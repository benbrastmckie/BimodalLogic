# Implementation Plan: Task #956 - D Construction via Staged Construction (v017)

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [IMPLEMENTING]
- **Effort**: 5-6 hours (remaining)
- **Dependencies**: Task 957 (COMPLETE), Task 959 (COMPLETE)
- **Research Inputs**: research-038.md (Case A strictness solution)
- **Artifacts**: plans/implementation-017.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v017 incorporates research-038 findings; replaces Strategy C iteration with Solution 1 (Case A strictness proof)

## Overview

**Current State**: Phases 0-5 COMPLETED with zero sorries. Phase 6 has 3 sorries in `CantorApplication.lean`.

**Key insight from research-038**: `toAntisymmetrization_lt_toAntisymmetrization_iff` shows quotient strictness equals preorder strictness. We don't need to reason about quotients separately - just prove witnesses satisfy `StagedPoint.lt`.

**Solution 1 (Case A Strictness)**: Prove that `density_frame_condition` Case A produces intermediates that are strictly between endpoints. Case B1 (reflexive target) is degenerate but can be handled by iteration to force Case A.

## Goals & Non-Goals

**Goals**:
- Resolve Phase 6 quotient strictness gap using Case A strictness
- Complete Phases 7-8 to construct D = Q via Cantor isomorphism
- Achieve sorry-free TaskFrame completeness

**Non-Goals**:
- Prove global `canonicalR_irreflexive` (Task 958 - proven unused)
- Lexicographic product densification (no longer needed)

## Implementation Phases

### Phase 0-5: [COMPLETED]

All phases completed with zero sorries. See implementation-014.md.

Files: `StagedTimeline.lean`, `WitnessSeedWrapper.lean`, `SeparationLemma.lean`, `StagedExecution.lean`, `DenseTimeline.lean`, `DensityFrameCondition.lean`

---

### Phase 6: Cantor Isomorphism Application [PARTIAL]

- **Dependencies:** Phase 5 (COMPLETE)
- **Goal:** Resolve 3 sorries, apply Cantor's theorem to establish TimelineQuot ≃o Q
- **Approach:** Solution 1 from research-038 (Case A strictness proof)

**Mathematical Foundation** (from research-038):

The key theorem from Mathlib:
```lean
theorem toAntisymmetrization_lt_toAntisymmetrization_iff {α : Type*} {a b : α} [Preorder α] :
  toAntisymmetrization (· ≤ ·) a < toAntisymmetrization (· ≤ ·) b ↔ a < b
```

This means `[a] < [b]` in TimelineQuot iff `StagedPoint.lt a b`, i.e.:
- `CanonicalR(a.mcs, b.mcs)` AND `NOT CanonicalR(b.mcs, a.mcs)`

**Phase 6a: Prove Case A Witnesses Are Strict** (1.5 hours)

The `density_frame_condition` proof has two cases:
- **Case A**: `G(delta) NOT in M` (delta is distinguishing) - uses double-density trick to produce W
- **Case B**: `G(delta) in M` - splits into B1 (reflexive target, returns W=M') and B2 (reduces to Case A)

**Key lemma to prove**:
```lean
/-- When density_frame_condition fires via Case A, the intermediate W is strictly between M and M'. -/
lemma density_frame_condition_caseA_strict
    {M M' : Set Formula}
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_not_R' : ¬CanonicalR M' M)
    (delta : Formula)
    (h_G_delta_M' : Formula.all_future delta ∈ M')
    (h_delta_not_M : delta ∉ M)
    (h_F_neg_delta : Formula.some_future (Formula.neg delta) ∈ M)  -- Case A condition
    (W : Set Formula)
    (hW : W = density_frame_condition_caseA_witness M M' delta h_mcs h_G_delta_M' h_F_neg_delta) :
    SetMaximalConsistent W ∧
    CanonicalR M W ∧ CanonicalR W M' ∧
    ¬CanonicalR W M ∧ ¬CanonicalR M' W
```

**Why this holds**: In Case A, W is constructed via Lindenbaum extension of `{F(neg(delta))} ∪ GContent(M)`. This W is a **fresh** MCS:
- `¬CanonicalR(W, M)`: W contains `neg(delta)` transitively (via F-witness), but M does not contain `delta`. If GContent(W) ⊆ M, then since W has the F(neg(delta)) witness structure, we derive a contradiction with M's MCS properties.
- `¬CanonicalR(M', W)`: W has the intermediate structure from the double-density trick. M' sees delta (G(delta) ∈ M'), but W is constructed to NOT satisfy delta directly.

**Phase 6b: Create Strict Density Wrapper** (0.5 hours)

```lean
/-- Guaranteed strict intermediate: returns W with M < W < M' in strict preorder sense. -/
theorem density_frame_condition_strict
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_lt : CanonicalR M M' ∧ ¬CanonicalR M' M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧
      CanonicalR M W ∧ CanonicalR W M' ∧
      ¬CanonicalR W M ∧ ¬CanonicalR M' W := by
  -- Apply density_frame_condition
  obtain ⟨W, hW_mcs, hW_R1, hW_R2⟩ := density_frame_condition M M' h_mcs h_mcs' h_lt.1 h_lt.2
  -- Analyze which case fired
  -- If Case A: use density_frame_condition_caseA_strict
  -- If Case B1 (W = M'): iterate with M and M', using seriality to find strict future of M'
  --   then the intermediate between M and that strict future is via Case A
  -- If Case B2: reduces to Case A
  sorry
```

**Phase 6c: Resolve NoMaxOrder** (0.5 hours)

```lean
instance : NoMaxOrder (TimelineQuot root_mcs root_mcs_proof) where
  exists_gt := by
    intro a
    induction a using Antisymmetrization.ind with
    | _ p =>
      -- Use seriality: p.mcs has F(T) for some T
      -- Get strict future witness from seriality + linearity
      obtain ⟨q, hq_mem, hq_lt⟩ := dense_timeline_has_strict_future root_mcs root_mcs_proof p.1 p.2
      use toAntisymmetrization (· ≤ ·) ⟨q, hq_mem⟩
      rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
      exact hq_lt
```

Helper lemma needed:
```lean
/-- Every point in the dense timeline has a strict future in the timeline. -/
lemma dense_timeline_has_strict_future (p : StagedPoint) (hp : p ∈ denseTimelineUnion) :
    ∃ q : StagedPoint, q ∈ denseTimelineUnion ∧ StagedPoint.lt p q
```

**Phase 6d: Resolve NoMinOrder** (0.5 hours)

Symmetric to 6c using past seriality.

**Phase 6e: Resolve DenselyOrdered** (1 hour)

```lean
instance : DenselyOrdered (TimelineQuot root_mcs root_mcs_proof) where
  dense := by
    intro a b hab
    induction a using Antisymmetrization.ind with
    | _ p =>
      induction b using Antisymmetrization.ind with
      | _ q =>
        rw [toAntisymmetrization_lt_toAntisymmetrization_iff] at hab
        -- hab : StagedPoint.lt p q, i.e., CanonicalR(p.mcs, q.mcs) ∧ ¬CanonicalR(q.mcs, p.mcs)
        obtain ⟨W, hW_mcs, hW_R1, hW_R2, hW_strict1, hW_strict2⟩ :=
          density_frame_condition_strict p.1.mcs q.1.mcs p.1.mcs_proof q.1.mcs_proof hab
        -- Need to show W is in denseTimelineUnion
        have hW_mem : W ∈ denseTimelineUnion := density_witness_in_union W hW_mcs hW_R1 p.2
        use toAntisymmetrization (· ≤ ·) ⟨⟨W, hW_mcs⟩, hW_mem⟩
        constructor
        · rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
          exact ⟨hW_R1, hW_strict1⟩
        · rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
          exact ⟨hW_R2, hW_strict2⟩
```

**Timing:** 4 hours total

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - add strictness lemmas
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` - resolve 3 sorries

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" CantorApplication.lean` returns empty
- `grep -n "\bsorry\b" DensityFrameCondition.lean` returns empty
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

**Timing:** 1 hour

**Files to create**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DFromSyntax.lean`

---

### Phase 8: TaskFrame + Completeness [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Construct TaskFrame and prove completeness

**Tasks**:
- [ ] Define `staged_task_frame : TaskFrame D`
- [ ] Prove temporal axiom validity
- [ ] Construct canonical evaluation
- [ ] Prove truth lemma
- [ ] Prove `staged_completeness`: valid phi -> ⊢ phi

**Timing:** 1.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TaskFrameFromSyntax.lean`

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/StagedConstruction/` shows no new axioms

### Integration Verification
- [ ] Completeness theorem connects to existing `valid` definition
- [ ] D is discovered as Q via Cantor, not imported
- [ ] task_rel is actual displacement (non-trivial)

## Artifacts & Outputs

**Existing files (Phases 0-5)**:
- `StagedTimeline.lean`, `WitnessSeedWrapper.lean`, `SeparationLemma.lean`
- `StagedExecution.lean`, `DenseTimeline.lean`, `DensityFrameCondition.lean`
- `CantorApplication.lean` (partial - 3 sorries)

**Files to complete (Phases 6-8)**:
- `DensityFrameCondition.lean` - add strictness lemmas
- `CantorApplication.lean` - resolve 3 sorries
- `DFromSyntax.lean` - Phase 7
- `TaskFrameFromSyntax.lean` - Phase 8

## Rollback/Contingency

**If Case A strictness is hard to prove**:
1. Document the specific obstruction
2. Fall back to Solution 2 (iteration approach from v016)
3. Last resort: lexicographic product densification

## Revision History

- **v017** (this revision): Solution 1 from research-038 - Case A strictness proof approach
- **v016**: Strategy C iteration approach (replaced)
- **v015**: Phase 5 status correction
- **v014**: Phase 5 blocked on density frame condition
