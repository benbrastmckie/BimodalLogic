# Research Report: Task #222

**Task**: 222 - Consolidate data/ and hf-dataset/ into unified directory structure
**Started**: 2026-05-29T00:00:00Z
**Completed**: 2026-05-29T00:00:00Z
**Effort**: small (3-4 hours estimated for implementation)
**Dependencies**: None
**Sources/Inputs**: Codebase (direct file inspection), git LFS config, data/ and hf-dataset/ inventories
**Artifacts**: - specs/222_consolidate_data_hf_dataset_directory/reports/01_consolidate-dirs-research.md
**Standards**: report-format.md, artifact-formats.md

---

## Executive Summary

- `data/` holds 70 MB of canonical JSONL datasets, metadata, a scripts/ subdirectory, Croissant metadata, and a 411-line `competitive-landscape.md` document; all data files are production artifacts with well-defined roles.
- `hf-dataset/` is a packaging directory, not a second data store: it holds HuggingFace upload/validate scripts, a dataset card README (the HF version), PUBLISHING.md, and a `data/` subdirectory containing only four symlinks pointing back into `data/`.
- There is no data duplication between the two directories: `hf-dataset/data/` is entirely symlinks.
- The two concerns are genuinely different: `data/` = canonical dataset storage + generation pipeline artifacts; `hf-dataset/` = HuggingFace publishing tooling.
- Recommended approach: keep `data/` as-is for canonical data; move `hf-dataset/` tooling into `data/publishing/` (or a top-level `publishing/`) to unify under one root; move `competitive-landscape.md` to `docs/research/`; add lightweight README.md to `data/` following the repository standard.
- No breaking changes to Lean executables, Python scripts, or git LFS configuration are required as long as symlinks within `data/publishing/data/` (or equivalent) are updated to remain valid.

---

## Context & Scope

The task asks to consolidate `data/` and `hf-dataset/` into a single coherent directory, add README.md files, and relocate extended documentation to `docs/`. This research inventories both directories completely, traces all cross-references in the codebase, and proposes a unified structure with risk analysis.

---

## Findings

### 1. Complete File Inventory: `data/`

Total size: ~70 MB

| File | Size | Purpose | Git tracked? |
|------|------|---------|--------------|
| `bmlogic-c5.jsonl` | 1.4 MB | Training set, complexity ≤5, 1,513 records | Yes (direct) |
| `bmlogic-c7.jsonl` | 53 MB | Training set, complexity ≤7, 49,904 records | Yes (git LFS) |
| `bmlogic-bench.jsonl` | 672 KB | Evaluation benchmark, 727 records | Yes (direct) |
| `proof_steps.jsonl` | 15 MB | Proof step supervision, 2,424 records | Yes (git LFS) |
| `bmlogic-c5_metadata.json` | 4 KB | Companion metadata for bmlogic-c5 | Yes |
| `bmlogic-c7_metadata.json` | 4 KB | Companion metadata for bmlogic-c7 | Yes |
| `bmlogic-bench_metadata.json` | 4 KB | Companion metadata for bmlogic-bench | Yes |
| `proof_steps_metadata.json` | 4 KB | Companion metadata for proof_steps | Yes |
| `bmlogic-bench-splits.json` | 24 KB | Cross-logic split definitions (4 slices) | Yes |
| `croissant.json` | 24 KB | MLCommons Croissant 1.0 machine-readable metadata | Yes |
| `competitive-landscape.md` | 28 KB (411 lines) | 13-dimension feature comparison across 12 benchmarks | Yes |
| `README.md` | 16 KB | HuggingFace dataset card (YAML frontmatter + full documentation) | Yes |
| `.gitignore` | ~1 KB | Excludes intermediate pipeline artifacts | Yes |
| `scripts/generate_splits.py` | — | Generates bmlogic-bench-splits.json | Yes |

**Git LFS tracked files** (from `.gitattributes` at repo root):
- `data/bmlogic-c7.jsonl` (~52 MB)
- `data/proof_steps.jsonl` (~14.7 MB)

**`.gitignore` exclusions** (intermediate/regenerable files):
- `axiom-instances.jsonl`, `bmlogic-bench-candidates.jsonl`, `bmlogic-bench-validated.jsonl`
- `test*.jsonl`, `test*_metadata.json`, `smoke-test.jsonl`, `smoke-test_metadata.json`
- Superseded: `bmlogic-medium.jsonl`, `bmlogic-deep.jsonl` (removed in Task 214)

### 2. Complete File Inventory: `hf-dataset/`

Total size: ~60 KB (excluding symlink targets)

| File | Size | Purpose |
|------|------|---------|
| `README.md` | 16 KB | HuggingFace dataset card with YAML config frontmatter — **distinct** from `data/README.md` |
| `PUBLISHING.md` | 8 KB | Step-by-step guide for publishing to HuggingFace Hub (6 steps + troubleshooting) |
| `upload.py` | 12 KB | Script to upload all 4 configs to HuggingFace Hub |
| `validate.py` | 12 KB | Pre-upload validation: YAML frontmatter, record counts, required fields, label values |
| `requirements.txt` | ~1 KB | Python deps: datasets, huggingface_hub, pyarrow, pyyaml |
| `data/bmlogic-bench.jsonl` | symlink | -> `../../data/bmlogic-bench.jsonl` |
| `data/bmlogic-c5.jsonl` | symlink | -> `../../data/bmlogic-c5.jsonl` |
| `data/bmlogic-c7.jsonl` | symlink | -> `../../data/bmlogic-c7.jsonl` |
| `data/proof_steps.jsonl` | symlink | -> `../../data/proof_steps.jsonl` |

**Key observation**: `hf-dataset/data/` is 100% symlinks — no data is stored there. The HuggingFace upload scripts use `Path(__file__).parent.resolve()` as their base directory, so they resolve `data/bmlogic-bench.jsonl` relative to the script location.

### 3. Overlapping Concerns Analysis

| Concern | `data/` | `hf-dataset/` | Overlap? |
|---------|---------|---------------|----------|
| Dataset storage | Primary (canonical) | Symlinks only | No actual overlap |
| Dataset card / README | `data/README.md` (MIT license, generation commands, LFS info) | `hf-dataset/README.md` (CC BY 4.0, YAML configs, HF-formatted) | **Two different READMEs with different purposes and licenses** |
| Publishing workflow | None | `upload.py`, `validate.py`, `PUBLISHING.md` | No overlap |
| Metadata | `*_metadata.json` companion files | None | No overlap |
| Scripts | `scripts/generate_splits.py` | None | No overlap |
| Documentation | `competitive-landscape.md` | `PUBLISHING.md` | Different scopes |

**Critical finding**: The two READMEs serve different purposes. `data/README.md` is the developer-facing dataset reference (generation commands, schemas, LFS config). `hf-dataset/README.md` is the HuggingFace dataset card (YAML frontmatter with `configs:` block that HF Hub parses, CC BY 4.0 license, HF-specific structure). They must remain separate or be carefully distinguished.

### 4. Cross-References in the Codebase

**Lean source files** (`Theories/Bimodal/Automation/`) — all reference `data/` with hardcoded default paths:
- `BenchmarkOracle.lean`: `data/bmlogic-bench-candidates.jsonl`, `data/bmlogic-bench-validated.jsonl`
- `FormulaMutator.lean`: `data/contrastive_pairs.jsonl`
- `ProofStepExport.lean`: `data/proof_steps.jsonl`
- `DatasetExport.lean`: `data/bmlogic.jsonl`
- `BenchmarkAnchors.lean`: `data/axiom-instances.jsonl`

All of these are configurable via `--output`/`--input` CLI flags; the hardcoded paths are defaults only.

**Python scripts** (`scripts/`) — all reference `data/` paths:
- `curate_benchmark.py`: `data/bmlogic-c5.jsonl`, `data/bmlogic-c7.jsonl`, `data/axiom-instances.jsonl`, `data/bmlogic-bench-candidates.jsonl`
- `finalize_benchmark.py`: `data/bmlogic-bench-validated.jsonl`, `data/bmlogic-bench.jsonl`, `data/bmlogic-bench_metadata.json`
- `validate_benchmark.py`: `data/bmlogic-bench-validated.jsonl`, `data/bmlogic-c5.jsonl`, `data/bmlogic-c7.jsonl`
- `validate_datasets.py`: `data/bmlogic-bench.jsonl`, `data/bmlogic-c5.jsonl` (and others)
- `standardize_metadata.py`: references `data/` paths
- `run_dataset_generation.sh`: outputs to `data/*.jsonl` throughout
- `data/scripts/generate_splits.py`: references `data/bmlogic-bench.jsonl`, `data/scripts/generate_splits.py`

**HuggingFace scripts** (`hf-dataset/`) — use path-relative resolution:
- `upload.py`: resolves `data/bmlogic-bench.jsonl` etc. relative to `Path(__file__).parent` (i.e., `hf-dataset/`)
- `validate.py`: same pattern

**Croissant and splits JSON**:
- `data/croissant.json`: references HuggingFace CDN URLs containing `/data/` in path
- `data/bmlogic-bench-splits.json`: references `data/bmlogic-bench.jsonl` and `data/scripts/generate_splits.py`

**Git configuration**:
- `.gitattributes` (repo root): tracks `data/bmlogic-c7.jsonl` and `data/proof_steps.jsonl` via LFS

**Root README.md**: references `docs/training/pipeline.md` but does not directly reference `data/` or `hf-dataset/` paths.

**Lakefile (`lakefile.lean`)**: contains comments referencing `data/` output paths but no build rules that produce/consume `data/` files directly.

### 5. What Constitutes "Extended Documentation" for `docs/`

The file `data/competitive-landscape.md` (411 lines, 28 KB) is research-level documentation — a 13-dimension competitive analysis across 12 benchmarks. It does not belong in the dataset directory; it belongs in `docs/research/` alongside `BIMODAL_LOGIC.md`, `DUAL_VERIFICATION.md`, and similar research documents.

`hf-dataset/PUBLISHING.md` (step-by-step HuggingFace publishing workflow) is operational documentation for the publishing process. It should stay close to the publishing scripts.

### 6. Documentation Standards Reference

From `docs/development/DIRECTORY_README_STANDARD.md`:
- `data/` qualifies for a README under "top-level source directory" or "directory with 3+ subdirectories" — it has 1 subdirectory (`scripts/`) but 14+ files at root level.
- Template D (lightweight, 40-70 lines) applies: purpose statement, file listing, quick reference, regeneration commands, links to full documentation.
- The existing `data/README.md` is much longer (16 KB) because it doubles as a HuggingFace dataset card. A proper directory README should be separated from the HF dataset card.

### 7. Repository Documentation Conventions

Docs follow lowercase kebab-case naming (per task 183 / task 223). New README files should use `README.md` (uppercase, standard convention preserved). New markdown docs that move to `docs/` should follow lowercase kebab-case (e.g., `competitive-landscape.md` keeps its name, already correct).

---

## Proposed Unified Structure

```
data/
├── README.md                          # Directory README (new, lightweight ~50 lines)
│                                      # Links to dataset-card.md and docs/research/
├── dataset-card.md                    # HuggingFace dataset card content
│                                      # (renamed from hf-dataset/README.md; YAML frontmatter preserved)
│                                      # OR: keep hf-dataset/README.md in place and just update symlinks
├── bmlogic-c5.jsonl                   # Training set, complexity ≤5 (unchanged)
├── bmlogic-c5_metadata.json           # Metadata (unchanged)
├── bmlogic-c7.jsonl                   # Training set, complexity ≤7, LFS (unchanged)
├── bmlogic-c7_metadata.json           # Metadata (unchanged)
├── bmlogic-bench.jsonl                # Benchmark (unchanged)
├── bmlogic-bench_metadata.json        # Metadata (unchanged)
├── bmlogic-bench-splits.json          # Cross-logic splits (unchanged)
├── proof_steps.jsonl                  # Proof steps, LFS (unchanged)
├── proof_steps_metadata.json          # Metadata (unchanged)
├── croissant.json                     # Croissant metadata (unchanged)
├── .gitignore                         # Unchanged
├── scripts/
│   ├── README.md                      # New: brief directory README (optional, <3 files rule)
│   └── generate_splits.py             # Unchanged
└── publishing/                        # NEW: moved from hf-dataset/
    ├── README.md                      # New: brief, links to PUBLISHING.md and upload.py
    ├── README-hf.md                   # Renamed from hf-dataset/README.md (HF dataset card)
    │                                  # OR keep as README.md (HF expects this name)
    ├── PUBLISHING.md                  # Unchanged, moved from hf-dataset/
    ├── upload.py                      # Updated: path resolution to ../bmlogic-bench.jsonl etc.
    ├── validate.py                    # Updated: path resolution
    ├── requirements.txt               # Unchanged, moved from hf-dataset/
    └── data/                          # Symlinks updated to ../../bmlogic-bench.jsonl etc.
        ├── bmlogic-bench.jsonl -> ../../bmlogic-bench.jsonl
        ├── bmlogic-c5.jsonl    -> ../../bmlogic-c5.jsonl
        ├── bmlogic-c7.jsonl    -> ../../bmlogic-c7.jsonl
        └── proof_steps.jsonl   -> ../../proof_steps.jsonl

docs/research/
└── competitive-landscape.md           # MOVED from data/competitive-landscape.md
```

**Alternative (simpler): keep `hf-dataset/` name but move under `data/`**

```
data/
├── README.md                          # New directory README (lightweight)
├── [all existing JSONL/JSON/scripts unchanged]
└── hf-dataset/                        # Moved from root: git mv hf-dataset/ data/hf-dataset/
    ├── README.md                      # HF dataset card (unchanged content)
    ├── PUBLISHING.md                  # Unchanged
    ├── upload.py                      # Path updated: `data/` -> `../`
    ├── validate.py                    # Path updated: `data/` -> `../`
    ├── requirements.txt               # Unchanged
    └── data/                          # Symlinks updated: ../../data/ -> ../../
        ├── bmlogic-bench.jsonl -> ../../bmlogic-bench.jsonl
        └── ...
```

**Recommendation**: The "move under `data/hf-dataset/`" alternative is simpler and lower risk. It makes the relationship explicit (HF tooling is part of the data ecosystem), requires only path updates to upload.py, validate.py, and the 4 symlinks, and avoids renaming any user-facing files.

---

## Decisions

- **`competitive-landscape.md`** should move to `docs/research/competitive-landscape.md` — it is a research document, not a dataset file. The `data/README.md` reference to it (`[competitive-landscape.md](competitive-landscape.md)`) would need updating to `[competitive-landscape.md](../docs/research/competitive-landscape.md)`.
- **`hf-dataset/README.md`** is a HuggingFace dataset card, not a directory README — it must keep the name `README.md` because HuggingFace Hub expects this specific filename for dataset cards. Do not rename it.
- **A new `data/README.md`** is needed as a proper directory navigation document (lightweight, Template D). The current `data/README.md` is the HF dataset card and is too long/specialized for this role. After moving `hf-dataset/` under `data/hf-dataset/`, `data/README.md` would serve as the directory README pointing to `hf-dataset/README.md` for the HF card.
- **Scripts' default paths**: All defaults (Lean executables and Python scripts) use `data/` relative to working directory. As long as users run from the repo root, moving `hf-dataset/` under `data/` does not affect them.

---

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Symlink breakage in `hf-dataset/data/` after move | Medium | Recreate symlinks with updated relative paths (`../../bmlogic-bench.jsonl` becomes `../../bmlogic-bench.jsonl` if structure is `data/hf-dataset/data/`); test with `ls -la` after |
| `upload.py` and `validate.py` path resolution breaks | Medium | Both use `Path(__file__).parent.resolve()` — updating DATASET_CONFIGS paths from `data/*.jsonl` to `../bmlogic-bench.jsonl` etc. fixes it |
| Broken references in `data/README.md` to `competitive-landscape.md` | Low | Update the single reference in the dataset overview section to the new docs/ path |
| Git history fragmentation for moved files | Low | Use `git mv` to preserve history; git tracks renames reasonably well for text files |
| Git LFS pointers for `.gitattributes` | Low | `.gitattributes` paths (`data/bmlogic-c7.jsonl`, `data/proof_steps.jsonl`) stay the same — JSONL files do not move, only hf-dataset/ does |
| CI/CD impact | Low | No CI/CD configuration found referencing `hf-dataset/` directly; validate by checking `.github/workflows/` |
| HuggingFace upload workflow disruption | Low | Users running from `data/hf-dataset/` need to update their working directory; document in PUBLISHING.md |
| `competitive-landscape.md` cross-references | Low | Check that `data/README.md` is the only file linking to it; update the link after move |

**CI/CD check**: The repository has a GitHub Actions badge referencing `ProofChecker/actions/workflows/ci.yml`. No explicit references to `data/` or `hf-dataset/` were found in the codebase outside of script defaults and documentation; the CI likely only builds Lean code.

---

## Implementation Sequence (for planning)

1. Move `competitive-landscape.md` to `docs/research/competitive-landscape.md` (git mv)
2. Update reference in `data/README.md` from `[competitive-landscape.md](competitive-landscape.md)` to the new path
3. Move `hf-dataset/` to `data/hf-dataset/` (git mv)
4. Recreate symlinks in `data/hf-dataset/data/` with corrected relative paths
5. Update path resolution in `data/hf-dataset/upload.py` (DATASET_CONFIGS `file` values: `data/X.jsonl` -> `../X.jsonl`)
6. Update path resolution in `data/hf-dataset/validate.py` (CONFIG_FILES values same update)
7. Write new `data/README.md` (lightweight directory README, ~50 lines, Template D)
8. Write `data/hf-dataset/README.md` is left unchanged (it is the HF dataset card)
9. Validate: `ls -la data/hf-dataset/data/`, run `python data/hf-dataset/validate.py --config bmlogic-bench`
10. Update `docs/README.md` `research/` section to include `competitive-landscape.md`
11. Optionally add `data/scripts/README.md` (only 1 file, so per standard it may not need one)

---

## Context Extension Recommendations

- **Topic**: Dataset directory conventions and HuggingFace publishing workflow
- **Gap**: No existing context file documents how `data/` and publishing tooling are organized in this project
- **Recommendation**: After implementation, the new `data/README.md` and `data/hf-dataset/README.md` serve as self-documenting context; no additional `.claude/context/` file needed

---

## Appendix

### Search Queries Used

- `find /home/benjamin/Projects/BimodalLogic/data -type f -o -type d`
- `find /home/benjamin/Projects/BimodalLogic/hf-dataset -type f -o -type d`
- `grep -r "data/" ... --include="*.py" --include="*.lean" --include="*.sh" -l`
- `grep -r "hf-dataset" ... -l`
- `git -C ... lfs track`

### Key File Paths Examined

- `/home/benjamin/Projects/BimodalLogic/data/README.md` — 349 lines, HF dataset card
- `/home/benjamin/Projects/BimodalLogic/hf-dataset/README.md` — 328 lines, HF dataset card (alternate version)
- `/home/benjamin/Projects/BimodalLogic/hf-dataset/PUBLISHING.md` — 214 lines, publish guide
- `/home/benjamin/Projects/BimodalLogic/hf-dataset/upload.py` — 303 lines
- `/home/benjamin/Projects/BimodalLogic/hf-dataset/validate.py` — 363 lines
- `/home/benjamin/Projects/BimodalLogic/docs/development/DIRECTORY_README_STANDARD.md` — repository README standards
- `/home/benjamin/Projects/BimodalLogic/.gitattributes` — LFS configuration
