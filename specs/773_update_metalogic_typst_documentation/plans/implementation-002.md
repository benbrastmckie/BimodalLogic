# Implementation Plan: Task #773 (Revision 2)

- **Task**: 773 - Update metalogic Typst documentation to reflect recent codebase changes
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Priority**: medium
- **Dependencies**: Task 772 (in progress - refactoring sorried proofs to Boneyard)
- **Research Inputs**: specs/773_update_metalogic_typst_documentation/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file), supersedes implementation-001.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Revision Summary

**Reason for revision**: User feedback indicates the current textbook-style formatting (boxed/shaded theorem environments) needs to be upgraded to professional math journal style. The problem is not just colors—it's the entire approach to theorem environments.

**Key change**: Migrate from `thmbox` package (modern boxed environments) to `ctheorems` package (AMS-style plain environments). This affects the template.typ and propagates to all chapters.

**Preserved content**: Phases 1-6 from implementation-001.md were completed and their content updates remain valid. This revision replaces Phase 7-8 with new styling phases.

## Overview

This revised plan has two components:
1. **Style Migration**: Convert the Typst project from textbook-style (thmbox) to professional math journal style (ctheorems with thmplain)
2. **Content Completion**: Finish the implementation status updates from the original plan

The AMS convention for theorem environments:
- **Theorems/Lemmas**: Italic body text, bold label, no box/shading
- **Definitions**: Upright body text, bold label, defined terms in italics
- **Remarks**: Upright body text, italic label
- **Visual separation**: Vertical spacing only—no boxes, backgrounds, or borders

### Research References

- [AMS Style Guide](https://www.ams.org/publications/authors/AMS-StyleGuide-online.pdf): Official AMS formatting standards
- [amsthm Package Documentation](https://texdoc.org/serve/amsthm/0): LaTeX amsthm conventions (plain/definition/remark styles)
- [ctheorems Package](https://typst.app/universe/package/ctheorems/): Typst package with thmplain for AMS-style environments
- [unequivocal-ams Template](https://typst.app/universe/package/unequivocal-ams): Reference AMS template for Typst

## Goals & Non-Goals

**Goals**:
- Migrate to `ctheorems` package with `thmplain` for plain theorem environments
- Apply AMS typography: italic theorem bodies, upright definition bodies
- Remove all colored backgrounds, borders, and visual decoration
- Preserve URLblue for hyperlinks only (digital document usability)
- Complete the implementation status tables from original plan
- Ensure document compiles and matches professional math journal appearance

**Non-Goals**:
- Adding patterns or hatching to diagrams (grayscale is sufficient)
- Modifying mathematical content (Phase 1-6 content updates are complete)
- Creating custom theorem numbering schemes (use default chapter.number)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ctheorems API differs from thmbox | Medium | Medium | Study ctheorems docs; use thmplain which matches amsthm |
| Chapter imports break after template change | High | Low | Update all chapter imports before compiling |
| Visual distinction lost without boxes | Low | Low | Use italic/upright typography per AMS convention |
| Counter/numbering changes | Medium | Low | Test numbering behavior; configure base/parent as needed |

## Implementation Phases

### Phase 7: Migrate Template to ctheorems [NOT STARTED]

**Goal**: Replace thmbox package with ctheorems using AMS-style plain environments

**Estimated effort**: 90 minutes

**Objectives**:
1. Replace thmbox import with ctheorems
2. Define theorem environments using `thmplain` (no boxes)
3. Configure AMS-style typography (italic theorems, upright definitions)
4. Remove all colored styling except URLblue for links

**Tasks**:
- [ ] Replace `#import "@preview/thmbox:0.3.0" as thmbox` with `#import "@preview/ctheorems:1.1.3": *`
- [ ] Add `#show: thmrules.with(qed-symbol: $square$)` after import
- [ ] Define plain environments:
  ```typst
  // AMS plain style: bold label, italic body
  #let theorem = thmplain(
    "theorem",
    "Theorem",
    titlefmt: strong,
    bodyfmt: emph,
  )
  #let lemma = thmplain(
    "lemma",
    "Lemma",
    base: "theorem",
    titlefmt: strong,
    bodyfmt: emph,
  )

  // AMS definition style: bold label, upright body
  #let definition = thmplain(
    "definition",
    "Definition",
    titlefmt: strong,
  )

  // AMS remark style: italic label, upright body
  #let remark = thmplain(
    "remark",
    "Remark",
    titlefmt: it => emph(it),
    numbering: none,
  )

  // Axiom like theorem
  #let axiom = thmplain(
    "axiom",
    "Axiom",
    titlefmt: strong,
    bodyfmt: emph,
  )
  ```
- [ ] Keep URLblue definition for hyperlinks
- [ ] Remove all thmbox-specific styling code and show rules
- [ ] Verify export list matches what chapters expect

**Files to modify**:
- `Theories/Bimodal/typst/template.typ` - Complete rewrite of theorem environments

**Verification**:
- Template compiles without errors
- All expected exports available (theorem, lemma, definition, remark, axiom, proof)

---

### Phase 8: Update Chapter Imports [NOT STARTED]

**Goal**: Update all chapter files to work with new template structure

**Estimated effort**: 30 minutes

**Objectives**:
1. Update import statements in all chapters
2. Remove any chapter-specific thmbox overrides
3. Verify each chapter compiles independently

**Tasks**:
- [ ] Update `00-introduction.typ` imports and theorem usage
- [ ] Update `01-syntax.typ` imports and theorem usage
- [ ] Update `02-semantics.typ` imports and theorem usage
- [ ] Update `03-proof-theory.typ` imports and theorem usage
- [ ] Update `04-metalogic.typ` imports and theorem usage
- [ ] Update `05-applications.typ` imports and theorem usage (if exists)
- [ ] Check for any `#show` rules that override theorem styling
- [ ] Compile each chapter individually to verify

**Files to modify**:
- `Theories/Bimodal/typst/chapters/*.typ` - All chapter files

**Verification**:
- Each chapter compiles without errors
- Theorem environments render with AMS styling

---

### Phase 9: Convert Diagrams to Grayscale [NOT STARTED]

**Goal**: Remove all colors from CeTZ diagrams except URLblue hyperlinks

**Estimated effort**: 45 minutes

**Objectives**:
1. Convert all colored fills to grayscale
2. Maintain visual distinction between layers using varying gray levels
3. Preserve black for text and strong emphasis elements

**Tasks**:
- [ ] 04-metalogic.typ - Theorem Dependency Diagram (lines 197-243):
  - [ ] `blue.lighten(90%)` → `gray.lighten(92%)`
  - [ ] `green.lighten(80%)` → `gray.lighten(80%)`
  - [ ] `yellow.lighten(80%)` → `gray.lighten(88%)`
  - [ ] `orange.lighten(85%)` → `gray.lighten(75%)`
- [ ] 04-metalogic.typ - File Organization Diagram (lines 423-471):
  - [ ] Apply same grayscale mapping
  - [ ] `purple.lighten(90%)` → `gray.lighten(85%)`
- [ ] 00-introduction.typ - World History Diagram (if present):
  - [ ] Convert light cone fills to grayscale
  - [ ] Change blue worldline to black
- [ ] Verify visual distinction between layers maintained

**Files to modify**:
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - Two CeTZ diagrams
- `Theories/Bimodal/typst/chapters/00-introduction.typ` - World History diagram

**Verification**:
- All diagrams render in grayscale
- Different layers remain visually distinguishable
- No colored elements except URLblue links

---

### Phase 10: Complete Implementation Status Section [NOT STARTED]

**Goal**: Update sorry status and implementation tables with current codebase state

**Estimated effort**: 45 minutes

**Objectives**:
1. Update sorry count table (20 sorries, all deprecated)
2. Update metalogic implementation status table
3. Ensure `semantic_weak_completeness` is clearly marked as sorry-free primary

**Tasks**:
- [ ] Verify sorry counts match Task 769 audit (20 total)
- [ ] Update File/Count/Cause table formatting to use AMS-style
- [ ] Update Metalogic Implementation table formatting
- [ ] Add emphasis to `semantic_weak_completeness` as THE completeness theorem
- [ ] Verify theorem names match current Lean codebase

**Files to modify**:
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - Lines 484-574

**Verification**:
- Sorry count matches audit (20)
- All sorries marked as deprecated/architectural
- `semantic_weak_completeness` clearly identified as primary

---

### Phase 11: Table Styling Update [NOT STARTED]

**Goal**: Convert tables to professional AMS-style with horizontal rules only

**Estimated effort**: 30 minutes

**Objectives**:
1. Use horizontal rules only (booktabs-style: toprule, midrule, bottomrule)
2. Remove any colored table elements
3. Consistent column alignment

**Tasks**:
- [ ] Verify all tables use `stroke: none` with `table.hline()` rules
- [ ] Check no colored fills in table cells
- [ ] Verify consistent text alignment (left for text, center for status/numbers)
- [ ] Check figure captions are beneath tables (AMS style)

**Files to modify**:
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - All tables

**Verification**:
- Tables match booktabs/AMS style
- No vertical rules
- Clean horizontal rules only

---

### Phase 12: Final Compilation and Review [NOT STARTED]

**Goal**: Full document compilation and visual comparison to AMS standards

**Estimated effort**: 30 minutes

**Objectives**:
1. Compile complete BimodalReference.typ
2. Visual inspection against AMS journal examples
3. Verify no regressions from Phase 1-6 content updates

**Tasks**:
- [ ] Run `typst compile BimodalReference.typ`
- [ ] Review PDF output for professional appearance
- [ ] Check theorem environments have italic body text
- [ ] Check definitions have upright body text
- [ ] Verify no colored elements except URLblue links
- [ ] Compare visual style to [Annals of Mathematics](https://annals.math.princeton.edu/) articles
- [ ] Verify all content from Phases 1-6 is preserved
- [ ] Create implementation summary

**Files to modify**:
- None (verification only)

**Verification**:
- Document compiles without errors or warnings
- Professional AMS-style appearance achieved
- All content accurate and complete

## Testing & Validation

- [ ] `typst compile BimodalReference.typ` succeeds without errors
- [ ] Theorem environments: bold label, italic body, no box/background
- [ ] Definition environments: bold label, upright body, no box/background
- [ ] All diagrams in grayscale only
- [ ] Tables use horizontal rules only (no vertical lines or cell fills)
- [ ] Only URLblue color visible (for hyperlinks)
- [ ] Visual appearance matches professional math journal standards

## Artifacts & Outputs

- `Theories/Bimodal/typst/template.typ` - Migrated to ctheorems
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - Updated styling and content
- `Theories/Bimodal/typst/chapters/*.typ` - Updated imports
- `specs/773_update_metalogic_typst_documentation/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If ctheorems migration causes issues:
1. Revert template.typ via `git checkout -- Theories/Bimodal/typst/template.typ`
2. Revert all chapter changes via `git checkout -- Theories/Bimodal/typst/chapters/`
3. Consider alternative: keep thmbox but with more aggressive styling overrides
4. Last resort: create custom theorem environments without any package

Git provides full rollback capability for all changes.

## Comparison: Before vs After

| Element | Before (thmbox) | After (ctheorems/thmplain) |
|---------|-----------------|---------------------------|
| Theorem box | Possibly shaded/bordered | No box, spacing only |
| Theorem body | Depends on thmbox default | Italic (AMS plain style) |
| Definition body | Depends on thmbox default | Upright (AMS definition style) |
| Remark style | Depends on thmbox default | Italic label, upright body |
| Visual separation | Box/fill/stroke | Vertical space only |
| Diagrams | Colored fills | Grayscale fills |
| Tables | May have fills | Horizontal rules only |

This revision prioritizes professional math journal appearance over "modern" textbook styling.
