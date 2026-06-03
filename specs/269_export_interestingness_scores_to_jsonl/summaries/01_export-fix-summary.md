# Implementation Summary: Export Interestingness Scores to JSONL

- **Task**: 269 - Export interestingness scores from DatasetRecord to JSONL output
- **Status**: Implemented
- **Session**: sess_1748995200_h0j4e8

## Changes

All changes confined to `Theories/Bimodal/Automation/DatasetExport.lean`:

1. **DatasetRecord struct** (line 214-216): Added `interestingness_score : Option Nat := none` and `interestingness_tier : Option String := none` fields after `proof_reconstruction_method`
2. **Inhabited instance** (line 245-246): Added `interestingness_score := none` and `interestingness_tier := none` defaults
3. **datasetRecordToJson** (line 302-307): Added JSON serialization for both fields using inline match pattern (null for None, value for Some)
4. **labeledToRecord** (line 341-342): Added field mapping from `lf.interestingnessScore` and `lf.interestingnessTier`

## Verification

- `lake build` passes (1682 jobs, zero errors)
- Regenerated c5 dataset: 395 records, all with non-null interestingness values
- Tier distribution: trivial (216), routine (170), basic (5), moderate (4)
- Score range: 0-366 (mean 62.7)
- Zero sorries, zero vacuous definitions, no new axioms

## Plan Deviations

- Phase 1 Task 3: Used inline match expressions for serialization instead of let bindings (matches existing codebase style)
- Phase 2 Task 4: All records had non-null values (interestingness is always computed during labeling, so null case was not observed)

## Artifacts

- Modified: `Theories/Bimodal/Automation/DatasetExport.lean`
- Regenerated: `data/bmlogic-c5.jsonl` (395 records with interestingness fields)
- Regenerated: `data/bmlogic-c5_metadata.json`
