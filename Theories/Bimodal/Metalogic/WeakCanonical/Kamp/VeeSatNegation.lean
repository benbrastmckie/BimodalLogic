/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.Kamp.EFSatNegationGeneral

/-!
# γ — Negation closure of ∨∃∀-formulas (Rabinovich Prop 4.3 ¬-case, PDF p.6)

The **negation** half of Proposition 4.3's disjunction sub-case: the negation of a `∨∃∀`-formula
is again a `∨∃∀`-formula. Faithful to Prop 4.3's disjunction-negation reading (p.6):
`¬ veeSat (⋁ᵢ φᵢ) = ⋀ᵢ ¬φᵢ`, each `¬φᵢ` re-expressed as a `∨∃∀` by the landed β
(`efSat_negation_generalFin`, `EFSatNegationGeneral.lean`), the conjunction reassembled by the
landed `veeConjFin_iff` (`VeeConj.lean`, Rabinovich Lemma 3.4 ∧-part). (The total-type twins
`veeSat_cons` / `efArb` / `efArb_pin_strictMono` / `veeSat_negation` were DELETED at the
switchover; the Fin layer below is the sole carrier.)

## Structure

`veeSat_negationFin` is proved by induction on the disjunct list `Φ`:

- **`nil`** (`Φ = []`): `¬ veeSat N env [] = True`, so `Φ'` must be a **tautological** `∨∃∀`.
  It is built as `Gd ++ [d]` for an arbitrary `d : ExistsForallFormula sig F r`, where `Gd` is
  the β-negation of `d`: `veeSat (Gd ++ [d]) ↔ (¬ efSat d) ∨ efSat d ↔ True` (excluded middle).
  This reuses β rather than constructing a bespoke top, so the empty case needs no `Fintype`
  disjunction over point-type assignments.
- **`cons ψ rest`**: `¬ veeSat (ψ :: rest) = (¬ efSat ψ) ∧ (¬ veeSat rest)`; apply β to `ψ`
  (`veeSat Gψ`) and the induction hypothesis to `rest` (`veeSat Φrest`), then reassemble the
  conjunction as `veeConj Gψ Φrest` via `veeConj_iff`.

## Threaded hypotheses (never discharged — CONDITIONAL orphan until ζ)

`veeSat_negationFin` carries the same `N / atomMap / nameOf / hName / h_INF / h_SUP / hNamed / hne`
hypotheses β threads. `hNamed` (atom-naming) and `hne : Nonempty N.carrier` are
**threaded, never discharged** — their discharge is the Phase-ζ concern (the E[Σ] output-alphabet
capture/closure of `ESigmaCapture.lean`, applied against a closed-`F` `canonExpand`). This module
stays OFF the live import path.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Proposition 4.3 (p.6), Lemma 3.4 (p.5). Cited by
  PDF page; the companion markdown transcription is corrupt.
- `EFSatNegationGeneral.lean`: `efSat_negation_generalFin` (β at the `∨∃∀` type).
- `VeeConj.lean`: `veeConjFin`, `veeConjFin_iff` (Lemma 3.4, ∧-part).
- `VeeExistsForall.lean`: `VeeExistsForall`, `veeSatFin`, `veeSat_nil`.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}

/-! ## 4. Fin layer: negation closure on the per-formula representation

Fin counterparts of sections 1-3 on `VeeExistsForallFin`/`veeSatFin`
(`ExistsForallLemmas.lean` Fin section): the β-negation is `efSat_negation_generalFin`
(`EFSatNegationGeneral.lean` §8, `M`-relative capture), the conjunction reassembly is
`veeConjFin_iff` (`ConjInterleave.lean` §10). The nil-case witness `efArbFin` bundles the empty
mentioned set `M = ∅` (its semantics are never inspected — only excluded middle on
`efSatFin N env efArbFin` is used). NO alphabet instances. -/

section FinLayer

variable {sig₀ : MonadicSignature} {F₀ : Finset Formula}

/-- Fin-variant of `veeSat_nil`: the empty per-formula disjunction is never satisfied. -/
@[simp] theorem veeSatFin_nil {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (env : Fin r → N.carrier) :
    ¬ veeSatFin N env ([] : VeeExistsForallFin sig₀ F₀ r) := by
  rintro ⟨ψ, hmem, _⟩
  exact (List.not_mem_nil hmem)

/-- Fin-variant of `veeSat_cons`: a per-formula `∨∃∀`-formula `ψ :: Ψ` is satisfied iff its head
is or its tail is. -/
theorem veeSatFin_cons {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (env : Fin r → N.carrier) (ψ : ExistsForallFormulaFin sig₀ F₀ r)
    (Ψ : VeeExistsForallFin sig₀ F₀ r) :
    veeSatFin N env (ψ :: Ψ) ↔ efSatFin N env ψ ∨ veeSatFin N env Ψ := by
  simp only [veeSatFin, List.mem_cons]
  constructor
  · rintro ⟨φ, (rfl | hmem), hsat⟩
    · exact Or.inl hsat
    · exact Or.inr ⟨φ, hmem, hsat⟩
  · rintro (h | ⟨φ, hmem, hsat⟩)
    · exact ⟨ψ, Or.inl rfl, h⟩
    · exact ⟨φ, Or.inr hmem, hsat⟩

/-- Fin-variant of `efArb`: an arbitrary per-formula `∃∀`-formula over the EMPTY mentioned set
`M = ∅`, used only as the nil-case witness of `veeSat_negationFin` (semantics never inspected).
`r+1` ordered points, everywhere-trivial partial point type (vacuous over `∅`), trivial
`intervalTopFin ∅` caps, and the strictly monotone pin `Fin.castSucc`. -/
noncomputable def efArbFin (sig₀ : MonadicSignature) (F₀ : Finset Formula) (r : Nat) :
    ExistsForallFormulaFin sig₀ F₀ r where
  n := r
  M := ∅
  pin := Fin.castSucc
  pointType := fun _ => (fun _ => false)
  intervalType := fun _ => intervalTopFin ∅

/-- The Fin nil-case witness `efArbFin` has a strictly monotone pin (`Fin.castSucc`). -/
theorem efArbFin_pin_strictMono (sig₀ : MonadicSignature) (F₀ : Finset Formula) (r : Nat) :
    StrictMono (efArbFin sig₀ F₀ r).pin := by
  intro a b hab
  exact Fin.castSucc_lt_castSucc_iff.mpr hab

/-- **Fin-variant of `veeSat_negation` (Rabinovich Prop 4.3 ¬-case, p.6).** The negation of a
per-formula `∨∃∀`-formula `Φ` is again a per-formula `∨∃∀`-formula `Φ'`, uniformly in the
(strictly monotone) environment. Faithful to `¬ (⋁ᵢ φᵢ) = ⋀ᵢ ¬φᵢ`: each `¬φᵢ` is the β-negation
`efSat_negation_generalFin`, and the conjunction is reassembled by `veeConjFin_iff`. Threads the
atom-naming premise (capture discharged directly: every readback IS an atom) and `hne`. -/
theorem veeSat_negationFin
    (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (atomMap : Formula → (sigE sig₀ F₀).preds)
    (nameOf : (sigE sig₀ F₀).preds → Formula)
    (hName : ∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (hNamed : ∀ (A : Formula) (y : N.carrier),
        N.interp (esigmaPred (F := F₀) A) y ↔ temporal_truth N atomMap y A)
    (hne : Nonempty N.carrier)
    {r : Nat} (Φ : VeeExistsForallFin sig₀ F₀ r) :
    ∃ Φ' : VeeExistsForallFin sig₀ F₀ r, (∀ ψ ∈ Φ', StrictMono ψ.pin) ∧
      ∀ env : Fin r → N.carrier, StrictMono env →
      (¬ veeSatFin N env Φ ↔ veeSatFin N env Φ') := by
  classical
  induction Φ with
  | nil =>
    -- `¬ veeSatFin [] = True`; the tautological `Φ'` is `Gd ++ [d]` (β-negation of `d`, then `d`).
    obtain ⟨Gd, hGdmono, hGd⟩ :=
      efSat_negation_generalFin N atomMap nameOf hName h_INF h_SUP hNamed hne (efArbFin sig₀ F₀ r)
    refine ⟨Gd ++ [efArbFin sig₀ F₀ r], ?_, fun env hmono => ?_⟩
    · -- Pin-mono: `Gd` disjuncts from β (`hGdmono`); `efArbFin` by construction.
      intro φ hφ
      rw [List.mem_append] at hφ
      rcases hφ with hφ | hφ
      · exact hGdmono φ hφ
      · rw [List.mem_singleton] at hφ
        subst hφ
        exact efArbFin_pin_strictMono sig₀ F₀ r
    · constructor
      · intro _
        rw [veeSatFin_append]
        by_cases hd : efSatFin N env (efArbFin sig₀ F₀ r)
        · exact Or.inr ⟨efArbFin sig₀ F₀ r, by simp, hd⟩
        · exact Or.inl ((hGd env hmono).mp hd)
      · intro _
        exact veeSatFin_nil N env
  | cons ψ rest ih =>
    -- `¬ veeSatFin (ψ :: rest) = (¬ efSatFin ψ) ∧ (¬ veeSatFin rest)`; β on `ψ`, IH on `rest`.
    obtain ⟨Gψ, hGψmono, hGψ⟩ :=
      efSat_negation_generalFin N atomMap nameOf hName h_INF h_SUP hNamed hne ψ
    obtain ⟨Φrest, hrestmono, hrest⟩ := ih
    refine ⟨veeConjFin Gψ Φrest, ?_, fun env hmono => ?_⟩
    · -- Pin-mono: `veeConjFin Gψ Φrest` pins are merge-lifted from `Gψ`'s, monotone since those
    -- are.
      exact fun χ hχ => veeConjFin_pin_strictMono Gψ Φrest hGψmono χ hχ
    · rw [veeSatFin_cons, not_or, hGψ env hmono, hrest env hmono,
        veeConjFin_iff N env Gψ Φrest]

end FinLayer

end Bimodal.Metalogic.WeakCanonical.Kamp
