# Research Report: Task #375

**Task**: Integrate latexmkrc into project LaTeX assets
**Date**: 2026-01-11
**Revised**: 2026-01-11
**Focus**: Best practices for latexmk configuration with build directory isolation, central config sharing, and gitignore patterns

## Summary

Research reveals that integrating a project-level `latexmkrc` configuration file into `ProofChecker/LaTeX/` will standardize LaTeX compilation across contributors. The recommended approach uses **Perl's `do` function** to create minimal one-line stub files in each theory directory that load the central config. This avoids duplication while preserving user-specific settings (like `$pdf_previewer`) from global configs. The `build/` directory is already gitignored.

## Findings

### Current Global Configuration Analysis

The user's `~/.config/latexmk/latexmkrc` contains:

| Setting | Value | Purpose |
|---------|-------|---------|
| `$pdf_mode` | 5 (XeLaTeX) | Modern font/Unicode support |
| `$out_dir` | `build` | Isolates auxiliary files |
| `$aux_dir` | `build` | Keeps source directories clean |
| `$emulate_aux` | 1 | Faster auxiliary file handling |
| `$max_repeat` | 5 | Prevents infinite compile loops |
| `$bibtex_use` | 2 | Uses biber for biblatex |
| `$draft_mode` | Environment variable | Toggleable fast compilation |
| `$pdf_previewer` | `start sioyek` | Local viewer preference |

**Strengths:**
- Build directory isolation (`build/`) aligns with project goals
- Draft mode support via environment variable is flexible
- Cleanup rules cover common auxiliary extensions
- XeLaTeX choice supports modern LaTeX features

**Issues for Project Integration:**
- `$pdf_previewer` is user/platform-specific (Sioyek not universal)
- No TEXINPUTS path configuration for shared assets
- `$xelatex` command includes synctex which may need documentation

### Existing Project Infrastructure

**Task 373 created:** `ProofChecker/LaTeX/` with shared assets:
- `formatting.sty` - Document formatting
- `notation-standards.sty` - Shared notation
- `bib_style.bst` - Bibliography style
- `README.md` - Usage documentation

**Existing build scripts:** `Bimodal/LaTeX/build.sh` uses `pdflatex` with `-output-directory=build`, not latexmk. This indicates opportunity for standardization.

**Gitignore status:** The root `.gitignore` already includes:
```
build/
```
This covers LaTeX build directories project-wide.

### Best Practices from Research

#### Build Directory Configuration

Per [latexmk documentation](https://mg.readthedocs.io/latexmk.html) and [Luke Naylor's guide](https://lukideangeometry.xyz/blog/latexmk):
- `$out_dir` and `$aux_dir` should match for simplicity
- `build/` is a common convention
- Post-process hooks can copy PDFs: `$success_cmd = 'cp build/*.pdf .'`

#### Project-Level Configuration

From [Overleaf documentation](https://docs.overleaf.com/managing-projects-and-files/the-latexmkrc-file):
- Project-level `latexmkrc` or `.latexmkrc` overrides user/system config
- Enables consistent builds across team members
- Should be committed to version control

#### LaTeX Gitignore Standards

From [GitHub's TeX.gitignore](https://github.com/github/gitignore/blob/main/TeX.gitignore):
- Core auxiliary: `*.aux`, `*.log`, `*.out`, `*.toc`, `*.fls`
- Build tools: `*.fdb_latexmk`, `*.synctex.gz`
- Build directories: `latex.out/`, `build/`

**Current project gitignore already handles `build/`** - no changes needed.

### Configuration Recommendations

#### 1. Portable Settings (Include in project)
```perl
# Build directory isolation
$out_dir = 'build';
$aux_dir = 'build';

# XeLaTeX with standard options
$pdf_mode = 5;
$xelatex = 'xelatex -interaction=nonstopmode -file-line-error -synctex=1 %O %S';

# Compilation control
$max_repeat = 5;
$emulate_aux = 1;

# Bibliography
$bibtex_use = 2;

# Cleanup extensions
@generated_exts = qw(aux bbl bcf blg fdb_latexmk fls log nav out run.xml snm synctex.gz toc vrb);
```

#### 2. User-Specific Settings (Exclude from project)
```perl
# PDF viewer - user preference
$pdf_previewer = 'start sioyek %S';  # User-specific

# Draft mode - keep as environment variable
$draft_mode = $ENV{'LATEXMK_DRAFT_MODE'} || 0;
```

#### 3. TEXINPUTS Configuration
Add to enable shared asset discovery:
```perl
# Ensure shared LaTeX assets are discoverable
ensure_path('TEXINPUTS', '../../LaTeX//');
```

### File Placement Options

**Option A: Central config with Perl `do` stubs (RECOMMENDED)**

Create `LaTeX/latexmkrc` with shared settings, then in each theory directory create a one-line stub:

```perl
# Bimodal/LaTeX/latexmkrc (or Logos/LaTeX/latexmkrc)
do '../../LaTeX/latexmkrc';
```

- Pros: Single source of truth, works with any editor/IDE that auto-discovers `latexmkrc`, no symlink issues on Windows
- Cons: Requires one-line stub per directory (trivial)

**Option B: Symlinks**

```bash
cd Bimodal/LaTeX && ln -s ../../LaTeX/latexmkrc .latexmkrc
cd Logos/LaTeX && ln -s ../../LaTeX/latexmkrc .latexmkrc
```

- Pros: Zero duplication
- Cons: Symlinks fragile on Windows, some editors don't follow them

**Option C: Use `-r` flag in build scripts**

Update `build.sh` to use latexmk with explicit config:

```bash
latexmk -r ../../LaTeX/latexmkrc -xelatex BimodalReference.tex
```

- Pros: No local config files needed
- Cons: Must use the script, raw `latexmk` won't find config

**Option D: Wrapper script at project root**

Create `LaTeX/latexmk-build` wrapper:

```bash
#!/bin/bash
latexmk -r "$(dirname "$0")/latexmkrc" "$@"
```

- Pros: Single entry point
- Cons: Non-standard workflow

**Recommendation**: Option A (stub with `do`) - minimal maintenance, works everywhere, preserves user's global `$pdf_previewer`.

### Config Loading Order and User Settings

Latexmk reads configuration files in order ([Arch man page](https://man.archlinux.org/man/latexmk.1)):

1. System RC file (`/opt/local/share/latexmk/LatexMk` or similar)
2. User RC file (`~/.latexmkrc`)
3. Current directory RC file (`latexmkrc` or `.latexmkrc`)
4. Command-line `-r` files

**Key insight**: If the project `latexmkrc` does NOT set `$pdf_previewer`, the user's setting from `~/.latexmkrc` is preserved. This allows each contributor to use their preferred PDF viewer while sharing all other build settings.

## Recommendations

1. **Create `LaTeX/latexmkrc`** - Central portable configuration WITHOUT `$pdf_previewer` (preserves user's global setting)
2. **Create stub files** - One-line `do '../../LaTeX/latexmkrc';` in `Bimodal/LaTeX/latexmkrc` and `Logos/LaTeX/latexmkrc`
3. **Update `LaTeX/README.md`** - Document latexmkrc usage, stub pattern, and how users can set their preferred viewer
4. **Keep gitignore as-is** - `build/` is already covered
5. **Update `build.sh` scripts** - Migrate from raw pdflatex to latexmk for consistency

## References

- [latexmk documentation](https://mg.readthedocs.io/latexmk.html) - Official usage guide
- [Arch Linux latexmk man page](https://man.archlinux.org/man/latexmk.1) - Config loading order and `-r` option
- [Luke Naylor's latexmk guide](https://lukideangeometry.xyz/blog/latexmk) - Project configuration patterns
- [Overleaf latexmkrc docs](https://docs.overleaf.com/managing-projects-and-files/the-latexmkrc-file) - Team collaboration patterns
- [GitHub TeX.gitignore](https://github.com/github/gitignore/blob/main/TeX.gitignore) - Standard LaTeX gitignore
- [latexmk v4.87 release notes](https://www.cantab.net/users/johncollins/latexmk/versions.html) - Recent aux_dir improvements
- [LaTeX Workshop subfiles discussion](https://github.com/James-Yu/LaTeX-Workshop/issues/1895) - Symlink vs stub approaches

## Next Steps

1. Create `LaTeX/latexmkrc` with portable settings (no `$pdf_previewer`)
2. Create `Bimodal/LaTeX/latexmkrc` stub: `do '../../LaTeX/latexmkrc';`
3. Create `Logos/LaTeX/latexmkrc` stub: `do '../../LaTeX/latexmkrc';`
4. Update `LaTeX/README.md` with latexmk usage section
5. Update `Bimodal/LaTeX/build.sh` to use latexmk
6. Test compilation in both theory directories
7. Verify user's global `$pdf_previewer` setting is preserved
