/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.OpenLanguage.OpenAxioms
import FormalSystem.OpenLanguage.OpenValidity
import FormalSystem.OpenLanguage.OpenOckhamist
import FormalSystem.OpenLanguage.OpenReversal
import FormalSystem.Metalogic.SoundnessLemmas.GenericSchemata
import FormalSystem.Metalogic.Conservativity.Plus.AxiomValidity

/-!
# Validity and reflection-validity of the L^▷ axiom schemata

The per-block helper theorems that the two dispatch lemmas of L^▷ soundness are assembled from.
Each block helper is **independently complete** — no block closes with a `sorry` — and the two
wildcard-free dispatches `openAxiom_validIn_min` / `openAxiom_reflect_time_validIn_min` consume
them, one arm per `OpenAxiom` constructor.

The reflection halves are what make the `time_reflection` rule sound **semantically**
(`Conservativity/Open/OpenSoundness.lean`, the companion recursion): no proof-theoretic mirror
argument is used, since the axiom set is not mirror-closed.

## No completeness is claimed

Nothing in this file is a completeness claim for L^▷ at any frame class. These are soundness
obligations, one per schema.

## The restricted-modal block is nearly free

Every obligation for the `▷`/`◁` block is a landed `openValid_*` theorem of
`OpenLanguage/OpenValidity.lean` or `OpenLanguage/OpenOckhamist.lean`, and every reflection half
is one line from its twin through `openValid_reflectTime`
(`OpenLanguage/OpenReversal.lean`): `reflectTime` fixes `⊡` and exchanges `▷` with `◁`, so the
reflection of each `▷` schema **is** its `◁` twin at the reflected parameters.

**The backward definability half is absent from the axiom type and is not discharged here.**
`▷◁φ → ⊡φ` remains the landed validity `openValid_ofut_opast_imp_stab`; it is excluded from
`OpenAxiom` because its `eraseOpen` image is the *Determined* schema, which
`PlusLanguage/PlusNonValidities.lean` refutes — see `OpenLanguage/OpenErasure.lean`'s discharge
table. Its absence is a statement about the discharge surface, not about its validity.

## The rigidity blocks

The two rigidity schemata need a congruence that `OpenLanguage/` does not carry, because the
landed `PlusLanguage.truth_congr_agreeFrom` / `truth_congr_agreeUpTo` are statements about
`PlusTruthAt` and a pure L^▷ formula may contain the crossed restricted modal. The two
`openTruthAt_congr_*` theorems below are their L^▷ counterparts: the seven shared arms transcribe
the L⁺ proof verbatim, and the one new arm in each needs **no induction hypothesis** — the
agreement relation at `t` is an equivalence (`agreeFrom_equivalence`, `agreeUpTo_equivalence`), so
the two quantifier domains of the crossed modal simply coincide. The recursive guard on the
purity clause is therefore not needed semantically; it is needed by the erasure transport of
`OpenLanguage/OpenErasure.lean`.

Both schemata are stated as **implication pairs**, never biconditionals: each half is discharged
separately, each erases separately, and a biconditional would have to be assembled from the halves
anyway.

## Main Results

- `openTruthAt_congr_agreeFrom`, `openTruthAt_congr_agreeUpTo` — the L^▷ purity congruences
- `openAxiomValidIn_ofutBlock`, `openAxiomReflectValidIn_ofutBlock` — the fourteen
  non-rigidity restricted-modal schemata and their reflections
- `openAxiomValidIn_rigidityBlock`, `openAxiomReflectValidIn_rigidityBlock` — the four rigidity
  halves and their reflections
- `openTruthAt_congr_ext`, `openTruthAt_timeShift` — the time-shift infrastructure `modal_future`
  consumes
- `openAxiomValidIn_propBlock`, `openAxiomReflectValidIn_propBlock` — the four propositional
  schemata and their reflections
- `openAxiomValidIn_modalBlock`, `openAxiomReflectValidIn_modalBlock` — the five S5-modal schemata
  plus `modal_future`, and their reflections
- `openAxiomValidIn_tempMonoBlock`, `openAxiomReflectValidIn_tempMonoBlock` — the two seriality,
  four monotonicity and two connection schemata, and their reflections
- `openAxiomValidIn_tempAccumBlock`, `openAxiomReflectValidIn_tempAccumBlock` — the two
  enrichment, two self-accumulation and two absorption schemata, and their reflections
- `openAxiomValidIn_linearityBlock`, `openAxiomReflectValidIn_linearityBlock` — the four
  linearity schemata, and their reflections
- `openAxiomValidIn_tempEquivBlock`, `openAxiomReflectValidIn_tempEquivBlock` — the four
  `F`/`P` equivalence schemata, and their reflections
- `openAxiomValidIn_discreteBlock`, `openAxiomReflectValidIn_discreteBlock` — the five
  discrete-uniformity schemata, and their reflections
- `openAxiomValidIn_priorBlock`, `openAxiomReflectValidIn_priorBlock` — the three Prior and three
  Dedekind schemata at `.ZTime`/`.RTime`, and their reflections
- `openAxiomValidIn_denseBlock`, `openAxiomReflectValidIn_denseBlock` — `density` and
  `dense_indicator` at `.Dense`, and their reflections
- `openAxiomValidIn_stabBlock`, `openAxiomReflectValidIn_stabBlock` — the six `⊡` schemata, and
  their reflections
- `openAxiomValidIn_pasteBlock`, `openAxiomReflectValidIn_pasteBlock` — PS and US, and their
  reflections

- `openAxiom_validIn_min`, `openAxiom_reflect_time_validIn_min` — **the two dispatch lemmas**,
  each a wildcard-free `cases ax` with one arm per constructor
- `openAxiom_validIn`, `openAxiom_reflect_time_validIn` — the same at any class admitting the
  schema

With the thirteen block helpers above, the `OpenAxiom` constructor set is **closed**: the union of
their covered-name lists is all 71 constructors, with none covered twice and none missing. The
per-block tally is in the aggregate section's own docstring, and the two dispatch lemmas have
exactly 71 arms each with no wildcard, so Lean's own exhaustiveness check enforces that closure.

## References

* `FormalSystem/Metalogic/Conservativity/Plus/AxiomValidity.lean` — the TM⁺ counterpart, whose
  45 TM-schema arms route through atomization; that route is unavailable here (see the
  directory README)
* `FormalSystem/PlusLanguage/PlusPasting.lean` — `AgreeFrom`, `AgreeUpTo` and the L⁺ congruences
  these transcribe

## Tags

open-language · soundness · axiom-validity · time-reflection
-/

-- Raised from the package default of 1500 because this file is the single discharge surface for
-- all 71 `OpenAxiom` constructors: thirteen block helpers, each schema's per-constructor validity
-- and its reflection half, plus the time-shift and `K±` infrastructure the `modal_future` and
-- Dedekind arms consume. The two wildcard-free dispatch lemmas read every one of those names, so
-- they belong in one module with them. Not for parking unrelated material.
set_option linter.style.longFile 2400

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage
open FormalSystem.OpenLanguage.OpenFormula
open FormalSystem.Semantics
open FormalSystem.Metalogic.SoundnessLemmas

/-! ## The L^▷ purity congruences -/

variable {F : TaskFrame}

/-- **A pure-future L^▷ formula sees only the history from `t` onward.** The L^▷ counterpart of
`PlusLanguage.truth_congr_agreeFrom`. The seven shared arms are that proof verbatim; the `opast`
arm uses no induction hypothesis, since `AgreeFrom · · t` is an equivalence and the two
quantifier domains coincide.

Paper: — (formalization-native; the L⁺ half `PlusLanguage.truth_congr_agreeFrom` supports the
manuscript's PS and US schemata, and this is its restatement over `OpenTruthAt`)
-/
theorem openTruthAt_congr_agreeFrom (M : TaskModel F) {φ : OpenFormula}
    (hφ : IsPureFutureOpen φ) :
    ∀ (τ σ : WorldHistory F) (t : F.Duration), AgreeFrom τ σ t →
      (OpenTruthAt M τ t φ ↔ OpenTruthAt M σ t φ) := by
  induction hφ with
  | atom p =>
    intro τ σ t hag
    change M.valuation _ p ↔ M.valuation _ p
    rw [hag t le_rfl]
  | bot => intros; exact Iff.rfl
  | imp _ _ ihφ ihψ =>
    intro τ σ t hag
    exact Iff.imp (ihφ τ σ t hag) (ihψ τ σ t hag)
  | box φ => intros; exact Iff.rfl
  | stab φ =>
    intro τ σ t hag
    exact forall_congr' fun ρ => imp_congr_left
      ⟨fun h => (hag t le_rfl).symm.trans h, fun h => (hag t le_rfl).trans h⟩
  | untl _ _ ihψ ihφ =>
    intro τ σ t hag
    exact exists_congr fun s => and_congr_right fun hts =>
      and_congr (ihφ τ σ s (agreeFrom_mono hts.le hag))
        (forall_congr' fun r => imp_congr_right fun htr => imp_congr_right fun _ =>
          ihψ τ σ r (agreeFrom_mono htr.le hag))
  | opast φ _ =>
    intro τ σ t hag
    exact forall_congr' fun ρ => imp_congr_left
      ⟨fun h s hs => (hag s hs).symm.trans (h s hs), fun h s hs => (hag s hs).trans (h s hs)⟩

/-- **A pure-past L^▷ formula sees only the history up to `t`.** The mirror of
`openTruthAt_congr_agreeFrom`; the new arm is `ofut`. -/
theorem openTruthAt_congr_agreeUpTo (M : TaskModel F) {φ : OpenFormula}
    (hφ : IsPurePastOpen φ) :
    ∀ (τ σ : WorldHistory F) (t : F.Duration), AgreeUpTo τ σ t →
      (OpenTruthAt M τ t φ ↔ OpenTruthAt M σ t φ) := by
  induction hφ with
  | atom p =>
    intro τ σ t hag
    change M.valuation _ p ↔ M.valuation _ p
    rw [hag t le_rfl]
  | bot => intros; exact Iff.rfl
  | imp _ _ ihφ ihψ =>
    intro τ σ t hag
    exact Iff.imp (ihφ τ σ t hag) (ihψ τ σ t hag)
  | box φ => intros; exact Iff.rfl
  | stab φ =>
    intro τ σ t hag
    exact forall_congr' fun ρ => imp_congr_left
      ⟨fun h => (hag t le_rfl).symm.trans h, fun h => (hag t le_rfl).trans h⟩
  | snce _ _ ihψ ihφ =>
    intro τ σ t hag
    exact exists_congr fun s => and_congr_right fun hst =>
      and_congr (ihφ τ σ s (agreeUpTo_mono hst.le hag))
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun hrt =>
          ihψ τ σ r (agreeUpTo_mono hrt.le hag))
  | ofut φ _ =>
    intro τ σ t hag
    exact forall_congr' fun ρ => imp_congr_left
      ⟨fun h s hs => (hag s hs).symm.trans (h s hs), fun h s hs => (hag s hs).trans (h s hs)⟩

/-! ## The restricted-modal block, per constructor

Fourteen schemata: S5 for `▷` (4), S5 for `◁` (4), the strength ordering `□ ⟹ ⊡ ⟹ ▷/◁` (3), the
two Ockhamist principles, and the forward definability half. Each is a landed validity; each
reflection half is `openValid_reflectTime` of its twin. -/

/-- `▷`-K is valid. -/
theorem openValidIn_ofutK (φ ψ : OpenFormula) :
    OpenValid (imp (ofut (imp φ ψ)) (imp (ofut φ) (ofut ψ))) :=
  openValid_ofut_k φ ψ

/-- `▷`-T is valid. -/
theorem openValidIn_ofutT (φ : OpenFormula) : OpenValid (imp (ofut φ) φ) :=
  openValid_ofut_t φ

/-- `▷`-4 is valid. -/
theorem openValidIn_ofutFour (φ : OpenFormula) :
    OpenValid (imp (ofut φ) (ofut (ofut φ))) :=
  openValid_ofut_four φ

/-- `▷`-5 is valid. -/
theorem openValidIn_ofutFive (φ : OpenFormula) :
    OpenValid (imp (dofut φ) (ofut (dofut φ))) :=
  openValid_ofut_five φ

/-- `◁`-K is valid. -/
theorem openValidIn_opastK (φ ψ : OpenFormula) :
    OpenValid (imp (opast (imp φ ψ)) (imp (opast φ) (opast ψ))) :=
  openValid_opast_k φ ψ

/-- `◁`-T is valid. -/
theorem openValidIn_opastT (φ : OpenFormula) : OpenValid (imp (opast φ) φ) :=
  openValid_opast_t φ

/-- `◁`-4 is valid. -/
theorem openValidIn_opastFour (φ : OpenFormula) :
    OpenValid (imp (opast φ) (opast (opast φ))) :=
  openValid_opast_four φ

/-- `◁`-5 is valid. -/
theorem openValidIn_opastFive (φ : OpenFormula) :
    OpenValid (imp (dopast φ) (opast (dopast φ))) :=
  openValid_opast_five φ

/-- `□φ → ⊡φ` is valid. -/
theorem openValidIn_stabOfBox (φ : OpenFormula) : OpenValid (imp (box φ) (stab φ)) :=
  openValid_stab_of_box φ

/-- `⊡φ → ▷φ` is valid. -/
theorem openValidIn_ofutOfStab (φ : OpenFormula) : OpenValid (imp (stab φ) (ofut φ)) :=
  openValid_ofut_of_stab φ

/-- `⊡φ → ◁φ` is valid. -/
theorem openValidIn_opastOfStab (φ : OpenFormula) : OpenValid (imp (stab φ) (opast φ)) :=
  openValid_opast_of_stab φ

/-- The Ockhamist principle `Pα → ▷P▷̂α` is valid. It is **not** stated for `⊡`: the stability
transposition `Pp → ⊡P⟐p` is refuted on `sinkFrame`. -/
theorem openValidIn_hnOpen (α : OpenFormula) :
    OpenValid (imp (somePast α) (ofut (somePast (dofut α)))) :=
  hnOpen_openValid α

/-- The open-past mirror `Fα → ◁F◁̂α` is valid. -/
theorem openValidIn_hnOpenMirror (α : OpenFormula) :
    OpenValid (imp (someFuture α) (opast (someFuture (dopast α)))) :=
  openValid_hnOpenPast α

/-- The forward definability half `⊡φ → ▷◁φ` is valid, over every task frame and with no frame
axiom. -/
theorem openValidIn_definabilityFwd (φ : OpenFormula) :
    OpenValid (imp (stab φ) (ofut (opast φ))) :=
  openValid_stab_imp_ofut_opast φ

/-! ### The reflection halves

One line each: `openValid_reflectTime` of the twin above. -/

/-- The reflection of `▷`-K is valid. -/
theorem openValidIn_ofutK_reflect (φ ψ : OpenFormula) :
    OpenValid (imp (ofut (imp φ ψ)) (imp (ofut φ) (ofut ψ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_ofutK φ ψ)

/-- The reflection of `▷`-T is valid. -/
theorem openValidIn_ofutT_reflect (φ : OpenFormula) :
    OpenValid (imp (ofut φ) φ).reflectTime :=
  openValid_reflectTime _ (openValidIn_ofutT φ)

/-- The reflection of `▷`-4 is valid. -/
theorem openValidIn_ofutFour_reflect (φ : OpenFormula) :
    OpenValid (imp (ofut φ) (ofut (ofut φ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_ofutFour φ)

/-- The reflection of `▷`-5 is valid. -/
theorem openValidIn_ofutFive_reflect (φ : OpenFormula) :
    OpenValid (imp (dofut φ) (ofut (dofut φ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_ofutFive φ)

/-- The reflection of `◁`-K is valid. -/
theorem openValidIn_opastK_reflect (φ ψ : OpenFormula) :
    OpenValid (imp (opast (imp φ ψ)) (imp (opast φ) (opast ψ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_opastK φ ψ)

/-- The reflection of `◁`-T is valid. -/
theorem openValidIn_opastT_reflect (φ : OpenFormula) :
    OpenValid (imp (opast φ) φ).reflectTime :=
  openValid_reflectTime _ (openValidIn_opastT φ)

/-- The reflection of `◁`-4 is valid. -/
theorem openValidIn_opastFour_reflect (φ : OpenFormula) :
    OpenValid (imp (opast φ) (opast (opast φ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_opastFour φ)

/-- The reflection of `◁`-5 is valid. -/
theorem openValidIn_opastFive_reflect (φ : OpenFormula) :
    OpenValid (imp (dopast φ) (opast (dopast φ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_opastFive φ)

/-- The reflection of `□φ → ⊡φ` is valid. -/
theorem openValidIn_stabOfBox_reflect (φ : OpenFormula) :
    OpenValid (imp (box φ) (stab φ)).reflectTime :=
  openValid_reflectTime _ (openValidIn_stabOfBox φ)

/-- The reflection of `⊡φ → ▷φ` is valid. -/
theorem openValidIn_ofutOfStab_reflect (φ : OpenFormula) :
    OpenValid (imp (stab φ) (ofut φ)).reflectTime :=
  openValid_reflectTime _ (openValidIn_ofutOfStab φ)

/-- The reflection of `⊡φ → ◁φ` is valid. -/
theorem openValidIn_opastOfStab_reflect (φ : OpenFormula) :
    OpenValid (imp (stab φ) (opast φ)).reflectTime :=
  openValid_reflectTime _ (openValidIn_opastOfStab φ)

/-- The reflection of the Ockhamist principle is valid. -/
theorem openValidIn_hnOpen_reflect (α : OpenFormula) :
    OpenValid (imp (somePast α) (ofut (somePast (dofut α)))).reflectTime :=
  openValid_reflectTime _ (openValidIn_hnOpen α)

/-- The reflection of the open-past Ockhamist mirror is valid. -/
theorem openValidIn_hnOpenMirror_reflect (α : OpenFormula) :
    OpenValid (imp (someFuture α) (opast (someFuture (dopast α)))).reflectTime :=
  openValid_reflectTime _ (openValidIn_hnOpenMirror α)

/-- The reflection of the forward definability half is valid. -/
theorem openValidIn_definabilityFwd_reflect (φ : OpenFormula) :
    OpenValid (imp (stab φ) (ofut (opast φ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_definabilityFwd φ)

/-! ## The rigidity block

`◁φ⁺ ↔ φ⁺` for pure-future `φ⁺` and `▷ψ⁻ ↔ ψ⁻` for pure-past `ψ⁻`, each stated as an implication
pair. The forward halves are instances of `◁`-T and `▷`-T and could be routed through them; they
are proved from the congruence here instead, so that each rigidity half is discharged by the fact
it is about. -/

/-- `◁φ⁺ → φ⁺` for pure-future `φ⁺`: take the witness `σ := τ`, which agrees with itself. -/
theorem openValidIn_rigidityOpastFwd {φ : OpenFormula} (_hφ : IsPureFutureOpen φ) :
    OpenValid (imp (opast φ) φ) :=
  OpenValid.of_forall_regular fun _ _ _ τ _ h => h τ fun _ _ => rfl

/-- `φ⁺ → ◁φ⁺` for pure-future `φ⁺`: the informative half. Every history agreeing with `τ` from
`t` onward agrees with it on everything `φ⁺` can see. -/
theorem openValidIn_rigidityOpastBwd {φ : OpenFormula} (hφ : IsPureFutureOpen φ) :
    OpenValid (imp φ (opast φ)) :=
  OpenValid.of_forall_regular fun _ _ M τ t h σ hag =>
    (openTruthAt_congr_agreeFrom M hφ τ σ t hag).mp h

/-- `▷ψ⁻ → ψ⁻` for pure-past `ψ⁻`. -/
theorem openValidIn_rigidityOfutFwd {φ : OpenFormula} (_hφ : IsPurePastOpen φ) :
    OpenValid (imp (ofut φ) φ) :=
  OpenValid.of_forall_regular fun _ _ _ τ _ h => h τ fun _ _ => rfl

/-- `ψ⁻ → ▷ψ⁻` for pure-past `ψ⁻`: the informative half. -/
theorem openValidIn_rigidityOfutBwd {φ : OpenFormula} (hφ : IsPurePastOpen φ) :
    OpenValid (imp φ (ofut φ)) :=
  OpenValid.of_forall_regular fun _ _ M τ t h σ hag =>
    (openTruthAt_congr_agreeUpTo M hφ τ σ t hag).mp h

/-- The reflection of `◁φ⁺ → φ⁺`. -/
theorem openValidIn_rigidityOpastFwd_reflect {φ : OpenFormula} (hφ : IsPureFutureOpen φ) :
    OpenValid (imp (opast φ) φ).reflectTime :=
  openValid_reflectTime _ (openValidIn_rigidityOpastFwd hφ)

/-- The reflection of `φ⁺ → ◁φ⁺`. -/
theorem openValidIn_rigidityOpastBwd_reflect {φ : OpenFormula} (hφ : IsPureFutureOpen φ) :
    OpenValid (imp φ (opast φ)).reflectTime :=
  openValid_reflectTime _ (openValidIn_rigidityOpastBwd hφ)

/-- The reflection of `▷ψ⁻ → ψ⁻`. -/
theorem openValidIn_rigidityOfutFwd_reflect {φ : OpenFormula} (hφ : IsPurePastOpen φ) :
    OpenValid (imp (ofut φ) φ).reflectTime :=
  openValid_reflectTime _ (openValidIn_rigidityOfutFwd hφ)

/-- The reflection of `ψ⁻ → ▷ψ⁻`. -/
theorem openValidIn_rigidityOfutBwd_reflect {φ : OpenFormula} (hφ : IsPurePastOpen φ) :
    OpenValid (imp φ (ofut φ)).reflectTime :=
  openValid_reflectTime _ (openValidIn_rigidityOfutBwd hφ)

/-! ## The two block aggregates

The named helpers the dispatch lemmas of `Conservativity/Open/OpenSoundness.lean`'s companion
file consume. Each is the conjunction of its block's per-constructor theorems above, in
constructor order, so that `obtain` in the dispatch names every arm once. -/

/-- **The restricted-modal validity block**: the fourteen non-rigidity `▷`/`◁` schemata, in
`OpenAxiom` constructor order — `ofut_k`, `ofut_t`, `ofut_four`, `ofut_five`, `opast_k`,
`opast_t`, `opast_four`, `opast_five`, `stab_of_box`, `ofut_of_stab`, `opast_of_stab`, `hn_open`,
`hn_open_mirror`, `definability_fwd`. -/
theorem openAxiomValidIn_ofutBlock :
    (∀ φ ψ : OpenFormula, OpenValid (imp (ofut (imp φ ψ)) (imp (ofut φ) (ofut ψ)))) ∧
    (∀ φ : OpenFormula, OpenValid (imp (ofut φ) φ)) ∧
    (∀ φ : OpenFormula, OpenValid (imp (ofut φ) (ofut (ofut φ)))) ∧
    (∀ φ : OpenFormula, OpenValid (imp (dofut φ) (ofut (dofut φ)))) ∧
    (∀ φ ψ : OpenFormula, OpenValid (imp (opast (imp φ ψ)) (imp (opast φ) (opast ψ)))) ∧
    (∀ φ : OpenFormula, OpenValid (imp (opast φ) φ)) ∧
    (∀ φ : OpenFormula, OpenValid (imp (opast φ) (opast (opast φ)))) ∧
    (∀ φ : OpenFormula, OpenValid (imp (dopast φ) (opast (dopast φ)))) ∧
    (∀ φ : OpenFormula, OpenValid (imp (box φ) (stab φ))) ∧
    (∀ φ : OpenFormula, OpenValid (imp (stab φ) (ofut φ))) ∧
    (∀ φ : OpenFormula, OpenValid (imp (stab φ) (opast φ))) ∧
    (∀ α : OpenFormula, OpenValid (imp (somePast α) (ofut (somePast (dofut α))))) ∧
    (∀ α : OpenFormula, OpenValid (imp (someFuture α) (opast (someFuture (dopast α))))) ∧
    (∀ φ : OpenFormula, OpenValid (imp (stab φ) (ofut (opast φ)))) :=
  ⟨openValidIn_ofutK, openValidIn_ofutT, openValidIn_ofutFour, openValidIn_ofutFive,
    openValidIn_opastK, openValidIn_opastT, openValidIn_opastFour, openValidIn_opastFive,
    openValidIn_stabOfBox, openValidIn_ofutOfStab, openValidIn_opastOfStab,
    openValidIn_hnOpen, openValidIn_hnOpenMirror, openValidIn_definabilityFwd⟩

/-- **The restricted-modal reflection block**, same fourteen schemata in the same order. -/
theorem openAxiomReflectValidIn_ofutBlock :
    (∀ φ ψ : OpenFormula,
      OpenValid (imp (ofut (imp φ ψ)) (imp (ofut φ) (ofut ψ))).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid (imp (ofut φ) φ).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid (imp (ofut φ) (ofut (ofut φ))).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid (imp (dofut φ) (ofut (dofut φ))).reflectTime) ∧
    (∀ φ ψ : OpenFormula,
      OpenValid (imp (opast (imp φ ψ)) (imp (opast φ) (opast ψ))).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid (imp (opast φ) φ).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid (imp (opast φ) (opast (opast φ))).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid (imp (dopast φ) (opast (dopast φ))).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid (imp (box φ) (stab φ)).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid (imp (stab φ) (ofut φ)).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid (imp (stab φ) (opast φ)).reflectTime) ∧
    (∀ α : OpenFormula,
      OpenValid (imp (somePast α) (ofut (somePast (dofut α)))).reflectTime) ∧
    (∀ α : OpenFormula,
      OpenValid (imp (someFuture α) (opast (someFuture (dopast α)))).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid (imp (stab φ) (ofut (opast φ))).reflectTime) :=
  ⟨openValidIn_ofutK_reflect, openValidIn_ofutT_reflect, openValidIn_ofutFour_reflect,
    openValidIn_ofutFive_reflect, openValidIn_opastK_reflect, openValidIn_opastT_reflect,
    openValidIn_opastFour_reflect, openValidIn_opastFive_reflect,
    openValidIn_stabOfBox_reflect, openValidIn_ofutOfStab_reflect,
    openValidIn_opastOfStab_reflect, openValidIn_hnOpen_reflect,
    openValidIn_hnOpenMirror_reflect, openValidIn_definabilityFwd_reflect⟩

/-- **The rigidity validity block**: the four rigidity halves in `OpenAxiom` constructor order —
`rigidity_opast_fwd`, `rigidity_opast_bwd`, `rigidity_ofut_fwd`, `rigidity_ofut_bwd`. -/
theorem openAxiomValidIn_rigidityBlock :
    (∀ {φ : OpenFormula}, IsPureFutureOpen φ → OpenValid (imp (opast φ) φ)) ∧
    (∀ {φ : OpenFormula}, IsPureFutureOpen φ → OpenValid (imp φ (opast φ))) ∧
    (∀ {φ : OpenFormula}, IsPurePastOpen φ → OpenValid (imp (ofut φ) φ)) ∧
    (∀ {φ : OpenFormula}, IsPurePastOpen φ → OpenValid (imp φ (ofut φ))) :=
  ⟨fun h => openValidIn_rigidityOpastFwd h, fun h => openValidIn_rigidityOpastBwd h,
    fun h => openValidIn_rigidityOfutFwd h, fun h => openValidIn_rigidityOfutBwd h⟩

/-- **The rigidity reflection block**, same four halves in the same order. -/
theorem openAxiomReflectValidIn_rigidityBlock :
    (∀ {φ : OpenFormula}, IsPureFutureOpen φ →
      OpenValid (imp (opast φ) φ).reflectTime) ∧
    (∀ {φ : OpenFormula}, IsPureFutureOpen φ → OpenValid (imp φ (opast φ)).reflectTime) ∧
    (∀ {φ : OpenFormula}, IsPurePastOpen φ → OpenValid (imp (ofut φ) φ).reflectTime) ∧
    (∀ {φ : OpenFormula}, IsPurePastOpen φ → OpenValid (imp φ (ofut φ)).reflectTime) :=
  ⟨fun h => openValidIn_rigidityOpastFwd_reflect h,
    fun h => openValidIn_rigidityOpastBwd_reflect h,
    fun h => openValidIn_rigidityOfutFwd_reflect h,
    fun h => openValidIn_rigidityOfutBwd_reflect h⟩

/-! ## Clause-lemma re-exports

`OpenLanguage/OpenTruth.lean`'s `OpenTruth` namespace carries clause lemmas for the two new
operators and for `neg`, `someFuture`, `somePast`, `dstab`, `dofut` and `dopast`, but not for the
derived operators the TM⁺ mirror schemata are stated through. Those are available generically from
the `StabClauses OpenFormula` instance (`Semantics/TruthClauses.lean`); the re-exports below put
them in the `OpenTruthAt` shape. Since the mirror block now delegates to
`Metalogic/SoundnessLemmas/GenericSchemata.lean`, these are no longer what the mirror arms are
read through; four of the nine are still consumed — `openTruth_allFuture_iff` and
`openTruth_allPast_iff` by `Conservativity/Open/OpenSoundness.lean`, and `openTruth_and_iff` and
`openTruth_untl_iff` by the pasting block, which is deliberately not generalised — so all nine are
kept rather than split. Each is already a one-line delegation to the generic clause lemma or an
`Iff.rfl`. -/

section ClauseLemmas

variable (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)

/-- Truth of `φ → ψ` at an L^▷ point. -/
theorem openTruth_imp_iff (φ ψ : OpenFormula) :
    OpenTruthAt M τ t (OpenFormula.imp φ ψ) ↔
      (OpenTruthAt M τ t φ → OpenTruthAt M τ t ψ) := Iff.rfl

/-- Truth of `φ U ψ` at an L^▷ point, guard first. -/
theorem openTruth_untl_iff (ψ φ : OpenFormula) :
    OpenTruthAt M τ t (OpenFormula.untl ψ φ) ↔
      ∃ s : F.Duration, t < s ∧ OpenTruthAt M τ s φ ∧
        ∀ r : F.Duration, t < r → r < s → OpenTruthAt M τ r ψ := Iff.rfl

/-- Truth of `φ S ψ` at an L^▷ point, guard first. -/
theorem openTruth_snce_iff (ψ φ : OpenFormula) :
    OpenTruthAt M τ t (OpenFormula.snce ψ φ) ↔
      ∃ s : F.Duration, s < t ∧ OpenTruthAt M τ s φ ∧
        ∀ r : F.Duration, s < r → r < t → OpenTruthAt M τ r ψ := Iff.rfl

/-- Truth of `φ ∧ ψ` at an L^▷ point. -/
theorem openTruth_and_iff (φ ψ : OpenFormula) :
    OpenTruthAt M τ t (OpenFormula.and φ ψ) ↔
      (OpenTruthAt M τ t φ ∧ OpenTruthAt M τ t ψ) :=
  TruthClauses.and_iff (L := OpenFormula) M τ t PUnit.unit φ ψ

/-- Truth of `φ ∨ ψ` at an L^▷ point. -/
theorem openTruth_or_iff (φ ψ : OpenFormula) :
    OpenTruthAt M τ t (OpenFormula.or φ ψ) ↔
      (OpenTruthAt M τ t φ ∨ OpenTruthAt M τ t ψ) :=
  TruthClauses.or_iff (L := OpenFormula) M τ t PUnit.unit φ ψ

/-- Truth of `◇φ` at an L^▷ point. -/
theorem openTruth_diamond_iff (φ : OpenFormula) :
    OpenTruthAt M τ t (OpenFormula.diamond φ) ↔
      ∃ σ : WorldHistory F, OpenTruthAt M σ t φ :=
  TruthClauses.diamond_iff (L := OpenFormula) M τ t PUnit.unit φ

/-- Truth of `Gφ` at an L^▷ point. -/
theorem openTruth_allFuture_iff (φ : OpenFormula) :
    OpenTruthAt M τ t (OpenFormula.allFuture φ) ↔
      ∀ s : F.Duration, t < s → OpenTruthAt M τ s φ :=
  TruthClauses.allFuture_iff (L := OpenFormula) M τ t PUnit.unit φ

/-- Truth of `Hφ` at an L^▷ point. -/
theorem openTruth_allPast_iff (φ : OpenFormula) :
    OpenTruthAt M τ t (OpenFormula.allPast φ) ↔
      ∀ s : F.Duration, s < t → OpenTruthAt M τ s φ :=
  TruthClauses.allPast_iff (L := OpenFormula) M τ t PUnit.unit φ

/-- Truth of `⊤` at an L^▷ point. -/
theorem openTruth_top (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) :
    OpenTruthAt M τ t OpenFormula.top :=
  TruthClauses.top_true (L := OpenFormula) M τ t PUnit.unit

end ClauseLemmas

/-! ## Time-shift invariance of L^▷ truth

The one piece of semantic infrastructure the TM⁺ mirror block needs that `OpenLanguage/` does not
carry. `modal_future` (`□φ → □Gφ`) is the only schema whose soundness argument moves the *time* of
evaluation rather than the history, and the L⁺ and L⋆ proofs both consume their language's
`timeShift` lemma for it (`PlusLanguage/PlusTruth.lean`'s `plusTruthAt_timeShift`,
`StarLanguage/StarTruth.lean`'s `starTruthAt_timeShift`). The L^▷ analogue is landed here rather
than beside `OpenTruthAt`, so that `OpenLanguage/OpenTruth.lean`'s module invariants stay
untouched.

The two new arms are **not** congruences over the subformula: `▷φ` and `◁φ` quantify over a
history, and the shift acts on the quantifier's *domain*, so each arm exhibits the shifted witness
explicitly. Both directions use the shift's inverse on the quantified history, exactly as the
`box` and `stab` arms of the L⁺ proof do, because `WorldHistory.timeShift` is not definitionally
involutive. -/

/-- **World histories with the same state at every time satisfy the same L^▷ formulas.** The L^▷
counterpart of `PlusLanguage.truth_congr_ext`. The `ofut` and `opast` arms need no induction
hypothesis: the quantified history is the same on both sides, so only the agreement antecedent is
transported. -/
theorem openTruthAt_congr_ext (M : TaskModel F) (φ : OpenFormula) :
    ∀ (τ σ : WorldHistory F) (t : F.Duration), (∀ s, τ.state s = σ.state s) →
      (OpenTruthAt M τ t φ ↔ OpenTruthAt M σ t φ) := by
  induction φ with
  | atom p => intro τ σ t hs; change M.valuation _ p ↔ M.valuation _ p; rw [hs t]
  | bot => intros; exact Iff.rfl
  | imp φ ψ ihφ ihψ => intro τ σ t hs; exact Iff.imp (ihφ τ σ t hs) (ihψ τ σ t hs)
  | box φ _ => intros; exact Iff.rfl
  | untl ψ φ ihψ ihφ =>
    intro τ σ t hs
    exact exists_congr fun s => and_congr_right fun _ => and_congr (ihφ τ σ s hs)
      (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ σ r hs)
  | snce ψ φ ihψ ihφ =>
    intro τ σ t hs
    exact exists_congr fun s => and_congr_right fun _ => and_congr (ihφ τ σ s hs)
      (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ σ r hs)
  | stab φ _ =>
    intro τ σ t hs
    exact forall_congr' fun ρ => imp_congr_left ⟨fun h => (hs t).symm.trans h,
      fun h => (hs t).trans h⟩
  | ofut φ _ =>
    intro τ σ t hs
    exact forall_congr' fun ρ => imp_congr_left
      ⟨fun h u hut => (hs u).symm.trans (h u hut), fun h u hut => (hs u).trans (h u hut)⟩
  | opast φ _ =>
    intro τ σ t hs
    exact forall_congr' fun ρ => imp_congr_left
      ⟨fun h u htu => (hs u).symm.trans (h u htu), fun h u htu => (hs u).trans (h u htu)⟩

/-- **L^▷ truth commutes with time shift.** The `OpenFormula` twin of `plusTruthAt_timeShift`,
whose proof shape the seven shared arms follow verbatim. The `ofut` arm shifts the quantified
history forward in the `→` direction and backward in the `←` direction, closing the latter with
`openTruthAt_congr_ext`; the `opast` arm is the same argument over `AgreeFrom`.

Paper: — (formalization-native; the L⁺ twin `plusTruthAt_timeShift` has no manuscript
statement either)
-/
theorem openTruthAt_timeShift (M : TaskModel F) (φ : OpenFormula) :
    ∀ (σ : WorldHistory F) (t Δ : F.Duration),
      OpenTruthAt M (σ.timeShift Δ) t φ ↔ OpenTruthAt M σ (t + Δ) φ := by
  induction φ with
  | atom p => intros; exact Iff.rfl
  | bot => intros; exact Iff.rfl
  | imp φ ψ ihφ ihψ => intro σ t Δ; exact Iff.imp (ihφ σ t Δ) (ihψ σ t Δ)
  | box φ ih =>
    intro σ t Δ
    constructor
    · intro h ρ
      exact (ih ρ t Δ).mp (h (ρ.timeShift Δ))
    · intro h ρ
      have h1 := (ih (ρ.timeShift (-Δ)) t Δ).mpr (h (ρ.timeShift (-Δ)))
      exact (openTruthAt_congr_ext M φ _ ρ t
        (fun s => (congrArg ρ.state (add_neg_cancel_right s Δ) :
          ρ.state (s + Δ + -Δ) = ρ.state s))).mp h1
  | untl ψ φ ihψ ihφ =>
    intro σ t Δ
    constructor
    · rintro ⟨s, hts, hφ, hψ⟩
      refine ⟨s + Δ, (add_lt_add_iff_right Δ).mpr hts, (ihφ σ s Δ).mp hφ, ?_⟩
      intro r' h1 h2
      have := ihψ σ (r' - Δ) Δ
      rw [sub_add_cancel] at this
      exact this.mp (hψ (r' - Δ) (lt_sub_iff_add_lt.mpr h1) (sub_lt_iff_lt_add.mpr h2))
    · rintro ⟨s', h, hφ, hψ⟩
      refine ⟨s' - Δ, lt_sub_iff_add_lt.mpr h, ?_, ?_⟩
      · have := ihφ σ (s' - Δ) Δ
        rw [sub_add_cancel] at this
        exact this.mpr hφ
      · intro r htr hrs
        exact (ihψ σ r Δ).mpr
          (hψ (r + Δ) ((add_lt_add_iff_right Δ).mpr htr) (lt_sub_iff_add_lt.mp hrs))
  | snce ψ φ ihψ ihφ =>
    intro σ t Δ
    constructor
    · rintro ⟨s, hst, hφ, hψ⟩
      refine ⟨s + Δ, (add_lt_add_iff_right Δ).mpr hst, (ihφ σ s Δ).mp hφ, ?_⟩
      intro r' h1 h2
      have := ihψ σ (r' - Δ) Δ
      rw [sub_add_cancel] at this
      exact this.mp (hψ (r' - Δ) (lt_sub_iff_add_lt.mpr h1) (sub_lt_iff_lt_add.mpr h2))
    · rintro ⟨s', h, hφ, hψ⟩
      refine ⟨s' - Δ, sub_lt_iff_lt_add.mpr h, ?_, ?_⟩
      · have := ihφ σ (s' - Δ) Δ
        rw [sub_add_cancel] at this
        exact this.mpr hφ
      · intro r hsr hrt
        exact (ihψ σ r Δ).mpr
          (hψ (r + Δ) (sub_lt_iff_lt_add.mp hsr) ((add_lt_add_iff_right Δ).mpr hrt))
  | stab φ ih =>
    intro σ t Δ
    constructor
    · intro h ρ hs
      exact (ih ρ t Δ).mp (h (ρ.timeShift Δ) hs)
    · intro h ρ hs
      have hs' : σ.state (t + Δ) = (ρ.timeShift (-Δ)).state (t + Δ) :=
        hs.trans (congrArg ρ.state (add_neg_cancel_right t Δ).symm)
      have h1 := (ih (ρ.timeShift (-Δ)) t Δ).mpr (h (ρ.timeShift (-Δ)) hs')
      exact (openTruthAt_congr_ext M φ _ ρ t
        (fun s => (congrArg ρ.state (add_neg_cancel_right s Δ) :
          ρ.state (s + Δ + -Δ) = ρ.state s))).mp h1
  | ofut φ ih =>
    intro σ t Δ
    constructor
    · intro h ρ hag
      refine (ih ρ t Δ).mp (h (ρ.timeShift Δ) ?_)
      intro u hut
      exact hag (u + Δ) ((add_le_add_iff_right Δ).mpr hut)
    · intro h ρ hag
      have hag' : AgreeUpTo σ (ρ.timeShift (-Δ)) (t + Δ) := by
        intro u hu
        have hle : u + -Δ ≤ t := by
          rw [← sub_eq_add_neg]; exact sub_le_iff_le_add.mpr hu
        have key := hag (u + -Δ) hle
        rw [WorldHistory.timeShift_state, neg_add_cancel_right] at key
        rw [WorldHistory.timeShift_state]
        exact key
      have h1 := (ih (ρ.timeShift (-Δ)) t Δ).mpr (h (ρ.timeShift (-Δ)) hag')
      exact (openTruthAt_congr_ext M φ _ ρ t
        (fun s => (congrArg ρ.state (add_neg_cancel_right s Δ) :
          ρ.state (s + Δ + -Δ) = ρ.state s))).mp h1
  | opast φ ih =>
    intro σ t Δ
    constructor
    · intro h ρ hag
      refine (ih ρ t Δ).mp (h (ρ.timeShift Δ) ?_)
      intro u htu
      exact hag (u + Δ) ((add_le_add_iff_right Δ).mpr htu)
    · intro h ρ hag
      have hag' : AgreeFrom σ (ρ.timeShift (-Δ)) (t + Δ) := by
        intro u hu
        have hle : t ≤ u + -Δ := by
          rw [← sub_eq_add_neg]; exact le_sub_iff_add_le.mpr hu
        have key := hag (u + -Δ) hle
        rw [WorldHistory.timeShift_state, neg_add_cancel_right] at key
        rw [WorldHistory.timeShift_state]
        exact key
      have h1 := (ih (ρ.timeShift (-Δ)) t Δ).mpr (h (ρ.timeShift (-Δ)) hag')
      exact (openTruthAt_congr_ext M φ _ ρ t
        (fun s => (congrArg ρ.state (add_neg_cancel_right s Δ) :
          ρ.state (s + Δ + -Δ) = ρ.state s))).mp h1

/-! ## The propositional block, per constructor

The four Layer-1 schemata of `OpenAxiom`. Each is a **one-line delegation** to the correspondingly
named `generic_*` lemma of `Metalogic/SoundnessLemmas/GenericSchemata.lean`, which states each TM⁺
mirror schema once over the `TruthEnv`/`StabClauses` clause interface; the same holds of every
mirror block below. Names, statements and attributes are unchanged — only the bodies are. The
delegation is statement-preserving because `OpenFormula`'s derived-operator `def`s coincide
definitionally with the clause layer's `abbrev`s, pinned by the `rfl` bridges in
`Tests/BimodalTest/Semantics/ValidityLayerTest.lean`.

**No atomization and no uniform substitution, here or anywhere below (R7).** The atomization route
of `Conservativity/Plus/Atomization.lean` rests on `stab_state_only` — `⊡φ`'s truth value at
`(τ, t)` is fixed by the world state `τ(t)` alone — and `▷χ` is *not* state-local: two histories
sharing a state at `t` need not agree up to `t`, so no L^▷ analogue of `stab_state_only` exists and
the atomization route is unavailable. Uniform substitution is independently unsound over TM⁺, whose
`atom_stab` schema (`p → ⊡p`, atoms only) is false at a general substitution instance. Every arm
below therefore rests on the generic clause-level statement, never on atomization or
substitution, and the shortcut is not to be re-attempted. **That unavailability is why the generic
layer exists**: the shared statement had to be made somewhere, and the clause interface is where it
can be made once for L⁺, L⋆ and L^▷ together instead of transcribed three times. -/

/-- Propositional K over L^▷. -/
theorem openValidIn_propK (φ ψ χ : OpenFormula) :
    OpenValid ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_prop_k (L := OpenFormula) M τ t PUnit.unit φ ψ χ

/-- Propositional S (weakening) over L^▷. -/
theorem openValidIn_propS (φ ψ : OpenFormula) : OpenValid (φ.imp (ψ.imp φ)) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_prop_s (L := OpenFormula) M τ t PUnit.unit φ ψ

/-- Ex Falso Quodlibet over L^▷. -/
theorem openValidIn_exFalso (φ : OpenFormula) : OpenValid (OpenFormula.bot.imp φ) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_ex_falso (L := OpenFormula) M τ t PUnit.unit φ

/-- Peirce's Law over L^▷, by classical case analysis on `φ`. -/
theorem openValidIn_peirce (φ ψ : OpenFormula) :
    OpenValid (((φ.imp ψ).imp φ).imp φ) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_peirce (L := OpenFormula) M τ t PUnit.unit φ ψ

/-! ## The S5-modal block, per constructor

The five Layer-2 schemata plus `modal_future`, the one Layer-4 interaction schema. `□` quantifies
over *all* world histories at the fixed time of evaluation, so T, 4, B, the 5-collapse and K are
each one step from that clause; `modal_future` is the only one that moves the time, and it consumes
`openTruthAt_timeShift` above. -/

/-- Modal T over L^▷: the evaluation history is itself a world history, so `□` reflects. -/
theorem openValidIn_modalT (φ : OpenFormula) : OpenValid ((OpenFormula.box φ).imp φ) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_modal_t (L := OpenFormula) M τ t PUnit.unit φ

/-- Modal 4 over L^▷: the `box` clause quantifies over all world histories, so it is
idempotent. -/
theorem openValidIn_modal4 (φ : OpenFormula) :
    OpenValid ((OpenFormula.box φ).imp (OpenFormula.box (OpenFormula.box φ))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_modal_4 (L := OpenFormula) M τ t PUnit.unit φ

/-- Modal B over L^▷. -/
theorem openValidIn_modalB (φ : OpenFormula) :
    OpenValid (φ.imp (OpenFormula.box φ.diamond)) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_modal_b (L := OpenFormula) M τ t PUnit.unit φ

/-- Modal 5 Collapse over L^▷. -/
theorem openValidIn_modal5Collapse (φ : OpenFormula) :
    OpenValid (φ.box.diamond.imp φ.box) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_modal_5_collapse (L := OpenFormula) M τ t PUnit.unit φ

/-- Modal K distribution over L^▷. -/
theorem openValidIn_modalKDist (φ ψ : OpenFormula) :
    OpenValid ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_modal_k_dist (L := OpenFormula) M τ t PUnit.unit φ ψ

/-- **MF at every `OpenFormula`**: `□φ → □Gφ`. The argument is the L⁺ one, with
`openTruthAt_timeShift` supplying homogeneity: `□φ` holds of the shifted history
`σ.timeShift (s - t)` at `t`, which is `φ` at `σ` at time `s`. -/
theorem openValidIn_modalFuture (φ : OpenFormula) :
    OpenValid ((OpenFormula.box φ).imp (OpenFormula.box (OpenFormula.allFuture φ))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_modal_future (L := OpenFormula) M τ t PUnit.unit φ fun σ s hts h => by
      have h1 := h (σ.timeShift (s - t))
      have h2 := (openTruthAt_timeShift M φ σ t (s - t)).mp h1
      rw [add_sub_cancel] at h2
      exact h2

/-! ### The reflection halves

Every schema of the two blocks above is valid at the unconstrained class, and every one of them is
closed under `reflectTime` up to its own metavariables — `reflectTime` commutes with `imp`, `box`
and `diamond`, and sends `Gφ` to `Hφ`, which is again the `modal_future` schema at the reflected
parameters. So each reflection half is one line through `openValid_reflectTime`, exactly as in the
restricted-modal block. -/

/-- The reflection of propositional K is valid. -/
theorem openValidIn_propK_reflect (φ ψ χ : OpenFormula) :
    OpenValid ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_propK φ ψ χ)

/-- The reflection of propositional S is valid. -/
theorem openValidIn_propS_reflect (φ ψ : OpenFormula) :
    OpenValid (φ.imp (ψ.imp φ)).reflectTime :=
  openValid_reflectTime _ (openValidIn_propS φ ψ)

/-- The reflection of Ex Falso Quodlibet is valid. -/
theorem openValidIn_exFalso_reflect (φ : OpenFormula) :
    OpenValid (OpenFormula.bot.imp φ).reflectTime :=
  openValid_reflectTime _ (openValidIn_exFalso φ)

/-- The reflection of Peirce's Law is valid. -/
theorem openValidIn_peirce_reflect (φ ψ : OpenFormula) :
    OpenValid (((φ.imp ψ).imp φ).imp φ).reflectTime :=
  openValid_reflectTime _ (openValidIn_peirce φ ψ)

/-- The reflection of Modal T is valid. -/
theorem openValidIn_modalT_reflect (φ : OpenFormula) :
    OpenValid ((OpenFormula.box φ).imp φ).reflectTime :=
  openValid_reflectTime _ (openValidIn_modalT φ)

/-- The reflection of Modal 4 is valid. -/
theorem openValidIn_modal4_reflect (φ : OpenFormula) :
    OpenValid ((OpenFormula.box φ).imp (OpenFormula.box (OpenFormula.box φ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_modal4 φ)

/-- The reflection of Modal B is valid. -/
theorem openValidIn_modalB_reflect (φ : OpenFormula) :
    OpenValid (φ.imp (OpenFormula.box φ.diamond)).reflectTime :=
  openValid_reflectTime _ (openValidIn_modalB φ)

/-- The reflection of the Modal 5 Collapse is valid. -/
theorem openValidIn_modal5Collapse_reflect (φ : OpenFormula) :
    OpenValid (φ.box.diamond.imp φ.box).reflectTime :=
  openValid_reflectTime _ (openValidIn_modal5Collapse φ)

/-- The reflection of Modal K distribution is valid. -/
theorem openValidIn_modalKDist_reflect (φ ψ : OpenFormula) :
    OpenValid ((φ.imp ψ).box.imp (φ.box.imp ψ.box)).reflectTime :=
  openValid_reflectTime _ (openValidIn_modalKDist φ ψ)

/-- The reflection of MF is valid: it is `□φ⁻ → □Hφ⁻` at the reflected parameter. -/
theorem openValidIn_modalFuture_reflect (φ : OpenFormula) :
    OpenValid ((OpenFormula.box φ).imp
      (OpenFormula.box (OpenFormula.allFuture φ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_modalFuture φ)

/-! ## The propositional and modal block aggregates

**Constructors covered by `openAxiomValidIn_propBlock`** (four, in `OpenAxiom` constructor order):
`prop_k`, `prop_s`, `ex_falso`, `peirce`.

**Constructors covered by `openAxiomValidIn_modalBlock`** (six, in `OpenAxiom` constructor order):
`modal_t`, `modal_4`, `modal_b`, `modal_5_collapse`, `modal_k_dist`, `modal_future`. The sixth is
`OpenAxiom`'s one Layer-4 constructor and is grouped here because its proof is a modal one; the
Layer-3 temporal constructors between them in the inductive are Phases 8-10's. -/

/-- **The propositional validity block**: `prop_k`, `prop_s`, `ex_falso`, `peirce`. -/
theorem openAxiomValidIn_propBlock :
    (∀ φ ψ χ : OpenFormula,
      OpenValid ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))) ∧
    (∀ φ ψ : OpenFormula, OpenValid (φ.imp (ψ.imp φ))) ∧
    (∀ φ : OpenFormula, OpenValid (OpenFormula.bot.imp φ)) ∧
    (∀ φ ψ : OpenFormula, OpenValid (((φ.imp ψ).imp φ).imp φ)) :=
  ⟨openValidIn_propK, openValidIn_propS, openValidIn_exFalso, openValidIn_peirce⟩

/-- **The propositional reflection block**, same four schemata in the same order. -/
theorem openAxiomReflectValidIn_propBlock :
    (∀ φ ψ χ : OpenFormula,
      OpenValid ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))).reflectTime) ∧
    (∀ φ ψ : OpenFormula, OpenValid (φ.imp (ψ.imp φ)).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid (OpenFormula.bot.imp φ).reflectTime) ∧
    (∀ φ ψ : OpenFormula, OpenValid (((φ.imp ψ).imp φ).imp φ).reflectTime) :=
  ⟨openValidIn_propK_reflect, openValidIn_propS_reflect, openValidIn_exFalso_reflect,
    openValidIn_peirce_reflect⟩

/-- **The S5-modal validity block**: `modal_t`, `modal_4`, `modal_b`, `modal_5_collapse`,
`modal_k_dist`, `modal_future`. -/
theorem openAxiomValidIn_modalBlock :
    (∀ φ : OpenFormula, OpenValid ((OpenFormula.box φ).imp φ)) ∧
    (∀ φ : OpenFormula,
      OpenValid ((OpenFormula.box φ).imp (OpenFormula.box (OpenFormula.box φ)))) ∧
    (∀ φ : OpenFormula, OpenValid (φ.imp (OpenFormula.box φ.diamond))) ∧
    (∀ φ : OpenFormula, OpenValid (φ.box.diamond.imp φ.box)) ∧
    (∀ φ ψ : OpenFormula, OpenValid ((φ.imp ψ).box.imp (φ.box.imp ψ.box))) ∧
    (∀ φ : OpenFormula,
      OpenValid ((OpenFormula.box φ).imp (OpenFormula.box (OpenFormula.allFuture φ)))) :=
  ⟨openValidIn_modalT, openValidIn_modal4, openValidIn_modalB, openValidIn_modal5Collapse,
    openValidIn_modalKDist, openValidIn_modalFuture⟩

/-- **The S5-modal reflection block**, same six schemata in the same order. -/
theorem openAxiomReflectValidIn_modalBlock :
    (∀ φ : OpenFormula, OpenValid ((OpenFormula.box φ).imp φ).reflectTime) ∧
    (∀ φ : OpenFormula,
      OpenValid ((OpenFormula.box φ).imp
        (OpenFormula.box (OpenFormula.box φ))).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid (φ.imp (OpenFormula.box φ.diamond)).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid (φ.box.diamond.imp φ.box).reflectTime) ∧
    (∀ φ ψ : OpenFormula,
      OpenValid ((φ.imp ψ).box.imp (φ.box.imp ψ.box)).reflectTime) ∧
    (∀ φ : OpenFormula,
      OpenValid ((OpenFormula.box φ).imp
        (OpenFormula.box (OpenFormula.allFuture φ))).reflectTime) :=
  ⟨openValidIn_modalT_reflect, openValidIn_modal4_reflect, openValidIn_modalB_reflect,
    openValidIn_modal5Collapse_reflect, openValidIn_modalKDist_reflect,
    openValidIn_modalFuture_reflect⟩

/-! ## The temporal monotonicity and connection block, per constructor

The seriality, left/right monotonicity and connection schemata of Layer 3, each delegating to the
generic layer. The two seriality schemata are closed formulas whose content is seriality of the
*temporal order* (`exists_gt` / `exists_lt` on `F.Duration`), which is what
`generic_serial_future` and `generic_serial_past` state — so no `ofPlus` transport is involved on
either side.

As throughout this file: no atomization, no uniform substitution (see the propositional block's
note). -/

/-- Serial future over L^▷: `F(⊤)`, from forward seriality of the duration order. -/
theorem openValidIn_serialFuture :
    OpenValid (OpenFormula.someFuture (OpenFormula.bot.imp OpenFormula.bot)) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_serial_future (L := OpenFormula) M τ t PUnit.unit

/-- Serial past over L^▷: `⊤ → P(⊤)`, from backward seriality. -/
theorem openValidIn_serialPast :
    OpenValid ((OpenFormula.bot.imp OpenFormula.bot).imp
      (OpenFormula.somePast (OpenFormula.bot.imp OpenFormula.bot))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_serial_past (L := OpenFormula) M τ t PUnit.unit

/-- BX2G over L^▷: the guard of an `until` may be weakened under `G`. -/
theorem openValidIn_leftMonoUntilG (φ χ ψ : OpenFormula) :
    OpenValid ((φ.imp χ).allFuture.imp
      ((OpenFormula.untl φ ψ).imp (OpenFormula.untl χ ψ))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_left_mono_until_G (L := OpenFormula) M τ t PUnit.unit φ χ ψ

/-- BX2H over L^▷, the past mirror of `openValidIn_leftMonoUntilG`. -/
theorem openValidIn_leftMonoSinceH (φ χ ψ : OpenFormula) :
    OpenValid ((φ.imp χ).allPast.imp
      ((OpenFormula.snce φ ψ).imp (OpenFormula.snce χ ψ))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_left_mono_since_H (L := OpenFormula) M τ t PUnit.unit φ χ ψ

/-- BX3 over L^▷: the event of an `until` may be weakened under `G`. -/
theorem openValidIn_rightMonoUntil (φ ψ χ : OpenFormula) :
    OpenValid ((φ.imp ψ).allFuture.imp
      ((OpenFormula.untl χ φ).imp (OpenFormula.untl χ ψ))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_right_mono_until (L := OpenFormula) M τ t PUnit.unit φ ψ χ

/-- BX3' over L^▷, the past mirror of `openValidIn_rightMonoUntil`. -/
theorem openValidIn_rightMonoSince (φ ψ χ : OpenFormula) :
    OpenValid ((φ.imp ψ).allPast.imp
      ((OpenFormula.snce χ φ).imp (OpenFormula.snce χ ψ))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_right_mono_since (L := OpenFormula) M τ t PUnit.unit φ ψ χ

/-- BX4 over L^▷: what is true now is always going to have been true. -/
theorem openValidIn_connectFuture (φ : OpenFormula) :
    OpenValid (φ.imp (φ.somePast.allFuture)) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_connect_future (L := OpenFormula) M τ t PUnit.unit φ

/-- BX4' over L^▷, the past mirror of `openValidIn_connectFuture`. -/
theorem openValidIn_connectPast (φ : OpenFormula) :
    OpenValid (φ.imp (φ.someFuture.allPast)) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_connect_past (L := OpenFormula) M τ t PUnit.unit φ

/-! ## The enrichment, self-accumulation and absorption block, per constructor

The heaviest arms of Layer 3. The clause-family `simp only` plus `rintro` plus
`rcases lt_trichotomy` argument each of these needs now lives once in `GenericSchemata.lean`; the
arms here are delegations. -/

/-- BX13 over L^▷ (Burgess A3a). -/
theorem openValidIn_enrichmentUntil (φ ψ p : OpenFormula) :
    OpenValid (OpenFormula.and p (OpenFormula.untl φ ψ) |>.imp
      (OpenFormula.untl φ (OpenFormula.and ψ (OpenFormula.snce φ p)))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_enrichment_until (L := OpenFormula) M τ t PUnit.unit φ ψ p

/-- BX13' over L^▷ (Burgess A3b), the past mirror of `openValidIn_enrichmentUntil`. -/
theorem openValidIn_enrichmentSince (φ ψ p : OpenFormula) :
    OpenValid (OpenFormula.and p (OpenFormula.snce φ ψ) |>.imp
      (OpenFormula.snce φ (OpenFormula.and ψ (OpenFormula.untl φ p)))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_enrichment_since (L := OpenFormula) M τ t PUnit.unit φ ψ p

/-- BX5 over L^▷. -/
theorem openValidIn_selfAccumUntil (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.untl φ ψ).imp
      (OpenFormula.untl (OpenFormula.and φ (OpenFormula.untl φ ψ)) ψ)) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_self_accum_until (L := OpenFormula) M τ t PUnit.unit φ ψ

/-- BX5' over L^▷, the past mirror of `openValidIn_selfAccumUntil`. -/
theorem openValidIn_selfAccumSince (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.snce φ ψ).imp
      (OpenFormula.snce (OpenFormula.and φ (OpenFormula.snce φ ψ)) ψ)) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_self_accum_since (L := OpenFormula) M τ t PUnit.unit φ ψ

/-- BX6 over L^▷. -/
theorem openValidIn_absorbUntil (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.untl φ (OpenFormula.and φ (OpenFormula.untl φ ψ))).imp
      (OpenFormula.untl φ ψ)) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_absorb_until (L := OpenFormula) M τ t PUnit.unit φ ψ

/-- BX6' over L^▷, the past mirror of `openValidIn_absorbUntil`. -/
theorem openValidIn_absorbSince (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.snce φ (OpenFormula.and φ (OpenFormula.snce φ ψ))).imp
      (OpenFormula.snce φ ψ)) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_absorb_since (L := OpenFormula) M τ t PUnit.unit φ ψ

/-! ### The reflection halves

Every schema of the two blocks above sits at `.Base`, so each reflection half is one line through
`openValid_reflectTime`; `reflectTime` exchanges `untl` with `snce` and `G` with `H`, so the image
of each future schema is its own past mirror at the reflected parameters. -/

/-- The reflection of serial future is valid: it is `P(⊤)`. -/
theorem openValidIn_serialFuture_reflect :
    OpenValid (OpenFormula.someFuture (OpenFormula.bot.imp OpenFormula.bot)).reflectTime :=
  openValid_reflectTime _ openValidIn_serialFuture

/-- The reflection of serial past is valid: it is `⊤ → F(⊤)`. -/
theorem openValidIn_serialPast_reflect :
    OpenValid ((OpenFormula.bot.imp OpenFormula.bot).imp
      (OpenFormula.somePast (OpenFormula.bot.imp OpenFormula.bot))).reflectTime :=
  openValid_reflectTime _ openValidIn_serialPast

/-- The reflection of BX2G is valid. -/
theorem openValidIn_leftMonoUntilG_reflect (φ χ ψ : OpenFormula) :
    OpenValid ((φ.imp χ).allFuture.imp
      ((OpenFormula.untl φ ψ).imp (OpenFormula.untl χ ψ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_leftMonoUntilG φ χ ψ)

/-- The reflection of BX2H is valid. -/
theorem openValidIn_leftMonoSinceH_reflect (φ χ ψ : OpenFormula) :
    OpenValid ((φ.imp χ).allPast.imp
      ((OpenFormula.snce φ ψ).imp (OpenFormula.snce χ ψ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_leftMonoSinceH φ χ ψ)

/-- The reflection of BX3 is valid. -/
theorem openValidIn_rightMonoUntil_reflect (φ ψ χ : OpenFormula) :
    OpenValid ((φ.imp ψ).allFuture.imp
      ((OpenFormula.untl χ φ).imp (OpenFormula.untl χ ψ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_rightMonoUntil φ ψ χ)

/-- The reflection of BX3' is valid. -/
theorem openValidIn_rightMonoSince_reflect (φ ψ χ : OpenFormula) :
    OpenValid ((φ.imp ψ).allPast.imp
      ((OpenFormula.snce χ φ).imp (OpenFormula.snce χ ψ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_rightMonoSince φ ψ χ)

/-- The reflection of BX4 is valid. -/
theorem openValidIn_connectFuture_reflect (φ : OpenFormula) :
    OpenValid (φ.imp (φ.somePast.allFuture)).reflectTime :=
  openValid_reflectTime _ (openValidIn_connectFuture φ)

/-- The reflection of BX4' is valid. -/
theorem openValidIn_connectPast_reflect (φ : OpenFormula) :
    OpenValid (φ.imp (φ.someFuture.allPast)).reflectTime :=
  openValid_reflectTime _ (openValidIn_connectPast φ)

/-- The reflection of BX13 is valid. -/
theorem openValidIn_enrichmentUntil_reflect (φ ψ p : OpenFormula) :
    OpenValid (OpenFormula.and p (OpenFormula.untl φ ψ) |>.imp
      (OpenFormula.untl φ (OpenFormula.and ψ (OpenFormula.snce φ p)))).reflectTime :=
  openValid_reflectTime _ (openValidIn_enrichmentUntil φ ψ p)

/-- The reflection of BX13' is valid. -/
theorem openValidIn_enrichmentSince_reflect (φ ψ p : OpenFormula) :
    OpenValid (OpenFormula.and p (OpenFormula.snce φ ψ) |>.imp
      (OpenFormula.snce φ (OpenFormula.and ψ (OpenFormula.untl φ p)))).reflectTime :=
  openValid_reflectTime _ (openValidIn_enrichmentSince φ ψ p)

/-- The reflection of BX5 is valid. -/
theorem openValidIn_selfAccumUntil_reflect (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.untl φ ψ).imp
      (OpenFormula.untl (OpenFormula.and φ (OpenFormula.untl φ ψ)) ψ)).reflectTime :=
  openValid_reflectTime _ (openValidIn_selfAccumUntil φ ψ)

/-- The reflection of BX5' is valid. -/
theorem openValidIn_selfAccumSince_reflect (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.snce φ ψ).imp
      (OpenFormula.snce (OpenFormula.and φ (OpenFormula.snce φ ψ)) ψ)).reflectTime :=
  openValid_reflectTime _ (openValidIn_selfAccumSince φ ψ)

/-- The reflection of BX6 is valid. -/
theorem openValidIn_absorbUntil_reflect (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.untl φ (OpenFormula.and φ (OpenFormula.untl φ ψ))).imp
      (OpenFormula.untl φ ψ)).reflectTime :=
  openValid_reflectTime _ (openValidIn_absorbUntil φ ψ)

/-- The reflection of BX6' is valid. -/
theorem openValidIn_absorbSince_reflect (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.snce φ (OpenFormula.and φ (OpenFormula.snce φ ψ))).imp
      (OpenFormula.snce φ ψ)).reflectTime :=
  openValid_reflectTime _ (openValidIn_absorbSince φ ψ)

/-! ## The temporal monotonicity and accumulation block aggregates

**Constructors covered by `openAxiomValidIn_tempMonoBlock`** (eight, in `OpenAxiom` constructor
order): `serial_future`, `serial_past`, `left_mono_until_G`, `left_mono_since_H`,
`right_mono_until`, `right_mono_since`, `connect_future`, `connect_past`.

**Constructors covered by `openAxiomValidIn_tempAccumBlock`** (six, in `OpenAxiom` constructor
order): `enrichment_until`, `enrichment_since`, `self_accum_until`, `self_accum_since`,
`absorb_until`, `absorb_since`. -/

/-- **The temporal monotonicity and connection validity block**: the eight schemata named in the
section docstring above. -/
theorem openAxiomValidIn_tempMonoBlock :
    OpenValid (OpenFormula.someFuture (OpenFormula.bot.imp OpenFormula.bot)) ∧
    OpenValid ((OpenFormula.bot.imp OpenFormula.bot).imp
      (OpenFormula.somePast (OpenFormula.bot.imp OpenFormula.bot))) ∧
    (∀ φ χ ψ : OpenFormula, OpenValid ((φ.imp χ).allFuture.imp
      ((OpenFormula.untl φ ψ).imp (OpenFormula.untl χ ψ)))) ∧
    (∀ φ χ ψ : OpenFormula, OpenValid ((φ.imp χ).allPast.imp
      ((OpenFormula.snce φ ψ).imp (OpenFormula.snce χ ψ)))) ∧
    (∀ φ ψ χ : OpenFormula, OpenValid ((φ.imp ψ).allFuture.imp
      ((OpenFormula.untl χ φ).imp (OpenFormula.untl χ ψ)))) ∧
    (∀ φ ψ χ : OpenFormula, OpenValid ((φ.imp ψ).allPast.imp
      ((OpenFormula.snce χ φ).imp (OpenFormula.snce χ ψ)))) ∧
    (∀ φ : OpenFormula, OpenValid (φ.imp (φ.somePast.allFuture))) ∧
    (∀ φ : OpenFormula, OpenValid (φ.imp (φ.someFuture.allPast))) :=
  ⟨openValidIn_serialFuture, openValidIn_serialPast, openValidIn_leftMonoUntilG,
    openValidIn_leftMonoSinceH, openValidIn_rightMonoUntil, openValidIn_rightMonoSince,
    openValidIn_connectFuture, openValidIn_connectPast⟩

/-- **The temporal monotonicity and connection reflection block**, same eight schemata in the same
order. -/
theorem openAxiomReflectValidIn_tempMonoBlock :
    OpenValid (OpenFormula.someFuture (OpenFormula.bot.imp OpenFormula.bot)).reflectTime ∧
    OpenValid ((OpenFormula.bot.imp OpenFormula.bot).imp
      (OpenFormula.somePast (OpenFormula.bot.imp OpenFormula.bot))).reflectTime ∧
    (∀ φ χ ψ : OpenFormula, OpenValid ((φ.imp χ).allFuture.imp
      ((OpenFormula.untl φ ψ).imp (OpenFormula.untl χ ψ))).reflectTime) ∧
    (∀ φ χ ψ : OpenFormula, OpenValid ((φ.imp χ).allPast.imp
      ((OpenFormula.snce φ ψ).imp (OpenFormula.snce χ ψ))).reflectTime) ∧
    (∀ φ ψ χ : OpenFormula, OpenValid ((φ.imp ψ).allFuture.imp
      ((OpenFormula.untl χ φ).imp (OpenFormula.untl χ ψ))).reflectTime) ∧
    (∀ φ ψ χ : OpenFormula, OpenValid ((φ.imp ψ).allPast.imp
      ((OpenFormula.snce χ φ).imp (OpenFormula.snce χ ψ))).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid (φ.imp (φ.somePast.allFuture)).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid (φ.imp (φ.someFuture.allPast)).reflectTime) :=
  ⟨openValidIn_serialFuture_reflect, openValidIn_serialPast_reflect,
    openValidIn_leftMonoUntilG_reflect, openValidIn_leftMonoSinceH_reflect,
    openValidIn_rightMonoUntil_reflect, openValidIn_rightMonoSince_reflect,
    openValidIn_connectFuture_reflect, openValidIn_connectPast_reflect⟩

/-- **The enrichment, self-accumulation and absorption validity block**: the six schemata named in
the section docstring above. -/
theorem openAxiomValidIn_tempAccumBlock :
    (∀ φ ψ p : OpenFormula, OpenValid (OpenFormula.and p (OpenFormula.untl φ ψ) |>.imp
      (OpenFormula.untl φ (OpenFormula.and ψ (OpenFormula.snce φ p))))) ∧
    (∀ φ ψ p : OpenFormula, OpenValid (OpenFormula.and p (OpenFormula.snce φ ψ) |>.imp
      (OpenFormula.snce φ (OpenFormula.and ψ (OpenFormula.untl φ p))))) ∧
    (∀ φ ψ : OpenFormula, OpenValid ((OpenFormula.untl φ ψ).imp
      (OpenFormula.untl (OpenFormula.and φ (OpenFormula.untl φ ψ)) ψ))) ∧
    (∀ φ ψ : OpenFormula, OpenValid ((OpenFormula.snce φ ψ).imp
      (OpenFormula.snce (OpenFormula.and φ (OpenFormula.snce φ ψ)) ψ))) ∧
    (∀ φ ψ : OpenFormula,
      OpenValid ((OpenFormula.untl φ (OpenFormula.and φ (OpenFormula.untl φ ψ))).imp
        (OpenFormula.untl φ ψ))) ∧
    (∀ φ ψ : OpenFormula,
      OpenValid ((OpenFormula.snce φ (OpenFormula.and φ (OpenFormula.snce φ ψ))).imp
        (OpenFormula.snce φ ψ))) :=
  ⟨openValidIn_enrichmentUntil, openValidIn_enrichmentSince, openValidIn_selfAccumUntil,
    openValidIn_selfAccumSince, openValidIn_absorbUntil, openValidIn_absorbSince⟩

/-- **The enrichment, self-accumulation and absorption reflection block**, same six schemata in
the same order. -/
theorem openAxiomReflectValidIn_tempAccumBlock :
    (∀ φ ψ p : OpenFormula, OpenValid (OpenFormula.and p (OpenFormula.untl φ ψ) |>.imp
      (OpenFormula.untl φ (OpenFormula.and ψ (OpenFormula.snce φ p)))).reflectTime) ∧
    (∀ φ ψ p : OpenFormula, OpenValid (OpenFormula.and p (OpenFormula.snce φ ψ) |>.imp
      (OpenFormula.snce φ (OpenFormula.and ψ (OpenFormula.untl φ p)))).reflectTime) ∧
    (∀ φ ψ : OpenFormula, OpenValid ((OpenFormula.untl φ ψ).imp
      (OpenFormula.untl (OpenFormula.and φ (OpenFormula.untl φ ψ)) ψ)).reflectTime) ∧
    (∀ φ ψ : OpenFormula, OpenValid ((OpenFormula.snce φ ψ).imp
      (OpenFormula.snce (OpenFormula.and φ (OpenFormula.snce φ ψ)) ψ)).reflectTime) ∧
    (∀ φ ψ : OpenFormula,
      OpenValid ((OpenFormula.untl φ (OpenFormula.and φ (OpenFormula.untl φ ψ))).imp
        (OpenFormula.untl φ ψ)).reflectTime) ∧
    (∀ φ ψ : OpenFormula,
      OpenValid ((OpenFormula.snce φ (OpenFormula.and φ (OpenFormula.snce φ ψ))).imp
        (OpenFormula.snce φ ψ)).reflectTime) :=
  ⟨openValidIn_enrichmentUntil_reflect, openValidIn_enrichmentSince_reflect,
    openValidIn_selfAccumUntil_reflect, openValidIn_selfAccumSince_reflect,
    openValidIn_absorbUntil_reflect, openValidIn_absorbSince_reflect⟩

/-! ## The linearity block, per constructor

The four linearity schemata of Layer 3 — the paper's CN for `U` and `S` and its `F`/`P` form TL —
each by trichotomy on the two witnesses the antecedent supplies.

**The disjunct nesting is read off `OpenAxiom`, not off the BX numbering.** `linear_until` and
`temp_linearity` carry the paper's **right-associated** disjunction, while `linear_since` and
`temp_linearity_past` carry the **left-associated** one; each of the four statements below
delegates to whichever generic lemma has the matching nesting (`generic_linear_until_paper`,
`generic_linear_since`, `generic_temp_linearity_paper`, `generic_temp_linearity_past`
respectively). The generic layer supplies **all four** variants on purpose, precisely so that no
language's statement is re-associated by the refactor; only the `.inl`/`.inr` routing differs
between them, and that routing now lives once per variant. -/

/-- BX7 / the paper's CN over L^▷: linearity of `until`, right-associated. -/
theorem openValidIn_linearUntil (φ ψ χ θ : OpenFormula) :
    OpenValid (OpenFormula.and (OpenFormula.untl φ ψ) (OpenFormula.untl χ θ)
      |>.imp (OpenFormula.or
        (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and ψ θ))
        (OpenFormula.or
          (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and ψ χ))
          (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and φ θ))))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_linear_until_paper (L := OpenFormula) M τ t PUnit.unit φ ψ χ θ

/-- BX7' over L^▷: linearity of `since`, left-associated. -/
theorem openValidIn_linearSince (φ ψ χ θ : OpenFormula) :
    OpenValid (OpenFormula.and (OpenFormula.snce φ ψ) (OpenFormula.snce χ θ)
      |>.imp (OpenFormula.or
        (OpenFormula.or
          (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and ψ θ))
          (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and ψ χ)))
        (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and φ θ)))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_linear_since (L := OpenFormula) M τ t PUnit.unit φ ψ χ θ

/-- BX11 / the paper's TL over L^▷: two future witnesses are ordered, right-associated. -/
theorem openValidIn_tempLinearity (φ ψ : OpenFormula) :
    OpenValid (OpenFormula.and (OpenFormula.someFuture φ) (OpenFormula.someFuture ψ) |>.imp
      (OpenFormula.or (OpenFormula.someFuture (OpenFormula.and (OpenFormula.someFuture φ) ψ))
        (OpenFormula.or (OpenFormula.someFuture (OpenFormula.and φ ψ))
          (OpenFormula.someFuture (OpenFormula.and φ (OpenFormula.someFuture ψ)))))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_temp_linearity_paper (L := OpenFormula) M τ t PUnit.unit φ ψ

/-- BX11' over L^▷, the past form, left-associated. -/
theorem openValidIn_tempLinearityPast (φ ψ : OpenFormula) :
    OpenValid (OpenFormula.and (OpenFormula.somePast φ) (OpenFormula.somePast ψ) |>.imp
      (OpenFormula.or (OpenFormula.somePast (OpenFormula.and φ ψ))
        (OpenFormula.or (OpenFormula.somePast (OpenFormula.and φ (OpenFormula.somePast ψ)))
          (OpenFormula.somePast (OpenFormula.and (OpenFormula.somePast φ) ψ))))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_temp_linearity_past (L := OpenFormula) M τ t PUnit.unit φ ψ

/-! ## The `F`/`P` equivalence block, per constructor

The four schemata relating `U`/`S` to `F`/`P`: an `until` witness is a future witness (BX10,
BX10'), and `F`/`P` is `U`/`S` at the trivial guard (BX12, BX12'). -/

/-- BX10 over L^▷: an `until` witness is a future witness. -/
theorem openValidIn_untilF (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.untl φ ψ).imp (OpenFormula.someFuture ψ)) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_until_F (L := OpenFormula) M τ t PUnit.unit φ ψ

/-- BX10' over L^▷, the past mirror of `openValidIn_untilF`. -/
theorem openValidIn_sinceP (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.snce φ ψ).imp (OpenFormula.somePast ψ)) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_since_P (L := OpenFormula) M τ t PUnit.unit φ ψ

/-- BX12 over L^▷: `F` is `U` at the trivial guard. -/
theorem openValidIn_FUntilEquiv (φ : OpenFormula) :
    OpenValid ((OpenFormula.someFuture φ).imp
      (OpenFormula.untl (OpenFormula.bot.imp OpenFormula.bot) φ)) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_F_until_equiv (L := OpenFormula) M τ t PUnit.unit φ

/-- BX12' over L^▷, the past mirror of `openValidIn_FUntilEquiv`. -/
theorem openValidIn_PSinceEquiv (φ : OpenFormula) :
    OpenValid ((OpenFormula.somePast φ).imp
      (OpenFormula.snce (OpenFormula.bot.imp OpenFormula.bot) φ)) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_P_since_equiv (L := OpenFormula) M τ t PUnit.unit φ

/-! ### The reflection halves

All eight schemata sit at `.Base`, so each reflection half is one line through
`openValid_reflectTime`. -/

/-- The reflection of BX7 is valid. -/
theorem openValidIn_linearUntil_reflect (φ ψ χ θ : OpenFormula) :
    OpenValid (OpenFormula.and (OpenFormula.untl φ ψ) (OpenFormula.untl χ θ)
      |>.imp (OpenFormula.or
        (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and ψ θ))
        (OpenFormula.or
          (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and ψ χ))
          (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and φ θ))))).reflectTime :=
  openValid_reflectTime _ (openValidIn_linearUntil φ ψ χ θ)

/-- The reflection of BX7' is valid. -/
theorem openValidIn_linearSince_reflect (φ ψ χ θ : OpenFormula) :
    OpenValid (OpenFormula.and (OpenFormula.snce φ ψ) (OpenFormula.snce χ θ)
      |>.imp (OpenFormula.or
        (OpenFormula.or
          (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and ψ θ))
          (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and ψ χ)))
        (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and φ θ)))).reflectTime :=
  openValid_reflectTime _ (openValidIn_linearSince φ ψ χ θ)

/-- The reflection of BX11 is valid. -/
theorem openValidIn_tempLinearity_reflect (φ ψ : OpenFormula) :
    OpenValid (OpenFormula.and (OpenFormula.someFuture φ) (OpenFormula.someFuture ψ) |>.imp
      (OpenFormula.or (OpenFormula.someFuture (OpenFormula.and (OpenFormula.someFuture φ) ψ))
        (OpenFormula.or (OpenFormula.someFuture (OpenFormula.and φ ψ))
          (OpenFormula.someFuture
            (OpenFormula.and φ (OpenFormula.someFuture ψ)))))).reflectTime :=
  openValid_reflectTime _ (openValidIn_tempLinearity φ ψ)

/-- The reflection of BX11' is valid. -/
theorem openValidIn_tempLinearityPast_reflect (φ ψ : OpenFormula) :
    OpenValid (OpenFormula.and (OpenFormula.somePast φ) (OpenFormula.somePast ψ) |>.imp
      (OpenFormula.or (OpenFormula.somePast (OpenFormula.and φ ψ))
        (OpenFormula.or (OpenFormula.somePast (OpenFormula.and φ (OpenFormula.somePast ψ)))
          (OpenFormula.somePast
            (OpenFormula.and (OpenFormula.somePast φ) ψ))))).reflectTime :=
  openValid_reflectTime _ (openValidIn_tempLinearityPast φ ψ)

/-- The reflection of BX10 is valid. -/
theorem openValidIn_untilF_reflect (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.untl φ ψ).imp (OpenFormula.someFuture ψ)).reflectTime :=
  openValid_reflectTime _ (openValidIn_untilF φ ψ)

/-- The reflection of BX10' is valid. -/
theorem openValidIn_sinceP_reflect (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.snce φ ψ).imp (OpenFormula.somePast ψ)).reflectTime :=
  openValid_reflectTime _ (openValidIn_sinceP φ ψ)

/-- The reflection of BX12 is valid. -/
theorem openValidIn_FUntilEquiv_reflect (φ : OpenFormula) :
    OpenValid ((OpenFormula.someFuture φ).imp
      (OpenFormula.untl (OpenFormula.bot.imp OpenFormula.bot) φ)).reflectTime :=
  openValid_reflectTime _ (openValidIn_FUntilEquiv φ)

/-- The reflection of BX12' is valid. -/
theorem openValidIn_PSinceEquiv_reflect (φ : OpenFormula) :
    OpenValid ((OpenFormula.somePast φ).imp
      (OpenFormula.snce (OpenFormula.bot.imp OpenFormula.bot) φ)).reflectTime :=
  openValid_reflectTime _ (openValidIn_PSinceEquiv φ)

/-! ## The linearity and equivalence block aggregates

**Constructors covered by `openAxiomValidIn_linearityBlock`** (four, in `OpenAxiom` constructor
order): `linear_until`, `linear_since`, `temp_linearity`, `temp_linearity_past`.

**Constructors covered by `openAxiomValidIn_tempEquivBlock`** (four, in `OpenAxiom` constructor
order): `until_F`, `since_P`, `F_until_equiv`, `P_since_equiv`.

The two blocks interleave in the inductive — `until_F`/`since_P` sit between `linear_since` and
`temp_linearity` — so neither block is a contiguous run of constructors. Each is nonetheless
internally constructor-ordered. -/

/-- **The linearity validity block**: `linear_until`, `linear_since`, `temp_linearity`,
`temp_linearity_past`. -/
theorem openAxiomValidIn_linearityBlock :
    (∀ φ ψ χ θ : OpenFormula,
      OpenValid (OpenFormula.and (OpenFormula.untl φ ψ) (OpenFormula.untl χ θ)
        |>.imp (OpenFormula.or
          (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and ψ θ))
          (OpenFormula.or
            (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and ψ χ))
            (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and φ θ)))))) ∧
    (∀ φ ψ χ θ : OpenFormula,
      OpenValid (OpenFormula.and (OpenFormula.snce φ ψ) (OpenFormula.snce χ θ)
        |>.imp (OpenFormula.or
          (OpenFormula.or
            (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and ψ θ))
            (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and ψ χ)))
          (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and φ θ))))) ∧
    (∀ φ ψ : OpenFormula,
      OpenValid (OpenFormula.and (OpenFormula.someFuture φ) (OpenFormula.someFuture ψ) |>.imp
        (OpenFormula.or (OpenFormula.someFuture (OpenFormula.and (OpenFormula.someFuture φ) ψ))
          (OpenFormula.or (OpenFormula.someFuture (OpenFormula.and φ ψ))
            (OpenFormula.someFuture (OpenFormula.and φ (OpenFormula.someFuture ψ))))))) ∧
    (∀ φ ψ : OpenFormula,
      OpenValid (OpenFormula.and (OpenFormula.somePast φ) (OpenFormula.somePast ψ) |>.imp
        (OpenFormula.or (OpenFormula.somePast (OpenFormula.and φ ψ))
          (OpenFormula.or (OpenFormula.somePast (OpenFormula.and φ (OpenFormula.somePast ψ)))
            (OpenFormula.somePast (OpenFormula.and (OpenFormula.somePast φ) ψ)))))) :=
  ⟨openValidIn_linearUntil, openValidIn_linearSince, openValidIn_tempLinearity,
    openValidIn_tempLinearityPast⟩

/-- **The linearity reflection block**, same four schemata in the same order. -/
theorem openAxiomReflectValidIn_linearityBlock :
    (∀ φ ψ χ θ : OpenFormula,
      OpenValid (OpenFormula.and (OpenFormula.untl φ ψ) (OpenFormula.untl χ θ)
        |>.imp (OpenFormula.or
          (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and ψ θ))
          (OpenFormula.or
            (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and ψ χ))
            (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and φ θ))))).reflectTime) ∧
    (∀ φ ψ χ θ : OpenFormula,
      OpenValid (OpenFormula.and (OpenFormula.snce φ ψ) (OpenFormula.snce χ θ)
        |>.imp (OpenFormula.or
          (OpenFormula.or
            (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and ψ θ))
            (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and ψ χ)))
          (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and φ θ)))).reflectTime) ∧
    (∀ φ ψ : OpenFormula,
      OpenValid (OpenFormula.and (OpenFormula.someFuture φ) (OpenFormula.someFuture ψ) |>.imp
        (OpenFormula.or (OpenFormula.someFuture (OpenFormula.and (OpenFormula.someFuture φ) ψ))
          (OpenFormula.or (OpenFormula.someFuture (OpenFormula.and φ ψ))
            (OpenFormula.someFuture
              (OpenFormula.and φ (OpenFormula.someFuture ψ)))))).reflectTime) ∧
    (∀ φ ψ : OpenFormula,
      OpenValid (OpenFormula.and (OpenFormula.somePast φ) (OpenFormula.somePast ψ) |>.imp
        (OpenFormula.or (OpenFormula.somePast (OpenFormula.and φ ψ))
          (OpenFormula.or (OpenFormula.somePast (OpenFormula.and φ (OpenFormula.somePast ψ)))
            (OpenFormula.somePast
              (OpenFormula.and (OpenFormula.somePast φ) ψ))))).reflectTime) :=
  ⟨openValidIn_linearUntil_reflect, openValidIn_linearSince_reflect,
    openValidIn_tempLinearity_reflect, openValidIn_tempLinearityPast_reflect⟩

/-- **The `F`/`P` equivalence validity block**: `until_F`, `since_P`, `F_until_equiv`,
`P_since_equiv`. -/
theorem openAxiomValidIn_tempEquivBlock :
    (∀ φ ψ : OpenFormula,
      OpenValid ((OpenFormula.untl φ ψ).imp (OpenFormula.someFuture ψ))) ∧
    (∀ φ ψ : OpenFormula,
      OpenValid ((OpenFormula.snce φ ψ).imp (OpenFormula.somePast ψ))) ∧
    (∀ φ : OpenFormula, OpenValid ((OpenFormula.someFuture φ).imp
      (OpenFormula.untl (OpenFormula.bot.imp OpenFormula.bot) φ))) ∧
    (∀ φ : OpenFormula, OpenValid ((OpenFormula.somePast φ).imp
      (OpenFormula.snce (OpenFormula.bot.imp OpenFormula.bot) φ))) :=
  ⟨openValidIn_untilF, openValidIn_sinceP, openValidIn_FUntilEquiv, openValidIn_PSinceEquiv⟩

/-- **The `F`/`P` equivalence reflection block**, same four schemata in the same order. -/
theorem openAxiomReflectValidIn_tempEquivBlock :
    (∀ φ ψ : OpenFormula,
      OpenValid ((OpenFormula.untl φ ψ).imp (OpenFormula.someFuture ψ)).reflectTime) ∧
    (∀ φ ψ : OpenFormula,
      OpenValid ((OpenFormula.snce φ ψ).imp (OpenFormula.somePast ψ)).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid ((OpenFormula.someFuture φ).imp
      (OpenFormula.untl (OpenFormula.bot.imp OpenFormula.bot) φ)).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid ((OpenFormula.somePast φ).imp
      (OpenFormula.snce (OpenFormula.bot.imp OpenFormula.bot) φ)).reflectTime) :=
  ⟨openValidIn_untilF_reflect, openValidIn_sinceP_reflect, openValidIn_FUntilEquiv_reflect,
    openValidIn_PSinceEquiv_reflect⟩

/-! ## The discrete-uniformity block, per constructor

The five Layer-5 schemata, each a **closed** formula at `.Base`. Each used to transport along
`openValid_ofPlus_iff` from `plusAxiom_validIn_min`; each now delegates to the generic schema
instead.

**The frame-level fact is still proved exactly once, and is still not re-derived here.** What
changed is where that one proof lives. Each of these records a *frame-level* uniformity fact —
that discreteness of the duration order is symmetric, propagates along the order and is modally
necessary — and `Metalogic/SoundnessLemmas/GenericSchemata.lean` now states it once over the
clause interface, with the gap-translation argument in `generic_gap_shift` /
`generic_cogap_shift` / `generic_gap_iff_cogap`. That serves L⁺, L⋆ and L^▷ together, and serves
a language with no `ofPlus` embedding at all, which transport could not. -/

/-- `U(⊤,⊥) → S(⊤,⊥)` over L^▷, by transport. -/
theorem openValidIn_discreteSymmFwd :
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.snce OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_discrete_symm_fwd (L := OpenFormula) M τ t PUnit.unit

/-- `S(⊤,⊥) → U(⊤,⊥)` over L^▷, by transport. -/
theorem openValidIn_discreteSymmBwd :
    OpenValid ((OpenFormula.snce OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_discrete_symm_bwd (L := OpenFormula) M τ t PUnit.unit

/-- `U(⊤,⊥) → G(U(⊤,⊥))` over L^▷, by transport. -/
theorem openValidIn_discretePropagateFwd :
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.allFuture
        (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_discrete_propagate_fwd (L := OpenFormula) M τ t PUnit.unit

/-- `U(⊤,⊥) → H(U(⊤,⊥))` over L^▷, by transport. -/
theorem openValidIn_discretePropagateBwd :
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.allPast
        (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_discrete_propagate_bwd (L := OpenFormula) M τ t PUnit.unit

/-- `U(⊤,⊥) → □(U(⊤,⊥))` over L^▷, by transport. -/
theorem openValidIn_discreteBoxNecessity :
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.box
        (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_discrete_box_necessity (L := OpenFormula) M τ t PUnit.unit

/-! ### The discrete reflection halves

All five sit at `.Base`, so each is one line through `openValid_reflectTime`. Note that the group
is **not** closed under `reflectTime`: the dual of `U(⊤,⊥) → G(U(⊤,⊥))` is
`S(⊤,⊥) → H(S(⊤,⊥))`, which is no member's statement. That costs nothing here, because
`openValid_reflectTime` produces the reflected statement whatever it is; it is recorded because
`Conservativity/Star/StarAxiomValidity.lean` has to name those duals explicitly, and a reader
comparing the two files will look for them. -/

/-- The reflection of `discrete_symm_fwd` is valid. -/
theorem openValidIn_discreteSymmFwd_reflect :
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.snce OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot))).reflectTime :=
  openValid_reflectTime _ openValidIn_discreteSymmFwd

/-- The reflection of `discrete_symm_bwd` is valid. -/
theorem openValidIn_discreteSymmBwd_reflect :
    OpenValid ((OpenFormula.snce OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot))).reflectTime :=
  openValid_reflectTime _ openValidIn_discreteSymmBwd

/-- The reflection of `discrete_propagate_fwd` is valid: `S(⊤,⊥) → H(S(⊤,⊥))`. -/
theorem openValidIn_discretePropagateFwd_reflect :
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.allFuture
        (OpenFormula.untl OpenFormula.bot
          (OpenFormula.bot.imp OpenFormula.bot)))).reflectTime :=
  openValid_reflectTime _ openValidIn_discretePropagateFwd

/-- The reflection of `discrete_propagate_bwd` is valid: `S(⊤,⊥) → G(S(⊤,⊥))`. -/
theorem openValidIn_discretePropagateBwd_reflect :
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.allPast
        (OpenFormula.untl OpenFormula.bot
          (OpenFormula.bot.imp OpenFormula.bot)))).reflectTime :=
  openValid_reflectTime _ openValidIn_discretePropagateBwd

/-- The reflection of `discrete_box_necessity` is valid: `S(⊤,⊥) → □(S(⊤,⊥))`. -/
theorem openValidIn_discreteBoxNecessity_reflect :
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.box
        (OpenFormula.untl OpenFormula.bot
          (OpenFormula.bot.imp OpenFormula.bot)))).reflectTime :=
  openValid_reflectTime _ openValidIn_discreteBoxNecessity

/-! ## The Prior and Dedekind block, per constructor

`prior_UZ`, `prior_SZ` and `z1` at `.ZTime`; `prior_U_gap`, `prior_S_gap` and `sep` at `.RTime`.
Each is stated at **the class its own `minFrameClass` arm names**, never at `.Base`.

The order-theoretic content is **not** inlined: the two Prior arms consume
`SoundnessLemmas.DiscreteOrder`'s `exists_nearest_gt` / `exists_nearest_lt`, `z1` its
`forall_gt_of_succ_step` / `forall_lt_of_pred_step`, the two gap arms the frame class's own
least-upper-bound property, and `sep` the whole of `SoundnessLemmas.Separability`'s `sep_order`,
each at the predicate `fun x => OpenTruthAt M τ x φ`. Nothing about `OpenFormula` enters those
lemmas.

**These six cannot use `openValid_reflectTime`**, which is stated at the unconstrained class only
(`OpenLanguage/OpenReversal.lean`). The four with a past twin among the schemata route to that
twin at the reflected parameter; `z1` and `sep` have no twin and their duals are proved here. -/

/-- Prior-UZ over L^▷ at `.ZTime`: the nearest `φ`-point above `t` witnesses `U(¬φ, φ)`. -/
theorem openValidIn_priorUZ (φ : OpenFormula) :
    OpenValidIn FrameClass.ZTime (φ.someFuture.imp (OpenFormula.untl φ.neg φ)) := by
  refine fun F hF M τ t => ?_
  sat_intro hF
  exact generic_prior_UZ (L := OpenFormula) M τ t PUnit.unit φ

/-- Prior-SZ over L^▷ at `.ZTime`, the past dual — through `exists_nearest_lt`, which is itself
`exists_nearest_gt` at `Dᵒᵈ`. The dualisation is of the *carrier*, never of the formula. -/
theorem openValidIn_priorSZ (φ : OpenFormula) :
    OpenValidIn FrameClass.ZTime (φ.somePast.imp (OpenFormula.snce φ.neg φ)) := by
  refine fun F hF M τ t => ?_
  sat_intro hF
  exact generic_prior_SZ (L := OpenFormula) M τ t PUnit.unit φ

/-- Z1 over L^▷ at `.ZTime`, through `forall_gt_of_succ_step`. -/
theorem openValidIn_z1 (φ : OpenFormula) :
    OpenValidIn FrameClass.ZTime ((φ.allFuture.imp φ).allFuture.imp
      (φ.allFuture.someFuture.imp φ.allFuture)) := by
  refine fun F hF M τ t => ?_
  sat_intro hF
  exact generic_z1 (L := OpenFormula) M τ t PUnit.unit φ

/-- The temporal dual of `openValidIn_z1`, through `forall_lt_of_pred_step`. Z1 has no past twin
among the schemata, so this dual is named here. -/
theorem openValidIn_z1_reflectDual (φ : OpenFormula) :
    OpenValidIn FrameClass.ZTime ((φ.allPast.imp φ).allPast.imp
      (φ.allPast.somePast.imp φ.allPast)) := by
  refine fun F hF M τ t => ?_
  sat_intro hF
  exact generic_z1_reflect_time (L := OpenFormula) M τ t PUnit.unit φ

/-- Prior-U (gap form) over L^▷ at `.RTime`. The least upper bound of the set of times whose whole
open past back to `t` satisfies `φ` is the gap point. -/
theorem openValidIn_priorUGap (φ : OpenFormula) :
    OpenValidIn FrameClass.RTime
      ((OpenFormula.and (OpenFormula.untl φ OpenFormula.top) φ.neg.someFuture).imp
        (OpenFormula.untl φ (OpenFormula.or φ.neg (OpenFormula.kPlus φ.neg)))) := by
  refine fun F h_lub M τ t => ?_
  sat_intro h_lub
  exact generic_prior_U_gap (L := OpenFormula) M τ t PUnit.unit φ h_lub

/-- Prior-S (gap form) over L^▷ at `.RTime`, the past dual — through
`SoundnessLemmas.exists_isGLB_of_lub`, so the least-upper-bound hypothesis is used once and the
greatest lower bound is derived rather than assumed. -/
theorem openValidIn_priorSGap (φ : OpenFormula) :
    OpenValidIn FrameClass.RTime
      ((OpenFormula.and (OpenFormula.snce φ OpenFormula.top) φ.neg.somePast).imp
        (OpenFormula.snce φ (OpenFormula.or φ.neg (OpenFormula.kMinus φ.neg)))) := by
  refine fun F h_lub M τ t => ?_
  sat_intro h_lub
  exact generic_prior_S_gap (L := OpenFormula) M τ t PUnit.unit φ h_lub

/-- **Sep over L^▷ at `.RTime`.** The order-theoretic core is `SoundnessLemmas.sep_order`,
consumed unchanged at `P := {u | OpenTruthAt M τ u φ}`; nothing about `OpenFormula` enters it. -/
theorem openValidIn_sep (φ : OpenFormula) :
    OpenValidIn FrameClass.RTime
      ((OpenFormula.and (OpenFormula.kPlus φ)
        (OpenFormula.kPlus (OpenFormula.and φ (OpenFormula.untl φ.neg φ))).neg).imp
        (OpenFormula.kPlus
          (OpenFormula.and (OpenFormula.kPlus φ) (OpenFormula.kMinus φ)))) := by
  refine fun F h_lub M τ t => ?_
  sat_intro h_lub
  exact generic_sep (L := OpenFormula) M τ t PUnit.unit φ h_lub

/-- **The temporal dual of Sep**, at `.RTime`. Sep has no past twin among the schemata, so the
dual is named here; the order-theoretic core is `SoundnessLemmas.sep_order_mirror`, which is
`sep_order` instantiated at `Dᵒᵈ`. -/
theorem openValidIn_sep_reflect (φ : OpenFormula) :
    OpenValidIn FrameClass.RTime
      (((OpenFormula.and (OpenFormula.kPlus φ)
        (OpenFormula.kPlus (OpenFormula.and φ (OpenFormula.untl φ.neg φ))).neg).imp
        (OpenFormula.kPlus
          (OpenFormula.and (OpenFormula.kPlus φ)
            (OpenFormula.kMinus φ)))).reflectTime) := by
  refine fun F h_lub M τ t => ?_
  sat_intro h_lub
  exact generic_sep_reflect_time (L := OpenFormula) M τ t PUnit.unit φ.reflectTime h_lub

/-! ### The Prior and Dedekind reflection halves

Four of the six route to their past twin at the reflected parameter; `z1` and `sep` route to the
duals named above. None can use `openValid_reflectTime`. -/

/-- The reflection of Prior-UZ is Prior-SZ at the reflected parameter. -/
theorem openValidIn_priorUZ_reflect (φ : OpenFormula) :
    OpenValidIn FrameClass.ZTime (φ.someFuture.imp (OpenFormula.untl φ.neg φ)).reflectTime :=
  openValidIn_priorSZ φ.reflectTime

/-- The reflection of Prior-SZ is Prior-UZ at the reflected parameter. -/
theorem openValidIn_priorSZ_reflect (φ : OpenFormula) :
    OpenValidIn FrameClass.ZTime (φ.somePast.imp (OpenFormula.snce φ.neg φ)).reflectTime :=
  openValidIn_priorUZ φ.reflectTime

/-- The reflection of Z1 is its named dual at the reflected parameter. -/
theorem openValidIn_z1_reflect (φ : OpenFormula) :
    OpenValidIn FrameClass.ZTime (((φ.allFuture.imp φ).allFuture.imp
      (φ.allFuture.someFuture.imp φ.allFuture))).reflectTime :=
  openValidIn_z1_reflectDual φ.reflectTime

/-- The reflection of Prior-U (gap form) is Prior-S (gap form) at the reflected parameter. -/
theorem openValidIn_priorUGap_reflect (φ : OpenFormula) :
    OpenValidIn FrameClass.RTime
      (((OpenFormula.and (OpenFormula.untl φ OpenFormula.top) φ.neg.someFuture).imp
        (OpenFormula.untl φ
          (OpenFormula.or φ.neg (OpenFormula.kPlus φ.neg)))).reflectTime) :=
  openValidIn_priorSGap φ.reflectTime

/-- The reflection of Prior-S (gap form) is Prior-U (gap form) at the reflected parameter. -/
theorem openValidIn_priorSGap_reflect (φ : OpenFormula) :
    OpenValidIn FrameClass.RTime
      (((OpenFormula.and (OpenFormula.snce φ OpenFormula.top) φ.neg.somePast).imp
        (OpenFormula.snce φ
          (OpenFormula.or φ.neg (OpenFormula.kMinus φ.neg)))).reflectTime) :=
  openValidIn_priorUGap φ.reflectTime

/-! ## The density block, per constructor

`density` and `dense_indicator`, both at `.Dense`. Neither has a past twin among the schemata, so
both reflection halves are proved directly at `.Dense` rather than routed. -/

/-- Density over L^▷ at `.Dense`: `GGφ → Gφ`. -/
theorem openValidIn_density (φ : OpenFormula) :
    OpenValidIn FrameClass.Dense ((φ.allFuture.allFuture).imp φ.allFuture) := by
  refine fun F h_dense M τ t => ?_
  sat_intro h_dense
  exact generic_density (L := OpenFormula) M τ t PUnit.unit φ

/-- The temporal dual of `openValidIn_density`: `HHφ → Hφ`, again at `.Dense`. -/
theorem openValidIn_density_reflectDual (φ : OpenFormula) :
    OpenValidIn FrameClass.Dense ((φ.allPast.allPast).imp φ.allPast) := by
  refine fun F h_dense M τ t => ?_
  sat_intro h_dense
  exact generic_density_reflect_time (L := OpenFormula) M τ t PUnit.unit φ

/-- The dense indicator over L^▷ at `.Dense`: `¬U(⊤,⊥)`. A witness `s > t` with no point strictly
between contradicts density. -/
theorem openValidIn_denseIndicator :
    OpenValidIn FrameClass.Dense
      (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).neg := by
  refine fun F h_dense M τ t => ?_
  sat_intro h_dense
  exact generic_dense_indicator (L := OpenFormula) M τ t PUnit.unit

/-- The temporal dual of the dense indicator: `¬S(⊤,⊥)`, again at `.Dense`. -/
theorem openValidIn_denseIndicator_reflectDual :
    OpenValidIn FrameClass.Dense
      (OpenFormula.snce OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).neg := by
  refine fun F h_dense M τ t => ?_
  sat_intro h_dense
  exact generic_dense_indicator_reflect_time (L := OpenFormula) M τ t PUnit.unit

/-- The reflection of density is its named dual at the reflected parameter. -/
theorem openValidIn_density_reflect (φ : OpenFormula) :
    OpenValidIn FrameClass.Dense ((φ.allFuture.allFuture).imp φ.allFuture).reflectTime :=
  openValidIn_density_reflectDual φ.reflectTime

/-- The reflection of the dense indicator is its named dual. -/
theorem openValidIn_denseIndicator_reflect :
    OpenValidIn FrameClass.Dense
      (OpenFormula.untl OpenFormula.bot
        (OpenFormula.bot.imp OpenFormula.bot)).neg.reflectTime :=
  openValidIn_denseIndicator_reflectDual

/-! ## The stability-modal block, per constructor

The six `⊡` schemata of the TM⁺ mirror block, all at `.Base`. `stab_of_box` of the
restricted-modal block states the same schema as `box_stab` here; both are kept, so that each
block is self-contained and the mirror block is constructor-for-constructor with `PlusAxiom`. -/

/-- SK over L^▷: K for `⊡`, from the universal-quantifier shape of the `stab` clause. -/
theorem openValidIn_stabK (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.stab (φ.imp ψ)).imp
      ((OpenFormula.stab φ).imp (OpenFormula.stab ψ))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_stab_k (L := OpenFormula) M τ t PUnit.unit φ ψ

/-- ST over L^▷: state equality is reflexive. -/
theorem openValidIn_stabT (φ : OpenFormula) :
    OpenValid ((OpenFormula.stab φ).imp φ) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_stab_t (L := OpenFormula) M τ t PUnit.unit φ

/-- S4 for `⊡` over L^▷: state equality at a fixed time is transitive. -/
theorem openValidIn_stab4 (φ : OpenFormula) :
    OpenValid ((OpenFormula.stab φ).imp (OpenFormula.stab (OpenFormula.stab φ))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_stab_4 (L := OpenFormula) M τ t PUnit.unit φ

/-- S5 for `⊡` over L^▷: state equality at a fixed time is symmetric. -/
theorem openValidIn_stab5 (φ : OpenFormula) :
    OpenValid ((dstab φ).imp (OpenFormula.stab (dstab φ))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_stab_5 (L := OpenFormula) M τ t PUnit.unit φ

/-- MS over L^▷: `⟨τ⟩_x ⊆ H_F`, so `□` is stronger than `⊡`. -/
theorem openValidIn_boxStab (φ : OpenFormula) :
    OpenValid ((OpenFormula.box φ).imp (OpenFormula.stab φ)) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_box_stab (L := OpenFormula) M τ t PUnit.unit φ

/-- AS over L^▷: the atom clause reads the world state alone, which the `stab` clause fixes. The
schema stays atom-restricted — widening it would change TM⁺ — though its semantic witness is the
whole state-locality fragment. -/
theorem openValidIn_atomStab (p : Atom) :
    OpenValid ((OpenFormula.atom p).imp (OpenFormula.stab (OpenFormula.atom p))) :=
  OpenValid.of_forall fun _ M τ t =>
    generic_atom_stab (L := OpenFormula) M τ t PUnit.unit p

/-! ### The stability reflection halves

`reflectTime` fixes `⊡` and `⟐`, so each image is its own schema at the reflected parameter; all
six are nonetheless one line through `openValid_reflectTime`. -/

/-- The reflection of SK is valid. -/
theorem openValidIn_stabK_reflect (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.stab (φ.imp ψ)).imp
      ((OpenFormula.stab φ).imp (OpenFormula.stab ψ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_stabK φ ψ)

/-- The reflection of ST is valid. -/
theorem openValidIn_stabT_reflect (φ : OpenFormula) :
    OpenValid ((OpenFormula.stab φ).imp φ).reflectTime :=
  openValid_reflectTime _ (openValidIn_stabT φ)

/-- The reflection of S4 for `⊡` is valid. -/
theorem openValidIn_stab4_reflect (φ : OpenFormula) :
    OpenValid ((OpenFormula.stab φ).imp
      (OpenFormula.stab (OpenFormula.stab φ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_stab4 φ)

/-- The reflection of S5 for `⊡` is valid. -/
theorem openValidIn_stab5_reflect (φ : OpenFormula) :
    OpenValid ((dstab φ).imp (OpenFormula.stab (dstab φ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_stab5 φ)

/-- The reflection of MS is valid. -/
theorem openValidIn_boxStab_reflect (φ : OpenFormula) :
    OpenValid ((OpenFormula.box φ).imp (OpenFormula.stab φ)).reflectTime :=
  openValid_reflectTime _ (openValidIn_boxStab φ)

/-- The reflection of AS is valid. -/
theorem openValidIn_atomStab_reflect (p : Atom) :
    OpenValid ((OpenFormula.atom p).imp
      (OpenFormula.stab (OpenFormula.atom p))).reflectTime :=
  openValid_reflectTime _ (openValidIn_atomStab p)

/-! ## The pasting block, per constructor

PS and US, both at `.Base`, both consuming Phase 1's purity predicates and the two L^▷ purity
congruences at the head of this file. `[F.IsRegular]` enters through `paste`, and
`OpenValid.of_forall_regular` is where it is registered.

**The congruences used are the L^▷ ones, not `PlusLanguage.truth_congr_agreeFrom` /
`truth_congr_agreeUpTo`.** The landed L⁺ halves are statements about `PlusTruthAt`, and a pure
L^▷ formula may contain the crossed restricted modal (`◁ψ` is pure-future, `▷ψ` is pure-past), so
they do not apply. `openTruthAt_congr_agreeFrom` / `openTruthAt_congr_agreeUpTo` are their L^▷
counterparts.

**PS and US are not each other's duals.** `reflectTime` fixes `⟐` and exchanges `untl`/`snce`, so
the dual of PS is PS with the conjuncts exchanged and the dual of US is SS. That costs nothing
here: `openValid_reflectTime` produces each dual whatever its shape, so neither needs to be named,
and no reflection lemma for `IsPureFutureOpen`/`IsPurePastOpen` is owed. -/

/-- PS (same-time pasting) over L^▷: `⟐φ⁺ → (⟐ψ⁻ → ⟐(φ⁺ ∧ ψ⁻))` for pure-future `φ⁺` and
pure-past `ψ⁻`. -/
theorem openValidIn_paste {φ ψ : OpenFormula} (hφ : IsPureFutureOpen φ)
    (hψ : IsPurePastOpen ψ) :
    OpenValid ((dstab φ).imp ((dstab ψ).imp (dstab (φ.and ψ)))) := by
  refine OpenValid.of_forall_regular fun F _ M τ t => ?_
  intro h1 h2
  rw [OpenTruth.dstab_iff] at h1 h2 ⊢
  obtain ⟨σ, hτσ, hφσ⟩ := h1
  obtain ⟨ρ, hτρ, hψρ⟩ := h2
  have hsame : ρ.state t = σ.state t := hτρ.symm.trans hτσ
  refine ⟨paste ρ σ t hsame, hτρ.trans (paste_agreeUpTo ρ σ t hsame t le_rfl).symm, ?_⟩
  rw [openTruth_and_iff]
  exact ⟨(openTruthAt_congr_agreeFrom M hφ _ _ t (paste_agreeFrom ρ σ t hsame)).mpr hφσ,
    (openTruthAt_congr_agreeUpTo M hψ _ _ t (paste_agreeUpTo ρ σ t hsame)).mpr hψρ⟩

/-- US (future pasting) over L^▷: `(α⁻ U ⟐φ⁺) → ⟐(α⁻ U φ⁺)` for pure-past `α⁻` and pure-future
`φ⁺`. -/
theorem openValidIn_untlPaste {α φ : OpenFormula} (hα : IsPurePastOpen α)
    (hφ : IsPureFutureOpen φ) :
    OpenValid ((OpenFormula.untl α (dstab φ)).imp (dstab (OpenFormula.untl α φ))) := by
  refine OpenValid.of_forall_regular fun F _ M τ t => ?_
  intro h
  rw [openTruth_untl_iff] at h
  obtain ⟨y, hty, hy, hguard⟩ := h
  rw [OpenTruth.dstab_iff] at hy
  obtain ⟨ρ, hτρ, hφρ⟩ := hy
  rw [OpenTruth.dstab_iff]
  refine ⟨paste τ ρ y hτρ, (paste_agreeUpTo τ ρ y hτρ t hty.le).symm, ?_⟩
  rw [openTruth_untl_iff]
  refine ⟨y, hty,
    (openTruthAt_congr_agreeFrom M hφ _ _ y (paste_agreeFrom τ ρ y hτρ)).mpr hφρ, ?_⟩
  intro r htr hry
  exact (openTruthAt_congr_agreeUpTo M hα _ τ r
    (agreeUpTo_mono hry.le (paste_agreeUpTo τ ρ y hτρ))).mpr (hguard r htr hry)

/-- The reflection of PS is valid: PS with the conjuncts exchanged, at the reflected
parameters. -/
theorem openValidIn_paste_reflect {φ ψ : OpenFormula} (hφ : IsPureFutureOpen φ)
    (hψ : IsPurePastOpen ψ) :
    OpenValid ((dstab φ).imp ((dstab ψ).imp (dstab (φ.and ψ)))).reflectTime :=
  openValid_reflectTime _ (openValidIn_paste hφ hψ)

/-- The reflection of US is valid: SS, the `snce` mirror, at the reflected parameters. -/
theorem openValidIn_untlPaste_reflect {α φ : OpenFormula} (hα : IsPurePastOpen α)
    (hφ : IsPureFutureOpen φ) :
    OpenValid ((OpenFormula.untl α (dstab φ)).imp
      (dstab (OpenFormula.untl α φ))).reflectTime :=
  openValid_reflectTime _ (openValidIn_untlPaste hα hφ)

/-! ## The Phase-10 block aggregates

**Constructors covered by `openAxiomValidIn_discreteBlock`** (five, in `OpenAxiom` constructor
order): `discrete_symm_fwd`, `discrete_symm_bwd`, `discrete_propagate_fwd`,
`discrete_propagate_bwd`, `discrete_box_necessity`.

**Constructors covered by `openAxiomValidIn_priorBlock`** (six, in `OpenAxiom` constructor order):
`prior_UZ`, `prior_SZ`, `z1`, `prior_U_gap`, `prior_S_gap`, `sep`. Each conjunct is stated at the
frame class its own `minFrameClass` arm names — `.ZTime` for the first three, `.RTime` for the
last three — never at `.Base`.

**Constructors covered by `openAxiomValidIn_denseBlock`** (two): `density`, `dense_indicator`,
both at `.Dense`.

**Constructors covered by `openAxiomValidIn_stabBlock`** (six, in `OpenAxiom` constructor order):
`stab_k`, `stab_t`, `stab_4`, `stab_5`, `box_stab`, `atom_stab`.

**Constructors covered by `openAxiomValidIn_pasteBlock`** (two): `paste`, `untl_paste`.

### The constructor set is now closed

Taking the union of the covered-name lists recorded in every block helper's docstring, across
this file:

| Block | Constructors |
|-------|-------------|
| `ofutBlock` | 14 |
| `rigidityBlock` | 4 |
| `propBlock` | 4 |
| `modalBlock` | 6 |
| `tempMonoBlock` | 8 |
| `tempAccumBlock` | 6 |
| `linearityBlock` | 4 |
| `tempEquivBlock` | 4 |
| `discreteBlock` | 5 |
| `priorBlock` | 6 |
| `denseBlock` | 2 |
| `stabBlock` | 6 |
| `pasteBlock` | 2 |
| **Total** | **71** |

`OpenAxiom` has 71 constructors (`OpenLanguage/OpenAxioms.lean`: 18 restricted-modal and 53 TM⁺
mirrors), no name is covered twice and none is missing. That is the totality fact the two
wildcard-free dispatch lemmas rest on. -/

/-- **The discrete-uniformity validity block**: the five schemata named in the section docstring
above. -/
theorem openAxiomValidIn_discreteBlock :
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.snce OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot))) ∧
    OpenValid ((OpenFormula.snce OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot))) ∧
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.allFuture
        (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)))) ∧
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.allPast
        (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)))) ∧
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.box
        (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)))) :=
  ⟨openValidIn_discreteSymmFwd, openValidIn_discreteSymmBwd, openValidIn_discretePropagateFwd,
    openValidIn_discretePropagateBwd, openValidIn_discreteBoxNecessity⟩

/-- **The discrete-uniformity reflection block**, same five schemata in the same order. -/
theorem openAxiomReflectValidIn_discreteBlock :
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.snce OpenFormula.bot
        (OpenFormula.bot.imp OpenFormula.bot))).reflectTime ∧
    OpenValid ((OpenFormula.snce OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.untl OpenFormula.bot
        (OpenFormula.bot.imp OpenFormula.bot))).reflectTime ∧
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.allFuture
        (OpenFormula.untl OpenFormula.bot
          (OpenFormula.bot.imp OpenFormula.bot)))).reflectTime ∧
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.allPast
        (OpenFormula.untl OpenFormula.bot
          (OpenFormula.bot.imp OpenFormula.bot)))).reflectTime ∧
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.box
        (OpenFormula.untl OpenFormula.bot
          (OpenFormula.bot.imp OpenFormula.bot)))).reflectTime :=
  ⟨openValidIn_discreteSymmFwd_reflect, openValidIn_discreteSymmBwd_reflect,
    openValidIn_discretePropagateFwd_reflect, openValidIn_discretePropagateBwd_reflect,
    openValidIn_discreteBoxNecessity_reflect⟩

/-- **The Prior and Dedekind validity block**: the six schemata named in the section docstring
above, each at its own frame class. -/
theorem openAxiomValidIn_priorBlock :
    (∀ φ : OpenFormula,
      OpenValidIn FrameClass.ZTime (φ.someFuture.imp (OpenFormula.untl φ.neg φ))) ∧
    (∀ φ : OpenFormula,
      OpenValidIn FrameClass.ZTime (φ.somePast.imp (OpenFormula.snce φ.neg φ))) ∧
    (∀ φ : OpenFormula, OpenValidIn FrameClass.ZTime ((φ.allFuture.imp φ).allFuture.imp
      (φ.allFuture.someFuture.imp φ.allFuture))) ∧
    (∀ φ : OpenFormula, OpenValidIn FrameClass.RTime
      ((OpenFormula.and (OpenFormula.untl φ OpenFormula.top) φ.neg.someFuture).imp
        (OpenFormula.untl φ (OpenFormula.or φ.neg (OpenFormula.kPlus φ.neg))))) ∧
    (∀ φ : OpenFormula, OpenValidIn FrameClass.RTime
      ((OpenFormula.and (OpenFormula.snce φ OpenFormula.top) φ.neg.somePast).imp
        (OpenFormula.snce φ (OpenFormula.or φ.neg (OpenFormula.kMinus φ.neg))))) ∧
    (∀ φ : OpenFormula, OpenValidIn FrameClass.RTime
      ((OpenFormula.and (OpenFormula.kPlus φ)
        (OpenFormula.kPlus (OpenFormula.and φ (OpenFormula.untl φ.neg φ))).neg).imp
        (OpenFormula.kPlus
          (OpenFormula.and (OpenFormula.kPlus φ) (OpenFormula.kMinus φ))))) :=
  ⟨openValidIn_priorUZ, openValidIn_priorSZ, openValidIn_z1, openValidIn_priorUGap,
    openValidIn_priorSGap, openValidIn_sep⟩

/-- **The Prior and Dedekind reflection block**, same six schemata in the same order and at the
same classes. -/
theorem openAxiomReflectValidIn_priorBlock :
    (∀ φ : OpenFormula, OpenValidIn FrameClass.ZTime
      (φ.someFuture.imp (OpenFormula.untl φ.neg φ)).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValidIn FrameClass.ZTime
      (φ.somePast.imp (OpenFormula.snce φ.neg φ)).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValidIn FrameClass.ZTime (((φ.allFuture.imp φ).allFuture.imp
      (φ.allFuture.someFuture.imp φ.allFuture))).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValidIn FrameClass.RTime
      (((OpenFormula.and (OpenFormula.untl φ OpenFormula.top) φ.neg.someFuture).imp
        (OpenFormula.untl φ
          (OpenFormula.or φ.neg (OpenFormula.kPlus φ.neg)))).reflectTime)) ∧
    (∀ φ : OpenFormula, OpenValidIn FrameClass.RTime
      (((OpenFormula.and (OpenFormula.snce φ OpenFormula.top) φ.neg.somePast).imp
        (OpenFormula.snce φ
          (OpenFormula.or φ.neg (OpenFormula.kMinus φ.neg)))).reflectTime)) ∧
    (∀ φ : OpenFormula, OpenValidIn FrameClass.RTime
      (((OpenFormula.and (OpenFormula.kPlus φ)
        (OpenFormula.kPlus (OpenFormula.and φ (OpenFormula.untl φ.neg φ))).neg).imp
        (OpenFormula.kPlus
          (OpenFormula.and (OpenFormula.kPlus φ)
            (OpenFormula.kMinus φ)))).reflectTime)) :=
  ⟨openValidIn_priorUZ_reflect, openValidIn_priorSZ_reflect, openValidIn_z1_reflect,
    openValidIn_priorUGap_reflect, openValidIn_priorSGap_reflect, openValidIn_sep_reflect⟩

/-- **The density validity block**: `density` and `dense_indicator`, both at `.Dense`. -/
theorem openAxiomValidIn_denseBlock :
    (∀ φ : OpenFormula,
      OpenValidIn FrameClass.Dense ((φ.allFuture.allFuture).imp φ.allFuture)) ∧
    OpenValidIn FrameClass.Dense
      (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).neg :=
  ⟨openValidIn_density, openValidIn_denseIndicator⟩

/-- **The density reflection block**, same two schemata in the same order. -/
theorem openAxiomReflectValidIn_denseBlock :
    (∀ φ : OpenFormula, OpenValidIn FrameClass.Dense
      ((φ.allFuture.allFuture).imp φ.allFuture).reflectTime) ∧
    OpenValidIn FrameClass.Dense
      (OpenFormula.untl OpenFormula.bot
        (OpenFormula.bot.imp OpenFormula.bot)).neg.reflectTime :=
  ⟨openValidIn_density_reflect, openValidIn_denseIndicator_reflect⟩

/-- **The stability-modal validity block**: the six schemata named in the section docstring
above. -/
theorem openAxiomValidIn_stabBlock :
    (∀ φ ψ : OpenFormula, OpenValid ((OpenFormula.stab (φ.imp ψ)).imp
      ((OpenFormula.stab φ).imp (OpenFormula.stab ψ)))) ∧
    (∀ φ : OpenFormula, OpenValid ((OpenFormula.stab φ).imp φ)) ∧
    (∀ φ : OpenFormula,
      OpenValid ((OpenFormula.stab φ).imp (OpenFormula.stab (OpenFormula.stab φ)))) ∧
    (∀ φ : OpenFormula, OpenValid ((dstab φ).imp (OpenFormula.stab (dstab φ)))) ∧
    (∀ φ : OpenFormula, OpenValid ((OpenFormula.box φ).imp (OpenFormula.stab φ))) ∧
    (∀ p : Atom,
      OpenValid ((OpenFormula.atom p).imp (OpenFormula.stab (OpenFormula.atom p)))) :=
  ⟨openValidIn_stabK, openValidIn_stabT, openValidIn_stab4, openValidIn_stab5,
    openValidIn_boxStab, openValidIn_atomStab⟩

/-- **The stability-modal reflection block**, same six schemata in the same order. -/
theorem openAxiomReflectValidIn_stabBlock :
    (∀ φ ψ : OpenFormula, OpenValid ((OpenFormula.stab (φ.imp ψ)).imp
      ((OpenFormula.stab φ).imp (OpenFormula.stab ψ))).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid ((OpenFormula.stab φ).imp φ).reflectTime) ∧
    (∀ φ : OpenFormula, OpenValid ((OpenFormula.stab φ).imp
      (OpenFormula.stab (OpenFormula.stab φ))).reflectTime) ∧
    (∀ φ : OpenFormula,
      OpenValid ((dstab φ).imp (OpenFormula.stab (dstab φ))).reflectTime) ∧
    (∀ φ : OpenFormula,
      OpenValid ((OpenFormula.box φ).imp (OpenFormula.stab φ)).reflectTime) ∧
    (∀ p : Atom, OpenValid ((OpenFormula.atom p).imp
      (OpenFormula.stab (OpenFormula.atom p))).reflectTime) :=
  ⟨openValidIn_stabK_reflect, openValidIn_stabT_reflect, openValidIn_stab4_reflect,
    openValidIn_stab5_reflect, openValidIn_boxStab_reflect, openValidIn_atomStab_reflect⟩

/-- **The pasting validity block**: `paste` and `untl_paste`. -/
theorem openAxiomValidIn_pasteBlock :
    (∀ {φ ψ : OpenFormula}, IsPureFutureOpen φ → IsPurePastOpen ψ →
      OpenValid ((dstab φ).imp ((dstab ψ).imp (dstab (φ.and ψ))))) ∧
    (∀ {α φ : OpenFormula}, IsPurePastOpen α → IsPureFutureOpen φ →
      OpenValid ((OpenFormula.untl α (dstab φ)).imp (dstab (OpenFormula.untl α φ)))) :=
  ⟨fun hφ hψ => openValidIn_paste hφ hψ, fun hα hφ => openValidIn_untlPaste hα hφ⟩

/-- **The pasting reflection block**, same two schemata in the same order. -/
theorem openAxiomReflectValidIn_pasteBlock :
    (∀ {φ ψ : OpenFormula}, IsPureFutureOpen φ → IsPurePastOpen ψ →
      OpenValid ((dstab φ).imp ((dstab ψ).imp (dstab (φ.and ψ)))).reflectTime) ∧
    (∀ {α φ : OpenFormula}, IsPurePastOpen α → IsPureFutureOpen φ →
      OpenValid ((OpenFormula.untl α (dstab φ)).imp
        (dstab (OpenFormula.untl α φ))).reflectTime) :=
  ⟨fun hφ hψ => openValidIn_paste_reflect hφ hψ,
    fun hα hφ => openValidIn_untlPaste_reflect hα hφ⟩

/-! ## The two dispatch lemmas

The public entry point of this file, and the semantic input to the soundness recursion of
`Conservativity/Open/OpenSoundness.lean`: every `OpenAxiom` schema is valid, and every schema's
time reflection is valid, each at the schema's own minimum frame class.

**Neither dispatch carries a wildcard arm.** Each is a `cases ax` with exactly 71 arms, one per
`OpenAxiom` constructor, in constructor order. `PlusAxiom.minFrameClass` ends in a `| _ => .Base`
catch-all and `plusAxiom_validIn_min`/`plusAxiom_reflect_time_validIn_min` have no wildcard;
here *none* of the four has one, so a constructor added to `OpenAxiom` without the matching arms
is a **build error rather than a silent gap**. That is the whole point of the wildcard-free
discipline, and it is why these two lemmas are the place the obligation is enforced rather than
merely documented.

**The full per-constructor obligation is five arms**, as `OpenLanguage/OpenAxioms.lean`'s
extension recipe records: the constructor line; one `OpenAxiom.minFrameClass` arm; one arm in
`openAxiom_validIn_min`; one arm in `openAxiom_reflect_time_validIn_min`; and one arm in
`dischargeAxiom` (`OpenLanguage/OpenErasure.lean`). The fifth is the one that can be *impossible*
rather than merely laborious — it must produce a TM⁺ derivation of the schema's `eraseOpen`
image — and it is what excludes the backward definability half `▷◁φ → ⊡φ` from the axiom type
despite its validity.

Each arm routes to the per-constructor theorem of its block, every one of which is also a
component of the block aggregate carrying that constructor's name in its docstring. Routing to the
per-constructor theorem rather than destructuring the aggregate keeps each arm a single `exact`.

## No completeness is claimed

These are soundness obligations. Nothing here is a completeness claim for L^▷ at any frame class.
-/

/-- **Every L^▷ schema is valid at its own minimum frame class.** One arm per
constructor, **no wildcard arm**; see the section docstring.

Paper: — (formalization-native; the manuscript supplies no logic for the restricted modals,
so none of its schemata has a paper anchor)
-/
theorem openAxiom_validIn_min {φ : OpenFormula} (ax : OpenAxiom φ) :
    OpenValidIn ax.minFrameClass φ := by
  cases ax with
  | ofut_k φ ψ => exact openValidIn_ofutK φ ψ
  | ofut_t φ => exact openValidIn_ofutT φ
  | ofut_four φ => exact openValidIn_ofutFour φ
  | ofut_five φ => exact openValidIn_ofutFive φ
  | opast_k φ ψ => exact openValidIn_opastK φ ψ
  | opast_t φ => exact openValidIn_opastT φ
  | opast_four φ => exact openValidIn_opastFour φ
  | opast_five φ => exact openValidIn_opastFive φ
  | stab_of_box φ => exact openValidIn_stabOfBox φ
  | ofut_of_stab φ => exact openValidIn_ofutOfStab φ
  | opast_of_stab φ => exact openValidIn_opastOfStab φ
  | hn_open α => exact openValidIn_hnOpen α
  | hn_open_mirror α => exact openValidIn_hnOpenMirror α
  | rigidity_opast_fwd φ hφ => exact openValidIn_rigidityOpastFwd hφ
  | rigidity_opast_bwd φ hφ => exact openValidIn_rigidityOpastBwd hφ
  | rigidity_ofut_fwd φ hφ => exact openValidIn_rigidityOfutFwd hφ
  | rigidity_ofut_bwd φ hφ => exact openValidIn_rigidityOfutBwd hφ
  | definability_fwd φ => exact openValidIn_definabilityFwd φ
  | prop_k φ ψ χ => exact openValidIn_propK φ ψ χ
  | prop_s φ ψ => exact openValidIn_propS φ ψ
  | ex_falso φ => exact openValidIn_exFalso φ
  | peirce φ ψ => exact openValidIn_peirce φ ψ
  | modal_t φ => exact openValidIn_modalT φ
  | modal_4 φ => exact openValidIn_modal4 φ
  | modal_b φ => exact openValidIn_modalB φ
  | modal_5_collapse φ => exact openValidIn_modal5Collapse φ
  | modal_k_dist φ ψ => exact openValidIn_modalKDist φ ψ
  | serial_future => exact openValidIn_serialFuture
  | serial_past => exact openValidIn_serialPast
  | left_mono_until_G φ χ ψ => exact openValidIn_leftMonoUntilG φ χ ψ
  | left_mono_since_H φ χ ψ => exact openValidIn_leftMonoSinceH φ χ ψ
  | right_mono_until φ ψ χ => exact openValidIn_rightMonoUntil φ ψ χ
  | right_mono_since φ ψ χ => exact openValidIn_rightMonoSince φ ψ χ
  | connect_future φ => exact openValidIn_connectFuture φ
  | connect_past φ => exact openValidIn_connectPast φ
  | enrichment_until φ ψ p => exact openValidIn_enrichmentUntil φ ψ p
  | enrichment_since φ ψ p => exact openValidIn_enrichmentSince φ ψ p
  | self_accum_until φ ψ => exact openValidIn_selfAccumUntil φ ψ
  | self_accum_since φ ψ => exact openValidIn_selfAccumSince φ ψ
  | absorb_until φ ψ => exact openValidIn_absorbUntil φ ψ
  | absorb_since φ ψ => exact openValidIn_absorbSince φ ψ
  | linear_until φ ψ χ θ => exact openValidIn_linearUntil φ ψ χ θ
  | linear_since φ ψ χ θ => exact openValidIn_linearSince φ ψ χ θ
  | until_F φ ψ => exact openValidIn_untilF φ ψ
  | since_P φ ψ => exact openValidIn_sinceP φ ψ
  | temp_linearity φ ψ => exact openValidIn_tempLinearity φ ψ
  | temp_linearity_past φ ψ => exact openValidIn_tempLinearityPast φ ψ
  | F_until_equiv φ => exact openValidIn_FUntilEquiv φ
  | P_since_equiv φ => exact openValidIn_PSinceEquiv φ
  | modal_future φ => exact openValidIn_modalFuture φ
  | discrete_symm_fwd => exact openValidIn_discreteSymmFwd
  | discrete_symm_bwd => exact openValidIn_discreteSymmBwd
  | discrete_propagate_fwd => exact openValidIn_discretePropagateFwd
  | discrete_propagate_bwd => exact openValidIn_discretePropagateBwd
  | discrete_box_necessity => exact openValidIn_discreteBoxNecessity
  | prior_UZ φ => exact openValidIn_priorUZ φ
  | prior_SZ φ => exact openValidIn_priorSZ φ
  | z1 φ => exact openValidIn_z1 φ
  | density φ => exact openValidIn_density φ
  | dense_indicator => exact openValidIn_denseIndicator
  | prior_U_gap φ => exact openValidIn_priorUGap φ
  | prior_S_gap φ => exact openValidIn_priorSGap φ
  | sep φ => exact openValidIn_sep φ
  | stab_k φ ψ => exact openValidIn_stabK φ ψ
  | stab_t φ => exact openValidIn_stabT φ
  | stab_4 φ => exact openValidIn_stab4 φ
  | stab_5 φ => exact openValidIn_stab5 φ
  | box_stab φ => exact openValidIn_boxStab φ
  | atom_stab p => exact openValidIn_atomStab p
  | paste φ ψ hφ hψ => exact openValidIn_paste hφ hψ
  | untl_paste α φ hα hφ => exact openValidIn_untlPaste hα hφ

/-- **Every L^▷ schema's time reflection is valid at its own minimum frame class.** One arm per
constructor, **no wildcard arm**; see the section docstring.

Paper: — (formalization-native; `lem:time-reflection` is stated for the base language, and
this is its extension to `⊡`, `▷` and `◁` at the level of the axiom schemata)
-/
theorem openAxiom_reflect_time_validIn_min {φ : OpenFormula} (ax : OpenAxiom φ) :
    OpenValidIn ax.minFrameClass φ.reflectTime := by
  cases ax with
  | ofut_k φ ψ => exact openValidIn_ofutK_reflect φ ψ
  | ofut_t φ => exact openValidIn_ofutT_reflect φ
  | ofut_four φ => exact openValidIn_ofutFour_reflect φ
  | ofut_five φ => exact openValidIn_ofutFive_reflect φ
  | opast_k φ ψ => exact openValidIn_opastK_reflect φ ψ
  | opast_t φ => exact openValidIn_opastT_reflect φ
  | opast_four φ => exact openValidIn_opastFour_reflect φ
  | opast_five φ => exact openValidIn_opastFive_reflect φ
  | stab_of_box φ => exact openValidIn_stabOfBox_reflect φ
  | ofut_of_stab φ => exact openValidIn_ofutOfStab_reflect φ
  | opast_of_stab φ => exact openValidIn_opastOfStab_reflect φ
  | hn_open α => exact openValidIn_hnOpen_reflect α
  | hn_open_mirror α => exact openValidIn_hnOpenMirror_reflect α
  | rigidity_opast_fwd φ hφ => exact openValidIn_rigidityOpastFwd_reflect hφ
  | rigidity_opast_bwd φ hφ => exact openValidIn_rigidityOpastBwd_reflect hφ
  | rigidity_ofut_fwd φ hφ => exact openValidIn_rigidityOfutFwd_reflect hφ
  | rigidity_ofut_bwd φ hφ => exact openValidIn_rigidityOfutBwd_reflect hφ
  | definability_fwd φ => exact openValidIn_definabilityFwd_reflect φ
  | prop_k φ ψ χ => exact openValidIn_propK_reflect φ ψ χ
  | prop_s φ ψ => exact openValidIn_propS_reflect φ ψ
  | ex_falso φ => exact openValidIn_exFalso_reflect φ
  | peirce φ ψ => exact openValidIn_peirce_reflect φ ψ
  | modal_t φ => exact openValidIn_modalT_reflect φ
  | modal_4 φ => exact openValidIn_modal4_reflect φ
  | modal_b φ => exact openValidIn_modalB_reflect φ
  | modal_5_collapse φ => exact openValidIn_modal5Collapse_reflect φ
  | modal_k_dist φ ψ => exact openValidIn_modalKDist_reflect φ ψ
  | serial_future => exact openValidIn_serialFuture_reflect
  | serial_past => exact openValidIn_serialPast_reflect
  | left_mono_until_G φ χ ψ => exact openValidIn_leftMonoUntilG_reflect φ χ ψ
  | left_mono_since_H φ χ ψ => exact openValidIn_leftMonoSinceH_reflect φ χ ψ
  | right_mono_until φ ψ χ => exact openValidIn_rightMonoUntil_reflect φ ψ χ
  | right_mono_since φ ψ χ => exact openValidIn_rightMonoSince_reflect φ ψ χ
  | connect_future φ => exact openValidIn_connectFuture_reflect φ
  | connect_past φ => exact openValidIn_connectPast_reflect φ
  | enrichment_until φ ψ p => exact openValidIn_enrichmentUntil_reflect φ ψ p
  | enrichment_since φ ψ p => exact openValidIn_enrichmentSince_reflect φ ψ p
  | self_accum_until φ ψ => exact openValidIn_selfAccumUntil_reflect φ ψ
  | self_accum_since φ ψ => exact openValidIn_selfAccumSince_reflect φ ψ
  | absorb_until φ ψ => exact openValidIn_absorbUntil_reflect φ ψ
  | absorb_since φ ψ => exact openValidIn_absorbSince_reflect φ ψ
  | linear_until φ ψ χ θ => exact openValidIn_linearUntil_reflect φ ψ χ θ
  | linear_since φ ψ χ θ => exact openValidIn_linearSince_reflect φ ψ χ θ
  | until_F φ ψ => exact openValidIn_untilF_reflect φ ψ
  | since_P φ ψ => exact openValidIn_sinceP_reflect φ ψ
  | temp_linearity φ ψ => exact openValidIn_tempLinearity_reflect φ ψ
  | temp_linearity_past φ ψ => exact openValidIn_tempLinearityPast_reflect φ ψ
  | F_until_equiv φ => exact openValidIn_FUntilEquiv_reflect φ
  | P_since_equiv φ => exact openValidIn_PSinceEquiv_reflect φ
  | modal_future φ => exact openValidIn_modalFuture_reflect φ
  | discrete_symm_fwd => exact openValidIn_discreteSymmFwd_reflect
  | discrete_symm_bwd => exact openValidIn_discreteSymmBwd_reflect
  | discrete_propagate_fwd => exact openValidIn_discretePropagateFwd_reflect
  | discrete_propagate_bwd => exact openValidIn_discretePropagateBwd_reflect
  | discrete_box_necessity => exact openValidIn_discreteBoxNecessity_reflect
  | prior_UZ φ => exact openValidIn_priorUZ_reflect φ
  | prior_SZ φ => exact openValidIn_priorSZ_reflect φ
  | z1 φ => exact openValidIn_z1_reflect φ
  | density φ => exact openValidIn_density_reflect φ
  | dense_indicator => exact openValidIn_denseIndicator_reflect
  | prior_U_gap φ => exact openValidIn_priorUGap_reflect φ
  | prior_S_gap φ => exact openValidIn_priorSGap_reflect φ
  | sep φ => exact openValidIn_sep_reflect φ
  | stab_k φ ψ => exact openValidIn_stabK_reflect φ ψ
  | stab_t φ => exact openValidIn_stabT_reflect φ
  | stab_4 φ => exact openValidIn_stab4_reflect φ
  | stab_5 φ => exact openValidIn_stab5_reflect φ
  | box_stab φ => exact openValidIn_boxStab_reflect φ
  | atom_stab p => exact openValidIn_atomStab_reflect p
  | paste φ ψ hφ hψ => exact openValidIn_paste_reflect hφ hψ
  | untl_paste α φ hα hφ => exact openValidIn_untlPaste_reflect hα hφ

/-- Validity of an L^▷ schema at any class admitting it. -/
theorem openAxiom_validIn {φ : OpenFormula} {fc : FrameClass} (ax : OpenAxiom φ)
    (h : ax.minFrameClass ≤ fc) : OpenValidIn fc φ :=
  OpenValidIn.mono h (openAxiom_validIn_min ax)

/-- Reflection-validity of an L^▷ schema at any class admitting it. -/
theorem openAxiom_reflect_time_validIn {φ : OpenFormula} {fc : FrameClass} (ax : OpenAxiom φ)
    (h : ax.minFrameClass ≤ fc) : OpenValidIn fc φ.reflectTime :=
  OpenValidIn.mono h (openAxiom_reflect_time_validIn_min ax)

end FormalSystem.Metalogic.Conservativity
