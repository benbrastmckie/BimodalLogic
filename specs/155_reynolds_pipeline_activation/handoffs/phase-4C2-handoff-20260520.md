# Phase 4C.2 Handoff: Inductive Step Setup + Case Split

## What Was Done

Task 4C.2 of the GHR93 Theorem 6 proof: established the inductive step structure for `ghr93_forward_to_backward` in `ExpressivenessGeneral.lean`.

### Key artifacts added (266 lines):

1. **`SplitPointProps` structure** (lines 136-163): Bundles properties of the split points c (in M_r) and d (in N_r), including interval containment, the bound `d <= a_n`, and backward strategies sigma/tau on sub-intervals.

2. **`obtain_split_point_props` theorem** (lines 172-210): Sorry'd construction of the split points. Currently uses trivial values (x, x') with sorry'd properties. The full implementation requires:
   - Computing the interval type A = X_{(a_{n-1}, a_n)}
   - Defining continuation formula C from A
   - Computing d = inf{t : C holds on (t,y')} (infimum in ExtendedCarrier)
   - Computing c via the forward strategy
   - Restricting the forward strategy to sub-intervals [x,c] and [c,y]
   - Applying the IH to get sigma and tau

3. **`ghr93_case_I` theorem** (lines 243-277): Sorry'd Case I (split case) where some selection falls below d. The proof requires partitioning selections, applying sigma/tau to each partition, and merging responses.

4. **`ghr93_cases_II_III_IV` theorem** (lines 301-324): Sorry'd combined Cases II-IV where all selections are at or above d. Further case split needed on whether a_n is a point, left-defined gap, or non-left-defined gap.

5. **`ghr93_inductive_step` theorem** (lines 333-356): Assembly theorem that unfolds the backward game, obtains split points, and dispatches to Case I or Cases II-IV via `by_cases`.

6. **Main theorem updated** (lines 431-449): The `| succ n _ih =>` branch now rewrites `1 + 3*(n+1) = 4 + 3*n` and calls `ghr93_inductive_step`.

## Current Sorry Count in ExpressivenessGeneral.lean

- `obtain_split_point_props`: 3 sorries (hd_le_an, sigma, tau)
- `ghr93_case_I`: 1 sorry (full Case I proof)
- `ghr93_cases_II_III_IV`: 1 sorry (Cases II-IV)
- `ghr93_forward_to_backward_rank_varying`: 1 sorry (rank-varying version)
- Total: 6 sorries (was 2 before this task)

## Immediate Next Action

**Task 4C.3**: Prove `ghr93_case_I`. This requires:
1. Partitioning `a_bwd` into elements below d and elements at/above d
2. Applying `props.sigma` to the below-d elements (via round monotonicity)
3. Applying `props.tau` to the at-or-above-d elements (via round monotonicity)
4. Merging the two responses into a single (n+1)-element response
5. Handling Round 2 by delegating to the appropriate sub-strategy
6. Verifying the combined winning condition

Alternatively, the next agent could focus on `obtain_split_point_props` to provide real split points instead of the trivial placeholders.

## Key Decisions

1. **Factored the inductive step into a separate theorem** rather than inlining it in the `succ` branch. This makes each case independently addressable.

2. **Bundled split point properties in a structure** rather than passing them as individual hypotheses. This makes the case helper signatures cleaner.

3. **Split into Case I vs Cases II-IV** rather than a 4-way case split, because Cases II-IV all share the premise "all selections at or above d" and differ only in the nature of a_n.

4. **Used `∃ i, a_bwd i < d` as the Case I predicate** rather than the GHR93 formulation "a_0 < d", since the selections are not necessarily ordered and the Lean formalization uses `Fin (n+1)` indexing rather than sorted sequences.

## Build Status

`lake build` passes (1647 jobs, 0 errors). All new code compiles with sorry'd sub-goals.
