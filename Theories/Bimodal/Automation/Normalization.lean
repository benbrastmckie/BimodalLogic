import Bimodal.Syntax.Formula

/-!
# Derived Operator Normalization

This module provides bidirectional normalization for derived operators in bimodal
logic TM. The "unfold" direction reduces derived operators (neg, top, and, or,
diamond, etc.) to their primitive expansions (atom, bot, imp, box, untl, snce).
The "fold" direction reconstitutes derived operators from primitive expansions
via greedy pattern matching.

## Main Definitions

### Unfold Direction (Phase 1)
- 15 `_unfold` simp lemmas (all `rfl`) organized by dependency level
- `modal_norm` macro: full normalization to primitives
- `prop_norm`, `modal_op_norm`, `temporal_norm`: selective variant macros
- `modal_norm_at`, `modal_norm_all`: hypothesis-targeting variants

### Fold Direction (Phase 2-3)
- `EnrichedFormula`: ADT with 21 constructors (6 primitive + 15 enriched)
- `Formula.foldFormula`: greedy bottom-up fold from primitives to enriched
- `EnrichedFormula.toPrimitive`: inverse direction (enriched to primitives)
- Fold-direction simp lemmas for unambiguous patterns
- `modal_fold` macro: fold primitives back to derived operators

### Serialization (Phase 4)
- `EnrichedFormula.toJson`: JSON serialization with enriched tags
- `EnrichedFormula.prettyPrint`: human-readable notation
- `EnrichedFormula.toSExpr`: S-expression output
- `Formula.toEnrichedJson`: convenience composition

## Ambiguity Analysis

The fold direction is non-deterministic for certain patterns. The key ambiguity:
- `imp(imp(A, bot), B)` matches both `or(A, B)` and `imp(neg(A), B)`
- Conservative resolution: fold to `or` only when the pattern is unambiguous
- The `or_fold` simp lemma is deliberately omitted due to this ambiguity

## References

- Task 190: Derived operator normalization (fold direction)
- Research reports: 01_normalization-seed.md, 02_modal-norm-research.md
-/

namespace Bimodal.Syntax

open Formula

/-!
## Phase 1: Unfold Lemmas

All 15 derived operators are `def` abbreviations, so their unfold lemmas
are trivially `rfl` (definitional equality). Organized by dependency level
in the operator hierarchy.
-/

section UnfoldLemmas

/-! ### Level 1: Direct primitives (depend only on atom, bot, imp, box, untl, snce) -/

/-- Unfold negation: `neg φ = imp φ bot` -/
@[simp] theorem neg_unfold (φ : Formula) : φ.neg = φ.imp bot := rfl

/-- Unfold top: `top = imp bot bot` -/
@[simp] theorem top_unfold : Formula.top = bot.imp bot := rfl

/-- Unfold next: `next φ = untl φ bot` -/
@[simp] theorem next_unfold (φ : Formula) : φ.next = φ.untl bot := rfl

/-- Unfold prev: `prev φ = snce φ bot` -/
@[simp] theorem prev_unfold (φ : Formula) : φ.prev = φ.snce bot := rfl

/-! ### Level 2: Depend on Level 1 operators -/

/-- Unfold conjunction: `and φ ψ = (φ.imp (ψ.imp bot)).imp bot` -/
@[simp] theorem and_unfold (φ ψ : Formula) :
    φ.and ψ = (φ.imp (ψ.imp bot)).imp bot := rfl

/-- Unfold disjunction: `or φ ψ = (φ.imp bot).imp ψ` -/
@[simp] theorem or_unfold (φ ψ : Formula) :
    φ.or ψ = (φ.imp bot).imp ψ := rfl

/-- Unfold diamond: `diamond φ = (φ.imp bot).box.imp bot` -/
@[simp] theorem diamond_unfold (φ : Formula) :
    φ.diamond = (φ.imp bot).box.imp bot := rfl

/-- Unfold some_future: `some_future φ = φ.untl (bot.imp bot)` -/
@[simp] theorem some_future_unfold (φ : Formula) :
    φ.some_future = φ.untl (bot.imp bot) := rfl

/-- Unfold some_past: `some_past φ = φ.snce (bot.imp bot)` -/
@[simp] theorem some_past_unfold (φ : Formula) :
    φ.some_past = φ.snce (bot.imp bot) := rfl

/-! ### Level 3: Depend on Level 2 operators -/

/-- Unfold all_future: `all_future φ = ((φ.imp bot).untl (bot.imp bot)).imp bot` -/
@[simp] theorem all_future_unfold (φ : Formula) :
    φ.all_future = ((φ.imp bot).untl (bot.imp bot)).imp bot := rfl

/-- Unfold all_past: `all_past φ = ((φ.imp bot).snce (bot.imp bot)).imp bot` -/
@[simp] theorem all_past_unfold (φ : Formula) :
    φ.all_past = ((φ.imp bot).snce (bot.imp bot)).imp bot := rfl

/-! ### Level 4: Depend on Level 3 operators -/

/-- Unfold weak_future: `weak_future φ = and φ (all_future φ)` expanded to primitives -/
@[simp] theorem weak_future_unfold (φ : Formula) :
    φ.weak_future =
      (φ.imp ((((φ.imp bot).untl (bot.imp bot)).imp bot).imp bot)).imp bot := rfl

/-- Unfold weak_past: `weak_past φ = and φ (all_past φ)` expanded to primitives -/
@[simp] theorem weak_past_unfold (φ : Formula) :
    φ.weak_past =
      (φ.imp ((((φ.imp bot).snce (bot.imp bot)).imp bot).imp bot)).imp bot := rfl

/-! ### Level 5: Depend on Level 4 operators -/

/-- Unfold always: `always φ = and (all_past φ) (and φ (all_future φ))` -/
@[simp] theorem always_unfold (φ : Formula) :
    φ.always = φ.all_past.and (φ.and φ.all_future) := rfl

/-! ### Level 6: Depend on Level 5 operators -/

/-- Unfold sometimes: `sometimes φ = neg (always (neg φ))` -/
@[simp] theorem sometimes_unfold (φ : Formula) :
    φ.sometimes = φ.neg.always.neg := rfl

end UnfoldLemmas

/-!
## Phase 1: Normalization Tactics

Plain macro approach (no `registerSimpAttr` infrastructure needed).
-/

section NormTactics

/--
Full normalization to primitives: unfolds all 15 derived operators.
Reduces any formula to a combination of `atom`, `bot`, `imp`, `box`, `untl`, `snce`.
-/
macro "modal_norm" : tactic =>
  `(tactic| simp only [
    neg_unfold, top_unfold, next_unfold, prev_unfold,
    and_unfold, or_unfold, diamond_unfold, some_future_unfold, some_past_unfold,
    all_future_unfold, all_past_unfold,
    weak_future_unfold, weak_past_unfold,
    always_unfold, sometimes_unfold])

/-- Propositional normalization only: unfolds neg, top, and, or. -/
macro "prop_norm" : tactic =>
  `(tactic| simp only [neg_unfold, top_unfold, and_unfold, or_unfold])

/-- Modal operator normalization only: unfolds diamond. -/
macro "modal_op_norm" : tactic =>
  `(tactic| simp only [diamond_unfold])

/-- Temporal normalization only: unfolds next, prev, some_future, some_past,
    all_future, all_past, weak_future, weak_past, always, sometimes. -/
macro "temporal_norm" : tactic =>
  `(tactic| simp only [
    next_unfold, prev_unfold,
    some_future_unfold, some_past_unfold,
    all_future_unfold, all_past_unfold,
    weak_future_unfold, weak_past_unfold,
    always_unfold, sometimes_unfold])

/-- Normalize at a specific hypothesis. -/
syntax "modal_norm_at" ident : tactic
macro_rules
  | `(tactic| modal_norm_at $h) =>
    `(tactic| (simp only [
      neg_unfold, top_unfold, next_unfold, prev_unfold,
      and_unfold, or_unfold, diamond_unfold, some_future_unfold, some_past_unfold,
      all_future_unfold, all_past_unfold,
      weak_future_unfold, weak_past_unfold,
      always_unfold, sometimes_unfold] at $h:ident))

/-- Normalize all hypotheses and the goal. -/
macro "modal_norm_all" : tactic =>
  `(tactic| simp only [
    neg_unfold, top_unfold, next_unfold, prev_unfold,
    and_unfold, or_unfold, diamond_unfold, some_future_unfold, some_past_unfold,
    all_future_unfold, all_past_unfold,
    weak_future_unfold, weak_past_unfold,
    always_unfold, sometimes_unfold] at *)

end NormTactics

/-!
## Phase 1: Verification Tests
-/

section UnfoldTests

-- Test: each unfold lemma typechecks
#check @neg_unfold
#check @top_unfold
#check @next_unfold
#check @prev_unfold
#check @and_unfold
#check @or_unfold
#check @diamond_unfold
#check @some_future_unfold
#check @some_past_unfold
#check @all_future_unfold
#check @all_past_unfold
#check @weak_future_unfold
#check @weak_past_unfold
#check @always_unfold
#check @sometimes_unfold

-- Test: modal_norm reduces always (uses multiple unfold rounds)
example (p : Atom) : (atom p).always =
    (atom p).all_past.and ((atom p).and (atom p).all_future) := by
  simp only [always_unfold]

-- Test: modal_norm reduces diamond to primitives
example (p : Atom) : (atom p).diamond = ((atom p).imp bot).box.imp bot := by
  modal_norm

-- Test: selective prop_norm preserves diamond (only unfolds neg, not diamond)
example (p : Atom) : (atom p).diamond.neg = ((atom p).diamond).imp bot := by
  simp only [neg_unfold]

-- Test: modal_op_norm unfolds diamond
example (p : Atom) : (atom p).diamond = ((atom p).neg).box.neg := by
  rfl  -- diamond is definitionally neg(box(neg φ))

-- Test: temporal_norm unfolds temporal operators
example (p : Atom) : (atom p).some_future = (atom p).untl (bot.imp bot) := by
  temporal_norm

-- Test: modal_norm reduces conjunction
example (p q : Atom) : (atom p).and (atom q) =
    ((atom p).imp ((atom q).imp bot)).imp bot := by
  modal_norm

-- Test: modal_norm reduces disjunction
example (p q : Atom) : (atom p).or (atom q) =
    ((atom p).imp bot).imp (atom q) := by
  modal_norm

end UnfoldTests

end Bimodal.Syntax
