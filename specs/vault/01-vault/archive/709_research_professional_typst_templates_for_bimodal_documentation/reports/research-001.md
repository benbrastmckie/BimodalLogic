# Research Report: Task #709

**Task**: 709 - Research Professional Typst Templates for Bimodal Documentation
**Started**: 2026-01-28T12:00:00Z
**Completed**: 2026-01-28T12:30:00Z
**Effort**: Low-Medium
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase analysis, Typst Universe, Typst Documentation, Web research
**Artifacts**: specs/709_research_professional_typst_templates_for_bimodal_documentation/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- Current Bimodal documentation uses `great-theorems` package with basic styling; several professional alternatives exist
- Key improvements: LaTeX-like page layout, enhanced theorem styling, TOC formatting, link colors, and mathematical notation fixes
- Recommended approach: Combine LaTeX-like settings with `thmbox` or `theorion` for professional theorem environments

## Context & Scope

The Bimodal TM Logic documentation (`Theories/Bimodal/typst/`) uses Typst for typesetting mathematical content. While functional, the current appearance needs enhancement to match the professional LaTeX quality of LogosReference.tex. Specific issues flagged in source comments include:

1. TOC chapter names should be bold (02-semantics.typ:104)
2. Hyperlinks should be light blue (BimodalReference.typ:18)
3. "iff" should appear in italics (02-semantics.typ:80)
4. Subscript/superscript positioning for `approx` symbol (02-semantics.typ:111)
5. Duration label positioning over arrows (02-semantics.typ:17)
6. Abstract header centering with spacing (BimodalReference.typ:93)

## Findings

### Current Implementation Analysis

The existing setup uses:

```typst
#import "@preview/great-theorems:0.1.2": *
#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.1")
#set par(justify: true)
```

Template defines basic theorem environments via `mathblock()` with chapter-relative numbering.

### Professional Typst Packages for Theorem Environments

#### 1. thmbox (Recommended for Professional Look)

**Package**: `@preview/thmbox:0.3.0`

Features:
- Modern, visually distinctive theorem environments with colored borders
- Configurable background fill, stroke color, and rounded corners
- Sectioned counter system with configurable levels
- Page break control via Typst figure rules
- Recommended fonts: New Computer Modern (already in use)

```typst
#import "@preview/thmbox:0.3.0": *
#show: thmbox-init()

// Use predefined environments: theorem, corollary, definition, example, lemma, proposition, proof
```

#### 2. theorion (Most Feature-Rich)

**Package**: `@preview/theorion:0.4.1`

Features:
- Four pre-built themes: Simple, Rainbow, Clouds, Fancy
- Multilingual support (built-in translations)
- Theorem restatement capability
- TOC generation for theorems
- Custom numbering with inheritance from headings

```typst
#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *  // or cosmos.simple, cosmos.rainbow, cosmos.clouds
#show: show-theorion
```

#### 3. clean-math-paper (Template Approach)

**Package**: `@preview/clean-math-paper:0.2.5`

Features:
- Ready-to-use mathematical paper template
- Pre-configured theorem, lemma, corollary, proof environments
- Customizable heading/link colors
- Multi-language support
- Uses great-theorems internally (current package)

### LaTeX-Like Page Configuration

To achieve professional LaTeX appearance, apply these settings:

```typst
// Core LaTeX-like settings
#set page(margin: 1.75in)  // Wide margins like LaTeX
#set par(
  leading: 0.55em,         // Tight line spacing
  spacing: 0.55em,         // Reduced paragraph spacing
  first-line-indent: 1.8em, // Classic first-line indent
  justify: true
)
#set text(font: "New Computer Modern", size: 11pt)
#show raw: set text(font: "New Computer Modern Mono")
#show heading: set block(above: 1.4em, below: 1em)
```

### Hyperlink Styling (Light Blue)

```typst
// Define custom blue color matching LogosReference.tex
#let URLblue = rgb(0, 0, 150)

// Apply to all links
#show link: set text(fill: URLblue)

// Optional: add underline
#show link: underline
```

### Table of Contents Formatting

For bold chapter names with normal subsections:

```typst
// Bold chapter entries (level 1)
#show outline.entry.where(level: 1): it => {
  strong(it)
}

// Add spacing before chapters
#show outline.entry.where(level: 1): set block(above: 1.2em)
```

### Mathematical Notation Fixes

#### "iff" in Italics

Create a dedicated command:

```typst
// In bimodal-notation.typ
#let iff = text(style: "italic", "iff")

// Or in math context
#let iff = $italic("iff")$

// Usage in math:
// $cal(M), tau, x tack.r.double p #iff x in "dom"(tau)$
```

#### Subscript/Superscript Stacking (approx symbol)

For stacked sub/superscripts like $\approx_y^x$:

```typst
// Method 1: Using attach with explicit positions
$attach(approx, t: x, b: y)$

// Method 2: Using limits positioning
$limits(approx)_y^x$

// For right-aligned stacking (LaTeX-like):
$approx_y^x$  // Standard Typst positioning
```

#### Duration Over Arrows

For placing duration labels over transition arrows:

```typst
// Method 1: Using attach
$w attach(arrow.r.double.long, t: x) u$

// Method 2: Using overset/underset pattern
#let overset(base, top) = $attach(#base, t: #top)$
$w #overset($arrow.r.double.long$, $x$) u$
```

### Book Template Option: bookly

**Package**: `@preview/bookly:1.1.2`

For full book formatting:
- Four themes: classic, modern, fancy, orly
- Chapter/part organization
- Proof-box, question-box, custom-box environments
- Title page templates for books and theses
- Front-matter, main-matter, appendix, back-matter structure

```typst
#import "@preview/bookly:1.1.2": *

#show: bookly.with(
  author: "Benjamin Brast-McKie",
  title: "Bimodal Reference Manual",
  theme: "classic",  // or "modern", "fancy"
  fonts: (body: "New Computer Modern"),
)
```

### Abstract Header Styling

```typst
// Centered abstract with spacing
#page(numbering: none)[
  #align(center)[
    #heading(outlined: false, numbering: none)[Abstract]
  ]
  #v(0.5em)  // Space after header

  // Abstract content...
]
```

### Comprehensive Template Improvements

Recommended template.typ modifications:

```typst
// ============================================================================
// Professional Typst Template for Bimodal Documentation
// ============================================================================

#import "@preview/thmbox:0.3.0": *  // Or theorion:0.4.1

// ============================================================================
// Page Layout (LaTeX-like)
// ============================================================================

#let latex-style = (
  margins: 1.75in,
  leading: 0.55em,
  spacing: 0.55em,
  first-line-indent: 1.8em,
)

// ============================================================================
// Colors
// ============================================================================

#let URLblue = rgb(0, 0, 150)

// ============================================================================
// Custom Commands
// ============================================================================

#let iff = text(style: "italic", " iff ")
#let overset(base, top) = $attach(#base, t: #top)$

// ============================================================================
// Show Rules
// ============================================================================

#let setup-document(doc) = {
  set page(margin: latex-style.margins)
  set par(
    leading: latex-style.leading,
    spacing: latex-style.spacing,
    first-line-indent: latex-style.first-line-indent,
    justify: true,
  )
  set text(font: "New Computer Modern", size: 11pt)
  show raw: set text(font: "New Computer Modern Mono")
  show heading: set block(above: 1.4em, below: 1em)
  show link: set text(fill: URLblue)
  show outline.entry.where(level: 1): strong
  show outline.entry.where(level: 1): set block(above: 1.2em)

  doc
}
```

## Recommendations

### Immediate Improvements (Low Effort)

1. **Add link styling**: `#show link: set text(fill: rgb(0, 0, 150))`
2. **Fix TOC bold chapters**: Show rule on `outline.entry.where(level: 1)`
3. **Create `iff` command**: `#let iff = text(style: "italic", " iff ")`
4. **Apply LaTeX-like margins**: `#set page(margin: 1.75in)`

### Medium-Term Improvements

1. **Upgrade theorem package**: Switch from `great-theorems` to `thmbox` or `theorion` for more professional styling
2. **Add paragraph indentation**: Apply `first-line-indent: 1.8em` for traditional book appearance
3. **Fix subscript/superscript stacking**: Use `attach()` or `limits()` functions

### Full Template Overhaul Option

For comprehensive professional appearance, consider adopting `bookly` as the base template, which provides:
- Professional book structure with front/back matter
- Built-in theorem boxes
- Chapter formatting
- Title page templates

## Decisions

1. **Package Selection**: Recommend `thmbox` for theorem styling due to clean modern appearance compatible with New Computer Modern font
2. **Page Layout**: Use LaTeX-like settings (wide margins, tight spacing) to match LogosReference.tex aesthetic
3. **Incremental Approach**: Apply immediate fixes first before full template restructuring

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Package compatibility | Test each package incrementally; `great-theorems` is already working |
| Compilation time increase | Typst is fast; additional packages have minimal impact |
| Breaking existing content | Create template branch for testing before merging |
| Learning curve for new packages | All recommended packages have good documentation |

## Appendix

### Search Queries Used

1. "Typst professional academic book template mathematics theorem proof 2026"
2. "Typst Universe packages academic publishing mathematical notation theorem environments"
3. "Typst LaTeX-like professional typography book formatting margins page layout academic"
4. "Typst table of contents styling chapter formatting professional book toc"
5. "Typst New Computer Modern font configuration mathematical typesetting LaTeX appearance"
6. "Typst hyperlink styling blue color link formatting academic document"
7. "Typst subscript superscript stacking align math notation position"
8. "Typst math italic text upright custom operator definition display"

### References

- [Typst Universe Search](https://typst.app/universe/search/)
- [thmbox Package](https://typst.app/universe/package/thmbox/)
- [theorion Package](https://typst.app/universe/package/theorion/)
- [clean-math-paper Template](https://typst.app/universe/package/clean-math-paper/)
- [bookly Template](https://typst.app/universe/package/bookly/)
- [great-theorems Package](https://typst.app/universe/package/great-theorems/)
- [Typst Page Setup Guide](https://typst.app/docs/guides/page-setup/)
- [Typst Outline Documentation](https://typst.app/docs/reference/model/outline/)
- [Typst Guide for LaTeX Users](https://typst.app/docs/guides/guide-for-latex-users/)
- [Typst Math Attach Function](https://typst.app/docs/reference/math/attach/)
- [Typst Link Function](https://typst.app/docs/reference/model/link/)
