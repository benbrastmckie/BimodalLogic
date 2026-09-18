/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Z1Countermodel

/-!
# `TMFrag` — the H/G-fragment of TM, and its metatheory

**Read `Metalogic/Conservativity.lean`'s module docstring first.** Forward proof-theoretic
conservativity of TM over TM⁻ — `Derivable fc [] (tr φ) → MinusLanguage.Derivable fc [] φ` —
is refuted at `.ZTime` (`tmMinusCompleteZTime_refuted`), refuted in the source at `.Base`, and
by `tmMinusComplete_iff_forward` it is *the same proposition* as "TM⁻ is complete over the frames of
`fc`". Nothing in this file states, approaches, or `sorry`s it.

What this file delivers instead is the logic that **is** complete for the base-language
validity `MinusValidIn fc`: the **H/G-fragment of TM**,

```
TMFrag fc φ  :=  TM ⊢[fc] tr φ
```

the set of base-language formulas whose translation is a TM theorem. Its metatheory transfers
mechanically through the landed truth-transfer bridge `minusValidIn_iff_validIn_tr`
(`Conservativity/MinusLanguageSoundness.lean`):

- **soundness** (`tmFrag_sound`) from `soundness_validIn`;
- **completeness** (`tmFrag_complete`) from any `WeakCompleteness fc` engine — instantiated at
  all four classes by `tmFrag_complete_base/dense/discrete/dedekind`;
- **`TM⁻ ⊆ TMFrag`** at every class (`tmMinus_le_tmFrag`, the `Γ = []` instance of
  `derivable_translate`);
- **`TM⁻ ⊊ TMFrag` at `.ZTime`** (`tmMinus_lt_tmFrag_ztime`): the Z1 schema is in the fragment
  (`z1_translate`) but not a TM⁻_z theorem (`not_minus_derivable_z1`);
- the reduction restated in fragment terms (`tmMinusComplete_iff_tmFrag_le_tmMinus`): TM⁻ is
  complete at `fc` iff the fragment collapses onto TM⁻ at `fc` — with `Forward` unfolded, never
  asserted.

Compactness of the fragment at `.Base` and `.Dense` is the sibling module
`Conservativity/FragmentCompactness.lean`.

## Why the fragment, and not a finite axiomatization

`TMFrag` is defined *through* TM; a native finite Hilbert axiomatization of the H/G-fragment of
TM over `MinusFormula` is open research and is not attempted here. What the fragment gives is an
honest, complete logic of `MinusValidIn` at every frame class, which TM⁻ itself is not
(`tmMinusCompleteZTime_refuted`).

## References

* `FormalSystem/Metalogic/Conservativity.lean` — the forward-conservativity prohibition
* `FormalSystem/Metalogic/Conservativity/TMCompletenessReduction.lean` — `TMMinusComplete`,
  `Forward`, `tmMinusComplete_iff_forward`
* `FormalSystem/Metalogic/Conservativity/Z1Countermodel.lean` — `not_minus_derivable_z1`
* `FormalSystem/Metalogic/StrongCompleteness.lean` — the four `WeakCompleteness` engines

## Tags

conservativity · fragment · base-language · completeness · compactness
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.MinusLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic

/--
**The H/G-fragment of TM.** A base-language formula `φ` is a theorem of the fragment at `fc`
iff its translation `tr φ` is a TM theorem at `fc`.

Since `TM` is the paper's `TM` (`def:TMplus`; see `Metalogic/Conservativity.lean` for the
mapping between the two families of system name), this is the set of Past/Future theorems of the
paper's `TM` at `fc` — the `H`/`G`-expressible part of what that system proves. It is **not** a
fragment of any *named* paper system: nothing on the `H`/`G` side of this tree — `TM⁻`, `TM⁻_z`,
`TM⁻_d`, `TM⁻_r` — carries a paper name.

This — not TM⁻ — is the complete logic of `MinusValidIn fc`: by `tmMinusComplete_iff_forward`
(`Conservativity/TMCompletenessReduction.lean`), TM⁻-completeness at `fc` is equivalent to forward
conservativity at `fc`, which is refuted at `.ZTime` (`tmMinusCompleteZTime_refuted`). The
fragment sidesteps that gap by definition: `tmFrag_iff_minusValidIn` below shows it is exactly
`MinusValidIn fc` at every class carrying a `WeakCompleteness fc` engine.
-/
def TMFrag (fc : FrameClass) (φ : MinusFormula) : Prop :=
  ProofSystem.Derivable fc [] (tr φ)

/-- **Soundness of the fragment.** A fragment theorem at `fc` is `MinusValidIn fc`: TM soundness
(`soundness_validIn`) on the translation, crossed back through `minusValidIn_iff_validIn_tr`.

Paper: — (formalization-native; the H/G-fragment is this tree's construction)
-/
theorem tmFrag_sound {fc : FrameClass} (φ : MinusFormula) (h : TMFrag fc φ) : MinusValidIn fc φ :=
  (minusValidIn_iff_validIn_tr fc φ).mpr (h.elim soundness_validIn)

/-- **Completeness of the fragment**, given a weak-completeness engine at `fc`: a `MinusValidIn fc`
formula's translation is `ValidIn fc` (`minusValidIn_iff_validIn_tr`), hence TM-derivable.

Paper: — (formalization-native; the H/G-fragment is this tree's construction)
-/
theorem tmFrag_complete {fc : FrameClass} (engine : WeakCompleteness fc) (φ : MinusFormula)
    (h : MinusValidIn fc φ) : TMFrag fc φ :=
  engine (tr φ) ((minusValidIn_iff_validIn_tr fc φ).mp h)

/-- **The fragment is exactly base-language validity**, at every class with an engine. -/
theorem tmFrag_iff_minusValidIn {fc : FrameClass} (engine : WeakCompleteness fc)
    (φ : MinusFormula) :
    TMFrag fc φ ↔ MinusValidIn fc φ :=
  ⟨tmFrag_sound φ, tmFrag_complete engine φ⟩

/-! ### The four completeness rows

`tmFrag_complete` at the four engines of `Metalogic/StrongCompleteness.lean`. -/

/-- Fragment completeness at `.Base`, via `completeness_base`. -/
theorem tmFrag_complete_base (φ : MinusFormula) (h : MinusValidIn FrameClass.Base φ) :
    TMFrag FrameClass.Base φ :=
  tmFrag_complete completeness_base φ h

/-- Fragment completeness at `.Dense`, via `completeness_dense`. -/
theorem tmFrag_complete_dense (φ : MinusFormula) (h : MinusValidIn FrameClass.Dense φ) :
    TMFrag FrameClass.Dense φ :=
  tmFrag_complete completeness_dense φ h

/-- Fragment completeness at `.ZTime`, via `completeness_ztime`. -/
theorem tmFrag_complete_ztime (φ : MinusFormula) (h : MinusValidIn FrameClass.ZTime φ) :
    TMFrag FrameClass.ZTime φ :=
  tmFrag_complete completeness_ztime φ h

/-- Fragment completeness at `.RTime`, via `completeness_rtime`. -/
theorem tmFrag_complete_rtime (φ : MinusFormula) (h : MinusValidIn FrameClass.RTime φ) :
    TMFrag FrameClass.RTime φ :=
  tmFrag_complete completeness_rtime φ h

/-! ### `TM⁻ ⊆ TMFrag`, and the strict inclusion at `.ZTime` -/

/-- **`TM⁻ ⊆ TMFrag` at every class.** The `Γ = []` instance of `derivable_translate`
(`Conservativity/Backward.lean`); `trCtx [] = []` definitionally, so no context bookkeeping.

Paper: — (formalization-native; the H/G-fragment is this tree's construction)
-/
theorem tmMinus_le_tmFrag {fc : FrameClass} (φ : MinusFormula)
    (h : MinusLanguage.Derivable fc [] φ) : TMFrag fc φ :=
  derivable_translate h

/-- The Z1 schema is in the fragment at `.ZTime`: this is `z1_translate`. -/
theorem tmFrag_z1_ztime (p : Atom) : TMFrag FrameClass.ZTime (Z1 (.atom p)) :=
  z1_translate _

/--
**`TM⁻ ⊊ TMFrag` at `.ZTime`.** Every TM⁻_z theorem is in the fragment, and the fragment
contains a formula — `Z1 p` — that TM⁻_z does not derive (`not_minus_derivable_z1`,
`Conservativity/Z1Countermodel.lean`, by soundness over the non-Archimedean carrier
`ℚ ×ₗ ℤ`).

This is the fragment-logic reading of the CEF refutation: the H/G-fragment of TM_z is
strictly larger than TM⁻_z.

Paper: — (formalization-native; the H/G-fragment is this tree's construction)
-/
theorem tmMinus_lt_tmFrag_ztime :
    (∀ φ : MinusFormula, MinusLanguage.Derivable FrameClass.ZTime [] φ →
        TMFrag FrameClass.ZTime φ) ∧
      ∃ φ : MinusFormula, TMFrag FrameClass.ZTime φ ∧
        ¬ MinusLanguage.Derivable FrameClass.ZTime [] φ :=
  ⟨fun φ h => tmMinus_le_tmFrag φ h,
   ⟨Z1 (.atom (Atom.mkBase "p")), tmFrag_z1_ztime _, not_minus_derivable_z1 _⟩⟩

/--
**The reduction, in fragment terms.** TM⁻ is complete over the frames of `fc` iff the fragment
collapses onto TM⁻ at `fc`. This is `tmMinusComplete_iff_forward` with `Forward fc` unfolded to its
definition — `∀ φ, TMFrag fc φ → MinusLanguage.Derivable fc [] φ` — and, exactly as there,
**neither side is asserted**: at `.ZTime` both are false (`tmMinusCompleteZTime_refuted`,
`tmMinus_lt_tmFrag_ztime`).
-/
theorem tmMinusComplete_iff_tmFrag_le_tmMinus {fc : FrameClass} (engine : WeakCompleteness fc) :
    TMMinusComplete fc ↔ ∀ φ : MinusFormula, TMFrag fc φ → MinusLanguage.Derivable fc [] φ :=
  tmMinusComplete_iff_forward engine

/-! ### Acceptance checks -/

/-- The flagship equivalence typechecks at `.Base` on the nose. -/
example (φ : MinusFormula) : TMFrag FrameClass.Base φ ↔ MinusValidIn FrameClass.Base φ :=
  tmFrag_iff_minusValidIn completeness_base φ

/-- At `.ZTime`, TM⁻-completeness is refuted and the fragment is strictly larger — the two
facts are the two halves of one story. -/
example : ¬ TMMinusComplete FrameClass.ZTime := tmMinusCompleteZTime_refuted (Atom.mkBase "p")

end FormalSystem.Metalogic.Conservativity
