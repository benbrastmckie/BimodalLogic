/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.Conservativity.Backward
import FormalSystem.Semantics.MinusLanguage.MinusValidity
import FormalSystem.Semantics.MinusLanguage.MinusSchemaValidity

/-!
# Soundness for the base language L⁻, by composition

`TM⁻ ⊢ φ  ⟹  L⁻-validity of φ`, at `FrameClass.Base` and at each of the three extensions, obtained
by composing two things this repository already has:

```
⊢⁻[fc] φ  ──[Conservativity.translate]──▸  ⊢[fc] tr φ  ──[soundness…]──▸  M,τ,x ⊨ tr φ
                                                                              ‖ truthAt_tr
                                                                          M,τ,x ⊨⁻ φ
```

The right-hand equality is the **truth-transfer bridge** `truthAt_tr`, proved here by induction on
`MinusFormula`. It is a theorem, not a definition: `MinusTruthAt` is defined natively on `MinusFormula`
(`Semantics/MinusLanguage/MinusTruth.lean`), so the bridge has to be earned. Four of its six cases are `Iff.rfl` or
congruence; the `allPast` and `allFuture` cases are the two with content, and both are discharged
by the existing `@[simp]` characterizations `Truth.past_iff` and `Truth.future_iff`, which unfold
L's `untl`/`snce`-derived `H`/`G` abbreviations to exactly the quantifications `MinusTruthAt`
states directly.

## What composition certifies, and what it does not

These theorems inherit per-axiom validity from `Metalogic/Soundness.lean`'s L validity lemmas
together with `MinusLanguage/AxiomDischarge.lean`'s discharge table. That is mathematically
complete — every L⁻ axiom's translation is an L theorem, and every L theorem is valid — but it
does mean **no L⁻ axiom is ever evaluated directly against `MinusTruthAt` by the composition
itself**. The three native `example`s at the end of this module are the standing evidence that
`MinusTruthAt` carries real content independently of the composition: each proves an L⁻ axiom scheme
valid by unfolding `MinusTruthAt`'s clauses and nothing else.

`Conservativity.translate` is `noncomputable`, but it occurs only inside proof terms of
`Prop`-valued theorems, so it contributes nothing to the axiom profile; every result below sits at
`[propext, Classical.choice, Quot.sound]`.

## The Dedekind target

`minus_soundness_rtime` concludes at `MinusValidRTime`, **not** at a density-free
`MinusValidComplete` — which is deliberately not defined. `Semantics/MinusLanguage/MinusValidity.lean`'s module
docstring gives the L⁻-native refutation: `Axiom.dn` is admissible at `FrameClass.RTime` and is
false on `ℤ`, which satisfies every remaining binder. This mirrors `soundness_rtime`'s own
target on the L side.

## Why there is no dense or Dedekind consistency corollary

Consistency is a per-frame-class fact read off a soundness theorem together with a *witness
frame* for that class. The tree carries `trivialFrame` over `Int`, which serves `FrameClass.Base`
and `FrameClass.ZTime`; it carries no dense or Dedekind-complete witness frame. The L side
records the same asymmetry in `Metalogic/Soundness.lean`'s docstring for `not_derivable_nil_bot`
("there is no `{fc}`-uniform statement, because `Dense` and `Dedekind` have no corresponding
consistency lemma in the tree yet"), and the L⁻ side inherits it exactly.

## Main Results

- `truthAt_tr` — the bridge: `TruthAt M τ t (tr φ) ↔ MinusTruthAt M τ t φ`
- `truthAt_trCtx`, `minusValid_iff_valid_tr` — its context-level and validity-level corollaries
- `minusTruthAt_timeShift` — time-homogeneity of `MinusTruthAt`, the L⁻ mirror of
  `Semantics.TimeShift.timeShift_preserves_truth`
- `minus_box_universal` — `□` is the **universal** modality over the whole model: history-blind by
  definition, time-blind by `Truth.box_const`
- `minusValidZTime_iff_validZTime_tr` — the `.ZTime` mirror of `minusValid_iff_valid_tr`,
  consumed by `Metalogic/Conservativity/TMCompletenessReduction.lean`
- `minus_soundness`, `minus_soundness_dense`, `minus_soundness_ztime`, `minus_soundness_rtime` — the
  four soundness theorems
- `minus_soundness_valid`, `minus_soundness_dense_valid`, `minus_soundness_ztime_valid`,
  `minus_soundness_rtime_valid` — their empty-context validity forms
- `minus_soundness_ztime_succ`, `minus_soundness_ztime_succ_valid` — a **fifth** soundness
  theorem, at `FrameClass.ZTime` with the two Archimedean binders dropped. Unlike the four
  above, it is **not** a composition (`Soundness.soundness_ztime` itself carries the binders
  being dropped); it is proved directly against `MinusTruthAt`. See its own docstring section below.
- `minus_not_derivable_nil_bot`, `minus_not_derivable_nil_bot_ztime` — consistency of L⁻ at
  `FrameClass.Base` and `FrameClass.ZTime`

## References

* JPL paper `\S sub:Logic` — `thm:TM-soundness`, `def:BL-semantics`
* `FormalSystem/Metalogic/Soundness.lean` — the four L soundness theorems composed with here
* `FormalSystem/Metalogic/Conservativity/Backward.lean` — `translate`, the proof-theoretic half
* `FormalSystem/Semantics/MinusLanguage/MinusTruth.lean`, `FormalSystem/Semantics/MinusLanguage/MinusValidity.lean` — the L⁻
  semantics this is stated against

## Tags

soundness · base-language · truth-transfer · def:BL-semantics
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax
open FormalSystem.MinusLanguage

variable {F : TaskFrame}

/--
**The truth-transfer bridge.** An L formula in the image of the translation is true exactly when
the base-language formula it translates is true, at the same model, history and time.

Proved by induction on `φ`, `generalizing τ t` — which is mandatory rather than stylistic: the
`box` case needs the induction hypothesis at a *different history* `σ`, and the two temporal cases
need it at a *different time* `s`. With `generalizing` the hypothesis reads `∀ τ t, …`, so each
use site applies it explicitly.

Case by case: `atom` and `bot` are `Iff.rfl`, because the two clauses are literally the same
expression (see `Semantics/MinusLanguage/MinusTruth.lean`); `imp` and
`box` are congruence under `tr`'s `rfl` push-through equations; `allPast` and `allFuture` are the
only two cases with content, and `Truth.past_iff` / `Truth.future_iff` supply it.
-/
theorem truthAt_tr (M : TaskModel F) (φ : MinusFormula) (τ : WorldHistory F) (t : F.Duration) :
    TruthAt M τ t (tr φ) ↔ MinusTruthAt M τ t φ := by
  induction φ generalizing τ t with
  | atom p => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp φ ψ ih1 ih2 => simp only [tr_imp, MinusTruthAt]; exact imp_congr (ih1 τ t) (ih2 τ t)
  | box φ ih =>
      simp only [tr_box, MinusTruthAt, Truth.box_iff]
      exact forall_congr' fun σ => ih σ t
  | allPast φ ih =>
      simp only [tr_allPast, MinusTruthAt, Truth.past_iff]
      exact forall_congr' fun s => imp_congr_right fun _ => ih τ s
  | allFuture φ ih =>
      simp only [tr_allFuture, MinusTruthAt, Truth.future_iff]
      exact forall_congr' fun s => imp_congr_right fun _ => ih τ s

/--
The context-level form of the bridge: if every formula of an L⁻ context is true, then every formula
of its translation is true. This is the side-condition discharger each of the four soundness
compositions below calls.
-/
theorem truthAt_trCtx (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {Γ : MinusLanguage.Context} (h : ∀ ψ ∈ Γ, MinusTruthAt M τ t ψ) :
    ∀ ψ ∈ trCtx Γ, TruthAt M τ t ψ := by
  intro ψ hψ
  obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hψ
  exact (truthAt_tr M χ τ t).mpr (h χ hχ)

/-! ### Two structural corollaries of the bridge

Both are L⁻ mirrors of facts `Semantics/Truth.lean` already carries for L, and both are obtained
by pushing the statement through `truthAt_tr` in each direction rather than by a fresh induction
on `MinusFormula`. They are grouped here, immediately after the bridge, because that is the only
reason they are cheap: `Semantics/MinusLanguage/MinusTruth.lean` cannot state either of them, since it sits below
the translation in the import order.
-/

/--
**Time-homogeneity of `MinusTruthAt`** — the L⁻ mirror of
`Semantics.TimeShift.timeShift_preserves_truth`.

Shifting a history by `y - x` moves the truth value at time `y` to time `x`, for every L⁻ formula
and at an *arbitrary* history: no convexity-beyond-the-structure or shift-closure
hypothesis is needed, exactly as on the L side, because `ShiftRel` is pointwise.

**Proof**: rewrite both sides through `truthAt_tr` and apply the L statement at `tr φ`. No
induction — the induction was already paid for once, in `truthAt_tr`.
-/
theorem minusTruthAt_timeShift (M : TaskModel F) (σ : WorldHistory F)
    (x y : F.Duration) (φ : MinusFormula) :
    MinusTruthAt M (σ.timeShift (y - x)) x φ ↔ MinusTruthAt M σ y φ := by
  rw [← truthAt_tr M φ (σ.timeShift (y - x)) x, ← truthAt_tr M φ σ y]
  exact TimeShift.timeShift_preserves_truth M σ x y (tr φ)

/--
**`□` is the universal modality over the whole model.**

`MinusTruthAt`'s box clause quantifies over all world histories at the *current* time, so
history-independence is definitional. Time-independence is the substantive half and is
`Truth.box_const`, itself time-homogeneity (`minusTruthAt_timeShift` is the same fact stated at the
L⁻ level). Composing the two: `□φ` holds at one history-and-time exactly when `φ` holds at
*every* history and *every* time.

**Consequence, and the reason this lemma is stated rather than left implicit.** L⁻ over task
frames is not a product logic in the hard sense: the `□`/`H`,`G` interaction contributes no
"same-time alignment" validities, because `□` ranges over the whole model rather than over a
time-indexed fibre. The Kripke structure an L⁻ formula can see is therefore an indexed family of
`F.Duration`-chains with a *universal* box, which is what makes a valuation-only truth lemma over
the translation frames of `Metalogic/Algebraic/FlowFrame.lean` possible at all — see
`Metalogic/Conservativity/ChainBundleTruth.lean`.
-/
theorem minus_box_universal (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (φ : MinusFormula) :
    MinusTruthAt M τ t φ.box ↔ ∀ (σ : WorldHistory F) s, MinusTruthAt M σ s φ := by
  constructor
  · intro h σ s
    have hb : TruthAt M τ t (tr φ).box := (truthAt_tr M φ.box τ t).mpr h
    have h2 := (Truth.box_const M τ σ t s (tr φ)).mp hb
    exact (truthAt_tr M φ σ s).mp (h2 σ)
  · intro h σ
    exact h σ t

/-! ### The two transfer theorems

One per L⁻ validity layer, and the whole of the L⁻/L validity bridge. Everything else in this
section is a corollary of one of them at a fixed predicate or tag.
-/

/--
**Transfer at a bare frame predicate.** L⁻ validity over the frames satisfying `P` is L validity
of the translation over the same frames.

**Why this one is required and is not redundant given the tag-indexed form below.**
`MinusValidOnFrames` — and its monotonicity lemma `MinusValidOnFrames.mono` — quantifies over an
arbitrary `P : TaskFrame → Prop`, and for arbitrary `P` there is no `fc` with `P = fc.Sat`: only
four predicates out of all of `TaskFrame → Prop` are named by a tag. This is the same asymmetry
that puts `ValidComplete` (`ValidOnFrames TaskFrame.IsComplete`) outside the `ValidIn` family, and
it is why `Semantics/Validity.lean` carries a `ValidOnFrames.mono` / `ValidIn.mono` split rather
than one lemma. The tag-indexed theorem below is this one at `fc.Sat`; the reverse derivation does
not exist.

A **corollary of `truthAt_tr`, not a definitional identity** — see `minusValid_iff_valid_tr` below on
why that distinction is load-bearing.
-/
theorem minusValidOnFrames_iff_validOnFrames_tr (P : TaskFrame → Prop) (φ : MinusFormula) :
    MinusValidOnFrames P φ ↔ ValidOnFrames P (tr φ) := by
  constructor
  · intro h F hF M τ t
    exact (truthAt_tr M φ τ t).mpr (h F hF M τ t)
  · intro h F hF M τ t
    exact (truthAt_tr M φ τ t).mp (h F hF M τ t)

/--
**Transfer at a `FrameClass` tag.** `minusValidOnFrames_iff_validOnFrames_tr` at `fc.Sat`, which is
what `MinusValidIn` and `ValidIn` are both defined as. Every named L⁻/L validity equivalence in
this development is this theorem at a literal tag.
-/
theorem minusValidIn_iff_validIn_tr (fc : ProofSystem.FrameClass) (φ : MinusFormula) :
    MinusValidIn fc φ ↔ ValidIn fc (tr φ) :=
  minusValidOnFrames_iff_validOnFrames_tr fc.Sat φ

/--
The validity-level bridge, at the unconstrained class: `minusValidIn_iff_validIn_tr` at
`.Base`, where `MinusValid` and `Valid` respectively are.

This is a **corollary of `truthAt_tr`, not the definition of `MinusValid`**. `MinusValid` is defined
against the native `MinusTruthAt`; stating this equivalence as a theorem is what keeps the
distinction visible, since defining L⁻ truth as `TruthAt ∘ tr` would make it hold by `Iff.rfl` and
would make every L⁻ soundness theorem below a restatement of its L source rather than a claim
about L⁻.
-/
theorem minusValid_iff_valid_tr (φ : MinusFormula) : MinusValid φ ↔ Valid (tr φ) :=
  minusValidIn_iff_validIn_tr ProofSystem.FrameClass.Base φ

/--
The **`.ZTime` mirror** of `minusValid_iff_valid_tr`: L⁻ validity over the discrete frame class
is `TruthAt`-equivalent to `ValidZTime` of the translation, with the four
`SuccOrder`/`PredOrder`/`IsSuccArchimedean`/`IsPredArchimedean` frame condition travelling as
the single packed `Sat .ZTime F` hypothesis, so neither direction has to open it. Like
`minusValid_iff_valid_tr`, a one-line corollary of `minusValidIn_iff_validIn_tr`.

Consumed by `Metalogic/Conservativity/TMCompletenessReduction.lean`'s `tmMinusCompleteZTime_iff_forwardZTime`.
-/
theorem minusValidZTime_iff_validZTime_tr (φ : MinusFormula) :
    MinusValidZTime φ ↔ ValidZTime (tr φ) :=
  minusValidIn_iff_validIn_tr ProofSystem.FrameClass.ZTime φ

end FormalSystem.Semantics

namespace FormalSystem.Metalogic

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.MinusLanguage
open FormalSystem.Semantics

/-! ## Soundness of L⁻, parameterized by `FrameClass`

`minus_soundness_in` is the whole of it: translate the L⁻ derivation, apply
`Metalogic/Soundness.lean`'s `soundness_in` at the same class, and cross the truth-transfer
bridge back into L⁻'s native semantics. Nothing in that composition mentions a particular class —
`Conservativity.translate` is already `fc`-polymorphic, and neither `truthAt_tr` nor
`truthAt_trCtx` carries a frame condition — so the four named theorems below are instances of it,
each supplying its class's `FrameClass.Sat` witness and keeping its original statement exactly. -/

/--
**Soundness of L⁻ at an arbitrary `FrameClass`.** An L⁻ derivation of `φ` from `Γ` at `fc` makes
`φ` true at every model, history and time over any frame satisfying `fc`, at which every
formula of `Γ` is true.

Composition of `Conservativity.translate` with `soundness_in`, across `truthAt_tr`.
-/
theorem minus_soundness_in {fc : FrameClass} (Γ : MinusLanguage.Context) (φ : MinusFormula)
    (d : MinusLanguage.DerivationTree fc Γ φ)
    (F : TaskFrame) (hF : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, MinusTruthAt M τ t ψ) :
    MinusTruthAt M τ t φ :=
  (truthAt_tr M φ τ t).mp
    (soundness_in (trCtx Γ) (tr φ) (Conservativity.translate d) F hF M τ t
      (truthAt_trCtx M τ t h_ctx))

/-- Empty-context form of `minus_soundness_in`: an L⁻ theorem at `fc` is `MinusValidIn fc`. The four
`minus_soundness*_valid` theorems below are its instances. -/
theorem minus_soundness_validIn {fc : FrameClass} {φ : MinusFormula}
    (d : MinusLanguage.DerivationTree fc [] φ) : MinusValidIn fc φ :=
  fun F hF M τ t =>
    minus_soundness_in [] φ d F hF M τ t (by simp)

/-! ### The four per-class instances -/

/--
**Soundness of L⁻ at `FrameClass.Base`.** An L⁻ derivation of `φ` from `Γ` makes `φ` true at every
model, history and time at which every formula of `Γ` is true.

`minus_soundness_in` at `fc = .Base`; `Sat .Base` is `True`, so the witness is `trivial`.

Paper: — (formalization-native; the paper defines L⁻ (`def:BL-semantics`) but states no L⁻ soundness theorem)
-/
theorem minus_soundness (Γ : MinusLanguage.Context) (φ : MinusFormula)
    (d : MinusLanguage.DerivationTree FrameClass.Base Γ φ)
    (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, MinusTruthAt M τ t ψ) :
    MinusTruthAt M τ t φ :=
  minus_soundness_in Γ φ d F trivial M τ t h_ctx

/--
**Soundness of L⁻ at `FrameClass.Dense`.** `minus_soundness_in` at `fc = .Dense`, with the
`[DenselyOrdered D]` instance supplied as the `Sat .Dense` witness; the binder bundle is
`soundness_dense`'s.

Paper: — (formalization-native; the paper defines L⁻ (`def:BL-semantics`) but states no L⁻ soundness theorem)
-/
theorem minus_soundness_dense (Γ : MinusLanguage.Context) (φ : MinusFormula)
    (d : MinusLanguage.DerivationTree FrameClass.Dense Γ φ)
    (F : TaskFrame) [DenselyOrdered F.Duration] (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, MinusTruthAt M τ t ψ) :
    MinusTruthAt M τ t φ :=
  minus_soundness_in Γ φ d F ‹DenselyOrdered F.Duration› M τ t h_ctx

/--
**Soundness of L⁻ at `FrameClass.ZTime`.** `minus_soundness_in` at `fc = .ZTime`, with the
four order instances bundled into the `Sat .ZTime` witness; the binder bundle is
`soundness_ztime`'s.

Paper: — (formalization-native; the paper defines L⁻ (`def:BL-semantics`) but states no L⁻ soundness theorem)
-/
theorem minus_soundness_ztime (Γ : MinusLanguage.Context) (φ : MinusFormula)
    (d : MinusLanguage.DerivationTree FrameClass.ZTime Γ φ)
    (F : TaskFrame) [SuccOrder F.Duration] [PredOrder F.Duration]
    [IsSuccArchimedean F.Duration] [IsPredArchimedean F.Duration] (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, MinusTruthAt M τ t ψ) :
    MinusTruthAt M τ t φ :=
  minus_soundness_in Γ φ d F
    ⟨‹SuccOrder F.Duration›, ‹PredOrder F.Duration›,
      ‹IsSuccArchimedean F.Duration›, ‹IsPredArchimedean F.Duration›⟩
    M τ t h_ctx

/--
**Soundness of L⁻ at `FrameClass.RTime`.** `minus_soundness_in` at `fc = .RTime`, with the
density instance and `h_lub` paired into the `Sat .RTime` witness; the binder bundle is
`soundness_rtime`'s, including the `[DenselyOrdered D]` binder and the least-upper-bound
hypothesis `h_lub` in its original position.

The `[DenselyOrdered D]` binder is load-bearing, not decorative — see the module docstring and
`Semantics/MinusLanguage/MinusValidity.lean`.

Paper: — (formalization-native; the paper defines L⁻ (`def:BL-semantics`) but states no L⁻ soundness theorem)
-/
theorem minus_soundness_rtime (Γ : MinusLanguage.Context) (φ : MinusFormula)
    (d : MinusLanguage.DerivationTree FrameClass.RTime Γ φ)
    (F : TaskFrame) [DenselyOrdered F.Duration]
    (h_lub : ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, MinusTruthAt M τ t ψ) :
    MinusTruthAt M τ t φ :=
  minus_soundness_in Γ φ d F ⟨‹DenselyOrdered F.Duration›, h_lub⟩ M τ t h_ctx

/-! ## Empty-context validity forms -/

/-- Empty-context form of `minus_soundness`: an L⁻ theorem at `FrameClass.Base` is L⁻-valid. -/
theorem minus_soundness_valid {φ : MinusFormula}
    (d : MinusLanguage.DerivationTree FrameClass.Base [] φ) : MinusValid φ :=
  minus_soundness_validIn d

/-- Empty-context form of `minus_soundness_dense`. -/
theorem minus_soundness_dense_valid {φ : MinusFormula}
    (d : MinusLanguage.DerivationTree FrameClass.Dense [] φ) : MinusValidDense φ :=
  minus_soundness_validIn d

/-- Empty-context form of `minus_soundness_ztime`. -/
theorem minus_soundness_ztime_valid {φ : MinusFormula}
    (d : MinusLanguage.DerivationTree FrameClass.ZTime [] φ) : MinusValidZTime φ :=
  minus_soundness_validIn d

/-- Empty-context form of `minus_soundness_rtime`, at `MinusValidRTime`. -/
theorem minus_soundness_rtime_valid {φ : MinusFormula}
    (d : MinusLanguage.DerivationTree FrameClass.RTime [] φ) : MinusValidRTime φ :=
  minus_soundness_validIn d

/-! ## `minus_soundness_ztime_succ` — binder-weakened discrete L⁻ soundness

The single missing prerequisite for CEF (report §6.1): L⁻ soundness at `FrameClass.ZTime`
under `[SuccOrder] [PredOrder]` only, dropping `[IsSuccArchimedean] [IsPredArchimedean]`, so that
it applies to the non-Archimedean carrier `ℚ ×ₗ ℤ` (`Semantics/LexCarrier.lean`) the CEF
countermodel is built over.

**This is not a composition.** Unlike `minus_soundness`/`minus_soundness_dense`/`minus_soundness_ztime`/
`minus_soundness_rtime` above, `minus_soundness_ztime_succ` cannot be obtained by translating and
invoking `Soundness.soundness_ztime`, because that theorem's own binder bundle carries the very
two Archimedean instances being dropped here. It is proved instead by induction on
`MinusLanguage.DerivationTree FrameClass.ZTime`, directly against `MinusTruthAt`.

The only genuinely new semantic content is `Semantics.MinusLanguage.MinusSchemaValidity`'s DF lemma
(`df_valid_of_succOrder`) and its `PredOrder` past-dual (`swapMinus_df_valid_of_predOrder`), needed
respectively for the `df` axiom leaf and for the `temporal_duality` case's swap component.
Every other axiom — the twelve with `minFrameClass = .Base` — is discharged **without any
semantic argument at all**: `minus_derivable_valid_and_swap_valid_zTimeSucc` re-derives each one
(and its swap) proof-theoretically, by composing `minus_soundness_valid` with the `TD` rule itself
(`⊢[Base] φ ⟹ ⊢[Base] φ.swapMinus`), never touching `MinusTruthAt` directly for those twelve. `dn`/`co`
are eliminated structurally: `FrameClass.Dense` and `FrameClass.RTime` are each incomparable
with `FrameClass.ZTime`, so their axiom leaves are unreachable under the `h_fc` side
condition. -/

/--
Combined validity and swap-validity, on `[SuccOrder] [PredOrder]` frames (no Archimedean
binders), for L⁻ theorems (empty-context derivations) at `FrameClass.ZTime`. The companion
`minus_soundness_ztime_succ`'s `temporal_duality` case needs exactly the swap half of this, as an
external fact — mirroring `Metalogic/Soundness.lean`'s `derivable_valid_and_swap_validIn` (the
L sibling this parallels), but over L⁻'s own 15-constructor `Axiom` rather than L's 45, and
without the `FrameClass` parameter, since the binder-weakened `.ZTime` frames this is stated
over are not a `FrameClass.Sat` variant.

The `axiom` case's `by_cases hbase : h_ax.minFrameClass ≤ FrameClass.Base` split is the same
device `Metalogic/Soundness.lean`'s `axiom_swap_validIn_min` uses: it separates the twelve
instance-free (`.Base`-classed)
axioms — whose validity **and swap-validity** both come for free via `minus_soundness_valid`
composed with the `TD` proof rule — from the three that are not, without enumerating the twelve
constructors by name.
-/
private theorem minus_derivable_valid_and_swap_valid_zTimeSucc {φ : MinusFormula}
    (d : MinusLanguage.DerivationTree FrameClass.ZTime [] φ) :
    MinusValidZTimeSucc φ ∧ MinusValidZTimeSucc φ.swapMinus := by
  match d with
  | .axiom _ _ h_ax h_fc =>
    by_cases hbase : h_ax.minFrameClass ≤ FrameClass.Base
    · exact ⟨MinusValidity.minusValid_implies_minusValidZTimeSucc
              (minus_soundness_valid (.axiom [] _ h_ax hbase)),
             MinusValidity.minusValid_implies_minusValidZTimeSucc
              (minus_soundness_valid (.temporal_duality _ (.axiom [] _ h_ax hbase)))⟩
    · cases h_ax with
      | df ψ =>
          exact ⟨fun F _ _ M τ t => df_valid_of_succOrder M τ t ψ,
                 fun F _ _ M τ t => swapMinus_df_valid_of_predOrder M τ t ψ.swapMinus⟩
      | dn _ => exact absurd h_fc (show ¬ (FrameClass.Dense ≤ FrameClass.ZTime) by decide)
      | co _ => exact absurd h_fc (show ¬ (FrameClass.RTime ≤ FrameClass.ZTime) by decide)
      | _ => exact absurd trivial hbase
  | .assumption _ _ h_mem => exact absurd h_mem (by simp)
  | .modus_ponens _ ψ' _ d1 d2 =>
    obtain ⟨h1_valid, h1_swap⟩ := minus_derivable_valid_and_swap_valid_zTimeSucc d1
    obtain ⟨h2_valid, h2_swap⟩ := minus_derivable_valid_and_swap_valid_zTimeSucc d2
    exact ⟨fun F _ _ M τ t => h1_valid F M τ t (h2_valid F M τ t),
           fun F _ _ M τ t => h1_swap F M τ t (h2_swap F M τ t)⟩
  | .necessitation _ d' =>
    obtain ⟨h_valid, h_swap⟩ := minus_derivable_valid_and_swap_valid_zTimeSucc d'
    exact ⟨fun F _ _ M _τ t σ => h_valid F M σ t,
           fun F _ _ M _τ t σ => h_swap F M σ t⟩
  | .temporal_necessitation _ d' =>
    obtain ⟨h_valid, h_swap⟩ := minus_derivable_valid_and_swap_valid_zTimeSucc d'
    exact ⟨fun F _ _ M τ t s _hs => h_valid F M τ s,
           fun F _ _ M τ t s _hs => h_swap F M τ s⟩
  | .temporal_duality _ d' =>
    obtain ⟨h_valid, h_swap⟩ := minus_derivable_valid_and_swap_valid_zTimeSucc d'
    exact ⟨h_swap, by rw [MinusFormula.swapMinus_involution]; exact h_valid⟩
  | .weakening Γ' _ _ d' h_sub =>
    have h_term := MinusLanguage.DerivationTree.height_ofWeakeningNil_lt d' h_sub
    exact minus_derivable_valid_and_swap_valid_zTimeSucc (d'.ofWeakeningNil h_sub)
termination_by d.height
decreasing_by
  all_goals first
    | omega
    | (simp only [MinusLanguage.DerivationTree.height]; omega)

/--
**Soundness of L⁻ at `FrameClass.ZTime`, binder-weakened.** An L⁻ derivation of `φ` from `Γ`
makes `φ` true at every model, history and time at which every formula of `Γ` is true —
on any `TaskFrame` carrying `[SuccOrder] [PredOrder]`, with **no** `IsSuccArchimedean` /
`IsPredArchimedean` requirement.

By induction on `d`, directly against `MinusTruthAt` (see the module docstring above for why this
cannot be a composition). The `axiom` case's `by_cases` split and the `temporal_duality` case's
call into `minus_derivable_valid_and_swap_valid_zTimeSucc` mirror that lemma's own proof exactly.
-/
theorem minus_soundness_ztime_succ (Γ : MinusLanguage.Context) (φ : MinusFormula)
    (d : MinusLanguage.DerivationTree FrameClass.ZTime Γ φ)
    (F : TaskFrame) [SuccOrder F.Duration] [PredOrder F.Duration] (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, MinusTruthAt M τ t ψ) :
    MinusTruthAt M τ t φ := by
  induction d generalizing τ t with
  | «axiom» Γ' φ' h_ax h_fc =>
    by_cases hbase : h_ax.minFrameClass ≤ FrameClass.Base
    · exact (minus_soundness_valid (.axiom [] _ h_ax hbase)).apply F M τ t
    · cases h_ax with
      | df ψ => exact df_valid_of_succOrder M τ t ψ
      | dn _ => exact absurd h_fc (show ¬ (FrameClass.Dense ≤ FrameClass.ZTime) by decide)
      | co _ => exact absurd h_fc (show ¬ (FrameClass.RTime ≤ FrameClass.ZTime) by decide)
      | _ => exact absurd trivial hbase
  | assumption Γ' φ' h_in => exact h_ctx φ' h_in
  | modus_ponens Γ' φ' ψ' d1 d2 ih1 ih2 =>
    exact (ih1 τ t h_ctx) (ih2 τ t h_ctx)
  | necessitation φ' d' ih =>
    rw [MinusTruth.box_iff]
    intro σ
    exact ih σ t (by simp)
  | temporal_necessitation φ' d' ih =>
    rw [MinusTruth.future_iff]
    intro s _hts
    exact ih τ s (by simp)
  | temporal_duality φ' d' _ih =>
    exact (minus_derivable_valid_and_swap_valid_zTimeSucc d').2 F M τ t
  | weakening Γ' Δ' φ' d' h_sub ih =>
    exact ih τ t (fun ψ h_in => h_ctx ψ (h_sub h_in))

/-- Empty-context form of `minus_soundness_ztime_succ`. -/
theorem minus_soundness_ztime_succ_valid {φ : MinusFormula}
    (d : MinusLanguage.DerivationTree FrameClass.ZTime [] φ) : MinusValidZTimeSucc φ :=
  fun F so po M τ t => minus_soundness_ztime_succ [] φ d F M τ t (by simp)

/-! ## Consistency

Two corollaries only, at `FrameClass.Base` and `FrameClass.ZTime`; the module docstring
explains why the dense and Dedekind cases are deliberately absent. Both are phrased as
`¬ MinusLanguage.Derivable …` rather than through `Metalogic.Core.Consistent`, for the same
import-graph reason `not_derivable_nil_bot` records on the L side. -/

/--
**L⁻ at `FrameClass.Base` is consistent**: `⊥` is not derivable from the empty context.

The witness is `trivialFrame` over `Int`, exactly as in `not_derivable_nil_bot`. The step across
the bridge is invisible here because `tr MinusFormula.bot` is `Formula.bot` definitionally, so
`TaskFrame.not_validOn_bot` applies unchanged.

Paper: — (formalization-native; the paper defines L⁻ (`def:BL-semantics`) but states no L⁻ consistency corollary)
-/
theorem minus_not_derivable_nil_bot :
    ¬ MinusLanguage.Derivable FrameClass.Base ([] : MinusLanguage.Context) MinusFormula.bot := by
  rintro ⟨d⟩
  refine TaskFrame.not_validOn_bot (FrameOver.trivialFrame (D := Int)) ?_
  intro M τ x
  exact minus_soundness [] MinusFormula.bot d (FrameOver.trivialFrame (D := Int)) M τ
    x (by simp)

/--
**L⁻ at `FrameClass.ZTime` is consistent**: `⊥` is not derivable from the empty context in the
system extended by the discreteness axioms.

The witness is again `trivialFrame` over `ℤ`, with a world history supplied by
`TaskFrame.hF_nonempty_of_frameAxioms` and the valuation by `TaskModel.allFalse`.
-/
theorem minus_not_derivable_nil_bot_ztime :
    ¬ MinusLanguage.Derivable FrameClass.ZTime ([] : MinusLanguage.Context) MinusFormula.bot := by
  rintro ⟨d⟩
  obtain ⟨τ⟩ := TaskFrame.hF_nonempty_of_frameAxioms (FrameOver.trivialFrame (D := ℤ))
  exact minus_soundness_ztime_valid d (FrameOver.trivialFrame (D := ℤ))
    (TaskFrame.isZTime_of_instances _) TaskModel.allFalse τ 0

/-! ## Native spot checks

Three L⁻ axiom schemes proved valid *directly* against `MinusTruthAt`, using nothing but its clauses.
They are not consumed by anything above — their job is to stand as evidence that the L⁻ semantics
carries content on its own, independently of the composition, and they are the guard against
`MinusTruthAt` ever being redefined as `TruthAt ∘ tr` (under which these scripts would not go through
as written).

**Do not delete these as redundant now that `minusValidOnFrames_iff_validOnFrames_tr` and
`minusValidIn_iff_validIn_tr` exist.** Those two are corollaries of the *theorem* `truthAt_tr`, not
of a definitional identity, so they presuppose exactly what these examples independently witness:
that `MinusTruthAt` is a separate definition which happens to agree with `TruthAt ∘ tr`. If L⁻ truth
were ever redefined as the composite, the transfer theorems would become `Iff.rfl` and would stop
carrying any information — and these three examples are what would fail first and say so.

`MT` is the informative one: it closes because `τ` is *itself* a world history, which is precisely
the `H_F` reading of `def:BL-semantics`'s box clause. -/

/-- TK — the temporal distribution scheme `G(φ → ψ) → (Gφ → Gψ)`. -/
example (φ ψ : MinusFormula) : MinusValid ((φ.imp ψ).allFuture.imp (φ.allFuture.imp ψ.allFuture)) := by
  refine MinusValid.of_forall ?_
  intro F M τ t hk hf s hs
  exact hk s hs (hf s hs)

/-- T4 — temporal transitivity `Gφ → GGφ`. -/
example (φ : MinusFormula) : MinusValid (φ.allFuture.imp φ.allFuture.allFuture) := by
  refine MinusValid.of_forall ?_
  intro F M τ t h s hs r hr
  exact h r (lt_trans hs hr)

/-- MT — the modal T scheme `□φ → φ`. -/
example (φ : MinusFormula) : MinusValid (φ.box.imp φ) := by
  refine MinusValid.of_forall ?_
  intro F M τ t h
  exact h τ

end FormalSystem.Metalogic
