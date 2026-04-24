# Research Report: Task #107

**Task**: Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-23
**Mode**: Team Research (4 teammates)
**Focus**: Density axioms — are they needed, and what's the long-term architecture for multiple representation theorems?

## Summary

**Density axioms (GGp→Gp, HHp→Hp) should NOT be added to the BX axiom system.** The Phase 3 agent's claim that the PointInsertion sorry sites require density was a misdiagnosis. The 4 sorry sites require constructing future MCS with specific formulas — a syntactic derivability challenge within BX, not a frame property issue. Burgess 1982 does NOT include density in his axiom system and proves completeness for ALL strict linear orders. The chronicle construction's use of Rat provides geometric density at the model level, which is correct and sufficient.

## Key Findings

### 1. Burgess Does NOT Use Density Axioms (Teammate A, HIGH confidence)

Burgess 1982's BX system has 11 axiom schemas (BX1-BX11 in his numbering). None is GGp→Gp or HHp→Hp. His completeness theorem is for ALL strict linear orders, not just dense ones. Density axioms D (FFp→Fp) and D' (PPp→Pp) are mentioned as EXTENSIONS that characterize dense orders. The chronicle construction is designed to work without them.

Verbrugge 2004 similarly works without density, targeting general linear orders.

### 2. The 4 PointInsertion Sorry Sites Do NOT Require Density (Teammate C, HIGH confidence)

Teammate C examined the exact proof states at each sorry location using `lean_goal`:

- **Line 807** (D2 guard): Goal is `∃ D, SetMaximalConsistent D ∧ ξ ∈ D ∧ g_content A ⊆ D`. No density axiom appears. The gap is propagating ξ from A to a future D.
- **Line 814** (D2 witness): Same goal. The gap is about BX5 recursive reasoning, not density.
- **Line 936** (lemma_2_8): Same character.
- **Line 360** (lemma_2_6_strong): Only sorry touching "betweenness", but explicitly documented as NOT on the critical path.

The Phase 3 agent confused two things:
- **Geometric density** of the Rat domain (correct, already present)
- **Syntactic density axioms** in the proof system (NOT needed)

### 3. A BX-Internal Proof Strategy Exists for D2 (Teammate C, MEDIUM-HIGH confidence)

For the D2 guard sub-case (line 807): Apply BX11 (`temp_linearity_mcs`) to `F(η) ∈ A` and `F(¬η) ∈ A`, get three disjuncts. D1 is absurd (contradiction). D2 and D3 lead to `enriched_resolving_seed_consistent`-based constructions yielding a future MCS D with ξ ∈ D. Complex but density-free.

The D2 witness sub-case (line 814) is harder, requiring BX5 recursive arguments. Teammate C rates this MEDIUM confidence.

### 4. PointInsertion Sorry Sites Are NOT on the Critical Path (Teammates A, C confirm)

`lemma_2_7` and `lemma_2_8` are not currently called by Phase 4's counterexample elimination. The blocking sorry sites are in `ChronicleConstruction.lean` (limit C5) and `ChronicleToCountermodel.lean` (integration). The PointInsertion sorries become important only when the C5 insertion strategy is redesigned to use between-point insertion.

### 5. Existing Infrastructure Supports Density as an Extension (Teammate B, HIGH confidence)

If density axioms are desired later for a separate `bx_completeness_dense` theorem:
- `density_valid` soundness proof is already sorry-free in `Soundness.lean`
- Only need a new `Axiom.density` constructor + one case in `axiom_valid_dense`
- Frame class infrastructure (`DenseTemporalFrame`, `valid_dense`) already exists
- `density_derivable` in `TemporalDerived.lean` is sorry'd — would become trivial

### 6. Long-Term Architecture (Teammate D, HIGH confidence)

Three representation theorems, one axiom type:
1. **Base (task 107)**: BX completeness over all strict linear orders via chronicle over Rat. This is the GENERAL result.
2. **Dense (task 68 or extension)**: BX + density axioms, completeness over dense orders. Add after base is done.
3. **Discrete (new task)**: BX + successor axioms, completeness over discrete orders. Separate Z-indexed construction.

The existing parametric infrastructure (`ParametricRepresentation.lean`) already has a domain selection table anticipating all three variants.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Phase 3 agent says density needed; Teammate C says it's not | **Teammate C is correct**: the sorry sites are about syntactic derivability within BX, not about density. The Phase 3 agent confused geometric density (Rat) with axiom density (GGp→Gp). |
| Teammate A says Burgess doesn't use density; BX has `temp_4` (G→GG) but not (GG→G) | **Consistent**: Burgess's BX is complete for ALL linear orders. GG→G is a density-specific extension, not needed for general completeness. |

### Gaps Identified

1. **The D2 witness sub-case (line 814) remains the hardest open problem.** Teammate C provides a strategy direction but rates it MEDIUM confidence. This may require additional research or a reformulation of lemma_2_7 for the witness case.
2. **The interaction between C4 elimination and between-point insertion needs concrete proof.** C4 was added in Phase 1 but the elimination proof has 2 sorry sites.

### Recommendations

**Immediate action**: Do NOT add density axioms. Instead:

1. **Skip Phase 3 entirely for now** — the PointInsertion sorry sites are not on the critical path and don't block Phases 4-7.
2. **Proceed to Phase 4** (C5 redesign) which IS on the critical path. If Phase 4's between-point insertion strategy requires `lemma_2_7`, then return to Phase 3 at that point with the BX11-based strategy Teammate C identified.
3. **Phase 5** (dense domain) addresses the geometric domain question, not the axiom question.
4. **Later**: Once base completeness is sorry-free, add density axioms as a separate task to get `bx_completeness_dense`.

**Revised plan update**: Phase 3's status should change from `[BLOCKED]` to `[DEFERRED]` — it's not blocked by a missing axiom, it's deferred because the sorry sites are not on the critical path.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Literature analysis (Burgess, Verbrugge) | completed | high |
| B | Codebase infrastructure for density axioms | completed | high |
| C | Critic: density is NOT needed | completed | high |
| D | Long-term multi-theorem architecture | completed | high |

## References

- Burgess, J.P. (1982). "Axioms for tense logic. I. 'Since' and 'until'." NDJFL 23(4), 367-374.
- de Jongh, Veltman, Verbrugge (2004). "Completeness by construction for tense logics of linear time."
- Phase 3 results: blocked finding at `plans/08_implementation-plan.md`
