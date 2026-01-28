# Implementation Plan: Refine Typst Styling for Journal Aesthetic

- **Task**: 714 - Refine Typst styling for journal aesthetic
- **Version**: 002
- **Status**: [IMPLEMENTING]
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: Task 709 (completed)
- **Research Inputs**: specs/714_refine_typst_styling_for_journal_aesthetic/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Previous Version**: implementation-001.md
- **Revision Reason**: User clarified: colored links should be preserved, apply AMS/journal aesthetic consistently throughout all Bimodal/typst/ documents

## Overview

This revised plan refines the Typst styling from task 709 to match the austere aesthetic of traditional mathematics journals (Annals of Mathematics, JAMS, Acta Mathematica) while **explicitly preserving colored hyperlinks** for digital usability. The current implementation uses subtle colored backgrounds for theorem environments that create a "textbook" appearance. The changes remove colored fills from theorem environments but preserve link colors (light blue for references and URLs).

### Key Changes from v001

1. **Colored links explicitly preserved**: Link colors (light blue) are retained for digital usability
2. **Expanded scope**: Apply styling consistently across all Bimodal/typst/ chapter files
3. **Verification updated**: Check all 6 chapter files for consistency

### Research Integration

Key findings from research-001.md:
- AMS standard defines three theorem styles: plain (italic body), definition (upright body), remark (upright, no extra spacing)
- None use background colors - text color only (black)
- Current implementation has four colored fills: theorem (blue-gray), definition (mint), axiom (orange), remark (gray)
- Recommended approach: Set `fill: none` and `stroke: none` for all environments

## Goals & Non-Goals

**Goals**:
- Remove all colored background fills from theorem environments
- Ensure environments use typographic distinction only (bold headers, appropriate body fonts)
- Match AMS/journal aesthetic: austere, black-only body text
- **Preserve colored hyperlinks** (light blue) for digital usability
- Apply changes consistently across ALL Bimodal/typst/ documents
- Preserve existing typography (fonts, margins, spacing)

**Non-Goals**:
- Removing URL/reference link colors (these are explicitly wanted)
- Switching from thmbox to ctheorems (try minimal changes first)
- Changing document structure or content

## Scope

**Files in scope**:
- `Theories/Bimodal/typst/template.typ` - Main styling definitions
- `Theories/Bimodal/typst/BimodalReference.typ` - Master document
- `Theories/Bimodal/typst/chapters/00-introduction.typ`
- `Theories/Bimodal/typst/chapters/01-syntax.typ`
- `Theories/Bimodal/typst/chapters/02-semantics.typ`
- `Theories/Bimodal/typst/chapters/03-proof-theory.typ`
- `Theories/Bimodal/typst/chapters/04-metalogic.typ`
- `Theories/Bimodal/typst/chapters/05-theorems.typ`
- `Theories/Bimodal/typst/chapters/06-notes.typ`

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| thmbox cannot fully remove styling with fill: none | Medium | Low | Fall back to fill: white, or investigate stroke parameter |
| Loss of visual distinction between environment types | Low | Medium | AMS convention relies on typography (italic vs. upright); verify body styles |
| Inconsistent styling in chapter files | Low | Low | Review all chapters for local overrides |
| Link colors accidentally removed | Low | Very Low | Check link styling separately from theorem styling |

## Implementation Phases

### Phase 1: Remove Background Colors from Theorem Environments [COMPLETED]

**Goal**: Eliminate all colored fills from theorem environments in template.typ

**Tasks**:
- [ ] Modify theorem-style to use `fill: none, stroke: none`
- [ ] Modify definition-style to use `fill: none, stroke: none`
- [ ] Modify axiom-style to use `fill: none, stroke: none`
- [ ] Modify remark-style to use `fill: none, stroke: none`

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/typst/template.typ` - Lines 28-42, change all style definitions

**Verification**:
- Compile BimodalReference.typ and verify no colored backgrounds appear
- Verify theorem headers remain bold
- Verify proof environment unchanged (already uses thmbox.proof directly)

---

### Phase 2: Verify and Preserve Link Colors [COMPLETED]

**Goal**: Ensure hyperlink colors are preserved while removing other colors

**Tasks**:
- [ ] Verify current link color configuration in template.typ or BimodalReference.typ
- [ ] Confirm links remain light blue after Phase 1 changes
- [ ] Test both internal references (@ref) and external URLs
- [ ] Document the link color setting for future reference

**Timing**: 15 minutes

**Files to check**:
- `Theories/Bimodal/typst/template.typ` - Link styling
- `Theories/Bimodal/typst/BimodalReference.typ` - Document-level settings

**Verification**:
- Internal cross-references display in light blue
- External URLs display in light blue
- Table of contents links are colored appropriately

---

### Phase 3: Verify Typography Conventions [COMPLETED]

**Goal**: Ensure body text matches AMS conventions (theorems italic, definitions upright)

**Tasks**:
- [ ] Check if thmbox default body styles match AMS conventions
- [ ] If needed, add body text styling parameters to each environment
- [ ] Verify theorem/lemma bodies are italic
- [ ] Verify definition bodies are upright with defined terms in italic

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/typst/template.typ` - May need to add bodyfmt or similar parameter

**Verification**:
- Visual comparison with sample AMS journal article
- Theorem bodies should be italic
- Definition bodies should be upright

---

### Phase 4: Compile and Quality Check All Chapters [COMPLETED]

**Goal**: Ensure all documents compile correctly and match journal aesthetic consistently

**Tasks**:
- [ ] Compile BimodalReference.typ to PDF
- [ ] Review each chapter for consistent styling:
  - [ ] 00-introduction.typ
  - [ ] 01-syntax.typ
  - [ ] 02-semantics.typ
  - [ ] 03-proof-theory.typ
  - [ ] 04-metalogic.typ
  - [ ] 05-theorems.typ
  - [ ] 06-notes.typ
- [ ] Verify no chapter has local styling overrides that introduce colors
- [ ] Verify tables have no colored backgrounds
- [ ] Verify code blocks (if any) are minimally styled
- [ ] Check page breaks around theorem environments
- [ ] Verify document prints well in black-and-white (except links)

**Timing**: 40 minutes

**Files to review**:
- All chapter files listed above
- Main BimodalReference.typ

**Verification**:
- Document compiles without errors
- All theorem environments appear without colored backgrounds
- Link colors are preserved (light blue)
- Typography is consistent throughout all chapters
- Visual comparison to target aesthetic (austere journal style)

---

### Phase 5: Documentation Update [COMPLETED]

**Goal**: Update template.typ comments to reflect journal styling intent

**Tasks**:
- [ ] Update comment header in template.typ to mention journal aesthetic
- [ ] Remove references to "subtle background tints" in comments
- [ ] Add brief comment explaining AMS-style convention
- [ ] Document that link colors are intentionally preserved

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/typst/template.typ` - Update comments in styling section

**Verification**:
- Comments accurately describe the styling approach
- No references to colored backgrounds remain in comments
- Link color preservation is documented

## Testing & Validation

- [ ] BimodalReference.typ compiles without errors
- [ ] No colored backgrounds visible in theorem environments
- [ ] Hyperlinks display in light blue (preserved)
- [ ] Theorem headers are bold
- [ ] Body text follows AMS convention (italic for theorems, upright for definitions)
- [ ] Tables have no colored cell backgrounds
- [ ] All 6 chapter files are styled consistently
- [ ] Document appears austere and journal-like
- [ ] Document prints correctly in black-and-white (links may be gray)

## Artifacts & Outputs

- `specs/714_refine_typst_styling_for_journal_aesthetic/plans/implementation-002.md` (this file)
- `Theories/Bimodal/typst/template.typ` (modified)
- `Theories/Bimodal/typst/BimodalReference.pdf` (recompiled)
- `specs/714_refine_typst_styling_for_journal_aesthetic/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If changes produce unsatisfactory results:
1. Revert template.typ to pre-change state via git
2. Consider alternative approach: switch to ctheorems package with thmplain
3. If thmbox is fundamentally unsuitable, implement custom show rules per research report Option 3

The current template.typ is simple enough that manual reversion is straightforward. Git history preserves the task 709 version as a known-good baseline.
