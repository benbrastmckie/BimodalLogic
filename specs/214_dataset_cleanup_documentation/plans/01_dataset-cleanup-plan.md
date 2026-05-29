# Implementation Plan: Task #214

- **Task**: 214 - Dataset cleanup, standardization, and documentation
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None (coordinate with task 213 but not blocked by it)
- **Research Inputs**: specs/214_dataset_cleanup_documentation/reports/01_team-research.md
- **Artifacts**: plans/01_dataset-cleanup-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The data/ directory contains 21 files produced by 3 generation pipelines (training, benchmark, proof-steps). Several files are intermediates or test artifacts that should be deleted. The remaining final datasets have inconsistent metadata schemas -- the benchmark has 14+ rich metadata fields while training datasets have 9 simple fields and proof_steps has no metadata file at all. The current data/.gitignore blanket-excludes ALL .jsonl and metadata files, preventing git from tracking final datasets. This plan covers file deletion, metadata enrichment and creation, gitignore rewrite, Git LFS setup, README creation, and schema validation.

**Important discovery**: The actual data/ directory has evolved since research was conducted. Task 213 has already generated new files: bmlogic-c5.jsonl (1.4MB, 1,513 records) and bmlogic-c7.jsonl (53MB, 49,904 records), each with metadata files. These appear to be the regenerated replacements for bmlogic-medium and bmlogic-deep respectively (matching their complexity levels). The plan must account for these new files and clarify the final dataset inventory with the user.

### Research Integration

The team research report (4 teammates) was integrated into this plan. Key findings incorporated:
- Common metadata header + dataset-specific extensions (not forcing bench format on all)
- Git LFS for files >10MB (confirmed: Git LFS is NOT currently installed)
- List specific intermediates to ignore in .gitignore (not blanket-exclude with ! exceptions)
- Flat directory structure (not subdirectories)
- HuggingFace dataset card format for README.md
- Misleading `representations` field in metadata (present in c5/c7 metadata, lists fields not in actual JSONL records)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This plan advances general project quality goals. No specific ROADMAP.md items reference dataset cleanup directly, but it supports the broader "Publication quality" phase (Phase 5) and potential HuggingFace publication of datasets.

## Goals & Non-Goals

**Goals**:
- Remove intermediate pipeline artifacts and test files from data/
- Create proof_steps_metadata.json with appropriate step-level fields
- Enrich training metadata with common header fields (dataset_name, version, description, schema_version, generation_date)
- Remove misleading `representations` array from metadata where actual JSONL records lack those fields
- Rewrite data/.gitignore to list specific intermediates rather than blanket exclusion
- Set up Git LFS for large files (>10MB)
- Create data/README.md documenting each dataset (purpose, schema, generation, fields)
- Verify record schema consistency across all kept datasets

**Non-Goals**:
- Modifying Lean DatasetMetadata struct or DatasetExport.lean (use Python scripts instead)
- Creating subdirectory-per-dataset structure (flat is sufficient for 4-6 datasets)
- Croissant 1.1 JSON-LD metadata
- HuggingFace Hub publication (task 208)
- JSON Schema validation files
- Adding SHA-256 checksums (future enhancement)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task 213 overwrites files during implementation | M | M | Check task 213 status before starting; document regeneration commands rather than freezing counts |
| Git LFS not available on system | H | H (confirmed) | Phase 2 includes Git LFS installation; if system constraints prevent installation, document the limitation and use .gitignore for large files |
| bmlogic-c5/c7 naming unclear -- may replace or supplement deep/medium | M | M | Phase 1 requires clarifying the dataset inventory before deleting anything |
| Metadata enrichment script breaks existing metadata | M | L | Back up metadata files before modification; validate after changes |
| Large file commits slow down git operations | M | M | Git LFS mitigates; if unavailable, keep large files gitignored with documentation |

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

### Phase 1: Audit and Clean Up Files [NOT STARTED]

**Goal**: Establish the definitive dataset inventory and remove intermediate/test files.

**Tasks**:
- [ ] Audit current data/ directory contents against research findings, noting new bmlogic-c5/c7 files
- [ ] Determine final dataset inventory: clarify whether c5/c7 replace medium/deep or are additional datasets
- [ ] Delete intermediate pipeline artifacts: axiom-instances.jsonl, bmlogic-bench-candidates.jsonl, bmlogic-bench-validated.jsonl
- [ ] Delete test files: test.jsonl, test_c4.jsonl, test_metadata.json, test_c4_metadata.json
- [ ] Delete any old datasets superseded by c5/c7 regeneration (if applicable)
- [ ] Verify no scripts have hard-coded dependencies on deleted files (check scripts/ directory)

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `data/axiom-instances.jsonl` - DELETE
- `data/bmlogic-bench-candidates.jsonl` - DELETE
- `data/bmlogic-bench-validated.jsonl` - DELETE
- `data/test.jsonl` - DELETE
- `data/test_c4.jsonl` - DELETE
- `data/test_metadata.json` - DELETE
- `data/test_c4_metadata.json` - DELETE
- Possibly `data/bmlogic-deep.jsonl`, `data/bmlogic-medium.jsonl` and their metadata - DELETE if superseded by c5/c7

**Verification**:
- Only final datasets and their metadata remain in data/
- No broken references in scripts/ directory
- `ls data/` shows only kept datasets, metadata, .gitignore

---

### Phase 2: Install Git LFS and Rewrite .gitignore [NOT STARTED]

**Goal**: Set up Git LFS for large files and rewrite .gitignore to track final datasets while excluding intermediates.

**Tasks**:
- [ ] Check if Git LFS is available (`git lfs version`) and install if needed (`nix-env -iA nixpkgs.git-lfs` or package manager equivalent)
- [ ] Initialize Git LFS in the repository (`git lfs install`)
- [ ] Track large JSONL files with Git LFS (any file >10MB: bmlogic-deep/c7 ~50MB, proof_steps ~15MB)
- [ ] Rewrite data/.gitignore to list specific intermediate filenames to ignore (not blanket patterns)
- [ ] Add .gitattributes entries for LFS-tracked files if needed
- [ ] Verify `git status` shows final datasets as trackable (not ignored)

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `data/.gitignore` - REWRITE: replace blanket `*.jsonl` / `*_metadata.json` with specific intermediate exclusions
- `.gitattributes` - CREATE or MODIFY: add LFS tracking patterns for large datasets
- Repository-level LFS configuration

**Verification**:
- `git lfs version` returns a version
- `git status` shows final .jsonl and metadata files as untracked (not ignored)
- `git check-ignore data/bmlogic-bench.jsonl` returns nothing (not ignored)
- `git check-ignore data/test.jsonl` would have been ignored (if file still existed)

---

### Phase 3: Standardize and Create Metadata [NOT STARTED]

**Goal**: Enrich training metadata with common header fields, create proof_steps_metadata.json, and remove misleading fields.

**Tasks**:
- [ ] Define common metadata header schema: dataset_name, version, description, generation_date, schema_version, frame_class, total_records (these exist in all datasets)
- [ ] Create a Python script (scripts/standardize_metadata.py) to:
  - Read each metadata file
  - Add missing common header fields
  - Remove misleading `representations` array where JSONL records lack those fields
  - Preserve all dataset-specific fields (tier_distribution, quality, etc. for bench; sampling_mode etc. for training)
  - Write back with consistent formatting
- [ ] Run the script to enrich bmlogic-deep_metadata.json and bmlogic-medium_metadata.json (or c5/c7 equivalents)
- [ ] Create proof_steps_metadata.json with appropriate fields: dataset_name, version, description, generation_date, schema_version, total_records, theorem_count, rule_distribution, step_statistics
- [ ] Populate proof_steps_metadata.json by scanning proof_steps.jsonl for actual statistics
- [ ] Validate that enriched metadata is valid JSON with consistent field ordering

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `scripts/standardize_metadata.py` - CREATE: metadata enrichment and validation script
- `data/bmlogic-deep_metadata.json` (or c7) - ENRICH: add common header fields
- `data/bmlogic-medium_metadata.json` (or c5) - ENRICH: add common header fields
- `data/proof_steps_metadata.json` - CREATE: new metadata file for proof steps dataset

**Verification**:
- All metadata files have dataset_name, version, description, generation_date, schema_version, frame_class
- proof_steps_metadata.json exists with correct record count and rule distribution
- No metadata file contains `representations` array for fields not in actual JSONL records
- `python3 -c "import json; json.load(open('data/FILE_metadata.json'))"` succeeds for each file

---

### Phase 4: Create data/README.md [NOT STARTED]

**Goal**: Write comprehensive documentation for the data/ directory in HuggingFace dataset card format.

**Tasks**:
- [ ] Create data/README.md with YAML frontmatter (HuggingFace dataset card format)
- [ ] Document each dataset: purpose, record count, schema (all fields with types and descriptions), generation command, provenance
- [ ] Document the three generation pipelines (training, benchmark, proof-steps) with regeneration commands
- [ ] Include record schema tables for each dataset type (training, benchmark, proof-steps)
- [ ] Document the metadata schema (common header + dataset-specific extensions)
- [ ] Add a "Dataset Relationships" section explaining how medium/deep/bench relate
- [ ] Include notes on file sizes and Git LFS tracking
- [ ] Design record counts as "approximate" or "as of generation date" to handle regeneration gracefully

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `data/README.md` - CREATE: comprehensive dataset documentation

**Verification**:
- README.md exists and is valid Markdown
- Each kept dataset is documented with schema, purpose, and generation command
- Record counts match actual JSONL line counts (spot-check)
- YAML frontmatter is valid (if HuggingFace format used)

---

### Phase 5: Schema Validation and Final Verification [NOT STARTED]

**Goal**: Verify all datasets have consistent field schemas and all deliverables are complete.

**Tasks**:
- [ ] Write a validation script (scripts/validate_datasets.py) that:
  - Reads first and last record of each JSONL file
  - Verifies all records have expected fields per dataset type
  - Cross-checks metadata record counts against actual JSONL line counts
  - Reports any schema inconsistencies
- [ ] Run validation script and fix any issues found
- [ ] Verify .gitignore correctly excludes intermediates but not finals
- [ ] Verify Git LFS is tracking the correct files
- [ ] Final audit: confirm data/ directory matches target structure
- [ ] Stage all changes and verify `git status` looks correct

**Timing**: 0.5 hours

**Depends on**: 4

**Files to modify**:
- `scripts/validate_datasets.py` - CREATE: dataset schema validation script
- Any files needing fixes discovered during validation

**Verification**:
- Validation script reports zero errors
- `git check-ignore` confirms correct ignore behavior
- `git lfs ls-files` shows large datasets tracked by LFS
- data/ directory matches target structure documented in README.md

---

## Testing & Validation

- [ ] All intermediate/test files deleted from data/
- [ ] All kept datasets are valid JSONL (each line parses as JSON)
- [ ] All metadata files are valid JSON with common header fields
- [ ] proof_steps_metadata.json exists with accurate statistics
- [ ] data/.gitignore excludes intermediates, allows finals
- [ ] Git LFS tracks files >10MB
- [ ] data/README.md documents all datasets accurately
- [ ] No broken script references to deleted files
- [ ] Validation script passes with zero errors

## Artifacts & Outputs

- `data/README.md` - Comprehensive dataset documentation
- `data/proof_steps_metadata.json` - New metadata for proof steps dataset
- `data/.gitignore` - Rewritten to list specific exclusions
- `data/bmlogic-*_metadata.json` - Enriched with common header fields
- `.gitattributes` - LFS tracking configuration
- `scripts/standardize_metadata.py` - Metadata enrichment script
- `scripts/validate_datasets.py` - Dataset validation script
- `specs/214_dataset_cleanup_documentation/plans/01_dataset-cleanup-plan.md` - This plan

## Rollback/Contingency

All deleted files are regenerable via documented pipeline commands:
- Training data: `lake exe dataset_generator` via `scripts/run_dataset_generation.sh`
- Benchmark: `lake exe benchmark_anchors` -> `scripts/curate_benchmark.py` -> `lake exe benchmark_oracle` -> `scripts/finalize_benchmark.py`
- Proof steps: `lake exe proof_extractor`
- Intermediates: `lake exe benchmark_anchors` (axiom-instances), pipeline stages (candidates, validated)

If metadata enrichment corrupts files, original metadata can be recovered from git history. If Git LFS causes issues, LFS tracking can be removed and large files kept gitignored.
