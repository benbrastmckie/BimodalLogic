/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Bundle.LimitMCSCoherence

/-!
# RealExtension: extending a rational family of MCSs to the reals by rational selection

A `Rat`-indexed family of maximal consistent sets is extended to an `ℝ`-indexed one by
**rational selection**: at a real point whose shifted coordinate is the cast of a rational, the
extension *selects* the rational family's own set there; only at the remaining points does it
take a limit.

## Why selection rather than a limit everywhere

The obvious alternative — take the left limit at *every* real point, rationals included — is
unavailable, and not merely inconvenient. `Bundle/LimitMCS.lean`'s module docstring records the
counterexample: agreement between the left limit at `(q : ℝ)` and `m q` fails in **both**
directions, so a uniform-limit extension does not extend the rational family, it replaces it.
Selection makes "extends rather than replaces" hold *by construction* —
`realLimitMCS_of_rat` below is a definitional unfolding, not a limit-interchange lemma — which
is exactly what the failed agreement claim was reaching for.

## What sits at the unselected points

At an unselected point the extension takes `limitMCSBelow` (`Bundle/LimitMCS.lean`), the
ultrafilter limit, rather than the plain limit set `limitSetBelow`. The limit set is consistent
but not negation-complete, so only the ultrafilter limit discharges the `is_mcs` field; that is
`limitMCSBelow_is_mcs`. The price is paid in the coherence proofs, where an unselected *source*
supplies an ultrafilter membership rather than a threshold witness, and is met by the four
`limitMCSBelow`-source variants of `Bundle/LimitMCSCoherence.lean`.

## The offset

`realLimitMCS` carries a real offset `δ` from the start, and `FMCS.toRealShift` builds the
shifted family directly. The real bundle needs its family set closed under *real* shifts, not
merely rational ones, so a construction that could only produce the unshifted family would have
to be re-run under a shift anyway. `FMCS.toReal` is the `δ = 0` instance.

## The four cases

Both coherence fields face a 2x2 matrix, on whether the source and target shifted coordinates
are selected. `Bundle/LimitMCSCoherence.lean` proves the six non-trivial cases (and documents
why the selected-to-selected cases G3 and H3 need no lemma: there the obligation is the rational
family's own field, modulo `Rat.cast_lt`). This module does the case split and dispatches.

The order hypothesis transports across the offset by adding `δ` to both sides; that transport
is stated once per proof, as `hshift`, and reused in all four branches.

## Main definitions and results

- `realLimitMCS`, with `realLimitMCS_of_rat` and `realLimitMCS_of_not_rat`.
- `realLimitMCS_is_mcs`, `realLimitMCS_forward_G`, `realLimitMCS_backward_H`.
- `FMCS.toRealShift`, `FMCS.toReal`, and `FMCS.toReal_at_rat`.

## Note on the past-side limit

`limitSetAbove` and its duals in `Bundle/LimitMCS.lean` are deliberately **unused** on this
route. The extension takes the *left* limit at unselected points and both temporal directions go
through it: `forward_G` because `allFuture` at a rational below the point propagates upward,
`backward_H` because `allPast` at rationals approaching the point from below propagates downward
past it. No above-side dual is needed, and none should be added on this account.
-/

namespace FormalSystem.Metalogic.Bundle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core

/-! ## The extension and its two unfolding lemmas -/

/--
The **real extension by rational selection** of a rational family `m` at offset `δ`.

At `x` whose shifted coordinate `x + δ` is the cast of a rational, the value is that rational's
own `m q`; elsewhere it is the ultrafilter limit from below at `x + δ`.

This is `noncomputable` irredeemably: the selection condition is an existential over `Rat` with
no decision procedure, so the `dite` runs on `Classical.propDecidable`. Do not look for a
computable variant.
-/
noncomputable def realLimitMCS (m : Rat → Set Formula) (δ : ℝ) (x : ℝ) : Set Formula := by
  classical
  exact if h : ∃ q : Rat, (q : ℝ) = x + δ then m h.choose else limitMCSBelow m (x + δ)

/--
**The selection lemma.** At a selected point the extension is the rational family's own set,
for *the* rational witnessing selection — not merely for the one `Exists.choose` happened to
produce.

This is the definitional replacement for the agreement claim that `Bundle/LimitMCS.lean`'s
docstring refutes, and it is the reason the construction is arranged by selection: the proof is
`dif_pos` followed by injectivity of the cast `Rat → ℝ`, with no limit interchange anywhere.
-/
theorem realLimitMCS_of_rat (m : Rat → Set Formula) (δ x : ℝ) (q : Rat)
    (h : (q : ℝ) = x + δ) : realLimitMCS m δ x = m q := by
  classical
  have hex : ∃ p : Rat, (p : ℝ) = x + δ := ⟨q, h⟩
  have hchoose : hex.choose = q := by
    have h1 : ((hex.choose : Rat) : ℝ) = x + δ := hex.choose_spec
    have h2 : ((hex.choose : Rat) : ℝ) = ((q : Rat) : ℝ) := by rw [h1, h]
    exact_mod_cast h2
  simp only [realLimitMCS, dif_pos hex, hchoose]

/-- **The non-selection lemma.** At an unselected point the extension is the ultrafilter limit. -/
theorem realLimitMCS_of_not_rat (m : Rat → Set Formula) (δ x : ℝ)
    (h : ¬ ∃ q : Rat, (q : ℝ) = x + δ) : realLimitMCS m δ x = limitMCSBelow m (x + δ) := by
  classical
  simp only [realLimitMCS, dif_neg h]

/-! ## The three `FMCS` fields -/

/--
**Maximal consistency of the extension.** Selected points inherit it from the rational family;
unselected points get it from `limitMCSBelow_is_mcs` (`Bundle/LimitMCS.lean`).
-/
theorem realLimitMCS_is_mcs {fc : FrameClass} (m : Rat → Set Formula)
    (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q)) (δ x : ℝ) :
    SetMaximalConsistent (fc := fc) (realLimitMCS m δ x) := by
  by_cases h : ∃ q : Rat, (q : ℝ) = x + δ
  · obtain ⟨q, hq⟩ := h
    rw [realLimitMCS_of_rat m δ x q hq]
    exact hm q
  · rw [realLimitMCS_of_not_rat m δ x h]
    exact limitMCSBelow_is_mcs m hm (x + δ)

/--
**Forward `G` coherence of the extension**, by the four-case split on selection of the two
shifted coordinates:

- selected → selected: the rational family's own `forward_G` (case G3, no lemma by design);
- selected → unselected: `limitSetBelow_forward_G_rat_source` (G1), its `limitSetBelow`
  conclusion lifted by `limitSetBelow_subset_limitMCSBelow`;
- unselected → selected: `limitMCSBelow_forward_G_rat_target` (G2);
- unselected → unselected: `limitMCSBelow_forward_G_limit` (G4).
-/
theorem realLimitMCS_forward_G (m : Rat → Set Formula)
    (hG : ∀ (s t : Rat) (φ : Formula), s < t → Formula.allFuture φ ∈ m s → φ ∈ m t)
    (δ x y : ℝ) (φ : Formula) (hxy : x < y)
    (hφ : Formula.allFuture φ ∈ realLimitMCS m δ x) :
    φ ∈ realLimitMCS m δ y := by
  have hshift : x + δ < y + δ := by linarith
  by_cases hx : ∃ q : Rat, (q : ℝ) = x + δ
  · obtain ⟨qx, hqx⟩ := hx
    rw [realLimitMCS_of_rat m δ x qx hqx] at hφ
    by_cases hy : ∃ q : Rat, (q : ℝ) = y + δ
    · obtain ⟨qy, hqy⟩ := hy
      rw [realLimitMCS_of_rat m δ y qy hqy]
      have hxylt : qx < qy := by
        have : (qx : ℝ) < (qy : ℝ) := by rw [hqx, hqy]; exact hshift
        exact_mod_cast this
      exact hG qx qy φ hxylt hφ
    · rw [realLimitMCS_of_not_rat m δ y hy]
      have hlt : (qx : ℝ) < y + δ := by rw [hqx]; exact hshift
      exact limitSetBelow_subset_limitMCSBelow m (y + δ)
        (limitSetBelow_forward_G_rat_source m hG qx (y + δ) φ hlt hφ)
  · rw [realLimitMCS_of_not_rat m δ x hx] at hφ
    by_cases hy : ∃ q : Rat, (q : ℝ) = y + δ
    · obtain ⟨qy, hqy⟩ := hy
      rw [realLimitMCS_of_rat m δ y qy hqy]
      have hlt : x + δ < (qy : ℝ) := by rw [hqy]; exact hshift
      exact limitMCSBelow_forward_G_rat_target m hG (x + δ) qy φ hlt hφ
    · rw [realLimitMCS_of_not_rat m δ y hy]
      exact limitMCSBelow_forward_G_limit m hG (x + δ) (y + δ) φ hshift hφ

/--
**Backward `H` coherence of the extension**, by the mirrored four-case split:

- selected → selected: the rational family's own `backward_H` (case H3, no lemma by design);
- selected → unselected: `limitSetBelow_backward_H_rat_source` (H1), whose hypothesis is the
  non-strict `t ≤ (q : ℝ)`, so the strict order here is passed through `le_of_lt`; the
  conclusion is lifted by `limitSetBelow_subset_limitMCSBelow`;
- unselected → selected: `limitMCSBelow_backward_H_rat_target` (H2);
- unselected → unselected: `limitMCSBelow_backward_H_limit` (H4).
-/
theorem realLimitMCS_backward_H (m : Rat → Set Formula)
    (hH : ∀ (s t : Rat) (φ : Formula), t < s → Formula.allPast φ ∈ m s → φ ∈ m t)
    (δ x y : ℝ) (φ : Formula) (hyx : y < x)
    (hφ : Formula.allPast φ ∈ realLimitMCS m δ x) :
    φ ∈ realLimitMCS m δ y := by
  have hshift : y + δ < x + δ := by linarith
  by_cases hx : ∃ q : Rat, (q : ℝ) = x + δ
  · obtain ⟨qx, hqx⟩ := hx
    rw [realLimitMCS_of_rat m δ x qx hqx] at hφ
    by_cases hy : ∃ q : Rat, (q : ℝ) = y + δ
    · obtain ⟨qy, hqy⟩ := hy
      rw [realLimitMCS_of_rat m δ y qy hqy]
      have hyxlt : qy < qx := by
        have : (qy : ℝ) < (qx : ℝ) := by rw [hqx, hqy]; exact hshift
        exact_mod_cast this
      exact hH qx qy φ hyxlt hφ
    · rw [realLimitMCS_of_not_rat m δ y hy]
      have hlt : y + δ < (qx : ℝ) := by rw [hqx]; exact hshift
      exact limitSetBelow_subset_limitMCSBelow m (y + δ)
        (limitSetBelow_backward_H_rat_source m hH qx (y + δ) φ (le_of_lt hlt) hφ)
  · rw [realLimitMCS_of_not_rat m δ x hx] at hφ
    by_cases hy : ∃ q : Rat, (q : ℝ) = y + δ
    · obtain ⟨qy, hqy⟩ := hy
      rw [realLimitMCS_of_rat m δ y qy hqy]
      have hlt : (qy : ℝ) < x + δ := by rw [hqy]; exact hshift
      exact limitMCSBelow_backward_H_rat_target m hH (x + δ) qy φ hlt hφ
    · rw [realLimitMCS_of_not_rat m δ y hy]
      exact limitMCSBelow_backward_H_limit m hH (x + δ) (y + δ) φ hshift hφ

/-! ## The extended families -/

/--
The **shifted real extension** of a rational family: an `ℝ`-indexed `FMCS` whose value at `x` is
the rational family's set at `x + δ` when that coordinate is rational, and the ultrafilter limit
there otherwise.
-/
noncomputable def FMCS.toRealShift {fc : FrameClass} (f : FMCS (fc := fc) Rat) (δ : ℝ) :
    FMCS (fc := fc) ℝ where
  mcs := realLimitMCS f.mcs δ
  is_mcs x := realLimitMCS_is_mcs f.mcs f.is_mcs δ x
  forward_G x y φ hxy hφ := realLimitMCS_forward_G f.mcs f.forward_G δ x y φ hxy hφ
  backward_H x y φ hyx hφ := realLimitMCS_backward_H f.mcs f.backward_H δ x y φ hyx hφ

/-- The **real extension** of a rational family: the unshifted instance of `FMCS.toRealShift`. -/
noncomputable def FMCS.toReal {fc : FrameClass} (f : FMCS (fc := fc) Rat) : FMCS (fc := fc) ℝ :=
  f.toRealShift 0

/--
**The extension extends rather than replaces.** At the cast of a rational the real family takes
exactly the rational family's set there.

Under rational selection this is a one-line corollary of `realLimitMCS_of_rat`. Under a
uniform-limit extension it would be false; see this module's docstring and
`Bundle/LimitMCS.lean`'s.
-/
theorem FMCS.toReal_at_rat {fc : FrameClass} (f : FMCS (fc := fc) Rat) (q : Rat) :
    (f.toReal).mcs (q : ℝ) = f.mcs q := by
  show realLimitMCS f.mcs 0 (q : ℝ) = f.mcs q
  exact realLimitMCS_of_rat f.mcs 0 (q : ℝ) q (by rw [add_zero])

end FormalSystem.Metalogic.Bundle
