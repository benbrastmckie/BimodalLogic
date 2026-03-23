# Research Report: Task #35

**Task**: Prove remaining sorries and axioms in Succ-chain completeness pipeline
**Date**: 2026-03-23
**Mode**: Team Research (2 teammates)

## Summary

All 7 items from the task description have been located, analyzed, and classified. Key findings:

1. **Critical correction**: `succ_propagates_P_not` (CanonicalTaskRelation.lean:665) is **already proven**. The sorry referenced in the task description at SuccRelation.lean:497 is inside `single_step_forcing_past`, not `succ_propagates_P_not` itself. The actual item count is still 7, but item identities differ from the description.

2. **Box backward should be skipped**: The sorry at SuccChainTruth.lean:254 is explicitly documented in the codebase as "not needed for completeness" and requires BFMCS (multi-history model) infrastructure far beyond the current scope.

3. **5 items are provable with clear paths**: Contraction, single_step_forcing_past, backward_witness, succ_chain_fam_p_step (backward cases), and the forward case of succ_chain_fam_p_step all have identified proof strategies.

4. **2 items (nesting boundaries) require new infrastructure**: `f_nesting_boundary` and `p_nesting_boundary` require temporal filtration or Fischer-Ladner closure arguments. Both teammates recommend keeping these as axioms for now, as they are semantically justified but require substantial new infrastructure to formalize.

## Corrected Item List

| # | Item | Location | Type | Status |
|---|------|----------|------|--------|
| 1 | `f_nesting_boundary` | SuccChainFMCS.lean:583 | axiom | Needs filtration infrastructure |
| 2 | `p_nesting_boundary` | SuccChainFMCS.lean:695 | axiom | Symmetric to #1 |
| 3 | `succ_chain_fam_p_step` | SuccChainFMCS.lean:335 | axiom | Backward cases easy; forward needs new lemma |
| 4 | Box backward | SuccChainTruth.lean:254 | sorry | **SKIP** — not needed for completeness |
| 5 | Structural contraction | SuccChainCompleteness.lean:109 | sorry | Easy — use `derivation_exchange` |
| 6 | `backward_witness` | CanonicalTaskRelation.lean:785 | sorry | Medium — depends on #7 |
| 7 | `single_step_forcing_past` | SuccRelation.lean:497 | sorry | Medium — add explicit p_step parameter |

## Key Findings

### Primary Approach (from Teammate A)

**Item-by-item analysis** with full type signatures, proof approaches, and dependency mapping:

- **Contraction (#5)**: Standard structural rule. The goal is: given `L ⊢ ⊥` where all elements of L are `φ.neg`, derive `[φ.neg] ⊢ ⊥`. Use `derivation_exchange` from MCSProperties.lean:61, since `contextAsSet L = contextAsSet [φ.neg]` when all elements are identical.

- **single_step_forcing_past (#7)**: Steps 1-5 of the proof outline (lines 336-496) are complete. The gap is at step 6-8: needs `p_content v ⊆ u ∪ p_content u` (P-step property). **Solution**: Add `h_p_step` as an explicit parameter rather than deriving it from abstract Succ (which doesn't include P-step). All call sites in `CanonicalTask_backward_MCS_P` already carry `h_p_step`.

- **backward_witness (#6)**: P-direction analog of the proven `bounded_witness` (CanonicalTaskRelation.lean:541). Depends on #7 being fixed. A chain direction confusion exists in the current proof attempt — the induction peels from the wrong end. Two fixes proposed: (a) add `tail_inv` for `CanonicalTask_backward_MCS_P`, or (b) create `single_step_forcing_past_pstep` variant with explicit P-step.

- **succ_chain_fam_p_step (#3)**: Case split on chain index. Backward cases (n < 0) use the proven `backward_chain_p_step` (SuccChainFMCS.lean:264). Forward case (n ≥ 0) needs a new `successor_satisfies_p_step` lemma in SuccExistence.lean, which requires analyzing the deferral seed structure for P-step properties.

- **Nesting boundaries (#1, #2)**: Require showing F-chains (resp. P-chains) in a consistent MCS must terminate. The standard proof uses Fischer-Ladner closure finiteness or temporal filtration. Neither is currently formalized. Teammate A notes: `iter_F n phi` has strictly increasing complexity, but `temp_4` (F(phi) → FF(phi)) makes F-chains upward-closed in MCS, so the inconsistency argument doesn't work directly — filtration is genuinely needed.

### Alternative Approaches (from Teammate B)

**Template proofs and reusable patterns identified**:

1. **Pattern A (Boundary via Nat.find)**: For nesting boundaries, use `Nat.find` with predicate `p n := iter_F (n+1) phi ∉ M`. The missing piece is proving `∃ n, p n`, which requires filtration theory.

2. **Pattern B (Succ G-persistence cascade)**: Proven 5-step chain used in both `succ_propagates_F_not` and `succ_propagates_P_not`. Already fully proven for P-direction.

3. **Pattern C (P-step from predecessor construction)**: `predecessor_satisfies_p_step` (SuccExistence.lean:573) provides the template for forward-chain P-step.

4. **Pattern D (Chain endpoint inversion)**: For `backward_witness`, restructure induction to peel from `v`'s side (endpoint with P-obligations). Requires `tail_inv` for `CanonicalTask_backward_MCS_P`.

5. **Pattern E (Contraction via derivation_exchange)**: Direct application — `contextAsSet L = contextAsSet [φ.neg]` when all elements equal `φ.neg`.

**Key Mathlib resources**: `Nat.find`/`Nat.find_spec`/`Nat.find_min` for nesting boundaries; `derivation_exchange` for contraction.

## Synthesis

### Conflicts Resolved

1. **Contraction difficulty**: Teammate A rated MEDIUM, Teammate B rated LOW. **Resolution**: LOW is correct — `derivation_exchange` provides a direct path since the proof operates at the set level, and `contextAsSet` collapses duplicate list elements. No induction on derivation trees needed.

2. **single_step_forcing_past difficulty**: Teammate A rated MEDIUM-HIGH (considering API changes), Teammate B rated LOW-MEDIUM (with explicit parameter). **Resolution**: LOW-MEDIUM — the explicit `h_p_step` parameter approach is surgical and doesn't require changing the `Succ` definition. Call sites already carry this data.

3. **Nesting boundaries disposition**: Both teammates agree these should remain as axioms for now. Teammate A explored Fischer-Ladner closure but concluded it needs substantial new infrastructure. Teammate B confirmed that `temp_4` makes F-chains upward-closed, so simple consistency arguments fail — genuine filtration theory is required.

### Gaps Identified

1. **Forward-chain P-step**: Neither teammate fully resolved how `successor_from_deferral_seed` satisfies P-step. This is the key unknown for eliminating the `succ_chain_fam_p_step` axiom's forward case. May require analyzing the deferral seed structure in detail during implementation.

2. **Chain inversion direction**: The `backward_witness` proof needs either `tail_inv` infrastructure or the `single_step_forcing_past_pstep` variant. The exact choice should be made during implementation based on which is cleaner.

### Recommendations

**Recommended proof order** (dependency-respecting):

1. **Contraction** (#5) — independent, easy, immediate win
2. **single_step_forcing_past** (#7) — add explicit `h_p_step` parameter
3. **backward_witness** (#6) — depends on #7, use `bounded_witness` as template
4. **succ_chain_fam_p_step backward cases** (#3 partial) — use `backward_chain_p_step`
5. **succ_chain_fam_p_step forward case** (#3 partial) — needs `successor_satisfies_p_step`
6. **Skip**: Box backward (#4) — documented as not needed
7. **Defer**: `f_nesting_boundary` (#1) and `p_nesting_boundary` (#2) — keep as axioms

**Net result**: 3 sorries resolved, 1 axiom eliminated (partially — backward cases of `succ_chain_fam_p_step`), 1 sorry skipped (documented), 2 axioms retained with justification.

**Alternative ambitious scope**: If filtration infrastructure is deemed worthwhile, items #1 and #2 could be tackled, but this would significantly expand the task scope and require new definitions (modal depth, Fischer-Ladner closure, filtration lemma).

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary item-by-item analysis | completed | high |
| B | Patterns, prior art, alternatives | completed | high |

## References

### Key Source Files
| File | Line | Content |
|------|------|---------|
| CanonicalTaskRelation.lean | 541 | `bounded_witness` (F-direction template) |
| CanonicalTaskRelation.lean | 496 | `succ_propagates_F_not` (F-direction template) |
| CanonicalTaskRelation.lean | 665 | `succ_propagates_P_not` (already proven) |
| SuccRelation.lean | 354-497 | `single_step_forcing_past` (sorry at 497) |
| SuccExistence.lean | 573 | `predecessor_satisfies_p_step` (P-step template) |
| SuccChainFMCS.lean | 264 | `backward_chain_p_step` (proven) |
| SuccChainFMCS.lean | 638 | `succ_chain_forward_F` (nesting boundary usage) |
| MCSProperties.lean | 61 | `derivation_exchange` (contraction tool) |

### Teammate Reports
- [01_teammate-a-findings.md](01_teammate-a-findings.md) — Full item-by-item analysis with type signatures
- [01_teammate-b-findings.md](01_teammate-b-findings.md) — Patterns, prior art, and alternative approaches
