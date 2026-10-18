/-
THE UNCONSTRAINED-PARAMETER REFUTATION: the recorded factorization and fibre statements of the
ladder realization record, as written, are FALSE -- not open -- because they quantify over the
counter-quotient parameters `Tc`, `Tn`, `P`, `B` with NO constraint, and at the all-zero
parameters the quotient `CK Tc Tn P B` is a SUBSINGLETON.

## What was asked, and what this probe answers

The presentation decision chose the set-valued per-state datum: the realization theorem is the
FIBRE EQUATION over `Dmax`, the maximum certified subset of `Q × ClType φ × CK Tc Tn P B`, and
the factorization lemma for the counter quotient is its COROLLARY. The recorded statements are

  `cellAt_const_of_kappa_eq … (Tc Tn P B : ℕ) …`
      `(hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n'))`
      `: cellAt … (t, ⟨(q, c, n), h⟩) z = cellAt … (t, ⟨(q, c', n'), h'⟩) z`
  `ladderRealized … (Tc Tn P B : ℕ) … : cellAt … (t, ⟨(q, c, n), h⟩) z = {T | ∃ S, … ∈ Dmax …}`

Both universally quantify `Tc Tn P B` and carry NO hypothesis relating them to the object, the
formula, or each other. The parameter constraints the design names -- `P` a common multiple of
the certificate graph's cycle lengths on saturated classes, `Tc` at least the cascade bound and
the semantic periodicity threshold, `Tn ≥ Tc + 2ℓ₀ - 1`, `B ≥ max (2 d_back + 1) 2` -- appear
NOWHERE in the statements. An implementation would have to prove them for EVERY parameter
tuple, the all-zero tuple included.

## What is settled here

  1. `ck_zero_subsingleton`: `CK 0 0 0 0 = Fin 1 × Fin 1 × Fin 1 × Fin 1 × Fin 1` has exactly one
     inhabitant, so at those parameters `kappa 0 0 0 0` identifies EVERY counter pair, whatever
     `kappa` is. By `decide`, with the quotient's five-coordinate shape written out.
  2. `const_shape_refuted_of_separating_pair`: from ONE pair of admissible ladder states at the
     same object state whose cells differ, the `cellAt_const_of_kappa_eq` SHAPE is false -- for
     EVERY `kappa`, not merely for a particular one, because the refutation runs at the all-zero
     parameters where `hk` is free. The `kappa` argument is universally quantified INSIDE the
     refuted statement, exactly as `no_positionwise_lift` quantifies over every finite counter
     quotient.
  3. `realized_shape_refuted_of_separating_pair`: the same pair refutes the
     `ladderRealized` SHAPE, for every `kappa` and every `Dmax`, because the right-hand side
     depends on `(c, n)` only through `kappa Tc Tn P B (c, n)`, which is constant at the all-zero
     parameters while the left-hand side is not. The proof uses NO property of `Dmax`, so the
     refutation is not an artefact of choosing a degenerate candidate set.
  4. The separating pair EXISTS and is compiled here, not assumed: `cell_succ_ne` on the
     four-state tag object, ported verbatim from the wired probe
     `ladder-cell-index-obstructions.lean` (`Probe773`), which remains the oracle and keeps its
     own copy unchanged. The cells at `(q, c, n)` and `(q, c + 1, n)` differ for EVERY `c` and
     `n`, with the next deadline held FIXED.
  5. `const_shape_refuted` and `realized_shape_refuted`: (2) and (3) discharged by (4), so both
     are UNCONDITIONAL refutations on this object. `Qp` is a `Fintype` and `Nonempty`,
     `pendP`-admissibility holds at both states (both are pending), and the frame is
     `ladderFrameAdm` with `ladderFrameAdm_isRegular` -- the record's own frame, not a weakened
     one.

## Non-vacuity, witnessed on both sides

`exists_mem_cell` gives a type in the cell at EVERY pending state, so neither cell in the
separating pair is empty and the inequality is not an artefact of two empty sets.
`ck_zero_subsingleton` is an equality of inhabitants, not an emptiness claim: `CK 0 0 0 0` is
inhabited by `(0, 0, 0, 0, 0)`, exhibited in the proofs below. A gate probing one coordinate
certifies one coordinate: this probe certifies the PARAMETER QUANTIFICATION and nothing else.

## What this probe does NOT show

It does not refute the presentation. The set-valued datum, the fibre equation over the maximum
certified subset, and the factorization lemma as a corollary are all untouched: what is refuted
is the recorded statements' FREE quantification over the parameters. Nor does it say the
parameter constraints are unprovable; it says the statements do not carry them. It says nothing
about `ladderSound` (whose conclusion is an existential over `Dmax`, which a coarser quotient can
satisfy) and nothing about `ladderLift`. It is not a device-discrimination claim, it asserts no
bound, and every quantity it names is a count.

## The repair this refutation points at, stated and NOT taken here

Adding a parameter hypothesis -- `ParamsOk Tc Tn P B` carrying (K1)-(K4) -- to
`cellAt_const_of_kappa_eq` and `ladderRealized` would remove the all-zero tuple from their scope.
That is a CHANGE TO A RECORDED CHALLENGE STATEMENT and is therefore not made by the
implementation that found the defect: `plan-compliance.md`'s Statement Fidelity section routes a
genuinely wrong recorded statement to `[BLOCKED]` and an explicit raise, never to a quiet edit of
either side. This probe is that raise, compiled.

## Verification

`#print axioms` on the five headline theorems: `[propext, Classical.choice, Quot.sound]`, the
fixture's own profile. No `sorry`, no axiom, no `native_decide`, no placeholder body and no
vacuous definition anywhere in this file.

Compile: `lake env lean` on this file
(`specs/evidence/seam-gluing-ray-product/ladder-unconstrained-parameter-refutation.lean`).
-/
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Limits.NoFiniteWidth
import FormalSystem.Metalogic.Decidability.RaySummary.Certificate

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate

namespace Probe761R

/-! ## The four-state object: a pending pair alternating a tag, an idle pair carrying it -/

/-- Object states `(pending?, tag)`. -/
abbrev Qp : Type := Bool × Bool

def pendP : Qp → Bool := fun q => q.1

/-- While pending the tag flips on every pending step and is COPIED onto the idle state that
ends the region; an idle state only goes to an idle state with the same tag. -/
def stepP : Qp → Qp → Bool := fun x y =>
  if x.1 then (if y.1 then (y.2 != x.2) else (y.2 == x.2))
  else (!y.1 && (y.2 == x.2))

theorem rlad_iff (t : ℤ) (x y : Qp × ℕ × ℕ) :
    Rlad stepP pendP t x y ↔
      stepP x.1 y.1 = true ∧ (x.1.1 = false → x.2.1 = 0) ∧ Drift x.2.2 y.2.2 ∧
        Count x.1.1 y.1.1 x.2.1 x.2.2 y.2.1 := Iff.rfl

theorem count_tt (c n c' : ℕ) : Count true true c n c' ↔ c' + 1 = c := by simp [Count]
theorem count_tf (c n c' : ℕ) : Count true false c n c' ↔ c' = 0 ∧ c = 0 := by simp [Count]
theorem count_ff (c n c' : ℕ) : Count false false c n c' ↔ c' = 0 := by simp [Count]

theorem fwdP : ∀ t x, ∃ y, RladAdm stepP pendP t x y := by
  rintro t ⟨⟨⟨b, tg⟩, c, n⟩, hx⟩
  cases b with
  | false =>
    have hc : c = 0 := hx rfl
    subst hc
    exact ⟨⟨((false, tg), 0, n), fun _ => rfl⟩, by
      simp [RladAdm, rlad_iff, stepP, Drift, Count]⟩
  | true =>
    cases c with
    | zero =>
      exact ⟨⟨((false, tg), 0, n), fun _ => rfl⟩, by
        simp [RladAdm, rlad_iff, stepP, Drift, Count]⟩
    | succ c =>
      exact ⟨⟨((true, !tg), c, n), fun h => by cases h⟩, by
        simp [RladAdm, rlad_iff, stepP, Drift, Count]⟩

theorem bwdP : ∀ t x, ∃ y, RladAdm stepP pendP (t - 1) y x := by
  rintro t ⟨⟨⟨b, tg⟩, c, n⟩, hx⟩
  cases b with
  | false =>
    have hc : c = 0 := hx rfl
    subst hc
    exact ⟨⟨((false, tg), 0, n), fun _ => rfl⟩, by
      simp [RladAdm, rlad_iff, stepP, Drift, Count]⟩
  | true =>
    exact ⟨⟨((true, !tg), c + 1, n), fun h => by cases h⟩, by
      simp [RladAdm, rlad_iff, stepP, Drift, Count]⟩

def F : FrameOver intOrder := ladderFrameAdm stepP pendP fwdP bwdP

instance : F.IsRegular := ladderFrameAdm_isRegular stepP pendP fwdP bwdP

/-! ## The three letters: pending, idle, and the tag -/

def pA : Atom := ⟨"p", none⟩
def rA : Atom := ⟨"r", none⟩
def aA : Atom := ⟨"a", none⟩

theorem pA_ne_rA : pA ≠ rA := by simp [pA, rA]
theorem aA_ne_pA : aA ≠ pA := by simp [aA, pA]
theorem aA_ne_rA : aA ≠ rA := by simp [aA, rA]

def labP : Qp → Atom → Bool := fun q at_ =>
  if at_ = pA then q.1 else if at_ = rA then !q.1 else if at_ = aA then q.2 else false

def M : TaskModel F.toTaskFrame := ladderModel stepP pendP fwdP bwdP labP

def p : PlusFormula := .atom pA
def r : PlusFormula := .atom rA
def a : PlusFormula := .atom aA

/-- `p U (r AND a)`: "the region ends on a tagged idle state". -/
def phiP : PlusFormula := .untl p (r.and a)

/-! ## Histories of `F` are offset ladder paths -/

theorem hist_path (σ : WorldHistory F) :
    ∃ (k : ℤ) (g : ℤ → LadderState Qp pendP),
      IsSlicedStepPath (RladAdm stepP pendP) k g ∧ σ.path = fun t => (t + k, g t) :=
  (ofSlicedStepFinBranch_mem_HF_iff (RladAdm stepP pendP) (RladAdm_fwd _ _) (RladAdm_bwd _ _)
    fwdP bwdP σ.path).mp ⟨σ, rfl⟩

theorem hist_of_path (k : ℤ) (g : ℤ → LadderState Qp pendP)
    (hg : IsSlicedStepPath (RladAdm stepP pendP) k g) :
    ∃ σ : WorldHistory F, σ.path = fun t => (t + k, g t) :=
  (ofSlicedStepFinBranch_mem_HF_iff (RladAdm stepP pendP) (RladAdm_fwd _ _) (RladAdm_bwd _ _)
    fwdP bwdP _).mpr ⟨k, g, hg, rfl⟩

section Along
variable {σ : WorldHistory F} {k : ℤ} {g : ℤ → LadderState Qp pendP}
  (hσ : σ.path = fun t => (t + k, g t))
include hσ

theorem state_eq (s : ℤ) : σ.state s = (s + k, g s) := congrFun hσ s

theorem truth_p (s : ℤ) : PlusTruthAt M σ s p ↔ (g s).1.1.1 = true := by
  show M.valuation (σ.state s) pA ↔ _
  rw [state_eq hσ s]
  simp [M, ladderModel, labP]

theorem truth_r (s : ℤ) : PlusTruthAt M σ s r ↔ (g s).1.1.1 = false := by
  show M.valuation (σ.state s) rA ↔ _
  rw [state_eq hσ s]
  simp [M, ladderModel, labP, pA_ne_rA.symm]

theorem truth_a (s : ℤ) : PlusTruthAt M σ s a ↔ (g s).1.1.2 = true := by
  show M.valuation (σ.state s) aA ↔ _
  rw [state_eq hσ s]
  simp [M, ladderModel, labP, aA_ne_pA, aA_ne_rA]

end Along

/-! ## The tag as a function of distance -/

/-- The tag `i` pending steps after a state tagged `tg`. -/
def tagAt (tg : Bool) (i : ℤ) : Bool := if i % 2 = 0 then tg else !tg

theorem tagAt_succ (tg : Bool) (i : ℤ) : tagAt tg (i + 1) = !(tagAt tg i) := by
  unfold tagAt
  split_ifs with h1 h2 h2
  · omega
  · simp
  · rfl
  · omega

/-- **The decisive arithmetic**: the tag at distance `c` and at distance `c + 1` always differ,
so the parity of the countdown is never invisible. -/
theorem tagAt_ne_succ (tg : Bool) (i : ℤ) : tagAt tg i ≠ tagAt tg (i + 1) := by
  rw [tagAt_succ]
  cases tagAt tg i <;> simp

/-! ## The forced run: the region is deterministic in the object component -/

section Run
variable {g : ℤ → LadderState Qp pendP} (hg : ∀ t, Rlad stepP pendP t (g t).1 (g (t + 1)).1)
include hg

/-- **Forward determinism while pending**: the countdown runs down by exactly one per step and
the tag flips by exactly one per step, so at distance `i ≤ c` the state is pending with tag
`tagAt tg i` and countdown `c - i`.  No drift freedom touches either. -/
theorem pending_run (tg : Bool) (c n : ℕ) (h0 : (g 0).1 = ((true, tg), c, n)) :
    ∀ i : ℕ, i ≤ c →
      (g (i : ℤ)).1.1.1 = true ∧ (g (i : ℤ)).1.1.2 = tagAt tg (i : ℤ) ∧
        (g (i : ℤ)).1.2.1 = c - i := by
  intro i
  induction i with
  | zero =>
    intro _
    rw [Nat.cast_zero, h0]
    exact ⟨rfl, by simp [tagAt], by simp⟩
  | succ i ih =>
    intro hi
    obtain ⟨hq1, hq2, hc⟩ := ih (by omega)
    rw [show ((i + 1 : ℕ) : ℤ) = (i : ℤ) + 1 by push_cast; ring]
    obtain ⟨hs, -, -, hcount⟩ := (rlad_iff ((i : ℤ)) (g (i : ℤ)).1 (g ((i : ℤ) + 1)).1).mp
      (hg (i : ℤ))
    rw [hq1] at hcount
    cases hy : (g ((i : ℤ) + 1)).1.1.1 with
    | false =>
      rw [hy, count_tf] at hcount
      omega
    | true =>
      refine ⟨rfl, ?_, by rw [hy, count_tt] at hcount; omega⟩
      have hbne : (g ((i : ℤ) + 1)).1.1.2 ≠ (g (i : ℤ)).1.1.2 := by
        simpa [stepP, hq1, hy] using hs
      rw [hq2] at hbne
      rw [tagAt_succ]
      revert hbne
      cases (g ((i : ℤ) + 1)).1.1.2 <;> cases tagAt tg (i : ℤ) <;> simp

/-- **The region ends on an idle state carrying the tag of the last pending state**, at distance
exactly `c + 1`.  `Count true true` cannot fire at countdown `0`, so the successor is idle, and
`stepP` copies the tag. -/
theorem idle_at (tg : Bool) (c n : ℕ) (h0 : (g 0).1 = ((true, tg), c, n)) :
    (g ((c : ℤ) + 1)).1.1.1 = false ∧ (g ((c : ℤ) + 1)).1.1.2 = tagAt tg (c : ℤ) := by
  obtain ⟨hq1, hq2, hc⟩ := pending_run hg tg c n h0 c le_rfl
  obtain ⟨hs, -, -, hcount⟩ := (rlad_iff ((c : ℤ)) (g (c : ℤ)).1 (g ((c : ℤ) + 1)).1).mp
    (hg (c : ℤ))
  rw [hq1, hc, Nat.sub_self] at hcount
  cases hy : (g ((c : ℤ) + 1)).1.1.1 with
  | true =>
    rw [hy, count_tt] at hcount
    omega
  | false =>
    refine ⟨rfl, ?_⟩
    have hbeq : (g ((c : ℤ) + 1)).1.1.2 = (g (c : ℤ)).1.1.2 := by
      simpa [stepP, hq1, hy] using hs
    rw [hbeq, hq2]

end Run

/-! ## `phiP` reads exactly the parity of the countdown, at every pending state -/

section Truth
variable {σ : WorldHistory F} {k : ℤ} {g : ℤ → LadderState Qp pendP}
  (hσ : σ.path = fun t => (t + k, g t))
  (hg : ∀ t, Rlad stepP pendP t (g t).1 (g (t + 1)).1)
include hσ hg

/-- **The truth of `phiP` at a pending ladder state is a function of the state alone**, and that
function reads `c mod 2`: the until is forced to fire at the region end `c + 1`, where the tag is
`tagAt tg c`.  Neither the next-deadline `n` nor any drift choice appears. -/
theorem truth_phiP (tg : Bool) (c n : ℕ) (h0 : (g 0).1 = ((true, tg), c, n)) :
    PlusTruthAt M σ 0 phiP ↔ tagAt tg (c : ℤ) = true := by
  constructor
  · rintro ⟨(s : ℤ), hs, hχ, hguard⟩
    have hs' : (0 : ℤ) < s := hs
    rw [PlusTruth.and_iff, truth_r hσ, truth_a hσ] at hχ
    obtain ⟨hr, ha⟩ := hχ
    rcases lt_trichotomy s ((c : ℤ) + 1) with hlt | heq | hgt
    · have hlt' : s < (c : ℤ) + 1 := hlt
      have hsn : ((s.toNat : ℕ) : ℤ) = s := Int.toNat_of_nonneg (by omega)
      have hle : s.toNat ≤ c := by omega
      obtain ⟨hq1, -, -⟩ := pending_run hg tg c n h0 s.toNat hle
      rw [← hsn] at hr
      rw [hr] at hq1
      exact absurd hq1 (by simp)
    · subst heq
      obtain ⟨-, htg⟩ := idle_at hg tg c n h0
      rw [htg] at ha
      exact ha
    · have hgt' : (c : ℤ) + 1 < s := hgt
      have hp := hguard ((c : ℤ) + 1) (show (0 : ℤ) < (c : ℤ) + 1 by omega) hgt
      rw [truth_p hσ] at hp
      obtain ⟨hidle, -⟩ := idle_at hg tg c n h0
      rw [hidle] at hp
      exact absurd hp (by simp)
  · intro htag
    refine ⟨(c : ℤ) + 1, show (0 : ℤ) < (c : ℤ) + 1 by omega, ?_, ?_⟩
    · rw [PlusTruth.and_iff, truth_r hσ, truth_a hσ]
      obtain ⟨hidle, htg⟩ := idle_at hg tg c n h0
      exact ⟨hidle, by rw [htg]; exact htag⟩
    · intro (s' : ℤ) h1 h2
      have h1' : (0 : ℤ) < s' := h1
      have h2' : s' < (c : ℤ) + 1 := h2
      rw [truth_p hσ]
      have hsn : ((s'.toNat : ℕ) : ℤ) = s' := Int.toNat_of_nonneg (by omega)
      have hle : s'.toNat ≤ c := by omega
      obtain ⟨hq1, -, -⟩ := pending_run hg tg c n h0 s'.toNat hle
      rw [← hsn]
      exact hq1

end Truth

/-! ## A reference history through every pending ladder state -/

/-- The run that keeps `n` fixed (`Drift n n` always holds), counts the region down to `0`, and
is idle ever after; extended backwards by lengthening the countdown and flipping the tag. -/
def gRefRaw (tg : Bool) (c n : ℕ) (t : ℤ) : Qp × ℕ × ℕ :=
  if t ≤ (c : ℤ) then ((true, tagAt tg t), ((c : ℤ) - t).toNat, n)
  else ((false, tagAt tg (c : ℤ)), 0, n)

theorem gRefRaw_adm (tg : Bool) (c n : ℕ) (t : ℤ) :
    (gRefRaw tg c n t).2.1 ∈ Adm pendP (gRefRaw tg c n t).1 := by
  show (gRefRaw tg c n t).1.1 = false → (gRefRaw tg c n t).2.1 = 0
  unfold gRefRaw
  split_ifs <;> simp

def gRef (tg : Bool) (c n : ℕ) (t : ℤ) : LadderState Qp pendP :=
  ⟨gRefRaw tg c n t, gRefRaw_adm tg c n t⟩

theorem gRefRaw_step (tg : Bool) (c n : ℕ) (t : ℤ) :
    Rlad stepP pendP 0 (gRefRaw tg c n t) (gRefRaw tg c n (t + 1)) := by
  rw [rlad_iff]
  have hts : tagAt tg (t + 1) = !(tagAt tg t) := tagAt_succ tg t
  unfold gRefRaw
  rcases lt_trichotomy t (c : ℤ) with hlt | heq | hgt
  · have h1 : t ≤ (c : ℤ) := le_of_lt hlt
    have h2 : t + 1 ≤ (c : ℤ) := by omega
    rw [if_pos h1, if_pos h2, hts]
    refine ⟨?_, by simp, Or.inl rfl, ?_⟩
    · show stepP (true, tagAt tg t) (true, !(tagAt tg t)) = true
      cases tagAt tg t <;> simp [stepP]
    · show Count true true (((c : ℤ) - t).toNat) n (((c : ℤ) - (t + 1)).toNat)
      rw [count_tt]
      omega
  · have h1 : t ≤ (c : ℤ) := le_of_eq heq
    have h2 : ¬ (t + 1 ≤ (c : ℤ)) := by omega
    rw [if_pos h1, if_neg h2, heq]
    refine ⟨?_, by simp, Or.inl rfl, ?_⟩
    · show stepP (true, tagAt tg (c : ℤ)) (false, tagAt tg (c : ℤ)) = true
      cases tagAt tg (c : ℤ) <;> simp [stepP]
    · show Count true false (((c : ℤ) - (c : ℤ)).toNat) n 0
      rw [count_tf]
      omega
  · have h1 : ¬ (t ≤ (c : ℤ)) := by omega
    have h2 : ¬ (t + 1 ≤ (c : ℤ)) := by omega
    rw [if_neg h1, if_neg h2]
    refine ⟨?_, by simp, Or.inl rfl, ?_⟩
    · show stepP (false, tagAt tg (c : ℤ)) (false, tagAt tg (c : ℤ)) = true
      cases tagAt tg (c : ℤ) <;> simp [stepP]
    · show Count false false 0 n 0
      rw [count_ff]

theorem gRef_isPath (tg : Bool) (c n : ℕ) :
    IsSlicedStepPath (RladAdm stepP pendP) 0 (gRef tg c n) := by
  intro t
  show Rlad stepP pendP (t + 0) (gRefRaw tg c n t) (gRefRaw tg c n (t + 1))
  have h : Rlad stepP pendP (t + 0) (gRefRaw tg c n t) (gRefRaw tg c n (t + 1)) ↔
      Rlad stepP pendP 0 (gRefRaw tg c n t) (gRefRaw tg c n (t + 1)) := Iff.rfl
  rw [h]
  exact gRefRaw_step tg c n t

theorem gRef_zero (tg : Bool) (c n : ℕ) : (gRef tg c n 0).1 = ((true, tg), c, n) := by
  show gRefRaw tg c n 0 = ((true, tg), c, n)
  unfold gRefRaw
  rw [if_pos (by positivity : (0 : ℤ) ≤ (c : ℤ))]
  simp [tagAt]

/-! ## The cells at a pending state -/

/-- A pending admissible ladder state with countdown `c` and next-deadline `n`. -/
def st (tg : Bool) (c n : ℕ) : LadderState Qp pendP :=
  ⟨((true, tg), c, n), fun h => by cases h⟩

def wP (tg : Bool) (c n : ℕ) : F.WorldState := ((0 : ℤ), st tg c n)


def wRef (tg : Bool) (c n : ℕ) : F.WorldState := ((0 : ℤ), gRef tg c n 0)

theorem wRef_eq (tg : Bool) (c n : ℕ) : wRef tg c n = wP tg c n :=
  Prod.ext rfl (Subtype.ext (gRef_zero tg c n))

/-- **Every type realized at a pending state settles `phiP` the same way**, by the countdown's
tag: the cell does not merely contain a type with `phiP`, it is uniform in `phiP`. -/
theorem phiP_mem_iff_of_mem_cell (tg : Bool) (c n : ℕ) (T : Finset PlusFormula)
    (hT : T ∈ cellAt M phiP (wP tg c n) 0) : (phiP ∈ T ↔ tagAt tg (c : ℤ) = true) := by
  obtain ⟨σ, hσz, rfl⟩ := hT
  obtain ⟨k, g, hg, hpath⟩ := hist_path σ
  have hst : ((0 : ℤ) + k, g 0) = wP tg c n := by
    rw [← hσz]
    exact (congrFun hpath 0).symm
  have hg0 : (g 0).1 = ((true, tg), c, n) :=
    congrArg (fun w : ℤ × LadderState Qp pendP => w.2.1) hst
  rw [mem_tpOf_iff]
  constructor
  · intro h
    exact (truth_phiP hpath (fun t => hg t) tg c n hg0).mp h.2
  · intro h
    exact ⟨self_mem_plusSubformulaClosure phiP,
      (truth_phiP hpath (fun t => hg t) tg c n hg0).mpr h⟩

/-- The cell at a pending state is nonempty: `gRef` is a history through it. -/
theorem exists_mem_cell (tg : Bool) (c n : ℕ) : ∃ T, T ∈ cellAt M phiP (wP tg c n) 0 := by
  obtain ⟨σ, hσ⟩ := hist_of_path 0 (gRef tg c n) (gRef_isPath tg c n)
  refine ⟨tpOf M phiP σ 0, ⟨σ, ?_, rfl⟩⟩
  rw [← wRef_eq]
  exact congrFun hσ 0

/-- **THE OBSTRUCTION, at every counter value**: the cells at `(q, c, n)` and `(q, c + 1, n)`
differ for EVERY `c` and `n`, with the next-deadline `n` held FIXED (so the gap differs by one
but neither state is distinguished by it in any clipped range).  The separating datum is the
parity of `c`, read at the region end -- a distance `c + 1` away, which no bound on `c` can
reach.  Consequently no index whose countdown coordinate has finite range can be sound: it must
identify two countdowns of opposite parity at equal `n`. -/
theorem cell_succ_ne (tg : Bool) (c n : ℕ) :
    cellAt M phiP (wP tg c n) 0 ≠ cellAt M phiP (wP tg (c + 1) n) 0 := by
  intro heq
  obtain ⟨T, hT⟩ := exists_mem_cell tg c n
  have h1 := phiP_mem_iff_of_mem_cell tg c n T hT
  rw [heq] at hT
  have h2 := phiP_mem_iff_of_mem_cell tg (c + 1) n T hT
  have hiff : (tagAt tg (c : ℤ) = true) ↔ (tagAt tg ((c + 1 : ℕ) : ℤ) = true) := h1.symm.trans h2
  rw [show ((c + 1 : ℕ) : ℤ) = (c : ℤ) + 1 by push_cast; ring] at hiff
  have hne := tagAt_ne_succ tg (c : ℤ)
  revert hiff hne
  cases tagAt tg (c : ℤ) <;> cases tagAt tg ((c : ℤ) + 1) <;> simp

/-! ## The counter quotient of the record, and the subsingleton at the all-zero parameters -/

/-- The counter quotient's carrier, with its five-coordinate shape written out exactly as the
record states it: a countdown threshold, a countdown residue, a next-deadline threshold, a
next-deadline residue, and the clipped gap. -/
abbrev CK (Tc Tn P B : ℕ) : Type :=
  Fin (Tc + 1) × Fin (P + 1) × Fin (Tn + 1) × Fin (P + 1) × Fin (2 * B + 1)

/-- `CK 0 0 0 0` is INHABITED: all five coordinates are `Fin 1`. Exhibited so that the
subsingleton claim below is read as "exactly one inhabitant", never as an emptiness claim. -/
def ckZero : CK 0 0 0 0 := (0, 0, 0, 0, 0)

/-- **(1) At the all-zero parameters the counter quotient is a SUBSINGLETON.** Every `kappa`
whose codomain is `CK Tc Tn P B` therefore identifies every counter pair at `Tc = Tn = P = B = 0`,
whatever `kappa` is and whatever its parameters are meant to mean. -/
theorem ck_zero_subsingleton : ∀ u v : CK 0 0 0 0, u = v := by decide

/-! ## The two refuted shapes, for EVERY `kappa` -/

section Shapes

variable {Q : Type} [Fintype Q] [Nonempty Q]
  (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
  (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
  (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
  (phi : PlusFormula)

/-- The closure component read as its underlying `Finset`, exactly as the record's `typeOfCl`
does. -/
abbrev typeOfCl {phi : PlusFormula} : ClType phi → Finset PlusFormula := Subtype.val

/-- **(2) The factorization SHAPE is refuted by one separating pair.** The statement refuted is
the recorded `cellAt_const_of_kappa_eq` with its parameters free. `kappa` is universally
quantified OUTSIDE the refuted statement, which is both faithful (the record's `kappa` is one
fixed definition) and the strongest reading: no choice of `kappa` and no reading of the
parameters evades the refutation, because the contradiction is drawn at the all-zero parameters
where `hk` is free whatever `kappa` is. -/
theorem const_shape_refuted_of_separating_pair
    (kappa : ∀ Tc Tn P B : ℕ, ℕ × ℕ → CK Tc Tn P B)
    (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q) (t z : ℤ)
    (hsep : cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c, n), h⟩) z
      ≠ cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c', n'), h'⟩) z) :
    ¬ ∀ (Tc Tn P B : ℕ) (q : Q) (c n c' n' : ℕ)
        (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q),
        kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
        ∀ t z : ℤ,
          cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c, n), h⟩) z
            = cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c', n'), h'⟩) z := by
  intro H
  exact hsep (H 0 0 0 0 q c n c' n' h h' (ck_zero_subsingleton _ _) t z)

/-- **(3) The FIBRE-EQUATION shape is refuted by the same pair.** `kappa` and `Dmax` are both
universally quantified OUTSIDE, so the refutation holds for every counter map and every
candidate maximum certified subset, and the proof uses NO property of `Dmax`: the two fibres
coincide because the right-hand side reads `(c, n)` only through `kappa Tc Tn P B (c, n)`, which
is constant at the all-zero parameters, while the left-hand side is not. -/
theorem realized_shape_refuted_of_separating_pair
    (kappa : ∀ Tc Tn P B : ℕ, ℕ × ℕ → CK Tc Tn P B)
    (Dmax : ∀ Tc Tn P B : ℕ, Set (Q × ClType phi × CK Tc Tn P B))
    (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q) (t z : ℤ)
    (hsep : cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c, n), h⟩) z
      ≠ cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c', n'), h'⟩) z) :
    ¬ ∀ (Tc Tn P B : ℕ) (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (t z : ℤ),
        cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c, n), h⟩) z
          = {T | ∃ S : ClType phi, typeOfCl S = T ∧
              (q, S, kappa Tc Tn P B (c, n)) ∈ Dmax Tc Tn P B} := by
  intro H
  refine hsep ?_
  rw [H 0 0 0 0 q c n h t z, H 0 0 0 0 q c' n' h' t z,
    ck_zero_subsingleton (kappa 0 0 0 0 (c, n)) (kappa 0 0 0 0 (c', n'))]

end Shapes

/-! ## The separating pair, compiled, and the two refutations unconditional -/

/-- **(4)/(5) The factorization shape is refuted on the tag object, unconditionally**, for every
`kappa`. The pair is `cell_succ_ne`'s: countdowns `c` and `c + 1` at the SAME object state and
the SAME next deadline, whose cells differ because `phiP` reads the parity of the countdown at
the region end, a distance `c + 1` away. Both cells are nonempty (`exists_mem_cell`). -/
theorem const_shape_refuted (kappa : ∀ Tc Tn P B : ℕ, ℕ × ℕ → CK Tc Tn P B)
    (tg : Bool) (c n : ℕ) :
    ¬ ∀ (Tc Tn P B : ℕ) (q : Qp) (c n c' n' : ℕ)
        (h : c ∈ Adm pendP q) (h' : c' ∈ Adm pendP q),
        kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
        ∀ t z : ℤ,
          cellAt M phiP (t, ⟨(q, c, n), h⟩) z = cellAt M phiP (t, ⟨(q, c', n'), h'⟩) z :=
  const_shape_refuted_of_separating_pair stepP pendP labP fwdP bwdP phiP kappa
    (true, tg) c n (c + 1) n (fun h => by cases h) (fun h => by cases h) 0 0
    (cell_succ_ne tg c n)

/-- **(4)/(5) The fibre-equation shape is refuted on the same object, unconditionally**, for
every `kappa` and every candidate maximum certified subset. -/
theorem realized_shape_refuted (kappa : ∀ Tc Tn P B : ℕ, ℕ × ℕ → CK Tc Tn P B)
    (Dmax : ∀ Tc Tn P B : ℕ, Set (Qp × ClType phiP × CK Tc Tn P B))
    (tg : Bool) (c n : ℕ) :
    ¬ ∀ (Tc Tn P B : ℕ) (q : Qp) (c n : ℕ) (h : c ∈ Adm pendP q) (t z : ℤ),
        cellAt M phiP (t, ⟨(q, c, n), h⟩) z
          = {T | ∃ S : ClType phiP, typeOfCl S = T ∧
              (q, S, kappa Tc Tn P B (c, n)) ∈ Dmax Tc Tn P B} :=
  realized_shape_refuted_of_separating_pair stepP pendP labP fwdP bwdP phiP kappa Dmax
    (true, tg) c n (c + 1) n (fun h => by cases h) (fun h => by cases h) 0 0
    (cell_succ_ne tg c n)

/-- Non-vacuity on both sides of the separating pair: each cell contains a type. -/
theorem separating_pair_nonvacuous (tg : Bool) (c n : ℕ) :
    (∃ T, T ∈ cellAt M phiP (wP tg c n) 0) ∧ (∃ T, T ∈ cellAt M phiP (wP tg (c + 1) n) 0) :=
  ⟨exists_mem_cell tg c n, exists_mem_cell tg (c + 1) n⟩

end Probe761R

#print axioms Probe761R.ck_zero_subsingleton
#print axioms Probe761R.const_shape_refuted_of_separating_pair
#print axioms Probe761R.realized_shape_refuted_of_separating_pair
#print axioms Probe761R.const_shape_refuted
#print axioms Probe761R.realized_shape_refuted
#print axioms Probe761R.separating_pair_nonvacuous
