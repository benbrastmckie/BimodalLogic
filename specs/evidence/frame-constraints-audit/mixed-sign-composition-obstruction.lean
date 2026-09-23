import FormalSystem.Semantics.Extension
import FormalSystem.Semantics.Extension.Completion
import FormalSystem.Metalogic.Independence.DriftFrame

/-!
# Evidence probe: **mixed-sign composition must not be added to `def:frame`**

## The design decision this holds in place

`TaskFrame.TotalComp` — `def:frame`'s *Compositionality* with its `x, y ≥ 0` provisos dropped —
**must not become a constraint on a task frame**, and must not acquire a home under
`FormalSystem/`. `not_totalComp_F0` below exhibits a concrete failure of it at the drift frame
`F°` (`FormalSystem.Metalogic.Independence.fzeroFrame`), which `fzeroFrame_isRegular` certifies as
a *regular* task frame — all four of `def:frame`'s constraints hold there. `F°` is the frame
`app:drift` supplies for `cor:no-characterization`, so adding mixed-sign composition to
`def:frame` would delete a frame the paper's own independence argument needs.

That is why `TotalComp` is declared **here**, outside the build graph, and not in the library: a
condition the library must *not* satisfy should not be sitting in the library inviting a future
reader to add it. `grep -rn "TotalComp" FormalSystem/` returning nothing is the invariant this
file protects.

## The positive content it also carries, which is what locates the obstruction

`saturation_of_completion` — *Completion* (`FormalSystem.Semantics.PartialHistory.Completion`,
the exact condition `thm:extension` consumes) implies *Saturation* **as soon as** the frame
satisfies mixed-sign composition and *Limit*. So over that subclass *Saturation* is exactly as
strong as `thm:extension`, and is necessary as well as sufficient.

Together with `not_totalComp_F0` this locates the obstruction exactly: the converse
`Completion → Saturation` holds modulo mixed-sign composition, and mixed-sign composition is
independent of the four constraints and refuted by a frame the paper relies on. The
**unconditional** converse is therefore open, and this file records precisely where it stops.

`TotalComp` is strictly stronger than `TaskFrame.Triangle` (`Semantics/StateTopology.lean`),
which only asks for *some* shortcut duration of bounded size. Mixed-sign composition is also
inexpressible at the primitive level, since primitive durations are nonnegative; it is expressible
here only because the extended relation is two-sided.

Compiled outside the build graph by `scripts/check-evidence-probes.sh`. Sorry-free.
-/

namespace FormalSystem.Semantics

open TaskFrame

namespace PartialHistory

/-! ## Mixed-sign composition

Unlike a task-directory probe, an evidence probe is compiled by `lake env lean` **against the
built library**, so it can import. `Completion` and `FrameOver.reflection_of_limit` are therefore
consumed from `FormalSystem.Semantics.Extension.Completion` and
`FormalSystem.Semantics.TaskFrame` rather than copied.
-/

/--
**Mixed-sign composition**: `def:frame`'s *Compositionality* with its `x, y ≥ 0` provisos dropped,
in the composition (`←`) direction. Inexpressible at the primitive level, since primitive
durations are nonnegative; expressible here because the extended relation is two-sided.
-/
def TotalComp {W : Type} {D : Type} [AddCommGroup D] (R : W → D → W → Prop) : Prop :=
  ∀ w u v x y, R w x u → R u y v → R w (x + y) v

/-! ## `Completion → Saturation`, under mixed-sign composition -/

variable {F : TaskFrame}

/--
**The conditional converse.** Under mixed-sign composition and *Limit*, *Completion* — hence the
one-point extension property, hence `thm:extension` — implies *Saturation*.

The construction: a `⊇`-directed family `S` of nonempty fibers and segments *demands* a state `w`
at the time `t` whenever some member of `S` is contained in `Fib(w, -t)`. Directedness plus
mixed-sign composition make the demanded states a **coherent family** (hence a partial history),
and *Limit* makes the demand at each time **unique**. *Completion* at `z = 0` then produces a
state meeting every demand, and every member of `S` is an intersection of demands, so that state
lies in `⋂ S`.
-/
theorem saturation_of_completion (hlim : TaskFrame.Limit F.TaskRel)
    (htot : TotalComp F.TaskRel) (hC : Completion F) :
    TaskFrame.Saturation F.TaskRel := by
  intro S hdir hmem
  obtain ⟨hSne, hdirS⟩ := hdir
  have hrefl := F.toFibre.reflection_of_limit hlim
  -- Coherence of the demanded states, from directedness plus mixed-sign composition.
  have coh : ∀ (A B : Set F.WorldState), A ∈ S → B ∈ S →
      ∀ (w v : F.WorldState) (s t : F.Duration),
        A ⊆ TaskFrame.Fib F.TaskRel w (-s) → B ⊆ TaskFrame.Fib F.TaskRel v (-t) →
        F.TaskRel w (t - s) v := by
    intro A B hA hB w v s t hAs hBt
    obtain ⟨C, hC', hCsub⟩ := hdirS A hA B hB
    obtain ⟨u, hu⟩ := (hmem C hC').2
    have huA : u ∈ A := (hCsub hu).1
    have huB : u ∈ B := (hCsub hu).2
    have h1 : F.TaskRel w (-s) u := hAs huA
    have h2 : F.TaskRel v (-t) u := hBt huB
    have h2' : F.TaskRel u t v := by
      have := (hrefl v (-t) u).mp h2
      rwa [neg_neg] at this
    have := htot w u v (-s) t h1 h2'
    rwa [show (-s) + t = t - s by abel] at this
  -- Uniqueness of the demand at a time, from *Limit*.
  have wd : ∀ (A B : Set F.WorldState), A ∈ S → B ∈ S →
      ∀ (w v : F.WorldState) (t : F.Duration),
        A ⊆ TaskFrame.Fib F.TaskRel w (-t) → B ⊆ TaskFrame.Fib F.TaskRel v (-t) → w = v := by
    intro A B hA hB w v t hAt hBt
    have := coh A B hA hB w v t t hAt hBt
    rw [sub_self] at this
    exact F.toFibre.eq_of_taskRel_zero_of_limit hlim this
  -- Every member of `S` is contained in a fiber, at a computable time.
  have hsub : ∀ A ∈ S, ∃ (w : F.WorldState) (x : F.Duration),
      A ⊆ TaskFrame.Fib F.TaskRel w x := by
    intro A hA
    rcases (hmem A hA).1 with ⟨w, x, rfl⟩ | ⟨w, v, x, y, _, _, rfl⟩
    · exact ⟨w, x, subset_rfl⟩
    · exact ⟨w, x, fun _ hu => hu.1⟩
  -- The demanded-times domain.
  set X : F.Duration → Prop :=
    fun t => ∃ w : F.WorldState, ∃ A ∈ S, A ⊆ TaskFrame.Fib F.TaskRel w (-t) with hX
  have hXne : ∃ t, X t := by
    obtain ⟨A, hA⟩ := hSne
    obtain ⟨w, x, hAx⟩ := hsub A hA
    refine ⟨-x, w, A, hA, ?_⟩
    rwa [neg_neg]
  -- The demanded states form a partial history.
  let τ : PartialHistory F :=
    { domain := X
      nonempty_domain := hXne
      states := fun _ ht => Classical.choose ht
      respects_task := by
        intro s t hs ht
        obtain ⟨A, hA, hAs⟩ := Classical.choose_spec hs
        obtain ⟨B, hB, hBt⟩ := Classical.choose_spec ht
        exact coh A B hA hB _ _ s t hAs hBt }
  obtain ⟨u, hu⟩ := hC τ 0
  have hu' : ∀ (t : F.Duration) (ht : X t), u ∈ TaskFrame.Fib F.TaskRel (Classical.choose ht) (-t) := by
    intro t ht
    have := hu t ht
    rwa [zero_sub] at this
  -- Every member of `S` contains `u`.
  refine ⟨u, ?_⟩
  rw [Set.mem_sInter]
  intro A hA
  have hdemand : ∀ (w : F.WorldState) (x : F.Duration),
      A ⊆ TaskFrame.Fib F.TaskRel w x → u ∈ TaskFrame.Fib F.TaskRel w x := by
    intro w x hAx
    have hXt : X (-x) := ⟨w, A, hA, by rwa [neg_neg]⟩
    have heq : Classical.choose hXt = w := by
      obtain ⟨B, hB, hBt⟩ := Classical.choose_spec hXt
      exact wd B A hB hA _ _ (-x) hBt (by rwa [neg_neg])
    have := hu' (-x) hXt
    rw [heq, neg_neg] at this
    exact this
  rcases (hmem A hA).1 with ⟨w, x, hAeq⟩ | ⟨w, v, x, y, _, _, hAeq⟩
  · subst hAeq; exact hdemand w x subset_rfl
  · subst hAeq
    exact ⟨hdemand w x (fun _ hz => hz.1), hdemand v (-y) (fun _ hz => hz.2)⟩

/-! ## Mixed-sign composition is refuted by a frame the paper needs -/

end PartialHistory

end FormalSystem.Semantics

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Semantics
open FormalSystem.Semantics.PartialHistory

/--
**Mixed-sign composition FAILS at the drift frame `F°`.**

`0 ⇒₁ 2` (since `2 ∈ [1, 2]`) and `2 ⇒₋₁ 1` (since `1 - 2 = -1 ∈ [-2, -1]`), but `0 ⇒₀ 1` is
false (`1 ∉ {0}`). `F°` satisfies all four of `def:frame`'s constraints
(`fzeroFrame_isRegular`), so mixed-sign composition is **independent** of them — and `F°` is the
frame `app:drift` supplies for `cor:no-characterization`, so adding mixed-sign composition to
`def:frame` would remove a frame the paper's own independence argument needs.
-/
theorem not_totalComp_F0 : ¬ TotalComp F0.TaskRel := by
  intro h
  have h1 : F0.TaskRel (0 : ℝ) (1 : ℝ) (2 : ℝ) :=
    (f0_taskRel_iff _ _ _).mpr (by rw [fzeroRel_iff]; left; norm_num)
  have h2 : F0.TaskRel (2 : ℝ) (-1 : ℝ) (1 : ℝ) :=
    (f0_taskRel_iff _ _ _).mpr (by rw [fzeroRel_iff]; right; norm_num)
  have h3 := h 0 2 1 1 (-1) h1 h2
  rw [show (1 : ℝ) + (-1 : ℝ) = 0 by norm_num, f0_taskRel_iff, fzeroRel_iff] at h3
  norm_num at h3

end FormalSystem.Metalogic.Independence

section AxiomCheck
#print axioms FormalSystem.Semantics.PartialHistory.saturation_of_completion
#print axioms FormalSystem.Metalogic.Independence.not_totalComp_F0
end AxiomCheck
