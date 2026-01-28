# Research Report: Typst Formatting Fixes for Bimodal Semantics

- **Task**: 708 - Fix Bimodal semantics Typst formatting issues
- **Started**: 2026-01-28T00:00:00Z
- **Completed**: 2026-01-28T00:10:00Z
- **Effort**: 15 minutes
- **Priority**: Medium
- **Dependencies**: None
- **Sources/Inputs**:
  - Codebase: `Theories/Bimodal/typst/chapters/02-semantics.typ`
  - Codebase: `Theories/Bimodal/typst/notation/bimodal-notation.typ`
  - Typst Documentation: attach functions, math styles, under/over functions
  - xarrow package documentation
- **Artifacts**: `specs/708_fix_bimodal_semantics_typst_formatting_issues/reports/research-001.md`
- **Standards**: report-format.md, artifact-formats.md

## Executive Summary

- Current `overset` implementation uses `attach(base, t: top)` which may not position text correctly above arrows
- The `Iff` command uses `[~_iff_~]` which produces markdown-style italics rather than math mode italics
- The `timeshift` command uses `attach(approx, t: sup, b: sub)` which should produce correct LaTeX-style stacking
- Solutions require minimal changes to `bimodal-notation.typ` using Typst's built-in `limits()` function and `math.italic()`
- The xarrow package offers an alternative for sophisticated arrow annotations if needed

## Context and Scope

### Task Description

Fix three Typst formatting issues identified in `Theories/Bimodal/typst/chapters/02-semantics.typ`:

1. **Line 28**: Duration text appears under arrow instead of over - `$w #overset($arrow.r.double.long$, $x$) u$`
2. **Line 79**: "iff" should display in italics - `&#Iff`
3. **Lines 106, 112**: Subscript/superscript stacking on approx symbol - `#timeshift($y$, $x$)`

### Current Implementations

In `bimodal-notation.typ` (lines 76-82):
```typst
// Metalanguage biconditional (distinct from object language iff) - italic style
#let Iff = [~_iff_~]

// Overset: place text above a symbol (for duration over arrows)
#let overset(base, top) = $attach(#base, t: #top)$

// Time-shift relation with subscript/superscript stacking (LaTeX-style)
#let timeshift(sub, sup) = $attach(approx, t: #sup, b: #sub)$
```

## Findings

### Issue 1: Arrow Annotation Positioning (overset)

**Problem**: The `attach(base, t: top)` function by default positions top attachments as superscripts (to the upper-right) for most symbols. Only "big operators" (like `sum`, `prod`, `integral`) automatically place attachments above/below.

**Typst Behavior**:
- `attach(base, t: content)` - positions `t` at top-right OR above, depending on symbol class
- `scripts(base)` - forces script-style positioning (to the side)
- `limits(base)` - forces limits-style positioning (above/below)

**Solution**: Wrap the arrow base in `limits()` to force the attachment above:

```typst
#let overset(base, top) = $limits(#base)^#top$
```

Or using explicit attach:
```typst
#let overset(base, top) = $attach(limits(#base), t: #top)$
```

**Alternative Solution**: Use the `xarrow` package for more sophisticated arrow annotations:
```typst
#import "@preview/xarrow:0.4.0": xarrow
$ a xarrow(sym: arrow.r.double.long, "duration") b $
```

**Source**: [Typst Attach Functions Documentation](https://typst.app/docs/reference/math/attach/)

### Issue 2: Italic "iff" Command

**Problem**: The current implementation `[~_iff_~]` uses content-mode markdown-style italics which may not render correctly in math mode and produces awkward spacing.

**Typst Math Style Functions**:
- `math.upright(content)` - non-italic style
- `math.italic(content)` - italic style
- `math.bold(content)` - bold style

These are distinct from the `text` function because math fonts contain multiple letter variants.

**Solution**: Use `math.italic()` for proper math-mode italics:

```typst
#let Iff = math.italic("iff")
```

**Alternative Solution**: Use upright text style (since "iff" is a metalanguage word, not a variable):

```typst
#let Iff = math.upright("iff")
```

**Spacing Consideration**: Add thin spaces around the command for proper alignment in equations:

```typst
#let Iff = $med #math.italic("iff") med$
```

Where `med` is a medium space in math mode.

**Source**: [Typst Math Styles Documentation](https://typst.app/docs/reference/math/styles/)

### Issue 3: Subscript/Superscript Stacking (timeshift)

**Problem**: The concern is whether `attach(approx, t: sup, b: sub)` produces LaTeX-style stacked sub/superscripts or script-style (to the side).

**Analysis of Current Implementation**:
```typst
#let timeshift(sub, sup) = $attach(approx, t: #sup, b: #sub)$
```

**Typst Default Behavior**: For symbols like `approx` (which is not a "big operator"), attachments default to script-style (to the side, like superscripts/subscripts on variables).

**Solution**: Use `limits()` to force stacking directly above/below the approx symbol:

```typst
#let timeshift(sub, sup) = $attach(limits(approx), t: #sup, b: #sub)$
```

Or using dedicated syntax:
```typst
#let timeshift(sub, sup) = $limits(approx)_#sub^#sup$
```

**Verification Needed**: Test both versions to confirm which produces the desired visual result:
- LaTeX `\overset{y}{\underset{x}{\approx}}` - stacks y above aprrox above x
- LaTeX `\approx_x^y` - places x and y as sub/superscripts to the right

**Source**: [Typst Attach Functions Documentation](https://typst.app/docs/reference/math/attach/)

## Decisions

1. **overset**: Use `limits()` wrapper to force above-positioning for arrow annotations
2. **Iff**: Use `math.italic()` for proper math-mode italic text
3. **timeshift**: Use `limits()` wrapper to force LaTeX-style stacking (above/below rather than script-style)

## Recommendations

### Priority 1: Update bimodal-notation.typ

Replace lines 76-82 with:

```typst
// Metalanguage biconditional (distinct from object language iff) - italic style
#let Iff = math.italic("iff")

// Overset: place text above a symbol (for duration over arrows)
#let overset(base, top) = $limits(#base)^#top$

// Time-shift relation with subscript/superscript stacking (LaTeX-style)
#let timeshift(sub, sup) = $limits(approx)_#sub^#sup$
```

### Priority 2: Verify Visual Output

After implementation, compile the Typst document and verify:
1. Duration `x` appears centered above the double arrow in the primitives table
2. "iff" appears in italics with proper spacing in the Truth definition
3. Subscript/superscript on approx symbol stack directly after the symbol

### Priority 3: Consider xarrow Package (Optional)

If the `limits()` approach doesn't produce ideal arrow annotations, consider importing `@preview/xarrow:0.4.0` for more control over arrow text positioning.

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| `limits()` changes symbol spacing | Low | Medium | Test visually, adjust spacing if needed |
| Math italic vs text italic appearance | Low | Low | Both are valid; choose based on document style |
| xarrow dependency adds complexity | Medium | Low | Only adopt if built-in approach fails |

## Appendix

### Search Queries Used

1. "Typst attach function overset text above symbol arrow annotation"
2. "Typst subscript superscript stacking directly after symbol LaTeX style limits"
3. "Typst custom command italic text math mode iff biconditional"

### Documentation References

- [Typst Attach Functions](https://typst.app/docs/reference/math/attach/)
- [Typst Under/Over Functions](https://typst.app/docs/reference/math/underover/)
- [Typst Math Styles](https://typst.app/docs/reference/math/styles/)
- [xarrow Package](https://typst.app/universe/package/xarrow/)

### Key Typst Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `attach(base, t:, b:, ...)` | Add attachments to symbol | `attach(sum, t: n, b: i=0)` |
| `limits(base)` | Force limits-style (above/below) | `limits(arrow)^text` |
| `scripts(base)` | Force scripts-style (side) | `scripts(sum)_i` |
| `math.italic(content)` | Italic in math mode | `math.italic("iff")` |
| `math.upright(content)` | Upright in math mode | `math.upright("if")` |
