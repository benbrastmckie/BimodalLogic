# Implementation Plan: Task #956 - D Construction via Staged Construction (v016)

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [PARTIAL] - Resume at Phase 6
- **Effort**: 7-8 hours (remaining)
- **Dependencies**: Task 957 (COMPLETE), Task 959 (COMPLETE - orientation)
- **Research Inputs**: research-036.md, research-037.md (remaining work assessment)
- **Artifacts**: plans/implementation-016.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v016 updates phase statuses to match actual codebase state; Phase 6 blocker is quotient strictness, not pre-quotient density

## Overview

**Current State**: Phases 0-5 are COMPLETED with zero sorries. Phase 6 has 3 sorries in `CantorApplication.lean`. The blocker is **quotient strictness** - the DenseTimeline witnesses provide `<=`-ordering but not strict `<` in the antisymmetrized quotient.

**Key change in v016**: Corrects Phase 5 status (was incorrectly showing sub-tasks as NOT STARTED despite Phase 5 being complete). Provides concrete Strategy C for Phase 6 quotient strictness resolution.

### Research Integration

- **research-037.md**: Confirmed Phase 6 blocker is quotient strictness gap (NOT canonicalR_irreflexive). Task 958 abandonment is irrelevant. Estimated 7-8 hours remaining.
- **implementation-summary-20260310f.md**: Phase 5 complete (DenseTimeline.lean, 320 lines, zero sorries).

## Goals & Non-Goals

**Goals**:
- Resolve Phase 6 quotient strictness gap (3 sorries)
- Complete Phases 7-8 to construct D = Q via Cantor isomorphism
- Achieve sorry-free TaskFrame completeness

**Non-Goals**:
- Global canonicalR_irreflexive theorem (Task 958 - proven unused)
- Lexicographic product densification (no longer needed)
- Path D (D = ConstructiveQuotient x Q) - FORBIDDEN

## Implementation Phases

### Phase 0-4: [COMPLETED]

All phases completed with zero sorries. See implementation-014.md.

Files: `StagedTimeline.lean`, `WitnessSeedWrapper.lean`, `SeparationLemma.lean`, `StagedExecution.lean`

---

### Phase 5: Cantor Prerequisites (Pre-Quotient) [COMPLETED]

**Completion**: DenseTimeline.lean created with zero sorries.

**Key theorems proven**:
- `dense_timeline_has_intermediate`: between any CanonicalR-ordered pair, exists intermediate
- `dense_timeline_has_future`: every point has CanonicalR-successor
- `dense_timeline_has_past`: every point has CanonicalR-predecessor
- `dense_timeline_countable`: union is countable
- `dense_timeline_nonempty`: union is nonempty
- `denseStage_linear`: each stage is linearly ordered

**Files**: `DenseTimeline.lean` (320 lines, zero sorries)

---

### Phase 6: Cantor Isomorphism Application [BLOCKED]

- **Dependencies:** Phase 5 (COMPLETE)
- **Goal:** Apply Cantor's theorem to establish TimelineQuot ≃o Q
- **Blocker:** Quotient strictness gap

**Current State** (CantorApplication.lean):
- `TimelineQuot`: Antisymmetrization of DenseTimelineElem by mutual CanonicalR
- `LinearOrder TimelineQuot`: Proven via Antisymmetrization + IsTotal
- `Nonempty TimelineQuot`: Proven
- `Countable TimelineQuot`: Proven
- **NoMaxOrder TimelineQuot**: SORRY (line 135)
- **NoMinOrder TimelineQuot**: SORRY (line 143)
- **DenselyOrdered TimelineQuot**: SORRY (line 149)

**Root Cause**: DenseTimeline witnesses provide CanonicalR(p, q) but not guaranteed STRICT in quotient. If CanonicalR(q, p) also holds, then [p] = [q] in TimelineQuot.

**Strategy C: Prove Strict Witnesses Exist**

The key insight is that if we start from quotient-level `<` (which requires NOT bidirectional CanonicalR), the witnesses will also be strict.

**Phase 6a: NoMaxOrder** (1.5 hours)

For any `[p]` in TimelineQuot, find `[q] > [p]`:

1. Apply `dense_timeline_has_future` to get q with CanonicalR(p.mcs, q.mcs)
2. **Case: CanonicalR(q.mcs, p.mcs) also holds** (bidirectional)
   - Then [p] = [q] in quotient - NOT a strict successor
   - Apply `dense_timeline_has_future` AGAIN from q to get r
   - By temporal linearity axiom: CanonicalR chain is transitive
   - By density axiom (F(phi) -> F(F(phi))): the F-witness for F(F(phi)) is DISTINCT from F(phi) witness
   - Eventually find strict successor r with CanonicalR(p, r) and NOT CanonicalR(r, p)
3. **Alternative proof**: Use `density_frame_condition` to directly produce strict witness
   - For any p, find q with CanonicalR(p, q) and NOT CanonicalR(q, p)
   - Seriality axiom + linearity ensures such q exists

```lean
instance : NoMaxOrder (TimelineQuot root_mcs root_mcs_proof) where
  exists_gt := by
    intro a
    induction a using Antisymmetrization.ind with
    | _ p =>
      -- Get future witness
      obtain ⟨q, hq_mem, hq_R⟩ := dense_timeline_has_future root_mcs root_mcs_proof p.1 p.2
      -- Case split on strictness
      by_cases h : CanonicalR q.mcs p.1.mcs
      · -- Bidirectional: iterate with seriality + linearity
        -- Use seriality: exists q' > q (in canonical sense)
        -- Use linearity: q' is comparable to p
        -- Eventually get strict successor
        sorry -- detailed proof here
      · -- Strict: done
        use toAntisymmetrization (· ≤ ·) ⟨q, hq_mem⟩
        exact ⟨Or.inr hq_R, h⟩
```

**Phase 6b: NoMinOrder** (0.5 hours)

Symmetric to 6a using `dense_timeline_has_past` and H-axioms.

**Phase 6c: DenselyOrdered** (1.5 hours)

For `[a] < [b]` in TimelineQuot, find `[c]` with `[a] < [c] < [b]`:

1. `[a] < [b]` means CanonicalR(a.mcs, b.mcs) AND NOT CanonicalR(b.mcs, a.mcs)
2. Apply `density_frame_condition` to get W with:
   - CanonicalR(a.mcs, W)
   - CanonicalR(W, b.mcs)
3. **Prove [a] < [W]**: Need NOT CanonicalR(W, a.mcs)
   - Suppose CanonicalR(W, a.mcs). Then by transitivity with CanonicalR(a.mcs, b.mcs), get CanonicalR(W, b.mcs) - OK
   - But also CanonicalR(a.mcs, W), so if CanonicalR(W, a.mcs), then [a] = [W] in quotient
   - Need to show this leads to contradiction or use Case B1 analysis
4. **Prove [W] < [b]**: Need NOT CanonicalR(b.mcs, W)
   - Similar analysis using the hypothesis NOT CanonicalR(b.mcs, a.mcs)

**Key lemma**: When a < b in quotient (strict), the density_frame_condition intermediate W is also strictly between in the quotient.

```lean
lemma density_frame_strict_quotient
    (a b : DenseTimelineElem root_mcs root_mcs_proof)
    (hab : a.1.mcs ≠ b.1.mcs)
    (hR : CanonicalR a.1.mcs b.1.mcs)
    (hR' : ¬CanonicalR b.1.mcs a.1.mcs)
    (W : Set Formula)
    (hW_mcs : SetMaximalConsistent W)
    (hW_R1 : CanonicalR a.1.mcs W)
    (hW_R2 : CanonicalR W b.1.mcs) :
    ¬CanonicalR W a.1.mcs ∧ ¬CanonicalR b.1.mcs W := by
  constructor
  · -- If CanonicalR(W, a.mcs), then with CanonicalR(a.mcs, b.mcs) and transitivity
    -- we get a cycle a -> W -> a -> b, but combined with CanonicalR(W, b.mcs)
    -- and NOT CanonicalR(b.mcs, a.mcs), derive contradiction
    sorry
  · -- If CanonicalR(b.mcs, W), then with CanonicalR(W, b.mcs) we have b ~ W
    -- But CanonicalR(a.mcs, W) and NOT CanonicalR(b.mcs, a.mcs)
    -- If b ~ W and a < b (strict), then a < W (strict)
    -- But we also have a <= W, so need a != W
    sorry
```

**Timing:** 3.5 hours total

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` - resolve 3 sorries

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" CantorApplication.lean` returns empty
- `cantor_iso` theorem compiles

---

### Phase 7: D and task_rel from Cantor [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Define D as (Q, +) and task_rel as actual displacement

**Tasks**:
- [ ] Define `D : Type := Q` with AddCommGroup instance from Mathlib
- [ ] Extract eval/eval_inv from `cantor_iso`
- [ ] Define `task_rel (d : D) (w : T) : T := eval_inv (eval w + d)`
- [ ] Prove `task_rel` is a group action (d = 0 -> id, d + d' -> composition)
- [ ] Prove order preservation: d > 0 -> task_rel d w > w

**Timing:** 1.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DFromSyntax.lean`

---

### Phase 8: TaskFrame + Completeness [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Construct TaskFrame and prove completeness

**Tasks**:
- [ ] Define `staged_task_frame : TaskFrame D` with:
  - `times := TimelineQuot`
  - `histories := { mcs_family : Q -> Set Formula | temporal_coherent }`
  - `task_rel := task_rel from Phase 7`
- [ ] Prove temporal axiom validity (seriality, linearity, density, T-axioms)
- [ ] Construct canonical evaluation: `canonical_fmcs : FMCS D` from root MCS
- [ ] Prove truth lemma: `truth_at canonical_fmcs t phi <-> phi ∈ canonical_fmcs.mcs t`
- [ ] Prove `staged_completeness`: `valid phi -> ⊢ phi`

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
- [ ] Completeness theorem connects to existing `valid` definition from Validity.lean
- [ ] D is discovered as Q via Cantor, not imported
- [ ] task_rel is actual displacement (non-trivial)

## Artifacts & Outputs

**Existing files (Phases 0-5)**:
- `StagedTimeline.lean`, `WitnessSeedWrapper.lean`, `SeparationLemma.lean`
- `StagedExecution.lean`, `DenseTimeline.lean`, `DensityFrameCondition.lean`
- `CantorApplication.lean` (partial - 3 sorries)

**Files to complete (Phases 6-8)**:
- `CantorApplication.lean` - Phase 6 (resolve 3 sorries)
- `DFromSyntax.lean` - Phase 7
- `TaskFrameFromSyntax.lean` - Phase 8

**Summary artifact**:
- `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

**If Phase 6 strictness proof is blocked**:
1. Document the specific obstruction (which case of the proof fails)
2. Try alternative: prove witnesses are fresh MCSs (not equal to endpoints)
3. Last resort: Fall back to lexicographic product densification (research-035)

**If Mathlib Cantor theorem signature mismatch**:
1. Check `Order.iso_of_countable_dense` exact signature
2. May need `Nonempty` proof adjustment
3. Implement back-and-forth manually (adds ~2 hours)

## Revision History

- **v016** (this revision): Correct phase statuses; Phase 6 blocker is quotient strictness, not pre-quotient density; concrete Strategy C with proof sketches
- **v015**: Phase 5 status inconsistent (marked COMPLETED but sub-tasks NOT STARTED)
- **v014**: Phase 5 blocked on density frame condition
- **v013-v001**: Prior approaches (see archive)
