# Implementation Plan: Task #371

**Task**: Refactor LaTeX reference manual titles
**Version**: 001
**Created**: 2026-01-11
**Language**: latex

## Overview

Replace the simple `\maketitle` command in both BimodalReference.tex and LogosReference.tex with custom `titlepage` environments featuring:
- Horizontal rules framing the main title
- Clear title/subtitle hierarchy
- Author name with website link
- Paper references with hyperlinks
- Professional academic manual appearance

## Phases

### Phase 1: Update BimodalReference.tex

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Replace `\maketitle` with custom `titlepage` environment
2. Add "Reference Manual" as main title with horizontal rules
3. Add "Bimodal Logic for Tense and Modality" as subtitle
4. Add author information with website link
5. Add paper reference with PDF link

**Files to modify**:
- `Bimodal/latex/BimodalReference.tex` - Replace title section

**Steps**:
1. Define `\HRule` command for horizontal rules
2. Remove existing `\title`, `\author`, `\date` commands
3. Remove `\maketitle` call
4. Insert custom `titlepage` environment with:
   - Vertical spacing at top
   - HRule above title
   - "Reference Manual" in `\Huge \bfseries`
   - HRule below title
   - "Bimodal Logic for Tense and Modality" in `\Large\itshape`
   - Author name in `\large`
   - Website link using `\texttt{\href{}{}}`
   - "Based on:" section with paper link
   - Date at bottom with `\vfill`
5. Keep abstract after title page

**Verification**:
- [ ] Document compiles without errors
- [ ] Title page displays correctly with horizontal rules
- [ ] Website link is clickable
- [ ] Paper reference link works
- [ ] Abstract appears on second page

---

### Phase 2: Update LogosReference.tex

**Estimated effort**: 25 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Replace `\maketitle` with custom `titlepage` environment (same pattern as Bimodal)
2. Add "Reference Manual" as main title
3. Add "Logos: A Hyperintensional Logic System" as subtitle
4. Add author information with website link
5. Add references to both Springer papers

**Files to modify**:
- `Logos/latex/LogosReference.tex` - Replace title section

**Steps**:
1. Define `\HRule` command for horizontal rules
2. Remove existing `\title`, `\author`, `\date` commands
3. Remove `\maketitle` call
4. Insert custom `titlepage` environment with:
   - Same structure as BimodalReference.tex
   - "Logos: A Hyperintensional Logic System" as subtitle
   - "Based on:" section with TWO paper references:
     - First paper: https://link.springer.com/article/10.1007/s10992-025-09793-8
     - Second paper: https://link.springer.com/article/10.1007/s10992-021-09612-w
5. Keep abstract after title page

**Verification**:
- [ ] Document compiles without errors
- [ ] Title page displays correctly with horizontal rules
- [ ] Website link is clickable
- [ ] Both paper reference links work
- [ ] Abstract appears correctly

---

### Phase 3: Verification and Consistency Check

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Compile both documents and verify PDF output
2. Ensure consistent styling between both manuals
3. Verify all hyperlinks work in generated PDFs

**Files to verify**:
- `Bimodal/latex/BimodalReference.tex`
- `Logos/latex/LogosReference.tex`

**Steps**:
1. Compile BimodalReference.tex with pdflatex
2. Compile LogosReference.tex with pdflatex
3. Open both PDFs and verify:
   - Title page layout matches intended design
   - Horizontal rules are visible and well-positioned
   - Font sizes create clear hierarchy
   - All hyperlinks are clickable and lead to correct URLs
4. Compare both title pages for visual consistency
5. Clean up any auxiliary files

**Verification**:
- [ ] Both PDFs generate successfully
- [ ] Title pages are visually consistent
- [ ] All 4 hyperlinks work (2 websites + 3 papers)
- [ ] No LaTeX warnings related to title page

## Dependencies

- hyperref package (already loaded via formatting.sty)
- No external dependencies

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| hyperref conflicts | Medium | Low | formatting.sty already loads hyperref, use its settings |
| Font size inconsistencies | Low | Low | Use standard LaTeX size commands |
| URL display issues | Low | Medium | Use `\texttt{}` with `\href{}{}` for clean display |

## Success Criteria

- [ ] BimodalReference.tex compiles successfully
- [ ] LogosReference.tex compiles successfully
- [ ] Title pages have professional academic appearance
- [ ] Main title "Reference Manual" is prominent with horizontal rules
- [ ] Subtitles clearly identify each logic system
- [ ] Author name and website are visible and linked
- [ ] Paper references are clickable
- [ ] Both manuals share consistent visual design

## Rollback Plan

If implementation fails, revert to original `\maketitle` approach by:
1. Restore `\title`, `\author`, `\date` commands
2. Remove `titlepage` environment
3. Restore `\maketitle` call
4. Remove `\HRule` definition

Git can be used to restore previous versions if needed.
