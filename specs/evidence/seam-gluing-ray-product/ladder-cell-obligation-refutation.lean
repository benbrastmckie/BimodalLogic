/-
THE DEPTH-0 CELL OBLIGATION IS REFUTED AT THE PARAMETER CONDITIONS AS THE OBLIGATION WAS FILED
AGAINST: `CellLEZeroConstOfKappaEqPre` — the library schema `CellLEZeroConstOfKappaEq` with the
parameter conditions' fourth conjunct frozen at `paramsOkK4Pre φ B := 2 * dBack φ + 1 ≤ B ∧ 2 ≤ B`,
the (K4) that bounds the gap clip by the BACKWARD exactness depth alone — fails at Probe761C's own
object, at the parameter outputs `Tcof`, `Tnof`, `Pof` and the gap clip `B = 2` that the frozen
(K4) admits, for a stab-free, `S`-free closure.

Mechanism. The gap coordinate of `kappa` clips `n - c` at `B`, and the frozen (K4) admits `B = 2`
for a formula with no `S`. But the next-deadline register is `1`-Lipschitz and its value at the
first idle position after `z`'s region IS the countdown of the region that follows
(`cntAt_eq_nxtAt_of_idle_pend`), so `nxtAt z ≤ cntAt z + I₁ + L₁ - 1` where `I₁` is the length of
the next idle run and `L₁` the length of the next region. A `U`-only formula of bounded `X`-depth
pins `I₁ = 1` and `L₁ = 2`, bounding the register at `z` by `cntAt z + 2`, while the collision
partner `(c, n + (P + 1))` has register `≥ c + 3`. So the type carrying that formula lies in the
cell at `(q, c, c + 2)` and in NO type of the cell at `(q, c, c + 2 + (P + 1))`.

What the repair of (K4) changes, compiled here as two positive facts. The library's (K4) now reads
`paramsOkK4 φ B := 2 * dBack φ + 1 ≤ B ∧ 2 * dFwd φ + 1 ≤ B ∧ 2 ≤ B`, with `dFwd` the forward
exactness depth (the `U`-nesting), and `Bof` is the matching output. `not_paramsOkK4_two`: the
repaired (K4) rejects `B = 2` for the separating formula (`dFwd chiD = 4`). `kappa_D_dissolves`:
at the repaired output `Bof stepC pendC labC chiD = 10`, the specific collision the refutation
turns on is no longer a collision — the unclipped gap `2` is distinguished from a gap of at least
`3`. Neither fact is a proof of the obligation under the repaired predicate; they say only that
THIS separating object is answered by the repair.

The frozen copies (`paramsOkK4Pre`, `ParamsOkPre`, `CellLEZeroConstOfKappaEqPre`) are verbatim
the library's conjunction and schema text with the fourth conjunct as the obligation was filed
against, so that the refutation stays a theorem about a named object after the library predicate
changed. Precedent: `AtomPreservingCountMove`, kept as a `def` so its refutation is a theorem.

The forty-seventh wired probe, compiled by `scripts/check-evidence-probes.sh`.
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe836A

/-! ### The parameter conditions as the obligation was filed against

`paramsOkK4Pre` is (K4) with the gap clip bounded by the backward exactness depth alone;
`ParamsOkPre` is the library's `ParamsOk` conjunction verbatim with that fourth conjunct;
`CellLEZeroConstOfKappaEqPre` is the library schema's text with `ParamsOkPre` in place of
`ParamsOk`. -/

def paramsOkK4Pre (φ : PlusFormula) (B : ℕ) : Prop :=
  2 * dBack φ + 1 ≤ B ∧ 2 ≤ B

def ParamsOkPre {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  paramsOkK1 step pend lab φ P ∧ paramsOkK2 step pend lab φ Tc P ∧
    paramsOkK3 Q pend φ Tc Tn ∧ paramsOkK4Pre φ B

def CellLEZeroConstOfKappaEqPre {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  ParamsOkPre step pend lab φ Tc Tn P B →
    (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q) (z : ℤ),
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
      cellAt (ladderModel step pend fwd bwd lab) φ
          ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z
        = cellAt (ladderModel step pend fwd bwd lab) φ
            ((z, ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z

/-! ### The object: Probe761C's own -/

abbrev Qc : Type := Fin 2

def pendC : Qc → Bool := fun q => decide (q = 0)

def stepC : Qc → Qc → Bool := fun _ _ => true

def pC : Atom := ⟨"p", none⟩

def labC : Qc → Atom → Bool := fun q at_ => decide (at_ = pC ∧ q = 0)

theorem pendC_zero : pendC 0 = true := by decide

theorem pendC_one : pendC 1 = false := by decide

theorem labC_pC (q : Qc) : labC q pC = pendC q := by
  simp [labC, pendC]

theorem admZeroC (d n : ℕ) : ((0 : Qc), d, n).2.1 ∈ Adm pendC ((0 : Qc), d, n).1 :=
  fun h => absurd (pendC_zero.symm.trans h) (by simp)

theorem fwdC : ∀ (t : ℤ) (x : LadderState Qc pendC), ∃ y, RladAdm stepC pendC t x y := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  by_cases hq : pendC q = true
  · cases c with
    | zero =>
        refine ⟨⟨(1, 0, n), fun _ => rfl⟩, rfl, hx, Or.inl rfl, ?_⟩
        simp [Count, hq, pendC_one]
    | succ d =>
        refine ⟨⟨(0, d, n), admZeroC d n⟩, rfl, hx, Or.inl rfl, ?_⟩
        simp [Count, hq, pendC_zero]
  · rw [Bool.not_eq_true] at hq
    refine ⟨⟨(1, 0, n), fun _ => rfl⟩, rfl, hx, Or.inl rfl, ?_⟩
    simp [Count, hq, pendC_one]

theorem bwdC : ∀ (t : ℤ) (x : LadderState Qc pendC), ∃ y, RladAdm stepC pendC (t - 1) y x := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  by_cases hq : pendC q = true
  · refine ⟨⟨(0, c + 1, n), admZeroC (c + 1) n⟩, rfl, admZeroC (c + 1) n,
      Or.inl rfl, ?_⟩
    simp [Count, hq, pendC_zero]
  · rw [Bool.not_eq_true] at hq
    have hc : c = 0 := hx hq
    refine ⟨⟨(0, 0, n), admZeroC 0 n⟩, rfl, admZeroC 0 n, Or.inl rfl, ?_⟩
    simp [Count, hq, pendC_zero, hc]

/-! ### The formula: `a U (¬a ∧ X(a ∧ X(a ∧ X ¬a)))`, with `X ψ := ⊥ U ψ` -/

def X (ψ : PlusFormula) : PlusFormula := .untl .bot ψ

def aD : PlusFormula := .atom pC

def naD : PlusFormula := PlusFormula.neg aD

/-- The next idle run after the current region has length exactly `1`, and the region after it
has length exactly `2`. -/
def chiD : PlusFormula := .untl aD (naD.and (X (aD.and (X (aD.and (X naD))))))

theorem no_stab_in_closure_chiD :
    ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure chiD := by
  intro χ h
  simp [plusSubformulaClosure, chiD, X, aD, naD, PlusFormula.neg, PlusFormula.and,
    PlusFormula.subformulas] at h

theorem dBack_chiD : dBack chiD = 0 := by
  simp [dBack, chiD, X, aD, naD, PlusFormula.neg, PlusFormula.and]

theorem dFwd_chiD : dFwd chiD = 4 := by
  simp [dFwd, chiD, X, aD, naD, PlusFormula.neg, PlusFormula.and]

/-! ### The parameters: the periodicity fixpoint's own outputs, and the gap clip the frozen
(K4) admits -/

noncomputable def TcC : ℕ := Tcof stepC pendC labC chiD
noncomputable def TnC : ℕ := Tnof stepC pendC labC chiD
noncomputable def PC : ℕ := Pof stepC pendC labC chiD

/-- The gap clip the frozen (K4) admits for a formula with no `S`. -/
def BC : ℕ := 2

theorem BC_eq_two : BC = 2 := rfl

/-- The frozen parameter conditions at the fixpoint's three outputs and the gap clip `2`: the
first three conjuncts are `paramsOk_params`'s own, the fourth is `dBack chiD = 0`. -/
theorem paramsOkPreD : ParamsOkPre stepC pendC labC chiD TcC TnC PC BC :=
  ⟨(paramsOk_params stepC pendC labC chiD).1, (paramsOk_params stepC pendC labC chiD).2.1,
    (paramsOk_params stepC pendC labC chiD).2.2.1, by
      show 2 * dBack chiD + 1 ≤ 2 ∧ 2 ≤ 2
      rw [dBack_chiD]; omega⟩

/-- **The repaired (K4) rejects the gap clip `2` for the separating formula.** -/
theorem not_paramsOkK4_two : ¬ paramsOkK4 chiD 2 := by
  intro h
  have := h.2.1
  rw [dFwd_chiD] at this
  omega

theorem Bof_chiD : Bof stepC pendC labC chiD = 10 := by
  simp [Bof, dBack_chiD, dFwd_chiD]

/-- **The specific collision dissolves at the repaired output.** At `Bof = 10` the unclipped gap
`2` is distinguished from a gap of at least `3`. -/
theorem kappa_D_dissolves :
    kappa TcC TnC PC (Bof stepC pendC labC chiD) (c0, c0 + 2)
      ≠ kappa TcC TnC PC (Bof stepC pendC labC chiD) (c0, c0 + 2 + (PC + 1)) := by
  intro h
  rw [Bof_chiD] at h
  simp only [kappa, Prod.mk.injEq, Fin.mk.injEq] at h
  have hgap := h.2.2.2.2
  unfold clipIdx at hgap
  split_ifs at hgap <;> omega

noncomputable def c0 : ℕ := max TcC TnC

/-! ### The model, and the `X` reading -/

noncomputable abbrev MD := ladderModel stepC pendC fwdC bwdC labC

abbrev HistD := WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame

theorem X_iff (τ : HistD) (t : ℤ) (ψ : PlusFormula) :
    PlusTruthAt MD τ t (X ψ) ↔ PlusTruthAt MD τ (t + 1) ψ := by
  rw [X, PlusTruth.untl_iff]
  constructor
  · rintro ⟨s, hs, hψ, hgd⟩
    obtain ⟨s', rfl⟩ : ∃ s' : ℤ, s' = s := ⟨s, rfl⟩
    have hs' : t < s' := hs
    have : s' = t + 1 := by
      by_contra hne
      exact PlusTruth.bot_false MD τ (t + 1)
        (hgd (t + 1) (Int.lt_add_one_iff.mpr le_rfl)
          (lt_of_le_of_ne (Int.lt_iff_add_one_le.mp hs') (Ne.symm hne)))
    subst this
    exact hψ
  · intro h
    refine ⟨t + 1, Int.lt_add_one_iff.mpr le_rfl, h, fun r h1 h2 => ?_⟩
    obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
    have h1' : t < r' := h1
    have h2' : r' < t + 1 := h2
    omega

/-- The atom `a` read along a ladder path's history: the pending bit of the object there. -/
theorem atom_iff_pend {g : ℤ → LadderState Qc pendC} (τ : HistD)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (t : ℤ) :
    PlusTruthAt MD τ t aD ↔ pendC (objAt g t) = true := by
  rw [aD, PlusTruth.atom_iff, hτ t]
  change labC (objAt g t) pC = true ↔ _
  rw [labC_pC]

theorem natom_iff_idle {g : ℤ → LadderState Qc pendC} (τ : HistD)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (t : ℤ) :
    PlusTruthAt MD τ t naD ↔ pendC (objAt g t) = false := by
  rw [naD, PlusTruth.neg_iff, atom_iff_pend τ hτ t]
  simp

/-! ### The witness path through `(0, c₀, c₀ + 2)`: pending forever into the past, idle at
`c₀ + 1`, a region of length `2` at `c₀ + 2, c₀ + 3`, idle from `c₀ + 4` on. -/

def wD (c₀ : ℕ) : ℤ → Qc := fun v =>
  if v ≤ (c₀ : ℤ) then 0 else if v = (c₀ : ℤ) + 1 then 1 else if v ≤ (c₀ : ℤ) + 3 then 0 else 1

def cD (c₀ : ℕ) : ℤ → ℕ := fun v =>
  if v ≤ (c₀ : ℤ) then ((c₀ : ℤ) - v).toNat else if v = (c₀ : ℤ) + 2 then 1 else 0

def nD (c₀ : ℕ) : ℤ → ℕ := fun v =>
  if v ≤ 0 then c₀ + 2 else if v ≤ (c₀ : ℤ) + 1 then ((c₀ : ℤ) + 2 - v).toNat else 1

theorem wD_of_le (c₀ : ℕ) (v : ℤ) (h : v ≤ (c₀ : ℤ)) : wD c₀ v = 0 := by
  unfold wD; rw [if_pos h]

theorem wD_of_eq1 (c₀ : ℕ) (v : ℤ) (h : v = (c₀ : ℤ) + 1) : wD c₀ v = 1 := by
  unfold wD; rw [if_neg (by omega), if_pos h]

theorem wD_of_mid (c₀ : ℕ) (v : ℤ) (h1 : (c₀ : ℤ) + 2 ≤ v) (h2 : v ≤ (c₀ : ℤ) + 3) :
    wD c₀ v = 0 := by
  unfold wD; rw [if_neg (by omega), if_neg (by omega), if_pos h2]

theorem wD_of_ge (c₀ : ℕ) (v : ℤ) (h : (c₀ : ℤ) + 4 ≤ v) : wD c₀ v = 1 := by
  unfold wD; rw [if_neg (by omega), if_neg (by omega), if_neg (by omega)]

theorem cD_of_le (c₀ : ℕ) (v : ℤ) (h : v ≤ (c₀ : ℤ)) : cD c₀ v = ((c₀ : ℤ) - v).toNat := by
  unfold cD; rw [if_pos h]

theorem cD_of_eq2 (c₀ : ℕ) (v : ℤ) (h : v = (c₀ : ℤ) + 2) : cD c₀ v = 1 := by
  unfold cD; rw [if_neg (by omega), if_pos h]

theorem cD_other (c₀ : ℕ) (v : ℤ) (h1 : ¬ v ≤ (c₀ : ℤ)) (h2 : v ≠ (c₀ : ℤ) + 2) :
    cD c₀ v = 0 := by
  unfold cD; rw [if_neg h1, if_neg h2]

theorem nD_of_le (c₀ : ℕ) (v : ℤ) (h : v ≤ 0) : nD c₀ v = c₀ + 2 := by
  unfold nD; rw [if_pos h]

theorem nD_of_mid (c₀ : ℕ) (v : ℤ) (h1 : ¬ v ≤ 0) (h2 : v ≤ (c₀ : ℤ) + 1) :
    nD c₀ v = ((c₀ : ℤ) + 2 - v).toNat := by
  unfold nD; rw [if_neg h1, if_pos h2]

theorem nD_drift (c₀ : ℕ) (u : ℤ) : Drift (nD c₀ u) (nD c₀ (u + 1)) := by
  unfold Drift nD
  split_ifs <;> omega

theorem admD (c₀ : ℕ) (v : ℤ) : pendC (wD c₀ v) = false → cD c₀ v = 0 := by
  intro h
  by_cases h1 : v ≤ (c₀ : ℤ)
  · rw [wD_of_le c₀ v h1] at h
    exact absurd (pendC_zero.symm.trans h) (by simp)
  · by_cases h2 : v = (c₀ : ℤ) + 2
    · rw [wD_of_mid c₀ v (by omega) (by omega)] at h
      exact absurd (pendC_zero.symm.trans h) (by simp)
    · exact cD_other c₀ v h1 h2

def gD (c₀ : ℕ) : ℤ → LadderState Qc pendC :=
  fun v => ⟨(wD c₀ v, cD c₀ v, nD c₀ v), admD c₀ v⟩

theorem gD_isPath (c₀ : ℕ) : IsLadderPath stepC pendC (gD c₀) := by
  intro u
  refine ⟨rfl, admD c₀ u, nD_drift c₀ u, ?_⟩
  show Count (pendC (wD c₀ u)) (pendC (wD c₀ (u + 1))) (cD c₀ u) (nD c₀ u) (cD c₀ (u + 1))
  rcases lt_trichotomy u (c₀ : ℤ) with hA | hB | hC
  · -- pending to pending, inside the long region
    rw [wD_of_le c₀ u (by omega), wD_of_le c₀ (u + 1) (by omega),
      cD_of_le c₀ u (by omega), cD_of_le c₀ (u + 1) (by omega)]
    simp only [Count, pendC_zero, if_true]
    omega
  · -- the region's last pending position steps to the idle position
    subst hB
    rw [wD_of_le c₀ (c₀ : ℤ) le_rfl, wD_of_eq1 c₀ ((c₀ : ℤ) + 1) rfl, cD_of_le c₀ (c₀ : ℤ) le_rfl,
      cD_other c₀ ((c₀ : ℤ) + 1) (by omega) (by omega)]
    simp only [Count, pendC_zero, pendC_one, Bool.false_eq_true, if_true,
      if_false, true_implies, true_and]
    all_goals omega
  · rcases lt_trichotomy u ((c₀ : ℤ) + 1) with hD | hE | hF
    · omega
    · -- the idle position steps into the short region: the pin
      subst hE
      rw [wD_of_eq1 c₀ ((c₀ : ℤ) + 1) rfl, wD_of_mid c₀ ((c₀ : ℤ) + 1 + 1) (by omega) (by omega),
        cD_of_eq2 c₀ ((c₀ : ℤ) + 1 + 1) (by omega), nD_of_mid c₀ ((c₀ : ℤ) + 1) (by omega) (by omega)]
      simp only [Count, pendC_zero, pendC_one, Bool.false_eq_true, if_true,
        if_false, false_implies, and_true]
      all_goals omega
    · rcases lt_trichotomy u ((c₀ : ℤ) + 2) with hG | hH | hI
      · omega
      · -- inside the short region
        subst hH
        rw [wD_of_mid c₀ ((c₀ : ℤ) + 2) (by omega) (by omega),
          wD_of_mid c₀ ((c₀ : ℤ) + 2 + 1) (by omega) (by omega),
          cD_of_eq2 c₀ ((c₀ : ℤ) + 2) rfl, cD_other c₀ ((c₀ : ℤ) + 2 + 1) (by omega) (by omega)]
        simp only [Count, pendC_zero, if_true]
      · rcases lt_trichotomy u ((c₀ : ℤ) + 3) with hJ | hK | hL
        · omega
        · -- the short region's last position steps to the idle tail
          subst hK
          rw [wD_of_mid c₀ ((c₀ : ℤ) + 3) (by omega) (by omega),
            wD_of_ge c₀ ((c₀ : ℤ) + 3 + 1) (by omega),
            cD_other c₀ ((c₀ : ℤ) + 3) (by omega) (by omega),
            cD_other c₀ ((c₀ : ℤ) + 3 + 1) (by omega) (by omega)]
          simp only [Count, pendC_zero, pendC_one, Bool.false_eq_true, if_true,
            if_false, true_implies, and_true]
        · -- idle forever
          rw [wD_of_ge c₀ u (by omega), wD_of_ge c₀ (u + 1) (by omega),
            cD_other c₀ u (by omega) (by omega), cD_other c₀ (u + 1) (by omega) (by omega)]
          simp only [Count, pendC_one, Bool.false_eq_true, if_false,
            false_implies, and_true]

theorem gD_zero (c₀ : ℕ) : gD c₀ 0 = ⟨((0 : Qc), c₀, c₀ + 2), admZeroC c₀ (c₀ + 2)⟩ := by
  apply Subtype.ext
  show (wD c₀ 0, cD c₀ 0, nD c₀ 0) = ((0 : Qc), c₀, c₀ + 2)
  rw [wD_of_le c₀ 0 (by omega), cD_of_le c₀ 0 (by omega), nD_of_le c₀ 0 le_rfl]
  have : ((c₀ : ℤ) - 0).toNat = c₀ := by omega
  rw [this]

/-- **`chiD` holds at `0` along the witness path.** -/
theorem chiD_true (c₀ : ℕ) (τ : HistD) (hτ : ∀ t : ℤ, τ.state t = (t, gD c₀ t)) :
    PlusTruthAt MD τ 0 chiD := by
  have hobj : ∀ v, objAt (gD c₀) v = wD c₀ v := fun _ => rfl
  rw [chiD, PlusTruth.untl_iff]
  refine ⟨(c₀ : ℤ) + 1, show (0 : ℤ) < (c₀ : ℤ) + 1 by omega, ?_, ?_⟩
  · rw [PlusTruth.and_iff]
    refine ⟨?_, ?_⟩
    · rw [natom_iff_idle τ hτ, hobj, wD_of_eq1 c₀ ((c₀ : ℤ) + 1) rfl]
      exact pendC_one
    · rw [X_iff, PlusTruth.and_iff]
      refine ⟨?_, ?_⟩
      · rw [atom_iff_pend τ hτ, hobj, wD_of_mid c₀ ((c₀ : ℤ) + 1 + 1) (by omega) (by omega)]
        exact pendC_zero
      · rw [X_iff, PlusTruth.and_iff]
        refine ⟨?_, ?_⟩
        · rw [atom_iff_pend τ hτ, hobj,
            wD_of_mid c₀ ((c₀ : ℤ) + 1 + 1 + 1) (by omega) (by omega)]
          exact pendC_zero
        · rw [X_iff, natom_iff_idle τ hτ, hobj, wD_of_ge c₀ ((c₀ : ℤ) + 1 + 1 + 1 + 1) (by omega)]
          exact pendC_one
  · intro r h1 h2
    obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
    have h2' : r' < (c₀ : ℤ) + 1 := h2
    rw [atom_iff_pend τ hτ, hobj, wD_of_le c₀ r' (by omega)]
    exact pendC_zero

/-! ### No path through `(0, c₀, n')` with `c₀ + 3 ≤ n'` satisfies `chiD` at `0` -/

theorem not_chiD_of_path (g' : ℤ → LadderState Qc pendC) (hg' : IsLadderPath stepC pendC g')
    (c₀ n' : ℕ) (h0 : (g' 0).1 = ((0 : Qc), c₀, n')) (hn' : c₀ + 3 ≤ n')
    (τ' : HistD) (hτ' : ∀ t : ℤ, τ'.state t = (t, g' t)) :
    ¬ PlusTruthAt MD τ' 0 chiD := by
  intro h
  have hobj0 : objAt g' 0 = 0 := by simp [objAt, h0]
  have hc0 : cntAt g' 0 = c₀ := by simp [cntAt, h0]
  have hn0 : nxtAt g' 0 = n' := by simp [nxtAt, h0]
  have hpend0 : pendC (objAt g' 0) = true := by rw [hobj0]; exact pendC_zero
  rw [chiD, PlusTruth.untl_iff] at h
  obtain ⟨s₀, hs, hev, hgd⟩ := h
  obtain ⟨s, rfl⟩ : ∃ s : ℤ, s = s₀ := ⟨s₀, rfl⟩
  have hs' : (0 : ℤ) < s := hs
  rw [PlusTruth.and_iff] at hev
  obtain ⟨hna, hx⟩ := hev
  rw [natom_iff_idle τ' hτ'] at hna
  -- the witness is the region's first idle position, `c₀ + 1`
  have hrun : ∀ j : ℕ, j ≤ c₀ → pendC (objAt g' ((0 : ℤ) + (j : ℤ))) = true :=
    fun j hj => (cntAt_sub_of_pend g' hg' 0 hpend0 j (by rw [hc0]; exact hj)).1
  have hidle : pendC (objAt g' ((0 : ℤ) + (cntAt g' 0 : ℤ) + 1)) = false :=
    not_pend_of_count g' hg' 0 hpend0
  rw [hc0] at hidle
  have hs_eq : s = (c₀ : ℤ) + 1 := by
    rcases lt_trichotomy (s : ℤ) ((c₀ : ℤ) + 1) with hlt | heq | hgt
    · exfalso
      have := hrun s.toNat (by omega)
      rw [show (0 : ℤ) + ((s.toNat : ℕ) : ℤ) = s by omega] at this
      exact Bool.false_ne_true (hna.symm.trans this)
    · exact heq
    · exfalso
      have := (atom_iff_pend τ' hτ' _).mp
        (hgd ((c₀ : ℤ) + 1) (show (0 : ℤ) < (c₀ : ℤ) + 1 by omega) hgt)
      rw [show (0 : ℤ) + (c₀ : ℤ) + 1 = (c₀ : ℤ) + 1 by ring] at hidle
      exact Bool.false_ne_true (hidle.symm.trans this)
  -- the shape of the next idle run and region
  rw [X_iff, PlusTruth.and_iff] at hx
  obtain ⟨ha1, hx⟩ := hx
  rw [X_iff, PlusTruth.and_iff] at hx
  obtain ⟨ha2, hx⟩ := hx
  rw [X_iff, natom_iff_idle τ' hτ'] at hx
  rw [atom_iff_pend τ' hτ'] at ha1 ha2
  -- the countdowns of the short region, and the pin
  have hc2 : cntAt g' (s + 1 + 1) = 0 := (cntAt_eq_zero_of_pend_idle g' hg' (s + 1 + 1) ha2 hx).1
  have hc1 : cntAt g' (s + 1 + 1) + 1 = cntAt g' (s + 1) :=
    cntAt_succ_of_pend_pend g' hg' (s + 1) ha1 ha2
  have hpin : cntAt g' (s + 1) = nxtAt g' s := cntAt_eq_nxtAt_of_idle_pend g' hg' s hna ha1
  -- the register is `1`-Lipschitz from `0` to `s`
  have hlip := nxtAt_lipschitz g' hg' 0 (c₀ + 1)
  rw [show (0 : ℤ) + ((c₀ + 1 : ℕ) : ℤ) = s by rw [hs_eq]; push_cast; ring, hn0] at hlip
  omega

/-! ### Probe761C's own path through `(0, c₀, n₀)`: pending forever into the past, idle forever
after, constant register — a ladder path through the collision partner, for every `n₀`. -/

def wC (c₀ : ℕ) : ℤ → Qc := fun v => if v ≤ (c₀ : ℤ) then 0 else 1

def cC (c₀ : ℕ) : ℤ → ℕ := fun v => ((c₀ : ℤ) - v).toNat

theorem pendC_wC_of_le (c₀ : ℕ) (v : ℤ) (h : v ≤ (c₀ : ℤ)) : pendC (wC c₀ v) = true := by
  simp [wC, pendC, h]

theorem pendC_wC_of_gt (c₀ : ℕ) (v : ℤ) (h : ¬ (v ≤ (c₀ : ℤ))) : pendC (wC c₀ v) = false := by
  simp [wC, pendC, h]

theorem admC (c₀ : ℕ) (v : ℤ) : pendC (wC c₀ v) = false → cC c₀ v = 0 := by
  intro h
  by_cases hv : v ≤ (c₀ : ℤ)
  · exact absurd ((pendC_wC_of_le c₀ v hv).symm.trans h) (by simp)
  · simp only [cC]; omega

def gC (c₀ n₀ : ℕ) : ℤ → LadderState Qc pendC :=
  fun v => ⟨(wC c₀ v, cC c₀ v, n₀), admC c₀ v⟩

theorem gC_isPath (c₀ n₀ : ℕ) : IsLadderPath stepC pendC (gC c₀ n₀) := by
  intro u
  refine ⟨rfl, admC c₀ u, Or.inl rfl, ?_⟩
  by_cases h1 : u + 1 ≤ (c₀ : ℤ)
  · have h0 : u ≤ (c₀ : ℤ) := by omega
    rw [show (gC c₀ n₀ u).1.1 = wC c₀ u from rfl, show (gC c₀ n₀ (u + 1)).1.1 = wC c₀ (u + 1) from rfl]
    simp only [Count, pendC_wC_of_le c₀ u h0, pendC_wC_of_le c₀ (u + 1) h1, if_true]
    show cC c₀ (u + 1) + 1 = cC c₀ u
    simp only [cC]; omega
  · by_cases h0 : u ≤ (c₀ : ℤ)
    · rw [show (gC c₀ n₀ u).1.1 = wC c₀ u from rfl,
        show (gC c₀ n₀ (u + 1)).1.1 = wC c₀ (u + 1) from rfl]
      simp only [Count, pendC_wC_of_le c₀ u h0, pendC_wC_of_gt c₀ (u + 1) h1]
      refine ⟨?_, ?_⟩
      · show cC c₀ (u + 1) = 0
        simp only [cC]; omega
      · intro _
        show cC c₀ u = 0
        simp only [cC]; omega
    · rw [show (gC c₀ n₀ u).1.1 = wC c₀ u from rfl,
        show (gC c₀ n₀ (u + 1)).1.1 = wC c₀ (u + 1) from rfl]
      simp only [Count, pendC_wC_of_gt c₀ u h0, pendC_wC_of_gt c₀ (u + 1) h1]
      refine ⟨?_, ?_⟩
      · show cC c₀ (u + 1) = 0
        simp only [cC]; omega
      · intro h
        exact absurd h (by simp)

theorem gC_objAt_zero (c₀ n₀ : ℕ) : objAt (gC c₀ n₀) 0 = 0 := by
  show wC c₀ 0 = 0
  simp [wC]

theorem gC_cntAt_zero (c₀ n₀ : ℕ) : cntAt (gC c₀ n₀) 0 = c₀ := by
  show cC c₀ 0 = c₀
  simp only [cC]; omega

/-! ### The refutation -/

theorem kappa_D :
    kappa TcC TnC PC BC (c0, c0 + 2) = kappa TcC TnC PC BC (c0, c0 + 2 + (PC + 1)) := by
  have h1 : TnC ≤ c0 := le_max_right _ _
  have hB : BC = 2 := BC_eq_two
  simp only [kappa, Prod.mk.injEq, Fin.mk.injEq, true_and]
  refine ⟨by omega, by rw [Nat.add_mod_right], ?_⟩
  rw [hB]
  unfold clipIdx
  split <;> split <;> omega

/-- **THE DEPTH-`0` CELL-LEVEL OBLIGATION, AS FILED, IS FALSE** at Probe761C's object, at the
periodicity fixpoint's own outputs and the gap clip the frozen (K4) admits, for a stab-free
closure. -/
theorem cellLEZeroConstOfKappaEqPre_refuted :
    ¬ CellLEZeroConstOfKappaEqPre stepC pendC fwdC bwdC labC chiD TcC TnC PC BC := by
  intro h
  have hcell := h paramsOkPreD no_stab_in_closure_chiD 0 c0 (c0 + 2) c0 (c0 + 2 + (PC + 1))
    (admZeroC c0 (c0 + 2)) (admZeroC c0 (c0 + 2 + (PC + 1))) 0 kappa_D
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdC bwdC (gD c0) (gD_isPath c0)
  have hmem : tpOf MD chiD τ 0 ∈ cellAt MD chiD
      ((0, ⟨((0 : Qc), c0, c0 + 2), admZeroC c0 (c0 + 2)⟩) :
        (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 :=
    (mem_cellAt_ladder_iff fwdC bwdC labC chiD _ 0 _).mpr
      ⟨gD c0, τ, gD_isPath c0, gD_zero c0, hτ, rfl⟩
  rw [hcell] at hmem
  obtain ⟨g', τ', hg', hg'0, hτ', hT⟩ :=
    (mem_cellAt_ladder_iff fwdC bwdC labC chiD _ 0 _).mp hmem
  have hchi : chiD ∈ tpOf MD chiD τ' 0 := by
    rw [hT, mem_tpOf_iff]
    exact ⟨self_mem_plusSubformulaClosure chiD, chiD_true c0 τ hτ⟩
  have htrue : PlusTruthAt MD τ' 0 chiD := ((mem_tpOf_iff MD chiD τ' 0 chiD).mp hchi).2
  exact not_chiD_of_path g' hg' c0 _ (congrArg Subtype.val hg'0) (by omega) τ' hτ' htrue

/-- **Non-vacuity, witnessed on both sides**: the frozen parameter conditions at the fixpoint's
outputs, a populated collision with `n ≠ n'`, a ladder path through EACH of the two states, and
the obligation as filed refuted at the very object carrying all of it. -/
theorem exists_refuting_cell_collision :
    ∃ c n c' n' : ℕ, n ≠ n' ∧
      kappa TcC TnC PC BC (c, n) = kappa TcC TnC PC BC (c', n') ∧
      ParamsOkPre stepC pendC labC chiD TcC TnC PC BC ∧
      (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure chiD) ∧
      (∃ g : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g ∧
        objAt g 0 = 0 ∧ cntAt g 0 = c ∧ nxtAt g 0 = n) ∧
      (∃ g : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g ∧
        objAt g 0 = 0 ∧ cntAt g 0 = c' ∧ nxtAt g 0 = n') ∧
      ¬ CellLEZeroConstOfKappaEqPre stepC pendC fwdC bwdC labC chiD TcC TnC PC BC := by
  refine ⟨c0, c0 + 2, c0, c0 + 2 + (PC + 1), by omega, kappa_D, paramsOkPreD,
    no_stab_in_closure_chiD, ?_, ?_, cellLEZeroConstOfKappaEqPre_refuted⟩
  · refine ⟨gD c0, gD_isPath c0, ?_, ?_, ?_⟩
    · show wD c0 0 = 0
      exact wD_of_le c0 0 (by omega)
    · show cD c0 0 = c0
      rw [cD_of_le c0 0 (by omega)]; omega
    · show nD c0 0 = c0 + 2
      exact nD_of_le c0 0 le_rfl
  · exact ⟨gC c0 (c0 + 2 + (PC + 1)), gC_isPath _ _, gC_objAt_zero _ _, gC_cntAt_zero _ _, rfl⟩

end Probe836A

#print axioms Probe836A.gD_isPath
#print axioms Probe836A.chiD_true
#print axioms Probe836A.not_chiD_of_path
#print axioms Probe836A.kappa_D
#print axioms Probe836A.cellLEZeroConstOfKappaEqPre_refuted
#print axioms Probe836A.exists_refuting_cell_collision
#print axioms Probe836A.not_paramsOkK4_two
#print axioms Probe836A.kappa_D_dissolves
