# Team Research Report: Task #268 — Reynolds Pipeline Bridge

**Task**: Reynolds pipeline bridge: archive divergent BX code and wire Theorem 14/15
**Date**: 2026-06-03
**Mode**: Team Research (4 teammates, Opus)

## Summary

The team identified the **root cause** of all failed implementation attempts: the formalization demands `IsSuccArchimedean` (Z-isomorphism) for the omega-chain limit domain, but Reynolds 1994 only requires **k-equivalence** to a Z-interval. The sorry chain exists because of this unnecessary architectural requirement. Reynolds' Stages 3-4 (Theorem 14 gap elimination + Theorem 15 good/very-good) are **already proved sorry-free** in the Lean codebase — the problem is that they are not connected to the completeness theorem.

## Key Findings

### Finding 1: Reynolds Theorem 15 is Already Sorry-Free (Teammate A)

The full Reynolds pipeline — from `no_boundary_at_successor` through `gap_prior_UZ_contradiction`, `reynolds_model_surgery_core`, `no_gaps_discrete_model_surgery`, to `one_class` — has **zero sorry statements**. The formalization faithfully implements Reynolds' Sections 7-8 at the `OrderedMonadicStructure` level.

### Finding 2: The Formalization Over-Engineers (Teammate D)

Reynolds' proof architecture:
```
MCS → chronicle → countable discrete Prior structure M
  → one_class (Theorem 14 + Theorem 15 punchline)
  → very_good → good (Lemma 16, lexicographic sum)
  → k-equiv to Z-interval → truth transfer → countermodel on Z
```

The formalization's approach:
```
MCS → chronicle → omega-chain limit domain (LimitDomSubtype)
  → TRY TO PROVE IsSuccArchimedean (Z-isomorphism)    ← WRONG
  → succ_embed_surjective → BFMCS on Z
```

Reynolds never proves any structure IS isomorphic to Z. He only needs k-equivalence. The demand for `IsSuccArchimedean` is an over-engineering artifact of the BX pipeline.

### Finding 3: Bypass is NOT Feasible Without Refactoring (Teammate B)

The parametric truth lemma requires `D : Type` with `AddCommGroup`, `LinearOrder`, `IsSuccArchimedean`, etc. — instantiated as `Z`. `LimitDomSubtype` cannot serve as `D` because it lacks `AddCommGroup`. Therefore `succ_embed_surjective` is structurally necessary for the CURRENT architecture: it translates limit_dom witnesses to Z time points.

### Finding 4: The Real Bottleneck is succ_embed_surjective (Teammate C)

The critic verified the sorry chain and identified that `succ_embed_surjective` (not `chronicle_gap_contradiction`) is the true chokepoint. Both `restricted_tc` and `restricted_fuc` use it for the same purpose: converting limit_dom witnesses back to Z indices. There exists a sorry-free `succ_embed_squeeze` that might work if cofinality can be shown.

### Finding 5: Two Viable Strategies Remain

**Strategy A: Prove omega-chain connectivity (Teammate B recommendation)**
- Prove `chronicle_gap_contradiction` by showing the omega-chain produces a single connected component
- Induction on cardinality of `dom(N) ∩ (a,b)` as well-founded measure
- Each point insertion either extends the succ orbit or creates a smaller sub-problem
- Effort: 400-600 lines. Risk: MEDIUM
- This closes the sorry chain as-is without architectural changes

**Strategy B: Reynolds k-equivalence bypass (Teammate A + D recommendation)**
- Don't prove `IsSuccArchimedean` at all
- Apply `one_class` (sorry-free) to the FULL LimitDomSubtype as an OrderedMonadicStructure
- Use `very_good → good` (ShiftAndGlue, sorry-free) → k-equiv to Z-interval
- Build countermodel via k-equivalence truth transfer
- **Requires refactoring** `countermodel_discrete_reynolds` to use k-equivalence instead of Z-indexing
- Effort: 350-700 lines. Risk: MEDIUM (refactoring existing infrastructure)
- This eliminates the sorry chain AND the architectural over-engineering

## Synthesis: Conflicts and Resolution

### Conflict 1: Can bypass work?
- **Teammate B** says bypass is NOT FEASIBLE (parametric truth lemma needs AddCommGroup on Z)
- **Teammate D** says bypass IS the right path (Reynolds only needs k-equivalence)
- **Resolution**: Both are correct about different things. The CURRENT `countermodel_discrete_reynolds` cannot bypass because it uses parametric Z-indexed families. But the countermodel COULD be restructured to use k-equivalence truth transfer (Reynolds Stage 5), which builds a NEW Z-structure from the k-equivalence rather than demanding the limit domain itself be Z. This is Strategy B — it requires refactoring, not just rewiring.

### Conflict 2: Which strategy is better?
- **Strategy A** (connectivity): fixes the sorry within the current architecture. Lower risk, no refactoring. But leaves the over-engineering in place.
- **Strategy B** (k-equivalence): follows Reynolds faithfully, eliminates architectural debt. Higher effort, requires refactoring. But makes the proof match the literature.
- **Resolution**: Strategy A is the pragmatic choice for unblocking `completeness_discrete` quickly. Strategy B is the principled choice for publication quality. **Recommend Strategy A first, Strategy B as follow-up.**

### Gap Identified: Connecting one_class to LimitDomSubtype

Whether pursuing Strategy A or B, a key missing piece is: wrapping `LimitDomSubtype` as an `OrderedMonadicStructure` and proving Prior-UZ/SZ hold on it. This enables applying the sorry-free `one_class` theorem to the limit domain. Both strategies benefit from this bridge.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Finding |
|----------|-------|--------|------------|-------------|
| A | Reynolds proof structure | completed | high | Theorem 15 already sorry-free; operates on FULL structure |
| B | Alternative approaches | completed | high | Bypass infeasible without refactoring; connectivity most promising |
| C | Critic | completed | high | Bottleneck is succ_embed_surjective; squeeze path exists |
| D | Strategic horizons | completed | high | IsSuccArchimedean is over-engineering; k-equivalence suffices |

## Recommendations

1. **Immediate (Strategy A)**: Prove omega-chain connectivity via stage induction with cardinality measure. Closes `chronicle_gap_contradiction` → cascades through sorry chain. ~400-600 lines.

2. **Follow-up (Strategy B)**: Refactor `countermodel_discrete_reynolds` to use k-equivalence truth transfer instead of Z-indexing. Eliminates architectural over-engineering. ~350-700 lines.

3. **Bridge work (both strategies)**: Wrap `LimitDomSubtype` as `OrderedMonadicStructure` with Prior-UZ/SZ proof. Apply `one_class` (sorry-free). ~100-200 lines.

## References

- Reynolds 1994, Sections 7-8 (Theorems 14-15)
- GoodStructuresModelSurgery.lean (sorry-free model surgery)
- GoodStructures.lean (good, very_good, contemp_equiv)
- NoGapsDiscreteProof.lean (one_class)
- ShiftAndGlue.lean (very_good → good)
- ChronicleToCountermodel.lean (sorry chain)
- Transfer.lean (countermodel_discrete_reynolds)
