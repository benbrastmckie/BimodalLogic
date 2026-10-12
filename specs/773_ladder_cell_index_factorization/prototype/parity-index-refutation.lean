/-
PROTOTYPE TEST (not a wired probe): the fresh refutation the predecessor blocker analysis asked
for.  The gap-carrying three-coordinate cell index
  `(q, min c B, min n B, clip (n - c) [-B, B])`
is REFUTED uniformly in `B`, on an object whose `step` relation makes the PARITY of the countdown
`c` observable at the region end -- a distance `c + 1` away, which `min c B` destroys.  The
refutation is independent of the gap coordinate: the two colliding states carry the SAME `n` and
gaps that both clip to the top of the gap range.

Mechanism: `Count true true` forces the countdown to run to `0` exactly, so the first idle state
sits at distance `c + 1`; `step` can alternate a tag on every pending step and copy it onto the
idle state, so the idle state's tag is `tag XOR (c mod 2)`.  An atom reading that tag, under
`p U (r AND a)`, reads `c mod 2` at unbounded distance.
-/
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace ParityIndexRefutation

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

def wP (tg : Bool) (c n : ℕ) : F.WorldState :=
  ((0 : ℤ), ⟨((true, tg), c, n), fun h => by cases h⟩)

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

/-! ## The candidate index and its refutation -/

/-- **The dispatch's candidate index**: `(q, min c B, min n B, clip (n - c) [-B, B])`, with the
gap coordinate offset by `B` so that it lands in `Fin (2*B + 1)` (truncated `ℕ`-subtraction
implements the clip at `-B`; `min ... (2*B)` the clip at `+B`).  A `Fintype` by construction for
every finite object. -/
def ladderIndex (B : ℕ) {Q : Type} {pend : Q → Bool} (x : LadderState Q pend) :
    Q × Fin (B + 1) × Fin (B + 1) × Fin (2 * B + 1) :=
  (x.1.1, ⟨min x.1.2.1 B, by omega⟩, ⟨min x.1.2.2 B, by omega⟩,
    ⟨min ((x.1.2.2 + B) - x.1.2.1) (2 * B), by omega⟩)

/-- **The cheap falsification gate passes, for `2 ≤ B`.** On the known refutation's own pair --
counters `(B, B+1)` against `(B, B+2)`, where every counter is `≥ B` -- the gap coordinate gives
`B+1` against `B+2`, so the candidate is NOT killed by the existing refutation. -/
theorem gate_separates (B : ℕ) (hB : 2 ≤ B) :
    min ((B + 1 + B) - B) (2 * B) ≠ min ((B + 2 + B) - B) (2 * B) := by omega

/-- **...but only for `2 ≤ B`**: at `B ≤ 1` the clip range is narrower than the gaps being
separated and the candidate collides on that very pair.  The `φ`-derived bound must therefore
exceed the gaps `φ` can see, which is the prototype's finding (B) restated as a constraint on
`B`. -/
theorem gate_collides_below_two (B : ℕ) (hB : B ≤ 1) :
    min ((B + 1 + B) - B) (2 * B) = min ((B + 2 + B) - B) (2 * B) := by omega

def xRef (B : ℕ) : LadderState Qp pendP :=
  ⟨((true, false), 2 * B, 4 * B + 2), fun h => by cases h⟩

def yRef (B : ℕ) : LadderState Qp pendP :=
  ⟨((true, false), 2 * B + 1, 4 * B + 2), fun h => by cases h⟩

/-- The two states collide in the candidate index, at every `B`: the object components agree, the
two counters both saturate `min _ B`, and both gaps (`2B+2` and `2B+1`) saturate the clip at
`+B`. -/
theorem index_collide (B : ℕ) : ladderIndex B (xRef B) = ladderIndex B (yRef B) := by
  simp only [ladderIndex, xRef, yRef, Prod.mk.injEq, Fin.mk.injEq, true_and]
  omega

/-- **THE REFUTATION, uniform in `B`**: the gap-carrying three-coordinate index does not factor
`cellAt`, for any `B` whatsoever.  The witnessing pair carries EQUAL next-deadlines and gaps that
both saturate the clip, so the gap coordinate is not what fails -- the countdown coordinate is,
through the parity its clipping destroys. -/
theorem ladderIndex_not_factoring (B : ℕ) :
    ¬ ∀ x y : LadderState Qp pendP, ladderIndex B x = ladderIndex B y →
        cellAt M phiP ((0 : ℤ), x) 0 = cellAt M phiP ((0 : ℤ), y) 0 := by
  intro h
  exact cell_succ_ne false (2 * B) (4 * B + 2) (h (xRef B) (yRef B) (index_collide B))

/-- The exhibited-bound form, at `B = |cl phiP|`, is refuted. -/
theorem exhibited_form_refuted :
    ¬ ∀ x y : LadderState Qp pendP,
        ladderIndex (plusSubformulaClosure phiP).card x
          = ladderIndex (plusSubformulaClosure phiP).card y →
        cellAt M phiP ((0 : ℤ), x) 0 = cellAt M phiP ((0 : ℤ), y) 0 :=
  ladderIndex_not_factoring _

/-- The `∃ B` fallback form is refuted too: the witness is uniform in `B`. -/
theorem exists_form_refuted :
    ¬ ∃ B : ℕ, ∀ x y : LadderState Qp pendP, ladderIndex B x = ladderIndex B y →
        cellAt M phiP ((0 : ℤ), x) 0 = cellAt M phiP ((0 : ℤ), y) 0 := by
  rintro ⟨B, h⟩
  exact ladderIndex_not_factoring B h

/-! ## The repair, gated on this object

The refutation says the countdown coordinate must retain whatever `cellAt` can read at distance
`c + 1` -- the object state at the region end, a `step`-reachability datum in `c + 1` steps.
That datum is eventually periodic in `c`, so a RESIDUE coordinate `c % P` beside `min c B`
restores it.  The check below is the cheap one: the residue coordinate separates the pair that
refutes the three-coordinate index.  It is NOT a proof that the repaired index factors `cellAt`. -/

/-- The candidate repaired by one residue coordinate, at period `P`. -/
def ladderIndexRes (B P : ℕ) {Q : Type} {pend : Q → Bool} (x : LadderState Q pend) :
    (Q × Fin (B + 1) × Fin (B + 1) × Fin (2 * B + 1)) × ℕ :=
  (ladderIndex B x, x.1.2.1 % P)

/-- At period `2` the repaired index DOES separate the pair that refutes the three-coordinate
candidate, at every `B`. -/
theorem index_res_separates (B : ℕ) :
    ladderIndexRes B 2 (xRef B) ≠ ladderIndexRes B 2 (yRef B) := by
  intro h
  have h2 := congrArg Prod.snd h
  simp only [ladderIndexRes, xRef, yRef] at h2
  omega

end ParityIndexRefutation

/-! ## Axiom check -/

#print axioms ParityIndexRefutation.cell_succ_ne
#print axioms ParityIndexRefutation.ladderIndex_not_factoring
#print axioms ParityIndexRefutation.exists_form_refuted
#print axioms ParityIndexRefutation.exhibited_form_refuted
#print axioms ParityIndexRefutation.truth_phiP
#print axioms ParityIndexRefutation.gate_separates
