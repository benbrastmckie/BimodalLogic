# Handoff: Boundary Case Analysis

## Session: sess_1774305257_ac078f
## Date: 2026-03-23

## Current State

### Build Status: BROKEN

The file `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` does not compile. Multiple errors exist:

1. **Unknown identifiers**: `Bimodal.Theorems.future_necessitation`, `Bimodal.Theorems.future_k_dist`, `Bimodal.ProofSystem.DerivationTree.neg_elim`
2. **Type mismatches**: Several `rfl` statements fail due to definitional inequalities
3. **Simp failures**: `simp` tactics that made no progress
4. **Unknown constant**: `Nat.eq_or_gt_of_le`

This broken state existed BEFORE this session started (commit 09f95c952 claims "Build passes" but it doesn't).

### Root Cause

The codebase has evolved and the referenced lemmas/constants no longer exist or have different names. The v6 implementation appears to have been done against a different version of the codebase.

## Analysis of the Boundary Case

### Problem Statement

In `restricted_succ_propagates_F_not` and `restricted_single_step_forcing`, there are sorries for the case where:
- `F(psi) in deferralClosure(phi)` (boundary)
- `FF(psi) not in deferralClosure(phi)` (outside closure)

### Key Findings

1. **G-content path issue**: The theorem `restricted_succ_propagates_F_not` as stated can be FALSE when `GF(psi) in chain(k)`. In this case:
   - `F(psi) in g_content(chain(k)) subset chain(k+1)`
   - So `F(psi) in chain(k+1)`, contradicting the goal

2. **Theorem needs strengthening**: To make the theorem provable, need additional hypothesis `GF(psi) not in chain(k)` or restructure the proof.

3. **MCS extension ambiguity**: Without `GG(neg(psi))` in the seed, the Lindenbaum extension can choose either `F(psi)` or `G(neg(psi))`, and we cannot control this choice.

4. **f_content blocking is insufficient**: Knowing `F(psi) not in f_content(chain(k+1))` (because `FF(psi) not in dc`) does NOT imply `F(psi) not in chain(k+1)`.

### Proposed Solutions

1. **Add hypothesis**: Strengthen `restricted_succ_propagates_F_not` with `GF(psi) not in chain(k)`

2. **Lexicographic induction**: In `bounded_witness`, use induction on `(d, g_depth)` where `g_depth` tracks remaining G-content paths

3. **Structural lemma**: Prove `GF(psi) not in dc` when `FF(psi) not in dc` (if true)

## Files Modified

- `specs/048_prove_succ_chain_fam_bounded_f_depth/plans/07_boundary-resolution.md` - Phase markers updated

## Required Next Steps

1. **Fix build errors**: The file needs to be updated to use current API
   - Find or create `future_necessitation`, `future_k_dist`, `neg_elim`
   - Fix type mismatches for negation/modal formulas
   - Replace deprecated `Nat.eq_or_gt_of_le`

2. **After build fixes**: Implement one of the proposed solutions for the boundary case

3. **Testing**: Once sorries are removed, run full `lake build` to verify

## Context Files

- Main file: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- Plan: `specs/048_prove_succ_chain_fam_bounded_f_depth/plans/07_boundary-resolution.md`
- Research: `specs/048_prove_succ_chain_fam_bounded_f_depth/reports/09_boundary-case.md`
