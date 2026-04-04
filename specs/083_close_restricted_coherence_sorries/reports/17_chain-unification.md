# Cycle 3 Research: Chain Unification Analysis

## Summary

This report analyzes the feasibility of unifying the restricted chain (F-resolution) with the deterministic chain (Until persistence) to close the remaining completeness sorries. The analysis reveals both fundamental obstacles and a concrete path forward.

## Architecture Overview

### Three Truth Lemma Variants

The codebase has multiple truth lemma variants, each with different requirements:

| Variant | File | h_tc | h_uc | Until/Since Status |
|---------|------|------|------|-------------------|
| `canonical_truth_lemma` | CanonicalConstruction.lean:492 | Required | Not used | **sorry** (L631-632) |
| `shifted_truth_lemma` | CanonicalConstruction.lean:654 | Required | Not used | **sorry** (L781-782) |
| `restricted_shifted_truth_lemma_strict` | CanonicalConstruction.lean:814 | Restricted | Not used | **sorry** (L940,943) |
| `parametric_canonical_truth_lemma` | ParametricTruthLemma.lean:219 | Required | Required | **sorry-free** |
| `parametric_shifted_truth_lemma` | ParametricTruthLemma.lean:414 | Required | Required | **sorry-free** |

**Key finding**: The parametric truth lemma (D-generic) is the ONLY sorry-free variant that handles Until/Since. It requires both `h_tc : B.temporally_coherent` and `h_uc : B.until_since_coherent` on the SAME BFMCS.

### ParametricRepresentation.lean is Broken

The file `ParametricRepresentation.lean` does NOT currently build:
- Error at line 294: `countermodel_implies_not_provable` calls `parametric_shifted_truth_lemma B h_tc` without providing `h_uc`
- The `parametric_algebraic_representation_conditional` (line 254) also lacks `h_uc` in its `construct_bfmcs` signature
- Both need to be updated to thread `h_uc` through

### Chain Constructions Available

| Chain | Base | forward_G | backward_H | forward_F | until_persist | x_content link |
|-------|------|-----------|------------|-----------|---------------|----------------|
| Deterministic | x_content | sorry-free | sorry-free | **UNPROVABLE** | sorry-free | YES (by definition) |
| SuccChain (full MCS) | Lindenbaum/Succ | sorry-free | sorry-free | **sorry** | NO | NO |
| Restricted (DRM) | Lindenbaum/DRM | N/A | N/A | **sorry-free** | NO | NO |
| Targeted | canonical_F/P | one-step only | one-step only | per-target | NO | NO |

## Approach Analysis

### Approach A: Transfer forward_F from restricted to deterministic chain -- BLOCKED

The restricted chain and deterministic chain produce DIFFERENT sequences from the same seed. `psi in DRM(n+1)` does NOT imply `psi in det_chain(n+1)` because the constructions diverge after step 0. No transfer theorem exists.

### Approach B: Prove forward_F for deterministic chain directly -- IMPOSSIBLE

The task context correctly identifies that F-deferral fixed points exist: an MCS can consistently contain `{neg(psi), F(psi), X(neg(psi)), X(F(psi))}`. The deterministic chain from such an MCS defers F(psi) forever. Forward_F is genuinely **unprovable** for the deterministic chain in general.

### Approach C: Different chains for h_tc vs h_uc -- IMPOSSIBLE

The parametric truth lemma requires `h_tc` and `h_uc` on the SAME `B : BFMCS D`. Both are passed to the same induction and used within the same family `fam`. There is no way to split them across different structures.

### Approach D: Seed = x_content -- COLLAPSES

Since x_content(M) is already MCS (maximal), any Lindenbaum extension of x_content(M) IS x_content(M). We can't add targeted F-resolution to x_content because x_content is deterministic and maximal.

### Approach E: DRM-level truth lemma -- BLOCKED for box

A DRM-level truth lemma can't handle the box case because DeferralRestrictedMCS doesn't track box formulas beyond deferralClosure. The box case requires full MCS properties (modal saturation across families).

## Key Insight: D = Int Simplifies Until/Since Coherence

For D = Int (discrete timeline), the `until_since_coherent` definition simplifies dramatically because **there are no integers strictly between n and n+1**:

### forward_until simplification

```
forward_until: (phi U psi) in chain(n) -> exists s > n, psi in chain(s)
               AND forall r, n < r < s, phi in chain(r)
```

Taking s = n+1 (if psi in chain(n+1)): the guard `forall r, n < r < n+1` is **vacuously true** (no integers in that interval). So forward_until reduces to:

```
(phi U psi) in chain(n) -> exists s > n, psi in chain(s)
```

Which is: `F(psi) in chain(n) -> exists s > n, psi in chain(s)` = forward_F applied to psi. Since `(phi U psi) -> F(psi)` is derivable via `until_implies_some_future`.

### backward_until for deterministic chain

For the deterministic chain (where chain(k) = x_content(chain(k-1))):

Given witness s > n with psi in chain(s) and phi at all intermediate integers, backward induction from s to n:

1. **Base (k=s)**: psi in chain(s) = x_content(chain(s-1)), so X(psi) in chain(s-1). Since `psi -> psi v (phi AND (phi U psi))` is derivable, X(psi v ...) in chain(s-1). By until_intro: (phi U psi) in chain(s-1).

2. **Step (k to k-1)**: phi in chain(k) and (phi U psi) in chain(k) (IH). So `phi AND (phi U psi)` in chain(k) = x_content(chain(k-1)). Then X(phi AND (phi U psi)) in chain(k-1). Since `(phi AND (phi U psi)) -> psi v (phi AND (phi U psi))` is derivable, X(psi v ...) in chain(k-1). By until_intro: (phi U psi) in chain(k-1).

3. **Terminal (k=n+1 to n)**: (phi U psi) in chain(n+1) = x_content(chain(n)). So X(phi U psi) in chain(n). But we need (phi U psi) in chain(n), not X(phi U psi).

**GAP**: X(phi U psi) in chain(n) does NOT imply (phi U psi) in chain(n). The backward induction produces the Until formula one step AHEAD of where we need it.

### Resolution of the gap

The issue is that X(alpha) -> alpha is not valid under strict semantics. However:

**Option 1**: If we allow non-strict semantics (G/H at >= / <=), the truth_at for Until uses `s >= t` (not s > t), so s = t is allowed. Then forward_until at s = n: psi in chain(n) directly. But the codebase uses strict semantics consistently.

**Option 2**: Use the `until_intro` axiom differently. until_intro says: `X(psi v (phi AND (phi U psi))) -> (phi U psi)`. If we can show `X(psi v (phi AND (phi U psi))) in chain(n)`, we get `(phi U psi) in chain(n)`.

For the deterministic chain: `psi v (phi AND (phi U psi)) in chain(n+1)` iff `X(psi v (phi AND (phi U psi))) in chain(n)`. From step 2 of the backward induction, we have `(phi U psi) in chain(n+1)`. By until_unfold in chain(n+1): `X(psi v (phi AND (phi U psi))) in chain(n+1)`. So `psi v (phi AND (phi U psi)) in chain(n+2)`.

This doesn't help directly. But from `(phi U psi) in chain(n+1)` and the until_unfold, we get `X(psi v ...) in chain(n+1)`, hence `psi v ... in x_content(chain(n+1)) = chain(n+2)`. This is going the wrong direction.

**Option 3**: Direct proof via until_intro at position n.

We need `X(psi v (phi AND (phi U psi))) in chain(n)`, which means `psi v (phi AND (phi U psi)) in x_content(chain(n)) = chain(n+1)`.

From the backward induction, we have (phi U psi) in chain(n+1). By MCS disjunction: `psi v (phi AND (phi U psi))` is implied by `(phi U psi) v psi`. Since psi or (phi U psi) is in chain(n+1) (by negation completeness), one of these holds. If (phi U psi) in chain(n+1), then by until_unfold, we get the disjunction in chain(n+1).

Actually, more directly: from `(phi U psi) in chain(n+1)`:
- until_unfold: `(phi U psi) -> X(psi v (phi AND (phi U psi)))` in the proof system
- So `X(psi v (phi AND (phi U psi))) in chain(n+1)` (by MCS)
- This means `psi v (phi AND (phi U psi)) in chain(n+2)`

But we need it in chain(n+1), not chain(n+2). The issue remains.

However, there's a simpler approach. From `(phi U psi) in chain(n+1)`, by MCS, EITHER `psi in chain(n+1)` OR `neg(psi) in chain(n+1)`.

If `psi in chain(n+1)`: then `psi v (phi AND (phi U psi)) in chain(n+1)`. So `X(psi v ...) in chain(n)`. By until_intro: `(phi U psi) in chain(n)`. DONE.

If `neg(psi) in chain(n+1)`: then by until_unfold + the disjunction in MCS, `phi AND (phi U psi) in chain(n+1)`. So `phi AND (phi U psi) in chain(n+1)`, hence `(phi AND (phi U psi)) -> psi v (phi AND (phi U psi))` gives `psi v (phi AND (phi U psi)) in chain(n+1)`. So `X(psi v ...) in chain(n)`. By until_intro: `(phi U psi) in chain(n)`. DONE.

**This WORKS.** The key step I was missing: from `(phi U psi) in chain(n+1)`, we can derive `psi v (phi AND (phi U psi)) in chain(n+1)` regardless of whether psi is in chain(n+1). This is because:
- `(phi U psi) -> X(psi v (phi AND (phi U psi)))` (until_unfold)
- But we want the disjunction in chain(n+1), not X of it

Actually, wait. We DON'T use until_unfold. Instead:
- Case 1: psi in chain(n+1). Then `psi v anything` in chain(n+1). Done.
- Case 2: neg(psi) in chain(n+1) and (phi U psi) in chain(n+1). The until_unfold gives us X(psi v (phi AND (phi U psi))) in chain(n+1). This gives us the disjunction in chain(n+2), NOT chain(n+1).

Hmm. Actually we need a different approach for case 2.

From neg(psi) in chain(n+1) and (phi U psi) in chain(n+1): by the until persistence theorem (sorry-free for the deterministic chain!), `phi in chain(n+2) AND (phi U psi) in chain(n+2)`. But this gives us Until at n+2, not at n.

Let me think again about what we actually need. We need `psi v (phi AND (phi U psi)) in chain(n+1)`. If (phi U psi) in chain(n+1):

In any MCS, `alpha -> alpha v beta` is derivable for any beta. So `(phi U psi) -> (phi U psi) v psi` is in the MCS. Wait, `(phi U psi) v psi` is not the same as `psi v (phi AND (phi U psi))`.

We need `psi v (phi AND (phi U psi))`. From (phi U psi), can we derive this?

Actually, let's check: is `(phi U psi) -> psi v (phi AND (phi U psi))` derivable? Semantically: if phi U psi at time t, then either psi at some s > t (exists), or... no. Under strict semantics, (phi U psi) means exists s > t with psi(s) and phi at intermediates. This does NOT imply psi v (phi AND (phi U psi)) AT TIME t. It's about future times.

So `(phi U psi) -> psi v (phi AND (phi U psi))` is NOT valid under strict semantics. Under non-strict semantics (s >= t), it would be derivable by taking s = t.

This means the backward_until backward induction has a genuine gap at the last step under strict semantics.

## Recommended Approach

### Path 1: Targeted chain + forward_G recovery + Until/Since coherence for Int

Build a chain that combines the targeted chain's F-resolution with full forward_G/backward_H (recovering the archived proofs, which are straightforward for strict semantics using the same temp_4 argument as SuccChainFMCS).

For D = Int until_since_coherent:
- **forward_until**: follows from forward_F (via (phi U psi) -> F(psi) + the chain's F-resolution). The guard is vacuous for D = Int.
- **backward_until**: requires x_content linkage for the induction, which the targeted chain does NOT have. This is the remaining gap.

### Path 2: Hybrid approach with deterministic chain for backward_until

For backward_until, use a SEPARATE argument that doesn't go through the chain:
- Given witness s > n with psi in chain(s) and phi at intermediates, we need (phi U psi) in chain(n)
- This can be proved axiomatically if the Until axioms (until_intro, etc.) are available

**CRITICAL OBSERVATION**: The Until/Since axioms are classified as `Discrete` in the axiom system. They are NOT in the base axiom set (`isBase = False`). This means:

1. **Base completeness** does NOT need Until/Since coherence at all -- the Until/Since axioms are not available, so the only formulas provable in the base system don't require Until/Since truth lemma cases
2. **Discrete completeness** DOES need Until/Since coherence, and the Until axioms ARE available for the proof

### Path 3 (RECOMMENDED): Separate base and discrete completeness chains

**For base completeness** (the current main target):
- Use the existing SuccChainFMCS or targeted chain
- The truth lemma sorry for Until/Since can be closed by noting that base-provable formulas never require Until/Since truth
- Alternatively, add `h_uc` as a vacuous hypothesis since no base MCS will have formula membership that triggers Until/Since evaluation

Wait, this isn't quite right either. The truth lemma is proved by structural induction on formulas. ALL formula constructors must be handled, including `untl` and `snce`. The base MCS CAN contain Until formulas (they're syntactically valid). The issue is whether the truth lemma holds for them.

### Path 4 (MOST PROMISING): Two-phase completeness

**Phase A**: For formulas WITHOUT Until/Since subformulas (covering base and most practical use), the existing truth lemma (with sorry only for Until/Since) DOES work. This gives completeness for the Until/Since-free fragment.

**Phase B**: For formulas WITH Until/Since (discrete completeness), build the deterministic chain as an FMCS and prove:
1. `temporally_coherent` via a HYBRID argument: use the DRM chain's F-resolution result EXISTENTIALLY (there exists a chain with F-resolution) combined with the deterministic chain's Until persistence
2. `until_since_coherent` via the deterministic chain's x_content linkage

The key insight for Phase B: the deterministic chain doesn't have forward_F on its own, but we can LIFT the DRM chain's F-resolution result. Specifically:

**Claim**: If F(psi) in chain(n) for the deterministic chain from M0, and psi in deferralClosure(root), then there exists s > n with psi in chain(s).

**Proof sketch**:
1. F(psi) in M0's deterministic chain at n
2. The DRM restricted chain from M0 (restricted to deferralClosure) resolves F(psi) within d = max_F_depth steps
3. psi in DRM(n+d)
4. The full Lindenbaum extension of DRM(n+d) contains psi (since psi in deferralClosure subset DRM)

But step 4 gives psi in the Lindenbaum extension of DRM(n+d), NOT in det_chain(n+d). The Lindenbaum extension is a different MCS than x_content^d(chain(n)).

**This approach fails** because the two chains are fundamentally different.

## Concrete Recommendation

The most viable path is to prove `until_since_coherent` for the SuccChainFMCS by showing that the constrained successor construction, combined with the DRM-level F-resolution, gives Until/Since coherence over Int.

Specifically:

1. **Fix ParametricRepresentation.lean**: Update `construct_bfmcs` signature to also return `h_uc`, and thread `h_uc` through `parametric_algebraic_representation_conditional` and `countermodel_implies_not_provable`. This is a small mechanical fix.

2. **Prove `succ_chain_restricted_forward_F`** (the main sorry in UltrafilterChain.lean:3917):
   - The constrained successor from seed includes `deferralDisjunctions(u)` in the seed
   - Deferral disjunctions: `psi v F(psi)` for F(psi) in u
   - The DRM chain resolves F in one step (f_content ⊆ successor)
   - Need to show this lifts from the DRM seed to the full MCS chain
   - The Lindenbaum extension of the seed preserves seed membership, so the deferral disjunction `psi v F(psi)` is in chain(n+1)
   - In chain(n+1) (MCS): either psi or F(psi). If psi: done. If F(psi): deferred.
   - This gives the F-step: `F(psi) in chain(n) -> psi in chain(n+1) OR F(psi) in chain(n+1)`
   - The DRM-level F-bounded property (max nesting depth d) combined with this F-step gives resolution within d steps

3. **Prove `until_since_coherent` for Int**:
   - forward_until follows from forward_F (step 2 above)
   - backward_until requires a separate proof using the until_intro axiom. The x_content gap can potentially be bridged using: if (phi U psi) holds at n+1 in the chain, and chain(n+1) satisfies the Succ relation with chain(n), then we need X(psi v (phi AND (phi U psi))) in chain(n). This requires showing `psi v (phi AND (phi U psi)) in x_content(chain(n))`, which needs `psi v (phi AND (phi U psi)) in chain(n+1)`. Since chain(n+1) is MCS and (phi U psi) in chain(n+1), case split on psi gives the disjunction. Then X of it in chain(n) requires that chain(n+1) = x_content(chain(n))... which is only true for the deterministic chain.

   **Alternatively**: backward_until for Int can use the until_induction axiom. Given `psi in chain(s)` for s > n and `phi` at all intermediates, apply until_induction with appropriate chi to derive `(phi U psi) in chain(n)`. This needs careful axiom engineering but avoids x_content linkage entirely.

## Active Sorries to Close (Priority Order)

1. `succ_chain_restricted_forward_F` (UltrafilterChain.lean:3917) -- THE key sorry
2. `succ_chain_restricted_backward_P` (UltrafilterChain.lean:3927) -- symmetric
3. Until/Since cases in `canonical_truth_lemma` (CanonicalConstruction.lean:631-632)
4. Until/Since cases in `shifted_truth_lemma` (CanonicalConstruction.lean:781-782)
5. Until/Since cases in `restricted_shifted_truth_lemma_strict` (CanonicalConstruction.lean:940,943)
6. Fix `ParametricRepresentation.lean` type errors (missing h_uc)

Note: Items 3-5 can be eliminated by migrating to the parametric truth lemma (items 1-2 + item 6).

## Files Examined

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/DeterministicChain.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BaseCompleteness.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean`
