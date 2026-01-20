# Implementation Plan: Task #483

- **Task**: 483 - investigate_latex_aux_file_corruption_errors
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/483_investigate_latex_aux_file_corruption_errors/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

This plan implements Option A from the research report: adding TEX root directives to all LaTeX subfiles. The TEX root directive tells VimTeX to compile from the main document's directory instead of the subfile's directory, which preserves the correct TEXINPUTS path resolution. This is a low-effort, medium-reliability quick fix.

### Research Integration

The research report (research-002.md) identified that the root cause of the "File 'bimodal-notation.sty' not found" error is that the shared latexmkrc uses `cwd()` at config load time, which returns the wrong base directory when latexmk is invoked from a subdirectory. Option A resolves this by telling VimTeX to use the main file's directory as the compilation root.

## Goals & Non-Goals

**Goals**:
- Add `%! TEX root` directive to all subfiles in the project
- Enable VimTeX compilation from subfiles without TEXINPUTS errors
- Preserve standalone subfile compilation capability where possible

**Non-Goals**:
- Modifying the latexmkrc configuration (that would be Option B)
- Changing VimTeX configuration (that would be Option C)
- Implementing project root detection in latexmkrc (deferred for future work)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Standalone compilation breaks | Medium | Low | TEX root is a hint, not a requirement; latexmk can still override |
| Different main file names | Low | Low | Verify each theory's main file before adding directive |
| Future subfiles need manual update | Low | Medium | Document convention in theory README |

## Implementation Phases

### Phase 1: Add TEX root directives to Bimodal subfiles [NOT STARTED]

**Goal**: Add TEX root directive to all 7 Bimodal theory subfiles

**Tasks**:
- [ ] Add `%! TEX root = ../BimodalReference.tex` to `00-Introduction.tex` (before line 1)
- [ ] Add `%! TEX root = ../BimodalReference.tex` to `01-Syntax.tex` (before line 1)
- [ ] Add `%! TEX root = ../BimodalReference.tex` to `02-Semantics.tex` (before line 1)
- [ ] Add `%! TEX root = ../BimodalReference.tex` to `03-ProofTheory.tex` (before line 1)
- [ ] Add `%! TEX root = ../BimodalReference.tex` to `04-Metalogic.tex` (before line 1)
- [ ] Add `%! TEX root = ../BimodalReference.tex` to `05-Theorems.tex` (before line 1)
- [ ] Add `%! TEX root = ../BimodalReference.tex` to `06-Notes.tex` (before line 1)

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/00-Introduction.tex` - Add TEX root directive as first line
- `Theories/Bimodal/latex/subfiles/01-Syntax.tex` - Add TEX root directive as first line
- `Theories/Bimodal/latex/subfiles/02-Semantics.tex` - Add TEX root directive as first line
- `Theories/Bimodal/latex/subfiles/03-ProofTheory.tex` - Add TEX root directive as first line
- `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` - Add TEX root directive as first line
- `Theories/Bimodal/latex/subfiles/05-Theorems.tex` - Add TEX root directive as first line
- `Theories/Bimodal/latex/subfiles/06-Notes.tex` - Add TEX root directive as first line

**Verification**:
- Each file starts with `%! TEX root = ../BimodalReference.tex`
- The `\documentclass[../BimodalReference.tex]{subfiles}` line follows on line 2

---

### Phase 2: Add TEX root directives to Logos subfiles [NOT STARTED]

**Goal**: Add TEX root directive to all 10 Logos theory subfiles

**Tasks**:
- [ ] Add `%! TEX root = ../LogosReference.tex` to `00-Introduction.tex` (before line 1)
- [ ] Add `%! TEX root = ../LogosReference.tex` to `01-ConstitutiveFoundation.tex` (before line 1)
- [ ] Add `%! TEX root = ../LogosReference.tex` to `02-DynamicsFoundation-Syntax.tex` (before line 1)
- [ ] Add `%! TEX root = ../LogosReference.tex` to `03-DynamicsFoundation-Semantics.tex` (before line 1)
- [ ] Add `%! TEX root = ../LogosReference.tex` to `04-DynamicsFoundation-Axioms.tex` (before line 1)
- [ ] Add `%! TEX root = ../LogosReference.tex` to `05-Epistemic.tex` (before line 1)
- [ ] Add `%! TEX root = ../LogosReference.tex` to `06-Normative.tex` (before line 1)
- [ ] Add `%! TEX root = ../LogosReference.tex` to `07-Spatial.tex` (before line 1)
- [ ] Add `%! TEX root = ../LogosReference.tex` to `08-Agential.tex` (before line 1)
- [ ] Add `%! TEX root = ../LogosReference.tex` to `09-Reflection.tex` (before line 1)

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/00-Introduction.tex` - Add TEX root directive as first line
- `Theories/Logos/latex/subfiles/01-ConstitutiveFoundation.tex` - Add TEX root directive as first line
- `Theories/Logos/latex/subfiles/02-DynamicsFoundation-Syntax.tex` - Add TEX root directive as first line
- `Theories/Logos/latex/subfiles/03-DynamicsFoundation-Semantics.tex` - Add TEX root directive as first line
- `Theories/Logos/latex/subfiles/04-DynamicsFoundation-Axioms.tex` - Add TEX root directive as first line
- `Theories/Logos/latex/subfiles/05-Epistemic.tex` - Add TEX root directive as first line
- `Theories/Logos/latex/subfiles/06-Normative.tex` - Add TEX root directive as first line
- `Theories/Logos/latex/subfiles/07-Spatial.tex` - Add TEX root directive as first line
- `Theories/Logos/latex/subfiles/08-Agential.tex` - Add TEX root directive as first line
- `Theories/Logos/latex/subfiles/09-Reflection.tex` - Add TEX root directive as first line

**Verification**:
- Each file starts with `%! TEX root = ../LogosReference.tex`
- The `\documentclass[../LogosReference.tex]{subfiles}` line follows on line 2

---

### Phase 3: Verification [NOT STARTED]

**Goal**: Verify the fix resolves the VimTeX compilation issue

**Tasks**:
- [ ] Test VimTeX compilation from a Bimodal subfile (open 04-Metalogic.tex, run `<leader>lc`)
- [ ] Test VimTeX compilation from a Logos subfile (open any subfile, run `<leader>lc`)
- [ ] Verify main document still compiles (cd to Theories/Bimodal/latex && latexmk BimodalReference.tex)
- [ ] Verify standalone subfile compilation still works if desired (cd to subfiles && latexmk 04-Metalogic.tex)

**Timing**: 10 minutes

**Verification**:
- No "File not found" errors when compiling from VimTeX
- TEXINPUTS resolves correctly to include both `assets/` and shared `latex/` directories

## Testing & Validation

- [ ] VimTeX `<leader>lc` compiles Bimodal subfile without errors
- [ ] VimTeX `<leader>lc` compiles Logos subfile without errors
- [ ] Main documents compile correctly from their directories
- [ ] No regressions in existing LaTeX workflow

## Artifacts & Outputs

- 17 modified subfiles with TEX root directives
- This implementation plan

## Rollback/Contingency

If the TEX root directive causes issues:
1. Remove the `%! TEX root` line from each affected subfile
2. Consider implementing Option B (subfiles/.latexmkrc fix) or Option C (VimTeX config) instead
3. The directive is a single-line addition, making rollback trivial via git revert
