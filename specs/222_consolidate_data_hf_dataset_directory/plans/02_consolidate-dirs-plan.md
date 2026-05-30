# Implementation Plan: Task #222

- **Task**: 222 - Consolidate data/ and hf-dataset/ into unified directory structure
- **Status**: [IN PROGRESS]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/222_consolidate_data_hf_dataset_directory/reports/01_consolidate-dirs-research.md
- **Artifacts**: plans/02_consolidate-dirs-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Consolidate the root-level `hf-dataset/` directory into `data/hf-dataset/` using `git mv`, update the 4 symlinks with corrected relative paths, update path resolution in `upload.py` and `validate.py`, move the misplaced `data/competitive-landscape.md` to `docs/research/`, and write a new lightweight `data/README.md` that serves as a proper directory navigation document. The existing `data/README.md` (HuggingFace dataset card) will be preserved as `data/dataset-card.md` before being replaced. No Lean source files, Python scripts outside `hf-dataset/`, or git LFS configuration need modification since all `data/` paths remain unchanged.

### Research Integration

Key findings from the research report:
- No data duplication: `hf-dataset/data/` contains only 4 symlinks pointing back to `data/*.jsonl`
- The two READMEs serve different purposes and must remain separate (directory README vs HF dataset card)
- `competitive-landscape.md` (411 lines) is a research document misplaced in `data/`
- `upload.py` and `validate.py` use `Path(__file__).parent.resolve()` for path resolution -- only their relative `data/` references need updating
- Git LFS tracks `data/bmlogic-c7.jsonl` and `data/proof_steps.jsonl` -- these paths are unchanged

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No specific ROADMAP.md items are advanced by this task. This is a directory hygiene task that improves repository organization.

## Goals & Non-Goals

**Goals**:
- Eliminate `hf-dataset/` as a root-level directory by moving it under `data/hf-dataset/`
- Ensure all symlinks in `data/hf-dataset/data/` remain valid after the move
- Ensure `upload.py` and `validate.py` scripts work from the new location
- Move `competitive-landscape.md` to `docs/research/` where research documents belong
- Provide a lightweight `data/README.md` that serves as a directory navigation document
- Preserve the HuggingFace dataset card content intact

**Non-Goals**:
- Modifying any Lean source files or Python scripts outside `hf-dataset/`
- Changing git LFS configuration (JSONL paths are unchanged)
- Renaming or restructuring files within `data/` itself (beyond the move)
- Modifying CI/CD workflows

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Symlinks break after git mv | M | M | Recreate symlinks with corrected relative paths; verify with `ls -la` and `readlink` |
| upload.py/validate.py path resolution breaks | M | M | Update DATASET_CONFIGS/CONFIG_FILES paths from `data/X.jsonl` to `../X.jsonl`; test with `--dry-run` or `--config` |
| data/README.md references to competitive-landscape.md break | L | H | Update the single reference to the new `docs/research/` path |
| Git history fragmentation for moved files | L | L | Use `git mv` to preserve rename tracking |
| HuggingFace upload workflow disruption | L | L | Document new working directory in PUBLISHING.md |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Move hf-dataset/ under data/ and fix symlinks [COMPLETED]

**Goal**: Relocate `hf-dataset/` to `data/hf-dataset/` and ensure all symlinks remain valid.

**Tasks**:
- [x] Run `git mv hf-dataset/ data/hf-dataset/` to move the directory *(completed)*
- [x] Remove the 4 broken symlinks in `data/hf-dataset/data/` *(completed)*
- [x] Recreate symlinks with corrected relative paths (depth changes from `../../data/` to `../../`): *(completed)*
  - `data/hf-dataset/data/bmlogic-bench.jsonl -> ../../bmlogic-bench.jsonl`
  - `data/hf-dataset/data/bmlogic-c5.jsonl -> ../../bmlogic-c5.jsonl`
  - `data/hf-dataset/data/bmlogic-c7.jsonl -> ../../bmlogic-c7.jsonl`
  - `data/hf-dataset/data/proof_steps.jsonl -> ../../proof_steps.jsonl`
- [x] Update path constants in `data/hf-dataset/upload.py` *(deviation: skipped — paths use data/ subdir symlinks, which are still correct after move)*
- [x] Update path constants in `data/hf-dataset/validate.py` *(deviation: skipped — same reasoning as upload.py)*
- [x] Update `data/hf-dataset/PUBLISHING.md` to reflect the new directory location (working directory instructions) *(completed)*

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `hf-dataset/` -> `data/hf-dataset/` (git mv)
- `data/hf-dataset/data/*.jsonl` (symlinks recreated)
- `data/hf-dataset/upload.py` - path constant updates
- `data/hf-dataset/validate.py` - path constant updates
- `data/hf-dataset/PUBLISHING.md` - directory location update

**Verification**:
- `ls -la data/hf-dataset/data/` shows 4 valid symlinks
- `readlink data/hf-dataset/data/bmlogic-bench.jsonl` returns `../../bmlogic-bench.jsonl`
- All symlink targets exist: `file data/hf-dataset/data/*.jsonl` shows no broken links
- `python data/hf-dataset/validate.py --config bmlogic-bench` runs without path errors (if Python deps available)

---

### Phase 2: Move competitive-landscape.md to docs/research/ [IN PROGRESS]

**Goal**: Relocate the misplaced research document to the appropriate documentation directory and update all references.

**Tasks**:
- [ ] Run `git mv data/competitive-landscape.md docs/research/competitive-landscape.md`
- [ ] Update the reference in `data/README.md` from `[competitive-landscape.md](competitive-landscape.md)` to point to the new location
- [ ] Update `docs/research/README.md` to list `competitive-landscape.md` in its file inventory
- [ ] Search for any other references to `data/competitive-landscape.md` in the codebase and update them

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `data/competitive-landscape.md` -> `docs/research/competitive-landscape.md` (git mv)
- `data/README.md` - update internal link
- `docs/research/README.md` - add file to inventory

**Verification**:
- `docs/research/competitive-landscape.md` exists and has correct content
- `grep -r "data/competitive-landscape" .` returns no results (all references updated)

---

### Phase 3: Write new data/README.md [NOT STARTED]

**Goal**: Replace the current `data/README.md` (which is a HuggingFace dataset card, too long and specialized for a directory README) with a proper lightweight directory navigation document. Preserve the original as `data/dataset-card.md`.

**Tasks**:
- [ ] Rename `data/README.md` to `data/dataset-card.md` via `git mv` (preserves the HF card content for reference)
- [ ] Write a new `data/README.md` (~50-70 lines) following Template D from the directory README standard:
  - Purpose statement: canonical dataset storage for BMLogic project
  - File inventory table: list all JSONL files, metadata files, croissant.json, scripts/, hf-dataset/
  - Quick reference: key commands for dataset generation, validation
  - Links: to `hf-dataset/README.md` for HuggingFace dataset card, to `docs/research/competitive-landscape.md` for competitive analysis, to `hf-dataset/PUBLISHING.md` for publishing workflow
- [ ] Update the reference in Phase 2 (the competitive-landscape link) to work with the new README content

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `data/README.md` -> `data/dataset-card.md` (git mv)
- `data/README.md` (new file, lightweight directory README)

**Verification**:
- `data/README.md` exists and is a lightweight directory README (~50-70 lines)
- `data/dataset-card.md` exists and contains the original HF dataset card content
- All links in the new README resolve to existing files

---

### Phase 4: Update cross-references and final validation [NOT STARTED]

**Goal**: Ensure all cross-references across the repository are consistent and perform end-to-end validation.

**Tasks**:
- [ ] Search the entire codebase for references to `hf-dataset/` (excluding `data/hf-dataset/`) and update any stale paths
- [ ] Check `data/bmlogic-bench-splits.json` for any references that need updating
- [ ] Check `data/croissant.json` for any local path references that need updating
- [ ] Verify `data/.gitignore` needs no changes
- [ ] Run `lake build` to confirm no Lean source files are affected
- [ ] Run `scripts/readme-lint.sh` if available to check for broken links
- [ ] Verify the complete file tree under `data/` is as expected

**Timing**: 30 minutes

**Depends on**: 1, 2, 3

**Files to modify**:
- Various files if stale `hf-dataset/` references are found
- `data/croissant.json` - if local path references exist
- `data/bmlogic-bench-splits.json` - if path references exist

**Verification**:
- `grep -r "hf-dataset/" . --include="*.md" --include="*.py" --include="*.json" --include="*.lean" | grep -v "data/hf-dataset/"` returns no results
- `lake build` passes (no Lean regressions)
- `ls -la data/hf-dataset/data/` shows 4 valid symlinks
- `find data/ -type l ! -exec test -e {} \; -print` returns empty (no broken symlinks)

## Testing & Validation

- [ ] All 4 symlinks in `data/hf-dataset/data/` resolve correctly
- [ ] `competitive-landscape.md` accessible at `docs/research/competitive-landscape.md`
- [ ] `data/README.md` is a lightweight directory README (not the HF dataset card)
- [ ] `data/dataset-card.md` preserves the original HF dataset card content
- [ ] No references to root-level `hf-dataset/` remain in the codebase
- [ ] `lake build` passes with no errors
- [ ] No broken symlinks anywhere under `data/`

## Artifacts & Outputs

- `specs/222_consolidate_data_hf_dataset_directory/plans/02_consolidate-dirs-plan.md` (this plan)
- `specs/222_consolidate_data_hf_dataset_directory/summaries/02_consolidate-dirs-summary.md` (after implementation)

## Rollback/Contingency

All changes use `git mv` and are easily reversible:
1. `git mv data/hf-dataset/ hf-dataset/` to restore original location
2. Recreate symlinks with original relative paths (`../../data/X.jsonl`)
3. Revert `upload.py` and `validate.py` path constants
4. `git mv docs/research/competitive-landscape.md data/competitive-landscape.md`
5. `git mv data/dataset-card.md data/README.md` to restore original README
6. Or simply `git checkout HEAD -- .` to revert all changes
