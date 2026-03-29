# Phase 1 Partial Summary: Dovetailed Chain Infrastructure

**Task**: 67 - prove_bundle_validity_implies_provability
**Phase**: 1 (Define Dovetailed Forward Chain)
**Status**: PARTIAL
**Session**: sess_1774812379_c05130
**Date**: 2026-03-29

## Work Completed

### Infrastructure Added to UltrafilterChain.lean

1. **F_unresolved predicate** (line ~3702)
   - `F_unresolved chain n phi`: F(phi) in chain(n) but phi not in chain(n)
   - Used to identify obligations needing resolution

2. **has_unresolved_F predicate** (line ~3708)
   - `has_unresolved_F chain n`: exists some unresolved F-formula at time n
   - Existential wrapper over F_unresolved

3. **select_unresolved_F function** (line ~3715)
   - Uses Classical.choose with propDecidable for the existence check
   - Returns an unresolved F-formula if one exists, otherwise F_top
   - Theorem `select_unresolved_F_spec` proves F(result) is in chain

4. **resolution_target_time function** (line ~3750)
   - Uses Nat.unpair to decode (time, index) from step number
   - When unpair(n) = (t, 0) and t <= n, targets time t for resolution
   - Otherwise targets current time n

5. **omega_chain_true_dovetailed_forward_with_inv** (line ~3772)
   - Chain construction skeleton with OmegaForwardInvariant tracking
   - Currently uses F_top at each step (placeholder)
   - Properties proven: MCS at each point, box_class_agree, G_theory propagation

### Key Mathematical Insight Identified

The fundamental insight for completing Phase 1:

1. **Formulas are Countable**: `Formula` derives `Countable` (Formula.lean:79)
2. **Formulas are Infinite**: There are infinitely many atoms
3. **Therefore Denumerable**: By `nonempty_denumerable`, we can get `Denumerable Formula`
4. **Enumeration**: `Denumerable.ofNat : Nat -> Formula` enumerates all formulas

This enables the dovetailing strategy:
- At step n, decode (t, k) = Nat.unpair n
- Let psi = Denumerable.ofNat k (the k-th formula in enumeration)
- If F(psi) in chain(t) is unresolved, resolve it
- By unpair surjectivity, every (t, encode(phi)) is eventually hit

## Remaining Work for Phase 1

1. **Add Denumerable instance for Formula**
   ```lean
   noncomputable instance : Denumerable Formula :=
     Classical.choice nonempty_denumerable
   ```

2. **Implement TRUE dovetailing**
   - At step n+1, decode (t, k) = Nat.unpair n
   - Get psi = Denumerable.ofNat k
   - Check if F(psi) in chain(min(t, n)) is unresolved
   - If yes, use resolving_witness for psi
   - If no, use F_top

3. **Prove F-propagation lemma**
   - F(phi) in chain(n) implies F(phi) in chain(n+1) OR phi in chain(n+1)
   - This follows from MCS negation completeness and G-theory preservation

## Build Status

- `lake build` succeeds (938 jobs)
- No new sorries introduced in infrastructure code
- Existing sorries unchanged (29 in UltrafilterChain.lean)

## Files Modified

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines 3668-3830)
- `specs/067_prove_bundle_validity_implies_provability/plans/08_dovetailed-omega-fmcs.md`

## Blocking Issues

None - the path forward is clear. The remaining work is to:
1. Wire in the Denumerable instance
2. Use formula index from unpair for F-formula selection
3. Prove the fairness lemma using unpair surjectivity

## Estimated Remaining Effort

- Phase 1 completion: 1-2 hours
- Phase 2 (chain properties): 2-3 hours
- Phase 3 (fairness lemma): 2-3 hours
- Phase 4 (backward chain): 2-3 hours
- Phase 5 (Z_chain wiring): 1-2 hours
- Phase 6 (completeness): 1-2 hours

Total remaining: ~10-15 hours
