# Phase 1 Handoff: Semantic Bridge Infrastructure (Second Attempt)

## Status: COMPLETED (SemanticBridge.lean compiles)

## What was accomplished

1. **SemanticBridge.lean builds successfully** with zero sorries. Import changed from 
   `SeparationThm` to `Defs` to avoid rebuilding the Hierarchy files.

2. **Key theorems proven**:
   - `z_structure_to_int`: IntStructure from ZStructure + atomMap
   - `int_truth_eq_temporal_truth_Z`: int_truth ↔ temporal_truth on Z-carrier (box-free)
   - `int_equiv_implies_temporal_equiv_Z`: int_equiv → temporal equivalence on Z
   - `temporal_truth_order_iso`: temporal_truth transfers through order isomorphisms
   - `int_equiv_implies_temporal_equiv_with_iso`: main bridge (any carrier with iso to Z)

3. **Pre-existing Hierarchy build issue documented**: HierarchyDefs.lean is missing 
   `import Bimodal.Metalogic.WeakCanonical.Separation.FormulaOps`. This is masked by 
   stale oleans from the original task 174 split. Touching any Hierarchy file exposes 
   the issue. The circular dependency (HierarchyInduction needs case5-8 from 
   HierarchyCompletion, which imports HierarchyInduction) also prevents clean rebuilds.
   
   **DO NOT** touch the Hierarchy files until this pre-existing issue is fixed as a 
   separate task. SemanticBridge avoids this by importing only `Defs.lean`.

## Next steps for task 273

### Phase 2-4 approach (revised)

The original plan assumed SemanticBridge would import SeparationThm to get 
`all_formulas_separable`. Since SemanticBridge now imports only Defs, the 
separation theorem needs to be accessed differently.

**Option A (recommended)**: Create a new file (e.g., `SeparationBypass.lean`) that:
1. Imports `SemanticBridge.lean` for the bridge theorems
2. Imports `PriorExpressiveness.lean` for `flatten_stavi_correct_prior`
3. Does NOT import `SeparationThm.lean` or any Hierarchy files
4. Proves `US_expressively_complete_over_prior` directly using the bridge + 
   the fact that on Prior structures, U'/S' are trivially false

The key insight: we don't need `all_formulas_separable` (the general separation 
theorem) for the bypass. We only need:
- The bridge (SemanticBridge: int_equiv → temporal_truth equivalence)
- The fact that on Prior structures, U' and S' connectives are false
- A direct argument that {U,S}-formulas suffice on Prior structures

**Option B**: Fix the Hierarchy build issue first (separate task), then import 
SeparationThm as originally planned.

### Immediate next action

1. Study `US_expressively_complete_over_prior` in PriorExpressiveness.lean to 
   understand its exact type signature and how it's consumed
2. Study `flatten_stavi_correct_prior` and what it provides
3. Design the bypass proof using SemanticBridge + Prior structure properties

## Files modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SemanticBridge.lean` (rewritten from previous attempt)
- `specs/273_chronicle_gap_contradiction_proof/plans/03_separation-bypass-plan.md` (Phase 1 marked IN PROGRESS)
