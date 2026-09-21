/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.ConvexConsequence.Separations

/-!
# AxiomSurvival - Which Base-Class Axioms of TM Survive C3

One theorem per row: each base-class axiom of TM is either C3-valid on every task frame
(`c3_*`) or refuted under C3 on the integer-time frame `NF` (`refute_C3_*`). The frame-class
rows are in `FrameClassSurvival.lean`, the past mirrors in `Mirrors.lean`, and the table as a
single theorem in `SurvivalTable.lean`.

## The pattern

C3 is TM's S5 modal layer over a bounded-interval tense logic. **Every failure below is an
existence assertion about the temporal order**, and boundedness of the index's domain is
exactly what makes an existence assertion fail:

- `serial_future`, `serial_past` — **fail**: they assert a later, respectively an earlier, time,
  and are refuted at an endpoint.
- `discrete_symm_fwd`, `discrete_symm_bwd` — **fail**: a gap ahead at the left endpoint has no
  gap behind it, and dually.
- `discrete_propagate_fwd` — **fails**: `G` reaches the right endpoint, where no successor
  exists.
- `discrete_box_necessity` — **fails**: its consequent boxes a `U`-formula, which is
  unsatisfiable by `c3_box_untl_unsat`.
- `discrete_propagate_bwd` — **survives**: a gap ahead is translated *backward*, into the
  domain, by convexity.
- The propositional and S5 rows — **survive**: C3 changes the range of `□`, not its character.
- The Burgess–Xu tense rows — **survive**: every witness and guard point they need lies in the
  domain already.
- `modal_future` — **survives**: C3 is time-uniform, by `c3_box_time_uniform`.

`discrete_propagate_fwd` and `discrete_propagate_bwd` are not mirror images under C3, and the
asymmetry is the point: a forward gap at `x` propagates to earlier domain times, where the
translated gap still lies inside the convex domain, but not to later ones, where it may fall off
the right end.

The two failing past rows, `serial_past` and `discrete_symm_bwd`, are not constructors of
`Axiom`: TM derives them by time reflection. They are stated against the formulas
`DerivedAxioms.serialPast` and `DerivedAxioms.discreteSymmBwd` derive.

## Main Results

- Propositional: `c3_prop_k`, `c3_prop_s`, `c3_ex_falso`, `c3_peirce`
- S5: `c3_modal_t`, `c3_modal_4`, `c3_modal_b`, `c3_modal_5_collapse`, `c3_modal_k_dist`
- Tense: `c3_left_mono_until_G`, `c3_right_mono_until`, `c3_connect_future`,
  `c3_enrichment_until`, `c3_self_accum_until`, `c3_absorb_until`, `c3_linear_until`,
  `c3_until_F`, `c3_temp_linearity`, `c3_F_until_equiv`
- Interaction and uniformity: `c3_modal_future`, `c3_discrete_propagate_bwd`
- The six failures: `refute_C3_serial_future`, `refute_C3_serial_past`,
  `refute_C3_discrete_symm_fwd`, `refute_C3_discrete_symm_bwd`,
  `refute_C3_discrete_propagate_fwd`, `refute_C3_discrete_box_necessity`

## References

* `FormalSystem/ProofSystem/Axioms.lean` — the `Axiom` constructors each row is stated against
* `FormalSystem/ProofSystem/DerivedAxioms.lean` — `serialPast`, `discreteSymmBwd`
* `FormalSystem/Semantics/ConvexTruth.lean` — `TruthAtConvex`, the clause lemmas, the germ
  theorems and `c3_box_time_uniform`

## Tags

convex-history · consequence-relation · axiom-survival · seriality · discreteness
-/

namespace FormalSystem.Metalogic.ConvexConsequence

open FormalSystem.Syntax FormalSystem.Semantics

variable {F : TaskFrame}

/-- The forward-gap formula `U(⊥, ⊤)`: some later time with nothing strictly between. It is the
antecedent of TM's four discreteness axioms, spelled out in full by the `Axiom` constructors;
this abbreviation unfolds to that spelling. -/
abbrev gapFwd : Formula := Formula.untl Formula.bot (Formula.bot.imp Formula.bot)

/-- The backward-gap formula `S(⊥, ⊤)`, the past dual of `gapFwd`. -/
abbrev gapBwd : Formula := Formula.snce Formula.bot (Formula.bot.imp Formula.bot)

/-! ## Propositional rows -/

/-- `prop_k` survives C3: the `imp` clause is the material conditional at a fixed index. -/
theorem c3_prop_k (φ ψ χ : Formula) :
    ValidC3 F ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) :=
  fun _M _τ _hτ _x _hx h1 h2 h3 => h1 h3 (h2 h3)

/-- `prop_s` survives C3. -/
theorem c3_prop_s (φ ψ : Formula) : ValidC3 F (φ.imp (ψ.imp φ)) :=
  fun _M _τ _hτ _x _hx h _ => h

/-- `ex_falso` survives C3: `⊥` is false at every index. -/
theorem c3_ex_falso (φ : Formula) : ValidC3 F (Formula.bot.imp φ) :=
  fun _M _τ _hτ _x _hx h => h.elim

/-- `peirce` survives C3. Classical. -/
theorem c3_peirce (φ ψ : Formula) : ValidC3 F (((φ.imp ψ).imp φ).imp φ) := by
  intro M τ _hτ x _hx h
  by_contra hφ
  exact hφ (h fun h' => absurd h' hφ)

/-! ## S5 rows

Each threads the convexity hypothesis of the box clause. The index itself is in the box's range
because a C3 index is convex with the evaluation time in its domain. -/

/-- `modal_t` survives C3: `□φ → φ`. -/
theorem c3_modal_t (φ : Formula) : ValidC3 F ((Formula.box φ).imp φ) :=
  fun _M τ hτ _x hx h => h τ hτ hx

/-- `□φ → □□φ` survives C3: the box is index-independent (`truthC3_box_indep`). TM derives this
formula rather than taking it as an axiom. -/
theorem c3_modal_4 (φ : Formula) :
    ValidC3 F ((Formula.box φ).imp (Formula.box (Formula.box φ))) :=
  fun _M _τ _hτ _x _hx h _σ _ _ ρ hρc hρ => h ρ hρc hρ

/-- `φ → □◇φ` survives C3. TM derives this formula rather than taking it as an axiom. -/
theorem c3_modal_b (φ : Formula) : ValidC3 F (φ.imp (Formula.box φ.diamond)) :=
  fun _M τ hτ _x hx hφ _σ _ _ hbox => hbox τ hτ hx hφ

/-- `modal_5_collapse` survives C3: `◇□φ → □φ`. Classical. -/
theorem c3_modal_5_collapse (φ : Formula) : ValidC3 F (φ.box.diamond.imp φ.box) := by
  intro _M _τ _hτ _x _hx h σ hσc hσ
  by_contra hcon
  exact h fun ρ _ _ hbox => hcon (hbox σ hσc hσ)

/-- `modal_k_dist` survives C3: `□(φ → ψ) → (□φ → □ψ)`. -/
theorem c3_modal_k_dist (φ ψ : Formula) :
    ValidC3 F ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) :=
  fun _M _τ _hτ _x _hx himp hφ σ hσc hσ => himp σ hσc hσ (hφ σ hσc hσ)

/-! ## Ported tense rows -/

/-- `connect_future` survives C3: `φ → G(Pφ)`. The present is in the past of every later domain
time, because the C3 side condition puts `x` itself in the domain. -/
theorem c3_connect_future (φ : Formula) : ValidC3 F (φ.imp φ.somePast.allFuture) := by
  intro M τ _hτ x hx hφ
  refine (TruthAtConvex.allFuture_iff M τ x φ.somePast).mpr fun s _hs hxs => ?_
  exact (TruthAtConvex.somePast_iff M τ s φ).mpr ⟨x, hx, hxs, hφ⟩

/-- `until_F` survives C3: `(φ U ψ) → Fψ`. -/
theorem c3_until_F (φ ψ : Formula) :
    ValidC3 F ((Formula.untl φ ψ).imp (Formula.someFuture ψ)) := by
  intro M τ _hτ x _hx h
  obtain ⟨s, hs, hxs, hψ, -⟩ := h
  exact (TruthAtConvex.someFuture_iff M τ x ψ).mpr ⟨s, hs, hxs, hψ⟩

/-- `F_until_equiv` survives C3: `Fφ → U(⊤, φ)`. Definitional under C3, as under C1. -/
theorem c3_F_until_equiv (φ : Formula) :
    ValidC3 F ((Formula.someFuture φ).imp
      (Formula.untl (Formula.bot.imp Formula.bot) φ)) :=
  fun _M _τ _hτ _x _hx h => h

/-! ## The Burgess–Xu block

None of these seven rows consults convexity. Each needs only that the witnesses and guard points
it moves between are *already* in the index's domain, which C3's own `untl` / `snce` clauses
guarantee, and that the evaluation time is in the domain, which is C3's side condition. -/

/-- `left_mono_until_G` survives C3: `G(φ → χ) → ((φ U ψ) → (χ U ψ))`. The restricted `G`
reaches every guard point, because guard points are domain points by C3's own clause. -/
theorem c3_left_mono_until_G (φ χ ψ : Formula) :
    ValidC3 F ((φ.imp χ).allFuture.imp ((Formula.untl φ ψ).imp (Formula.untl χ ψ))) := by
  intro M τ _hτ x _hx hG h
  rw [TruthAtConvex.allFuture_iff] at hG
  obtain ⟨s, hs, hxs, hψ, hguard⟩ := h
  exact ⟨s, hs, hxs, hψ, fun r hr hxr hrs => hG r hr hxr (hguard r hr hxr hrs)⟩

/-- `right_mono_until` survives C3: `G(φ → ψ) → ((χ U φ) → (χ U ψ))`. The restricted `G`
reaches the witness, which is a domain point. -/
theorem c3_right_mono_until (φ ψ χ : Formula) :
    ValidC3 F ((φ.imp ψ).allFuture.imp ((Formula.untl χ φ).imp (Formula.untl χ ψ))) := by
  intro M τ _hτ x _hx hG h
  rw [TruthAtConvex.allFuture_iff] at hG
  obtain ⟨s, hs, hxs, hφ, hguard⟩ := h
  exact ⟨s, hs, hxs, hG s hs hxs hφ, hguard⟩

/-- `enrichment_until` survives C3: `p ∧ (φ U ψ) → φ U (ψ ∧ (φ S p))`. The since-witness is the
evaluation time itself, available because it is in the domain. -/
theorem c3_enrichment_until (φ ψ p : Formula) :
    ValidC3 F ((Formula.and p (Formula.untl φ ψ)).imp
      (Formula.untl φ (Formula.and ψ (Formula.snce φ p)))) := by
  intro M τ _hτ x hx h
  obtain ⟨hp, s, hs, hxs, hψ, hguard⟩ := (TruthAtConvex.and_iff M τ x _ _).mp h
  refine ⟨s, hs, hxs, (TruthAtConvex.and_iff M τ s _ _).mpr ⟨hψ, x, hx, hxs, hp, ?_⟩, hguard⟩
  exact fun r hr hxr hrs => hguard r hr hxr hrs

/-- `self_accum_until` survives C3: `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`. At each guard point the
original witness still lies ahead, in the domain. -/
theorem c3_self_accum_until (φ ψ : Formula) :
    ValidC3 F ((Formula.untl φ ψ).imp
      (Formula.untl (Formula.and φ (Formula.untl φ ψ)) ψ)) := by
  intro M τ _hτ x _hx h
  obtain ⟨s, hs, hxs, hψ, hguard⟩ := h
  refine ⟨s, hs, hxs, hψ, fun r hr hxr hrs => ?_⟩
  exact (TruthAtConvex.and_iff M τ r _ _).mpr ⟨hguard r hr hxr hrs, s, hs, hrs, hψ,
    fun r' hr' hrr' hr's => hguard r' hr' (lt_trans hxr hrr') hr's⟩

/-- `absorb_until` survives C3: `(φ U (φ ∧ (φ U ψ))) → (φ U ψ)`. The two guarded stretches
concatenate across the intermediate witness. -/
theorem c3_absorb_until (φ ψ : Formula) :
    ValidC3 F ((Formula.untl φ (Formula.and φ (Formula.untl φ ψ))).imp
      (Formula.untl φ ψ)) := by
  intro M τ _hτ x _hx h
  obtain ⟨s, _hs, hxs, hev, hguard⟩ := h
  obtain ⟨hφs, s', hs', hss', hψ, hguard'⟩ := (TruthAtConvex.and_iff M τ s _ _).mp hev
  refine ⟨s', hs', lt_trans hxs hss', hψ, fun r hr hxr hrs' => ?_⟩
  rcases lt_trichotomy r s with h | h | h
  · exact hguard r hr hxr h
  · exact h ▸ hφs
  · exact hguard' r hr h hrs'

/-- `linear_until` survives C3: trichotomy on the two witnesses, both of which are domain
points. -/
theorem c3_linear_until (φ ψ χ θ : Formula) :
    ValidC3 F ((Formula.and (Formula.untl φ ψ) (Formula.untl χ θ)).imp
      (Formula.or (Formula.untl (Formula.and φ χ) (Formula.and ψ θ))
        (Formula.or (Formula.untl (Formula.and φ χ) (Formula.and ψ χ))
          (Formula.untl (Formula.and φ χ) (Formula.and φ θ))))) := by
  intro M τ _hτ x _hx h
  obtain ⟨⟨s₁, hs₁, hxs₁, hψ, hg₁⟩, ⟨s₂, hs₂, hxs₂, hθ, hg₂⟩⟩ :=
    (TruthAtConvex.and_iff M τ x _ _).mp h
  -- `Formula.or a b` is `a.neg.imp b`: the goal is `¬A → ¬B → C`.
  intro hA hB
  rcases lt_trichotomy s₁ s₂ with hlt | heq | hgt
  · refine absurd ?_ hB
    exact ⟨s₁, hs₁, hxs₁, (TruthAtConvex.and_iff M τ s₁ _ _).mpr ⟨hψ, hg₂ s₁ hs₁ hxs₁ hlt⟩,
      fun r hr hxr hrs => (TruthAtConvex.and_iff M τ r _ _).mpr
        ⟨hg₁ r hr hxr hrs, hg₂ r hr hxr (lt_trans hrs hlt)⟩⟩
  · subst heq
    refine absurd ?_ hA
    exact ⟨s₁, hs₁, hxs₁, (TruthAtConvex.and_iff M τ s₁ _ _).mpr ⟨hψ, hθ⟩,
      fun r hr hxr hrs => (TruthAtConvex.and_iff M τ r _ _).mpr
        ⟨hg₁ r hr hxr hrs, hg₂ r hr hxr hrs⟩⟩
  · exact ⟨s₂, hs₂, hxs₂, (TruthAtConvex.and_iff M τ s₂ _ _).mpr ⟨hg₁ s₂ hs₂ hxs₂ hgt, hθ⟩,
      fun r hr hxr hrs => (TruthAtConvex.and_iff M τ r _ _).mpr
        ⟨hg₁ r hr hxr (lt_trans hrs hgt), hg₂ r hr hxr hrs⟩⟩

/-- `temp_linearity` survives C3: trichotomy on the two `F`-witnesses, both of which are domain
points. -/
theorem c3_temp_linearity (φ ψ : Formula) :
    ValidC3 F ((Formula.and (Formula.someFuture φ) (Formula.someFuture ψ)).imp
      (Formula.or (Formula.someFuture (Formula.and (Formula.someFuture φ) ψ))
        (Formula.or (Formula.someFuture (Formula.and φ ψ))
          (Formula.someFuture (Formula.and φ (Formula.someFuture ψ)))))) := by
  intro M τ _hτ x _hx h
  obtain ⟨h₁, h₂⟩ := (TruthAtConvex.and_iff M τ x _ _).mp h
  obtain ⟨s₁, hs₁, hxs₁, hφ⟩ := (TruthAtConvex.someFuture_iff M τ x φ).mp h₁
  obtain ⟨s₂, hs₂, hxs₂, hψ⟩ := (TruthAtConvex.someFuture_iff M τ x ψ).mp h₂
  -- `Formula.or a b` is `a.neg.imp b`: the goal is `¬A → ¬B → C`.
  intro hA hB
  rcases lt_trichotomy s₁ s₂ with hlt | heq | hgt
  · exact (TruthAtConvex.someFuture_iff M τ x _).mpr ⟨s₁, hs₁, hxs₁,
      (TruthAtConvex.and_iff M τ s₁ _ _).mpr
        ⟨hφ, (TruthAtConvex.someFuture_iff M τ s₁ ψ).mpr ⟨s₂, hs₂, hlt, hψ⟩⟩⟩
  · subst heq
    refine absurd ?_ hB
    exact (TruthAtConvex.someFuture_iff M τ x _).mpr ⟨s₁, hs₁, hxs₁,
      (TruthAtConvex.and_iff M τ s₁ _ _).mpr ⟨hφ, hψ⟩⟩
  · refine absurd ?_ hA
    exact (TruthAtConvex.someFuture_iff M τ x _).mpr ⟨s₂, hs₂, hxs₂,
      (TruthAtConvex.and_iff M τ s₂ _ _).mpr
        ⟨(TruthAtConvex.someFuture_iff M τ s₂ φ).mpr ⟨s₁, hs₁, hgt, hφ⟩, hψ⟩⟩

/-! ## Interaction and uniformity rows -/

/--
`modal_future` survives C3: `□φ → □(Gφ)`, TM's one modal/temporal interaction axiom, on an
arbitrary task frame.

The proof is `c3_box_time_uniform`: `□φ` at `x` gives `□φ` at every later domain time `s`, and
`□φ` at `s` gives `φ` at `(σ, s)` for the very `σ` under consideration, which is in the box's
range at `s`.

`c3_box_untl_unsat` does not apply to the consequent: `□Gφ` boxes `¬(⊤ U ¬φ)`, not a
`U`-formula, and `G` is vacuously *true* at germs, where `F` is false. The axiom survives
because the germ-degeneracy of the tense operators falls on the existential side.
-/
theorem c3_modal_future (φ : Formula) :
    ValidC3 F ((Formula.box φ).imp (Formula.box (Formula.allFuture φ))) := by
  intro M τ _hτ x _hx h σ hσc _hσ
  refine (TruthAtConvex.allFuture_iff M σ x φ).mpr fun s hs _hxs => ?_
  exact (c3_box_time_uniform M τ σ x s φ h) σ hσc hs

/--
`discrete_propagate_bwd` survives C3, on **every** frame: `U(⊥,⊤) → H(U(⊥,⊤))`.

A forward gap `(x, s)` at `x` is translated back to an earlier domain time `y`: the candidate
successor is `y + (s - x)`. It lies in the domain by convexity, because it is at most `x` —
were it later than `x`, the point `x + (x - y)` would sit strictly inside the gap. The
translated interval `(y, y + (s - x))` is empty because each of its points translates forward
into the original gap.
-/
theorem c3_discrete_propagate_bwd : ValidC3 F (gapFwd.imp (Formula.allPast gapFwd)) := by
  intro M τ hconv x hx h
  obtain ⟨s, hs, hxs, -, hgap⟩ := h
  rintro ⟨y, hy, hyx, hneg, -⟩
  apply hneg
  have hd : 0 < s - x := sub_pos.mpr hxs
  have hle : y + (s - x) ≤ x := by
    by_contra hc
    have hc' : x < y + (s - x) := lt_of_not_ge hc
    have h1 : x < x + (x - y) := lt_add_of_pos_right x (sub_pos.mpr hyx)
    have h2 : x + (x - y) < s := lt_sub_iff_add_lt'.mp (sub_lt_iff_lt_add'.mpr hc')
    exact hgap (x + (x - y)) (hconv x s hx hs _ h1.le h2.le) h1 h2
  have hyle : y ≤ y + (s - x) := le_add_of_nonneg_right hd.le
  refine ⟨y + (s - x), hconv y x hy hx _ hyle hle, lt_add_of_pos_right y hd, fun c => c, ?_⟩
  intro r _hr hyr hrs
  have h1 : x < x + (r - y) := lt_add_of_pos_right x (sub_pos.mpr hyr)
  have h2 : x + (r - y) < s := lt_sub_iff_add_lt'.mp (sub_lt_iff_lt_add'.mpr hrs)
  exact hgap (x + (r - y)) (hconv x s hx hs _ h1.le h2.le) h1 h2

/-! ## Endpoint behaviour on `bdd01` -/

/-- A forward gap exists at the left endpoint of `bdd01`: `1` is the immediate successor of `0`
in the domain. -/
theorem gapFwd_bdd01_zero (M : TaskModel NF) : TruthAtConvex M bdd01 0 gapFwd :=
  ⟨1, bdd01_one_mem, by decide, fun c => c, fun r _ h0r hr1 =>
    absurd (Int.lt_iff_add_one_le.mp h0r) (by simpa using hr1)⟩

/-- No forward gap exists at the right endpoint of `bdd01`: no later domain time exists at
all. -/
theorem not_gapFwd_bdd01_one (M : TaskModel NF) : ¬ TruthAtConvex M bdd01 1 gapFwd := by
  rintro ⟨s, ⟨-, hs1⟩, h1s, -, -⟩
  exact absurd (lt_of_lt_of_le h1s hs1) (lt_irrefl 1)

/-- A backward gap exists at the right endpoint of `bdd01`. -/
theorem gapBwd_bdd01_one (M : TaskModel NF) : TruthAtConvex M bdd01 1 gapBwd :=
  ⟨0, bdd01_zero_mem, by decide, fun c => c, fun r _ h0r hr1 =>
    absurd (Int.lt_iff_add_one_le.mp h0r) (by simpa using hr1)⟩

/-- No backward gap exists at the left endpoint of `bdd01`: no earlier domain time exists at
all. -/
theorem not_gapBwd_bdd01_zero (M : TaskModel NF) : ¬ TruthAtConvex M bdd01 0 gapBwd := by
  rintro ⟨s, ⟨hs0, -⟩, hs, -, -⟩
  exact absurd (lt_of_le_of_lt hs0 hs) (lt_irrefl 0)

/-! ## The six failures -/

/-- **`serial_future` fails under C3**, at its verbatim `Axiom` statement `F⊤`: refuted at the
right endpoint of `bdd`. -/
theorem refute_C3_serial_future :
    ¬ ValidC3 NF (Formula.someFuture (Formula.bot.imp Formula.bot)) :=
  refute_C3_someFuture_top

/-- **`serial_past` fails under C3**, at the formula `DerivedAxioms.serialPast` derives,
`⊤ → P⊤`: refuted at the left endpoint of `bdd`. -/
theorem refute_C3_serial_past :
    ¬ ValidC3 NF ((Formula.bot.imp Formula.bot).imp
      (Formula.somePast (Formula.bot.imp Formula.bot))) := by
  intro h
  obtain ⟨s, ⟨hs0, -⟩, hs, -, -⟩ :=
    h TaskModel.allTrue bdd bdd_isConvex 0 bdd_zero_mem (fun c => c)
  exact absurd (lt_of_le_of_lt hs0 hs) (lt_irrefl 0)

/-- **`discrete_symm_fwd` fails under C3**: `U(⊥,⊤) → S(⊥,⊤)` is refuted at the left endpoint,
where a forward gap exists and no backward one can. -/
theorem refute_C3_discrete_symm_fwd : ¬ ValidC3 NF (gapFwd.imp gapBwd) := fun h =>
  not_gapBwd_bdd01_zero TaskModel.allTrue
    (h TaskModel.allTrue bdd01 bdd01_isConvex 0 bdd01_zero_mem
      (gapFwd_bdd01_zero TaskModel.allTrue))

/-- **`discrete_symm_bwd` fails under C3**, at the formula `DerivedAxioms.discreteSymmBwd`
derives: refuted dually, at the right endpoint. -/
theorem refute_C3_discrete_symm_bwd : ¬ ValidC3 NF (gapBwd.imp gapFwd) := fun h =>
  not_gapFwd_bdd01_one TaskModel.allTrue
    (h TaskModel.allTrue bdd01 bdd01_isConvex 1 bdd01_one_mem
      (gapBwd_bdd01_one TaskModel.allTrue))

/-- **`discrete_propagate_fwd` fails under C3**: `U(⊥,⊤) → G(U(⊥,⊤))`. The gap at `0` does not
propagate to `1`, because `G` reaches the right endpoint, where no gap exists. -/
theorem refute_C3_discrete_propagate_fwd :
    ¬ ValidC3 NF (gapFwd.imp (Formula.allFuture gapFwd)) := by
  intro h
  have hG := h TaskModel.allTrue bdd01 bdd01_isConvex 0 bdd01_zero_mem
    (gapFwd_bdd01_zero TaskModel.allTrue)
  exact not_gapFwd_bdd01_one TaskModel.allTrue
    ((TruthAtConvex.allFuture_iff TaskModel.allTrue bdd01 0 gapFwd).mp hG 1 bdd01_one_mem
      (by decide))

/--
**`discrete_box_necessity` fails under C3**: `U(⊥,⊤) → □(U(⊥,⊤))`. Its consequent is a boxed
`U`-formula, hence C3-unsatisfiable by `c3_box_untl_unsat`, while its antecedent is satisfiable.

This is the germ theorem cashed out on a named TM axiom: any axiom whose consequent boxes a
binary tense formula goes the same way.
-/
theorem refute_C3_discrete_box_necessity :
    ¬ ValidC3 NF (gapFwd.imp (Formula.box gapFwd)) := fun h =>
  c3_box_untl_unsat TaskModel.allTrue bdd01 0 Formula.bot (Formula.bot.imp Formula.bot)
    (h TaskModel.allTrue bdd01 bdd01_isConvex 0 bdd01_zero_mem
      (gapFwd_bdd01_zero TaskModel.allTrue))

end FormalSystem.Metalogic.ConvexConsequence
