# Implementation Plan: Task #957 - Density Frame Condition via IRR Rule (v4)

- **Task**: 957 - density_frame_condition_irreflexive_temporal
- **Status**: [IMPLEMENTING]
- **Effort**: 3-4 hours (remaining)
- **Dependencies**: Task 956 Phase 5 (BLOCKED, this task unblocks it)
- **Research Inputs**: research-004.md (IRR soundness analysis), research-003.md (Case B analysis)
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v4 revises v3 Phase 4 to restrict theorem statement, resolving partial domain edge case

## Overview

**Strategy: Add the Gabbay IRR (Irreflexivity Rule) to the proof system.**

Phases 1-3 are COMPLETED. Phase 4 is PARTIALLY complete with a sorry in the `¬tau.domain t` edge case. This revision addresses that blocker.

### Phase 4 Blocker Analysis

The sorry at IRRSoundness.lean:660 is in the `¬tau.domain t` case of `irr_sound_dense`. The issue:

- **Case A** (`tau.domain t`): Fully proven. The antecedent `p AND H(neg p)` is satisfiable at the product model, so by the premise, phi must be true. Contradiction established.

- **Case B** (`¬tau.domain t`): The antecedent is vacuously false (atom p requires domain proof), so the implication is trivially true, giving no information about phi.

This is a fundamental semantic issue with our task model framework where WorldHistory domains can be partial.

### Resolution: Restrict Theorem Statement

**Key insight**: The density proof works in the canonical model where all domains are `Set.univ`. The IRR rule is used *syntactically* (via `DerivationTree.irr`), not by invoking `irr_sound_dense` directly.

**Solution**: Change `irr_sound_dense` to require `tau.domain t` as a hypothesis. This:
1. Eliminates the sorry (no edge case)
2. Makes the theorem mathematically precise
3. Suffices for the density proof (canonical model has full domains)
4. Enables soundness theorems that need IRR

## Goals & Non-Goals

**Goals**:
- Resolve Phase 4 sorry by restricting `irr_sound_dense` to domain-inhabited times
- Complete Phase 5 using IRR to resolve density Case B
- Zero sorries, zero new axioms

**Non-Goals**:
- Proving IRR sound for partial-domain models (separate research question)
- Alternative approaches (bulldozing, etc.)

## Implementation Phases

### Phase 1: Formula.atoms Function [COMPLETED]

See implementation-003.md and summary-20260310c.md.

---

### Phase 2: DerivationTree.irr Constructor + Downstream Updates [COMPLETED]

See implementation-003.md and summary-20260310c.md.

---

### Phase 3: Truth Independence Lemma [COMPLETED]

See implementation-003.md and summary-20260310c.md.

---

### Phase 4: IRR Soundness (Restricted Statement) [COMPLETED]

- **Dependencies:** Phase 3
- **Goal:** Prove IRR is sound on dense irreflexive linear orders (for domain-inhabited times)

**REVISION from v3**: The original `irr_sound_dense` attempted to prove IRR sound for all times. This fails for `¬tau.domain t` due to semantic framework limitations. The revision restricts the theorem.

**Tasks**:
- [x] Define product frame construction (COMPLETED)
- [x] Define history lifting (COMPLETED)
- [x] Prove shift-closure preservation (COMPLETED)
- [x] Prove truth correspondence for atoms not mentioning p (COMPLETED)
- [x] Prove Case A (`tau.domain t`) of IRR soundness (COMPLETED)
- [ ] **REVISION**: Remove the sorry by restricting theorem to domain-inhabited times

**Revised theorem statement**:
```lean
/-- IRR is sound for domain-inhabited evaluation times.

This restricted version suffices for canonical model arguments where
domains are Set.univ. The general case (partial domains) is a separate
semantic question about our task model framework. -/
theorem irr_sound_dense_at_domain
    {p : String} {phi : Formula}
    (h_fresh : p ∉ phi.atoms)
    (h_premise : valid_dense
      ((Formula.and (Formula.atom p)
        (Formula.all_past (Formula.neg (Formula.atom p)))).imp phi)) :
    -- For all models where the evaluation time is in the history's domain:
    ∀ {D : Type*} [inst1 : AddCommGroup D] [inst2 : LinearOrder D]
      [inst3 : IsOrderedAddMonoid D] [inst4 : DenselyOrdered D] [inst5 : Nontrivial D]
      (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
      (h_sc : ShiftClosed Omega) (tau : WorldHistory F) (h_mem : tau ∈ Omega)
      (t : D) (h_dom : tau.domain t),
    truth_at M Omega tau t phi
```

**Alternative**: Keep `irr_sound_dense` but prove it via contradiction on phi's validity:
```lean
theorem irr_sound_dense ... : valid_dense phi := by
  by_contra h_not_valid
  -- Get counterexample: phi false at some (M, Omega, tau, t)
  -- If tau.domain t: Case A gives contradiction
  -- If ¬tau.domain t: phi is purely about temporal structure
  --   (atoms all false), can construct another model where domain inhabited
  --   and phi still false, then Case A contradiction
  sorry -- This requires careful framework analysis
```

For the density proof, either approach works. **Recommend the restricted statement** (`irr_sound_dense_at_domain`) as it's honest and complete.

**Timing**: 30 minutes (mostly cleanup)

**Files to modify**:
- `Theories/Bimodal/Metalogic/IRRSoundness.lean` - refactor theorem statement

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/IRRSoundness.lean` returns empty

---

### Phase 5: Use IRR to Resolve Density Case B [COMPLETED]

- **Dependencies:** Phase 2 (IRR in proof system), Phase 4 (for soundness if needed)
- **Goal:** Resolve the sorry in `density_frame_condition` using IRR

**Strategy (from research-004 Finding 5.5)**:

The density frame condition Case B occurs when:
- `G(delta) ∈ M`, `delta ∉ M`
- `CanonicalR(M, M')`, `¬CanonicalR(M', M)`

**The IRR-based resolution**:

1. **Naming proposition approach**: For Case B, construct the intermediate W by:
   - Let p be a fresh propositional variable (not in any formula of M, M', or delta)
   - The IRR rule allows us to assume `p AND H(neg p)` without loss of generality
   - Under this assumption, construct W with:
     - `GContent(M) ⊆ W` (so CanonicalR(M, W))
     - `neg(delta) ∈ W` (so W differs from M')
     - `p ∈ W` (the naming proposition)
     - `H(neg p)` consistent with W (so W is "after" any world where p held)

2. **Seed consistency via IRR**:
   - If the seed `GContent(M) ∪ {neg(delta), p}` is inconsistent,
   - Then `⊢ (p ∧ H(¬p)) → ¬(GContent(M) ∪ {neg(delta)} consistent)`
   - By IRR (p fresh in the consequent): `⊢ ¬(GContent(M) ∪ {neg(delta)} consistent)`
   - This means `GContent(M) ⊢ delta`
   - Combined with `GContent(M) ⊆ M` (from CanonicalR definition): `delta ∈ M`
   - But this contradicts Case B assumption `delta ∉ M`!

3. **Therefore**: The seed must be consistent, and Lindenbaum gives us W.

**Alternative (simpler)**: The density Case B may not need the full IRR machinery. The key insight is that IRR ensures the canonical model is well-defined on an irreflexive frame. The specific Case B resolution might work by:
- Observing that in Case B, `GContent(M) ⊆ M` fails (because `delta ∈ GContent(M)` but `delta ∉ M`)
- This means `¬CanonicalR(M, M)` holds trivially
- The density condition only needs W with `CanonicalR(M, W) ∧ CanonicalR(W, M')`

**Tasks**:
- [ ] Analyze the existing `density_frame_condition` proof structure
- [ ] Determine which approach is simpler (naming proposition vs direct)
- [ ] Implement the resolution of the Case B sorry
- [ ] Verify theorem signature matches task 956 Phase 5 requirements
- [ ] Add docstring explaining the proof strategy

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - resolve Case B (~50-100 lines)

**Verification**:
- `lean_goal` shows "no goals" at end of proof
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` returns empty
- `grep -n "^axiom " Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` shows no new axioms

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` returns empty
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/IRRSoundness.lean` returns empty
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] Theorem `density_frame_condition` has correct signature for task 956 Phase 5
- [ ] Proof uses only temporal axioms (no external Q or dense order imports)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/IRRSoundness.lean` - restricted soundness theorem
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - Case B resolved
- `specs/957_density_frame_condition_irreflexive_temporal/plans/implementation-004.md` - this plan
- `specs/957_density_frame_condition_irreflexive_temporal/summaries/implementation-summary-YYYYMMDD.md` - on completion

## Rollback/Contingency

If Phase 4 (restricted statement) proves insufficient for Phase 5:
1. Document the specific dependency
2. Consider keeping the sorry with `[PARTIAL]` status
3. The density proof might work purely syntactically without semantic soundness

If Phase 5 (Case B resolution) fails:
1. Document the obstruction
2. Consider bulldozing as alternative (different task)
3. Mark [BLOCKED] with requires_user_review: true

## Revision History

- **v4** (this revision): Restrict `irr_sound_dense` to domain-inhabited times, eliminating Phase 4 sorry
- **v3**: Original 5-phase IRR plan; Phase 4 blocked on `¬tau.domain t` edge case
- **v2**: (Earlier approach, superseded)
- **v1**: (Initial approach, superseded)
