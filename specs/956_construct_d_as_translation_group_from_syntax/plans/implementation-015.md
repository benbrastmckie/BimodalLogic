# Implementation Plan: Task #956 - D Construction via Staged Construction (v015)

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [PARTIAL]
- **Effort**: 12 hours (remaining)
- **Dependencies**: Task 957 (COMPLETE - density_frame_condition proven)
- **Research Inputs**: research-034.md, research-035.md, research-036.md (unblocking analysis)
- **Artifacts**: plans/implementation-015.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v015 revises v014 Phase 5 to use density_frame_condition from task 957

## Overview

This plan continues the **staged construction** approach from v014. Phases 0-4 are COMPLETED with zero sorries. Phase 5 was BLOCKED on the density frame condition, which is now proven in task 957.

**Key change in v015**: Phase 5 is revised to use `density_frame_condition` directly from `DensityFrameCondition.lean` instead of the insufficient `density_intermediate` approach.

### Research Integration

- **research-036.md**: Task 957 completion unblocks Phase 5. Recommends Strategy C (hybrid density insertion using density_frame_condition for all ordered pairs).
- **Task 957 completion**: `density_frame_condition` proven with zero sorries - given CanonicalR(M, M') and NOT CanonicalR(M', M), exists W with CanonicalR(M, W) AND CanonicalR(W, M').

## Goals & Non-Goals

**Goals**:
- Complete Phase 5 by proving `staged_timeline_densely_ordered` using `density_frame_condition`
- Complete Phases 6-8 to construct D = Q via Cantor isomorphism
- Achieve sorry-free TaskFrame completeness

**Non-Goals**:
- Lexicographic product densification (research-035 fallback - no longer needed)
- Path D (D = ConstructiveQuotient x Q) - FORBIDDEN

## Implementation Phases

### Phase 0-4: [COMPLETED]

See implementation-014.md for details. All phases completed with zero sorries.

---

### Phase 5: Cantor Prerequisites Verification [COMPLETED]

- **Dependencies:** Phase 4, Task 957 (COMPLETE)
- **Goal:** Prove the staged timeline T satisfies Cantor prerequisites
- **Prior Blocker:** `staged_timeline_densely_ordered` was blocked on density frame condition
- **Resolution:** Task 957 provides `density_frame_condition` theorem

**Phase 5a: Import and verify density_frame_condition [NOT STARTED]**

- [ ] Add import `Bimodal.Metalogic.StagedConstruction.DensityFrameCondition` to CantorPrereqs.lean
- [ ] Verify `density_frame_condition` theorem signature matches requirements
- [ ] Create wrapper: `density_staged_point` that applies density_frame_condition to StagedPoint pairs

**Phase 5b: Strictness lemma [NOT STARTED]**

The `density_frame_condition` gives W with CanonicalR(M, W) and CanonicalR(W, M'). For StagedPoint.lt density, we need W STRICTLY between, meaning:
- NOT CanonicalR(W, M)
- NOT CanonicalR(M', W)

- [ ] Analyze Case B1 (M' reflexive) - in this case W = M', which is NOT strictly between
- [ ] Prove `density_frame_condition_strict`: For non-reflexive M', the intermediate W is strictly between
- [ ] For Case B1 (reflexive M'): Use double-density trick from density_frame_condition proof to find a non-reflexive intermediate
- [ ] Alternative: Prove that between any StagedPoint.lt pair, there exists at least one non-reflexive intermediate via the Case A path

**Phase 5c: Prove staged_timeline_densely_ordered [NOT STARTED]**

Two strategies available:

**Strategy C (Recommended)**: For any a < b in the union, apply density_frame_condition(a.mcs, b.mcs) to get W. By strictness lemma, W is strictly between. Show W is in the union because:
1. W is a valid MCS (from density_frame_condition)
2. W is CanonicalR-reachable from root (by transitivity through a)
3. The staged construction eventually adds all reachable MCSs

- [ ] Prove `reachable_mcs_eventually_added`: any MCS reachable via CanonicalR from root appears in some stage
- [ ] Prove `staged_timeline_densely_ordered`: for a < b in union, exists c with a < c < b

**Phase 5d: Verify Cantor prerequisites complete [NOT STARTED]**

- [ ] `staged_timeline_countable`: ALREADY PROVEN in v014
- [ ] `staged_timeline_has_future` (NoMaxOrder): ALREADY PROVEN in v014
- [ ] `staged_timeline_has_past` (NoMinOrder): ALREADY PROVEN in v014
- [ ] `staged_timeline_nonempty`: ALREADY PROVEN in v014
- [ ] `staged_timeline_densely_ordered`: Phase 5c target

**Timing:** 4-5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` - add density proofs

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" CantorPrereqs.lean` returns empty
- All 5 Cantor prerequisites proven

---

### Phase 6: Cantor Isomorphism Application [BLOCKED]

- **Dependencies:** Phase 5
- **Goal:** Apply Cantor's theorem to establish T isomorphic to Q

**Tasks** (unchanged from v014):
- [ ] Import Mathlib's `Order.CountableDenseLinearOrder` (verify availability with lean_local_search)
- [ ] Instantiate `CountableDenseLinearOrderWithoutEndpoints` for staged timeline T
- [ ] Construct `cantor_iso : T ≃o Q` using Mathlib's Cantor uniqueness theorem
- [ ] Define `eval : T -> Q` and `eval_inv : Q -> T`
- [ ] Prove order preservation lemmas

**Timing:** 1.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

---

### Phase 7: D and task_rel from Cantor [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Define D as (Q, +) and task_rel as actual displacement

**Tasks** (unchanged from v014):
- [ ] Define `D : Type := Q`
- [ ] Define group operations (add, zero, neg)
- [ ] Prove `D_is_linearly_ordered_abelian_group`
- [ ] Define `task_rel (d : D) (w : T) : T := eval_inv (eval w + d)`
- [ ] Prove group action and order preservation properties

**Timing:** 1.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DFromSyntax.lean`

---

### Phase 8: TaskFrame + Completeness [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Construct TaskFrame and prove completeness

**Tasks** (unchanged from v014):
- [ ] Define `staged_task_frame : TaskFrame D`
- [ ] Prove temporal axioms hold
- [ ] Integrate with truth lemma
- [ ] Prove `staged_completeness`: valid phi -> ⊢ phi

**Timing:** 2.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TaskFrameFromSyntax.lean`

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/StagedConstruction/` shows no new axioms

### Integration Verification
- [ ] Completeness theorem connects to existing Validity.lean definition
- [ ] D is discovered Q via Cantor, not imported
- [ ] task_rel is actual displacement (non-trivial)

## Artifacts & Outputs

Files from v014 (existing):
- `StagedTimeline.lean`, `WitnessSeedWrapper.lean`, `SeparationLemma.lean`, `StagedExecution.lean`

Files to complete in v015:
- `CantorPrereqs.lean` - Phase 5 density completion
- `CantorApplication.lean` - Phase 6 Cantor isomorphism
- `DFromSyntax.lean` - Phase 7 D construction
- `TaskFrameFromSyntax.lean` - Phase 8 completeness

Summary artifact:
- `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

**If Phase 5 strictness lemma is blocked**:
1. Document the specific obstruction (Case B1 handling)
2. Fall back to lexicographic product densification (research-035)
3. Mark [BLOCKED] with requires_user_review: true if neither works

**If Mathlib Cantor theorem unavailable**:
1. Check alternative Mathlib functions (Order.iso_rat_*, etc.)
2. Implement Cantor back-and-forth manually (adds ~2 hours)

## Revision History

- **v015** (this revision): Phase 5 unblocked by task 957, revised to use density_frame_condition
- **v014**: Phase 5 blocked on density frame condition
- **v013-v001**: Prior approaches (see archive)
