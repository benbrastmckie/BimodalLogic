# Implementation Plan: Task #473

- **Task**: 473 - Fix compositionality gaps from Task 458
- **Status**: [IN PROGRESS]
- **Version**: 002
- **Effort**: 10-14 hours
- **Priority**: Medium
- **Dependencies**: Task 472 (Lindenbaum extension - COMPLETED)
- **Research Inputs**:
  - .claude/specs/473_fix_compositionality_gaps_task_458/reports/research-001.md
  - .claude/specs/473_fix_compositionality_gaps_task_458/reports/research-002.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**Revision 002** restructures the approach based on research-002.md findings. Instead of accepting compositionality gaps as limitations (as in v001), this plan implements the **time-shift-based witness construction** approach inspired by the JPL paper's `lem:history-time-shift-preservation` and `app:auto_existence`.

### Key Insight from Research

The pointwise transfer approach fails for mixed-sign duration cases because endpoint formula membership doesn't encode the relationship between total displacement and formula truth. The time-shift approach avoids compositionality issues entirely by:

1. Using **semantic history construction** instead of pointwise formula transfer
2. Leveraging the existing `time_shift_preserves_truth` theorem from Truth.lean
3. Defining task relation via history existence rather than formula conditions

### Strategy Change from v001

| Aspect | v001 (Pointwise) | v002 (Time-Shift) |
|--------|------------------|-------------------|
| Task relation | Formula transfer conditions | History existence |
| Compositionality | Accept gaps as limitations | Trivially satisfied |
| Witnesses | Lindenbaum extension on formulas | Time-shift construction |
| Core tool | `closure_mcs_negation_complete` | `time_shift_preserves_truth` |

## Goals & Non-Goals

**Goals**:
- Restructure `finite_task_rel` to use semantic history-based definition
- Implement `finite_time_shift` construction for witness generation
- Prove compositionality trivially via history composition
- Complete truth lemma using time-shift preservation
- Eliminate ALL compositionality sorry gaps (not just document them)

**Non-Goals**:
- Preserve backward compatibility with pointwise approach
- Maintain current sorry gap structure (we're eliminating them)
- Incremental fixes (this is a structural refactor)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Finite domain time-shift complexity | High | Medium | Careful modular arithmetic handling |
| History construction bootstrapping | High | Medium | Leverage existing WorldHistory.time_shift |
| Type universe issues with histories | Medium | Low | Use same universe as existing code |
| Larger refactor scope | Medium | High | Phase incrementally, verify each step |

## Implementation Phases

### Phase 1: Time-Shift Infrastructure [NOT STARTED]

**Goal**: Add finite-domain time-shift construction matching `WorldHistory.time_shift`

**Tasks**:
- [ ] Study `WorldHistory.time_shift` at WorldHistory.lean:236 for pattern
- [ ] Define `FiniteHistory.time_shift` with domain translation
- [ ] Prove domain bounds preserved under finite time-shift
- [ ] Prove `finite_time_shift_respects_task` - task relation preserved

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Add FiniteHistory.time_shift section

**Key implementation pattern** (from WorldHistory.lean:236):
```lean
def time_shift (sigma : WorldHistory F) (Delta : D) : WorldHistory F where
  domain := fun z => sigma.domain (z + Delta)
  convex := ... -- preserved under translation
  states := fun z hz => sigma.states (z + Delta) hz
  respects_task := ... -- preserved since duration unchanged
```

**Verification**:
- `FiniteHistory.time_shift` compiles without sorry
- Can shift any finite history by any integer within bounds

---

### Phase 2: Semantic Task Relation [NOT STARTED]

**Goal**: Replace pointwise `finite_task_rel` with history-existence definition

**Tasks**:
- [ ] Define `finite_task_rel_semantic`:
  ```lean
  def finite_task_rel_semantic (phi : Formula) (w : FiniteWorldState phi)
      (d : Int) (u : FiniteWorldState phi) : Prop :=
    exists (h : FiniteHistory phi) (t : FiniteTime),
      h.states t = w /\ h.states (t + d) = u
  ```
- [ ] Prove equivalence for same-sign cases (connects to existing proofs)
- [ ] Delete or deprecate old `finite_task_rel` definition
- [ ] Update all references to use new definition

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Replace task relation

**Verification**:
- New definition compiles
- Existing same-sign lemmas still work (possibly with adaptation)

---

### Phase 3: Compositionality Proof [NOT STARTED]

**Goal**: Prove compositionality trivially via history concatenation/windowing

**Tasks**:
- [ ] Prove `finite_task_rel_semantic_compositionality`:
  ```lean
  theorem compositionality :
    finite_task_rel_semantic phi w x u ->
    finite_task_rel_semantic phi u y v ->
    finite_task_rel_semantic phi w (x + y) v
  ```
- [ ] The proof is trivial: if h1 witnesses (w, x, u) at time t1, and h2 witnesses (u, y, v) at time t2, then time-shifting h2 to align at t1+x gives a single history through all three
- [ ] Remove all 8 compositionality sorries from v001

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Compositionality section

**Verification**:
- `compositionality` theorem compiles without sorry
- All mixed-sign cases handled by same proof

---

### Phase 4: Existence Theorems via Time-Shift [NOT STARTED]

**Goal**: Prove existence theorems using time-shift construction instead of Lindenbaum

**Tasks**:
- [ ] Revise `finite_forward_existence_thm`:
  - Given state w at time t, construct a history h through w
  - Time-shift to get state at t+1
  - Witness: h.states (t+1)
- [ ] Revise `finite_backward_existence_thm` similarly
- [ ] The key: we don't need to construct a *new* consistent set; we extract from existing history

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Existence section

**Verification**:
- Existence theorems compile without sorry
- Can invoke from truth lemma proofs

---

### Phase 5: Truth Lemma Refactor [NOT STARTED]

**Goal**: Refactor truth lemma to use time-shift preservation

**Tasks**:
- [ ] For temporal cases, use pattern from JPL paper's app:valid:
  1. Suppose backward direction fails (contrapositive)
  2. Construct witness history via time-shift
  3. Apply `time_shift_preserves_truth` (Truth.lean:311)
  4. Derive contradiction with semantic truth
- [ ] Implication case: use closure_mcs properties (from v001)
- [ ] Box case: use canonical property (from v001)
- [ ] Fill remaining backward-direction sorries

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Truth Lemma section

**Key theorem from Truth.lean:311**:
```lean
theorem time_shift_preserves_truth (M : TaskModel F) (sigma : WorldHistory F)
    (x y : D) (phi : Formula) :
    truth_at M (WorldHistory.time_shift sigma (y - x)) x phi <->
    truth_at M sigma y phi
```

**Verification**:
- Truth lemma compiles with zero or minimal sorries
- All connective cases have both directions

---

### Phase 6: History Construction Completion [NOT STARTED]

**Goal**: Complete history construction using new existence theorems

**Tasks**:
- [ ] Fill `finite_history_from_state` using time-shift existence
- [ ] Verify recursive construction terminates (finite time domain)
- [ ] Ensure history satisfies all task relation requirements

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - History Construction section

**Verification**:
- `finite_history_from_state` returns valid history without sorry
- History can be used in completeness theorem

---

### Phase 7: Final Verification and Cleanup [NOT STARTED]

**Goal**: Verify complete build and document approach

**Tasks**:
- [ ] Run full `lake build` and verify reduction in sorries
- [ ] Remove deprecated pointwise infrastructure
- [ ] Update docstrings to reflect time-shift approach
- [ ] Create implementation summary documenting the refactor

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Cleanup
- Summary artifact

**Verification**:
- Clean build
- Sorry count significantly reduced (target: <5 sorries, ideally 0)
- Approach documented for future reference

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Completeness.FiniteCanonicalModel` succeeds
- [ ] Compositionality proven without sorry (all 8 mixed-sign cases)
- [ ] Truth lemma backward directions work via time-shift
- [ ] Existence theorems use time-shift construction
- [ ] History construction complete

## Artifacts & Outputs

- plans/implementation-002.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (completion summary)
- Modified: `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

## Comparison with v001

| Phase | v001 Approach | v002 Approach |
|-------|---------------|---------------|
| 1 | Derivation infrastructure | Time-shift infrastructure |
| 2 | Local consistency bridge | Semantic task relation |
| 3 | Truth lemma via negation-completeness | Compositionality proof (trivial) |
| 4 | Existence via Lindenbaum | Existence via time-shift |
| 5 | History construction | Truth lemma via time-shift |
| 6 | Compositionality documentation | History construction |
| 7 | Final verification | Final verification |

**Key difference**: v001 accepted compositionality gaps and worked around them. v002 eliminates them by restructuring the fundamental approach.

## Rollback/Contingency

If time-shift refactor proves too invasive:
1. Revert to v001 approach (accept gaps as limitations)
2. The v001 plan remains valid as fallback
3. Document time-shift as "ideal approach for future work"

If specific phases fail:
1. Phases 1-3 are interdependent (time-shift + semantic relation + compositionality)
2. Phases 4-6 can fall back to v001 approach if needed
3. Phase 7 adapts to whatever was accomplished
