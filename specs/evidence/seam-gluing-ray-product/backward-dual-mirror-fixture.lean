/-
Probe 733: **the backward dual of the finite-graph `⊡` summary on the MIRROR fixture** —
time-asymmetric AND backward-NONDETERMINISTIC (E1's hard test). Provisional header; the full
collection-style header is written in the next phase.

Compile-check from the repository root with:
  lake env lean specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability

namespace Probe733Mirror

def pa : Atom := ⟨"p", none⟩
def p : PlusFormula := PlusFormula.atom pa
def Pp : PlusFormula := PlusFormula.somePast p
def stabPast : PlusFormula := PlusFormula.stab Pp

/-! ## The mirror fixture: Probe710's step graph with every arrow reversed -/

/-- States: `bef k j` (`j + 1` steps before `x k`), `x k` (the `p` state of thread `k`), `aft k`
(the shared forward spine; `aft k` is reached one step after `x k` and one step after `aft (k-1)`). -/
inductive Node : Type
  | bef : ℕ → ℕ → Node
  | x : ℕ → Node
  | aft : ℕ → Node
  deriving DecidableEq

instance : Nonempty Node := ⟨.x 0⟩

/-- The one-step relation: every state has EXACTLY ONE successor and one or TWO predecessors. -/
inductive Step : Node → Node → Prop
  | befNext (k j : ℕ) : Step (.bef k (j + 1)) (.bef k j)
  | befX (k : ℕ) : Step (.bef k 0) (.x k)
  | xAft (k : ℕ) : Step (.x k) (.aft k)
  | aftUp (k : ℕ) : Step (.aft k) (.aft (k + 1))

/-! ### Forward inverses: forward determinism -/

theorem step_bef_inv {k j : ℕ} {u : Node} (h : Step (.bef k j) u) :
    (j = 0 ∧ u = .x k) ∨ ∃ j', j = j' + 1 ∧ u = .bef k j' := by
  cases h with
  | befNext _ j' => exact Or.inr ⟨j', rfl, rfl⟩
  | befX _ => exact Or.inl ⟨rfl, rfl⟩

theorem step_x_inv {k : ℕ} {u : Node} (h : Step (.x k) u) : u = .aft k := by
  cases h; rfl

theorem step_aft_inv {k : ℕ} {u : Node} (h : Step (.aft k) u) : u = .aft (k + 1) := by
  cases h; rfl

/-! ### Backward inverses: the branching lives at `aft (k + 1)` -/

theorem step_inv_bef {v : Node} {k j : ℕ} (h : Step v (.bef k j)) : v = .bef k (j + 1) := by
  cases h; rfl

theorem step_inv_x {v : Node} {k : ℕ} (h : Step v (.x k)) : v = .bef k 0 := by
  cases h; rfl

theorem step_inv_aft {v : Node} {k : ℕ} (h : Step v (.aft k)) :
    v = .x k ∨ ∃ k', k = k' + 1 ∧ v = .aft k' := by
  cases h with
  | xAft _ => exact Or.inl rfl
  | aftUp k' => exact Or.inr ⟨k', rfl, rfl⟩

theorem step_fwd (w : Node) : ∃ u, Step w u := by
  cases w with
  | bef k j =>
    cases j with
    | zero => exact ⟨_, Step.befX k⟩
    | succ j => exact ⟨_, Step.befNext k j⟩
  | x k => exact ⟨_, Step.xAft k⟩
  | aft k => exact ⟨_, Step.aftUp k⟩

theorem step_bwd (w : Node) : ∃ v, Step v w := by
  cases w with
  | bef k j => exact ⟨_, Step.befNext k j⟩
  | x k => exact ⟨_, Step.befX k⟩
  | aft k => exact ⟨_, Step.xAft k⟩

/-! ### The backward branching factor, stated explicitly -/

/-- Successors, as a list — a SINGLETON at every node (forward determinism). -/
def fwdList : Node → List Node
  | .bef k 0 => [.x k]
  | .bef k (j + 1) => [.bef k j]
  | .x k => [.aft k]
  | .aft k => [.aft (k + 1)]

/-- Predecessors, as a list — TWO entries at every `aft (k + 1)`, one elsewhere. -/
def bwdList : Node → List Node
  | .bef k j => [.bef k (j + 1)]
  | .x k => [.bef k 0]
  | .aft 0 => [.x 0]
  | .aft (k + 1) => [.aft k, .x (k + 1)]

theorem mem_fwdList {w u : Node} (h : Step w u) : u ∈ fwdList w := by
  cases h with
  | befNext k j => simp [fwdList]
  | befX k => simp [fwdList]
  | xAft k => simp [fwdList]
  | aftUp k => simp [fwdList]

theorem mem_bwdList {v w : Node} (h : Step v w) : v ∈ bwdList w := by
  cases h with
  | befNext k j => simp [bwdList]
  | befX k => simp [bwdList]
  | xAft k => cases k <;> simp [bwdList]
  | aftUp k => simp [bwdList]

/-- Backward branching factor 2 at every `aft (k + 1)`. -/
theorem bwdList_aft_succ_length (k : ℕ) : (bwdList (.aft (k + 1))).length = 2 := rfl

/-- The two predecessors of `aft (k + 1)` are distinct `Step`-predecessors. -/
theorem two_preds_aft (k : ℕ) :
    Step (.aft k) (.aft (k + 1)) ∧ Step (.x (k + 1)) (.aft (k + 1)) ∧
      (Node.aft k ≠ Node.x (k + 1)) :=
  ⟨Step.aftUp k, Step.xAft (k + 1), fun h => by cases h⟩

theorem fwd_finite (w : Node) : {u | Step w u}.Finite :=
  (List.finite_toSet (fwdList w)).subset fun _ hu => mem_fwdList hu

theorem bwd_finite (w : Node) : {v | Step v w}.Finite :=
  (List.finite_toSet (bwdList w)).subset fun _ hv => mem_bwdList hv

theorem iter_fwd_finite (n : ℕ) (w : Node) : {u | iter Step n w u}.Finite := by
  induction n with
  | zero =>
    refine (Set.finite_singleton w).subset fun u hu => ?_
    have : w = u := hu
    simp [this]
  | succ n ih =>
    refine (ih.biUnion fun v _ => fwd_finite v).subset fun u hu => ?_
    obtain ⟨v, hv, hvu⟩ := hu
    exact Set.mem_biUnion (x := v) hv hvu

theorem iter_bwd_finite (n : ℕ) (w : Node) : {v | iter Step n v w}.Finite := by
  induction n generalizing w with
  | zero =>
    refine (Set.finite_singleton w).subset fun v hv => ?_
    have : v = w := hv
    simp [this]
  | succ n ih =>
    refine ((bwd_finite w).biUnion fun v' _ => ih v').subset fun v hv => ?_
    obtain ⟨v', hv', hv'w⟩ := hv
    exact Set.mem_biUnion (x := v') hv'w hv'

theorem fib_finite (w : Node) (d : ℤ) : (TaskFrame.Fib (ofStepRel Step) w d).Finite := by
  rcases le_or_gt 0 d with hd | hd
  · refine (iter_fwd_finite d.natAbs w).subset fun u hu => ?_
    exact (ofStepRel_of_nonneg hd w u).mp hu
  · refine (iter_bwd_finite d.natAbs w).subset fun u hu => ?_
    exact (ofStepRel_of_nonpos hd.le w u).mp hu

def F : FrameOver intOrder :=
  FrameOver.ofReflectiveRegular Node (ofStepRel Step)
    (fun w d u => by
      constructor
      · rintro ⟨h1, h2⟩
        exact ⟨fun hd => by simpa [Int.natAbs_neg] using h2 (by omega),
               fun hd => by simpa [Int.natAbs_neg] using h1 (by omega)⟩
      · rintro ⟨h1, h2⟩
        exact ⟨fun hd => by simpa [Int.natAbs_neg] using h2 (by omega),
               fun hd => by simpa [Int.natAbs_neg] using h1 (by omega)⟩)
    (fun w v x y hx hy => by
      change (0 : ℤ) ≤ x at hx
      change (0 : ℤ) ≤ y at hy
      rw [ofStepRel_of_nonneg (add_nonneg hx hy)]
      have hnat : (x + y).natAbs = x.natAbs + y.natAbs := by omega
      rw [hnat, iter_add]
      exact exists_congr fun u => by
        rw [ofStepRel_of_nonneg hx, ofStepRel_of_nonneg hy])
    (fun w x hx => by
      constructor
      · obtain ⟨u, hu⟩ := exists_iter_fwd step_fwd x.natAbs w
        exact ⟨u, (ofStepRel_of_nonneg hx w u).mpr hu⟩
      · obtain ⟨v, hv⟩ := exists_iter_bwd step_bwd x.natAbs w
        exact ⟨v, (ofStepRel_of_nonneg hx v w).mpr hv⟩)
    (TaskFrame.limit_of_succOrder fun w u h => by
      rw [ofStepRel_of_nonneg (le_refl (0 : ℤ))] at h
      simpa [eq_comm] using h)
    (TaskFrame.saturation_of_fib_finite fib_finite)

instance F_isRegular : F.IsRegular := FrameOver.instIsRegularOfReflective _ _ _ _ _ _ _

theorem F_taskRel : F.TaskRel = ofStepRel Step := FrameOver.ofReflectiveRegular_taskRel_eq

theorem F_step (w u : Node) : F.step w u ↔ Step w u := by
  change F.TaskRel w 1 u ↔ _
  rw [F_taskRel, ofStepRel_of_nonneg (zero_le_one : (0 : ℤ) ≤ 1)]
  exact iter_one Step w u

def M : TaskModel F.toTaskFrame := ⟨fun w _ => ∃ k, w = Node.x k⟩

/-! ### Every step path is canonical -/

/-- The bi-infinite step path of thread `k` with `x k` at time `t`:
`… bef k 1, bef k 0, x k, aft k, aft (k+1), …`. -/
def canon (k : ℕ) (t : ℤ) (s : ℤ) : Node :=
  if s < t then .bef k (t - 1 - s).toNat
  else if s = t then .x k
  else .aft (k + (s - t - 1).toNat)

theorem canon_of_lt {k : ℕ} {t s : ℤ} (h : s < t) : canon k t s = .bef k (t - 1 - s).toNat := by
  simp [canon, h]

theorem canon_self (k : ℕ) (t : ℤ) : canon k t t = .x k := by
  simp [canon]

theorem canon_of_gt {k : ℕ} {t s : ℤ} (h : t < s) :
    canon k t s = .aft (k + (s - t - 1).toNat) := by
  simp [canon, not_lt.mpr h.le, h.ne']

theorem canon_step (k : ℕ) (t s : ℤ) : Step (canon k t s) (canon k t (s + 1)) := by
  rcases lt_trichotomy (s + 1) t with h1 | h1 | h1
  · rw [canon_of_lt (by omega), canon_of_lt h1]
    have e : (t - 1 - s).toNat = (t - 1 - (s + 1)).toNat + 1 := by omega
    rw [e]
    exact Step.befNext _ _
  · rw [canon_of_lt (by omega), h1, canon_self]
    have e : (t - 1 - s).toNat = 0 := by omega
    rw [e]
    exact Step.befX k
  · rcases lt_trichotomy s t with h2 | h2 | h2
    · omega
    · subst h2
      rw [canon_self, canon_of_gt (by omega)]
      have e : (s + 1 - s - 1).toNat = 0 := by omega
      rw [e, Nat.add_zero]
      exact Step.xAft k
    · rw [canon_of_gt h2, canon_of_gt (by omega)]
      have e : (s + 1 - t - 1).toNat = (s - t - 1).toNat + 1 := by omega
      rw [e, ← Nat.add_assoc]
      exact Step.aftUp _

theorem canon_eq_x_iff {k k' : ℕ} {t s : ℤ} : canon k t s = .x k' ↔ s = t ∧ k = k' := by
  rcases lt_trichotomy s t with h | h | h
  · rw [canon_of_lt h]; simp; omega
  · subst h; rw [canon_self]; simp
  · rw [canon_of_gt h]; simp; omega

section Struct

variable {g : ℤ → Node} (hg : ∀ s, Step (g s) (g (s + 1)))
include hg

/-- Forward determinism: out of `x k` the path runs `aft k, aft (k+1), …`. -/
theorem fwd_from_x {t : ℤ} {k : ℕ} (ht : g t = .x k) (i : ℕ) : g (t + i + 1) = .aft (k + i) := by
  induction i with
  | zero =>
    have h := hg t
    rw [ht] at h
    simpa using step_x_inv h
  | succ i ih =>
    have h := hg (t + i + 1)
    rw [ih] at h
    have e : t + ((i + 1 : ℕ) : ℤ) + 1 = t + i + 1 + 1 := by push_cast; ring
    rw [e, step_aft_inv h, Nat.add_assoc]

/-- Backward determinism off the spine: into `x k` the path runs `…, bef k 1, bef k 0`. -/
theorem bwd_from_x {t : ℤ} {k : ℕ} (ht : g t = .x k) (i : ℕ) : g (t - i - 1) = .bef k i := by
  induction i with
  | zero =>
    have h := hg (t - 1)
    rw [show t - 1 + 1 = t by ring, ht] at h
    simpa using step_inv_x h
  | succ i ih =>
    have h := hg (t - i - 1 - 1)
    rw [show t - i - 1 - 1 + 1 = t - i - 1 by ring, ih] at h
    have e : t - ((i + 1 : ℕ) : ℤ) - 1 = t - i - 1 - 1 := by push_cast; ring
    rw [e]
    exact step_inv_bef h

/-- From `bef k j` the path reaches `x k` after exactly `j + 1` forward steps. -/
theorem bef_fwd {k : ℕ} (j : ℕ) : ∀ s, g s = .bef k j → g (s + j + 1) = .x k := by
  induction j with
  | zero =>
    intro s hs
    have h := hg s
    rw [hs] at h
    rcases step_bef_inv h with ⟨-, hu⟩ | ⟨j', hj', -⟩
    · simpa using hu
    · omega
  | succ j ih =>
    intro s hs
    have h := hg s
    rw [hs] at h
    rcases step_bef_inv h with ⟨hj, -⟩ | ⟨j', hj', hu⟩
    · omega
    · have hj'' : j' = j := by omega
      rw [hj''] at hu
      have := ih (s + 1) hu
      have e : s + ((j + 1 : ℕ) : ℤ) + 1 = s + 1 + j + 1 := by push_cast; ring
      rw [e]
      exact this

/-- From `aft m` the path reaches SOME `x` within `m + 1` backward steps — the two-way split at
every `aft (k+1)` is where the backward branching enters. -/
theorem aft_back (m : ℕ) : ∀ s, g s = .aft m → ∃ (i : ℕ) (k' : ℕ), g (s - i) = .x k' := by
  induction m with
  | zero =>
    intro s hs
    have h := hg (s - 1)
    rw [show s - 1 + 1 = s by ring, hs] at h
    rcases step_inv_aft h with hv | ⟨k', hk', -⟩
    · exact ⟨1, 0, by simpa using hv⟩
    · omega
  | succ m ih =>
    intro s hs
    have h := hg (s - 1)
    rw [show s - 1 + 1 = s by ring, hs] at h
    rcases step_inv_aft h with hv | ⟨k', hk', hv⟩
    · exact ⟨1, m + 1, by simpa using hv⟩
    · have hk'' : k' = m := by omega
      rw [hk''] at hv
      obtain ⟨i, k'', hi⟩ := ih (s - 1) hv
      refine ⟨i + 1, k'', ?_⟩
      rw [show s - ((i + 1 : ℕ) : ℤ) = s - 1 - i by push_cast; ring]
      exact hi

theorem exists_x : ∃ (t : ℤ) (k : ℕ), g t = .x k := by
  cases hx : g 0 with
  | bef k j => exact ⟨0 + j + 1, k, bef_fwd hg j 0 hx⟩
  | x k => exact ⟨0, k, hx⟩
  | aft m =>
    obtain ⟨i, k', hi⟩ := aft_back hg m 0 hx
    exact ⟨0 - i, k', hi⟩

/-- **Every step path is canonical.** -/
theorem path_eq_canon : ∃ (k : ℕ) (t : ℤ), ∀ s, g s = canon k t s := by
  obtain ⟨t, k, ht⟩ := exists_x hg
  refine ⟨k, t, fun s => ?_⟩
  rcases lt_trichotomy s t with h | h | h
  · rw [canon_of_lt h]
    have := bwd_from_x hg ht (t - 1 - s).toNat
    rw [show t - ((t - 1 - s).toNat : ℤ) - 1 = s by omega] at this
    exact this
  · subst h; rw [canon_self]; exact ht
  · rw [canon_of_gt h]
    have := fwd_from_x hg ht (s - t - 1).toNat
    rw [show t + ((s - t - 1).toNat : ℤ) + 1 = s by omega] at this
    exact this

end Struct

theorem hist_canon (σ : WorldHistory F.toTaskFrame) :
    ∃ (k : ℕ) (t : ℤ), ∀ s, σ.state s = canon k t s := by
  have hstep : IsStepPath F σ.path := (FrameOver.mem_HF_iff_adjacent F σ.path).mp ⟨σ, rfl⟩
  exact path_eq_canon fun s => (F_step _ _).mp (hstep s)

def histOf (k : ℕ) (t : ℤ) : WorldHistory F.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath F (canon k t) (fun s => (F_step _ _).mpr (canon_step k t s))

theorem histOf_state (k : ℕ) (t s : ℤ) : (histOf k t).state s = canon k t s :=
  congrFun (FrameOver.worldHistoryOfStepPath.path F (canon k t) _) s

section Truth

variable {σ : WorldHistory F.toTaskFrame} {k : ℕ} {t : ℤ} (hσ : ∀ s, σ.state s = canon k t s)
include hσ

theorem truth_p (s : ℤ) : PlusTruthAt M σ s p ↔ s = t := by
  change (∃ k', σ.state s = Node.x k') ↔ s = t
  rw [hσ s]
  constructor
  · rintro ⟨k', hk'⟩; exact (canon_eq_x_iff.mp hk').1
  · intro h; exact ⟨k, canon_eq_x_iff.mpr ⟨h, rfl⟩⟩

omit hσ in
theorem truth_top (s : ℤ) : PlusTruthAt M σ s PlusFormula.top := fun h => h

theorem truth_Pp (s : ℤ) : PlusTruthAt M σ s Pp ↔ t < s := by
  constructor
  · rintro ⟨(s' : ℤ), hs', hp, -⟩
    rw [truth_p hσ] at hp
    exact hp ▸ hs'
  · intro h
    exact ⟨t, h, (truth_p hσ t).mpr rfl, fun r _ _ => truth_top r⟩

end Truth

/-! ## Backward reachability on a BRANCHING backward graph -/

def IsBwdPath (w₀ : Node) (g : ℕ → Node) : Prop := g 0 = w₀ ∧ ∀ n, Step (g (n + 1)) (g n)

def AllBwdPathsMeet (w₀ : Node) : Prop :=
  ∀ g : ℕ → Node, IsBwdPath w₀ g → ∃ n, 0 < n ∧ ∃ k, g n = .x k

/-- **The branching step.** From `aft m`, EVERY backward root path meets an `x` state within
`m + 1` steps. The universal quantifier is genuine here: at each `aft (k + 1)` on the way the path
chooses between `x (k + 1)` and `aft k`, and the induction on `m` closes both branches. The bound
`n ≤ m + 1` is the König-style uniform depth that makes this a finite backward-reachability
check. -/
theorem bwd_reaches_x (m : ℕ) : ∀ g : ℕ → Node, g 0 = .aft m →
    (∀ n, Step (g (n + 1)) (g n)) → ∃ n, 0 < n ∧ n ≤ m + 1 ∧ ∃ k, g n = .x k := by
  induction m with
  | zero =>
    intro g h0 hstep
    have h := hstep 0
    rw [h0] at h
    rcases step_inv_aft h with hv | ⟨k', hk', -⟩
    · exact ⟨1, Nat.one_pos, le_refl 1, 0, hv⟩
    · exact absurd hk' (Nat.succ_ne_zero k').symm
  | succ m ih =>
    intro g h0 hstep
    have h := hstep 0
    rw [h0] at h
    rcases step_inv_aft h with hv | ⟨k', hk', hv⟩
    · exact ⟨1, Nat.one_pos, Nat.le_add_left 1 (m + 1), m + 1, hv⟩
    · rw [← Nat.succ.inj hk'] at hv
      obtain ⟨n, hn, hle, k, hk⟩ := ih (fun n => g (n + 1)) hv (fun n => hstep (n + 1))
      exact ⟨n + 1, Nat.succ_pos n, Nat.succ_le_succ hle, k, hk⟩

theorem allBwdPathsMeet_aft (m : ℕ) : AllBwdPathsMeet (.aft m) := by
  intro g hg
  obtain ⟨n, hn, -, k, hk⟩ := bwd_reaches_x m g hg.1 hg.2
  exact ⟨n, hn, k, hk⟩

/-! ### Two distinct backward root paths from the state under test -/

/-- Exit the spine immediately: `aft m, x m, bef m 0, bef m 1, …`. -/
def bwdExitNow (m : ℕ) : ℕ → Node
  | 0 => .aft m
  | 1 => .x m
  | n + 2 => .bef m n

theorem bwdExitNow_step (m n : ℕ) : Step (bwdExitNow m (n + 1)) (bwdExitNow m n) := by
  match n with
  | 0 => exact Step.xAft m
  | 1 => exact Step.befX m
  | n + 2 => exact Step.befNext m n

/-- Stay on the spine one more step, then exit: `aft (m+1), aft m, x m, bef m 0, …`. -/
def bwdExitLater (m : ℕ) : ℕ → Node
  | 0 => .aft (m + 1)
  | n + 1 => bwdExitNow m n

theorem bwdExitLater_step (m n : ℕ) : Step (bwdExitLater m (n + 1)) (bwdExitLater m n) := by
  match n with
  | 0 => exact Step.aftUp m
  | n + 1 => exact bwdExitNow_step m n

/-- **The backward factor at `aft (m + 1)` is NOT a singleton**: two backward root paths from it
that already differ at their first step. -/
theorem two_bwd_paths (m : ℕ) :
    IsBwdPath (.aft (m + 1)) (bwdExitNow (m + 1)) ∧ IsBwdPath (.aft (m + 1)) (bwdExitLater m) ∧
      bwdExitNow (m + 1) 1 ≠ bwdExitLater m 1 :=
  ⟨⟨rfl, bwdExitNow_step (m + 1)⟩, ⟨rfl, bwdExitLater_step m⟩, fun h => by cases h⟩

/-! ### The states where the summary is False -/

def bwdFromX (k : ℕ) : ℕ → Node
  | 0 => .x k
  | n + 1 => .bef k n

theorem bwdFromX_step (k n : ℕ) : Step (bwdFromX k (n + 1)) (bwdFromX k n) := by
  cases n with
  | zero => exact Step.befX k
  | succ n => exact Step.befNext k n

theorem bwdFromX_ne_x {k n k' : ℕ} (hn : 0 < n) : bwdFromX k n ≠ .x k' := by
  cases n with
  | zero => omega
  | succ n => intro h; cases h

def bwdFromBef (k j : ℕ) : ℕ → Node := fun n => .bef k (j + n)

theorem bwdFromBef_step (k j n : ℕ) : Step (bwdFromBef k j (n + 1)) (bwdFromBef k j n) :=
  Step.befNext k (j + n)

theorem not_allBwdPathsMeet_x (k : ℕ) : ¬ AllBwdPathsMeet (.x k) := by
  intro h
  obtain ⟨n, hn, k', hk'⟩ := h (bwdFromX k) ⟨rfl, bwdFromX_step k⟩
  exact bwdFromX_ne_x hn hk'

theorem not_allBwdPathsMeet_bef (k j : ℕ) : ¬ AllBwdPathsMeet (.bef k j) := by
  intro h
  obtain ⟨n, hn, k', hk'⟩ := h (bwdFromBef k j) ⟨by simp [bwdFromBef], bwdFromBef_step k j⟩
  cases hk'

/-- `AllBwdPathsMeet` holds exactly at the `aft` states. Unlike the asymmetric-fixture probe, the
universal quantifier over backward paths does NOT collapse to one chain here. -/
theorem allBwdPathsMeet_iff (w : Node) : AllBwdPathsMeet w ↔ ∃ m, w = .aft m := by
  constructor
  · intro h
    cases w with
    | bef k j => exact absurd h (not_allBwdPathsMeet_bef k j)
    | x k => exact absurd h (not_allBwdPathsMeet_x k)
    | aft m => exact ⟨m, rfl⟩
  · rintro ⟨m, rfl⟩
    exact allBwdPathsMeet_aft m

/-! ## The backward summary theorem -/

theorem stabPast_iff_aft (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    PlusTruthAt M τ t stabPast ↔ ∃ m, τ.state t = .aft m := by
  obtain ⟨k₀, t₀, hτ⟩ := hist_canon τ
  constructor
  · intro (h : ∀ σ : WorldHistory F.toTaskFrame, τ.state t = σ.state t →
      PlusTruthAt M σ t Pp)
    have hPp : PlusTruthAt M τ t Pp := h τ rfl
    have ht₀ : t₀ < t := (truth_Pp hτ t).mp hPp
    refine ⟨k₀ + (t - t₀ - 1).toNat, ?_⟩
    rw [hτ t, canon_of_gt ht₀]
  · rintro ⟨m, haft⟩
    intro σ hagree
    obtain ⟨k', t', hσ⟩ := hist_canon σ
    have hst : σ.state t = .aft m := by rw [← hagree]; exact haft
    have hcan : canon k' t' t = .aft m := by rw [← hσ t]; exact hst
    have ht' : t' < t := by
      rcases lt_trichotomy t t' with h | h | h
      · rw [canon_of_lt h] at hcan; cases hcan
      · subst h; rw [canon_self] at hcan; cases hcan
      · exact h
    exact (truth_Pp hσ t).mpr ht'

theorem pastStab_iff_allBwdPathsMeet (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    PlusTruthAt M τ t stabPast ↔ AllBwdPathsMeet (τ.state t) :=
  (stabPast_iff_aft τ t).trans (allBwdPathsMeet_iff (τ.state t)).symm

theorem past_stab_at_aft (τ : WorldHistory F.toTaskFrame) (t : ℤ) {m : ℕ}
    (h : τ.state t = .aft m) : PlusTruthAt M τ t stabPast :=
  (pastStab_iff_allBwdPathsMeet τ t).mpr (h ▸ allBwdPathsMeet_aft m)

theorem not_past_stab_at_x (τ : WorldHistory F.toTaskFrame) (t : ℤ) {k : ℕ}
    (h : τ.state t = .x k) : ¬ PlusTruthAt M τ t stabPast :=
  fun hst => not_allBwdPathsMeet_x k (h ▸ (pastStab_iff_allBwdPathsMeet τ t).mp hst)

theorem not_past_stab_at_bef (τ : WorldHistory F.toTaskFrame) (t : ℤ) {k j : ℕ}
    (h : τ.state t = .bef k j) : ¬ PlusTruthAt M τ t stabPast :=
  fun hst => not_allBwdPathsMeet_bef k j (h ▸ (pastStab_iff_allBwdPathsMeet τ t).mp hst)

theorem decide_past_stab (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    (PlusTruthAt M τ t stabPast ↔ ∃ m, τ.state t = .aft m) :=
  stabPast_iff_aft τ t

instance decidable_past_stab (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    Decidable (PlusTruthAt M τ t stabPast) :=
  match hw : (τ.state t : Node) with
  | .bef _ _ => Decidable.isFalse (not_past_stab_at_bef τ t hw)
  | .x _ => Decidable.isFalse (not_past_stab_at_x τ t hw)
  | .aft _ => Decidable.isTrue (past_stab_at_aft τ t hw)

end Probe733Mirror

#print axioms Probe733Mirror.two_bwd_paths
#print axioms Probe733Mirror.bwd_reaches_x
#print axioms Probe733Mirror.allBwdPathsMeet_iff
#print axioms Probe733Mirror.stabPast_iff_aft
#print axioms Probe733Mirror.pastStab_iff_allBwdPathsMeet
#print axioms Probe733Mirror.decide_past_stab
