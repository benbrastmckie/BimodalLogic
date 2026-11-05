/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.OpenLanguage.OpenAxioms
import FormalSystem.OpenLanguage.OpenValidity
import FormalSystem.OpenLanguage.OpenOckhamist
import FormalSystem.OpenLanguage.OpenReversal

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

## References

* `FormalSystem/Metalogic/Conservativity/Plus/AxiomValidity.lean` — the TM⁺ counterpart, whose
  45 TM-schema arms route through atomization; that route is unavailable here (see the
  directory README)
* `FormalSystem/PlusLanguage/PlusPasting.lean` — `AgreeFrom`, `AgreeUpTo` and the L⁺ congruences
  these transcribe

## Tags

open-language · soundness · axiom-validity · time-reflection
-/

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
theorem openValidIn_rigidityOpastFwd {φ : OpenFormula} (hφ : IsPureFutureOpen φ) :
    OpenValid (imp (opast φ) φ) :=
  OpenValid.of_forall_regular fun _ _ _ τ _ h => h τ fun _ _ => rfl

/-- `φ⁺ → ◁φ⁺` for pure-future `φ⁺`: the informative half. Every history agreeing with `τ` from
`t` onward agrees with it on everything `φ⁺` can see. -/
theorem openValidIn_rigidityOpastBwd {φ : OpenFormula} (hφ : IsPureFutureOpen φ) :
    OpenValid (imp φ (opast φ)) :=
  OpenValid.of_forall_regular fun _ _ M τ t h σ hag =>
    (openTruthAt_congr_agreeFrom M hφ τ σ t hag).mp h

/-- `▷ψ⁻ → ψ⁻` for pure-past `ψ⁻`. -/
theorem openValidIn_rigidityOfutFwd {φ : OpenFormula} (hφ : IsPurePastOpen φ) :
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

end FormalSystem.Metalogic.Conservativity
