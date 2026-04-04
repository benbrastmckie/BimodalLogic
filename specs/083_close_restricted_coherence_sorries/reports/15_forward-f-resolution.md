# Forward F Resolution Analysis

## Task 83, Phase 5 Blocker: forward_F Circularity

**Date**: 2026-04-04
**Session**: sess_1743724801_c4d5e6
**Focus**: Evaluate approaches to close `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` sorries

---

## 1. Dependency Graph Analysis

### 1.1 The Circularity (Verified Against Code)

The fundamental circularity has been confirmed by tracing the actual Lean code:

```
truth_lemma_backward(G(psi))          [ParametricTruthLemma.lean:335]
  -> extracts forward_F from h_tc     [via h_tc fam hfam]
  -> temporal_backward_G uses          [TemporalCoherence.lean:177]
     fam.forward_F t (Formula.neg phi)

forward_F(neg(phi)):
  F(neg(phi)) in chain(t) -> exists s > t, neg(phi) in chain(s)

Proving forward_F needs truth lemma backward for G(neg(neg(phi))):
  truth_lemma_backward(G(neg(neg(phi)))) needs forward_F(neg(neg(neg(phi))))
  -> INFINITE REGRESS (negations grow unboundedly)
```

### 1.2 What Each Lemma Actually Needs

| Lemma | Dependencies | Needs forward_F? |
|-------|-------------|-------------------|
| truth_fwd(atom/bot) | trivial | NO |
| truth_fwd(imp psi chi) | truth_bwd(psi), truth_fwd(chi) | indirect via subformulas |
| truth_fwd(box psi) | truth_fwd(psi), modal_forward | NO |
| truth_fwd(G psi) | fam.forward_G only | **NO** |
| truth_fwd(H psi) | fam.backward_H only | **NO** |
| truth_fwd(untl/snce) | h_uc | NO (uses h_uc) |
| truth_bwd(atom/bot) | trivial | NO |
| truth_bwd(imp psi chi) | truth_fwd(psi), truth_bwd(chi) | indirect via subformulas |
| truth_bwd(box psi) | truth_bwd(psi), modal_backward | NO |
| truth_bwd(G psi) | temporal_backward_G -> forward_F(neg psi) | **YES** |
| truth_bwd(H psi) | temporal_backward_H -> backward_P(neg psi) | **YES** |
| truth_bwd(untl/snce) | h_uc | NO (uses h_uc) |

**Critical observation**: The forward direction for G/H is independent of forward_F.

### 1.3 Sorry-Free Infrastructure

| Component | File | Status |
|-----------|------|--------|
| `parametric_canonical_truth_lemma` | ParametricTruthLemma.lean | sorry-free (parametric in h_tc, h_uc) |
| `parametric_shifted_truth_lemma` | ParametricTruthLemma.lean | sorry-free |
| `deterministic_chain` (all properties) | DeterministicChain.lean | sorry-free |
| `until_persists_chain` | DeterministicChain.lean | sorry-free |
| `since_persists_chain` | DeterministicChain.lean | sorry-free |
| `G_persists_forward` (Nat arm) | DeterministicChain.lean | sorry-free |
| `H_persists_backward` (negSucc arm) | DeterministicChain.lean | sorry-free |
| `targeted_forward_successor` | TargetedChain.lean | sorry-free |
| `canonical_forward_F` / `canonical_backward_P` | CanonicalFrame.lean | sorry-free |
| `temporal_backward_G_with_fwd_F` | TemporalCoherence.lean | sorry-free (takes fwd_F as param) |
| `G_neg_bot_theorem` (G(top) derivable) | SuccChainFMCS.lean | sorry-free |
| `F_until_equiv` axiom | Axioms.lean | available (Discrete) |
| `until_unfold` axiom | Axioms.lean | available (Discrete) |

### 1.4 Sorry Sites on Critical Path

| Sorry | File:Line | Blocking |
|-------|-----------|----------|
| `succ_chain_restricted_forward_F` | UltrafilterChain.lean:3917 | restricted temporal coherence |
| `succ_chain_restricted_backward_P` | UltrafilterChain.lean:3927 | restricted temporal coherence |
| `restricted_shifted_truth_lemma` untl | CanonicalConstruction.lean:940 | Until truth lemma |
| `restricted_shifted_truth_lemma` snce | CanonicalConstruction.lean:943 | Since truth lemma |
| `DovetailedFMCS_forward_F` | DovetailedChain.lean:1235 | dovetailed coherence |
| `forward_dovetailed_until_persists` | DovetailedChain.lean:600 | Until in dovetailed |

---

## 2. Option Evaluation

### 2.1 Option A: Mutual Induction (Split Truth Lemma)

**Concept**: Decompose truth lemma into forward-only and backward parts; prove forward_F using only truth_lemma_forward for G formulas.

**Detailed analysis**:

The proposed package by formula-size induction:
```
P(phi) := truth_lemma(phi) AND forward_F(phi) AND backward_P(phi)
```

To prove `forward_F(phi)` within this package:
1. Assume `F(phi) in chain(t)`, want `exists s > t, phi in chain(s)`
2. By contrapositive: assume phi not in chain(s) for all s > t
3. Then neg(phi) in chain(s) for all s > t (MCS negation completeness)
4. By truth_lemma forward for neg(phi): truth(neg(phi), s) at all s > t
5. Semantically: truth(G(neg(phi)), t)
6. By truth_lemma backward for G(neg(phi)): G(neg(phi)) in chain(t)
7. Contradiction with F(phi) = neg(G(neg(phi))) in chain(t)

**Problem at step 6**: truth_lemma_backward for G(neg(phi)) needs `forward_F(neg(neg(phi)))`. But:
- `neg(neg(phi)) = (phi.imp bot).imp bot`
- This has size LARGER than phi
- The induction does not decrease

**Alternative**: Could step 5->6 avoid using backward_G? If phi in chain(s) for all s > t, can we directly derive G(phi) in chain(t)?

For the deterministic chain, backward_G proof requires the contrapositive argument (TemporalCoherence.lean:166-179). There is NO direct syntactic proof of `(forall s > t, phi in chain(s)) -> G(phi) in chain(t)` without the contrapositive.

The chain gives us `phi in chain(t+1)`, hence `X(phi) in chain(t)`, hence `F(phi) in chain(t)`. But `F(phi) != G(phi)`.

**Verdict**: **FAILS**. The circularity cannot be broken by formula-size induction because the contrapositive adds negations. No alternative to the contrapositive proof of backward_G is known.

### 2.2 Option B: Restricted Chain (DeferralRestrictedMCS)

**Concept**: Use DeferralRestrictedMCS chain with bounded F-nesting.

**Detailed analysis**:

The DRM approach has multiple independent problems:

1. **G-propagation fails at DRM level** (RestrictedTruthLemma.lean:108-121 sorry): G(G(psi)) may exceed deferralClosure, so G cannot persist through the chain.

2. **H-step fails at DRM level** (RestrictedTruthLemma.lean:148-168 sorry): Succ-based h_content_reverse requires full MCS properties unavailable in DRM.

3. **Lindenbaum extensions break chain structure**: DRM elements are extended to full MCS via Lindenbaum, but independent extensions at each position lose the Succ relation and x_content linkage.

4. **Until/Since cases still sorry** in restricted_shifted_truth_lemma (CanonicalConstruction.lean:940-943): Even with restricted temporal coherence, the Until case needs x_content propagation which the SuccChainFMCS doesn't have.

5. **TargetedChain archived**: The targeted chain building blocks are sorry-free, but `TargetedFMCS` and `forward_G`/`backward_H` were archived because they depend on the T-axiom (`G(phi) -> phi`), which is FALSE under strict semantics.

**Verdict**: **BLOCKED on multiple fronts**. Would require solving G-propagation, H-step, and Until/Since independently. Estimated 15-20h.

### 2.3 Option C: Parametric Truth Lemma Path

**Concept**: Use `parametric_canonical_truth_lemma` (sorry-free, parametric in h_tc and h_uc). Prove h_tc and h_uc for a concrete chain.

**Analysis**:

The parametric truth lemma requires:
- h_tc: `B.temporally_coherent` = forward_F + backward_P for ALL formulas
- h_uc: `B.until_since_coherent` = forward/backward Until + forward/backward Since

For h_uc: `forward_until` itself needs forward_F (the proof goes: `(phi U psi) -> F(psi)` then forward_F to get witness). So h_uc depends on h_tc.

The deterministic chain has sorry-free until/since persistence, but `forward_until` (finding the initial witness s) still requires forward_F.

**Verdict**: **BLOCKED by the same forward_F issue**. h_uc cannot be proved independently of h_tc.

---

## 3. The Fundamental Problem

All three options fail because of the same root cause:

> **There is no known proof of `forward_F` for any chain construction that does not use the truth lemma backward for G, which itself requires forward_F.**

The circularity is:
```
forward_F -> (via contrapositive) truth_lemma_backward(G) -> forward_F
```

And:
```
forward_until -> forward_F -> truth_lemma_backward(G) -> forward_F
```

### 3.1 Why the Textbook Proof Works

In standard temporal logic completeness proofs, forward_F is ensured BY CONSTRUCTION of the chain, not proved after the fact. The chain is built to RESOLVE F-obligations:

1. At each step n, if F(psi) is in the current MCS, the next MCS is chosen to contain psi (or at least to make progress toward resolving psi).

2. The dovetailed/targeted chain approaches in this codebase attempt this, but they use g_content-based successors (which preserve G-formulas but NOT x_content/Until), so Until persistence is lost.

3. The deterministic chain preserves Until (via x_content) but does NOT resolve F-obligations.

### 3.2 The Missing Construction

What is needed is a chain that has BOTH:
- **x_content propagation** (chain(n+1) = x_content(chain(n)) or a superset), for Until persistence
- **F-resolution** (F(psi) in chain(n) -> eventually psi in chain(n+k)), by construction

These are not inherently contradictory. The deterministic chain has the first. The targeted chain has the second. A hybrid could have both.

---

## 4. Recommended Approach: Option D (Hybrid Deterministic-Targeted Chain)

### 4.1 Core Idea

Build a chain where:
- The default successor is `x_content(chain(n))` (deterministic, for Until persistence)
- At selected steps, use a targeted successor that resolves a specific F-obligation AND includes x_content

Since `g_content(M) subset x_content(M)` (because `G(phi) -> X(phi)` is derivable), and `canonical_forward_F` gives a successor W with `g_content(M) subset W` and `psi in W`, we can take the successor to be an MCS extending `x_content(M) union {psi}` where `psi` is the formula being resolved.

### 4.2 Construction

Given MCS M_0:

1. Enumerate `deferralClosure(root)` as `{psi_1, psi_2, ..., psi_N}` (finite)
2. Build forward chain with round-robin scheduling:
   - At step `n`, let `target = psi_{n mod N}`
   - If `F(target)` is in `chain(n)`: build successor that contains `x_content(chain(n))` AND `target`
   - Otherwise: use `x_content(chain(n))` as usual

3. The successor in the F-resolution case must be shown to be an MCS containing x_content(chain(n))

### 4.3 Key Technical Challenge

The targeted successor from `canonical_forward_F` gives W with:
- `SetMaximalConsistent W`
- `psi in W`
- `g_content(M) subset W`

But we need `x_content(M) subset W` (stronger than g_content). This is NOT guaranteed by canonical_forward_F.

**Resolution**: We need a strengthened version of canonical_forward_F:

**Claim**: If `F(psi) in M` and `M` is MCS, then there exists MCS `W` with `psi in W` AND `x_content(M) subset W`.

**Proof sketch**: The seed for Lindenbaum extension is `x_content(M) union {psi}`. We need to show this is consistent.

If `x_content(M) union {psi}` is inconsistent, then `x_content(M) |- neg(psi)`. By x_lift (from the X-K distribution axiom), `M |- X(neg(psi))`. So `X(neg(psi)) in M`. By next_implies_some_future: `F(neg(psi)) in M`. But `F(psi) in M` (hypothesis). Combined: `F(psi) AND F(neg(psi)) in M`.

Now `F(psi) = neg(G(neg(psi)))` and `F(neg(psi)) = neg(G(neg(neg(psi)))) = neg(G(psi))` (where neg(neg(psi)) reduces to psi via double negation in MCS). So `neg(G(neg(psi))) AND neg(G(psi)) in M`, i.e., both `G(psi)` and `G(neg(psi))` are NOT in M. By MCS: `F(neg(psi)) AND F(psi) in M`.

Actually, this doesn't immediately lead to a contradiction because F(psi) and F(neg(psi)) CAN coexist in a consistent MCS (psi can be true at some future time and neg(psi) at another).

So the simple seed `x_content(M) union {psi}` may be INCONSISTENT.

### 4.4 Alternative: Interleaved Chain

Instead of trying to extend x_content(M) with psi, use a TWO-STEP construction:

1. Step 2k: `chain(2k+1) = x_content(chain(2k))` (deterministic step)
2. Step 2k+1: `chain(2k+2)` = targeted successor of `chain(2k+1)` resolving psi_{k mod N}

This preserves x_content propagation at even steps and resolves F-obligations at odd steps.

**Problem**: Until persistence requires x_content propagation at EVERY step. The targeted successor at odd steps does NOT guarantee x_content(chain(2k+1)) subset chain(2k+2).

### 4.5 Revised Approach: Well-Founded Resolution via canonical_forward_F + x_content

The key insight is that we don't need EVERY step to be x_content-based. We need:
1. Until persistence: (phi U psi) persists until psi appears
2. F-resolution: F(psi) eventually gets resolved

For Until persistence, we need: if (phi U psi) in chain(n) and psi not in chain(n+1), then phi and (phi U psi) in chain(n+1).

In the deterministic chain, this follows from `until_unfold -> X(psi or (phi and (phi U psi))) in chain(n) -> the disjunction in x_content(chain(n)) = chain(n+1)`.

In a targeted chain using g_content-based successors, we have g_content(chain(n)) subset chain(n+1). Since `G(phi) -> X(phi)` is derivable, everything in g_content is in x_content. But `until_unfold` gives `X(psi or ...)` in chain(n), which means the disjunction is in x_content but NOT necessarily in g_content.

**Therefore**: g_content-based successors DO NOT preserve Until. This is precisely why the dovetailed chain fails.

### 4.6 Final Assessment

The fundamental tension is:
- **Until persistence needs x_content propagation** (chain(n+1) contains x_content(chain(n)))
- **F-resolution needs targeted Lindenbaum extensions** (chain(n+1) contains specific phi from canonical_forward_F)
- **Both together need** x_content(chain(n)) union {phi} to be CONSISTENT, which is not guaranteed

---

## 5. Recommended Path Forward

### 5.1 Approach: x_content-targeted hybrid with consistency proof

The most viable path is proving that `x_content(M) union {psi}` IS consistent when `F(psi) in M`:

**Theorem to prove**: For MCS M, if F(psi) in M, then `x_content(M) union {psi}` is set-consistent.

**Proof attempt**: Suppose `x_content(M) union {psi}` is inconsistent. Then there exist `a_1, ..., a_k in x_content(M)` with `a_1, ..., a_k, psi |- bot`. By deduction theorem: `a_1, ..., a_k |- neg(psi)`. By x_lift (applying X-K distribution): `X(a_1), ..., X(a_k) |- X(neg(psi))`. Since each X(a_i) in M: `X(neg(psi)) in M`, i.e., neg(psi) in x_content(M).

But psi in x_content(M) union {psi}, and neg(psi) in x_content(M), so x_content(M) itself contains neg(psi). Is this a contradiction?

Only if psi in x_content(M). But we don't know that. If psi NOT in x_content(M), then x_content(M) union {psi} can still be inconsistent: `x_content(M) |- neg(psi)` simply means `neg(psi) in x_content(M)` (since x_content(M) is MCS by x_content_mcs).

So the scenario is: `neg(psi) in x_content(M)` (i.e., `X(neg(psi)) in M`), and `F(psi) in M`.

Is `X(neg(psi)) AND F(psi)` in M consistent?
- `X(neg(psi))` means `neg(psi)` at time t+1
- `F(psi)` means `psi` at some time s > t
- These are compatible: psi could be true at s > t+1 while neg(psi) is true at t+1.

So **the consistency proof fails**. `x_content(M) union {psi}` CAN be inconsistent when `F(psi) in M`.

### 5.2 Revised Recommendation: Mark Phase 5 as BLOCKED

Given the analysis above, none of the three original options (A, B, C) nor the hybrid option D can close forward_F without addressing a deeper structural issue.

The fundamental problem is that the completeness proof for temporal logic with Until/Since requires a chain construction that simultaneously:
1. Preserves x_content propagation (for Until persistence)
2. Resolves F-obligations (for temporal coherence)

And these two requirements conflict because resolving F(psi) may require departing from the x_content successor.

### 5.3 Actually Viable Path: Prove forward_until DIRECTLY for the deterministic chain

Re-examining the dependency graph, there may be a way to prove `forward_until` WITHOUT going through forward_F:

**Direct proof of forward_until for deterministic chain**:

Given `(phi U psi) in chain(t)`, we need `exists s > t, psi in chain(s) AND forall r in (t,s), phi in chain(r)`.

The deterministic chain gives us (by until_persists_chain):
- Either psi appears at chain(t+1), or (phi U psi) in chain(t+1) with phi in chain(t+1)
- Iterating: either psi appears at some chain(t+k), or (phi U psi) and phi persist in chain(t+j) for all j < k

**Key question**: Can (phi U psi) persist forever in the deterministic chain?

If (phi U psi) in chain(n) for ALL n >= t, then by temporal_necessitation-like argument, G(phi U psi) should be derivable at t... but G is not necessitated from chain membership.

**Alternative**: Use the UNTIL INDUCTION axiom to derive a contradiction.

If (phi U psi) persists in chain(n) for all n >= t, then at each n, the until_unfold gives X(psi or (phi and (phi U psi))) in chain(n). Since psi never appears, we always take the second disjunct: phi and (phi U psi) in chain(n+1).

So we have: phi in chain(n) for all n > t, AND (phi U psi) in chain(n) for all n > t.

Now consider: is `(phi U psi) AND G(phi) AND neg(F(psi))` consistent?
- `(phi U psi)` says: psi eventually holds (strictly after current time), with phi at intermediates
- `G(phi)` says: phi at all future times
- `neg(F(psi))` = `G(neg(psi))` says: neg(psi) at all future times

Can an MCS contain all three? `(phi U psi)` and `G(neg(psi))`: until says psi eventually, G(neg(psi)) says psi never. These ARE contradictory!

Specifically: `(phi U psi) -> F(psi)` is derivable (via `until_implies_some_future`). And `F(psi)` and `G(neg(psi))` are contradictory (F(psi) = neg(G(neg(psi))), so F(psi) and G(neg(psi)) yield neg(G(neg(psi))) and G(neg(psi)), contradicting MCS consistency).

So if (phi U psi) in chain(n) for all n >= t, then F(psi) in chain(n) for all n >= t, hence neg(G(neg(psi))) in chain(n) for all n >= t. BUT ALSO neg(psi) in chain(n) for all n >= t (since psi never appears and each chain(n) is MCS). So G(neg(psi)) should be in chain(t)... BUT THIS IS WHAT WE CANNOT PROVE (it's backward_G, which needs forward_F).

The cycle reasserts itself.

**HOWEVER**: We don't need G(neg(psi)) in chain(t). We only need a CONTRADICTION. And we have:
- `F(psi) in chain(t)` (from (phi U psi) -> F(psi))
- `neg(psi) in chain(n)` for all n > t (since psi never appears)

If we could show `neg(psi) in chain(t)` as well... then `neg(F(psi)) = G(neg(psi))` would follow from... no, that's still backward_G.

### 5.4 The Breakthrough Approach: Omega-Rule / Compactness Argument

Wait. Here is a potentially viable approach that avoids the contrapositive backward_G entirely:

**Claim**: For the deterministic chain, `forward_until` can be proved by well-founded descent on the natural numbers.

**Proof**: Given `(phi U psi) in chain(t)`, we want `psi in chain(s)` for some s > t.

By `until_unfold` + `x_content` propagation (which IS available in the deterministic chain):
- If psi in chain(t+1), done.
- Otherwise, phi and (phi U psi) in chain(t+1).

Assume for contradiction: psi not in chain(n) for any n > t. Then by induction:
- (phi U psi) in chain(n) for all n >= t
- phi in chain(n) for all n > t

From (phi U psi) in chain(n) for all n >= t:
- In particular (phi U psi) in chain(t)
- `until_implies_some_future`: F(psi) in chain(t)
- So `(top U psi) in chain(t)` by F_until_equiv

Also, (top U psi) propagates via until_persists_chain (since psi never appears and top is always in every MCS).

Now use `until_induction` axiom with CLEVER choice of chi.

Set chi = `neg(phi U psi)`:
```
G(psi -> neg(phi U psi)) AND G(phi AND X(neg(phi U psi)) -> neg(phi U psi)) -> ((phi U psi) -> X(neg(phi U psi)))
```

First conjunct: `G(psi -> neg(phi U psi))`. Is this in chain(t)? This says: at all future times, psi implies neg(phi U psi). Under our assumption, psi NEVER holds at future times. So `psi -> neg(phi U psi)` is vacuously true at each future time (antecedent is false). In an MCS where neg(psi) holds, `psi -> neg(phi U psi)` follows from neg(psi) by ex falso. Since neg(psi) in chain(n) for all n > t (by assumption), `(psi -> neg(phi U psi)) in chain(n)` for all n > t.

But we need `G(psi -> neg(phi U psi)) in chain(t)`. And that's backward_G again.

Hmm. Every attempt to use G quantification runs into the backward_G circularity.

### 5.5 FINAL Recommendation

After exhaustive analysis, the most viable approach is:

**Use the targeted chain infrastructure to build a chain with BOTH g_content propagation AND F-resolution, then prove forward_G directly (non-contrapositively) using the G-step derivation `G(phi) -> X(G(phi))`.**

Specifically:

1. The targeted chain has `targeted_fam_G_step` (line 350): G(phi) at n implies phi at n+1 via g_content.

2. The targeted chain has `targeted_fam_H_step` (line 379): H(phi) at n implies phi at n-1 via h_content.

3. G-persistence across the full Int chain can be proved by induction:
   - G(phi) in chain(t) -> G(phi) in chain(t+1) via `G(G(phi)) -> X(G(phi))` (temp_4 + G_implies_X)
   - BUT this only works within the Nat arm. Cross-boundary requires `Y(G(phi)) -> G(phi)`.

4. **Cross-boundary derivation**: `Y(G(phi)) -> G(phi)` IS semantically valid under strict semantics. The syntactic derivation uses:
   - `Y(G(phi))` at t means `G(phi)` at t-1
   - `G(phi)` at t-1 means phi at all s > t-1
   - Under strict discrete semantics: all s > t-1 includes all s > t
   - So G(phi) at t follows

   The DERIVATION: Use `until_connectedness` or `temp_a`/`temp_a_dual` to connect Y and G. Alternatively, derive `Y(G(phi)) -> phi AND G(phi)` using:
   - `Y(G(phi)) -> P(G(phi))` (Y implies P: `X(a) -> F(a)` dual gives `Y(a) -> P(a)`)
   - `G(phi) -> temp_a(phi) -> G(P(phi))`
   - This seems circular.

   Actually: `Y(alpha) = bot S alpha`. `P(alpha) = neg(H(neg(alpha)))`. The derivation `Y(alpha) -> P(alpha)` IS available as `next_implies_some_future` dual (which would be `prev_implies_some_past`).

5. Even without the cross-boundary G/H, we can use SINGLE-ARM chains:
   - For completeness, we need: phi not provable -> exists countermodel
   - The countermodel evaluation is at time 0 (in M_0)
   - For the truth lemma at time 0, we need G/H propagation FROM 0 to positive/negative times
   - Forward from 0: sorry-free (G_persists_forward in Nat arm)
   - Backward from 0: sorry-free (H_persists_backward in negSucc arm)
   - The cross-boundary issue only arises for G at NEGATIVE times or H at POSITIVE times

For completeness evaluation at time 0, the truth lemma cases are:
- G(psi) in chain(0) -> truth: needs phi at all s > 0, which is forward (Nat arm) -- OK
- truth(G(psi), 0) -> G(psi) in chain(0): this is backward_G, needs forward_F -- BLOCKED
- H(psi) in chain(0) -> truth: needs phi at all s < 0, which is backward (negSucc arm) -- OK
- truth(H(psi), 0) -> H(psi) in chain(0): this is backward_H, needs backward_P -- BLOCKED

So even for evaluation at time 0, backward_G/backward_H (and hence forward_F/backward_P) are needed.

---

## 6. Summary and Final Recommendation

### 6.1 Status

The forward_F circularity is a **fundamental structural problem** in the completeness proof architecture. Every known approach hits the same cycle:

```
backward_G/backward_H -> forward_F/backward_P -> backward_G/backward_H
```

None of the three proposed options (A, B, C) nor any hybrid can break this cycle with the current infrastructure.

### 6.2 Root Cause

The root cause is that the backward direction of the truth lemma for G/H (semantic truth -> MCS membership) uses a CONTRAPOSITIVE argument that requires finding temporal witnesses (forward_F/backward_P). These witnesses cannot be guaranteed by any chain construction that also preserves Until/Since persistence.

### 6.3 Recommended Next Steps

**Short term (mark task status)**:
- Mark Phase 5 forward_F resolution as BLOCKED
- Document this analysis as the reason

**Medium term (2-3 weeks, estimated 15-25h)**:

The most promising resolution is **Option D-revised: Prove `x_content(M) union S` consistency for targeted seeds**.

Specifically, prove: For MCS M with F(psi) in M, if `S subset x_content(M)` is the set of formulas from x_content that we need to preserve, and S is compatible with psi (formally: `S union {psi}` is consistent), then there exists MCS W containing `S union {psi}`.

This requires:
1. Prove `Y(G(phi)) -> G(phi)` as a syntactic derivation (for cross-boundary G propagation)
2. Build a hybrid chain that uses x_content at each step but additionally resolves F-obligations via targeted Lindenbaum extensions
3. Prove the consistency of the hybrid seeds
4. Wire through parametric_canonical_truth_lemma

The most promising sub-approach for (2)-(3): instead of extending x_content(M) with psi, use a TWO-PHASE approach:
- Phase A: chain(n+1) = x_content(chain(n)) [deterministic, preserves Until]
- Phase B: if F(psi) was in chain(n) but psi not in chain(n+1), SWAP chain(n+1) with a Lindenbaum extension of x_content(chain(n)) that includes psi

For Phase B, the seed `x_content(chain(n)) union {psi}` may be inconsistent. But we showed that inconsistency means `neg(psi) in x_content(chain(n))`, i.e., `X(neg(psi)) in chain(n)`. So the F-obligation `F(psi)` coexists with `X(neg(psi))` -- psi fails at the next step but might succeed later.

This suggests: instead of resolving at n+1, wait. The F-obligation `F(psi)` propagates because `(top U psi)` persists via until_persists_chain. At some step m, `x_content(chain(m)) union {psi}` may become consistent (when neg(psi) is no longer forced). At that point, do the targeted swap.

**The key question becomes**: Does `x_content(chain(m)) union {psi}` eventually become consistent? This requires showing that the deterministic chain cannot force neg(psi) into x_content(chain(m)) forever. This is a NON-TRIVIAL finite-model-theory question specific to the formula closure.

**Alternative long-term approach**: Restructure the completeness proof to avoid backward_G entirely, using an algebraic/lattice-theoretic approach instead of the model-theoretic contrapositive. This would be a significant research effort (40-60h).

### 6.4 Effort Estimates

| Approach | Effort | Likelihood of Success |
|----------|--------|-----------------------|
| Option A (mutual induction) | 8-12h | LOW (fundamentally blocked) |
| Option B (restricted chain) | 15-20h | LOW (multiple independent blockers) |
| Option C (parametric path) | 8-12h | LOW (same forward_F blocker) |
| Option D (hybrid chain) | 15-25h | MEDIUM (consistency proof needed) |
| Algebraic restructure | 40-60h | HIGH (but major effort) |

### 6.5 Immediate Recommendation

1. **Mark Phase 5 forward_F as BLOCKED** with this analysis
2. **Investigate the `Y(G(phi)) -> G(phi)` derivation** as a standalone sub-task (2-4h). This is needed for ANY resolution approach and is the smallest actionable piece.
3. **Investigate the seed consistency question** for the hybrid chain (4-8h): Can `x_content(M) union {psi}` be shown consistent under additional hypotheses derivable from the chain structure?
4. If (2) and (3) succeed, proceed with the full hybrid chain construction.
