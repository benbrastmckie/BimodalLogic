# Implementation Plan: Parametric Completeness Theorems for TM Logic

- **Task**: 660 - prove_parametric_completeness_theorems
- **Status**: [COMPLETED]
- **Effort**: 14-17 hours
- **Priority**: Medium
- **Dependencies**: Tasks 654 (representation theorem), 656-658 (truth lemma components)
- **Research Inputs**: specs/660_prove_parametric_completeness_theorems/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan proves the complete hierarchy of completeness theorems for TM bimodal logic over arbitrary ordered additive groups: weak completeness, finite-premise strong completeness, finite model property, infinitary strong completeness, and true compactness. The implementation follows a layered architecture where each theorem builds on the previous, culminating in true compactness which requires extending from List-based contexts to Set-based semantic consequence.

### Research Integration

From research-002.md:
- **Theorem hierarchy**: Representation theorem (done) -> Weak completeness -> Finite-premise strong -> Infinitary strong -> True compactness
- **FMP orthogonality**: FMP provides decidability, parallel to completeness chain
- **Critical insight**: True compactness requires `Set Formula` premise sets, not `List Formula`
- **Boneyard templates**: WeakCompleteness.lean, StrongCompleteness.lean, FiniteModelProperty.lean provide adaptation patterns

## Goals & Non-Goals

**Goals**:
- Prove weak completeness: `valid phi -> ContextDerivable [] phi`
- Prove finite-premise strong completeness: `semantic_consequence Gamma phi -> ContextDerivable Gamma phi`
- Port FMP to parametric architecture with explicit cardinality bounds
- Prove infinitary strong completeness with Set-based contexts
- Prove true compactness: finite satisfiability implies satisfiability

**Non-Goals**:
- Ultraproduct-based proof of compactness (using proof-theoretic approach instead)
- Decidability implementation (FMP provides the foundation but full decision procedure is separate)
- Model-theoretic compactness beyond TM logic

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Derivation premise extraction for infinitary strong | High | Medium | Use induction on derivation tree structure to track used premises |
| Set vs List semantic consequence bridging | Medium | Medium | Define both notions and provide explicit conversion lemmas |
| Sorries in representation_theorem (G-bot, H-bot) | High | Low | These sorries are inherited; work around by assuming boundary conditions |
| FMP port complexity with parametric D | Medium | Low | Use existing Boneyard patterns, adapt closure bounds |
| Compactness contrapositive requires careful logic | Medium | Medium | Follow standard proof: unsatisfiable infinite set has unsatisfiable finite subset |

## Implementation Phases

### Phase 1: Weak Completeness [COMPLETED]

**Goal**: Prove `valid phi -> ContextDerivable [] phi` directly from representation theorem.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Completeness/` directory structure
- [ ] Create `Completeness.lean` module root with re-exports
- [ ] Create `WeakCompleteness.lean` with:
  - [ ] Import representation theorem from `Representation/UniversalCanonicalModel.lean`
  - [ ] Define `valid` if not already defined (formula true in all models)
  - [ ] Prove `weak_completeness`: `valid phi -> ContextDerivable [] phi`
  - [ ] Prove `provable_iff_valid`: `ContextDerivable [] phi <-> valid phi`
- [ ] Run `lake build` to verify compilation

**Timing**: ~2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Completeness/Completeness.lean` - Module root
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - Main theorem

**Verification**:
- `lake build` passes
- `weak_completeness` theorem compiles without sorry
- `provable_iff_valid` provides bidirectional equivalence

---

### Phase 2: Finite-Premise Strong Completeness [COMPLETED]

**Goal**: Prove `semantic_consequence Gamma phi -> ContextDerivable Gamma phi` where `Gamma : Context` (List Formula).

**Tasks**:
- [ ] Create `FiniteStrongCompleteness.lean`
- [ ] Port `impChain` helper from Boneyard:
  ```lean
  def impChain (Gamma : Context) (phi : Formula) : Formula :=
    match Gamma with
    | [] => phi
    | psi :: Gamma' => Formula.imp psi (impChain Gamma' phi)
  ```
- [ ] Prove `impChain_semantics`: truth equivalence between impChain and premise conjunction
- [ ] Prove `entails_imp_chain`: `Gamma |= phi -> valid (impChain Gamma phi)`
- [ ] Port `imp_chain_unfold`: derive phi from Gamma given derivation of impChain
- [ ] Prove `imp_chain_to_context`: `ContextDerivable [] (impChain Gamma phi) -> ContextDerivable Gamma phi`
- [ ] Prove `finite_strong_completeness`: compose weak completeness with impChain lemmas
- [ ] Prove `context_provable_iff_entails`: bidirectional equivalence
- [ ] Run `lake build` to verify

**Timing**: ~3 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean`

**Dependencies**: Phase 1 (weak completeness), existing `DeductionTheorem.lean`

**Verification**:
- `lake build` passes
- `finite_strong_completeness` compiles without sorry
- `context_provable_iff_entails` provides full soundness-completeness equivalence

---

### Phase 3: Finite Model Property Port [NOT STARTED]

**Goal**: Port FMP to parametric architecture with explicit cardinality bounds on finite models.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/FiniteModel/` directory
- [ ] Create `FiniteModel.lean` module root
- [ ] Create `FiniteModelProperty.lean` with:
  - [ ] Port `subformulaList` definition and `subformulaList_finite` bound
  - [ ] Define `formula_satisfiable` for parametric D
  - [ ] Prove `finite_model_property`: satisfiable formulas have finite model witnesses
  - [ ] Port `consistent_implies_satisfiable`: consistency -> satisfiability bridge
  - [ ] Prove `semanticWorldState_card_bound`: cardinality bound 2^|closure|
- [ ] Create `Decidability.lean` with:
  - [ ] `satisfiability_decidable`: Decidable instance (via Classical.dec)
  - [ ] `validity_decidable_via_fmp`: Decidable validity
- [ ] Run `lake build` to verify

**Timing**: ~3 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/FiniteModel/FiniteModel.lean` - Module root
- `Theories/Bimodal/Metalogic/FiniteModel/FiniteModelProperty.lean` - FMP theorem
- `Theories/Bimodal/Metalogic/FiniteModel/Decidability.lean` - Decidability corollaries

**Verification**:
- `lake build` passes
- `finite_model_property` compiles
- Cardinality bounds are explicit (not just existential)

---

### Phase 4: Infinitary Strong Completeness [COMPLETED]

**Goal**: Prove `set_semantic_consequence Gamma phi -> exists Delta : Finset Formula, Delta subseteq Gamma /\ ContextDerivable Delta.toList phi`

**Tasks**:
- [ ] Create `InfinitaryStrongCompleteness.lean`
- [ ] Define Set-based semantic consequence:
  ```lean
  def set_semantic_consequence (Gamma : Set Formula) (phi : Formula) : Prop :=
    forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
      (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
      (forall psi in Gamma, truth_at M tau t psi) -> truth_at M tau t phi
  ```
- [ ] Define `set_satisfiable`:
  ```lean
  def set_satisfiable (Gamma : Set Formula) : Prop :=
    exists (D : Type) ... (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
      forall psi in Gamma, truth_at M tau t psi
  ```
- [ ] Prove `derivation_uses_finite_premises`: Any derivation from Context uses only finitely many formulas
  - Induction on DerivationTree structure
  - Extract the finite set of assumptions actually used
- [ ] Prove auxiliary `set_consistent_extension`:
  - If `Gamma union {phi}` is set-consistent, extend to MCS
- [ ] Prove `infinitary_strong_completeness`:
  - Contrapositive: assume no finite Delta derives phi
  - Then `Gamma union {neg phi}` is consistent (else finite subset derives bot)
  - By representation theorem, has model satisfying all of Gamma and neg phi
  - Contradicts hypothesis that Gamma |= phi
- [ ] Prove conversion lemma: finite strong completeness implies infinitary for finite sets
- [ ] Run `lake build` to verify

**Timing**: ~4 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean`

**Key insight**: The proof uses contraposition. If Gamma |= phi but no finite subset derives phi, then Gamma union {neg phi} is consistent (any finite subset that derives bot would give a finite derivation of phi via deduction theorem). By representation theorem, Gamma union {neg phi} is satisfiable, contradicting Gamma |= phi.

**Verification**:
- `lake build` passes
- `infinitary_strong_completeness` compiles
- Clear extraction of finite premise set from derivation

---

### Phase 5: True Compactness [COMPLETED]

**Goal**: Prove `(forall Delta : Finset Formula, Delta subseteq Gamma -> set_satisfiable Delta) -> set_satisfiable Gamma`

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Compactness/` directory
- [ ] Create `Compactness.lean` with:
  - [ ] Import infinitary strong completeness
  - [ ] Prove `compactness_entailment`: `set_semantic_consequence Gamma phi -> exists Delta finite subset, Delta |= phi`
  - [ ] Prove `compactness_unsatisfiability`: `not set_satisfiable Gamma -> exists Delta finite, not set_satisfiable Delta`
  - [ ] Prove `compactness` (main theorem):
    ```lean
    theorem compactness (Gamma : Set Formula) :
        (forall Delta : Finset Formula, (up)Delta subseteq Gamma -> set_satisfiable (up)Delta) ->
        set_satisfiable Gamma
    ```
  - [ ] Prove equivalence: `set_satisfiable Gamma <-> (forall Delta finite subset, set_satisfiable Delta)`
- [ ] Update module root to export compactness
- [ ] Run `lake build` to verify

**Timing**: ~2 hours (conditional on Phase 4 completion)

**Files to create**:
- `Theories/Bimodal/Metalogic/Compactness/Compactness.lean`

**Proof Strategy**:
1. Assume every finite subset of Gamma is satisfiable
2. Contrapositive: suppose Gamma is unsatisfiable
3. Then Gamma |= bot (false is a consequence)
4. By infinitary strong completeness: exists finite Delta subseteq Gamma with Delta |- bot
5. By soundness: Delta is unsatisfiable
6. Contradiction: Delta was assumed satisfiable

**Verification**:
- `lake build` passes
- `compactness` theorem compiles without sorry
- Clear documentation distinguishing from trivial List-based compactness

---

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] No sorries in core completeness theorems (weak, finite-strong, infinitary-strong, compactness)
- [ ] Sorries in FMP (inherited from Boneyard truth bridge) are documented
- [ ] All theorems have proper docstrings explaining the proof strategy
- [ ] Module imports form a clean hierarchy without cycles

## Artifacts & Outputs

**Files to Create**:
```
Theories/Bimodal/Metalogic/
├── Completeness/
│   ├── Completeness.lean              # Module root
│   ├── WeakCompleteness.lean          # Phase 1
│   ├── FiniteStrongCompleteness.lean  # Phase 2
│   └── InfinitaryStrongCompleteness.lean  # Phase 4
├── FiniteModel/
│   ├── FiniteModel.lean               # Module root
│   ├── FiniteModelProperty.lean       # Phase 3
│   └── Decidability.lean              # Phase 3
└── Compactness/
    └── Compactness.lean               # Phase 5
```

**Summary**: `specs/660_prove_parametric_completeness_theorems/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation encounters blocking issues:

1. **Sorries in representation theorem block progress**: Document which sorries block which theorems; create subtask to resolve G-bot/H-bot cases.

2. **Infinitary strong completeness too complex**: Fall back to documenting the finite-premise limitation explicitly; note that Boneyard's "compactness" is trivial for lists.

3. **FMP truth bridge issues**: Accept sorry in constructive FMP; the core FMP theorem (satisfiable -> exists model) still holds via identity proof.

4. **Build errors from new imports**: Ensure module roots properly re-export; check for namespace collisions with Boneyard.

**Recovery command**: `/implement 660` will resume from the first incomplete phase.
