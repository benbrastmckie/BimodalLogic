# Implementation Plan: Task #654

- **Task**: 654 - Research Purely Syntactic Representation Theorem
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/654_research_purely_syntactic_representation_theorem/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Completely refactor the representation theorem to use a purely syntactic canonical frame that properly instantiates TaskFrame. The current implementation uses an ad-hoc CanonicalFrame structure that does not match the TaskFrame definition from semantics, creating a fundamental disconnect between soundness (proven for TaskFrames) and completeness (proven for non-TaskFrame structures). This refactor will archive the incorrect implementation, then build a correct SyntacticCanonicalFrame using MCS worlds with a task relation based on transitive closure of temporal witnesses, satisfying nullity and compositionality axioms syntactically.

### Research Integration

Integrated research-002.md findings:
- Current CanonicalFrame lacks time type parameter and task_rel structure
- SemanticCanonicalFrame has compositionality sorry due to finite time bounds
- Recommended approach: Pure MCS canonical model with unbounded Int time type
- Task relation via transitive closure ensures automatic nullity/compositionality
- Truth lemma must be proven for the syntactic task relation

## Goals & Non-Goals

**Goals**:
- Archive current incorrect CanonicalFrame and related files to Bimodal/Boneyard/
- Define SyntacticCanonicalFrame that properly instantiates TaskFrame Int
- Implement syntactic task_rel based on temporal formula containment
- Prove nullity and compositionality for the syntactic task relation
- Prove truth lemma showing syntactic model matches semantic truth
- Update representation theorem to produce genuine TaskFrame instances

**Non-Goals**:
- Implement finite model property (separate concern, uses filtration)
- Optimize performance of canonical model construction
- Extend to parametric time types beyond Int (future work)
- Prove strong completeness (only weak completeness via representation)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Compositionality proof complex for transitive closure | H | M | Use inductive chain structure; break into base + transitive cases |
| Truth lemma backward direction fails | H | L | Leverage MCS negation-completeness (already proven in MaximalConsistent.lean) |
| Box operator semantics mismatch | M | M | Box quantifies over all histories = all MCS; standard modal logic correspondence |
| Temporal chain consistency hard to define | M | M | Use generated submodel technique from modal logic; define inductively |
| Lost partial work if phase fails | M | L | Git commit each completed phase; mark phases [PARTIAL] on interruption |

## Implementation Phases

### Phase 1: Archive Incorrect Implementation [NOT STARTED]

**Goal**: Move current ad-hoc CanonicalFrame implementation to Boneyard for reference

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/` directory if not exists
- [ ] Move `Metalogic_v2/Representation/CanonicalModel.lean` to Boneyard
- [ ] Move `Metalogic_v2/Representation/SemanticCanonicalModel.lean` to Boneyard
- [ ] Move `Metalogic_v2/Representation/TruthLemma.lean` to Boneyard
- [ ] Update imports in remaining Representation files to remove archived dependencies
- [ ] Verify project builds without errors after archival

**Timing**: 1 hour

**Files to modify**:
- Create: `Theories/Bimodal/Boneyard/CanonicalModel_v1.lean` (archived)
- Create: `Theories/Bimodal/Boneyard/SemanticCanonicalModel_v1.lean` (archived)
- Create: `Theories/Bimodal/Boneyard/TruthLemma_v1.lean` (archived)
- Modify: `Metalogic_v2/Representation/RepresentationTheorem.lean` (remove imports)
- Modify: `Metalogic_v2/Representation/FiniteModelProperty.lean` (remove imports)

**Verification**:
- `lake build` succeeds with no errors
- Archived files accessible in Boneyard for reference

---

### Phase 2: Define Syntactic Task Relation Infrastructure [NOT STARTED]

**Goal**: Create the base syntactic task relation using temporal formula containment

**Tasks**:
- [ ] Create `Metalogic_v2/Representation/SyntacticTaskRelation.lean`
- [ ] Define `temporal_witness_step` for single-step MCS connections
- [ ] Define `TemporalChain` structure for sequences of MCS
- [ ] Implement chain concatenation operation
- [ ] Define `syntactic_task_rel_base` as reflexive-transitive closure
- [ ] Prove basic properties (reflexivity, transitivity)

**Timing**: 2 hours

**Files to modify**:
- Create: `Metalogic_v2/Representation/SyntacticTaskRelation.lean`
- Import in: `Metalogic_v2/Representation.lean` (module aggregator)

**Verification**:
- `syntactic_task_rel_base w 0 w` holds by reflexivity
- `syntactic_task_rel_base w d1 u → syntactic_task_rel_base u d2 v → syntactic_task_rel_base w (d1+d2) v` proven
- File compiles without errors

---

### Phase 3: Implement SyntacticCanonicalFrame [NOT STARTED]

**Goal**: Create TaskFrame instance using syntactic task relation

**Tasks**:
- [ ] Create `Metalogic_v2/Representation/SyntacticCanonicalFrame.lean`
- [ ] Define `SyntacticCanonicalFrame : TaskFrame Int` with MCS as WorldState
- [ ] Implement `nullity` proof using reflexivity of syntactic_task_rel
- [ ] Implement `compositionality` proof using chain concatenation
- [ ] Add helper lemmas for reasoning about MCS temporal properties

**Timing**: 1.5 hours

**Files to modify**:
- Create: `Metalogic_v2/Representation/SyntacticCanonicalFrame.lean`
- Import dependencies: `Semantics/TaskFrame.lean`, `Metalogic_v2/Consistency/MaximalConsistent.lean`

**Verification**:
- `SyntacticCanonicalFrame` compiles as valid `TaskFrame Int` instance
- `lean_diagnostic_messages` shows no errors
- `lean_goal` confirms nullity and compositionality are closed

---

### Phase 4: Define Syntactic Canonical Model [NOT STARTED]

**Goal**: Build TaskModel instance wrapping SyntacticCanonicalFrame

**Tasks**:
- [ ] Create `Metalogic_v2/Representation/SyntacticCanonicalModel.lean`
- [ ] Define `SyntacticCanonicalModel : TaskModel Int` using SyntacticCanonicalFrame
- [ ] Implement valuation function based on MCS atom membership
- [ ] Define domain D as all Int values (unbounded)
- [ ] Add helper functions for accessing frame/model components

**Timing**: 1 hour

**Files to modify**:
- Create: `Metalogic_v2/Representation/SyntacticCanonicalModel.lean`
- Import: `Semantics/TaskModel.lean`, `SyntacticCanonicalFrame.lean`

**Verification**:
- `SyntacticCanonicalModel` type-checks as `TaskModel Int`
- Valuation function compiles
- Can construct model instances for test formulas

---

### Phase 5: Prove Truth Lemma [NOT STARTED]

**Goal**: Show formula membership in MCS corresponds to semantic truth in syntactic model

**Tasks**:
- [ ] Create `Metalogic_v2/Representation/SyntacticTruthLemma.lean`
- [ ] Prove truth lemma forward direction (formula in MCS → semantically true)
- [ ] Prove truth lemma backward direction (semantically true → formula in MCS)
- [ ] Handle special cases: atoms, box operator, temporal operators
- [ ] Leverage MCS negation-completeness for backward direction
- [ ] Add lemmas connecting syntactic_task_rel to semantic truth_at

**Timing**: 2 hours

**Files to modify**:
- Create: `Metalogic_v2/Representation/SyntacticTruthLemma.lean`
- Import: `SyntacticCanonicalModel.lean`, `Semantics/Truth.lean`, `Metalogic_v2/Consistency/MaximalConsistent.lean`

**Verification**:
- Truth lemma compiles with no sorry
- `∀ phi w, phi ∈ w.formulas ↔ truth_at model tau t phi` proven
- All cases (atom, not, and, box, H, G) handled

---

### Phase 6: Update Representation Theorem [NOT STARTED]

**Goal**: Refactor main theorem to use SyntacticCanonicalFrame and prove completeness

**Tasks**:
- [ ] Modify `Metalogic_v2/Representation/RepresentationTheorem.lean`
- [ ] Update theorem statement to produce `TaskFrame Int` instead of ad-hoc structure
- [ ] Prove consistent context implies existence of SyntacticCanonicalModel
- [ ] Use truth lemma to show context formulas satisfied in model
- [ ] Update module documentation with new approach
- [ ] Run final `lake build` to verify all changes integrate

**Timing**: 0.5 hours

**Files to modify**:
- Modify: `Metalogic_v2/Representation/RepresentationTheorem.lean`
- Modify: `Metalogic_v2/Representation.lean` (update imports)

**Verification**:
- Representation theorem compiles with signature `∀ Gamma, Consistent Gamma → ∃ (M : TaskModel Int), Satisfies M Gamma`
- `lake build` succeeds for entire project
- No sorries remain in Representation module

---

## Testing & Validation

- [ ] All Representation files compile without errors
- [ ] `lake build` succeeds for full project
- [ ] No sorry remaining in any Representation theorem
- [ ] SyntacticCanonicalFrame is genuine TaskFrame Int instance
- [ ] Truth lemma covers all formula cases (atom, connectives, modal, temporal)
- [ ] Representation theorem produces TaskModel not ad-hoc structure
- [ ] Archived files preserved in Boneyard for reference

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/CanonicalModel_v1.lean` (archived old implementation)
- `Theories/Bimodal/Boneyard/SemanticCanonicalModel_v1.lean` (archived semantic attempt)
- `Theories/Bimodal/Boneyard/TruthLemma_v1.lean` (archived old truth lemma)
- `Metalogic_v2/Representation/SyntacticTaskRelation.lean` (new infrastructure)
- `Metalogic_v2/Representation/SyntacticCanonicalFrame.lean` (correct frame definition)
- `Metalogic_v2/Representation/SyntacticCanonicalModel.lean` (model wrapper)
- `Metalogic_v2/Representation/SyntacticTruthLemma.lean` (correctness proof)
- `Metalogic_v2/Representation/RepresentationTheorem.lean` (updated theorem)
- `specs/654_research_purely_syntactic_representation_theorem/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If implementation fails or produces intractable proof obligations:

1. **Preserve progress**: Keep all completed phases committed in git
2. **Restore from Boneyard**: Copy archived files back to Metalogic_v2/Representation/
3. **Document issues**: Create error report in errors.json with:
   - Which phase failed
   - Specific proof obligations that couldn't be closed
   - Recommended alternative approaches
4. **Alternative approaches** (in priority order):
   - Approach 3 from research: Define task_rel as explicit transitive closure type
   - Approach 4 from research: Use Lindenbaum-Tarski algebraic construction
   - Approach 5 from research: Define syntactic duration type for parametric D
5. **Fallback**: Mark task [BLOCKED] with detailed technical blocker description
