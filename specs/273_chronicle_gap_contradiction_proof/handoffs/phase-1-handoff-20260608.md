# Phase 1 Handoff: Semantic Bridge Infrastructure

## Status: BLOCKED

## What was accomplished

1. **Identified the pre-existing Separation build chain issue**: The Hierarchy/ subdirectory has a circular dependency between HierarchyInduction.lean and HierarchyCompletion.lean. This prevents `all_formulas_separable` from compiling, which is needed by the SemanticBridge.

2. **Fixed 2 of 3 build issues**:
   - Added missing `FormulaOps` import to HierarchyDefs.lean (fixed ~32 errors: `subst_formula`, `IntStructure.withAtom`)
   - Moved 4 definitions from HierarchyCompletion to HierarchyDefs (fixed 3 errors: `is_separable_with_U_type`, `is_separable_with_U_type_of_equiv`, `or_separable_with_U_type`, `and_separable_with_U_type`)
   - Created HierarchyCaseSep.lean with case1/2/combined theorems (imported by HierarchyInduction)

3. **Created SemanticBridge.lean** with:
   - `z_structure_to_int`: constructs IntStructure from ZStructure + atomMap
   - `is_box_free`: predicate for box-free formulas
   - `int_truth_eq_temporal_truth_Z`: core bridge theorem (int_truth matches temporal_truth on Z-carrier structures)
   - `int_equiv_implies_temporal_equiv_Z`: transfer theorem
   - `temporal_truth_order_iso`: transfer through order isomorphisms
   - `int_equiv_implies_temporal_equiv_with_iso`: main bridge theorem

4. **SemanticBridge.lean cannot be verified** because its import of SeparationThm.lean fails due to the HierarchyInduction build errors.

## Remaining blocker

4 errors remain in HierarchyInduction.lean:
- `case5_sep_with_U_type_Z_gen` (unknown identifier)
- `case6_sep_with_U_type_Z_gen` (unknown identifier)
- `case7_sep_with_U_type_Z_gen` (unknown identifier)
- `case8_sep_with_U_type_Z_gen` (unknown identifier)

These theorems are in HierarchyCompletion.lean (lines 253-665) and need to be moved to HierarchyCaseSep.lean. This is a mechanical copy-paste of ~415 lines of proof code.

## Next action

1. Copy lines 251-665 of HierarchyCompletion.lean to HierarchyCaseSep.lean (before the `end` statement)
2. Also copy lines 527-590 (the private helper `snce_Ufree_event_qNotU_guard_sep_with_U_type`)
3. Remove the moved code from HierarchyCompletion.lean (lines 57-665)
4. Remove duplicate definitions from HierarchyCompletion.lean (is_separable_with_U_type, etc. now in HierarchyDefs)
5. Add `import HierarchyCaseSep` to HierarchyCompletion.lean
6. Verify: `lake build Bimodal.Metalogic.WeakCanonical.Separation.SemanticBridge`

## Key decisions

- The SemanticBridge uses ZStructure (from MonadicFO.lean) as the intermediate type, avoiding the fragile `h_carrier : M.carrier = Z` approach
- For Prior structures with non-Z carriers, the bridge goes through `temporal_truth_order_iso` using an explicit `OrderIso M.carrier Z`

## Files modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy/HierarchyDefs.lean` (added import + moved definitions)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy/HierarchyCaseSep.lean` (new file)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy/HierarchyInduction.lean` (added import)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SemanticBridge.lean` (new file, unverified)
