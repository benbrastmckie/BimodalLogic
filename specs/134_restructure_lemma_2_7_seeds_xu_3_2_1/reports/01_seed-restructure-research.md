# Research Report: Restructure lemma_2_7/lemma_2_7_since Seeds Using Xu 3.2.1

- **Task**: 134 - Restructure lemma_2_7/lemma_2_7_since seeds using Xu 3.2.1
- **Started**: 2026-05-13T21:10:00Z
- **Completed**: 2026-05-13T21:30:00Z
- **Effort**: 6-8 hours estimated
- **Dependencies**: Task 115 (Xu 3.2.1 implementation, completed)
- **Sources/Inputs**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (4347 lines)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (3488 lines)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (1612 lines)
  - `specs/115_replace_a4a_with_left_mono_until_g/summaries/03_remove-a4a-summary.md`
  - `specs/115_replace_a4a_with_left_mono_until_g/reports/03_team-research.md`
- **Artifacts**: This report
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Project Context

- **Upstream Dependencies**: `xu_lemma_3_2_1_until` (line 1548), `xu_lemma_3_2_1_since` (line 1680) in PointInsertion.lean; `dcs_neg_union_consistent` (line 458); `dc_delta_B_burgessR3` (line 657)
- **Downstream Dependents**: `CounterexampleElimination.lean` — calls `lemma_2_7` at 6 sites (lines 1001, 1029, 1033, 1044, 2078, 2107, 2112, 2129) and `lemma_2_7_since` at 5 sites (lines 1581, 1609, 1613, 1624, 2607, 2635, 2639, 2651)
- **Alternative Paths**: Keep current 5-component seed (working, sorry-free) but drop components 3-4 only
- **Potential Extensions**: `lemma_2_8` / `lemma_2_8_since` share the same seed — simplification applies there too

## Executive Summary

- The current `lemma_2_7_seed` has 5 components: B ∪ {eta} ∪ {untl(γ,β)} ∪ {snce(α,β)} ∪ {snce(α,β∧xi)}. Components 3 and 4 are redundant via Xu 3.2.1, but component 5 (`snce(α, β∧xi)`) is NOT directly available from Xu 3.2.1 since xi ∉ B.
- The seed can be reduced from 5 components to 3: B ∪ {eta} ∪ {snce(α, β∧xi)}. Components 3-4 are provably in B* via Xu 3.2.1, so they need not be in the seed.
- The seed CANNOT be reduced to the trivial `B ∪ {eta}` claimed in the task description. The 5th component is essential for establishing `xi ∈ B'` in the output.
- The consistency proof still simplifies significantly (~300 lines removable) because the 5-way case analysis on seed membership reduces to 3-way.
- An alternative approach exists: restructure the `lemma_2_7` proof to derive `snce(α, β∧xi) ∈ D` post-hoc from the seed `B ∪ {eta}` using properties of D (which extends B). This is mathematically feasible but requires substantial new proof work.

## Context & Scope

### Current Architecture

`lemma_2_7` (Burgess 1982, p.372) splits a BurgessR3Maximal(A, B, C) triple given `untl(eta, xi) ∈ A` and `xi ∉ B`. It produces D (MCS with eta ∈ D) and B' (with xi ∈ B') such that BurgessR3Maximal(A, B', D) and BurgessR3Maximal(D, B'', C).

The proof constructs D by Lindenbaum-extending the 5-component seed, then uses seed membership to establish:
1. `eta ∈ D` — from component 2 ({eta})
2. `B ⊆ D` — from component 1 (B)
3. `burgessR3(D, B, C)` — from component 3 (untl formulas)
4. `burgessR3(A, B, D)` — from component 4 (snce formulas)
5. `burgessR3(A, DC({xi}∪B), D)` — from component 5 (snce(β∧xi,α) formulas), via burgessR_conj
6. `xi ∈ B'` — from step 5, via Zorn on DC({xi}∪B)

### Task 115 Precedent

Task 115 simplified `lemma_2_6_splitting` from a rich D₀ seed to `{β.neg} ∪ B`, using Xu 3.2.1 to establish the Until/Since formulas in D post-hoc. That worked because `lemma_2_6_splitting` does NOT need the guard (delta/beta) in B'. Its output type is: BurgessR3Maximal(A, B', D) ∧ BurgessR3Maximal(D, B'', C) ∧ β.neg ∈ D.

`lemma_2_7` has a stronger output requirement: `xi ∈ B'`. This requires establishing `burgessR3(A, DC({xi}∪B), D)` — which needs `snce(α, β∧xi) ∈ D` for all β ∈ B, α ∈ A.

## Findings

### Finding 1: Components 3-4 Are Redundant (Confirmed)

The 3rd component `{untl(γ,β) | β∈B, γ∈C}` and 4th component `{snce(α,β) | β∈B, α∈A}` are entirely subsumed by Xu 3.2.1:

- `xu_lemma_3_2_1_until` (line 1548): BurgessR3Maximal(A,B,C) → untl(γ,β) ∈ B for all β ∈ B, γ ∈ C
- `xu_lemma_3_2_1_since` (line 1680): BurgessR3Maximal(A,B,C) → snce(α,β) ∈ B for all β ∈ B, α ∈ A

Since B is the 1st seed component and B ⊆ D (the Lindenbaum extension), these formulas are automatically in D. No explicit seed inclusion needed.

**Impact**: Removes ~307 lines of helper functions (l27_guard, l27_collect_guards, l27_c_event_list, l27_a_event_list, etc.) that extract guards/events from the 5-component seed structure. The consistency proof case analysis reduces from 5 cases to 3.

### Finding 2: Component 5 Cannot Be Dropped

The 5th component `{snce(α, β∧xi) | β∈B, α∈A}` is NOT available from Xu 3.2.1 because the guard `β∧xi` contains `xi`, and `xi ∉ B`. Xu 3.2.1 only provides `snce(α, β') ∈ B` for `β' ∈ B`.

The proof chain that derives `xi ∈ B'` (the critical output) is:
1. `snce(α, β∧xi) ∈ D` (from seed component 5)
2. `snce(α, xi) ∈ D` (via left_mono_since: (β∧xi) → xi)
3. `burgessRSince(D, xi, A) = ∀α∈A, snce(α, xi) ∈ D`
4. `burgessR(A, xi, D)` (via burgessRSince_implies_burgessR)
5. `burgessR(A, β∧xi, D)` for all β∈B (via burgessR_conj)
6. `burgessR3(A, DC({xi}∪B), D)` (via dc_delta_B_burgessR3)
7. `xi ∈ B'` (via Zorn from DC({xi}∪B))

Without component 5 in the seed, step 1 fails. No other path to step 4 is apparent without establishing `snce(α, xi) ∈ D` first.

### Finding 3: Alternative Post-Hoc Derivation Path (Theoretical)

It might be possible to derive `snce(α, β∧xi) ∈ D` without including it in the seed, by using the `burgessR3_untl_conj_in_A` helper (RRelation.lean:1417) applied to BurgessR3Maximal(A, B, C). This theorem gives:

`untl(δ, β'∧untl(γ,β)) ∈ A` for β,β' ∈ B, γ,δ ∈ C

However, the chain from this to `snce(α, β∧xi) ∈ D` is unclear. The key difficulty: xi = guard of `untl(eta, xi)`, not a formula in any of A, B, or C directly. To get `burgessR(A, xi, D)` we would need to show that xi participates in an R-relation with D, which is precisely what component 5 establishes.

A deeper investigation using `untl(eta, xi) ∈ A` + BX5 self-accumulation might yield a direct proof that `burgessR(A, xi, D)` from the simplified seed `B ∪ {eta}`. The self-accumulation `untl(xi∧untl(eta,xi), eta) ∈ A` puts xi-containing formulas in A, but extracting `burgessR(A, xi, D)` from this is non-trivial and would require new proof infrastructure.

### Finding 4: Partial Simplification Is Achievable

Reducing the seed from 5 to 3 components (B ∪ {eta} ∪ {snce(α,β∧xi)}) is straightforward:

**Current seed**:
```
B ∪ {eta} ∪ {untl(γ,β) | β∈B, γ∈C} ∪ {snce(α,β) | β∈B, α∈A} ∪ {snce(α,β∧xi) | β∈B, α∈A}
```

**Simplified seed**:
```
B ∪ {eta} ∪ {snce(α,β∧xi) | β∈B, α∈A}
```

The consistency proof would:
1. Use the same BX5+BX7+BX13 chain but with only 3 cases
2. Drop all untl-extraction and snce(β,α)-extraction helpers
3. The `lemma_2_7` proof body is unchanged — it derives components 3-4 memberships from Xu 3.2.1 + B ⊆ D (exactly as `lemma_2_6_splitting` does at lines 1835-1841)

### Finding 5: Scope of Changes

| Component | Lines | Removable? | Reason |
|-----------|-------|------------|--------|
| `lemma_2_7_seed` (def, line 1875) | 5 | Simplify | Remove 2 of 5 set-union components |
| l27_guard, l27_collect_guards (1880-1919) | 40 | Simplify | 5-case → 3-case |
| l27_c_event_list, l27_a_event_list (1921-1975) | 55 | Partially remove | untl extraction no longer needed |
| l27_collect_guards_mem_of_B (1984-2010) | 27 | Simplify | 5-case → 3-case |
| l27_seed_untl_mem, l27_seed_snce_mem (2015-2075) | 61 | Partially remove | component 3 helpers removable |
| l27_gen_guards, l27_gen_a_events (2082-2170) | 89 | Simplify | 5-case → 3-case |
| lemma_2_7_seed_consistent (2188-2592) | 405 | Major simplify | 5-way → 3-way case split |
| lemma_2_7 (2604-2705) | 102 | Minor edit | Replace seed extraction with Xu 3.2.1 for components 3-4 |
| lemma_2_8_seed_consistent (2713-3088) | 376 | Major simplify | Shares seed with 2.7 |
| lemma_2_7_since_seed (3093) | 5 | Simplify | Dual: remove 2 components, change component 5 |
| l27s helpers (3098-3183) | 86 | Simplify/remove | Dual extraction helpers |
| lemma_2_7_since_seed_consistent (3184-3531) | 348 | Major simplify | Dual consistency proof |
| lemma_2_7_since (3532-3620) | 89 | Minor edit | Replace extraction with Xu 3.2.1 |
| lemma_2_8_since_seed_consistent (3641-3975) | 335 | Major simplify | Shares since_seed |

**Estimated total removable**: ~700-900 lines from PointInsertion.lean (4347 → ~3500-3600 lines)

### Finding 6: lemma_2_7_since_seed Has Dual 5th Component

The since-direction seed is:
```
B ∪ {eta} ∪ {untl(γ,β) | β∈B, γ∈C} ∪ {snce(α,β) | β∈B, α∈A} ∪ {untl(γ,β∧xi) | β∈B, γ∈C}
```

Here component 5 is `untl(γ, β∧xi)` (not snce). The same analysis applies: components 3-4 are redundant via Xu 3.2.1, component 5 (`untl(γ,β∧xi)`) is needed for `xi ∈ B''` in the since direction.

### Finding 7: CounterexampleElimination Callers Need Full Output Type

All callers of `lemma_2_7` in CounterexampleElimination.lean destructure the FULL output tuple including `xi ∈ B'` (or discard it with `_` in the `lemma_2_8` cases where the caller already has xi ∈ g). The output type signature MUST remain unchanged:

```lean
∃ B' D B'', BurgessR3Maximal A B' D ∧ BurgessR3Maximal D B'' C ∧
  SetMaximalConsistent D ∧ eta ∈ D ∧ B ⊆ B' ∧ B ⊆ D ∧ B ⊆ B'' ∧ xi ∈ B'
```

Zero changes needed in CounterexampleElimination.lean.

## Decisions

- **Partial simplification**: Reduce seeds from 5 to 3 components (drop components 3-4, keep 5)
- **Output types unchanged**: Both `lemma_2_7` and `lemma_2_7_since` output types stay identical
- **Task description correction**: The task description claims "seed simplifies to B* ∪ {eta} with trivial consistency via dcs_neg_union_consistent." This is incorrect — the 5th component cannot be dropped and consistency is not trivial. The correct simplification is: B ∪ {eta} ∪ {5th component} with a simplified BX5+BX7+BX13 chain.

## Recommendations

1. **Implement partial simplification** (5→3 components): Drop seed components 3 and 4. In `lemma_2_7` and `lemma_2_7_since`, derive the untl/snce memberships from Xu 3.2.1 + B ⊆ D (following the pattern in `lemma_2_6_splitting`, lines 1835-1841). Estimated savings: ~700-900 lines.

2. **Simplify consistency proofs**: With only 3 seed components, the case analysis in `lemma_2_7_seed_consistent` / `lemma_2_7_since_seed_consistent` / `lemma_2_8_seed_consistent` / `lemma_2_8_since_seed_consistent` reduces from 5-way to 3-way. The BX5+BX7+BX13 chain logic stays but with fewer extraction helpers.

3. **Update task description**: Revise the task to reflect that the 5th component must be retained. The simplification is still substantial but not as dramatic as originally described.

4. **Phase structure** (recommended):
   - Phase 1: Simplify `lemma_2_7_seed` and `lemma_2_7_seed_consistent` (Until direction)
   - Phase 2: Update `lemma_2_7` to use Xu 3.2.1 for components 3-4
   - Phase 3: Simplify `lemma_2_8_seed_consistent` (shares Until seed)
   - Phase 4: Simplify `lemma_2_7_since_seed` and `lemma_2_7_since_seed_consistent` (Since direction)
   - Phase 5: Update `lemma_2_7_since` to use Xu 3.2.1 for components 3-4
   - Phase 6: Simplify `lemma_2_8_since_seed_consistent` (shares Since seed)
   - Phase 7: Clean up dead helpers, verify `lake build`

## Risks & Mitigations

- **Risk**: Consistency proof refactoring may introduce sorry or break downstream. **Mitigation**: Each phase verified with `lake build`. All existing proofs are sorry-free, providing a clear baseline.
- **Risk**: Helper functions used by both lemma_2_7_seed_consistent and lemma_2_8_seed_consistent (they share the same seed). **Mitigation**: Phase 1 and 3 must be coordinated — simplify helpers that both use before removing old ones.
- **Risk**: The 5th component consistency argument (BX5+BX7+BX13 chain) remains complex. **Mitigation**: This is the irreducible complexity — Burgess's original proof requires this chain for the xi ∈ B' output.

## Appendix

### Key Theorems (from Task 115)

| Theorem | Location | Statement |
|---------|----------|-----------|
| `xu_lemma_3_2_1_until` | PointInsertion.lean:1548 | R(A,B,C) → untl(γ,β) ∈ B for all β∈B, γ∈C |
| `xu_lemma_3_2_1_since` | PointInsertion.lean:1680 | R(A,B,C) → snce(α,β) ∈ B for all β∈B, α∈A |
| `dcs_neg_union_consistent` | PointInsertion.lean:458 | DCS B, φ∉B → {φ.neg}∪B consistent |
| `dc_delta_B_burgessR3` | PointInsertion.lean:657 | Extension of B by delta preserves burgessR3 |
| `burgessR_conj` | PointInsertion.lean (approx) | burgessR(A,β,C) ∧ burgessR(A,β',C) → burgessR(A,β∧β',C) |

### Seed Component Analysis

| # | Current Seed Component | In B via Xu 3.2.1? | Needed in seed? |
|---|------------------------|---------------------|-----------------|
| 1 | B | N/A (is B itself) | Yes |
| 2 | {eta} | No (eta arbitrary) | Yes |
| 3 | {untl(γ,β) : β∈B, γ∈C} | Yes (xu_lemma_3_2_1_until) | No |
| 4 | {snce(α,β) : β∈B, α∈A} | Yes (xu_lemma_3_2_1_since) | No |
| 5 | {snce(α,β∧xi) : β∈B, α∈A} | No (xi∉B, so β∧xi∉B) | Yes |

### Call Sites in CounterexampleElimination.lean

| Line | Lemma | Context |
|------|-------|---------|
| 1001 | lemma_2_7 | xi ∉ g case, uses xi ∈ B' |
| 1029 | lemma_2_7 | BX5 self-accum, uses B' for g subset |
| 1033 | lemma_2_7 | xi ∉ g case, uses xi ∈ B' |
| 1044 | lemma_2_7 | xi ∉ g case, uses xi ∈ B' |
| 2078 | lemma_2_7 | forward direction, uses B' for g subset |
| 2107-2129 | lemma_2_7 | multiple sub-cases in forward elimination |
| 1581 | lemma_2_7_since | xi ∉ g case (since direction) |
| 1609-1624 | lemma_2_7_since | multiple sub-cases in since elimination |
| 2607-2651 | lemma_2_7_since | backward direction elimination |
