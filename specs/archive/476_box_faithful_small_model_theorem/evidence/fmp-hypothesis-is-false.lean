/-
Evidence probe: the `fmp` hypothesis of `BiLasso/Assembly.lean` is FALSE for every candidate list.

  fmp : ∀ φ, ¬ ValidZTime φ → ∃ P ∈ cands φ, ∃ w : Fin P.card, SatAtState P w φ.neg

Witness: ψ := □(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)  ("every history meets p, and meets it at most once
from the left").
- Positive half: ψ holds in the ℤ-carrier shift set (sh w d = w + d, p true only at state 0), so
  ¬ ValidZTime ψ.neg.
- Negative half: no IntPresentation satisfies ψ at any history/time: a history τ meets p at some
  a; left of a it is p-free; pigeonhole on card+1 times finds a repeated state; the resulting
  cycle, pumped bi-infinitely, is itself a history (all walks are histories) that never meets p,
  contradicting the first conjunct.

Checked with `lean_run_code` (no `lake build`) on 2026-09-18 against the live tree; `fmp_false`
measures [propext, Classical.choice, Quot.sound] -- no sorryAx.
Compile-check with: lake env lean specs/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean
-/
import FormalSystem.Semantics.ShiftSet
import FormalSystem.Metalogic.Decidability.BiLasso.Assembly
open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.Metalogic.Decidability

namespace Probe476

def pa : Atom := ⟨"p", none⟩
def p : Formula := Formula.atom pa
def Fp : Formula := Formula.untl Formula.top p
def Pp : Formula := Formula.snce Formula.top p
/-- `□(p ∨ Fp ∨ Pp)`: every history meets `p` at some time. -/
def A : Formula := Formula.box (p.or (Fp.or Pp))
/-- `□(p → ¬Pp)`: a `p`-time has no earlier `p`-time. -/
def C : Formula := Formula.box (p.imp Pp.neg)
def ψ : Formula := A.and C

/-! ### Positive half: `ψ` is satisfiable over ℤ-time (infinite carrier). -/

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

theorem shiftTruth_psi (w t : ℤ) : S.ShiftTruth w t ψ := by
  simp only [ψ, A, C, Formula.and, Formula.or, Formula.neg, Formula.top, Fp, Pp, p,
    ShiftSet.ShiftTruth]
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

theorem not_validZTime_neg_psi : ¬ ValidZTime ψ.neg := by
  intro hv
  have := hv S.frame (TaskFrame.isZTime_of_instances _) S.model (S.hist (0:ℤ)) (0:ℤ)
  exact this ((S.forward_repr (0:ℤ) (0:ℤ) ψ).mpr (shiftTruth_psi 0 0))

/-! ### Negative half: no `IntPresentation` satisfies `ψ` anywhere. -/

variable (P : IntPresentation)

def mk (f : ℤ → Fin P.card) (hf : ∀ n, P.step (f n) (f (n + 1)) = true) :
    WorldHistory P.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath P.toFibre f ((P.isStepPath_iff f).mpr hf)

theorem steps (σ : WorldHistory P.toTaskFrame) (n : ℤ) :
    P.step (σ.path n) (σ.path (n + 1)) = true :=
  (P.isStepPath_iff _).mp σ.isStepPath n

theorem no_presentation_sat (τ : WorldHistory P.toTaskFrame) (t : ℤ) :
    ¬ TruthAt P.toModel τ t ψ := by
  intro h
  have hA : TruthAt P.toModel τ t A := by
    by_contra hA; exact h (fun a => absurd a hA)
  have hC : TruthAt P.toModel τ t C := by
    by_contra hC; exact h (fun _ c => hC c)
  simp only [A, C, Formula.or, Formula.neg, Fp, Pp, Formula.top, p, TruthAt] at hA hC
  have someP : ∀ σ : WorldHistory P.toTaskFrame, ∃ a, P.val pa (σ.path a) = true := by
    intro σ
    by_contra hno
    have hno' : ∀ a, ¬ P.toModel.valuation (σ.state a) pa := fun a h => hno ⟨a, h⟩
    obtain ⟨s, -, hs, -⟩ := hA σ (hno' t) (fun ⟨s, _, hs, _⟩ => hno' s hs)
    exact hno' s hs
  have firstP : ∀ σ : WorldHistory P.toTaskFrame, ∀ a, P.val pa (σ.path a) = true →
      ∀ b < a, P.val pa (σ.path b) ≠ true := by
    intro σ a ha b hb hbt
    let g : ℤ → Fin P.card := fun n => σ.path (n + (a - t))
    have hg : ∀ n, P.step (g n) (g (n + 1)) = true := by
      intro n
      have := steps P σ (n + (a - t))
      simp only [g]; rwa [show n + 1 + (a - t) = n + (a - t) + 1 by ring]
    apply hC (mk P g hg)
    · show P.val pa (σ.path (t + (a - t))) = true
      rwa [show t + (a - t) = a by ring]
    · refine ⟨b - (a - t), by omega, ?_, fun _ _ _ h => h⟩
      show P.val pa (σ.path (b - (a - t) + (a - t))) = true
      rwa [show b - (a - t) + (a - t) = b by ring]
  obtain ⟨a, ha⟩ := someP τ
  let f : Fin (P.card + 1) → Fin P.card := fun i => τ.path (a - 1 - i)
  obtain ⟨i, j, hij, hfij⟩ := Fintype.exists_ne_map_eq_of_card_lt f (by simp)
  obtain ⟨x, y, hxy, hya, hpxy⟩ : ∃ x y : ℤ, x < y ∧ y ≤ a - 1 ∧ τ.path x = τ.path y := by
    rcases lt_or_gt_of_ne (Fin.val_ne_of_ne hij) with hlt | hgt
    · exact ⟨a - 1 - j, a - 1 - i, by omega, by omega, hfij.symm⟩
    · exact ⟨a - 1 - i, a - 1 - j, by omega, by omega, hfij⟩
  set L := y - x with hL
  have hLpos : 0 < L := by omega
  let h' : ℤ → Fin P.card := fun n => τ.path (x + n % L)
  have hstep : ∀ n, P.step (h' n) (h' (n + 1)) = true := by
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
    exact steps P τ _
  obtain ⟨s, hs⟩ := someP (mk P h' hstep)
  have hr0 := Int.emod_nonneg s (ne_of_gt hLpos)
  have hrL := Int.emod_lt_of_pos s hLpos
  exact firstP τ a ha (x + s % L) (by omega) hs

theorem no_presentation_satAtState (w : Fin P.card) : ¬ SatAtState P w ψ.neg.neg := by
  rintro ⟨τ, t, -, htr⟩
  exact htr (no_presentation_sat P τ t)

/-- **The `fmp` hypothesis of `Assembly.lean` is false, for every candidate list.** -/
theorem fmp_false (cands : Formula → List IntPresentation) :
    ¬ (∀ φ : Formula, ¬ ValidZTime φ →
        ∃ P ∈ cands φ, ∃ w : Fin P.card, SatAtState P w φ.neg) := by
  intro fmp
  obtain ⟨P, -, w, hw⟩ := fmp ψ.neg not_validZTime_neg_psi
  exact no_presentation_satAtState P w hw

#print axioms fmp_false
end Probe476
