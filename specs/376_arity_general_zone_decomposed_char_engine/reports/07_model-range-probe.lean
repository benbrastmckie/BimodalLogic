import Bimodal.Metalogic.WeakCanonical.PriorDefs
import Mathlib.Data.Real.Basic
import Mathlib.Data.Int.LeastGreatest

/-! # Task 376 — Model-range probe: what `semantic_prior_UZ/SZ` actually excludes

Reports 02 and 03 pin the non-vacuity of their seam refutations to `(ℚ,<)` (order-homogeneity /
render-symmetry); report 05 pins its variant to `(ℝ,<)`. All three read the seam's model binder at
`ExteriorGateAssembleK.lean:571`, `InteriorGateGeneralK.lean:1776`, `KampPrior.lean:1070` and
report it as a FREE `∀ M : OrderedMonadicStructure sig` with "no rigidity restriction"
(reports/03 reference table, row "`∀ M` range (no rigidity)").

That read stops one line short. `ExteriorGateAssembleK.lean:572` and `KampPrior.lean:1071`
immediately bind `(h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)`.

This probe establishes what those two binders cost, and it is a strictly negative result about the
refutations' instantiation legs — it makes NO claim that any seam is dischargeable.

## What is proved (all sorry-free)

1. `prior_UZ_forces_immediate_successor` — `semantic_prior_UZ` implies every non-maximal point has
   an IMMEDIATE SUCCESSOR. Instantiate the binder at the tautology `⊥ → ⊥`: its negation is false
   everywhere, so the "nothing in between" clause forces the open interval `(t,s)` to be EMPTY.
   The predicate/valuation plays no role — this holds for EVERY `atomMap`.
2. `prior_UZ_fails_of_dense` — hence no densely-ordered structure satisfies `semantic_prior_UZ`.
3. `rat_fails_prior_UZ` / `real_fails_prior_UZ` — `(ℚ,<)` and `(ℝ,<)` fail it, for EVERY `atomMap`.

## Consequence for reports 02/03/05

`(ℚ,<)` and `(ℝ,<)` are NOT in the seam's model range. Every refutation leg discharged by
exhibiting an automorphism of `(ℚ,<)` or `(ℝ,<)` is discharged by a structure the seam's own
hypotheses exclude. Note reports/03 itself flags this transport as its "single non-compiled leg".

This does NOT resurrect the `∀ w` seam: report 05's TWO-CO-CHARACTERISTIC-RENDERS route needs no
automorphism and fires inside the discrete class (see `two_renders_kill_forall_seam_schema`). It
bears only on the legs that need HOMOGENEITY — i.e. reports/03's existential-`w` refutation.
-/

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

namespace Task376ModelRange

/-! ## The valuation-free tautology -/

/-- `⊥ → ⊥`: true at every point of every structure, under every `atomMap`. -/
def taut : Formula := Formula.bot.imp Formula.bot

theorem taut_true {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (s : M.carrier) :
    temporal_truth M atomMap s taut := by
  simp only [taut, temporal_truth]
  exact id

theorem taut_neg_false {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (s : M.carrier) :
    ¬ temporal_truth M atomMap s taut.neg := by
  intro h
  simp only [Formula.neg, temporal_truth] at h
  exact h (taut_true M atomMap s)

/-! ## `semantic_prior_UZ` forces discreteness -/

/-- **`semantic_prior_UZ` implies every non-maximal point has an immediate successor.**

    The Prior-UZ binder ranges over ALL formulas `ψ`, so it may be instantiated at the tautology
    `taut`. The antecedent is then free (any point above `t` witnesses it); the consequent supplies
    `s > t` with `taut.neg` holding throughout `(t,s)` — but `taut.neg` holds NOWHERE. So `(t,s)`
    is empty: `s` is the immediate successor of `t`.

    No hypothesis on `atomMap` or on `M.interp` is used. -/
theorem prior_UZ_forces_immediate_successor {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap) (t : M.carrier) (hne : ∃ s : M.carrier, t < s) :
    ∃ s : M.carrier, t < s ∧ ∀ r : M.carrier, t < r → ¬ (r < s) := by
  obtain ⟨s0, hs0⟩ := hne
  obtain ⟨s, hts, _, hmid⟩ := h_UZ t taut ⟨s0, hs0, taut_true M atomMap s0⟩
  exact ⟨s, hts, fun r hr hrs => taut_neg_false M atomMap r (hmid r hr hrs)⟩

/-- **No densely-ordered structure satisfies `semantic_prior_UZ`.** -/
theorem prior_UZ_fails_of_dense {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (hdense : ∀ a b : M.carrier, a < b → ∃ c, a < c ∧ c < b)
    (t : M.carrier) (hne : ∃ s : M.carrier, t < s) :
    ¬ semantic_prior_UZ M atomMap := by
  intro h_UZ
  obtain ⟨s, hts, hgap⟩ := prior_UZ_forces_immediate_successor M atomMap h_UZ t hne
  obtain ⟨c, hc1, hc2⟩ := hdense t s hts
  exact hgap c hc1 hc2

/-! ## The concrete instantiations reports 02/03/05 rely on -/

/-- A one-predicate signature; the valuation is irrelevant to every result below. -/
def sigU : MonadicSignature := { preds := Unit }

/-- `(ℚ,<)` as an `OrderedMonadicStructure`, with an arbitrary (here empty) valuation.
    `@[reducible]` so that `Qstruct.carrier` unfolds to `ℚ` during instance synthesis. -/
@[reducible] def Qstruct : OrderedMonadicStructure sigU where
  carrier := ℚ
  interp := fun _ _ => False
  carrier_order := inferInstance

/-- `(ℝ,<)` as an `OrderedMonadicStructure`. -/
@[reducible] noncomputable def Rstruct : OrderedMonadicStructure sigU where
  carrier := ℝ
  interp := fun _ _ => False
  carrier_order := inferInstance

/-- **`(ℚ,<)` is NOT in the seam's model range** — for EVERY `atomMap`.
    This is the structure reports/02 and reports/03 use to discharge render-symmetry. -/
theorem rat_fails_prior_UZ (atomMap : Formula → sigU.preds) :
    ¬ semantic_prior_UZ Qstruct atomMap := by
  refine prior_UZ_fails_of_dense Qstruct atomMap ?_ (0 : ℚ) ⟨1, by norm_num⟩
  intro a b hab
  exact exists_between hab

/-- **`(ℝ,<)` is NOT in the seam's model range** — for EVERY `atomMap`.
    This is the structure report 05 uses ("the refutation fires over `(ℝ,<)`, which IS
    Dedekind complete"). Dedekind completeness is beside the point: `(ℝ,<)` is DENSE, and
    `semantic_prior_UZ` excludes every dense order. -/
theorem real_fails_prior_UZ (atomMap : Formula → sigU.preds) :
    ¬ semantic_prior_UZ Rstruct atomMap := by
  refine prior_UZ_fails_of_dense Rstruct atomMap ?_ (0 : ℝ) ⟨1, by norm_num⟩
  intro a b hab
  exact exists_between hab

/-! ## Why this does NOT resurrect the `∀ w` seam (report 05's route, schematised)

Reports/02-03's diagonal collision needs TWO iffs at distinct renders. The `∀ w` seam form hands
both over for free as soon as two distinct renders exist — no automorphism, hence no homogeneity,
hence no `(ℚ,<)`. The schema below is the shape of report 05's claim, stated abstractly over an
opaque render predicate and an opaque collision, to make explicit that the `∀`-form refutation
survives inside the discrete (`h_UZ`-satisfying) class.

This probe therefore CONFIRMS report 05's conclusion for the `∀ w` form while removing the
`(ℚ,<)`/`(ℝ,<)` legs from reports/02-03's existential-`w` refutation.
-/

/-- Schema: the `∀ w` seam dies from two distinct renders alone. Automorphisms play no role, so
    restricting to the discrete `h_UZ` class does not save it. -/
theorem two_renders_kill_forall_seam_schema
    {Carrier : Type} {Render : Carrier → Prop} {Iff_at : Carrier → Prop}
    (collision : ∀ w0 w' : Carrier, w0 ≠ w' → Iff_at w0 → Iff_at w' → False)
    (seam : ∀ w : Carrier, Render w → Iff_at w)
    (w0 w' : Carrier) (hne : w0 ≠ w') (h0 : Render w0) (h' : Render w') : False :=
  collision w0 w' hne (seam w0 h0) (seam w' h')

/-! ## (ℤ,<) SATISFIES `semantic_prior_UZ` — the Tier-1 question, decided

Report 04 proposes threading `h_UZ`/`h_SZ` into `InteriorGateGeneralK.lean:1776` ("Tier 1") to
remove the refutations' witnesses. Report 06 counters that `seamPair_joint_refutation_int`
(task 374) already refutes the seam pair in a concrete **(ℤ,<)** with no automorphism and zero
residual.

The two claims meet here. `(ℤ,<)` is discrete AND every subset of `{s | t < s}` has a least element
(that set is order-isomorphic to `ℕ`), so the first-occurrence demand is met for EVERY formula under
EVERY valuation — not just vacuously under a coarse interp.

**Therefore threading `h_UZ`/`h_SZ` anywhere does NOT invalidate an `(ℤ,<)` witness.** Tier 1 removes
the `(ℚ,<)`/`(ℝ,<)` witnesses only.
-/

/-- `(ℤ,<)` as an `OrderedMonadicStructure`, over an ARBITRARY valuation `interp`. -/
@[reducible] def Zstruct (interp : sigU.preds → ℤ → Prop) : OrderedMonadicStructure sigU where
  carrier := ℤ
  interp := interp
  carrier_order := inferInstance

/-- **(ℤ,<) satisfies `semantic_prior_UZ` — for EVERY valuation and EVERY `atomMap`.**

    Given any formula `ψ` true somewhere above `t`, the set `{s | t < s ∧ ψ}` is nonempty and
    bounded below by `t`, so `Int.exists_least_of_bdd` supplies a LEAST such `s`. Everything
    strictly between `t` and that least `s` fails `ψ`, which is exactly the Prior-UZ conclusion.

    Consequence: `(ℤ,<)` is squarely INSIDE the seam's model range. A refutation witnessed by
    `(ℤ,<)` survives every `h_UZ`/`h_SZ` threading. -/
theorem int_satisfies_prior_UZ (interp : sigU.preds → ℤ → Prop)
    (atomMap : Formula → sigU.preds) :
    semantic_prior_UZ (Zstruct interp) atomMap := by
  intro t ψ hex
  classical
  set P : ℤ → Prop := fun s => t < s ∧ temporal_truth (Zstruct interp) atomMap s ψ with hP
  have hbdd : ∃ b : ℤ, ∀ z : ℤ, P z → b ≤ z := ⟨t, fun z hz => le_of_lt hz.1⟩
  have hinh : ∃ z : ℤ, P z := by obtain ⟨s, hts, hψ⟩ := hex; exact ⟨s, hts, hψ⟩
  obtain ⟨lb, ⟨hlb_gt, hlb_ψ⟩, hleast⟩ := Int.exists_least_of_bdd hbdd hinh
  refine ⟨lb, hlb_gt, hlb_ψ, fun r htr hrlb => ?_⟩
  simp only [Formula.neg, temporal_truth]
  intro hψr
  exact absurd (hleast r ⟨htr, hψr⟩) (not_le.mpr hrlb)

/-- Mirror: `(ℤ,<)` satisfies `semantic_prior_SZ`, for every valuation and every `atomMap`. -/
theorem int_satisfies_prior_SZ (interp : sigU.preds → ℤ → Prop)
    (atomMap : Formula → sigU.preds) :
    semantic_prior_SZ (Zstruct interp) atomMap := by
  intro t ψ hex
  classical
  set P : ℤ → Prop := fun s => s < t ∧ temporal_truth (Zstruct interp) atomMap s ψ with hP
  have hbdd : ∃ b : ℤ, ∀ z : ℤ, P z → z ≤ b := ⟨t, fun z hz => le_of_lt hz.1⟩
  have hinh : ∃ z : ℤ, P z := by obtain ⟨s, hst, hψ⟩ := hex; exact ⟨s, hst, hψ⟩
  obtain ⟨ub, ⟨hub_lt, hub_ψ⟩, hgreatest⟩ := Int.exists_greatest_of_bdd hbdd hinh
  refine ⟨ub, hub_lt, hub_ψ, fun r hubr hrt => ?_⟩
  simp only [Formula.neg, temporal_truth]
  intro hψr
  exact absurd (hgreatest r ⟨hrt, hψr⟩) (not_le.mpr hubr)

end Task376ModelRange
