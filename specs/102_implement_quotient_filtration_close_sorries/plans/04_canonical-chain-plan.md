# Implementation Plan: Canonical Chain Construction for Until/Since Sorry Closure (v3)

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Status**: [NOT STARTED]
- **Effort**: 28 hours
- **Dependencies**: Task 101 (research, completed)
- **Research Inputs**:
  - specs/102_implement_quotient_filtration_close_sorries/reports/04_task-semantics-research.md
  - specs/102_implement_quotient_filtration_close_sorries/reports/02_team-research.md
  - specs/102_implement_quotient_filtration_close_sorries/reports/03_team-research.md
- **Artifacts**: plans/04_canonical-chain-plan.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close all 10 Until/Since sorries (4 in Frame.lean, 6 in Realization.lean) blocking BX completeness by constructing a linear canonical chain of BXPoints indexed by integers. Round 4 research established that the Frame.lean sorry signatures are **unprovable as stated** because they universally quantify over all BXPoints in a `bx_le` interval, but `bx_le` is a non-total preorder. The resolution is to bypass these signatures entirely: build a canonical chain `(..., w_{-1}, w_0, w_1, ...)` with `task_rel w_i d w_j := (j = i + d)`, which trivially satisfies TaskFrame axioms. The truth lemma is proved directly on the chain, where the guard property is trivially satisfied because the integer ordering is total. Definition of done: all 10 sorries closed (or replaced), `lake build` clean, no new axioms.

### Research Integration

Reports integrated in this plan version:
- `04_task-semantics-research.md` -- Deep analysis establishing that Frame.lean sorry signatures are unprovable; identified canonical chain (Option 3) as the correct approach; mapped existing infrastructure (bx_forward_witness, bx_backward_witness, DefectChain lemmas)
- `02_team-research.md` -- BX7 investigation (inconclusive), Sigma/MCS confusion, backward contradiction impossibility, Realization independence finding
- `03_team-research.md` -- Further BX7/BX11 analysis, confirmation of guard-lifting gap

### Prior Plan Reference

Prior plan: `plans/02_defect-discharge-implementation.md` (v2). Key lessons learned:
- **Phase 1 (SigmaOrdering) and Phase 2 partial (DefectChain)** are completed infrastructure -- reusable but not on the critical path for the new approach
- **BX7 direct proof was time-boxed and inconclusive** -- disjunction analysis does not guarantee the needed case
- **Effort calibration**: v2 estimated 38h total; Phases 1-2 consumed ~14h actual; the remaining 24h were allocated to approaches now known to be dead ends
- **Realization.lean sorries are independent** of Frame.lean -- they cannot be closed by delegation to Frame.lean because they have the same root cause (bx_le non-totality)
- **sigma_strict weakening** was correctly abandoned -- it pushes the problem to TruthLemma call sites

### Roadmap Alignment

This plan advances the following ROAD_MAP.md items:
- **Until/Since eventuality + backward**: Closes 4 Frame.lean sorries (lines 607-647)
- **Active-path sorry reduction**: Reduces active-path sorries from 6 to 4 (box modal-equivalence + TaskModel embedding remain), or to 2 if the chain also resolves the TaskModel embedding
- **Realization.lean sorries**: Closes 6 sorries (lines 471-622) -- same chain-based approach

## Goals & Non-Goals

**Goals**:
- Close all 4 Frame.lean Until/Since sorries by constructing canonical chain proofs
- Close all 6 Realization.lean Until/Since sorries by the same mechanism
- Build a canonical `TaskFrame Int` instance from the BXPoint chain
- Prove the truth lemma for Until/Since on the chain-based model
- `lake build` passes with zero new sorries and zero new axioms
- Preserve all completed infrastructure (SigmaOrdering.lean, DefectChain.lean)

**Non-Goals**:
- Closing the box modal-equivalence sorry (Frame.lean:440) -- separate task
- Closing the TaskModel embedding sorry (Completeness.lean:154) -- may be partially addressed but not the primary target
- Proving bx_le totality on arbitrary BXPoint intervals (impossible and unnecessary)
- Constructing a general finite model / quotient filtration (abandoned approach)
- Modifying the bx_le definition

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Forward chain step Lindenbaum seed consistency is hard to prove | H | M | Existing `forward_temporal_witness_seed_consistent` is a model; the enriched seed adds Until-propagation formulas which are derivable from BX5/BX9 |
| Backward chain step (Since direction) has subtle seed construction | M | M | Mirror Until direction; `past_temporal_witness_seed_consistent` already proved |
| Well-founded recursion on defect count hits Lean termination checker | M | L | Use `Nat.lt_wfRel` with explicit decreasing proof; `sigma_defect_count_bounded` provides the bound |
| Restructuring TruthLemma.lean to use chain-based proofs breaks existing proved cases | H | L | Do NOT modify TruthLemma.lean directly; instead, fill in Frame.lean sorry bodies using the chain construction as an internal proof technique |
| Chain construction requires infinite sequence but Lean prefers finite data | M | M | Use function `Int -> BXPoint` rather than inductive list; the chain is total on Int by construction |

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

### Phase 1: Forward Chain Step Construction [BLOCKED]

**Goal**: Construct the one-step forward chain operation: given a BXPoint `w` with Until-defects, produce a successor `w'` with `bx_le w w'` and either one defect discharged or all defects propagated with the guard formula maintained.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean`
- [ ] Define `forward_chain_seed (w : BXPoint) (phi psi : Formula) : Set Formula` as `{psi} ∪ g_content(w.formulas)` (discharge case) or `{phi, phi U psi} ∪ g_content(w.formulas)` (propagation case)
- [ ] Prove `forward_chain_seed_consistent_discharge`: when `phi U psi ∈ w` and `F(psi) ∈ w`, the seed `{psi} ∪ g_content(w)` is consistent. Strategy: derive from `bx_forward_witness` which already proves this for `{psi} ∪ g_content(w)`
- [ ] Prove `forward_chain_seed_consistent_propagate`: when `phi U psi ∈ w` and `psi ∉ w`, the seed `{phi, phi U psi} ∪ g_content(w)` is consistent. Strategy: BX9 gives `phi ∈ w` (so `phi` is consistent with MCS content), BX5 gives `(phi ∧ (phi U psi)) U psi ∈ w`, and `G(phi) → phi` gives `phi ∈ g_content(w)`-extension... actually use Lindenbaum on `g_content(w) ∪ {phi, phi U psi}` with consistency from `phi ∈ w` and `phi U psi ∈ w` (both are in the MCS, and g_content preserves consistency)
- [ ] Define `forward_step (w : BXPoint) (phi psi : Formula) (h_until : phi U psi ∈ w) (h_not_psi : psi ∉ w) : BXPoint` via Lindenbaum extension of the propagation seed
- [ ] Prove `forward_step_bx_le : bx_le w (forward_step w phi psi ...)` -- follows from `g_content(w) ⊆ (forward_step ...)` by seed construction
- [ ] Prove `forward_step_phi : phi ∈ (forward_step w phi psi ...).formulas` -- from seed membership
- [ ] Prove `forward_step_until : (phi U psi) ∈ (forward_step w phi psi ...).formulas` -- from seed membership
- [ ] Define mirror `backward_step` for Since direction using `h_content` and `bx_backward_witness`
- [ ] Prove corresponding properties for `backward_step`
- [ ] Verify `lake build` passes

**Timing**: 6 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- new file

**Verification**:
- `lake build` compiles with no new errors
- `forward_step` and `backward_step` are proved without sorry
- `bx_le` relationship between step input and output is proved

---

### Phase 2: Defect-Discharge Chain Construction [NOT STARTED]

**Goal**: Build a finite chain from a BXPoint `w` with `phi U psi ∈ w` and `psi ∉ w` to a BXPoint `v` with `psi ∈ v`, such that `phi` holds at every intermediate point and `bx_le` holds between consecutive points. Use well-founded recursion on defect count.

**Tasks**:
- [ ] Define `UntilChain (w : BXPoint) (phi psi : Formula) : Type` as a structure with: endpoint `v : BXPoint`, chain `members : List BXPoint` with `w` at head and `v` at tail, proof that `bx_le` holds between consecutives, proof that `phi ∈ m.formulas` for all `m` except the last, proof that `psi ∈ v.formulas`
- [ ] Define `build_until_chain` by well-founded recursion on `sigma_defect_count w Sigma` where `Sigma` is a finite set containing all relevant Until subformulas
- [ ] Base case: if `psi ∈ w.formulas`, chain is `[w]` with `v = w`
- [ ] Recursive case: use `forward_step` to get `w'`, prove `sigma_defect_count w' Sigma < sigma_defect_count w Sigma` (defect `phi U psi` is discharged because either `psi ∈ w'` or the count decreases by propagation -- key: the propagation step creates w' where the Until is maintained but one step closer to discharge; use the existing `hintikka_step_target_decrease` pattern as a model)
- [ ] Prove `until_chain_guard`: for all members `m` of the chain except the last, `phi ∈ m.formulas`
- [ ] Prove `until_chain_bx_le_transitive`: `bx_le w v` (by transitivity of bx_le along the chain)
- [ ] Prove `until_chain_endpoint`: `psi ∈ v.formulas`
- [ ] Mirror: define `SinceChain` and `build_since_chain` for the backward direction
- [ ] Verify `lake build` passes

**Timing**: 8 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- extend

**Verification**:
- `build_until_chain` terminates (no sorry on termination)
- Chain properties (guard, endpoint, ordering) all proved without sorry
- `lake build` passes cleanly

---

### Phase 3: Close Frame.lean Sorries [NOT STARTED]

**Goal**: Close all 4 Frame.lean sorries by using the chain construction inside each sorry body. The key insight: the sorry signatures quantify over **all** BXPoints in an interval, but we can prove this using the chain as an intermediate -- we construct the chain witness `v` and then show the universal guard property holds by showing that for any `u` with `bx_le w u` and `bx_le u v ∧ not bx_le v u`, we can derive `phi ∈ u` using BX axioms applied to the chain endpoint.

**Strategy for `bx_until_eventuality_resolution`**: The chain gives us `v` with `bx_le w v`, `psi ∈ v`, and the chain-internal guard. For the **universal** guard (arbitrary `u` between `w` and `v`), we need: given `bx_le w u` and `bx_le u v` and `not bx_le v u`, show `phi ∈ u`. The key derivation:
1. From `phi U psi ∈ w` and BX4: `G(P(phi U psi)) ∈ w`
2. From `bx_le w u`: `P(phi U psi) ∈ u`
3. From `bx_backward_witness`: there exists `u' ≤ u` with `phi U psi ∈ u'`
4. From BX9 at `u'`: `phi ∈ u'` or `psi ∈ u'`
5. **New approach**: Instead of trying to lift `phi` from `u'` to `u` (which fails due to bx_le non-totality), use the chain `v` to derive `phi ∈ u` differently.
6. From `bx_le u v` and `psi ∈ v`: by BX4' on `psi` at `v`, `H(F(psi)) ∈ v`; by `bx_H_forward` with `bx_le u v`: `F(psi) ∈ u`. Then BX12: `top U psi ∈ u`.
7. From `phi U psi ∈ u'` with `bx_le u' u`: `G(P(phi U psi)) ∈ u'` (BX4), `P(phi U psi) ∈ u` (bx_le propagation)... this still doesn't give `phi U psi ∈ u`.
8. **Alternative**: Prove the weaker statement that suffices: replace the sorry body with a call to the chain construction. Since we control the chain endpoint `v`, we can **choose** `v` to be the chain endpoint where `psi` first appears. Then use `bx_until_backward` (the other sorry) to complete the loop -- but this is circular.

**Revised strategy**: If the universal guard is truly unprovable, **restructure** the sorry signatures. Replace the 4 sorry'd lemmas with new versions that use chain-based witnesses instead of universal quantification. Then update TruthLemma.lean call sites to use the new versions.

**Tasks**:
- [ ] Attempt to prove `bx_until_eventuality_resolution` using the chain: construct chain from `w`, take endpoint `v`. For the universal guard, attempt the BX4/BX12/BX7 derivation pathway
- [ ] If the universal guard proof works: close the sorry directly
- [ ] If the universal guard proof does not work: create alternative signatures:
  - `bx_until_eventuality_resolution_v2 (w : BXPoint) (phi psi : Formula) (h_until : phi U psi ∈ w) (h_not_psi : psi ∉ w) : ∃ v, bx_le w v ∧ psi ∈ v ∧ ∀ u ∈ chain_members, phi ∈ u`
  - This signature quantifies over chain members, not arbitrary BXPoints
- [ ] If restructuring is needed: update `bx_until_eventuality_resolution` body to call `_v2`, proving the universal guard from the chain-member guard (this requires showing that the TruthLemma only needs the chain-member guard -- which it does, because truth is evaluated along a specific world history, not over arbitrary MCSs)
- [ ] Close `bx_until_backward`: given `v >= w` with `psi ∈ v` and the universal guard, derive `phi U psi ∈ w`. Strategy: use the enriched seed construction (already in Realization.lean) to get `u` with `bx_le w u`, `bx_le u v`, `not(phi U psi) ∈ u`. The guard gives `phi ∈ u`. From `bx_le u v` and `psi ∈ v`: `F(psi) ∈ u` (as above). Then BX12: `top U psi ∈ u`. Apply BX7 with `phi U psi` and `top U psi` to get a contradiction with `not(phi U psi)`.
- [ ] Close `bx_since_eventuality_resolution`: mirror of Until using `bx_backward_witness` and h_content
- [ ] Close `bx_since_backward`: mirror of Until backward
- [ ] Verify TruthLemma.lean compiles without changes (if signatures preserved) or with minimal updates (if signatures changed)
- [ ] Verify `lake build` passes with Frame.lean sorry-free

**Timing**: 8 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- close 4 sorries
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` -- update call sites if signatures change

**Verification**:
- Frame.lean has zero sorries (was 4, excluding the box modal-equivalence sorry at line 440 which is out of scope)
- TruthLemma.lean compiles unchanged or with minimal bridge updates
- `lake build` passes cleanly
- No new axioms

---

### Phase 4: Close Realization.lean Sorries [NOT STARTED]

**Goal**: Close all 6 Realization.lean sorries. These are independent implementations with the same root cause as Frame.lean (bx_le non-totality in guard lifting). Strategy: replace the sorry bodies with calls to the now-proved Frame.lean lemmas via LocusControl.lean, or close independently using the same chain technique.

**Tasks**:
- [ ] Analyze whether Frame.lean's now-proved lemmas can directly close Realization.lean sorries (check signature compatibility between `until_eventuality_resolution` in Realization.lean and `bx_until_eventuality_resolution` in Frame.lean -- they have identical signatures)
- [ ] If signatures match: replace `until_eventuality_resolution` body in Realization.lean with a direct call to `bx_until_eventuality_resolution` (already imported transitively)
- [ ] If signatures do not match: use the chain construction technique directly in each sorry body
- [ ] Close `until_eventuality_resolution` sorry (2 sorry sites at lines 500, 504)
- [ ] Close `until_backward` sorry (1 sorry site at line 564)
- [ ] Close `since_eventuality_resolution` sorry (2 sorry sites at lines 590, 592)
- [ ] Close `since_backward` sorry (1 sorry site at line 622)
- [ ] Update LocusControl.lean if any signatures changed
- [ ] Verify `lake build` passes with Realization.lean sorry-free

**Timing**: 4 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- close 6 sorries
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` -- update if needed

**Verification**:
- Realization.lean has zero sorries (was 6)
- LocusControl.lean delegates correctly
- `lake build` passes cleanly
- No new axioms

---

### Phase 5: Final Validation and Cleanup [NOT STARTED]

**Goal**: Comprehensive verification that all 10 sorries are closed, no regressions, clean build, and imports are properly wired.

**Tasks**:
- [ ] Run `lake build` and verify zero errors
- [ ] Run `lean_verify` on all key theorems:
  - `Bimodal.Metalogic.BXCanonical.bx_until_eventuality_resolution`
  - `Bimodal.Metalogic.BXCanonical.bx_until_backward`
  - `Bimodal.Metalogic.BXCanonical.bx_since_eventuality_resolution`
  - `Bimodal.Metalogic.BXCanonical.bx_since_backward`
  - `Bimodal.Metalogic.BXCanonical.Quasimodel.until_eventuality_resolution`
  - `Bimodal.Metalogic.BXCanonical.Quasimodel.until_backward`
  - `Bimodal.Metalogic.BXCanonical.Quasimodel.since_eventuality_resolution`
  - `Bimodal.Metalogic.BXCanonical.Quasimodel.since_backward`
- [ ] Count total remaining sorries in BXCanonical/ and compare to baseline (was 11: 5 Frame.lean + 6 Realization.lean; target: 1 Frame.lean box sorry remaining)
- [ ] Verify no new axiom declarations across the codebase
- [ ] Add `import Bimodal.Metalogic.BXCanonical.CanonicalChain` to BXCanonical.lean if not already imported
- [ ] Ensure Filtration/SigmaOrdering.lean and Filtration/DefectChain.lean are still importable and compile (preserve existing work even if not on critical path)
- [ ] Clean up any scratch comments or temporary code

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean` -- add CanonicalChain import
- Any files needing cleanup

**Verification**:
- Frame.lean sorry count: 5 -> 1 (box modal-equivalence remains)
- Realization.lean sorry count: 6 -> 0
- Total active-path sorries reduced from 6 to 2 (box modal-equivalence + TaskModel embedding)
- `lean_verify` confirms no axioms beyond standard Lean4/Mathlib axioms
- `lake build` passes cleanly

## Testing & Validation

- [ ] `lake build` passes at end of each phase with no regressions
- [ ] No new `sorry` anywhere in the codebase (net reduction of 10)
- [ ] No new `axiom` declarations
- [ ] `lean_verify` on all 8 key theorems shows clean axiom usage
- [ ] Frame.lean sorry count: 5 -> 1
- [ ] Realization.lean sorry count: 6 -> 0
- [ ] TruthLemma.lean compiles without sorry for Until/Since cases
- [ ] CanonicalChain.lean is properly imported via BXCanonical.lean aggregator

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- new file (chain construction + defect discharge)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- modified (4 Until/Since sorries closed)
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` -- potentially modified if signatures change
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- modified (6 sorries closed)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` -- updated if needed
- `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean` -- add CanonicalChain import
- `specs/102_implement_quotient_filtration_close_sorries/plans/04_canonical-chain-plan.md` -- this plan

## Rollback/Contingency

**If chain seed consistency proofs fail**: The forward_step construction relies on Lindenbaum extension of `g_content(w) ∪ {phi, phi U psi}`. If this seed is not provably consistent, fall back to using `bx_forward_witness` directly (which is already proved) and build the chain one F-witness at a time, losing the defect-counting termination argument but potentially still closing the sorries via a different well-foundedness measure.

**If the universal guard cannot be proved from the chain**: Restructure the Frame.lean sorry signatures to use chain-member quantification instead of universal BXPoint quantification. This requires corresponding updates to TruthLemma.lean but is mathematically sound because truth evaluation operates along specific histories, not over arbitrary MCSs.

**If Realization.lean delegation fails**: Close Realization.lean sorries independently using the exact same chain construction technique inside each sorry body. The sorries are structurally identical to Frame.lean's.

**Git rollback**: Each phase is committed separately. Revert to the last successful phase commit if a later phase cannot be completed. The existing SigmaOrdering.lean and DefectChain.lean are not modified and remain safe.
