# Implementation Plan v2: Constrained Predecessor Seed

- **Task**: 34 - prove_succ_seed_consistency_axioms
- **Status**: [COMPLETED]
- **Effort**: 5-10 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/034_prove_succ_seed_consistency_axioms/reports/01_seed-consistency-research.md
  - specs/034_prove_succ_seed_consistency_axioms/reports/02_team-research.md
  - specs/034_prove_succ_seed_consistency_axioms/reports/03_team-research.md (solution)
- **Artifacts**: plans/02_constrained-seed-approach.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Supersedes**: plans/01_seed-axiom-elimination.md (Phase 4 blocked)

## Overview

This revised plan incorporates the **Constrained Predecessor Seed** solution discovered through team research. The original plan's Phases 1-2 succeeded (eliminating 2 axioms), but Phase 4 was blocked because Lindenbaum extension can introduce arbitrary F-formulas. The solution is to add G-blocking formulas to the predecessor seed that explicitly prevent "bad" F-formulas.

### Previous Progress (Preserved)

| Axiom | Status | Method |
|-------|--------|--------|
| `successor_deferral_seed_consistent_axiom` | **ELIMINATED** | Direct proof via WitnessSeed pattern |
| `predecessor_deferral_seed_consistent_axiom` | **ELIMINATED** | Symmetric proof |
| `predecessor_f_step_axiom` | **BLOCKED** | This plan addresses it |

### Solution Summary

Add G-blocking formulas to the predecessor seed:

```lean
constrained_predecessor_seed(u) =
  h_content(u) ∪ pastDeferralDisjunctions(u) ∪
  {G(¬φ) | F(φ) ∉ u ∧ φ ∉ u}
```

**Why it works**:
1. **Consistency**: Every blocking formula `G(¬φ)` is already in `u` (because `F(φ) ∉ u` ⟹ `G(¬φ) ∈ u` via MCS completeness)
2. **F-step**: If `F(φ) ∈ predecessor` with `φ ∉ u` and `F(φ) ∉ u`, then `G(¬φ)` is in seed and predecessor, but `F(φ) = ¬G(¬φ)`, contradiction

## Goals & Non-Goals

**Goals**:
- Eliminate `predecessor_f_step_axiom` via constrained seed construction
- Achieve **zero production axioms** in SuccExistence.lean
- Maintain all existing functionality (successor_succ, predecessor_succ, predecessor_pred)

**Non-Goals**:
- Re-proving the already-eliminated axioms (Phases 1-2 done)
- Modifying downstream consumers (SuccChainFMCS, etc.) — interface unchanged
- Addressing symmetric `successor_p_step_axiom` (Task 40 scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Infinite blocking set causes Lean issues | H | L | The set is a subset of u, which Lindenbaum already handles |
| Consistency proof more subtle than sketch | M | L | Proof sketch is complete; seed ⊆ u is the key insight |
| Build regressions in downstream | M | L | Interface unchanged; run full build after each phase |
| Double negation handling in MCS | L | L | MCS in classical logic; ¬¬A ↔ A is standard |

## Implementation Phases

### Phase 1: Define Constrained Predecessor Seed [COMPLETED]

**Goal**: Create the new seed definition with G-blocking formulas

**Tasks**:
- [ ] Define `f_step_blocking_formulas` in SuccExistence.lean:
  ```lean
  def f_step_blocking_formulas (u : Set Formula) : Set Formula :=
    {Formula.all_future (Formula.neg φ) | φ : Formula,
      Formula.some_future φ ∉ u ∧ φ ∉ u}
  ```
- [ ] Define `constrained_predecessor_seed`:
  ```lean
  def constrained_predecessor_seed (u : Set Formula) : Set Formula :=
    h_content u ∪ pastDeferralDisjunctions u ∪ f_step_blocking_formulas u
  ```
- [ ] Verify definitions compile

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- `lake build` succeeds

---

### Phase 2: Prove Seed Subset Property [COMPLETED]

**Goal**: Prove `constrained_predecessor_seed(u) ⊆ u`

This is the KEY lemma that makes everything work.

**Tasks**:
- [ ] Prove `f_step_blocking_formulas_subset_u`:
  ```lean
  theorem f_step_blocking_formulas_subset_u
      (u : Set Formula) (h_mcs : SetMaximalConsistent u) :
      f_step_blocking_formulas u ⊆ u := by
    intro ψ h_mem
    -- ψ = G(¬φ) for some φ with F(φ) ∉ u and φ ∉ u
    obtain ⟨φ, h_F_not, h_not, rfl⟩ := h_mem
    -- F(φ) ∉ u means ¬F(φ) ∈ u (MCS completeness)
    have h_neg_F : Formula.neg (Formula.some_future φ) ∈ u :=
      h_mcs.2 _ (h_F_not)
    -- ¬F(φ) = ¬¬G(¬φ) = G(¬φ) (definition + double negation)
    -- F(φ) = ¬G(¬φ), so ¬F(φ) = ¬¬G(¬φ)
    -- By MCS double negation: ¬¬A ∈ u ↔ A ∈ u
    exact mcs_double_neg_elim h_mcs h_neg_F
  ```
- [ ] Prove `constrained_predecessor_seed_subset_u`:
  ```lean
  theorem constrained_predecessor_seed_subset_u
      (u : Set Formula) (h_mcs : SetMaximalConsistent u) :
      constrained_predecessor_seed u ⊆ u := by
    intro ψ h_mem
    rcases h_mem with h_h | h_pd | h_block
    · exact h_content_subset_mcs h_mcs h_h  -- T-axiom
    · exact pastDeferralDisjunctions_subset_mcs h_mcs h_pd
    · exact f_step_blocking_formulas_subset_u u h_mcs h_block
  ```

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- Both lemmas compile without sorry

---

### Phase 3: Prove Seed Consistency [COMPLETED]

**Goal**: Prove the constrained seed is consistent

**Tasks**:
- [ ] Prove `constrained_predecessor_seed_consistent`:
  ```lean
  theorem constrained_predecessor_seed_consistent
      (u : Set Formula) (h_mcs : SetMaximalConsistent u)
      (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
      SetConsistent (constrained_predecessor_seed u) := by
    -- constrained_predecessor_seed u ⊆ u
    have h_sub := constrained_predecessor_seed_subset_u u h_mcs
    -- u is consistent (MCS)
    have h_cons := h_mcs.1
    -- Any subset of a consistent set is consistent
    exact set_consistent_subset h_cons h_sub
  ```

**Timing**: 0.5 hours (follows directly from Phase 2)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- Lemma compiles without sorry

---

### Phase 4: Update Predecessor Construction [COMPLETED]

**Goal**: Replace the old seed with constrained seed in predecessor construction

**Tasks**:
- [ ] Modify `predecessor_from_deferral_seed` to use `constrained_predecessor_seed`:
  ```lean
  noncomputable def predecessor_from_constrained_seed
      (u : Set Formula) (h_mcs : SetMaximalConsistent u)
      (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
      Set Formula :=
    lindenbaumMCS_set (constrained_predecessor_seed u)
      (constrained_predecessor_seed_consistent u h_mcs h_P_top)
  ```
- [ ] Or modify existing def to use new seed (alias for compatibility)
- [ ] Verify existing lemmas using the old construction still work (may need updating)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- `lake build` succeeds with updated construction

---

### Phase 5: Prove F-step Directly [COMPLETED]

**Goal**: Prove F-step as a theorem (no axiom)

**Tasks**:
- [ ] Prove `predecessor_f_step` (replaces axiom):
  ```lean
  theorem predecessor_f_step
      (u : Set Formula) (h_mcs : SetMaximalConsistent u)
      (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
      f_content (predecessor_from_constrained_seed u h_mcs h_P_top) ⊆ u ∪ f_content u := by
    intro φ h_F_in_pred
    -- h_F_in_pred : F(φ) ∈ predecessor
    let v := predecessor_from_constrained_seed u h_mcs h_P_top
    let h_mcs_v := predecessor_from_constrained_seed_mcs u h_mcs h_P_top
    -- Case split: either φ ∈ u, or F(φ) ∈ u, or we reach contradiction
    by_cases h_φ : φ ∈ u
    · left; exact h_φ
    by_cases h_F_φ : Formula.some_future φ ∈ u
    · right; exact h_F_φ
    -- Neither φ ∈ u nor F(φ) ∈ u
    -- By construction: G(¬φ) ∈ constrained_predecessor_seed(u)
    have h_G_in_seed : Formula.all_future (Formula.neg φ) ∈ constrained_predecessor_seed u := by
      right; right  -- In f_step_blocking_formulas
      exact ⟨φ, h_F_φ, h_φ, rfl⟩
    -- Since v extends seed: G(¬φ) ∈ v
    have h_G_in_v : Formula.all_future (Formula.neg φ) ∈ v :=
      lindenbaumMCS_set_extends _ _ h_G_in_seed
    -- But F(φ) = ¬G(¬φ), so both G(¬φ) and ¬G(¬φ) in v
    have h_F_eq : Formula.some_future φ = Formula.neg (Formula.all_future (Formula.neg φ)) := rfl
    rw [h_F_eq] at h_F_in_pred
    -- Contradiction with v being consistent
    exact absurd h_G_in_v (set_consistent_not_both h_mcs_v.1 _ h_F_in_pred)
  ```
- [ ] Remove `predecessor_f_step_axiom` declaration
- [ ] Update any references to use new theorem

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- `lake build` succeeds
- `lean_verify` shows no axiom for predecessor_f_step

---

### Phase 6: Verification & Cleanup [COMPLETED]

**Goal**: Verify all axioms eliminated, no regressions

**Tasks**:
- [ ] Run `lake build` on full project
- [ ] Run `lean_verify` on key theorems:
  - `predecessor_succ`
  - `successor_from_deferral_seed`
  - `predecessor_from_deferral_seed` (or new name)
- [ ] Grep for `axiom` in SuccExistence.lean — should be ZERO
- [ ] Update summary file with final results
- [ ] Remove any temporary compatibility code

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` (cleanup)
- `specs/034_prove_succ_seed_consistency_axioms/summaries/01_seed-axiom-summary.md` (update)

**Verification**:
- Zero axioms in SuccExistence.lean
- All dependent theorems compile
- No build regressions

---

## Testing & Validation

- [ ] `lake build` succeeds with no new errors
- [ ] `lean_verify Bimodal.Metalogic.Bundle.SuccExistence.predecessor_succ` shows no axioms
- [ ] `lean_verify Bimodal.Metalogic.Bundle.SuccExistence.successor_succ` shows no axioms
- [ ] Grep: `grep -c "^axiom" Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` returns 0
- [ ] Dependent modules compile: SuccChainFMCS.lean, SuccChainTruth.lean

## Artifacts & Outputs

- `plans/02_constrained-seed-approach.md` (this file)
- Modified `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` with:
  - `constrained_predecessor_seed` definition
  - `predecessor_f_step` theorem (proven)
  - No remaining axioms
- `summaries/02_constrained-seed-summary.md` upon completion

## Rollback/Contingency

If the constrained seed approach introduces unexpected issues:
1. `git checkout Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` to restore
2. Return to axiom-based approach documented in plan v1
3. Consider alternative approaches from team research (filtration, bidirectional construction)

## Key Insight (From Team Research)

The breakthrough is recognizing that every blocking formula `G(¬φ)` we add is **already in `u`**:

```
F(φ) ∉ u
  ⟹ ¬F(φ) ∈ u          (MCS negation completeness)
  ⟹ ¬¬G(¬φ) ∈ u        (F(φ) = ¬G(¬φ) by definition)
  ⟹ G(¬φ) ∈ u          (MCS double negation elimination)
```

Therefore `constrained_predecessor_seed(u) ⊆ u`, and consistency is immediate.
