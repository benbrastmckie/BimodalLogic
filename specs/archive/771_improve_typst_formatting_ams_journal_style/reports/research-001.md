# Research Report: Task #771

**Task**: 771 - improve_typst_formatting_ams_journal_style
**Started**: 2026-01-30T12:00:00Z
**Completed**: 2026-01-30T12:15:00Z
**Effort**: Low-Medium
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase exploration (Typst and LaTeX source files)
**Artifacts**: This research report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The Typst project has already undergone partial AMS-style improvements (template.typ uses `fill: none`, `stroke: none` for theorem environments)
- Remaining color usage is concentrated in **diagrams** (04-metalogic.typ, 00-introduction.typ) which use blue, green, orange, yellow, purple fills
- The LaTeX version (BimodalReference.tex) uses pure AMS style with no colored backgrounds in theorem environments
- URLblue for hyperlinks should be preserved (this is consistent with both professional digital documents and the LaTeX version)
- Key improvements needed: Convert colored diagram fills to grayscale or monochrome patterns

## Context & Scope

The task is to improve formatting of BimodalReference.typ to match AMS-style professional mathematics journal appearance. The current Typst document "resembles a college textbook" due to colorful diagrams. Changes needed:

1. Remove all colors except for clickable links
2. Adopt styling closer to BimodalReference.tex (LaTeX version)
3. Apply systematic improvements across the entire Typst project

## Findings

### Current Color Usage Inventory

**1. Template-Level (template.typ)**
- `URLblue = rgb(30, 144, 255)` - Used for hyperlinks only (KEEP)
- Theorem environments already use `fill: none`, `stroke: none` (GOOD)

**2. Main Document (BimodalReference.typ)**
- Line 59: `#show link: set text(fill: URLblue)` - Hyperlinks (KEEP)
- Line 69: `#let HRule = line(length: 100%, stroke: 0.5pt)` - Black line (GOOD)

**3. Chapter Diagrams (NEED CHANGES)**

**00-introduction.typ** - World History Diagram:
| Line | Color Usage | Purpose |
|------|-------------|---------|
| 29 | `fill: blue.transparentize(85%)` | Past light cone background |
| 30 | `stroke: gray.lighten(40%)` | Light cone border |
| 37 | `fill: orange.transparentize(85%)` | Future light cone background |
| 38 | `stroke: gray.lighten(40%)` | Light cone border |
| 43-48 | `gray.lighten(50%)` | Counterfactual paths (dotted) |
| 56, 63-64, 68, 71 | `blue.darken(40%)` | Main worldline and label |

**04-metalogic.typ** - Two CeTZ Diagrams:

*Canonical Model Diagram (lines 193-215):*
| Line | Color Usage | Purpose |
|------|-------------|---------|
| 194 | `gray.darken(20%)` | Arrow stroke |
| 197, 200, 203 | `blue.lighten(90%)` | Box fills (MCS boxes) |
| 207 | `green.lighten(85%)` | Box fill (history layer) |
| 212, 215 | `orange.lighten(85%)` | Box fills (bottom layer) |

*Tableau Proof Diagram (lines 388-413):*
| Line | Color Usage | Purpose |
|------|-------------|---------|
| 389 | `gray.darken(30%)` | Arrow stroke |
| 392, 395 | `blue.lighten(90%)` | Box fills |
| 399 | `green.lighten(85%)` | Box fill |
| 403 | `orange.lighten(85%)` | Box fill |
| 406 | `yellow.lighten(80%)` | Box fill |
| 410, 413 | `purple.lighten(90%)` | Box fills |

**4. Table Strokes (Multiple Files)**
- Multiple chapters use `stroke: none` for tables - already AMS-style (GOOD)
- Some tables use `table.hline()` for horizontal rules - AMS convention (GOOD)

### LaTeX Version Analysis (BimodalReference.tex)

The LaTeX version follows strict AMS conventions:
- Uses `amsthm` with standard theorem styles (`definition`, `plain`, `remark`)
- NO colored backgrounds on theorem environments
- NO colored text except URLblue for hyperlinks
- Uses `booktabs` package for tables (professional `\toprule`, `\midrule`, `\bottomrule`)
- Uses `hyperref` with `colorlinks=true` and `URLblue` for all link types
- Diagrams are NOT present in BimodalReference.tex (text-only, or uses TikZ with minimal styling)

### AMS Style Guidelines Summary

Based on the LaTeX AMS packages and professional journal standards:

1. **Body text**: Black only
2. **Theorem environments**: Italic statement body (plain style), upright for definitions/remarks
3. **Diagrams**: Minimal color, prefer grayscale or pattern fills
4. **Links**: Single accent color (URLblue) acceptable for digital documents
5. **Tables**: No vertical rules, minimal horizontal rules (`booktabs` style)
6. **Math**: Standard Computer Modern or similar serif font

### Recommendations

#### Immediate Changes Required

**1. Introduction Diagram (00-introduction.typ)**
Convert from colored light cones to grayscale:
```typst
// Before: fill: blue.transparentize(85%)
// After:  fill: gray.lighten(90%)
// Before: fill: orange.transparentize(85%)
// After:  fill: gray.lighten(85%)
// Before: stroke/fill: blue.darken(40%)
// After:  stroke/fill: black
```

**2. Metalogic Diagrams (04-metalogic.typ)**
Convert both diagrams to use:
- Grayscale fills with varying lightness (90%, 85%, 80%) for visual distinction
- Or use patterns/hatching instead of color fills
- Black strokes instead of gray (or retain gray for subtle arrows)

Suggested grayscale mapping:
| Original Color | Replacement |
|---------------|-------------|
| `blue.lighten(90%)` | `gray.lighten(90%)` |
| `green.lighten(85%)` | `gray.lighten(82%)` |
| `orange.lighten(85%)` | `gray.lighten(75%)` |
| `yellow.lighten(80%)` | `gray.lighten(88%)` |
| `purple.lighten(90%)` | `gray.lighten(78%)` |

**3. Preserve URLblue**
The URLblue color for hyperlinks should remain. This is:
- Standard practice for digital PDF documents
- Consistent with the LaTeX version
- Necessary for usability (identifying clickable links)

#### No Changes Required

- Template theorem environments (already AMS-style)
- Table formatting (already uses booktabs-style rules)
- Font choice (New Computer Modern matches LaTeX)
- Paragraph/heading spacing (already LaTeX-like)

## Decisions

1. **URLblue preservation**: Keep `URLblue = rgb(30, 144, 255)` for links - this is the one acceptable color
2. **Diagram approach**: Convert to grayscale rather than removing diagrams entirely
3. **Scope**: Focus on the two files with color diagrams; template.typ is already compliant

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Grayscale diagrams may lose visual clarity | Medium | Test different gray levels; ensure sufficient contrast |
| Patterns/hatching may not render well in PDF | Low | Use solid grayscale fills instead |
| Print vs screen appearance | Low | Test both; grayscale works well for both |

## Implementation Checklist

### High Priority (Core AMS Compliance)
- [ ] Convert 00-introduction.typ diagram to grayscale
  - [ ] Change blue light cone fill to `gray.lighten(90%)`
  - [ ] Change orange light cone fill to `gray.lighten(85%)`
  - [ ] Change worldline stroke/fill from blue.darken(40%) to black
  - [ ] Keep gray dotted lines for counterfactuals (already subtle)

- [ ] Convert 04-metalogic.typ Canonical Model diagram to grayscale
  - [ ] Replace all colored box fills with varying gray levels
  - [ ] Keep or darken arrow strokes

- [ ] Convert 04-metalogic.typ Tableau Proof diagram to grayscale
  - [ ] Replace all colored box fills with varying gray levels
  - [ ] Keep or darken arrow strokes

### Verification
- [ ] Compile BimodalReference.typ and verify PDF appearance
- [ ] Compare against BimodalReference.tex PDF for consistency
- [ ] Verify URLblue links still visible and functional

### Optional Enhancements
- [ ] Consider adding subtle border strokes to grayscale boxes for better definition
- [ ] Add labels or legends if grayscale distinction is insufficient

## Appendix

### Files Requiring Changes
1. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/chapters/00-introduction.typ`
2. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/chapters/04-metalogic.typ`

### Files Already Compliant
1. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/template.typ` - Theorem environments are AMS-style
2. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/BimodalReference.typ` - Only uses URLblue for links
3. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/notation/*.typ` - No colors
4. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/chapters/01-syntax.typ` - Tables only, no colors
5. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/chapters/02-semantics.typ` - Tables only, no colors
6. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/chapters/03-proof-theory.typ` - Tables only, no colors
7. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/chapters/05-theorems.typ` - Tables only, no colors
8. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/chapters/06-notes.typ` - Tables only, no colors

### Search Queries Used
- `rgb|color|fill|stroke|blue|red|green|yellow|orange|purple` in Typst directory
- File structure exploration via Glob
