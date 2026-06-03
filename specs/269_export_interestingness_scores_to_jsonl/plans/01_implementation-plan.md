# Implementation Plan: Export Interestingness Scores to JSONL

- **Task**: 269 - Export interestingness scores from DatasetRecord to JSONL output
- **Status**: [COMPLETED]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: specs/269_export_interestingness_scores_to_jsonl/reports/01_export-fix.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`DatasetRecord` is missing two fields that `LabeledFormula` already populates — `interestingnessScore` and `interestingnessTier` — so both are silently dropped when converting to JSONL. The fix is confined to `Theories/Bimodal/Automation/DatasetExport.lean` and requires 4 targeted edits: add the two fields to the struct, default them in the `Inhabited` instance, serialize them in `datasetRecordToJson`, and transfer them in `labeledToRecord`. Validation is done by regenerating the c5 dataset and inspecting the output.

### Research Integration

Research report `01_export-fix.md` confirmed the bug and identified all 4 edit points with exact code snippets. The serialization pattern to follow is already present in `LabeledFormula.toJson` (DatasetGenerator.lean lines 810-815). No typeclass or deriving changes are needed.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Add `interestingness_score` and `interestingness_tier` fields to `DatasetRecord`
- Serialize both fields as JSON in `datasetRecordToJson`
- Transfer both fields from `LabeledFormula` in `labeledToRecord`
- Confirm `lake build` succeeds and scores appear in regenerated JSONL output

**Non-Goals**:
- Changing interestingness computation logic
- Modifying any file other than `DatasetExport.lean`
- Adding new tests beyond spot-checking regenerated output

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Field name mismatch (`interestingnessScore` vs snake_case) | M | L | Research confirmed exact field names from `LabeledFormula`; verify at edit time |
| `Inhabited` instance out of sync with struct | M | L | Add fields to both struct and instance in the same edit pass |
| c5 dataset regeneration timeout | L | M | Spot-check first 100 records rather than waiting for full run |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Apply 4 Edits and Build [COMPLETED]

- **Goal:** Make all struct, instance, serialization, and mapping changes in `DatasetExport.lean`, then confirm `lake build` passes.
- **Tasks:**
  - [x] Open `Theories/Bimodal/Automation/DatasetExport.lean` and locate `DatasetRecord` struct (~line 213); add `interestingness_score : Option Nat` and `interestingness_tier : Option String` after `proof_reconstruction_method`
  - [x] Locate the hand-written `Inhabited DatasetRecord` instance (~line 215); add `interestingness_score := none` and `interestingness_tier := none` to the default value
  - [x] Locate `datasetRecordToJson` (~line 268); add `let intScoreStr` and `let intTierStr` bindings (match on `Option`) and append both as JSON fields after existing fields *(deviation: altered -- used inline match expressions instead of let bindings, consistent with existing serialization pattern in the file)*
  - [x] Locate `labeledToRecord` (~line 301); add `interestingness_score := lf.interestingnessScore` and `interestingness_tier := lf.interestingnessTier` to the record body
  - [x] Run `lake build` and confirm zero errors
- **Timing:** 30 minutes
- **Depends on:** none
- **Files to modify:**
  - `Theories/Bimodal/Automation/DatasetExport.lean` — 4 edit points as described above

- **Verification:**
  - `lake build` exits with code 0
  - `grep -n "interestingness_score" Theories/Bimodal/Automation/DatasetExport.lean` returns 4 matches (struct, instance, serializer, mapper)

---

### Phase 2: Regenerate c5 Dataset and Validate [COMPLETED]

- **Goal:** Confirm that `interestingness_score` and `interestingness_tier` appear with non-null values in JSONL output for formulas that have scores computed.
- **Tasks:**
  - [x] Regenerate the c5 dataset (or a small sample) using the existing generation command
  - [x] Spot-check the first 100 JSONL records: verify `"interestingness_score"` and `"interestingness_tier"` keys are present
  - [x] Confirm at least some records have non-null values (i.e., transfer is live, not always `none`)
  - [x] Confirm records with no interestingness computation show `null` for both fields *(deviation: altered -- all 395 records had non-null values since interestingness is always computed during labeling)*
- **Timing:** 30 minutes
- **Depends on:** 1
- **Files to modify:** None (read-only validation)

- **Verification:**
  - At least one JSONL record contains `"interestingness_score": <integer>` and `"interestingness_tier": "<string>"`
  - No build errors introduced by the changes

---

## Testing & Validation

- [ ] `lake build` exits clean after Phase 1 edits
- [ ] Regenerated JSONL contains `interestingness_score` and `interestingness_tier` keys in every record
- [ ] Non-null values appear for formulas that had scores computed
- [ ] Null values appear for formulas without scores (graceful degradation confirmed)

## Artifacts & Outputs

- `specs/269_export_interestingness_scores_to_jsonl/plans/01_implementation-plan.md` (this file)
- Modified: `Theories/Bimodal/Automation/DatasetExport.lean`
- `specs/269_export_interestingness_scores_to_jsonl/summaries/01_export-fix-summary.md` (post-implementation)

## Rollback/Contingency

All changes are confined to a single file (`DatasetExport.lean`). If the build fails or produces unexpected output, revert with `git checkout -- Theories/Bimodal/Automation/DatasetExport.lean`. No schema migrations or generated file changes need to be rolled back independently.
