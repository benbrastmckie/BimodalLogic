# Implementation Plan: Task #261

**Task**: Decidability - Implement decision procedures for TM logic
**Version**: 001
**Created**: 2026-01-12
**Language**: lean

## Overview

This plan implements verified decision procedures for TM bimodal logic using the tableau method. The approach leverages the Type-based axiom representation (from task 260) to construct actual proof terms when valid, and finite countermodels when invalid. The implementation builds on existing infrastructure in `ProofSearch.lean` and integrates with the semantics and proof system modules.

### Key Design Decisions

1. **Tableau-Based Approach**: Use signed formula tableaux for systematic satisfiability checking
2. **Witness Construction**: Return `DerivationTree` proofs for valid formulas, `Countermodel` for invalid
3. **Proof Search Integration**: Use existing `matchAxiom` and `bounded_search_with_proof` as optimization layer
4. **Finite Model Property**: Leverage FMP for termination guarantees

### Module Architecture

```
Theories/Bimodal/Metalogic/Decidability/
├── SignedFormula.lean       -- SignedFormula, Branch types
├── Tableau.lean             -- Tableau rules and expansion
├── Closure.lean             -- Branch closure detection
├── Saturation.lean          -- Saturation detection and termination
├── ProofExtraction.lean     -- Extract DerivationTree from closed tableau
├── CountermodelExtraction.lean -- Extract finite model from open branch
├── DecisionProcedure.lean   -- Main decide function
└── Correctness.lean         -- Soundness and completeness proofs
```

---

## Phases

### Phase 1: Signed Formula and Branch Types

**Estimated effort**: 3-4 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Define `Sign` type (pos/neg) for signed formulas
2. Define `SignedFormula` structure with decidable equality
3. Define `Branch` as list of signed formulas
4. Implement basic branch operations (contains, contradicts)
5. Define subformula closure function

**Files to create**:
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean`

**Steps**:
1. Create module with imports from Bimodal.Syntax and Bimodal.ProofSystem
2. Define Sign inductive type:
   ```lean
   inductive Sign | pos | neg
     deriving Repr, DecidableEq, BEq, Hashable
   ```
3. Define SignedFormula structure:
   ```lean
   structure SignedFormula where
     sign : Sign
     formula : Formula
     deriving Repr, DecidableEq, BEq, Hashable
   ```
4. Define Branch type and basic operations:
   ```lean
   abbrev Branch := List SignedFormula

   def Branch.contains (b : Branch) (sf : SignedFormula) : Bool
   def Branch.hasContradiction (b : Branch) : Bool
   def Branch.hasBotPos (b : Branch) : Bool
   ```
5. Implement subformula closure:
   ```lean
   def Formula.subformulas : Formula → List Formula
   def subformulaClosure : Formula → List Formula
   ```

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.SignedFormula` compiles
- Basic tests verify contradiction detection works
- Subformula closure is closed under itself

---

### Phase 2: Tableau Rules

**Estimated effort**: 6-8 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Define tableau expansion rules for all formula constructors
2. Implement propositional rules (and, or, imp, neg)
3. Implement modal S5 rules (box, diamond)
4. Implement temporal rules (all_future, all_past, some_future, some_past)
5. Define rule application function

**Files to create**:
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean`

**Steps**:
1. Import SignedFormula module
2. Define TableauRule type describing rule applications:
   ```lean
   inductive TableauRule where
     | andPos : TableauRule    -- T(A ∧ B) → T(A), T(B)
     | andNeg : TableauRule    -- F(A ∧ B) → F(A) | F(B) (branching)
     | orPos : TableauRule     -- T(A ∨ B) → T(A) | T(B) (branching)
     | orNeg : TableauRule     -- F(A ∨ B) → F(A), F(B)
     | impPos : TableauRule    -- T(A → B) → F(A) | T(B) (branching)
     | impNeg : TableauRule    -- F(A → B) → T(A), F(B)
     | negPos : TableauRule    -- T(¬A) → F(A)
     | negNeg : TableauRule    -- F(¬A) → T(A)
     | boxPos : TableauRule    -- T(□A) → T(A) at all accessible states
     | boxNeg : TableauRule    -- F(□A) → F(A) at new accessible state
     | allFuturePos : TableauRule  -- T(GA) → T(A) at all future times
     | allFutureNeg : TableauRule  -- F(GA) → F(A) at some future time
     | allPastPos : TableauRule    -- T(HA) → T(A) at all past times
     | allPastNeg : TableauRule    -- F(HA) → F(A) at some past time
   ```
3. Implement rule applicability check:
   ```lean
   def isApplicable (rule : TableauRule) (sf : SignedFormula) : Bool
   ```
4. Implement rule application (returns list of branches for branching rules):
   ```lean
   def applyRule (rule : TableauRule) (sf : SignedFormula) (b : Branch)
       : List Branch
   ```
5. Implement single-step expansion:
   ```lean
   def expandBranch (b : Branch) : List Branch
   ```

**Verification**:
- Each rule preserves satisfiability (semantic soundness)
- Branching rules produce correct alternatives
- Non-branching rules produce single extended branch

---

### Phase 3: Branch Closure and Contradiction Detection

**Estimated effort**: 4-5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Define ClosureWitness type capturing why a branch closes
2. Implement efficient closure detection
3. Implement axiom-based closure (T(axiom) closes branch)
4. Connect to matchAxiom for axiom identification

**Files to create**:
- `Theories/Bimodal/Metalogic/Decidability/Closure.lean`

**Steps**:
1. Import Tableau and Automation.ProofSearch modules
2. Define ClosureWitness:
   ```lean
   inductive ClosureWitness (b : Branch) where
     | contradiction (φ : Formula)
         (hpos : SignedFormula.mk .pos φ ∈ b)
         (hneg : SignedFormula.mk .neg φ ∈ b) : ClosureWitness b
     | botPos (h : SignedFormula.mk .pos .bot ∈ b) : ClosureWitness b
     | axiomNeg (φ : Formula) (ax : Axiom φ)
         (h : SignedFormula.mk .neg φ ∈ b) : ClosureWitness b
   ```
3. Implement findClosure:
   ```lean
   def findClosure (b : Branch) : Option (ClosureWitness b)
   ```
4. Optimize closure detection using hash sets for large branches
5. Implement axiom closure using `matchAxiom`:
   ```lean
   def checkAxiomClosure (b : Branch) : Option (ClosureWitness b) :=
     b.findSome? fun sf =>
       if sf.sign = .neg then
         match matchAxiom sf.formula with
         | some ⟨_, wit⟩ => some (ClosureWitness.axiomNeg sf.formula wit _)
         | none => none
       else none
   ```

**Verification**:
- Closed branches are unsatisfiable
- Axiom closure correctly identifies TM axiom instances
- Contradiction detection is complete (finds all pairs)

---

### Phase 4: Saturation and Termination

**Estimated effort**: 6-8 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Define saturation (no applicable rules produce new formulas)
2. Implement termination measure (subformula complexity)
3. Prove tableau expansion terminates
4. Define fully expanded tableau type

**Files to create**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`

**Steps**:
1. Import Tableau and Closure modules
2. Define saturation predicate:
   ```lean
   def isSaturated (b : Branch) : Bool :=
     -- All rules that can be applied have been applied
     b.all fun sf =>
       (expandBranch [sf]).all fun b' =>
         b'.all fun sf' => b.contains sf'
   ```
3. Define tableau termination measure:
   ```lean
   def branchComplexity (b : Branch) : Nat :=
     b.foldl (fun acc sf => acc + sf.formula.complexity) 0

   def unexpandedComplexity (b : Branch) : Nat :=
     -- Sum of complexity of not-yet-expanded signed formulas
   ```
4. Define ExpandedTableau inductive type:
   ```lean
   inductive ExpandedTableau where
     | closed (b : Branch) (wit : ClosureWitness b)
     | open (b : Branch) (hsat : isSaturated b) (hopen : findClosure b = none)
   ```
5. Implement main expansion loop with fuel/termination proof:
   ```lean
   def expandToCompletion (b : Branch) : ExpandedTableau
   termination_by unexpandedComplexity b
   ```

**Verification**:
- Saturation is decidable
- Termination measure decreases with each non-saturating step
- Expansion eventually terminates for any input

---

### Phase 5: Proof Extraction

**Estimated effort**: 6-8 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Extract DerivationTree from closed tableau
2. Use matchAxiom for axiom witness extraction
3. Construct proof by combining closure reasons
4. Verify extracted proof is well-typed

**Files to create**:
- `Theories/Bimodal/Metalogic/Decidability/ProofExtraction.lean`

**Steps**:
1. Import all Decidability modules and ProofSystem
2. Define proof extraction from ClosureWitness:
   ```lean
   def extractProofFromClosure (φ : Formula) (wit : ClosureWitness b)
       (hroot : SignedFormula.mk .neg φ ∈ b) : DerivationTree [] φ
   ```
3. Handle each closure case:
   - `contradiction`: Use propositional reasoning
   - `botPos`: Use ex_falso axiom
   - `axiomNeg`: Use axiom constructor directly with witness
4. Implement proof combination for branching rules:
   ```lean
   def combineProofs (φ : Formula) (rule : TableauRule)
       (proofs : List (DerivationTree [] _)) : DerivationTree [] φ
   ```
5. Main extraction function:
   ```lean
   def tableauToProof (φ : Formula) (t : ExpandedTableau)
       (hclosed : t.matches .closed _ _) : DerivationTree [] φ
   ```

**Verification**:
- Extracted proof type-checks
- Proof corresponds to tableau structure
- All axiom witnesses are valid

---

### Phase 6: Countermodel Extraction

**Estimated effort**: 6-8 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Define finite countermodel structure
2. Extract model from open saturated branch
3. Prove model satisfies branch formulas
4. Prove model refutes original formula

**Files to create**:
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean`

**Steps**:
1. Import Saturation and Semantics modules
2. Define Countermodel structure:
   ```lean
   structure Countermodel (φ : Formula) where
     -- Use finite frame with Int time (simplified)
     frame : TaskFrame Int
     model : TaskModel frame
     history : WorldHistory frame
     time : Int
     timeDomain : history.domain time
     refutes : ¬truth_at model history time timeDomain φ
   ```
3. Extract finite frame from branch:
   ```lean
   def extractFrame (b : Branch) : TaskFrame Int :=
     -- Single world state (modal S5 simplification)
     -- Linear time structure from temporal formulas
   ```
4. Define valuation from branch membership:
   ```lean
   def extractValuation (b : Branch) (p : String) : Bool :=
     b.contains (SignedFormula.mk .pos (Formula.atom p))
   ```
5. Prove truth lemma for finite model:
   ```lean
   theorem branchTruthLemma (b : Branch) (φ : Formula)
       (hsat : isSaturated b) (hopen : findClosure b = none) :
       (SignedFormula.mk .pos φ ∈ b → truth_at _ _ _ _ φ) ∧
       (SignedFormula.mk .neg φ ∈ b → ¬truth_at _ _ _ _ φ)
   ```
6. Main extraction:
   ```lean
   def extractCountermodel (φ : Formula) (t : ExpandedTableau)
       (hopen : t.matches .open _ _ _) : Countermodel φ
   ```

**Verification**:
- Extracted model is well-formed
- Truth lemma holds for all branch formulas
- Model correctly refutes the original formula

---

### Phase 7: Decision Procedure Integration

**Estimated effort**: 4-5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Define DecisionResult type
2. Implement main decide function
3. Add proof search optimization layer
4. Integrate with existing search infrastructure

**Files to create**:
- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean`

**Steps**:
1. Import all Decidability modules
2. Define DecisionResult:
   ```lean
   inductive DecisionResult (φ : Formula) where
     | valid (proof : DerivationTree [] φ)
     | invalid (counter : Countermodel φ)
   ```
3. Implement optimized decision procedure:
   ```lean
   def decide (φ : Formula) : DecisionResult φ :=
     -- Optimization: try proof search first for shallow proofs
     match bounded_search_with_proof [] φ 5 with
     | (some proof, _, _) => DecisionResult.valid proof
     | (none, _, _) =>
         -- Full tableau decision
         let tableau := expandToCompletion [SignedFormula.mk .neg φ]
         match tableau with
         | .closed b wit => DecisionResult.valid (tableauToProof φ tableau _)
         | .open b hsat hopen => DecisionResult.invalid (extractCountermodel φ tableau _)
   ```
4. Add configurable search depth for optimization layer
5. Export convenient API:
   ```lean
   def isValid (φ : Formula) : Bool := decide φ matches .valid _
   def isSatisfiable (φ : Formula) : Bool := decide φ.neg matches .invalid _
   ```

**Verification**:
- Decision procedure terminates on all inputs
- Result is correct (valid iff formula is TM-valid)
- Optimization does not affect correctness

---

### Phase 8: Correctness Proofs

**Estimated effort**: 8-10 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Prove decision procedure soundness
2. Prove decision procedure completeness
3. Construct Decidable instance for validity
4. Connect to existing soundness theorem

**Files to create**:
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean`

**Steps**:
1. Import DecisionProcedure and Soundness modules
2. Prove soundness (valid result implies validity):
   ```lean
   theorem decide_sound (φ : Formula) :
       (h : decide φ = .valid proof) → valid φ :=
     fun h => soundness proof
   ```
3. Prove completeness (validity implies valid result):
   ```lean
   theorem decide_complete (φ : Formula) :
       valid φ → ∃ proof, decide φ = .valid proof
   ```
4. Prove countermodel correctness:
   ```lean
   theorem countermodel_refutes (φ : Formula) (c : Countermodel φ) :
       ¬valid φ :=
     fun hv => c.refutes (hv _ _ _ _ _ _)
   ```
5. Construct decidability instance:
   ```lean
   instance decidableValidity (φ : Formula) : Decidable (valid φ) :=
     match h : decide φ with
     | .valid proof => Decidable.isTrue (soundness proof)
     | .invalid counter => Decidable.isFalse (countermodel_refutes φ counter)
   ```
6. Add theorem connecting to semantic validity:
   ```lean
   theorem decidable_valid_iff_provable (φ : Formula) :
       valid φ ↔ Nonempty (DerivationTree [] φ)
   ```

**Verification**:
- All theorems compile without sorry
- Decidable instance works in #decide commands
- Correctness aligns with soundness theorem

---

### Phase 9: Testing and Validation

**Estimated effort**: 4-5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Test decision procedure on axiom schemata
2. Test on known invalid formulas
3. Verify countermodel construction
4. Performance benchmarks

**Files to create**:
- `BimodalTest/Metalogic/DecidabilityTest.lean`

**Steps**:
1. Create test module importing Decidability
2. Test all 14 TM axiom instances are decided valid:
   ```lean
   example : decide (prop_k_instance p q r) matches .valid _ := rfl
   example : decide (modal_t_instance p) matches .valid _ := rfl
   -- ... for all 14 axioms
   ```
3. Test known invalid formulas produce countermodels:
   ```lean
   example : decide (Formula.atom "p") matches .invalid _ := rfl
   example : decide (Formula.box (Formula.atom "p")) matches .invalid _ := rfl
   ```
4. Verify countermodel properties:
   ```lean
   #check (decide (Formula.atom "p")).2.refutes
   ```
5. Add performance benchmarks comparing to proof search:
   ```lean
   #time decide complexFormula  -- Compare with bounded_search
   ```
6. Test edge cases (empty formula, deeply nested, etc.)

**Verification**:
- All axioms are correctly identified as valid
- Invalid formulas produce meaningful countermodels
- Performance is acceptable for practical formulas

---

## Dependencies

### Internal Dependencies
- `Bimodal.Syntax.Formula` - Formula type with DecidableEq
- `Bimodal.ProofSystem.Axioms` - Axiom type with Type-based representation
- `Bimodal.ProofSystem.Derivation` - DerivationTree type
- `Bimodal.Semantics` - Truth semantics and validity
- `Bimodal.Automation.ProofSearch` - matchAxiom, bounded_search_with_proof
- `Bimodal.Metalogic.Soundness` - Soundness theorem

### External Dependencies
- `Mathlib.Data.List.Basic` - List operations
- `Mathlib.Data.Fintype.Basic` - Finite types for decidability
- `Mathlib.Algebra.Order.Group.Int` - Integer ordering

### Task Dependencies
- Task 260 (Proof Search) - COMPLETED - Provides Type-based Axiom and matchAxiom

---

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Termination complexity | High | Use fuel-based recursion initially, prove termination measure later |
| Proof term size | Medium | Cache intermediate proofs, consider lazy construction |
| Countermodel construction complexity | Medium | Start with simplified S5 single-world model |
| Modal S5 interactions | Medium | Leverage existing S5 axioms in proof extraction |
| Temporal-modal interaction | High | Carefully handle interaction axioms (MF, TF) in rules |

### Risk Details

**Termination Complexity**: Tableau termination for modal-temporal logics is non-trivial. Initial implementation uses explicit fuel bounds; later phases formalize the termination measure.

**Proof Term Size**: For complex formulas, extracted proof terms may be large. Mitigation: implement proof sharing/caching for common subproofs.

**S5 Simplification**: The S5 modal structure means all worlds are mutually accessible. This simplifies countermodel extraction to a single-world model for the modal component.

---

## Success Criteria

- [ ] `SignedFormula` and `Branch` types defined with `DecidableEq`
- [ ] Tableau rules implemented for all TM formula constructors
- [ ] Branch closure detection using `matchAxiom` for axioms
- [ ] Saturation detection with termination guarantee
- [ ] Proof extraction producing valid `DerivationTree`
- [ ] Countermodel extraction producing `Countermodel` witness
- [ ] Main `decide` function with `DecisionResult` return type
- [ ] `Decidable (valid φ)` instance constructed
- [ ] All 14 TM axiom schemata test as valid
- [ ] Known invalid formulas produce countermodels
- [ ] Performance acceptable for formulas up to complexity 50
- [ ] Zero compilation errors in Decidability module hierarchy
