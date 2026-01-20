# Implementation Plan: Fix Metalogic LaTeX Formatting and Structure Issues

- **Task**: 646 - Fix Metalogic LaTeX formatting and structure issues
- **Status**: [IMPLEMENTING]
- **Effort**: 3.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/646_fix_metalogic_latex_formatting_issues/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

This plan addresses 14 FIX:/NOTE: tags in `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` covering formatting consistency, explanatory content additions, and structural reorganization. The research report identified three categories of issues with recommended phasing from lowest to highest risk. LaTeX compilation will be verified after each phase.

### Research Integration

Key findings from research-001.md integrated into this plan:
- 14 total tags split into 3 categories: definitional ordering (4), explanatory content (5), formatting/presentation (5)
- 5 TODO tags explicitly excluded as out-of-scope research questions
- Project standards require: theorem names in italics for prose, `\texttt{}` for Lean names, definitions before first use
- Recommended phasing strategy: formatting first (low risk), then content (medium risk), then structure (higher risk)

## Goals & Non-Goals

**Goals**:
- Resolve all 14 FIX:/NOTE: tags in 04-Metalogic.tex
- Ensure LaTeX compiles without errors after changes
- Follow project LaTeX style guide conventions
- Remove resolved tags from source file

**Non-Goals**:
- Address TODO: tags (5 excluded, represent deeper research questions)
- Modify other LaTeX subfiles
- Change mathematical content or proofs
- Rewrite sections beyond tag requirements

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking LaTeX compilation | High | Medium | Compile after each phase, verify no errors |
| Inconsistent theorem name formatting | Low | Low | Grep for theorem names to ensure all converted |
| Cross-reference breakage from reordering | Medium | Medium | Check `\cref`/`\ref` usage after Phase 3 |
| TikZ diagram errors from flipping | Medium | Medium | Test diagram separately before integrating |
| Paragraph flow disruption from merges | Medium | Low | Read merged sections aloud for flow |

## Implementation Phases

### Phase 1: Formatting Consistency [COMPLETED]

**Goal**: Apply mechanical formatting fixes with minimal risk

**Tasks**:
- [ ] Issue 12: Apply italics to theorem names in prose (change "Representation Theorem" to `\emph{Representation Theorem}`)
- [ ] Scan entire file for other theorem name references and apply consistent formatting
- [ ] Issue 14a (line 371): Change `Metalogic_v2` to `\texttt{Metalogic\_v2}`
- [ ] Issue 14b (line 409): Update directory items to use `\textbf{\texttt{Core/}}` formatting
- [ ] Remove FIX/NOTE tags for resolved issues (lines 109, 371, 409)
- [ ] Compile LaTeX to verify no errors

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` - formatting changes throughout

**Verification**:
- All theorem names in prose are italicized
- All Lean directory references use `\texttt{}`
- LaTeX compiles without errors
- Tags removed from source

---

### Phase 2: Content Additions [IN PROGRESS]

**Goal**: Add explanatory prose without restructuring existing content

**Tasks**:
- [ ] Issue 5 (line 101): Merge Lindenbaum footnote into prose explanation, remove redundant footnote
- [ ] Issue 6 (line 171): Add 2-3 sentences after Strong Representation Theorem explaining its significance
- [ ] Issue 7 (line 261): Add explanation about alignment of proof system and semantics after Provable iff Valid theorem
- [ ] Issue 8 (line 304): Define what "proof pi" represents (derivation tree/term) in decision procedure context
- [ ] Issue 9 (line 310): Add brief explanatory text for:
  - Direct axiom proof (matching formula to axiom schema)
  - Proof search (automated tactic application)
  - Tableau (systematic truth/falsity decomposition)
- [ ] Issue 10 (line 342): Add 2-3 sentences interpreting complexity table values (PSPACE-complete practical meaning)
- [ ] Issue 11 (line 367): Add explanation of decidability usefulness despite computational limitations
- [ ] Remove FIX/NOTE tags for resolved issues (lines 101, 171, 261, 304, 310, 342, 367)
- [ ] Compile LaTeX to verify no errors

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` - prose additions at specified locations

**Verification**:
- Each theorem/concept has appropriate explanatory text following
- New prose follows one-sentence-per-line convention
- LaTeX compiles without errors
- Tags removed from source

---

### Phase 3: Structural Reorganization [NOT STARTED]

**Goal**: Restructure sections for improved definition ordering and flow

**Tasks**:
- [ ] Issue 1 (line 89): Create formal `\begin{definition}[Negation-Complete]` environment, then state that MCSs have this property
- [ ] Issue 2 (line 116): Reorder subsection to introduce history/time definitions BEFORE Canonical World State definition
- [ ] Issue 3 (line 147): Add brief explanation of quotient construction before referencing it in Truth lemma
- [ ] Issue 4 (line 285): Move Finite Model Property content into Decidability subsection as opening paragraph, remove FMP subsection
- [ ] Issue 13 (lines 181, 183): Reorganize theorem dependency diagram:
  - Flip orientation (Core Infrastructure at top, Corollaries at bottom)
  - Remove left-side layer labels ("Corollaries", "Central Result", "Core Infrastructure")
  - Add explanatory text following diagram
  - Add `\label{fig:theorem-deps}` for cross-reference
- [ ] Check all `\cref`/`\ref` usages for breakage
- [ ] Remove FIX/NOTE tags for resolved issues (lines 89, 116, 127, 147, 154, 181, 183, 285)
- [ ] Compile LaTeX to verify no errors

**Timing**: 1.25 hours

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` - structural changes to sections

**Verification**:
- Negation-completeness defined before use
- Histories/times defined before canonical world states
- Quotient construction explained before referenced
- FMP content integrated into Decidability section
- Diagram reads top-to-bottom (fundamental to derived)
- All cross-references still work
- LaTeX compiles without errors
- Tags removed from source

---

## Testing & Validation

- [ ] LaTeX compiles without errors after each phase
- [ ] No undefined references or missing labels
- [ ] PDF output renders correctly
- [ ] All 14 FIX:/NOTE: tags removed from source
- [ ] TODO: tags (5 excluded) remain untouched
- [ ] Prose additions follow semantic linefeeds convention
- [ ] Theorem names consistently italicized throughout
- [ ] Lean names consistently use `\texttt{}` formatting

## Artifacts & Outputs

- `specs/646_fix_metalogic_latex_formatting_issues/plans/implementation-001.md` (this file)
- `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` (modified)
- `specs/646_fix_metalogic_latex_formatting_issues/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If LaTeX compilation fails during a phase:
1. Use git to restore previous version: `git checkout -- Theories/Bimodal/latex/subfiles/04-Metalogic.tex`
2. Re-apply changes incrementally to isolate the error
3. If TikZ diagram changes cause errors, test diagram in isolation first

If cross-references break in Phase 3:
1. Check for label name changes
2. Verify all `\cref`/`\ref` targets still exist
3. Update references as needed before proceeding
