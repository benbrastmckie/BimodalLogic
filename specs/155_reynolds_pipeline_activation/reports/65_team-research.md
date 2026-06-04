# Research Report: Task #155 — Post-281 Blocker Resolution

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-06-04
**Mode**: Team Research (4 teammates)

## Summary

After task 281 bypassed the old sorry chain, ONE sorry root remains: `nf_2var_existential_transfer` (StaviCompleteness.lean, lines 2353/2435/2805). Two implementation attempts failed — one on sub-interval splitting, one on formula_agreement circularity. The team identified THREE viable resolution paths, with a critical depth arithmetic question determining which is optimal. All four teammates converge on the same diagnosis: the game composition argument is mathematically necessary; the question is how to access it without circularity.

## Key Findings

### Unanimous Agreements (HIGH confidence)

1. **ONE root sorry**: `nf_2var_existential_transfer`. All three sorry sites (lines 2353, 2435, 2805) trace to this single theorem. Line 2805 resolves automatically when 2353/2435 are proved.

2. **Sub-interval splitting is a real mathematical problem**: Zone matching gives u' with correct 1-var NF and orderings relative to (x',t'), but NOT sub-interval type data for (x,u)/(x',u'). This is a genuine gap in the direct induction, confirmed across 5+ sessions with concrete counterexamples.

3. **The formula_agreement circularity is structural**: `formula_agreement` quantifies over ALL StaviFormulas of bounded depth. Converting NF agreement to formula_agreement IS `stavi_expressive_completeness` — the theorem being proved. No engineering fix can break this within the current architecture.

4. **All literature converges on game composition**: GHR93, Libkin, Thomas, Reynolds all require the Duplicator to use a FULL interval strategy (not zone matching) to find responses preserving all decomposition formulas simultaneously.

5. **The stale axiom audit** in Completeness.lean (lines 380-401) references `chronicle_gap_contradiction` as the sorry source. The actual path goes through `stavi_expressive_completeness`. Documentation debt, not structural.

### Three Viable Resolution Paths

#### Path 1: Mutual Induction at Rank k-1 (Teammate C) — ~380 lines

**Core insight**: The outer induction's IH at depth k gives `nf_characterizable_by_stavi` at depth k-1, which yields `stavi_expressive_completeness` at depth k-1. With depth-(k-1) expressive completeness, formula_agreement CAN be built from NF hypotheses — breaking the circularity. Uses EXISTING game infrastructure.

**Chain**: IH → depth-(k-1) expressiveness → formula_agreement at rank r → existing game at rank r → existential transfer at j < k.

**Critical question**: What is r? Teammate A flags a 2x depth gap: `stavi_fo_depth_le_twice_depth` means depth-k NFs only give formula_agreement at rank floor(k/2), not rank k. This may mean the game at rank floor(k/2) only proves transfer at j ≤ floor(k/2), not j < k.

**Teammate C's counter-argument**: The game at rank k-1 gives formula_agreement at depth k-1, which by monotonicity gives NF agreement at ALL depths j ≤ k-1. But this requires BUILDING the game at rank k-1, which needs formula_agreement at rank k-1 as input — and that's the question.

**Verdict**: Viable IF the depth arithmetic resolves favorably (r = k-1 or close enough). Needs one focused session to verify the exact depth relationships. Smallest code change, uses existing infrastructure.

#### Path 2: Discrete Specialization (Teammate A) — ~600 lines

**Core insight**: For discrete orders (`IsSuccArchimedean`), `discrete_no_gaps` eliminates ALL gaps from `ExtendedCarrier`. This means depth-k NF agreement on the plain structure implies depth-k NF agreement on the extended structure (since mu is trivially true everywhere). Via Doets' lemma, this gives formula_agreement at rank floor(k/2) without needing expressive completeness at all.

**Why it avoids circularity**: Formula_agreement comes from depth-k NF agreement via Doets' lemma (a general model theory result), NOT from `stavi_expressive_completeness`.

**Caveat**: Only works for discrete models. General `nf_characterizable_by_stavi` retains sorry for non-discrete. Acceptable since the goal is `completeness_discrete`.

**Same depth question**: If the game is at rank floor(k/2) and we need transfer at j < k, the depth arithmetic must be verified. Teammate A argues 2*floor(k/2) ≥ k-1 for k ≥ 1.

**Verdict**: Mathematically sound, well-scoped to the actual goal. More code than Path 1, but avoids the mutual induction complexity.

#### Path 3: Strengthened NF Induction (Teammate B) — ~250-400 lines

**Core insight**: Prove a generalized theorem parametric in number of points n with ALL adjacent-pair interval data. Zone matching + depth decrease gives sub-interval types at depth k-1 (one less than k), sufficient for recursive step.

**Reduces to game argument**: The "refined zone matching preserving sub-interval types" IS the game composition expressed in NF language. The proof would be a game argument in disguise, but without the ExtendedCarrier bridge.

**Risk**: The refined zone matching may be as hard as the game composition itself (~400 lines).

**Verdict**: Viable, stays in NF world. But may not be simpler than using existing game infrastructure.

### Conflict Resolution

| Issue | Teammate A | Teammate C | Resolution |
|-------|-----------|-----------|------------|
| Depth gap (floor(k/2) vs k) | Fatal for Path 1 | Solvable (rank k-1 suffices) | UNRESOLVED — needs verification |
| Best path | Path 2 (discrete) | Path 1 (mutual induction) | Both viable; depth arithmetic decides |
| NF Type Game viability | Not viable (still hits splitting) | N/A (doesn't propose it) | Agree: NF Type Game is dead |
| Axiomatization | Not considered | Not considered | D recommends as fallback; mathematically honest option |

### Strategic Assessment (Teammate D)

- 35 sorry sites project-wide, only 3 on critical path — task is correctly scoped
- Project already successful without this sorry (soundness, decidability, FMP, completeness_dense all sorry-free)
- Task 155 has consumed 66 plans, 120+ research reports — diminishing returns
- Recommends: investigate whether `gap_prior_UZ_contradiction` needs FULL expressiveness (if only a fragment is needed, the circularity may dissolve). If that fails, axiomatize with GHR93 reference.

## Synthesis: Recommended Attack Order

1. **Verify depth arithmetic** (1 focused session): Check the exact relationship between game rank r, NF depth k, and the depths j < k needed by nf_fraisse_compression. If floor(k/2) ≥ k-1 for relevant k values, or if the game rank can be set to k-1 using depth-(k-1) expressiveness, then Path 1 (mutual induction) is optimal.

2. **If depth arithmetic works → Path 1** (~380 lines, uses existing game infrastructure, smallest change)

3. **If depth arithmetic fails → Path 2** (discrete specialization, ~600 lines, avoids the depth question entirely by eliminating gaps)

4. **If both fail → Axiomatize** with full GHR93 citation. The project's main results are not affected.

5. **Side investigation** (Teammate D's suggestion): Check whether `gap_prior_UZ_contradiction` actually needs FULL `stavi_expressive_completeness` or only a fragment. If a fragment suffices, the problem scope may shrink dramatically.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary/Paths | completed | Medium-High | Discrete specialization path; depth gap analysis |
| B | Alternatives/Literature | completed | High | Literature convergence on game composition; strengthened induction |
| C | Critic | completed | High | Mutual induction at rank k-1; circularity validation |
| D | Horizons | completed | Medium | Strategic assessment; fragment sufficiency question |

## References

- GHR93 Proposition 7 (pp.114-115): Full game-theoretic proof of composition
- Libkin 2004, Lemma 3.7: Composition Lemma for Linear Orders
- Thomas 1997: General composition framework for temporal structures
- Reynolds 1994, Theorems 4-5: Completeness via gap elimination
