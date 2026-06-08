# Research Report: Task #273

**Task**: Bypass GHR93 bridge lemma sorry via GHR94 integer-time separation
**Date**: 2026-06-08
**Mode**: Team Research (4 teammates)
**Focus**: Study how to overcome the last blocker following the Direct Kamp translation given by GHR94 Ch 10.3, considering prior art in the literature

## Summary

Team research reveals that the "Direct Kamp translation via GHR94 Ch 10.3" framing is misleading: Ch 10.3 covers Dedekind-complete (real-line) time, while the integer case is Ch 10.2, which is already fully formalized in `Separation/`. More importantly, Teammate A discovered that `separation_implies_expressiveness` in `ExpressiveCompleteness/Theorem.lean` already implements the full GHR94 Ch 9.3.1 quantifier elimination proof, sorry-free. This changes the problem from "implement a 1000-line Kamp translation" to "write a ~200-350 line semantic transfer lemma."

However, Teammate B raises a valid concern: Prior structures are not necessarily Z-isomorphic, so the transfer from Z-structure correctness to arbitrary Prior structures is not trivial. The resolution depends on whether `GoodStructures.lean` provides the needed Prior-to-Z embedding infrastructure.

The Critic (Teammate C) identifies that no live `#print axioms completeness_discrete` has been run — this is a prerequisite before any further implementation work. Additionally, there are TWO sorry chains reaching `completeness_discrete` (Stavi + Chronicle), not just one.

## Key Findings

### 1. `separation_implies_expressiveness` Already Exists Sorry-Free (Teammate A)

**This is the most significant discovery.** The file `ExpressiveCompleteness/Theorem.lean` contains `separation_implies_expressiveness`, implementing GHR94 Ch 9.3.1 — quantifier elimination by induction on depth using the separation theorem. It produces a temporal formula `A` correct for all Z-carrier (`IntStructureFromSig`) structures.

Combined with `SemanticBridge.lean`'s `int_equiv_implies_temporal_equiv_with_iso`, the only missing piece is a semantic transfer theorem (~200-350 lines) extending correctness from Z-carrier structures to arbitrary `OrderedMonadicStructure sig` satisfying Prior-UZ/SZ.

**Confidence**: High (code verified to exist)

### 2. Prior Structures Are Not Necessarily Z-Isomorphic (Teammate B)

`US_expressively_complete_over_Z` (sorry-free) covers only `IntStructureFromSig` (Z-indexed structures). A Prior structure satisfying Prior-UZ/SZ need NOT have carrier isomorphic to Z (could be uncountable). The `temporal_truth_order_iso` bridge requires an explicit `M.carrier ≃o Z`, which cannot be assumed.

This means Teammate A's approach requires either:
- Proving that Prior-UZ/SZ structures have a Z-embeddable substructure sufficient for the formula evaluation, OR
- A different transfer argument that doesn't require Z-isomorphism

**Confidence**: High (type-level constraint verified)

### 3. Sorry Chain Audit Is Stale (Teammate C)

No live `#print axioms completeness_discrete` call has been run during the 5 implementation cycles. The actual sorry propagation through the import graph is unverified. This MUST be checked before any further Phase 2 work. It's possible that:
- Sorry doesn't actually propagate (Lean's `#print axioms` is proof-term-based, not import-based)
- Chronicle sorry chain (Chain B) is the only remaining blocker after Phase 1 work
- Or both chains remain active

**Confidence**: High (this is a factual gap)

### 4. Two Sorry Chains, Not One (Teammates C, D)

- **Chain A**: StaviCompleteness.lean:2353/2435 → stavi_expressive_completeness → US_expressively_complete_over_prior → ... → completeness_discrete
- **Chain B**: ChronicleToCountermodel.lean:531 → chronicle_gap_contradiction → (transitive import) → completeness_discrete

Even if Chain A is fixed, Chain B must be decoupled (Plan Phase 5). Phase 5 may be a simple import guard or may require splitting `Completeness.lean`.

### 5. Only Sorries #1 and #2 Need Independent Work (Teammate B)

Sorry #3 at StaviCompleteness.lean:2805 is explicitly derivative — the comment says it will be completed once `nf_2var_from_interval_data` is proved. So fixing the 4-variable existential transfer resolves all three sorry sites.

### 6. The Discrete-Only Case May Be Simpler (Teammates C, D)

On discrete (gap-free, Z-like) structures, EF game Cases III/IV never arise (`ghr93_forward_to_backward_discrete` uses only Cases I and II). A discrete-only bridge lemma avoids the general Stavi machinery for the specific use case in `gap_prior_UZ_contradiction`. Estimated ~200-400 lines vs ~600+ for the general case.

## Synthesis

### Conflicts Resolved

**Conflict 1: Approach scope (~200 vs ~600 lines)**

Teammate A says ~200-350 lines (semantic transfer using existing `separation_implies_expressiveness`). Teammate B says ~400-600 lines (prove bridge lemma directly in StaviCompleteness). These are genuinely different approaches:

- **Approach S** (Teammate A): Use `separation_implies_expressiveness` as black box + write transfer lemma. Simpler IF the Prior-to-Z embedding works. Risk: Prior structures may not be Z-embeddable.
- **Approach D** (Teammate B): Fill the sorry directly in StaviCompleteness. More work but avoids the Z-isomorphism question entirely.

**Resolution**: Try Approach S first (cheaper), fall back to Approach D if the transfer lemma hits the Z-isomorphism wall. Check `GoodStructures.lean` for Prior-to-Z embedding infrastructure as a decision point.

**Conflict 2: Whether the separation theorem provides quantifier elimination for MonadicFormula**

Teammate C notes the plan conflates syntactic separation (splitting U/S occurrences) with quantifier elimination (translating FO quantifiers to temporal operators). Teammate A's finding resolves this: `separation_implies_expressiveness` DOES provide quantifier elimination — it uses the separation theorem internally but is a separate theorem.

### Gaps Identified

1. **No live `#print axioms` verification** — must be done immediately
2. **Prior-to-Z embedding feasibility** unknown — check `GoodStructures.lean`
3. **Chain B (Chronicle) sorry propagation** — untested whether `#print axioms` picks it up
4. **Approach S feasibility** depends on whether Prior structures can be embedded into Z-time for formula evaluation purposes

### Recommendations

**Immediate actions (before any implementation):**
1. Run `#print axioms completeness_discrete` to get current sorry state
2. Check `ExpressiveCompleteness/Theorem.lean` for `separation_implies_expressiveness` signature
3. Check `GoodStructures.lean` for Prior-to-Z embedding infrastructure

**Implementation strategy (ordered by effort/risk):**
1. **Approach S** (~200-350 lines): Use `separation_implies_expressiveness` + transfer lemma. Try this first.
2. **Approach D-discrete** (~200-400 lines): Discrete-only bridge lemma exploiting Cases I/II only. Fallback if Approach S fails.
3. **Approach D-general** (~400-600 lines): Fill the sorry directly. Last resort.

**Strategic recommendation (from Teammate D):**
- Split remaining work into focused sub-tasks
- Consider prioritizing dense completeness (task 117, estimated 200-300 lines) as a faster win
- Phase 1 + prereq already delivered durable value (separation theorem sorry-free)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary: GHR94 approach | completed | high |
| B | Alternative approaches | completed | high |
| C | Critic: gaps/assumptions | completed | high |
| D | Horizons: strategy | completed | medium |

## References

- GHR94 Ch 9.3.1: Quantifier elimination via separation (formalized in ExpressiveCompleteness/Theorem.lean)
- GHR94 Ch 10.2: Integer-time separation (formalized in Separation/)
- GHR93 Proposition 7: 4-variable existential transfer (the sorry content)
- Teammate findings: specs/273_chronicle_gap_contradiction_proof/reports/03_teammate-{a,b,c,d}-findings.md
