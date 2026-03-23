# Research Report: Typst Documentation Structure for Strict vs Reflexive Semantics

**Task**: 32 - Document Strict vs Reflexive Semantics
**Date**: 2026-03-22
**Session**: sess_1774168874_bcb521
**Agent**: typst-research-agent

---

## Executive Summary

This report analyzes the BimodalReference.typ documentation structure to determine optimal placement and formatting for documenting the strict vs reflexive semantics design choice. The recommended approach is a **new subsection in 06-notes.typ** titled "Design Choices", which aligns with the chapter's existing purpose of documenting implementation decisions and discrepancies.

---

## 1. Recommended Placement

### Primary Recommendation: Section in 06-notes.typ

**Location**: New subsection `== Design Choices` after `== Discrepancy Notes` (line 34) or before `=== Terminology` (line 39)

**Justification**:

1. **Thematic alignment**: Chapter 6 ("Notes") already documents:
   - Implementation status
   - Discrepancies between paper and implementation
   - Axiom naming conventions
   - Completeness status details

2. **Precedent**: The existing structure uses `== Discrepancy Notes` for similar meta-documentation about implementation choices vs theoretical alternatives.

3. **Non-intrusive**: Does not disrupt the formal definition flow in 02-semantics.typ, which should remain focused on the *chosen* semantics without debating alternatives.

4. **Cross-reference friendly**: Can reference the truth conditions in 02-semantics.typ (lines 85-88) without duplicating them.

### Alternative Options (Not Recommended)

| Option | Location | Why Not Recommended |
|--------|----------|---------------------|
| Subsection in 02-semantics.typ | After "Truth Conditions" | Disrupts formal presentation flow; mixes meta-discussion with definitions |
| New chapter 07-design-choices.typ | Standalone | Too much overhead for a single topic; suggests multiple design choices worth a chapter |
| Remark box after Definition (Truth) | In 02-semantics.typ | Too localized; misses broader context (frame definability, T-axiom, history) |

---

## 2. Proposed Content Structure

### Section Outline

```
== Design Choices

=== Strict vs Reflexive Temporal Semantics

[Opening paragraph: frame the choice]

#definition("Reflexive Temporal Semantics")[...]

#definition("Strict Temporal Semantics")[...]

[Comparison table]

#remark("Historical Context")[...]

#remark("Frame Definability")[...]

#remark("Rationale for TM")[...]
```

### Recommended Content Elements

#### A. Opening Framing (2-3 paragraphs)

Explain that temporal operators G and H can be interpreted with either reflexive (>=) or strict (<) quantification. Note that this choice has significant consequences for axiom validity, frame definability, and proof complexity.

#### B. Two Definition Boxes

**Definition (Reflexive Temporal Semantics)**:
```typst
#definition("Reflexive Temporal Semantics")[
  Under *reflexive semantics*, the temporal operators include the present moment:
  $
    cal(M), tau, x tack.r.double G phi.alt &#Iff
      cal(M), tau, y tack.r.double phi.alt "for all" y : D "where" x lt.eq y \
    cal(M), tau, x tack.r.double H phi.alt &#Iff
      cal(M), tau, y tack.r.double phi.alt "for all" y : D "where" y lt.eq x
  $
  The T-axioms $G phi.alt arrow.r phi.alt$ and $H phi.alt arrow.r phi.alt$ are definitionally valid.
]
```

**Definition (Strict Temporal Semantics)** - mark as current:
```typst
#definition("Strict Temporal Semantics (Current)")[
  Under *strict semantics*, the temporal operators exclude the present moment:
  $
    cal(M), tau, x tack.r.double G phi.alt &#Iff
      cal(M), tau, y tack.r.double phi.alt "for all" y : D "where" x < y \
    cal(M), tau, x tack.r.double H phi.alt &#Iff
      cal(M), tau, y tack.r.double phi.alt "for all" y : D "where" y < x
  $
  The T-axioms are *invalid*: $G phi.alt arrow.r phi.alt$ fails because no $y > x$ equals $x$.
]
```

#### C. Comparison Table

```typst
#figure(
  table(
    columns: 3,
    stroke: none,
    table.hline(),
    table.header(
      [*Property*], [*Reflexive*], [*Strict*],
    ),
    table.hline(),
    [Truth condition], [$y gt.eq x$], [$y > x$],
    [T-axiom ($G phi.alt arrow.r phi.alt$)], [Valid], [Invalid],
    [Seriality ($G phi.alt arrow.r F phi.alt$)], [Trivial], [Requires NoMaxOrder],
    [Density ($G G phi.alt arrow.r G phi.alt$)], [Trivial], [Requires DenselyOrdered],
    [Frame definability], [Limited], [Rich],
    [Canonical model irreflexivity], [N/A (reflexive)], [Requires proof/axiom],
    table.hline(),
  ),
  caption: [Comparison of reflexive and strict temporal semantics.],
)
```

#### D. Remark Boxes

**Remark (Historical Context)**:
- Prior (1957-1968): strict semantics, established frame correspondence theory
- CTL/CTL*: reflexive semantics, model checking applications
- S4.3.1: reflexive, complete for linear orders

**Remark (Frame Definability)**:
- Irreflexivity is NOT modally definable (Blackburn, de Rijke, Venema)
- Under strict semantics: density/seriality axioms genuinely characterize frame classes
- Under reflexive semantics: DN, DF, SF, SP become trivially valid on any linear order

**Remark (TM Rationale)**:
- TM uses strict semantics (current implementation)
- Enables distinct frame classes (Base/Dense/Discrete)
- Requires canonicalR_irreflexive_axiom for completeness
- Task 29 investigates switching to reflexive for T-axiom benefits

#### E. Cross-Reference to 02-semantics.typ

```typst
The truth conditions in @sec:truth (Definition: Truth) use strict semantics, with $y < x$ for past and $x < y$ for future quantification.
```

---

## 3. Typst Formatting Recommendations

### Theorem Environments to Use

| Environment | Purpose | Example |
|-------------|---------|---------|
| `#definition` | Formal definitions of reflexive/strict semantics | Both semantic variants |
| `#remark` | Commentary on history, frame definability, rationale | 3 remark boxes |
| `#figure` with `table` | Comparison table | Properties comparison |

### Mathematical Notation

Use existing notation from `bimodal-notation.typ`:
- `$cal(M)$` for model
- `$tau$` for history
- `$tack.r.double$` for satisfaction
- `$phi.alt$` for formula variable
- `$G$`, `$H$`, `$F$`, `$P$` for temporal operators

### Formatting Style

Follow the AMS aesthetic established in `template.typ`:
- No background colors on theorem environments
- Definition boxes with upright body text
- Remark boxes for commentary (upright body)
- Tables with `stroke: none` and `table.hline()` separators

---

## 4. Sample Typst Code

### Complete Section Implementation

```typst
== Design Choices

The implementation of TM logic involves foundational choices that affect the proof theory and metatheoretic properties.
This section documents these choices and their rationale.

=== Strict vs Reflexive Temporal Semantics

The temporal operators $G$ (future) and $H$ (past) can be interpreted with either *strict* or *reflexive* quantification over times.
This choice has significant consequences for axiom validity, frame definability, and completeness proof structure.

#definition("Strict Temporal Semantics (Current)")[
  Under *strict semantics*, temporal quantification excludes the present moment:
  $
    cal(M), tau, x tack.r.double G phi.alt &#Iff
      cal(M), tau, y tack.r.double phi.alt "for all" y : D "where" x < y \
    cal(M), tau, x tack.r.double H phi.alt &#Iff
      cal(M), tau, y tack.r.double phi.alt "for all" y : D "where" y < x
  $
  This matches the truth conditions in @sec:truth.
]

#definition("Reflexive Temporal Semantics")[
  Under *reflexive semantics*, temporal quantification includes the present moment:
  $
    cal(M), tau, x tack.r.double G phi.alt &#Iff
      cal(M), tau, y tack.r.double phi.alt "for all" y : D "where" x lt.eq y \
    cal(M), tau, x tack.r.double H phi.alt &#Iff
      cal(M), tau, y tack.r.double phi.alt "for all" y : D "where" y lt.eq x
  $
  The temporal T-axioms $G phi.alt arrow.r phi.alt$ and $H phi.alt arrow.r phi.alt$ become definitionally valid.
]

#figure(
  table(
    columns: 3,
    stroke: none,
    table.hline(),
    table.header(
      [*Property*], [*Reflexive ($lt.eq$)*], [*Strict ($<$)*],
    ),
    table.hline(),
    [T-axiom: $G phi.alt arrow.r phi.alt$], [Valid], [Invalid],
    [Seriality: $G phi.alt arrow.r F phi.alt$], [Trivially valid], [Requires NoMaxOrder],
    [Density: $G G phi.alt arrow.r G phi.alt$], [Trivially valid], [Requires DenselyOrdered],
    [Discreteness: $("DF" "axiom")$], [Trivially valid], [Requires SuccOrder],
    [Frame class separation], [Collapsed], [Preserved],
    [Canonical irreflexivity], [Not needed], [Requires axiom/proof],
    table.hline(),
  ),
  caption: [Comparison of reflexive and strict temporal semantics.],
)

#remark("Historical Context")[
  Arthur Prior (1957--1968) established tense logic using strict semantics, with F ("it will be the case") and P ("it was the case") quantifying over strictly future and past times.
  This approach enables rich frame correspondence: temporal axioms genuinely characterize frame properties.
  Computer science applications (CTL, LTL model checking) often use reflexive semantics, where "AG" means "at all states including the current one."
]

#remark("Frame Definability")[
  Under strict semantics, temporal axioms characterize frame classes:
  - *Density*: $G G phi.alt arrow.r G phi.alt$ is valid iff the frame is densely ordered.
  - *Seriality*: $G phi.alt arrow.r F phi.alt$ is valid iff the frame has no maximum element.

  Under reflexive semantics, these axioms become trivially valid on any linear order.
  The frame class structure (Base/Dense/Discrete) collapses to a single logic.

  Notably, *irreflexivity is not modally definable* (Blackburn, de Rijke, Venema): no temporal formula characterizes exactly the irreflexive frames.
]

#remark("Rationale for TM")[
  TM currently uses strict semantics to:
  + Preserve three distinct frame classes (Base, Dense, Discrete) with different axiom requirements.
  + Align with Prior's tense logic tradition and frame correspondence theory.
  + Enable the density and seriality axioms to genuinely characterize their target frames.

  The trade-off is that the canonical model construction requires proving (or axiomatizing) irreflexivity of the canonical temporal relation.
  The `canonicalR_irreflexive_axiom` in the current implementation reflects this requirement.
]
```

---

## 5. Integration Notes

### Required Modifications

1. **06-notes.typ**: Add the new `== Design Choices` section (approximately 80-100 lines)

2. **02-semantics.typ**: Add a label for cross-reference
   ```typst
   == Truth Conditions <sec:truth>
   ```

3. **04-metalogic.typ**: Update the footnote at line 154 to reference the new design choices section:
   ```typst
   #footnote[The T-axiom ($G phi.alt arrow.r phi.alt$) is _not_ valid in TM logic because G/H are strict operators. See @sec:design-choices for details.]
   ```

### No New Imports Required

The existing `template.typ` imports (`definition`, `theorem`, `lemma`, `axiom`, `remark`, `proof`) provide all needed environments.

---

## 6. Summary

| Aspect | Recommendation |
|--------|----------------|
| **Placement** | New `== Design Choices` section in `06-notes.typ` |
| **Structure** | Opening + 2 definitions + comparison table + 3 remarks |
| **Environments** | `#definition` for semantics variants, `#remark` for commentary, `#figure` for table |
| **Cross-references** | Link to 02-semantics.typ truth conditions, update 04-metalogic.typ footnote |
| **Length** | ~80-100 lines of Typst code |

---

## References

### Files Analyzed

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/BimodalReference.typ`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/chapters/02-semantics.typ`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/chapters/06-notes.typ`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/template.typ`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/notation/bimodal-notation.typ`

### Prior Research

- `/home/benjamin/Projects/ProofChecker/specs/029_switch_to_reflexive_gh_semantics/reports/05_team-research.md`
- `/home/benjamin/Projects/ProofChecker/specs/029_switch_to_reflexive_gh_semantics/reports/06_theoretical-analysis.md`
