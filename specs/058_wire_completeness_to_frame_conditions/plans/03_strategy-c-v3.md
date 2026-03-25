# Implementation Plan: Task #58 (Revised v3)

- **Task**: 58 - Wire completeness to FrameConditions
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (all prerequisite infrastructure is sorry-free)
- **Supersedes**: plans/02_revised-strategy-c.md (v2 had incorrect boundary_resolution_set definition)
- **Research Inputs**:
  - specs/058_wire_completeness_to_frame_conditions/reports/04_termination-strategy.md (ROOT CAUSE FIX)
  - specs/064_critical_path_review/reports/02_team-research.md (Strategy C analysis)
  - specs/archive/053_direct_bounded_witness_induction/reports/01_bounded-witness-restructuring.md (Original root cause)
- **Type**: lean4
- **Lean Intent**: false

## Overview

Eliminate the 3 sorries in `FrameConditions/Completeness.lean` via Strategy C: Restricted Chain + Dovetailing.

### Critical Revision: Why v2 Phase 2 Failed

The v2 plan added `boundary_resolution_set` to the seed, but the definition at `SuccExistence.lean:281` was **incorrect**:

```lean
-- WRONG: includes chi in u, which defeats the purpose
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | chi in u and   -- THIS CONDITION IS THE BUG
        Formula.some_future chi in u and
        Formula.some_future (Formula.some_future chi) not_in deferralClosure phi}
```

The `chi in u` condition was added "to make consistency trivial" but it means the set only contains formulas already in the current world. **This doesn't help resolve F-obligations.**

**The fix**: Remove the `chi in u` condition and prove consistency properly:

```lean
-- CORRECT: forces resolution of boundary F-obligations
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {psi | Formula.some_future psi in u and
         Formula.some_future (Formula.some_future psi) not_in deferralClosure phi}
```

With this fix, termination becomes trivial: depth decreases by 1 in all cases.

## Goals & Non-Goals

**Goals**:
- Fix `boundary_resolution_set` definition (remove `chi in u` condition)
- Prove seed consistency for the corrected definition
- Eliminate all 3 sorries in `FrameConditions/Completeness.lean`
- Build sorry-free `construct_bfmcs` (replacing the deprecated version)

**Non-Goals**:
- Eliminating `discrete_Icc_finite_axiom` (separate documented debt, task 60)
- Refactoring the existing deprecated `construct_bfmcs` or `SuccChainTemporalCoherent`
- Building completeness for arbitrary temporal domains (only Int needed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Consistency proof for corrected seed is non-trivial | M | M | Key lemma: if F(psi) in u then G(neg psi) not_in u (MCS consistency). Therefore neg(psi) not_in g_content(u). Full argument in report 04. |
| p_step_blocking conflict | L | L | Blocking formulas are H(neg chi) for P(chi) not_in u. Temporal duality prevents P(psi) conflicts when F(psi) in u. |
| Existing lemmas depend on old definition | L | L | Only 2 lemmas use old definition; both can be reproven. |

## Implementation Phases

### Phase 1: Fix boundary_resolution_set Definition [NOT STARTED]

**Goal**: Correct the `boundary_resolution_set` definition by removing the `chi in u` condition, then prove consistency of the modified seed.

**Context**: The current definition defeats its purpose. The corrected definition forces resolution of boundary F-obligations.

**Tasks**:
- [ ] In `SuccExistence.lean`, change `boundary_resolution_set` definition:
  ```lean
  def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
    {psi | Formula.some_future psi in u and
           Formula.some_future (Formula.some_future psi) not_in (deferralClosure phi : Set Formula)}
  ```
- [ ] Update `mem_boundary_resolution_set_iff` lemma for new definition
- [ ] Prove `boundary_resolution_set_subset_deferralClosure`: psi in boundary_resolution_set implies psi in deferralClosure (since F(psi) in u subset dc implies psi in subformulaClosure)
- [ ] Prove key consistency lemma `neg_not_in_g_content_when_F_in_u`:
  ```lean
  theorem neg_not_in_g_content_when_F_in_u (phi : Formula) (u : Set Formula)
      (h_mcs : DeferralRestrictedMCS phi u) (psi : Formula)
      (h_F_psi : Formula.some_future psi in u) :
      Formula.neg psi not_in g_content u
  ```
  Proof sketch: F(psi) = neg(G(neg psi)), so G(neg psi) not_in u by MCS consistency, so neg(psi) not_in g_content(u).
- [ ] Update `constrained_successor_seed_restricted_consistent` proof
- [ ] Verify `lake build` succeeds

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` -- fix definition, add consistency lemmas
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- update downstream proofs

**Verification**:
- `lake build` succeeds
- No new sorries introduced

---

### Phase 2: Prove Forward F-Coherence (Termination Now Trivial) [NOT STARTED]

**Goal**: With the corrected seed, prove `restricted_bounded_witness` and make `restricted_forward_chain_forward_F` sorry-free.

**Context**: With the corrected definition, termination becomes trivial:
- **Boundary case** (FF(psi) not in deferralClosure): `psi in boundary_resolution_set`, so `psi in seed ⊆ chain(k+1)` -- DIRECT, depth drops to 0
- **Interior case** (FF(psi) in deferralClosure): Use Class A argument, recurse with depth d-1

**Tasks**:
- [ ] Prove `boundary_resolution_in_chain`:
  ```lean
  theorem boundary_resolution_in_chain (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi)
      (k : Nat) (psi : Formula)
      (h_F_psi : Formula.some_future psi in restricted_forward_chain phi M0 k)
      (h_FF_not : Formula.some_future (Formula.some_future psi) not_in deferralClosure phi) :
      psi in restricted_forward_chain phi M0 (k + 1)
  ```
- [ ] Rewrite `restricted_bounded_witness` with case split:
  ```lean
  theorem restricted_bounded_witness ... := by
    by_cases h : FF(iter_F (d-1) theta) in deferralClosure phi
    case inl => -- Interior: Class A + recurse with d-1
    case inr => -- Boundary: direct from seed
  termination_by d  -- Now trivial!
  ```
- [ ] Verify `restricted_forward_chain_forward_F` becomes sorry-free via `lean_verify`
- [ ] Verify `restricted_forward_chain_iter_F_witness` becomes sorry-free
- [ ] Clean up any remaining v2 artifacts

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- rewrite bounded_witness

**Verification**:
- `lean_verify` on `restricted_forward_chain_forward_F` shows no `sorryAx`
- `lake build` succeeds

---

### Phase 3: Build Backward Chain with Modified Predecessor [NOT STARTED]

**Goal**: Build `constrained_predecessor_restricted` with symmetric `past_boundary_resolution_set`, then construct `restricted_backward_chain` with P-coherence.

**Context**: Symmetric to Phases 1-2 but for the backward direction.

**Tasks**:
- [ ] Define `past_boundary_resolution_set`:
  ```lean
  def past_boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
    {psi | Formula.some_past psi in u and
           Formula.some_past (Formula.some_past psi) not_in deferralClosure phi}
  ```
- [ ] Define `constrained_predecessor_seed_restricted` including past_boundary_resolution_set
- [ ] Prove seed consistency (symmetric: if P(psi) in u then H(neg psi) not_in u)
- [ ] Define `constrained_predecessor_restricted` via `deferral_restricted_lindenbaum`
- [ ] Prove Succ(predecessor, u) and h_persistence, p_step properties
- [ ] Define `restricted_backward_chain`
- [ ] Prove `restricted_backward_chain_backward_P` using same approach as Phase 2

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` -- past_boundary_resolution_set
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- predecessor construction and backward chain

**Verification**:
- `lean_verify` on `restricted_backward_chain_backward_P` shows no `sorryAx`
- `lake build` succeeds

---

### Phase 4: Dovetail into FMCS over Int and Wire to construct_bfmcs [NOT STARTED]

**Goal**: Combine forward and backward restricted chains into an FMCS over Int, build sorry-free `construct_bfmcs`.

**Tasks**:
- [ ] Define `restricted_succ_chain_fam`: Int -> Set Formula combining forward and backward chains
- [ ] Prove `restricted_succ_chain_fam_is_mcs`: each position is an MCS
- [ ] Prove `restricted_succ_chain_fam_succ`: adjacent positions satisfy Succ
- [ ] Prove `restricted_succ_chain_fam_forward_F`: forward F-coherence
- [ ] Prove `restricted_succ_chain_fam_backward_P`: backward P-coherence
- [ ] Define `RestrictedSuccChainFMCS`: FMCS Int wrapper
- [ ] Prove temporal coherence for `RestrictedSuccChainFMCS`
- [ ] Define `construct_bfmcs_restricted`: sorry-free BFMCS construction

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- dovetailing construction
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- construct_bfmcs_restricted

**Verification**:
- `lean_verify` on `construct_bfmcs_restricted` shows no `sorryAx`
- `lake build` succeeds

---

### Phase 5: Wire to FrameConditions/Completeness.lean [NOT STARTED]

**Goal**: Eliminate the 3 sorries in `FrameConditions/Completeness.lean`.

**Tasks**:
- [ ] Prove `dense_completeness_fc`: use `parametric_algebraic_representation_conditional` with `construct_bfmcs_restricted`
- [ ] Prove `completeness_over_Int`: same construction directly over Int
- [ ] Prove `discrete_completeness_fc`: wire through `completeness_over_Int`
- [ ] Update docstrings in Completeness.lean
- [ ] Run full `lake build`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Semantics/FrameConditions/Completeness.lean` -- replace 3 sorries

**Verification**:
- `lean_verify` on all 3 target theorems shows no `sorryAx`
- Full `lake build` succeeds
- `grep -r "sorryAx\|:= sorry" Theories/Bimodal/Semantics/FrameConditions/Completeness.lean` returns empty

## Testing & Validation

- [ ] `lean_verify` confirms no `sorryAx` in all 3 target theorems
- [ ] `lean_verify` confirms no `sorryAx` in `construct_bfmcs_restricted`
- [ ] `lean_verify` confirms no `sorryAx` in `restricted_forward_chain_forward_F`
- [ ] `lean_verify` confirms no `sorryAx` in `restricted_backward_chain_backward_P`
- [ ] Full `lake build` passes
- [ ] No new sorries introduced anywhere in the codebase

## Key Differences from v2

| Aspect | v2 Plan | v3 Plan (this) |
|--------|---------|----------------|
| Phase 1 goal | Add boundary_resolution_set to seed | FIX boundary_resolution_set definition |
| Root assumption | chi in u condition needed for consistency | chi in u condition defeats purpose; remove it |
| Consistency proof | Trivial (chi already in u) | Non-trivial but doable (neg(psi) not in g_content) |
| Termination | Still blocked after v2 Phase 1 | Trivial (depth always decreases by 1) |
| Effort estimate | 10 hours | 8 hours (simpler after correct fix) |
| Risk profile | Unknown termination blocker persisted | Known path to completion |
