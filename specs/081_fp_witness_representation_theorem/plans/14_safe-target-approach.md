# Implementation Plan: F/P Witness via Safe Target Lemma

- **Task**: 81 - F/P Witness Representation Theorem
- **Status**: [NOT STARTED]
- **Effort**: 8-10 hours
- **Dependencies**: None (builds on sorry-free `build_targeted_successor` from v11)
- **Research Inputs**: reports/14_fuel-approach-review.md, reports/13_blocker-analysis.md, reports/09_definitive-approach.md
- **Artifacts**: plans/14_safe-target-approach.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the F/P witness gap (`forward_F` / `backward_P`) in the completeness proof by proving a **safe target lemma**: for any restricted MCS with F-obligations, there exists a successor target choice that resolves at least one F-obligation without destroying others. This avoids the fuel-based recursion (a known dead end from tasks 48, 67, and report 14) and instead composes the sorry-free one-step `build_targeted_successor` into a full witness via well-founded induction on the set of unresolved F-obligations. The definition of done is sorry-free `forward_F` and `backward_P` fields on `SuccChainFMCS`, wired through to `bfmcs_from_mcs_temporally_coherent`.

## Goals & Non-Goals

**Goals**:
- Prove the safe target lemma: a successor can resolve an F-obligation without introducing new ones at the same or lower depth
- Compose one-step resolution into full `forward_F` via well-founded induction on unresolved obligations
- Symmetric construction for `backward_P`
- Wire through to `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:237)
- Achieve sorry-free `completeness_over_Int` and `discrete_completeness_fc`

**Non-Goals**:
- Dense completeness (`dense_completeness_fc` — separate sorry, needs dense canonical model)
- Fuel-based termination arguments (KNOWN DEAD END — see report 14)
- Refactoring SuccChainFMCS architecture
- Algebraic temporal shift approach (viable but requires significant new infrastructure — separate task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Safe target lemma is false: resolving one F-obligation always risks destroying another | H | M | Analyze deferralClosure structure: obligations at different depths are independent. If same-depth interference exists, use priority ordering on obligations. |
| Well-founded measure on unresolved obligations doesn't decrease at each step | H | M | Fallback to lexicographic measure on (max_unresolved_depth, count_at_max_depth). Each step either reduces max depth or reduces count at that depth. |
| Wiring from restricted chain to SuccChainFMCS has structural gaps | M | M | Map exact dependency chain via `lean_verify` on intermediate theorems before starting implementation. |
| The safe target argument requires understanding scheduler interaction | M | L | The restricted MCS construction controls the scheduler — it picks which obligation to target. This is a feature, not a bug. |

## Implementation Phases

### Phase 1: Map Sorry Chain and Validate Approach [COMPLETED]
- **Goal:** Understand the exact sorry chain from `forward_F` to `completeness_over_Int` and verify the safe target approach is viable.
- **Tasks:**
  - [ ] Trace the sorry chain: `forward_F` → `succ_chain_forward_F` → `temporal_backward_G` → truth lemma → completeness
  - [ ] Read `build_targeted_successor` and document its preconditions and postconditions
  - [ ] Identify what "unresolved F-obligations" means formally in terms of deferralClosure
  - [ ] Verify that resolving an F-obligation at depth d does not create new obligations at depth ≤ d
  - [ ] If the safe target property doesn't hold, document why and propose alternative measure
  - [ ] Write a concrete mathematical sketch of the induction argument
- **Timing:** 1.5 hours

### Phase 2: Prove Safe Target Lemma [BLOCKED]
- **Goal:** Prove that for any restricted MCS with unresolved F-obligations, there exists a successor that resolves at least one without net increase in the obligation set.
- **Tasks:**
  - [ ] Define `unresolved_F_obligations : RestrictedMCS → Finset Formula` (F-formulas in MCS not yet witnessed)
  - [ ] Prove that `build_targeted_successor` targeting obligation `F(psi)` produces a successor where either `psi` holds (obligation resolved) or `F(psi)` persists but depth decreases
  - [ ] Prove that no new F-obligations are introduced at the same or lower nesting depth
  - [ ] Combine: the multiset of (depth, obligation) strictly decreases under the multiset ordering
  - [ ] Handle edge case: obligation outside deferralClosure (may not need resolution for the target formula)
- **Timing:** 3 hours

### Phase 3: Compose into Full Forward_F / Backward_P [NOT STARTED]
- **Goal:** Use well-founded induction on the obligation multiset to compose one-step resolution into full `forward_F` and `backward_P`.
- **Tasks:**
  - [ ] Define well-founded measure: `Finset.card (unresolved_F_obligations_up_to_depth d)` or multiset ordering
  - [ ] Prove `forward_F`: F(phi) at t implies exists t' ≥ t with phi at t', by iterating safe target steps
  - [ ] Prove symmetric `backward_P` using `past_temporal_box_seed` and backward targeted successor
  - [ ] Verify both are sorry-free via `lean_verify`
  - [ ] Ensure the construction works within the restricted chain framework (not arbitrary chains)
- **Timing:** 2.5 hours

### Phase 4: Wire to Completeness [NOT STARTED]
- **Goal:** Connect sorry-free `forward_F`/`backward_P` through to `bfmcs_from_mcs_temporally_coherent` and completeness theorems.
- **Tasks:**
  - [ ] Wire `forward_F` into `SuccChainFMCS` temporal coherence fields
  - [ ] Wire `backward_P` into `SuccChainFMCS` temporal coherence fields
  - [ ] Verify `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:237) is now sorry-free
  - [ ] Verify `completeness_over_Int` is sorry-free
  - [ ] Verify `discrete_completeness_fc` is sorry-free
  - [ ] Run `lake build` for clean build
- **Timing:** 1.5 hours

### Phase 5: Verification and Documentation [NOT STARTED]
- **Goal:** Full verification and cleanup.
- **Tasks:**
  - [ ] `lean_verify` on all key theorems in the chain
  - [ ] Grep for remaining sorries in SuccChainFMCS.lean — document active vs deprecated
  - [ ] Update ROADMAP.md to reflect sorry-free completeness status
  - [ ] Update module docstrings
- **Timing:** 0.5 hours

## Testing & Validation

- [ ] `lake build` succeeds with no regressions
- [ ] `lean_verify` confirms `completeness_over_Int` is sorry-free
- [ ] `lean_verify` confirms `discrete_completeness_fc` is sorry-free
- [ ] Grep for `sorry` in Completeness.lean shows only `dense_completeness_fc`
- [ ] Full dependency chain verified: safe_target → forward_F → temporal_coherence → bfmcs → completeness

## Artifacts & Outputs

- Sorry-free `forward_F` and `backward_P` on `SuccChainFMCS`
- Sorry-free `completeness_over_Int` theorem
- Sorry-free `discrete_completeness_fc` theorem
- Safe target lemma as reusable infrastructure
- Updated ROADMAP.md

## Rollback/Contingency

**If safe target lemma is false** (Phase 2 discovers counterexample):
- Fallback to **algebraic temporal shift** approach (ROADMAP line 124): define FMCS via algebraic automorphism of Lindenbaum algebra. This sidesteps F-obligation enumeration entirely but requires significant new infrastructure (separate task).
- Alternative: **restricted completeness** for bounded F-nesting fragment (publishable partial result).

**Do NOT fall back to**:
- Fuel-based termination (dead end: tasks 48, 67, report 14)
- Enriched seed construction (provably false: `constrained_successor_seed_restricted_consistent`)
- Bidirectional temporal witness seed (blocked: H-theory not G-liftable)

**Partial progress preservation**:
- Each phase commits independently
- Phase 2 safe target lemma is valuable even if wiring (Phase 4) encounters gaps
