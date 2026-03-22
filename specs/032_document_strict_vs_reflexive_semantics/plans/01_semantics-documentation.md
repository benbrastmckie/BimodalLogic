# Implementation Plan: Document Strict vs Reflexive Semantics

- **Task**: 32 - document_strict_vs_reflexive_semantics
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: None (Task 29 research reports already complete)
- **Research Inputs**: specs/032_document_strict_vs_reflexive_semantics/reports/01_typst-structure-research.md
- **Artifacts**: plans/01_semantics-documentation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Overview

This task creates a documentation section in the BimodalReference.typ manual explaining the design choice between strict and reflexive temporal semantics for G/H operators. The research recommends a new "Design Choices" subsection in 06-notes.typ, containing formal definitions of both semantic variants, a comparison table, and three remark boxes covering historical context, frame definability, and TM's rationale. Integration requires adding a cross-reference label to 02-semantics.typ and optionally updating a footnote in 04-metalogic.typ.

### Research Integration

The research report (01_typst-structure-research.md) provides:
- Recommended placement: `== Design Choices` section in 06-notes.typ (after line 34)
- Complete sample Typst code for all content elements
- Existing notation from bimodal-notation.typ to reuse
- Integration points in 02-semantics.typ and 04-metalogic.typ

Source materials from Task 29:
- **05_team-research.md**: Frame class collapse details (DN, DF, SF, SP trivially valid under reflexive)
- **06_theoretical-analysis.md**: Historical context (Prior, CTL, S4.3.1), frame definability theorems, formal semantic definitions

## Goals & Non-Goals

**Goals**:
- Create a clear, self-contained explanation of strict vs reflexive semantics
- Document the mathematical trade-offs between the two approaches
- Explain TM's current choice (strict semantics) and rationale
- Follow existing BimodalReference.typ formatting conventions (AMS aesthetic)
- Enable cross-referencing from semantics and metalogic chapters

**Non-Goals**:
- Advocate for switching to reflexive semantics (that is Task 29's domain)
- Provide implementation-level Lean code details
- Duplicate the full theoretical analysis (reference Task 29 reports instead)
- Create a separate chapter for design choices

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Notation inconsistency with existing chapters | M | L | Use bimodal-notation.typ symbols exactly as documented in research |
| Section placement disrupts flow of 06-notes.typ | L | L | Insert after "Discrepancy Notes" per research recommendation |
| Cross-reference label conflicts | L | L | Use unique label `<sec:design-choices>` and `<sec:truth>` |
| Typst compilation errors | M | L | Test incremental compilation after each phase |

## Implementation Phases

### Phase 1: Create Design Choices Section in 06-notes.typ [COMPLETED]

**Goal**: Add the main content section with definitions, comparison table, and remarks.

**Tasks**:
- [ ] Insert `== Design Choices` heading after line 34 in 06-notes.typ
- [ ] Add opening paragraph framing the semantic choice
- [ ] Add `=== Strict vs Reflexive Temporal Semantics` subsection
- [ ] Create `#definition("Strict Temporal Semantics (Current)")` box with `<` quantification
- [ ] Create `#definition("Reflexive Temporal Semantics")` box with `<=` quantification
- [ ] Add comparison table (6 properties: T-axiom, seriality, density, discreteness, frame class, canonical irreflexivity)
- [ ] Add `#remark("Historical Context")` covering Prior, CTL/CTL*, S4.3.1
- [ ] Add `#remark("Frame Definability")` covering modal definability limitations
- [ ] Add `#remark("Rationale for TM")` explaining current strict choice
- [ ] Add section label `<sec:design-choices>` for cross-referencing

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/typst/chapters/06-notes.typ` - Add ~80-100 lines of new content

**Verification**:
- File compiles without errors: `typst compile BimodalReference.typ`
- Section appears in correct location (after Discrepancy Notes)
- All definition and remark boxes render correctly
- Table displays with proper formatting

---

### Phase 2: Add Cross-References and Integration [COMPLETED]

**Goal**: Link the new section to existing chapters and verify complete document compilation.

**Tasks**:
- [ ] Add label `<sec:truth>` to `== Truth Conditions` heading in 02-semantics.typ (line 71)
- [ ] Add cross-reference `@sec:truth` in the strict semantics definition (06-notes.typ)
- [ ] Optionally update footnote in 04-metalogic.typ to reference `@sec:design-choices`
- [ ] Compile full document and verify all cross-references resolve
- [ ] Review rendered PDF for layout and formatting consistency

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/typst/chapters/02-semantics.typ` - Add label to Truth Conditions heading
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - Optional footnote update (if T-axiom mentioned)

**Verification**:
- All `@sec:*` references resolve without warnings
- Full document compiles: `typst compile BimodalReference.typ`
- PDF renders correctly with clickable cross-references

---

### Phase 3: Final Review and Documentation [COMPLETED]

**Goal**: Ensure content accuracy, style consistency, and create implementation summary.

**Tasks**:
- [ ] Review all mathematical notation matches bimodal-notation.typ conventions
- [ ] Verify historical claims against Task 29 source reports
- [ ] Check that comparison table accurately reflects research findings
- [ ] Confirm no duplicate content with existing semantics chapter
- [ ] Create implementation summary artifact

**Timing**: 30 minutes

**Files to modify**:
- `specs/032_document_strict_vs_reflexive_semantics/summaries/01_semantics-documentation-summary.md` - Create summary

**Verification**:
- Content review complete
- Implementation summary created
- Task ready for completion

## Testing & Validation

- [ ] `typst compile Theories/Bimodal/typst/BimodalReference.typ` succeeds without errors
- [ ] All cross-references (`@sec:truth`, `@sec:design-choices`) resolve
- [ ] PDF output displays new section correctly formatted
- [ ] Definition boxes use proper `#definition` environment
- [ ] Remark boxes use proper `#remark` environment
- [ ] Table renders with AMS-style formatting (stroke: none, hlines)
- [ ] Mathematical notation matches existing chapters

## Artifacts & Outputs

- `Theories/Bimodal/typst/chapters/06-notes.typ` - Modified with Design Choices section
- `Theories/Bimodal/typst/chapters/02-semantics.typ` - Modified with `<sec:truth>` label
- `specs/032_document_strict_vs_reflexive_semantics/summaries/01_semantics-documentation-summary.md` - Implementation summary

## Rollback/Contingency

If the implementation causes document compilation issues:
1. Revert changes to 06-notes.typ using git checkout
2. Revert changes to 02-semantics.typ if needed
3. Investigate Typst syntax errors incrementally
4. Re-implement with smaller, tested additions

The existing document structure is stable; additions are isolated to clearly defined locations.
