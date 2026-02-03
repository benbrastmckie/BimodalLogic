# Implementation Plan: Task #844 (Revision)

- **Task**: 844 - Redesign Metalogic Pre-Coherent Bundle Construction
- **Status**: [IMPLEMENTING]
- **Effort**: 12-16 hours
- **Dependencies**: None (supersedes failed implementation-001.md)
- **Research Inputs**:
  - specs/844_redesign_metalogic_precoherent_bundle_construction/reports/research-002.md
  - specs/844_redesign_metalogic_precoherent_bundle_construction/summaries/implementation-summary-20260203.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Version**: 002
- **Supersedes**: implementation-001.md (Pre-Coherent Bundle approach - FAILED)

## Overview

This plan implements **Approach B: Coherent Witness Chain Construction** from research-002.md. The previous Pre-Coherent Bundle approach (implementation-001.md) was proven mathematically impossible because S-boundedness (an intra-family property) cannot enforce box-coherence (an inter-family property).

The Coherent Witness Chain approach builds families incrementally with coherence built into the construction step-by-step, rather than hoping coherence emerges from a product of locally-constrained families. The key insight is that witness families must include BoxContent in their seed to ensure agreement with the base family.

### Research Integration

- **research-002.md**: Provides the Coherent Witness Chain construction strategy, the diamond_boxcontent_consistent lemma proof sketch, and the key insight that coherence must be built into construction
- **implementation-summary-20260203.md**: Documents the Pre-Coherent Bundle failure and identifies the false claim that doomed the approach

## Goals & Non-Goals

**Goals**:
- Eliminate `singleFamily_modal_backward_axiom` from Construction.lean
- Achieve zero sorries in the bundle construction (construction sorries only)
- Implement CoherentWitness structure with built-in coherence guarantee
- Prove `diamond_boxcontent_consistent` lemma (core viability lemma)
- Construct CoherentBundle that satisfies BMCS interface
- Maintain compatibility with existing TruthLemma infrastructure

**Non-Goals**:
- Eliminating temporal backward sorries (G, H) - these are fundamental omega-rule limitations
- Changing the BMCS interface structure
- Modifying the completeness theorem signatures
- Full multi-family saturation for arbitrary formulas (closure-bounded suffices)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| diamond_boxcontent_consistent proof fails | High | Low | Proof sketch in research-002.md is sound; K distribution argument is standard |
| BoxContent over all times creates issues | Medium | Medium | Use constant families where MCS is same at all times (temporal simplification) |
| Mutual coherence between witnesses | Medium | Medium | Build witnesses coherent with accumulated bundle, not just base |
| Zorn's lemma formalization complex | Medium | High | Reuse existing SaturatedConstruction.lean infrastructure |

## Sorry Characterization

### Pre-existing Sorries

- **singleFamily_modal_backward_axiom** (Construction.lean, line 228): Axiom justifying modal_backward for single-family BMCS. This is the target for elimination.
- **SaturatedConstruction.lean sorries** (lines 714, 733, 785): Technical gaps in Zorn-based saturation proof related to BoxContent preservation.
- **TruthLemma.lean temporal sorries** (lines 383, 395): G/H backward - fundamental omega-rule limitation, NOT addressed by this task.

### Expected Resolution

- **Phase 3** resolves `singleFamily_modal_backward_axiom` by providing constructive modal_backward via CoherentBundle
- **Phase 4** may resolve SaturatedConstruction sorries if the coherent witness construction addresses their root causes

### New Sorries

- None expected. If proof complexity requires temporary sorry, will document with remediation timeline.

### Remaining Debt

After this implementation:
- TruthLemma temporal sorries (G, H backward) remain - documented as fundamental omega-rule limitation
- No new sorries expected in bundle construction
- Completeness theorems no longer depend on modal_backward axiom

## Implementation Phases

### Phase 1: Define BoxContent and CoherentWitness Structures [COMPLETED]

**Goal**: Establish the core data structures for the Coherent Witness Chain construction.

**Estimated effort**: 2 hours

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`
- [ ] Define `BoxContent (fam : IndexedMCSFamily D) : Set Formula` - the set of all chi where Box chi appears in fam at any time
- [ ] Define `WitnessSeed (base : IndexedMCSFamily D) (psi : Formula) : Set Formula` = {psi} ∪ BoxContent(base)
- [ ] Define `CoherentWitness` structure with family + coherence proof
- [ ] Add necessary imports (BMCS, IndexedMCSFamily, MCSProperties, etc.)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` (NEW)

**Verification**:
- [ ] File compiles without errors
- [ ] `lean_hover_info` confirms correct types for BoxContent and WitnessSeed

---

### Phase 2: Prove diamond_boxcontent_consistent Lemma [IN PROGRESS]

**Goal**: Prove the core viability lemma that makes Approach B possible.

**Estimated effort**: 3-4 hours

**Tasks**:
- [ ] Implement `diamond_boxcontent_consistent` theorem
- [ ] Follow proof sketch from research-002.md:
  1. Suppose {psi} ∪ BoxContent derives bot
  2. Extract finite witness list chi_1, ..., chi_n with Box chi_i in base.mcs
  3. By deduction theorem: chi_1, ..., chi_n |- neg psi
  4. By necessitation: Box(chi_1 -> ... -> chi_n -> neg psi) is theorem
  5. By K distribution: Box chi_1 -> ... -> Box chi_n -> Box(neg psi)
  6. All Box chi_i in base.mcs, so Box(neg psi) in base.mcs
  7. But Diamond psi = neg(Box(neg psi)) in base.mcs - contradiction
- [ ] May need helper lemmas for K distribution chain
- [ ] May need lemma connecting finite derivation to list subset

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`

**Verification**:
- [ ] Theorem statement matches research-002.md signature
- [ ] No sorries in proof
- [ ] `lake build Bimodal.Metalogic.Bundle.CoherentConstruction` succeeds

---

### Phase 3: Construct Coherent Witness Families [NOT STARTED]

**Goal**: Implement the witness family construction with built-in coherence.

**Estimated effort**: 2-3 hours

**Tasks**:
- [ ] Define `constructCoherentWitness` using:
  1. Extract WitnessSeed = {psi} ∪ BoxContent(base)
  2. Use `diamond_boxcontent_consistent` to prove seed consistent
  3. Apply Lindenbaum to extend to MCS
  4. Build constantWitnessFamily from MCS
  5. Prove coherence property from seed inclusion
- [ ] Prove `constructCoherentWitness_contains_psi`: witness contains the Diamond's inner formula
- [ ] Prove `constructCoherentWitness_coherent`: witness satisfies coherence with base

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`

**Verification**:
- [ ] `constructCoherentWitness` compiles without sorry
- [ ] Both theorems (`_contains_psi`, `_coherent`) compile without sorry

---

### Phase 4: Define CoherentBundle Structure [NOT STARTED]

**Goal**: Create the bundle structure that collects coherent witnesses.

**Estimated effort**: 2-3 hours

**Tasks**:
- [ ] Define `CoherentBundle` structure with:
  - `base : IndexedMCSFamily D`
  - `witnesses : Set (CoherentWitness base)`
  - `base_included : base ∈ allFamilies` (or equivalent)
  - `saturated : forall Diamond psi in base, exists witness with psi`
- [ ] Define `CoherentBundle.allFamilies : Set (IndexedMCSFamily D)`
- [ ] Prove `CoherentBundle.box_coherent`: Box phi in any family implies phi in all families
- [ ] Prove `CoherentBundle.modal_saturated`: Diamond formulas have witnesses

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`

**Verification**:
- [ ] Structure compiles
- [ ] box_coherent proof is sorry-free
- [ ] modal_saturated proof is sorry-free

---

### Phase 5: Implement CoherentBundle.toBMCS Conversion [NOT STARTED]

**Goal**: Convert CoherentBundle to BMCS interface for TruthLemma compatibility.

**Estimated effort**: 2-3 hours

**Tasks**:
- [ ] Define `CoherentBundle.toBMCS : CoherentBundle D -> BMCS D`
- [ ] Prove `modal_forward` from box_coherent (T-axiom application)
- [ ] Prove `modal_backward` from saturation via contraposition argument:
  1. If phi in all families but Box phi not in fam.mcs t
  2. Then neg(Box phi) = Diamond(neg phi) in fam.mcs t
  3. By saturation, exists witness with neg phi
  4. But phi in all families including witness - contradiction
- [ ] Verify eval_family is base family

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`

**Verification**:
- [ ] `toBMCS` compiles without sorry
- [ ] modal_backward proof does NOT use singleFamily_modal_backward_axiom

---

### Phase 6: Construct CoherentBundle from Consistent Context [NOT STARTED]

**Goal**: Provide the main entry point for completeness theorem integration.

**Estimated effort**: 1-2 hours

**Tasks**:
- [ ] Define `constructCoherentBundle (Gamma : List Formula) (h_cons : ContextConsistent Gamma) : CoherentBundle D`
  1. Build base family via Lindenbaum (reuse existing lindenbaumMCS)
  2. Construct constantIndexedMCSFamily from base MCS
  3. Iteratively/non-constructively add coherent witnesses for all Diamonds
  4. May use Zorn's lemma for existence (adapt from SaturatedConstruction)
- [ ] Prove `constructCoherentBundle_contains_context`: Gamma is in base.mcs 0
- [ ] Define `construct_bmcs_coherent` = constructCoherentBundle.toBMCS

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`

**Verification**:
- [ ] Entry point compiles
- [ ] Context preservation theorem compiles without sorry

---

### Phase 7: Integration and Cleanup [NOT STARTED]

**Goal**: Integrate with existing completeness infrastructure and document changes.

**Estimated effort**: 1-2 hours

**Tasks**:
- [ ] Add `construct_bmcs_coherent` export to bundle module
- [ ] Update `Bimodal.lean` imports if needed
- [ ] Document relationship between CoherentConstruction and existing Construction.lean
- [ ] Verify TruthLemma works with coherent BMCS (should be automatic via BMCS interface)
- [ ] Add module documentation explaining approach B implementation
- [ ] Update PreCoherentBundle.lean header to reference this as the successful approach

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` (documentation)
- `Theories/Bimodal/Metalogic/Bundle/PreCoherentBundle.lean` (cross-reference)
- `Theories/Bimodal.lean` (imports, if needed)

**Verification**:
- [ ] `lake build` succeeds for full project
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` returns 0
- [ ] No new axioms introduced

---

### Phase 8: Verification and Sorry Audit [NOT STARTED]

**Goal**: Final verification that the axiom is eliminated and construction is sorry-free.

**Estimated effort**: 1 hour

**Tasks**:
- [ ] Run full project build: `lake build`
- [ ] Audit sorry count in new file: should be 0
- [ ] Verify singleFamily_modal_backward_axiom is not used by CoherentConstruction
- [ ] Document final sorry/axiom status in implementation summary
- [ ] Create implementation summary at `specs/844_redesign_metalogic_precoherent_bundle_construction/summaries/implementation-summary-{DATE}.md`

**Files to modify**:
- `specs/844_redesign_metalogic_precoherent_bundle_construction/summaries/implementation-summary-{DATE}.md` (NEW)

**Verification**:
- [ ] All success criteria met (see below)

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` returns 0
- [ ] `grep -c "axiom" Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` returns 0
- [ ] TruthLemma compiles when using CoherentBundle.toBMCS
- [ ] diamond_boxcontent_consistent proof follows research-002.md sketch
- [ ] modal_backward in toBMCS does not reference singleFamily_modal_backward_axiom

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Main implementation
- `specs/844_redesign_metalogic_precoherent_bundle_construction/plans/implementation-002.md` - This plan
- `specs/844_redesign_metalogic_precoherent_bundle_construction/summaries/implementation-summary-{DATE}.md` - Final summary

## Rollback/Contingency

If implementation encounters fundamental blockers:
1. Document the specific failure point and mathematical reason
2. Keep Construction.lean with axiom-based approach as fallback
3. The axiom is mathematically justified (canonical model metatheory)
4. Completeness theorems remain valid with documented axiom

The existing `singleFamily_modal_backward_axiom` approach is sound - this work aims to eliminate it for cleaner formalization, not correctness.

## Lessons from Previous Approach

### What Failed (implementation-001.md)

The Pre-Coherent Bundle approach relied on the false claim:
> "If Box phi is in one S-bounded family f at time t, then phi is in ALL S-bounded families at time t."

This is FALSE because:
1. **S-boundedness** restricts WHICH formulas Box can contain (intra-family property)
2. **Box-coherence** requires AGREEMENT on formula truth across families (inter-family property)
3. These properties are ORTHOGONAL - the first does not imply the second

### Key Insight for This Approach

**Any "product of all families satisfying local property P" approach will fail** because local properties cannot force global agreement. The bundle construction must BUILD agreement into the construction process, not hope it emerges.

The Coherent Witness Chain approach addresses this by:
1. Constructing witnesses that are coherent BY DESIGN
2. Including BoxContent in the witness seed
3. Using the provable consistency of Diamond + BoxContent

## Success Criteria

- [ ] Zero sorries in CoherentConstruction.lean
- [ ] Zero new axioms introduced
- [ ] TruthLemma compiles without modification when using CoherentBundle
- [ ] modal_backward proved without singleFamily_modal_backward_axiom
- [ ] `lake build` succeeds for full project
- [ ] diamond_boxcontent_consistent proven (not sorry'd)
