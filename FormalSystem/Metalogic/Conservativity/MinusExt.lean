/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Fragment

/-!
# `MinusExt` — TM⁻ plus a schema set, as a theorems-only closure

**Read `Metalogic/Conservativity.lean`'s module docstring first.** Nothing here states,
approaches, or `sorry`s forward conservativity (`Forward fc`) or TM⁻-completeness
(`TMMinusComplete fc`). This module is the *soundness engine* for the native axiomatization
question answered in `Conservativity/FragmentAxiomatization.lean`: given a set `Ax` of L⁻
formulas (the instances of some candidate schemata), what does TM⁻ at `fc` plus `Ax` prove, and
is all of it inside the H/G-fragment `TMFrag fc`?

## What `MinusExt fc Ax` is

`MinusExt fc Ax φ` holds iff `φ` is in the closure of

* every TM⁻ theorem at `fc` (`MinusLanguage.Derivable fc [] φ`), and
* every member of `Ax`,

under the four rules TM⁻ applies to *theorems*: **MP**, **MN** (`□`), **TN** (`G`) and **TR**
(`MinusFormula.reflectTime`). It is **theorems-only**: there is no context parameter, because
TM⁻'s MN/TN/TR are themselves empty-context rules, and the only question this closure serves
is which *theorems* a schema set adds.

It is **`Prop`-valued**, unlike `MinusLanguage.DerivationTree` (`Type`-valued). The L⁻
derivation tree has to be data because `Conservativity.translate` pattern-matches it into an L
derivation tree; nothing pattern-matches `MinusExt` into a `Type`, and every consumer here
(`minusExt_le_tmFrag`, the Σ-rows, the conditional completeness theorem) lands in `Prop`.

## Main Results

- `minusExt_of_derivable` — `TM⁻ ⊆ MinusExt fc Ax` (the `tm` constructor as a theorem)
- `minusExt_mono` — monotone in `Ax`
- `minusExt_empty_iff` — `MinusExt fc ∅` is exactly TM⁻ at `fc`
- `tmFrag_mp`, `tmFrag_mn`, `tmFrag_tn`, `tmFrag_reflectTime` — `TMFrag fc` is closed under the
  four rules, each a one-liner on the TM side because `tr` commutes with `imp`/`box`/`allFuture`
  definitionally and with `reflectTime` by `MinusLanguage.tr_reflectTime`
- `minusExt_le_tmFrag` — **the engine**: `Ax ⊆ TMFrag fc → MinusExt fc Ax ⊆ TMFrag fc`

## References

* `FormalSystem/Metalogic/Conservativity/Fragment.lean` — `TMFrag`, `tmMinus_le_tmFrag`
* `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean` — the consumer: Σ_fc,
  the four soundness rows, and conditional completeness
* `FormalSystem/MinusLanguage/Translation.lean` — `tr_reflectTime`

## Tags

conservativity · fragment · base-language · axiomatization · soundness
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.MinusLanguage
open FormalSystem.Metalogic

/--
**TM⁻ at `fc` plus the schema-instance set `Ax`, closed under MP, MN, TN, TR.**

The two base cases are `tm` (a TM⁻ theorem at `fc`) and `ax` (a member of `Ax`); the four rules
are TM⁻'s own theorem-level rules. No context: see the module docstring.
-/
inductive MinusExt (fc : FrameClass) (Ax : Set MinusFormula) : MinusFormula → Prop where
  /-- Every TM⁻ theorem at `fc` is in the extension. -/
  | tm {φ : MinusFormula} (h : MinusLanguage.Derivable fc [] φ) : MinusExt fc Ax φ
  /-- Every member of `Ax` is in the extension. -/
  | ax {φ : MinusFormula} (h : φ ∈ Ax) : MinusExt fc Ax φ
  /-- **MP**. -/
  | mp {φ ψ : MinusFormula} (h₁ : MinusExt fc Ax (φ.imp ψ)) (h₂ : MinusExt fc Ax φ) :
      MinusExt fc Ax ψ
  /-- **MN**: closure under `□`. -/
  | mn {φ : MinusFormula} (h : MinusExt fc Ax φ) : MinusExt fc Ax φ.box
  /-- **TN**: closure under `G`. -/
  | tn {φ : MinusFormula} (h : MinusExt fc Ax φ) : MinusExt fc Ax φ.allFuture
  /-- **TR**: closure under `MinusFormula.reflectTime`. -/
  | tr {φ : MinusFormula} (h : MinusExt fc Ax φ) : MinusExt fc Ax φ.reflectTime

/-- `TM⁻ ⊆ MinusExt fc Ax`: the `tm` constructor, exported as a theorem. -/
theorem minusExt_of_derivable {fc : FrameClass} {Ax : Set MinusFormula} {φ : MinusFormula}
    (h : MinusLanguage.Derivable fc [] φ) : MinusExt fc Ax φ :=
  MinusExt.tm h

/-- `MinusExt fc` is monotone in the schema set. -/
theorem minusExt_mono {fc : FrameClass} {Ax₁ Ax₂ : Set MinusFormula} (hle : Ax₁ ⊆ Ax₂)
    {φ : MinusFormula} (h : MinusExt fc Ax₁ φ) : MinusExt fc Ax₂ φ := by
  induction h with
  | tm h => exact MinusExt.tm h
  | ax h => exact MinusExt.ax (hle h)
  | mp _ _ ih₁ ih₂ => exact MinusExt.mp ih₁ ih₂
  | mn _ ih => exact MinusExt.mn ih
  | tn _ ih => exact MinusExt.tn ih
  | tr _ ih => exact MinusExt.tr ih

/--
**`MinusExt fc ∅` is exactly TM⁻ at `fc`.** Backward is `tm`; forward is induction, replaying
each rule as the corresponding `MinusLanguage.DerivationTree` constructor on the `Nonempty`
witnesses.
-/
theorem minusExt_empty_iff {fc : FrameClass} {φ : MinusFormula} :
    MinusExt fc ∅ φ ↔ MinusLanguage.Derivable fc [] φ := by
  constructor
  · intro h
    induction h with
    | tm h => exact h
    | ax h => exact absurd h (Set.notMem_empty _)
    | mp _ _ ih₁ ih₂ =>
        exact ih₁.elim fun d₁ => ih₂.elim fun d₂ => ⟨.modus_ponens [] _ _ d₁ d₂⟩
    | mn _ ih => exact ih.elim fun d => ⟨.necessitation _ d⟩
    | tn _ ih => exact ih.elim fun d => ⟨.temporal_necessitation _ d⟩
    | tr _ ih => exact ih.elim fun d => ⟨.time_reflection _ d⟩
  · exact MinusExt.tm

/-! ### `TMFrag fc` is closed under the four rules

Each is one TM-side rule application. `tr_imp`, `tr_box`, `tr_allFuture` are `rfl`, so the
first three need no rewriting; `tmFrag_reflectTime` transports along `tr_reflectTime`, exactly as
`translate`'s `time_reflection` case does in `Conservativity/Backward.lean`. -/

/-- `TMFrag fc` is closed under **MP**. -/
theorem tmFrag_mp {fc : FrameClass} {φ ψ : MinusFormula} (h₁ : TMFrag fc (φ.imp ψ))
    (h₂ : TMFrag fc φ) : TMFrag fc ψ :=
  h₁.elim fun d₁ => h₂.elim fun d₂ => ⟨.modus_ponens [] (tr φ) (tr ψ) d₁ d₂⟩

/-- `TMFrag fc` is closed under **MN**. -/
theorem tmFrag_mn {fc : FrameClass} {φ : MinusFormula} (h : TMFrag fc φ) : TMFrag fc φ.box :=
  h.elim fun d => ⟨.necessitation (tr φ) d⟩

/-- `TMFrag fc` is closed under **TN**. -/
theorem tmFrag_tn {fc : FrameClass} {φ : MinusFormula} (h : TMFrag fc φ) :
    TMFrag fc φ.allFuture :=
  h.elim fun d => ⟨.temporal_necessitation (tr φ) d⟩

/-- `TMFrag fc` is closed under **TR**, transported along `MinusLanguage.tr_reflectTime`. -/
theorem tmFrag_reflectTime {fc : FrameClass} {φ : MinusFormula} (h : TMFrag fc φ) :
    TMFrag fc φ.reflectTime := by
  unfold TMFrag
  rw [MinusLanguage.tr_reflectTime]
  exact h.elim fun d => ⟨.time_reflection (tr φ) d⟩

/--
**The soundness engine.** If every member of `Ax` is in the fragment at `fc`, then everything
TM⁻ + `Ax` proves at `fc` is in the fragment at `fc`: `tm` is `tmMinus_le_tmFrag`, `ax` is the
hypothesis, and the four rules are the four closure lemmas above.

This is the half of "TM⁻ + Σ_fc = TMFrag fc" that is machine-checked unconditionally at every
class; the other half lives behind the explicit `ChainComplete` hypothesis in
`Conservativity/FragmentAxiomatization.lean`, discharged at `.Dense` only by
`Conservativity/MinusChainCompleteness.lean`.

Paper: — (formalization-native; the H/G-fragment is this tree's construction)
-/
theorem minusExt_le_tmFrag {fc : FrameClass} {Ax : Set MinusFormula}
    (hAx : ∀ ψ ∈ Ax, TMFrag fc ψ) {φ : MinusFormula} (h : MinusExt fc Ax φ) :
    TMFrag fc φ := by
  induction h with
  | tm h => exact tmMinus_le_tmFrag _ h
  | ax h => exact hAx _ h
  | mp _ _ ih₁ ih₂ => exact tmFrag_mp ih₁ ih₂
  | mn _ ih => exact tmFrag_mn ih
  | tn _ ih => exact tmFrag_tn ih
  | tr _ ih => exact tmFrag_reflectTime ih

/-! ### Acceptance checks -/

/-- With the empty schema set, the engine's hypothesis is vacuous. -/
example {fc : FrameClass} {φ : MinusFormula} (h : MinusExt fc ∅ φ) : TMFrag fc φ :=
  minusExt_le_tmFrag (fun _ hψ => absurd hψ (Set.notMem_empty _)) h

/-- The same instance, through `minusExt_empty_iff` and `tmMinus_le_tmFrag`. -/
example {fc : FrameClass} {φ : MinusFormula} (h : MinusExt fc ∅ φ) : TMFrag fc φ :=
  tmMinus_le_tmFrag _ (minusExt_empty_iff.mp h)

end FormalSystem.Metalogic.Conservativity
