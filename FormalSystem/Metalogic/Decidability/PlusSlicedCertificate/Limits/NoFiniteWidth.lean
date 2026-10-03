/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Init
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Sound
import FormalSystem.Semantics.SlicedFrame
import FormalSystem.Semantics.IntNormalForm
import FormalSystem.PlusLanguage.PlusValidity
import Mathlib.Tactic.Ring

/-!
# The Time-Sliced Certificate Class Is Incomplete for L⁺: the Finite-Width Obstruction

The witness is

  `Φ := (A' ∧ C') ∧ D`

where `A' := □(p ∨ ⊡Fp ∨ ⊡Pp)` and `C' := □(p → ⊡¬Pp)` together say "every history meets `p`
exactly once" (`Fp := ⊤ U p`, `Pp := ⊤ S p`), and `D := □(⊡Fp → ¬⊡¬Xp)` says: at every state all of
whose histories still have `p` strictly ahead (a *pre* state), some history reaches `p` at the very
next time (`Xp := ⊥ U p`, "`p` at the next time"). Every `⊡` and `□` in `Φ` governs a state formula
or a single temporal operator over state formulas, so `Φ` lies in the CTL-like fragment.

## The argument, in six steps

1. **A model of `Φ` exists.** `F`/`M` below is a countable, finitely branching, time-homogeneous
   regular ℤ-frame with carrier `Node = {pre k} ∪ {x k} ∪ {post k j}` and steps
   `pre (k+1) → pre k`, `pre k → x k`, `x k → post k 0`, `post k j → post k (j+1)`. Every
   bi-infinite step path of `F` is `… pre (k+2), pre (k+1), pre k, x k, post k 0, post k 1, …` for
   one `k` and one position of `x k` (`path_eq_canon`), so verifying `Φ` is a case split on the
   position of time `0` relative to that `x`. `not_plusValidZTime_neg_Φ` lands this half.
2. **No model on a finite-width sliced frame satisfies `Φ` anywhere.** The frame is
   `FrameOver.ofSlicedStep R fwd bwd` with `[Finite W]` — the frame every `PlusSlicedCertificate`
   presents. Classify every state as `p`, *pre* (every history through it has `p` strictly ahead)
   or *post* (strictly behind).
3. Predecessors of a `p` state are pre (`preN_pred_of_val`), so by `D` there is a `p` state at every
   earlier time (`val_chain`): the `p` times extend arbitrarily far into the past from any one of
   them.
4. Successors of a `p` state, or of a post state, are post (`postN_succ_of_val`, `postN_succ`).
5. A post state has no infinite backward chain of post predecessors: such a chain, pasted with any
   forward path, is a history with no `p` at all, contradicting `A'`/`C'` (`core_false`'s König
   step, `long_step`). With finitely many predecessors per state (`[Finite W]`), this bounds, for
   each post state, the length of backward post-chains reaching it.
6. But the forward post-chains from the `p` states at times `a - n - 1` (for a fixed `p`-time `a`
   and every `n : ℕ`) reach time `a` as backward post-chains of every length `n`
   (`exists_backChain`), and there are only finitely many states at time `a` — pigeonhole
   (`exists_long`) forces a single state to be the end of backward post-chains of unbounded length,
   contradicting step 5. `no_finite_width_sat` lands this half.

Consequence (`not_sliced_complete`, `not_certifies`): `Φ.neg` is a ℤ-time non-validity of L⁺ that no
`PlusSlicedCertificate` certifies. `not_finite_width_fmp` restates this as a frame-class
obstruction: the width of a countermodel of `Φ.neg` — the number of states per time — is
necessarily infinite, so no certificate class presenting a frame with finite per-time fibres is
complete for L⁺, and already not for the CTL-like fragment.

## Scope, stated so the result is not over-read

Two limits carry over from
`FormalSystem/Metalogic/Decidability/FMP/README.md`'s "The finite-carrier route is refuted, not
merely open" section, which records the companion finite-*carrier* refutation beside this one:

- **Scope is ℤ (discrete) frames only.** The pumping argument (steps 3-6 above) needs discreteness
  and says nothing about a dense duration.
- **`Φ` uses `⊡`** (`PlusFormula.stab`), so this half of the refutation is specifically an **L⁺**
  result, not a result about the base language TM — in contrast with a `⊡`-free finite-carrier
  witness, whose membership in the image of `ofFormula` is what would make that other half a
  statement about TM itself.

Two further disclaimers, also carried from that section: **nothing** here is claimed about an
*infinite* carrier (only about finite per-time fibres over an infinite carrier), and **nothing**
here touches soundness — `PlusSlicedCertificate.Sound`'s `plusRefutes_of_certifies` is untouched and
unused in the refuting direction.

**Not claimed**: no width bound for targets that *do* have a finite-width countermodel; no
obstruction to a wider certificate class presenting infinite per-time fibres.

## Main results

- `not_plusValidZTime_neg_Φ` — `Φ.neg` is a ℤ-time non-validity of L⁺ (the positive half)
- `no_finite_width_sat` — no model on a finite-width `FrameOver.ofSlicedStep` frame satisfies `Φ`
  anywhere (the negative half; the core refutation)
- `not_certifies` — no `PlusSlicedCertificate [] [Φ.neg]` certifies `Φ.neg`
- `not_sliced_complete` — the time-sliced certificate class is incomplete for L⁺ over ℤ-time
- `not_finite_width_fmp` — no certificate class presenting finite-width sliced frames is complete
  for L⁺, whatever its clauses

## Tags

plus-language · certificate · time-sliced · completeness · finite-model-property · finite-width
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage

namespace PlusSlicedCertificate

-- The single-letter definitions below (`p`, `D`, `F`, `M`, `Φ`, `A'`, `C'`) are nested in their
-- own namespace so that they do not land in `PlusSlicedCertificate` itself.
namespace NoFiniteWidth

/-! ## The witness formula -/

def pa : Atom := ⟨"p", none⟩
def p : PlusFormula := PlusFormula.atom pa
/-- `Fp := ⊤ U p`: `p` somewhere ahead. -/
def Fp : PlusFormula := PlusFormula.untl PlusFormula.top p
/-- `Pp := ⊤ S p`: `p` somewhere behind. -/
def Pp : PlusFormula := PlusFormula.snce PlusFormula.top p
/-- `Xp := ⊥ U p`: `p` at the next time. -/
def Xp : PlusFormula := PlusFormula.untl PlusFormula.bot p
/-- `□(p ∨ ⊡Fp ∨ ⊡Pp)`: every history is at `p`, has `p` ahead, or has `p` behind. -/
def A' : PlusFormula := PlusFormula.box (p.or ((PlusFormula.stab Fp).or (PlusFormula.stab Pp)))
/-- `□(p → ⊡¬Pp)`: at a `p` state, no history has `p` behind. Together with `A'`: every history
meets `p` exactly once. -/
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

/-- **`Φ.neg` is a ℤ-time non-validity of L⁺.** The witnessing model `F`/`M` is **finitely
branching** (every state has one or two successors and exactly one predecessor, `step_fwd`,
`step_bwd`, `fwdList`, `bwdList`), so what separates it from a time-sliced certificate's frame is
not a failure of König's lemma — König's lemma holds for it. What separates it is **width**: at
any time the carrier has infinitely many `pre`/`post` states, of unbounded age (how far `post k j`
is from its `x k`) and unbounded distance to go (how far `pre (k + i)` is from its `x k`), no two
of which are two-way bisimilar (distinct threads `k ≠ k'` never meet again). Those two facts are
the whole point of the model.

Paper: — (the formalization's own refutation; no counterpart in the cited paper)
-/
theorem not_plusValidZTime_neg_Φ : ¬ PlusValidZTime Φ.neg := by
  intro hv
  exact hv F ⟨F_isRegular, F_isZTime⟩ M (histOf 0 0) 0 Φ_true

end NoFiniteWidth

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
