/-
# PLACEHOLDER HEADER (Phase 2 writes the collection-style header here)
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe855O

/-! ## The two one-sided relaxations of the refuted two-sided schema -/

section Schematic

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- **The `▷`-shaped relaxation**: past fixed, future free. The atom row is preserved only on the
half-line at or below the compared position. -/
def PastAtomPreservingCountMove (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) : Prop :=
  ∀ (g : ℤ → LadderState Q pend) (z : ℤ) (c' n' : ℕ), IsLadderPath step pend g →
    c' ∈ Adm pend (objAt g z) →
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z = c' ∧ nxtAt g' z = n' ∧
      ∀ (v : ℤ), v ≤ z → ∀ p : Atom, lab (objAt g' v) p = lab (objAt g v) p

/-- **The `◁`-shaped relaxation**: future fixed, past free. The atom row is preserved only on the
half-line at or above the compared position. -/
def FutAtomPreservingCountMove (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) : Prop :=
  ∀ (g : ℤ → LadderState Q pend) (z : ℤ) (c' n' : ℕ), IsLadderPath step pend g →
    c' ∈ Adm pend (objAt g z) →
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z = c' ∧ nxtAt g' z = n' ∧
      ∀ (v : ℤ), z ≤ v → ∀ p : Atom, lab (objAt g' v) p = lab (objAt g v) p

/-- Both one-sided forms are genuine relaxations: the two-sided schema implies the `◁`-shaped
one, so refuting the latter is strictly stronger than the recorded refutation. -/
theorem futAtomPreservingCountMove_of_twoSided (lab : Q → Atom → Bool)
    (h : AtomPreservingCountMove step pend lab) :
    FutAtomPreservingCountMove step pend lab := by
  intro g z c' n' hg hadm
  obtain ⟨g', hg', hobj, hc, hn, hlab⟩ := h g z c' n' hg hadm
  exact ⟨g', hg', hobj, hc, hn, fun v _ p => hlab v p⟩

/-- …and the `▷`-shaped one. -/
theorem pastAtomPreservingCountMove_of_twoSided (lab : Q → Atom → Bool)
    (h : AtomPreservingCountMove step pend lab) :
    PastAtomPreservingCountMove step pend lab := by
  intro g z c' n' hg hadm
  obtain ⟨g', hg', hobj, hc, hn, hlab⟩ := h g z c' n' hg hadm
  exact ⟨g', hg', hobj, hc, hn, fun v _ p => hlab v p⟩

/-! ## The countdown rigidity is FORWARD-ONLY -/

/-- **THE COUNTDOWN IS A FUNCTION OF THE FORWARD PEND PROFILE ALONE.** The sharpening of
`cntAt_eq_of_pend_eq` that the one-sided measurement needs: two ladder paths whose objects agree
on the pending bit at every position AT OR ABOVE `u` carry the same countdown at `u`. Nothing
about the past of `u` enters, because `cntAt g u` is the distance from `u` to the last pending
position of `u`'s own region (`cntAt_sub_of_pend`, `not_pend_of_count`) and that is read entirely
forward.

This is `cntAt_eq_of_pend_eq`'s own proof at the hypothesis it actually consumes; the landed
theorem is left exactly as it stands and nothing is weakened. -/
theorem cntAt_eq_of_pend_eq_fwd (g g' : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (hg' : IsLadderPath step pend g') (u : ℤ)
    (hpend : ∀ v : ℤ, u ≤ v → pend (objAt g v) = pend (objAt g' v)) :
    cntAt g u = cntAt g' u := by
  by_cases hu : pend (objAt g u) = true
  · have hu' : pend (objAt g' u) = true := by rw [← hpend u le_rfl]; exact hu
    by_contra hne
    rcases Nat.lt_or_ge (cntAt g u) (cntAt g' u) with hlt | hge
    · have h1 := not_pend_of_count g hg u hu
      have h2 := (cntAt_sub_of_pend g' hg' u hu' (cntAt g u + 1) (by omega)).1
      rw [show u + ((cntAt g u + 1 : ℕ) : ℤ) = u + (cntAt g u : ℤ) + 1 by push_cast; ring] at h2
      rw [hpend _ (by omega)] at h1
      rw [h1] at h2
      simp at h2
    · have hlt' : cntAt g' u < cntAt g u := by omega
      have h1 := not_pend_of_count g' hg' u hu'
      have h2 := (cntAt_sub_of_pend g hg u hu (cntAt g' u + 1) (by omega)).1
      rw [show u + ((cntAt g' u + 1 : ℕ) : ℤ) = u + (cntAt g' u : ℤ) + 1 by push_cast; ring] at h2
      rw [hpend _ (by omega)] at h2
      rw [h1] at h2
      simp at h2
  · rw [Bool.not_eq_true] at hu
    have hu' : pend (objAt g' u) = false := by rw [← hpend u le_rfl]; exact hu
    rw [cntAt_eq_zero_of_idle g hg u hu, cntAt_eq_zero_of_idle g' hg' u hu']

/-- **The forward atom-row transport is countdown-rigid.** The one-sided reading of
`cntAt_eq_of_lab_eq_of_pendFactorsLab`: agreement of the atom row on the half-line at or above
`u` already forces the countdown at `u`. -/
theorem cntAt_eq_of_lab_eq_fwd_of_pendFactorsLab (lab : Q → Atom → Bool)
    (hfac : PendFactorsLab pend lab)
    (g g' : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (hg' : IsLadderPath step pend g') (u : ℤ)
    (hlab : ∀ (v : ℤ), u ≤ v → ∀ p : Atom, lab (objAt g v) p = lab (objAt g' v) p) :
    cntAt g u = cntAt g' u :=
  cntAt_eq_of_pend_eq_fwd g g' hg hg' u (fun v hv => hfac _ _ (fun p => hlab v hv p))

/-! ## The `◁`-shaped relaxation is refuted -/

/-- **THE `◁`-SHAPED ONE-SIDED COUNT MOVE IS REFUTED**, whenever the pending bit factors through
the atom row, at every ladder path and every admissible target countdown differing from the path's
own — under exactly the hypotheses the landed `atomPreservingCountMove_refuted` carries. Freeing
the whole PAST buys nothing: the obstruction is entirely forward, so the mechanism bites the
`◁`-projected form unchanged. -/
theorem futAtomPreservingCountMove_refuted (lab : Q → Atom → Bool)
    (hfac : PendFactorsLab pend lab)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ) (c' : ℕ)
    (hadm : c' ∈ Adm pend (objAt g z)) (hne : cntAt g z ≠ c') :
    ¬ FutAtomPreservingCountMove step pend lab := by
  intro hmove
  obtain ⟨g', hg', _, hc, _, hlab⟩ := hmove g z c' 0 hg hadm
  have h := cntAt_eq_of_lab_eq_fwd_of_pendFactorsLab lab hfac g' g hg' hg z hlab
  exact hne (h.symm.trans hc)

/-- **The two-sided refutation is a corollary of the one-sided one**, which is the precise sense in
which the `◁` projection removes nothing: the recorded `atomPreservingCountMove_refuted` follows
from `futAtomPreservingCountMove_refuted` through the relaxation. -/
theorem atomPreservingCountMove_refuted_via_fwd (lab : Q → Atom → Bool)
    (hfac : PendFactorsLab pend lab)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ) (c' : ℕ)
    (hadm : c' ∈ Adm pend (objAt g z)) (hne : cntAt g z ≠ c') :
    ¬ AtomPreservingCountMove step pend lab :=
  fun h => futAtomPreservingCountMove_refuted lab hfac g hg z c' hadm hne
    (futAtomPreservingCountMove_of_twoSided lab h)

end Schematic

/-! ## The object, re-derived verbatim from `ladder-cell-agreement-refutation.lean`

Probes are compiled with `lake env lean` outside the Lake module graph, so no probe can import
another; the two-state object is therefore transcribed here under this file's own namespace, and
`ladder-cell-agreement-refutation.lean` is neither edited nor re-signed.  The source probe's
seriality lemmas (`fwdC`, `bwdC`) and its parameter apparatus are omitted: they exist there to
build a model and establish cell membership, and nothing in this file's refutation needs a
frame. -/

abbrev Qc : Type := Fin 2

def pendC : Qc → Bool := fun q => decide (q = 0)

def stepC : Qc → Qc → Bool := fun _ _ => true

def pC : Atom := ⟨"p", none⟩

def labC : Qc → Atom → Bool := fun q at_ => decide (at_ = pC ∧ q = 0)

theorem pendC_zero : pendC 0 = true := by decide

theorem pendC_one : pendC 1 = false := by decide

theorem not_pendC_zero_false : ¬ ((true : Bool) = false) := by simp

/-- Admissibility of EVERY countdown at the pending state: the clause's hypothesis is false
there. -/
theorem admZeroC (d n : ℕ) : ((0 : Qc), d, n).2.1 ∈ Adm pendC ((0 : Qc), d, n).1 :=
  fun h => absurd (pendC_zero.symm.trans h) not_pendC_zero_false

theorem labC_pC (q : Qc) : labC q pC = pendC q := by
  simp [labC, pendC]

/-- **The pending bit factors through the atom row at this object**, because it IS one of the
atoms of the labelling. -/
theorem pendFactorsLabC : PendFactorsLab pendC labC :=
  pendFactorsLab_of_atom labC pC (fun q => (labC_pC q).symm)

/-! ### The walk, pending at every past position, and its forced countdown -/

def wC (c₀ : ℕ) : ℤ → Qc := fun v => if v ≤ (c₀ : ℤ) then 0 else 1

def cC (c₀ : ℕ) : ℤ → ℕ := fun v => ((c₀ : ℤ) - v).toNat

theorem pendC_wC_of_le (c₀ : ℕ) (v : ℤ) (h : v ≤ (c₀ : ℤ)) : pendC (wC c₀ v) = true := by
  simp [wC, pendC, h]

theorem pendC_wC_of_gt (c₀ : ℕ) (v : ℤ) (h : ¬ (v ≤ (c₀ : ℤ))) : pendC (wC c₀ v) = false := by
  simp [wC, pendC, h]

theorem admC (c₀ : ℕ) (v : ℤ) : pendC (wC c₀ v) = false → cC c₀ v = 0 := by
  intro h
  by_cases hv : v ≤ (c₀ : ℤ)
  · exact absurd ((pendC_wC_of_le c₀ v hv).symm.trans h) not_pendC_zero_false
  · simp only [cC]; omega

/-- **The ladder path through `⟨(0, c₀, n₀), _⟩`**: pending at every position at or below `c₀`,
idle after, with the next-deadline register CONSTANT at `n₀`.  The walk has no region start, so
the register is free of every pin and the constant is admissible. -/
def gC (c₀ n₀ : ℕ) : ℤ → LadderState Qc pendC :=
  fun v => ⟨(wC c₀ v, cC c₀ v, n₀), admC c₀ v⟩

theorem gC_objAt (c₀ n₀ : ℕ) (v : ℤ) : objAt (gC c₀ n₀) v = wC c₀ v := rfl

theorem gC_cntAt (c₀ n₀ : ℕ) (v : ℤ) : cntAt (gC c₀ n₀) v = cC c₀ v := rfl

theorem gC_nxtAt (c₀ n₀ : ℕ) (v : ℤ) : nxtAt (gC c₀ n₀) v = n₀ := rfl

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

theorem gC_zero (c₀ n₀ : ℕ) : (gC c₀ n₀ 0).1 = ((0 : Qc), c₀, n₀) := by
  simp only [gC, wC, cC]
  norm_num

theorem gC_objAt_zero (c₀ n₀ : ℕ) : objAt (gC c₀ n₀) 0 = 0 := by
  have := gC_zero c₀ n₀
  simpa [objAt] using congrArg Prod.fst this

theorem gC_cntAt_zero (c₀ n₀ : ℕ) : cntAt (gC c₀ n₀) 0 = c₀ := by
  simp only [gC_cntAt, cC]
  norm_num

end Probe855O

#print axioms Probe855O.futAtomPreservingCountMove_of_twoSided
#print axioms Probe855O.pastAtomPreservingCountMove_of_twoSided
#print axioms Probe855O.cntAt_eq_of_pend_eq_fwd
#print axioms Probe855O.cntAt_eq_of_lab_eq_fwd_of_pendFactorsLab
#print axioms Probe855O.futAtomPreservingCountMove_refuted
#print axioms Probe855O.atomPreservingCountMove_refuted_via_fwd
#print axioms Probe855O.labC_pC
#print axioms Probe855O.pendFactorsLabC
#print axioms Probe855O.admZeroC
#print axioms Probe855O.gC_isPath
#print axioms Probe855O.gC_objAt_zero
#print axioms Probe855O.gC_cntAt_zero
