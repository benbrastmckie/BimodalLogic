# Handoff: Task 107 Phase 2 - Build Errors Reduced, 4 Remaining

**Date**: 2026-05-03  
**Session ID**: sess_1777762781_b2f826  
**Status**: PARTIAL - Major progress on build errors, Phase 2 structure complete

---

## Summary of Progress

### Build Errors Fixed
- Fixed ~15 structural/indentation errors in `burgess_D0_finite_subset_consistent`
- Fixed Prop/Type elimination issues by replacing `rcases` with classical choice
- Fixed type mismatch issues with `collect_guards` subtype destructuring

### Current Build Errors (4 remaining)

All in **inconsistent case** (`burgess_D0_finite_subset_consistent_incons`):

| Line | Error | Context |
|------|-------|---------|
| 1904 | Application type mismatch | `h_ev_imp` in modus_ponens call |
| 1911 | Application type mismatch | Helper lemma call |
| 1914 | Application type mismatch | Helper lemma call |
| 1930 | Application type mismatch | `Classical.choose` extraction |

**Pattern**: These are similar to the errors already fixed in the consistent case - the `rw [h_eq]` is changing the goal but helper lemmas still reference the old `hφ : φ ∈ L`.

### Current Sorry Count

- **PointInsertion.lean**: 4 sorries
  - Line 1411: `d0_a_event_list_mem` (helper lemma - temporarily sorried)
  - Line 1858: `h_ev_b` in inconsistent case (needs proper derivation)
  - Line 1859: `h_ev_untl` in inconsistent case (needs proper derivation)
  - Line 2397: `lemma_2_7_seed_consistent` (Phase 3 - not started)

### Phase 2 Status

**Consistent case** (`burgess_D0_finite_subset_consistent`):
- ✅ Structure complete with 4 cases (B, β.neg, untl, snce)
- ✅ Uses classical choice for witness extraction (avoids Or.casesOn)
- ✅ All 3 sorry sites closed (Sites 1-3)
- ⚠️ Build passes except for `d0_a_event_list_mem` helper

**Inconsistent case** (`burgess_D0_finite_subset_consistent_incons`):
- ⚠️ Structure in place but 4 type mismatch errors
- ⚠️ 2 sorries for `h_ev_b` and `h_ev_untl` derivations
- The inconsistent case is simpler (no BX14 separation) but needs proper derivation

---

## Key Insights for Next Agent

### The Consistent Case Pattern (Working)
```lean
-- After extracting β', γ' with classical choice:
have h_eq : φ = Formula.untl β' γ' := ...
have h_φ_eq : Formula.untl β' γ' ∈ L := by rw [←h_eq]; exact hφ
rw [h_eq]  -- IMPORTANT: Rewrite goal before helper calls
-- Now helper lemmas use h_φ_eq instead of hφ
have h_in_raw := collect_guards_mem_of_B h_B_dcs β L hL (Formula.untl β' γ') h_φ_eq h_untl_B
```

### The Inconsistent Case Derivation Issue
The inconsistent case has:
```lean
let evt := iterated_enrichment h_mcs_A q a_list ha_list γ_hat h_bx5
let event := evt.event'
have h_event_impl_γhat : DerivationTree [] (event.imp γ_hat) := evt.h_impl
```

But we need `event → b` and `event → untl(b, γ_hat)`. The `evt.h_impl` gives `event → γ_hat`, not `event → q` where `q = b ∧ untl(b, γ_hat)`.

**Possible approaches**:
1. Use a different enrichment that produces `event → q`
2. Derive `event → b` from `untl(q, event) ∈ A` using BX axioms
3. Restructure the proof to not need these specific derivations

### d0_a_event_list_mem Helper
This helper lemma needs to be completed. The issue is with nested if-then-else in filterMap.

---

## Recommended Next Steps

### Option 1: Fix Remaining Build Errors (1-2 hours)
Apply the same pattern used in the consistent case to fix the 4 remaining type mismatches in the inconsistent case.

### Option 2: Complete the Inconsistent Case Derivations (2-3 hours)
Figure out how to derive `h_ev_b` and `h_ev_untl` properly. This might require:
- Restructuring the enrichment approach
- Adding a new helper lemma
- Using a different BX axiom chain

### Option 3: Update Plan and Proceed to Phase 3 (5+ hours)
With Phase 2 structurally complete (even with 2 sorries in inconsistent case), proceed to Phase 3 (`lemma_2_7_seed_consistent`).

---

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
  - Consistent case proof structure (lines ~1680-1780)
  - Inconsistent case proof structure (lines ~1850-1950)
  - Helper lemma calls updated to use explicit type arguments

---

## Verification Commands

```bash
# Check sorry count
grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean

# Build status
lake build Bimodal.Metalogic.BXCanonical.Chronicle.PointInsertion

# Check specific errors
lake build 2>&1 | grep -E "1904|1911|1914|1930"
```

---

## References

- Implementation Plan: `specs/107_chain_design_diagnostics_for_representation_theorem/plans/52_implementation-plan.md`
- Previous Handoff: `specs/107_chain_design_diagnostics_for_representation_theorem/handoffs/55_phase2-complete.md`
- Burgess 1982: `/home/benjamin/Projects/ProofChecker/literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`

---

## Agent Instructions

**CRITICAL**: Update the plan file at `specs/107_chain_design_diagnostics_for_representation_theorem/plans/52_implementation-plan.md` to reflect:
1. Current Phase 2 status (consistent case complete, inconsistent case partial)
2. The 4 remaining build errors
3. The 4 sorries and their locations
4. Any changes to the approach or timeline

When Phase 2 is fully complete (build passing, only Phase 3 sorry remaining), mark Phase 2 as [COMPLETED] in the plan.
