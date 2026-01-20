# Research Report: Task #483

**Task**: 483 - Investigate LaTeX Aux File Corruption Errors
**Started**: 2026-01-20T12:00:00Z
**Completed**: 2026-01-20T12:45:00Z
**Effort**: Medium
**Priority**: High
**Dependencies**: None
**Sources/Inputs**: Codebase analysis, WebSearch, CTAN documentation, VimTeX documentation, latexmk manpages
**Artifacts**: This research report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Aux file corruption during continuous builds occurs when LaTeX is interrupted mid-write, leaving truncated auxiliary files
- The `subfiles` package enables independent chapter compilation with automatic preamble inheritance from the main file
- VimTeX's `VimtexToggleMain` command allows switching between compiling the root document and individual subfiles
- Using separate `aux_dir` and `out_dir` isolates build artifacts and makes cleanup easier
- Recommended workflow: use single-shot compilation (`VimtexCompileSS`) instead of continuous mode when editing intensively

## Context & Scope

The user experiences consistent build errors when using continuous compilation mode (`<leader>lc`) in Neovim with VimTeX while editing LaTeX files.
Errors include:
- "File ended while scanning use of \@newl@bel"
- "@@BOOKMARK" errors
- "Extra }, or forgotten \endgroup" errors in `.aux` files

These require frequent manual cleanup with `<leader>lk` (killing aux files).
The goal is to find solutions for faster, more robust builds with support for compiling individual subfiles.

## Findings

### Root Cause Analysis: Aux File Corruption

The "File ended while scanning" error occurs when auxiliary files are incompletely written.
This happens because:

1. **Interrupted compilation**: When LaTeX is stopped mid-execution (via Ctrl+C, closing the editor, or rapid saves triggering new compilations), auxiliary files may be truncated
2. **Race conditions in continuous mode**: With `latexmk -pvc` (preview continuously), rapid file saves can trigger overlapping compilation attempts
3. **File system timing**: Modern filesystems may report file changes faster than latexmk can complete a compilation cycle, causing repeated restarts

**Key insight**: The `-interaction=nonstopmode` setting (which VimTeX uses by default) allows LaTeX to proceed past errors, but corrupted aux files from a previous interrupted run persist and cause cascading failures.

**Solutions**:

1. **Delete aux files after corruption**: Run `latexmk -C` or `latexmk -CA` to clean all generated files, or use VimTeX's `<leader>lk` (`:VimtexClean`)
2. **Use single-shot compilation**: Instead of continuous mode, use `VimtexCompileSS` for explicit compilation after saving
3. **Configure longer polling intervals**: The `$sleep_time` variable in latexmkrc controls how frequently latexmk checks for changes (default 2 seconds)
4. **Graceful stopping**: Instead of killing the process, use `:VimtexStop` to gracefully end continuous compilation before editing

### Subfiles Package for Independent Chapter Building

The project already uses the `subfiles` package correctly.
Looking at the current structure:

```
Theories/Logos/latex/
  LogosReference.tex          (main document)
  subfiles/
    00-Introduction.tex       \documentclass[../LogosReference.tex]{subfiles}
    01-ConstitutiveFoundation.tex
    ...
```

**How subfiles works**:

1. When compiling the **main file**: subfile content is included via `\subfile{}`, ignoring the subfile's `\documentclass` line
2. When compiling a **subfile directly**: The preamble from the main file is automatically loaded

**Building individual subfiles**:

```bash
# Compile just the introduction
cd Theories/Logos/latex/subfiles
pdflatex 00-Introduction.tex
# Or with latexmk
latexmk -xelatex 00-Introduction.tex
```

**Benefits**:
- Faster iteration when working on a single chapter
- Reduced risk of aux file corruption (fewer files to manage)
- Preserves all cross-references when compiling full document later

**Path handling gotcha**: When compiling subfiles, relative paths for figures/includes are resolved relative to the subfile's directory, not the main file.
Current configuration uses `\graphicspath` or absolute paths in `TEXINPUTS` to handle this.

### VimTeX Configuration for Subfile Workflow

**Key command: `VimtexToggleMain`** (default mapping: `<leader>ls` or `\ls`)

This toggles between:
- Compiling the detected main file (e.g., `LogosReference.tex`)
- Compiling the current file as a standalone subfile

**Workflow for editing subfiles**:

1. Open a subfile (e.g., `00-Introduction.tex`)
2. VimTeX auto-detects the main file via the `\documentclass[../LogosReference.tex]{subfiles}` line
3. Press `<leader>ls` to toggle to subfile compilation mode
4. Use `<leader>ll` (single-shot) or `<leader>lc` (continuous) to compile just the current file
5. Press `<leader>ls` again to switch back to main document compilation

**Recommended VimTeX configuration**:

```lua
-- In your init.lua or LaTeX-specific config
vim.g.vimtex_compiler_latexmk = {
  aux_dir = 'build',
  out_dir = 'build',
  callback = 1,
  continuous = 0,  -- Disable continuous by default to prevent corruption
  executable = 'latexmk',
  options = {
    '-xelatex',
    '-verbose',
    '-file-line-error',
    '-synctex=1',
    '-interaction=nonstopmode',
  },
}

-- Auto-clean on quit
vim.api.nvim_create_autocmd("User", {
  pattern = "VimtexEventQuit",
  group = vim.api.nvim_create_augroup("vimtex_config", {}),
  command = "VimtexClean",
})
```

**Key setting**: `continuous = 0` disables continuous compilation by default.
Use explicit compilation (`<leader>ll`) after saving to avoid corruption issues.

### latexmk Configuration Improvements

The current `latexmkrc` configuration is well-structured.
Recommended additions for robustness:

```perl
# ProofChecker Shared LaTeX Build Configuration
# ... existing configuration ...

# Increase sleep time to reduce race conditions (default is 2)
$sleep_time = 3;

# Enable emulate_aux for better aux directory handling
$emulate_aux = 1;

# Force cleanup of fdb file on errors (helps recovery)
$force_mode = 1;

# Recorder mode for better dependency tracking
$recorder = 1;

# Add custom cleanup extensions for thorough cleanup
push @generated_exts, qw(synctex.gz(busy) fdb_latexmk);

# Hooks for pre/post processing (optional)
# $compiling_cmd = "echo 'Compiling...'";
# $success_cmd = "echo 'Build successful'";
# $failure_cmd = "echo 'Build failed - check for aux corruption'";
```

**For subfile-specific builds**, create a local `.latexmkrc` in the subfiles directory:

```perl
# Theories/Logos/latex/subfiles/.latexmkrc
@default_files = ('*.tex');
$pdf_mode = 5;  # XeLaTeX

# Point to the shared config for consistent settings
do '../../../../latex/latexmkrc';

# Override build directory for subfiles
$out_dir = '../build/subfiles';
$aux_dir = '../build/subfiles';
```

### Large LaTeX Project Best Practices

**Directory Structure** (already well-implemented in this project):

```
Theories/{Theory}/latex/
  {Theory}Reference.tex      # Main document
  latexmkrc                   # Local config loading shared config
  assets/                     # Theory-specific packages (.sty)
  bibliography/               # .bib files
  build/                      # All generated files (aux, log, pdf)
  subfiles/                   # Chapter files
    00-Introduction.tex
    01-Chapter1.tex
    ...
```

**Build performance tips**:

1. **Use `\include` with `\includeonly`** for draft mode:
   ```latex
   % In main preamble
   \includeonly{subfiles/00-Introduction}  % Only compile this chapter

   % In document body
   \include{subfiles/00-Introduction}
   \include{subfiles/01-Chapter1}
   ...
   ```
   Note: This requires using `\include` instead of `\subfile`, which is a different approach.

2. **Separate build directory** (already configured via `$out_dir = 'build'`):
   - Keeps source directory clean
   - Makes cleanup trivial (`rm -rf build/`)
   - Prevents aux file pollution

3. **Draft mode for faster iteration**:
   ```latex
   \documentclass[11pt,draft]{article}
   ```
   This skips image loading and shows overfull boxes clearly.

4. **Precompiled preamble** (advanced):
   ```bash
   pdflatex -ini -jobname=preamble "&pdflatex preamble.tex\dump"
   pdflatex "&preamble" document.tex
   ```
   This caches the preamble for faster subsequent compilations.

### Recommended Workflow

**For daily editing**:

1. **Use single-shot compilation** (`<leader>ll` in VimTeX) instead of continuous mode
2. **Toggle to subfile mode** (`<leader>ls`) when focusing on one chapter
3. **Compile subfile only** - faster iteration, isolated aux files
4. **Switch back** (`<leader>ls`) and compile full document periodically to verify cross-references

**When corruption occurs**:

1. Stop any running compilation: `<leader>lk` or `:VimtexStop`
2. Clean auxiliary files: `:VimtexClean!` (full clean) or `latexmk -CA` from terminal
3. Restart compilation: `<leader>ll`

**Preventive measures**:

1. Set `continuous = 0` in VimTeX configuration
2. Save files less frequently during heavy editing (or use `updatetime` to batch writes)
3. Consider using `tectonic` instead of latexmk for simpler builds (it auto-cleans aux files)

## Decisions

1. **Recommend single-shot over continuous compilation** - The corruption issues stem from interrupted builds in continuous mode
2. **Leverage existing subfiles setup** - The project structure already supports independent chapter compilation
3. **Use VimtexToggleMain for subfile workflow** - This is the simplest path to fast iteration on individual chapters
4. **Keep current latexmkrc structure** - The shared configuration pattern is correct; add robustness settings

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Subfile path resolution errors | Medium | Medium | Verify TEXINPUTS includes both source and shared directories |
| Cross-reference loss in subfile mode | Low | Low | Periodically compile full document to update aux files |
| VimTeX version incompatibility | Low | Medium | Pin VimTeX version or test updates before adopting |
| User habit change friction | Medium | Low | Document the `<leader>ls` + `<leader>ll` workflow prominently |

## Appendix

### Search Queries Used

1. `latex aux file corruption "File ended while scanning" continuous build latexmk`
2. `latex subfiles package build individual chapters standalone document 2025`
3. `latexmk continuous mode pvc file locking race condition aux corruption`
4. `vimtex neovim continuous compilation latexmk subfiles single file compilation 2025`
5. `latexmk $aux_dir $out_dir corruption fix rebuild auxiliary files`
6. `vimtex g:vimtex_compiler_latexmk_engines subfiles compilation main file detection`
7. `large latex project structure best practices chapter organization build performance`
8. `vimtex VimtexToggleMain subfile compile individual file`

### References

- [Overleaf: Multi-file LaTeX projects](https://www.overleaf.com/learn/latex/Multi-file_LaTeX_projects)
- [CTAN: subfiles package documentation](https://ctan.uib.no/macros/latex/contrib/subfiles/subfiles.pdf)
- [latexmk documentation](https://texdoc.org/serve/latexmk/0)
- [VimTeX GitHub repository](https://github.com/lervag/vimtex)
- [ejmastnak: Compiling LaTeX Documents in Vim](https://ejmastnak.com/tutorials/vim-latex/compilation/)
- [ejmastnak: A VimTeX Plugin Guide](https://ejmastnak.com/tutorials/vim-latex/vimtex/)
- [VimTeX wiki: Introduction](https://github.com/lervag/vimtex/wiki/introduction)
- [Overleaf: Stop on First Error compilation mode](https://www.overleaf.com/learn/how-to/Using_the_Stop_on_First_Error_compilation_mode)
- [Dickimaw Books: File ended while scanning](https://www.dickimaw-books.com/latex/novices/html/fileendedwhilescanning.html)
- [BENEVOL 2025: On the Structuring of LaTeX Projects](https://benevol2025.github.io/pre/paper10.pdf)
- [Overleaf: Management in a large project](https://www.overleaf.com/learn/latex/Management_in_a_large_project)

### VimTeX Key Mappings Reference

| Mapping | Command | Description |
|---------|---------|-------------|
| `<leader>ll` | `:VimtexCompile` | Start continuous compilation (or single-shot if `continuous=0`) |
| `<leader>lc` | `:VimtexCompile` | Toggle continuous compilation on/off |
| `<leader>lk` | `:VimtexStop` | Stop compilation |
| `<leader>lK` | `:VimtexStopAll` | Stop all compilations |
| `<leader>ls` | `:VimtexToggleMain` | Toggle between main file and subfile compilation |
| `<leader>lC` | `:VimtexClean` | Clean auxiliary files |
| `<leader>lg` | `:VimtexStatus` | Show compilation status |
| `<leader>le` | `:VimtexErrors` | Show compilation errors |
