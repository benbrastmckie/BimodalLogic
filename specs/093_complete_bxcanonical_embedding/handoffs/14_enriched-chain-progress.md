# Handoff: Task 93 Implementation Progress (Plan v13, Round 4)

## Session: sess_1776278400_a3b7c1
## Date: 2026-04-14

## Status: PARTIAL (enriched chain infrastructure built, forward_F still open)

### Key Achievements This Session

1. **F-monotonicity lemmas**: `F_mono`, `F_conj_left_mcs`, `F_conj_right_mcs` - proved that F(A and B) implies F(A) and F(B) at MCS level.

2. **BX11 fold theorem** (`enriched_fwd_fold` + `enriched_fwd_exists`): The core mathematical breakthrough. Given F(target) in M and F(chi_i) in M for a list of others, constructs an MCS M' with:
   - g_content(M) subset M'
   - target in M' OR F(target) in M'
   - For each chi_i: chi_i in M' OR F(chi_i) in M'
   The proof uses iterated BX11 + conjunction extraction + F-monotonicity + FF_imp_F. All three BX11 cases are handled: direct resolution (cases 1,2) and F-wrapping with degradation (case 3).

3. **Enriched forward step** (`enriched_fwd_step`): Uses BX11 fold at resolving steps to protect all F-formulas from sigma_list. Proved: MCS property, g_content propagation, F-preservation.

4. **Chain updated**: `rr_fwd_chain` now uses `enriched_fwd_step` instead of `fwd_succ`. All existing proofs (g_content propagation, h_content propagation, box stability, BFMCS modal coherence) still compile.

5. **F-preservation chain lemmas**: `rr_fwd_chain_F_preserved` and `rr_fwd_chain_F_propagate` proved.

### Remaining Sorries (6 in RootScopedChain.lean)

| # | Name | Location | Difficulty |
|---|------|----------|-----------|
| 1 | `rr_fwd_chain_forward_F` | ~line 758 | HARD - see analysis below |
| 2 | `dd_fmcs_forward_F` | ~line 772 | Depends on #1 |
| 3 | `dd_fmcs_backward_P` | ~line 779 | Symmetric to #2 |
| 4 | `dd_bfmcs_restricted_tc` | ~line 833 | Depends on #2, #3 |
| 5 | `dd_bfmcs_restricted_buc` | ~line 839 | Depends on chain structure |
| 6 | `dd_bfmcs_restricted_fuc` | ~line 844 | Depends on chain structure |

### Analysis: Why forward_F Is Hard

The `enriched_fwd_step_preserves` theorem gives: at each step n, if F(psi) in chain(n) and psi in sigma_list, then psi in chain(n+1) OR F(psi) in chain(n+1).

This is NECESSARY but NOT SUFFICIENT for forward_F. The issue:

1. **enriched_fwd_exists gives a disjunction**: target in M' OR F(target) in M'. It does NOT guarantee target in M'.

2. **BX11 fold F-wrapping**: When BX11 case 3 occurs (the new formula's witness is earlier), the target gets F-wrapped. The fold might always F-wrap the target if other formulas always have earlier witnesses.

3. **Defect count does not decrease**: Having chi in M' does NOT remove F(chi) from M' (since chi implies F(chi) by temp_t). So the "defect count" never decreases, invalidating the defect-discharge argument.

4. **Classical Lindenbaum choice**: The Lindenbaum extension is arbitrary among all MCS extending the seed. It might always include F(psi) even when psi is in the compound.

### Proposed Fix: Enriched Step with Guaranteed Target Resolution

The plan's original approach (ordered defect-discharge chain) avoids this by choosing the formula with the EARLIEST witness as the target. By BX11 semantics, the earliest-witness formula always gets case 1 or 2 (not case 3), so it IS resolved (not F-wrapped).

Implementation approach:

1. Define `find_earliest_witness`: Given F(psi_1), ..., F(psi_k) in M, use BX11 pairwise to find one with earliest witness. Result: exists j such that for all i != j, F(psi_j and F(psi_i)) in M or F(psi_j and psi_i) in M (i.e., psi_j's witness is at or before psi_i's).

2. Define `ordered_enriched_step`: At each step, find the earliest-witness formula among current F-defects from sigma. Resolve it (guaranteed by BX11 ordering). Protect the rest.

3. The resolved formula has psi_j in M'. For forward_F: F(psi) persists until psi has the earliest witness. When it does, psi in M'. Since the set of "earlier" formulas can only shrink (by no_new_f_defects for sigma), psi's turn comes eventually.

Actually, even simpler: the `find_earliest_witness` + `enriched_resolving_seed_consistent` from OrderedSeedConsistency.lean already provides the right seed. The seed {psi_j, F(psi_k) | k != j} union g_content(M) is consistent, and psi_j IN M' (not just "or F(psi_j)").

The earlier two_defect_consistent_seed theorem handles the 2-formula case. The generalization to k formulas via iterated BX11 is what find_earliest_witness provides.

### Alternative Fix: Modify enriched_fwd_exists to guarantee target resolution

Change the fold strategy: instead of arbitrary BX11 fold order, always fold with the TARGET as the first argument. Then:
- If target has earliest witness among remaining: cases 1 or 2, target stays resolved
- If some chi has earlier witness: case 3, target gets F-wrapped

In the second case, swap: fold with chi as the new "target to resolve" and original target as "F-protected". Continue until the target accumulates enough BX11 case 1/2 pairings that it stays resolved.

This doesn't work directly because the fold is sequential and case 3 wraps the compound.

### Recommended Next Steps

1. Implement `find_earliest_witness` for a list of F-defects (iterated BX11)
2. Prove that the earliest-witness formula IS resolved (not F-protected) by the BX11 fold
3. Modify enriched_fwd_step to resolve the earliest-witness formula at each step
4. Prove forward_F using the fact that psi eventually has the earliest witness (since the set of formulas with earlier witnesses shrinks)
5. Prove backward_P symmetrically
6. Close restricted coherence properties

### File State

- `OrderedSeedConsistency.lean`: 0 sorry (unchanged)
- `RootScopedChain.lean`: 6 sorry (was 5, added one intermediate sorry)
- `Completeness.lean`: uses dd_countermodel (unchanged)
- `CanonicalModel.lean`: 6 sorry (dead code, unchanged)

### Build Status

`lake build` succeeds. All sorry are in RootScopedChain.lean.
