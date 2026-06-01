# Implementation Plan: Task #257

- **Task**: 257 - Migrate large data storage from Git LFS to Hugging Face Hub
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/257_large_data_storage_huggingface/reports/01_large-data-storage.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The BimodalLogic repository uses Git LFS to track ~105 MB of JSONL dataset files, with planned c9/c11 datasets that will grow into the multi-GB range. A complete Hugging Face Hub publishing pipeline already exists in `data/hf-dataset/` (upload.py, validate.py, dataset card, PUBLISHING.md), but has not yet been executed. This plan covers executing the upload, updating downstream references and documentation, removing LFS tracking from `.gitattributes`, and optionally cleaning LFS objects from git history. The task is complete when datasets are published on HF Hub, documentation points to HF as the canonical source, and new dataset files are no longer LFS-tracked.

### Research Integration

Key findings from `reports/01_large-data-storage.md`:
- HF Hub provides effectively unlimited public storage for community datasets, purpose-built versioning, CDN, and Parquet auto-conversion
- The `data/hf-dataset/` pipeline is complete and ready to execute (upload.py, validate.py, dataset card with 4 configs)
- Git LFS free tier (250 GiB) is adequate now but will be exceeded by c9/c11 datasets, and every clone/CI run charges bandwidth
- DVC is not recommended -- adds tooling complexity without benefit over HF Hub for this use case
- Migration path is straightforward: upload, update references, remove LFS tracking

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No specific ROADMAP.md items are directly advanced by this task. This is infrastructure work that supports the dataset generation and publication pipeline referenced in `data/README.md`.

## Goals & Non-Goals

**Goals**:
- Publish all 4 dataset configs to `logos-labs/bmlogic-bench` on Hugging Face Hub
- Pin a version tag (v1.0) on the HF dataset repo for reproducible downstream consumption
- Update `data/README.md` and `data/hf-dataset/PUBLISHING.md` to document HF Hub as the canonical data source
- Remove LFS tracking from `.gitattributes` for dataset files
- Document download instructions for BimodalHarness and other consumers

**Non-Goals**:
- Rewriting git history to remove existing LFS objects (optional cleanup, deferred)
- Modifying BimodalHarness directly (separate repo, documented instructions only)
- Setting up automated CI pipeline for dataset publishing (documented as future work)
- Generating c9/c11 datasets (separate tasks)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `logos-labs` HF organization does not exist | M | M | Create org before upload; fall back to personal account as interim |
| HF token lacks write permissions | L | L | Verify token scopes before upload; PUBLISHING.md documents token requirements |
| Upload fails for large c7 file (~52 MB) | L | L | Use `--max-shard-size 25MB` flag; retry with single config `--config bmlogic-c7` |
| Existing LFS consumers break after .gitattributes change | M | L | Data files remain in repo (just not LFS-tracked); document migration in README |
| Record counts in validate.py diverge from actual data | M | M | Run validate.py before upload; update EXPECTED_COUNTS if data has been regenerated |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Validate and Publish Datasets to HF Hub [NOT STARTED]

**Goal**: Execute the existing upload pipeline to publish all 4 dataset configs to Hugging Face Hub, verify the upload, and pin a version tag.

**Tasks**:
- [ ] Ensure `logos-labs` HF organization exists (create at https://huggingface.co/organizations/new if needed)
- [ ] Generate HF write token at https://huggingface.co/settings/tokens (Write scope)
- [ ] Install dependencies: `cd data/hf-dataset && pip install -r requirements.txt`
- [ ] Run validation: `python validate.py` -- confirm all 5 checks pass (YAML + 4 configs)
- [ ] Run dry-run upload: `python upload.py --dry-run` -- verify record counts and schemas
- [ ] Execute upload: `python upload.py --token $HF_TOKEN` (or `export HF_TOKEN=...` first)
- [ ] Verify dataset card renders at `https://huggingface.co/datasets/logos-labs/bmlogic-bench`
- [ ] Verify interactive dataset viewer shows Parquet-converted data
- [ ] Run post-publish verification script from PUBLISHING.md Step 5 (load_dataset assertions)
- [ ] Pin version: create tag `v1.0` on the HF dataset repo using `huggingface_hub` API or web UI

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- No file modifications in this phase (execution of existing scripts)

**Verification**:
- `python validate.py` exits with code 0
- `python upload.py --dry-run` shows correct record counts for all 4 configs
- Dataset accessible at `https://huggingface.co/datasets/logos-labs/bmlogic-bench`
- `load_dataset("logos-labs/bmlogic-bench")` returns 727 test records
- Tag `v1.0` visible on HF dataset repo

---

### Phase 2: Update Documentation and Download References [NOT STARTED]

**Goal**: Update repository documentation to establish HF Hub as the canonical data source and provide download instructions for downstream consumers.

**Tasks**:
- [ ] Update `data/README.md` "Git LFS" section to note datasets are now hosted on HF Hub
- [ ] Add HF Hub download instructions to `data/README.md` (huggingface-cli and Python API)
- [ ] Add HF dataset URL and revision pinning guidance to `data/README.md`
- [ ] Update `data/hf-dataset/PUBLISHING.md` with the actual published URL and v1.0 tag
- [ ] Add a "Downstream Consumer Setup" section to `data/README.md` documenting how BimodalHarness (or any consumer) should download data from HF Hub instead of cloning LFS files
- [ ] Update any references to `git lfs pull` in documentation to note HF Hub as preferred source

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `data/README.md` -- update Git LFS section, add HF Hub download section
- `data/hf-dataset/PUBLISHING.md` -- add post-publish status and version info

**Verification**:
- `data/README.md` contains HF Hub download instructions with `logos-labs/bmlogic-bench` repo ID
- `data/README.md` contains revision pinning example (`revision="v1.0"`)
- No broken internal links in documentation

---

### Phase 3: Remove LFS Tracking from .gitattributes [NOT STARTED]

**Goal**: Stop tracking dataset files via Git LFS so future clones do not download large binary objects. Existing LFS objects remain in git history but no new LFS objects are created.

**Tasks**:
- [ ] Edit `.gitattributes` to remove the 4 LFS tracking lines for `data/*.jsonl` files
- [ ] Run `git lfs untrack "data/bmlogic-c7.jsonl" "data/bmlogic-c9.jsonl" "data/bmlogic-c11.jsonl" "data/proof_steps.jsonl"` as an alternative to manual edit (achieves the same result)
- [ ] Verify `.gitattributes` is empty or contains no LFS entries
- [ ] Add `data/*.jsonl` to `.gitignore` to prevent accidentally committing large dataset files to git (they should live on HF Hub going forward)
- [ ] Update `data/README.md` to reflect that datasets are no longer LFS-tracked
- [ ] Update CI workflow (`.github/workflows/ci.yml`) if it references LFS checkout (currently it does not use `lfs: true`, so no change needed)

**Timing**: 30 minutes

**Depends on**: 2

**Files to modify**:
- `.gitattributes` -- remove all 4 LFS tracking lines
- `.gitignore` -- add `data/*.jsonl` entries for large dataset files (keep small files like bmlogic-c5.jsonl and bmlogic-bench.jsonl if desired, or exclude all and rely on HF Hub)
- `data/README.md` -- update Git LFS section to note LFS tracking removed

**Verification**:
- `.gitattributes` contains no `filter=lfs` entries
- `git lfs ls-files` returns empty output
- `.gitignore` contains entries preventing accidental commit of large JSONL files
- `lake build` still succeeds (no Lean dependency on data files)

---

### Phase 4: Optional History Cleanup Documentation [NOT STARTED]

**Goal**: Document the process for removing LFS objects from git history (BFG Repo-Cleaner or git filter-repo) without executing the rewrite. This preserves the option for future cleanup while avoiding the disruptive force-push required for history rewriting.

**Tasks**:
- [ ] Add a "History Cleanup (Optional)" section to `data/README.md` documenting:
  - BFG Repo-Cleaner command: `java -jar bfg.jar --strip-blobs-bigger-than 50M`
  - git-filter-repo alternative: `git filter-repo --path-glob 'data/*.jsonl' --invert-paths`
  - Warning about force-push requirement and collaborator re-clone
  - Estimated LFS storage savings (~105 MB currently)
- [ ] Note in README that existing LFS objects will naturally become unreferenced over time and can be pruned via GitHub's LFS management UI

**Timing**: 15 minutes

**Depends on**: 3

**Files to modify**:
- `data/README.md` -- add history cleanup documentation section

**Verification**:
- `data/README.md` contains history cleanup instructions with both BFG and git-filter-repo options
- Documentation includes warnings about force-push consequences

## Testing & Validation

- [ ] `python data/hf-dataset/validate.py` passes all checks before upload
- [ ] `python data/hf-dataset/upload.py --dry-run` shows correct record counts
- [ ] Dataset is accessible via `load_dataset("logos-labs/bmlogic-bench")` after upload
- [ ] All 4 configs load correctly: default (727), bmlogic-c5 (1513), bmlogic-c7 (49904), proof-steps (2424)
- [ ] `.gitattributes` has no LFS entries after Phase 3
- [ ] `lake build` succeeds after all changes (no build dependency on data files)
- [ ] Documentation in `data/README.md` is internally consistent

## Artifacts & Outputs

- `specs/257_large_data_storage_huggingface/plans/01_implementation-plan.md` (this file)
- Updated `data/README.md` with HF Hub download instructions and LFS removal notes
- Updated `data/hf-dataset/PUBLISHING.md` with post-publish status
- Updated `.gitattributes` (LFS entries removed)
- Updated `.gitignore` (large JSONL files excluded)
- Published dataset at `https://huggingface.co/datasets/logos-labs/bmlogic-bench` (v1.0 tag)

## Rollback/Contingency

- **Upload failure**: Re-run `upload.py` with `--config` flag for individual configs. Use `--max-shard-size 25MB` for large files.
- **LFS removal regret**: Re-add LFS tracking with `git lfs track "data/*.jsonl"` and restore `.gitattributes` from git history (`git checkout HEAD~1 -- .gitattributes`).
- **Dataset corruption on HF Hub**: Re-upload from local JSONL files (canonical copies remain in the repository or on disk).
- **BimodalHarness integration issues**: The existing data files remain accessible locally; HF Hub is additive, not destructive.
