# Implementation Plan: Task #486

- **Task**: 486 - Add Abilities and Choice boxes to TikZ diagram
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: .claude/specs/486_add_abilities_box_to_tikz_diagram/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

Add two new boxes (Abilities and Choice) to the middle layer of the TikZ extension dependencies diagram in 00-Introduction.tex and the ASCII diagram in README.md.
The Abilities box will contain ability operators (Can_a, Able_a) while the Choice box will contain free choice modal operators (FP, Ch).
Research established that ability modals and free choice modals are conceptually distinct: ability modals concern agent capacities, while free choice modals concern permission distribution over alternatives.
This justifies separating them into two distinct boxes rather than combining them.

### Research Integration

Key findings from research-001.md integrated:
- Ability modals (Can_a, Able_a, Cannot_a) concern what agents can bring about through their capacities
- Free choice modals (FP, FF, Ch) concern permission distribution over disjunctive alternatives
- These are conceptually distinct: ability without permission and permission without ability are both possible
- STIT operators (stit_a, dstit_a) are optional but valuable additions

## Goals & Non-Goals

**Goals**:
- Add Abilities box with ability operators (Can_a, Able_a) to TikZ diagram middle layer
- Add Choice box with free choice operators (FP, Ch) to TikZ diagram middle layer
- Update ASCII diagram in README.md to include both new boxes
- Maintain visual balance and readability of the diagram
- Update Layer Descriptions section to include both new extensions

**Non-Goals**:
- Implementing the Lean code for these operators (already documented in GLOSSARY.md)
- Adding STIT operators (deferred as optional enhancement)
- Modifying the semantic specification in recursive-semantics.md

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TikZ layout becomes crowded with 5 middle boxes | M | M | Use consistent smallbox styling, adjust spacing |
| Ellipsis positioning unclear with 5 boxes | L | L | Keep ellipsis on right side only as current |
| README ASCII diagram hard to fit 5 boxes | M | M | May need to adjust column widths or use 2-row layout |

## Implementation Phases

### Phase 1: Update TikZ Diagram [COMPLETED]

**Goal**: Add Abilities and Choice boxes to the middle layer of the TikZ diagram in 00-Introduction.tex

**Tasks**:
- [ ] Add Abilities smallbox node with operators (Can_a, Able_a) between Epistemic and Normative
- [ ] Add Choice smallbox node with operators (FP, Ch) between Normative and Spatial
- [ ] Adjust horizontal positioning of all five middle boxes for visual balance
- [ ] Verify grey background box (middlebox) still fits all nodes including ellipsis
- [ ] Compile and verify diagram renders correctly without overfull hbox warnings

**Timing**: 45 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/00-Introduction.tex` - Add two new smallbox nodes

**Verification**:
- pdflatex compiles without errors
- All five boxes visible in middle layer
- Arrows from Explanatory to middle box and from middle box to bottom layers render correctly
- No overlapping elements or cut-off text

---

### Phase 2: Update README ASCII Diagram [COMPLETED]

**Goal**: Add Abilities and Choice boxes to the ASCII architecture diagram in README.md

**Tasks**:
- [ ] Add Abilities extension box to middle layer row
- [ ] Add Choice extension box to middle layer row
- [ ] Adjust box widths if needed for line length constraints (~80 chars)
- [ ] Update bullet descriptions for both new extensions

**Timing**: 30 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/README.md` - Update ASCII diagram and extension descriptions

**Verification**:
- Markdown renders correctly in GitHub preview
- All five middle extensions visible
- Line lengths reasonable (not excessively long)
- Extension descriptions accurate per research findings

---

### Phase 3: Update Layer Descriptions [COMPLETED]

**Goal**: Add descriptions for Abilities and Choice extensions to the Layer Descriptions section

**Tasks**:
- [ ] Add Abilities Extension description to enumerated list in sec:layer-descriptions
- [ ] Add Choice Extension description to enumerated list
- [ ] Ensure descriptions align with research findings on conceptual distinctions
- [ ] Verify numbering is correct after additions

**Timing**: 15 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/00-Introduction.tex` - Update Layer Descriptions section

**Verification**:
- LaTeX compiles without errors
- Descriptions are accurate and concise
- Numbering sequential

## Testing & Validation

- [ ] pdflatex builds 00-Introduction.tex without errors or warnings
- [ ] TikZ diagram displays all 5 middle extension boxes clearly
- [ ] Grey background box encompasses all middle extensions
- [ ] Arrows render correctly without intersections
- [ ] README.md ASCII diagram displays correctly in markdown viewer
- [ ] Both new extension descriptions present and accurate

## Artifacts & Outputs

- Modified: `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/00-Introduction.tex`
- Modified: `/home/benjamin/Projects/ProofChecker/README.md`
- Plan: `.claude/specs/486_add_abilities_box_to_tikz_diagram/plans/implementation-001.md`
- Summary: `.claude/specs/486_add_abilities_box_to_tikz_diagram/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation causes layout issues:
1. Revert to previous commit using `git checkout HEAD~1 -- Theories/Logos/latex/subfiles/00-Introduction.tex README.md`
2. Consider alternative layouts: stacking middle boxes in 2 rows, or reducing operator count per box
3. If 5 boxes too crowded, consider combining Abilities and Choice into single "Agency" box as fallback
