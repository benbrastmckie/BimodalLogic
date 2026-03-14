# Implementation Plan: Branch Comparison Decision and Task Coordination

- **Task**: 966 - branch_comparison_duration_group_refactor
- **Status**: [NOT STARTED]
- **Effort**: 1-2 hours
- **Dependencies**: None (decision task)
- **Research Inputs**:
  - specs/966_branch_comparison_duration_group_refactor/reports/research-001.md
  - specs/966_branch_comparison_duration_group_refactor/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This is a META/decision task that formalizes the adoption of the `forward_comp + converse` axiomatization proposed in branch `claude/duration-group-construction-SFEJg`. Research-002 provides rigorous mathematical verification confirming:

1. Full mixed-sign compositionality is impossible for relational canonical models
2. The converse axiom correctly expresses group inverse relationship in duration group D
3. backward_comp is derivable from forward_comp + converse
4. Guardless respects_task is sound with converse
5. ShiftClosed gap is independent of compositionality question

The implementation involves documenting the decision, verifying artifact renumbering is complete, and ensuring follow-up tasks (967, 968, 969) are properly coordinated.

### Research Integration

**From research-001.md**: Full comparison of branch vs main approaches, recommendation to adopt branch artifacts renumbered, defer Lean implementation until after task 956.

**From research-002.md**: Mathematical verification of all core claims, optimal axiomatization is `nullity_identity + forward_comp + converse`, 7-phase implementation plan validated.

## Goals & Non-Goals

**Goals**:
- Document the formal decision to adopt `forward_comp + converse` axiomatization
- Verify all branch artifacts have been correctly renumbered to avoid conflicts
- Ensure tasks 967, 968, 969 are properly configured with correct dependencies
- Update task 966 description with final decision and next steps

**Non-Goals**:
- Implementing the TaskFrame refactor (that is task 969)
- Making any Lean code changes (tasks 967, 968, 969 handle those)
- Modifying the branch itself (branch will not be merged, only artifacts adopted)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Artifact renumbering incomplete | L | L | Phase 2 verifies all artifacts are in place |
| Task dependencies misconfigured | M | L | Phase 3 audits dependencies against research findings |
| Task 956 conflicts | H | M | Coordinate: 969 depends on 966, which depends on 956 reaching stable phase |

## Implementation Phases

### Phase 1: Decision Documentation [NOT STARTED]

- **Dependencies:** None
- **Goal:** Create formal decision record adopting forward_comp + converse

**Tasks:**
- [ ] Create decision summary in task 966 completion summary
- [ ] Document key findings from research-002:
  - Impossibility of full mixed-sign compositionality for relational models
  - Converse axiom expresses group inverse correctly
  - backward_comp derivable from forward_comp + converse
  - Guardless respects_task is sound
  - ShiftClosed gap independent (handled by task 968)
- [ ] Document recommended axiomatization: `nullity_identity + forward_comp + converse`

**Timing:** 15 minutes

**Files to modify:**
- `specs/state.json` - Update task 966 completion_summary
- `specs/TODO.md` - Mark task 966 complete with decision

**Verification:**
- Decision documented in completion_summary
- Task status updated to completed

---

### Phase 2: Artifact Renumbering Verification [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Verify all branch artifacts have been correctly adopted and renumbered

**Tasks:**
- [ ] Verify branch artifacts are present on main:
  - `specs/0_shift_closure_research/` - unnumbered research (CHECK)
  - `specs/research_sign_elimination/` - unnumbered research (CHECK)
  - `specs/962_algebraic_structure_sign_free_task_frame/` - branch artifact (on main, no conflict)
  - `specs/963_duration_group_taskframe_refactor/` - branch artifact (on main, no conflict)
- [ ] Verify task number mapping is clear:
  - Branch task 962 (paper footnote) - not adopted (ShiftClosed gap now in task 968)
  - Branch task 963 (TaskFrame refactor) - content adopted into tasks 967, 968, 969
- [ ] Document any artifacts that were NOT adopted and why

**Timing:** 15 minutes

**Files to modify:**
- None (verification only)

**Verification:**
- All expected artifacts present
- No task number conflicts on main

---

### Phase 3: Task Dependency Audit [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Verify tasks 967, 968, 969 have correct dependencies and descriptions

**Tasks:**
- [ ] Audit task 967 (change_atom_type_for_freshness):
  - Status: researched (correct)
  - Dependencies: none (correct - foundational refactor)
  - Description: covers Atom type change for freshness
- [ ] Audit task 968 (prove_shift_closure_canonical_fmcs_bridge):
  - Status: not_started (correct)
  - Dependencies: [967, 969] (verify correctness)
  - Description: covers ShiftClosed proof and BFMCS bridge
- [ ] Audit task 969 (refactor_taskframe_restrict_compositionality):
  - Status: not_started (correct)
  - Dependencies: [966] (verify correctness)
  - Description: covers TaskFrame forward_compositionality refactor
- [ ] Verify dependency chain is coherent:
  - 966 (decision) -> 969 (TaskFrame refactor)
  - 967 (Atom type) + 969 (TaskFrame) -> 968 (ShiftClosed bridge)

**Timing:** 15 minutes

**Files to modify:**
- `specs/state.json` - Fix any dependency issues found
- `specs/TODO.md` - Update if needed

**Verification:**
- All three tasks have correct status, language, priority
- Dependency chain is acyclic and coherent
- Descriptions align with research findings

---

### Phase 4: Coordination Notes [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Document coordination requirements with task 956 and other active tasks

**Tasks:**
- [ ] Document task 956 interaction:
  - Task 956 (construct D as translation group) is actively implementing
  - Task 969 depends on 966 but should wait for 956 to reach stable phase boundary
  - The forward_comp + converse formulation SIMPLIFIES 956's canonical_task_rel proof
- [ ] Document implementation sequence:
  - First: Complete 966 (this decision task)
  - Next: Wait for 956 phase 7 completion OR proceed if independent
  - Then: Implement 969 (TaskFrame refactor)
  - Parallel: Implement 967 (Atom type - independent of 969)
  - Finally: Implement 968 (ShiftClosed bridge - depends on 967 + 969)
- [ ] Create completion summary noting the coordinated plan

**Timing:** 15 minutes

**Files to modify:**
- `specs/966_branch_comparison_duration_group_refactor/summaries/implementation-summary-20260314.md` (create)

**Verification:**
- Coordination notes documented
- Implementation sequence clear
- No blocking circular dependencies

---

## Testing & Validation

- [ ] All tasks 967, 968, 969 exist in state.json with correct fields
- [ ] All research artifacts are accessible at documented paths
- [ ] Decision documented in completion_summary
- [ ] No task number conflicts remain

## Artifacts & Outputs

- `specs/966_branch_comparison_duration_group_refactor/plans/implementation-001.md` (this file)
- `specs/966_branch_comparison_duration_group_refactor/summaries/implementation-summary-20260314.md` (to be created in Phase 4)

## Rollback/Contingency

This is a decision task with no code changes. Rollback is trivial:
- Revert state.json changes if decision needs revisiting
- Tasks 967, 968, 969 can be modified or abandoned if research conclusions change
