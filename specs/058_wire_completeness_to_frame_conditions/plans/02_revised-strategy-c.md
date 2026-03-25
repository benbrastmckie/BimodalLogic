# Implementation Plan: Task #58 (Revised v2)

- **Task**: 58 - Wire completeness to FrameConditions
- **Status**: [IN PROGRESS]
- **Effort**: 10 hours
- **Dependencies**: None (all prerequisite infrastructure is sorry-free)
- **Supersedes**: plans/01_strategy-c-implementation.md (v1 blocked on termination)
- **Research Inputs**:
  - specs/064_critical_path_review/reports/02_team-research.md (Strategy C analysis)
  - specs/archive/053_direct_bounded_witness_induction/reports/01_bounded-witness-restructuring.md (ROOT CAUSE)
  - specs/058_wire_completeness_to_frame_conditions/handoffs/01_phase1-partial.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Eliminate the 3 sorries in `FrameConditions/Completeness.lean` via Strategy C: Restricted Chain + Dovetailing. This revision addresses the **fundamental blocker** discovered during v1 implementation and confirmed by archived task 53 research.

### Critical Revision: Why v1 Phase 1 Failed

The v1 plan assumed `restricted_bounded_witness` could be proven by induction on boundary depth. Two implementation attempts failed on termination. Archived task 53 research proved this is **not a termination problem** but a **mathematical impossibility**:

**The theorem is unprovable from the current chain construction.**

The f_step property `psi in chain(k+1) OR F(psi) in chain(k+1)` is genuinely disjunctive. The Lindenbaum extension resolves this non-deterministically. When `FF(psi) not in deferralClosure` (boundary case), there is no logical forcing to choose resolution over deferral. The construction can cycle forever with `F(psi)` present but `psi` absent.

**The fix**: Modify `constrained_successor_restricted` to include **boundaryResolutionFormulas** in the seed, forcing resolution of boundary F-obligations. This is ~200 additional lines but solves the problem at the correct level.

The same modification is needed symmetrically for `constrained_predecessor_restricted` and P-obligations.

## Goals & Non-Goals

**Goals**:
- Eliminate all 3 sorries in `FrameConditions/Completeness.lean`
- Build sorry-free `construct_bfmcs` (replacing the deprecated version)
- Prove forward F-coherence and backward P-coherence for restricted chains
- Wire through `parametric_algebraic_representation_conditional` to completeness theorems

**Non-Goals**:
- Eliminating `discrete_Icc_finite_axiom` (separate documented debt, task 60)
- Refactoring the existing deprecated `construct_bfmcs` or `SuccChainTemporalCoherent`
- Building completeness for arbitrary temporal domains (only Int needed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Boundary resolution seed consistency proof is non-trivial | H | M | Task 53 analysis shows G(neg psi) not in u when F(psi) in u (by MCS consistency). Full consistency argument via incompatibility of neg(psi) with g_content when F(psi) present. |
| Modified seed changes existing sorry-free proofs (f_step, g_persistence) | M | L | The boundary formulas are a SUBSET of the deferral disjunctions. Adding them strengthens the seed; all existing properties that depend on seed membership still hold since the disjunction was already present. |
| Backward chain boundary resolution for P-obligations differs structurally | M | L | Symmetric construction: define `pastBoundaryResolutionFormulas` for PP(psi) not in deferralClosure. Same consistency argument applies via σ-duality. |
| Dovetailing join point has subtle type mismatches | M | L | Both chains share M0 by construction; Int indexing is straightforward |
| `boxClassFamilies` integration requires non-trivial adaptation | M | M | Use `extendToMCS` theorems (partially supported) or create `RestrictedSuccChainFMCS` wrapper |

## Implementation Phases

### Phase 1: Modify Successor Seed with Boundary Resolution [COMPLETED]

**Goal**: Add `boundaryResolutionFormulas` to `constrained_successor_seed_restricted` so that boundary F-obligations are forced to resolve.

**Context**: The current seed includes `deferralDisjunctions(u)` = `{psi or F(psi) : F(psi) in u}`. For boundary cases where `FF(psi) not in deferralClosure`, the disjunction allows infinite deferral. We add `psi` directly to the seed for these boundary cases.

**Tasks**:
- [ ] Define `boundaryResolutionFormulas`:
  ```lean
  def boundaryResolutionFormulas (phi : Formula) (u : Set Formula) : Set Formula :=
    { psi | Formula.some_future psi in u and
            Formula.some_future (Formula.some_future psi) not_in (deferralClosure phi : Set Formula) }
  ```
- [ ] Prove `boundaryResolutionFormulas_subset_deferralClosure`: all boundary resolution formulas are in deferralClosure (since F(psi) in dc implies psi in subformulaClosure subset dc)
- [ ] Modify `constrained_successor_seed_restricted` to include `boundaryResolutionFormulas`
- [ ] Prove consistency of the modified seed:
  - Key lemma: if `F(psi) in u` then `G(neg psi) not_in u` (by MCS consistency, since `F(psi) = neg(G(neg psi))`)
  - Therefore `neg(psi) not_in g_content(u)`
  - Full argument: the modified seed is consistent because adding `psi` when `F(psi) in u` and `FF(psi) not_in dc` does not conflict with g_content obligations
- [ ] Verify existing `constrained_successor_restricted_succ` still holds (the Succ relation properties should be preserved since we strengthened the seed)
- [ ] Verify existing `restricted_forward_chain_F_step_witness` still holds
- [ ] Delete or deprecate the false intermediate lemmas identified in task 53:
  - `restricted_single_step_forcing` (boundary case is false without modified seed)
  - `restricted_succ_propagates_F_not` (false)
  - `restricted_succ_propagates_F_not'` (false)
  - `restricted_single_step_forcing'` (depends on false lemma)
- [ ] Extract the proven Class A argument into standalone `restricted_single_step_forcing_interior`
- [ ] Run `lake build` to verify no regressions

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- seed modification, cleanup

**Verification**:
- `lake build` succeeds
- No new sorries introduced
- Class A proof preserved in `restricted_single_step_forcing_interior`

---

### Phase 2: Prove Forward F-Coherence [IN PROGRESS]

**Goal**: With the modified seed, prove `restricted_bounded_witness` and make `restricted_forward_chain_forward_F` sorry-free.

**Context**: With boundary resolution in the seed, the proof becomes straightforward:
- **Interior case** (FF(psi) in deferralClosure): Use Class A argument (already proven, extracted in Phase 1)
- **Boundary case** (FF(psi) not in deferralClosure): `psi in boundaryResolutionFormulas`, so `psi in seed subset chain(k+1)` -- DIRECT, no recursion needed

**Tasks**:
- [ ] Rewrite `restricted_bounded_witness` using case split on `FF(psi) in deferralClosure`:
  - Interior case: apply `restricted_single_step_forcing_interior`, recurse with decreased depth
  - Boundary case: `psi in chain(k+1)` directly from modified seed
- [ ] Verify `restricted_forward_chain_forward_F` becomes sorry-free via `lean_verify`
- [ ] Verify `restricted_forward_chain_iter_F_witness` becomes sorry-free
- [ ] Clean up partial implementation artifacts from v1 attempts

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- rewrite bounded_witness

**Verification**:
- `lean_verify` on `restricted_forward_chain_forward_F` shows no `sorryAx`
- `lake build` succeeds

---

### Phase 3: Build Backward Chain with Modified Predecessor [NOT STARTED]

**Goal**: Build `constrained_predecessor_restricted` with symmetric `pastBoundaryResolutionFormulas`, then construct `restricted_backward_chain` with P-coherence.

**Context**: Symmetric to Phases 1-2 but for the backward direction. The predecessor seed needs the same modification: force resolution of boundary P-obligations where `PP(psi) not in deferralClosure`.

**Tasks**:
- [ ] Define `pastBoundaryResolutionFormulas` (symmetric to Phase 1)
- [ ] Define `constrained_predecessor_seed_restricted` including:
  - `h_content(u)` (H-formula contents)
  - `pastDeferralDisjunctions(u)` (psi or P(psi) disjunctions)
  - `p_step_blocking_formulas`
  - `pastBoundaryResolutionFormulas` (force boundary P-resolution)
- [ ] Prove seed consistency (symmetric argument: if P(psi) in u then H(neg psi) not_in u)
- [ ] Prove seed subset deferralClosure
- [ ] Define `constrained_predecessor_restricted` via `deferral_restricted_lindenbaum`
- [ ] Prove Succ(predecessor, u) and h_persistence, p_step properties
- [ ] Define `restricted_backward_chain` (symmetric to forward chain)
- [ ] Prove `restricted_backward_chain_backward_P` using same approach as Phase 2:
  - Interior case: Class A argument (symmetric)
  - Boundary case: direct from modified seed

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- predecessor construction and backward chain

**Verification**:
- `lean_verify` on `restricted_backward_chain_backward_P` shows no `sorryAx`
- `lake build` succeeds

---

### Phase 4: Dovetail into FMCS over Int and Wire to construct_bfmcs [NOT STARTED]

**Goal**: Combine forward and backward restricted chains into an FMCS over Int, build a sorry-free `construct_bfmcs`, and wire to `parametric_algebraic_representation_conditional`.

**Context**: Unchanged from v1 -- the forward chain runs on Nat (n >= 0), the backward chain runs on Nat (positions before M0). The dovetailing maps Int to the appropriate chain.

**Tasks**:
- [ ] Define `restricted_succ_chain_fam`: Int -> Set Formula combining forward and backward chains
- [ ] Prove `restricted_succ_chain_fam_is_mcs`: each position is an MCS (extend DeferralRestrictedMCS to full MCS via `extendToMCS`)
- [ ] Prove `restricted_succ_chain_fam_succ`: adjacent positions satisfy Succ
- [ ] Prove `restricted_succ_chain_fam_forward_F`: forward F-coherence (from Phase 2)
- [ ] Prove `restricted_succ_chain_fam_backward_P`: backward P-coherence (from Phase 3)
- [ ] Define `RestrictedSuccChainFMCS`: FMCS Int wrapper for the restricted chain
- [ ] Prove temporal coherence for `RestrictedSuccChainFMCS`
- [ ] Define `construct_bfmcs_restricted`: sorry-free BFMCS construction
- [ ] Prove `construct_bfmcs_restricted_temporally_coherent`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- dovetailing construction
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- new `construct_bfmcs_restricted`

**Verification**:
- `lean_verify` on `construct_bfmcs_restricted` shows no `sorryAx`
- `lake build` succeeds

---

### Phase 5: Wire to FrameConditions/Completeness.lean [NOT STARTED]

**Goal**: Eliminate the 3 sorries in `FrameConditions/Completeness.lean`.

**Context**: Unchanged from v1.

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

## Artifacts & Outputs

- Sorry-free `boundaryResolutionFormulas` / `pastBoundaryResolutionFormulas` (seed modifications)
- Sorry-free `restricted_bounded_witness` (now trivial with modified seed)
- Sorry-free `constrained_predecessor_restricted` construction
- Sorry-free `restricted_backward_chain` with P-coherence
- Sorry-free `construct_bfmcs_restricted` (BFMCS over Int)
- Sorry-free `dense_completeness_fc`, `discrete_completeness_fc`, `completeness_over_Int`
- Cleanup of false intermediate lemmas from SuccChainFMCS.lean

## Rollback/Contingency

Each phase produces independently verifiable Lean code that `lake build` can check. If a phase fails:
- Phase 1 modifies the successor seed -- rollback by reverting to current seed
- Phases 2-3 add new proofs using modified seed -- rollback is deletion
- Phase 4 adds new construction alongside deprecated one -- rollback is deletion
- Phase 5 is the only phase modifying existing sorry sites -- rollback by reverting Completeness.lean

If the boundary resolution seed consistency proof is harder than expected (Phase 1), a fallback is to use the weaker approach from task 53 Option B (pigeonhole on deferralClosure finiteness combined with Classical.choose determinism) to show the chain cannot cycle.

## Key Differences from v1

| Aspect | v1 Plan | v2 Plan (this) |
|--------|---------|----------------|
| Phase 1 goal | Prove `restricted_bounded_witness` by induction | Modify successor seed to force boundary resolution |
| Root assumption | f_step + induction suffices | f_step allows infinite deferral; seed must force resolution |
| Termination | Lexicographic measure needed | No recursion issue; boundary case is direct |
| Effort estimate | 8 hours | 10 hours (seed modification + cleanup overhead) |
| Risk profile | Unknown termination blocker | Known consistency proof as main risk |
| Phases | 5 phases, Phase 1 blocked | 5 phases, no known blockers |
