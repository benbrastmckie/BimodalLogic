/-
THE TPOF PERIODICITY REFUTATION: the realized closure type along a ladder path is NOT eventually
periodic.  The unconditional model-level periodicity statement -- "along every ladder path there
are a threshold `N` and a period `p > 0` with `tpOf σ (z + p) = tpOf σ z` for every `z ≥ N`", the
shape `satThreshold`/`satPeriod` carry on the certificate side -- is FALSE, and this file compiles
the refutation.

## What was asked, and what this probe answers

What was asked for was the model-side analogue of the certificate graph's periodicity: a
statement about `tpOf` along a ladder path.  The only landed periodicity statement is
`prodPre_periodic`, whose outputs `satThreshold`/`satPeriod` are a fact about the
backward-reachability fixpoint on `Finset (ProdState Q phi)` -- a CERTIFICATE-relation fact, with
nothing in the layer relating it to `Rlad`, `ladderModel`, `tpOf` or `cellAt`.  The question this
probe settles is whether the model side carries that statement UNCONDITIONALLY, so that a bridge
could be built to it from either end.  It does not.

The conditional form does hold and is landed beside half (i) as
`tpOf_periodic_of_objAt_periodic`: a GLOBALLY `l`-periodic object walk makes the realized
stab-free type `l`-periodic at every position.  This probe shows that the hypothesis there is
load-bearing and not decorative: drop it and the conclusion fails.

## What is settled here

The object is two states, `false` and `true`, both IDLE (`pendA _ = false`), with `stepA` total.
So `Adm` pins the current deadline to `0` everywhere, `Count` is discharged by the idle clause at
every step, and the only free datum of a path is its object walk -- which is therefore an
ARBITRARY function `ℤ → Bool`.  That is the whole content of the refutation: the atomic clause
reads `objAt`, so an aperiodic walk gives an aperiodic realized type, and no hypothesis of the
unconditional statement constrains the walk.

  1. `fwdA`, `bwdA`: `RladAdm` is serial in both directions on the admissible carrier, so
     `ladderFrameAdm` and `ladderModel` are available on this object.  Both hypotheses are
     DISCHARGED, not assumed.
  2. `wA`: the walk is `true` exactly at the powers of two.  The predicate is a decidable,
     computable `Bool` (`isP2`, a bounded search over `Finset.range (m + 1)`), so no classical
     choice enters the walk itself.
  3. `exists_gA`: the walk lifts to a ladder path through the landed
     `exists_ladderPath_of_walk`, with countdown identically `0`.  Four of its six side conditions
     are vacuous because the object has no pending state at all, and the remaining two are `rfl`.
  4. `wA_pow`, `wA_pow_add`: the TAIL aperiodicity arithmetic.  For every `p > 0` and every
     threshold `N` there is an `n` with `2 ^ n ≥ N` and `2 ^ n > p`; then
     `2 ^ n < 2 ^ n + p < 2 ^ (n + 1)`, so `2 ^ n` is a power of two and `2 ^ n + p` is not.  The
     witness is pinned to the powers of two precisely so that the walk is aperiodic IN THE TAIL:
     an eventually constant walk would be eventually periodic and would refute nothing.
  5. `TpOfEventualPeriodicity`: the target, written out as a schema universally quantified over
     the object, its seriality, the label, the formula, the path, the path's presentation and the
     stab-free closure condition, and concluding `∃ N, ∃ p, 0 < p ∧ ∀ z ≥ N, …`.  Both
     quantifiers of the eventual form are present: a threshold AND a period.
  6. `tpOf_periodicity_refuted_unconditional : ¬ TpOfEventualPeriodicity`.
  7. `exists_separating_positions`: the separating pair, stated on its own, with the non-vacuity
     witnesses attached.

## Non-vacuity, witnessed on both sides

The separating formula is `chiA := ¬ p`, whose closure is `{¬ p, p, ⊥}`.  At a power of two the
realized type CONTAINS `p` and omits `¬ p`; at the shifted position it CONTAINS `¬ p` and omits
`p`.  `exists_separating_positions` carries all four memberships, so NEITHER type is empty and the
inequality is not an artefact of two empty sets.  The path is a ladder path of `ladderFrameAdm`
on the admissible carrier and the history is produced by the landed
`exists_hist_of_isLadderPath`, not exhibited by hand.

## What this probe does NOT show

It refutes NOTHING about `tpOf_periodic_of_objAt_periodic`, whose hypothesis this witness
violates at every NONZERO `l` (`wA_not_periodic`): `wA` is globally periodic at no nonzero
distance, since `wA (2 ^ n + l) ≠ wA (2 ^ n)` for every large `n`.  At `l = 0` that hypothesis
holds of every walk and the conditional lemma's conclusion is the identity `tpOf σ z = tpOf σ z`,
so `l = 0` is a case in which neither statement says anything.  It refutes nothing about
`objAt_tpOf_eq_of_objAt_periodic`, nothing about the duplication type lemma
`tpOf_eq_spliceIdx_of_tpOf_eq`, nothing about the spaced type pigeonhole
`exists_typeBlock_of_spacing`, and nothing about the realized-chain bridge
`realized_typeBlock_mem_prodCycleLens` / `typeBlock_length_dvd_of_paramsOk`.

It is a statement about PERIODICITY and is NOT a restatement of `splice_type_invariance_refuted`.
That refutation is about a SURGERY: whether duplicating an admissibility-preserving block
preserves the realized type.  This one performs no surgery at all -- one path, two of its
positions -- and says nothing about any splice, type-respecting or not.  Neither probe implies
the other.

It says nothing about `prodPre_periodic`, which is a fact about the certificate fixpoint and is
untouched; nothing about `cellAt_const_of_kappa_eq` or any cell-level agreement; nothing about
`ladderSound`, `ladderLift` or `ladderRealized`.  It asserts no bound, and it does not say that
the conditional form reaches the circularity the task names -- it does not, because the tight
(doubling) chain's walk is not globally periodic either.

## What is refuted, precisely

The claim refuted is that EVENTUAL periodicity of `tpOf` -- a threshold `N` and a period `p > 0`
-- holds along an ARBITRARY ladder path, with no hypothesis on the path's object walk.  It does
not: an all-idle object imposes nothing on the walk, the atomic clause reads the walk, and an
aperiodic walk is available.  Nothing here says that periodicity fails for a path whose walk IS
constrained; `tpOf_periodic_of_objAt_periodic` is the compiled statement of the case where it
holds.

## Verification

`#print axioms` on every headline theorem: `[propext, Classical.choice, Quot.sound]`, the
fixture's own profile.  No `sorry`, no axiom, no `native_decide`, no placeholder body and no
vacuous definition anywhere in this file.

Compile: `lake env lean` on this file
(`specs/evidence/seam-gluing-ray-product/ladder-tpof-periodicity-refutation.lean`).
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe852P

/-! ### The all-idle two-state object -/

abbrev Qa : Type := Bool

/-- Both states are idle, so `Adm` pins the current deadline to `0` and `Count` is discharged by
its idle clause at every step. The walk is therefore completely unconstrained. -/
def pendA : Qa → Bool := fun _ => false

/-- The object steps from anywhere to anywhere. -/
def stepA : Qa → Qa → Bool := fun _ _ => true

def pA : Atom := ⟨"p", none⟩

/-- `p` holds at the state `true` and fails at the state `false`. -/
def labA : Qa → Atom → Bool := fun q at_ => decide (at_ = pA ∧ q = true)

theorem pendA_eq (q : Qa) : pendA q = false := rfl

/-! ### Seriality, discharged -/

theorem fwdA : ∀ (t : ℤ) (x : LadderState Qa pendA), ∃ y, RladAdm stepA pendA t x y := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  have hc : c = 0 := hx rfl
  subst hc
  refine ⟨⟨(q, 0, n), fun _ => rfl⟩, rfl, fun _ => rfl, Or.inl rfl, ?_⟩
  show Count (pendA q) (pendA q) 0 n 0
  simp [Count, pendA]

theorem bwdA : ∀ (t : ℤ) (x : LadderState Qa pendA), ∃ y, RladAdm stepA pendA (t - 1) y x := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  have hc : c = 0 := hx rfl
  subst hc
  refine ⟨⟨(q, 0, n), fun _ => rfl⟩, rfl, fun _ => rfl, Or.inl rfl, ?_⟩
  show Count (pendA q) (pendA q) 0 n 0
  simp [Count, pendA]

/-! ### The aperiodic walk: `true` exactly at the powers of two -/

/-- A decidable, computable power-of-two test: a bounded search, legitimate because `j < 2 ^ j`
forces any witness `j` of `2 ^ j = m` to lie below `m + 1`. -/
def isP2 (m : ℕ) : Bool := (List.range (m + 1)).any (fun j => 2 ^ j == m)

/-- The walk. At `v ≤ 0` the value is `isP2 0 = false`, so the whole non-positive ray is
constant; all the aperiodicity lives in the tail, which is what the refutation needs. -/
def wA : ℤ → Qa := fun v => isP2 v.toNat

theorem lt_two_pow (n : ℕ) : n < 2 ^ n := by
  induction n with
  | zero => norm_num
  | succ m ih =>
      have h : (2 : ℕ) ^ (m + 1) = 2 ^ m + 2 ^ m := by rw [pow_succ]; omega
      omega

theorem two_pow_pos (n : ℕ) : 0 < (2 : ℕ) ^ n := Nat.lt_of_le_of_lt (Nat.zero_le n) (lt_two_pow n)

theorem isP2_iff (m : ℕ) : isP2 m = true ↔ ∃ j : ℕ, j < m + 1 ∧ 2 ^ j = m := by
  simp only [isP2, List.any_eq_true, List.mem_range, beq_iff_eq]

theorem wA_pow (n : ℕ) : wA ((2 ^ n : ℕ) : ℤ) = true := by
  have h : ((2 ^ n : ℕ) : ℤ).toNat = 2 ^ n := Int.toNat_natCast _
  rw [wA, h, isP2_iff]
  exact ⟨n, by have := lt_two_pow n; omega, rfl⟩

theorem wA_pow_add (n : ℕ) (p : ℤ) (hp : 0 < p) (hlt : p < ((2 ^ n : ℕ) : ℤ)) :
    wA (((2 ^ n : ℕ) : ℤ) + p) = false := by
  have hpos : 0 < (2 : ℕ) ^ n := two_pow_pos n
  have hk : (((2 ^ n : ℕ) : ℤ) + p).toNat = 2 ^ n + p.toNat := by omega
  have hk0 : 0 < p.toNat := by omega
  have hkl : p.toNat < 2 ^ n := by omega
  rw [wA, hk]
  rw [Bool.eq_false_iff, ne_eq, isP2_iff]
  rintro ⟨j, -, hj⟩
  have hgt : n < j := by
    by_contra hc
    have hle : (2 : ℕ) ^ j ≤ 2 ^ n := Nat.pow_le_pow_right (by omega) (by omega)
    omega
  have hsucc : (2 : ℕ) ^ (n + 1) = 2 ^ n + 2 ^ n := by rw [pow_succ]; omega
  have hlt' : j ≤ n := by
    by_contra hc
    have hle : (2 : ℕ) ^ (n + 1) ≤ 2 ^ j := Nat.pow_le_pow_right (by omega) (by omega)
    omega
  omega

/-- **The threshold is reachable.** For every threshold `N` and every period `p` there is a power
of two at or above `N` and strictly above `p`, so the separating pair can be placed anywhere in
the tail. -/
theorem exists_pow_ge (N p : ℤ) : ∃ n : ℕ, N ≤ ((2 ^ n : ℕ) : ℤ) ∧ p < ((2 ^ n : ℕ) : ℤ) := by
  refine ⟨N.toNat + p.toNat + 1, ?_, ?_⟩
  · have h := lt_two_pow (N.toNat + p.toNat + 1)
    omega
  · have h := lt_two_pow (N.toNat + p.toNat + 1)
    omega

/-! ### The path and its history -/

theorem exists_gA : ∃ g : ℤ → LadderState Qa pendA, IsLadderPath stepA pendA g ∧
    (∀ v, objAt g v = wA v) ∧ (∀ v, cntAt g v = 0) :=
  exists_ladderPath_of_walk wA (fun _ => 0) 0 (fun _ => rfl) (fun _ _ => rfl)
    (fun v h _ => absurd h (by simp [pendA]))
    (fun _ _ _ => rfl)
    (fun _ _ _ hs1 _ _ => absurd hs1 (by simp [pendA]))
    (fun _ _ h1 => absurd h1 (by simp [pendA]))

theorem exists_histA : ∃ (g : ℤ → LadderState Qa pendA)
    (σ : WorldHistory (ladderFrameAdm stepA pendA fwdA bwdA).toTaskFrame),
    IsLadderPath stepA pendA g ∧ (∀ t : ℤ, σ.state t = (t + 0, g t)) ∧
      (∀ v, objAt g v = wA v) := by
  obtain ⟨g, hg, hobj, -⟩ := exists_gA
  obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath fwdA bwdA g hg
  exact ⟨g, σ, hg, fun t => by rw [hσ t, add_zero], hobj⟩

/-! ### The separating formula: the negated letter -/

/-- `¬ p`. Its closure is `{¬ p, p, ⊥}`: `stab`-free, and large enough that the realized type is
nonempty at EVERY position, whichever way the letter falls. -/
def chiA : PlusFormula := PlusFormula.neg (PlusFormula.atom pA)

theorem chiA_mem_closure : chiA ∈ plusSubformulaClosure chiA :=
  self_mem_plusSubformulaClosure chiA

theorem atom_mem_closure_chiA : PlusFormula.atom pA ∈ plusSubformulaClosure chiA :=
  plusClosure_imp_left chiA (PlusFormula.atom pA) PlusFormula.bot chiA_mem_closure

theorem no_stab_in_closure_chiA :
    ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure chiA := by
  intro χ h
  simp [plusSubformulaClosure, chiA, PlusFormula.neg, PlusFormula.subformulas] at h

/-! ### The two truth readings -/

theorem atom_truth_iff {g : ℤ → LadderState Qa pendA} {k : ℤ}
    (σ : WorldHistory (ladderFrameAdm stepA pendA fwdA bwdA).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (z : ℤ) :
    PlusTruthAt (ladderModel stepA pendA fwdA bwdA labA) σ z (.atom pA) ↔ objAt g z = true := by
  rw [PlusTruth.atom_iff, hσ z]
  show labA (objAt g z) pA = true ↔ objAt g z = true
  simp [labA]

theorem atom_mem_tpOf_iff {g : ℤ → LadderState Qa pendA} {k : ℤ}
    (σ : WorldHistory (ladderFrameAdm stepA pendA fwdA bwdA).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (z : ℤ) :
    PlusFormula.atom pA ∈ tpOf (ladderModel stepA pendA fwdA bwdA labA) chiA σ z
      ↔ objAt g z = true := by
  rw [mem_tpOf_iff]
  exact ⟨fun h => (atom_truth_iff σ hσ z).mp h.2,
    fun h => ⟨atom_mem_closure_chiA, (atom_truth_iff σ hσ z).mpr h⟩⟩

theorem chiA_mem_tpOf_iff {g : ℤ → LadderState Qa pendA} {k : ℤ}
    (σ : WorldHistory (ladderFrameAdm stepA pendA fwdA bwdA).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (z : ℤ) :
    chiA ∈ tpOf (ladderModel stepA pendA fwdA bwdA labA) chiA σ z
      ↔ objAt g z = false := by
  rw [mem_tpOf_iff]
  constructor
  · rintro ⟨-, h⟩
    rw [chiA, PlusTruth.neg_iff] at h
    have := (atom_truth_iff σ hσ z).mpr
    cases hb : objAt g z with
    | false => rfl
    | true => exact absurd (this hb) h
  · intro h
    refine ⟨chiA_mem_closure, ?_⟩
    rw [chiA, PlusTruth.neg_iff]
    intro hc
    have := (atom_truth_iff σ hσ z).mp hc
    rw [h] at this
    exact absurd this (by simp)

/-! ### The target schema, and its refutation -/

/-- **EVENTUAL PERIODICITY OF THE REALIZED TYPE, UNCONDITIONALLY.** A threshold `N` and a period
`p > 0` beyond which the realized stab-free type repeats, for EVERY ladder path of EVERY object --
the shape `satThreshold`/`satPeriod` carry on the certificate side, asked of the model side with
no hypothesis on the path's object walk. -/
def TpOfEventualPeriodicity : Prop :=
  ∀ (Q : Type) [Finite Q] [Nonempty Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (k : ℤ) (g : ℤ → LadderState Q pend)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
    IsLadderPath step pend g →
    (∀ t : ℤ, σ.state t = (t + k, g t)) →
    (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∃ N : ℤ, ∃ p : ℤ, 0 < p ∧ ∀ z : ℤ, N ≤ z →
      tpOf (ladderModel step pend fwd bwd lab) φ σ (z + p)
        = tpOf (ladderModel step pend fwd bwd lab) φ σ z

/-- **THE REFUTATION.** Eventual periodicity of `tpOf` along an arbitrary ladder path is false.
Both quantifiers of the eventual form are refuted at once: no threshold `N` and no period
`p > 0` work, because at some power of two at or above `N` the letter holds and at that position
plus `p` it does not. -/
theorem tpOf_periodicity_refuted_unconditional : ¬ TpOfEventualPeriodicity := by
  intro h
  obtain ⟨g, σ, hg, hσ, hobj⟩ := exists_histA
  obtain ⟨N, p, hp, hper⟩ :=
    h Qa stepA pendA fwdA bwdA labA chiA 0 g σ hg hσ no_stab_in_closure_chiA
  obtain ⟨n, hN, hpl⟩ := exists_pow_ge N p
  have heq := hper ((2 ^ n : ℕ) : ℤ) hN
  have hin : PlusFormula.atom pA
      ∈ tpOf (ladderModel stepA pendA fwdA bwdA labA) chiA σ ((2 ^ n : ℕ) : ℤ) :=
    (atom_mem_tpOf_iff σ hσ _).mpr (by rw [hobj]; exact wA_pow n)
  have hout : PlusFormula.atom pA
      ∉ tpOf (ladderModel stepA pendA fwdA bwdA labA) chiA σ (((2 ^ n : ℕ) : ℤ) + p) := by
    intro hc
    have hb := (atom_mem_tpOf_iff σ hσ _).mp hc
    rw [hobj, wA_pow_add n p hp hpl] at hb
    exact absurd hb (by simp)
  exact hout (heq ▸ hin)

/-- **The separating pair, with non-vacuity on both sides.** Beyond every threshold and for every
period there are two positions of ONE ladder path whose realized types differ, and NEITHER of the
two types is empty: the letter is in the first and out of the second, while its negation is out of
the first and in the second. -/
theorem exists_separating_positions (N p : ℤ) (hp : 0 < p) :
    ∃ (g : ℤ → LadderState Qa pendA)
      (σ : WorldHistory (ladderFrameAdm stepA pendA fwdA bwdA).toTaskFrame) (z : ℤ),
      IsLadderPath stepA pendA g ∧ (∀ t : ℤ, σ.state t = (t + 0, g t)) ∧ N ≤ z ∧
      PlusFormula.atom pA ∈ tpOf (ladderModel stepA pendA fwdA bwdA labA) chiA σ z ∧
      chiA ∉ tpOf (ladderModel stepA pendA fwdA bwdA labA) chiA σ z ∧
      PlusFormula.atom pA ∉ tpOf (ladderModel stepA pendA fwdA bwdA labA) chiA σ (z + p) ∧
      chiA ∈ tpOf (ladderModel stepA pendA fwdA bwdA labA) chiA σ (z + p) ∧
      tpOf (ladderModel stepA pendA fwdA bwdA labA) chiA σ (z + p)
        ≠ tpOf (ladderModel stepA pendA fwdA bwdA labA) chiA σ z := by
  obtain ⟨g, σ, hg, hσ, hobj⟩ := exists_histA
  obtain ⟨n, hN, hpl⟩ := exists_pow_ge N p
  have hhi : objAt g ((2 ^ n : ℕ) : ℤ) = true := by rw [hobj]; exact wA_pow n
  have hlo : objAt g (((2 ^ n : ℕ) : ℤ) + p) = false := by
    rw [hobj]; exact wA_pow_add n p hp hpl
  refine ⟨g, σ, ((2 ^ n : ℕ) : ℤ), hg, hσ, hN,
    (atom_mem_tpOf_iff σ hσ _).mpr hhi, ?_, ?_, (chiA_mem_tpOf_iff σ hσ _).mpr hlo, ?_⟩
  · intro hc
    have := (chiA_mem_tpOf_iff σ hσ _).mp hc
    rw [hhi] at this
    exact absurd this (by simp)
  · intro hc
    have := (atom_mem_tpOf_iff σ hσ _).mp hc
    rw [hlo] at this
    exact absurd this (by simp)
  · intro hc
    have hin := (atom_mem_tpOf_iff σ hσ ((2 ^ n : ℕ) : ℤ)).mpr hhi
    have hout : PlusFormula.atom pA
        ∉ tpOf (ladderModel stepA pendA fwdA bwdA labA) chiA σ (((2 ^ n : ℕ) : ℤ) + p) := by
      intro hc'
      have hb := (atom_mem_tpOf_iff σ hσ _).mp hc'
      rw [hlo] at hb
      exact absurd hb (by simp)
    exact hout (hc ▸ hin)

/-- **The walk of the witness is globally periodic at NO NONZERO distance**, so the hypothesis of
`tpOf_periodic_of_objAt_periodic` is violated by this witness at every `l ≠ 0`, and the
conditional lemma is untouched by the refutation above. (At `l = 0` that hypothesis holds of every
walk and its conclusion is the identity, so `l = 0` is not a case this excludes and not a case
either statement says anything in.) -/
theorem wA_not_periodic (l : ℤ) (hl : l ≠ 0) : ¬ ∀ v : ℤ, wA (v + l) = wA v := by
  intro hper
  rcases lt_or_gt_of_ne hl with hneg | hpos
  · obtain ⟨n, -, hpl⟩ := exists_pow_ge 0 (-l)
    have h := hper (((2 ^ n : ℕ) : ℤ) + (-l))
    rw [show ((2 ^ n : ℕ) : ℤ) + -l + l = ((2 ^ n : ℕ) : ℤ) by ring] at h
    rw [wA_pow n, wA_pow_add n (-l) (by omega) hpl] at h
    exact absurd h (by simp)
  · obtain ⟨n, -, hpl⟩ := exists_pow_ge 0 l
    have h := hper ((2 ^ n : ℕ) : ℤ)
    rw [wA_pow n, wA_pow_add n l hpos hpl] at h
    exact absurd h (by simp)

#print axioms tpOf_periodicity_refuted_unconditional
#print axioms exists_separating_positions
#print axioms wA_not_periodic
#print axioms exists_histA
#print axioms exists_gA
#print axioms fwdA
#print axioms bwdA
#print axioms wA_pow
#print axioms wA_pow_add
#print axioms exists_pow_ge
#print axioms no_stab_in_closure_chiA

end Probe852P
