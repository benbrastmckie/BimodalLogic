# Research Report: Task #383

**Task**: Rename Core/ to Explanatory/
**Date**: 2026-01-11
**Focus**: Systematic renaming and consolidation

## Summary

The task requires renaming `Logos/Core/` to `Logos/Explanatory/` and updating all references. Currently both directories exist: `Core/` contains the full implementation (Frame, Syntax, Truth) while `Explanatory/` is a stub. The terminology inconsistency arises from documentation using "Core Extension" while some code references mention "Explanatory" as the post-Foundation layer name.

## Findings

### Current Directory Structure

**Logos/Core/ (Active Implementation)**:
- `Frame.lean` - CoreFrame, WorldHistory, CoreModel (227 lines)
- `Syntax.lean` - Formula type with all operators (222 lines)
- `Truth.lean` - truthAt evaluation function (195 lines)
- `Core.lean` - Module export importing all three

**Logos/Explanatory/ (Stub Only)**:
- `Explanatory.lean` - Placeholder with namespace stub (~20 lines)
- `../Explanatory.lean` - Same content, duplicate file

**Namespace Usage**:
- All Core/ files use `namespace Logos.Core`
- Stub uses `namespace Logos.Explanatory`

### References to Update

**Lean Files (Logos/):**
1. `Logos/Core.lean` - Import statements reference `Logos.Core.*`
2. `Logos/Core/Frame.lean` - `namespace Logos.Core`
3. `Logos/Core/Syntax.lean` - `namespace Logos.Core`
4. `Logos/Core/Truth.lean` - `namespace Logos.Core`, imports `Logos.Core.*`

**Documentation Files:**
1. `RECURSIVE_SEMANTICS.md` - Uses "Core Extension" terminology (~15 occurrences)
2. `LAYER_EXTENSIONS.md` - Uses "Core Extension" extensively
3. `CONCEPTUAL_ENGINEERING.md` - References `Logos/Core/` paths, uses "Core Extension"
4. `GLOSSARY.md` - May have "Core Extension" entries
5. `METHODOLOGY.md` - May reference "Core Extension"
6. `README.md` files - Various references

**LaTeX Files:**
1. `LogosReference.tex` - Comments mention "Core Extension"
2. `02-CoreExtension-Syntax.tex` - File name contains "Core", references `Logos.Core.Syntax`
3. `03-CoreExtension-Semantics.tex` - File name contains "Core", references `Logos.Core.*`
4. `04-CoreExtension-Axioms.tex` - File name contains "Core", references `Logos.Core.*`

### Terminology Analysis

The documentation uses two naming conventions:
1. **"Core Extension"** - Used in RECURSIVE_SEMANTICS.md, LAYER_EXTENSIONS.md, LaTeX files
2. **"Explanatory Extension"** - Used in some roadmap/status documents

The phrase "Core Extension" appears to be the primary term in formal documentation, while "Explanatory" appears in implementation status/roadmap discussions. The user prefers "Explanatory" as the canonical name.

### Rename Scope

**Files to Rename:**
- `Logos/Core/` → `Logos/Explanatory/`
- `Logos/Core.lean` → Keep as `Logos/Core.lean` re-exporting `Logos.Explanatory` for backwards compatibility, OR rename to `Logos/Explanatory.lean`

**Files to Delete (duplicates):**
- `Logos/Explanatory/Explanatory.lean` (stub)
- `Logos/Explanatory.lean` (stub)

**Namespace Changes:**
- `namespace Logos.Core` → `namespace Logos.Explanatory`
- All imports `Logos.Core.*` → `Logos.Explanatory.*`

**LaTeX File Renames (Optional):**
- `02-CoreExtension-Syntax.tex` → `02-ExplanatoryExtension-Syntax.tex`
- `03-CoreExtension-Semantics.tex` → `03-ExplanatoryExtension-Semantics.tex`
- `04-CoreExtension-Axioms.tex` → `04-ExplanatoryExtension-Axioms.tex`
- Update `LogosReference.tex` includes

**String Replacements:**
- "Core Extension" → "Explanatory Extension" (in documentation)
- "Core extension" → "Explanatory extension"
- "CoreExtension" → "ExplanatoryExtension"
- "CoreFrame" → "ExplanatoryFrame"
- "CoreModel" → "ExplanatoryModel"
- `Logos.Core` → `Logos.Explanatory`
- `Logos/Core` → `Logos/Explanatory`

## Recommendations

1. **Use git mv for directory rename**: Preserves history
   ```bash
   git mv Logos/Core Logos/Explanatory
   ```

2. **Keep backwards compatibility module**: Create `Logos/Core.lean` that re-exports `Logos.Explanatory` with deprecation notice

3. **Update namespaces systematically**: Use sed/grep for bulk replacement, then manual verification

4. **Rename LaTeX subfiles**: Update file names and LogosReference.tex includes

5. **Order of operations**:
   - Remove duplicate stub files first
   - Rename directory
   - Update Lean namespaces/imports
   - Update documentation
   - Update LaTeX
   - Verify build

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Broken imports | Build failure | Run `lake build Logos` after each phase |
| Missed references | Documentation inconsistency | Use grep to verify no "Core" references remain |
| Git history loss | Harder to track changes | Use `git mv` instead of delete/create |
| LaTeX build failure | PDF generation breaks | Test `latexmk` after LaTeX changes |

## References

- `Logos/Core/` - Current implementation (Frame.lean, Syntax.lean, Truth.lean)
- `Logos/Explanatory/` - Current stub to be replaced
- `Logos/docs/research/RECURSIVE_SEMANTICS.md` - Primary terminology source
- `Logos/latex/LogosReference.tex` - LaTeX document structure

## Next Steps

1. Create implementation plan with phased approach
2. Phase 1: Remove stub duplicates, rename directory
3. Phase 2: Update Lean namespaces and imports
4. Phase 3: Update documentation (markdown)
5. Phase 4: Update LaTeX files and rebuild
6. Phase 5: Verify build and create deprecation alias
