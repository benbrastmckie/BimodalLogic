/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.Prop42Contentful
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFixFaithful.VecEANegFixFaithful
import FormalSystem.Metalogic.WeakCanonical.Kamp.Lemma53FaithfulPast

/-!
# Proposition 4.2 at the faithful Dedekind carrier (Rabinovich, PDF p.6)

This module is the terminus of the faithful re-base. It discharges the contentful Proposition 4.2
target `Prop42Contentful` (`Prop42Contentful.lean:151`) from `HasDedekindINF` **alone**, where the
landed `prop42_contentful_of_attained` (`Section5Correspondence.lean:128`) needs `HasAttainedINF`
**and** `HasAttainedSUP`.

## Source correspondence

PDF **p.6** states the proposition, and the carrier is printed in the statement itself:

> **Proposition 4.2.** *(Closure under negation)* *The negation of `∃⃗∀`-formulas with at most two
> free variables is equivalent* **over Dedekind complete chains** *to a disjunction of
> `∃⃗∀`-formulas.*

"Over Dedekind complete chains" is the whole reason this module exists. The same page derives
Proposition 4.3 from it by structural induction, and Theorem 4.4 (Kamp's theorem) from 4.3 — both
also stated over Dedekind complete chains. Section 5 (pp.7-11) supplies the proof, and is consumed
here opaquely through `VVecEA2.negFixFaithful_iff` (`EANegationFixFaithful/VecEANegFixFaithful.lean`).

## What is new here and what is inherited

Nothing mathematical is new. The theorem below is one line: it pairs the witness
`v.negFixFaithful` with the biconditional `VVecEA2.negFixFaithful_iff`. That is exactly the shape
of `prop42_contentful_of_attained`, which pairs `v.negFix` with `VVecEA2.negFix_iff`. The
difference is entirely in the hypotheses, and that difference is the deliverable.

## Carrier: what `HasDedekindINF` buys, and what it still excludes

The strengthening chain, weakest to strongest, with what is now landed marked:

```
Rabinovich's Dedekind completeness  <  HasDedekindINF  <  HasDefinableINF  <  HasAttainedINF
                                            ^ this module          the previously landed terminus ^
```

Two steps of that chain have been closed by the re-base; **one remains open**. `HasDedekindINF`
(`DedekindINF.lean:136`) is still a hypothesis about the structure, not a derivation from Dedekind
completeness of the order. Closing the last step would mean deriving `HasDedekindINF` from order
completeness alone, which is not attempted anywhere in this tree. So this theorem is **not**
Rabinovich's Proposition 4.2 simpliciter either, and must not be cited as such — it is Proposition
4.2 one strengthening step away from the paper, where the attained version was three.

What the remaining gap costs is recorded concretely rather than as prose:
`hasDefinableINF_excludes_kplus` (`Lemma53.lean:290`) machine-refutes the *weaker*
`HasDefinableINF` as already too strong, so the two steps closed here were not decorative.

## Non-vacuity: the three ways this statement could be hollow, each closed

An over-strong hypothesis, a vacuous conclusion and a `⊤`-collapsed witness all pass sorry-free,
axiom-clean and EXIT 0 exactly as a contentful theorem does. Three machine-checked declarations
below close the three failure modes, rather than asserting their absence:

1. **Wrong quantifier order.** `prop42Faithful_perPoint_is_VACUOUS` proves the per-point ordering
   — `∃ v'` *inside* `∀ z₀ z₁` — from **no carrier hypothesis at all**. That it compiles is what
   makes it worthless, and it is the control showing `Prop42Contentful`'s hoisted `∃ v'` is a
   different statement. Same template as `lemma53Faithful_perPoint_is_VACUOUS`
   (`Lemma53Faithful.lean:354`).
2. **`⊤`-collapsed witness.** Closed upstream by `topVVec_contentful_forces_unsat`
   (`Prop42Contentful.lean:229`): offering the all-`⊤` formula as `v'` does not discharge
   `Prop42Contentful`, it commits the offerer to `v` being unsatisfiable on every ordered pair.
3. **Hollow witness — the `∃ v'` hides which formula was built.** This is the failure mode specific
   to *this* phase: `prop42_contentful_of_dedekind` is silent about the witness, so a construction
   that had silently dropped the paper's limit disjunct would prove it verbatim.
   `prop42_witness_exposes_negFixFaithful` names the witness, and
   `prop42_witness_carries_limit_gate` proves the witness still fires on the `K⁺(¬β₁)(z₀)` gate
   that the faithful recursion adds at Case 1 (PDF p.9) and that the attained development
   structurally cannot carry.

## Cumulative exclusion for the whole re-base: where the difference is OBSERVABLE

`prop42_faithful_unobservable_on_prior` states the honest limit of everything landed. On every
structure that is a Prior structure in both directions, the paper's disjunct (2) `K⁺(P₁)(z₀)` and
its Since dual `K⁻(P)(z₁)` are **both provably dead**. Every live consumer in this tree is such a
structure. Therefore:

* the faithful carrier is strictly weaker, and that is machine-checked;
* no current consumer can observe the difference, and that is also machine-checked;
* observability arrives only with a genuinely non-attained Dedekind-complete frame class, which
  **this development does not build**.

`ℝ` with `P₁` interpreted as `{x | x > 0}` and `z₀ = 0` is such a structure — `inf{z ∈ (0,1) |
P₁(z)} = 0 = z₀`, so no `r₀ > z₀` has `¬P₁` below it, while `ℝ` is Dedekind complete and the paper
covers it via disjunct (2). Constructing it as a frame class is the next fidelity milestone and is
not owned here.

## `HasDedekindSUP` is not consumed

Every faithful `_iff` in the chain feeding this module assumes `HasDedekindINF` and nothing else;
the fold, the recursion, the anchored mirrors and the bounded fixes touch no supremum, no `K⁻` and
no last-occurrence point. `HasDedekindSUP` and the Since mirror (`Lemma53FaithfulPast.lean`) are
therefore **not** hypotheses of this theorem, and adding them for symmetry would be an unused
hypothesis and a strengthening that buys nothing. They are imported here only so that
`prior_makes_kminus_disjunct_unreachable` can be consumed in the cumulative exclusion statement
below — which is a genuine use, not a symmetric one.

`prop42_contentful_of_attained_inf_only` records the practical consequence: the previously landed
`prop42_contentful_of_attained` is now a corollary whose `HasAttainedSUP` argument is unused.

## References

- Rabinovich 2014, *A Proof of Kamp's Theorem*, Proposition 4.2, PDF p.6 (statement and carrier);
  Propositions 4.3 and Theorem 4.4, same page; Section 5, pp.7-11 (proof).
- Cite by **PDF page only**:
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
  The companion `.md` conversion is **corrupt** and is never ground truth.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## The witness, named before it is hidden behind the `∃` -/

/-- **The witness of the faithful Proposition 4.2, exposed.**

    `Prop42Contentful` existentially quantifies the negation formula, so the theorem below is
    silent about *which* `VVecEA2` discharges it. This lemma names it: the witness is
    `v.negFixFaithful`, the Prop 4.3 De Morgan fold over the faithful recursion
    (`EANegationFixFaithful/VecEANegFixFaithful.lean`), and nothing else.

    Stating this separately is not redundancy. A construction that had silently dropped, merged or
    `⊤`-erased the faithful recursion's disjuncts would prove `prop42_contentful_of_dedekind`
    verbatim, because that statement mentions only `¬v.holds`. It could not prove this one together
    with `prop42_witness_carries_limit_gate` below.

    Source correspondence: Rabinovich 2014, Proposition 4.2, PDF p.6. -/
theorem prop42_witness_exposes_negFixFaithful {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasDedekindINF M atomMap) (v : VVecEA2) :
    ∀ z0 z1 : M.carrier, z0 < z1 →
      (v.negFixFaithful.holds M atomMap z0 z1 ↔ ¬ v.holds M atomMap z0 z1) :=
  fun z0 z1 h_lt => VVecEA2.negFixFaithful_iff M atomMap h_INF v z0 z1 h_lt

/-! ## The theorem -/

/-- **Rabinovich's Proposition 4.2 (PDF p.6), at the faithful Dedekind carrier.**

    For every `VVecEA2` formula `v` there is a single `VVecEA2` formula `v'` — depending on `v`
    alone, uniform in the points — equivalent to `¬v` on every ordered pair. The witness is
    `v.negFixFaithful` and the biconditional is `VVecEA2.negFixFaithful_iff`.

    **Carrier, stated because the rule requires it.** This assumes `HasDedekindINF` alone: no
    `HasDedekindSUP`, no `HasAttainedINF`, no `HasAttainedSUP`. That is two strengthening steps
    weaker than `prop42_contentful_of_attained` (`Section5Correspondence.lean:128`), and one step
    stronger than the Dedekind completeness Rabinovich actually assumes. It is therefore **not**
    Proposition 4.2 simpliciter; see this module's docstring for the residual gap and for the
    proof, `prior_makes_disjunct2_unreachable`, that no current consumer can observe the
    difference.

    Source correspondence: Rabinovich 2014, Proposition 4.2, PDF p.6; proved in Section 5,
    pp.7-11. -/
theorem prop42_contentful_of_dedekind {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasDedekindINF M atomMap) (v : VVecEA2) :
    Prop42Contentful M atomMap v :=
  ⟨v.negFixFaithful, prop42_witness_exposes_negFixFaithful M atomMap h_INF v⟩

/-- **The landed attained Proposition 4.2 is now a corollary, and its `HasAttainedSUP` argument is
    unused.**

    `prop42_contentful_of_attained` (`Section5Correspondence.lean:128`) takes `h_INF :
    HasAttainedINF` *and* `h_SUP : HasAttainedSUP`, because `VVecEA2.negFix_iff`
    (`EANegationFix/VecEANegFix.lean:183`) needs both. Routed through the faithful chain, the SUP
    half is not needed at all: `HasAttainedINF.toHasDedekindINF` (`DedekindINF.lean:172`) supplies
    the whole carrier.

    The shim runs attained → faithful only. A faithful → attained use would be a strengthening
    rather than a lift, and appears nowhere in this development. -/
theorem prop42_contentful_of_attained_inf_only {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (v : VVecEA2) :
    Prop42Contentful M atomMap v :=
  prop42_contentful_of_dedekind M atomMap h_INF.toHasDedekindINF v

/-! ## Failed-vacuity control (mandatory)

The **per-point** ordering below quantifies `∃ v'` *inside* `∀ z₀ z₁`. It is provable with **no
carrier hypothesis at all** — one picks the empty disjunction when the right hand side is false and
the all-`⊤` formula when it is true. That it compiles is exactly what makes it worthless, and it is
the control showing the hoisted `Prop42Contentful` discharged above is not the same statement.

Same template as `lemma53Faithful_perPoint_is_VACUOUS` (`Lemma53Faithful.lean:354`), re-run against
the FINAL statement of the re-base rather than against Lemma 5.3. -/

/-- **The per-point ordering of Proposition 4.2 is vacuous.** No `HasDedekindINF`, no
    `HasAttainedINF`, no Dedekind completeness, no hypothesis on `M` at all — and the witness
    depends on the points, which is precisely the content `Prop42Contentful`'s hoisted `∃ v'`
    adds. -/
theorem prop42Faithful_perPoint_is_VACUOUS {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (v : VVecEA2) :
    ∀ z0 z1 : M.carrier, z0 < z1 →
      ∃ v' : VVecEA2, (v'.holds M atomMap z0 z1 ↔ ¬ v.holds M atomMap z0 z1) := by
  intro z0 z1 _
  by_cases h : v.holds M atomMap z0 z1
  · refine ⟨⟨[]⟩, ?_⟩
    simp only [VVecEA2.holds, List.not_mem_nil, false_and, exists_false]
    exact Iff.intro False.elim (fun hn => absurd h hn)
  · exact ⟨topVVec, Iff.intro (fun _ => h) (fun _ => topVVec_holds M atomMap z0 z1)⟩

/-! ## The witness is not hollow: the limit gate survives to the top

`prop42_witness_exposes_negFixFaithful` names the witness; this shows the named witness still
carries what the faithful re-base was built to restore. -/

/-- **The paper's Case 1 limit gate is live in the witness of the final theorem.**

    For a single-disjunct input `v = ⟨[⟨n, vea⟩]⟩`, the witness `v.negFixFaithful` is forced by the
    `K⁺(¬β₁)(z₀)` condition alone — the disjunct the faithful recursion adds at Case 1 (PDF p.9),
    carried by `kplusLeftBlock` (`Lemma53Faithful.lean:189`), and the one the attained development
    structurally cannot have (`negChainOn`, `EANegationFix/OnBuilder.lean:179`, truncates it away
    on the grounds that on Prior structures the INF is always attained).

    Carrier-free: the hypothesis is `kplus` at `z₀` itself, not a carrier assumption that would
    produce it. This is the outer-fold counterpart of `VecEA2.negFixFaithful_carries_limit_gate`
    (`EANegationFixFaithful/VecEANegFixFaithful.lean:281`) — that one shows the gate is not
    discarded by the `VecEA2` lift, this one shows it is not absorbed by the outer De Morgan fold
    on the way to `Prop42Contentful`'s witness. Together they exclude the two ways the restored
    limit disjunct could vanish between the recursion and the headline theorem without any
    statement in either module becoming false. -/
theorem prop42_witness_carries_limit_gate {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {n : Nat} (vea : VecEA2 n) (a b : TemporalPred)
    (qs : List (TemporalPred × TemporalPred))
    (hpairs : vea.bracket.foldPairs = (a, b) :: qs)
    (z0 z1 : M.carrier)
    (hk : kplus M atomMap (vea.bracket.segmentTypes ⟨0, Nat.succ_pos n⟩).neg.formula z0) :
    (VVecEA2.mk [⟨n, vea⟩]).negFixFaithful.holds M atomMap z0 z1 := by
  simp only [VVecEA2.negFixFaithful, List.foldr_cons, List.foldr_nil]
  refine (VVecEA2.conjFull_iff M atomMap _ _ z0 z1).mpr
    ⟨?_, VVecEA2.trivialTrue_holds M atomMap z0 z1⟩
  exact VecEA2.negFixFaithful_carries_limit_gate M atomMap vea a b qs hpairs z0 z1 hk

/-! ## Cumulative exclusion for the whole re-base (final, required)

Everything above is strictly weaker in its hypotheses than what it replaces. This states, as a
theorem rather than as prose, the honest limit of that gain: on the structures every live consumer
in this tree actually inhabits, the gain is **not observable**. -/

/-- **On Prior structures the faithful re-base is unobservable, in both directions.**

    On a structure that is a Prior structure in the future direction (`SemanticPriorUZ`) and in the
    past direction (`SemanticPriorSZ`), the paper's disjunct (2) `K⁺(P)(z₀)` (PDF p.8) and its
    Since dual `K⁻(P)(z₁)` are **both** unreachable whenever `P` occurs strictly inside `(z₀,z₁)`.
    The two halves are `prior_makes_disjunct2_unreachable` (`Lemma53Faithful.lean:382`) and
    `prior_makes_kminus_disjunct_unreachable` (`Lemma53FaithfulPast.lean:355`); this is their
    conjunction, stated once so that the cumulative claim has a single machine-checked home.

    **Consequence, and the honest scope of this task.** Every declaration landed across the
    re-base — the faithful Lemma 5.3 and its Since mirror, the bounded fixes, the anchored mirrors,
    Lemma 5.1 at `n = 1` and its recursion, the Prop 4.2/4.3 lift chain, and
    `prop42_contentful_of_dedekind` above — is strictly weaker in its hypotheses than the attained
    version it mirrors, and that strictness is machine-checked
    (`hasDefinableINF_excludes_kplus`, `Lemma53.lean:290`). But no consumer can *see* the
    difference, because every live consumer is a Prior structure and this theorem shows the
    restored disjuncts are dead there.

    Observability requires a Dedekind-complete frame class on which the infimum is genuinely not
    attained — `ℝ` with `P₁ = {x | x > 0}` and `z₀ = 0` being the paper's own witness. **This
    development does not build such a frame class.** That is the next fidelity milestone, and
    stating it here rather than claiming coverage is the point of this theorem. -/
theorem prop42_faithful_unobservable_on_prior {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (P : Formula) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) :
    ¬kplus M atomMap P z0 ∧ ¬kminus M atomMap P z1 :=
  ⟨prior_makes_disjunct2_unreachable M atomMap h_UZ P z0 z1 h_lt h_occ,
   prior_makes_kminus_disjunct_unreachable M atomMap h_SZ P z0 z1 h_lt h_occ⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp
