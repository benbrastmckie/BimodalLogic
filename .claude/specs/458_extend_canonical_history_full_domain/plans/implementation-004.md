# Implementation Plan: Task #458

- **Task**: 458 - Extend canonical_history from singleton domain to full domain
- **Status**: [NOT STARTED]
- **Effort**: 15-17 hours
- **Priority**: High
- **Dependencies**: Task 448 (completed)
- **Research Inputs**: .claude/specs/458_extend_canonical_history_full_domain/reports/research-004.md
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements a finite canonical model approach for completeness, replacing the infinite Duration-based construction that encountered compositionality gaps. The key insight from research-004.md is that since formulas are finite, the canonical countermodel for completeness only needs a finite number of world histories with a finite domain bounded by the temporal/modal depth of the target formula.

### Research Integration

Key findings from research-004.md integrated into this plan:
1. **Finite Model Property**: The temporal depth bounds domain size; modal depth bounds world history count
2. **Existing Infrastructure**: `subformulas`, `temporalDepth`, `modalDepth` already implemented in codebase
3. **Compositionality Simplification**: Finite model eliminates mixed-sign compositionality gaps
4. **Connection to Decidability**: Finite model property directly yields decidability

## Goals & Non-Goals

**Goals**:
- Implement finite canonical model construction based on subformula closure
- Prove weak_completeness theorem using finite model
- Establish strong_completeness as corollary
- Create modular file structure for reusability
- Preserve existing Duration-based code for potential future use

**Non-Goals**:
- Removing or refactoring the existing infinite canonical model code
- Implementing full decidability decision procedure (separate task)
- Optimizing for computational efficiency
- Proving model finiteness constructively (can use Classical.choice)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Local consistency definition complex | Medium | Medium | Start with propositional fragment, extend incrementally |
| Box case requires all histories | Medium | Medium | Define finite set of histories upfront, quantify over it |
| Finite existence lemma technical | High | Low | Adapt proven forward_extension pattern from existing code |
| Integration with existing code | Low | High | Keep as separate module, define interface types |
| Lindenbaum for finite sets | Medium | Low | Reuse existing set_lindenbaum with restriction |

## Implementation Phases

### Phase 1: Finite Time Domain and Subformula Closure [NOT STARTED]

**Goal**: Establish the finite time domain type and formalize subformula closure as a Finset

**Tasks**:
- [ ] Create `FiniteCanonicalModel.lean` in `Theories/Bimodal/Metalogic/Completeness/`
- [ ] Define `FiniteTime k := Fin (2 * k + 1)` for temporal domain
- [ ] Define `toInt : FiniteTime k -> Int` mapping to centered integers (-k to +k)
- [ ] Define `closure : Formula -> Finset Formula` using existing `subformulas`
- [ ] Prove `closure_finite : Fintype (closure phi).Elem`
- [ ] Prove basic arithmetic properties for FiniteTime

**Timing**: 2 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - New file

**Verification**:
- `lake build` succeeds
- `lean_diagnostic_messages` shows no errors
- All new definitions typecheck

---

### Phase 2: Finite World States [NOT STARTED]

**Goal**: Define finite world states as truth assignments restricted to subformula closure

**Tasks**:
- [ ] Define `FiniteWorldState phi` as function `closure phi -> Bool`
- [ ] Define `IsLocallyConsistent` predicate (propositional truth table consistency)
- [ ] Prove `Fintype (FiniteWorldState phi)` - at most 2^|closure| states
- [ ] Define equivalence between FiniteWorldState and restricted SetMaximalConsistent
- [ ] Implement `worldStateToSet : FiniteWorldState phi -> Set Formula`
- [ ] Implement `setToWorldState : (S : Set Formula) -> (h : restricted S phi) -> FiniteWorldState phi`

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

**Verification**:
- `Fintype` instance compiles
- Conversion functions are inverses (partial)
- No sorry in definitions

---

### Phase 3: Finite Task Relation [NOT STARTED]

**Goal**: Define task relation restricted to subformula transfer properties

**Tasks**:
- [ ] Define `finite_task_rel phi : FiniteWorldState phi -> Int -> FiniteWorldState phi -> Prop`
- [ ] Implement box-transfer: `box psi in closure -> S(box psi) -> T(psi)`
- [ ] Implement future-transfer: `d > 0 -> G psi in closure -> S(G psi) -> T(psi)`
- [ ] Implement past-transfer: `d < 0 -> H psi in closure -> S(H psi) -> T(psi)`
- [ ] Add persistence conditions: `S(box psi) -> T(box psi)` (box formulas persist)
- [ ] Prove `finite_task_rel_nullity`: `finite_task_rel phi S 0 S`
- [ ] Prove `finite_task_rel_compositionality`: composition of relations

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

**Verification**:
- Nullity proven without sorry
- Compositionality proven without sorry (this was the key gap in infinite model)
- Properties type-correct

---

### Phase 4: Finite Canonical Frame and Model [NOT STARTED]

**Goal**: Assemble frame and model structures for the finite canonical model

**Tasks**:
- [ ] Define `FiniteCanonicalFrame phi : TaskFrame Int` using FiniteWorldState and finite_task_rel
- [ ] Prove frame properties (nullity, compositionality) lift from relation properties
- [ ] Define `finite_valuation phi : String -> FiniteWorldState phi -> Prop`
- [ ] Define `FiniteCanonicalModel phi : TaskModel Int`
- [ ] Define `FiniteHistory phi` as function from FiniteTime to FiniteWorldState
- [ ] Implement `finite_history_from_origin` using existence lemmas

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

**Verification**:
- Frame satisfies TaskFrame axioms
- Model typechecks
- History construction compiles

---

### Phase 5: Finite Existence Lemmas [NOT STARTED]

**Goal**: Prove that consistent world states can be extended forward and backward

**Tasks**:
- [ ] Prove `finite_forward_existence`: given consistent S at t, exists consistent T at t+1
- [ ] Prove `finite_backward_existence`: given consistent S at t, exists consistent T at t-1
- [ ] These adapt existing `forward_extension` and `backward_extension` patterns
- [ ] Key simplification: only need to satisfy transfer for formulas in closure(phi)
- [ ] Use set_lindenbaum restricted to closure formulas

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

**Verification**:
- Existence lemmas proven (may use Classical.choice)
- Properties sufficient for history construction

---

### Phase 6: Finite Truth Lemma [NOT STARTED]

**Goal**: Prove the truth lemma for formulas in the subformula closure

**Tasks**:
- [ ] State `finite_truth_lemma`: for psi in closure(phi), `psi in S_t <-> truth_at M tau t psi`
- [ ] Prove atom case: `atom p in S <-> valuation p S` (by definition)
- [ ] Prove bot case: `bot in S <-> False` (by consistency)
- [ ] Prove imp case: uses local consistency of world states
- [ ] Prove box case: quantify over finite set of histories
- [ ] Prove all_past case: uses finite_task_rel transfer
- [ ] Prove all_future case: uses finite_task_rel transfer
- [ ] Combine into mutual induction on formula structure (bounded by closure)

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

**Verification**:
- Truth lemma proven without sorry
- All cases covered
- Induction terminates (closure is finite)

---

### Phase 7: Weak and Strong Completeness [NOT STARTED]

**Goal**: Prove the main completeness theorems using the finite canonical model

**Tasks**:
- [ ] Prove `finite_weak_completeness`: `not (derivable phi) -> exists M tau t, not (truth_at M tau t phi)`
  - Given: phi not derivable
  - By Lindenbaum: extend {neg phi} to maximal consistent S0 restricted to closure(phi)
  - Construct: FiniteWorldState from S0
  - Build: FiniteHistory using existence lemmas
  - Apply: finite_truth_lemma to get neg phi true at origin
- [ ] Prove `finite_strong_completeness`: `Gamma |= phi -> Gamma |- phi`
  - Contrapositive of weak completeness
- [ ] Connect to existing `weak_completeness` and `strong_completeness` axioms
- [ ] Replace axiom statements with proofs (or provide alternative theorems)

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`
- `Theories/Bimodal/Metalogic/Completeness.lean` (update documentation, optionally replace axioms)

**Verification**:
- weak_completeness and strong_completeness proven without sorry
- Theorems match expected signatures
- Documentation updated

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `lean_diagnostic_messages` shows no warnings on new file
- [ ] All phases compile without sorry (except documented Classical.choice uses)
- [ ] Finite truth lemma covers all formula cases
- [ ] Completeness theorems have correct type signatures
- [ ] Integration with existing Completeness.lean works (no import cycles)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Main implementation
- `.claude/specs/458_extend_canonical_history_full_domain/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

- The finite canonical model is implemented in a new file, leaving existing code untouched
- If approach fails, can revert to Duration-based approach with documented sorry gaps
- Each phase is independently verifiable, allowing partial progress preservation
- Key risk mitigation: Phase 3 (compositionality) is the critical validation point - if it fails, reconsider approach before proceeding
