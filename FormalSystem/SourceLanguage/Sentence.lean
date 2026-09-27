/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula

/-!
# `Sentence` — the source sentence language and its elimination into `Formula`

The companion ModelChecker repository states an argument in a **source language** whose operator
set is deliberately redundant: nine primitive operators and eight defined ones, the defined ones
being abbreviations that its own expansion pass rewrites before anything else runs. Everything
downstream of that rewrite — the encoder, the solver, the decoder, the re-checker — consumes the
six-primitive `Formula` of `FormalSystem/Syntax/Formula.lean`. The rewrite itself is therefore a
translation between two languages, and it sits inside the trust base of that pipeline: a defect in
it means every later stage rigorously certifies a countermodel to a *different* argument than the
one the user wrote, and a round trip between the two consumers cannot detect it, because both
sides read the same already-translated formula.

This module is the syntax half of an independent verified reference for that translation. It
declares `Sentence`, the source AST with all seventeen operators plus atoms, and `tr`, the
elimination of every one of them into the six `Formula` primitives.
`FormalSystem/SourceLanguage/SentenceTruth.lean` supplies the semantic half and the agreement
theorem.

## Main Definitions

- `Sentence` — the source AST: 18 constructors, nine primitive operators, eight defined, plus atoms
- `tr : Sentence → Formula` — the elimination of every defined operator into the six primitives

## Main Results

- push-through equations (`tr_neg`, `tr_wedge`, `tr_vee`, `tr_box`, `tr_allFut`, `tr_allPast`,
  `tr_untl`, `tr_snce`, `tr_top`, `tr_dia`, `tr_next`, `tr_prev`) — the twelve operators that do
  commute with `tr`, each by `rfl`
- `tr_cond_ne`, `tr_someFut_ne`, `tr_somePast_ne` — the three that do **not**, recorded by proof
- `tr_not_injective` — `tr` is *not* injective, and that is by design

## `untl`/`snce` are guard-first, on both sides

`Formula.untl` and `Formula.snce` take the guard first and the event second, and so do
`Sentence.untl` and `Sentence.snce`; the source repository normalized to guard-first throughout, so
the elimination of these two is positional identity rather than a swap. The per-constructor
docstrings below name which operand is which, because nothing in the types does.

## Three operators do not push through, and each would be silently wrong written the obvious way

The source repository routes `\rightarrow` through `¬A ∨ B`, and `Formula.or φ ψ` is
`φ.neg.imp ψ`, so the image of a source-level implication is
`Formula.or (Formula.neg (tr A)) (tr B)` — a *doubly negated antecedent* — and **not**
`Formula.imp (tr A) (tr B)`. The two are semantically equivalent and are different formulas, so
they have different subformula closures, hence different certificate label domains. Writing the
obvious rule would produce a reference that disagrees with the source repository on every
conditional. `tr_cond_ne` records this by proof.

Likewise the source repository's existential tenses are `¬\Future¬` and `¬\Past¬`, so their images
are `((tr A).neg.allFuture).neg` and `((tr A).neg.allPast).neg`, and **not**
`Formula.someFuture (tr A)` / `Formula.somePast (tr A)` — which are a top-level `untl`/`snce`
whereas the images are a top-level `imp`. `tr_someFut_ne` and `tr_somePast_ne` record this.
`FormalSystem/MinusLanguage/Translation.lean` proves the same phenomenon for its own `tr`, and the
idiom here is that module's.

## The range invariant

No `Formula.imp` in the range of `tr` is the image of a source-level implication. `Formula.imp`
occurs in the range only inside the encodings of `neg`, `and`, `or` and `top` (each of which is an
`imp` by definition) and inside the two universal tenses (`allFuture`/`allPast`, which are
double-negated `untl`/`snce`). A reader who "simplifies" `tr`'s `cond` row to `Formula.imp` breaks
this invariant, and `tr_cond_ne` fails.

## `tr` is lossy, and that is the point

`tr` is **not** injective — `tr_not_injective` proves it — because each defined operator is
eliminated onto the very abbreviation it stands for: `tr (cond A B)` and `tr (vee (neg A) B)` are
the same `Formula`, as are `tr top` and `tr (neg bot)`, `tr (dia A)` and `tr (neg (box (neg A)))`,
and `tr (someFut A)` and `tr (neg (allFut (neg A)))`. The elimination discards exactly the
information that distinguishes an abbreviation from what it abbreviates, which is what an
elimination is for. The consequence for the conformance channel of `BimodalTools/README.md` is
that comparison runs forward only: a translated `Formula` does not determine the `Sentence` it came
from, so no inverse pass can be checked against.

This is why the plan-level expectation of a `tr_injective` mirroring
`FormalSystem/MinusLanguage/Translation.lean` does not hold here. That translation is
primitive-to-primitive and same-name, so it is injective; this one collapses seventeen operators
onto six, so it cannot be.

## References

* `FormalSystem/SourceLanguage/SentenceTruth.lean` — `Sat`, and the agreement theorem `sat_iff`
* `FormalSystem/MinusLanguage/Translation.lean` — the "existential operators do NOT push through"
  precedent and the `≠` idiom followed here
* `BimodalTools/SentenceExport.lean` — the JSON codec and the conformance channel
* `FormalSystem/SourceLanguage/README.md` — the per-file inventory and the elimination table
-/

namespace FormalSystem.SourceLanguage

open FormalSystem.Syntax

/--
The source sentence language: the AST the companion ModelChecker repository builds from surface
syntax, before its own expansion pass eliminates the defined operators.

Nine constructors are primitive there (`atom`, `bot`, `neg`, `wedge`, `vee`, `box`, `allFut`,
`allPast`, `untl`, `snce` — atoms and the nine operators) and eight are defined (`cond`, `bicond`,
`top`, `dia`, `someFut`, `somePast`, `next`, `prev`). All seventeen operators are constructors
here on purpose: the defined ones are precisely the part the source repository's own translation
never sees, and precisely the part this module is a reference for.
-/
inductive Sentence : Type where
  /-- A sentence letter (`p`, `q`, ...). Only the base name crosses the wire; a fresh-indexed atom
  is rejected at the wire on both sides. -/
  | atom : Atom → Sentence
  /-- Falsum, `\bot`. Primitive. -/
  | bot : Sentence
  /-- Negation, `\neg A`. Primitive in the source language, derived in `Formula`. -/
  | neg : Sentence → Sentence
  /-- Conjunction, `\wedge A B`. Primitive in the source language, derived in `Formula`. -/
  | wedge : Sentence → Sentence → Sentence
  /-- Disjunction, `\vee A B`. Primitive in the source language, derived in `Formula`. -/
  | vee : Sentence → Sentence → Sentence
  /-- Necessity, `\Box A`. Primitive. -/
  | box : Sentence → Sentence
  /-- The universal future, `\Future A` (tense-logical `G`). Primitive in the source language,
  derived in `Formula`. -/
  | allFut : Sentence → Sentence
  /-- The universal past, `\Past A` (tense-logical `H`). Primitive in the source language, derived
  in `Formula`. -/
  | allPast : Sentence → Sentence
  /-- Until, `\Until g e`. Primitive. **Argument 1 is the guard `g`, argument 2 the event `e`**:
  the event happens strictly later and the guard holds strictly in between. -/
  | untl : Sentence → Sentence → Sentence
  /-- Since, `\Since g e`. Primitive. **Argument 1 is the guard `g`, argument 2 the event `e`**:
  the event happened strictly earlier and the guard held strictly in between. -/
  | snce : Sentence → Sentence → Sentence
  /-- The material conditional, `\rightarrow A B`. Defined, as `¬A ∨ B` — *not* as a primitive
  implication; see `tr_cond_ne`. -/
  | cond : Sentence → Sentence → Sentence
  /-- The biconditional, `\leftrightarrow A B`. Defined, as the conjunction of the two
  conditionals. -/
  | bicond : Sentence → Sentence → Sentence
  /-- Verum, `\top`. Defined, as `¬⊥`. The source repository's expansion pass currently raises on
  this tag; the Lean side covers it unconditionally. -/
  | top : Sentence
  /-- Possibility, `\Diamond A`. Defined, as `¬□¬A`. -/
  | dia : Sentence → Sentence
  /-- The existential future, `\future A` (tense-logical `F`). Defined, as `¬\Future¬A` — *not* as
  `Formula.someFuture`; see `tr_someFut_ne`. -/
  | someFut : Sentence → Sentence
  /-- The existential past, `\past A` (tense-logical `P`). Defined, as `¬\Past¬A` — *not* as
  `Formula.somePast`; see `tr_somePast_ne`. -/
  | somePast : Sentence → Sentence
  /-- The next-time operator, `\next A`. Defined, as `\Until ⊥ A`. -/
  | next : Sentence → Sentence
  /-- The previous-time operator, `\prev A`. Defined, as `\Since ⊥ A`. -/
  | prev : Sentence → Sentence
  deriving Repr, DecidableEq, BEq

/--
The elimination of the source language into `Formula`: every one of the seventeen operators
rewritten into the six `Formula` primitives.

Twelve rows land on the `Formula` operator of the same name and commute with `tr` (see the
push-through equations below). Four do not, and each is the row a reader is most likely to
"simplify" into a different formula:

- `cond A B ↦ Formula.or (tr A).neg (tr B)`, **not** `Formula.imp (tr A) (tr B)` (`tr_cond_ne`)
- `bicond A B ↦` the conjunction of the two `or`-shaped conditionals
- `someFut A ↦ ((tr A).neg.allFuture).neg`, **not** `Formula.someFuture (tr A)` (`tr_someFut_ne`)
- `somePast A ↦ ((tr A).neg.allPast).neg`, **not** `Formula.somePast (tr A)` (`tr_somePast_ne`)

Every row was checked by execution against the source repository's own pipeline, and every row is
pinned independently by a `#guard` in
`Tests/BimodalTest/Syntax/SentenceTranslationTest.lean`.
-/
def tr : Sentence → Formula
  | .atom a => Formula.atom a
  | .bot => Formula.bot
  | .neg A => (tr A).neg
  | .wedge A B => (tr A).and (tr B)
  | .vee A B => (tr A).or (tr B)
  | .box A => (tr A).box
  | .allFut A => (tr A).allFuture
  | .allPast A => (tr A).allPast
  | .untl g e => Formula.untl (tr g) (tr e)
  | .snce g e => Formula.snce (tr g) (tr e)
  | .cond A B => ((tr A).neg).or (tr B)
  | .bicond A B => (((tr A).neg).or (tr B)).and (((tr B).neg).or (tr A))
  | .top => Formula.bot.neg
  | .dia A => (tr A).diamond
  | .someFut A => ((tr A).neg.allFuture).neg
  | .somePast A => ((tr A).neg.allPast).neg
  | .next A => Formula.next (tr A)
  | .prev A => Formula.prev (tr A)

/-! ### The twelve operators that push through

Each of these is `rfl`: the source operator's image is the `Formula` operator of the same name.
They are the normal form for rewriting `tr` out of a goal, and `SentenceTruth.lean`'s agreement
proof runs on them. -/

/-- Negation pushes through `tr`. -/
@[simp] theorem tr_neg (A : Sentence) : tr A.neg = (tr A).neg := rfl

/-- Conjunction pushes through `tr`. -/
@[simp] theorem tr_wedge (A B : Sentence) : tr (A.wedge B) = (tr A).and (tr B) := rfl

/-- Disjunction pushes through `tr`. -/
@[simp] theorem tr_vee (A B : Sentence) : tr (A.vee B) = (tr A).or (tr B) := rfl

/-- Necessity pushes through `tr`. -/
@[simp] theorem tr_box (A : Sentence) : tr A.box = (tr A).box := rfl

/-- The universal future pushes through `tr`. -/
@[simp] theorem tr_allFut (A : Sentence) : tr A.allFut = (tr A).allFuture := rfl

/-- The universal past pushes through `tr`. -/
@[simp] theorem tr_allPast (A : Sentence) : tr A.allPast = (tr A).allPast := rfl

/-- Until pushes through `tr`, guard-first on both sides — positional identity, no swap. -/
@[simp] theorem tr_untl (g e : Sentence) : tr (g.untl e) = Formula.untl (tr g) (tr e) := rfl

/-- Since pushes through `tr`, guard-first on both sides — positional identity, no swap. -/
@[simp] theorem tr_snce (g e : Sentence) : tr (g.snce e) = Formula.snce (tr g) (tr e) := rfl

/-- Verum pushes through `tr`: `Formula.bot.neg` is `Formula.top` by definition. -/
@[simp] theorem tr_top : tr Sentence.top = Formula.top := rfl

/-- Possibility pushes through `tr`. -/
@[simp] theorem tr_dia (A : Sentence) : tr A.dia = (tr A).diamond := rfl

/-- The next-time operator pushes through `tr`. -/
@[simp] theorem tr_next (A : Sentence) : tr A.next = Formula.next (tr A) := rfl

/-- The previous-time operator pushes through `tr`. -/
@[simp] theorem tr_prev (A : Sentence) : tr A.prev = Formula.prev (tr A) := rfl

/-! ### The three that do not push through

These are the deliberate inequalities. Each one is the proof that stops a later "simplification"
of `tr` from silently changing the subformula closure of the translated formula — and so the
label domain of every certificate stated about it. -/

/--
No `Formula` is a proper subformula of itself in the `imp`-doubled position: `(φ → ⊥) → ⊥ ≠ φ`.

The workhorse of `tr_cond_ne`. Proved by the derived `sizeOf`, which strictly increases at every
constructor.
-/
theorem imp_imp_bot_bot_ne (φ : Formula) :
    Formula.imp (Formula.imp φ Formula.bot) Formula.bot ≠ φ := by
  intro h
  have hsize := congrArg sizeOf h
  simp only [Formula.imp.sizeOf_spec, Formula.bot.sizeOf_spec] at hsize
  omega

/--
The source-level conditional does **not** land on `Formula.imp`.

`tr (cond A B)` is `Formula.or (tr A).neg (tr B)`, i.e. `((tr A → ⊥) → ⊥) → tr B`: the antecedent
is doubly negated, because the source repository routes `\rightarrow` through `¬A ∨ B`. Replacing
this row by `Formula.imp (tr A) (tr B)` keeps the truth conditions and changes the formula, hence
the subformula closure, hence the certificate label domain — so it would make this module a
reference for an encoding no consumer implements. The inequality is deliberate.
-/
theorem tr_cond_ne (A B : Sentence) : tr (Sentence.cond A B) ≠ Formula.imp (tr A) (tr B) := by
  intro h
  simp only [tr, Formula.or, Formula.neg, Formula.imp.injEq] at h
  exact imp_imp_bot_bot_ne (tr A) h.1

/--
The source-level existential future does **not** land on `Formula.someFuture`.

`tr (someFut A)` is `((tr A).neg.allFuture).neg`, a top-level `imp`, because the source repository
defines `\future` as `¬\Future¬`. `Formula.someFuture (tr A)` is `Formula.untl Formula.top (tr A)`,
a top-level `untl`. Different constructors, so no association or abbreviation choice could have
made them equal. Dual of `tr_somePast_ne`, and the analogue of
`FormalSystem/MinusLanguage/Translation.lean`'s `tr_someFuture_ne`.
-/
theorem tr_someFut_ne (A : Sentence) :
    tr (Sentence.someFut A) ≠ Formula.someFuture (tr A) := by
  simp only [tr, Formula.someFuture, Formula.neg]
  exact Formula.noConfusion

/--
The source-level existential past does **not** land on `Formula.somePast`. Dual of
`tr_someFut_ne`.
-/
theorem tr_somePast_ne (A : Sentence) :
    tr (Sentence.somePast A) ≠ Formula.somePast (tr A) := by
  simp only [tr, Formula.somePast, Formula.neg]
  exact Formula.noConfusion

/-! ### `tr` is lossy

An elimination collapses each abbreviation onto what it abbreviates, so it cannot be injective —
see the module docstring for why the `FormalSystem/MinusLanguage/Translation.lean` precedent does
not transfer, and for the consequence for the conformance channel. -/

/--
`tr` is not injective.

Witness: `tr (cond bot bot) = tr (vee (neg bot) bot)` by `rfl`, because the source-level
conditional *is* the disjunction of the negated antecedent with the consequent, and `tr` eliminates
it onto exactly that. The same collapse happens for `top` against `neg bot`, for `dia` against
`neg (box (neg ·))`, and for `someFut`/`somePast` against the negated universal tenses. The
elimination discards what distinguishes an abbreviation from its expansion, which is its purpose.

The practical consequence: a translated `Formula` does not determine the `Sentence` it came from, so
the conformance channel of `BimodalTools/README.md` compares in the forward direction only and no
inverse pass is checkable against this reference.
-/
theorem tr_not_injective : ¬ Function.Injective tr := by
  intro hinj
  have h : Sentence.cond Sentence.bot Sentence.bot
      = Sentence.vee (Sentence.neg Sentence.bot) Sentence.bot := hinj rfl
  exact absurd h (by decide)

end FormalSystem.SourceLanguage
