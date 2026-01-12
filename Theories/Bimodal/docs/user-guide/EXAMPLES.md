# Logos Examples

This document provides comprehensive examples of modal, temporal, and bimodal reasoning using Logos.

**Canonical import path:** `import Logos.Examples` (or a specific module such as `Logos.Examples.ModalProofs`). Legacy `Archive.*` paths remain available for backward compatibility.

## 1. Modal Logic Examples

### Automated Proof Search

The ProofSearch module provides automated proof discovery capabilities for modal logic formulas.
See `Logos/Core/Automation/ProofSearch.lean` for the full API.

```lean
import Logos.Core.Automation.ProofSearch

/-- Automated proof of modal T axiom: □φ → φ -/
example : Bool :=
  let goal := (Formula.atom "p").box.imp (Formula.atom "p")
  let (found, _, _, _, _) := ProofSearch.bounded_search [] goal 3
  found  -- Returns true (axiom match)

/-- Search with performance statistics -/
example : ProofSearch.SearchStats :=
  let goal := (Formula.atom "p").box.imp (Formula.atom "p")
  let (_, _, _, stats, _) := ProofSearch.search_with_heuristics [] goal 10
  stats  -- Shows: hits, misses, visited, prunedByLimit

/-- Custom heuristic strategies -/
example : Nat × Nat :=
  let weights_axiom_first : ProofSearch.HeuristicWeights :=
    { axiomWeight := 0, mpBase := 10 }
  let weights_mp_first : ProofSearch.HeuristicWeights :=
    { axiomWeight := 10, mpBase := 0 }
  let goal := (Formula.atom "p").box.imp (Formula.atom "p")
  let score1 := ProofSearch.heuristic_score weights_axiom_first [] goal
  let score2 := ProofSearch.heuristic_score weights_mp_first [] goal
  (score1, score2)  -- (0, 10) - axiom-first prefers this goal
```

For complete examples, see `Archive/ModalProofs.lean` (sections: Automated Proof Search, 
Search Performance Analysis, Custom Heuristic Strategies, Context Transformation Utilities).

### S5 Axiom Proofs

#### Axiom MT: `□φ → φ` (Reflexivity)

```lean
/-- Prove the reflexivity axiom MT: what is necessary is actual -/
example (P : Formula) : ⊢ (P.box.imp P) := by
  apply DerivationTree.axiom
  apply Axiom.modal_t

/-- Using DSL syntax -/
example : ⊢ (□"p" → "p") := by
  apply DerivationTree.axiom
  apply Axiom.modal_t
```

#### Axiom M4: `□φ → □□φ` (Transitivity)

```lean
/-- Prove the transitivity axiom M4: necessity iterates -/
example (P : Formula) : ⊢ (P.box.imp P.box.box) := by
  apply DerivationTree.axiom
  apply Axiom.modal_4

/-- Chain of necessities -/
example (P : Formula) : [P.box] ⊢ P.box.box.box := by
  apply DerivationTree.modusPonens
  · apply DerivationTree.axiom; apply Axiom.modal_4
  · apply DerivationTree.modusPonens
    · apply DerivationTree.axiom; apply Axiom.modal_4
    · apply DerivationTree.assumption; simp
```

#### Axiom MB: `φ → □◇φ` (Symmetry)

```lean
/-- Prove the symmetry axiom MB: actuality implies necessary possibility -/
example (P : Formula) : ⊢ (P.imp (diamond P).box) := by
  apply DerivationTree.axiom
  apply Axiom.modal_b

/-- Using the axiom to derive a fact -/
example (P : Formula) : [P] ⊢ (diamond P).box := by
  apply DerivationTree.modusPonens
  · apply DerivationTree.axiom; apply Axiom.modal_b
  · apply DerivationTree.assumption; simp
```

### Diamond as Derived Operator

```lean
/-- Diamond is defined as `¬□¬` -/
example (P : Formula) : diamond P = neg (Formula.box (neg P)) := rfl

/-- Prove `◇p` from `p` using MB -/
example (P : Formula) : [P] ⊢ diamond P := by
  -- From P, we can derive `□◇P` (by MB)
  -- From `□◇P`, we get `◇P` (by MT on `◇P`)
  sorry -- Full proof requires intermediate steps
```

### Key S5 Theorems

```lean
/-- In S5, `□φ ↔ □□φ` -/
theorem box_idempotent (P : Formula) :
  (⊢ P.box.imp P.box.box) ∧ (⊢ P.box.box.imp P.box) := by
  constructor
  · apply DerivationTree.axiom; apply Axiom.modal_4
  · -- `□□φ → □φ` is derivable using MT on `□φ`
    sorry

/-- In S5, `◇φ ↔ ◇◇φ` -/
theorem diamond_idempotent (P : Formula) :
  (⊢ (diamond P).imp (diamond (diamond P))) ∧
  (⊢ (diamond (diamond P)).imp (diamond P)) := by
  sorry

/-- In S5, `□◇φ ↔ ◇φ` -/
theorem box_diamond_collapse (P : Formula) :
  ⊢ ((diamond P).box.imp (diamond P)) := by
  apply DerivationTree.axiom
  apply Axiom.modal_t

/-- In S5, `◇□φ ↔ □φ` -/
theorem diamond_box_collapse (P : Formula) :
  ⊢ ((diamond P.box).imp P.box) := by
  sorry
```

## 2. Temporal Logic Examples

### Automated Temporal Search

Temporal formulas can be discovered automatically using proof search. Temporal formulas
typically require higher search depths than modal formulas due to operator complexity.

```lean
import Logos.Core.Automation.ProofSearch

/-- Automated proof of temporal 4 axiom: Gφ → GGφ -/
example : Bool :=
  let goal := (Formula.atom "p").all_future.imp (Formula.atom "p").all_future.all_future
  let (found, _, _, _, _) := ProofSearch.bounded_search [] goal 5
  found  -- Returns true (axiom match)

/-- Temporal context transformations -/
example : Context :=
  let Γ := [Formula.atom "p", Formula.atom "q"]
  ProofSearch.future_context Γ  -- Returns [Gp, Gq]

/-- Temporal formulas require higher depth than modal -/
example : Bool × Bool :=
  let temporal_goal := (Formula.atom "p").all_future.imp (Formula.atom "p").all_future.all_future
  let modal_goal := (Formula.atom "p").box.imp (Formula.atom "p").box.box
  let (temp_found, _, _, _, _) := ProofSearch.bounded_search [] temporal_goal 3
  let (modal_found, _, _, _, _) := ProofSearch.bounded_search [] modal_goal 3
  (temp_found, modal_found)  -- Both should succeed with depth 3
```

For complete examples, see `Archive/TemporalProofs.lean` (sections: Automated Temporal Search,
Temporal Context Transformations).

### Temporal Axiom Proofs

#### Axiom T4: Gφ → GGφ

```lean
/-- All-future iterates: what will always be will always always be -/
example (P : Formula) : ⊢ ((Formula.all_future P).imp (Formula.all_future (Formula.all_future P))) := by
  apply DerivationTree.axiom
  apply Axiom.temp_4
```

#### Axiom TA: φ → G(Pφ)

```lean
/-- Present implies future past: now will have been -/
example (P : Formula) : ⊢ (P.imp (Formula.all_future (some_past P))) := by
  apply DerivationTree.axiom
  apply Axiom.temp_a
```

#### Axiom TL: △φ → G(Hφ)

```lean
/-- Linearity: if always, then future has past -/
example (P : Formula) : ⊢ ((always P).imp (Formula.all_future (Formula.all_past P))) := by
  apply DerivationTree.axiom
  apply Axiom.temp_l
```

### Past and Future Operators

```lean
/-- Universal past (H): P holds at all past times -/
example (P : Formula) : Formula := Formula.all_past P

/-- Universal future (G): P holds at all future times -/
example (P : Formula) : Formula := Formula.all_future P

/-- Existential past (P): P held at some past time -/
example (P : Formula) : Formula := some_past P  -- ¬H¬P

/-- Existential future (F): P will hold at some future time -/
example (P : Formula) : Formula := some_future P  -- ¬G¬P
```

### Temporal Properties

```lean
/-- Always operator: Hφ ∧ φ ∧ Gφ -/
example (P : Formula) : always P = and (and (Formula.all_past P) P) (Formula.all_future P) := rfl

/-- Sometimes operator: Pφ ∨ φ ∨ Fφ -/
example (P : Formula) : sometimes P = or (or (some_past P) P) (some_future P) := rfl

/-- From always, derive present -/
example (P : Formula) : [always P] ⊢ P := by
  -- always P = Hφ ∧ φ ∧ Gφ
  -- Extract φ from the conjunction
  sorry

/-- From always, derive all_past -/
example (P : Formula) : [always P] ⊢ Formula.all_past P := by
  sorry

/-- From always, derive all_future -/
example (P : Formula) : [always P] ⊢ Formula.all_future P := by
  sorry
```

## 3. Bimodal Interaction Examples

### MF Axiom: □φ → □Gφ

```lean
/-- What is necessary will always be necessary -/
example (P : Formula) : ⊢ (P.box.imp (Formula.box (Formula.all_future P))) := by
  apply DerivationTree.axiom
  apply Axiom.modal_future

/-- Derive □Gp from □p -/
example (P : Formula) : [P.box] ⊢ Formula.box (Formula.all_future P) := by
  apply DerivationTree.modusPonens
  · apply DerivationTree.axiom; apply Axiom.modal_future
  · apply DerivationTree.assumption; simp
```

### TF Axiom: □φ → G□φ

```lean
/-- What is necessary will remain necessary -/
example (P : Formula) : ⊢ (P.box.imp (Formula.all_future P.box)) := by
  apply DerivationTree.axiom
  apply Axiom.temp_future

/-- Derive G□p from □p -/
example (P : Formula) : [P.box] ⊢ Formula.all_future P.box := by
  apply DerivationTree.modusPonens
  · apply DerivationTree.axiom; apply Axiom.temp_future
  · apply DerivationTree.assumption; simp
```

### Combined Modal-Temporal Reasoning

```lean
/-- From `□p`, derive both `□Gp` and `G□p` -/
example (P : Formula) : [P.box] ⊢ and (Formula.box (Formula.all_future P)) (Formula.all_future P.box) := by
  -- Use MF for first conjunct, TF for second
  sorry

/-- Modal necessity implies temporal persistence -/
example (P : Formula) : [P.box] ⊢ always P := by
  -- This is essentially P1: `□φ → △φ`
  -- Requires proving from MF, TF, MT, and temporal duality
  sorry
```

## 4. Perpetuity Principles

### Automated Perpetuity Discovery

The perpetuity principles P1-P6 can be discovered automatically using proof search.
Bimodal formulas require higher search depths due to modal-temporal interaction.

```lean
import Logos.Core.Automation.ProofSearch

/-- Automated discovery of P1: □φ → △φ -/
example : Bool :=
  let goal := (Formula.atom "p").box.imp (△(Formula.atom "p"))
  let (found, _, _, _, _) := ProofSearch.bounded_search [] goal 10
  found  -- Returns true, discovering P1 automatically

/-- Automated discovery of P2: ▽φ → ◇φ -/
example : Bool :=
  let goal := (▽(Formula.atom "p")).imp (Formula.atom "p").diamond
  let (found, _, _, _, _) := ProofSearch.bounded_search [] goal 10
  found  -- Returns true, discovering P2 automatically

/-- Combined modal-temporal search -/
example : Bool :=
  let goal := (Formula.atom "p").box.imp (Formula.atom "p").all_future.box
  let (found, _, _, _, _) := ProofSearch.bounded_search [] goal 10
  found  -- Searches through modal-temporal interaction axioms

/-- Bimodal search depth requirements comparison -/
example : Nat × Nat × Nat :=
  let modal_goal := (Formula.atom "p").box.imp (Formula.atom "p")
  let temporal_goal := (Formula.atom "p").all_future.imp (Formula.atom "p").all_future.all_future
  let bimodal_goal := (Formula.atom "p").box.imp (△(Formula.atom "p"))
  let (_, _, _, modal_stats, _) := ProofSearch.bounded_search [] modal_goal 5
  let (_, _, _, temporal_stats, _) := ProofSearch.bounded_search [] temporal_goal 5
  let (_, _, _, bimodal_stats, _) := ProofSearch.bounded_search [] bimodal_goal 10
  (modal_stats.visited, temporal_stats.visited, bimodal_stats.visited)
  -- Bimodal formulas typically visit more nodes due to operator interaction
```

For complete examples, see `Archive/BimodalProofs.lean` (sections: Perpetuity Automation Examples,
Combined Modal-Temporal Search).

### P1: `□φ → △φ`

```lean
/-- What is necessary is always the case -/
theorem perpetuity_1_example (P : Formula) : ⊢ (P.box.imp (△P)) := by
  -- Proof sketch:
  -- 1. `□P → □Future P` (MF)
  -- 2. `□Future P → Future P` (MT)
  -- 3. `□P → Future P` (transitivity)
  -- 4. By TD (temporal duality), `□P → Past P`
  -- 5. `□P → P` (MT)
  -- 6. Combine: `□P → Past P ∧ P ∧ Future P = always P`
  sorry

/-- Using P1 -/
example (P : Formula) : [P.box] ⊢ always P := by
  apply DerivationTree.modusPonens
  · exact perpetuity_1 P
  · apply DerivationTree.assumption; simp
```

### P2: `▽φ → ◇φ`

```lean
/-- What is sometimes the case is possible -/
theorem perpetuity_2_example (P : Formula) : ⊢ ((▽P).imp (diamond P)) := by
  -- Proof by contraposition of P1
  -- If `¬◇P` (= `□¬P`), then `always ¬P`
  -- Contrapositive: `sometimes P → ◇P`
  sorry
```

### P3: `□φ → □△φ`

```lean
/-- Necessity of perpetuity: necessary implies necessarily always -/
theorem perpetuity_3_example (P : Formula) : ⊢ (P.box.imp ((△P).box)) := by
  -- Proof sketch:
  -- 1. □P → always P (P1)
  -- 2. Need to show □P → □always P
  -- 3. Use MK: from premises derive □(always P)
  sorry
```

### P4: `◇▽φ → ◇φ`

```lean
/-- Possibility of occurrence -/
theorem perpetuity_4_example (P : Formula) : ⊢ ((diamond (▽P)).imp (diamond P)) := by
  -- Contrapositive of P3 applied to ¬P
  sorry
```

### P5: `◇▽φ → △◇φ`

```lean
/-- Persistent possibility: if possibly sometimes, then always possible -/
theorem perpetuity_5_example (P : Formula) : ⊢ ((diamond (▽P)).imp (△(diamond P))) := by
  -- Key theorem showing modal-temporal interaction
  sorry
```

### P6: `▽□φ → □△φ`

```lean
/-- Occurrent necessity is perpetual -/
theorem perpetuity_6_example (P : Formula) : ⊢ ((▽P.box).imp ((△P).box)) := by
  -- If necessity holds at some time, it holds always necessarily
  sorry
```

## 5. Advanced Examples

### Soundness Example

```lean
/-- Verify soundness for a specific derivation -/
example (P : Formula) : valid (P.box.imp P) := by
  -- Show MT is valid in all task semantic models
  intro F M τ t
  intro h_box_p
  -- □P means P holds in all histories at t
  -- In particular, P holds in τ at t
  exact h_box_p τ
```

### Consistency Example

```lean
/-- Show {□P, ◇¬P} is inconsistent -/
example (P : Formula) : ¬consistent [P.box, diamond (neg P)] := by
  -- □P implies P (MT)
  -- ◇¬P = ¬□¬¬P = ¬□P (by double negation)
  -- We have □P and ¬□P, contradiction
  sorry
```

### Temporal Duality Example

```lean
/-- Temporal duality: swapping all_past and all_future preserves provability -/
example (P : Formula) (h : ⊢ P) : ⊢ (swap_temporal P) := by
  apply DerivationTree.temporalDuality
  exact h

/-- Example: if ⊢ Gp → GGp, then ⊢ Hp → HHp -/
example (P : Formula) : ⊢ (Formula.all_past P).imp (Formula.all_past (Formula.all_past P)) := by
  -- By TD applied to T4
  apply DerivationTree.temporalDuality
  apply DerivationTree.axiom
  apply Axiom.temp_4
```

### Custom Tactic Usage

```lean
/-- Using modal_auto for complex proofs -/
example (P Q : Formula) :
  [P.box, Q.box] ⊢ (and P Q).box := by
  tm_auto

/-- Using modal_search with depth limit -/
example (P : Formula) : [P.box.box.box] ⊢ P := by
  modal_search 5
```

### ProofSearch API Reference

The `Logos.Core.Automation.ProofSearch` module provides:

- **`bounded_search`**: Depth-bounded search with caching and statistics
  - Returns: `(Bool, ProofCache, Visited, SearchStats, Nat)`
  - Parameters: context, goal, depth, cache, visited, visits, visitLimit, weights, stats
  
- **`search_with_heuristics`**: Heuristic-guided search with default parameters
  - Returns: `(Bool, ProofCache, Visited, SearchStats, Nat)`
  - Parameters: context, goal, depth, visitLimit, weights
  
- **`search_with_cache`**: Cached search with memoization
  - Returns: `(Bool, ProofCache, Visited, SearchStats, Nat)`
  - Parameters: cache, context, goal, depth, visitLimit, weights

- **`HeuristicWeights`**: Configurable weights for branch ordering
  - Fields: axiomWeight, assumptionWeight, mpBase, mpComplexityWeight, modalBase, temporalBase, contextPenaltyWeight, deadEnd

- **`SearchStats`**: Performance statistics
  - Fields: hits (cache hits), misses (cache misses), visited (nodes explored), prunedByLimit (pruned by visit limit)

- **Context Transformations**:
  - `box_context`: Applies `□` to all formulas in context (for modal K rule)
  - `future_context`: Applies `G` to all formulas in context (for temporal K rule)

For detailed usage examples and performance analysis, see:
- `Archive/ModalProofs.lean` - Modal automation examples
- `Archive/TemporalProofs.lean` - Temporal automation examples
- `Archive/BimodalProofs.lean` - Perpetuity automation examples
- `docs/research/proof-search-automation.md` - Research documentation

## 6. Working with Derivation Trees

Since `DerivationTree` is a `Type` (not a `Prop`), we can perform computations and pattern matching 
on derivation trees. This section demonstrates these capabilities.

### Computing Derivation Height

```lean
/-- Compute the height (depth) of a derivation tree -/
def height {Γ : Context} {φ : Formula} : DerivationTree Γ φ → Nat
  | .axiom _ _ _ => 0
  | .assumption _ _ _ => 0
  | .modusPonens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | .necessitation _ d => 1 + d.height
  | .temporalNecessitation _ d => 1 + d.height
  | .temporalDuality _ d => 1 + d.height
  | .weakening _ _ _ d _ => 1 + d.height

/-- Example: axiom derivations have height 0 -/
example (p : Formula) : 
  let d : [] ⊢ (p.box.imp p) := DerivationTree.axiom [] _ (Axiom.modal_t p)
  height d = 0 := rfl

/-- Example: modus ponens increases height -/
example (p q : Formula) :
  let d1 : [p.imp q] ⊢ (p.imp q) := DerivationTree.assumption _ _ (by simp)
  let d2 : [p.imp q, p] ⊢ p := DerivationTree.assumption _ _ (by simp)
  let d : [p.imp q, p] ⊢ q := DerivationTree.modusPonens _ _ _ 
    (DerivationTree.weakening _ _ _ d1 (by simp)) d2
  height d = 1 := by rfl
```

### Pattern Matching on Derivation Structure

```lean
/-- Check if a derivation uses any axioms -/
def usesAxiom {Γ : Context} {φ : Formula} : DerivationTree Γ φ → Bool
  | .axiom _ _ _ => true
  | .assumption _ _ _ => false
  | .modusPonens _ _ _ d1 d2 => d1.usesAxiom || d2.usesAxiom
  | .necessitation _ d => d.usesAxiom
  | .temporalNecessitation _ d => d.usesAxiom
  | .temporalDuality _ d => d.usesAxiom
  | .weakening _ _ _ d _ => d.usesAxiom

/-- Count the number of modus ponens applications -/
def countModusPonens {Γ : Context} {φ : Formula} : DerivationTree Γ φ → Nat
  | .axiom _ _ _ => 0
  | .assumption _ _ _ => 0
  | .modusPonens _ _ _ d1 d2 => 1 + d1.countModusPonens + d2.countModusPonens
  | .necessitation _ d => d.countModusPonens
  | .temporalNecessitation _ d => d.countModusPonens
  | .temporalDuality _ d => d.countModusPonens
  | .weakening _ _ _ d _ => d.countModusPonens
```

### Well-Founded Recursion Using Height

The `height` function enables well-founded recursion on derivation trees, which is used in 
metalogical proofs like the deduction theorem:

```lean
/-- Deduction theorem uses well-founded recursion on derivation height -/
theorem deduction_theorem (Γ : Context) (φ ψ : Formula) :
  (φ :: Γ) ⊢ ψ → Γ ⊢ (φ.imp ψ) := by
  intro d
  -- Proof proceeds by induction on height of d
  -- Pattern matching on DerivationTree enables this
  sorry
```

## 7. Exercises

Practice problems with progressive hints and solutions. Try each exercise before looking at hints!

---

### Exercise 1: Modal K Distribution (Basic)

**Problem**: Prove `⊢ □(P → Q) → (□P → □Q)`

This is the modal K axiom (or distribution axiom) - necessity distributes over implication.

**Hint 1**: This is a fundamental axiom of modal logic, not a derived theorem.

**Hint 2**: Look for `Axiom.modal_k_dist` in the axiom definitions.

<details>
<summary>Solution</summary>

```lean
example (P Q : Formula) : ⊢ (P.imp Q).box.imp (P.box.imp Q.box) :=
  DerivationTree.axiom [] _ (Axiom.modal_k_dist P Q)
```

**Explanation**: Modal K distribution is one of the 14 TM axiom schemas. It's applied directly via `DerivationTree.axiom` with the `Axiom.modal_k_dist` constructor. This axiom states that if something is necessarily true as an implication, then the necessity of the antecedent implies the necessity of the consequent.
</details>

---

### Exercise 2: Modus Ponens from Assumptions (Basic)

**Problem**: Prove `[P, P → Q] ⊢ Q`

Derive Q from assumptions P and P → Q using modus ponens.

**Hint 1**: You need to extract both assumptions from the context, then apply modus ponens.

**Hint 2**: Use `DerivationTree.assumption` to get each formula from the context, then `DerivationTree.modusPonens`.

<details>
<summary>Solution</summary>

```lean
example (P Q : Formula) : [P, P.imp Q] ⊢ Q := by
  apply DerivationTree.modusPonens (Γ := [P, P.imp Q]) (φ := P) (ψ := Q)
  · -- Prove [P, P → Q] ⊢ P → Q
    apply DerivationTree.assumption
    simp
  · -- Prove [P, P → Q] ⊢ P
    apply DerivationTree.assumption
    simp
```

Or in term mode:

```lean
example (P Q : Formula) : [P, P.imp Q] ⊢ Q :=
  DerivationTree.modusPonens [P, P.imp Q] P Q
    (DerivationTree.assumption [P, P.imp Q] (P.imp Q) (by simp))
    (DerivationTree.assumption [P, P.imp Q] P (by simp))
```

**Explanation**: `modusPonens` requires two sub-derivations: one for the implication `P → Q` and one for the antecedent `P`. Both are in our context, so we use `assumption` with a membership proof (which `simp` handles).
</details>

---

### Exercise 3: Necessity Implies Possibility (Basic)

**Problem**: Prove `⊢ □P → ◇P`

If P is necessary (true in all worlds), then P is possible (true in some world).

**Hint 1**: Remember that `◇P` is defined as `¬□¬P`. So the goal is really `□P → ¬□¬P`.

**Hint 2**: Use axiom T (`□P → P`) and axiom B (`P → □◇P`), along with contraposition and transitivity.

<details>
<summary>Solution</summary>

```lean
import Bimodal.Theorems.Propositional

open Bimodal.Theorems.Propositional

example (P : Formula) : ⊢ P.box.imp P.diamond := by
  -- □P → ◇P
  -- ◇P = ¬□¬P, so we need □P → ¬□¬P
  -- Strategy: □P → P (T), P → □◇P (B), □◇P = □¬□¬P
  -- Then: □P → P → □¬□¬P, contrapose inner part

  -- Actually simpler: use T and contraposition
  -- □P → P (T axiom)
  -- ¬P → ¬□P (contraposition of T on ¬P)
  -- But □¬P → ¬P (T on ¬P)
  -- So □¬P → ¬□P... hmm

  -- Cleaner: Use T directly: □P → P, and ¬P → □¬P contraposed...
  -- This requires the S5 characteristic theorem.
  -- For S5: □P → P and P → □◇P give □P → □◇P, then T: □◇P → ◇P

  have t_axiom : ⊢ P.box.imp P := DerivationTree.axiom [] _ (Axiom.modal_t P)
  have b_axiom : ⊢ P.imp P.diamond.box := DerivationTree.axiom [] _ (Axiom.modal_b P)
  have t_on_diamond : ⊢ P.diamond.box.imp P.diamond :=
    DerivationTree.axiom [] _ (Axiom.modal_t P.diamond)

  -- Chain: □P → P → □◇P → ◇P
  have step1 := imp_trans t_axiom b_axiom  -- □P → □◇P
  exact imp_trans step1 t_on_diamond       -- □P → ◇P
```

**Explanation**: We chain three implications: T axiom gives `□P → P`, B axiom gives `P → □◇P`, and T on `◇P` gives `□◇P → ◇P`. Composing these via `imp_trans` yields `□P → ◇P`.
</details>

---

### Exercise 4: S5 Collapse for Possibility (Intermediate)

**Problem**: Prove `⊢ ◇◇P → ◇P`

In S5 logic, iterated possibility collapses.

**Hint 1**: S5 has "collapse" properties due to the equivalence relation on worlds. Look for an S5-specific axiom.

**Hint 2**: The axiom `modal_5_collapse` directly provides `◇◇φ → ◇φ`.

<details>
<summary>Solution</summary>

```lean
example (P : Formula) : ⊢ P.diamond.diamond.imp P.diamond :=
  DerivationTree.axiom [] _ (Axiom.modal_5_collapse P)
```

**Explanation**: In S5, the accessibility relation is an equivalence relation, which means `◇◇P → ◇P` holds as an axiom schema. The `modal_5_collapse` axiom directly captures this property.
</details>

---

### Exercise 5: Extract from Temporal Always (Intermediate)

**Problem**: Prove `[always P] ⊢ P`

The `always` operator is defined as a conjunction of past and future necessity. Extract P from it.

**Hint 1**: `always P` is defined as `P.all_past.and P.all_future`. You need conjunction elimination.

**Hint 2**: First extract `HP` (always was P), then use temporal T axiom `HP → P`.

<details>
<summary>Solution</summary>

```lean
import Bimodal.Theorems.Propositional

open Bimodal.Theorems.Propositional

example (P : Formula) : [P.always] ⊢ P := by
  -- always P = HP ∧ GP where H = all_past, G = all_future
  -- Need to extract HP from HP ∧ GP, then use temporal T: HP → P

  -- Get HP ∧ GP from context
  have conj : [P.always] ⊢ P.always := DerivationTree.assumption _ _ (by simp)

  -- Left conjunction elimination: (HP ∧ GP) → HP
  have lce : ⊢ P.always.imp P.all_past := lce_imp P.all_past P.all_future

  -- Apply to get HP
  have hp : [P.always] ⊢ P.all_past := by
    apply DerivationTree.modusPonens
    · exact DerivationTree.weakening [] [P.always] _ lce (by simp)
    · exact conj

  -- Temporal T axiom: HP → P
  have temp_t : ⊢ P.all_past.imp P := DerivationTree.axiom [] _ (Axiom.temp_t P)

  -- Apply to get P
  apply DerivationTree.modusPonens
  · exact DerivationTree.weakening [] [P.always] _ temp_t (by simp)
  · exact hp
```

**Explanation**: The `always` operator is the conjunction of "always was" (`all_past`) and "always will be" (`all_future`). We use left conjunction elimination to get `HP`, then apply the temporal T axiom (`HP → P`) to extract P.
</details>

---

### Exercise 6: Distribute Box Over Conjunction (Intermediate)

**Problem**: Show that `{□P, □Q}` entails `□(P ∧ Q)`

From necessity of P and necessity of Q, derive necessity of their conjunction.

**Hint 1**: You'll need to prove `⊢ □P → (□Q → □(P ∧ Q))` first, then apply it to assumptions.

**Hint 2**: Use modal K distribution: `□(P → (Q → P ∧ Q)) → (□P → □(Q → P ∧ Q))`, combined with conjunction introduction `P → (Q → P ∧ Q)`.

<details>
<summary>Solution</summary>

```lean
import Bimodal.Theorems.Propositional
import Bimodal.Theorems.Combinators

open Bimodal.Theorems.Propositional
open Bimodal.Theorems.Combinators

noncomputable example (P Q : Formula) : [P.box, Q.box] ⊢ (P.and Q).box := by
  -- Strategy:
  -- 1. Prove ⊢ P → (Q → P ∧ Q) (conjunction introduction theorem)
  -- 2. Necessitate: ⊢ □(P → (Q → P ∧ Q))
  -- 3. Use K distribution twice to get ⊢ □P → □(Q → P ∧ Q) and ⊢ □(Q → P ∧ Q) → (□Q → □(P ∧ Q))
  -- 4. Chain and apply to assumptions

  -- Conjunction introduction theorem
  have conj_intro : ⊢ P.imp (Q.imp (P.and Q)) := pairing P Q

  -- Necessitate
  have nec_conj : ⊢ (P.imp (Q.imp (P.and Q))).box :=
    DerivationTree.necessitation _ conj_intro

  -- First K distribution: □(P → (Q → P ∧ Q)) → (□P → □(Q → P ∧ Q))
  have k1 : ⊢ (P.imp (Q.imp (P.and Q))).box.imp (P.box.imp (Q.imp (P.and Q)).box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist P (Q.imp (P.and Q)))

  -- Apply to get □P → □(Q → P ∧ Q)
  have step1 : ⊢ P.box.imp (Q.imp (P.and Q)).box := mp nec_conj k1

  -- Second K distribution: □(Q → P ∧ Q) → (□Q → □(P ∧ Q))
  have k2 : ⊢ (Q.imp (P.and Q)).box.imp (Q.box.imp (P.and Q).box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist Q (P.and Q))

  -- Chain: □P → □(Q → P ∧ Q) → (□Q → □(P ∧ Q))
  have step2 : ⊢ P.box.imp (Q.box.imp (P.and Q).box) := imp_trans step1 k2

  -- Now apply to our assumptions
  have boxP : [P.box, Q.box] ⊢ P.box := DerivationTree.assumption _ _ (by simp)
  have boxQ : [P.box, Q.box] ⊢ Q.box := DerivationTree.assumption _ _ (by simp)

  -- Weaken step2 into context
  have step2_weak : [P.box, Q.box] ⊢ P.box.imp (Q.box.imp (P.and Q).box) :=
    DerivationTree.weakening [] [P.box, Q.box] _ step2 (by simp)

  -- Apply twice
  have inter : [P.box, Q.box] ⊢ Q.box.imp (P.and Q).box :=
    DerivationTree.modusPonens _ _ _ step2_weak boxP
  exact DerivationTree.modusPonens _ _ _ inter boxQ
```

**Explanation**: This proof uses the "pairing" combinator for conjunction introduction, necessitation to put it under a box, and then two applications of modal K distribution to thread the necessity through. The key insight is that modal K lets us "lift" implications into necessitated form.
</details>

---

### Exercise 7: Perpetuity Principle P1 (Advanced)

**Problem**: Prove `⊢ □P → always P`

This is perpetuity principle P1: necessity implies eternal truth.

**Hint 1**: `always P = HP ∧ GP`. You need to prove `□P → HP` and `□P → GP` separately.

**Hint 2**: Use the interaction axioms `Axiom.int_1` (`□P → HP`) and `Axiom.int_2` (`□P → GP`), then combine with conjunction introduction.

<details>
<summary>Solution</summary>

```lean
import Bimodal.Theorems.Combinators

open Bimodal.Theorems.Combinators

example (P : Formula) : ⊢ P.box.imp P.always := by
  -- always P = HP ∧ GP
  -- Need □P → HP ∧ GP
  -- We have interaction axioms: □P → HP and □P → GP

  -- Interaction axiom 1: □φ → Hφ (necessity implies always-was)
  have int1 : ⊢ P.box.imp P.all_past :=
    DerivationTree.axiom [] _ (Axiom.int_1 P)

  -- Interaction axiom 2: □φ → Gφ (necessity implies always-will-be)
  have int2 : ⊢ P.box.imp P.all_future :=
    DerivationTree.axiom [] _ (Axiom.int_2 P)

  -- Combine: □P → HP and □P → GP implies □P → (HP ∧ GP)
  -- Using combine_imp_conj from Combinators
  exact combine_imp_conj int1 int2
```

**Explanation**: The TM logic includes interaction axioms that connect modal necessity with temporal operators. `int_1` says necessity implies "always was" (past eternity), and `int_2` says necessity implies "always will be" (future eternity). The `combine_imp_conj` combinator merges two implications with the same antecedent into a conjunction in the consequent.
</details>

---

### Exercise 8: Bimodal Equivalence (Advanced)

**Problem**: Prove `⊢ always □P ↔ □P` in TM

The necessity of something is equivalent to eternal necessity.

**Hint 1**: A biconditional `A ↔ B` is `(A → B) ∧ (B → A)`. Prove both directions.

**Hint 2**: For `always □P → □P`, extract from conjunction. For `□P → always □P`, use Exercise 7's pattern with `□P` substituted for `P`.

<details>
<summary>Solution</summary>

```lean
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.Propositional

open Bimodal.Theorems.Combinators
open Bimodal.Theorems.Propositional

-- Forward direction: always □P → □P
example (P : Formula) : ⊢ P.box.always.imp P.box := by
  -- always □P = H□P ∧ G□P
  -- Use temporal T: H□P → □P
  have lce : ⊢ P.box.always.imp P.box.all_past := lce_imp P.box.all_past P.box.all_future
  have temp_t : ⊢ P.box.all_past.imp P.box := DerivationTree.axiom [] _ (Axiom.temp_t P.box)
  exact imp_trans lce temp_t

-- Backward direction: □P → always □P (using P1 pattern)
example (P : Formula) : ⊢ P.box.imp P.box.always := by
  -- □□P → always □P by P1 pattern
  -- But we need □P → □□P first (axiom 4)
  have modal_4 : ⊢ P.box.imp P.box.box := DerivationTree.axiom [] _ (Axiom.modal_4 P)

  -- Then □□P → always □P by P1
  have int1 : ⊢ P.box.box.imp P.box.all_past := DerivationTree.axiom [] _ (Axiom.int_1 P.box)
  have int2 : ⊢ P.box.box.imp P.box.all_future := DerivationTree.axiom [] _ (Axiom.int_2 P.box)
  have p1 : ⊢ P.box.box.imp P.box.always := combine_imp_conj int1 int2

  exact imp_trans modal_4 p1

-- Full biconditional
noncomputable example (P : Formula) : ⊢ P.box.always.iff P.box := by
  -- iff = (A → B) ∧ (B → A)
  have fwd : ⊢ P.box.always.imp P.box := by
    have lce : ⊢ P.box.always.imp P.box.all_past := lce_imp P.box.all_past P.box.all_future
    have temp_t : ⊢ P.box.all_past.imp P.box := DerivationTree.axiom [] _ (Axiom.temp_t P.box)
    exact imp_trans lce temp_t

  have bwd : ⊢ P.box.imp P.box.always := by
    have modal_4 : ⊢ P.box.imp P.box.box := DerivationTree.axiom [] _ (Axiom.modal_4 P)
    have int1 : ⊢ P.box.box.imp P.box.all_past := DerivationTree.axiom [] _ (Axiom.int_1 P.box)
    have int2 : ⊢ P.box.box.imp P.box.all_future := DerivationTree.axiom [] _ (Axiom.int_2 P.box)
    have p1 : ⊢ P.box.box.imp P.box.always := combine_imp_conj int1 int2
    exact imp_trans modal_4 p1

  exact combine_imp_conj fwd bwd
```

**Explanation**: The forward direction uses temporal T (`HP → P` applied to `□P`). The backward direction uses modal 4 (`□P → □□P`) to get double necessity, then applies the P1 pattern to `□P` instead of `P`. This demonstrates the deep connection between modal and temporal operators in TM.
</details>

---

### Exercise 9: Canonical Model Understanding (Advanced)

**Problem**: Explain the structure of a canonical model proof for completeness.

This is a conceptual exercise about the completeness proof infrastructure.

**Hint 1**: Review `Bimodal/Metalogic/Completeness.lean` for the scaffolding.

**Hint 2**: The key components are: (1) maximal consistent sets, (2) canonical frame construction, (3) truth lemma.

<details>
<summary>Discussion</summary>

A canonical model proof for TM completeness follows these steps:

1. **Maximal Consistent Sets (MCS)**: For any consistent set of formulas Γ, extend it to a maximal consistent set using Lindenbaum's lemma. An MCS contains exactly one of `φ` or `¬φ` for every formula.

2. **Canonical Frame**: Define a frame where:
   - Worlds = maximal consistent sets
   - Modal accessibility: `w R v` iff for all φ, if `□φ ∈ w` then `φ ∈ v`
   - Temporal accessibility: similar for `H` and `G` operators

3. **Canonical Model**: Define valuation: `p` is true at world `w` iff `atom p ∈ w`.

4. **Truth Lemma**: Prove by induction on formula complexity:
   `φ ∈ w` iff `M, w ⊨ φ`

   The modal cases use the definition of accessibility. The key insight is that the axioms guarantee the right frame properties.

5. **Completeness**: If `⊨ φ` (valid), then `⊢ φ` (provable).
   - Contrapositive: if `⊬ φ`, then `⊭ φ`
   - If `φ` is not provable, then `{¬φ}` is consistent
   - Extend to MCS `w`, build canonical model
   - By truth lemma, `¬φ ∈ w` means `M, w ⊨ ¬φ`, so `M, w ⊭ φ`

The current implementation in `Completeness.lean` has the scaffolding with placeholder `sorry`s. Task 257 tracks completing these proofs.

See also: [KNOWN_LIMITATIONS.md](../project-info/KNOWN_LIMITATIONS.md) for status.
</details>

---

### Additional Resources

- **Lean Source Files**:
  - `Bimodal/Examples/ModalProofs.lean` - More modal proof examples
  - `Bimodal/Examples/TemporalProofs.lean` - Temporal logic examples
  - `Bimodal/Examples/BimodalProofs.lean` - Combined modal-temporal proofs
  - `Bimodal/Theorems/Combinators.lean` - Proof combinators used above

- **Reference Guides**:
  - [Axiom Reference](../reference/AXIOM_REFERENCE.md) - Complete list of TM axioms
  - [Tactic Reference](../reference/TACTIC_REFERENCE.md) - Custom tactics
  - [Troubleshooting](TROUBLESHOOTING.md) - Common errors and solutions

## References

- [Tutorial](TUTORIAL.md) - Getting started guide
- [Architecture](ARCHITECTURE.md) - Full TM logic specification
- [Tactic Development](TACTIC_DEVELOPMENT.md) - Custom tactics
