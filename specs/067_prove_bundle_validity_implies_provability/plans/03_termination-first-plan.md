# Implementation Plan: Task 67 - Termination-First Restricted Truth Lemma

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: [NOT STARTED]
- **Effort**: 8-12 hours
- **Dependencies**: None (builds on existing sorry-free infrastructure)
- **Research Inputs**: specs/067_prove_bundle_validity_implies_provability/reports/08_team-research.md
- **Artifacts**: plans/03_termination-first-plan.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan follows Path A (Restricted Truth Lemma) from the team research, with a termination-first prioritization. The approach eliminates the sorry in `bundle_validity_implies_provability` by:
1. Filling termination sorries in `SuccChainFMCS.lean` (cleanest wins - bodies already complete)
2. Completing G/H propagation in `RestrictedTruthLemma.lean` (needed for G/H cases)
3. Adapting `parametric_canonical_truth_lemma` to accept restricted coherence
4. Wiring the restricted truth lemma to completeness

The key insight from research: the DRM restriction bounds F-nesting within `deferralClosure(phi)`, making termination provable via lexicographic measures on `(closure_F_bound - depth, chain_position)`.

### Research Integration

From `reports/08_team-research.md`:
- **Sorry-free infrastructure**: `deferral_restricted_mcs_F_bounded`, `deferral_restricted_mcs_P_bounded`, `build_restricted_tc_family` (bodies complete)
- **Critical path**: termination (4) -> G/H propagation (3) -> restricted BFMCS coherence -> truth lemma adaptation -> completeness wiring
- **The blocker**: `parametric_canonical_truth_lemma` requires `h_tc : B.temporally_coherent` (family-level), but `construct_bfmcs_bundle` only provides bundle-level coherence

## Goals & Non-Goals

**Goals**:
- Eliminate the sorry in `bundle_validity_implies_provability` (Completeness.lean or equivalent)
- Fill all termination sorries in `SuccChainFMCS.lean` (4 `decreasing_by sorry`)
- Complete G/H propagation proofs in `RestrictedTruthLemma.lean`
- Create restricted BFMCS coherence bridge
- Wire restricted truth lemma to completeness theorem

**Non-Goals**:
- Proving full MCS temporal coherence (unbounded F-nesting makes this impossible)
- Path B (family-level coherence for SuccChainFMCS) - reduces to Path A per research
- Seed consistency (`constrained_successor_seed_restricted_consistent`) unless it blocks critical path
- Backward chain construction sorries unless they block backward_P

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Termination measure not accepted by Lean | High | Medium | Use `Nat.find` with well-founded recursion as fallback; consult Mathlib patterns |
| G/H propagation requires DRM properties not yet proven | High | Medium | Check if DRM T-axiom closure suffices; may need additional DRM lemmas |
| Restricted BFMCS coherence requires substantial new definitions | Medium | Low | Research shows `RestrictedTemporallyCoherentFamily` structure exists |
| Seed consistency blocks forward_F | Medium | Low | Multi-BRS case may be avoidable if we restrict to single-BRS seeds |

## Implementation Phases

### Phase 1: Fill Termination Sorries [NOT STARTED]

**Goal**: Complete the 4 `decreasing_by sorry` proofs in SuccChainFMCS.lean using lexicographic measures

**Tasks**:
- [ ] Identify exact locations of the 4 termination sorries (grep for `decreasing_by sorry`)
- [ ] Analyze the recursive structure of `restricted_bounded_witness` and variants
- [ ] Design lexicographic termination measure: `(closure_F_bound phi - current_depth, remaining_steps)`
- [ ] Prove `restricted_bounded_witness` terminates
- [ ] Prove `restricted_backward_bounded_witness` terminates
- [ ] Prove `restricted_combined_bounded_witness` terminates
- [ ] Prove `restricted_combined_bounded_witness_P` terminates
- [ ] Run `lake build` to verify all 4 sorries eliminated

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Timing**: 2-3 hours

**Verification**:
- `grep -c "decreasing_by sorry" SuccChainFMCS.lean` returns 0
- `lake build Bimodal.Metalogic.Bundle.SuccChainFMCS` succeeds without sorryAx

---

### Phase 2: Complete G/H Propagation [NOT STARTED]

**Goal**: Fill the 3 G/H propagation sorries in RestrictedTruthLemma.lean

**Tasks**:
- [ ] Analyze `restricted_chain_G_propagates` (lines 85-106) - currently has sorry at line 106
- [ ] Use induction on `m - n` with G-step at each iteration
- [ ] Prove the n < m case using k-step induction
- [ ] Fill sorry for T-axiom case at line 115 (psi extraction from G(psi))
- [ ] Analyze `restricted_chain_H_step` (lines 124-135) - currently has sorry at line 135
- [ ] Use h_content propagation from Succ relation for backward step
- [ ] Run `lake build` to verify G/H propagation complete

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean`

**Timing**: 2-3 hours

**Verification**:
- `grep -c "sorry" RestrictedTruthLemma.lean` returns 0 (or only non-G/H sorries)
- `lake build Bimodal.Metalogic.Algebraic.RestrictedTruthLemma` succeeds

---

### Phase 3: Restricted BFMCS Coherence Bridge [NOT STARTED]

**Goal**: Create bridge between `RestrictedTemporallyCoherentFamily` and BFMCS temporal coherence

**Tasks**:
- [ ] Define `RestrictedBFMCS` structure or predicate in new file or extend existing
- [ ] Define `RestrictedTemporalCoherence` for BFMCS (coherence over deferralClosure(phi) only)
- [ ] Prove `RestrictedTemporallyCoherentFamily` implies `RestrictedTemporalCoherence` for its single-family BFMCS
- [ ] Create adapter: `build_restricted_bfmcs_from_tc_family` that wraps family as single-family BFMCS
- [ ] Verify the restricted BFMCS satisfies modal_forward/modal_backward (trivial for single family)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` (extend existing)
- OR create new `Theories/Bimodal/Metalogic/Algebraic/RestrictedBFMCS.lean`

**Timing**: 1.5-2 hours

**Verification**:
- New definitions type-check
- `lake build` succeeds
- Bridge lemmas stated and proven

---

### Phase 4: Restricted Truth Lemma Adaptation [NOT STARTED]

**Goal**: Create restricted version of `parametric_canonical_truth_lemma` that uses restricted coherence

**Tasks**:
- [ ] Define `restricted_parametric_canonical_truth_lemma` theorem statement
- [ ] Modify proof to use restricted forward_F/backward_P instead of full temporal coherence
- [ ] Verify induction hypothesis works for subformulas in deferralClosure
- [ ] Handle G case using `restricted_chain_G_propagates` (from Phase 2)
- [ ] Handle H case using `restricted_chain_H_step` (from Phase 2)
- [ ] Handle F case using restricted forward_F coherence
- [ ] Handle P case using restricted backward_P coherence
- [ ] Prove bidrectionality: MCS membership <-> truth_at

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean`

**Timing**: 2-3 hours

**Verification**:
- `restricted_parametric_canonical_truth_lemma` compiles without sorry
- Statement matches: `psi in fam.mcs t <-> truth_at model omega history t psi` for psi in closure

---

### Phase 5: Completeness Wiring [NOT STARTED]

**Goal**: Wire restricted truth lemma to eliminate sorry in completeness theorem

**Tasks**:
- [ ] Locate the sorry in `bundle_validity_implies_provability` or equivalent theorem
- [ ] Understand current proof structure and what the sorry needs
- [ ] Apply restricted truth lemma: given unprovable phi, construct restricted TC family with neg(phi)
- [ ] Use forward direction of restricted truth lemma to show neg(phi) is true in model
- [ ] Derive contradiction with validity hypothesis
- [ ] Clean up any auxiliary lemmas or casts needed
- [ ] Run full `lake build` to verify no sorryAx in completeness module

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` (or wherever the sorry lives)
- Potentially `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Timing**: 1-2 hours

**Verification**:
- `#print axioms bundle_validity_implies_provability` shows no `sorryAx`
- `lake build Bimodal.Metalogic.Completeness` succeeds
- Final completeness theorem is axiom-free (except standard Mathlib axioms)

---

## Testing & Validation

- [ ] Phase 1: `grep "decreasing_by sorry" SuccChainFMCS.lean` returns empty
- [ ] Phase 2: G/H propagation lemmas compile without sorry
- [ ] Phase 3: Restricted BFMCS bridge definitions type-check
- [ ] Phase 4: `restricted_parametric_canonical_truth_lemma` compiles
- [ ] Phase 5: `#print axioms bundle_validity_implies_provability` shows no `sorryAx`
- [ ] Full build: `lake build` completes without errors
- [ ] Axiom check: `#print axioms` on all modified theorems

## Artifacts & Outputs

- `specs/067_prove_bundle_validity_implies_provability/plans/03_termination-first-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- Modified `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean`
- Modified `Theories/Bimodal/Metalogic/Completeness.lean`
- Summary report on completion: `specs/067_prove_bundle_validity_implies_provability/summaries/03_completeness-summary.md`

## Rollback/Contingency

- **If termination measures fail**: Try `Nat.find` approach with explicit well-foundedness proof; consult Mathlib's `Nat.lt_wfRel` or `Prod.Lex` for lexicographic measures
- **If G/H propagation blocked on DRM properties**: May need to prove additional DRM closure lemmas; check if T-axiom derivability within DRM suffices
- **If restricted BFMCS bridge too complex**: Consider proving restricted truth lemma directly without BFMCS wrapper, using only `RestrictedTemporallyCoherentFamily`
- **If seed consistency blocks Phase 1**: Restrict to single-BRS seeds initially; multi-BRS case can be deferred
- **Emergency rollback**: All phases modify existing files with clear additions; git revert to pre-implementation state if needed
