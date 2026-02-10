# Implementation Plan: Task #843 (v008)

- **Task**: 843 - Remove singleFamily_modal_backward_axiom
- **Status**: [IMPLEMENTING]
- **Effort**: 50-65 hours
- **Dependencies**: None (Phase 4 already completed)
- **Research Inputs**: research-017.md (architectural redesign analysis), research-016.md (16-round synthesis)
- **Artifacts**: plans/implementation-008.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Language**: lean

## Overview

This plan revises v007 to use **Alternative A: Unified Interleaved Chain** from research-017.md. The key insight is that the two-chain architecture (forward from 0, backward from 0) fundamentally cannot support cross-sign G/H propagation. The interleaved chain builds MCS in order M_0, M_1, M_{-1}, M_2, M_{-2}, ... with bidirectional content inclusion at each step.

### What Changed from v007

| Aspect | v007 | v008 |
|--------|------|------|
| Phase 1 approach | Patch two-chain architecture | Replace with interleaved chain |
| Chain construction | Two separate Nat-indexed chains | Single Int-indexed interleaved chain |
| Cross-sign strategy | Hope shared base suffices (it doesn't) | Include bidirectional content at each step |
| Risk level | BLOCKED (architectural limitation) | MEDIUM-HIGH (new construction, subtle proofs) |
| Effort estimate | 12-15 hours (Phase 1 alone) | 15-20 hours (Phase 1 with new architecture) |

### Why Two-Chain Failed

The v007 Phase 1 was blocked because:
1. Forward chain propagates GContent going positive (0 → 1 → 2 → ...)
2. Backward chain propagates HContent going negative (0 → -1 → -2 → ...)
3. G formulas in the backward chain do NOT propagate toward the shared base
4. Sharing the base MCS is insufficient - the chains are constructed with one-directional Lindenbaum extension

### Interleaved Chain Solution

The interleaved chain builds MCS in dovetailing order: M_0, M_1, M_{-1}, M_2, M_{-2}, ...

At each step n (constructing M_t):
- Include GContent(M_{t-1}) if t-1 already constructed
- Include HContent(M_{t+1}) if t+1 already constructed
- Include F-witnesses and P-witnesses via dovetailing enumeration

This ensures G formulas from any constructed MCS propagate forward to later times, even across the 0-boundary.

## Goals & Non-Goals

**Goals**:
- Replace two-chain with unified interleaved chain construction
- Resolve all 4 temporal sorries (cross-sign G/H, F/P witnesses)
- Make `temporal_coherent_family_exists` sorry-free
- Keep Phase 4 completion (FALSE axiom replaced with CORRECT one)
- Preserve Phases 2-5 from v007 (unchanged)
- All proofs compile with `lake build` at each phase boundary

**Non-Goals**:
- Refactoring existing same-sign propagation proofs (reuse where possible)
- Module hierarchy restructuring
- Task 865 (canonical task frame bridge)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Interleaved construction complexity | High | Medium | Start with clear construction order; prove invariants incrementally |
| Chicken-and-egg dependencies | Medium | Medium | Dovetailing order ensures dependencies are always satisfied |
| Lindenbaum consistency for seeds | Medium | Low | GContent union HContent from existing MCS is consistent (same argument as single-direction) |
| Integration with existing proofs | Low | Low | Reuse same-sign lemmas; only cross-sign cases need new proofs |

## Sorry Characterization

### Pre-existing Sorries (to be resolved)
4 sorries in `DovetailingChain.lean`:
1. `forward_G` cross-sign case (t < 0 < t') - BLOCKED in v007
2. `backward_H` cross-sign case (t' < 0 < t) - BLOCKED in v007
3. `forward_F` (dovetailing enumeration) - NOT STARTED
4. `backward_P` (dovetailing enumeration) - NOT STARTED

### Expected Resolution
- Phase 1 resolves ALL 4 sorries via unified interleaved chain construction

### New Sorries
- None expected. Interleaved construction is standard; each step has clear mathematical grounding.

## Axiom Characterization

### Current State (after v007 Phase 4)
- `singleFamily_modal_backward_axiom` - DEPRECATED (FALSE)
- `fully_saturated_bmcs_exists` - IN USE (CORRECT, unproven)
- `temporal_coherent_family_exists` - theorem with 4 transitive sorries

### Expected Resolution
- Phase 1: Eliminate 4 sorries → `temporal_coherent_family_exists` becomes fully proven
- Phase 5 (long-term): Prove `fully_saturated_bmcs_exists` → zero axioms

## Implementation Phases

### Phase 1: Unified Interleaved Chain Construction [PARTIAL]

**Goal:** Replace the two-chain architecture with a unified interleaved chain that supports cross-sign temporal propagation.

**Architecture:**
```
Construction order: M_0, M_1, M_{-1}, M_2, M_{-2}, M_3, M_{-3}, ...

At step n (constructing M_t where t = dovetail_decode(n)):
  seed_t = base_context (if t=0)
         ∪ GContent(M_{t-1})  (if t-1 already constructed)
         ∪ HContent(M_{t+1})  (if t+1 already constructed)
         ∪ F-witness formulas  (from dovetailing enumeration)
         ∪ P-witness formulas  (from dovetailing enumeration)

  M_t = Lindenbaum(seed_t)
```

**Key Lemmas:**

1. **Seed consistency**: `seed_t` is consistent
   - Proof: GContent(M_{t-1}) and HContent(M_{t+1}) are both consistent subsets of MCS
   - Their union is consistent by K-axiom arguments (same as single-direction case)

2. **Forward G propagation**: G phi in M_t → phi in M_{t'} for t < t'
   - If t < 0 < t' (cross-sign): M_0's seed includes GContent(M_{t}), so G phi in M_0. Then same-sign forward propagation gives phi in M_{t'}.
   - Key insight: By construction order, M_0 is built first, and M_{-1} is built after M_1. When M_{-1} is built, we DON'T need its G-content in M_0 - we need M_0's G-content (built from base) to propagate forward.

3. **Backward H propagation**: H phi in M_t → phi in M_{t'} for t' < t
   - Symmetric argument using HContent inclusion

4. **F-witness completeness**: For all (t, F(psi)), if F(psi) in M_t, eventually some M_{t'} (t' > t) contains psi
   - Proof: Dovetailing enumeration ensures every (time, formula) pair is processed

5. **P-witness completeness**: Symmetric for P formulas

**Tasks:**
- [x] Define `dovetailIndex : Nat → Int` mapping construction step to time index
  - `dovetailIndex 0 = 0`
  - `dovetailIndex (2k+1) = k+1` (positive times)
  - `dovetailIndex (2k+2) = -(k+1)` (negative times)
- [x] Define `dovetailRank : Int → Nat` inverse function
- [SORRY] Prove `dovetailRank_dovetailIndex`: inverse property (computationally verified)
- [SORRY] Prove `dovetailIndex_dovetailRank`: inverse property (computationally verified)
- [SORRY] Prove `dovetail_neighbor_constructed`: neighbor availability property
- [ ] Define `interleavedChainSeed` incorporating bidirectional content
  - Takes current time t and already-constructed MCS map
  - Returns seed set including GContent/HContent from neighbors
- [ ] Prove `interleavedChainSeed_consistent`: seed is always consistent
- [ ] Define `interleavedChainMCS : Nat → MCS` using Nat.rec with seed construction
- [ ] Define `interleavedChainFamily : Int → MCS` via dovetailIndex
- [ ] Prove `interleaved_forward_G`: G phi in M_t → phi in M_{t'} for t < t' (BOTH same-sign and cross-sign)
- [ ] Prove `interleaved_backward_H`: H phi in M_t → phi in M_{t'} for t' < t (BOTH same-sign and cross-sign)
- [ ] Implement dovetailing enumeration for F-witnesses using `Nat.pair`/`Nat.unpair`
- [ ] Implement dovetailing enumeration for P-witnesses
- [ ] Prove F/P completeness
- [ ] Verify `temporal_coherent_family_exists` compiles without sorry or axiom

**Progress Notes (2026-02-10):**
- Added dovetailing infrastructure to DovetailingChain.lean
- Updated module documentation to describe interleaved chain approach
- Inverse property proofs are computationally verified but full proofs require careful Int coercion handling
- Original 4 temporal sorries remain (cross-sign G/H, F/P witnesses)
- Total sorries in file: 7 (3 new arithmetic + 4 original temporal)

**Timing:** 15-20 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` (major rewrite)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (update to use new construction)

**Verification:**
- `lake build` succeeds
- `#print axioms temporal_coherent_family_exists` shows only Lean builtins

**Dependencies:** None

---

### Phase 2: BoxContent Accessibility Symmetry [NOT STARTED]

**Goal:** Prove that BoxContent inclusion is symmetric: if `BoxContent(M) ⊆ M'`, then `BoxContent(M') ⊆ M`.

**Proof Sketch (from research-016 Section 5.3):**
1. Assume BoxContent(M) ⊆ M' and Box chi in M' (goal: chi in M)
2. Suppose chi ∉ M (for contradiction)
3. Then neg(chi) in M (MCS maximality)
4. By modal_b: `neg(chi) → Box(Diamond(neg(chi)))`, so `Box(Diamond(neg(chi)))` in M
5. `Diamond(neg(chi))` is in BoxContent(M)
6. Since BoxContent(M) ⊆ M': `Diamond(neg(chi))` in M'
7. `Diamond(neg(chi)) = neg(Box(neg(neg(chi))))`
8. By DNE in MCS: `Box(chi)` in M' iff `Box(neg(neg(chi)))` in M'
9. We have both `Box(chi)` in M' (assumption) and `neg(Box(neg(neg(chi))))` in M'
10. By modal congruence on DNE: contradiction
11. Therefore chi in M

**Tasks:**
- [ ] Define `BoxContentAt : Set Formula → Set Formula` for bare MCS
  - `BoxContentAt M := { chi | Formula.box chi ∈ M }`
- [ ] Prove helper: MCS contains DNE equivalences (`chi ∈ M ↔ neg(neg(chi)) ∈ M`)
- [ ] Prove helper: Box congruence in MCS (`Box chi ∈ M ↔ Box (neg(neg(chi))) ∈ M`)
- [ ] Prove `boxcontent_accessibility_symmetric`:
  - `SetMaximalConsistent M → SetMaximalConsistent M' → BoxContentAt M ⊆ M' → BoxContentAt M' ⊆ M`
- [ ] Prove corollary: accessibility relation is symmetric

**Timing:** 6-10 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/Bundle/S5Properties.lean` (NEW)

**Verification:**
- `lake build` succeeds
- `boxcontent_accessibility_symmetric` type-checks without sorry

**Dependencies:** None (independent of Phase 1)

---

### Phase 3: Generalized Diamond-BoxContent Consistency [NOT STARTED]

**Goal:** Prove `diamond_boxcontent_consistent_mcs` for bare MCS without requiring IndexedMCSFamily wrapper.

**Tasks:**
- [ ] Prove `diamond_boxcontent_consistent_mcs`:
  - For any MCS M with `Diamond(psi) ∈ M`, the set `{psi} ∪ BoxContentAt(M)` is consistent
  - Proof: K-distribution argument at single time point (same as existing lemma)
- [ ] Prove Lindenbaum corollary: extension exists with psi and BoxContent(M) preserved
- [ ] Verify the lemma works without `IsConstantFamily` constraint

**Timing:** 3-5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/S5Properties.lean` (extend)
- OR `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`

**Verification:**
- `lake build` succeeds
- Lemma usable with bare `Set Formula` MCS

**Dependencies:** None (independent of Phases 1-2)

---

### Phase 4: Replace FALSE Axiom with CORRECT Axiom [COMPLETED]

**Status:** Already completed in v007.

The FALSE `singleFamily_modal_backward_axiom` has been replaced with the CORRECT `fully_saturated_bmcs_exists` axiom. Completeness chain now depends on mathematically sound axiom.

---

### Phase 5: Prove the Correct Axiom (Long-term) [NOT STARTED]

**Goal:** Transform the correct axiom into a proven theorem via full canonical model construction.

**Strategy (from research-016 Section 7.3):**
1. Define the canonical accessibility relation: R(M, M') := BoxContent(M) ⊆ M'
2. Prove R is reflexive (T-axiom), transitive (4-axiom), symmetric (Phase 2)
3. Prove R is universal (single equivalence class) using S5 structure
4. Define families as time-shifted temporal chains from all MCS
5. Prove modal_forward from universal accessibility
6. Prove modal_backward from saturated_modal_backward + full saturation
7. Prove temporal coherence from interleaved construction (Phase 1)

**Tasks:**
- [ ] Prove canonical accessibility is an equivalence relation
- [ ] Prove canonical accessibility is universal (all MCS in one class)
- [ ] Construct BMCS from canonical model
- [ ] Prove modal_forward from universality
- [ ] Prove full saturation using generalized diamond consistency (Phase 3)
- [ ] Prove temporal coherence using interleaved chain (Phase 1)
- [ ] Replace axiom declaration with theorem

**Timing:** 20-30 hours (high variance)

**Files to create:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBMCS.lean` (NEW)

**Verification:**
- `lake build` succeeds
- `#print axioms bmcs_strong_completeness` shows ONLY Lean builtins
- `fully_saturated_bmcs_exists` is now a theorem, not an axiom

**Dependencies:** Phases 1-4

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] Phase 1: `#print axioms temporal_coherent_family_exists` shows only Lean builtins
- [ ] Phase 2: `boxcontent_accessibility_symmetric` compiles without sorry
- [ ] Phase 3: `diamond_boxcontent_consistent_mcs` works for bare MCS
- [ ] Phase 4: Already verified (COMPLETED)
- [ ] Phase 5: `#print axioms bmcs_strong_completeness` shows only Lean builtins
- [ ] No new sorry declarations in any phase
- [ ] `bmcs_truth_lemma` remains unchanged and sorry-free

## Artifacts & Outputs

- `plans/implementation-008.md` (this file)
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` (MAJOR REWRITE, Phase 1)
- `Theories/Bimodal/Metalogic/Bundle/S5Properties.lean` (NEW, Phases 2-3)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBMCS.lean` (NEW, Phase 5)
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

**If Phase 1 interleaved construction proves too complex:**
- Fall back to Alternative C (deferral) from research-017
- Accept 4 sorries as documented technical debt
- Phase 4 (critical goal) is already complete

**If seed consistency proof is blocked:**
- May need additional lemmas about GContent/HContent independence
- Can use axiom temporarily if needed, then resolve in Phase 5

**If Phase 5 proves too large:**
- Phases 1-4 provide substantial value: sorry-free temporal coherence + correct axiom
- Phase 5 can be a separate follow-up task

## Phase Priority

1. **Phase 1 (Priority 1)**: Interleaved chain - eliminates temporal sorries
2. **Phases 2-3 (Priority 2)**: BoxContent symmetry - enables Phase 5
3. **Phase 5 (Priority 3)**: Full axiom elimination - long-term goal

Phase 4 is already COMPLETED from v007.
