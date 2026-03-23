# Task 29 Implementation Status - Phase 4-5 Analysis

## Session
- **Session ID**: sess_1774229628_25c345
- **Date**: 2026-03-22

## Summary

Phase 4 key theorem `fresh_Gp_seed_consistent` is PROVEN. The per-witness strictness approach works. However, Phase 5 (call site refactoring) requires deeper architectural changes than initially anticipated.

## Phase 4 Status: PARTIAL

### Proven Theorems
- `fresh_Gp_seed_consistent` - The fresh G-atom seed is consistent
- `fresh_for_g_content_implies_not_always_neg` - Fresh atom implies G(¬q) ∉ M
- `canonicalR_reflexive` - CanonicalR is reflexive under reflexive semantics
- `canonicalR_past_reflexive` - CanonicalR_past is reflexive

### Compiles with Upstream Sorries
- `existsTask_strict_fresh_atom` - Main per-witness strictness theorem

### Remaining Sorries (3)
1. **`exists_fresh_for_g_content`** (line 312): Needs cardinality argument
   - Goal: `∃ q, fresh_for_set q (g_content M)`
   - Issue: Countable union of finite sets can equal countable set
   - Potential fix: Use seed-based reasoning or add hypothesis

2. **`fresh_for_g_content_some_decided_false`** (line 668): Depends on above
   - Goal: `∃ q, fresh_for_set q (g_content M) ∧ ¬q ∈ M`
   - Blocked by: `exists_fresh_for_g_content`

3. **`naming_set_consistent`** (line 512): Legacy, UNUSED
   - Part of old IRR-based proof approach
   - Can be deleted or left with sorry

## Phase 5 Status: BLOCKED

### Issue Discovered

The call sites don't just use `canonicalR_irreflexive` for standalone contradiction. They use it to derive **strictness** from `CanonicalR M N`:

```lean
-- This theorem is FALSE under reflexive semantics when M = N
theorem lt_of_canonicalR (M N : CanonicalMCS) (h : CanonicalR M.world N.world) : M < N
```

Under reflexive semantics:
- `CanonicalR M M` is TRUE (by T-axiom)
- `M < M` is FALSE (irreflexivity of <)
- So `lt_of_canonicalR` is **unsound** when M = N

### Deeper Problem

Even when M ≠ N, mutual accessibility is possible:
- `CanonicalR M N ∧ CanonicalR N M` can both hold
- This gives `M ≤ N ∧ N ≤ M`, so `¬(M < N)` and `¬(N < M)`
- The Preorder on CanonicalMCS is NOT a PartialOrder

### Affected Files (~30 call sites)

| File | Uses | Issue |
|------|------|-------|
| FMCSTransfer.lean | 2 | `lt_of_canonicalR` for transfer witnesses |
| CanonicalSerialFrameInstance.lean | 2 | `canonicalR_strict` for serial witnesses |
| SaturatedChain.lean | 8 | `canonicalR_irreflexive` for chain ordering |
| DovetailedTimelineQuot.lean | 12 | `canonicalR_irreflexive` and `canonicalR_strict` |
| CantorApplication.lean | 4 | `canonicalR_strict` for density witnesses |
| IncrementalTimeline.lean | 1 | `canonicalR_irreflexive` for point equality |
| TimelineQuotCanonical.lean | 1 | `canonicalR_irreflexive` for quotient |
| ClosureSaturation.lean | 2 | `canonicalR_irreflexive` for saturation |
| DiscreteTimeline.lean | 2 | `canonicalR_strict` for discrete successors |

### Options for Resolution

1. **Change Preorder to PartialOrder**: Define equivalence `M ≈ N ↔ CanonicalR M N ∧ CanonicalR N M` and work in quotient
   - Pro: Clean mathematical structure
   - Con: Major refactoring of all Preorder-based code

2. **Weaken TemporalCoherentFamily**: Change forward_F to use `t ≤ s` instead of `t < s`
   - Pro: Aligns with reflexive semantics
   - Con: Breaking change to coherence structure

3. **Add strictness predicates**: Have witness constructions prove `¬CanonicalR W M` explicitly
   - Pro: Minimal change to existing structure
   - Con: Need to audit each witness construction

### Recommended Path Forward

Use **Option 3 with selective fix**:

1. Keep `existsTask_strict_fresh_atom` as the source of per-witness strictness
2. For completeness proofs that need strict witnesses, use fresh-atom-based construction
3. For ordering proofs, consider quotient structure (separate task)
4. Document which call sites need strictness vs which can use non-strict relations

## Key Insight: Fresh G-Atom Strictness

The per-witness strictness theorem works because:

1. Find fresh atom q for g_content(M) with `¬q ∈ M`
2. Build seed `g_content(M) ∪ {G(q)}`
3. Extend to MCS W via Lindenbaum
4. `G(q) ∈ W` implies `q ∈ g_content(W)`
5. Since `q ∉ M`, we have `g_content(W) ⊄ M`
6. Therefore `¬CanonicalR W M` (strictness!)

This provides strictness for SPECIFIC witnesses, not for all CanonicalR relations.

## Files Modified This Session

- `specs/029_switch_to_reflexive_gh_semantics/plans/05_irr-removal-approach.md` - Updated Phase 4 and 5 status

## Recommendations

### Immediate (This Task)
1. Mark Phase 4 as PARTIAL with documented sorries
2. Mark Phase 5 as BLOCKED pending architectural decision
3. Create follow-up task for Phase 5 resolution

### Future Work
1. **Task A**: Resolve freshness existence (cardinality argument or seed-based)
2. **Task B**: Decide on order structure (Preorder vs PartialOrder quotient)
3. **Task C**: Refactor call sites based on decision from Task B
4. **Task D**: Delete `canonicalR_irreflexive_axiom` after call sites fixed
5. **Task E**: Update documentation for reflexive semantics

## Build Status

```
Build completed successfully (1044 jobs).
```

Sorries in CanonicalIrreflexivity.lean: 4 (3 substantive + 1 in comments)
