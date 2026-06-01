# Implementation Plan: Tableau-Driven Formula Labeling for DatasetGenerator

- **Task**: 241 - Rebuild DatasetGenerator for correct tableau integration
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: Task 239 (proof extraction), Task 240 (countermodel correctness)
- **Research Inputs**: specs/241_tableau_formula_labeling/reports/01_research-findings.md
- **Artifacts**: plans/01_tableau-labeling-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Rebuild the DatasetGenerator labeling pipeline to produce richer labeled formula records with detailed proof metadata and enriched countermodels from the corrected tableau. Phase 1 adds new fields to `LabeledFormula` and wires existing infrastructure (RuleProfile, decisionMethod tracking, countermodel consistency) with no external dependencies. Phase 2 integrates the `SemanticCountermodel` and `EnrichedCountermodel` types from task 240. Phase 3 integrates full proof extraction from task 239, removes the `decideOptimized` retry path, and eliminates spurious timeouts. All serialization in DataExport.lean and DatasetExport.lean is updated in each phase to match.

### Research Integration

The research report (01_research-findings.md) identified three interrelated problems in the current labeling pipeline:

1. **Incomplete proof extraction** (task 239): Valid formulas confirmed by the tableau but without extractable proof terms are mislabeled as `.timeout`.
2. **Vacuous countermodel correctness** (task 240): `branchTruthLemma` proves `True` for all signed formulas; `SimpleCountermodel` captures only atoms, not full model structure.
3. **Blocking termination edge cases** (task 237): Some modal-temporal formulas produce incorrect labels due to blocking refinement gaps.

The research recommended a phased approach (A/B/C) matching our 3-phase structure, and identified all files requiring changes: DatasetGenerator.lean, DataExport.lean, DatasetExport.lean, DatasetValidator.lean, and EnrichedCountermodel.lean.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items directly correspond to this task.

## Goals & Non-Goals

**Goals**:
- Add `ruleProfile`, `decisionMethod`, `countermodelConsistent`, and `tableauStats` fields to `LabeledFormula`
- Wire `walkDerivationTree` from DataExport.lean into the labeling pipeline for valid results
- Track which decision stage produced each result (fast_path_axiom, proof_search, tableau_closed, tableau_open, timeout)
- Integrate enriched and semantic countermodels from task 240
- Integrate full proof extraction from task 239, eliminating the timeout-as-fallback-for-valid path
- Update all JSON serialization (DataExport, DatasetExport, DatasetValidator) for new fields
- Maintain backward compatibility for downstream JSONL consumers

**Non-Goals**:
- Modifying the tableau algorithm itself (that is task 237 scope)
- Implementing proof extraction (task 239 scope)
- Implementing semantic countermodel correctness (task 240 scope)
- Modifying the FormulaEnumerator or sampling pipeline
- Changing the CLI interface or argument parsing

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Tasks 239/240 change the DecisionResult type signature | H | M | Phase 1 works with current types; Phases 2-3 adapt to whatever types tasks 239/240 produce |
| Breaking LabeledFormula changes ripple to all consumers | M | H | Update all 4 consumer files (DatasetExport, DatasetExporter, DatasetValidator, EnrichedCountermodel) atomically per phase |
| Conformance tests fail after pipeline changes | M | M | Run DatasetValidator conformance tests as verification for each phase; update expected results if labeling accuracy genuinely improves |
| Performance regression from walkDerivationTree on every valid formula | L | L | walkDerivationTree is O(proof_size) simple recursion; negligible for streaming pipeline |
| Task 240 produces a SemanticCountermodel type that differs from research predictions | M | M | Phase 2 reads whatever type task 240 creates; the plan specifies the integration pattern, not the exact type |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1, Task 240 |
| 3 | 3 | 1, Task 239 |
| 4 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel (Phases 2 and 3 can run in parallel once Phase 1 is complete and their respective dependency tasks are done).

---

### Phase 1: Enrich LabeledFormula with RuleProfile and Decision Method Tracking [COMPLETED]

**Goal**: Add new metadata fields to `LabeledFormula`, wire `walkDerivationTree` into the labeling pipeline for valid results, track which decision stage produced each result, and update all JSON serialization. This phase has no external dependencies.

**Tasks**:
- [x] Add `ruleProfile : Option RuleProfile` field to `LabeledFormula` in DatasetGenerator.lean *(completed)*
- [x] Add `decisionMethod : String` field to `LabeledFormula` (values: "fast_path_axiom", "proof_search", "tableau_closed", "tableau_open", "timeout") *(completed)*
- [x] Add `countermodelConsistent : Option Bool` field to `LabeledFormula` *(completed)*
- [x] Update `Inhabited LabeledFormula` instance with new field defaults *(completed)*
- [x] Modify `labelFormula` to compute `RuleProfile` via `walkDerivationTree` for `.valid proof` results (import from DataExport) *(completed)*
- [x] Modify `labelFormula` to set `decisionMethod` based on which code path produced the result *(completed)*
- [x] Modify `labelFormula` to call `SimpleCountermodel.isConsistent` for `.invalid cm` results (add this method if it does not exist: check atoms intersection is empty) *(completed — isConsistent already existed in CountermodelExtraction.lean)*
- [x] Add `decisionMethod` field to `LabeledFormula.toJson` serialization in DatasetGenerator.lean *(completed)*
- [x] Add `ruleProfile` field to `LabeledFormula.toJson` (serialize as `RuleProfile.toJson` or null) *(completed)*
- [x] Add `countermodelConsistent` field to `LabeledFormula.toJson` *(completed)*
- [x] Update `DatasetRecord` in DatasetExport.lean: add `decision_method : String`, `rule_profile : Option RuleProfile`, `countermodel_consistent : Option Bool` fields *(completed)*
- [x] Update `Inhabited DatasetRecord` instance with new field defaults *(completed)*
- [x] Update `labeledToRecord` to propagate new fields from `LabeledFormula` *(completed)*
- [x] Update `datasetRecordToJson` to serialize new fields *(completed)*
- [x] Update `DatasetMetadata` to include decision method distribution (optional, counts of each method type) *(completed — added decisionMethodDist field with accumulation in both streaming and batch paths)*
- [x] Run `lake build Bimodal.Automation.DatasetGenerator` to verify compilation *(completed — builds successfully)*
- [x] Run `lake build Bimodal.Automation.DatasetExport` to verify compilation *(completed — builds successfully)*
- [x] Run `lake build Bimodal.Automation.DatasetValidator` to verify compilation (may need minor updates to account for new fields) *(completed — builds successfully, no updates needed)*

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - Add fields, update labelFormula, update toJson
- `Theories/Bimodal/Automation/DatasetExport.lean` - Add fields to DatasetRecord, update serialization
- `Theories/Bimodal/Automation/DataExport.lean` - Add SimpleCountermodel.isConsistent if needed
- `Theories/Bimodal/Automation/DatasetValidator.lean` - Ensure compilation with new LabeledFormula fields

**Verification**:
- `lake build Bimodal.Automation.DatasetGenerator` compiles without errors
- `lake build Bimodal.Automation.DatasetExport` compiles without errors
- `lake build Bimodal.Automation.DatasetValidator` compiles without errors
- New fields appear in serialized JSON output (manual inspection of `LabeledFormula.toJson` and `datasetRecordToJson`)

---

### Phase 2: Integrate Enriched and Semantic Countermodels from Task 240 [NOT STARTED]

**Goal**: Replace the atom-only `SimpleCountermodel` with the richer countermodel types produced by task 240. Wire `EnrichedCountermodel` (already exists in EnrichedCountermodel.lean) into the main pipeline, and integrate the new `SemanticCountermodel` type (to be created by task 240).

**Tasks**:
- [ ] Inspect task 240 output: determine the exact `SemanticCountermodel` type signature and its location
- [ ] Add `enrichedCountermodel : Option EnrichedCountermodel` field to `LabeledFormula`
- [ ] Add `semanticCountermodel : Option SemanticCountermodel` field to `LabeledFormula` (type name from task 240)
- [ ] Update `Inhabited LabeledFormula` instance
- [ ] Import `Bimodal.Automation.Enriched` in DatasetGenerator.lean (for `EnrichedCountermodel`)
- [ ] Modify `labelFormula` for `.invalid` cases: after obtaining `SimpleCountermodel`, also call `extractEnrichedCountermodel` using the open branch (this requires access to the raw branch from the tableau result)
- [ ] Modify `labelFormula` for `.invalid` cases: if task 240 provides a `SemanticCountermodel` constructor, wire it in
- [ ] If `labelFormula` cannot access the raw branch (because `decideAuto` returns `SimpleCountermodel`, not `Branch`): create a parallel code path using `buildTableau` directly for invalid results to extract the enriched countermodel
- [ ] Add `EnrichedCountermodel.toJson` serialization to `LabeledFormula.toJson` (already exists in EnrichedCountermodel.lean)
- [ ] Add `SemanticCountermodel.toJson` serialization (implement if task 240 did not provide it)
- [ ] Update `DatasetRecord` in DatasetExport.lean: add `enriched_countermodel` and `semantic_countermodel` fields
- [ ] Update `Inhabited DatasetRecord`, `labeledToRecord`, and `datasetRecordToJson`
- [ ] Run `lake build Bimodal.Automation.DatasetGenerator` and `lake build Bimodal.Automation.DatasetExport`

**Timing**: 2 hours

**Depends on**: 1, Task 240

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - Add countermodel fields, modify labelFormula
- `Theories/Bimodal/Automation/DatasetExport.lean` - Add fields to DatasetRecord, update serialization
- `Theories/Bimodal/Automation/DataExport.lean` - Add SemanticCountermodel.toJson if needed
- `Theories/Bimodal/Automation/EnrichedCountermodel.lean` - Possibly extend for new integration pattern

**Verification**:
- `lake build Bimodal.Automation.DatasetGenerator` compiles without errors
- `lake build Bimodal.Automation.DatasetExport` compiles without errors
- Invalid formulas produce enriched countermodel data (inspect JSON output for a known invalid formula)

---

### Phase 3: Integrate Full Proof Extraction and Remove Retry Path [NOT STARTED]

**Goal**: With task 239 providing complete proof extraction from closed tableaux, eliminate the `decideOptimized` retry path in `labelFormula`, remove the timeout-as-fallback-for-valid workaround in `DecisionProcedure.decide`, and add `proofReconstructionMethod` tracking.

**Tasks**:
- [ ] Inspect task 239 output: verify that `decide` now returns `.valid proof` for all closed tableaux (the line 154 `.timeout` fallback in DecisionProcedure.lean should be replaced)
- [ ] Add `proofReconstructionMethod : Option String` field to `LabeledFormula` (values: "axiom_match", "proof_search", "tableau_extraction")
- [ ] Update `Inhabited LabeledFormula` instance
- [ ] Remove the `decideOptimized` retry block from `labelFormula` (lines 287-316 in current DatasetGenerator.lean): the `.timeout` case from `decideAuto` should now be genuinely rare
- [ ] Simplify `labelFormula` to a single `decideAuto` call with three clean branches: `.valid`, `.invalid`, `.timeout`
- [ ] Set `proofReconstructionMethod` based on how the proof was obtained (this may require inspecting the proof structure or adding a tag to `DecisionResult`)
- [ ] Update `LabeledFormula.toJson` to include `proofReconstructionMethod`
- [ ] Update `DatasetRecord`, `Inhabited DatasetRecord`, `labeledToRecord`, and `datasetRecordToJson` for new field
- [ ] Update `DatasetValidator.knownValidFormulas` expected results if labeling accuracy changes (formulas previously timing out should now be labeled `.valid`)
- [ ] Run `lake build Bimodal.Automation.DatasetGenerator`
- [ ] Run `lake build Bimodal.Automation.DatasetExport`
- [ ] Run `lake build Bimodal.Automation.DatasetValidator`

**Timing**: 1.5 hours

**Depends on**: 1, Task 239

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - Remove retry path, add proofReconstructionMethod, simplify labelFormula
- `Theories/Bimodal/Automation/DatasetExport.lean` - Add field to DatasetRecord, update serialization
- `Theories/Bimodal/Automation/DatasetValidator.lean` - Update expected results if needed

**Verification**:
- `lake build Bimodal.Automation.DatasetGenerator` compiles without errors
- `lake build Bimodal.Automation.DatasetExport` compiles without errors
- `lake build Bimodal.Automation.DatasetValidator` compiles without errors
- The `decideOptimized` retry block is removed from `labelFormula`
- Known valid formulas that previously timed out now produce `.valid` labels

---

### Phase 4: Full Build Verification and Conformance Testing [NOT STARTED]

**Goal**: Verify that the complete pipeline compiles, passes conformance tests, and produces valid JSONL output with all new fields populated.

**Tasks**:
- [ ] Run `lake build` (full project build) to verify no regressions
- [ ] Verify `#print axioms` on key definitions to check no sorry leakage
- [ ] Inspect `LabeledFormula.toJson` output for a known valid formula (should include ruleProfile, decisionMethod, proofReconstructionMethod)
- [ ] Inspect `LabeledFormula.toJson` output for a known invalid formula (should include enrichedCountermodel, semanticCountermodel, countermodelConsistent)
- [ ] Verify `datasetRecordToJson` includes all new fields with correct JSON structure
- [ ] Verify backward compatibility: existing fields (formula, label, proof_trace, countermodel, metrics, pattern_key) remain unchanged in structure and semantics
- [ ] Update DatasetValidator conformance tests if any known formulas changed labels due to improved accuracy
- [ ] Run conformance tests via DatasetValidator to confirm pass

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetValidator.lean` - Update conformance tests if needed

**Verification**:
- `lake build` succeeds with zero errors
- DatasetValidator conformance tests pass
- JSONL output contains all new fields for valid, invalid, and timeout formulas

## Testing & Validation

- [ ] `lake build Bimodal.Automation.DatasetGenerator` compiles after each phase
- [ ] `lake build Bimodal.Automation.DatasetExport` compiles after each phase
- [ ] `lake build` (full project) compiles after Phase 4
- [ ] DatasetValidator conformance tests pass after Phase 4
- [ ] New JSON fields are correctly serialized (manual inspection)
- [ ] Backward compatibility: existing JSONL consumers continue to work (new fields are additive)

## Artifacts & Outputs

- `specs/241_tableau_formula_labeling/plans/01_tableau-labeling-plan.md` (this plan)
- Modified `Theories/Bimodal/Automation/DatasetGenerator.lean` (enriched LabeledFormula, simplified labelFormula)
- Modified `Theories/Bimodal/Automation/DataExport.lean` (new serialization functions)
- Modified `Theories/Bimodal/Automation/DatasetExport.lean` (enriched DatasetRecord)
- Modified `Theories/Bimodal/Automation/DatasetValidator.lean` (updated conformance tests)

## Rollback/Contingency

If tasks 239 or 240 are not yet complete when implementation begins:
- Phase 1 can proceed independently and delivers value on its own (ruleProfile, decisionMethod, countermodelConsistent)
- Phases 2 and 3 should be deferred until their respective dependency tasks complete
- If task 239/240 change types in unexpected ways, the plan's integration patterns (inspect output, wire types) remain valid; only specific type names may need updating
- Git revert of individual phase commits provides clean rollback per phase
