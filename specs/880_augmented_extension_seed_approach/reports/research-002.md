# Research Report: Task #880 (Wave 2)

**Task**: 880 - Investigate augmented extension seed approach (CONTINUATION)
**Date**: 2026-02-12
**Mode**: Team Research (2 teammates)
**Session**: sess_1770923218_d57f7a
**Focus**: Identify the best path towards mathematically elegant, sorry-free proofs

## Summary

Wave 2 research identifies a **clear implementation path** to eliminate 9 of 12 sorry sites in ZornFamily.lean with **HIGH confidence** (Steps 0-3). The remaining 3 sorries require controlled Lindenbaum extension, which carries **HIGH risk** but is mathematically valid. Key insight: the `forward_F` and `backward_P` structural fields are **fundamentally broken** - they assert universal propagation for existential operators, making domain extension impossible for many families. The recommended approach is to remove these fields entirely, simplify the seed, and prove F/P as a derived property for total families.

## Key Findings

### 1. Sorry Site Classification

| Category | Count | Lines | Approach |
|----------|-------|-------|----------|
| **IMPOSSIBLE** | 3 | 844, 874, 1120+1260 | Delete/remove (false lemmas) |
| **HARD** | 3 | 888*, 1786, 1928 | *888 becomes EASY after Step 2 |
| **MEDIUM** | 4 | 1764, 1968, 2091, 2161+2168 | Structural changes |

*After removing F/P obligations from the seed (Step 2), the cross-sign case at line 888 becomes straightforward.

### 2. The Core Architectural Flaw

The `forward_F` and `backward_P` fields in `GHCoherentPartialFamily` are **mathematically unsatisfiable**:

```
forward_F : forall s t, s in domain -> t in domain -> s < t ->
    forall phi, F(phi) in mcs(s) -> phi in mcs(t)
```

**Counterexample**: If `mcs(0)` contains both `F(p)` and `F(neg p)` (which is consistent in temporal logic), then `forward_F` requires both `p` and `neg p` in `mcs(1)`, contradicting consistency.

**Consequence**: Zorn cannot produce a total family because extension from `{0}` to `{0,1}` is impossible whenever the base MCS contains conflicting existential obligations.

### 3. Recommended Approach: Remove forward_F/backward_P

**The minimum viable change** is to remove `forward_F` and `backward_P` from the structure entirely, returning to G/H-only coherence. This:
- Eliminates 6 sorries directly (the 4 extension F/P sorries + 2 false multi-witness lemmas)
- Makes the seed (GContent + HContent only) trivially consistent for all cases
- Requires proving F/P as a derived property for total families

### 4. Cross-Sign Case is SOLVABLE

After removing F/P obligations from the seed, the cross-sign case becomes straightforward:

1. All GContent elements propagate to `GContent(mcs(s_max))` via `GContent_propagates_forward`
2. GContent further propagates to `mcs(s_min)` (since `s_max < s_min`, both in domain)
3. All HContent elements are in `HContent(mcs(s_min))` via `HContent_propagates_backward`
4. Everything lands in `mcs(s_min)` via T-axiom, which is consistent

This eliminates all 3 seed consistency sorries (lines 888, 1120, 1260).

### 5. non_total_has_boundary is FALSE

**Counterexample**: Domain = all even integers. For any odd `t`, there exist even numbers both above and below `t`, so no boundary exists. Yet the domain is not all of `Int`.

**Implication**: The boundary-only extension strategy cannot yield totality. General extension for ANY missing time is needed, requiring controlled Lindenbaum to prevent G/H conflicts with existing MCSs.

### 6. DovetailingChain as Fallback

If the Zorn approach fails on Steps 4-6:
- DovetailingChain has 4 sorry sites, **none IMPOSSIBLE**
- Cross-sign G/H propagation (2 sorries) requires the same infrastructure as ZornFamily
- F/P witness construction (2 sorries) requires dovetailing enumeration
- Total estimated effort comparable to controlled Lindenbaum

## Implementation Plan (21-31 hours)

### Phase 1: Quick Wins (Steps 0-3, ~9 hours, 9/12 sorries)

| Step | Description | Effort | Risk | Sorries |
|------|-------------|--------|------|---------|
| 0 | Delete false lemmas (`multi_witness_seed_consistent_*`) | 0.5h | LOW | S1, S2 |
| 1 | Remove `forward_F`/`backward_P` from structure | 4-6h | MEDIUM | S6, S7, S8, S9 |
| 2 | Simplify `extensionSeed` to GContent + HContent only | 1-2h | LOW | (prepares S3-S5) |
| 3 | Prove `extensionSeed_consistent` for all cases | 3-5h | LOW-MEDIUM | S3, S4, S5 |

**Confidence: HIGH (90%)** - Clear mathematical strategy, well-understood infrastructure.

### Phase 2: Hard Cases (Steps 4-6, ~12-18 hours, remaining 3/12 sorries)

| Step | Description | Effort | Risk | Sorries |
|------|-------------|--------|------|---------|
| 4 | Handle general (non-boundary) extension | 6-10h | HIGH | S10 |
| 5 | G/H from-new-to-old via controlled Lindenbaum | 10-15h | VERY HIGH | S11, S12 |

**Alternative**: Combine Steps 4+5 into Step 6 (general extension with controlled Lindenbaum): 12-18h.

**Confidence: MEDIUM (55%)** - Novel technique, no existing infrastructure.

### Dependency Graph

```
Step 0 ──────────────────────────────┐
   (independent)                      │
                                      │
Step 1 (remove F/P fields)            │
   │                                  │
   ├─→ Step 2 (simplify seed)         │
   │      │                           │
   │      └─→ Step 3 (seed consistent)│
   │                                  │
   └─→ Step 4+5 or Step 6             │
         (controlled Lindenbaum)      │
              │                       │
              └───────────────────────┴─→ [ALL SORRIES ELIMINATED]
```

## Synthesis

### Conflicts Resolved

| Issue | Teammate A | Teammate B | Resolution |
|-------|-----------|-----------|------------|
| Cross-sign difficulty | HARD | EASY after Step 2 | **EASY** - removing F/P obligations from seed makes it trivial |
| PObligations in cross-sign | Solvable | Identified s_min edge case | **Resolved** - PObligations removed entirely in Step 2 |

### Gaps Identified

1. **Controlled Lindenbaum formalization** - No existing infrastructure in codebase
2. **F/P recovery for total families** - Must be proven post-Zorn as derived property
3. **General extension vs boundary-only** - Architectural restructuring needed

### Confidence Assessment

| Outcome | Probability |
|---------|-------------|
| Steps 0-3 succeed (9/12 sorries) | 90% |
| Steps 4-6 succeed (remaining 3/12) | 55% |
| Full sorry-free ZornFamily.lean | 50% |
| Fallback to DovetailingChain works | 70% |

## Recommendations

### Primary Path (ZornFamily)

1. **Immediate (TODAY)**: Execute Steps 0-1
   - Delete false lemmas
   - Remove `forward_F`/`backward_P` from structure
   - This unblocks all further progress

2. **Short-term (2-3 days)**: Execute Steps 2-3
   - Simplify seed definition
   - Prove seed consistency for all cases
   - **Milestone: 9/12 sorries eliminated**

3. **Medium-term (1 week)**: Attempt Steps 4-6
   - Develop controlled Lindenbaum
   - If blocked, pivot to DovetailingChain

### Fallback Path (DovetailingChain)

If controlled Lindenbaum proves intractable:
1. Transfer cross-sign infrastructure (same mathematical argument)
2. Build dovetailing enumeration for F/P witness placement
3. Accept longer implementation timeline

### Strategic Decision

The choice between continuing with ZornFamily vs pivoting to DovetailingChain should be made **after Steps 0-3 complete**. At that point:
- 9/12 sorries eliminated
- Clear picture of controlled Lindenbaum feasibility
- Better estimate of remaining effort

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Optimal approach analysis, sorry classification | completed | MEDIUM-HIGH |
| B | Concrete implementation path, detailed proof strategy | completed | MEDIUM |

## Evidence (Verified via lean_local_search)

### Proven Infrastructure Available
- `temporal_witness_seed_consistent` - single F-witness consistent
- `temporal_witness_seed_consistent_past` - single P-witness consistent
- `GContent_consistent`, `HContent_consistent` - G/H content consistent
- `GContent_propagates_forward`, `HContent_propagates_backward` - 4-axiom propagation
- `set_mcs_all_future_all_future`, `set_mcs_all_past_all_past` - modal iteration
- `generalized_temporal_k`, `generalized_past_k` - necessitation rules
- `set_lindenbaum`, `zorn_le_nonempty_0` - Lindenbaum extension, Zorn's lemma

### False Lemmas (must delete)
- `multi_witness_seed_consistent_future` (line 806-844)
- `multi_witness_seed_consistent_past` (line 849-874)

## Next Steps

1. **Create implementation plan v005** based on this research
2. **Execute Step 0** immediately (delete false lemmas)
3. **Execute Step 1** (remove `forward_F`/`backward_P` - this is the critical structural change)
4. **Evaluate progress** after Steps 0-3 complete before committing to Steps 4-6 vs DovetailingChain pivot
