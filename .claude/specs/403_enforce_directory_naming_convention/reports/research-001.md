# Research Report: Task #403

**Task**: Enforce directory naming convention
**Date**: 2026-01-11
**Focus**: Identify all capitalized directories without Lean source code and references requiring updates

## Summary

The project has a documented naming convention (CONTRIBUTING.md Section 3): PascalCase for Lean source directories, lowercase for all others. However, there are 19 directories that violate this convention - capitalized directories that contain no Lean source code. These are primarily `Documentation/` and `LaTeX/` directories nested within the `Theories/` hierarchy.

## Findings

### Current Convention (documented in CONTRIBUTING.md)

```
PascalCase (capitalized):
- Directories containing Lean source code
- Required to match Lean import paths (e.g., `import Theories.Bimodal.Syntax`)

lowercase:
- All other directories (docs/, scripts/, latex/, benchmarks/)
- Provides visual distinction between code and non-code
```

### Directories Violating Convention

**19 directories need renaming** (capitalized but contain no .lean files):

#### Top-level `docs/` subdirectories (7 directories)
```
docs/architecture/          → docs/architecture/
docs/development/           → docs/development/
docs/installation/          → docs/installation/
docs/project-info/           → docs/project-info/
docs/reference/             → docs/reference/
docs/research/              → docs/research/
docs/user-guide/             → docs/user-guide/
```

#### Theories/Bimodal non-Lean directories (6 directories)
```
Theories/Bimodal/docs/                  → Theories/Bimodal/docs/
Theories/Bimodal/docs/project-info/      → Theories/Bimodal/docs/project-info/
Theories/Bimodal/docs/reference/        → Theories/Bimodal/docs/reference/
Theories/Bimodal/docs/research/         → Theories/Bimodal/docs/research/
Theories/Bimodal/docs/user-guide/        → Theories/Bimodal/docs/user-guide/
Theories/Bimodal/LaTeX/                          → Theories/Bimodal/latex/
```

#### Theories/Logos non-Lean directories (6 directories)
```
Theories/Logos/docs/                    → Theories/Logos/docs/
Theories/Logos/docs/project-info/        → Theories/Logos/docs/project-info/
Theories/Logos/docs/reference/          → Theories/Logos/docs/reference/
Theories/Logos/docs/research/           → Theories/Logos/docs/research/
Theories/Logos/docs/user-guide/          → Theories/Logos/docs/user-guide/
Theories/Logos/LaTeX/                            → Theories/Logos/latex/
```

### References Requiring Updates

#### Active References (outside .claude/specs/archive/)

| File | Reference Type |
|------|---------------|
| `latex/README.md` | 9 references to `Theories/*/LaTeX/` |
| `latex/latexmkrc` | 3 references to theory `LaTeX/` directories |
| `.claude/specs/TODO.md` | Task description mentions `LaTeX/` |
| `.claude/specs/state.json` | Task description mentions `LaTeX/` |
| `.claude/specs/394_*/reports/research-002.md` | Reference to `Documentation/` |
| `.claude/specs/372_*/plans/implementation-001.md` | References to `Documentation/` |

#### Internal References Within Violating Directories

The `Documentation/` directories contain extensive internal cross-references:
- `Theories/Bimodal/docs/` - 26 files with internal links
- `Theories/Logos/docs/` - 17 files with internal links
- `docs/` subdirectories - need relative path updates

#### README Files Referencing Documentation Directories

| File | Issue |
|------|-------|
| `Theories/Bimodal/README.md` | Links to `docs/README.md` (broken - should be `Documentation/` or will become `docs/`) |
| `Theories/Logos/README.md` | Same issue |

### Previous Implementation Attempt

Task 391 (archived) claimed to rename `Documentation/` → `docs/` and `LaTeX/` → `latex/` but:
- Root-level `Documentation/` was renamed to `docs/` ✓
- Root-level `LaTeX/` → `latex/` (shared config) ✓
- **Theory-specific `Documentation/` and `LaTeX/` were NOT renamed** ✗

The implementation summary claimed success but the directories still exist with uppercase names.

### Special Considerations

1. **Git history preservation**: Use `git mv` for all renames
2. **Build output directories**: `Theories/*/LaTeX/build/` should be in .gitignore (or moved)
3. **latexmkrc paths**: The `latex/latexmkrc` config references theory LaTeX directories
4. **Nested .claude directories**: Found in:
   - `Theories/Logos/LaTeX/.claude/specs/` (orphaned task artifacts)
   - `Theories/Bimodal/LaTeX/assets/.claude/specs/` (orphaned task artifacts)

## Recommendations

### Phase 1: Rename docs/ subdirectories (7 directories)
Simple renames, limited impact:
```bash
git mv docs/Architecture docs/architecture
git mv docs/Development docs/development
# ... etc
```

### Phase 2: Rename Theory Documentation directories (10 directories)
More complex due to internal references:
```bash
git mv Theories/Bimodal/Documentation Theories/Bimodal/docs
git mv Theories/Logos/Documentation Theories/Logos/docs
```
Then update all internal markdown links.

### Phase 3: Rename Theory LaTeX directories (2 directories)
Requires updating `latex/latexmkrc` and `latex/README.md`:
```bash
git mv Theories/Bimodal/LaTeX Theories/Bimodal/latex
git mv Theories/Logos/LaTeX Theories/Logos/latex
```

### Phase 4: Clean up orphaned artifacts
Remove `.claude/` directories nested inside the LaTeX directories.

### Phase 5: Update all references
Systematic search and replace across the codebase.

## File Count Estimates

| Directory | Files Affected |
|-----------|---------------|
| `docs/` subdirectories | ~50 files |
| `Theories/Bimodal/docs/` | 26 files |
| `Theories/Logos/docs/` | 17 files |
| `Theories/*/LaTeX/` | ~15 files |
| References to update | ~100+ file edits |

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Broken documentation links | Medium | Systematic grep + sed replacement |
| LaTeX build failure | Medium | Test builds after renaming |
| Git history fragmentation | Low | Use `git mv` to preserve history |
| Orphaned references in archive | Low | Archive is historical, no updates needed |

## Success Criteria

- [ ] All 19 violating directories renamed to lowercase
- [ ] All internal documentation links updated and working
- [ ] LaTeX builds successfully from new paths
- [ ] `lake build` completes without errors
- [ ] No broken links in markdown files (verified by grep)
- [ ] Convention documented directories match actual structure

## Next Steps

1. Create implementation plan with detailed phases
2. Start with lowest-risk changes (docs/ subdirectories)
3. Test LaTeX builds after renaming
4. Verify all markdown links
