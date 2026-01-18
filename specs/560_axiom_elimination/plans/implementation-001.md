# Implementation Plan: Task #560

- **Task**: 560 - Axiom Elimination
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: Task 558 (MCS and truth lemma foundation)
- **Research Inputs**: specs/560_axiom_elimination/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Replace the `representation_theorem_backward_empty` axiom with a proven theorem in `Representation/ContextProvability.lean`. The proof uses the completeness contrapositive argument: show that if a formula is not derivable from empty context, then its negation is consistent, hence satisfiable in the canonical model, and therefore there exists a countermodel witnessing non-validity. The key challenge is bridging canonical model truth to the polymorphic semantic validity definition.

### Research Integration

Research report `research-001.md` identifies the proof strategy (contrapositive via `Function.mtr`), the available infrastructure (`deduction_theorem`, `double_negation`, `representation_theorem`), and the semantic embedding gap that needs to be addressed.

## Goals & Non-Goals

**Goals**:
- Remove the axiom declaration for `representation_theorem_backward_empty`
- Prove the theorem using existing Metalogic_v2 infrastructure
- Maintain all downstream theorems (`representation_theorem_empty`, `valid_implies_derivable`, etc.) without changes to their proofs

**Non-Goals**:
- Refactoring the semantic consequence definition
- Changing the canonical model construction
- Modifying the representation theorem infrastructure
- Addressing other axioms or sorries in the codebase

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Semantic embedding gap too complex | High | Medium | Use the existing completeness_corollary approach in RepresentationTheorem.lean as fallback; consider adding intermediate bridge lemmas |
| Deduction theorem format mismatch | Medium | Low | Verify deduction theorem signature matches expected usage; adapt proof structure if needed |
| Double negation elimination type issues | Medium | Low | Check exact signature of `double_negation` and ensure proper weakening to context |
| Canonical truth not connecting to semantic truth | High | Medium | Leverage `canonicalContextSatisfiable` and `representation_satisfiability` as bridge |

## Implementation Phases

### Phase 1: Explore Infrastructure and Verify Dependencies [NOT STARTED]

**Goal**: Confirm all required lemmas exist and have compatible signatures.

**Tasks**:
- [ ] Verify `deduction_theorem` signature: `(Γ : Context) → (A B : Formula) → (A :: Γ ⊢ B) → Γ ⊢ A.imp B`
- [ ] Verify `double_negation` signature: `(φ : Formula) → ⊢ φ.neg.neg.imp φ`
- [ ] Check `representation_theorem` signature: `Consistent Γ → ∃ (w : CanonicalWorldState), ∀ φ ∈ Γ, canonicalTruthAt w φ`
- [ ] Identify Mathlib contrapositive lemmas (`Function.mtr`, `not_imp_not`)
- [ ] Verify `Consistent` definition and its relationship to derivability

**Timing**: 30 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic_v2/Core/DeductionTheorem.lean` - deduction theorem
- `Theories/Bimodal/Theorems/Propositional.lean` - double negation
- `Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean` - representation theorem
- `Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean` - Consistent definition

**Verification**:
- All lemma signatures documented
- Compatibility confirmed with proof sketch

---

### Phase 2: Prove Consistency of Negation Lemma [NOT STARTED]

**Goal**: Prove that if `φ` is not derivable from empty context, then `[φ.neg]` is consistent.

**Tasks**:
- [ ] Create helper lemma: `not_derivable_implies_neg_consistent`
- [ ] Proof structure:
  1. Assume `¬ContextDerivable [] φ`
  2. Assume for contradiction: `¬Consistent [φ.neg]` (i.e., `[φ.neg] ⊢ ⊥`)
  3. By deduction theorem: `[] ⊢ φ.neg → ⊥` = `[] ⊢ φ.neg.neg`
  4. By `double_negation` + modus ponens: `[] ⊢ φ`
  5. Contradiction with assumption
- [ ] Handle weakening of `double_negation` from `⊢` to `[] ⊢`
- [ ] Test proof compiles without errors

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - add helper lemma

**Verification**:
- Lemma `not_derivable_implies_neg_consistent` compiles
- No sorries in the lemma
- `lean_diagnostic_messages` shows no errors

---

### Phase 3: Bridge Canonical Truth to Semantic Countermodel [NOT STARTED]

**Goal**: Prove that canonical world truth of `φ.neg` implies existence of semantic countermodel.

**Tasks**:
- [ ] Analyze `canonicalTruthAt` definition and semantic structures
- [ ] Identify how to instantiate the polymorphic `semantic_consequence` with a concrete model
- [ ] Option A: Construct `TaskFrame Int` and `TaskModel` from canonical model
- [ ] Option B: Use negation of semantic consequence directly with canonical model witness
- [ ] Create bridge lemma: `canonical_neg_true_implies_not_semantic_consequence`
- [ ] Handle the quantification over `∀ D : Type, ...` by exhibiting a specific witness

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - add bridge lemma

**Verification**:
- Bridge lemma compiles
- No sorries in the lemma
- Type compatibility verified via `lean_goal` and `lean_hover_info`

---

### Phase 4: Replace Axiom with Theorem [NOT STARTED]

**Goal**: Convert the axiom declaration to a proven theorem using the helper lemmas.

**Tasks**:
- [ ] Change `axiom representation_theorem_backward_empty` to `theorem representation_theorem_backward_empty`
- [ ] Implement proof using contrapositive:
  1. Apply `Function.mtr` (or `Mathlib.Tactic.Contrapose.mtr`)
  2. Assume `¬ContextDerivable [] φ`
  3. By Phase 2 lemma: `Consistent [φ.neg]`
  4. By `representation_theorem`: `∃ w, φ.neg ∈ w.carrier`
  5. By Phase 3 bridge: `¬semantic_consequence [] φ`
- [ ] Verify all downstream theorems still compile:
  - `representation_theorem_empty`
  - `valid_implies_derivable`
  - `derivable_implies_valid`
  - `representation_validity`
- [ ] Run `lean_diagnostic_messages` on entire file

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - replace axiom with theorem

**Verification**:
- `axiom` keyword removed
- Theorem compiles without sorry
- All dependent theorems compile
- `lake build` succeeds for the module

---

### Phase 5: Verification and Cleanup [NOT STARTED]

**Goal**: Ensure no regressions and clean up any temporary constructs.

**Tasks**:
- [ ] Run full build: `lake build Bimodal.Metalogic_v2.Representation.ContextProvability`
- [ ] Check for any new sorries introduced: search for `sorry` in modified files
- [ ] Verify WeakCompleteness.lean still compiles (uses `representation_theorem_backward_empty`)
- [ ] Run `lake build` for full project
- [ ] Review proof for clarity and add documentation comments
- [ ] Remove any temporary debugging code

**Timing**: 15 minutes

**Files to verify**:
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean`
- `Theories/Bimodal/Metalogic_v2/Completeness/WeakCompleteness.lean`

**Verification**:
- Zero sorries in ContextProvability.lean (except any pre-existing)
- Full `lake build` succeeds
- No new compiler warnings

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic_v2.Representation.ContextProvability` succeeds
- [ ] `lake build Bimodal.Metalogic_v2.Completeness.WeakCompleteness` succeeds
- [ ] `lake build` full project succeeds
- [ ] No `axiom` declarations remain in ContextProvability.lean for representation_theorem_backward_empty
- [ ] All existing theorems using the axiom still compile
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` returns 0 new sorries

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - Modified file with proven theorem
- `specs/560_axiom_elimination/plans/implementation-001.md` - This plan
- `specs/560_axiom_elimination/summaries/implementation-summary-YYYYMMDD.md` - Completion summary (to be created)

## Rollback/Contingency

If the semantic embedding proves too complex:
1. Keep the axiom but add a detailed proof sketch comment documenting the approach
2. Create a follow-up task for completing the semantic embedding
3. Consider alternative approaches:
   - Using FMP module infrastructure
   - Adding intermediate axioms that are easier to prove
   - Factoring the proof into smaller verified steps

Git provides rollback capability: `git checkout HEAD -- Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean`
