# Phase 2 handoff — BLOCKED (encoding-level obstruction in the RECONCILE construction)

**Status: Phase 2 BLOCKED. Phase 1 remains COMPLETE and green.** No sorry / vacuous placeholder /
Prop43Structural.lean hole introduced. Spine green: full `lake build` EXIT 0 at 1769 jobs;
`completeness_discrete` axiom trace unchanged
`[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`
(the `sorryAx` is the pre-existing `KampPrior.lean:562` sorry, not from this task). The new file
`Prop42NegationGeneral.lean` is off the live import path.

## The obstruction (machine-confirmed, scratch probe EXIT 0)

The plan/verdict specify the split as **standalone `efSat` objects** with a "cap-free" middle
discharged through `EndpointPinnedCapTrivial`. That cannot close in this repo's encoding:

1. `efSat` (`ExistsForallFormula.lean:100-111`) **mandatorily** carries two *universal*
   exterior-cap clauses (5th: `∀ y < x 0, unaryHolds (intervalType 0) y`; 6th:
   `∀ y > x_last, unaryHolds (intervalType last) y`). There is no cap-free `efSat`.
2. `unaryHolds N τ p ↔ ∀ a : AtomKind (sigE sig F) 1, atom_eval N (fun _=>p) a ↔ (τ a = true)` —
   **exact** agreement on every atom (`unaryHolds_iff`; `nf_eval_nf` depth-0, `NormalForm.lean:198`).
3. `(sigE sig F).preds = sig.preds ⊕ {A // A ∈ F}` (`ESigmaExpansion.lean:63`) is non-empty on the
   completeness spine → `AtomKind (sigE sig F) 1` has genuine predicate atoms.

⇒ **No fixed `UnaryType` is realized at every point of a general `N`.** So there is no "`UnaryType`
top"; `EndpointPinnedCapTrivial.capTrivialLeft/Right (∀ y, unaryHolds N cap y)` is undischargeable
from any construction; and `efSat_split`'s **forward** direction is already false (from `efSat ψ`,
the below piece's mandatory after-cap `∀ y > z0, unaryHolds (splitBelow.afterCap) y` is unprovable —
the region above `z0 = x_m` carries the middle/above content, not a single universal type).

The plan cited `VVecEA2.trivialTrue` for "the vacuous caps", but that is a `VVecEA2` at the
cap-free `VecEA2` level; it does not supply a universally-realized `UnaryType`. The two levels were
conflated in the verdict.

## Repair path (requires a plan revision — raised as a blocker per plan-compliance for .lean files)

Rabinovich's cap-free / one-sided pieces ARE expressible, but at the **TL-formula + bounded-`VecEA2`
level**, not as standalone `efSat` objects:

- Below `ψ0(z0)` → `α_m ∧ buildLeft(x_{m-1}..x0, β0)` (`ExistsForallNF.lean:310`; Since/past, only ≤ z0).
- Above `ψ1(z1)` → `α_k ∧ buildRight(x_{k+1}..x_n, β_{n+1})` (`ExistsForallNF.lean:297`; Until/future, only ≥ z1).
- Middle `φ(z0,z1)` → bounded `BracketFormula`/`VecEA2` on (z0,z1) (cap-free by construction),
  negated directly by `VVecEA2.negFix_iff` (NOT via `efSat`/`EndpointPinnedCapTrivial`).
- `¬ψ0`, `¬ψ1` realize as endpoint `TemporalPred`s — exactly Phase 1's `negLeftClause`/`negRightClause`
  (already landed sorry-free) — combined with `¬φ` by `VVecEA2.disj`.
- Correctness bridges: `buildLeft_spec_iff_chain` / `buildRight_spec_iff_chain` (`Prop35Chain.lean:56,146`).
- New piece needed: decomposition lemma `efSat ψ ↔ (α_m ∧ leftPart)(z0) ∧ bracket(z0,z1) ∧ (α_k ∧ rightPart)(z1)`
  (~200-400 lines; a Prop 4.2 re-derivation at the TL level).

**Recommended next action**: `/revise 383` to re-plan Phases 2-6 onto the TL/bounded-VecEA2 level,
then re-dispatch. Phase 1's `negLeftClause`/`negRightClause` are reusable verbatim.

## Reusable green asset from this dispatch
`Prop42NegationGeneral.lean`: `negLeftClause`/`negLeftClause_holds`, `negRightClause`/`negRightClause_holds`
— VVecEA2 endpoint clauses whose `holds(z0,z1)` iff a one-free-variable `∃∀` end piece fails at the
pinned endpoint. Built directly from `TemporalPred = ⟨Formula⟩` + `temporal_truth_neg` +
`translateProp35_correct`; no signature-atom/surjectivity routing needed (the verdict's flagged
residual risk was overstated).
