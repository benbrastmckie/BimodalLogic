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
