# Implementation Plan: Task #228

- **Task**: 228 - Fix all stale metadata and documentation across data/
- **Status**: [IN PROGRESS]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/228_fix_dataset_metadata_staleness/reports/01_metadata-staleness-audit.md
- **Artifacts**: plans/01_fix-metadata-staleness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Fix all stale metadata values and documentation across 6 files in data/. The research audit verified every reported discrepancy against ground truth from JSONL files and identified the complete change inventory. All changes are mechanical edits with known correct values -- no structural changes to data files, no code modifications, and no schema migrations. License will be standardized to CC BY 4.0 (matching the authoritative HuggingFace publishing artifacts).

### Research Integration

Key findings from the audit report (01_metadata-staleness-audit.md):
- proof_steps_metadata.json has 9 stale numeric fields (total_records, theorem_count, all rule_distribution values, avg/max steps)
- bmlogic-bench_metadata.json uses `total_count` instead of `total_records` (inconsistent with all other metadata files); value 777 is correct
- data/README.md has 4 stale record counts (727 and 2424 in various locations)
- data/dataset-card.md has stale overview table, stale proof steps statistics, and says "14 fields" when actual training schema has 16 (missing max_modal_depth, max_temporal_depth)
- License is split: dataset-card.md YAML says `mit`, while croissant.json and hf-dataset/README.md use CC BY 4.0. Recommendation: CC BY 4.0 everywhere
- `total_count` key is only referenced in bmlogic-bench_metadata.json itself (grep confirmed), so rename is safe

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Update all stale numeric values in proof_steps_metadata.json to match JSONL ground truth
- Standardize key naming (total_count -> total_records) in bmlogic-bench_metadata.json
- Fix all stale record counts in data/README.md
- Update dataset-card.md overview table, proof steps statistics, and training schema table (14 -> 16 fields)
- Resolve license inconsistency by standardizing on CC BY 4.0 across all files
- Add missing license field to bmlogic-bench_metadata.json

**Non-Goals**:
- Updating bmlogic-bench-splits.json (still shows 727; out of scope, tracked by task 230)
- Fixing benchmark schema field count discrepancy in dataset-card.md (13 vs 14 vs 15; pre-existing, not in task scope)
- Updating croissant.json SHA-256 hashes or contentSize (tracked by task 227/231)
- Modifying any JSONL data files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Incorrect ground truth values | H | L | Values verified by Python analysis in research report; re-verify with wc -l and jq before editing |
| Breaking downstream tooling with total_count rename | M | L | Grep confirmed total_count only in bmlogic-bench_metadata.json itself |
| Missing update locations | M | L | Research report provides exhaustive file-by-file change inventory with line numbers |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Update metadata JSON files [COMPLETED]

**Goal**: Fix all stale values in the 4 metadata JSON files and standardize key naming.

**Tasks**:
- [x] Update proof_steps_metadata.json: total_records 2424->10063, theorem_count 36->310 *(completed)*
- [x] Update proof_steps_metadata.json: rule_distribution (axiom:4635, modus_ponens:4325, temporal_necessitation:991, temporal_duality:63, necessitation:49) *(completed)*
- [x] Update proof_steps_metadata.json: step_statistics (avg 32.5, max 327, min 1 unchanged) *(completed)*
- [x] Update proof_steps_metadata.json: license "MIT" -> "CC BY 4.0" *(completed)*
- [x] Update bmlogic-bench_metadata.json: rename key total_count -> total_records (value 777 unchanged) *(completed)*
- [x] Update bmlogic-bench_metadata.json: add "license": "CC BY 4.0" field *(completed)*
- [x] Update bmlogic-c5_metadata.json: license "MIT" -> "CC BY 4.0" *(completed)*
- [x] Update bmlogic-c7_metadata.json: license "MIT" -> "CC BY 4.0" *(completed)*

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `data/proof_steps_metadata.json` - Update 9 stale numeric values + license
- `data/bmlogic-bench_metadata.json` - Rename key + add license field
- `data/bmlogic-c5_metadata.json` - License update only
- `data/bmlogic-c7_metadata.json` - License update only

**Verification**:
- All metadata JSON files parse as valid JSON (python3 -m json.tool)
- proof_steps_metadata.json total_records matches `wc -l data/proof_steps.jsonl`
- bmlogic-bench_metadata.json uses total_records key (not total_count)
- All 4 metadata files have license: "CC BY 4.0"
- No other metadata files reference total_count (grep -r "total_count" data/)

---

### Phase 2: Update documentation files [NOT STARTED]

**Goal**: Fix all stale record counts and schema documentation in README.md and dataset-card.md.

**Tasks**:
- [ ] Update data/README.md file inventory table: bmlogic-bench.jsonl 727->777, proof_steps.jsonl 2424->10063
- [ ] Update data/README.md: bmlogic-bench-splits.json description "4 slices, 727 records" -> "4 slices, 777 records"
- [ ] Update data/README.md: NL paraphrase section "all 727 records" -> "all 777 records"
- [ ] Update data/dataset-card.md YAML frontmatter: license: mit -> license: cc-by-4.0
- [ ] Update data/dataset-card.md overview table: bmlogic-bench.jsonl 727->777, proof_steps.jsonl 2424->10063
- [ ] Update data/dataset-card.md proof steps section: records 2424->10063, theorems 36->310
- [ ] Update data/dataset-card.md proof steps section: rule distribution (5 values)
- [ ] Update data/dataset-card.md proof steps section: steps per theorem (max 325->327, avg 67.3->32.5)
- [ ] Update data/dataset-card.md: training schema table header "14 fields" -> "16 fields"
- [ ] Update data/dataset-card.md: prose references "14-field schema" -> "16-field schema" (two occurrences)
- [ ] Add max_modal_depth and max_temporal_depth rows to training schema table in dataset-card.md
- [ ] Update data/dataset-card.md Croissant section body text: "license (MIT)" -> "license (CC BY 4.0)"

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `data/README.md` - Fix 4 stale record counts
- `data/dataset-card.md` - Fix overview table, proof steps statistics, training schema, license references

**Verification**:
- No occurrences of "727" remain in data/README.md (except bmlogic-bench-splits.json internal references which are out of scope)
- No occurrences of "2,424" or "2424" remain in data/README.md or data/dataset-card.md
- Training schema table in dataset-card.md has 16 rows (or says "16 fields")
- max_modal_depth and max_temporal_depth appear in the schema table
- grep for "MIT" and "mit" in dataset-card.md returns no hits

---

### Phase 3: Cross-file verification and consistency check [NOT STARTED]

**Goal**: Verify all changes are internally consistent across all 6 files and no stale values remain.

**Tasks**:
- [ ] Run verification: grep for known stale values (727, 2424, "14 fields", "MIT") across all data/ files
- [ ] Verify all JSON files are valid (python3 -m json.tool on each)
- [ ] Verify license consistency: all files referencing license say CC BY 4.0 or cc-by-4.0
- [ ] Verify total_records key consistency: no metadata file uses total_count
- [ ] Run quick sanity check: wc -l on JSONL files matches metadata total_records values

**Timing**: 15 minutes

**Depends on**: 1, 2

**Files to modify**:
- None (verification only; fix any issues found by editing the files from Phases 1-2)

**Verification**:
- All grep checks pass (no stale values found)
- All JSON files parse without error
- License is CC BY 4.0 in: proof_steps_metadata.json, bmlogic-bench_metadata.json, bmlogic-c5_metadata.json, bmlogic-c7_metadata.json, dataset-card.md YAML, dataset-card.md body
- croissant.json and hf-dataset/README.md already use CC BY 4.0 (no changes needed, just confirm)

## Testing & Validation

- [ ] All 4 metadata JSON files parse as valid JSON
- [ ] proof_steps_metadata.json total_records = 10063 (matches wc -l data/proof_steps.jsonl)
- [ ] bmlogic-bench_metadata.json total_records = 777 (matches wc -l data/bmlogic-bench.jsonl)
- [ ] No metadata file uses "total_count" key
- [ ] License is "CC BY 4.0" or "cc-by-4.0" in all 6 files that reference license
- [ ] Training schema table in dataset-card.md documents 16 fields including max_modal_depth and max_temporal_depth
- [ ] No occurrences of stale values (727, 2424, "14 fields") remain in data/README.md or data/dataset-card.md

## Artifacts & Outputs

- plans/01_fix-metadata-staleness.md (this plan)
- summaries/01_fix-metadata-staleness-summary.md (post-implementation)
- 6 modified files in data/: proof_steps_metadata.json, bmlogic-bench_metadata.json, bmlogic-c5_metadata.json, bmlogic-c7_metadata.json, README.md, dataset-card.md

## Rollback/Contingency

All changes are to tracked files in git. Rollback via `git checkout -- data/proof_steps_metadata.json data/bmlogic-bench_metadata.json data/bmlogic-c5_metadata.json data/bmlogic-c7_metadata.json data/README.md data/dataset-card.md`. No structural changes, so partial rollback of individual files is also safe.
