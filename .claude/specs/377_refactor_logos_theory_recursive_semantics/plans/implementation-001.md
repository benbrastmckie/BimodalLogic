# Implementation Plan: Task #377

**Task**: Refactor Logos theory for recursive semantics
**Version**: 001
**Created**: 2026-01-11
**Language**: lean

## Overview

Transform Logos/ from a thin re-export wrapper around Bimodal/ into a self-contained implementation of the layered semantic framework specified in RECURSIVE_SEMANTICS.md. The implementation proceeds bottom-up: first the Constitutive Foundation (hyperintensional mereological state space with bilateral propositions), then the Core Extension (intensional task-based semantics with modal, temporal, and counterfactual operators).

This plan is organized into 6 phases, progressing from foundational structures to full semantic evaluation. Each phase builds on the previous and produces compilable, testable code.

## Phases

### Phase 1: Module Structure and Constitutive Frame

**Estimated effort**: 4-6 hours
**Status**: [IN PROGRESS]

**Objectives**:
1. Remove Bimodal re-exports and establish self-contained module structure
2. Implement the Constitutive Frame (complete lattice state space)
3. Define core mereological operations (fusion, parthood, null/full states)

**Files to modify**:
- `Logos/Foundation.lean` (new) - Module export file
- `Logos/Foundation/Frame.lean` (new) - Constitutive frame structure
- `Logos/Foundation/Basic.lean` (new) - Basic mereological lemmas

**Steps**:
1. Create `Logos/Foundation/` directory structure
2. Define `ConstitutiveFrame` structure using Mathlib's `CompleteLattice`:
   ```lean
   structure ConstitutiveFrame where
     State : Type*
     [lattice : CompleteLattice State]
   ```
3. Define derived operations:
   - `null : State` (⊥ element, □)
   - `full : State` (⊤ element, ■)
   - `fusion : State → State → State` (⊔ operation, s.t)
   - `parthood : State → State → Prop` (≤ relation, ⊑)
4. Prove basic lemmas: null identity, fusion associativity/commutativity
5. Remove `import Bimodal` from existing Logos files

**Verification**:
- `lake build Logos.Foundation` compiles without error
- Basic lemmas proven without sorry
- No Bimodal imports remain in Foundation/

---

### Phase 2: Bilateral Propositions and Hyperintensional Interpretation

**Estimated effort**: 5-7 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Define bilateral propositions (verifier/falsifier pairs)
2. Implement propositional operations (product ⊗, sum ⊕)
3. Define the interpretation function for non-logical vocabulary
4. Implement variable assignments

**Files to modify**:
- `Logos/Foundation/Proposition.lean` (new) - Bilateral propositions
- `Logos/Foundation/Interpretation.lean` (new) - Interpretation function
- `Logos/Foundation/Assignment.lean` (new) - Variable assignments

**Steps**:
1. Define `BilateralProp` structure:
   ```lean
   structure BilateralProp (S : Type*) where
     verifiers : Set S
     falsifiers : Set S
   ```
2. Implement propositional operations:
   - `product : BilateralProp S → BilateralProp S → BilateralProp S` (⊗)
   - `sum : BilateralProp S → BilateralProp S → BilateralProp S` (⊕)
   - `negation : BilateralProp S → BilateralProp S` (swap verifiers/falsifiers)
3. Define `Interpretation` for function symbols and predicates:
   - Function symbols: `S^n → S`
   - Predicates: Sets of verifier/falsifier functions
4. Define `VarAssignment : Var → State`
5. Prove propositional operations satisfy expected properties

**Verification**:
- `lake build Logos.Foundation.Proposition` compiles
- Negation is involutive: `neg (neg p) = p`
- De Morgan-like laws for product/sum hold

---

### Phase 3: Hyperintensional Semantics (Verification/Falsification)

**Estimated effort**: 6-8 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Define constitutive formula syntax (¬, ∧, ∨, ⊤, ⊥, ≡)
2. Implement verification (⊩⁺) and falsification (⊩⁻) relations
3. Define propositional identity and constitutive relations (essence, ground)

**Files to modify**:
- `Logos/Foundation/Syntax.lean` (new) - Constitutive formula type
- `Logos/Foundation/Semantics.lean` (new) - Verification/falsification
- `Logos/Foundation/Consequence.lean` (new) - Logical consequence

**Steps**:
1. Define `ConstitutiveFormula` type:
   ```lean
   inductive ConstitutiveFormula where
     | atom : String → ConstitutiveFormula
     | bot : ConstitutiveFormula
     | top : ConstitutiveFormula
     | neg : ConstitutiveFormula → ConstitutiveFormula
     | and : ConstitutiveFormula → ConstitutiveFormula → ConstitutiveFormula
     | or : ConstitutiveFormula → ConstitutiveFormula → ConstitutiveFormula
     | ident : ConstitutiveFormula → ConstitutiveFormula → ConstitutiveFormula
   ```
2. Implement `verifies` and `falsifies` relations per RECURSIVE_SEMANTICS.md:
   - Atomic: check interpretation
   - Negation: swap verification/falsification
   - Conjunction: fusion of verifiers, sum of falsifiers
   - Disjunction: sum of verifiers, fusion of falsifiers
   - Top: all states verify, only full falsifies
   - Bottom: never verified, only null falsifies
   - Identity: null verifies iff verifier/falsifier sets equal
3. Define derived relations:
   - `essence A B := A ∧ B ≡ B`
   - `ground A B := A ∨ B ≡ B`
4. Define logical consequence for identity sentences

**Verification**:
- Verification/falsification clauses match RECURSIVE_SEMANTICS.md exactly
- `verifies` and `falsifies` are decidable for finite state spaces
- Example: `¬¬p ≡ p` is valid

---

### Phase 4: Core Frame Extension (Task Relation)

**Estimated effort**: 5-7 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Extend Constitutive Frame with temporal order and task relation
2. Define all 6 task relation constraints (nullity, compositionality, parthood L/R, containment L/R, maximality)
3. Define state modality concepts (possible, compatible, maximal, world-state)

**Files to modify**:
- `Logos/Core.lean` (new) - Module export file
- `Logos/Core/Frame.lean` (new) - Core frame with task relation
- `Logos/Core/Modality.lean` (new) - State modality definitions

**Steps**:
1. Define `CoreFrame` extending `ConstitutiveFrame`:
   ```lean
   structure CoreFrame (T : Type*) [LinearOrderedAddCommGroup T] extends ConstitutiveFrame where
     task_rel : State → T → State → Prop
     nullity : ∀ s, task_rel s 0 s
     compositionality : ∀ s u v x y, task_rel s x u → task_rel u y v → task_rel s (x + y) v
     parthood_left : ∀ d s t r, d ≤ s → task_rel s x t → ∃ r', r' ≤ t ∧ task_rel d x r'
     parthood_right : ...
     containment_left : ...
     containment_right : ...
     maximality : ...
   ```
2. Define state modality concepts:
   - `possible s := task_rel s 0 s`
   - `compatible s t := possible (fusion s t)`
   - `maximal_t_compatible s t r := ...` (per RECURSIVE_SEMANTICS.md)
   - `world_state w := maximal_possible w`
3. Define `WorldHistory` over CoreFrame:
   ```lean
   structure WorldHistory (F : CoreFrame T) where
     domain : Set T
     domain_convex : Convex domain
     states : ∀ t ∈ domain, F.State
     world_states : ∀ t ht, world_state (states t ht)
     task_respecting : ∀ x y (hx : x ∈ domain) (hy : y ∈ domain),
       x ≤ y → F.task_rel (states x hx) (y - x) (states y hy)
   ```

**Verification**:
- `lake build Logos.Core.Frame` compiles
- Task relation constraints are correctly formulated
- Example CoreFrame instances can be constructed

---

### Phase 5: Extended Formula Type and Core Operators

**Estimated effort**: 6-8 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Define full formula type with all Core Extension operators
2. Implement modal (□, ◇), temporal (H, G, P, F, Since, Until), counterfactual (□→), and store/recall (↑, ↓) operators
3. Add lambda abstraction and universal quantifier

**Files to modify**:
- `Logos/Core/Syntax.lean` (new) - Core formula type
- `Logos/Core/Syntax/Formula.lean` (new) - Full formula definition
- `Logos/Core/Syntax/Operators.lean` (new) - Derived operators

**Steps**:
1. Define `Formula` extending `ConstitutiveFormula`:
   ```lean
   inductive Formula where
     -- Constitutive operators (embedded)
     | cfml : ConstitutiveFormula → Formula
     -- Modal operators
     | box : Formula → Formula
     | diamond : Formula → Formula
     -- Temporal operators (basic)
     | all_past : Formula → Formula
     | all_future : Formula → Formula
     -- Temporal operators (extended)
     | since : Formula → Formula → Formula
     | until : Formula → Formula → Formula
     -- Counterfactual
     | counterfactual : Formula → Formula → Formula
     -- Store/Recall (indexed)
     | store : Nat → Formula → Formula
     | recall : Nat → Formula → Formula
     -- Quantification
     | forall : String → Formula → Formula
     | lambda : String → Formula → Term → Formula
   ```
2. Define `Term` type for object-level terms:
   ```lean
   inductive Term where
     | var : String → Term
     | const : String → Term
     | app : String → List Term → Term
   ```
3. Implement derived operators:
   - `some_past`, `some_future` (existential temporal)
   - `always`, `sometimes` (△, ▽)
   - `might_counterfactual` (◇→)
   - Negation, conjunction, disjunction at Formula level

**Verification**:
- `lake build Logos.Core.Syntax` compiles
- All operators from RECURSIVE_SEMANTICS.md represented
- Formula complexity metric works correctly

---

### Phase 6: Truth Evaluation and Validity

**Estimated effort**: 8-10 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Implement full truth evaluation relative to model, history, time, assignment, temporal index
2. Define validity and logical consequence
3. Create tests validating semantic clauses match RECURSIVE_SEMANTICS.md

**Files to modify**:
- `Logos/Core/Model.lean` (new) - Core model structure
- `Logos/Core/Truth.lean` (new) - Truth evaluation
- `Logos/Core/Validity.lean` (new) - Validity and consequence
- `LogosTest/Core/TruthTest.lean` (new) - Semantic tests

**Steps**:
1. Define `CoreModel`:
   ```lean
   structure CoreModel (T : Type*) [LinearOrderedAddCommGroup T] where
     frame : CoreFrame T
     interpretation : Interpretation frame.State
   ```
2. Define `TemporalIndex` for store/recall:
   ```lean
   def TemporalIndex := List T
   ```
3. Implement `truth_at` with full parameters:
   ```lean
   def truth_at (M : CoreModel T) (τ : WorldHistory M.frame) (t : T) (ht : τ.domain t)
       (σ : VarAssignment M.frame.State) (idx : TemporalIndex) : Formula → Prop
   ```
4. Implement semantic clauses for all operators:
   - Modal: quantify over all world-histories at time t
   - Temporal: quantify over earlier/later times in domain
   - Since/Until: existential + universal combination
   - Counterfactual: mereological formulation per RECURSIVE_SEMANTICS.md
   - Store: update temporal index
   - Recall: evaluate at stored time
   - Forall: quantify over all states
   - Lambda: substitute in assignment
5. Define validity and logical consequence
6. Create test suite with examples from RECURSIVE_SEMANTICS.md

**Verification**:
- `lake build Logos` compiles without error
- `lake build LogosTest` compiles
- Key examples validate:
  - Modal T: `□φ → φ`
  - Temporal 4: `Gφ → GGφ`
  - Bimodal interaction: `□φ → △φ`
  - Counterfactual identity: `φ □→ φ`

---

## Dependencies

- **Task 376** (TheoryLib structure): Should be coordinated but not blocking. If TheoryLib is implemented first, Logos can be moved into it. Otherwise, Logos can be developed standalone and migrated later.
- **Mathlib**: `CompleteLattice`, `LinearOrderedAddCommGroup` (already available)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Counterfactual semantics complexity | High | Medium | Implement simpler modal/temporal first; counterfactuals can be deferred to later phase |
| Task relation constraints too strong | Medium | Medium | Start with just nullity+compositionality (as Bimodal does), add others incrementally |
| Performance with large state spaces | Medium | Low | Focus on correctness first; use abstract formulation with typeclasses |
| Coordination with Task 376 | Low | Medium | Proceed independently; migration is straightforward |

## Success Criteria

- [ ] Logos/ contains no Bimodal imports (fully self-contained)
- [ ] `lake build Logos` succeeds with no errors
- [ ] ConstitutiveFrame with CompleteLattice structure implemented
- [ ] Bilateral propositions with verifier/falsifier semantics working
- [ ] CoreFrame with full task relation constraints implemented
- [ ] All operators from RECURSIVE_SEMANTICS.md represented in Formula type
- [ ] Truth evaluation implemented for all operators
- [ ] Test suite validates key semantic properties

## Rollback Plan

If implementation fails:
1. Git revert to pre-implementation state
2. Logos/ remains as Bimodal re-export layer
3. Document blockers in research report update
4. Consider alternative approaches (e.g., embed Bimodal and extend rather than replace)

## Notes

- This plan focuses on semantic foundations. Proof system (axioms, derivation) and metalogic (soundness, completeness) are deferred to subsequent tasks.
- Extensions (Epistemic, Normative, Spatial, Agential) remain as stubs per original design; they build on the Core Extension implemented here.
- The research report estimates 41-58 hours total; this plan structures that into 6 phases of approximately 6-8 hours each for manageability.
