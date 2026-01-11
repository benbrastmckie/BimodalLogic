# Implementation Plan: Task #391

**Task**: Enforce directory naming convention for Lean projects
**Version**: 001
**Created**: 2026-01-12
**Language**: general

## Overview

Enforce a consistent directory naming convention across the ProofChecker project: directories containing Lean source code use PascalCase (capitalized), while all other directories use lowercase. This aligns with Lean 4 ecosystem conventions where module directories match their import paths.

### Current State Audit

| Directory | Contains Lean? | Current Case | Compliant? |
|-----------|----------------|--------------|------------|
| `Logos/` | Yes | PascalCase | ✓ |
| `Theories/` | Yes | PascalCase | ✓ |
| `Tests/` | Yes | PascalCase | ✓ |
| `docs/` | No (markdown) | PascalCase | ✗ → rename to `docs/` |
| `latex/` | No (latex/sty) | PascalCase | ✗ → rename to `latex/` |
| `benchmarks/` | No (scripts) | lowercase | ✓ |
| `scripts/` | No (scripts) | lowercase | ✓ |

## Phases

### Phase 1: Rename Documentation/ to docs/

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Rename `docs/` directory to `docs/`
2. Update all references to `docs/` across the codebase

**Files to modify**:
- `docs/` → `docs/` (directory rename)
- `README.md` - update documentation links
- `.claude/CLAUDE.md` - update project structure reference
- `.claude/ARCHITECTURE.md` - update if references exist
- Any other files referencing `docs/`

**Steps**:
1. Use `git mv Documentation docs` to rename with history preservation
2. Search for all references to `docs/` in the codebase
3. Update each reference to use `docs/`
4. Verify no broken links remain

**Verification**:
- `ls -la` shows `docs/` not `docs/`
- `grep -r "docs/" .` returns no results (excluding .git)
- All documentation links in README.md work

---

### Phase 2: Rename LaTeX/ to latex/

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Rename `latex/` directory to `latex/`
2. Update all references to `latex/` across the codebase

**Files to modify**:
- `latex/` → `latex/` (directory rename)
- Any files referencing `latex/`

**Steps**:
1. Use `git mv LaTeX latex` to rename with history preservation
2. Search for all references to `latex/` in the codebase
3. Update each reference to use `latex/`

**Verification**:
- `ls -la` shows `latex/` not `latex/`
- `grep -r "latex/" .` returns no results (excluding .git)

---

### Phase 3: Document the convention

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create or update project documentation with the naming convention
2. Ensure the standard is discoverable for contributors

**Files to modify**:
- `CONTRIBUTING.md` - add or create with conventions section
- `README.md` - add brief note about project structure conventions
- `.claude/CLAUDE.md` - update project structure section

**Steps**:
1. Check if `CONTRIBUTING.md` exists; create if not
2. Add "Directory Naming Convention" section explaining:
   - PascalCase for Lean source directories (import path alignment)
   - lowercase for all other directories
   - Examples of each category
3. Update README.md project structure section with brief note
4. Update `.claude/CLAUDE.md` project structure to reflect new names

**Documentation Content**:
```markdown
## Directory Naming Convention

This project follows Lean 4 ecosystem conventions for directory naming:

- **PascalCase** (capitalized): Directories containing Lean source code
  - These match Lean's import path requirements
  - Examples: `Logos/`, `Theories/`, `Tests/`

- **lowercase**: All other directories
  - Examples: `docs/`, `scripts/`, `benchmarks/`, `latex/`

This convention ensures:
1. Lean imports work correctly (`import Theories.Bimodal`)
2. Alignment with standard conventions (`docs/`, `scripts/`)
3. Visual distinction between code and non-code directories
```

**Verification**:
- CONTRIBUTING.md exists and contains convention documentation
- README.md project structure section is accurate
- Convention is clearly explained

---

## Dependencies

- None (self-contained refactoring task)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Broken internal links | Medium | Medium | Thorough grep search before/after |
| Git history confusion | Low | Low | Use `git mv` for rename |
| CI/CD path issues | Medium | Low | Check any CI configs for hardcoded paths |

## Success Criteria

- [ ] `docs/` renamed to `docs/`
- [ ] `latex/` renamed to `latex/`
- [ ] All internal references updated
- [ ] Convention documented in CONTRIBUTING.md
- [ ] README.md project structure updated
- [ ] No broken links or references
- [ ] Project builds successfully after changes

## Rollback Plan

If issues arise:
1. `git mv docs Documentation` and `git mv latex LaTeX` to revert renames
2. `git checkout HEAD~1 -- README.md CONTRIBUTING.md` to restore docs
3. Commit rollback
