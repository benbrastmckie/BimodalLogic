# Research Report: Task #223

**Task**: 223 - Rename documentation files to lowercase kebab-case and update all references
**Started**: 2026-05-29T00:00:00Z
**Completed**: 2026-05-29T00:30:00Z
**Effort**: 2-4 hours (estimated in task)
**Dependencies**: None
**Sources/Inputs**: Codebase (find/grep), git log, scripts/readme-lint.sh execution
**Artifacts**: specs/223_rename_docs_lowercase_kebab_case/reports/01_rename-docs-research.md
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- 15 documentation files in `Theories/Bimodal/docs/` use SCREAMING_SNAKE_CASE and must be renamed to lowercase kebab-case.
- These 15 files have approximately 355 references scattered across `.md`, `.lean`, and `.claude/context/` files — with `IMPLEMENTATION_STATUS.md` alone having 124 references.
- Scripts in `scripts/` are already either kebab-case (`readme-lint.sh`, `readme-inventory.sh`) or use Python/shell snake_case convention (`run_dataset_generation.sh`, `*.py`) — the Python/shell scripts are **out of scope** for this rename.
- `readme-standard.md` and `docstring-standard.md` do not currently prescribe a file naming convention; they must be updated to add a section prescribing lowercase kebab-case for documentation files.
- `readme-lint.sh` currently has 16 pre-existing broken links (path resolution issues) that are unrelated to the rename and should not regress further after the rename.

---

## Context & Scope

### Primary Scope (files to rename)

The task targets files in `Theories/Bimodal/docs/reference/`, `Theories/Bimodal/docs/user-guide/`, and `Theories/Bimodal/docs/project-info/` that use SCREAMING_SNAKE_CASE. `README.md` is excluded: it is a universal convention name that should not be changed.

The task description mentions "scripts/" but both shell scripts that belong to this area (`readme-lint.sh`, `readme-inventory.sh`) are already lowercase kebab-case. The Python scripts (`curate_benchmark.py`, `generate_dataset.py`, etc.) use Python's standard snake_case convention and are out of scope.

### Reference Update Scope

References must be updated across:
- All `.md` files in `Theories/Bimodal/` and `docs/` trees
- Root `README.md`
- Lean source files (`.lean`) in `Theories/Bimodal/` that cite docs in comments
- `.claude/context/` files that reference registry filenames
- `specs/` files where cross-references appear in active (non-archived) task artifacts

Archived specs (`specs/archive/`) are **not** updated — historical records should remain accurate to the time they were written.

---

## Findings

### Non-Compliant Files — Complete Inventory

#### docs/reference/ (3 files)

| Current Name | Proposed Kebab-Case Name | Reference Count |
|---|---|---|
| `AXIOM_REFERENCE.md` | `axiom-reference.md` | 18 |
| `OPERATORS.md` | `operators.md` | 9 |
| `TACTIC_REFERENCE.md` | `tactic-reference.md` | 8 |

Already compliant (created by task 183): `readme-standard.md`, `docstring-standard.md`, `comment-convention.md`

#### docs/user-guide/ (7 files)

| Current Name | Proposed Kebab-Case Name | Reference Count |
|---|---|---|
| `ARCHITECTURE.md` | `architecture.md` | 49 |
| `TUTORIAL.md` | `tutorial.md` | 25 |
| `TACTIC_DEVELOPMENT.md` | `tactic-development.md` | 19 |
| `EXAMPLES.md` | `examples.md` | 18 |
| `PROOF_PATTERNS.md` | `proof-patterns.md` | 10 |
| `QUICKSTART.md` | `quickstart.md` | 14 |
| `TROUBLESHOOTING.md` | `troubleshooting.md` | 5 |

#### docs/project-info/ (5 files)

| Current Name | Proposed Kebab-Case Name | Reference Count |
|---|---|---|
| `IMPLEMENTATION_STATUS.md` | `implementation-status.md` | 124 |
| `TACTIC_REGISTRY.md` | `tactic-registry.md` | 38 |
| `PERFORMANCE_TARGETS.md` | `performance-targets.md` | 8 |
| `KNOWN_LIMITATIONS.md` | `known-limitations.md` | 9 |
| `TEST_COVERAGE.md` | `test-coverage.md` | 1 |

**Total: 15 files to rename, ~355 total references to update.**

---

### Reference Locations Per File

#### AXIOM_REFERENCE.md (18 references)

| File | Line(s) |
|---|---|
| `README.md` (root) | 162 |
| `docs/README.md` | 33 |
| `docs/reference/README.md` | 15 |
| `Theories/Bimodal/docs/README.md` | 42, 81, 95 |
| `Theories/Bimodal/docs/user-guide/QUICKSTART.md` | 101, 140 |
| `Theories/Bimodal/docs/user-guide/EXAMPLES.md` | 965 |
| `Theories/Bimodal/docs/user-guide/TROUBLESHOOTING.md` | 401 |
| `Theories/Bimodal/docs/reference/TACTIC_REFERENCE.md` | 174 |
| `Theories/Bimodal/docs/user-guide/README.md` | 23 |
| `Theories/Bimodal/README.md` | 276 |
| `Theories/Bimodal/docs/user-guide/PROOF_PATTERNS.md` | 171 |
| `Theories/Bimodal/docs/reference/README.md` | 9, 32 |
| `Theories/Bimodal/ProofSystem/README.md` | 70 |
| `Theories/Bimodal/docs/reference/AXIOM_REFERENCE.md` | 253 (self-cross-ref in PROOF_PATTERNS) |

#### OPERATORS.md (9 references)

| File | Line(s) |
|---|---|
| `README.md` (root) | 163 |
| `docs/README.md` | 188 |
| `docs/development/DIRECTORY_README_STANDARD.md` | 315 |
| `docs/reference/README.md` | 15, 28 |
| `Theories/Bimodal/docs/README.md` | 44, 82, 96 |
| `Theories/Bimodal/docs/reference/README.md` | 47 |

Note: `docs/reference/README.md` line 15 links to `../../Theories/Bimodal/docs/reference/OPERATORS.md`; the `Theories/Bimodal/docs/reference/README.md` line 47 links to `../../../docs/reference/OPERATORS.md` which is already broken (that file does not exist at `docs/reference/OPERATORS.md`).

#### TACTIC_REFERENCE.md (8 references)

| File | Line(s) |
|---|---|
| `README.md` (root) | 164 |
| `docs/reference/README.md` | 15 |
| `Theories/Bimodal/README.md` | 277 |
| `Theories/Bimodal/docs/README.md` | 43 |
| `Theories/Bimodal/docs/user-guide/TROUBLESHOOTING.md` | 402 |
| `Theories/Bimodal/docs/user-guide/EXAMPLES.md` | 966 |
| `Theories/Bimodal/docs/reference/README.md` | 10, 43 |

#### ARCHITECTURE.md (49 references — highest non-registry count)

Spread across: `docs/architecture/ADR-001`, `docs/development/METAPROGRAMMING_GUIDE.md`, `docs/development/LEAN_STYLE_GUIDE.md`, `docs/user-guide/INTEGRATION.md`, `docs/development/DIRECTORY_README_STANDARD.md`, `docs/README.md`, `docs/research/BIMODAL_LOGIC.md`, `docs/research/DUAL_VERIFICATION.md`, `docs/research/PROOF_LIBRARY_DESIGN.md`, `Tests/BimodalTest/Integration/README.md`, and 14 Lean source files (`.lean`) in `Semantics/`, `Syntax/`, `ProofSystem/`, `Metalogic/`, `Theorems/`, and `Examples/`.

Note: Many Lean files use **already-broken paths** such as `docs/UserGuide/ARCHITECTURE.md` (the directory was previously `UserGuide/` and has since been renamed to `user-guide/`). These broken paths will need correction alongside the filename rename.

#### TUTORIAL.md (25 references)

Files: root `README.md`, `docs/README.md`, `docs/development/DIRECTORY_README_STANDARD.md`, `docs/user-guide/README.md`, `docs/user-guide/INTEGRATION.md`, `docs/development/DOC_QUALITY_CHECKLIST.md`, `Theories/Bimodal/docs/README.md`, `Theories/Bimodal/docs/user-guide/README.md`, `Theories/Bimodal/docs/user-guide/EXAMPLES.md`, `Theories/Bimodal/docs/reference/OPERATORS.md`, `Theories/Bimodal/docs/user-guide/ARCHITECTURE.md`, `Theories/Bimodal/docs/user-guide/QUICKSTART.md`.

#### TACTIC_DEVELOPMENT.md (19 references)

Files include Lean source: `Theories/Bimodal/Automation/AesopRules.lean` (line 52), `Theories/Bimodal/Automation/Tactics/Helpers.lean` (line 30). Both use old path `docs/ProjectInfo/TACTIC_DEVELOPMENT.md` which is double-broken (old `ProjectInfo/` dir name AND old filename). Also referenced from `docs/development/PHASED_IMPLEMENTATION.md`, `docs/development/DOC_QUALITY_CHECKLIST.md` (3 times), `docs/development/METAPROGRAMMING_GUIDE.md`, `docs/user-guide/README.md`, `Theories/Bimodal/docs/project-info/TACTIC_REGISTRY.md`, `Theories/Bimodal/docs/README.md`, and user-guide files.

#### EXAMPLES.md (18 references)

Files: `docs/README.md`, `docs/user-guide/README.md`, `docs/user-guide/INTEGRATION.md`, `docs/development/DIRECTORY_README_STANDARD.md` (2), `Theories/Bimodal/docs/README.md` (2), `Theories/Bimodal/docs/user-guide/README.md` (2), `Theories/Bimodal/docs/user-guide/TROUBLESHOOTING.md`, `Theories/Bimodal/docs/user-guide/TUTORIAL.md`, `Theories/Bimodal/docs/user-guide/ARCHITECTURE.md` (2), `Theories/Bimodal/docs/user-guide/QUICKSTART.md` (2).

#### IMPLEMENTATION_STATUS.md (124 references — largest count)

Spread across: `docs/project-info/IMPLEMENTATION_STATUS.md` (root project-info), `docs/project-info/SORRY_REGISTRY.md`, `docs/project-info/MAINTENANCE.md`, `.claude/context/standards/task-management.md` (mentions by name without path), `.claude/context/standards/git-safety.md`, `.claude/context/workflows/review-process.md`, all Theories/Bimodal project-info files, many Lean files, and numerous specs/.

The `.claude/context/` references use the bare filename without path, so they do not need path-corrected links — but the filename references must be updated to match the new name.

#### TACTIC_REGISTRY.md (38 references)

Appears in `.claude/context/standards/task-management.md`, `.claude/context/standards/git-safety.md`, `.claude/context/workflows/review-process.md`, `docs/project-info/FEATURE_REGISTRY.md`, `docs/project-info/SORRY_REGISTRY.md`, `docs/project-info/IMPLEMENTATION_STATUS.md`, `docs/project-info/MAINTENANCE.md`, Bimodal docs project-info files, and Lean files.

#### Remaining files (PROOF_PATTERNS.md, QUICKSTART.md, KNOWN_LIMITATIONS.md, TROUBLESHOOTING.md, PERFORMANCE_TARGETS.md, TEST_COVERAGE.md)

These have 5-14 references each, confined mainly to `Theories/Bimodal/docs/` files and root-level `docs/README.md`.

---

### Scripts Directory Assessment

| Script | Current Name Style | In Scope? | Notes |
|---|---|---|---|
| `readme-lint.sh` | kebab-case | N/A (already compliant) | The lint tool for this task |
| `readme-inventory.sh` | kebab-case | N/A (already compliant) | Inventory helper |
| `run_dataset_generation.sh` | snake_case | Out of scope | Shell script for ML pipeline, not docs |
| `*.py` files | snake_case | Out of scope | Python convention; not doc files |

---

### Standards Documents Requiring Updates

The following files in `docs/reference/` need a new "File Naming Convention" section added:

1. `Theories/Bimodal/docs/reference/readme-standard.md` — Add section prescribing lowercase kebab-case for all `.md` files in `Theories/Bimodal/docs/`
2. `Theories/Bimodal/docs/reference/docstring-standard.md` — No filename convention needed (covers `.lean` files only)

The task also requires ensuring the docs prescribe kebab-case **going forward**.

---

### readme-lint.sh: Pre-existing Broken Links

Running `scripts/readme-lint.sh` currently reports **16 broken links** that are pre-existing (prior to any rename). These fall into two categories:

1. **Cross-tree links** (from `Theories/Bimodal/docs/` to root `docs/`): relative paths that travel up past the `Theories/Bimodal/` root are wrong by 1-2 levels. Example: `Theories/Bimodal/docs/README.md` links to `../../docs/README.md` (resolves to `Theories/docs/README.md`, does not exist).

2. **Missing files**: `docs/reference/API_REFERENCE.md` is linked from reference README but does not exist; `docs/reference/OPERATORS.md` is linked but OPERATORS.md lives at `Theories/Bimodal/docs/reference/OPERATORS.md`.

These pre-existing issues are **out of scope** for this rename task, but the plan should note them to avoid confusion. After the rename, the lint count should not increase.

---

## Decisions

- **README.md excluded**: The name `README.md` is a universal filesystem and GitHub convention (case-sensitive by design). Do not rename.
- **Python scripts excluded**: `*.py` files in `scripts/` use Python snake_case which is idiomatic and expected by Python tooling. Do not rename.
- **`run_dataset_generation.sh` excluded**: This is an ML pipeline script, not a documentation file, and has a long history of references in archived specs.
- **Archived specs excluded**: Files in `specs/archive/` are historical records. References within them are not updated.
- **`.claude/context/` references**: The context files use bare filenames (e.g., `TACTIC_REGISTRY.md`) as names in text, not as file paths. These must be updated to use the new names.
- **Scope confirmation**: The user-guide/ and project-info/ non-compliant files are included because the task says "Audit Theories/Bimodal/docs/reference/ and scripts/" but the intent is to rename all task-183-era documentation. The rename of user-guide/ and project-info/ files is necessary for consistency.

---

## Risks & Mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| Missing a reference during manual update | Medium | Use `grep -rn` for each old filename after rename to verify 0 remaining refs |
| Pre-existing broken lint links confusing post-rename verification | Low | Run lint before rename, document baseline count (16 broken), verify count does not increase |
| Lean source files referencing old paths (double-broken: wrong dir name + wrong filename) | Medium | Fix both the directory name (`UserGuide/` -> `user-guide/`, `ProjectInfo/` -> `project-info/`) and the filename in one pass |
| References in `.claude/context/` use bare filenames in running text (not as links) | Low | Text search for `TACTIC_REGISTRY.md`, `IMPLEMENTATION_STATUS.md`, etc. in `.claude/context/*.md` and update |
| `IMPLEMENTATION_STATUS.md` has 124 references — highest risk of missing some | High | Use sed or automated substitution, followed by grep verification |
| Active (non-archived) specs reference old names | Medium | Check active task plans and reports in `specs/2xx_*` directories |

---

## Context Extension Recommendations

- **Topic**: File naming conventions for documentation in Theories/Bimodal/docs/
- **Gap**: No existing context file prescribes lowercase kebab-case for `.md` files in this tree; `readme-standard.md` covers README structure but not filename format.
- **Recommendation**: After the rename, add a "File Naming Convention" section to `Theories/Bimodal/docs/reference/readme-standard.md` prescribing lowercase kebab-case for all `.md` files in the docs tree.

---

## Appendix

### Search Commands Used

```bash
find Theories/Bimodal/docs/ -type f -name "*.md"   # inventory
grep -rn "AXIOM_REFERENCE" . --include="*.md" --include="*.lean"  # per-file refs
bash scripts/readme-lint.sh  # pre-rename baseline: 16 broken links
```

### Proposed Rename Map (complete)

```
Theories/Bimodal/docs/reference/AXIOM_REFERENCE.md    -> axiom-reference.md
Theories/Bimodal/docs/reference/OPERATORS.md           -> operators.md
Theories/Bimodal/docs/reference/TACTIC_REFERENCE.md   -> tactic-reference.md
Theories/Bimodal/docs/user-guide/ARCHITECTURE.md      -> architecture.md
Theories/Bimodal/docs/user-guide/EXAMPLES.md          -> examples.md
Theories/Bimodal/docs/user-guide/PROOF_PATTERNS.md    -> proof-patterns.md
Theories/Bimodal/docs/user-guide/QUICKSTART.md        -> quickstart.md
Theories/Bimodal/docs/user-guide/TACTIC_DEVELOPMENT.md -> tactic-development.md
Theories/Bimodal/docs/user-guide/TROUBLESHOOTING.md   -> troubleshooting.md
Theories/Bimodal/docs/user-guide/TUTORIAL.md          -> tutorial.md
Theories/Bimodal/docs/project-info/IMPLEMENTATION_STATUS.md -> implementation-status.md
Theories/Bimodal/docs/project-info/KNOWN_LIMITATIONS.md     -> known-limitations.md
Theories/Bimodal/docs/project-info/PERFORMANCE_TARGETS.md   -> performance-targets.md
Theories/Bimodal/docs/project-info/TACTIC_REGISTRY.md       -> tactic-registry.md
Theories/Bimodal/docs/project-info/TEST_COVERAGE.md         -> test-coverage.md
```

### Recommended Implementation Order

1. Rename all 15 files (git mv) in a single commit.
2. Update references in bulk using `sed -i` or similar, working file-by-file through the rename map.
3. Update Lean source docstrings (double-fix: wrong dir name AND wrong filename).
4. Update `readme-standard.md` to prescribe kebab-case naming.
5. Run `scripts/readme-lint.sh` and verify broken count = 16 (same baseline; no new breakage).
6. Run `grep -rn "AXIOM_REFERENCE\|TACTIC_REFERENCE\|OPERATORS\|IMPLEMENTATION_STATUS\|TACTIC_REGISTRY\|ARCHITECTURE\|TUTORIAL\|EXAMPLES\|QUICKSTART\|TROUBLESHOOTING\|TACTIC_DEVELOPMENT\|PROOF_PATTERNS\|PERFORMANCE_TARGETS\|KNOWN_LIMITATIONS\|TEST_COVERAGE" Theories/Bimodal/ docs/ README.md .claude/context/` to verify 0 remaining old-name references (outside archived specs).
