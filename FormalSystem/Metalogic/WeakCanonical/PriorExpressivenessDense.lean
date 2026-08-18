/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.PriorExpressiveness
import FormalSystem.Metalogic.WeakCanonical.PriorDefsDense
import FormalSystem.Metalogic.WeakCanonical.Kamp.KPlusFaithful
import FormalSystem.Metalogic.WeakCanonical.Kamp.KampPriorFaithful

/-!
# `{U,S}` Expressive Completeness over *Dense* Prior Structures

Reynolds 1992, §5 Theorem 3 (printed p.176), at the carrier the Dedekind route actually needs:
expressive completeness of `{U,S}` over structures satisfying the **dense** Prior axioms
`SemanticPriorU` / `SemanticPriorS` (`PriorDefsDense.lean:119`, `:138`), rather than the
*integer* axioms `SemanticPriorUZ` / `SemanticPriorSZ` (`PriorDefs.lean:28`, `:39`) at which
`uSExpressivelyCompleteOverPrior` (`PriorExpressiveness.lean:357`) is pinned.

**Theorem 3, verbatim** (printed p.176, read from the source PDF): *"The language with U and S
is expressively complete for the class of Prior structures."* Its "Prior structure" is defined on
the same page: *"Call a linear temporal structure a Prior structure if it satisfies all
substitution instances of Prior-U and Prior-S"*, and Prior-U / Prior-S are, verbatim from printed
p.168, `U(⊤,p) ∧ F¬p → U(¬p ∨ K⁺(¬p),p)` and `S(⊤,p) ∧ P¬p → S(¬p ∨ K⁻(¬p),p)` — which are
exactly `SemanticPriorU` and `SemanticPriorS`.

**Consequence, and the reason this module exists**: Reynolds' Theorem 3 is a statement about
`SemanticPriorU` / `SemanticPriorS`. The landed `uSExpressivelyCompleteOverPrior` is pinned at
`SemanticPriorUZ` / `SemanticPriorSZ`, which are *not* Reynolds' Prior axioms and are strictly
stronger (`semanticPriorU_not_implies_semanticPriorUZ`, `PriorDefsDense.lean:372`). So
`uSExpressivelyCompleteOverPrior` **is not Reynolds' Theorem 3**, and
`uSExpressivelyCompleteOverDensePrior` below is. This is a fidelity gap in the tree's existing
naming, established by reading the source rather than inferred from the plan.

## The carrier measurement, and what it found

This module opens with a measurement of the existing chain rather than an assumption about it,
and the measurement **refuted the premise this module was chartered on**. Recorded here because
the refutation, not the composition, is this module's principal content.

**Measured**: `Kamp.kampPriorExpressiveCompleteness` (`Kamp/KampPrior.lean:672`) and
`Kamp.nfCharacterizableTemporalPrior` (`:589`) consume `SemanticPriorUZ` / `SemanticPriorSZ`
and **no completeness carrier at all**. `KampPrior.lean` contains zero occurrences of
`HasDedekindINF`, `HasDedekindSUP`, `HasFaithfulDedekindINF`, `HasFaithfulDedekindSUP`,
`HasAttainedINF`, `HasAttainedSUP`, `kplus`, `negFix*`, `prop42*` or `VVecEA2`. Its single
edge into the Rabinovich machinery is `Kamp.kampArm_zeta`.

**One level down**, at `kampArm_zeta` in `Kamp/ZetaUniformExtract.lean`, the carrier does appear
— and it is the **attained originals**: `HasAttainedINF` and `HasAttainedSUP` (seven occurrences
each), together with `VVecEA2` and `negFix` from `Kamp/EANegationFix/`. `ZetaUniformExtract.lean`
contains **zero** occurrences of `HasFaithfulDedekindINF` or `HasFaithfulDedekindSUP`.

**Verdict**: the chain routes through the attained originals, *not* through the re-based faithful
chain. The faithful chain is present in the aggregator `Kamp/NfMultiAnchorBridge.lean` (fifteen
occurrences of `HasFaithfulDedekindINF`) but the zeta wire that `kampPriorExpressiveCompleteness`
actually consumes does not reach it. So the plan's "compose the re-based faithful chain with
`prior_hasFaithfulDedekindINF_dense`" has nothing to compose *with* on the `KampPrior` side, and
a faithful sibling of `kampPriorExpressiveCompleteness` is this module's real remaining content.

**Update — the zeta wire now reaches the faithful chain.** The two paragraphs above record the
measurement as it stood when this module was written, and are kept as the record of the
refutation. They are superseded on one point: `Kamp/ZetaUniformExtractFaithful.lean` now carries
`Kamp.kampArm_zeta_faithful`, the ζ wire at `HasFaithfulDedekindINF` / `HasFaithfulDedekindSUP`,
sorry-free. What remains open is the spine *above* the wire; see
`kampFaithfulExpressiveCompleteness_open`'s docstring for the measured remaining inventory.

**And the obstruction is strictly worse than a missing composition.** The tree already
machine-checks that the dense hypotheses do not supply the integer ones:
`semanticPriorU_not_implies_semanticPriorUZ` (`PriorDefsDense.lean:372`) exhibits `denseRayFlow`
satisfying `SemanticPriorU ∧ SemanticPriorS` and refuting `SemanticPriorUZ`. Its own docstring
draws the consequence for exactly this module: *"every declaration pinned at `SemanticPriorUZ` /
`SemanticPriorSZ` — `uSExpressivelyCompleteOverPrior` (`PriorExpressiveness.lean:357`) ... and
their consumers — has no dense instance obtained by reuse."* Re-exporting
`uSExpressivelyCompleteOverPrior` at the dense hypotheses is therefore not merely unproved but
**unavailable**, and `uSExpressivelyCompleteOverDensePrior_not_by_reuse` below restates that
unavailability as a claim about this module's own target.

## What this module lands

* `KampFaithfulExpressiveCompleteness` — the open obligation, named and stated: expressive
  completeness at `HasFaithfulDedekindINF` / `HasFaithfulDedekindSUP`. This is the plan's
  `kampDedekindExpressiveCompleteness`, stated as a type rather than proved, because the
  measurement above shows it is a re-base of the whole zeta wire and not a composition.
* `uSExpressivelyCompleteOverDensePrior_of_faithful` — **sorry-free**. The composition the plan
  chartered, discharged in full: the obligation plus `prior_hasFaithfulDedekindINF_dense` /
  `prior_hasFaithfulDedekindSUP_dense` (Phase 10.1, `Kamp/KPlusFaithful.lean:474`, `:524`) gives
  the dense target. Every step of the intended composition that *can* be taken is taken here.
* `uSExpressivelyCompleteOverDensePrior` — the plan-shaped target, obtained from the conditional
  by the single open obligation. It carries this module's **only** `sorry`, isolated in
  `kampFaithfulExpressiveCompleteness_open`.
* Anti-vacuity, sorry-free, at Phase 9's positive dense witness `denseWindowFlow`.

## Domain restriction, inherited and stated

`Kamp.nf_nvar_exist_all_depths` (`Kamp/KampPrior.lean:363`) carries `hn : n ≤ 1`, excluding the
arity-`n ≥ 2` arm, and `nfCharacterizableTemporalPrior` consumes it at `n = 1` only. The
restriction is invisible in `kampPriorExpressiveCompleteness`' statement because arity-1 is all
that statement ever needs. **It is inherited by everything here** and is not widened: the
obligation `KampFaithfulExpressiveCompleteness` is stated at `MonadicFormula sig 1`, exactly the
arity at which the existing chain closes, so any discharge of it inherits `hn : n ≤ 1` verbatim.
Nothing in this module reaches arity `≥ 2`.

## Honesty charter

`uSExpressivelyCompleteOverDensePrior_of_faithful`, the anti-vacuity block and the measurement
corollary are **original glue**: no source states them, because no source works with this tree's
separation of `SemanticPriorU` from `SemanticPriorUZ`. The *statement* being aimed at is
Reynolds'; the route to it is this tree's.

**The route departs from Reynolds' own proof, deliberately.** His printed proof (p.176) begins
*"By the expressive completeness of {U, S, U′, S′} over all linear structures, it suffices to
prove that for any {U, S, U′, S′}-formula B′, there is a {U, S}-formula B such that B′ ↔ B is
valid in all Prior structures"* — that is, a reduction through the Stavi connectives (his
Theorem 2, p.176). This tree cannot take that route: its `stavi_expressive_completeness` is
Boneyard'd and sorry-tainted. It substitutes Rabinovich's method relativized to the faithful
eq (5.2) carrier. **The substituted route has no source**; only the target statement does.

Reynolds also attributes the theorem onward — *"It is now not hard to prove the following (see
[8], proposition 4.2)"* — so p.176 is a statement-plus-sketch site, not a self-contained proof
this tree could have transcribed even had the Stavi route been available.

## References

- Reynolds 1992, "Continuous Temporal Models", §5 Theorem 3, printed p.176
- Rabinovich 2014, "A Proof of Kamp's Theorem", §5, eq (5.2), PDF p.8
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Syntax

/-! ## The measurement, as a claim about this module's target

The gate's verdict, restated where it bites: the dense hypotheses of
`uSExpressivelyCompleteOverDensePrior` do not supply the integer hypotheses of
`uSExpressivelyCompleteOverPrior`, so the latter cannot be re-exported at the former. -/

/-- **The target is not obtainable by reuse.** There is a structure satisfying both hypotheses of
`uSExpressivelyCompleteOverDensePrior` at which `uSExpressivelyCompleteOverPrior`'s first
hypothesis fails, so no instantiation of the landed integer theorem proves the dense one.

This is `semanticPriorU_not_implies_semanticPriorUZ` (`PriorDefsDense.lean:372`) read as a
statement about this module's charter: the witness is `denseRayFlow`. It is the reason
`KampFaithfulExpressiveCompleteness` below is an obligation rather than a corollary. -/
theorem uSExpressivelyCompleteOverDensePrior_not_by_reuse :
    ∃ (M : OrderedMonadicStructure densePriorSig) (atomMap : Formula → densePriorSig.preds),
      SemanticPriorU M atomMap ∧ SemanticPriorS M atomMap ∧ ¬ SemanticPriorUZ M atomMap :=
  semanticPriorU_not_implies_semanticPriorUZ

/-! ## The open obligation

The plan's `kampDedekindExpressiveCompleteness`, stated. The measurement above shows it is a
re-base of `Kamp/ZetaUniformExtract.lean`'s zeta wire from `HasAttainedINF` / `HasAttainedSUP`
onto `HasFaithfulDedekindINF` / `HasFaithfulDedekindSUP`, together with everything the wire
consumes below it — not a composition of already-landed parts. -/

/-- **Expressive completeness at the faithful eq (5.2) carrier** — the obligation this module's
target rests on, and the faithful sibling of `Kamp.kampPriorExpressiveCompleteness`
(`Kamp/KampPrior.lean:672`).

Same shape as `kampPriorExpressiveCompleteness`, with `SemanticPriorUZ` / `SemanticPriorSZ`
replaced by `Kamp.HasFaithfulDedekindINF` / `Kamp.HasFaithfulDedekindSUP`
(`Kamp/KPlusFaithful.lean:320` and its `Since`-dual) — Rabinovich 2014's eq (5.2), PDF p.8, at
the source's own `K⁺` rather than at this tree's `kplus`.

Stated at `MonadicFormula sig 1`: the arity at which the existing chain closes, inheriting
`Kamp.nf_nvar_exist_all_depths`' `hn : n ≤ 1` (`Kamp/KampPrior.lean:363`) rather than widening
it. -/
def KampFaithfulExpressiveCompleteness {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (_h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) : Type :=
  ∀ (psi : MonadicFormula sig 1),
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (_h_INF : Kamp.HasFaithfulDedekindINF M atomMap)
        (_h_SUP : Kamp.HasFaithfulDedekindSUP M atomMap)
        (t : M.carrier),
        eval M (fun _ => t) psi ↔
        TemporalTruth M atomMap t A }

/-! ## The composition — sorry-free

This is the chartered composition piece — the `uSExpressivelyCompleteOverDensePrior_of_faithful`
bullet of "What this module lands" above — discharged in full. Every step of the chartered
composition that the tree supports is taken here; the only thing standing between this and an
unconditional `uSExpressivelyCompleteOverDensePrior` is the obligation above. -/

/-- **`{U,S}` expressive completeness over dense Prior structures, from the faithful obligation**
— Reynolds 1992, §5 Theorem 3 (printed p.176), conditional on
`KampFaithfulExpressiveCompleteness`.

The composition: `SemanticPriorU` yields `Kamp.HasFaithfulDedekindINF` with no completeness or
discreteness hypothesis on the flow (`Kamp.prior_hasFaithfulDedekindINF_dense`,
`Kamp/KPlusFaithful.lean:474`), and `SemanticPriorS` yields the `Since`-dual
(`Kamp.prior_hasFaithfulDedekindSUP_dense`, `:524`); feeding both to the obligation gives the
dense target, with the *same* witness formula `A`.

Mirrors `uSExpressivelyCompleteOverPrior`'s shape exactly, `h_surj` binder included. Original
glue on a sourced statement: Reynolds states the theorem, but not at this tree's separation of
`SemanticPriorU` from `SemanticPriorUZ`, so the composition itself has no source. -/
noncomputable def uSExpressivelyCompleteOverDensePrior_of_faithful
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (H : KampFaithfulExpressiveCompleteness atomMap h_surj)
    (psi : MonadicFormula sig 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (_h_prior_U : SemanticPriorU M atomMap)
        (_h_prior_S : SemanticPriorS M atomMap)
        (t : M.carrier),
        eval M (fun _ => t) psi ↔
        TemporalTruth M atomMap t A } :=
  ⟨(H psi).val, fun M h_U h_S t =>
    (H psi).property M
      (Kamp.prior_hasFaithfulDedekindINF_dense M atomMap h_U)
      (Kamp.prior_hasFaithfulDedekindSUP_dense M atomMap h_S) t⟩

/-! ## The plan-shaped target — DISCHARGED

This module is now sorry-free, and with it the whole route: the obligation below was the only
gap. -/

/-- **The obligation, discharged** — expressive completeness of `{U,S}` at the faithful eq (5.2)
carrier, supplied by `Kamp.kampPriorExpressiveCompletenessFaithful`
(`Kamp/KampPriorFaithful.lean`).

**What closed it.** The obligation was a re-base of the whole `kampPriorExpressiveCompleteness`
spine (`Kamp/KampPrior.lean:672`) from `SemanticPriorUZ` / `SemanticPriorSZ` onto
`Kamp.HasFaithfulDedekindINF` / `Kamp.HasFaithfulDedekindSUP`. The re-base landed in four rungs,
each sorry-free:

1. **The ζ wire** — `Kamp.kampArm_zeta_faithful` (`Kamp/ZetaUniformExtractFaithful.lean:522`),
   with the canonical-expansion transfers `Kamp.canonExpand_hasFaithfulDedekindINF` / `SUP` and
   the faithful uniform translate `Kamp.translate_uniformFin_faithful`. This serves the `k ≥ 2`
   arms of `nf_nvar_exist_all_depths`.
2. **The one substantive obligation above the wire** — `Kamp.aggOdPopFold_iff_faithful`
   (`Kamp/NfMultiAnchorBridge/AggregateOffDiagK1Faithful.lean:89`). `aggOdPopFold_iff`
   (`AggregateOffDiagK1.lean:1226`) touches its carrier hypotheses at exactly one step, the
   bit-false branch of its cons case (`:1253`), and that step is `VVecEA2.negFix_iff` — for which
   `VVecEA2.negFixFaithful_iff` is the faithful counterpart, needing `HasFaithfulDedekindINF`
   alone. Everything else in the spine turned out to be restatement.
3. **The bridge interface and the six trichotomy arms** —
   `Kamp/NfMultiAnchorBridge/PriorInterfaceFaithful.lean`,
   `Kamp/NfMultiAnchorBridge/OuterGateFaithful.lean`, and
   `Kamp/NfMultiAnchorBridge/ArmLemmasFaithful.lean`, the last carrying the `k = 0` and `k = 1`
   arm closures plus the `negFixFaithful` population folds they ride.
4. **The spine itself** — `Kamp/KampPriorFaithful.lean`, restating
   `nf_succ_char_formula_correct`, both per-depth arm closures, `nf_nvar_exist_all_depths`, its
   convenience wrapper, `nfCharacterizableTemporalPrior`, and the main theorem.

Every attained original is untouched: the re-base added declarations and removed and renamed
nothing.

**What it does not assume**: nothing about arity `≥ 2`. The statement is at
`MonadicFormula sig 1`, inheriting `Kamp.nf_nvar_exist_all_depths_faithful`'s `hn : n ≤ 1`
domain restriction rather than widening it.

**Source status**: the construction is Rabinovich, *A Proof of Kamp's Theorem* (2014) — Def 3.1
p.4 for the normal-form stratification, Lemmas 3.2(2) and 3.4 pp.4-5 for the characteristic
assembly, Def 4.1 / Prop 4.3 / Thm 4.4 pp.5-6 for the ζ wire, Prop 4.2 p.6 for the negated
population clauses. The *choice of carrier* has no source: Rabinovich draws no distinction
between the attained first-occurrence property and his own eq (5.2) dichotomy (PDF p.8), so the
re-basing is this tree's own work. -/
noncomputable def kampFaithfulExpressiveCompleteness
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    KampFaithfulExpressiveCompleteness atomMap h_surj :=
  fun psi => Kamp.kampPriorExpressiveCompletenessFaithful atomMap h_surj psi

/-- **Retained name.** This was the module's strategic sorry; it is now
`kampFaithfulExpressiveCompleteness` under its former name, at the same type and with no
weakening. It is kept so that every consumer written against the open obligation continues to
typecheck unchanged, and it no longer contributes `sorryAx` to anything downstream. -/
noncomputable def kampFaithfulExpressiveCompleteness_open
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    KampFaithfulExpressiveCompleteness atomMap h_surj :=
  kampFaithfulExpressiveCompleteness atomMap h_surj

/-- **`{U,S}` expressive completeness over dense Prior structures** — Reynolds 1992, §5 Theorem 3,
printed p.176: *"The language with U and S is expressively complete for the class of Prior
structures."*

Reynolds' "Prior structure" is defined on that page as a linear temporal structure satisfying all
substitution instances of Prior-U and Prior-S, which are `SemanticPriorU` / `SemanticPriorS`
(printed p.168). So **this declaration is Reynolds' Theorem 3**, whereas
`uSExpressivelyCompleteOverPrior` (`PriorExpressiveness.lean:357`), pinned at the strictly
stronger `SemanticPriorUZ` / `SemanticPriorSZ`, is not — see this module's header.
`uSExpressivelyCompleteOverDensePrior_not_by_reuse` shows the gap between the two hypothesis sets
is real, so this is not a restatement of the landed theorem.

**Rests on one open obligation**, `kampFaithfulExpressiveCompleteness_open`; see its docstring.
The composition itself, `uSExpressivelyCompleteOverDensePrior_of_faithful`, is sorry-free.

Obtained by Rabinovich's method relativized to the faithful eq (5.2) carrier, **not** by
Reynolds' own reduction to `{U,S,U',S'}`, which would run through the Boneyard'd, sorry-tainted
`stavi_expressive_completeness`. Domain restriction `hn : n ≤ 1` inherited, not widened. -/
noncomputable def uSExpressivelyCompleteOverDensePrior
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (psi : MonadicFormula sig 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (_h_prior_U : SemanticPriorU M atomMap)
        (_h_prior_S : SemanticPriorS M atomMap)
        (t : M.carrier),
        eval M (fun _ => t) psi ↔
        TemporalTruth M atomMap t A } :=
  uSExpressivelyCompleteOverDensePrior_of_faithful atomMap h_surj
    (kampFaithfulExpressiveCompleteness_open atomMap h_surj) psi

/-! ## Anti-vacuity

**The phase's most important task**, and entirely sorry-free: everything below is independent of
the open obligation. A sorry-free `uSExpressivelyCompleteOverDensePrior` whose hypothesis no
dense structure satisfies would reproduce the exact defect this whole block exists to repair, so
the hypothesis pair is exhibited as inhabited at Phase 9's positive dense witness
`denseWindowFlow` (`PriorDefsDense.lean:336`), and the conditional theorem is instantiated there
at a non-trivial `psi`. -/

/-- `densePriorSig.preds` is `Unit` (`PriorDefsDense.lean:294`), hence finite.

`MonadicSignature` deliberately carries no `Fintype` field (`MonadicFO.lean:61-63`) under the
infinite-alphabet discipline, so the instance is supplied per-signature, as here. -/
instance : Fintype densePriorSig.preds := inferInstanceAs (Fintype Unit)

/-- `densePriorSig.preds` is `Unit`, hence decidable; supplied per-signature for the same reason
as the `Fintype` instance above. -/
instance : DecidableEq densePriorSig.preds := inferInstanceAs (DecidableEq Unit)

/-- The only atom map into `densePriorSig` is surjective, since `densePriorSig.preds = Unit`. -/
theorem densePriorAtomMap_surj :
    ∀ p : densePriorSig.preds, ∃ a : Atom, densePriorAtomMap (.atom a) = p :=
  fun _ => ⟨Atom.mkBase "p", rfl⟩

/-- **Anti-vacuity, hypotheses.** Both hypotheses of `uSExpressivelyCompleteOverDensePrior` hold
at the dense window flow, and so does the faithful carrier the composition routes through — so
neither the target's hypothesis pair nor the intermediate carrier is empty.

The carrier facts are Phase 13's `Kamp.hasFaithfulDedekindINF_of_dense_window` and its dual
(`Kamp/KPlusFaithful.lean:672`, `:678`); listing them alongside the Prior hypotheses records that
`uSExpressivelyCompleteOverDensePrior_of_faithful`'s *internal* step is inhabited here too, not
only its premise. -/
theorem densePrior_target_hypotheses_inhabited :
    SemanticPriorU denseWindowFlow densePriorAtomMap ∧
    SemanticPriorS denseWindowFlow densePriorAtomMap ∧
    Kamp.HasFaithfulDedekindINF denseWindowFlow densePriorAtomMap ∧
    Kamp.HasFaithfulDedekindSUP denseWindowFlow densePriorAtomMap :=
  ⟨semanticPriorU_of_dense_window, semanticPriorS_of_dense_window,
    Kamp.hasFaithfulDedekindINF_of_dense_window, Kamp.hasFaithfulDedekindSUP_of_dense_window⟩

/-- A non-trivial test formula: `∃ x, t < x ∧ P(x)` — the monadic first-order rendering of `F P`.

Quantifier depth 1, and it uses both the order and the predicate, so it is not equivalent to any
quantifier-free formula and the expressive-completeness claim at it has content. Index `0` is the
variable bound by `.ex` (by `eval`'s `Fin.cons x env` convention, `MonadicFO.lean:313`) and index
`1` is the free variable. -/
def denseTestPsi : MonadicFormula densePriorSig 1 :=
  .ex (.and (.lt 1 0) (.atom () 0))

/-- `denseTestPsi` says what its docstring says. Checked rather than asserted, since the index
convention is easy to get backwards. -/
theorem denseTestPsi_eval (t : denseWindowFlow.carrier) :
    eval denseWindowFlow (fun _ => t) denseTestPsi ↔
      ∃ x : denseWindowFlow.carrier, t < x ∧ denseWindowFlow.interp () x :=
  Iff.rfl

/-- **Anti-vacuity, the instantiation.** The conditional theorem produces an actual
`{ A : Formula // … }` at the dense window flow for the non-trivial `denseTestPsi`, with the
hypotheses discharged from `densePrior_target_hypotheses_inhabited` rather than assumed.

**Sorry-free**: it consumes `uSExpressivelyCompleteOverDensePrior_of_faithful`, not
`uSExpressivelyCompleteOverDensePrior`, so it does not inherit the open obligation's `sorry` —
it takes the obligation as a hypothesis and is honest about doing so. This is the strongest
anti-vacuity statement available while the obligation is open: it shows the target's conclusion
is *reachable* at a dense structure, and that the route from the hypotheses to the carrier
actually fires there. -/
noncomputable def uSExpressivelyCompleteOverDensePrior_at_denseWindow
    (H : KampFaithfulExpressiveCompleteness densePriorAtomMap densePriorAtomMap_surj) :
    { A : Formula //
      ∀ t : denseWindowFlow.carrier,
        eval denseWindowFlow (fun _ => t) denseTestPsi ↔
        TemporalTruth denseWindowFlow densePriorAtomMap t A } :=
  let R := uSExpressivelyCompleteOverDensePrior_of_faithful densePriorAtomMap
    densePriorAtomMap_surj H denseTestPsi
  ⟨R.val, fun t => R.property denseWindowFlow
    semanticPriorU_of_dense_window semanticPriorS_of_dense_window t⟩

end FormalSystem.Metalogic.WeakCanonical
