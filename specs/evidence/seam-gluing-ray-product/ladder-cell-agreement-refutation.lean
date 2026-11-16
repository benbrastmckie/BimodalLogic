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
