# Implementation Plan: Task #956 - D Construction via Staged Construction (v018)

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [IMPLEMENTING]
- **Effort**: 3-4 hours (remaining)
- **Dependencies**: Task 957 (COMPLETE), Task 959 (COMPLETE)
- **Research Inputs**: research-039.md (iteration-based strictness solution)
- **Artifacts**: plans/implementation-018.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v018 replaces direct Case A strictness proof with iteration-based approach from research-039

## Overview

**Current State**: Phases 0-5 COMPLETED with zero sorries. Phase 6 has 3 sorries in `CantorApplication.lean` plus 8 sorries in partial `density_frame_condition_strict`.

**Key insight from research-039**: Direct formula-based proof of `NOT CanonicalR(V, M)` is difficult under irreflexive semantics because G(delta) and neg(delta) are consistent. Instead, use **iteration to force Case A**.

**Iteration Approach**: When `density_frame_condition` returns a non-strict witness (Case B1: W = M'), apply seriality to get M''s strict future, then apply density between M and that future. This forces Case A (fresh MCS).

## Goals & Non-Goals

**Goals**:
- Resolve Phase 6 quotient strictness gap using iteration approach
- Complete Phases 7-8 to construct D = Q via Cantor isomorphism
- Achieve sorry-free TaskFrame completeness

**Non-Goals**:
- Prove global `canonicalR_irreflexive` (Task 958 - proven unused)
- Direct Case A strictness proof (v017 approach - abandoned)

## Implementation Phases

### Phase 0-5: [COMPLETED]

All phases completed with zero sorries. See implementation-014.md.

Files: `StagedTimeline.lean`, `WitnessSeedWrapper.lean`, `SeparationLemma.lean`, `StagedExecution.lean`, `DenseTimeline.lean`, `DensityFrameCondition.lean`

---

### Phase 6: Cantor Isomorphism Application [BLOCKED]

- **Dependencies:** Phase 5 (COMPLETE)
- **Goal:** Resolve 3 sorries via iteration-based strictness, apply Cantor's theorem
- **Approach:** Iteration from research-039 (replaces v017 direct proof)

**Progress (from v017 attempt)**:
- Added `denseTimeline_linearly_ordered` lemma to DenseTimeline.lean
- Fixed CantorApplication imports/instances (DecidableLE, DecidableLT, LinearOrder)
- Partial `density_frame_condition_strict` structure in place

**Mathematical Foundation** (from research-039):

Case B1 returns W = M' when M' is reflexive (G(delta) in M implies delta in M). This collapses in the quotient. The iteration approach:

1. Check if `density_frame_condition` returned strict witness (W != M, W != M' up to mutual accessibility)
2. If non-strict (Case B1): M' is reflexive, so by seriality M' has a strict future M''
3. Apply density between M and M'' - this must use Case A (different distinguishing formula)
4. The new witness is guaranteed strict

**Phase 6a: Implement Iteration Wrapper** (1.5 hours)

```lean
/-- Check if two MCSs are mutually accessible (equivalent in quotient). -/
def mutually_accessible (M M' : Set Formula) : Prop :=
  CanonicalR M M' ∧ CanonicalR M' M

/-- Get a strict future of an MCS using seriality. -/
lemma mcs_has_strict_future (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ M' : Set Formula, SetMaximalConsistent M' ∧ CanonicalR M M' ∧ ¬CanonicalR M' M := by
  -- Use seriality: F(verum) in M
  -- Apply forward_witness to get M' with verum in M'
  -- M' is strict because... (need to prove)
  sorry

/-- Strict density: guaranteed strict intermediate via iteration. -/
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
  -- Check if W is already strict
  by_cases h_strict_back : ¬CanonicalR W M
  case pos =>
    by_cases h_strict_fwd : ¬CanonicalR M' W
    case pos =>
      exact ⟨W, hW_mcs, hW_R1, hW_R2, h_strict_back, h_strict_fwd⟩
    case neg =>
      -- M' sees W, so W sees M' and M' sees W - they're equivalent
      -- This shouldn't happen if W != M'
      -- Use linearity to derive contradiction or find alternative
      sorry
  case neg =>
    -- W sees M back - they're mutually accessible
    -- This is Case B1: W = M' (up to equivalence) and M' is reflexive
    -- Iterate: get strict future of M' via seriality
    obtain ⟨M'', hM''_mcs, hM''_R, hM''_strict⟩ := mcs_has_strict_future M' h_mcs'
    -- Now apply density between M and M''
    have h_M_M'' : CanonicalR M M'' := canonicalR_transitive M M' M'' h_mcs hW_R1 hM''_R
    have h_not_M''_M : ¬CanonicalR M'' M := by
      intro h_contra
      -- M'' -> M -> M' -> M'' forms a cycle
      -- With M' -> M'' strict, this contradicts...
      sorry
    -- Apply density_frame_condition between M and M''
    -- This uses a DIFFERENT distinguishing formula, so Case A fires
    obtain ⟨W', hW'_mcs, hW'_R1, hW'_R2⟩ := density_frame_condition M M'' h_mcs hM''_mcs h_M_M'' h_not_M''_M
    -- W' is strict by Case A (new distinguishing formula)
    -- Need to prove W' is also between M and M' (not just M and M'')
    sorry
```

**Key Lemma**: The iteration terminates because each application uses a different distinguishing formula from the finite formula hierarchy.

**Phase 6b: Prove Strict Future Exists** (0.5 hours)

```lean
/-- Every MCS has a strict future (not mutually accessible). -/
lemma mcs_has_strict_future (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ M' : Set Formula, SetMaximalConsistent M' ∧ CanonicalR M M' ∧ ¬CanonicalR M' M := by
  -- By seriality, F(verum) in M (or use specific seriality lemma)
  -- forward_witness gives M' with verum in M'
  -- If M' were to see back to M, then GContent(M') subset M
  -- But M' is "fresh" from Lindenbaum...
  -- Use the distinguishing formula from forward_witness construction
  sorry
```

**Alternative**: Use `task_seriality_F` which gives F(phi) -> exists future with phi.

**Phase 6c: Resolve NoMaxOrder** (0.5 hours)

```lean
instance : NoMaxOrder (TimelineQuot root_mcs root_mcs_proof) where
  exists_gt := by
    intro a
    induction a using Antisymmetrization.ind with
    | _ p =>
      -- Use mcs_has_strict_future on p.mcs
      obtain ⟨q_mcs, hq_mcs, hq_R, hq_strict⟩ := mcs_has_strict_future p.1.mcs p.1.mcs_proof
      -- Show q_mcs is in denseTimelineUnion
      have hq_mem : q_mcs ∈ denseTimelineUnion := by
        -- forward witness is reachable, hence in union
        sorry
      use toAntisymmetrization (· ≤ ·) ⟨⟨q_mcs, hq_mcs⟩, hq_mem⟩
      rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
      exact ⟨hq_R, hq_strict⟩
```

**Phase 6d: Resolve NoMinOrder** (0.5 hours)

Symmetric to 6c using past seriality (`H(verum) -> exists past`).

**Phase 6e: Resolve DenselyOrdered** (0.5 hours)

```lean
instance : DenselyOrdered (TimelineQuot root_mcs root_mcs_proof) where
  dense := by
    intro a b hab
    induction a using Antisymmetrization.ind with
    | _ p =>
      induction b using Antisymmetrization.ind with
      | _ q =>
        rw [toAntisymmetrization_lt_toAntisymmetrization_iff] at hab
        -- hab : StagedPoint.lt p q
        obtain ⟨W, hW_mcs, hW_R1, hW_R2, hW_strict1, hW_strict2⟩ :=
          density_frame_condition_strict p.1.mcs q.1.mcs p.1.mcs_proof q.1.mcs_proof hab
        have hW_mem : W ∈ denseTimelineUnion := by sorry  -- reachability argument
        use toAntisymmetrization (· ≤ ·) ⟨⟨W, hW_mcs⟩, hW_mem⟩
        constructor
        · rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
          exact ⟨hW_R1, hW_strict1⟩
        · rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
          exact ⟨hW_R2, hW_strict2⟩
```

**Timing:** 3 hours total

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - iteration wrapper
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` - resolve 3 sorries

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" CantorApplication.lean` returns empty
- `grep -n "\bsorry\b" DensityFrameCondition.lean` returns empty (no new sorries)

---

### Phase 7: D and task_rel from Cantor [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Define D as (Q, +) and task_rel as actual displacement

**Tasks**:
- [ ] Define `D : Type := Q` with AddCommGroup instance from Mathlib
- [ ] Extract eval/eval_inv from `cantor_iso`
- [ ] Define `task_rel (d : D) (w : T) : T := eval_inv (eval w + d)`
- [ ] Prove `task_rel` is a group action
- [ ] Prove order preservation

**Timing:** 0.5 hours

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
- [ ] Prove `staged_completeness`: valid phi -> phi provable

**Timing:** 0.5 hours

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
- `DensityFrameCondition.lean` - add iteration wrapper
- `CantorApplication.lean` - resolve 3 sorries
- `DFromSyntax.lean` - Phase 7
- `TaskFrameFromSyntax.lean` - Phase 8

## Rollback/Contingency

**If iteration approach has issues**:
1. Check that seriality actually gives strict futures (not just any future)
2. Verify transitivity chains preserve strictness
3. Last resort: strengthen witness seed construction (Approach D from research-039)

## Revision History

- **v018** (this revision): Iteration approach from research-039 - wrap density with strictness check
- **v017**: Direct Case A strictness proof (FAILED - backward strictness hard under irreflexive semantics)
- **v016**: Strategy C iteration approach (original)
- **v015**: Phase 5 status correction
- **v014**: Phase 5 blocked on density frame condition
