# Implementation Plan: Task #223

- **Task**: 223 - Rename documentation files to lowercase kebab-case and update all references
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/223_rename_docs_lowercase_kebab_case/reports/01_rename-docs-research.md
- **Artifacts**: plans/02_rename-docs-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Rename 15 SCREAMING_SNAKE_CASE documentation files in `Theories/Bimodal/docs/` to lowercase kebab-case, update all ~355 references across `.md`, `.lean`, and `.claude/context/` files, add a file naming convention section to `readme-standard.md`, and verify no new broken links are introduced. The work is organized into four phases: bulk file renames via `git mv`, reference updates (grouped by scope and complexity), standards documentation update, and verification.

### Research Integration

Research report (01_rename-docs-research.md) provided:
- Complete inventory of 15 non-compliant files across 3 subdirectories (reference/, user-guide/, project-info/)
- Per-file reference counts and locations (IMPLEMENTATION_STATUS.md has 124 refs, highest)
- Identification of 14 Lean files with double-broken references (old directory name + old filename)
- Pre-existing lint baseline of 16 broken links (out of scope to fix, must not regress)
- Scripts directory confirmed already compliant; Python scripts excluded from scope

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items are directly advanced by this task. This is a naming hygiene task that improves codebase consistency.

## Goals & Non-Goals

**Goals**:
- Rename all 15 SCREAMING_SNAKE_CASE documentation files to lowercase kebab-case
- Update all references across the Theories/Bimodal/ tree, root docs, and .claude/context/
- Fix double-broken references in Lean source files (wrong directory name + wrong filename)
- Add a "File Naming Convention" section to readme-standard.md prescribing kebab-case
- Verify no new broken links are introduced (lint count stays at baseline 16)

**Non-Goals**:
- Renaming README.md files (universal convention, excluded)
- Renaming Python scripts in scripts/ (idiomatic snake_case, excluded)
- Fixing pre-existing broken links unrelated to the rename (16 baseline issues)
- Updating references in specs/archive/ (historical records)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Missing references during update (especially IMPLEMENTATION_STATUS.md with 124 refs) | H | M | Use automated sed substitution, then grep verification for zero remaining old-name references |
| Double-broken Lean references (wrong dir + wrong filename) require two corrections | M | H | Fix both directory and filename in a single sed pass per file |
| Pre-existing lint failures confuse post-rename verification | L | M | Record baseline count (16) before rename; verify count does not increase |
| Case-sensitive filesystems may cause git mv issues | L | L | Use git mv which handles case changes correctly on Linux |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Rename All 15 Files [COMPLETED]

**Goal**: Perform all file renames via `git mv` in a single atomic operation.

**Tasks**:
- [x] Run `scripts/readme-lint.sh` and record baseline broken link count (expected: 16) *(completed: baseline confirmed 16 broken links)*
- [x] Rename 3 files in `Theories/Bimodal/docs/reference/`: *(completed)*
  - `git mv AXIOM_REFERENCE.md axiom-reference.md`
  - `git mv OPERATORS.md operators.md`
  - `git mv TACTIC_REFERENCE.md tactic-reference.md`
- [x] Rename 7 files in `Theories/Bimodal/docs/user-guide/`: *(completed)*
  - `git mv ARCHITECTURE.md architecture.md`
  - `git mv EXAMPLES.md examples.md`
  - `git mv PROOF_PATTERNS.md proof-patterns.md`
  - `git mv QUICKSTART.md quickstart.md`
  - `git mv TACTIC_DEVELOPMENT.md tactic-development.md`
  - `git mv TROUBLESHOOTING.md troubleshooting.md`
  - `git mv TUTORIAL.md tutorial.md`
- [x] Rename 5 files in `Theories/Bimodal/docs/project-info/`: *(completed)*
  - `git mv IMPLEMENTATION_STATUS.md implementation-status.md`
  - `git mv KNOWN_LIMITATIONS.md known-limitations.md`
  - `git mv PERFORMANCE_TARGETS.md performance-targets.md`
  - `git mv TACTIC_REGISTRY.md tactic-registry.md`
  - `git mv TEST_COVERAGE.md test-coverage.md`
- [x] Verify all 15 renames succeeded with `git status` *(completed: 15 renames confirmed staged)*

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/docs/reference/` - 3 files renamed
- `Theories/Bimodal/docs/user-guide/` - 7 files renamed
- `Theories/Bimodal/docs/project-info/` - 5 files renamed

**Verification**:
- `git status` shows 15 renames staged
- No old-name files remain in any of the 3 directories
- `ls Theories/Bimodal/docs/reference/ Theories/Bimodal/docs/user-guide/ Theories/Bimodal/docs/project-info/` confirms all filenames are lowercase kebab-case (plus README.md)

---

### Phase 2: Update All References [NOT STARTED]

**Goal**: Systematically update all ~355 references to renamed files across the entire codebase (excluding specs/archive/).

**Tasks**:
- [ ] Update references in `Theories/Bimodal/docs/` markdown files (bulk sed substitution for all 15 old-to-new filename mappings)
- [ ] Update references in root-level `README.md`
- [ ] Update references in `docs/` tree (root docs/ directory)
- [ ] Update self-references within the renamed files themselves (e.g., internal cross-refs)
- [ ] Fix double-broken references in 14 `.lean` files that use old directory names (`UserGuide/`, `ProjectInfo/`) AND old filenames -- update both directory path and filename in one pass:
  - `docs/UserGuide/ARCHITECTURE.md` -> `docs/user-guide/architecture.md`
  - `docs/ProjectInfo/TACTIC_DEVELOPMENT.md` -> `docs/user-guide/tactic-development.md`
  - `docs/ProjectInfo/IMPLEMENTATION_STATUS.md` -> `docs/project-info/implementation-status.md`
  - `docs/ProjectInfo/TACTIC_REGISTRY.md` -> `docs/project-info/tactic-registry.md`
- [ ] Update bare filename references in `.claude/context/` files (text mentions like `TACTIC_REGISTRY.md` -> `tactic-registry.md`)
- [ ] Update references in active `specs/` task artifacts (non-archived)
- [ ] Run comprehensive grep verification for each old filename to confirm zero remaining references (excluding specs/archive/):
  ```
  grep -rn "AXIOM_REFERENCE\|TACTIC_REFERENCE\|OPERATORS\|IMPLEMENTATION_STATUS\|TACTIC_REGISTRY\|ARCHITECTURE\|TUTORIAL\|EXAMPLES\|QUICKSTART\|TROUBLESHOOTING\|TACTIC_DEVELOPMENT\|PROOF_PATTERNS\|PERFORMANCE_TARGETS\|KNOWN_LIMITATIONS\|TEST_COVERAGE" \
    Theories/Bimodal/ docs/ README.md .claude/context/ specs/ \
    --include="*.md" --include="*.lean" \
    | grep -v "specs/archive/"
  ```

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `README.md` (root) - update doc links
- `docs/README.md` and subdirectories - update cross-references
- `Theories/Bimodal/docs/**/*.md` - update all internal cross-references (largest batch)
- `Theories/Bimodal/README.md` - update doc links
- `Theories/Bimodal/**/*.lean` - fix double-broken references in ~14 files
- `.claude/context/**/*.md` - update bare filename mentions
- Active `specs/` files - update any cross-references

**Verification**:
- grep for all 15 old filenames returns zero matches (excluding specs/archive/)
- No new broken references introduced in the files that were edited

---

### Phase 3: Update Documentation Standards [NOT STARTED]

**Goal**: Add a file naming convention section to `readme-standard.md` to prescribe lowercase kebab-case going forward.

**Tasks**:
- [ ] Add a "File Naming Convention" section to `Theories/Bimodal/docs/reference/readme-standard.md` containing:
  - Rule: All `.md` files in `Theories/Bimodal/docs/` must use lowercase kebab-case (e.g., `axiom-reference.md`, `implementation-status.md`)
  - Exception: `README.md` is excluded (universal convention)
  - Rationale: Consistency with repository-wide kebab-case convention for documentation
  - Examples: `AXIOM_REFERENCE.md` -> `axiom-reference.md`, `TACTIC_DEVELOPMENT.md` -> `tactic-development.md`
- [ ] Review `Theories/Bimodal/docs/reference/docstring-standard.md` to confirm no filename convention section is needed (covers `.lean` files only)

**Timing**: 15 minutes

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/docs/reference/readme-standard.md` - add naming convention section

**Verification**:
- New section exists in readme-standard.md with clear kebab-case prescription
- Section includes the README.md exception

---

### Phase 4: Verification and Cleanup [NOT STARTED]

**Goal**: Run full verification suite to confirm no regressions.

**Tasks**:
- [ ] Run `scripts/readme-lint.sh` and compare broken link count to Phase 1 baseline (must not increase from 16)
- [ ] Run final grep verification for all 15 old filenames across entire project (excluding specs/archive/)
- [ ] Spot-check 3-5 high-reference files (IMPLEMENTATION_STATUS.md with 124 refs, ARCHITECTURE.md with 49 refs, TACTIC_REGISTRY.md with 38 refs) to confirm links resolve correctly
- [ ] Verify `lake build` still passes (documentation renames should not affect Lean build, but confirm no import path issues)

**Timing**: 30 minutes

**Depends on**: 3

**Files to modify**:
- None (verification only)

**Verification**:
- readme-lint.sh broken count <= 16 (baseline)
- Zero grep matches for old filenames outside specs/archive/
- lake build passes
- High-reference files confirmed correct

## Testing & Validation

- [ ] Pre-rename lint baseline recorded (expected: 16 broken links)
- [ ] All 15 files renamed successfully (git status confirms)
- [ ] Zero old-name references remain outside specs/archive/
- [ ] Post-rename lint count does not exceed baseline
- [ ] lake build passes
- [ ] readme-standard.md contains file naming convention section

## Artifacts & Outputs

- `specs/223_rename_docs_lowercase_kebab_case/plans/02_rename-docs-plan.md` (this file)
- 15 renamed documentation files in `Theories/Bimodal/docs/`
- Updated `Theories/Bimodal/docs/reference/readme-standard.md` with naming convention
- ~355 updated references across .md, .lean, and .claude/context/ files

## Rollback/Contingency

If the rename causes unexpected breakage:
1. `git checkout -- .` to revert all unstaged changes
2. If already committed, `git revert HEAD` to undo the commit
3. The rename is purely cosmetic and does not affect Lean compilation or logic
