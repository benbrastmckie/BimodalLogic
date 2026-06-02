# Implementation Plan: Task #248

- **Task**: 248 - fold_direction_formula_normalization
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: None (all fold/serialization functions exist in Normalization.lean)
- **Research Inputs**: specs/248_fold_direction_formula_normalization/reports/01_fold-direction-normalization.md
- **Artifacts**: plans/01_fold-direction-normalization.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Wire existing fold algorithm and enriched serialization functions from Normalization.lean into the dataset export pipeline. The fold algorithm (EnrichedFormula ADT, two-pass greedy fold, JSON/pretty-print/S-expression serialization) is already fully implemented and tested. This plan adds `formula_folded_json`, `formula_folded_str`, and `formula_folded_sexpr` fields to `DatasetRecord` in DatasetExport.lean, adds `goal_folded_json` to `ProofStep` in ProofStepExtractor.lean, and updates both JSON serializers and the metadata representations array. No new Lean logic is needed.

### Research Integration

Key findings from the research report:

1. The fold algorithm is fully implemented in Normalization.lean (lines 249-658) with a two-pass greedy strategy that correctly resolves the `or`/`and` ambiguity.
2. Three convenience functions already exist: `Formula.toEnrichedJson`, `Formula.toEnrichedPretty`, `Formula.toEnrichedSExpr` (lines 971-980).
3. All 21 round-trip tests pass -- `toPrimitive(foldFormulaFull(f)) = f` holds empirically.
4. Integration is mechanical: add fields, import Normalization, populate with existing function calls.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items explicitly reference this task. This task enables enriched formula representations for BimodalHarness training data, supporting the dataset enhancement topic.

## Goals & Non-Goals

**Goals**:
- Add enriched (folded) formula fields alongside existing primitive fields in DatasetRecord
- Add enriched goal representation in ProofStep
- Update JSONL serialization for both structures
- Update metadata representations array to document new fields
- Maintain backward compatibility (all existing fields unchanged)

**Non-Goals**:
- Modifying the fold algorithm itself (already correct and tested)
- Adding formal round-trip theorems (deferred per research recommendation)
- Adding folded context formulas in ProofStep (lower priority, can be done later)
- Changing existing field names or formats

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import cycle from Normalization | H | L | Normalization.lean imports only Syntax.Formula; DatasetExport imports DatasetGenerator and DataExport -- no cycle expected |
| Build regression from new import | M | L | Run `lake build` after changes to verify |
| JSONL field ordering breaks downstream | L | L | New fields appended at end of JSON object; existing consumers ignore unknown fields |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Add Enriched Fields to DatasetRecord and Serialization [COMPLETED]

**Goal**: Add three new folded-formula fields to DatasetRecord, populate them in labeledToRecord, update datasetRecordToJson, and update the metadata representations array.

**Tasks**:
- [x] Add `import Bimodal.Automation.Normalization` to DatasetExport.lean (after existing imports, line 2)
- [x] Add three fields to the `DatasetRecord` structure (after `formula_tokens` at line 184):
  - `formula_folded_json : String` -- enriched JSON AST from `Formula.toEnrichedJson`
  - `formula_folded_str : String` -- enriched pretty-print from `Formula.toEnrichedPretty`
  - `formula_folded_sexpr : String` -- enriched S-expression from `Formula.toEnrichedSExpr`
- [x] Add default values for the three new fields in the `Inhabited DatasetRecord` instance (empty strings)
- [x] Populate the three new fields in `labeledToRecord` using:
  - `formula_folded_json := lf.formula.toEnrichedJson`
  - `formula_folded_str := lf.formula.toEnrichedPretty`
  - `formula_folded_sexpr := lf.formula.toEnrichedSExpr`
- [x] Add the three new fields to `datasetRecordToJson` serialization (append after `max_temporal_depth` at line 279):
  - `formula_folded_json` field as raw JSON (not string-escaped, since toEnrichedJson produces a JSON object)
  - `formula_folded_str` field as escaped string
  - `formula_folded_sexpr` field as escaped string
- [x] Add three entries to the `representations` array in `datasetMetadataToJson` (after the `pattern_features` entry at line 440):
  - `{"field": "formula_folded_json", "format": "json-ast", "description": "Enriched JSON AST with derived operator tags (neg, and, or, diamond, etc.)"}`
  - `{"field": "formula_folded_str", "format": "human-readable", "description": "Enriched pretty-print with derived operator notation"}`
  - `{"field": "formula_folded_sexpr", "format": "s-expression", "description": "Enriched S-expression with derived operator tags"}`

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetExport.lean` -- add import, add fields, update serialization, update metadata

**Verification**:
- `lake build Bimodal.Automation.DatasetExport` compiles without errors
- New fields appear in generated JSONL output (can verify with `#eval` or a small test)

---

### Phase 2: Add Enriched Goal to ProofStep and Build Verification [NOT STARTED]

**Goal**: Add `goal_folded_json` field to ProofStep, update its JSON serialization, import Normalization, and verify the full project builds.

**Tasks**:
- [ ] Add `import Bimodal.Automation.Normalization` to ProofStepExtractor.lean (after existing imports, line 4)
- [ ] Add `goal_folded_json : String` field to the `ProofStep` structure (after `goal` at line 135)
- [ ] Populate `goal_folded_json` in `extractStepSequence` where ProofStep records are constructed -- set to `step.goal.toEnrichedJson`
- [ ] Add `goal_folded_json` to `ProofStep.toJson` serialization (after the `goal` field at line 177):
  - `++ ", \"goal_folded_json\": " ++ step.goal_folded_json`
- [ ] Run `lake build Bimodal.Automation.ProofStepExtractor` to verify module compiles
- [ ] Run `lake build` to verify full project builds with no regressions

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/ProofStepExtractor.lean` -- add import, add field, update serialization

**Verification**:
- `lake build Bimodal.Automation.ProofStepExtractor` compiles without errors
- `lake build` full project passes (zero new errors)
- The `goal_folded_json` field appears in ProofStep JSON output

---

## Testing & Validation

- [ ] `lake build Bimodal.Automation.DatasetExport` passes
- [ ] `lake build Bimodal.Automation.ProofStepExtractor` passes
- [ ] `lake build` full project passes with zero errors
- [ ] New JSONL fields (`formula_folded_json`, `formula_folded_str`, `formula_folded_sexpr`) produce valid enriched representations
- [ ] `goal_folded_json` field in ProofStep output contains enriched JSON
- [ ] Existing fields remain unchanged (backward compatibility)

## Artifacts & Outputs

- `specs/248_fold_direction_formula_normalization/plans/01_fold-direction-normalization.md` (this plan)
- Modified: `Theories/Bimodal/Automation/DatasetExport.lean`
- Modified: `Theories/Bimodal/Automation/ProofStepExtractor.lean`

## Rollback/Contingency

Revert the two modified files to their pre-implementation state using `git checkout`. No new files are created by implementation; the changes are additive (new fields alongside existing ones) so partial rollback per-file is safe.
