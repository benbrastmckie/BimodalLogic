/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.Conservativity
import FormalSystem.Semantics.BLValidity

/-!
# Soundness for the base language BL, by composition

`TM ⊢ φ  ⟹  BL-validity of φ`, at `FrameClass.Base` and at each of the three extensions, obtained
by composing two things this repository already has:

```
⊢ᴮᴸ[fc] φ  ──[Conservativity.translate]──▸  ⊢[fc] tr φ  ──[soundness…]──▸  M,τ,x ⊨ tr φ
                                                                              ‖ truthAt_tr
                                                                          M,τ,x ⊨ᴮᴸ φ
```

The right-hand equality is the **truth-transfer bridge** `truthAt_tr`, proved here by induction on
`BLFormula`. It is a theorem, not a definition: `BLTruthAt` is defined natively on `BLFormula`
(`Semantics/BLTruth.lean`), so the bridge has to be earned. Four of its six cases are `Iff.rfl` or
congruence; the `allPast` and `allFuture` cases are the two with content, and both are discharged
by the existing `@[simp]` characterizations `Truth.past_iff` and `Truth.future_iff`, which unfold
BL⁺'s `untl`/`snce`-derived `H`/`G` abbreviations to exactly the quantifications `BLTruthAt`
states directly.

## What composition certifies, and what it does not

These theorems inherit per-axiom validity from `Metalogic/Soundness.lean`'s BL⁺ validity lemmas
together with `BaseLanguage/AxiomDischarge.lean`'s discharge table. That is mathematically
complete — every BL axiom's translation is a BL⁺ theorem, and every BL⁺ theorem is valid — but it
does mean **no BL axiom is ever evaluated directly against `BLTruthAt` by the composition
itself**. The three native `example`s at the end of this module are the standing evidence that
`BLTruthAt` carries real content independently of the composition: each proves a BL axiom scheme
valid by unfolding `BLTruthAt`'s clauses and nothing else.

`Conservativity.translate` is `noncomputable`, but it occurs only inside proof terms of
`Prop`-valued theorems, so it contributes nothing to the axiom profile; every result below sits at
`[propext, Classical.choice, Quot.sound]`.

## The Dedekind target

`bl_soundness_dedekind` concludes at `BLValidDedekindDense`, **not** at a density-free
`BLValidDedekind` — which is deliberately not defined. `Semantics/BLValidity.lean`'s module
docstring gives the BL-native refutation: `Axiom.dn` is admissible at `FrameClass.Dedekind` and is
false on `ℤ`, which satisfies every remaining binder. This mirrors `soundness_dedekind`'s own
target on the BL⁺ side.

## Why there is no dense or Dedekind consistency corollary

Consistency is a per-frame-class fact read off a soundness theorem together with a *witness
frame* for that class. The tree carries `trivialFrame` over `Int`, which serves `FrameClass.Base`
and `FrameClass.Discrete`; it carries no dense or Dedekind-complete witness frame. The BL⁺ side
records the same asymmetry in `Metalogic/Soundness.lean`'s docstring for `not_derivable_nil_bot`
("there is no `{fc}`-uniform statement, because `Dense` and `Dedekind` have no corresponding
consistency lemma in the tree yet"), and the BL side inherits it exactly.

## Main Results

- `truthAt_tr` — the bridge: `TruthAt M τ t (tr φ) ↔ BLTruthAt M τ t φ`
- `truthAt_trCtx`, `blValid_iff_valid_tr` — its context-level and validity-level corollaries
- `blValidDiscrete_iff_validDiscrete_tr` — the `.Discrete` mirror of `blValid_iff_valid_tr`,
  consumed by `Metalogic/TMCompletenessReduction.lean`
- `bl_soundness`, `bl_soundness_dense`, `bl_soundness_discrete`, `bl_soundness_dedekind` — the
  four soundness theorems
- `bl_soundness_valid`, `bl_soundness_dense_valid`, `bl_soundness_discrete_valid`,
  `bl_soundness_dedekind_valid` — their empty-context validity forms
- `bl_not_derivable_nil_bot`, `bl_not_derivable_nil_bot_discrete` — consistency of BL at
  `FrameClass.Base` and `FrameClass.Discrete`

## References

* JPL paper `\S sub:Logic` — `thm:TM-soundness`, `def:BL-semantics`
* `FormalSystem/Metalogic/Soundness.lean` — the four BL⁺ soundness theorems composed with here
* `FormalSystem/Metalogic/Conservativity.lean` — `translate`, the proof-theoretic half
* `FormalSystem/Semantics/BLTruth.lean`, `FormalSystem/Semantics/BLValidity.lean` — the BL
  semantics this is stated against
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax
open FormalSystem.BaseLanguage

variable {F : TaskFrame}

/--
**The truth-transfer bridge.** A BL⁺ formula in the image of the translation is true exactly when
the base-language formula it translates is true, at the same model, history and time.

Proved by induction on `φ`, `generalizing τ t` — which is mandatory rather than stylistic: the
`box` case needs the induction hypothesis at a *different history* `σ`, and the two temporal cases
need it at a *different time* `s`. With `generalizing` the hypothesis reads `∀ τ t, …`, so each
use site applies it explicitly.

Case by case: `atom` and `bot` are `Iff.rfl`, because the two clauses are literally the same
expression (including the domain conjunct — see `Semantics/BLTruth.lean` on Decision A); `imp` and
`box` are congruence under `tr`'s `rfl` push-through equations; `allPast` and `allFuture` are the
only two cases with content, and `Truth.past_iff` / `Truth.future_iff` supply it.
-/
theorem truthAt_tr (M : TaskModel F) (φ : BLFormula) (τ : WorldHistory F) (t : F.Duration) :
    TruthAt M τ t (tr φ) ↔ BLTruthAt M τ t φ := by
  induction φ generalizing τ t with
  | atom p => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp φ ψ ih1 ih2 => simp only [tr_imp, BLTruthAt]; exact imp_congr (ih1 τ t) (ih2 τ t)
  | box φ ih =>
      simp only [tr_box, BLTruthAt, Truth.box_iff]
      exact forall_congr' fun σ => imp_congr_right fun _ => ih σ t
  | allPast φ ih =>
      simp only [tr_allPast, BLTruthAt, Truth.past_iff]
      exact forall_congr' fun s => imp_congr_right fun _ => ih τ s
  | allFuture φ ih =>
      simp only [tr_allFuture, BLTruthAt, Truth.future_iff]
      exact forall_congr' fun s => imp_congr_right fun _ => ih τ s

/--
The context-level form of the bridge: if every formula of a BL context is true, then every formula
of its translation is true. This is the side-condition discharger each of the four soundness
compositions below calls.
-/
theorem truthAt_trCtx (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {Γ : BaseLanguage.Context} (h : ∀ ψ ∈ Γ, BLTruthAt M τ t ψ) :
    ∀ ψ ∈ trCtx Γ, TruthAt M τ t ψ := by
  intro ψ hψ
  obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hψ
  exact (truthAt_tr M χ τ t).mpr (h χ hχ)

/--
The validity-level bridge.

This is a **corollary of `truthAt_tr`, not the definition of `BLValid`**. `BLValid` is defined
against the native `BLTruthAt`; stating this equivalence as a theorem is what keeps the
distinction visible, since defining BL truth as `TruthAt ∘ tr` would make it hold by `Iff.rfl` and
would make every BL soundness theorem below a restatement of its BL⁺ source rather than a claim
about BL.
-/
theorem blValid_iff_valid_tr (φ : BLFormula) : BLValid φ ↔ valid (tr φ) := by
  constructor
  · intro h
    refine valid.of_forall_total ?_
    intro F M τ hτ t
    exact (truthAt_tr M φ τ t).mpr (h.apply F M τ hτ t)
  · intro h
    refine BLValid.of_forall_total ?_
    intro F M τ hτ t
    exact (truthAt_tr M φ τ t).mp (h.apply F M τ hτ t)

/--
The **`.Discrete` mirror** of `blValid_iff_valid_tr`: BL validity over the discrete frame class
is `TruthAt`-equivalent to `ValidDiscrete` of the translation, with the four
`SuccOrder`/`PredOrder`/`IsSuccArchimedean`/`IsPredArchimedean` instance binders threaded through
exactly as `BLValidDiscrete.of_forall`/`.apply` and `ValidDiscrete.of_forall`/`.apply` carry them.
Same two-branch `constructor` proof as `blValid_iff_valid_tr`, off `truthAt_tr`.

Consumed by `Metalogic/TMCompletenessReduction.lean`'s `tmCompleteDiscrete_iff_forwardDiscrete`.
-/
theorem blValidDiscrete_iff_validDiscrete_tr (φ : BLFormula) :
    BLValidDiscrete φ ↔ ValidDiscrete (tr φ) := by
  constructor
  · intro h
    refine ValidDiscrete.of_forall ?_
    intro F so po hsa hpa M τ hτ t
    exact (truthAt_tr M φ τ t).mpr (h.apply F M τ hτ t)
  · intro h
    refine BLValidDiscrete.of_forall ?_
    intro F so po hsa hpa M τ hτ t
    exact (truthAt_tr M φ τ t).mp (h.apply F M τ hτ t)

end FormalSystem.Semantics

namespace FormalSystem.Metalogic

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.BaseLanguage
open FormalSystem.Semantics

/-! ## The four soundness theorems

Each is a single expression: translate the BL derivation, apply the corresponding BL⁺ soundness
theorem, and cross the bridge. The binder bundle of each matches its BL⁺ source exactly —
including `soundness_dedekind`'s `h_lub`, which is threaded through in the same position, between
`D` and `F`. -/

/--
**Soundness of BL at `FrameClass.Base`.** A BL derivation of `φ` from `Γ` makes `φ` true at every
model, **total** history and time at which every formula of `Γ` is true.

Composition of `Conservativity.translate` with `soundness`, across `truthAt_tr`.
-/
theorem bl_soundness (Γ : BaseLanguage.Context) (φ : BLFormula)
    (d : BaseLanguage.DerivationTree FrameClass.Base Γ φ)
    (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, BLTruthAt M τ t ψ) :
    BLTruthAt M τ t φ :=
  (truthAt_tr M φ τ t).mp
    (soundness (trCtx Γ) (tr φ) (Conservativity.translate d) F M τ h_mem t
      (truthAt_trCtx M τ t h_ctx))

/--
**Soundness of BL at `FrameClass.Dense`.** Composition of `Conservativity.translate` with
`soundness_dense`, across `truthAt_tr`; the binder bundle is `soundness_dense`'s.
-/
theorem bl_soundness_dense (Γ : BaseLanguage.Context) (φ : BLFormula)
    (d : BaseLanguage.DerivationTree FrameClass.Dense Γ φ)
    (F : TaskFrame) [DenselyOrdered F.Duration] (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, BLTruthAt M τ t ψ) :
    BLTruthAt M τ t φ :=
  (truthAt_tr M φ τ t).mp
    (soundness_dense (trCtx Γ) (tr φ) (Conservativity.translate d) F M τ h_mem t
      (truthAt_trCtx M τ t h_ctx))

/--
**Soundness of BL at `FrameClass.Discrete`.** Composition of `Conservativity.translate` with
`soundness_discrete`, across `truthAt_tr`; the binder bundle is `soundness_discrete`'s.
-/
theorem bl_soundness_discrete (Γ : BaseLanguage.Context) (φ : BLFormula)
    (d : BaseLanguage.DerivationTree FrameClass.Discrete Γ φ)
    (F : TaskFrame) [SuccOrder F.Duration] [PredOrder F.Duration]
    [IsSuccArchimedean F.Duration] [IsPredArchimedean F.Duration] (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, BLTruthAt M τ t ψ) :
    BLTruthAt M τ t φ :=
  (truthAt_tr M φ τ t).mp
    (soundness_discrete (trCtx Γ) (tr φ) (Conservativity.translate d) F M τ h_mem t
      (truthAt_trCtx M τ t h_ctx))

/--
**Soundness of BL at `FrameClass.Dedekind`.** Composition of `Conservativity.translate` with
`soundness_dedekind`, across `truthAt_tr`; the binder bundle is `soundness_dedekind`'s, including
the `[DenselyOrdered D]` binder and the least-upper-bound hypothesis `h_lub` in its original
position.

The `[DenselyOrdered D]` binder is load-bearing, not decorative — see the module docstring and
`Semantics/BLValidity.lean`.
-/
theorem bl_soundness_dedekind (Γ : BaseLanguage.Context) (φ : BLFormula)
    (d : BaseLanguage.DerivationTree FrameClass.Dedekind Γ φ)
    (F : TaskFrame) [DenselyOrdered F.Duration]
    (h_lub : ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, BLTruthAt M τ t ψ) :
    BLTruthAt M τ t φ :=
  (truthAt_tr M φ τ t).mp
    (soundness_dedekind (trCtx Γ) (tr φ) (Conservativity.translate d) F h_lub M τ h_mem t
      (truthAt_trCtx M τ t h_ctx))

/-! ## Empty-context validity forms -/

/-- Empty-context form of `bl_soundness`: a BL theorem at `FrameClass.Base` is BL-valid. -/
theorem bl_soundness_valid {φ : BLFormula}
    (d : BaseLanguage.DerivationTree FrameClass.Base [] φ) : BLValid φ :=
  BLValid.of_forall_total fun F M τ h_mem t => bl_soundness [] φ d F M τ h_mem t (by simp)

/-- Empty-context form of `bl_soundness_dense`. -/
theorem bl_soundness_dense_valid {φ : BLFormula}
    (d : BaseLanguage.DerivationTree FrameClass.Dense [] φ) : BLValidDense φ :=
  BLValidDense.of_forall fun F _ M τ h_mem t => bl_soundness_dense [] φ d F M τ h_mem t (by simp)

/-- Empty-context form of `bl_soundness_discrete`. -/
theorem bl_soundness_discrete_valid {φ : BLFormula}
    (d : BaseLanguage.DerivationTree FrameClass.Discrete [] φ) : BLValidDiscrete φ :=
  BLValidDiscrete.of_forall fun F _ _ _ _ M τ h_mem t =>
    bl_soundness_discrete [] φ d F M τ h_mem t (by simp)

/-- Empty-context form of `bl_soundness_dedekind`, at `BLValidDedekindDense`. -/
theorem bl_soundness_dedekind_valid {φ : BLFormula}
    (d : BaseLanguage.DerivationTree FrameClass.Dedekind [] φ) : BLValidDedekindDense φ :=
  BLValidDedekindDense.of_forall fun F _ h_lub M τ h_mem t =>
    bl_soundness_dedekind [] φ d F h_lub M τ h_mem t (by simp)

/-! ## Consistency

Two corollaries only, at `FrameClass.Base` and `FrameClass.Discrete`; the module docstring
explains why the dense and Dedekind cases are deliberately absent. Both are phrased as
`¬ BaseLanguage.Derivable …` rather than through `Metalogic.Core.Consistent`, for the same
import-graph reason `not_derivable_nil_bot` records on the BL⁺ side. -/

/--
**BL at `FrameClass.Base` is consistent**: `⊥` is not derivable from the empty context.

The witness is `trivialFrame` over `Int`, exactly as in `not_derivable_nil_bot`. The step across
the bridge is invisible here because `tr BLFormula.bot` is `Formula.bot` definitionally, so
`TaskFrame.not_validOn_bot` applies unchanged.
-/
theorem bl_not_derivable_nil_bot :
    ¬ BaseLanguage.Derivable FrameClass.Base ([] : BaseLanguage.Context) BLFormula.bot := by
  rintro ⟨d⟩
  refine TaskFrame.not_validOn_bot (FrameOver.trivialFrame (D := Int)) ?_
  intro M τ x
  exact bl_soundness [] BLFormula.bot d (FrameOver.trivialFrame (D := Int)) M τ.val
    τ.property x (by simp)

/--
**BL at `FrameClass.Discrete` is consistent**: `⊥` is not derivable from the empty context in the
system extended by the discreteness axioms.

The witness is again `trivialFrame` over `ℤ`, with the single total history supplied by
`TaskFrame.hF_nonempty_of_frameAxioms` and the valuation by `TaskModel.allFalse`.
-/
theorem bl_not_derivable_nil_bot_discrete :
    ¬ BaseLanguage.Derivable FrameClass.Discrete ([] : BaseLanguage.Context) BLFormula.bot := by
  rintro ⟨d⟩
  obtain ⟨τ⟩ := TaskFrame.hF_nonempty_of_frameAxioms (FrameOver.trivialFrame (D := ℤ))
  exact (bl_soundness_discrete_valid d).apply (FrameOver.trivialFrame (D := ℤ)) TaskModel.allFalse
    τ.val τ.property 0

/-! ## Native spot checks

Three BL axiom schemes proved valid *directly* against `BLTruthAt`, using nothing but its clauses.
They are not consumed by anything above — their job is to stand as evidence that the BL semantics
carries content on its own, independently of the composition, and they are the guard against
`BLTruthAt` ever being redefined as `TruthAt ∘ tr` (under which these scripts would not go through
as written).

`MT` is the informative one: it closes because `τ` is *itself* total, which is precisely the `H_F`
reading of `def:BL-semantics`'s box clause. -/

/-- TK — the temporal distribution scheme `G(φ → ψ) → (Gφ → Gψ)`. -/
example (φ ψ : BLFormula) : BLValid ((φ.imp ψ).allFuture.imp (φ.allFuture.imp ψ.allFuture)) := by
  refine BLValid.of_forall_total ?_
  intro F M τ _ t hk hf s hs
  exact hk s hs (hf s hs)

/-- T4 — temporal transitivity `Gφ → GGφ`. -/
example (φ : BLFormula) : BLValid (φ.allFuture.imp φ.allFuture.allFuture) := by
  refine BLValid.of_forall_total ?_
  intro F M τ _ t h s hs r hr
  exact h r (lt_trans hs hr)

/-- MT — the modal T scheme `□φ → φ`. -/
example (φ : BLFormula) : BLValid (φ.box.imp φ) := by
  refine BLValid.of_forall_total ?_
  intro F M τ hτ t h
  exact h τ hτ

end FormalSystem.Metalogic
