# Implementation Plan: Task #383

**Task**: Rename Core/ to Explanatory/
**Version**: 001
**Created**: 2026-01-11
**Language**: lean

## Overview

Systematically rename `Logos/Core/` to `Logos/Explanatory/` and update all references throughout the codebase. The current `Logos/Explanatory/` stub will be replaced with the full implementation from `Logos/Core/`. All namespaces, imports, documentation, and LaTeX files will be updated to use "Explanatory Extension" terminology consistently.

## Phases

### Phase 1: Clean Up and Directory Rename

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Remove duplicate stub files
2. Rename Core/ directory to Explanatory/ using git mv

**Files to modify**:
- `Logos/Explanatory.lean` - Delete (stub)
- `Logos/Explanatory/Explanatory.lean` - Delete (stub)
- `Logos/Core/` → `Logos/Explanatory/` - Rename directory

**Steps**:
1. Delete `Logos/Explanatory.lean` (stub file)
2. Delete `Logos/Explanatory/Explanatory.lean` (stub file)
3. Remove empty `Logos/Explanatory/` directory
4. Use `git mv Logos/Core Logos/Explanatory` to rename directory
5. Rename `Logos/Core.lean` to `Logos/Explanatory.lean`

**Verification**:
- `ls Logos/Explanatory/` shows Frame.lean, Syntax.lean, Truth.lean
- No `Logos/Core/` directory exists
- Git history preserved for renamed files

---

### Phase 2: Update Lean Namespaces and Imports

**Estimated effort**: 45 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Update all namespace declarations from `Logos.Core` to `Logos.Explanatory`
2. Update all import statements
3. Verify build passes

**Files to modify**:
- `Logos/Explanatory.lean` - Update imports
- `Logos/Explanatory/Frame.lean` - Update namespace
- `Logos/Explanatory/Syntax.lean` - Update namespace
- `Logos/Explanatory/Truth.lean` - Update namespace and imports

**Steps**:
1. In `Logos/Explanatory/Frame.lean`:
   - Change `namespace Logos.Core` → `namespace Logos.Explanatory`
   - Change `end Logos.Core` → `end Logos.Explanatory`
2. In `Logos/Explanatory/Syntax.lean`:
   - Change `namespace Logos.Core` → `namespace Logos.Explanatory`
   - Change `end Logos.Core` → `end Logos.Explanatory`
3. In `Logos/Explanatory/Truth.lean`:
   - Change imports from `Logos.Core.*` → `Logos.Explanatory.*`
   - Change `namespace Logos.Core` → `namespace Logos.Explanatory`
   - Change `open Logos.Core.Formula` → `open Logos.Explanatory.Formula`
   - Change `end Logos.Core` → `end Logos.Explanatory`
4. In `Logos/Explanatory.lean`:
   - Change imports from `Logos.Core.*` → `Logos.Explanatory.*`
   - Update docstring references
5. Run `lake build Logos` to verify

**Verification**:
- `lake build Logos` succeeds
- `grep -r "Logos.Core" Logos/` returns no matches in .lean files

---

### Phase 3: Update Documentation (Markdown)

**Estimated effort**: 1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Replace "Core Extension" with "Explanatory Extension" in documentation
2. Update file path references
3. Maintain consistency with theoretical naming

**Files to modify**:
- `Logos/docs/Research/RECURSIVE_SEMANTICS.md`
- `Logos/docs/Research/LAYER_EXTENSIONS.md`
- `Logos/docs/Research/CONCEPTUAL_ENGINEERING.md`
- `Logos/docs/Reference/GLOSSARY.md`
- `Logos/docs/UserGuide/METHODOLOGY.md`
- Other .md files with "Core" references

**Steps**:
1. In each documentation file, replace:
   - "Core Extension" → "Explanatory Extension"
   - "Core extension" → "Explanatory extension"
   - "core extension" → "explanatory extension"
   - `Logos/Core/` → `Logos/Explanatory/`
   - `Logos.Core` → `Logos.Explanatory`
2. Update ASCII diagrams in RECURSIVE_SEMANTICS.md and LAYER_EXTENSIONS.md
3. Update file path references in CONCEPTUAL_ENGINEERING.md
4. Review each change for context appropriateness

**Verification**:
- `grep -ri "Core Extension" Logos/docs/` returns no matches
- `grep -ri "Logos/Core" Logos/docs/` returns no matches
- Documentation remains coherent and accurate

---

### Phase 4: Update LaTeX Files

**Estimated effort**: 45 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Rename LaTeX subfiles with "CoreExtension" in name
2. Update LogosReference.tex includes
3. Update \leansrc references in LaTeX
4. Verify LaTeX builds

**Files to modify**:
- `Logos/latex/subfiles/02-CoreExtension-Syntax.tex` → `02-ExplanatoryExtension-Syntax.tex`
- `Logos/latex/subfiles/03-CoreExtension-Semantics.tex` → `03-ExplanatoryExtension-Semantics.tex`
- `Logos/latex/subfiles/04-CoreExtension-Axioms.tex` → `04-ExplanatoryExtension-Axioms.tex`
- `Logos/latex/LogosReference.tex` - Update includes and comments

**Steps**:
1. Rename LaTeX subfiles using git mv:
   ```bash
   git mv Logos/latex/subfiles/02-CoreExtension-Syntax.tex \
          Logos/latex/subfiles/02-ExplanatoryExtension-Syntax.tex
   git mv Logos/latex/subfiles/03-CoreExtension-Semantics.tex \
          Logos/latex/subfiles/03-ExplanatoryExtension-Semantics.tex
   git mv Logos/latex/subfiles/04-CoreExtension-Axioms.tex \
          Logos/latex/subfiles/04-ExplanatoryExtension-Axioms.tex
   ```
2. Update `LogosReference.tex`:
   - Change includes to new filenames
   - Update comments from "Core Extension" to "Explanatory Extension"
3. In each renamed subfile:
   - Replace `\leansrc{Logos.Core.*}` → `\leansrc{Logos.Explanatory.*}`
   - Replace "Core Extension" → "Explanatory Extension" in text
4. Build LaTeX to verify: `cd Logos/LaTeX && latexmk -pdf LogosReference.tex`

**Verification**:
- `latexmk -pdf LogosReference.tex` succeeds
- PDF shows "Explanatory Extension" terminology
- No "Core Extension" text in generated PDF (except possibly historical references)

---

### Phase 5: Final Verification and Cleanup

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Comprehensive search for remaining "Core" references
2. Verify all builds pass
3. Clean up any cruft

**Files to modify**:
- Any files with remaining "Core" references

**Steps**:
1. Run comprehensive search:
   ```bash
   grep -ri "Core Extension" Logos/
   grep -ri "Logos.Core" Logos/
   grep -ri "Logos/Core" Logos/
   grep -ri "CoreExtension" Logos/
   grep -ri "CoreFrame" Logos/
   grep -ri "CoreModel" Logos/
   ```
2. Fix any remaining references found
3. Run full build verification:
   ```bash
   lake build Logos
   cd Logos/LaTeX && latexmk -pdf LogosReference.tex
   ```
4. Review git diff for unintended changes
5. Create final commit

**Verification**:
- All grep searches return empty or only appropriate references
- `lake build Logos` succeeds
- LaTeX builds successfully
- Git status clean after commit

---

## Dependencies

- None - This is a standalone refactoring task

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Broken imports | Build failure | Medium | Run `lake build` after each phase |
| Missed references | Inconsistent terminology | Medium | Comprehensive grep search in Phase 5 |
| Git history loss | Harder to track changes | Low | Use `git mv` for all renames |
| LaTeX build failure | PDF generation breaks | Low | Test `latexmk` in Phase 4 |
| External references | Broken links from outside repo | Low | Document change in commit message |

## Success Criteria

- [ ] No `Logos/Core/` directory exists
- [ ] `Logos/Explanatory/` contains Frame.lean, Syntax.lean, Truth.lean
- [ ] All namespaces use `Logos.Explanatory`
- [ ] All imports reference `Logos.Explanatory.*`
- [ ] `lake build Logos` succeeds
- [ ] Documentation uses "Explanatory Extension" consistently
- [ ] LaTeX files renamed and build successfully
- [ ] `grep -ri "Logos.Core" Logos/` returns no .lean file matches
- [ ] `grep -ri "Core Extension" Logos/` returns no matches

## Rollback Plan

If implementation fails at any phase:
1. Use `git checkout -- .` to revert all changes
2. Use `git clean -fd` to remove any new files
3. Document the failure point for debugging
4. Re-attempt after fixing the issue

## Notes

- The rename preserves the full implementation from Task 377
- "Explanatory Extension" aligns with the theoretical framework terminology
- The stub files being removed contain no valuable code
- Total estimated effort: 3.5 hours
