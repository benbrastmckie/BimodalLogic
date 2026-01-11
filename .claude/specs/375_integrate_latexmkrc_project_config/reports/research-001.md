# Research Report: Task #375

**Task**: Integrate latexmkrc into project LaTeX assets
**Date**: 2026-01-11
**Focus**: Best practices for latexmk configuration with build directory isolation and gitignore patterns

## Summary

Research reveals that integrating a project-level `latexmkrc` configuration file into `ProofChecker/LaTeX/` will standardize LaTeX compilation across contributors. The current global configuration at `~/.config/latexmk/latexmkrc` provides an excellent foundation. Key improvements include: confirming the `build/` directory is already gitignored, removing viewer-specific settings for portability, and documenting draft mode usage.

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

**Option A: Single project-level config at `LaTeX/latexmkrc`**
- Pros: Central location, follows task 373 pattern
- Cons: Requires copying or symlinking to theory directories

**Option B: Config in each theory's LaTeX directory**
- Pros: Works directly where latexmk is run
- Cons: Potential duplication

**Option C: Template at `LaTeX/latexmkrc` + symlinks**
- Pros: Single source of truth, works in place
- Cons: Requires symlink management

**Recommendation**: Option A with documentation on copying to theory directories or running latexmk with explicit config path.

## Recommendations

1. **Create `LaTeX/latexmkrc`** - Portable configuration without viewer settings
2. **Add `LaTeX/latexmkrc.user.template`** - Template for user-specific settings
3. **Update `LaTeX/README.md`** - Document latexmkrc usage and configuration
4. **Keep gitignore as-is** - `build/` is already covered
5. **Consider updating `build.sh`** - Migrate from raw pdflatex to latexmk

## References

- [latexmk documentation](https://mg.readthedocs.io/latexmk.html) - Official usage guide
- [Luke Naylor's latexmk guide](https://lukideangeometry.xyz/blog/latexmk) - Project configuration patterns
- [Overleaf latexmkrc docs](https://docs.overleaf.com/managing-projects-and-files/the-latexmkrc-file) - Team collaboration patterns
- [GitHub TeX.gitignore](https://github.com/github/gitignore/blob/main/TeX.gitignore) - Standard LaTeX gitignore
- [latexmk v4.87 release notes](https://www.cantab.net/users/johncollins/latexmk/versions.html) - Recent aux_dir improvements

## Next Steps

1. Create `LaTeX/latexmkrc` with portable settings
2. Create `LaTeX/latexmkrc.user.template` for viewer/draft settings
3. Update `LaTeX/README.md` with latexmk usage section
4. Test compilation in Bimodal/LaTeX/ and Logos/LaTeX/
5. Optionally update theory-specific `build.sh` scripts to use latexmk
