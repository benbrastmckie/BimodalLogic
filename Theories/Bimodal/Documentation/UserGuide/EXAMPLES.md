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

## 7. Exercise Problems

### Basic Exercises

1. Prove `⊢ □(P → Q) → (□P → □Q)` (K axiom for necessity)
2. Prove `[P, P → Q] ⊢ Q` using modus ponens
3. Prove `⊢ □P → ◇P` from MT and MB

### Intermediate Exercises

4. Prove `⊢ ◇◇P → ◇P` in S5
5. Prove `[always P] ⊢ P` by extracting from conjunction
6. Show `{□P, □Q}` entails `□(P ∧ Q)`

### Advanced Exercises

7. Prove perpetuity principle P1: `⊢ □P → always P`
8. Prove `⊢ always □P ↔ □P` in TM
9. Construct a canonical model proof for a specific formula

### Solutions

Solutions are available via the active `Logos/Examples/` modules (legacy `Archive/` paths still work):
- `Logos/Examples/ModalProofs.lean`
- `Logos/Examples/TemporalProofs.lean`
- `Logos/Examples/BimodalProofs.lean`

## References

- [Tutorial](TUTORIAL.md) - Getting started guide
- [Architecture](ARCHITECTURE.md) - Full TM logic specification
- [Tactic Development](TACTIC_DEVELOPMENT.md) - Custom tactics
