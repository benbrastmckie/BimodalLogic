# Implementation Plan: Proof Step Extractor for BimodalHarness Training Data

- **Task**: 212 - Implement proof step extractor for BimodalHarness training data
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None
- **Research Inputs**: specs/212_implement_proof_step_extractor/reports/01_proof-step-extractor.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Implement an `extractStepSequence` function that recursively walks `DerivationTree` values and emits ordered `ProofStep` records for the BimodalHarness AlphaZero-style training pipeline. The implementation creates two new Lean files (`ProofStepExtractor.lean` for core extraction logic and `ProofStepExport.lean` for the executable entry point), adds a `lake exe proof_extractor` target to the lakefile, and registers the computable subset of ~102 theorem definitions from `Theories/Bimodal/Theorems/` for step extraction. The existing `walkDerivationTree` pattern in `DataExport.lean` provides the recursive traversal template, and existing JSON serialization infrastructure (`Formula.toJson`, `escapeJsonString`, `listToJsonArray`) is reused directly.

### Research Integration

Key findings from the research report integrated into this plan:
- **DerivationTree** is `Type` (not `Prop`), enabling pattern matching and computable data extraction across all 7 constructors
- **49-action space confirmed**: 42 axiom constructors + 7 inference rules
- **Computability analysis**: 102 of ~145 definitions in Theorems/ are computable (no `noncomputable` marker); breakdown: Combinators (12), Helpers (6), Bridge (23), Principles (16), Core (13), Connectives (12), ModalS5 (7), TemporalDerived (9), ModalS4 (2), GeneralizedNecessitation (1), Reasoning (1)
- **~43 definitions are noncomputable** (use `deduction_theorem`), excluded from Phase 1 scope but recoverable via metaprogramming in a future task
- **Existing infrastructure**: `walkDerivationTree`, `Formula.toJson`, `escapeJsonString`, `listToJsonArray`, `writeRecordJSONL` patterns, lakefile `lean_exe` targets -- all directly reusable
- **Estimated yield**: ~300-800 steps from computable theorems (3-8 nodes per tree on average)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items directly addressed by this task.

## Goals & Non-Goals

**Goals**:
- Define `ProofStep` structure and `ProofStep.toJson` serialization matching the `ProofStepRecord` schema expected by BimodalHarness
- Implement `Axiom.toName` mapping all 42 axiom constructors to string names
- Implement `extractStepSequence` that recursively walks a `DerivationTree` and emits ordered `ProofStep` records with `(context, goal, rule, axiom_name, subgoals)`
- Register all computable theorems (~102 definitions) from `Theories/Bimodal/Theorems/` into a named registry
- Create `lake exe proof_extractor` executable that processes the registry and outputs JSONL
- Verify end-to-end pipeline: build passes, executable runs, JSONL output is well-formed

**Non-Goals**:
- Extracting steps from noncomputable theorems (requires metaprogramming, deferred to future task)
- Python-side consumer code (belongs to BimodalHarness task 9)
- Tensor conversion or ML model integration
- Extending the action space beyond the existing 49 actions

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Some "computable" theorems fail at runtime in executable context | M | L | Test with `#eval` on representative subset first; exclude any that fail |
| Large formula JSON makes JSONL files unwieldy | L | M | Include both `formula_ast` (full) and `formula_str` (pretty-print) fields; optional `--compact` flag |
| Theorem registration boilerplate is error-prone (102 entries) | M | M | Group by file with comments; systematic construction using sigma types |
| FrameClass-parameterized theorems require explicit fc instantiation | M | L | Default to `FrameClass.Base` for most theorems; handle `Dense`/`Discrete`-specific ones explicitly |
| Axiom.toName 42-case match is tedious but straightforward | L | L | Follow exhaustive pattern from research report; compile-time verification catches missing cases |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Core Extraction Logic [COMPLETED]

**Goal**: Create `ProofStepExtractor.lean` with `ProofStep` structure, `Axiom.toName`, `extractStepSequence`, and JSON serialization.

**Tasks**:
- [x] Create `Theories/Bimodal/Automation/ProofStepExtractor.lean` with module docstring
- [x] Define `ProofStep` structure with fields: `theoremName`, `stepIndex`, `context`, `goal`, `rule`, `axiomName`, `subgoals`, `frameClass`
- [x] Implement `Axiom.toName` as a 42-case pattern match mapping each axiom constructor to its string name
- [x] Implement `ProofStep.toJson` serialization using the existing `Formula.toJson`, `escapeJsonString`, `listToJsonArray` helpers from `DataExport.lean`
- [x] Implement `Context.toJson` helper to serialize context (list of formulas) to JSON array *(deviation: altered -- named `contextToJson` instead of `Context.toJson` since Context is a type alias for List Formula)*
- [x] Implement `extractStepSequence` recursive function following the `walkDerivationTree` pattern: walk each `DerivationTree` node, emit a `ProofStep` record, recurse into sub-derivations, accumulate steps in order with an index counter
- [x] Add `import Bimodal.Automation.ProofStepExtractor` to `Theories/Bimodal/Automation.lean`
- [x] Verify compilation: `lake build Bimodal.Automation.ProofStepExtractor`

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/ProofStepExtractor.lean` - New file: core extraction types and functions
- `Theories/Bimodal/Automation.lean` - Add import for new module

**Verification**:
- `lake build Bimodal.Automation.ProofStepExtractor` compiles without errors
- `Axiom.toName` covers all 42 constructors (exhaustive match ensures no warnings)
- `extractStepSequence` handles all 7 `DerivationTree` constructors

---

### Phase 2: Theorem Registry [COMPLETED]

**Goal**: Create a named registry of all computable theorems from `Theories/Bimodal/Theorems/`, organized by source file, with sigma-typed entries that pair theorem names with their `DerivationTree` values.

**Tasks**:
- [x] Design the registry entry type: `(String × (fc : FrameClass) × (f : Formula) × DerivationTree fc [] f)` or equivalent sigma type that captures theorem name, frame class, formula, and tree *(deviation: altered -- used TheoremEntry with lazy thunk pattern instead of sigma types, since thunks avoid evaluating all trees at registry construction time)*
- [x] Register computable theorems from `Combinators.lean` (8 standalone definitions: identity, b_combinator, theorem_flip, theorem_app1, theorem_app2, pairing, dni, temp_future_derived) *(deviation: altered -- 8 not 12, since imp_trans, mp, combine_imp_conj, combine_imp_conj_3 require proof inputs and cannot be registered standalone)*
- [x] Register computable theorems from `Perpetuity/Helpers.lean` (3 standalone definitions: box_to_future, box_to_past, box_to_present) *(deviation: altered -- 3 not 6, since axiom_in_context, apply_axiom_to, apply_axiom_in_context require proof inputs)*
- [ ] Register computable theorems from `Perpetuity/Bridge.lean` (~23 computable definitions) *(deviation: skipped -- ALL definitions are inside noncomputable section)*
- [x] Register computable theorems from `Perpetuity/Principles.lean` (10 standalone definitions: perpetuity_1, diamond_4, modal_5, perpetuity_2, box_to_box_past, perpetuity_3, perpetuity_4, mb_diamond, box_diamond_to_future_box_diamond, box_diamond_to_past_box_diamond) *(deviation: altered -- 10 not 16, since contraposition, box_conj_intro, box_conj_intro_imp, box_conj_intro_imp_3, box_dne, future_k_dist require proof inputs or are noncomputable)*
- [ ] Register computable theorems from `Propositional/Core.lean` (~13 computable definitions) *(deviation: skipped -- ALL definitions are inside noncomputable section)*
- [ ] Register computable theorems from `Propositional/Connectives.lean` (~12 computable definitions) *(deviation: skipped -- ALL definitions are inside noncomputable section)*
- [x] Register computable theorems from `ModalS5.lean` (6 standalone definitions: t_box_to_diamond, box_contrapose, k_dist_diamond, t_box_consistency, s5_diamond_box, s5_diamond_box_to_truth) *(deviation: altered -- 6 not 7, since iff is a Formula definition not a DerivationTree)*
- [x] Register computable theorems from `TemporalDerived.lean` (7 standalone definitions)
- [x] Register computable theorems from `ModalS4.lean` (2 standalone definitions)
- [ ] Register computable theorems from `GeneralizedNecessitation.lean` (1 computable definition: reverse_deduction) *(deviation: skipped -- reverse_deduction requires a proof input)*
- [ ] Register computable theorems from `Propositional/Reasoning.lean` (1 computable definition) *(deviation: skipped -- ALL definitions inside noncomputable section)*
- [x] Verify all registry entries compile: `lake build proof_extractor`

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/ProofStepExtractor.lean` - Add theorem registry section with all computable theorem entries

**Verification**:
- All registry entries compile without errors
- No `noncomputable` definitions referenced (would cause compilation failure in executable context)
- Registry size matches expected count (~102 entries)

---

### Phase 3: Executable and JSONL Export [COMPLETED]

**Goal**: Create `ProofStepExport.lean` with the `main` function for `lake exe proof_extractor`, add the `lean_exe` target to `lakefile.lean`, and implement JSONL output.

**Tasks**:
- [x] Create `Theories/Bimodal/Automation/ProofStepExport.lean` with module docstring
- [x] Import `ProofStepExtractor` and all `Theorems.*` modules
- [x] Implement `processTheorem` function: given a registry entry, call `extractStepSequence`, produce list of `ProofStep.toJson` strings *(deviation: altered -- named processRegistry, processes all entries in a batch rather than one at a time)*
- [x] Implement `writeProofStepsJSONL` function: iterate over registry, call `processTheorem` for each, write one JSON line per step to output file *(deviation: altered -- integrated into main function directly)*
- [ ] Implement CLI argument parsing: `--output PATH` (default: `data/proof_steps.jsonl`), `--frame-class FILTER` (optional: Base/Dense/Discrete), `--compact` (optional: omit formula AST) *(deviation: altered -- implemented --output only; --frame-class and --compact deferred as all theorems are Base and compact mode not needed for initial version)*
- [x] Implement `main : IO Unit` function: parse args, run extraction, report summary (theorem count, step count, output path)
- [x] Add `lean_exe proof_extractor` target to `lakefile.lean` following existing `dataset_generator` pattern
- [x] Build the executable: `lake build proof_extractor`

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/ProofStepExport.lean` - New file: executable entry point with main function
- `lakefile.lean` - Add `lean_exe proof_extractor` target

**Verification**:
- `lake build proof_extractor` compiles without errors
- `lake exe proof_extractor` runs and produces output file
- Output file exists at the expected path

---

### Phase 4: End-to-End Validation [COMPLETED]

**Goal**: Run the full pipeline, validate JSONL output, verify step yield is in expected range, and ensure schema compatibility with BimodalHarness.

**Tasks**:
- [x] Run `lake exe proof_extractor -- --output data/proof_steps.jsonl` and capture output
- [x] Verify output file is valid JSONL (each line parses as valid JSON)
- [x] Verify step count is within expected range (~300-800 steps) *(deviation: altered -- actual yield is 2424 steps, higher than expected because some theorems like perpetuity proofs have deep derivation trees with 100+ nodes)*
- [x] Spot-check 5-10 records for correctness: verify `rule` field matches expected inference rule, `axiom_name` is non-null only when `rule = "axiom"`, `context` and `goal` are valid formula JSON, `subgoals` array length matches the rule's arity
- [x] Verify all 42 axiom names appear at least once across the corpus (or document which are absent and why) *(deviation: altered -- 13 of 42 axiom names present; 29 absent because the computable standalone theorems use only propositional, S5 modal, and basic temporal axioms; BX temporal, uniformity, prior, Z1, and density axioms appear in noncomputable theorems excluded from extraction)*
- [x] Verify all 7 inference rule names appear in the output *(deviation: altered -- 5 of 7 rules present; assumption and weakening absent because all registered theorems derive from empty context and do not use context expansion)*
- [x] Run `lake build` to confirm no regressions in the full project build
- [x] Write a brief validation summary as comments in `ProofStepExport.lean`

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Automation/ProofStepExport.lean` - Add validation notes and usage documentation

**Verification**:
- JSONL file contains valid JSON on every line
- Step count >= 200 (minimum viable for training)
- `lake build` passes with no new errors
- All 7 inference rules represented in output
- `axiom_name` field correctly null for non-axiom rules and non-null for axiom rule

---

## Testing & Validation

- [ ] `lake build Bimodal.Automation.ProofStepExtractor` compiles cleanly
- [ ] `lake build proof_extractor` compiles cleanly
- [ ] `lake exe proof_extractor` runs to completion and produces JSONL output
- [ ] Output JSONL has one valid JSON object per line
- [ ] Step count is in range 200-1000
- [ ] Each record has all required fields: `theorem_name`, `step_index`, `context`, `goal`, `rule`, `axiom_name`, `subgoals`, `frame_class`
- [ ] `rule` field values are one of the 7 valid inference rule strings
- [ ] `axiom_name` is non-null iff `rule = "axiom"`
- [ ] `lake build` (full project) passes with no regressions

## Artifacts & Outputs

- `Theories/Bimodal/Automation/ProofStepExtractor.lean` - Core extraction types, Axiom.toName, extractStepSequence, ProofStep.toJson
- `Theories/Bimodal/Automation/ProofStepExport.lean` - Executable entry point with main function
- `Theories/Bimodal/Automation.lean` - Updated umbrella import
- `lakefile.lean` - New `lean_exe proof_extractor` target
- `data/proof_steps.jsonl` - Output JSONL file (generated at runtime, not committed)
- `specs/212_implement_proof_step_extractor/plans/01_implementation-plan.md` - This plan

## Rollback/Contingency

If implementation fails:
1. The two new files (`ProofStepExtractor.lean`, `ProofStepExport.lean`) can be deleted without affecting existing code
2. The `lean_exe` target in `lakefile.lean` can be removed (single block deletion)
3. The umbrella import line in `Automation.lean` can be removed
4. No existing files are modified destructively -- the changes are purely additive
5. If specific theorems cause runtime issues in the executable, they can be excluded from the registry individually without affecting the pipeline
