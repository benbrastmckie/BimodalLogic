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

/-! ## Fixture B: two pending cycles of coprime lengths sharing a state -/

/-- Object states `(pending?, index)`; pending indices `0 = a`, `1 = b`, `2 = c`, `3 = d`. -/
abbrev Q5 : Type := Bool × Fin 4

def pend5 : Q5 → Bool := fun q => q.1

/-- Pending edges `a → b → c → a` and `a → d → a` (a 3-cycle and a 2-cycle sharing `a`); every
pending `(true, i)` steps to its idle copy `(false, i)`; idle states self-loop. -/
def step5 : Q5 → Q5 → Bool := fun x y =>
  if x.1 then
    (if y.1 then
      ((x.2 == 0 && (y.2 == 1 || y.2 == 3)) || (x.2 == 1 && y.2 == 2) ||
        (x.2 == 2 && y.2 == 0) || (x.2 == 3 && y.2 == 0))
     else (y.2 == x.2))
  else (!y.1 && (y.2 == x.2))

theorem rlad5_iff (t : ℤ) (x y : Q5 × ℕ × ℕ) :
    Rlad step5 pend5 t x y ↔
      step5 x.1 y.1 = true ∧ (x.1.1 = false → x.2.1 = 0) ∧ Drift x.2.2 y.2.2 ∧
        Count x.1.1 y.1.1 x.2.1 x.2.2 y.2.1 := Iff.rfl

/-- A pending successor index: `a → b`, `b → c`, `c → a`, `d → a`. -/
def nxt : Fin 4 → Fin 4 := fun i => if i = 0 then 1 else if i = 1 then 2 else 0

/-- A pending predecessor index: `a` from `c`, `b` from `a`, `c` from `b`, `d` from `a`. -/
def prv : Fin 4 → Fin 4 := fun i =>
  if i = 0 then 2 else if i = 1 then 0 else if i = 2 then 1 else 0

theorem step5_nxt : ∀ i : Fin 4, step5 (true, i) (true, nxt i) = true := by decide

theorem step5_prv : ∀ i : Fin 4, step5 (true, prv i) (true, i) = true := by decide

theorem fwd5 : ∀ t x, ∃ y, RladAdm step5 pend5 t x y := by
  rintro t ⟨⟨⟨b, i⟩, c, n⟩, hx⟩
  cases b with
  | false =>
    have hc : c = 0 := hx rfl
    subst hc
    exact ⟨⟨((false, i), 0, n), fun _ => rfl⟩, by
      simp [RladAdm, rlad5_iff, step5, Drift, Count]⟩
  | true =>
    cases c with
    | zero =>
      exact ⟨⟨((false, i), 0, n), fun _ => rfl⟩, by
        simp [RladAdm, rlad5_iff, step5, Drift, Count]⟩
    | succ c =>
      exact ⟨⟨((true, nxt i), c, n), fun h => by cases h⟩, by
        simp [RladAdm, rlad5_iff, Drift, Count, step5_nxt]⟩

theorem bwd5 : ∀ t x, ∃ y, RladAdm step5 pend5 (t - 1) y x := by
  rintro t ⟨⟨⟨b, i⟩, c, n⟩, hx⟩
  cases b with
  | false =>
    have hc : c = 0 := hx rfl
    subst hc
    exact ⟨⟨((false, i), 0, n), fun _ => rfl⟩, by
      simp [RladAdm, rlad5_iff, step5, Drift, Count]⟩
  | true =>
    exact ⟨⟨((true, prv i), c + 1, n), fun h => by cases h⟩, by
      simp [RladAdm, rlad5_iff, Drift, Count, step5_prv]⟩

def F5 : FrameOver intOrder := ladderFrameAdm step5 pend5 fwd5 bwd5

instance : F5.IsRegular := ladderFrameAdm_isRegular step5 pend5 fwd5 bwd5

/-- `p` pending, `r` idle, `a` index `0`, `d` PENDING index `3` (so `d` is false at every idle
state). -/
def lab5 : Q5 → Atom → Bool := fun q at_ =>
  if at_ = pA then q.1 else if at_ = rA then !q.1
  else if at_ = aA then (q.2 == 0) else if at_ = dA then (q.1 && q.2 == 3) else false

def M5 : TaskModel F5.toTaskFrame := ladderModel step5 pend5 fwd5 bwd5 lab5

def la : PlusFormula := .atom aA
def ld : PlusFormula := .atom dA

/-- `p U (r AND l_a)`: the region ends on the idle copy of `a`. -/
def endA : PlusFormula := .untl p (r.and la)

/-- `top U l_d`, with `top := bot -> bot`: some strictly later state is pending `d`. -/
def evD : PlusFormula := .untl (.imp .bot .bot) ld

/-- The probe formula; both observables are in its closure. -/
def phi5 : PlusFormula := .imp endA evD

def a5 : Q5 := (true, 0)

/-- A pending admissible ladder state of fixture B. -/
def st5 (i : Fin 4) (c n : ℕ) : LadderState Q5 pend5 :=
  ⟨((true, i), c, n), fun h => by cases h⟩

/-- A countdown divisible by `3` and by `P + 1`, at or above every threshold `T`. -/
def c5 (T P : ℕ) : ℕ := 3 * (P + 1) * (T + 1)

def x5 (T P B : ℕ) : LadderState Q5 pend5 :=
  st5 0 (c5 T P) (c5 T P + (P + 1) + B)

def y5 (T P B : ℕ) : LadderState Q5 pend5 :=
  st5 0 (c5 T P + (P + 1)) (c5 T P + (P + 1) + B)

/-! ## The exhibited threshold and period of fixture B's full-graph reach sets -/

/-- From `a`, four steps reach every state. -/
theorem reach5_four : (reachStep step5)^[4] {a5} = Finset.univ := by decide

/-- Every state has a predecessor, so the full set is a fixed point of `reachStep`. -/
theorem reachStep5_univ : reachStep step5 Finset.univ = Finset.univ := by decide

/-- **Period `1` is an exhibited period of this object, from threshold `4`** — exactly the
shape `reachN_eventually_periodic` returns, with the minimal period.  Under either reading of the
instantiation convention (`P := period` or `P := period - 1`) the index's modulus `P + 1` is `2`
or `1`, both coprime to `3`. -/
theorem reach5_eventually_constant :
    ∀ k : ℕ, 4 ≤ k → (reachStep step5)^[k + 1] {a5} = (reachStep step5)^[k] {a5} := by
  intro k hk
  obtain ⟨m, rfl⟩ : ∃ m, k = 4 + m := ⟨k - 4, by omega⟩
  have huniv : ∀ m, (reachStep step5)^[4 + m] {a5} = Finset.univ := by
    intro m
    induction m with
    | zero => exact reach5_four
    | succ m ih =>
      rw [show 4 + (m + 1) = (4 + m) + 1 by omega, Function.iterate_succ_apply', ih,
        reachStep5_univ]
  rw [show 4 + m + 1 = 4 + (m + 1) by omega, huniv, huniv]

/-! ## The 3-cycle as a function of distance -/

/-- The index `i` pending steps after `a` along the 3-cycle. -/
def cyc (i : ℤ) : Fin 4 := ⟨(i % 3).toNat, by omega⟩

theorem cyc_cases (i : ℤ) :
    (cyc i = 0 ∧ cyc (i + 1) = 1) ∨ (cyc i = 1 ∧ cyc (i + 1) = 2) ∨
      (cyc i = 2 ∧ cyc (i + 1) = 0) := by
  have h3 : i % 3 = 0 ∨ i % 3 = 1 ∨ i % 3 = 2 := by omega
  rcases h3 with h | h | h
  · exact Or.inl ⟨Fin.ext (by change (i % 3).toNat = 0; omega),
      Fin.ext (by change ((i + 1) % 3).toNat = 1; omega)⟩
  · exact Or.inr (Or.inl ⟨Fin.ext (by change (i % 3).toNat = 1; omega),
      Fin.ext (by change ((i + 1) % 3).toNat = 2; omega)⟩)
  · exact Or.inr (Or.inr ⟨Fin.ext (by change (i % 3).toNat = 2; omega),
      Fin.ext (by change ((i + 1) % 3).toNat = 0; omega)⟩)

/-- The 3-cycle never visits `d`. -/
theorem cyc_ne_three (i : ℤ) : cyc i ≠ 3 := fun h => by
  have h' : (i % 3).toNat = 3 := congrArg Fin.val h
  omega

theorem step5_cyc_succ (i : ℤ) : step5 (true, cyc i) (true, cyc (i + 1)) = true := by
  rcases cyc_cases i with ⟨h0, h1⟩ | ⟨h0, h1⟩ | ⟨h0, h1⟩ <;> rw [h0, h1] <;> decide

/-- **The `d`-free pending successor of a 3-cycle state is the next 3-cycle state.** -/
theorem step5_cyc (i : ℤ) (j : Fin 4) (hs : step5 (true, cyc i) (true, j) = true)
    (hj : j ≠ 3) : j = cyc (i + 1) := by
  rcases cyc_cases i with ⟨h0, h1⟩ | ⟨h0, h1⟩ | ⟨h0, h1⟩ <;>
    (rw [h0] at hs; rw [h1]; revert j; decide)

theorem cyc_zero (c : ℕ) (h : 3 ∣ c) : cyc c = 0 :=
  Fin.ext (by change ((c : ℤ) % 3).toNat = 0; omega)

theorem dvd_of_cyc_zero (c : ℕ) (h : cyc c = 0) : 3 ∣ c := by
  have h' : ((c : ℤ) % 3).toNat = 0 := congrArg Fin.val h
  omega

/-! ## Histories of `F5`, and the letters along them -/

theorem hist_path5 (σ : WorldHistory F5) :
    ∃ (k : ℤ) (g : ℤ → LadderState Q5 pend5),
      IsSlicedStepPath (RladAdm step5 pend5) k g ∧ σ.path = fun t => (t + k, g t) :=
  (ofSlicedStepFinBranch_mem_HF_iff (RladAdm step5 pend5) (RladAdm_fwd _ _) (RladAdm_bwd _ _)
    fwd5 bwd5 σ.path).mp ⟨σ, rfl⟩

theorem hist_of_path5 (k : ℤ) (g : ℤ → LadderState Q5 pend5)
    (hg : IsSlicedStepPath (RladAdm step5 pend5) k g) :
    ∃ σ : WorldHistory F5, σ.path = fun t => (t + k, g t) :=
  (ofSlicedStepFinBranch_mem_HF_iff (RladAdm step5 pend5) (RladAdm_fwd _ _) (RladAdm_bwd _ _)
    fwd5 bwd5 _).mpr ⟨k, g, hg, rfl⟩

section Along5
variable {σ : WorldHistory F5} {k : ℤ} {g : ℤ → LadderState Q5 pend5}
  (hσ : σ.path = fun t => (t + k, g t))
include hσ

theorem state_eq5 (s : ℤ) : σ.state s = (s + k, g s) := congrFun hσ s

theorem truth_p5 (s : ℤ) : PlusTruthAt M5 σ s p ↔ (g s).1.1.1 = true := by
  change M5.valuation (σ.state s) pA ↔ _
  rw [state_eq5 hσ s]
  simp [M5, ladderModel, lab5]

theorem truth_r5 (s : ℤ) : PlusTruthAt M5 σ s r ↔ (g s).1.1.1 = false := by
  change M5.valuation (σ.state s) rA ↔ _
  rw [state_eq5 hσ s]
  simp [M5, ladderModel, lab5, pA_ne_rA.symm]

theorem truth_la5 (s : ℤ) : PlusTruthAt M5 σ s la ↔ (g s).1.1.2 = 0 := by
  change M5.valuation (σ.state s) aA ↔ _
  rw [state_eq5 hσ s]
  simp [M5, ladderModel, lab5, aA_ne_pA, aA_ne_rA]

theorem truth_ld5 (s : ℤ) :
    PlusTruthAt M5 σ s ld ↔ (g s).1.1.1 = true ∧ (g s).1.1.2 = 3 := by
  change M5.valuation (σ.state s) dA ↔ _
  rw [state_eq5 hσ s]
  simp [M5, ladderModel, lab5, dA_ne_pA, dA_ne_rA, dA_ne_aA]

/-- A pending-`d` position strictly after `0` makes `top U l_d` true at `0`. -/
theorem evD_of_ld (j : ℕ) (hj : 1 ≤ j) (hld : (g (j : ℤ)).1.1 = (true, 3)) :
    PlusTruthAt M5 σ 0 evD := by
  refine ⟨(j : ℤ), show (0 : ℤ) < (j : ℤ) by omega, ?_, ?_⟩
  · rw [truth_ld5 hσ]
    exact ⟨congrArg Prod.fst hld, congrArg Prod.snd hld⟩
  · intro _ _ _ h
    exact h

end Along5

/-! ## The forced run in fixture B: the index follows the 3-cycle while `d` is avoided -/

section Run5
variable {g : ℤ → LadderState Q5 pend5}
  (hg : ∀ t, Rlad step5 pend5 t (g t).1 (g (t + 1)).1)
include hg

/-- **Along a `d`-free pending run from `a`, position `i` is `(true, cyc i)`**, so the run is
back at `a` only at `i ≡ 0 (mod 3)`.  Pending-ness is `pending_run_gen`; the step is one of
`step5`'s four `d`-free pending edges (`step5_cyc`). -/
theorem walk_mod3 (c n : ℕ) (h0 : (g 0).1 = ((true, 0), c, n)) :
    ∀ i : ℕ, i ≤ c → (∀ j : ℕ, 1 ≤ j → j ≤ i → (g (j : ℤ)).1.1 ≠ (true, 3)) →
      (g (i : ℤ)).1.1 = (true, cyc (i : ℤ)) := by
  intro i
  induction i with
  | zero =>
    intro _ _
    have h00 : cyc 0 = 0 := by decide
    rw [Nat.cast_zero, h0, h00]
  | succ i ih =>
    intro hi hd
    have hprev := ih (by omega) (fun j h1 h2 => hd j h1 (by omega))
    have hpend : (g ((i + 1 : ℕ) : ℤ)).1.1.1 = true :=
      (pending_run_gen hg (true, 0) c n rfl h0 (i + 1) hi).1
    have hne : (g ((i + 1 : ℕ) : ℤ)).1.1 ≠ (true, 3) := hd (i + 1) (by omega) le_rfl
    obtain ⟨hs, -, -, -⟩ := hg (i : ℤ)
    rw [show ((i + 1 : ℕ) : ℤ) = (i : ℤ) + 1 by push_cast; ring] at hpend hne ⊢
    have hsplit : (g ((i : ℤ) + 1)).1.1 = (true, (g ((i : ℤ) + 1)).1.1.2) :=
      Prod.ext hpend rfl
    rw [hsplit, hprev] at hs
    have hj : (g ((i : ℤ) + 1)).1.1.2 ≠ 3 := fun h => hne (by rw [hsplit, h])
    rw [hsplit, step5_cyc (i : ℤ) _ hs hj]

/-- **The idle state ending a region copies the index of the last pending state**: `step5`'s
pending-to-idle clause is `y.2 == x.2`. -/
theorem idle_copy5 (i0 : Fin 4) (c n : ℕ) (h0 : (g 0).1 = ((true, i0), c, n)) :
    (g ((c : ℤ) + 1)).1.1.2 = (g (c : ℤ)).1.1.2 := by
  have hq1 : (g (c : ℤ)).1.1.1 = true :=
    (pending_run_gen hg (true, i0) c n rfl h0 c le_rfl).1
  have hy : (g ((c : ℤ) + 1)).1.1.1 = false := idle_at_gen hg (true, i0) c n rfl h0
  obtain ⟨hs, -, -, -⟩ := hg (c : ℤ)
  simpa [step5, hq1, hy] using hs

end Run5

section Truth5
variable {σ : WorldHistory F5} {k : ℤ} {g : ℤ → LadderState Q5 pend5}
  (hσ : σ.path = fun t => (t + k, g t))
  (hg : ∀ t, Rlad step5 pend5 t (g t).1 (g (t + 1)).1)
include hσ hg

/-- **`p U (r AND l_a)` at a pending state reads the index of the region's idle end**: the until
is forced to fire at `c + 1`, the first idle position, and nowhere else. -/
theorem endA_at_zero_iff (i0 : Fin 4) (c n : ℕ) (h0 : (g 0).1 = ((true, i0), c, n)) :
    PlusTruthAt M5 σ 0 endA ↔ (g ((c : ℤ) + 1)).1.1.2 = 0 := by
  constructor
  · rintro ⟨(s : ℤ), hs, hχ, hguard⟩
    have hs' : (0 : ℤ) < s := hs
    rw [PlusTruth.and_iff, truth_r5 hσ, truth_la5 hσ] at hχ
    obtain ⟨hr, ha⟩ := hχ
    rcases lt_trichotomy s ((c : ℤ) + 1) with hlt | heq | hgt
    · have hsn : ((s.toNat : ℕ) : ℤ) = s := Int.toNat_of_nonneg (by omega)
      have hle : s.toNat ≤ c := by omega
      have hq1 : (g ((s.toNat : ℕ) : ℤ)).1.1.1 = true :=
        (pending_run_gen hg (true, i0) c n rfl h0 s.toNat hle).1
      rw [hsn, hr] at hq1
      exact absurd hq1 Bool.false_ne_true
    · subst heq
      exact ha
    · have hp := hguard ((c : ℤ) + 1) (show (0 : ℤ) < (c : ℤ) + 1 by omega) hgt
      rw [truth_p5 hσ] at hp
      have hidle : (g ((c : ℤ) + 1)).1.1.1 = false := idle_at_gen hg (true, i0) c n rfl h0
      rw [hidle] at hp
      exact absurd hp Bool.false_ne_true
  · intro ha
    refine ⟨(c : ℤ) + 1, show (0 : ℤ) < (c : ℤ) + 1 by omega, ?_, ?_⟩
    · rw [PlusTruth.and_iff, truth_r5 hσ, truth_la5 hσ]
      exact ⟨idle_at_gen hg (true, i0) c n rfl h0, ha⟩
    · intro (s' : ℤ) h1 h2
      have h1' : (0 : ℤ) < s' := h1
      have h2' : s' < (c : ℤ) + 1 := h2
      rw [truth_p5 hσ]
      have hsn : ((s'.toNat : ℕ) : ℤ) = s' := Int.toNat_of_nonneg (by omega)
      have hle : s'.toNat ≤ c := by omega
      have hq1 : (g ((s'.toNat : ℕ) : ℤ)).1.1.1 = true :=
        (pending_run_gen hg (true, i0) c n rfl h0 s'.toNat hle).1
      rw [hsn] at hq1
      exact hq1

end Truth5

/-! ## A reference history through every pending `a`-state, along the 3-cycle -/

/-- Counts the region down along the 3-cycle with `n` fixed, idle at the copy of the last
pending index ever after; extended backwards along the 3-cycle. -/
def g5RefRaw (c n : ℕ) (t : ℤ) : Q5 × ℕ × ℕ :=
  if t ≤ (c : ℤ) then ((true, cyc t), ((c : ℤ) - t).toNat, n)
  else ((false, cyc (c : ℤ)), 0, n)

theorem g5RefRaw_adm (c n : ℕ) (t : ℤ) :
    (g5RefRaw c n t).2.1 ∈ Adm pend5 (g5RefRaw c n t).1 := by
  change (g5RefRaw c n t).1.1 = false → (g5RefRaw c n t).2.1 = 0
  unfold g5RefRaw
  split_ifs <;> simp

def g5Ref (c n : ℕ) (t : ℤ) : LadderState Q5 pend5 :=
  ⟨g5RefRaw c n t, g5RefRaw_adm c n t⟩

theorem g5RefRaw_step (c n : ℕ) (t : ℤ) :
    Rlad step5 pend5 0 (g5RefRaw c n t) (g5RefRaw c n (t + 1)) := by
  rw [rlad5_iff]
  unfold g5RefRaw
  rcases lt_trichotomy t (c : ℤ) with hlt | heq | hgt
  · have h1 : t ≤ (c : ℤ) := le_of_lt hlt
    have h2 : t + 1 ≤ (c : ℤ) := by omega
    rw [if_pos h1, if_pos h2]
    refine ⟨step5_cyc_succ t, by simp, Or.inl rfl, ?_⟩
    change Count true true (((c : ℤ) - t).toNat) n (((c : ℤ) - (t + 1)).toNat)
    rw [count_tt]
    omega
  · have h1 : t ≤ (c : ℤ) := le_of_eq heq
    have h2 : ¬ (t + 1 ≤ (c : ℤ)) := by omega
    rw [if_pos h1, if_neg h2, heq]
    refine ⟨by simp [step5], by simp, Or.inl rfl, ?_⟩
    change Count true false (((c : ℤ) - (c : ℤ)).toNat) n 0
    rw [count_tf]
    omega
  · have h1 : ¬ (t ≤ (c : ℤ)) := by omega
    have h2 : ¬ (t + 1 ≤ (c : ℤ)) := by omega
    rw [if_neg h1, if_neg h2]
    refine ⟨by simp [step5], by simp, Or.inl rfl, ?_⟩
    change Count false false 0 n 0
    rw [count_ff]

theorem g5Ref_isPath (c n : ℕ) :
    IsSlicedStepPath (RladAdm step5 pend5) 0 (g5Ref c n) := by
  intro t
  change Rlad step5 pend5 (t + 0) (g5RefRaw c n t) (g5RefRaw c n (t + 1))
  have h : Rlad step5 pend5 (t + 0) (g5RefRaw c n t) (g5RefRaw c n (t + 1)) ↔
      Rlad step5 pend5 0 (g5RefRaw c n t) (g5RefRaw c n (t + 1)) := Iff.rfl
  rw [h]
  exact g5RefRaw_step c n t

theorem g5Ref_zero (c n : ℕ) : (g5Ref c n 0).1 = ((true, 0), c, n) := by
  change g5RefRaw c n 0 = ((true, 0), c, n)
  unfold g5RefRaw
  rw [if_pos (by positivity : (0 : ℤ) ≤ (c : ℤ))]
  have h00 : cyc 0 = 0 := by decide
  simp [h00]

/-- Along the reference history no position carries `l_d`: the 3-cycle never visits `d` and
`l_d` is false at every idle state. -/
theorem not_evD_ref (c n : ℕ) {σ : WorldHistory F5}
    (hσ : σ.path = fun t => (t + 0, g5Ref c n t)) : ¬ PlusTruthAt M5 σ 0 evD := by
  rintro ⟨(s : ℤ), -, hld, -⟩
  rw [truth_ld5 hσ] at hld
  obtain ⟨hp, hd⟩ := hld
  change (g5RefRaw c n s).1.1 = true at hp
  change (g5RefRaw c n s).1.2 = 3 at hd
  unfold g5RefRaw at hp hd
  by_cases h : s ≤ (c : ℤ)
  · rw [if_pos h] at hd
    exact cyc_ne_three s hd
  · rw [if_neg h] at hp
    exact Bool.false_ne_true hp

/-- Along the reference history with `3 ∣ c`, the region ends on the idle copy of `a`. -/
theorem endA_ref (c n : ℕ) (hc : 3 ∣ c) {σ : WorldHistory F5}
    (hσ : σ.path = fun t => (t + 0, g5Ref c n t)) : PlusTruthAt M5 σ 0 endA := by
  rw [endA_at_zero_iff hσ (fun t => g5Ref_isPath c n t) 0 c n (g5Ref_zero c n)]
  change (g5RefRaw c n ((c : ℤ) + 1)).1.2 = 0
  unfold g5RefRaw
  rw [if_neg (by omega)]
  exact cyc_zero c hc

/-! ## Mechanism (5): the reach-set period against the letter-restricted sub-object -/

/-- **The cell at `(a, c, n)` with `3 ∣ c` contains a type WITHOUT `phi5`**: the reference
history satisfies `endA` and refutes `evD`. -/
theorem exists_cell_not_phi5 (c n : ℕ) (hc : 3 ∣ c) :
    ∃ T', T' ∈ cellAt M5 phi5 ((0 : ℤ), st5 0 c n) 0 ∧ phi5 ∉ T' := by
  obtain ⟨σ, hσ⟩ := hist_of_path5 0 (g5Ref c n) (g5Ref_isPath c n)
  refine ⟨tpOf M5 phi5 σ 0, ⟨σ, ?_, rfl⟩, ?_⟩
  · have hw : ((0 : ℤ), g5Ref c n 0) = ((0 : ℤ), st5 0 c n) :=
      Prod.ext rfl (Subtype.ext (g5Ref_zero c n))
    rw [← hw]
    exact congrFun hσ 0
  · rw [mem_tpOf_iff]
    rintro ⟨-, hφ⟩
    have hφ' : PlusTruthAt M5 σ 0 endA → PlusTruthAt M5 σ 0 evD := hφ
    exact not_evD_ref c n hσ (hφ' (endA_ref c n hc hσ))

/-- **Every type in the cell at `(a, C + (P+1), n)` with `3 ∣ C` and `3 ∤ P + 1` contains
`phi5`**: if the region ends on the idle copy of `a`, the run returned to `a` after `C + (P+1)`
pending steps, which is not a multiple of `3`, so the run left the 3-cycle through `d`. -/
theorem phi5_mem_of_mem_cell (C P n : ℕ) (hC : 3 ∣ C) (h3 : ¬ 3 ∣ (P + 1))
    (T' : Finset PlusFormula)
    (hT : T' ∈ cellAt M5 phi5 ((0 : ℤ), st5 0 (C + (P + 1)) n) 0) : phi5 ∈ T' := by
  obtain ⟨σ, hσz, rfl⟩ := hT
  obtain ⟨k, g, hg, hpath⟩ := hist_path5 σ
  have hst : ((0 : ℤ) + k, g 0) = ((0 : ℤ), st5 0 (C + (P + 1)) n) := by
    rw [← hσz]
    exact (congrFun hpath 0).symm
  have hg0 : (g 0).1 = ((true, 0), C + (P + 1), n) :=
    congrArg (fun w : ℤ × LadderState Q5 pend5 => w.2.1) hst
  have hg' : ∀ t, Rlad step5 pend5 t (g t).1 (g (t + 1)).1 := fun t => hg t
  rw [mem_tpOf_iff]
  refine ⟨self_mem_plusSubformulaClosure _, ?_⟩
  change PlusTruthAt M5 σ 0 endA → PlusTruthAt M5 σ 0 evD
  intro hendA
  have hidx : (g ((C + (P + 1) : ℕ) : ℤ)).1.1.2 = 0 := by
    have h1 := (endA_at_zero_iff hpath hg' 0 (C + (P + 1)) n hg0).mp hendA
    rw [idle_copy5 hg' 0 (C + (P + 1)) n hg0] at h1
    exact h1
  by_cases hd : ∃ j : ℕ, 1 ≤ j ∧ j ≤ C + (P + 1) ∧ (g (j : ℤ)).1.1 = (true, 3)
  · obtain ⟨j, hj1, -, hjd⟩ := hd
    exact evD_of_ld hpath j hj1 hjd
  · exfalso
    have hfree : ∀ j : ℕ, 1 ≤ j → j ≤ C + (P + 1) → (g (j : ℤ)).1.1 ≠ (true, 3) :=
      fun j h1 h2 heq => hd ⟨j, h1, h2, heq⟩
    have hw := walk_mod3 hg' (C + (P + 1)) n hg0 (C + (P + 1)) le_rfl hfree
    have hcyc : cyc ((C + (P + 1) : ℕ) : ℤ) = 0 := by
      have h2 := congrArg Prod.snd hw
      rw [hidx] at h2
      exact h2.symm
    have hdvd := dvd_of_cyc_zero (C + (P + 1)) hcyc
    omega

theorem c5_dvd (T P : ℕ) : 3 ∣ c5 T P := ⟨(P + 1) * (T + 1), by unfold c5; ring⟩

theorem le_c5 (T P : ℕ) : T ≤ c5 T P := by
  have h := Nat.le_mul_of_pos_left (T + 1) (show 0 < 3 * (P + 1) by positivity)
  unfold c5
  generalize 3 * (P + 1) * (T + 1) = C at h ⊢
  omega

/-- The Phase 1 recipe at an arbitrary countdown `C ≥ T`: both countdowns saturate the
threshold, the residues agree modulo `P + 1`, the next deadline is shared, both gaps clip. -/
theorem collide5 (T P B C : ℕ) (hTC : T ≤ C) :
    ladderIndexRes T P B (st5 0 C (C + (P + 1) + B))
      = ladderIndexRes T P B (st5 0 (C + (P + 1)) (C + (P + 1) + B)) := by
  simp only [ladderIndexRes, st5, Prod.mk.injEq, Fin.mk.injEq, true_and]
  and_intros <;> first | omega | exact (Nat.add_mod_right C (P + 1)).symm

/-- **The pair collides in the index for EVERY `(T, P, B)`.** -/
theorem period_collision (T P B : ℕ) :
    ladderIndexRes T P B (x5 T P B) = ladderIndexRes T P B (y5 T P B) :=
  collide5 T P B (c5 T P) (le_c5 T P)

/-- **The cells differ whenever `3 ∤ P + 1`**: the reference type through `x5` lacks `phi5`;
every type through `y5` contains it. -/
theorem cell5_ne (T P B : ℕ) (h3 : ¬ 3 ∣ (P + 1)) :
    cellAt M5 phi5 ((0 : ℤ), x5 T P B) 0 ≠ cellAt M5 phi5 ((0 : ℤ), y5 T P B) 0 := by
  intro heq
  unfold x5 y5 at heq
  obtain ⟨T', hT', hnot⟩ :=
    exists_cell_not_phi5 (c5 T P) (c5 T P + (P + 1) + B) (c5_dvd T P)
  rw [heq] at hT'
  exact hnot (phi5_mem_of_mem_cell (c5 T P) P (c5 T P + (P + 1) + B) (c5_dvd T P) h3 T' hT')

/-- **THE REFUTATION OF THE REACH-SET PERIOD.**  For every threshold, every clip bound and every
modulus coprime to `3` — in particular both readings of the exhibited period `1` — the index does
not factor the coprime-cycle fixture's cells. -/
theorem reach_period_refuted (T P B : ℕ) (h3 : ¬ 3 ∣ (P + 1)) :
    ¬ ∀ x y : LadderState Q5 pend5, ladderIndexRes T P B x = ladderIndexRes T P B y →
        cellAt M5 phi5 ((0 : ℤ), x) 0 = cellAt M5 phi5 ((0 : ℤ), y) 0 := by
  intro h
  exact cell5_ne T P B h3 (h _ _ (period_collision T P B))

end Probe775
