/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Thread
import FormalSystem.Semantics.Validity
import FormalSystem.Semantics.FrameClassValidity
import Mathlib.Data.Int.SuccPred
import Mathlib.Order.SuccPred.LinearLocallyFinite

/-!
# The Branching Frame of a State-Sharing Witness Family

The deterministic device presents its model through `ShiftSet`, whose task relation is the
functional shift relation. That route is closed here by construction: a branching task relation
is not a function, so this module builds a `FrameOver intOrder` **directly**, and
`Semantics/ShiftSet.lean` is neither used nor modified.

## The carrier is a quotient, and only within a single time

World states are `share`-classes of index/time pairs: `(i, u)` and `(j, u)` name the same state
exactly when `share u i j`. Pairs at *different* times are never identified, so time is a
well-defined function on states (`SharingWitnessFamily.time`) and the frame is still a "flow"
whose duration is recoverable from its endpoints.

That per-time restriction is what makes the quotient lift of the task relation go through with
no extra compatibility field on `SharingWitnessFamily`: the four congruences
`reachN_congr_left`, `reachN_congr_right`, `step_congr_left` and `step_congr_right` are all the
compatibility the lift needs, and each is a consequence of `share` being an equivalence.

## One two-sided relation, not two

`FrameOver` takes its primitive on the positive cone and extends it by the reflection
convention. Rather than discharging each constraint against that extension, this module defines
the two-sided relation `RelZ` once, proves the reflection law for it, and then cites
`TaskFrame.compositional_reflect_of_reflective` and its three siblings — the same route
`ShiftSet.fibre_isRegular` takes.

`RelZ` factors through `SharingWitnessFamily.Conn`, a *duration-free* connectivity predicate on
raw pairs: forward reachability when the source is earlier, backward when it is later. Because
`Conn` mentions no duration, the reflection law is `conn_symm` plus an `omega` on the time
coordinate, rather than a case split on the sign of the duration inside every proof.

## Main Definitions

- `SharingWitnessFamily.shareSetoid` — the per-time sharing equivalence on `Fin |lassos| × ℤ`
- `SharingWitnessFamily.WorldState` — its quotient, the frame's carrier
- `SharingWitnessFamily.Conn` — duration-free connectivity between raw positions
- `SharingWitnessFamily.RelZ` — the two-sided task relation on states
- `SharingWitnessFamily.frame` — the branching `FrameOver intOrder`

## Main Results

- `SharingWitnessFamily.relZ_reflection` — the reflection law
- `SharingWitnessFamily.relZ_comp` — *Compositionality*, from `reachN_add`
- `SharingWitnessFamily.relZ_serial` — *Seriality*, from `reachN_const`
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

namespace SharingWitnessFamily

variable {Γ Del : Context}

/--
**The per-time sharing equivalence** on index/time pairs: `(i, u)` and `(j, v)` name the same
world state exactly when `u = v` and `share u i j`.

Pairs at different times are never identified, which is what keeps `time` well defined on the
quotient and the frame a flow.
-/
def shareSetoid (S : SharingWitnessFamily Γ Del) : Setoid (Fin S.lassos.length × ℤ) where
  r p q := p.2 = q.2 ∧ S.share p.2 p.1 q.1
  iseqv :=
    { refl := fun p => ⟨rfl, S.share_refl p.2 p.1⟩
      symm := by
        rintro p q ⟨ht, hs⟩
        exact ⟨ht.symm, by rw [← ht]; exact S.share_symm hs⟩
      trans := by
        rintro p q r ⟨ht₁, hs₁⟩ ⟨ht₂, hs₂⟩
        refine ⟨ht₁.trans ht₂, S.share_trans hs₁ ?_⟩
        rw [ht₁]
        exact hs₂ }

/-- The frame's carrier: `share`-classes of index/time pairs. -/
abbrev WorldState (S : SharingWitnessFamily Γ Del) : Type := Quotient S.shareSetoid

/-- The class of an index at a time. -/
def cls (S : SharingWitnessFamily Γ Del) (i : Fin S.lassos.length) (u : ℤ) : S.WorldState :=
  Quotient.mk S.shareSetoid (i, u)

theorem cls_eq {S : SharingWitnessFamily Γ Del} {i j : Fin S.lassos.length} {u v : ℤ}
    (hu : u = v) (hs : S.share u i j) : S.cls i u = S.cls j v :=
  Quotient.sound (⟨hu, hs⟩ : S.shareSetoid.r (i, u) (j, v))

theorem share_of_cls_eq {S : SharingWitnessFamily Γ Del} {i j : Fin S.lassos.length} {u v : ℤ}
    (h : S.cls i u = S.cls j v) : u = v ∧ S.share u i j :=
  Quotient.exact h

/-- Time is well defined on states, because the setoid never crosses a time. -/
def time (S : SharingWitnessFamily Γ Del) (C : S.WorldState) : ℤ :=
  Quotient.liftOn C (fun p => p.2) (fun _ _ h => h.1)

@[simp]
theorem time_cls (S : SharingWitnessFamily Γ Del) (i : Fin S.lassos.length) (u : ℤ) :
    S.time (S.cls i u) = u := rfl

/--
**Duration-free connectivity between raw positions.** Forward reachability when the source is
no later than the target, backward reachability otherwise. Symmetric by `conn_symm`, which is
what makes the reflection law cheap.
-/
def Conn (S : SharingWitnessFamily Γ Del) (p q : Fin S.lassos.length × ℤ) : Prop :=
  if p.2 ≤ q.2 then S.ReachN (q.2 - p.2).toNat p.2 p.1 q.1
  else S.ReachN (p.2 - q.2).toNat q.2 q.1 p.1

theorem conn_of_reachN {S : SharingWitnessFamily Γ Del} {n : ℕ} {u : ℤ}
    {i j : Fin S.lassos.length} (h : S.ReachN n u i j) : S.Conn (i, u) (j, u + (n : ℤ)) := by
  change (if u ≤ u + (n : ℤ) then S.ReachN ((u + (n : ℤ)) - u).toNat u i j
        else S.ReachN (u - (u + (n : ℤ))).toNat (u + (n : ℤ)) j i)
  rw [if_pos (by omega : u ≤ u + (n : ℤ)),
    show ((u + (n : ℤ)) - u).toNat = n from by omega]
  exact h

theorem conn_symm {S : SharingWitnessFamily Γ Del} {p q : Fin S.lassos.length × ℤ}
    (h : S.Conn p q) : S.Conn q p := by
  unfold Conn at h ⊢
  rcases lt_trichotomy p.2 q.2 with hlt | heq | hgt
  · rw [if_pos hlt.le] at h
    rw [if_neg (by omega)]
    exact h
  · rw [if_pos heq.le] at h
    rw [if_pos heq.ge]
    have h0 : (q.2 - p.2).toNat = 0 := by omega
    have h0' : (p.2 - q.2).toNat = 0 := by omega
    rw [h0] at h
    rw [h0', reachN_zero]
    rw [reachN_zero] at h
    rw [← heq]
    exact S.share_symm h
  · rw [if_neg (by omega)] at h
    rw [if_pos hgt.le]
    exact h

theorem conn_congr_left {S : SharingWitnessFamily Γ Del} {p p' q : Fin S.lassos.length × ℤ}
    (hp : p.2 = p'.2) (hs : S.share p.2 p.1 p'.1) (h : S.Conn p q) : S.Conn p' q := by
  unfold Conn at h ⊢
  rw [← hp]
  split at h
  · rename_i hle
    rw [if_pos hle]
    exact reachN_congr_left (S.share_symm hs) h
  · rename_i hle
    rw [if_neg hle]
    refine reachN_congr_right h ?_
    have hn : q.2 + (((p.2 - q.2).toNat : ℕ) : ℤ) = p.2 := by omega
    rw [hn]
    exact hs

theorem conn_congr_right {S : SharingWitnessFamily Γ Del} {p q q' : Fin S.lassos.length × ℤ}
    (hq : q.2 = q'.2) (hs : S.share q.2 q.1 q'.1) (h : S.Conn p q) : S.Conn p q' :=
  conn_symm (conn_congr_left hq hs (conn_symm h))

/--
**The two-sided task relation on states.** A duration `d` takes `C` to `C'` when the times
differ by `d` and the two raw positions are connected.
-/
def RelZ (S : SharingWitnessFamily Γ Del) (C : S.WorldState) (d : ℤ) (C' : S.WorldState) :
    Prop :=
  Quotient.liftOn₂ C C' (fun p q => q.2 = p.2 + d ∧ S.Conn p q)
    (by
      intro p₁ q₁ p₂ q₂ hp hq
      apply propext
      obtain ⟨hpt, hps⟩ := hp
      obtain ⟨hqt, hqs⟩ := hq
      constructor
      · rintro ⟨ht, hc⟩
        exact ⟨by omega, conn_congr_right hqt hqs (conn_congr_left hpt hps hc)⟩
      · rintro ⟨ht, hc⟩
        refine ⟨by omega, ?_⟩
        refine conn_congr_right hqt.symm ?_ (conn_congr_left hpt.symm ?_ hc)
        · rw [← hqt]; exact S.share_symm hqs
        · rw [← hpt]; exact S.share_symm hps)

@[simp]
theorem relZ_cls (S : SharingWitnessFamily Γ Del) (i j : Fin S.lassos.length) (u v d : ℤ) :
    S.RelZ (S.cls i u) d (S.cls j v) ↔ (v = u + d ∧ S.Conn (i, u) (j, v)) := Iff.rfl

/-- **The reflection law.** Reversing a duration reverses the relation; `Conn` is duration-free
and symmetric, so only the time coordinate has to move. -/
theorem relZ_reflection (S : SharingWitnessFamily Γ Del) :
    ∀ (C : S.WorldState) (d : ℤ) (C' : S.WorldState), S.RelZ C d C' ↔ S.RelZ C' (-d) C := by
  intro C d C'
  induction C using Quotient.inductionOn with
  | _ p =>
    induction C' using Quotient.inductionOn with
    | _ q =>
      constructor
      · rintro ⟨ht, hc⟩
        exact ⟨by omega, conn_symm hc⟩
      · rintro ⟨ht, hc⟩
        exact ⟨by omega, conn_symm hc⟩

/-- Every state is the class of some index at its own time. -/
theorem exists_cls (S : SharingWitnessFamily Γ Del) (C : S.WorldState) :
    ∃ i : Fin S.lassos.length, C = S.cls i (S.time C) := by
  induction C using Quotient.inductionOn with
  | _ p => exact ⟨p.1, by cases p; rfl⟩

/-- **Compositionality** for the branching relation, from `reachN_add`. -/
theorem relZ_comp (S : SharingWitnessFamily Γ Del) : TaskFrame.Compositional S.RelZ := by
  intro C C'' x y hx hy
  induction C using Quotient.inductionOn with
  | _ p =>
    induction C'' using Quotient.inductionOn with
    | _ r =>
      constructor
      · rintro ⟨ht, hc⟩
        have hle : p.2 ≤ r.2 := by omega
        unfold Conn at hc
        rw [if_pos hle] at hc
        have hsplit : (r.2 - p.2).toNat = x.toNat + y.toNat := by omega
        rw [hsplit] at hc
        obtain ⟨k, h₁, h₂⟩ := (S.reachN_add x.toNat y.toNat p.2 p.1 r.1).mp hc
        refine ⟨S.cls k (p.2 + x), ⟨by omega, ?_⟩, ⟨by omega, ?_⟩⟩
        · have := conn_of_reachN h₁
          have hx' : p.2 + ((x.toNat : ℕ) : ℤ) = p.2 + x := by omega
          rwa [hx'] at this
        · have := conn_of_reachN (u := p.2 + ((x.toNat : ℕ) : ℤ)) h₂
          have hx' : p.2 + ((x.toNat : ℕ) : ℤ) = p.2 + x := by omega
          rw [hx'] at this
          have hy' : p.2 + x + ((y.toNat : ℕ) : ℤ) = r.2 := by omega
          rwa [hy'] at this
      · rintro ⟨C', h₁, h₂⟩
        revert h₁ h₂
        induction C' using Quotient.inductionOn with
        | _ q =>
          rintro ⟨ht₁, hc₁⟩ ⟨ht₂, hc₂⟩
          refine ⟨by omega, ?_⟩
          unfold Conn at hc₁ hc₂ ⊢
          rw [if_pos (by omega : p.2 ≤ q.2)] at hc₁
          rw [if_pos (by omega : q.2 ≤ r.2)] at hc₂
          rw [if_pos (by omega : p.2 ≤ r.2)]
          have hsplit : (r.2 - p.2).toNat = (q.2 - p.2).toNat + (r.2 - q.2).toNat := by omega
          rw [hsplit]
          refine (S.reachN_add _ _ p.2 p.1 r.1).mpr ⟨q.1, hc₁, ?_⟩
          have hq' : p.2 + (((q.2 - p.2).toNat : ℕ) : ℤ) = q.2 := by omega
          rw [hq']
          exact hc₂

/-- **Seriality** for the branching relation: staying on one lasso is always available in both
directions. -/
theorem relZ_serial (S : SharingWitnessFamily Γ Del) : TaskFrame.Serial S.RelZ := by
  intro C x hx
  induction C using Quotient.inductionOn with
  | _ p =>
    obtain ⟨i, u⟩ := p
    refine ⟨⟨S.cls i (u + x), ?_⟩, ⟨S.cls i (u - x), ?_⟩⟩
    · refine ⟨rfl, ?_⟩
      have h := conn_of_reachN (S.reachN_const x.toNat u i)
      rwa [show u + ((x.toNat : ℕ) : ℤ) = u + x from by omega] at h
    · refine ⟨show (u : ℤ) = u - x + x from by omega, ?_⟩
      have h := conn_of_reachN (S.reachN_const x.toNat (u - x) i)
      rwa [show u - x + ((x.toNat : ℕ) : ℤ) = u from by omega] at h

/--
**The branching frame.** Built as a literal `FrameOver intOrder`; nothing here routes through
`ShiftSet`, whose task relation is functional by construction.
-/
def frame (S : SharingWitnessFamily Γ Del) : FrameOver intOrder where
  WorldState := S.WorldState
  worldNonempty := ⟨S.cls S.mainIdx 0⟩
  PosRel := fun C x C' => S.RelZ C (x : ↑intOrder) C'

/-- **The frame's task relation is the two-sided relation.** The frame's primitive is `RelZ`
restricted to the positive cone, and `RelZ` satisfies the reflection law, so the reflection
convention recovers it on the nose. -/
@[simp]
theorem frame_taskRel (S : SharingWitnessFamily Γ Del) (C : S.WorldState) (d : ℤ)
    (C' : S.WorldState) : S.frame.TaskRel C d C' ↔ S.RelZ C d C' :=
  TaskFrame.reflect_restrict_iff (R := S.RelZ) S.relZ_reflection

/-- *Compositionality* at the frame's own task relation. -/
theorem frame_comp (S : SharingWitnessFamily Γ Del) :
    TaskFrame.Compositional S.frame.TaskRel :=
  TaskFrame.compositional_reflect_of_reflective S.relZ_reflection S.relZ_comp

/-- *Seriality* at the frame's own task relation. -/
theorem frame_serial (S : SharingWitnessFamily Γ Del) :
    TaskFrame.Serial S.frame.TaskRel :=
  TaskFrame.serial_reflect_of_reflective S.relZ_reflection S.relZ_serial

/-! ### The four `def:frame` constraints, and the ℤ-time instances

Limit and Saturation need **no new frame-axiom argument**: the first is
`TaskFrame.limit_of_succOrder` at the zero-duration law, which asks only that a zero-duration
transition is the identity — never that the relation is functional; the second is
`TaskFrame.saturation_of_fib_finite`, whose docstring names exactly this case, an infinite
carrier with finite fibres. Determinism is nowhere used.
-/

/-- **The zero-duration law.** A zero-duration transition is the identity of states — the whole
hypothesis `TaskFrame.limit_of_succOrder` needs. -/
theorem relZ_zero (S : SharingWitnessFamily Γ Del) :
    ∀ C C' : S.WorldState, S.RelZ C 0 C' → C' = C := by
  intro C C'
  induction C using Quotient.inductionOn with
  | _ p =>
    induction C' using Quotient.inductionOn with
    | _ q =>
      rintro ⟨ht, hc⟩
      have heq : p.2 = q.2 := by omega
      unfold Conn at hc
      rw [if_pos (le_of_eq heq)] at hc
      rw [show (q.2 - p.2).toNat = 0 from by omega, reachN_zero] at hc
      refine Quotient.sound (⟨heq.symm, ?_⟩ : S.shareSetoid.r q p)
      rw [← heq]
      exact S.share_symm hc

/-- The time coordinate advances by the duration. -/
theorem time_of_relZ (S : SharingWitnessFamily Γ Del) (d : ℤ) :
    ∀ C C' : S.WorldState, S.RelZ C d C' → S.time C' = S.time C + d := by
  intro C C'
  induction C using Quotient.inductionOn with
  | _ p =>
    induction C' using Quotient.inductionOn with
    | _ q => exact fun h => h.1

/-- **Limit**, by `TaskFrame.limit_of_succOrder`: over the discrete integer duration the only
arbitrarily-small transition is the zero one. -/
theorem relZ_limit (S : SharingWitnessFamily Γ Del) :
    ∀ C C' : S.WorldState, (∀ x : ℤ, 0 < x → ∃ y, |y| < x ∧ S.RelZ C y C') → C' = C :=
  TaskFrame.limit_of_succOrder S.relZ_zero

/-- **Fibres are finite.** At a fixed source and duration, every target lies at one fixed time,
where there are at most `|lassos|` classes. The carrier itself is infinite, which is exactly the
case `TaskFrame.saturation_of_fib_finite` is for. -/
theorem relZ_fib_finite (S : SharingWitnessFamily Γ Del) (C : S.WorldState) (d : ℤ) :
    (TaskFrame.Fib S.RelZ C d).Finite := by
  refine Set.Finite.subset (Set.finite_range
    (fun i : Fin S.lassos.length => S.cls i (S.time C + d))) ?_
  intro C' hC'
  have ht := S.time_of_relZ d C C' hC'
  obtain ⟨j, hj⟩ := S.exists_cls C'
  exact ⟨j, by rw [← ht]; exact hj.symm⟩

/-- **Saturation**, by `TaskFrame.saturation_of_fib_finite`. -/
theorem relZ_saturation (S : SharingWitnessFamily Γ Del) : TaskFrame.Saturation S.RelZ :=
  TaskFrame.saturation_of_fib_finite S.relZ_fib_finite

/-- *Limit* at the frame's own task relation. -/
theorem frame_limit (S : SharingWitnessFamily Γ Del) : TaskFrame.Limit S.frame.TaskRel :=
  TaskFrame.limit_reflect_of_reflective S.relZ_reflection S.relZ_limit

/-- *Saturation* at the frame's own task relation. -/
theorem frame_saturation (S : SharingWitnessFamily Γ Del) :
    TaskFrame.Saturation S.frame.TaskRel :=
  TaskFrame.saturation_reflect_of_reflective S.relZ_reflection S.relZ_saturation

/-- **The branching frame is regular.** All four constraints, none of them using determinism. -/
instance instIsRegular (S : SharingWitnessFamily Γ Del) : S.frame.IsRegular where
  comp := S.frame_comp
  serial := S.frame_serial
  limit := S.frame_limit
  saturation := S.frame_saturation

/-- Regularity at the total space as well as at the fibre: instance synthesis does not project
through `FrameOver.toTaskFrame` on its own. -/
instance instIsRegularTask (S : SharingWitnessFamily Γ Del) :
    S.frame.toTaskFrame.IsRegular :=
  S.instIsRegular

/-- **The branching frame is a ℤ-time frame.** Applied with an explicit `@` and four
`inferInstanceAs` arguments: a `haveI` shadows the `SuccOrder` instance that `IsSuccArchimedean`
is indexed by, and the application then fails to elaborate. -/
theorem frame_isZTime (S : SharingWitnessFamily Γ Del) : S.frame.toTaskFrame.IsZTime :=
  @TaskFrame.isZTime_of_instances S.frame.toTaskFrame
    (inferInstanceAs (SuccOrder ℤ)) (inferInstanceAs (PredOrder ℤ))
    (inferInstanceAs (IsSuccArchimedean ℤ)) (inferInstanceAs (IsPredArchimedean ℤ))

/-- The branching frame satisfies the ℤ-time frame class. -/
theorem frame_sat_ztime (S : SharingWitnessFamily Γ Del) :
    FormalSystem.ProofSystem.FrameClass.ZTime.Sat S.frame.toTaskFrame :=
  ⟨inferInstance, S.frame_isZTime⟩

/-- The branching frame satisfies the unconstrained frame class, by antitonicity. -/
theorem frame_sat_base (S : SharingWitnessFamily Γ Del) :
    FormalSystem.ProofSystem.FrameClass.Base.Sat S.frame.toTaskFrame :=
  FormalSystem.ProofSystem.FrameClass.Sat.anti (by decide) S.frame_sat_ztime

end SharingWitnessFamily

end FormalSystem.Metalogic.Decidability
