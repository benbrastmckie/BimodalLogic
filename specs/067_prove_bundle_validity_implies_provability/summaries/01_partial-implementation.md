# Implementation Summary: Task #67 (Partial)

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Plan**: plans/09_fix-backward-chain.md (v9)
- **Status**: PARTIAL
- **Date**: 2026-03-29

## Completed Work

### Phase 1: g_persistence_reverse [COMPLETED - Prior Session]
The `constrained_predecessor_restricted_g_persistence_reverse` theorem was proven in a prior session, establishing that G(chi) in the predecessor implies chi in u.

### Phase 2: f_step_forward [COMPLETED]

**Problem**: The `constrained_predecessor_restricted_f_step_forward` theorem had a sorry in the case where chi not in u AND F(chi) not in u, but F(chi) appears in the predecessor v.

**Solution**: Added a new seed component `f_step_blocking_alt_restricted` that handles this exact case:

```lean
def f_step_blocking_alt_restricted (phi : Formula) (u : Set Formula) : Set Formula :=
  { psi | exists chi : Formula,
    chi not in u AND
    Formula.some_future chi not in u AND
    Formula.some_future chi in (Bimodal.Syntax.deferralClosure phi : Set Formula) AND
    psi = Formula.all_future (Formula.neg chi) }
```

**Key Insight**: When chi not in u and F(chi) not in u, by maximality of u within deferralClosure, G(neg chi) = neg F(chi) must be in u. The new component adds G(neg chi) to the seed, which propagates to the predecessor v via Lindenbaum extension. Since F(chi) = neg G(neg chi), having both F(chi) and G(neg chi) in v contradicts consistency.

**Files Modified**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
  - Added `f_step_blocking_alt_restricted` definition (lines 3375-3380)
  - Added `f_step_blocking_alt_subset_deferralClosure` theorem
  - Added `f_step_blocking_alt_subset_u` theorem
  - Updated `constrained_predecessor_seed_restricted` to include new component
  - Updated `mem_constrained_predecessor_seed_restricted_iff`
  - Added `f_step_blocking_alt_subset_constrained_predecessor_seed_restricted`
  - Updated `constrained_predecessor_seed_restricted_subset_deferralClosure` for new case
  - Updated `constrained_predecessor_seed_restricted_consistent` for new case
  - Replaced sorry in `constrained_predecessor_restricted_f_step_forward` with actual proof

**Result**: `constrained_predecessor_restricted_succ` now compiles without sorries in its core path.

## Blocked Work

### Phase 3: Fuel-Exhaustion Sorries [BLOCKED]

**Problem**: Four fuel-exhaustion sorries remain at lines 2913, 5527, 5685, 5881. These occur in fuel=0 base cases of recursive bounded witness lemmas.

**Analysis**: These cases are semantically unreachable because:
1. Initial fuel = B*B+1 where B = closure_F_bound phi
2. Each recursive call decreases fuel by 1
3. The maximum required depth is B*B

However, proving unreachability requires:
1. Restructuring to well-founded recursion on a complex measure
2. The recursion moves through positions (k) and depths (d) non-monotonically
3. Threading fuel-sufficiency invariants through 4+ recursive functions

**Decision**: Marked as BLOCKED. The plan's contingency notes: "The sorry is in a semantically unreachable branch, so it doesn't affect correctness of the main path."

### Phase 4: Wire to Completeness [NOT STARTED]

Cannot proceed until Phase 3 eliminates fuel sorries from `build_restricted_tc_family`.

## Verification

```bash
lake build  # Passes (938 jobs)
```

**Remaining sorries in SuccChainFMCS.lean**:
- Line 1659: `g_content_union_brs_consistent` (deprecated path)
- Line 1688: `augmented_seed_consistent` (deprecated path)
- Line 2005: `constrained_successor_seed_restricted_consistent` multi-BRS case (deprecated)
- Lines 2913, 2915, 5527, 5685, 5881: Fuel-exhaustion base cases (Phase 3 target)

## Technical Details

### Seed Structure Change

The predecessor seed now has 6 components:
```
constrained_predecessor_seed_restricted phi u =
  h_content u UNION
  pastDeferralDisjunctions u UNION
  f_step_blocking_formulas_restricted phi u UNION
  f_step_blocking_alt_restricted phi u UNION        -- NEW
  g_step_blocking_formulas_restricted phi u UNION
  seriality_g_blocking
```

### Consistency Proof Update

The consistency proof for the extended seed shows that `f_step_blocking_alt_restricted` is a subset of u:
- When chi not in u and F(chi) not in u and F(chi) in deferralClosure
- By maximality: inserting G(neg chi) is inconsistent iff it's not already in u
- Derive contradiction: if G(neg chi) not in u, then both G(neg chi) and F(chi) are derivable from appropriate subsets of u, leading to contradiction

## Next Steps

1. **Phase 3**: Consider restructuring bounded witness lemmas to use well-founded recursion on a Lex measure `(B*B - visited_positions, d)` or proving fuel-sufficiency invariants
2. **Phase 4**: Once Phase 3 complete, wire `build_restricted_tc_family` to `bfmcs_from_mcs_temporally_coherent` in Completeness.lean

## Session Information

- **Session ID**: sess_1774826310_4c40e6
- **Agent**: lean-implementation-agent
