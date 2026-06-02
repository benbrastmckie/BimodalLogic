# Research Report: Task #164 — Tableau Correctness (Team Research)

**Task**: Prove tableau correctness theorem for decision procedure
**Date**: 2026-06-01
**Mode**: Team Research (4 teammates)
**Focus**: Literature-informed approach for 3 remaining sorry sites

## Summary

Four research teammates investigated the 3 remaining sorry sites (truthLemma_neg untl/snce, blocking_terminates) from complementary angles: standard literature approaches, alternative strategies, critical audit, and strategic direction. All four converge on a propagation-based proof strategy for the Until/Since cases, with the Critic identifying two important issues that must be addressed first.

## Key Findings

### 1. The Until/Since Truth Lemma Gap — Root Cause and Solution

**Consensus across all teammates**: The `sat_untl_neg` invariant proves that `F(U(event, guard))` cannot exist in a saturated branch because the `untlNeg` rule would apply. But `truthLemma_neg` needs the stronger claim that Until is false *semantically* in the branch model — which requires reasoning about ALL transitively reachable future times, not just immediate successors.

**The key insight** (A + B + C agree): The `untlNeg` rule's Branch 2 re-propagates `F(U(event, guard))` to the successor time `t'`. This means:
- If `F(U(e,g))` holds at time `t` in a saturated branch, applying `sat_untl_neg` gives us `F(event)` or `F(guard)` at each `t' ∈ futureOf(t)`
- In the Branch 2 case (where `F(guard)` holds), `F(U(e,g))` is ALSO placed at `t'` (persistent re-propagation)
- Therefore `sat_untl_neg` can be applied again at `t'`, covering `t''`, and so on by induction

**Critical strengthening needed** (from Critic): The current `sat_untl_neg` only proves `F(event) OR F(guard)`. It needs strengthening to `F(event) OR (F(guard) AND F(U(event,guard)))` — the second disjunct must include the persistence of `F(U)`. This is directly extractable from `applyRule .untlNeg` Branch 2 output.

### 2. `isTimeOrderedBefore` Fuel Bug (from Critic)

**Latent semantic bug**: `isTimeOrderedBefore` in CountermodelExtraction.lean uses fuel-bounded DFS with default `fuel := 50`. For tableau branches with chains longer than 50 hops, it returns `false` for genuinely ordered pairs. This makes `branchTruth` evaluate Until/Since incorrectly for deep chains. No existing proof bounds chain depth to < 50.

**Fix**: Either increase fuel to a provably sufficient bound (tied to subformula count), or refactor to use Mathlib's `Relation.TransGen` which has no fuel limitation.

### 3. `blocking_terminates` — Approach

**Consensus**: Decompose into sub-lemmas:
1. Generalized subformula property: all formulas in expanded branches are subformulas of the original formula
2. Bound on distinct time types: bounded by `2^(2 * |subformulas φ|)` (A) or `4^n` (B)
3. Pigeonhole: once time points exceed the bound, branch sets must repeat → blocking detects this

**Critical fix** (from Critic): The theorem currently quantifies over ALL branches, but the subformula property only holds for branches derived from expanding the initial formula. Restrict the quantifier.

**Mathlib tool** (from Horizons): `Fintype.exists_ne_map_eq_of_card_lt` provides the pigeonhole lemma. Already used in `Claim1.lean:815`.

### 4. Vacuous Proofs Audit (from Critic)

Three resolved sorry sites (`sat_box_neg`, `sat_untl_pos`, `sat_snce_pos`) are proved via `exfalso` — they derive `False` from the hypothesis that the formula exists in a saturated branch, then use `False.elim`. This is **technically correct** (the formula genuinely cannot appear) but the theorem names suggest constructive witnesses. Low severity — correct but worth documenting.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| A/B: prove propagation lemma on existing code vs D: change rule definition | **Use propagation lemma** — changing rule definitions risks breaking 10 already-proved sorry sites and requires re-proving soundness. The propagation approach works with the existing rule semantics. |
| A: introduce `TimeReachable` inductive relation vs B: use existing `isTimeOrderedBefore` | **Fix `isTimeOrderedBefore` fuel bug first** (Critic's finding), then use it. Introducing a new relation adds unnecessary complexity when the existing one just needs its fuel bound fixed. |
| Resolution order: D says blocking_terminates first vs A/B say Until first | **Until first** — it's the higher-value result (proves semantic completeness), and the strengthened `sat_untl_neg` is a prerequisite for clean Until reasoning. blocking_terminates is independent and can follow. |

### Recommended Implementation Order

**Phase 1: Fix infrastructure bugs**
- [ ] Fix `isTimeOrderedBefore` fuel bound (tie to subformula count or use unbounded recursion on finite graph)
- [ ] Restrict `blocking_terminates` quantifier to expanded branches only
- [ ] Add comment documenting De Morgan refactor dependency in Tableau.lean

**Phase 2: Strengthen sat_untl_neg / sat_snce_neg**
- [ ] Prove `sat_untl_neg_strong`: `F(U(e,g)) @ (w,t)` in saturated branch implies `F(event) @ (w,t') OR (F(guard) @ (w,t') AND F(U(e,g)) @ (w,t'))` for all `t' ∈ futureOf(t)`
- [ ] Prove mirror `sat_snce_neg_strong` for Since

**Phase 3: Prove propagation + truth lemma**
- [ ] Prove `untl_neg_propagates`: `F(U(e,g))` at `t` implies `F(U(e,g))` at all transitively reachable `t'` (path induction using Phase 2)
- [ ] Prove `truthLemma_neg` untl case: use `untl_neg_propagates` + `sat_untl_neg_strong` to show Until is false at every reachable time
- [ ] Prove mirror for Since

**Phase 4: blocking_terminates**
- [ ] Prove generalized subformula property for expanded branches
- [ ] Prove time type bound (use `Finset.card_powerset` or direct counting)
- [ ] Apply pigeonhole (`Fintype.exists_ne_map_eq_of_card_lt`) to show blocking fires
- [ ] Assemble `blocking_terminates` from sub-lemmas

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary | completed | high | Path induction via untlNeg Branch 2 re-propagation; literature confirmation |
| B | Alternatives | completed | high | Propagation lemma approach; blocking decomposition into 5 sub-lemmas |
| C | Critic | completed | high | sat_untl_neg strengthening needed; isTimeOrderedBefore fuel bug; quantifier fix |
| D | Horizons | completed | medium | Strategic prioritization; Mathlib pigeonhole lemma; Obendrauf patterns |

## References

- Gabbay, Hodkinson, Reynolds (1994) *Temporal Logic: Foundations* Vol 1, Ch 10 — Reynolds co-decomposition for Until
- Venema (1993) *Derivation Rules as Anti-Axioms* — Since and Until treatment
- Hodkinson & Reynolds (2006) *Temporal Logic* (Handbook Ch 11) — tableau completeness
- Obendrauf (2024) *Lean Formalization of Coalition Logic* — closure definition subtleties in Lean 4
- Libkin (2004) *Elements of Finite Model Theory* Ch 3 — rank-k type finiteness for blocking argument
