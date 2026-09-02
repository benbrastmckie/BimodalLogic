/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Correspondence.FwdRecPeriodicity

/-!
# The `ℤ` bridge: a task frame over `ℤ` is a digraph, and its histories are walks

`Semantics/Correspondence/FwdRec.lean` proves the *atomic* half of the forward-recurrence
correspondence at an arbitrary duration group, and `FwdRecPeriodicity.lean` supplies the
`Walk`/`MinCyc` apparatus. This module joins them at `D = ℤ`, where the frame *is* a digraph:

* `step F w u := F.TaskRel w 1 u` is the one-step relation;
* every bi-infinite walk in `step F` is a total history (`ofWalk`), because
  *Compositionality* plus *Converse* plus *Nullity* give `Rₙ = R₁ⁿ` (`taskRel_diff`);
* every total history is a bi-infinite walk (`hist_isWalk`).

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

* `step`, `ofWalk`, `hist_isWalk` — the frame/digraph dictionary
* `allRec_of_fwdRec`, `hist_periodic`, `hist_deterministic` — recurrence forces periodicity
* `density_schema_iff_fwdRec` — full-schema exactness at `ℤ`
* `mod_densitySchema_int` — `Mod densitySchema` on the `ℤ` fibre is exactly the `FwdRec` frames
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

namespace Bridge

/-- The one-step digraph of a task frame over `ℤ`. -/
def step (F : FrameOver intOrder) : F.WorldState → F.WorldState → Prop :=
  fun w u => F.TaskRel w 1 u

/-- Walking `k` natural steps realizes the duration `k`: `forward_comp` iterated. -/
theorem taskRel_nat (F : FrameOver intOrder) {σ : ℤ → F.WorldState}
    (h : Walk.IsWalk (step F) σ) (s : ℤ) :
    ∀ k : ℕ, F.TaskRel (σ s) (k : ℤ) (σ (s + (k : ℤ))) := by
  intro k
  induction k with
  | zero => simpa using F.nullity (σ s)
  | succ k ih =>
      have h1 : F.TaskRel (σ (s + (k : ℤ))) 1 (σ (s + (k : ℤ) + 1)) := h (s + (k : ℤ))
      have h2 := F.forward_comp (σ s) (σ (s + (k : ℤ))) (σ (s + (k : ℤ) + 1)) (k : ℤ) 1
        (by positivity) (by norm_num) ih h1
      have e1 : ((k : ℤ) + 1) = ((k + 1 : ℕ) : ℤ) := by push_cast; ring
      have e2 : s + (k : ℤ) + 1 = s + ((k + 1 : ℕ) : ℤ) := by push_cast; ring
      rw [e1, e2] at h2
      exact h2

/-- **Every bi-infinite walk respects the task relation at every duration**: *Compositionality*,
*Converse* and *Nullity* together give `Rₙ = R₁ⁿ`. -/
theorem taskRel_diff (F : FrameOver intOrder) {σ : ℤ → F.WorldState}
    (h : Walk.IsWalk (step F) σ) (s t : ℤ) : F.TaskRel (σ s) (t - s) (σ t) := by
  rcases le_total s t with hst | hst
  · have hk := taskRel_nat F h s (t - s).toNat
    rw [show (((t - s).toNat : ℤ)) = t - s by omega, show s + (t - s) = t by ring] at hk
    exact hk
  · have hk := taskRel_nat F h t (s - t).toNat
    rw [show (((s - t).toNat : ℤ)) = s - t by omega, show t + (s - t) = s by ring] at hk
    have hc := (F.converse (σ t) (s - t) (σ s)).mp hk
    rw [show -(s - t) = t - s by ring] at hc
    exact hc

/-- The total history a bi-infinite walk determines. -/
def ofWalk (F : FrameOver intOrder) {σ : ℤ → F.WorldState} (h : Walk.IsWalk (step F) σ) :
    WorldHistory F.toTaskFrame where
  domain := fun _ => True
  nonempty_domain := ⟨0, trivial⟩
  states := fun t _ => σ t
  respects_task := fun s t _ _ => taskRel_diff F h s t
  convex := fun _ _ _ _ _ _ _ => trivial

theorem ofWalk_isTotal (F : FrameOver intOrder) {σ : ℤ → F.WorldState}
    (h : Walk.IsWalk (step F) σ) : (ofWalk F h).IsTotal := fun _ => trivial

/-- **Every total history is a bi-infinite walk.** -/
theorem hist_isWalk (F : FrameOver intOrder) (τ : WorldHistory F.toTaskFrame)
    (hτ : τ.IsTotal) : Walk.IsWalk (step F) (fun n => τ.states n (hτ n)) := by
  intro n
  have h := τ.respects_task n (n + 1) (hτ n) (hτ (n + 1))
  rw [show n + 1 - n = (1 : ℤ) by ring] at h
  exact h

/-- `n` covers `n - 1` in `ℤ`. Stated standalone so that `omega` runs in a context whose atoms are
literally `Int`; inside `allRec_of_fwdRec` the times carry `↑intOrder`'s order instance, which is
`Int`'s only up to unfolding and which `omega` therefore does not read. -/
private theorem int_covers (n : ℤ) : n - 1 < n ∧ ∀ r : ℤ, n - 1 < r → r < n → False :=
  ⟨by omega, fun _ h1 h2 => by omega⟩

/-- **`FwdRec` over `ℤ` is exactly the digraph hypothesis `AllRec`.** -/
theorem allRec_of_fwdRec (F : FrameOver intOrder) (hF : F.toTaskFrame.FwdRec) :
    Walk.AllRec (step F) := by
  intro σ hσ n
  exact hF ⟨ofWalk F hσ, ofWalk_isTotal F hσ⟩ (n - 1) n (int_covers n).1 (int_covers n).2
    (fun w => ∃ m : ℤ, n < m ∧ σ m = w) (fun r hr => ⟨r, hr, rfl⟩)

/-- **Over `ℤ`, `FwdRec F` forces every total history to be periodic.** -/
theorem hist_periodic (F : FrameOver intOrder) (hF : F.toTaskFrame.FwdRec)
    (τ : WorldHistory F.toTaskFrame) (hτ : τ.IsTotal) :
    ∃ π : ℤ, 0 < π ∧ ∀ n : ℤ, τ.states (n + π) (hτ (n + π)) = τ.states n (hτ n) :=
  Walk.periodic (allRec_of_fwdRec F hF) (hist_isWalk F τ hτ)

/--
**The structural shape of a `FwdRec` frame over `ℤ`**: the one-step relation is *deterministic*
along histories — two total histories that agree at one time agree one step later.
-/
theorem hist_deterministic (F : FrameOver intOrder) (hF : F.toTaskFrame.FwdRec)
    (τ ρ : WorldHistory F.toTaskFrame) (hτ : τ.IsTotal) (hρ : ρ.IsTotal) (t : ℤ)
    (h : τ.states t (hτ t) = ρ.states t (hρ t)) :
    τ.states (t + 1) (hτ (t + 1)) = ρ.states (t + 1) (hρ (t + 1)) :=
  Walk.succ_unique' (allRec_of_fwdRec F hF) (hist_isWalk F τ hτ) (hist_isWalk F ρ hρ) h

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
    exact h _ ⟨φ, rfl⟩
  · rintro h φ ⟨ψ, rfl⟩
    exact h ψ

end Bridge

end FormalSystem.Semantics
