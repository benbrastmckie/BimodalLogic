# Implementation Plan: Task #403

**Task**: Enforce directory naming convention
**Version**: 001
**Created**: 2026-01-11
**Language**: general

## Overview

Rename 19 capitalized directories that contain no Lean source code to lowercase, following the documented convention in CONTRIBUTING.md Section 3. This involves renaming directories using `git mv` to preserve history, then updating all internal and external references to these directories.

## Phases

### Phase 1: Rename docs/ subdirectories

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Rename 7 PascalCase subdirectories in `docs/` to lowercase
2. Update internal links within renamed directories

**Directories to rename**:
```
docs/architecture/   → docs/architecture/
docs/development/    → docs/development/
docs/installation/   → docs/installation/
docs/project-info/    → docs/project-info/
docs/reference/      → docs/reference/
docs/research/       → docs/research/
docs/user-guide/      → docs/user-guide/
```

**Steps**:
1. Execute `git mv` for each directory:
   ```bash
   git mv docs/Architecture docs/architecture
   git mv docs/Development docs/development
   git mv docs/Installation docs/installation
   git mv docs/ProjectInfo docs/project-info
   git mv docs/Reference docs/reference
   git mv docs/Research docs/research
   git mv docs/UserGuide docs/user-guide
   ```

2. Update internal links in `docs/README.md` and all files within renamed directories

3. Update references in other parts of codebase:
   - `.claude/CLAUDE.md` references to docs subdirectories
   - Any markdown files linking to docs/

**Verification**:
- All 7 directories renamed (verify with `ls docs/`)
- No broken links in `docs/README.md`
- Grep for old paths returns no results outside archive

---

### Phase 2: Rename Theories/Bimodal/Documentation/ to docs/

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Rename `Theories/Bimodal/docs/` to `Theories/Bimodal/docs/`
2. Rename internal subdirectories to lowercase with hyphens
3. Update all internal cross-references (26 files)

**Directories to rename**:
```
Theories/Bimodal/docs/              → Theories/Bimodal/docs/
Theories/Bimodal/docs/project-info/  → Theories/Bimodal/docs/project-info/
Theories/Bimodal/docs/reference/    → Theories/Bimodal/docs/reference/
Theories/Bimodal/docs/research/     → Theories/Bimodal/docs/research/
Theories/Bimodal/docs/user-guide/    → Theories/Bimodal/docs/user-guide/
```

**Steps**:
1. Rename the parent directory first:
   ```bash
   git mv Theories/Bimodal/Documentation Theories/Bimodal/docs
   ```

2. Rename subdirectories:
   ```bash
   git mv Theories/Bimodal/docs/ProjectInfo Theories/Bimodal/docs/project-info
   git mv Theories/Bimodal/docs/Reference Theories/Bimodal/docs/reference
   git mv Theories/Bimodal/docs/Research Theories/Bimodal/docs/research
   git mv Theories/Bimodal/docs/UserGuide Theories/Bimodal/docs/user-guide
   ```

3. Update all internal links within the 26 files:
   - Links to `../ProjectInfo/` → `../project-info/`
   - Links to `../Reference/` → `../reference/`
   - Links to `../Research/` → `../research/`
   - Links to `../UserGuide/` → `../user-guide/`

4. Update `Theories/Bimodal/README.md` link to documentation

**Verification**:
- Directory structure matches expected lowercase format
- All internal README.md files have working navigation links
- `Theories/Bimodal/README.md` links to `docs/README.md`

---

### Phase 3: Rename Theories/Logos/Documentation/ to docs/

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Rename `Theories/Logos/Documentation/` to `Theories/Logos/docs/`
2. Rename internal subdirectories to lowercase with hyphens
3. Update all internal cross-references (17 files)

**Directories to rename**:
```
Theories/Logos/Documentation/              → Theories/Logos/docs/
Theories/Logos/Documentation/ProjectInfo/  → Theories/Logos/docs/project-info/
Theories/Logos/Documentation/Reference/    → Theories/Logos/docs/reference/
Theories/Logos/Documentation/Research/     → Theories/Logos/docs/research/
Theories/Logos/Documentation/UserGuide/    → Theories/Logos/docs/user-guide/
```

**Steps**:
1. Rename the parent directory:
   ```bash
   git mv Theories/Logos/Documentation Theories/Logos/docs
   ```

2. Rename subdirectories:
   ```bash
   git mv Theories/Logos/docs/ProjectInfo Theories/Logos/docs/project-info
   git mv Theories/Logos/docs/Reference Theories/Logos/docs/reference
   git mv Theories/Logos/docs/Research Theories/Logos/docs/research
   git mv Theories/Logos/docs/UserGuide Theories/Logos/docs/user-guide
   ```

3. Update internal links in all 17 files

4. Update `Theories/Logos/README.md` link to documentation

5. Update cross-references from Bimodal docs to Logos docs

**Verification**:
- Directory structure matches expected lowercase format
- All internal links working
- Cross-theory links updated (Bimodal → Logos)

---

### Phase 4: Rename Theory LaTeX directories

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Remove orphaned `.claude/` directories inside LaTeX directories
2. Rename `Theories/Bimodal/LaTeX/` to `Theories/Bimodal/latex/`
3. Rename `Theories/Logos/LaTeX/` to `Theories/Logos/latex/`
4. Update `latex/latexmkrc` and `latex/README.md` references

**Steps**:
1. Remove orphaned artifacts:
   ```bash
   rm -rf Theories/Logos/LaTeX/.claude
   rm -rf Theories/Bimodal/LaTeX/assets/.claude
   ```

2. Rename LaTeX directories:
   ```bash
   git mv Theories/Bimodal/LaTeX Theories/Bimodal/latex
   git mv Theories/Logos/LaTeX Theories/Logos/latex
   ```

3. Update `latex/README.md`:
   - Change all `Theories/Bimodal/LaTeX/` → `Theories/Bimodal/latex/`
   - Change all `Theories/Logos/LaTeX/` → `Theories/Logos/latex/`

4. Update `latex/latexmkrc`:
   - Update any path references to theory LaTeX directories

5. Verify `latexmkrc` stub files in theory directories still work

**Verification**:
- LaTeX directories renamed
- `latex/README.md` references updated
- `latex/latexmkrc` works correctly
- Build LaTeX documents to verify paths work

---

### Phase 5: Update remaining references and verify

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Find and update any remaining references to old directory names
2. Update CONTRIBUTING.md if needed
3. Verify no broken links remain
4. Run `lake build` to ensure Lean still builds

**Steps**:
1. Search for remaining references:
   ```bash
   grep -r "Documentation/" --include="*.md" | grep -v archive
   grep -r "/LaTeX/" --include="*.md" | grep -v archive
   grep -r "ProjectInfo/" --include="*.md" | grep -v archive
   grep -r "UserGuide/" --include="*.md" | grep -v archive
   grep -r "Reference/" --include="*.md" | grep -v archive
   grep -r "Research/" --include="*.md" | grep -v archive
   ```

2. Update any remaining references found

3. Run verification:
   ```bash
   lake build
   ```

4. Update `.claude/specs/TODO.md` and `.claude/specs/state.json` task descriptions (they reference the old paths)

**Verification**:
- `grep` for old paths returns only archive results
- `lake build` succeeds
- All markdown links work (spot check key files)

---

## Dependencies

- None - this is a standalone refactoring task

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Broken internal documentation links | Medium | Medium | Systematic search-replace, verify with grep |
| LaTeX builds fail after path change | Medium | Low | Test builds after Phase 4, revert if needed |
| Git history complications | Low | Low | Use `git mv` which preserves history |
| Missed references in archive | Low | High | Archive is historical, don't update - just note in summary |

## Success Criteria

- [ ] All 19 violating directories renamed to lowercase
- [ ] All PascalCase → lowercase (Architecture → architecture)
- [ ] All PascalCase → kebab-case where appropriate (ProjectInfo → project-info)
- [ ] All internal documentation links updated and working
- [ ] LaTeX builds successfully from new paths
- [ ] `lake build` completes without errors
- [ ] No broken links in markdown files (verified by grep)
- [ ] CONTRIBUTING.md structure example matches actual directory structure

## Rollback Plan

If issues arise:
1. Use `git reset --hard HEAD~1` to undo last commit
2. Or `git revert` for specific commits
3. Directory renames via `git mv` are easily reversible

## Notes

- Archive files (`.claude/specs/archive/`) will NOT be updated - they are historical records
- Task 403 description in TODO.md and state.json mentions old paths - will update in Phase 5
