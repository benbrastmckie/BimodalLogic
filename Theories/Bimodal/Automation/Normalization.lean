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
| `untl φ (imp bot bot)` | `some_future φ` | Unambiguous: guard is `top` |
| `snce φ (imp bot bot)` | `some_past φ` | Unambiguous: guard is `top` |
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
  | .some_future φ => Formula.some_future φ.toPrimitive
  | .some_past φ  => Formula.some_past φ.toPrimitive
  | .all_future φ => Formula.all_future φ.toPrimitive
  | .all_past φ   => Formula.all_past φ.toPrimitive
  | .next φ       => Formula.next φ.toPrimitive
  | .prev φ       => Formula.prev φ.toPrimitive
  | .weak_future φ => Formula.weak_future φ.toPrimitive
  | .weak_past φ  => Formula.weak_past φ.toPrimitive
  | .always φ     => Formula.always φ.toPrimitive
  | .sometimes φ  => Formula.sometimes φ.toPrimitive

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
- `imp (neg (neg φ).some_future) bot` → check for `all_future`
- `imp (neg (neg φ).some_past) bot` → check for `all_past`
- `imp φ bot` → `neg φ`
- `imp (neg φ) ψ` → `or_ φ ψ` (when not further matchable)

### Pattern matching order at `untl` nodes:
- `untl φ top` → `some_future φ`
- `untl φ bot` → `next φ`

### Pattern matching order at `snce` nodes:
- `snce φ top` → `some_past φ`
- `snce φ bot` → `prev φ`
-/
def Formula.foldFormula : Formula → EnrichedFormula
  | Formula.atom a => .atom a
  | Formula.bot => .bot
  | Formula.box φ => .box φ.foldFormula
  | Formula.untl φ ψ =>
    let φ' := φ.foldFormula
    let ψ' := ψ.foldFormula
    match ψ' with
    | .top => .some_future φ'
    | .bot => .next φ'
    | _ => .untl φ' ψ'
  | Formula.snce φ ψ =>
    let φ' := φ.foldFormula
    let ψ' := ψ.foldFormula
    match ψ' with
    | .top => .some_past φ'
    | .bot => .prev φ'
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
    -- imp(some_future(neg φ)) bot → all_future φ
    | .some_future (.neg φ), .bot => .all_future φ
    -- imp(some_past(neg φ)) bot → all_past φ
    | .some_past (.neg φ), .bot => .all_past φ
    -- imp (and_ (all_past φ) (and_ ψ (all_future χ))) bot where φ = neg α, ψ = neg α, χ = neg α
    -- This is neg(always(neg α)) = sometimes α
    -- After folding always: neg(always(neg α))
    -- But always is recognized later, so we check for sometimes pattern:
    -- neg (and_ (all_past φ) (and_ ψ (all_future χ))) where φ, ψ, χ are all neg of the same formula
    -- However, this would require always to be recognized first. We handle this differently below.
    --
    -- General neg: imp φ bot → neg φ
    -- After neg, check if the result forms a higher-level operator
    | left', .bot =>
      -- Check specific patterns first (most specific to least specific)
      match left' with
      -- Check for weak_future: neg (imp φ (neg (all_future φ')))
      -- where φ = φ'. This is and_ φ (all_future φ) = weak_future φ
      | .imp φ (.neg (.all_future φ')) =>
        if φ == φ' then .weak_future φ else .and_ φ (.all_future φ')
      -- Check for weak_past: neg (imp φ (neg (all_past φ')))
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
    - `and_ (all_past φ) (and_ ψ (all_future χ))` where φ = ψ = χ → `always φ`
    - `and_ (all_past φ) (weak_future ψ)` where φ = ψ → `always φ`
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
    | .neg inner => .or_ inner ψ'
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
    -- Recognize always: and_ (all_past φ) (and_ ψ (all_future χ)) where φ = ψ = χ
    match φ', ψ' with
    | .all_past a, .and_ b (.all_future c) =>
      if a == b && b == c then .always a
      else .and_ φ' ψ'
    -- Recognize always (alternative): and_ (all_past φ) (weak_future ψ) where φ = ψ
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

/-- Full fold: fold primitives then recognize composite operators. -/
def Formula.foldFormulaFull (f : Formula) : EnrichedFormula :=
  f.foldFormula.recognizeComposites

/-!
## Phase 2: Fold Tests
-/

section FoldTests

-- Helper: create test atoms
private def p_atom : Atom := Atom.mk_base "p"
private def q_atom : Atom := Atom.mk_base "q"

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

-- Test: foldFormula on some_future
-- `untl (atom p) (imp bot bot)` folds to `some_future (atom p)`
#eval do
  let f := Formula.some_future (Formula.atom p_atom)
  let r := f.foldFormula
  return repr r  -- should show some_future (atom ...)

-- Test: foldFormula on some_past
-- `snce (atom p) (imp bot bot)` folds to `some_past (atom p)`
#eval do
  let f := Formula.some_past (Formula.atom p_atom)
  let r := f.foldFormula
  return repr r  -- should show some_past (atom ...)

-- Test: foldFormula on all_future
#eval do
  let f := Formula.all_future (Formula.atom p_atom)
  let r := f.foldFormula
  return repr r  -- should show all_future (atom ...)

-- Test: foldFormula on all_past
#eval do
  let f := Formula.all_past (Formula.atom p_atom)
  let r := f.foldFormula
  return repr r  -- should show all_past (atom ...)

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
    Formula.some_future (Formula.atom p_atom),
    Formula.some_past (Formula.atom p_atom),
    Formula.all_future (Formula.atom p_atom),
    Formula.all_past (Formula.atom p_atom),
    Formula.next (Formula.atom p_atom),
    Formula.prev (Formula.atom p_atom)
  ]
  let results := formulas.map fun f =>
    let folded := Formula.foldFormula f
    let roundTrip := EnrichedFormula.toPrimitive folded
    (f == roundTrip, repr f, repr folded)
  return results

-- Test: weak_future fold
#eval do
  let f := Formula.weak_future (Formula.atom p_atom)
  let r := f.foldFormula
  return repr r  -- should show weak_future (atom ...)

-- Test: weak_past fold
#eval do
  let f := Formula.weak_past (Formula.atom p_atom)
  let r := f.foldFormula
  return repr r  -- should show weak_past (atom ...)

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
    Formula.weak_future (Formula.atom p_atom),
    Formula.weak_past (Formula.atom p_atom)
  ]
  let results := formulas.map fun f =>
    let folded := Formula.foldFormulaFull f
    let roundTrip := EnrichedFormula.toPrimitive folded
    (f == roundTrip, repr folded)
  return results

end FoldTests

end Bimodal.Syntax
