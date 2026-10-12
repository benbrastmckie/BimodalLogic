/-
PROTOTYPE TEST (not a wired probe): two cheap checks on the gap-carrying cell-index
candidate, run before the general proof is attempted.  Fixture copied VERBATIM from
specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean so the results are
directly comparable with that probe's refutation.  Namespace renamed to avoid collision.
-/
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace GapIndexTest

/-! ## The two-state object -/

def stepB : Bool → Bool → Bool := fun _ _ => true
def pendB : Bool → Bool := fun q => q

theorem rlad_iff (t : ℤ) (x y : Bool × ℕ × ℕ) :
    Rlad stepB pendB t x y ↔
      (x.1 = false → x.2.1 = 0) ∧ Drift x.2.2 y.2.2 ∧ Count x.1 y.1 x.2.1 x.2.2 y.2.1 := by
  simp [Rlad, stepB, pendB]

/-- `Count` on concrete Booleans, so no cast is ever rewritten inside a hypothesis. -/
theorem count_tt (c n c' : ℕ) : Count true true c n c' ↔ c' + 1 = c := by simp [Count]
theorem count_tf (c n c' : ℕ) : Count true false c n c' ↔ c' = 0 ∧ c = 0 := by simp [Count]
theorem count_ft (c n c' : ℕ) : Count false true c n c' ↔ c' = n := by simp [Count]
theorem count_ff (c n c' : ℕ) : Count false false c n c' ↔ c' = 0 := by simp [Count]

theorem fwdB : ∀ t x, ∃ y, RladAdm stepB pendB t x y := by
  rintro t ⟨⟨q, c, n⟩, hx⟩
  cases q with
  | false =>
    have hc : c = 0 := hx rfl
    subst hc
    exact ⟨⟨(false, 0, n), fun _ => rfl⟩, by simp [RladAdm, rlad_iff, Drift, Count]⟩
  | true =>
    cases c with
    | zero => exact ⟨⟨(false, 0, n), fun _ => rfl⟩, by simp [RladAdm, rlad_iff, Drift, Count]⟩
    | succ c =>
      exact ⟨⟨(true, c, n), fun h => by cases h⟩, by simp [RladAdm, rlad_iff, Drift, Count]⟩

theorem bwdB : ∀ t x, ∃ y, RladAdm stepB pendB (t - 1) y x := by
  rintro t ⟨⟨q, c, n⟩, hx⟩
  cases q with
  | false =>
    have hc : c = 0 := hx rfl
    subst hc
    exact ⟨⟨(false, 0, n), fun _ => rfl⟩, by simp [RladAdm, rlad_iff, Drift, Count]⟩
  | true =>
    exact ⟨⟨(true, c + 1, n), fun h => by cases h⟩, by simp [RladAdm, rlad_iff, Drift, Count]⟩

def F : FrameOver intOrder := ladderFrameAdm stepB pendB fwdB bwdB

instance : F.IsRegular := ladderFrameAdm_isRegular stepB pendB fwdB bwdB

def pA : Atom := ⟨"p", none⟩
def rA : Atom := ⟨"r", none⟩

theorem pA_ne_rA : pA ≠ rA := by simp [pA, rA]

/-- `p` at the pending state, `r` at the idle one. -/
def labB : Bool → Atom → Bool := fun q a => if a = pA then q else if a = rA then !q else false

def M : TaskModel F.toTaskFrame := ladderModel stepB pendB fwdB bwdB labB

/-! ## The formula: `p U (r ∧ X(p ∧ X r))` with `X χ := ⊥ U χ` -/

def p : PlusFormula := .atom pA
def r : PlusFormula := .atom rA
def X (χ : PlusFormula) : PlusFormula := .untl .bot χ
def phi : PlusFormula := .untl p (r.and (X (p.and (X r))))

/-! ## Histories of `F` are offset ladder paths -/

theorem hist_path (σ : WorldHistory F) :
    ∃ (k : ℤ) (g : ℤ → LadderState Bool pendB),
      IsSlicedStepPath (RladAdm stepB pendB) k g ∧ σ.path = fun t => (t + k, g t) :=
  (ofSlicedStepFinBranch_mem_HF_iff (RladAdm stepB pendB) (RladAdm_fwd _ _) (RladAdm_bwd _ _)
    fwdB bwdB σ.path).mp ⟨σ, rfl⟩

theorem hist_of_path (k : ℤ) (g : ℤ → LadderState Bool pendB)
    (hg : IsSlicedStepPath (RladAdm stepB pendB) k g) :
    ∃ σ : WorldHistory F, σ.path = fun t => (t + k, g t) :=
  (ofSlicedStepFinBranch_mem_HF_iff (RladAdm stepB pendB) (RladAdm_fwd _ _) (RladAdm_bwd _ _)
    fwdB bwdB _).mpr ⟨k, g, hg, rfl⟩

/-! ## Truth of the letters and of `X` along a history -/

section Along
variable {σ : WorldHistory F} {k : ℤ} {g : ℤ → LadderState Bool pendB}
  (hσ : σ.path = fun t => (t + k, g t))
include hσ

theorem state_eq (s : ℤ) : σ.state s = (s + k, g s) := congrFun hσ s

theorem truth_p (s : ℤ) : PlusTruthAt M σ s p ↔ (g s).1.1 = true := by
  show M.valuation (σ.state s) pA ↔ _
  rw [state_eq hσ s]
  simp [M, ladderModel, labB]

theorem truth_r (s : ℤ) : PlusTruthAt M σ s r ↔ (g s).1.1 = false := by
  show M.valuation (σ.state s) rA ↔ _
  rw [state_eq hσ s]
  simp [M, ladderModel, labB, pA_ne_rA.symm]

end Along

theorem truth_X (σ : WorldHistory F) (s : ℤ) (χ : PlusFormula) :
    PlusTruthAt M σ s (X χ) ↔ PlusTruthAt M σ (s + 1) χ := by
  constructor
  · rintro ⟨(s' : ℤ), hlt, hχ, hgap⟩
    have hlt' : (s : ℤ) < s' := hlt
    have hs' : s' = s + 1 := by
      by_contra hne
      exact hgap (s + 1) (show (s : ℤ) < s + 1 by omega) (show (s + 1 : ℤ) < s' by omega)
    rw [hs'] at hχ
    exact hχ
  · intro h
    refine ⟨s + 1, show (s : ℤ) < s + 1 by omega, h, fun (r' : ℤ) h1 h2 => ?_⟩
    have h1' : (s : ℤ) < r' := h1
    have h2' : (r' : ℤ) < s + 1 := h2
    omega

/-! ## The negative half: every history through `(a, B, B+2)` refutes `phi` at `0` -/

section Neg
variable {g : ℤ → LadderState Bool pendB} (hg : ∀ t, Rlad stepB pendB t (g t).1 (g (t + 1)).1)
include hg

/-- Forward determinism while pending: the countdown runs to `0` at `B`, and `n` drifts by at
most one per step. -/
theorem pending_run (B n₀ : ℕ) (h0 : (g 0).1 = (true, B, n₀)) :
    ∀ i : ℕ, i ≤ B →
      (g i).1.1 = true ∧ (g i).1.2.1 = B - i ∧ n₀ ≤ (g i).1.2.2 + i := by
  intro i
  induction i with
  | zero =>
    intro _
    rw [Nat.cast_zero, h0]
    refine ⟨rfl, ?_, ?_⟩ <;> simp
  | succ i ih =>
    intro hi
    obtain ⟨hq, hc, hn⟩ := ih (by omega)
    have hstep := (rlad_iff _ _ _).mp (hg i)
    obtain ⟨-, hd, hcount⟩ := hstep
    rw [show ((i : ℤ) + 1) = ((i + 1 : ℕ) : ℤ) by push_cast; rfl] at hd hcount
    rw [hq] at hcount
    simp only [Drift] at hd
    cases hy : (g ((i + 1 : ℕ) : ℤ)).1.1 with
    | false =>
      rw [hy, count_tf] at hcount
      omega
    | true =>
      rw [hy, count_tt] at hcount
      refine ⟨rfl, ?_, ?_⟩ <;> omega

/-- At `B` the countdown is `0`, so `B + 1` is idle with `c = 0`, and its `n` is at least
`n₀ - (B + 1)`. -/
theorem idle_at (B n₀ : ℕ) (h0 : (g 0).1 = (true, B, n₀)) :
    (g ((B + 1 : ℕ) : ℤ)).1.1 = false ∧ (g ((B + 1 : ℕ) : ℤ)).1.2.1 = 0 ∧
      n₀ ≤ (g ((B + 1 : ℕ) : ℤ)).1.2.2 + (B + 1) := by
  obtain ⟨hq, hc, hn⟩ := pending_run hg B n₀ h0 B le_rfl
  have hstep := (rlad_iff _ _ _).mp (hg B)
  obtain ⟨-, hd, hcount⟩ := hstep
  rw [show ((B : ℤ) + 1) = ((B + 1 : ℕ) : ℤ) by push_cast; rfl] at hd hcount
  rw [hq, hc, Nat.sub_self] at hcount
  simp only [Drift] at hd
  cases hy : (g ((B + 1 : ℕ) : ℤ)).1.1 with
  | false =>
    rw [hy, count_tf] at hcount
    refine ⟨rfl, hcount.1, ?_⟩
    omega
  | true =>
    rw [hy, count_tt] at hcount
    omega

/-- After an idle state with `1 ≤ n`, the next state is idle or pending with `1 ≤ c`. -/
theorem after_idle (t : ℤ) (hidle : (g t).1.1 = false) (hn : 1 ≤ (g t).1.2.2) :
    (g (t + 1)).1.1 = false ∨ ((g (t + 1)).1.1 = true ∧ 1 ≤ (g (t + 1)).1.2.1) := by
  have hstep := (rlad_iff _ _ _).mp (hg t)
  obtain ⟨-, -, hcount⟩ := hstep
  rw [hidle] at hcount
  cases hy : (g (t + 1)).1.1 with
  | false => exact Or.inl rfl
  | true =>
    rw [hy, count_ft] at hcount
    exact Or.inr ⟨rfl, by omega⟩

/-- A pending state with `1 ≤ c` is followed by a pending state. -/
theorem after_pending (t : ℤ) (hp : (g t).1.1 = true) (hc : 1 ≤ (g t).1.2.1) :
    (g (t + 1)).1.1 = true := by
  have hstep := (rlad_iff _ _ _).mp (hg t)
  obtain ⟨-, -, hcount⟩ := hstep
  rw [hp] at hcount
  cases hy : (g (t + 1)).1.1 with
  | false =>
    rw [hy, count_tf] at hcount
    omega
  | true => rfl

end Neg

theorem not_phi_of_gap_two (σ : WorldHistory F) (k : ℤ) (g : ℤ → LadderState Bool pendB)
    (hσ : σ.path = fun t => (t + k, g t))
    (hg : IsSlicedStepPath (RladAdm stepB pendB) k g) (B : ℕ)
    (h0 : (g 0).1 = (true, B, B + 2)) : ¬ PlusTruthAt M σ 0 phi := by
  have hg' : ∀ t, Rlad stepB pendB t (g t).1 (g (t + 1)).1 := fun t => hg t
  rintro ⟨(s : ℤ), hs, hχ, hguard⟩
  have hs' : (0 : ℤ) < s := hs
  rw [PlusTruth.and_iff, truth_r hσ] at hχ
  obtain ⟨hr, hX⟩ := hχ
  rcases lt_trichotomy s ((B + 1 : ℕ) : ℤ) with hlt | heq | hgt
  · -- `0 < s ≤ B`: the state at `s` is pending, so `r` fails there
    have hsn : ((s.toNat : ℕ) : ℤ) = s := Int.toNat_of_nonneg (by omega)
    have hle : s.toNat ≤ B := by omega
    obtain ⟨hq, -, -⟩ := pending_run hg' B (B + 2) h0 s.toNat hle
    rw [← hsn] at hr
    rw [hr] at hq
    exact Bool.false_ne_true hq
  · -- `s = B + 1`: the next region has length at least two
    subst heq
    rw [truth_X, PlusTruth.and_iff, truth_p hσ, truth_X, truth_r hσ] at hX
    obtain ⟨hp2, hr3⟩ := hX
    obtain ⟨hidle, -, hn⟩ := idle_at hg' B (B + 2) h0
    rcases after_idle hg' _ hidle (by omega) with h | ⟨-, hc⟩
    · rw [h] at hp2
      exact Bool.false_ne_true hp2
    · have := after_pending hg' _ hp2 hc
      rw [this] at hr3
      exact Bool.noConfusion hr3
  · -- `s > B + 1`: the guard `p` fails at the idle state `B + 1`
    have hp := hguard ((B + 1 : ℕ) : ℤ) (show (0 : ℤ) < ((B + 1 : ℕ) : ℤ) by omega) hgt
    rw [truth_p hσ] at hp
    obtain ⟨hidle, -, -⟩ := idle_at hg' B (B + 2) h0
    rw [hidle] at hp
    exact Bool.false_ne_true hp

/-! ## The positive half: a history through `(a, B, B+1)` whose next region has length one -/

/-- The future from time `0`: the current region `(true, B - m, B + 1 - m)` for `m ≤ B`, one
idle, a region of length one, then idle forever. -/
def futPos (B : ℕ) (m : ℕ) : Bool × ℕ × ℕ :=
  if m ≤ B then (true, B - m, B + 1 - m)
  else if m = B + 1 then (false, 0, 0)
  else if m = B + 2 then (true, 0, 0)
  else (false, 0, 0)

/-- The whole path: idle with `n = B` before `0`, `futPos` from `0` on. -/
def gPos (B : ℕ) (t : ℤ) : Bool × ℕ × ℕ := if t < 0 then (false, 0, B) else futPos B t.toNat

theorem futPos_adm (B m : ℕ) : (futPos B m).1 = false → (futPos B m).2.1 = 0 := by
  unfold futPos
  split_ifs <;> simp

theorem gPos_adm (B : ℕ) (t : ℤ) : (gPos B t).2.1 ∈ Adm pendB (gPos B t).1 := by
  show (gPos B t).1 = false → (gPos B t).2.1 = 0
  unfold gPos
  split_ifs with h
  · simp
  · exact futPos_adm B t.toNat

def gPosA (B : ℕ) (t : ℤ) : LadderState Bool pendB := ⟨gPos B t, gPos_adm B t⟩

theorem futPos_step (B m : ℕ) : Rlad stepB pendB 0 (futPos B m) (futPos B (m + 1)) := by
  rw [rlad_iff]
  unfold futPos
  split_ifs <;> simp [Drift, Count] <;> omega

theorem gPos_isPath (B : ℕ) : IsSlicedStepPath (RladAdm stepB pendB) 0 (gPosA B) := by
  intro t
  show Rlad stepB pendB (t + 0) (gPos B t) (gPos B (t + 1))
  have hT : ∀ t', Rlad stepB pendB (t + 0) (gPos B t) (gPos B t') ↔
      Rlad stepB pendB 0 (gPos B t) (gPos B t') := fun _ => Iff.rfl
  rw [hT]
  rcases lt_trichotomy t (-1) with hlt | heq | hgt
  · have h1 : t < 0 := by omega
    have h2 : t + 1 < 0 := by omega
    simp only [gPos, h1, h2, if_true]
    rw [rlad_iff]
    simp [Drift, Count]
  · subst heq
    simp only [gPos, show (-1 : ℤ) < 0 by norm_num, show ¬ ((-1 : ℤ) + 1 < 0) by norm_num,
      if_true, if_false, show ((-1 : ℤ) + 1).toNat = 0 by rfl]
    rw [rlad_iff]
    simp [futPos, Drift, Count]
  · have h1 : ¬ t < 0 := by omega
    have h2 : ¬ t + 1 < 0 := by omega
    simp only [gPos, h1, h2, if_false]
    rw [show (t + 1).toNat = t.toNat + 1 by omega]
    exact futPos_step B t.toNat

theorem gPos_natCast (B m : ℕ) : gPos B (m : ℤ) = futPos B m := by
  simp [gPos]

theorem phi_pos (σ : WorldHistory F) (B : ℕ) (hσ : σ.path = fun t => (t + 0, gPosA B t)) :
    PlusTruthAt M σ 0 phi := by
  refine ⟨((B + 1 : ℕ) : ℤ), show (0 : ℤ) < ((B + 1 : ℕ) : ℤ) by omega, ?_, ?_⟩
  · rw [PlusTruth.and_iff, truth_r hσ, truth_X, PlusTruth.and_iff, truth_p hσ, truth_X,
      truth_r hσ]
    rw [show ((B + 1 : ℕ) : ℤ) + 1 = ((B + 2 : ℕ) : ℤ) by push_cast; ring,
      show ((B + 2 : ℕ) : ℤ) + 1 = ((B + 3 : ℕ) : ℤ) by push_cast; ring]
    simp only [gPosA, gPos_natCast, futPos]
    simp
  · intro (s' : ℤ) h1 h2
    have h1' : (0 : ℤ) < s' := h1
    have h2' : s' < ((B + 1 : ℕ) : ℤ) := h2
    rw [truth_p hσ]
    have hsn : ((s'.toNat : ℕ) : ℤ) = s' := Int.toNat_of_nonneg (by omega)
    have hle : s'.toNat ≤ B := by omega
    rw [← hsn]
    simp only [gPosA, gPos_natCast, futPos, hle, if_true]

/-! ## The refutation -/

def w1 (B : ℕ) : F.WorldState := ((0 : ℤ), gPosA B 0)

theorem gPosA_zero (B : ℕ) : (gPosA B 0).1 = (true, B, B + 1) := by
  simp [gPosA, gPos, futPos]

def w2 (B : ℕ) : F.WorldState :=
  ((0 : ℤ), ⟨(true, B, B + 2), fun h => by cases h⟩)

/-- Every type realized at `(a, B, B + 2)` omits `phi`. -/
theorem phi_not_mem_of_mem_cell₂ (B : ℕ) (T : Finset PlusFormula)
    (hT : T ∈ cellAt M phi (w2 B) 0) : phi ∉ T := by
  obtain ⟨σ, hσz, rfl⟩ := hT
  obtain ⟨k, g, hg, hpath⟩ := hist_path σ
  have hst : ((0 : ℤ) + k, g 0) = w2 B := by
    rw [← hσz]
    exact (congrFun hpath 0).symm
  have hg0' : (g 0).1 = (true, B, B + 2) :=
    congrArg (fun w : ℤ × LadderState Bool pendB => w.2.1) hst
  intro hmem
  rw [mem_tpOf_iff] at hmem
  exact not_phi_of_gap_two σ k g hpath hg B hg0' hmem.2

/-- Some type realized at `(a, B, B + 1)` contains `phi`. -/
theorem exists_phi_mem_cell₁ (B : ℕ) :
    ∃ T ∈ cellAt M phi (w1 B) 0, phi ∈ T := by
  obtain ⟨σ, hσ⟩ := hist_of_path 0 (gPosA B) (gPos_isPath B)
  refine ⟨tpOf M phi σ 0, ⟨σ, ?_, rfl⟩, ?_⟩
  · exact congrFun hσ 0
  · rw [mem_tpOf_iff]
    exact ⟨self_mem_plusSubformulaClosure phi, phi_pos σ B hσ⟩

/-- **The refutation, uniform in `B`**: the cells at `(a, B, B + 1)` and `(a, B, B + 2)` differ,
although all four counters are `≥ B`. In particular they differ at `B = |cl phi|`. -/
theorem cell_ne (B : ℕ) : cellAt M phi (w1 B) 0 ≠ cellAt M phi (w2 B) 0 := by
  intro heq
  obtain ⟨T, hT, hmem⟩ := exists_phi_mem_cell₁ B
  rw [heq] at hT
  exact phi_not_mem_of_mem_cell₂ B T hT hmem

theorem w1_eq (B : ℕ) :
    w1 B = ((0 : ℤ), ⟨(true, B, B + 1), fun h => by cases h⟩) :=
  Prod.ext rfl (Subtype.ext (gPosA_zero B))

/-- The dispatch's exhibited-bound form, instantiated at this object and `q = a`, with the
counters `(c, n) = (B, B + 1)` and `(c', n') = (B, B + 2)`, `B = |cl phi|`: all four hypotheses
hold and the conclusion fails. -/
theorem exhibited_form_refuted :
    ¬ ∀ (c c' n n' : ℕ), (plusSubformulaClosure phi).card ≤ c →
      (plusSubformulaClosure phi).card ≤ c' → (plusSubformulaClosure phi).card ≤ n →
      (plusSubformulaClosure phi).card ≤ n' →
      ∀ (hc : c ∈ Adm pendB true) (hc' : c' ∈ Adm pendB true),
        cellAt M phi ((0 : ℤ), ⟨(true, c, n), hc⟩) 0 =
          cellAt M phi ((0 : ℤ), ⟨(true, c', n'), hc'⟩) 0 := by
  intro h
  have := h (plusSubformulaClosure phi).card (plusSubformulaClosure phi).card
    ((plusSubformulaClosure phi).card + 1) ((plusSubformulaClosure phi).card + 2)
    le_rfl le_rfl (by omega) (by omega) (fun h => by cases h) (fun h => by cases h)
  apply cell_ne (plusSubformulaClosure phi).card
  rw [w1_eq]
  exact this

/-- The `∃ B` fallback form is refuted too: the witness is uniform in `B`. -/
theorem exists_form_refuted :
    ¬ ∃ B : ℕ, ∀ (c c' n n' : ℕ), B ≤ c → B ≤ c' → B ≤ n → B ≤ n' →
      ∀ (hc : c ∈ Adm pendB true) (hc' : c' ∈ Adm pendB true),
        cellAt M phi ((0 : ℤ), ⟨(true, c, n), hc⟩) 0 =
          cellAt M phi ((0 : ℤ), ⟨(true, c', n'), hc'⟩) 0 := by
  rintro ⟨B, h⟩
  have := h B B (B + 1) (B + 2) le_rfl le_rfl (by omega) (by omega)
    (fun h => by cases h) (fun h => by cases h)
  apply cell_ne B
  rw [w1_eq]
  exact this


/-! ## TEST A — the gap's one-step arithmetic (settles the recorded drift risk) -/

/-- **During a pending region the gap is non-decreasing and grows by at most two per step.**
`Count true true` forces the countdown down by exactly one (`c' + 1 = c`) while `Drift` moves the
next deadline by at most one, so `n - c` can only stay put or rise. Over a region of length `c₀`
the gap therefore reaches up to `g₀ + 2·c₀`, and `c₀` is unbounded on the carrier: the gap is
UNBOUNDED along runs. General in the object -- no fixture. -/
theorem gap_step_pending {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (t : ℤ) (x y : Q × ℕ × ℕ) (hx : pend x.1 = true) (hy : pend y.1 = true)
    (h : Rlad step pend t x y) :
    ((y.2.2 : ℤ) - (y.2.1 : ℤ)) = ((x.2.2 : ℤ) - (x.2.1 : ℤ))
    ∨ ((y.2.2 : ℤ) - (y.2.1 : ℤ)) = ((x.2.2 : ℤ) - (x.2.1 : ℤ)) + 1
    ∨ ((y.2.2 : ℤ) - (y.2.1 : ℤ)) = ((x.2.2 : ℤ) - (x.2.1 : ℤ)) + 2 := by
  obtain ⟨-, -, hd, hcount⟩ := h
  rw [hx, hy, count_tt] at hcount
  simp only [Drift] at hd
  omega

/-! ## TEST B — the refuting formula is BLIND among gaps ≥ 2

The decisive question for the gap-carrying index: does `phi` separate gap `j` from gap `j+1` for
arbitrarily large `j`?  If it did, no clipped gap coordinate could work either and the
sub-problem would be deeper than three coordinates.  It does not. -/

/-- The gap-`j` world state, generalising `w2` (which is `j = 2`). -/
def wj (B j : ℕ) : F.WorldState :=
  ((0 : ℤ), ⟨(true, B, B + j), fun h => by cases h⟩)

theorem wj_two (B : ℕ) : wj B 2 = w2 B := rfl

/-- **`not_phi_of_gap_two` generalises to EVERY gap `≥ 2`**, with the same proof: the region still
runs to `0` at `B`, the idle state at `B + 1` still carries `1 ≤ n` (now because `2 ≤ j`), and the
next region still has length at least two, so `r ∧ X(p ∧ X r)` fails at the seam. -/
theorem not_phi_of_gap_ge_two (σ : WorldHistory F) (k : ℤ) (g : ℤ → LadderState Bool pendB)
    (hσ : σ.path = fun t => (t + k, g t))
    (hg : IsSlicedStepPath (RladAdm stepB pendB) k g) (B j : ℕ) (hj : 2 ≤ j)
    (h0 : (g 0).1 = (true, B, B + j)) : ¬ PlusTruthAt M σ 0 phi := by
  have hg' : ∀ t, Rlad stepB pendB t (g t).1 (g (t + 1)).1 := fun t => hg t
  rintro ⟨(s : ℤ), hs, hχ, hguard⟩
  have hs' : (0 : ℤ) < s := hs
  rw [PlusTruth.and_iff, truth_r hσ] at hχ
  obtain ⟨hr, hX⟩ := hχ
  rcases lt_trichotomy s ((B + 1 : ℕ) : ℤ) with hlt | heq | hgt
  · have hsn : ((s.toNat : ℕ) : ℤ) = s := Int.toNat_of_nonneg (by omega)
    have hle : s.toNat ≤ B := by omega
    obtain ⟨hq, -, -⟩ := pending_run hg' B (B + j) h0 s.toNat hle
    rw [← hsn] at hr
    rw [hr] at hq
    exact Bool.false_ne_true hq
  · subst heq
    rw [truth_X, PlusTruth.and_iff, truth_p hσ, truth_X, truth_r hσ] at hX
    obtain ⟨hp2, hr3⟩ := hX
    obtain ⟨hidle, -, hn⟩ := idle_at hg' B (B + j) h0
    rcases after_idle hg' _ hidle (by omega) with h | ⟨-, hc⟩
    · rw [h] at hp2
      exact Bool.false_ne_true hp2
    · have := after_pending hg' _ hp2 hc
      rw [this] at hr3
      exact Bool.noConfusion hr3
  · have hp := hguard ((B + 1 : ℕ) : ℤ) (show (0 : ℤ) < ((B + 1 : ℕ) : ℤ) by omega) hgt
    rw [truth_p hσ] at hp
    obtain ⟨hidle, -, -⟩ := idle_at hg' B (B + j) h0
    rw [hidle] at hp
    exact Bool.false_ne_true hp

/-- Every type realized at gap `≥ 2` omits `phi`. -/
theorem phi_not_mem_of_mem_cellj (B j : ℕ) (hj : 2 ≤ j) (T : Finset PlusFormula)
    (hT : T ∈ cellAt M phi (wj B j) 0) : phi ∉ T := by
  obtain ⟨σ, hσz, rfl⟩ := hT
  obtain ⟨k, g, hg, hpath⟩ := hist_path σ
  have hst : ((0 : ℤ) + k, g 0) = wj B j := by
    rw [← hσz]
    exact (congrFun hpath 0).symm
  have hg0' : (g 0).1 = (true, B, B + j) :=
    congrArg (fun w : ℤ × LadderState Bool pendB => w.2.1) hst
  intro hmem
  rw [mem_tpOf_iff] at hmem
  exact not_phi_of_gap_ge_two σ k g hpath hg B j hj hg0' hmem.2

/-- **`phi` IS blind among gaps `≥ 2`**: for any two gaps `j, j' ≥ 2`, `phi` sits in a type
realized at gap `j` exactly when it sits in one realized at gap `j'` -- namely never.  So the
mechanism behind `cell_ne` does NOT iterate upward: it separates gap 1 from gap `≥ 2` and makes
no finer distinction above 2.  The two-coordinate index failed by destroying a SMALL gap at large
counters, not by any unboundedness of the gap itself. -/
theorem phi_blind_above_two (B j j' : ℕ) (hj : 2 ≤ j) (hj' : 2 ≤ j')
    (T T' : Finset PlusFormula)
    (hT : T ∈ cellAt M phi (wj B j) 0) (hT' : T' ∈ cellAt M phi (wj B j') 0) :
    (phi ∈ T) ↔ (phi ∈ T') := by
  simp [phi_not_mem_of_mem_cellj B j hj T hT, phi_not_mem_of_mem_cellj B j' hj' T' hT']

/-- The gap-`1` cell still differs from every gap-`≥ 2` cell (the refutation, restated at
general `j`): the separation is real, it is just confined to the small gaps. -/
theorem cell_ne_gap_ge_two (B j : ℕ) (hj : 2 ≤ j) :
    cellAt M phi (w1 B) 0 ≠ cellAt M phi (wj B j) 0 := by
  intro heq
  obtain ⟨T, hT, hmem⟩ := exists_phi_mem_cell₁ B
  rw [heq] at hT
  exact phi_not_mem_of_mem_cellj B j hj T hT hmem

/-! ## TEST C — the countdown never escapes the deadlines already present

The second candidate route: instead of INDEXING an infinite carrier, BOUND it.  These two facts
say the only way either counter can grow is `Drift`'s `n' = n + 1` -- the countdown `c` is always
dominated by the counters already in hand.  So the sub-carrier `n ≤ N ∧ c ≤ N` is closed under
`Rlad` whenever drift stays in range (and drift can always choose `n' = n`), which would make the
carrier a genuine `Fintype` with no index needed at all. -/

/-- **The countdown is dominated by the current counters.**  Pending→pending decrements it,
a region start copies `n`, and an idle target zeroes it: in every case `c' ≤ max c n`. -/
theorem count_le_max (px py : Bool) (c n c' : ℕ) (h : Count px py c n c') : c' ≤ max c n := by
  unfold Count at h
  split_ifs at h <;> omega

/-- **The bounded sub-carrier is closed under `Rlad`**: if both counters start `≤ N` and drift
keeps the next deadline `≤ N`, the successor's countdown is `≤ N` too.  Nothing in the relation
can push `c` above the bound on its own. -/
theorem rlad_counters_bdd {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (N : ℕ)
    (t : ℤ) (x y : Q × ℕ × ℕ) (h : Rlad step pend t x y)
    (hc : x.2.1 ≤ N) (hn : x.2.2 ≤ N) : y.2.1 ≤ N := by
  obtain ⟨-, -, -, hcount⟩ := h
  have := count_le_max _ _ _ _ _ hcount
  omega

/-- **Drift can always stand still**, so bounding `n` never obstructs the next-deadline clause:
the bound is compatible with the relation rather than fighting it. -/
theorem drift_refl (n : ℕ) : Drift n n := Or.inl rfl

end GapIndexTest
