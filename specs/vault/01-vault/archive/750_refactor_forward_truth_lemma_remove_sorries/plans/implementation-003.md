# Implementation Plan: Task #750

- **Task**: 750 - refactor_forward_truth_lemma_remove_sorries
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/750_refactor_forward_truth_lemma_remove_sorries/reports/research-005.md
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan achieves sorry-free completeness by building an algebraic semantic bridge that connects the existing sorry-free algebraic representation theorem to standard Kripke semantics. The focus is on **concrete technical results first**; documentation updates happen only after sorry-free proofs are complete.

The algebraic path (`Algebraic/AlgebraicRepresentation.lean`) already proves `AlgSatisfiable phi <-> AlgConsistent phi` without sorries. We leverage this by constructing a TaskModel from ultrafilter membership and proving a truth lemma that bridges algebraic and semantic truth.

### Revision Notes (v003)

**Changes from v002**:
- Removed Phase 1 (Documentation and Dead Code Removal) - defer until results are complete
- Removed premature documentation tasks from all phases
- Removed "Two-Pillar Architecture" framing - focus on achievable independence
- Removed archival preparation - not needed until sorry-free completeness achieved
- Moved documentation to final phase, conditioned on success
- Reduced total effort from 16h to 12h

**Guiding Principle**: Prove sorry-free results first. Document after.

## Goals & Non-Goals

**Goals**:
- Create `AlgebraicSemanticBridge.lean` connecting ultrafilters to TaskModel
- Prove `algebraic_semantic_truth_lemma` without sorries
- Prove `algebraic_completeness : valid phi -> derivation [] phi` without sorries
- Update documentation **only after** sorry-free completeness is achieved

**Non-Goals**:
- Imposing a specific architecture on the metalogic
- Removing or refactoring code that isn't blocking progress
- Writing documentation before results are proven
- Archiving or deprecating working code

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Ultrafilter-to-TaskModel construction fails | High | Medium | Can fall back to partial results; document what was learned |
| Time domain construction is non-trivial | High | Medium | Use indexed time (Z) with ultrafilter membership determining accessibility |
| Truth lemma cases harder than expected | Medium | Medium | Complete easier cases first; mark hard cases for future work if needed |

## Implementation Phases

### Phase 1: Type Infrastructure [COMPLETED]

**Goal**: Create core type definitions for bridging ultrafilters to semantic models

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean`
- [ ] Import: LindenbaumQuotient, UltrafilterMCS, TaskFrame, TaskModel
- [ ] Define `AlgTaskFrame` structure wrapping ultrafilter data with temporal accessibility
- [ ] Define `ultrafilterWorld : Ultrafilter LindenbaumAlg -> Type`
- [ ] Define temporal accessibility using G_quot/H_quot membership
- [ ] Define `taskRelation` on ultrafilter worlds using box_quot membership
- [ ] Verify all definitions compile without sorries

**Timing**: 3 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` - add import

**Verification**:
- New file compiles
- Type definitions are well-founded
- No sorries introduced

---

### Phase 2: Model Construction [COMPLETED]

**Goal**: Construct TaskModel from ultrafilter and prove basic properties

**Tasks**:
- [ ] Define `ultrafilterToTaskFrame : Ultrafilter LindenbaumAlg -> TaskFrame Z`
- [ ] Prove frame axioms (reflexivity, transitivity as needed)
- [ ] Define `ultrafilterToValuation : Ultrafilter LindenbaumAlg -> (PropVar -> Set UltrafilterWorld)`
- [ ] Define `ultrafilterToTaskModel : Ultrafilter LindenbaumAlg -> TaskModel`
- [ ] Prove valuation coherence with ultrafilter membership
- [ ] Define `ultrafilterHistory : Ultrafilter LindenbaumAlg -> WorldHistory`

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean`

**Verification**:
- `ultrafilterToTaskModel` compiles
- Frame axioms proven
- `lake build` succeeds

---

### Phase 3: Semantic Truth Lemma [PARTIAL]

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
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean`

**Verification**:
- Truth lemma proven without sorries
- All formula cases covered
- Induction is well-founded

---

### Phase 4: Completeness Theorem [NOT STARTED]

**Goal**: Prove sorry-free completeness via algebraic path

**Tasks**:
- [ ] State `algebraic_completeness`:
  ```lean
  theorem algebraic_completeness (phi : Formula) : valid phi -> derivation [] phi
  ```
- [ ] Prove using contrapositive:
  - Assume `not (derivation [] phi)`
  - By `AlgConsistent phi.neg` (negation is consistent)
  - By `algebraic_representation_theorem`, exists `U : AlgWorld` with `algTrueAt U phi.neg`
  - By `algebraic_semantic_truth_lemma`, `truth_at (ultrafilterToTaskModel U) ... phi.neg`
  - This contradicts `valid phi`
- [ ] Add `algebraic_completeness` to exports in Algebraic.lean
- [ ] Run full `lake build` to verify

**Timing**: 1 hour (assuming earlier phases complete)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean`
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` - update exports

**Verification**:
- `algebraic_completeness` proven without sorries
- Full `lake build` succeeds

---

### Phase 5: Documentation (Conditional) [NOT STARTED]

**Goal**: Document results **only if** Phases 1-4 complete successfully without sorries

**Precondition**: `algebraic_completeness` is proven without sorries

**Tasks**:
- [ ] Update `Theories/Bimodal/Metalogic/README.md` with new algebraic completeness path
- [ ] Add brief cross-reference in `AlgebraicSemanticBridge.lean` header
- [ ] Note independence from Representation path (factual, not architectural mandate)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md`
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean` - header only

**Verification**:
- Documentation accurately reflects achieved results
- No architectural claims beyond what was proven

**Skip Condition**: If any Phase 1-4 remains incomplete or has sorries, skip this phase entirely. The code speaks for itself.

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] No sorries in `AlgebraicSemanticBridge.lean` at Phase 4 completion
- [ ] `algebraic_completeness` compiles and is sorry-free
- [ ] Existing `algebraic_representation_theorem` still works
- [ ] FMP path (`semantic_weak_completeness`) unaffected

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean` - new file
- `specs/750_refactor_forward_truth_lemma_remove_sorries/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If the algebraic bridge proves infeasible:

**Fallback**: Partial Results
1. Keep whatever compiles from Phases 1-3
2. Mark incomplete cases with `sorry` and clear TODO comments
3. Document what was learned in implementation summary
4. Leave as foundation for future work

**Rollback**:
1. Git revert to pre-phase state
2. Research and prior plans remain valid

## Notes

**Why start with code, not documentation**:
- Documentation without results creates confusion
- The code is the primary record of what's proven
- Documentation is only valuable when describing achieved results

**Relationship to other tasks**:
- Task 749 (FMP path) proceeds independently
- Task 753 (Representation sorries) is an alternative approach
- Success here provides one sorry-free path; others may exist
