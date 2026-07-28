/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleLimitGapWitness
import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleLimitGuardWitness

/-!
# Until/Since at the real bundle: the mechanical transport

`Bundle/RealExtensionBundle.lean` builds the real bundle `BFMCS.toRealBundle` over a rational
bundle and transports restricted **temporal** coherence to it. This module does the same work for
restricted **Until/Since** coherence, as far as it goes.

## The one lemma everything rests on

`guard_transport_realLimitMCS` says that a guard stated over *rationals* in an interval already
guards every *real* in that interval. At a selected real the extension is a rational set and the
rational guard applies verbatim; at an unselected real the extension is `limitMCSBelow`, and the
left end of the interval is itself a legitimate `limitSetBelow` threshold, so
`limitSetBelow_subset_limitMCSBelow` upgrades the guard. This removes the selected/unselected
split from every guard obligation in the file.

## What transports and what does not

The four obligations do **not** behave alike, and the asymmetry is structural rather than an
artifact of these proofs. `realLimitMCS` takes the limit **from below**, so a membership at an
unselected real is information about the rationals *underneath* it:

- **Forward `untl`, forward `snce`, at a selected target** — `toRealBundle_forward_until_selected`
  and `toRealBundle_forward_since_selected`. Mechanical: the rational witness `s'` transports to
  the real `(s' : ℝ) - δ` and the rational guard transports by the guard lemma.
- **Backward `untl` at a selected target** — `toRealBundle_backward_until_selected`. The real
  witness `s` sits *above* the target, so descending from it (`limitMCSBelow_cofinal_below`, via
  `exists_rat_witness_of_realLimitMCS`) moves *towards* the target and lands inside the guarded
  interval. That is the whole reason this case closes.
- **Backward `snce`, and backward `untl` at an unselected target** — refuted; see the
  `Refutations` section below.

`cantor_bfmcs_dense_real_restricted_fuc` is **deliberately absent** from this module. Forward
`untl` from a membership at an *unselected* target — forward case B — is a separate obligation
with its own probe, and its absence here is not an oversight and does not mean the module is
half-finished.

## Refutations

The generic backward transport

> `B.RestrictedBackwardUntilSinceCoherent root →`
> `(B.toRealBundle).RestrictedBackwardUntilSinceCoherent root`

is **false**, and is therefore not stated in this module; nor is the chronicle instance that
would be obtained by composing it with the rational backward instance. Two independent
counterexample families are recorded below. Both are built the same way — take a genuine model
`M` over the flow `ℝ`, set `m q := {χ | M, q ⊨ χ}` for rational `q`, and observe that the real
bundle's value at a gap is a limit **from below** and so disagrees with `M`'s own theory at that
gap. Taking theories of a real model makes every `m q` maximal consistent at
`FrameClass.Dedekind` for free, and makes `forward_G`/`backward_H` hold semantically, so each
family really is an `FMCS (fc := FrameClass.Dedekind) Rat`; the one-family bundle over it has
both modal fields, with `□χ ↔ χ` at a single modal world.

### Refutation 1 — backward `snce`, at a *selected* target

Fix an irrational `g` with `0 < g < 5`. Let `V(φ) = (0, g)` and `V(ψ) = (g, 5)`, and take
`root := snce φ ψ`, `δ := 0`.

*The hypothesis holds.* The only Until/Since formula in `subformulaClosure root` is `snce φ ψ`
itself, and the rational antecedent is never satisfied: a rational `u` with `φ ∈ m u` lies in
`(0, g)`, so the rationals of `(u, t)` include rationals of `(u, g)`, where `ψ` fails. Rational
restricted backward coherence therefore holds vacuously.

*The real witness pattern holds* at the selected target `t := 5` with the unselected witness
`s := g`. First, `φ ∈ realLimitMCS m 0 g`, because `{q | φ ∈ m q} ⊇ (0, g) ∩ ℚ` is a
`limitFilterBelow g` generator, so `φ ∈ limitSetBelow m g ⊆ limitMCSBelow m g`. Second, the guard
holds at every real of `(g, 5)`: directly at a selected one, and at an unselected one because
every rational of `(g, r)` carries `ψ`.

*The conclusion fails.* `snce φ ψ ∉ m 5`, since a real `u < 5` with `M, u ⊨ φ` lies in `(0, g)`
and `ψ` then fails throughout `(u, g]`.

*Isolation.* Nothing above uses the modal dimension, the ultrafilter's choice, or the difference
between the deferral and subformula closures. The single load-bearing fact is that the real
bundle at the gap `g` contains `φ` because `φ` is *eventually true from below* there, while `M`'s
own point `g` does not satisfy `φ`. The real bundle's witness pattern can thus be met by a
witness the rational family cannot supply — and for `snce` the witness lies *below* the target,
so descending from it (the move that rescues `untl`) leaves the guarded interval rather than
entering it. This is exactly the asymmetry noted at
`toRealBundle_backward_since_selected_of_rat_witness`.

### Refutation 2 — backward `untl`, at an *unselected* target

Fix an irrational `g` with `0 < g < 2 < 3`, rationals `t_n ↗ g`, and rationals
`α_n ∈ (t_n, t_{n+1})`. Let `V(ψ) = (⋃ n, (t_n, α_n)) ∪ (g, 3)` and `V(φ) = (g, 3)`, and take
`root := untl φ ψ`, `δ := 0`.

*The hypothesis holds.* Again `untl φ ψ` is the only Until/Since formula in the closure. At a
rational `t < g` the antecedent fails, since any `φ`-point is above `g` and the rationals of
`(t, g)` include `¬ψ` points from the intervals `(α_n, t_{n+1})`. At a rational `t ∈ (g, 3)` the
antecedent's conclusion is true in `M` anyway. At `t ≥ 3` there is no `φ`-point above `t`.

*The real witness pattern holds* at the unselected target `t := g`, with the selected witness
`s := 2`: `φ ∈ m 2` and the guard holds at every real of `(g, 2)`.

*The conclusion fails.* No rational below `g` carries `untl φ ψ`, and `{q : ℚ | (q : ℝ) < g}` is
a `limitFilterBelow g` generator, so the complement of `{q | untl φ ψ ∈ m q}` is large and
`untl φ ψ ∉ limitMCSBelow m g`.

### What these do and do not settle

They refute the transport theorem **as stated above**, whose only hypothesis on the rational
bundle is restricted backward coherence. They do **not** settle the chronicle instance. Neither
family satisfies the *unrestricted* rational forward Until coherence that `cantorBfmcsDense`
enjoys: in Refutation 1 the formula `untl φ.neg φ` holds at rationals of `(0, g)` with the
irrational witness `g` and no rational witness, and in Refutation 2 the same happens for the
definable gap of `φ.neg` at `g`. Deciding whether a transport strengthened by those hypotheses
(equivalently, by a `BFMCS.LimitFutureWitness`-style gap discharge applied to the *witness*
rather than to `someFuture`) is provable is gap-facing work of exactly the kind that this
module's forward case B counterpart owns, and it is deliberately not attempted here.

## Main results

- `guard_transport_realLimitMCS`, `exists_rat_witness_of_realLimitMCS`.
- `toRealBundle_forward_until_selected`, `toRealBundle_forward_since_selected`.
- `toRealBundle_backward_until_selected`,
  `toRealBundle_backward_since_selected_of_rat_witness`.
- `cantor_bfmcs_dense_real_restricted_tc`.
-/

namespace FormalSystem.Metalogic.Bundle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core

/-! ## The shared guard lemma -/

/--
**A rational guard is already a real guard.**

If `ψ` lies in `m q` for every rational `q` strictly between the reals `a` and `b`, then `ψ` lies
in the real extension `realLimitMCS m δ` at every real point whose shifted coordinate `r + δ`
lies strictly between `a` and `b`.

At a selected point this is the rational guard read off through `realLimitMCS_of_rat`. At an
unselected point the extension is `limitMCSBelow m (r + δ)`, and `a` itself is a threshold
witnessing `ψ ∈ limitSetBelow m (r + δ)`: every rational in `(a, r + δ)` is in `(a, b)`, since
`r + δ < b`. `limitSetBelow_subset_limitMCSBelow` then finishes.

This is what removes the unselected-point difficulty from **every** guard obligation over the
real bundle, and it is stated free of any bundle so that it can be reused.
-/
theorem guard_transport_realLimitMCS (m : Rat → Set Formula) (δ a b : ℝ) (ψ : Formula)
    (hguard : ∀ q : Rat, a < (q : ℝ) → (q : ℝ) < b → ψ ∈ m q)
    (r : ℝ) (hra : a < r + δ) (hrb : r + δ < b) :
    ψ ∈ realLimitMCS m δ r := by
  by_cases hx : ∃ p : Rat, (p : ℝ) = r + δ
  · obtain ⟨p, hp⟩ := hx
    rw [realLimitMCS_of_rat m δ r p hp]
    exact hguard p (by rw [hp]; exact hra) (by rw [hp]; exact hrb)
  · rw [realLimitMCS_of_not_rat m δ r hx]
    refine limitSetBelow_subset_limitMCSBelow m (r + δ) ⟨a, hra, ?_⟩
    intro q h1 h2
    exact hguard q h1 (by linarith)

/-! ## Rational interpolation of a real witness -/

/--
**A real witness restricts to a rational one, without overshooting.**

If `φ` lies in the real extension at `s`, then for any real threshold `z` below the shifted
coordinate `s + δ` there is a rational `u` with `z < u ≤ s + δ` and `φ ∈ m u`.

At a selected `s` the rational is the selecting one and the bound is an equality; at an
unselected `s` it is `limitMCSBelow_cofinal_below`, which produces rationals arbitrarily close
below `s + δ`. The `≤` (rather than `<`) is exactly what makes the two cases share a statement.

Note the direction: the rational produced is **at or below** `s + δ`. That is why this helper
serves the backward `untl` obligation, whose witness sits above the target, and why it does
*not* serve the backward `snce` obligation, whose witness sits below the target — there,
descending from the witness moves away from the guarded interval rather than into it.
-/
theorem exists_rat_witness_of_realLimitMCS (m : Rat → Set Formula) (δ s : ℝ) (φ : Formula)
    (hφ : φ ∈ realLimitMCS m δ s) (z : ℝ) (hz : z < s + δ) :
    ∃ u : Rat, z < (u : ℝ) ∧ (u : ℝ) ≤ s + δ ∧ φ ∈ m u := by
  by_cases hx : ∃ p : Rat, (p : ℝ) = s + δ
  · obtain ⟨p, hp⟩ := hx
    rw [realLimitMCS_of_rat m δ s p hp] at hφ
    exact ⟨p, by rw [hp]; exact hz, le_of_eq hp, hφ⟩
  · rw [realLimitMCS_of_not_rat m δ s hx] at hφ
    obtain ⟨u, h1, h2, h3⟩ := limitMCSBelow_cofinal_below m (s + δ) hφ z hz
    exact ⟨u, h1, le_of_lt h2, h3⟩

/-! ## Forward case A: a selected target -/

/--
**Forward `untl` at a selected real.** From `untl φ ψ` in the extension at a real `t` whose
shifted coordinate is the rational `p`, the rational forward coherence supplies a rational
witness `s'` and a rational guard on `(p, s')`; the real witness is `(s' : ℝ) - δ`, whose own
shifted coordinate is `s'`, and the guard transports by `guard_transport_realLimitMCS`.

No limit reasoning occurs anywhere: at a selected target the extension *is* the rational family.
-/
theorem toRealBundle_forward_until_selected {fc : FrameClass} (B : BFMCS (fc := fc) Rat)
    (root : Formula) (h_rfuc : B.RestrictedForwardUntilSinceCoherent root)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.untl φ ψ ∈ subformulaClosure root)
    (p : Rat) (hp : (p : ℝ) = t + δ)
    (hU : Formula.untl φ ψ ∈ realLimitMCS fam.mcs δ t) :
    ∃ s : ℝ, t < s ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
      ∀ r : ℝ, t < r → r < s → ψ ∈ realLimitMCS fam.mcs δ r := by
  rw [realLimitMCS_of_rat fam.mcs δ t p hp] at hU
  obtain ⟨s', hps', hφ, hguard⟩ := (h_rfuc fam hfam).1 p φ ψ hsub hU
  have hlt : (p : ℝ) < (s' : ℝ) := by exact_mod_cast hps'
  rw [hp] at hlt
  refine ⟨(s' : ℝ) - δ, by linarith, ?_, ?_⟩
  · rw [realLimitMCS_of_rat fam.mcs δ ((s' : ℝ) - δ) s' (by ring)]
    exact hφ
  · intro r hr1 hr2
    refine guard_transport_realLimitMCS fam.mcs δ (t + δ) ((s' : ℝ)) ψ ?_ r (by linarith)
      (by linarith)
    intro q hq1 hq2
    refine hguard q ?_ ?_
    · rw [← hp] at hq1; exact_mod_cast hq1
    · exact_mod_cast hq2

/--
**Forward `snce` at a selected real**: the mirror of `toRealBundle_forward_until_selected`, with
the witness below the target and the guard on `(s', p)`.
-/
theorem toRealBundle_forward_since_selected {fc : FrameClass} (B : BFMCS (fc := fc) Rat)
    (root : Formula) (h_rfuc : B.RestrictedForwardUntilSinceCoherent root)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.snce φ ψ ∈ subformulaClosure root)
    (p : Rat) (hp : (p : ℝ) = t + δ)
    (hS : Formula.snce φ ψ ∈ realLimitMCS fam.mcs δ t) :
    ∃ s : ℝ, s < t ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
      ∀ r : ℝ, s < r → r < t → ψ ∈ realLimitMCS fam.mcs δ r := by
  rw [realLimitMCS_of_rat fam.mcs δ t p hp] at hS
  obtain ⟨s', hs'p, hφ, hguard⟩ := (h_rfuc fam hfam).2 p φ ψ hsub hS
  have hlt : (s' : ℝ) < (p : ℝ) := by exact_mod_cast hs'p
  rw [hp] at hlt
  refine ⟨(s' : ℝ) - δ, by linarith, ?_, ?_⟩
  · rw [realLimitMCS_of_rat fam.mcs δ ((s' : ℝ) - δ) s' (by ring)]
    exact hφ
  · intro r hr1 hr2
    refine guard_transport_realLimitMCS fam.mcs δ ((s' : ℝ)) (t + δ) ψ ?_ r (by linarith)
      (by linarith)
    intro q hq1 hq2
    refine hguard q ?_ ?_
    · exact_mod_cast hq1
    · rw [← hp] at hq2; exact_mod_cast hq2

/-! ## Backward `untl` at a selected target -/

/--
**Backward `untl` at a selected real.** From a real witness pattern at a real `t` whose shifted
coordinate is the rational `p`, the rational backward coherence delivers `untl φ ψ ∈ fam.mcs p`.

The real witness `s` is interpolated to a rational `u` with `p < u ≤ s + δ`
(`exists_rat_witness_of_realLimitMCS`). Every rational `q` with `p < q < u` has
`(q : ℝ) - δ` strictly between `t` and `s`, so the real guard applies there and
`realLimitMCS_of_rat` reads it off as `ψ ∈ fam.mcs q`.

This is the one backward case that survives. `exists_rat_witness_of_realLimitMCS` descends from
the witness, and here the witness is *above* the target, so the descent stays inside the guarded
interval `(t, s)`. The `snce` mirror has the witness below the target and the same descent leaves
the guarded interval — see `toRealBundle_backward_since_selected_is_refuted`.
-/
theorem toRealBundle_backward_until_selected {fc : FrameClass} (B : BFMCS (fc := fc) Rat)
    (root : Formula) (h_rbuc : B.RestrictedBackwardUntilSinceCoherent root)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.untl φ ψ ∈ subformulaClosure root)
    (p : Rat) (hp : (p : ℝ) = t + δ)
    (hwit : ∃ s : ℝ, t < s ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
      ∀ r : ℝ, t < r → r < s → ψ ∈ realLimitMCS fam.mcs δ r) :
    Formula.untl φ ψ ∈ realLimitMCS fam.mcs δ t := by
  obtain ⟨s, hts, hφ, hguard⟩ := hwit
  rw [realLimitMCS_of_rat fam.mcs δ t p hp]
  obtain ⟨u, hpu, hus, hφu⟩ :=
    exists_rat_witness_of_realLimitMCS fam.mcs δ s φ hφ (p : ℝ) (by rw [hp]; linarith)
  refine (h_rbuc fam hfam).1 p φ ψ hsub ⟨u, by exact_mod_cast hpu, hφu, ?_⟩
  intro q hpq hqu
  have h1 : (p : ℝ) < (q : ℝ) := by exact_mod_cast hpq
  have h2 : (q : ℝ) < (u : ℝ) := by exact_mod_cast hqu
  rw [hp] at h1
  have hr := hguard ((q : ℝ) - δ) (by linarith) (by linarith)
  rwa [realLimitMCS_of_rat fam.mcs δ ((q : ℝ) - δ) q (by ring)] at hr

/--
**Backward `snce` at a selected target, from a selected witness.**

The `snce` mirror of `toRealBundle_backward_until_selected`, and it is stated with the witness's
shifted coordinate `w` assumed rational rather than obtained by interpolation. That hypothesis is
not a convenience: for `snce` the witness lies *below* the target, so
`exists_rat_witness_of_realLimitMCS` — which descends — would produce a rational strictly below
`w`, outside the guarded interval `(s, t)`, where nothing is known about `ψ`. The Refutations
section of this module's docstring exhibits a family where exactly that failure is fatal.

With `w` rational the proof is the mirror image of the `untl` case and uses no limit reasoning at
all: every rational `q` with `w < q < p` has `(q : ℝ) - δ` strictly between `s` and `t`, so the
real guard reads off as `ψ ∈ fam.mcs q`.
-/
theorem toRealBundle_backward_since_selected_of_rat_witness {fc : FrameClass}
    (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_rbuc : B.RestrictedBackwardUntilSinceCoherent root)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.snce φ ψ ∈ subformulaClosure root)
    (p : Rat) (hp : (p : ℝ) = t + δ)
    (s : ℝ) (hst : s < t) (w : Rat) (hw : (w : ℝ) = s + δ)
    (hφ : φ ∈ realLimitMCS fam.mcs δ s)
    (hguard : ∀ r : ℝ, s < r → r < t → ψ ∈ realLimitMCS fam.mcs δ r) :
    Formula.snce φ ψ ∈ realLimitMCS fam.mcs δ t := by
  rw [realLimitMCS_of_rat fam.mcs δ t p hp]
  rw [realLimitMCS_of_rat fam.mcs δ s w hw] at hφ
  have hwp : (w : ℝ) < (p : ℝ) := by rw [hw, hp]; linarith
  refine (h_rbuc fam hfam).2 p φ ψ hsub ⟨w, by exact_mod_cast hwp, hφ, ?_⟩
  intro q hwq hqp
  have h1 : (w : ℝ) < (q : ℝ) := by exact_mod_cast hwq
  have h2 : (q : ℝ) < (p : ℝ) := by exact_mod_cast hqp
  rw [hw] at h1
  rw [hp] at h2
  have hr := hguard ((q : ℝ) - δ) (by linarith) (by linarith)
  rwa [realLimitMCS_of_rat fam.mcs δ ((q : ℝ) - δ) q (by ring)] at hr

/-! ## Backward `untl` at an unselected target -/

/--
**Backward `untl` at an unselected real**, using the guard-reach obligation.

The target's shifted coordinate `T := t + δ` is a gap. The real witness interpolates to a
rational `u ∈ (T, s + δ]` (`exists_rat_witness_of_realLimitMCS`), and every rational of `(T, u)`
is a selected real of `(t, s)`, so the real guard reads off as a *rational* guard on `(T, u)`.

That rational guard is exactly the antecedent of `BFMCS.LimitGuardBelow`: `ψ` holds on an
interval abutting the gap `T` **from above**, so — no `ψ`-right gap at `T` being possible — it
already holds on an interval `(a, T)` abutting `T` from below. The rational backward coherence
then fires at *every* rational `q ∈ (a, T)` with the single witness `u`, its guard obligation on
`(q, u)` being covered by `(a, T) ∪ (T, u)` — the two halves meet because `T` itself is not
rational. So `untl φ ψ ∈ limitSetBelow fam.mcs T`, which is the extension's value at `t` by
`limitSetBelow_subset_limitMCSBelow`.
-/
theorem toRealBundle_backward_until_unselected {fc : FrameClass} (B : BFMCS (fc := fc) Rat)
    (root : Formula) (h_rbuc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_lgb : B.LimitGuardBelow)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.untl φ ψ ∈ subformulaClosure root)
    (hx : ¬ ∃ p : Rat, (p : ℝ) = t + δ)
    (hwit : ∃ s : ℝ, t < s ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
      ∀ r : ℝ, t < r → r < s → ψ ∈ realLimitMCS fam.mcs δ r) :
    Formula.untl φ ψ ∈ realLimitMCS fam.mcs δ t := by
  obtain ⟨s, hts, hφ, hguard⟩ := hwit
  obtain ⟨u, hu1, hu2, hφu⟩ :=
    exists_rat_witness_of_realLimitMCS fam.mcs δ s φ hφ (t + δ) (by linarith)
  have hrg : ∀ q : Rat, t + δ < (q : ℝ) → (q : ℝ) < (u : ℝ) → ψ ∈ fam.mcs q := by
    intro q h1 h2
    have hr := hguard ((q : ℝ) - δ) (by linarith) (by linarith)
    rwa [realLimitMCS_of_rat fam.mcs δ ((q : ℝ) - δ) q (by ring)] at hr
  obtain ⟨a, ha, hA⟩ := h_lgb fam hfam (t + δ) hx ψ u hu1 hrg
  rw [realLimitMCS_of_not_rat fam.mcs δ t hx]
  refine limitSetBelow_subset_limitMCSBelow fam.mcs (t + δ) ⟨a, ha, ?_⟩
  intro q h1 h2
  have hqu : (q : ℝ) < (u : ℝ) := by linarith
  refine (h_rbuc fam hfam).1 q φ ψ hsub ⟨u, by exact_mod_cast hqu, hφu, ?_⟩
  intro w hw1 hw2
  have hw1' : (q : ℝ) < (w : ℝ) := by exact_mod_cast hw1
  have hw2' : (w : ℝ) < (u : ℝ) := by exact_mod_cast hw2
  rcases lt_trichotomy ((w : ℝ)) (t + δ) with h | h | h
  · exact hA w (by linarith) h
  · exact absurd ⟨w, h⟩ hx
  · exact hrg w h hw2'

/-! ## Backward `snce`: the witness placed below the gap -/

/--
**The `snce` witness, relocated to a rational strictly below the target.**

Given a real witness `s < t` for `snce φ ψ` over the real bundle, this produces a *rational* `u`
with `(u : ℝ) < t + δ`, `φ ∈ fam.mcs u`, and `ψ ∈ fam.mcs q` for **every** rational `q` between
`u` and `t + δ`. That triple is precisely the antecedent of the rational backward coherence, at
any rational target in `(u, t + δ]`.

Both selection cases go through, and neither needs the target to be selected:

- *Selected witness.* `s + δ` is the rational `w`; take `u := w` and read the real guard off at
  each rational of `(w, t + δ)`.
- *Unselected witness.* `S := s + δ` is a gap. The real guard gives a rational guard on
  `(S, c)` for any rational `c ∈ (S, t + δ)`, so `BFMCS.LimitGuardBelow` extends `ψ` **past the
  gap**, to an interval `(a, S)` abutting `S` from below. `limitMCSBelow_cofinal_below` then
  descends from `φ ∈ limitMCSBelow fam.mcs S` into that very interval, yielding `u ∈ (a, S)`
  with `φ ∈ fam.mcs u`. The guard on `(u, t + δ)` is `(a, S) ∪ (S, t + δ)`; the gap `S` is not
  rational, so nothing is missed at the join.

This is the step the earlier refutation of the guard-free transport turns on. Descending from an
`snce` witness does leave the interval that the *real* guard covers — but the guarded interval
does not stop at the gap, because a `ψ`-right gap there is exactly what `Axiom.prior_S_gap`
forbids (Reynolds 1992's `γ⁻` and *right gaps*, printed p.175). Placing the new witness strictly
between two existing rational points is Burgess 1982 I's own construction step (printed
pp.372-373, where the interpolated point is `z = (x + y)/2`).
-/
theorem exists_rat_since_witness_below_of_limitGuardBelow {fc : FrameClass}
    (B : BFMCS (fc := fc) Rat) (h_lgb : B.LimitGuardBelow)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t s : ℝ) (φ ψ : Formula)
    (hst : s < t) (hφ : φ ∈ realLimitMCS fam.mcs δ s)
    (hguard : ∀ r : ℝ, s < r → r < t → ψ ∈ realLimitMCS fam.mcs δ r) :
    ∃ u : Rat, (u : ℝ) < t + δ ∧ φ ∈ fam.mcs u ∧
      ∀ q : Rat, (u : ℝ) < (q : ℝ) → (q : ℝ) < t + δ → ψ ∈ fam.mcs q := by
  have hrg : ∀ q : Rat, s + δ < (q : ℝ) → (q : ℝ) < t + δ → ψ ∈ fam.mcs q := by
    intro q h1 h2
    have hr := hguard ((q : ℝ) - δ) (by linarith) (by linarith)
    rwa [realLimitMCS_of_rat fam.mcs δ ((q : ℝ) - δ) q (by ring)] at hr
  by_cases hy : ∃ w : Rat, (w : ℝ) = s + δ
  · obtain ⟨w, hw⟩ := hy
    rw [realLimitMCS_of_rat fam.mcs δ s w hw] at hφ
    refine ⟨w, by rw [hw]; linarith, hφ, ?_⟩
    intro q h1 h2
    exact hrg q (by rw [← hw]; exact h1) h2
  · obtain ⟨c, hc1, hc2⟩ := exists_rat_btwn (show s + δ < t + δ by linarith)
    obtain ⟨a, ha, hA⟩ :=
      h_lgb fam hfam (s + δ) hy ψ c hc1 (fun q h1 h2 => hrg q h1 (by linarith))
    rw [realLimitMCS_of_not_rat fam.mcs δ s hy] at hφ
    obtain ⟨u, hu1, hu2, hφu⟩ := limitMCSBelow_cofinal_below fam.mcs (s + δ) hφ a ha
    refine ⟨u, by linarith, hφu, ?_⟩
    intro q h1 h2
    rcases lt_trichotomy ((q : ℝ)) (s + δ) with h | h | h
    · exact hA q (by linarith) h
    · exact absurd ⟨q, h⟩ hy
    · exact hrg q h h2

/--
**Backward `snce` at a selected target, from an unselected witness.**

The companion of `toRealBundle_backward_since_selected_of_rat_witness`, covering exactly the
case that lemma's rational-witness hypothesis excludes. The relocated rational witness comes from
`exists_rat_since_witness_below_of_limitGuardBelow`, and the rational backward coherence fires
once, at the target's own rational coordinate.
-/
theorem toRealBundle_backward_since_selected_of_gap_witness {fc : FrameClass}
    (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_rbuc : B.RestrictedBackwardUntilSinceCoherent root) (h_lgb : B.LimitGuardBelow)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.snce φ ψ ∈ subformulaClosure root)
    (p : Rat) (hp : (p : ℝ) = t + δ)
    (s : ℝ) (hst : s < t) (hφ : φ ∈ realLimitMCS fam.mcs δ s)
    (hguard : ∀ r : ℝ, s < r → r < t → ψ ∈ realLimitMCS fam.mcs δ r) :
    Formula.snce φ ψ ∈ realLimitMCS fam.mcs δ t := by
  obtain ⟨u, hut, hφu, hg⟩ :=
    exists_rat_since_witness_below_of_limitGuardBelow B h_lgb fam hfam δ t s φ ψ hst hφ hguard
  rw [realLimitMCS_of_rat fam.mcs δ t p hp]
  have hup : (u : ℝ) < (p : ℝ) := by rw [hp]; exact hut
  refine (h_rbuc fam hfam).2 p φ ψ hsub ⟨u, by exact_mod_cast hup, hφu, ?_⟩
  intro q h1 h2
  have h1' : (u : ℝ) < (q : ℝ) := by exact_mod_cast h1
  have h2' : (q : ℝ) < (p : ℝ) := by exact_mod_cast h2
  rw [hp] at h2'
  exact hg q h1' h2'

/--
**Backward `snce` at an unselected target.**

No gap lemma is needed *at the target*: the relocated rational witness `u` lies below every
rational `q ∈ (u, t + δ)`, and the guard covers `(u, q) ⊆ (u, t + δ)`, so rational backward
coherence puts `snce φ ψ` in `fam.mcs q` for **every** such `q` at once. That is membership in
`limitSetBelow fam.mcs (t + δ)` with threshold `(u : ℝ)`, hence in the extension at `t`.
-/
theorem toRealBundle_backward_since_unselected {fc : FrameClass} (B : BFMCS (fc := fc) Rat)
    (root : Formula) (h_rbuc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_lgb : B.LimitGuardBelow)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.snce φ ψ ∈ subformulaClosure root)
    (hx : ¬ ∃ p : Rat, (p : ℝ) = t + δ)
    (s : ℝ) (hst : s < t) (hφ : φ ∈ realLimitMCS fam.mcs δ s)
    (hguard : ∀ r : ℝ, s < r → r < t → ψ ∈ realLimitMCS fam.mcs δ r) :
    Formula.snce φ ψ ∈ realLimitMCS fam.mcs δ t := by
  obtain ⟨u, hut, hφu, hg⟩ :=
    exists_rat_since_witness_below_of_limitGuardBelow B h_lgb fam hfam δ t s φ ψ hst hφ hguard
  rw [realLimitMCS_of_not_rat fam.mcs δ t hx]
  refine limitSetBelow_subset_limitMCSBelow fam.mcs (t + δ) ⟨(u : ℝ), hut, ?_⟩
  intro q h1 h2
  refine (h_rbuc fam hfam).2 q φ ψ hsub ⟨u, by exact_mod_cast h1, hφu, ?_⟩
  intro w hw1 hw2
  have hw1' : (u : ℝ) < (w : ℝ) := by exact_mod_cast hw1
  have hw2' : (w : ℝ) < (q : ℝ) := by exact_mod_cast hw2
  exact hg w hw1' (by linarith)

/-! ## The strengthened backward transport -/

/--
**Transport of restricted backward Until/Since coherence to the real bundle.**

The guard-free form of this statement is false — see the `Refutations` section of this module's
docstring. The single added hypothesis `BFMCS.LimitGuardBelow` is what excludes both refuting
families, and it is not an extra assumption in practice: the chronicle bundle discharges it from
`Axiom.prior_S_gap`.

Four cases, on the selection of the target's shifted coordinate `T := t + δ` and (for `snce`) of
the witness's `S := s + δ`:

| case | route |
|---|---|
| `untl`, `T` selected | `toRealBundle_backward_until_selected` — no gap reasoning |
| `untl`, `T` unselected | `toRealBundle_backward_until_unselected` |
| `snce`, `T` and `S` selected | `toRealBundle_backward_since_selected_of_rat_witness` |
| `snce`, `T` selected, `S` a gap | `toRealBundle_backward_since_selected_of_gap_witness` |
| `snce`, `T` unselected | `toRealBundle_backward_since_unselected` |

Only the `snce` branch splits twice; the `untl` branch never needs to know whether its witness is
selected, because `exists_rat_witness_of_realLimitMCS` descends *towards* the target there.
-/
theorem BFMCS.toRealBundle_restricted_backward_until_since {fc : FrameClass}
    (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_rbuc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_lgb : B.LimitGuardBelow) :
    (B.toRealBundle).RestrictedBackwardUntilSinceCoherent root := by
  rintro G ⟨fam, hfam, δ, rfl⟩
  constructor
  · intro t φ ψ hsub hwit
    have hwit' : ∃ s : ℝ, t < s ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
        ∀ r : ℝ, t < r → r < s → ψ ∈ realLimitMCS fam.mcs δ r := hwit
    show Formula.untl φ ψ ∈ realLimitMCS fam.mcs δ t
    by_cases hx : ∃ p : Rat, (p : ℝ) = t + δ
    · obtain ⟨p, hp⟩ := hx
      exact toRealBundle_backward_until_selected B root h_rbuc fam hfam δ t φ ψ hsub p hp hwit'
    · exact toRealBundle_backward_until_unselected B root h_rbuc h_lgb fam hfam δ t φ ψ hsub hx
        hwit'
  · intro t φ ψ hsub hwit
    have hwit' : ∃ s : ℝ, s < t ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
        ∀ r : ℝ, s < r → r < t → ψ ∈ realLimitMCS fam.mcs δ r := hwit
    obtain ⟨s, hst, hφ, hguard⟩ := hwit'
    show Formula.snce φ ψ ∈ realLimitMCS fam.mcs δ t
    by_cases hx : ∃ p : Rat, (p : ℝ) = t + δ
    · obtain ⟨p, hp⟩ := hx
      by_cases hy : ∃ w : Rat, (w : ℝ) = s + δ
      · obtain ⟨w, hw⟩ := hy
        exact toRealBundle_backward_since_selected_of_rat_witness B root h_rbuc fam hfam δ t φ ψ
          hsub p hp s hst w hw hφ hguard
      · exact toRealBundle_backward_since_selected_of_gap_witness B root h_rbuc h_lgb fam hfam δ t
          φ ψ hsub p hp s hst hφ hguard
    · exact toRealBundle_backward_since_unselected B root h_rbuc h_lgb fam hfam δ t φ ψ hsub hx s
        hst hφ hguard

end FormalSystem.Metalogic.Bundle

namespace FormalSystem.Metalogic.BXCanonical.Chronicle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle

/-! ## The chronicle real instance for temporal coherence -/

/--
**Restricted temporal coherence for the real bundle over `cantorBfmcsDense`.**

The composition of `BFMCS.toRealBundle_restricted_temporally_coherent` with the rational instance
`cantor_bfmcs_dense_restricted_tc` and the gap discharge
`cantor_bfmcs_dense_limit_future_witness`. Neither of the latter two is modified here.

`cantor_bfmcs_dense_restricted_tc` carries an unnamed closure-containment hypothesis, discharged
at the call site by `deferralClosure_subset_extendedDeferralClosure`; it is threaded through
unchanged. The `hfc : FrameClass.Dedekind ≤ fc` hypothesis comes from the gap discharge and is
likewise threaded rather than discharged here.
-/
theorem cantor_bfmcs_dense_real_restricted_tc (fc : FrameClass) (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula) :
    ((cantorBfmcsDense fc A h_mcs h_box_dense).toRealBundle).RestrictedTemporallyCoherent root :=
  BFMCS.toRealBundle_restricted_temporally_coherent _ root
    (cantor_bfmcs_dense_restricted_tc fc A h_mcs h_box_dense root
      (fun _ψ hψ => Finset.mem_toList.mpr
        (deferralClosure_subset_extendedDeferralClosure root hψ)))
    (cantor_bfmcs_dense_limit_future_witness fc hfc A h_mcs h_box_dense root)

/-! ## The chronicle real instance for backward Until/Since coherence -/

/--
**Restricted backward Until/Since coherence for the real bundle over `cantorBfmcsDense`.**

The composition of `BFMCS.toRealBundle_restricted_backward_until_since` with the rational
instance `cantor_bfmcs_dense_restricted_buc` and the guard-reach discharge
`cantor_bfmcs_dense_limit_guard_below`. Neither of the latter two is modified here.

The transport's guard-free form is refuted (see this module's `Refutations` section); what makes
the instance nonetheless available is that the chronicle bundle *does* satisfy
`BFMCS.LimitGuardBelow`, discharged from `Axiom.prior_S_gap`. As with
`cantor_bfmcs_dense_real_restricted_tc`, the `hfc : FrameClass.Dedekind ≤ fc` hypothesis comes
from the gap discharge and is threaded rather than discharged here.
-/
theorem cantor_bfmcs_dense_real_restricted_buc (fc : FrameClass)
    (hfc : FrameClass.Dedekind ≤ fc) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula) :
    ((cantorBfmcsDense fc A h_mcs h_box_dense).toRealBundle).RestrictedBackwardUntilSinceCoherent
      root :=
  BFMCS.toRealBundle_restricted_backward_until_since _ root
    (cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense root)
    (cantor_bfmcs_dense_limit_guard_below fc hfc A h_mcs h_box_dense)

end FormalSystem.Metalogic.BXCanonical.Chronicle
