# Implementation Plan: Task #709

- **Task**: 709 - Research Professional Typst Templates for Bimodal Documentation
- **Status**: [COMPLETED]
- **Effort**: 3-4 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/709_research_professional_typst_templates_for_bimodal_documentation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

This plan implements professional LaTeX-like styling for the Bimodal TM Logic documentation in Typst. The approach prioritizes incremental improvements: first applying quick fixes for flagged issues (hyperlink colors, TOC formatting, notation commands), then enhancing page layout and paragraph styling, and finally upgrading the theorem environment package for a more polished appearance. Changes are made to template.typ and BimodalReference.typ while preserving the existing chapter structure.

### Research Integration

Key findings from research-001.md integrated into this plan:
- **thmbox** package recommended for professional theorem styling with colored borders
- LaTeX-like page settings: 1.75in margins, tight leading (0.55em), first-line indent (1.8em)
- URLblue color defined as `rgb(0, 0, 150)` to match LogosReference.tex
- TOC bold chapters via `outline.entry.where(level: 1)` show rule
- `attach()` function for subscript/superscript stacking on symbols

## Goals & Non-Goals

**Goals**:
- Match the professional LaTeX appearance of LogosReference.tex
- Fix all flagged issues in source comments (6 items)
- Create reusable notation commands for common patterns
- Maintain backwards compatibility with existing chapter content

**Non-Goals**:
- Complete restructuring with bookly template (save for future)
- Adding bibliography support
- Chapter-level refactoring

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| thmbox package incompatibility | High | Low | Fall back to enhancing great-theorems styling |
| Page margin changes break content | Medium | Low | Test with full document compile after changes |
| Notation commands break existing formulas | Medium | Medium | Test each notation change with affected chapter |

## Implementation Phases

### Phase 1: Foundation and Link Styling [COMPLETED]

**Goal**: Establish color definitions and hyperlink styling to match LaTeX appearance.

**Tasks**:
- [ ] Add URLblue color definition to template.typ: `#let URLblue = rgb(0, 0, 150)`
- [ ] Add show rule for links: `#show link: set text(fill: URLblue)`
- [ ] Update website link on title page to use monospace font (texttt equivalent)
- [ ] Test that all hyperlinks in document appear in light blue

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/typst/template.typ` - Add color definition and link show rule
- `Theories/Bimodal/typst/BimodalReference.typ` - Update website link styling

**Verification**:
- Compile document and verify all links appear in light blue
- Verify website URL appears in monospace font

---

### Phase 2: Table of Contents Formatting [COMPLETED]

**Goal**: Make chapter entries bold with proper spacing, matching LaTeX TOC style.

**Tasks**:
- [ ] Add show rule for level 1 outline entries: `#show outline.entry.where(level: 1): strong`
- [ ] Add spacing before chapter entries: `#show outline.entry.where(level: 1): set block(above: 1.2em)`
- [ ] Add space after "Contents" heading before TOC entries
- [ ] Verify section/subsection entries remain normal weight

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/typst/BimodalReference.typ` - Add outline show rules in abstract page section

**Verification**:
- Compile and verify chapter names are bold in TOC
- Verify section numbers and titles are normal weight
- Verify spacing looks balanced

---

### Phase 3: Abstract Header Styling [COMPLETED]

**Goal**: Center the Abstract header with proper spacing before content.

**Tasks**:
- [ ] Wrap abstract heading in `#align(center)[]`
- [ ] Add vertical space after heading: `#v(0.5em)`
- [ ] Optionally increase heading size slightly for emphasis

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/typst/BimodalReference.typ` - Update abstract section

**Verification**:
- Compile and verify Abstract header is centered
- Verify spacing before content paragraph looks professional

---

### Phase 4: Mathematical Notation Commands [COMPLETED]

**Goal**: Add dedicated notation commands for iff, duration arrows, and subscript/superscript stacking.

**Tasks**:
- [ ] Create `#let iff = text(style: "italic", " iff ")` command in bimodal-notation.typ
- [ ] Create `#let overset(base, top) = $attach(#base, t: #top)$` for duration over arrows
- [ ] Create subscript/superscript stacking helper: `#let approxrel(sub, sup) = $attach(approx, t: #sup, b: #sub)$`
- [ ] Update chapter files to use new notation commands where flagged

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/typst/notation/bimodal-notation.typ` - Add new notation commands
- `Theories/Bimodal/typst/chapters/02-semantics.typ` - Update formulas to use new commands

**Verification**:
- Compile and verify "iff" appears in italics in Definition 4 (Truth)
- Verify duration labels appear over arrows in task frame table
- Verify subscript/superscript stacking on approx symbol

---

### Phase 5: Page Layout and Typography [COMPLETED]

**Goal**: Apply LaTeX-like page settings for professional book appearance.

**Tasks**:
- [ ] Set page margins: `#set page(margin: 1.75in)` or adjusted for Typst defaults
- [ ] Set paragraph leading: `#set par(leading: 0.55em)`
- [ ] Set paragraph spacing: `#set par(spacing: 0.55em)`
- [ ] Add first-line indent: `#set par(first-line-indent: 1.8em)`
- [ ] Adjust heading spacing: `#show heading: set block(above: 1.4em, below: 1em)`
- [ ] Ensure New Computer Modern Mono used for raw text

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/typst/BimodalReference.typ` - Update document configuration section

**Verification**:
- Compile full document and compare with LogosReference.pdf appearance
- Verify margins, line spacing, and paragraph indents match LaTeX style
- Verify no overfull lines or layout issues

---

### Phase 6: Theorem Environment Enhancement [COMPLETED]

**Goal**: Upgrade to thmbox package for professional theorem styling.

**Tasks**:
- [ ] Replace `great-theorems` import with `@preview/thmbox:0.3.0`
- [ ] Initialize thmbox: `#show: thmbox-init()`
- [ ] Update theorem environment definitions to use thmbox syntax
- [ ] Configure counters for chapter-relative numbering
- [ ] Maintain existing environment names (definition, theorem, lemma, axiom, remark, proof)
- [ ] Test all environments render correctly

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/typst/template.typ` - Replace theorem environment definitions
- `Theories/Bimodal/typst/BimodalReference.typ` - Update package import and initialization

**Verification**:
- Compile and verify all theorem environments render with professional styling
- Verify numbering continues to follow chapter.number pattern
- Verify proof environments work correctly
- Spot-check multiple chapters for correct rendering

---

### Phase 7: Final Polish and Cleanup [COMPLETED]

**Goal**: Remove TODO/FIX/NOTE comments and finalize document.

**Tasks**:
- [ ] Remove all resolved TODO/FIX/NOTE comments from source files
- [ ] Add any remaining polish (consistent spacing, alignment)
- [ ] Full document review for visual consistency
- [ ] Update any chapter-specific styling issues discovered during testing

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/typst/BimodalReference.typ` - Remove resolved comments
- `Theories/Bimodal/typst/chapters/02-semantics.typ` - Remove resolved comments
- Other chapter files as needed

**Verification**:
- Full compile with no warnings
- Visual inspection of entire PDF
- No TODO/FIX/NOTE comments remain in flagged locations

---

## Testing & Validation

- [ ] Document compiles without errors after each phase
- [ ] All hyperlinks appear in URLblue color
- [ ] TOC shows bold chapter names with normal section names
- [ ] Abstract header is centered with proper spacing
- [ ] "iff" appears in italics in semantic definitions
- [ ] Duration labels appear over transition arrows
- [ ] Subscript/superscript stacking matches LaTeX appearance
- [ ] Page layout resembles LogosReference.tex
- [ ] All theorem environments render correctly
- [ ] No flagged TODO/FIX/NOTE comments remain

## Artifacts & Outputs

- Updated `Theories/Bimodal/typst/template.typ` with professional styling
- Updated `Theories/Bimodal/typst/BimodalReference.typ` with page configuration
- Updated `Theories/Bimodal/typst/notation/bimodal-notation.typ` with new commands
- Updated chapter files with notation changes
- Compiled BimodalReference.pdf with professional appearance

## Rollback/Contingency

If thmbox package causes issues in Phase 6:
1. Revert to great-theorems package
2. Apply custom styling to existing mathblock() definitions
3. Use CSS-like show rules to enhance appearance of existing environments

All changes can be reverted via git if needed. Each phase is independently testable, so issues can be isolated to specific changes.
