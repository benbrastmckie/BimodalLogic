# Implementation Plan: Task #482

- **Task**: 482 - Implement history gluing lemma
- **Status**: [NOT STARTED]
- **Effort**: 4-5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: .claude/specs/482_history_gluing_lemma/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implement the history gluing lemma to compose two `FiniteHistory` structures that share a common `SemanticWorldState` at their junction point. This eliminates the 2 sorries in `SemanticTaskRelV2.compositionality` (lines 2211 and 2214 in FiniteCanonicalModel.lean). The approach uses piecewise construction where the glued history uses `h1` states before the junction and `h2` states after, with careful bounds checking to ensure the result remains within the finite time domain.

### Research Integration

Key findings from research-001.md:
- Strategy A (piecewise construction) selected as most general approach
- Junction consistency proven by showing `FiniteWorldState` equality implies unit-step relation compatibility
- Bounds case (neg) likely impossible in completeness context - may use contradiction or acceptable sorry

## Goals & Non-Goals

**Goals**:
- Define `glue_histories` function to construct glued `FiniteHistory` from two histories sharing a junction state
- Prove junction consistency lemmas (`junction_forward_consistent`, `junction_backward_consistent`)
- Prove glued history satisfies `forward_rel` and `backward_rel` properties
- Connect gluing to `SemanticTaskRelV2.compositionality` theorem to eliminate sorries
- Verify `lake build` succeeds with no new sorries in FiniteCanonicalModel.lean

**Non-Goals**:
- Optimizing for computational efficiency (noncomputable is acceptable)
- Handling the impossible bounds case (neg) with full proof (acceptable sorry if needed)
- Generalizing beyond the specific completeness proof context

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Offset arithmetic complexity | High | Medium | Define clear helper functions for time offset calculations |
| Bounds checking failures | Medium | Medium | Add explicit bounds lemmas before main construction |
| Junction consistency gap | High | Low | Prove via `FiniteWorldState` equality semantics |
| Type unification issues | Medium | Medium | Use explicit type annotations throughout |
| Neg case blocking | Low | Low | Mark as acceptable sorry if contradiction not provable |

## Implementation Phases

### Phase 1: Helper Definitions and Bounds Lemmas [IN PROGRESS]

**Goal**: Define time offset helpers and prove bounds are preserved under gluing operations.

**Tasks**:
- [ ] Define `time_offset_for_gluing` helper to compute offsets between h1/h2 time frames
- [ ] Define `valid_gluing_bounds` predicate capturing when gluing is well-defined
- [ ] Prove `gluing_bounds_pos` lemma: when junction exists, final time is within bounds
- [ ] Prove `time_in_h1_range` and `time_in_h2_range` helper lemmas

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Add new section after `SemanticTaskRelV2` definition

**Verification**:
- All new definitions type-check without errors
- Helper lemmas compile without sorry

---

### Phase 2: Junction Consistency Lemmas [NOT STARTED]

**Goal**: Prove that histories agreeing at the junction point can be composed with consistent unit-step relations.

**Tasks**:
- [ ] Prove `junction_forward_consistent`: if `h1.states t1' = h2.states t2` then forward step from junction in h1 matches h2
- [ ] Prove `junction_backward_consistent`: symmetric for backward steps
- [ ] Prove `consistent_at_junction`: combining forward and backward consistency

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - After Phase 1 additions

**Verification**:
- Junction lemmas compile without sorry
- Lemmas use only the `h_agree` hypothesis and existing history properties

---

### Phase 3: Glue Histories Construction [NOT STARTED]

**Goal**: Define the main `glue_histories` function that constructs a combined history from two histories sharing a junction state.

**Tasks**:
- [ ] Define `glue_histories` noncomputable function with piecewise state definition
- [ ] Prove `glue_histories_forward_rel`: glued history satisfies forward consistency
- [ ] Prove `glue_histories_backward_rel`: glued history satisfies backward consistency
- [ ] Prove `glue_histories_start`: glued history starts at correct state
- [ ] Prove `glue_histories_end`: glued history ends at correct state

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - After Phase 2 additions

**Verification**:
- `glue_histories` returns valid `FiniteHistory phi`
- Start/end lemmas connect to `semantic_task_rel_v2` requirements
- No new sorries introduced

---

### Phase 4: Connect to Compositionality [NOT STARTED]

**Goal**: Use gluing construction to eliminate sorries in `SemanticTaskRelV2.compositionality`.

**Tasks**:
- [ ] Replace sorry at line 2211 (case pos) with gluing construction
- [ ] Address line 2214 (case neg): either prove contradiction or mark as acceptable sorry with comment
- [ ] Verify compositionality theorem compiles without sorry (or with documented acceptable sorry)
- [ ] Run `lake build` to verify no regressions

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Lines 2211-2214 in compositionality proof

**Verification**:
- `lake build` succeeds
- At most one documented sorry remains (for neg case if contradiction not provable)
- All other sorries in compositionality eliminated

---

## Testing & Validation

- [ ] All new definitions type-check (`lean_diagnostic_messages` shows no errors)
- [ ] Junction consistency lemmas proven without sorry
- [ ] `glue_histories` constructs valid `FiniteHistory`
- [ ] Compositionality theorem proven (or neg case documented)
- [ ] `lake build` succeeds with exit code 0
- [ ] No new sorries introduced (verify with grep for "sorry")

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Modified with gluing lemmas
- `.claude/specs/482_history_gluing_lemma/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If gluing approach proves infeasible:
1. Revert changes to FiniteCanonicalModel.lean via `git checkout`
2. Consider Strategy B (same-history observation) as simpler alternative for completeness context
3. Document blocking issue in research report for future reference
4. Mark compositionality sorries as acceptable with detailed comments explaining the mathematical justification
