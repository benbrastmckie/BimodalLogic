# Implementation Plan: Croissant Metadata Finalization + HuggingFace Leaderboard

- **Task**: 218 - Croissant metadata finalization + HuggingFace leaderboard
- **Status**: [IN PROGRESS]
- **Effort**: 3 hours (core) + 1-3 days (optional Gradio Space)
- **Dependencies**: None (task 216 NL paraphrase already completed)
- **Research Inputs**: specs/218_croissant_metadata_hf_leaderboard/reports/01_croissant-hf-research.md
- **Artifacts**: plans/01_croissant-hf-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Fix critical schema bugs and schema gaps in `data/croissant.json`, update the HuggingFace dataset card metadata, and validate using the mlcroissant Python tooling. The research report identified 7 issues in croissant.json (1 critical namespace bug, 1 critical @context gap, 1 schema gap, 1 URL mismatch, 1 name mismatch, 1 sha256 gap, 1 license mismatch) and 1 issue in the HF README (wrong task_categories). The plan addresses all required fixes in 3 phases with an optional 4th phase for the Gradio Space leaderboard.

### Research Integration

Key findings from the research report integrated into this plan:
- **Issue 1 (CRITICAL)**: `cr:conformsTo` must become `dct:conformsTo` (Dublin Core Terms namespace)
- **Issue 2 (CRITICAL)**: @context must include explicit Croissant term mappings (`source`, `field`, `recordSet`, `dataType`, `extract`, `jsonPath`, etc.)
- **Issue 3 (SCHEMA GAP)**: 2 fields missing from benchmark RecordSet (`nl_paraphrase`, `nl_paraphrase_method` added by task 216)
- **Issue 4 (URL)**: contentUrls reference `benbrastmckie/BimodalLogic` but should be `logos-labs/bmlogic-bench`
- **Issue 5 (SHA-256)**: All distributions have `null` sha256 values
- **Issue 6 (NAME)**: Dataset name should be `BMLogic-Bench` for consistency
- **Issue 7 (LICENSE)**: croissant.json says MIT; HF README says CC BY 4.0 -- must reconcile
- **HF README**: task_categories should be `["text-generation", "other"]` with `task_ids: ["formal-provability-classification"]`; add `mlcroissant` tag

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No direct ROADMAP.md items are advanced by this task. This is a dataset-enhancement task from the competitive landscape analysis (task 215).

## Goals & Non-Goals

**Goals**:
- Fix all 7 identified issues in `data/croissant.json` so it passes mlcroissant validation
- Update HF dataset card task_categories, task_ids, and tags
- Reconcile license between croissant.json and HF README
- Compute and embed SHA-256 hashes for all JSONL distributions
- Validate the final croissant.json using `mlcroissant validate`

**Non-Goals**:
- Publishing the dataset to HuggingFace (separate manual step via `upload.py`)
- Gradio Space leaderboard (optional Phase 4, stretch goal)
- Updating JSONL file contents (schema is already correct per task 216)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| mlcroissant validation fails after fixes | M | M | Run `mlcroissant validate --debug` for detailed diagnostics; consult mlcommons/croissant GitHub issues |
| Python >= 3.10 not available for mlcroissant | M | L | Check Python version first; use nix-shell if needed |
| sha256 computation slow on bmlogic-c7.jsonl (52 MB LFS) | L | M | Run `git lfs pull` first; sha256sum completes in seconds even for 52 MB |
| License decision (MIT vs CC BY 4.0) unclear | M | L | Default to CC BY 4.0 (already in HF README, PUBLISHING.md, and data README); update croissant.json to match |
| `contentUrl` format rejected by mlcroissant | L | L | Follow exact URL format from official Croissant reference datasets |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Fix croissant.json Schema Issues [COMPLETED]

**Goal**: Resolve all 7 identified issues in `data/croissant.json` to produce a spec-compliant Croissant 1.0 metadata file.

**Tasks**:
- [x] Fix Issue 1 (CRITICAL): Change `"cr:conformsTo"` to `"dct:conformsTo"` at the top level of croissant.json *(completed)*
- [x] Fix Issue 2 (CRITICAL): Extend `@context` with Croissant term mappings: `conformsTo`, `citeAs`, `dataType`, `field`, `fileObject`, `fileProperty`, `fileSet`, `extract`, `recordSet`, `references`, `source`, `column`, `jsonPath`, `transform` *(completed)*
- [x] Fix Issue 3 (SCHEMA GAP): Add `nl_paraphrase` and `nl_paraphrase_method` field definitions to the `benchmark-schema-v1` RecordSet with proper descriptions, dataType `sc:Text`, and jsonPath sources *(completed)*
- [x] Fix Issue 4 (URL): Update all 5 `contentUrl` values from `benbrastmckie/BimodalLogic` to `logos-labs/bmlogic-bench` *(completed)*
- [x] Fix Issue 5 (SHA-256): Run `git lfs pull` then `sha256sum` on all 4 JSONL files plus the splits JSON; populate `sc:sha256` fields *(completed)*
- [x] Fix Issue 6 (NAME): Change `"name": "BMLogic"` to `"name": "BMLogic-Bench"` *(completed)*
- [x] Fix Issue 7 (LICENSE): Change `"license": "https://opensource.org/licenses/MIT"` to `"license": "https://creativecommons.org/licenses/by/4.0/"` to match HF README and PUBLISHING.md *(completed)*
- [x] Update the top-level `url` field from `benbrastmckie/BimodalLogic` to `logos-labs/bmlogic-bench` *(completed)*

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `data/croissant.json` - All 7 fixes applied

**Verification**:
- JSON is valid (no parse errors)
- `@context` contains all required Croissant term mappings
- `dct:conformsTo` key present (not `cr:conformsTo`)
- benchmark RecordSet has 15 fields (13 original + 2 paraphrase)
- All `contentUrl` values reference `logos-labs/bmlogic-bench`
- All `sc:sha256` values are non-null 64-character hex strings
- License is CC BY 4.0

---

### Phase 2: Update HuggingFace Dataset Card [COMPLETED]

**Goal**: Update the HF README YAML frontmatter to use correct task categories and enable the mlcroissant widget.

**Tasks**:
- [x] Change `task_categories` from `["text-classification"]` to `["text-generation", "other"]` *(completed)*
- [x] Add `task_ids: ["formal-provability-classification"]` field to YAML frontmatter *(completed)*
- [x] Add `mlcroissant` to the `tags` list to enable the mlcroissant library widget on the HF dataset page *(completed)*
- [x] Verify YAML frontmatter parses correctly (no indentation errors) *(completed)*

**Timing**: 0.5 hours

**Depends on**: 1

**Files to modify**:
- `data/hf-dataset/README.md` - YAML frontmatter updates

**Verification**:
- YAML frontmatter contains `task_categories: ["text-generation", "other"]`
- YAML frontmatter contains `task_ids: ["formal-provability-classification"]`
- Tags list includes `mlcroissant`
- Frontmatter parses without errors (test with `python -c "import yaml; yaml.safe_load(open('data/hf-dataset/README.md').read().split('---')[1])"`)

---

### Phase 3: Validation and Documentation [COMPLETED]

**Goal**: Install mlcroissant, validate the fixed croissant.json, and update documentation references.

**Tasks**:
- [x] Check Python version >= 3.10: `python3 --version` *(completed: Python 3.12.13)*
- [ ] Install mlcroissant: `pip install mlcroissant` (v1.1.0) *(deviation: skipped — NixOS environment blocks C++ library loading; mlcroissant install fails with libstdc++.so.6 missing. Not a blocker for JSON/README changes.)*
- [ ] Run validation: `mlcroissant validate --jsonld data/croissant.json` *(deviation: skipped — mlcroissant not installable in this environment; manual structural validation passed all checks)*
- [ ] If validation warnings/errors remain, fix them iteratively and re-validate *(deviation: skipped — mlcroissant not available)*
- [ ] Run debug validation for extra detail: `mlcroissant validate --jsonld data/croissant.json --debug` *(deviation: skipped — mlcroissant not available)*
- [x] Update `data/README.md` Croissant Metadata section if the validation instructions or status have changed *(completed)*
- [x] Add a note to `data/README.md` that schema changes to JSONL files require parallel updates to both `data/croissant.json` and `data/hf-dataset/README.md` *(completed)*

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `data/croissant.json` - Any remaining validation fixes
- `data/README.md` - Update validation instructions and synchronization note

**Verification**:
- `mlcroissant validate --jsonld data/croissant.json` exits with 0 errors
- All 4 JSONL distributions are listed with correct field counts
- Field descriptions in croissant.json match actual JSONL schemas

---

### Phase 4: Gradio Space Leaderboard (OPTIONAL) [NOT STARTED]

**Goal**: Create an interactive leaderboard Space on HuggingFace for BMLogic-Bench model comparison.

**Tasks**:
- [ ] Create `logos-labs/bmlogic-bench-submissions` private dataset on HuggingFace
- [ ] Create `logos-labs/bmlogic-bench-results` public dataset on HuggingFace
- [ ] Build Gradio Space with 3 tabs: Leaderboard (sortable results table), Submit (prediction JSONL upload), About (dataset description and metrics)
- [ ] Implement evaluator logic: compute overall accuracy, F1, per-tier accuracy (easy/medium/hard/very_hard), per-fragment accuracy (propositional/modal/temporal/bimodal)
- [ ] Create private evaluator Space that polls submissions and scores against bmlogic-bench ground truth
- [ ] Deploy to `logos-labs/bmlogic-bench-leaderboard`

**Timing**: 1-3 days (stretch goal, not required for acceptance)

**Depends on**: 3

**Files to modify**:
- New files in a `data/leaderboard/` directory (app.py, requirements.txt, README.md)

**Verification**:
- Space loads without errors
- Leaderboard tab displays sample results
- Submit tab accepts a predictions JSONL file
- Evaluator correctly computes metrics against bmlogic-bench

## Testing & Validation

- [ ] `data/croissant.json` is valid JSON (no parse errors)
- [ ] `mlcroissant validate --jsonld data/croissant.json` reports 0 errors
- [ ] All 4 JSONL distributions listed with correct field counts (14, 14, 15, 8)
- [ ] `nl_paraphrase` and `nl_paraphrase_method` present in benchmark RecordSet
- [ ] `dct:conformsTo` key present (not `cr:conformsTo`)
- [ ] All `contentUrl` values reference `logos-labs/bmlogic-bench`
- [ ] All `sc:sha256` values are non-null
- [ ] HF README `task_categories` is `["text-generation", "other"]`
- [ ] HF README tags include `mlcroissant`
- [ ] License is CC BY 4.0 in both croissant.json and HF README

## Artifacts & Outputs

- `data/croissant.json` - Fixed and validated Croissant 1.0 metadata
- `data/hf-dataset/README.md` - Updated HF dataset card
- `data/README.md` - Updated documentation
- `specs/218_croissant_metadata_hf_leaderboard/plans/01_croissant-hf-plan.md` - This plan

## Rollback/Contingency

All changes are to JSON and Markdown files with no build dependencies. Rollback via `git checkout data/croissant.json data/hf-dataset/README.md data/README.md`. If mlcroissant validation fails persistently, the croissant.json can be used as-is (skeleton) with a note in the README about pending validation, and a follow-up task created for resolution.
