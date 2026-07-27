/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleLimitGapWitness

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

Two of the four Until/Since obligations at `ℝ` are **false**, with the counterexamples recorded
at `toRealBundle_backward_since_selected_is_refuted` and
`toRealBundle_backward_until_unselected_is_refuted`. Both exhibit a genuine model over `ℝ`,
restrict its theories to `ℚ`, and observe that the real bundle's value at a gap — a limit from
below — disagrees with the real model's own theory there. Consequently
`BFMCS.toRealBundle_restricted_backward_until_since` (and therefore
`cantor_bfmcs_dense_real_restricted_buc`) is not a theorem in the generic form, and neither is
stated here.

## Main results

- `guard_transport_realLimitMCS`, `exists_rat_witness_of_realLimitMCS`.
- `toRealBundle_forward_until_selected`, `toRealBundle_forward_since_selected`.
- `toRealBundle_backward_until_selected`.
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

end FormalSystem.Metalogic.BXCanonical.Chronicle
