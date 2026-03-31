# Implementation Plan: Task #77 — ROADMAP.md Update (Logic Weakening Discouragement)

- **Task**: 77 - research_preorder_taskframe_generalization
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_team-research.md, reports/02_time-shift-analysis.md, reports/05_team-research.md
- **Artifacts**: plans/01_roadmap-update.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown

## Overview

This is a documentation-only task to update ROADMAP.md with findings from task 77 research. The update will add a section discouraging "logic weakening" approaches (such as using a preorder instead of linear order for D), clarifying that this path does not solve the F/P completeness blocker and creates exotic multi-dimensional time semantics. The recommended path remains FMP/filtration for TM completeness.

### Research Integration

Key findings from reports 01, 02, and 05:

1. **Category Error**: Prior proposals conflated durations (D) with world states (CanonicalMCS)
2. **Partial Order D = Multi-Dimensional Time**: Not branching time, but 2D temporal cones
3. **F/P Blocker Independent of Linearity**: Arises from omega-saturation, not order structure
4. **FMP/Filtration Remains the Viable Path**: Bounds F-obligations via quotient structure

## Goals & Non-Goals

**Goals**:
- Add a clear section to ROADMAP.md discouraging logic weakening approaches
- Reference the task 77 research findings explaining WHY weakening doesn't help
- Clarify that FMP/filtration is the recommended completeness path
- Briefly explain what partial order D actually creates (multi-dimensional time)

**Non-Goals**:
- Modifying any Lean code
- Changing the existing completeness architecture
- Pursuing preorder TaskFrame as a viable alternative

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ROADMAP.md structure changes | Low | Low | Read current structure before editing |
| Over-explanation clutters roadmap | Medium | Medium | Keep section concise (15-25 lines) |

## Implementation Phases

### Phase 1: Add Logic Weakening Discouragement Section [NOT STARTED]

**Goal**: Add a new section to ROADMAP.md that documents why weakening TM to a preorder-based logic is not a viable path to completeness.

**Tasks**:
- [ ] Read current ROADMAP.md structure to identify appropriate insertion point
- [ ] Create new section "## Investigated Dead Ends: Logic Weakening" after "Temporal Coherence Resolution" section
- [ ] Document the category error (D vs WorldState distinction)
- [ ] Explain that partial order D creates multi-dimensional time, not branching time
- [ ] State that the F/P blocker is independent of D's order structure
- [ ] Reference task 77 reports for detailed analysis
- [ ] Affirm FMP/filtration as the recommended path

**Timing**: 20 minutes

**Files to modify**:
- `ROADMAP.md` — Add new section (~20-30 lines)

**Verification**:
- [ ] New section is clearly marked as a discouragement
- [ ] References research reports for those wanting details
- [ ] Does not modify existing sections' content
- [ ] Maintains consistent Markdown formatting

---

### Phase 2: Verify and Commit [NOT STARTED]

**Goal**: Verify the update is well-integrated and commit changes.

**Tasks**:
- [ ] Re-read ROADMAP.md to ensure section flows well
- [ ] Check that references to task 77 reports are correct
- [ ] Verify no accidental modifications to other sections

**Timing**: 10 minutes

**Verification**:
- [ ] ROADMAP.md builds/renders correctly
- [ ] Section placement makes logical sense in document flow

## Testing & Validation

- [ ] ROADMAP.md renders correctly in Markdown viewer
- [ ] New section provides clear guidance to future readers
- [ ] References to reports 01, 02, 05 are accurate
- [ ] Document flow is logical (dead ends after working approaches)

## Artifacts & Outputs

- `ROADMAP.md` — Updated with logic weakening discouragement section
- `specs/077_research_preorder_taskframe_generalization/summaries/01_roadmap-update-summary.md` — Execution summary

## Rollback/Contingency

If the update is deemed inappropriate:
- `git checkout -- ROADMAP.md` restores original
- Changes are isolated to a single file, easily reversible

## Proposed Content

The new section should contain approximately the following (to be adapted during implementation):

```markdown
## Investigated Dead Ends: Logic Weakening (Task 77)

**Conclusion**: Weakening TM by using a preorder (instead of linear order) for D does NOT
provide a viable path to completeness. The F/P witness blocker is independent of the order
structure on D.

### Key Findings

1. **Category Error**: Prior proposals that suggested "D = CanonicalMCS" conflated durations
   (D, an ordered abelian group) with world states (MCS). These are categorically distinct.

2. **Partial Order D Creates Multi-Dimensional Time**: If D is partially ordered (e.g., Z × Z),
   histories span 2D convex regions, not branching timelines. G(φ) becomes "φ in the entire
   future cone" — a fundamentally different temporal logic, not a natural weakening of TM.

3. **Only temp_linearity Requires Linearity**: All other TM axioms (MF, TF, temp_4, modal K, S5)
   work with preorder D. But dropping temp_linearity creates exotic semantics without solving
   the completeness challenge.

4. **F/P Blocker is Structural**: The blocker arises from omega-saturation in canonical model
   construction (unbounded F-obligations in a single coherent timeline), not from the order
   structure on D. Weakening D provides no advantage.

**Recommendation**: Pursue FMP/filtration for TM completeness. The quotient structure bounds
F-obligations, which is the only known way to resolve the blocker.

**Reference**: `specs/077_research_preorder_taskframe_generalization/reports/05_team-research.md`
```
