/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Agreement

/-!
# The Deterministic Device as the Diagonal Instance

The branching device is an **addition**, not a replacement: the deterministic witness family is
the state-sharing family whose sharing relation is equality. This module exhibits that instance
and proves each branching condition equivalent to — not merely implied by — its deterministic
counterpart, so `Sharing/` is a genuine generalisation rather than a parallel development.

## `share u i j ↔ i = j`, by three singleton segments of `id`

`SharingWitnessFamily` encodes its sharing datum as three periodic segments of **representative
maps**, with the out-of-range default the identity (`Sharing/Basic.lean`). Setting all three
segments to `id` — `[id]`, `[]`, `[id]`, the two cycles non-empty as the structure requires —
makes the decoded map the identity at *every* time, in range or out, and `share` therefore
literal equality of indices. `rep_idem` is discharged because `id` is idempotent.

## Why each reduction is an `iff`, not an implication

`Sharing/Predicates.lean` already proves the two implications (C1') → (C1) and (C2') → (C2)
**unconditionally**, for an arbitrary sharing family, by instantiating the shared-successor and
thread quantifiers at the reflexive witness. Those are the directions that make the branching
conditions strengthenings. Here the converses hold too, and only here: under `share u i j ↔ i = j`

* the shared-successor quantifier of (C1')'s `untl` clause ranges over the single index `i`, so
  the branching clause *is* the deterministic clause;
* every thread is **constant** — its step field reads `θ.idx u = θ.idx (u + 1)` — so the thread
  quantifier of (C2') ranges over the constant threads alone, which is the per-lasso quantifier
  of (C2).

`thread_toSharing_idx` is the whole content of the second bullet and is proved by an integer
induction on the step field.

## (C0) is free here, and that is the explanation of a deliberate omission

`WitnessFamily/Predicates.lean` records that atoms are "deliberately unconstrained", which is
what makes the deterministic agreement theorem's `atom` case `Iff.rfl`. `atomCoherent_toSharing`
is why that was sound: at the diagonal instance (C0) says "if `i = j` then the labels at `i` and
`j` agree on atoms", which is true with nothing to check. The condition only acquires content
once two *distinct* indices may name one state.

## What the diagonal instance says about the stability modal

`FormalSystem.PlusLanguage.states_eq_of_deterministic` shows that on a frame whose task relation
is functional, any two histories through a common state agree at every time;
`FormalSystem.PlusLanguage.stab_iff_of_deterministic` turns that into `⊡φ ↔ φ` at every point.
`W.toSharing`'s task relation is functional — `share` is equality, so a state has exactly one
successor — and the collapse therefore holds at the diagonal instance. That is the semantic
statement of why the deterministic device is blind to `⊡` by construction, and why the branching
instance, whose relation is not functional, is what a stability clause would need. The clause
itself is out of scope here; see `Sharing/Agreement.lean`'s header.

## Main Definitions

- `WitnessFamily.toSharing` — the diagonal state-sharing family over a witness family

## Main Results

- `WitnessFamily.share_toSharing` — the sharing relation is equality
- `WitnessFamily.atomCoherent_toSharing` — (C0) holds unconditionally at the diagonal
- `WitnessFamily.localCoherentShare_toSharing` — (C1') ↔ (C1)
- `WitnessFamily.threadFulfilling_toSharing` — (C2') ↔ (C2)
- `WitnessFamily.certifies_toSharing` — the deterministic bundle yields the branching bundle
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

namespace WitnessFamily

variable {Γ Del : Context}

/--
**The diagonal state-sharing family.**

Three segments of representative maps, all `id`, so the decoded map is the identity everywhere
and `share u i j` is `i = j`. The parent's five exported fields are `W`'s own, unchanged, so the
JSON export contract is untouched by this construction.
-/
def toSharing (W : WitnessFamily Γ Del) : SharingWitnessFamily Γ Del where
  toWitnessFamily := W
  repBack := [id]
  repMid := []
  repFwd := [id]
  repBack_ne := by simp
  repFwd_ne := by simp
  rep_idem := by
    intro f hf i
    have hid : f = id := by
      simp only [List.append_assoc, List.nil_append] at hf
      rcases List.mem_append.mp hf with h | h <;> simpa using h
    subst hid
    rfl

@[simp]
theorem toSharing_toWitnessFamily (W : WitnessFamily Γ Del) :
    W.toSharing.toWitnessFamily = W := rfl

/-- **The decoded representative map is the identity at every time**, in range and out. -/
theorem rep_toSharing (W : WitnessFamily Γ Del) (u : ℤ) : W.toSharing.rep u = id := by
  have hlists : W.toSharing.repBack ++ W.toSharing.repMid ++ W.toSharing.repFwd
      = [id, id] := rfl
  rcases W.toSharing.rep_mem_or_id u with h | h
  · rw [hlists] at h
    rcases List.mem_cons.mp h with h' | h'
    · exact h'
    · rcases List.mem_cons.mp h' with h'' | h''
      · exact h''
      · cases h''
  · exact h

/-- **The sharing relation at the diagonal instance is equality.** -/
@[simp]
theorem share_toSharing (W : WitnessFamily Γ Del) (u : ℤ)
    (i j : Fin W.toSharing.lassos.length) : W.toSharing.share u i j ↔ i = j := by
  change W.toSharing.rep u i = W.toSharing.rep u j ↔ i = j
  rw [rep_toSharing]
  exact Iff.rfl

/--
**(C0) holds unconditionally at the diagonal instance.**

This is the explanation of `WitnessFamily/Predicates.lean`'s deliberate omission of an atom
clause: the condition has no content until two distinct indices may name one state.
-/
theorem atomCoherent_toSharing (W : WitnessFamily Γ Del) : W.toSharing.AtomCoherent := by
  intro u i j h a
  have hij : i = j := (share_toSharing W u i j).mp h
  subst hij
  exact Iff.rfl

/-- **(C1') at the diagonal instance is exactly (C1).** -/
theorem localCoherentShare_toSharing (W : WitnessFamily Γ Del) :
    W.toSharing.LocalCoherentShare ↔ W.LocalCoherentLab := by
  constructor
  · intro h
    exact SharingWitnessFamily.localCoherentLab_of_share h
  · intro h i t
    obtain ⟨hbot, himp, hbox, huntl, hsnce⟩ := h i t
    refine ⟨hbot, himp, hbox, ?_, ?_⟩
    · intro j hj g e hc
      have hij : i = j := (share_toSharing W (t + 1) i j).mp hj
      subst hij
      exact huntl g e hc
    · intro k hk g e hc
      have hik : i = k := (share_toSharing W t i k).mp hk
      subst hik
      exact hsnce g e hc

/--
**Every thread of the diagonal instance is constant.**

The step field reads `share (u + 1) (idx u) (idx (u + 1))`, which is `idx u = idx (u + 1)` here,
so the index never moves. Proved at `0` by `Int.induction_on` and then transported.
-/
theorem thread_toSharing_eq_zero (W : WitnessFamily Γ Del) (θ : W.toSharing.Thread) :
    ∀ u : ℤ, θ.idx u = θ.idx 0 := by
  have hstep : ∀ u : ℤ, θ.idx u = θ.idx (u + 1) := fun u =>
    (share_toSharing W (u + 1) (θ.idx u) (θ.idx (u + 1))).mp (θ.step u)
  intro u
  refine Int.induction_on u rfl ?_ ?_
  · intro n ih
    rw [← hstep (n : ℤ)]
    exact ih
  · intro n ih
    rw [hstep (-(n : ℤ) - 1), show -(n : ℤ) - 1 + 1 = -(n : ℤ) from by omega]
    exact ih

/-- A thread of the diagonal instance holds one index at every pair of times. -/
theorem thread_toSharing_idx (W : WitnessFamily Γ Del) (θ : W.toSharing.Thread) (u v : ℤ) :
    θ.idx u = θ.idx v := by
  rw [thread_toSharing_eq_zero W θ u, thread_toSharing_eq_zero W θ v]

/-- **(C2') at the diagonal instance is exactly (C2).** -/
theorem threadFulfilling_toSharing (W : WitnessFamily Γ Del) :
    W.toSharing.ThreadFulfilling ↔ W.FulfillingLab := by
  constructor
  · intro h
    exact SharingWitnessFamily.fulfillingLab_of_thread h
  · intro h
    refine ⟨fun i u g e hmem θ hθ => ?_, fun i u g e hmem θ hθ => ?_⟩
    · obtain ⟨s, hs, hes, hgs⟩ := h.1 i u g e hmem
      refine ⟨s, hs, ?_, ?_⟩
      · rw [(thread_toSharing_idx W θ s u).trans hθ]
        exact hes
      · intro r hr1 hr2
        rw [(thread_toSharing_idx W θ r u).trans hθ]
        exact hgs r hr1 hr2
    · obtain ⟨s, hs, hes, hgs⟩ := h.2 i u g e hmem
      refine ⟨s, hs, ?_, ?_⟩
      · rw [(thread_toSharing_idx W θ s u).trans hθ]
        exact hes
      · intro r hr1 hr2
        rw [(thread_toSharing_idx W θ r u).trans hθ]
        exact hgs r hr1 hr2

/--
**The deterministic bundle yields the branching bundle at the diagonal instance.**

(C0) is free, (C1') and (C2') are the two reductions above, and (C3) `BoxFaithful` and (C4)
`Target` are inherited literally — `W.toSharing.toWitnessFamily` is `W`. A fifth component,
`StabFaithful`, was planned and is out of scope; see this module's header for the semantic
statement that stands in its place.
-/
theorem certifies_toSharing (W : WitnessFamily Γ Del) {t : ℤ} (h : W.Certifies t) :
    W.toSharing.Certifies t :=
  ⟨atomCoherent_toSharing W,
    ⟨(localCoherentShare_toSharing W).mpr h.1, (threadFulfilling_toSharing W).mpr h.2.1⟩,
    h.2.2.1, h.2.2.2⟩

end WitnessFamily

end FormalSystem.Metalogic.Decidability
