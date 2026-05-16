# Research Report: Task #154 — Order Atom Blocker Resolution

**Task**: 154 - sum_preservation_ef_games
**Date**: 2026-05-15
**Mode**: Team Research (4 teammates)
**Session**: sess_1778890351_0d9c53
**Focus**: Identify the mathematically correct solution for the order atom transfer blocker in `sum_nf_agree`

## Summary

All 4 teammates reached unanimous consensus: the 4 sorry's in `sum_nf_agree` (NEquivalence.lean lines 264, 334, 400, 459) are **genuinely unresolvable** with the current proof invariant. The fix is to replace the per-element 1-variable NF hypothesis (`h_elem`) with a **joint multi-variable NF characteristic equality** at the ordered-sum level. This mirrors exactly how `nf_agreement_monotone` (NormalForm.lean:339-421) handles the same challenge within a single structure.

### Root Cause (confirmed by all teammates)

`AtomKind sig 1` contains **zero order atoms** — the constructor `order i j (h : i ≠ j)` with `i, j : Fin 1` is impossible since `Fin 1 = {0}`. Therefore, 1-variable NF characteristics encode only predicate truth values and quantifier reachability, with no positional/order information whatsoever. When a witness `⟨i, b⟩` is selected to match `⟨i, a⟩` via 1-variable NF matching, there is no constraint on the order of `b` relative to existing same-component environment elements.

### Partial Closability (Teammate C critical finding)

Of the 4 sub-cases in each sorry (after `Fin.cases` on j₁ and j₂):
- **Both succ**: closable via `h_atoms` (existing environment atoms)
- **Both zero**: impossible since `h_ne`
- **Cross-component**: closable via `h_idx` (same component indices)
- **Same-component, same index**: **STUCK** — the only genuinely blocked sub-case

This means 3 of 4 sub-cases could be closed immediately even without restructuring, narrowing the actual gap.

## Recommended Approach: Joint NF Characteristic Equality

**Consensus rating: HIGH confidence (all 4 teammates)**

### The Fix

Replace the current `sum_nf_agree` invariant structure:

**Current** (broken):
```
h_elem : ∀ m ≤ k, ∀ j : Fin n, ∀ nf_j : NormalForm sig m 1,
  nf_eval_nf (ms (env_M j).1) m 1 (fun _ => (env_M j).2) nf_j ↔
  nf_eval_nf (ms' (env_N j).1) m 1 (fun _ => (env_N j).2) nf_j
```

This gives per-element 1-variable NF agreement — insufficient for order.

**Fixed** (two equivalent formulations):

**Option A** — Joint ordered-sum NF (Teammates A, B prefer):
```
h_char : nf_characteristic (orderedSum sig I ms) k n env_M =
         nf_characteristic (orderedSum sig I ms') k n env_N
```

This single hypothesis encodes ALL atom agreements (predicate AND order) between all environment positions. When extending environments, `nf_agreement_from_shared_nf` gives atom agreement for free.

**Option B** — Per-component joint NF (Teammate C prefers as potentially cleaner):
```
h_joint_i : ∀ i, nf_characteristic (ms i) k n_i (sub_env_M i) =
            nf_characteristic (ms' i) k n_i (sub_env_N i)
```

Where `sub_env_M i` extracts the sub-environment of all elements in component `i`.

### Why This Works

1. **Base case (n=0)**: Joint NF with 0 variables reduces to component k-equivalence (`h_comp`), which is the given hypothesis.

2. **First quantifier step (n=0→1)**: `AtomKind sig 1` has no order atoms, so 1-variable NF transfer suffices. The current proof already handles this correctly.

3. **Subsequent steps (n≥1→n+1)**: Joint NF at depth k with n+1 variables encodes ALL pairwise order atoms. When selecting a witness `⟨i, b⟩` to match `⟨i, a⟩`, use the component's (k+1)-equivalence quantifier transfer to find `b` that satisfies the SAME joint NF as `a` together with all existing same-component environment elements. `nf_agreement_from_shared_nf` then gives atom-level agreement including order.

4. **Cross-component order**: Handled by `h_idx` (environment elements have matching component indices), so lexicographic order between different components is automatically preserved.

### Implementation Estimate

- ~150-250 additional lines (restructuring, not from scratch)
- Uses existing infrastructure: `nf_agreement_monotone`, `nf_agreement_from_shared_nf`, `nf_characteristic`, `nf_exists_unique`
- No new axioms, typeclasses, or EF-game machinery needed

## Strategic Finding (Teammate D)

**Finite index sets suffice**: `very_good_implies_good` (Reynolds Lemma 16) only uses `sum_preservation` with a **finite** index set — the condensation quotient by `contemp_equiv` has finitely many equivalence classes bounded by `Fintype.card (KType sig k)`. If the general proof is slow, proving `sum_preservation` restricted to `[Fintype I]` is mathematically sufficient to activate the entire Reynolds pipeline.

**Additional blocker for task 155**: Transfer.lean Step 6 (ZIntervalStructure → TaskFrame bridge) is not yet implemented and must be included in task 155's scope.

## Rejected Alternatives

| Alternative | Reason for Rejection |
|-------------|---------------------|
| EF-game approach | 400-600 lines of new infrastructure, no Mathlib support, no reuse (Teammate B) |
| Quantifier-free reduction | Order atom problem is intrinsic to quantifier step, not base case (Teammate B) |
| Axiomatize with sorry | Zero-debt policy prohibits (Teammate D) |
| KEquivalenceFramework redesign | Typeclass is well-designed; issue is proof-engineering (Teammate D) |

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary | completed | high | Detailed proof structure analysis, joint NF invariant formulation |
| B | Alternatives | completed | high | Concrete counterexample (Z with no predicates), eliminated EF games |
| C | Critic | completed | high | Confirmed blocker, identified 3/4 sub-cases closable, sharpened to single stuck case |
| D | Horizons | completed | high | Finite index sets suffice for Reynolds pipeline, Transfer.lean blocker |

## Conflicts and Resolution

**No conflicts found.** All 4 teammates independently converged on the same diagnosis and the same family of solutions (joint NF characteristic equality). The only variation is between Option A (ordered-sum level) and Option B (per-component level), which are mathematically equivalent — Option A is slightly simpler to implement as it directly mirrors `nf_agreement_monotone`.

## Next Steps

1. `/revise 154` to restructure the implementation plan around the joint NF approach
2. `/implement 154` to close the 4 sorry's using the new invariant
3. Consider the `[Fintype I]` restriction as a fallback if the general proof exceeds budget
