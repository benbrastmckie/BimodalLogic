/-
Probe 746 (requirement (S) of the ray-product verdict), **the frame-constructor branching
verdict.** This file is the machine-checked record of what the carried "regular-frame constructor
for finitely many fibre shapes per time" prerequisite actually costs and actually buys. It is a
MIXED verdict: one generalization lands, and two candidate shapes for the construction it was
supposed to enable are refuted.

**Read this first: the frame constructor is not a dependency of requirement (S).** None of
what follows is. The carried cost estimate
(300-500 lines, inherited from task 742's research) attached the constructor to (S) on the
reasoning that liveness needs an infinite slice with committed states, and that
`FormalSystem.Semantics.FrameOver.ofSlicedStep` cannot supply one because `Saturation` for sliced
frames is proved only under `[Finite W]`. That reasoning is a COMPLETENESS burden, not a soundness
one: in (S) the presentation is GIVEN and its liveness sits in the `Cons` hypothesis, so
`ofSlicedStep` on the presentation's own finite `Q` suffices unchanged and no generalization is
needed anywhere on (S)'s critical path. The constructor is therefore a SUCCESSOR RECORD and is
deliberately NOT built here. What is preserved here is its hard part — the crux the dispatch named
and the two refutations found while testing it — so that the descoping rests on a green,
rot-guarded artifact rather than on a report paragraph.

**What is established POSITIVELY.** `FormalSystem.Semantics.ofSlicedStep_fib_finite`'s `[Finite W]`
IS replaceable by a two-sided finite-branching hypothesis on the one-step relation, with no
carrier hypothesis at all: `fib_finite_of_finBranch` below proves every `TaskFrame.Fib` of
`ofSlicedStepRel R` finite from `FwdFinBranch R` and `BwdFinBranch R` alone, and
`saturation_of_finBranch` feeds it to the library's `TaskFrame.saturation_of_fib_finite` (which
carries no carrier hypothesis of its own). The library lemma's proof bounds the fibre crudely, by
`{p.1 + d} ×ˢ Set.univ`, and never reads `R` at all — the entire finiteness requirement there comes
from `Finite W` through `Set.finite_univ` — so replacing that one bound by a reachability bound is
the whole of the repair, exactly as the dispatch's structural reading predicted. The four other
field discharges `ofSlicedStep` feeds to `ofReflectiveRegular` (`ofSlicedStepRel_reflect`,
`ofSlicedStep_compositional`, `ofSlicedStep_serial`, `ofSlicedStep_limit`) already carry no
`[Finite W]`, so `ofSlicedStep_fib_finite` is indeed the single funnel.

**TWO-SIDEDNESS IS NOT OPTIONAL, and this is the crux the dispatch flagged.** `TaskFrame.Fib` is
taken at NEGATIVE durations too, where `ofSlicedStepRel`'s sign-guarded conjunct reads the
iteration in the opposite direction (`d ≤ 0 → iterS R d.natAbs q.1 q.2 p.2`), so the fibre is the
step relation's **preimage** rather than its image. Finiteness is not stable under taking
converses, so one relation needs finite branching in BOTH senses: `fib_finite_of_finBranch`'s proof
splits on `le_or_gt 0 d` and consumes `iterS_fwd_finite` on one branch and `iterS_bwd_finite` on
the other. A hypothesis of forward finite branching alone does not suffice, and the next paragraph
is a refutation rather than a caution.

**What is REFUTED, part one: the named reset hazard is real.** The dispatch named a commitment
encoding "whose discharge transition resets the counter to 0 from any level" as a shape that would
give the reset state an infinite preimage. `Rbad` below is that encoding on the infinite slice `ℕ`
(count down by one, or discharge to `0` from any level). Its forward branching is finite
(`Rbad_fwd`), its backward branching fails at the reset target (`Rbad_bwd_infinite`), and the
failure is not an artefact of the hypothesis's phrasing: the `d = -1` fibre over `(0, 0)` is
genuinely infinite (`Rbad_fib_infinite`), so the bound fails outright on the object the library
lemma is about.

**What is REFUTED, part two: no reset PLACEMENT rescues a nondeterministic deadline.** This refutes
the dispatch's own guess at the repair shape and is the finding that would otherwise have been paid
for inside the construction. `Rok` below is the natural repair — commit to an arbitrary fresh
deadline only from level `0`, count down otherwise. Its backward branching is now finite
(`Rok_bwd`), but its FORWARD branching now fails at the commitment state (`Rok_fwd_infinite`): the
unbounded nondeterministic choice is infinite-branching on whichever side it fires, and moving the
reset merely swaps the failing side. The consequence for the successor record is concrete: a
commitment encoding for liveness must bound the deadline it commits to (or otherwise finitize the
choice) BEFORE two-sided finite branching is available, and no rearrangement of where the reset
fires substitutes for that.

**The generalization is non-vacuous on a genuinely infinite slice.** `shift_saturation` below is
`TaskFrame.Saturation (ofSlicedStepRel Rshift)` for the deterministic shift on the slice `ℤ`, with
no `[Finite W]` anywhere — and `shift_slice_infinite` records that the slice really is infinite.
That is a shape `ofSlicedStep_saturation` cannot state, so the generalization buys something real
and is not merely a hypothesis-weakening exercise.

**What is NOT established.** The constructor itself is NOT built: there is no `ofSlicedStepBranch`
here, no restatement of the nine `[Finite W]`-carrying declarations of
`FormalSystem/Semantics/SlicedFrame.lean`, and no `FrameOver`/`IsRegular` instance under the weaker
hypothesis — only the fibre-finiteness and `Saturation` core. An in-place generalization of that
module is PROHIBITED by task 746's plan, not merely unattempted: `ofSlicedStep` is referenced
across the tree including by probes this collection may not retire, so the parallel constructor
belongs to its own record. Nothing here constructs a model, realizes a presentation, or touches
`RaySummary`. No liveness encoding is exhibited that DOES have two-sided finite branching while
still deferring an eventuality — the refutations bound the design space, they do not close it, and
whether a finitized-deadline encoding suffices is left open to the successor. No complexity bound,
upper or lower. `Decidable (PlusValidZTime φ)` is NOT stated in any form, conditional or otherwise,
and no claim is made that L⁺ is decidable, qualified or not. Forward-only in the usual sense of
this collection: `FwdFinBranch`/`BwdFinBranch` are the two senses of branching of a single
time-indexed relation, not a backward semantic dual, and no symmetry with any backward fixture
result is implied.

**The decision held in place.** The carried 300-500 line frame-constructor prerequisite is
descoped from requirement (S) on the ground stated in the first paragraph, and the artifact that
makes the descoping checkable is this file: the generalization it was meant to deliver is here in
its load-bearing form, so the successor record inherits a proved core rather than a sketch, and
inherits two refutations that tell it which encodings not to try. If anything in this file stops
compiling, the descoping claim is the thing to revisit — do not delete the probe or weaken its
statements to make it pass.
-/
import FormalSystem.Semantics.SlicedFrame

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


/-! ## Axiom profile

Every declaration above on the standard profile `[propext, Classical.choice, Quot.sound]`; no
proof debt, no new axiom.
-/

#print axioms FwdFinBranch
#print axioms BwdFinBranch
#print axioms iterS_fwd_finite
#print axioms iterS_bwd_finite
#print axioms fib_finite_of_finBranch
#print axioms saturation_of_finBranch
#print axioms Rbad
#print axioms Rbad_fwd
#print axioms Rbad_bwd_infinite
#print axioms Rbad_fib_infinite
#print axioms Rok
#print axioms Rok_bwd
#print axioms Rok_fwd_infinite
#print axioms Rshift
#print axioms Rshift_fwd
#print axioms Rshift_bwd
#print axioms shift_saturation
#print axioms shift_slice_infinite

end Probe746
