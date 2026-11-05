/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Frames.TranslationProduct
import FormalSystem.PlusLanguage.PlusValidity

/-!
# Naming rules: soundness of the irreflexivity and clock rules over L⁺

A **naming rule** is a non-orthodox inference rule: it licenses inferring `φ` from
`A(q) → φ` for a sentence letter `q` that does not occur in `φ`, where `A(q)` says that `q`
behaves like a *name* for the time of evaluation. The letter is auxiliary — it is discharged by
the rule and never appears in the conclusion — which is what makes such a rule sound without
`A(q)` being valid.

## Why a time can be named inside a stability cluster but not globally

No L⁺ formula can be true at exactly one time of every history: truth at a time is evaluated
against a valuation on world states, and a world state may recur. What *can* be arranged is a
model in which `q` holds at exactly one time of each history and in which that time is the same
across the whole stability cluster of the present state — the set `⟨τ⟩_x` of histories agreeing
with `τ` at `x` (`def:BLstar-semantics`). The translation product
(`Semantics/Frames/TranslationProduct.lean`) supplies exactly such a model: its states carry a
clock reading, every task advances the clock by its own duration (`clock_eq`), and `q` is
interpreted as "the clock reads zero". The clock is rigid under `⊡` because two histories
through one product state read the same clock there.

So the device is: move to the translation product, name the time with the clock, run the premise
there, then forget `q` (`plusTruthAt_congr_of_fresh`) and project back along
`HistMorphism.plus_invariance` / `plus_invariance`. The letter is auxiliary and the product is a
proof device, never an intended model — the standing caveat of the translation-product module
applies here unchanged.

## Main Definitions

- `Fresh q φ` — the atom `q` does not occur in `φ`
- `clockModel` — the product valuation that reads `q` as "the clock is zero"
- `nm`, `once`, `rigid`, `clockAnte` — the clock rule's antecedent, as L⁺ formulas

## Main Results

- `plusTruthAt_congr_of_fresh` — L⁺ truth is unchanged by a valuation change at a fresh atom only
- `plusTruthAt_nm`, `plusTruthAt_once`, `plusTruthAt_rigid`, `plusTruthAt_clockAnte` — the clock
  valuation satisfies the antecedent on every history of the product
- `clock_irr_sound` — **soundness of the clock rule**: an atom may be assumed to hold at exactly
  one time of every history, with that time rigid under `⊡`
- `irr_sound` — **soundness of Gabbay's plain irreflexivity rule**, as a corollary

## Not formalized

No completeness, decidability or axiomatizability claim is made or implied. These are soundness
facts about two rules; what an axiomatization built on them would prove is not settled here.

## References

* `FormalSystem/Semantics/Frames/TranslationProduct.lean` — the clock product and its invariance
* `FormalSystem/Semantics/HistoryMorphism.lean` — `TwoWayBounded`, `HistMorphism.plus_invariance`
* Gabbay's irreflexivity rule and Reynolds' *Auxiliary Atoms* rule are the two sources; the clock
  rule below is the strengthening of the former that the latter's device suggests

## Tags

naming-rules · irreflexivity · clock-rule · soundness · plus-language
-/

namespace FormalSystem.Metalogic.NamingRules

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage

/-! ## Freshness -/

/-- **The atom `q` does not occur in the formula.** A naming-rule-local predicate on the seven
L⁺ constructors: the syntax layer carries no `atoms` function, and adding one would rebuild every
dependent of `PlusLanguage/Formula.lean` for a notion only these two rules consume. -/
def Fresh (q : Atom) : PlusFormula → Prop
  | .atom p => p ≠ q
  | .bot => True
  | .imp a b => Fresh q a ∧ Fresh q b
  | .box a => Fresh q a
  | .untl a b => Fresh q a ∧ Fresh q b
  | .snce a b => Fresh q a ∧ Fresh q b
  | .stab a => Fresh q a

/-- `Fresh` rejects the atom it is about. -/
example (q : Atom) : ¬ Fresh q (PlusFormula.atom q) := fun h => h rfl

/-- `Fresh` accepts every other atom. -/
example (p q : Atom) (h : p ≠ q) : Fresh q (PlusFormula.atom p) := h

/-- `Fresh` is not everywhere true: it rejects a compound containing the atom. -/
example (q : Atom) : ¬ Fresh q (PlusFormula.stab (PlusFormula.atom q)) := fun h => h rfl

/--
**L⁺ truth is unchanged by a valuation change at a fresh atom only.**

Two models agreeing at every atom other than `q` give the same truth value to every `q`-fresh
formula, at every history and every time. This is what discharges the auxiliary letter: the
premise is instantiated at a model built to satisfy the antecedent, and the conclusion — being
`q`-free — holds at the model that forgets `q`.

By induction on `φ`. The `box` and `stab` cases are `forall_congr'` chains: both clauses
quantify over histories and neither consults the valuation except through the inductive
hypothesis.

Paper: — (formalization-native; the manuscript states no naming rule)
-/
theorem plusTruthAt_congr_of_fresh {F : TaskFrame} (M M' : TaskModel F) (q : Atom)
    (hV : ∀ (w : F.WorldState) (p : Atom), p ≠ q → (M.valuation w p ↔ M'.valuation w p)) :
    ∀ φ : PlusFormula, Fresh q φ → ∀ (τ : WorldHistory F) (t : F.Duration),
      PlusTruthAt M τ t φ ↔ PlusTruthAt M' τ t φ := by
  intro φ
  induction φ with
  | atom p => intro hq τ t; exact hV _ _ hq
  | bot => intro _ _ _; exact Iff.rfl
  | imp a b ih1 ih2 => intro hq τ t; exact imp_congr (ih1 hq.1 τ t) (ih2 hq.2 τ t)
  | box a ih => intro hq τ t; exact forall_congr' fun σ => ih hq σ t
  | untl a b ih1 ih2 =>
    intro hq τ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 hq.2 τ s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 hq.1 τ r)
  | snce a b ih1 ih2 =>
    intro hq τ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 hq.2 τ s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 hq.1 τ r)
  | stab a ih =>
    intro hq τ t
    exact forall_congr' fun σ => imp_congr_right fun _ => ih hq σ t

end FormalSystem.Metalogic.NamingRules
