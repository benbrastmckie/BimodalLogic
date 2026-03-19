# Implementation Plan: Task #995

- **Task**: 995 - fmcs_domain_transfer_lemma
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None (CanonicalFMCS.lean is already sorry-free)
- **Research Inputs**: specs/995_fmcs_domain_transfer_lemma/reports/01_fmcs-domain-transfer.md
- **Artifacts**: plans/01_fmcs-domain-transfer.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Build a general FMCS domain transfer lemma that transfers temporal coherence properties (forward_F, backward_P) from the sorry-free `CanonicalMCS`-based construction to any domain `D` with `AddCommGroup + LinearOrder + IsOrderedAddMonoid`. The key insight is that `CanonicalMCS` has proven forward_F/backward_P for free (each witness MCS is in the domain by construction), and we transfer these properties along an order-embedding/retraction pair rather than proving them directly on the target domain.

### Research Integration

Key findings from the research report:
- **FMCSTransfer structure**: An embedding/retraction pair encapsulates the transfer relationship
- **CanonicalMCS provides sorry-free temporal coherence**: forward_F and backward_P are trivially proven because every MCS is in the domain
- **Transfer vs direct proof**: We transfer properties along embeddings rather than proving them directly on Z/Q chains
- **Challenges**: CanonicalMCS has Preorder (not LinearOrder), retraction must be monotone, witness inclusion requires strict order preservation

## Goals and Non-Goals

**Goals**:
- Define `FMCSTransfer` structure capturing embedding/retraction pair requirements
- Prove `transfer_forward_G`, `transfer_backward_H` (should be straightforward via composition)
- Prove `transfer_forward_F`, `transfer_backward_P` (the main payoff - transfers the sorry-free CanonicalMCS proofs)
- Provide instantiation infrastructure for Int and Rat targets

**Non-Goals**:
- Completing the actual Int/Rat instantiations (separate tasks)
- Modifying existing IntBFMCS.lean or CanonicalEmbedding.lean directly
- Building the dovetailing chain construction (that's a prerequisite for Int instantiation)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Embedding/retraction conditions too strong | High | Medium | Start with minimal conditions, add only what's needed for proofs |
| Order direction confusion (CanonicalMCS Preorder vs target LinearOrder) | Medium | Medium | Carefully document which direction each morphism preserves |
| Witness transfer requires additional constraints | High | Low | The witness comes from canonical_forward_F which gives a CanonicalMCS element directly |
| Type universe issues | Low | Low | Use consistent universe levels following existing infrastructure |

## Implementation Phases

### Phase 1: Define FMCSTransfer Structure [NOT STARTED]

**Goal**: Create the core structure capturing the embedding/retraction pair and compatibility requirements.

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`
- [ ] Import CanonicalFMCS.lean, FMCSDef.lean, and relevant Mathlib Order.Hom modules
- [ ] Define `FMCSTransfer` structure with:
  - `embed : CanonicalMCS ↪o D` (order embedding from CanonicalMCS to D)
  - `retract : D → CanonicalMCS` (retraction function)
  - `retract_left_inverse : ∀ w, retract (embed w) = w`
  - `retract_monotone : ∀ d₁ d₂, d₁ ≤ d₂ → retract d₁ ≤ retract d₂`
- [ ] Add documentation explaining the transfer concept

**Timing**: 1.5 hours

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.FMCSTransfer` succeeds
- Structure definition compiles without errors

---

### Phase 2: Define Transferred FMCS [NOT STARTED]

**Goal**: Define the transferred FMCS structure using the retraction to assign MCSes.

**Tasks**:
- [ ] Define `transferredFMCS : FMCS D` using the FMCSTransfer structure
- [ ] MCS assignment: `mcs d := canonicalMCSBFMCS.mcs (T.retract d)`
- [ ] Prove `is_mcs` from canonicalMCS_is_mcs
- [ ] Prove `forward_G` by composing retract_monotone with canonicalMCS_forward_G
- [ ] Prove `backward_H` by composing retract_monotone with canonicalMCS_backward_H

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`

**Verification**:
- `transferredFMCS` definition compiles
- forward_G and backward_H proofs have no sorries
- `lake build` succeeds

---

### Phase 3: Prove transfer_forward_F [NOT STARTED]

**Goal**: Prove the forward_F property transfers from CanonicalMCS to D.

**Tasks**:
- [ ] State `transfer_forward_F` theorem: F(phi) at d implies witness s > d with phi at s
- [ ] Use `canonicalMCS_forward_F` to get witness `w : CanonicalMCS` with `T.retract d ≤ w`
- [ ] Show `T.embed w` is the witness in D (need d < T.embed w)
- [ ] Key lemma: For w strictly greater than retract d in CanonicalMCS, embed w > d in D
- [ ] Prove phi membership via retract_left_inverse: mcs(embed w) = canonicalMCSBFMCS.mcs(retract(embed w)) = canonicalMCSBFMCS.mcs(w)

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`

**Verification**:
- `transfer_forward_F` proof has no sorries
- `lake build` succeeds

---

### Phase 4: Prove transfer_backward_P [NOT STARTED]

**Goal**: Prove the backward_P property transfers from CanonicalMCS to D.

**Tasks**:
- [ ] State `transfer_backward_P` theorem: P(phi) at d implies witness s < d with phi at s
- [ ] Use `canonicalMCS_backward_P` to get witness `w : CanonicalMCS` with `w ≤ T.retract d`
- [ ] Show `T.embed w` is the witness in D (need T.embed w < d)
- [ ] Key lemma: For w strictly less than retract d in CanonicalMCS, embed w < d in D
- [ ] Prove phi membership via retract_left_inverse (symmetric to forward_F)

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`

**Verification**:
- `transfer_backward_P` proof has no sorries
- `lake build` succeeds

---

### Phase 5: Main Transfer Theorem and Instantiation Infrastructure [NOT STARTED]

**Goal**: Package the transfer into a main theorem and provide infrastructure for Int/Rat instantiation.

**Tasks**:
- [ ] Define `fmcs_domain_transfer` theorem combining all transferred properties
- [ ] Add convenience wrapper `transferredTemporalCoherentFamily`
- [ ] Add module documentation explaining how to instantiate for specific D
- [ ] Add placeholder/stub for Int instantiation (documenting requirements)
- [ ] Add placeholder/stub for Rat instantiation (documenting requirements)
- [ ] Ensure clean API for downstream use by IntBFMCS and CanonicalEmbedding

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`

**Verification**:
- Full module compiles with no sorries in transfer theorems
- Documentation clearly explains instantiation requirements
- `lake build` succeeds

---

### Phase 6: Integration and Testing [NOT STARTED]

**Goal**: Verify integration with existing codebase and document usage patterns.

**Tasks**:
- [ ] Add import to lakefile.lean if needed
- [ ] Verify no conflicts with existing IntBFMCS.lean or CanonicalEmbedding.lean
- [ ] Add test usage example in module docstring showing transfer pattern
- [ ] Update FMCS module structure comments to reference new transfer approach
- [ ] Create summary artifact documenting the transfer lemma

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean` (final polish)
- Potentially `Theories/Bimodal/lakefile.lean` (if import structure changes)

**Verification**:
- Full `lake build` succeeds
- No new sorries introduced
- Transfer infrastructure is documented and usable

---

## Testing and Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.FMCSTransfer` succeeds without errors
- [ ] `lake build` full project succeeds without new sorries
- [ ] transfer_forward_F and transfer_backward_P are sorry-free
- [ ] FMCSTransfer structure is usable with both strict and non-strict order preservation
- [ ] Documentation explains instantiation requirements clearly

## Artifacts and Outputs

- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean` - Main transfer infrastructure
- `specs/995_fmcs_domain_transfer_lemma/summaries/01_fmcs-domain-transfer-summary.md` - Implementation summary

## Rollback/Contingency

If the FMCSTransfer approach proves too restrictive:
1. The existing sorry-based approaches in IntBFMCS.lean and CanonicalEmbedding.lean remain functional
2. Alternative: weaker transfer conditions (e.g., only transfer F/P for specific witness types)
3. Alternative: direct proof approach for Int using enriched dovetailing (bypasses transfer)

## Notes

**Key Technical Insight**: The critical observation is that `canonicalMCS_forward_F` gives a witness `w : CanonicalMCS`, NOT just an MCS. Since w is already in the CanonicalMCS type, we can apply `T.embed w` to get a witness in D. The only requirements are:
1. `embed` preserves strict order (so w > retract d implies embed w > d)
2. `retract_left_inverse` holds (so mcs(embed w) = mcs(w))

This is fundamentally different from the dovetailing approach, which tries to include all witnesses in a chain. Here, we don't need the witnesses in the chain - we just need to be able to map them via the embedding.

**Preorder vs LinearOrder**: CanonicalMCS has Preorder (not LinearOrder). The OrderEmbedding `↪o` works with Preorders on the source. The target D has LinearOrder by TaskFrame requirements. The embedding being order-reflecting means strict inequalities transfer correctly.
