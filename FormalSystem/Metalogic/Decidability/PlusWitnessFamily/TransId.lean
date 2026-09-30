/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Predicates

/-!
# The hop-free collapse of (C1') and (C2')

A **hop-free** L⁺ sharing family is one whose succession relation never leaves the index it is
read at: `S.trans u i j` forces `i = j`. The no-hopping succession bundle `transIdOf` is exactly
such a family's data, and this module records what hop-freedom buys.

## Why this matters for the compression

`PlusLocalCoherentShare` (C1') and `PlusThreadFulfilling` (C2') are the two *branching*
conditions of the six: their quantifiers range over succession-related indices and over threads
respectively, so a producer that supplies only per-lasso data cannot discharge them directly.
The compression produces exactly such per-lasso data — one bounded lasso per witnessing history,
each locally coherent and fulfilling **on its own** — and the two theorems below are what turn
that data into the branching conditions.

On a hop-free family the collapse is exact, not merely sufficient:

- (C1')'s `untl` clause quantifies over every `j` with `S.trans t i j`, and `snce` over every `k`
  with `S.trans (t - 1) k i`. Hop-freedom forces `j = i` and `k = i`, so each branching clause is
  precisely its one-position instance. `plusLocalCoherentShare_of_transId` is therefore the
  converse of the landed `plusLocalCoherentLab_of_share`, available only under `hid`.
- (C2') quantifies over every thread through the position. `Thread.step` puts consecutive indices
  in `trans`, so hop-freedom makes every thread's index function constant
  (`transId_forces_const_thread`), hence equal to the constant thread at its own value
  (`thread_eq_const_of_transId`). (C2') then reduces to `PlusFulfillingLab`, the converse of the
  landed `plusFulfillingLab_of_thread`.

## What hop-freedom does *not* cost

Hop-freedom constrains `trans`, not `share`. The representative structure stays as branching as
the producer makes it, so (C0) and (C5) keep their content: (C5) quantifies over the `share`-class
at one time and never over succession. This is the separation the succession redesign exists to
make expressible, and it is why the hop-free bundle was the intended producer's choice rather
than `transFullOf`. Under `transFullOf`, (C1')'s two clauses revert to the pre-redesign reading
that made the certificate class empty for exactly the stability targets such a producer must
certify.

## There is no compression, and hop-freedom is incomplete

The compression this module's second heading anticipates does not exist: no theorem in this tree
produces a certifying family from an arbitrary ℤ-time non-validity, and none can for the class as
it stands (`Limits/NoCertificate.lean`). Hop-freedom fails one step earlier and independently:
`Limits/HopFree.lean`'s `not_exists_hopFree_plusCertifies_hopTarget` shows no hop-free family
certifies `hopTarget`, because a hop-free family presents at most `lassos.length` distinct state
paths while that target forces unboundedly many.

**The four theorems below remain true, remain proved, and are kept.** They are statements about
what hop-freedom buys a producer that already has per-lasso data; that they cannot be fed by a
general producer does not touch them. Read them as a substrate fact, not as a completeness
strategy.

## Main Results

- `plusLocalCoherentShare_of_transId` — (C1') from `PlusLocalCoherentLab` on a hop-free family
- `transId_forces_const_thread` — every thread of a hop-free family is constant
- `thread_eq_const_of_transId` — hence equal to `Thread.const` at its own value
- `plusThreadFulfilling_of_transId` — (C2') from `PlusFulfillingLab` on a hop-free family
- `transIdOf_hid` — the `transIdOf` bundle is hop-free, which is the form a producer hands in
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

variable {Γ Del : PlusContext}

/--
**Hop-freedom**: succession never leaves the index it is read at.

Stated as a hypothesis rather than as a class, because the compression supplies it from its own
`transIdOf` data through `transIdOf_hid` and no other producer in this tree needs it.
-/
abbrev PlusHopFree (S : PlusSharingWitnessFamily Γ Del) : Prop :=
  ∀ (u : ℤ) (i j : Fin S.lassos.length), S.trans u i j → i = j

/--
**(C1') from its one-position form, on a hop-free family.**

Under `hid` the `untl` clause's successor `j` and the `snce` clause's predecessor `k` are both
forced equal to `i`, so each branching clause is exactly the one-position instance
`PlusLocalCoherentLab` already supplies. The three non-temporal clauses are shared verbatim.

This is the exact converse of `plusLocalCoherentLab_of_share`, which instantiates the same two
quantifiers at `trans_refl'` in the other direction. The converse is false without `hid`, and
that is the point of the branching device.

Paper: — (a certificate-side reduction between two conditions of this formalization's own
condition set, with no counterpart in the paper)
-/
theorem plusLocalCoherentShare_of_transId (S : PlusSharingWitnessFamily Γ Del)
    (hid : ∀ (u : ℤ) (i j : Fin S.lassos.length), S.trans u i j → i = j)
    (h : S.toPlusWitnessFamily.PlusLocalCoherentLab) :
    S.PlusLocalCoherentShare := by
  intro i t
  obtain ⟨hbot, himp, hbox, huntl, hsnce⟩ := h i t
  refine ⟨hbot, himp, hbox, ?_, ?_⟩
  · intro j hj g e hc
    have hij : i = j := hid t i j hj
    subst hij
    exact huntl g e hc
  · intro k hk g e hc
    have hki : k = i := hid (t - 1) k i hk
    subst hki
    exact hsnce g e hc

/--
**Every thread of a hop-free family is constant.**

`Thread.step θ u` puts `θ.idx u` and `θ.idx (u + 1)` in `S.trans u`, so `hid` makes consecutive
values equal; the two-sided extension to all of ℤ is an induction on the natural-number gap in
each direction.
-/
theorem transId_forces_const_thread (S : PlusSharingWitnessFamily Γ Del)
    (hid : ∀ (u : ℤ) (i j : Fin S.lassos.length), S.trans u i j → i = j)
    (θ : S.Thread) (u v : ℤ) : θ.idx u = θ.idx v := by
  have hstep : ∀ w : ℤ, θ.idx w = θ.idx (w + 1) := fun w => hid w _ _ (θ.step w)
  have hnat : ∀ (m : ℕ) (w : ℤ), θ.idx w = θ.idx (w + (m : ℤ)) := by
    intro m
    induction m with
    | zero => intro w; simp
    | succ k ih =>
      intro w
      have hshift : w + ((k + 1 : ℕ) : ℤ) = (w + (k : ℤ)) + 1 := by omega
      rw [hshift, ← hstep (w + (k : ℤ))]
      exact ih w
  rcases le_total u v with hle | hle
  · have hv : v = u + (((v - u).toNat : ℕ) : ℤ) := by omega
    rw [hv]
    exact hnat _ u
  · have hu : u = v + (((u - v).toNat : ℕ) : ℤ) := by omega
    rw [hu]
    exact (hnat _ v).symm

/--
**A hop-free family's threads are exactly the constant ones.**

The extensional reading of `transId_forces_const_thread`: a thread holding index `i` at any one
time is the constant thread at `i`, by `Thread.ext`.
-/
theorem thread_eq_const_of_transId (S : PlusSharingWitnessFamily Γ Del)
    (hid : ∀ (u : ℤ) (i j : Fin S.lassos.length), S.trans u i j → i = j)
    (θ : S.Thread) (u : ℤ) (i : Fin S.lassos.length) (hθ : θ.idx u = i) :
    θ = PlusSharingWitnessFamily.Thread.const S i := by
  apply SharingSkeleton.Thread.ext
  intro w
  rw [transId_forces_const_thread S hid θ w u, hθ]
  rfl

/--
**(C2') from its per-lasso form, on a hop-free family.**

Every thread through `(i, u)` is the constant thread at `i` by `thread_eq_const_of_transId`, so
the thread-indexed witness demanded by (C2') is the lasso-local witness `PlusFulfillingLab`
already supplies, read at the same times.

This is the exact converse of `plusFulfillingLab_of_thread`, which instantiates the thread
quantifier at `Thread.const` in the other direction.

Paper: — (a certificate-side reduction between two conditions of this formalization's own
condition set, with no counterpart in the paper)
-/
theorem plusThreadFulfilling_of_transId (S : PlusSharingWitnessFamily Γ Del)
    (hid : ∀ (u : ℤ) (i j : Fin S.lassos.length), S.trans u i j → i = j)
    (h : S.toPlusWitnessFamily.PlusFulfillingLab) :
    S.PlusThreadFulfilling := by
  refine ⟨fun i u g e hmem θ hθ => ?_, fun i u g e hmem θ hθ => ?_⟩
  · obtain ⟨s, hs, hes, hgs⟩ := h.1 i u g e hmem
    rw [thread_eq_const_of_transId S hid θ u i hθ]
    exact ⟨s, hs, hes, hgs⟩
  · obtain ⟨s, hs, hes, hgs⟩ := h.2 i u g e hmem
    rw [thread_eq_const_of_transId S hid θ u i hθ]
    exact ⟨s, hs, hes, hgs⟩

/--
**The no-hopping bundle is hop-free.**

The form a producer hands in: a family whose three succession segments are `transIdOf` applied
to its three representative segments satisfies the `hid` hypothesis of the two collapse theorems
above. `transMatOf_id` decodes the bundle to `transId` at *every* time, out-of-range default
included, and `transId_eq` reads that as index equality.

Only the `transRaw` half of `trans` is consumed here; the arrival-share half is discarded, which
is why hop-freedom says nothing about how branching the representative structure is.
-/
theorem transIdOf_hid (S : PlusSharingWitnessFamily Γ Del)
    (hb : S.transBack = transIdOf S.lassos.length S.repBack)
    (hm : S.transMid = transIdOf S.lassos.length S.repMid)
    (hf : S.transFwd = transIdOf S.lassos.length S.repFwd)
    (u : ℤ) (i j : Fin S.lassos.length) (h : S.trans u i j) : i = j := by
  have hraw : S.transRaw u i j = true := h.1
  have hdec : S.transRaw u = transId S.lassos.length := by
    change transMatOf S.lassos.length S.transBack S.transMid S.transFwd u = _
    rw [hb, hm, hf]
    exact transMatOf_id S.lassos.length S.repBack S.repMid S.repFwd u
  rw [hdec] at hraw
  exact transId_eq hraw

end FormalSystem.Metalogic.Decidability
