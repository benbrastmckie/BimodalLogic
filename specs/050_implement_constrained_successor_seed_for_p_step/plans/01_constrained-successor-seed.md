# Implementation Plan: Constrained Successor Seed for P-Step

- **Task**: 50 - implement_constrained_successor_seed_for_p_step
- **Status**: [NOT STARTED]
- **Effort**: 3-4 hours
- **Dependencies**: Task 34 (completed - constrained predecessor seed pattern)
- **Research Inputs**: specs/050_implement_constrained_successor_seed_for_p_step/reports/02_research.md
- **Artifacts**: plans/01_constrained-successor-seed.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Implement the symmetric counterpart to task 34's constrained predecessor seed. The goal is to eliminate the sorry at SuccChainFMCS.lean:350-370 by proving `successor_p_step` directly via a constrained successor seed construction. The constrained successor seed adds P-step blocking formulas `{H(neg phi) | P(phi) not in u and phi not in u}` that prevent "bad" P-formulas from appearing in the successor.

### Research Integration

Key findings from 02_research.md:
- P-step blocking formula definition: `{H(neg phi) | P(phi) not in u and phi not in u}`
- Subset proof path: `P(phi) = neg(H(neg(phi)))`, so `neg(P(phi))` double-neg-eliminates to `H(neg phi)`
- The `predecessor_f_step` proof (SuccExistence.lean:630-661) provides the exact template
- All required infrastructure exists (SetMaximalConsistent.negation_complete, double_neg_elim, set_consistent_not_both)

## Goals & Non-Goals

**Goals**:
- Define `p_step_blocking_formulas` (symmetric to `f_step_blocking_formulas`)
- Define `constrained_successor_seed` (extends `successor_deferral_seed` with blocking formulas)
- Prove `p_step_blocking_formulas_subset_u`
- Prove `constrained_successor_seed_consistent`
- Define `constrained_successor_from_seed` (Lindenbaum extension)
- Prove `successor_p_step` theorem
- Fill the sorry at SuccChainFMCS.lean:350-370 using `successor_p_step`

**Non-Goals**:
- Modifying the existing `successor_from_deferral_seed` (preserved for compatibility)
- Changing the Succ relation definition
- Modifying the forward_chain construction (interface unchanged)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Type mismatches in P/H duality | M | L | Follow exact pattern from f_step_blocking_formulas |
| Consistency proof diverges from template | L | L | seed subset u is the key insight (proven for predecessor) |
| Integration with forward_chain | M | L | successor_p_step provides the theorem, forward_chain calls it |
| Build regressions | M | L | Run lake build after each phase |

## Implementation Phases

### Phase 1: Define P-Step Blocking Formulas [NOT STARTED]

**Goal**: Create the blocking formula definitions symmetric to f_step_blocking_formulas

**Tasks**:
- [ ] Define `p_step_blocking_formulas` in SuccExistence.lean:
  ```lean
  def p_step_blocking_formulas (u : Set Formula) : Set Formula :=
    {psi | exists phi : Formula, Formula.some_past phi not in u and phi not in u and
      psi = Formula.all_past (Formula.neg phi)}
  ```
- [ ] Add membership lemma `mem_p_step_blocking_formulas_iff`
- [ ] Add subset lemma `p_step_blocking_formulas_subset_successor_seed` (for later use)
- [ ] Verify definitions compile with `lake build`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` (after line 126, before Phase 1 Predecessor section)

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Bundle.SuccExistence` succeeds

---

### Phase 2: Define Constrained Successor Seed [NOT STARTED]

**Goal**: Create the extended seed definition with P-step blocking formulas

**Tasks**:
- [ ] Define `constrained_successor_seed`:
  ```lean
  def constrained_successor_seed (u : Set Formula) : Set Formula :=
    g_content u union deferralDisjunctions u union p_step_blocking_formulas u
  ```
- [ ] Add membership lemma `mem_constrained_successor_seed_iff`
- [ ] Add subset lemmas for each component
- [ ] Verify definitions compile

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- `lake build` succeeds

---

### Phase 3: Prove Blocking Formulas Subset Property [NOT STARTED]

**Goal**: Prove `p_step_blocking_formulas(u) subset u` for MCS u

**Tasks**:
- [ ] Prove `p_step_blocking_formulas_subset_u`:
  ```lean
  theorem p_step_blocking_formulas_subset_u
      (u : Set Formula) (h_mcs : SetMaximalConsistent u) :
      p_step_blocking_formulas u subset u := by
    intro chi h_block
    obtain <phi, h_P_not, _, rfl> := h_block
    -- P(phi) not in u means neg(P(phi)) in u. By negation completeness, neg(P(phi)) in u.
    -- neg(P(phi)) = neg(neg(H(neg(phi)))) (since P = neg . H . neg)
    -- By double negation elimination: H(neg phi) in u.
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.some_past phi) with h_in | h_neg_in
    . exact absurd h_in h_P_not
    . exact SetMaximalConsistent.double_neg_elim h_mcs _ h_neg_in
  ```

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- Lemma compiles without sorry

---

### Phase 4: Prove Constrained Seed Consistency [NOT STARTED]

**Goal**: Prove the constrained successor seed is consistent

**Tasks**:
- [ ] Prove `constrained_successor_seed_consistent`:
  ```lean
  theorem constrained_successor_seed_consistent (u : Set Formula)
      (h_mcs : SetMaximalConsistent u)
      (h_F_top : Formula.some_future (Formula.neg Formula.bot) in u) :
      SetConsistent (constrained_successor_seed u) := by
    -- Show each component is a subset of u
    have h_g_in_u : g_content u subset u := g_content_subset_mcs h_mcs
    have h_deferrals_in_u : deferralDisjunctions u subset u := ...
    have h_blocking_in_u : p_step_blocking_formulas u subset u := p_step_blocking_formulas_subset_u u h_mcs
    -- Combine to show constrained_successor_seed u subset u
    have h_seed_subset_u : constrained_successor_seed u subset u := ...
    -- Subset of consistent set is consistent
    intro L hL_sub <d>
    exact h_mcs.1 L (fun chi h => h_seed_subset_u (hL_sub chi h)) <d>
  ```

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- Theorem compiles without sorry
- Follows pattern from `predecessor_deferral_seed_consistent_axiom` at lines 360-428

---

### Phase 5: Define Constrained Successor Construction [NOT STARTED]

**Goal**: Create the Lindenbaum extension and basic properties

**Tasks**:
- [ ] Define `constrained_successor_from_seed`:
  ```lean
  noncomputable def constrained_successor_from_seed
      (u : Set Formula) (h_mcs : SetMaximalConsistent u)
      (h_F_top : Formula.some_future (Formula.neg Formula.bot) in u) :
      Set Formula :=
    lindenbaumMCS_set (constrained_successor_seed u)
      (constrained_successor_seed_consistent u h_mcs h_F_top)
  ```
- [ ] Prove `constrained_successor_from_seed_mcs`
- [ ] Prove `constrained_successor_from_seed_extends`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- All definitions and lemmas compile

---

### Phase 6: Prove Successor P-Step Theorem [NOT STARTED]

**Goal**: Prove the main theorem `successor_p_step`

**Tasks**:
- [ ] Prove `successor_p_step` (following `predecessor_f_step` template at lines 630-661):
  ```lean
  theorem successor_p_step
      (u : Set Formula) (h_mcs : SetMaximalConsistent u)
      (h_F_top : Formula.some_future (Formula.neg Formula.bot) in u) :
      p_content (constrained_successor_from_seed u h_mcs h_F_top) subset u union p_content u := by
    intro phi h_phi_in_p_content
    by_cases h_phi_in_u : phi in u
    . exact Set.mem_union_left _ h_phi_in_u
    . by_cases h_P_phi_in_u : Formula.some_past phi in u
      . exact Set.mem_union_right _ h_P_phi_in_u
      . -- Contradiction case: H(neg phi) in seed, P(phi) in successor
        have h_block : Formula.all_past (Formula.neg phi) in p_step_blocking_formulas u :=
          <phi, h_P_phi_in_u, h_phi_in_u, rfl>
        have h_in_seed : Formula.all_past (Formula.neg phi) in constrained_successor_seed u := ...
        have h_in_succ : Formula.all_past (Formula.neg phi) in
            constrained_successor_from_seed u h_mcs h_F_top := ...
        have h_P_in_succ : Formula.some_past phi in
            constrained_successor_from_seed u h_mcs h_F_top := h_phi_in_p_content
        -- P(phi) = neg(H(neg phi)) by definition (some_past phi = neg (all_past (neg phi)))
        -- So we have both H(neg phi) and neg(H(neg phi)) in successor, contradiction
        have h_mcs_succ := constrained_successor_from_seed_mcs u h_mcs h_F_top
        exact False.elim (set_consistent_not_both h_mcs_succ.1
          (Formula.all_past (Formula.neg phi)) h_in_succ h_P_in_succ)
  ```

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- Theorem compiles without sorry
- `lean_goal` shows proof is complete

---

### Phase 7: Fill SuccChainFMCS Sorry [NOT STARTED]

**Goal**: Use `successor_p_step` to fill the sorry at SuccChainFMCS.lean:350-370

**Tasks**:
- [ ] Examine the forward_chain construction in SuccChainFMCS.lean
- [ ] Determine if forward_chain needs to use constrained_successor_from_seed (likely yes)
- [ ] Option A: Update `ForwardChainElement.next` to use constrained_successor_from_seed
- [ ] Option B: Prove forward_chain inherits p_step property via the existing construction
- [ ] Fill the sorry using successor_p_step
- [ ] Verify no new sorries introduced

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (lines 350-370)
- Possibly `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` (if construction update needed)

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Bundle.SuccChainFMCS` succeeds
- No sorries in `succ_chain_fam_p_step`

---

### Phase 8: Verification and Cleanup [NOT STARTED]

**Goal**: Verify full integration and clean up

**Tasks**:
- [ ] Run full `lake build` to verify all dependent files compile
- [ ] Grep for remaining sorries in SuccExistence.lean and SuccChainFMCS.lean
- [ ] Verify `succ_chain_backward_P` still compiles (uses succ_chain_fam_p_step)
- [ ] Update docstrings to reflect proven theorem (remove "axiom" references)
- [ ] Clean up any temporary code or comments

**Timing**: 30 minutes

**Files to check**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- Files that import these modules

**Verification**:
- `lake build` succeeds with no warnings
- No sorries in the target theorems
- All FMCS coherence theorems still work

## Testing & Validation

- [ ] `lake build` succeeds with zero sorries in successor_p_step and succ_chain_fam_p_step
- [ ] `succ_chain_backward_P` compiles successfully
- [ ] No new sorries introduced elsewhere
- [ ] Full `lake build` completes without errors

## Artifacts & Outputs

- `specs/050_implement_constrained_successor_seed_for_p_step/plans/01_constrained-successor-seed.md` (this file)
- `specs/050_implement_constrained_successor_seed_for_p_step/summaries/01_implementation-summary.md` (upon completion)
- Modified: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
- Modified: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

## Rollback/Contingency

If implementation causes issues:
1. The existing `successor_from_deferral_seed` is preserved (no breaking changes to interface)
2. The sorry at SuccChainFMCS.lean:350 can be restored temporarily
3. Git can revert to pre-change state if needed
4. The axiom fallback from task 46 remains available if needed

## Key Insight (From Task 34 Pattern)

The breakthrough is recognizing that every blocking formula `H(neg phi)` we add is **already in `u`**:

```
P(phi) not in u
  => neg(P(phi)) in u          (MCS negation completeness)
  => neg(neg(H(neg(phi)))) in u  (P(phi) = neg(H(neg(phi))) by definition)
  => H(neg(phi)) in u          (MCS double negation elimination)
```

Therefore `constrained_successor_seed(u) subset u`, and consistency is immediate.

## File Location Reference

From research report and code inspection:
- f_step_blocking_formulas definition: SuccExistence.lean lines 162-164
- f_step_blocking_formulas_subset_u proof: SuccExistence.lean lines 406-413
- predecessor_f_step proof template: SuccExistence.lean lines 630-661
- Forward chain sorry: SuccChainFMCS.lean lines 350-370
