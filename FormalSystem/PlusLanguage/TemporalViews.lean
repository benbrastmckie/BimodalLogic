/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.PlusLanguage.Formula

/-!
# Exact derived temporal views for TM⁺, and inclusive Until/Since

Optional syntax module imported by the temporal proof-mode frontend.

## Argument order

The primitive constructors are **guard first, event second**: `untl guard event`.

* The TM⁺ dual wrappers copy `Formula`'s right-hand sides verbatim, **event first**:
  `release φ ψ = ¬(¬ψ U ¬φ)`, `weakUntil φ ψ = (ψ U φ) ∨ G ψ`,
  `strongRelease φ ψ = ψ U (ψ ∧ φ)`, and their past mirrors. `before φ ψ` is
  `release (¬φ) ψ ∧ F φ`, with `Formula.before`'s documented swap.
* `inclusiveUntil guard event := event ∨ (guard ∧ U guard event)` is **guard first**, like
  `untl`. Read on strict U it says: the event holds now, or the guard holds now and strictly
  later the event holds with the guard throughout the open interval. It is a derived
  abbreviation. It adds no metric syntax, constructor or axiom, and strict rules are not reused
  for it by changing notation. `inclusiveSince` is its past mirror.

Every view below is pinned by `rfl` to its literal primitive expansion and to the `ofFormula`
embedding of its TM counterpart. The `*_expand` equalities are AST equalities that the native
views tier uses these equations with `lunfold` and `lfold`.
-/

namespace FormalSystem.PlusLanguage

namespace PlusFormula

/-- Release, event first like `Formula.release`: `release φ ψ = ¬(¬ψ U ¬φ)`. -/
def release (φ ψ : PlusFormula) : PlusFormula := sig% FormalSystem.Syntax.Sig.release φ ψ

/-- Trigger, the past mirror of `release`: `trigger φ ψ = ¬(¬ψ S ¬φ)`. -/
def trigger (φ ψ : PlusFormula) : PlusFormula := sig% FormalSystem.Syntax.Sig.trigger φ ψ

/-- Weak Until, event first: `weakUntil φ ψ = (ψ U φ) ∨ G ψ`. -/
def weakUntil (φ ψ : PlusFormula) : PlusFormula := sig% FormalSystem.Syntax.Sig.weakUntil φ ψ

/-- Weak Since, event first: `weakSince φ ψ = (ψ S φ) ∨ H ψ`. -/
def weakSince (φ ψ : PlusFormula) : PlusFormula := sig% FormalSystem.Syntax.Sig.weakSince φ ψ

/-- Strong Release, event first: `strongRelease φ ψ = ψ U (ψ ∧ φ)`. -/
def strongRelease (φ ψ : PlusFormula) : PlusFormula := PlusFormula.untl ψ (PlusFormula.and ψ φ)

/-- Strong Trigger, event first: `strongTrigger φ ψ = ψ S (ψ ∧ φ)`. -/
def strongTrigger (φ ψ : PlusFormula) : PlusFormula := PlusFormula.snce ψ (PlusFormula.and ψ φ)

/-- Before, with `Formula.before`'s documented swap: `release (¬φ) ψ ∧ F φ`. -/
def before (φ ψ : PlusFormula) : PlusFormula :=
  (PlusFormula.release φ.neg ψ).and (PlusFormula.someFuture φ)

/-- Inclusive Until, guard first: `event ∨ (guard ∧ U guard event)`. Derived from strict U. -/
def inclusiveUntil (guard event : PlusFormula) : PlusFormula :=
  sig% FormalSystem.Syntax.Sig.inclusiveUntil guard event

/-- Inclusive Since, guard first: `event ∨ (guard ∧ S guard event)`. Derived from strict S. -/
def inclusiveSince (guard event : PlusFormula) : PlusFormula :=
  sig% FormalSystem.Syntax.Sig.inclusiveSince guard event

/-! ### Literal expansions, usable as rewrite equalities -/

/-- Literal formula-data expansion of this derived view. -/
theorem release_expand (φ ψ : PlusFormula) :
    release φ ψ = (PlusFormula.untl ψ.neg φ.neg).neg := rfl
/-- Literal formula-data expansion of this derived view. -/
theorem trigger_expand (φ ψ : PlusFormula) :
    trigger φ ψ = (PlusFormula.snce ψ.neg φ.neg).neg := rfl
/-- Literal formula-data expansion of this derived view. -/
theorem weakUntil_expand (φ ψ : PlusFormula) :
    weakUntil φ ψ = (PlusFormula.untl ψ φ).or ψ.allFuture := rfl
/-- Literal formula-data expansion of this derived view. -/
theorem weakSince_expand (φ ψ : PlusFormula) :
    weakSince φ ψ = (PlusFormula.snce ψ φ).or ψ.allPast := rfl
/-- Literal formula-data expansion of this derived view. -/
theorem strongRelease_expand (φ ψ : PlusFormula) :
    strongRelease φ ψ = PlusFormula.untl ψ (ψ.and φ) := rfl
/-- Literal formula-data expansion of this derived view. -/
theorem strongTrigger_expand (φ ψ : PlusFormula) :
    strongTrigger φ ψ = PlusFormula.snce ψ (ψ.and φ) := rfl
/-- The double negation is what substituting `¬φ` into `release` produces; it is kept. -/
theorem before_expand (φ ψ : PlusFormula) :
    before φ ψ = ((PlusFormula.untl ψ.neg φ.neg.neg).neg).and (PlusFormula.someFuture φ) := rfl
/-- Literal formula-data expansion of this derived view. -/
theorem inclusiveUntil_expand (guard event : PlusFormula) :
    inclusiveUntil guard event = event.or (guard.and (PlusFormula.untl guard event)) := rfl
/-- Literal formula-data expansion of this derived view. -/
theorem inclusiveSince_expand (guard event : PlusFormula) :
    inclusiveSince guard event = event.or (guard.and (PlusFormula.snce guard event)) := rfl

/-! ### Time-reflection pins: each future view reflects to its past mirror -/

/-- Time reflection exchanges this view with its past/future mirror. -/
theorem reflect_time_release (φ ψ : PlusFormula) :
    (release φ ψ).reflectTime = trigger φ.reflectTime ψ.reflectTime := rfl
/-- Time reflection exchanges this view with its past/future mirror. -/
theorem reflect_time_trigger (φ ψ : PlusFormula) :
    (trigger φ ψ).reflectTime = release φ.reflectTime ψ.reflectTime := rfl
/-- Time reflection exchanges this view with its past/future mirror. -/
theorem reflect_time_weakUntil (φ ψ : PlusFormula) :
    (weakUntil φ ψ).reflectTime = weakSince φ.reflectTime ψ.reflectTime := rfl
/-- Time reflection exchanges this view with its past/future mirror. -/
theorem reflect_time_weakSince (φ ψ : PlusFormula) :
    (weakSince φ ψ).reflectTime = weakUntil φ.reflectTime ψ.reflectTime := rfl
/-- Time reflection exchanges this view with its past/future mirror. -/
theorem reflect_time_strongRelease (φ ψ : PlusFormula) :
    (strongRelease φ ψ).reflectTime = strongTrigger φ.reflectTime ψ.reflectTime := rfl
/-- Time reflection exchanges this view with its past/future mirror. -/
theorem reflect_time_strongTrigger (φ ψ : PlusFormula) :
    (strongTrigger φ ψ).reflectTime = strongRelease φ.reflectTime ψ.reflectTime := rfl
/-- Time reflection exchanges this view with its past/future mirror. -/
theorem reflect_time_inclusiveUntil (g e : PlusFormula) :
    (inclusiveUntil g e).reflectTime = inclusiveSince g.reflectTime e.reflectTime := rfl
/-- Time reflection exchanges this view with its past/future mirror. -/
theorem reflect_time_inclusiveSince (g e : PlusFormula) :
    (inclusiveSince g e).reflectTime = inclusiveUntil g.reflectTime e.reflectTime := rfl

end PlusFormula

end FormalSystem.PlusLanguage

namespace FormalSystem.Syntax.Formula

/-- Inclusive Until, guard first: `event ∨ (guard ∧ U guard event)`. Derived from strict U. -/
def inclusiveUntil (guard event : Formula) : Formula := sig% Sig.inclusiveUntil guard event

/-- Inclusive Since, guard first: `event ∨ (guard ∧ S guard event)`. Derived from strict S. -/
def inclusiveSince (guard event : Formula) : Formula := sig% Sig.inclusiveSince guard event

/-! ### Literal expansions of the existing TM views, usable as rewrite equalities -/

/-- Literal formula-data expansion of this derived view. -/
theorem release_expand (φ ψ : Formula) :
    release φ ψ = (Formula.untl ψ.neg φ.neg).neg := rfl
/-- Literal formula-data expansion of this derived view. -/
theorem trigger_expand (φ ψ : Formula) :
    trigger φ ψ = (Formula.snce ψ.neg φ.neg).neg := rfl
/-- Literal formula-data expansion of this derived view. -/
theorem weakUntil_expand (φ ψ : Formula) :
    weakUntil φ ψ = (Formula.untl ψ φ).or ψ.allFuture := rfl
/-- Literal formula-data expansion of this derived view. -/
theorem weakSince_expand (φ ψ : Formula) :
    weakSince φ ψ = (Formula.snce ψ φ).or ψ.allPast := rfl
/-- Literal formula-data expansion of this derived view. -/
theorem strongRelease_expand (φ ψ : Formula) :
    strongRelease φ ψ = Formula.untl ψ (ψ.and φ) := rfl
/-- Literal formula-data expansion of this derived view. -/
theorem strongTrigger_expand (φ ψ : Formula) :
    strongTrigger φ ψ = Formula.snce ψ (ψ.and φ) := rfl
/-- Literal formula-data expansion of this derived view. -/
theorem before_expand (φ ψ : Formula) :
    before φ ψ = ((Formula.untl ψ.neg φ.neg.neg).neg).and (Formula.someFuture φ) := rfl
/-- Literal formula-data expansion of this derived view. -/
theorem inclusiveUntil_expand (guard event : Formula) :
    inclusiveUntil guard event = event.or (guard.and (Formula.untl guard event)) := rfl
/-- Literal formula-data expansion of this derived view. -/
theorem inclusiveSince_expand (guard event : Formula) :
    inclusiveSince guard event = event.or (guard.and (Formula.snce guard event)) := rfl

/-- Time reflection exchanges this view with its past/future mirror. -/
theorem reflect_time_inclusiveUntil (g e : Formula) :
    (inclusiveUntil g e).reflectTime = inclusiveSince g.reflectTime e.reflectTime := rfl
/-- Time reflection exchanges this view with its past/future mirror. -/
theorem reflect_time_inclusiveSince (g e : Formula) :
    (inclusiveSince g e).reflectTime = inclusiveUntil g.reflectTime e.reflectTime := rfl

end FormalSystem.Syntax.Formula

namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax (Formula)

/-! ### Embedding pins

`ofFormula` commutes with every view definitionally, because each TM⁺ right-hand side is
`Formula`'s verbatim. If one of these stops being `rfl`, fix the view's definition. -/

/-- The TM embedding commutes with this derived view. -/
theorem ofFormula_release (φ ψ : Formula) :
    ofFormula (Formula.release φ ψ) = PlusFormula.release (ofFormula φ) (ofFormula ψ) := rfl
/-- The TM embedding commutes with this derived view. -/
theorem ofFormula_trigger (φ ψ : Formula) :
    ofFormula (Formula.trigger φ ψ) = PlusFormula.trigger (ofFormula φ) (ofFormula ψ) := rfl
/-- The TM embedding commutes with this derived view. -/
theorem ofFormula_weakUntil (φ ψ : Formula) :
    ofFormula (Formula.weakUntil φ ψ) = PlusFormula.weakUntil (ofFormula φ) (ofFormula ψ) := rfl
/-- The TM embedding commutes with this derived view. -/
theorem ofFormula_weakSince (φ ψ : Formula) :
    ofFormula (Formula.weakSince φ ψ) = PlusFormula.weakSince (ofFormula φ) (ofFormula ψ) := rfl
/-- The TM embedding commutes with this derived view. -/
theorem ofFormula_strongRelease (φ ψ : Formula) :
    ofFormula (Formula.strongRelease φ ψ) =
      PlusFormula.strongRelease (ofFormula φ) (ofFormula ψ) := rfl
/-- The TM embedding commutes with this derived view. -/
theorem ofFormula_strongTrigger (φ ψ : Formula) :
    ofFormula (Formula.strongTrigger φ ψ) =
      PlusFormula.strongTrigger (ofFormula φ) (ofFormula ψ) := rfl
/-- The TM embedding commutes with this derived view. -/
theorem ofFormula_before (φ ψ : Formula) :
    ofFormula (Formula.before φ ψ) = PlusFormula.before (ofFormula φ) (ofFormula ψ) := rfl
/-- The TM embedding commutes with this derived view. -/
theorem ofFormula_inclusiveUntil (g e : Formula) :
    ofFormula (Formula.inclusiveUntil g e) =
      PlusFormula.inclusiveUntil (ofFormula g) (ofFormula e) := rfl
/-- The TM embedding commutes with this derived view. -/
theorem ofFormula_inclusiveSince (g e : Formula) :
    ofFormula (Formula.inclusiveSince g e) =
      PlusFormula.inclusiveSince (ofFormula g) (ofFormula e) := rfl

/-- `ofFormula` on the inclusive view stays guard-first and agrees with the literal expansion. -/
example (g e : Formula) : ofFormula (Formula.inclusiveUntil g e) =
    (ofFormula e).or ((ofFormula g).and (PlusFormula.untl (ofFormula g) (ofFormula e))) := rfl

end FormalSystem.PlusLanguage
