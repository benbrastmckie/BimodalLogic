# Research Report: Task #714

**Task**: 714 - Refine Typst styling for journal aesthetic
**Started**: 2026-01-28T12:00:00Z
**Completed**: 2026-01-28T12:45:00Z
**Effort**: Low
**Priority**: High
**Dependencies**: Task 709 (completed)
**Sources/Inputs**: Codebase analysis, Task 709 research/implementation, AMS style guides, Springer LNM conventions, Typst documentation, Pascal Michaillat's minimalist template principles
**Artifacts**: specs/714_refine_typst_styling_for_journal_aesthetic/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- Current implementation uses `thmbox` with colored background fills that create a "textbook" appearance; professional mathematics journals use no background colors and rely solely on typographic distinction (italic vs. upright text, bold headers)
- The AMS amsthm convention defines three theorem styles: **plain** (italic body), **definition** (upright body), **remark** (upright, no extra spacing) - all without decorative backgrounds
- Recommended approach: Replace colored `thmbox` environments with plain styling using only typographic emphasis; remove colored fills; consider switching to a simpler theorem package or custom show rules that match traditional journal aesthetics

## Context & Scope

Task 709 implemented professional Typst styling for the Bimodal TM Logic documentation. While the implementation improved typography (LaTeX-like margins, New Computer Modern font, proper paragraph indentation), the theorem environments use `thmbox` with colored background fills:

- **Theorem/Lemma**: `rgb("#f8f8ff")` (light blue-gray)
- **Definition**: `rgb("#f0fff0")` (light mint green)
- **Axiom**: `rgb("#fff8f0")` (light orange)
- **Remark**: `rgb("#f8f8f8")` (light gray)

These subtle colors, while "professional," still evoke a modern textbook rather than the austere aesthetic of traditional mathematics journals like:
- Annals of Mathematics
- Journal of the American Mathematical Society (JAMS)
- Acta Mathematica
- Springer Lecture Notes in Mathematics (LNM)

The goal is to shift from colorful textbook styling to the traditional, austere aesthetic of mathematics research journals.

## Findings

### Current Implementation Analysis

From `template.typ`:
```typst
#let theorem-style = (fill: rgb("#f8f8ff"))   // Light blue-gray
#let definition-style = (fill: rgb("#f0fff0")) // Light mint
#let axiom-style = (fill: rgb("#fff8f0"))      // Light orange
#let remark-style = (fill: rgb("#f8f8f8"))     // Light gray

#let definition = thmbox.definition.with(..definition-style)
#let theorem = thmbox.theorem.with(..theorem-style)
#let lemma = thmbox.lemma.with(..theorem-style)
#let axiom = thmbox.axiom.with(..axiom-style)
#let remark = thmbox.remark.with(..remark-style)
```

This creates visually distinct boxes - appropriate for educational materials, but not matching journal conventions.

### AMS/amsthm Theorem Style Conventions

The AMS standard (used by virtually all mathematics journals) defines three theorem styles:

| Style | Body Font | Extra Spacing | Usage |
|-------|-----------|---------------|-------|
| **plain** | Italic | Yes | Theorems, lemmas, propositions, corollaries, conjectures |
| **definition** | Upright (roman) | Yes | Definitions, conditions, problems, examples |
| **remark** | Upright (roman) | No | Remarks, notes, annotations, cases |

Key characteristics:
- **No background colors whatsoever** - text color only (black)
- Theorem header in **bold** (e.g., "Theorem 2.1.")
- For **plain** style: body text in *italic*
- For **definition** style: body text in upright, defined term in *italic*
- For **remark** style: header in *italic*, body upright
- Horizontal spacing and numbering only for visual separation

### Springer LNM Conventions

The Springer Lecture Notes class (`llncs`) uses:
- Run-in heading in **bold**, following text in *italics* (for theorems)
- Definitions, lemmas, propositions use same pattern
- Proofs have initial word in *italics*, body in normal font
- **No colored backgrounds or borders**

### Pascal Michaillat's Minimalist Principle

From the minimalist LaTeX template design principles:
> "No colors are used in the text (only black) to reduce distraction and so the paper prints well; colors are reserved for figures."

This captures the journal aesthetic perfectly - colors distract from mathematical content and don't reproduce well in print.

### Typst Implementation Options

#### Option 1: Remove fills from thmbox (Minimal Change)

```typst
#let theorem-style = (fill: none)  // Or fill: white
#let definition-style = (fill: none)
#let axiom-style = (fill: none)
#let remark-style = (fill: none)
```

**Pros**: Minimal code change, preserves thmbox structure
**Cons**: May still have borders or other decorative elements from thmbox

#### Option 2: Switch to ctheorems with thmplain

The `ctheorems` package provides `thmplain` for undecorated environments:

```typst
#import "@preview/ctheorems:1.1.3": *

#let theorem = thmplain("theorem", "Theorem", titlefmt: strong)
#let definition = thmplain("definition", "Definition", base: "theorem", titlefmt: strong)
#let lemma = thmplain("lemma", "Lemma", base: "theorem", titlefmt: strong)
```

**Pros**: Purpose-built for plain academic styling
**Cons**: Package change, slightly different API

#### Option 3: Custom show rules (Full Control)

Define theorem environments using native Typst:

```typst
#let theorem(title: none, body) = {
  block(above: 1.5em, below: 1.5em)[
    #strong[Theorem#if title != none [ (#title)].]
    #emph(body)
  ]
}

#let definition(title: none, body) = {
  block(above: 1.5em, below: 1.5em)[
    #strong[Definition#if title != none [ (#title)].]
    #body
  ]
}
```

**Pros**: Complete control, no external dependencies, matches AMS exactly
**Cons**: More code, manual counter management

### Additional Styling Refinements

#### Link Color

Current: `URLblue = rgb(0, 0, 150)` - This is acceptable for journals, as hyperlinks are a modern addition. Consider making it darker or even black for print.

#### Remove Colored Elements

Check all elements that might have color:
- Table cell backgrounds
- Code block backgrounds
- Figure captions
- Any decorative rules or borders

### Typography Verification

The current typography is already journal-appropriate:
- Font: New Computer Modern (matches LaTeX standard)
- Size: 11pt (standard for journals)
- Margins: 1.5in x 1.25in (reasonable for academic)
- Paragraph spacing: 0.55em leading, 1.8em first-line indent

These should be preserved.

## Recommendations

### Phase 1: Remove Background Colors (Essential)

1. In `template.typ`, change all style definitions to use no fill:
   ```typst
   #let theorem-style = (fill: none, stroke: none)
   #let definition-style = (fill: none, stroke: none)
   #let axiom-style = (fill: none, stroke: none)
   #let remark-style = (fill: none, stroke: none)
   ```

2. If `thmbox` still adds visible styling with `fill: none`, consider:
   - Testing `fill: white` or `fill: rgb("#ffffff")`
   - Investigating `stroke` parameter to remove borders
   - Switching to `ctheorems` with `thmplain` if needed

### Phase 2: Verify AMS-Style Typography

Ensure body text matches AMS conventions:
- Theorems, lemmas, corollaries: italic body
- Definitions: upright body, defined term in italic
- Remarks: upright body, potentially italic header

### Phase 3: Review All Colored Elements

1. Consider darkening or removing link color for print compatibility
2. Remove any colored table cell backgrounds
3. Ensure code blocks have minimal or no background styling

### Phase 4: Compile and Verify

1. Compile BimodalReference.pdf
2. Compare against a sample AMS journal article for aesthetic match
3. Test print to verify black-only readability

## Decisions

1. **Package choice**: Attempt to modify existing `thmbox` usage first; only switch to `ctheorems` or custom if `thmbox` cannot produce sufficiently austere output
2. **Link color**: Keep `URLblue` for now (hyperlinks are a modern convention), but document as optional refinement for pure print aesthetic
3. **Approach**: Incremental - remove colors first, then refine typography if needed

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `thmbox` cannot fully remove styling | Medium | Fall back to `ctheorems` with `thmplain` |
| Loss of visual distinction between environment types | Low | AMS convention relies on typography (italic vs. upright), not colors |
| Changes break existing chapter files | Low | Environments exported via template.typ; chapter content unchanged |
| Overly sparse appearance | Low | This is the goal - matches journal standards |

## Appendix

### Search Queries Used

1. "Typst academic journal template austere professional mathematics styling minimal color"
2. "AMS journal LaTeX styling conventions theorem definition formatting professional mathematics"
3. "amsthm theorem style plain definition remark roman italic text no color academic typography"
4. "Typst thmbox theorem styling no background color austere plain style academic"
5. "New Computer Modern font mathematics journal professional typography LaTeX academic"
6. "Typst academic mathematics minimal styling black only no color professional journal"
7. "Springer LNM Lecture Notes Mathematics style formatting austere traditional no color theorem"
8. "AMS Annals Acta Mathematica journal typography traditional black text theorem italic definition upright"

### References

- [AMS amsthm Package Documentation](https://texdoc.org/serve/amsthm/0) - Official theorem style definitions
- [Overleaf: Theorems and Proofs](https://www.overleaf.com/learn/latex/Theorems_and_proofs) - AMS theorem style usage
- [Pascal Michaillat: Minimalist LaTeX Template](https://pascalmichaillat.org/a/) - Minimalist design principles
- [Typst Universe: thmbox](https://typst.app/universe/package/thmbox/) - Current package documentation
- [Typst Universe: ctheorems](https://typst.app/universe/package/ctheorems/) - Alternative with thmplain
- [Springer LNCS Instructions](https://cs.brown.edu/about/system/managed/latex/doc/llncs.pdf) - LNM/LNCS style guide
- [AMS Author Handbook](https://www.ams.org/arc/handbook/handbook-journals.pdf) - Journal formatting standards
- [AMS Style Guide](https://www.ams.org/publications/authors/AMS-StyleGuide-online.pdf) - Typography conventions
- [Annals of Mathematics: aomart class](https://ctan.math.illinois.edu/macros/latex/contrib/aomart/aomart.pdf) - Top journal LaTeX class

## Next Steps

Run `/plan 714` to create implementation plan for refining Typst styling to match journal aesthetic.
