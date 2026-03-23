# Implementation Plan: Task #48 (v4)

- **Task**: 48 - prove_succ_chain_fam_bounded_f_depth
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: Task 47 (completed)
- **Research Inputs**:
  - specs/048_prove_succ_chain_fam_bounded_f_depth/reports/06_team-research.md
- **Previous Plans**:
  - plans/01_restricted-succ-chain.md (phases 1-2 partial)
  - plans/02_augmented-closure.md (phases 0-3 complete, 4-6 blocked)
  - plans/03_restricted-p-step.md (phase 1 blocked - theorem FALSE as stated)
- **Artifacts**: plans/04_restricted-blocking.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan addresses the v3 blocker where `p_step_blocking_for_deferral_restricted` was found to be **FALSE as stated**. Team research (both teammates independently) confirmed the counterexample and converged on the same solution: define `p_step_blocking_formulas_restricted` that only considers formulas where `P(chi)` is in `deferralClosure`.

The key mathematical insight is that we don't need to block `P(chi)` where `P(chi) NOT IN deferralClosure` because such formulas **cannot appear in the successor anyway** - the Lindenbaum extension only adds formulas from `deferralClosure`.

### Research Integration

Key findings from `06_team-research.md`:
- **Counterexample proven**: If `P(psi) NOT in deferralClosure`, then `H(neg psi) NOT in deferralClosure`, but `H(neg psi) IN p_step_blocking_formulas u` by construction
- **Solution**: Define restricted blocking that only considers `P(chi)` where `P(chi) IN deferralClosure`
- **Recommended definition**: Use `P(chi) IN deferralClosure` as the restriction predicate (directly matches proof structure)
- **Confidence**: HIGH from both teammates

### What Previous Plans Accomplished

| Version | Status | Key Work |
|---------|--------|----------|
| v1 | Partial | `RestrictedSerialMCS`, P-nesting infrastructure |
| v2 | Phases 0-3 complete | `deferralClosure`, F/P-depth bounds, `DeferralRestrictedMCS` |
| v3 | Phase 1 blocked | Discovered `p_step_blocking_for_deferral_restricted` is FALSE |
| v4 (this) | Planned | Define restricted blocking, fix the construction |

## Goals & Non-Goals

**Goals**:
- Define `p_step_blocking_formulas_restricted` with `P(chi) IN deferralClosure` condition
- Prove the restricted blocking subset theorem (replaces false theorem from v3)
- Update `constrained_successor_seed` to use restricted blocking
- Prove P-step property for the restricted construction
- Update chain construction to use restricted successor
- Remove the deprecated sorries in `f_nesting_is_bounded` and `p_nesting_is_bounded`

**Non-Goals**:
- Changing the fundamental structure of the completeness proof
- Proving full MCS properties for DeferralRestrictedMCS (not needed)
- Modifying the Succ relation definition

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Restricted blocking breaks P-step property | High | Low | Research verified this works mathematically |
| Need symmetric F-direction restriction | Medium | Medium | Apply same pattern for G-step blocking if needed |
| Chain construction complexity | Medium | Low | Same structure, just using restricted definitions |
| Additional structural lemmas needed | Low | Medium | Research identified `some_past_of_subformula_in_closureWithNeg` may be needed |

## Implementation Phases

### Phase 1: Define Restricted P-Step Blocking [COMPLETED]

**Goal**: Create the mathematically correct restricted blocking definition.

**Tasks**:
- [ ] Add `p_step_blocking_formulas_restricted` to SuccExistence.lean:
  ```lean
  /-- P-step blocking formulas restricted to the deferral closure.
      Only blocks P(chi) where P(chi) could actually appear in the successor.
      This is the correct definition - the unrestricted version is false for
      DeferralRestrictedMCS (see research report 06_team-research.md). -/
  def p_step_blocking_formulas_restricted (phi : Formula) (u : Set Formula) : Set Formula :=
    {psi | exists chi : Formula,
           Formula.some_past chi IN deferralClosure phi AND
           Formula.some_past chi NOT IN u AND
           chi NOT IN u AND
           psi = Formula.all_past (Formula.neg chi)}
  ```
- [ ] Prove `p_step_blocking_restricted_subset_deferralClosure`:
  ```lean
  theorem p_step_blocking_restricted_subset_deferralClosure (phi : Formula) (u : Set Formula) :
      p_step_blocking_formulas_restricted phi u SUBSET (deferralClosure phi : Set Formula)
  ```
  (Follows from definition: if `P(chi) IN deferralClosure`, then `H(neg chi) IN deferralClosure`)

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Add restricted blocking definition

**Verification**:
- `lake build` succeeds
- Definition compiles without errors

---

### Phase 2: Prove Restricted Blocking Subset Theorem [COMPLETED]

**Goal**: Prove the restricted blocking formulas stay in the MCS.

**Tasks**:
- [ ] Add `p_step_blocking_restricted_subset` to RestrictedMCS.lean:
  ```lean
  /-- P-step blocking formulas (restricted) are subset of u for DeferralRestrictedMCS.
      This is exactly the "Case 1" proof from the original attempt - the case where
      P(psi) IN deferralClosure. The "Case 2" where P(psi) NOT IN deferralClosure
      is now excluded by definition. -/
  theorem p_step_blocking_restricted_subset (phi : Formula) (u : Set Formula)
      (h_drm : DeferralRestrictedMCS phi u) :
      p_step_blocking_formulas_restricted phi u SUBSET u := by
    intro psi mem psi, chi, h_P_in_dc, h_P_not_in, h_chi_not_in, rfl mem
    -- This is the existing "Case 1" proof (lines 959-1059 of RestrictedMCS.lean)
    -- The hypothesis h_P_in_dc matches the by_cases condition that was true
    ...
  ```
- [ ] Extract and adapt the existing "Case 1" proof from lines 959-1059
- [ ] Verify the proof goes through without the problematic else branch

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Add restricted blocking theorem

**Verification**:
- `lake build` succeeds
- No sorries in the new theorem
- Proof uses existing Case 1 logic

---

### Phase 3: Update Constrained Successor Seed [COMPLETED]

**Goal**: Use restricted blocking in the successor seed construction.

**Tasks**:
- [ ] Define `constrained_successor_seed_restricted`:
  ```lean
  /-- Constrained successor seed using restricted P-step blocking.
      This is the correct version that stays within deferralClosure. -/
  def constrained_successor_seed_restricted (phi : Formula) (u : Set Formula) : Set Formula :=
    g_content u UNION deferralDisjunctions u UNION p_step_blocking_formulas_restricted phi u
  ```
- [ ] Prove `constrained_successor_seed_restricted_subset_deferralClosure`:
  ```lean
  theorem constrained_successor_seed_restricted_subset_deferralClosure (phi : Formula) (u : Set Formula)
      (h_drm : DeferralRestrictedMCS phi u) :
      constrained_successor_seed_restricted phi u SUBSET (deferralClosure phi : Set Formula)
  ```
  (Uses existing g_content and deferralDisjunctions subset lemmas from v2)
- [ ] Prove `constrained_successor_seed_restricted_consistent`:
  ```lean
  theorem constrained_successor_seed_restricted_consistent (phi : Formula) (u : Set Formula)
      (h_drm : DeferralRestrictedMCS phi u)
      (h_F_top : Formula.some_future (Formula.neg Formula.bot) IN u) :
      SetConsistent (constrained_successor_seed_restricted phi u)
  ```

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Add restricted seed

**Verification**:
- `lake build` succeeds
- Seed is proven consistent and within deferralClosure

---

### Phase 4: Prove P-Step Property for Restricted Construction [COMPLETED]

**Goal**: Prove the restricted construction satisfies the P-step relation.

**Tasks**:
- [ ] Prove `p_step_for_restricted_successor`:
  ```lean
  /-- The restricted successor construction satisfies P_step.

      For any P(chi) in the successor v:
      1. Either chi IN u (so P(chi) IN p_content(u)) checkmark
      2. Or P(chi) IN u checkmark
      3. Or chi NOT IN u AND P(chi) NOT IN u -> blocking formula H(neg chi) prevents P(chi) in v

      The restriction to P(chi) IN deferralClosure is safe because the Lindenbaum
      extension only adds formulas from deferralClosure anyway. -/
  theorem p_step_for_restricted_successor (phi : Formula) (u : Set Formula)
      (h_drm : DeferralRestrictedMCS phi u)
      (v : Set Formula)
      (h_v_mcs : SetMaximalConsistent v)
      (h_v_from_seed : constrained_successor_seed_restricted phi u SUBSET v) :
      P_step u v
  ```
- [ ] Build `constrained_successor_restricted`:
  ```lean
  noncomputable def constrained_successor_restricted (phi : Formula) (u : Set Formula)
      (h_drm : DeferralRestrictedMCS phi u)
      (h_F_top : Formula.some_future (Formula.neg Formula.bot) IN u) :
      DeferralRestrictedMCS phi
  ```
- [ ] Prove `constrained_successor_restricted_succ`:
  ```lean
  theorem constrained_successor_restricted_succ (phi : Formula) (u : Set Formula)
      (h_drm : DeferralRestrictedMCS phi u)
      (h_F_top : Formula.some_future (Formula.neg Formula.bot) IN u) :
      Succ u (constrained_successor_restricted phi u h_drm h_F_top).world
  ```

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - P-step property and successor
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Helper lemmas if needed

**Verification**:
- `lake build` succeeds
- P-step and Succ relations proven without sorries

---

### Phase 5: Update Chain Construction and Remove Sorries [PARTIAL]

**2026-03-23 Update (Session sess_1774297366_a2de0b)**:
- FIXED: `F_top_in_restricted_successor` (~line 1822-2055) - Proof complete, no sorry
  - Used disjunction elimination argument mirroring `constrained_successor_restricted_f_step`
  - Key insight: F_top is a theorem, so any consistent set must contain it if F_top is in deferralClosure
- PARTIAL: `restricted_forward_chain_iter_F_witness` (~line 2213-2260)
  - The "depth decrease" case (inl branch) is fully proven using strong induction
  - The "persistence" case (inr branch) has sorry - requires well-founded recursion on combined measure
  - Mathematical argument is valid (documented in comments), but formal proof needs infrastructure

**2026-03-23 Update (Session sess_1774298091_fcd47e)**:
- SIMPLIFIED: `restricted_forward_chain_iter_F_witness` (~line 2195-2261)
  - Consolidated the complex branching structure into a cleaner proof
  - The "depth decrease" case (inl branch) remains fully proven
  - The "persistence" case (inr branch) is documented with a single sorry at line 2261
  - Key mathematical insight documented: F-boundedness + negation completeness bounds persistence
  - The theorem is only used with d = 1 in `restricted_forward_chain_forward_F`
- STATUS: Phase remains PARTIAL due to the persistence case sorry
  - Mathematical validity confirmed
  - Formal proof requires well-founded recursion infrastructure (future task)

**Goal**: Build the restricted chain and remove deprecated sorries.

**Tasks**:
- [ ] Define `restricted_forward_chain`:
  ```lean
  noncomputable def restricted_forward_chain (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) :
      Nat -> DeferralRestrictedMCS phi
    | 0 => M0.toDeferralRestrictedMCS
    | n + 1 => constrained_successor_restricted phi
        (restricted_forward_chain phi M0 n).world
        (restricted_forward_chain phi M0 n)
        (restricted_forward_chain_F_top phi M0 n)
  ```
- [ ] Prove `restricted_forward_chain_succ`: Each step satisfies Succ
- [ ] Define symmetric `restricted_backward_chain` for P-direction
- [ ] Define `restricted_succ_chain_fam` combining forward and backward
- [ ] Prove F/P-nesting coherence using `deferral_restricted_mcs_F_bounded`/`P_bounded`
- [ ] Remove deprecated sorry at `f_nesting_is_bounded` (or delete definition)
- [ ] Remove deprecated sorry at `p_nesting_is_bounded` (or delete definition)
- [ ] Add coercion from `restricted_succ_chain_fam` to standard chain type

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Chain construction and coherence

**Verification**:
- `lake build` succeeds
- `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean | grep -c "nesting_is_bounded"` returns 0
- F/P/G/H coherence proven without sorries

---

## Testing & Validation

- [ ] `lake build` succeeds with no new errors
- [ ] `grep -r "f_nesting_is_bounded\|p_nesting_is_bounded" Theories/` shows deprecated or removed
- [ ] The sorry at RestrictedMCS.lean:1124 (the "else" branch) is removed or unreachable
- [ ] Total project sorry count decreases by at least 2
- [ ] Documentation comments explain why restricted blocking is mathematically correct

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Restricted blocking definitions
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Restricted blocking subset theorem
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Restricted chain + coherence proofs
- `specs/048_prove_succ_chain_fam_bounded_f_depth/summaries/04_restricted-blocking-summary.md` - Implementation summary

## Rollback/Contingency

If implementation proves more complex than expected:

1. **Phase 1-2 complexity**: If extracting Case 1 proof is difficult, may need to refactor the original proof structure. Can mark partial and continue.

2. **Phase 4 blocks**: If P-step property proof is complex, examine whether additional structural lemmas about deferralClosure are needed.

3. **Phase 5 blocks**: If chain coherence is complex, complete forward-only chain first, then add backward chain as follow-up task.

4. **G-step symmetry needed**: If similar issues arise for F/G direction, apply the same restricted definition pattern.

## Notes

- **Key mathematical insight**: We don't need to block `P(chi)` where `P(chi) NOT IN deferralClosure` because such formulas cannot appear in the successor anyway.
- **Research confidence**: Both teammates independently verified the solution with HIGH confidence.
- **Prior art**: This matches the standard pattern from modal logic literature (Venema, Goldblatt, BdRV) of working within closure from the start.
- The v3 "Case 1" proof (lines 959-1059) is exactly what we need - we just exclude Case 2 by definition.
- The counterexample construction showed precisely why Case 2 was impossible: `H(neg psi) NOT IN u` when `P(psi) NOT IN deferralClosure`.
