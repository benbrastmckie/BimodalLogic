# Teammate B Findings: Alternative Approaches Assessment

**Task**: 84 -- Establish `until_since_coherent` for Bundle Completeness
**Focus**: Review and assess alternative mathematical approaches from task 83 and broader literature
**Date**: 2026-04-08
**Artifact**: 04b

---

## Key Findings

### 1. The Forward Direction Is the SOLE Remaining Blocker (HIGH confidence)

The backward directions (conjuncts 2 and 4 of `until_since_coherent`) are fully proved in `UntilSinceCoherence.lean`, parameterized by a step transfer hypothesis. The step transfer for the backward direction composes `or_until_in_mcs` (BX8+BX9) with the chain structure. Phase 1 (derive `until_intro`/`since_intro`) and Phase 2 (backward proofs) are complete. The entire problem reduces to the forward directions: given `(phi U psi) in fam.mcs t`, find `s >= t` with `psi in fam.mcs s` and `phi in fam.mcs r` for `t <= r < s`.

### 2. Bilateral Tuple Approach: NOT RECOMMENDED (HIGH confidence)

The task 953 "bilateral" refactoring concerns bilateral proof systems (assertion/denial judgments), not bilateral demand/supply tuples for chain construction. No bilateral tuple construction exists in the codebase or prior reports.

A hypothetical bilateral tuple approach -- pairing each chain element with a "demand set" (formulas needing future witnesses) and "supply set" (formulas available from the chain) -- is essentially a repackaging of the quasimodel/dovetailed scheduling idea. The fundamental blocker identified in report 24 (task 83) remains: when taking a detour to resolve an F-obligation, the Until formula `(phi U psi)` at the current chain position is NOT preserved because it is X-liftable but not G-liftable. The demand/supply framing changes the bookkeeping but does not change the underlying mathematics. The guard persistence gap is the same: demonstrating `phi in fam.mcs r` for all `r` between `t` and the witness `s` requires the chain to maintain the Until formula's guard through each intermediate step.

**Cost**: Estimated 1500-2000 LOC (per report 03 synthesis). Not justified given the identical mathematical obstacle.

### 3. "Pull Before Push" / Reduction to F-Resolution: MOST PROMISING BUT INCOMPLETE (MEDIUM confidence, 55%)

The idea: since BX10 gives `(phi U psi) -> F(psi)`, if we had `forward_F` (existential future witness), we would get `psi in fam.mcs s` for some `s > t`. But then we need the guard: `phi in fam.mcs r` for all `r in [t, s)`. Can this be reconstructed from BX5 (self-accumulation)?

**Analysis of guard reconstruction**:

Given `(phi U psi) in fam.mcs t` and knowing `psi in fam.mcs s` for some `s > t`:

1. BX5 gives `(phi U psi) -> ((phi AND (phi U psi)) U psi)`. So `((phi AND (phi U psi)) U psi) in fam.mcs t`.

2. BX9 (elimination) gives `((phi AND (phi U psi)) U psi) -> (phi AND (phi U psi)) OR psi`. Unfolding at each position from t to s: either `psi` appears (and we are done), or `phi AND (phi U psi)` holds.

3. So at each position `r` between `t` and the FIRST occurrence of `psi`, we get `phi in fam.mcs r` AND `(phi U psi) in fam.mcs r`.

**The critical question**: Does this work ACROSS chain steps? Step 2 uses BX9 to unfold at a SINGLE MCS. To go from position `r` to position `r+1`, we need `(phi U psi) in fam.mcs r` to imply something about `fam.mcs (r+1)`. Under BX with the dovetailed chain:

- The chain guarantees `g_content(fam.mcs r) subset fam.mcs (r+1)`.
- `(phi U psi) in fam.mcs r` does NOT imply `G(phi U psi) in fam.mcs r` (Until is existential, G is universal). So `(phi U psi)` is not in `g_content(fam.mcs r)`.
- Therefore `(phi U psi)` does NOT propagate to `fam.mcs (r+1)` through the g_content mechanism.

**Conclusion**: The guard reconstruction via BX5+BX9 works within a single MCS but does NOT transfer across chain steps for non-deterministic chains. For the deterministic chain (where `fam.mcs (r+1) = x_content(fam.mcs r)`), it DOES work because `until_unfold` gives `X(psi OR (phi AND (phi U psi))) in fam.mcs r`, and under BX `X(alpha) = alpha`, so the disjunction is in `fam.mcs r` itself. But under BX, `x_content(M) = M` (since `X(alpha) <-> alpha`), making the chain constant, which makes forward Until trivially unsatisfiable for formulas where `psi not in M`.

**Verdict**: Pull-before-push reduces to F-resolution, which is exactly the same `forward_F` problem. The guard CAN be extracted IF the chain construction already preserves Until through steps. This is circular.

### 4. Quasimodel Method Under BX Reflexive Semantics: FAILS (HIGH confidence)

Report 24 (task 83) exhaustively analyzed the quasimodel (GHR 1994) approach. The key conclusion (Section 1.9) applies directly:

Under BX reflexive semantics, G(phi) -> phi IS valid (BX1). This means `g_content(M) subset M` for any MCS M. However, the critical direction is the REVERSE: we need `(phi U psi) in M` to imply `(phi U psi) in g_content(M)`, i.e., `G(phi U psi) in M`. BX1 only gives the forward direction (`G(alpha) -> alpha`), not the converse (`alpha -> G(alpha)`).

Published proofs (Burgess 1984, GHR 1994) work with reflexive-TRANSITIVE temporal semantics where the accessibility relation ensures that if a formula holds at all reachable states, G of that formula holds. Under BX, this works for the deterministic chain (where reachability is trivial since the chain is constant), but NOT for the dovetailed chain where different chain elements may differ.

**Linearization question**: Can a quasimodel graph be linearized into an omega chain? Report 24 Section 1.4-1.5 shows that any linearization that takes "detours" (jumping to witness MCSes) breaks Until persistence. The detour step path(n+1) = W (witness MCS) satisfies `g_content(path(n)) subset W` but NOT `x_content(path(n)) subset W`. Since Until persistence requires the x_content linkage, linearization breaks the property.

**Verdict**: The quasimodel approach does not yield a working chain construction for TM with BX axioms without solving the same G-liftability problem.

### 5. Reduction to F-Resolution via BX10: CIRCULAR (HIGH confidence)

BX10 gives `(phi U psi) -> F(psi)`. The current `DovetailedFMCS_forward_F` theorem is itself `sorry`:

```
DovetailedFMCS_forward_F (line 1296): sorry
-- depends on forward_dovetailed_until_persists (line 614): sorry
```

So `forward_F` is NOT available. It depends on Until persistence through Lindenbaum steps, which is the SAME blocker as forward Until coherence. We cannot reduce forward Until to forward_F because forward_F is blocked by the same fundamental obstacle.

The `restricted_forward_chain_forward_F` in SuccChainFMCS.lean (line 3128) does have a proof, but it applies to the SuccChain construction with restricted theories. This IS available sorry-free for the restricted path (lines 356/450 of Completeness.lean use restricted TC), but `until_since_coherent` is quantified over ALL formulas, not just those in the deferral closure.

### 6. Restructuring the Predicate: VIABLE TACTICAL MOVE (MEDIUM-HIGH confidence, 70%)

The `until_since_coherent` predicate has four conjuncts:
1. Forward Until: `(phi U psi) in M_t -> exists s >= t, ...`
2. Backward Until: `(exists s >= t, ...) -> (phi U psi) in M_t`
3. Forward Since: `(phi S psi) in M_t -> exists s <= t, ...`
4. Backward Since: `(exists s <= t, ...) -> (phi S psi) in M_t`

Conjuncts 2 and 4 are proved (parameterized). Conjuncts 1 and 3 are blocked.

**Option A: Split into half-coherence predicates**

Define `BFMCS.backward_until_since_coherent` (conjuncts 2,4 only) and `BFMCS.forward_until_since_coherent` (conjuncts 1,3 only). The truth lemma's Until backward direction (semantic -> syntactic) uses ONLY backward coherence. The truth lemma's Until forward direction (syntactic -> semantic) uses ONLY forward coherence.

The truth lemma structure in `ParametricTruthLemma.lean` and `CanonicalConstruction.lean` threads `h_uc : B.until_since_coherent` through. If we split this, the backward half can be provided immediately, and the forward half can remain as a more precisely scoped sorry.

**Benefit**: Closes the backward direction completely, narrows the sorry surface to "forward Until/Since coherence" specifically. This makes the sorry more informative and may reveal that the forward direction is used in fewer places than expected.

**Option B: Weaken forward coherence to use forward_F**

Rewrite forward Until coherence as: given `(phi U psi) in fam.mcs t`, the chain satisfies `forward_F` for `psi`, yielding `s > t` with `psi in fam.mcs s`. Then separately argue the guard via Until self-accumulation (BX5) and chain structure.

This requires the chain to have a specific structural property: Until persistence through chain steps. For the deterministic chain (constant under BX), this is trivially true but gives a constant chain. For the dovetailed chain, it is the blocker.

**Option C: Define a new chain construction**

Instead of modifying the existing dovetailed chain, define a new "Until-aware" chain construction. The key insight: under BX, the deterministic chain is constant (because X(alpha) = alpha). So all Until obligations are "already resolved" at the start -- if `(phi U psi) in M`, then by BX9, either `psi in M` (resolved immediately) or `phi AND (phi U psi) in M` (active but unresolved). If `psi not in M`, then the chain will NEVER resolve it because the chain is constant.

This suggests the problem is not in the chain construction but in the CHOICE of starting MCS. The Lindenbaum extension that produces M from {neg(phi_0)} determines all temporal content. If `(phi U psi) in M` but `psi not in M`, we need to find a witness MCS W where `psi in W` and certain coherence properties hold. The forward temporal witness seed (`{psi} union g_content(M)`) provides such a W via Lindenbaum extension. The issue is that W may not agree with M on Until formulas.

**Verdict on restructuring**: Option A is the cleanest tactical move. It separates what is provable (backward) from what is blocked (forward), giving a clearer picture of the remaining work. However, it does NOT close any of the three sorry sites in Completeness.lean -- those all need the full predicate.

---

## Recommended Approach

**Primary recommendation: A two-pronged strategy combining predicate restructuring (Option A) with a novel argument for the constant-chain case.**

### Prong 1: Exploit the Constant Chain (NOVEL OBSERVATION)

Under BX reflexive semantics, `X(alpha) = alpha` in any MCS (BX8+BX9). This means `x_content(M) = M` for any MCS M, and the deterministic chain is constant: `chain(n) = M` for all `n`.

For a constant chain:
- **Forward Until**: `(phi U psi) in M`. By BX9, `phi OR psi in M`. If `psi in M`, the witness is `s = t` (BX8 gives reflexive Until, and BX definition uses `t <= s`). If `psi not in M`, then `phi in M` and `(phi U psi) in M`. But also by BX10, `F(psi) in M`. Under the constant chain, `fam.mcs s = M` for all `s`, so `psi not in fam.mcs s` for any `s`. But `F(psi) in M` means `neg(G(neg(psi))) in M`. In the constant chain, `neg(psi) in M` at every time, so `G(neg(psi))` SHOULD be in M... but proving this requires temporal_backward_G, which requires forward_F. **Same circularity.**

Wait -- BUT in the constant chain, `G(alpha) in M iff alpha in M` (because BX1 gives `G(alpha) -> alpha` and under reflexive semantics with a constant chain where every future time has the same MCS). Actually, this is the key question: is `G(alpha) in M` for every `alpha in M`?

Under BX1: `G(alpha) -> alpha`. So `alpha in M` does NOT imply `G(alpha) in M`. The implication goes only one way. A constant chain where `neg(psi) in M` at all times means `neg(psi)` holds at all future times, so SEMANTICALLY `G(neg(psi))` should be true. But we cannot derive this syntactically without the backward G step.

**THIS IS EXACTLY THE SAME CIRCULARITY.** The constant chain does not help.

### Prong 2: Predicate Split (Tactical)

Split `until_since_coherent` into backward and forward halves. Provide backward half immediately. Leave forward half as a precisely scoped sorry. This requires:

1. Refactor `ParametricTruthLemma.lean` to accept split coherence
2. Refactor `CanonicalConstruction.lean` similarly
3. Prove backward half for all three construction paths
4. Potentially close sorry sites for directions that only need backward coherence

**Assessment of truth lemma structure**: The Until case in the truth lemma has TWO directions:
- Forward (syntactic -> semantic): `(phi U psi) in fam.mcs t -> exists s >= t, truth(psi, s) AND ...`
  This needs forward Until coherence (conjunct 1) to get the MCS-level witness, then IH to convert to truth.
- Backward (semantic -> syntactic): `exists s >= t, truth(psi, s) AND ... -> (phi U psi) in fam.mcs t`
  This needs backward Until coherence (conjunct 2) with IH applied to convert truth to MCS membership.

So splitting the predicate WOULD allow the backward truth lemma direction to be proved without forward coherence. But the full truth lemma (bidirectional iff) needs both. The completeness proof uses the backward direction: validity implies truth, truth lemma backward gives MCS membership. So completeness uses the semantic -> syntactic direction, which uses backward Until coherence. This is available.

**BUT WAIT**: The completeness proof also uses the truth lemma for G, which in the backward direction (truth -> syntactic) requires `forward_F`. So even if we split Until coherence, the G case still needs `forward_F`, which is part of `temporally_coherent`. The sorry at line 322 already depends on `temporally_coherent` being sorry. Lines 356 and 450 use restricted/dovetailed TC which are sorry-free for TC but still sorry for UC.

### Revised Assessment

The fundamental blocker is NOT until_since_coherent in isolation -- it is the interaction between forward_F and the truth lemma's G backward case. The forward Until coherence depends on the same chain construction that forward_F depends on. Splitting until_since_coherent does NOT close any Completeness.lean sorry, because the truth lemma needs both directions.

**However**: Re-reading the definition at TemporalCoherence.lean:466-479, the forward Until uses `t <= s` (non-strict). If `psi in fam.mcs t` directly (the reflexive base case), the witness is `s = t`. By BX9, `(phi U psi) in M` implies `phi OR psi in M`. If `psi in M`, forward Until is trivially satisfied with `s = t`.

The hard case is `(phi U psi) in M` with `psi not in M`. In this case we need a STRICT future witness. This is exactly the eventuality resolution problem.

---

## Evidence/Examples

### Evidence that all approaches converge on the same blocker

| Approach | What It Needs | Why It Fails |
|----------|---------------|-------------|
| Enriched seed | G(phi U psi) in M | Not derivable from (phi U psi) in M |
| Quasimodel detour | x_content preservation through detours | Detours use g_content, not x_content |
| F-resolution + guard | forward_F for psi | forward_F has the same sorry chain |
| Constant chain | G(neg(psi)) from constant membership | Requires temporal_backward_G, circular |
| Finite deferral | Contradiction from cycle | Requires G(neg(psi)) or semantic truth lemma |
| Well-founded induction | Decreasing formula size | Sizes increase through dependency chain |

### Evidence for the predicate split being the best tactical move

The backward Until/Since proofs in `UntilSinceCoherence.lean` are fully proved and parameterized. The step transfer can be instantiated for any chain that preserves `(phi U psi)` backward (which the deterministic chain trivially does, and which the dovetailed chain does for formulas in g_content). However, wiring these into the completeness proof requires the full `until_since_coherent` predicate, so the split alone does not close sorries.

---

## Confidence Level

- **Bilateral tuple approach is unhelpful**: 95% confidence
- **Quasimodel fails under BX**: 95% confidence (confirmed by report 24 analysis + BX1 limitation)
- **Reduction to F-resolution is circular**: 95% confidence
- **Guard reconstruction from BX5 works within MCS but not across chain steps**: 90% confidence
- **Predicate split is the best tactical move but does not close sorries**: 85% confidence
- **All approaches converge on the same fundamental blocker (G-liftability of Until)**: 95% confidence

---

## Summary Assessment

The forward direction of `until_since_coherent` is blocked by the same fundamental obstacle as `forward_F`: converting meta-level knowledge ("neg(psi) at all future chain positions") into object-level membership ("G(neg(psi)) in chain(t)") requires `temporal_backward_G`, which requires `forward_F`, creating an intrinsic circularity in the truth lemma structure.

Every alternative approach analyzed -- bilateral tuples, quasimodels, F-resolution, constant chains, finite deferral -- converges on this same blocker. The BX reflexive semantics (BX1: G(alpha) -> alpha) provides the forward direction but not the reverse needed for G-liftability.

**The most productive next step** is NOT to continue searching for clever chain constructions. Instead:

1. **Accept** that forward Until/Since coherence requires solving forward_F first (or simultaneously).
2. **Focus** on approaches that break the `forward_F` <-> `temporal_backward_G` circularity, such as:
   - The restricted truth lemma approach (which already has sorry-free restricted TC)
   - A restricted version of `until_since_coherent` that quantifies only over formulas in the deferral closure
   - A restructured proof that proves forward_F and the truth lemma by simultaneous well-founded induction (despite the size increase concern from report 24 Section 4.4, there may be a reformulation that avoids it)
3. **Split** `until_since_coherent` into backward (proved) and forward (sorry) halves as a documentation improvement, even if it doesn't close the Completeness.lean sorry sites.
