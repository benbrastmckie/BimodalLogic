# Implementation Plan: Task #77 — ROADMAP.md Update (Logic Weakening Discouragement)

- **Task**: 77 - research_preorder_taskframe_generalization
- **Version**: 2 (revised)
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_team-research.md, reports/02_time-shift-analysis.md, reports/05_team-research.md
- **Artifacts**: plans/02_roadmap-update-revised.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown

## Revision Notes

**Previous Plan**: 01_roadmap-update.md
**Revision Reason**: The previous plan incorrectly recommended FMP/filtration as the completeness path. This undermines the representation theorem goal, which aims to characterize different subsystems:

> "TM is the logic of TaskFrames over [specific frame class]"

FMP/filtration is a generic technique that proves finite model property for any logic, but does NOT provide a characterization theorem relating TM to a specific semantic class. The representation theorem approach is essential for understanding WHAT TM characterizes.

## Overview

This is a documentation-only task to update ROADMAP.md with findings from task 77 research. The update will add a section discouraging "logic weakening" approaches (such as using a preorder instead of linear order for D), while:

1. **NOT recommending FMP/filtration** as an alternative (since it doesn't give characterization)
2. **Clarifying the representation theorem goal** — we want to know WHAT frame class TM corresponds to
3. **Documenting why preorder D is a dead end** — creates multi-dimensional time, not branching time
4. **Acknowledging the open challenge** — canonical completeness with characterization remains unsolved

### Research Integration

Key findings from reports 01, 02, and 05:

1. **Category Error**: Prior proposals conflated durations (D) with world states (CanonicalMCS)
2. **Partial Order D = Multi-Dimensional Time**: Not branching time, but 2D temporal cones
3. **F/P Blocker Independent of Linearity**: Arises from omega-saturation, not order structure
4. **Characterization Goal**: We want "TM = logic of TaskFrames over LOAGs" style theorems

## Goals & Non-Goals

**Goals**:
- Add a clear section to ROADMAP.md discouraging logic weakening approaches
- Reference the task 77 research findings explaining WHY weakening doesn't help
- Clarify that the goal is representation theorems (characterizing frame classes)
- Acknowledge that canonical completeness for TM remains an open challenge
- Briefly explain what partial order D actually creates (multi-dimensional time)

**Non-Goals**:
- Recommending FMP/filtration (this is a fallback, not a solution to characterization)
- Modifying any Lean code
- Changing the existing completeness architecture
- Pursuing preorder TaskFrame as a viable alternative

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ROADMAP.md structure changes | Low | Low | Read current structure before editing |
| Over-explanation clutters roadmap | Medium | Medium | Keep section concise (20-30 lines) |

## Implementation Phases

### Phase 1: Add Logic Weakening Discouragement Section [NOT STARTED]

**Goal**: Add a new section to ROADMAP.md that documents why weakening TM to a preorder-based logic is not a viable path to completeness, while clarifying the representation theorem goal.

**Tasks**:
- [ ] Read current ROADMAP.md structure to identify appropriate insertion point
- [ ] Create new section "## Investigated Dead Ends: Logic Weakening" after existing completeness sections
- [ ] Document the category error (D vs WorldState distinction)
- [ ] Explain that partial order D creates multi-dimensional time, not branching time
- [ ] State that the F/P blocker is independent of D's order structure
- [ ] Clarify the representation theorem goal (characterizing frame classes, not just FMP)
- [ ] Acknowledge canonical completeness for TM remains an open challenge
- [ ] Reference task 77 reports for detailed analysis

**Timing**: 20 minutes

**Files to modify**:
- `ROADMAP.md` — Add new section (~25-35 lines)

**Verification**:
- [ ] New section is clearly marked as a discouragement
- [ ] Does NOT recommend FMP/filtration as an alternative
- [ ] Clarifies that representation theorem approach is the goal
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
- [ ] ROADMAP.md renders correctly in Markdown viewer
- [ ] Section placement makes logical sense in document flow

## Testing & Validation

- [ ] ROADMAP.md renders correctly in Markdown viewer
- [ ] New section provides clear guidance to future readers
- [ ] Does not recommend FMP/filtration as a replacement
- [ ] Acknowledges open challenge of representation-style completeness
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

### Representation Theorem Goal

The goal of TM completeness is a **representation theorem** characterizing the frame class:

> "TM is complete with respect to TaskFrames over totally ordered abelian groups."

This tells us WHAT semantic class TM corresponds to. FMP/filtration techniques can prove
decidability or finite model property, but do not provide this characterization.

The canonical completeness approach (building a single countermodel from MCS) is the path to
representation theorems. The F/P witness blocker remains an open challenge in this approach.

**Reference**: `specs/077_research_preorder_taskframe_generalization/reports/05_team-research.md`
```
