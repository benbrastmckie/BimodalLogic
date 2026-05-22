# Seed Research Report: Unify Computable and Tactic Proof Search Systems

**Task**: #186 — Unify computable and tactic proof search systems
**Date**: 2026-05-22
**Type**: Seed report (preliminary — expand during /research phase)

## Motivation

The project maintains two parallel proof search implementations that have diverged significantly:

1. **`modal_search`** (Tactics.lean, ~450 lines of search logic): A `TacticM`-based recursive search that constructs `DerivationTree` proof terms via `mkAppM`. It works directly on Lean goals at the meta-level, successfully building Type-valued witnesses. Used by `modal_search`, `temporal_search`, `propositional_search`, and `tm_auto` tactics.

2. **`bounded_search` / `bounded_search_with_proof`** (ProofSearch.lean, ~960 lines): A computable Lean function implementing IDDFS, best-first search, and pattern learning. `bounded_search` returns `Bool`; `bounded_search_with_proof` returns `Option (DerivationTree G p)`. Includes `SearchConfig`, `HeuristicWeights`, `PatternDatabase`, and `SearchStats`.

The computable search has richer algorithms (IDDFS completeness, best-first with heuristics, pattern learning) but weaker proof construction (no modal K/temporal K in the proof-returning variant). The tactic search has stronger proof construction but simpler algorithms (fixed-order DFS only). Neither benefits from the other's strengths. Unifying them would give the tactic the computable search's algorithmic sophistication, and give the computable search the tactic's complete proof construction.

## Current State

### TacticM-based search (Tactics.lean)

**`searchProof`** (line 862-893): Recursive DFS with fixed strategy order:
1. `tryAxiomMatch` — try all registered axiom constructors
2. `tryAssumptionMatch` — context lookup via `simp`
3. `tryModusPonens` — backward chain from context implications (depth > 1)
4. `tryModalK` — reduce `□Γ ⊢ □φ` to `Γ ⊢ φ` (depth > 1)
5. `tryTemporalK` — reduce `FΓ ⊢ Fφ` to `Γ ⊢ φ` (depth > 1)

**`SearchConfig`** (line 904-919): Defines `depth`, `visitLimit`, and weights for axiom/assumption/mp/modalK/temporalK. However, `searchProof` ignores all config fields except `depth` — the weights, visitLimit, and strategy ordering are not used. This is noted at line 1028: "visitLimit and weights not yet used by searchProof (future enhancement)".

**`runModalSearch`** (line 1019-1030): Creates config, validates goal, calls `searchProof`. Only passes `cfg.depth`.

### Computable search (ProofSearch.lean)

**`bounded_search`** (line 779-835): Bool-returning search with:
- Hash-based `ProofCache` memoization
- `Visited` cycle detection
- `visitLimit` enforcement
- `HeuristicWeights`-guided branch ordering via `orderSubgoalsByScore`
- Modal K and temporal K rules
- `SearchStats` tracking (hits, misses, visited, pruned)

**`bounded_search_with_proof`** (line 886-959): Proof-returning variant. Missing features vs `bounded_search`:
- NO modal K or temporal K (lines 951-955: "Modal/temporal rules would go here")
- No caching (noted: "caching would require storing proofs indexed by (Γ, φ)")
- No heuristic ordering
- Uses `findMembershipWitness` for direct proof construction instead of `simp`

**`iddfs_search`** (line 987-1011): Iterative deepening wrapper. Complete and optimal. Used by `search` function.

**`bestFirst_search`** (line 1095-1178): Priority queue search. Uses `pattern_aware_score` for node ordering. Complete within expansion limit.

**`search_with_learning`** (line 1309-1325): Records success patterns via `PatternDatabase`.

### Key divergences

| Feature | modal_search (tactic) | bounded_search (computable) |
|---------|----------------------|---------------------------|
| Axiom matching | `tryAxiomMatch` (12 patterns) | `matchAxiom` (more patterns) |
| Assumption | `simp` on membership goal | `findMembershipWitness` (decidable) |
| Modus ponens | Context-only backward chain | Context-only backward chain |
| Modal K | Full (via `generalized_modal_k`) | Bool only (no proof term) |
| Temporal K | Full (via `generalized_temporal_k`) | Bool only (no proof term) |
| Caching | None | `ProofCache` (HashMap) |
| Heuristics | Config exists, unused | Full heuristic scoring |
| IDDFS | No | Yes |
| Best-first | No | Yes |
| Pattern learning | No | Yes |
| Visit limit | Config exists, unused | Enforced |
| Proof output | DerivationTree (via mkAppM) | Option DerivationTree (incomplete) |

## Proposed Approach

### Phase 1: Complete bounded_search_with_proof

Add modal K and temporal K rules to `bounded_search_with_proof` (ProofSearch.lean:951-955). This requires:
- A computable function to check if all context formulas are boxed/futured
- Context transformation (unbox/unfuture)
- Apply `generalized_modal_k` / `generalized_temporal_k` to construct the proof term
- These are `noncomputable` — determine if this blocks the computable search or requires `noncomputable` propagation

### Phase 2: Make SearchConfig functional in searchProof

Wire `SearchConfig` weights into `searchProof` (Tactics.lean):
- Respect `visitLimit` with a mutable counter (or thread through recursion)
- Use weights to determine strategy ordering (sort strategies by weight before trying)
- This makes the existing named-parameter syntax (`modal_search (depth := 20) (visitLimit := 2000)`) actually work

### Phase 3: Add IDDFS and caching to modal_search

Port IDDFS from ProofSearch.lean to the tactic. Instead of a single DFS at fixed depth, run iterative deepening. Add `observing?`-based caching to avoid re-exploring failed subgoals.

### Phase 4: Optional computable fallback

Add a fallback path: when `searchProof` fails in `TacticM`, optionally call `bounded_search_with_proof` as a fallback. This leverages the computable search's different heuristic ordering. Guard behind a flag to avoid double-searching by default.

### Phase 5: Tests and benchmarks

Create a benchmark suite comparing tactic vs computable search on the same goal set. Measure: goals closed, time, nodes visited.

## Key Questions for Research Phase

1. **Noncomputability barrier**: `generalized_modal_k` and `generalized_temporal_k` are `noncomputable` (they use the deduction theorem). Can `bounded_search_with_proof` use them and remain a valid Lean function, or must the entire function become `noncomputable`? What are the implications for `#eval`-based testing?

2. **Caching proof terms**: Is it feasible to cache `DerivationTree` proof terms in a `HashMap`? The terms can be large and require `BEq`/`Hashable` instances for `DerivationTree` (which may not exist). Alternative: cache at the `Bool` level first, then reconstruct proofs only for successful paths.

3. **TacticM performance**: Does `observing?` (used for backtracking in `tryAxiomMatch`, `tryAssumptionMatch`, etc.) have significant overhead? Should we batch operations to minimize `observing?` calls?

4. **Strategy interleaving**: Should the unified search interleave tactic-based and computable strategies, or use one as primary with the other as fallback?

5. **Pattern learning in TacticM**: Can the `PatternDatabase` from ProofSearch.lean be maintained across tactic invocations? Environment extensions or a global `IO.Ref` could persist the database within a file elaboration.

## Estimated Scope

- **Phase 1** (complete bounded_search_with_proof): 4 hours
- **Phase 2** (wire SearchConfig): 3 hours
- **Phase 3** (IDDFS in tactic): 4 hours
- **Phase 4** (computable fallback): 2 hours
- **Phase 5** (benchmarks): 2 hours
- **Total**: ~15 hours (medium effort)

## Dependencies

- **Depends on**: Task 185 (complete axiom coverage — both systems need consistent axiom sets)
- **Depended on by**: Task 192 (master dispatch — needs unified search as backend)
- **Related**: Task 187 (lemma database — benefits from unified search), Task 190 (normalization — pre-processing before search)

## References

- `Theories/Bimodal/Automation/Tactics.lean` — `searchProof` (862), `SearchConfig` (904), `runModalSearch` (1019)
- `Theories/Bimodal/Automation/ProofSearch.lean` — `bounded_search` (779), `bounded_search_with_proof` (886), `iddfs_search` (987), `bestFirst_search` (1095), `search_with_learning` (1309)
- `Theories/Bimodal/Automation/SuccessPatterns.lean` — `PatternDatabase`, `PatternKey`, `ProofStrategy`
- Mathlib's `solve_by_elim` architecture — for comparison of tactic vs term-level search integration
