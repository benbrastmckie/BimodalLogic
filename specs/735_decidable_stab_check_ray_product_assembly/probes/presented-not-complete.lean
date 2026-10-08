/-
Research probe (decidable stab check assembly): **`Presented` is not a complete presentation
notion — it fails on a finite regular model for every finite presentation.**

Fixture model A of `quasistate-does-not-determine-hit.lean` (three states, `p` at `b` only,
steps `a→a, a→b, b→b`), seam `(t, a)`, `φ := Fp`. For every `n` the history that stays at `a`
until `t + n + 1` and then jumps to `b` passes through the seam, so its closure trace
`(¬p, Fp)^(n+1) · (p, Fp)^ω` (forward from `t`) is a seam trace. A finite presentation whose
run traces include all of these also has, by pumping a repeated state in the first
`card Q + 1` positions after `t`, a run whose trace has `Fp` at `t` and `p` nowhere after `t` —
which violates the `untl` run condition, so by `Presented` (⇐) and `clTrace_localRun` it is no
seam trace. Hence `¬ Presented MA stayA t Fp lab step` for every `Q`, `lab`, `step`.
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe735

/-! ## The fixture (model A of the B2b verdict probe, re-declared) -/

abbrev St := Fin 3

def a : St := 0
def b : St := 1

def pa : Atom := ⟨"p", none⟩

abbrev Fp : PlusFormula := someFuture (.atom pa)

def RA : ℤ → St → St → Prop := fun _ u v => v = u ∨ v = b

theorem RA_fwd : ∀ (t : ℤ) (w : St), ∃ u, RA t w u := fun _ w => ⟨w, Or.inl rfl⟩
theorem RA_bwd : ∀ (t : ℤ) (w : St), ∃ v, RA (t - 1) v w := fun _ w => ⟨w, Or.inl rfl⟩
theorem RA_aa : ∀ t, RA t a a := fun _ => Or.inl rfl
theorem RA_ab : ∀ t, RA t a b := fun _ => Or.inr rfl
theorem RA_bb : ∀ t, RA t b b := fun _ => Or.inl rfl

abbrev FA : FrameOver intOrder := FrameOver.ofSlicedStep RA RA_fwd RA_bwd

instance instFARegular : FA.IsRegular := FrameOver.ofSlicedStep_isRegular RA RA_fwd RA_bwd

/-- `p` holds exactly at `b`. -/
def MA : TaskModel FA.toTaskFrame where
  valuation q _ := q.2 = b

/-- The constant history at `a`. -/
noncomputable def stayA : WorldHistory FA.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath FA (fun z => (z, a)) (by
    intro z
    exact (FrameOver.ofSlicedStep_step RA RA_fwd RA_bwd _ _).mpr ⟨rfl, RA_aa z⟩)

theorem stayA_state (z : ℤ) : stayA.state z = (z, a) := rfl

/-- The history at `a` up to `w` and at `b` from `w + 1`. -/
noncomputable def jump (w : ℤ) : WorldHistory FA.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath FA (fun z => (z, if w < z then b else a)) (by
    intro z
    refine (FrameOver.ofSlicedStep_step RA RA_fwd RA_bwd _ _).mpr ⟨rfl, ?_⟩
    show RA z (if w < z then b else a) (if w < z + 1 then b else a)
    by_cases h : w < z
    · rw [if_pos h, if_pos (by omega)]
      exact RA_bb z
    · rw [if_neg h]
      by_cases h' : w < z + 1
      · rw [if_pos h']
        exact RA_ab z
      · rw [if_neg h']
        exact RA_aa z)

theorem jump_state (w z : ℤ) : (jump w).state z = (z, if w < z then b else a) := rfl

theorem p_iff (σ : WorldHistory FA.toTaskFrame) (z : ℤ) :
    PlusTruthAt MA σ z (.atom pa) ↔ (σ.state z).2 = b := Iff.rfl

theorem Fp_iff (σ : WorldHistory FA.toTaskFrame) (z : ℤ) :
    PlusTruthAt MA σ z Fp ↔ ∃ s, z < s ∧ (σ.state s).2 = b :=
  PlusTruth.someFuture_iff _ _ _ _

theorem jump_p_iff (w z : ℤ) : PlusTruthAt MA (jump w) z (.atom pa) ↔ w < z := by
  rw [p_iff, jump_state]
  by_cases h : w < z
  · simp [h]
  · simp [h, a, b]

theorem jump_Fp (w z : ℤ) : PlusTruthAt MA (jump w) z Fp := by
  rw [Fp_iff]
  refine ⟨max w z + 1, by omega, ?_⟩
  rw [jump_state]
  show (if w < max w z + 1 then b else a) = b
  rw [if_pos (by omega)]

/-! ## Pumping a run of a finite presentation -/

section Pump

variable {Q : Type} {sig : MonadicSignature}
  (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (now : sig.preds)

/-- The index walked by the pumped run after `i`: the segment `[i, j)` repeated forever. -/
def loopIdx (i j : ℤ) : ℕ → ℤ
  | 0 => i
  | n + 1 => if loopIdx i j n + 1 = j then i else loopIdx i j n + 1

theorem loopIdx_bounds (i j : ℤ) (hij : i < j) (n : ℕ) :
    i ≤ loopIdx i j n ∧ loopIdx i j n < j := by
  induction n with
  | zero => exact ⟨le_rfl, hij⟩
  | succ n ih =>
    simp only [loopIdx]
    split_ifs with h <;> omega

/-- The pumped run: `ρ` up to `i`, then `ρ` on the segment `[i, j)` repeated forever. -/
def pump (ρ : ℤ → Q) (i j : ℤ) (z : ℤ) : Q :=
  if z ≤ i then ρ z else ρ (loopIdx i j (z - i).toNat)

theorem pump_of_le (ρ : ℤ → Q) (i j z : ℤ) (h : z ≤ i) : pump ρ i j z = ρ z := if_pos h

theorem pump_of_lt (ρ : ℤ → Q) (i j z : ℤ) (h : i < z) :
    pump ρ i j z = ρ (loopIdx i j (z - i).toNat) := if_neg (by omega)

/-- Every value of the pumped run at or after `t < i` is a value of `ρ` on `[t, j)`. -/
theorem pump_exists (ρ : ℤ → Q) (t i j : ℤ) (hti : t < i) (hij : i < j) (z : ℤ) (hz : t ≤ z) :
    ∃ w, t ≤ w ∧ w < j ∧ pump ρ i j z = ρ w := by
  by_cases h : z ≤ i
  · exact ⟨z, hz, by omega, pump_of_le ρ i j z h⟩
  · obtain ⟨h1, h2⟩ := loopIdx_bounds i j hij (z - i).toNat
    exact ⟨_, by omega, h2, pump_of_lt ρ i j z (by omega)⟩

theorem pump_isRun (t : ℤ) (ρ : ℤ → Q) (hρ : IsRun lab step now t ρ) (i j : ℤ)
    (hti : t < i) (hij : i < j) (hloop : ρ i = ρ j) : IsRun lab step now t (pump ρ i j) := by
  obtain ⟨hstep, hnow⟩ := hρ
  -- a step out of any `w ∈ [i, j)` lands on `ρ (w + 1)`, also through the wrap-around
  have hnext : ∀ w, i ≤ w → w < j →
      ρ (if w + 1 = j then i else w + 1) = ρ (w + 1) := by
    intro w _ _
    split_ifs with h
    · rw [hloop, h]
    · rfl
  refine ⟨?_, ?_⟩
  · intro z
    by_cases hz : z + 1 ≤ i
    · rw [pump_of_le ρ i j z (by omega), pump_of_le ρ i j (z + 1) hz]
      exact hstep z
    · by_cases hz' : z ≤ i
      · have hzi : z = i := by omega
        subst hzi
        rw [pump_of_le ρ z j z le_rfl, pump_of_lt ρ z j (z + 1) (by omega),
          show (z + 1 - z).toNat = 1 by omega]
        show step (ρ z) (ρ (if loopIdx z j 0 + 1 = j then z else loopIdx z j 0 + 1)) = true
        rw [show loopIdx z j 0 = z from rfl, hnext z le_rfl hij]
        exact hstep z
      · rw [pump_of_lt ρ i j z (by omega), pump_of_lt ρ i j (z + 1) (by omega),
          show (z + 1 - i).toNat = (z - i).toNat + 1 by omega]
        obtain ⟨h1, h2⟩ := loopIdx_bounds i j hij (z - i).toNat
        show step (ρ _) (ρ (if loopIdx i j (z - i).toNat + 1 = j then i
          else loopIdx i j (z - i).toNat + 1)) = true
        rw [hnext _ h1 h2]
        exact hstep _
  · intro z
    by_cases hz : z ≤ i
    · rw [pump_of_le ρ i j z hz]
      exact hnow z
    · rw [pump_of_lt ρ i j z (by omega)]
      obtain ⟨h1, _⟩ := loopIdx_bounds i j hij (z - i).toNat
      rw [hnow]
      constructor
      · intro h; omega
      · intro h; omega

end Pump

/-! ## The obstruction -/

theorem hFp : Fp ∈ plusSubformulaClosure Fp := self_mem_plusSubformulaClosure Fp

theorem hatom : PlusFormula.atom pa ∈ plusSubformulaClosure Fp :=
  plusClosure_untl_left Fp (.atom pa) PlusFormula.top hFp

/-- **`Presented` fails on model A at the seam `(t, a)` for every finite presentation.** -/
theorem not_presented (t : ℤ) {Q : Type} [Fintype Q] [DecidableEq Q]
    (lab : Q → (clSig Fp).preds → Bool) (step : Q → Q → Bool) :
    ¬ Presented MA stayA t Fp lab step := by
  intro hP
  -- the seam history that stays at `a` until `t + card Q + 1`
  set n : ℕ := Fintype.card Q with hn
  set σ : WorldHistory FA.toTaskFrame := jump (t + n + 1) with hσ
  have hσt : σ.state t = stayA.state t := by
    rw [hσ, jump_state, stayA_state, if_neg (by omega)]
  -- its closure trace is a seam trace, hence (⇒) a run trace
  have hsp : ∃ bf : SeqPair FA (stayA.state t),
      clTrace MA Fp t σ = clTrace MA Fp t (spliced stayA t bf) := by
    let x : Presheaf.StabFibre FA.toTaskFrame t (stayA.state t) := ⟨σ, hσt⟩
    refine ⟨seamOmegaEquiv t (stayA.state t) x, ?_⟩
    have hrt := Equiv.symm_apply_apply (seamOmegaEquiv t (stayA.state t)) x
    show clTrace MA Fp t x.1 = clTrace MA Fp t
      ((seamOmegaEquiv t (stayA.state t)).symm ((seamOmegaEquiv t (stayA.state t)) x)).1
    rw [hrt]
  obtain ⟨ρ, hρ, hc⟩ := (hP (clTrace MA Fp t σ)).mp hsp
  -- `Fp` at `t` on the run, `p` nowhere on `[t, t + n + 1]`
  have hFpt : lab (ρ t) (clLetter Fp hFp) = true := by
    have h1 : clTrace MA Fp t σ (clLetter Fp hFp) t := jump_Fp (t + n + 1) t
    rw [hc] at h1
    exact h1
  have hpf : ∀ z, t ≤ z → z ≤ t + n + 1 → lab (ρ z) (clLetter Fp hatom) = false := by
    intro z hz1 hz2
    have h1 : ¬ clTrace MA Fp t σ (clLetter Fp hatom) z := by
      show ¬ PlusTruthAt MA σ z (.atom pa)
      rw [hσ, jump_p_iff]
      omega
    rw [hc] at h1
    exact Bool.eq_false_iff.mpr h1
  -- pigeonhole on the `n + 1` positions `t + 1, …, t + n + 1`
  have hcard : Fintype.card Q < Fintype.card (Fin (n + 1)) := by
    rw [Fintype.card_fin]; omega
  obtain ⟨x, y, hxy, hfxy⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun m : Fin (n + 1) => ρ (t + 1 + m)) hcard
  -- the pumped run refutes the `untl` run condition
  have key : ∀ i j : ℤ, t < i → i < j → j ≤ t + n + 1 → ρ i = ρ j → False := by
    intro i j hti hij hj hloop
    have hρ' := pump_isRun lab step (clNow Fp) t ρ hρ i j hti hij hloop
    obtain ⟨bf', hbf'⟩ := (hP (runTrace lab (pump ρ i j))).mpr ⟨_, hρ', rfl⟩
    have hL : LocalRun Fp (runTrace lab (pump ρ i j)) := by
      rw [hbf']
      exact clTrace_localRun MA Fp t _
    have h0 : runTrace lab (pump ρ i j) (clLetter Fp hFp) t := by
      show lab (pump ρ i j t) (clLetter Fp hFp) = true
      rw [pump_of_le ρ i j t (le_of_lt hti)]
      exact hFpt
    obtain ⟨s, hts, hs, -⟩ := (hL.untl PlusFormula.top (.atom pa) hFp t).mp h0
    obtain ⟨w, htw, hwj, hw⟩ := pump_exists ρ t i j hti hij s (le_of_lt hts)
    have hs' : lab (pump ρ i j s) (clLetter Fp hatom) = true := hs
    rw [hw, hpf w htw (by omega)] at hs'
    exact Bool.false_ne_true hs'
  rcases lt_or_gt_of_ne hxy with h | h
  · exact key (t + 1 + x) (t + 1 + y) (by omega) (by simp only [Fin.lt_def] at h; omega)
      (by omega) hfxy
  · exact key (t + 1 + y) (t + 1 + x) (by omega) (by simp only [Fin.lt_def] at h; omega)
      (by omega) hfxy.symm

#print axioms not_presented

end Probe735
