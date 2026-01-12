# Research Report: Task #261

**Task**: Decidability - Implement decision procedures for TM logic
**Date**: 2026-01-11
**Focus**: Decidability algorithms, tableau methods, and finite model property for TM bimodal logic

## Summary

TM bimodal logic (S5 modal + linear temporal) is decidable via the finite model property and tableau methods. The existing ProofSearch infrastructure provides a strong foundation, but dedicated decision procedures require: (1) formal finite model property proofs, (2) tableau-based satisfiability checking, and (3) integration with the existing validity/semantic consequence framework.

## Findings

### 1. TM Logic Decidability Background

TM bimodal logic combines:
- **S5 modal logic** (metaphysical necessity): Known to be decidable (NP-complete for satisfiability)
- **Linear temporal logic** with past/future: Known to be decidable (PSPACE-complete)

The combination preserves decidability because:
1. S5's equivalence relation structure bounds modal branching
2. Linear temporal structure prevents exponential time branching
3. The interaction axioms (MF, TF) preserve finite model property

**Key Reference**: [Tableau Methods for Modal and Temporal Logics](https://link.springer.com/chapter/10.1007/978-94-017-1754-0_6) covers tableau methods for combined modal-temporal logics.

### 2. Existing Codebase Analysis

#### 2.1 Syntax (`Bimodal/Syntax/Formula.lean`)

The formula type already has decidable equality:
```lean
inductive Formula : Type where
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | all_past : Formula → Formula
  | all_future : Formula → Formula
  deriving Repr, DecidableEq, BEq, Hashable
```

Useful metrics for tableau termination:
- `complexity`: Total formula nodes
- `modalDepth`: Nesting level of box operators
- `temporalDepth`: Nesting level of temporal operators

#### 2.2 Semantics (`Bimodal/Semantics/`)

**Key definitions for decidability**:
- `valid`: Formula true in all models for all temporal types
- `satisfiable`: Context satisfiable in some model
- `semantic_consequence`: Semantic entailment

**Challenge**: Validity quantifies over ALL temporal types:
```lean
def valid (φ : Formula) : Prop :=
  ∀ (T : Type) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    (F : TaskFrame T) (M : TaskModel F) (τ : WorldHistory F)
    (t : T) (ht : τ.domain t), truth_at M τ t ht φ
```

For decidability, we need to reduce this to checking a finite model.

#### 2.3 Proof System (`Bimodal/ProofSystem/`)

14 axiom schemata + 3 inference rules (MP, Modal K, Temporal K).

The completeness infrastructure (`Bimodal/Metalogic/Completeness.lean`) provides:
- `Consistent`: Context consistency definition
- `MaximalConsistent`: Maximal consistent sets
- `lindenbaum`: Extension to maximal consistent sets (axiom)
- `provable_iff_valid`: Soundness + weak completeness (partial)

#### 2.4 Proof Search (`Bimodal/Automation/ProofSearch.lean`)

Existing infrastructure (1085 lines) provides:
- `bounded_search`: Depth-limited DFS
- `iddfs_search`: Iterative deepening DFS
- `bestFirst_search`: Priority queue search
- `matches_axiom`: 14 TM axiom schema matching
- Heuristic scoring and caching

**Gap**: Returns `Bool` (provable/not), not a formal decision procedure with completeness proof.

### 3. Finite Model Property

The finite model property (FMP) is the key to decidability:

**Theorem** (FMP for TM): If φ is satisfiable, then φ is satisfiable in a finite model of size bounded by f(|φ|).

For TM logic:
- **Modal S5 component**: Uses filtration with bound 2^|φ| states
- **Temporal component**: Uses unfolding with bound 2^|φ| time points
- **Combined**: Bounded by product of modal and temporal bounds

**Proof Approach** (to be formalized):
1. Start with infinite model satisfying φ
2. Apply modal filtration: quotient by modal equivalence
3. Apply temporal unraveling: extract finite time segment
4. Show resulting finite model still satisfies φ

### 4. Tableau Method for TM Logic

A tableau decision procedure systematically searches for a countermodel.

#### 4.1 Signed Formulas

```lean
inductive SignedFormula where
  | pos : Formula → SignedFormula  -- Formula asserted true
  | neg : Formula → SignedFormula  -- Formula asserted false
```

#### 4.2 Tableau Rules

**Propositional Rules**:
- `T ∧`: Split positive conjunction
- `F ∨`: Split negative disjunction
- `T →`: Branch (F antecedent or T consequent)
- `F →`: Non-branching (T antecedent and F consequent)

**Modal Rules** (S5-specific):
- `T □φ`: Add T φ to all accessible states
- `F □φ`: Create new state with F φ
- **S5 optimization**: All states mutually accessible

**Temporal Rules**:
- `T Gφ`: Add T φ at all future times
- `F Gφ`: Create new future time with F φ
- `T Hφ`: Add T φ at all past times
- `F Hφ`: Create new past time with F φ

#### 4.3 Closure and Saturation

A branch is **closed** if it contains both T p and F p for some atom p, or contains F ⊥.

A branch is **open** if it is saturated (all rules applied) and not closed.

**Key Property**: If all branches close, the formula is unsatisfiable. If any branch is open, it describes a countermodel.

### 5. Existing Formalizations in Lean

Several relevant formalizations exist:

1. **Wu & Goré**: [Verified Decision Procedures for Modal Logics](https://d-nb.info/1365997553/34) - Lean formalization of modal tableaux for K, KT, S4 with soundness, completeness, and termination proofs.

2. **Bentzen**: [Henkin-style completeness for S5](https://github.com/bbentzen/mpl/) - Lean 3 formalization of S5 completeness.

3. **PAL+S5 Formalization**: [Formalization-PAL](https://github.com/ljt12138/Formalization-PAL) - S5 completeness and automatic proof checking.

### 6. Mathlib Resources

Relevant Mathlib definitions:
- `Fintype.decidableForallFintype`: Decidability of ∀ over finite types
- `Fintype.decidableExistsFintype`: Decidability of ∃ over finite types
- `FirstOrder.Language.Theory.IsSatisfiable`: First-order satisfiability
- `Classical.dec`: Classical decidability

For our decision procedure, we need:
```lean
-- Target theorem
theorem decidable_validity : Decidable (valid φ) := ...

-- Via finite model property
theorem fmp : valid φ ↔ valid_in_finite_models φ := ...
theorem decidable_finite_validity : Decidable (valid_in_finite_models φ) := ...
```

### 7. Implementation Architecture

#### 7.1 Module Structure

```
Bimodal/Metalogic/Decidability/
├── FMP.lean              -- Finite model property proofs
├── Filtration.lean       -- Modal filtration construction
├── Tableau.lean          -- Tableau rules and closure
├── TableauTermination.lean -- Termination proofs
├── DecisionProcedure.lean  -- Main decision function
└── Correctness.lean      -- Soundness and completeness
```

#### 7.2 Type Definitions

```lean
-- Signed formulas for tableau
inductive Sign | pos | neg
structure SignedFormula := (sign : Sign) (formula : Formula)

-- Tableau branch (set of signed formulas)
def Branch := List SignedFormula

-- Tableau (tree of branches)
inductive Tableau
  | leaf : Branch → Tableau
  | branch : Branch → Tableau → Tableau → Tableau

-- Decision result with witness
inductive DecisionResult (φ : Formula)
  | valid : DerivationTree [] φ → DecisionResult φ
  | invalid : (F : TaskFrame Int) × TaskModel F × ... → DecisionResult φ
```

#### 7.3 Key Functions

```lean
-- Apply tableau rules exhaustively
def saturate : Branch → Tableau

-- Check if branch is closed
def isClosed : Branch → Bool

-- Check if tableau is closed (all branches closed)
def tableauClosed : Tableau → Bool

-- Decision procedure
def decide (φ : Formula) : DecisionResult φ :=
  let tableau := saturate [SignedFormula.neg φ]
  if tableauClosed tableau then
    DecisionResult.valid (extractProof tableau)
  else
    DecisionResult.invalid (extractCountermodel tableau)
```

### 8. Relationship to Task 260 (Proof Search)

Task 260 implements **proof search** (find derivation if exists).
Task 261 implements **decision procedure** (decide validity with proof/countermodel).

**Key differences**:
- Proof search may not terminate on invalid formulas
- Decision procedure always terminates with answer
- Decision procedure provides countermodel on failure

**Integration opportunity**: The tableau decision procedure can use proof search as a subroutine for attempting direct derivation before full tableau expansion.

### 9. Complexity Analysis

For TM logic:
- **Validity**: PSPACE-complete (inherits from temporal component)
- **Satisfiability**: PSPACE-complete (dual of validity)
- **Model size bound**: Exponential in formula size

Practical optimizations:
- Caching and memoization
- Formula subformula closure
- Optimized S5 handling (single equivalence class)
- Early termination on closure detection

## Recommendations

### Phase 1: Finite Model Property (20-25 hours)

1. Define finite TaskFrame restriction
2. Prove modal filtration preserves S5 properties
3. Prove temporal unraveling produces finite model
4. Combine into FMP theorem
5. Connect FMP to polymorphic validity

### Phase 2: Tableau Implementation (15-20 hours)

1. Define SignedFormula and Branch types
2. Implement tableau rules for all formula constructors
3. Implement closure detection
4. Prove rule soundness (each rule preserves satisfiability)
5. Connect to existing Formula structure

### Phase 3: Termination and Completeness (10-15 hours)

1. Define termination measure (subformula count + modal/temporal depth)
2. Prove rules decrease measure or reach saturation
3. Prove completeness (open saturated branch ⇒ model exists)
4. Derive decidability from termination + completeness

### Phase 4: Decision Procedure Integration (8-10 hours)

1. Implement `decide : Formula → DecisionResult`
2. Extract proof term from closed tableau
3. Extract finite countermodel from open branch
4. Add optimizations (caching, early termination)

### Phase 5: Testing and Validation (5-8 hours)

1. Test on TM axiom schemata (should be valid)
2. Test on known invalid formulas (should produce countermodels)
3. Compare with proof search results
4. Performance benchmarks

## References

### Academic Sources
- Gore, R. (1999). [Tableau Methods for Modal and Temporal Logics](https://link.springer.com/chapter/10.1007/978-94-017-1754-0_6)
- Wolper, P. [The Tableau Method for Temporal Logic](https://orbi.uliege.be/bitstream/2268/179456/1/WOL85%20Tableau.pdf)
- Wu, M. [Verified Decision Procedures for Modal Logics](https://d-nb.info/1365997553/34)
- Bentzen, B. [A Henkin-style completeness proof for S5](https://link.springer.com/chapter/10.1007/978-3-030-89391-0_25)

### Lean Formalizations
- [Bentzen's S5 in Lean](https://github.com/bbentzen/mpl/)
- [PAL + S5 Formalization](https://github.com/ljt12138/Formalization-PAL)

### Codebase Files
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Syntax/Formula.lean` - Formula syntax
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/` - Semantics module
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness.lean` - Completeness infrastructure
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Automation/ProofSearch.lean` - Proof search

## Next Steps

1. Create implementation plan based on this research
2. Begin Phase 1 (FMP) with modal filtration definition
3. Coordinate with Task 260 to ensure proof search integration
4. Consider porting verified tableau approach from Wu & Goré
