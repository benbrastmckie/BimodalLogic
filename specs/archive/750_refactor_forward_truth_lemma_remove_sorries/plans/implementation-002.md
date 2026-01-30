# Implementation Plan: Task #750

- **Task**: 750 - refactor_forward_truth_lemma_remove_sorries
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Priority**: High
- **Dependencies**: None (builds on existing sorry-free Algebraic infrastructure)
- **Research Inputs**: specs/750_refactor_forward_truth_lemma_remove_sorries/reports/research-005.md, research-006.md, research-007.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements Option B (Algebraic Bridge) from research-005.md to achieve sorry-free completeness by connecting the existing sorry-free algebraic representation theorem to standard Kripke semantics. The approach creates `AlgebraicSemanticBridge.lean` that constructs TaskModel from ultrafilters and proves the semantic truth lemma. This is more elegant and maintainable than fixing the 20+ sorries in the Representation path, and leverages existing sorry-free infrastructure in `Algebraic/`.

### Research Integration

**Integrated from research-005.md**:
- Three completeness paths exist: Algebraic (sorry-free), Representation (20+ sorries), FMP (1 sorry)
- Algebraic path already proves `AlgSatisfiable phi <-> AlgConsistent phi` without sorries
- Option B (Algebraic Bridge) is recommended as best long-term investment
- Concrete roadmap provided: Documentation (1-2 days), Bridge (2-4 weeks), FMP Independence (1-2 weeks), Archival (1 day)

**Integrated from research-006.md**:
- The semantic gap is well-understood: ultrafilters are "propositional" but encode temporal structure via G_quot/H_quot operators
- The bijection MCS <-> Ultrafilter preserves logical structure
- Bridge requires constructing TaskModel from ultrafilter membership

**Integrated from research-007.md**:
- Task 749 (FMP path) is independent and complementary
- Both tasks can proceed in parallel without conflict
- This plan does not affect task 749's approach

## Goals & Non-Goals

**Goals**:
- Remove all sorries from the completeness proof path by using the algebraic bridge
- Create `AlgebraicSemanticBridge.lean` connecting ultrafilters to TaskModel
- Prove `algebraic_completeness : valid phi -> derivable [] phi` via the algebraic path
- Document the Two-Pillar Architecture (Algebraic + FMP) in Metalogic/README.md
- Clean up dead code in TruthLemma.lean (backward direction, box cases)
- Maintain backward compatibility: existing APIs continue to work

**Non-Goals**:
- Fixing the Representation path sorries (CoherentConstruction, TaskRelation, etc.)
- Modifying the FMP path (task 749 handles that independently)
- Proving the compositionality sorry (mathematically false for unbounded durations)
- Creating new axioms or changing the proof calculus

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Ultrafilter-to-TaskModel construction is harder than expected | High | Medium | Start with simpler propositional cases; can fall back to partial bridge |
| Time domain construction from ultrafilters is non-trivial | High | Medium | Use indexed time (Z) with ultrafilter membership determining accessibility |
| Breaking existing imports during refactor | Medium | Low | Run `lake build` after each phase; preserve original files until bridge proven |
| Bridge proof requires MCS properties not yet proven | Medium | Low | `UltrafilterMCS.lean` already provides MCS <-> Ultrafilter bijection |

## Implementation Phases

### Phase 1: Documentation and Dead Code Removal [NOT STARTED]

**Goal**: Document current architecture, mark sorry criticality, remove unused backward Truth Lemma code

**Tasks**:
- [ ] Create/update `Theories/Bimodal/Metalogic/README.md` with Three-Path Architecture section
- [ ] Document which sorries block which theorems in README
- [ ] Add sorry criticality comments in CoherentConstruction.lean, TaskRelation.lean, UniversalCanonicalModel.lean
- [ ] Identify and document unused backward direction proofs in TruthLemma.lean
- [ ] Remove or comment out backward direction cases (atom_backward, imp_backward, box_backward, etc.)
- [ ] Remove unused box forward/backward cases (architectural limitation - box quantifies over ALL histories)
- [ ] Run `lake build` to verify no regressions

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md` - create/update architecture documentation
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - remove dead code
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` - add criticality comments
- `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean` - add criticality comments
- `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean` - add criticality comments

**Verification**:
- `lake build` succeeds
- README documents all three paths with sorry counts
- Dead code removed from TruthLemma.lean

---

### Phase 2: Algebraic Semantic Bridge - Type Infrastructure [NOT STARTED]

**Goal**: Create core type definitions for bridging ultrafilters to semantic models

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean`
- [ ] Import necessary modules: LindenbaumQuotient, UltrafilterMCS, TaskFrame, TaskModel
- [ ] Define `AlgTaskFrame` structure that wraps ultrafilter data with temporal accessibility
- [ ] Define `ultrafilterWorld : Ultrafilter LindenbaumAlg -> Type` (world states from ultrafilter)
- [ ] Define temporal accessibility relations using G_quot/H_quot membership
- [ ] Define `taskRelation` on ultrafilter worlds using box_quot membership
- [ ] Verify type definitions compile without sorries

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean` - create new file
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` - add import

**Verification**:
- New file compiles
- Type definitions are well-founded
- No new sorries introduced

---

### Phase 3: Algebraic Semantic Bridge - Model Construction [NOT STARTED]

**Goal**: Construct TaskModel from ultrafilter and prove basic properties

**Tasks**:
- [ ] Define `ultrafilterToTaskFrame : Ultrafilter LindenbaumAlg -> TaskFrame Z`
- [ ] Prove frame axioms hold (reflexivity, transitivity as needed)
- [ ] Define `ultrafilterToValuation : Ultrafilter LindenbaumAlg -> (PropVar -> Set UltrafilterWorld)`
- [ ] Define `ultrafilterToTaskModel : Ultrafilter LindenbaumAlg -> TaskModel`
- [ ] Prove basic model properties: valuation coherence with ultrafilter membership
- [ ] Define `ultrafilterHistory : Ultrafilter LindenbaumAlg -> WorldHistory`

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean` - extend with model construction

**Verification**:
- `ultrafilterToTaskModel` compiles
- Frame axioms proven (may need to use existing lemmas from Algebraic/)
- `lake build` succeeds

---

### Phase 4: Algebraic Semantic Truth Lemma [NOT STARTED]

**Goal**: Prove the key bridge theorem: algebraic truth equals semantic truth

**Tasks**:
- [ ] State `algebraic_semantic_truth_lemma`:
  ```lean
  theorem algebraic_semantic_truth_lemma (U : AlgWorld) (phi : Formula) :
      algTrueAt U phi <-> truth_at (ultrafilterToTaskModel U) (ultrafilterHistory U) 0 phi
  ```
- [ ] Prove by induction on formula structure
- [ ] Handle atom case: use valuation definition
- [ ] Handle bot case: trivial
- [ ] Handle imp case: use ultrafilter filter properties
- [ ] Handle box case: use taskRelation definition and box_quot properties
- [ ] Handle G case: use G_quot properties and temporal accessibility
- [ ] Handle H case: use H_quot properties and temporal accessibility

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean` - add truth lemma

**Verification**:
- Truth lemma proven without sorries
- All formula cases covered
- Induction is well-founded

---

### Phase 5: Algebraic Completeness and Integration [NOT STARTED]

**Goal**: Prove completeness via algebraic path and integrate with existing infrastructure

**Tasks**:
- [ ] State `algebraic_completeness`:
  ```lean
  theorem algebraic_completeness (phi : Formula) : valid phi -> derivation [] phi
  ```
- [ ] Prove using:
  - Contrapositive: assume `not (derivation [] phi)`
  - By `AlgConsistent phi.neg` (negation is consistent)
  - By `algebraic_representation_theorem`, exists `U : AlgWorld` with `algTrueAt U phi.neg`
  - By `algebraic_semantic_truth_lemma`, `truth_at (ultrafilterToTaskModel U) ... phi.neg`
  - This contradicts `valid phi`
- [ ] Add `algebraic_completeness` to exports in Algebraic.lean
- [ ] Add cross-reference comments pointing to FMP path
- [ ] Update Metalogic/README.md with completed algebraic completeness

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean` - add completeness theorem
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` - update exports
- `Theories/Bimodal/Metalogic/README.md` - document completion

**Verification**:
- `algebraic_completeness` proven without sorries
- Full `lake build` succeeds
- README accurately reflects sorry-free status

---

### Phase 6: Final Cleanup and Archival Preparation [NOT STARTED]

**Goal**: Clean up code, add cross-references, prepare Representation/ for future archival

**Tasks**:
- [ ] Add cross-reference comment in `FMP/SemanticCanonicalModel.lean` pointing to algebraic path
- [ ] Mark Representation/ files as "LEGACY - superseded by Algebraic path" in headers
- [ ] Update `Theories/Bimodal/Metalogic/Metalogic.lean` to highlight Two-Pillar imports
- [ ] Create archival checklist in README.md for when Representation/ can be moved to Boneyard
- [ ] Run full `lake build` and verify no warnings
- [ ] Document any remaining sorries with justification (e.g., soundness axiomatization)

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - add cross-reference
- `Theories/Bimodal/Metalogic/Representation/*.lean` - add legacy notices
- `Theories/Bimodal/Metalogic/Metalogic.lean` - update imports
- `Theories/Bimodal/Metalogic/README.md` - add archival checklist

**Verification**:
- Full `lake build` passes
- Cross-references are accurate
- README documents clear path to archival

## Testing & Validation

- [ ] `lake build` passes with no new errors after each phase
- [ ] No sorries in AlgebraicSemanticBridge.lean when complete
- [ ] `algebraic_representation_theorem` still compiles (Algebraic path intact)
- [ ] `algebraic_completeness` compiles without sorries
- [ ] `semantic_weak_completeness` still compiles (FMP path unaffected)
- [ ] All imports resolve correctly
- [ ] README.md accurately reflects the codebase state

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean` - new file with bridge theorem
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - refactored, dead code removed
- `Theories/Bimodal/Metalogic/README.md` - updated with Two-Pillar documentation
- `specs/750_refactor_forward_truth_lemma_remove_sorries/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If the algebraic bridge proves infeasible within the time estimate:

**Fallback Option A**: Partial Bridge
1. Complete Phases 1-3 (documentation + type infrastructure)
2. Leave truth lemma with sorries marked as "future work"
3. Document the approach for future completion
4. This still provides: dead code removal, architecture documentation, foundation for future work

**Fallback Option B**: Documentation-Only
1. Complete only Phase 1
2. Keep TruthLemma.lean as-is with documented sorries
3. Document the Three-Path Architecture without code changes
4. Document the sorries as "intentional architectural limitations"

**Rollback Procedure**:
1. Git revert to pre-phase state
2. Files are preserved in git history
3. Research and plan remain valid for future attempt

## Notes

**Why Option B over Option A (Fixing Representation)**:
- Algebraic path is already sorry-free; we leverage existing work
- Representation path has 20+ sorries in complex files
- Algebraic approach is more mathematically elegant
- Creates cleaner long-term architecture

**Relationship to Task 749**:
- Task 749 (FMP path) is independent and can proceed in parallel
- Both tasks contribute to the Two-Pillar Architecture
- No conflicts or dependencies between tasks
