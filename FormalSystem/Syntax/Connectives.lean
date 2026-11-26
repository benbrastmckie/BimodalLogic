/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Init

/-!
# Connective Signature

The primitive-operator classes shared by the object languages of this library, and every derived
operator written once over them.

## Design

- **One class per primitive operator.** `HasBot`, `HasImp`, `HasBox`, `HasUntl`, `HasSnce`,
  `HasStab`, `HasAllFuture` and `HasAllPast` each carry the one operator and nothing else. A
  language states which primitives it has by which instances it declares. Class names follow the
  constructor spelling (`untl`, `snce`), so a class and its constructor read alike.
- **Derived operators are functions over the classes, not defaulted class fields.** A defaulted
  field can be overridden by an instance, so a class with defaults would not fix the encoding;
  a function in `Sig` has one body for every language. Each is stated over the weakest set of
  classes that types it.
- **No notation.** Notation stays with the per-language definitions, which also carry dot
  notation and the per-language docstrings.
- **No semantics.** This module imports `FormalSystem.Init` alone and sits below every formula
  type.

Every operator in `Sig` is an `abbrev`, so it unfolds to its primitive form at reducible
transparency.

## Main definitions

- Boolean: `Sig.neg`, `Sig.top`, `Sig.and`, `Sig.or`
- Modal: `Sig.diamond`, `Sig.dstab`
- Future: `Sig.someFuture`, `Sig.allFuture`, `Sig.kPlus`, `Sig.after`, `Sig.next`
- Past: `Sig.somePast`, `Sig.allPast`, `Sig.kMinus`, `Sig.prev`
- Both directions: `Sig.always`, `Sig.sometimes`
- Over primitive tenses: `Sig.someFuture'`, `Sig.somePast'`, `Sig.always'`
- Intervals: `Sig.inclusiveUntil`, `Sig.inclusiveSince`, `Sig.release`, `Sig.trigger`,
  `Sig.weakUntil`, `Sig.weakSince`

## Argument order

`untl` and `snce` are **guard first**: `untl guard event`. Two conventions follow from that and
must not be mixed up.

- `Sig.inclusiveUntil` and `Sig.inclusiveSince` are **guard first**, like the primitives.
- `Sig.release`, `Sig.trigger`, `Sig.weakUntil` and `Sig.weakSince` are **event first**: the
  first argument is the event and the second the guard, the reverse of the primitive they are
  built from. `Sig.after` is event first as well.

## References

* `FormalSystem/Syntax/Formula.lean` — the language L, whose derived operators have these bodies
* `docs/development/stability-operator-family.md` — why `stab` is filed with the modal operators
-/

namespace FormalSystem.Syntax

universe u

/-! ## Primitive-operator classes -/

/-- A language with falsum `⊥`. -/
class HasBot (L : Type u) where
  /-- Falsum (`⊥`). -/
  bot : L

/-- A language with material implication `→`. -/
class HasImp (L : Type u) where
  /-- Material implication (`φ → ψ`). -/
  imp : L → L → L

/-- A language with the necessity modal `□`. -/
class HasBox (L : Type u) where
  /-- Necessity (`□φ`). -/
  box : L → L

/-- A language with strict Until. The operator is **guard first**: `untl guard event`. -/
class HasUntl (L : Type u) where
  /-- Strict Until, guard first: `untl guard event`. -/
  untl : L → L → L

/-- A language with strict Since. The operator is **guard first**: `snce guard event`. -/
class HasSnce (L : Type u) where
  /-- Strict Since, guard first: `snce guard event`. -/
  snce : L → L → L

/-- A language with the stability modal `⊡`. -/
class HasStab (L : Type u) where
  /-- Stability (`⊡φ`). -/
  stab : L → L

/-- A language with the strict future tense `G` as a primitive, rather than derived from Until. -/
class HasAllFuture (L : Type u) where
  /-- Strict universal future (`Gφ`), as a primitive. -/
  allFuture : L → L

/-- A language with the strict past tense `H` as a primitive, rather than derived from Since. -/
class HasAllPast (L : Type u) where
  /-- Strict universal past (`Hφ`), as a primitive. -/
  allPast : L → L

namespace Sig

/-! ## Boolean operators -/

section Boolean
variable {L : Type u} [HasBot L] [HasImp L]

/-- Negation (`¬φ`): `φ → ⊥`. -/
abbrev neg (φ : L) : L := HasImp.imp φ HasBot.bot

/-- Verum (`⊤`): `⊥ → ⊥`. -/
abbrev top : L := HasImp.imp (HasBot.bot : L) HasBot.bot

/-- Conjunction (`φ ∧ ψ`): `¬(φ → ¬ψ)`. -/
abbrev and (φ ψ : L) : L := neg (HasImp.imp φ (neg ψ))

/-- Disjunction (`φ ∨ ψ`): `¬φ → ψ`. -/
abbrev or (φ ψ : L) : L := HasImp.imp (neg φ) ψ

end Boolean

/-! ## Modal operators -/

section Modal
variable {L : Type u} [HasBot L] [HasImp L]

/-- Possibility (`◇φ`): `¬□¬φ`. -/
abbrev diamond [HasBox L] (φ : L) : L := neg (HasBox.box (neg φ))

/-- The dual of stability: `¬⊡¬φ`. -/
abbrev dstab [HasStab L] (φ : L) : L := neg (HasStab.stab (neg φ))

end Modal

/-! ## Future operators over Until -/

section Future
variable {L : Type u} [HasBot L] [HasImp L] [HasUntl L]

/-- Strict existential future (`Fφ`): `⊤ U φ`, guard first. -/
abbrev someFuture (φ : L) : L := HasUntl.untl top φ

/-- Strict universal future (`Gφ`): `¬F¬φ`. -/
abbrev allFuture (φ : L) : L := neg (someFuture (neg φ))

/-- `K⁺φ`: `¬(¬φ U ⊤)`, guard first. -/
abbrev kPlus (φ : L) : L := neg (HasUntl.untl (neg φ) top)

/-- After (`A(φ, ψ)`): `¬φ U (φ ∧ ψ)`. **Event first**: `φ` is the event. -/
abbrev after (φ ψ : L) : L := HasUntl.untl (neg φ) (and φ ψ)

end Future

/-- Next (`Xφ`): `⊥ U φ`, guard first. -/
abbrev next {L : Type u} [HasBot L] [HasUntl L] (φ : L) : L := HasUntl.untl HasBot.bot φ

/-! ## Past operators over Since -/

section Past
variable {L : Type u} [HasBot L] [HasImp L] [HasSnce L]

/-- Strict existential past (`Pφ`): `⊤ S φ`, guard first. -/
abbrev somePast (φ : L) : L := HasSnce.snce top φ

/-- Strict universal past (`Hφ`): `¬P¬φ`. -/
abbrev allPast (φ : L) : L := neg (somePast (neg φ))

/-- `K⁻φ`: `¬(¬φ S ⊤)`, guard first. -/
abbrev kMinus (φ : L) : L := neg (HasSnce.snce (neg φ) top)

end Past

/-- Previous (`Yφ`): `⊥ S φ`, guard first. -/
abbrev prev {L : Type u} [HasBot L] [HasSnce L] (φ : L) : L := HasSnce.snce HasBot.bot φ

/-! ## Operators in both temporal directions -/

section Always
variable {L : Type u} [HasBot L] [HasImp L] [HasUntl L] [HasSnce L]

/-- Temporal `always` (`△φ`): `Hφ ∧ (φ ∧ Gφ)`. -/
abbrev always (φ : L) : L := and (allPast φ) (and φ (allFuture φ))

/-- Temporal `sometimes` (`▽φ`): `¬△¬φ`. -/
abbrev sometimes (φ : L) : L := neg (always (neg φ))

end Always

/-! ## Operators over primitive tenses

A language that takes `G` and `H` as primitives derives the existential tenses from them, the
reverse of a language built on Until and Since. The primed names keep the two encodings apart. -/

section Tense
variable {L : Type u} [HasBot L] [HasImp L]

/-- Strict existential future over a primitive `G`: `¬G¬φ`. -/
abbrev someFuture' [HasAllFuture L] (φ : L) : L := neg (HasAllFuture.allFuture (neg φ))

/-- Strict existential past over a primitive `H`: `¬H¬φ`. -/
abbrev somePast' [HasAllPast L] (φ : L) : L := neg (HasAllPast.allPast (neg φ))

/-- Temporal `always` over the primitive tenses (`△φ`): `Hφ ∧ (φ ∧ Gφ)`. -/
abbrev always' [HasAllFuture L] [HasAllPast L] (φ : L) : L :=
  and (HasAllPast.allPast φ) (and φ (HasAllFuture.allFuture φ))

end Tense

/-! ## Interval operators -/

section IntervalFuture
variable {L : Type u} [HasBot L] [HasImp L] [HasUntl L]

/-- Inclusive Until: `ev ∨ (g ∧ (g U ev))`. **Guard first**, like `untl`: the event holds now or
later, and the guard holds from now up to it. -/
abbrev inclusiveUntil (g ev : L) : L := or ev (and g (HasUntl.untl g ev))

/-- Release (`R(φ, ψ)`), the dual of Until: `¬(¬ψ U ¬φ)`.

**Argument-order trap.** This is **event first**: `φ` is the event and `ψ` the guard, the reverse
of the guard-first `untl` it is built from. -/
abbrev release (φ ψ : L) : L := neg (HasUntl.untl (neg ψ) (neg φ))

/-- Weak Until (`W(φ, ψ)`), Until without the liveness requirement: `(ψ U φ) ∨ Gψ`.

**Event first**, as `release` is: `φ` is the event and `ψ` the guard. -/
abbrev weakUntil (φ ψ : L) : L := or (HasUntl.untl ψ φ) (allFuture ψ)

end IntervalFuture

section IntervalPast
variable {L : Type u} [HasBot L] [HasImp L] [HasSnce L]

/-- Inclusive Since: `ev ∨ (g ∧ (g S ev))`. **Guard first**, like `snce`: the event holds now or
earlier, and the guard holds from it up to now. -/
abbrev inclusiveSince (g ev : L) : L := or ev (and g (HasSnce.snce g ev))

/-- Trigger (`T(φ, ψ)`), the dual of Since: `¬(¬ψ S ¬φ)`.

**Argument-order trap.** This is **event first**: `φ` is the event and `ψ` the guard, the reverse
of the guard-first `snce` it is built from. -/
abbrev trigger (φ ψ : L) : L := neg (HasSnce.snce (neg ψ) (neg φ))

/-- Weak Since (`WS(φ, ψ)`), Since without the liveness requirement: `(ψ S φ) ∨ Hψ`.

**Event first**, as `trigger` is: `φ` is the event and `ψ` the guard. -/
abbrev weakSince (φ ψ : L) : L := or (HasSnce.snce ψ φ) (allPast ψ)

end IntervalPast

end Sig

end FormalSystem.Syntax
