# Teammate A Findings: Primary Mathematical Analysis

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-02
**Focus**: Rigorous analysis of remaining sorries and solution approaches

---

## Key Findings

1. **The 2 main sorries** (`succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P`) operate on the **full MCS chain** (`succ_chain_fam`), not the restricted chain (`restricted_succ_chain_fam`). This is a critical distinction.

2. **The restricted chain's strong F-resolution is built on an unsound foundation.** The `constrained_successor_seed_restricted` includes `f_content(u)`, which is provably inconsistent when both `F(A)` and `F(neg(A))` are in `u`. The theorem `constrained_successor_seed_restricted_consistent` is explicitly marked as FALSE (SuccChainFMCS.lean:2215).

3. **The 2 auxiliary sorries** (`restricted_chain_G_propagates` and `restricted_chain_H_step`) are **never used** anywhere in the codebase. They are declared but unreferenced. They are NOT blocking completeness.

4. **The completeness path** (`completeness_over_Int` -> `restricted_bundle_validity_implies_provability` -> `bfmcs_restricted_temporally_coherent`) uses `succ_chain_restricted_forward_F`/`backward_P` on the full MCS chain. This is where the real sorry lies.

5. **A simplified chain approach** (SimplifiedChain.lean) exists but is incomplete -- the `targeted_restricted_seed_consistent` theorem has a sorry at the G-lift argument when `target in L`.

---

## Sorry Analysis

### Sorry 1: `succ_chain_restricted_forward_F` (UltrafilterChain.lean:3762)

**Exact goal state:**
```lean
S : SerialMCS
root : Formula
n : Int
psi : Formula
h_dc : psi ∈ deferralClosure root
h_F : psi.some_future ∈ succ_chain_fam S n
⊢ ∃ m, n ≤ m ∧ psi ∈ succ_chain_fam S m
```

**What's needed:** Show that `F(psi) ∈ succ_chain_fam S n` implies `psi` eventually appears in the full MCS chain at some time `m >= n`.

**Why it's hard:** `succ_chain_fam` uses `constrained_successor_from_seed` which provides only the **weak f_step**: `f_content(chain(n)) ⊆ chain(n+1) ∪ f_content(chain(n+1))`. Each F-obligation is either resolved or deferred. In a full MCS, there is no bound on F-nesting depth, so perpetual deferral cannot be ruled out by a simple finiteness argument.

### Sorry 2: `succ_chain_restricted_backward_P` (UltrafilterChain.lean:3772)

**Exact goal state:**
```lean
S : SerialMCS
root : Formula
n : Int
psi : Formula
h_dc : psi ∈ deferralClosure root
h_P : psi.some_past ∈ succ_chain_fam S n
⊢ ∃ m ≤ n, psi ∈ succ_chain_fam S m
```

**Symmetric to Sorry 1** for the past direction. The backward chain uses `constrained_predecessor` with `h_content` and `pastDeferralDisjunctions`, giving only weak p_step.

### Sorry 3: `restricted_chain_G_propagates` (RestrictedTruthLemma.lean:116)

**Exact goal state:**
```lean
case inl
phi : Formula
fam : RestrictedTemporallyCoherentFamily phi
n m : Int
psi : Formula
h_nm : n ≤ m
h_G_in_chain : psi.all_future ∈ restricted_succ_chain_fam phi fam.seed n
h_lt : n < m
h_diff_pos : 0 < m - n
h_le : 0 ≤ m - n
k : Nat
hk : m - n = k
hk_pos : k > 0
j : Nat
hj : k = j.succ
h_m_eq : m = n + (j + 1)
⊢ psi ∈ restricted_succ_chain_fam phi fam.seed m
```

**Status: UNUSED.** This theorem is never referenced anywhere. The single-step `restricted_chain_G_step` IS proven (line 71-78). The multi-step propagation requires `G(psi) ∈ chain(n+1)` from `G(psi) ∈ chain(n)`, which needs `G(G(psi)) ∈ chain(n)` -- but `G(G(psi))` may not be in `deferralClosure`.

**Impact on completeness:** None. This theorem is dead code.

### Sorry 4: `restricted_chain_H_step` (RestrictedTruthLemma.lean:158)

**Exact goal state:**
```lean
phi : Formula
fam : RestrictedTemporallyCoherentFamily phi
n : Int
psi : Formula
h_H_in_chain : psi.all_past ∈ restricted_succ_chain_fam phi fam.seed n
h_psi_dc : psi ∈ deferralClosure phi
⊢ psi ∈ restricted_succ_chain_fam phi fam.seed (n - 1)
```

**Status: UNUSED.** Never referenced. Would need `Succ_implies_h_content_reverse` which requires full MCS, not DRM.

**Impact on completeness:** None. Dead code.

---

## Mathematical Structure

### deferralClosure Properties

`deferralClosure(phi)` is defined as (SubformulaClosure.lean:702):
```lean
closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi ∪ serialityFormulas
```

Key properties:
- **Finite**: It is a `Finset Formula` (union of finsets)
- **Contains phi and neg(phi)**: via `closureWithNeg`
- **Contains F_top and P_top**: via `serialityFormulas`
- **Contains deferral disjunctions**: `chi ∨ F(chi)` for each `F(chi)` in `closureWithNeg(phi)`
- **Bounds F-nesting depth**: `closure_F_bound phi = max(max_F_depth_in_closure phi, 1) + 1`

### Chain Construction Comparison

| Property | Full MCS Chain (`succ_chain_fam`) | Restricted Chain (`restricted_succ_chain_fam`) |
|----------|-----------------------------------|-----------------------------------------------|
| Element type | `SetMaximalConsistent` | `DeferralRestrictedMCS phi` |
| F-step | Weak: resolve-or-defer | **Should be strong** but seed consistency FALSE |
| Seed includes `f_content`? | No | Yes (but this makes seed inconsistent!) |
| forward_F proven? | No (sorry) | Depends on sorry chain to `constrained_successor_seed_restricted_consistent` |
| forward_G proven? | Yes (sorry-free) | Single-step yes, multi-step no (but not needed) |

### The Fundamental Problem

The architecture has a tension:
1. **Full MCS chain**: Sound construction (seed consistency trivial), but no F-resolution guarantee
2. **Restricted chain with f_content**: F-resolution in one step, but seed consistency is **false**
3. **Simplified chain without f_content**: Sound construction, but only weak f_step (perpetual deferral possible)

### Why Perpetual Deferral is the Real Obstacle

For the full MCS chain, at each step the Lindenbaum extension can freely choose to add `F(psi)` instead of `psi`. The deferral disjunction `psi ∨ F(psi)` is in the seed, but the extension is non-constructive and may always pick the `F(psi)` branch. There is no mechanism to force resolution.

For the DeferralRestrictedMCS chain, F-nesting is bounded by `closure_F_bound phi`. If `F(psi) ∈ chain(n)`, then `iter_F d psi ∈ chain(n)` for some bounded d, and `iter_F (d+1) psi ∉ chain(n)`. But this bounds nesting AT A SINGLE TIME POINT, not across time. The deferral can still propagate `F(psi)` forward indefinitely even within the bounded closure.

---

## Recommended Approach

### Approach 1: Targeted Chain Construction (Most Promising)

**Core idea:** Instead of trying to resolve ALL F-obligations simultaneously (which causes the seed inconsistency), resolve ONE F-obligation at a time using the targeted seed `{target} ∪ g_content(u)`.

The key ingredient already exists: `forward_temporal_witness_seed_consistent` (WitnessSeed.lean:79) proves that `{psi} ∪ g_content(M)` is consistent when `F(psi) ∈ M` and `M` is a full MCS.

**Strategy for `succ_chain_restricted_forward_F`:**
1. Given `F(psi) ∈ succ_chain_fam S n`, we need `∃ m >= n, psi ∈ succ_chain_fam S m`
2. Use `temporal_theory_witness_exists` (UltrafilterChain.lean:2212): there exists a full MCS `W` with `psi ∈ W` and `box_class_agree` with `chain(n)`
3. `W` can seed a `SuccChainFMCS` shifted to time `n+1`
4. This gives `psi ∈ shifted_fmcs(SuccChainFMCS W, n+1).mcs(n+1)` = `psi ∈ W`

**Problem:** This gives a witness in a DIFFERENT family, not the same family (`succ_chain_fam S`). The sorry requires `psi ∈ succ_chain_fam S m`, i.e., the same chain.

### Approach 2: Change the Architecture to Use Restricted Completeness Path

**Core idea:** The sorry theorems in UltrafilterChain.lean try to prove F/P-resolution for the *unrestricted* chain `succ_chain_fam`. This is fundamentally harder than necessary. Instead, restructure the completeness proof to avoid needing same-family F/P-resolution on unrestricted chains.

**Key observation:** The `restricted_shifted_truth_lemma` + `bfmcs_restricted_temporally_coherent` path (Completeness.lean:337-373) already routes through `succ_chain_restricted_forward_F`/`backward_P`, which are the sorry theorems. But these theorems are stated for the wrong chain type.

**The fix:** Replace the BFMCS families with families that have proven F/P-resolution. Two sub-approaches:

**2a. Dovetailed chain (partially implemented):** `DovetailedChain.lean` has `forward_dovetailed` (sorry-free) which resolves all F-obligations via fair scheduling. But `dovetailed_fmcs` and `construct_bfmcs_int` are declared but never implemented.

**2b. Direct restricted completeness (bypassing BFMCS):** Prove completeness directly from the restricted truth lemma without constructing a BFMCS at all. This is the approach sketched in Report 09's Strategy B / Report 10's "Correct Path".

### Approach 3: Fix the Seed Consistency (SimplifiedChain.lean path)

**Core idea:** The simplified chain uses `simplified_restricted_seed` (without `f_content`), which IS consistent. Then use `targeted_restricted_seed` to resolve one F-obligation at a time via the G-lift argument.

**Status:** The `targeted_restricted_seed_consistent` has a sorry (SimplifiedChain.lean:195) at the G-lift step when elements of L are not all in `g_content(u)` (some may be `deferralDisjunctions` or `p_step_blocking` elements which are not G-liftable).

**What's needed to close this sorry:** Adapt the G-lift argument from `forward_temporal_witness_seed_consistent` (WitnessSeed.lean:79) to handle the case where `L` contains non-G-liftable elements. The key insight is that these elements are in `u`, so `L ⊢ neg(target)` with `L ⊆ u` gives `u ⊢ neg(target)`, which combined with `F(target) = neg(G(neg(target))) ∈ u` does NOT give a contradiction (both `neg(target)` and `F(target)` can coexist in an MCS).

**This approach has a fundamental difficulty:** The G-lift technique works when ALL elements of the derivation are G-liftable (i.e., in `g_content(M)`). When the seed includes non-G-liftable elements, the technique breaks down.

### Recommended: Approach 2b (Direct Restricted Completeness)

**Justification:**
1. The restricted truth lemma is sorry-free
2. `build_restricted_tc_family` is sorry-free (it uses the proven `restricted_forward_chain_forward_F`)
3. Wait -- `restricted_forward_chain_forward_F` depends on `restricted_forward_chain_F_resolves` which depends on `constrained_successor_restricted_f_content_persistence` which depends on `constrained_successor_restricted` which depends on `constrained_successor_seed_restricted_consistent` -- which is **FALSE**.

**Revised assessment:** The restricted chain infrastructure is ALSO sorry-dependent on the false seed consistency theorem. The entire `build_restricted_tc_family` path is unsound.

**Actually recommended: Approach 2a (Dovetailed Chain)**

The dovetailed chain (`DovetailedChain.lean`) has `forward_dovetailed` which IS sorry-free and resolves all F-obligations. The missing piece is packaging this into the completeness infrastructure. Let me verify this.

---

## Evidence/Examples

### Key Sorry-Free Lemmas

| Lemma | File:Line | What it proves |
|-------|-----------|---------------|
| `forward_temporal_witness_seed_consistent` | WitnessSeed.lean:79 | `{psi} ∪ g_content(M)` consistent when `F(psi) ∈ M` (full MCS) |
| `temporal_theory_witness_exists` | UltrafilterChain.lean:2212 | Existence of witness MCS with `psi ∈ W` and `box_class_agree` |
| `restricted_truth_lemma` | RestrictedTruthLemma.lean:291 | DRM membership iff extended chain membership for subformulaClosure |
| `simplified_restricted_seed_consistent` | SimplifiedChain.lean:78 | Simplified seed (without f_content) is consistent |

### Key Sorry-Bearing Dependencies

| Theorem | File:Line | Status | Impact |
|---------|-----------|--------|--------|
| `constrained_successor_seed_restricted_consistent` | SuccChainFMCS.lean:2237 | **FALSE** | Blocks ALL restricted chain infrastructure |
| `targeted_restricted_seed_consistent` | SimplifiedChain.lean:195 | Sorry (G-lift gap) | Blocks targeted single-F resolution |
| `succ_chain_restricted_forward_F` | UltrafilterChain.lean:3762 | Sorry | Directly blocks completeness |
| `succ_chain_restricted_backward_P` | UltrafilterChain.lean:3772 | Sorry | Directly blocks completeness |

### The Dovetailed Chain (VERIFIED - Incomplete)

`DovetailedChain.lean` (605 lines, ZERO sorries) has a sorry-free `forward_dovetailed` chain with:
- `forward_dovetailed_forward_G`: G-persistence (sorry-free)
- `forward_dovetailed_backward_H`: H-backward coherence (sorry-free)
- `forward_dovetailed_box_agree`: box_class_agree preservation (sorry-free)

**CRITICAL: forward_F is NOT proven.** Lines 287-605 are design analysis/commentary, not proofs. The file identifies that:
1. F-formulas do NOT persist through Lindenbaum extensions (line 385)
2. The dovetailed scheduling approach cannot guarantee resolution before `G(neg(phi))` enters (line 587-589)
3. Including F-formulas in the seed fails because they are not G-liftable (line 395)

**`dovetailed_fmcs` and `construct_bfmcs_int` are mentioned in the header but never implemented.**

### Summary: The G-lift Gap is the Universal Bottleneck

Every approach hits the same wall: proving that a seed containing a targeted formula `psi` (where `F(psi) ∈ M`) is consistent when the seed also contains non-G-liftable elements. The G-lift technique from `forward_temporal_witness_seed_consistent` works for `{psi} ∪ g_content(M)` but fails when the seed includes deferral disjunctions or p_step_blocking elements.

The approaches explored so far:
1. **Full MCS chain** (`succ_chain_fam`): No mechanism to force F-resolution
2. **Restricted chain with f_content**: Seed is provably inconsistent
3. **Simplified chain with targeted seed**: G-lift gap for non-G-liftable seed elements
4. **Dovetailed chain**: F-formulas don't persist through Lindenbaum extensions
5. **Direct restricted completeness**: Needs a temporally coherent family, which needs F-resolution

### The One Remaining Path

The G-lift argument in `forward_temporal_witness_seed_consistent` (WitnessSeed.lean:79-104) proves `{psi} ∪ g_content(M)` is consistent when `F(psi) ∈ M`. This is sorry-free and fully verified.

To close the main sorries, one could:
1. Build a chain where each step uses ONLY `{target} ∪ g_content(M)` as seed (no deferral disjunctions, no p_step_blocking)
2. This gives a chain where `F(target) ∈ chain(n) → target ∈ chain(n+1)` for the targeted formula
3. Use fair scheduling across formulas in `deferralClosure(root)` (which is finite)
4. Prove that the resulting chain satisfies forward_G and backward_H (from g_content propagation)
5. Prove forward_F via the scheduling argument

The challenge: without deferral disjunctions in the seed, the resulting chain may not satisfy the Succ relation. But the Succ relation is only needed for the truth lemma's G/H cases, and the g_content propagation provides the equivalent property.

This amounts to building a custom chain construction that is specifically tailored for the completeness proof, using only the sorry-free `temporal_theory_witness_exists` at each step.

---

## Confidence Level

**High**

**Justification:**
- The goal state analysis is exact (obtained via `lean_goal`)
- The dependency analysis is thorough (traced through multiple files)
- The identification of `constrained_successor_seed_restricted_consistent` as FALSE is confirmed by the source code comments (SuccChainFMCS.lean:2215)
- The finding that `restricted_chain_G_propagates` and `restricted_chain_H_step` are dead code is confirmed by grep (zero references)
- The DovetailedChain.lean analysis is verified (zero sorries, but forward_F unproven with extensive design analysis)
- The G-lift bottleneck is identified as the universal blocker across all approaches
- The one remaining viable path (pure g_content seed + fair scheduling) is clearly identified with its trade-offs
