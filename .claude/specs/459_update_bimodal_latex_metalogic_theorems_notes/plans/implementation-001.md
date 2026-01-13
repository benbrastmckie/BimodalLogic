# Implementation Plan: Update Bimodal LaTeX Metalogic, Theorems, and Notes

- **Task**: 459 - Update Bimodal LaTeX Metalogic, Theorems, and Notes
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

Update three Bimodal LaTeX subfiles to document recent implementation progress.
The primary addition is a new Decidability section in 04-Metalogic.tex covering the tableau-based decision procedure.
Secondary updates include new S5 theorems and generalized necessitation in 05-Theorems.tex, and implementation status updates in 06-Notes.tex.

### Research Integration

Research report (research-001.md) identified:
- Decidability module with soundness proven, completeness partial (requires FMP)
- Main theorems: validity_decidable, decide_sound, decide_complete
- Tableau-based algorithm with O(2^n) time, O(n) space (PSPACE-complete)
- New theorems: box_conj_iff, diamond_disj_iff, s5_diamond_box biconditionals
- Generalized necessitation for modal and temporal contexts

## Goals & Non-Goals

**Goals**:
- Add complete Decidability subsection to 04-Metalogic.tex
- Document new S5 theorems in 05-Theorems.tex
- Update implementation status tables in 06-Notes.tex
- Maintain consistent LaTeX style (one sentence per line)

**Non-Goals**:
- Modifying the main BimodalReference.tex structure
- Adding new sections beyond those specified
- Creating new macro definitions

## Risks & Mitigations

- Risk: Inconsistent notation with existing document. Mitigation: Use existing logos-notation.sty macros.
- Risk: Overfull hboxes in tables. Mitigation: Use @{} column specifiers and abbreviate where needed.
- Risk: Missing theorem details. Mitigation: Cross-reference research report and Lean source files.

## Implementation Phases

### Phase 1: Update 04-Metalogic.tex with Decidability [NOT STARTED]

**Goal:** Add new Decidability subsection documenting the tableau-based decision procedure.

**Tasks:**
- [ ] Add \subsection{Decidability} after Completeness Infrastructure section (line 108)
- [ ] Document main theorems: validity_decidable and decide_sound
- [ ] Describe tableau algorithm structure (signed formulas, expansion rules, closure, saturation)
- [ ] Add complexity analysis (PSPACE-complete, O(2^n) time, O(n) space)
- [ ] Add implementation status table for decidability submodules
- [ ] Add note about soundness being proven vs completeness requiring FMP

**Timing:** 1 hour

**Files to modify:**
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/04-Metalogic.tex` - Add decidability section after line 108

**Verification:**
- [ ] LaTeX compiles without errors
- [ ] New section appears correctly in document structure
- [ ] Theorem statements match Lean implementation

---

### Phase 2: Update 05-Theorems.tex with New Theorems [NOT STARTED]

**Goal:** Add missing S5 theorems and verify generalized necessitation section.

**Tasks:**
- [ ] Verify S5 Collapse theorem includes biconditional form (already present as theorem 69-71)
- [ ] Add s5_diamond_box_to_truth theorem if missing
- [ ] Add T-Box-Consistency theorem: Box(phi AND NOT phi) -> False
- [ ] Update Modal S5 section with any missing theorems from research
- [ ] Verify Generalized Necessitation section is complete (already present lines 147-157)
- [ ] Update Module Organization table if needed

**Timing:** 45 minutes

**Files to modify:**
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/05-Theorems.tex` - Add missing theorems to Modal S5 section

**Verification:**
- [ ] All theorems from research report are documented
- [ ] LaTeX compiles without errors
- [ ] Theorem formatting is consistent with existing style

---

### Phase 3: Update 06-Notes.tex with Status Updates [NOT STARTED]

**Goal:** Update implementation status table and source files documentation.

**Tasks:**
- [ ] Add Decidability row to Implementation Status table
- [ ] Add Decidability directory to Source Files table
- [ ] Add discrepancy note about decidability vs canonical model approaches
- [ ] Update Completeness Status section with decidability note

**Timing:** 45 minutes

**Files to modify:**
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/06-Notes.tex` - Update tables and add notes

**Verification:**
- [ ] Implementation Status table has Decidability row
- [ ] Source Files table includes Decidability directory
- [ ] LaTeX compiles without errors

---

### Phase 4: Verify Build and Final Review [NOT STARTED]

**Goal:** Ensure all three files compile correctly together.

**Tasks:**
- [ ] Build BimodalReference.tex to verify subfiles integrate
- [ ] Check for any LaTeX warnings or errors
- [ ] Verify cross-references resolve if any were added
- [ ] Review document structure in PDF output

**Timing:** 15 minutes

**Files to modify:**
- None (verification only)

**Verification:**
- [ ] `pdflatex BimodalReference.tex` succeeds
- [ ] No overfull hbox warnings
- [ ] Document renders correctly

## Testing & Validation

- [ ] All three subfiles compile individually
- [ ] Main BimodalReference.tex compiles with all subfiles
- [ ] No LaTeX errors or warnings
- [ ] Content matches research report findings
- [ ] Follows semantic linefeed convention (one sentence per line)

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (on completion)

## Rollback/Contingency

If LaTeX errors occur during implementation:
1. Revert individual file changes using git checkout
2. Identify specific problematic content
3. Simplify table structures or theorem formatting as needed
