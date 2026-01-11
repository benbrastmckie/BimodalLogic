# Implementation Plan: Task #375

**Task**: Integrate latexmkrc into project LaTeX assets
**Version**: 001
**Created**: 2026-01-11
**Language**: latex

## Overview

Integrate a central `latexmkrc` configuration into `ProofChecker/LaTeX/` using the Perl `do` stub pattern. This creates a single source of truth for LaTeX build configuration while preserving user-specific settings (like PDF viewer preferences) from global configs. The implementation involves creating the central config, stub files in theory directories, updating documentation, and modernizing build scripts.

## Phases

### Phase 1: Create Central latexmkrc Configuration

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create portable `LaTeX/latexmkrc` with shared build settings
2. Exclude user-specific settings (`$pdf_previewer`) to preserve global config

**Files to modify**:
- `LaTeX/latexmkrc` - Create new file with portable settings

**Steps**:
1. Create `LaTeX/latexmkrc` with these settings:
   - `$pdf_mode = 5` (XeLaTeX)
   - `$out_dir = 'build'` and `$aux_dir = 'build'`
   - `$xelatex` command with `-synctex=1` for editor integration
   - `$max_repeat = 5` and `$emulate_aux = 1`
   - `$bibtex_use = 2` for biblatex/biber
   - `@generated_exts` cleanup list
   - `$clean_ext` for full cleanup
2. Add clear comments explaining each setting
3. Add header comment explaining the stub pattern for theory directories

**Verification**:
- File exists at `LaTeX/latexmkrc`
- File is valid Perl syntax (no syntax errors when sourced)

---

### Phase 2: Create Theory Directory Stubs

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create minimal stub files that load the central config
2. Ensure stubs work from their respective directories

**Files to modify**:
- `Bimodal/LaTeX/latexmkrc` - Create new stub file
- `Logos/LaTeX/latexmkrc` - Create new stub file

**Steps**:
1. Create `Bimodal/LaTeX/latexmkrc`:
   ```perl
   # Load shared ProofChecker LaTeX build configuration
   # See LaTeX/README.md for details
   do '../../LaTeX/latexmkrc';
   ```
2. Create `Logos/LaTeX/latexmkrc`:
   ```perl
   # Load shared ProofChecker LaTeX build configuration
   # See LaTeX/README.md for details
   do '../../LaTeX/latexmkrc';
   ```

**Verification**:
- Both stub files exist
- Running `latexmk --version` in each directory doesn't produce config errors
- Stubs correctly reference the central config path

---

### Phase 3: Update Build Script

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Modernize `Bimodal/LaTeX/build.sh` to use latexmk instead of raw pdflatex
2. Leverage the new latexmkrc configuration

**Files to modify**:
- `Bimodal/LaTeX/build.sh` - Update to use latexmk

**Steps**:
1. Replace pdflatex calls with latexmk:
   - Remove manual two-pass compilation
   - Use `latexmk -xelatex BimodalReference.tex`
2. Update clean flag to use `latexmk -c` and `latexmk -C`
3. Keep the script simple since latexmkrc handles most settings
4. Update script comments to reflect new approach

**Verification**:
- `./build.sh` successfully compiles `BimodalReference.pdf` to `build/`
- `./build.sh --clean` removes build artifacts
- Build uses XeLaTeX (as specified in latexmkrc)

---

### Phase 4: Update Documentation

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Document the latexmkrc configuration in `LaTeX/README.md`
2. Explain how users can customize their PDF viewer

**Files to modify**:
- `LaTeX/README.md` - Add latexmk configuration section

**Steps**:
1. Add new section "## Build Configuration (latexmk)" to README.md:
   - Explain the stub pattern
   - List the settings in `latexmkrc`
   - Document how to set PDF viewer in `~/.latexmkrc`
   - Note that `build/` directory is gitignored
2. Add usage examples:
   - Basic: `cd Bimodal/LaTeX && latexmk BimodalReference.tex`
   - With preview: `latexmk -pvc BimodalReference.tex`
   - Clean: `latexmk -c` or `latexmk -C`
3. Document draft mode via environment variable

**Verification**:
- README.md has complete latexmk documentation
- Instructions are accurate and easy to follow

---

### Phase 5: Test and Verify

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Verify compilation works in both theory directories
2. Confirm user's global `$pdf_previewer` is preserved
3. Ensure build artifacts go to `build/` directory

**Files to modify**:
- None (testing only)

**Steps**:
1. Test Bimodal compilation:
   ```bash
   cd Bimodal/LaTeX
   latexmk BimodalReference.tex
   # Verify build/BimodalReference.pdf exists
   ```
2. Test Logos compilation:
   ```bash
   cd Logos/LaTeX
   latexmk LogosReference.tex
   # Verify build/LogosReference.pdf exists
   ```
3. Verify synctex works (check for .synctex.gz in build/)
4. Test cleanup: `latexmk -c` removes aux files, `latexmk -C` removes PDF
5. Verify user's PDF viewer setting is preserved (check `latexmk -pv` uses expected viewer)

**Verification**:
- Both documents compile successfully
- PDFs appear in `build/` subdirectory
- `.synctex.gz` files generated for editor integration
- User's global `$pdf_previewer` is used when previewing

---

## Dependencies

- latexmk must be installed on the system
- XeLaTeX must be available (part of TeX Live or similar)
- Task 373 (shared LaTeX assets) must be complete (it is)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| XeLaTeX not available on some systems | Med | Low | Document requirement, pdflatex fallback in README |
| Perl `do` path resolution issues | Med | Low | Test relative path from each directory |
| Build script changes break existing workflow | Low | Low | Preserve script interface, just change implementation |

## Success Criteria

- [ ] `LaTeX/latexmkrc` exists with portable settings (no `$pdf_previewer`)
- [ ] `Bimodal/LaTeX/latexmkrc` stub loads central config
- [ ] `Logos/LaTeX/latexmkrc` stub loads central config
- [ ] `Bimodal/LaTeX/build.sh` uses latexmk
- [ ] `LaTeX/README.md` documents latexmk configuration
- [ ] Both BimodalReference.tex and LogosReference.tex compile successfully
- [ ] Build artifacts go to `build/` subdirectory
- [ ] User's global `$pdf_previewer` setting is preserved

## Rollback Plan

If implementation fails:
1. Delete new `latexmkrc` files (central and stubs)
2. Restore original `build.sh` from git: `git checkout Bimodal/LaTeX/build.sh`
3. Revert README.md changes: `git checkout LaTeX/README.md`

The original pdflatex-based workflow will continue to work since it doesn't depend on latexmkrc files.
