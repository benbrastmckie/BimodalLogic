# Phase 6 Handoff: Lemma 2.7 Burgess Direct Seed

**Session**: sess_1777504537_1d1fdf
**Date**: 2026-04-29
**Phase**: 6 [PARTIAL]
**Branch**: irr_until
**File**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`

## What Was Done

### 1. Deleted old Case 1/Case 2 code

The previous approach (case split on `{eta} union B` consistency, BX7 on `U(alpha, eta)` and `U(eta.neg, top)`) was deleted as specified in plan v33. The old code had 2 sorry sites (case-pos and case-neg D1/D3 completion).

### 2. Added sorry-free helper lemmas

Two new helper lemmas were added and compile sorry-free:

**`right_mono_until_mcs`** (line ~955): BX3 at MCS level. If `derivation [] (psi.imp chi)` and `U(phi, psi) in A`, then `U(phi, chi) in A`. Uses `Axiom.right_mono_until psi chi phi` (note parameter order: from-event, to-event, guard).

**`untl_conj_eta_of_g_content`** (line ~970): For all beta with `G(beta) in A`, `U(xi, beta AND eta) in A` from `U(xi, eta) in A`. Proof chain: G(beta) -> G(eta -> eta AND beta) via conj_intro_curried + TG + K_dist, then BX3 gives U(xi, eta AND beta), then swap to U(xi, beta AND eta).

### 3. Updated docstring to reflect Burgess direct seed strategy

The module docstring was updated to describe Burgess's actual proof structure (Steps 1-9 in the comment block).

## Current State

- **PointInsertion.lean**: 1 sorry (lemma_2_7 body)
- **Build**: passes with warnings only
- **Helper lemmas**: sorry-free, compile clean

## Fundamental Blockers Identified

### Blocker 1: Seed consistency with h_content(C)

To construct D with both `xi in D` AND `g_content(D) subset C`, the seed must include `h_content(C)`. The seed is `{event} union g_content(A) union h_content(C)`.

Since `g_content(A) subset B` and `h_content(C) subset B` (Phase 5b), the seed is a subset of `{event} union B`. For consistency, need `event.neg not-in B`.

**Problem**: B is `BurgessR3Maximal` (NOT negation-complete). We cannot prove `event.neg not-in B` in general. The `dcs_neg_union_consistent` requires `event not-in B`, which gives `{event.neg} union B` consistent, NOT `{event} union B` consistent.

**Potential solutions**:
1. Show `event in B` (then `event.neg not-in B` by consistency). Requires `G(event) in A`, which requires `G(xi AND U(xi,eta)) in A` -- not derivable from `U(xi,eta) in A`.
2. Show the full Burgess seed consistency directly (comprehension over A x B) without going through `{event} union B`. This requires a sophisticated consistency argument using BX5+BX7+BX13 to show any finite subset is consistent.
3. Use `lemma_2_4` for the forward direction (gives `BurgessR3Maximal(A, B', D)` with `g_content(A) subset D`) and prove `g_content(D) subset C` by a SEPARATE argument not requiring `h_content(C) subset D`.

### Blocker 2: Getting xi in D

Under open guard semantics, `U(xi, eta)` does NOT imply `F(xi)` (the guard holds on the open interval but not at the event point, and the interval can be empty in non-dense orders). So we cannot directly construct a seed containing xi using `forward_temporal_witness_seed_consistent`.

**Potential solutions**:
1. **BX7 in case-neg** (eta.neg in B): Apply BX7 to `U(alpha, eta)` and `U(eta.neg, gamma)` to get D3 = `U(guard, alpha AND gamma)`. BX10 on D3 gives `F(alpha AND gamma)`, so `{alpha AND gamma} union g_content(A)` is consistent. Since alpha = xi AND U(xi,eta), we get xi in D. This was partially implemented in the old code and DOES work for this sub-problem.
2. **BX7 in case-pos** ({eta} union B consistent): Need to extract a splitting witness from `BurgessR3Maximal_extension_fails`. The negation of burgessR3 gives a formula phi in DC({eta} union B) and gamma in C with `U(phi, gamma) not-in A`. Then BX14 (separation) on `U(xi, eta)` and `not-U(phi, eta)` gives `U(xi, xi AND not-phi)`. BX10 gives `F(xi AND not-phi)` and xi in D.

### Blocker 3: eta in B'

After constructing D with xi in D and `BurgessR3Maximal(A, B', D)`, need eta in B'.

**Problem**: `burgessR3Maximal_exists_from_seed` requires `eta in A` (left endpoint) to seed B' with eta. But eta might not be in A. And `dc_delta_B_burgessR3` requires `G(eta) in A` to strengthen the guard, but `G(eta) not-in A` (since `eta not-in g_content(A)`, as `eta not-in B` and `g_content(A) subset B`).

**Potential solutions**:
1. **Construct D such that burgessR(A, eta, D) holds by construction**. If the seed for D is enriched with Since-formulas `S(xi, alpha)` for each alpha in A (via BX13), then D contains `S(xi, alpha)` for each alpha, and combined with xi in D, this may give burgessR(A, eta, D). Specifically: from BX13, `U(xi,eta) AND alpha -> U(xi, eta AND S(xi, alpha))` for each alpha in A. If `eta AND S(xi, alpha)` is the event, then at D: `S(xi, alpha) in D`, and from `xi in D` + `S(xi, alpha) in D` perhaps derive `burgessR` properties.
2. **Direct maximality argument**: Show that if eta not-in B', then `{eta} union B'` consistent, and `dc_delta_B_burgessR3` gives burgessR3(A, DC({eta} union B'), D). For this, need `U(beta' AND eta, delta) in A` for all beta' in B', delta in D. This reduces to showing the guard strengthening `U(beta', delta) -> U(beta' AND eta, delta)` which needs `G(eta) in A`. Blocked.
3. **Burgess's approach**: Construct D from a seed that includes formulas ensuring burgessR(A, eta, D) directly. The seed `{S(alpha, beta AND eta) : alpha in A, beta in B}` union other terms. The consistency of this seed is exactly what Burgess proves via BX5+BX7+BX13.

## Recommended Next Steps

### Option A: Implement Burgess's full seed construction
The full Burgess seed `D_0 = {S(alpha, beta AND eta) : alpha in A, beta in B} union B union {xi} union {U(gamma, beta) : gamma in C, beta in B}` with the consistency proof via BX5+BX7+BX13 chain. This is complex but mathematically sound.

**Key steps**:
1. Define D_0 as a set comprehension
2. Prove consistency: for any finite L subset D_0, take representatives alpha_i, beta_i, gamma_i and show the conjunction `S(alpha_i, beta_i AND eta) AND beta_j AND xi AND U(gamma_k, beta_l)` is consistent using BX5+BX7+BX13
3. Use Lindenbaum to get D
4. Show xi in D, g_content(A) subset D (from B subset D and g_content(A) subset B), h_content(C) subset D (from U(gamma, beta) terms)
5. Show eta in B' from S-formulas in D

**Estimated effort**: 8-12 hours (complex seed consistency proof)

### Option B: Weaken the theorem to skip eta in B'
If downstream usage (C5 case in CounterexampleElimination) can be reformulated to not need `eta in B'`, this dramatically simplifies the proof. The splitting `xi in D` with `BurgessR3Maximal` pairs is achievable via the BX7 case-neg approach.

**Estimated effort**: 2-3 hours (xi in D only) + investigation of downstream impact

### Option C: Use Xu's Lemma 2.4 instead
Xu 1988 provides a simpler splitting that may bypass the eta-in-B' issue entirely. Research report 47 mentions this alternative. Needs investigation of whether Xu's approach gives the same output type.

**Estimated effort**: 4-6 hours (research + implementation)

## Key Infrastructure

| Lemma | Location | Status | Purpose |
|-------|----------|--------|---------|
| `right_mono_until_mcs` | PointInsertion.lean:~955 | sorry-free | BX3 at MCS level |
| `untl_conj_eta_of_g_content` | PointInsertion.lean:~970 | sorry-free | U(xi, beta AND eta) from G(beta) |
| `self_accum_until_mcs` | PointInsertion.lean:189 | sorry-free | BX5 at MCS level |
| `lemma_2_6_splitting` | PointInsertion.lean:913 | sorry-free | Full splitting with g_content |
| `splitting_seed_consistent` | PointInsertion.lean:894 | sorry-free | Seed consistency for Lemma 2.6 |
| `burgessR3Maximal_from_g_content_sub` | RRelation.lean:1512 | sorry-free | BurgessR3Maximal from g_content |
| `burgessR3Maximal_exists_from_seed` | RRelation.lean:1171 | sorry-free | BurgessR3Maximal from single seed |
| `BurgessR3Maximal_extension_fails` | PointInsertion.lean:566 | sorry-free | Maximality contradiction |
| `dc_delta_B_burgessR3` | PointInsertion.lean:583 | sorry-free | DCS extension preserves burgessR3 |
| `Axiom.right_mono_until` | Axioms.lean:151 | N/A | BX3: G(phi->psi) -> U(chi,phi) -> U(chi,psi) |
| `Axiom.enrichment_until` | Axioms.lean:175 | N/A | BX13: p AND U(phi,psi) -> U(phi, psi AND S(phi,p)) |
| `Axiom.separation_until` | Axioms.lean:193 | N/A | BX14: U(q,p) AND NOT U(r,p) -> U(q, q AND NOT r) |

## Compile Status

PointInsertion.lean compiles with 1 sorry (lemma_2_7 body). All helper lemmas sorry-free. `lake build` succeeds.
