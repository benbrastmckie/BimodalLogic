# Implementation Summary: Plan v15 Forward-F Resolution

**Task**: 83 - Close Restricted Coherence Sorries
**Plan**: 15_forward-f-resolution.md
**Status**: BLOCKED at Phase 2
**Session**: sess_1743724801_c4d5e6

## What Was Attempted

Phase 1 (Mathematical Analysis) was completed. Phase 2 (Modify Dovetailed Chain) was attempted and found to be blocked by a fundamental mathematical constraint.

## Key Finding: The x_content vs g_content Propagation Gap

The dovetailed chain constructs successors via `temporal_theory_witness_with_g_exists`, which gives a Lindenbaum extension W with `g_content(M) subset W`. Until persistence requires `x_content(M) subset W`, because `until_unfold` produces `X(stuff)` formulas that live in x_content, not g_content.

### Four Approaches Were Analyzed and All Found Blocked

1. **Modify forward_step to use x_content base**: Since `x_content(M)` is already MCS, `x_content(M) union {target}` is consistent only when `target in x_content(M)`. The resolution step becomes vacuous -- the chain reduces to the pure deterministic chain. Forward_F is then unprovable without the truth lemma (circular dependency).

2. **Add Until formulas to Lindenbaum seed**: The consistency proof requires every seed element to be G-liftable (G(x) in M). Until formulas `(top U psi)` are NOT G-liftable: `G(top U psi) in M` is not derivable from `(top U psi) in M`. The G-lift argument produces `G(neg(top U psi))` which equals `G(G(neg(psi)))`. Under strict semantics (no T-axiom for G), this does NOT contradict `(top U psi) in M`.

3. **Use until_induction axiom**: Instantiating `until_induction` with relevant chi values fails because the first premise `G(psi -> top U psi)` is underivable under strict semantics (psi at current time does not give psi at a strictly future time).

4. **Prove F-persistence instead**: `F(psi) = neg(G(neg(psi)))` is not preserved through Lindenbaum extensions because the Lindenbaum process (Zorn's lemma) can freely add `G(neg(psi))`, destroying the F-obligation before the scheduling targets psi for resolution.

### Root Cause

The fundamental issue is a tension between two requirements:
- **Until persistence** needs x_content propagation (X-based unfold formulas in successor)
- **Forward_F resolution** needs g_content-based Lindenbaum extension (to add target formula)

These requirements conflict because:
- x_content elements are NOT G-liftable (only have X(a) in M, not G(a))
- The consistency proof for Lindenbaum seed requires G-liftability
- An MCS cannot be extended (it's already maximal), so x_content(M) union {target} is trivial or inconsistent

## Files Modified

- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean`: Updated sorry comments at `forward_dovetailed_until_persists` (line 590) and `backward_dovetailed_since_persists` (line 966) with detailed analysis of why each approach fails.

## Sorry Count

- DovetailedChain.lean: 6 sorries (unchanged from baseline)
- No new sorries introduced
- No new axioms introduced
- Build passes: yes

## Remaining Sorries on Critical Path

All 6 sorries in DovetailedChain.lean remain:
1. `forward_dovetailed_until_persists` (line 621)
2. `backward_dovetailed_since_persists` (line 989)
3. `until_backward_to_zero` (line 1085)
4. `since_forward_to_zero` (line 1098)
5. `DovetailedFMCS_forward_F` (line 1258)
6. `DovetailedFMCS_backward_P` (line 1266)

Plus the Until/Since cases of `restricted_shifted_truth_lemma` in CanonicalConstruction.lean (lines 940, 943).

## Recommended Next Steps

1. **Algebraic restructure**: The plan's contingency (lines 434-437) suggests a deeper restructure (~40-60h). This could involve building the truth lemma differently, avoiding the need for same-family forward_F.

2. **Fragment completeness**: Prove completeness for the G/H/Box fragment (without Until/Since). The dovetailed chain already has sorry-free forward_G, backward_H, and box_class_agree.

3. **New chain architecture**: Investigate whether a chain construction that INTERLEAVES x_content and g_content steps can provide both Until persistence and F-resolution, with a more sophisticated fair-scheduling argument.
