# Implementation Plan: Task #750

- **Task**: 750 - refactor_forward_truth_lemma_remove_sorries
- **Status**: [NOT STARTED]
- **Effort**: 8-10 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: research-008.md (Option 5 analysis)
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements **Option 5: Hybrid Approach** from research-008.md. Instead of building a semantic truth lemma for arbitrary ultrafilter states (which failed in v003), we use the ultrafilter purely as a **consistency witness** to seed the existing sorry-free FMP construction.

### Key Insight

The algebraic path proves `¬⊢ phi → AlgSatisfiable phi.neg` (ultrafilter exists). The FMP path proves `¬⊢ phi → countermodel exists`. The hybrid approach connects these:

```
¬⊢ phi
  → AlgConsistent phi.neg           (definition)
  → AlgSatisfiable phi.neg          (algebraic_representation_theorem, SORRY-FREE)
  → ultrafilter U with phi.neg ∈ U  (by construction)
  → MCS Γ = ultrafilterToSet U      (existing infrastructure)
  → phi.neg ∈ Γ, phi ∉ Γ           (MCS properties)
  → Γ ∩ closure(phi) is closure MCS (existing: mcs_projection_is_closure_mcs)
  → FMP countermodel construction   (existing: semantic_weak_completeness structure)
  → ⊢ phi by contradiction         (GOAL)
```

This bypasses the need for a semantic truth lemma entirely - we don't need to prove `algTrueAt U phi ↔ truth_at model ...`.

### Why This Works

1. **No semantic bridge needed**: We don't try to equate ultrafilter truth with Kripke truth
2. **Uses proven infrastructure**: Both `algebraic_representation_theorem` and `semantic_weak_completeness` are sorry-free
3. **MCS is the key**: The ultrafilter-to-MCS map (`ultrafilterToSet`) provides the connection
4. **Existing FMP machinery**: The MCS projection and world state construction already exist

### Revision Notes (v004)

**Changes from v003**:
- Abandoned algebraic-semantic bridge approach (failed - box requires global ultrafilter reasoning)
- New strategy: ultrafilter as consistency witness, not semantic model
- Reuses existing FMP infrastructure instead of building parallel construction
- Significantly reduced scope - proving one connecting theorem instead of full truth lemma

## Goals & Non-Goals

**Goals**:
- Prove `hybrid_completeness : valid phi → ⊢ phi` without sorries
- Connect algebraic consistency to FMP construction via MCS
- Keep existing AlgebraicSemanticBridge.lean infrastructure (may be useful later)

**Non-Goals**:
- Proving semantic truth lemma for ultrafilter states (this is what failed)
- Removing sorries from TruthLemma.lean (different approach, different task)
- Building new model constructions

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ultrafilterToSet_mcs has sorries | High | Low | Check if sorries are on critical path; may need to fill them |
| MCS projection lemma needs work | Medium | Medium | Existing mcs_projection_is_closure_mcs should suffice |
| Type mismatches between modules | Medium | Medium | Use explicit type conversions; align definitions |

## Implementation Phases

### Phase 1: Audit Existing Infrastructure [COMPLETED]

**Goal**: Verify all required lemmas exist and identify any sorries on the critical path

**Tasks**:
- [ ] Verify `algebraic_representation_theorem` is sorry-free
- [ ] Check sorries in `UltrafilterMCS.lean` - are any on our path?
- [ ] Verify `mcs_projection_is_closure_mcs` exists and its dependencies
- [ ] Check `semantic_weak_completeness` structure for reuse
- [ ] Document any gaps that need filling

**Files to examine**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicRepresentation.lean`
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean`
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`

**Timing**: 2 hours

**Verification**:
- Create document listing all lemmas on critical path with sorry status
- Identify minimum work needed

---

### Phase 2: Fill Critical UltrafilterMCS Sorries [SKIPPED]

**Goal**: Fill any sorries in UltrafilterMCS.lean that block `ultrafilterToSet_mcs`

**Tasks**:
- [ ] Identify which sorries are needed for `ultrafilterToSet_mcs`
- [ ] Fill `ultrafilterToSet_consistent` if needed
- [ ] Fill `ultrafilterToSet_complete` if needed
- [ ] Fill any helper lemmas required
- [ ] Run `lake build` to verify

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean`

**Timing**: 3 hours

**Verification**:
- `ultrafilterToSet_mcs` compiles without sorries
- `lake build` passes

**Skip Condition**: If Phase 1 shows these are already sorry-free, skip to Phase 3.

---

### Phase 3: Create Hybrid Completeness Module [COMPLETED]

**Goal**: Create the connecting theorem in a new file

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/HybridCompleteness.lean`
- [ ] Import: AlgebraicRepresentation, UltrafilterMCS, SemanticCanonicalModel
- [ ] Define `alg_consistent_to_mcs`:
  ```lean
  theorem alg_consistent_to_mcs (phi : Formula) (h : AlgConsistent phi) :
      ∃ Γ : Set Formula, SetMCS Γ ∧ phi ∈ Γ
  ```
- [ ] Prove using `algebraic_representation_theorem` + `ultrafilterToSet`
- [ ] Verify this compiles without sorries

**Files to create**:
- `Theories/Bimodal/Metalogic/Algebraic/HybridCompleteness.lean`

**Timing**: 2 hours

**Verification**:
- New file compiles
- `alg_consistent_to_mcs` proven without sorries

---

### Phase 4: Connect to FMP Path [COMPLETED]

**Goal**: Use the MCS from Phase 3 to feed into FMP construction for completeness

**Tasks**:
- [ ] In HybridCompleteness.lean, add:
  ```lean
  noncomputable def hybrid_weak_completeness (phi : Formula) :
      valid phi → ⊢ phi
  ```
- [ ] Proof structure:
  1. Assume valid phi, suppose ¬⊢ phi
  2. By AlgConsistent phi.neg (not provable means consistent)
  3. By alg_consistent_to_mcs, get MCS Γ with phi.neg ∈ Γ
  4. Project to closure MCS: S = Γ ∩ closure(phi)
  5. Build SemanticWorldState from S (reuse FMP machinery)
  6. phi.neg ∈ S, so phi false at this world state
  7. Contradiction with valid phi
- [ ] Run `lake build` to verify

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/HybridCompleteness.lean`
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` (add import)

**Timing**: 3 hours

**Verification**:
- `hybrid_weak_completeness` proven without sorries
- Full `lake build` succeeds

---

### Phase 5: Documentation and Cleanup [COMPLETED]

**Goal**: Document the result and update module exports

**Precondition**: Phase 4 completes successfully without sorries

**Tasks**:
- [ ] Add module docstring to HybridCompleteness.lean explaining the approach
- [ ] Update Algebraic/README.md to document the new completeness path
- [ ] Create implementation summary

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/HybridCompleteness.lean` (docstring)
- `Theories/Bimodal/Metalogic/Algebraic/README.md`

**Timing**: 30 minutes

**Verification**:
- Documentation accurately describes what was achieved
- Module structure is clear

**Skip Condition**: If any prior phase has sorries, document partial progress instead.

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] No new sorries introduced in HybridCompleteness.lean at Phase 4 completion
- [ ] `hybrid_weak_completeness` compiles and is sorry-free
- [ ] Existing code (algebraic_representation_theorem, semantic_weak_completeness) unaffected

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/HybridCompleteness.lean` - new file
- `specs/750_refactor_forward_truth_lemma_remove_sorries/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If the hybrid approach proves infeasible:

**Fallback**: Partial Connection
1. Document what lemmas ARE provable
2. Keep any infrastructure that compiles
3. Mark gaps with clear TODO comments

**Rollback**:
1. Git revert to pre-phase state
2. Keep AlgebraicSemanticBridge.lean from v003 (may be useful for future approaches)

## Notes

**Why Option 5 differs from Option 3 (FMP Path)**:
- Option 3 tries to bridge `valid phi` → `semantic_truth_at_v2` directly
- Option 5 uses algebraic consistency as an intermediate step
- The ultrafilter provides a "certified" MCS without needing semantic reasoning

**Relationship to other tasks**:
- Task 749 (FMP path) attempts Option 3 directly
- Task 753 (CoherentConstruction) works on the Representation path
- This approach is independent and provides an alternative if both get stuck

**Why this might succeed where v003 failed**:
- v003 tried to prove: ultrafilter membership ↔ semantic truth (hard - requires global reasoning)
- v004 proves: ultrafilter membership → MCS membership → FMP construction (easier - local properties)
