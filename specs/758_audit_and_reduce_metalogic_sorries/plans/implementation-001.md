# Implementation Plan: Audit and Reduce Metalogic Sorries

- **Task**: 758 - Audit and reduce sorry count in Theories/Bimodal/Metalogic/
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Priority**: High
- **Dependencies**: Related to Task 750 (forward Truth Lemma refactor)
- **Research Inputs**: specs/758_audit_and_reduce_metalogic_sorries/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Audit and reduce sorries in Theories/Bimodal/Metalogic/ by: (1) porting the soundness proof from Boneyard, (2) fixing classical propositional logic lemmas, (3) fixing IndexedMCSFamily delegation, (4) archiving exploratory code not worth keeping, and (5) documenting architectural limitations. The main completeness theorem `semantic_weak_completeness` is already sorry-free; this task addresses the soundness direction and secondary paths.

### Research Integration

Research report (research-001.md) identified:
- 28 actual code sorries across 8 files
- Critical sorry: soundness axiom (1 sorry blocking bidirectional metatheory)
- Exploratory sorries: 13 sorries in cross-origin/compositionality code worth archiving
- Architectural limitations: omega-rule prevents backward temporal truth lemma

## Goals & Non-Goals

**Goals**:
- Port soundness proof from Boneyard to main codebase (1 sorry)
- Fix classical propositional logic derivation lemmas (2 sorries)
- Fix IndexedMCSFamily delegation to CoherentConstruction (4 sorries)
- Archive exploratory code not worth keeping to Boneyard
- Document architectural limitations that cannot be fixed
- Reduce total sorry count from 28 to approximately 9

**Non-Goals**:
- Fix architectural limitations requiring omega-rule (impossible)
- Complete cross-origin coherence cases (intentionally out of scope)
- Complete TaskRelation compositionality (not on critical path)
- Rewrite semantic_weak_completeness (already sorry-free)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Boneyard soundness proof needs significant adaptation | H | M | Review SoundnessLemmas.lean first; it already has context soundness |
| IndexedMCSFamily delegation more complex than expected | M | L | May need CoherentConstruction API adjustments |
| Classical logic lemmas need specific derivation tree structure | L | L | Standard natural deduction construction |
| Archive breaks downstream imports | M | L | Search for imports before moving |

## Implementation Phases

### Phase 1: Port Soundness Proof from Boneyard [NOT STARTED]

**Goal**: Eliminate the soundness axiom sorry in WeakCompleteness.lean by porting the proven soundness theorem from Boneyard/Metalogic_v2/Soundness.

**Tasks**:
- [ ] Review Boneyard/Metalogic_v2/Soundness/Soundness.lean and SoundnessLemmas.lean
- [ ] Identify the gap: Boneyard has `soundness_from_empty` but WeakCompleteness needs `soundness` with arbitrary context
- [ ] Extend Boneyard soundness to arbitrary context (add weakening case handling)
- [ ] Move extended soundness proof from Boneyard to Metalogic/Completeness/
- [ ] Update WeakCompleteness.lean to import and use the proven soundness theorem
- [ ] Verify lake build succeeds

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - Remove sorry, import proven soundness
- `Theories/Bimodal/Boneyard/Metalogic_v2/Soundness/Soundness.lean` - Extend to context soundness
- New file or existing: Move soundness to main codebase

**Verification**:
- `lake build Bimodal.Metalogic.Completeness.WeakCompleteness` succeeds
- grep for "sorry" in WeakCompleteness.lean returns 0

---

### Phase 2: Fix Classical Propositional Logic Lemmas [NOT STARTED]

**Goal**: Prove the two classical logic derivation lemmas in AlgebraicSemanticBridge.lean that establish `|-  neg(psi -> chi) -> psi` and `|- neg(psi -> chi) -> neg(chi)`.

**Tasks**:
- [ ] Examine AlgebraicSemanticBridge.lean lines 301, 307 to understand required lemmas
- [ ] Review existing propositional derivation infrastructure in ProofSystem/
- [ ] Construct derivation trees for both tautologies using available axioms
- [ ] Replace sorries with proofs
- [ ] Verify with lake build

**Timing**: 1-1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean` - Lines 301, 307

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.AlgebraicSemanticBridge` succeeds
- grep for "sorry" in those lines returns 0

---

### Phase 3: Fix IndexedMCSFamily Delegation [NOT STARTED]

**Goal**: Fix the 4 sorries in IndexedMCSFamily.lean (lines 620, 626, 632, 638) by properly delegating to CoherentConstruction.

**Tasks**:
- [ ] Examine IndexedMCSFamily.lean to understand what forward_G, backward_H, forward_H, backward_G need
- [ ] Check CoherentConstruction.construct_coherent_family API for available coherence properties
- [ ] Implement delegation from IndexedMCSFamily to CoherentConstruction
- [ ] Replace the 4 sorries with proper calls
- [ ] Verify with lake build

**Timing**: 1-1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - Lines 620-638

**Verification**:
- `lake build Bimodal.Metalogic.Representation.IndexedMCSFamily` succeeds
- IndexedMCSFamily coherence sorries eliminated

---

### Phase 4: Archive Exploratory Code to Boneyard [NOT STARTED]

**Goal**: Move code not worth keeping to Boneyard with clear documentation, reducing sorry count and codebase noise.

**Tasks**:
- [ ] Identify code to archive:
  - CoherentConstruction cross-origin cases (8 sorries) - NOT REQUIRED FOR COMPLETENESS
  - TaskRelation compositionality (5 sorries) - Not on critical path
- [ ] Search for imports of these functions to ensure no breakage
- [ ] Create Boneyard/Metalogic_v3/Archived/ directory if needed
- [ ] Move cross-origin cases and TaskRelation compositionality to Boneyard
- [ ] Add documentation explaining why archived
- [ ] Update imports if any files depend on archived code
- [ ] Verify lake build succeeds

**Timing**: 1.5-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` - Remove cross-origin cases
- `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean` - Remove compositionality
- New: `Theories/Bimodal/Boneyard/Metalogic_v3/Archived/CrossOriginCases.lean`
- New: `Theories/Bimodal/Boneyard/Metalogic_v3/Archived/TaskRelationCompositionality.lean`

**Verification**:
- `lake build` succeeds (full project)
- Archived files have clear documentation
- Sorry count in main Metalogic/ reduced by 13

---

### Phase 5: Document Architectural Limitations [NOT STARTED]

**Goal**: Add clear documentation for sorries that represent architectural limitations and cannot be fixed without fundamental changes.

**Tasks**:
- [ ] Document omega-rule limitation in TruthLemma.lean (backward temporal cases, 2 sorries)
- [ ] Document box cases in TruthLemma.lean (2 sorries) - requires modal architecture change
- [ ] Document SemanticCanonicalModel compositionality axiom (mathematically false for unbounded durations)
- [ ] Add architectural notes explaining why semantic_weak_completeness bypasses these issues
- [ ] Update module docstrings with limitation warnings

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Add limitation documentation
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Add limitation documentation

**Verification**:
- All documented limitations have clear explanation
- Documentation explains why sorry-free completeness still holds

---

## Testing & Validation

- [ ] `lake build` succeeds for full project
- [ ] grep -r "sorry" Theories/Bimodal/Metalogic/ --include="*.lean" | wc -l shows reduction
- [ ] WeakCompleteness.lean soundness theorem proven
- [ ] No imports broken by archiving
- [ ] Documentation added for all remaining sorries

## Artifacts & Outputs

- `specs/758_audit_and_reduce_metalogic_sorries/plans/implementation-001.md` (this file)
- Updated Metalogic files with reduced sorry count
- Archived code in Boneyard with documentation
- Architectural limitation documentation

## Expected Sorry Reduction

| Phase | Sorries Fixed | Sorries Archived | Running Total |
|-------|---------------|------------------|---------------|
| Start | - | - | 28 |
| Phase 1 | 1 | 0 | 27 |
| Phase 2 | 2 | 0 | 25 |
| Phase 3 | 4 | 0 | 21 |
| Phase 4 | 0 | 13 | 8 |
| Phase 5 | 0 (documented) | 0 | 8 |

Final: 8 documented sorries remaining (architectural limitations in TruthLemma, SemanticCanonicalModel, FiniteModelProperty, AlgebraicSemanticBridge temporal cases).

## Rollback/Contingency

- Git commits after each phase enable per-phase rollback
- If Boneyard soundness port fails: keep soundness axiom, document as TODO
- If archiving breaks imports: revert and stub out archived code instead
- If IndexedMCSFamily delegation complex: document as architectural debt
