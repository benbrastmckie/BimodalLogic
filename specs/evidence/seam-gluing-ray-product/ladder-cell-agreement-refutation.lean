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

/-!
# THE REFUTATION ATTEMPT ON THE FILED AGREEMENT, AND ITS VERDICT

Everything above this line refutes a CONSTRUCTION and declines to settle the obligation.  This
section is the attempt to settle it in the negative: to exhibit, at this object, two
`kappa`-equal ladder states whose cells differ, at parameters satisfying `ParamsOk`.

## The predicted mechanism

`cntAt_eq_of_pend_eq` makes the countdown a function of the pend profile alone, and
`pendFactorsLabC` makes the pending bit a readable atom.  So moving the countdown moves an atom
row, and a formula recording how long the pending bit is held should separate two ladder states
with different countdowns.

## What compiles: the mechanism is REAL

* `sepC k` is `X^(k+1) ¬p` — "the pending bit is released exactly `k + 1` steps from now" — with
  `X` written as the strict `untl` at the guard `⊥` (`truth_nxtF`).
* `sepC_mem_of_cnt_eq` (POSITIVE membership): every type of the cell at `⟨(0, k, n), _⟩` contains
  `sepC k`.
* `sepC_not_mem_of_lt_cnt` (NEGATIVE membership): no type of the cell at `⟨(0, c', n'), _⟩`
  contains `sepC k`, for every `c' > k`.
* `sepC_cell_ne`: the two cells differ.  The separating type is exhibited and both memberships
  are closed.  `stabSepC k := ⊡ (sepC k)` does the same one `⊡` up (`stabSepC_cell_ne`).

## What compiles: the mechanism NEVER REACHES A COLLISION

* `lt_Tc_of_closure_card`: under `ParamsOk` at ANY formula `φ`, the closure's cardinality is
  strictly below `Tc`.  This is (K2)'s margin conjunct and nothing else: the margin carries the
  factor `2 ^ card (closure φ)`.
* `sepC_closure_card`: the closure of `sepC k` has at least `k + 2` members — a formula that
  records a hold of length `k` carries `k` nested `X`s, each a distinct closure member.
* `sepC_no_collision`, `stabSepC_no_collision`: so every countdown the separating formula can
  record lies BELOW the clipping threshold, where `kappa`'s first coordinate `min c Tc` is
  injective.  The pair `(k, n)`, `(c', n')` that `sepC_cell_ne` separates is never a
  `kappa`-collision at parameters satisfying `ParamsOk` for `sepC k`.
* `sepC_cell_eq`: at countdowns at or above `k` the cell of `sepC k` reads `min c (k + 1)` and
  nothing else.
* `sepC_agreement_at_collision`: hence at EVERY `kappa`-collision whose countdown is at or above
  `k`, at parameters satisfying `ParamsOk` for `sepC k`, the two cells are EQUAL.  The negative
  membership goal the refutation needs — a type of one collision cell absent from the other — is
  not merely unclosed for this family: its negation compiles.

## The verdict

The filed agreement is NOT refuted by this round, and it is not proved.  It is OPEN WITH A
MEASURED ACCOUNT, and the account is the pair of facts above: recording a hold of length `k`
costs closure size at least `k`, and (K2)'s margin puts `Tc` exponentially above the closure
size, so depth outruns nothing — the thresholds are a function of the formula and they grow
faster than the formula's reach.  The step that fails is the INSTANTIATION of the separating
type at a collision, not either membership.

`RefutationTargetC` states the round's target as an object.  No theorem here proves it and no
theorem here refutes it.  What would have to be true for it to hold: a formula `φ` whose cell
at this object distinguishes two countdowns that are BOTH at least `Tc` (or two next-deadline
registers both at least `Tn`, or two gaps both clipped) for parameters satisfying `ParamsOk`
at `φ` itself — a formula that reads a countdown above `2 ^ card (closure φ)`.  The
`X`-chain family cannot, and neither can its `⊡`-prefixed sibling; nothing here says no formula
can, and the families tried here are box-free with `⊡`-depth at most one.

## What the round found for the count move

`exists_non_atom_preserving_count_move`: two ladder paths through ladder states with DIFFERENT
countdowns that realize the SAME closure type of `sepC k` while their ATOM ROWS DIFFER at a
position.  `atomPreservingCountMove_refutedC` says a count move cannot preserve the atom row;
this says it does not need to — the rows differ beyond the formula's reach, where the type
cannot see them.  That is the shape the obligation is met by at this family, and it is the
construction `## What this probe does NOT settle` above records as stated nowhere in the tree.
It is landed here at ONE formula family on ONE object, with explicit paths; it is not a general
construction.

## Verification

`#print axioms` on every headline theorem of this section.  No `sorry`, no axiom, no
`native_decide`, no placeholder body and no vacuous definition.  No theorem of this section
carries a `stab`-free premise, raises `Tc`, strengthens `ParamsOk`, or assumes a finite fibre or
finite width: `ParamsOk` appears only as a HYPOTHESIS at the formula under test, universally
quantified over its four parameters.
-/

namespace Probe761C

/-- The model of this object. -/
noncomputable abbrev MC :
    TaskModel (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame :=
  ladderModel stepC pendC fwdC bwdC labC

/-- `X ψ`, written with the strict `untl` at the guard `⊥`. -/
def nxtF (ψ : PlusFormula) : PlusFormula := .untl .bot ψ

/-- `X^k ψ`. -/
def nxtN : ℕ → PlusFormula → PlusFormula
  | 0, ψ => ψ
  | k + 1, ψ => nxtF (nxtN k ψ)

/-- **THE CANDIDATE SEPARATING FORMULA.** `X^(k+1) ¬p`: the pending bit is released exactly
`k + 1` steps from now. -/
def sepC (k : ℕ) : PlusFormula := nxtN (k + 1) (PlusFormula.neg (.atom pC))

theorem int_succ_lt_of_ne (t s : ℤ) (h : t < s) (hne : s ≠ t + 1) : t + 1 < s := by omega

theorem int_not_between (t r : ℤ) (h1 : t < r) (h2 : r < t + 1) : False := by omega

theorem truth_nxtF (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (t : ℤ) (ψ : PlusFormula) :
    PlusTruthAt MC τ t (nxtF ψ) ↔ PlusTruthAt MC τ (t + 1) ψ := by
  constructor
  · rintro ⟨s, hts, hs, hr⟩
    by_cases he : s = t + 1
    · rw [he] at hs
      exact hs
    · exact (hr (t + 1) (Int.lt_succ_self t) (int_succ_lt_of_ne t s hts he)).elim
  · intro h
    exact ⟨t + 1, Int.lt_succ_self t, h, fun r h1 h2 => (int_not_between t r h1 h2).elim⟩

theorem truth_nxtN (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (ψ : PlusFormula) (k : ℕ) :
    ∀ t : ℤ, PlusTruthAt MC τ t (nxtN k ψ) ↔ PlusTruthAt MC τ (t + (k : ℤ)) ψ := by
  induction k with
  | zero => intro t; simp [nxtN]
  | succ k ih =>
    intro t
    rw [show nxtN (k + 1) ψ = nxtF (nxtN k ψ) from rfl, truth_nxtF, ih]
    rw [show t + 1 + (k : ℤ) = t + ((k + 1 : ℕ) : ℤ) by push_cast; ring]

theorem truth_neg_pC (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (g : ℤ → LadderState Qc pendC) (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (s : ℤ) :
    PlusTruthAt MC τ s (PlusFormula.neg (.atom pC)) ↔ pendC (objAt g s) = false := by
  show (labC (τ.state s).2.1.1 pC = true → False) ↔ _
  rw [hτ s]
  show (labC (objAt g s) pC = true → False) ↔ _
  rw [labC_pC]
  cases pendC (objAt g s) <;> simp

theorem truth_sepC (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (g : ℤ → LadderState Qc pendC) (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (k : ℕ) :
    PlusTruthAt MC τ 0 (sepC k) ↔ pendC (objAt g (((k + 1 : ℕ) : ℤ))) = false := by
  rw [sepC, truth_nxtN, truth_neg_pC τ g hτ, zero_add]

/-- The ladder state `⟨(0, c, n), _⟩`. -/
def stC (c n : ℕ) : LadderState Qc pendC := ⟨((0 : Qc), c, n), admZeroC c n⟩

theorem gC_zero_eq (c n : ℕ) : gC c n 0 = stC c n := Subtype.ext (gC_zero c n)

theorem cellC_nonempty (φ : PlusFormula) (c n : ℕ) :
    ∃ T, T ∈ cellAt MC φ
      ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 := by
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdC bwdC (gC c n) (gC_isPath c n)
  exact ⟨_, (mem_cellAt_ladder_iff fwdC bwdC labC φ (stC c n) 0 _).mpr
    ⟨gC c n, τ, gC_isPath c n, gC_zero_eq c n, hτ, rfl⟩⟩

/-- **POSITIVE MEMBERSHIP.** -/
theorem sepC_mem_of_cnt_eq (k n : ℕ) (T : Finset PlusFormula)
    (hT : T ∈ cellAt MC (sepC k)
      ((0, stC k n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    sepC k ∈ T := by
  obtain ⟨g, τ, hg, hg0, hτ, rfl⟩ := (mem_cellAt_ladder_iff fwdC bwdC labC (sepC k) _ 0 T).mp hT
  rw [mem_tpOf_iff]
  refine ⟨self_mem_plusSubformulaClosure _, ?_⟩
  rw [truth_sepC τ g hτ]
  have hobj : objAt g 0 = 0 := by rw [objAt, hg0]; rfl
  have hcnt : cntAt g 0 = k := by rw [cntAt, hg0]; rfl
  have h := not_pend_of_count g hg 0 (by rw [hobj]; exact pendC_zero)
  rw [hcnt] at h
  rw [show ((k + 1 : ℕ) : ℤ) = 0 + (k : ℤ) + 1 by push_cast; ring]
  exact h

/-- **NEGATIVE MEMBERSHIP.** -/
theorem sepC_not_mem_of_lt_cnt (k c' n' : ℕ) (hlt : k < c') (T : Finset PlusFormula)
    (hT : T ∈ cellAt MC (sepC k)
      ((0, stC c' n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    sepC k ∉ T := by
  obtain ⟨g, τ, hg, hg0, hτ, rfl⟩ := (mem_cellAt_ladder_iff fwdC bwdC labC (sepC k) _ 0 T).mp hT
  rw [mem_tpOf_iff]
  rintro ⟨-, h⟩
  rw [truth_sepC τ g hτ] at h
  have hobj : objAt g 0 = 0 := by rw [objAt, hg0]; rfl
  have hcnt : cntAt g 0 = c' := by rw [cntAt, hg0]; rfl
  have h2 := (cntAt_sub_of_pend g hg 0 (by rw [hobj]; exact pendC_zero) (k + 1)
    (by rw [hcnt]; omega)).1
  rw [zero_add, h] at h2
  exact absurd h2 (by simp)

/-- **THE SEPARATION.** -/
theorem sepC_cell_ne (k n c' n' : ℕ) (hlt : k < c') :
    cellAt MC (sepC k) ((0, stC k n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
      ≠ cellAt MC (sepC k)
          ((0, stC c' n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 := by
  intro heq
  obtain ⟨T, hT⟩ := cellC_nonempty (sepC k) k n
  exact sepC_not_mem_of_lt_cnt k c' n' hlt T (heq ▸ hT) (sepC_mem_of_cnt_eq k n T hT)

/-! ### Where it stops -/

/-- The `X`-depth read off the event side. -/
def nxtDepth : PlusFormula → ℕ
  | .untl _ b => nxtDepth b + 1
  | _ => 0

theorem nxtDepth_nxtN (i : ℕ) : nxtDepth (nxtN i (PlusFormula.neg (.atom pC))) = i := by
  induction i with
  | zero => rfl
  | succ i ih => show nxtDepth (nxtN i _) + 1 = i + 1; rw [ih]

theorem nxtN_mem_closure (ψ : PlusFormula) (j : ℕ) :
    ∀ i, i ≤ j → nxtN i ψ ∈ plusSubformulaClosure (nxtN j ψ) := by
  induction j with
  | zero => intro i hi; obtain rfl : i = 0 := by omega
            exact self_mem_plusSubformulaClosure _
  | succ j ih =>
    intro i hi
    rcases Nat.lt_or_ge i (j + 1) with h | h
    · have h1 := ih i (by omega)
      have h2 : nxtN j ψ ∈ plusSubformulaClosure (nxtN (j + 1) ψ) :=
        plusClosure_untl_left _ _ _ (self_mem_plusSubformulaClosure (nxtN (j + 1) ψ))
      unfold plusSubformulaClosure at h1 h2 ⊢
      simp only [List.mem_toFinset] at h1 h2 ⊢
      exact PlusFormula.subformulas_trans h1 h2
    · obtain rfl : i = j + 1 := by omega
      exact self_mem_plusSubformulaClosure _

theorem sepC_closure_card (k : ℕ) : k + 2 ≤ (plusSubformulaClosure (sepC k)).card := by
  have h := Finset.card_le_card_of_injOn (s := Finset.range (k + 2))
    (t := plusSubformulaClosure (sepC k)) (fun i => nxtN i (PlusFormula.neg (.atom pC)))
    (fun i hi => nxtN_mem_closure _ (k + 1) i (by simp at hi; omega))
    (fun i _ j _ hij => by
      have := congrArg nxtDepth hij
      simpa [nxtDepth_nxtN] using this)
  simpa using h

theorem lt_Tc_of_closure_card (φ : PlusFormula) (m Tc Tn P B : ℕ)
    (hcard : m ≤ (plusSubformulaClosure φ).card)
    (hp : ParamsOk stepC pendC labC φ Tc Tn P B) : m < Tc := by
  have hm := hp.2.1.2.2
  have hpow := Nat.lt_two_pow_self (n := (plusSubformulaClosure φ).card)
  have hQ : Fintype.card Qc = 2 := by simp
  rw [hQ] at hm
  generalize 2 ^ (plusSubformulaClosure φ).card = X at hm hpow
  generalize (plusSubformulaClosure φ).sup stabDepth = D at hm
  have h1 : 2 * X ≤ 2 * X * (P + 1) := Nat.le_mul_of_pos_right _ (Nat.succ_pos P)
  have h2 : 2 * X * (P + 1) ≤ 2 * X * (P + 1) * (D + 1) :=
    Nat.le_mul_of_pos_right _ (Nat.succ_pos D)
  omega

theorem sepC_lt_Tc (k Tc Tn P B : ℕ) (hp : ParamsOk stepC pendC labC (sepC k) Tc Tn P B) :
    k + 2 < Tc :=
  lt_Tc_of_closure_card (sepC k) (k + 2) Tc Tn P B (sepC_closure_card k) hp

/-- **WHERE THE SEPARATING TYPE STOPS.** -/
theorem sepC_no_collision (k n c' n' Tc Tn P B : ℕ)
    (hp : ParamsOk stepC pendC labC (sepC k) Tc Tn P B)
    (hk : kappa Tc Tn P B (k, n) = kappa Tc Tn P B (c', n')) : c' = k := by
  have hlt := sepC_lt_Tc k Tc Tn P B hp
  have h1 := congrArg (fun x => (x.1 : ℕ)) hk
  simp only [kappa] at h1
  omega

/-! ### The agreement HOLDS at the separating family -/

theorem pendC_objAt_of_le (g : ℤ → LadderState Qc pendC) (hg : IsLadderPath stepC pendC g)
    (c n : ℕ) (hg0 : g 0 = stC c n) (i : ℕ) (hi : i ≤ c + 1) :
    pendC (objAt g (i : ℤ)) = decide (i ≤ c) := by
  have hobj : objAt g 0 = 0 := by rw [objAt, hg0]; rfl
  have hcnt : cntAt g 0 = c := by rw [cntAt, hg0]; rfl
  have hu : pendC (objAt g 0) = true := by rw [hobj]; exact pendC_zero
  rcases Nat.lt_or_ge c i with h | h
  · obtain rfl : i = c + 1 := by omega
    have h1 := not_pend_of_count g hg 0 hu
    rw [hcnt] at h1
    rw [show ((c + 1 : ℕ) : ℤ) = 0 + (c : ℤ) + 1 by push_cast; ring, h1]
    simp
  · have h1 := (cntAt_sub_of_pend g hg 0 hu i (by rw [hcnt]; exact h)).1
    rw [zero_add] at h1
    rw [h1]
    simp [h]

theorem mem_closure_nxtN (χ ψ : PlusFormula) (j : ℕ) :
    ψ ∈ plusSubformulaClosure (nxtN j χ) →
      ψ = .bot ∨ ψ ∈ plusSubformulaClosure χ ∨ ∃ i, i ≤ j ∧ ψ = nxtN i χ := by
  induction j with
  | zero => intro h; exact Or.inr (Or.inl h)
  | succ j ih =>
    intro h
    have h' : ψ ∈ PlusFormula.subformulas (PlusFormula.untl .bot (nxtN j χ)) := by
      unfold plusSubformulaClosure at h
      exact List.mem_toFinset.mp h
    simp only [PlusFormula.subformulas, List.mem_cons, List.mem_append, List.not_mem_nil,
      or_false] at h'
    rcases h' with rfl | h' | h'
    · exact Or.inr (Or.inr ⟨j + 1, le_rfl, rfl⟩)
    · rcases ih (by unfold plusSubformulaClosure; exact List.mem_toFinset.mpr h') with
        h1 | h1 | ⟨i, hi, rfl⟩
      · exact Or.inl h1
      · exact Or.inr (Or.inl h1)
      · exact Or.inr (Or.inr ⟨i, by omega, rfl⟩)
    · exact Or.inl h'

theorem truth_sepC_closure_iff (k c n c' n' : ℕ) (hc : k ≤ c) (hc' : k ≤ c')
    (hiff : c = k ↔ c' = k)
    (g g' : ℤ → LadderState Qc pendC) (hg : IsLadderPath stepC pendC g)
    (hg' : IsLadderPath stepC pendC g') (hg0 : g 0 = stC c n) (hg0' : g' 0 = stC c' n')
    (τ τ' : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (hτ' : ∀ t : ℤ, τ'.state t = (t, g' t))
    (ψ : PlusFormula) (hψ : ψ ∈ plusSubformulaClosure (sepC k)) :
    PlusTruthAt MC τ 0 ψ ↔ PlusTruthAt MC τ' 0 ψ := by
  have key : ∀ i : ℕ, i ≤ k + 1 → pendC (objAt g (i : ℤ)) = pendC (objAt g' (i : ℤ)) := by
    intro i hi
    rw [pendC_objAt_of_le g hg c n hg0 i (by omega),
      pendC_objAt_of_le g' hg' c' n' hg0' i (by omega)]
    have hi2 : (i ≤ c) ↔ (i ≤ c') := by omega
    simp [hi2]
  have key0 : pendC (objAt g 0) = pendC (objAt g' 0) := by simpa using key 0 (by omega)
  rcases mem_closure_nxtN _ ψ (k + 1) hψ with rfl | h | ⟨i, hi, rfl⟩
  · exact ⟨fun h => h.elim, fun h => h.elim⟩
  · have h' : ψ = PlusFormula.neg (.atom pC) ∨ ψ = .atom pC ∨ ψ = .bot := by
      simpa [plusSubformulaClosure, PlusFormula.neg, PlusFormula.subformulas] using h
    rcases h' with rfl | rfl | rfl
    · rw [truth_neg_pC τ g hτ, truth_neg_pC τ' g' hτ', key0]
    · show (labC (τ.state 0).2.1.1 pC = true) ↔ (labC (τ'.state 0).2.1.1 pC = true)
      rw [hτ 0, hτ' 0]
      show (labC (objAt g 0) pC = true) ↔ (labC (objAt g' 0) pC = true)
      rw [labC_pC, labC_pC, key0]
    · exact ⟨fun h => h.elim, fun h => h.elim⟩
  · rw [truth_nxtN, truth_nxtN, truth_neg_pC τ g hτ, truth_neg_pC τ' g' hτ', zero_add,
      key i hi]

theorem sepC_cell_subset (k c n c' n' : ℕ) (hc : k ≤ c) (hc' : k ≤ c')
    (hiff : c = k ↔ c' = k) :
    cellAt MC (sepC k) ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
      ⊆ cellAt MC (sepC k)
          ((0, stC c' n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 := by
  intro T hT
  obtain ⟨g, τ, hg, hg0, hτ, rfl⟩ := (mem_cellAt_ladder_iff fwdC bwdC labC (sepC k) _ 0 T).mp hT
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwdC bwdC (gC c' n') (gC_isPath c' n')
  refine (mem_cellAt_ladder_iff fwdC bwdC labC (sepC k) (stC c' n') 0 _).mpr
    ⟨gC c' n', τ', gC_isPath _ _, gC_zero_eq _ _, hτ', ?_⟩
  ext ψ
  rw [mem_tpOf_iff, mem_tpOf_iff]
  exact and_congr_right (fun hψ => (truth_sepC_closure_iff k c n c' n' hc hc' hiff g (gC c' n')
    hg (gC_isPath _ _) hg0 (gC_zero_eq _ _) τ τ' hτ hτ' ψ hψ).symm)

/-- **THE CELL OF THE SEPARATING FORMULA READS `min c (k + 1)` AND NOTHING ELSE**, at every
countdown at or above `k`. -/
theorem sepC_cell_eq (k c n c' n' : ℕ) (hc : k ≤ c) (hc' : k ≤ c') (hiff : c = k ↔ c' = k) :
    cellAt MC (sepC k) ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
      = cellAt MC (sepC k)
          ((0, stC c' n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 :=
  Set.Subset.antisymm (sepC_cell_subset k c n c' n' hc hc' hiff)
    (sepC_cell_subset k c' n' c n hc' hc hiff.symm)

/-- **THE FILED AGREEMENT HOLDS AT THE SEPARATING FAMILY.** -/
theorem sepC_agreement_at_collision (k c n c' n' Tc Tn P B : ℕ)
    (hp : ParamsOk stepC pendC labC (sepC k) Tc Tn P B)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) (hc : k ≤ c) :
    cellAt MC (sepC k) ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
      = cellAt MC (sepC k)
          ((0, stC c' n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 := by
  have hlt := sepC_lt_Tc k Tc Tn P B hp
  have h1 := congrArg (fun x => (x.1 : ℕ)) hk
  simp only [kappa] at h1
  exact sepC_cell_eq k c n c' n' hc (by omega) (by omega)

/-- **A NON-ATOM-PRESERVING COUNT MOVE EXISTS AT THIS OBJECT.** -/
theorem exists_non_atom_preserving_count_move (k c n c' n' : ℕ) (hc : k < c) (hc' : k < c')
    (hne : c ≠ c') :
    ∃ (g g' : ℤ → LadderState Qc pendC)
      (τ τ' : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame),
      IsLadderPath stepC pendC g ∧ IsLadderPath stepC pendC g' ∧
      g 0 = stC c n ∧ g' 0 = stC c' n' ∧
      (∀ t : ℤ, τ.state t = (t, g t)) ∧ (∀ t : ℤ, τ'.state t = (t, g' t)) ∧
      tpOf MC (sepC k) τ 0 = tpOf MC (sepC k) τ' 0 ∧
      ∃ v : ℤ, labC (objAt g v) pC ≠ labC (objAt g' v) pC := by
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdC bwdC (gC c n) (gC_isPath c n)
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwdC bwdC (gC c' n') (gC_isPath c' n')
  refine ⟨gC c n, gC c' n', τ, τ', gC_isPath _ _, gC_isPath _ _, gC_zero_eq _ _,
    gC_zero_eq _ _, hτ, hτ', ?_, ?_⟩
  · ext ψ
    rw [mem_tpOf_iff, mem_tpOf_iff]
    exact and_congr_right (fun hψ => truth_sepC_closure_iff k c n c' n' (by omega) (by omega)
      (by omega) (gC c n) (gC c' n') (gC_isPath _ _) (gC_isPath _ _) (gC_zero_eq _ _)
      (gC_zero_eq _ _) τ τ' hτ hτ' ψ hψ)
  · rcases Nat.lt_or_gt_of_ne hne with h | h
    · refine ⟨(c : ℤ) + 1, ?_⟩
      rw [labC_pC, labC_pC, gC_objAt, gC_objAt, pendC_wC_of_gt c _ (by omega),
        pendC_wC_of_le c' _ (by omega)]
      simp
    · refine ⟨(c' : ℤ) + 1, ?_⟩
      rw [labC_pC, labC_pC, gC_objAt, gC_objAt, pendC_wC_of_le c _ (by omega),
        pendC_wC_of_gt c' _ (by omega)]
      simp

/-! ### The same verdict one `⊡` up -/

/-- **THE `⊡`-BEARING CANDIDATE.** `⊡ X^(k+1) ¬p`. -/
def stabSepC (k : ℕ) : PlusFormula := PlusFormula.stab (sepC k)

theorem stabSepC_closure_card (k : ℕ) : k + 2 ≤ (plusSubformulaClosure (stabSepC k)).card := by
  refine le_trans (sepC_closure_card k) (Finset.card_le_card (fun ψ h => ?_))
  unfold plusSubformulaClosure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact PlusFormula.subformulas_trans h (PlusFormula.stab_inner_mem_subformulas _)

theorem stabSepC_mem_of_cnt_eq (k n : ℕ) (T : Finset PlusFormula)
    (hT : T ∈ cellAt MC (stabSepC k)
      ((0, stC k n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    stabSepC k ∈ T := by
  obtain ⟨τ, hs, rfl⟩ := hT
  rw [mem_tpOf_iff]
  refine ⟨self_mem_plusSubformulaClosure _, fun σ hσ => ?_⟩
  have hmem : tpOf MC (sepC k) σ 0 ∈ cellAt MC (sepC k)
      ((0, stC k n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 :=
    ⟨σ, hσ.symm.trans hs, rfl⟩
  exact ((mem_tpOf_iff _ _ _ _ _).mp (sepC_mem_of_cnt_eq k n _ hmem)).2

theorem stabSepC_not_mem_of_lt_cnt (k c' n' : ℕ) (hlt : k < c') (T : Finset PlusFormula)
    (hT : T ∈ cellAt MC (stabSepC k)
      ((0, stC c' n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    stabSepC k ∉ T := by
  obtain ⟨τ, hs, rfl⟩ := hT
  rw [mem_tpOf_iff]
  rintro ⟨-, h⟩
  have hmem : tpOf MC (sepC k) τ 0 ∈ cellAt MC (sepC k)
      ((0, stC c' n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 := ⟨τ, hs, rfl⟩
  exact sepC_not_mem_of_lt_cnt k c' n' hlt _ hmem
    ((mem_tpOf_iff _ _ _ _ _).mpr ⟨self_mem_plusSubformulaClosure _,
      h τ rfl⟩)

theorem stabSepC_cell_ne (k n c' n' : ℕ) (hlt : k < c') :
    cellAt MC (stabSepC k) ((0, stC k n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
      ≠ cellAt MC (stabSepC k)
          ((0, stC c' n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 := by
  intro heq
  obtain ⟨T, hT⟩ := cellC_nonempty (stabSepC k) k n
  exact stabSepC_not_mem_of_lt_cnt k c' n' hlt T (heq ▸ hT) (stabSepC_mem_of_cnt_eq k n T hT)

theorem stabSepC_no_collision (k n c' n' Tc Tn P B : ℕ)
    (hp : ParamsOk stepC pendC labC (stabSepC k) Tc Tn P B)
    (hk : kappa Tc Tn P B (k, n) = kappa Tc Tn P B (c', n')) : c' = k := by
  have hlt := lt_Tc_of_closure_card (stabSepC k) (k + 2) Tc Tn P B (stabSepC_closure_card k) hp
  have h1 := congrArg (fun x => (x.1 : ℕ)) hk
  simp only [kappa] at h1
  omega

/-! ### The round's target, as an object, and the verdict in one statement -/

/-- **THE TARGET OF THE REFUTATION ATTEMPT**, stated and NOT decided: a formula, parameters
satisfying `ParamsOk` at it, and a `kappa`-collision between two countdown/register pairs at the
pending state of this object whose cells differ.  A proof of this proposition would refute the
filed agreement; nothing in this file proves it or refutes it. -/
def RefutationTargetC : Prop :=
  ∃ (φ : PlusFormula) (Tc Tn P B c n c' n' : ℕ),
    ParamsOk stepC pendC labC φ Tc Tn P B ∧
    kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') ∧
    cellAt MC φ ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
      ≠ cellAt MC φ ((0, stC c' n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0

/-- **Every witness of the target sits above its own formula's closure size**: the parameter
`Tc` of any witness exceeds the cardinality of the witness formula's closure. -/
theorem refutationTargetC_margin (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk stepC pendC labC φ Tc Tn P B) : (plusSubformulaClosure φ).card < Tc :=
  lt_Tc_of_closure_card φ _ Tc Tn P B le_rfl hp

/-- **THE VERDICT OF THE ROUND, IN ONE STATEMENT.** For every hold length `k`: the separating
formula separates the countdown `k` from every larger one; at parameters satisfying `ParamsOk`
for it, it AGREES across every `kappa`-collision whose countdown is at or above `k`; and its
`⊡`-prefixed sibling separates the same pairs and likewise meets no collision at `k`. -/
theorem round_one_verdict (k : ℕ) :
    (∀ n c' n' : ℕ, k < c' →
      cellAt MC (sepC k) ((0, stC k n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
        ≠ cellAt MC (sepC k)
            ((0, stC c' n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) ∧
    (∀ c n c' n' Tc Tn P B : ℕ, ParamsOk stepC pendC labC (sepC k) Tc Tn P B →
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') → k ≤ c →
      cellAt MC (sepC k) ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
        = cellAt MC (sepC k)
            ((0, stC c' n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) ∧
    (∀ n c' n' : ℕ, k < c' →
      cellAt MC (stabSepC k)
          ((0, stC k n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
        ≠ cellAt MC (stabSepC k)
            ((0, stC c' n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) ∧
    (∀ n c' n' Tc Tn P B : ℕ, ParamsOk stepC pendC labC (stabSepC k) Tc Tn P B →
      kappa Tc Tn P B (k, n) = kappa Tc Tn P B (c', n') → c' = k) :=
  ⟨fun n c' n' h => sepC_cell_ne k n c' n' h,
   fun c n c' n' Tc Tn P B hp hk hc => sepC_agreement_at_collision k c n c' n' Tc Tn P B hp hk hc,
   fun n c' n' h => stabSepC_cell_ne k n c' n' h,
   fun n c' n' Tc Tn P B hp hk => stabSepC_no_collision k n c' n' Tc Tn P B hp hk⟩

#print axioms Probe761C.truth_nxtF
#print axioms Probe761C.sepC_mem_of_cnt_eq
#print axioms Probe761C.sepC_not_mem_of_lt_cnt
#print axioms Probe761C.sepC_cell_ne
#print axioms Probe761C.sepC_closure_card
#print axioms Probe761C.lt_Tc_of_closure_card
#print axioms Probe761C.sepC_no_collision
#print axioms Probe761C.sepC_cell_eq
#print axioms Probe761C.sepC_agreement_at_collision
#print axioms Probe761C.exists_non_atom_preserving_count_move
#print axioms Probe761C.stabSepC_cell_ne
#print axioms Probe761C.stabSepC_no_collision
#print axioms Probe761C.refutationTargetC_margin
#print axioms Probe761C.round_one_verdict

end Probe761C

/-!
# THE COUNT MOVE THE AGREEMENT NEEDS: ITS TYPE, A TRANSFER PRINCIPLE FOR IT, AND WHERE IT REFUSES

The section above closed the refutation attempt OPEN WITH A MEASURED ACCOUNT, which routes the
work to the construction `## What this probe does NOT settle` records as stated nowhere:

> "two ladder paths can realize the same closure type without agreeing on a single atom row, so
> the obligation can be met by a construction that does not preserve the valuation pointwise.
> No such construction is stated anywhere in the tree and none is supplied here."

This section STATES that construction, proves it is exactly the diagonal agreement, lands the
transfer principle a non-positionwise construction has to go through — `⊡` and `□` clauses
included — closes the part of the move that a slide inside a pending run delivers, and compiles
where the rest refuses.  **It does not build the general construction, and the filed agreement
stays OPEN.**

## The construction's type

* `TypePreservingCountMove`: every ladder path through one state of a `kappa`-collision is
  answered by a ladder path through the other realizing the SAME closure type.  No atom-row
  clause.
* `typePreservingCountMove_iff_cellAt_const`: the move at a formula and four parameters is
  EQUIVALENT to the equality of the two cells at every collision (diagonal world state).  The
  move is the agreement, read on ladder paths; nothing is lost.
* `countMove_rows_differ`: when the pending bit factors through the atom row, two ladder paths
  with different countdowns at a position disagree on an atom somewhere.  Non-atom-preservation
  is forced, not chosen.
* `CountMoveTargetC`: the move at this object, at every formula and every `ParamsOk` tuple,
  stated as a proposition and NOT decided.

## The transfer principle

`no_positionwise_lift` and the atom-row rigidity above both say the same thing: the two paths of
a count move cannot be compared position by position.  What replaces positionwise comparison is
a depth-indexed back-and-forth:

* `TransferSys`: a family of relations between points `(τ, t)`, `(τ', t')` with one
  back-and-forth clause per operator.  The temporal clauses match a witness by a witness and each
  intermediate point of the answer by SOME intermediate point of the question.  The `⊡` clauses
  match a history through one state by a history through the other — at level `k + 1` they ARE
  the level-`k` agreement of the two cells.
* `truth_iff_of_transferSys`: related points satisfy the same formulas up to the level's operator
  depth, for the whole language when the system carries the `⊡`/`□` clauses.
* `typePreservingCountMove_of_transferSys`: the count move follows from ANY whole-language
  transfer system that links the two states of each collision at the closure's operator depth.
  This is the interface the construction is owed: a system and one link.
* `shiftR_transferSys`: the time shift is a whole-language transfer system — the `⊡` clauses are
  dischargeable.

## What the slide delivers

* `slideR_transferSys`, `tpOf_eq_of_homStretch`: inside a stretch of one history carrying one
  atom row, the closure type is the same at any two times at least `sup opDepth` from both ends —
  on closures with no `⊡` and no `□` member.
* `slide_count_move_C`: at this object, for EVERY ladder path (no explicit walk) pending far
  enough back, the type realized at countdown `c` is the type the same history realizes `d` steps
  earlier at countdown `c + d`.  This closes the FUTURE half of the move — the exit position
  moves and the type does not — for the `⊡`-free, `□`-free fragment.  **It is a fragment
  instance, labelled as one; it is NOT the construction**, which may carry no `⊡`-free premise.
* `slide_closure_transferSys`, `tpOf_eq_of_linkedStretch`: the same slide for the WHOLE language,
  conditional on exactly one thing — `StateLinked`: the states of the stretch answer each other's
  histories one level down.  That is the induction step of a slide-based count move with its `⊡`
  clause written out, and it names what a pending run owes: the lower-level cell agreement of the
  states `(q, c - i, n_i)` ALONG the run.
* `tpOf_eq_of_constStretch`: where the link is free — a history resting in one world state, in
  any frame over `ℤ` — the slide holds unconditionally for every formula.  It does not apply on
  the ladder frame (a world state there carries its time, and a pending run changes the countdown
  at every step); it is recorded to show the closure is not vacuous.

## Where the construction refuses

* `cnt_cap_of_row` (THE CAP): for a pending position `z` whose region was entered from the idle
  position `e`, with the previous region `(e₀, x₀]`,
  `cntAt g z + (z - e - 1) ≤ (x₀ - e₀ - 1) + (e - e₀)`.
  The entry register of a region is at most the previous region's length less one plus the steps
  between the two entries.  Every quantity on the right is a position of the pending ROW.
* `exists_past_row_change_of_cap_lt` (THE REFUSING COORDINATE): a ladder path whose countdown at
  `z` exceeds the cap another path's row sets there disagrees with that row inside `[e₀, z]`.
  A count move that RAISES a countdown past the cap must rewrite the PAST row, two regions deep.
* `tight_state_refuses_C` (THE PAIRS): for every `m` a ladder path through countdown `2 m + 2`
  attaining the cap, so that every path through a larger countdown at that position rewrites the
  window `[0, m + 3]`.  The countdown is unbounded in `m`, so these are collisions of every
  counter quotient.

## The account

The count move has two halves.  The FUTURE half (the exit moves) is delivered by the slide once
the path is deep in its run.  The PAST half is owed whenever the cap binds: the previous region
must be lengthened, which raises ITS entry register and can bind the cap one region earlier — the
cascade.  It bottoms out, on a history whose regions double from a short one, at a region too
short to lengthen invisibly; there the only move left is to insert a whole region, whose
type-preservation is a transfer system on the SEQUENCE of regions that is not built here.
Independently, at a closure carrying `⊡` the slide owes `StateLinked`, i.e. the agreement of
states with the SAME countdown and different registers along the run, which again needs later
regions reshaped (their exit-register windows differ).  Both debts are the same object: a
transfer system relating two histories whose region lengths differ at infinitely many regions.
It is stated nowhere in the tree; `TransferSys` is the form it would take.

## Verification

`#print axioms` on every headline theorem of this section.  No `sorry`, no axiom, no
`native_decide`, no placeholder body and no vacuous definition.  `Tc` is not raised and
`ParamsOk` is not strengthened; no finite-fibre or finite-width assumption appears.  The `⊡`-free
premise appears ONLY on the three fragment-instance theorems named above
(`tpOf_eq_of_homStretch`, `slide_count_move_C`, and `allowed_of_stabBoxFree` that serves them),
never on the construction's type, the transfer theorem, the slide closure or the cap.
-/

namespace Probe761C

/-! ### The construction's type -/

section MoveType

variable {Q : Type} [Finite Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE CONSTRUCTION'S TYPE.** The count move the agreement needs, with NO clause about atom
rows: every ladder path through one state of a `kappa`-collision is answered by a ladder path
through the other state realizing the SAME closure type at the compared position.  The two paths,
the common closure type and the two states are all it names; where the rows differ is a
consequence (`countMove_rows_differ`), not a clause. -/
def TypePreservingCountMove
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  ∀ (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q),
    kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
    ∀ (g : ℤ → LadderState Q pend)
      (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
      IsLadderPath step pend g → g 0 = (⟨(q, c, n), h⟩ : LadderState Q pend) →
      (∀ t : ℤ, τ.state t = (t, g t)) →
      ∃ (g' : ℤ → LadderState Q pend)
        (τ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        IsLadderPath step pend g' ∧ g' 0 = (⟨(q, c', n'), h'⟩ : LadderState Q pend) ∧
        (∀ t : ℤ, τ'.state t = (t, g' t)) ∧
        tpOf (ladderModel step pend fwd bwd lab) φ τ' 0
          = tpOf (ladderModel step pend fwd bwd lab) φ τ 0

/-- **THE CONSTRUCTION IS EXACTLY THE DIAGONAL AGREEMENT.** The count move holds at a formula and
four parameters iff the two cells of every `kappa`-collision are equal at the diagonal world state
`(0, x)`, time `0`.  Nothing is lost and nothing is gained by passing to paths: the move is the
agreement, read on ladder paths. -/
theorem typePreservingCountMove_iff_cellAt_const
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) :
    TypePreservingCountMove fwd bwd lab φ Tc Tn P B ↔
      ∀ (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q),
        kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
        cellAt (ladderModel step pend fwd bwd lab) φ
            ((0, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) 0
          = cellAt (ladderModel step pend fwd bwd lab) φ
            ((0, ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) 0 := by
  constructor
  · intro hmove q c n c' n' h h' hk
    apply Set.Subset.antisymm
    · intro T hT
      obtain ⟨g, τ, hg, hg0, hτ, rfl⟩ := (mem_cellAt_ladder_iff fwd bwd lab φ _ 0 T).mp hT
      obtain ⟨g', τ', hg', hg0', hτ', htp⟩ := hmove q c n c' n' h h' hk g τ hg hg0 hτ
      exact (mem_cellAt_ladder_iff fwd bwd lab φ _ 0 _).mpr ⟨g', τ', hg', hg0', hτ', htp⟩
    · intro T hT
      obtain ⟨g, τ, hg, hg0, hτ, rfl⟩ := (mem_cellAt_ladder_iff fwd bwd lab φ _ 0 T).mp hT
      obtain ⟨g', τ', hg', hg0', hτ', htp⟩ := hmove q c' n' c n h' h hk.symm g τ hg hg0 hτ
      exact (mem_cellAt_ladder_iff fwd bwd lab φ _ 0 _).mpr ⟨g', τ', hg', hg0', hτ', htp⟩
  · intro hcell q c n c' n' h h' hk g τ hg hg0 hτ
    have hmem : tpOf (ladderModel step pend fwd bwd lab) φ τ 0 ∈
        cellAt (ladderModel step pend fwd bwd lab) φ
          ((0, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) 0 :=
      (mem_cellAt_ladder_iff fwd bwd lab φ _ 0 _).mpr ⟨g, τ, hg, hg0, hτ, rfl⟩
    rw [hcell q c n c' n' h h' hk] at hmem
    obtain ⟨g', τ', hg', hg0', hτ', htp⟩ := (mem_cellAt_ladder_iff fwd bwd lab φ _ 0 _).mp hmem
    exact ⟨g', τ', hg', hg0', hτ', htp⟩

omit [Finite Q] [Nonempty Q] in
/-- **THE ROWS MUST DIFFER.** When the pending bit factors through the atom row, two ladder paths
carrying different countdowns at one position disagree on some atom at some position.  So every
instance of the count move at a collision that moves the countdown is non-atom-preserving by
force, not by choice. -/
theorem countMove_rows_differ (lab : Q → Atom → Bool) (hfac : PendFactorsLab pend lab)
    (g g' : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (hg' : IsLadderPath step pend g') (z : ℤ)
    (hne : cntAt g z ≠ cntAt g' z) :
    ∃ (v : ℤ) (p : Atom), lab (objAt g v) p ≠ lab (objAt g' v) p := by
  by_contra hno
  push Not at hno
  exact hne (cntAt_eq_of_lab_eq_of_pendFactorsLab lab hfac g g' hg hg' hno z)

end MoveType

/-- **THE TARGET OF THE CONSTRUCTION AT THIS OBJECT**, stated and NOT decided: the count move at
every formula and every parameter tuple satisfying `ParamsOk` for it.  Nothing in this file proves
it or refutes it; it is the diagonal form of the filed agreement at this object
(`typePreservingCountMove_iff_cellAt_const`). -/
def CountMoveTargetC : Prop :=
  ∀ (φ : PlusFormula) (Tc Tn P B : ℕ), ParamsOk stepC pendC labC φ Tc Tn P B →
    TypePreservingCountMove fwdC bwdC labC φ Tc Tn P B

/-! ### A transfer principle that is not positionwise -/

section Game

variable {F : TaskFrame}

/-- The operator-nesting depth: every modal and temporal operator counts one. -/
def opDepth : PlusFormula → ℕ
  | .atom _ => 0
  | .bot => 0
  | .imp a b => max (opDepth a) (opDepth b)
  | .box a => opDepth a + 1
  | .untl a b => max (opDepth a) (opDepth b) + 1
  | .snce a b => max (opDepth a) (opDepth b) + 1
  | .stab a => opDepth a + 1

/-- The fragment cut out by two switches: `□` is admitted iff `ub`, `⊡` iff `us`. -/
def Allowed (ub us : Prop) : PlusFormula → Prop
  | .atom _ => True
  | .bot => True
  | .imp a b => Allowed ub us a ∧ Allowed ub us b
  | .box a => ub ∧ Allowed ub us a
  | .untl a b => Allowed ub us a ∧ Allowed ub us b
  | .snce a b => Allowed ub us a ∧ Allowed ub us b
  | .stab a => us ∧ Allowed ub us a

/-- **A DEPTH-INDEXED TRANSFER SYSTEM.** A family of relations between points `(τ, t)` and
`(τ', t')` of one model, with a back-and-forth clause per operator.  The temporal clauses match a
witness on one side by a witness on the other and every intermediate point of the answer by SOME
intermediate point of the question — the correspondence is not a function of position, and no
position is required to keep its own partner.  The `⊡` clauses match a history through one state
by a history through the other: at level `k + 1` they are the level-`k` agreement of the two
cells, which is how the cell enters its own transport. -/
structure TransferSys (M : TaskModel F) (ub us : Prop)
    (R : ℕ → WorldHistory F → F.Duration → WorldHistory F → F.Duration → Prop) : Prop where
  atom : ∀ k τ t τ' t', R k τ t τ' t' →
    ∀ p : Atom, M.valuation (τ.state t) p ↔ M.valuation (τ'.state t') p
  untl_forth : ∀ k τ t τ' t', R (k + 1) τ t τ' t' → ∀ s, t < s →
    ∃ s', t' < s' ∧ R k τ s τ' s' ∧
      ∀ r', t' < r' → r' < s' → ∃ r, t < r ∧ r < s ∧ R k τ r τ' r'
  untl_back : ∀ k τ t τ' t', R (k + 1) τ t τ' t' → ∀ s', t' < s' →
    ∃ s, t < s ∧ R k τ s τ' s' ∧
      ∀ r, t < r → r < s → ∃ r', t' < r' ∧ r' < s' ∧ R k τ r τ' r'
  snce_forth : ∀ k τ t τ' t', R (k + 1) τ t τ' t' → ∀ s, s < t →
    ∃ s', s' < t' ∧ R k τ s τ' s' ∧
      ∀ r', s' < r' → r' < t' → ∃ r, s < r ∧ r < t ∧ R k τ r τ' r'
  snce_back : ∀ k τ t τ' t', R (k + 1) τ t τ' t' → ∀ s', s' < t' →
    ∃ s, s < t ∧ R k τ s τ' s' ∧
      ∀ r, s < r → r < t → ∃ r', s' < r' ∧ r' < t' ∧ R k τ r τ' r'
  box_forth : ub → ∀ k τ t τ' t', R (k + 1) τ t τ' t' →
    ∀ σ : WorldHistory F, ∃ σ' : WorldHistory F, R k σ t σ' t'
  box_back : ub → ∀ k τ t τ' t', R (k + 1) τ t τ' t' →
    ∀ σ' : WorldHistory F, ∃ σ : WorldHistory F, R k σ t σ' t'
  stab_forth : us → ∀ k τ t τ' t', R (k + 1) τ t τ' t' →
    ∀ σ : WorldHistory F, τ.state t = σ.state t →
      ∃ σ' : WorldHistory F, τ'.state t' = σ'.state t' ∧ R k σ t σ' t'
  stab_back : us → ∀ k τ t τ' t', R (k + 1) τ t τ' t' →
    ∀ σ' : WorldHistory F, τ'.state t' = σ'.state t' →
      ∃ σ : WorldHistory F, τ.state t = σ.state t ∧ R k σ t σ' t'

/-- **THE TRANSFER THEOREM.** Two points related at level `k` by a transfer system satisfy the
same formulas of the system's fragment of operator depth at most `k` — `⊡` and `□` included when
the system carries their clauses. -/
theorem truth_iff_of_transferSys (M : TaskModel F) (ub us : Prop)
    (R : ℕ → WorldHistory F → F.Duration → WorldHistory F → F.Duration → Prop)
    (hR : TransferSys M ub us R) :
    ∀ (φ : PlusFormula) (k : ℕ) (τ : WorldHistory F) (t : F.Duration)
      (τ' : WorldHistory F) (t' : F.Duration),
      Allowed ub us φ → opDepth φ ≤ k → R k τ t τ' t' →
      (PlusTruthAt M τ t φ ↔ PlusTruthAt M τ' t' φ) := by
  intro φ
  induction φ with
  | atom p => intro k τ t τ' t' _ _ h; exact hR.atom k τ t τ' t' h p
  | bot => intro k τ t τ' t' _ _ _; exact Iff.rfl
  | imp a b iha ihb =>
      intro k τ t τ' t' hal hd h
      have ha := iha k τ t τ' t' hal.1 (le_trans (le_max_left _ _) hd) h
      have hb := ihb k τ t τ' t' hal.2 (le_trans (le_max_right _ _) hd) h
      exact ⟨fun hi x => hb.mp (hi (ha.mpr x)), fun hi x => hb.mpr (hi (ha.mp x))⟩
  | box a iha =>
      intro k τ t τ' t' hal hd h
      obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by simp only [opDepth] at hd; omega⟩
      have hdj : opDepth a ≤ j := by simp only [opDepth] at hd; omega
      constructor
      · intro hb σ'
        obtain ⟨σ, hσ⟩ := hR.box_back hal.1 j τ t τ' t' h σ'
        exact (iha j σ t σ' t' hal.2 hdj hσ).mp (hb σ)
      · intro hb σ
        obtain ⟨σ', hσ⟩ := hR.box_forth hal.1 j τ t τ' t' h σ
        exact (iha j σ t σ' t' hal.2 hdj hσ).mpr (hb σ')
  | untl a b iha ihb =>
      intro k τ t τ' t' hal hd h
      obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by simp only [opDepth] at hd; omega⟩
      have hda : opDepth a ≤ j := by simp only [opDepth] at hd; omega
      have hdb : opDepth b ≤ j := by simp only [opDepth] at hd; omega
      constructor
      · rintro ⟨s, hts, hs, hr⟩
        obtain ⟨s', hts', hss, hbetween⟩ := hR.untl_forth j τ t τ' t' h s hts
        refine ⟨s', hts', (ihb j τ s τ' s' hal.2 hdb hss).mp hs, fun r' h1 h2 => ?_⟩
        obtain ⟨r, hr1, hr2, hrr⟩ := hbetween r' h1 h2
        exact (iha j τ r τ' r' hal.1 hda hrr).mp (hr r hr1 hr2)
      · rintro ⟨s', hts', hs, hr⟩
        obtain ⟨s, hts, hss, hbetween⟩ := hR.untl_back j τ t τ' t' h s' hts'
        refine ⟨s, hts, (ihb j τ s τ' s' hal.2 hdb hss).mpr hs, fun r h1 h2 => ?_⟩
        obtain ⟨r', hr1, hr2, hrr⟩ := hbetween r h1 h2
        exact (iha j τ r τ' r' hal.1 hda hrr).mpr (hr r' hr1 hr2)
  | snce a b iha ihb =>
      intro k τ t τ' t' hal hd h
      obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by simp only [opDepth] at hd; omega⟩
      have hda : opDepth a ≤ j := by simp only [opDepth] at hd; omega
      have hdb : opDepth b ≤ j := by simp only [opDepth] at hd; omega
      constructor
      · rintro ⟨s, hts, hs, hr⟩
        obtain ⟨s', hts', hss, hbetween⟩ := hR.snce_forth j τ t τ' t' h s hts
        refine ⟨s', hts', (ihb j τ s τ' s' hal.2 hdb hss).mp hs, fun r' h1 h2 => ?_⟩
        obtain ⟨r, hr1, hr2, hrr⟩ := hbetween r' h1 h2
        exact (iha j τ r τ' r' hal.1 hda hrr).mp (hr r hr1 hr2)
      · rintro ⟨s', hts', hs, hr⟩
        obtain ⟨s, hts, hss, hbetween⟩ := hR.snce_back j τ t τ' t' h s' hts'
        refine ⟨s, hts, (ihb j τ s τ' s' hal.2 hdb hss).mpr hs, fun r h1 h2 => ?_⟩
        obtain ⟨r', hr1, hr2, hrr⟩ := hbetween r h1 h2
        exact (iha j τ r τ' r' hal.1 hda hrr).mpr (hr r' hr1 hr2)
  | stab a iha =>
      intro k τ t τ' t' hal hd h
      obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by simp only [opDepth] at hd; omega⟩
      have hdj : opDepth a ≤ j := by simp only [opDepth] at hd; omega
      constructor
      · intro hb σ' hst
        obtain ⟨σ, hst0, hσ⟩ := hR.stab_back hal.1 j τ t τ' t' h σ' hst
        exact (iha j σ t σ' t' hal.2 hdj hσ).mp (hb σ hst0)
      · intro hb σ hst
        obtain ⟨σ', hst0, hσ⟩ := hR.stab_forth hal.1 j τ t τ' t' h σ hst
        exact (iha j σ t σ' t' hal.2 hdj hσ).mpr (hb σ' hst0)

/-- The `⊡`-free and `□`-free fragment is the fragment with both switches off. -/
theorem allowed_of_stabBoxFree : ∀ ψ : PlusFormula, StabBoxFree ψ → Allowed False False ψ := by
  intro ψ
  induction ψ with
  | atom p => intro _; exact trivial
  | bot => intro _; exact trivial
  | imp a b iha ihb => intro h; exact ⟨iha h.1, ihb h.2⟩
  | box a _ => intro h; exact h.elim
  | untl a b iha ihb => intro h; exact ⟨iha h.1, ihb h.2⟩
  | snce a b iha ihb => intro h; exact ⟨iha h.1, ihb h.2⟩
  | stab a _ => intro h; exact h.elim

/-- Every formula is in the fragment with both switches on. -/
theorem allowed_true : ∀ ψ : PlusFormula, Allowed True True ψ := by
  intro ψ
  induction ψ with
  | atom p => exact trivial
  | bot => exact trivial
  | imp a b iha ihb => exact ⟨iha, ihb⟩
  | box a ih => exact ⟨trivial, ih⟩
  | untl a b iha ihb => exact ⟨iha, ihb⟩
  | snce a b iha ihb => exact ⟨iha, ihb⟩
  | stab a ih => exact ⟨trivial, ih⟩

/-- **THE TYPE FOLLOWS THE RELATION.** Two points related by a whole-language transfer system at
the closure's operator depth realize the same closure type. -/
theorem tpOf_eq_of_transferSys {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (R : ℕ → WorldHistory F.toTaskFrame → ℤ → WorldHistory F.toTaskFrame → ℤ → Prop)
    (hR : TransferSys M True True R) (φ : PlusFormula)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (τ' : WorldHistory F.toTaskFrame) (t' : ℤ)
    (h : R ((plusSubformulaClosure φ).sup opDepth) τ t τ' t') :
    tpOf M φ τ t = tpOf M φ τ' t' := by
  ext ψ
  rw [mem_tpOf_iff, mem_tpOf_iff]
  exact and_congr_right (fun hψ => truth_iff_of_transferSys M True True R hR ψ
    ((plusSubformulaClosure φ).sup opDepth) τ t τ' t' (allowed_true ψ) (Finset.le_sup hψ) h)

end Game

/-! ### An instance carrying the `⊡` and `□` clauses: the time shift -/

section Shift

variable {F : FrameOver intOrder}

/-- The shift relation: `τ'` is `τ` read `Δ` later, and the two times differ by `Δ`. -/
def ShiftR (_k : ℕ) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (τ' : WorldHistory F.toTaskFrame) (t' : ℤ) : Prop :=
  ∃ Δ : ℤ, t = t' + Δ ∧ ∀ s : ℤ, τ'.state s = τ.state (s + Δ)

theorem shiftR_untl_forth (k : ℕ) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (τ' : WorldHistory F.toTaskFrame) (t' : ℤ) (h : ShiftR (F := F) (k + 1) τ t τ' t')
    (s : ℤ) (hts : t < s) :
    ∃ s' : ℤ, t' < s' ∧ ShiftR (F := F) k τ s τ' s' ∧
      ∀ r' : ℤ, t' < r' → r' < s' → ∃ r : ℤ, t < r ∧ r < s ∧ ShiftR (F := F) k τ r τ' r' := by
  obtain ⟨Δ, rfl, h⟩ := h
  exact ⟨s - Δ, by omega, ⟨Δ, by omega, h⟩,
    fun r' h1 h2 => ⟨r' + Δ, by omega, by omega, ⟨Δ, rfl, h⟩⟩⟩

theorem shiftR_untl_back (k : ℕ) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (τ' : WorldHistory F.toTaskFrame) (t' : ℤ) (h : ShiftR (F := F) (k + 1) τ t τ' t')
    (s' : ℤ) (hts' : t' < s') :
    ∃ s : ℤ, t < s ∧ ShiftR (F := F) k τ s τ' s' ∧
      ∀ r : ℤ, t < r → r < s → ∃ r' : ℤ, t' < r' ∧ r' < s' ∧ ShiftR (F := F) k τ r τ' r' := by
  obtain ⟨Δ, rfl, h⟩ := h
  exact ⟨s' + Δ, by omega, ⟨Δ, rfl, h⟩,
    fun r h1 h2 => ⟨r - Δ, by omega, by omega, ⟨Δ, by omega, h⟩⟩⟩

theorem shiftR_snce_forth (k : ℕ) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (τ' : WorldHistory F.toTaskFrame) (t' : ℤ) (h : ShiftR (F := F) (k + 1) τ t τ' t')
    (s : ℤ) (hts : s < t) :
    ∃ s' : ℤ, s' < t' ∧ ShiftR (F := F) k τ s τ' s' ∧
      ∀ r' : ℤ, s' < r' → r' < t' → ∃ r : ℤ, s < r ∧ r < t ∧ ShiftR (F := F) k τ r τ' r' := by
  obtain ⟨Δ, rfl, h⟩ := h
  exact ⟨s - Δ, by omega, ⟨Δ, by omega, h⟩,
    fun r' h1 h2 => ⟨r' + Δ, by omega, by omega, ⟨Δ, rfl, h⟩⟩⟩

theorem shiftR_snce_back (k : ℕ) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (τ' : WorldHistory F.toTaskFrame) (t' : ℤ) (h : ShiftR (F := F) (k + 1) τ t τ' t')
    (s' : ℤ) (hts' : s' < t') :
    ∃ s : ℤ, s < t ∧ ShiftR (F := F) k τ s τ' s' ∧
      ∀ r : ℤ, s < r → r < t → ∃ r' : ℤ, s' < r' ∧ r' < t' ∧ ShiftR (F := F) k τ r τ' r' := by
  obtain ⟨Δ, rfl, h⟩ := h
  exact ⟨s' + Δ, by omega, ⟨Δ, rfl, h⟩,
    fun r h1 h2 => ⟨r - Δ, by omega, by omega, ⟨Δ, by omega, h⟩⟩⟩

theorem shiftR_of_unshift (k : ℕ) (σ' : WorldHistory F.toTaskFrame) (t' Δ : ℤ) :
    ShiftR (F := F) k (σ'.timeShift (-Δ)) (t' + Δ) σ' t' := by
  refine ⟨Δ, rfl, fun s => ?_⟩
  show σ'.state s = σ'.state (s + Δ + -Δ)
  rw [show s + Δ + -Δ = s by omega]

theorem unshift_state (σ' : WorldHistory F.toTaskFrame) (t' Δ : ℤ) :
    (σ'.timeShift (-Δ)).state (t' + Δ) = σ'.state t' := by
  show σ'.state (t' + Δ + -Δ) = σ'.state t'
  rw [show t' + Δ + -Δ = t' by omega]

/-- **THE SHIFT RELATION IS A TRANSFER SYSTEM FOR THE WHOLE LANGUAGE**, `⊡` and `□` switched on:
both clause families are answered by shifting the quantified history.  The transfer theorem at
this system is `plusTruthAt_timeShift`; it is recorded to show the `⊡` clauses of a transfer
system are dischargeable, not to prove anything new. -/
theorem shiftR_transferSys (M : TaskModel F.toTaskFrame) :
    TransferSys M True True (ShiftR (F := F)) where
  atom := by
    rintro k τ t τ' t' ⟨Δ, rfl, h⟩ p
    rw [h t']
  untl_forth := fun k τ t τ' t' h s hts => shiftR_untl_forth k τ t τ' t' h s hts
  untl_back := fun k τ t τ' t' h s hts => shiftR_untl_back k τ t τ' t' h s hts
  snce_forth := fun k τ t τ' t' h s hts => shiftR_snce_forth k τ t τ' t' h s hts
  snce_back := fun k τ t τ' t' h s hts => shiftR_snce_back k τ t τ' t' h s hts
  box_forth := by
    rintro - k τ t τ' t' ⟨Δ, rfl, h⟩ σ
    exact ⟨σ.timeShift Δ, Δ, rfl, fun s => rfl⟩
  box_back := by
    rintro - k τ t τ' t' ⟨Δ, rfl, h⟩ σ'
    exact ⟨σ'.timeShift (-Δ), shiftR_of_unshift k σ' t' Δ⟩
  stab_forth := by
    rintro - k τ t τ' t' ⟨Δ, rfl, h⟩ σ hst
    refine ⟨σ.timeShift Δ, ?_, Δ, rfl, fun s => rfl⟩
    show τ'.state t' = σ.state (t' + Δ)
    rw [h t', hst]
  stab_back := by
    rintro - k τ t τ' t' ⟨Δ, rfl, h⟩ σ' hst
    refine ⟨σ'.timeShift (-Δ), ?_, shiftR_of_unshift k σ' t' Δ⟩
    rw [unshift_state, ← hst, h t']

end Shift

/-! ### The slide: the evaluation point moves inside a homogeneous stretch

The sliding relation carries a parameter `Lk`, the condition a stretch must meet at each level.
At `Lk := fun _ _ _ _ => True` it is the `⊡`-free and `□`-free instance.  At the state-link
condition `StateLinked R` it is the closure of ANY transfer system `R` under sliding
(`slide_closure_transferSys`), `⊡` and `□` included — and the state-link condition is then
exactly what the `⊡` clause consumes: the states of the stretch answer each other's histories
one level down. -/

section Slide

variable {F : FrameOver intOrder}

/-- The stretch `[a, b]` of a history carries one atom row. -/
def HomStretch (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (a b : ℤ) : Prop :=
  ∀ u v : ℤ, a ≤ u → u ≤ b → a ≤ v → v ≤ b →
    ∀ p : Atom, M.valuation (τ.state u) p ↔ M.valuation (τ.state v) p

/-- The sliding relation: the same history, and either the same time or two times both at least
`k` inside one homogeneous stretch meeting the level-`k` condition `Lk`. -/
def SlideR (M : TaskModel F.toTaskFrame)
    (Lk : ℕ → WorldHistory F.toTaskFrame → ℤ → ℤ → Prop)
    (k : ℕ) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (τ' : WorldHistory F.toTaskFrame) (t' : ℤ) : Prop :=
  τ' = τ ∧ (t' = t ∨ ∃ a b : ℤ, HomStretch M τ a b ∧ Lk k τ a b ∧
    a + (k : ℤ) ≤ t ∧ t + (k : ℤ) ≤ b ∧ a + (k : ℤ) ≤ t' ∧ t' + (k : ℤ) ≤ b)

variable (M : TaskModel F.toTaskFrame) (Lk : ℕ → WorldHistory F.toTaskFrame → ℤ → ℤ → Prop)

theorem slideR_symm (k : ℕ) (τ : WorldHistory F.toTaskFrame)
    (t : ℤ) (τ' : WorldHistory F.toTaskFrame) (t' : ℤ) (h : SlideR M Lk k τ t τ' t') :
    SlideR M Lk k τ' t' τ t := by
  obtain ⟨rfl, h⟩ := h
  refine ⟨rfl, ?_⟩
  rcases h with h | ⟨a, b, hom, hl, h1, h2, h3, h4⟩
  · exact Or.inl h.symm
  · exact Or.inr ⟨a, b, hom, hl, h3, h4, h1, h2⟩

theorem slideR_refl (k : ℕ) (τ : WorldHistory F.toTaskFrame)
    (t : ℤ) : SlideR M Lk k τ t τ t := ⟨rfl, Or.inl rfl⟩

theorem slideR_atom (k : ℕ) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (τ' : WorldHistory F.toTaskFrame) (t' : ℤ) (h : SlideR M Lk k τ t τ' t') (p : Atom) :
    M.valuation (τ.state t) p ↔ M.valuation (τ'.state t') p := by
  obtain ⟨rfl, h⟩ := h
  rcases h with rfl | ⟨a, b, hom, -, h1, h2, h3, h4⟩
  · exact Iff.rfl
  · exact hom t t' (by omega) (by omega) (by omega) (by omega) p

theorem slideR_untl_forth (hmono : ∀ k τ a b, Lk (k + 1) τ a b → Lk k τ a b) (k : ℕ)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (τ' : WorldHistory F.toTaskFrame) (t' : ℤ)
    (h : SlideR M Lk (k + 1) τ t τ' t') (s : ℤ) (hts : t < s) :
    ∃ s' : ℤ, t' < s' ∧ SlideR M Lk k τ s τ' s' ∧
      ∀ r' : ℤ, t' < r' → r' < s' → ∃ r : ℤ, t < r ∧ r < s ∧ SlideR M Lk k τ r τ' r' := by
  obtain ⟨rfl, h⟩ := h
  rcases h with rfl | ⟨a, b, hom, hl, h1, h2, h3, h4⟩
  · exact ⟨s, hts, slideR_refl M Lk k _ s,
      fun r' hr1 hr2 => ⟨r', hr1, hr2, slideR_refl M Lk k _ r'⟩⟩
  · have hl' := hmono k _ a b hl
    push_cast at h1 h2 h3 h4
    by_cases hs : s + (k : ℤ) ≤ b
    · refine ⟨t' + 1, by omega,
        ⟨rfl, Or.inr ⟨a, b, hom, hl', by omega, hs, by omega, by omega⟩⟩,
        fun r' hr1 hr2 => by omega⟩
    · refine ⟨s, by omega, slideR_refl M Lk k _ s, fun r' hr1 hr2 => ?_⟩
      by_cases hr : r' + (k : ℤ) ≤ b
      · exact ⟨t + 1, by omega, by omega,
          ⟨rfl, Or.inr ⟨a, b, hom, hl', by omega, by omega, by omega, hr⟩⟩⟩
      · exact ⟨r', by omega, hr2, slideR_refl M Lk k _ r'⟩

theorem slideR_snce_forth (hmono : ∀ k τ a b, Lk (k + 1) τ a b → Lk k τ a b) (k : ℕ)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (τ' : WorldHistory F.toTaskFrame) (t' : ℤ)
    (h : SlideR M Lk (k + 1) τ t τ' t') (s : ℤ) (hts : s < t) :
    ∃ s' : ℤ, s' < t' ∧ SlideR M Lk k τ s τ' s' ∧
      ∀ r' : ℤ, s' < r' → r' < t' → ∃ r : ℤ, s < r ∧ r < t ∧ SlideR M Lk k τ r τ' r' := by
  obtain ⟨rfl, h⟩ := h
  rcases h with rfl | ⟨a, b, hom, hl, h1, h2, h3, h4⟩
  · exact ⟨s, hts, slideR_refl M Lk k _ s,
      fun r' hr1 hr2 => ⟨r', hr1, hr2, slideR_refl M Lk k _ r'⟩⟩
  · have hl' := hmono k _ a b hl
    push_cast at h1 h2 h3 h4
    by_cases hs : a + (k : ℤ) ≤ s
    · refine ⟨t' - 1, by omega,
        ⟨rfl, Or.inr ⟨a, b, hom, hl', hs, by omega, by omega, by omega⟩⟩,
        fun r' hr1 hr2 => by omega⟩
    · refine ⟨s, by omega, slideR_refl M Lk k _ s, fun r' hr1 hr2 => ?_⟩
      by_cases hr : a + (k : ℤ) ≤ r'
      · exact ⟨t - 1, by omega, by omega,
          ⟨rfl, Or.inr ⟨a, b, hom, hl', by omega, by omega, hr, by omega⟩⟩⟩
      · exact ⟨r', hr1, by omega, slideR_refl M Lk k _ r'⟩

theorem slideR_untl_back (hmono : ∀ k τ a b, Lk (k + 1) τ a b → Lk k τ a b) (k : ℕ)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (τ' : WorldHistory F.toTaskFrame) (t' : ℤ)
    (h : SlideR M Lk (k + 1) τ t τ' t') (s' : ℤ) (hts' : t' < s') :
    ∃ s : ℤ, t < s ∧ SlideR M Lk k τ s τ' s' ∧
      ∀ r : ℤ, t < r → r < s → ∃ r' : ℤ, t' < r' ∧ r' < s' ∧ SlideR M Lk k τ r τ' r' := by
  obtain ⟨s, hts, hss, hb⟩ :=
    slideR_untl_forth M Lk hmono k τ' t' τ t (slideR_symm M Lk (k + 1) τ t τ' t' h) s' hts'
  refine ⟨s, hts, slideR_symm M Lk k _ _ _ _ hss, fun r h1 h2 => ?_⟩
  obtain ⟨r', hr1, hr2, hrr⟩ := hb r h1 h2
  exact ⟨r', hr1, hr2, slideR_symm M Lk k _ _ _ _ hrr⟩

theorem slideR_snce_back (hmono : ∀ k τ a b, Lk (k + 1) τ a b → Lk k τ a b) (k : ℕ)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (τ' : WorldHistory F.toTaskFrame) (t' : ℤ)
    (h : SlideR M Lk (k + 1) τ t τ' t') (s' : ℤ) (hts' : s' < t') :
    ∃ s : ℤ, s < t ∧ SlideR M Lk k τ s τ' s' ∧
      ∀ r : ℤ, s < r → r < t → ∃ r' : ℤ, s' < r' ∧ r' < t' ∧ SlideR M Lk k τ r τ' r' := by
  obtain ⟨s, hts, hss, hb⟩ :=
    slideR_snce_forth M Lk hmono k τ' t' τ t (slideR_symm M Lk (k + 1) τ t τ' t' h) s' hts'
  refine ⟨s, hts, slideR_symm M Lk k _ _ _ _ hss, fun r h1 h2 => ?_⟩
  obtain ⟨r', hr1, hr2, hrr⟩ := hb r h1 h2
  exact ⟨r', hr1, hr2, slideR_symm M Lk k _ _ _ _ hrr⟩

/-- **THE SLIDING RELATION IS A TRANSFER SYSTEM** for the `⊡`-free and `□`-free fragment, with
no condition on the stretch beyond its atom row. -/
theorem slideR_transferSys :
    TransferSys M False False (SlideR M (fun _ _ _ _ => True)) where
  atom := fun k τ t τ' t' h p => slideR_atom M _ k τ t τ' t' h p
  untl_forth := fun k τ t τ' t' h s hts =>
    slideR_untl_forth M _ (fun _ _ _ _ h => h) k τ t τ' t' h s hts
  untl_back := fun k τ t τ' t' h s hts =>
    slideR_untl_back M _ (fun _ _ _ _ h => h) k τ t τ' t' h s hts
  snce_forth := fun k τ t τ' t' h s hts =>
    slideR_snce_forth M _ (fun _ _ _ _ h => h) k τ t τ' t' h s hts
  snce_back := fun k τ t τ' t' h s hts =>
    slideR_snce_back M _ (fun _ _ _ _ h => h) k τ t τ' t' h s hts
  box_forth := fun h => h.elim
  box_back := fun h => h.elim
  stab_forth := fun h => h.elim
  stab_back := fun h => h.elim

/-- **THE STATE-LINK CONDITION.** A stretch is linked at level `k` through `R` when, at every
level below `k`, any two of its states answer each other's histories: a history through the state
at `u` is matched by an `R`-related history through the state at `v`, and conversely.  At level
`j` this is the level-`j` agreement of the two cells, read through `R`. -/
def StateLinked (R : ℕ → WorldHistory F.toTaskFrame → ℤ → WorldHistory F.toTaskFrame → ℤ → Prop)
    (k : ℕ) (τ : WorldHistory F.toTaskFrame) (a b : ℤ) : Prop :=
  ∀ j : ℕ, j < k → ∀ u v : ℤ, a ≤ u → u ≤ b → a ≤ v → v ≤ b →
    (∀ σ : WorldHistory F.toTaskFrame, τ.state u = σ.state u →
      ∃ σ' : WorldHistory F.toTaskFrame, τ.state v = σ'.state v ∧ R j σ u σ' v) ∧
    (∀ σ' : WorldHistory F.toTaskFrame, τ.state v = σ'.state v →
      ∃ σ : WorldHistory F.toTaskFrame, τ.state u = σ.state u ∧ R j σ u σ' v)

/-- **THE SLIDE CLOSURE: THE INDUCTION STEP OF THE COUNT MOVE, WITH ITS `⊡` CLAUSE.** Let `R` be
a transfer system for the whole language in which every history at one time is related to some
history at any other (the time shift supplies this).  Then `R` together with the slides inside
homogeneous, state-linked stretches is again a transfer system for the whole language.  The `⊡`
clause of a slide is discharged by the state link and by nothing else — so the cell agreement of
the states ALONG a pending run, one level down, is exactly what a slide-based count move owes at
a closure carrying `⊡`. -/
theorem slide_closure_transferSys
    (R : ℕ → WorldHistory F.toTaskFrame → ℤ → WorldHistory F.toTaskFrame → ℤ → Prop)
    (hR : TransferSys M True True R)
    (hbox : ∀ (k : ℕ) (σ : WorldHistory F.toTaskFrame) (t t' : ℤ),
      ∃ σ' : WorldHistory F.toTaskFrame, R k σ t σ' t')
    (hbox' : ∀ (k : ℕ) (σ' : WorldHistory F.toTaskFrame) (t t' : ℤ),
      ∃ σ : WorldHistory F.toTaskFrame, R k σ t σ' t') :
    TransferSys M True True
      (fun k τ t τ' t' => R k τ t τ' t' ∨ SlideR M (StateLinked R) k τ t τ' t') where
  atom := by
    rintro k τ t τ' t' (h | h) p
    · exact hR.atom k τ t τ' t' h p
    · exact slideR_atom M _ k τ t τ' t' h p
  untl_forth := by
    rintro k τ t τ' t' (h | h) s hts
    · obtain ⟨s', h1, h2, h3⟩ := hR.untl_forth k τ t τ' t' h s hts
      exact ⟨s', h1, Or.inl h2, fun r' a b => by
        obtain ⟨r, c, d, e⟩ := h3 r' a b
        exact ⟨r, c, d, Or.inl e⟩⟩
    · obtain ⟨s', h1, h2, h3⟩ := slideR_untl_forth M _
        (fun k τ a b hl j hj => hl j (by omega)) k τ t τ' t' h s hts
      exact ⟨s', h1, Or.inr h2, fun r' a b => by
        obtain ⟨r, c, d, e⟩ := h3 r' a b
        exact ⟨r, c, d, Or.inr e⟩⟩
  untl_back := by
    rintro k τ t τ' t' (h | h) s hts
    · obtain ⟨s', h1, h2, h3⟩ := hR.untl_back k τ t τ' t' h s hts
      exact ⟨s', h1, Or.inl h2, fun r' a b => by
        obtain ⟨r, c, d, e⟩ := h3 r' a b
        exact ⟨r, c, d, Or.inl e⟩⟩
    · obtain ⟨s', h1, h2, h3⟩ := slideR_untl_back M _
        (fun k τ a b hl j hj => hl j (by omega)) k τ t τ' t' h s hts
      exact ⟨s', h1, Or.inr h2, fun r' a b => by
        obtain ⟨r, c, d, e⟩ := h3 r' a b
        exact ⟨r, c, d, Or.inr e⟩⟩
  snce_forth := by
    rintro k τ t τ' t' (h | h) s hts
    · obtain ⟨s', h1, h2, h3⟩ := hR.snce_forth k τ t τ' t' h s hts
      exact ⟨s', h1, Or.inl h2, fun r' a b => by
        obtain ⟨r, c, d, e⟩ := h3 r' a b
        exact ⟨r, c, d, Or.inl e⟩⟩
    · obtain ⟨s', h1, h2, h3⟩ := slideR_snce_forth M _
        (fun k τ a b hl j hj => hl j (by omega)) k τ t τ' t' h s hts
      exact ⟨s', h1, Or.inr h2, fun r' a b => by
        obtain ⟨r, c, d, e⟩ := h3 r' a b
        exact ⟨r, c, d, Or.inr e⟩⟩
  snce_back := by
    rintro k τ t τ' t' (h | h) s hts
    · obtain ⟨s', h1, h2, h3⟩ := hR.snce_back k τ t τ' t' h s hts
      exact ⟨s', h1, Or.inl h2, fun r' a b => by
        obtain ⟨r, c, d, e⟩ := h3 r' a b
        exact ⟨r, c, d, Or.inl e⟩⟩
    · obtain ⟨s', h1, h2, h3⟩ := slideR_snce_back M _
        (fun k τ a b hl j hj => hl j (by omega)) k τ t τ' t' h s hts
      exact ⟨s', h1, Or.inr h2, fun r' a b => by
        obtain ⟨r, c, d, e⟩ := h3 r' a b
        exact ⟨r, c, d, Or.inr e⟩⟩
  box_forth := by
    rintro - k τ t τ' t' - σ
    obtain ⟨σ', h⟩ := hbox k σ t t'
    exact ⟨σ', Or.inl h⟩
  box_back := by
    rintro - k τ t τ' t' - σ'
    obtain ⟨σ, h⟩ := hbox' k σ' t t'
    exact ⟨σ, Or.inl h⟩
  stab_forth := by
    rintro - k τ t τ' t' (h | ⟨rfl, h⟩) σ hst
    · obtain ⟨σ', h1, h2⟩ := hR.stab_forth trivial k τ t τ' t' h σ hst
      exact ⟨σ', h1, Or.inl h2⟩
    · rcases h with rfl | ⟨a, b, -, hl, h1, h2, h3, h4⟩
      · exact ⟨σ, hst, Or.inr (slideR_refl M _ k σ _)⟩
      · push_cast at h1 h2 h3 h4
        obtain ⟨σ', hs', hr⟩ :=
          (hl k (by omega) t t' (by omega) (by omega) (by omega) (by omega)).1 σ hst
        exact ⟨σ', hs', Or.inl hr⟩
  stab_back := by
    rintro - k τ t τ' t' (h | ⟨rfl, h⟩) σ' hst
    · obtain ⟨σ, h1, h2⟩ := hR.stab_back trivial k τ t τ' t' h σ' hst
      exact ⟨σ, h1, Or.inl h2⟩
    · rcases h with rfl | ⟨a, b, -, hl, h1, h2, h3, h4⟩
      · exact ⟨σ', hst, Or.inr (slideR_refl M _ k σ' _)⟩
      · push_cast at h1 h2 h3 h4
        obtain ⟨σ, hs, hr⟩ :=
          (hl k (by omega) t t' (by omega) (by omega) (by omega) (by omega)).2 σ' hst
        exact ⟨σ, hs, Or.inl hr⟩

/-- **THE SLIDE.** On a closure with no `⊡` and no `□` member, the closure type is the same at
any two times lying at least `sup opDepth` inside one homogeneous stretch of one history.  The
atom rows of the two points, read relative to the evaluation time, differ wherever the stretch
ends; the type does not. -/
theorem tpOf_eq_of_homStretch (φ : PlusFormula)
    (hnos : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (hnob : ∀ χ : PlusFormula, PlusFormula.box χ ∉ plusSubformulaClosure φ)
    (τ : WorldHistory F.toTaskFrame) (a b t t' : ℤ) (hom : HomStretch M τ a b)
    (h1 : a + (((plusSubformulaClosure φ).sup opDepth : ℕ) : ℤ) ≤ t)
    (h2 : t + (((plusSubformulaClosure φ).sup opDepth : ℕ) : ℤ) ≤ b)
    (h3 : a + (((plusSubformulaClosure φ).sup opDepth : ℕ) : ℤ) ≤ t')
    (h4 : t' + (((plusSubformulaClosure φ).sup opDepth : ℕ) : ℤ) ≤ b) :
    tpOf M φ τ t = tpOf M φ τ t' := by
  ext ψ
  rw [mem_tpOf_iff, mem_tpOf_iff]
  refine and_congr_right (fun hψ => ?_)
  exact truth_iff_of_transferSys M False False _ (slideR_transferSys M) ψ
    ((plusSubformulaClosure φ).sup opDepth) τ t τ t'
    (allowed_of_stabBoxFree ψ (stabBoxFree_of_mem_closure hnos hnob ψ hψ))
    (Finset.le_sup hψ) ⟨rfl, Or.inr ⟨a, b, hom, trivial, h1, h2, h3, h4⟩⟩

/-- **THE SLIDE AT A CLOSURE CARRYING `⊡`**, conditional on the state link and on nothing else:
inside a homogeneous stretch linked at the closure's operator depth through a transfer system,
the closure type is the same at any two sufficiently interior times — for EVERY formula. -/
theorem tpOf_eq_of_linkedStretch
    (R : ℕ → WorldHistory F.toTaskFrame → ℤ → WorldHistory F.toTaskFrame → ℤ → Prop)
    (hR : TransferSys M True True R)
    (hbox : ∀ (k : ℕ) (σ : WorldHistory F.toTaskFrame) (t t' : ℤ),
      ∃ σ' : WorldHistory F.toTaskFrame, R k σ t σ' t')
    (hbox' : ∀ (k : ℕ) (σ' : WorldHistory F.toTaskFrame) (t t' : ℤ),
      ∃ σ : WorldHistory F.toTaskFrame, R k σ t σ' t')
    (φ : PlusFormula)
    (τ : WorldHistory F.toTaskFrame) (a b t t' : ℤ) (hom : HomStretch M τ a b)
    (hl : StateLinked R ((plusSubformulaClosure φ).sup opDepth) τ a b)
    (h1 : a + (((plusSubformulaClosure φ).sup opDepth : ℕ) : ℤ) ≤ t)
    (h2 : t + (((plusSubformulaClosure φ).sup opDepth : ℕ) : ℤ) ≤ b)
    (h3 : a + (((plusSubformulaClosure φ).sup opDepth : ℕ) : ℤ) ≤ t')
    (h4 : t' + (((plusSubformulaClosure φ).sup opDepth : ℕ) : ℤ) ≤ b) :
    tpOf M φ τ t = tpOf M φ τ t' := by
  ext ψ
  rw [mem_tpOf_iff, mem_tpOf_iff]
  refine and_congr_right (fun hψ => ?_)
  exact truth_iff_of_transferSys M True True _ (slide_closure_transferSys M R hR hbox hbox') ψ
    ((plusSubformulaClosure φ).sup opDepth) τ t τ t' (allowed_true ψ)
    (Finset.le_sup hψ) (Or.inr ⟨rfl, Or.inr ⟨a, b, hom, hl, h1, h2, h3, h4⟩⟩)

theorem shiftR_total (k : ℕ) (σ : WorldHistory F.toTaskFrame) (t t' : ℤ) :
    ∃ σ' : WorldHistory F.toTaskFrame, ShiftR (F := F) k σ t σ' t' :=
  ⟨σ.timeShift (t - t'), t - t', by omega, fun _ => rfl⟩

theorem shiftR_total' (k : ℕ) (σ' : WorldHistory F.toTaskFrame) (t t' : ℤ) :
    ∃ σ : WorldHistory F.toTaskFrame, ShiftR (F := F) k σ t σ' t' := by
  refine ⟨σ'.timeShift (-(t - t')), ?_⟩
  have h := shiftR_of_unshift (F := F) k σ' t' (t - t')
  rwa [show t' + (t - t') = t by omega] at h

/-- **AN UNCONDITIONAL SLIDE CARRYING `⊡` AND `□`.** In any frame over `ℤ`, a history resting in
ONE world state across a stretch realizes the same closure type at any two sufficiently interior
times, for every formula: the state link is supplied by the time shift.  This is the slide
closure at a link that costs nothing.  It does NOT apply on the ladder frame, whose world states
carry their own time coordinate and whose pending runs change the countdown at every step — there
the link is the lower-level cell agreement of DIFFERENT ladder states and is owed, not free. -/
theorem tpOf_eq_of_constStretch (φ : PlusFormula)
    (τ : WorldHistory F.toTaskFrame) (a b t t' : ℤ)
    (hconst : ∀ u v : ℤ, a ≤ u → u ≤ b → a ≤ v → v ≤ b → τ.state u = τ.state v)
    (h1 : a + (((plusSubformulaClosure φ).sup opDepth : ℕ) : ℤ) ≤ t)
    (h2 : t + (((plusSubformulaClosure φ).sup opDepth : ℕ) : ℤ) ≤ b)
    (h3 : a + (((plusSubformulaClosure φ).sup opDepth : ℕ) : ℤ) ≤ t')
    (h4 : t' + (((plusSubformulaClosure φ).sup opDepth : ℕ) : ℤ) ≤ b) :
    tpOf M φ τ t = tpOf M φ τ t' := by
  refine tpOf_eq_of_linkedStretch M (ShiftR (F := F)) (shiftR_transferSys M)
    (fun k σ t t' => shiftR_total k σ t t') (fun k σ' t t' => shiftR_total' k σ' t t')
    φ τ a b t t' ?_ ?_ h1 h2 h3 h4
  · intro u v hu1 hu2 hv1 hv2 p
    rw [hconst u v hu1 hu2 hv1 hv2]
  · intro j _ u v hu1 hu2 hv1 hv2
    refine ⟨fun σ hst => ⟨σ.timeShift (u - v), ?_, u - v, by omega, fun _ => rfl⟩,
      fun σ' hst => ?_⟩
    · show τ.state v = σ.state (v + (u - v))
      rw [show v + (u - v) = u by omega, ← hst, hconst u v hu1 hu2 hv1 hv2]
    · refine ⟨σ'.timeShift (-(u - v)), ?_, ?_⟩
      · have h := unshift_state (F := F) σ' v (u - v)
        rw [show v + (u - v) = u by omega] at h
        rw [h, ← hst, hconst u v hu1 hu2 hv1 hv2]
      · have h := shiftR_of_unshift (F := F) j σ' v (u - v)
        rwa [show v + (u - v) = u by omega] at h

end Slide

/-! ### The interface the construction is owed -/

section Interface

variable {Q : Type} [Finite Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE COUNT MOVE FROM A TRANSFER SYSTEM.** The count move at a formula and four parameters
holds as soon as SOME whole-language transfer system relates, at the closure's operator depth,
every ladder history through one state of a `kappa`-collision to a ladder history through the
other.  No clause asks the two histories to agree at any position: what is owed is the system and
the one link at the compared position. -/
theorem typePreservingCountMove_of_transferSys
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (R : ℕ → WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame → ℤ →
      WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame → ℤ → Prop)
    (hR : TransferSys (ladderModel step pend fwd bwd lab) True True R)
    (hlink : ∀ (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q),
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
      ∀ (g : ℤ → LadderState Q pend)
        (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        IsLadderPath step pend g → g 0 = (⟨(q, c, n), h⟩ : LadderState Q pend) →
        (∀ t : ℤ, τ.state t = (t, g t)) →
        ∃ (g' : ℤ → LadderState Q pend)
          (τ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
          IsLadderPath step pend g' ∧ g' 0 = (⟨(q, c', n'), h'⟩ : LadderState Q pend) ∧
          (∀ t : ℤ, τ'.state t = (t, g' t)) ∧
          R ((plusSubformulaClosure φ).sup opDepth) τ 0 τ' 0) :
    TypePreservingCountMove fwd bwd lab φ Tc Tn P B := by
  intro q c n c' n' h h' hk g τ hg hg0 hτ
  obtain ⟨g', τ', hg', hg0', hτ', hr⟩ := hlink q c n c' n' h h' hk g τ hg hg0 hτ
  exact ⟨g', τ', hg', hg0', hτ',
    (tpOf_eq_of_transferSys (ladderModel step pend fwd bwd lab) R hR φ τ 0 τ' 0 hr).symm⟩

end Interface

/-! ### The slide at this object: a count move for every history deep inside its pending run -/

theorem objAt_eq_zero_of_pendC (g : ℤ → LadderState Qc pendC) (u : ℤ)
    (h : pendC (objAt g u) = true) : objAt g u = 0 := by
  simpa [pendC] using h

/-- **THE SLIDE IS A COUNT MOVE AT THIS OBJECT.** Let a ladder path be pending on the `d + D`
positions before `0`, with countdown at least `D` at `0`, where `D` is the closure's operator
depth.  Then the closure type it realizes at `0` — at countdown `c` — is the type it realizes at
`-d`, where its countdown is `c + d`.  One history, two states with different countdowns, one
type; no explicit path, no bound on the formula beyond `⊡`- and `□`-freedom of its closure. -/
theorem slide_count_move_C (φ : PlusFormula)
    (hnos : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (hnob : ∀ χ : PlusFormula, PlusFormula.box χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Qc pendC) (hg : IsLadderPath stepC pendC g)
    (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (d : ℕ)
    (hpast : ∀ i : ℕ, i ≤ d + (plusSubformulaClosure φ).sup opDepth →
      pendC (objAt g (0 - (i : ℤ))) = true)
    (hcnt : (plusSubformulaClosure φ).sup opDepth ≤ cntAt g 0) :
    tpOf MC φ τ 0 = tpOf MC φ τ (-(d : ℤ)) ∧ cntAt g (-(d : ℤ)) = cntAt g 0 + d := by
  set D := (plusSubformulaClosure φ).sup opDepth with hD
  have h0 : pendC (objAt g 0) = true := by simpa using hpast 0 (by omega)
  have hpend : ∀ u : ℤ, -((d : ℤ) + (D : ℤ)) ≤ u → u ≤ (cntAt g 0 : ℤ) →
      pendC (objAt g u) = true := by
    intro u hu1 hu2
    rcases le_or_gt u 0 with hle | hgt
    · have := hpast (-u).toNat (by omega)
      rwa [show (0 : ℤ) - ((-u).toNat : ℤ) = u by omega] at this
    · have := (cntAt_sub_of_pend g hg 0 h0 u.toNat (by omega)).1
      rwa [show (0 : ℤ) + (u.toNat : ℤ) = u by omega] at this
  have hom : HomStretch MC τ (-((d : ℤ) + (D : ℤ))) (cntAt g 0 : ℤ) := by
    intro u v hu1 hu2 hv1 hv2 p
    show labC (τ.state u).2.1.1 p = true ↔ labC (τ.state v).2.1.1 p = true
    rw [hτ u, hτ v]
    show labC (objAt g u) p = true ↔ labC (objAt g v) p = true
    rw [objAt_eq_zero_of_pendC g u (hpend u hu1 hu2), objAt_eq_zero_of_pendC g v (hpend v hv1 hv2)]
  refine ⟨tpOf_eq_of_homStretch MC φ hnos hnob τ _ _ 0 (-(d : ℤ)) hom
    (by omega) (by omega) (by omega) (by omega), ?_⟩
  have := cntAt_add_of_pend_back g hg 0 d (fun i hi => hpast i (by omega))
  rwa [show (0 : ℤ) - (d : ℤ) = -(d : ℤ) by omega] at this

/-! ### Where the construction refuses: the past row caps the countdown -/

section Cap

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE CAP.** Let `e₀` be idle and `(e₀, x₀]` a pending region ending at `x₀` (so `x₀ + 1` is
idle); let `e ≥ x₀ + 1` be idle and `(e, z]` pending.  Then

  `cntAt g z + (z - e - 1) ≤ (x₀ - e₀ - 1) + (e - e₀)`.

The left side is the entry register of the region containing `z`; the right side is the entry
register of the previous region — which IS that region's length less one — plus the number of
steps the register had to drift.  Every quantity on the right is a position of the pending ROW. -/
theorem cnt_cap_of_row (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (e₀ x₀ e z : ℤ) (he₀ : pend (objAt g e₀) = false) (hlt₀ : e₀ < x₀)
    (hrun₀ : ∀ u : ℤ, e₀ < u → u ≤ x₀ → pend (objAt g u) = true)
    (hx₀ : pend (objAt g (x₀ + 1)) = false) (hx₀e : x₀ < e)
    (he : pend (objAt g e) = false) (hez : e < z)
    (hrun : ∀ u : ℤ, e < u → u ≤ z → pend (objAt g u) = true) :
    (cntAt g z : ℤ) + (z - e - 1) ≤ (x₀ - e₀ - 1) + (e - e₀) := by
  -- the previous region: its entry register is its length less one
  have hpin₀ := cntAt_eq_nxtAt_of_idle_pend g hg e₀ he₀ (hrun₀ (e₀ + 1) (by omega) (by omega))
  have hend₀ := (cntAt_eq_zero_of_pend_idle g hg x₀ (hrun₀ x₀ hlt₀ le_rfl) hx₀).1
  have hback₀ := cntAt_add_of_pend_back g hg x₀ (x₀ - e₀ - 1).toNat
    (fun i hi => hrun₀ _ (by omega) (by omega))
  rw [show x₀ - (((x₀ - e₀ - 1).toNat : ℕ) : ℤ) = e₀ + 1 by omega] at hback₀
  -- the region containing `z`: its entry register is its countdown at `z` plus the elapsed steps
  have hpin := cntAt_eq_nxtAt_of_idle_pend g hg e he (hrun (e + 1) (by omega) (by omega))
  have hback := cntAt_add_of_pend_back g hg z (z - e - 1).toNat
    (fun i hi => hrun _ (by omega) (by omega))
  rw [show z - (((z - e - 1).toNat : ℕ) : ℤ) = e + 1 by omega] at hback
  -- the register drifts by at most one per step between the two entries
  have hlip := nxtAt_lipschitz g hg e₀ (e - e₀).toNat
  rw [show e₀ + (((e - e₀).toNat : ℕ) : ℤ) = e by omega] at hlip
  omega

/-- **THE REFUSING COORDINATE.** A ladder path whose countdown at `z` exceeds the cap another
path's row sets there disagrees with that path's pending row somewhere in the window `[e₀, z]`.
So a count move that RAISES a countdown past the cap must rewrite the pending row in the PAST of
the compared position, inside a window whose length the previous region fixes — and when the
pending bit factors through the atom row, that is an atom-row change two regions deep.  The
future row changes too (`countMove_rows_differ` and the rigid region); this is the past half. -/
theorem exists_past_row_change_of_cap_lt (g g' : ℤ → LadderState Q pend)
    (hg' : IsLadderPath step pend g')
    (e₀ x₀ e z : ℤ) (he₀ : pend (objAt g e₀) = false) (hlt₀ : e₀ < x₀)
    (hrun₀ : ∀ u : ℤ, e₀ < u → u ≤ x₀ → pend (objAt g u) = true)
    (hx₀ : pend (objAt g (x₀ + 1)) = false) (hx₀e : x₀ < e)
    (he : pend (objAt g e) = false) (hez : e < z)
    (hrun : ∀ u : ℤ, e < u → u ≤ z → pend (objAt g u) = true)
    (hlt : (x₀ - e₀ - 1) + (e - e₀) < (cntAt g' z : ℤ) + (z - e - 1)) :
    ∃ v : ℤ, e₀ ≤ v ∧ v ≤ z ∧ pend (objAt g' v) ≠ pend (objAt g v) := by
  by_contra hno
  push Not at hno
  have hcap := cnt_cap_of_row g' hg' e₀ x₀ e z
    (by rw [hno e₀ le_rfl (by omega)]; exact he₀) hlt₀
    (fun u h1 h2 => by rw [hno u (by omega) (by omega)]; exact hrun₀ u h1 h2)
    (by rw [hno (x₀ + 1) (by omega) (by omega)]; exact hx₀) hx₀e
    (by rw [hno e (by omega) (by omega)]; exact he) hez
    (fun u h1 h2 => by rw [hno u (by omega) (by omega)]; exact hrun u h1 h2)
  omega

end Cap

/-! ### The cap binds: a tight history at every scale -/

/-- The tight walk: idle up to `0`, a region of length `m + 1`, one idle position, a region of
length `2 m + 3`, idle from then on. -/
def wT (m : ℕ) : ℤ → Qc := fun v =>
  if (1 ≤ v ∧ v ≤ (m : ℤ) + 1) ∨ ((m : ℤ) + 3 ≤ v ∧ v ≤ 3 * (m : ℤ) + 5) then 0 else 1

/-- The tight walk's forced countdown. -/
def cT (m : ℕ) : ℤ → ℕ := fun v =>
  if 1 ≤ v ∧ v ≤ (m : ℤ) + 1 then ((m : ℤ) + 1 - v).toNat
  else if (m : ℤ) + 3 ≤ v ∧ v ≤ 3 * (m : ℤ) + 5 then (3 * (m : ℤ) + 5 - v).toNat else 0

theorem pendC_wT (m : ℕ) (v : ℤ) :
    pendC (wT m v) = true ↔
      ((1 ≤ v ∧ v ≤ (m : ℤ) + 1) ∨ ((m : ℤ) + 3 ≤ v ∧ v ≤ 3 * (m : ℤ) + 5)) := by
  unfold wT
  split_ifs with h
  · simp [pendC, h]
  · simp [pendC, h]

theorem pendC_wT_false (m : ℕ) (v : ℤ) :
    pendC (wT m v) = false ↔
      ¬ ((1 ≤ v ∧ v ≤ (m : ℤ) + 1) ∨ ((m : ℤ) + 3 ≤ v ∧ v ≤ 3 * (m : ℤ) + 5)) := by
  rw [← pendC_wT, Bool.not_eq_true]

/-- **THE TIGHT WALK IS A LADDER PATH**: its two pins, `m` at `0` and `2 m + 2` at `m + 2`, sit
exactly `m + 2` apart — the register rises at every step between the two entries. -/
theorem exists_tight_ladderPath (m : ℕ) :
    ∃ g : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g ∧
      (∀ v, objAt g v = wT m v) ∧ (∀ v, cntAt g v = cT m v) := by
  refine exists_ladderPath_of_walk_of_pins (wT m) (cT m) (fun _ => rfl) ?_ ?_ ?_ ?_
  · intro v h
    rw [pendC_wT_false] at h
    unfold cT
    split_ifs <;> omega
  · intro v h1 h2
    rw [pendC_wT] at h1 h2
    unfold cT
    split_ifs <;> omega
  · intro v h1 h2
    rw [pendC_wT] at h1
    rw [pendC_wT_false] at h2
    unfold cT
    split_ifs <;> omega
  · intro s v hs0 hs1 hv0 hv1
    rw [pendC_wT_false] at hs0 hv0
    rw [pendC_wT] at hs1 hv1
    unfold cT
    split_ifs <;> omega

/-- **THE CONSTRUCTION REFUSES AT A TIGHT HISTORY, AT EVERY SCALE.** For every `m` there is a
ladder path through the pending state of this object with countdown `2 m + 2` at position
`m + 3` such that EVERY ladder path carrying a larger countdown there disagrees with its pending
row — an atom row, at this object — somewhere in the window `[0, m + 3]`, the two regions before
the compared position.  The countdown `2 m + 2` exceeds every threshold for large `m`, so the
pairs are collisions of every counter quotient; the rewriting the count move owes them is in the
PAST, and it is two regions deep. -/
theorem tight_state_refuses_C (m : ℕ) :
    ∃ g : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g ∧
      objAt g ((m : ℤ) + 3) = 0 ∧ cntAt g ((m : ℤ) + 3) = 2 * m + 2 ∧
      ∀ g' : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g' →
        2 * m + 2 < cntAt g' ((m : ℤ) + 3) →
        ∃ v : ℤ, 0 ≤ v ∧ v ≤ (m : ℤ) + 3 ∧ pendC (objAt g' v) ≠ pendC (objAt g v) := by
  obtain ⟨g, hg, hobj, hcnt⟩ := exists_tight_ladderPath m
  have hp : ∀ v, pendC (objAt g v) = true ↔
      ((1 ≤ v ∧ v ≤ (m : ℤ) + 1) ∨ ((m : ℤ) + 3 ≤ v ∧ v ≤ 3 * (m : ℤ) + 5)) :=
    fun v => by rw [hobj]; exact pendC_wT m v
  have hpf : ∀ v, pendC (objAt g v) = false ↔
      ¬ ((1 ≤ v ∧ v ≤ (m : ℤ) + 1) ∨ ((m : ℤ) + 3 ≤ v ∧ v ≤ 3 * (m : ℤ) + 5)) :=
    fun v => by rw [hobj]; exact pendC_wT_false m v
  refine ⟨g, hg, ?_, ?_, fun g' hg' hlt => ?_⟩
  · rw [hobj]; unfold wT; rw [if_pos (by omega)]
  · rw [hcnt]; unfold cT; split_ifs <;> omega
  · exact exists_past_row_change_of_cap_lt g g' hg' 0 ((m : ℤ) + 1) ((m : ℤ) + 2) ((m : ℤ) + 3)
      ((hpf 0).mpr (by omega)) (by omega) (fun u h1 h2 => (hp u).mpr (by omega))
      ((hpf _).mpr (by omega)) (by omega) ((hpf _).mpr (by omega)) (by omega)
      (fun u h1 h2 => (hp u).mpr (by omega)) (by omega)

#print axioms Probe761C.typePreservingCountMove_iff_cellAt_const
#print axioms Probe761C.countMove_rows_differ
#print axioms Probe761C.truth_iff_of_transferSys
#print axioms Probe761C.typePreservingCountMove_of_transferSys
#print axioms Probe761C.shiftR_transferSys
#print axioms Probe761C.slideR_transferSys
#print axioms Probe761C.slide_closure_transferSys
#print axioms Probe761C.tpOf_eq_of_homStretch
#print axioms Probe761C.tpOf_eq_of_linkedStretch
#print axioms Probe761C.tpOf_eq_of_constStretch
#print axioms Probe761C.slide_count_move_C
#print axioms Probe761C.cnt_cap_of_row
#print axioms Probe761C.exists_past_row_change_of_cap_lt
#print axioms Probe761C.exists_tight_ladderPath
#print axioms Probe761C.tight_state_refuses_C

end Probe761C

/-!
# THE FILED AGREEMENT IS REFUTED: THE GAP CLIP OF (K4) IS TOO SMALL, BY AN UNBOUNDED AMOUNT

The two sections above leave `RefutationTargetC` and `CountMoveTargetC` stated and undecided, and
their docstrings say so ("nothing in this file proves it or refutes it").  THIS SECTION DECIDES
BOTH: `RefutationTargetC` HOLDS and `CountMoveTargetC` is FALSE.  Those two docstrings, and the
second section's "It is NOT REFUTED", describe the file as it stood before this section; they are
not edited (the file is append-only) and they are superseded here.

## The mechanism

Every earlier attempt read the COUNTDOWN, which (K2)'s margin puts out of a formula's reach.  This
section reads the GAP `n - c` between the register and the countdown — `kappa`'s fifth coordinate,
clipped to `[-B, B]`, where (K4) asks only `2 * dBack φ + 1 ≤ B`, `2 * dFwd φ + 1 ≤ B`, `2 ≤ B`.
Three facts about a pending state `(c, n)`:

* a history through it has an idle position in its past only if `c ≤ n + 1`
  (`cnt_le_nxt_succ_of_past_idle`): the region was entered with the countdown set to the register,
  and the register falls by at most one per step;
* one step FORWARD the gap rises by up to two (the countdown falls by one, the register may rise
  by one), and one step BACKWARD it falls by up to two;
* `⊡` re-chooses the history at every state, so a formula can walk the register up or down at
  two per step and then read the gap with a reader of fixed cost.

So a formula reads the gap at a distance from `0` that is TWICE its temporal depth plus the
reader's own threshold, while (K4) clips it at twice the LARGER of the two exactness depths plus
one.

## What is compiled

**The refutation, at the tie.**  `thetaC := ⊡ X ⊡ ¬ P ¬p` has `dBack = dFwd = 1`, so
`Bof … thetaC = 3` (`Bof_thetaC`).

* `thetaC_not_mem`: at the pending state `(n + 3, n)` — gap `-3` — NO realized type contains
  `thetaC`.
* `thetaC_mem`: at every pending state `(c, n)` with `n + 4 ≤ c` — gap at most `-4` — EVERY
  realized type contains it.
* `kappa_collision_theta`: `(Tc + 3, Tc)` and `(Tc + 3 + (P + 1), Tc)` are one `kappa`-class at
  the clip `3`, for every `Tc`, `Tn`, `P`.
* `refutationTargetC_holds`: **`RefutationTargetC`** — at `thetaC`, the periodicity fixpoint's own
  four outputs (`paramsOk_params`), and that pair, the two cells differ.
* `not_countMoveTargetC`: **`¬ CountMoveTargetC`**.
* `cellAt_const_of_kappa_eq_schema_refuted`: the statement filed as `cellAt_const_of_kappa_eq`,
  quantifiers and all, is FALSE.  The instance: the two-state object, `thetaC`, the fixpoint's
  parameters, world time `0`, evaluation time `0`.
* `no_fibre_equation_over_kappa`: no function of the counter class equals the cell at this object
  — so the statement filed as `ladderRealized`, whose right-hand side reads `(q, kappa (c, n))`
  alone, is false with it, whatever `Dmax` is.
* `no_transferSys_links_collisions`: no whole-language `TransferSys` carries the link
  `typePreservingCountMove_of_transferSys` consumes at these parameters.
* `certStabK_fails_of_contains_realized`: every set of triples containing the realized triples of
  this object's pending states fails condition (5) at the clip `3`.  The set of realized triples
  is such a set; so is any certified set a soundness statement would put them in.

**The excess is unbounded.**  `mixC a k := ◇ Y_p^a ◇ readC k` steps back `a` times through pending
positions (gap down by two each) and then asks the forward reader `readC k` ("the pending bit is
released, the next position starts a region, and that region is over within `k` positions"),
which fails at every pending position whose gap exceeds `k` (`readC_false_of_gap`).

* `dBack_mixC`, `dFwd_mixC`: `dBack = a`, `dFwd = k + 2`; `Bof_mixC`: at `a = k + 2` the clip is
  `2 k + 5`.
* `mixC_mem`: at gap exactly `2 a + k` every realized type contains `mixC a k` (`k ≥ 1`).
* `mixC_not_mem`: at every gap above `2 a + k` none does.
* `mixC_refutes`: for every `k ≥ 1`, at `mixC (k + 2) k` and the fixpoint's own parameters, the
  gap `3 k + 4` and the gap one modulus above it are one `kappa`-class with different cells.  The
  separated gap exceeds the clip `2 k + 5` by `k - 1`.

## What this section does and does not settle

It settles the truth value of the filed `cellAt_const_of_kappa_eq`: FALSE, at parameters
satisfying `ParamsOk` as it is defined, with no `Tc` raise, no `ParamsOk` strengthening, no
`⊡`-free premise and no finite-fibre or finite-width assumption.  The quantifier that fails is
the one over counter pairs whose gaps both lie outside the clip.

It does NOT show that `kappa`'s SHAPE is wrong.  Both families are defeated by a larger clip:
`thetaC` by `B ≥ 4`, `mixC a k` by `B ≥ 2 a + k + 1`, which a clip of the form
`2 * (dBack φ + dFwd φ) + 2` dominates.  Whether any clip that is a function of the formula makes
the agreement TRUE is not decided here; no proof of the agreement at any clip is offered.

It does NOT decide the tight family of the section above (`tight_state_refuses_C`): those states
have gap in `{-1, 0, 1}`, inside every clip, and neither family here separates them.

## Verification

`#print axioms` on every headline theorem of this section.  No `sorry`, no axiom, no
`native_decide`, no placeholder body and no vacuous definition.
-/

namespace Probe761C

/-! ### Gluing ladder paths -/

section Glue

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- Follow `g₁` up to and including `z`, and `g₂` from `z + 1` on. -/
def gluePath (g₁ g₂ : ℤ → LadderState Q pend) (z : ℤ) : ℤ → LadderState Q pend :=
  fun v => if v ≤ z then g₁ v else g₂ v

theorem gluePath_isPath (g₁ g₂ : ℤ → LadderState Q pend)
    (h₁ : IsLadderPath step pend g₁) (h₂ : IsLadderPath step pend g₂) (z : ℤ)
    (hz : RladAdm step pend z (g₁ z) (g₂ (z + 1))) :
    IsLadderPath step pend (gluePath g₁ g₂ z) := by
  intro u
  unfold gluePath
  by_cases h : u + 1 ≤ z
  · rw [if_pos (by omega), if_pos h]
    exact h₁ u
  · by_cases h' : u ≤ z
    · have hu : u = z := by omega
      subst hu
      rw [if_pos le_rfl, if_neg h]
      exact hz
    · rw [if_neg h', if_neg h]
      exact h₂ u

theorem gluePath_of_le (g₁ g₂ : ℤ → LadderState Q pend) (z v : ℤ) (h : v ≤ z) :
    gluePath g₁ g₂ z v = g₁ v := by
  unfold gluePath; rw [if_pos h]

theorem gluePath_of_gt (g₁ g₂ : ℤ → LadderState Q pend) (z v : ℤ) (h : z < v) :
    gluePath g₁ g₂ z v = g₂ v := by
  unfold gluePath; rw [if_neg (by omega)]

/-- A ladder path read at a shifted clock is a ladder path: the relation ignores its time. -/
theorem shiftPath_isPath (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (k : ℤ) :
    IsLadderPath step pend (fun v => g (v - k)) := by
  intro u
  have h := hg (u - k)
  rw [show u - k + 1 = u + 1 - k by ring] at h
  exact h

/-- **A FINITE PAST FORCES THE GAP.** On a ladder path, a pending position with an idle position
somewhere before it carries a countdown at most one above its register: the region it sits in was
entered with the countdown set to the register, and since then the countdown fell by one per step
while the register fell by at most one per step. -/
theorem cnt_le_nxt_succ_of_past_idle (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (z s : ℤ) (hs : s < z) (hidle : pend (objAt g s) = false) (hz : pend (objAt g z) = true) :
    cntAt g z ≤ nxtAt g z + 1 := by
  have hex : ∃ k : ℕ, pend (objAt g (z - (k : ℤ) - 1)) = false :=
    ⟨(z - s - 1).toNat, by rw [show z - (((z - s - 1).toNat : ℕ) : ℤ) - 1 = s by omega]; exact hidle⟩
  have hk := Nat.find_spec hex
  have hmin : ∀ i : ℕ, i < Nat.find hex → pend (objAt g (z - (i : ℤ) - 1)) = true := by
    intro i hi
    have := Nat.find_min hex hi
    simpa using this
  set k := Nat.find hex with hkdef
  have hall : ∀ i : ℕ, i ≤ k → pend (objAt g (z - (i : ℤ))) = true := by
    intro i hi
    cases i with
    | zero => simpa using hz
    | succ j =>
      have := hmin j (by omega)
      rwa [show z - ((j + 1 : ℕ) : ℤ) = z - (j : ℤ) - 1 by push_cast; ring]
  have hpin := cntAt_eq_nxtAt_of_idle_pend g hg (z - (k : ℤ) - 1) hk
    (by rw [show z - (k : ℤ) - 1 + 1 = z - (k : ℤ) by ring]; exact hall k le_rfl)
  rw [show z - (k : ℤ) - 1 + 1 = z - (k : ℤ) by ring] at hpin
  have hback := cntAt_add_of_pend_back g hg z k hall
  have hlip := nxtAt_lipschitz g hg (z - (k : ℤ) - 1) (k + 1)
  rw [show z - (k : ℤ) - 1 + ((k + 1 : ℕ) : ℤ) = z by push_cast; ring] at hlip
  omega

end Glue

/-! ### The separating formula -/

/-- The constant idle path with register `r`. -/
def gI (r : ℕ) : ℤ → LadderState Qc pendC := fun _ => ⟨((1 : Qc), 0, r), fun _ => rfl⟩

theorem gI_isPath (r : ℕ) : IsLadderPath stepC pendC (gI r) := by
  intro u
  refine ⟨rfl, fun _ => rfl, Or.inl rfl, ?_⟩
  show Count (pendC 1) (pendC 1) 0 r 0
  simp [Count, pendC_one]

/-- `P ¬p`: the pending bit was released at some earlier time. -/
def pastIdleC : PlusFormula := .snce (.imp .bot .bot) (PlusFormula.neg (.atom pC))

/-- **THE SEPARATING FORMULA.** `⊡ X ⊡ ¬ P ¬p`: on every history through this state, one step
on, every history through the state reached there has been pending at every earlier time. -/
def thetaC : PlusFormula := .stab (nxtF (.stab (PlusFormula.neg pastIdleC)))

theorem truth_neg_pC_off (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (g : ℤ → LadderState Qc pendC) (k : ℤ) (hτ : ∀ t : ℤ, τ.state t = (t + k, g t)) (s : ℤ) :
    PlusTruthAt MC τ s (PlusFormula.neg (.atom pC)) ↔ pendC (objAt g s) = false := by
  show (labC (τ.state s).2.1.1 pC = true → False) ↔ _
  rw [hτ s]
  show (labC (objAt g s) pC = true → False) ↔ _
  rw [labC_pC]
  cases pendC (objAt g s) <;> simp

theorem truth_pastIdleC (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (g : ℤ → LadderState Qc pendC) (k : ℤ) (hτ : ∀ t : ℤ, τ.state t = (t + k, g t)) (t : ℤ) :
    PlusTruthAt MC τ t pastIdleC ↔ ∃ s : ℤ, s < t ∧ pendC (objAt g s) = false := by
  constructor
  · rintro ⟨s, hs, h, -⟩
    exact ⟨s, hs, (truth_neg_pC_off τ g k hτ s).mp h⟩
  · rintro ⟨s, hs, h⟩
    exact ⟨s, hs, (truth_neg_pC_off τ g k hτ s).mpr h, fun _ _ _ hf => hf⟩

theorem dBack_thetaC : dBack thetaC = 1 := rfl

theorem dFwd_thetaC : dFwd thetaC = 1 := rfl

/-- (K4)'s least admissible gap clip at the separating formula is `3`. -/
theorem Bof_thetaC : Bof stepC pendC labC thetaC = 3 := by
  unfold Bof
  rw [dBack_thetaC, dFwd_thetaC]
  rfl

/-- **NEGATIVE MEMBERSHIP: gap `n - c = -3`.** At the pending state with countdown `n + 3` and
register `n`, no realized type contains the separating formula: one step on the register can have
risen to `n + 1` against a countdown `n + 2`, and that state is also reached one step after an
idle state with register `n + 2`. -/
theorem thetaC_not_mem (n : ℕ) (T : Finset PlusFormula)
    (hT : T ∈ cellAt MC thetaC
      ((0, stC (n + 3) n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    thetaC ∉ T := by
  obtain ⟨τ, hs, rfl⟩ := hT
  rw [mem_tpOf_iff]
  rintro ⟨-, h⟩
  -- the common future: the path through `(n + 2, n + 1)` at time `1`
  have hfut := shiftPath_isPath (gC (n + 2) (n + 1)) (gC_isPath (n + 2) (n + 1)) 1
  have hfut1 : gC (n + 2) (n + 1) (0 + 1 - 1) = stC (n + 2) (n + 1) := by
    rw [show (0 : ℤ) + 1 - 1 = 0 by norm_num, gC_zero_eq]
  -- `σ`: through `(n + 3, n)` at `0`, register rising
  have hσp : IsLadderPath stepC pendC
      (gluePath (gC (n + 3) n) (fun v : ℤ => gC (n + 2) (n + 1) (v - 1)) 0) := by
    refine gluePath_isPath _ _ (gC_isPath _ _) hfut 0 ?_
    rw [hfut1, gC_zero_eq]
    refine ⟨rfl, admZeroC _ _, Or.inr (Or.inl rfl), ?_⟩
    show Count (pendC 0) (pendC 0) (n + 3) n (n + 2)
    simp [Count, pendC_zero]
  -- `ρ`: idle at `0` with register `n + 2`, the same state at `1`
  have hρp : IsLadderPath stepC pendC
      (gluePath (gI (n + 2)) (fun v : ℤ => gC (n + 2) (n + 1) (v - 1)) 0) := by
    refine gluePath_isPath _ _ (gI_isPath _) hfut 0 ?_
    rw [hfut1]
    refine ⟨rfl, fun _ => rfl, Or.inr (Or.inr rfl), ?_⟩
    show Count (pendC 1) (pendC 0) 0 (n + 2) (n + 2)
    simp [Count, pendC_zero, pendC_one]
  obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath fwdC bwdC _ hσp
  obtain ⟨ρ, hρ⟩ := exists_hist_of_isLadderPath fwdC bwdC _ hρp
  have h1 : PlusTruthAt MC σ 0 (nxtF (.stab (PlusFormula.neg pastIdleC))) := by
    refine h σ ?_
    rw [hs, hσ 0, gluePath_of_le _ _ 0 0 le_rfl, gC_zero_eq]
  rw [truth_nxtF] at h1
  have h2 : PlusTruthAt MC ρ (0 + 1) pastIdleC → False := by
    refine h1 ρ ?_
    rw [hσ (0 + 1), hρ (0 + 1), gluePath_of_gt _ _ 0 (0 + 1) (by norm_num),
      gluePath_of_gt _ _ 0 (0 + 1) (by norm_num)]
  refine h2 ((truth_pastIdleC ρ _ 0 (fun t => by rw [hρ t, add_zero]) (0 + 1)).mpr
    ⟨0, by norm_num, ?_⟩)
  show pendC (gluePath (gI (n + 2)) (fun v : ℤ => gC (n + 2) (n + 1) (v - 1)) 0 0).1.1 = false
  rw [gluePath_of_le _ _ 0 0 le_rfl]
  exact pendC_one

/-- **POSITIVE MEMBERSHIP: gap `n - c ≤ -4`.** At a pending state whose countdown exceeds its
register by at least four, every realized type contains the separating formula: one step on the
countdown still exceeds the register by at least two, and `cnt_le_nxt_succ_of_past_idle` leaves
such a state no history with an idle past. -/
theorem thetaC_mem (c n : ℕ) (hgap : n + 4 ≤ c) (T : Finset PlusFormula)
    (hT : T ∈ cellAt MC thetaC
      ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    thetaC ∈ T := by
  obtain ⟨τ, hs, rfl⟩ := hT
  rw [mem_tpOf_iff]
  refine ⟨self_mem_plusSubformulaClosure _, fun σ hσ => ?_⟩
  show PlusTruthAt MC σ 0 (nxtF (.stab (PlusFormula.neg pastIdleC)))
  rw [truth_nxtF]
  intro ρ hρ hpast
  obtain ⟨k, g, hg, hp⟩ := exists_isLadderPath_of_hist fwdC bwdC σ
  obtain ⟨k', g', hg', hp'⟩ := exists_isLadderPath_of_hist fwdC bwdC ρ
  have h0 : ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) = (0 + k, g 0) :=
    hs.symm.trans (hσ.trans (hp 0))
  have hg0 : g 0 = stC c n := (congrArg Prod.snd h0).symm
  have h1 : ((0 + 1 + k, g (0 + 1)) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState)
      = (0 + 1 + k', g' (0 + 1)) := (hp (0 + 1)).symm.trans (hρ.trans (hp' (0 + 1)))
  have hg1 : g (0 + 1) = g' (0 + 1) := congrArg Prod.snd h1
  have hobj : objAt g 0 = 0 := by rw [objAt, hg0]; rfl
  have hcnt : cntAt g 0 = c := by rw [cntAt, hg0]; rfl
  have hnxt : nxtAt g 0 = n := by rw [nxtAt, hg0]; rfl
  have e1 : (0 : ℤ) + ((1 : ℕ) : ℤ) = 0 + 1 := by norm_num
  have hstep := cntAt_sub_of_pend g hg 0 (by rw [hobj]; exact pendC_zero) 1 (by omega)
  have hlip := nxtAt_lipschitz g hg 0 1
  rw [e1] at hstep hlip
  obtain ⟨s, hs1, hidle⟩ := (truth_pastIdleC ρ g' k' hp' (0 + 1)).mp hpast
  have hcap := cnt_le_nxt_succ_of_past_idle g' hg' (0 + 1) s hs1 hidle
    (by rw [show objAt g' (0 + 1) = objAt g (0 + 1) by rw [objAt, objAt, hg1]]; exact hstep.1)
  rw [show cntAt g' (0 + 1) = cntAt g (0 + 1) by rw [cntAt, cntAt, hg1],
    show nxtAt g' (0 + 1) = nxtAt g (0 + 1) by rw [nxtAt, nxtAt, hg1]] at hcap
  have hs2 := hstep.2
  omega

/-- **THE COLLISION.** At every threshold pair, every modulus and the gap clip `3`, the counter
pairs `(Tc + 3, Tc)` and `(Tc + 3 + (P + 1), Tc)` have the same class: both countdowns are at or
above `Tc`, they differ by the modulus, the register is shared, and both gaps are at or below
`-3`, where the clip stops reading. -/
theorem kappa_collision_theta (Tc Tn P : ℕ) :
    kappa Tc Tn P 3 (Tc + 3, Tc) = kappa Tc Tn P 3 (Tc + 3 + (P + 1), Tc) := by
  unfold kappa
  refine Prod.ext (Fin.ext ?_) (Prod.ext (Fin.ext ?_) (Prod.ext rfl (Prod.ext rfl (Fin.ext ?_))))
  · show min (Tc + 3) Tc = min (Tc + 3 + (P + 1)) Tc
    omega
  · show (Tc + 3) % (P + 1) = (Tc + 3 + (P + 1)) % (P + 1)
    rw [Nat.add_mod_right]
  · show clipIdx 3 (Tc + 3) Tc = clipIdx 3 (Tc + 3 + (P + 1)) Tc
    unfold clipIdx
    split_ifs <;> omega

/-- **THE CELLS DIFFER.** -/
theorem thetaC_cell_ne (n c' : ℕ) (hgap : n + 4 ≤ c') :
    cellAt MC thetaC ((0, stC (n + 3) n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
      ≠ cellAt MC thetaC
          ((0, stC c' n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 := by
  intro heq
  obtain ⟨T, hT⟩ := cellC_nonempty thetaC (n + 3) n
  exact thetaC_not_mem n T hT (thetaC_mem c' n hgap T (heq ▸ hT))

/-- **THE REFUTATION TARGET HOLDS.** At the separating formula and the periodicity fixpoint's own
four parameter outputs for it — which satisfy `ParamsOk` by `paramsOk_params` — the counter pairs
`(Tc + 3, Tc)` and `(Tc + 3 + (P + 1), Tc)` are a `kappa`-collision at the pending state of this
object, and their cells differ. -/
theorem refutationTargetC_holds : RefutationTargetC := by
  refine ⟨thetaC, Tcof stepC pendC labC thetaC, Tnof stepC pendC labC thetaC,
    Pof stepC pendC labC thetaC, Bof stepC pendC labC thetaC,
    Tcof stepC pendC labC thetaC + 3, Tcof stepC pendC labC thetaC,
    Tcof stepC pendC labC thetaC + 3 + (Pof stepC pendC labC thetaC + 1),
    Tcof stepC pendC labC thetaC, paramsOk_params stepC pendC labC thetaC, ?_, ?_⟩
  · rw [Bof_thetaC]
    exact kappa_collision_theta _ _ _
  · exact thetaC_cell_ne _ _ (by omega)

/-- **THE COUNT MOVE'S TARGET AT THIS OBJECT IS FALSE.** -/
theorem not_countMoveTargetC : ¬ CountMoveTargetC := by
  intro hmove
  obtain ⟨φ, Tc, Tn, P, B, c, n, c', n', hp, hk, hne⟩ := refutationTargetC_holds
  exact hne ((typePreservingCountMove_iff_cellAt_const fwdC bwdC labC φ Tc Tn P B).mp
    (hmove φ Tc Tn P B hp) 0 c n c' n' (admZeroC c n) (admZeroC c' n') hk)

/-- **THE FILED AGREEMENT'S SCHEMA IS FALSE.** The statement filed as `cellAt_const_of_kappa_eq`
— for every finite object, labelling, formula and parameter tuple satisfying `ParamsOk`, the cells
of a `kappa`-collision are equal at every world time and evaluation time — fails at the two-state
object, the separating formula, the periodicity fixpoint's own parameters, world time `0` and
evaluation time `0`.  The quantifier that fails is the one over the counter pairs of a collision
whose gaps both lie below the clip. -/
theorem cellAt_const_of_kappa_eq_schema_refuted :
    ¬ (∀ (Q : Type) [Fintype Q] [Nonempty Q]
        (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
        (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
        (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
        (phi : PlusFormula) (Tc Tn P B : ℕ), ParamsOk step pend lab phi Tc Tn P B →
        ∀ (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q),
          kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') → ∀ t z : ℤ,
          cellAt (ladderModel step pend fwd bwd lab) phi
              ((t, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z
            = cellAt (ladderModel step pend fwd bwd lab) phi
              ((t, ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z) := by
  intro hall
  obtain ⟨φ, Tc, Tn, P, B, c, n, c', n', hp, hk, hne⟩ := refutationTargetC_holds
  exact hne (hall Qc stepC pendC labC fwdC bwdC φ Tc Tn P B hp 0 c n c' n'
    (admZeroC c n) (admZeroC c' n') hk 0 0)


/-- **NO FIBRE EQUATION OVER `kappa`.** Whatever the right-hand side is, the cell at the pending
state of this object is not a function of the counter class at the separating formula and the
periodicity fixpoint's own parameters.  The statement filed as `ladderRealized` equates the cell
with a set read off `(q, kappa (c, n))` alone, so it is an instance of what is refuted here. -/
theorem no_fibre_equation_over_kappa :
    ¬ ∃ F : CK (Tcof stepC pendC labC thetaC) (Tnof stepC pendC labC thetaC)
        (Pof stepC pendC labC thetaC) (Bof stepC pendC labC thetaC) → Set (Finset PlusFormula),
      ∀ c n : ℕ,
        cellAt MC thetaC ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
          = F (kappa (Tcof stepC pendC labC thetaC) (Tnof stepC pendC labC thetaC)
            (Pof stepC pendC labC thetaC) (Bof stepC pendC labC thetaC) (c, n)) := by
  rintro ⟨F, hF⟩
  have hk : kappa (Tcof stepC pendC labC thetaC) (Tnof stepC pendC labC thetaC)
      (Pof stepC pendC labC thetaC) (Bof stepC pendC labC thetaC)
        (Tcof stepC pendC labC thetaC + 3, Tcof stepC pendC labC thetaC)
      = kappa (Tcof stepC pendC labC thetaC) (Tnof stepC pendC labC thetaC)
        (Pof stepC pendC labC thetaC) (Bof stepC pendC labC thetaC)
        (Tcof stepC pendC labC thetaC + 3 + (Pof stepC pendC labC thetaC + 1),
          Tcof stepC pendC labC thetaC) := by
    rw [Bof_thetaC]
    exact kappa_collision_theta _ _ _
  refine thetaC_cell_ne (Tcof stepC pendC labC thetaC)
    (Tcof stepC pendC labC thetaC + 3 + (Pof stepC pendC labC thetaC + 1)) (by omega) ?_
  rw [hF, hF, hk]

/-- **NO TRANSFER SYSTEM LINKS THE COLLISIONS.** At the separating formula and the periodicity
fixpoint's own parameters, no whole-language transfer system carries the link
`typePreservingCountMove_of_transferSys` consumes: the count move it would deliver is false at
this object. -/
theorem no_transferSys_links_collisions
    (R : ℕ → WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame → ℤ →
      WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame → ℤ → Prop)
    (hR : TransferSys MC True True R) :
    ¬ (∀ (q : Qc) (c n c' n' : ℕ) (h : c ∈ Adm pendC q) (h' : c' ∈ Adm pendC q),
      kappa (Tcof stepC pendC labC thetaC) (Tnof stepC pendC labC thetaC)
          (Pof stepC pendC labC thetaC) (Bof stepC pendC labC thetaC) (c, n)
        = kappa (Tcof stepC pendC labC thetaC) (Tnof stepC pendC labC thetaC)
          (Pof stepC pendC labC thetaC) (Bof stepC pendC labC thetaC) (c', n') →
      ∀ (g : ℤ → LadderState Qc pendC)
        (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame),
        IsLadderPath stepC pendC g → g 0 = (⟨(q, c, n), h⟩ : LadderState Qc pendC) →
        (∀ t : ℤ, τ.state t = (t, g t)) →
        ∃ (g' : ℤ → LadderState Qc pendC)
          (τ' : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame),
          IsLadderPath stepC pendC g' ∧ g' 0 = (⟨(q, c', n'), h'⟩ : LadderState Qc pendC) ∧
          (∀ t : ℤ, τ'.state t = (t, g' t)) ∧
          R ((plusSubformulaClosure thetaC).sup opDepth) τ 0 τ' 0) := by
  intro hlink
  have hmove := typePreservingCountMove_of_transferSys fwdC bwdC labC thetaC
    (Tcof stepC pendC labC thetaC) (Tnof stepC pendC labC thetaC)
    (Pof stepC pendC labC thetaC) (Bof stepC pendC labC thetaC) R hR hlink
  have hcell := (typePreservingCountMove_iff_cellAt_const fwdC bwdC labC thetaC
    (Tcof stepC pendC labC thetaC) (Tnof stepC pendC labC thetaC)
    (Pof stepC pendC labC thetaC) (Bof stepC pendC labC thetaC)).mp hmove
  apply no_fibre_equation_over_kappa
  refine ⟨fun κ => {T | ∃ c n : ℕ, kappa (Tcof stepC pendC labC thetaC)
    (Tnof stepC pendC labC thetaC) (Pof stepC pendC labC thetaC)
    (Bof stepC pendC labC thetaC) (c, n) = κ ∧
    T ∈ cellAt MC thetaC
      ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0}, fun c n => ?_⟩
  ext T
  constructor
  · intro hT
    exact ⟨c, n, rfl, hT⟩
  · rintro ⟨c', n', hk, hT⟩
    have := hcell 0 c' n' c n (admZeroC c' n') (admZeroC c n) hk
    exact this ▸ hT

/-- **CONDITION (5) FAILS ON EVERY SET CONTAINING THE REALIZED TRIPLES.** At the separating
formula, the gap clip `3` and any thresholds and modulus: a set of `(object, closure type,
counter class)` triples containing the triple of every history through every pending state of
this object at time `0` is not `certStabK`-certified.  The fibre over the class of
`(Tc + 3, Tc)` holds a type carrying the `⊡` letter and a type in which its argument fails. -/
theorem certStabK_fails_of_contains_realized (Tc Tn P : ℕ)
    (R : Set (Qc × ClType thetaC × CK Tc Tn P 3))
    (hR : ∀ (c n : ℕ) (σ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame),
      σ.state 0 = ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) →
      (((0 : Qc), ⟨tpOf MC thetaC σ 0, Finset.mem_powerset.mpr (tpOf_subset MC thetaC σ 0)⟩,
        kappa Tc Tn P 3 (c, n)) : Qc × ClType thetaC × CK Tc Tn P 3) ∈ R) :
    ¬ certStabK thetaC Tc Tn P 3 R := by
  intro hcert
  -- a history through the state where the letter holds
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwdC bwdC (gC (Tc + 3 + (P + 1)) Tc)
    (gC_isPath _ _)
  have hs' : τ'.state 0
      = ((0, stC (Tc + 3 + (P + 1)) Tc) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) := by
    rw [hτ' 0, gC_zero_eq]
  have hθ' : thetaC ∈ tpOf MC thetaC τ' 0 :=
    thetaC_mem (Tc + 3 + (P + 1)) Tc (by omega) _ ⟨τ', hs', rfl⟩
  -- a history through the state where the letter's argument fails
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdC bwdC (gC (Tc + 3) Tc) (gC_isPath _ _)
  have hs : τ.state 0
      = ((0, stC (Tc + 3) Tc) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) := by
    rw [hτ 0, gC_zero_eq]
  have hθ : thetaC ∉ tpOf MC thetaC τ 0 := thetaC_not_mem Tc _ ⟨τ, hs, rfl⟩
  have hfalse : ¬ PlusTruthAt MC τ 0 thetaC := fun h =>
    hθ ((mem_tpOf_iff _ _ _ _ _).mpr ⟨self_mem_plusSubformulaClosure _, h⟩)
  have hex : ∃ σ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame,
      τ.state 0 = σ.state 0 ∧
      ¬ PlusTruthAt MC σ 0 (nxtF (.stab (PlusFormula.neg pastIdleC))) := by
    by_contra hn
    exact hfalse (fun σ e => by_contra (fun hσ => hn ⟨σ, e, hσ⟩))
  obtain ⟨σ, hσe, hσ⟩ := hex
  have hall := (hcert _ (hR _ _ τ' hs') thetaC (self_mem_plusSubformulaClosure _) rfl).mp hθ'
  have hmem := hall _ (hR (Tc + 3) Tc σ (hσe.symm.trans hs)) rfl (kappa_collision_theta Tc Tn P)
  exact hσ ((mem_tpOf_iff _ _ _ _ _).mp hmem).2

#print axioms Probe761C.gluePath_isPath
#print axioms Probe761C.cnt_le_nxt_succ_of_past_idle
#print axioms Probe761C.thetaC_not_mem
#print axioms Probe761C.thetaC_mem
#print axioms Probe761C.kappa_collision_theta
#print axioms Probe761C.thetaC_cell_ne
#print axioms Probe761C.refutationTargetC_holds
#print axioms Probe761C.not_countMoveTargetC
#print axioms Probe761C.cellAt_const_of_kappa_eq_schema_refuted
#print axioms Probe761C.no_fibre_equation_over_kappa
#print axioms Probe761C.no_transferSys_links_collisions
#print axioms Probe761C.certStabK_fails_of_contains_realized

end Probe761C

namespace Probe761C

/-! ### (K4)'s shape: the larger of the two exactness depths is exceeded without bound -/

/-- Conjunction, in the primitive connectives. -/
def andF (a b : PlusFormula) : PlusFormula := PlusFormula.neg (.imp a (PlusFormula.neg b))

/-- Disjunction, in the primitive connectives. -/
def orF (a b : PlusFormula) : PlusFormula := .imp (PlusFormula.neg a) b

/-- `Y ψ`, written with the strict `snce` at the guard `⊥`. -/
def prvF (ψ : PlusFormula) : PlusFormula := .snce .bot ψ

/-- The dual of `⊡`: some history through this state. -/
def diaF (ψ : PlusFormula) : PlusFormula := PlusFormula.neg (.stab (PlusFormula.neg ψ))

theorem truth_andF (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (t : ℤ) (a b : PlusFormula) :
    PlusTruthAt MC τ t (andF a b) ↔ PlusTruthAt MC τ t a ∧ PlusTruthAt MC τ t b := by
  show ((PlusTruthAt MC τ t a → (PlusTruthAt MC τ t b → False)) → False) ↔ _
  tauto

theorem truth_orF (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (t : ℤ) (a b : PlusFormula) :
    PlusTruthAt MC τ t (orF a b) ↔ PlusTruthAt MC τ t a ∨ PlusTruthAt MC τ t b := by
  show ((PlusTruthAt MC τ t a → False) → PlusTruthAt MC τ t b) ↔ _
  tauto

theorem int_lt_pred_of_ne (t s : ℤ) (h : s < t) (hne : s ≠ t - 1) : s < t - 1 := by omega

theorem int_pred_lt (t : ℤ) : t - 1 < t := by omega

theorem int_not_between_pred (t r : ℤ) (h1 : t - 1 < r) (h2 : r < t) : False := by omega

theorem truth_prvF (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (t : ℤ) (ψ : PlusFormula) :
    PlusTruthAt MC τ t (prvF ψ) ↔ PlusTruthAt MC τ (t - 1) ψ := by
  constructor
  · rintro ⟨s, hst, hs, hr⟩
    by_cases he : s = t - 1
    · rw [he] at hs
      exact hs
    · exact (hr (t - 1) (int_lt_pred_of_ne t s hst he) (int_pred_lt t)).elim
  · intro h
    exact ⟨t - 1, int_pred_lt t, h, fun r h1 h2 => (int_not_between_pred t r h1 h2).elim⟩

theorem truth_diaF (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (t : ℤ) (ψ : PlusFormula) :
    PlusTruthAt MC τ t (diaF ψ) ↔
      ∃ σ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame,
        τ.state t = σ.state t ∧ PlusTruthAt MC σ t ψ := by
  show ((∀ σ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame,
    τ.state t = σ.state t → (PlusTruthAt MC σ t ψ → False)) → False) ↔ _
  constructor
  · intro h
    by_contra hn
    exact h (fun σ e hψ => hn ⟨σ, e, hψ⟩)
  · rintro ⟨σ, e, hψ⟩ h
    exact h σ e hψ

theorem truth_pC_off (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (g : ℤ → LadderState Qc pendC) (k : ℤ) (hτ : ∀ t : ℤ, τ.state t = (t + k, g t)) (s : ℤ) :
    PlusTruthAt MC τ s (.atom pC) ↔ pendC (objAt g s) = true := by
  show labC (τ.state s).2.1.1 pC = true ↔ _
  rw [hτ s]
  show labC (objAt g s) pC = true ↔ _
  rw [labC_pC]

/-- `withinC k`: the pending bit is released at one of the next `k` positions. -/
def withinC : ℕ → PlusFormula
  | 0 => .bot
  | k + 1 => nxtF (orF (PlusFormula.neg (.atom pC)) (withinC k))

theorem truth_withinC (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (g : ℤ → LadderState Qc pendC) (k₀ : ℤ) (hτ : ∀ t : ℤ, τ.state t = (t + k₀, g t)) (k : ℕ) :
    ∀ t : ℤ, PlusTruthAt MC τ t (withinC k) ↔
      ∃ j : ℕ, 1 ≤ j ∧ j ≤ k ∧ pendC (objAt g (t + (j : ℤ))) = false := by
  induction k with
  | zero =>
    intro t
    show False ↔ _
    constructor
    · exact False.elim
    · rintro ⟨j, h1, h2, -⟩
      omega
  | succ k ih =>
    intro t
    rw [show withinC (k + 1) = nxtF (orF (PlusFormula.neg (.atom pC)) (withinC k)) from rfl,
      truth_nxtF, truth_orF, truth_neg_pC_off τ g k₀ hτ, ih]
    constructor
    · rintro (h | ⟨j, h1, h2, h3⟩)
      · exact ⟨1, le_rfl, by omega, by rw [show t + ((1 : ℕ) : ℤ) = t + 1 by norm_num]; exact h⟩
      · exact ⟨j + 1, by omega, by omega,
          by rw [show t + ((j + 1 : ℕ) : ℤ) = t + 1 + (j : ℤ) by push_cast; ring]; exact h3⟩
    · rintro ⟨j, h1, h2, h3⟩
      by_cases hj : j = 1
      · left
        subst hj
        rwa [show t + ((1 : ℕ) : ℤ) = t + 1 by norm_num] at h3
      · right
        refine ⟨j - 1, by omega, by omega, ?_⟩
        rwa [show t + 1 + ((j - 1 : ℕ) : ℤ) = t + (j : ℤ) by omega]

/-- **THE FORWARD READER.** `readC k`: the pending bit holds until it is released, the very next
position starts a new region, and that region is over within `k` positions.  At a pending state it
asks the register to come down to `k - 1` by the end of the current region. -/
def readC (k : ℕ) : PlusFormula :=
  .untl (.atom pC)
    (andF (PlusFormula.neg (.atom pC)) (nxtF (andF (.atom pC) (withinC k))))

theorem truth_readC (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (g : ℤ → LadderState Qc pendC) (k₀ : ℤ) (hτ : ∀ t : ℤ, τ.state t = (t + k₀, g t)) (k : ℕ)
    (t : ℤ) :
    PlusTruthAt MC τ t (readC k) ↔
      ∃ s : ℤ, t < s ∧ pendC (objAt g s) = false ∧ pendC (objAt g (s + 1)) = true ∧
        (∃ j : ℕ, 1 ≤ j ∧ j ≤ k ∧ pendC (objAt g (s + 1 + (j : ℤ))) = false) ∧
        ∀ r : ℤ, t < r → r < s → pendC (objAt g r) = true := by
  show (∃ s : ℤ, t < s ∧
    PlusTruthAt MC τ s (andF (PlusFormula.neg (.atom pC)) (nxtF (andF (.atom pC) (withinC k)))) ∧
      ∀ r : ℤ, t < r → r < s → PlusTruthAt MC τ r (.atom pC)) ↔ _
  constructor
  · rintro ⟨s, h1, h2, h3⟩
    rw [truth_andF, truth_neg_pC_off τ g k₀ hτ, truth_nxtF, truth_andF, truth_pC_off τ g k₀ hτ,
      truth_withinC τ g k₀ hτ] at h2
    exact ⟨s, h1, h2.1, h2.2.1, h2.2.2, fun r a b => (truth_pC_off τ g k₀ hτ r).mp (h3 r a b)⟩
  · rintro ⟨s, h1, h2, h3, h4, h5⟩
    refine ⟨s, h1, ?_, fun r a b => (truth_pC_off τ g k₀ hτ r).mpr (h5 r a b)⟩
    rw [truth_andF, truth_neg_pC_off τ g k₀ hτ, truth_nxtF, truth_andF, truth_pC_off τ g k₀ hτ,
      truth_withinC τ g k₀ hτ]
    exact ⟨h2, h3, h4⟩

/-- `backC a ψ`: step back `a` times through pending positions, then `ψ`. -/
def backC : ℕ → PlusFormula → PlusFormula
  | 0, ψ => ψ
  | a + 1, ψ => prvF (andF (.atom pC) (backC a ψ))

theorem truth_backC (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (g : ℤ → LadderState Qc pendC) (k₀ : ℤ) (hτ : ∀ t : ℤ, τ.state t = (t + k₀, g t))
    (ψ : PlusFormula) (a : ℕ) :
    ∀ t : ℤ, PlusTruthAt MC τ t (backC a ψ) ↔
      (∀ i : ℕ, 1 ≤ i → i ≤ a → pendC (objAt g (t - (i : ℤ))) = true) ∧
        PlusTruthAt MC τ (t - (a : ℤ)) ψ := by
  induction a with
  | zero =>
    intro t
    rw [show backC 0 ψ = ψ from rfl, show t - ((0 : ℕ) : ℤ) = t by norm_num]
    exact ⟨fun h => ⟨fun i h1 h2 => by omega, h⟩, fun h => h.2⟩
  | succ a ih =>
    intro t
    rw [show backC (a + 1) ψ = prvF (andF (.atom pC) (backC a ψ)) from rfl, truth_prvF,
      truth_andF, truth_pC_off τ g k₀ hτ, ih]
    constructor
    · rintro ⟨hp, hall, hψ⟩
      refine ⟨fun i h1 h2 => ?_, ?_⟩
      · by_cases hi : i = 1
        · subst hi
          rw [show t - ((1 : ℕ) : ℤ) = t - 1 by norm_num]
          exact hp
        · have := hall (i - 1) (by omega) (by omega)
          rwa [show t - 1 - ((i - 1 : ℕ) : ℤ) = t - (i : ℤ) by omega] at this
      · rwa [show t - ((a + 1 : ℕ) : ℤ) = t - 1 - (a : ℤ) by push_cast; ring]
    · rintro ⟨hall, hψ⟩
      refine ⟨?_, fun i h1 h2 => ?_, ?_⟩
      · have := hall 1 le_rfl (by omega)
        rwa [show t - ((1 : ℕ) : ℤ) = t - 1 by norm_num] at this
      · have := hall (i + 1) (by omega) (by omega)
        rwa [show t - ((i + 1 : ℕ) : ℤ) = t - 1 - (i : ℤ) by push_cast; ring] at this
      · rwa [show t - ((a + 1 : ℕ) : ℤ) = t - 1 - (a : ℤ) by push_cast; ring] at hψ

/-- **THE MIXED FAMILY.** `◇ Y_p^a ◇ readC k`: some history through this state was pending at the
`a` previous positions, and some history through the state it carried `a` steps ago satisfies the
forward reader.  The backward steps lower the gap by two each; the reader then reads it at
`k`. -/
def mixC (a k : ℕ) : PlusFormula := diaF (backC a (diaF (readC k)))

/-! #### Its two exactness depths -/

theorem dBack_withinC (k : ℕ) : dBack (withinC k) = 0 := by
  induction k with
  | zero => rfl
  | succ k ih =>
    show max (dBack PlusFormula.bot) (max (max (max (dBack (PlusFormula.atom pC)) 0) 0)
      (dBack (withinC k))) = 0
    rw [ih]; rfl

theorem dFwd_withinC (k : ℕ) : dFwd (withinC k) = k := by
  induction k with
  | zero => rfl
  | succ k ih =>
    show max (dFwd PlusFormula.bot) (max (max (max (dFwd (PlusFormula.atom pC)) 0) 0)
      (dFwd (withinC k))) + 1 = k + 1
    rw [ih]
    show max 0 (max (max (max 0 0) 0) k) + 1 = k + 1
    omega

theorem dBack_readC (k : ℕ) : dBack (readC k) = 0 := by
  have h := dBack_withinC k
  simp only [readC, andF, nxtF, PlusFormula.neg, dBack, h]
  rfl

theorem dFwd_readC (k : ℕ) : dFwd (readC k) = k + 2 := by
  have h := dFwd_withinC k
  simp only [readC, andF, nxtF, PlusFormula.neg, dFwd, h]
  omega

theorem dBack_backC (a : ℕ) (ψ : PlusFormula) : dBack (backC a ψ) = a + dBack ψ := by
  induction a with
  | zero => simp [backC]
  | succ a ih =>
    simp only [backC, prvF, andF, PlusFormula.neg, dBack, ih]
    omega

theorem dFwd_backC (a : ℕ) (ψ : PlusFormula) : dFwd (backC a ψ) = dFwd ψ := by
  induction a with
  | zero => simp [backC]
  | succ a ih =>
    simp only [backC, prvF, andF, PlusFormula.neg, dFwd, ih]
    omega

theorem dBack_mixC (a k : ℕ) : dBack (mixC a k) = a := by
  have h1 := dBack_backC a (diaF (readC k))
  have h2 := dBack_readC k
  simp only [mixC, diaF, PlusFormula.neg, dBack] at h1 ⊢
  omega

theorem dFwd_mixC (a k : ℕ) : dFwd (mixC a k) = k + 2 := by
  have h1 := dFwd_backC a (diaF (readC k))
  have h2 := dFwd_readC k
  simp only [mixC, diaF, PlusFormula.neg, dFwd] at h1 ⊢
  omega

/-- (K4)'s least admissible gap clip at `mixC (k + 2) k` is `2 k + 5`. -/
theorem Bof_mixC (k : ℕ) : Bof stepC pendC labC (mixC (k + 2) k) = 2 * k + 5 := by
  unfold Bof
  rw [dBack_mixC, dFwd_mixC]
  omega

/-! #### The reader fails above its gap -/

/-- **THE READER'S CEILING.** At a pending position whose register exceeds its countdown by more
than `k`, the forward reader fails: the register cannot come down to `k - 1` by the end of the
current region, so the region entered right after it lasts more than `k` positions. -/
theorem readC_false_of_gap (g : ℤ → LadderState Qc pendC) (hg : IsLadderPath stepC pendC g)
    (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame) (k₀ : ℤ)
    (hτ : ∀ t : ℤ, τ.state t = (t + k₀, g t)) (k : ℕ) (t : ℤ)
    (hp : pendC (objAt g t) = true) (hgap : cntAt g t + k + 1 ≤ nxtAt g t) :
    ¬ PlusTruthAt MC τ t (readC k) := by
  rw [truth_readC τ g k₀ hτ]
  rintro ⟨s, hts, hidle, hpend1, ⟨j, hj1, hjk, hjidle⟩, hguard⟩
  have hend := not_pend_of_count g hg t hp
  have hs : s = t + (cntAt g t : ℤ) + 1 := by
    rcases lt_trichotomy s (t + (cntAt g t : ℤ) + 1) with hlt | heq | hgt
    · have := (cntAt_sub_of_pend g hg t hp (s - t).toNat (by omega)).1
      rw [show t + (((s - t).toNat : ℕ) : ℤ) = s by omega] at this
      exact absurd (this.symm.trans hidle) (by simp)
    · exact heq
    · exact absurd ((hguard _ (by omega) hgt).symm.trans hend) (by simp)
  have hpin := cntAt_eq_nxtAt_of_idle_pend g hg s hidle hpend1
  have hlip := nxtAt_lipschitz g hg t (cntAt g t + 1)
  rw [show t + ((cntAt g t + 1 : ℕ) : ℤ) = s by rw [hs]; push_cast; ring] at hlip
  have := (cntAt_sub_of_pend g hg (s + 1) hpend1 j (by omega)).1
  exact absurd (this.symm.trans hjidle) (by simp)

/-- **NEGATIVE MEMBERSHIP: gap above `2 a + k`.** -/
theorem mixC_not_mem (a k c n : ℕ) (hgap : c + 2 * a + k + 1 ≤ n) (T : Finset PlusFormula)
    (hT : T ∈ cellAt MC (mixC a k)
      ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    mixC a k ∉ T := by
  obtain ⟨τ, hs, rfl⟩ := hT
  rw [mem_tpOf_iff]
  rintro ⟨-, h⟩
  obtain ⟨σ, hσ, hback⟩ := (truth_diaF τ 0 (backC a (diaF (readC k)))).mp h
  obtain ⟨k₀, g, hg, hp⟩ := exists_isLadderPath_of_hist fwdC bwdC σ
  rw [truth_backC σ g k₀ hp] at hback
  obtain ⟨hall, hdia⟩ := hback
  obtain ⟨ρ, hρ, hread⟩ := (truth_diaF σ _ _).mp hdia
  obtain ⟨k₁, g₁, hg₁, hp₁⟩ := exists_isLadderPath_of_hist fwdC bwdC ρ
  have h0 : ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) = (0 + k₀, g 0) :=
    hs.symm.trans (hσ.trans (hp 0))
  have hg0 : g 0 = stC c n := (congrArg Prod.snd h0).symm
  have hobj : objAt g 0 = 0 := by rw [objAt, hg0]; rfl
  have hcnt : cntAt g 0 = c := by rw [cntAt, hg0]; rfl
  have hnxt : nxtAt g 0 = n := by rw [nxtAt, hg0]; rfl
  have hpend : ∀ i : ℕ, i ≤ a → pendC (objAt g (0 - (i : ℤ))) = true := by
    intro i hi
    cases i with
    | zero => simpa [hobj] using pendC_zero
    | succ j => exact hall (j + 1) (by omega) hi
  have hback := cntAt_add_of_pend_back g hg 0 a hpend
  have hlip := nxtAt_lipschitz g hg (0 - (a : ℤ)) a
  rw [show (0 : ℤ) - (a : ℤ) + (a : ℤ) = 0 by ring] at hlip
  have h1 : ((0 - (a : ℤ) + k₀, g (0 - (a : ℤ))) :
      (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) = (0 - (a : ℤ) + k₁, g₁ (0 - (a : ℤ))) :=
    (hp (0 - (a : ℤ))).symm.trans (hρ.trans (hp₁ (0 - (a : ℤ))))
  have hg1 : g (0 - (a : ℤ)) = g₁ (0 - (a : ℤ)) := congrArg Prod.snd h1
  refine readC_false_of_gap g₁ hg₁ ρ k₁ hp₁ k (0 - (a : ℤ)) ?_ ?_ hread
  · rw [show objAt g₁ (0 - (a : ℤ)) = objAt g (0 - (a : ℤ)) by rw [objAt, objAt, hg1]]
    exact hpend a le_rfl
  · rw [show cntAt g₁ (0 - (a : ℤ)) = cntAt g (0 - (a : ℤ)) by rw [cntAt, cntAt, hg1],
      show nxtAt g₁ (0 - (a : ℤ)) = nxtAt g (0 - (a : ℤ)) by rw [nxtAt, nxtAt, hg1]]
    omega

/-! #### The two ramps -/

/-- A ladder path whose register RISES at each of `m` consecutive pending steps. -/
theorem exists_upRamp (m c : ℕ) : ∀ n : ℕ, ∃ g : ℤ → LadderState Qc pendC,
    IsLadderPath stepC pendC g ∧ g 0 = stC (c + m) n ∧ g (m : ℤ) = stC c (n + m) := by
  induction m with
  | zero =>
    intro n
    exact ⟨gC c n, gC_isPath c n, gC_zero_eq c n, by simpa using gC_zero_eq c n⟩
  | succ m ih =>
    intro n
    obtain ⟨g, hg, h0, hm⟩ := ih (n + 1)
    refine ⟨gluePath (gC (c + m + 1) n) (fun v : ℤ => g (v - 1)) 0,
      gluePath_isPath _ _ (gC_isPath _ _) (shiftPath_isPath g hg 1) 0 ?_, ?_, ?_⟩
    · show RladAdm stepC pendC 0 (gC (c + m + 1) n 0) (g (0 + 1 - 1))
      rw [show (0 : ℤ) + 1 - 1 = 0 by norm_num, h0, gC_zero_eq]
      refine ⟨rfl, admZeroC _ _, Or.inr (Or.inl rfl), ?_⟩
      show Count (pendC 0) (pendC 0) (c + m + 1) n (c + m)
      simp [Count, pendC_zero]
    · rw [gluePath_of_le _ _ 0 0 le_rfl, gC_zero_eq]
      rfl
    · rw [gluePath_of_gt _ _ 0 _ (by push_cast; omega)]
      show g (((m + 1 : ℕ) : ℤ) - 1) = _
      rw [show ((m + 1 : ℕ) : ℤ) - 1 = (m : ℤ) by push_cast; ring, hm,
        show n + 1 + m = n + (m + 1) by omega]

/-- A ladder path whose register FALLS at each of `m` consecutive pending steps. -/
theorem exists_downRamp (m c n : ℕ) : ∃ g : ℤ → LadderState Qc pendC,
    IsLadderPath stepC pendC g ∧ g 0 = stC (c + m) (n + m) ∧ g (m : ℤ) = stC c n := by
  induction m with
  | zero => exact ⟨gC c n, gC_isPath c n, gC_zero_eq c n, by simpa using gC_zero_eq c n⟩
  | succ m ih =>
    obtain ⟨g, hg, h0, hm⟩ := ih
    refine ⟨gluePath (gC (c + m + 1) (n + m + 1)) (fun v : ℤ => g (v - 1)) 0,
      gluePath_isPath _ _ (gC_isPath _ _) (shiftPath_isPath g hg 1) 0 ?_, ?_, ?_⟩
    · show RladAdm stepC pendC 0 (gC (c + m + 1) (n + m + 1) 0) (g (0 + 1 - 1))
      rw [show (0 : ℤ) + 1 - 1 = 0 by norm_num, h0, gC_zero_eq]
      refine ⟨rfl, admZeroC _ _, Or.inr (Or.inr rfl), ?_⟩
      show Count (pendC 0) (pendC 0) (c + m + 1) (n + m + 1) (c + m)
      simp [Count, pendC_zero]
    · rw [gluePath_of_le _ _ 0 0 le_rfl, gC_zero_eq]
      rfl
    · rw [gluePath_of_gt _ _ 0 _ (by push_cast; omega)]
      show g (((m + 1 : ℕ) : ℤ) - 1) = _
      rw [show ((m + 1 : ℕ) : ℤ) - 1 = (m : ℤ) by push_cast; ring, hm]

/-- **POSITIVE MEMBERSHIP: gap exactly `2 a + k`.** The register rose at each of the `a` steps
before `0`, so `a` steps back the gap was `k`; from that state the register can fall at every
remaining step of the region, reach `k` at its last position and `k - 1` at the idle position
after it, and the region entered there lasts exactly `k` positions. -/
theorem mixC_mem (a k c : ℕ) (hk : 1 ≤ k) (T : Finset PlusFormula)
    (hT : T ∈ cellAt MC (mixC a k)
      ((0, stC c (c + 2 * a + k)) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    mixC a k ∈ T := by
  obtain ⟨τ, hs, rfl⟩ := hT
  rw [mem_tpOf_iff]
  refine ⟨self_mem_plusSubformulaClosure _, ?_⟩
  obtain ⟨gu, hgu, hu0, hua⟩ := exists_upRamp a c (c + a + k)
  rw [show c + a + k + a = c + 2 * a + k by omega] at hua
  obtain ⟨gd, hgd, hd0, hdm⟩ := exists_downRamp (c + a) 0 k
  rw [show 0 + (c + a) = c + a by omega, show k + (c + a) = c + a + k by omega] at hd0
  obtain ⟨M, hM⟩ : ∃ M : ℤ, M = ((c + a : ℕ) : ℤ) := ⟨_, rfl⟩
  rw [← hM] at hdm
  have hMc : M = (c : ℤ) + (a : ℤ) := by rw [hM]; push_cast; ring
  -- the tail: idle at `M + 1` with register `k - 1`, then a region of exactly `k` positions
  have htail : IsLadderPath stepC pendC
      (gluePath (gI (k - 1)) (fun v : ℤ => gC (k - 1) (k - 1) (v - (M + 2))) (M + 1)) := by
    refine gluePath_isPath _ _ (gI_isPath _)
      (shiftPath_isPath _ (gC_isPath (k - 1) (k - 1)) (M + 2)) (M + 1) ?_
    show RladAdm stepC pendC (M + 1) (gI (k - 1) (M + 1)) (gC (k - 1) (k - 1) (M + 1 + 1 - (M + 2)))
    rw [show M + 1 + 1 - (M + 2) = 0 by ring, gC_zero_eq]
    refine ⟨rfl, fun _ => rfl, Or.inl rfl, ?_⟩
    show Count (pendC 1) (pendC 0) 0 (k - 1) (k - 1)
    simp [Count, pendC_zero, pendC_one]
  have hρ0 : IsLadderPath stepC pendC (gluePath gd
      (gluePath (gI (k - 1)) (fun v : ℤ => gC (k - 1) (k - 1) (v - (M + 2))) (M + 1)) M) := by
    refine gluePath_isPath _ _ hgd htail M ?_
    rw [hdm, gluePath_of_le _ _ (M + 1) (M + 1) le_rfl]
    refine ⟨rfl, admZeroC _ _, Or.inr (Or.inr (show k - 1 + 1 = k by omega)), ?_⟩
    show Count (pendC 0) (pendC 1) 0 k 0
    simp [Count, pendC_zero, pendC_one]
  obtain ⟨ρ0, hρ0def⟩ : ∃ ρ0 : ℤ → LadderState Qc pendC, ρ0 = gluePath gd
      (gluePath (gI (k - 1)) (fun v : ℤ => gC (k - 1) (k - 1) (v - (M + 2))) (M + 1)) M :=
    ⟨_, rfl⟩
  rw [← hρ0def] at hρ0
  -- values of `ρ0`
  have hρlow : ∀ v : ℤ, v ≤ M → ρ0 v = gd v := fun v hv => by
    rw [hρ0def, gluePath_of_le _ _ M v hv]
  have hρidle : ρ0 (M + 1) = gI (k - 1) (M + 1) := by
    rw [hρ0def, gluePath_of_gt _ _ M (M + 1) (by omega), gluePath_of_le _ _ (M + 1) (M + 1) le_rfl]
  have hρhigh : ∀ v : ℤ, M + 1 < v → ρ0 v = gC (k - 1) (k - 1) (v - (M + 2)) := fun v hv => by
    rw [hρ0def, gluePath_of_gt _ _ M v (by omega), gluePath_of_gt _ _ (M + 1) v hv]
  obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath fwdC bwdC _ (shiftPath_isPath gu hgu (-(a : ℤ)))
  obtain ⟨ρ, hρ⟩ := exists_hist_of_isLadderPath fwdC bwdC _ (shiftPath_isPath ρ0 hρ0 (-(a : ℤ)))
  have hu_obj : objAt gu 0 = 0 := by rw [objAt, hu0]; rfl
  have hu_cnt : cntAt gu 0 = c + a := by rw [cntAt, hu0]; rfl
  have hd_obj : objAt gd 0 = 0 := by rw [objAt, hd0]; rfl
  have hd_cnt : cntAt gd 0 = c + a := by rw [cntAt, hd0]; rfl
  refine (truth_diaF τ 0 (backC a (diaF (readC k)))).mpr ⟨σ, ?_, ?_⟩
  · rw [hs, hσ 0]
    show _ = ((0 : ℤ), gu (0 - -(a : ℤ)))
    rw [show (0 : ℤ) - -(a : ℤ) = (a : ℤ) by ring, hua]
  · rw [truth_backC σ _ 0 (fun t => by rw [hσ t, add_zero])]
    refine ⟨fun i h1 h2 => ?_, (truth_diaF σ _ _).mpr ⟨ρ, ?_, ?_⟩⟩
    · show pendC (objAt gu (0 - (i : ℤ) - -(a : ℤ))) = true
      have := (cntAt_sub_of_pend gu hgu 0 (by rw [hu_obj]; exact pendC_zero) (a - i)
        (by omega)).1
      rwa [show (0 : ℤ) + ((a - i : ℕ) : ℤ) = 0 - (i : ℤ) - -(a : ℤ) by omega] at this
    · rw [hσ, hρ]
      show ((0 : ℤ) - (a : ℤ), gu (0 - (a : ℤ) - -(a : ℤ))) = (0 - (a : ℤ), ρ0 (0 - (a : ℤ) - -(a : ℤ)))
      rw [show (0 : ℤ) - (a : ℤ) - -(a : ℤ) = 0 by ring, hu0, hρlow 0 (by omega), hd0]
    · rw [truth_readC ρ _ 0 (fun t => by rw [hρ t, add_zero])]
      refine ⟨(c : ℤ) + 1, by omega, ?_, ?_, ⟨k, hk, le_rfl, ?_⟩, fun r hr1 hr2 => ?_⟩
      · show pendC (objAt ρ0 ((c : ℤ) + 1 - -(a : ℤ))) = false
        rw [show (c : ℤ) + 1 - -(a : ℤ) = M + 1 by omega, objAt, hρidle]
        exact pendC_one
      · show pendC (objAt ρ0 ((c : ℤ) + 1 + 1 - -(a : ℤ))) = true
        rw [show (c : ℤ) + 1 + 1 - -(a : ℤ) = M + 2 by omega, objAt, hρhigh _ (by omega),
          show M + 2 - (M + 2) = 0 by ring, gC_zero_eq]
        exact pendC_zero
      · show pendC (objAt ρ0 ((c : ℤ) + 1 + 1 + (k : ℤ) - -(a : ℤ))) = false
        rw [show (c : ℤ) + 1 + 1 + (k : ℤ) - -(a : ℤ) = M + 2 + (k : ℤ) by omega, objAt,
          hρhigh _ (by omega), show M + 2 + (k : ℤ) - (M + 2) = (k : ℤ) by ring]
        exact pendC_wC_of_gt (k - 1) (k : ℤ) (by omega)
      · show pendC (objAt ρ0 (r - -(a : ℤ))) = true
        rw [objAt, hρlow _ (by omega)]
        have := (cntAt_sub_of_pend gd hgd 0 (by rw [hd_obj]; exact pendC_zero)
          (r - -(a : ℤ)).toNat (by omega)).1
        rwa [show (0 : ℤ) + (((r - -(a : ℤ)).toNat : ℕ) : ℤ) = r - -(a : ℤ) by omega] at this

/-- **THE COLLISION ON THE POSITIVE SIDE.** A register at or above `Tn` and a gap at or above the
clip `B`: raising the register by the modulus stays in the class. -/
theorem kappa_collision_pos (Tc Tn P B c n : ℕ) (hn : Tn ≤ n) (hB : c + B ≤ n) :
    kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c, n + (P + 1)) := by
  unfold kappa
  refine Prod.ext rfl (Prod.ext rfl (Prod.ext (Fin.ext ?_) (Prod.ext (Fin.ext ?_) (Fin.ext ?_))))
  · show min n Tn = min (n + (P + 1)) Tn
    omega
  · show n % (P + 1) = (n + (P + 1)) % (P + 1)
    rw [Nat.add_mod_right]
  · show clipIdx B c n = clipIdx B c (n + (P + 1))
    unfold clipIdx
    split_ifs <;> omega

/-- **THE EXCESS IS UNBOUNDED.** For every `k ≥ 1`, at the formula `mixC (k + 2) k` and the
periodicity fixpoint's own parameter outputs: (K4)'s gap clip is `2 k + 5`, while the cell at the
pending state separates the gap `3 k + 4` from the gap one modulus above it — two counter pairs of
one `kappa`-class.  The separated gap exceeds the clip by `k - 1`: no constant added to the larger
of the two exactness depths repairs (K4). -/
theorem mixC_refutes (k : ℕ) (hk : 1 ≤ k) :
    Bof stepC pendC labC (mixC (k + 2) k) = 2 * k + 5 ∧
    ∃ c n n' : ℕ, n = c + (3 * k + 4) ∧
      ParamsOk stepC pendC labC (mixC (k + 2) k)
        (Tcof stepC pendC labC (mixC (k + 2) k)) (Tnof stepC pendC labC (mixC (k + 2) k))
        (Pof stepC pendC labC (mixC (k + 2) k)) (Bof stepC pendC labC (mixC (k + 2) k)) ∧
      kappa (Tcof stepC pendC labC (mixC (k + 2) k)) (Tnof stepC pendC labC (mixC (k + 2) k))
          (Pof stepC pendC labC (mixC (k + 2) k)) (Bof stepC pendC labC (mixC (k + 2) k)) (c, n)
        = kappa (Tcof stepC pendC labC (mixC (k + 2) k)) (Tnof stepC pendC labC (mixC (k + 2) k))
          (Pof stepC pendC labC (mixC (k + 2) k)) (Bof stepC pendC labC (mixC (k + 2) k)) (c, n') ∧
      cellAt MC (mixC (k + 2) k)
          ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
        ≠ cellAt MC (mixC (k + 2) k)
          ((0, stC c n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 := by
  refine ⟨Bof_mixC k, Tnof stepC pendC labC (mixC (k + 2) k),
    Tnof stepC pendC labC (mixC (k + 2) k) + (3 * k + 4),
    Tnof stepC pendC labC (mixC (k + 2) k) + (3 * k + 4)
      + (Pof stepC pendC labC (mixC (k + 2) k) + 1), rfl,
    paramsOk_params stepC pendC labC (mixC (k + 2) k), ?_, ?_⟩
  · exact kappa_collision_pos _ _ _ _ _ _ (by omega) (by rw [Bof_mixC]; omega)
  · intro heq
    obtain ⟨T, hT⟩ := cellC_nonempty (mixC (k + 2) k) (Tnof stepC pendC labC (mixC (k + 2) k))
      (Tnof stepC pendC labC (mixC (k + 2) k) + (3 * k + 4))
    have hmem : mixC (k + 2) k ∈ T := by
      refine mixC_mem (k + 2) k (Tnof stepC pendC labC (mixC (k + 2) k)) hk T ?_
      rw [show Tnof stepC pendC labC (mixC (k + 2) k) + 2 * (k + 2) + k
        = Tnof stepC pendC labC (mixC (k + 2) k) + (3 * k + 4) by omega]
      exact hT
    exact mixC_not_mem (k + 2) k _ _ (by omega) T (heq ▸ hT) hmem

#print axioms Probe761C.readC_false_of_gap
#print axioms Probe761C.mixC_not_mem
#print axioms Probe761C.mixC_mem
#print axioms Probe761C.kappa_collision_pos
#print axioms Probe761C.Bof_mixC
#print axioms Probe761C.mixC_refutes

end Probe761C

/-!
# THE REPAIRED GAP CLIP IS REFUTED TOO: A JUMP THROUGH A REGION DOUBLES WHAT THE GAP READER SEES

The section above refutes the filed agreement at (K4)'s clip `max (2 dBack + 1) (2 dFwd + 1) 2`
and records that both of its families are defeated by a clip of the form
`2 * (dBack φ + dFwd φ) + 2`.  THIS SECTION REFUTES THE AGREEMENT AT THAT CLIP, and at every clip
below `2 ^ (dBack φ + 1)`.

## The mechanism

Both earlier families move the gap by at most two per temporal operator and then pay their
reader's threshold in depth, so a clip linear in the depths dominates them.  The family here pays
ONE `snce` per DOUBLING:

* an idle state's only datum is its register `r`;
* a region entered from an idle state with register `r₀` has exactly `r₀ + 1` pending positions,
  so the idle state right after it is `r₀ + 2` steps on and carries a register at most
  `2 r₀ + 2` (`nxt_le_double`), a bound attained by raising the register at every step;
* `⊡` re-chooses the history at every state, so at an idle state the formula
  `◇ (p S (¬p ∧ ψ))` asks for SOME past whose nearest earlier idle state satisfies `ψ` — and if
  `ψ` holds exactly at idle registers `≤ K`, that formula holds exactly at idle registers
  `≤ 2 K + 2`.

`lvlC 0 := ◇ X (p ∧ X ¬p)` holds at an idle state exactly when its register is `0`; so `lvlC j`
holds exactly at idle registers `≤ Kc j`, with `Kc j + 2 = 2 ^ (j + 1)` (`Kc_eq`), at backward
depth `j` and forward depth `2`.  At a pending state `(c, n)` the idle state after the current
region carries a register at least `n - c - 1`, so `dblC j := ◇ (p U (¬p ∧ lvlC j))` reads the
gap `n - c` at `Kc j + 1 = 2 ^ (j + 1) - 1`, at `dBack = j`, `dFwd = 3`.

## What is compiled

* `lvlC_false` / `lvlC_true`: the level reader's two halves (false at every idle register above
  `Kc j`, true at the idle register `Kc j`).
* `dblC_mem`: at gap exactly `Kc j + 1` EVERY realized type contains `dblC j`.
* `dblC_not_mem`: at every gap above `Kc j + 1` NONE does.
* `dBack_dblC`, `dFwd_dblC`: `j` and `3`; `BRep_dblC`: the repaired clip at `dblC j` is `2 j + 8`.
* `paramsOkRep_params`: the repaired parameter conditions — (K1), (K2), (K3) as the library has
  them and (K4) replaced by `2 * (dBack φ + dFwd φ) + 2 ≤ B ∧ 2 ≤ B` — hold at the periodicity
  fixpoint's own `Tcof`, `Tnof`, `Pof` and the clip `BRep φ`.
* `repaired_clip_refuted`: **for every `j ≥ 3`**, at `dblC j`, those parameters and that clip,
  the gap `2 ^ (j + 1) - 1` and the gap one modulus above it are one `kappa`-class with different
  cells.
* `gap_clip_below_exponential_refuted`: the same for EVERY `Tc`, `Tn`, `P` and every clip
  `B < 2 ^ (j + 1)`: no clip that is polynomial in the two exactness depths repairs (K4).

## What this section does and does not settle

It settles that the clip `2 * (dBack φ + dFwd φ) + 2` is wrong, by compilation, with no `Tc`
raise, no `⊡`-free premise and no finite-fibre or finite-width assumption.  The two earlier
families remain non-collisions at that clip (`thetaC_pair_not_collision`,
`mixC_pair_not_collision`, wired probe `ladder-step-fragment-gap-depth.lean`, cited and not
re-proved here): those results say the earlier witnesses are gone, and this section supplies a
new one.

It does NOT touch the step-fragment results of that probe (`stepFrag_gap_depth_exact`): `dblC`
uses a `snce` and an `untl` at the guard `p`, which are jumps, and the step fragment has none.

It does NOT show that the agreement holds at any clip.  `dblC j` is defeated by `B ≥ 2 ^ (j + 1)`,
and nothing here proves or refutes the agreement at a clip exponential in `dBack φ`.  A failed
search for a faster-growing family would be evidence about the search only.

## Verification

`#print axioms` on every headline theorem of this section.  No `sorry`, no axiom, no
`native_decide`, no placeholder body and no vacuous definition.
-/

namespace Probe761C

/-! ### The level thresholds and the formulas -/

/-- The idle register the level-`j` reader reads: `0`, `2`, `6`, `14`, … -/
def Kc : ℕ → ℕ
  | 0 => 0
  | j + 1 => 2 * Kc j + 2

theorem Kc_succ (j : ℕ) : Kc (j + 1) = 2 * Kc j + 2 := rfl

theorem Kc_eq (j : ℕ) : Kc j + 2 = 2 ^ (j + 1) := by
  induction j with
  | zero => rfl
  | succ j ih =>
    rw [Kc_succ, pow_succ]
    omega

theorem Kc_lb (j : ℕ) (hj : 3 ≤ j) : 2 * j + 7 ≤ Kc j := by
  induction j, hj using Nat.le_induction with
  | base => exact (show 2 * 3 + 7 ≤ 14 by norm_num)
  | succ j _ ih =>
    rw [Kc_succ]
    omega

/-- **THE LEVEL READER.** At an idle state: level `0` says the region entered next is a single
position; level `j + 1` says some history through this state has, as its nearest earlier idle
state, one satisfying level `j`. -/
def lvlC : ℕ → PlusFormula
  | 0 => diaF (nxtF (andF (.atom pC) (nxtF (PlusFormula.neg (.atom pC)))))
  | j + 1 => diaF (.snce (.atom pC) (andF (PlusFormula.neg (.atom pC)) (lvlC j)))

/-- **THE CANDIDATE SEPARATING FORMULA.** `◇ (p U (¬p ∧ lvlC j))`: some history through this
state reaches, at the end of the current region, an idle state satisfying the level-`j` reader.
It is supposed to read the gap `n - c` at `Kc j + 1 = 2 ^ (j + 1) - 1`; the `snce` jump of each
level buys a doubling. -/
def dblC (j : ℕ) : PlusFormula :=
  diaF (.untl (.atom pC) (andF (PlusFormula.neg (.atom pC)) (lvlC j)))

theorem dBack_lvlC (j : ℕ) : dBack (lvlC j) = j := by
  induction j with
  | zero => rfl
  | succ j ih =>
    simp only [lvlC, diaF, andF, PlusFormula.neg, dBack, ih]
    omega

theorem dFwd_lvlC (j : ℕ) : dFwd (lvlC j) = 2 := by
  induction j with
  | zero => rfl
  | succ j ih =>
    simp only [lvlC, diaF, andF, PlusFormula.neg, dFwd, ih]
    omega

theorem dBack_dblC (j : ℕ) : dBack (dblC j) = j := by
  have h := dBack_lvlC j
  simp only [dblC, diaF, andF, PlusFormula.neg, dBack, h]
  omega

theorem dFwd_dblC (j : ℕ) : dFwd (dblC j) = 3 := by
  have h := dFwd_lvlC j
  simp only [dblC, diaF, andF, PlusFormula.neg, dFwd, h]
  omega

/-! ### Histories at offset `0` -/

theorem hist_reselect (τ σ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (g : ℤ → LadderState Qc pendC) (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (t : ℤ)
    (e : τ.state t = σ.state t) :
    ∃ g' : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g' ∧
      (∀ v : ℤ, σ.state v = (v, g' v)) ∧ g' t = g t := by
  obtain ⟨k, g', hg', hp'⟩ := exists_isLadderPath_of_hist fwdC bwdC σ
  have h0 : ((t, g t) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) = (t + k, g' t) :=
    (hτ t).symm.trans (e.trans (hp' t))
  have hk : t = t + k := congrArg Prod.fst h0
  have hk0 : k = 0 := by omega
  subst hk0
  exact ⟨g', hg', fun v => by rw [hp' v, add_zero], (congrArg Prod.snd h0).symm⟩

theorem state_eq_of_path_eq
    (τ σ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (g g' : ℤ → LadderState Qc pendC) (hτ : ∀ t : ℤ, τ.state t = (t, g t))
    (hσ : ∀ t : ℤ, σ.state t = (t, g' t)) (t : ℤ) (h : g t = g' t) :
    τ.state t = σ.state t := by
  rw [hτ t, hσ t, h]

theorem truth_jumpBack (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (g : ℤ → LadderState Qc pendC) (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (ψ : PlusFormula)
    (t : ℤ) :
    PlusTruthAt MC τ t (.snce (.atom pC) (andF (PlusFormula.neg (.atom pC)) ψ)) ↔
      ∃ s : ℤ, s < t ∧ pendC (objAt g s) = false ∧ PlusTruthAt MC τ s ψ ∧
        ∀ r : ℤ, s < r → r < t → pendC (objAt g r) = true := by
  have hτ' : ∀ t : ℤ, τ.state t = (t + 0, g t) := fun t => by rw [hτ t, add_zero]
  show (∃ s : ℤ, s < t ∧ PlusTruthAt MC τ s (andF (PlusFormula.neg (.atom pC)) ψ) ∧
      ∀ r : ℤ, s < r → r < t → PlusTruthAt MC τ r (.atom pC)) ↔ _
  constructor
  · rintro ⟨s, h1, h2, h3⟩
    rw [truth_andF, truth_neg_pC_off τ g 0 hτ'] at h2
    exact ⟨s, h1, h2.1, h2.2, fun r a b => (truth_pC_off τ g 0 hτ' r).mp (h3 r a b)⟩
  · rintro ⟨s, h1, h2, h3, h4⟩
    refine ⟨s, h1, ?_, fun r a b => (truth_pC_off τ g 0 hτ' r).mpr (h4 r a b)⟩
    rw [truth_andF, truth_neg_pC_off τ g 0 hτ']
    exact ⟨h2, h3⟩

theorem truth_jumpFwd (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (g : ℤ → LadderState Qc pendC) (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (ψ : PlusFormula)
    (t : ℤ) :
    PlusTruthAt MC τ t (.untl (.atom pC) (andF (PlusFormula.neg (.atom pC)) ψ)) ↔
      ∃ s : ℤ, t < s ∧ pendC (objAt g s) = false ∧ PlusTruthAt MC τ s ψ ∧
        ∀ r : ℤ, t < r → r < s → pendC (objAt g r) = true := by
  have hτ' : ∀ t : ℤ, τ.state t = (t + 0, g t) := fun t => by rw [hτ t, add_zero]
  show (∃ s : ℤ, t < s ∧ PlusTruthAt MC τ s (andF (PlusFormula.neg (.atom pC)) ψ) ∧
      ∀ r : ℤ, t < r → r < s → PlusTruthAt MC τ r (.atom pC)) ↔ _
  constructor
  · rintro ⟨s, h1, h2, h3⟩
    rw [truth_andF, truth_neg_pC_off τ g 0 hτ'] at h2
    exact ⟨s, h1, h2.1, h2.2, fun r a b => (truth_pC_off τ g 0 hτ' r).mp (h3 r a b)⟩
  · rintro ⟨s, h1, h2, h3, h4⟩
    refine ⟨s, h1, ?_, fun r a b => (truth_pC_off τ g 0 hτ' r).mpr (h4 r a b)⟩
    rw [truth_andF, truth_neg_pC_off τ g 0 hτ']
    exact ⟨h2, h3⟩

/-! ### The doubling bound -/

/-- **ONE REGION AT MOST DOUBLES THE REGISTER.** Between an idle position and the next idle
position with only pending positions in between, the register grows to at most twice its value
plus two: the region in between has exactly `register + 1` positions. -/
theorem nxt_le_double (g : ℤ → LadderState Qc pendC) (hg : IsLadderPath stepC pendC g)
    (s t : ℤ) (hst : s < t) (hs : pendC (objAt g s) = false) (ht : pendC (objAt g t) = false)
    (hmid : ∀ r : ℤ, s < r → r < t → pendC (objAt g r) = true) :
    nxtAt g t ≤ 2 * nxtAt g s + 2 := by
  by_cases h1 : t = s + 1
  · have hlip := nxtAt_lipschitz g hg s 1
    rw [show s + ((1 : ℕ) : ℤ) = t by rw [h1]; norm_num] at hlip
    omega
  · have hp1 : pendC (objAt g (s + 1)) = true := hmid (s + 1) (by omega) (by omega)
    have hpin := cntAt_eq_nxtAt_of_idle_pend g hg s hs hp1
    have hend := not_pend_of_count g hg (s + 1) hp1
    have ht' : t = s + 1 + (cntAt g (s + 1) : ℤ) + 1 := by
      rcases lt_trichotomy t (s + 1 + (cntAt g (s + 1) : ℤ) + 1) with hlt | heq | hgt
      · have := (cntAt_sub_of_pend g hg (s + 1) hp1 (t - (s + 1)).toNat (by omega)).1
        rw [show s + 1 + (((t - (s + 1)).toNat : ℕ) : ℤ) = t by omega] at this
        exact absurd (this.symm.trans ht) (by simp)
      · exact heq
      · exact absurd ((hmid _ (by omega) hgt).symm.trans hend) (by simp)
    have hlip := nxtAt_lipschitz g hg s (cntAt g (s + 1) + 2)
    rw [show s + ((cntAt g (s + 1) + 2 : ℕ) : ℤ) = t by rw [ht']; push_cast; ring] at hlip
    omega

/-! ### The level reader's two halves -/

/-- **THE LEVEL READER'S CEILING.** At an idle position whose register exceeds `Kc j`, the
level-`j` reader fails on every history. -/
theorem lvlC_false : ∀ (j : ℕ)
    (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (g : ℤ → LadderState Qc pendC), (∀ t : ℤ, τ.state t = (t, g t)) → ∀ t : ℤ,
    pendC (objAt g t) = false → Kc j < nxtAt g t → ¬ PlusTruthAt MC τ t (lvlC j) := by
  intro j
  induction j with
  | zero =>
    intro τ g hτ t hidle hlt h
    have h' : PlusTruthAt MC τ t
        (diaF (nxtF (andF (.atom pC) (nxtF (PlusFormula.neg (.atom pC)))))) := h
    obtain ⟨σ, e, hσ⟩ := (truth_diaF τ t _).mp h'
    obtain ⟨g', hg', hp', hgt⟩ := hist_reselect τ σ g hτ t e
    have hp0 : ∀ v : ℤ, σ.state v = (v + 0, g' v) := fun v => by rw [hp' v, add_zero]
    rw [truth_nxtF, truth_andF, truth_pC_off σ g' 0 hp0, truth_nxtF,
      truth_neg_pC_off σ g' 0 hp0] at hσ
    obtain ⟨hpend, hidle2⟩ := hσ
    have hidle' : pendC (objAt g' t) = false := by rw [objAt, hgt]; exact hidle
    have hpin := cntAt_eq_nxtAt_of_idle_pend g' hg' t hidle' hpend
    have hn : nxtAt g' t = nxtAt g t := by rw [nxtAt, nxtAt, hgt]
    have hK0 : Kc 0 = 0 := rfl
    have := (cntAt_sub_of_pend g' hg' (t + 1) hpend 1 (by omega)).1
    rw [show t + 1 + ((1 : ℕ) : ℤ) = t + 1 + 1 by norm_num] at this
    exact absurd (this.symm.trans hidle2) (by simp)
  | succ j ih =>
    intro τ g hτ t hidle hlt h
    have h' : PlusTruthAt MC τ t
        (diaF (.snce (.atom pC) (andF (PlusFormula.neg (.atom pC)) (lvlC j)))) := h
    obtain ⟨σ, e, hσ⟩ := (truth_diaF τ t _).mp h'
    obtain ⟨g', hg', hp', hgt⟩ := hist_reselect τ σ g hτ t e
    rw [truth_jumpBack σ g' hp'] at hσ
    obtain ⟨s, hst, hsidle, hψ, hmid⟩ := hσ
    have hidle' : pendC (objAt g' t) = false := by rw [objAt, hgt]; exact hidle
    have hn : nxtAt g' t = nxtAt g t := by rw [nxtAt, nxtAt, hgt]
    have hdbl := nxt_le_double g' hg' s t hst hsidle hidle' hmid
    have hs : nxtAt g' s ≤ Kc j := by
      by_contra hc
      exact ih σ g' hp' s hsidle (by omega) hψ
    rw [Kc_succ] at hlt
    omega

/-- **THE LEVEL READER'S FLOOR.** At the idle state with register exactly `Kc j`, the level-`j`
reader holds on every history: the witnessing past raises the register at every step of a region
entered from the idle state with register `Kc (j - 1)`. -/
theorem lvlC_true : ∀ (j : ℕ)
    (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (g : ℤ → LadderState Qc pendC), (∀ t : ℤ, τ.state t = (t, g t)) → ∀ t : ℤ,
    g t = gI (Kc j) 0 → PlusTruthAt MC τ t (lvlC j) := by
  intro j
  induction j with
  | zero =>
    intro τ g hτ t hgt
    have hpath : IsLadderPath stepC pendC
        (gluePath (gI 0) (fun v : ℤ => gC 0 0 (v - (t + 1))) t) := by
      refine gluePath_isPath _ _ (gI_isPath _) (shiftPath_isPath _ (gC_isPath 0 0) (t + 1)) t ?_
      show RladAdm stepC pendC t (gI 0 t) (gC 0 0 (t + 1 - (t + 1)))
      rw [show t + 1 - (t + 1) = (0 : ℤ) by ring, gC_zero_eq]
      refine ⟨rfl, fun _ => rfl, Or.inl rfl, ?_⟩
      show Count (pendC 1) (pendC 0) 0 0 0
      simp [Count, pendC_zero, pendC_one]
    obtain ⟨ρ0, hρ0def⟩ : ∃ ρ0 : ℤ → LadderState Qc pendC,
        ρ0 = gluePath (gI 0) (fun v : ℤ => gC 0 0 (v - (t + 1))) t := ⟨_, rfl⟩
    rw [← hρ0def] at hpath
    have hρt : ρ0 t = gI 0 t := by rw [hρ0def, gluePath_of_le _ _ t t le_rfl]
    have hρhigh : ∀ v : ℤ, t < v → ρ0 v = gC 0 0 (v - (t + 1)) := fun v hv => by
      rw [hρ0def, gluePath_of_gt _ _ t v hv]
    obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath fwdC bwdC _ hpath
    have hσ0 : ∀ v : ℤ, σ.state v = (v + 0, ρ0 v) := fun v => by rw [hσ v, add_zero]
    show PlusTruthAt MC τ t (diaF (nxtF (andF (.atom pC) (nxtF (PlusFormula.neg (.atom pC))))))
    refine (truth_diaF τ t _).mpr ⟨σ, state_eq_of_path_eq τ σ g ρ0 hτ hσ t ?_, ?_⟩
    · rw [hgt, hρt]
      rfl
    · rw [truth_nxtF, truth_andF, truth_pC_off σ ρ0 0 hσ0, truth_nxtF,
        truth_neg_pC_off σ ρ0 0 hσ0]
      refine ⟨?_, ?_⟩
      · rw [objAt, hρhigh _ (by omega), show t + 1 - (t + 1) = (0 : ℤ) by ring, gC_zero_eq]
        exact pendC_zero
      · rw [objAt, hρhigh _ (by omega), show t + 1 + 1 - (t + 1) = (1 : ℤ) by ring]
        exact pendC_wC_of_gt 0 1 (by norm_num)
  | succ j ih =>
    intro τ g hτ t hgt
    obtain ⟨K, hK⟩ : ∃ K : ℕ, K = Kc j := ⟨_, rfl⟩
    have hK1 : Kc (j + 1) = 2 * K + 2 := by rw [hK]; exact Kc_succ j
    obtain ⟨gu, hgu, hu0, huK⟩ := exists_upRamp K 0 (K + 1)
    obtain ⟨s, hs⟩ : ∃ s : ℤ, s = t - (K : ℤ) - 2 := ⟨_, rfl⟩
    have hmidp : IsLadderPath stepC pendC
        (gluePath (fun v : ℤ => gu (v - (s + 1))) (gI (2 * K + 2)) (t - 1)) := by
      refine gluePath_isPath _ _ (shiftPath_isPath gu hgu (s + 1)) (gI_isPath _) (t - 1) ?_
      show RladAdm stepC pendC (t - 1) (gu (t - 1 - (s + 1))) (gI (2 * K + 2) (t - 1 + 1))
      rw [show t - 1 - (s + 1) = (K : ℤ) by omega, huK]
      refine ⟨rfl, admZeroC _ _,
        Or.inr (Or.inl (show 2 * K + 2 = K + 1 + K + 1 by omega)), ?_⟩
      show Count (pendC 0) (pendC 1) 0 (K + 1 + K) 0
      simp [Count, pendC_zero, pendC_one]
    have hpath : IsLadderPath stepC pendC (gluePath (gI K)
        (gluePath (fun v : ℤ => gu (v - (s + 1))) (gI (2 * K + 2)) (t - 1)) s) := by
      refine gluePath_isPath _ _ (gI_isPath _) hmidp s ?_
      rw [gluePath_of_le _ _ (t - 1) (s + 1) (by omega)]
      show RladAdm stepC pendC s (gI K s) (gu (s + 1 - (s + 1)))
      rw [show s + 1 - (s + 1) = (0 : ℤ) by ring, hu0]
      refine ⟨rfl, fun _ => rfl, Or.inr (Or.inl rfl), ?_⟩
      show Count (pendC 1) (pendC 0) 0 K (0 + K)
      simp [Count, pendC_zero, pendC_one]
    obtain ⟨ρ0, hρ0def⟩ : ∃ ρ0 : ℤ → LadderState Qc pendC, ρ0 = gluePath (gI K)
        (gluePath (fun v : ℤ => gu (v - (s + 1))) (gI (2 * K + 2)) (t - 1)) s := ⟨_, rfl⟩
    rw [← hρ0def] at hpath
    have hρlow : ∀ v : ℤ, v ≤ s → ρ0 v = gI K v := fun v hv => by
      rw [hρ0def, gluePath_of_le _ _ s v hv]
    have hρmid : ∀ v : ℤ, s < v → v ≤ t - 1 → ρ0 v = gu (v - (s + 1)) := fun v h1 h2 => by
      rw [hρ0def, gluePath_of_gt _ _ s v h1, gluePath_of_le _ _ (t - 1) v h2]
    have hρt : ρ0 t = gI (2 * K + 2) t := by
      rw [hρ0def, gluePath_of_gt _ _ s t (by omega), gluePath_of_gt _ _ (t - 1) t (by omega)]
    obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath fwdC bwdC _ hpath
    have hu_obj : objAt gu 0 = 0 := by rw [objAt, hu0]; rfl
    have hu_cnt : cntAt gu 0 = 0 + K := by rw [cntAt, hu0]; rfl
    have e2 : gI (Kc (j + 1)) 0 = gI (2 * K + 2) t := congrArg (fun r => gI r 0) hK1
    have e1 : ρ0 s = gI (Kc j) 0 :=
      (hρlow s le_rfl).trans (congrArg (fun r => gI r 0) hK)
    show PlusTruthAt MC τ t
      (diaF (.snce (.atom pC) (andF (PlusFormula.neg (.atom pC)) (lvlC j))))
    refine (truth_diaF τ t _).mpr ⟨σ, state_eq_of_path_eq τ σ g ρ0 hτ hσ t ?_, ?_⟩
    · rw [hgt, hρt, e2]
    · rw [truth_jumpBack σ ρ0 hσ]
      refine ⟨s, by omega, ?_, ih σ ρ0 hσ s e1, fun r hr1 hr2 => ?_⟩
      · rw [objAt, hρlow s le_rfl]
        exact pendC_one
      · rw [objAt, hρmid r hr1 (by omega)]
        have := (cntAt_sub_of_pend gu hgu 0 (by rw [hu_obj]; exact pendC_zero)
          (r - (s + 1)).toNat (by omega)).1
        rwa [show (0 : ℤ) + (((r - (s + 1)).toNat : ℕ) : ℤ) = r - (s + 1) by omega] at this

/-! ### The two memberships -/

/-- **NEGATIVE MEMBERSHIP: gap above `Kc j + 1`.** At a pending state whose register exceeds its
countdown by more than `Kc j + 1`, no realized type contains `dblC j`: the idle state after the
current region carries a register above `Kc j` on every history. -/
theorem dblC_not_mem (j c n : ℕ) (hgap : c + Kc j + 2 ≤ n) (T : Finset PlusFormula)
    (hT : T ∈ cellAt MC (dblC j)
      ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    dblC j ∉ T := by
  obtain ⟨τ, hs, rfl⟩ := hT
  rw [mem_tpOf_iff]
  rintro ⟨-, h⟩
  obtain ⟨σ, hσ, hjump⟩ := (truth_diaF τ 0
    (.untl (.atom pC) (andF (PlusFormula.neg (.atom pC)) (lvlC j)))).mp h
  obtain ⟨k₀, g, hg, hp⟩ := exists_isLadderPath_of_hist fwdC bwdC σ
  have h0 : ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) = (0 + k₀, g 0) :=
    hs.symm.trans (hσ.trans (hp 0))
  have hk : (0 : ℤ) = 0 + k₀ := congrArg Prod.fst h0
  have hk0 : k₀ = 0 := by omega
  subst hk0
  have hp' : ∀ v : ℤ, σ.state v = (v, g v) := fun v => by rw [hp v, add_zero]
  have hg0 : g 0 = stC c n := (congrArg Prod.snd h0).symm
  have hobj : objAt g 0 = 0 := by rw [objAt, hg0]; rfl
  have hcnt : cntAt g 0 = c := by rw [cntAt, hg0]; rfl
  have hnxt : nxtAt g 0 = n := by rw [nxtAt, hg0]; rfl
  rw [truth_jumpFwd σ g hp'] at hjump
  obtain ⟨s, hts, hidle, hψ, hguard⟩ := hjump
  have hp0 : pendC (objAt g 0) = true := by rw [hobj]; exact pendC_zero
  have hend := not_pend_of_count g hg 0 hp0
  have hs' : s = 0 + (cntAt g 0 : ℤ) + 1 := by
    rcases lt_trichotomy s (0 + (cntAt g 0 : ℤ) + 1) with hlt | heq | hgt
    · have := (cntAt_sub_of_pend g hg 0 hp0 s.toNat (by omega)).1
      rw [show (0 : ℤ) + ((s.toNat : ℕ) : ℤ) = s by omega] at this
      exact absurd (this.symm.trans hidle) (by simp)
    · exact heq
    · exact absurd ((hguard _ (by omega) hgt).symm.trans hend) (by simp)
  have hlip := nxtAt_lipschitz g hg 0 (cntAt g 0 + 1)
  rw [show (0 : ℤ) + ((cntAt g 0 + 1 : ℕ) : ℤ) = s by rw [hs']; push_cast; ring] at hlip
  exact lvlC_false j σ g hp' s hidle (by omega) hψ

/-- **POSITIVE MEMBERSHIP: gap exactly `Kc j + 1`.** The register falls at every remaining step
of the region and once more on leaving it, so the idle state after the region carries the
register `Kc j`, where the level-`j` reader holds. -/
theorem dblC_mem (j c : ℕ) (T : Finset PlusFormula)
    (hT : T ∈ cellAt MC (dblC j)
      ((0, stC c (c + Kc j + 1)) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    dblC j ∈ T := by
  obtain ⟨τ, hs, rfl⟩ := hT
  rw [mem_tpOf_iff]
  refine ⟨self_mem_plusSubformulaClosure _, ?_⟩
  obtain ⟨K, hK⟩ : ∃ K : ℕ, K = Kc j := ⟨_, rfl⟩
  rw [← hK] at hs
  obtain ⟨gd, hgd, hd0, hdc⟩ := exists_downRamp c 0 (K + 1)
  rw [show 0 + c = c by omega, show K + 1 + c = c + K + 1 by omega] at hd0
  have hpath : IsLadderPath stepC pendC (gluePath gd (gI K) (c : ℤ)) := by
    refine gluePath_isPath _ _ hgd (gI_isPath _) (c : ℤ) ?_
    rw [hdc]
    refine ⟨rfl, admZeroC _ _, Or.inr (Or.inr rfl), ?_⟩
    show Count (pendC 0) (pendC 1) 0 (K + 1) 0
    simp [Count, pendC_zero, pendC_one]
  obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath fwdC bwdC _ hpath
  have hd_obj : objAt gd 0 = 0 := by rw [objAt, hd0]; rfl
  have hd_cnt : cntAt gd 0 = c := by rw [cntAt, hd0]; rfl
  show PlusTruthAt MC τ 0
    (diaF (.untl (.atom pC) (andF (PlusFormula.neg (.atom pC)) (lvlC j))))
  refine (truth_diaF τ 0 _).mpr ⟨σ, ?_, ?_⟩
  · rw [hs, hσ 0, gluePath_of_le _ _ (c : ℤ) 0 (by omega), hd0]
  · rw [truth_jumpFwd σ _ hσ]
    refine ⟨(c : ℤ) + 1, by omega, ?_, lvlC_true j σ _ hσ ((c : ℤ) + 1) ?_,
      fun r hr1 hr2 => ?_⟩
    · rw [objAt, gluePath_of_gt _ _ (c : ℤ) _ (by omega)]
      exact pendC_one
    · rw [gluePath_of_gt _ _ (c : ℤ) _ (by omega)]
      exact congrArg (fun r => gI r 0) hK
    · rw [objAt, gluePath_of_le _ _ (c : ℤ) r (by omega)]
      have := (cntAt_sub_of_pend gd hgd 0 (by rw [hd_obj]; exact pendC_zero) r.toNat
        (by omega)).1
      rwa [show (0 : ℤ) + ((r.toNat : ℕ) : ℤ) = r by omega] at this

/-- **THE CELLS DIFFER.** -/
theorem dblC_cell_ne (j c n' : ℕ) (hgap : c + Kc j + 2 ≤ n') :
    cellAt MC (dblC j)
        ((0, stC c (c + Kc j + 1)) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
      ≠ cellAt MC (dblC j)
          ((0, stC c n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 := by
  intro heq
  obtain ⟨T, hT⟩ := cellC_nonempty (dblC j) c (c + Kc j + 1)
  exact dblC_not_mem j c n' hgap T (heq ▸ hT) (dblC_mem j c T hT)

/-! ### The repaired parameter conditions, and the refutation at them -/

/-- **(K4) AT THE REPAIRED CLIP**: `B` is at least twice the SUM of the two exactness depths plus
two, and at least `2`. -/
def paramsOkK4Rep (φ : PlusFormula) (B : ℕ) : Prop :=
  2 * (dBack φ + dFwd φ) + 2 ≤ B ∧ 2 ≤ B

/-- **THE REPAIRED PARAMETER CONDITIONS** at this object: (K1), (K2) and (K3) exactly as the
library states them, with (K4) replaced by `paramsOkK4Rep`. -/
def ParamsOkRep (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  paramsOkK1 stepC pendC labC φ P ∧ paramsOkK2 stepC pendC labC φ Tc P ∧
    paramsOkK3 Qc pendC φ Tc Tn ∧ paramsOkK4Rep φ B

/-- The repaired clip's least admissible value. -/
def BRep (φ : PlusFormula) : ℕ := 2 * (dBack φ + dFwd φ) + 2

/-- The repaired conditions hold at the periodicity fixpoint's own three outputs and the repaired
clip: the hypothesis is not vacuous. -/
theorem paramsOkRep_params (φ : PlusFormula) :
    ParamsOkRep φ (Tcof stepC pendC labC φ) (Tnof stepC pendC labC φ) (Pof stepC pendC labC φ)
      (BRep φ) := by
  obtain ⟨h1, h2, h3, -⟩ := paramsOk_params stepC pendC labC φ
  exact ⟨h1, h2, h3, le_rfl, by unfold BRep; omega⟩

theorem BRep_dblC (j : ℕ) : BRep (dblC j) = 2 * j + 8 := by
  unfold BRep
  rw [dBack_dblC, dFwd_dblC]
  omega

/-- **THE CLIP DOES NOT REACH: EVERY CLIP BELOW `2 ^ (j + 1)`.** At every threshold pair, every
modulus and every gap clip `B < 2 ^ (j + 1)`, the pending state of this object carries a
`kappa`-collision whose cells differ at `dblC j`. -/
theorem gap_clip_below_exponential_refuted (j B Tc Tn P : ℕ) (hB : B + 1 ≤ 2 ^ (j + 1)) :
    ∃ c n n' : ℕ, n = c + (2 ^ (j + 1) - 1) ∧
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c, n') ∧
      cellAt MC (dblC j)
          ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
        ≠ cellAt MC (dblC j)
          ((0, stC c n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 := by
  have hK := Kc_eq j
  have hn : Tn + (2 ^ (j + 1) - 1) = Tn + Kc j + 1 := by omega
  refine ⟨Tn, Tn + (2 ^ (j + 1) - 1), Tn + (2 ^ (j + 1) - 1) + (P + 1), rfl, ?_, ?_⟩
  · exact kappa_collision_pos Tc Tn P B Tn _ (by omega) (by omega)
  · rw [hn]
    exact dblC_cell_ne j Tn _ (by omega)

/-- **THE REPAIRED CLIP IS REFUTED.** For every `j ≥ 3`, at the formula `dblC j` and the
periodicity fixpoint's own parameter outputs with the gap clip `2 * (dBack + dFwd) + 2`: the
repaired parameter conditions hold, the clip is `2 j + 8`, and the cell at the pending state
separates the gap `2 ^ (j + 1) - 1` from the gap one modulus above it — two counter pairs of one
`kappa`-class. -/
theorem repaired_clip_refuted (j : ℕ) (hj : 3 ≤ j) :
    BRep (dblC j) = 2 * j + 8 ∧
    ParamsOkRep (dblC j) (Tcof stepC pendC labC (dblC j)) (Tnof stepC pendC labC (dblC j))
      (Pof stepC pendC labC (dblC j)) (BRep (dblC j)) ∧
    ∃ c n n' : ℕ, n = c + (2 ^ (j + 1) - 1) ∧
      kappa (Tcof stepC pendC labC (dblC j)) (Tnof stepC pendC labC (dblC j))
          (Pof stepC pendC labC (dblC j)) (BRep (dblC j)) (c, n)
        = kappa (Tcof stepC pendC labC (dblC j)) (Tnof stepC pendC labC (dblC j))
          (Pof stepC pendC labC (dblC j)) (BRep (dblC j)) (c, n') ∧
      cellAt MC (dblC j)
          ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
        ≠ cellAt MC (dblC j)
          ((0, stC c n') : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 := by
  have hlb := Kc_lb j hj
  have hK := Kc_eq j
  refine ⟨BRep_dblC j, paramsOkRep_params (dblC j), ?_⟩
  exact gap_clip_below_exponential_refuted j (BRep (dblC j)) _ _ _
    (by rw [BRep_dblC]; omega)

#print axioms Probe761C.nxt_le_double
#print axioms Probe761C.lvlC_false
#print axioms Probe761C.lvlC_true
#print axioms Probe761C.dblC_not_mem
#print axioms Probe761C.dblC_mem
#print axioms Probe761C.dblC_cell_ne
#print axioms Probe761C.paramsOkRep_params
#print axioms Probe761C.gap_clip_below_exponential_refuted
#print axioms Probe761C.repaired_clip_refuted

end Probe761C
