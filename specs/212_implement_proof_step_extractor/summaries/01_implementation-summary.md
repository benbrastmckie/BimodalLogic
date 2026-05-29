# Implementation Summary: Proof Step Extractor

- **Task**: 212 - Implement proof step extractor for BimodalHarness training data
- **Status**: COMPLETED
- **Session**: sess_1780083735_5vngv
- **Date**: 2026-05-29

## What Was Implemented

Built a complete proof step extraction pipeline that walks DerivationTree values and emits ordered ProofStep records for the BimodalHarness AlphaZero-style training pipeline.

### New Files

1. **`Theories/Bimodal/Automation/ProofStepExtractor.lean`** (310 lines)
   - `Axiom.toName`: 42-case exhaustive pattern match mapping axiom constructors to strings
   - `ProofStep` structure with 8 fields: theoremName, stepIndex, context, goal, rule, axiomName, subgoals, frameClass
   - `ProofStep.toJson`: JSON serialization matching BimodalHarness ProofStepRecord schema
   - `extractStepSequence`: Recursive pre-order tree walker handling all 7 DerivationTree constructors
   - `TheoremEntry`: Registry entry type with lazy evaluation thunk

2. **`Theories/Bimodal/Automation/ProofStepExport.lean`** (320 lines)
   - Theorem registry with 36 computable standalone theorems across 7 source files
   - `processRegistry`: Batch extraction with error handling
   - `parseArgs`: CLI argument parsing (--output)
   - `main`: Entry point writing JSONL output

### Modified Files

3. **`lakefile.lean`**: Added `lean_exe proof_extractor` target
4. **`Theories/Bimodal/Automation.lean`**: Added ProofStepExtractor import

### Generated Output (not committed)

5. **`data/proof_steps.jsonl`**: 2424 proof step records from 36 theorems

## Metrics

| Metric | Value |
|--------|-------|
| Theorems registered | 36 |
| Total proof steps | 2424 |
| Axiom names present | 13 of 42 |
| Inference rules present | 5 of 7 |
| JSONL validity | 100% (2424/2424 lines) |
| Field completeness | 100% |
| axiom_name/rule consistency | 0 violations |
| Subgoals arity correctness | 100% |
| Sorries | 0 |
| New axioms | 0 |
| Build status | passes (1678 jobs) |

## Registry Breakdown

| Source File | Count | Theorems |
|-------------|-------|----------|
| Combinators.lean | 8 | identity, b_combinator, theorem_flip, theorem_app1, theorem_app2, pairing, dni, temp_future_derived |
| ModalS4.lean | 2 | s4_box_diamond_box, s4_diamond_box_diamond |
| ModalS5.lean | 6 | t_box_to_diamond, box_contrapose, k_dist_diamond, t_box_consistency, s5_diamond_box, s5_diamond_box_to_truth |
| TemporalDerived.lean | 7 | connect_future_thm, connect_past_thm, G_implies_G_id, until_implies_some_future, since_implies_some_past, until_imp_F, since_imp_P |
| Helpers.lean | 3 | box_to_future, box_to_past, box_to_present |
| Principles.lean | 10 | perpetuity_1, diamond_4, modal_5, perpetuity_2, box_to_box_past, perpetuity_3, perpetuity_4, mb_diamond, box_diamond_to_future_box_diamond, box_diamond_to_past_box_diamond |

## Plan Deviations

- **Registry design** (Phase 2, Task 2.1): Used TheoremEntry with lazy thunks instead of sigma types, avoiding eager evaluation of all derivation trees at construction time.
- **Registry scope** (Phase 2): 36 standalone theorems registered instead of estimated ~102. The research overestimated computability: Bridge.lean, Core.lean, Connectives.lean, and Reasoning.lean are entirely inside `noncomputable section`, and many computable definitions require proof inputs (DerivationTree arguments) making them unsuitable for standalone registration.
- **CLI arguments** (Phase 3, Task 3.5): Only `--output` implemented; `--frame-class` and `--compact` deferred since all registered theorems use FrameClass.Base and compact mode is not needed for initial version.
- **Step count** (Phase 4, Task 4.3): Actual yield 2424 exceeds estimated 300-800 because some theorems (especially perpetuity proofs and combinator compositions) produce deep derivation trees.
- **Axiom coverage** (Phase 4, Task 4.5): 13/42 axiom names present (not 42/42). The BX temporal, uniformity, prior, Z1, and density axioms are used in noncomputable theorems excluded from extraction.
- **Rule coverage** (Phase 4, Task 4.6): 5/7 rules present. `assumption` and `weakening` absent because all registered theorems derive from empty context.

## Future Work

- Extract from noncomputable theorems using Lean metaprogramming (requires `#eval`-level elaboration tricks)
- Add `--frame-class` filter for Dense/Discrete-specific extraction when Dense/Discrete standalone theorems are added
- Register theorems that take proof inputs by pre-computing their arguments (e.g., `imp_trans` composed with specific axiom pairs)
