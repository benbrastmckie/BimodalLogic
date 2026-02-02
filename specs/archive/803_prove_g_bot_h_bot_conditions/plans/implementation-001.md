# Implementation Plan: Task #803

- **Task**: 803 - prove_g_bot_h_bot_conditions
- **Status**: [COMPLETED]
- **Effort**: 0.5 hours
- **Dependencies**: None (all required lemmas exist)
- **Research Inputs**: specs/803_prove_g_bot_h_bot_conditions/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task completes two `sorry` proofs in `UniversalCanonicalModel.lean` (lines 83-86) that establish boundary conditions for the representation theorem. The proofs show that `G bot` (all-future falsity) and `H bot` (all-past falsity) cannot be members of a maximal consistent set, using T-axioms already proven in `IndexedMCSFamily.lean`.

### Research Integration

Research report `research-001.md` provides two implementation options:
- **Option 1 (Recommended)**: Use `mcs_closed_temp_t_future` / `mcs_closed_temp_t_past` helper lemmas (5 lines per proof)
- **Option 2**: Direct T-axiom application (15 lines per proof)

This plan follows Option 1 as it reuses existing infrastructure and matches the style in `TruthLemma.lean`.

## Goals & Non-Goals

**Goals**:
- Replace the two `sorry` proofs for `h_no_G_bot` and `h_no_H_bot` in `representation_theorem`
- Ensure `representation_theorem` compiles without `sorry`
- Reduce project sorry count by 2

**Non-Goals**:
- Modifying other sorries in `UniversalCanonicalModel.lean` (lines 164, 182)
- Refactoring the representation theorem structure
- Adding new lemmas to other files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Helper lemmas unavailable | Medium | Very Low | Lemmas verified in IndexedMCSFamily.lean lines 257-296 |
| Import issues | Low | Very Low | TruthLemma.lean already imports required modules |

## Implementation Phases

### Phase 1: Implement G_bot/H_bot Proofs [COMPLETED]

**Goal**: Replace both `sorry` statements with working proofs using T-axiom closure lemmas.

**Tasks**:
- [ ] Read UniversalCanonicalModel.lean to confirm exact sorry locations (lines 83-86)
- [ ] Replace `h_no_G_bot` sorry (line 84) with proof using `mcs_closed_temp_t_future`
- [ ] Replace `h_no_H_bot` sorry (line 86) with proof using `mcs_closed_temp_t_past`
- [ ] Run `lake build` to verify compilation
- [ ] Confirm `representation_theorem` has no sorries

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean` - lines 83-86

**Proof Pattern for h_no_G_bot**:
```lean
have h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma := by
  intro h_G_bot_in
  -- If G bot in Gamma, then bot in Gamma by T-axiom closure
  have h_bot_in : Formula.bot ∈ Gamma :=
    mcs_closed_temp_t_future h_mcs Formula.bot h_G_bot_in
  -- But bot in Gamma contradicts MCS consistency
  apply h_mcs.1 [Formula.bot]
  · intro psi hpsi; simp at hpsi; rw [hpsi]; exact h_bot_in
  · constructor
    exact DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
```

**Proof Pattern for h_no_H_bot**:
```lean
have h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma := by
  intro h_H_bot_in
  have h_bot_in : Formula.bot ∈ Gamma :=
    mcs_closed_temp_t_past h_mcs Formula.bot h_H_bot_in
  apply h_mcs.1 [Formula.bot]
  · intro psi hpsi; simp at hpsi; rw [hpsi]; exact h_bot_in
  · constructor
    exact DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
```

**Verification**:
- `lake build` completes without errors
- `representation_theorem` has no sorries

---

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `grep -n "sorry" Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean` shows sorries only on lines 164, 182 (other theorems)
- [ ] The proofs correctly use `mcs_closed_temp_t_future` and `mcs_closed_temp_t_past`

## Artifacts & Outputs

- `specs/803_prove_g_bot_h_bot_conditions/plans/implementation-001.md` (this file)
- `specs/803_prove_g_bot_h_bot_conditions/summaries/implementation-summary-20260202.md` (after completion)
- Modified file: `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean`

## Rollback/Contingency

If the proofs fail to compile:
1. Revert changes with `git checkout -- Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean`
2. Review error messages and adjust proof structure
3. Consider Option 2 (direct T-axiom application) from research report if helper lemmas are insufficient
