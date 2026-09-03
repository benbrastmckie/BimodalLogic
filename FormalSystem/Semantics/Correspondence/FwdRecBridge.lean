/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Correspondence.FwdRecPeriodicity
import FormalSystem.Semantics.IntNormalForm

/-!
# The `ℤ` bridge: a task frame over `ℤ` is a digraph, and its histories are walks

`Semantics/Correspondence/FwdRec.lean` proves the *atomic* half of the forward-recurrence
correspondence at an arbitrary duration group, and `FwdRecPeriodicity.lean` supplies the
`Walk`/`MinCyc` apparatus. This module joins them at `D = ℤ`, where the frame *is* a digraph:

* `FrameOver.step F w u := F.TaskRel w 1 u` is the one-step relation;
* every bi-infinite walk in `F.step` is a total history (`FrameOver.HFofStepPath`), because
  *Compositionality* plus *Converse* plus *Nullity* give `Rₙ = R₁ⁿ`
  (`FrameOver.respects_of_isStepPath`);
* every total history is a bi-infinite walk (`TaskFrame.HF.isStepPath`).

**The dictionary itself is not redefined here.** `Semantics/IntNormalForm.lean` already carries
it, in the `IsStepPath` spelling, and this module imports it: `Walk.IsWalk F.step` and
`IsStepPath F` are the *same* proposition, definitionally — see
`isWalk_iff_isStepPath` below, which is `Iff.rfl`. Five `Bridge.*` re-derivations
(`step`, `taskRel_nat`, `taskRel_diff`, `ofWalk`/`ofWalk_isTotal`, `hist_isWalk`) were deleted
in favour of the imported versions. Where a consumer needs both directions at once, cite
`FrameOver.mem_HF_iff_adjacent`, the pre-bundled round trip, rather than reassembling them.

Under that dictionary `TaskFrame.FwdRec` **is** `Walk.AllRec`, so `Walk.periodic` applies and
every total history of a forward-recurrent frame over `ℤ` is periodic. Feeding that into
`density_of_hist_periodic` gives the **full schema** half:

```
(∀ φ, F ⊨ GGφ → Gφ)  ↔  F.FwdRec        (at D = ℤ)
```

and hence the deliverable-level identity `Mod densitySchema = {F | F.FwdRec}`, restricted to the
`ℤ` fibre.

## The `ℤ` restriction is not removable, and this file is where it enters

Every result below is stated over `FrameOver intOrder`, never at an arbitrary `D`. The
restriction is bought by exactly one thing: `Walk.periodic`'s induction runs over walk *indices*,
which requires the times to be indexed by `ℤ` in the first place. Nothing in
`FwdRecPeriodicity.lean`'s truth-level layer needs it — `density_of_hist_periodic` holds at
arbitrary `D` — and nothing in `FwdRec.lean`'s atomic correspondence needs it either.

Whether forward recurrence gives the full schema over a general non-dense `D` — with "periodic"
weakened to shift-recurrence under a history-preserving order automorphism — is **open**. The
candidate counterexample is the sum of `ℤ` and `nℤ` over `ℤ ×ₗ ℤ`, the same carrier
`Metalogic/Independence/LexIntWitness.lean` uses to separate `Sat .Discrete` from
`Mod (AxiomSet .Discrete)`.

## Main results

* `isWalk_iff_isStepPath` — the frame/digraph dictionary, as an identity with `IntNormalForm`
* `allRec_of_fwdRec`, `hist_periodic`, `hist_deterministic` — recurrence forces periodicity
* `density_schema_iff_fwdRec` — full-schema exactness at `ℤ`
* `mod_densitySchema_int` — `Mod densitySchema` on the `ℤ` fibre is exactly the `FwdRec` frames
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

namespace Bridge

/--
**The two spellings of the `ℤ` dictionary are the same proposition.**

`Walk.IsWalk R σ` unfolds to `∀ n : ℤ, R (σ n) (σ (n + 1))` (`FwdRecPeriodicity.lean`) and
`IsStepPath F f` to `∀ n : ℤ, F.step (f n) (f (n + 1))` (`IntNormalForm.lean`).
Substituting `R := F.step` makes the two literally the same term, so this is `Iff.rfl` and not
merely an equivalence — which is what lets the `Walk`-side results below consume
`IntNormalForm`'s step-path apparatus with no transport.
-/
theorem isWalk_iff_isStepPath (F : FrameOver intOrder) (σ : ℤ → F.WorldState) :
    Walk.IsWalk F.step σ ↔ IsStepPath F σ := Iff.rfl

/-- `n` covers `n - 1` in `ℤ`. Stated standalone so that `omega` runs in a context whose atoms are
literally `Int`; inside `allRec_of_fwdRec` the times carry `↑intOrder`'s order instance, which is
`Int`'s only up to unfolding and which `omega` therefore does not read. -/
private theorem int_covers (n : ℤ) : n - 1 < n ∧ ∀ r : ℤ, n - 1 < r → r < n → False :=
  ⟨by omega, fun _ h1 h2 => by omega⟩

/-- **`FwdRec` over `ℤ` is exactly the digraph hypothesis `AllRec`.** -/
theorem allRec_of_fwdRec (F : FrameOver intOrder) (hF : F.toTaskFrame.FwdRec) :
    Walk.AllRec F.step := by
  intro σ hσ n
  exact hF (FrameOver.HFofStepPath F σ hσ) (n - 1) n (int_covers n).1 (int_covers n).2
    (fun w => ∃ m : ℤ, n < m ∧ σ m = w) (fun r hr => ⟨r, hr, rfl⟩)

/-- **Over `ℤ`, `FwdRec F` forces every total history to be periodic.** -/
theorem hist_periodic (F : FrameOver intOrder) (hF : F.toTaskFrame.FwdRec)
    (τ : WorldHistory F.toTaskFrame) (hτ : τ.IsTotal) :
    ∃ π : ℤ, 0 < π ∧ ∀ n : ℤ, τ.states (n + π) (hτ (n + π)) = τ.states n (hτ n) :=
  Walk.periodic (allRec_of_fwdRec F hF) (TaskFrame.HF.isStepPath ⟨τ, hτ⟩)

/--
**The structural shape of a `FwdRec` frame over `ℤ`**: the one-step relation is *deterministic*
along histories — two total histories that agree at one time agree one step later.
-/
theorem hist_deterministic (F : FrameOver intOrder) (hF : F.toTaskFrame.FwdRec)
    (τ ρ : WorldHistory F.toTaskFrame) (hτ : τ.IsTotal) (hρ : ρ.IsTotal) (t : ℤ)
    (h : τ.states t (hτ t) = ρ.states t (hρ t)) :
    τ.states (t + 1) (hτ (t + 1)) = ρ.states (t + 1) (hρ (t + 1)) :=
  Walk.succ_unique' (allRec_of_fwdRec F hF) (TaskFrame.HF.isStepPath ⟨τ, hτ⟩)
    (TaskFrame.HF.isStepPath ⟨ρ, hρ⟩) h

/--
**Full-schema exactness over `ℤ`.**

`F` validates *every* instance of `GGφ → Gφ` — `φ` ranging over all formulas, not just atoms —
exactly when `F.FwdRec`. Contrast
`Semantics.validOn_atomic_density_iff_fwdRec`, which is the *atomic* statement and holds at an
arbitrary duration group; the two are stated separately and deliberately not merged.
-/
theorem density_schema_iff_fwdRec (F : FrameOver intOrder) :
    (∀ φ : Formula,
        F.toTaskFrame.ValidOn (φ.allFuture.allFuture.imp φ.allFuture)) ↔ F.toTaskFrame.FwdRec := by
  constructor
  · intro h
    exact (validOn_atomic_density_iff_fwdRec F.toTaskFrame).mp fun p => h (Formula.atom p)
  · intro hF φ
    rw [TaskFrame.validOn_iff_total]
    intro M τ hτ t
    exact density_of_hist_periodic F.toTaskFrame
      (fun τ' hτ' => hist_periodic F hF τ' hτ') φ M τ hτ t

/--
**Deliverable (3) at the `Mod` level**: on the `ℤ` fibre, the model class of the density schema
is exactly the forward-recurrent frames.

Stated as an equality of subsets of the fibre rather than of `Set TaskFrame`, because that is
what is true: `Mod densitySchema` as a set of *bundled* frames also contains frames over other
duration groups, and the characterization is `ℤ`-only. See this module's header for why the
restriction is not removable and what remains open without it.
-/
theorem mod_densitySchema_int :
    {F : FrameOver intOrder | F.toTaskFrame ∈ Mod densitySchema}
      = {F : FrameOver intOrder | F.toTaskFrame.FwdRec} := by
  ext F
  simp only [Set.mem_setOf_eq]
  rw [← density_schema_iff_fwdRec F]
  constructor
  · intro h φ
    exact h ⟨φ, rfl⟩
  · rintro h φ ⟨ψ, rfl⟩
    exact h ψ

end Bridge

end FormalSystem.Semantics
