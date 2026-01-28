# Implementation Plan: Task #703

- **Task**: 703 - fix_bimodal_typst_formatting_issues
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/703_fix_bimodal_typst_formatting_issues/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Fix Typst formatting issues in BimodalReference.typ to achieve visual parity with the LaTeX reference documents. The research report identified concrete solutions for all issues: margins should use uniform 1.75in to match LaTeX 11pt article class, Abstract header needs spacing adjustments, Contents/TOC header needs manual styling with centered title, and hyperlink color can optionally be changed to light blue. The URL monospace formatting is already correct using `#raw()`.

### Research Integration

- Research report: `specs/703_fix_bimodal_typst_formatting_issues/reports/research-001.md`
- Key findings: LaTeX 11pt article class uses 1.75in margins; current Typst uses 1.5in x 1.25in y. URLblue color rgb(0,0,150) matches LaTeX but task requests "light blue". URL formatting already uses `#raw()` correctly.

## Goals & Non-Goals

**Goals**:
- Match page margins to LaTeX 11pt article class defaults (1.75in uniform)
- Add proper spacing around Abstract header
- Style Contents header with centering and proper spacing
- Adjust hyperlink color to light blue (if desired)

**Non-Goals**:
- Changing URL monospace formatting (already correct)
- Modifying any document content
- Changing theorem environment styling

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Margin change affects page breaks | Medium | Medium | Review document pagination after change |
| TOC styling breaks with nested sections | Low | Low | Test with actual document structure |
| Light blue color reduces readability | Low | Low | Use Dodger Blue rgb(30,144,255) which has good contrast |

## Implementation Phases

### Phase 1: Update Page Margins [COMPLETED]

**Goal**: Change page margins from asymmetric (1.5in x, 1.25in y) to uniform 1.75in to match LaTeX 11pt article class defaults.

**Tasks**:
- [ ] Edit BimodalReference.typ line 43 to change margin value
- [ ] Verify document renders correctly with new margins

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/typst/BimodalReference.typ` (line 43)

**Before**:
```typst
  margin: (x: 1.5in, y: 1.25in),  // Professional margins
```

**After**:
```typst
  margin: 1.75in,  // Match LaTeX 11pt article class defaults
```

**Verification**:
- Compile document with `typst compile BimodalReference.typ`
- Visually inspect margins match expected 1.75in

---

### Phase 2: Add Abstract Header Spacing [COMPLETED]

**Goal**: Add vertical spacing above and below the Abstract header for better visual separation.

**Tasks**:
- [ ] Add `#v(1em)` before the Abstract header alignment block
- [ ] Change spacing after header from 0.5em to 1em for consistency

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/typst/BimodalReference.typ` (lines 105-109)

**Before**:
```typst
#page(numbering: none)[
  #align(center)[
    #text(size: 14pt, weight: "bold")[Abstract]
  ]
  #v(0.5em)
```

**After**:
```typst
#page(numbering: none)[
  #v(1em)
  #align(center)[
    #text(size: 14pt, weight: "bold")[Abstract]
  ]
  #v(1em)
```

**Verification**:
- Compile document and verify Abstract header has balanced spacing above and below

---

### Phase 3: Style Contents Header [COMPLETED]

**Goal**: Style the Contents/TOC header with centering and proper spacing, matching the Abstract header styling.

**Tasks**:
- [ ] Add manual centered Contents header before the outline
- [ ] Change outline title parameter to `none` since header is styled manually
- [ ] Add spacing around the manual header

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/typst/BimodalReference.typ` (lines 117-123)

**Before**:
```typst
  #v(1cm)
  // Bold chapter entries (level 1), normal weight for sections/subsections
  #show outline.entry.where(level: 1): it => {
    v(0.5em)
    strong(it)
  }
  #outline(title: "Contents", indent: auto)
```

**After**:
```typst
  #v(1cm)

  // Styled Contents header
  #align(center)[
    #text(size: 14pt, weight: "bold")[Contents]
  ]
  #v(1em)

  // Bold chapter entries (level 1), normal weight for sections/subsections
  #show outline.entry.where(level: 1): it => {
    v(0.5em)
    strong(it)
  }
  #outline(title: none, indent: auto)
```

**Verification**:
- Compile document and verify Contents header is centered with proper styling
- Verify TOC entries still display correctly with proper indentation

---

### Phase 4: Adjust Hyperlink Color to Light Blue [IN PROGRESS]

**Goal**: Change hyperlink color from dark blue rgb(0,0,150) to light blue rgb(30,144,255) (Dodger Blue) for better visibility.

**Tasks**:
- [ ] Edit template.typ line 18 to change URLblue color value
- [ ] Verify links display in light blue throughout document

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/typst/template.typ` (line 18)

**Before**:
```typst
#let URLblue = rgb(0, 0, 150)
```

**After**:
```typst
#let URLblue = rgb(30, 144, 255)  // Light blue (Dodger Blue)
```

**Verification**:
- Compile document and verify all hyperlinks appear in light blue
- Check readability against white background

---

## Testing & Validation

- [ ] Document compiles without errors
- [ ] Margins appear uniform at 1.75in on all sides
- [ ] Abstract header has balanced spacing (1em above and below)
- [ ] Contents header is centered with 14pt bold styling
- [ ] TOC entries display correctly with proper indentation
- [ ] Hyperlinks display in light blue color
- [ ] Document pagination is acceptable with new margins

## Artifacts & Outputs

- `Theories/Bimodal/typst/BimodalReference.typ` - Modified document with margin, abstract, and TOC changes
- `Theories/Bimodal/typst/template.typ` - Modified template with updated hyperlink color
- `specs/703_fix_bimodal_typst_formatting_issues/summaries/implementation-summary-YYYYMMDD.md` - Implementation summary

## Rollback/Contingency

If formatting changes cause unacceptable layout issues:
1. Revert margin change: restore `margin: (x: 1.5in, y: 1.25in)`
2. Revert abstract spacing: restore `#v(0.5em)` and remove top spacing
3. Revert TOC: restore `title: "Contents"` and remove manual header
4. Revert color: restore `rgb(0, 0, 150)` for dark blue

All changes are isolated and can be reverted independently using git.
