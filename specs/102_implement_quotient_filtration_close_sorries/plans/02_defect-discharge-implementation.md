# Implementation Plan: Defect-Discharge Chain Construction and Sorry Closure (v2)

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Status**: [IN PROGRESS]
- **Effort**: 38 hours
- **Dependencies**: Task 101 (research, completed)
- **Research Inputs**:
  - specs/101_research_quotient_filtration_model/reports/01_quotient-filtration-design.md
  - specs/102_implement_quotient_filtration_close_sorries/reports/02_team-research.md
  - specs/102_implement_quotient_filtration_close_sorries/reports/02_teammate-a-findings.md
  - specs/102_implement_quotient_filtration_close_sorries/reports/02_teammate-b-findings.md
  - specs/102_implement_quotient_filtration_close_sorries/reports/02_teammate-c-findings.md
  - specs/102_implement_quotient_filtration_close_sorries/reports/02_teammate-d-findings.md
- **Artifacts**: plans/02_defect-discharge-implementation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the 4 Frame.lean and 6 Realization.lean sorries blocking BX completeness. Round 2 team research identified critical errors in the original plan: (1) the guard extension lemma's fallback confuses Sigma membership with MCS membership, (2) the backward direction cannot work by contradiction, (3) Realization.lean sorries are independent implementations, not wrappers around Frame.lean. The revised plan adopts a staged investigation approach: first attempt a BX7-based direct proof (time-boxed 4h, 50% success probability), then fall back to a finite linear model construction (80% confidence) if BX7 fails. The sigma_strict guard weakening approach is abandoned per team consensus. Definition of done: all 10 sorries closed, `lake build` clean, no new axioms.

### Research Integration

Reports integrated in this revision:
- `02_team-research.md` (synthesis of 4 teammate findings)
- `02_teammate-a-findings.md` (BX7 direct proof strategy, F(psi) derivability)
- `02_teammate-b-findings.md` (literature cross-reference, finite model infrastructure inventory)
- `02_teammate-c-findings.md` (Sigma/MCS confusion error, backward contradiction impossibility, Realization independence)
- `02_teammate-d-findings.md` (Until/Since symmetry, TaskModel bonus, investigation ordering)

### Prior Plan Reference

Revises: `plans/01_defect-discharge-implementation.md` (v1). Preserves Phase 1 [COMPLETED] and Phase 2 [PARTIAL]. Replaces Phases 3-5 entirely based on team research findings.

### Roadmap Alignment

This plan advances the following ROAD_MAP.md items:
- **Until/Since eventuality + backward**: Closes 4 Frame.lean sorries (lines 653, 675, 690, 704)
- **Active-path sorry reduction**: Reduces active-path sorries from 6 to 2 (box modal-equivalence + TaskModel embedding remain)
- Also closes 6 Realization.lean sorries (independent implementations)

### Key Corrections from Team Research

1. **Sigma vs MCS confusion (Finding C1)**: The v1 plan's Phase 3 fallback claimed "G(phi) in enrichedClosure(target)" implies "G(phi) in u'.formulas". These are completely different: Sigma membership is set-theoretic (formula is tracked), MCS membership is logical (formula holds at a point). The guard extension approach based on enrichedClosure properties is unsound as stated.

2. **Backward direction (Finding C2)**: Simple contradiction does not work. Having phi in u and not(phi U psi) in u is perfectly consistent. The backward sorry needs a constructive derivation, not a contradiction argument.

3. **Realization independence (Finding C3)**: The 6 Realization.lean sorries use the quasimodel chain approach independently from Frame.lean. Closing Frame.lean does NOT automatically close them. Strategy: delete Realization.lean implementations and delegate to Frame.lean after Frame.lean is closed.

4. **sigma_strict not viable (Conflict 3)**: Weakening Frame.lean guards from bx_lt to sigma_strict makes signatures easier to prove but creates an equal bridge problem at TruthLemma call sites. Abandoned.

5. **Symmetry reduction (Finding D1)**: Only 2 independent problems exist (Until forward + Until backward). Since mirrors automatically via h_content/g_content duality.

## Goals & Non-Goals

**Goals**:
- Close all 4 Frame.lean Until/Since sorries (forward + backward, both directions)
- Close all 6 Realization.lean Until/Since sorries
- `lake build` passes with zero new sorries and zero new axioms
- Investigate BX7 direct proof as primary approach (time-boxed)
- Build finite linear model as contingency if BX7 fails
- Preserve all completed infrastructure (SigmaOrdering.lean, DefectChain.lean partial)

**Non-Goals**:
- Closing the box modal-equivalence sorry (Frame.lean:440) -- separate task
- Closing the TaskModel embedding sorry (Completeness.lean:154) -- separate task (but may benefit from finite model if built)
- Constructing a general Fintype instance for HintikkaPoints
- Proving global totality of bx_le on BXPoints
- Adding Mathlib Quotient/Setoid infrastructure
- Modifying bx_le definition (cost/risk too high per Finding B4)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| BX7 disjunct analysis does not yield phi at intermediate points | M | M | Time-boxed to 4h; finite model fallback ready |
| Finite linear model requires more infrastructure than estimated | H | L | Extensive reusable infrastructure already exists (HintikkaPoint, sigma_signature, defect_count, hintikka_step); team B inventoried it |
| Backward direction needs fundamentally new approach | H | M | BX7 may handle both directions; finite model makes backward trivial (position ordering is total) |
| Realization.lean delegation to Frame.lean has signature mismatch | M | L | Bridge lemmas can adapt; or close Realization independently using same technique |
| Well-founded recursion on defect count hits Lean termination checker | M | M | Use Nat.lt_wfRel; provide explicit decreasing proof; existing `hintikka_step_target_decrease` is a model |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 or 4-alt | 3 (decision gate) |
| 5 | 5 | 4 or 4-alt |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Sigma Ordering Infrastructure [COMPLETED]

**Goal**: Define the Sigma-restricted ordering predicates and prove their basic properties.

**Tasks**:
- [x] Create `Theories/Bimodal/Metalogic/BXCanonical/Filtration/SigmaOrdering.lean`
- [x] Define `sigma_le`, `sigma_strict`, `sigma_equiv` on BXPoints
- [x] Prove `bx_le_implies_sigma_le`, `sigma_le_refl`, `sigma_strict_irrefl`
- [x] Prove `not_bx_le_of_sigma_strict`, `not_sigma_le_of_sigma_strict`
- [x] Prove `sigma_formula_determined`, `not_sigma_equiv_of_sigma_strict`
- [x] Prove `sigma_strict_of_bx_le_and_witness`, `sigma_H_backward`
- [x] Register imports in Filtration module file
- [x] Verify `lake build` passes

**Timing**: 8 hours (actual)

**Depends on**: none

**Files modified**:
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/SigmaOrdering.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration.lean`

---

### Phase 2: Defect-Discharge Chain Lemmas [BLOCKED]

**Goal**: Define sigma defect count and prove the per-step lemmas needed for chain construction. Complete the well-founded chain construction.

**Tasks**:
- [x] Create `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean`
- [x] Define `sigma_defect_count` and `sigma_since_defect_count`
- [x] Prove `sigma_defect_count_bounded`
- [x] Prove `defect_step_phi` (BX9 extraction), `defect_step_F_psi` (BX10 eventuality)
- [x] Prove `defect_step_connect` (BX4 connectedness), `defect_step_self_accum` (BX5 self-accumulation)
- [x] Mirror lemmas for Since direction
- [ ] Prove `defect_chain_exists`: well-founded recursion on defect count builds the full chain
- [ ] Prove `defect_chain_guard_at_members`: phi at all chain members except last
- [ ] Prove `defect_chain_goal`: psi at last chain member
- [ ] Prove `defect_chain_ordered`: bx_le between consecutive members
- [ ] Mirror chain properties for Since direction
- [ ] Verify `lake build` passes

**Timing**: 6 hours remaining (of original 12)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean`

**Verification**:
- `lake build` compiles with no new errors
- `defect_chain_exists` proved without sorry
- Both Until and Since chain properties proved

---

### Phase 3: BX7 Direct Proof Investigation [COMPLETED]

**Goal**: Time-boxed 4-hour investigation of whether BX7 (linear_until) can directly close the Until forward sorry (`bx_until_eventuality_resolution`). This is a decision gate: success leads to Phase 4, failure leads to Phase 4-alt.

**Tasks**:
- [ ] Read Frame.lean carefully: understand the exact sorry signatures and what needs to be proved
- [ ] Understand BX7 (`linear_until`) axiom: what are its 3 disjuncts? What inputs does it require?
- [ ] Verify F(psi) derivability at intermediate points (Finding A3): given `bx_le u v` and `psi in v`, confirm `F(psi) in u` via `H(F(psi)) in v` (BX4') and `bx_H_forward`
- [ ] Apply BX7 to `(phi U psi)` at backward witness `u'` and `(top U psi)` at `u` (from F(psi) = top U psi)
- [ ] Analyze which of BX7's 3 disjuncts applies:
  - Disjunct 1: `phi U psi` implies `top U psi` (forward containment) -- does this give phi at u?
  - Disjunct 2: `top U psi` implies `phi U psi` (backward containment) -- analyze
  - Disjunct 3: mutual exclusion case -- analyze
- [ ] If BX7 yields `phi in u`: write proof sketch for `bx_until_eventuality_resolution`
- [ ] If BX7 yields `phi in u`: verify backward direction (`bx_until_backward`) also follows
- [ ] Document findings: which disjunct, why it works (or why it fails), exact proof steps
- [ ] **Decision gate**: If BX7 works -> proceed to Phase 4. If BX7 fails -> proceed to Phase 4-alt.

**Timing**: 4 hours (strict time-box)

**Depends on**: 2

**Files to modify**:
- None (investigation only; proof sketches in scratch files or documentation)

**Verification**:
- Clear written determination: BX7 works (with proof sketch) or BX7 fails (with explanation of which step breaks)
- Decision recorded: Phase 4 or Phase 4-alt

---

### Phase 4: Close Frame.lean Sorries via BX7 [NOT STARTED]

**Goal**: If Phase 3 succeeds, implement the BX7-based proof to close all 4 Frame.lean sorries. Keep existing bx_lt guard signatures unchanged (no sigma_strict weakening).

**Precondition**: Phase 3 decision gate = BX7 SUCCESS

**Tasks**:
- [ ] Close `bx_until_eventuality_resolution` sorry using BX7 proof from Phase 3
- [ ] Close `bx_until_backward` sorry: if BX7 handles backward, use same technique; otherwise derive constructively
- [ ] Close `bx_since_eventuality_resolution` sorry: mirror Until forward using h_content/g_content duality
- [ ] Close `bx_since_backward` sorry: mirror Until backward
- [ ] Verify TruthLemma.lean call sites still compile (signatures unchanged)
- [ ] Verify `lake build` passes with Frame.lean sorry-free

**Timing**: 6 hours

**Depends on**: 3 (BX7 success path)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- close 4 sorries

**Verification**:
- Frame.lean has zero sorries (was 4)
- TruthLemma.lean compiles unchanged
- `lake build` passes cleanly
- No new axioms

---

### Phase 4-alt: Finite Linear Model Construction [NOT STARTED]

**Goal**: If Phase 3 fails (BX7 does not work), build an independent finite model with a position-based total ordering where the guard property is trivial. Bypass the bx_le totality problem entirely.

**Precondition**: Phase 3 decision gate = BX7 FAILURE

**Tasks**:
- [ ] Design `FiltrationModel` structure: finite list of HintikkaPoints (or BXPoints) with position-based ordering
- [ ] Leverage existing infrastructure: `HintikkaPoint`, `sigma_signature`, `defect_count`, `hintikka_step`, `hintikka_step_target_decrease`, `enriched_seed_consistent_until`
- [ ] Define ordering as position in chain (total by construction)
- [ ] Prove Until truth lemma in finite model:
  - Forward: chain construction gives witness v with psi; all intermediate points have phi by BX9 at chain members
  - Backward: given witness v with phi U psi and all intermediates have phi, derive phi U psi at the point (constructive, not contradiction)
- [ ] Prove Since truth lemma by mirroring
- [ ] Connect finite model to Frame.lean:
  - Option A: Modify Frame.lean sorries to use finite model witnesses (preferred if signatures can stay close to current)
  - Option B: Close Frame.lean sorries by embedding finite model construction inline
- [ ] Update TruthLemma.lean call sites if signatures change
- [ ] Verify `lake build` passes with Frame.lean sorry-free

**Timing**: 16 hours

**Depends on**: 3 (BX7 failure path)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/FiniteModel.lean` -- new file
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- close 4 sorries
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` -- update call sites if needed

**Verification**:
- Frame.lean has zero sorries (was 4)
- Finite model ordering is total (proved, not assumed)
- `lake build` passes cleanly
- No new axioms

---

### Phase 5: Close Realization.lean Sorries [NOT STARTED]

**Goal**: Close the 6 Realization.lean sorries. These are independent implementations (not wrappers around Frame.lean). Strategy: delete the independent implementations and delegate to Frame.lean infrastructure, or close independently using the same technique that worked for Frame.lean.

**Tasks**:
- [ ] Analyze Realization.lean sorry signatures: understand what each sorry needs to prove
- [ ] Determine delegation strategy:
  - Option A (preferred): Replace Realization.lean sorry bodies with calls to the now-proved Frame.lean lemmas, adding any necessary bridge lemmas for type adaptation
  - Option B: Close independently using the same BX7 or finite-model technique
- [ ] Close `until_eventuality_resolution` sorry at Realization.lean (phi case)
- [ ] Close `until_eventuality_resolution` sorry at Realization.lean (psi case)
- [ ] Close `until_backward` sorry at Realization.lean
- [ ] Close `since_eventuality_resolution` sorry at Realization.lean (phi case)
- [ ] Close `since_eventuality_resolution` sorry at Realization.lean (psi case)
- [ ] Close `since_backward` sorry at Realization.lean
- [ ] Verify `lake build` passes with Realization.lean sorry-free

**Timing**: 4 hours (if delegating to Frame.lean) or 8 hours (if closing independently)

**Depends on**: 4 or 4-alt

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- close 6 sorries

**Verification**:
- Realization.lean has zero sorries (was 6)
- `lake build` passes cleanly
- No new axioms

---

### Phase 6: Final Validation [NOT STARTED]

**Goal**: Comprehensive verification that all 10 sorries are closed, no new sorries or axioms introduced, and the build is clean.

**Tasks**:
- [ ] Run `lake build` and verify zero errors
- [ ] Run `lean_verify` on all 8 key theorems:
  - `bx_until_eventuality_resolution`
  - `bx_until_backward`
  - `bx_since_eventuality_resolution`
  - `bx_since_backward`
  - `until_eventuality_resolution`
  - `until_backward`
  - `since_eventuality_resolution`
  - `since_backward`
- [ ] Count total remaining sorries in BXCanonical/ and compare to baseline
- [ ] Verify no new axiom declarations across the codebase
- [ ] Update LocusControl.lean if it delegates to any modified signatures

**Timing**: 2 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` -- update if needed

**Verification**:
- Frame.lean sorry count: 4 -> 0
- Realization.lean sorry count: 6 -> 0
- Total active-path sorries reduced from 6 to 2 (box modal-equivalence + TaskModel embedding)
- `lean_verify` confirms no axioms beyond standard Lean4/Mathlib axioms
- `lake build` passes cleanly

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

- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/SigmaOrdering.lean` -- existing (Phase 1)
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean` -- existing, to be extended (Phase 2)
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/FiniteModel.lean` -- new, contingent on Phase 4-alt
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- modified (4 sorries closed)
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` -- modified if signatures change
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- modified (6 sorries closed)
- `specs/102_implement_quotient_filtration_close_sorries/plans/02_defect-discharge-implementation.md` -- this plan

## Rollback/Contingency

**If Phase 3 (BX7 investigation) fails**: Proceed to Phase 4-alt (finite linear model). This is the planned contingency, not an error. The finite model approach has 80% confidence and uses extensive existing infrastructure.

**If Phase 4-alt (finite model) also fails**: Fall back to replacing bx_le ordering entirely (nuclear option, 95% confidence, ~20h additional). Replace `bx_le := g_content ⊆` with a chain-constructed linear ordering. Requires reverifying G/H truth lemma. Only pursue if both primary and secondary approaches fail.

**If Realization.lean delegation fails**: Close Realization.lean sorries independently using the same technique that worked for Frame.lean. The sorries are structurally similar even though they use the quasimodel chain approach.

**Git rollback**: Each phase is committed separately. Revert to the last successful phase commit if a later phase cannot be completed.
