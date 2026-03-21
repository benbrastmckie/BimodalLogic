# Implementation Plan: Task #15

- **Task**: 15 - discrete_representation_theorem_axiom_removal
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: Task 14 (SuccChainFMCS, partial)
- **Research Inputs**: specs/015_discrete_representation_theorem_axiom_removal/reports/01_discrete-rep-research.md
- **Artifacts**: plans/01_discrete-rep-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

Wire the Succ-chain FMCS construction from Task 14 into the discrete representation theorem in DiscreteInstantiation.lean. This involves creating a BFMCS wrapper for the SuccChainFMCS, implementing the `construct_bfmcs` function to convert any MCS to a temporally coherent BFMCS, and proving the unconditional discrete representation theorem. The plan follows Option B from research: wire with documented axioms first, then pursue axiom elimination as the scope permits.

### Research Integration

Key findings from research report integrated into this plan:
- The conditional theorem in DiscreteInstantiation.lean requires a `construct_bfmcs` callback
- SuccChainFMCS has 5 axioms (F_top_propagates, P_top_propagates, past_4_axiom, forward_F, backward_P)
- DiscreteSuccSeed.lean has 2 axioms (seed consistency, covering property)
- The `discrete_Icc_finite_axiom` is bypassed by the Succ-chain approach (different construction path)
- MCS seriality (F_top and P_top membership) is derivable from SetMaximalConsistent

## Goals & Non-Goals

**Goals**:
- Create `SuccChainBFMCS.lean` wrapping SuccChainFMCS as a singleton BFMCS
- Implement `construct_bfmcs_impl` using SerialMCS conversion
- Wire to DiscreteInstantiation to obtain unconditional discrete representation theorem
- Prove `past_4_axiom` via temporal duality (eliminates one axiom)
- Document remaining axiom dependencies

**Non-Goals**:
- Full proof of `succ_chain_forward_F_axiom` (requires bounded witness theorem - future task)
- Full proof of `succ_chain_backward_P_axiom` (symmetric to above)
- Proving seed consistency/covering axioms in DiscreteSuccSeed.lean (very hard)
- Removing `discrete_Icc_finite_axiom` (different construction path, not used here)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| MCS seriality proof missing | High | Medium | Use Lindenbaum + provability of F(top) in KTxKT |
| Modal coherence for singleton BFMCS non-trivial | Medium | Low | CanonicalR reflexive, singleton trivially coherent |
| Temporal duality for past_4 blocked | Medium | Medium | Keep as axiom, document why |
| Type mismatches between FMCS/BFMCS interfaces | Low | Medium | Careful interface alignment, reuse TemporalCoherentFamily |

## Implementation Phases

### Phase 1: SerialMCS Infrastructure [COMPLETED]

**Goal**: Establish that every MCS is serial (contains F_top and P_top), enabling conversion to SerialMCS.

**Tasks**:
- [ ] Prove `SetMaximalConsistent.contains_seriality_future`: F(top) is provable in KTxKT, hence in every MCS
- [ ] Prove `SetMaximalConsistent.contains_seriality_past`: P(top) is provable in KTxKT, hence in every MCS
- [ ] Define `MCS_to_SerialMCS`: noncomputable conversion function
- [ ] Verify existing `SerialMCS` structure in SuccChainFMCS.lean is compatible

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Add seriality theorems if not present

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.SuccChainFMCS` succeeds
- `MCS_to_SerialMCS` compiles without sorry

---

### Phase 2: BFMCS Wrapper Construction [IN PROGRESS]

**Goal**: Create `SuccChainBFMCS.lean` that wraps a SuccChainFMCS as a singleton BFMCS with temporal coherence.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean`
- [ ] Define `SingletonBFMCS`: wrap single TemporalCoherentFamily as BFMCS
- [ ] Prove modal coherence for singleton bundle (trivial: single family coherent with itself)
- [ ] Prove temporal coherence using SuccChainTemporalCoherent
- [ ] Define `SuccChainBFMCS M0` combining the above

**Timing**: 1 hour

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean`

**Files to modify**:
- `Theories/Bimodal.lean` (or lakefile) - Add import

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.SuccChainBFMCS` succeeds
- `SuccChainBFMCS M0` has type `BFMCS Int`
- `SuccChainBFMCS_temporally_coherent` theorem exists

---

### Phase 3: construct_bfmcs Implementation [NOT STARTED]

**Goal**: Implement the `construct_bfmcs` callback function that DiscreteInstantiation needs.

**Tasks**:
- [ ] Define `construct_bfmcs_impl` in SuccChainBFMCS.lean:
  - Input: `M : Set Formula`, `h_mcs : SetMaximalConsistent M`
  - Output: `Σ' (B : BFMCS Int) (h_tc : B.temporally_coherent) (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int), M = fam.mcs t`
- [ ] Convert M to SerialMCS using `MCS_to_SerialMCS`
- [ ] Build SuccChainFMCS from SerialMCS
- [ ] Wrap in singleton BFMCS
- [ ] Return with t = 0 (base MCS appears at time 0)
- [ ] Prove `M = fam.mcs 0` (definitional from construction)

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean` - Add construct_bfmcs_impl

**Verification**:
- `construct_bfmcs_impl` compiles (may use axioms from SuccChainFMCS)
- Type signature matches `discrete_representation_conditional` requirement

---

### Phase 4: Wire to DiscreteInstantiation [NOT STARTED]

**Goal**: Use construct_bfmcs_impl to prove the unconditional discrete representation theorem.

**Tasks**:
- [ ] Add import for SuccChainBFMCS to DiscreteInstantiation.lean
- [ ] Define `discrete_representation_unconditional`:
  ```lean
  theorem discrete_representation_unconditional
      (φ : Formula) (h_not_prov : ¬Nonempty (DerivationTree [] φ)) :
      ∃ (B : BFMCS Int) (h_tc : B.temporally_coherent)
        (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
        ¬truth_at DiscreteCanonicalTaskModel (ShiftClosedParametricCanonicalOmega B)
          (parametric_to_history fam) t φ
  ```
- [ ] Prove by applying `discrete_representation_conditional` with `construct_bfmcs_impl`
- [ ] Update module docstring to reflect unconditional theorem availability

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` - Add unconditional theorem

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.DiscreteInstantiation` succeeds
- `#check discrete_representation_unconditional` shows expected type
- No new axioms introduced beyond those in SuccChainFMCS

---

### Phase 5: Axiom Documentation and past_4 Elimination [NOT STARTED]

**Goal**: Document axiom dependencies and attempt to prove past_4_axiom via temporal duality.

**Tasks**:
- [ ] Attempt to prove `past_4_axiom` using:
  - Temporal duality: H(φ) ↔ ¬F(¬φ) and temp_4 for G
  - Or direct proof via proof system rules
- [ ] If past_4 proof succeeds, remove axiom from SuccChainFMCS.lean
- [ ] Add comprehensive axiom documentation section to DiscreteInstantiation.lean:
  - List all axioms the unconditional theorem depends on
  - Note which are from SuccChainFMCS vs DiscreteSuccSeed
  - Document why each is semantically sound
  - Note which could be eliminated in future work
- [ ] Create axiom removal roadmap in module docstring

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Remove past_4_axiom if proven
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` - Add axiom documentation

**Verification**:
- `lake build` succeeds for entire project
- Axiom count reduced by 1 if past_4 proven
- Documentation accurately reflects axiom dependencies

---

## Testing & Validation

- [ ] `lake build` succeeds with no new errors
- [ ] `discrete_representation_unconditional` type checks
- [ ] All existing tests pass
- [ ] No regressions in SuccChainFMCS, DiscreteInstantiation, or dependent modules
- [ ] `#print axioms discrete_representation_unconditional` shows only documented axioms

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean` (new)
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (modified - seriality, possibly past_4 removed)
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` (modified - unconditional theorem + docs)
- `specs/015_discrete_representation_theorem_axiom_removal/plans/01_discrete-rep-plan.md` (this file)
- `specs/015_discrete_representation_theorem_axiom_removal/summaries/01_discrete-rep-summary.md` (after completion)

## Rollback/Contingency

If wiring fails due to unexpected type mismatches or missing lemmas:
1. Keep conditional theorem as primary result
2. Document blockers in DiscreteInstantiation.lean
3. Create follow-up task for resolving blockers
4. Preserve all partial progress in feature branch

If past_4_axiom cannot be proven:
1. Keep it as an axiom
2. Document semantic justification (temporal duality should work)
3. Flag as high-priority for future axiom elimination

If seriality proofs fail:
1. Introduce seriality as an axiom (semantically sound)
2. Document that F(top)/P(top) provability is the blocker
3. Create follow-up task to prove F(top)/P(top) in KTxKT proof system
