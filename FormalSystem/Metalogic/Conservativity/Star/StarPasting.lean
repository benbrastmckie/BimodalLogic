/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PlusLanguage.PlusPasting
import FormalSystem.Semantics.StarLanguage.StarValidity

/-!
# The two L⋆ purity congruences, and PS / US over `StarFormula`

The semantic content the `paste` and `untl_paste` arms of `StarAxiom` consume
(`StarLanguage/Axioms.lean`). Everything here is the L⋆ counterpart of
`Semantics/PlusLanguage/PlusPasting.lean`'s pasting block, with the stored-time vector threaded through.

## What is reused rather than rebuilt

`Semantics/PlusLanguage/PlusPasting.lean` is imported and consumed **read-only**. Its pasting construction —
`paste`, `paste_isTotal`, `paste_agreeFrom`, `paste_agreeUpTo`, `AgreeFrom`, `AgreeUpTo`,
`agreeFrom_mono`, `agreeUpTo_mono` — is formula-independent: it splices two total histories at a
time and says nothing about any language. Only the two *congruences* mention formulas, and those
are what this module re-proves by induction on the L⋆ purity predicates.

## The register vector, and why the motive quantifies over it

`star_truth_congr_agreeFrom` is stated with `∀ v` **inside** the induction motive rather than
fixed outside it. The `timeStore` case recurses at `Function.update v i t`, a different vector
from the one the statement was entered with, so a motive with `v` fixed does not close.

## The widening this module makes possible

`StarIsPureFuture.box` and `.stab` admit **arbitrary** bodies (`StarLanguage/Formula.lean`),
exactly as their L⁺ counterparts do. So `□↓¹p` is pure-future, and PS / US over `StarFormula`
therefore reach register-carrying formulas that no `ofPlus` instance supplies — a proper
widening, independent of the one `RecallFree` carries for `modal_future`.

## The temporal duals are separate theorems, not instances of the same one

PS and US are **not** each other's duals. `swapTemporal` fixes `⟐` and exchanges `untl`/`snce`,
so the dual of PS is PS with the conjuncts exchanged (`star_paste_valid'`) and the dual of US is
SS (`star_snce_paste_valid`). This is the same shape `Semantics/PlusLanguage/PlusPasting.lean` has, and for
the same reason; both duals are proved here so that the `paste`/`untl_paste` swap arms of
`starAxiom_swap_validIn_min` have a lemma to land on.

## Why this file lives here rather than under `Semantics/`

It is a consumer of `StarAxiom`'s side conditions and belongs to the axiom-validity layer, which
is this directory. The precedent is `Conservativity/Star/StarAxiomValidity.lean`, which declares
`starTruth_iff_iff` for the same reason: every consumer is here.

## References

* `FormalSystem/Semantics/PlusLanguage/PlusPasting.lean` — the pasting construction reused read-only, and the
  L⁺ congruences mirrored here
* `FormalSystem/StarLanguage/Formula.lean` — `StarIsPureFuture`, `StarIsPurePast`
* JPL paper `possible_worlds.tex` — `def:BLstar-semantics`

## Tags

pasting · star-language · purity · axiom-validity
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.StarLanguage
open FormalSystem.Semantics

variable {F : TaskFrame}

/-- **A pure-future L⋆ formula sees only the history from `t` onward** — at every register
vector. The L⋆ counterpart of `Semantics.truth_congr_agreeFrom`, with the vector universally
quantified inside the motive so the `timeStore` case can recurse at `Function.update v i t`.

Paper: `def:BLstar-semantics` -/
theorem star_truth_congr_agreeFrom (M : TaskModel F) {φ : StarFormula}
    (hφ : StarIsPureFuture φ) :
    ∀ (τ σ : ConvexHistory F), τ.IsTotal → σ.IsTotal → ∀ t, AgreeFrom τ σ t →
      ∀ v : ℕ → F.Duration, (StarTruthAt M τ t v φ ↔ StarTruthAt M σ t v φ) := by
  induction hφ with
  | atom p =>
    intro τ σ hτ hσ t hag v
    constructor
    · rintro ⟨h1, hv⟩; exact ⟨hσ t, by rw [← hag t le_rfl h1 (hσ t)]; exact hv⟩
    · rintro ⟨h2, hv⟩; exact ⟨hτ t, by rw [hag t le_rfl (hτ t) h2]; exact hv⟩
  | bot => intros; exact Iff.rfl
  | imp _ _ ihφ ihψ =>
    intro τ σ hτ hσ t hag v
    exact Iff.imp (ihφ τ σ hτ hσ t hag v) (ihψ τ σ hτ hσ t hag v)
  | box φ => intros; exact Iff.rfl
  | stab φ =>
    intro τ σ hτ hσ t hag v
    exact forall_congr' fun ρ => imp_congr_right fun _ =>
      imp_congr_left (sameStateAt_congr_left (hτ t) (hσ t) (hag t le_rfl _ _))
  | untl _ _ ihψ ihφ =>
    intro τ σ hτ hσ t hag v
    exact exists_congr fun s => and_congr_right fun hts =>
      and_congr (ihφ τ σ hτ hσ s (agreeFrom_mono hts.le hag) v)
        (forall_congr' fun r => imp_congr_right fun htr => imp_congr_right fun _ =>
          ihψ τ σ hτ hσ r (agreeFrom_mono htr.le hag) v)
  | timeStore i _ ih =>
    intro τ σ hτ hσ t hag v
    exact ih τ σ hτ hσ t hag (Function.update v i t)

/-- **A pure-past L⋆ formula sees only the history up to `t`** — the temporal mirror of
`star_truth_congr_agreeFrom`.

Paper: `def:BLstar-semantics` -/
theorem star_truth_congr_agreeUpTo (M : TaskModel F) {φ : StarFormula}
    (hφ : StarIsPurePast φ) :
    ∀ (τ σ : ConvexHistory F), τ.IsTotal → σ.IsTotal → ∀ t, AgreeUpTo τ σ t →
      ∀ v : ℕ → F.Duration, (StarTruthAt M τ t v φ ↔ StarTruthAt M σ t v φ) := by
  induction hφ with
  | atom p =>
    intro τ σ hτ hσ t hag v
    constructor
    · rintro ⟨h1, hv⟩; exact ⟨hσ t, by rw [← hag t le_rfl h1 (hσ t)]; exact hv⟩
    · rintro ⟨h2, hv⟩; exact ⟨hτ t, by rw [hag t le_rfl (hτ t) h2]; exact hv⟩
  | bot => intros; exact Iff.rfl
  | imp _ _ ihφ ihψ =>
    intro τ σ hτ hσ t hag v
    exact Iff.imp (ihφ τ σ hτ hσ t hag v) (ihψ τ σ hτ hσ t hag v)
  | box φ => intros; exact Iff.rfl
  | stab φ =>
    intro τ σ hτ hσ t hag v
    exact forall_congr' fun ρ => imp_congr_right fun _ =>
      imp_congr_left (sameStateAt_congr_left (hτ t) (hσ t) (hag t le_rfl _ _))
  | snce _ _ ihψ ihφ =>
    intro τ σ hτ hσ t hag v
    exact exists_congr fun s => and_congr_right fun hst =>
      and_congr (ihφ τ σ hτ hσ s (agreeUpTo_mono hst.le hag) v)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun hrt =>
          ihψ τ σ hτ hσ r (agreeUpTo_mono hrt.le hag) v)
  | timeStore i _ ih =>
    intro τ σ hτ hσ t hag v
    exact ih τ σ hτ hσ t hag (Function.update v i t)

/-- **PS (same-time pasting) over `StarFormula`**: `⟐φ⁺ → (⟐ψ⁻ → ⟐(φ⁺ ∧ ψ⁻))` at every point,
for pure-future `φ⁺` and pure-past `ψ⁻`. The L⋆ counterpart of `Semantics.paste_valid`, and the
semantic content of `StarAxiom.paste`.

Paper: `possible_worlds.tex`, the PS schema -/
theorem star_paste_valid (M : TaskModel F) (τ : ConvexHistory F) (hτ : τ.IsTotal)
    (t : F.Duration) (v : ℕ → F.Duration) {φ ψ : StarFormula}
    (hφ : StarIsPureFuture φ) (hψ : StarIsPurePast ψ) :
    StarTruthAt M τ t v
      (.imp (StarFormula.dstab φ)
        (.imp (StarFormula.dstab ψ) (StarFormula.dstab (φ.and ψ)))) := by
  intro h1 h2
  rw [StarTruth.dstab_iff] at h1 h2 ⊢
  obtain ⟨σ, hσ, hτσ, hφσ⟩ := h1
  obtain ⟨ρ, hρ, hτρ, hψρ⟩ := h2
  have hsame : SameStateAt ρ σ t := fun a b => (hτρ (hτ t) a).symm.trans (hτσ (hτ t) b)
  refine ⟨paste ρ σ hρ hσ t hsame, paste_isTotal ρ σ hρ hσ t hsame, ?_, ?_⟩
  · intro a b
    rw [hτρ a (hρ t)]
    exact (paste_agreeUpTo ρ σ hρ hσ t hsame t le_rfl b (hρ t)).symm
  · rw [StarTruth.and_iff]
    exact ⟨(star_truth_congr_agreeFrom M hφ _ _ (paste_isTotal ρ σ hρ hσ t hsame) hσ t
              (paste_agreeFrom ρ σ hρ hσ t hsame) v).mpr hφσ,
           (star_truth_congr_agreeUpTo M hψ _ _ (paste_isTotal ρ σ hρ hσ t hsame) hρ t
              (paste_agreeUpTo ρ σ hρ hσ t hsame) v).mpr hψρ⟩

/-- **US (future pasting) over `StarFormula`**: `(α⁻ U ⟐φ⁺) → ⟐(α⁻ U φ⁺)` at every point, for
pure-past `α⁻` and pure-future `φ⁺`. The L⋆ counterpart of `Semantics.untl_dstab_valid`, and the
semantic content of `StarAxiom.untl_paste`.

Paper: `possible_worlds.tex`, the US schema -/
theorem star_untl_paste_valid (M : TaskModel F) (τ : ConvexHistory F) (hτ : τ.IsTotal)
    (t : F.Duration) (v : ℕ → F.Duration) {α φ : StarFormula}
    (hα : StarIsPurePast α) (hφ : StarIsPureFuture φ) :
    StarTruthAt M τ t v
      (.imp (.untl α (StarFormula.dstab φ)) (StarFormula.dstab (.untl α φ))) := by
  intro h
  rw [StarTruth.untl_iff] at h
  obtain ⟨y, hty, hy, hguard⟩ := h
  rw [StarTruth.dstab_iff] at hy
  obtain ⟨ρ, hρ, hτρ, hφρ⟩ := hy
  rw [StarTruth.dstab_iff]
  refine ⟨paste τ ρ hτ hρ y hτρ, paste_isTotal τ ρ hτ hρ y hτρ,
    fun a b => (paste_agreeUpTo τ ρ hτ hρ y hτρ t hty.le b a).symm, ?_⟩
  rw [StarTruth.untl_iff]
  refine ⟨y, hty, (star_truth_congr_agreeFrom M hφ _ _ (paste_isTotal τ ρ hτ hρ y hτρ) hρ y
    (paste_agreeFrom τ ρ hτ hρ y hτρ) v).mpr hφρ, ?_⟩
  intro r htr hry
  exact (star_truth_congr_agreeUpTo M hα _ τ (paste_isTotal τ ρ hτ hρ y hτρ) hτ r
    (agreeUpTo_mono hry.le (paste_agreeUpTo τ ρ hτ hρ y hτρ)) v).mpr (hguard r htr hry)

/-- **PS with the conjuncts exchanged** over `StarFormula`: `⟐ψ⁻ → (⟐φ⁺ → ⟐(ψ⁻ ∧ φ⁺))` for
pure-past `ψ⁻` and pure-future `φ⁺`. This is the temporal dual of `star_paste_valid` — the
`swapTemporal` instance of the `paste` schema — proved by the same pasting argument with the two
congruences applied in the other order. The L⁺ counterpart is `Semantics.paste_valid'`.

Paper: `possible_worlds.tex`, the PS schema -/
theorem star_paste_valid' (M : TaskModel F) (τ : ConvexHistory F) (hτ : τ.IsTotal)
    (t : F.Duration) (v : ℕ → F.Duration) {ψ φ : StarFormula}
    (hψ : StarIsPurePast ψ) (hφ : StarIsPureFuture φ) :
    StarTruthAt M τ t v
      (.imp (StarFormula.dstab ψ)
        (.imp (StarFormula.dstab φ) (StarFormula.dstab (ψ.and φ)))) := by
  intro h2 h1
  rw [StarTruth.dstab_iff] at h1 h2 ⊢
  obtain ⟨σ, hσ, hτσ, hφσ⟩ := h1
  obtain ⟨ρ, hρ, hτρ, hψρ⟩ := h2
  have hsame : SameStateAt ρ σ t := fun a b => (hτρ (hτ t) a).symm.trans (hτσ (hτ t) b)
  refine ⟨paste ρ σ hρ hσ t hsame, paste_isTotal ρ σ hρ hσ t hsame, ?_, ?_⟩
  · intro a b
    rw [hτρ a (hρ t)]
    exact (paste_agreeUpTo ρ σ hρ hσ t hsame t le_rfl b (hρ t)).symm
  · rw [StarTruth.and_iff]
    exact ⟨(star_truth_congr_agreeUpTo M hψ _ _ (paste_isTotal ρ σ hρ hσ t hsame) hρ t
              (paste_agreeUpTo ρ σ hρ hσ t hsame) v).mpr hψρ,
           (star_truth_congr_agreeFrom M hφ _ _ (paste_isTotal ρ σ hρ hσ t hsame) hσ t
              (paste_agreeFrom ρ σ hρ hσ t hsame) v).mpr hφσ⟩

/-- **SS (past pasting) over `StarFormula`**: `(α⁺ S ⟐φ⁻) → ⟐(α⁺ S φ⁻)` for pure-future `α⁺` and
pure-past `φ⁻` — the `snce` mirror of US, and the temporal dual of the `untl_paste` schema. The
witness `ρ` at a past time `y < t` is pasted up to `y` with `τ` after `y`. The L⁺ counterpart is
`Semantics.snce_dstab_valid`.

Paper: `possible_worlds.tex`, the US schema (past mirror) -/
theorem star_snce_paste_valid (M : TaskModel F) (τ : ConvexHistory F) (hτ : τ.IsTotal)
    (t : F.Duration) (v : ℕ → F.Duration) {α φ : StarFormula}
    (hα : StarIsPureFuture α) (hφ : StarIsPurePast φ) :
    StarTruthAt M τ t v
      (.imp (.snce α (StarFormula.dstab φ)) (StarFormula.dstab (.snce α φ))) := by
  intro h
  rw [StarTruth.snce_iff] at h
  obtain ⟨y, hyt, hy, hguard⟩ := h
  rw [StarTruth.dstab_iff] at hy
  obtain ⟨ρ, hρ, hτρ, hφρ⟩ := hy
  have hsame : SameStateAt ρ τ y := hτρ.symm
  rw [StarTruth.dstab_iff]
  refine ⟨paste ρ τ hρ hτ y hsame, paste_isTotal ρ τ hρ hτ y hsame,
    fun a b => (paste_agreeFrom ρ τ hρ hτ y hsame t hyt.le b a).symm, ?_⟩
  rw [StarTruth.snce_iff]
  refine ⟨y, hyt, (star_truth_congr_agreeUpTo M hφ _ _ (paste_isTotal ρ τ hρ hτ y hsame) hρ y
    (paste_agreeUpTo ρ τ hρ hτ y hsame) v).mpr hφρ, ?_⟩
  intro r hyr hrt
  exact (star_truth_congr_agreeFrom M hα _ τ (paste_isTotal ρ τ hρ hτ y hsame) hτ r
    (agreeFrom_mono hyr.le (paste_agreeFrom ρ τ hρ hτ y hsame)) v).mpr (hguard r hyr hrt)

end FormalSystem.Metalogic.Conservativity
