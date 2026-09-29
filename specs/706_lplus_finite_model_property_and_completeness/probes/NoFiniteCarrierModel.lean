/-
Probe 706: the finite-carrier finite model property FAILS for L⁺ over regular ℤ-frames.

The formula `θ := □(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)` ("every history meets `p`, and never twice") is
`⊡`-free — it is `ofFormula` of the `Formula`-side witness recorded in
`specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`.

- Positive half: `θ` holds on the ℤ-carrier shift set (`sh w d = w + d`, `p` true only at state
  `0`), so `¬ PlusValidZTime θ.neg`: `θ.neg` is a genuine ℤ-time non-validity of L⁺.
- Negative half: NO regular ℤ-frame with a `Finite` world-state carrier satisfies `θ` at any
  history and time. A history meets `p` at some `a`; left of `a` it is `p`-free (second
  conjunct, read at every time through `plusBox_const`-style shifting); pigeonhole on the
  finite carrier finds a repeated state left of `a`; the cycle between the repeats, pumped
  bi-infinitely, is a step path, hence a history (`mem_HF_iff_adjacent`), and it never meets
  `p`, contradicting the first conjunct.

Consequence (`not_finite_carrier_fmp`): a certificate whose soundness lands
`PlusWitnessFamily.PlusRefutes` by presenting a finite-carrier frame — in particular any
certificate presenting `FrameOver.ofStep` on `Fin n`, the shape of `PlusGraphCertificate` in
task 703's plan v2 — cannot certify `θ.neg`, so that certificate class is incomplete for
ℤ-time non-validity, already on the `⊡`-free fragment L.

Compile-check from the repository root with:
  lake env lean specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability

namespace Probe706

def pa : Atom := ⟨"p", none⟩
def p : PlusFormula := PlusFormula.atom pa
def Fp : PlusFormula := PlusFormula.untl PlusFormula.top p
def Pp : PlusFormula := PlusFormula.snce PlusFormula.top p
/-- `□(p ∨ Fp ∨ Pp)`: every history meets `p` at some time. -/
def A : PlusFormula := PlusFormula.box (p.or (Fp.or Pp))
/-- `□(p → ¬Pp)`: a `p`-time has no earlier `p`-time. -/
def C : PlusFormula := PlusFormula.box (p.imp Pp.neg)
/-- The witness. -/
def θ : PlusFormula := A.and C

/-- The `Formula`-side twin (`Probe476.ψ`). -/
def ψL : Formula :=
  (Formula.box ((Formula.atom pa).or ((Formula.untl Formula.top (Formula.atom pa)).or
      (Formula.snce Formula.top (Formula.atom pa))))).and
    (Formula.box ((Formula.atom pa).imp (Formula.snce Formula.top (Formula.atom pa)).neg))

/-- `θ` is `⊡`-free: it is the embedding of an L formula. -/
theorem θ_eq_ofFormula : θ = ofFormula ψL := by decide

/-! ### Positive half: `θ` is satisfiable over ℤ-time (infinite carrier). -/

abbrev S : ShiftSet intOrder where
  Carrier := ℤ
  carrier_nonempty := ⟨0⟩
  sh w d := w + d
  sh_zero w := by simp
  sh_add w a b := by simp [add_assoc]
  sep w u h := by
    obtain ⟨y, hy, rfl⟩ := h 1 (by decide)
    have hy' : |(y : ℤ)| < 1 := hy
    have : (y:ℤ) = 0 := Int.abs_lt_one_iff.mp hy'
    change w + y = w
    rw [this]; simp
  A _ w := w = 0

theorem shiftTruth_psiL (w t : ℤ) : S.ShiftTruth w t ψL := by
  simp only [ψL, Formula.and, Formula.or, Formula.neg, Formula.top, ShiftSet.ShiftTruth]
  intro h
  apply h
  · intro (v : ℤ) hv1 hv2
    change (v + t = 0 → False) at hv1
    rcases lt_trichotomy t (-v) with hlt | heq | hgt
    · exact (hv2 ⟨-v, hlt, show v + -v = 0 by omega, fun _ _ _ h => h⟩).elim
    · exact (hv1 (by omega)).elim
    · exact ⟨-v, hgt, show v + -v = 0 by omega, fun _ _ _ h => h⟩
  · rintro (v : ℤ) hp ⟨s, hs, hps, -⟩
    change v + t = 0 at hp
    change v + s = 0 at hps
    change s < t at hs
    omega

/-- `θ.neg` is a ℤ-time non-validity of L⁺. -/
theorem not_plusValidZTime_neg_θ : ¬ PlusValidZTime θ.neg := by
  intro hv
  have h := hv S.frame ⟨S.frame_isRegular, TaskFrame.isZTime_of_instances _⟩ S.model
    (S.hist (0:ℤ)) (0:ℤ)
  apply h
  rw [θ_eq_ofFormula]
  exact (plusTruthAt_ofFormula S.model ψL _ _).mpr
    ((S.forward_repr (0:ℤ) (0:ℤ) ψL).mpr (shiftTruth_psiL 0 0))

/-! ### Negative half: no finite-carrier regular ℤ-frame satisfies `θ` anywhere. -/

section Finite

variable {F : FrameOver intOrder} [F.IsRegular]

/-- A step path is a history. -/
def mk (f : ℤ → F.WorldState) (hf : ∀ n, F.step (f n) (f (n + 1))) :
    WorldHistory F.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath F f hf

omit [F.IsRegular] in
theorem steps (σ : WorldHistory F.toTaskFrame) (n : ℤ) :
    F.step (σ.path n) (σ.path (n + 1)) :=
  σ.isStepPath n

theorem no_finite_carrier_sat [Finite F.WorldState] (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    ¬ PlusTruthAt M τ t θ := by
  intro h
  have hA : PlusTruthAt M τ t A := by
    by_contra hA; exact h (fun a => absurd a hA)
  have hC : PlusTruthAt M τ t C := by
    by_contra hC; exact h (fun _ c => hC c)
  simp only [A, C, PlusFormula.or, PlusFormula.neg, Fp, Pp, PlusFormula.top, p,
    PlusTruthAt] at hA hC
  have someP : ∀ σ : WorldHistory F.toTaskFrame, ∃ a, M.valuation (σ.path a) pa := by
    intro σ
    by_contra hno
    have hno' : ∀ a, ¬ M.valuation (σ.state a) pa := fun a h => hno ⟨a, h⟩
    obtain ⟨s, -, hs, -⟩ := hA σ (hno' t) (fun ⟨s, _, hs, _⟩ => hno' s hs)
    exact hno' s hs
  have firstP : ∀ σ : WorldHistory F.toTaskFrame, ∀ a, M.valuation (σ.path a) pa →
      ∀ b < a, ¬ M.valuation (σ.path b) pa := by
    intro σ a ha b hb hbt
    let g : ℤ → F.WorldState := fun n => σ.path (n + (a - t))
    have hg : ∀ n, F.step (g n) (g (n + 1)) := by
      intro n
      have := steps σ (n + (a - t))
      simp only [g]; rwa [show n + 1 + (a - t) = n + (a - t) + 1 by ring]
    apply hC (mk g hg)
    · show M.valuation (σ.path (t + (a - t))) pa
      rwa [show t + (a - t) = a by ring]
    · refine ⟨b - (a - t), by omega, ?_, fun _ _ _ h => h⟩
      show M.valuation (σ.path (b - (a - t) + (a - t))) pa
      rwa [show b - (a - t) + (a - t) = b by ring]
  obtain ⟨a, ha⟩ := someP τ
  let f : ℕ → F.WorldState := fun i => τ.path (a - 1 - i)
  obtain ⟨i, j, hij, hfij⟩ := Finite.exists_ne_map_eq_of_infinite f
  obtain ⟨x, y, hxy, hya, hpxy⟩ : ∃ x y : ℤ, x < y ∧ y ≤ a - 1 ∧ τ.path x = τ.path y := by
    rcases lt_or_gt_of_ne hij with hlt | hgt
    · exact ⟨a - 1 - j, a - 1 - i, by omega, by omega, hfij.symm⟩
    · exact ⟨a - 1 - i, a - 1 - j, by omega, by omega, hfij⟩
  set L := y - x with hL
  have hLpos : 0 < L := by omega
  let h' : ℤ → F.WorldState := fun n => τ.path (x + n % L)
  have hstep : ∀ n, F.step (h' n) (h' (n + 1)) := by
    intro n
    have hr0 := Int.emod_nonneg n (ne_of_gt hLpos)
    have hrL := Int.emod_lt_of_pos n hLpos
    have hdecomp := Int.emod_add_mul_ediv n L
    have key : τ.path (x + (n + 1) % L) = τ.path (x + n % L + 1) := by
      have e : (n + 1) % L = (n % L + 1) % L := by
        conv_lhs => rw [← hdecomp]
        rw [show n % L + L * (n / L) + 1 = (n % L + 1) + L * (n / L) by ring,
          Int.add_mul_emod_self_left]
      rw [e]
      rcases lt_or_eq_of_le (show n % L + 1 ≤ L by omega) with hlt | heq
      · rw [Int.emod_eq_of_lt (by omega) hlt, add_assoc]
      · rw [heq, Int.emod_self, add_zero, hpxy]
        congr 1; omega
    simp only [h']
    rw [key]
    exact steps τ _
  obtain ⟨s, hs⟩ := someP (mk h' hstep)
  have hr0 := Int.emod_nonneg s (ne_of_gt hLpos)
  have hrL := Int.emod_lt_of_pos s hLpos
  exact firstP τ a ha (x + s % L) (by omega) hs

end Finite

/-- The `FrameOver.ofStep` instance — the frame a `PlusGraphCertificate` (task 703 plan v2,
Phase 13) presents, and the frame Phase 17's hypotheses range over. -/
theorem no_ofStep_sat {W : Type} [Finite W] [Nonempty W] (R : W → W → Prop)
    (fwd : ∀ w, ∃ u, R w u) (bwd : ∀ w, ∃ v, R v w)
    (M : TaskModel (FrameOver.ofStep R fwd bwd).toTaskFrame)
    (τ : WorldHistory (FrameOver.ofStep R fwd bwd).toTaskFrame) (t : ℤ) :
    ¬ PlusTruthAt M τ t θ :=
  haveI : Finite (FrameOver.ofStep R fwd bwd).WorldState := ‹Finite W›
  no_finite_carrier_sat (F := FrameOver.ofStep R fwd bwd) M τ t

/-- **The finite-carrier finite model property fails for L⁺ over ℤ-time.** There is a ℤ-time
non-validity (`θ.neg`, which is `⊡`-free) with no countermodel on any regular ℤ-frame whose
world-state carrier is finite. -/
theorem not_finite_carrier_fmp :
    ¬ ∀ φ : PlusFormula, ¬ PlusValidZTime φ →
      ∃ (F : FrameOver intOrder) (_ : F.IsRegular) (_ : Finite F.WorldState)
        (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ),
        ¬ PlusTruthAt M τ t φ := by
  intro fmp
  obtain ⟨F, hreg, hfin, M, τ, t, hτ⟩ := fmp θ.neg not_plusValidZTime_neg_θ
  exact hτ (fun hθ => no_finite_carrier_sat M τ t hθ)

/-! ### The single-operator (CTL-like) fragment fails the same way

`θ' := □(p ∨ ⊡Fp ∨ ⊡Pp) ∧ □(p → ⊡¬Pp)`: every `⊡` and every `□` governs a state formula or a
single temporal operator applied to state formulas, so `θ'` lies in the CTL-like fragment
(each stability modal governing one temporal operator). It is ℤ-satisfiable (on the shift set,
where `⊡` collapses because histories through a state are unique) and satisfiable on no
finite-carrier regular ℤ-frame, by the same pumping argument. So staging through the fragment
does not rescue a finite-carrier certificate shape either. -/

def A' : PlusFormula := PlusFormula.box (p.or ((PlusFormula.stab Fp).or (PlusFormula.stab Pp)))
def C' : PlusFormula := PlusFormula.box (p.imp (PlusFormula.stab Pp.neg))
def θ' : PlusFormula := A'.and C'

/-- On the shift set, two histories sharing a state at one time coincide. -/
theorem S_hist_unique (τ σ : WorldHistory S.frame) (t : ℤ) (h : τ.state t = σ.state t) :
    σ = τ := by
  have hτ := S.total_eq_orbit τ
  have hσ := S.total_eq_orbit σ
  have h1 : τ.state t = τ.state 0 + t :=
    congrArg (fun ρ : WorldHistory S.frame => ρ.state t) hτ
  have h2 : σ.state t = σ.state 0 + t :=
    congrArg (fun ρ : WorldHistory S.frame => ρ.state t) hσ
  have e : σ.state 0 = τ.state 0 := by
    have : (τ.state 0 : ℤ) + t = σ.state 0 + t := by rw [← h1, ← h2, h]
    exact (add_right_cancel this).symm
  rw [hσ, hτ, e]

/-- `⊡` collapses on the shift set. -/
theorem stab_iff_S (τ : WorldHistory S.frame) (t : ℤ) (φ : PlusFormula) :
    PlusTruthAt S.model τ t (.stab φ) ↔ PlusTruthAt S.model τ t φ :=
  ⟨fun h => h τ rfl, fun h σ hs => by rw [S_hist_unique τ σ t hs]; exact h⟩

theorem θ'_of_θ (τ : WorldHistory S.frame) (t : ℤ) (h : PlusTruthAt S.model τ t θ) :
    PlusTruthAt S.model τ t θ' := by
  have hA : PlusTruthAt S.model τ t A := by
    by_contra hA; exact h (fun a => absurd a hA)
  have hC : PlusTruthAt S.model τ t C := by
    by_contra hC; exact h (fun _ c => hC c)
  intro hnot
  apply hnot
  · intro σ hnp hnsF
    rw [stab_iff_S]
    apply hA σ hnp
    intro hF
    exact hnsF ((stab_iff_S σ t Fp).mpr hF)
  · intro σ hp
    rw [stab_iff_S]
    exact hC σ hp

/-- `θ'.neg` is a ℤ-time non-validity of L⁺, inside the CTL-like fragment. -/
theorem not_plusValidZTime_neg_θ' : ¬ PlusValidZTime θ'.neg := by
  intro hv
  have h := hv S.frame ⟨S.frame_isRegular, TaskFrame.isZTime_of_instances _⟩ S.model
    (S.hist (0:ℤ)) (0:ℤ)
  apply h
  apply θ'_of_θ
  rw [θ_eq_ofFormula]
  exact (plusTruthAt_ofFormula S.model ψL _ _).mpr
    ((S.forward_repr (0:ℤ) (0:ℤ) ψL).mpr (shiftTruth_psiL 0 0))

section Finite'

variable {F : FrameOver intOrder} [F.IsRegular]

theorem no_finite_carrier_sat' [Finite F.WorldState] (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    ¬ PlusTruthAt M τ t θ' := by
  intro h
  have hA : PlusTruthAt M τ t A' := by
    by_contra hA; exact h (fun a => absurd a hA)
  have hC : PlusTruthAt M τ t C' := by
    by_contra hC; exact h (fun _ c => hC c)
  simp only [A', C', PlusFormula.or, PlusFormula.neg, Fp, Pp, PlusFormula.top, p,
    PlusTruthAt] at hA hC
  have someP : ∀ σ : WorldHistory F.toTaskFrame, ∃ a, M.valuation (σ.path a) pa := by
    intro σ
    by_contra hno
    have hno' : ∀ a, ¬ M.valuation (σ.state a) pa := fun a h => hno ⟨a, h⟩
    obtain ⟨s, -, hs, -⟩ := hA σ (hno' t)
      (fun hF => by
        obtain ⟨s, -, hs, -⟩ := hF σ rfl
        exact hno' s hs) σ rfl
    exact hno' s hs
  have firstP : ∀ σ : WorldHistory F.toTaskFrame, ∀ a, M.valuation (σ.path a) pa →
      ∀ b < a, ¬ M.valuation (σ.path b) pa := by
    intro σ a ha b hb hbt
    let g : ℤ → F.WorldState := fun n => σ.path (n + (a - t))
    have hg : ∀ n, F.step (g n) (g (n + 1)) := by
      intro n
      have := steps σ (n + (a - t))
      simp only [g]; rwa [show n + 1 + (a - t) = n + (a - t) + 1 by ring]
    apply hC (mk g hg) ?_ (mk g hg) rfl
    · refine ⟨b - (a - t), by omega, ?_, fun _ _ _ h => h⟩
      show M.valuation (σ.path (b - (a - t) + (a - t))) pa
      rwa [show b - (a - t) + (a - t) = b by ring]
    · show M.valuation (σ.path (t + (a - t))) pa
      rwa [show t + (a - t) = a by ring]
  obtain ⟨a, ha⟩ := someP τ
  let f : ℕ → F.WorldState := fun i => τ.path (a - 1 - i)
  obtain ⟨i, j, hij, hfij⟩ := Finite.exists_ne_map_eq_of_infinite f
  obtain ⟨x, y, hxy, hya, hpxy⟩ : ∃ x y : ℤ, x < y ∧ y ≤ a - 1 ∧ τ.path x = τ.path y := by
    rcases lt_or_gt_of_ne hij with hlt | hgt
    · exact ⟨a - 1 - j, a - 1 - i, by omega, by omega, hfij.symm⟩
    · exact ⟨a - 1 - i, a - 1 - j, by omega, by omega, hfij⟩
  set L := y - x with hL
  have hLpos : 0 < L := by omega
  let h' : ℤ → F.WorldState := fun n => τ.path (x + n % L)
  have hstep : ∀ n, F.step (h' n) (h' (n + 1)) := by
    intro n
    have hr0 := Int.emod_nonneg n (ne_of_gt hLpos)
    have hrL := Int.emod_lt_of_pos n hLpos
    have hdecomp := Int.emod_add_mul_ediv n L
    have key : τ.path (x + (n + 1) % L) = τ.path (x + n % L + 1) := by
      have e : (n + 1) % L = (n % L + 1) % L := by
        conv_lhs => rw [← hdecomp]
        rw [show n % L + L * (n / L) + 1 = (n % L + 1) + L * (n / L) by ring,
          Int.add_mul_emod_self_left]
      rw [e]
      rcases lt_or_eq_of_le (show n % L + 1 ≤ L by omega) with hlt | heq
      · rw [Int.emod_eq_of_lt (by omega) hlt, add_assoc]
      · rw [heq, Int.emod_self, add_zero, hpxy]
        congr 1; omega
    simp only [h']
    rw [key]
    exact steps τ _
  obtain ⟨s, hs⟩ := someP (mk h' hstep)
  have hr0 := Int.emod_nonneg s (ne_of_gt hLpos)
  have hrL := Int.emod_lt_of_pos s hLpos
  exact firstP τ a ha (x + s % L) (by omega) hs

end Finite'

/-- **The finite-carrier finite model property fails already for the CTL-like fragment.** -/
theorem not_finite_carrier_fmp_fragment :
    ¬ ∀ φ : PlusFormula, ¬ PlusValidZTime φ →
      ∃ (F : FrameOver intOrder) (_ : F.IsRegular) (_ : Finite F.WorldState)
        (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ),
        ¬ PlusTruthAt M τ t φ := by
  intro fmp
  obtain ⟨F, hreg, hfin, M, τ, t, hτ⟩ := fmp θ'.neg not_plusValidZTime_neg_θ'
  exact hτ (fun hθ => no_finite_carrier_sat' M τ t hθ)

#print axioms not_plusValidZTime_neg_θ'
#print axioms no_finite_carrier_sat'
#print axioms not_finite_carrier_fmp_fragment

#print axioms not_plusValidZTime_neg_θ
#print axioms no_finite_carrier_sat
#print axioms no_ofStep_sat
#print axioms not_finite_carrier_fmp

end Probe706
