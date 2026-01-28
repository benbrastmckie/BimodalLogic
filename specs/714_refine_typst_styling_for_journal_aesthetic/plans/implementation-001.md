# Implementation Plan: Refine Typst Styling for Journal Aesthetic

- **Task**: 714 - Refine Typst styling for journal aesthetic
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: High
- **Dependencies**: Task 709 (completed)
- **Research Inputs**: specs/714_refine_typst_styling_for_journal_aesthetic/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

This plan refines the Typst styling from task 709 to match the austere aesthetic of traditional mathematics journals (Annals of Mathematics, JAMS, Acta Mathematica). The current implementation uses subtle colored backgrounds for theorem environments that create a "textbook" appearance. The changes remove all colored fills, relying solely on typographic distinction (bold headers, italic bodies) as per AMS/amsthm conventions. The document already uses appropriate typography (New Computer Modern 11pt, LaTeX-like margins), so changes focus on the theorem environment styling.

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
- Match AMS/journal aesthetic: austere, black-only text
- Preserve existing typography (fonts, margins, spacing)

**Non-Goals**:
- Switching from thmbox to ctheorems (try minimal changes first)
- Removing URL link colors (acceptable for digital documents)
- Changing document structure or content

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| thmbox cannot fully remove styling with fill: none | Medium | Low | Fall back to fill: white, or investigate stroke parameter |
| Loss of visual distinction between environment types | Low | Medium | AMS convention relies on typography (italic vs. upright); verify body styles |
| Changes break chapter files | Low | Very Low | Environments exported via template.typ; chapter content unchanged |
| Overly sparse appearance | Low | Very Low | This is the goal - matches journal standards |

## Implementation Phases

### Phase 1: Remove Background Colors [NOT STARTED]

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

### Phase 2: Verify Typography Conventions [NOT STARTED]

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
- Visual comparison with sample AMS journal article (e.g., Annals of Mathematics)
- Theorem bodies should be italic
- Definition bodies should be upright

---

### Phase 3: Compile and Quality Check [NOT STARTED]

**Goal**: Ensure complete document compiles correctly and matches journal aesthetic

**Tasks**:
- [ ] Compile BimodalReference.typ to PDF
- [ ] Review all chapters for consistent styling
- [ ] Verify tables have no colored backgrounds
- [ ] Verify code blocks (if any) are minimally styled
- [ ] Check page breaks around theorem environments
- [ ] Verify document prints well in black-and-white

**Timing**: 30 minutes

**Files to modify**:
- None expected (verification phase)

**Verification**:
- Document compiles without errors
- All theorem environments appear without colored backgrounds
- Typography is consistent throughout
- Visual comparison to target aesthetic (austere journal style)

---

### Phase 4: Documentation Update [NOT STARTED]

**Goal**: Update template.typ comments to reflect journal styling intent

**Tasks**:
- [ ] Update comment header in template.typ to mention journal aesthetic
- [ ] Remove references to "subtle background tints" in comments
- [ ] Add brief comment explaining AMS-style convention

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/typst/template.typ` - Update comments in styling section

**Verification**:
- Comments accurately describe the styling approach
- No references to colored backgrounds remain in comments

## Testing & Validation

- [ ] BimodalReference.typ compiles without errors
- [ ] No colored backgrounds visible in theorem environments
- [ ] Theorem headers are bold
- [ ] Body text follows AMS convention (italic for theorems, upright for definitions)
- [ ] Tables have no colored cell backgrounds
- [ ] Document appears austere and journal-like
- [ ] Document prints correctly in black-and-white

## Artifacts & Outputs

- `specs/714_refine_typst_styling_for_journal_aesthetic/plans/implementation-001.md` (this file)
- `Theories/Bimodal/typst/template.typ` (modified)
- `Theories/Bimodal/typst/BimodalReference.pdf` (recompiled)
- `specs/714_refine_typst_styling_for_journal_aesthetic/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If changes produce unsatisfactory results:
1. Revert template.typ to pre-change state via git
2. Consider alternative approach: switch to ctheorems package with thmplain
3. If thmbox is fundamentally unsuitable, implement custom show rules per research report Option 3

The current template.typ is simple enough that manual reversion is straightforward. Git history preserves the task 709 version as a known-good baseline.
