/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
import FormalSystem.Metalogic.Core.DeductionTheorem
import FormalSystem.Theorems.TemporalDerived
import FormalSystem.Theorems.Propositional.Core
import FormalSystem.Theorems.Propositional.Connectives

/-!
# Derived Theorems of the Dedekind Frame Class

Hilbert-side companion to `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean`. The
headline result is `co_derived`: the paper's **CO** principle

  `CO(φ) := △(Hφ → F(Hφ)) → (Hφ → Gφ)`

is a *theorem* of this repository's Dedekind class, derived from the retained Reynolds basis.
No `Axiom.co` constructor is added; the official Dedekind-class basis remains
`Axiom.prior_U_gap` / `Axiom.prior_S_gap` / `Axiom.sep`.

## Scaffolding

Everything before `co_derived` is frame-class-generic base machinery, provable at
`FrameClass.Base`:

- `alwaysElimPast` / `alwaysElimHere` / `alwaysElimFuture` — `fc`-generic wrappers around the
  existing `TemporalDerived` conjunction-eliminators for `△ψ = Hψ ∧ (ψ ∧ Gψ)`.
- `notUntlBot` / `notSnceBot`, `untlEventBot` / `snceEventBot` — a `U`/`S` whose event is
  refutable is itself refutable.
- `someFutureAllPastImp` (**L2**) — `F(Hψ) → ψ`. Contraposed BX4 (`connect_future`).
- `someFutureAllPastUntlTop` (**L1**) — `F(Hψ) → U(⊤, ψ)`. The guard-strengthening step: BX5
  (`self_accum_until`) deposits `F(Hψ)` into the guard, L2 turns that deposit into `ψ`
  pointwise via BX2G, and BX3 weakens the event to `⊤`.
- `snceAllPastAndImp` (**L3**) — `S(Hψ ∧ ψ, ψ) → Hψ`. The point-shifting step: BX5' deposits
  `P(¬ψ)` into the guard of an assumed `P(¬ψ)`, after which all three disjuncts of BX7'
  (`linear_since`) carry a contradictory event.

## Main result

- `co_derived {fc} (h_fc : FrameClass.Dedekind ≤ fc) (φ) : ⊢[fc] Formula.co φ`.

## Direction of the result

The Reynolds basis derives CO. The **converse fails, and the failure is machine-checked**: see
`FormalSystem.Metalogic.Independence.CoNotPriorU`, where `co_not_derives_prior_U_gap` and
`co_not_derives_prior_U_gap_schema` refute the derivation of `Axiom.prior_U_gap` from CO over
the dense base, using the periodic clock model (`D = ℚ`, `W = ℚ ⧸ ℤ`) with a symmetric
irrational arc valuation.

An earlier note here proposed a different witness — a ℚ-flow with isolated `¬p` points
accumulating at a gap from above, framed as "the classical Stavi US-vs-FO phenomenon". That
witness is **refuted**: in it `¬U(¬p,p) ∧ F(U(¬p,p))` defines the cut, so CO fails there too.
It should not be re-attempted.
-/

namespace FormalSystem.Theorems.DedekindDerived

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Propositional
open FormalSystem.Theorems.TemporalDerived
open FormalSystem.Metalogic.Core

/-! ## Local plumbing -/

/-- Modus ponens inside a context. -/
private def ctxMp {fc : FrameClass} {Γ : Context} {A B : Formula}
    (h1 : Γ ⊢[fc] A.imp B) (h2 : Γ ⊢[fc] A) : Γ ⊢[fc] B :=
  DerivationTree.modus_ponens Γ A B h1 h2

/-- Import an `fc`-theorem into any context. -/
private def thmIn {fc : FrameClass} {Γ : Context} {A : Formula}
    (d : DerivationTree fc [] A) : DerivationTree fc Γ A :=
  DerivationTree.weakening [] Γ A d (List.nil_subset Γ)

/-- Lift a `FrameClass.Base` theorem to any frame class. -/
private def baseThm {fc : FrameClass} {A : Formula}
    (d : DerivationTree FrameClass.Base [] A) : DerivationTree fc [] A :=
  d.lift (FrameClass.base_le fc)

/-- `⊢ ⊤`. -/
private def topThm {fc : FrameClass} : ⊢[fc] Formula.top := identity Formula.bot

/-- `⊢ A → ⊤`. -/
private def impTop {fc : FrameClass} (A : Formula) : ⊢[fc] A.imp Formula.top :=
  mp topThm (DerivationTree.axiom [] _ (Axiom.prop_s Formula.top A) (FrameClass.base_le fc))

/-- From `⊢ A → ¬B` and `⊢ B`, conclude `⊢ A → ⊥`. -/
private def impBotOfImpNeg {fc : FrameClass} {A B : Formula}
    (h1 : ⊢[fc] A.imp B.neg) (h2 : ⊢[fc] B) : ⊢[fc] A.imp Formula.bot :=
  mp h2 (mp (show ⊢[fc] A.imp (B.imp Formula.bot) from h1)
    (theoremFlip (fc := fc) (A := A) (B := B) (C := Formula.bot)))

/-- Conjunction introduction in context. -/
private def andIntro {fc : FrameClass} {Γ : Context} {A B : Formula}
    (ha : Γ ⊢[fc] A) (hb : Γ ⊢[fc] B) : Γ ⊢[fc] A.and B :=
  ctxMp (ctxMp (thmIn (pairing A B)) ha) hb

/-- Left conjunction elimination in context. -/
private noncomputable def andFst {fc : FrameClass} {Γ : Context} {A B : Formula}
    (h : Γ ⊢[fc] A.and B) : Γ ⊢[fc] A :=
  ctxMp (thmIn (lceImp A B)) h

/-- Right conjunction elimination in context. -/
private noncomputable def andSnd {fc : FrameClass} {Γ : Context} {A B : Formula}
    (h : Γ ⊢[fc] A.and B) : Γ ⊢[fc] B :=
  ctxMp (thmIn (rceImp A B)) h

/-- Disjunction elimination into `⊥`: `Formula.or A B` unfolds to `¬A → B`, so refuting both
disjuncts is a pair of modus ponens steps. -/
private def orElimBot {fc : FrameClass} {Γ : Context} {A B : Formula}
    (h : Γ ⊢[fc] Formula.or A B) (ha : Γ ⊢[fc] A.imp Formula.bot)
    (hb : Γ ⊢[fc] B.imp Formula.bot) : Γ ⊢[fc] Formula.bot :=
  ctxMp hb (ctxMp (show Γ ⊢[fc] (A.imp Formula.bot).imp B from h) ha)

/-! ## `△`-elimination at an arbitrary frame class -/

/-- `⊢[fc] △ψ → Hψ`. -/
noncomputable def alwaysElimPast {fc : FrameClass} (ψ : Formula) :
    ⊢[fc] ψ.always.imp ψ.allPast :=
  baseThm (alwaysImpAllPast ψ)

/-- `⊢[fc] △ψ → ψ`. -/
noncomputable def alwaysElimHere {fc : FrameClass} (ψ : Formula) :
    ⊢[fc] ψ.always.imp ψ :=
  baseThm (alwaysToPresent ψ)

/-- `⊢[fc] △ψ → Gψ`. -/
noncomputable def alwaysElimFuture {fc : FrameClass} (ψ : Formula) :
    ⊢[fc] ψ.always.imp ψ.allFuture :=
  baseThm (alwaysImpAllFuture ψ)

/-! ## Contradictory `U` / `S` -/

/-- `⊢[fc] F(⊥) → ⊥`. -/
private noncomputable def notSomeFutureBot {fc : FrameClass} :
    ⊢[fc] Formula.bot.someFuture.imp Formula.bot :=
  let h1 : ⊢[fc] Formula.bot.someFuture.imp Formula.top.neg.someFuture :=
    mp (DerivationTree.temporal_necessitation _ (efqAxiom (fc := fc) Formula.top.neg))
      (baseThm (fMono Formula.bot Formula.top.neg))
  impBotOfImpNeg (impTrans h1 (baseThm (fNegG Formula.top)))
    (DerivationTree.temporal_necessitation _ (topThm (fc := fc)))

/-- `⊢[fc] P(⊥) → ⊥`. -/
private noncomputable def notSomePastBot {fc : FrameClass} :
    ⊢[fc] Formula.bot.somePast.imp Formula.bot :=
  let h1 : ⊢[fc] Formula.bot.somePast.imp Formula.top.neg.somePast :=
    mp (FormalSystem.Theorems.pastNecessitation _ (efqAxiom (fc := fc) Formula.top.neg))
      (baseThm (pMono Formula.bot Formula.top.neg))
  impBotOfImpNeg (impTrans h1 (baseThm (pNegH Formula.top)))
    (FormalSystem.Theorems.pastNecessitation _ (topThm (fc := fc)))

/-- `⊢[fc] U(⊥, ψ) → ⊥`. -/
private noncomputable def notUntlBot {fc : FrameClass} (ψ : Formula) :
    ⊢[fc] (Formula.untlQ ψ Formula.bot).imp Formula.bot :=
  let weaken : ⊢[fc] (Formula.untlQ ψ Formula.bot).imp (Formula.untlQ Formula.top Formula.bot) :=
    mp (DerivationTree.temporal_necessitation _ (impTop (fc := fc) ψ))
      (baseThm (untilMonoGuard ψ Formula.top Formula.bot))
  impTrans weaken notSomeFutureBot

/-- `⊢[fc] S(⊥, ψ) → ⊥`. -/
private noncomputable def notSnceBot {fc : FrameClass} (ψ : Formula) :
    ⊢[fc] (Formula.snceQ ψ Formula.bot).imp Formula.bot :=
  let weaken : ⊢[fc] (Formula.snceQ ψ Formula.bot).imp (Formula.snceQ Formula.top Formula.bot) :=
    mp (FormalSystem.Theorems.pastNecessitation _ (impTop (fc := fc) ψ))
      (baseThm (sinceMonoGuard ψ Formula.top Formula.bot))
  impTrans weaken notSomePastBot

/-- If the event of an `Until` is refutable, the `Until` is refutable. -/
private noncomputable def untlEventBot {fc : FrameClass} {E : Formula} (ψ : Formula)
    (h : ⊢[fc] E.imp Formula.bot) : ⊢[fc] (Formula.untlQ ψ E).imp Formula.bot :=
  impTrans
    (mp (DerivationTree.temporal_necessitation _ h)
      (baseThm (untilMonoEvent E Formula.bot ψ)))
    (notUntlBot ψ)

/-- If the event of a `Since` is refutable, the `Since` is refutable. -/
private noncomputable def snceEventBot {fc : FrameClass} {E : Formula} (ψ : Formula)
    (h : ⊢[fc] E.imp Formula.bot) : ⊢[fc] (Formula.snceQ ψ E).imp Formula.bot :=
  impTrans
    (mp (FormalSystem.Theorems.pastNecessitation _ h)
      (baseThm (sinceMonoEvent E Formula.bot ψ)))
    (notSnceBot ψ)

/-! ## The three point-shifting lemmas -/

/--
**L2**: `⊢[fc] F(Hψ) → ψ`.

`Hψ` is *definitionally* `¬P(¬ψ)` and `G(P¬ψ)` is *definitionally* `¬F(Hψ)` under the tree's
abbreviations, so BX4 (`connect_future` at `¬ψ`: `¬ψ → G(P¬ψ)`) contraposes to
`¬¬F(Hψ) → ¬¬ψ`, and double negation on both ends closes the gap.
-/
noncomputable def someFutureAllPastImp {fc : FrameClass} (ψ : Formula) :
    ⊢[fc] ψ.allPast.someFuture.imp ψ :=
  let connect : ⊢[fc] ψ.neg.imp ψ.neg.somePast.allFuture :=
    DerivationTree.axiom [] _ (Axiom.connect_future ψ.neg) (FrameClass.base_le fc)
  let contra : ⊢[fc] ψ.neg.somePast.allFuture.neg.imp ψ.neg.neg :=
    mp connect (baseThm (contrapositive ψ.neg ψ.neg.somePast.allFuture))
  impTrans (notNotIntro ψ.allPast.someFuture)
    (impTrans (show ⊢[fc] ψ.allPast.someFuture.neg.neg.imp ψ.neg.neg from contra)
      (doubleNegation ψ))

/--
**L1**: `⊢[fc] F(Hψ) → U(⊤, ψ)`.

The one guard-strengthening step in the development. BX5 (`self_accum_until`) turns
`U(Hψ, ⊤)` into `U(Hψ, ⊤ ∧ U(Hψ, ⊤))`, depositing `F(Hψ)` at every point of the open guard
interval; L2 converts that deposit into `ψ` pointwise via BX2G; BX3 then weakens the event
`Hψ` to `⊤`.
-/
noncomputable def someFutureAllPastUntlTop {fc : FrameClass} (ψ : Formula) :
    ⊢[fc] ψ.allPast.someFuture.imp (Formula.untlQ ψ Formula.top) :=
  let χ := ψ.allPast
  let accum : ⊢[fc] (Formula.untlQ Formula.top χ).imp
      (Formula.untlQ (Formula.and Formula.top (Formula.untlQ Formula.top χ)) χ) :=
    DerivationTree.axiom [] _ (Axiom.self_accum_until Formula.top χ) (FrameClass.base_le fc)
  let guardImp : ⊢[fc] (Formula.and Formula.top (Formula.untlQ Formula.top χ)).imp ψ :=
    impTrans (rceImp Formula.top (Formula.untlQ Formula.top χ))
      (show ⊢[fc] (Formula.untlQ Formula.top χ).imp ψ from someFutureAllPastImp ψ)
  let strengthen : ⊢[fc]
      (Formula.untlQ (Formula.and Formula.top (Formula.untlQ Formula.top χ)) χ).imp
        (Formula.untlQ ψ χ) :=
    mp (DerivationTree.temporal_necessitation _ guardImp)
      (baseThm (untilMonoGuard (Formula.and Formula.top (Formula.untlQ Formula.top χ)) ψ χ))
  let weakenEvent : ⊢[fc] (Formula.untlQ ψ χ).imp (Formula.untlQ ψ Formula.top) :=
    mp (DerivationTree.temporal_necessitation _ (impTop (fc := fc) χ))
      (baseThm (untilMonoEvent χ Formula.top ψ))
  show ⊢[fc] (Formula.untlQ Formula.top χ).imp (Formula.untlQ ψ Formula.top) from
    impTrans accum (impTrans strengthen weakenEvent)

/--
**L3**: `⊢[fc] S(Hψ ∧ ψ, ψ) → Hψ`.

The point-shifting step. `Hψ` unfolds to `P(¬ψ) → ⊥`, so assume both `S(Hψ ∧ ψ, ψ)` and
`P(¬ψ)`. BX5' (`self_accum_since`) upgrades the latter to `S(¬ψ, ⊤ ∧ P(¬ψ))`, depositing
`P(¬ψ)` throughout its own guard interval. BX7' (`linear_since`) then splits on the relative
position of the two witnesses, and **all three** disjuncts carry a contradictory event:

* witnesses coincide — the event asserts `¬ψ` and `ψ` at once;
* the `¬ψ`-witness is the later one — likewise `¬ψ` and `ψ`;
* the `Hψ ∧ ψ`-witness is the later one — it inherits the deposited `P(¬ψ)` from the guard,
  and `Hψ` is definitionally `¬P(¬ψ)`.

The third bullet is exactly the information a bare `P(¬ψ)` would have lost, and is why the
self-accumulation step is needed.
-/
noncomputable def snceAllPastAndImp {fc : FrameClass} (ψ : Formula) :
    ⊢[fc] (Formula.snceQ ψ (Formula.and ψ.allPast ψ)).imp ψ.allPast :=
  let P : Formula := ψ.neg.somePast
  let G1 : Formula := Formula.and Formula.top P
  let E : Formula := Formula.and ψ.allPast ψ
  let Γ : Context := [P, Formula.snceQ ψ E]
  -- Event refutation for the first disjunct: `¬ψ ∧ (Hψ ∧ ψ)`.
  let ev1 : ⊢[fc] (Formula.and ψ.neg E).imp Formula.bot :=
    let Δ : Context := [Formula.and ψ.neg E]
    let hA : Δ ⊢[fc] Formula.and ψ.neg E :=
      DerivationTree.assumption _ _ (List.Mem.head _)
    let hneg : Δ ⊢[fc] ψ.neg := andFst hA
    let hpos : Δ ⊢[fc] ψ := andSnd (andSnd hA)
    deductionTheorem [] (Formula.and ψ.neg E) Formula.bot
      (ctxMp (show Δ ⊢[fc] ψ.imp Formula.bot from hneg) hpos)
  -- Second disjunct: `¬ψ ∧ ψ`.
  let ev2 : ⊢[fc] (Formula.and ψ.neg ψ).imp Formula.bot :=
    let Δ : Context := [Formula.and ψ.neg ψ]
    let hA : Δ ⊢[fc] Formula.and ψ.neg ψ :=
      DerivationTree.assumption _ _ (List.Mem.head _)
    deductionTheorem [] (Formula.and ψ.neg ψ) Formula.bot
      (ctxMp (show Δ ⊢[fc] ψ.imp Formula.bot from andFst hA) (andSnd hA))
  -- Third disjunct: `(⊤ ∧ P(¬ψ)) ∧ (Hψ ∧ ψ)`.
  let ev3 : ⊢[fc] (Formula.and G1 E).imp Formula.bot :=
    let Δ : Context := [Formula.and G1 E]
    let hA : Δ ⊢[fc] Formula.and G1 E :=
      DerivationTree.assumption _ _ (List.Mem.head _)
    let hP : Δ ⊢[fc] P := andSnd (andFst hA)
    let hH : Δ ⊢[fc] ψ.allPast := andFst (andSnd hA)
    deductionTheorem [] (Formula.and G1 E) Formula.bot
      (ctxMp (show Δ ⊢[fc] P.imp Formula.bot from hH) hP)
  let hSnce : Γ ⊢[fc] Formula.snceQ ψ E :=
    DerivationTree.assumption _ _ (List.Mem.tail _ (List.Mem.head _))
  let hPast : Γ ⊢[fc] P := DerivationTree.assumption _ _ (List.Mem.head _)
  let hAccum : Γ ⊢[fc] Formula.snceQ G1 ψ.neg :=
    ctxMp (thmIn (DerivationTree.axiom [] _ (Axiom.self_accum_since Formula.top ψ.neg)
      (FrameClass.base_le fc))) hPast
  let hSplit : Γ ⊢[fc]
      Formula.or
        (Formula.or
          (Formula.snceQ (Formula.and G1 ψ) (Formula.and ψ.neg E))
          (Formula.snceQ (Formula.and G1 ψ) (Formula.and ψ.neg ψ)))
        (Formula.snceQ (Formula.and G1 ψ) (Formula.and G1 E)) :=
    ctxMp (thmIn (DerivationTree.axiom [] _ (Axiom.linear_since G1 ψ.neg ψ E)
      (FrameClass.base_le fc))) (andIntro hAccum hSnce)
  let hBot : Γ ⊢[fc] Formula.bot :=
    orElimBot hSplit
      (thmIn (deductionTheorem [] _ Formula.bot
        (orElimBot
          (DerivationTree.assumption
            [Formula.or (Formula.snceQ (Formula.and G1 ψ) (Formula.and ψ.neg E))
              (Formula.snceQ (Formula.and G1 ψ) (Formula.and ψ.neg ψ))] _ (List.Mem.head _))
          (thmIn (snceEventBot (Formula.and G1 ψ) ev1))
          (thmIn (snceEventBot (Formula.and G1 ψ) ev2)))))
      (thmIn (snceEventBot (Formula.and G1 ψ) ev3))
  deductionTheorem [] (Formula.snceQ ψ E) ψ.allPast
    (show [Formula.snceQ ψ E] ⊢[fc] P.imp Formula.bot from
      deductionTheorem [Formula.snceQ ψ E] P Formula.bot hBot)

/-! ## The CO derivation -/

/--
**Event refutation at the Prior-U witness.**

`⊢[fc] (Hφ → F(Hφ)) → (((¬φ ∨ K⁺(¬φ)) ∧ S(Hφ ∧ φ, φ)) → ⊥)`.

This is the whole content of the `co_derived` endgame, packaged as a *theorem* (empty context)
so that it can be pushed under `G` by `gDistribution` and fed to BX3 at the Prior-U witness.

At the witness `s`, the `Since` conjunct — supplied by BX13 (`enrichment_until`) from the fact
that `Hφ ∧ φ` holds at the evaluation point and `φ` holds throughout the open guard interval —
yields `Hφ` at `s` by **L3**. The `△`-antecedent's `G`-component, evaluated at `s`, then gives
`F(Hφ)` there, and both disjuncts of the Prior-U consequent's event die:

* `¬φ` dies because **L2** turns `F(Hφ)` into `φ`;
* `K⁺(¬φ) = ¬U(⊤, ¬¬φ)` dies because **L1** turns `F(Hφ)` into `U(⊤, φ)`, which BX2G lifts to
  `U(⊤, ¬¬φ)`.
-/
private noncomputable def coEventBot {fc : FrameClass} (φ : Formula) :
    ⊢[fc] (φ.allPast.imp φ.allPast.someFuture).imp
      ((Formula.and (Formula.or φ.neg (Formula.kPlus φ.neg))
        (Formula.snceQ φ (Formula.and φ.allPast φ))).imp Formula.bot) :=
  let χ := φ.allPast
  let ev := Formula.or φ.neg (Formula.kPlus φ.neg)
  let sinceWit := Formula.snceQ φ (Formula.and χ φ)
  let Δ : Context := [Formula.and ev sinceWit, χ.imp χ.someFuture]
  let hAnd : Δ ⊢[fc] Formula.and ev sinceWit :=
    DerivationTree.assumption _ _ (List.Mem.head _)
  let hImp : Δ ⊢[fc] χ.imp χ.someFuture :=
    DerivationTree.assumption _ _ (List.Mem.tail _ (List.Mem.head _))
  let hχ : Δ ⊢[fc] χ := ctxMp (thmIn (snceAllPastAndImp φ)) (andSnd hAnd)
  let hFχ : Δ ⊢[fc] χ.someFuture := ctxMp hImp hχ
  let hφ : Δ ⊢[fc] φ := ctxMp (thmIn (someFutureAllPastImp φ)) hFχ
  let hU : Δ ⊢[fc] Formula.untlQ φ Formula.top :=
    ctxMp (thmIn (someFutureAllPastUntlTop φ)) hFχ
  let hUnn : Δ ⊢[fc] Formula.untlQ φ.neg.neg Formula.top :=
    ctxMp (thmIn (mp (DerivationTree.temporal_necessitation _ (notNotIntro (fc := fc) φ))
      (baseThm (untilMonoGuard φ φ.neg.neg Formula.top)))) hU
  let refuteNeg : Δ ⊢[fc] φ.neg.imp Formula.bot :=
    ctxMp (thmIn (theoremApp1 (fc := fc) (A := φ) (B := Formula.bot))) hφ
  let refuteKPlus : Δ ⊢[fc] (Formula.kPlus φ.neg).imp Formula.bot :=
    ctxMp (thmIn (theoremApp1 (fc := fc) (A := Formula.untlQ φ.neg.neg Formula.top)
      (B := Formula.bot))) hUnn
  deductionTheorem [] (χ.imp χ.someFuture) _
    (deductionTheorem [χ.imp χ.someFuture] (Formula.and ev sinceWit) Formula.bot
      (orElimBot (andFst hAnd) refuteNeg refuteKPlus))

/--
**CO is a derived theorem of the Dedekind class.**

`⊢[fc] △(Hφ → F(Hφ)) → (Hφ → Gφ)` whenever `FrameClass.Dedekind ≤ fc`.

**Source of the formula**: JPL paper anchor `TMP-CO` (the `\aitem[CO]{TMP-CO}` entry inside
`def:TMplus-c`; displayed key CO), verbatim:
"`\aitem[CO]{TMP-CO} $\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow
(\Past\varphi \rightarrow \Future\varphi)$.`"
There CO is the extra axiom of the paper's complete-order extension BX_c. The
`△` is the temporal triangle `Formula.always`, not `Formula.box`; see `Formula.co`.

**CO is derived here, not primitive.** No `Axiom.co` constructor exists; the official
Dedekind-class basis remains `Axiom.prior_U_gap` / `Axiom.prior_S_gap` / `Axiom.sep`.

**Axiom footprint** (verified against the finished derivation, not assumed): the *only*
non-base axiom consumed is `Axiom.prior_U_gap`. Neither `Axiom.prior_S_gap` nor `Axiom.sep` is
used, and neither is `Axiom.density` nor `Axiom.dense_indicator` — so the derivation in fact
goes through at any `fc` admitting Prior-U. (This is exact, not an estimate: every other
`DerivationTree.axiom` node in this file is discharged by `FrameClass.base_le`, and every
imported lemma it uses is stated at `FrameClass.Base`.) The base axioms consumed include
`prop_k`, `prop_s`, `ex_falso`, `connect_future` (BX4), `left_mono_until_G` (BX2G),
`left_mono_since_H`
(BX2H), `right_mono_until` (BX3), `right_mono_since` (BX3'), `self_accum_until` (BX5),
`self_accum_since` (BX5'), `linear_since` (BX7') and `enrichment_until` (BX13). The rules used
are modus ponens, assumption, weakening, temporal necessitation and — via
`Theorems.pastNecessitation` — temporal duality.

**Shape of the argument.** Assume `△(Hφ → F Hφ)` and `Hφ`, and for contradiction `F(¬φ)`. The
middle conjunct of the triangle gives `F(Hφ)`, whence `φ` (L2) and `U(⊤, φ)` (L1). Prior-U at
`φ` then yields `U(¬φ ∨ K⁺(¬φ), φ)`, and BX13 enriches its event with `S(Hφ ∧ φ, φ)` — the
`Since`-record of what holds at and below the evaluation point. `coEventBot`, pushed under `G`
by the triangle's `G`-component, refutes that enriched event outright, collapsing the `Until`
to `U(⊥, φ)`, which is absurd.

**Direction.** This is the Reynolds ⊢ CO direction only. The converse direction now has a
machine-checked **refutation**: `FormalSystem.Metalogic.Independence.CoNotPriorU` proves that
CO does not derive `Axiom.prior_U_gap` over the dense base, both for contexts of CO instances
(`co_not_derives_prior_U_gap`) and for a CO-closed schema system closed under modus ponens,
modal and temporal necessitation, and temporal duality
(`co_not_derives_prior_U_gap_schema`). See the module docstring.

**Semantic cross-check.** `FormalSystem.Metalogic.SoundnessLemmas.co_valid` proves
`ValidDedekindDense (Formula.co φ)` by an independent least-upper-bound argument, so soundness
applied to this derivation lands on a statement already established semantically.
-/
noncomputable def co_derived {fc : FrameClass} (h_fc : FrameClass.Dedekind ≤ fc)
    (φ : Formula) : ⊢[fc] Formula.co φ :=
  let χ := φ.allPast
  let tri := Formula.always (χ.imp χ.someFuture)
  let ev := Formula.or φ.neg (Formula.kPlus φ.neg)
  let sinceWit := Formula.snceQ φ (Formula.and χ φ)
  let enriched := Formula.and ev sinceWit
  let Γ : Context := [φ.neg.someFuture, χ, tri]
  let hTri : Γ ⊢[fc] tri :=
    DerivationTree.assumption _ _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _)))
  let hH : Γ ⊢[fc] χ := DerivationTree.assumption _ _ (List.Mem.tail _ (List.Mem.head _))
  let hFneg : Γ ⊢[fc] φ.neg.someFuture := DerivationTree.assumption _ _ (List.Mem.head _)
  -- The triangle's present-tense conjunct fires at the evaluation point.
  let hFχ : Γ ⊢[fc] χ.someFuture :=
    ctxMp (ctxMp (thmIn (alwaysElimHere (χ.imp χ.someFuture))) hTri) hH
  let hφ : Γ ⊢[fc] φ := ctxMp (thmIn (someFutureAllPastImp φ)) hFχ
  let hU : Γ ⊢[fc] Formula.untlQ φ Formula.top :=
    ctxMp (thmIn (someFutureAllPastUntlTop φ)) hFχ
  -- Prior-U at `φ` — the only non-base axiom in the whole derivation.
  let hGap : Γ ⊢[fc] Formula.untlQ φ ev :=
    ctxMp (thmIn (DerivationTree.axiom [] _ (Axiom.prior_U_gap φ) h_fc)) (andIntro hU hFneg)
  -- BX13: record `Hφ ∧ φ` at the witness as a `Since`.
  let hEnriched : Γ ⊢[fc] Formula.untlQ φ enriched :=
    ctxMp (thmIn (DerivationTree.axiom [] _
      (Axiom.enrichment_until φ ev (Formula.and χ φ)) (FrameClass.base_le fc)))
      (andIntro (andIntro hH hφ) hGap)
  -- The triangle's `G`-conjunct, pushed onto the event refutation.
  let hG : Γ ⊢[fc] (χ.imp χ.someFuture).allFuture :=
    ctxMp (thmIn (alwaysElimFuture (χ.imp χ.someFuture))) hTri
  let hGEvent : Γ ⊢[fc] (enriched.imp Formula.bot).allFuture :=
    ctxMp (ctxMp (thmIn (baseThm (gDistribution (χ.imp χ.someFuture)
      (enriched.imp Formula.bot))))
      (thmIn (DerivationTree.temporal_necessitation _ (coEventBot (fc := fc) φ)))) hG
  let hUBot : Γ ⊢[fc] Formula.untlQ φ Formula.bot :=
    ctxMp (ctxMp (thmIn (baseThm (untilMonoEvent enriched Formula.bot φ))) hGEvent) hEnriched
  let hBot : Γ ⊢[fc] Formula.bot := ctxMp (thmIn (notUntlBot φ)) hUBot
  deductionTheorem [] tri _
    (deductionTheorem [tri] χ φ.allFuture
      (show [χ, tri] ⊢[fc] φ.neg.someFuture.imp Formula.bot from
        deductionTheorem [χ, tri] φ.neg.someFuture Formula.bot hBot))

end FormalSystem.Theorems.DedekindDerived
