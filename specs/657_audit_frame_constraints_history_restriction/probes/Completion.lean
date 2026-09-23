import FormalSystem.Semantics.Extension

/-!
# Probe: *Completion* — the exact frame-level condition `thm:extension` needs

`def:frame`'s *Saturation* is consumed at exactly one site, `lem:step`
(`FormalSystem.Semantics.PartialHistory.step`). This probe isolates the condition that site
actually needs, shows it is implied by *Saturation*, and shows it is **equivalent** to the
one-point extension property — so it is exactly as strong as `thm:extension` requires, no more.

The condition, stated over a bare relation and with no reference to histories:

> *Completion.* `⋂_{t ∈ X} Fib(w_t, z - t) ≠ ∅` for every nonempty `X ⊆ D`, every coherent
> family `{w_t}_{t ∈ X} ⊆ W` (`w_s ⇒_{t - s} w_t` for all `s, t ∈ X`), and every `z ∈ D`.

A coherent family indexed by a nonempty `X` **is** a partial history (`def:world-history`), so the
`PartialHistory`-shaped form `Completion` below and the relation-shaped form `CoherentCompletion`
are interchangeable; both are given, and `completion_iff_coherentCompletion` bridges them.

## What this probe settles

* `completion_of_onePointExtension` — the extension property gives *Completion*, with **no**
  frame constraint whatever.
* `onePointExtension_of_completion` — *Completion* plus *Seriality* plus *Limit* gives the
  one-point extension property, with **no** *Saturation* and **no** *Compositionality*.
* `completion_of_isRegular` — *Saturation* (via the existing `step`) gives *Completion*.
* `extension_of_completion` — *Completion* plus *Seriality* plus *Limit* gives `thm:extension`
  in full, through the existing Zorn scaffolding (`exists_maximal_extension`), which is itself
  constraint-free.

Consequence: within `def:frame`, *Saturation* may be replaced by *Completion* without losing
`thm:extension` or `cor:occurrence`, and *Compositionality* then plays no part in either.
Whether the replacement is a **strict** weakening is the converse `Completion → Saturation`,
which is left open here; see the report.
-/

namespace FormalSystem.Semantics

open TaskFrame

namespace PartialHistory

variable {F : TaskFrame}

/-! ## The two forms of *Completion* -/

/--
*Completion*, in `PartialHistory` form: every partial history admits a state consistent with all
of its own times at any prescribed further time `z`.

This is literally `(⋂₀ Constraints τ z).Nonempty` after `PartialHistory.fibers` has rewritten
constraint membership as the fiber conditions; the segment class of `def:frame`'s *Saturation*
disappears, because a constraint segment is the intersection of its two endpoint fiber
conditions (`seg_eq_inter_fib`).
-/
def Completion (F : TaskFrame) : Prop :=
  ∀ (τ : PartialHistory F) (z : F.Duration),
    ∃ u : F.WorldState, ∀ (t : F.Duration) (ht : τ.domain t),
      F.TaskRel (τ.states t ht) (z - t) u

/--
*Completion*, in bare-relation form: no notion of history is used, only a coherent family.
This is the shape in which the condition could be stated inside `def:frame` itself.
-/
def CoherentCompletion (F : TaskFrame) : Prop :=
  ∀ (X : F.Duration → Prop), (∃ t, X t) →
    ∀ (w : (t : F.Duration) → X t → F.WorldState),
      (∀ (s t : F.Duration) (hs : X s) (ht : X t), F.TaskRel (w s hs) (t - s) (w t ht)) →
      ∀ z : F.Duration, ∃ u : F.WorldState,
        ∀ (t : F.Duration) (ht : X t), F.TaskRel (w t ht) (z - t) u

/-- The two forms are the same condition: a coherent family on a nonempty index set *is* a
partial history. -/
theorem completion_iff_coherentCompletion : Completion F ↔ CoherentCompletion F := by
  constructor
  · intro h X hX w hw z
    exact h ⟨X, hX, w, hw⟩ z
  · intro h τ z
    exact h τ.domain τ.nonempty_domain τ.states τ.respects_task z

/-! ## The one-point extension property -/

/-- The conclusion of `lem:step`, as a property of the frame. -/
def OnePointExtension (F : TaskFrame) : Prop :=
  ∀ (τ : PartialHistory F) (z : F.Duration), ∃ σ : PartialHistory F, Extends σ τ ∧ σ.domain z

/-! ## `OnePointExtension → Completion`, with no constraint at all -/

/--
The extension property yields *Completion* **unconditionally** — no frame constraint is used.
The witness is the extending history's own state at `z`, and coherence is that history's
`respects_task` field.
-/
theorem completion_of_onePointExtension (h : OnePointExtension F) : Completion F := by
  intro τ z
  obtain ⟨σ, hext, hσz⟩ := h τ z
  refine ⟨σ.states z hσz, fun t ht => ?_⟩
  have := σ.respects_task t z (hext.subset t ht) hσz
  rwa [hext.agree t ht] at this

/-! ## `Completion → OnePointExtension`, from *Seriality* and *Limit* only -/

/--
The reflection law needs only *Limit*.

`FrameOver.reflection` is stated at `[F.IsRegular]`; its `d = 0` branch uses only
`eq_of_taskRel_zero`, which is *Limit*, and its `d ≠ 0` branch is definitional content of the
reflection convention. This restatement keeps *Saturation* out of the hypotheses, which is the
whole point of the probe.
-/
theorem reflection_of_limit (hlim : TaskFrame.Limit F.TaskRel)
    (w : F.WorldState) (d : F.Duration) (u : F.WorldState) :
    F.TaskRel w d u ↔ F.TaskRel u (-d) w := by
  rcases eq_or_ne d 0 with rfl | hd
  · rw [neg_zero]
    constructor
    · intro hR
      obtain rfl := F.toFibre.eq_of_taskRel_zero_of_limit hlim hR
      exact hR
    · intro hR
      obtain rfl := F.toFibre.eq_of_taskRel_zero_of_limit hlim hR
      exact hR
  · exact TaskFrame.reflect_reflection_of_ne hd

/--
*Completion* plus *Seriality* plus *Limit* gives the one-point extension property.

**No *Saturation*, and no *Compositionality*.** This is the `lem:admissible` argument run with
the *Completion* witness in place of the *Saturation* witness: the four pair-cases of
`AdjoinRespects` are `τ`'s own task-respect, the *Completion* fiber condition, that same
condition through the reflection law (`reflection_of_limit`), and `lem:nullity`
(`TaskFrame.nullity_of_serial_limit`) at the new time.
-/
theorem onePointExtension_of_completion (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (hC : Completion F) : OnePointExtension F := by
  intro τ z
  by_cases hz : τ.domain z
  · exact ⟨τ, ⟨fun _ ht => ht, fun _ _ => rfl⟩, hz⟩
  obtain ⟨u, hu⟩ := hC τ z
  have hadm : AdjoinRespects τ z u := by
    intro s t hs ht
    by_cases hsd : τ.domain s <;> by_cases htd : τ.domain t
    · rw [adjoinFun_of_domain τ u hsd, adjoinFun_of_domain τ u htd]
      exact τ.respects_task s t hsd htd
    · obtain rfl : z = t := (Or.resolve_left ht htd).symm
      rw [adjoinFun_of_domain τ u hsd, adjoinFun_of_not_domain τ u htd]
      exact hu s hsd
    · obtain rfl : z = s := (Or.resolve_left hs hsd).symm
      rw [adjoinFun_of_not_domain τ u hsd, adjoinFun_of_domain τ u htd]
      have hconv := (reflection_of_limit hlim (τ.states t htd) (z - t) u).mp (hu t htd)
      rwa [neg_sub] at hconv
    · obtain rfl : z = s := (Or.resolve_left hs hsd).symm
      obtain rfl : z = t := (Or.resolve_left ht htd).symm
      rw [adjoinFun_of_not_domain τ u hsd, sub_self]
      exact TaskFrame.nullity_of_serial_limit hser hlim u
  exact ⟨adjoin τ z u hadm, adjoin_extends τ z u hadm, adjoin_domain_self τ z u hadm⟩

/-- The equivalence, at any frame satisfying *Seriality* and *Limit*: *Completion* **is** the
one-point extension property. -/
theorem completion_iff_onePointExtension (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) : Completion F ↔ OnePointExtension F :=
  ⟨onePointExtension_of_completion hser hlim, completion_of_onePointExtension⟩

/-! ## *Saturation* implies *Completion* -/

/-- *Saturation* (through the existing `lem:step`) gives *Completion*. -/
theorem completion_of_isRegular [F.IsRegular] : Completion F :=
  completion_of_onePointExtension (fun τ z => step F τ z)

/-! ## `thm:extension` from *Completion* -/

/--
`thm:extension` in full, with *Saturation* replaced by *Completion*.

The Zorn scaffolding (`exists_maximal_extension`, `PartialHistoryOrder`) carries no frame
constraint, so the only inputs are *Completion*, *Seriality* and *Limit*.
-/
theorem extension_of_completion (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (hC : Completion F) (τ : PartialHistory F) :
    ∃ σ : WorldHistory F, Extends σ.val τ := by
  obtain ⟨μ, hle, hmax⟩ := exists_maximal_extension τ
  have htot : μ.IsTotal := by
    intro z
    obtain ⟨σ, hext, hσz⟩ := onePointExtension_of_completion hser hlim hC μ z
    exact (le_def.mp (hmax (le_def.mpr hext))).subset z hσz
  exact ⟨⟨μ, htot⟩, le_def.mp hle⟩

end PartialHistory

end FormalSystem.Semantics

/-! ## Axiom profiles -/

section AxiomCheck
open FormalSystem.Semantics.PartialHistory
#print axioms completion_of_onePointExtension
#print axioms onePointExtension_of_completion
#print axioms completion_of_isRegular
#print axioms extension_of_completion
#print axioms completion_iff_coherentCompletion
end AxiomCheck
