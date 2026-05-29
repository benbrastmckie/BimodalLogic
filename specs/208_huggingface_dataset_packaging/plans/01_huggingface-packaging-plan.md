# Implementation Plan: Task #208

- **Task**: 208 - HuggingFace dataset packaging for BMLogic-Bench
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: 214 (dataset cleanup, completed)
- **Research Inputs**: specs/208_huggingface_dataset_packaging/reports/01_huggingface-packaging.md
- **Artifacts**: plans/01_huggingface-packaging-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Package the four BMLogic-Bench datasets for HuggingFace Datasets Hub publication under `logos-labs/bmlogic-bench`. The work creates a self-contained `hf-dataset/` directory with YAML-frontmatter dataset card, Python upload script, and validation tooling. The directory structure mirrors the HuggingFace repository layout so that `push_to_hub()` can publish directly. No actual Hub push is performed -- that remains a manual step.

### Research Integration

Research report (01_huggingface-packaging.md) established:
- 4-config structure: `bmlogic-bench` (default, test, 727), `bmlogic-c5` (train, 1,513), `bmlogic-c7` (train, 49,904), `proof-steps` (train, 2,424)
- JSONL upload with auto-Parquet conversion (no manual Parquet needed for <5GB)
- CC BY 4.0 license for dataset files (MIT remains for code)
- NeurIPS 2026 requires public HF dataset with Croissant metadata (auto-generated) and RAI fields (manual)
- Dataset card README.md with YAML frontmatter is the primary config mechanism
- Python deps: datasets>=2.19.0, huggingface_hub>=0.23.0

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items are explicitly tracked for HuggingFace packaging. This task supports the NeurIPS 2026 submission workflow.

## Goals & Non-Goals

**Goals**:
- Create `hf-dataset/` directory with HuggingFace-compatible layout
- Write dataset card README.md with YAML frontmatter for 4 configs and comprehensive prose documentation
- Create Python upload script that pushes all 4 configs via `push_to_hub()`
- Create validation script to verify JSONL schemas, record counts, and packaging correctness
- Include BibTeX citation entries for the paper and software
- Ensure one-line loading works: `datasets.load_dataset("logos-labs/bmlogic-bench")`

**Non-Goals**:
- Actually pushing to HuggingFace Hub (manual step by the user)
- Creating the `logos-labs` organization on HuggingFace
- Completing NeurIPS RAI metadata fields (separate post-upload step)
- Manual Parquet conversion (HF auto-converts JSONL)
- Creating train/val/test splits within a single config (schemas differ across configs)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Nested JSON columns cause schema inference failure | M | L | Upload script includes explicit `Features` fallback with `Value('string')` for complex dicts |
| `logos-labs` org not yet created on HuggingFace | L | M | Upload script accepts `--repo` argument; defaults to `logos-labs/bmlogic-bench` but user can override |
| YAML frontmatter syntax error breaks HF parsing | M | L | Validation script includes YAML lint check; test locally before push |
| bmlogic-c7.jsonl too large for upload timeout | L | L | 52 MB is well under threshold; script uses `max_shard_size="100MB"` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Directory Structure and Dataset Card [COMPLETED]

**Goal**: Create the `hf-dataset/` directory with symlinked data files and write the complete dataset card README.md with YAML frontmatter and prose documentation.

**Tasks**:
- [x] Create `hf-dataset/` directory at project root *(completed)*
- [x] Create `hf-dataset/data/` subdirectory *(completed)*
- [x] Symlink (or copy) the 4 JSONL files from `data/` into `hf-dataset/data/` *(completed: symlinks to ../../data/ files)*
- [x] Write `hf-dataset/README.md` with YAML frontmatter containing: *(completed)*
  - `language: [en]`
  - `license: cc-by-4.0`
  - `pretty_name: "BMLogic-Bench: Bimodal Logic Benchmark"`
  - `tags: [logic, theorem-proving, bimodal-logic, temporal-logic, modal-logic, lean4, formal-verification, benchmark, reasoning]`
  - `task_categories: [text-classification]`
  - `size_categories: [10K<n<100K]`
  - 4 config entries with correct `config_name`, `data_files`, and `split` mappings
  - `bmlogic-bench` marked as `default: true`
- [x] Write dataset card prose sections: *(completed: 10 sections)*
  - Dataset Summary (TM logic, benchmark purpose, LLM reasoning evaluation)
  - Dataset Details (per-config descriptions, schemas, statistics)
  - Dataset Creation (Lean 4 decision procedures, curation rationale)
  - Uses (intended: evaluation, fine-tuning; out-of-scope uses)
  - Data Instances (one example per config)
  - Data Fields (field-by-field description per config)
  - Data Splits (record count table)
  - Considerations (social impact, class imbalance: ~4% valid in training vs ~47% in benchmark, synthetic data)
  - Citation Information (BibTeX entries)
  - Contributions (acknowledgements)
- [x] Include both BibTeX entries: pre-print `@article` for NeurIPS and `@software` for GitHub *(completed)*

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `hf-dataset/README.md` - Create dataset card (new file)

**Verification**:
- `hf-dataset/README.md` exists with valid YAML frontmatter between `---` delimiters
- YAML contains exactly 4 config entries
- All 4 data file paths in YAML point to existing files in `hf-dataset/data/`
- Prose includes all 10 required sections

---

### Phase 2: Upload and Validation Scripts [COMPLETED]

**Goal**: Create Python scripts for uploading to HuggingFace Hub and validating the packaging locally.

**Tasks**:
- [x] Create `hf-dataset/upload.py` with: *(completed)*
  - Argument parser: `--repo` (default: `logos-labs/bmlogic-bench`), `--dry-run` flag, `--token` for HF auth
  - Load each JSONL with `datasets.load_dataset("json", data_files=...)`
  - Push each config separately via `push_to_hub()` with correct `config_name` and `split`
  - Print progress and record counts for each config
  - `--dry-run` mode: load datasets and print schemas/counts without pushing
  - Error handling for authentication, network, and schema inference failures
- [x] Create `hf-dataset/validate.py` with: *(completed)*
  - Load each JSONL file and verify record counts match expected values (727, 1513, 49904, 2424)
  - Verify field schemas match documented fields per config
  - Check for null/missing values in required fields
  - Validate YAML frontmatter in README.md parses correctly
  - Print summary table of validation results
  - Exit with non-zero code on any validation failure
- [x] Create `hf-dataset/requirements.txt` with pinned minimum versions: *(completed)*
  - `datasets>=2.19.0`
  - `huggingface_hub>=0.23.0`
  - `pyarrow>=14.0.0`
  - `pyyaml>=6.0`
- [x] Add docstrings and usage instructions to both scripts *(completed)*

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `hf-dataset/upload.py` - Create upload script (new file)
- `hf-dataset/validate.py` - Create validation script (new file)
- `hf-dataset/requirements.txt` - Create dependency list (new file)

**Verification**:
- `python hf-dataset/upload.py --dry-run` loads all 4 datasets and prints schemas without errors
- `python hf-dataset/validate.py` passes all checks with exit code 0
- Both scripts have `--help` output with usage documentation

---

### Phase 3: Integration Test and Documentation [NOT STARTED]

**Goal**: Run end-to-end validation, verify the packaging is complete, and add user-facing documentation.

**Tasks**:
- [ ] Run `python hf-dataset/validate.py` and verify all checks pass
- [ ] Run `python hf-dataset/upload.py --dry-run` and verify all 4 configs load correctly
- [ ] Verify dataset card README.md renders correctly (check YAML structure manually)
- [ ] Create `hf-dataset/PUBLISHING.md` with step-by-step instructions:
  - Prerequisites (HF account, `logos-labs` org, API token)
  - Install deps: `pip install -r requirements.txt`
  - Validate: `python validate.py`
  - Dry run: `python upload.py --dry-run`
  - Publish: `python upload.py --token YOUR_TOKEN`
  - Post-publish verification: `datasets.load_dataset("logos-labs/bmlogic-bench")`
  - Croissant download and RAI field addition for NeurIPS submission
- [ ] Verify no data files are accidentally duplicated (symlinks or copies are consistent)

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `hf-dataset/PUBLISHING.md` - Create publishing guide (new file)

**Verification**:
- All validation passes
- Dry-run upload succeeds for all 4 configs
- `hf-dataset/` directory contains: README.md, upload.py, validate.py, requirements.txt, PUBLISHING.md, data/ (with 4 JSONL files)
- No Python errors or warnings during dry-run

## Testing & Validation

- [ ] `python hf-dataset/validate.py` exits with code 0 (all schema and count checks pass)
- [ ] `python hf-dataset/upload.py --dry-run` loads all 4 configs without error
- [ ] YAML frontmatter in `hf-dataset/README.md` parses correctly (no syntax errors)
- [ ] Record counts match: bmlogic-bench=727, bmlogic-c5=1513, bmlogic-c7=49904, proof-steps=2424
- [ ] BibTeX entries are present in dataset card
- [ ] All 4 JSONL files are accessible in `hf-dataset/data/`

## Artifacts & Outputs

- `hf-dataset/README.md` - Dataset card with YAML frontmatter and prose documentation
- `hf-dataset/upload.py` - Python upload script for HuggingFace Hub
- `hf-dataset/validate.py` - Python validation script
- `hf-dataset/requirements.txt` - Python dependency list
- `hf-dataset/PUBLISHING.md` - Step-by-step publishing instructions
- `hf-dataset/data/` - Directory containing (symlinks to) the 4 JSONL files

## Rollback/Contingency

The `hf-dataset/` directory is entirely new and self-contained. Rollback is simply `rm -rf hf-dataset/`. No existing files in the repository are modified. The original data files in `data/` remain untouched.
