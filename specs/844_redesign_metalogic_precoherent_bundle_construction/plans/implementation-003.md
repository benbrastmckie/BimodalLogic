# Implementation Plan: Task #844 (K-Distribution Chain Completion)

- **Task**: 844 - Redesign Metalogic Pre-Coherent Bundle Construction
- **Status**: [NOT STARTED]
- **Effort**: 8-10 hours
- **Dependencies**: None (builds on completed Phases 1-3 from implementation-002.md)
- **Research Inputs**:
  - specs/844_redesign_metalogic_precoherent_bundle_construction/reports/research-003.md
  - specs/844_redesign_metalogic_precoherent_bundle_construction/summaries/implementation-summary-20260203.md
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Version**: 003
- **Supersedes**: implementation-002.md (Phases 1-3 completed, Phase 2 sorry blocking)

## Overview

This plan completes the Coherent Witness Chain construction by implementing the K-distribution chain formalization identified as the critical blocking issue in research-003.md. The key theorem `generalized_modal_k` already exists; the gap is connecting it to MCS membership via a helper lemma `mcs_chain_implication`.

### Research Integration

- **research-003.md**: Identified `generalized_modal_k` in GeneralizedNecessitation.lean as the existing K-distribution theorem
- **Key insight**: The gap is formalization (list derivation to MCS closure), not mathematical
- **Proof strategy**: Build `mcs_chain_implication` to iteratively apply modus ponens in MCS

## Goals & Non-Goals

**Goals**:
- Complete the sorry at line 256 in `diamond_boxcontent_consistent_constant`
- Implement `mcs_chain_implication` helper lemma
- Complete Phases 4-8 from implementation-002.md (CoherentBundle structure, BMCS conversion)
- Eliminate `singleFamily_modal_backward_axiom` dependency for CoherentConstruction

**Non-Goals**:
- Eliminating temporal backward sorries (G, H) - fundamental omega-rule limitation
- Removing `singleFamily_modal_backward_axiom` from Construction.lean (it remains as fallback)
- Completing SaturatedConstruction.lean sorries (different root cause)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| deductionChain complex to formalize | Medium | Medium | Use simpler iterative approach with foldr |
| Mutual coherence between witnesses harder than expected | Medium | Medium | Start with single-witness BMCS before multi-witness |
| Zorn's lemma needed for full saturation | High | High | Accept partial saturation first, add Zorn later |
| Type universe issues with context/list conversion | Low | Medium | Use explicit universe annotations |

## Sorry Characterization

### Pre-existing Sorries in Scope

- `diamond_boxcontent_consistent_constant` (CoherentConstruction.lean, line 256): K-distribution chain proof incomplete
  - Case 2 (psi not in L) is complete
  - Case 1 (psi in L) requires K-distribution chain to derive Box(neg psi)

### Expected Resolution

- **Phase 1** resolves line 256 sorry via `mcs_chain_implication` helper
- **Phase 2** completes core viability lemma
- **Phases 3-5** build CoherentBundle without new sorries

### New Sorries

- None expected. The mathematical proof is complete (research-003.md); this is formalization work.

### Remaining Debt

After this implementation:
- `singleFamily_modal_backward_axiom` remains in Construction.lean (valid fallback)
- SaturatedConstruction.lean sorries (lines 714, 733, 785) remain - different scope
- TruthLemma temporal sorries (G, H backward) - fundamental omega-rule limitation

## Implementation Phases

### Phase 1: Implement mcs_chain_implication Helper [NOT STARTED]

**Goal**: Create the helper lemma that connects list-based derivation to MCS membership.

**Estimated effort**: 3-4 hours

**Tasks**:
- [ ] Study `generalized_modal_k` signature and how it transforms contexts
- [ ] Define `theorem_in_mcs` helper if not already present (theorems are in every MCS)
- [ ] Implement `mcs_chain_implication`:
  ```lean
  lemma mcs_chain_implication {S : Set Formula} (h_mcs : SetMaximalConsistent S)
      (L : List Formula) (phi : Formula)
      (h_thm : [] ⊢ L.foldr Formula.imp phi)
      (h_L_in : forall psi in L, psi in S) :
      phi in S
  ```
- [ ] Use induction on L:
  - Base case: `[] ⊢ phi` implies phi is a theorem, use `theorem_in_mcs`
  - Inductive case: `[] ⊢ chi -> rest` and `chi in S`, apply `set_mcs_implication_property`
- [ ] Verify the lemma compiles with `lake build`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` (add helper)

**Verification**:
- [ ] `mcs_chain_implication` compiles without sorry
- [ ] `lean_goal` shows expected type at key proof points

---

### Phase 2: Complete diamond_boxcontent_consistent_constant [NOT STARTED]

**Goal**: Fill in the sorry at line 256 using the new helper lemma.

**Estimated effort**: 2-3 hours

**Tasks**:
- [ ] Import/use `mcs_chain_implication` in CoherentConstruction.lean
- [ ] Complete Case 1 (psi in L) proof:
  1. From `L_filt ⊢ neg psi`, build `[] ⊢ L_filt.foldr Formula.imp (neg psi)` via deductionChain
  2. Apply `generalized_modal_k` with empty context to get `[] ⊢ Box(L_filt.foldr Formula.imp (neg psi))`
  3. Use K-axiom distribution to get `[] ⊢ (Box L_filt).foldr Formula.imp (Box(neg psi))`
  4. Apply `mcs_chain_implication` with `h_filt_in_M` (all Box chi_i in M)
  5. Derive contradiction: Box(neg psi) in M but Diamond psi = neg(Box(neg psi)) in M
- [ ] Verify no new sorries introduced
- [ ] Run `lake build` to confirm compilation

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` (complete sorry)

**Verification**:
- [ ] `diamond_boxcontent_consistent_constant` compiles without sorry
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` returns 0

---

### Phase 3: Define CoherentBundle Structure [NOT STARTED]

**Goal**: Create the bundle structure that collects coherent witnesses.

**Estimated effort**: 1-2 hours

**Tasks**:
- [ ] Define `CoherentBundle` structure:
  ```lean
  structure CoherentBundle (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
    base : IndexedMCSFamily D
    base_constant : IsConstantFamily base
    witnesses : forall psi t, diamondFormula psi in base.mcs t -> CoherentWitness base
  ```
- [ ] Prove `CoherentBundle.allFamilies`: collects base + all witnesses
- [ ] Prove `CoherentBundle.box_coherent`: Box phi in any family implies phi in all families
  - Follows from CoherentWitness.contains_boxcontent
- [ ] Document structure purpose and invariants

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`

**Verification**:
- [ ] Structure definition compiles
- [ ] box_coherent proof is sorry-free

---

### Phase 4: Implement CoherentBundle.toBMCS [NOT STARTED]

**Goal**: Convert CoherentBundle to BMCS interface for TruthLemma compatibility.

**Estimated effort**: 2 hours

**Tasks**:
- [ ] Define `CoherentBundle.toBMCS : CoherentBundle D -> BMCS D`
- [ ] Implement `modal_forward`:
  - If Box phi in fam.mcs t, then phi in fam.mcs t (T-axiom)
  - Standard MCS property
- [ ] Implement `modal_backward`:
  - If phi in ALL families at all times, need Box phi in fam.mcs t
  - Contraposition: if Box phi not in fam.mcs t, then neg(Box phi) = Diamond(neg phi) in fam.mcs t
  - By saturation, exists witness with neg phi
  - But phi in all families including witness - contradiction
- [ ] Verify modal_backward does NOT use `singleFamily_modal_backward_axiom`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`

**Verification**:
- [ ] `toBMCS` compiles without sorry
- [ ] modal_backward proof is self-contained

---

### Phase 5: Construct CoherentBundle from Consistent Context [NOT STARTED]

**Goal**: Provide the main entry point for completeness theorem integration.

**Estimated effort**: 2 hours

**Tasks**:
- [ ] Define `constructCoherentBundle`:
  ```lean
  noncomputable def constructCoherentBundle (Gamma : List Formula)
      (h_cons : ContextConsistent Gamma) : CoherentBundle D
  ```
- [ ] Implementation:
  1. Build base MCS via lindenbaumMCS containing Gamma
  2. Create constantIndexedMCSFamily from base MCS
  3. For each Diamond psi in base, use constructCoherentWitness to get witness
  4. Bundle into CoherentBundle structure
- [ ] Prove `constructCoherentBundle_contains_context`: Gamma is in base.mcs at time 0
- [ ] Define `construct_bmcs_coherent` = constructCoherentBundle.toBMCS

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`

**Verification**:
- [ ] Entry point compiles
- [ ] Context preservation theorem compiles without sorry

---

### Phase 6: Integration and Verification [NOT STARTED]

**Goal**: Verify integration with existing infrastructure and document results.

**Estimated effort**: 1 hour

**Tasks**:
- [ ] Add `construct_bmcs_coherent` export to module
- [ ] Verify TruthLemma works with CoherentBundle.toBMCS (via BMCS interface)
- [ ] Run full `lake build` to confirm no regressions
- [ ] Update module documentation with final approach description
- [ ] Create implementation summary

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` (documentation)
- `specs/844_redesign_metalogic_precoherent_bundle_construction/summaries/implementation-summary-{DATE}.md` (NEW)

**Verification**:
- [ ] `lake build` succeeds for full project
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` returns 0
- [ ] No new axioms introduced

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` returns 0
- [ ] `grep -c "axiom" Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` returns 0
- [ ] `mcs_chain_implication` passes induction proof
- [ ] `diamond_boxcontent_consistent_constant` case 1 resolves via K-distribution
- [ ] modal_backward in toBMCS does not reference `singleFamily_modal_backward_axiom`

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - New `mcs_chain_implication` helper
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Completed construction
- `specs/844_redesign_metalogic_precoherent_bundle_construction/plans/implementation-003.md` - This plan
- `specs/844_redesign_metalogic_precoherent_bundle_construction/summaries/implementation-summary-{DATE}.md` - Final summary

## Rollback/Contingency

If the K-distribution chain formalization proves harder than expected:

1. **Document the specific gap**: What exactly is missing?
2. **Consider alternative proof structure**: The iterative modus ponens can be done differently
3. **Fallback**: Construction.lean with `singleFamily_modal_backward_axiom` remains valid

The axiom-based approach is mathematically sound (canonical model metatheory). This work aims to eliminate it for cleaner formalization, not for correctness.

## Key Technical Insight

The proof strategy for `mcs_chain_implication`:

```lean
-- Goal: phi in S given [] ⊢ L.foldr Formula.imp phi and all L in S
induction L with
| nil =>
  -- [] ⊢ phi means phi is a theorem
  -- All theorems are in every MCS
  exact theorem_in_mcs h_mcs h_thm
| cons chi L' ih =>
  -- [] ⊢ chi -> L'.foldr Formula.imp phi
  -- chi in S (from h_L_in)
  -- Need: L'.foldr Formula.imp phi in S
  -- Then apply set_mcs_implication_property with chi
  have h_rest : [] ⊢ L'.foldr Formula.imp phi := ... -- deduction from h_thm
  have h_rest_in_S := ih h_rest (fun psi h => h_L_in psi (List.mem_cons_of_mem chi h))
  exact set_mcs_implication_property h_mcs h_thm h_L_in.head h_rest_in_S
```

The key insight from research-003.md is that `set_mcs_implication_property` already does modus ponens in MCS; we just need to chain it.

## Success Criteria

- [ ] Zero sorries in CoherentConstruction.lean
- [ ] Zero new axioms introduced
- [ ] `mcs_chain_implication` proven by induction on list
- [ ] `diamond_boxcontent_consistent_constant` fully proven
- [ ] CoherentBundle.toBMCS provides modal_backward without axiom
- [ ] `lake build` succeeds for full project
