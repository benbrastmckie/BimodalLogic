/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Ultraproduct.Carrier
import FormalSystem.Semantics.ShiftSet

/-!
# The ultraproduct shift set

`Ultraproduct/Carrier.lean` builds the two ultraproduct sorts — `UD φ D` on the duration family
and `UOmega φ Ω` on the history-carrier family — together with the lifted shift action `shU` and
its `sh_zero`/`sh_add` laws. This module assembles them into a `ShiftSet`:

* `UT φ T` — the **ultraproduct temporal order**, `TemporalOrder.of (UD φ (fun i => ↑(T i)))`;
* `uSep` — the `sep` field of `ShiftSet` (`Semantics/ShiftSet.lean:110`) discharged on the
  ultraproduct, by contraposition plus a global section chosen with `exists_section`;
* `uShiftSet φ S` — the ultraproduct shift set itself.

## No hypotheses

`uShiftSet` discharges **all seven** `ShiftSet` fields from `S : ∀ i, ShiftSet (T i)` alone:

```lean
uShiftSet : ∀ {I : Type} (φ : Ultrafilter I) {T : I → TemporalOrder},
  (∀ i, ShiftSet (T i)) → ShiftSet (UT φ T)
```

Contrast the exploratory `shiftSetOnUD` in
`Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean`, which takes `carrier_nonempty`,
`sep` and `A` as *hypotheses* because it had no ultraproduct proof of them. Here
`carrier_nonempty` comes from `(S i).carrier_nonempty.some`, `sep` is `uSep`, and `A` is the
eventual-truth valuation lifted through `Quotient.liftOn` with its well-definedness obligation
discharged inline. That the `sep` field is *first-order* over the signature
`⟨Ω, D; <, +, 0, sh, (A_p)⟩` is exactly what makes `uSep` provable at all — see the field's own
docstring in `Semantics/ShiftSet.lean`.

## No binder list on `T`

`uSep` and `uShiftSet` mention `∀ i, AddCommGroup ↑(T i)`, `LinearOrder ↑(T i)` and
`IsOrderedAddMonoid ↑(T i)` implicitly, through `UD` and `mk_abs`. None of these needs an
instance binder: `TemporalOrder`'s four algebra projections are registered as instances
(`Semantics/TemporalOrder.lean:91`), so they synthesize pointwise from `T i` itself.

## What is deliberately not here

The Łoś lemma and its `TruthAt` corollary — see `Ultraproduct/Los.lean`, which consumes
`uShiftSet` and nothing else from this module.

## Axiom profile

`#print axioms uSep` and `#print axioms uShiftSet` both report exactly
`[propext, Classical.choice, Quot.sound]`, with `sorryAx` absent. `Classical.choice` enters
through `exists_section` and through `Carrier.lean`'s `LinearOrder` instance; `propext` through
the `Quotient.liftOn` well-definedness proof for `A`.
-/

set_option linter.unusedSectionVars false

open Filter

namespace FormalSystem.Semantics.Ultraproduct

variable {I : Type} {φ : Ultrafilter I} {T : I → TemporalOrder}

/-! ## The ultraproduct temporal order -/

variable (φ T) in
/-- The ultraproduct temporal order.

`@[reducible]` is LOAD-BEARING. Without it `(UT φ T).carrier` does not reduce to
`UD φ (fun i => ↑(T i))` at `rw` motive-typing transparency, and every `rw` inside `uSep`
fails with "Application type mismatch ... expected to have type (UT φ T).carrier".
Measured: a plain `noncomputable def` breaks `uSep`'s `rw [← mk_zero]` and `rw [mk_abs]`. -/
@[reducible] noncomputable def UT : TemporalOrder := TemporalOrder.of (UD φ (fun i => ↑(T i)))

/-! ## The `sep` field on the ultraproduct -/

/-- **The `sep` field, discharged on the ultraproduct.**

Contrapositive plus `exists_section`. If `u ≠ w` then, `φ` being an ultrafilter,
`g i ≠ f i` holds eventually; the per-index contrapositive of `(S i).sep`
(`Semantics/ShiftSet.lean:110`) then supplies, eventually, a positive radius `x` beyond which
no shift of `f i` reaches `g i`. `exists_section` turns that eventual existential into a global
section `ξ`, whose class `mk ξ` is a positive radius in the ultraproduct — and the witness the
hypothesis returns for it contradicts the radius at any index in the (nonempty, because `φ` is
`NeBot`) triple intersection. -/
theorem uSep (S : ∀ i, ShiftSet (T i)) (w u : UOmega φ (fun i => (S i).Carrier))
    (h : ∀ x : ↑(UT φ T), 0 < x → ∃ y, |y| < x ∧ u = shU (fun i => (S i).sh) w y) : u = w := by
  haveI : ∀ i, Nonempty ↑(T i) := fun i => ⟨0⟩
  obtain ⟨f, rfl⟩ := omk_surjective w
  obtain ⟨g, rfl⟩ := omk_surjective u
  by_contra hc
  have h1 : ∀ᶠ i in φ, ¬ (g i = f i) :=
    Ultrafilter.eventually_not.mpr (fun hh => hc (omk_eq_omk.mpr hh))
  have h2 : ∀ᶠ i in φ, ∃ x : ↑(T i), 0 < x ∧ ∀ y, |y| < x → ¬ (g i = (S i).sh (f i) y) := by
    refine h1.mono (fun i hi => ?_)
    by_contra hx
    push_neg at hx
    exact hi ((S i).sep (f i) (g i) (fun x hx0 => hx x hx0))
  obtain ⟨ξ, hξ⟩ := exists_section h2
  obtain ⟨y, hy1, hy2⟩ := h (mk ξ) (by
    rw [← mk_zero]; exact mk_lt_mk.mpr (hξ.mono fun i hi => hi.1))
  obtain ⟨η, rfl⟩ := mk_surjective y
  rw [mk_abs] at hy1
  have hlt : ∀ᶠ i in φ, |η i| < ξ i := mk_lt_mk.mp hy1
  rw [shU_mk] at hy2
  have heq : ∀ᶠ i in φ, g i = (S i).sh (f i) (η i) := omk_eq_omk.mp hy2
  obtain ⟨j, hj1, hj2⟩ := ((hlt.and heq).and hξ).exists
  exact hj2.2 (η j) hj1.1 hj1.2

/-! ## The ultraproduct shift set -/

variable (φ) in
/-- **The ultraproduct shift set.** All seven fields discharged; no hypotheses.

`sh_zero` and `sh_add` come from `Carrier.lean`'s `shU_zero` and `shU_add` applied pointwise;
`sep` is `uSep`; and the valuation `A p` is *eventual* satisfaction of `p`, lifted off the
`carrierSetoid` quotient by `Quotient.liftOn` — well defined because eventually-equal sections
eventually agree on `(S i).A p`. -/
noncomputable def uShiftSet (S : ∀ i, ShiftSet (T i)) : ShiftSet (UT φ T) where
  Carrier := UOmega φ (fun i => (S i).Carrier)
  carrier_nonempty := ⟨omk (fun i => (S i).carrier_nonempty.some)⟩
  sh := shU (fun i => (S i).sh)
  sh_zero := fun w => shU_zero _ (fun i v => (S i).sh_zero v) w
  sh_add := fun w a b => shU_add _ (fun i v p q => (S i).sh_add v p q) w a b
  sep := uSep S
  A := fun p w => Quotient.liftOn w (fun f => ∀ᶠ i in φ, (S i).A p (f i)) (by
    intro f g h
    have h' : ∀ᶠ i in φ, f i = g i := h
    exact propext ⟨fun hf => hf.mp (h'.mono fun i hi hp => hi ▸ hp),
      fun hg => hg.mp (h'.mono fun i hi hp => hi ▸ hp)⟩)

end FormalSystem.Semantics.Ultraproduct
