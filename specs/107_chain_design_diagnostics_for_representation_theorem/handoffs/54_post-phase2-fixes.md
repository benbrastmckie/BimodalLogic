# Handoff: Task 107 Post-Phase 2 Fixes

**Date**: 2026-05-02  
**Session ID**: sess_107_implement  
**Status**: PARTIAL - Build errors mostly fixed, 2 sorry sites remain in inconsistent case  
**Delegation**: From orchestrator to lean-implementation-agent

---

## Summary of Progress

### Build Errors Fixed (7 of ~8 pre-existing errors)

1. **Lines 1387, 1412**: Removed `dsimp made no progress` by eliminating unnecessary `dsimp` tactics
2. **Line 1450**: Removed problematic `show` tactic with non-definitionally-equal pattern
3. **Line 1656**: Fixed `simp made no progress` by using `by exact List.mem_singleton.mpr rfl` instead of `by simp`
4. **Lines 1686, 1867**: Converted `rcases` with union membership to nested `by_cases` to avoid `Or.casesOn` Prop/Type elimination issues
5. **Lines 1416-1424**: Fixed `d0_a_event_list_mem` proof structure for filterMap membership

### Remaining Issues

**2 sorry sites added** in `burgess_D0_finite_subset_consistent_incons` (lines 1878-1879):
```lean
have h_ev_b : DerivationTree [] (event.imp b) := sorry
have h_ev_untl : DerivationTree [] (event.imp (Formula.untl b γ_hat)) := sorry
```

These need proper derivation from the iterated enrichment structure. The inconsistent case proof is simpler than the consistent case (no BX14 separation), but the derivation of `event → b` and `event → untl(b, γ_hat)` from `event → γ_hat` requires additional BX chain reasoning.

**Type mismatch errors** at lines 1697, 1889, 1900 - These are related to the Exists.casesOn elimination in the `by_cases` branches for Until and Since formulas. The classical witness extraction needs refinement.

### Current Sorry Count

- **PointInsertion.lean**: 3 sorries
  - Lines 1878-1879: Inconsistent case derivations (2 sorries)
  - Line 2405: `lemma_2_7_seed_consistent` (Phase 3 - not started)
  
- **Other files**: No changes (CounterexampleElimination.lean and ChronicleToCountermodel.lean still have their original sorry sites)

### Build Status

`lake build` shows the main errors are now:
1. Exists.casesOn elimination in Type context (lines 1709, 1909, 1934)
2. Application type mismatches (lines 1697, 1889, 1900)
3. The 3 intentional sorry sites

The structural fixes for the Prop/Type elimination are in place, but the specific tactic implementations need refinement.

---

## Recommended Next Steps

### Option 1: Complete the Inconsistent Case (2-3 hours)

The inconsistent case in `burgess_D0_finite_subset_consistent_incons` needs:
1. Derive `h_ev_b : event → b` from the enrichment structure
2. Derive `h_ev_untl : event → untl(b, γ_hat)` 

**Approach**: Use the fact that the event is enriched with guard `q = b ∧ untl(b, γ_hat)`. The enriched event should imply both components through the BX5+BX13 construction, even without BX14 separation.

### Option 2: Fix Remaining Exists.casesOn Errors (1-2 hours)

The remaining errors are in the `by_cases` branches for Until and Since formulas. The pattern:
```lean
by_cases h_untl : ∃ β' ∈ B, ∃ γ ∈ C, φ = Formula.untl β' γ
· -- Use classical witness extraction
  let β' := Classical.choose h_untl
```

needs to be refined to avoid the elimination issue.

### Option 3: Proceed to Phase 3 (5+ hours)

With the inconsistent case sorried, Phase 3 (`lemma_2_7_seed_consistent`) can proceed. This requires:
1. BX7 (linear_until) application for the 5th seed component
2. Burgess p.372 three-way disjunction handling
3. BX5+BX14+BX13+BX10 chain for the modified seed

---

## Key Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
  - Fixed ~8 pre-existing build errors
  - Restructured union membership case analysis to use `by_cases` instead of `rcases`
  - Added 2 sorry sites in inconsistent case (documented above)

---

## Verification

After fixes:
```bash
# Check sorry count
grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean
# Expected: 3 sorries (lines 1878-1879, 2405)

# Build status
lake build
# Expected: Exists.casesOn errors in by_cases branches, plus 3 sorry warnings
```

---

## References

- Implementation Plan: `specs/107_chain_design_diagnostics_for_representation_theorem/plans/52_implementation-plan.md`
- Previous Handoff: `specs/107_chain_design_diagnostics_for_representation_theorem/handoffs/53_phase1-2-progress.md`
- Burgess 1982: `/home/benjamin/Projects/ProofChecker/literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`
