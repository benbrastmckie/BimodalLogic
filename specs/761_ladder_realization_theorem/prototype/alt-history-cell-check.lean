/-
THE ALTERNATIVE HISTORY THROUGH THE ORIGINAL STATE: the separating pair does NOT separate the
CELLS.

The splice-type refutation (`specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean`,
`Probe761S`) exhibits two ladder paths through counter-class-equivalent states whose realized
types differ at `z`, refuting half (ii) of the truth-transport layer. Its own "What this probe
does NOT show" section leaves one question open, verbatim:

  "It settles NOTHING about `cellAt_const_of_kappa_eq` itself -- a cell is the set of types
  realized by ALL histories through a state, and this probe compares two particular histories;
  whether some other history through the original state realizes `chiS` is not decided here and
  no claim is made either way."

This file decides it, AFFIRMATIVELY: `chiS` IS realized at the ORIGINAL state, by a second
history through that very state. So the formula that separates the two PATHS does not separate
the two CELLS, and the cell-level route to the agreement is not touched by the refutation.

## What is settled here

The fixture is the refutation's own (three-state object, `pendS`/`stepS`/`labS`, the walk `wS`
with its forced countdown `cS`, the formula `chiS = ⊤ U (p ∧ ⊤ U p)`), reproduced because the
probe is not a library module and cannot be imported.

  1. `w2`, the ALTERNATIVE walk: the original `wS` with ONE position changed -- position `3`
     moved from the `0`-state to the `p`-state. `w2_eq_wS_of_ne` records that it agrees with
     `wS` everywhere else.
  2. `pendS_w2`: the alternative walk has the SAME pending/idle profile as the original at every
     position (`pendS 1 = pendS 0 = true`). This is the load-bearing fact. Every clause of `Rlad`
     except the `step` clause reads only `pend` of the object, the countdown and the deadline
     register -- so all three of them transfer VERBATIM with the original's own `cntAt` and
     `nxtAt`, and only the `step` clause has to be rechecked (`hw2`).
  3. `altPath`: therefore the alternative walk carries the ORIGINAL path's countdown and deadline
     register unchanged, is a ladder path (`altPath_isLadderPath`), and -- because it differs from
     the original only at position `3` -- passes through the IDENTICAL ladder state at every
     position below `3`, the original's own state, not merely a class-equivalent one
     (`altPath_eq_of_ne`). No splice, no parameter, no divisibility and no `ParamsOk` is used
     anywhere in its construction.
  4. `chiS_in_cell_at_original_state`: at every `z < 1` the cell at the ORIGINAL state
     `(z, g z)` contains a type carrying `chiS` (realized by the alternative history) AND the
     original history's own type at `z` does NOT carry `chiS` (`chiS_false_of_orig`, the
     refutation's own lemma). The cell is therefore not the original type's singleton, and it
     already contains the bit the splice was accused of adding.
  5. `alt_atoms_eq_spliced_atoms`: the alternative path and the SPLICED path hit the `p`-state at
     exactly the same positions, `{1, 3}`. The atom valuation along the two is identical, which
     is the hypothesis any type-level comparison between them would need.

## What this does NOT show

It does NOT prove `cellAt_const_of_kappa_eq`, and it does not prove the full type equality
`tpOf (alt) z = tpOf (spliced) z` -- item 5 supplies the atom-level agreement that claim would
rest on, but the induction over `chiS`'s closure that would turn it into type equality is not
performed here. It refutes nothing: half (ii) stays refuted, the splice stays type-blind, and the
pumping route's defect is untouched. What it removes is the inference from that refutation to a
cell-level obstruction: at the refutation's own witness, there is none.

## Verification

`#print axioms` on every theorem below. No `sorry`, no axiom, no `native_decide`, no placeholder
body, no vacuous definition.

Compile: `lake env lean` on this file. NOT a wired probe and NOT gate-covered; a prototype. If
the revision adopts the cell-level route, items 1-4 are what it should land in the library.
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace AltHistory

/-! ## The refutation's fixture, reproduced

Identical to `Probe761S`'s, which is the oracle. Reproduced rather than imported because
`specs/evidence/**` is not on the Lake source path. -/

abbrev Qs : Type := Fin 3

def pendS : Qs → Bool := fun q => decide (q.val < 2)

def stepS : Qs → Qs → Bool := fun x y =>
  if x = 0 then true else if x = 1 then decide (y = 0 ∨ y = 2) else decide (y = 2)

def pS : Atom := ⟨"p", none⟩

def labS : Qs → Atom → Bool := fun q at_ => decide (at_ = pS ∧ q = 1)

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
        simp only [Count, show pendS 0 = true from by decide, hq, if_true]
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
    simp only [Count, show pendS 0 = true from by decide, hq, if_true]
  · have hq' : pendS q = false := by simpa using hq
    have hc : c = 0 := hx hq'
    have h2 : q = 2 := eq_two_of_not_pend q hq'
    subst hc; subst h2
    refine ⟨⟨(2, 0, n), fun _ => rfl⟩, ?_⟩
    refine ⟨stepS_two_two, fun _ => rfl, Or.inl rfl, ?_⟩
    show Count (pendS 2) (pendS 2) 0 n 0
    simp [Count, pendS_two]

/-! ### The original walk and its forced countdown -/

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

theorem no_region_start (s : ℤ) (h0 : pendS (wS s) = false) (h1 : pendS (wS (s + 1)) = true) :
    False := by
  have h := le_three_of_pendS_wS (s + 1) h1
  exact Bool.false_ne_true (h0.symm.trans (pendS_wS_of_le s (by omega)))

/-- **The original ladder path**, the refutation's own. -/
theorem exists_gS : ∃ g : ℤ → LadderState Qs pendS, IsLadderPath stepS pendS g ∧
    (∀ v, objAt g v = wS v) ∧ (∀ v, cntAt g v = cS v) :=
  exists_ladderPath_of_walk wS cS 0 hwS hidleS hppS hpiS
    (fun s _ hs0 hs1 _ _ => absurd (no_region_start s hs0 hs1) not_false)
    (fun v hv0 hv1 => absurd (no_region_start v hv0 hv1) not_false)

/-! ### The formula, and the two truth readings -/

def chiS : PlusFormula :=
  .untl PlusFormula.top ((PlusFormula.atom pS).and (.untl PlusFormula.top (.atom pS)))

theorem wS_eq_one_iff (v : ℤ) : wS v = 1 ↔ v = 1 := by
  constructor
  · intro h
    by_cases h4 : 4 ≤ v
    · rw [wS_of_ge v h4] at h; exact absurd h (by decide)
    · by_cases h1 : v = 1
      · exact h1
      · rw [wS_of_le v h4 h1] at h; exact absurd h (by decide)
  · intro h; rw [h]; exact wS_one

theorem atom_truth_iff {g : ℤ → LadderState Qs pendS} {k : ℤ}
    (σ : WorldHistory (ladderFrameAdm stepS pendS fwdS bwdS).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (z : ℤ) :
    PlusTruthAt (ladderModel stepS pendS fwdS bwdS labS) σ z (.atom pS) ↔ objAt g z = 1 := by
  rw [PlusTruth.atom_iff, hσ z]
  show labS (objAt g z) pS = true ↔ objAt g z = 1
  simp [labS]

/-- The refutation's own: `chiS` is FALSE along the original at every position. -/
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

/-- The refutation's own: two `p`-hits make `chiS` true below the first. -/
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

/-! ## THE ALTERNATIVE WALK

The original with ONE position changed: position `3` moved from the `0`-state to the `p`-state.
Both are pending, so the pending/idle profile -- and with it the whole forced counter structure
-- is untouched. -/

def w2 : ℤ → Qs := fun v => if 4 ≤ v then 2 else if v = 1 then 1 else if v = 3 then 1 else 0

theorem w2_eq_wS_of_ne (v : ℤ) (h : v ≠ 3) : w2 v = wS v := by
  by_cases h4 : 4 ≤ v
  · rw [wS_of_ge v h4]; simp [w2, h4]
  · by_cases h1 : v = 1
    · subst h1; rw [wS_one]; norm_num [w2]
    · rw [wS_of_le v h4 h1]; simp [w2, h4, h1, h]

theorem w2_one : w2 1 = 1 := by norm_num [w2]

theorem w2_three : w2 3 = 1 := by norm_num [w2]

theorem w2_of_ge (v : ℤ) (h4 : 4 ≤ v) : w2 v = 2 := by simp [w2, h4]

/-- **The load-bearing fact**: the alternative walk has the SAME pending/idle profile as the
original at every position. Every `Rlad` clause but the `step` clause reads the object only
through `pend`, so all of them transfer with the original's own counters. -/
theorem pendS_w2 (v : ℤ) : pendS (w2 v) = pendS (wS v) := by
  by_cases h : v = 3
  · subst h
    rw [w2_three, wS_of_le 3 (by omega) (by omega)]
    decide
  · rw [w2_eq_wS_of_ne v h]

theorem w2_eq_one_iff (v : ℤ) : w2 v = 1 ↔ (v = 1 ∨ v = 3) := by
  constructor
  · intro h
    by_cases h3 : v = 3
    · exact Or.inr h3
    · rw [w2_eq_wS_of_ne v h3, wS_eq_one_iff] at h; exact Or.inl h
  · rintro (h1 | h3)
    · subst h1; exact w2_one
    · subst h3; exact w2_three

theorem hw2 (v : ℤ) : stepS (w2 v) (w2 (v + 1)) = true := by
  by_cases h4 : 4 ≤ v
  · rw [w2_of_ge v h4, w2_of_ge (v + 1) (by omega)]; exact stepS_two_two
  · by_cases h3 : v = 3
    · subst h3
      rw [w2_three, show (3 : ℤ) + 1 = 4 by norm_num, w2_of_ge 4 le_rfl]
      decide
    · by_cases h1 : v = 1
      · subst h1
        rw [w2_one, show (1 : ℤ) + 1 = 2 by norm_num,
          w2_eq_wS_of_ne 2 (by omega), wS_of_le 2 (by omega) (by omega)]
        decide
      · rw [w2_eq_wS_of_ne v h3, wS_of_le v h4 h1]; exact stepS_zero _

/-! ## THE ALTERNATIVE PATH, through the ORIGINAL state

Carries the original path's countdown and deadline register verbatim. -/

/-- The alternative ladder path: the original's counters on the alternative walk. -/
def altPath (g : ℤ → LadderState Qs pendS) (hobj : ∀ v, objAt g v = wS v)
    (v : ℤ) : LadderState Qs pendS :=
  ⟨(w2 v, cntAt g v, nxtAt g v), by
    intro hfalse
    refine (g v).2 ?_
    show pendS (objAt g v) = false
    rw [hobj v, ← pendS_w2 v]
    exact hfalse⟩

theorem objAt_altPath (g : ℤ → LadderState Qs pendS) (hobj : ∀ v, objAt g v = wS v) (v : ℤ) :
    objAt (altPath g hobj) v = w2 v := rfl

theorem pendS_w2_objAt (g : ℤ → LadderState Qs pendS) (hobj : ∀ v, objAt g v = wS v) (v : ℤ) :
    pendS (w2 v) = pendS (objAt g v) := by rw [hobj v]; exact pendS_w2 v

/-- **The alternative walk IS a ladder path**, with the original's counters: only the `step`
clause of `Rlad` needed rechecking. No splice, no parameter, no divisibility. -/
theorem altPath_isLadderPath (g : ℤ → LadderState Qs pendS) (hg : IsLadderPath stepS pendS g)
    (hobj : ∀ v, objAt g v = wS v) : IsLadderPath stepS pendS (altPath g hobj) := by
  intro u
  obtain ⟨-, h2, h3, h4⟩ := hg u
  refine ⟨hw2 u, ?_, h3, ?_⟩
  · intro hfalse
    exact h2 ((pendS_w2_objAt g hobj u).symm.trans hfalse)
  · rw [show (altPath g hobj u).1.2.1 = cntAt g u from rfl,
      show (altPath g hobj u).1.2.2 = nxtAt g u from rfl,
      show (altPath g hobj (u + 1)).1.2.1 = cntAt g (u + 1) from rfl,
      show (altPath g hobj u).1.1 = w2 u from rfl,
      show (altPath g hobj (u + 1)).1.1 = w2 (u + 1) from rfl,
      pendS_w2_objAt g hobj u, pendS_w2_objAt g hobj (u + 1)]
    exact h4

/-- **And it passes through the ORIGINAL state** at every position but `3` -- the identical
ladder state, not merely a class-equivalent one. -/
theorem altPath_eq_of_ne (g : ℤ → LadderState Qs pendS) (hobj : ∀ v, objAt g v = wS v)
    (z : ℤ) (hz : z ≠ 3) : altPath g hobj z = g z := by
  apply Subtype.ext
  show (w2 z, cntAt g z, nxtAt g z) = (g z).1
  rw [w2_eq_wS_of_ne z hz, ← hobj z]
  rfl

theorem twoHits_altPath (g : ℤ → LadderState Qs pendS) (hobj : ∀ v, objAt g v = wS v) :
    TwoHits (altPath g hobj) := ⟨w2_one, w2_three⟩

/-! ## THE HEADLINE -/

/-- **THE SEPARATING PAIR DOES NOT SEPARATE THE CELLS.** At every `z < 1`, the cell at the
ORIGINAL state `(z, g z)` contains a type carrying `chiS` -- realized by the alternative history
through that very state -- while the ORIGINAL history's own type at `z` does not carry it. The
cell is therefore not the original type's singleton: it already contains the bit the splice was
accused of adding, and `chiS` is no obstruction to `cellAt_const_of_kappa_eq`.

The third conjunct is NON-VACUITY for the fourth's second half: the original history it
quantifies over exists, so "the original type does not carry `chiS`" is a statement about a real
history rather than an empty quantification. -/
theorem chiS_in_cell_at_original_state :
    ∃ g : ℤ → LadderState Qs pendS,
      IsLadderPath stepS pendS g ∧ (∀ v, objAt g v = wS v) ∧ (∀ v, cntAt g v = cS v) ∧
      (∃ σ : WorldHistory (ladderFrameAdm stepS pendS fwdS bwdS).toTaskFrame,
        ∀ t : ℤ, σ.state t = (t, g t)) ∧
      ∀ z : ℤ, z < 1 →
        (∃ T ∈ cellAt (ladderModel stepS pendS fwdS bwdS labS) chiS
            ((z, g z) : (ladderFrameAdm stepS pendS fwdS bwdS).WorldState) z, chiS ∈ T) ∧
        (∀ σ : WorldHistory (ladderFrameAdm stepS pendS fwdS bwdS).toTaskFrame,
          (∀ t : ℤ, σ.state t = (t, g t)) →
            chiS ∉ tpOf (ladderModel stepS pendS fwdS bwdS labS) chiS σ z) := by
  obtain ⟨g, hg, hobj, hcnt⟩ := exists_gS
  refine ⟨g, hg, hobj, hcnt, exists_hist_of_isLadderPath fwdS bwdS g hg,
    fun z hz => ⟨?_, ?_⟩⟩
  · obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdS bwdS (altPath g hobj)
      (altPath_isLadderPath g hg hobj)
    refine ⟨tpOf (ladderModel stepS pendS fwdS bwdS labS) chiS τ z, ?_, ?_⟩
    · exact (mem_cellAt_ladder_iff fwdS bwdS labS chiS (g z) z _).mpr
        ⟨altPath g hobj, τ, altPath_isLadderPath g hg hobj,
          altPath_eq_of_ne g hobj z (by omega), hτ, rfl⟩
    · rw [mem_tpOf_iff]
      refine ⟨self_mem_plusSubformulaClosure chiS, ?_⟩
      exact chiS_true_of_twoHits (k := 0) τ (fun t => by rw [add_zero]; exact hτ t)
        (twoHits_altPath g hobj) z hz
  · intro σ hσ hmem
    exact chiS_false_of_orig (k := 0) σ (fun t => by rw [add_zero]; exact hσ t) hobj z
      ((mem_tpOf_iff _ _ _ _ _).mp hmem).2

/-- **The alternative path and the SPLICED path carry the IDENTICAL atom valuation**: both hit
the `p`-state at exactly `{1, 3}`. This is the atom-level agreement a type-level comparison
between them would rest on; the comparison itself is not performed here. -/
theorem alt_atoms_eq_spliced_atoms (g g' : ℤ → LadderState Qs pendS)
    (hobj : ∀ v, objAt g v = wS v) (hobj' : ∀ v, objAt g' v = spliceObj g 0 2 v) (v : ℤ) :
    (objAt (altPath g hobj) v = 1) ↔ (objAt g' v = 1) := by
  rw [objAt_altPath g hobj v, w2_eq_one_iff, hobj' v]
  by_cases h : v < 0 + ((2 : ℕ) : ℤ)
  · rw [spliceObj_of_lt v h, hobj v, wS_eq_one_iff]
    constructor
    · rintro (h1 | h3)
      · exact h1
      · omega
    · exact fun h1 => Or.inl h1
  · rw [spliceObj_of_ge v (by omega), hobj (v - ((2 : ℕ) : ℤ)), wS_eq_one_iff,
      show ((2 : ℕ) : ℤ) = 2 from by norm_num] at *
    omega

end AltHistory

#print axioms AltHistory.pendS_w2
#print axioms AltHistory.hw2
#print axioms AltHistory.altPath_isLadderPath
#print axioms AltHistory.altPath_eq_of_ne
#print axioms AltHistory.chiS_in_cell_at_original_state
#print axioms AltHistory.alt_atoms_eq_spliced_atoms
