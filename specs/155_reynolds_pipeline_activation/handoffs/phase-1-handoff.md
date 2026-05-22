# Phase 1 Handoff: D-Consistency / Infimum Redefinition

## Summary

Phase 1 requires a major structural refactoring of ExpressivenessGeneral.lean. The full infimum redefinition (Steps 1-6 from report 27) involves restructuring ~762 lines of Case II proof code that uses `hd_eq_an` at 25+ sites. This is too large for one session. No sorry sites closed, but the code architecture is now thoroughly analyzed.

## Key Finding: Gap Case Also Non-Trivial

Report 27 claimed "gaps are uniquely determined by rank-r formula truth (cut uniqueness)". This is **incomplete**:

- Two gaps with the **same cut** are equal (`gap_ext`, EFGames.lean:275).
- But formula agreement at rank r does NOT directly imply same cut.
- Formula truth A^mu(gap) quantifies over mu-points above/below the gap. Two gaps with different cuts could potentially have the same rank-r formula truth if the differing cut points are rank-r indistinguishable.
- The Round 2 mechanism gives ordering between t and any specific point p (via `hwin_full p hp`), but translating this to "same cut as d" requires showing the ordering is the SAME as d's ordering relative to p — which circles back to needing formula-determines-ordering infrastructure.

**Conclusion**: Both the gap and point cases of d_consistency's interior sorry likely require either the infimum redefinition or rank embedding.

## Architecture of the Refactoring

### Current Architecture
```
obtain_split_point_props:
  d := a_bwd(n)               -- d IS a_bwd(n)
  hd_eq_an : d = a_bwd(n)     -- trivially rfl
  → calls d_consistency_left/right
  → calls ghr93_strategy_restrict_left/right (uses hd_eq_an)
  → IH gives sigma, tau
  → builds SplitPointProps with hd_eq_an

ghr93_case_II (762 lines):
  Uses props.hd_eq_an at 25 sites to rewrite a_bwd(n) to d in game tuples
  Puts c at position n of the M-side response
  d_consistency ensures a'_full(n) = d in strategy restriction
```

### Target Architecture (GHR93-faithful)
```
obtain_split_point_props:
  d := infimum(continuation_set)    -- d is the infimum
  hd_le_an : d ≤ a_bwd(n)          -- infimum ≤ member
  → NO d_consistency needed
  → strategy restriction uses infimum property directly
  → IH gives sigma, tau
  → builds SplitPointProps with hd_le_an (NOT hd_eq_an)

ghr93_case_II (rewritten):
  All a_bwd(i) > d (strictly, from d = infimum < a_bwd(i))
  Uses τ for positions 0..n-1
  Constructs e_n FRESH via U(B,A) formula transfer
  NO hd_eq_an rewrites
  Response at position n is e_n (not c)
```

### Impact Assessment

| Component | Current Lines | Lines Changed | Difficulty |
|-----------|--------------|---------------|------------|
| SplitPointProps | 37 | 5 | Trivial |
| obtain_split_point_props | 260 | 80 | Medium |
| d_consistency_left | 78 | -78 (delete) | Deletion |
| d_consistency_right | 77 | -77 (delete) | Deletion |
| ghr93_strategy_restrict_left | 83 | 50-80 (new argument) | Hard |
| ghr93_strategy_restrict_right | 79 | 50-80 (new argument) | Hard |
| ghr93_case_I | 993 | 20-40 (hd_eq_an → hd_le_an) | Easy |
| ghr93_case_II | 762 | 300-500 (full rewrite) | Very Hard |
| **Total** | | ~400-600 net new | |

### Sequencing Strategy

The refactoring CANNOT be done incrementally because Steps 1-2 break the build immediately. All downstream changes must be made atomically.

**Recommended approach**: Fork the file, make all changes, verify with `lake build`.

Alternatively, use a **compatibility shim**:
1. Keep `hd_eq_an` in SplitPointProps
2. Add `hd_le_an` as a WEAKER alternative
3. Add a `hd_eq_an_or_le` field that provides either = or ≤
4. Gradually migrate Case II to not need equality
5. Once Case II is migrated, remove hd_eq_an

This approach allows incremental progress but adds temporary complexity.

## Continuation Infrastructure

The following infrastructure already exists for the infimum redefinition:

| Component | Location | Status |
|-----------|----------|--------|
| `continuation_set` | line 142 | Complete |
| `continuation_set_nonempty` | line 162 | Complete |
| `continuation_set_upward_closed` | line 174 | Complete |
| `a_n_in_continuation_set` | line 192 | Complete |
| `inf_carrier_cut` | line 153 | Complete |
| `infimum_gap` | line 377 | Complete |
| `infimum_gap_r_definable` | line 904 | Complete |
| `cont_holds_above_gap` | line 424 | Complete |

The infimum machinery is solid. The hard part is restructuring the downstream consumers.

## Recommendation

1. **Short-term**: Mark Phase 1 as BLOCKED pending major refactoring. Focus on Phases 2-4 which have independent sorry sites.
2. **Medium-term**: Implement the full infimum redefinition as a single atomic change (~400-600 lines), using a dedicated multi-hour session.
3. **Fallback**: If the infimum approach hits obstacles in strategy_restrict, use the rank embedding approach (report 27, Section 6, ~440 lines).

## Files Analyzed (Not Modified)
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` (strategy_restrict signatures)
