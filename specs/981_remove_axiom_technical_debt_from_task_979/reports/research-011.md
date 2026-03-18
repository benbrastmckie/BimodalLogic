# Research Report: Task #981 - Remaining Work Assessment Post-Task 991

**Task**: 981 - remove_axiom_technical_debt_from_task_979
**Date**: 2026-03-18
**Session**: sess_1773866020_ba9183
**Focus**: Assess what remains after task 991 completion, identify unnecessary work

---

## Executive Summary

Task 991's completion (irreflexive semantics refactoring) is **orthogonal** to task 981's remaining work. Task 991 addressed the discrete completeness path (DiscreteSuccSeed.lean), while task 981 plan v7 targets the dense completeness path (TimelineQuot). The `discrete_Icc_finite_axiom` remains present and is not affected by task 991.

**Remaining Work**: One sorry in `timelineQuot_not_valid_of_neg_consistent` (TimelineQuotCompleteness.lean:127)

**Recommendation**: Either complete the truth lemma wiring (achieves dense completeness) OR accept current state with comprehensive documentation (all components proven, wiring gap documented). Given publication goals, Option A is preferred if tractable.

---

## Part 1: Current Axiom Status

### 1.1 Axioms in Active Codebase (4 total)

| Axiom | Location | Justification | Used By |
|-------|----------|---------------|---------|
| `discrete_Icc_finite_axiom` | DiscreteTimeline.lean:316 | Interval finiteness for discrete timeline | Discrete completeness only |
| `canonicalR_irreflexive_axiom` | CanonicalIrreflexivity.lean:1212 | Canonical R is irreflexive | General canonical model |
| `discreteImmediateSuccSeed_consistent_axiom` | DiscreteSuccSeed.lean:284 | Seed consistency via seriality | Discrete construction (task 991) |
| `discreteImmediateSucc_covers_axiom` | DiscreteSuccSeed.lean:414 | Covering property (Segerberg/Verbrugge) | Discrete construction (task 991) |

### 1.2 What Task 991 Changed

Task 991 modified the **discrete** completeness infrastructure:
- **Removed**: `g_content_subset_mcs_axiom` (FALSE under strict semantics)
- **Added**: 2 justified axioms (seed consistency + covering)
- **File**: `DiscreteSuccSeed.lean`

This work is on the **discrete** path, while task 981 plan v7 targets the **dense** path.

### 1.3 Impact on Task 981

**None**. The two tasks address different completeness paths:
- Task 981 plan v7: Dense completeness via TimelineQuot (avoid discrete axiom entirely)
- Task 991: Discrete construction with irreflexive semantics

The `discrete_Icc_finite_axiom` remains exactly where it was.

---

## Part 2: Task 981 Plan v7 Status

### 2.1 Phase Status

| Phase | Name | Status | Notes |
|-------|------|--------|-------|
| 1 | Documentation and Deprecation | COMPLETED | W=D constructs deprecated |
| 2 | TaskFrame over TimelineQuot | COMPLETED | `timelineQuotParametricTaskFrame` done |
| 3 | WorldHistory and Omega Construction | COMPLETED | SeparatedHistory infrastructure |
| 4 | Truth Lemma Bridge | **PARTIAL** | Blocked on forward-only truth lemma |
| 5 | Complete Countermodel Theorem | NOT STARTED | Depends on Phase 4 |
| 6 | Axiom Removal and Verification | NOT STARTED | Depends on Phase 5 |

### 2.2 The Blocking Sorry

**Location**: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean:127`

```lean
theorem timelineQuot_not_valid_of_neg_consistent
    (φ : Formula) (h_cons : ContextConsistent [φ.neg]) :
    ...
    ¬@valid_over D acg inferInstance oam φ := by
  intro M₀ h_M₀_mcs D acg oam
  sorry  -- ← THE ONE BLOCKING SORRY
```

This sorry is the single remaining gap between:
- **Piece 1**: All BFMCS/FMCS infrastructure (proven sorry-free)
- **Piece 2**: Dense completeness theorem statement

### 2.3 Why It's Blocked

From research-010: The truth lemma needs adaptation from Int-indexed FMCS to TimelineQuot-indexed FMCS. The challenge is that `parametric_shifted_truth_lemma` uses BFMCS infrastructure with `modal_forward`/`modal_backward`, but a forward-only version is needed for the separated construction.

---

## Part 3: Current Completeness Status

### 3.1 Dense Completeness

| Component | Status | File |
|-----------|--------|------|
| Cantor isomorphism (TimelineQuot ≃o Q) | PROVEN | CantorApplication.lean |
| FMCS construction | PROVEN | CanonicalFMCS.lean |
| Truth lemma (Int-based) | PROVEN | CanonicalConstruction.lean |
| Shifted truth lemma | PROVEN | CanonicalConstruction.lean |
| TimelineQuot TaskFrame | PROVEN | TimelineQuotCanonical.lean |
| Countermodel construction | **SORRY** | TimelineQuotCompleteness.lean:127 |
| `dense_completeness_theorem` | Depends on sorry | TimelineQuotCompleteness.lean:151 |

**Assessment**: All components except the final wiring are sorry-free.

### 3.2 Discrete Completeness

| Component | Status | File |
|-----------|--------|------|
| DiscreteTimelineQuot | PROVEN | DiscreteTimeline.lean |
| LocallyFiniteOrder | **AXIOM** | DiscreteTimeline.lean:316 |
| Discrete seed construction | AXIOM-BACKED | DiscreteSuccSeed.lean |
| `discrete_completeness_theorem` | **SORRY** | Completeness.lean:173 |

**Assessment**: Blocked by `discrete_Icc_finite_axiom` + additional axioms from task 991.

---

## Part 4: Options for Task 981

### Option A: Complete the Truth Lemma Wiring (Recommended)

**Action**: Fill the sorry in `timelineQuot_not_valid_of_neg_consistent`

**Approach** (from research-010):
1. Adapt `parametric_shifted_truth_lemma` to forward-only version
2. Use existing `timelineQuotFMCS` and `SeparatedHistory` infrastructure
3. Build countermodel using Phase 2-3 components

**Effort**: 4-8 hours (adapting existing proofs)
**Outcome**: Full dense completeness proof, axiom-free for dense path
**Value**: HIGH - main completeness result fully mechanized

### Option B: Accept Current State with Documentation

**Action**: Mark task as [COMPLETED] with scope reduction

**Justification**:
- All components are proven sorry-free
- The wiring gap is well-understood and documented
- Dense completeness can be presented as "components proven, assembly documented"
- `discrete_Icc_finite_axiom` is only needed for discrete path (not the main result)

**Effort**: 2-3 hours (documentation updates)
**Outcome**: Honest documentation of current state
**Value**: MODERATE - clears task backlog, acknowledges limitation

### Option C: Abandon and Create Focused Follow-up

**Action**: Mark as [ABANDONED], create "Complete TimelineQuot truth lemma" task

**Justification**:
- Task 981's original scope (remove axiom) evolved significantly
- Plan v7 is a different task than the original
- Fresh task with narrow scope may be clearer

**Effort**: 1 hour (task management)
**Outcome**: Cleaner task tracking
**Value**: LOW - same work needs to happen eventually

---

## Part 5: Recommendation for Publication Readiness

### 5.1 Current State Assessment

| Aspect | Status | Publication Impact |
|--------|--------|-------------------|
| Soundness | SORRY-FREE | Ready |
| Decidability | SORRY-FREE | Ready |
| Dense completeness components | SORRY-FREE | Ready (with caveat) |
| Dense completeness theorem | ONE SORRY | Document as "components proven" |
| Discrete completeness | AXIOM-BACKED | Document as "conditional on axiom" |

### 5.2 For "Highest Quality" Publication

**Recommended Path**: Option A (Complete the truth lemma)

Rationale:
1. Dense completeness is the main result (Int ≃ TimelineQuot ≃ Q)
2. Completing it eliminates all caveats on the primary theorem
3. The work is bounded (one sorry, known structure)
4. Discrete completeness with axioms is acceptable secondary result

### 5.3 For "Ready Now" Publication

**Alternative Path**: Option B (Document current state)

Present as:
1. Soundness: Fully mechanized
2. Decidability: Fully mechanized
3. Dense completeness: All components mechanized, final wiring documented
4. Discrete completeness: Mechanized modulo documented axioms

This is an honest and publishable state.

---

## Part 6: Unnecessary Work Assessment

### 6.1 Work That IS Necessary

- Fill `timelineQuot_not_valid_of_neg_consistent` sorry (if pursuing Option A)
- Update documentation to reflect current state
- Ensure `discrete_Icc_finite_axiom` is properly documented

### 6.2 Work That Is NOT Necessary

- **Removing `discrete_Icc_finite_axiom`**: Not required if dense completeness is the focus
- **Proving the 2 new task 991 axioms**: They are mathematically justified
- **Re-implementing discrete construction**: Task 991 already did this
- **Re-doing phases 1-3**: Already completed

### 6.3 Parts That Could Be Abandoned

- **Discrete completeness without axiom**: This was the original task 981 goal but was deemed intractable (research-001 through research-007 document failed attempts)
- **Phase 4 of plan v7 (if choosing Option B)**: Accept the wiring gap

---

## Decisions

1. **Task 991 has no impact on task 981 remaining work** - orthogonal paths
2. **`discrete_Icc_finite_axiom` is still present** - not removed by task 991
3. **Recommended**: Option A (complete truth lemma) for publication quality
4. **Acceptable**: Option B (document current state) if time-constrained
5. **The discrete covering axiom quest is concluded** - dense path bypasses it entirely

---

## Next Steps

### If Proceeding with Option A:
1. Update state.json status to "implementing"
2. Resume Phase 4: Adapt forward-only truth lemma
3. Complete Phase 5: Fill countermodel construction sorry
4. Complete Phase 6: Verify no axioms on dense path, document discrete path

### If Proceeding with Option B:
1. Update task description to reflect scope change
2. Document wiring gap comprehensively in Completeness.lean
3. Update ROAD_MAP.md with final status
4. Mark task as [COMPLETED] with completion_summary noting scope

---

## References

- `specs/981_.../plans/07_timelinequot-truth-lemma.md` - Current plan
- `specs/981_.../reports/research-010.md` - W=D error analysis
- `specs/991_.../summaries/05_seriality-completion-summary.md` - Task 991 outcome
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - Blocking sorry
- `Theories/Bimodal/FrameConditions/Completeness.lean` - Overall completeness status
- `specs/ROAD_MAP.md` - Strategic context
