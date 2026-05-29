# Implementation Plan: Task #214 (v2)

- **Task**: 214 - Dataset cleanup, standardization, and documentation
- **Status**: [NOT STARTED]
- **Effort**: 4.5 hours
- **Dependencies**: Task 213 (completed)
- **Research Inputs**: specs/214_dataset_cleanup_documentation/reports/01_team-research.md, specs/214_dataset_cleanup_documentation/reports/02_task-213-impact.md
- **Artifacts**: plans/02_dataset-cleanup-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The data/ directory contains 20 files produced by 3 generation pipelines (training, benchmark, proof-steps). Task 213 completed and generated two new canonical training datasets -- bmlogic-c5.jsonl (1,513 records, complexity 5, exhaustive) and bmlogic-c7.jsonl (49,904 records, complexity 7, exhaustive) -- with a richer 14-field schema including `formula_sexpr`, `formula_tokens`, and `pattern_features`. These supersede the older bmlogic-medium.jsonl and bmlogic-deep.jsonl, which lack multi-representation fields and used the older pipeline. This plan covers: updating script default paths, deleting superseded and intermediate files, Git LFS setup and gitignore rewrite, metadata standardization, README creation, and schema validation.

### Research Integration

Two research reports were integrated into this plan:
- **01_team-research.md** (4-teammate synthesis): Established the overall cleanup strategy -- common metadata header with dataset-specific extensions, Git LFS for large files, HuggingFace-compatible README, flat directory structure, specific-intermediate gitignore pattern.
- **02_task-213-impact.md** (follow-up): Identified that task 213 generated c5/c7 datasets that supersede medium/deep, that the `representations` field is now accurate in c5/c7 metadata (no removal needed), and that three Python scripts plus one shell script hardcode medium/deep paths requiring updates before deletion.

### Prior Plan Reference

The prior plan (01_dataset-cleanup-plan.md) correctly anticipated the overall phase structure (audit/clean, LFS/gitignore, metadata, README, validation) but left the medium/deep vs c5/c7 disposition as an open question. The follow-up research resolved this definitively: delete both medium and deep, keep c5 and c7 as canonical replacements. The prior plan also missed the script default path updates as an explicit dependency. Effort calibration from the prior plan (5 hours) was reasonable; this revision tightens to 4.5 hours by simplifying the metadata phase (no need to remove representations).

### Roadmap Alignment

No specific ROADMAP.md items reference dataset cleanup directly. This task supports the broader "Phase 5 -- Publication quality" goals (task 95, task 8) and future HuggingFace publication (task 208).

## Goals & Non-Goals

**Goals**:
- Update Python/shell script defaults from medium/deep to c5/c7 before deleting old files
- Remove 11 files: 4 superseded datasets (medium, deep + metadata), 3 benchmark intermediates, 4 test files
- Install Git LFS and configure tracking for files >10MB (c7 ~53MB, proof_steps ~15MB)
- Rewrite data/.gitignore to list specific intermediates instead of blanket exclusion
- Enrich c5/c7 metadata with common header fields (dataset_name, version, description, generation_date, schema_version)
- Create proof_steps_metadata.json with step-level statistics
- Create data/README.md documenting all final datasets with schemas, generation commands, and purpose
- Verify record schema consistency across all kept datasets

**Non-Goals**:
- Modifying Lean DatasetMetadata struct or DatasetExport.lean (use Python scripts instead)
- Creating subdirectory-per-dataset structure (flat is sufficient for 4 datasets)
- Croissant 1.1 JSON-LD metadata
- HuggingFace Hub publication (task 208)
- JSON Schema validation files
- Adding SHA-256 checksums (future enhancement)
- Improving valid fraction percentages (3-4% is documented, not fixed here)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Scripts break when medium/deep deleted | H | H (confirmed: 4 scripts reference them) | Phase 1 updates all script defaults BEFORE any file deletion |
| Git LFS not available on system | H | H (confirmed not installed) | Phase 2 includes installation; if system constraints prevent it, keep large files gitignored with documentation |
| c5 is smaller than medium (1,513 vs 5,136 records) | L | L | Document in README; c5 represents exhaustive coverage of complexity-5 space, not a sampling shortfall |
| Metadata enrichment corrupts existing files | M | L | Back up metadata files before modification; validate after changes |
| Benchmark pipeline needs regeneration from c5/c7 | M | L | Verify bmlogic-bench.jsonl is already final and stable before deleting source training data |
| ID conflicts between c5 and c7 (both start at bmlogic-00001) | L | L | Document in README as expected behavior; IDs are sequential within each file |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases are sequential because each builds on the file state established by the previous phase.

---

### Phase 1: Update Scripts and Clean Up Files [COMPLETED]

**Goal**: Update all script default paths from medium/deep to c5/c7, then remove superseded datasets, intermediate pipeline artifacts, and test files.

**Tasks**:
- [x] Update `scripts/curate_benchmark.py`: change `--medium` default from `data/bmlogic-medium.jsonl` to `data/bmlogic-c5.jsonl`, change `--deep` default from `data/bmlogic-deep.jsonl` to `data/bmlogic-c7.jsonl`, update docstring references *(completed)*
- [x] Update `scripts/validate_benchmark.py`: change `--production-medium` default to `data/bmlogic-c5.jsonl`, change `--production-deep` default to `data/bmlogic-c7.jsonl` *(completed)*
- [x] Update `scripts/verify_benchmark.py`: change `medium_path` default to `data/bmlogic-c5.jsonl`, change `deep_path` default to `data/bmlogic-c7.jsonl` *(completed)*
- [x] Update `scripts/run_dataset_generation.sh`: update output paths and comments from medium/deep to c5/c7, update complexity parameters to match c5 (max_complexity=5) and c7 (max_complexity=7) with exhaustive mode *(completed)*
- [x] Delete superseded datasets: `data/bmlogic-deep.jsonl`, `data/bmlogic-deep_metadata.json`, `data/bmlogic-medium.jsonl`, `data/bmlogic-medium_metadata.json` *(completed)*
- [x] Delete intermediate pipeline artifacts: `data/axiom-instances.jsonl`, `data/bmlogic-bench-candidates.jsonl`, `data/bmlogic-bench-validated.jsonl` *(completed)*
- [x] Delete test files: `data/test.jsonl`, `data/test_c4.jsonl`, `data/test_metadata.json`, `data/test_c4_metadata.json` *(completed)*
- [x] Verify no other scripts reference deleted filenames: `grep -r 'bmlogic-medium\|bmlogic-deep\|axiom-instances\|bench-candidates\|bench-validated\|test\.jsonl\|test_c4' scripts/` *(completed)*

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `scripts/curate_benchmark.py` - Update default paths and docstring
- `scripts/validate_benchmark.py` - Update default paths
- `scripts/verify_benchmark.py` - Update default paths
- `scripts/run_dataset_generation.sh` - Update output paths, complexity params, comments
- `data/bmlogic-deep.jsonl` - DELETE
- `data/bmlogic-deep_metadata.json` - DELETE
- `data/bmlogic-medium.jsonl` - DELETE
- `data/bmlogic-medium_metadata.json` - DELETE
- `data/axiom-instances.jsonl` - DELETE
- `data/bmlogic-bench-candidates.jsonl` - DELETE
- `data/bmlogic-bench-validated.jsonl` - DELETE
- `data/test.jsonl` - DELETE
- `data/test_c4.jsonl` - DELETE
- `data/test_metadata.json` - DELETE
- `data/test_c4_metadata.json` - DELETE

**Verification**:
- `ls data/` shows only: bmlogic-bench.jsonl, bmlogic-bench_metadata.json, bmlogic-c5.jsonl, bmlogic-c5_metadata.json, bmlogic-c7.jsonl, bmlogic-c7_metadata.json, proof_steps.jsonl, .gitignore
- `grep -r 'bmlogic-medium\|bmlogic-deep' scripts/` returns nothing
- `python3 -c "import scripts.curate_benchmark"` does not error on missing defaults

---

### Phase 2: Install Git LFS and Rewrite .gitignore [COMPLETED]

**Goal**: Set up Git LFS for large files and rewrite .gitignore to track final datasets while excluding only regenerable intermediates by name.

**Tasks**:
- [x] Check if Git LFS is available (`git lfs version`) and install if needed (e.g., `nix-env -iA nixpkgs.git-lfs` or system package manager) *(completed: installed via nix profile, version 3.7.1)*
- [x] Initialize Git LFS in the repository (`git lfs install`) *(deviation: altered — used --local flag due to read-only global config)*
- [x] Track large JSONL files with Git LFS: `bmlogic-c7.jsonl` (~53MB) and `proof_steps.jsonl` (~15MB) *(completed)*
- [x] Rewrite `data/.gitignore` to list specific intermediate filenames to ignore (not blanket patterns): axiom-instances.jsonl, bmlogic-bench-candidates.jsonl, bmlogic-bench-validated.jsonl, test*.jsonl, test*_metadata.json *(completed)*
- [x] Create or update `.gitattributes` with LFS tracking patterns for large datasets *(completed)*
- [x] Verify `git status` shows final datasets as trackable (not ignored) *(completed)*

**Timing**: 0.75 hours

**Depends on**: 1

**Files to modify**:
- `data/.gitignore` - REWRITE: replace blanket exclusion with specific intermediate filenames
- `.gitattributes` - CREATE or MODIFY: add LFS tracking patterns

**Verification**:
- `git lfs version` returns a version
- `git check-ignore data/bmlogic-bench.jsonl` returns nothing (not ignored)
- `git check-ignore data/bmlogic-c5.jsonl` returns nothing (not ignored)
- `git check-ignore data/bmlogic-c7.jsonl` returns nothing (not ignored)
- `git check-ignore data/proof_steps.jsonl` returns nothing (not ignored)
- `git lfs track` shows c7 and proof_steps patterns

---

### Phase 3: Standardize and Create Metadata [NOT STARTED]

**Goal**: Enrich c5/c7 metadata with common header fields and create proof_steps_metadata.json. The `representations` array in c5/c7 metadata is accurate and should be preserved.

**Tasks**:
- [ ] Define common metadata header schema: dataset_name, version, description, generation_date, schema_version, frame_class, total_records
- [ ] Create `scripts/standardize_metadata.py` to:
  - Read each metadata file
  - Add missing common header fields (dataset_name, version, description, generation_date, schema_version)
  - Preserve ALL existing fields including accurate `representations` array in c5/c7
  - Write back with consistent JSON formatting (sorted keys, 2-space indent)
- [ ] Run the script to enrich `data/bmlogic-c5_metadata.json` and `data/bmlogic-c7_metadata.json`
- [ ] Create `data/proof_steps_metadata.json` by scanning proof_steps.jsonl for statistics: total_records, theorem_count, rule_distribution, step_statistics (avg/max steps per theorem)
- [ ] Validate that all metadata files are valid JSON with consistent field ordering

**Timing**: 1.25 hours

**Depends on**: 2

**Files to modify**:
- `scripts/standardize_metadata.py` - CREATE: metadata enrichment script
- `data/bmlogic-c5_metadata.json` - ENRICH: add common header fields
- `data/bmlogic-c7_metadata.json` - ENRICH: add common header fields
- `data/proof_steps_metadata.json` - CREATE: new metadata file for proof steps dataset

**Verification**:
- All metadata files have dataset_name, version, description, generation_date, schema_version
- `data/proof_steps_metadata.json` exists with correct record count (2,424) and rule distribution
- c5/c7 metadata retains `representations` array (confirmed accurate)
- `python3 -c "import json; json.load(open('data/bmlogic-c5_metadata.json'))"` succeeds
- `python3 -c "import json; json.load(open('data/bmlogic-c7_metadata.json'))"` succeeds
- `python3 -c "import json; json.load(open('data/proof_steps_metadata.json'))"` succeeds

---

### Phase 4: Create data/README.md [NOT STARTED]

**Goal**: Write comprehensive documentation for the data/ directory in HuggingFace dataset card format, documenting the canonical c5/c7/bench/proof_steps inventory.

**Tasks**:
- [ ] Create `data/README.md` with YAML frontmatter (HuggingFace dataset card format)
- [ ] Document each dataset with purpose, record count, and schema:
  - bmlogic-bench.jsonl (727 records) -- benchmark evaluation set, 13-field schema
  - bmlogic-c5.jsonl (1,513 records) -- small training set, complexity 5, exhaustive, 14-field schema
  - bmlogic-c7.jsonl (49,904 records) -- large training set, complexity 7, exhaustive, 14-field schema
  - proof_steps.jsonl (2,424 records) -- proof step records, 8-field schema
- [ ] Document the three generation pipelines with regeneration commands
- [ ] Include field-level schema tables for each dataset type (training 14-field, benchmark 13-field, proof-steps 8-field)
- [ ] Document the metadata schema (common header + dataset-specific extensions)
- [ ] Add a "Dataset Relationships" section explaining c5/c7/bench progression and that c5/c7 replaced medium/deep
- [ ] Note file sizes, Git LFS tracking status, and ID scheme (sequential within each file, not globally unique)
- [ ] Design record counts as "as of generation date" to handle future regeneration gracefully

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `data/README.md` - CREATE: comprehensive dataset documentation

**Verification**:
- README.md exists and is valid Markdown
- Each kept dataset is documented with schema, purpose, and generation command
- Record counts match actual JSONL line counts (spot-check with `wc -l`)
- YAML frontmatter is valid

---

### Phase 5: Schema Validation and Final Verification [NOT STARTED]

**Goal**: Verify all datasets have consistent field schemas matching the documented specifications and all deliverables are complete.

**Tasks**:
- [ ] Write `scripts/validate_datasets.py` that:
  - Reads first and last record of each JSONL file
  - Verifies training records (c5, c7) have 14 expected fields: id, split, formula_str, formula_ast, frame_class, label, proof_trace, countermodel, pattern_key, metrics, augmentation, formula_sexpr, formula_tokens, pattern_features
  - Verifies benchmark records have 13 expected fields
  - Verifies proof_steps records have 8 expected fields
  - Cross-checks metadata record counts against actual JSONL line counts
  - Reports any schema inconsistencies
- [ ] Run validation script and fix any issues found
- [ ] Verify .gitignore correctly excludes intermediates but not finals
- [ ] Verify Git LFS is tracking the correct files
- [ ] Final audit: confirm data/ directory matches target structure from README

**Timing**: 0.5 hours

**Depends on**: 4

**Files to modify**:
- `scripts/validate_datasets.py` - CREATE: dataset schema validation script
- Any files needing fixes discovered during validation

**Verification**:
- Validation script reports zero errors
- `git check-ignore` confirms correct ignore behavior for all final datasets
- `git lfs ls-files` shows large datasets tracked by LFS
- data/ directory contains exactly 9 files: 4 JSONL datasets, 4 metadata files, .gitignore
- README.md documents the same file inventory

---

## Testing & Validation

- [ ] All 11 intermediate/test/superseded files deleted from data/
- [ ] All 4 script files updated with c5/c7 defaults (no remaining medium/deep references)
- [ ] All kept datasets are valid JSONL (each line parses as JSON)
- [ ] All metadata files are valid JSON with common header fields
- [ ] proof_steps_metadata.json exists with accurate statistics
- [ ] data/.gitignore excludes intermediates, allows finals
- [ ] Git LFS tracks files >10MB (c7 and proof_steps)
- [ ] data/README.md documents all 4 datasets accurately
- [ ] No broken script references to deleted files
- [ ] Validation script passes with zero errors

## Artifacts & Outputs

- `data/README.md` - Comprehensive dataset documentation
- `data/proof_steps_metadata.json` - New metadata for proof steps dataset
- `data/.gitignore` - Rewritten to list specific exclusions
- `data/bmlogic-c5_metadata.json` - Enriched with common header fields
- `data/bmlogic-c7_metadata.json` - Enriched with common header fields
- `.gitattributes` - LFS tracking configuration
- `scripts/standardize_metadata.py` - Metadata enrichment script
- `scripts/validate_datasets.py` - Dataset validation script
- `scripts/curate_benchmark.py` - Updated default paths (c5/c7)
- `scripts/validate_benchmark.py` - Updated default paths (c5/c7)
- `scripts/verify_benchmark.py` - Updated default paths (c5/c7)
- `scripts/run_dataset_generation.sh` - Updated output paths and parameters (c5/c7)
- `specs/214_dataset_cleanup_documentation/plans/02_dataset-cleanup-plan.md` - This plan

## Rollback/Contingency

All deleted files are regenerable via documented pipeline commands:
- Training data (c5): `lake exe dataset_generator --max_complexity 5 --sampling_mode exhaustive --output data/bmlogic-c5.jsonl`
- Training data (c7): `lake exe dataset_generator --max_complexity 7 --sampling_mode exhaustive --output data/bmlogic-c7.jsonl`
- Benchmark: `lake exe benchmark_anchors` -> `scripts/curate_benchmark.py` -> `lake exe benchmark_oracle` -> `scripts/finalize_benchmark.py`
- Proof steps: `lake exe proof_extractor`
- Intermediates: `lake exe benchmark_anchors` (axiom-instances), pipeline stages (candidates, validated)

If metadata enrichment corrupts files, original metadata can be recovered from git history. If Git LFS causes issues, LFS tracking can be removed and large files kept gitignored. Script default path changes can be reverted via git.
