/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.DriftHistories
import FormalSystem.Metalogic.Independence.StateSetTruth

/-!
# `Deterministic` is not L⁺-definable — `cor:no-characterization`

The two headline results, obtained by instantiating the generic state-set bridge
(`Independence/StateSetTruth.lean`) at the **indistinguishable pair** `F°` (the drift frame,
`Independence/DriftFrame.lean`) and `F¹` (the translation flow,
`Independence/RealTranslationFrame.lean`).

## Main Results

- `fzero_determined` together with `fzero_not_deterministic` — **(T3)**: a frame that validates
  *Determined* without being deterministic, so the converse of
  `determined_of_deterministic` (`Semantics/PlusLanguage/PlusDeterminism.lean`) fails
- `fzero_plusValidOn_iff_f1` — **(T4)**: `F°` and `F¹` validate exactly the same `PlusFormula`s
- `deterministic_not_plusDefinable` — the conclusion: no set of L⁺ formulas defines the
  deterministic frames

## The three-way split the "exactly" claim conflates

The claim *"Determined (`φ → ⊡φ`) is valid exactly over the Deterministic frames"* runs together
three different regions, and only the first two coincide:

1. `⊡` trivializes **semantically** — `⟨τ⟩_x` is a singleton at every total history and time —
   **exactly** on the deterministic frames. That is `lem:deterministic-singleton`, whose (⇒) half
   is `states_eq_of_deterministic`.
2. `⊡` trivializes **logically** — *Determined* is frame-valid — on a class **strictly
   containing** them. `F°` is in that class (`fzero_determined`) and not deterministic
   (`fzero_not_deterministic`): its histories through a given state at a given time are many, but
   they all agree on every L⁺ formula, which is all validity can see.
3. Neither region is **L⁺-definable** (`deterministic_not_plusDefinable`).

So the ⇒ direction of the claim holds (`determined_of_deterministic`), the ⇐ direction is false,
and no repair by a different formula set is possible.

## Uniform substitution is unsound here

`p → ⊡p` is frame-valid over `F°`, while `Fp → ⊡Fp` is refutable over `natFrame`
(`refute_determined`, `Semantics/PlusLanguage/PlusNonValidities.lean`). A schema's validity at atomic
instances therefore does not transfer to its substitution instances in this setting — atoms are
state formulas by definition of the valuation, and general formulas are not. **No proof in this
development argues by substitution**, and none may.

## Axiom pin (C4)

Recorded from `#print axioms` at the time of writing, and re-checkable by uncommenting:

```
#print axioms FormalSystem.Metalogic.Independence.fzero_determined
#print axioms FormalSystem.Metalogic.Independence.fzero_plusValidOn_iff_f1
#print axioms FormalSystem.Metalogic.Independence.deterministic_not_plusDefinable
```

All three report `[propext, Classical.choice, Quot.sound]`, and the `Classical.choice` is
**carrier-borne, not argument-borne**. Three cross-checks establish that, and they are the pin
that actually matters:

* `#print axioms fzero_not_deterministic` — a statement whose entire proof is two `norm_num`
  facts about `1` and `2` — already reports `Classical.choice`. It comes with `ℝ` itself, whose
  order and field structure are classical in Mathlib.
* `#print axioms plusTruthAt_iff_mem_satSet` reports `[propext]` **alone**, and
  `#print axioms determined_of_orderFlow` reports `[propext, Quot.sound]`. The entire generic
  argument — the state-set recursion, the bridge, and the validity corollary — is therefore
  choice-free; only its *instantiation* at a real carrier is not.
* The two hypotheses that *could* have needed `thm:extension` and Zorn, namely
  `fzero_stateOccurs` and `f1_stateOccurs`, are discharged by **explicit affine witnesses**
  rather than by `cor:occurrence`.

So no step here is a "validity ⟹ frame condition" step, and nothing reintroduces the ZFC
direction that `Semantics/PlusLanguage/PlusDeterminism.lean`'s docstring stays clear of; that module's own
collapse theorems still report `[propext]` alone.

## References

* JPL paper `cor:no-characterization`, `app:deterministic`, `app:drift`
* `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean` — the positive half whose converse fails here

## Tags

independence · definability · determinism · plus-language · app:deterministic
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage

/-! ## (H1) and (H2) for F¹ -/

/-- **(H1) for `F¹`**: a translation history is an order-isomorphism of `(ℝ, <)`, trivially —
`τ(t) = τ(0) + t` (`f1_states_eq`). -/
theorem f1_orderFlow : OrderFlow F1 where
  strictMono := by
    intro τ hτ s t hst
    have hs := f1_states_eq τ hτ s
    have ht := f1_states_eq τ hτ t
    show τ.states s (hτ s) < τ.states t (hτ t)
    rw [hs, ht]
    linarith
  hits_future := by
    intro τ hτ x v hv
    refine ⟨x + (v - τ.states x (hτ x)), ?_, ?_⟩
    · have : (0 : ℝ) < v - τ.states x (hτ x) := sub_pos.mpr hv
      show x < x + (v - τ.states x (hτ x))
      linarith
    · have hx := f1_states_eq τ hτ x
      have hc := f1_states_eq τ hτ (x + (v - τ.states x (hτ x)))
      show τ.states (x + (v - τ.states x (hτ x))) _ = v
      rw [hc]
      linarith [hx]
  hits_past := by
    intro τ hτ x v hv
    refine ⟨x - (τ.states x (hτ x) - v), ?_, ?_⟩
    · have : (0 : ℝ) < τ.states x (hτ x) - v := sub_pos.mpr hv
      show x - (τ.states x (hτ x) - v) < x
      linarith
    · have hx := f1_states_eq τ hτ x
      have hc := f1_states_eq τ hτ (x - (τ.states x (hτ x) - v))
      show τ.states (x - (τ.states x (hτ x) - v)) _ = v
      rw [hc]
      linarith [hx]

/-- **(H2) for `F¹`**, with an explicit witness: the orbit through `w - x` has state `w` at time
`x`. No `thm:extension`, no Zorn. -/
theorem f1_stateOccurs : StateOccurs F1 := by
  intro w x
  refine ⟨oneShift.hist (w - x), oneShift.hist_isTotal _, ?_⟩
  show w - x + x = w
  ring

/-! ## (T3) — a non-deterministic frame validating *Determined* -/

/-- **`F°` validates *Determined*** — every instance, `φ` arbitrary — by the generic
`determined_of_orderFlow`. -/
theorem fzero_determined (φ : PlusFormula) : F0.PlusValidOn (.imp φ (.stab φ)) :=
  determined_of_orderFlow fzero_orderFlow fzero_stateOccurs φ

/--
**(T3): the "exactly" claim is false.** `F°` validates every instance of *Determined* and is not
deterministic, so the converse of `determined_of_deterministic`
(`Semantics/PlusLanguage/PlusDeterminism.lean`) fails — validity of the schema does **not** characterize
`TaskFrame.Deterministic`.
-/
theorem determined_valid_on_non_deterministic :
    (∀ φ : PlusFormula, F0.PlusValidOn (.imp φ (.stab φ))) ∧ ¬ F0.Deterministic :=
  ⟨fzero_determined, fzero_not_deterministic⟩

/-! ## (T4) — F° and F¹ are L⁺-indistinguishable -/

/--
**(T4): `F°` and `F¹` validate exactly the same L⁺ formulas.**

Both sides reduce, by `plusValidOn_iff_satSet_univ`, to the *same* frame-free condition — that
`satSet V φ` is all of `ℝ` for every valuation `V` — because the state-set recursion mentions
only the order on `ℝ` and neither task relation.
-/
theorem fzero_plusValidOn_iff_f1 (φ : PlusFormula) : F0.PlusValidOn φ ↔ F1.PlusValidOn φ := by
  rw [plusValidOn_iff_satSet_univ fzero_orderFlow fzero_stateOccurs φ,
      plusValidOn_iff_satSet_univ f1_orderFlow f1_stateOccurs φ]

/--
**`Deterministic` is not L⁺-definable** (`cor:no-characterization`).

No set `Γ` of `PlusFormula`s has "`F` validates every member of `Γ`" equivalent to
`F.Deterministic`. Any such `Γ` would be validated by `F¹`, which is deterministic; by (T4) it
would then be validated by `F°`; and `F°` is not deterministic.

This is *elimination by indistinguishability*, not separation: the two frames **agree** on every
L⁺ sentence, which is precisely why no such sentence set can tell determinism apart.

Paper: `app:deterministic`
-/
theorem deterministic_not_plusDefinable :
    ¬ ∃ Γ : Set PlusFormula, ∀ F : TaskFrame, F.Deterministic ↔ ∀ φ ∈ Γ, F.PlusValidOn φ := by
  rintro ⟨Γ, hΓ⟩
  have h1 : ∀ φ ∈ Γ, F1.PlusValidOn φ := (hΓ F1).mp f1_deterministic
  have h0 : ∀ φ ∈ Γ, F0.PlusValidOn φ := fun φ hφ => (fzero_plusValidOn_iff_f1 φ).mpr (h1 φ hφ)
  exact fzero_not_deterministic ((hΓ F0).mpr h0)

end FormalSystem.Metalogic.Independence
