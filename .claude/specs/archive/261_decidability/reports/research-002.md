# Research Report: Task #261 - Type-Based Axiom Implications for Decidability

**Task**: Decidability - Implement decision procedures for TM logic
**Date**: 2026-01-12
**Focus**: How the Type-based axiom representation (from task 260) affects proof search, decidability procedures, and new patterns for decision procedures in Lean 4

## Summary

The completion of task 260 (refactoring `Axiom : Formula -> Prop` to `Axiom : Formula -> Type`) provides significant advantages for decidability implementation. This change enables:

1. **Direct proof term construction** from search procedures
2. **Decidable equality** on axiom witnesses via `deriving DecidableEq`
3. **Pattern matching** to return actual axiom witnesses (not just Bool)
4. **Unified decision procedure** that returns `DecisionResult` with proof terms

This research analyzes the implications and identifies new patterns available for implementing verified decision procedures.

---

## Part 1: Changes Introduced by Task 260

### 1.1 Axiom Type Change

**Before (Prop)**:
```lean
inductive Axiom : Formula → Prop where
  | prop_k (φ ψ χ : Formula) : Axiom ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))
  -- ... 14 constructors
```

**After (Type)**:
```lean
inductive Axiom : Formula → Type where
  | prop_k (φ ψ χ : Formula) : Axiom ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))
  -- ... 14 constructors
  deriving Repr
```

### 1.2 Key Capabilities Unlocked

| Capability | Before (Prop) | After (Type) |
|------------|---------------|--------------|
| Pattern match to produce data | No | Yes |
| Return axiom witness from functions | No | Yes |
| `DecidableEq` derivable | No | Yes |
| `Repr` derivable | No | Yes |
| Store in computational data structures | No (erasure) | Yes |
| Proof irrelevance | Yes | No (but unused) |

### 1.3 New Functions Added

**`matchAxiom : Formula → Option (Sigma Axiom)`**

This function matches a formula against all 14 axiom patterns and returns the actual axiom witness:

```lean
def matchAxiom (φ : Formula) : Option (Sigma Axiom) :=
  match φ with
  | .imp lhs rhs =>
      -- ex_falso: ⊥ → φ
      (if lhs = .bot then some ⟨_, Axiom.ex_falso rhs⟩ else none)
      <|> (match lhs, rhs with
           | .box phi, phi' =>
               if phi = phi' then some ⟨_, Axiom.modal_t phi⟩ else none
           | _, _ => none)
      -- ... 12 more axiom patterns
  | _ => none
```

**`bounded_search_with_proof : Context → Formula → Nat → Option (DerivationTree Γ φ)`**

Returns actual proof terms, not just `Bool`:

```lean
def bounded_search_with_proof (Γ : Context) (φ : Formula) (depth : Nat)
    : Option (DerivationTree Γ φ) × Visited × Nat := ...
```

---

## Part 2: Implications for Decidability Procedures

### 2.1 Decision Procedure Return Types

**Old Approach (Bool-based)**:
```lean
-- Returns Bool, no proof witness
def decide_valid (φ : Formula) : Bool :=
  let (found, _, _, _, _) := search [] φ
  found
```

**New Approach (Witness-based)**:
```lean
-- Returns proof term or countermodel
inductive DecisionResult (φ : Formula) where
  | valid : DerivationTree [] φ → DecisionResult φ
  | invalid : Countermodel φ → DecisionResult φ

def decide (φ : Formula) : DecisionResult φ := ...
```

The Type-based axiom enables `DecisionResult.valid` to return an actual `DerivationTree`, not just assert existence.

### 2.2 Proof Term Construction Benefits

**For Validity Proofs**:
When the tableau closes (formula is valid), we can extract an actual `DerivationTree`:

```lean
def extractProof (tableau : Tableau) (hclosed : tableauClosed tableau) : DerivationTree [] φ :=
  -- Pattern match on closed tableau structure
  -- Use matchAxiom to get axiom witnesses
  -- Construct DerivationTree via axiom, modus_ponens, necessitation rules
```

**For Countermodel Construction**:
When the tableau has an open branch, we extract a finite countermodel:

```lean
def extractCountermodel (tableau : Tableau) (hopen : hasOpenBranch tableau) : Countermodel φ :=
  -- Open branch describes satisfying assignment
  -- Construct finite TaskFrame and valuation
```

### 2.3 Decidability Instance Construction

With Type-based axioms, we can construct a proper `Decidable` instance:

```lean
instance decideValidity (φ : Formula) : Decidable (valid φ) :=
  match decide φ with
  | .valid proof => Decidable.isTrue (soundness proof)
  | .invalid counter => Decidable.isFalse (countermodel_refutes counter)
```

This requires:
1. **Soundness theorem**: `DerivationTree [] φ → valid φ` (already exists)
2. **Countermodel refutation**: `Countermodel φ → ¬valid φ` (to be implemented)

---

## Part 3: Tableau Method Integration

### 3.1 Signed Formula Tableau with Proof Terms

The tableau method naturally produces proof terms when combined with Type-based axioms:

```lean
inductive Sign | pos | neg

structure SignedFormula where
  sign : Sign
  formula : Formula
  deriving DecidableEq  -- Enabled by Formula DecidableEq

def Branch := List SignedFormula

inductive TableauResult where
  | closed : Branch → ClosureWitness → TableauResult
  | open : Branch → SaturationWitness → TableauResult
```

### 3.2 Closure Witness Structure

When a branch closes, we can witness the closure:

```lean
inductive ClosureWitness where
  | contradiction : (φ : Formula) → (pos φ ∈ branch) → (neg φ ∈ branch) → ClosureWitness
  | axiomMatch : (φ : Formula) → Axiom φ → (neg φ ∈ branch) → ClosureWitness
  | botPos : (pos .bot ∈ branch) → ClosureWitness
```

The `axiomMatch` constructor now carries an actual `Axiom φ` witness (not just a proof of `Axiom φ` existence).

### 3.3 Proof Extraction from Closed Tableau

```lean
def tableauToProof (φ : Formula) (t : Tableau) (hclosed : allBranchesClosed t) : DerivationTree [] φ :=
  -- For each closed branch, extract the reason for closure
  -- Combine using modus ponens and axiom rules
  -- The key insight: axiom witnesses from matchAxiom can be directly used
  match t.closureWitness with
  | .axiomMatch ψ axiomWit _ =>
      -- Use the actual Axiom witness in DerivationTree.axiom constructor
      DerivationTree.axiom [] ψ axiomWit
  | ...
```

---

## Part 4: Integration with Proof Search

### 4.1 Proof Search as Subsystem

The proof search from task 260 can serve as an optimization layer for decidability:

```lean
def decide_optimized (φ : Formula) : DecisionResult φ :=
  -- Try direct proof search first (fast for axioms and simple proofs)
  match bounded_search_with_proof [] φ 10 with
  | (some proof, _, _) => DecisionResult.valid proof
  | (none, _, _) =>
      -- Fall back to full tableau decision procedure
      decide_tableau φ
```

### 4.2 Bidirectional Proof Construction

The Type-based axiom enables bidirectional proof construction:

**Forward (axiom-driven)**:
```lean
-- Start from axiom, build up via modus ponens
let axiomProof := DerivationTree.axiom [] φ (matchAxiom φ).get!.2
```

**Backward (goal-driven)**:
```lean
-- Start from goal, decompose via tableau
let goals := tableauExpand φ
-- Recursively prove subgoals, combine into proof term
```

### 4.3 Proof Term Caching

Since `Axiom : Type`, we can cache proof terms efficiently:

```lean
-- Cache indexed by (Context, Formula) returning actual DerivationTree
abbrev ProofTermCache := Std.HashMap (Context × Formula) (DerivationTree ...)
```

This is not possible with `Axiom : Prop` due to proof erasure.

---

## Part 5: New Patterns for Decidability

### 5.1 Pattern: Witnessed Decision

Instead of returning `Bool` and separately proving correctness:

```lean
-- Old pattern
def decide_old : Bool := ...
theorem decide_old_correct : decide_old = true ↔ valid φ := ...
```

Use a witnessed decision:

```lean
-- New pattern with Type-based axiom
def decide_witnessed : DecisionResult φ :=
  if let some ⟨_, wit⟩ := matchAxiom φ then
    DecisionResult.valid (DerivationTree.axiom [] φ wit)
  else
    -- tableau expansion
```

### 5.2 Pattern: Incremental Proof Construction

Build proofs incrementally during search:

```lean
structure SearchState where
  partialProof : Option (PartialDerivation)  -- Type-based, can store
  goals : List Formula
  visited : Visited

def searchStep (state : SearchState) : SearchState × Option (DerivationTree ...) :=
  -- Each step may complete a proof fragment
  -- Combine fragments using modus ponens witnesses
```

### 5.3 Pattern: Decidable Subformula Property

The subformula property is decidable with Type-based equality:

```lean
def subformulas (φ : Formula) : List Formula := ...

instance : DecidablePred (fun ψ => ψ ∈ subformulas φ) :=
  fun ψ => List.decidableMem ψ (subformulas φ)
```

This enables efficient tableau termination checks.

### 5.4 Pattern: Finite Model Property with Witnesses

The FMP proof can produce finite models as data:

```lean
structure FiniteModel (φ : Formula) where
  worlds : Fin n  -- Finite world set
  relation : Fin n → Fin n → Bool  -- Decidable accessibility
  valuation : Fin n → String → Bool  -- Decidable valuation
  satisfies : FiniteModel.satisfies this φ  -- Satisfaction witness
```

---

## Part 6: Implementation Recommendations

### 6.1 Updated Architecture

Based on the Type-based axiom change, the decidability module structure should be:

```
Bimodal/Metalogic/Decidability/
├── SignedFormula.lean      -- SignedFormula type with DecidableEq
├── Tableau.lean            -- Tableau rules returning witnesses
├── Closure.lean            -- Branch closure with ClosureWitness
├── Saturation.lean         -- Saturation detection
├── ProofExtraction.lean    -- Extract DerivationTree from closed tableau
├── CountermodelExtraction.lean  -- Extract finite model from open branch
├── DecisionProcedure.lean  -- Main decide function returning DecisionResult
└── Correctness.lean        -- Soundness and completeness proofs
```

### 6.2 Key Type Definitions

```lean
-- Decision result with witnesses
inductive DecisionResult (φ : Formula) where
  | valid (proof : DerivationTree [] φ)
  | invalid (counter : Countermodel φ)

-- Countermodel structure (for invalid formulas)
structure Countermodel (φ : Formula) where
  frame : TaskFrame Int  -- Finite temporal frame
  model : TaskModel frame
  history : WorldHistory frame
  time : Int
  timeDomain : history.domain time
  refutes : ¬truth_at model history time timeDomain φ

-- Tableau node with witness tracking
structure TableauNode where
  branch : Branch
  status : NodeStatus
  witness : Option ClosureWitness  -- Track how/why branch closed
```

### 6.3 Integration Points

1. **With ProofSearch**: Use `bounded_search_with_proof` for quick validity checks
2. **With Soundness**: Leverage existing `axiom_valid` lemmas for proof term validation
3. **With Semantics**: Use existing `truth_at` for countermodel construction

### 6.4 Phased Implementation

**Phase 1**: Define `SignedFormula`, `Branch`, `DecisionResult` types
- Leverage `DecidableEq` from Type-based design

**Phase 2**: Implement tableau rules with witness tracking
- Each rule produces `ClosureWitness` when applicable

**Phase 3**: Implement proof extraction
- Use `matchAxiom` for axiom identification
- Construct `DerivationTree` from closure witnesses

**Phase 4**: Implement countermodel extraction
- Convert open branch to finite model
- Prove model refutes formula

**Phase 5**: Prove decidability instance
- Connect `DecisionResult` to `Decidable (valid φ)`

---

## Part 7: Risks and Mitigations

### 7.1 Risk: Proof Term Size

**Risk**: Proof terms may be large for complex formulas.

**Mitigation**:
- Use lazy proof term construction
- Implement proof compression (share common subproofs)
- Optional: return `Option (DerivationTree ...)` with size threshold

### 7.2 Risk: Termination Complexity

**Risk**: Tableau termination proofs may be complex.

**Mitigation**:
- Use subformula complexity as termination measure
- Leverage existing `Formula.complexity` function
- The `DecidableEq` on formulas ensures termination checking is decidable

### 7.3 Risk: Countermodel Construction Complexity

**Risk**: Finite countermodel construction may be intricate.

**Mitigation**:
- Start with simple frame (linear time Int)
- Use existing `TaskFrame` infrastructure
- Countermodel only needs to refute single formula (minimal)

---

## Conclusion

The Type-based axiom refactor from task 260 significantly improves the foundation for decidability implementation:

1. **Direct witness construction**: `matchAxiom` returns actual axiom witnesses
2. **Proof term output**: `bounded_search_with_proof` returns `DerivationTree`
3. **Decidable equality**: Enables efficient tableau closure detection
4. **Data-carrying decisions**: `DecisionResult` can hold proof terms

The recommended approach:
1. Leverage the existing proof search as an optimization layer
2. Implement tableau rules with witness tracking
3. Use `matchAxiom` for proof extraction from closed tableaux
4. Define `Countermodel` structure for refutation witnesses
5. Construct `Decidable (valid φ)` from `DecisionResult`

Estimated effort: 40-50 hours (reduced from original 40-60 due to existing infrastructure)

---

## References

### Codebase Files
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` - Type-based axiom definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Derivation.lean` - DerivationTree definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Automation/ProofSearch.lean` - matchAxiom and proof search
- `/home/benjamin/Projects/ProofChecker/.claude/specs/260_proof_search/reports/research-004.md` - Axiom refactor analysis

### Task Context
- Task 260 (Proof Search): Completed the Axiom Prop->Type refactor
- Task 261 (Decidability): This task - implementing decision procedures

### Lean 4 / Mathlib References
- `Mathlib.Tactic.ITauto.Proof` - ITauto's proof term type (for pattern reference)
- `Fintype.decidableForallFintype` - Decidability of ∀ over finite types
- `Fintype.decidableExistsFintype` - Decidability of ∃ over finite types

### Academic References
- Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
- Wu, M. Verified Decision Procedures for Modal Logics (Lean formalization)
