/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.PriorInterface
import FormalSystem.Metalogic.WeakCanonical.Kamp.KPlusFaithful

/-!
# The `NfMultiAnchorBridge` prior interface at the faithful eq (5.2) carrier

`PriorInterface.lean` states the bridge's two relativizing predicates —
`ExistProviders.correct` and `BracketCarrierCorrectVPrior` — against
`SemanticPriorUZ` / `SemanticPriorSZ` (`WeakCanonical/PriorDefs.lean:22`, `:33`). This module
restates both against `HasFaithfulDedekindINF` / `HasFaithfulDedekindSUP`
(`Kamp/KPlusFaithful.lean:320`, `:339`), which are Rabinovich's eq (5.2) dichotomy (PDF p.8) at
the source's own `K⁺` / `K⁻` (his Definitions (2)/(3), PDF p.3).

## Why this module is the bottom rung of the spine re-base

`ExistProviders` and `BracketCarrierCorrectVPrior` are where the Prior hypotheses *enter* the
`NfMultiAnchorBridge` tree. `PriorInterface.lean` imports only `CarrierKv.lean`, which mentions no
completeness carrier at all, and every other UZ/SZ-carrying module of the bridge sits above it:
`ExteriorFiberK`, `InteriorGateGeneralK` and `SubBracket` import it directly, and the whole
`ExteriorNegation*` / `ExteriorConverter*` / `ExteriorPinnedConverse*` / `Aggregate*` chain sits
above those. So re-basing here is what makes the rungs above it re-basable at all.

## Direction of the swap, and why it is a strengthening rather than a swap

`SemanticPriorUZ` implies `HasAttainedINF` (`prior_hasAttainedINF`, `Kamp/PriorINF.lean:230`),
which implies `HasFaithfulDedekindINF` (`HasAttainedINF.toHasFaithfulDedekindINF`,
`KPlusFaithful.lean:382`); the composite has no converse
(`hasFaithfulDedekindINF_not_implies_hasDedekindINF`, `KPlusFaithful.lean:693`). The faithful
hypothesis is therefore strictly *weaker*, so:

- a `ExistProvidersFaithful` bundle is a strictly *stronger* obligation on the provider than an
  `ExistProviders` bundle — its `correct` field must hold under less;
- `BracketCarrierCorrectVPriorFaithful` is a strictly *stronger* conclusion about a carrier than
  `BracketCarrierCorrectVPrior`.

Neither faithful form can be *derived* from its UZ/SZ original — that is exactly why the spine
needs restating rather than re-deriving. The derivable direction is recorded below, in
`ExistProvidersFaithful.toExistProviders` and
`BracketCarrierCorrectVPriorFaithful.toBracketCarrierCorrectVPrior`, so the re-base is
machine-checked to be a weakening of hypotheses and not a sideways move — the same discipline
`kampArm_zeta_faithful_covers_attained` (`Kamp/ZetaUniformExtractFaithful.lean:576`) applies at the
ζ wire.

## Nothing is removed and nothing is renamed

Every declaration of `PriorInterface.lean` stands byte-identical; this module only adds faithful
siblings. The two `k ≤ 1` lifts below are, like their UZ/SZ originals, weakenings of the
*unconditional* landed carrier-correctness lemmas `bracketEndChar_kv_correct_zero` and
`bracketEndChar_kv_correct_one` — they drop the hypotheses rather than using them, so the faithful
lifts are as cheap as the UZ/SZ ones and re-prove nothing.

## Source status of this module

**The re-basing itself has no source.** Rabinovich draws no distinction between the attained
first-occurrence property and the eq (5.2) dichotomy — eq (5.2) (PDF p.8) is simply his stated
property, and the attained strengthening is this tree's own artifact. Reynolds likewise states no
such separation. So the *statements* below ride their originals' citations (Lemma 3.2(2), PDF p.4,
plus the §5 bracket notation `[α_0, …, α_n](z_0, z_1)`, PDF p.7, for the two-fixed-endpoint
framing; Prop 3.5, PDF p.5, for the ∃-witness → Until/Since folding mechanism; Cor 5.4, PDF
p.7/p.9, for per-round provider threading), while the *choice of carrier* is original work
answering `KampFaithfulExpressiveCompleteness`
(`WeakCanonical/PriorExpressivenessDense.lean:169`), which is stated at the faithful carrier.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation
  (nfDepth0CharFormula nf_depth0_char_formula_correct
   formulaConjList formula_conjList_iff)

/-! ## 1. The provider bundle at the faithful carrier -/

/-- **Provider bundle at the faithful eq (5.2) carrier** — the faithful sibling of
`ExistProviders` (`PriorInterface.lean:46`).

Same `existF` field, same per-round provider threading per **Cor 5.4** (the `F_i` are TL formulas,
PDF p.7/p.9); the only change is in `correct`, whose two relativizing hypotheses are
`HasFaithfulDedekindINF` / `HasFaithfulDedekindSUP` in place of `SemanticPriorUZ` /
`SemanticPriorSZ`. Because the faithful carrier is the weaker hypothesis, this is a **stronger**
bundle than `ExistProviders`: `toExistProviders` below converts one of these into one of those,
and there is no converse. -/
structure ExistProvidersFaithful (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (k : Nat) where
  /-- The single-anchor existential converter: at each arity `n + 1` it turns a depth-`k`
  normal form into a temporal formula. Correctness at the faithful carrier is the `correct`
  field. -/
  existF : (n : Nat) → NormalForm sig k (n + 1) → Formula
  correct : ∀ (n : Nat) (sub : NormalForm sig k (n + 1)) (M : OrderedMonadicStructure sig)
      (_h_INF : HasFaithfulDedekindINF M atomMap) (_h_SUP : HasFaithfulDedekindSUP M atomMap)
      (t : M.carrier),
      TemporalTruth M atomMap t (existF n sub) ↔
        ∃ env : Fin n → M.carrier, NfEvalNf M k (n + 1) (insertEnv env t) sub

/-- **A faithful provider bundle re-supplies the UZ/SZ one.** Every consumer that arrives holding
`SemanticPriorUZ` / `SemanticPriorSZ` is served by an `ExistProvidersFaithful`, through
`prior_hasAttainedINF` / `prior_hasAttainedSUP` (`Kamp/PriorINF.lean:230`, `:275`) composed with
`HasAttainedINF.toHasFaithfulDedekindINF` / `HasAttainedSUP.toHasFaithfulDedekindSUP`
(`KPlusFaithful.lean:382`, `:389`). The `existF` field is carried across unchanged, so the
converter formula produced is literally the same one.

This is the D11 coverage record: it machine-checks that the re-base weakens hypotheses rather than
moving sideways. `ExistProviders` itself is left untouched. There is no converse — the faithful
carrier does not yield `SemanticPriorUZ`. -/
def ExistProvidersFaithful.toExistProviders {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProvidersFaithful sig atomMap k) : ExistProviders sig atomMap k where
  existF := P.existF
  correct n sub M h_UZ h_SZ t :=
    P.correct n sub M (prior_hasAttainedINF M atomMap h_UZ).toHasFaithfulDedekindINF
      (prior_hasAttainedSUP M atomMap h_SZ).toHasFaithfulDedekindSUP t

/-! ## 2. Relativized carrier correctness at the faithful carrier -/

/-- **Carrier correctness relativized to the faithful eq (5.2) carrier** — the faithful sibling of
`BracketCarrierCorrectVPrior` (`PriorInterface.lean:70`).

Character-for-character that predicate, with `(h_UZ : SemanticPriorUZ M atomMap)
(h_SZ : SemanticPriorSZ M atomMap)` replaced by `(h_INF : HasFaithfulDedekindINF M atomMap)
(h_SUP : HasFaithfulDedekindSUP M atomMap)`. The six atom-layer order hypotheses, the fixed
endpoint pair `(x, t)` and the bracket-witness conclusion are all unchanged, so the framing
citations ride the original: Lemma 3.2(2) (PDF p.4) plus the §5 bracket notation
`[α_0, …, α_n](z_0, z_1)` (PDF p.7); Prop 3.5 (PDF p.5) is cited only for the ∃-witness →
Until/Since folding mechanism.

Being the *stronger* predicate, this is the form the faithful spine needs and the form that
cannot be obtained from the landed one. -/
def BracketCarrierCorrectVPriorFaithful {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (atomMap : Formula → sig.preds)
    {k : Nat} (carrier : BracketEndCharCarrierV sig k) : Prop :=
  ∀ (qnf : NormalForm sig k 3)
    (h_xy : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_INF : HasFaithfulDedekindINF M atomMap) (h_SUP : HasFaithfulDedekindSUP M atomMap)
    (x t : M.carrier),
    (carrier qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf

/-- **Faithful carrier correctness re-supplies the UZ/SZ form.** The D11 coverage record for §2,
matching `ExistProvidersFaithful.toExistProviders`: any carrier correct at the faithful eq (5.2)
hypotheses is correct at the UZ/SZ ones, via `prior_hasAttainedINF` / `prior_hasAttainedSUP` and
the `toHasFaithfulDedekind*` shims. `BracketCarrierCorrectVPrior` is left untouched, and there is
no converse. -/
theorem BracketCarrierCorrectVPriorFaithful.toBracketCarrierCorrectVPrior
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat} {carrier : BracketEndCharCarrierV sig k}
    (h : BracketCarrierCorrectVPriorFaithful atomMap carrier) :
    BracketCarrierCorrectVPrior atomMap carrier :=
  fun qnf h_xy h_yt h_xt h_yx h_ty h_tx M h_UZ h_SZ x t =>
    h qnf h_xy h_yt h_xt h_yx h_ty h_tx M
      (prior_hasAttainedINF M atomMap h_UZ).toHasFaithfulDedekindINF
      (prior_hasAttainedSUP M atomMap h_SZ).toHasFaithfulDedekindSUP x t

/-! ## 3. The `k ≤ 1` lifts

Exactly as at the UZ/SZ carrier, these are weakenings of the *unconditional* landed lemmas
`bracketEndChar_kv_correct_zero` and `bracketEndChar_kv_correct_one`, not re-proofs: an
unconditional `↔` implies every relativized one, so the proof drops the hypotheses. That the
faithful lifts are as cheap as the UZ/SZ lifts is not luck — it is the reason the k ≤ 1 rungs were
stated unconditionally in the first place. -/

/-- **`k = 0` faithful lift.** The faithful sibling of `bracketEndChar_kv_correct_zero_prior`
(`PriorInterface.lean:89`), and like it a weakening of the unconditional
`bracketEndChar_kv_correct_zero` — the proof drops `h_INF` / `h_SUP`. At `k = 0` the
`NormalForm.atomAssgn` order hypotheses are definitionally the landed `qnf (.order …)` ones.
Citations ride the consumed lemma; no chain step is shortcut. -/
theorem bracketEndChar_kv_correct_zero_prior_faithful {sig : MonadicSignature}
    [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula) :
    BracketCarrierCorrectVPriorFaithful atomMap (bracketEndCharKv atomMap h_surj charF 0) :=
  fun qnf h_xy h_yt h_xt h_yx h_ty h_tx M _h_INF _h_SUP x t =>
    bracketEndChar_kv_correct_zero atomMap h_surj charF qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t

/-- **`k = 1` faithful lift.** The faithful sibling of `bracketEndChar_kv_correct_one_prior`
(`PriorInterface.lean:104`), and like it a weakening of the unconditional
`bracketEndChar_kv_correct_one`, dropping `h_INF` / `h_SUP`; the depth-0 provider agreement `h0` is
retained. At `k = 1` the `NormalForm.atomAssgn` order hypotheses are definitionally the landed
`qnf.1 (.order …)` ones. Citations ride the consumed lemma; no chain step is shortcut. -/
theorem bracketEndChar_kv_correct_one_prior_faithful {sig : MonadicSignature}
    [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (h0 : charF 0 = nfDepth0CharFormula atomMap h_surj) :
    BracketCarrierCorrectVPriorFaithful atomMap (bracketEndCharKv atomMap h_surj charF 1) :=
  fun qnf h_xy h_yt h_xt h_yx h_ty h_tx M _h_INF _h_SUP x t =>
    bracketEndChar_kv_correct_one atomMap h_surj charF h0 qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t

end FormalSystem.Metalogic.WeakCanonical.Kamp
