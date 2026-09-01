/-
VERIFIED PROTOTYPE for the ShiftSet ultraproduct + Łoś lemma.

Checked with `lean_run_code` against the live tree (Lean v4.33.0-rc1, Mathlib 79d0395a)
on 2026-08-31. Every declaration below elaborated sorry-free; `#print axioms` on `uSep`,
`uShiftSet`, `los` and `los_truthAt` all report exactly

    [propext, Classical.choice, Quot.sound]

This file is a research artifact, not a build target. It imports the probe in order to
reuse its carrier construction; the implementation should PROMOTE the probe's declarations
into `FormalSystem/Semantics/Ultraproduct/Carrier.lean` and drop this import.
-/

import BimodalTest.Semantics.DependentUltraproductProbe

set_option linter.unusedSectionVars false
open Filter FormalSystem.Semantics FormalSystem.Syntax BimodalTest.DependentUltraproductProbe
open FormalSystem.Semantics.ShiftSet (ShiftTruth)

variable {I : Type} {φ : Ultrafilter I} {T : I → TemporalOrder}

/-! ## New support lemmas (not in the probe) -/

/-- **The choice-function lemma.** An eventual existential over a dependent family yields a
global section that eventually witnesses it. This is the single place `Classical.choice`
enters the Łoś proof beyond the probe's own uses. -/
theorem exists_section {Ω : I → Type} [∀ i, Nonempty (Ω i)] {P : ∀ i, Ω i → Prop}
    (h : ∀ᶠ i in φ, ∃ v, P i v) : ∃ f : ∀ i, Ω i, ∀ᶠ i in φ, P i (f i) := by
  classical
  refine ⟨fun i => if hi : ∃ v, P i v then hi.choose else Classical.arbitrary _, ?_⟩
  exact h.mono (fun i hi => by simp only [dif_pos hi]; exact hi.choose_spec)

theorem mk_surjective {D : I → Type} [∀ i, AddCommGroup (D i)] (a : UD φ D) :
    ∃ f : ∀ i, D i, mk f = a := by
  induction a using QuotientAddGroup.induction_on with
  | H f => exact ⟨f, rfl⟩

section Order
variable {D : I → Type} [∀ i, AddCommGroup (D i)] [∀ i, LinearOrder (D i)]
  [∀ i, IsOrderedAddMonoid (D i)]

theorem mk_zero : mk (φ := φ) (0 : ∀ i, D i) = 0 := rfl

theorem mk_max (f g : ∀ i, D i) :
    max (mk (φ := φ) f) (mk g) = mk (fun i => max (f i) (g i)) := by
  rcases φ.em (fun i => f i ≤ g i) with h | h
  · rw [max_eq_right (mk_le_mk.mpr h)]
    exact (mk_eq_mk.mpr (h.mono (fun i hi => (max_eq_right hi).symm)))
  · have h' : ∀ᶠ i in φ, g i ≤ f i := h.mono (fun i hi => le_of_not_ge hi)
    rw [max_eq_left (mk_le_mk.mpr h')]
    exact (mk_eq_mk.mpr (h'.mono (fun i hi => (max_eq_left hi).symm)))

/-- Needed by `uSep`: the `sep` field mentions `|·|`. -/
theorem mk_abs (f : ∀ i, D i) : |mk (φ := φ) f| = mk (fun i => |f i|) := by
  simp only [abs_eq_max_neg]
  rw [show (-(mk (φ := φ) f)) = mk (fun i => -(f i)) from rfl, mk_max]
end Order

/-! ## The ultraproduct temporal order and shift set -/

variable (φ T) in
/-- The ultraproduct temporal order.

`@[reducible]` is LOAD-BEARING. Without it `(UT φ T).carrier` does not reduce to
`UD φ (fun i => ↑(T i))` at `rw` motive-typing transparency, and every `rw` inside `uSep`
fails with "Application type mismatch ... expected to have type (UT φ T).carrier".
Measured: a plain `noncomputable def` breaks `uSep`'s `rw [← mk_zero]` and `rw [mk_abs]`. -/
@[reducible] noncomputable def UT : TemporalOrder := TemporalOrder.of (UD φ (fun i => ↑(T i)))

/-- **The `sep` field, discharged on the ultraproduct.** Contrapositive + `exists_section`. -/
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

variable (φ) in
/-- **The ultraproduct shift set.** All seven fields discharged; no hypotheses. -/
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

/-! ## Łoś -/

/-- **Łoś's theorem for `ShiftTruth`.**

Note the statement shape: `χ` is generalized FIRST and `f`, `x` appear under a `∀` in the
conclusion. `induction χ with` then gives induction hypotheses quantified over all carrier
sections and all duration sections, which the `box` case (arbitrary `v`) and the `untl`/`snce`
cases (arbitrary time `s`, `r`) both require. Writing `(f) (x)` as ordinary binders and using
`generalizing f x` also works; this form was the one measured. -/
theorem los (S : ∀ i, ShiftSet (T i)) (χ : Formula) :
    ∀ (f : ∀ i, (S i).Carrier) (x : ∀ i, ↑(T i)),
      ShiftTruth (uShiftSet φ S) (omk f) (mk x) χ ↔
        ∀ᶠ i in φ, ShiftTruth (S i) (f i) (x i) χ := by
  haveI : ∀ i, Nonempty ((S i).Carrier) := fun i => (S i).carrier_nonempty
  induction χ with
  | atom p => intro f x; exact Iff.rfl
  | bot => intro f x; exact ⟨fun h => h.elim, fun h => by obtain ⟨_, hi⟩ := h.exists; exact hi⟩
  | imp ψ χ ihψ ihχ =>
    intro f x
    -- NB: `rw [show _ ↔ _ from Iff.rfl]` FAILS here (`uShiftSet` is semireducible, so
    -- `(uShiftSet φ S).Carrier` will not reduce during motive typing). `Iff.trans` works.
    exact (imp_congr (ihψ f x) (ihχ f x)).trans Ultrafilter.eventually_imp.symm
  | box ψ ih =>
    intro f x
    constructor
    · intro h
      by_contra hc
      have h2 : ∀ᶠ i in φ, ∃ v, ¬ ShiftTruth (S i) v (x i) ψ :=
        (Ultrafilter.eventually_not.mpr hc).mono (fun i hi => not_forall.mp hi)
      obtain ⟨g, hg⟩ := exists_section h2
      obtain ⟨j, hj1, hj2⟩ := (((ih g x).mp (h (omk g))).and hg).exists
      exact hj2 hj1
    · intro h v
      obtain ⟨g, rfl⟩ := omk_surjective v
      exact (ih g x).mpr (h.mono fun i hi => hi (g i))
  | untl ψ χ ihψ ihχ =>
    intro f x
    constructor
    · rintro ⟨s, hs, he, hg⟩
      obtain ⟨σ, rfl⟩ := mk_surjective s
      have h1 : ∀ᶠ i in φ, x i < σ i := mk_lt_mk.mp hs
      have h2 := (ihχ f σ).mp he
      have h3 : ∀ᶠ i in φ, ∀ r, x i < r → r < σ i → ShiftTruth (S i) (f i) r ψ := by
        by_contra hc
        have h4 : ∀ᶠ i in φ, ∃ r, x i < r ∧ r < σ i ∧ ¬ ShiftTruth (S i) (f i) r ψ :=
          (Ultrafilter.eventually_not.mpr hc).mono (fun i hi => by
            obtain ⟨r, hr⟩ := not_forall.mp hi; exact ⟨r, by tauto⟩)
        obtain ⟨ρ, hρ⟩ := exists_section h4
        have hx := (ihψ f ρ).mp (hg (mk ρ) (mk_lt_mk.mpr (hρ.mono fun i hi => hi.1))
          (mk_lt_mk.mpr (hρ.mono fun i hi => hi.2.1)))
        obtain ⟨j, hj1, hj2⟩ := (hx.and hρ).exists
        exact hj2.2.2 hj1
      exact ((h1.and (h2.and h3)).mono (fun i hi => ⟨σ i, hi.1, hi.2.1, hi.2.2⟩))
    · intro h
      obtain ⟨σ, hσ⟩ := exists_section h
      refine ⟨mk σ, mk_lt_mk.mpr (hσ.mono fun i hi => hi.1),
        (ihχ f σ).mpr (hσ.mono fun i hi => hi.2.1), ?_⟩
      intro r hr1 hr2
      obtain ⟨ρ, rfl⟩ := mk_surjective r
      exact (ihψ f ρ).mpr (((mk_lt_mk.mp hr1).and ((mk_lt_mk.mp hr2).and hσ)).mono
        (fun i hi => hi.2.2.2.2 (ρ i) hi.1 hi.2.1))
  | snce ψ χ ihψ ihχ =>
    intro f x
    constructor
    · rintro ⟨s, hs, he, hg⟩
      obtain ⟨σ, rfl⟩ := mk_surjective s
      have h1 : ∀ᶠ i in φ, σ i < x i := mk_lt_mk.mp hs
      have h2 := (ihχ f σ).mp he
      have h3 : ∀ᶠ i in φ, ∀ r, σ i < r → r < x i → ShiftTruth (S i) (f i) r ψ := by
        by_contra hc
        have h4 : ∀ᶠ i in φ, ∃ r, σ i < r ∧ r < x i ∧ ¬ ShiftTruth (S i) (f i) r ψ :=
          (Ultrafilter.eventually_not.mpr hc).mono (fun i hi => by
            obtain ⟨r, hr⟩ := not_forall.mp hi; exact ⟨r, by tauto⟩)
        obtain ⟨ρ, hρ⟩ := exists_section h4
        have hx := (ihψ f ρ).mp (hg (mk ρ) (mk_lt_mk.mpr (hρ.mono fun i hi => hi.1))
          (mk_lt_mk.mpr (hρ.mono fun i hi => hi.2.1)))
        obtain ⟨j, hj1, hj2⟩ := (hx.and hρ).exists
        exact hj2.2.2 hj1
      exact ((h1.and (h2.and h3)).mono (fun i hi => ⟨σ i, hi.1, hi.2.1, hi.2.2⟩))
    · intro h
      obtain ⟨σ, hσ⟩ := exists_section h
      refine ⟨mk σ, mk_lt_mk.mpr (hσ.mono fun i hi => hi.1),
        (ihχ f σ).mpr (hσ.mono fun i hi => hi.2.1), ?_⟩
      intro r hr1 hr2
      obtain ⟨ρ, rfl⟩ := mk_surjective r
      exact (ihψ f ρ).mpr (((mk_lt_mk.mp hr1).and ((mk_lt_mk.mp hr2).and hσ)).mono
        (fun i hi => hi.2.2.2.2 (ρ i) hi.1 hi.2.1))

/-- **Łoś's theorem for `TruthAt`** — `los` conjugated by `ShiftSet.forward_repr` on both sides.

This is the statement the task asked for. It is obtained WITHOUT any choice-function argument
over total world-histories: `forward_repr`'s own `box` case already reconciles `TruthAt`'s
quantifier over all total histories with `ShiftTruth`'s quantifier over the carrier, via
`hist_isTotal` and `total_eq_orbit`. -/
theorem los_truthAt (S : ∀ i, ShiftSet (T i)) (f : ∀ i, (S i).Carrier) (x : ∀ i, ↑(T i))
    (χ : Formula) :
    TruthAt (uShiftSet φ S).model ((uShiftSet φ S).hist (omk f)) (mk x) χ ↔
      ∀ᶠ i in φ, TruthAt (S i).model ((S i).hist (f i)) (x i) χ :=
  (ShiftSet.forward_repr _ _ _ _).trans ((los S χ f x).trans
    (eventually_congr (Eventually.of_forall fun i =>
      (ShiftSet.forward_repr (S i) (f i) (x i) χ).symm)))

#print axioms uSep
#print axioms uShiftSet
#print axioms los
#print axioms los_truthAt
