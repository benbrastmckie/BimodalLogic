/-
THE SPLICE TYPE REFUTATION: the pumping surgery of the ladder replacement layer does NOT preserve
the realized closure type, at ANY distance from the splice point.  Half (ii) of the model-level
truth-transport layer -- "repeating an object cycle of length `l ∣ P + 1` inside a pending region
whose splice point lies at least `T_c` from `z` preserves the stab-free part of `tpOf` at `z`" --
is FALSE as stated, and this file compiles the separating pair.

## What was asked, and what this probe answers

The agreement of class-equivalent ladder cells was to be proved by a PUMPING replacement: the
admissibility half is landed in full (`exists_spliced_ladderPath`,
`exists_spliced_ladderPath_of_pend_past`), half (i) of the truth side is landed
(`truthAt_iff_of_objAt_eq_of_stabPinned`: two ladder paths with the SAME object walk realize the
same closure formulas), and what remained was half (ii), the transport of the realized type ACROSS
the splice.  The preceding record read half (ii) as OPEN, obstructed at the seam
(`spliceIdx_seam_lt`) and plausibly reachable by a distance budget per `U`/`S`-nesting depth
together with the splice's monotonicity on future object positions.

That reading is wrong, and the error is in the budget: nested `U` has UNBOUNDED reach.  A single
splice duplicates the pumped block, so it ADDS one occurrence of every object state of that block
to the walk's future -- and a nested eventuality COUNTS occurrences at any distance whatsoever.

## What is settled here

The object is three states: `0` and `1` pending, `2` idle; `0` steps to all three, `1` steps to
`0` and to `2`, `2` self-loops.  The letter `p` holds at `1` alone.  The walk `wS` is `0` at every
position at or below `0`, `1` at position `1`, `0` at positions `2` and `3`, and `2` from position
`4` on, with the countdown `cS v = (3 - v).toNat` forced by `Count`.  So the walk is pending on
`(-∞, 3]`, idle on `[4, ∞)`, has NO region start at all, and hits the `p`-state exactly ONCE.

  1. `fwdS`, `bwdS`: the object is serial on the admissible carrier in both directions, so
     `ladderFrameAdm` and `ladderModel` are available on it.  Both hypotheses are discharged, not
     assumed.
  2. `exists_gS`: the walk lifts to a ladder path (`exists_ladderPath_of_walk`); the pin side
     condition is vacuous because the walk has no region start.
  3. `two_mem_objCycleLensS`: the pending pair `0 → 1 → 0` is an object cycle of length `2`, so
     `(K1)` of `ParamsOk` forces `2 ∣ P + 1` at the parameters the periodicity fixpoint defines
     (`two_dvd_PS_succ`, through `paramsOk_params`).  The divisibility hypothesis of half (ii) is
     therefore MET, not sidestepped.
  4. `exists_separating_splice`: the splice at `a = 0` with `l = 2` satisfies every hypothesis of
     half (ii) -- `0 < l`, `pend (objAt g 0) = true`, `l ≤ cntAt g 0`,
     `objAt g 0 = objAt g (0 + l)`, `l ∣ P + 1`, `ParamsOk` at `(T_c, T_n, P, B)`, the stab-free
     closure condition, and `T_c ≤ |0 - z|` at `z = -T_c` -- and the two realized types at `z`
     DIFFER.  The spliced path is produced by the landed
     `exists_spliced_ladderPath_of_pend_past`, so the surgery is the record's own and no weakened
     variant.
  5. The separating formula is `chiS := ⊤ U (p ∧ ⊤ U p)`, "the `p`-state is hit at least twice in
     the strict future".  It is `stab`-free (`no_stab_in_closure_chiS`), it lies in its own
     subformula closure, and it is FALSE along the original at EVERY position
     (`chiS_false_of_orig`: the walk hits `1` only at position `1`, and no witness lies after
     that one) while TRUE along the spliced path at every position below `1`
     (`chiS_true_of_spliced`: the duplicated block puts a second hit at position `3`).
  6. `splice_type_invariance_refuted`: half (ii), written out as the schema
     `SpliceTypeInvariance` with every hypothesis the plan records, is refuted outright.
  7. **The refutation survives the ITERATED surgery.**  One splice raises the countdown by `l`,
     so the residue coordinate of `kappa` returns only after `(P + 1) / l` repetitions; the
     refutation is not an artefact of taking the surgery once.  `twoHits_of_spliced` creates the
     second hit, `twoHits_iterate` shows no further splice at `(0, 2)` destroys it, and
     `spliced_rehypotheses` shows the spliced path satisfies the splice hypotheses again at
     `(0, 2)` -- so the iteration is genuinely available and `chiS` is true at every stage of it
     while false along the original throughout.
  8. **WHY the block is the wrong unit**, compiled rather than left to prose:
     `splice_block_not_type_respecting`. The pumped block's two endpoints carry the SAME object
     state and DIFFERENT realized types -- `⊤ U p` holds at the block's entry, the single `p`-hit
     lying inside the block, and fails at its exit. An object cycle is therefore not a unit of
     type-invariance, and the seam has nothing to disarm it. This is what keeps the refutation
     strictly OFF a block whose endpoint TYPES agree: such a block is a different object and
     nothing here speaks about it.

## Non-vacuity, witnessed on both sides

`exists_separating_splice` carries `PlusFormula.top ∈ tpOf … σ z` and
`PlusFormula.top ∈ tpOf … σ' z` as two of its conjuncts, so NEITHER realized type is empty and
the inequality is not an artefact of two empty sets.  `spliced_rehypotheses` is what keeps item 7
from being a statement about an unreachable configuration.  Both paths are ladder paths of
`ladderFrameAdm` on the admissible carrier, both histories are produced by
`exists_hist_of_isLadderPath`, and the parameters are the periodicity fixpoint's own outputs
rather than exhibited constants.

## What this probe does NOT show

It does not refute half (i), which stands on its own ground and is untouched here.  It does not
refute the presentation: the set-valued datum, the fibre equation over the maximum certified
subset, and the factorization lemma as its corollary are all untouched.  It settles NOTHING about
`cellAt_const_of_kappa_eq` itself -- a cell is the set of types realized by ALL histories through
a state, and this probe compares two particular histories; whether some other history through the
original state realizes `chiS` is not decided here and no claim is made either way.  It says
nothing about `ladderSound`, `ladderLift` or `ladderRealized`.  It is not a device-discrimination
claim, it asserts no bound, and every quantity it names is a count.

Above all, it says NOTHING about a splice at a TYPE-RESPECTING block -- one whose two endpoints
carry the same realized type as well as the same object state.  `splice_block_not_type_respecting`
shows the block refuted here is not of that kind, so the refutation is confined to the
object-cycle splice by construction rather than by silence.

## What is refuted, precisely

The claim refuted is that the FIXED surgery `spliceObj`/`spliceCnt` applied at an OBJECT cycle --
a block chosen to preserve ADMISSIBILITY -- also preserves the realized TYPE.  It does not: the
surgery is type-blind, and a nested eventuality reads the occurrence count the surgery changes.
The diagnosis is compiled, not asserted: the block's endpoint types DIFFER
(`splice_block_not_type_respecting`), so the loop is not a unit of type-invariance.  Nothing here
says a splice at a TYPE-RESPECTING block is impossible, or that a type-aware lengthening of the
region is; those are different constructions, not stated anywhere in the tree, and this probe
neither supplies nor refutes them.

## Verification

`#print axioms` on every headline theorem: `[propext, Classical.choice, Quot.sound]`, the
fixture's own profile (twenty-one printed theorems).  No `sorry`, no axiom, no `native_decide`, no placeholder body and no
vacuous definition anywhere in this file.

Compile: `lake env lean` on this file
(`specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean`).
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe761S


abbrev Qs : Type := Fin 3

def pendS : Qs → Bool := fun q => decide (q.val < 2)

def stepS : Qs → Qs → Bool := fun x y =>
  if x = 0 then true else if x = 1 then decide (y = 0 ∨ y = 2) else decide (y = 2)

def pS : Atom := ⟨"p", none⟩

def labS : Qs → Atom → Bool := fun q at_ => decide (at_ = pS ∧ q = 1)

theorem pendS_zero : pendS 0 = true := by decide

theorem eq_two_of_not_pend (q : Qs) (h : pendS q = false) : q = 2 := by
  revert h; fin_cases q <;> decide

theorem pendS_two : pendS 2 = false := by decide

theorem stepS_two_two : stepS 2 2 = true := by decide

theorem stepS_zero (y : Qs) : stepS 0 y = true := by simp [stepS]

theorem stepS_pend_two (q : Qs) (hq : pendS q = true) : stepS q 2 = true := by
  revert hq; fin_cases q <;> decide

theorem stepS_pend_zero (q : Qs) (hq : pendS q = true) : stepS q 0 = true := by
  revert hq; fin_cases q <;> decide

/-! ### Seriality -/

theorem fwdS : ∀ (t : ℤ) (x : LadderState Qs pendS), ∃ y, RladAdm stepS pendS t x y := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  by_cases hq : pendS q = true
  · cases c with
    | zero =>
        refine ⟨⟨(2, 0, n), fun _ => rfl⟩, ?_⟩
        refine ⟨stepS_pend_two q hq, fun h => absurd (hq.symm.trans h) (by simp), Or.inl rfl, ?_⟩
        show Count (pendS q) (pendS 2) 0 n 0
        simp [Count, pendS_two]
    | succ k =>
        refine ⟨⟨(0, k, n), fun h => absurd h (by simp [pendS])⟩, ?_⟩
        refine ⟨stepS_pend_zero q hq, fun h => absurd (hq.symm.trans h) (by simp), Or.inl rfl, ?_⟩
        show Count (pendS q) (pendS 0) (k + 1) n k
        simp only [Count, pendS_zero, hq, if_true]
  · have hq' : pendS q = false := by simpa using hq
    have hc : c = 0 := hx hq'
    subst hc
    refine ⟨⟨(2, 0, n), fun _ => rfl⟩, ?_⟩
    have h2 : q = 2 := eq_two_of_not_pend q hq'
    subst h2
    refine ⟨stepS_two_two, fun _ => rfl, Or.inl rfl, ?_⟩
    show Count (pendS 2) (pendS 2) 0 n 0
    simp [Count, pendS_two]

theorem bwdS : ∀ (t : ℤ) (x : LadderState Qs pendS), ∃ y, RladAdm stepS pendS (t - 1) y x := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  by_cases hq : pendS q = true
  · refine ⟨⟨(0, c + 1, n), fun h => absurd h (by simp [pendS])⟩, ?_⟩
    refine ⟨stepS_zero q, fun h => absurd h (by simp [pendS]), Or.inl rfl, ?_⟩
    show Count (pendS 0) (pendS q) (c + 1) n c
    simp only [Count, pendS_zero, hq, if_true]
  · have hq' : pendS q = false := by simpa using hq
    have hc : c = 0 := hx hq'
    have h2 : q = 2 := eq_two_of_not_pend q hq'
    subst hc; subst h2
    refine ⟨⟨(2, 0, n), fun _ => rfl⟩, ?_⟩
    refine ⟨stepS_two_two, fun _ => rfl, Or.inl rfl, ?_⟩
    show Count (pendS 2) (pendS 2) 0 n 0
    simp [Count, pendS_two]

/-! ### The walk and its forced countdown -/

def wS : ℤ → Qs := fun v => if 4 ≤ v then 2 else if v = 1 then 1 else 0

def cS : ℤ → ℕ := fun v => (3 - v).toNat

theorem wS_of_le (v : ℤ) (h4 : ¬ (4 ≤ v)) (h1 : v ≠ 1) : wS v = 0 := by
  simp [wS, h4, h1]

theorem wS_one : wS 1 = 1 := by norm_num [wS]

theorem wS_of_ge (v : ℤ) (h4 : 4 ≤ v) : wS v = 2 := by simp [wS, h4]

theorem pendS_wS_of_le (v : ℤ) (h : v ≤ 3) : pendS (wS v) = true := by
  by_cases h1 : v = 1
  · rw [h1, wS_one]; decide
  · rw [wS_of_le v (by omega) h1]; decide

theorem pendS_wS_of_ge (v : ℤ) (h : 4 ≤ v) : pendS (wS v) = false := by
  rw [wS_of_ge v h]; exact pendS_two

theorem le_three_of_pendS_wS (v : ℤ) (h : pendS (wS v) = true) : v ≤ 3 := by
  by_contra hc
  exact Bool.false_ne_true ((pendS_wS_of_ge v (by omega)).symm.trans h)

theorem hwS (v : ℤ) : stepS (wS v) (wS (v + 1)) = true := by
  by_cases h4 : 4 ≤ v
  · rw [wS_of_ge v h4, wS_of_ge (v + 1) (by omega)]; exact stepS_two_two
  · by_cases h1 : v = 1
    · subst h1
      rw [show (1 : ℤ) + 1 = 2 by norm_num, wS_one, wS_of_le 2 (by omega) (by omega)]
      decide
    · rw [wS_of_le v h4 h1]; exact stepS_zero _

theorem hidleS (v : ℤ) (h : pendS (wS v) = false) : cS v = 0 := by
  have : ¬ (v ≤ 3) := by
    intro hv
    exact Bool.false_ne_true (h.symm.trans (pendS_wS_of_le v hv))
  simp only [cS]; omega

theorem hppS (v : ℤ) (_h : pendS (wS v) = true) (h' : pendS (wS (v + 1)) = true) :
    cS (v + 1) + 1 = cS v := by
  have hv := le_three_of_pendS_wS (v + 1) h'
  simp only [cS]; omega

theorem hpiS (v : ℤ) (h : pendS (wS v) = true) (h' : pendS (wS (v + 1)) = false) : cS v = 0 := by
  have hv := le_three_of_pendS_wS v h
  have hv' : ¬ (v + 1 ≤ 3) := by
    intro hle
    exact Bool.false_ne_true (h'.symm.trans (pendS_wS_of_le (v + 1) hle))
  have : v = 3 := by omega
  simp only [cS, this]; norm_num

/-- There is no region start at all: the walk is pending on `(-∞, 3]` and idle on `[4, ∞)`. -/
theorem no_region_start (s : ℤ) (h0 : pendS (wS s) = false) (h1 : pendS (wS (s + 1)) = true) :
    False := by
  have h := le_three_of_pendS_wS (s + 1) h1
  exact Bool.false_ne_true (h0.symm.trans (pendS_wS_of_le s (by omega)))

/-- **The original ladder path.** -/
theorem exists_gS : ∃ g : ℤ → LadderState Qs pendS, IsLadderPath stepS pendS g ∧
    (∀ v, objAt g v = wS v) ∧ (∀ v, cntAt g v = cS v) :=
  exists_ladderPath_of_walk wS cS 0 hwS hidleS hppS hpiS
    (fun s _ hs0 hs1 _ _ => absurd (no_region_start s hs0 hs1) not_false)
    (fun v hv0 hv1 => absurd (no_region_start v hv0 hv1) not_false)


/-! ### The object cycle of length two, and the divisibility `(K1)` supplies -/

def cycS : ℕ → Qs := fun i => if i % 2 = 0 then 0 else 1

theorem two_mem_objCycleLensS : (2 : ℕ) ∈ objCycleLens stepS pendS := by
  refine ⟨by omega, by simp [Fintype.card_fin], cycS, ?_, ?_, ?_⟩
  · intro i
    rcases Nat.mod_two_eq_zero_or_one i with h0 | h1
    · have h : (i + 1) % 2 = 1 := by omega
      simp only [cycS, h0, h]
      decide
    · have h : (i + 1) % 2 = 0 := by omega
      simp only [cycS, h1, h]
      decide
  · intro i; simp only [cycS]; split <;> decide
  · simp [cycS]

/-! ### The formula: a nested eventuality that COUNTS -/

def chiS : PlusFormula :=
  .untl PlusFormula.top ((PlusFormula.atom pS).and (.untl PlusFormula.top (.atom pS)))

theorem top_mem_closure_chiS : PlusFormula.top ∈ plusSubformulaClosure chiS := by
  have h : PlusFormula.untl PlusFormula.top
      ((PlusFormula.atom pS).and (.untl PlusFormula.top (.atom pS)))
      ∈ plusSubformulaClosure chiS := self_mem_plusSubformulaClosure chiS
  exact plusClosure_untl_right chiS _ _ h

theorem no_stab_in_closure_chiS :
    ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure chiS := by
  intro χ h
  simp [plusSubformulaClosure, chiS, PlusFormula.and, PlusFormula.neg, PlusFormula.top,
    PlusFormula.subformulas] at h

theorem wS_eq_one_iff (v : ℤ) : wS v = 1 ↔ v = 1 := by
  constructor
  · intro h
    by_cases h4 : 4 ≤ v
    · rw [wS_of_ge v h4] at h; exact absurd h (by decide)
    · by_cases h1 : v = 1
      · exact h1
      · rw [wS_of_le v h4 h1] at h; exact absurd h (by decide)
  · intro h; rw [h]; exact wS_one

/-! ### The two truth readings -/

theorem atom_truth_iff {g : ℤ → LadderState Qs pendS} {k : ℤ}
    (σ : WorldHistory (ladderFrameAdm stepS pendS fwdS bwdS).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (z : ℤ) :
    PlusTruthAt (ladderModel stepS pendS fwdS bwdS labS) σ z (.atom pS) ↔ objAt g z = 1 := by
  rw [PlusTruth.atom_iff, hσ z]
  show labS (objAt g z) pS = true ↔ objAt g z = 1
  simp [labS]

theorem chiS_false_of_orig {g : ℤ → LadderState Qs pendS} {k : ℤ}
    (σ : WorldHistory (ladderFrameAdm stepS pendS fwdS bwdS).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (hobj : ∀ v, objAt g v = wS v) (z : ℤ) :
    ¬ PlusTruthAt (ladderModel stepS pendS fwdS bwdS labS) σ z chiS := by
  rw [chiS, PlusTruth.untl_iff]
  rintro ⟨s, -, hand, -⟩
  rw [PlusTruth.and_iff] at hand
  obtain ⟨hp, hfp⟩ := hand
  rw [atom_truth_iff σ hσ s, hobj s, wS_eq_one_iff] at hp
  subst hp
  rw [PlusTruth.untl_iff] at hfp
  obtain ⟨s', hs', hp', -⟩ := hfp
  rw [atom_truth_iff σ hσ s', hobj s', wS_eq_one_iff] at hp'
  subst hp'
  exact absurd hs' (lt_irrefl 1)

theorem spliced_obj_eq_one_iff {g g' : ℤ → LadderState Qs pendS}
    (hobj : ∀ v, objAt g v = wS v) (hobj' : ∀ v, objAt g' v = spliceObj g 0 2 v) (v : ℤ) :
    objAt g' v = 1 ↔ (v = 1 ∨ v = 3) := by
  rw [hobj' v]
  by_cases h : v < 0 + ((2 : ℕ) : ℤ)
  · rw [spliceObj_of_lt v h, hobj v, wS_eq_one_iff]
    constructor
    · exact fun hv => Or.inl hv
    · rintro (h1 | h3)
      · exact h1
      · omega
  · rw [spliceObj_of_ge v (by omega), hobj (v - ((2 : ℕ) : ℤ)), wS_eq_one_iff,
      show ((2 : ℕ) : ℤ) = 2 from by norm_num] at *
    omega

/-- The object walk hits the `p`-state at position `1` AND at position `3`. One splice at
`(0, 2)` creates this from the original's single hit, and no further splice destroys it. -/
def TwoHits (g : ℤ → LadderState Qs pendS) : Prop := objAt g 1 = 1 ∧ objAt g 3 = 1

theorem chiS_true_of_twoHits {g' : ℤ → LadderState Qs pendS} {k : ℤ}
    (σ' : WorldHistory (ladderFrameAdm stepS pendS fwdS bwdS).toTaskFrame)
    (hσ' : ∀ t : ℤ, σ'.state t = (t + k, g' t)) (h : TwoHits g') (z : ℤ) (hz : z < 1) :
    PlusTruthAt (ladderModel stepS pendS fwdS bwdS labS) σ' z chiS := by
  rw [chiS, PlusTruth.untl_iff]
  refine ⟨1, hz, ?_, fun r _ _ => PlusTruth.top_true _ _ _⟩
  rw [PlusTruth.and_iff]
  refine ⟨?_, ?_⟩
  · rw [atom_truth_iff σ' hσ' 1]; exact h.1
  · rw [PlusTruth.untl_iff]
    refine ⟨3, by norm_num, ?_, fun r _ _ => PlusTruth.top_true _ _ _⟩
    rw [atom_truth_iff σ' hσ' 3]; exact h.2

/-- **ONE splice at `(0, 2)` creates the second hit.** -/
theorem twoHits_of_spliced {g g' : ℤ → LadderState Qs pendS} (h1 : objAt g 1 = 1)
    (hobj' : ∀ v, objAt g' v = spliceObj g 0 2 v) : TwoHits g' := by
  refine ⟨?_, ?_⟩
  · rw [hobj' 1, spliceObj_of_lt 1 (by norm_num)]; exact h1
  · rw [hobj' 3, spliceObj_of_ge 3 (by norm_num),
      show (3 : ℤ) - ((2 : ℕ) : ℤ) = 1 from by norm_num]
    exact h1

/-- **AND NO FURTHER SPLICE DESTROYS IT**, so the refutation is not an artefact of taking the
surgery only once: the `(P + 1) / l` iterations the residue coordinate of `kappa` actually needs
keep `chiS` true at every stage, while it is false along the original at every position. -/
theorem twoHits_iterate {g g' : ℤ → LadderState Qs pendS} (h : TwoHits g)
    (hobj' : ∀ v, objAt g' v = spliceObj g 0 2 v) : TwoHits g' :=
  twoHits_of_spliced h.1 hobj'

/-- **The spliced path satisfies the splice hypotheses again at `(0, 2)`**, so the iteration is
genuinely available and the previous statement is not vacuous. -/
theorem spliced_rehypotheses {g g' : ℤ → LadderState Qs pendS}
    (hobj : ∀ v, objAt g v = wS v) (hcnt : ∀ v, cntAt g v = cS v)
    (hobj' : ∀ v, objAt g' v = spliceObj g 0 2 v)
    (hcnt' : ∀ v, cntAt g' v = spliceCnt g 0 2 v) :
    pendS (objAt g' 0) = true ∧ (2 : ℕ) ≤ cntAt g' 0 ∧
      objAt g' 0 = objAt g' (0 + ((2 : ℕ) : ℤ)) ∧
      (∀ p : ℤ, p ≤ 0 → pendS (objAt g' p) = true) := by
  have hpend : ∀ p : ℤ, p ≤ 0 → pendS (objAt g' p) = true := fun p hp => by
    rw [hobj' p, spliceObj_of_lt p (by omega), hobj p]
    exact pendS_wS_of_le p (by omega)
  refine ⟨hpend 0 le_rfl, ?_, ?_, hpend⟩
  · rw [hcnt' 0, spliceCnt_of_lt 0 (by norm_num), if_pos (by positivity), hcnt 0]
    simp only [cS]; norm_num
  · rw [hobj' 0, hobj' (0 + ((2 : ℕ) : ℤ)), spliceObj_of_lt 0 (by norm_num),
      spliceObj_of_ge (0 + ((2 : ℕ) : ℤ)) le_rfl,
      show (0 : ℤ) + ((2 : ℕ) : ℤ) - ((2 : ℕ) : ℤ) = 0 from by ring]

theorem chiS_true_of_spliced {g g' : ℤ → LadderState Qs pendS} {k : ℤ}
    (σ' : WorldHistory (ladderFrameAdm stepS pendS fwdS bwdS).toTaskFrame)
    (hσ' : ∀ t : ℤ, σ'.state t = (t + k, g' t))
    (hobj : ∀ v, objAt g v = wS v) (hobj' : ∀ v, objAt g' v = spliceObj g 0 2 v)
    (z : ℤ) (hz : z < 1) :
    PlusTruthAt (ladderModel stepS pendS fwdS bwdS labS) σ' z chiS :=
  chiS_true_of_twoHits σ' hσ' (twoHits_of_spliced (by rw [hobj 1]; exact wS_one) hobj') z hz


/-! ### WHY the block is the wrong unit, compiled

The refutation runs on an OBJECT cycle: the block's two endpoints carry the same object state.
They do NOT carry the same realized type, and that is the precise defect. `⊤ U p` holds at the
block's entry (the single `p`-hit lies inside the block) and fails at its exit (nothing after it
hits `p`), so the loop is not a unit of type-invariance and the seam has nothing to disarm it.
This is what keeps the refutation OFF a block whose endpoint types agree: such a block is a
different object, and nothing here speaks about it. -/

/-- `⊤ U p`, the inner eventuality of `chiS`, is a closure member of `chiS`. -/
theorem futp_mem_closure_chiS :
    PlusFormula.untl PlusFormula.top (PlusFormula.atom pS) ∈ plusSubformulaClosure chiS := by
  have h0 : PlusFormula.untl PlusFormula.top
      ((PlusFormula.atom pS).and (.untl PlusFormula.top (.atom pS)))
      ∈ plusSubformulaClosure chiS := self_mem_plusSubformulaClosure chiS
  have h1 : ((PlusFormula.atom pS).and (.untl PlusFormula.top (.atom pS)))
      ∈ plusSubformulaClosure chiS := plusClosure_untl_left chiS _ _ h0
  have h2 : ((PlusFormula.atom pS).imp
      ((PlusFormula.untl PlusFormula.top (PlusFormula.atom pS)).imp PlusFormula.bot))
      ∈ plusSubformulaClosure chiS := plusClosure_imp_left chiS _ _ h1
  have h3 : ((PlusFormula.untl PlusFormula.top (PlusFormula.atom pS)).imp PlusFormula.bot)
      ∈ plusSubformulaClosure chiS := plusClosure_imp_right chiS _ _ h2
  exact plusClosure_imp_left chiS _ _ h3

/-- **THE PUMPED BLOCK IS NOT TYPE-RESPECTING.** Its two endpoints carry the same object state and
DIFFERENT realized types. So what this file refutes is the splice at an OBJECT cycle; a block whose
endpoint TYPES agree is a different object, and this probe says nothing about it either way. -/
theorem splice_block_not_type_respecting {g : ℤ → LadderState Qs pendS} {k : ℤ}
    (σ : WorldHistory (ladderFrameAdm stepS pendS fwdS bwdS).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (hobj : ∀ v, objAt g v = wS v) :
    objAt g 0 = objAt g (0 + ((2 : ℕ) : ℤ)) ∧
      tpOf (ladderModel stepS pendS fwdS bwdS labS) chiS σ 0
        ≠ tpOf (ladderModel stepS pendS fwdS bwdS labS) chiS σ 2 := by
  have h2 : (0 : ℤ) + ((2 : ℕ) : ℤ) = 2 := by norm_num
  refine ⟨?_, ?_⟩
  · rw [h2, hobj 0, hobj 2, wS_of_le 0 (by omega) (by omega), wS_of_le 2 (by omega) (by omega)]
  · intro heq
    -- `⊤ U p` holds at the block's entry: the single `p`-hit is at position `1`
    have hin : PlusFormula.untl PlusFormula.top (PlusFormula.atom pS)
        ∈ tpOf (ladderModel stepS pendS fwdS bwdS labS) chiS σ 0 := by
      rw [mem_tpOf_iff]
      refine ⟨futp_mem_closure_chiS, ?_⟩
      rw [PlusTruth.untl_iff]
      refine ⟨1, by norm_num, ?_, fun r _ _ => PlusTruth.top_true _ _ _⟩
      rw [atom_truth_iff σ hσ 1, hobj 1]
      exact wS_one
    -- and fails at its exit: nothing after position `2` hits the `p`-state
    rw [heq, mem_tpOf_iff, PlusTruth.untl_iff] at hin
    obtain ⟨s, hs, hp, -⟩ := hin.2
    rw [atom_truth_iff σ hσ s, hobj s, wS_eq_one_iff] at hp
    subst hp
    exact absurd hs (by norm_num)

/-! ### The parameters, discharged at the periodicity fixpoint's own outputs -/

noncomputable def TcS : ℕ := Tcof stepS pendS labS chiS
noncomputable def TnS : ℕ := Tnof stepS pendS labS chiS
noncomputable def PS : ℕ := Pof stepS pendS labS chiS
noncomputable def BS : ℕ := Bof stepS pendS labS chiS

theorem paramsOkS : ParamsOk stepS pendS labS chiS TcS TnS PS BS :=
  paramsOk_params stepS pendS labS chiS

theorem natAbs_neg_cast (m : ℕ) : m ≤ ((0 : ℤ) - -(m : ℤ)).natAbs := by
  rw [show (0 : ℤ) - -(m : ℤ) = (m : ℤ) from by ring, Int.natAbs_natCast]

theorem two_dvd_PS_succ : (2 : ℕ) ∣ PS + 1 :=
  paramsOkS.1.2.1 2 two_mem_objCycleLensS

/-! ### The separating pair -/

theorem exists_separating_splice :
    ∃ (g g' : ℤ → LadderState Qs pendS)
      (σ σ' : WorldHistory (ladderFrameAdm stepS pendS fwdS bwdS).toTaskFrame) (z : ℤ),
      IsLadderPath stepS pendS g ∧ IsLadderPath stepS pendS g' ∧
      pendS (objAt g 0) = true ∧ (2 : ℕ) ≤ cntAt g 0 ∧
      objAt g 0 = objAt g (0 + ((2 : ℕ) : ℤ)) ∧
      (∀ v, objAt g' v = spliceObj g 0 2 v) ∧ (∀ v, cntAt g' v = spliceCnt g 0 2 v) ∧
      (∀ t : ℤ, σ.state t = (t, g t)) ∧ (∀ t : ℤ, σ'.state t = (t, g' t)) ∧
      TcS ≤ (0 - z).natAbs ∧
      PlusFormula.top ∈ tpOf (ladderModel stepS pendS fwdS bwdS labS) chiS σ z ∧
      PlusFormula.top ∈ tpOf (ladderModel stepS pendS fwdS bwdS labS) chiS σ' z ∧
      tpOf (ladderModel stepS pendS fwdS bwdS labS) chiS σ z
        ≠ tpOf (ladderModel stepS pendS fwdS bwdS labS) chiS σ' z := by
  obtain ⟨g, hg, hobj, hcnt⟩ := exists_gS
  have hw0 : wS 0 = 0 := wS_of_le 0 (by omega) (by omega)
  have hw2 : wS 2 = 0 := wS_of_le 2 (by omega) (by omega)
  have hpa : pendS (objAt g 0) = true := by rw [hobj 0]; exact pendS_wS_of_le 0 (by omega)
  have hcl : (2 : ℕ) ≤ cntAt g 0 := by rw [hcnt 0]; simp only [cS]; norm_num
  have hpast : ∀ p : ℤ, p ≤ 0 → pendS (objAt g p) = true := fun p hp => by
    rw [hobj p]; exact pendS_wS_of_le p (by omega)
  have hrep : objAt g 0 = objAt g (0 + ((2 : ℕ) : ℤ)) := by
    have h2 : (0 : ℤ) + ((2 : ℕ) : ℤ) = 2 := by norm_num
    rw [h2, hobj 0, hobj 2, hw0, hw2]
  obtain ⟨g', hg', hobj', hcnt'⟩ :=
    exists_spliced_ladderPath_of_pend_past hg (by omega) hcl hpast hrep
  obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath fwdS bwdS g hg
  obtain ⟨σ', hσ'⟩ := exists_hist_of_isLadderPath fwdS bwdS g' hg'
  have hσ0 : ∀ t : ℤ, σ.state t = (t + (0 : ℤ), g t) := fun t => by rw [add_zero]; exact hσ t
  have hσ0' : ∀ t : ℤ, σ'.state t = (t + (0 : ℤ), g' t) := fun t => by rw [add_zero]; exact hσ' t
  refine ⟨g, g', σ, σ', -(TcS : ℤ), hg, hg', hpa, hcl, hrep, hobj', hcnt', hσ, hσ', natAbs_neg_cast TcS,
    ?_, ?_, ?_⟩
  · rw [mem_tpOf_iff]
    exact ⟨top_mem_closure_chiS, PlusTruth.top_true _ _ _⟩
  · rw [mem_tpOf_iff]
    exact ⟨top_mem_closure_chiS, PlusTruth.top_true _ _ _⟩
  · intro heq
    have h1 : chiS ∈ tpOf (ladderModel stepS pendS fwdS bwdS labS) chiS σ' (-(TcS : ℤ)) := by
      rw [mem_tpOf_iff]
      exact ⟨self_mem_plusSubformulaClosure chiS,
        chiS_true_of_spliced σ' hσ0' hobj hobj' _ (by omega)⟩
    rw [← heq, mem_tpOf_iff] at h1
    exact chiS_false_of_orig σ hσ0 hobj _ h1.2

/-! ### The refuted schema -/

/-- **Half (ii) of the truth-transport layer, as a schema.** -/
def SpliceTypeInvariance : Prop :=
  ∀ (Q : Type) [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (φ : PlusFormula) (Tc Tn P B : ℕ),
    ParamsOk step pend lab φ Tc Tn P B →
    (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (g g' : ℤ → LadderState Q pend) (a : ℤ) (l : ℕ),
    IsLadderPath step pend g → IsLadderPath step pend g' →
    0 < l → pend (objAt g a) = true → l ≤ cntAt g a →
    objAt g a = objAt g (a + (l : ℤ)) → l ∣ P + 1 →
    (∀ v, objAt g' v = spliceObj g a l v) → (∀ v, cntAt g' v = spliceCnt g a l v) →
    ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
    (∀ t : ℤ, σ.state t = (t, g t)) → (∀ t : ℤ, σ'.state t = (t, g' t)) →
    ∀ z : ℤ, Tc ≤ (a - z).natAbs →
      tpOf (ladderModel step pend fwd bwd lab) φ σ z
        = tpOf (ladderModel step pend fwd bwd lab) φ σ' z

/-- **THE REFUTATION.** -/
theorem splice_type_invariance_refuted : ¬ SpliceTypeInvariance := by
  intro h
  obtain ⟨g, g', σ, σ', z, hg, hg', hpa, hcl, hrep, hobj', hcnt', hσ, hσ', hz, -, -, hne⟩ :=
    exists_separating_splice
  exact hne (h Qs stepS pendS labS fwdS bwdS chiS TcS TnS PS BS paramsOkS
    no_stab_in_closure_chiS g g' 0 2 hg hg' (by omega) hpa hcl hrep two_dvd_PS_succ
    hobj' hcnt' σ σ' hσ hσ' z hz)

end Probe761S

#print axioms Probe761S.fwdS
#print axioms Probe761S.bwdS
#print axioms Probe761S.exists_gS
#print axioms Probe761S.two_mem_objCycleLensS
#print axioms Probe761S.top_mem_closure_chiS
#print axioms Probe761S.no_stab_in_closure_chiS
#print axioms Probe761S.wS_eq_one_iff
#print axioms Probe761S.atom_truth_iff
#print axioms Probe761S.chiS_false_of_orig
#print axioms Probe761S.spliced_obj_eq_one_iff
#print axioms Probe761S.chiS_true_of_twoHits
#print axioms Probe761S.twoHits_of_spliced
#print axioms Probe761S.twoHits_iterate
#print axioms Probe761S.spliced_rehypotheses
#print axioms Probe761S.chiS_true_of_spliced
#print axioms Probe761S.paramsOkS
#print axioms Probe761S.futp_mem_closure_chiS
#print axioms Probe761S.splice_block_not_type_respecting
#print axioms Probe761S.two_dvd_PS_succ
#print axioms Probe761S.exists_separating_splice
#print axioms Probe761S.splice_type_invariance_refuted
