import FormalSystem.Semantics.SlicedFrame

/-!
# Crux probe for the (S) frame-constructor prerequisite

Tests, cheaply and before any construction, whether `ofSlicedStep_fib_finite`'s `[Finite W]`
can be replaced by a two-sided finite-branching hypothesis on `R`.
-/

namespace Probe746

open FormalSystem.Semantics FormalSystem.Semantics.TaskFrame

/-- Forward finite branching of a time-indexed one-step relation. -/
def FwdFinBranch {W : Type} (R : ℤ → W → W → Prop) : Prop :=
  ∀ t w, {u | R t w u}.Finite

/-- Backward finite branching: the **preimage** side, which finiteness is not stable under. -/
def BwdFinBranch {W : Type} (R : ℤ → W → W → Prop) : Prop :=
  ∀ t u, {w | R t w u}.Finite

/-- The `n`-step forward image of one state is finite under forward finite branching. -/
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

/-- The `n`-step backward **preimage** of one state is finite under backward finite branching. -/
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
**The generalization.** `ofSlicedStepRel` has finite fibres under two-sided finite branching
alone — **no `[Finite W]`**, so the carrier's slice may be infinite.
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

/-- **Saturation from two-sided finite branching alone**, carrier-agnostic. -/
theorem saturation_of_finBranch {W : Type} (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R) :
    TaskFrame.Saturation (ofSlicedStepRel R) :=
  TaskFrame.saturation_of_fib_finite (fib_finite_of_finBranch R hf hb)

/-! ## The negative crux: reset-from-any-level breaks the backward side -/

/-- A countdown-with-unrestricted-reset encoding on the infinite slice `ℕ`:
`Rbad t n m` iff `n = m + 1` (count down) **or** `m = 0` (discharge-and-reset, from any level). -/
def Rbad : ℤ → ℕ → ℕ → Prop := fun _ n m => n = m + 1 ∨ m = 0

/-- Forward branching is finite: from `n` only `n - 1` and `0` are reachable. -/
theorem Rbad_fwd : FwdFinBranch Rbad := by
  intro t n
  refine Set.Finite.subset (Set.Finite.insert 0 (Set.finite_singleton (n - 1))) ?_
  intro m hm
  rcases hm with h | h
  · refine Set.mem_insert_iff.mpr (Or.inr ?_)
    simp only [Set.mem_singleton_iff]; omega
  · exact Set.mem_insert_iff.mpr (Or.inl h)

/-- Backward branching **fails**: the reset target `0` has every state as a predecessor. -/
theorem Rbad_bwd_infinite (t : ℤ) : ¬ {n : ℕ | Rbad t n 0}.Finite := by
  have h : {n : ℕ | Rbad t n 0} = Set.univ := by
    ext n; simp [Rbad]
  rw [h]
  exact Set.infinite_univ.not_finite

/-- And the crude bound fails outright: the `d = -1` fibre over `(0, 0)` is infinite. -/
theorem Rbad_fib_infinite : ¬ (TaskFrame.Fib (ofSlicedStepRel Rbad) ((0 : ℤ), (0 : ℕ)) (-1)).Finite := by
  intro hfin
  have hsub : (fun n : ℕ => ((-1 : ℤ), n)) ''
      {n : ℕ | Rbad (-1) n 0} ⊆ TaskFrame.Fib (ofSlicedStepRel Rbad) ((0 : ℤ), (0 : ℕ)) (-1) := by
    rintro q ⟨n, hn, rfl⟩
    refine ⟨by norm_num, fun h => absurd h (by norm_num), fun _ => ?_⟩
    simpa using hn
  have : ((fun n : ℕ => ((-1 : ℤ), n)) '' {n : ℕ | Rbad (-1) n 0}).Finite :=
    hfin.subset hsub
  exact Rbad_bwd_infinite (-1) (Set.Finite.of_finite_image this
    (Set.injOn_of_injective (fun a b hab => by simpa using hab)))

/-! ## The symmetric obstruction: moving the reset to level 0 only swaps the failing side -/

/-- The "repaired" encoding: countdown by one, and commit to an arbitrary fresh deadline **only
from level 0**. `Rok t n m` iff `n = m + 1` or `n = 0`. -/
def Rok : ℤ → ℕ → ℕ → Prop := fun _ n m => n = m + 1 ∨ n = 0

/-- Backward branching is now finite: into `m` only `m + 1` and `0` lead. -/
theorem Rok_bwd : BwdFinBranch Rok := by
  intro t m
  refine Set.Finite.subset (Set.Finite.insert 0 (Set.finite_singleton (m + 1))) ?_
  intro n hn
  rcases hn with h | h
  · exact Set.mem_insert_iff.mpr (Or.inr h)
  · exact Set.mem_insert_iff.mpr (Or.inl h)

/-- But **forward** branching now fails at the commitment state `0`: every fresh deadline is
reachable. The unbounded nondeterministic choice is infinite-branching on whichever side it
fires; moving the reset does not remove it. -/
theorem Rok_fwd_infinite (t : ℤ) : ¬ {m : ℕ | Rok t 0 m}.Finite := by
  have h : {m : ℕ | Rok t 0 m} = Set.univ := by
    ext m; simp [Rok]
  rw [h]
  exact Set.infinite_univ.not_finite

/-! ## The generalization is non-vacuous on an infinite slice -/

/-- A deterministic shift on the infinite slice `ℤ`: both branching sides are singletons. -/
def Rshift : ℤ → ℤ → ℤ → Prop := fun _ n m => m = n + 1

theorem Rshift_fwd : FwdFinBranch Rshift := by
  intro t n
  have : {m : ℤ | Rshift t n m} = {n + 1} := by ext m; simp [Rshift]
  rw [this]; exact Set.finite_singleton _

theorem Rshift_bwd : BwdFinBranch Rshift := by
  intro t m
  have : {n : ℤ | Rshift t n m} = {m - 1} := by ext n; simp [Rshift]; omega
  rw [this]; exact Set.finite_singleton _

/-- **The witness**: `Saturation` on a frame whose slice `ℤ` is infinite, with no `[Finite W]`
anywhere -- the shape `ofSlicedStep_saturation` cannot state. -/
theorem shift_saturation : TaskFrame.Saturation (ofSlicedStepRel Rshift) :=
  saturation_of_finBranch Rshift Rshift_fwd Rshift_bwd

/-- And its carrier slice is genuinely infinite. -/
theorem shift_slice_infinite : ¬ Finite ℤ := by
  simpa using Int.infinite.not_finite

end Probe746
