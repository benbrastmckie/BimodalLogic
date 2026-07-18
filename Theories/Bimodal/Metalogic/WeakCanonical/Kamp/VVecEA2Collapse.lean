import Bimodal.Metalogic.WeakCanonical.Kamp.VeeExistsForall
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAFormula
import Bimodal.Metalogic.WeakCanonical.Kamp.IntervalType

/-!
# E[Σ] collapse bridge `VVecEA2 → VeeExistsForall` (Rabinovich Def 4.1, PDF p.5-6) — assembly half

This module supplies the **disjunctive-assembly half** of the E[Σ] atom-collapse bridge that lifts a
`VVecEA2` witness (the object the arbitrary-pin negation engine `prop42_efSat_negation_general`
produces) back into a `VeeExistsForall` object. The bridge is Rabinovich Def 4.1 (PDF p.5-6) — the
`VVecEA2 → VeeExistsForall` re-expression is the E[Σ] atom-collapse, the genuine reverse of the
landed forward bridge `translateVeeProp42` (`Prop42ExistsForall.lean`, which runs
`VeeExistsForall → VVecEA2`).

## What is here (green): the per-clause → disjunction assembly

`vvecea2_collapse_of_perClause` reduces the full bridge to a **per-clause reverse translation**: given
a map `trans` sending each `VVecEA2` disjunct `⟨n, vea⟩` to an `ExistsForallFormula sig F 2` whose
`efSat` matches `vea.holds` on strictly-ordered pairs, the disjunction `v'.disjuncts.map trans` is a
`VeeExistsForall` object satisfied exactly when `v'` holds. This is the `foldr`/`map`-over-disjuncts
step (Def 3.3 disjunction distributivity), proved directly by disjunct matching — the same shape as
`translateVeeProp42_correct` in reverse. It is sorry-free and axiom-clean.

## What is NOT here (the crux, escalated): the per-clause collapse `trans`/`htrans`

The remaining obligation — constructing `trans` and proving `htrans` — is the genuine Def 4.1
content (report 07 R4 "true crux", HIGH-risk). It is a **verified blocker** under the hypotheses the
revised Phase-10a signature carries (`N`, `atomMap`, `h_surj`, `HasAttainedINF`, `HasAttainedSUP`):

* The `VVecEA2` disjuncts the engine emits carry **arbitrary `TL(Until,Since)` `Formula`s** at their
  endpoints — `negLeftClauseTL`'s `⟨Formula.neg (belowFormula …)⟩`, `negRightClauseTL`'s
  `⟨Formula.neg (aboveFormula …)⟩`, and the `(middleBracket …).negFix` INF/`K⁺` machinery. None is a
  `unaryToFormula`-image of a `UnaryType`.
* A `VeeExistsForall`'s atomic content is `UnaryType`/`IntervalType` — a truth assignment to the
  **unary E[Σ] predicates at a single point** (`unaryHolds`). Capturing an arbitrary `TL` formula as
  a `UnaryType` is only possible via the E[Σ] atom-collapse of a **processed** formula in the
  canonical expansion (`ESigmaExpansion.atom_eval_new`, which holds on `canonExpand …`), i.e. it
  needs the *definability/capture* property that a `TL` formula over the processed alphabet is
  realized by a fresh unary atom of `N`.
* The bridge's hypotheses do not supply that property: `HasAttainedINF`/`HasAttainedSUP` are
  first-occurrence *attainment* facts (`PriorINF.lean`), not definability; `h_surj` says every `pred`
  has a naming `Atom`, not that an arbitrary `TL` formula is captured by a `pred`. No reverse
  translation (`TL → ∃∀`, `Formula → UnaryType`) exists in the tree.

Hence `trans`/`htrans` cannot be discharged as written; Phase 10a is `[BLOCKED]` on this missing
E[Σ]-capture hypothesis (the same class as the original Phase-10 Axis-2 gap). See the task plan's
Phase 10a escalation. No `sorry` or placeholder is introduced.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Definition 4.1 (p.5-6). Cited by PDF page; the
  companion markdown transcription is corrupt.
- `Prop42ExistsForall.lean`: `translateVeeProp42` / `translateVeeProp42_correct` (the forward bridge).
- `Prop42NegationGeneral.lean`: `prop42_efSat_negation_general` (produces the `VVecEA2` this lifts).
- `VeeExistsForall.lean`: `veeSat`, `veeSat_append`.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula)
open Bimodal.Metalogic.WeakCanonical

/-- **E[Σ] collapse bridge, disjunctive-assembly half (Def 4.1, p.5-6).** Given a per-clause reverse
translation `trans` that sends every `VVecEA2` disjunct to an `ExistsForallFormula sig F 2` matching
it on strictly-ordered pairs (`htrans`), the mapped disjunction is a `VeeExistsForall` object
satisfied exactly when the whole `VVecEA2` holds. This is the reverse of `translateVeeProp42_correct`:
the `map`-over-disjuncts step, proved by disjunct matching (Def 3.3 disjunction distributivity).

The per-clause hypothesis `trans`/`htrans` is the genuine Def 4.1 atom-collapse content and is the
`[BLOCKED]` crux under the current hypotheses (see the module docstring). -/
theorem vvecea2_collapse_of_perClause {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (v' : VVecEA2)
    (trans : (Σ n, VecEA2 n) → ExistsForallFormula sig F 2)
    (htrans : ∀ vea ∈ v'.disjuncts, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
        (efSat N env (trans vea) ↔ vea.2.holds N atomMap (env 0) (env 1))) :
    ∃ Φ : VeeExistsForall sig F 2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (veeSat N env Φ ↔ v'.holds N atomMap (env 0) (env 1)) := by
  refine ⟨v'.disjuncts.map trans, fun env henv => ?_⟩
  simp only [veeSat, VVecEA2.holds, List.mem_map]
  constructor
  · rintro ⟨ψ, ⟨vea, hvea, rfl⟩, hsat⟩
    exact ⟨vea, hvea, (htrans vea hvea env henv).mp hsat⟩
  · rintro ⟨vea, hvea, hholds⟩
    exact ⟨trans vea, ⟨vea, hvea, rfl⟩, (htrans vea hvea env henv).mpr hholds⟩

/-! ## Conditional reverse bridge threading `hCapture` (Def 4.1 E[Σ] collapse, p.5-6)

The per-clause reverse translation `trans`/`htrans` demanded by `vvecea2_collapse_of_perClause`
is the genuine Def 4.1 atom-collapse. It is discharged here as a **conditional** result taking the
capture/definability hypothesis `hCapture` (a `TL` formula over the processed E[Σ] alphabet is
realized by an admissible-completion set at every point — the literal reverse of
`unaryToFormula_correct`, lifted to `IntervalType`). With `hCapture` in hand every arbitrary
`TL(Until,Since)` endpoint/segment `Formula` the negation engine emits
(`Prop42NegationGeneral.lean`) is captured as an `IntervalType`. Because an `ExistsForallFormula`
point type is a *single* complete `UnaryType` while a captured truth set is a *union* of complete
types, each `VecEA2` clause expands into a disjunction over the admissible completions at its
point positions — the E[Σ] collapse of Def 4.1. The result is a proved CONDITIONAL biconditional,
an orphan gated on `hCapture` (discharged only at ζ / Phase 10P), off the live import path.
-/

/-- **Capture at the `TemporalPred` level.** `hCapture` supplies, for every `Formula`, an
admissible-completion set (`IntervalType`) whose partial satisfaction matches temporal truth. Since
`TemporalPred.eval_at` is `temporal_truth` on the wrapped formula, every `TemporalPred` is captured
by an `IntervalType`. This is the reusable wrapper the reverse bridge routes all endpoint and
segment predicates through. -/
theorem intervalType_captures_temporalPred {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
        ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
    (tp : TemporalPred) :
    ∃ S : IntervalType sig F, ∀ y : N.carrier,
      intervalHolds N S y ↔ tp.eval_at N atomMap y := by
  obtain ⟨S, hS⟩ := hCapture tp.formula
  exact ⟨S, fun y => hS y⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
