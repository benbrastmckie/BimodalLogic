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

The Reynolds basis derives CO. The **converse is not claimed and is believed false**: a ℚ-flow
with isolated `¬p` points accumulating at a gap from above validates every CO instance while
refuting Prior-U — the classical Stavi US-vs-FO phenomenon. That is a pen-and-paper
observation, not a machine-checked one; nothing here depends on it.
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
    ⊢[fc] (Formula.untl Formula.bot ψ).imp Formula.bot :=
  let weaken : ⊢[fc] (Formula.untl Formula.bot ψ).imp (Formula.untl Formula.bot Formula.top) :=
    mp (DerivationTree.temporal_necessitation _ (impTop (fc := fc) ψ))
      (baseThm (untilMonoGuard ψ Formula.top Formula.bot))
  impTrans weaken notSomeFutureBot

/-- `⊢[fc] S(⊥, ψ) → ⊥`. -/
private noncomputable def notSnceBot {fc : FrameClass} (ψ : Formula) :
    ⊢[fc] (Formula.snce Formula.bot ψ).imp Formula.bot :=
  let weaken : ⊢[fc] (Formula.snce Formula.bot ψ).imp (Formula.snce Formula.bot Formula.top) :=
    mp (FormalSystem.Theorems.pastNecessitation _ (impTop (fc := fc) ψ))
      (baseThm (sinceMonoGuard ψ Formula.top Formula.bot))
  impTrans weaken notSomePastBot

/-- If the event of an `Until` is refutable, the `Until` is refutable. -/
private noncomputable def untlEventBot {fc : FrameClass} {E : Formula} (ψ : Formula)
    (h : ⊢[fc] E.imp Formula.bot) : ⊢[fc] (Formula.untl E ψ).imp Formula.bot :=
  impTrans
    (mp (DerivationTree.temporal_necessitation _ h)
      (baseThm (untilMonoEvent E Formula.bot ψ)))
    (notUntlBot ψ)

/-- If the event of a `Since` is refutable, the `Since` is refutable. -/
private noncomputable def snceEventBot {fc : FrameClass} {E : Formula} (ψ : Formula)
    (h : ⊢[fc] E.imp Formula.bot) : ⊢[fc] (Formula.snce E ψ).imp Formula.bot :=
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
    ⊢[fc] ψ.allPast.someFuture.imp (Formula.untl Formula.top ψ) :=
  let χ := ψ.allPast
  let accum : ⊢[fc] (Formula.untl χ Formula.top).imp
      (Formula.untl χ (Formula.and Formula.top (Formula.untl χ Formula.top))) :=
    DerivationTree.axiom [] _ (Axiom.self_accum_until Formula.top χ) (FrameClass.base_le fc)
  let guardImp : ⊢[fc] (Formula.and Formula.top (Formula.untl χ Formula.top)).imp ψ :=
    impTrans (rceImp Formula.top (Formula.untl χ Formula.top))
      (show ⊢[fc] (Formula.untl χ Formula.top).imp ψ from someFutureAllPastImp ψ)
  let strengthen : ⊢[fc]
      (Formula.untl χ (Formula.and Formula.top (Formula.untl χ Formula.top))).imp
        (Formula.untl χ ψ) :=
    mp (DerivationTree.temporal_necessitation _ guardImp)
      (baseThm (untilMonoGuard (Formula.and Formula.top (Formula.untl χ Formula.top)) ψ χ))
  let weakenEvent : ⊢[fc] (Formula.untl χ ψ).imp (Formula.untl Formula.top ψ) :=
    mp (DerivationTree.temporal_necessitation _ (impTop (fc := fc) χ))
      (baseThm (untilMonoEvent χ Formula.top ψ))
  show ⊢[fc] (Formula.untl χ Formula.top).imp (Formula.untl Formula.top ψ) from
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
    ⊢[fc] (Formula.snce (Formula.and ψ.allPast ψ) ψ).imp ψ.allPast :=
  let P : Formula := ψ.neg.somePast
  let G1 : Formula := Formula.and Formula.top P
  let E : Formula := Formula.and ψ.allPast ψ
  let Γ : Context := [P, Formula.snce E ψ]
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
  let hSnce : Γ ⊢[fc] Formula.snce E ψ :=
    DerivationTree.assumption _ _ (List.Mem.tail _ (List.Mem.head _))
  let hPast : Γ ⊢[fc] P := DerivationTree.assumption _ _ (List.Mem.head _)
  let hAccum : Γ ⊢[fc] Formula.snce ψ.neg G1 :=
    ctxMp (thmIn (DerivationTree.axiom [] _ (Axiom.self_accum_since Formula.top ψ.neg)
      (FrameClass.base_le fc))) hPast
  let hSplit : Γ ⊢[fc]
      Formula.or
        (Formula.or
          (Formula.snce (Formula.and ψ.neg E) (Formula.and G1 ψ))
          (Formula.snce (Formula.and ψ.neg ψ) (Formula.and G1 ψ)))
        (Formula.snce (Formula.and G1 E) (Formula.and G1 ψ)) :=
    ctxMp (thmIn (DerivationTree.axiom [] _ (Axiom.linear_since G1 ψ.neg ψ E)
      (FrameClass.base_le fc))) (andIntro hAccum hSnce)
  let hBot : Γ ⊢[fc] Formula.bot :=
    orElimBot hSplit
      (thmIn (deductionTheorem [] _ Formula.bot
        (orElimBot
          (DerivationTree.assumption
            [Formula.or (Formula.snce (Formula.and ψ.neg E) (Formula.and G1 ψ))
              (Formula.snce (Formula.and ψ.neg ψ) (Formula.and G1 ψ))] _ (List.Mem.head _))
          (thmIn (snceEventBot (Formula.and G1 ψ) ev1))
          (thmIn (snceEventBot (Formula.and G1 ψ) ev2)))))
      (thmIn (snceEventBot (Formula.and G1 ψ) ev3))
  deductionTheorem [] (Formula.snce E ψ) ψ.allPast
    (show [Formula.snce E ψ] ⊢[fc] P.imp Formula.bot from
      deductionTheorem [Formula.snce E ψ] P Formula.bot hBot)

end FormalSystem.Theorems.DedekindDerived
