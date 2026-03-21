# Research Report: Task #483

**Task**: investigate_latex_aux_file_corruption_errors
**Date**: 2026-01-20
**Focus**: TEXINPUTS path resolution failure in LaTeX subfiles compilation with VimTeX

## Summary

The root cause of the "File 'bimodal-notation.sty' not found" error when compiling subfiles with VimTeX is that the shared latexmkrc uses `cwd()` at config load time to compute TEXINPUTS paths.
When latexmk is invoked from a subdirectory (e.g., `subfiles/`), `cwd()` returns the wrong base directory, breaking all dependent path calculations.
The recommended solution is to compute paths relative to a project root marker rather than relying on the working directory.

## Findings

### 1. Root Cause Analysis

The shared latexmkrc at `/home/benjamin/Projects/ProofChecker/latex/latexmkrc` uses:

```perl
use Cwd qw(abs_path cwd);
my $source_dir = cwd();  # Captured at config load time
my $shared_latex_dir = abs_path("$source_dir/../../../latex");

ensure_path('TEXINPUTS', "$source_dir/assets//");
ensure_path('TEXINPUTS', "$shared_latex_dir//");
```

**Problem**: `cwd()` is evaluated when the config file is parsed, not when compilation runs.
When VimTeX with `<leader>ls` (VimtexToggleMain) invokes latexmk from the subfiles directory:

1. User opens `Theories/Bimodal/latex/subfiles/04-Metalogic.tex`
2. VimTeX detects subfiles package and sets root to subfiles directory
3. latexmk runs from `subfiles/` directory
4. `cwd()` returns `.../Theories/Bimodal/latex/subfiles/`
5. `$source_dir/../../../latex` resolves incorrectly (goes up from subfiles, not from theory's latex/)
6. TEXINPUTS points to nonexistent paths
7. `bimodal-notation.sty` (which requires `notation-standards.sty`) cannot be found

### 2. VimTeX Behavior

Based on research from [VimTeX documentation](https://raw.githubusercontent.com/lervag/vimtex/master/doc/vimtex.txt) and [issue #630](https://github.com/lervag/vimtex/issues/630):

- VimTeX uses `self.file_info.root` as the compilation working directory
- When `<leader>ls` toggles main with subfiles, the root changes to the subfile's directory
- This is intentional behavior to allow standalone subfile compilation
- The root directory change affects where latexmk loads its config

**Key insight**: VimTeX's behavior is correct - it's the latexmkrc's reliance on `cwd()` that creates the incompatibility.

### 3. Community Solutions Analysis

Research from [LaTeX-Workshop issue #1895](https://github.com/James-Yu/LaTeX-Workshop/issues/1895), [latexmk configuration guides](https://lukideangeometry.xyz/blog/latexmk), and [Overleaf documentation](https://www.overleaf.com/learn/latex/Articles/An_introduction_to_Kpathsea_and_how_TeX_engines_search_for_files):

| Approach | Pros | Cons | Complexity |
|----------|------|------|------------|
| Project root marker | Robust, portable | Requires marker file | Medium |
| FindBin Perl module | Standard, reliable | May not work with `do` includes | Medium |
| latexmk `$do_cd = 1` | Simple | Breaks other path assumptions | Low |
| `%! TEX root` directive | VimTeX-native | Requires per-file setup | Low |
| Absolute paths in stubs | Guaranteed to work | Not portable | Low |
| Symlinks in subdirectories | Simple, immediate | Maintenance burden | Low |

### 4. Recommended Solution: Project Root Detection

The most robust solution is to compute paths relative to a known project root marker (e.g., `lakefile.lean` or `.git`).

**Proposed latexmkrc modification**:

```perl
use Cwd qw(abs_path cwd);
use File::Basename;

# Find project root by searching upward for marker
sub find_project_root {
    my $dir = cwd();
    while ($dir ne '/') {
        return $dir if -e "$dir/lakefile.lean" || -e "$dir/.git";
        $dir = dirname($dir);
    }
    return cwd();  # Fallback to current directory
}

# Determine theory root by finding latex/ directory above us
sub find_theory_latex_root {
    my $dir = cwd();
    while ($dir ne '/') {
        # If we're in a directory that has latexmkrc (but not ourselves loading)
        # and has the characteristic structure (assets/, subfiles/, etc.)
        my $parent = dirname($dir);
        if (-e "$parent/latexmkrc" && -d "$parent/assets") {
            return $parent;  # We're in a subdirectory like subfiles/
        }
        if (-e "$dir/latexmkrc" && -d "$dir/assets") {
            return $dir;  # We're in the theory's latex/ directory
        }
        $dir = $parent;
    }
    return cwd();
}

my $project_root = find_project_root();
my $source_dir = find_theory_latex_root();
my $shared_latex_dir = "$project_root/latex";

# Now paths are stable regardless of where latexmk is invoked
ensure_path('TEXINPUTS', "$source_dir/assets//");
ensure_path('TEXINPUTS', "$shared_latex_dir//");
```

### 5. Alternative Quick Fixes

#### Option A: TEX root directive in subfiles (Low effort, medium reliability)

Add to each subfile's first line:

```latex
%! TEX root = ../BimodalReference.tex
\documentclass[../BimodalReference.tex]{subfiles}
```

This tells VimTeX to treat the main file as root for compilation, preserving the correct working directory.

**Pros**: No config changes, VimTeX-native solution
**Cons**: Must add to every subfile, may affect standalone compilation

#### Option B: Subfiles directory latexmkrc override (Medium effort, high reliability)

The existing `subfiles/.latexmkrc` attempts this but incorrectly:

```perl
# Current (broken)
$ENV{'TEXINPUTS'} = '../assets/:' . ($ENV{'TEXINPUTS'} || '');
do '../latexmkrc';
```

**Fixed version**:

```perl
# Compute absolute paths before loading parent config
use Cwd qw(abs_path cwd);
my $subfiles_dir = cwd();
my $theory_latex_dir = abs_path("$subfiles_dir/..");
my $project_root = abs_path("$subfiles_dir/../../../../..");

# Set TEXINPUTS with absolute paths
$ENV{'TEXINPUTS'} = "$theory_latex_dir/assets/:$theory_latex_dir/:$project_root/latex/:" . ($ENV{'TEXINPUTS'} || '');

# Now load parent config (which will also add paths, but ours are already set)
do '../latexmkrc';
```

#### Option C: VimTeX root preservation (Low effort, user-side)

Configure VimTeX to compile from main file directory even when editing subfiles:

```lua
-- In Neovim config (lazy.nvim example)
{
  "lervag/vimtex",
  config = function()
    -- Ensure compilation uses main file's directory
    vim.g.vimtex_compiler_latexmk = {
      aux_dir = 'build',
      out_dir = 'build',
    }
  end,
}
```

Or use buffer variable to force main file:

```lua
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*/latex/subfiles/*.tex",
  callback = function()
    -- Find main file relative to subfile
    local main = vim.fn.expand("%:p:h:h") .. "/BimodalReference.tex"
    if vim.fn.filereadable(main) == 1 then
      vim.b.vimtex_main = main
    end
  end,
})
```

### 6. Current Project Structure

```
ProofChecker/
├── lakefile.lean                     # Project root marker
├── latex/
│   ├── latexmkrc                     # Shared config (problem location)
│   └── notation-standards.sty        # Shared styles
└── Theories/Bimodal/latex/
    ├── latexmkrc                     # Stub: do '../../../latex/latexmkrc'
    ├── assets/
    │   └── bimodal-notation.sty      # Theory-specific styles
    ├── BimodalReference.tex          # Main document
    └── subfiles/
        ├── .latexmkrc                # Subfiles override (currently broken)
        └── 04-Metalogic.tex          # Subfile document
```

## Recommendations

### Immediate (Quick fix)

1. Add `%! TEX root = ../BimodalReference.tex` to all subfiles
2. This allows VimTeX to compile from the correct directory without config changes

### Short-term (Robust fix)

1. Implement project root detection in shared latexmkrc
2. Use `find_project_root()` pattern to compute stable absolute paths
3. Remove the broken subfiles/.latexmkrc (it's no longer needed)

### Testing Protocol

After implementation:

1. From project root: `cd Theories/Bimodal/latex && latexmk BimodalReference.tex` - should work
2. From subfiles: `cd Theories/Bimodal/latex/subfiles && latexmk 04-Metalogic.tex` - should work
3. VimTeX: Open subfile, `<leader>lc` - should work
4. VimTeX: Open subfile, `<leader>ls`, `<leader>lv` - should work

## References

- [VimTeX Documentation](https://raw.githubusercontent.com/lervag/vimtex/master/doc/vimtex.txt)
- [VimTeX Issue #630: VimtexToggleMain root folder](https://github.com/lervag/vimtex/issues/630)
- [LaTeX-Workshop Issue #1895: subfiles cwd for latexmk](https://github.com/James-Yu/LaTeX-Workshop/issues/1895)
- [Kpathsea Introduction](https://www.overleaf.com/learn/latex/Articles/An_introduction_to_Kpathsea_and_how_TeX_engines_search_for_files)
- [Configuring latexmk](https://lukideangeometry.xyz/blog/latexmk)
- [VimTeX Compilation Tutorial](https://ejmastnak.com/tutorials/vim-latex/compilation/)
- [Perl FindBin Module](https://perldoc.perl.org/FindBin)

## Next Steps

1. **Create implementation plan** with `/plan 483` to:
   - Implement project root detection in shared latexmkrc
   - Add TEX root directives to subfiles as fallback
   - Update subfiles/.latexmkrc or remove it
   - Add verification tests
