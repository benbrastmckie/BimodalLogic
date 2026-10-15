/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.NomicLanguage.NomicTruth
import FormalSystem.Semantics.Nomic.Uniformity

/-!
# Validity on a nomic frame, and seriality of the nomic operator

`def:frame-validity`, read for the nomic language: a formula is valid on a nomic frame when it is
true at every time along every **nomologically possible** world. `NomicTruthAt` ranges over bare
state functions with no membership proof — that is the recorded consequence of inheriting
`lawHist`'s bare-function presentation — so *validity*, not truth, is where `τ ∈ H_F` enters.

The one schema that needs no frame condition at all is **D**. `nomic_serial` holds over every
nomic frame, independently of `thm:nomic-uniform`'s conditions (1)-(6), because `H_F^{τ(x)}` is
never empty: `lem:nomic-occurrence` at `w = u = τ x` supplies an inhabitant. `◈` is therefore a
normal serial modality on every nomic frame, which is what the paper's closing discussion records.

## The accessibility relation under uniformity

Under `NomicFrame.Uniform` the accessibility relation at every time is `H_F × H_F` and is an
equivalence relation — `NomicFrame.accRel_eq_of_uniform` and
`NomicFrame.accRel_equivalence_of_uniform`, both in
`FormalSystem/Semantics/Nomic/Uniformity.lean`. That is the frame-level reason every **S5** schema
holds for `◈` on the **full** language over a uniform frame, and it is stated there rather than
restated here, since it mentions no formula.

## Main Definitions

- `NomicFrame.NomicValidOn` — validity over a nomic frame

## Main Results

- `nomic_serial` — **D** for the nomic operator, over every nomic frame
- `nomicValidOn_nomic_iff_box_of_uniform` — the uniformity collapse as a pair of validities, the
  validity-level form of `NomicLanguage.nomic_iff_box_of_uniform`. `NomicLanguage/NomicFour.lean`'s
  forward direction is one line on it

## Choice dependence, recorded honestly

`nomic_serial` reaches `NomicFrame.lawHist_nonempty` and so `lem:nomic-occurrence`: a theorem of
**ZFC**, not of ZF, through `thm:extension`'s Zorn appeal. `rmk:choice` does not list it among
the paper's choice-free results. `nomicValidOn_nomic_iff_box_of_uniform`, by contrast, takes no
regularity instance and consumes no constraint.

## References

* JPL paper `def:frame-validity` — validity over a frame
* JPL paper `thm:nomic-uniform`, closing discussion — seriality, and the collapse under uniformity
* `FormalSystem/Semantics/Nomic/Uniformity.lean` — `lawHist_nonempty`, `accRel_eq_of_uniform`
* `FormalSystem/OpenLanguage/OpenValidity.lean` — the semantic-only validity precedent

## Tags

validity · nomic-language · seriality · uniformity
-/

namespace FormalSystem.NomicLanguage

open FormalSystem.Syntax
open FormalSystem.Semantics

end FormalSystem.NomicLanguage

namespace FormalSystem.Semantics

open FormalSystem.NomicLanguage

/--
`def:frame-validity` for the nomic language: `φ` is valid over the nomic frame `F` iff it is true
at every time along every nomologically possible world, under every model over `F`.

**Validity, not truth, is where `τ ∈ H_F` enters** — the recorded consequence of letting
`NomicTruthAt` range over bare state functions.
-/
def NomicFrame.NomicValidOn {D : TemporalOrder} (F : NomicFrame D) (φ : NomicFormula) : Prop :=
  ∀ (M : NomicModel F) (τ : ↑D → F.World), τ ∈ F.HF → ∀ x : ↑D, NomicTruthAt M τ x φ

/--
**D** for the nomic operator, over **every** nomic frame, independently of `thm:nomic-uniform`'s
conditions (1)-(6): `◈φ → ¬◈¬φ`.

The one schema in scope that needs no uniformity hypothesis at all. Its whole content is that
`H_F^{τ(x)}` is nonempty, which is `NomicFrame.lawHist_nonempty`, whose witness comes from
`lem:nomic-occurrence` at `w = u = τ x`.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`; see
this module's docstring.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem nomic_serial {D : TemporalOrder} (F : NomicFrame D) [F.IsRegular] (φ : NomicFormula) :
    F.NomicValidOn (.imp (.nomic φ) (.imp (.nomic (.imp φ .bot)) .bot)) := by
  intro M τ _ x hnom hneg
  obtain ⟨σ, hσ⟩ := F.lawHist_nonempty (τ x) x
  exact hneg σ hσ (hnom σ hσ)

/--
The uniformity collapse as a pair of validities: over a uniform nomic frame, `◈φ → □φ` and
`□φ → ◈φ` are both valid, for every formula.

The validity-level form of `NomicLanguage.nomic_iff_box_of_uniform`, which does the work; this
adds only the validity binders. `NomicLanguage/NomicFour.lean`'s `(⇐)` direction is one line on
it.

**Choice-free**: it takes no regularity instance and consumes no constraint.
-/
theorem nomicValidOn_nomic_iff_box_of_uniform {D : TemporalOrder} (F : NomicFrame D)
    (h : F.Uniform) (φ : NomicFormula) :
    F.NomicValidOn (.imp (.nomic φ) (.box φ)) ∧ F.NomicValidOn (.imp (.box φ) (.nomic φ)) :=
  ⟨fun M τ _ x => (nomic_iff_box_of_uniform h M τ x φ).mp,
    fun M τ _ x => (nomic_iff_box_of_uniform h M τ x φ).mpr⟩

end FormalSystem.Semantics
