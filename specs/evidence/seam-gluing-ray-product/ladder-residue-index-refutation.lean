/-
PROVISIONAL HEADER -- written before any proof below, to be replaced by the final record once the
three decision gates have run.

## The two predictions

**(4) The threshold cannot be object-derived.**  `PlusTruthAt`'s `untl` clause is strict in both
bounds, so over integer time `bot U chi` is exactly "`chi` at the next instant" and `k` nested
nexts read `chi` exactly `k` instants later (`truth_nextPow`).  On the two-state fixture of the
fourteenth probe `Count true true` forces the first idle state of a region to distance exactly
`c + 1`, so the depth-`(T+1)` next-chain ending in the idle letter is true at `(q, T, n)` and false
at `(q, T + (P+1), n)`.  With `n := T + (P+1) + B` the six-coordinate index `ladderIndexRes T P B`
identifies that pair for EVERY `(T, P, B)`: both countdowns saturate the threshold, both residues
agree, `n` is shared, both gaps clip to `2B` (`depth_collision`, `cell_depth_ne`,
`object_only_parameters_refuted`).  Prediction: all four close; the threshold must be at least the
formula's `untl`-nesting depth, hence formula-derived.

**(5) The exhibited period is the period of the wrong object.**  `reachStep` iterates the FULL
`step` relation, so the exhibited `P` is the period of the reach-SET iteration on the whole graph;
a formula that forbids a letter restricts the object to a sub-object whose pending cycle structure
has a different period.  On the object whose pending part is a 3-cycle and a 2-cycle sharing one
state the reach sets are constant from threshold `4` (period `1`), while every `d`-free pending
walk from `a` back to `a` has length `0 mod 3`; every modulus coprime to `3` collides on a pair a
depth-2 formula separates (`reach5_eventually_constant`, `period_collision`, `cell5_ne`,
`reach_period_refuted`).  Prediction: all four close.

Compile: `lake env lean specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean`
-/
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe775

/-! ## The pinned definitional bodies, ported byte-for-byte from the fourteenth probe -/

/-- **The re-scoped candidate**: thresholds AND residues on both counters, beside the clipped
gap.  Ported byte-for-byte from `ladder-cell-index-obstructions.lean` so that what is refuted
below is the index as landed there. -/
def ladderIndexRes (T P B : ℕ) {Q : Type} {pend : Q → Bool} (x : LadderState Q pend) :
    Q × Fin (T + 1) × Fin (P + 1) × Fin (T + 1) × Fin (P + 1) × Fin (2 * B + 1) :=
  (x.1.1,
    ⟨min x.1.2.1 T, by omega⟩,
    ⟨x.1.2.1 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
    ⟨min x.1.2.2 T, by omega⟩,
    ⟨x.1.2.2 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
    ⟨min ((x.1.2.2 + B) - x.1.2.1) (2 * B), by omega⟩)

/-- One step of reachability under the object's step relation, ported byte-for-byte: the map
whose iteration `reachN_eventually_periodic` shows eventually periodic, and whose period is what
mechanism (5) measures against a letter-restricted sub-object. -/
def reachStep {Q : Type} [Fintype Q] [DecidableEq Q] (step : Q → Q → Bool)
    (S : Finset Q) : Finset Q :=
  S.biUnion (fun q => Finset.univ.filter (fun q' => step q q' = true))

/-! ## Generic facts about `Count`, and the forced run in any object -/

theorem count_tt (c n c' : ℕ) : Count true true c n c' ↔ c' + 1 = c := by simp [Count]
theorem count_tf (c n c' : ℕ) : Count true false c n c' ↔ c' = 0 ∧ c = 0 := by simp [Count]
theorem count_ff (c n c' : ℕ) : Count false false c n c' ↔ c' = 0 := by simp [Count]

section RunGen
variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
  {g : ℤ → LadderState Q pend} (hg : ∀ t, Rlad step pend t (g t).1 (g (t + 1)).1)
include hg

/-- **Forward determinism of the countdown, in ANY object**: from a pending state with countdown
`c`, every position `i ≤ c` is pending with countdown `c - i`.  Only `Count` is used; nothing
about `step`, `Drift`, or the next deadline enters. -/
theorem pending_run_gen (q : Q) (c n : ℕ) (hq : pend q = true) (h0 : (g 0).1 = (q, c, n)) :
    ∀ i : ℕ, i ≤ c → pend (g (i : ℤ)).1.1 = true ∧ (g (i : ℤ)).1.2.1 = c - i := by
  intro i
  induction i with
  | zero =>
    intro _
    rw [Nat.cast_zero, h0]
    exact ⟨hq, by simp⟩
  | succ i ih =>
    intro hi
    obtain ⟨hq1, hc⟩ := ih (by omega)
    rw [show ((i + 1 : ℕ) : ℤ) = (i : ℤ) + 1 by push_cast; ring]
    obtain ⟨-, -, -, hcount⟩ := hg (i : ℤ)
    rw [hq1] at hcount
    cases hy : pend (g ((i : ℤ) + 1)).1.1 with
    | false =>
      rw [hy, count_tf] at hcount
      omega
    | true =>
      rw [hy, count_tt] at hcount
      exact ⟨rfl, by omega⟩

/-- **The first idle state sits at distance exactly `c + 1`, in ANY object**: `Count true true`
cannot fire at countdown `0`. -/
theorem idle_at_gen (q : Q) (c n : ℕ) (hq : pend q = true) (h0 : (g 0).1 = (q, c, n)) :
    pend (g ((c : ℤ) + 1)).1.1 = false := by
  obtain ⟨hq1, hc⟩ := pending_run_gen hg q c n hq h0 c le_rfl
  obtain ⟨-, -, -, hcount⟩ := hg (c : ℤ)
  rw [hq1, hc, Nat.sub_self] at hcount
  cases hy : pend (g ((c : ℤ) + 1)).1.1 with
  | true =>
    rw [hy, count_tt] at hcount
    omega
  | false => rfl

end RunGen

/-! ## Nested nexts: `X chi := bot U chi` -/

/-- `k` nested nexts. -/
def nextPow : ℕ → PlusFormula → PlusFormula
  | 0, chi => chi
  | k + 1, chi => .untl .bot (nextPow k chi)

/-- **Over integer time `bot U chi` is `chi` at the next instant**, so `k` nested nexts read
`chi` exactly `k` instants later.  The `untl` clause is strict in both bounds: the witness `s'`
has no instant strictly between `s` and itself, so `s' = s + 1`. -/
theorem truth_nextPow {G : FrameOver intOrder} (N : TaskModel G.toTaskFrame)
    (σ : WorldHistory G.toTaskFrame) (k : ℕ) (chi : PlusFormula) (s : ℤ) :
    PlusTruthAt N σ s (nextPow k chi) ↔ PlusTruthAt N σ (s + k) chi := by
  induction k generalizing s with
  | zero => simp [nextPow]
  | succ k ih =>
    simp only [nextPow]
    constructor
    · rintro ⟨(s' : ℤ), hs, hψ, hguard⟩
      have hs' : (s : ℤ) < s' := hs
      have hs1 : s' = s + 1 := by
        by_contra hne
        exact hguard (s + 1) (show (s : ℤ) < s + 1 by omega) (show (s + 1 : ℤ) < s' by omega)
      subst hs1
      rw [ih] at hψ
      rw [show s + ((k + 1 : ℕ) : ℤ) = s + 1 + (k : ℤ) by push_cast; ring]
      exact hψ
    · intro h
      refine ⟨s + 1, show (s : ℤ) < s + 1 by omega, ?_, ?_⟩
      · rw [ih, show s + 1 + (k : ℤ) = s + ((k + 1 : ℕ) : ℤ) by push_cast; ring]
        exact h
      · intro (r : ℤ) h1 h2
        exfalso
        have h1' : (s : ℤ) < r := h1
        have h2' : r < s + 1 := h2
        omega

/-! ## Fixture A: the two-state alternating object of the fourteenth probe, ported verbatim -/

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

/-! ## The letters: pending, idle, the tag, and the fixture-B letter `d` -/

def pA : Atom := ⟨"p", none⟩
def rA : Atom := ⟨"r", none⟩
def aA : Atom := ⟨"a", none⟩
def dA : Atom := ⟨"d", none⟩

theorem pA_ne_rA : pA ≠ rA := by simp [pA, rA]
theorem aA_ne_pA : aA ≠ pA := by simp [aA, pA]
theorem aA_ne_rA : aA ≠ rA := by simp [aA, rA]
theorem dA_ne_pA : dA ≠ pA := by simp [dA, pA]
theorem dA_ne_rA : dA ≠ rA := by simp [dA, rA]
theorem dA_ne_aA : dA ≠ aA := by simp [dA, aA]

def labP : Qp → Atom → Bool := fun q at_ =>
  if at_ = pA then q.1 else if at_ = rA then !q.1 else if at_ = aA then q.2 else false

def M : TaskModel F.toTaskFrame := ladderModel stepP pendP fwdP bwdP labP

def p : PlusFormula := .atom pA
def r : PlusFormula := .atom rA

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

/-- The depth-`(T+1)` next-chain ending in the idle letter: true exactly when the first idle
state sits at distance `T + 1`. -/
def phiDepth (T : ℕ) : PlusFormula := nextPow (T + 1) r

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

/-- **`phiDepth T` reads whether position `T + 1` is idle**, along any history. -/
theorem truth_phiDepth (T : ℕ) :
    PlusTruthAt M σ 0 (phiDepth T) ↔ (g ((T : ℤ) + 1)).1.1.1 = false := by
  unfold phiDepth
  rw [truth_nextPow, show (0 : ℤ) + ((T + 1 : ℕ) : ℤ) = (T : ℤ) + 1 by push_cast; ring,
    truth_r hσ]

end Along

/-! ## The tag as a function of distance, and a reference history through every pending state -/

/-- The tag `i` pending steps after a state tagged `tg`. -/
def tagAt (tg : Bool) (i : ℤ) : Bool := if i % 2 = 0 then tg else !tg

theorem tagAt_succ (tg : Bool) (i : ℤ) : tagAt tg (i + 1) = !(tagAt tg i) := by
  unfold tagAt
  split_ifs with h1 h2 h2
  · omega
  · simp
  · rfl
  · omega

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

/-! ## Mechanism (4): the threshold against the formula's depth -/

/-- A pending admissible ladder state with countdown `c` and next-deadline `n`. -/
def st (tg : Bool) (c n : ℕ) : LadderState Qp pendP :=
  ⟨((true, tg), c, n), fun h => by cases h⟩

/-- The witnessing pair: countdowns `T` and `T + (P+1)`, one shared next deadline chosen so that
both gaps saturate the clip. -/
def xT (T P B : ℕ) : LadderState Qp pendP := st false T (T + (P + 1) + B)

def yT (T P B : ℕ) : LadderState Qp pendP := st false (T + (P + 1)) (T + (P + 1) + B)

/-- **The pair collides in the index for EVERY `(T, P, B)`**: both countdowns saturate the
threshold `T`, the residues agree modulo `P + 1` (`Nat.add_mod_right`), the next deadline is
shared, and both gaps clip to `2B`. -/
theorem depth_collision (T P B : ℕ) :
    ladderIndexRes T P B (xT T P B) = ladderIndexRes T P B (yT T P B) := by
  simp only [ladderIndexRes, xT, yT, st, Prod.mk.injEq, Fin.mk.injEq, true_and]
  and_intros <;> first | omega | exact (Nat.add_mod_right T (P + 1)).symm

/-- **Every type in the cell at a pending state settles `phiDepth T` by its own path**: it
contains the formula iff position `T + 1` of that path is idle. -/
theorem phiDepth_mem_iff_of_mem_cell (T c n : ℕ) (T' : Finset PlusFormula)
    (hT : T' ∈ cellAt M (phiDepth T) ((0 : ℤ), st false c n) 0) :
    ∃ g : ℤ → LadderState Qp pendP, (∀ t, Rlad stepP pendP t (g t).1 (g (t + 1)).1) ∧
      (g 0).1 = ((true, false), c, n) ∧
      (phiDepth T ∈ T' ↔ (g ((T : ℤ) + 1)).1.1.1 = false) := by
  obtain ⟨σ, hσz, rfl⟩ := hT
  obtain ⟨k, g, hg, hpath⟩ := hist_path σ
  have hst : ((0 : ℤ) + k, g 0) = ((0 : ℤ), st false c n) := by
    rw [← hσz]
    exact (congrFun hpath 0).symm
  have hg0 : (g 0).1 = ((true, false), c, n) :=
    congrArg (fun w : ℤ × LadderState Qp pendP => w.2.1) hst
  refine ⟨g, fun t => hg t, hg0, ?_⟩
  rw [mem_tpOf_iff]
  constructor
  · intro h
    exact (truth_phiDepth hpath T).mp h.2
  · intro h
    exact ⟨self_mem_plusSubformulaClosure _, (truth_phiDepth hpath T).mpr h⟩

/-- The cell at a pending state is nonempty: `gRef` is a history through it. -/
theorem exists_mem_cell_phiDepth (T c n : ℕ) :
    ∃ T', T' ∈ cellAt M (phiDepth T) ((0 : ℤ), st false c n) 0 := by
  obtain ⟨σ, hσ⟩ := hist_of_path 0 (gRef false c n) (gRef_isPath false c n)
  refine ⟨tpOf M (phiDepth T) σ 0, ⟨σ, ?_, rfl⟩⟩
  have hw : ((0 : ℤ), gRef false c n 0) = ((0 : ℤ), st false c n) :=
    Prod.ext rfl (Subtype.ext (gRef_zero false c n))
  rw [← hw]
  exact congrFun hσ 0

/-- **The cells differ**: through `xT` the first idle state is at distance exactly `T + 1`
(`idle_at_gen` at `c = T`), so the reference type contains `phiDepth T`; through `yT` position
`T + 1 ≤ T + (P+1)` is still pending (`pending_run_gen`), so no type in that cell does. -/
theorem cell_depth_ne (T P B : ℕ) :
    cellAt M (phiDepth T) ((0 : ℤ), xT T P B) 0 ≠ cellAt M (phiDepth T) ((0 : ℤ), yT T P B) 0 := by
  intro heq
  unfold xT yT at heq
  obtain ⟨T', hT'⟩ := exists_mem_cell_phiDepth T T (T + (P + 1) + B)
  obtain ⟨g1, hg1, hg10, hiff1⟩ := phiDepth_mem_iff_of_mem_cell T T (T + (P + 1) + B) T' hT'
  have hmem : phiDepth T ∈ T' := hiff1.mpr (idle_at_gen hg1 (true, false) T _ rfl hg10)
  rw [heq] at hT'
  obtain ⟨g2, hg2, hg20, hiff2⟩ :=
    phiDepth_mem_iff_of_mem_cell T (T + (P + 1)) (T + (P + 1) + B) T' hT'
  have hpend := (pending_run_gen hg2 (true, false) (T + (P + 1)) _ rfl hg20 (T + 1) (by omega)).1
  rw [show ((T + 1 : ℕ) : ℤ) = (T : ℤ) + 1 by push_cast; ring] at hpend
  have hidle := hiff2.mp hmem
  have hpend' : (g2 ((T : ℤ) + 1)).1.1.1 = true := hpend
  rw [hidle] at hpend'
  exact Bool.false_ne_true hpend'

/-- **THE REFUTATION OF EVERY FORMULA-INDEPENDENT PARAMETER TRIPLE.**  No `(T, P, B)` makes the
six-coordinate index factor the cells of the two-state fixture for every formula: the threshold
must be at least the formula's `untl`-nesting depth, and so cannot be derived from the object
alone. -/
theorem object_only_parameters_refuted :
    ¬ ∃ T P B : ℕ, ∀ φ : PlusFormula, ∀ x y : LadderState Qp pendP,
        ladderIndexRes T P B x = ladderIndexRes T P B y →
          cellAt M φ ((0 : ℤ), x) 0 = cellAt M φ ((0 : ℤ), y) 0 := by
  rintro ⟨T, P, B, h⟩
  exact cell_depth_ne T P B (h _ _ _ (depth_collision T P B))

end Probe775
