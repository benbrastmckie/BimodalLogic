# Research Report: Task #48 — Mathematical Root Cause and Correct Path Forward

**Task**: 48 — prove_succ_chain_fam_bounded_f_depth
**Date**: 2026-03-23
**Mode**: Team Research (2 teammates)
**Session**: sess_1774317485_ed8944

## Summary

After 11 plan versions and 21 prior research artifacts, both teammates independently reached the same conclusion: **the Lindenbaum Succ-lifting approach (Plan v11) is UNPROVABLE**, but the actual fix is surprisingly small. The core blocker reduces to a single missing lemma: DRM negation completeness for formulas whose negation is also in `deferralClosure`.

## Key Discovery: Lindenbaum Succ Lifting is Fatal

**Both teammates independently confirmed**: `Succ(extendToMCS(chain(k)), extendToMCS(chain(k+1)))` is NOT provable.

**Root cause**: The two `extendToMCS` calls are independent Zorn's lemma / `Classical.choose` applications. `extendToMCS(chain(k))` can freely add `G(chi)` formulas that have no connection to `extendToMCS(chain(k+1))`. The g_content property cannot be transferred across independently-chosen extensions.

**Verdict**: Plan v11 Phase 1 is a dead end. Do NOT pursue Succ lifting.

**What IS proven and useful**: `extendToMCS_transfer_back` (line 4249) — this theorem is solid and may be useful in the future, but the Succ lifting it requires is not achievable.

## The Actual Fix: DRM Negation Completeness + Modal Duality

### Sorry Triage (10 sorries, only 2 on critical path)

| Priority | Lines | Location | Fix |
|----------|-------|----------|-----|
| **CRITICAL** | 2360, 3012 | `restricted_single_step_forcing` / `restricted_succ_propagates_F_not` (FF ∈ dc case) | DRM negation completeness + modal duality |
| **BOUNDARY** | 2980, 3026 | Same theorems (FF ∉ dc case) | False as stated; handled by `restricted_bounded_witness` induction |
| **DEAD CODE** | 3097, 3675, 3903, 3915 | `restricted_succ_propagates_F_not'` (primed) | NOT on critical path — can be deprecated |
| **DEPRECATED** | 736, 971 | `f_nesting_is_bounded`, `p_nesting_is_bounded` | Already marked deprecated |

### Critical Path Analysis (Teammate A)

The proof dependency chain:
```
restricted_bounded_witness (line 3967)
  └── calls restricted_succ_propagates_F_not (line 4010)
        └── sorry at line 3012 (FF ∈ dc, modal duality gap)
```

The primed theorems (`restricted_succ_propagates_F_not'`) are used by `restricted_single_step_forcing'` — but this is an **aborted attempt** not on the critical path. The code explicitly marks these as FALSE (lines 3786, 3896).

### The Fix (Both Teammates Agree)

**Step 1**: Prove DRM negation completeness within dc:
```lean
lemma drm_negation_complete_within_dc (phi psi : Formula)
    (u : DeferralRestrictedMCS phi)
    (h_in_dc : psi ∈ deferralClosure phi)
    (h_neg_in_dc : psi.neg ∈ deferralClosure phi)
    (h_not_in_u : psi ∉ u.world) :
    psi.neg ∈ u.world
```

**Why this is provable** (Teammate B): DRM maximality states `∀ psi ∈ dc, psi ∉ S → ¬SetConsistent(insert psi S)`. If both `psi ∈ dc` and `psi.neg ∈ dc`, and `psi ∉ u`, then `insert psi u` is inconsistent. Since `psi.neg ∈ dc` and the DRM is maximally consistent within dc, either `psi.neg ∈ u` (done) or `insert (psi.neg) u` is also inconsistent — but both `insert psi u` and `insert (psi.neg) u` inconsistent implies `u` itself derives both `neg psi` and `neg (neg psi)`, contradicting consistency. So `psi.neg ∈ u`.

**Prerequisite**: `neg(FF(psi)) ∈ deferralClosure` when `FF(psi) ∈ deferralClosure`. This holds because `deferralClosure` contains `closureWithNeg`, which is closed under negation by construction.

**Step 2**: Apply existing `neg_FF_implies_GG_neg_in_mcs` (SuccRelation.lean:142):
Once `neg(FF(psi)) ∈ u`, modal duality gives `GG(psi.neg) ∈ u`, and the rest follows as in the unrestricted case.

**Teammate A's insight**: The modal duality `neg(FF(psi)) → GG(psi.neg)` is NOT definitional equality (since `some_future psi = psi.neg.all_future.neg`), but follows via DNE in any MCS context. The existing `neg_FF_implies_GG_neg_in_mcs` already handles this.

### Boundary Case (Lines 2980, 3026): FF ∉ dc

Both teammates agree this case is **false as stated** for `restricted_single_step_forcing` — when `FF(psi) ∉ dc`, F(psi) can be deferred to the successor without resolving. However:

- **Teammate A**: This is handled by the induction in `restricted_bounded_witness` (the calling code at lines 4007-4015 already handles `F(iter_F d' psi) ∉ dc` trivially)
- **Teammate B**: The `restricted_forward_chain_F_bounded` (line 2267) provides the needed bound

**Action**: These sorries should either be marked as unreachable from the calling context, or the theorem signatures should be strengthened to exclude this sub-case.

## Conflicts Resolved

### Conflict 1: Best Approach
- **Teammate A**: Modal duality lemma (Option D) — fix the derivation gap
- **Teammate B**: DRM negation completeness — fill the sorry directly

**Resolution**: These are COMPLEMENTARY, not conflicting. The fix requires BOTH:
1. DRM negation completeness gives `neg(FF(psi)) ∈ u`
2. Modal duality (via existing `neg_FF_implies_GG_neg_in_mcs`) converts to `GG(psi.neg) ∈ u`

### Conflict 2: Are primed theorems load-bearing?
- **Teammate A**: NOT on critical path — `restricted_bounded_witness` uses non-primed only
- **Teammate B**: Didn't analyze primed vs non-primed distinction deeply

**Resolution**: Teammate A's analysis is correct. The primed theorems are dead code from an aborted attempt.

## Gaps Identified

1. **Verify `neg(FF(psi)) ∈ deferralClosure`**: Need to confirm `closureWithNeg` is closed under negation. Check definition in RestrictedMCS.lean.

2. **Verify DRM maximality gives `psi.neg ∈ u`**: The argument requires that `insert psi u` inconsistent + `psi.neg ∈ dc` → `psi.neg ∈ u`. Need to check if the DRM construction (constrained Lindenbaum) guarantees this.

3. **Handle the `FF ∉ dc` boundary**: Either prove the calling context never reaches this branch, or restructure theorem signatures.

## Recommendations (Prioritized)

1. **IMMEDIATE**: Search RestrictedMCS.lean for existing DRM negation completeness lemma
2. **IMMEDIATE**: Verify `closureWithNeg` is closed under negation (check definition)
3. **PROVE**: `drm_negation_complete_within_dc` if not already present
4. **PROVE**: Apply to fix sorries at lines 2360 and 3012
5. **DEPRECATE**: Remove or mark primed theorems (lines 3097, 3675, 3903, 3915)
6. **HANDLE**: Lines 2980, 3026 — mark as unreachable or restructure signatures

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Root cause + dependency analysis | completed | HIGH (root cause), HIGH (primed not load-bearing) |
| B | Solution evaluation + infrastructure review | completed | HIGH (Succ lifting fatal), HIGH (DRM neg-completeness path) |

## Key Takeaway

**Stop pursuing Lindenbaum Succ lifting.** The fix is much simpler: prove one lemma (DRM negation completeness within dc), which enables the existing `neg_FF_implies_GG_neg_in_mcs` to close the critical sorries. The primed theorems are dead code. The boundary cases (FF ∉ dc) are handled by the calling code's induction structure.

## References

- Teammate A findings: specs/048_prove_succ_chain_fam_bounded_f_depth/reports/22_teammate-a-findings.md
- Teammate B findings: specs/048_prove_succ_chain_fam_bounded_f_depth/reports/22_teammate-b-findings.md
- Prior synthesis: reports/19_team-research.md
- Current plan (v11, now superseded): plans/11_lindenbaum-extension.md
- Working bounded_witness: CanonicalTaskRelation.lean:651
- Modal duality: SuccRelation.lean:142-208
- Transfer back (proven): SuccChainFMCS.lean:4249
