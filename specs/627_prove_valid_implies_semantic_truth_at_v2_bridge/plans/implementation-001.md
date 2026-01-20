# Implementation Plan: Task #627

- **Task**: 627 - Prove valid_implies_semantic_truth_at_v2 bridge for Strategy A completeness
- **Status**: [ABANDONED]
- **Effort**: 0.5 hours (decision) OR 8-12 hours (full implementation)
- **Priority**: High (but optional for completeness)
- **Dependencies**: Tasks 470 (FMP), 608 (representation architecture), 610 (upward bridge research)
- **Research Inputs**: specs/627_prove_valid_implies_semantic_truth_at_v2_bridge/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan addresses the "downward" bridge theorem `valid phi -> (forall w, semantic_truth_at_v2 phi w t phi)`. Research-001.md conclusively found that **this bridge is NOT required** for the completeness proof. The existing architecture establishes `valid phi <-> Nonempty (phi)` via `main_provable_iff_valid_v2` (PROVEN) using `semantic_weak_completeness` which avoids this bridge entirely.

### Research Integration

From research-001.md:
- `main_provable_iff_valid_v2` is PROVEN via `semantic_weak_completeness`
- The "downward bridge" would require the SAME hard work as task 610 (upward bridge)
- Both bridges require proving `truth_at <-> models` correspondence for Box and temporal operators
- The completeness proof chain is already complete without this bridge

## Goals & Non-Goals

**Goals**:
- Make a clear architectural decision: ABANDON or PROCEED
- If ABANDON: Document reasoning and mark task as not required
- If PROCEED: Define phases equivalent to task 610 complexity

**Non-Goals**:
- This plan does NOT assume implementation will proceed
- Not attempting to simplify the bridge (research shows it has full 610 complexity)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Wasted effort on unnecessary proof | High | High (if proceeding) | Recommend abandonment |
| Missing theoretical elegance | Low | N/A | Document why bridge exists conceptually |
| Misunderstanding completeness architecture | Medium | Low | Research thoroughly documented the proof chain |

## Implementation Phases

### Phase 1: Decision Point [COMPLETED]

**Goal**: Determine whether to abandon this task or proceed with full implementation

**Tasks**:
- [x] Review research findings with stakeholder
- [x] Confirm completeness proof chain is complete via `main_provable_iff_valid_v2`
- [x] Decide: **ABANDON** (recommended) - Completeness is achieved without this bridge

**Decision (2026-01-19)**: ABANDON. Research conclusively showed this bridge is not required for completeness. The `main_provable_iff_valid_v2` theorem already establishes `valid phi <-> Nonempty (Proof phi)` via `semantic_weak_completeness`. Implementing this bridge would require 8-12 hours of hard work on Box and temporal cases with no capability gained.

**Timing**: 0.5 hours

**Decision Criteria**:
- **ABANDON if**: Completeness is the only goal (it is already achieved)
- **PROCEED if**: Theoretical completeness of all proof paths is desired

**Verification**:
- Decision is documented
- Task status updated appropriately

---

### Phase 2: (IF PROCEEDING) Instantiate Validity [NOT STARTED]

**Goal**: Apply `valid phi` to `SemanticCanonicalModel phi`

**Tasks**:
- [ ] Prove `valid_at_semantic_canonical`: `valid phi -> forall tau t, truth_at (SemanticCanonicalModel phi) tau t phi`
- [ ] This is direct instantiation of the validity definition

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/SemanticCanonicalModel.lean` - Add instantiation lemma

**Verification**:
- Lemma compiles without sorries
- Type signature matches expected form

---

### Phase 3: (IF PROCEEDING) Connect WorldHistories to SemanticWorldStates [NOT STARTED]

**Goal**: Show each SemanticWorldState has a WorldHistory passing through it

**Tasks**:
- [ ] Use existing `semantic_world_state_has_world_history` or prove if missing
- [ ] Show for any `w : SemanticWorldState phi`, there exists `tau` with `tau 0 = [w]`
- [ ] Connect instantiated validity to specific world states

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/SemanticCanonicalModel.lean` - Add connectivity lemmas

**Verification**:
- Connectivity lemmas compile
- Can apply `valid_at_semantic_canonical` to specific world states

---

### Phase 4: (IF PROCEEDING) Bridge truth_at to models [NOT STARTED]

**Goal**: Prove the core bridge `truth_at M tau t phi -> w.models phi h_mem`

**Tasks**:
- [ ] Prove by structural induction on `phi`
- [ ] Handle Atom case: valuation check (straightforward)
- [ ] Handle Bot case: trivial
- [ ] Handle Imp case: IH on subformulas
- [ ] Handle Box case: canonical MCS propagation lemma (HARD)
- [ ] Handle temporal cases: bounded relevance lemma (HARD)

**Timing**: 4-6 hours (this is the hard phase)

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/SemanticCanonicalModel.lean` - Add bridge theorem

**Dependencies**: This phase has the same complexity as task 610

**Verification**:
- Bridge theorem compiles without sorries
- All inductive cases handled

---

### Phase 5: (IF PROCEEDING) Assemble Final Theorem [NOT STARTED]

**Goal**: Combine phases to prove `valid_implies_semantic_truth_at_v2`

**Tasks**:
- [ ] Assemble instantiation + connectivity + bridge
- [ ] Prove final theorem statement
- [ ] Clean up and document

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/SemanticCanonicalModel.lean` - Add final theorem

**Verification**:
- `valid_implies_semantic_truth_at_v2` compiles without sorries
- Theorem integrates cleanly with existing architecture

---

## Testing & Validation

- [ ] `lake build` passes with no new sorries
- [ ] Theorem statement matches task description
- [ ] Documentation updated to reflect new proof path (if proceeding)

## Artifacts & Outputs

**If ABANDONED**:
- Updated TODO.md with abandonment note
- Updated state.json status

**If COMPLETED**:
- `Theories/Bimodal/Metalogic_v2/SemanticCanonicalModel.lean` with new theorem
- `specs/627_prove_valid_implies_semantic_truth_at_v2_bridge/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If bridge proof becomes intractable:
- Abandon at any phase (no dependencies on this theorem)
- Mark task as not required with reference to research findings
- Document conceptual importance without implementation

## Recommendation

**ABANDON this task**. The research clearly shows:
1. Completeness is already proven via `main_provable_iff_valid_v2`
2. The bridge requires 8-12 hours of hard work on Box and temporal cases
3. The result provides no additional capability beyond theoretical elegance

Consider merging with task 610 if both bridges are desired for theoretical completeness, as they share the same core challenge: proving `truth_at <-> models` correspondence.
