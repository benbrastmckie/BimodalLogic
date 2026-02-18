# Handoff: Task 900 Phase 3

**Session**: 2026-02-18, sess_1771436504_b7f48c
**Agent**: lean-implementation-agent
**Status**: Partial - Phases 1-2 complete, Phase 3-4 in progress

## Immediate Next Action

Complete the `processWorkItem_preserves_consistent` modal/temporal cases (boxPositive, boxNegative, futurePositive, futureNegative, pastPositive, pastNegative) starting at line 7103 in RecursiveSeed.lean.

## Current State

**File**: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`

**Completed in this session**:
1. Strengthened `WorklistInvariant` (line ~6892) to include:
   - `SeedConsistent state.seed` (as before)
   - `SeedWellFormed state.seed` (NEW)
   - For all items: `FormulaConsistent item.formula ∧ item.formula ∈ state.seed.getFormulas item.famIdx item.timeIdx` (STRENGTHENED)

2. Updated `processWorkItem_preserves_consistent` signature (line ~7041) to take:
   - `h_cons : SeedConsistent state.seed`
   - `h_wf : SeedWellFormed state.seed` (NEW)
   - `h_item_cons : FormulaConsistent item.formula`
   - `h_in_seed : item.formula ∈ state.seed.getFormulas item.famIdx item.timeIdx` (NEW)

3. Completed simple cases for `processWorkItem_preserves_consistent`:
   - `atomic`: Uses `getFormulas_eq_of_wellformed_and_at_position` + `Set.insert_eq_of_mem`
   - `bottom`: Same pattern
   - `implication`: Same pattern
   - `negation`: Same pattern

4. Updated `buildSeedComplete_consistent` to provide the strengthened invariant.

**Remaining sorries in scope (Phase 3-4)**:
- Lines 7103-7123: 6 modal/temporal cases in `processWorkItem_preserves_consistent`
- Lines 7154-7165: 6 modal/temporal cases in `processWorkItem_newWork_consistent`
- Lines 7205-7222: 3 invariant maintenance lemmas in `processWorklistAux_preserves_invariant`

## Key Decisions Made

1. **Invariant Strengthening**: The key insight is that `h_in_seed` (formula already in seed) makes h_compat trivial via `Set.insert_eq_of_mem`. This avoids needing to prove compatibility of arbitrary formulas.

2. **Pattern for Simple Cases**:
   ```lean
   have h_entry_cons : SetConsistent entry.formulas := h_cons entry h_entry
   have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position
     state.seed entry item.famIdx item.timeIdx h_wf h_entry h_fam h_time
   have h_formula_in_entry : item.formula ∈ entry.formulas := by
     rw [← h_getFormulas_eq]; exact h_in_seed
   rw [Set.insert_eq_of_mem h_formula_in_entry]
   exact h_entry_cons
   ```

## What NOT to Try

1. **Don't try to prove h_compat without h_in_seed**: The original approach of proving `SetConsistent (insert phi entry.formulas)` without knowing phi is already there requires proving formula compatibility, which is complex for arbitrary formulas.

2. **Don't weaken the invariant**: The strengthened invariant is necessary. It ensures that when we process a work item, we're always inserting a formula that's already present.

## Critical Context

1. **Key lemmas to use**:
   - `getFormulas_eq_of_wellformed_and_at_position`: Links getFormulas to entry.formulas when well-formed
   - `Set.insert_eq_of_mem`: When phi is already in S, insert phi S = S
   - `addFormula_formula_in_getFormulas`: After addFormula, the formula is in getFormulas
   - `createNewFamily_preserves_seedConsistent`, `createNewTime_preserves_seedConsistent`: For negative cases

2. **Modal/temporal case pattern** (boxPositive example):
   - `seed1 = addFormula Box psi` (Box psi already in seed by h_in_seed)
   - `seed2 = foldl addFormula psi over all families`
   - Need: SeedConsistent seed2
   - Approach: Use `foldl_addFormula_preserves_consistent` with appropriate h_compat

3. **Invariant maintenance in processWorklistAux**:
   - Need lemmas showing `processWorkItem` preserves well-formedness
   - Need lemmas showing formula membership is preserved/established

## References

- **Plan**: `specs/900_prove_cut_rule_derivation_tree_manipulation/plans/implementation-001.md`
- **Summary**: `specs/900_prove_cut_rule_derivation_tree_manipulation/summaries/implementation-summary-20260218.md`
- **Main file**: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
- **MCP tools guide**: `.claude/context/project/lean4/tools/mcp-tools-guide.md`
