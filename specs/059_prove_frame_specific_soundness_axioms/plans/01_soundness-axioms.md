# Implementation Plan: Task #59 - Frame-Specific Soundness Axioms

- **Task**: 59 - prove_frame_specific_soundness_axioms
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/059_prove_frame_specific_soundness_axioms/reports/01_frame-soundness-research.md
  - specs/059_prove_frame_specific_soundness_axioms/reports/02_team-research.md
- **Artifacts**: plans/01_soundness-axioms.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Fill 5 sorries in `Soundness.lean` for frame-specific axiom validity. Key research finding: under reflexive temporal semantics (`<=`), 4 of 5 axioms are trivially valid using `le_rfl` as self-witness. The `temporal_duality` case (line 602) requires `[DenselyOrdered D] [Nontrivial D]` constraints not present in the general soundness theorem, making it a documented architectural limitation.

### Research Integration

From `01_frame-soundness-research.md` and `02_team-research.md`:
- Reflexive semantics (`s <= t` instead of `s < t`) makes density/seriality trivially valid
- The `[DenselyOrdered D]` typeclass is declared but unused in density proofs
- Proof pattern for trivial cases: `h_GG s hts s le_rfl` (witness is current time `t` itself)
- `temporal_duality` requires `derivable_implies_swap_valid` which has frame constraints
- `soundness_dense` theorem (line 701) handles all cases including duality

## Goals & Non-Goals

**Goals**:
- Fill 4 sorries (density, discreteness_forward, seriality_future, seriality_past) with verified proofs
- Document why `temporal_duality` cannot be proven without frame constraints
- Reduce sorry count from 5 to 1 with clear explanation
- Verify all proofs compile with `lake build`

**Non-Goals**:
- Add `[DenselyOrdered D] [Nontrivial D]` constraints to general soundness theorem (would change API)
- Prove `temporal_duality` (requires architectural changes beyond task scope)
- Modify reflexive vs strict semantics design
- Touch parallel strict temporal extensions track (tasks 74-76)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Proof term mismatch with verified research | M | L | Research proofs tested with `lean_multi_attempt`; follow exact patterns |
| `discreteness_forward` more complex than expected | L | L | Research provides complete proof; uses established `and_of_not_imp_not` helper |
| Build regression in other theorems | M | L | Run full `lake build` after each phase; check no new sorries introduced |

## Implementation Phases

### Phase 1: Trivial Seriality Proofs [NOT STARTED]

**Goal**: Fill seriality_future and seriality_past sorries using reflexive self-witness pattern

**Tasks**:
- [ ] Replace sorry at line 579 (seriality_future) with:
  ```lean
  simp only [Formula.some_future, Formula.neg, truth_at]
  intro h_G h_neg_F
  exact h_neg_F t le_rfl (h_G t le_rfl)
  ```
- [ ] Replace sorry at line 582 (seriality_past) with:
  ```lean
  simp only [Formula.some_past, Formula.neg, truth_at]
  intro h_H h_neg_P
  exact h_neg_P t le_rfl (h_H t le_rfl)
  ```
- [ ] Run `lake build Bimodal.Metalogic.Soundness` to verify

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - lines 577-582

**Verification**:
- `lake build` succeeds
- No new sorries introduced
- Seriality proofs use the self-witness `t` via `le_rfl`

---

### Phase 2: Density Axiom Proof [NOT STARTED]

**Goal**: Fill density sorry using GG -> G transitivity pattern

**Tasks**:
- [ ] Replace sorry at line 572 (density) with:
  ```lean
  simp only [truth_at]
  intro h_GG s hts
  exact h_GG s hts s le_rfl
  ```
- [ ] Run `lake build Bimodal.Metalogic.Soundness` to verify

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - lines 568-572

**Verification**:
- `lake build` succeeds
- Density proof uses reflexive witness: given `h_GG` (forall r >= t, forall q >= r, phi q), prove `phi s` for any `s >= t` by taking `r = s, q = s`

---

### Phase 3: Discreteness Forward Proof [NOT STARTED]

**Goal**: Fill discreteness_forward sorry using `and_of_not_imp_not` decomposition

**Tasks**:
- [ ] Replace sorry at line 576 (discreteness_forward) with:
  ```lean
  simp only [Formula.and, Formula.some_future, Formula.neg, truth_at]
  intro h_conj h_G_not_H
  have h1 := and_of_not_imp_not h_conj
  have ⟨_h_F_top, h_phi_and_H⟩ := h1
  have h2 := and_of_not_imp_not h_phi_and_H
  have ⟨_h_phi, h_H⟩ := h2
  apply h_G_not_H t le_rfl
  exact h_H
  ```
- [ ] Run `lake build Bimodal.Metalogic.Soundness` to verify

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - lines 573-576

**Verification**:
- `lake build` succeeds
- Proof correctly decomposes the conjunction using `and_of_not_imp_not`
- Witness for `F(H phi)` is `t` itself via `le_rfl`

---

### Phase 4: Temporal Duality Documentation [NOT STARTED]

**Goal**: Document why `temporal_duality` requires frame constraints and update comment

**Tasks**:
- [ ] Update comment at line 598-602 to explain the architectural constraint:
  ```lean
  | temporal_duality phi' d' ih =>
      -- ARCHITECTURAL LIMITATION: temporal_duality soundness requires
      -- [DenselyOrdered D] [Nontrivial D] constraints because it calls
      -- SoundnessLemmas.derivable_implies_swap_valid which has those constraints.
      --
      -- For soundness of derivations containing temporal_duality, use the
      -- soundness_dense theorem (line 701) which provides these constraints.
      -- This sorry is intentional and documents the frame-class restriction.
      sorry
  ```
- [ ] Run final `lake build` to verify no regressions

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - lines 598-602

**Verification**:
- Comment accurately explains the architectural reason
- References `soundness_dense` as the alternative for full soundness
- `lake build` shows exactly 1 sorry warning at line 602

## Testing & Validation

- [ ] `lake build` succeeds with only 1 sorry warning (temporal_duality at line 602)
- [ ] No new sorries introduced elsewhere
- [ ] Each filled proof follows the verified pattern from research
- [ ] Comments accurately document the reflexive semantics design decision
- [ ] `soundness_dense` remains the correct theorem for dense frame soundness

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Soundness.lean` - Modified with 4 filled sorries and 1 documented sorry
- `specs/059_prove_frame_specific_soundness_axioms/summaries/01_soundness-axioms-summary.md` - Implementation summary (created on completion)

## Rollback/Contingency

If any proof fails to compile:
1. Revert the specific sorry replacement using `git checkout -- Theories/Bimodal/Metalogic/Soundness.lean`
2. Use `lean_goal` at the sorry position to inspect expected type
3. Use `lean_multi_attempt` to test alternative proof terms
4. Consult `soundness_dense` (line 701+) for reference implementation patterns

If build introduces new errors:
1. Check for import changes or namespace conflicts
2. Run `lake clean && lake build` for clean rebuild
3. Verify no unintended edits outside the sorry locations
