# Implementation Summary: Close Restricted Coherence Sorries

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: PARTIAL
- **Phases Completed**: 2 of 5 (Phase 1 complete, Phase 2 complete, Phase 3 blocked, Phase 4 blocked, Phase 5 partial)

## What Was Accomplished

### Phase 1: Dead Code Cleanup (COMPLETED)
- Verified `restricted_chain_G_propagates` and `restricted_chain_H_step` in RestrictedTruthLemma.lean have zero external references (dead code)
- Added `**DEAD CODE**` docstring annotations to both theorems
- Build passes cleanly

### Phase 2: Targeted Chain Construction (COMPLETED)
- Created `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` (new file, 36 definitions/theorems)
- Built sorry-free targeted chain infrastructure:
  - `targeted_forward_successor`: Given F(psi) in MCS M, builds successor with psi resolved and g_content(M) preserved
  - `targeted_backward_predecessor`: Symmetric for P(psi)
  - `targeted_forward_chain` / `targeted_backward_chain`: Nat-indexed chains with round-robin scheduling
  - `targeted_fam`: Combined Int-indexed family
  - `TargetedFMCS`: FMCS structure with sorry-free forward_G and backward_H
- Verified via `lean_verify`: TargetedFMCS uses only standard axioms (propext, Classical.choice, Quot.sound, lean compiler) -- NO sorry

### Phase 3: Fair Scheduling for F/P Resolution (BLOCKED)
The core blocker: proving that F-obligations persist or resolve for ALL deferralClosure formulas simultaneously within a SINGLE chain.

**Root cause analysis**: The targeted chain resolves the scheduled target formula at each step (when F(target) is present), but F-obligations for OTHER formulas may vanish because:
1. `canonical_forward_F` provides g_content persistence but NOT F-step (f_content persistence)
2. The enriched seed approach (adding deferral disjunctions to the seed) fails because deferral disjunctions are not G-liftable, breaking the consistency proof
3. Multi-target seed consistency (`{chi_1, ..., chi_k} ∪ g_content(M)` consistent) is FALSE in general (e.g., F(p) and F(neg(p)) both in M makes {p, neg(p)} ∪ g_content(M) inconsistent)
4. The linearity axiom helps for the F(a ∧ b) case but not the F(a ∧ F(b)) case
5. `F(phi) → G(F(phi))` is NOT provable in TM, so F-obligations don't inherently persist

### Phase 4: Bridge to Completeness Path (BLOCKED)
Blocked by Phase 3. The completeness proof requires `restricted_temporally_coherent`, which needs forward_F for ALL deferralClosure formulas within a SINGLE FMCS family.

### Phase 5: Verification and Cleanup (PARTIAL)
- Build passes: `lake build` succeeds with 938 jobs
- TargetedChain.lean is sorry-free (verified by lean_verify)
- Dead code in RestrictedTruthLemma.lean annotated
- The 2 original sorry theorems (`succ_chain_restricted_forward_F`, `succ_chain_restricted_backward_P`) remain

## Mathematical Analysis

The fundamental difficulty is the **multi-target F-resolution problem**:

Given MCS M with F(chi_1), ..., F(chi_k) in M (for chi_i in deferralClosure), build a successor chain where ALL chi_i eventually appear. This requires either:

1. **Multi-target seed consistency**: `{chi_1, ..., chi_k} ∪ g_content(M)` consistent -- FALSE in general
2. **F-persistence across steps**: when resolving chi_j, all other F(chi_i) persist -- requires enriched seed consistency, which fails because elements from M are not G-liftable
3. **External termination argument**: show that perpetual deferral is impossible -- requires forward_F (circular)

The single-target case IS solved (Phase 2): `{psi} ∪ g_content(M)` consistent when F(psi) in M. But extending to k targets requires solving the multi-target problem.

### Potential Paths Forward

1. **Simultaneous resolution via linearity**: Use the linearity axiom `F(a) ∧ F(b) → F(a ∧ b) ∨ F(a ∧ F(b)) ∨ F(F(a) ∧ b)` to show that for any finite set of F-obligations, there exists a future time where a SUBSET resolves simultaneously. Build a cascading construction that resolves subsets iteratively. Estimated effort: 8-12 hours.

2. **Modified Lindenbaum lemma**: Prove a variant of the Lindenbaum lemma that simultaneously resolves multiple constraints. This would require a careful transfinite construction that interleaves formula resolution with MCS extension. Estimated effort: 12-18 hours.

3. **Semantic compactness argument**: Show that if every finite subset of deferralClosure has a resolving chain, then the full set does too. This is a compactness-style argument but formalized proof-theoretically. Estimated effort: 6-10 hours.

4. **Constrained successor augmentation**: Prove that `constrained_successor_seed(M) ∪ {target}` is consistent when F(target) in M. This is plausible because deferral disjunctions and p_step_blocking formulas in the seed don't interact badly with target, but the formal proof requires a generalization of the G-lifting argument. Estimated effort: 4-8 hours.

## Files Modified
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` -- dead code annotations
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` -- new file (sorry-free)

## Files NOT Modified (sorries remain)
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` still have sorry
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- `completeness_over_Int` still has sorry dependency
