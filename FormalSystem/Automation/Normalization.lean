/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.NormalizationAttr
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
- 21 `_unfold` lemmas (all `rfl`) organized by dependency level, tagged `@[formula_unfold]`

### Fold Direction (Phase 2-3)
- `EnrichedFormula`: ADT with 21 constructors (6 primitive + 15 enriched)
- `Formula.foldFormula`: greedy bottom-up fold from primitives to enriched
- `EnrichedFormula.toPrimitive`: inverse direction (enriched to primitives)
- 10 `_fold` lemmas for unambiguous patterns, tagged `@[formula_fold]`

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
@[formula_unfold] theorem neg_unfold (φ : Formula) : φ.neg = φ.imp bot := rfl

/-- Unfold top: `top = imp bot bot` -/
@[formula_unfold] theorem top_unfold : Formula.top = bot.imp bot := rfl

/-- Unfold next: `next φ = bot.untl φ` -/
@[formula_unfold] theorem next_unfold (φ : Formula) : φ.next = bot.untl φ := rfl

/-- Unfold prev: `prev φ = bot.snce φ` -/
@[formula_unfold] theorem prev_unfold (φ : Formula) : φ.prev = bot.snce φ := rfl

/-! ### Level 2: Depend on Level 1 operators -/

/-- Unfold conjunction: `and φ ψ = (φ.imp (ψ.imp bot)).imp bot` -/
@[formula_unfold] theorem and_unfold (φ ψ : Formula) :
    φ.and ψ = (φ.imp (ψ.imp bot)).imp bot := rfl

/-- Unfold disjunction: `or φ ψ = (φ.imp bot).imp ψ` -/
@[formula_unfold] theorem or_unfold (φ ψ : Formula) :
    φ.or ψ = (φ.imp bot).imp ψ := rfl

/-- Unfold diamond: `diamond φ = (φ.imp bot).box.imp bot` -/
@[formula_unfold] theorem diamond_unfold (φ : Formula) :
    φ.diamond = (φ.imp bot).box.imp bot := rfl

/-- Unfold someFuture: `someFuture φ = (bot.imp bot).untl φ` -/
@[formula_unfold] theorem some_future_unfold (φ : Formula) :
    φ.someFuture = (bot.imp bot).untl φ := rfl

/-- Unfold somePast: `somePast φ = (bot.imp bot).snce φ` -/
@[formula_unfold] theorem some_past_unfold (φ : Formula) :
    φ.somePast = (bot.imp bot).snce φ := rfl

/-! ### Level 3: Depend on Level 2 operators -/

/-- Unfold allFuture: `allFuture φ = ((bot.imp bot).untl (φ.imp bot)).imp bot` -/
@[formula_unfold] theorem all_future_unfold (φ : Formula) :
    φ.allFuture = ((bot.imp bot).untl (φ.imp bot)).imp bot := rfl

/-- Unfold allPast: `allPast φ = ((bot.imp bot).snce (φ.imp bot)).imp bot` -/
@[formula_unfold] theorem all_past_unfold (φ : Formula) :
    φ.allPast = ((bot.imp bot).snce (φ.imp bot)).imp bot := rfl

/-! ### Level 4: Depend on Level 3 operators -/

/-- Unfold weakFuture: `weakFuture φ = and φ (allFuture φ)` expanded to primitives -/
@[formula_unfold] theorem weak_future_unfold (φ : Formula) :
    φ.weakFuture =
      (φ.imp ((((bot.imp bot).untl (φ.imp bot)).imp bot).imp bot)).imp bot := rfl

/-- Unfold weakPast: `weakPast φ = and φ (allPast φ)` expanded to primitives -/
@[formula_unfold] theorem weak_past_unfold (φ : Formula) :
    φ.weakPast =
      (φ.imp ((((bot.imp bot).snce (φ.imp bot)).imp bot).imp bot)).imp bot := rfl

/-! ### Level 5: Depend on Level 4 operators -/

/-- Unfold always: `always φ = and (allPast φ) (and φ (allFuture φ))` -/
@[formula_unfold] theorem always_unfold (φ : Formula) :
    φ.always = φ.allPast.and (φ.and φ.allFuture) := rfl

/-! ### Level 6: Depend on Level 5 operators -/

/-- Unfold sometimes: `sometimes φ = neg (always (neg φ))` -/
@[formula_unfold] theorem sometimes_unfold (φ : Formula) :
    φ.sometimes = φ.neg.always.neg := rfl

/-! ### Level 7: Strong Release and Strong Trigger (depend on Level 2 operators) -/

/-- Unfold strongRelease: `strongRelease φ ψ = untl ψ (and ψ φ)` -/
@[formula_unfold] theorem strong_release_unfold (φ ψ : Formula) :
    Formula.strongRelease φ ψ = Formula.untl ψ (Formula.and ψ φ) := rfl

/-- Unfold strongTrigger: `strongTrigger φ ψ = snce ψ (and ψ φ)` -/
@[formula_unfold] theorem strong_trigger_unfold (φ ψ : Formula) :
    Formula.strongTrigger φ ψ = Formula.snce ψ (Formula.and ψ φ) := rfl

/-! ### Level 8: Release, Weak Until, Trigger, Weak Since (depend on Level 2/3 operators) -/

/-- Unfold release: `release φ ψ = neg (untl (neg φ) (neg ψ))` -/
@[formula_unfold] theorem release_unfold (φ ψ : Formula) :
    Formula.release φ ψ = ((ψ.neg.untl φ.neg).neg) := rfl

/-- Unfold weakUntil: `weakUntil φ ψ = or (untl φ ψ) (allFuture ψ)` -/
@[formula_unfold] theorem weak_until_unfold (φ ψ : Formula) :
    Formula.weakUntil φ ψ = ((ψ.untl φ).or ψ.allFuture) := rfl

/-- Unfold trigger: `trigger φ ψ = neg (snce (neg φ) (neg ψ))` -/
@[formula_unfold] theorem trigger_unfold (φ ψ : Formula) :
    Formula.trigger φ ψ = ((ψ.neg.snce φ.neg).neg) := rfl

/-- Unfold weakSince: `weakSince φ ψ = or (snce φ ψ) (allPast ψ)` -/
@[formula_unfold] theorem weak_since_unfold (φ ψ : Formula) :
    Formula.weakSince φ ψ = ((ψ.snce φ).or ψ.allPast) := rfl

end UnfoldLemmas

/-!
## Phase 1: The unfold and fold simp sets

Both families are declared in `FormalSystem/Automation/NormalizationAttr.lean`, so adding an
unfold lemma to the section above extends every `simp only [formula_unfold]` in the tree
automatically. A caller wanting a *proper sub-list* -- unfolding only the propositional
operators, say, or only the temporal ones -- names those lemmas individually, because
`[formula_unfold]` would over-normalize.

Seven tactic wrappers over exactly those spellings used to live here and were retired to
`Boneyard/RetiredTactics/` on measurement: not one of them had an invocation outside this
file's own examples.

Neither family is in the **default** simp set. The two are exact `rfl` inverses of each other, so
tagging both `@[simp]` made plain `simp` rewrite in a cycle until it hit `maximum recursion
depth` on any `Formula` goal. See `NormalizationAttr.lean` for the full account.
-/


/-! The unfold lemmas' statements and reductions are pinned in
`Tests/BimodalTest/Automation/NormalizationTest.lean`. -/

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
| `untl (imp bot bot) φ` | `someFuture φ` | Unambiguous: guard is `top` |
| `snce (imp bot bot) φ` | `somePast φ` | Unambiguous: guard is `top` |
| `untl bot φ` | `next φ` | Unambiguous: guard is `bot` |
| `snce bot φ` | `prev φ` | Unambiguous: guard is `bot` |

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
  | .untl ψ φ     => Formula.untl ψ.toPrimitive φ.toPrimitive
  | .snce ψ φ     => Formula.snce ψ.toPrimitive φ.toPrimitive
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
- `untl top φ` → `someFuture φ`
- `untl bot φ` → `next φ`

### Pattern matching order at `snce` nodes:
- `snce top φ` → `somePast φ`
- `snce bot φ` → `prev φ`
-/
def _root_.FormalSystem.Syntax.Formula.foldFormula : Formula → EnrichedFormula
  | Formula.atom a => .atom a
  | Formula.bot => .bot
  | Formula.box φ => .box φ.foldFormula
  | Formula.untl ψ φ =>
    let φ' := φ.foldFormula
    let ψ' := ψ.foldFormula
    match ψ' with
    | .top => .some_future φ'
    | .bot => .next φ'
    | _ =>
      -- strongRelease φ ψ = untl (and ψ φ) ψ: left is `and_ g b` with g == ψ'
      match φ' with
      | .and_ a b => if a == ψ' then .strong_release b ψ' else .untl ψ' φ'
      | _ => .untl ψ' φ'
  | Formula.snce ψ φ =>
    let φ' := φ.foldFormula
    let ψ' := ψ.foldFormula
    match ψ' with
    | .top => .some_past φ'
    | .bot => .prev φ'
    | _ =>
      -- strongTrigger φ ψ = snce (and ψ φ) ψ: left is `and_ g b` with g == ψ'
      match φ' with
      | .and_ a b => if a == ψ' then .strong_trigger b ψ' else .snce ψ' φ'
      | _ => .snce ψ' φ'
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
    | .untl (.neg ψ) (.neg φ), .bot => .release φ ψ
    -- trigger φ ψ = ¬(¬φ S ¬ψ) = imp (snce (neg φ) (neg ψ)) bot
    | .snce (.neg ψ) (.neg φ), .bot => .trigger φ ψ
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
      -- weakUntil φ ψ = (φ U ψ) ∨ Gψ = or_ (untl ψ φ) (allFuture ψ)
      -- weakSince φ ψ = (φ S ψ) ∨ Hψ = or_ (snce ψ φ) (allPast ψ)
      match inner, ψ' with
      | .untl b a, .all_future b' => if b == b' then .weak_until a b else .or_ inner ψ'
      | .snce b a, .all_past b'   => if b == b' then .weak_since a b else .or_ inner ψ'
      | _, _ => .or_ inner ψ'
    | _ => .imp φ' ψ'
  | .box φ => .box φ.recognizeComposites
  | .untl ψ φ => .untl ψ.recognizeComposites φ.recognizeComposites
  | .snce ψ φ => .snce ψ.recognizeComposites φ.recognizeComposites
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

/-! `foldFormula` and `foldFormulaFull` are pinned by `#guard` rows in
`Tests/BimodalTest/Automation/NormalizationTest.lean`. -/

/-!
## Phase 3: Fold-Direction Simp Lemmas

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
@[formula_fold] theorem neg_fold (φ : Formula) : φ.imp bot = neg φ := rfl

/-- Fold top: `bot.imp bot = top` -/
@[formula_fold] theorem top_fold : bot.imp bot = Formula.top := rfl

/-- Fold conjunction: `(φ.imp (ψ.neg)).neg = and φ ψ` -/
@[formula_fold] theorem and_fold (φ ψ : Formula) :
    (φ.imp (ψ.imp bot)).imp bot = Formula.and φ ψ := rfl

/-- Fold diamond: `(φ.neg.box).neg = diamond φ` -/
@[formula_fold] theorem diamond_fold (φ : Formula) :
    ((φ.imp bot).box).imp bot = diamond φ := rfl

/-- Fold someFuture: `(bot.imp bot).untl φ = someFuture φ` -/
@[formula_fold] theorem some_future_fold (φ : Formula) :
    (bot.imp bot).untl φ = someFuture φ := rfl

/-- Fold somePast: `(bot.imp bot).snce φ = somePast φ` -/
@[formula_fold] theorem some_past_fold (φ : Formula) :
    (bot.imp bot).snce φ = somePast φ := rfl

/-- Fold next: `bot.untl φ = next φ` -/
@[formula_fold] theorem next_fold (φ : Formula) :
    bot.untl φ = next φ := rfl

/-- Fold prev: `bot.snce φ = prev φ` -/
@[formula_fold] theorem prev_fold (φ : Formula) :
    bot.snce φ = prev φ := rfl

/-- Fold allFuture: `(φ.neg.someFuture).neg = allFuture φ` -/
@[formula_fold] theorem all_future_fold (φ : Formula) :
    ((bot.imp bot).untl (φ.imp bot)).imp bot = allFuture φ := rfl

/-- Fold allPast: `(φ.neg.somePast).neg = allPast φ` -/
@[formula_fold] theorem all_past_fold (φ : Formula) :
    ((bot.imp bot).snce (φ.imp bot)).imp bot = allPast φ := rfl

end FoldLemmas


/-! Round-trip examples over both simp sets live in
`Tests/BimodalTest/Automation/NormalizationTest.lean`. -/

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
  | .untl ψ φ =>
    "{\"tag\": \"untl\", \"event\": " ++ φ.toJson ++ ", \"guard\": " ++ ψ.toJson ++ "}"
  | .snce ψ φ =>
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
  | .untl ψ φ     => "U(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"
  | .snce ψ φ     => "S(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"
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
  | .untl ψ φ     => "(untl " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
  | .snce ψ φ     => "(snce " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
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

/-! The serialization functions above are exercised by `#guard` rows in
`Tests/BimodalTest/Automation/NormalizationTest.lean`. -/

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
  | .untl ψ φ  => .untl (normalizeFormula ψ) (normalizeFormula φ)
  | .snce ψ φ  => .snce (normalizeFormula ψ) (normalizeFormula φ)

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
  | untl ψ φ ih_ψ ih_φ => simp [normalizeFormula, ih_φ, ih_ψ]
  | snce ψ φ ih_ψ ih_φ => simp [normalizeFormula, ih_φ, ih_ψ]

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
  | .imp (.imp (.untl ψ _) .bot) (.imp (.untl (.imp .bot .bot) (.imp ψ' .bot)) .bot) =>
    if ψ == ψ' then some "weakUntil" else none
  -- weakSince: imp (imp (snce φ ψ) ⊥) (imp (snce (imp ψ' ⊥) (imp ⊥ ⊥)) ⊥), ψ == ψ'
  | .imp (.imp (.snce ψ _) .bot) (.imp (.snce (.imp .bot .bot) (.imp ψ' .bot)) .bot) =>
    if ψ == ψ' then some "weakSince" else none
  -- release: imp (untl (imp φ ⊥) (imp ψ ⊥)) ⊥, with φ ≠ ⊥ and ψ ≠ ⊥ (else collapses to G/¬)
  | .imp (.untl (.imp ψ .bot) (.imp φ .bot)) .bot =>
    if φ == .bot || ψ == .bot then none else some "release"
  -- trigger: imp (snce (imp φ ⊥) (imp ψ ⊥)) ⊥, with φ ≠ ⊥ and ψ ≠ ⊥ (else collapses to H/¬)
  | .imp (.snce (.imp ψ .bot) (.imp φ .bot)) .bot =>
    if φ == .bot || ψ == .bot then none else some "trigger"
  -- strongRelease: untl (and ψ φ) ψ = untl (imp (imp ψ (imp φ ⊥)) ⊥) ψ'
  | .untl ψ' (.imp (.imp ψ (.imp _ .bot)) .bot) =>
    if ψ == ψ' then some "strongRelease" else none
  -- strongTrigger: snce (and ψ φ) ψ = snce (imp (imp ψ (imp φ ⊥)) ⊥) ψ'
  | .snce ψ' (.imp (.imp ψ (.imp _ .bot)) .bot) =>
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
