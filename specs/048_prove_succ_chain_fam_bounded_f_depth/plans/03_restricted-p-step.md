# Implementation Plan: Task #48 (v3)

- **Task**: 48 - prove_succ_chain_fam_bounded_f_depth
- **Status**: [IN PROGRESS]
- **Effort**: 4 hours
- **Dependencies**: Task 47 (completed)
- **Research Inputs**:
  - specs/048_prove_succ_chain_fam_bounded_f_depth/reports/03_blocker-analysis.md
  - specs/048_prove_succ_chain_fam_bounded_f_depth/summaries/02_augmented-closure-summary.md
- **Previous Plan**: plans/02_augmented-closure.md (phases 0-3 complete, phases 4-6 blocked)
- **Artifacts**: plans/03_restricted-p-step.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan implements **Path 2** from the blocker analysis: prove that `p_step_blocking_formulas` stays within the MCS for `DeferralRestrictedMCS` by leveraging existing negation completeness for closure formulas.

### Key Mathematical Insight

The blockeranalysis revealed that full MCS negation completeness is NOT needed. The `p_step_blocking_formulas` only considers `P(φ)` formulas where `φ` arises from the seed construction. All such `φ` are in `subformulaClosure`, so `deferral_restricted_mcs_negation_complete` (RestrictedMCS.lean:774-849) applies directly.

### What v2 Accomplished

| Phase | Status | Description |
|-------|--------|-------------|
| 0 | COMPLETED | Closure question analysis |
| 1 | COMPLETED | `deferralClosure` definitions in SubformulaClosure.lean |
| 2 | COMPLETED | F/P-depth bounding proofs |
| 3 | COMPLETED | `DeferralRestrictedMCS` + Lindenbaum + F/P-bounded |
| 4 | PARTIAL | Seed subset lemmas proven; chain construction blocked |
| 5-6 | BLOCKED | Required full MCS properties |

### v3 Strategy

Replace blocked phases 4-6 with a 3-phase approach using restricted P-step:
1. Prove restricted P-step blocking lemma using existing negation completeness
2. Update `constrained_successor` to use `DeferralRestrictedMCS`
3. Build restricted chain and prove coherence

## Goals & Non-Goals

**Goals**:
- Prove `p_step_blocking_for_deferral_restricted`: P-step blocking stays in restricted MCS
- Update `constrained_successor_from_seed` to use `deferral_restricted_lindenbaum`
- Define `restricted_forward_chain` producing `DeferralRestrictedMCS` elements
- Prove F/P-nesting coherence using existing `deferral_restricted_mcs_F_bounded`
- Remove the 2 deprecated F/P boundedness sorries

**Non-Goals**:
- Proving full MCS properties for DeferralRestrictedMCS (not needed)
- Changing the fundamental structure of the completeness proof
- Modifying the Succ relation definition

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| P-step blocking needs formulas outside subformulaClosure | High | Low | Blocker analysis verified all P(φ) come from closure |
| Negation completeness insufficient for H(neg φ) | Medium | Low | `double_neg_elim` follows from deduction closure |
| Chain consistency proof breaks | Medium | Low | Same structure, just restricted domain |
| Type coercion complexity | Medium | Medium | Define explicit lift functions |

## Implementation Phases

### Phase 1: Prove Restricted P-Step Blocking [PARTIAL]

**Goal**: Prove that `p_step_blocking_formulas u ⊆ u` for `DeferralRestrictedMCS`.

**The Key Lemma**:
```lean
/-- P-step blocking formulas stay in u when u is a DeferralRestrictedMCS.

The proof exploits that p_step_blocking_formulas only considers P(φ) where φ
arises from seed elements. Since u ⊆ deferralClosure(psi), all such φ are in
subformulaClosure(psi), so deferral_restricted_mcs_negation_complete applies.
-/
theorem p_step_blocking_for_deferral_restricted (psi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS psi u) :
    p_step_blocking_formulas u ⊆ u
```

**Proof Strategy**:
1. Take `χ ∈ p_step_blocking_formulas u`
2. By definition, `χ = H(neg φ)` for some `φ` with `P(φ) ∉ u` and `φ ∉ u`
3. Show `P(φ) ∈ subformulaClosure psi` (from closure structure)
4. Apply `deferral_restricted_mcs_negation_complete` to get `P(φ) ∈ u ∨ neg P(φ) ∈ u`
5. Since `P(φ) ∉ u`, we have `neg P(φ) ∈ u`
6. Use deduction to derive `H(neg φ) ∈ u`

**Prerequisites** (may need to prove):
```lean
-- P(φ) in deferralClosure implies φ in subformulaClosure
theorem some_past_in_deferralClosure_inner_in_subformulaClosure (psi φ : Formula)
    (h : Formula.some_past φ ∈ deferralClosure psi) :
    φ ∈ subformulaClosure psi
```

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - add restricted P-step theorem
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - add prerequisite lemmas if needed

**Verification**:
- `lake build` succeeds
- No new sorries

---

### Phase 2: Update Constrained Successor Construction [NOT STARTED]

**Goal**: Replace `lindenbaumMCS_set` with `deferral_restricted_lindenbaum` in successor construction.

**Tasks**:

1. **Define restricted constrained successor**:
```lean
/-- Build constrained successor using deferral-restricted Lindenbaum.
Returns a DeferralRestrictedMCS that satisfies Succ with the input. -/
noncomputable def constrained_successor_restricted (psi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS psi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    DeferralRestrictedMCS psi :=
  ⟨Classical.choose (deferral_restricted_lindenbaum psi
      (constrained_successor_seed u)
      (constrained_successor_seed_restricted_consistent psi u h_drm h_F_top)
      (constrained_successor_seed_subset_deferralClosure psi u h_drm.subset)),
   Classical.choose_spec ...⟩
```

2. **Prove seed consistency for restricted case**:
```lean
theorem constrained_successor_seed_restricted_consistent (psi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS psi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    SetConsistent (constrained_successor_seed u)
```

   Uses `p_step_blocking_for_deferral_restricted` from Phase 1.

3. **Prove Succ relation holds**:
```lean
theorem constrained_successor_restricted_succ (psi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS psi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    Succ u.world (constrained_successor_restricted psi u h_drm h_F_top).world
```

4. **Define symmetric predecessor construction**:
```lean
noncomputable def constrained_predecessor_restricted (psi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS psi u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    DeferralRestrictedMCS psi
```

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - add restricted versions
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - helper lemmas

**Verification**:
- `lake build` succeeds
- Restricted successor/predecessor satisfy Succ/P_step
- No new sorries

---

### Phase 3: Build Restricted Chain and Prove Coherence [NOT STARTED]

**Goal**: Define `restricted_succ_chain_fam` and prove F/P-nesting coherence.

**Tasks**:

1. **Define restricted forward chain**:
```lean
/-- Forward chain where each element is a DeferralRestrictedMCS. -/
noncomputable def restricted_forward_chain (psi : Formula)
    (M0 : DeferralRestrictedSerialMCS psi) :
    Nat → DeferralRestrictedMCS psi
  | 0 => M0.toDeferralRestrictedMCS
  | n + 1 => constrained_successor_restricted psi
      (restricted_forward_chain psi M0 n).world
      (restricted_forward_chain psi M0 n)
      (restricted_forward_chain_F_top psi M0 n)
```

2. **Define restricted backward chain** (symmetric for P-direction)

3. **Define combined bi-directional chain**:
```lean
noncomputable def restricted_succ_chain_fam (psi : Formula)
    (M0 : DeferralRestrictedSerialMCS psi) :
    Int → DeferralRestrictedMCS psi :=
  fun i => if i ≥ 0 then restricted_forward_chain psi M0 i.toNat
           else restricted_backward_chain psi M0 (-i).toNat
```

4. **Prove F-nesting coherence**:
```lean
theorem restricted_succ_chain_forward_F (psi : Formula)
    (M0 : DeferralRestrictedSerialMCS psi)
    (i : Int) (φ : Formula)
    (h_F : Formula.some_future φ ∈ (restricted_succ_chain_fam psi M0 i).world) :
    ∃ j > i, φ ∈ (restricted_succ_chain_fam psi M0 j).world
```

   Uses `deferral_restricted_mcs_F_bounded` to bound the search.

5. **Prove P-nesting coherence** (symmetric)

6. **Prove G/H coherence** (follows from F/P coherence)

7. **Define coercion to standard chain** for completeness theorem:
```lean
def restricted_chain_to_standard (psi : Formula)
    (M0 : DeferralRestrictedSerialMCS psi) :
    Int → Set Formula :=
  fun i => (restricted_succ_chain_fam psi M0 i).world
```

8. **Remove deprecated sorries**:
   - Delete `f_nesting_is_bounded` (replaced by `deferral_restricted_mcs_F_bounded`)
   - Delete `p_nesting_is_bounded` (replaced by `deferral_restricted_mcs_P_bounded`)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - restricted chain + coherence

**Verification**:
- `lake build` succeeds
- F/P/G/H coherence proven without sorries
- Total sorry count decreases by 2

---

## Testing & Validation

- [ ] `lake build` succeeds with no new errors
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` shows 0 F/P boundedness sorries
- [ ] `grep -r "f_nesting_is_bounded\|p_nesting_is_bounded" Theories/` shows deprecated or removed
- [ ] `lean_verify` on key theorems shows no axioms beyond standard
- [ ] Total project sorry count decreases by at least 2

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - `p_step_blocking_for_deferral_restricted`
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - restricted successor/predecessor
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - restricted chain + coherence proofs
- `specs/048_prove_succ_chain_fam_bounded_f_depth/summaries/03_restricted-p-step-summary.md` - implementation summary

## Rollback/Contingency

If implementation proves more complex than expected:

1. **Phase 1 blocks**: If P-step blocking requires formulas outside subformulaClosure, need to extend `deferralClosure` to include those formulas and prove extended negation completeness.

2. **Phase 2 blocks**: If seed consistency proof fails, may need to strengthen the prerequisite lemmas from Phase 1.

3. **Phase 3 blocks**: If coherence proof is complex, can complete forward-only chain first, then add backward chain as follow-up.

## Notes

- The critical insight from blocker analysis: we don't need full MCS, just negation completeness for formulas in the closure.
- `deferral_restricted_mcs_negation_complete` already exists (RestrictedMCS.lean:774-849).
- All three phases build on Phase 4 work from v2 (seed subset lemmas are already proven).
- The 2 deprecated sorries (`f_nesting_is_bounded`, `p_nesting_is_bounded`) can be deleted once coherence is proven.
