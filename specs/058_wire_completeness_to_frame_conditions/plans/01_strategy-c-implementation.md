# Implementation Plan: Task #58

- **Task**: 58 - Wire completeness to FrameConditions
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (all prerequisite infrastructure is sorry-free)
- **Research Inputs**: specs/064_critical_path_review/reports/02_team-research.md, specs/058_wire_completeness_to_frame_conditions/reports/02_team-research.md, specs/058_wire_completeness_to_frame_conditions/reports/03_ultrafilter-chain-verification.md
- **Artifacts**: plans/01_strategy-c-implementation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Eliminate the 3 sorries in `FrameConditions/Completeness.lean` (`dense_completeness_fc`, `discrete_completeness_fc`, `completeness_over_Int`) by implementing Strategy C: Restricted Chain + sigma-Duality Dovetailing. The approach builds a sorry-free `constrained_predecessor_restricted` (symmetric to the existing sorry-free `constrained_successor_restricted`), constructs a backward chain with P-coherence, dovetails forward+backward chains into an FMCS over Int, and wires through `construct_bfmcs` to the `parametric_algebraic_representation_conditional` theorem.

### Research Integration

- **Strategy C confirmed optimal** (task 64 team research): ~780 lines, symmetric construction, no mathematical obstacles. Temporal Shift Automorphism proven impossible as global construction.
- **Critical discovery**: `restricted_forward_chain_forward_F` currently depends on `sorryAx` via a missing `restricted_bounded_witness` lemma. This must be fixed first (Phase 1).
- **Forward infrastructure 80% complete**: `restricted_forward_chain`, `restricted_forward_chain_succ`, `restricted_forward_chain_F_bounded` are all sorry-free. Only the final forward F-coherence proof needs the bounded witness lemma.
- **Backward infrastructure partially exists**: `predecessor_deferral_seed`, `pastDeferralDisjunctions`, `h_content_subset_deferralClosure`, `p_nesting_is_bounded_restricted` all exist and are sorry-free.

## Goals & Non-Goals

**Goals**:
- Eliminate all 3 sorries in `FrameConditions/Completeness.lean`
- Build sorry-free `construct_bfmcs` (replacing the deprecated version)
- Prove forward F-coherence and backward P-coherence for restricted chains
- Wire through `parametric_algebraic_representation_conditional` to completeness theorems

**Non-Goals**:
- Eliminating `discrete_Icc_finite_axiom` (separate documented debt)
- Refactoring the existing deprecated `construct_bfmcs` or `SuccChainTemporalCoherent`
- Building completeness for arbitrary temporal domains (only Int needed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `restricted_bounded_witness` requires novel proof technique | H | L | The forward F-step witness and F-bounded theorems are sorry-free; the bounded witness is a standard induction combining them |
| `constrained_predecessor_seed_restricted_consistent` proof diverges from successor pattern | M | L | The predecessor seed consistency proof in SuccExistence.lean for general MCS already exists; restricted version follows same pattern with `deferral_restricted_lindenbaum` |
| Dovetailing join point has subtle type mismatches | M | L | Both chains share M0 by construction; Int indexing is straightforward |
| `boxClassFamilies` integration requires non-trivial adaptation for restricted chains | M | M | Option to either create `RestrictedSuccChainFMCS` wrapper or use `extendToMCS` theorems (both already partially supported) |
| F_top/P_top membership in deferralClosure for arbitrary phi | M | M | Already handled by `F_top_in_restricted_successor` proof pattern; same approach for backward chain |

## Implementation Phases

### Phase 1: Fix Forward F-Coherence (restricted_bounded_witness) [PARTIAL]

**Goal**: Make `restricted_forward_chain_forward_F` sorry-free by implementing the missing `restricted_bounded_witness` lemma.

**Context**: The proof at `restricted_forward_chain_iter_F_witness` (line 2215) calls `restricted_bounded_witness` which does not exist, causing `sorryAx` dependency. The bounded witness lemma proves: given F^d(psi) in chain(k) with d >= 1, and boundary d_max (from `restricted_forward_chain_F_bounded`), then psi appears in chain(k + d_max).

**Tasks**:
- [ ] Implement `restricted_bounded_witness` theorem: given F-nesting boundary (d_max >= 1, iter_F d_max psi in chain(k), iter_F (d_max+1) psi not in chain(k)), prove psi in chain(k + d_max) by induction on d_max using `restricted_forward_chain_F_step_witness`
- [ ] Verify `restricted_forward_chain_forward_F` becomes sorry-free via `lean_verify`
- [ ] Verify `restricted_forward_chain_iter_F_witness` becomes sorry-free

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- add `restricted_bounded_witness` before line 2162

**Verification**:
- `lean_verify` on `Bimodal.Metalogic.Bundle.restricted_forward_chain_forward_F` shows no `sorryAx`
- `lake build` succeeds

---

### Phase 2: Constrained Predecessor Restricted Construction [NOT STARTED]

**Goal**: Build `constrained_predecessor_restricted` -- the symmetric analog of `constrained_successor_restricted` for the backward direction.

**Context**: The predecessor seed (`predecessor_deferral_seed`) and its components (`h_content`, `pastDeferralDisjunctions`, `f_step_blocking_formulas`) are already defined in SuccExistence.lean. We need a restricted version that stays within `deferralClosure` and produces a `DeferralRestrictedMCS`.

**Tasks**:
- [ ] Define `constrained_predecessor_seed_restricted` in SuccExistence.lean or SuccChainFMCS.lean: `h_content(u) union pastDeferralDisjunctions(u) union p_step_blocking_formulas(u)` (symmetric to successor seed)
- [ ] Prove `constrained_predecessor_seed_restricted_subset_deferralClosure`: seed stays within deferralClosure (uses `h_content_subset_deferralClosure` and past deferral disjunctions being in deferralClosure)
- [ ] Prove `constrained_predecessor_seed_restricted_consistent`: seed is consistent when P_top in u (symmetric to successor seed consistency proof)
- [ ] Define `constrained_predecessor_restricted` via `deferral_restricted_lindenbaum`
- [ ] Prove `constrained_predecessor_restricted_is_mcs`: result is a DeferralRestrictedMCS
- [ ] Prove `constrained_predecessor_restricted_succ`: Succ(predecessor, u) holds
- [ ] Prove `constrained_predecessor_restricted_h_persistence`: h_content(u) subset predecessor
- [ ] Prove `constrained_predecessor_restricted_p_step`: p_content(u) subset predecessor union p_content(predecessor)
- [ ] Prove `constrained_predecessor_restricted_f_step`: f_content(predecessor) subset u union f_content(u)
- [ ] Prove `P_top_in_restricted_predecessor`: P_top propagates through predecessor construction

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- add predecessor construction after the backward chain structure (after line 2276)

**Verification**:
- `lean_verify` on all new theorems shows no `sorryAx`
- `constrained_predecessor_restricted_succ` type-checks with `Succ` relation
- `lake build` succeeds

---

### Phase 3: Restricted Backward Chain and P-Coherence [NOT STARTED]

**Goal**: Build `restricted_backward_chain` and prove backward P-coherence (`restricted_backward_chain_backward_P`).

**Context**: Symmetric to the forward chain construction. Uses `constrained_predecessor_restricted` from Phase 2. P-nesting boundedness (`p_nesting_is_bounded_restricted`) is already proven.

**Tasks**:
- [ ] Define `RestrictedBackwardChainElement.next` method using `constrained_predecessor_restricted`
- [ ] Define `restrictedBackwardChainAt` recursive construction (symmetric to `restrictedForwardChainAt`)
- [ ] Define `restricted_backward_chain` extracting world from chain elements
- [ ] Prove `restricted_backward_chain_is_drm`: chain elements are DeferralRestrictedMCS
- [ ] Prove `restricted_backward_chain_has_P_top`: P_top propagates
- [ ] Prove `restricted_backward_chain_zero`: chain at 0 equals M0
- [ ] Prove `restricted_backward_chain_pred`: Succ(chain(n+1), chain(n)) -- predecessor relation
- [ ] Prove `restricted_backward_chain_P_bounded`: P-nesting boundedness (uses `p_nesting_is_bounded_restricted`)
- [ ] Implement `restricted_backward_bounded_witness`: symmetric to Phase 1's forward version
- [ ] Prove `restricted_backward_chain_backward_P`: if P(psi) in chain(n), exists m > n with psi in chain(m)
- [ ] Prove `restricted_backward_chain_f_step`: f_content flows backward (needed for full Succ verification)

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- extend backward chain section

**Verification**:
- `lean_verify` on `restricted_backward_chain_backward_P` shows no `sorryAx`
- `lean_verify` on `restricted_backward_chain_pred` shows no `sorryAx`
- `lake build` succeeds

---

### Phase 4: Dovetail into FMCS over Int and Wire to construct_bfmcs [NOT STARTED]

**Goal**: Combine forward and backward restricted chains into an FMCS over Int, build a sorry-free `construct_bfmcs`, and wire to `parametric_algebraic_representation_conditional`.

**Context**: The forward chain runs on Nat (n >= 0), the backward chain runs on Nat (positions before M0). The dovetailing maps Int to the appropriate chain: non-negative to forward, negative to backward. The existing `boxClassFamilies` infrastructure (modal forward/backward, nonempty) is sorry-free; only temporal coherence needs replacement.

**Tasks**:
- [ ] Define `restricted_succ_chain_fam`: Int -> Set Formula combining forward and backward chains
- [ ] Prove `restricted_succ_chain_fam_is_mcs`: each position is an MCS (extend DeferralRestrictedMCS to full MCS via `extendToMCS`)
- [ ] Prove `restricted_succ_chain_fam_succ`: adjacent positions satisfy Succ
- [ ] Prove `restricted_succ_chain_fam_forward_F`: forward F-coherence (from Phase 1)
- [ ] Prove `restricted_succ_chain_fam_backward_P`: backward P-coherence (from Phase 3)
- [ ] Define `RestrictedSuccChainFMCS`: FMCS Int wrapper for the restricted chain
- [ ] Prove temporal coherence for `RestrictedSuccChainFMCS`
- [ ] Define `construct_bfmcs_restricted`: sorry-free BFMCS construction using restricted chains (replaces deprecated `construct_bfmcs`)
- [ ] Prove `construct_bfmcs_restricted_temporally_coherent`: temporal coherence for the new construction

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- dovetailing construction
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- new `construct_bfmcs_restricted` alongside deprecated version

**Verification**:
- `lean_verify` on `construct_bfmcs_restricted` shows no `sorryAx`
- `lean_verify` on temporal coherence theorem shows no `sorryAx`
- `lake build` succeeds

---

### Phase 5: Wire to FrameConditions/Completeness.lean [NOT STARTED]

**Goal**: Eliminate the 3 sorries in `FrameConditions/Completeness.lean` by wiring through the sorry-free `construct_bfmcs_restricted` and `parametric_algebraic_representation_conditional`.

**Context**: The three sorries are `dense_completeness_fc` (line 108), `discrete_completeness_fc` (line 151), and `completeness_over_Int` (line 170). All require proving `Nonempty ([] |- phi)` from semantic validity. The proof strategy: if phi not provable, extend neg(phi) to MCS, build BFMCS, apply representation theorem to get countermodel, contradicting validity.

**Tasks**:
- [ ] Prove `dense_completeness_fc`: use `parametric_algebraic_representation_conditional` with `construct_bfmcs_restricted` (Int satisfies dense frame conditions)
- [ ] Prove `completeness_over_Int`: use same construction directly over Int
- [ ] Prove `discrete_completeness_fc`: wire through `completeness_over_Int` (Int is discrete) or handle separately
- [ ] Update docstrings in Completeness.lean to reflect completed status
- [ ] Remove or update deprecation warnings on old `construct_bfmcs`
- [ ] Run full `lake build` to verify no regressions

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- replace 3 sorries with proofs

**Verification**:
- `lean_verify` on `dense_completeness_fc` shows no `sorryAx`
- `lean_verify` on `discrete_completeness_fc` shows no `sorryAx`
- `lean_verify` on `completeness_over_Int` shows no `sorryAx`
- Full `lake build` succeeds with no new warnings
- `grep -r "sorryAx\|:= sorry" Theories/Bimodal/FrameConditions/Completeness.lean` returns empty

## Testing & Validation

- [ ] `lean_verify` confirms no `sorryAx` in all 3 target theorems
- [ ] `lean_verify` confirms no `sorryAx` in `construct_bfmcs_restricted`
- [ ] `lean_verify` confirms no `sorryAx` in `restricted_forward_chain_forward_F`
- [ ] `lean_verify` confirms no `sorryAx` in `restricted_backward_chain_backward_P`
- [ ] Full `lake build` passes
- [ ] No new sorries introduced anywhere in the codebase

## Artifacts & Outputs

- Sorry-free `restricted_bounded_witness` (fixes existing forward F-coherence)
- Sorry-free `constrained_predecessor_restricted` construction
- Sorry-free `restricted_backward_chain` with P-coherence
- Sorry-free `construct_bfmcs_restricted` (BFMCS over Int)
- Sorry-free `dense_completeness_fc`, `discrete_completeness_fc`, `completeness_over_Int`
- Updated docstrings reflecting completed status

## Rollback/Contingency

Each phase produces independently verifiable Lean code that `lake build` can check. If a phase fails:
- Phases 1-3 add new definitions without modifying existing code; rollback is deletion of new code
- Phase 4 adds new construction alongside deprecated one; rollback is deletion of new construction
- Phase 5 is the only phase modifying existing sorry sites; if it fails, revert `Completeness.lean` changes

If the restricted predecessor construction proves harder than expected (Phase 2), a fallback approach is to use the existing `extendToMCS` theorems to lift DeferralRestrictedMCS to full MCS and use the unrestricted `predecessor_exists` theorem, then transfer back properties via `extendToMCS_transfer_back`.
