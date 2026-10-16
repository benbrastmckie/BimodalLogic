/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.EffectivePeriodicExtension
import FormalSystem.Metalogic.Decidability.BiLasso.Periodic

/-!
# A Finite Certificate that a Bounded History Is a Fragment of a Possible World

The cut footnote's last operative sentence, verbatim from `JPL/appendix_cut_material.tex`:

> This licenses a finite certificate that a given bounded history is a fragment of a possible
> world.

This module is that certificate at a bare `FrameOver intOrder`: a finite prefix plus a finite
cycle each way, placed at an absolute time, together with a `Bool`-valued check that decides
whether the certificate presents a possible world through a given bounded window, and the two
directions of that check's correctness — soundness here, completeness in the same namespace.

## What the certificate is built on

`Periodic.unrollOf` at `α := F.WorldState` — the carrier-generic three-segment decoding of
`BiLasso/Periodic.lean`, which is entirely choice-free. Deliberately **not** `BiLasso`'s own
`unrollOf`, which decodes into `Fin P.card`, is choice-carrying, and lives in a module held
byte-stable.

## Coherence is not a field

`BiLasso` carries its walk condition as a structure field, so a `BiLasso` is coherent by
construction. `FrameLasso` does not: the specification asks for a *decidable check* that the
certificate presents a possible world, so the type below is bare data and the check carries the
coherence obligation. That is the one deliberate departure from `BiLasso`'s shape, and it is
what makes `presentsWindow` a check rather than a lookup.

## What this licenses, and what it does not

`BiLasso/Agreement.lean` states three limits on what a window certificate can be cited for, and
they transfer here unchanged, by reference rather than restatement: box truth is a property of
the *model*, not of any single history; `Past` and `Future` quantify outside the window and so do
not transfer off it; and path periodicity is not truth periodicity. In one sentence: this
certificate licenses an existential claim about the window that was found — *this* bounded
history really is a fragment of *some* possible world — and nothing whatever about universal
obligations.

## Main Definitions

- `FrameLasso` — the certificate: three segment lists, an absolute origin, both cycles non-empty
- `FrameLasso.unroll` — the decoded bi-infinite path
- `Coherent` / `AgreesWindow` — the two halves of the check, as decidable propositions
- `presentsWindow` — the `Bool`-valued check

## Main Results

- `FrameLasso.unroll_sub_back_length` / `FrameLasso.unroll_add_fwd_length` — the two
  periodicities
- `presentsWindow_sound` — a passing check yields a possible world agreeing with the window
- `presentsWindow_complete` — every bounded adjacent window over an enumerated carrier is
  presented by some certificate whose segments are bounded by `enum.length`

## Tags

certificate · lasso · decidable-check · choice-free
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Semantics

/-! ## Reduction arithmetic

Three facts about `Int.emod` that the window argument needs. `BiLasso/Basic.lean` carries the
same three, stated at `Fin P.card` inside a module held byte-stable; they are restated here at
the generality they actually have, which is none at all — they mention no list and no frame.
-/

/-- The canonical representative of `i` in `[a, a + n)` has residue `i % n`. -/
theorem reduce_emod_int (n a i : ℤ) : (a + (i - a) % n) % n = i % n := by
  conv_rhs => rw [show i = a + (i - a) by omega]
  rw [Int.add_emod a ((i - a) % n) n, Int.emod_emod_of_dvd _ (dvd_refl n), ← Int.add_emod]

/-- Residue equality is preserved by the successor. -/
theorem emod_succ_congr_int {n x y : ℤ} (h : x % n = y % n) : (x + 1) % n = (y + 1) % n := by
  rw [Int.add_emod, h, ← Int.add_emod]

/--
**The reduction, packaged.** Every `i` has a representative in `[c, c + n)` agreeing with it
both modulo `n` and modulo `n` after subtracting `c`.

Stated as an existential rather than as a formula in `Int.emod`, and deliberately so: `omega`
discharges a goal mentioning `%` by routing through `Int.ediv`/`Int.emod` machinery that
measures `[propext, Classical.choice, Quot.sound]`, so a caller that keeps the representative's
*definition* in scope silently inherits that. Handing the caller an opaque witness with four
linear facts about it keeps every downstream `omega` call on pure linear arithmetic.
-/
theorem exists_reduce_int {n : ℤ} (hn : 0 < n) (c i : ℤ) :
    ∃ j : ℤ, c ≤ j ∧ j < c + n ∧ j % n = i % n ∧ (j - c) % n = (i - c) % n := by
  refine ⟨c + (i - c) % n, ?_, ?_, reduce_emod_int n c i, ?_⟩
  · have h0 : 0 ≤ (i - c) % n := Int.emod_nonneg _ (by omega)
    generalize (i - c) % n = r at h0
    omega
  · have h1 : (i - c) % n < n := Int.emod_lt_of_pos _ hn
    generalize (i - c) % n = r at h1
    omega
  · rw [show c + (i - c) % n - c = (i - c) % n by omega]
    exact Int.emod_emod_of_dvd _ (dvd_refl _)

/-! ## One coherent window is adjacency everywhere -/

/--
**The window reduction.** If the decoding steps at every time in
`[-|back| - 1, |mid| + |fwd|)`, it steps at *every* time.

That one contiguous window covers the two within-segment chains, the two seams and the two
wrap-arounds at once; every other time reduces into it modulo the relevant cycle length. The
argument is `BiLasso.unroll_isStepPath`'s, carried over to `Periodic.unrollOf` at an arbitrary
inhabited carrier.
-/
theorem unrollOf_step_of_window {F : FrameOver intOrder} [Inhabited F.WorldState]
    (back mid fwd : List F.WorldState) (hb : back ≠ []) (hf : fwd ≠ [])
    (hwin : ∀ t : ℤ, -(back.length : ℤ) - 1 ≤ t → t < (mid.length : ℤ) + (fwd.length : ℤ) →
      F.step (Periodic.unrollOf back mid fwd t) (Periodic.unrollOf back mid fwd (t + 1)))
    (t : ℤ) :
    F.step (Periodic.unrollOf back mid fwd t) (Periodic.unrollOf back mid fwd (t + 1)) := by
  have hbl := Periodic.length_pos_int (l := back) hb
  have hfl := Periodic.length_pos_int (l := fwd) hf
  have hm : (0 : ℤ) ≤ (mid.length : ℤ) := Int.natCast_nonneg _
  rcases (by omega : t < -1 ∨ -1 ≤ t) with hlt | hge
  · -- `t ≤ -2`: reduce modulo `|back|` into `[-|back| - 1, -1)`.
    obtain ⟨t', hlo, hhi, hres, -⟩ :=
      exists_reduce_int (n := (back.length : ℤ)) hbl (-(back.length : ℤ) - 1) t
    have hcoh := hwin t' (by omega) (by omega)
    have e1 : Periodic.unrollOf back mid fwd t' = Periodic.unrollOf back mid fwd t := by
      rw [Periodic.unrollOf_neg back mid fwd (by omega),
        Periodic.unrollOf_neg back mid fwd (by omega)]
      exact Periodic.cyc_congr hres
    have e2 : Periodic.unrollOf back mid fwd (t' + 1)
        = Periodic.unrollOf back mid fwd (t + 1) := by
      rw [Periodic.unrollOf_neg back mid fwd (by omega),
        Periodic.unrollOf_neg back mid fwd (by omega)]
      exact Periodic.cyc_congr (emod_succ_congr_int hres)
    rw [← e1, ← e2]
    exact hcoh
  rcases (by omega : t < (mid.length : ℤ) ∨ (mid.length : ℤ) ≤ t) with hmid | hmid
  · -- `-1 ≤ t < |mid|`: already in the window.
    exact hwin t (by omega) (by omega)
  · -- `t ≥ |mid|`: reduce modulo `|fwd|` into `[|mid|, |mid| + |fwd|)`.
    obtain ⟨t', hlo, hhi, -, hres⟩ :=
      exists_reduce_int (n := (fwd.length : ℤ)) hfl (mid.length : ℤ) t
    have hcoh := hwin t' (by omega) (by omega)
    have e1 : Periodic.unrollOf back mid fwd t' = Periodic.unrollOf back mid fwd t := by
      rw [Periodic.unrollOf_fwd back mid fwd (by omega),
        Periodic.unrollOf_fwd back mid fwd hmid]
      exact Periodic.cyc_congr hres
    have e2 : Periodic.unrollOf back mid fwd (t' + 1)
        = Periodic.unrollOf back mid fwd (t + 1) := by
      rw [Periodic.unrollOf_fwd back mid fwd (by omega),
        Periodic.unrollOf_fwd back mid fwd (by omega)]
      refine Periodic.cyc_congr ?_
      rw [show t' + 1 - (mid.length : ℤ) = (t' - (mid.length : ℤ)) + 1 by omega,
        show t + 1 - (mid.length : ℤ) = (t - (mid.length : ℤ)) + 1 by omega]
      exact emod_succ_congr_int hres
    rw [← e1, ← e2]
    exact hcoh

/-! ## The certificate -/

/--
**The finite certificate**: a finite prefix plus a finite cycle each way, placed at an absolute
time.

Coherence is deliberately **not** a field — see this module's docstring. The indexing convention
is `BiLasso`'s and `Periodic.unrollOf`'s, in local time measured from `origin`:

```
 …  back[0] … back[|back|-1]   mid[0] … mid[|mid|-1]   fwd[0] … fwd[|fwd|-1]   fwd[0] …
                          ↑t = -1  ↑t = 0                              ↑t = |mid|+|fwd|-1
```
-/
structure FrameLasso (F : FrameOver intOrder) [Inhabited F.WorldState] where
  /-- The leftward cycle, indexed left-to-right in time. -/
  back : List F.WorldState
  /-- The finite window. May be empty. -/
  mid : List F.WorldState
  /-- The rightward cycle, indexed left-to-right in time. -/
  fwd : List F.WorldState
  /-- The absolute time at which the window begins. -/
  origin : ℤ
  /-- The leftward cycle is non-empty — without it the decoding is not total on the left. -/
  back_ne : back ≠ []
  /-- The rightward cycle is non-empty. -/
  fwd_ne : fwd ≠ []

namespace FrameLasso

variable {F : FrameOver intOrder} [Inhabited F.WorldState]

/-- The decoded bi-infinite path, in absolute time. -/
def unroll (L : FrameLasso F) (t : ℤ) : F.WorldState :=
  Periodic.unrollOf L.back L.mid L.fwd (t - L.origin)

theorem unroll_def (L : FrameLasso F) (t : ℤ) :
    L.unroll t = Periodic.unrollOf L.back L.mid L.fwd (t - L.origin) := rfl

/-- The window index-to-local-time map: index `0` is local time `-|back| - 1`. -/
def windowTime (L : FrameLasso F) (i : ℕ) : ℤ := (i : ℤ) - (L.back.length : ℤ) - 1

/-- **Leftward periodicity.** Strictly left of the origin the decoding has period `|back|`. -/
theorem unroll_sub_back_length (L : FrameLasso F) {t : ℤ} (ht : t < L.origin) :
    L.unroll (t - (L.back.length : ℤ)) = L.unroll t := by
  rw [unroll_def, unroll_def, show t - (L.back.length : ℤ) - L.origin
    = (t - L.origin) - (L.back.length : ℤ) by omega]
  exact Periodic.unrollOf_sub_back_length L.back L.mid L.fwd L.back_ne (by omega)

/-- **Rightward periodicity.** At or past `origin + |mid|` the decoding has period `|fwd|`. -/
theorem unroll_add_fwd_length (L : FrameLasso F) {t : ℤ}
    (ht : L.origin + (L.mid.length : ℤ) ≤ t) :
    L.unroll (t + (L.fwd.length : ℤ)) = L.unroll t := by
  rw [unroll_def, unroll_def, show t + (L.fwd.length : ℤ) - L.origin
    = (t - L.origin) + (L.fwd.length : ℤ) by omega]
  exact Periodic.unrollOf_add_fwd_length L.back L.mid L.fwd L.fwd_ne (by omega)

end FrameLasso

/-! ## The decidable check -/

/--
**Coherence**: the certificate is a genuine walk in `(W, ⇒₁)`, asserted on one contiguous window
of local times indexed by a `Fin` — which is what makes it decidable by
`Fintype.decidableForallFintype` alone, with no search over ℤ.
-/
def Coherent {F : FrameOver intOrder} [Inhabited F.WorldState] (L : FrameLasso F) : Prop :=
  ∀ i : Fin (L.back.length + 1 + L.mid.length + L.fwd.length),
    F.step (Periodic.unrollOf L.back L.mid L.fwd (L.windowTime i))
      (Periodic.unrollOf L.back L.mid L.fwd (L.windowTime i + 1))

instance decidableCoherent {F : FrameOver intOrder} [Inhabited F.WorldState]
    [DecidableRel F.step] (L : FrameLasso F) : Decidable (Coherent L) :=
  inferInstanceAs (Decidable (∀ _i : Fin (L.back.length + 1 + L.mid.length + L.fwd.length), _))

/--
**Window agreement**: the decoding reproduces `win`, placed so that `win[0]` sits at absolute
time `a`.
-/
def AgreesWindow {F : FrameOver intOrder} [Inhabited F.WorldState] (L : FrameLasso F) (a : ℤ)
    (win : List F.WorldState) : Prop :=
  ∀ k : ℕ, k < win.length → L.unroll (a + (k : ℤ)) = win.getD k default

/--
Pointwise agreement between a decoding and a finite window is decidable, being a bounded
quantifier over `ℕ` into a type with decidable equality. `BiLasso/Agreement.lean` states the
same fact as an `example` at a `PlacedBiLasso`; here it is a named instance, which is what the
`Bool`-valued check below consumes.
-/
instance decidableAgreesWindow {F : FrameOver intOrder} [Inhabited F.WorldState]
    [DecidableEq F.WorldState] (L : FrameLasso F) (a : ℤ) (win : List F.WorldState) :
    Decidable (AgreesWindow L a win) :=
  inferInstanceAs (Decidable (∀ k : ℕ, k < win.length → _))

/--
**The decidable check**: this certificate is a genuine walk in `(W, ⇒₁)` and agrees with the
given bounded window where that window lives.

Coherence is decided through `DecidableRel F.step` over a `Fin`-indexed window; agreement is
decided through `DecidableEq F.WorldState` over a bounded `ℕ` range. Both halves run.
-/
def presentsWindow {F : FrameOver intOrder} [Inhabited F.WorldState] [DecidableEq F.WorldState]
    [DecidableRel F.step] (L : FrameLasso F) (a : ℤ) (win : List F.WorldState) : Bool :=
  decide (Coherent L) && decide (AgreesWindow L a win)

theorem coherent_of_presentsWindow {F : FrameOver intOrder} [Inhabited F.WorldState]
    [DecidableEq F.WorldState] [DecidableRel F.step] {L : FrameLasso F} {a : ℤ}
    {win : List F.WorldState} (h : presentsWindow L a win = true) : Coherent L := by
  rw [presentsWindow, Bool.and_eq_true] at h
  exact of_decide_eq_true h.1

theorem agreesWindow_of_presentsWindow {F : FrameOver intOrder} [Inhabited F.WorldState]
    [DecidableEq F.WorldState] [DecidableRel F.step] {L : FrameLasso F} {a : ℤ}
    {win : List F.WorldState} (h : presentsWindow L a win = true) : AgreesWindow L a win := by
  rw [presentsWindow, Bool.and_eq_true] at h
  exact of_decide_eq_true h.2

/-- `Coherent`, restated at a local time in the window rather than at a `Fin` index. -/
theorem step_of_coherent {F : FrameOver intOrder} [Inhabited F.WorldState] {L : FrameLasso F}
    (hc : Coherent L) {t : ℤ} (h1 : -(L.back.length : ℤ) - 1 ≤ t)
    (h2 : t < (L.mid.length : ℤ) + (L.fwd.length : ℤ)) :
    F.step (Periodic.unrollOf L.back L.mid L.fwd t)
      (Periodic.unrollOf L.back L.mid L.fwd (t + 1)) := by
  have hlt : (t + (L.back.length : ℤ) + 1).toNat
      < L.back.length + 1 + L.mid.length + L.fwd.length := by omega
  have hcoh := hc ⟨(t + (L.back.length : ℤ) + 1).toNat, hlt⟩
  have hw : L.windowTime ((t + (L.back.length : ℤ) + 1).toNat) = t := by
    simp only [FrameLasso.windowTime]
    omega
  rwa [hw] at hcoh

/-- A coherent certificate decodes to a bi-infinite step path. -/
theorem isStepPath_of_coherent {F : FrameOver intOrder} [Inhabited F.WorldState]
    {L : FrameLasso F} (hc : Coherent L) : IsStepPath F L.unroll := by
  intro t
  have hstep := unrollOf_step_of_window L.back L.mid L.fwd L.back_ne L.fwd_ne
    (fun s hs1 hs2 => step_of_coherent hc hs1 hs2) (t - L.origin)
  rw [FrameLasso.unroll_def, FrameLasso.unroll_def,
    show t + 1 - L.origin = (t - L.origin) + 1 by omega]
  exact hstep

/--
**Soundness.** A certificate passing the check decodes to a possible world that agrees with the
window and is ultimately periodic in both directions, with periods `|back|` leftward and `|fwd|`
rightward.

The `H_F` conclusion is routed through `FrameOver.worldHistoryOfStepPathInt`, not through
`worldHistoryOfStepPath`, so soundness is choice-free.
-/
theorem presentsWindow_sound {F : FrameOver intOrder} [F.IsRegular] [Inhabited F.WorldState]
    [DecidableEq F.WorldState] [DecidableRel F.step]
    (L : FrameLasso F) (a : ℤ) (win : List F.WorldState)
    (h : presentsWindow L a win = true) :
    ∃ σ : WorldHistory F,
      (∀ t : ℤ, σ.path t = Periodic.unrollOf L.back L.mid L.fwd (t - L.origin)) ∧
      (∀ k : ℕ, k < win.length → σ.path (a + (k : ℤ)) = win.getD k default) ∧
      (∀ t : ℤ, t < L.origin → σ.path (t - (L.back.length : ℤ)) = σ.path t) ∧
      (∀ t : ℤ, L.origin + (L.mid.length : ℤ) ≤ t →
        σ.path (t + (L.fwd.length : ℤ)) = σ.path t) := by
  have hc := coherent_of_presentsWindow h
  have hag := agreesWindow_of_presentsWindow h
  refine ⟨FrameOver.worldHistoryOfStepPathInt F L.unroll (isStepPath_of_coherent hc),
    fun _ => rfl, hag, ?_, ?_⟩
  · intro t ht
    exact L.unroll_sub_back_length ht
  · intro t ht
    exact L.unroll_add_fwd_length ht

end FormalSystem.Metalogic.Decidability
