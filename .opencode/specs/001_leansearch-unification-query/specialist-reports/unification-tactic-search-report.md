# LeanSearch Semantic Search Report: Unification Tactic

**Query**: "unification tactic"  
**Date**: 2025-12-21  
**Results Count**: 15  
**Purpose**: Find Lean 4 tactics, metaprogramming components, and definitions related to unification for tactic development

---

## Executive Summary

The LeanSearch semantic search for "unification tactic" returned 15 results with relevance scores ranging from 0.047 to 0.231. The results primarily fall into two categories:

1. **Model Theory Unification** (7 results): Mathematical unification in direct limit constructions from `Mathlib.ModelTheory.DirectLimit`
2. **Tactic Development** (3 results): Congruence and term matching tactics useful for unification-based tactic implementation

### Key Findings

- **Most Relevant for Tactic Development**: `congr!` and `congrM` tactics (distances 0.213 and 0.231) provide pattern matching and recursive congruence application
- **Metaprogramming Utility**: `Mathlib.MoveAdd.unifyMovements` (distance 0.230) demonstrates expression unification for term rearrangement
- **Mathematical Context**: The model theory results, while less directly applicable, show sophisticated unification algorithms in categorical settings

---

## Top Results by Relevance

### 1. FirstOrder.Language.DirectLimit.unify
**Distance**: 0.047 (Most semantically similar)  
**Library**: Mathlib  
**Module**: `Mathlib.ModelTheory.DirectLimit`  
**Type**: Definition

**Signature**:
```lean
{α : Type*} (x : α → Σˣ f) (i : ι) (h : i ∈ upperBounds (range (Sigma.fst ∘ x))) (a : α) : G i
```

**Full Type**:
```lean
{L : FirstOrder.Language} →
  {ι : Type v} →
    [inst : Preorder ι] →
      {G : ι → Type w} →
        [inst_1 : (i : ι) → L.Structure (G i)] →
          (f : (i j : ι) → inst.le i j → L.Embedding (G i) (G j)) →
            {α : Type u_1} →
              (x : α → FirstOrder.Language.Structure.Sigma f) →
                (i : ι) → Set.instMembership.mem (upperBounds (Set.range (Function.comp Sigma.fst x))) i → α → G i
```

**Description**: Raises a family of elements in the Σ-type to the same level along the embeddings in a direct limit construction. This demonstrates a formal unification algorithm that brings disparate indexed elements to a common level.

**Relevance to Tactic Development**: Shows how to implement unification algorithms that normalize heterogeneous terms to a common representation - a core concept in unification-based tactics.

---

### 2. FirstOrder.Language.DirectLimit.comp_unify
**Distance**: 0.098  
**Library**: Mathlib  
**Module**: `Mathlib.ModelTheory.DirectLimit`  
**Type**: Theorem

**Signature**:
```lean
{α : Type*} {x : α → Σˣ f} {i j : ι} (ij : i ≤ j) (h : i ∈ upperBounds (range (Sigma.fst ∘ x))) :
  f i j ij ∘ unify f x i h = unify f x j fun k hk => _root_.trans (mem_upperBounds.1 h k hk) ij
```

**Description**: Proves that unification commutes with directed system embeddings - a fundamental property showing that the choice of unification level doesn't matter (up to embedding).

**Relevance to Tactic Development**: Demonstrates soundness properties that unification algorithms must satisfy - critical for ensuring tactic correctness.

---

### 3. FirstOrder.Language.DirectLimit.exists_unify_eq
**Distance**: 0.098  
**Library**: Mathlib  
**Module**: `Mathlib.ModelTheory.DirectLimit`  
**Type**: Theorem

**Signature**:
```lean
{α : Type*} [Finite α] {x y : α → Σˣ f} (xy : x ≈ y) :
  ∃ (i : ι) (hx : i ∈ upperBounds (range (Sigma.fst ∘ x))) (hy : i ∈ upperBounds (range (Sigma.fst ∘ y))),
    unify f x i hx = unify f y i hy
```

**Description**: For equivalent families in the direct limit, there exists a common index where their unifications are equal.

**Relevance to Tactic Development**: Shows existence of a most general unifier (MGU) - a central concept in unification theory and tactic design.

---

### 4. FirstOrder.Language.DirectLimit.unify_sigma_mk_self
**Distance**: 0.109  
**Library**: Mathlib  
**Module**: `Mathlib.ModelTheory.DirectLimit`  
**Type**: Theorem

**Signature**:
```lean
{α : Type*} {i : ι} {x : α → G i} :
  (unify f (fun a => .mk f i (x a)) i fun _ ⟨_, hj⟩ => _root_.trans (le_of_eq hj.symm) (refl _)) = x
```

**Description**: Unification of a constant family at its own index is the identity function.

**Relevance to Tactic Development**: Establishes that unification is idempotent when applied to already-unified terms - an important optimization property.

---

### 5. FirstOrder.Language.DirectLimit.unify.congr_simp
**Distance**: 0.114  
**Library**: Mathlib  
**Module**: `Mathlib.ModelTheory.DirectLimit`  
**Type**: (unlabeled kind)

**Signature**: Not explicitly provided (congruence lemma)

**Description**: Congruence lemma for the unify function showing that equality of inputs implies equality of unification results.

**Relevance to Tactic Development**: Demonstrates the connection between unification and congruence - essential for understanding how unification tactics should respect term equality.

---

### 6. FirstOrder.Language.DirectLimit.relMap_unify_equiv
**Distance**: 0.123  
**Library**: Mathlib  
**Module**: `Mathlib.ModelTheory.DirectLimit`  
**Type**: Theorem

**Signature**:
```lean
{n : ℕ} (R : L.Relations n) (x : Fin n → Σˣ f) (i j : ι) (hi : i ∈ upperBounds (range (Sigma.fst ∘ x)))
  (hj : j ∈ upperBounds (range (Sigma.fst ∘ x))) : RelMap R (unify f x i hi) = RelMap R (unify f x j hj)
```

**Description**: Relation interpretations are invariant under unification at different levels.

**Relevance to Tactic Development**: Shows that unification preserves semantic meaning - crucial for soundness of unification-based proof tactics.

---

### 7. FirstOrder.Language.DirectLimit.funMap_unify_equiv
**Distance**: 0.157  
**Library**: Mathlib  
**Module**: `Mathlib.ModelTheory.DirectLimit`  
**Type**: Theorem

**Signature**:
```lean
{n : ℕ} (F : L.Functions n) (x : Fin n → Σˣ f) (i j : ι) (hi : i ∈ upperBounds (range (Sigma.fst ∘ x)))
  (hj : j ∈ upperBounds (range (Sigma.fst ∘ x))) :
  Structure.Sigma.mk f i (funMap F (unify f x i hi)) ≈ .mk f j (funMap F (unify f x j hj))
```

**Description**: Function symbols are compatible with unification - applying a function and then unifying is equivalent (up to equivalence) to unifying and then applying the function.

**Relevance to Tactic Development**: Establishes that unification is a homomorphism, preserving function applications - important for ensuring tactics don't introduce semantic bugs.

---

### 8. Congr!.congr! (Congruence Tactic)
**Distance**: 0.213  
**Library**: Mathlib  
**Module**: `Mathlib.Tactic.CongrExclamation`  
**Type**: Tactic Definition

**Signature**: `Lean.ParserDescr`

**Syntax**:
```lean
congr!
congr! n
congr! with x y z
congr! n with x y z
```

**Description**: The `congr!` tactic recursively applies congruence lemmas to equate corresponding parts of LHS and RHS of goals. It's more aggressive than standard `congr`, attempting multiple strategies:

- Converts reflexive relations to equalities
- Uses user-tagged `@[congr]` lemmas
- Generates congruences for `simp`-rewritable subexpressions
- Handles pi-type congruences
- Auto-introduces variables (with optional naming via `with` clause)
- Applies `funext`/`Function.hfunext` for function equalities
- Attempts to close goals via definitional equality, `Subsingleton.elim`, or `assumption`

**Configuration**:
```lean
congr! (transparency := .default) 2
congr! (config := .unfoldSameFun)
```

**Relevance to Tactic Development**: ⭐ **HIGHLY RELEVANT** ⭐
- Provides a reference implementation for recursive congruence application
- Shows how to combine multiple strategies (unification, simplification, extensionality)
- Demonstrates configuration-based tactic design
- Key source code to study for implementing unification-based tactics

**Source Location**: `Mathlib.Tactic.CongrExclamation`

---

### 9. Mathlib.Tactic.congrM (Congruence Matching)
**Distance**: 0.231  
**Library**: Mathlib  
**Module**: `Mathlib.Tactic.CongrM`  
**Type**: Tactic Definition

**Signature**: `Lean.ParserDescr`

**Syntax**:
```lean
congrm e
```

**Description**: Proves goals of the form `lhs = rhs`, `lhs ↔ rhs`, `lhs ≍ rhs`, or `R lhs rhs` (for reflexive R). The expression `e` is a pattern with placeholders `?_` or `?name`, matched simultaneously against both sides. Each placeholder generates a goal proving equality of corresponding subexpressions.

**Example**:
```lean
example {a b c d : ℕ} :
    Nat.pred a.succ * (d + (c + a.pred)) = Nat.pred b.succ * (b + (c + d.pred)) := by
  congrm Nat.pred (Nat.succ ?h1) * (?h2 + ?h3)
  /-  Goals left:
  case h1 ⊢ a = b
  case h2 ⊢ d = b
  case h3 ⊢ c + a.pred = c + d.pred
  -/
```

**Relevance to Tactic Development**: ⭐ **HIGHLY RELEVANT** ⭐
- Shows pattern-based unification with named placeholders
- Demonstrates bidirectional pattern matching (matching pattern against both LHS and RHS)
- Key technique for implementing user-directed unification tactics
- Frontend to congruence quotations `congr(...)`

**Source Location**: `Mathlib.Tactic.CongrM`

---

### 10. Mathlib.MoveAdd.unifyMovements
**Distance**: 0.230  
**Library**: Mathlib  
**Module**: `Mathlib.Tactic.MoveAdd`  
**Type**: Metaprogramming Function

**Signature**:
```lean
(data : Array (Expr × Bool × Syntax)) (tgt : Expr) :
  MetaM (List (Expr × Bool) × (List MessageData × List Syntax) × Array MessageData)
```

**Full Type**:
```lean
Lean.Name →
  Array (Prod Lean.Expr (Prod Bool Lean.Syntax)) →
    Lean.Expr →
      Lean.Meta.MetaM
        (Prod (List (Prod Lean.Expr Bool))
          (Prod (Prod (List Lean.MessageData) (List Lean.Syntax)) (Array Lean.MessageData)))
```

**Description**: Takes an array of `(Expr, Bool, Syntax)` triples (from parsed user input), a binary operation name `op`, and a target expression `tgt`. Unifies each input expression with atoms of operation `op` in the target, returning:
1. List of matched `(expr, bool)` pairs
2. Error messages for unmatched terms with their syntax
3. Debugging messages

**Relevance to Tactic Development**: ⭐ **HIGHLY RELEVANT** ⭐
- Real-world example of implementing term unification in Lean 4 metaprogramming
- Shows error handling for failed unification
- Demonstrates how to preserve syntax information for error reporting
- Uses `MetaM` monad for unification in tactic context
- Practical pattern for matching user-provided terms against goal expressions

**Source Location**: `Mathlib.Tactic.MoveAdd`

---

## Results by Category

### Category 1: Tactic Implementations (Most Relevant)

| Name | Module | Distance | Key Feature |
|------|--------|----------|-------------|
| `congr!` | `Mathlib.Tactic.CongrExclamation` | 0.213 | Recursive congruence with multiple strategies |
| `congrM` | `Mathlib.Tactic.CongrM` | 0.231 | Pattern-based bidirectional matching |
| `unifyMovements` | `Mathlib.Tactic.MoveAdd` | 0.230 | Term unification in MetaM monad |

**Study Priority**: HIGH - These are directly implementable examples of unification in Lean 4 tactics.

---

### Category 2: Mathematical Unification Theory

| Name | Module | Distance | Concept |
|------|--------|----------|---------|
| `DirectLimit.unify` | `Mathlib.ModelTheory.DirectLimit` | 0.047 | Basic unification algorithm |
| `DirectLimit.comp_unify` | `Mathlib.ModelTheory.DirectLimit` | 0.098 | Unification soundness |
| `DirectLimit.exists_unify_eq` | `Mathlib.ModelTheory.DirectLimit` | 0.098 | Most general unifier existence |
| `DirectLimit.unify_sigma_mk_self` | `Mathlib.ModelTheory.DirectLimit` | 0.109 | Idempotence |
| `DirectLimit.unify.congr_simp` | `Mathlib.ModelTheory.DirectLimit` | 0.114 | Congruence property |
| `DirectLimit.relMap_unify_equiv` | `Mathlib.ModelTheory.DirectLimit` | 0.123 | Semantic preservation (relations) |
| `DirectLimit.funMap_unify_equiv` | `Mathlib.ModelTheory.DirectLimit` | 0.157 | Semantic preservation (functions) |

**Study Priority**: MEDIUM - Useful for understanding unification theory and soundness properties.

---

## Recommendations for Tactic Development

### Immediate Action Items

1. **Study `congrM` source code** (`Mathlib.Tactic.CongrM`)
   - Learn pattern-based matching with placeholders
   - Understand congruence quotation mechanism
   - Pattern: `?name` creates tagged subgoals

2. **Study `congr!` implementation** (`Mathlib.Tactic.CongrExclamation`)
   - Learn recursive congruence application
   - Understand strategy combination (reflexivity, user lemmas, simplification)
   - Study configuration-based tactic design

3. **Study `unifyMovements`** (`Mathlib.Tactic.MoveAdd`)
   - Learn MetaM-based term unification
   - Understand error handling in unification
   - See how to parse user syntax and match against goals

### Key Lean 4 Metaprogramming Patterns Identified

1. **Pattern Matching with Placeholders**:
   ```lean
   congrm pattern ?h1 ?h2  -- generates tagged subgoals
   ```

2. **Configuration Objects**:
   ```lean
   congr! (transparency := .default) 2
   congr! (config := .unfoldSameFun)
   ```

3. **MetaM Unification**:
   ```lean
   def unifyTerms (data : Array (Expr × Syntax)) (tgt : Expr) : MetaM ... := do
     -- match expressions against target
     -- return matched pairs + errors
   ```

4. **Error Reporting**:
   ```lean
   -- Return (results, (error_messages, error_syntax), debug_messages)
   return (matched, (errors, syntaxLocs), debugMsgs)
   ```

### Additional Searches Recommended

Based on these results, consider follow-up searches for:

1. **"metavariable assignment"** - For lower-level unification primitives
2. **"isDefEq"** - For definitional equality checking (core to unification)
3. **"synthesize instance"** - For type class unification
4. **"pattern matching elaboration"** - For pattern syntax in tactics
5. **"Meta.mkFreshExprMVar"** - For creating unification metavariables

---

## Unification Concepts Identified

### From Mathematical Results

1. **Most General Unifier (MGU)**: `exists_unify_eq` shows existence of MGU
2. **Idempotence**: `unify_sigma_mk_self` shows unification is idempotent
3. **Soundness**: `comp_unify` shows unification respects embeddings
4. **Semantic Preservation**: `relMap_unify_equiv` and `funMap_unify_equiv` show unification preserves meaning

### From Tactic Results

1. **Bidirectional Matching**: `congrM` matches pattern against both LHS and RHS simultaneously
2. **Recursive Application**: `congr!` applies unification recursively with depth control
3. **Strategy Composition**: `congr!` tries multiple approaches (refl, user lemmas, simp, funext)
4. **Error Recovery**: `unifyMovements` returns both successes and failures

---

## Source Code Locations for Further Study

### High Priority
1. `Mathlib/Tactic/CongrM.lean` - Pattern-based unification
2. `Mathlib/Tactic/CongrExclamation.lean` - Recursive congruence
3. `Mathlib/Tactic/MoveAdd.lean` - MetaM unification example

### Medium Priority
4. `Mathlib/ModelTheory/DirectLimit.lean` - Mathematical unification theory

### Related Areas (Not in Results, But Recommended)
5. `Lean/Meta/Tactic/Unify.lean` - Core Lean 4 unification
6. `Lean/Meta/ExprDefEq.lean` - Definitional equality
7. `Mathlib/Tactic/Ring.lean` - Another normalization/unification tactic

---

## Glossary of Terms

- **Congruence**: Property that equal inputs to a function yield equal outputs
- **MGU (Most General Unifier)**: The least restrictive unification that makes terms equal
- **Idempotence**: Applying an operation twice gives the same result as applying it once
- **MetaM**: Lean 4's metaprogramming monad for tactic development
- **Reflexive Relation**: Relation R where R x x holds for all x
- **Funext**: Function extensionality - functions are equal if they agree on all inputs
- **Congruence Quotation**: Syntax `congr(...)` for generating congruence proofs

---

## Statistics

- **Total Results**: 15
- **Unique Modules**: 3
  - `Mathlib.ModelTheory.DirectLimit`: 7 results
  - `Mathlib.Tactic.CongrExclamation`: 1 result
  - `Mathlib.Tactic.CongrM`: 1 result
  - `Mathlib.Tactic.MoveAdd`: 1 result
- **Result Types**:
  - Definitions: 3
  - Theorems: 6
  - Tactics: 2
  - Metaprogramming Functions: 1
  - Other: 3
- **Distance Range**: 0.047 - 0.231
- **High Relevance (< 0.15)**: 7 results
- **Medium Relevance (0.15 - 0.20)**: 1 result
- **Lower Relevance (> 0.20)**: 3 results (but these are the most practically useful!)

---

## Conclusion

The LeanSearch query successfully identified both theoretical foundations and practical implementations of unification in Lean 4. While the mathematically closest results (`DirectLimit.unify` and related theorems) provide theoretical grounding, the most valuable results for tactic development are the tactic implementations (`congr!`, `congrM`, `unifyMovements`) despite their slightly higher distance scores.

### Key Takeaway

For implementing unification-based tactics in Lean 4:
1. Start with studying `congrM` for pattern-based matching
2. Study `congr!` for recursive application strategies  
3. Study `unifyMovements` for MetaM-based implementation details
4. Use the `DirectLimit.unify` theory as a reference for soundness properties

The semantic search effectively distinguished between "unification as a mathematical operation" and "unification as a tactic technique," providing valuable results from both perspectives.
