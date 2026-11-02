/-
# THE CELL-AGREEMENT CONSTRUCTION REFUTATION

The cell-level route to the ladder's agreement on `kappa`-classes names ONE construction, and this
probe refutes it.

## What the route names

The depth-`0` cell-level agreement asks, for a `kappa`-collision between `(c, n)` and `(c', n')`,
that the stab-free part of the cell at `⟨(q, c, n), _⟩` equal the stab-free part of the cell at
`⟨(q, c', n'), _⟩`.  Read through `mem_cellAt_ladder_iff`, one inclusion asks for a LADDER PATH
through the second state realizing a type a given path through the first realizes; and the one
landed way to make two ladder paths realize the same stab-free closure type is
`tpOf_stabFree_eq_of_lab_eq`, whose hypothesis is pointwise agreement of the ATOM ROW.  The
construction is therefore `AtomPreservingCountMove`: replace a ladder path, at a chosen position,
by one through the same object state carrying any admissible counter pair there, preserving the
atom row at every position.

## What this probe compiles

The construction is REFUTED, on a two-state object with the parameter conditions discharged at the
periodicity fixpoint's own outputs:

* `pendFactorsLabC` — the object's labelling carries the pending bit as one of its atoms, so the
  pending bit factors through the atom row (`PendFactorsLab`).  Nothing excludes such a labelling:
  the realization statement quantifies over EVERY `lab : Q → Atom → Bool`.
* `atomPreservingCountMove_refutedC` — the construction fails at this object.  The mechanism is the
  library's own `cntAt_eq_of_pend_eq`: the countdown is a function of the PEND PROFILE alone, so
  moving `c` means moving the pend profile, and when the pending bit is readable in the language
  moving the pend profile means moving an atom row.  The two requirements of the construction are
  jointly unsatisfiable.
* `exists_refuting_collision` — the obligation is NON-VACUOUS ON BOTH SIDES while the construction
  is unavailable: a populated `kappa`-collision with `c ≠ c'` at parameters satisfying `ParamsOk`,
  a ladder path through EACH of the two ladder states, and the realized type on each side
  containing the atom `p` of the closure.
* `nxt_free` — the `n` HALF of the construction CLOSES at this object, for every target value of
  the next-deadline register and with every atom row preserved.  The obstruction is confined to the
  `c` coordinate, by construction rather than by silence.

## What this probe does NOT settle

It does not refute the obligation `CellLEZeroConstOfKappaEq`, and it must not be read as doing so.
A cell is a set of TYPES over all histories through a state; two ladder paths can realize the same
closure type without agreeing on a single atom row, so the obligation can be met by a construction
that does not preserve the valuation pointwise.  No such construction is stated anywhere in the
tree and none is supplied here.  It settles nothing about the filed `cellAt_const_of_kappa_eq`,
about `ladderSound`, `ladderLift` or `ladderRealized`, and nothing about the PRESENTATION, which is
untouched.  Half (i) of the truth-transport layer and the atom-valuation agreement are both
untouched and both still hold at their own hypotheses; what is compiled here is how far the second
of them can reach, not that it is wrong.  It is not a device-discrimination claim, and every
quantity named is a COUNT: no bound of any kind is asserted.

The walk exhibited here is PENDING AT EVERY PAST POSITION, which is the forward-only liveness
regime the thirteenth wired probe
(`specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`) already compiles for
this frame scheme; it is used here because it makes the next-deadline register free of every pin
(the walk has no region start at all), which is what isolates the `c` coordinate as the sole
obstruction.

## Verification

`#print axioms` on every headline theorem.  No `sorry`, no axiom, no `native_decide`, no
placeholder body and no vacuous definition anywhere in this file.

Compile: `lake env lean` on this file
(`specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`).
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe761C

/-! ### The object: one pending state, one idle state, the pending bit carried as an atom -/

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

/-! ### Seriality -/

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

/-! ### The `n` half of the construction CLOSES at this object -/

/-- **The next-deadline register is free.** For every target value, the path with that value in
place of the original realizes the IDENTICAL atom row at every position, stays a ladder path, and
sits at the same object state with the same countdown.  The `c` coordinate is therefore the whole
of the obstruction below. -/
theorem nxt_free (c₀ n₀ n₁ : ℕ) :
    IsLadderPath stepC pendC (gC c₀ n₁) ∧ objAt (gC c₀ n₁) 0 = objAt (gC c₀ n₀) 0 ∧
      cntAt (gC c₀ n₁) 0 = cntAt (gC c₀ n₀) 0 ∧ nxtAt (gC c₀ n₁) 0 = n₁ ∧
      ∀ (v : ℤ) (p : Atom), labC (objAt (gC c₀ n₁) v) p = labC (objAt (gC c₀ n₀) v) p :=
  ⟨gC_isPath c₀ n₁, rfl, rfl, rfl, fun _ _ => rfl⟩

/-! ### The parameters, discharged at the periodicity fixpoint's own outputs -/

def chiC : PlusFormula := .untl (.atom pC) (PlusFormula.neg (.atom pC))

noncomputable def TcC : ℕ := Tcof stepC pendC labC chiC
noncomputable def TnC : ℕ := Tnof stepC pendC labC chiC
noncomputable def PCp : ℕ := Pof stepC pendC labC chiC
noncomputable def BC : ℕ := Bof stepC pendC labC chiC

theorem paramsOkC : ParamsOk stepC pendC labC chiC TcC TnC PCp BC :=
  paramsOk_params stepC pendC labC chiC

theorem atom_pC_mem_closure_chiC : PlusFormula.atom pC ∈ plusSubformulaClosure chiC :=
  plusClosure_untl_right chiC (PlusFormula.neg (.atom pC)) (.atom pC)
    (self_mem_plusSubformulaClosure chiC)

theorem no_stab_in_closure_chiC :
    ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure chiC := by
  intro χ h
  simp [plusSubformulaClosure, chiC, PlusFormula.neg, PlusFormula.subformulas] at h

/-! ### The populated collision and the refutation -/

/-- The counter pair the collision starts from: at or above both thresholds, which is what
`kappa_eq_of_shift` consumes. -/
noncomputable def c0C : ℕ := max TcC TnC

theorem kappa_collisionC :
    kappa TcC TnC PCp BC (c0C + 1 * (PCp + 1), c0C + 1 * (PCp + 1))
      = kappa TcC TnC PCp BC (c0C, c0C) :=
  kappa_eq_of_shift TcC TnC PCp BC c0C c0C 1 (le_max_left _ _) (le_max_right _ _)

theorem c0C_ne_shift : c0C ≠ c0C + 1 * (PCp + 1) := by omega

/-- **THE CONSTRUCTION IS REFUTED AT THIS OBJECT.** -/
theorem atomPreservingCountMove_refutedC : ¬ AtomPreservingCountMove stepC pendC labC := by
  refine atomPreservingCountMove_refuted labC pendFactorsLabC (gC c0C c0C)
    (gC_isPath c0C c0C) 0 (c0C + 1 * (PCp + 1)) ?_ ?_
  · intro h
    rw [gC_objAt_zero c0C c0C] at h
    exact absurd (pendC_zero.symm.trans h) not_pendC_zero_false
  · rw [gC_cntAt_zero c0C c0C]
    exact c0C_ne_shift

/-! ### The obligation is non-vacuous on both sides while the construction is unavailable -/

theorem mem_cell_of_gC (c₀ n₀ : ℕ) :
    ∃ τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame,
      (∀ t : ℤ, τ.state t = (t, gC c₀ n₀ t)) ∧
      tpOf (ladderModel stepC pendC fwdC bwdC labC) chiC τ 0
        ∈ cellAt (ladderModel stepC pendC fwdC bwdC labC) chiC
            ((0, gC c₀ n₀ 0) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 ∧
      PlusFormula.atom pC ∈ tpOf (ladderModel stepC pendC fwdC bwdC labC) chiC τ 0 := by
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdC bwdC (gC c₀ n₀) (gC_isPath c₀ n₀)
  refine ⟨τ, hτ, ?_, ?_⟩
  · exact (mem_cellAt_ladder_iff fwdC bwdC labC chiC (gC c₀ n₀ 0) 0 _).mpr
      ⟨gC c₀ n₀, τ, gC_isPath c₀ n₀, rfl, hτ, rfl⟩
  · refine (atom_mem_tpOf_ladder_iff fwdC bwdC labC chiC (k := 0) (g := gC c₀ n₀) τ
      (fun t => by simpa using hτ t) 0 pC).mpr ⟨atom_pC_mem_closure_chiC, ?_⟩
    rw [gC_objAt_zero c₀ n₀]
    simp [labC]

/-- **THE WHOLE FINDING, IN ONE STATEMENT.** A populated `kappa`-collision with `c ≠ c'` at
parameters satisfying `ParamsOk`, a ladder path through EACH of the two ladder states with the
atom `p` of the closure realized on each side, and the construction the cell-level route names
REFUTED at the very object that carries all of it. -/
theorem exists_refuting_collision :
    ∃ c n c' n' : ℕ, c ≠ c' ∧
      kappa TcC TnC PCp BC (c, n) = kappa TcC TnC PCp BC (c', n') ∧
      ParamsOk stepC pendC labC chiC TcC TnC PCp BC ∧
      (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure chiC) ∧
      (∃ g : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g ∧
        objAt g 0 = 0 ∧ cntAt g 0 = c ∧ nxtAt g 0 = n) ∧
      (∃ g : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g ∧
        objAt g 0 = 0 ∧ cntAt g 0 = c' ∧ nxtAt g 0 = n') ∧
      ¬ AtomPreservingCountMove stepC pendC labC := by
  refine ⟨c0C, c0C, c0C + 1 * (PCp + 1), c0C + 1 * (PCp + 1), c0C_ne_shift,
    kappa_collisionC.symm, paramsOkC, no_stab_in_closure_chiC, ?_, ?_,
    atomPreservingCountMove_refutedC⟩
  · exact ⟨gC c0C c0C, gC_isPath c0C c0C, gC_objAt_zero _ _, gC_cntAt_zero _ _, rfl⟩
  · exact ⟨gC (c0C + 1 * (PCp + 1)) (c0C + 1 * (PCp + 1)),
      gC_isPath _ _, gC_objAt_zero _ _, gC_cntAt_zero _ _, rfl⟩

#print axioms Probe761C.pendFactorsLabC
#print axioms Probe761C.fwdC
#print axioms Probe761C.bwdC
#print axioms Probe761C.admC
#print axioms Probe761C.gC_isPath
#print axioms Probe761C.gC_zero
#print axioms Probe761C.gC_objAt_zero
#print axioms Probe761C.gC_cntAt_zero
#print axioms Probe761C.nxt_free
#print axioms Probe761C.paramsOkC
#print axioms Probe761C.atom_pC_mem_closure_chiC
#print axioms Probe761C.no_stab_in_closure_chiC
#print axioms Probe761C.kappa_collisionC
#print axioms Probe761C.c0C_ne_shift
#print axioms Probe761C.atomPreservingCountMove_refutedC
#print axioms Probe761C.mem_cell_of_gC
#print axioms Probe761C.exists_refuting_collision

end Probe761C
