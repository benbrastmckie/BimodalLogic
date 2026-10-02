/-
Probe 710: the TIME-SLICED certificate class is INCOMPLETE for full L⁺ over regular ℤ-frames.

The witness is

  Φ := θ' ∧ □(⊡Fp → ¬⊡¬Xp)

where `θ' := □(p ∨ ⊡Fp ∨ ⊡Pp) ∧ □(p → ⊡¬Pp)` is task 706's "every history meets `p` exactly once"
in its CTL-like form, `Xp := ⊥ U p` is "p at the next time", and the new conjunct says: at every
state all of whose histories still have `p` ahead (a *pre* state), some history reaches `p` at the
very next time. Every `⊡` and `□` governs a state formula or a single temporal operator over state
formulas, so `Φ` lies in the CTL-like fragment of report 706 §Q3.

- Positive half (`not_plusValidZTime_neg_Φ`): `Φ` holds on a countable, finitely branching,
  time-homogeneous regular ℤ-frame `F` with carrier `Node = {pre k} ∪ {x k} ∪ {post k j}` and the
  steps `pre (k+1) → pre k`, `pre k → x k`, `x k → post k 0`, `post k j → post k (j+1)`. Every
  bi-infinite step path of `F` is `… pre (k+2), pre (k+1), pre k, x k, post k 0, post k 1, …`
  for one `k` and one position of `x k` (`path_eq_canon`), which is what makes the verification
  a case split on the position of the time `0` relative to that `x`.
- Negative half (`no_finite_width_sat`): NO model on a frame `FrameOver.ofSlicedStep R fwd bwd`
  with `[Finite W]` — the frame every `PlusSlicedCertificate` presents — satisfies `Φ` at any
  history and time. Sketch: every state is `p`, *pre* (all histories through it have `p` strictly
  ahead) or *post* (strictly behind); predecessors of a `p` state are pre, so by the new conjunct
  there are `p` states at every time `≤ a` for some `a`; successors of `p` or post states are
  post; a post state can have no infinite backward path of post states (such a path, pasted with
  any forward path, is a history with no `p`), and with finitely many predecessors per state this
  bounds, for each post state, the length of backward post-chains into it (König); but the forward
  post-chains from the `p` states at times `a - n - 1` reach time `a` as backward post-chains of
  every length `n`, and there are only finitely many states at time `a` — pigeonhole.

Consequence (`not_sliced_complete`): `Φ.neg` is a ℤ-time non-validity of L⁺ that no
`PlusSlicedCertificate` certifies. The width of a countermodel of `Φ.neg` — the number of
states per time — is necessarily infinite, so no certificate class presenting a frame with
finite per-time fibres is complete for L⁺, and already not for the CTL-like fragment.

Compile-check from the repository root with:
  lake env lean specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability

namespace Probe710

/-! ## The witness formula -/

def pa : Atom := ⟨"p", none⟩
def p : PlusFormula := PlusFormula.atom pa
def Fp : PlusFormula := PlusFormula.untl PlusFormula.top p
def Pp : PlusFormula := PlusFormula.snce PlusFormula.top p
/-- `Xp := ⊥ U p`: `p` at the next time. -/
def Xp : PlusFormula := PlusFormula.untl PlusFormula.bot p
/-- `□(p ∨ ⊡Fp ∨ ⊡Pp)` (task 706's `A'`). -/
def A' : PlusFormula := PlusFormula.box (p.or ((PlusFormula.stab Fp).or (PlusFormula.stab Pp)))
/-- `□(p → ⊡¬Pp)` (task 706's `C'`). -/
def C' : PlusFormula := PlusFormula.box (p.imp (PlusFormula.stab Pp.neg))
/-- `□(⊡Fp → ¬⊡¬Xp)`: every pre state has a `p`-successor. -/
def D : PlusFormula :=
  PlusFormula.box ((PlusFormula.stab Fp).imp (PlusFormula.stab Xp.neg).neg)
/-- The witness. -/
def Φ : PlusFormula := (A'.and C').and D

/-! ## Positive half: a countable, finitely branching model of `Φ` -/

/-- States: `pre k` (`k + 1` steps to go), `x k` (the `p` state of thread `k`), `post k j`
(`j + 1` steps after `x k`). -/
inductive Node : Type
  | pre : ℕ → Node
  | x : ℕ → Node
  | post : ℕ → ℕ → Node
  deriving DecidableEq

instance : Nonempty Node := ⟨.x 0⟩

/-- The one-step relation. Every state has one or two successors and exactly one predecessor. -/
inductive Step : Node → Node → Prop
  | preDown (k : ℕ) : Step (.pre (k + 1)) (.pre k)
  | preX (k : ℕ) : Step (.pre k) (.x k)
  | xPost (k : ℕ) : Step (.x k) (.post k 0)
  | postNext (k j : ℕ) : Step (.post k j) (.post k (j + 1))

theorem step_pre_inv {k : ℕ} {u : Node} (h : Step (.pre k) u) :
    u = .x k ∨ ∃ k', k = k' + 1 ∧ u = .pre k' := by
  cases h with
  | preDown k' => exact Or.inr ⟨k', rfl, rfl⟩
  | preX _ => exact Or.inl rfl

theorem step_x_inv {k : ℕ} {u : Node} (h : Step (.x k) u) : u = .post k 0 := by
  cases h; rfl

theorem step_post_inv {k j : ℕ} {u : Node} (h : Step (.post k j) u) : u = .post k (j + 1) := by
  cases h; rfl

theorem step_inv_pre {v : Node} {k : ℕ} (h : Step v (.pre k)) : v = .pre (k + 1) := by
  cases h; rfl

theorem step_inv_x {v : Node} {k : ℕ} (h : Step v (.x k)) : v = .pre k := by
  cases h; rfl

theorem step_inv_post {v : Node} {k j : ℕ} (h : Step v (.post k j)) :
    (j = 0 ∧ v = .x k) ∨ ∃ j', j = j' + 1 ∧ v = .post k j' := by
  cases h with
  | xPost _ => exact Or.inl ⟨rfl, rfl⟩
  | postNext _ j' => exact Or.inr ⟨j', rfl, rfl⟩

theorem step_fwd (w : Node) : ∃ u, Step w u := by
  cases w with
  | pre k => exact ⟨_, Step.preX k⟩
  | x k => exact ⟨_, Step.xPost k⟩
  | post k j => exact ⟨_, Step.postNext k j⟩

theorem step_bwd (w : Node) : ∃ v, Step v w := by
  cases w with
  | pre k => exact ⟨_, Step.preDown k⟩
  | x k => exact ⟨_, Step.preX k⟩
  | post k j =>
    cases j with
    | zero => exact ⟨_, Step.xPost k⟩
    | succ j => exact ⟨_, Step.postNext k j⟩

/-- Successors, as a list: the forward fibres are finite. -/
def fwdList : Node → List Node
  | .pre 0 => [.x 0]
  | .pre (k + 1) => [.pre k, .x (k + 1)]
  | .x k => [.post k 0]
  | .post k j => [.post k (j + 1)]

theorem mem_fwdList {w u : Node} (h : Step w u) : u ∈ fwdList w := by
  cases h with
  | preDown k => simp [fwdList]
  | preX k => cases k <;> simp [fwdList]
  | xPost k => simp [fwdList]
  | postNext k j => simp [fwdList]

/-- Predecessors, as a list: the backward fibres are finite. -/
def bwdList : Node → List Node
  | .pre k => [.pre (k + 1)]
  | .x k => [.pre k]
  | .post k 0 => [.x k]
  | .post k (j + 1) => [.post k j]

theorem mem_bwdList {v w : Node} (h : Step v w) : v ∈ bwdList w := by
  cases h with
  | preDown k => simp [bwdList]
  | preX k => simp [bwdList]
  | xPost k => simp [bwdList]
  | postNext k j => simp [bwdList]

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

/-- The fibres of the two-sided relation generated by `Step` are finite, although the carrier is
not: this is what `TaskFrame.saturation_of_fib_finite` consumes. -/
theorem fib_finite (w : Node) (d : ℤ) : (TaskFrame.Fib (ofStepRel Step) w d).Finite := by
  rcases le_or_gt 0 d with hd | hd
  · refine (iter_fwd_finite d.natAbs w).subset fun u hu => ?_
    exact (ofStepRel_of_nonneg hd w u).mp hu
  · refine (iter_bwd_finite d.natAbs w).subset fun u hu => ?_
    exact (ofStepRel_of_nonpos hd.le w u).mp hu

/-- The frame: `FrameOver.ofStep`'s construction with *Saturation* discharged from finite fibres
instead of a finite carrier. -/
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

/-- The model: `p` holds exactly at the `x` states. -/
def M : TaskModel F.toTaskFrame := ⟨fun w _ => ∃ k, w = Node.x k⟩

/-! ### Every step path is canonical -/

/-- The bi-infinite step path of thread `k` with `x k` at time `t`. -/
def canon (k : ℕ) (t : ℤ) (s : ℤ) : Node :=
  if s < t then .pre (k + (t - 1 - s).toNat)
  else if s = t then .x k
  else .post k (s - t - 1).toNat

theorem canon_of_lt {k : ℕ} {t s : ℤ} (h : s < t) :
    canon k t s = .pre (k + (t - 1 - s).toNat) := by
  simp [canon, h]

theorem canon_self (k : ℕ) (t : ℤ) : canon k t t = .x k := by
  simp [canon]

theorem canon_of_gt {k : ℕ} {t s : ℤ} (h : t < s) : canon k t s = .post k (s - t - 1).toNat := by
  simp [canon, not_lt.mpr h.le, h.ne']

theorem canon_step (k : ℕ) (t s : ℤ) : Step (canon k t s) (canon k t (s + 1)) := by
  rcases lt_trichotomy (s + 1) t with h1 | h1 | h1
  · rw [canon_of_lt (by omega), canon_of_lt h1]
    have e : (t - 1 - s).toNat = (t - 1 - (s + 1)).toNat + 1 := by omega
    rw [e]
    exact Step.preDown _
  · rw [canon_of_lt (by omega), h1, canon_self]
    have e : (t - 1 - s).toNat = 0 := by omega
    rw [e, Nat.add_zero]
    exact Step.preX k
  · rcases lt_trichotomy s t with h2 | h2 | h2
    · omega
    · subst h2
      rw [canon_self, canon_of_gt (by omega)]
      have e : (s + 1 - s - 1).toNat = 0 := by omega
      rw [e]
      exact Step.xPost k
    · rw [canon_of_gt h2, canon_of_gt (by omega)]
      have e : (s + 1 - t - 1).toNat = (s - t - 1).toNat + 1 := by omega
      rw [e]
      exact Step.postNext k _

/-- `canon k t s` is an `x` state exactly at `s = t`. -/
theorem canon_eq_x_iff {k k' : ℕ} {t s : ℤ} : canon k t s = .x k' ↔ s = t ∧ k = k' := by
  rcases lt_trichotomy s t with h | h | h
  · rw [canon_of_lt h]; simp; omega
  · subst h; rw [canon_self]; simp
  · rw [canon_of_gt h]; simp; omega

section Struct

variable {g : ℤ → Node} (hg : ∀ s, Step (g s) (g (s + 1)))
include hg

theorem fwd_from_x {t : ℤ} {k : ℕ} (ht : g t = .x k) (i : ℕ) : g (t + i + 1) = .post k i := by
  induction i with
  | zero =>
    have h := hg t
    rw [ht] at h
    simpa using step_x_inv h
  | succ i ih =>
    have h := hg (t + i + 1)
    rw [ih] at h
    have e : t + ((i + 1 : ℕ) : ℤ) + 1 = t + i + 1 + 1 := by push_cast; ring
    rw [e]
    exact step_post_inv h

theorem bwd_from_x {t : ℤ} {k : ℕ} (ht : g t = .x k) (i : ℕ) : g (t - i - 1) = .pre (k + i) := by
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
    exact step_inv_pre h

theorem post_back {k : ℕ} (j : ℕ) : ∀ s, g s = .post k j → g (s - j - 1) = .x k := by
  induction j with
  | zero =>
    intro s hs
    have h := hg (s - 1)
    rw [show s - 1 + 1 = s by ring, hs] at h
    rcases step_inv_post h with ⟨-, hv⟩ | ⟨j', hj', -⟩
    · simpa using hv
    · omega
  | succ j ih =>
    intro s hs
    have h := hg (s - 1)
    rw [show s - 1 + 1 = s by ring, hs] at h
    rcases step_inv_post h with ⟨hj, -⟩ | ⟨j', hj', hv⟩
    · omega
    · have hj'' : j' = j := by omega
      rw [hj''] at hv
      have := ih (s - 1) hv
      have e : s - ((j + 1 : ℕ) : ℤ) - 1 = s - 1 - j - 1 := by push_cast; ring
      rw [e]
      exact this

theorem pre_fwd (k : ℕ) : ∀ s, g s = .pre k → ∃ (i : ℕ) (k' : ℕ), g (s + i) = .x k' := by
  induction k with
  | zero =>
    intro s hs
    have h := hg s
    rw [hs] at h
    rcases step_pre_inv h with hv | ⟨k', hk', -⟩
    · exact ⟨1, 0, by simpa using hv⟩
    · omega
  | succ k ih =>
    intro s hs
    have h := hg s
    rw [hs] at h
    rcases step_pre_inv h with hv | ⟨k', hk', hv⟩
    · exact ⟨1, k + 1, by simpa using hv⟩
    · have hk'' : k' = k := by omega
      rw [hk''] at hv
      obtain ⟨i, k'', hi⟩ := ih (s + 1) hv
      refine ⟨i + 1, k'', ?_⟩
      rw [show s + ((i + 1 : ℕ) : ℤ) = s + 1 + i by push_cast; ring]
      exact hi

theorem exists_x : ∃ (t : ℤ) (k : ℕ), g t = .x k := by
  cases hx : g 0 with
  | pre k =>
    obtain ⟨i, k', hi⟩ := pre_fwd hg k 0 hx
    exact ⟨0 + i, k', hi⟩
  | x k => exact ⟨0, k, hx⟩
  | post k j => exact ⟨0 - j - 1, k, post_back hg j 0 hx⟩

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

/-! ### Histories of `F` -/

/-- The history of the canonical path. -/
def histOf (k : ℕ) (t : ℤ) : WorldHistory F :=
  FrameOver.worldHistoryOfStepPath F (canon k t) (fun s => (F_step _ _).mpr (canon_step k t s))

theorem histOf_state (k : ℕ) (t s : ℤ) : (histOf k t).state s = canon k t s :=
  congrFun (FrameOver.worldHistoryOfStepPath.path F (canon k t) _) s

theorem hist_canon (σ : WorldHistory F) : ∃ (k : ℕ) (t : ℤ), ∀ s, σ.state s = canon k t s := by
  have hstep : IsStepPath F σ.path := (FrameOver.mem_HF_iff_adjacent F σ.path).mp ⟨σ, rfl⟩
  exact path_eq_canon fun s => (F_step _ _).mp (hstep s)

/-! ### Truth of the atoms and the single temporal operators along a canonical history -/

section Truth

variable {σ : WorldHistory F} {k : ℕ} {t : ℤ} (hσ : ∀ s, σ.state s = canon k t s)
include hσ

theorem truth_p (s : ℤ) : PlusTruthAt M σ s p ↔ s = t := by
  change (∃ k', σ.state s = Node.x k') ↔ s = t
  rw [hσ s]
  constructor
  · rintro ⟨k', hk'⟩; exact (canon_eq_x_iff.mp hk').1
  · intro h; exact ⟨k, canon_eq_x_iff.mpr ⟨h, rfl⟩⟩

omit hσ in
theorem truth_top (s : ℤ) : PlusTruthAt M σ s PlusFormula.top := fun h => h

theorem truth_Fp (s : ℤ) : PlusTruthAt M σ s Fp ↔ s < t := by
  constructor
  · rintro ⟨(s' : ℤ), hs', hp, -⟩
    rw [truth_p hσ] at hp
    exact hp ▸ hs'
  · intro h
    exact ⟨t, h, (truth_p hσ t).mpr rfl, fun r _ _ => truth_top r⟩

theorem truth_Pp (s : ℤ) : PlusTruthAt M σ s Pp ↔ t < s := by
  constructor
  · rintro ⟨(s' : ℤ), hs', hp, -⟩
    rw [truth_p hσ] at hp
    exact hp ▸ hs'
  · intro h
    exact ⟨t, h, (truth_p hσ t).mpr rfl, fun r _ _ => truth_top r⟩

theorem truth_Xp (s : ℤ) : PlusTruthAt M σ s Xp ↔ s + 1 = t := by
  constructor
  · rintro ⟨(s' : ℤ), hs', hp, hgap⟩
    rw [truth_p hσ] at hp
    have hs'' : (s : ℤ) < s' := hs'
    by_contra hne
    exact hgap (s + 1) (show (s : ℤ) < s + 1 by omega) (show (s + 1 : ℤ) < s' by omega)
  · intro h
    refine ⟨t, show (s : ℤ) < t by omega, (truth_p hσ t).mpr rfl, fun (r : ℤ) h1 h2 => ?_⟩
    have h1' : (s : ℤ) < r := h1
    have h2' : (r : ℤ) < t := h2
    omega

end Truth

/-- Two canonical histories sharing a pre state at time `s` are both pre at `s`. -/
theorem lt_of_canon_eq_of_lt {k k' : ℕ} {t t' s : ℤ} (h : canon k t s = canon k' t' s)
    (hs : s < t) : s < t' := by
  rw [canon_of_lt hs] at h
  rcases lt_trichotomy s t' with h' | h' | h'
  · exact h'
  · subst h'; rw [canon_self] at h; cases h
  · rw [canon_of_gt h'] at h; cases h

theorem gt_of_canon_eq_of_gt {k k' : ℕ} {t t' s : ℤ} (h : canon k t s = canon k' t' s)
    (hs : t < s) : t' < s := by
  rw [canon_of_gt hs] at h
  rcases lt_trichotomy s t' with h' | h' | h'
  · rw [canon_of_lt h'] at h; cases h
  · subst h'; rw [canon_self] at h; cases h
  · exact h'

theorem eq_of_canon_eq_of_eq {k k' : ℕ} {t t' s : ℤ} (h : canon k t s = canon k' t' s)
    (hs : s = t) : s = t' := by
  subst hs
  rw [canon_self] at h
  exact (canon_eq_x_iff.mp h.symm).1

/-- **`Φ` holds in `F`.** -/
theorem Φ_true : PlusTruthAt M (histOf 0 0) 0 Φ := by
  have hA : PlusTruthAt M (histOf 0 0) 0 A' := by
    intro σ
    obtain ⟨k, t, hσ⟩ := hist_canon σ
    simp only [PlusFormula.or, PlusFormula.neg, PlusTruthAt]
    intro hnp hnF
    rcases lt_trichotomy (0 : ℤ) t with h | h | h
    · exfalso
      apply hnF
      intro σ' hσ'
      obtain ⟨k', t', hσ''⟩ := hist_canon σ'
      rw [truth_Fp hσ'']
      have := hσ 0 ▸ hσ'' 0 ▸ hσ'
      exact lt_of_canon_eq_of_lt this h
    · exact (hnp ((truth_p hσ 0).mpr h)).elim
    · intro σ' hσ'
      obtain ⟨k', t', hσ''⟩ := hist_canon σ'
      rw [truth_Pp hσ'']
      have := hσ 0 ▸ hσ'' 0 ▸ hσ'
      exact gt_of_canon_eq_of_gt this h
  have hC : PlusTruthAt M (histOf 0 0) 0 C' := by
    intro σ
    obtain ⟨k, t, hσ⟩ := hist_canon σ
    simp only [PlusFormula.neg, PlusTruthAt]
    intro hp σ' hσ'
    have ht : (0 : ℤ) = t := (truth_p hσ 0).mp hp
    obtain ⟨k', t', hσ''⟩ := hist_canon σ'
    rw [truth_Pp hσ'']
    have := hσ 0 ▸ hσ'' 0 ▸ hσ'
    have := eq_of_canon_eq_of_eq this ht
    omega
  have hD : PlusTruthAt M (histOf 0 0) 0 D := by
    intro σ
    obtain ⟨k, t, hσ⟩ := hist_canon σ
    simp only [PlusFormula.neg, PlusTruthAt]
    intro hstF hall
    have ht : (0 : ℤ) < t := (truth_Fp hσ 0).mp (hstF σ rfl)
    apply hall (histOf (k + (t - 1 - 0).toNat) 1)
    · rw [hσ 0, histOf_state, canon_of_lt ht, canon_of_lt (by omega)]
      congr 1
    · rw [truth_Xp (fun s => histOf_state _ _ s)]
      norm_num
  simp only [Φ, PlusFormula.and, PlusFormula.neg, PlusTruthAt]
  intro h
  exact h (fun h' => h' hA hC) hD

theorem F_isZTime : F.toTaskFrame.IsZTime :=
  @TaskFrame.isZTime_of_instances F.toTaskFrame
    (inferInstanceAs (SuccOrder ℤ)) (inferInstanceAs (PredOrder ℤ))
    (inferInstanceAs (IsSuccArchimedean ℤ)) (inferInstanceAs (IsPredArchimedean ℤ))

/-- **`Φ.neg` is a ℤ-time non-validity of L⁺.** -/
theorem not_plusValidZTime_neg_Φ : ¬ PlusValidZTime Φ.neg := by
  intro hv
  exact hv F ⟨F_isRegular, F_isZTime⟩ M (histOf 0 0) 0 Φ_true

#print axioms not_plusValidZTime_neg_Φ

/-! ## Negative half: no model on a finite-width sliced frame satisfies `Φ`

The frame is `FrameOver.ofSlicedStep R fwd bwd` with `[Finite W]`: the frame every
`PlusSlicedCertificate` presents (`PlusSlicedCertificate.frame`), with `W = Fin G.n`. Nothing
below uses anything about `R` beyond bi-seriality, and nothing about `W` beyond finiteness.
-/

section NoFiniteWidth

variable {W : Type} (R : ℤ → W → W → Prop)

/-- An offset-`0` step path of the slice relation: it occupies slice `t` at time `t`. -/
def IsPath (g : ℤ → W) : Prop := ∀ t, R t (g t) (g (t + 1))

/-! ### Paths: existence through every state, and gluing at a time -/

/-- A forward step sequence from `w` at slice `t`, by choice. -/
noncomputable def fwdSeq (fwd : ∀ t w, ∃ u, R t w u) (t : ℤ) (w : W) : ℕ → W
  | 0 => w
  | n + 1 => Classical.choose (fwd (t + n) (fwdSeq fwd t w n))

@[simp]
theorem fwdSeq_zero (fwd : ∀ t w, ∃ u, R t w u) (t : ℤ) (w : W) : fwdSeq R fwd t w 0 = w := rfl

theorem fwdSeq_spec (fwd : ∀ t w, ∃ u, R t w u) (t : ℤ) (w : W) (n : ℕ) :
    R (t + n) (fwdSeq R fwd t w n) (fwdSeq R fwd t w (n + 1)) :=
  Classical.choose_spec (fwd (t + n) (fwdSeq R fwd t w n))

/-- A backward step sequence into `w` at slice `t`, by choice: `bwdSeq (n + 1)` sits at slice
`t - n - 1`. -/
noncomputable def bwdSeq (bwd : ∀ t w, ∃ v, R (t - 1) v w) (t : ℤ) (w : W) : ℕ → W
  | 0 => w
  | n + 1 => Classical.choose (bwd (t - n) (bwdSeq bwd t w n))

@[simp]
theorem bwdSeq_zero (bwd : ∀ t w, ∃ v, R (t - 1) v w) (t : ℤ) (w : W) : bwdSeq R bwd t w 0 = w :=
  rfl

theorem bwdSeq_spec (bwd : ∀ t w, ∃ v, R (t - 1) v w) (t : ℤ) (w : W) (n : ℕ) :
    R (t - n - 1) (bwdSeq R bwd t w (n + 1)) (bwdSeq R bwd t w n) :=
  Classical.choose_spec (bwd (t - n) (bwdSeq R bwd t w n))

/-- Every state at every slice lies on an offset-`0` path. -/
theorem exists_path_through (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w)
    (t : ℤ) (w : W) : ∃ g, IsPath R g ∧ g t = w := by
  classical
  let g : ℤ → W := fun s =>
    if t ≤ s then fwdSeq R fwd t w (s - t).toNat else bwdSeq R bwd t w (t - s).toNat
  refine ⟨g, ?_, by simp [g]⟩
  intro s
  rcases lt_trichotomy (s + 1) t with h1 | h1 | h1
  · have hs : ¬ t ≤ s := by omega
    have hs1 : ¬ t ≤ s + 1 := by omega
    simp only [g, if_neg hs, if_neg hs1]
    have e : (t - s).toNat = (t - (s + 1)).toNat + 1 := by omega
    rw [e]
    have := bwdSeq_spec R bwd t w (t - (s + 1)).toNat
    rwa [show t - ((t - (s + 1)).toNat : ℤ) - 1 = s by omega] at this
  · have hs : ¬ t ≤ s := by omega
    have hs1 : t ≤ s + 1 := by omega
    simp only [g, if_neg hs, if_pos hs1]
    have e1 : (t - s).toNat = 1 := by omega
    have e2 : (s + 1 - t).toNat = 0 := by omega
    rw [e1, e2]
    have := bwdSeq_spec R bwd t w 0
    simp only [Nat.cast_zero, sub_zero] at this
    rwa [show t - 1 = s by omega] at this
  · have hs : t ≤ s := by omega
    have hs1 : t ≤ s + 1 := by omega
    simp only [g, if_pos hs, if_pos hs1]
    have e : (s + 1 - t).toNat = (s - t).toNat + 1 := by omega
    rw [e]
    have := fwdSeq_spec R fwd t w (s - t).toNat
    rwa [show t + ((s - t).toNat : ℤ) = s by omega] at this

/-- Gluing two paths at time `t`: `g₀` up to and including `t`, `g₁` afterwards. -/
def glue (t : ℤ) (g₀ g₁ : ℤ → W) (s : ℤ) : W := if s ≤ t then g₀ s else g₁ s

theorem glue_of_le {t s : ℤ} (g₀ g₁ : ℤ → W) (h : s ≤ t) : glue t g₀ g₁ s = g₀ s := by
  simp [glue, h]

theorem glue_of_lt {t s : ℤ} (g₀ g₁ : ℤ → W) (h : t < s) : glue t g₀ g₁ s = g₁ s := by
  simp [glue, not_le.mpr h]

theorem glue_isPath {t : ℤ} {g₀ g₁ : ℤ → W} (h₀ : IsPath R g₀) (h₁ : IsPath R g₁)
    (hc : R t (g₀ t) (g₁ (t + 1))) : IsPath R (glue t g₀ g₁) := by
  intro s
  rcases lt_trichotomy s t with h | h | h
  · have e1 : s ≤ t := by omega
    have e2 : s + 1 ≤ t := by omega
    rw [glue_of_le _ _ e1, glue_of_le _ _ e2]
    exact h₀ s
  · subst h
    have e2 : s < s + 1 := by omega
    rw [glue_of_le _ _ le_rfl, glue_of_lt _ _ e2]
    exact hc
  · have e2 : t < s + 1 := by omega
    rw [glue_of_lt _ _ h, glue_of_lt _ _ e2]
    exact h₁ s

/-! ### Pre and post states, from "exactly one `p` per path" -/

section Core

-- The three path facts are section variables so that each lemma names only what it uses; the
-- linter's unused-variable notice on the ones that need fewer is noise here.
set_option linter.unusedSectionVars false

variable [Finite W] [Nonempty W]
  (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w)
  (val : ℤ × W → Prop)

/-- A *pre* state: every path through it has `p` strictly ahead. -/
def PreN (t : ℤ) (w : W) : Prop :=
  ∀ g, IsPath R g → g t = w → ∃ a, t < a ∧ val (a, g a)

/-- A *post* state: every path through it has `p` strictly behind. -/
def PostN (t : ℤ) (w : W) : Prop :=
  ∀ g, IsPath R g → g t = w → ∃ a, a < t ∧ val (a, g a)

variable (someP : ∀ g, IsPath R g → ∃ a, val (a, g a))
  (onceP : ∀ g, IsPath R g → ∀ a b, val (a, g a) → val (b, g b) → a = b)
  (succP : ∀ g, IsPath R g → ∀ s,
    (∀ g', IsPath R g' → g' s = g s → ∃ a, s < a ∧ val (a, g' a)) →
      ∃ u, R s (g s) u ∧ val (s + 1, u))

include fwd bwd onceP in
theorem not_val_of_postN {t : ℤ} {w : W} (h : PostN R val t w) : ¬ val (t, w) := by
  intro hv
  obtain ⟨g, hg, hw⟩ := exists_path_through R fwd bwd t w
  obtain ⟨a, ha, hva⟩ := h g hg hw
  have := onceP g hg a t hva (by rwa [hw])
  omega

include fwd bwd onceP in
theorem not_val_of_preN {t : ℤ} {w : W} (h : PreN R val t w) : ¬ val (t, w) := by
  intro hv
  obtain ⟨g, hg, hw⟩ := exists_path_through R fwd bwd t w
  obtain ⟨a, ha, hva⟩ := h g hg hw
  have := onceP g hg a t hva (by rwa [hw])
  omega

include fwd bwd someP in
/-- A state that is not `p` is pre or post. -/
theorem preN_or_postN {t : ℤ} {w : W} (h : ¬ val (t, w)) :
    PreN R val t w ∨ PostN R val t w := by
  classical
  by_cases hpre : PreN R val t w
  · exact Or.inl hpre
  right
  simp only [PreN, not_forall, not_exists, not_and] at hpre
  obtain ⟨g₁, hg₁, hw₁, hno⟩ := hpre
  intro g₂ hg₂ hw₂
  let hh : IsPath R (glue t g₂ g₁) :=
    glue_isPath R hg₂ hg₁ (by rw [hw₂, ← hw₁]; exact hg₁ t)
  obtain ⟨c, hc⟩ := someP _ hh
  rcases lt_trichotomy c t with hct | hct | hct
  · rw [glue_of_le _ _ hct.le] at hc
    exact ⟨c, hct, hc⟩
  · subst hct
    rw [glue_of_le _ _ le_rfl, hw₂] at hc
    exact (h hc).elim
  · rw [glue_of_lt _ _ hct] at hc
    exact (hno c hct hc).elim

include fwd bwd someP onceP in
/-- If every path through the edge `(t, w) → (t + 1, u)` has `p` at or before `t`, then `(t + 1, u)`
is post. -/
theorem postN_of_exists {t : ℤ} {w u : W} (hR : R t w u)
    (hex : ∀ h, IsPath R h → h t = w → h (t + 1) = u → ∃ a, a ≤ t ∧ val (a, h a)) :
    PostN R val (t + 1) u := by
  obtain ⟨g₀, hg₀, hw₀⟩ := exists_path_through R fwd bwd t w
  have hnot : ¬ val (t + 1, u) := by
    intro hv
    obtain ⟨g, hg, hu⟩ := exists_path_through R fwd bwd (t + 1) u
    have hh : IsPath R (glue t g₀ g) := glue_isPath R hg₀ hg (by rw [hw₀, hu]; exact hR)
    obtain ⟨a, ha, hva⟩ := hex _ hh (by rw [glue_of_le _ _ le_rfl, hw₀])
      (by rw [glue_of_lt _ _ (by omega), hu])
    have := onceP _ hh a (t + 1) hva (by rw [glue_of_lt _ _ (by omega), hu]; exact hv)
    omega
  rcases preN_or_postN R fwd bwd val someP hnot with hpre | hpost
  · exfalso
    obtain ⟨g, hg, hu⟩ := exists_path_through R fwd bwd (t + 1) u
    have hh : IsPath R (glue t g₀ g) := glue_isPath R hg₀ hg (by rw [hw₀, hu]; exact hR)
    obtain ⟨a, ha, hva⟩ := hex _ hh (by rw [glue_of_le _ _ le_rfl, hw₀])
      (by rw [glue_of_lt _ _ (by omega), hu])
    obtain ⟨b, hb, hvb⟩ := hpre _ hh (by rw [glue_of_lt _ _ (by omega), hu])
    have := onceP _ hh a b hva hvb
    omega
  · exact hpost

include fwd bwd someP onceP in
/-- Mirror: if every path through the edge `(t - 1, v) → (t, w)` has `p` at or after `t`, then
`(t - 1, v)` is pre. -/
theorem preN_of_exists {t : ℤ} {v w : W} (hR : R (t - 1) v w)
    (hex : ∀ h, IsPath R h → h (t - 1) = v → h t = w → ∃ a, t ≤ a ∧ val (a, h a)) :
    PreN R val (t - 1) v := by
  obtain ⟨g₀, hg₀, hw₀⟩ := exists_path_through R fwd bwd t w
  have hglue : ∀ g, IsPath R g → g (t - 1) = v → IsPath R (glue (t - 1) g g₀) := by
    intro g hg hv
    refine glue_isPath R hg hg₀ ?_
    rw [hv, show t - 1 + 1 = t by ring, hw₀]
    exact hR
  have hnot : ¬ val (t - 1, v) := by
    intro hvv
    obtain ⟨g, hg, hv⟩ := exists_path_through R fwd bwd (t - 1) v
    have hh := hglue g hg hv
    obtain ⟨a, ha, hva⟩ := hex _ hh (by rw [glue_of_le _ _ le_rfl, hv])
      (by rw [glue_of_lt _ _ (by omega), hw₀])
    have := onceP _ hh a (t - 1) hva (by rw [glue_of_le _ _ le_rfl, hv]; exact hvv)
    omega
  rcases preN_or_postN R fwd bwd val someP hnot with hpre | hpost
  · exact hpre
  · exfalso
    obtain ⟨g, hg, hv⟩ := exists_path_through R fwd bwd (t - 1) v
    have hh := hglue g hg hv
    obtain ⟨a, ha, hva⟩ := hex _ hh (by rw [glue_of_le _ _ le_rfl, hv])
      (by rw [glue_of_lt _ _ (by omega), hw₀])
    obtain ⟨b, hb, hvb⟩ := hpost _ hh (by rw [glue_of_le _ _ le_rfl, hv])
    have := onceP _ hh a b hva hvb
    omega

include fwd bwd someP onceP in
theorem postN_succ_of_val {t : ℤ} {w u : W} (hv : val (t, w)) (hR : R t w u) :
    PostN R val (t + 1) u :=
  postN_of_exists R fwd bwd val someP onceP hR fun h _ hw _ => ⟨t, le_rfl, by rw [hw]; exact hv⟩

include fwd bwd someP onceP in
theorem postN_succ {t : ℤ} {w u : W} (hp : PostN R val t w) (hR : R t w u) :
    PostN R val (t + 1) u :=
  postN_of_exists R fwd bwd val someP onceP hR fun h hh hw _ => by
    obtain ⟨a, ha, hva⟩ := hp h hh hw
    exact ⟨a, ha.le, hva⟩

include fwd bwd someP onceP in
theorem preN_pred_of_val {t : ℤ} {v w : W} (hv : val (t, w)) (hR : R (t - 1) v w) :
    PreN R val (t - 1) v :=
  preN_of_exists R fwd bwd val someP onceP hR fun h _ _ hw => ⟨t, le_rfl, by rw [hw]; exact hv⟩

include fwd bwd someP onceP in
theorem preN_pred {t : ℤ} {v w : W} (hp : PreN R val t w) (hR : R (t - 1) v w) :
    PreN R val (t - 1) v :=
  preN_of_exists R fwd bwd val someP onceP hR fun h hh _ hw => by
    obtain ⟨a, ha, hva⟩ := hp h hh hw
    exact ⟨a, ha.le, hva⟩

/-! ### `p` states at every earlier time -/

include fwd bwd someP onceP in
/-- Behind a `p` state there is a pre state at every earlier slice. -/
theorem preN_chain {a : ℤ} {w : W} (hv : val (a, w)) :
    ∀ k : ℕ, ∃ v, PreN R val (a - k - 1) v := by
  intro k
  induction k with
  | zero =>
    obtain ⟨v, hR⟩ := bwd a w
    refine ⟨v, ?_⟩
    simpa using preN_pred_of_val R fwd bwd val someP onceP hv hR
  | succ k ih =>
    obtain ⟨v, hpre⟩ := ih
    obtain ⟨v', hR⟩ := bwd (a - k - 1) v
    refine ⟨v', ?_⟩
    have := preN_pred R fwd bwd val someP onceP hpre hR
    rwa [show a - k - 1 - 1 = a - ((k + 1 : ℕ) : ℤ) - 1 by push_cast; ring] at this

include fwd bwd someP onceP succP in
/-- Behind a `p` state there is a `p` state at every earlier slice. -/
theorem val_chain {a : ℤ} {w : W} (hv : val (a, w)) (k : ℕ) : ∃ u, val (a - k, u) := by
  obtain ⟨v, hpre⟩ := preN_chain R fwd bwd val someP onceP hv k
  obtain ⟨g, hg, hgv⟩ := exists_path_through R fwd bwd (a - k - 1) v
  obtain ⟨u, -, hu⟩ := succP g hg (a - k - 1)
    (fun g' hg' h => hpre g' hg' (by rw [h, hgv]))
  refine ⟨u, ?_⟩
  rwa [show a - k - 1 + 1 = a - k by ring] at hu

/-! ### Forward post chains, backward post chains, and König -/

include fwd bwd someP onceP in
/-- The forward sequence from a `p` state consists of post states. -/
theorem postN_fwdSeq {s : ℤ} {u : W} (hv : val (s, u)) :
    ∀ j : ℕ, PostN R val (s + j + 1) (fwdSeq R fwd s u (j + 1)) := by
  intro j
  induction j with
  | zero =>
    have h0 := fwdSeq_spec R fwd s u 0
    simp only [Nat.cast_zero, add_zero, fwdSeq_zero] at h0
    have := postN_succ_of_val R fwd bwd val someP onceP hv h0
    simpa using this
  | succ j ih =>
    have := postN_succ R fwd bwd val someP onceP ih (by
      have h := fwdSeq_spec R fwd s u (j + 1)
      rwa [show s + ((j + 1 : ℕ) : ℤ) = s + j + 1 by push_cast; ring] at h)
    rwa [show s + j + 1 + 1 = s + ((j + 1 : ℕ) : ℤ) + 1 by push_cast; ring] at this

/-- A backward chain of `n` post steps into `(t, w)`, all of whose states are post. -/
def BackChain (t : ℤ) (w : W) (n : ℕ) : Prop :=
  ∃ c : ℕ → W, c 0 = w ∧ (∀ i, i < n → R (t - i - 1) (c (i + 1)) (c i)) ∧
    (∀ i, i ≤ n → PostN R val (t - i) (c i))

theorem backChain_mono {t : ℤ} {w : W} {m n : ℕ} (h : BackChain R val t w n) (hmn : m ≤ n) :
    BackChain R val t w m := by
  obtain ⟨c, hc0, hstep, hpost⟩ := h
  exact ⟨c, hc0, fun i hi => hstep i (by omega), fun i hi => hpost i (by omega)⟩

theorem postN_of_backChain {t : ℤ} {w : W} {n : ℕ} (h : BackChain R val t w n) :
    PostN R val t w := by
  obtain ⟨c, hc0, -, hpost⟩ := h
  have := hpost 0 (Nat.zero_le _)
  simpa [hc0] using this

include fwd bwd someP onceP succP in
/-- Backward post chains of every length end at slice `a`. -/
theorem exists_backChain {a : ℤ} {w : W} (hv : val (a, w)) (n : ℕ) :
    ∃ z, BackChain R val a z n := by
  obtain ⟨u, hu⟩ := val_chain R fwd bwd val someP onceP succP hv (n + 1)
  set s := a - ((n + 1 : ℕ) : ℤ) with hs
  refine ⟨fwdSeq R fwd s u (n + 1), fun i => fwdSeq R fwd s u (n + 1 - i), rfl, ?_, ?_⟩
  · intro i hi
    show R (a - i - 1) (fwdSeq R fwd s u (n + 1 - (i + 1))) (fwdSeq R fwd s u (n + 1 - i))
    have h := fwdSeq_spec R fwd s u (n - i)
    rw [show n - i + 1 = n + 1 - (i : ℕ) by omega] at h
    rw [show n + 1 - (i + 1) = n - i by omega]
    rwa [show s + ((n - i : ℕ) : ℤ) = a - i - 1 by rw [hs]; push_cast [Nat.cast_sub hi.le]; ring]
      at h
  · intro i hi
    show PostN R val (a - i) (fwdSeq R fwd s u (n + 1 - i))
    have h := postN_fwdSeq R fwd bwd val someP onceP hu (n - i)
    rw [show n - i + 1 = n + 1 - i by omega] at h
    rwa [show s + ((n - i : ℕ) : ℤ) + 1 = a - i by rw [hs]; push_cast [Nat.cast_sub hi]; ring]
      at h

include fwd bwd someP onceP succP in
/-- **Pigeonhole at slice `a`**: some state there is the end of backward post chains of every
length. -/
theorem exists_long {a : ℤ} {w : W} (hv : val (a, w)) :
    ∃ z, ∀ n, BackChain R val a z n := by
  classical
  by_contra hno
  simp only [not_exists, not_forall] at hno
  choose nz hnz using hno
  obtain ⟨N, hN⟩ := (Set.finite_range nz).bddAbove
  obtain ⟨z, hz⟩ := exists_backChain R fwd bwd val someP onceP succP hv N
  exact hnz z (backChain_mono R val hz (hN ⟨z, rfl⟩))

include fwd bwd onceP in
/-- **König's step**: a state with backward post chains of every length has a post predecessor
with backward post chains of every length. -/
theorem long_step {t : ℤ} {w : W} (hl : ∀ n, BackChain R val t w n) :
    ∃ v, R (t - 1) v w ∧ ∀ n, BackChain R val (t - 1) v n := by
  classical
  by_contra hno
  simp only [not_exists, not_and, not_forall] at hno
  let nv : W → ℕ := fun v => if h : R (t - 1) v w then Classical.choose (hno v h) else 0
  have hnv : ∀ v, R (t - 1) v w → ¬ BackChain R val (t - 1) v (nv v) := by
    intro v h
    simp only [nv, dif_pos h]
    exact Classical.choose_spec (hno v h)
  obtain ⟨N, hN⟩ := (Set.finite_range nv).bddAbove
  obtain ⟨c, hc0, hstep, hpost⟩ := hl (N + 1)
  have hR : R (t - 1) (c 1) w := by
    have := hstep 0 (by omega)
    simpa [hc0] using this
  apply hnv (c 1) hR
  refine backChain_mono R val (n := N) ⟨fun i => c (i + 1), rfl, ?_, ?_⟩ (hN ⟨c 1, rfl⟩)
  · intro i hi
    have := hstep (i + 1) (by omega)
    rwa [show t - ((i + 1 : ℕ) : ℤ) - 1 = t - 1 - i - 1 by push_cast; ring] at this
  · intro i hi
    have := hpost (i + 1) (by omega)
    rwa [show t - ((i + 1 : ℕ) : ℤ) = t - 1 - i by push_cast; ring] at this

/-- The infinite backward post chain, by iterated choice. -/
noncomputable def longSeq (x₀ : {x : ℤ × W // ∀ n, BackChain R val x.1 x.2 n}) :
    ℕ → {x : ℤ × W // ∀ n, BackChain R val x.1 x.2 n}
  | 0 => x₀
  | n + 1 =>
    ⟨((longSeq x₀ n).1.1 - 1, Classical.choose (long_step R fwd bwd val onceP (longSeq x₀ n).2)),
      (Classical.choose_spec (long_step R fwd bwd val onceP (longSeq x₀ n).2)).2⟩

theorem longSeq_time (x₀ : {x : ℤ × W // ∀ n, BackChain R val x.1 x.2 n}) (n : ℕ) :
    (longSeq R fwd bwd val onceP x₀ n).1.1 = x₀.1.1 - n := by
  induction n with
  | zero => simp [longSeq]
  | succ n ih =>
    show (longSeq R fwd bwd val onceP x₀ n).1.1 - 1 = _
    rw [ih]; push_cast; ring

theorem longSeq_step (x₀ : {x : ℤ × W // ∀ n, BackChain R val x.1 x.2 n}) (n : ℕ) :
    R ((longSeq R fwd bwd val onceP x₀ n).1.1 - 1) (longSeq R fwd bwd val onceP x₀ (n + 1)).1.2
      (longSeq R fwd bwd val onceP x₀ n).1.2 :=
  (Classical.choose_spec (long_step R fwd bwd val onceP (longSeq R fwd bwd val onceP x₀ n).2)).1

theorem longSeq_postN (x₀ : {x : ℤ × W // ∀ n, BackChain R val x.1 x.2 n}) (n : ℕ) :
    PostN R val (longSeq R fwd bwd val onceP x₀ n).1.1 (longSeq R fwd bwd val onceP x₀ n).1.2 :=
  postN_of_backChain R val ((longSeq R fwd bwd val onceP x₀ n).2 0)

include fwd bwd someP onceP succP in
/-- **The core contradiction**: `someP`, `onceP` and `succP` cannot all hold on a finite `W`. -/
theorem core_false : False := by
  classical
  obtain ⟨g₀, hg₀, -⟩ := exists_path_through R fwd bwd 0 (Classical.arbitrary W)
  obtain ⟨a, hva⟩ := someP g₀ hg₀
  obtain ⟨z, hz⟩ := exists_long R fwd bwd val someP onceP succP hva
  let x₀ : {x : ℤ × W // ∀ n, BackChain R val x.1 x.2 n} := ⟨(a, z), hz⟩
  let d : ℕ → W := fun i => (longSeq R fwd bwd val onceP x₀ i).1.2
  have hd_time : ∀ i, (longSeq R fwd bwd val onceP x₀ i).1.1 = a - i :=
    fun i => longSeq_time R fwd bwd val onceP x₀ i
  have hd0 : d 0 = z := rfl
  have hd_step : ∀ i : ℕ, R (a - i - 1) (d (i + 1)) (d i) := by
    intro i
    have := longSeq_step R fwd bwd val onceP x₀ i
    rwa [hd_time] at this
  have hd_post : ∀ i : ℕ, PostN R val (a - i) (d i) := by
    intro i
    have := longSeq_postN R fwd bwd val onceP x₀ i
    rwa [hd_time] at this
  let ff := fwdSeq R fwd a z
  let g : ℤ → W := fun s => if s ≤ a then d (a - s).toNat else ff (s - a).toNat
  have hg : IsPath R g := by
    intro s
    rcases lt_trichotomy s a with h1 | h1 | h1
    · have hs : s ≤ a := by omega
      have hs1 : s + 1 ≤ a := by omega
      simp only [g, if_pos hs, if_pos hs1]
      have e : (a - s).toNat = (a - (s + 1)).toNat + 1 := by omega
      rw [e]
      have := hd_step (a - (s + 1)).toNat
      rwa [show a - ((a - (s + 1)).toNat : ℤ) - 1 = s by omega] at this
    · subst h1
      have hs1 : ¬ s + 1 ≤ s := by omega
      simp only [g, le_refl, if_true, if_neg hs1, sub_self, Int.toNat_zero, hd0]
      have e2 : (s + 1 - s).toNat = 1 := by omega
      rw [e2]
      have := fwdSeq_spec R fwd s z 0
      simpa using this
    · have hs : ¬ s ≤ a := by omega
      have hs1 : ¬ s + 1 ≤ a := by omega
      simp only [g, if_neg hs, if_neg hs1]
      have e : (s + 1 - a).toNat = (s - a).toNat + 1 := by omega
      rw [e]
      have := fwdSeq_spec R fwd a z (s - a).toNat
      rwa [show a + ((s - a).toNat : ℤ) = s by omega] at this
  have hga : g a = z := by simp [g, hd0]
  obtain ⟨b, hb⟩ := someP g hg
  rcases le_or_gt b a with hba | hba
  · have hgb : g b = d (a - b).toNat := by simp [g, hba]
    rw [hgb] at hb
    have hpost := hd_post (a - b).toNat
    rw [show a - ((a - b).toNat : ℤ) = b by omega] at hpost
    exact not_val_of_postN R fwd bwd val onceP hpost hb
  · obtain ⟨b', hb', hvb'⟩ := hd_post 0 g hg (by
      show g (a - ((0 : ℕ) : ℤ)) = d 0
      rw [Nat.cast_zero, sub_zero, hga, hd0])
    have := onceP g hg b b' hb hvb'
    simp at hb'
    omega

end Core

/-! ### From the semantics on the sliced frame to the three path facts -/

variable [Finite W] [Nonempty W] (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w)

/-- The history of an offset-`0` path. -/
def pathHist (g : ℤ → W) (hg : IsPath R g) : WorldHistory (FrameOver.ofSlicedStep R fwd bwd) :=
  FrameOver.worldHistoryOfStepPath (FrameOver.ofSlicedStep R fwd bwd) (fun t => (t, g t))
    (fun n => (FrameOver.ofSlicedStep_step R fwd bwd _ _).mpr ⟨rfl, hg n⟩)

theorem pathHist_state (g : ℤ → W) (hg : IsPath R g) (s : ℤ) :
    (pathHist R fwd bwd g hg).state s = (s, g s) :=
  congrFun (FrameOver.worldHistoryOfStepPath.path _ _ _) s

/-- Every history is an offset path. -/
theorem hist_offset (σ : WorldHistory (FrameOver.ofSlicedStep R fwd bwd)) :
    ∃ (k : ℤ) (g : ℤ → W), IsPath R g ∧ ∀ v, σ.state v = (v + k, g (v + k)) := by
  obtain ⟨k, g₀, hg₀, hpath⟩ := (FrameOver.ofSlicedStep_mem_HF_iff R fwd bwd σ.path).mp ⟨σ, rfl⟩
  refine ⟨k, fun s => g₀ (s - k), ?_, ?_⟩
  · intro s
    have h := hg₀ (s - k)
    rwa [show s - k + k = s by ring, show s - k + 1 = s + 1 - k by ring] at h
  · intro v
    change σ.path v = _
    rw [congrFun hpath v]
    simp only [add_sub_cancel_right]
    rfl

/-- A history sharing the state `(s, w)` of an offset-`0` path at time `s` is itself offset `0`. -/
theorem hist_offset_zero (σ : WorldHistory (FrameOver.ofSlicedStep R fwd bwd)) {s : ℤ} {w : W}
    (h : σ.state s = (s, w)) :
    ∃ g : ℤ → W, IsPath R g ∧ g s = w ∧ ∀ v, σ.state v = (v, g v) := by
  obtain ⟨k, g, hg, hσ⟩ := hist_offset R fwd bwd σ
  have hk : k = 0 := by
    have := (hσ s).symm.trans h
    have := congrArg Prod.fst this
    simp at this
    omega
  subst hk
  refine ⟨g, hg, ?_, fun v => by simpa using hσ v⟩
  have := (hσ s).symm.trans h
  simpa using congrArg Prod.snd this

section Semantics

variable (M : TaskModel (FrameOver.ofSlicedStep R fwd bwd).toTaskFrame)

/-- `box ψ` at one history and time is `ψ` along every offset-`0` path at every time. -/
theorem box_transfer {ψ : PlusFormula} {τ : WorldHistory (FrameOver.ofSlicedStep R fwd bwd)}
    {t0 : ℤ} (h : PlusTruthAt M τ t0 (PlusFormula.box ψ)) (g : ℤ → W) (hg : IsPath R g)
    (s : ℤ) : PlusTruthAt M (pathHist R fwd bwd g hg) s ψ := by
  have := (plusTruthAt_timeShift M ψ (pathHist R fwd bwd g hg) t0 (s - t0)).mp
    (h ((pathHist R fwd bwd g hg).timeShift (s - t0)))
  rwa [show t0 + (s - t0) = s by ring] at this

theorem someP_of_A' {τ : WorldHistory (FrameOver.ofSlicedStep R fwd bwd)} {t0 : ℤ}
    (hA : PlusTruthAt M τ t0 A') (g : ℤ → W) (hg : IsPath R g) :
    ∃ a, M.valuation (a, g a) pa := by
  have h := box_transfer R fwd bwd M hA g hg 0
  simp only [PlusFormula.or, PlusFormula.neg, PlusTruthAt] at h
  by_contra hno
  have hno' : ∀ a, ¬ M.valuation (a, g a) pa := fun a ha => hno ⟨a, ha⟩
  have hp : ¬ PlusTruthAt M (pathHist R fwd bwd g hg) 0 p := by
    change ¬ M.valuation ((pathHist R fwd bwd g hg).state 0) pa
    rw [pathHist_state]
    exact hno' 0
  have hF : ¬ (∀ σ, (pathHist R fwd bwd g hg).state 0 = σ.state 0 →
      PlusTruthAt M σ 0 Fp) := by
    intro hst
    obtain ⟨(s' : ℤ), hs', hv, -⟩ := hst _ rfl
    change M.valuation ((pathHist R fwd bwd g hg).state s') pa at hv
    rw [pathHist_state] at hv
    exact hno' s' hv
  obtain ⟨(s' : ℤ), hs', hv, -⟩ := h hp hF _ rfl
  change M.valuation ((pathHist R fwd bwd g hg).state s') pa at hv
  rw [pathHist_state] at hv
  exact hno' s' hv

theorem onceP_of_C' {τ : WorldHistory (FrameOver.ofSlicedStep R fwd bwd)} {t0 : ℤ}
    (hC : PlusTruthAt M τ t0 C') (g : ℤ → W) (hg : IsPath R g) (a b : ℤ)
    (ha : M.valuation (a, g a) pa) (hb : M.valuation (b, g b) pa) : a = b := by
  have key : ∀ a b : ℤ, a < b → M.valuation (a, g a) pa → M.valuation (b, g b) pa → False := by
    intro a b hab ha hb
    have h := box_transfer R fwd bwd M hC g hg b
    simp only [PlusFormula.neg, PlusTruthAt] at h
    refine h ?_ _ rfl ⟨a, hab, ?_, fun _ _ _ hh => hh⟩
    · change M.valuation ((pathHist R fwd bwd g hg).state b) pa
      rw [pathHist_state]; exact hb
    · change M.valuation ((pathHist R fwd bwd g hg).state a) pa
      rw [pathHist_state]; exact ha
  rcases lt_trichotomy a b with h | h | h
  · exact (key a b h ha hb).elim
  · exact h
  · exact (key b a h hb ha).elim

theorem succP_of_D {τ : WorldHistory (FrameOver.ofSlicedStep R fwd bwd)} {t0 : ℤ}
    (hD : PlusTruthAt M τ t0 D) (g : ℤ → W) (hg : IsPath R g) (s : ℤ)
    (hpre : ∀ g', IsPath R g' → g' s = g s → ∃ a, s < a ∧ M.valuation (a, g' a) pa) :
    ∃ u, R s (g s) u ∧ M.valuation (s + 1, u) pa := by
  have h := box_transfer R fwd bwd M hD g hg s
  simp only [PlusFormula.neg, PlusTruthAt] at h
  have hstF : ∀ σ, (pathHist R fwd bwd g hg).state s = σ.state s →
      PlusTruthAt M σ s Fp := by
    intro σ hσ
    rw [pathHist_state] at hσ
    obtain ⟨g', hg', hgs, hσ'⟩ := hist_offset_zero R fwd bwd σ hσ.symm
    obtain ⟨a, ha, hva⟩ := hpre g' hg' hgs
    refine ⟨a, ha, ?_, fun _ _ _ hh => hh⟩
    change M.valuation (σ.state a) pa
    rw [hσ' a]; exact hva
  by_contra hno
  apply h hstF
  intro σ hσ hX
  rw [pathHist_state] at hσ
  obtain ⟨g', hg', hgs, hσ'⟩ := hist_offset_zero R fwd bwd σ hσ.symm
  obtain ⟨(s' : ℤ), hs', hv, hgap⟩ := hX
  have hs'' : (s : ℤ) < s' := hs'
  have hs1 : s' = s + 1 := by
    by_contra hne
    exact hgap (s + 1) (show (s : ℤ) < s + 1 by omega) (show (s + 1 : ℤ) < s' by omega)
  change M.valuation (σ.state s') pa at hv
  rw [hσ' s', hs1] at hv
  apply hno
  refine ⟨g' (s + 1), ?_, hv⟩
  rw [← hgs]; exact hg' s

/-- **No model on a finite-width sliced frame satisfies `Φ` anywhere.** -/
theorem no_finite_width_sat (τ : WorldHistory (FrameOver.ofSlicedStep R fwd bwd)) (t0 : ℤ) :
    ¬ PlusTruthAt M τ t0 Φ := by
  intro h
  have hA : PlusTruthAt M τ t0 A' := by
    by_contra hA
    exact h (fun h' => (h' (fun a => absurd a hA)).elim)
  have hC : PlusTruthAt M τ t0 C' := by
    by_contra hC
    exact h (fun h' => (h' (fun _ c => hC c)).elim)
  have hD : PlusTruthAt M τ t0 D := by
    by_contra hD
    exact h (fun _ d => hD d)
  exact core_false R fwd bwd (fun x => M.valuation x pa)
    (someP_of_A' R fwd bwd M hA) (onceP_of_C' R fwd bwd M hC) (succP_of_D R fwd bwd M hD)

end Semantics

end NoFiniteWidth

/-! ## The certificate corollaries -/

/-- **No time-sliced certificate certifies `Φ.neg`.** The frame a certificate presents is
`FrameOver.ofSlicedStep` on `Fin G.n`, and an accepted certificate puts a model of `Φ` on it at the
target position (the argument of `Sound.lean`'s `plusRefutes_of_certifies`, with the frame kept). -/
theorem not_certifies (G : PlusSlicedCertificate [] [Φ.neg]) : ¬ G.Certifies := by
  intro hc
  have h := G.biSerial_of_certifies hc
  have hbox := G.boxLabelFaithful_of_certifies hc
  have hTS := G.tailStable_of_certifies hc
  have hstab := G.stabFaithful_of_certifies hc
  have hblf := G.boxLiveFaithful_of_certifies hc
  have htgt := G.target_of_certifies hc
  obtain ⟨Rn, hRf, hRlab⟩ := G.exists_fulfilling_run_at_targetTime hc
  have hlab : G.target.lab G.targetTime = G.canLab Rn.st G.targetTime := by
    rw [← hRlab]
    exact G.lab_eq_canLab Rn hRf G.targetTime
  have hnot : ¬ PlusTruthAt (G.model h) (G.stepHistory h Rn.st Rn.steps) G.targetTime Φ.neg := by
    intro hT
    refine htgt.2 Φ.neg (List.mem_singleton_self _) ?_
    rw [hlab]
    exact (G.mem_canLab_iff_plusTruthAt h hbox hTS hstab hblf
      (plusConclusion_mem_closure (List.mem_singleton_self _)) Rn.st Rn.steps G.targetTime).mpr hT
  apply hnot
  intro hΦ
  exact no_finite_width_sat G.stepRel (G.stepRel_fwd h) (G.stepRel_bwd h) (G.model h)
    (G.stepHistory h Rn.st Rn.steps) G.targetTime hΦ

/-- **The time-sliced certificate class is incomplete for L⁺ over ℤ-time**: `Φ.neg` is a ℤ-time
non-validity, inside the CTL-like fragment, that no `PlusSlicedCertificate` certifies. -/
theorem not_sliced_complete :
    ¬ ∀ ψ : PlusFormula, ¬ PlusValidZTime ψ →
      ∃ G : PlusSlicedCertificate [] [ψ], G.Certifies := by
  intro hcomp
  obtain ⟨G, hG⟩ := hcomp Φ.neg not_plusValidZTime_neg_Φ
  exact not_certifies G hG

/-- **No certificate class presenting finite-width sliced frames is complete**, whatever its
clauses: there is no countermodel to `Φ.neg` on any `FrameOver.ofSlicedStep` frame over a finite
`W`. -/
theorem not_finite_width_fmp :
    ¬ ∀ φ : PlusFormula, ¬ PlusValidZTime φ →
      ∃ (W : Type) (_ : Finite W) (_ : Nonempty W) (R : ℤ → W → W → Prop)
        (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w)
        (M : TaskModel (FrameOver.ofSlicedStep R fwd bwd).toTaskFrame)
        (τ : WorldHistory (FrameOver.ofSlicedStep R fwd bwd)) (t : ℤ),
        ¬ PlusTruthAt M τ t φ := by
  intro fmp
  obtain ⟨W, _, _, R, fwd, bwd, M, τ, t, hτ⟩ := fmp Φ.neg not_plusValidZTime_neg_Φ
  exact hτ (fun hΦ => no_finite_width_sat R fwd bwd M τ t hΦ)

#print axioms no_finite_width_sat
#print axioms not_certifies
#print axioms not_sliced_complete
#print axioms not_finite_width_fmp

end Probe710
