# Implementation Plan: Defect-Discharge Chain Construction and Sorry Closure

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Status**: [IN PROGRESS]
- **Effort**: 45 hours
- **Dependencies**: Task 101 (research, completed)
- **Research Inputs**: specs/101_research_quotient_filtration_model/reports/01_quotient-filtration-design.md
- **Artifacts**: plans/01_defect-discharge-implementation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the 4 Frame.lean and 6 Realization.lean sorries blocking BX completeness by implementing a defect-discharge chain construction. Task 101 research established that the naive quotient/Setoid approach fails because `bx_le` (g_content inclusion) is not total even on Sigma-equivalence classes, and BX11 does not provide the needed totality. The viable path modifies the Frame.lean sorry signatures to use a `sigma_strict` guard (Sigma-restricted strict ordering) instead of the unprovable `not bx_le v u` guard, constructs defect-discharge chains via well-founded induction on `sigma_defect_count`, and proves a guard extension lemma covering arbitrary intermediate BXPoints. The TruthLemma.lean and Realization.lean call sites are then updated to use the modified signatures.

### Research Integration

The research report (task 101) provides the complete mathematical design:

- **Finding 1**: `bx_le` is not total even on Sigma-equivalence classes sharing a common ancestor. BX11 gives ordering of F-witnesses but not g_content-inclusion totality.
- **Finding 2**: The correct approach constructs a defect-discharge chain and proves the guard via Sigma-determined formula membership, not preorder totality.
- **Finding 3**: Frame.lean sorry signatures must be REPLACED, not filled. The guard condition `not bx_le v u` is strictly stronger than what semantic truth requires; `sigma_strict Sigma u v` is the correct weakening.
- **Finding 4**: The enrichedClosure's G/H-enrichment properties (`enrichedGNegBigconj`, `enrichedHNegBigconj`) are the key ingredient for the guard extension lemma.
- **Axiom map**: BX1 (reflexivity), BX4/BX4' (connectedness), BX5/BX5' (self-accumulation), BX6/BX6' (absorption), BX9/BX9' (elimination), BX10/BX10' (eventuality extraction), temp_4 (G-transitivity). BX7/BX11 are NOT needed for the final design.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This plan advances the following ROAD_MAP.md items:
- **Until/Since eventuality + backward**: Closes 4 Frame.lean sorries (lines 653, 675, 690, 704)
- **Active-path sorry reduction**: Reduces active-path sorries from 6 to 2 (box modal-equivalence + TaskModel embedding remain)
- Also closes 6 Realization.lean sorries that delegate to Frame.lean

## Goals & Non-Goals

**Goals**:
- Close all 4 Frame.lean Until/Since sorries (forward + backward, both directions)
- Close all 6 Realization.lean Until/Since sorries
- `lake build` passes with zero new sorries and zero new axioms
- Define `sigma_strict`, `sigma_equiv`, `sigma_defect_count` on BXPoints using enrichedClosure
- Construct defect-discharge chains via well-founded recursion
- Prove the guard extension lemma for arbitrary intermediate BXPoints

**Non-Goals**:
- Closing the box modal-equivalence sorry (Frame.lean:440) -- separate task
- Closing the TaskModel embedding sorry (Completeness.lean:154) -- separate task
- Constructing a general Fintype instance for HintikkaPoints
- Proving global totality of any ordering on BXPoints
- Adding Mathlib Quotient/Setoid infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Guard extension lemma fails (enrichedClosure G/H-enrichment insufficient to determine phi at arbitrary intermediate BXPoints) | H | M | Fallback: replace bx_le entirely with chain-constructed linear ordering (+20h) |
| Modified Frame.lean signatures break TruthLemma call sites | M | L | TruthLemma uses both directions symmetrically; update call sites in same phase |
| Defect-discharge step requires Until-induction not available | H | L | BX5+BX6+BX9 self-accumulation chain should suffice per research |
| Well-founded recursion on sigma_defect_count hits Lean termination checker issues | M | M | Use Nat.lt_wfRel or WellFoundedRelation instance; provide explicit decreasing proof |
| Since direction is not a clean mirror of Until (asymmetric bx_le direction) | M | L | Research confirms h_content duality holds; implement Until first, mirror carefully |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Sigma Ordering Infrastructure [COMPLETED]

**Goal**: Define the Sigma-restricted ordering predicates and prove their basic properties, establishing the vocabulary used by all subsequent phases.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Filtration/SigmaOrdering.lean`
- [ ] Define `sigma_le` (Sigma-restricted preorder on BXPoints): `forall f, G(f) in Sigma -> G(f) in w.formulas -> f in v.formulas`
- [ ] Define `sigma_strict` (strict version): `sigma_le w v` and `exists f, G(f) in Sigma` and `G(f) in v.formulas` and `f not in w.formulas`
- [ ] Define `sigma_equiv` (agreement on all Sigma-formulas): `forall f in Sigma, f in w.formulas <-> f in v.formulas`
- [ ] Prove `bx_le_implies_sigma_le`: `bx_le w v -> sigma_le Sigma w v`
- [ ] Prove `sigma_le_refl`: reflexivity from BX1
- [ ] Prove `sigma_le_trans`: transitivity from temp_4
- [ ] Prove `sigma_equiv_of_le_and_ge`: `sigma_le w v -> sigma_le v w -> sigma_equiv w v`
- [ ] Prove `sigma_formula_determined`: `f in Sigma -> sigma_equiv w v -> (f in w.formulas <-> f in v.formulas)`
- [ ] Prove `sigma_strict_irrefl`: `not (sigma_strict Sigma w w)`
- [ ] Prove `not_bx_le_of_sigma_strict_and_enriched`: when `Sigma = enrichedClosure target`, `sigma_strict Sigma u v` implies `not (sigma_le Sigma v u)` (uses enrichedClosure properties)
- [ ] Register imports in Filtration module file
- [ ] Verify `lake build` passes

**Timing**: 8 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/SigmaOrdering.lean` -- new file
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration.lean` -- new module aggregator (or add to BXCanonical.lean)

**Verification**:
- `lake build` compiles with no new errors
- All sigma_le/sigma_strict/sigma_equiv lemmas stated and proved (no sorry)
- `bx_le_implies_sigma_le` connects old infrastructure to new

---

### Phase 2: Defect-Discharge Chain Construction [PARTIAL]

**Goal**: Define the sigma defect count, construct defect-discharge chains by well-founded recursion, and prove that chains have the guard property at chain members and the goal at the terminal point.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean`
- [ ] Define `sigma_defect_count`: count of Until formulas in `Sigma` whose goal formula is absent from the BXPoint
- [ ] Prove `sigma_defect_count_bounded`: `sigma_defect_count w Sigma <= Sigma.card`
- [ ] Define `DefectChain` structure: list of BXPoints with `bx_le` between consecutive, phi at all but last, psi at last
- [ ] Prove `defect_discharge_step`: given `phi U psi in w` and `psi not in w`, construct successor `v` with `bx_le w v` and either `psi in v` (done) or `phi U psi in v, phi in v, sigma_defect_count v Sigma < sigma_defect_count w Sigma`
  - Uses BX9 (phi or psi extraction), BX10 (F(psi) extraction), BX5 (self-accumulation)
  - Successor constructed via enriched Lindenbaum seed from `chain_step_seed_consistent_enriched` (existing in Construction.lean or similar)
- [ ] Prove `defect_chain_exists`: well-founded recursion on defect count builds the full chain
  - Termination: `sigma_defect_count` strictly decreases at each non-terminal step
  - Terminal: `psi in v` at the endpoint
- [ ] Prove `defect_chain_guard_at_members`: for all chain members except the last, `phi in wi.formulas`
- [ ] Prove `defect_chain_goal`: `psi in wk.formulas` at the last chain member
- [ ] Prove `defect_chain_ordered`: `bx_le wi w(i+1)` for consecutive chain members
- [ ] Mirror for Since direction: `SinceDefectChain` using h_content and backward witnesses
- [ ] Verify `lake build` passes

**Timing**: 12 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean` -- new file

**Verification**:
- `lake build` compiles with no new errors
- `defect_chain_exists` proved without sorry (well-founded recursion terminates)
- Chain properties (guard at members, goal at end, ordered) all proved
- Both Until and Since directions covered

---

### Phase 3: Guard Extension Lemma [NOT STARTED]

**Goal**: Prove that the guard property extends from chain members to arbitrary intermediate BXPoints. This is the mathematically hardest phase and the critical path of the entire task.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Filtration/GuardExtension.lean`
- [ ] Prove the core guard extension theorem:
  ```
  guard_extension: Given a defect-discharge chain from w to v (with phi U psi),
  for any u with bx_le w u, bx_le u v, and sigma_strict Sigma u v:
  phi in u.formulas
  ```
- [ ] The proof strategy uses these sub-lemmas:
  - [ ] `g_content_sigma_propagation`: `bx_le w u -> G(f) in Sigma -> G(f) in w.formulas -> f in u.formulas`
  - [ ] `h_content_sigma_propagation`: `bx_le u v -> H(f) in Sigma -> H(f) in v.formulas -> f in u.formulas`
  - [ ] `enriched_g_constraint`: The enrichedClosure's `enrichedGNegBigconj` formulas constrain which Sigma-formulas can hold at intermediate points
  - [ ] `enriched_h_constraint`: Mirror using `enrichedHNegBigconj`
  - [ ] `sigma_strict_phi_from_constraints`: combining g_content(w) and h_content(v) constraints within Sigma determines phi membership at u
- [ ] If the direct enrichedClosure argument is insufficient, implement the fallback sub-strategy:
  - [ ] Show that `P(phi U psi) in u` (from BX4 + bx_le w u)
  - [ ] Show backward witness `u'` with `phi U psi in u'` and `bx_le u' u`
  - [ ] Show `phi in u'` from BX9 (since defect analysis constrains the disjunction)
  - [ ] Show `G(phi) in u'` using enrichedClosure membership of `G(phi)` when `phi U psi in Sigma`
  - [ ] Conclude `phi in u` from `bx_le u' u` and `G(phi) in u'`
- [ ] Mirror for Since direction using h_content/g_content duality
- [ ] Verify `lake build` passes

**Timing**: 15 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/GuardExtension.lean` -- new file

**Verification**:
- `lake build` compiles with no new errors
- `guard_extension` theorem proved without sorry
- Both Until and Since versions proved
- No new axioms introduced (check with `lean_verify` on key theorems)

---

### Phase 4: Modify Frame.lean Signatures and Close Sorries [NOT STARTED]

**Goal**: Replace the 4 Frame.lean sorry signatures with `sigma_strict`-guarded versions and close them using the defect-discharge chain + guard extension infrastructure from phases 1-3.

**Tasks**:
- [ ] Modify `bx_until_eventuality_resolution` signature: replace `not bx_le v u` guard with `sigma_strict (enrichedClosure target) u v` guard, adding `target : Formula` and `h_in_sigma : Formula.untl phi psi in enrichedClosure target` parameters
- [ ] Close `bx_until_eventuality_resolution` sorry: construct defect chain, take last element as witness v, guard follows from guard_extension
- [ ] Modify `bx_until_backward` signature: same guard replacement
- [ ] Close `bx_until_backward` sorry: contradiction argument using enriched seed + sigma_strict guard
- [ ] Modify `bx_since_eventuality_resolution` signature: mirror for Since using h_content direction
- [ ] Close `bx_since_eventuality_resolution` sorry
- [ ] Modify `bx_since_backward` signature: mirror
- [ ] Close `bx_since_backward` sorry
- [ ] Update TruthLemma.lean call sites for all 4 modified signatures:
  - `truth_lemma_until` forward case (line ~295): pass enrichedClosure target and membership proof
  - `truth_lemma_until` backward case (line ~306): pass enrichedClosure target and membership proof
  - `truth_lemma_since` forward case (line ~345): mirror
  - `truth_lemma_since` backward case (line ~356): mirror
- [ ] Verify call site compatibility: the TruthLemma already works with enrichedClosure (via the Quasimodel infrastructure), so the Sigma parameter should be available in scope
- [ ] Verify `lake build` passes with Frame.lean and TruthLemma.lean sorry-free

**Timing**: 5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- modify 4 signatures, close 4 sorries
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` -- update 4 call sites

**Verification**:
- Frame.lean has zero sorries (was 4)
- TruthLemma.lean Until/Since cases compile without sorry
- `lake build` passes cleanly
- No new axioms (verify with `lean_verify`)

---

### Phase 5: Close Realization.lean Sorries and Final Validation [NOT STARTED]

**Goal**: Close the 6 Realization.lean sorries that delegate to the Frame.lean infrastructure, and perform final validation that no new sorries or axioms were introduced.

**Tasks**:
- [ ] Close `until_eventuality_resolution` sorry at Realization.lean:500 (phi case): use guard_extension with defect chain to show phi propagates
- [ ] Close `until_eventuality_resolution` sorry at Realization.lean:504 (psi case): handle case where psi holds at backward witness
- [ ] Close `until_backward` sorry at Realization.lean:564: use enriched seed construction + sigma_strict guard to derive contradiction
- [ ] Close `since_eventuality_resolution` sorry at Realization.lean:590 (phi case): mirror of Until
- [ ] Close `since_eventuality_resolution` sorry at Realization.lean:592 (psi case): mirror
- [ ] Close `since_backward` sorry at Realization.lean:622: mirror of until_backward
- [ ] Update LocusControl.lean if it delegates to any of the modified Realization.lean signatures
- [ ] Run `lake build` and verify zero new sorries across entire project
- [ ] Run `lean_verify` on key theorems to confirm no new axioms:
  - `bx_until_eventuality_resolution`
  - `bx_until_backward`
  - `bx_since_eventuality_resolution`
  - `bx_since_backward`
  - `until_eventuality_resolution`
  - `until_backward`
  - `since_eventuality_resolution`
  - `since_backward`
- [ ] Count total remaining sorries in BXCanonical/ and compare to baseline

**Timing**: 5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- close 6 sorries
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` -- update if needed

**Verification**:
- Realization.lean has zero sorries (was 6)
- `lake build` passes with zero new sorries and zero new axioms
- Total active-path sorries reduced from 6 to 2 (box modal-equivalence + TaskModel embedding)
- `lean_verify` confirms no axioms beyond the standard Lean4/Mathlib axioms

## Testing & Validation

- [ ] `lake build` passes at end of each phase with no regressions
- [ ] No new `sorry` anywhere in the codebase
- [ ] No new `axiom` declarations
- [ ] `lean_verify` on all 8 key theorems shows clean axiom usage
- [ ] Frame.lean sorry count: 4 -> 0
- [ ] Realization.lean sorry count: 6 -> 0
- [ ] TruthLemma.lean compiles without sorry for Until/Since cases
- [ ] All new files in Filtration/ are properly imported via module aggregator

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/SigmaOrdering.lean` -- new
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean` -- new
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/GuardExtension.lean` -- new
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- modified (4 sorries closed)
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` -- modified (call site updates)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- modified (6 sorries closed)
- `specs/102_implement_quotient_filtration_close_sorries/plans/01_defect-discharge-implementation.md` -- this plan
- `specs/102_implement_quotient_filtration_close_sorries/summaries/01_defect-discharge-summary.md` -- post-implementation

## Rollback/Contingency

**If Phase 3 (guard extension) fails**: The enrichedClosure G/H-enrichment may not suffice to determine `phi in u` from chain constraints alone. Fallback: replace `bx_le` entirely with a chain-constructed linear ordering on BXPoints. This avoids the guard extension problem by making the ordering total by construction, but requires rewriting Frame.lean more extensively. Estimated additional cost: +20 hours.

**If modified signatures break downstream**: The signature changes in Phase 4 are additive (new parameters), not destructive. If TruthLemma cannot supply the Sigma/membership parameters, add sorry-bridging lemmas that recover the old signature from the new one (temporary, to unblock).

**Git rollback**: Each phase is committed separately. Revert to the last successful phase commit if a later phase cannot be completed.
