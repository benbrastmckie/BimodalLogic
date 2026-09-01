/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Correspondence.Galois

/-!
# Forward recurrence: the frame-level correspondent of the density schema

The density schema `GGφ → Gφ` has **no** duration-level correspondent — a frame over a non-dense
carrier can validate every instance of it, as `Metalogic/Independence/StaticFrame.lean`'s
static frame over `ℤ` shows. What it *does* correspond to is a condition on the frame's own
structure, namely on which total histories `F.TaskRel` allows:

> whenever `s` immediately succeeds `t`, any state property holding throughout `(s, ∞)` along a
> total history already holds at `s`.

That is `TaskFrame.FwdRec`. Over a densely ordered carrier there are no covering pairs at all, so
the condition is vacuous and every frame satisfies it — which is why density's *soundness* half
never looked like a frame condition.

## Two results at two different strengths — stated separately, never merged

* **Atomic**, at arbitrary `D`: `F` validates every *atomic* instance of `GGφ → Gφ` iff `F.FwdRec`
  (`validOn_atomic_density_iff_fwdRec`, below). No hypothesis on the carrier.
* **Full schema**, at `D = ℤ` only: the schema-level statement needs the `Walk`/`MinCyc`
  periodicity apparatus, and the `ℤ` restriction is exactly what that apparatus buys. It is not
  proved here.

Merging the two would over-claim: the atomic version generalizes to every duration group and the
schema version, as currently proved anywhere, does not. Whether forward recurrence gives the full
schema over a general non-dense `D` — with "periodic" weakened to shift-recurrence under a
history-preserving order automorphism — is open, with the sum of `ℤ`/`nℤ` over `ℤ ×ₗ ℤ` as the
candidate counterexample.

## Main results

* `TaskFrame.FwdRec` — the frame condition, over bundled frames
* `validOn_iff_total` — the bridge from the `∀ M τ hτ t, TruthAt …` shape to `TaskFrame.ValidOn`
* `validOn_atomic_density_iff_fwdRec` — the atomic correspondence, at arbitrary `D`
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

/-! ## The frame condition -/

/--
**Forward recurrence at covering pairs.**

Stated over a bundled `TaskFrame`, so the carrier appears only as `F.Duration` and there is no
free carrier parameter. `t < s` together with `∀ r, t < r → r < s → False` says that `s`
immediately succeeds `t`; the conclusion is the "every state property holding throughout
`(s, ∞)` already holds at `s`" form, which is the shape the density axiom instance consumes.

This is a condition on `F`'s own structure — on which total histories `F.TaskRel` allows — and
**not** a condition on `F.Duration` alone. That distinction is the whole content of the (T0)
refutation recorded in `Semantics/Correspondence/DurationFrames.lean`.
-/
def TaskFrame.FwdRec (F : TaskFrame) : Prop :=
  ∀ (τ : F.HF) (t s : F.Duration), t < s → (∀ r, t < r → r < s → False) →
    ∀ A : F.WorldState → Prop,
      (∀ r, s < r → A (τ.val.states r (τ.property r))) → A (τ.val.states s (τ.property s))

/--
**The bridge between the two validity shapes.**

`TaskFrame.ValidOn` quantifies over the bundled subtype `F.HF`; correspondence arguments are
naturally written with the history and its totality proof unbundled. One term in each direction,
because `TaskFrame.HF` is a subtype and `.val`/`.property` are its projections.
-/
theorem validOn_iff_total (F : TaskFrame) (φ : Formula) :
    F.ValidOn φ ↔ ∀ (M : TaskModel F) (τ : WorldHistory F), τ.IsTotal → ∀ t, TruthAt M τ t φ :=
  ⟨fun h M τ hτ t => h M ⟨τ, hτ⟩ t, fun h M τ t => h M τ.val τ.property t⟩

/-! ## The atomic correspondence -/

/--
**Exact correspondence for the atomic density schema, at an arbitrary duration group.**

`F` validates every atomic instance of `GGφ → Gφ` exactly when `F` is forward-recurrent at
covering pairs. Both sides are properties of `F`; neither is a property of `F.Duration` alone.

(⇒) reads the recurrence witness off a single axiom instance, at the model whose valuation *is*
the state property `A`. (⇐) splits on whether the interval `(t, s)` is inhabited: if it is, the
axiom instance goes through on order grounds alone, and if it is not, `s` covers `t` and the
frame condition is consumed exactly there.
-/
theorem validOn_atomic_density_iff_fwdRec (F : TaskFrame) :
    (∀ p : Atom,
        F.ValidOn ((Formula.atom p).allFuture.allFuture.imp (Formula.atom p).allFuture))
      ↔ F.FwdRec := by
  simp only [validOn_iff_total]
  constructor
  · intro h τ t s hts hcov A hA
    let M : TaskModel F := ⟨fun w _ => A w⟩
    have hgg : TruthAt M τ.val t (Formula.atom (Atom.mk "p" none)).allFuture.allFuture := by
      rw [Truth.future_iff]
      intro u hu
      rw [Truth.future_iff]
      intro r hr
      have hsu : s ≤ u := by
        by_contra hlt
        exact hcov u hu (lt_of_not_ge hlt)
      exact ⟨τ.property r, hA r (lt_of_le_of_lt hsu hr)⟩
    have hg := h (Atom.mk "p" none) M τ.val τ.property t hgg
    rw [Truth.future_iff] at hg
    obtain ⟨_, hv⟩ := hg s hts
    exact hv
  · intro h p M τ hτ t hgg
    rw [Truth.future_iff]
    intro s hst
    rw [Truth.future_iff] at hgg
    by_cases hmid : ∃ r : F.Duration, t < r ∧ r < s
    · obtain ⟨r, h1, h2⟩ := hmid
      have hr := hgg r h1
      rw [Truth.future_iff] at hr
      exact hr s h2
    · have hcov : ∀ r, t < r → r < s → False := fun r hr1 hr2 => hmid ⟨r, hr1, hr2⟩
      have hA : ∀ r : F.Duration, s < r → M.valuation (τ.states r (hτ r)) p := by
        intro r hr
        have hs := hgg s hst
        rw [Truth.future_iff] at hs
        obtain ⟨_, hv⟩ := hs r hr
        exact hv
      exact ⟨hτ s, h ⟨τ, hτ⟩ t s hst hcov (fun w => M.valuation w p) hA⟩

end FormalSystem.Semantics
