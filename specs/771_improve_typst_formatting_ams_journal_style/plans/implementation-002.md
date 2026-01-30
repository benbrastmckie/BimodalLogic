# Implementation Plan: Task #771 (Revision 2)

- **Task**: 771 - Improve Typst formatting to AMS journal style
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: medium
- **Dependencies**: None
- **Research Inputs**: specs/771_improve_typst_formatting_ams_journal_style/reports/research-001.md, additional web research on AMS conventions
- **Artifacts**: plans/implementation-002.md (this file), supersedes implementation-001.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Revision Summary

**Reason for revision**: User feedback indicates the original plan misidentified the scope. The problem is not just colors in diagrams—the entire theorem environment approach needs to change. The `thmbox` package provides "modern textbook-style" boxed environments. Professional math journals (AMS, Annals of Mathematics, Acta Mathematica) use **plain unboxed environments** with typography-only styling.

**Key insight**: Setting `fill: none` and `stroke: none` on thmbox may not fully remove its visual styling. The correct solution is to migrate to `ctheorems` package using `thmplain` function, which is specifically designed for AMS-style plain environments.

**Superseded content**: Implementation-001.md focused only on diagram color conversion. This revision adds theorem environment migration as the primary change.

## Overview

This revised plan addresses two styling issues:
1. **Theorem Environments**: Migrate from `thmbox` to `ctheorems` with `thmplain` for unboxed AMS-style theorems
2. **Diagram Colors**: Convert all colored fills to grayscale (preserved from original plan)

### AMS Typography Conventions

Based on [amsthm documentation](https://texdoc.org/serve/amsthm/0) and [AMS Style Guide](https://www.ams.org/publications/authors/AMS-StyleGuide-online.pdf):

| Environment | Label Style | Body Style | Visual Decoration |
|-------------|-------------|------------|-------------------|
| Theorem, Lemma | **Bold** | *Italic* | None (spacing only) |
| Definition | **Bold** | Upright | None (spacing only) |
| Remark, Note | *Italic* | Upright | None (spacing only) |
| Proof | *Italic* "Proof." | Upright | QED symbol at end |

### Package References

- [ctheorems](https://typst.app/universe/package/ctheorems/): Provides `thmplain` for AMS-style environments
- [unequivocal-ams](https://typst.app/universe/package/unequivocal-ams): Reference AMS template for Typst
- [typst-ams-fullpage-template](https://github.com/gdahia/typst-ams-fullpage-template): Example of plain theorem styling

## Goals & Non-Goals

**Goals**:
- Migrate theorem environments to `ctheorems` with `thmplain`
- Apply AMS typography: bold labels, italic theorem bodies, upright definition bodies
- Remove ALL visual decoration from theorem environments (no boxes, fills, strokes, shadows)
- Convert diagram colors to grayscale
- Preserve URLblue for hyperlinks only
- Match appearance of professional math journals

**Non-Goals**:
- Changing theorem numbering schemes
- Modifying mathematical content
- Creating custom fonts or spacing systems
- Modifying tables (already booktabs-style)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ctheorems API incompatible with chapter usage | Medium | Medium | Test each chapter after template change |
| thmplain lacks italic body support | Medium | Low | Use bodyfmt parameter; fall back to custom fmt if needed |
| Counter/numbering breaks | Low | Low | Configure base parameter to link counters |
| Proof environment styling differs | Low | Low | ctheorems includes proof environment by default |

## Implementation Phases

### Phase 1: Migrate Template to ctheorems [NOT STARTED]

**Goal**: Replace thmbox package with ctheorems using AMS-style plain environments

**Estimated effort**: 60 minutes

**Objectives**:
1. Replace thmbox import with ctheorems
2. Define theorem environments using `thmplain` with AMS styling
3. Configure proper typography (italic bodies for theorems, upright for definitions)
4. Test that exports work for chapters

**Tasks**:
- [ ] Replace import line:
  ```typst
  // OLD:
  #import "@preview/thmbox:0.3.0" as thmbox

  // NEW:
  #import "@preview/ctheorems:1.1.3": *
  ```
- [ ] Add show rule for thmrules:
  ```typst
  // Export show rule for chapters to apply
  #let apply-thmrules = doc => {
    show: thmrules.with(qed-symbol: $square$)
    doc
  }
  ```
- [ ] Define AMS-style plain environments:
  ```typst
  // AMS "plain" style: bold label, italic body
  #let theorem = thmplain(
    "theorem",
    "Theorem",
    titlefmt: strong,
    bodyfmt: body => emph(body),
  )

  #let lemma = thmplain(
    "lemma",
    "Lemma",
    base: "theorem",
    titlefmt: strong,
    bodyfmt: body => emph(body),
  )

  // AMS "definition" style: bold label, upright body
  #let definition = thmplain(
    "definition",
    "Definition",
    titlefmt: strong,
  )

  // Axiom follows theorem style
  #let axiom = thmplain(
    "axiom",
    "Axiom",
    titlefmt: strong,
    bodyfmt: body => emph(body),
  )

  // AMS "remark" style: italic label, upright body, unnumbered
  #let remark = thmplain(
    "remark",
    "Remark",
    titlefmt: emph,
    numbering: none,
  )

  // Proof is provided by ctheorems
  // Re-export for convenience
  #let proof = thmproof("proof", "Proof")
  ```
- [ ] Remove all thmbox-specific code:
  - Remove `thmbox-show` initialization
  - Remove `.with()` styling overrides
  - Remove thmbox re-exports
- [ ] Keep URLblue color definition for hyperlinks
- [ ] Update export list at end of template

**Files to modify**:
- `Theories/Bimodal/typst/template.typ`

**Verification**:
- Template file parses without errors
- All expected symbols exported: theorem, lemma, definition, axiom, remark, proof, URLblue

---

### Phase 2: Update Chapter Show Rules [NOT STARTED]

**Goal**: Apply thmrules show rule in all chapter files

**Estimated effort**: 30 minutes

**Objectives**:
1. Add thmrules show rule to each chapter
2. Remove any chapter-specific thmbox overrides
3. Verify each chapter compiles

**Tasks**:
- [ ] For each chapter file, add after imports:
  ```typst
  #show: thmrules.with(qed-symbol: $square$)
  ```
- [ ] Check and remove any thmbox-specific `#show` rules
- [ ] Update these files:
  - [ ] `00-introduction.typ`
  - [ ] `01-syntax.typ`
  - [ ] `02-semantics.typ`
  - [ ] `03-proof-theory.typ`
  - [ ] `04-metalogic.typ`
- [ ] Compile each chapter individually

**Files to modify**:
- `Theories/Bimodal/typst/chapters/*.typ` - All chapter files

**Verification**:
- Each chapter compiles without errors
- `typst compile Theories/Bimodal/typst/chapters/04-metalogic.typ --root=Theories/Bimodal/typst /tmp/test.pdf` succeeds

---

### Phase 3: Convert Introduction Diagram to Grayscale [NOT STARTED]

**Goal**: Remove colors from World History diagram in 00-introduction.typ

**Estimated effort**: 20 minutes

**Tasks**:
- [ ] Change `blue.transparentize(85%)` → `gray.lighten(90%)`
- [ ] Change `orange.transparentize(85%)` → `gray.lighten(85%)`
- [ ] Change `blue.darken(40%)` (worldline) → `black`
- [ ] Keep gray dotted lines (already appropriate)
- [ ] Compile and verify visual clarity

**Files to modify**:
- `Theories/Bimodal/typst/chapters/00-introduction.typ` - CeTZ diagram

**Verification**:
- Diagram renders in grayscale only
- Light cones distinguishable
- Worldline clearly visible

---

### Phase 4: Convert Metalogic Diagrams to Grayscale [NOT STARTED]

**Goal**: Remove colors from both CeTZ diagrams in 04-metalogic.typ

**Estimated effort**: 30 minutes

**Tasks**:
- [ ] Theorem Dependency Diagram (lines ~197-243):
  - [ ] `blue.lighten(90%)` → `gray.lighten(92%)`
  - [ ] `green.lighten(80%)` / `green.lighten(85%)` → `gray.lighten(80%)`
  - [ ] `yellow.lighten(80%)` → `gray.lighten(88%)`
  - [ ] `orange.lighten(85%)` → `gray.lighten(75%)`
- [ ] File Organization Diagram (lines ~423-471):
  - [ ] Apply same grayscale mapping as above
  - [ ] `purple.lighten(90%)` → `gray.lighten(85%)`
- [ ] Verify visual distinction maintained between layers

**Files to modify**:
- `Theories/Bimodal/typst/chapters/04-metalogic.typ`

**Verification**:
- Both diagrams render without colors
- Different layers visually distinguishable
- Arrows and labels remain clear

---

### Phase 5: Final Verification [NOT STARTED]

**Goal**: Compile full document and verify AMS-style appearance

**Estimated effort**: 20 minutes

**Tasks**:
- [ ] Compile full BimodalReference.typ
- [ ] Visual inspection checklist:
  - [ ] Theorems: **Bold** label, *italic* body, no box/background
  - [ ] Definitions: **Bold** label, upright body, no box/background
  - [ ] Remarks: *Italic* label, upright body, no box/background
  - [ ] Proofs: *Italic* "Proof", QED symbol at end
  - [ ] Diagrams: Grayscale only
  - [ ] Tables: Horizontal rules only (booktabs style)
  - [ ] Hyperlinks: URLblue color preserved
- [ ] Compare to reference journals:
  - [ ] [Annals of Mathematics](https://annals.math.princeton.edu/)
  - [ ] Journal of the AMS
- [ ] Create implementation summary

**Files to modify**:
- None (verification only)

**Verification**:
- `typst compile Theories/Bimodal/typst/BimodalReference.typ` succeeds
- PDF matches professional math journal appearance
- No colored elements except URLblue links

## Testing & Validation

- [ ] `typst compile BimodalReference.typ` succeeds without errors
- [ ] Theorem bodies are italic, not boxed
- [ ] Definition bodies are upright, not boxed
- [ ] Proof environments end with QED symbol
- [ ] All diagrams render in grayscale
- [ ] No visual elements except typography and spacing
- [ ] URLblue hyperlinks preserved and functional

## Artifacts & Outputs

- `specs/771_improve_typst_formatting_ams_journal_style/plans/implementation-002.md` (this file)
- `specs/771_improve_typst_formatting_ams_journal_style/summaries/implementation-summary-YYYYMMDD.md`
- Modified files:
  - `Theories/Bimodal/typst/template.typ`
  - `Theories/Bimodal/typst/chapters/*.typ`

## Rollback/Contingency

If ctheorems migration fails:
1. `git checkout -- Theories/Bimodal/typst/` to revert all changes
2. Consider alternative packages:
   - `great-theorems` with mathblock configured for no styling
   - `lemmify` with custom thm-styling
   - Manual implementation without package

If grayscale lacks sufficient contrast:
1. Use pattern fills (dots, hashes) instead of solid gray
2. Add subtle black borders to distinguish layers
3. Use varying line styles (solid, dashed, dotted)

## Comparison: Before vs After

| Element | Before (thmbox) | After (ctheorems/thmplain) |
|---------|-----------------|---------------------------|
| Theorem visual | May have box/fill | Typography only |
| Theorem body | Package default | Italic |
| Definition body | Package default | Upright |
| Remark label | Package default | Italic |
| Proof | Package default | Italic "Proof" + QED |
| Diagrams | Colored fills | Grayscale fills |
| Overall feel | Modern textbook | Professional journal |

## Reference Sources

- [AMS Style Guide for Journals](https://www.ams.org/publications/authors/AMS-StyleGuide-online.pdf)
- [amsthm Package Documentation](https://texdoc.org/serve/amsthm/0)
- [ctheorems Package](https://typst.app/universe/package/ctheorems/)
- [Annals of Mathematics Submission Guidelines](https://annals.math.princeton.edu/submission-guidelines)
- [aomart LaTeX Class](https://ctan.math.illinois.edu/macros/latex/contrib/aomart/aomart.pdf)
