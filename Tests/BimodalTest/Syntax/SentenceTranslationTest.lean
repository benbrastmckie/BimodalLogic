/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.SourceLanguage.Sentence

/-!
# `tr` pinned row by row

One `#guard` per row of the elimination table in `FormalSystem/SourceLanguage/README.md`, plus four
structural probes. Every row is written out on the right-hand side as an explicit `Formula`, so a
later "simplification" of `tr` fails a build here instead of passing silently — which is the whole
reason these exist: the three rows that do not push through
(`FormalSystem.SourceLanguage.tr_cond_ne` and friends) are exactly the rows an obvious rewrite
would break, and truth preservation would keep holding while the certificate label domain changed
underneath.

A failing `#guard` is a build error, so `lake build BimodalTest` green is the assertion.

These probes live here rather than under `FormalSystem/` because the `#`-command linter is disabled
for the `BimodalTest` library only.

## What each group covers

- **The 18 constructor rows** — one atomic instance of every `Sentence` constructor.
- **The four rows that are not the obvious operator** — each pinned twice: once against the true
  image, once against the wrong one, so both directions fail loudly.
- **The asymmetric `Until`/`Since` probes** — an operand swap changes the image, so a regression to
  an event-first argument order fails here rather than passing silently.
- **The nested probes** — a nested `\future`/`\Future` pair and a nested conditional, the two
  families that do not push through, checked at depth.
-/

namespace BimodalTest.Syntax.SentenceTranslation

open FormalSystem.Syntax FormalSystem.SourceLanguage

/-! ### Abbreviations: three sentence letters, on both sides -/

/-- The sentence letter `p`, source side. -/
private def sp : Sentence := Sentence.atom (Atom.mkBase "p")
/-- The sentence letter `q`, source side. -/
private def sq : Sentence := Sentence.atom (Atom.mkBase "q")
/-- The sentence letter `r`, source side. -/
private def sr : Sentence := Sentence.atom (Atom.mkBase "r")

/-- The sentence letter `p`, `Formula` side. -/
private def fp : Formula := Formula.atomS "p"
/-- The sentence letter `q`, `Formula` side. -/
private def fq : Formula := Formula.atomS "q"
/-- The sentence letter `r`, `Formula` side. -/
private def fr : Formula := Formula.atomS "r"

/-! ### The 18 constructor rows -/

-- `p` (sentence letter) ↦ `Formula.atom a`, base name only
#guard tr sp == fp

-- `\bot` ↦ `Formula.bot`
#guard tr Sentence.bot == Formula.bot

-- `\neg A` ↦ `(tr A).neg`
#guard tr (Sentence.neg sp) == fp.neg

-- `\wedge A B` ↦ `(tr A).and (tr B)`
#guard tr (Sentence.wedge sp sq) == fp.and fq

-- `\vee A B` ↦ `(tr A).or (tr B)`
#guard tr (Sentence.vee sp sq) == fp.or fq

-- `\Box A` ↦ `(tr A).box`
#guard tr (Sentence.box sp) == fp.box

-- `\Future A` (G) ↦ `(tr A).allFuture`
#guard tr (Sentence.allFut sp) == fp.allFuture

-- `\Past A` (H) ↦ `(tr A).allPast`
#guard tr (Sentence.allPast sp) == fp.allPast

-- `\Until g e` ↦ `Formula.untl (tr g) (tr e)`, guard first, positional identity
#guard tr (Sentence.untl sp sq) == Formula.untl fp fq

-- `\Since g e` ↦ `Formula.snce (tr g) (tr e)`, guard first, positional identity
#guard tr (Sentence.snce sp sq) == Formula.snce fp fq

-- `\rightarrow A B` ↦ `((tr A).neg).or (tr B)` — NOT `Formula.imp`
#guard tr (Sentence.cond sp sq) == (fp.neg).or fq

-- `\leftrightarrow A B` ↦ the conjunction of the two `or`-shaped conditionals
#guard tr (Sentence.bicond sp sq) == ((fp.neg).or fq).and ((fq.neg).or fp)

-- `\top` ↦ `Formula.bot.neg` (= `Formula.top`). The source repository's own corpus excludes this
-- tag, because a known defect in its defined-operator expansion pass raises on it; the Lean side
-- covers it unconditionally, which turns that exclusion into a visible fixture diff rather than a
-- silent hole.
#guard tr Sentence.top == Formula.bot.neg
#guard tr Sentence.top == Formula.top

-- `\Diamond A` ↦ `(tr A).diamond`
#guard tr (Sentence.dia sp) == fp.diamond

-- `\future A` (F) ↦ `((tr A).neg.allFuture).neg` — NOT `Formula.someFuture`
#guard tr (Sentence.someFut sp) == (fp.neg.allFuture).neg

-- `\past A` (P) ↦ `((tr A).neg.allPast).neg` — NOT `Formula.somePast`
#guard tr (Sentence.somePast sp) == (fp.neg.allPast).neg

-- `\next A` ↦ `Formula.next (tr A)` (= `Formula.untl Formula.bot (tr A)`)
#guard tr (Sentence.next sp) == Formula.next fp
#guard tr (Sentence.next sp) == Formula.untl Formula.bot fp

-- `\prev A` ↦ `Formula.prev (tr A)` (= `Formula.snce Formula.bot (tr A)`)
#guard tr (Sentence.prev sp) == Formula.prev fp
#guard tr (Sentence.prev sp) == Formula.snce Formula.bot fp

/-! ### The four rows that are not the obvious operator, pinned from the wrong side too

`tr_cond_ne`, `tr_someFut_ne` and `tr_somePast_ne` prove these inequalities for every argument.
These `#guard`s are the executable echo: they fail at build time on the concrete instance, so a
reader who "simplifies" a row sees a test break rather than a theorem they have to go read. -/

#guard !(tr (Sentence.cond sp sq) == Formula.imp fp fq)
#guard !(tr (Sentence.someFut sp) == Formula.someFuture fp)
#guard !(tr (Sentence.somePast sp) == Formula.somePast fp)
#guard !(tr (Sentence.bicond sp sq) == Formula.imp (Formula.imp fp fq) (Formula.imp fq fp))

/-! ### `Until`/`Since` are asymmetric, so an argument-order regression is visible

The source repository normalized to guard-first, so `tr`'s `untl`/`snce` rows are positional
identity. That makes an event-first regression invisible to any probe whose two operands are
interchangeable. These four rows are not: swapping the operands changes the image. -/

#guard !(tr (Sentence.untl sp sq) == Formula.untl fq fp)
#guard !(tr (Sentence.snce sp sq) == Formula.snce fq fp)
#guard tr (Sentence.untl (Sentence.neg sp) sq) == Formula.untl fp.neg fq
#guard tr (Sentence.snce (Sentence.neg sp) sq) == Formula.snce fp.neg fq

/-! ### Nested instances of the two families that do not push through -/

-- `\future \Future p` — the existential tense wrapping the universal one
#guard tr (Sentence.someFut (Sentence.allFut sp)) == ((fp.allFuture).neg.allFuture).neg

-- `\past \Past p` — the past-side mirror
#guard tr (Sentence.somePast (Sentence.allPast sp)) == ((fp.allPast).neg.allPast).neg

-- `\rightarrow (\rightarrow p q) r` — a conditional in the antecedent of a conditional, where the
-- doubled negation appears twice over
#guard tr (Sentence.cond (Sentence.cond sp sq) sr) == (((fp.neg).or fq).neg).or fr

-- `\leftrightarrow (\rightarrow p q) r` — a conditional inside a biconditional
#guard tr (Sentence.bicond (Sentence.cond sp sq) sr)
    == ((((fp.neg).or fq).neg).or fr).and ((fr.neg).or ((fp.neg).or fq))

end BimodalTest.Syntax.SentenceTranslation
