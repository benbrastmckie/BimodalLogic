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

end FormalSystem.Metalogic.Conservativity
