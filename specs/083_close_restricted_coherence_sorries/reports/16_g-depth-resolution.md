# Research Report 16: G-Depth Resolution and Fundamental Approach Analysis

**Task**: 83 (Close Restricted Coherence Sorries)
**Session**: sess_1743724801_c4d5e6
**Date**: 2026-04-04
**Cycle**: Research cycle 2, round 16

## Executive Summary

This research cycle investigated five fundamentally different approaches to breaking the forward_F circularity. The primary candidate (G-depth step-indexed truth lemma) was analyzed in depth and found to **not address the actual circularity**, which is in the chain construction, not the truth lemma. However, the investigation uncovered two critical findings:

1. **The restricted chain seed (SuccChainFMCS) is built on a FALSE theorem** -- `constrained_successor_seed_restricted_consistent` at line 2484 is provably false because `f_content(u)` can contain contradictory formulas (documented at line 2170).

2. **The deterministic chain (DeterministicChain.lean) IS sorry-free** for Until/Since persistence, forward_G, backward_H, and all MCS properties. It is the most promising base for a completeness proof, needing only forward_F.

## Approach Analysis

### Approach 3: G-Depth Step-Indexed Truth Lemma (PRIMARY) -- DOES NOT HELP

**Claim**: Induct on `temporalDepth(phi)` so backward_G(psi) at depth k+1 only needs forward_F at depth k, breaking the circularity.

**Analysis**: The circularity is NOT in the truth lemma. The truth lemma (`parametric_canonical_truth_lemma` in ParametricTruthLemma.lean) already works correctly given `h_tc : B.temporally_coherent`. The circularity is in PROVING `h_tc` for the constructed chain. Specifically:

- `h_tc` requires `forward_F` as a property of the chain family
- `forward_F` in the dovetailed chain requires Until persistence (sorry at line 621 of DovetailedChain.lean)
- Until persistence fails because g_content-based Lindenbaum extensions don't preserve x_content formulas

G-depth induction on the truth lemma would restructure a proof that is already correct. It does not address the chain construction problem.

**Temporal depth arithmetic verification**:
- `temporalDepth(G(psi)) = 1 + temporalDepth(psi)` -- confirmed at Formula.lean:265
- `temporalDepth(neg(psi)) = temporalDepth(psi.imp bot) = max(temporalDepth(psi), 0) = temporalDepth(psi)` -- confirmed at Formula.lean:262
- The depth decrease IS valid: backward_G(psi) needs forward_F(neg(psi)) where `temporalDepth(neg(psi)) < temporalDepth(G(psi))`
- But this structural property is IRRELEVANT because forward_F is an external chain property, not part of the truth lemma induction

### Approach 1: Avoid backward_G (Non-Contrapositive Proof) -- FAILS

**Claim**: Directly prove G(psi) in chain(t) from psi in chain(s) for all s > t.

**Analysis**: In the deterministic chain, `psi ∈ chain(s)` for all s > t gives `X^k(psi) ∈ chain(t)` for all k >= 1. Deriving G(psi) from `{X^k(psi) | k >= 1}` requires an omega-rule, which is not available in the finite axiom system. The set `{X^k(psi) | k >= 1} ∪ {F(neg(psi))}` is syntactically consistent (models with non-standard elements witness this), so no finite derivation exists.

### Approach 2: Until Induction Axiom -- FAILS (as expected)

The Until induction axiom `G(b → c) → G(a ∧ X(c) → c) → (a U b → c)` eliminates Until into a consequence `c`, but choosing `c` to witness forward_F requires circular assumptions.

### Approach 4: Canonical Forward_F -- STRUCTURAL MISMATCH

`canonical_forward_F` (CanonicalFrame.lean:133, sorry-free) provides: given `F(psi) ∈ M`, there exists MCS W with `psi ∈ W` and `g_content(M) ⊆ W`. The witness W is an arbitrary MCS, not a specific chain position. The truth lemma requires the witness in the SAME family because truth evaluation is along a single history.

**Cannot be used directly** for family-level forward_F.

### Approach 5: Two-Sorted Completeness -- SPECULATIVE

Would require splitting the completeness into a temporal fragment and a modal fragment, then combining. The interaction between Box (quantifying over histories) and G (quantifying over times) makes this non-trivial. No existing infrastructure supports this.

## Critical Finding: Restricted Chain Seed is FALSE

In `SuccChainFMCS.lean`, the `constrained_successor_seed_restricted_consistent` theorem (line 2192) has a sorry (line 2484) and is **actually false**, as documented at line 2170:

```
**THEOREM IS FALSE** — the constrained_successor_seed_restricted can be inconsistent.

**Counterexample**: If both F(A) and F(¬A) are in u (which is consistent — it means
"A holds at some future time" and "¬A holds at some future time"), then both A and ¬A
are in f_content(u) ⊆ seed. The set {A, ¬A} derives ⊥, so the seed is inconsistent.
```

The seed definition at `SuccExistence.lean:356` includes `f_content(u)`, which extracts inner formulas from F-formulas in u. When both `F(A)` and `F(neg(A))` are in u (semantically consistent), `f_content` contains `{A, neg(A)}`, making the seed inconsistent.

**Impact**: All theorems downstream of `constrained_successor_seed_restricted_consistent` are unsound:
- `constrained_successor_restricted` (line 2502)
- `restricted_forward_chain_f_content_persistence` (line 3171)
- `restricted_forward_chain_F_resolves` (line 3185)
- `build_restricted_tc_family` (line 6270)

The entire SuccChainFMCS restricted chain approach needs its seed redesigned.

## Deterministic Chain: The Strongest Foundation

**DeterministicChain.lean** is fully sorry-free and provides:

| Property | Status | Line |
|----------|--------|------|
| `deterministic_chain_mcs` | Sorry-free | Each chain(n) is MCS |
| `until_persists_chain` | Sorry-free | 242 |
| `since_persists_chain` | Sorry-free | 279 |
| `forward_G_nat` | Sorry-free | 433 |
| `backward_H_negSucc` | Sorry-free | (symmetric) |

**Missing only**: `forward_F` and `backward_P`

**Key property for forward_F**: F(psi) = top U psi persists via `until_persists_chain`. So `F(psi) ∈ chain(n)` implies either `psi ∈ chain(n+1)` or `F(psi) ∈ chain(n+1)`.

**The open question**: Can we prove that psi MUST eventually appear in the deterministic chain?

## Recommended Path Forward

### Option A: Deterministic Chain + Bounded F-Nesting (RECOMMENDED)

The deterministic chain has unbounded MCS but the COMPLETENESS PROOF only needs forward_F for formulas in `deferralClosure(root)`. For a fixed root formula:

1. F-nesting depth is bounded within `deferralClosure(root)` by `max_F_depth_in_closure`
2. If `F(psi) ∈ chain(n)` with `psi ∈ deferralClosure(root)`, then `iter_F k psi` eventually exits the closure

**Key insight**: Define a "restricted forward_F" that only applies to formulas in deferralClosure. In the deterministic chain, F(psi) persists via Until persistence. By the bounded F-nesting depth, the F-obligation cannot be infinitely deferred -- it must resolve within bounded steps.

**Concrete steps**:
1. Define `restricted_forward_F_deterministic(root, M_0, n, psi)`: given `F(psi) ∈ chain(n)` and `psi ∈ deferralClosure(root)`, show `∃ s > n, psi ∈ chain(s)`
2. The proof: by induction on the max F-nesting depth minus the current F-nesting level
3. At each step, either psi appears (done) or F(psi) persists but at a lower position in the deferralClosure ordering
4. This is well-founded because deferralClosure is finite

**CRITICAL CHECK NEEDED**: Does `until_persists_chain` give us both `phi ∈ chain(n+1)` AND `(phi U psi) ∈ chain(n+1)` when `psi ∉ chain(n+1)`? YES -- confirmed at line 242-271. The Until persistence gives both the guard formula AND the Until formula.

**BLOCKER**: The deterministic chain has x_content(M) = {phi | X(phi) ∈ M}, which is a FULL MCS. There's no direct connection between deferralClosure membership and chain behavior. We need to prove that the bounded F-nesting property of deferralClosure transfers to the full MCS chain.

Specifically: `iter_F (B+1) psi ∉ chain(n)` where B = `max_F_depth_in_closure(root)`. But chain(n) is a full MCS, not restricted to deferralClosure. So `iter_F (B+1) psi` COULD be in chain(n) even though it's not in deferralClosure(root).

This means the bounded F-nesting argument only works if the chain elements are DeferralRestrictedMCS, not full MCS. The deterministic chain uses full MCS (x_content of full MCS is full MCS).

### Option B: Fix the Restricted Seed (SECONDARY)

Fix `constrained_successor_seed_restricted` by removing `f_content(u)` from the seed. Instead, use `g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas_restricted(u)`. This seed IS consistent (all elements are in u, which is consistent).

**Consequence**: Without f_content in the seed, the successor doesn't automatically contain `psi` when `F(psi) ∈ u`. Instead, it contains the deferral disjunction `psi ∨ F(psi)`. The F-obligation is DEFERRED, not resolved.

The existing deferral machinery in the restricted chain handles this:
- F(psi) in u → deferral disjunction `psi ∨ F(psi)` in seed → either psi or F(psi) in successor (by DRM maximality)
- If F(psi) deferred: repeat at the next step
- Bounded F-nesting ensures termination within bounded steps

**Steps**:
1. Remove `f_content u` from `constrained_successor_seed_restricted` at SuccExistence.lean:357
2. Fix `constrained_successor_seed_restricted_consistent` (now trivially true since all seed elements are in u)
3. Update `constrained_successor_restricted_f_content_persistence` -- this theorem BECOMES FALSE (f_content is no longer in the seed). Replace with a deferral-based F-step lemma.
4. Rebuild the fuel-bounded witness proofs (lines 5790, 5948, 6144)
5. Close the CanonicalConstruction.lean sorry sites for Until/Since truth lemma (lines 940, 943) using the restricted chain

**Risk**: This is a substantial refactoring of the SuccChainFMCS approach, touching ~500 lines.

### Option C: Hybrid Deterministic-Canonical Approach (EXPLORATORY)

Use the deterministic chain for Until/Since/G/H coherence, and supplement with a separate argument for forward_F:

1. Build the deterministic chain from M_0 (sorry-free)
2. For forward_F, don't prove it as a chain property
3. Instead, restructure the completeness proof to avoid needing forward_F

This would require either:
- A non-contrapositive proof of backward_G (ruled out by Approach 1)
- A different model construction (e.g., canonical frame with non-linear time)
- A filtration argument (finite model property)

## Sorry Census (Task 83 Scope)

### DovetailedChain.lean (6 sorries)
| Line | Theorem | Root Cause |
|------|---------|------------|
| 621 | `forward_dovetailed_until_persists` | x_content not in g_content |
| 989 | `backward_dovetailed_since_persists` | Mirror of 621 |
| 1085 | `until_backward_to_zero` | Needs x_content propagation |
| 1098 | `since_forward_to_zero` | Mirror of 1085 |
| 1258 | `DovetailedFMCS_forward_F` | Depends on 621 |
| 1266 | `DovetailedFMCS_backward_P` | Depends on 989 |

### CanonicalConstruction.lean (2 sorries)
| Line | Theorem | Root Cause |
|------|---------|------------|
| 940 | Until truth lemma | Needs x_content + forward_F |
| 943 | Since truth lemma | Mirror of 940 |

### SuccChainFMCS.lean (3 blocking sorries + 6 non-blocking)
| Line | Theorem | Root Cause | Blocking? |
|------|---------|------------|-----------|
| 2484 | `constrained_successor_seed_restricted_consistent` | **FALSE THEOREM** (f_content inconsistency) | YES |
| 5790 | Fuel exhaustion (backward bounded witness) | Fuel sufficiency | YES |
| 5948 | Fuel exhaustion (combined bounded witness) | Fuel sufficiency | YES |
| 6144 | Fuel exhaustion (combined P bounded witness) | Fuel sufficiency | YES |
| 1248 | Non-restricted T-axiom | Strict semantics (unfixable) | No |
| 2164 | Multi-BRS consistency | Non-restricted path | No |
| 3996, 4263, 4406 | T-axiom variants | Strict semantics | No |

### RestrictedTruthLemma.lean (2 sorries)
| Line | Theorem | Root Cause |
|------|---------|------------|
| 121 | Restricted Until coherence | Depends on restricted chain |
| 168 | Restricted Since coherence | Mirror |

### UltrafilterChain.lean (2 sorries)
| Line | Root Cause |
|------|------------|
| 3917 | Bundle-level coherence (non-critical path) |
| 3927 | Bundle-level coherence (non-critical path) |

## Recommendation

**Pursue Option B (Fix the Restricted Seed)** as the primary path. This is the most tractable because:

1. The root cause is identified (f_content in seed)
2. The fix is well-defined (remove f_content, use deferral disjunctions)
3. The bounded F-nesting machinery already exists
4. The restricted chain approach has the right structural properties

**Before implementing**: Verify that the deferral disjunction approach actually resolves F-obligations in bounded steps. The key question is whether DRM maximality applied to `psi ∨ F(psi)` always chooses the resolved case `psi` after enough steps.

**Do NOT pursue**: G-depth truth lemma, omega-rule, or Approach 1 (non-contrapositive backward_G). These are confirmed dead ends.
