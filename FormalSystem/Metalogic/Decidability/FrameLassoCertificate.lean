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
- `FrameCoherent` / `AgreesWindow` — the two halves of the check, as decidable propositions
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

/-- `Periodic.cyc` at an index whose reduction by an explicit multiple of the length lands in
range: the cyclic lookup is then a plain `getD`. One lemma covers every index the window
argument meets, which keeps `omega` away from `Int.emod` at every call site. -/
theorem cyc_eq_getD_shift {α : Type*} [Inhabited α] (l : List α) (i k : ℤ)
    (h0 : 0 ≤ i + k * (l.length : ℤ)) (h1 : i + k * (l.length : ℤ) < (l.length : ℤ)) :
    Periodic.cyc l i = l.getD (i + k * (l.length : ℤ)).toNat default := by
  have h : i % (l.length : ℤ) = i + k * (l.length : ℤ) := by
    rw [← Periodic.emod_add_mul i k (l.length : ℤ)]
    exact Int.emod_eq_of_lt h0 h1
  rw [Periodic.cyc, h]

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
def FrameCoherent {F : FrameOver intOrder} [Inhabited F.WorldState] (L : FrameLasso F) : Prop :=
  ∀ i : Fin (L.back.length + 1 + L.mid.length + L.fwd.length),
    F.step (Periodic.unrollOf L.back L.mid L.fwd (L.windowTime i))
      (Periodic.unrollOf L.back L.mid L.fwd (L.windowTime i + 1))

instance decidableCoherent {F : FrameOver intOrder} [Inhabited F.WorldState]
    [DecidableRel F.step] (L : FrameLasso F) : Decidable (FrameCoherent L) :=
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
  decide (FrameCoherent L) && decide (AgreesWindow L a win)

theorem coherent_of_presentsWindow {F : FrameOver intOrder} [Inhabited F.WorldState]
    [DecidableEq F.WorldState] [DecidableRel F.step] {L : FrameLasso F} {a : ℤ}
    {win : List F.WorldState} (h : presentsWindow L a win = true) : FrameCoherent L := by
  rw [presentsWindow, Bool.and_eq_true] at h
  exact of_decide_eq_true h.1

theorem agreesWindow_of_presentsWindow {F : FrameOver intOrder} [Inhabited F.WorldState]
    [DecidableEq F.WorldState] [DecidableRel F.step] {L : FrameLasso F} {a : ℤ}
    {win : List F.WorldState} (h : presentsWindow L a win = true) : AgreesWindow L a win := by
  rw [presentsWindow, Bool.and_eq_true] at h
  exact of_decide_eq_true h.2

/-- `FrameCoherent`, restated at a local time in the window rather than at a `Fin` index. -/
theorem step_of_coherent {F : FrameOver intOrder} [Inhabited F.WorldState] {L : FrameLasso F}
    (hc : FrameCoherent L) {t : ℤ} (h1 : -(L.back.length : ℤ) - 1 ≤ t)
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
    {L : FrameLasso F} (hc : FrameCoherent L) : IsStepPath F L.unroll := by
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

Paper: — (the specification is cut material; see
`docs/reference/paper-definitions-of-record.md`, "The finite-case effectiveness footnote")
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

/-! ## Completeness

`presentsWindow_sound` and `presentsWindow_complete` are the two directions of one claim:
together they say the decidable check is *exactly* the predicate "this certificate presents a
possible world through this bounded history". Soundness says a passing check is not a false
positive; completeness says the check is not vacuously unsatisfiable — every bounded adjacent
window over an enumerated carrier really is presented by some certificate, with both cycles
bounded by `enum.length`.

`IntPresentation.extend_periodic_extends` (`BiLasso/Agreement.lean`) is the presented-frame
counterpart. The difference is the hypothesis, not the content: that one is stated at an
`IntPresentation` — a carrier already packaged as `Fin card` with a `Bool`-valued adjacency
matrix — and is choice-carrying through the decoding module it reuses. This one is stated at a
bare `FrameOver intOrder` with its carrier handed over as a list, and is not.
-/

/--
`getD` at an in-range index is `getElem`.

Mathlib's `List.getD_eq_getElem` says exactly this and measures
`[propext, Classical.choice, Quot.sound]`, as does every other lemma in
`Mathlib/Data/List/GetD.lean`. The route below — `List.getD_eq_getElem?_getD` followed by
`List.getElem?_eq_getElem` — says the same thing at `[propext]`, and is what keeps the
certificate layer scrubbed.
-/
theorem getD_eq_getElem_of_lt {α : Type*} [Inhabited α] (l : List α) (n : ℕ) (h : n < l.length) :
    l.getD n default = l[n] := by
  rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem h]
  rfl

/-- `getD` into a `List.range`-map, at an index inside the range. -/
theorem getD_rangeMap {α : Type*} [Inhabited α] (n : ℕ) (f : ℕ → α) (m : ℕ) (hm : m < n) :
    ((List.range n).map f).getD m default = f m := by
  have hlen : m < ((List.range n).map f).length := by
    rw [List.length_map, List.length_range]; exact hm
  rw [getD_eq_getElem_of_lt _ _ hlen, List.getElem_map, List.getElem_range]

/-- `getD` into a three-fold concatenation, resolved by which block the index falls in. -/
theorem getD_append_three {α : Type*} [Inhabited α] (l₁ l₂ l₃ : List α) (m : ℕ) :
    (l₁ ++ l₂ ++ l₃).getD m default =
      if m < l₁.length then l₁.getD m default
      else if m < l₁.length + l₂.length then l₂.getD (m - l₁.length) default
      else l₃.getD (m - l₁.length - l₂.length) default := by
  have hlen : (l₁ ++ l₂).length = l₁.length + l₂.length := List.length_append
  simp only [List.getD_eq_getElem?_getD]
  rcases Nat.lt_or_ge m l₁.length with h₁ | h₁
  · rw [if_pos h₁, List.getElem?_append_left (by omega), List.getElem?_append_left h₁]
  rcases Nat.lt_or_ge m (l₁.length + l₂.length) with h₂ | h₂
  · rw [if_neg (by omega), if_pos h₂, List.getElem?_append_left (by omega),
      List.getElem?_append_right h₁]
  · rw [if_neg (by omega), if_neg (by omega), List.getElem?_append_right (by omega), hlen,
      Nat.sub_sub]

section Runs

variable (F : FrameOver intOrder) [F.IsRegular] [Inhabited F.WorldState] [DecidableRel F.step]
  (enum : List F.WorldState) (henum : ∀ w, w ∈ enum)

/-- `fwdRun` read with `getD` rather than `getElem`. -/
theorem fwdRun_getD (w : F.WorldState) (n k : ℕ) (hk : k < n) :
    (fwdRun F enum henum w n).getD k default = (succOfEnum F enum henum)^[k + 1] w :=
  getD_rangeMap n _ k hk

/-- `bwdRun` read with `getD` rather than `getElem`. The list is in increasing time order, so
index `k` is `n - k` steps back. -/
theorem bwdRun_getD (w : F.WorldState) (n k : ℕ) (hk : k < n) :
    (bwdRun F enum henum w n).getD k default = (predOfEnum F enum henum)^[n - k] w := by
  have hlen : k < (bwdRun F enum henum w n).length := by rw [bwdRun_length]; exact hk
  rw [getD_eq_getElem_of_lt _ _ hlen]
  exact bwdRun_getElem F enum henum w n k hk

end Runs

/--
**Coherence from the segments.** `FrameCoherent` asserted segment by segment: adjacency inside each
of the three lists, the two seams, and the two cycle wrap-arounds.

This is the interface the completeness proof discharges. Stating it separately is what keeps the
modular reduction (`unrollOf_step_of_window` and the `cyc` index arithmetic) out of the
construction, and the construction out of the arithmetic.
-/
theorem coherent_of_segments {F : FrameOver intOrder} [Inhabited F.WorldState]
    (L : FrameLasso F) (hmidne : L.mid ≠ [])
    (hback : ∀ m : ℕ, m + 1 < L.back.length →
      F.step (L.back.getD m default) (L.back.getD (m + 1) default))
    (hbackwrap : F.step (L.back.getD (L.back.length - 1) default) (L.back.getD 0 default))
    (hseamL : F.step (L.back.getD (L.back.length - 1) default) (L.mid.getD 0 default))
    (hmidadj : ∀ m : ℕ, m + 1 < L.mid.length →
      F.step (L.mid.getD m default) (L.mid.getD (m + 1) default))
    (hseamR : F.step (L.mid.getD (L.mid.length - 1) default) (L.fwd.getD 0 default))
    (hfwd : ∀ m : ℕ, m + 1 < L.fwd.length →
      F.step (L.fwd.getD m default) (L.fwd.getD (m + 1) default))
    (hfwdwrap : F.step (L.fwd.getD (L.fwd.length - 1) default) (L.fwd.getD 0 default)) :
    FrameCoherent L := by
  have hbl : 0 < L.back.length := List.length_pos_of_ne_nil L.back_ne
  have hfl : 0 < L.fwd.length := List.length_pos_of_ne_nil L.fwd_ne
  have hml : 0 < L.mid.length := List.length_pos_of_ne_nil hmidne
  intro i
  have hi := i.isLt
  have hcycB : ∀ (x k : ℤ), 0 ≤ x + k * (L.back.length : ℤ) →
      x + k * (L.back.length : ℤ) < (L.back.length : ℤ) →
      Periodic.cyc L.back x = L.back.getD (x + k * (L.back.length : ℤ)).toNat default :=
    fun x k h0 h1 => cyc_eq_getD_shift L.back x k h0 h1
  have hcycF : ∀ (x k : ℤ), 0 ≤ x + k * (L.fwd.length : ℤ) →
      x + k * (L.fwd.length : ℤ) < (L.fwd.length : ℤ) →
      Periodic.cyc L.fwd x = L.fwd.getD (x + k * (L.fwd.length : ℤ)).toNat default :=
    fun x k h0 h1 => cyc_eq_getD_shift L.fwd x k h0 h1
  -- `t` is the local time this window index names.
  have hwt : L.windowTime (i : ℕ) = (i : ℤ) - (L.back.length : ℤ) - 1 := rfl
  rw [hwt]
  set t : ℤ := (i : ℤ) - (L.back.length : ℤ) - 1 with htdef
  have ht1 : -(L.back.length : ℤ) - 1 ≤ t := by omega
  have ht2 : t < (L.mid.length : ℤ) + (L.fwd.length : ℤ) := by omega
  rcases (by omega : t = -(L.back.length : ℤ) - 1 ∨ -(L.back.length : ℤ) ≤ t) with hA | hA
  · -- the leftward wrap-around
    rw [Periodic.unrollOf_neg _ _ _ (by omega), Periodic.unrollOf_neg _ _ _ (by omega),
      hcycB _ 2 (by omega) (by omega), hcycB _ 1 (by omega) (by omega),
      show (t + 2 * (L.back.length : ℤ)).toNat = L.back.length - 1 by omega,
      show (t + 1 + 1 * (L.back.length : ℤ)).toNat = 0 by omega]
    exact hbackwrap
  rcases (by omega : t ≤ -2 ∨ -1 ≤ t) with hB | hB
  · -- inside the leftward cycle
    rw [Periodic.unrollOf_neg _ _ _ (by omega), Periodic.unrollOf_neg _ _ _ (by omega),
      hcycB _ 1 (by omega) (by omega), hcycB _ 1 (by omega) (by omega),
      show (t + 1 + 1 * (L.back.length : ℤ)).toNat
        = (t + 1 * (L.back.length : ℤ)).toNat + 1 by omega]
    exact hback _ (by omega)
  rcases (by omega : t = -1 ∨ 0 ≤ t) with hC | hC
  · -- the leftward seam
    rw [Periodic.unrollOf_neg _ _ _ (by omega),
      Periodic.unrollOf_mid _ _ _ (by omega) (by omega),
      hcycB _ 1 (by omega) (by omega),
      show (t + 1 * (L.back.length : ℤ)).toNat = L.back.length - 1 by omega,
      show (t + 1).toNat = 0 by omega]
    exact hseamL
  rcases (by omega : t + 1 < (L.mid.length : ℤ) ∨ (L.mid.length : ℤ) ≤ t + 1) with hD | hD
  · -- inside the window
    rw [Periodic.unrollOf_mid _ _ _ (by omega) (by omega),
      Periodic.unrollOf_mid _ _ _ (by omega) (by omega),
      show (t + 1).toNat = t.toNat + 1 by omega]
    exact hmidadj _ (by omega)
  rcases (by omega : t = (L.mid.length : ℤ) - 1 ∨ (L.mid.length : ℤ) ≤ t) with hE | hE
  · -- the rightward seam
    rw [Periodic.unrollOf_mid _ _ _ (by omega) (by omega),
      Periodic.unrollOf_fwd _ _ _ (by omega),
      hcycF _ 0 (by omega) (by omega),
      show t.toNat = L.mid.length - 1 by omega,
      show (t + 1 - (L.mid.length : ℤ) + 0 * (L.fwd.length : ℤ)).toNat = 0 by omega]
    exact hseamR
  rcases (by omega : t + 1 < (L.mid.length : ℤ) + (L.fwd.length : ℤ) ∨
      t = (L.mid.length : ℤ) + (L.fwd.length : ℤ) - 1) with hF | hF
  · -- inside the rightward cycle
    rw [Periodic.unrollOf_fwd _ _ _ (by omega), Periodic.unrollOf_fwd _ _ _ (by omega),
      hcycF _ 0 (by omega) (by omega), hcycF _ 0 (by omega) (by omega),
      show (t + 1 - (L.mid.length : ℤ) + 0 * (L.fwd.length : ℤ)).toNat
        = (t - (L.mid.length : ℤ) + 0 * (L.fwd.length : ℤ)).toNat + 1 by omega]
    exact hfwd _ (by omega)
  · -- the rightward wrap-around
    rw [Periodic.unrollOf_fwd _ _ _ (by omega), Periodic.unrollOf_fwd _ _ _ (by omega),
      hcycF _ 0 (by omega) (by omega), hcycF _ (-1) (by omega) (by omega),
      show (t - (L.mid.length : ℤ) + 0 * (L.fwd.length : ℤ)).toNat
        = L.fwd.length - 1 by omega,
      show (t + 1 - (L.mid.length : ℤ) + (-1) * (L.fwd.length : ℤ)).toNat = 0 by omega]
    exact hfwdwrap

/--
**Completeness against the extension theorem.** Every bounded adjacent window over an enumerated
carrier is presented by some certificate whose two cycles are bounded by the enumeration's
length.

The certificate is assembled from `EffectivePeriodicExtension.lean`'s own orbit segments rather
than from a second run of the orbit argument: `bwdRun` and `fwdRun` supply the two tails and the
two cycles, pigeonhole (`exists_dup_of_enum`) supplies the two revisits that make the cycles
close, and `coherent_of_segments` turns segment-wise adjacency into `FrameCoherent`.

The tails cannot live in `back` and `fwd`, because those two lists are read *cyclically* by
`Periodic.unrollOf` and so cannot carry a non-repeating prefix. They are folded into `mid`
instead, with `origin` shifted left by the backward tail's length — which is why `mid` is
`bwdRun … ++ win ++ fwdRun …` and the certificate's origin is `a - i₀` rather than `a`.

Paper: — (the specification is cut material; see
`docs/reference/paper-definitions-of-record.md`, "The finite-case effectiveness footnote")
-/
theorem presentsWindow_complete {F : FrameOver intOrder} [F.IsRegular] [Inhabited F.WorldState]
    [DecidableEq F.WorldState] [DecidableRel F.step]
    (enum : List F.WorldState) (henum : ∀ w, w ∈ enum)
    (a : ℤ) (win : List F.WorldState) (hne : win ≠ [])
    (hadj : ∀ k : ℕ, k + 1 < win.length →
      F.step (win.getD k default) (win.getD (k + 1) default)) :
    ∃ L : FrameLasso F, presentsWindow L a win = true ∧
      L.back.length ≤ enum.length ∧ L.fwd.length ≤ enum.length := by
  have hwl : 0 < win.length := List.length_pos_of_ne_nil hne
  obtain ⟨sc, hscd⟩ : ∃ f : F.WorldState → F.WorldState, f = succOfEnum F enum henum := ⟨_, rfl⟩
  obtain ⟨pr, hprd⟩ : ∃ f : F.WorldState → F.WorldState, f = predOfEnum F enum henum := ⟨_, rfl⟩
  obtain ⟨w₀, hw₀⟩ : ∃ w : F.WorldState, w = win.getD 0 default := ⟨_, rfl⟩
  obtain ⟨w₁, hw₁⟩ : ∃ w : F.WorldState, w = win.getD (win.length - 1) default := ⟨_, rfl⟩
  have hsc : ∀ w, F.step w (sc w) := by rw [hscd]; exact succOfEnum_step F enum henum
  have hpr : ∀ w, F.step (pr w) w := by rw [hprd]; exact predOfEnum_step F enum henum
  have hscstep : ∀ (w : F.WorldState) (n : ℕ), F.step (sc^[n] w) (sc^[n + 1] w) := by
    intro w n
    rw [Function.iterate_succ_apply']
    exact hsc _
  have hprstep : ∀ (w : F.WorldState) (n : ℕ), F.step (pr^[n + 1] w) (pr^[n] w) := by
    intro w n
    rw [Function.iterate_succ_apply']
    exact hpr _
  obtain ⟨i₁, j₁, hij₁, hj₁, heq₁⟩ :=
    exists_dup_of_enum enum henum (enum.length + 1) (by omega) (fun k => sc^[k] w₁)
  obtain ⟨i₀, j₀, hij₀, hj₀, heq₀⟩ :=
    exists_dup_of_enum enum henum (enum.length + 1) (by omega) (fun k => pr^[k] w₀)
  -- The three segments, as opaque lists with their defining equations.
  obtain ⟨bck, hbck⟩ : ∃ l : List F.WorldState,
      l = bwdRun F enum henum (pr^[i₀] w₀) (j₀ - i₀) := ⟨_, rfl⟩
  obtain ⟨fwl, hfwl⟩ : ∃ l : List F.WorldState,
      l = fwdRun F enum henum (sc^[i₁] w₁) (j₁ - i₁) := ⟨_, rfl⟩
  obtain ⟨mdl, hmdl⟩ : ∃ l : List F.WorldState,
      l = bwdRun F enum henum w₀ i₀ ++ win ++ fwdRun F enum henum w₁ i₁ := ⟨_, rfl⟩
  have hbcklen : bck.length = j₀ - i₀ := by rw [hbck, bwdRun_length]
  have hfwllen : fwl.length = j₁ - i₁ := by rw [hfwl, fwdRun_length]
  have hmdllen : mdl.length = i₀ + win.length + i₁ := by
    rw [hmdl, List.length_append, List.length_append, bwdRun_length, fwdRun_length]
  have hbne : bck ≠ [] := by
    intro h
    have h0 : bck.length = 0 := by rw [h]; rfl
    omega
  have hfne : fwl ≠ [] := by
    intro h
    have h0 : fwl.length = 0 := by rw [h]; rfl
    omega
  have hmne : mdl ≠ [] := by
    intro h
    have h0 : mdl.length = 0 := by rw [h]; rfl
    omega
  -- Reading the three segments.
  have hbckget : ∀ m : ℕ, m < j₀ - i₀ → bck.getD m default = pr^[j₀ - m] w₀ := by
    intro m hm
    rw [hbck, bwdRun_getD F enum henum _ _ m hm, ← hprd,
      ← Function.iterate_add_apply pr (j₀ - i₀ - m) i₀ w₀]
    congr 1
    omega
  have hfwlget : ∀ m : ℕ, m < j₁ - i₁ → fwl.getD m default = sc^[i₁ + m + 1] w₁ := by
    intro m hm
    rw [hfwl, fwdRun_getD F enum henum _ _ m hm, ← hscd,
      ← Function.iterate_add_apply sc (m + 1) i₁ w₁]
    congr 1
    omega
  have hmdlget : ∀ m : ℕ, m < i₀ + win.length + i₁ →
      mdl.getD m default =
        if m < i₀ then pr^[i₀ - m] w₀
        else if m < i₀ + win.length then win.getD (m - i₀) default
        else sc^[m - i₀ - win.length + 1] w₁ := by
    intro m hm
    rw [hmdl, getD_append_three]
    simp only [bwdRun_length]
    split_ifs with h1 h2
    · rw [bwdRun_getD F enum henum w₀ i₀ m h1, ← hprd]
    · rfl
    · rw [fwdRun_getD F enum henum w₁ i₁ (m - i₀ - win.length) (by omega), ← hscd]
  -- The two ends of `mdl`, which the two seams reach for.
  have hmdlfirst : mdl.getD 0 default = pr^[i₀] w₀ := by
    rw [hmdlget 0 (by omega)]
    rcases Nat.eq_zero_or_pos i₀ with h | h
    · subst h
      rw [if_neg (by omega), if_pos (by omega)]
      simp only [Nat.sub_self, Function.iterate_zero, id_eq, hw₀]
    · rw [if_pos h]
      congr 1
  have hmdllast : mdl.getD (i₀ + win.length + i₁ - 1) default = sc^[i₁] w₁ := by
    rw [hmdlget _ (by omega)]
    rcases Nat.eq_zero_or_pos i₁ with h | h
    · subst h
      rw [if_neg (by omega), if_pos (by omega),
        show i₀ + win.length + 0 - 1 - i₀ = win.length - 1 by omega, ← hw₁]
      simp
    · rw [if_neg (by omega), if_neg (by omega)]
      congr 1
      omega
  refine ⟨⟨bck, mdl, fwl, a - (i₀ : ℤ), hbne, hfne⟩, ?_, ?_, ?_⟩
  · -- the check passes
    have hC : FrameCoherent (⟨bck, mdl, fwl, a - (i₀ : ℤ), hbne, hfne⟩ : FrameLasso F) := by
      refine coherent_of_segments _ hmne ?_ ?_ ?_ ?_ ?_ ?_ ?_
      · -- inside the leftward cycle
        intro m hm
        change F.step (bck.getD m default) (bck.getD (m + 1) default)
        rw [hbcklen] at hm
        rw [hbckget m (by omega), hbckget (m + 1) (by omega),
          show j₀ - m = (j₀ - (m + 1)) + 1 by omega]
        exact hprstep w₀ _
      · -- the leftward wrap-around
        change F.step (bck.getD (bck.length - 1) default) (bck.getD 0 default)
        rw [hbcklen, hbckget (j₀ - i₀ - 1) (by omega), hbckget 0 (by omega),
          show j₀ - (j₀ - i₀ - 1) = i₀ + 1 by omega, show j₀ - 0 = j₀ by omega, ← heq₀]
        exact hprstep w₀ _
      · -- the leftward seam
        change F.step (bck.getD (bck.length - 1) default) (mdl.getD 0 default)
        rw [hbcklen, hbckget (j₀ - i₀ - 1) (by omega), hmdlfirst,
          show j₀ - (j₀ - i₀ - 1) = i₀ + 1 by omega]
        exact hprstep w₀ _
      · -- inside the window and the two tails
        intro m hm
        change F.step (mdl.getD m default) (mdl.getD (m + 1) default)
        rw [hmdllen] at hm
        rw [hmdlget m (by omega), hmdlget (m + 1) (by omega)]
        rcases Nat.lt_or_ge (m + 1) i₀ with h1 | h1
        · rw [if_pos (by omega), if_pos (by omega),
            show i₀ - m = (i₀ - (m + 1)) + 1 by omega]
          exact hprstep w₀ _
        rcases Nat.lt_or_ge m i₀ with h2 | h2
        · rw [if_pos h2, if_neg (by omega), if_pos (by omega),
            show i₀ - m = 1 by omega, show m + 1 - i₀ = 0 by omega, ← hw₀]
          simpa using hprstep w₀ 0
        rcases Nat.lt_or_ge (m + 1) (i₀ + win.length) with h3 | h3
        · rw [if_neg (by omega), if_pos (by omega), if_neg (by omega), if_pos (by omega),
            show m + 1 - i₀ = (m - i₀) + 1 by omega]
          exact hadj (m - i₀) (by omega)
        rcases Nat.lt_or_ge m (i₀ + win.length) with h4 | h4
        · rw [if_neg (by omega), if_pos (by omega), if_neg (by omega), if_neg (by omega),
            show m - i₀ = win.length - 1 by omega,
            show m + 1 - i₀ - win.length + 1 = 1 by omega, ← hw₁]
          simpa using hscstep w₁ 0
        · rw [if_neg (by omega), if_neg (by omega), if_neg (by omega), if_neg (by omega),
            show m + 1 - i₀ - win.length + 1 = (m - i₀ - win.length + 1) + 1 by omega]
          exact hscstep w₁ _
      · -- the rightward seam
        change F.step (mdl.getD (mdl.length - 1) default) (fwl.getD 0 default)
        rw [hmdllen, hmdllast, hfwlget 0 (by omega), show i₁ + 0 + 1 = i₁ + 1 by omega]
        exact hscstep w₁ _
      · -- inside the rightward cycle
        intro m hm
        change F.step (fwl.getD m default) (fwl.getD (m + 1) default)
        rw [hfwllen] at hm
        rw [hfwlget m (by omega), hfwlget (m + 1) (by omega),
          show i₁ + (m + 1) + 1 = (i₁ + m + 1) + 1 by omega]
        exact hscstep w₁ _
      · -- the rightward wrap-around
        change F.step (fwl.getD (fwl.length - 1) default) (fwl.getD 0 default)
        rw [hfwllen, hfwlget (j₁ - i₁ - 1) (by omega), hfwlget 0 (by omega),
          show i₁ + (j₁ - i₁ - 1) + 1 = j₁ by omega, show i₁ + 0 + 1 = i₁ + 1 by omega,
          ← heq₁]
        exact hscstep w₁ _
    have hA : AgreesWindow (⟨bck, mdl, fwl, a - (i₀ : ℤ), hbne, hfne⟩ : FrameLasso F) a win := by
      intro k hk
      change Periodic.unrollOf bck mdl fwl (a + (k : ℤ) - (a - (i₀ : ℤ))) = win.getD k default
      rw [show a + (k : ℤ) - (a - (i₀ : ℤ)) = (i₀ : ℤ) + (k : ℤ) by omega,
        Periodic.unrollOf_mid _ _ _ (by omega) (by rw [hmdllen]; omega),
        show ((i₀ : ℤ) + (k : ℤ)).toNat = i₀ + k by omega,
        hmdlget (i₀ + k) (by omega), if_neg (by omega), if_pos (by omega)]
      congr 1
      omega
    rw [presentsWindow, Bool.and_eq_true]
    exact ⟨decide_eq_true hC, decide_eq_true hA⟩
  · change bck.length ≤ enum.length
    omega
  · change fwl.length ≤ enum.length
    omega

end FormalSystem.Metalogic.Decidability
