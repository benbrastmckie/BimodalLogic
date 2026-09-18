/-
Probe 01 (task 568, research) — the four open C3 verdicts closed, ported to the live tree.

NOT part of the library. Checked with `lean_run_code` against the live tree (no `lake build`).
Ports task 553's C3 recursion to the tree's current history layer: `PartialHistory F` with the
`IsConvex` predicate (the former `ConvexHistory` structure no longer exists), and C1 is now
`TaskFrame.ValidOn` over `WorldHistory F`.

Establishes
  * `c3_discrete_propagate_bwd` — NA SURVIVES C3 on EVERY frame (was CONDITIONAL).
  * `c3_z1`                     — Z1 SURVIVES C3 on every ZTime frame (was CONDITIONAL).
  * `c3_prior_U_gap`            — Prior-U SURVIVES C3 on every Complete frame (was UNRESOLVED).
  * `c3_sep`                    — Sep SURVIVES C3 on every RTime frame (was UNRESOLVED),
                                  by reusing `SoundnessLemmas.sep_order` verbatim.
  * `validC4_lastPoint` / `refute_C3_lastPoint` — C3 and C4 have DIFFERENT validities:
                                  `F⊤ → F G⊥` is C4-valid and not C3-valid.
  * `truthC3_timeShift_box`     — the box step of shift invariance with convexity threaded.
-/
import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.Validity
import FormalSystem.Semantics.FrameProperty
import FormalSystem.Metalogic.SoundnessLemmas.Separability
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Int.SuccPred

open FormalSystem.Syntax FormalSystem.Semantics

namespace Probe568
variable {F : TaskFrame}

def TruthAtConvex (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration) : Formula → Prop
  | Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => TruthAtConvex M τ t φ → TruthAtConvex M τ t ψ
  | Formula.box φ => ∀ σ : PartialHistory F, σ.IsConvex → σ.domain t → TruthAtConvex M σ t φ
  | Formula.untl ψ φ => ∃ s : F.Duration, τ.domain s ∧ t < s ∧ TruthAtConvex M τ s φ ∧
      ∀ r : F.Duration, τ.domain r → t < r → r < s → TruthAtConvex M τ r ψ
  | Formula.snce ψ φ => ∃ s : F.Duration, τ.domain s ∧ s < t ∧ TruthAtConvex M τ s φ ∧
      ∀ r : F.Duration, τ.domain r → s < r → r < t → TruthAtConvex M τ r ψ

def ValidC3 (F : TaskFrame) (φ : Formula) : Prop :=
  ∀ (M : TaskModel F) (τ : PartialHistory F), τ.IsConvex → ∀ x, τ.domain x → TruthAtConvex M τ x φ

def IsInterval (τ : PartialHistory F) : Prop :=
  ∃ a b : F.Duration, ∀ t, τ.domain t ↔ (a ≤ t ∧ t ≤ b)

def ValidC4 (F : TaskFrame) (φ : Formula) : Prop :=
  ∀ (M : TaskModel F) (τ : PartialHistory F), IsInterval τ →
    ∀ x, τ.domain x → TruthAtConvex M τ x φ

/-! ## Clause lemmas -/

theorem and_iff (M : TaskModel F) (τ : PartialHistory F) (t) (φ ψ : Formula) :
    TruthAtConvex M τ t (φ.and ψ) ↔ TruthAtConvex M τ t φ ∧ TruthAtConvex M τ t ψ := by
  show ((_ → (_ → False)) → False) ↔ _
  tauto

theorem someFuture_iff (M : TaskModel F) (τ : PartialHistory F) (x) (φ : Formula) :
    TruthAtConvex M τ x (Formula.someFuture φ) ↔
      ∃ s, τ.domain s ∧ x < s ∧ TruthAtConvex M τ s φ :=
  ⟨fun ⟨s, hs, hxs, hφ, _⟩ => ⟨s, hs, hxs, hφ⟩,
   fun ⟨s, hs, hxs, hφ⟩ => ⟨s, hs, hxs, hφ, fun _ _ _ _ h => h⟩⟩

theorem allFuture_iff (M : TaskModel F) (τ : PartialHistory F) (x) (φ : Formula) :
    TruthAtConvex M τ x (Formula.allFuture φ) ↔
      ∀ s, τ.domain s → x < s → TruthAtConvex M τ s φ := by
  constructor
  · intro h s hs hxs
    by_contra hcon
    exact h ((someFuture_iff M τ x φ.neg).mpr ⟨s, hs, hxs, hcon⟩)
  · intro h hcon
    obtain ⟨s, hs, hxs, hneg⟩ := (someFuture_iff M τ x φ.neg).mp hcon
    exact hneg (h s hs hxs)

theorem kPlus_iff (M : TaskModel F) (τ : PartialHistory F) (t) (φ : Formula) :
    TruthAtConvex M τ t φ.kPlus ↔
      ∀ s, τ.domain s → t < s → ∃ r, τ.domain r ∧ t < r ∧ r < s ∧ TruthAtConvex M τ r φ := by
  show (¬ ∃ s, τ.domain s ∧ t < s ∧ (False → False) ∧
      ∀ r, τ.domain r → t < r → r < s → (TruthAtConvex M τ r φ → False)) ↔ _
  constructor
  · intro h s hs hts
    by_contra hc
    exact h ⟨s, hs, hts, id, fun r hr h1 h2 hφ => hc ⟨r, hr, h1, h2, hφ⟩⟩
  · rintro h ⟨s, hs, hts, -, hno⟩
    obtain ⟨r, hr, h1, h2, hφ⟩ := h s hs hts
    exact hno r hr h1 h2 hφ

theorem kMinus_iff (M : TaskModel F) (τ : PartialHistory F) (t) (φ : Formula) :
    TruthAtConvex M τ t φ.kMinus ↔
      ∀ s, τ.domain s → s < t → ∃ r, τ.domain r ∧ s < r ∧ r < t ∧ TruthAtConvex M τ r φ := by
  show (¬ ∃ s, τ.domain s ∧ s < t ∧ (False → False) ∧
      ∀ r, τ.domain r → s < r → r < t → (TruthAtConvex M τ r φ → False)) ↔ _
  constructor
  · intro h s hs hts
    by_contra hc
    exact h ⟨s, hs, hts, id, fun r hr h1 h2 hφ => hc ⟨r, hr, h1, h2, hφ⟩⟩
  · rintro h ⟨s, hs, hts, -, hno⟩
    obtain ⟨r, hr, h1, h2, hφ⟩ := h s hs hts
    exact hno r hr h1 h2 hφ

/-! ## Gap 1: NA (`discrete_propagate_bwd`) survives on every frame -/

theorem c3_discrete_propagate_bwd :
    ValidC3 F ((Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.allPast (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)))) := by
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
  intro r hr hyr hrs
  have h1 : x < x + (r - y) := lt_add_of_pos_right x (sub_pos.mpr hyr)
  have h2 : x + (r - y) < s := lt_sub_iff_add_lt'.mp (sub_lt_iff_lt_add'.mpr hrs)
  exact hgap (x + (r - y)) (hconv x s hx hs _ h1.le h2.le) h1 h2

/-! ## Gap 2: Z1 survives on every ZTime frame -/

theorem c3_z1 (hZ : F.IsZTime) (φ : Formula) :
    ValidC3 F ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture)) := by
  obtain ⟨_, _, _, _⟩ := hZ
  intro M τ hconv x hx hstep hF
  rw [allFuture_iff] at hstep
  obtain ⟨s0, hs0d, hxs0, hG0⟩ := (someFuture_iff M τ x _).mp hF
  have hdom : ∀ u, x < u → u ≤ s0 → τ.domain u :=
    fun u hxu hus => hconv x s0 hx hs0d u hxu.le hus
  have back : ∀ t, x < Order.pred t → t ≤ s0 →
      TruthAtConvex M τ t φ.allFuture → TruthAtConvex M τ (Order.pred t) φ.allFuture := by
    intro t hxp hts hGt
    have hxt : x < t := lt_of_lt_of_le hxp (Order.pred_le t)
    have hφt : TruthAtConvex M τ t φ := hstep t (hdom t hxt hts) hxt hGt
    rw [allFuture_iff] at hGt ⊢
    intro u hud hpu
    rcases eq_or_lt_of_le (Order.le_of_pred_lt hpu) with h | h
    · exact h ▸ hφt
    · exact hGt u hud h
  have iter : ∀ n : ℕ, x < Order.pred^[n] s0 →
      TruthAtConvex M τ (Order.pred^[n] s0) φ.allFuture := by
    intro n
    induction n with
    | zero => intro _; exact hG0
    | succ n ih =>
      intro hx'
      rw [Function.iterate_succ_apply'] at hx' ⊢
      exact back _ hx' (Order.pred_iterate_le _ _)
        (ih (lt_of_lt_of_le hx' (Order.pred_le _)))
  rw [allFuture_iff]
  intro t htd hxt
  rcases le_or_gt t s0 with hts | hts
  · obtain ⟨n, hn⟩ := IsPredArchimedean.exists_pred_iterate_of_le hts
    have hG : TruthAtConvex M τ t φ.allFuture := hn ▸ iter n (hn ▸ hxt)
    exact hstep t htd hxt hG
  · exact (allFuture_iff M τ s0 φ).mp hG0 t htd hts

/-! ## Gap 3: Prior-U survives on every Complete frame (no density needed) -/

theorem c3_prior_U_gap (hc : F.IsComplete) (φ : Formula) :
    ValidC3 F ((Formula.and (Formula.untl φ Formula.top) φ.neg.someFuture).imp
      (Formula.untl φ (Formula.or φ.neg (Formula.kPlus φ.neg)))) := by
  intro M τ hconv t ht h_ant
  obtain ⟨⟨s0, hs0d, hts0, -, hp0⟩, ⟨v, hvd, htv, hnpv, -⟩⟩ := (and_iff M τ t _ _).mp h_ant
  let A : Set F.Duration := {u | t < u ∧ u ≤ v ∧
    ∀ r, t < r → r < u → TruthAtConvex M τ r φ}
  have hmem : min s0 v ∈ A := by
    refine ⟨lt_min hts0 htv, min_le_right _ _, fun r htr hr => ?_⟩
    have hrs0 : r < s0 := lt_of_lt_of_le hr (min_le_left _ _)
    exact hp0 r (hconv t s0 ht hs0d r htr.le hrs0.le) htr hrs0
  obtain ⟨s, hs⟩ := hc A ⟨_, hmem⟩ ⟨v, fun u hu => hu.2.1⟩
  have hts : t < s := lt_of_lt_of_le hmem.1 (hs.1 hmem)
  have hsv : s ≤ v := hs.2 fun u hu => hu.2.1
  have hsd : τ.domain s := hconv t v ht hvd s hts.le hsv
  have hguard : ∀ r, t < r → r < s → TruthAtConvex M τ r φ := by
    intro r htr hrs
    obtain ⟨u, huA, hru, -⟩ := hs.exists_between hrs
    exact huA.2.2 r htr hru
  refine ⟨s, hsd, hts, ?_, fun r _ htr hrs => hguard r htr hrs⟩
  intro hnn
  have hps : TruthAtConvex M τ s φ := Classical.byContradiction hnn
  rintro ⟨w, hwd, hsw, -, hw⟩
  have hsv' : s < v := by
    rcases lt_or_eq_of_le hsv with h | h
    · exact h
    · exact absurd (h ▸ hps) hnpv
  have hwA : min w v ∈ A := by
    refine ⟨lt_trans hts (lt_min hsw hsv'), min_le_right _ _, fun r htr hr => ?_⟩
    have hrw : r < w := lt_of_lt_of_le hr (min_le_left _ _)
    rcases lt_trichotomy r s with h | h | h
    · exact hguard r htr h
    · exact h ▸ hps
    · exact Classical.byContradiction
        (hw r (hconv s w hsd hwd r h.le hrw.le) h hrw)
  exact absurd (hs.1 hwA) (not_le_of_gt (lt_min hsw hsv'))

/-! ## Gap 4: Sep survives on every RTime frame -/

theorem c3_sep (hR : F.IsRTime) (φ : Formula) :
    ValidC3 F ((Formula.and (Formula.kPlus φ)
        (Formula.kPlus (Formula.and φ (Formula.untl φ.neg φ))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))) := by
  obtain ⟨hdense, h_lub⟩ := hR
  intro M τ hconv t ht h_ant
  obtain ⟨Q, hQc, hQd⟩ :=
    FormalSystem.Metalogic.SoundnessLemmas.exists_countable_order_dense h_lub
  obtain ⟨h1, h2⟩ := (and_iff M τ t _ _).mp h_ant
  rw [kPlus_iff] at h1
  have h2' : ∃ s₁, τ.domain s₁ ∧ t < s₁ ∧ ∀ r, τ.domain r → t < r → r < s₁ →
      ¬ (TruthAtConvex M τ r φ ∧ TruthAtConvex M τ r (Formula.untl φ.neg φ)) := by
    by_contra hc
    apply h2
    rw [kPlus_iff]
    intro s hs hts
    by_contra hc2
    exact hc ⟨s, hs, hts, fun r hr h1 h2 hr' =>
      hc2 ⟨r, hr, h1, h2, (and_iff M τ r _ _).mpr hr'⟩⟩
  obtain ⟨s₁, hs₁d, hts₁, hstart⟩ := h2'
  rw [kPlus_iff]
  intro s₂ hs₂d hts₂
  by_contra hno
  have hno' : ∀ r, τ.domain r → t < r → r < s₂ →
      ¬ (TruthAtConvex M τ r φ.kPlus ∧ TruthAtConvex M τ r φ.kMinus) :=
    fun r hr a b hab => hno ⟨r, hr, a, b, (and_iff M τ r _ _).mpr hab⟩
  let P : Set F.Duration := {u | ∃ _ : τ.domain u, TruthAtConvex M τ u φ}
  have hin : ∀ {u s}, τ.domain s → t < u → u ≤ s → τ.domain u :=
    fun {u s} hs htu hus => hconv t s ht hs u htu.le hus
  refine FormalSystem.Metalogic.SoundnessLemmas.sep_order h_lub Q hQc hQd P t s₁ s₂ hts₁ hts₂
    ?_ ?_ ?_
  · intro v htv
    obtain ⟨r, hr, h1', h2', hφ⟩ :=
      h1 (min v s₁) (hin hs₁d (lt_min htv hts₁) (min_le_right _ _)) (lt_min htv hts₁)
    exact ⟨r, h1', lt_of_lt_of_le h2' (min_le_left _ _), hr, hφ⟩
  · rintro u htu hus₁ ⟨hud, hφu⟩ ⟨v, huv, ⟨hvd, hφv⟩, hfree⟩
    exact hstart u hud htu hus₁ ⟨hφu, v, hvd, huv, hφv,
      fun r hr hur hrv hφr => hfree r hur hrv ⟨hr, hφr⟩⟩
  · intro u htu hus₂
    have hud : τ.domain u := hin hs₂d htu hus₂.le
    by_cases hK : TruthAtConvex M τ u φ.kPlus
    · have hKm : ¬ TruthAtConvex M τ u φ.kMinus := fun h => hno' u hud htu hus₂ ⟨hK, h⟩
      rw [kMinus_iff] at hKm
      push Not at hKm
      obtain ⟨v, hvd, hvu, hv⟩ := hKm
      exact Or.inr ⟨v, hvu, fun w hvw hwu ⟨hwd, hφw⟩ => hv w hwd hvw hwu hφw⟩
    · rw [kPlus_iff] at hK
      push Not at hK
      obtain ⟨v, hvd, huv, hv⟩ := hK
      exact Or.inl ⟨v, huv, fun w huw hwv ⟨hwd, hφw⟩ => hv w hwd huw hwv hφw⟩

/-! ## Shift invariance: the box step, with convexity threaded through `isConvex_timeShift` -/

theorem truthC3_timeShift_box (M : TaskModel F) (φ : Formula)
    (ih : ∀ (σ : PartialHistory F) (z Δ : F.Duration),
      TruthAtConvex M (σ.timeShift Δ) z φ ↔ TruthAtConvex M σ (z + Δ) φ)
    (σ : PartialHistory F) (z Δ : F.Duration) :
    TruthAtConvex M (σ.timeShift Δ) z φ.box ↔ TruthAtConvex M σ (z + Δ) φ.box := by
  constructor
  · intro h ρ hρc hρ
    exact (ih ρ z Δ).mp (h (ρ.timeShift Δ) (PartialHistory.isConvex_timeShift hρc Δ) hρ)
  · intro h ρ hρc hρ
    have hdom : (ρ.timeShift (-Δ)).domain (z + Δ) := by
      show ρ.domain (z + Δ + -Δ)
      simpa using hρ
    have hz := (ih ρ (z + Δ) (-Δ)).mp
      (h _ (PartialHistory.isConvex_timeShift hρc (-Δ)) hdom)
    simpa using hz

/-! ## C1 / C3 / C4 separations -/

abbrev NF : TaskFrame := FrameOver.natFrame (D := ℤ)

theorem valid_C1_someFuture_top : NF.ValidOn (Formula.someFuture Formula.top) :=
  fun _M _τ t => ⟨t + 1, lt_add_one t, fun h => h, fun _ _ _ h => h⟩

/-- `F⊤ → F G⊥`: a last point exists whenever a later point does. -/
def lastPoint : Formula :=
  (Formula.someFuture Formula.top).imp (Formula.someFuture (Formula.allFuture Formula.bot))

theorem validC4_lastPoint : ValidC4 F lastPoint := by
  rintro M τ ⟨a, b, hab⟩ x hx ⟨s, hs, hxs, -, -⟩
  have hsb := ((hab s).mp hs).2
  have hb : τ.domain b :=
    (hab b).mpr ⟨le_trans ((hab x).mp hx).1 (le_trans hxs.le hsb), le_refl b⟩
  refine ⟨b, hb, lt_of_lt_of_le hxs hsb, ?_, fun _ _ _ _ h => h⟩
  rintro ⟨u, hu, hbu, -, -⟩
  exact absurd ((hab u).mp hu).2 (not_le_of_gt hbu)

def totalNF : PartialHistory NF :=
  PartialHistory.ofTotal NF (fun _ => (0 : Nat))
    (fun _ _ => (FrameOver.natFrame_rel_iff _ _ _).mpr (Or.inr rfl))

theorem refute_C3_lastPoint : ¬ ValidC3 NF lastPoint := by
  intro h
  obtain ⟨s, -, -, hG, -⟩ := h TaskModel.allTrue totalNF
    (PartialHistory.IsTotal.isConvex (PartialHistory.ofTotal_isTotal _ _ _)) 0 trivial
    ⟨1, trivial, by decide, fun h => h, fun _ _ _ _ h => h⟩
  exact hG ⟨s + 1, trivial, lt_add_one s, fun h => h, fun _ _ _ _ h => h⟩

end Probe568
