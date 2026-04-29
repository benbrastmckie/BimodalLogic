# Phase 6 Handoff: Lemma 2.7 Until-Formula Splitting

**Session**: sess_1777497460_373b8c
**Date**: 2026-04-29
**Phase**: 6 [PARTIAL]
**Branch**: irr_until
**File**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (lines 937–1095)

## What Was Done

### 1. Extended `lemma_2_6_splitting` return type (SORRY-FREE)

Added `g_content A ⊆ D ∧ g_content D ⊆ C` to the return type. These were already proved internally (`h_gc_AD`, `h_gc_DC`) but not exposed. Now returned in the existential. This unblocks Phase 8 (density fix).

### 2. Lemma 2.7 proof structure: case split on `{eta} ∪ B` consistency

**Case 1 (inconsistent)**: `{eta} ∪ B` inconsistent → `eta.neg ∈ B` by `neg_mem_of_inconsistent_union`.

- BX5 enriches `U(xi, eta)` to `U(xi ∧ U(xi,eta), eta) ∈ A` via `self_accum_until_mcs`
- Picks `top = (⊥ → ⊥) ∈ C` as concrete formula
- Gets `U(eta.neg, top) ∈ A` from `burgessR(A, eta.neg, C)` using `h_r3m.2.1.1`
- BX7 (`linear_until`) on `U(alpha, eta)` and `U(eta.neg, top)` gives three-way disjunction D1∨D2∨D3
- **D2 eliminated sorry-free**: `U(guard, eta∧eta.neg) ∉ A` proved via:
  - BX10: `U(guard, eta∧eta.neg) → F(eta∧eta.neg)`
  - `¬(eta∧eta.neg)` is a propositional theorem → `G(¬(eta∧eta.neg)) ∈ A`
  - `F(eta∧eta.neg)` and `G(¬(eta∧eta.neg))` contradict MCS consistency
- **D1/D3 case split**: NOT YET FORMALIZED (sorry)
  - D1 = `U(guard, eta∧top)` → event contains `eta`, splitting gives `eta ∈ D`
  - D3 = `U(guard, alpha∧top)` → event contains `xi` (since `alpha = xi∧U(xi,eta)`), splitting gives `xi ∈ D`
  - Need to construct D via Lindenbaum extension of `{event} ∪ g_content(A) ∪ h_content(C)`
  - Then need `BurgessR3Maximal(A, B', D)` and `BurgessR3Maximal(D, B'', C)` via `burgessR3Maximal_from_g_content_sub`
  - Need `eta ∈ B'` via `burgessR3Maximal_exists_from_seed` — requires `burgessR(A, eta, D)`
  - **Key blocker**: showing `burgessR(A, eta, D)` for the constructed D using BX13

**Case 2 (consistent)**: `{eta} ∪ B` consistent → `BurgessR3Maximal_extension_fails` argument. Skeleton only (sorry).

## What Remains

### Priority 1: Close Case 1 (inconsistent, D1/D3 split)

1. Extract D1∨D3 from `h_disj_A` and `h_D2_not_A` using MCS disjunction properties
2. For D3 case (`U(guard, alpha∧top) ∈ A`):
   - BX10 gives `F(alpha∧top) ∈ A`, so `F(xi∧U(xi,eta)) ∈ A`
   - Construct seed `{xi, P(U(guard, alpha∧top))} ∪ g_content(A) ∪ h_content(C)`
   - Show seed consistency (needs argument that xi is compatible with g_content(A))
   - Lindenbaum gives D with `xi ∈ D`
   - `burgessR3Maximal_from_g_content_sub` gives both BurgessR3Maximal pairs
3. For D1 case (`U(guard, eta∧top) ∈ A`):
   - Similar: seed `{eta} ∪ g_content(A) ∪ h_content(C)`, but need `xi ∈ D` too
   - May need to combine: seed `{xi, eta} ∪ g_content(A) ∪ h_content(C)`?
   - Consistency harder to show
4. Show `eta ∈ B'` via BX13 (enrichment_until) connection

### Priority 2: Close Case 2 (consistent)

- Extend `{eta} ∪ B` to DCS via Lindenbaum
- Use `BurgessR3Maximal_extension_fails` to get a failure witness
- Use BX14 (separation) or alternative to construct splitting point
- Less clear path — may need more research

## Key Infrastructure

| Lemma | Location | Purpose |
|-------|----------|---------|
| `self_accum_until_mcs` | PointInsertion.lean | BX5: U(xi,eta) → U(xi∧U(xi,eta), eta) |
| `connect_future_mcs` | PointInsertion.lean | BX4: phi → G(P(phi)) |
| `conj_mcs` | MCSProperties (imported) | phi ∈ A ∧ psi ∈ A → (phi∧psi) ∈ A |
| `theorem_in_mcs` | MCSProperties | ⊢ phi → phi ∈ A |
| `until_F_mcs` | MCSProperties | BX10: U(phi,psi) → F(psi) |
| `neg_mem_of_inconsistent_union` | PointInsertion.lean | ¬consistent({phi}∪B) → phi.neg ∈ B |
| `set_consistent_not_both` | MCSProperties | phi ∈ A → phi.neg ∉ A |
| `burgessR3Maximal_from_g_content_sub` | PointInsertion.lean | g_content A ⊆ C → ∃ B, BurgessR3Maximal A B C |
| `lemma_2_6_splitting` | PointInsertion.lean | Full splitting with g_content guarantees |
| `BurgessR3Maximal_extension_fails` | PointInsertion.lean | Maximality contradiction |
| `Axiom.linear_until` | Axioms.lean | BX7: U(a,b)∧U(c,d) → D1∨D2∨D3 |

## Compile Status

PointInsertion.lean compiles with 3 sorry sites in Lemma 2.7 (Case 1 D1/D3, Case 2). All other code sorry-free. `lake build` succeeds.

## Relationship to Phases 8/9

The `lemma_2_6_splitting` extension (exposing `g_content A ⊆ D` and `g_content D ⊆ C`) directly enables the Phase 8/9 fix via `h_gc_adj` invariant. See handoffs 06 and 07.
