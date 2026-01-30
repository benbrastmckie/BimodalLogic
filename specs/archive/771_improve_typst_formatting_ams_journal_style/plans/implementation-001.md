# Implementation Plan: Improve Typst Formatting to AMS Journal Style

- **Task**: 771 - improve_typst_formatting_ams_journal_style
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/771_improve_typst_formatting_ams_journal_style/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Overview

Convert colored diagram elements in BimodalReference.typ to grayscale to achieve AMS-style professional mathematics journal appearance. The research identified that theorem environments and tables are already AMS-compliant; only two chapter files (00-introduction.typ, 04-metalogic.typ) contain colored diagrams requiring conversion. URLblue for hyperlinks will be preserved as this is standard practice for digital documents.

### Research Integration

Key findings from research-001.md:
- Template-level theorem environments already use `fill: none`, `stroke: none` (compliant)
- URLblue hyperlinks should be preserved for digital document usability
- Three diagrams require conversion: World History (introduction), Canonical Model (metalogic), Tableau Proof (metalogic)
- Grayscale mapping provided with varying lightness values to maintain visual distinction

## Goals & Non-Goals

**Goals**:
- Remove all colors from diagrams except URLblue hyperlinks
- Convert colored fills to grayscale with sufficient contrast for visual distinction
- Match the professional AMS-style appearance of BimodalReference.tex

**Non-Goals**:
- Adding patterns or hatching (grayscale fills are sufficient)
- Modifying theorem environment styling (already compliant)
- Changing table formatting (already uses booktabs-style rules)
- Removing URLblue from hyperlinks (necessary for usability)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Grayscale boxes lose visual distinction | Medium | Low | Use varying gray levels (75%-90%) with 5%+ separation |
| Worldline elements become invisible | Medium | Low | Use black instead of blue.darken(40%) for strong contrast |
| PDF rendering differs from preview | Low | Low | Compile and visually verify after each phase |

## Implementation Phases

### Phase 1: Convert Introduction Diagram [NOT STARTED]

**Goal**: Convert the World History diagram in 00-introduction.typ from colored to grayscale

**Tasks**:
- [ ] Change past light cone fill from `blue.transparentize(85%)` to `gray.lighten(90%)`
- [ ] Change future light cone fill from `orange.transparentize(85%)` to `gray.lighten(85%)`
- [ ] Change worldline stroke/fill from `blue.darken(40%)` to `black`
- [ ] Keep gray dotted lines for counterfactuals (already appropriate)
- [ ] Compile and verify visual clarity

**Timing**: 30 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/chapters/00-introduction.typ` - Lines 29-71 (CeTZ diagram)

**Verification**:
- Compile BimodalReference.typ successfully
- Light cones are distinguishable in grayscale
- Worldline is clearly visible in black

---

### Phase 2: Convert Metalogic Diagrams [NOT STARTED]

**Goal**: Convert both CeTZ diagrams in 04-metalogic.typ to grayscale

**Tasks**:
- [ ] Canonical Model diagram (lines 193-215):
  - [ ] Replace `blue.lighten(90%)` fills with `gray.lighten(90%)`
  - [ ] Replace `green.lighten(85%)` fill with `gray.lighten(82%)`
  - [ ] Replace `orange.lighten(85%)` fills with `gray.lighten(75%)`
- [ ] Tableau Proof diagram (lines 388-413):
  - [ ] Replace `blue.lighten(90%)` fills with `gray.lighten(90%)`
  - [ ] Replace `green.lighten(85%)` fill with `gray.lighten(82%)`
  - [ ] Replace `orange.lighten(85%)` fill with `gray.lighten(75%)`
  - [ ] Replace `yellow.lighten(80%)` fill with `gray.lighten(88%)`
  - [ ] Replace `purple.lighten(90%)` fills with `gray.lighten(78%)`
- [ ] Compile and verify visual distinction between layers

**Timing**: 45 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/chapters/04-metalogic.typ` - Lines 193-215 (Canonical Model), Lines 388-413 (Tableau Proof)

**Verification**:
- Both diagrams compile without errors
- Each layer is visually distinguishable
- Arrows and labels remain clear

---

### Phase 3: Final Verification and Comparison [NOT STARTED]

**Goal**: Verify complete document compiles and matches AMS style expectations

**Tasks**:
- [ ] Compile full BimodalReference.typ document
- [ ] Verify no remaining color usage except URLblue
- [ ] Visual comparison with BimodalReference.tex PDF (if available)
- [ ] Verify URLblue links remain functional and visible
- [ ] Create implementation summary

**Timing**: 15 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- Document compiles without errors
- No colors visible except blue hyperlinks
- Professional AMS-style appearance achieved

## Testing & Validation

- [ ] `typst compile BimodalReference.typ` succeeds without errors
- [ ] Visual inspection confirms no colored fills except URLblue links
- [ ] All three diagrams retain sufficient contrast for readability
- [ ] Document appearance matches professional mathematics journal style

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (after completion)
- Modified Typst files (in place)

## Rollback/Contingency

If grayscale conversion results in insufficient visual distinction:
1. Revert individual file changes via `git checkout -- <file>`
2. Consider adding subtle black borders to grayscale boxes
3. Alternative: use pattern fills instead of solid grayscale

Git provides full rollback capability for all changes.
