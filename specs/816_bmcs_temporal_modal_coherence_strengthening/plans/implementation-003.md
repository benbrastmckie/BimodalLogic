# Implementation Plan: Task #816

- **Task**: 816 - BMCS Temporal Modal Coherence Strengthening via Finite Dynamical System Model
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None (builds on existing FMP infrastructure in Theories/Bimodal/Metalogic/FMP/)
- **Research Inputs**:
  - specs/816_bmcs_temporal_modal_coherence_strengthening/reports/research-013.md (modal saturation)
  - specs/816_bmcs_temporal_modal_coherence_strengthening/reports/research-014.md (FMP-based finite model)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implement a **Finite Dynamical System Model (FDSM)** construction to achieve a sorry-free completeness proof for bimodal TM logic. The key insight from research-014 is that the "omega-rule limitation" claimed in prior plans is **FALSE when using bounded time**: with `BoundedTime k = Fin(2k+1)`, temporal "all future" becomes a finite conjunction, not an infinite one. Combined with multi-history modal saturation from research-013, this eliminates all three target sorries:

1. `TruthLemma.lean:383` - `phi_at_all_future_implies_mcs_all_future` (temporal backward, G)
2. `TruthLemma.lean:394` - `phi_at_all_past_implies_mcs_all_past` (temporal backward, H)
3. `Construction.lean:220` - `modal_backward` in `singleFamilyBMCS` (modal saturation)

**Naming Rationale**: We use "Finite Dynamical System Model" rather than "Finite Branching Model" because world histories in TM logic do not branch - they are deterministic sequences of states indexed by time. The FDSM represents a finite dynamical system with multiple possible trajectories (histories) through a finite state space over bounded time.

### Research Integration

From research-013.md (modal saturation):
- Single-family BMCS cannot satisfy `modal_backward` (Box phi not derivable from phi alone)
- Multi-family construction with modal saturation ensures diamond witnesses exist
- Contrapositive gives modal_backward: if phi in ALL histories, then Box phi must hold

From research-014.md (FMP-based finite model):
- Temporal backward sorries are NOT fundamental - they arise from unbounded time domain
- With `BoundedTime k`, "all future" is a finite set `{s : BoundedTime k | t <= s}`
- The finite conjunction can be internalized in the world state construction
- FMP bounds: at most `2^|closure phi|` world states, `2*temporalDepth(phi)+1` times

## Goals & Non-Goals

**Goals**:
- Implement FDSM construction with bounded time and multi-history modal saturation
- Eliminate `modal_backward` sorry via modal saturation
- Eliminate temporal backward sorries via finite time domain
- Prove truth lemma without sorries for all operators
- Connect FDSM to Validity.lean completeness

**Non-Goals**:
- Removing existing BMCS/FMP code (keep as reference implementation)
- Proving full S5 modal logic properties (TM uses T axiom only)
- Optimizing the cardinality bounds (correctness over efficiency)
- Implementing omega-saturation for unbounded time (this plan proves it unnecessary)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Modal saturation termination complexity | Medium | Medium | Leverage finite closure bound; saturation adds at most 2^|C| families |
| Temporal saturation of finite histories | High | Low | Finite time domain makes this a finite conjunction over known set |
| Integration with existing ClosureMCS | Medium | Medium | Reuse existing `worldStateFromClosureMCS` pattern |
| World state cardinality explosion | Medium | Low | Already bounded by 2^closureSize in FiniteWorldState.lean |
| Proof engineering for finiteness arguments | Medium | Medium | Use Mathlib's `Fintype` and `Finset` automation |

## Implementation Phases

### Phase 1: FDSM Core Structures [NOT STARTED]

**Goal**: Define the core types for finite dynamical system models

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/FDSM/Core.lean`
- [ ] Define `FDSMTime phi := BoundedTime (temporalBound phi)` (reuse existing)
- [ ] Define `FDSMWorldState phi := FiniteWorldState phi` (reuse existing)
- [ ] Define `FDSMHistory phi` structure:
  ```lean
  structure FDSMHistory (phi : Formula) where
    states : FDSMTime phi -> FDSMWorldState phi
    temporal_G_coherent : forall t, (forall s, t <= s -> psi in (states s).toSet) ->
                          G psi in (states t).toSet  -- FINITE CONJUNCTION
    temporal_H_coherent : forall t, (forall s, s <= t -> psi in (states s).toSet) ->
                          H psi in (states t).toSet  -- FINITE CONJUNCTION
  ```
- [ ] Define `FiniteDynamicalSystemModel phi` structure with:
  - `histories : Finset (FDSMHistory phi)`
  - `nonempty : histories.Nonempty`
  - `modal_saturated : ...` (diamond witnesses exist)
  - `eval_history : FDSMHistory phi`
  - `eval_history_mem : eval_history in histories`

**Timing**: 2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/FDSM/Core.lean`

**Verification**:
- Module compiles without errors
- All structures have proper finiteness instances

---

### Phase 2: Temporal Saturation for Finite Histories [NOT STARTED]

**Goal**: Implement history construction with temporal backward coherence

**Tasks**:
- [ ] Define `temporally_saturated_history` construction from closure MCS
- [ ] Prove temporal backward coherence for finite time domain:
  ```lean
  theorem finite_temporal_backward_G (phi : Formula) (S : Set Formula)
      (h_mcs : ClosureMaximalConsistent phi S) (t : FDSMTime phi) (psi : Formula)
      (h_psi_clos : psi in closure phi)
      (h_all_future : forall (s : FDSMTime phi), t <= s -> psi in S) :
      Formula.all_future psi in S
  ```
- [ ] Key insight: `{s : FDSMTime phi | t <= s}` is a finite set (Fin subset)
- [ ] Use `Finset.forall_mem` pattern for finite conjunction
- [ ] Prove symmetric result for `temporal_backward_H`
- [ ] Define `fdsm_history_from_closure_mcs` construction

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/Core.lean` (add to Phase 1 file)

**Verification**:
- `finite_temporal_backward_G` compiles without sorry
- `finite_temporal_backward_H` compiles without sorry

---

### Phase 3: Modal Saturation Construction [NOT STARTED]

**Goal**: Implement diamond witness construction for modal saturation

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean`
- [ ] Define `diamond_formulas phi : Finset Formula` - diamond subformulas in closure
- [ ] Define `witness_set (M : Set Formula) (psi : Formula) : Set Formula`:
  ```lean
  {psi} union {chi | Formula.box chi in M}
  ```
- [ ] Prove `witness_set_consistent`:
  ```lean
  theorem witness_set_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
      (psi : Formula) (h_diamond : Formula.neg (Formula.box (Formula.neg psi)) in M) :
      SetConsistent (witness_set M psi)
  ```
  (Proof: by contrapositive - if witness_set inconsistent, then Box (neg psi) derivable, contradicting diamond)
- [ ] Define `add_witness_history (histories : Finset (FDSMHistory phi)) (psi : Formula) (t : FDSMTime phi)`
- [ ] Prove added history is valid FDSMHistory with temporal coherence

**Timing**: 2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean`

**Verification**:
- `witness_set_consistent` compiles without sorry
- `add_witness_history` produces valid FDSMHistory

---

### Phase 4: Saturation Fixed Point [NOT STARTED]

**Goal**: Implement iteration to modal saturation fixed point

**Tasks**:
- [ ] Define `saturation_step` - one round of adding missing witnesses
- [ ] Define `saturated_histories` - fixed point construction
- [ ] Prove termination: histories bounded by `2^closureSize`
- [ ] Prove `modal_saturated` property at fixed point:
  ```lean
  theorem saturated_histories_modal_saturated (phi : Formula) (h_cons : SetConsistent {phi}) :
      let hists := saturated_histories phi h_cons
      forall h in hists, forall t, forall psi,
        (Formula.box psi).neg in (h.states t).toSet ->
        exists h' in hists, psi.neg in (h'.states t).toSet
  ```
- [ ] Derive `modal_backward` from saturation:
  ```lean
  theorem saturated_modal_backward (phi : Formula) (h_cons : SetConsistent {phi}) :
      let hists := saturated_histories phi h_cons
      forall h in hists, forall t, forall psi,
        (forall h' in hists, psi in (h'.states t).toSet) ->
        Formula.box psi in (h.states t).toSet
  ```
  (Proof: contrapositive using modal_saturated)

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` (continue)

**Verification**:
- Saturation terminates
- `saturated_modal_backward` compiles without sorry

---

### Phase 5: FDSM Truth Lemma [NOT STARTED]

**Goal**: Prove the sorry-free truth lemma for FDSM

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/FDSM/TruthLemma.lean`
- [ ] Define `fdsm_truth_at` for FDSM:
  ```lean
  def fdsm_truth_at (M : FiniteDynamicalSystemModel phi) (h : FDSMHistory phi)
      (t : FDSMTime phi) (psi : Formula) : Prop
  ```
- [ ] Prove truth lemma by structural induction:
  - Atom: trivial by definition
  - Bot: by consistency
  - Imp: by MCS properties
  - Box: by `saturated_modal_backward` (NO SORRY)
  - G (all_future): by `finite_temporal_backward_G` (NO SORRY)
  - H (all_past): by `finite_temporal_backward_H` (NO SORRY)
- [ ] Key theorem:
  ```lean
  theorem fdsm_truth_lemma (M : FiniteDynamicalSystemModel phi)
      (h : FDSMHistory phi) (hh : h in M.histories) (t : FDSMTime phi) (psi : Formula)
      (h_clos : psi in closure phi) :
      psi in (h.states t).toSet <-> fdsm_truth_at M h t psi
  ```

**Timing**: 2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/FDSM/TruthLemma.lean`

**Verification**:
- All six induction cases compile without sorry
- `fdsm_truth_lemma` is completely sorry-free

---

### Phase 6: Validity Bridge and Completeness [NOT STARTED]

**Goal**: Connect FDSM to Validity.lean completeness

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/FDSM/Completeness.lean`
- [ ] Define `fdsm_to_task_frame`:
  ```lean
  def fdsm_to_task_frame (phi : Formula) (M : FiniteDynamicalSystemModel phi) :
      TaskFrame (FDSMTime phi)
  ```
- [ ] Define `fdsm_to_task_model` and `fdsm_to_world_history`
- [ ] Prove truth correspondence with Validity.lean's `truth_at`
- [ ] Prove main completeness theorem:
  ```lean
  theorem fdsm_weak_completeness (phi : Formula) :
      (forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
       (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
       truth_at M tau t phi) ->
      |- phi
  ```
- [ ] Alternative: direct FDSM completeness without Validity bridge
  ```lean
  theorem fdsm_internal_completeness (phi : Formula) :
      (forall M : FiniteDynamicalSystemModel phi,
       fdsm_truth_at M M.eval_history (BoundedTime.origin _) phi) ->
      |- phi
  ```

**Timing**: 1.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/FDSM/Completeness.lean`

**Verification**:
- Completeness theorem compiles without sorry
- Bridge to Validity.lean is type-correct

---

## Testing & Validation

- [ ] `lake build` passes with no errors
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/FDSM/` returns no matches
- [ ] All three target sorries are eliminated:
  - [ ] TruthLemma.lean temporal backward G - replaced by FDSM approach
  - [ ] TruthLemma.lean temporal backward H - replaced by FDSM approach
  - [ ] Construction.lean modal_backward - replaced by FDSM approach
- [ ] FDSM TruthLemma is completely sorry-free
- [ ] Completeness theorem connects to provability

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/FDSM/Core.lean` - FDSM core structures
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` - Modal saturation construction
- `Theories/Bimodal/Metalogic/FDSM/TruthLemma.lean` - Sorry-free truth lemma
- `Theories/Bimodal/Metalogic/FDSM/Completeness.lean` - Completeness theorem
- `specs/816_bmcs_temporal_modal_coherence_strengthening/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If implementation fails:
1. Existing BMCS and FMP code remains functional (kept as reference)
2. Partial FDSM work can be kept in separate module for future completion
3. Document what failed and why in implementation summary
4. Current state with documented sorries is acceptable fallback

**Fallback Approach**: If full FDSM proves too complex:
1. Keep using FMP's `semantic_weak_completeness` as the main sorry-free result
2. Document BMCS sorries as architectural limitations of that specific approach
3. Add FDSM as supplementary "strengthening" when complete

## Mathematical Summary

### Why FDSM Succeeds

| Problem | BMCS Approach | FDSM Solution |
|---------|---------------|---------------|
| Modal backward | Single family: phi in MCS does NOT imply Box phi in MCS | Multi-history: if phi in ALL histories, Box phi by saturation |
| Temporal G backward | Unbounded time: infinite conjunction (omega-rule) | Bounded time: finite conjunction over `Fin(2k+1)` |
| Temporal H backward | Unbounded time: infinite conjunction (omega-rule) | Bounded time: finite conjunction over `Fin(2k+1)` |

### Key Insight: No Omega-Rule Needed

With unbounded time `D : Type*`:
- "forall s >= t, psi at s" is potentially infinite
- Cannot be captured by finitary proof systems

With bounded time `BoundedTime k = Fin(2k+1)`:
- "forall s >= t, psi at s" is a finite set: `{s : Fin(2k+1) | t <= s}`
- Finite conjunction: `psi(t) and psi(t+1) and ... and psi(k)`
- Can be internalized in the world state construction

### FDSM Cardinality Bounds

- Histories: at most `2^closureSize phi` distinct histories (by FMP)
- Times per history: exactly `2*temporalDepth(phi)+1` time points
- World states: at most `2^closureSize phi` distinct states
- Total model size: polynomial in formula size
