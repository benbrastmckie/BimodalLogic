# Investigation Report: LaTeX Subfiles TEXINPUTS Path Resolution

**Date**: 2026-01-20
**Status**: UNRESOLVED
**Scope**: VimTeX + latexmk subfiles compilation from subdirectories

## Problem Summary

When editing subfiles in `Theories/Bimodal/latex/subfiles/`:
- `<leader>lc` (compile) works when VimTeX main is toggled OFF
- `<leader>ls` (VimtexToggleMain) works to switch compilation target
- `<leader>lv` (view) and compilation with main toggled ON fails with:
  ```
  File 'notation-standards.sty' not found
  ```

The error occurs because `notation-standards.sty` lives in the parent `latex/` directory, and when latexmk runs from `subfiles/`, the TEXINPUTS path calculation breaks.

## Configuration Context

### Shared latexmkrc Structure

The project uses a shared latexmkrc at `ProofChecker/latex/latexmkrc` with theory-specific stubs:

```perl
# Theory stub (e.g., Theories/Bimodal/latex/latexmkrc)
do '../../../latex/latexmkrc';
```

### Current TEXINPUTS Configuration

```perl
# In shared latexmkrc (lines 54-75)
use Cwd qw(abs_path cwd);
my $source_dir = cwd();  # The theory's latex/ directory
my $shared_latex_dir = abs_path("$source_dir/../../../latex");

ensure_path('TEXINPUTS', "$source_dir/assets//");
ensure_path('TEXINPUTS', "$shared_latex_dir//");
```

### The Core Problem

`$source_dir = cwd()` is evaluated **at config load time**, not at compilation time. When:

1. User opens `subfiles/04-Metalogic.tex`
2. VimTeX calls latexmk from `subfiles/` directory
3. `cwd()` returns `Theories/Bimodal/latex/subfiles/`
4. `$source_dir` becomes the **wrong** base directory
5. `$shared_latex_dir` calculation also breaks (goes up 3 levels from subfiles/)

The `notation-standards.sty` file exists at `Theories/Bimodal/latex/notation-standards.sty` but is not found because TEXINPUTS points to incorrect paths.

## Attempted Solutions

### Attempt 1: Add Parent Directory to TEXINPUTS

**Approach**: Add `ensure_path('TEXINPUTS', '..//');` after existing TEXINPUTS lines.

**Rationale**: The trailing `//` enables Kpathsea recursive searching, so `../` would search the parent directory.

**Code Added**:
```perl
# Subfiles support: include parent directory in search path
# Enables compilation from subdirectories (e.g., subfiles/) to find .sty files in parent
ensure_path('TEXINPUTS', '..//');
```

**Result**: FAILED - Same error persists

**Analysis**: The relative `../` path is resolved relative to where latexmk runs, but since `$source_dir` is already wrong, this doesn't help. The `bimodal-notation.sty` at line 20 tries to load `notation-standards.sty` and can't find it.

**Action**: Change reverted

## Root Cause Analysis

### Why the Simple Fix Failed

The problem is deeper than just adding a relative path:

1. **Config Load Timing**: `cwd()` captures the directory at config parse time, not compile time
2. **Cascading Path Errors**: When `$source_dir` is wrong, `$shared_latex_dir` also becomes wrong
3. **Package Dependencies**: `bimodal-notation.sty` depends on `notation-standards.sty`, creating a chain of failures

### VimTeX Behavior

When `<leader>ls` toggles main:
- VimTeX changes the root document for compilation
- This may change the working directory passed to latexmk
- The config's assumptions about directory structure break

## Potential Solutions (Untested)

### Option 1: Detect Subdirectory and Adjust Paths

Add logic to detect if running from a subdirectory and adjust paths accordingly:

```perl
use Cwd qw(abs_path cwd);
use File::Spec;

my $source_dir = cwd();

# Detect if we're in a subdirectory (e.g., subfiles/)
if ($source_dir =~ /\/subfiles\/?$/) {
    $source_dir = abs_path("$source_dir/..");
}

my $shared_latex_dir = abs_path("$source_dir/../../../latex");
```

**Pros**: Keeps existing config structure, minimal changes
**Cons**: Fragile pattern matching, doesn't generalize to other subdirectories

### Option 2: Use Absolute Paths from Project Root

Compute paths relative to a known project root marker (e.g., `.git` or `lakefile.lean`):

```perl
use Cwd qw(abs_path cwd);
use File::Basename;

# Find project root by searching upward for marker
sub find_project_root {
    my $dir = cwd();
    while ($dir ne '/') {
        return $dir if -e "$dir/lakefile.lean";
        $dir = dirname($dir);
    }
    return cwd();  # Fallback
}

my $project_root = find_project_root();
# Compute all paths relative to known root
```

**Pros**: Robust regardless of compile directory
**Cons**: More complex, requires project marker to exist

### Option 3: Configure VimTeX to Always Compile from Parent

Configure VimTeX to always run latexmk from the theory's `latex/` directory, not subdirectories:

```lua
-- In VimTeX config
vim.g.vimtex_compiler_latexmk = {
    options = {
        '-cd',  -- Change to file directory (default)
        -- Or specify explicit root
    },
}
```

Or use `b:vimtex_main` buffer variable to control compilation root.

**Pros**: No changes to latexmkrc needed
**Cons**: Per-buffer configuration, may affect other workflows

### Option 4: Symlinks in Subdirectories

Create symlinks in `subfiles/` pointing to required `.sty` files:

```bash
cd Theories/Bimodal/latex/subfiles/
ln -s ../notation-standards.sty .
ln -s ../bimodal-notation.sty .
ln -s ../assets/ .
```

**Pros**: Simple, works immediately
**Cons**: Maintenance burden, pollutes subdirectories, not DRY

### Option 5: Theory-Specific TEXINPUTS Override

In each theory's `latexmkrc` stub, add explicit absolute paths:

```perl
do '../../../latex/latexmkrc';

# Theory-specific override for subfiles support
my $theory_latex_dir = '/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex';
ensure_path('TEXINPUTS', "$theory_latex_dir//");
ensure_path('TEXINPUTS', "$theory_latex_dir/assets//");
```

**Pros**: Explicit, guaranteed to work
**Cons**: Hardcoded absolute paths, not portable

## Relevant VimTeX Issues

### Issue #630: VimtexToggleMain and subfiles root folder
- https://github.com/lervag/vimtex/issues/630
- Discusses how VimTeX handles subfiles and root document detection
- Suggests using `%! TEX root = ../main.tex` directive

### Issue #3061: File .sty not found, emergency stop
- https://github.com/lervag/vimtex/issues/3061
- Similar TEXINPUTS path resolution issues
- Discusses latexmk working directory behavior

## File Structure Reference

```
ProofChecker/
  latex/
    latexmkrc                    # Shared config
    notation-standards.sty       # Shared styles
  Theories/
    Bimodal/
      latex/
        latexmkrc                # Stub: do '../../../latex/latexmkrc'
        bimodal-notation.sty     # Loads notation-standards.sty
        notation-standards.sty   # Local copy (if exists)
        assets/
          bimodal-notation.sty   # Asset version
        subfiles/
          04-Metalogic.tex       # Subfile document
```

## Recommendations

### Recommended Next Steps

1. **Investigate VimTeX Root Detection**: Check if `%! TEX root` directive in subfiles helps
2. **Test Option 1**: Implement subdirectory detection with careful pattern matching
3. **Consider Option 3**: VimTeX-side configuration may be cleaner than latexmkrc changes

### Information Needed

- Does VimTeX change `cwd` when `<leader>ls` toggles main?
- What is the exact latexmk invocation command VimTeX uses?
- Does the subfile have a `%! TEX root` directive?

### Debug Commands

```bash
# Check TEXINPUTS as seen by kpsewhich
kpsewhich --show-path=tex

# Verify .sty file locations
find Theories/Bimodal/latex -name "*.sty"

# Test latexmk directly from subfiles/
cd Theories/Bimodal/latex/subfiles
latexmk -xelatex 04-Metalogic.tex
```

## Conclusion

The attempted fix of adding `ensure_path('TEXINPUTS', '..//');` failed because the underlying problem is that `cwd()` captures the wrong directory when latexmk is invoked from a subdirectory. A more sophisticated solution is needed that either:

1. Detects and corrects for subdirectory execution in latexmkrc
2. Configures VimTeX to always compile from the correct directory
3. Uses absolute paths computed from a stable project root

The problem is well-understood but requires more investigation into VimTeX's compilation workflow to determine the cleanest fix.
