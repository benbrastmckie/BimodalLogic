# Research Report: Task #379 - LaTeX Best Practices for .bst Files with Build Directory

**Task**: Fix LogosReference LaTeX warnings and errors
**Date**: 2026-01-11
**Focus**: Best practices for finding .bst files when using latexmk with build/ output directory

## Summary

Comprehensive web research reveals that the recommended approach for handling .bst file discovery when using latexmk's `$out_dir` is to use the `ensure_path()` function with absolute paths, rather than setting environment variables directly or using custom `$bibtex` commands. The current configuration has issues because it relies on a custom bibtex command that may conflict with latexmk's internal handling.

## Key Findings

### 1. The Root Cause (Confirmed)

When latexmk uses `$out_dir = 'build'`, BibTeX runs from inside the build directory. This breaks relative paths in `.bst` and `.bib` lookups. The [Overleaf Kpathsea documentation](https://www.overleaf.com/learn/latex/Articles/An_introduction_to_Kpathsea_and_how_TeX_engines_search_for_files) confirms:

> "The BibTeX program uses Kpathsea to search for its input files; in particular: the BSTINPUTS config variable (search path) is used to search for .bst files."

### 2. Recommended Solution: `ensure_path()`

The [latexmk manual](https://www.cantab.net/users/johncollins/latexmk/latexmk-480.txt) and [Debian manpage](https://manpages.debian.org/unstable/latexmk/latexmk.1.en.html) document the proper approach:

> "The `ensure_path()` subroutine allows you to add directories to environment variables for file searching. The first parameter is the name of one of the system's environment variables for search paths. The remaining parameters are values that should be in the variable."

**Example:**
```perl
ensure_path( 'BSTINPUTS', '/absolute/path/to/bst/directory//' );
ensure_path( 'BIBINPUTS', '/absolute/path/to/bib/directory//' );
```

The trailing `//` tells Kpathsea to search subdirectories recursively.

### 3. The `$bibtex_fudge` Variable

The [latexmk documentation](https://mg.readthedocs.io/latexmk.html) explains:

> "`$bibtex_fudge` controls whether latexmk changes to the aux directory before running BibTeX. This variable addresses two issues: older BibTeX bugs with path components and modern security restrictions that prevent writing to non-working directories."

This is enabled by default (`$bibtex_fudge = 1`), meaning latexmk already handles directory changes for BibTeX. The custom `$bibtex` command in the current config may interfere with this mechanism.

### 4. Why the Current Configuration Fails

The current `latex/latexmkrc` uses:
```perl
$bibtex = "BSTINPUTS='$shared_latex_dir:' BIBINPUTS='$source_dir:' bibtex %O %S";
```

**Problems:**
1. This overrides latexmk's internal bibtex handling
2. Environment variables set inline may not persist correctly across latexmk's multiple compilation passes
3. The empty .bbl file issue (from research-002.md) suggests latexmk's file management conflicts with this approach

### 5. Alternative: Disable Build Directory for BibTeX Only

Per [GitHub LaTeX-Workshop issue #3023](https://github.com/James-Yu/LaTeX-Workshop/issues/3023):

> "Unlike biber, bibtex (and bibtex8) does not support an output directory parameter. This creates issues when using latexmk with an output directory because to support the output_directory flag with bibtex, latexmk changes the current directory to the output directory."

The issue notes that biber handles this gracefully but bibtex requires workarounds.

### 6. Project Using Similar Approach: SJTUThesis

The [SJTUThesis project](https://github.com/sjtug/SJTUThesis/blob/master/.latexmkrc) provides a production-tested latexmkrc that handles complex builds. It uses biber instead of bibtex for bibliography management, which avoids these issues entirely.

## Recommendations

### Option 1: Use `ensure_path()` with Absolute Paths (Recommended)

Replace the custom `$bibtex` command with proper `ensure_path()` calls:

```perl
use Cwd qw(abs_path cwd);
my $shared_latex_dir = abs_path('../../LaTeX');
my $source_dir = cwd();

# Use ensure_path for proper latexmk integration
ensure_path('BSTINPUTS', "$shared_latex_dir//");
ensure_path('BIBINPUTS', "$source_dir//");

# Remove custom $bibtex - let latexmk handle it with bibtex_fudge
# $bibtex = ...;  # DELETE THIS LINE
```

### Option 2: Copy .bst to Theory Directory

Place `bib_style.bst` in `Logos/latex/bib_style.bst`:
- Pro: Eliminates path resolution entirely
- Con: Duplicates the file (violates DRY)

### Option 3: Switch to Biber

Change from bibtex to biber:
```perl
$bibtex_use = 2;  # Already set for biber
$biber = 'biber %O %S';
```
- Pro: Biber natively supports output directories
- Con: Requires .bib file format changes and different .tex commands

### Option 4: Remove Build Directory

Set `$out_dir` and `$aux_dir` to empty or `.`:
```perl
$out_dir = '.';
$aux_dir = '.';
```
- Pro: Simplest fix, works immediately
- Con: Auxiliary files clutter source directory

## Testing Plan

1. Implement Option 1 (`ensure_path()` approach)
2. Run `latexmk -verbose` to see search paths
3. Verify .bbl file is generated and non-empty
4. Check final PDF has bibliography

## References

- [Overleaf: Kpathsea and File Searching](https://www.overleaf.com/learn/latex/Articles/An_introduction_to_Kpathsea_and_how_TeX_engines_search_for_files)
- [latexmk Manual](https://www.cantab.net/users/johncollins/latexmk/latexmk-480.txt)
- [Debian latexmk Manpage](https://manpages.debian.org/unstable/latexmk/latexmk.1.en.html)
- [LaTeX-Workshop BibTeX Output Directory Issue](https://github.com/James-Yu/LaTeX-Workshop/issues/3023)
- [Configuring latexmk - Luke Naylor](https://lukideangeometry.xyz/blog/latexmk)
- [Using Latexmk Guide](https://mg.readthedocs.io/latexmk.html)

## Next Steps

1. Implement Option 1: Replace custom `$bibtex` with `ensure_path()` calls
2. Test bibliography generation
3. If still failing, try Option 2 (copy .bst file)
4. Document final solution in latex/README.md
