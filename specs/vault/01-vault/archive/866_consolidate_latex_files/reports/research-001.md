# Research Report: Task #866

**Task**: 866 - consolidate_latex_files
**Started**: 2026-02-10T12:00:00Z
**Completed**: 2026-02-10T12:15:00Z
**Effort**: Low
**Dependencies**: None
**Sources/Inputs**: Codebase exploration (Glob, Grep, Read)
**Artifacts**: This report at specs/866_consolidate_latex_files/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- The `latex/` directory at project root is a **shared resource hub** that `BimodalReference.tex` actively depends on
- BimodalReference.tex uses two files from `latex/`: `formatting.sty` and `notation-standards.sty` (via bimodal-notation.sty)
- The root `latex/` directory **CANNOT be safely removed** without breaking the build
- **Recommended approach**: Keep `latex/` but clean up outdated Logos references in documentation
- Alternative: Move shared files to `Theories/Bimodal/latex/` if no other theories will ever exist

## Context & Scope

The task asks whether the root `latex/` directory is needed for `Theories/Bimodal/latex/BimodalReference.tex`, or if files should be consolidated into the Bimodal directory.

### Directories Analyzed

1. `/home/benjamin/Projects/ProofChecker/latex/` (root LaTeX directory)
2. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/` (Bimodal theory directory)

## Findings

### 1. Root latex/ Directory Contents

| File | Purpose | Used by Bimodal? |
|------|---------|------------------|
| `formatting.sty` | Shared formatting: fonts, colors, hyperlinks, headers, boxes | **YES** - directly via `\usepackage{formatting}` |
| `notation-standards.sty` | Shared notation: modal operators, connectives, model notation | **YES** - via `bimodal-notation.sty` (`\RequirePackage{notation-standards}`) |
| `latexmkrc` | Central build configuration | **YES** - loaded by Bimodal's stub latexmkrc |
| `bib_style.bst` | Bibliography style for natbib | **NO** - Bimodal has no bibliography |
| `latex-fix.sh` | Troubleshooting/build script | **Optional** - helpful utility |
| `README.md` | Documentation | Reference only |
| `MIGRATION_SUMMARY.md` | Migration documentation | Reference only |
| `LATEX_TROUBLESHOOTING.md` | Troubleshooting guide | Reference only |
| `build/` | Build artifacts for notation-standards | Not needed - test artifacts |

### 2. BimodalReference.tex Dependencies

From examining the main document:

```latex
% Custom packages (found via TEXINPUTS configured in latexmkrc)
\usepackage{bimodal-notation}
\usepackage{formatting}
```

**Dependency chain**:
1. `BimodalReference.tex` requires `formatting.sty` (from root `latex/`)
2. `BimodalReference.tex` requires `bimodal-notation.sty` (from `assets/`)
3. `bimodal-notation.sty` requires `notation-standards.sty` (from root `latex/`)

### 3. Build System Configuration

The build system uses a **stub pattern**:

- **Central config**: `latex/latexmkrc` - defines TEXINPUTS, build options, paths
- **Theory stub**: `Theories/Bimodal/latex/latexmkrc` - just contains `do '../../../latex/latexmkrc';`

The central latexmkrc sets up TEXINPUTS to find:
- `$source_dir/assets//` - theory-specific packages (e.g., bimodal-notation.sty)
- `$shared_latex_dir//` - shared packages (formatting.sty, notation-standards.sty)

### 4. Current Theory Status

Only **one theory exists**: Bimodal. The documentation references a "Logos" theory extensively, but:
- No `Theories/Logos/` directory exists
- All Logos references in `latex/*.md` files are for a planned but unimplemented theory
- The shared architecture was designed for multiple theories that may never materialize

### 5. Files That Can Be Safely Removed

| File | Reason |
|------|--------|
| `latex/build/` | Test artifacts (notation-standards.aux, .fls, .log, .fdb_latexmk) |
| `latex/bib_style.bst` | Only needed if a theory uses bibliography; Bimodal does not |

### 6. Files That Should Be Updated

The following documentation files contain extensive references to a non-existent "Logos" theory:
- `latex/README.md` - Many Logos examples
- `latex/MIGRATION_SUMMARY.md` - References Logos as existing
- `latex/LATEX_TROUBLESHOOTING.md` - Logos examples
- `latex/latex-fix.sh` - Logos in help text

## Decisions

### Decision 1: Keep vs. Move Shared Files

**Decision**: Keep `latex/` directory as-is (with cleanup)

**Rationale**:
1. The architecture is designed for multi-theory support
2. Moving files would require updating:
   - `Bimodal/latex/latexmkrc` stub (change path)
   - `bimodal-notation.sty` (if it uses relative paths - it doesn't, but TEXINPUTS would need adjustment)
   - All documentation
3. If a second theory is ever added, the shared structure already works
4. The separation between shared formatting and theory-specific notation is clean

### Decision 2: Files to Remove

Safe to remove:
- `latex/build/` directory entirely
- `latex/bib_style.bst` (unless future theories need it)

### Decision 3: Documentation Updates

Update documentation to:
- Remove or mark Logos references as "planned" or "example"
- Accurately reflect that only Bimodal exists
- Keep the multi-theory architecture documentation for future use

## Recommendations

### Option A: Minimal Cleanup (Recommended)

1. **Delete** `latex/build/` directory (orphaned test artifacts)
2. **Keep** all other files in `latex/`
3. **Update** documentation to remove references to non-existent Logos theory
4. **Keep** shared architecture for future extensibility

**Pros**: Minimal changes, preserves future flexibility
**Cons**: Maintains slightly complex multi-theory setup for single theory

### Option B: Full Consolidation to Bimodal

1. **Move** `formatting.sty` to `Theories/Bimodal/latex/assets/`
2. **Move** `notation-standards.sty` to `Theories/Bimodal/latex/assets/`
3. **Update** `Theories/Bimodal/latex/latexmkrc` to be self-contained
4. **Update** `bimodal-notation.sty` import path
5. **Move** `latexmkrc` content into Bimodal's version
6. **Delete** entire `latex/` directory
7. **Keep** `latex-fix.sh` somewhere (move to `.claude/scripts/` or delete)

**Pros**: Simpler single-theory structure, everything in one place
**Cons**: More refactoring work, loses multi-theory support

### Option C: Hybrid Approach

1. Keep `latex/` but only with files actively used:
   - `formatting.sty` (used)
   - `notation-standards.sty` (used)
   - `latexmkrc` (used)
2. Delete unused files:
   - `build/` directory
   - `bib_style.bst`
   - Documentation files (or move to `docs/`)
   - `latex-fix.sh` (move to `.claude/scripts/` or Bimodal/latex/)

**Pros**: Clean middle ground
**Cons**: Documentation scattered

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Breaking build after changes | Test with `latexmk BimodalReference.tex` after any modification |
| Future theory can't use shared files | Option A preserves this; Options B/C would need re-architecture |
| Confusion about Logos references | Update documentation regardless of structural choice |

## Appendix

### Search Queries Used

1. `Glob **/* in latex/` - Found all files in root latex directory
2. `Glob **/* in Theories/Bimodal/latex/` - Found all Bimodal LaTeX files
3. `Read BimodalReference.tex` - Identified package dependencies
4. `Read bimodal-notation.sty` - Found notation-standards.sty dependency
5. `Grep Logos|logos in latex/` - Found all Logos references in documentation

### File Counts

- Root `latex/`: 12 files (including build artifacts)
- `Theories/Bimodal/latex/`: 20 files (including PDFs and logs)
- Shared style files actually used: 2 (`formatting.sty`, `notation-standards.sty`)

### Critical Files for Build

The minimum set of files required for `BimodalReference.tex` to compile:

From `latex/`:
- `latexmkrc`
- `formatting.sty`
- `notation-standards.sty`

From `Theories/Bimodal/latex/`:
- `latexmkrc` (stub)
- `BimodalReference.tex`
- `assets/bimodal-notation.sty`
- `subfiles/*.tex` (all 7 subfiles)
