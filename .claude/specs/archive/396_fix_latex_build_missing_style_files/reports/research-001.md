# Research Report: Task #396

**Task**: Fix LaTeX build missing style files
**Date**: 2026-01-11
**Focus**: Troubleshoot and fix style file path resolution errors

## Summary

The LaTeX build errors are caused by incorrect path calculations in the shared `latexmkrc` configuration and hardcoded relative paths in `.sty` files that don't account for the actual directory structure. Three interconnected issues need resolution: (1) the shared latexmkrc computes an incorrect path to the shared `latex/` directory, (2) `bimodal-notation.sty` uses a relative path that doesn't work when TEXINPUTS resolves the package, and (3) documentation is outdated.

## Findings

### Issue 1: Incorrect TEXINPUTS Path in Shared latexmkrc

**Location**: `latex/latexmkrc` lines 53-74

**Problem**: The latexmkrc uses this path calculation:
```perl
my $shared_latex_dir = abs_path('../../LaTeX');
```

When executed from `Theories/Logos/LaTeX/` (via the stub `do '../../latex/latexmkrc'`), this resolves to:
```
Theories/Logos/LaTeX/ → ../../LaTeX → Theories/LaTeX
```

This is wrong. The actual shared directory is at `/home/benjamin/Projects/ProofChecker/latex/`.

**Root Cause**: The path calculation assumes the shared config is in a `LaTeX` directory two levels up from the theory's `LaTeX/` directory, but the actual structure is:
```
ProofChecker/
├── latex/                              # Shared LaTeX assets (repo root)
│   └── latexmkrc                       # Shared config
└── Theories/
    ├── Bimodal/LaTeX/latexmkrc         # Stub: do '../../latex/latexmkrc'
    └── Logos/LaTeX/latexmkrc           # Stub: do '../../latex/latexmkrc'
```

The stub files correctly reference `../../latex/latexmkrc` (going up to `Theories/`, then up to `ProofChecker/`, then into `latex/`). But once inside the shared latexmkrc, the path `../../LaTeX` is computed relative to the current working directory (the theory's `LaTeX/` directory), not relative to the shared config file.

### Issue 2: Hardcoded Relative Path in bimodal-notation.sty

**Location**: `Theories/Bimodal/LaTeX/assets/bimodal-notation.sty` line 18

**Problem**: The file contains:
```latex
\RequirePackage{../../latex/notation-standards}
```

This path is incorrect because:
1. When LaTeX loads `bimodal-notation.sty` via TEXINPUTS, the working directory is the document's directory (`Theories/Bimodal/LaTeX/`), not the package's directory
2. From `Theories/Bimodal/LaTeX/`, `../../latex/notation-standards` resolves to `Theories/latex/notation-standards` which doesn't exist

**Contrast with logos-notation.sty**: The Logos version uses:
```latex
\RequirePackage{notation-standards}
```

This works if TEXINPUTS includes the shared `latex/` directory, allowing LaTeX to find `notation-standards.sty` by name.

### Issue 3: Documentation Outdated

**Location**: `latex/README.md`

The documentation shows paths like `Bimodal/latex/` and `Logos/latex/` (lowercase `latex`), but the actual directories are:
- `Theories/Bimodal/LaTeX/` (uppercase)
- `Theories/Logos/LaTeX/` (uppercase)

Also, the documentation is missing the `Theories/` prefix.

## Root Cause Analysis

The fundamental issue is that the latexmkrc's TEXINPUTS configuration uses a path computation that doesn't account for the actual directory hierarchy:

| What the code expects | What exists |
|----------------------|-------------|
| `Theory/LaTeX/` at one level up | `Theories/Theory/LaTeX/` nested deeper |
| Shared config at `../../LaTeX/latexmkrc` | Shared config at repo root `latex/latexmkrc` |

When Task 391 renamed `LaTeX` to `latex` at the repo root, it didn't update the path calculation logic inside latexmkrc.

## Recommendations

### Solution: Fix Path Calculation in Shared latexmkrc

**Approach**: Compute the shared directory path dynamically based on the location of the latexmkrc file itself, not relative to the current working directory.

```perl
use File::Basename;
use Cwd qw(abs_path cwd);

# Get directory containing THIS config file (latex/)
my $shared_latex_dir = dirname(abs_path($0));

# Current working directory (the theory's LaTeX/ directory)
my $source_dir = cwd();
```

This makes the path resolution robust regardless of:
- Where the command is run from
- The depth of the theory directory
- Future directory structure changes

### Fix bimodal-notation.sty

Change line 18 from:
```latex
\RequirePackage{../../latex/notation-standards}
```
to:
```latex
\RequirePackage{notation-standards}
```

This matches logos-notation.sty and relies on TEXINPUTS (once fixed) to find the package.

### Update Documentation

Update `latex/README.md` to reflect actual paths:
- `Theories/Bimodal/LaTeX/` instead of `Bimodal/latex/`
- `Theories/Logos/LaTeX/` instead of `Logos/latex/`

## Verification Strategy

After implementing fixes:

1. **Build Logos document**:
   ```bash
   cd Theories/Logos/LaTeX && latexmk LogosReference.tex
   ```

2. **Build Bimodal document**:
   ```bash
   cd Theories/Bimodal/LaTeX && latexmk BimodalReference.tex
   ```

3. **Verify both PDFs are generated without style file errors**

## Files to Modify

| File | Change |
|------|--------|
| `latex/latexmkrc` | Fix `$shared_latex_dir` computation |
| `Theories/Bimodal/LaTeX/assets/bimodal-notation.sty` | Change `\RequirePackage{../../latex/notation-standards}` to `\RequirePackage{notation-standards}` |
| `latex/README.md` | Update directory paths to reflect actual structure |

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking other latexmk configurations | Low | The fix makes path resolution more robust, not less |
| `$0` not being set correctly | Low | This is standard Perl behavior; test on both Linux and macOS |
| Future directory restructuring | Low | Using the config file's location as anchor is the most stable approach |

## Next Steps

1. Create implementation plan with phased approach
2. Implement fixes
3. Test both documents build successfully
4. Update any other documentation referencing the old paths
