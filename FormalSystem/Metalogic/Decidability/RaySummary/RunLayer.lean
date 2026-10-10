/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.SlicedFrame

/-!
# The run layer's frame scheme: a finitely branching sliced constructor and the deadline ladder

Requirement (W)'s run layer (`RaySummary/README.md`, "(W): what landed and what did not") is
blocked on three obligations, the first of which is a **frame-scheme constructor** producing
infinite-width, finitely branching regular `ℤ`-frames from a finite object. This module lands
the regularity part of that obligation, and nothing more.

## The design decision

The scheme is **thread-indexed unfolding in its general form, the deadline ladder**: a state
carries, beside its object state `q`, two counters — the current deadline `c`, counting down
deterministically while a `⊡`-forced eventuality is pending and sitting at `0` while idle, and
the next deadline `n`, which drifts by at most one per step at EVERY step — so that no state
ever chooses a deadline. Both bounded-deadline alternatives are refuted by landed theorems:

* a **fixed cap** on the counters gives a finite slice, and every finite-width `ofSlicedStep`
  model validates the `ℤ`-time non-validity `Φ.neg`
  (`not_finite_width_fmp`, `PlusSlicedCertificate/Limits/NoFiniteWidth.lean`);
* a **state-chosen deadline** is infinite-branching on whichever side it fires
  (`Rok_fwd_infinite`, `Rbad_bwd_infinite`, `b2b-frame-constructor-branching.lean`), and
  `Saturation` for a sliced frame needs two-sided finite branching.

The ladder relation `Rlad` over `Q × ℕ × ℕ` has two-sided finite branching for EVERY finite
object (`Rlad_fwd`, `Rlad_bwd`) and an infinite slice (`Rlad_slice_infinite`), which is exactly
the shape `not_finite_width_fmp` demands and `ofSlicedStep` cannot build. The `Node` shape of
`Limits/NoFiniteWidth.lean` is the one-region special case.

**Depth.** The run layer needs `k = 1`: every landed bridge it consumes carries `hk : 1 ≤ k` and
nothing asks more, and run conditions are enforced structurally by the object's step relation
(as `Cons` does for requirement (S)), never read off `k`-types.

## What this module holds

* The branching core — `FwdFinBranch`, `BwdFinBranch`, `iterS_fwd_finite`, `iterS_bwd_finite`,
  `fib_finite_of_finBranch`, `saturation_of_finBranch` — transcribed from the wired probe
  `b2b-frame-constructor-branching.lean` (Probe746), which sits outside the Lake build graph
  and is untouched.
* `ofSlicedStepFinBranch`: `FrameOver.ofSlicedStep`'s body with the `[Finite W]`-gated
  `Saturation` discharge replaced by `saturation_of_finBranch`. No carrier finiteness anywhere;
  `Semantics/SlicedFrame.lean` is not modified (the constructor is parallel, never in place).
  With it: regularity, the one-step characterization, the record that the carrier is infinite,
  and the history-space characterization `ofSlicedStepFinBranch_mem_HF_iff`.
* The deadline ladder — `Drift`, `Count`, `Rlad` — with `Rlad_fwd`, `Rlad_bwd`,
  `Rlad_slice_infinite`, and the frame `ladderFrame` it yields through the constructor.

## What this module does not hold

* **Seriality** is an object condition: `ladderFrame` takes `fwd`/`bwd` as explicit hypotheses
  exactly as `ofSlicedStep` does. A pending state at `c = 0` needs a discharging successor, and
  which objects supply one is the admissibility restriction the README names and does not cost.
* **No realization theorem** (the run layer's phase 2): nothing here says a ladder state
  realizes any closure type, states `HitPresented`, or constructs a model.
* **No general completeness row** (the run layer's phase 3, (C)'s general row): open.
* Nothing mentions `PlusValidZTime`, and `Decidable (PlusValidZTime φ)` is not stated in any
  form. No complexity bound, upper or lower. `Nat.card` and every cell count elsewhere in this
  cluster is a count, never a bound on a procedure.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Semantics FormalSystem.Semantics.TaskFrame

/-! ## The branching core (transcribed from `b2b-frame-constructor-branching.lean`) -/

/-- Forward finite branching of a time-indexed one-step relation. Transcribed from the wired
probe `b2b-frame-constructor-branching.lean`, which is untouched. -/
def FwdFinBranch {W : Type} (R : ℤ → W → W → Prop) : Prop :=
  ∀ t w, {u | R t w u}.Finite

/-- Backward finite branching: the **preimage** side, which finiteness is not stable under.
Transcribed from `b2b-frame-constructor-branching.lean`, which is untouched. -/
def BwdFinBranch {W : Type} (R : ℤ → W → W → Prop) : Prop :=
  ∀ t u, {w | R t w u}.Finite

/-- The `n`-step forward image of one state is finite under forward finite branching.
Transcribed from `b2b-frame-constructor-branching.lean`. -/
theorem iterS_fwd_finite {W : Type} (R : ℤ → W → W → Prop) (hf : FwdFinBranch R) :
    ∀ (n : ℕ) (t : ℤ) (w : W), {u | iterS R n t w u}.Finite := by
  intro n
  induction n with
  | zero =>
    intro t w
    have : {u | iterS R 0 t w u} = {w} := by ext u; simp [iterS, eq_comm]
    rw [this]; exact Set.finite_singleton w
  | succ n ih =>
    intro t w
    have hrw : {u | iterS R (n + 1) t w u}
        = ⋃ v ∈ {v | iterS R n t w v}, {u | R (t + n) v u} := by
      ext u; simp [iterS]
    rw [hrw]
    exact Set.Finite.biUnion (ih t w) (fun v _ => hf (t + n) v)

/-- The `n`-step backward **preimage** of one state is finite under backward finite branching.
Transcribed from `b2b-frame-constructor-branching.lean`. -/
theorem iterS_bwd_finite {W : Type} (R : ℤ → W → W → Prop) (hb : BwdFinBranch R) :
    ∀ (n : ℕ) (t : ℤ) (u : W), {w | iterS R n t w u}.Finite := by
  intro n
  induction n with
  | zero =>
    intro t u
    have : {w | iterS R 0 t w u} = {u} := by ext w; simp [iterS]
    rw [this]; exact Set.finite_singleton u
  | succ n ih =>
    intro t u
    have hrw : {w | iterS R (n + 1) t w u}
        = ⋃ v ∈ {v | R (t + n) v u}, {w | iterS R n t w v} := by
      ext w
      simp only [iterS_succ, Set.mem_setOf_eq, Set.mem_iUnion, exists_prop]
      exact ⟨fun ⟨v, h1, h2⟩ => ⟨v, h2, h1⟩, fun ⟨v, h1, h2⟩ => ⟨v, h2, h1⟩⟩
    rw [hrw]
    exact Set.Finite.biUnion (hb (t + n) u) (fun v _ => ih t v)

/--
**Finite fibres from two-sided finite branching alone** — no `[Finite W]`, so the carrier's slice
may be infinite. Two-sidedness is not optional: `TaskFrame.Fib` is taken at negative durations
too, where `ofSlicedStepRel` reads the iteration in the opposite direction, so the fibre is the
step relation's preimage there. Transcribed from `b2b-frame-constructor-branching.lean`.
-/
theorem fib_finite_of_finBranch {W : Type} (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R) :
    ∀ (p : ℤ × W) (d : ℤ), (TaskFrame.Fib (ofSlicedStepRel R) p d).Finite := by
  intro p d
  rcases le_or_gt 0 d with hd | hd
  · -- forward: the fibre injects into `{p.1 + d} × (n-step image of p.2)`
    refine Set.Finite.subset
      ((Set.finite_singleton (p.1 + d)).prod (iterS_fwd_finite R hf d.natAbs p.1 p.2)) ?_
    intro q hq
    have h : ofSlicedStepRel R p d q := hq
    exact ⟨h.1, h.2.1 hd⟩
  · -- backward: the fibre injects into `{p.1 + d} × (n-step preimage of p.2)`
    refine Set.Finite.subset
      ((Set.finite_singleton (p.1 + d)).prod
        (iterS_bwd_finite R hb d.natAbs (p.1 + d) p.2)) ?_
    intro q hq
    have h : ofSlicedStepRel R p d q := hq
    refine ⟨h.1, ?_⟩
    have h2 := h.2.2 (le_of_lt hd)
    rwa [h.1] at h2

/-- **Saturation from two-sided finite branching alone**, carrier-agnostic: the one slot in
which `ofSlicedStepFinBranch` differs from `FrameOver.ofSlicedStep`. Transcribed from
`b2b-frame-constructor-branching.lean`. -/
theorem saturation_of_finBranch {W : Type} (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R) :
    TaskFrame.Saturation (ofSlicedStepRel R) :=
  TaskFrame.saturation_of_fib_finite (fib_finite_of_finBranch R hf hb)

/-! ## The finitely branching sliced constructor -/

/--
**Frame synthesis over a sliced carrier under finite branching**: `FrameOver.ofSlicedStep`'s body
with the `[Finite W]`-gated `ofSlicedStep_saturation` replaced by `saturation_of_finBranch` in
its one `Saturation` slot, and `[Finite W]` dropped. The four other field discharges
(`ofSlicedStepRel_reflect`, `ofSlicedStep_compositional`, `ofSlicedStep_serial`,
`ofSlicedStep_limit`) carry no carrier finiteness and are reused unchanged.

This is a **parallel** constructor: `Semantics/SlicedFrame.lean` is not modified, and
`ofSlicedStep` is not reducible to this one (its `[Finite W]` is exactly what is given up).
-/
def ofSlicedStepFinBranch {W : Type} [Nonempty W] (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w) : FrameOver intOrder :=
  FrameOver.ofReflectiveRegular (ℤ × W) (ofSlicedStepRel R)
    (fun p d q => ofSlicedStepRel_reflect R p d q)
    (ofSlicedStep_compositional R)
    (ofSlicedStep_serial R fwd bwd)
    (ofSlicedStep_limit R)
    (saturation_of_finBranch R hf hb)

/-- **`ofSlicedStepFinBranch` is regular**, through the regular constructor's auto-instance. -/
instance ofSlicedStepFinBranch_isRegular {W : Type} [Nonempty W] (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w) :
    (ofSlicedStepFinBranch R hf hb fwd bwd).IsRegular :=
  FrameOver.instIsRegularOfReflective _ _ _ _ _ _ _

@[simp]
theorem ofSlicedStepFinBranch_taskRel {W : Type} [Nonempty W] (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w) :
    (ofSlicedStepFinBranch R hf hb fwd bwd).TaskRel = ofSlicedStepRel R :=
  FrameOver.ofReflectiveRegular_taskRel_eq

/-- The one-step relation of the synthesized frame advances the slice by one and steps along
`R`. -/
theorem ofSlicedStepFinBranch_step {W : Type} [Nonempty W] (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w) (p q : ℤ × W) :
    (ofSlicedStepFinBranch R hf hb fwd bwd).step p q ↔ q.1 = p.1 + 1 ∧ R p.1 p.2 q.2 := by
  change (ofSlicedStepFinBranch R hf hb fwd bwd).TaskRel p 1 q ↔ _
  rw [ofSlicedStepFinBranch_taskRel, ofSlicedStepRel_of_nonneg (zero_le_one : (0 : ℤ) ≤ 1)]
  simp only [Int.natAbs_one, iterS_one]

/-- **The synthesized frame's carrier is not finite**: `ℤ × W` is infinite through `ℤ`, whatever
`W` is. Recorded as a theorem so that no finite-carrier reading of this constructor is
available. -/
theorem ofSlicedStepFinBranch_not_finite_worldState {W : Type} [Nonempty W]
    (R : ℤ → W → W → Prop) (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w) :
    ¬ Finite (ofSlicedStepFinBranch R hf hb fwd bwd).WorldState :=
  not_finite_iff_infinite.mpr (inferInstanceAs (Infinite (ℤ × W)))

/--
**The history space of `ofSlicedStepFinBranch` is exactly the set of offset step paths** —
`ofSlicedStep_mem_HF_iff` with the constructor swapped, routed through
`FrameOver.mem_HF_iff_adjacent` and `ofSlicedStepFinBranch_step` alone; no finiteness instance
is consumed anywhere in the proof.
-/
theorem ofSlicedStepFinBranch_mem_HF_iff {W : Type} [Nonempty W] (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w) (f : ℤ → ℤ × W) :
    (∃ τ : WorldHistory (ofSlicedStepFinBranch R hf hb fwd bwd), τ.path = f) ↔
      ∃ (k : ℤ) (g : ℤ → W), IsSlicedStepPath R k g ∧ f = fun t => (t + k, g t) := by
  refine Iff.trans (FrameOver.mem_HF_iff_adjacent (ofSlicedStepFinBranch R hf hb fwd bwd) f) ?_
  constructor
  · intro hstep
    have hadj : ∀ n : ℤ, (f (n + 1)).1 = (f n).1 + 1 ∧ R (f n).1 (f n).2 (f (n + 1)).2 :=
      fun n => (ofSlicedStepFinBranch_step R hf hb fwd bwd (f n) (f (n + 1))).mp (hstep n)
    have hfst : ∀ t : ℤ, (f t).1 = t + (f 0).1 := by
      intro t
      induction t using Int.induction_on with
      | zero => simp
      | succ n ih => have := (hadj (n : ℤ)).1; omega
      | pred n ih =>
        have h := (hadj (-(n : ℤ) - 1)).1
        rw [show (-(n : ℤ) - 1) + 1 = -(n : ℤ) by omega] at h
        omega
    refine ⟨(f 0).1, fun t => (f t).2, ?_, ?_⟩
    · intro t
      have h := (hadj t).2
      rwa [hfst t] at h
    · funext t
      have h1 : (f t).1 = t + (f 0).1 := hfst t
      exact Prod.ext h1 rfl
  · rintro ⟨k, g, hg, rfl⟩
    intro n
    refine (ofSlicedStepFinBranch_step R hf hb fwd bwd _ _).mpr ⟨?_, ?_⟩
    · change (n + 1) + k = (n + k) + 1
      omega
    · exact hg n

/-! ## The deadline ladder -/

/-- The next-deadline counter drifts by at most one per step. -/
def Drift (n n' : ℕ) : Prop := n' = n ∨ n' = n + 1 ∨ n' + 1 = n

/-- The current-deadline counter: deterministic countdown while a region continues, handed the
next-deadline value when a region starts, and `0` while idle. A region ends exactly when the
countdown reaches `0` — no early discharge with leftover — and that clause is what keeps the
backward side finite (`Rlad_bwd`): a reset-from-any-level would give the idle state an infinite
preimage, which is `Rbad_bwd_infinite`'s shape. -/
def Count (px py : Bool) (c n c' : ℕ) : Prop :=
  if py then (if px then c' + 1 = c else c' = n) else (c' = 0 ∧ (px = true → c = 0))

/-- **The deadline ladder** over a finite object `(step, pend)`: states `(q, c, n)`, with the
object stepping along `step`, an idle state carrying `c = 0`, the next deadline drifting
(`Drift`) and the current deadline counting (`Count`). Time-invariant: the relation ignores
its `ℤ` argument. -/
def Rlad {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) :
    ℤ → (Q × ℕ × ℕ) → (Q × ℕ × ℕ) → Prop :=
  fun _ x y => step x.1 y.1 = true ∧ (pend x.1 = false → x.2.1 = 0) ∧
    Drift x.2.2 y.2.2 ∧ Count (pend x.1) (pend y.1) x.2.1 x.2.2 y.2.1

/-- The three values a counter can take after one step, as a finite set. -/
def tri (a b c : ℕ) : Set ℕ := {a, b, c}

theorem tri_finite (a b c : ℕ) : (tri a b c).Finite :=
  ((Set.finite_singleton c).insert b).insert a

/-- **Forward branching is finite**: from `(q, c, n)` the successor is in
`Q × {c - 1, n, 0} × {n - 1, n, n + 1}`. -/
theorem Rlad_fwd {Q : Type} [Finite Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    FwdFinBranch (Rlad step pend) := by
  intro t x
  refine Set.Finite.subset
    ((Set.finite_univ (α := Q)).prod ((tri_finite (x.2.1 - 1) x.2.2 0).prod
      (tri_finite (x.2.2 - 1) x.2.2 (x.2.2 + 1)))) ?_
  rintro ⟨q', c', n'⟩ ⟨-, -, hd, hc⟩
  refine ⟨Set.mem_univ _, ?_, ?_⟩
  · simp only [Count] at hc
    simp only [tri, Set.mem_insert_iff, Set.mem_singleton_iff]
    split_ifs at hc with h1 h2
    · left; omega
    · right; left; exact hc
    · right; right; exact hc.1
  · simp only [Drift] at hd
    simp only [tri, Set.mem_insert_iff, Set.mem_singleton_iff]
    omega

/-- **Backward branching is finite**: into `(q', c', n')` the predecessor is in
`Q × {c' + 1, 0, 0} × {n' - 1, n', n' + 1}`. This is the side `Rbad` fails and the side the
"no early discharge" clause of `Count` is for. -/
theorem Rlad_bwd {Q : Type} [Finite Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    BwdFinBranch (Rlad step pend) := by
  intro t y
  refine Set.Finite.subset
    ((Set.finite_univ (α := Q)).prod ((tri_finite (y.2.1 + 1) 0 0).prod
      (tri_finite (y.2.2 - 1) y.2.2 (y.2.2 + 1)))) ?_
  rintro ⟨q, c, n⟩ ⟨-, hidle, hd, hc⟩
  refine ⟨Set.mem_univ _, ?_, ?_⟩
  · simp only [Count] at hc
    simp only [tri, Set.mem_insert_iff, Set.mem_singleton_iff]
    split_ifs at hc with h1 h2
    · left; omega
    · right; left
      simp only [Bool.not_eq_true] at h2
      exact hidle h2
    · right; left
      by_cases hp : pend q = true
      · exact hc.2 hp
      · exact hidle (by simpa using hp)
  · simp only [Drift] at hd
    simp only [tri, Set.mem_insert_iff, Set.mem_singleton_iff]
    omega

/-- The ladder's carrier slice is infinite whenever `Q` is inhabited: the deadlines are
unbounded. This is the width `not_finite_width_fmp` forces, and the reason no cap is placed on
either counter. -/
theorem Rlad_slice_infinite {Q : Type} [Nonempty Q] : ¬ Finite (Q × ℕ × ℕ) := by
  intro h
  have : Finite ℕ := Finite.of_injective (fun n : ℕ => ((Classical.arbitrary Q), n, 0))
    (fun a b hab => by simpa using hab)
  exact not_finite ℕ

/-! ## The ladder frame -/

/-- **The frame-scheme constructor of requirement (W)'s obligation (i), regularity part**: a
finite object `(Q, step, pend)` with the seriality hypotheses `fwd`/`bwd` on its ladder yields
the regular `ℤ`-frame on the carrier `ℤ × (Q × ℕ × ℕ)` whose one-step relation is `Rlad`. The
only finiteness is `[Finite Q]` on the OBJECT; the slice is infinite (`Rlad_slice_infinite`).
Seriality is the object's own obligation, taken as hypotheses exactly as `ofSlicedStep` takes
them. -/
def ladderFrame {Q : Type} [Finite Q] [Nonempty Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, Rlad step pend t x y) (bwd : ∀ t x, ∃ y, Rlad step pend (t - 1) y x) :
    FrameOver intOrder :=
  ofSlicedStepFinBranch (Rlad step pend) (Rlad_fwd step pend) (Rlad_bwd step pend) fwd bwd

/-- **`ladderFrame` is regular.** `Saturation` comes from `saturation_of_finBranch` through
`Rlad_fwd`/`Rlad_bwd`, with no `[Finite W]` on the carrier, so `not_finite_width_fmp` is not
contradicted. This is the regularity part of obligation (i) and nothing else: no realization
theorem (nothing says a ladder state realizes a closure type), nothing about `HitPresented`,
nothing about `PlusValidZTime` in any form, and no complexity bound.

Paper: — (the nearest literature object is the quasimodel `⟨f, R⟩` of HWZ 2000's Definition 12,
whose run set `R` is chosen freely; no counterpart constructor exists there, because in this
semantics the run set is the path set of a frame and is not chosen — the ladder builds that
frame, and the HWZ corpus entry is of UNVERIFIED-summary provenance, so it orients the shape and
sources no claim) -/
instance ladderFrame_isRegular {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, Rlad step pend t x y) (bwd : ∀ t x, ∃ y, Rlad step pend (t - 1) y x) :
    (ladderFrame step pend fwd bwd).IsRegular :=
  ofSlicedStepFinBranch_isRegular _ _ _ _ _

/-- The one-step relation of `ladderFrame` advances the slice by one and steps along the
ladder. -/
theorem ladderFrame_step {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, Rlad step pend t x y) (bwd : ∀ t x, ∃ y, Rlad step pend (t - 1) y x)
    (x y : ℤ × (Q × ℕ × ℕ)) :
    (ladderFrame step pend fwd bwd).step x y ↔ y.1 = x.1 + 1 ∧ Rlad step pend x.1 x.2 y.2 :=
  ofSlicedStepFinBranch_step _ _ _ _ _ x y

end FormalSystem.Metalogic.Decidability.RaySummary
