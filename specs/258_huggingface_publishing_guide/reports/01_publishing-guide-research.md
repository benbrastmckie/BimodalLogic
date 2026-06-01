# Research Report: HF Publishing Guide

- **Task**: 258 - Create a Hugging Face publishing guide in docs/
- **Started**: 2026-06-01T00:00:00Z
- **Completed**: 2026-06-01T00:15:00Z
- **Effort**: ~1 hour (research only)
- **Dependencies**: None
- **Sources/Inputs**:
  - `data/hf-dataset/PUBLISHING.md` — existing step-by-step upload guide
  - `data/hf-dataset/upload.py` — upload script source
  - `data/hf-dataset/validate.py` — validation script source
  - `data/hf-dataset/requirements.txt` — Python dependencies
  - `data/hf-dataset/README.md` — dataset card with YAML frontmatter
  - `data/README.md` — canonical data directory documentation
  - `docs/README.md` — docs/ directory index and conventions
  - `docs/development/README.md` — development documentation overview
  - `docs/training/PIPELINE.md` — training pipeline reference (existing)
- **Artifacts**: `specs/258_huggingface_publishing_guide/reports/01_publishing-guide-research.md`
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

---

## Executive Summary

- A comprehensive HF publishing workflow already exists at `data/hf-dataset/PUBLISHING.md` but
  it is scoped to the `data/hf-dataset/` directory and written for a single-session operator.
- The `docs/` directory is well-organized with subdirectories for `training/`, `development/`,
  `research/`, etc. The natural home for a user-facing HF publishing guide is
  `docs/training/PUBLISHING_GUIDE.md` — adjacent to the existing `docs/training/PIPELINE.md`.
- The new guide should serve ML researchers and dataset consumers who discover the project
  through `docs/` rather than through `data/`. It should cross-reference but not duplicate
  the detailed operator guide in `data/hf-dataset/PUBLISHING.md`.
- Key topics to cover: overview, prerequisites, validate → dry-run → upload workflow, dataset
  card / Croissant metadata, post-publish verification, NeurIPS extras, download instructions,
  troubleshooting. Most content already exists; the guide synthesizes it for the docs/ audience.

---

## Context & Scope

### What Was Researched

1. Whether `docs/` already contains a HF publishing guide — it does not (no file matching
   "huggingface", "hf", or "publishing" found anywhere under `docs/`).
2. The exact content of the existing `data/hf-dataset/PUBLISHING.md` — a 230-line operator
   guide covering 6 steps (install, validate, dry-run, upload, post-verify, NeurIPS extras)
   plus troubleshooting and file structure.
3. The `upload.py` and `validate.py` scripts to understand the actual CLI interface.
4. The `data/README.md` which contains download instructions and dataset descriptions.
5. The `docs/` organization to determine the correct subdirectory placement.

### Constraints

- Documentation line limit: 100 characters per line (per `docs/README.md` standards).
- Markdown formatting: ATX-style headings, language-annotated code fences, Unicode in backticks.
- The guide must be audience-appropriate for ML researchers discovering the project through docs/,
  not necessarily for release engineers running the upload pipeline.

---

## Findings

### Existing Publishing Infrastructure

The project has a complete, ready-to-use HF publishing pipeline:

| Artifact | Location | Purpose |
|----------|----------|---------|
| `upload.py` | `data/hf-dataset/` | Uploads all 4 configs to `logos-labs/bmlogic-bench` |
| `validate.py` | `data/hf-dataset/` | Pre-upload validation (5 checks, exit code 0/1) |
| `requirements.txt` | `data/hf-dataset/` | `datasets>=2.19.0`, `huggingface_hub>=0.23.0`, etc. |
| `README.md` | `data/hf-dataset/` | Dataset card with YAML frontmatter (HF reads this) |
| `PUBLISHING.md` | `data/hf-dataset/` | Detailed 6-step operator guide |
| `croissant.json` | `data/` | MLCommons Croissant 1.0 metadata |
| `dataset-card.md` | `data/` | Full dataset card with schemas |

### Dataset Configurations

Four configs are published to `logos-labs/bmlogic-bench`:

| Config | Split | Records | Description |
|--------|-------|---------|-------------|
| `default` | test | 727 | Evaluation benchmark (stratified) |
| `bmlogic-c5` | train | 1,513 | Training set, complexity ≤ 5 |
| `bmlogic-c7` | train | 49,904 | Training set, complexity ≤ 7 |
| `proof-steps` | train | 2,424 | Proof step supervision (36 theorems) |

### Upload Script CLI

```bash
# Dry run (loads locally, no push):
python upload.py --dry-run

# Upload with token arg:
python upload.py --token YOUR_HF_TOKEN

# Upload with env var:
export HF_TOKEN=your_token_here && python upload.py

# Upload single config:
python upload.py --token YOUR_HF_TOKEN --config bmlogic-c5

# Custom repo:
python upload.py --repo your-org/your-repo --token YOUR_HF_TOKEN

# Limit shard size (for slow connections):
python upload.py --token YOUR_HF_TOKEN --max-shard-size 25MB
```

### Validation Script

```bash
cd data/hf-dataset/
python validate.py            # all configs
python validate.py --config bmlogic-c5  # single config
python validate.py --verbose  # include schema details
```

Checks: YAML frontmatter (4 configs), record counts, required fields non-null, label values.

### Docs/ Directory Structure (Relevant Sections)

```
docs/
├── README.md               # Hub with audience-based navigation
├── training/               # Training data pipeline docs
│   └── PIPELINE.md         # Dual-signal pipeline reference
├── development/            # Developer standards
├── research/               # Research documents
├── user-guide/             # Integration guides
├── installation/           # Setup guides
├── architecture/           # ADRs
├── project-info/           # Status tracking
└── reference/              # API reference
```

The `docs/training/` subdirectory is the natural home for a HF publishing guide because:
- It already contains ML-pipeline documentation (`PIPELINE.md`)
- It is listed in `docs/README.md` under "training/" with "Audience: ML researchers,
  contributors working on neural proof search"
- A publishing guide is a logical companion to the pipeline reference

### Documentation Status of Migration

Per `data/hf-dataset/PUBLISHING.md` (as of 2026-06-01):
- LFS tracking: removed
- HF Hub upload: **Pending** (dataset not yet published)
- The guide being created in docs/ should reflect this pending status and direct users to
  complete the upload using the existing tooling before distributing the canonical URL.

### Key Technical Details to Include in the Guide

1. **Token management**: `HF_TOKEN` env var preferred over `--token` arg (avoids shell history).
2. **Working directory**: Scripts must be run from `data/hf-dataset/` (paths are relative).
3. **Symlink behavior**: `data/hf-dataset/data/` contains symlinks to `../../*.jsonl`; HF upload
   follows symlinks automatically.
4. **Post-upload Parquet conversion**: HF auto-converts JSONL to Parquet after upload.
5. **Schema synchronization rule**: When JSONL schema changes, update both `croissant.json`
   (RecordSet field definitions) and `data/hf-dataset/README.md` (YAML frontmatter + card).
6. **NeurIPS extras**: Croissant download from HF after upload; RAI YAML fields to add manually.
7. **Croissant validation**: `mlcroissant validate --jsonld data/croissant.json` (requires
   C++ toolchain; fallback: `python3 -c "import json; json.load(open('data/croissant.json'))"`)

### Download Instructions for Consumers

```python
from datasets import load_dataset

ds_bench  = load_dataset("logos-labs/bmlogic-bench")
ds_c5     = load_dataset("logos-labs/bmlogic-bench", "bmlogic-c5")
ds_c7     = load_dataset("logos-labs/bmlogic-bench", "bmlogic-c7")
ds_proof  = load_dataset("logos-labs/bmlogic-bench", "proof-steps")

# Pin a version for reproducibility
ds_bench_v1 = load_dataset("logos-labs/bmlogic-bench", revision="v1.0")
```

CLI download:
```bash
pip install huggingface_hub
huggingface-cli download logos-labs/bmlogic-bench --repo-type dataset --local-dir data/
```

---

## Decisions

1. **Placement**: `docs/training/PUBLISHING_GUIDE.md` — adjacent to `PIPELINE.md`, same audience.
2. **Scope**: The docs/ guide is a user-facing overview with cross-references to the detailed
   operator guide (`data/hf-dataset/PUBLISHING.md`). It is not a verbatim copy.
3. **Audience framing**: ML researchers and dataset consumers, not release engineers.
4. **Status note**: Include a prominent status callout noting the dataset is pending upload,
   pointing to the canonical URL for when it goes live.
5. **Update `docs/README.md`**: Add the new file to the `training/` section listing.
6. **Update `docs/training/` README (if it exists)**: None exists currently; may need to create
   a `docs/training/README.md` as a directory index following `DIRECTORY_README_STANDARD.md`.

---

## Recommendations

### Guide Structure

The guide at `docs/training/PUBLISHING_GUIDE.md` should contain:

1. **Title and status callout** — "BMLogic-Bench on Hugging Face Hub" + pending/live status
2. **Overview** — What the dataset is, 4 configs, canonical URL
3. **Quick start for consumers** — `load_dataset(...)` one-liners (most users just need this)
4. **Publishing the dataset** — For maintainers: prerequisites, 4-step workflow
   - Install dependencies
   - Validate (`python validate.py`)
   - Dry run (`python upload.py --dry-run`)
   - Upload (`python upload.py --token ...`)
5. **Post-publish verification** — Python verification snippet, browser URL
6. **NeurIPS submission extras** — Croissant download, RAI fields
7. **Dataset card and schema** — How to update `data/hf-dataset/README.md` and
   `data/croissant.json` when schema changes
8. **Troubleshooting** — Auth errors, upload timeouts, schema inference
9. **Related documentation** — Cross-references to `data/hf-dataset/PUBLISHING.md`,
   `data/README.md`, `docs/training/PIPELINE.md`

### Files to Create/Update

| Action | File |
|--------|------|
| Create | `docs/training/PUBLISHING_GUIDE.md` |
| Create | `docs/training/README.md` (directory index, if not present) |
| Update | `docs/README.md` — add `PUBLISHING_GUIDE.md` to training/ section |

### What to Avoid

- Do not duplicate the full 6-step operator detail from `data/hf-dataset/PUBLISHING.md`.
  Cross-reference it instead.
- Do not claim the dataset is live until the upload is complete.
- Do not exceed 100-character line width.

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Dataset not yet published; guide may confuse users | Add prominent status callout; note pending state |
| Schema drift between JSONL and Croissant/README | Document the synchronization rule explicitly |
| Record counts in PUBLISHING.md may be stale (bmlogic-bench shows 727 but data/README.md shows 777) | Cross-check: use 727 for the HF upload configs (PUBLISHING.md and upload.py agree); 777 is a different count in data/README.md (newer benchmark with Very Hard+ slice not yet in HF upload configs) |
| `docs/training/` has no README.md currently | Create `docs/training/README.md` as part of this task |

---

## Appendix

### Record Count Discrepancy Note

`data/hf-dataset/PUBLISHING.md` and `upload.py` both specify 727 records for the default
(bmlogic-bench) config. However, `data/README.md` lists 777 records in the File Inventory
table. The 777 figure reflects the addition of a "Very Hard+" benchmark slice (Task referenced
in data/README.md: "curate 100+ records at complexity 8-9 for the benchmark"). The HF upload
configs in `upload.py` still use the 727-record version. The publishing guide should use 727
to match the actual upload tooling, and note that future versions may increase the count.

### Files Not Needing Changes

- `data/hf-dataset/PUBLISHING.md` — complete, accurate, should remain as-is
- `data/hf-dataset/upload.py` — correct implementation
- `data/hf-dataset/validate.py` — correct implementation
- `data/hf-dataset/README.md` — dataset card, correct

### Search Queries Used

- Local file tree exploration via `find` and `ls` (no web searches needed; all information
  was available in the codebase)
