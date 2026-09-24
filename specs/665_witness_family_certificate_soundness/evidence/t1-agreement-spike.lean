import FormalSystem.Semantics.ShiftSet
import FormalSystem.Semantics.Validity
import FormalSystem.Syntax.SubformulaClosure.Closure
import Mathlib.Data.Int.SuccPred
import Mathlib.Order.SuccPred.LinearLocallyFinite

open FormalSystem.Syntax FormalSystem.Semantics

namespace Probe665

/-- Stand-in for the decoded witness family. -/
structure Fam where
  k : ℕ
  L : Fin (k+1) → ℤ → Finset Formula
  bx : Formula → Bool

def Fam.std (W : Fam) : ShiftSet intOrder where
  Carrier := Fin (W.k + 1) × ℤ
  carrier_nonempty := ⟨(⟨0, Nat.succ_pos _⟩, 0)⟩
  sh := fun w d => (w.1, w.2 + d)
  sh_zero := by intro w; simp
  sh_add := by intro w a b; simp [add_assoc]
  sep := by
    intro w u h
    obtain ⟨y, hy, hu⟩ := h 1 (by norm_num)
    have h1 : (|(y : ℤ)| : ℤ) < 1 := hy
    have hy0 : y = 0 := Int.abs_lt_one_iff.mp h1
    subst hy0
    simpa using hu
  A := fun p w => Formula.atom p ∈ W.L w.1 w.2

theorem Fam.std_isZTime (W : Fam) : W.std.frame.IsZTime :=
  @TaskFrame.isZTime_of_instances W.std.frame
    (inferInstanceAs (SuccOrder ℤ)) (inferInstanceAs (PredOrder ℤ))
    (inferInstanceAs (IsSuccArchimedean ℤ)) (inferInstanceAs (IsPredArchimedean ℤ))

theorem Fam.std_sat_ztime (W : Fam) :
    FormalSystem.ProofSystem.FrameClass.ZTime.Sat W.std.frame :=
  ⟨inferInstance, W.std_isZTime⟩

/-- `sh` at a fixed duration is surjective on the carrier. -/
theorem Fam.sh_surj (W : Fam) (t : ℤ) (u : W.std.Carrier) :
    ∃ v : W.std.Carrier, W.std.sh v t = u :=
  ⟨(u.1, u.2 - t), by cases u; simp [Fam.std]⟩

theorem Fam.sh_fst (W : Fam) (w : W.std.Carrier) (t : ℤ) : (W.std.sh w t).1 = w.1 := rfl
theorem Fam.sh_snd (W : Fam) (w : W.std.Carrier) (t : ℤ) : (W.std.sh w t).2 = w.2 + t := rfl

/-- The label at a carrier point. -/
def Fam.lab (W : Fam) (w : W.std.Carrier) : Finset Formula := W.L w.1 w.2

theorem Fam.lab_sh (W : Fam) (w : W.std.Carrier) (t : ℤ) :
    W.lab (W.std.sh w t) = W.L w.1 (w.2 + t) := rfl

/-! ## The three certificate predicates -/

def LocalCoherentLab (φ : Formula) (W : Fam) : Prop :=
  ∀ (i : Fin (W.k+1)) (t : ℤ),
    (Formula.bot ∉ W.L i t) ∧
    (∀ a b : Formula, Formula.imp a b ∈ subformulaClosure φ →
        (Formula.imp a b ∈ W.L i t ↔ (a ∈ W.L i t → b ∈ W.L i t))) ∧
    (∀ χ : Formula, Formula.box χ ∈ subformulaClosure φ →
        (Formula.box χ ∈ W.L i t ↔ W.bx χ = true)) ∧
    (∀ g e : Formula, Formula.untl g e ∈ subformulaClosure φ →
        (Formula.untl g e ∈ W.L i t ↔
          (e ∈ W.L i (t+1) ∨ (g ∈ W.L i (t+1) ∧ Formula.untl g e ∈ W.L i (t+1))))) ∧
    (∀ g e : Formula, Formula.snce g e ∈ subformulaClosure φ →
        (Formula.snce g e ∈ W.L i t ↔
          (e ∈ W.L i (t-1) ∨ (g ∈ W.L i (t-1) ∧ Formula.snce g e ∈ W.L i (t-1)))))

def FulfillingLab (W : Fam) : Prop :=
  (∀ (i : Fin (W.k+1)) (t : ℤ) (g e : Formula), Formula.untl g e ∈ W.L i t →
      ∃ s : ℤ, t < s ∧ e ∈ W.L i s ∧ ∀ r : ℤ, t < r → r < s → g ∈ W.L i r) ∧
  (∀ (i : Fin (W.k+1)) (t : ℤ) (g e : Formula), Formula.snce g e ∈ W.L i t →
      ∃ s : ℤ, s < t ∧ e ∈ W.L i s ∧ ∀ r : ℤ, s < r → r < t → g ∈ W.L i r)

def BoxFaithful (φ : Formula) (W : Fam) : Prop :=
  ∀ χ : Formula, Formula.box χ ∈ subformulaClosure φ →
    (W.bx χ = true ↔ ∀ (i : Fin (W.k+1)) (t : ℤ), χ ∈ W.L i t)

/-! ## The inner distance inductions -/

theorem untl_mem_of_witness (W : Fam) {φ : Formula} (hloc : LocalCoherentLab φ W)
    {g e : Formula} (hge : Formula.untl g e ∈ subformulaClosure φ)
    (i : Fin (W.k+1))
    (hg : ∀ u : ℤ, ShiftSet.ShiftTruth W.std (i, u) 0 g ↔ g ∈ W.L i u)
    (he : ∀ u : ℤ, ShiftSet.ShiftTruth W.std (i, u) 0 e ↔ e ∈ W.L i u) :
    ∀ (d : ℕ) (t s : ℤ), s - t = (d : ℤ) → t < s →
      e ∈ W.L i s → (∀ r : ℤ, t < r → r < s → g ∈ W.L i r) →
      Formula.untl g e ∈ W.L i t := by
  intro d
  induction d with
  | zero => intro t s hd hts _ _; omega
  | succ n ih =>
    intro t s hd hts hse hguard
    have hclause := (hloc i t).2.2.2.1 g e hge
    rcases eq_or_lt_of_le (show t + 1 ≤ s by omega) with heq | hlt
    · exact hclause.mpr (Or.inl (heq ▸ hse))
    · exact hclause.mpr (Or.inr ⟨hguard (t+1) (by omega) hlt,
        ih (t+1) s (by omega) hlt hse (fun r hr1 hr2 => hguard r (by omega) hr2)⟩)

theorem snce_mem_of_witness (W : Fam) {φ : Formula} (hloc : LocalCoherentLab φ W)
    {g e : Formula} (hge : Formula.snce g e ∈ subformulaClosure φ)
    (i : Fin (W.k+1)) :
    ∀ (d : ℕ) (t s : ℤ), t - s = (d : ℤ) → s < t →
      e ∈ W.L i s → (∀ r : ℤ, s < r → r < t → g ∈ W.L i r) →
      Formula.snce g e ∈ W.L i t := by
  intro d
  induction d with
  | zero => intro t s hd hst _ _; omega
  | succ n ih =>
    intro t s hd hst hse hguard
    have hclause := (hloc i t).2.2.2.2 g e hge
    rcases eq_or_lt_of_le (show s ≤ t - 1 by omega) with heq | hlt
    · exact hclause.mpr (Or.inl (heq ▸ hse))
    · exact hclause.mpr (Or.inr ⟨hguard (t-1) hlt (by omega),
        ih (t-1) s (by omega) hlt hse (fun r hr1 hr2 => hguard r hr1 (by omega))⟩)

/-! ## The agreement theorem, in shift-set form -/

theorem shiftTruth_iff_mem (W : Fam) {φ : Formula}
    (hloc : LocalCoherentLab φ W) (hful : FulfillingLab W) (hbox : BoxFaithful φ W) :
    ∀ ψ : Formula, ψ ∈ subformulaClosure φ →
      ∀ (w : W.std.Carrier) (t : ℤ),
        ShiftSet.ShiftTruth W.std w t ψ ↔ ψ ∈ W.L w.1 (w.2 + t) := by
  intro ψ
  induction ψ with
  | atom p => intro _ w t; exact Iff.rfl
  | bot =>
    intro _ w t
    exact ⟨fun h => absurd h (by exact id), fun h => absurd h (hloc w.1 (w.2+t)).1⟩
  | imp a b iha ihb =>
    intro hmem w t
    have ha := iha (closure_imp_left φ a b hmem) w t
    have hb := ihb (closure_imp_right φ a b hmem) w t
    rw [show ShiftSet.ShiftTruth W.std w t (Formula.imp a b)
        = (ShiftSet.ShiftTruth W.std w t a → ShiftSet.ShiftTruth W.std w t b) from rfl,
      (hloc w.1 (w.2+t)).2.1 a b hmem]
    exact ⟨fun h hl => hb.mp (h (ha.mpr hl)), fun h hs => hb.mpr (h (ha.mp hs))⟩
  | box χ ih =>
    intro hmem w t
    rw [(hloc w.1 (w.2+t)).2.2.1 χ hmem, hbox χ hmem]
    constructor
    · intro h i u
      obtain ⟨v, hv⟩ := W.sh_surj t (i, u)
      have := (ih (closure_box φ χ hmem) v t).mp (h v)
      have h1 : v.1 = i := congrArg Prod.fst hv
      have h2 : v.2 + t = u := congrArg Prod.snd hv
      rw [h1, h2] at this
      exact this
    · intro h v
      exact (ih (closure_box φ χ hmem) v t).mpr (h v.1 (v.2 + t))
  | untl g e ihg ihe =>
    intro hmem w t
    have hgc : g ∈ subformulaClosure φ := closure_untl_right φ e g hmem
    have hec : e ∈ subformulaClosure φ := closure_untl_left φ e g hmem
    constructor
    · rintro ⟨s, hts, hse, hguard⟩
      have hts' : @LT.lt ℤ _ t s := hts
      replace hguard : ∀ r : ℤ, @LT.lt ℤ _ t r → @LT.lt ℤ _ r s →
          ShiftSet.ShiftTruth W.std w r g := hguard
      refine untl_mem_of_witness W hloc hmem w.1
        (fun u => by simpa using ihg hgc (w.1, u) 0)
        (fun u => by simpa using ihe hec (w.1, u) 0)
        (s - t).toNat (w.2 + t) (w.2 + s) (by omega) (by omega)
        ((ihe hec w s).mp hse) ?_
      intro r hr1 hr2
      have := (ihg hgc w (r - w.2)).mp (hguard (r - w.2) (by omega) (by omega))
      simpa using this
    · intro hlab
      obtain ⟨s, hts, hes, hgs⟩ := hful.1 w.1 (w.2 + t) g e hlab
      refine ⟨s - w.2, show @LT.lt ℤ _ t (s - w.2) by omega,
        (ihe hec w (s - w.2)).mpr (by simpa using hes), ?_⟩
      intro r hr1 hr2
      have hr1' : @LT.lt ℤ _ t r := hr1
      have hr2' : @LT.lt ℤ _ r (s - w.2) := hr2
      exact (ihg hgc w r).mpr (hgs (w.2 + r) (by omega) (by omega))
  | snce g e ihg ihe =>
    intro hmem w t
    have hgc : g ∈ subformulaClosure φ := closure_snce_right φ e g hmem
    have hec : e ∈ subformulaClosure φ := closure_snce_left φ e g hmem
    constructor
    · rintro ⟨s, hst, hse, hguard⟩
      have hst' : @LT.lt ℤ _ s t := hst
      replace hguard : ∀ r : ℤ, @LT.lt ℤ _ s r → @LT.lt ℤ _ r t →
          ShiftSet.ShiftTruth W.std w r g := hguard
      refine snce_mem_of_witness W hloc hmem w.1
        (t - s).toNat (w.2 + t) (w.2 + s) (by omega) (by omega)
        ((ihe hec w s).mp hse) ?_
      intro r hr1 hr2
      have := (ihg hgc w (r - w.2)).mp (hguard (r - w.2) (by omega) (by omega))
      simpa using this
    · intro hlab
      obtain ⟨s, hst, hes, hgs⟩ := hful.2 w.1 (w.2 + t) g e hlab
      refine ⟨s - w.2, show @LT.lt ℤ _ (s - w.2) t by omega,
        (ihe hec w (s - w.2)).mpr (by simpa using hes), ?_⟩
      intro r hr1 hr2
      have hr1' : @LT.lt ℤ _ (s - w.2) r := hr1
      have hr2' : @LT.lt ℤ _ r t := hr2
      exact (ihg hgc w r).mpr (hgs (w.2 + r) (by omega) (by omega))

/-- **T1**, in `TruthAt` form, via `ShiftSet.forward_repr`. -/
theorem truth_iff_mem (W : Fam) {φ : Formula}
    (hloc : LocalCoherentLab φ W) (hful : FulfillingLab W) (hbox : BoxFaithful φ W)
    (i : Fin (W.k+1)) (t : ℤ) (ψ : Formula) (hψ : ψ ∈ subformulaClosure φ) :
    TruthAt W.std.model (W.std.hist ((i, 0) : W.std.Carrier)) t ψ ↔ ψ ∈ W.L i t :=
  (ShiftSet.forward_repr W.std ((i, 0) : W.std.Carrier) t ψ).trans
    (by simpa using shiftTruth_iff_mem W hloc hful hbox ψ hψ ((i, 0) : W.std.Carrier) t)

end Probe665

namespace Probe665

open FormalSystem.ProofSystem

/-- The certificate's target: a time at which every premise is labelled and no conclusion is. -/
def Target (W : Fam) (Γ Del : Context) (t : ℤ) : Prop :=
  (∀ γ ∈ Γ, γ ∈ W.L ⟨0, Nat.succ_pos _⟩ t) ∧ (∀ σ ∈ Del, σ ∉ W.L ⟨0, Nat.succ_pos _⟩ t)

/-- **T1'** — a witness family with a target refutes ℤ-time consequence. -/
theorem not_consequence_ztime (W : Fam) {φ : Formula} {Γ Del : Context} {t : ℤ}
    (hloc : LocalCoherentLab φ W) (hful : FulfillingLab W) (hbox : BoxFaithful φ W)
    (hΓ : ∀ γ ∈ Γ, γ ∈ subformulaClosure φ) (hD : ∀ σ ∈ Del, σ ∈ subformulaClosure φ)
    (htgt : Target W Γ Del t) {σ : Formula} (hσ : σ ∈ Del) :
    ¬ SemanticConsequenceIn FrameClass.ZTime Γ σ := by
  intro hcons
  have hpre : ∀ ψ ∈ Γ, TruthAt W.std.model
      (W.std.hist ((⟨0, Nat.succ_pos _⟩, 0) : W.std.Carrier)) t ψ := by
    intro ψ hψ
    exact (truth_iff_mem W hloc hful hbox _ t ψ (hΓ ψ hψ)).mpr (htgt.1 ψ hψ)
  have := hcons W.std.frame W.std_sat_ztime W.std.model _ t hpre
  exact htgt.2 σ hσ ((truth_iff_mem W hloc hful hbox _ t σ (hD σ hσ)).mp this)

/-- The same at the unconstrained class, via `FrameClass.Sat.anti`. -/
theorem not_consequence_base (W : Fam) {φ : Formula} {Γ Del : Context} {t : ℤ}
    (hloc : LocalCoherentLab φ W) (hful : FulfillingLab W) (hbox : BoxFaithful φ W)
    (hΓ : ∀ γ ∈ Γ, γ ∈ subformulaClosure φ) (hD : ∀ σ ∈ Del, σ ∈ subformulaClosure φ)
    (htgt : Target W Γ Del t) {σ : Formula} (hσ : σ ∈ Del) :
    ¬ SemanticConsequenceIn FrameClass.Base Γ σ := by
  intro hcons
  refine not_consequence_ztime W hloc hful hbox hΓ hD htgt hσ ?_
  intro F hF M τ u hall
  exact hcons F (FrameClass.Sat.anti (by decide) hF) M τ u hall

/-- The joint form ModelChecker reports. -/
theorem joint_countermodel (W : Fam) {φ : Formula} {Γ Del : Context} {t : ℤ}
    (hloc : LocalCoherentLab φ W) (hful : FulfillingLab W) (hbox : BoxFaithful φ W)
    (hΓ : ∀ γ ∈ Γ, γ ∈ subformulaClosure φ) (hD : ∀ σ ∈ Del, σ ∈ subformulaClosure φ)
    (htgt : Target W Γ Del t) :
    ∃ (F : TaskFrame) (_ : FrameClass.ZTime.Sat F) (M : TaskModel F)
      (τ : WorldHistory F) (u : F.Duration),
      (∀ γ ∈ Γ, TruthAt M τ u γ) ∧ (∀ σ ∈ Del, ¬ TruthAt M τ u σ) :=
  ⟨W.std.frame, W.std_sat_ztime, W.std.model,
    W.std.hist ((⟨0, Nat.succ_pos _⟩, 0) : W.std.Carrier), t,
    fun γ hγ => (truth_iff_mem W hloc hful hbox _ t γ (hΓ γ hγ)).mpr (htgt.1 γ hγ),
    fun σ hσ h => htgt.2 σ hσ ((truth_iff_mem W hloc hful hbox _ t σ (hD σ hσ)).mp h)⟩

#print axioms truth_iff_mem
#print axioms not_consequence_ztime
#print axioms joint_countermodel

end Probe665
