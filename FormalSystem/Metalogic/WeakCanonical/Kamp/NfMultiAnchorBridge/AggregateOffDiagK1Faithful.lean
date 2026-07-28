/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.AggregateOffDiagK1
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFixFaithful.VecEANegFixFaithful

/-!
# The k = 1 aggregate population fold at the faithful eq (5.2) carrier

This module discharges the **one genuine proof obligation** the spine re-base has above the ζ
wire, as opposed to the mechanical restatement that makes up the rest of it.

## The gate question, and its answer

The re-base's inventory found that of the `SemanticPriorUZ` / `SemanticPriorSZ` hypothesis-binder
sites across the live spine, only two *consume* the carrier rather than thread it:
`AggregateOffDiagK1.lean:1288` (`aggPop1_correct`) and `:1381` (`aggPop1F_correct`). Both consume
it the same way — `prior_hasAttainedINF` / `prior_hasAttainedSUP` feeding `aggOdPopFold_iff`
(`AggregateOffDiagK1.lean:1226`). So the whole question of whether the spine is re-basable at all
reduces to: *what does `aggOdPopFold_iff` bottom out on?*

**Answer, by inspection of its proof rather than by assumption**: `aggOdPopFold_iff` uses
`h_INF` / `h_SUP` at exactly one step, the bit-false branch of its cons case
(`AggregateOffDiagK1.lean:1253`), and that step is `VVecEA2.negFix_iff`. Its nil case, its
`VVecEA2.conjFull_iff` cons rewrite, and its bit-true branch are all carrier-free.

`VVecEA2.negFix_iff` is precisely what `VVecEA2.negFixFaithful_iff`
(`EANegationFixFaithful/VecEANegFixFaithful.lean:244`) already supplies at the faithful carrier.
So the obligation is discharged, and the remainder of the spine re-base is mechanical restatement
with no further proof content — which is the outcome the gate was set to distinguish from the
alternative, that it bottomed out on genuine attainment and the re-base was blocked.

**The `SUP` half is not consumed at all**, exactly as at the ζ wire: `VVecEA2.negFix_iff` needs
`HasAttainedINF` **and** `HasAttainedSUP`, whereas `VVecEA2.negFixFaithful_iff` needs
`HasFaithfulDedekindINF` **alone**. `HasFaithfulDedekindSUP` is bound below as `_h_SUP` and never
used, kept only so the statement stays shape-parallel with the attained original and with the
consuming obligation `KampFaithfulExpressiveCompleteness`
(`WeakCanonical/PriorExpressivenessDense.lean:169`). Deleting it would strengthen the result;
that decision is deliberately not taken here, matching `ZetaUniformExtractFaithful.lean`.

## The fold is over `negFixFaithful`, not over `negFix`

The faithful fold below negates its bit-false clauses with `VVecEA2.negFixFaithful`
(`EANegationFixFaithful/VecEANegFixFaithful.lean:208`) rather than `VVecEA2.negFix`. This is
forced, not a preference: `negFix`'s correctness biconditional is available only at the attained
carrier, so a fold built from `negFix` cannot be read off at the faithful one. The two folds are
therefore different `VVecEA2` terms with the same Rabinovich content — Proposition 4.2, closure
under negation, printed verbatim at PDF p.6 as *"The negation of ∃⃗∀-formulas with at most two free
variables is equivalent over Dedekind complete chains to a disjunction of ∃⃗∀-formulas."*

## Nothing is removed and nothing is renamed

`aggOdPopFold_iff` and both its consumers stand byte-identical; this module only adds siblings.

## Source status

The Lemma 3.4 closure under ∧ that the fold implements, and Proposition 4.2 that its bit-false
clauses implement, are Rabinovich's (PDF p.5 and p.6 respectively). **The choice of carrier has no
source**: Rabinovich draws no distinction between the attained first-occurrence property and his
own eq (5.2) dichotomy (PDF p.8), so the re-basing is this tree's own work.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
  {atomMap : Formula → sig.preds}

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **The biconditional population fold at the faithful carrier** — the faithful sibling of
`aggOdPopFold_iff` (`AggregateOffDiagK1.lean:1226`), and the single genuine proof obligation of the
spine re-base.

Folding `if bit qnf then D qnf else (D qnf).negFixFaithful` over a list with `conjFull` holds iff
every listed `qnf`'s carrier matches its bit — the biconditional per-clause reading (`⟺`, not `→`)
that the k = 1 population match requires.

The original's proof structure verbatim: induction over the list, nil closed by
`VVecEA2.trivialTrue_holds`, cons opened by `VVecEA2.conjFull_iff`. The one carrier-consuming step,
the bit-false branch, is redirected from `VVecEA2.negFix_iff` to `VVecEA2.negFixFaithful_iff`
(`EANegationFixFaithful/VecEANegFixFaithful.lean:244`), which needs `HasFaithfulDedekindINF` alone.
Rabinovich Lemma 3.4 (PDF p.5) for the ∧-closure; Proposition 4.2 (PDF p.6) for the negated
clauses. -/
theorem aggOdPopFold_iff_faithful (M : OrderedMonadicStructure sig)
    (h_INF : HasFaithfulDedekindINF M atomMap) (_h_SUP : HasFaithfulDedekindSUP M atomMap)
    (D : NormalForm sig 1 3 → VVecEA2) (bit : NormalForm sig 1 3 → Bool)
    (z0 z1 : M.carrier) (h_lt : z0 < z1) (l : List (NormalForm sig 1 3)) :
    ((l.map fun qnf => if bit qnf then D qnf else (D qnf).negFixFaithful).foldr
        VVecEA2.conjFull VVecEA2.trivialTrue).holds M atomMap z0 z1 ↔
      ∀ qnf ∈ l, ((D qnf).holds M atomMap z0 z1 ↔ bit qnf = true) := by
  induction l with
  | nil =>
    simp only [List.map_nil, List.foldr_nil]
    constructor
    · intro _ qnf hq
      exact absurd hq (List.not_mem_nil)
    · intro _
      exact VVecEA2.trivialTrue_holds M atomMap z0 z1
  | cons q qs ih =>
    rw [List.map_cons, List.foldr_cons, VVecEA2.conjFull_iff, ih,
        List.forall_mem_cons]
    refine and_congr ?_ Iff.rfl
    by_cases hb : bit q = true
    · rw [if_pos hb, hb]
      constructor
      · intro hp
        exact ⟨fun _ => rfl, fun _ => hp⟩
      · intro hiff
        exact hiff.mpr rfl
    · rw [if_neg hb,
          VVecEA2.negFixFaithful_iff M atomMap h_INF (D q) z0 z1 h_lt]
      constructor
      · intro hneg
        exact ⟨fun hh => absurd hh hneg, fun hbit => absurd hbit hb⟩
      · intro hiff hh
        exact hb (hiff.mp hh)

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **The faithful population fold re-supplies the attained one's hypotheses.** The D11 coverage
record: a consumer arriving with `HasAttainedINF` / `HasAttainedSUP` — as both
`aggPop1_correct` and `aggPop1F_correct` do, via `prior_hasAttainedINF` / `prior_hasAttainedSUP` —
can read off the faithful fold, through `HasAttainedINF.toHasFaithfulDedekindINF` /
`HasAttainedSUP.toHasFaithfulDedekindSUP` (`KPlusFaithful.lean:382`, `:389`).

This machine-checks that the re-base is a weakening of hypotheses and not a sideways move.
`aggOdPopFold_iff` itself is left untouched, and there is no converse: the faithful carrier does
not yield `HasAttainedINF` (`hasFaithfulDedekindINF_not_implies_hasDedekindINF`,
`KPlusFaithful.lean:693`).

Note that the two folds are *different carrier terms* — this one negates with `negFixFaithful`,
the original with `negFix` — so this is coverage of the attained hypothesis set, not an identity
of the folded formulas. -/
theorem aggOdPopFold_iff_faithful_covers_attained (M : OrderedMonadicStructure sig)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    (D : NormalForm sig 1 3 → VVecEA2) (bit : NormalForm sig 1 3 → Bool)
    (z0 z1 : M.carrier) (h_lt : z0 < z1) (l : List (NormalForm sig 1 3)) :
    ((l.map fun qnf => if bit qnf then D qnf else (D qnf).negFixFaithful).foldr
        VVecEA2.conjFull VVecEA2.trivialTrue).holds M atomMap z0 z1 ↔
      ∀ qnf ∈ l, ((D qnf).holds M atomMap z0 z1 ↔ bit qnf = true) :=
  aggOdPopFold_iff_faithful M h_INF.toHasFaithfulDedekindINF h_SUP.toHasFaithfulDedekindSUP
    D bit z0 z1 h_lt l

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **The faithful fold is readable on any Prior structure.** The end-to-end record that the
gate's answer reaches the two consuming sites: `SemanticPriorUZ` / `SemanticPriorSZ` route to the
faithful carrier through `prior_hasAttainedINF` / `prior_hasAttainedSUP`
(`Kamp/PriorINF.lean:230`, `:275`) composed with the `toHasFaithfulDedekind*` shims, so
`aggPop1_correct` and `aggPop1F_correct` have a faithful-carrier route available to them and are
not the obstruction the gate was checking for. -/
theorem aggOdPopFold_iff_faithful_on_prior (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (D : NormalForm sig 1 3 → VVecEA2) (bit : NormalForm sig 1 3 → Bool)
    (z0 z1 : M.carrier) (h_lt : z0 < z1) (l : List (NormalForm sig 1 3)) :
    ((l.map fun qnf => if bit qnf then D qnf else (D qnf).negFixFaithful).foldr
        VVecEA2.conjFull VVecEA2.trivialTrue).holds M atomMap z0 z1 ↔
      ∀ qnf ∈ l, ((D qnf).holds M atomMap z0 z1 ↔ bit qnf = true) :=
  aggOdPopFold_iff_faithful_covers_attained M (prior_hasAttainedINF M atomMap h_UZ)
    (prior_hasAttainedSUP M atomMap h_SZ) D bit z0 z1 h_lt l

end FormalSystem.Metalogic.WeakCanonical.Kamp
