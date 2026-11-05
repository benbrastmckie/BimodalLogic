/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.OpenLanguage.OpenAxioms
import FormalSystem.OpenLanguage.OpenValidity
import FormalSystem.OpenLanguage.OpenOckhamist
import FormalSystem.OpenLanguage.OpenReversal
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
- `openKPlus_iff`, `openKMinus_iff` — the two Reynolds gap operators, unfolded
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

With the thirteen block helpers above, the `OpenAxiom` constructor set is **closed**: the union of
their covered-name lists is all 71 constructors, with none covered twice and none missing. The
per-block tally is in the Phase-10 aggregate section's own docstring.

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

/-! ## The L^▷ purity congruences -/

variable {F : TaskFrame}

/-- **A pure-future L^▷ formula sees only the history from `t` onward.** The L^▷ counterpart of
`PlusLanguage.truth_congr_agreeFrom`. The seven shared arms are that proof verbatim; the `opast`
arm uses no induction hypothesis, since `AgreeFrom · · t` is an equivalence and the two
quantifier domains coincide. -/
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
them in the `OpenTruthAt` shape the `StarTruth.*_iff` family has, so the mirror proofs below can be
read against `Conservativity/Star/StarAxiomValidity.lean` line for line. -/

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
`openTruthAt_congr_ext`; the `opast` arm is the same argument over `AgreeFrom`. -/
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

The four Layer-1 schemata of `OpenAxiom`, proved **directly against `OpenTruthAt`** at arbitrary
`OpenFormula` metavariables.

**No atomization and no uniform substitution, here or anywhere below (R7).** The atomization route
of `Conservativity/Plus/Atomization.lean` rests on `stab_state_only` — `⊡φ`'s truth value at
`(τ, t)` is fixed by the world state `τ(t)` alone — and `▷χ` is *not* state-local: two histories
sharing a state at `t` need not agree up to `t`, so no L^▷ analogue of `stab_state_only` exists and
the atomization route is unavailable. Uniform substitution is independently unsound over TM⁺, whose
`atom_stab` schema (`p → ⊡p`, atoms only) is false at a general substitution instance. Every arm
below is therefore a fresh direct proof, and the shortcut is not to be re-attempted. -/

/-- Propositional K over L^▷. -/
theorem openValidIn_propK (φ ψ χ : OpenFormula) :
    OpenValid ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) :=
  OpenValid.of_forall fun _ _ _ _ h1 h2 h3 => h1 h3 (h2 h3)

/-- Propositional S (weakening) over L^▷. -/
theorem openValidIn_propS (φ ψ : OpenFormula) : OpenValid (φ.imp (ψ.imp φ)) :=
  OpenValid.of_forall fun _ _ _ _ h _ => h

/-- Ex Falso Quodlibet over L^▷. -/
theorem openValidIn_exFalso (φ : OpenFormula) : OpenValid (OpenFormula.bot.imp φ) :=
  OpenValid.of_forall fun _ _ _ _ h => h.elim

/-- Peirce's Law over L^▷, by classical case analysis on `φ`. -/
theorem openValidIn_peirce (φ ψ : OpenFormula) :
    OpenValid (((φ.imp ψ).imp φ).imp φ) := by
  refine OpenValid.of_forall fun F M τ t h => ?_
  by_cases hφ : OpenTruthAt M τ t φ
  · exact hφ
  · exact h fun hp => absurd hp hφ

/-! ## The S5-modal block, per constructor

The five Layer-2 schemata plus `modal_future`, the one Layer-4 interaction schema. `□` quantifies
over *all* world histories at the fixed time of evaluation, so T, 4, B, the 5-collapse and K are
each one step from that clause; `modal_future` is the only one that moves the time, and it consumes
`openTruthAt_timeShift` above. -/

/-- Modal T over L^▷: the evaluation history is itself a world history, so `□` reflects. -/
theorem openValidIn_modalT (φ : OpenFormula) : OpenValid ((OpenFormula.box φ).imp φ) :=
  OpenValid.of_forall fun _ _ τ _ h => h τ

/-- Modal 4 over L^▷: the `box` clause quantifies over all world histories, so it is
idempotent. -/
theorem openValidIn_modal4 (φ : OpenFormula) :
    OpenValid ((OpenFormula.box φ).imp (OpenFormula.box (OpenFormula.box φ))) :=
  OpenValid.of_forall fun _ _ _ _ h _ => h

/-- Modal B over L^▷. -/
theorem openValidIn_modalB (φ : OpenFormula) :
    OpenValid (φ.imp (OpenFormula.box φ.diamond)) := by
  refine OpenValid.of_forall fun F M τ t h => ?_
  intro σ
  rw [openTruth_diamond_iff]
  exact ⟨τ, h⟩

/-- Modal 5 Collapse over L^▷. -/
theorem openValidIn_modal5Collapse (φ : OpenFormula) :
    OpenValid (φ.box.diamond.imp φ.box) := by
  refine OpenValid.of_forall fun F M τ t h => ?_
  rw [openTruth_diamond_iff] at h
  obtain ⟨σ, hb⟩ := h
  exact hb

/-- Modal K distribution over L^▷. -/
theorem openValidIn_modalKDist (φ ψ : OpenFormula) :
    OpenValid ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) :=
  OpenValid.of_forall fun _ _ _ _ h1 h2 σ => h1 σ (h2 σ)

/-- **MF at every `OpenFormula`**: `□φ → □Gφ`. The argument is the L⁺ one, with
`openTruthAt_timeShift` supplying homogeneity: `□φ` holds of the shifted history
`σ.timeShift (s - t)` at `t`, which is `φ` at `σ` at time `s`. -/
theorem openValidIn_modalFuture (φ : OpenFormula) :
    OpenValid ((OpenFormula.box φ).imp (OpenFormula.box (OpenFormula.allFuture φ))) := by
  refine OpenValid.of_forall fun F M τ t h => ?_
  intro σ
  rw [openTruth_allFuture_iff]
  intro s hts
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

The seriality, left/right monotonicity and connection schemata of Layer 3. Each is the L-level
argument of `Metalogic/Soundness.lean` under the substitution `TruthAt M τ t ↦ OpenTruthAt M τ t`,
`Truth.*_iff ↦ openTruth_*_iff`, read against
`Conservativity/Star/StarAxiomValidity.lean`'s own transcription of the same proofs. The two
seriality schemata are closed formulas and are proved from `exists_gt` / `exists_lt` directly
rather than transported, so that the whole block is discharged against `OpenTruthAt` uniformly.

As throughout this file: no atomization, no uniform substitution (see the propositional block's
note). -/

/-- Serial future over L^▷: `F(⊤)`, from forward seriality of the duration order. -/
theorem openValidIn_serialFuture :
    OpenValid (OpenFormula.someFuture (OpenFormula.bot.imp OpenFormula.bot)) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  rw [OpenTruth.someFuture_iff]
  obtain ⟨s, hts⟩ := exists_gt t
  exact ⟨s, hts, fun h => h⟩

/-- Serial past over L^▷: `⊤ → P(⊤)`, from backward seriality. -/
theorem openValidIn_serialPast :
    OpenValid ((OpenFormula.bot.imp OpenFormula.bot).imp
      (OpenFormula.somePast (OpenFormula.bot.imp OpenFormula.bot))) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  intro _
  rw [OpenTruth.somePast_iff]
  obtain ⟨s, hst⟩ := exists_lt t
  exact ⟨s, hst, fun h => h⟩

/-- BX2G over L^▷: the guard of an `until` may be weakened under `G`. -/
theorem openValidIn_leftMonoUntilG (φ χ ψ : OpenFormula) :
    OpenValid ((φ.imp χ).allFuture.imp
      ((OpenFormula.untl φ ψ).imp (OpenFormula.untl χ ψ))) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_allFuture_iff, openTruth_untl_iff]
  rintro h_G ⟨s, hts, h_event, h_guard⟩
  exact ⟨s, hts, h_event, fun r htr hrs => h_G r htr (h_guard r htr hrs)⟩

/-- BX2H over L^▷, the past mirror of `openValidIn_leftMonoUntilG`. -/
theorem openValidIn_leftMonoSinceH (φ χ ψ : OpenFormula) :
    OpenValid ((φ.imp χ).allPast.imp
      ((OpenFormula.snce φ ψ).imp (OpenFormula.snce χ ψ))) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_allPast_iff, openTruth_snce_iff]
  rintro h_H ⟨s, hst, h_event, h_guard⟩
  exact ⟨s, hst, h_event, fun r hsr hrt => h_H r hrt (h_guard r hsr hrt)⟩

/-- BX3 over L^▷: the event of an `until` may be weakened under `G`. -/
theorem openValidIn_rightMonoUntil (φ ψ χ : OpenFormula) :
    OpenValid ((φ.imp ψ).allFuture.imp
      ((OpenFormula.untl χ φ).imp (OpenFormula.untl χ ψ))) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_allFuture_iff, openTruth_untl_iff]
  rintro h_G ⟨s, hts, h_event, h_guard⟩
  exact ⟨s, hts, h_G s hts h_event, h_guard⟩

/-- BX3' over L^▷, the past mirror of `openValidIn_rightMonoUntil`. -/
theorem openValidIn_rightMonoSince (φ ψ χ : OpenFormula) :
    OpenValid ((φ.imp ψ).allPast.imp
      ((OpenFormula.snce χ φ).imp (OpenFormula.snce χ ψ))) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_allPast_iff, openTruth_snce_iff]
  rintro h_H ⟨s, hst, h_event, h_guard⟩
  exact ⟨s, hst, h_H s hst h_event, h_guard⟩

/-- BX4 over L^▷: what is true now is always going to have been true. -/
theorem openValidIn_connectFuture (φ : OpenFormula) :
    OpenValid (φ.imp (φ.somePast.allFuture)) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_allFuture_iff, OpenTruth.somePast_iff]
  intro h s hts
  exact ⟨t, hts, h⟩

/-- BX4' over L^▷, the past mirror of `openValidIn_connectFuture`. -/
theorem openValidIn_connectPast (φ : OpenFormula) :
    OpenValid (φ.imp (φ.someFuture.allPast)) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_allPast_iff, OpenTruth.someFuture_iff]
  intro h s hst
  exact ⟨t, hst, h⟩

/-! ## The enrichment, self-accumulation and absorption block, per constructor

The heaviest arms of Layer 3. Each is `simp only` over the clause family followed by `rintro`
and, where two witnesses must be compared, `rcases lt_trichotomy`. -/

/-- BX13 over L^▷ (Burgess A3a). -/
theorem openValidIn_enrichmentUntil (φ ψ p : OpenFormula) :
    OpenValid (OpenFormula.and p (OpenFormula.untl φ ψ) |>.imp
      (OpenFormula.untl φ (OpenFormula.and ψ (OpenFormula.snce φ p)))) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_and_iff, openTruth_untl_iff, openTruth_snce_iff]
  rintro ⟨h_pt, s, hts, h_ψs, h_guard⟩
  exact ⟨s, hts, ⟨h_ψs, t, hts, h_pt, h_guard⟩, h_guard⟩

/-- BX13' over L^▷ (Burgess A3b), the past mirror of `openValidIn_enrichmentUntil`. -/
theorem openValidIn_enrichmentSince (φ ψ p : OpenFormula) :
    OpenValid (OpenFormula.and p (OpenFormula.snce φ ψ) |>.imp
      (OpenFormula.snce φ (OpenFormula.and ψ (OpenFormula.untl φ p)))) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_and_iff, openTruth_untl_iff, openTruth_snce_iff]
  rintro ⟨h_pt, s, hst, h_ψs, h_guard⟩
  exact ⟨s, hst, ⟨h_ψs, t, hst, h_pt, h_guard⟩, h_guard⟩

/-- BX5 over L^▷. -/
theorem openValidIn_selfAccumUntil (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.untl φ ψ).imp
      (OpenFormula.untl (OpenFormula.and φ (OpenFormula.untl φ ψ)) ψ)) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_and_iff, openTruth_untl_iff]
  rintro ⟨s, hts, h_ψs, h_guard⟩
  refine ⟨s, hts, h_ψs, fun r htr hrs => ⟨h_guard r htr hrs, ?_⟩⟩
  exact ⟨s, hrs, h_ψs, fun q hqr hqs => h_guard q (lt_trans htr hqr) hqs⟩

/-- BX5' over L^▷, the past mirror of `openValidIn_selfAccumUntil`. -/
theorem openValidIn_selfAccumSince (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.snce φ ψ).imp
      (OpenFormula.snce (OpenFormula.and φ (OpenFormula.snce φ ψ)) ψ)) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_and_iff, openTruth_snce_iff]
  rintro ⟨s, hst, h_ψs, h_guard⟩
  refine ⟨s, hst, h_ψs, fun r hsr hrt => ⟨h_guard r hsr hrt, ?_⟩⟩
  exact ⟨s, hsr, h_ψs, fun q hsq hqr => h_guard q hsq (lt_trans hqr hrt)⟩

/-- BX6 over L^▷. -/
theorem openValidIn_absorbUntil (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.untl φ (OpenFormula.and φ (OpenFormula.untl φ ψ))).imp
      (OpenFormula.untl φ ψ)) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_and_iff, openTruth_untl_iff]
  rintro ⟨s₁, hts₁, ⟨h_φs₁, s₂, hs₁s₂, h_ψs₂, h_guard₂⟩, h_guard₁⟩
  refine ⟨s₂, lt_trans hts₁ hs₁s₂, h_ψs₂, fun q htq hqs₂ => ?_⟩
  rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
  · exact h_guard₁ q htq h_lt
  · exact h_eq ▸ h_φs₁
  · exact h_guard₂ q h_gt hqs₂

/-- BX6' over L^▷, the past mirror of `openValidIn_absorbUntil`. -/
theorem openValidIn_absorbSince (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.snce φ (OpenFormula.and φ (OpenFormula.snce φ ψ))).imp
      (OpenFormula.snce φ ψ)) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_and_iff, openTruth_snce_iff]
  rintro ⟨s₁, hs₁t, ⟨h_φs₁, s₂, hs₂s₁, h_ψs₂, h_guard₂⟩, h_guard₁⟩
  refine ⟨s₂, lt_trans hs₂s₁ hs₁t, h_ψs₂, fun q hs₂q hqt => ?_⟩
  rcases lt_trichotomy s₁ q with h_lt | h_eq | h_gt
  · exact h_guard₁ q h_lt hqt
  · exact h_eq ▸ h_φs₁
  · exact h_guard₂ q hs₂q h_gt

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
`temp_linearity_past` carry the **left-associated** one; the four statements below are transcribed
from whichever `Conservativity/Star/StarAxiomValidity.lean` theorem has the matching nesting
(`starValid_linear_until_paper`, `starValid_linear_since`, `starValid_temp_linearity_paper`,
`starValid_temp_linearity_past` respectively), since only the `.inl`/`.inr` routing differs
between the variants. -/

/-- BX7 / the paper's CN over L^▷: linearity of `until`, right-associated. -/
theorem openValidIn_linearUntil (φ ψ χ θ : OpenFormula) :
    OpenValid (OpenFormula.and (OpenFormula.untl φ ψ) (OpenFormula.untl χ θ)
      |>.imp (OpenFormula.or
        (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and ψ θ))
        (OpenFormula.or
          (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and ψ χ))
          (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and φ θ))))) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_and_iff, openTruth_or_iff, openTruth_untl_iff]
  rintro ⟨⟨s₁, hts₁, h_ψs₁, h_guard₁⟩, s₂, hts₂, h_θs₂, h_guard₂⟩
  rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
  · exact .inr (.inl ⟨s₁, hts₁, ⟨h_ψs₁, h_guard₂ s₁ hts₁ h_lt⟩,
      fun r htr hrs => ⟨h_guard₁ r htr hrs, h_guard₂ r htr (lt_trans hrs h_lt)⟩⟩)
  · exact .inl ⟨s₁, hts₁, ⟨h_ψs₁, h_eq ▸ h_θs₂⟩,
      fun r htr hrs => ⟨h_guard₁ r htr hrs, h_guard₂ r htr (h_eq ▸ hrs)⟩⟩
  · exact .inr (.inr ⟨s₂, hts₂, ⟨h_guard₁ s₂ hts₂ h_gt, h_θs₂⟩,
      fun r htr hrs => ⟨h_guard₁ r htr (lt_trans hrs h_gt), h_guard₂ r htr hrs⟩⟩)

/-- BX7' over L^▷: linearity of `since`, left-associated. -/
theorem openValidIn_linearSince (φ ψ χ θ : OpenFormula) :
    OpenValid (OpenFormula.and (OpenFormula.snce φ ψ) (OpenFormula.snce χ θ)
      |>.imp (OpenFormula.or
        (OpenFormula.or
          (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and ψ θ))
          (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and ψ χ)))
        (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and φ θ)))) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_and_iff, openTruth_or_iff, openTruth_snce_iff]
  rintro ⟨⟨s₁, hs₁t, h_ψs₁, h_guard₁⟩, s₂, hs₂t, h_θs₂, h_guard₂⟩
  rcases lt_trichotomy s₂ s₁ with h_lt | h_eq | h_gt
  · exact .inl (.inr ⟨s₁, hs₁t, ⟨h_ψs₁, h_guard₂ s₁ h_lt hs₁t⟩,
      fun r hs₁r hrt => ⟨h_guard₁ r hs₁r hrt, h_guard₂ r (lt_trans h_lt hs₁r) hrt⟩⟩)
  · exact .inl (.inl ⟨s₁, hs₁t, ⟨h_ψs₁, h_eq ▸ h_θs₂⟩,
      fun r hs₁r hrt => ⟨h_guard₁ r hs₁r hrt, h_guard₂ r (h_eq ▸ hs₁r) hrt⟩⟩)
  · exact .inr ⟨s₂, hs₂t, ⟨h_guard₁ s₂ h_gt hs₂t, h_θs₂⟩,
      fun r hs₂r hrt => ⟨h_guard₁ r (lt_trans h_gt hs₂r) hrt, h_guard₂ r hs₂r hrt⟩⟩

/-- BX11 / the paper's TL over L^▷: two future witnesses are ordered, right-associated. -/
theorem openValidIn_tempLinearity (φ ψ : OpenFormula) :
    OpenValid (OpenFormula.and (OpenFormula.someFuture φ) (OpenFormula.someFuture ψ) |>.imp
      (OpenFormula.or (OpenFormula.someFuture (OpenFormula.and (OpenFormula.someFuture φ) ψ))
        (OpenFormula.or (OpenFormula.someFuture (OpenFormula.and φ ψ))
          (OpenFormula.someFuture (OpenFormula.and φ (OpenFormula.someFuture ψ)))))) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_and_iff, openTruth_or_iff, OpenTruth.someFuture_iff]
  rintro ⟨⟨s₁, hts₁, hφ⟩, s₂, hts₂, hψ⟩
  rcases lt_trichotomy s₁ s₂ with h | h | h
  · exact .inr (.inr ⟨s₁, hts₁, hφ, s₂, h, hψ⟩)
  · exact .inr (.inl ⟨s₁, hts₁, hφ, h ▸ hψ⟩)
  · exact .inl ⟨s₂, hts₂, ⟨s₁, h, hφ⟩, hψ⟩

/-- BX11' over L^▷, the past form, left-associated. -/
theorem openValidIn_tempLinearityPast (φ ψ : OpenFormula) :
    OpenValid (OpenFormula.and (OpenFormula.somePast φ) (OpenFormula.somePast ψ) |>.imp
      (OpenFormula.or (OpenFormula.somePast (OpenFormula.and φ ψ))
        (OpenFormula.or (OpenFormula.somePast (OpenFormula.and φ (OpenFormula.somePast ψ)))
          (OpenFormula.somePast (OpenFormula.and (OpenFormula.somePast φ) ψ))))) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_and_iff, openTruth_or_iff, OpenTruth.somePast_iff]
  rintro ⟨⟨s₁, hs₁t, hφ⟩, s₂, hs₂t, hψ⟩
  rcases lt_trichotomy s₁ s₂ with h | h | h
  · exact .inr (.inr ⟨s₂, hs₂t, ⟨s₁, h, hφ⟩, hψ⟩)
  · exact .inl ⟨s₁, hs₁t, hφ, h ▸ hψ⟩
  · exact .inr (.inl ⟨s₁, hs₁t, hφ, s₂, h, hψ⟩)

/-! ## The `F`/`P` equivalence block, per constructor

The four schemata relating `U`/`S` to `F`/`P`: an `until` witness is a future witness (BX10,
BX10'), and `F`/`P` is `U`/`S` at the trivial guard (BX12, BX12'). -/

/-- BX10 over L^▷: an `until` witness is a future witness. -/
theorem openValidIn_untilF (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.untl φ ψ).imp (OpenFormula.someFuture ψ)) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_untl_iff, OpenTruth.someFuture_iff]
  rintro ⟨s, hts, h_ψs, _⟩
  exact ⟨s, hts, h_ψs⟩

/-- BX10' over L^▷, the past mirror of `openValidIn_untilF`. -/
theorem openValidIn_sinceP (φ ψ : OpenFormula) :
    OpenValid ((OpenFormula.snce φ ψ).imp (OpenFormula.somePast ψ)) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, openTruth_snce_iff, OpenTruth.somePast_iff]
  rintro ⟨s, hst, h_ψs, _⟩
  exact ⟨s, hst, h_ψs⟩

/-- BX12 over L^▷: `F` is `U` at the trivial guard. -/
theorem openValidIn_FUntilEquiv (φ : OpenFormula) :
    OpenValid ((OpenFormula.someFuture φ).imp
      (OpenFormula.untl (OpenFormula.bot.imp OpenFormula.bot) φ)) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, OpenTruth.someFuture_iff, openTruth_untl_iff]
  rintro ⟨s, hts, h_φs⟩
  exact ⟨s, hts, h_φs, fun _ _ _ => id⟩

/-- BX12' over L^▷, the past mirror of `openValidIn_FUntilEquiv`. -/
theorem openValidIn_PSinceEquiv (φ : OpenFormula) :
    OpenValid ((OpenFormula.somePast φ).imp
      (OpenFormula.snce (OpenFormula.bot.imp OpenFormula.bot) φ)) := by
  refine OpenValid.of_forall fun F M τ t => ?_
  simp only [openTruth_imp_iff, OpenTruth.somePast_iff, openTruth_snce_iff]
  rintro ⟨s, hst, h_φs⟩
  exact ⟨s, hst, h_φs, fun _ _ _ => id⟩

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

/-! ## The two `K±` clause lemmas

`OpenFormula.kPlus` / `OpenFormula.kMinus` (declared beside `OpenAxiom` in
`OpenLanguage/OpenAxioms.lean`, since the Dedekind schemata are their only consumers) unfolded
into the shape the Dedekind arms consume. Transcriptions of `starKPlus_iff` / `starKMinus_iff`. -/

/-- `K⁺φ` at `t`: every point above `t` has a `φ`-point strictly between. -/
theorem openKPlus_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : OpenFormula) :
    OpenTruthAt M τ t φ.kPlus ↔
      ∀ s : F.Duration, t < s → ∃ r : F.Duration, t < r ∧ r < s ∧ OpenTruthAt M τ r φ := by
  simp only [OpenFormula.kPlus, OpenFormula.neg, OpenFormula.top, OpenTruthAt]
  constructor
  · intro h s hs
    by_contra hc
    push Not at hc
    exact h ⟨s, hs, id, fun r h1 h2 hr => hc r h1 h2 hr⟩
  · rintro h ⟨s, hs, -, hall⟩
    obtain ⟨r, h1, h2, hr⟩ := h s hs
    exact hall r h1 h2 hr

/-- `K⁻φ` at `t`: the past mirror of `openKPlus_iff`. -/
theorem openKMinus_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : OpenFormula) :
    OpenTruthAt M τ t φ.kMinus ↔
      ∀ s : F.Duration, s < t → ∃ r : F.Duration, s < r ∧ r < t ∧ OpenTruthAt M τ r φ := by
  simp only [OpenFormula.kMinus, OpenFormula.neg, OpenFormula.top, OpenTruthAt]
  constructor
  · intro h s hs
    by_contra hc
    push Not at hc
    exact h ⟨s, hs, id, fun r h1 h2 hr => hc r h1 h2 hr⟩
  · rintro h ⟨s, hs, -, hall⟩
    obtain ⟨r, h1, h2, hr⟩ := h s hs
    exact hall r h1 h2 hr

/-! ## The discrete-uniformity block, per constructor

The five Layer-5 schemata, each a **closed** formula at `.Base`. They are therefore literally
`ofPlus` images, and their validity transports along `openValid_ofPlus_iff` from
`plusAxiom_validIn_min` with no L^▷ argument at all.

**Transport rather than a direct proof is the right route here, and not merely the cheap one.**
Each of these records a *frame-level* uniformity fact — that a regular task frame's discreteness is
symmetric, propagates along the order and is modally necessary — proved once at the L level
(`Metalogic/Soundness.lean`'s uniformity block). A direct L^▷ proof would re-derive that frame
reasoning, not transcribe a truth-clause argument. -/

/-- `U(⊤,⊥) → S(⊤,⊥)` over L^▷, by transport. -/
theorem openValidIn_discreteSymmFwd :
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.snce OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot))) :=
  (openValid_ofPlus_iff
    ((PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot)).imp
      (PlusFormula.snce PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot)))).mpr
    (plusAxiom_validIn_min PlusAxiom.discrete_symm_fwd)

/-- `S(⊤,⊥) → U(⊤,⊥)` over L^▷, by transport. -/
theorem openValidIn_discreteSymmBwd :
    OpenValid ((OpenFormula.snce OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot))) :=
  (openValid_ofPlus_iff
    ((PlusFormula.snce PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot)).imp
      (PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot)))).mpr
    (plusAxiom_validIn_min PlusAxiom.discrete_symm_bwd)

/-- `U(⊤,⊥) → G(U(⊤,⊥))` over L^▷, by transport. -/
theorem openValidIn_discretePropagateFwd :
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.allFuture
        (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)))) :=
  (openValid_ofPlus_iff
    ((PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot)).imp
      (PlusFormula.allFuture
        (PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot))))).mpr
    (plusAxiom_validIn_min PlusAxiom.discrete_propagate_fwd)

/-- `U(⊤,⊥) → H(U(⊤,⊥))` over L^▷, by transport. -/
theorem openValidIn_discretePropagateBwd :
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.allPast
        (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)))) :=
  (openValid_ofPlus_iff
    ((PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot)).imp
      (PlusFormula.allPast
        (PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot))))).mpr
    (plusAxiom_validIn_min PlusAxiom.discrete_propagate_bwd)

/-- `U(⊤,⊥) → □(U(⊤,⊥))` over L^▷, by transport. -/
theorem openValidIn_discreteBoxNecessity :
    OpenValid ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
      (OpenFormula.box
        (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)))) :=
  (openValid_ofPlus_iff
    ((PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot)).imp
      (PlusFormula.box
        (PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot))))).mpr
    (plusAxiom_validIn_min PlusAxiom.discrete_box_necessity)

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
  simp only [openTruth_imp_iff, OpenTruth.someFuture_iff, openTruth_untl_iff,
    OpenTruth.neg_iff]
  rintro ⟨s, hts, hs⟩
  exact FormalSystem.Metalogic.SoundnessLemmas.exists_nearest_gt
    (P := fun x => OpenTruthAt M τ x φ) hts hs

/-- Prior-SZ over L^▷ at `.ZTime`, the past dual — through `exists_nearest_lt`, which is itself
`exists_nearest_gt` at `Dᵒᵈ`. The dualisation is of the *carrier*, never of the formula. -/
theorem openValidIn_priorSZ (φ : OpenFormula) :
    OpenValidIn FrameClass.ZTime (φ.somePast.imp (OpenFormula.snce φ.neg φ)) := by
  refine fun F hF M τ t => ?_
  sat_intro hF
  simp only [openTruth_imp_iff, OpenTruth.somePast_iff, openTruth_snce_iff,
    OpenTruth.neg_iff]
  rintro ⟨s, hst, hs⟩
  exact FormalSystem.Metalogic.SoundnessLemmas.exists_nearest_lt
    (P := fun x => OpenTruthAt M τ x φ) hst hs

/-- Z1 over L^▷ at `.ZTime`, through `forall_gt_of_succ_step`. -/
theorem openValidIn_z1 (φ : OpenFormula) :
    OpenValidIn FrameClass.ZTime ((φ.allFuture.imp φ).allFuture.imp
      (φ.allFuture.someFuture.imp φ.allFuture)) := by
  refine fun F hF M τ t => ?_
  sat_intro hF
  simp only [openTruth_imp_iff, openTruth_allFuture_iff, OpenTruth.someFuture_iff]
  rintro h_GGpIp ⟨s₀, hts₀, hs₀⟩
  exact FormalSystem.Metalogic.SoundnessLemmas.forall_gt_of_succ_step
    (P := fun x => OpenTruthAt M τ x φ) h_GGpIp hts₀ hs₀

/-- The temporal dual of `openValidIn_z1`, through `forall_lt_of_pred_step`. Z1 has no past twin
among the schemata, so this dual is named here. -/
theorem openValidIn_z1_reflectDual (φ : OpenFormula) :
    OpenValidIn FrameClass.ZTime ((φ.allPast.imp φ).allPast.imp
      (φ.allPast.somePast.imp φ.allPast)) := by
  refine fun F hF M τ t => ?_
  sat_intro hF
  simp only [openTruth_imp_iff, openTruth_allPast_iff, OpenTruth.somePast_iff]
  rintro h_HHpIp ⟨s₀, hs₀t, hs₀⟩
  exact FormalSystem.Metalogic.SoundnessLemmas.forall_lt_of_pred_step
    (P := fun x => OpenTruthAt M τ x φ) h_HHpIp hs₀t hs₀

/-- Prior-U (gap form) over L^▷ at `.RTime`. The least upper bound of the set of times whose whole
open past back to `t` satisfies `φ` is the gap point. -/
theorem openValidIn_priorUGap (φ : OpenFormula) :
    OpenValidIn FrameClass.RTime
      ((OpenFormula.and (OpenFormula.untl φ OpenFormula.top) φ.neg.someFuture).imp
        (OpenFormula.untl φ (OpenFormula.or φ.neg (OpenFormula.kPlus φ.neg)))) := by
  refine fun F h_lub M τ t h_ant => ?_
  sat_intro h_lub
  simp only [openTruth_and_iff, openTruth_untl_iff, OpenTruth.someFuture_iff,
    OpenTruth.neg_iff] at h_ant
  obtain ⟨h1, h2⟩ := h_ant
  obtain ⟨s0, hts0, -, hp0⟩ := h1
  obtain ⟨w0, htw0, hnpw0⟩ := h2
  set A : Set F.Duration :=
    {u : F.Duration | t < u ∧ ∀ r : F.Duration, t < r → r < u → OpenTruthAt M τ r φ} with hA
  have hs0A : s0 ∈ A := ⟨hts0, hp0⟩
  have hAbdd : BddAbove A := by
    refine ⟨w0, ?_⟩
    intro u hu
    by_contra hvu
    exact hnpw0 (hu.2 w0 htw0 (lt_of_not_ge hvu))
  obtain ⟨s, hs⟩ := h_lub A ⟨s0, hs0A⟩ hAbdd
  have hts : t < s := lt_of_lt_of_le hts0 (hs.1 hs0A)
  have hguard : ∀ r : F.Duration, t < r → r < s → OpenTruthAt M τ r φ := by
    intro r htr hrs
    obtain ⟨u, huA, hru, -⟩ := hs.exists_between hrs
    exact huA.2 r htr hru
  simp only [openTruth_untl_iff, openTruth_or_iff, OpenTruth.neg_iff, openKPlus_iff]
  refine ⟨s, hts, ?_, hguard⟩
  by_cases hps : OpenTruthAt M τ s φ
  · refine .inr fun w hsw => ?_
    by_contra hw
    push Not at hw
    have hwA : w ∈ A := by
      refine ⟨lt_trans hts hsw, ?_⟩
      intro r htr hrw
      rcases lt_trichotomy r s with h | h | h
      · exact hguard r htr h
      · exact h ▸ hps
      · exact hw r h hrw
    exact absurd (hs.1 hwA) (not_le_of_gt hsw)
  · exact .inl hps

/-- Prior-S (gap form) over L^▷ at `.RTime`, the past dual — through
`SoundnessLemmas.exists_isGLB_of_lub`, so the least-upper-bound hypothesis is used once and the
greatest lower bound is derived rather than assumed. -/
theorem openValidIn_priorSGap (φ : OpenFormula) :
    OpenValidIn FrameClass.RTime
      ((OpenFormula.and (OpenFormula.snce φ OpenFormula.top) φ.neg.somePast).imp
        (OpenFormula.snce φ (OpenFormula.or φ.neg (OpenFormula.kMinus φ.neg)))) := by
  refine fun F h_lub M τ t h_ant => ?_
  sat_intro h_lub
  simp only [openTruth_and_iff, openTruth_snce_iff, OpenTruth.somePast_iff,
    OpenTruth.neg_iff] at h_ant
  obtain ⟨h1, h2⟩ := h_ant
  obtain ⟨s0, hs0t, -, hp0⟩ := h1
  obtain ⟨w0, hw0t, hnpw0⟩ := h2
  set B : Set F.Duration :=
    {u : F.Duration | u < t ∧ ∀ r : F.Duration, u < r → r < t → OpenTruthAt M τ r φ} with hB
  have hs0B : s0 ∈ B := ⟨hs0t, hp0⟩
  have hBbdd : BddBelow B := by
    refine ⟨w0, ?_⟩
    intro u hu
    by_contra huw
    exact hnpw0 (hu.2 w0 (lt_of_not_ge huw) hw0t)
  obtain ⟨s, hs⟩ :=
    FormalSystem.Metalogic.SoundnessLemmas.exists_isGLB_of_lub h_lub ⟨s0, hs0B⟩ hBbdd
  have hst : s < t := lt_of_le_of_lt (hs.1 hs0B) hs0t
  have hguard : ∀ r : F.Duration, s < r → r < t → OpenTruthAt M τ r φ := by
    intro r hsr hrt
    obtain ⟨u, huB, -, hur⟩ := hs.exists_between hsr
    exact huB.2 r hur hrt
  simp only [openTruth_snce_iff, openTruth_or_iff, OpenTruth.neg_iff, openKMinus_iff]
  refine ⟨s, hst, ?_, hguard⟩
  by_cases hps : OpenTruthAt M τ s φ
  · refine .inr fun w hws => ?_
    by_contra hw
    push Not at hw
    have hwB : w ∈ B := by
      refine ⟨lt_trans hws hst, ?_⟩
      intro r hwr hrt
      rcases lt_trichotomy r s with h | h | h
      · exact hw r hwr h
      · exact h ▸ hps
      · exact hguard r h hrt
    exact absurd (hs.1 hwB) (not_le_of_gt hws)
  · exact .inl hps

/-- **Sep over L^▷ at `.RTime`.** The order-theoretic core is `SoundnessLemmas.sep_order`,
consumed unchanged at `P := {u | OpenTruthAt M τ u φ}`; nothing about `OpenFormula` enters it. -/
theorem openValidIn_sep (φ : OpenFormula) :
    OpenValidIn FrameClass.RTime
      ((OpenFormula.and (OpenFormula.kPlus φ)
        (OpenFormula.kPlus (OpenFormula.and φ (OpenFormula.untl φ.neg φ))).neg).imp
        (OpenFormula.kPlus
          (OpenFormula.and (OpenFormula.kPlus φ) (OpenFormula.kMinus φ)))) := by
  refine fun F h_lub M τ t h_ant => ?_
  sat_intro h_lub
  obtain ⟨Q, hQc, hQd⟩ :=
    FormalSystem.Metalogic.SoundnessLemmas.exists_countable_order_dense h_lub
  obtain ⟨h1, h2⟩ := (openTruth_and_iff M τ t _ _).mp h_ant
  simp only [OpenTruthAt, OpenFormula.and, OpenFormula.neg, OpenFormula.kPlus,
    OpenFormula.kMinus, OpenFormula.top] at h1 h2 ⊢
  rintro ⟨s₂, hts₂, -, hno⟩
  have hK : ∀ w, t < w → ∃ u, t < u ∧ u < w ∧ OpenTruthAt M τ u φ := by
    intro w htw
    by_contra hc
    refine h1 ⟨w, htw, fun hb => hb, ?_⟩
    intro r htr hrw hrφ
    exact hc ⟨r, htr, hrw, hrφ⟩
  have h2' : ∃ s₁, t < s₁ ∧ (True) ∧ ∀ u, t < u → u < s₁ →
      (OpenTruthAt M τ u φ → OpenTruthAt M τ u (OpenFormula.untl φ.neg φ) → False) := by
    refine Classical.byContradiction (fun hc => h2 ?_)
    intro hbad
    exact hc (by
      obtain ⟨s₁, hts₁, -, hu⟩ := hbad
      exact ⟨s₁, hts₁, trivial, fun u htu hus => Classical.byContradiction (hu u htu hus)⟩)
  obtain ⟨s₁, hts₁, -, hstart⟩ := h2'
  refine FormalSystem.Metalogic.SoundnessLemmas.sep_order h_lub Q hQc hQd
    {u | OpenTruthAt M τ u φ} t s₁ s₂ hts₁ hts₂ hK ?_ ?_
  · rintro u htu hus₁ huP ⟨w, huw, hwP, hfree⟩
    exact hstart u htu hus₁ huP ⟨w, huw, hwP, fun r hur hrw => hfree r hur hrw⟩
  · intro u htu hus₂
    have hAB : OpenTruthAt M τ u (OpenFormula.kPlus φ) →
        OpenTruthAt M τ u (OpenFormula.kMinus φ) → False := by
      intro ha hb
      exact hno u htu hus₂ (fun k => k ha hb)
    by_cases hR : ∃ w, u < w ∧ ∀ z, u < z → z < w → ¬ OpenTruthAt M τ z φ
    · exact Or.inl hR
    · refine Or.inr ?_
      have ha : OpenTruthAt M τ u (OpenFormula.kPlus φ) := by
        rw [openKPlus_iff]
        intro s hus
        by_contra hc
        exact hR ⟨s, hus, fun z huz hzs hz => hc ⟨z, huz, hzs, hz⟩⟩
      have hb := hAB ha
      refine Classical.byContradiction (fun hns => hb ?_)
      rw [openKMinus_iff]
      intro s hsu
      by_contra hc
      exact hns ⟨s, hsu, fun z hsz hzu hz => hc ⟨z, hsz, hzu, hz⟩⟩

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
  refine fun F h_lub M τ t h_ant => ?_
  sat_intro h_lub
  obtain ⟨Q, hQc, hQd⟩ :=
    FormalSystem.Metalogic.SoundnessLemmas.exists_countable_order_dense h_lub
  obtain ⟨h1, h2⟩ := (openTruth_and_iff M τ t _ _).mp h_ant
  simp only [OpenFormula.and, OpenFormula.neg, OpenFormula.kPlus, OpenFormula.kMinus,
    OpenFormula.top, OpenFormula.reflectTime, OpenTruthAt] at h1 h2 ⊢
  rintro ⟨s₂, hs₂t, -, hno⟩
  have hK : ∀ w, w < t → ∃ u, w < u ∧ u < t ∧ OpenTruthAt M τ u φ.reflectTime := by
    intro w hwt
    by_contra hc
    refine h1 ⟨w, hwt, fun hb => hb, ?_⟩
    intro r hwr hrt hrφ
    exact hc ⟨r, hwr, hrt, hrφ⟩
  have h2' : ∃ s₁, s₁ < t ∧ (True) ∧ ∀ u, u < t → s₁ < u →
      (OpenTruthAt M τ u φ.reflectTime →
        OpenTruthAt M τ u (OpenFormula.snce φ.reflectTime.neg φ.reflectTime) → False) := by
    refine Classical.byContradiction (fun hc => h2 ?_)
    intro hbad
    exact hc (by
      obtain ⟨s₁, hs₁t, -, hu⟩ := hbad
      exact ⟨s₁, hs₁t, trivial, fun u hut hs₁u => Classical.byContradiction (hu u hs₁u hut)⟩)
  obtain ⟨s₁, hs₁t, -, hstart⟩ := h2'
  refine FormalSystem.Metalogic.SoundnessLemmas.sep_order_mirror h_lub Q hQc hQd
    {u | OpenTruthAt M τ u φ.reflectTime} t s₁ s₂ hs₁t hs₂t hK ?_ ?_
  · rintro u hut hs₁u huP ⟨w, hwu, hwP, hfree⟩
    exact hstart u hut hs₁u huP ⟨w, hwu, hwP, fun r hwr hru => hfree r hwr hru⟩
  · intro u hut hs₂u
    have hAB : OpenTruthAt M τ u (OpenFormula.kMinus φ.reflectTime) →
        OpenTruthAt M τ u (OpenFormula.kPlus φ.reflectTime) → False := by
      intro ha hb
      exact hno u hs₂u hut (fun k => k ha hb)
    by_cases hL : ∃ w, w < u ∧ ∀ z, w < z → z < u → ¬ OpenTruthAt M τ z φ.reflectTime
    · exact Or.inl hL
    · refine Or.inr ?_
      have ha : OpenTruthAt M τ u (OpenFormula.kMinus φ.reflectTime) := by
        rw [openKMinus_iff]
        intro s hsu
        by_contra hc
        exact hL ⟨s, hsu, fun z hsz hzu hz => hc ⟨z, hsz, hzu, hz⟩⟩
      have hb := hAB ha
      refine Classical.byContradiction (fun hns => hb ?_)
      rw [openKPlus_iff]
      intro s hus
      by_contra hc
      exact hns ⟨s, hus, fun z huz hzs hz => hc ⟨z, huz, hzs, hz⟩⟩

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
  simp only [openTruth_imp_iff, openTruth_allFuture_iff]
  intro h_GG s hts
  obtain ⟨r, htr, hrs⟩ := @DenselyOrdered.dense F.Duration _ h_dense t s hts
  exact h_GG r htr s hrs

/-- The temporal dual of `openValidIn_density`: `HHφ → Hφ`, again at `.Dense`. -/
theorem openValidIn_density_reflectDual (φ : OpenFormula) :
    OpenValidIn FrameClass.Dense ((φ.allPast.allPast).imp φ.allPast) := by
  refine fun F h_dense M τ t => ?_
  sat_intro h_dense
  simp only [openTruth_imp_iff, openTruth_allPast_iff]
  intro h_HH s hst
  obtain ⟨r, hsr, hrt⟩ := @DenselyOrdered.dense F.Duration _ h_dense s t hst
  exact h_HH r hrt s hsr

/-- The dense indicator over L^▷ at `.Dense`: `¬U(⊤,⊥)`. A witness `s > t` with no point strictly
between contradicts density. -/
theorem openValidIn_denseIndicator :
    OpenValidIn FrameClass.Dense
      (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).neg := by
  refine fun F h_dense M τ t => ?_
  sat_intro h_dense
  rw [OpenTruth.neg_iff, openTruth_untl_iff]
  rintro ⟨s, hts, -, hall⟩
  obtain ⟨r, htr, hrs⟩ := @DenselyOrdered.dense F.Duration _ h_dense t s hts
  exact hall r htr hrs

/-- The temporal dual of the dense indicator: `¬S(⊤,⊥)`, again at `.Dense`. -/
theorem openValidIn_denseIndicator_reflectDual :
    OpenValidIn FrameClass.Dense
      (OpenFormula.snce OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).neg := by
  refine fun F h_dense M τ t => ?_
  sat_intro h_dense
  rw [OpenTruth.neg_iff, openTruth_snce_iff]
  rintro ⟨s, hst, -, hall⟩
  obtain ⟨r, hsr, hrt⟩ := @DenselyOrdered.dense F.Duration _ h_dense s t hst
  exact hall r hsr hrt

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
  OpenValid.of_forall fun _ _ _ _ h1 h2 σ hs => h1 σ hs (h2 σ hs)

/-- ST over L^▷: state equality is reflexive. -/
theorem openValidIn_stabT (φ : OpenFormula) :
    OpenValid ((OpenFormula.stab φ).imp φ) :=
  OpenValid.of_forall fun _ _ τ _ h => h τ rfl

/-- S4 for `⊡` over L^▷: state equality at a fixed time is transitive. -/
theorem openValidIn_stab4 (φ : OpenFormula) :
    OpenValid ((OpenFormula.stab φ).imp (OpenFormula.stab (OpenFormula.stab φ))) := by
  refine OpenValid.of_forall fun F M τ t h => ?_
  intro σ hσsame ρ hρsame
  exact h ρ (hσsame.trans hρsame)

/-- S5 for `⊡` over L^▷: state equality at a fixed time is symmetric. -/
theorem openValidIn_stab5 (φ : OpenFormula) :
    OpenValid ((dstab φ).imp (OpenFormula.stab (dstab φ))) := by
  refine OpenValid.of_forall fun F M τ t h => ?_
  intro σ hσsame
  rw [OpenTruth.dstab_iff] at h ⊢
  obtain ⟨ρ, hρsame, hφ⟩ := h
  exact ⟨ρ, hσsame.symm.trans hρsame, hφ⟩

/-- MS over L^▷: `⟨τ⟩_x ⊆ H_F`, so `□` is stronger than `⊡`. -/
theorem openValidIn_boxStab (φ : OpenFormula) :
    OpenValid ((OpenFormula.box φ).imp (OpenFormula.stab φ)) :=
  OpenValid.of_forall fun _ _ _ _ h σ _ => h σ

/-- AS over L^▷: the atom clause reads the world state alone, which the `stab` clause fixes. The
schema stays atom-restricted — widening it would change TM⁺ — though its semantic witness is the
whole state-locality fragment. -/
theorem openValidIn_atomStab (p : Atom) :
    OpenValid ((OpenFormula.atom p).imp (OpenFormula.stab (OpenFormula.atom p))) := by
  refine OpenValid.of_forall fun F M τ t h => ?_
  intro σ hsame
  rw [OpenTruth.atom_iff] at h ⊢
  rw [← hsame]
  exact h

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

end FormalSystem.Metalogic.Conservativity
