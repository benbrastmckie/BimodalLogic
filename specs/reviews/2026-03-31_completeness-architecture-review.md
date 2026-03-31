# TM Completeness Architecture Review

**Date**: 2026-03-31
**Scope**: Representation theorem gaps, sorry inventory, task audit

---

## Executive Summary

The TM completeness architecture has **57 actual sorry tactics** across 13 files (excluding Boneyard and examples). The critical path has **27 completeness-blocking sorries** concentrated in:
- UltrafilterChain.lean (25 sorries) - temporal coherence construction
- SuccChainFMCS.lean (4 sorries) - seed consistency proofs
- FrameConditions/Completeness.lean (2 sorries) - top-level completeness
- RestrictedTruthLemma.lean (2 sorries) - chain G/H propagation

The core blocker remains **temporal coherence for F/P witnesses**: constructing a BFMCS where F(phi) at time t guarantees phi exists at some s >= t within the same family.

---

## 1. Sorry Inventory

### 1.1 Publication-Path Sorries (27 total)

These block the representation theorem "TM complete wrt TaskFrames over totally ordered abelian groups":

| File | Count | Category | Lines |
|------|-------|----------|-------|
| UltrafilterChain.lean | 25 | Temporal coherence | 3377, 3383, 3887, 4301, 4721, 4767, 5251, 5273, 5287, 5352, 5369, 6487, 6510, 6551, 7426, 7448, 8047, 8050, 8062, 8064, 8123, 8139, 8374 |
| SuccChainFMCS.lean | 4 | Seed consistency | 1734, 1763, 2082, 5736 |
| Completeness.lean | 2 | Top-level wiring | 134, 237 |
| RestrictedTruthLemma.lean | 2 | Chain propagation | 116, 158 |
| SuccChainTruth.lean | 1 | Singleton-Omega gap | 311 |
| CanonicalConstruction.lean | 2 | FMCS forward/backward | 889, 893 |

### 1.2 Frame-Specific Soundness Sorries (5)

In `Soundness.lean` lines 572, 576, 579, 582, 602:
- `density`: GGpsi -> Gpsi (requires DenselyOrdered D)
- `discreteness_forward`: (Ftop /\ phi /\ Hphi) -> F(Hphi) (requires SuccOrder D)
- `seriality_future`: Gpsi -> Fpsi (requires NoMaxOrder D)
- `seriality_past`: Hpsi -> Ppsi (requires NoMinOrder D)
- `temporal_duality`: swap soundness (requires frame constraints)

### 1.3 FMP Sorries (2)

In `TruthPreservation.lean` lines 263, 281:
- `mcs_all_future_closure`: Under strict semantics, Gψ -> ψ is NOT valid
- `mcs_all_past_closure`: Under strict semantics, Hψ -> ψ is NOT valid

These are **deprecated** as they rely on reflexive temporal semantics.

### 1.4 Example/Pedagogical Sorries (13)

- ModalProofs.lean: 5 sorries (exercise proofs)
- ModalProofStrategies.lean: 5 sorries (demonstration)
- TemporalProofs.lean: 2 sorries (exercise proofs)
- Demo.lean: 1 sorry (pedagogical)

These are **expected** and not on the critical path.

### 1.5 Sorry Classification Summary

| Category | Count | Status |
|----------|-------|--------|
| F/P witness temporal coherence | ~18 | BLOCKED (fundamental) |
| G/H chain propagation | ~5 | BLOCKED (structural) |
| Seed consistency proofs | 4 | Task #78 (researched) |
| Top-level wiring | 2 | Task #58 (researched) |
| Frame-specific soundness | 5 | Task #59 (not started) |
| FMP strict temporal | 2 | Task #998 (researching) |
| Examples/pedagogical | 13 | Expected |

---

## 2. Task Audit

### 2.1 Valid Tasks (Current Approach Still Correct)

| Task | Status | Assessment |
|------|--------|------------|
| **#57** | RESEARCHED | Valid - cleanup work, parallelizable |
| **#59** | NOT STARTED | Valid - frame-specific soundness, parallelizable |
| **#68** | RESEARCHED | Valid - Rat canonical model for dense completeness |
| **#74-76** | NOT STARTED | Valid - strict temporal research track |
| **#78** | RESEARCHED | Valid - seed consistency sorries (spawned from #73) |
| **#79** | RESEARCHED | Valid - termination artifact sorries (spawned from #73) |
| **#992** | RESEARCHED | Valid - STSA reorganization, non-blocking |
| **#998** | RESEARCHING | Valid - FMP redesign for strict semantics |

### 2.2 Tasks Needing Revision

| Task | Status | Issue | Recommendation |
|------|--------|-------|----------------|
| **#58** | RESEARCHED | Description understates blocker. Real blocker is `bfmcs_from_mcs_temporally_coherent` which depends on 25 UltrafilterChain sorries, not just "wiring". | Update description to reflect that this is BLOCKED on temporal coherence, not just wiring. The plan assumes temporal coherence exists. |
| **#8** | RESEARCHED | Research is accurate but completion requires resolving the F/P witness blocker which no existing task addresses. | Keep as reference. Mark dependency on F/P resolution. |
| **#21** | PLANNED | Tech debt cleanup depends on tasks 18 and 15, but task 18 is BLOCKED indefinitely. | Remove dependency on 18. Scope to non-dependent cleanup. |
| **#18** | BLOCKED | Dense representation blocked on DenseTask framework which requires F/P witnesses. The blocker chain is infinite. | Consider abandoning or reframing as "exploration only" until F/P is resolved via FMP path. |

### 2.3 Tasks to Consider Abandoning

| Task | Status | Reason | Recommendation |
|------|--------|--------|----------------|
| **#61** | NOT STARTED | "Eliminate BFMCS bundles entirely" - already marked experimental. The BFMCS architecture is necessary for modal completeness (Box backward requires multiple families). | Mark [ABANDONED]. The bundle structure is mathematically necessary. |
| **#19** | NOT STARTED | "Deprecate old discrete pipeline" - low priority, and discrete completeness is now achieved via Int reduction. | Defer indefinitely or abandon. |
| **#20** | NOT STARTED | "Audit parametric canonical" - depends on task 18 which is blocked. | Defer until F/P resolution or abandon. |

---

## 3. Gap Analysis

### 3.1 The Core Blocker: F/P Temporal Coherence

**Current state**: The algebraic path through `ParametricRepresentation` is sorry-free BUT conditional on `construct_bfmcs` providing a `B.temporally_coherent` BFMCS. This callback requires:

```
forward_F: F(phi) at t implies exists s >= t with phi at s (within same family)
backward_P: P(phi) at t implies exists s <= t with phi at s (within same family)
```

**Why it's hard**: Lindenbaum extension from a seed doesn't guarantee F-obligations resolve. The extension can add `G(neg phi)` when consistent with the seed, killing the F(phi) witness.

**ROADMAP states**: "Class A sorries (DNE-solvable)" are "small effort" but this is **misleading**. The Class A sorries (lines 2359, 3011) were identified in the OLD SuccChain approach which was **abandoned**. The current approach (omega chain, Z_chain, CoherentZChain) has different sorries.

### 3.2 Missing Tasks

1. **Task for UltrafilterChain temporal coherence cleanup**: The 25 sorries in UltrafilterChain.lean span multiple abandoned approaches:
   - Old SuccChain (f_nesting_is_bounded - FALSE)
   - Bidirectional seed (H(a) -> G(H(a)) - NOT derivable)
   - Z_chain (cross-chain propagation - structural gap)
   - CoherentZChain (same gaps)

   **Recommendation**: Create a new task to audit and remove dead code from UltrafilterChain.lean. Much of this file is archived dead ends.

2. **Task for Class A sorry resolution**: The ROADMAP claims "small effort" for modal duality via DNE. No task exists for this. However, the relevant sorries (2359, 3011) are in the deprecated SuccChain code, not the current path.

3. **Task for deciding canonical model vs FMP path**: The architecture has two paths:
   - Canonical model: Representation theorem (blocked on F/P)
   - FMP: Decidability + finite model property (task #998)

   No task explicitly documents the trade-off or decision point.

### 3.3 What Blocks the Representation Theorem?

The goal: "TM complete wrt TaskFrames over totally ordered abelian groups"

The blocker chain:
```
representation_theorem
  <- completeness_over_Int (sorry at line 237)
  <- bfmcs_from_mcs_temporally_coherent (sorry at line 237)
  <- Z_chain_forward_F / Z_chain_backward_P (sorries throughout UltrafilterChain)
  <- omega_forward_F_bounded_persistence (sorry at line 6510)
  <- fair scheduling doesn't force F-resolution
  <- Lindenbaum extension can add G(neg phi) killing F(phi) witness
```

### 3.4 Is FMP the Only Viable Path?

**Yes, for decidability and practical completeness.**

The FMP path (#998) can establish:
- TM has the finite model property
- TM is decidable
- For any consistent formula, there exists a finite countermodel

**No, for the representation theorem.**

FMP/filtration does NOT provide:
- A characterization of the frame class
- The statement "TM = logic of TaskFrames over totally ordered abelian groups"

The ROADMAP acknowledges this: "FMP/filtration techniques can prove decidability or finite model property, but do not provide this characterization."

---

## 4. Recommended Next Steps

### Immediate (Quick Wins)

1. **Execute #78 and #79**: Resolve the 6 spawned sorries from Class A analysis. Effort: 2-4 hours.

2. **Execute #57**: Clean up UltrafilterChain.lean. Remove ~430 lines of dead code. Effort: 1-2 hours.

3. **Execute #59**: Frame-specific soundness axioms. 5 sorries, straightforward. Effort: 3-5 hours.

### Short-Term (Stabilization)

4. **Revise #58**: Update description to accurately reflect that it's BLOCKED on temporal coherence, not just "wiring". The current plan assumes temporal coherence exists.

5. **Create audit task for UltrafilterChain dead code**: Many of the 25 sorries are in abandoned approaches (SuccChain, bidirectional seed). A cleanup task would reduce cognitive load.

6. **Mark #61 ABANDONED**: The bundle structure is mathematically necessary for modal completeness.

### Medium-Term (Path Decision)

7. **Complete #998 (FMP redesign)**: This is the most viable path to decidability and "weak completeness" (every consistent formula has a finite model).

8. **Decision point on representation theorem**: After #998 completes, decide whether to:
   - Accept FMP as "completeness enough" for practical purposes
   - Continue canonical model research for representation theorem (long-term, speculative)

### Research Track (Parallel)

9. **Execute #74-76**: Strict temporal semantics research. This may provide insights into the F/P blocker.

---

## 5. Technical Debt Summary

| Item | Sorries | Tasks | Status |
|------|---------|-------|--------|
| Temporal coherence (F/P) | ~18 | None directly | Fundamental blocker |
| Chain G/H propagation | ~5 | #78, #79 | Researched |
| Top-level completeness | 2 | #58 | Blocked on temporal |
| Frame-specific soundness | 5 | #59 | Not started |
| FMP strict temporal | 2 | #998 | Researching |
| RestrictedTruthLemma | 2 | None | Low priority |
| Examples | 13 | #949 | Expected/cosmetic |
| Dead code in UltrafilterChain | N/A | None | Needs new task |

**Custom Axioms**: 1 (`discrete_Icc_finite_axiom`) - Task #60

**Total completeness-blocking sorries**: 27 (excluding examples)

---

## Appendix: Complete Sorry Listing by File

```
Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean (25):
  3377, 3383: f_preserving_seed_consistent sub-cases (DEAD CODE)
  3887: G_of_bidirectional_seed H_theory case (BLOCKED: H(a)->G(H(a)) not derivable)
  4301: bidirectional_seed_consistent H_theory case (BLOCKED)
  4721: boxClassFamilies_temporally_coherent (BLOCKED: removed SuccChainTemporalCoherent)
  4767: construct_bfmcs (DEPRECATED/DEAD CODE)
  5251, 5273: Z_chain_forward_G cross-chain cases (structural gap)
  5287: Z_chain_backward_H (structural gap)
  5352, 5369: Z_chain_forward_F, Z_chain_backward_P (omega chain doesn't force resolution)
  6481, 6487: omega_chain_forward_F_step (G(neg phi) gap)
  6510: omega_forward_F_bounded_persistence (dovetailed construction needed)
  6551: Z_chain_forward_F' t<0 case (cross-chain)
  7426, 7448: p_preserving_seed_consistent complex cases
  8047, 8050, 8062, 8064: CoherentZChain_FMCS forward_G cross-chain cases
  8123, 8139: CoherentZChain_forward_F/backward_P (Phase 6B gaps)
  8374: (additional case)

Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean (4):
  1734: g_content_union_brs_consistent
  1763: augmented_seed_consistent
  2082: constrained_successor_seed_restricted_consistent
  5736: comment reference only

Theories/Bimodal/FrameConditions/Completeness.lean (2):
  134: dense_completeness_fc (Int not dense)
  237: bfmcs_from_mcs_temporally_coherent

Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean (2):
  116: restricted_chain_G_step (G-propagation for DRM)
  158: restricted_chain_H_step (H-propagation for DRM)

Theories/Bimodal/Metalogic/Soundness.lean (5):
  572: density axiom (DenselyOrdered)
  576: discreteness_forward (SuccOrder)
  579: seriality_future (NoMaxOrder)
  582: seriality_past (NoMinOrder)
  602: temporal_duality

Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean (2):
  889, 893: FMCS forward_G/backward_H

Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean (2):
  263: mcs_all_future_closure (strict semantics)
  281: mcs_all_past_closure (strict semantics)

Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean (1):
  311: singleton-Omega modal backward gap
```
