/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula

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
- `modalNorm` macro: full normalization to primitives
- `propNorm`, `modalOpNorm`, `temporalNorm`: selective variant macros
- `modalNormAt`, `modalNormAll`: hypothesis-targeting variants

### Fold Direction (Phase 2-3)
- `EnrichedFormula`: ADT with 21 constructors (6 primitive + 15 enriched)
- `Formula.foldFormula`: greedy bottom-up fold from primitives to enriched
- `EnrichedFormula.toPrimitive`: inverse direction (enriched to primitives)
- Fold-direction simp lemmas for unambiguous patterns
- `modalFold` macro: fold primitives back to derived operators

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

- Research reports: 01_normalization-seed.md, 02_modal-norm-research.md
-/

namespace FormalSystem.Automation.Normalization

open FormalSystem.Syntax
open FormalSystem.Syntax.Formula

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

/-- Unfold someFuture: `someFuture φ = φ.untl (bot.imp bot)` -/
@[simp] theorem some_future_unfold (φ : Formula) :
    φ.someFuture = φ.untl (bot.imp bot) := rfl

/-- Unfold somePast: `somePast φ = φ.snce (bot.imp bot)` -/
@[simp] theorem some_past_unfold (φ : Formula) :
    φ.somePast = φ.snce (bot.imp bot) := rfl

/-! ### Level 3: Depend on Level 2 operators -/

/-- Unfold allFuture: `allFuture φ = ((φ.imp bot).untl (bot.imp bot)).imp bot` -/
@[simp] theorem all_future_unfold (φ : Formula) :
    φ.allFuture = ((φ.imp bot).untl (bot.imp bot)).imp bot := rfl

/-- Unfold allPast: `allPast φ = ((φ.imp bot).snce (bot.imp bot)).imp bot` -/
@[simp] theorem all_past_unfold (φ : Formula) :
    φ.allPast = ((φ.imp bot).snce (bot.imp bot)).imp bot := rfl

/-! ### Level 4: Depend on Level 3 operators -/

/-- Unfold weakFuture: `weakFuture φ = and φ (allFuture φ)` expanded to primitives -/
@[simp] theorem weak_future_unfold (φ : Formula) :
    φ.weakFuture =
      (φ.imp ((((φ.imp bot).untl (bot.imp bot)).imp bot).imp bot)).imp bot := rfl

/-- Unfold weakPast: `weakPast φ = and φ (allPast φ)` expanded to primitives -/
@[simp] theorem weak_past_unfold (φ : Formula) :
    φ.weakPast =
      (φ.imp ((((φ.imp bot).snce (bot.imp bot)).imp bot).imp bot)).imp bot := rfl

/-! ### Level 5: Depend on Level 4 operators -/

/-- Unfold always: `always φ = and (allPast φ) (and φ (allFuture φ))` -/
@[simp] theorem always_unfold (φ : Formula) :
    φ.always = φ.allPast.and (φ.and φ.allFuture) := rfl

/-! ### Level 6: Depend on Level 5 operators -/

/-- Unfold sometimes: `sometimes φ = neg (always (neg φ))` -/
@[simp] theorem sometimes_unfold (φ : Formula) :
    φ.sometimes = φ.neg.always.neg := rfl

/-! ### Level 7: Strong Release and Strong Trigger (depend on Level 2 operators) -/

/-- Unfold strongRelease: `strongRelease φ ψ = untl (and ψ φ) ψ` -/
@[simp] theorem strong_release_unfold (φ ψ : Formula) :
    Formula.strongRelease φ ψ = Formula.untl (Formula.and ψ φ) ψ := rfl

/-- Unfold strongTrigger: `strongTrigger φ ψ = snce (and ψ φ) ψ` -/
@[simp] theorem strong_trigger_unfold (φ ψ : Formula) :
    Formula.strongTrigger φ ψ = Formula.snce (Formula.and ψ φ) ψ := rfl

/-! ### Level 8: Release, Weak Until, Trigger, Weak Since (depend on Level 2/3 operators) -/

/-- Unfold release: `release φ ψ = neg (untl (neg φ) (neg ψ))` -/
@[simp] theorem release_unfold (φ ψ : Formula) :
    Formula.release φ ψ = ((φ.neg.untl ψ.neg).neg) := rfl

/-- Unfold weakUntil: `weakUntil φ ψ = or (untl φ ψ) (allFuture ψ)` -/
@[simp] theorem weak_until_unfold (φ ψ : Formula) :
    Formula.weakUntil φ ψ = ((φ.untl ψ).or ψ.allFuture) := rfl

/-- Unfold trigger: `trigger φ ψ = neg (snce (neg φ) (neg ψ))` -/
@[simp] theorem trigger_unfold (φ ψ : Formula) :
    Formula.trigger φ ψ = ((φ.neg.snce ψ.neg).neg) := rfl

/-- Unfold weakSince: `weakSince φ ψ = or (snce φ ψ) (allPast ψ)` -/
@[simp] theorem weak_since_unfold (φ ψ : Formula) :
    Formula.weakSince φ ψ = ((φ.snce ψ).or ψ.allPast) := rfl

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
macro "modalNorm" : tactic =>
  `(tactic| simp only [
    neg_unfold, top_unfold, next_unfold, prev_unfold,
    and_unfold, or_unfold, diamond_unfold, some_future_unfold, some_past_unfold,
    all_future_unfold, all_past_unfold,
    weak_future_unfold, weak_past_unfold,
    always_unfold, sometimes_unfold,
    strong_release_unfold, strong_trigger_unfold,
    release_unfold, weak_until_unfold, trigger_unfold, weak_since_unfold])

/-- Propositional normalization only: unfolds neg, top, and, or. -/
macro "propNorm" : tactic =>
  `(tactic| simp only [neg_unfold, top_unfold, and_unfold, or_unfold])

/-- Modal operator normalization only: unfolds diamond. -/
macro "modalOpNorm" : tactic =>
  `(tactic| simp only [diamond_unfold])

/-- Temporal normalization only: unfolds next, prev, someFuture, somePast,
    allFuture, allPast, weakFuture, weakPast, always, sometimes. -/
macro "temporalNorm" : tactic =>
  `(tactic| simp only [
    next_unfold, prev_unfold,
    some_future_unfold, some_past_unfold,
    all_future_unfold, all_past_unfold,
    weak_future_unfold, weak_past_unfold,
    always_unfold, sometimes_unfold])

/-- Normalize at a specific hypothesis. -/
syntax "modalNormAt" ident : tactic
macro_rules
  | `(tactic| modalNormAt $h) =>
    `(tactic| (simp only [
      neg_unfold, top_unfold, next_unfold, prev_unfold,
      and_unfold, or_unfold, diamond_unfold, some_future_unfold, some_past_unfold,
      all_future_unfold, all_past_unfold,
      weak_future_unfold, weak_past_unfold,
      always_unfold, sometimes_unfold,
      strong_release_unfold, strong_trigger_unfold,
      release_unfold, weak_until_unfold, trigger_unfold, weak_since_unfold] at $h:ident))

/-- Normalize all hypotheses and the goal. -/
macro "modalNormAll" : tactic =>
  `(tactic| simp only [
    neg_unfold, top_unfold, next_unfold, prev_unfold,
    and_unfold, or_unfold, diamond_unfold, some_future_unfold, some_past_unfold,
    all_future_unfold, all_past_unfold,
    weak_future_unfold, weak_past_unfold,
    always_unfold, sometimes_unfold,
    strong_release_unfold, strong_trigger_unfold,
    release_unfold, weak_until_unfold, trigger_unfold, weak_since_unfold] at *)

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
#check @strong_release_unfold
#check @strong_trigger_unfold

-- Test: modalNorm reduces always (uses multiple unfold rounds)
example (p : Atom) : (atom p).always =
    (atom p).allPast.and ((atom p).and (atom p).allFuture) := by
  simp only [always_unfold]

-- Test: modalNorm reduces diamond to primitives
example (p : Atom) : (atom p).diamond = ((atom p).imp bot).box.imp bot := by
  modalNorm

-- Test: selective propNorm preserves diamond (only unfolds neg, not diamond)
example (p : Atom) : (atom p).diamond.neg = ((atom p).diamond).imp bot := by
  simp only [neg_unfold]

-- Test: modalOpNorm unfolds diamond
example (p : Atom) : (atom p).diamond = ((atom p).neg).box.neg := by
  rfl  -- diamond is definitionally neg(box(neg φ))

-- Test: temporalNorm unfolds temporal operators
example (p : Atom) : (atom p).someFuture = (atom p).untl (bot.imp bot) := by
  temporalNorm

-- Test: modalNorm reduces conjunction
example (p q : Atom) : (atom p).and (atom q) =
    ((atom p).imp ((atom q).imp bot)).imp bot := by
  modalNorm

-- Test: modalNorm reduces disjunction
example (p q : Atom) : (atom p).or (atom q) =
    ((atom p).imp bot).imp (atom q) := by
  modalNorm

end UnfoldTests

/-!
## Phase 2: EnrichedFormula ADT and Fold Algorithm

The `EnrichedFormula` type mirrors `Formula` but adds constructors for all 15
derived operators. The `foldFormula` function performs bottom-up greedy pattern
matching to reconstitute derived operators from their primitive expansions.

### Ambiguity Analysis

| Pattern | Matches | Resolution |
|---------|---------|------------|
| `imp φ bot` | `neg φ` | Unambiguous: always fold to `neg` |
| `imp bot bot` | `top` (also `neg bot`) | Unambiguous: fold to `top` (special case of `neg`) |
| `imp (imp φ bot) ψ` | `or φ ψ` OR `imp (neg φ) ψ` | AMBIGUOUS: fold to `or_` when ψ is not `bot` |
| `imp (imp φ (imp ψ bot)) bot` | `and φ ψ` | Unambiguous after `neg` recognition |
| `imp (box (imp φ bot)) bot` | `diamond φ` | Unambiguous after `neg` recognition |
| `untl φ (imp bot bot)` | `someFuture φ` | Unambiguous: guard is `top` |
| `snce φ (imp bot bot)` | `somePast φ` | Unambiguous: guard is `top` |
| `untl φ bot` | `next φ` | Unambiguous: guard is `bot` |
| `snce φ bot` | `prev φ` | Unambiguous: guard is `bot` |

Higher-level operators are recognized compositionally after folding subformulas.
-/

/--
Enriched formula type with constructors for all derived operators.

Has 21 constructors: 6 primitive (matching `Formula`) plus 15 enriched
(one for each derived operator).
-/
inductive EnrichedFormula : Type where
  /-- Propositional atom -/
  | atom : Atom → EnrichedFormula
  /-- Bottom (falsum) -/
  | bot : EnrichedFormula
  /-- Implication -/
  | imp : EnrichedFormula → EnrichedFormula → EnrichedFormula
  /-- Modal necessity (box) -/
  | box : EnrichedFormula → EnrichedFormula
  /-- Until (temporal) -/
  | untl : EnrichedFormula → EnrichedFormula → EnrichedFormula
  /-- Since (temporal) -/
  | snce : EnrichedFormula → EnrichedFormula → EnrichedFormula
  /-- Negation (derived: φ → ⊥) -/
  | neg : EnrichedFormula → EnrichedFormula
  /-- Top/verum (derived: ⊥ → ⊥) -/
  | top : EnrichedFormula
  /-- Conjunction (derived: ¬(φ → ¬ψ)) -/
  | and_ : EnrichedFormula → EnrichedFormula → EnrichedFormula
  /-- Disjunction (derived: ¬φ → ψ) -/
  | or_ : EnrichedFormula → EnrichedFormula → EnrichedFormula
  /-- Modal possibility/diamond (derived: ¬□¬φ) -/
  | diamond : EnrichedFormula → EnrichedFormula
  /-- Some future / F (derived: U(φ, ⊤)) -/
  | some_future : EnrichedFormula → EnrichedFormula
  /-- Some past / P (derived: S(φ, ⊤)) -/
  | some_past : EnrichedFormula → EnrichedFormula
  /-- All future / G (derived: ¬F(¬φ)) -/
  | all_future : EnrichedFormula → EnrichedFormula
  /-- All past / H (derived: ¬P(¬φ)) -/
  | all_past : EnrichedFormula → EnrichedFormula
  /-- Next / X (derived: U(φ, ⊥)) -/
  | next : EnrichedFormula → EnrichedFormula
  /-- Previous / Y (derived: S(φ, ⊥)) -/
  | prev : EnrichedFormula → EnrichedFormula
  /-- Weak future / G' (derived: φ ∧ Gφ) -/
  | weak_future : EnrichedFormula → EnrichedFormula
  /-- Weak past / H' (derived: φ ∧ Hφ) -/
  | weak_past : EnrichedFormula → EnrichedFormula
  /-- Always / △ (derived: Hφ ∧ (φ ∧ Gφ)) -/
  | always : EnrichedFormula → EnrichedFormula
  /-- Sometimes / ▽ (derived: ¬△(¬φ)) -/
  | sometimes : EnrichedFormula → EnrichedFormula
  /-- Strong Release / M (derived: ψ U (ψ ∧ φ)) -/
  | strong_release : EnrichedFormula → EnrichedFormula → EnrichedFormula
  /-- Strong Trigger / ST (derived: ψ S (ψ ∧ φ)) -/
  | strong_trigger : EnrichedFormula → EnrichedFormula → EnrichedFormula
  /-- Release / R (derived: ¬(¬φ U ¬ψ)) -/
  | release : EnrichedFormula → EnrichedFormula → EnrichedFormula
  /-- Weak Until / WU (derived: (φ U ψ) ∨ Gψ) -/
  | weak_until : EnrichedFormula → EnrichedFormula → EnrichedFormula
  /-- Trigger / T (derived: ¬(¬φ S ¬ψ)) -/
  | trigger : EnrichedFormula → EnrichedFormula → EnrichedFormula
  /-- Weak Since / WS (derived: (φ S ψ) ∨ Hψ) -/
  | weak_since : EnrichedFormula → EnrichedFormula → EnrichedFormula
  deriving Repr, BEq, Inhabited

namespace EnrichedFormula

/--
Convert an enriched formula back to a primitive `Formula` by expanding each
enriched constructor to its definition.
-/
def toPrimitive : EnrichedFormula → Formula
  | .atom a       => Formula.atom a
  | .bot          => Formula.bot
  | .imp φ ψ      => Formula.imp φ.toPrimitive ψ.toPrimitive
  | .box φ        => Formula.box φ.toPrimitive
  | .untl φ ψ     => Formula.untl φ.toPrimitive ψ.toPrimitive
  | .snce φ ψ     => Formula.snce φ.toPrimitive ψ.toPrimitive
  | .neg φ        => Formula.neg φ.toPrimitive
  | .top          => Formula.top
  | .and_ φ ψ     => Formula.and φ.toPrimitive ψ.toPrimitive
  | .or_ φ ψ      => Formula.or φ.toPrimitive ψ.toPrimitive
  | .diamond φ    => Formula.diamond φ.toPrimitive
  | .some_future φ => Formula.someFuture φ.toPrimitive
  | .some_past φ  => Formula.somePast φ.toPrimitive
  | .all_future φ => Formula.allFuture φ.toPrimitive
  | .all_past φ   => Formula.allPast φ.toPrimitive
  | .next φ       => Formula.next φ.toPrimitive
  | .prev φ       => Formula.prev φ.toPrimitive
  | .weak_future φ => Formula.weakFuture φ.toPrimitive
  | .weak_past φ  => Formula.weakPast φ.toPrimitive
  | .always φ     => Formula.always φ.toPrimitive
  | .sometimes φ  => Formula.sometimes φ.toPrimitive
  | .strong_release φ ψ => Formula.strongRelease φ.toPrimitive ψ.toPrimitive
  | .strong_trigger φ ψ => Formula.strongTrigger φ.toPrimitive ψ.toPrimitive
  | .release φ ψ  => Formula.release φ.toPrimitive ψ.toPrimitive
  | .weak_until φ ψ => Formula.weakUntil φ.toPrimitive ψ.toPrimitive
  | .trigger φ ψ  => Formula.trigger φ.toPrimitive ψ.toPrimitive
  | .weak_since φ ψ => Formula.weakSince φ.toPrimitive ψ.toPrimitive

end EnrichedFormula

/--
Greedy bottom-up fold: convert a primitive `Formula` into an `EnrichedFormula`
by pattern-matching against derived operator definitions.

The algorithm:
1. Recursively fold all subformulas first (bottom-up)
2. At each node, attempt to match the primitive pattern against derived operators
3. Try higher-level operators first (so compositions are recognized)
4. For ambiguous patterns, use conservative resolution

### Pattern matching order at `imp` nodes:
- `imp bot bot` → `top`
- `imp (imp φ (imp ψ bot)) bot` → check if it's `and_` (via neg recognition)
- `imp (box (neg φ)) bot` → `diamond φ`
- `imp (neg (neg φ).someFuture) bot` → check for `allFuture`
- `imp (neg (neg φ).somePast) bot` → check for `allPast`
- `imp φ bot` → `neg φ`
- `imp (neg φ) ψ` → `or_ φ ψ` (when not further matchable)

### Pattern matching order at `untl` nodes:
- `untl φ top` → `someFuture φ`
- `untl φ bot` → `next φ`

### Pattern matching order at `snce` nodes:
- `snce φ top` → `somePast φ`
- `snce φ bot` → `prev φ`
-/
def _root_.FormalSystem.Syntax.Formula.foldFormula : Formula → EnrichedFormula
  | Formula.atom a => .atom a
  | Formula.bot => .bot
  | Formula.box φ => .box φ.foldFormula
  | Formula.untl φ ψ =>
    let φ' := φ.foldFormula
    let ψ' := ψ.foldFormula
    match ψ' with
    | .top => .some_future φ'
    | .bot => .next φ'
    | _ =>
      -- strongRelease φ ψ = untl (and ψ φ) ψ: left is `and_ g b` with g == ψ'
      match φ' with
      | .and_ a b => if a == ψ' then .strong_release b ψ' else .untl φ' ψ'
      | _ => .untl φ' ψ'
  | Formula.snce φ ψ =>
    let φ' := φ.foldFormula
    let ψ' := ψ.foldFormula
    match ψ' with
    | .top => .some_past φ'
    | .bot => .prev φ'
    | _ =>
      -- strongTrigger φ ψ = snce (and ψ φ) ψ: left is `and_ g b` with g == ψ'
      match φ' with
      | .and_ a b => if a == ψ' then .strong_trigger b ψ' else .snce φ' ψ'
      | _ => .snce φ' ψ'
  | Formula.imp φ ψ =>
    let φ' := φ.foldFormula
    let ψ' := ψ.foldFormula
    -- Try to recognize derived operators from the folded subformulas
    foldImp φ' ψ'
where
  /-- Helper: recognize derived operators at imp nodes after subformulas are folded.
      This function examines already-folded enriched subformulas to recognize
      higher-level derived operator patterns. -/
  foldImp (left right : EnrichedFormula) : EnrichedFormula :=
    match left, right with
    -- imp bot bot → top
    | .bot, .bot => .top
    -- imp (box (neg φ)) bot → diamond φ
    | .box (.neg φ), .bot => .diamond φ
    -- imp (imp φ (neg ψ)) bot → could be and_ φ ψ
    -- After folding, this appears as: imp (imp φ' (neg ψ')) bot
    -- which is neg (imp φ' (neg ψ')) = and_ φ' ψ'
    -- But we need to be careful: the inner `neg` was already folded.
    -- Pattern: neg (imp φ (neg ψ)) = and φ ψ
    --
    -- imp(someFuture(neg φ)) bot → allFuture φ
    | .some_future (.neg φ), .bot => .all_future φ
    -- imp(somePast(neg φ)) bot → allPast φ
    | .some_past (.neg φ), .bot => .all_past φ
    -- release φ ψ = ¬(¬φ U ¬ψ) = imp (untl (neg φ) (neg ψ)) bot
    -- Placed after the someFuture/somePast ⊥-guards so `release(φ,⊥)` (which folds
    -- to `someFuture (neg φ)` via the ⊤-collapse of `neg ⊥`) still routes to allFuture.
    | .untl (.neg φ) (.neg ψ), .bot => .release φ ψ
    -- trigger φ ψ = ¬(¬φ S ¬ψ) = imp (snce (neg φ) (neg ψ)) bot
    | .snce (.neg φ) (.neg ψ), .bot => .trigger φ ψ
    -- imp (and_ (allPast φ) (and_ ψ (allFuture χ))) bot where φ = neg α, ψ = neg α, χ = neg α
    -- This is neg(always(neg α)) = sometimes α
    -- After folding always: neg(always(neg α))
    -- But always is recognized later, so we check for sometimes pattern:
    -- neg (and_ (allPast φ) (and_ ψ (allFuture χ))) where φ, ψ, χ are all neg of the same formula
    -- However, this would require always to be recognized first. We handle this differently below.
    --
    -- General neg: imp φ bot → neg φ
    -- After neg, check if the result forms a higher-level operator
    | left', .bot =>
      -- Check specific patterns first (most specific to least specific)
      match left' with
      -- Check for weakFuture: neg (imp φ (neg (allFuture φ')))
      -- where φ = φ'. This is and_ φ (allFuture φ) = weakFuture φ
      | .imp φ (.neg (.all_future φ')) =>
        if φ == φ' then .weak_future φ else .and_ φ (.all_future φ')
      -- Check for weakPast: neg (imp φ (neg (allPast φ')))
      | .imp φ (.neg (.all_past φ')) =>
        if φ == φ' then .weak_past φ else .and_ φ (.all_past φ')
      -- Check for and_: neg (imp φ (neg ψ)) = and φ ψ
      | .imp φ (.neg ψ) => .and_ φ ψ
      | _ => .neg left'
    -- imp (neg φ) ψ → AMBIGUOUS: could be or_ φ ψ or imp (neg φ) ψ
    -- Conservative: do NOT fold to or_ during initial pass.
    -- or_ is recognized in the post-processing step (recognizeComposites)
    -- to avoid interference with and_ recognition.
    -- Default: keep as imp
    | left', right' => .imp left' right'

/-- Post-process fold to recognize composite operators (always, sometimes, or_).
    This is applied after the initial fold to catch patterns that span
    multiple levels of the operator hierarchy.

    Recognizes:
    - `and_ (allPast φ) (and_ ψ (allFuture χ))` where φ = ψ = χ → `always φ`
    - `and_ (allPast φ) (weakFuture ψ)` where φ = ψ → `always φ`
    - `neg (always (neg φ))` → `sometimes φ`
    - `imp (neg φ) ψ` → `or_ φ ψ` (deferred from initial fold to avoid and_ interference)

    Applied bottom-up: recurse first, then match at each node.
-/
def EnrichedFormula.recognizeComposites : EnrichedFormula → EnrichedFormula
  | .atom a => .atom a
  | .bot => .bot
  | .top => .top
  | .imp φ ψ =>
    let φ' := φ.recognizeComposites
    let ψ' := ψ.recognizeComposites
    -- Recognize or_: imp (neg φ) ψ → or_ φ ψ
    match φ' with
    | .neg inner =>
      -- weakUntil φ ψ = (φ U ψ) ∨ Gψ = or_ (untl φ ψ) (allFuture ψ)
      -- weakSince φ ψ = (φ S ψ) ∨ Hψ = or_ (snce φ ψ) (allPast ψ)
      match inner, ψ' with
      | .untl a b, .all_future b' => if b == b' then .weak_until a b else .or_ inner ψ'
      | .snce a b, .all_past b'   => if b == b' then .weak_since a b else .or_ inner ψ'
      | _, _ => .or_ inner ψ'
    | _ => .imp φ' ψ'
  | .box φ => .box φ.recognizeComposites
  | .untl φ ψ => .untl φ.recognizeComposites ψ.recognizeComposites
  | .snce φ ψ => .snce φ.recognizeComposites ψ.recognizeComposites
  | .neg φ =>
    let φ' := φ.recognizeComposites
    -- Recognize sometimes: neg (always (neg φ)) → sometimes φ
    match φ' with
    | .always (.neg inner) => .sometimes inner
    | _ => .neg φ'
  | .and_ φ ψ =>
    let φ' := φ.recognizeComposites
    let ψ' := ψ.recognizeComposites
    -- Recognize always: and_ (allPast φ) (and_ ψ (allFuture χ)) where φ = ψ = χ
    match φ', ψ' with
    | .all_past a, .and_ b (.all_future c) =>
      if a == b && b == c then .always a
      else .and_ φ' ψ'
    -- Recognize always (alternative): and_ (allPast φ) (weakFuture ψ) where φ = ψ
    | .all_past a, .weak_future b =>
      if a == b then .always a
      else .and_ φ' ψ'
    | _, _ => .and_ φ' ψ'
  | .or_ φ ψ => .or_ φ.recognizeComposites ψ.recognizeComposites
  | .diamond φ => .diamond φ.recognizeComposites
  | .some_future φ => .some_future φ.recognizeComposites
  | .some_past φ => .some_past φ.recognizeComposites
  | .all_future φ => .all_future φ.recognizeComposites
  | .all_past φ => .all_past φ.recognizeComposites
  | .next φ => .next φ.recognizeComposites
  | .prev φ => .prev φ.recognizeComposites
  | .weak_future φ => .weak_future φ.recognizeComposites
  | .weak_past φ => .weak_past φ.recognizeComposites
  | .always φ => .always φ.recognizeComposites
  | .sometimes φ => .sometimes φ.recognizeComposites
  | .strong_release φ ψ => .strong_release φ.recognizeComposites ψ.recognizeComposites
  | .strong_trigger φ ψ => .strong_trigger φ.recognizeComposites ψ.recognizeComposites
  | .release φ ψ  => .release φ.recognizeComposites ψ.recognizeComposites
  | .weak_until φ ψ => .weak_until φ.recognizeComposites ψ.recognizeComposites
  | .trigger φ ψ  => .trigger φ.recognizeComposites ψ.recognizeComposites
  | .weak_since φ ψ => .weak_since φ.recognizeComposites ψ.recognizeComposites

/-- Full fold: fold primitives then recognize composite operators. -/
def _root_.FormalSystem.Syntax.Formula.foldFormulaFull (f : Formula) : EnrichedFormula :=
  f.foldFormula.recognizeComposites

/-!
## Phase 2: Fold Tests
-/

section FoldTests

-- Helper: create test atoms
private def p_atom : Atom := Atom.mkBase "p"
private def q_atom : Atom := Atom.mkBase "q"

-- Test: foldFormula on neg
-- `imp (atom p) bot` folds to `neg (atom p)`
#eval do
  let f := Formula.imp (Formula.atom p_atom) Formula.bot
  let r := f.foldFormula
  return repr r  -- should show neg (atom ...)

-- Test: foldFormula on top
-- `imp bot bot` folds to `top`
#eval do
  let f := Formula.imp Formula.bot Formula.bot
  let r := f.foldFormula
  return repr r  -- should show top

-- Test: foldFormula on diamond
-- `imp (box (imp (atom p) bot)) bot` folds to `diamond (atom p)`
#eval do
  let f := Formula.diamond (Formula.atom p_atom)  -- unfolds to the primitive
  let r := f.foldFormula
  return repr r  -- should show diamond (atom ...)

-- Test: foldFormula on and
-- `imp (imp (atom p) (imp (atom q) bot)) bot` folds to `and_ (atom p) (atom q)`
#eval do
  let f := Formula.and (Formula.atom p_atom) (Formula.atom q_atom)
  let r := f.foldFormula
  return repr r  -- should show and_ (atom ...) (atom ...)

-- Test: foldFormula on or
-- `imp (imp (atom p) bot) (atom q)` folds to `or_ (atom p) (atom q)`
#eval do
  let f := Formula.or (Formula.atom p_atom) (Formula.atom q_atom)
  let r := f.foldFormula
  return repr r  -- should show or_ (atom ...) (atom ...)

-- Test: foldFormula on someFuture
-- `untl (atom p) (imp bot bot)` folds to `someFuture (atom p)`
#eval do
  let f := Formula.someFuture (Formula.atom p_atom)
  let r := f.foldFormula
  return repr r  -- should show someFuture (atom ...)

-- Test: foldFormula on somePast
-- `snce (atom p) (imp bot bot)` folds to `somePast (atom p)`
#eval do
  let f := Formula.somePast (Formula.atom p_atom)
  let r := f.foldFormula
  return repr r  -- should show somePast (atom ...)

-- Test: foldFormula on allFuture
#eval do
  let f := Formula.allFuture (Formula.atom p_atom)
  let r := f.foldFormula
  return repr r  -- should show allFuture (atom ...)

-- Test: foldFormula on allPast
#eval do
  let f := Formula.allPast (Formula.atom p_atom)
  let r := f.foldFormula
  return repr r  -- should show allPast (atom ...)

-- Test: foldFormula on next
#eval do
  let f := Formula.next (Formula.atom p_atom)
  let r := f.foldFormula
  return repr r  -- should show next (atom ...)

-- Test: foldFormula on prev
#eval do
  let f := Formula.prev (Formula.atom p_atom)
  let r := f.foldFormula
  return repr r  -- should show prev (atom ...)

-- Test: round-trip property: toPrimitive(foldFormula(f)) = f
-- for formulas built with derived operators
#eval do
  let formulas : List Formula := [
    Formula.neg (Formula.atom p_atom),
    Formula.top,
    Formula.and (Formula.atom p_atom) (Formula.atom q_atom),
    Formula.or (Formula.atom p_atom) (Formula.atom q_atom),
    Formula.diamond (Formula.atom p_atom),
    Formula.someFuture (Formula.atom p_atom),
    Formula.somePast (Formula.atom p_atom),
    Formula.allFuture (Formula.atom p_atom),
    Formula.allPast (Formula.atom p_atom),
    Formula.next (Formula.atom p_atom),
    Formula.prev (Formula.atom p_atom)
  ]
  let results := formulas.map fun f =>
    let folded := Formula.foldFormula f
    let roundTrip := EnrichedFormula.toPrimitive folded
    (f == roundTrip, repr f, repr folded)
  return results

-- Test: weakFuture fold
#eval do
  let f := Formula.weakFuture (Formula.atom p_atom)
  let r := f.foldFormula
  return repr r  -- should show weakFuture (atom ...)

-- Test: weakPast fold
#eval do
  let f := Formula.weakPast (Formula.atom p_atom)
  let r := f.foldFormula
  return repr r  -- should show weakPast (atom ...)

-- Test: always fold (requires recognizeComposites)
#eval do
  let f := Formula.always (Formula.atom p_atom)
  let r := f.foldFormulaFull
  return repr r  -- should show always (atom ...)

-- Test: sometimes fold (requires recognizeComposites)
#eval do
  let f := Formula.sometimes (Formula.atom p_atom)
  let r := f.foldFormulaFull
  return repr r  -- should show sometimes (atom ...)

-- Test: full round-trip with composites
#eval do
  let formulas : List Formula := [
    Formula.always (Formula.atom p_atom),
    Formula.sometimes (Formula.atom p_atom),
    Formula.weakFuture (Formula.atom p_atom),
    Formula.weakPast (Formula.atom p_atom)
  ]
  let results := formulas.map fun f =>
    let folded := Formula.foldFormulaFull f
    let roundTrip := EnrichedFormula.toPrimitive folded
    (f == roundTrip, repr folded)
  return results

-- Derived binary operators fold to their own tags (not neg(untl ...) etc.).
-- Each assertion checks (a) the correct enriched tag and (b) round-trip identity.
#guard Formula.foldFormulaFull (Formula.release (Formula.atom p_atom) (Formula.atom q_atom))
  == EnrichedFormula.release (.atom p_atom) (.atom q_atom)
#guard Formula.foldFormulaFull (Formula.weakUntil (Formula.atom p_atom) (Formula.atom q_atom))
  == EnrichedFormula.weak_until (.atom p_atom) (.atom q_atom)
#guard Formula.foldFormulaFull (Formula.trigger (Formula.atom p_atom) (Formula.atom q_atom))
  == EnrichedFormula.trigger (.atom p_atom) (.atom q_atom)
#guard Formula.foldFormulaFull (Formula.weakSince (Formula.atom p_atom) (Formula.atom q_atom))
  == EnrichedFormula.weak_since (.atom p_atom) (.atom q_atom)
#guard Formula.foldFormulaFull (Formula.strongRelease (Formula.atom p_atom) (Formula.atom q_atom))
  == EnrichedFormula.strong_release (.atom p_atom) (.atom q_atom)
#guard Formula.foldFormulaFull (Formula.strongTrigger (Formula.atom p_atom) (Formula.atom q_atom))
  == EnrichedFormula.strong_trigger (.atom p_atom) (.atom q_atom)

-- Round-trip: toPrimitive ∘ foldFormulaFull = id for all 6 binary operators.
#guard [
    Formula.release (Formula.atom p_atom) (Formula.atom q_atom),
    Formula.weakUntil (Formula.atom p_atom) (Formula.atom q_atom),
    Formula.trigger (Formula.atom p_atom) (Formula.atom q_atom),
    Formula.weakSince (Formula.atom p_atom) (Formula.atom q_atom),
    Formula.strongRelease (Formula.atom p_atom) (Formula.atom q_atom),
    Formula.strongTrigger (Formula.atom p_atom) (Formula.atom q_atom)
  ].all (fun f => f == EnrichedFormula.toPrimitive (Formula.foldFormulaFull f))

-- Regression (report §8 / plan risk): release(p, ⊥) still folds to allFuture p,
-- because `neg ⊥` collapses to ⊤ and the someFuture ⊥-guard fires first.
#guard Formula.foldFormulaFull (Formula.release (Formula.atom p_atom) Formula.bot)
  == EnrichedFormula.all_future (.atom p_atom)

end FoldTests

/-!
## Phase 3: Fold-Direction Simp Lemmas and Round-Trip Tests

Fold-direction simp lemmas rewrite primitive patterns back to derived operators.
These are the reverse of the unfold lemmas. Only unambiguous patterns get fold lemmas;
`or_fold` is deliberately omitted due to the `imp(neg A, B)` ambiguity.

### Omitted fold lemmas (with rationale)
- `or_fold`: Omitted because `(φ.imp bot).imp ψ` could be either `or φ ψ` or
  `imp (neg φ) ψ`. The pattern is ambiguous -- we cannot distinguish these
  at the syntactic level.
- `sometimes_fold`: Would require matching the full `always` expansion of `neg φ`
  then wrapping in `neg`. The pattern is too complex for a single simp lemma;
  use `foldFormulaFull` instead.
- `always_fold`: Similarly complex multi-level pattern. Use `foldFormulaFull`.
- `weak_future_fold`, `weak_past_fold`: These overlap with `and_fold` when the
  second argument happens to be `allFuture`/`allPast` of the first. The fold
  macro does not include these to avoid unexpected simp interactions; they can
  be applied manually via `rw [← weak_future_unfold]`.
-/

section FoldLemmas

/-- Fold negation: `φ.imp bot = neg φ` -/
@[simp] theorem neg_fold (φ : Formula) : φ.imp bot = neg φ := rfl

/-- Fold top: `bot.imp bot = top` -/
@[simp] theorem top_fold : bot.imp bot = Formula.top := rfl

/-- Fold conjunction: `(φ.imp (ψ.neg)).neg = and φ ψ` -/
@[simp] theorem and_fold (φ ψ : Formula) :
    (φ.imp (ψ.imp bot)).imp bot = Formula.and φ ψ := rfl

/-- Fold diamond: `(φ.neg.box).neg = diamond φ` -/
@[simp] theorem diamond_fold (φ : Formula) :
    ((φ.imp bot).box).imp bot = diamond φ := rfl

/-- Fold someFuture: `untl φ top = someFuture φ` -/
@[simp] theorem some_future_fold (φ : Formula) :
    φ.untl (bot.imp bot) = someFuture φ := rfl

/-- Fold somePast: `snce φ top = somePast φ` -/
@[simp] theorem some_past_fold (φ : Formula) :
    φ.snce (bot.imp bot) = somePast φ := rfl

/-- Fold next: `untl φ bot = next φ` -/
@[simp] theorem next_fold (φ : Formula) :
    φ.untl bot = next φ := rfl

/-- Fold prev: `snce φ bot = prev φ` -/
@[simp] theorem prev_fold (φ : Formula) :
    φ.snce bot = prev φ := rfl

/-- Fold allFuture: `(φ.neg.someFuture).neg = allFuture φ` -/
@[simp] theorem all_future_fold (φ : Formula) :
    ((φ.imp bot).untl (bot.imp bot)).imp bot = allFuture φ := rfl

/-- Fold allPast: `(φ.neg.somePast).neg = allPast φ` -/
@[simp] theorem all_past_fold (φ : Formula) :
    ((φ.imp bot).snce (bot.imp bot)).imp bot = allPast φ := rfl

end FoldLemmas

section FoldTactics

/-- Fold primitives back to derived operators where unambiguous.
    Uses the `← _unfold` pattern to reverse unfold lemmas. -/
macro "modalFold" : tactic =>
  `(tactic| simp only [
    ← neg_unfold, ← top_unfold, ← next_unfold, ← prev_unfold,
    ← and_unfold, ← diamond_unfold,
    ← some_future_unfold, ← some_past_unfold,
    ← all_future_unfold, ← all_past_unfold,
    ← weak_future_unfold, ← weak_past_unfold,
    ← always_unfold, ← sometimes_unfold,
    ← strong_release_unfold, ← strong_trigger_unfold])

end FoldTactics

section RoundTripTests

-- Round-trip tactic tests: modalNorm followed by modalFold
-- For unambiguous operators, the unfold/fold cycle recovers the original.
-- (Since both sides of the equality are identical, modalNorm rewrites both
-- and the goal closes immediately. This tests that modalNorm does not get stuck.)

-- Test: neg round-trip
example (φ : Formula) : φ.neg = φ.neg := by modalNorm

-- Test: top round-trip
example : Formula.top = Formula.top := by modalNorm

-- Test: diamond round-trip
example (φ : Formula) : φ.diamond = φ.diamond := by modalNorm

-- Test: and round-trip
example (φ ψ : Formula) : Formula.and φ ψ = Formula.and φ ψ := by modalNorm

-- Test: someFuture/somePast round-trip
example (φ : Formula) : someFuture φ = someFuture φ := by modalNorm
example (φ : Formula) : somePast φ = somePast φ := by modalNorm

-- Test: allFuture/allPast round-trip
example (φ : Formula) : allFuture φ = allFuture φ := by modalNorm
example (φ : Formula) : allPast φ = allPast φ := by modalNorm

-- Test: next/prev round-trip
example (φ : Formula) : next φ = next φ := by modalNorm
example (φ : Formula) : prev φ = prev φ := by modalNorm

-- Test: weakFuture/weakPast round-trip
example (φ : Formula) : weakFuture φ = weakFuture φ := by modalNorm
example (φ : Formula) : weakPast φ = weakPast φ := by modalNorm

-- Test: always/sometimes round-trip
example (φ : Formula) : always φ = always φ := by modalNorm
example (φ : Formula) : sometimes φ = sometimes φ := by modalNorm

-- Test: modalFold recovers derived operators from primitive form
-- These tests verify that modalFold actually does work on primitive-form goals.
example (φ : Formula) : φ.imp Formula.bot = φ.neg := by modalFold
example (φ : Formula) : φ.untl Formula.bot = φ.next := by modalFold
example (φ : Formula) : φ.snce Formula.bot = φ.prev := by modalFold

-- Test: fold lemmas work individually via rw
example (φ ψ : Formula) :
    (φ.imp (ψ.imp Formula.bot)).imp Formula.bot = Formula.and φ ψ := by
  rw [← and_unfold]
example (φ : Formula) :
    ((φ.imp Formula.bot).box).imp Formula.bot = φ.diamond := by
  rw [← diamond_unfold]

-- Test: foldFormula/toPrimitive round-trip for enumerated formulas at complexity <= 5
-- (Uses `#eval` for computable verification)
#eval do
  let p := Atom.mkBase "p"
  let q := Atom.mkBase "q"
  let testFormulas : List Formula := [
    Formula.atom p, Formula.bot,
    Formula.neg (Formula.atom p), Formula.top,
    Formula.next (Formula.atom p), Formula.prev (Formula.atom p),
    Formula.and (Formula.atom p) (Formula.atom q),
    Formula.or (Formula.atom p) (Formula.atom q),
    Formula.diamond (Formula.atom p),
    Formula.someFuture (Formula.atom p), Formula.somePast (Formula.atom p),
    Formula.allFuture (Formula.atom p), Formula.allPast (Formula.atom p),
    Formula.neg (Formula.neg (Formula.atom p)),
    Formula.diamond (Formula.diamond (Formula.atom p)),
    Formula.box (Formula.neg (Formula.atom p)),
    Formula.imp (Formula.atom p) (Formula.atom q),
    Formula.weakFuture (Formula.atom p), Formula.weakPast (Formula.atom p),
    Formula.always (Formula.atom p), Formula.sometimes (Formula.atom p)
  ]
  let results := testFormulas.map fun f =>
    let folded := Formula.foldFormulaFull f
    let roundTrip := EnrichedFormula.toPrimitive folded
    f == roundTrip
  let allPass := results.all id
  let failCount := results.filter (! ·) |>.length
  return s!"Round-trip test: {if allPass then "ALL PASS" else s!"FAILURES: {failCount}"} ({testFormulas.length} formulas tested)"

end RoundTripTests

/-!
## Phase 4: JSON Serialization for Enriched Formulas

Provides JSON, pretty-print, and S-expression serialization for `EnrichedFormula`.
Uses enriched operator tags (e.g., `"neg"`, `"diamond"`, `"always"`) instead of
only primitive tags, enabling richer training data for the BimodalHarness pipeline.
-/

section Serialization

/-- Escape a string for inclusion in a JSON string value. -/
private def escapeJson (s : String) : String :=
  s.toList.foldl (fun acc c =>
    match c with
    | '\\' => acc ++ "\\\\"
    | '"'  => acc ++ "\\\""
    | '\n' => acc ++ "\\n"
    | c    => acc.push c
  ) ""

namespace EnrichedFormula

/--
Serialize an `EnrichedFormula` to a JSON string with enriched operator tags.

The JSON schema uses a `"tag"` field for the constructor:
- Primitives: `"atom"`, `"bot"`, `"imp"`, `"box"`, `"untl"`, `"snce"`
- Enriched: `"neg"`, `"top"`, `"and"`, `"or"`, `"diamond"`, `"someFuture"`,
  `"somePast"`, `"allFuture"`, `"allPast"`, `"next"`, `"prev"`,
  `"weakFuture"`, `"weakPast"`, `"always"`, `"sometimes"`

Child fields: `"child"` for unary, `"left"`/`"right"` for binary,
`"event"`/`"guard"` for temporal binary operators.
-/
def toJson : EnrichedFormula → String
  | .atom a =>
    let nameStr := escapeJson a.base
    "{\"tag\": \"atom\", \"name\": \"" ++ nameStr ++ "\"}"
  | .bot => "{\"tag\": \"bot\"}"
  | .top => "{\"tag\": \"top\"}"
  | .imp φ ψ =>
    "{\"tag\": \"imp\", \"left\": " ++ φ.toJson ++ ", \"right\": " ++ ψ.toJson ++ "}"
  | .box φ =>
    "{\"tag\": \"box\", \"child\": " ++ φ.toJson ++ "}"
  | .untl φ ψ =>
    "{\"tag\": \"untl\", \"event\": " ++ φ.toJson ++ ", \"guard\": " ++ ψ.toJson ++ "}"
  | .snce φ ψ =>
    "{\"tag\": \"snce\", \"event\": " ++ φ.toJson ++ ", \"guard\": " ++ ψ.toJson ++ "}"
  | .neg φ =>
    "{\"tag\": \"neg\", \"child\": " ++ φ.toJson ++ "}"
  | .and_ φ ψ =>
    "{\"tag\": \"and\", \"left\": " ++ φ.toJson ++ ", \"right\": " ++ ψ.toJson ++ "}"
  | .or_ φ ψ =>
    "{\"tag\": \"or\", \"left\": " ++ φ.toJson ++ ", \"right\": " ++ ψ.toJson ++ "}"
  | .diamond φ =>
    "{\"tag\": \"diamond\", \"child\": " ++ φ.toJson ++ "}"
  | .some_future φ =>
    "{\"tag\": \"someFuture\", \"child\": " ++ φ.toJson ++ "}"
  | .some_past φ =>
    "{\"tag\": \"somePast\", \"child\": " ++ φ.toJson ++ "}"
  | .all_future φ =>
    "{\"tag\": \"allFuture\", \"child\": " ++ φ.toJson ++ "}"
  | .all_past φ =>
    "{\"tag\": \"allPast\", \"child\": " ++ φ.toJson ++ "}"
  | .next φ =>
    "{\"tag\": \"next\", \"child\": " ++ φ.toJson ++ "}"
  | .prev φ =>
    "{\"tag\": \"prev\", \"child\": " ++ φ.toJson ++ "}"
  | .weak_future φ =>
    "{\"tag\": \"weakFuture\", \"child\": " ++ φ.toJson ++ "}"
  | .weak_past φ =>
    "{\"tag\": \"weakPast\", \"child\": " ++ φ.toJson ++ "}"
  | .always φ =>
    "{\"tag\": \"always\", \"child\": " ++ φ.toJson ++ "}"
  | .sometimes φ =>
    "{\"tag\": \"sometimes\", \"child\": " ++ φ.toJson ++ "}"
  | .strong_release φ ψ =>
    "{\"tag\": \"strongRelease\", \"left\": " ++ φ.toJson ++ ", \"right\": " ++ ψ.toJson ++ "}"
  | .strong_trigger φ ψ =>
    "{\"tag\": \"strongTrigger\", \"left\": " ++ φ.toJson ++ ", \"right\": " ++ ψ.toJson ++ "}"
  | .release φ ψ =>
    "{\"tag\": \"release\", \"left\": " ++ φ.toJson ++ ", \"right\": " ++ ψ.toJson ++ "}"
  | .weak_until φ ψ =>
    "{\"tag\": \"weakUntil\", \"left\": " ++ φ.toJson ++ ", \"right\": " ++ ψ.toJson ++ "}"
  | .trigger φ ψ =>
    "{\"tag\": \"trigger\", \"left\": " ++ φ.toJson ++ ", \"right\": " ++ ψ.toJson ++ "}"
  | .weak_since φ ψ =>
    "{\"tag\": \"weakSince\", \"left\": " ++ φ.toJson ++ ", \"right\": " ++ ψ.toJson ++ "}"

/--
Pretty-print an `EnrichedFormula` in human-readable notation.

Uses standard logical notation:
- `neg φ` → `"~φ"`, `and_ φ ψ` → `"(φ & ψ)"`, `or_ φ ψ` → `"(φ | ψ)"`
- `diamond φ` → `"<>φ"`, `box φ` → `"[]φ"`
- `allFuture φ` → `"Gφ"`, `allPast φ` → `"Hφ"`
- `someFuture φ` → `"Fφ"`, `somePast φ` → `"Pφ"`
- `always φ` → `"△φ"`, `sometimes φ` → `"▽φ"`
- `weakFuture φ` → `"G'φ"`, `weakPast φ` → `"H'φ"`
- `next φ` → `"Xφ"`, `prev φ` → `"Yφ"`
-/
def prettyPrint : EnrichedFormula → String
  | .atom a       => a.base
  | .bot          => "⊥"
  | .top          => "⊤"
  | .imp φ ψ      => "(" ++ φ.prettyPrint ++ " → " ++ ψ.prettyPrint ++ ")"
  | .box φ        => "□" ++ φ.prettyPrint
  | .untl φ ψ     => "U(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"
  | .snce φ ψ     => "S(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"
  | .neg φ        => "~" ++ φ.prettyPrint
  | .and_ φ ψ     => "(" ++ φ.prettyPrint ++ " & " ++ ψ.prettyPrint ++ ")"
  | .or_ φ ψ      => "(" ++ φ.prettyPrint ++ " | " ++ ψ.prettyPrint ++ ")"
  | .diamond φ    => "<>" ++ φ.prettyPrint
  | .some_future φ => "F" ++ φ.prettyPrint
  | .some_past φ  => "P" ++ φ.prettyPrint
  | .all_future φ => "G" ++ φ.prettyPrint
  | .all_past φ   => "H" ++ φ.prettyPrint
  | .next φ       => "X" ++ φ.prettyPrint
  | .prev φ       => "Y" ++ φ.prettyPrint
  | .weak_future φ => "G'" ++ φ.prettyPrint
  | .weak_past φ  => "H'" ++ φ.prettyPrint
  | .always φ     => "△" ++ φ.prettyPrint
  | .sometimes φ  => "▽" ++ φ.prettyPrint
  | .strong_release φ ψ => "M(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"
  | .strong_trigger φ ψ => "ST(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"
  | .release φ ψ  => "R(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"
  | .weak_until φ ψ => "WU(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"
  | .trigger φ ψ  => "T(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"
  | .weak_since φ ψ => "WS(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"

/--
Serialize an `EnrichedFormula` to an S-expression string with enriched tags.

Uses parenthesized prefix notation:
- `(neg (atom "p"))`, `(and (atom "p") (atom "q"))`, `(diamond (atom "p"))`, etc.
-/
def toSExpr : EnrichedFormula → String
  | .atom a =>
    let idx := match a.freshIndex with
      | none => ""
      | some n => " " ++ toString n
    "(atom \"" ++ escapeJson a.base ++ "\"" ++ idx ++ ")"
  | .bot          => "bot"
  | .top          => "top"
  | .imp φ ψ      => "(imp " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
  | .box φ        => "(box " ++ φ.toSExpr ++ ")"
  | .untl φ ψ     => "(untl " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
  | .snce φ ψ     => "(snce " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
  | .neg φ        => "(neg " ++ φ.toSExpr ++ ")"
  | .and_ φ ψ     => "(and " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
  | .or_ φ ψ      => "(or " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
  | .diamond φ    => "(diamond " ++ φ.toSExpr ++ ")"
  | .some_future φ => "(someFuture " ++ φ.toSExpr ++ ")"
  | .some_past φ  => "(somePast " ++ φ.toSExpr ++ ")"
  | .all_future φ => "(allFuture " ++ φ.toSExpr ++ ")"
  | .all_past φ   => "(allPast " ++ φ.toSExpr ++ ")"
  | .next φ       => "(next " ++ φ.toSExpr ++ ")"
  | .prev φ       => "(prev " ++ φ.toSExpr ++ ")"
  | .weak_future φ => "(weakFuture " ++ φ.toSExpr ++ ")"
  | .weak_past φ  => "(weakPast " ++ φ.toSExpr ++ ")"
  | .always φ     => "(always " ++ φ.toSExpr ++ ")"
  | .sometimes φ  => "(sometimes " ++ φ.toSExpr ++ ")"
  | .strong_release φ ψ => "(strongRelease " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
  | .strong_trigger φ ψ => "(strongTrigger " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
  | .release φ ψ  => "(release " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
  | .weak_until φ ψ => "(weakUntil " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
  | .trigger φ ψ  => "(trigger " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
  | .weak_since φ ψ => "(weakSince " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"

end EnrichedFormula

/-- Convenience: fold a primitive `Formula` and serialize to enriched JSON. -/
def _root_.FormalSystem.Syntax.Formula.toEnrichedJson (f : Formula) : String :=
  (f.foldFormulaFull).toJson

/-- Convenience: fold a primitive `Formula` and pretty-print with enriched operators. -/
def _root_.FormalSystem.Syntax.Formula.toEnrichedPretty (f : Formula) : String :=
  (f.foldFormulaFull).prettyPrint

/-- Convenience: fold a primitive `Formula` and serialize to enriched S-expression. -/
def _root_.FormalSystem.Syntax.Formula.toEnrichedSExpr (f : Formula) : String :=
  (f.foldFormulaFull).toSExpr

end Serialization

section SerializationTests

-- Test: toJson on neg (atom p)
#eval do
  let f := EnrichedFormula.neg (.atom (Atom.mkBase "p"))
  return f.toJson
-- Expected: {"tag": "neg", "child": {"tag": "atom", "name": "p"}}

-- Test: toJson on diamond (atom p)
#eval do
  let f := EnrichedFormula.diamond (.atom (Atom.mkBase "p"))
  return f.toJson
-- Expected: {"tag": "diamond", "child": {"tag": "atom", "name": "p"}}

-- Test: toEnrichedJson on diamond formula
#eval do
  let f := Formula.diamond (Formula.atom (Atom.mkBase "p"))
  return f.toEnrichedJson
-- Expected: {"tag": "diamond", "child": {"tag": "atom", "name": "p"}}

-- Test: prettyPrint on always (atom p)
#eval do
  let f := EnrichedFormula.always (.atom (Atom.mkBase "p"))
  return f.prettyPrint
-- Expected: △p

-- Test: toSExpr on and_ (atom p) (atom q)
#eval do
  let f := EnrichedFormula.and_ (.atom (Atom.mkBase "p")) (.atom (Atom.mkBase "q"))
  return f.toSExpr
-- Expected: (and (atom "p") (atom "q"))

-- Test: toEnrichedJson on always formula (full pipeline)
#eval do
  let f := Formula.always (Formula.atom (Atom.mkBase "p"))
  return f.toEnrichedJson
-- Expected: {"tag": "always", "child": {"tag": "atom", "name": "p"}}

-- Test: prettyPrint on complex formula
#eval do
  let f := Formula.imp (Formula.diamond (Formula.atom (Atom.mkBase "p")))
                        (Formula.allFuture (Formula.atom (Atom.mkBase "q")))
  return (Formula.foldFormulaFull f).prettyPrint
-- Expected: (<>p → Gq)

end SerializationTests

/-!
## Programmatic Normalization to Primitives

`normalizeFormula` recursively traverses a formula and rebuilds it using only the
6 primitive constructors (`atom`, `bot`, `imp`, `box`, `untl`, `snce`). Since every
derived operator (`neg`, `top`, `and`, `or`, `diamond`, `always`, `sometimes`,
`next`, `prev`, `weakFuture`, `weakPast`, `allFuture`, `allPast`,
`someFuture`, `somePast`, `release`, `weakUntil`, `trigger`, `weakSince`,
`strongRelease`, `strongTrigger`) is a `def` abbreviation that Lean unfolds at
elaboration time, `normalizeFormula` is definitionally the identity function.

Its purpose is:
1. **Contract documentation**: makes explicit that the decision procedure operates
   on primitive-only formulas.
2. **Future-proofing**: if any derived operator is ever changed from `def` to
   `opaque` or `abbrev`, this function will still produce a correct normalization.
3. **External formula guard**: formulas arriving from external sources (e.g., JSON
   parsing) are guaranteed to be in primitive form after normalization.
-/

section ProgrammaticNormalization

/--
Normalize a formula to primitive constructors only.

Pattern-matches on all 6 primitive constructors of `Formula` (`atom`, `bot`,
`imp`, `box`, `untl`, `snce`) and recursively normalizes subformulas. Since
every derived operator is a `def` abbreviation that expands to these 6
constructors, this function is the identity by definitional equality.
-/
def normalizeFormula : Formula → Formula
  | .atom a    => .atom a
  | .bot       => .bot
  | .imp φ ψ   => .imp (normalizeFormula φ) (normalizeFormula ψ)
  | .box φ     => .box (normalizeFormula φ)
  | .untl φ ψ  => .untl (normalizeFormula φ) (normalizeFormula ψ)
  | .snce φ ψ  => .snce (normalizeFormula φ) (normalizeFormula ψ)

/--
`normalizeFormula` is the identity function.

Since all derived operators are `def` abbreviations that Lean unfolds
definitionally, `normalizeFormula` rebuilds exactly the same term. The
proof is by structural induction on `φ` with `rfl` at each leaf and
the inductive hypothesis at each node.
-/
@[simp] theorem normalizeFormula_id (φ : Formula) : normalizeFormula φ = φ := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp φ ψ ih_φ ih_ψ => simp [normalizeFormula, ih_φ, ih_ψ]
  | box φ ih => simp [normalizeFormula, ih]
  | untl φ ψ ih_φ ih_ψ => simp [normalizeFormula, ih_φ, ih_ψ]
  | snce φ ψ ih_φ ih_ψ => simp [normalizeFormula, ih_φ, ih_ψ]

end ProgrammaticNormalization

/-!
## Value-Level Operator Census (Phase 3)

Prior presence measurement was folded-tag based and structurally blind (report §10.3): a
census over folded tags returned zero for the binary derived operators purely because the
representation layer lacked their constructors — regardless of dataset content. Phase 2 fixed
the fold layer, so `foldFormulaFull`-based tags are now real. This section adds an *independent*
value-level census that matches the derived operators directly against their primitive
`Formula` encodings (precedent: `FormulaMutator.lean` primitive-pattern matchers), and
cross-checks it against the now-correct folded tags.

The value-level matcher inspects the *top node* of a formula and returns the derived-operator
tag if its primitive encoding is present. `⊥`-guards mirror the fold's collapse priorities so
that, e.g., `release(φ, ⊥)` (which collapses to `allFuture φ`) is NOT counted as a `release`.
-/

section OperatorCensus

/-- Value-level matcher: return the binary derived-operator tag whose primitive encoding is at
    the top node of `f`, or `none`. The `⊥`/`⊤`-guards mirror `foldFormula`'s collapse order so
    this agrees with the folded-tag census (e.g. `release(φ,⊥) = allFuture φ` is not a release).

    Primitive encodings (from `Formula` defs):
    - `release φ ψ  = ¬((¬φ) U (¬ψ))`         = `imp (untl (imp φ ⊥) (imp ψ ⊥)) ⊥`
    - `trigger φ ψ  = ¬((¬φ) S (¬ψ))`         = `imp (snce (imp φ ⊥) (imp ψ ⊥)) ⊥`
    - `weakUntil φ ψ = (φ U ψ) ∨ Gψ`         = `imp (imp (untl φ ψ) ⊥) (Gψ)`
    - `weakSince φ ψ = (φ S ψ) ∨ Hψ`         = `imp (imp (snce φ ψ) ⊥) (Hψ)`
    - `strongRelease φ ψ = (ψ ∧ φ) U ψ`      = `untl (and ψ φ) ψ`
    - `strongTrigger φ ψ = (ψ ∧ φ) S ψ`      = `snce (and ψ φ) ψ` -/
def _root_.FormalSystem.Syntax.Formula.matchBinaryDerived : Formula → Option String
  -- weakUntil: imp (imp (untl φ ψ) ⊥) (imp (untl (imp ψ' ⊥) (imp ⊥ ⊥)) ⊥), ψ == ψ'
  | .imp (.imp (.untl _ ψ) .bot) (.imp (.untl (.imp ψ' .bot) (.imp .bot .bot)) .bot) =>
    if ψ == ψ' then some "weakUntil" else none
  -- weakSince: imp (imp (snce φ ψ) ⊥) (imp (snce (imp ψ' ⊥) (imp ⊥ ⊥)) ⊥), ψ == ψ'
  | .imp (.imp (.snce _ ψ) .bot) (.imp (.snce (.imp ψ' .bot) (.imp .bot .bot)) .bot) =>
    if ψ == ψ' then some "weakSince" else none
  -- release: imp (untl (imp φ ⊥) (imp ψ ⊥)) ⊥, with φ ≠ ⊥ and ψ ≠ ⊥ (else collapses to G/¬)
  | .imp (.untl (.imp φ .bot) (.imp ψ .bot)) .bot =>
    if φ == .bot || ψ == .bot then none else some "release"
  -- trigger: imp (snce (imp φ ⊥) (imp ψ ⊥)) ⊥, with φ ≠ ⊥ and ψ ≠ ⊥ (else collapses to H/¬)
  | .imp (.snce (.imp φ .bot) (.imp ψ .bot)) .bot =>
    if φ == .bot || ψ == .bot then none else some "trigger"
  -- strongRelease: untl (and ψ φ) ψ = untl (imp (imp ψ (imp φ ⊥)) ⊥) ψ'
  | .untl (.imp (.imp ψ (.imp _ .bot)) .bot) ψ' =>
    if ψ == ψ' then some "strongRelease" else none
  -- strongTrigger: snce (and ψ φ) ψ = snce (imp (imp ψ (imp φ ⊥)) ⊥) ψ'
  | .snce (.imp (.imp ψ (.imp _ .bot)) .bot) ψ' =>
    if ψ == ψ' then some "strongTrigger" else none
  | _ => none

/-- Folded-tag matcher: the binary derived-operator tag at the top node of an already-folded
    `EnrichedFormula`, or `none`. This reads the tags produced by `foldFormulaFull`. -/
def EnrichedFormula.topBinaryTag : EnrichedFormula → Option String
  | .release _ _       => some "release"
  | .weak_until _ _    => some "weakUntil"
  | .trigger _ _       => some "trigger"
  | .weak_since _ _    => some "weakSince"
  | .strong_release _ _ => some "strongRelease"
  | .strong_trigger _ _ => some "strongTrigger"
  | _ => none

/-- Folded-tag census over a formula's top node: fold then read the binary tag. -/
def _root_.FormalSystem.Syntax.Formula.foldedBinaryTag (f : Formula) : Option String :=
  f.foldFormulaFull.topBinaryTag

/-- Census over a list of formulas: the multiset (as a sorted `List String`) of binary
    derived-operator tags detected by the value-level matcher. -/
def valueCensus (fs : List Formula) : List String :=
  (fs.filterMap Formula.matchBinaryDerived).mergeSort (· ≤ ·)

/-- Census over a list of formulas: the multiset (sorted) of binary derived-operator tags
    read from the folded (`foldFormulaFull`) representation. -/
def foldedCensus (fs : List Formula) : List String :=
  (fs.filterMap Formula.foldedBinaryTag).mergeSort (· ≤ ·)

section CensusTests

private def cp : Atom := Atom.mkBase "p"
private def cq : Atom := Atom.mkBase "q"

/-- Sample covering all 6 binary derived operators (atom operands) plus the `release(p,⊥)`
    collapse regression. -/
private def censusSample : List Formula := [
  Formula.release (.atom cp) (.atom cq),
  Formula.weakUntil (.atom cp) (.atom cq),
  Formula.trigger (.atom cp) (.atom cq),
  Formula.weakSince (.atom cp) (.atom cq),
  Formula.strongRelease (.atom cp) (.atom cq),
  Formula.strongTrigger (.atom cp) (.atom cq),
  Formula.release (.atom cp) Formula.bot  -- collapses to allFuture p: counted by neither
]

-- The value-level census and the folded-tag census agree on the sample.
#guard valueCensus censusSample == foldedCensus censusSample

-- All 6 binary operators have nonzero presence (each tag appears exactly once).
#guard valueCensus censusSample ==
  ["release", "strongRelease", "strongTrigger", "trigger", "weakSince", "weakUntil"]

-- The collapse case contributes no binary tag to either census.
#guard Formula.matchBinaryDerived (Formula.release (.atom cp) Formula.bot) == none
#guard Formula.foldedBinaryTag (Formula.release (.atom cp) Formula.bot) == none

end CensusTests

end OperatorCensus

end FormalSystem.Automation.Normalization
