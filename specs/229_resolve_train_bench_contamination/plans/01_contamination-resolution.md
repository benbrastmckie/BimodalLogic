# Implementation Plan: Task #229

- **Task**: 229 - Resolve train/benchmark formula contamination
- **Status**: [IN PROGRESS]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/229_resolve_train_bench_contamination/reports/01_train-bench-contamination.md
- **Artifacts**: plans/01_contamination-resolution.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

This plan implements Option B from the contamination research: adding a `contamination_flag` boolean field to all 777 benchmark records in `bmlogic-bench.jsonl`, indicating whether each formula appears verbatim in the `bmlogic-c7.jsonl` training set. The approach preserves all existing record IDs, splits, and downstream structure while transparently flagging the 553 contaminated records (71.2%). All downstream artifacts (metadata, splits, croissant schema, dataset card, HF copy) will be updated to reflect the new field and document the contamination analysis.

### Research Integration

The research report (01_train-bench-contamination.md) confirmed the contamination claim precisely: 553/777 benchmark formulas are in the c7 training set. The root cause is structural (c7 is an exhaustive enumeration up to complexity 7, so any benchmark formula sampled from that range is necessarily duplicated). The report evaluated four options (A: trim, B: flag, C: remove from training, D: regenerate) and recommended Option B as the lowest-risk immediate fix. Key quantitative findings (per-split contamination rates, difficulty tier skew of held-out records, stale splits count of 727) are all integrated into the phase tasks below.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Add `contamination_flag: bool` field to all 777 benchmark records
- Fix the stale `total_records` count in `bmlogic-bench-splits.json` (727 -> 777)
- Update `croissant.json` schema to document the new field
- Add a contamination analysis section to `data/dataset-card.md`
- Sync `data/hf-dataset/data/bmlogic-bench.jsonl` with the updated benchmark
- Update `data/hf-dataset/README.md` with contamination documentation
- Update `data/bmlogic-bench_metadata.json` with contamination statistics

**Non-Goals**:
- Regenerating the benchmark from scratch (Option D, deferred to a follow-up task)
- Removing formulas from the c7 training set (Option C, ruled out by research)
- Generating NL paraphrases (tracked separately in task 230)
- Modifying any training data files (`bmlogic-c5.jsonl`, `bmlogic-c7.jsonl`)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Formula string comparison mismatches due to whitespace/encoding differences | H | L | Use exact same `formula_str` field comparison as research verification script; validate count matches 553 |
| Stale splits regeneration changes split assignments | M | L | Re-run `generate_splits.py` and verify split counts match research report values before committing |
| Croissant schema update breaks HF dataset validation | M | L | Run `data/hf-dataset/validate.py` after all updates to verify schema consistency |
| HF README formatting diverges from dataset-card.md | L | M | Copy relevant contamination section from dataset-card.md to keep both in sync |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Add contamination_flag to benchmark records [COMPLETED]

**Goal**: Create a Python script that loads c7 training formulas, compares against benchmark records, and writes an updated `bmlogic-bench.jsonl` with the `contamination_flag` boolean field added to every record.

**Tasks**:
- [x] Create `data/scripts/add_contamination_flag.py` script *(completed)*
  - Load all `formula_str` values from `data/bmlogic-c7.jsonl` into a set
  - Read each record from `data/bmlogic-bench.jsonl`
  - Add `contamination_flag: true` if `formula_str` is in the c7 set, `false` otherwise
  - Write updated records to `data/bmlogic-bench.jsonl` (overwrite in place)
  - Print summary statistics (total, flagged true, flagged false) for verification
- [x] Run the script and verify output: *(completed: 553/777 contaminated, 224/777 held-out)*
  - Confirmed 553 records have `contamination_flag: true`
  - Confirmed 224 records have `contamination_flag: false`
  - Confirmed total record count remains 777
- [x] Verify no fields were lost or reordered *(completed: all 15 fields present in every record)*

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `data/scripts/add_contamination_flag.py` - New script
- `data/bmlogic-bench.jsonl` - Add `contamination_flag` field to all 777 records

**Verification**:
- Script prints `553/777 contaminated, 224/777 held-out`
- Every record in output JSONL has exactly the expected fields plus `contamination_flag`
- Record count unchanged at 777

---

### Phase 2: Update metadata, splits, and croissant schema [NOT STARTED]

**Goal**: Update all JSON metadata artifacts to reflect the new `contamination_flag` field and fix the stale splits count.

**Tasks**:
- [ ] Update `data/bmlogic-bench_metadata.json`:
  - Add a `contamination_analysis` section with fields: `training_set` ("bmlogic-c7.jsonl"), `overlap_count` (553), `held_out_count` (224), `overlap_percentage` (71.2), `resolution` ("contamination_flag field added"), `analysis_date`
  - Add `contamination_flag` to any field-listing or schema section if present
- [ ] Fix `data/bmlogic-bench-splits.json`:
  - Re-run `python data/scripts/generate_splits.py` to regenerate with correct total_records (777)
  - If script is not runnable or produces errors, manually update `total_records` from 727 to 777 and verify split record counts
  - Verify the four splits (propositional-only, modal-only, temporal-only, bimodal) have correct record counts
- [ ] Update `data/croissant.json`:
  - Add `contamination_flag` field definition to the benchmark record set schema (`cr:recordSet`)
  - Field type: boolean, description: "Whether this formula appears verbatim in the bmlogic-c7 training set"

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `data/bmlogic-bench_metadata.json` - Add contamination analysis section
- `data/bmlogic-bench-splits.json` - Fix stale total_records count
- `data/croissant.json` - Add contamination_flag field to schema

**Verification**:
- `bmlogic-bench_metadata.json` parses as valid JSON with `contamination_analysis` section
- `bmlogic-bench-splits.json` shows `total_records: 777`
- `croissant.json` parses as valid JSON with `contamination_flag` in the benchmark record set

---

### Phase 3: Update dataset card documentation [NOT STARTED]

**Goal**: Add a contamination analysis section to the dataset card explaining the overlap, its root cause, the resolution, and usage guidance for filtering.

**Tasks**:
- [ ] Add "Contamination Analysis" section to `data/dataset-card.md`:
  - Explain the structural overlap: c7 is exhaustive up to complexity 7, so benchmark formulas in that range are necessarily duplicated
  - Report key numbers: 553/777 (71.2%) contaminated, 224/777 (28.8%) held-out
  - Per-split breakdown table (from research: propositional-only 72/97, modal-only 101/144, temporal-only 176/247, bimodal 162/239)
  - Explain the `contamination_flag` field and its meaning
  - Add usage example: filtering benchmark to held-out records only
  - Note that axiom instances are almost entirely held-out (59/60 = 98.3%)
- [ ] Add a brief contamination note to the "Benchmark" subsection if one exists, cross-referencing the full analysis section
- [ ] Review the dataset card for any stale record counts or claims that need updating

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `data/dataset-card.md` - Add contamination analysis section

**Verification**:
- Dataset card contains "Contamination Analysis" section with correct statistics
- Usage example for filtering is syntactically correct Python/pandas
- No contradictory claims elsewhere in the document

---

### Phase 4: Sync HF dataset and validate [NOT STARTED]

**Goal**: Copy the updated benchmark to the HF dataset directory, update the HF README with contamination documentation, and run validation to ensure consistency.

**Tasks**:
- [ ] Copy updated `data/bmlogic-bench.jsonl` to `data/hf-dataset/data/bmlogic-bench.jsonl`
- [ ] Update `data/hf-dataset/README.md`:
  - Add contamination analysis section (mirroring or referencing dataset-card.md content)
  - Ensure field documentation includes `contamination_flag`
- [ ] Run validation if available:
  - `python data/hf-dataset/validate.py` to check dataset consistency
  - If validation script does not cover the new field, verify manually that all HF benchmark records have `contamination_flag`
- [ ] Final verification pass:
  - Confirm `data/hf-dataset/data/bmlogic-bench.jsonl` has 777 records with `contamination_flag`
  - Confirm all JSON files parse without errors
  - Run a quick diff between `data/bmlogic-bench.jsonl` and `data/hf-dataset/data/bmlogic-bench.jsonl` to confirm they are identical

**Timing**: 30 minutes

**Depends on**: 2, 3

**Files to modify**:
- `data/hf-dataset/data/bmlogic-bench.jsonl` - Sync updated benchmark
- `data/hf-dataset/README.md` - Add contamination documentation

**Verification**:
- HF benchmark file is byte-identical to source benchmark file
- `validate.py` passes (or manual validation confirms field presence)
- HF README documents the `contamination_flag` field and contamination analysis

## Testing & Validation

- [ ] Contamination flag counts match research findings: 553 true, 224 false, 777 total
- [ ] Per-split contamination rates match research (propositional-only: 72/97, modal-only: 101/144, temporal-only: 176/247, bimodal: 162/239)
- [ ] No benchmark records lost or duplicated (count remains 777, all IDs preserved)
- [ ] All original fields preserved in updated JSONL (no field loss or reordering)
- [ ] `bmlogic-bench-splits.json` total_records corrected to 777
- [ ] `croissant.json` includes `contamination_flag` field definition
- [ ] `bmlogic-bench_metadata.json` includes `contamination_analysis` section
- [ ] HF dataset copy is byte-identical to source
- [ ] All JSON files parse without errors
- [ ] Dataset card and HF README contain contamination documentation with correct statistics

## Artifacts & Outputs

- `data/scripts/add_contamination_flag.py` - Contamination flagging script (new)
- `data/bmlogic-bench.jsonl` - Updated with `contamination_flag` field
- `data/bmlogic-bench_metadata.json` - Updated with contamination analysis
- `data/bmlogic-bench-splits.json` - Fixed stale total_records
- `data/croissant.json` - Updated schema with new field
- `data/dataset-card.md` - Updated with contamination analysis section
- `data/hf-dataset/data/bmlogic-bench.jsonl` - Synced HF copy
- `data/hf-dataset/README.md` - Updated with contamination documentation
- `specs/229_resolve_train_bench_contamination/plans/01_contamination-resolution.md` - This plan

## Rollback/Contingency

All modified data files are tracked in git. If the implementation introduces errors:
1. `git checkout -- data/bmlogic-bench.jsonl` to restore original benchmark
2. `git checkout -- data/bmlogic-bench_metadata.json data/bmlogic-bench-splits.json data/croissant.json` to restore metadata
3. `git checkout -- data/dataset-card.md data/hf-dataset/` to restore documentation

The contamination flagging script (`add_contamination_flag.py`) is idempotent and can be re-run safely. The script is additive (only adds a field, never removes data), so partial runs do not corrupt the benchmark.
