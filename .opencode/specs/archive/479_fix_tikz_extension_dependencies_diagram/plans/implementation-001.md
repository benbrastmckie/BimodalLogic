# Implementation Plan: Task #479

- **Task**: 479 - Fix TikZ extension dependencies diagram
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: .claude/specs/479_fix_tikz_extension_dependencies_diagram/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

Restructure the TikZ diagram in `00-Introduction.tex` to match the README.md ASCII diagram structure. The key changes are: (1) vertical stacking with full-width boxes for Foundation, Explanatory, Agential, and Reflection; (2) middle extensions (Epistemic, Normative, Spatial) in a grey horizontal band with ellipses; (3) Agential and Reflection on the same level (both inheriting from middle extensions, not from each other); (4) cleaner arrow paths without crossing.

### Research Integration

Key findings from research-001.md:
- Required TikZ libraries: `fit`, `backgrounds`, `positioning`, `calc`
- Use `gray!15` fill for background box with `inner sep=10pt` padding
- Apply `rounded corners=4pt` for professional styling
- Use `-|` operator for right-angle connections
- Ellipsis nodes with `\ldots` for extensibility indicators

### User Modification

**Critical requirement**: Agential and Reflection layers must be on the same level, both inheriting from the middle layer extensions (not from each other). This differs from the README.md diagram which shows a linear sequence.

## Goals & Non-Goals

**Goals**:
- Match the visual structure of README.md (vertical flow with horizontal band for middle extensions)
- Add grey background box around middle extensions (Epistemic, Normative, Spatial)
- Add ellipsis indicators to show extensibility
- Place Agential and Reflection on the same horizontal level
- Both Agential and Reflection inherit from middle extensions
- Use professional styling (rounded corners, clean arrows)
- Maintain semantic accuracy (correct dependency relationships)

**Non-Goals**:
- Changing the content/descriptions within each box
- Modifying the explanatory text after the diagram
- Adding new extensions not in the current diagram
- Implementing complex animations or interactions

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TikZ library loading errors | High | Low | Add libraries incrementally, test after each |
| Arrow paths crossing | Medium | Medium | Use coordinate calculations and `-|` paths |
| Background layer conflicts | Medium | Low | Use explicit `pgfonlayer` environment |
| Build failure | High | Low | Test compile after each phase |

## Implementation Phases

### Phase 1: Add TikZ Libraries and Update Styles [COMPLETED]

**Goal**: Set up required TikZ libraries and define updated node styles.

**Tasks**:
- [ ] Add `\usetikzlibrary{fit,backgrounds,positioning,calc}` after tikzpicture begins
- [ ] Update `box` style to include `rounded corners=4pt`
- [ ] Update `smallbox` style to include `rounded corners=3pt`
- [ ] Add `widebox` style for full-width Foundation/Explanatory/Agential/Reflection boxes

**Timing**: 20 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/00-Introduction.tex` (lines 26-30)

**Verification**:
- LaTeX compiles without errors
- Existing diagram still renders (may look unchanged)

---

### Phase 2: Restructure Nodes to Vertical Layout [COMPLETED]

**Goal**: Convert to vertical stacking layout with full-width boxes for main layers.

**Tasks**:
- [ ] Keep Foundation at top, make full-width
- [ ] Keep Explanatory below Foundation, make full-width
- [ ] Position middle extensions (Epistemic, Normative, Spatial) horizontally centered
- [ ] Create Agential as full-width box below middle extensions
- [ ] Create Reflection as full-width box at same level as Agential (side by side)
- [ ] Use relative positioning (`below=of`, `right=of`) instead of absolute coordinates

**Timing**: 30 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/00-Introduction.tex` (lines 32-92)

**Verification**:
- All nodes visible and properly positioned
- Vertical flow visible from Foundation to bottom layers
- Agential and Reflection on same horizontal level

---

### Phase 3: Add Background Box and Ellipses [COMPLETED]

**Goal**: Add grey background grouping for middle extensions and ellipsis indicators.

**Tasks**:
- [ ] Create `pgfonlayer{background}` with fitted box around Epistemic, Normative, Spatial
- [ ] Style background box with `fill=gray!15, draw=gray!50, rounded corners=4pt, inner sep=10pt`
- [ ] Add left ellipsis node (`\ldots`) before Epistemic
- [ ] Add right ellipsis node (`\ldots`) after Spatial

**Timing**: 25 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/00-Introduction.tex` (insert after middle extension nodes)

**Verification**:
- Grey background box visible around middle extensions
- Ellipses visible on left and right sides
- Ellipses included within or adjacent to background box

---

### Phase 4: Update Arrow Connections [COMPLETED]

**Goal**: Redraw arrows with clean paths reflecting the correct dependency structure.

**Tasks**:
- [ ] Foundation -> Explanatory: vertical arrow with "required" label
- [ ] Explanatory -> middle layer: fan-out arrows with "optional" labels
- [ ] Create coordinate above middle extensions for arrow junction
- [ ] Middle extensions -> Agential: converging arrows with "at least one required" label
- [ ] Middle extensions -> Reflection: separate converging arrows (especially from Epistemic)
- [ ] Remove old Agential -> Reflection arrow (they are now at same level)
- [ ] Use `-|` and `|-` for right-angle connections to avoid crossing

**Timing**: 30 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/00-Introduction.tex` (lines 94-106)

**Verification**:
- All dependency relationships correctly represented
- No arrow intersections or overlaps
- Labels positioned clearly

---

### Phase 5: Final Polish and Build Verification [COMPLETED]

**Goal**: Refine positioning, spacing, and verify complete build.

**Tasks**:
- [ ] Adjust node spacing for visual balance
- [ ] Ensure labels don't overlap nodes or arrows
- [ ] Verify all TikZ styles are consistent
- [ ] Run full `pdflatex LogosReference.tex` build
- [ ] Check for overfull hbox warnings
- [ ] Verify diagram appears correctly in PDF output

**Timing**: 15 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/00-Introduction.tex`

**Verification**:
- Clean pdflatex build with no errors
- Diagram matches intended structure
- PDF renders correctly

## Testing & Validation

- [ ] `pdflatex 00-Introduction.tex` compiles successfully as standalone subfile
- [ ] `pdflatex LogosReference.tex` compiles successfully for full document
- [ ] Diagram structure matches README.md visual layout
- [ ] Agential and Reflection are on same horizontal level
- [ ] Grey background box visible around middle extensions
- [ ] Ellipses visible indicating extensibility
- [ ] Arrow paths do not cross
- [ ] All labels readable and correctly positioned

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- Modified `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/00-Introduction.tex`
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If the new diagram causes build issues or renders incorrectly:
1. The original TikZ code is preserved in git history
2. Can revert with `git checkout HEAD~1 -- Theories/Logos/latex/subfiles/00-Introduction.tex`
3. Phase-by-phase commits allow reverting to any intermediate state

## Appendix: Target Structure Reference

```
┌─────────────────────────────────────────────────────────────┐
│                  Constitutive Foundation                     │
│                (hyperintensional base layer)                 │
└───────────────────────────┬─────────────────────────────────┘
                            │ required
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Explanatory Extension                      │
│             (modal, temporal, counterfactual)                │
└───────────────────────────┬─────────────────────────────────┘
                            │ optional
       ┌────────────────────┼────────────────────┐
       ▼                    ▼                    ▼
┌──────────────────────────────────────────────────────────────┐
│ [GREY BOX]                                                   │
│  ... [Epistemic] [Normative] [Spatial] ...                   │
└──────────┬────────────────┼────────────────────┬─────────────┘
           │                │                    │
           │ at least one   │ at least one       │
           ▼                ▼                    ▼
┌─────────────────────────┐   ┌─────────────────────────────────┐
│   Agential Extension    │   │      Reflection Extension       │
│  (multi-agent reasoning)│   │  (metacognitive self-modeling)  │
└─────────────────────────┘   └─────────────────────────────────┘
     ^                                    ^
     |_____ Both at same level ___________|
```

Note: Both Agential and Reflection inherit from the middle extensions (at least one required), and are positioned at the same level rather than in sequence.
