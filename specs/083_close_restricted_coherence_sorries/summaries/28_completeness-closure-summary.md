# Implementation Summary: Close Restricted Coherence Sorries (Plan v28)

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [PARTIAL]
- **Plan**: plans/28_completeness-closure.md
- **Session**: sess_1775525602_0f7cf6

## Phases Completed

### Phase 1: Close Trivial Sorries [COMPLETED]

**Changes made**:
1. **SuccChainFMCS.lean**: Closed 4 annotated T-axiom sorries
   - Line 1267: `sorry /- was: temp_t_future chi -/` → `DerivationTree.axiom [] _ (Axiom.temp_t_future chi)`
   - Line 3804: `sorry /- was: temp_t_past chi -/` → `DerivationTree.axiom [] _ (Axiom.temp_t_past chi)`
   - Line 4071: `sorry /- was: temp_t_future chi -/` → `DerivationTree.axiom [] _ (Axiom.temp_t_future chi)`
   - Line 4214: `sorry /- was: temp_t_future neg_neg_bot -/` → `DerivationTree.axiom [] _ (Axiom.temp_t_future neg_neg_bot)`

2. **RestrictedTruthLemma.lean**: Removed dead code
   - Deleted `restricted_chain_G_propagates` (zero references, sorry, ~35 lines)
   - Deleted `restricted_chain_H_step` (zero references, sorry, ~45 lines)
   - Kept `restricted_chain_G_step` (has external references)

**Not addressed**: `F_until_equiv_valid` / `P_since_equiv_valid` sorries in Soundness.lean (discrete soundness, not on completeness critical path)

### Phase 2: Main Sorries [BLOCKED]

**Critical finding**: The completeness critical path does NOT go through `succ_chain_restricted_forward_F` (UltrafilterChain.lean) as all previous plans assumed. The actual critical path is:

```
completeness_over_Int (Completeness.lean)
  → dovetailed_bundle_validity_implies_provability
    → dovetailed_bfmcs_restricted_temporally_coherent
      → DovetailedFMCS_forward_F (DovetailedChain.lean:1300) ← SORRY
      → DovetailedFMCS_backward_P (DovetailedChain.lean:1308) ← SORRY
```

Confirmed via `#print axioms`:
- `Bimodal.FrameConditions.completeness_over_Int` → depends on `sorryAx` ✓
- `Bimodal.Metalogic.Algebraic.DovetailedChain.DovetailedFMCS_forward_F` → depends on `sorryAx` ✓

**Blocker**: `DovetailedFMCS_forward_F` is blocked by `forward_dovetailed_until_persists` — Until obligations don't persist through Lindenbaum extension steps (X-content vs G-content mismatch).

**Plan updated**: Phase 2 now targets DovetailedChain.lean instead of UltrafilterChain.lean.

### Phase 3: Cleanup [IN PROGRESS]

Dead code removal done (Phase 1 overlap). Remaining items blocked on Phase 2.

## Sorry Impact

| Change | Sorries Before | Sorries After | Net |
|--------|---------------|---------------|-----|
| SuccChainFMCS.lean | 23 | 19 | -4 |
| RestrictedTruthLemma.lean | 7 | 5 | -2 |
| **Total** | **30** | **24** | **-6** |

## Next Steps

1. Deep-read DovetailedChain.lean to understand Until persistence blocker
2. Evaluate approach options for closing `DovetailedFMCS_forward_F`
3. Consider `/research 83` focused on the dovetailed chain's specific blocker
