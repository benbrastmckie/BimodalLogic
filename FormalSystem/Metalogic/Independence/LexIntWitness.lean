/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.StaticFrame
import FormalSystem.Metalogic.Soundness
import FormalSystem.Semantics.Correspondence.Indicator
import FormalSystem.Semantics.DurationClassification
import FormalSystem.Semantics.LexCarrier
import Mathlib.Data.Prod.Lex
import Mathlib.Algebra.Order.Monoid.Prod
import Mathlib.Algebra.Order.Group.Int

/-!
# Witness (b): the static frame over `ℤ ×ₗ ℤ`, and the Discrete sandwich

`FrameClass.Sat FrameClass.Discrete` is **not** Galois-closed. `Sat .Discrete` is
`TaskFrame.IsSuccArchDiscrete`, `def:TMplus-f`'s Hölder narrowing to ℤ-time, and the witness that
it is strictly smaller than the model class of its axiom set is the static frame over
`ℤ ×ₗ ℤ`: a discrete carrier — every point has an immediate successor, `toLex (0, 1)` above it —
that is **not Archimedean**, since `toLex (1, 0)` dominates every multiple of `toLex (0, 1)`.

All four `TemporalOrder` components (`AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`,
`Nontrivial`) synthesize for `ℤ ×ₗ ℤ` with no help, exactly as they do for `ℚ ×ₗ ℤ` in
`Semantics/LexCarrier.lean`; this file declares **no** new instance.

Membership in `Mod (AxiomSet .Discrete)` goes *through the constant-truth calculus* of
`Metalogic/Independence/StaticFrame.lean`. Writing `b(φ)` for the constant truth value of `φ`,
discreteness gives `b(U(ψ, φ)) = b(φ)` and hence `b(Fφ) = b(Gφ) = b(φ)`, so:

* `prior_UZ` (`Fφ → U(¬φ, φ)`) reduces to `b(φ) → b(φ)`, and `prior_SZ` dually;
* `z1` is `static_validates_z1`, which needs only time-invariance;
* every axiom at `minFrameClass ≤ .Base` is sound on *every* task frame.

## The upper bound is `{F | F.IsDiscrete}`, and it is obtained semantically

`Mod (AxiomSet .Discrete) ⊆ {F | F.IsDiscrete}` — the **paper's** bare Discrete clause, not
`Sat .Discrete`. The two are different classes, and this file is the proof that they are:
`lexIntStaticFrame` is in the first and not the second.

The inclusion is proved by `validOn_nextTop_of_mem_mod_discrete`, which replays
`Theorems/DiscreteUnfolding.succIndicatorAt`'s route at the *semantic* level:
`Axiom.prior_UZ ⊤` is a member of `AxiomSet .Discrete`, its antecedent `F⊤` holds on every frame
(a nontrivial ordered duration group has no maximum), and its consequent `U(¬⊤, ⊤)` has exactly
the truth condition of `U(⊥, ⊤) = X⊤`, since `¬⊤` and `⊥` are both false everywhere. This route
is deliberately **independent of the `Derivable`-level `succIndicatorAt`**: no proof theory is
imported into the semantic sandwich.

## The sandwich is over `AxiomSet`, never a theorem set

Same contract as `Metalogic/Independence/RationalWitness.lean`: `Mod` of the theorem set would
require a single-frame `F.ValidOn φ → F.ValidOn φ.swapTemporal` closure lemma for
`temporal_duality`, which does not exist and is false in general.

## Main results

* the `ℤ ×ₗ ℤ` order facts, imported from `Semantics/LexCarrier.lean`'s generic `LexInt` API
* `lexIntStaticFrame`, `lexIntStaticFrame_mem_mod`, `lexIntStaticFrame_not_sat` — the witness
* `validOn_nextTop_of_mem_mod_discrete` — the semantic upper-bound engine
* `sat_discrete_ssubset_mod_axiomSet`, `mod_axiomSet_discrete_subset_isDiscrete` — the sandwich
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.ProofSystem

/-! ## `ℤ ×ₗ ℤ`: the carrier, by instantiation

`Semantics/LexCarrier.lean` carries the whole `α ×ₗ ℤ` apparatus at an **arbitrary** ordered
abelian group in the first coordinate: the four ambient instances, the `SuccOrder`/`PredOrder`
pair, `LexInt.isLeast_pos`, and the three non-Archimedean theorems. This module is one of its two
instantiations — the other is `ℚ ×ₗ ℤ` in `Metalogic/Z1Countermodel.lean` — and re-derives none
of it. In particular the four-`example` instance-pinning ritual that used to sit here is gone;
`LexCarrier.lean` carries the single surviving copy.

The immediate-successor and immediate-predecessor facts this module's `.Discrete` dispatch needs
are `DurationClassification.isLeast_succ_of_isLeast_pos` and `isGreatest_pred_of_isLeast_pos`
applied to `LexInt.isLeast_pos`, at `α := ℤ`.
-/

/-! ## The witness frame -/

/--
The **static frame over `ℤ ×ₗ ℤ`**: two world states, and the identity task relation at every
duration. Its duration group is discrete but not Archimedean, hence not successor-Archimedean.
-/
def lexIntStaticFrame : TaskFrame := (FrameOver.staticFrame Bool (D := ℤ ×ₗ ℤ)).toTaskFrame

/--
**The witness is not in `Sat .Discrete`.**

`Sat .Discrete` is `TaskFrame.IsSuccArchDiscrete`, whose successor half — a `SuccOrder` together
with `IsSuccArchimedean` — is exactly what `Semantics.archimedean_of_succ` converts into
`Archimedean`, and `LexInt.not_archimedean` refutes that.

The existential's `PredOrder` and `IsPredArchimedean` components are simply unused, matching
`DurationClassification.lean`'s own recorded measurement that the transfer needs only the
successor half.
-/
theorem lexIntStaticFrame_not_sat :
    lexIntStaticFrame ∉ {F : TaskFrame | FrameClass.Sat FrameClass.Discrete F} := by
  rintro ⟨so, _, hsa, _⟩
  exact LexInt.not_archimedean (@archimedean_of_succ (ℤ ×ₗ ℤ) _ _ _ so _ hsa)

/--
**The witness models every `.Discrete` axiom instance.**

Dispatch: everything at `minFrameClass ≤ .Base` is sound on every task frame; `prior_UZ` and
`prior_SZ` are the discrete `untl`/`snce` calculus; `z1` is `static_validates_z1`; the two Dense
and three Dedekind axioms are eliminated by `Dense ≰ Discrete` and `Dedekind ≰ Discrete`.
-/
theorem lexIntStaticFrame_mem_mod :
    lexIntStaticFrame ∈ Semantics.Mod (AxiomSet FrameClass.Discrete) := by
  have hdisc : ∀ x : ℤ ×ₗ ℤ, ∃ y, IsLeast {z : ℤ ×ₗ ℤ | x < z} y :=
    fun x => ⟨_, isLeast_succ_of_isLeast_pos LexInt.isLeast_pos x⟩
  have hpred : ∀ x : ℤ ×ₗ ℤ, ∃ y, IsGreatest {z : ℤ ×ₗ ℤ | z < x} y :=
    fun x => ⟨_, isGreatest_pred_of_isLeast_pos LexInt.isLeast_pos x⟩
  rintro φ ⟨ax, hax⟩
  by_cases hb : ax.minFrameClass ≤ FrameClass.Base
  · exact Validity.validOn_of_valid (axiom_valid ax hb) lexIntStaticFrame
  · cases ax with
    | prior_UZ ψ =>
        intro M τ x h
        exact (static_untl_iff_disc (D := ℤ ×ₗ ℤ) hdisc Bool M τ.val τ.property ψ.neg ψ x).mpr
          ((static_someFuture_iff (D := ℤ ×ₗ ℤ) Bool M τ.val τ.property ψ x).mp h)
    | prior_SZ ψ =>
        intro M τ x h
        exact (static_snce_iff_disc (D := ℤ ×ₗ ℤ) hpred Bool M τ.val τ.property ψ.neg ψ x).mpr
          ((static_somePast_iff (D := ℤ ×ₗ ℤ) Bool M τ.val τ.property ψ x).mp h)
    | z1 ψ =>
        intro M τ x
        exact static_validates_z1 (D := ℤ ×ₗ ℤ) Bool M τ.val τ.property ψ x
    | _ => first
        | exact absurd (show FrameClass.Dense ≤ FrameClass.Discrete from hax) (by decide)
        | exact absurd (FrameClass.base_le FrameClass.Base) hb

/-! ## The semantic upper-bound engine -/

/--
**Every model of `AxiomSet .Discrete` validates `X⊤`.**

The semantic replay of `Theorems.DiscreteUnfolding.succIndicatorAt`'s three steps, and
deliberately independent of it — no proof theory is used, so the sandwich below does not inherit
a `Derivable`-level dependency.

1. `F⊤` holds at every point: a nontrivial ordered duration group has a positive element, so
   every time has a strictly later one.
2. `Axiom.prior_UZ ⊤` is a member of `AxiomSet .Discrete`, so `F⊤ → U(¬⊤, ⊤)` holds on `F`.
3. `U(¬⊤, ⊤)` and `U(⊥, ⊤) = X⊤` have the same truth condition, since `¬⊤` and `⊥` are both
   false everywhere. This is the step the `Derivable`-level route discharges with
   `Combinators.guardMono`.
-/
theorem validOn_nextTop_of_mem_mod_discrete {F : TaskFrame}
    (hF : F ∈ Semantics.Mod (AxiomSet FrameClass.Discrete)) :
    F.ValidOn (Formula.next Formula.top) := by
  intro M τ x
  obtain ⟨p, hp⟩ := TaskFrame.exists_pos_of_nontrivial (D := F.Duration.carrier)
  have hstep := hF _ ⟨Axiom.prior_UZ Formula.top, by decide⟩ M τ x
  have hF_top : TruthAt M τ.val x (Formula.someFuture Formula.top) := by
    rw [Truth.some_future_iff]
    exact ⟨x + p, lt_add_of_pos_right x hp, fun h => h⟩
  obtain ⟨s, hxs, _, hg⟩ := hstep hF_top
  exact ⟨s, hxs, fun h => h, fun r hr1 hr2 => hg r hr1 hr2 (fun h => h)⟩

/-! ## The Discrete sandwich -/

/-- `Sat .Discrete ⊆ Mod (AxiomSet .Discrete)`: soundness of the `.Discrete` axioms. -/
theorem sat_discrete_subset_mod_axiomSet :
    {F : TaskFrame | FrameClass.Sat FrameClass.Discrete F} ⊆
      Semantics.Mod (AxiomSet FrameClass.Discrete) :=
  fun F hF _ ⟨ax, hax⟩ => axiom_discrete_valid ax hax F hF

/--
**The lower half of the sandwich is strict**: `Sat .Discrete ⊊ Mod (AxiomSet .Discrete)`, with
`lexIntStaticFrame` the separating frame.

Equivalently: `Sat .Discrete` — the ℤ-time narrowing — is **not** Galois-closed. Contrast
`Semantics.galoisClosed_isDiscrete`, which shows that the paper's bare Discrete class *is*.
-/
theorem sat_discrete_ssubset_mod_axiomSet :
    {F : TaskFrame | FrameClass.Sat FrameClass.Discrete F} ⊂
      Semantics.Mod (AxiomSet FrameClass.Discrete) :=
  ⟨sat_discrete_subset_mod_axiomSet,
    fun hrev => lexIntStaticFrame_not_sat (hrev lexIntStaticFrame_mem_mod)⟩

/--
**The upper half of the sandwich**: `Mod (AxiomSet .Discrete) ⊆ {F | F.IsDiscrete}`.

The upper bound is the **paper's** Discrete class, not `Sat .Discrete`; the two are different,
and `sat_discrete_ssubset_mod_axiomSet` is the proof that they are.
-/
theorem mod_axiomSet_discrete_subset_isDiscrete :
    Semantics.Mod (AxiomSet FrameClass.Discrete) ⊆ {F : TaskFrame | F.IsDiscrete} :=
  fun _ hF => (validOn_nextTop_iff_isDiscrete _).mp (validOn_nextTop_of_mem_mod_discrete hF)

end FormalSystem.Metalogic.Independence
