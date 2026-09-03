/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.StaticFrame
import FormalSystem.Metalogic.Soundness
import FormalSystem.Semantics.Correspondence.Indicator
import Mathlib.NumberTheory.Real.Irrational
import Mathlib.Algebra.Order.Archimedean.Real.Basic

/-!
# Witness (a): the static frame over `ℚ`, and the Dedekind sandwich

`FrameClass.Sat FrameClass.Dedekind` is **not** Galois-closed. The witness is the static frame
over the rationals: it models every axiom instance permitted at `FrameClass.Dedekind`, yet its
duration group is not Dedekind-complete, so it is not in `Sat .Dedekind`.

`ratStaticFrame ∈ Mod (AxiomSet .Dedekind)` is obtained *through the constant-truth calculus* of
`Metalogic/Independence/StaticFrame.lean`, not axiom by axiom. Writing `b(φ)` for the constant
truth value of `φ`, the dense-carrier calculus gives `b(U(ψ, φ)) = b(φ) ∧ b(ψ)` and hence
`b(Gφ) = b(Fφ) = b(K⁺φ) = b(K⁻φ) = b(φ)`, and then:

* every axiom at `minFrameClass ≤ .Dense` is delivered wholesale by
  `axiom_dense_valid`, since `ℚ` *is* densely ordered — this covers the 37 Base axioms
  and both Dense axioms with no case analysis here;
* `prior_U_gap`'s antecedent `U(φ, ⊤) ∧ F(¬φ)` reduces to `b(φ) ∧ ¬b(φ)` and is vacuous;
  `prior_S_gap` dually;
* `sep`'s inner `U(¬φ, φ)` reduces to `b(φ) ∧ ¬b(φ) = ⊥`, so the second conjunct of its
  antecedent is `⊤` and the whole axiom collapses to `b(φ) → b(φ)`.

The upper bound `Mod (AxiomSet .Dedekind) ⊆ Sat .Dense` is semantic, not proof-theoretic:
`Axiom.dense_indicator` lies in `AxiomSet .Dedekind` (its `minFrameClass` is `.Dense ≤ .Dedekind`),
so `Semantics.validOn_neg_nextTop_iff` applies directly.

## Both sandwiches are over `AxiomSet`, and deliberately so

`Mod` of the *theorem* set is not attempted anywhere in this file. It would require a single-frame
`F.ValidOn φ → F.ValidOn φ.swapTemporal` closure lemma for the `temporal_duality` rule; no such
lemma exists and it is false in general, since a frame need not be closed under time reversal.
Since `AxiomSet fc ⊆ {φ | Derivable fc [] φ}`, the `AxiomSet` sandwich is the stronger statement
anyway. See `Semantics/Correspondence/Galois.lean`'s "Reified sets" section.

## Main results

* `rat_not_complete` — `ℚ` is not Dedekind-complete; written here because Mathlib carries no
  off-the-shelf statement of it in this form
* `ratStaticFrame` — the witness frame, and `ratStaticFrame_mem_mod` / `ratStaticFrame_not_sat`
* `sat_dedekind_ssubset_mod_axiomSet` and `mod_axiomSet_dedekind_subset_sat_dense` — the sandwich
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.ProofSystem

/-! ## `ℚ` is not Dedekind-complete -/

/--
**`ℚ` is not Dedekind-complete.**

Mathlib has no off-the-shelf statement in this shape, so it is written out. The witness set is
`{q : ℚ | (q : ℝ) < √2}`: it is nonempty (`0` is in it) and bounded above (by `2`), and any
rational least upper bound `x` would satisfy `(x : ℝ) = √2` — below `√2` it is beaten by a
rational supplied by `exists_rat_btwn`, above `√2` it is not least for the same reason — which
`irrational_sqrt_two` refutes.
-/
theorem rat_not_complete :
    ¬ (∀ s : Set ℚ, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) := by
  intro h
  have hpos : (0 : ℝ) < Real.sqrt 2 := Real.sqrt_pos.mpr (by norm_num)
  have hlt2 : Real.sqrt 2 < 2 := by
    nlinarith [Real.sq_sqrt (show (0 : ℝ) ≤ 2 by norm_num), Real.sqrt_nonneg (2 : ℝ)]
  set S : Set ℚ := {q : ℚ | (q : ℝ) < Real.sqrt 2} with hSdef
  have hne : S.Nonempty := ⟨0, by simp [hSdef]⟩
  have hbdd : BddAbove S := by
    refine ⟨2, fun q hq => ?_⟩
    have hq2 : (q : ℝ) < 2 := lt_trans hq hlt2
    exact_mod_cast hq2.le
  obtain ⟨x, hx⟩ := h S hne hbdd
  refine irrational_sqrt_two ⟨x, ?_⟩
  rcases lt_trichotomy ((x : ℝ)) (Real.sqrt 2) with hlt | heq | hgt
  · obtain ⟨y, hy1, hy2⟩ := exists_rat_btwn hlt
    have hyS : y ∈ S := hy2
    have hyx : y ≤ x := hx.1 hyS
    exact absurd (show (x : ℝ) < (y : ℝ) from hy1) (not_lt.mpr (by exact_mod_cast hyx))
  · exact heq
  · obtain ⟨y, hy1, hy2⟩ := exists_rat_btwn hgt
    have hub : y ∈ upperBounds S := by
      intro q hq
      have : (q : ℝ) < (y : ℝ) := lt_trans hq hy1
      exact_mod_cast this.le
    have hxy : x ≤ y := hx.2 hub
    exact absurd (show (y : ℝ) < (x : ℝ) from hy2) (not_lt.mpr (by exact_mod_cast hxy))

/-! ## The witness frame -/

/--
The **static frame over `ℚ`**: two world states, and the identity task relation at every
duration. Its duration group `ℚ` is densely ordered but not Dedekind-complete, which is exactly
the gap the witness exploits.
-/
def ratStaticFrame : TaskFrame := (FrameOver.staticFrame Bool (D := ℚ)).toTaskFrame

/-- The witness frame is dense: `ℚ` is densely ordered. -/
theorem ratStaticFrame_isDense : ratStaticFrame.IsDense :=
  inferInstanceAs (DenselyOrdered ℚ)

/--
**The witness models every `.Dedekind` axiom instance.**

Dispatch: everything at `minFrameClass ≤ .Dense` is `axiom_dense_valid` applied at the
dense frame; the three Reynolds axioms are the calculus computations described in the module
docstring; the three `.Discrete` axioms are eliminated by `Discrete ≰ Dedekind`.
-/
theorem ratStaticFrame_mem_mod :
    ratStaticFrame ∈ Semantics.Mod (AxiomSet FrameClass.Dedekind) := by
  have andE : ∀ {P Q : Prop}, ((P → Q → False) → False) → P ∧ Q := by
    intro P Q hpq
    by_contra hn
    exact hpq fun hp hq => hn ⟨hp, hq⟩
  rintro φ ⟨ax, hax⟩
  by_cases hb : ax.minFrameClass ≤ FrameClass.Dense
  · exact axiom_dense_valid ax hb ratStaticFrame ratStaticFrame_isDense
  · cases ax with
    | prior_U_gap ψ =>
        intro M τ x hant
        obtain ⟨h1, h2⟩ := andE hant
        have hψ := ((static_untl_iff_dense (D := ℚ) Bool M τ.val τ.property
          ψ Formula.top x).mp h1).2
        exact absurd hψ ((static_someFuture_iff (D := ℚ) Bool M τ.val τ.property ψ.neg x).mp h2)
    | prior_S_gap ψ =>
        intro M τ x hant
        obtain ⟨h1, h2⟩ := andE hant
        have hψ := ((static_snce_iff_dense (D := ℚ) Bool M τ.val τ.property
          ψ Formula.top x).mp h1).2
        exact absurd hψ ((static_somePast_iff (D := ℚ) Bool M τ.val τ.property ψ.neg x).mp h2)
    | sep ψ =>
        intro M τ x hant
        obtain ⟨h1, _⟩ := andE hant
        have hψ := (static_kPlus_iff_dense (D := ℚ) Bool M τ.val τ.property ψ x).mp h1
        refine (static_kPlus_iff_dense (D := ℚ) Bool M τ.val τ.property _ x).mpr ?_
        intro hc
        exact hc ((static_kPlus_iff_dense (D := ℚ) Bool M τ.val τ.property ψ x).mpr hψ)
          ((static_kMinus_iff_dense (D := ℚ) Bool M τ.val τ.property ψ x).mpr hψ)
    | prior_UZ _ =>
        exact absurd (show FrameClass.Discrete ≤ FrameClass.Dedekind from hax) (by decide)
    | prior_SZ _ =>
        exact absurd (show FrameClass.Discrete ≤ FrameClass.Dedekind from hax) (by decide)
    | z1 _ =>
        exact absurd (show FrameClass.Discrete ≤ FrameClass.Dedekind from hax) (by decide)
    | _ => exact absurd (FrameClass.base_le FrameClass.Dense) hb

/--
**The witness is not in `Sat .Dedekind`.**

`Sat .Dedekind` is `TaskFrame.IsDedekind`, the conjunction of `IsDense` and `IsComplete`;
`rat_not_complete` kills the second conjunct.
-/
theorem ratStaticFrame_not_sat :
    ratStaticFrame ∉ {F : TaskFrame | FrameClass.Sat FrameClass.Dedekind F} :=
  fun h => rat_not_complete h.2

/-! ## The Dedekind sandwich -/

/-- `Sat .Dedekind ⊆ Mod (AxiomSet .Dedekind)`: soundness of the `.Dedekind` axioms. -/
theorem sat_dedekind_subset_mod_axiomSet :
    {F : TaskFrame | FrameClass.Sat FrameClass.Dedekind F} ⊆
      Semantics.Mod (AxiomSet FrameClass.Dedekind) :=
  fun F hF _ ⟨ax, hax⟩ => axiom_dedekind_valid ax hax F hF

/--
**The lower half of the sandwich is strict**: `Sat .Dedekind ⊊ Mod (AxiomSet .Dedekind)`, with
`ratStaticFrame` the separating frame.

Equivalently: `Sat .Dedekind` is not Galois-closed, since its `Mod (Th ·)` closure contains the
witness.
-/
theorem sat_dedekind_ssubset_mod_axiomSet :
    {F : TaskFrame | FrameClass.Sat FrameClass.Dedekind F} ⊂
      Semantics.Mod (AxiomSet FrameClass.Dedekind) :=
  ⟨sat_dedekind_subset_mod_axiomSet,
    fun hrev => ratStaticFrame_not_sat (hrev ratStaticFrame_mem_mod)⟩

/--
**The upper half of the sandwich**: `Mod (AxiomSet .Dedekind) ⊆ Sat .Dense`.

Semantic, not proof-theoretic: `Axiom.dense_indicator` is itself a member of
`AxiomSet .Dedekind` (its `minFrameClass` is `.Dense`, and `Dense ≤ Dedekind`), so every frame in
the model class validates `¬X⊤` and `Semantics.validOn_neg_nextTop_iff` converts that to density.
-/
theorem mod_axiomSet_dedekind_subset_sat_dense :
    Semantics.Mod (AxiomSet FrameClass.Dedekind) ⊆
      {F : TaskFrame | FrameClass.Sat FrameClass.Dense F} :=
  fun F hF => (validOn_neg_nextTop_iff F).mp
    (hF ⟨Axiom.dense_indicator, by decide⟩)

end FormalSystem.Metalogic.Independence
