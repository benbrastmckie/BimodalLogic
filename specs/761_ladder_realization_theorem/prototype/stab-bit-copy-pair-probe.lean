/-
RESEARCH-ROUND PROBE (route S-1), ladder realization theorem, Phase 11.6.

**Question.** The depth induction's step needs the pinned-letter premise
`hL : ∀ χ, L (⊡χ) → ∀ w, (PlusTruthAt M σ' w (⊡χ) ↔ PlusTruthAt M σ (ρ w) (⊡χ))`
at EVERY position of the rebuilt path, and by `stab_state_only` each such instance is a
statement about the PAIR OF LADDER STATES the two paths occupy. The recorded obstruction says
those pairs are not `kappa`-collisions, from two sources: (O1) interior copies of the iterated
duplication are displaced by a multiple of the block length `l`, which need not be a multiple of
`P + 1`; (O2) threshold-tight pairs have their lower member below `Tc`. Neither was known to be a
GENUINE difference of a `⊡` bit rather than merely an underivable one.

**What this probe decides, on one fixture, by compilation.** Both sources are genuine: a `⊡` bit
really does differ at each pair shape, so no proof route can derive `hL` there and the pump
construction must be changed so that no such pair arises.

* (O1) is genuine: `stab_bit_ne_of_odd_shift` — at an ODD countdown displacement the `⊡phiP` bit
  differs, at every `c`, every `n`, and every tag.
* (O1) is curable by the RESIDUE alone: `stab_bit_eq_of_even_shift` and
  `stab_bit_eq_of_paramsOkK1_shift` — at a displacement that is a multiple of `P + 1` the
  `⊡phiP` bit agrees, with NO threshold hypothesis, and `(K1)` already forces the modulus this
  fixture's bit reads (`two_mem_objCycleLens`, so `2 ∣ P + 1`).
* (O2) is genuine and is NOT curable by the residue: `stab_bit_ne_of_below_threshold` — the bit
  of `⊡(X r)` is `c = 0`, so it differs between `c = 0` and `c = e` for EVERY `e > 0`, a multiple
  of `P + 1` included. A threshold margin is therefore mandatory, not an artifact of the proof.

**What this probe does NOT establish.** It is one fixture; it refutes universals and proves no
agreement. It says nothing about the general cell, nothing about any bound (every quantity named
is a count), and nothing about the realization theorem. It does not claim the pump construction
produces these exact pairs — the countdowns at interior copy positions are not exposed by any
landed clause of `exists_iterSpliced_ladderPath_idx_of_pend_past`, which is recorded as an open
obligation and is not assumed here.

The object, the letters, the forced-run lemmas and `phiP` are the fixture of
`specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean`, reproduced because
an evidence file is not an importable module; `tagAt`, `pending_run`, `idle_at`, `truth_phiP`,
`gRef` and `cell_succ_ne`'s surrounding block are that probe's and are not re-derived in spirit.
Everything from `## The stab bit is a state datum` down is new.

Compile-check from the repository root with:
  lake env lean specs/761_ladder_realization_theorem/prototype/stab-bit-copy-pair-probe.lean
-/
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel
import FormalSystem.Metalogic.Decidability.RaySummary.CounterQuotient
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Limits.NoFiniteWidth


open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate

namespace ProbeS1

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


/-! ## The stab bit is a state datum, and on this fixture it reads the countdown's parity -/

/-- Every pending ladder state carries a history: `gRef` through it. This keeps every `⊡`
statement below non-vacuous. -/
theorem exists_hist_at (tg : Bool) (c n : ℕ) :
    ∃ τ : WorldHistory F, τ.state 0 = wP tg c n := by
  obtain ⟨σ, hσ⟩ := hist_of_path 0 (gRef tg c n) (gRef_isPath tg c n)
  refine ⟨σ, ?_⟩
  rw [← wRef_eq]
  exact congrFun hσ 0

/-- `phiP`'s truth at time `0` on ANY history through a pending ladder state is the countdown's
tag — `truth_phiP` with the history's own path decomposition supplied. -/
theorem truth_phiP_of_state (τ : WorldHistory F) (tg : Bool) (c n : ℕ)
    (hτ : τ.state 0 = wP tg c n) :
    PlusTruthAt M τ 0 phiP ↔ tagAt tg (c : ℤ) = true := by
  obtain ⟨k, g, hg, hpath⟩ := hist_path τ
  have hst : ((0 : ℤ) + k, g 0) = wP tg c n := by
    rw [← hτ]
    exact (congrFun hpath 0).symm
  have hg0 : (g 0).1 = ((true, tg), c, n) :=
    congrArg (fun w : ℤ × LadderState Qp pendP => w.2.1) hst
  exact truth_phiP hpath (fun t => hg t) tg c n hg0

/-- **The `⊡` bit of `phiP` at a pending ladder state is the countdown's tag.** The `stab` clause
quantifies over the histories through the state, and `truth_phiP_of_state` settles every one of
them the same way, so the universal collapses to the one proposition. -/
theorem stab_phiP_iff (τ : WorldHistory F) (tg : Bool) (c n : ℕ)
    (hτ : τ.state 0 = wP tg c n) :
    PlusTruthAt M τ 0 (PlusFormula.stab phiP) ↔ tagAt tg (c : ℤ) = true := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h
    exact (truth_phiP_of_state τ tg c n hτ).mp (h τ rfl)
  · intro h σ hs
    refine (truth_phiP_of_state σ tg c n ?_).mpr h
    rw [← hs]
    exact hτ

/-! ## The tag as a residue reading -/

theorem tagAt_eq_of_emod_eq (tg : Bool) (i j : ℤ) (h : i % 2 = j % 2) :
    tagAt tg i = tagAt tg j := by
  unfold tagAt
  rw [h]

theorem tagAt_ne_of_emod_ne (tg : Bool) (i j : ℤ) (h : ¬ (i % 2 = j % 2)) :
    tagAt tg i ≠ tagAt tg j := by
  unfold tagAt
  have hi : i % 2 = 0 ∨ i % 2 = 1 := Int.emod_two_eq_zero_or_one i
  have hj : j % 2 = 0 ∨ j % 2 = 1 := Int.emod_two_eq_zero_or_one j
  rcases hi with hi | hi <;> rcases hj with hj | hj
  · exact absurd (hi.trans hj.symm) h
  · rw [hi, hj, if_pos rfl, if_neg (by norm_num : ¬ ((1 : ℤ) = 0))]
    cases tg <;> simp
  · rw [hi, hj, if_neg (by norm_num : ¬ ((1 : ℤ) = 0)), if_pos rfl]
    cases tg <;> simp
  · exact absurd (hi.trans hj.symm) h

/-! ## (O1): an off-residue displacement genuinely changes the stab bit -/

/-- **THE (O1) REFUTATION.** At an ODD countdown displacement the `⊡phiP` bits of the two states
genuinely DIFFER — at every tag, every `c` and every `n`, with the next-deadline register held
fixed. So `hL` at an interior-copy pair whose displacement is odd is not merely underivable from
an agreement on `kappa`-classes: it is FALSE. A construction whose interior copies are displaced
by a non-multiple of the modulus the bit reads cannot be repaired by any proof. -/
theorem stab_bit_ne_of_odd_shift (tg : Bool) (c n e : ℕ) (he : e % 2 = 1)
    (τ₁ τ₂ : WorldHistory F) (h₁ : τ₁.state 0 = wP tg c n)
    (h₂ : τ₂.state 0 = wP tg (c + e) n) :
    ¬ (PlusTruthAt M τ₁ 0 (PlusFormula.stab phiP) ↔
        PlusTruthAt M τ₂ 0 (PlusFormula.stab phiP)) := by
  rw [stab_phiP_iff τ₁ tg c n h₁, stab_phiP_iff τ₂ tg (c + e) n h₂]
  have hmod : ¬ (((c + e : ℕ) : ℤ) % 2 = ((c : ℕ) : ℤ) % 2) := by
    push_cast
    omega
  have hne := tagAt_ne_of_emod_ne tg ((c + e : ℕ) : ℤ) ((c : ℕ) : ℤ) hmod
  revert hne
  cases tagAt tg ((c + e : ℕ) : ℤ) <;> cases tagAt tg ((c : ℕ) : ℤ) <;> simp

/-- **The on-residue half.** At an EVEN displacement the bits AGREE — at every `c`, with NO
threshold hypothesis on either member. -/
theorem stab_bit_eq_of_even_shift (tg : Bool) (c n e : ℕ) (he : e % 2 = 0)
    (τ₁ τ₂ : WorldHistory F) (h₁ : τ₁.state 0 = wP tg c n)
    (h₂ : τ₂.state 0 = wP tg (c + e) n) :
    (PlusTruthAt M τ₁ 0 (PlusFormula.stab phiP) ↔
      PlusTruthAt M τ₂ 0 (PlusFormula.stab phiP)) := by
  rw [stab_phiP_iff τ₁ tg c n h₁, stab_phiP_iff τ₂ tg (c + e) n h₂]
  have hmod : ((c : ℕ) : ℤ) % 2 = ((c + e : ℕ) : ℤ) % 2 := by
    push_cast
    omega
  rw [tagAt_eq_of_emod_eq tg ((c : ℕ) : ℤ) ((c + e : ℕ) : ℤ) hmod]

/-! ## (K1) already forces the modulus this fixture's stab bit reads -/

/-- The pending two-cycle of the fixture's object: the tag flips on every pending step, so the
walk `i ↦ (true, i odd)` is a pending cycle of length `2`. -/
def cyc : ℕ → Qp := fun i => (true, decide (i % 2 = 1))

/-- **`2` is an object cycle length**, so `(K1)` forces `2 ∣ P + 1`. -/
theorem two_mem_objCycleLens : (2 : ℕ) ∈ objCycleLens stepP pendP := by
  refine ⟨by norm_num, ?_, cyc, ?_, ?_, ?_⟩
  · show 2 ≤ Fintype.card (Bool × Bool)
    simp
  · intro i
    show stepP (cyc i) (cyc (i + 1)) = true
    unfold cyc stepP
    have h : (i + 1) % 2 = 1 ↔ ¬ (i % 2 = 1) := by omega
    by_cases hi : i % 2 = 1 <;> simp [hi, h]
  · intro i
    rfl
  · unfold cyc
    norm_num

/-- **(K1) covers the fixture's stab bit.** Every admissible modulus `P + 1` is even here. -/
theorem two_dvd_succ_of_paramsOkK1 (lab : Qp → Atom → Bool) (φ : PlusFormula) (P : ℕ)
    (h : paramsOkK1 stepP pendP lab φ P) : 2 ∣ P + 1 :=
  h.2.1 2 two_mem_objCycleLens

/-- **THE POSITIVE READING OF (O1).** Under `(K1)` alone, a displacement by any multiple of the
modulus `P + 1` leaves the `⊡phiP` bit unchanged — at EVERY `c`, with no threshold. So the cure
for (O1) is a construction whose copy displacements are exact multiples of `P + 1`, and nothing
about thresholds enters. -/
theorem stab_bit_eq_of_paramsOkK1_shift (lab : Qp → Atom → Bool) (φ : PlusFormula) (P : ℕ)
    (hK1 : paramsOkK1 stepP pendP lab φ P) (tg : Bool) (c n m : ℕ)
    (τ₁ τ₂ : WorldHistory F) (h₁ : τ₁.state 0 = wP tg c n)
    (h₂ : τ₂.state 0 = wP tg (c + m * (P + 1)) n) :
    (PlusTruthAt M τ₁ 0 (PlusFormula.stab phiP) ↔
      PlusTruthAt M τ₂ 0 (PlusFormula.stab phiP)) := by
  obtain ⟨j, hj⟩ := two_dvd_succ_of_paramsOkK1 lab φ P hK1
  refine stab_bit_eq_of_even_shift tg c n (m * (P + 1)) ?_ τ₁ τ₂ h₁ h₂
  rw [hj, show m * (2 * j) = 2 * (m * j) by ring]
  exact Nat.mul_mod_right 2 (m * j)

/-! ## (O2): below the threshold the bit reads the EXACT countdown, not its residue

`X r` — `⊥ U r`, the next-time reading of "idle" — fires exactly one step away, and the forced
run puts the region's idle state at distance exactly `c + 1`. So the `⊡` bit of `X r` is
`c = 0`: a reading of the exact countdown, blind to every residue. -/

def Xf (χ : PlusFormula) : PlusFormula := .untl .bot χ

/-- `X r`'s truth on any history through a pending ladder state is `c = 0`. -/
theorem truth_Xr_of_state (τ : WorldHistory F) (tg : Bool) (c n : ℕ)
    (hτ : τ.state 0 = wP tg c n) :
    PlusTruthAt M τ 0 (Xf r) ↔ c = 0 := by
  obtain ⟨k, g, hg, hpath⟩ := hist_path τ
  have hst : ((0 : ℤ) + k, g 0) = wP tg c n := by
    rw [← hτ]
    exact (congrFun hpath 0).symm
  have hg0 : (g 0).1 = ((true, tg), c, n) :=
    congrArg (fun w : ℤ × LadderState Qp pendP => w.2.1) hst
  constructor
  · rintro ⟨(s : ℤ), hs, hr, hguard⟩
    have hs' : (0 : ℤ) < s := hs
    have hs1 : s = 1 := by
      by_contra hne
      have h2 : (0 : ℤ) < 1 := by omega
      have h3 : (1 : ℤ) < s := by omega
      exact PlusTruth.bot_false (M := M) (τ := τ) (t := (1 : ℤ)) (hguard 1 h2 h3)
    subst hs1
    rw [truth_r hpath] at hr
    by_contra hc
    have hc1 : 1 ≤ c := by omega
    obtain ⟨hq1, -, -⟩ := pending_run (fun t => hg t) tg c n hg0 1 hc1
    rw [show ((1 : ℕ) : ℤ) = (1 : ℤ) by norm_num] at hq1
    rw [hq1] at hr
    exact absurd hr (by simp)
  · intro hc
    subst hc
    refine ⟨1, show (0 : ℤ) < 1 by omega, ?_, ?_⟩
    · rw [truth_r hpath]
      obtain ⟨hidle, -⟩ := idle_at (fun t => hg t) tg 0 n hg0
      rw [show (1 : ℤ) = ((0 : ℕ) : ℤ) + 1 by norm_num]
      exact hidle
    · intro (s' : ℤ) h1 h2
      have h1' : (0 : ℤ) < s' := h1
      have h2' : s' < (1 : ℤ) := h2
      exact absurd h2' (not_lt.mpr (by omega))

/-- **The `⊡` bit of `X r` at a pending ladder state is `c = 0`.** -/
theorem stab_Xr_iff (τ : WorldHistory F) (tg : Bool) (c n : ℕ)
    (hτ : τ.state 0 = wP tg c n) :
    PlusTruthAt M τ 0 (PlusFormula.stab (Xf r)) ↔ c = 0 := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h
    exact (truth_Xr_of_state τ tg c n hτ).mp (h τ rfl)
  · intro h σ hs
    refine (truth_Xr_of_state σ tg c n ?_).mpr h
    rw [← hs]
    exact hτ

/-- **THE (O2) REFUTATION.** The `⊡(X r)` bits at countdown `0` and at countdown `e` differ for
EVERY `e > 0` — in particular at `e = m * (P + 1)` with `0 < m`, an exact multiple of the
modulus. So a threshold-straddling pair genuinely carries differing `⊡` bits WHATEVER the
residue, and no respacing of the pump's blocks can repair it: the construction must keep both
members of every copy pair above the threshold at which the bit stops reading the exact
countdown. This is the compiled statement that makes a margin MANDATORY. -/
theorem stab_bit_ne_of_below_threshold (tg : Bool) (n e : ℕ) (he : 0 < e)
    (τ₁ τ₂ : WorldHistory F) (h₁ : τ₁.state 0 = wP tg 0 n)
    (h₂ : τ₂.state 0 = wP tg e n) :
    ¬ (PlusTruthAt M τ₁ 0 (PlusFormula.stab (Xf r)) ↔
        PlusTruthAt M τ₂ 0 (PlusFormula.stab (Xf r))) := by
  rw [stab_Xr_iff τ₁ tg 0 n h₁, stab_Xr_iff τ₂ tg e n h₂]
  intro h
  exact absurd (h.mp rfl) (by omega)

/-- The (O2) refutation at an EXACT multiple of the modulus, stated so the residue cannot be
read as the missing ingredient. -/
theorem stab_bit_ne_of_below_threshold_on_residue (tg : Bool) (n P m : ℕ) (hm : 0 < m)
    (τ₁ τ₂ : WorldHistory F) (h₁ : τ₁.state 0 = wP tg 0 n)
    (h₂ : τ₂.state 0 = wP tg (m * (P + 1)) n) :
    ¬ (PlusTruthAt M τ₁ 0 (PlusFormula.stab (Xf r)) ↔
        PlusTruthAt M τ₂ 0 (PlusFormula.stab (Xf r))) :=
  stab_bit_ne_of_below_threshold tg n (m * (P + 1)) (by positivity) τ₁ τ₂ h₁ h₂

/-! ## The margin design's two parameter facts, generic in the object

The cure the two refutations above force is a construction whose copy displacements are exact
multiples of `P + 1` AND whose copy pairs both sit above a threshold. The landed spaced
pigeonhole `exists_typeBlock_of_spacing` delivers the first at spacing `s := P + 1` — its block
length is `d * (P + 1)` with `1 ≤ d ≤ b`, so every interior-copy displacement is a multiple of
`P + 1` and the "exact shift" question does not arise — but it is gated on the room hypothesis
`w₀ + b * (P + 1) ≤ z + cntAt g z`, which at `cntAt g z = Tc` reads `b * (P + 1) ≤ Tc`. The two
theorems below settle what that costs: the room hypothesis is NOT derivable from `ParamsOk` as it
stands, and the conjunct that would supply it is dischargeable, so the strengthening is a real
change to `ParamsOk` and not a vacuous one. -/

section Margin

variable {Q : Type} [Fintype Q]

/-- **No inequality growing in `P` follows from `ParamsOk` at a fixed `Tc`.** `paramsOk_inflate`
multiplies the modulus by any positive `j` with all four parameters otherwise held, so the
modulus is unbounded at fixed `Tc`: the room hypothesis `b * (P + 1) ≤ Tc` that spacing
`s := P + 1` needs is not a consequence of the parameter conditions, and a margin design must add
a conjunct coupling `Tc` to `P`. (`budget_mul_succ_le_Tc`, the room bound `(K2)` does give, is
`b * (b + 1) ≤ Tc` and mentions `P` nowhere.) -/
theorem paramsOk_modulus_unbounded_at_fixed_Tc (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) (N : ℕ) :
    ∃ P' : ℕ, N ≤ P' ∧ ParamsOk step pend lab φ Tc Tn P' B := by
  refine ⟨(N + 1) * (P + 1) - 1, ?_, paramsOk_inflate step pend lab φ Tc Tn P B hp (N + 1)
    (Nat.succ_pos N)⟩
  have h : N + 1 ≤ (N + 1) * (P + 1) := Nat.le_mul_of_pos_right _ (Nat.succ_pos P)
  omega

/-- **`ParamsOk` is monotone upward in `Tc` once `Tn` is raised with it.** `(K1)` and `(K4)` do
not mention `Tc`, and `(K2)` and the second half of `(K3)` are lower bounds on it; only `(K3)`'s
ordering conjunct constrains `Tc` from above, and it is re-established at the raised `Tn`. -/
theorem paramsOk_raise_Tc (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) (Tc' Tn' : ℕ) (hc : Tc ≤ Tc')
    (hn : Tc' + 2 * ell0 Q φ ≤ Tn' + 1) :
    ParamsOk step pend lab φ Tc' Tn' P B := by
  obtain ⟨hK1, ⟨hK2a, hK2b⟩, ⟨-, hK3b⟩, hK4⟩ := hp
  exact ⟨hK1, ⟨le_trans hK2a hc, le_trans hK2b hc⟩, ⟨hn, le_trans hK3b hc⟩, hK4⟩

/-- **THE MARGIN CONJUNCT IS DISCHARGEABLE.** For every required margin `N` there are parameters
satisfying `(K1)`-`(K4)` with `N ≤ Tc`. So strengthening `(K2)` by any margin — in particular
`b * (P + 1)` once per `⊡`-nesting level, the depth-dependent amount the stratified design needs —
leaves the parameter hypothesis satisfiable, and the strengthened conditions are not vacuous for
any downstream consumer. The margin is a COUNT; no upper bound on `Tc` is claimed here or
anywhere it feeds. -/
theorem exists_paramsOk_with_margin [Nonempty Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (N : ℕ) :
    ∃ Tc Tn : ℕ, N ≤ Tc ∧
      ParamsOk step pend lab φ Tc Tn (Pof step pend lab φ) (Bof step pend lab φ) := by
  classical
  set Tc' := max (Tcof step pend lab φ) N with hTc'
  refine ⟨Tc', Tc' + 2 * ell0 Q φ, le_max_right _ _, ?_⟩
  exact paramsOk_raise_Tc step pend lab φ (Tcof step pend lab φ) (Tnof step pend lab φ)
    (Pof step pend lab φ) (Bof step pend lab φ) (paramsOk_params step pend lab φ) Tc'
    (Tc' + 2 * ell0 Q φ) (le_max_left _ _) (by omega)

end Margin

#print axioms ProbeS1.stab_phiP_iff
#print axioms ProbeS1.stab_bit_ne_of_odd_shift
#print axioms ProbeS1.stab_bit_eq_of_even_shift
#print axioms ProbeS1.two_mem_objCycleLens
#print axioms ProbeS1.stab_bit_eq_of_paramsOkK1_shift
#print axioms ProbeS1.stab_Xr_iff
#print axioms ProbeS1.stab_bit_ne_of_below_threshold
#print axioms ProbeS1.stab_bit_ne_of_below_threshold_on_residue
#print axioms ProbeS1.exists_hist_at
#print axioms ProbeS1.paramsOk_modulus_unbounded_at_fixed_Tc
#print axioms ProbeS1.paramsOk_raise_Tc
#print axioms ProbeS1.exists_paramsOk_with_margin

end ProbeS1
