/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Correspondence.DurationFrames
import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.CompletenessDerived
import FormalSystem.Semantics.LexCarrier
import FormalSystem.Theorems.DiscreteUnfolding

/-!
# `UZ` and `Z1` fail over every non-Archimedean discrete temporal order

`prop:archimedean` asserts that neither `UZ` nor `Z1` is valid over *any* discrete temporal order
that fails to be Archimedean. This module proves it at that generality: at an arbitrary
`(D : TemporalOrder)` carrying a least strictly positive duration and `¬ Archimedean ↑D`, both
formulas are refuted on `translationFrame D`.

## The paper's proof structure

Both countermodels share almost everything. One frame, `translationFrame D` — the deterministic
translation flow on `D` itself. One history, `translationHist D`. And one division of `D`, driven
by the least positive duration `u`:

* the **near** times, `E = {z | 0 < z ∧ ∃ n : ℕ, z < n • u}` — those within finitely many unit
  steps of `0`;
* and their complement, the times beyond every multiple of the unit.

`¬ Archimedean ↑D` is exactly what makes the second class nonempty, via
`Semantics.exists_gt_nsmul_of_not_archimedean`, which supplies the paper's `y`. The two proofs
then diverge only in the valuation they read off that division:

* for `Z1`, `|p|` is the complement of the near times, `Eᶜ`;
* for `UZ`, `|p|` is a copy of `ℤ` sitting above every multiple of the unit, `{y + n • u | n : ℤ}`.

## Where this sits in the duration dichotomy

This is the **least-positive** branch. Its dense twin is `Independence/ZTimeSharpness.lean`, which
refutes the same two formulas at an arbitrary densely ordered duration group; between them the two
modules cover every carrier, because `Semantics.duration_dense_or_least_pos` makes density and a
least positive element exhaustive on a nontrivial totally ordered abelian group.

That dichotomy is also why no `¬ DenselyOrdered`-hypothesis wrapper is stated here: a consumer
holding `¬ DenselyOrdered ↑D` reaches this module's hypothesis by
`(duration_dense_or_least_pos (D := ↑D)).resolve_left`, one step, with nothing for a wrapper to
add. The hypothesis forms that *are* carried below are the two a consumer cannot produce in one
step — the paper's own Discrete clause (`TaskFrame.IsDiscrete`) and a `[SuccOrder ↑D]` instance.

## Hypothesis form, and why it is not `[SuccOrder ↑D]` primarily

The primary binder is `IsLeast {z | 0 < z} u`, the paper's own "there is a least duration `1 > 0`"
read verbatim. It is `Prop`-valued rather than data, so it carries no choice of successor function
and unifies with a witness from any source — the duration dichotomy, a `SuccOrder` instance via
`Semantics.isLeast_pos_succ_zero`, or a hand-built witness such as `LexInt.isLeast_pos`. The
`[SuccOrder ↑D]` entry points below are wrappers over it, not the other way round.

## Choice dependence

`translationFrame` depends on `Classical.choice`, as does every declaration over it. Nothing in
this module is advertised as choice-free, and no result below should be read as a constructive
refutation.

## The atomic instance is forced

Both refuted formulas stay at `Formula.atom p` and are never schematic in `φ`, for the reason
`Independence/ZTimeSharpness.lean` already records at its own `.Base` results: `Axiom.prior_UZ ⊥`
has an unsatisfiable antecedent and so is valid everywhere, which would falsify a `∀ φ` form.

## Main results

- `not_validOn_prior_UZ_nonArchimedean`, `not_validOn_z1_nonArchimedean`: the two frame-level
  refutations at the primary `IsLeast` hypothesis.
- `not_validOn_prior_UZ_discrete_nonArchimedean`, `not_validOn_z1_discrete_nonArchimedean`: the
  same, from the paper's own Discrete clause.
- `not_validOn_prior_UZ_succ_nonArchimedean`, `not_validOn_z1_succ_nonArchimedean`: the same, from
  a `[SuccOrder ↑D]` instance.
- `not_validOnFrameOver_prior_UZ_nonArchimedean`, `not_validOnFrameOver_z1_nonArchimedean`:
  `prop:archimedean`'s own `⊭_D` shape — not valid on *every* frame over `D`.
- `lexZOrder`, `translationFrame_lexZ_not_isZTime`: a concrete non-Archimedean discrete carrier,
  and the record that its translation frame is regular and `IsDiscrete` yet not `IsZTime`.
- `not_validOnFrames_isDiscrete_prior_UZ`, `not_validOnFrames_isDiscrete_z1`: non-validity over
  the bare Discrete class of record.

## Tags

archimedean · discrete · countermodel · prior-uz · z1 · sharpness · translation-frame
-/

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

namespace FormalSystem.Metalogic.Independence

/-! ## Shape pins

Each `example` below type-checks only if the formula this module refutes is *exactly* the one the
matching derived theorem (or `Axiom` constructor) produces. They are duplicated deliberately from
`Independence/ZTimeSharpness.lean`'s own pins section, so that *this* module's generality claim is
independently a compiler obligation rather than a reading inherited from a neighbour: without them
a mis-transcribed formula would yield a true but vacuous non-validity result about some other
formula.
-/

/-- Shape pin: the formula below is exactly `Axiom.prior_UZ`'s. -/
example (φ : Formula) : Axiom (φ.someFuture.imp (Formula.untl φ.neg φ)) := Axiom.prior_UZ φ

/-- Shape pin: the formula below is exactly Z1's, the derived
`Metalogic.CompletenessDerived.z1Thm` (a theorem at `FrameClass.ZTime`). -/
example (φ : Formula) :
    DerivationTree FrameClass.ZTime []
      ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture)) :=
  FormalSystem.Theorems.DiscreteUnfolding.z1Schema φ

/-! ## The two frame-level refutations -/

/--
**`Axiom.prior_UZ` fails on the translation frame over any non-Archimedean duration group with a
least positive element.**

The valuation is the paper's: `|p| = {y + n • u | n : ℤ}`, a copy of `ℤ` sitting above every
multiple of the unit, where `y` is the time beyond all of them. Every member of it is strictly
positive (`hpos`, by cases on the sign of `n`: upwards from `y > 0` by `nsmul_nonneg`, downwards
by `y - k • u > 0`, which is what `y` being beyond every multiple buys).

`Fp` holds at `0` because `y` itself is a `p`-time above `0`. But no `p`-time has a `¬p`-guarded
initial segment: given a `p`-time `y + n • u`, its predecessor `y + (n - 1) • u` is **itself** a
positive `p`-time strictly below it, so the guard `¬p` fails there. That refutes `U(p, ¬p)`.

The paper states this last step contrapositively; it is read forwards here, by destructuring the
`untl` witness and contradicting its guard. A presentation reordering, not a deviation.
-/
theorem not_validOn_prior_UZ_nonArchimedean (D : TemporalOrder) {u : (D : Type)}
    (hu : IsLeast {z : (D : Type) | 0 < z} u) (hna : ¬ Archimedean (D : Type)) (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        ((Formula.atom p).someFuture.imp
          (Formula.untl (Formula.atom p).neg (Formula.atom p))) := by
  intro h
  have hu0 : (0 : (D : Type)) < u := hu.1
  obtain ⟨y, hy⟩ := exists_gt_nsmul_of_not_archimedean hu hna
  have hy0 : (0 : (D : Type)) < y := by simpa using hy 0
  set A : Set (D : Type) := {z | ∃ n : ℤ, z = y + n • u} with hA
  have hpos : ∀ n : ℤ, (0 : (D : Type)) < y + n • u := by
    intro n
    rcases le_or_gt 0 n with hn | hn
    · have hnn : (0 : (D : Type)) ≤ n • u := by
        lift n to ℕ using hn
        simpa using nsmul_nonneg hu0.le n
      exact lt_of_lt_of_le hy0 (le_add_of_nonneg_right hnn)
    · obtain ⟨k, hk⟩ : ∃ k : ℕ, n = -(k : ℤ) := ⟨(-n).toNat, by omega⟩
      subst hk
      rw [show (-(k : ℤ)) • u = -((k : ℕ) • u) by rw [neg_zsmul, natCast_zsmul],
        ← sub_eq_add_neg]
      exact sub_pos.mpr (hy k)
  have hval := h (translationModel D A) (translationHist D) 0
  rw [Truth.imp_iff] at hval
  have hant : TruthAt (translationModel D A) (translationHist D) 0
      (Formula.atom p).someFuture := by
    rw [Truth.some_future_iff]
    exact ⟨y, hy0, (translation_realizes D A p y).mpr ⟨0, by simp⟩⟩
  obtain ⟨s, h0s, hps, hguard⟩ := hval hant
  rw [translation_realizes] at hps
  obtain ⟨n, rfl⟩ := hps
  have hpred : y + (n - 1) • u < y + n • u := by
    refine add_lt_add_of_le_of_lt le_rfl ?_
    rw [sub_zsmul, one_zsmul, ← sub_eq_add_neg]
    exact sub_lt_self _ hu0
  have hne := hguard (y + (n - 1) • u) (hpos (n - 1)) hpred
  rw [Truth.neg_iff] at hne
  exact hne ((translation_realizes D A p _).mpr ⟨n - 1, rfl⟩)

/--
**Z1 (`Metalogic.CompletenessDerived.z1Thm`) fails on the same frame, under the same hypotheses.**

The valuation is the complement of the paper's near times: `|p| = Eᶜ`, where
`E = {z | 0 < z ∧ ∃ n : ℕ, z < n • u}` collects the times within finitely many unit steps of `0`.
Three facts about that division carry the proof:

* `hEstep`: `E` is closed under adding the unit — if `z < n • u` then `z + u < (n + 1) • u`. This
  is what makes `G(Gp → p)` hold at `0`: at a time `s` in `E`, the hypothesis `Gp` applied to
  `s + u ∈ E` is already a contradiction, so `p` at `s` follows vacuously.
* `hAbove`: everything strictly above `y` is outside `E`, since `y` exceeds every `n • u`. This
  gives `Gp` at `y`, hence `FGp` at `0`.
* `huE`: the unit is itself near (`u < 2 • u`), which refutes `Gp` at `0`.

So `G(Gp → p) → (FGp → Gp)` has a true antecedent and a false consequent at `0`.
-/
theorem not_validOn_z1_nonArchimedean (D : TemporalOrder) {u : (D : Type)}
    (hu : IsLeast {z : (D : Type) | 0 < z} u) (hna : ¬ Archimedean (D : Type)) (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
          ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) := by
  intro h
  have hu0 : (0 : (D : Type)) < u := hu.1
  obtain ⟨y, hy⟩ := exists_gt_nsmul_of_not_archimedean hu hna
  have hy0 : (0 : (D : Type)) < y := by simpa using hy 0
  set E : Set (D : Type) := {z | 0 < z ∧ ∃ n : ℕ, z < n • u} with hE
  set A : Set (D : Type) := Eᶜ with hA
  have hEstep : ∀ z, z ∈ E → z + u ∈ E := by
    rintro z ⟨hz0, n, hn⟩
    refine ⟨lt_trans hz0 (lt_add_of_pos_right _ hu0), n + 1, ?_⟩
    rw [succ_nsmul]
    exact add_lt_add_of_lt_of_le hn le_rfl
  have hAbove : ∀ z, y < z → z ∈ A := by
    intro z hz hzE
    obtain ⟨-, n, hn⟩ := hzE
    exact absurd (lt_trans (hy n) hz) (not_lt.mpr hn.le)
  have huE : u ∈ E := ⟨hu0, 2, by rw [two_nsmul]; exact lt_add_of_pos_right u hu0⟩
  have hval := h (translationModel D A) (translationHist D) 0
  rw [Truth.imp_iff] at hval
  have hant : TruthAt (translationModel D A) (translationHist D) 0
      ((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture := by
    rw [Truth.future_iff]
    intro s _
    rw [Truth.imp_iff]
    intro hGp
    rw [translation_realizes_allFuture] at hGp
    rw [translation_realizes]
    intro hsE
    exact hGp (s + u) (lt_add_of_pos_right s hu0) (hEstep s hsE)
  have hcons := hval hant
  rw [Truth.imp_iff] at hcons
  have hFGp : TruthAt (translationModel D A) (translationHist D) 0
      (Formula.atom p).allFuture.someFuture := by
    rw [Truth.some_future_iff]
    refine ⟨y, hy0, ?_⟩
    rw [translation_realizes_allFuture]
    exact hAbove
  have hnotGp : ¬ TruthAt (translationModel D A) (translationHist D) 0
      (Formula.atom p).allFuture := by
    rw [translation_realizes_allFuture]
    intro hall
    exact hall u hu0 huE
  exact hnotGp (hcons hFGp)

/-! ## The paper's own Discrete hypothesis -/

/--
**`Axiom.prior_UZ` fails at the paper's own Discrete clause.**

`TaskFrame.IsDiscrete` is the Discrete clause of `def:frame-properties` stated pointwise — every
time with a strict upper bound has a *least* one — and this is the entry point a consumer holding
that clause uses. The least positive duration the countermodel needs is extracted through
`Semantics.isDiscrete_iff_exists_isLeast_pos`, whose `.mp` direction unifies with
`TaskFrame.IsDiscrete` directly; no detour through `TaskFrame.exists_pos_of_nontrivial` is needed.
-/
theorem not_validOn_prior_UZ_discrete_nonArchimedean (D : TemporalOrder)
    (hdisc : (translationFrame D).toTaskFrame.IsDiscrete) (hna : ¬ Archimedean (D : Type))
    (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        ((Formula.atom p).someFuture.imp
          (Formula.untl (Formula.atom p).neg (Formula.atom p))) := by
  obtain ⟨u, hu⟩ := (isDiscrete_iff_exists_isLeast_pos D).mp hdisc
  exact not_validOn_prior_UZ_nonArchimedean D hu hna p

/-- **The Z1 half at the Discrete hypothesis**, by the same extraction. -/
theorem not_validOn_z1_discrete_nonArchimedean (D : TemporalOrder)
    (hdisc : (translationFrame D).toTaskFrame.IsDiscrete) (hna : ¬ Archimedean (D : Type))
    (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
          ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) := by
  obtain ⟨u, hu⟩ := (isDiscrete_iff_exists_isLeast_pos D).mp hdisc
  exact not_validOn_z1_nonArchimedean D hu hna p

/-! ## The successor-order hypothesis -/

/--
**`Axiom.prior_UZ` fails over a non-Archimedean duration group with a successor structure.**

A `[SuccOrder ↑D]` instance is the strongest of the three hypothesis forms carried here, and the
one a caller with a concrete discrete carrier usually has. It routes through
`Semantics.isLeast_pos_succ_zero`: `Order.succ 0` is the least strictly positive element.

The primary binder on the two results above is deliberately the weaker, `Prop`-valued `IsLeast`
rather than this instance — it carries no choice of successor function, and so admits a witness
from the duration dichotomy or from a hand-built one such as `LexInt.isLeast_pos`.
-/
theorem not_validOn_prior_UZ_succ_nonArchimedean (D : TemporalOrder) [SuccOrder (D : Type)]
    (hna : ¬ Archimedean (D : Type)) (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        ((Formula.atom p).someFuture.imp
          (Formula.untl (Formula.atom p).neg (Formula.atom p))) :=
  not_validOn_prior_UZ_nonArchimedean D isLeast_pos_succ_zero hna p

/-- **The Z1 half at the `SuccOrder` hypothesis**, through the same `isLeast_pos_succ_zero`. -/
theorem not_validOn_z1_succ_nonArchimedean (D : TemporalOrder) [SuccOrder (D : Type)]
    (hna : ¬ Archimedean (D : Type)) (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
          ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) :=
  not_validOn_z1_nonArchimedean D isLeast_pos_succ_zero hna p

/-! ## `prop:archimedean`'s own shape: not valid *over* `D` -/

/--
**`UZ` is not valid over any non-Archimedean `D` with a least positive duration.**

"Valid over `D`" is validity on *every* frame over `D`, which is the shape
`Semantics.validOn_df_iff_isDiscrete` renders the paper's `⊨_D` in; its negation follows from a
single refuting frame over `D`, and `translationFrame D` is one.

This and `not_validOnFrameOver_z1_nonArchimedean` are the two identifiers the paper's
`prop:archimedean` will cite, in `FormalSystem.Metalogic.Independence`.
-/
theorem not_validOnFrameOver_prior_UZ_nonArchimedean (D : TemporalOrder) {u : (D : Type)}
    (hu : IsLeast {z : (D : Type) | 0 < z} u) (hna : ¬ Archimedean (D : Type)) (p : Atom) :
    ¬ ∀ F : FrameOver D, F.toTaskFrame.ValidOn
        ((Formula.atom p).someFuture.imp
          (Formula.untl (Formula.atom p).neg (Formula.atom p))) :=
  fun h => not_validOn_prior_UZ_nonArchimedean D hu hna p (h (translationFrame D))

/-- **`prop:archimedean`'s own shape for `Z1`**, the second identifier the paper cites. -/
theorem not_validOnFrameOver_z1_nonArchimedean (D : TemporalOrder) {u : (D : Type)}
    (hu : IsLeast {z : (D : Type) | 0 < z} u) (hna : ¬ Archimedean (D : Type)) (p : Atom) :
    ¬ ∀ F : FrameOver D, F.toTaskFrame.ValidOn
        (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
          ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) :=
  fun h => not_validOn_z1_nonArchimedean D hu hna p (h (translationFrame D))

/-! ## Instantiation at a concrete non-Archimedean discrete carrier -/

/--
The duration group the class-level corollaries below are read off at: `ℤ ×ₗ ℤ`, the lexicographic
product, which is discrete and not Archimedean at once. `LexInt.isLeast_pos` supplies its least
positive duration `toLex (0, 1)` and `LexInt.not_archimedean` its failure of the Archimedean
property, both at `α ×ₗ ℤ` for any nontrivial `α`.

`Correspondence.Rigidity`'s `lexRat_not_archimedean` is **not** usable here: `ℚ ×ₗ ℚ` is densely
ordered, so it has no least positive duration at all and falls on the other branch of the
dichotomy — the one `Independence/ZTimeSharpness.lean` handles.

Carries a real body rather than being stated abstractly, mirroring `ztimeSharpOrder` in
`Independence/ZTimeSharpness.lean`.
-/
noncomputable abbrev lexZOrder : TemporalOrder := TemporalOrder.of (ℤ ×ₗ ℤ)

/--
**The witness frame is regular and `IsDiscrete`, yet not `IsZTime`.**

This is the non-collision, on the record. `TaskFrame.IsZTime` is the successor-Archimedean
narrowing of `IsDiscrete`, and its successor-Archimedean component would make the duration group
Archimedean by `Semantics.archimedean_of_succ` — which `LexInt.not_archimedean` refutes at
`ℤ ×ₗ ℤ`. So nothing in this module contradicts `prior_UZ_validIn_iff_ztime` or
`z1_validIn_iff_ztime`: the frames refuted here are outside the class those characterizations
assert validity on.
-/
theorem translationFrame_lexZ_not_isZTime :
    ¬ (translationFrame lexZOrder).toTaskFrame.IsZTime := by
  rintro ⟨so, -, hsa, -⟩
  exact LexInt.not_archimedean (@archimedean_of_succ (ℤ ×ₗ ℤ) _ _ _ so _ hsa)

/--
**`UZ` is not valid over the bare Discrete class of record.**

The class is `def:frame-properties`' Regular-and-Discrete conjunction, which is what `def:BX-z`
narrows when it pins `TM_z`'s soundness class to `ℤ`-time. The witness is
`translationFrame lexZOrder`: regular by the frame's own instance, `IsDiscrete` by
`Semantics.translationFrame_isDiscrete` at `LexInt.isLeast_pos`, and **not** `IsZTime` by
`translationFrame_lexZ_not_isZTime` — which is why this result and
`prior_UZ_validIn_iff_ztime` are both true.
-/
theorem not_validOnFrames_isDiscrete_prior_UZ (p : Atom) :
    ¬ ValidOnFrames (fun F : TaskFrame => F.IsRegular ∧ F.IsDiscrete)
        ((Formula.atom p).someFuture.imp
          (Formula.untl (Formula.atom p).neg (Formula.atom p))) :=
  fun h => not_validOn_prior_UZ_nonArchimedean lexZOrder LexInt.isLeast_pos
    LexInt.not_archimedean p
    (h _ ⟨inferInstance, translationFrame_isDiscrete _ LexInt.isLeast_pos⟩)

/--
**`Z1` is not valid over the bare Discrete class of record**, at the same witness frame and for
the same reason — regular, `IsDiscrete`, not `IsZTime`.
-/
theorem not_validOnFrames_isDiscrete_z1 (p : Atom) :
    ¬ ValidOnFrames (fun F : TaskFrame => F.IsRegular ∧ F.IsDiscrete)
        (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
          ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) :=
  fun h => not_validOn_z1_nonArchimedean lexZOrder LexInt.isLeast_pos LexInt.not_archimedean p
    (h _ ⟨inferInstance, translationFrame_isDiscrete _ LexInt.isLeast_pos⟩)

end FormalSystem.Metalogic.Independence
