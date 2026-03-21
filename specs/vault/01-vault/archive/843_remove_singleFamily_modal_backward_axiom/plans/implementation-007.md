# Implementation Plan: Task #843 (v007)

- **Task**: 843 - Remove singleFamily_modal_backward_axiom
- **Status**: [PARTIAL]
- **Effort**: 45-60 hours
- **Dependencies**: None (Phase 1 already completed)
- **Research Inputs**: research-016.md (comprehensive 16-round synthesis), research-015.md (S5 insights, later falsified), implementation-summary-20260205.md (Phase 2 falsification discovery)
- **Artifacts**: plans/implementation-007.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Language**: lean

## Overview

This plan eliminates the FALSE `singleFamily_modal_backward_axiom` using the **BoxContent accessibility symmetry** insight from research-016. The key finding is that while S5 Box invariance (Box phi in M implies Box phi in M' for arbitrary MCS) is FALSE, the weaker **BoxContent symmetry** (BoxContent(M) subset M' implies BoxContent(M') subset M) IS provable and provides the foundation for a correct axiom replacement.

### Critical Discovery: S5 Box Invariance is FALSE

Plan v006 Phase 2 attempted to prove S5 Box invariance. During implementation, a counterexample was discovered:
- For `phi = atom "p"`, `Box(atom "p")` is neither provable nor refutable
- Some MCS contain `Box(atom "p")`, others contain `neg(Box(atom "p"))`
- Therefore Box invariance fails for arbitrary MCS

This invalidates the entire Phase 2-6 strategy of plan v006.

### New Strategy: BoxContent Accessibility Symmetry

Research-016 Section 5.3 establishes that BoxContent accessibility symmetry IS provable:
- If `BoxContent(M) subset M'` (M R M' in canonical model), then `BoxContent(M') subset M`
- Proof uses modal_b + classical logic in MCS (detailed in research-016)
- This provides "one-hop transfer" between accessibility-related MCS

### What Changed from v006

| Aspect | v006 | v007 |
|--------|------|------|
| Modal approach | S5 Box invariance (FALSE) | BoxContent symmetry + correct axiom |
| Phase 2 goal | Prove Box invariance | Prove BoxContent symmetry |
| Axiom status | Eliminate entirely | Replace FALSE with CORRECT, then prove |
| modal_forward strategy | Trivial via Box invariance | Via full canonical model construction |
| Risk level | HIGH (unknown mathematical validity) | MEDIUM (mathematically established) |

### Completeness Dependency Graph (Current)

```
bmcs_strong_completeness (sorry-free)
  -> bmcs_context_representation (sorry-free)
    -> construct_temporal_bmcs
      -> singleFamilyBMCS
        -> singleFamily_modal_backward_axiom  <- AXIOM (FALSE)
      -> temporal_coherent_family_exists      <- theorem (sorry-backed from v006 Phase 1)
    -> bmcs_truth_lemma (sorry-free)
```

### Target Dependency Graph (Short-term)

```
bmcs_strong_completeness (sorry-free, one CORRECT axiom)
  -> bmcs_context_representation (sorry-free)
    -> construct_saturated_bmcs
      -> fully_saturated_bmcs_exists          <- NEW AXIOM (CORRECT, unproven)
      -> saturated_modal_backward (PROVEN)    <- ENABLES modal_backward
    -> bmcs_truth_lemma (sorry-free, unchanged)
```

### Target Dependency Graph (Long-term)

```
bmcs_strong_completeness (sorry-free, axiom-free)
  -> bmcs_context_representation (sorry-free, axiom-free)
    -> construct_canonical_bmcs
      -> boxcontent_symmetry (PROVEN)         <- KEY ENABLING LEMMA
      -> canonical_accessibility_universal    <- Via S5 equivalence relation
      -> canonical_bmcs_fully_saturated       <- Via diamond witness construction
    -> bmcs_truth_lemma (sorry-free, unchanged)
```

## Goals & Non-Goals

**Goals**:
- Replace the mathematically FALSE `singleFamily_modal_backward_axiom` with a mathematically CORRECT axiom
- Prove BoxContent accessibility symmetry as a key enabling lemma
- Resolve remaining temporal dovetailing sorries (4 from Phase 1 of v006)
- Generalize diamond_boxcontent_consistent to work with bare MCS
- Prepare infrastructure for proving the correct axiom (long-term goal)
- All proofs compile with `lake build` at each phase boundary

**Non-Goals**:
- Full axiom elimination in this plan (moved to Phase 5 as optional)
- Removing orphaned axioms in dead code paths
- Task 865 (canonical task frame bridge)
- Module hierarchy restructuring

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| BoxContent symmetry proof complexity | Medium | Low | Proof sketch verified in research-016 using modal_b + MCS properties |
| Temporal dovetailing sorries | Low | Low | Cross-sign case well-understood; dovetailing enumeration uses Mathlib infrastructure |
| Correct axiom formulation | Low | Low | Standard canonical model theory guarantees the axiom is true |
| Integration with existing completeness chain | Low | Low | Minimal changes - just swap axiom reference |

## Sorry Characterization

### Pre-existing Sorries (from v006 Phase 1)
4 sorries in `DovetailingChain.lean`:
1. `forward_G` cross-sign case (t < 0 < t')
2. `backward_H` cross-sign case (t' < 0 < t)
3. `forward_F` (dovetailing enumeration)
4. `backward_P` (dovetailing enumeration)

### Expected Resolution
- Phase 1 resolves these 4 sorries using unified chain and Encodable enumeration

### New Sorries
- None expected. Each phase has clear mathematical grounding.

## Axiom Characterization

### Pre-existing Axioms
- `singleFamily_modal_backward_axiom` in `Construction.lean:210` (FALSE)
- `temporal_coherent_family_exists` in `TemporalCoherentConstruction.lean:578` (now sorry-backed theorem)

### Expected Resolution (Short-term: Phases 1-4)
- Phase 1: Eliminate 4 sorries, making temporal_coherent_family_exists fully proven
- Phase 4: Replace FALSE axiom with CORRECT axiom

### Expected Resolution (Long-term: Phase 5)
- Phase 5: Prove the correct axiom, achieving zero axioms

## Implementation Phases

### Phase 1: Complete Temporal Dovetailing Sorries [PARTIAL]

**Goal:** Resolve the 4 remaining sorries in DovetailingChain.lean from v006 Phase 1.

**Progress:**
- [x] Unified shared base MCS construction (chains_share_base lemma)
  - Both forward and backward chains now share a single MCS at index 0
  - This is a prerequisite for cross-sign propagation but not sufficient alone
- [ ] Resolve `forward_G` cross-sign case (BLOCKED - requires full interleaved chain)
  - Current two-chain architecture cannot support cross-sign G propagation
  - Would require restructuring to interleaved chain construction
- [ ] Resolve `backward_H` cross-sign case (BLOCKED - symmetric to above)
- [ ] Implement dovetailing enumeration for `forward_F` (NOT STARTED)
  - Use `Nat.pair`/`Nat.unpair` with `Encodable Formula`
  - At each step n, process the formula with code `n mod enum_bound` at time `n / enum_bound`
  - Prove completeness: every (formula, time) pair is eventually processed
- [ ] Resolve `backward_P` symmetrically (NOT STARTED)
- [ ] Verify `temporal_coherent_family_exists` compiles without sorry or axiom (BLOCKED by above)

**Analysis:**
The cross-sign cases require fundamental architectural changes beyond what can be achieved
by sharing the base MCS. The current two-chain construction (forward Nat chain + backward
Nat chain meeting at shared base) is structurally incapable of cross-sign temporal propagation
because:
1. Forward chain propagates GContent going positive (0 -> 1 -> 2 -> ...)
2. Backward chain propagates HContent going negative (0 -> -1 -> -2 -> ...)
3. G formulas in the backward chain do not propagate toward the shared base

Per rollback contingency: accept sorry markers at cross-sign cases as non-blocking for the
modal axiom goal (Phase 4 is complete).

**Tasks:**
- [ ] Resolve `forward_G` cross-sign case using unified bidirectional chain
  - At junction point 0, include TemporalContent from both positive and negative neighbors
  - Prove G-propagation across the 0-boundary via transitive chain of inclusions
- [ ] Resolve `backward_H` cross-sign case symmetrically
- [ ] Implement dovetailing enumeration for `forward_F`
  - Use `Nat.pair`/`Nat.unpair` with `Encodable Formula`
  - At each step n, process the formula with code `n mod enum_bound` at time `n / enum_bound`
  - Prove completeness: every (formula, time) pair is eventually processed
- [ ] Resolve `backward_P` symmetrically
- [ ] Verify `temporal_coherent_family_exists` compiles without sorry or axiom

**Timing:** 12-15 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`

**Verification:**
- `lake build` succeeds
- `#print axioms temporal_coherent_family_exists` shows only Lean builtins

**Dependencies:** None

---

### Phase 2: BoxContent Accessibility Symmetry [NOT STARTED]

**Goal:** Prove that BoxContent inclusion is symmetric: if `BoxContent(M) subset M'`, then `BoxContent(M') subset M`.

**Proof Sketch (from research-016 Section 5.3):**
1. Assume BoxContent(M) subset M' and Box chi in M' (goal: chi in M)
2. Suppose chi not in M (for contradiction)
3. Then neg(chi) in M (MCS maximality)
4. By modal_b: `neg(chi) -> Box(Diamond(neg(chi)))`, so `Box(Diamond(neg(chi)))` in M
5. `Diamond(neg(chi))` is in BoxContent(M)
6. Since BoxContent(M) subset M': `Diamond(neg(chi))` in M'
7. `Diamond(neg(chi)) = neg(Box(neg(neg(chi))))`
8. By DNE in MCS: `Box(chi)` in M' iff `Box(neg(neg(chi)))` in M'
9. We have both `Box(chi)` in M' (assumption) and `neg(Box(neg(neg(chi))))` in M'
10. By modal congruence on DNE: contradiction
11. Therefore chi in M

**Tasks:**
- [ ] Define `BoxContentAt : Set Formula -> Set Formula` for bare MCS
  - `BoxContentAt M := { chi | Formula.box chi in M }`
- [ ] Prove helper: MCS contains DNE equivalences (`chi in M iff neg(neg(chi)) in M`)
- [ ] Prove helper: Box congruence in MCS (`Box chi in M iff Box (neg(neg(chi))) in M`)
- [ ] Prove `boxcontent_accessibility_symmetric`:
  - `SetMaximalConsistent M -> SetMaximalConsistent M' -> BoxContentAt M subset M' -> BoxContentAt M' subset M`
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
  - For any MCS M with `Diamond(psi)` in M, the set `{psi} union BoxContentAt(M)` is consistent
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

**Goal:** Replace the mathematically FALSE `singleFamily_modal_backward_axiom` with a mathematically CORRECT axiom asserting the existence of a fully saturated BMCS.

**New Axiom:**
```lean
axiom fully_saturated_bmcs_exists (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (B : BMCS D),
      (∀ gamma in Gamma, gamma in B.eval_family.mcs 0) ∧
      B.temporally_coherent ∧
      is_modally_saturated B
```

**Why this axiom is CORRECT:**
- Standard canonical model theory for S5 modal + temporal logic guarantees such a BMCS exists
- The canonical model construction (all MCS as worlds, BoxContent-defined accessibility) produces this
- This is the statement that `saturated_modal_backward` (PROVEN) uses

**Tasks:**
- [ ] Define `fully_saturated_bmcs_exists` axiom in appropriate module
- [ ] Define `is_modally_saturated` predicate if not already present
- [ ] Rewire `Completeness.lean` to use new axiom instead of `singleFamily_modal_backward_axiom`
  - Update `construct_temporal_bmcs` or create `construct_saturated_bmcs`
  - Ensure `saturated_modal_backward` is used for modal_backward
- [ ] Comment out the old FALSE axiom (preserve for reference)
- [ ] Verify `#print axioms bmcs_strong_completeness` shows new axiom instead of old

**Timing:** 4-6 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` (new axiom, comment old)
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` (rewire)

**Verification:**
- `lake build` succeeds
- `#print axioms bmcs_strong_completeness` shows `fully_saturated_bmcs_exists` (CORRECT)
- Old FALSE axiom no longer in dependency chain

**Dependencies:** None (can be done independently of Phases 1-3)

---

### Phase 5: Prove the Correct Axiom (Long-term) [NOT STARTED]

**Goal:** Transform the correct axiom into a proven theorem via full canonical model construction.

**Strategy (from research-016 Section 7.3):**
1. Define the canonical accessibility relation: R(M, M') := BoxContent(M) subset M'
2. Prove R is reflexive (T-axiom), transitive (4-axiom), symmetric (Phase 2)
3. Prove R is universal (single equivalence class) using S5 structure
4. Define families as time-shifted temporal chains from all MCS
5. Prove modal_forward from universal accessibility
6. Prove modal_backward from saturated_modal_backward + full saturation
7. Prove temporal coherence from dovetailing construction

**Tasks:**
- [ ] Prove canonical accessibility is an equivalence relation
- [ ] Prove canonical accessibility is universal (all MCS in one class)
- [ ] Construct BMCS from canonical model
- [ ] Prove modal_forward from universality
- [ ] Prove full saturation using generalized diamond consistency (Phase 3)
- [ ] Prove temporal coherence using dovetailing (Phase 1)
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
- [ ] Phase 4: `#print axioms bmcs_strong_completeness` shows CORRECT axiom, not FALSE one
- [ ] Phase 5: `#print axioms bmcs_strong_completeness` shows only Lean builtins
- [ ] No new sorry declarations in any phase
- [ ] `bmcs_truth_lemma` remains unchanged and sorry-free

## Artifacts & Outputs

- `plans/implementation-007.md` (this file)
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` (MODIFIED, Phase 1)
- `Theories/Bimodal/Metalogic/Bundle/S5Properties.lean` (NEW, Phases 2-3)
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` (MODIFIED, Phase 4)
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` (MODIFIED, Phase 4)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBMCS.lean` (NEW, Phase 5)
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

**If Phase 1 cross-sign proof is blocked:**
- Use a global Zorn argument over coherent extensions
- Or accept sorry markers at cross-sign cases (non-blocking for modal axiom goal)

**If Phase 2 BoxContent symmetry is more complex than expected:**
- The proof sketch is verified; may just require more helper lemmas
- Can proceed to Phase 4 (axiom replacement) independently

**If Phase 4 integration fails:**
- The new axiom formulation may need adjustment
- Can iterate on the precise statement while preserving the core idea

**If Phase 5 proves too large:**
- Phases 1-4 provide substantial value: FALSE axiom replaced with CORRECT one
- Phase 5 can be a separate follow-up task

## Priority Sequence

Research-016 recommends this priority order:

1. **Priority 1 (Immediate): Phase 4** - Replace FALSE axiom with CORRECT one for mathematical soundness
2. **Priority 2 (Near-term): Phase 1** - Complete temporal sorries for clean temporal construction
3. **Priority 3 (Medium-term): Phases 2-3** - Enable full canonical model approach
4. **Priority 4 (Long-term): Phase 5** - Full axiom elimination

However, for cleaner implementation, the phases are numbered in logical dependency order.
