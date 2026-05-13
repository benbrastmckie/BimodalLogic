# Implementation Summary: Z1 Axiom and Doets Gap Elimination (v15)

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Plan**: plans/12_semantic-z1-gap.md
- **Status**: PARTIAL (Phases 1-2 completed, Phase 3 blocked)
- **Session**: sess_1778638598_997271

## Phases Completed

### Phase 1: Add Imports and Prove Order.succ Equality [COMPLETED]
Previously completed.

### Phase 2: Add Z1 Axiom and Prove Soundness [COMPLETED]
Previously completed. Z1 axiom added, soundness proved, all pattern matches updated, z1_derivation replaced with axiom-based approach, lake build passes.

## Phases Not Completed

### Phase 3: Doets Maximum Principle and Gap Elimination [BLOCKED]

**What was attempted**: Extensive analysis of the `succ_cofinal` sorry (line 1869 of ChronicleToCountermodel.lean) in the gap scenario where the orbit `s^n(a)` converges to L in R and the pred-chain `p^k(pb)` converges from above.

**Approaches evaluated**:

1. **Z1 Doets maximum principle (plan approach)**: Z1 at orbit point with discriminating formula phi gives either G(neg(phi)) (contradiction if phi at all orbit) or F(G(neg(phi)) and phi) giving a "maximum point" y. If y.val < L, orbit_below_L forces y to be orbit, and succ(y) is orbit where phi should hold but G(neg(phi)) gives neg(phi) at succ(y). **Blocking issue**: backward_G needs phi at ALL y > x (including b and points beyond b, which are outside the gap region). FG(neg(phi)) at x similarly needs G(neg(phi)) at some y > x, which needs neg(phi) at ALL w > y. Cannot control formula membership at b and beyond without a discriminating formula that fails everywhere above the gap.

2. **Prior-UZ approach**: Prior-UZ gives U(phi, phi.neg). limit_satisfies_c5_strong gives witness y with phi at y (GOAL) and phi.neg at intermediates (GUARD). When y is the immediate successor, guard is vacuous. No contradiction from Prior-UZ alone.

3. **Stage induction (succ_reaches_dom_N)**: Boundary cases at lines 1295 and 1448 remain sorry'd. Needs succ of dom(N) boundary point to be in dom(N+1), which is not guaranteed.

4. **Direct real analysis**: No contradiction without temporal axioms (Z+Z model is consistent with discrete structure without Z1).

**Root cause**: backward_G quantifies over ALL limit_dom y > x, requiring control of formula membership at b and beyond the gap region. The constant-MCS case is consistent with Z1 and requires a construction-level argument.

## Recommendations

1. **Research needed**: Study Doets 1987 / Reynolds 1994 gap elimination proofs.
2. **Alternative**: Add construction-level lemma about omega_chain boundary behavior.
3. **Plan revision**: Phase 3 needs revision for the "b and beyond" control issue.

## Files Modified

- `ChronicleToCountermodel.lean`: Updated sorry comments at succ_cofinal gap (line 1869). Removed extended incorrect analysis. Comments now document blocking issues.

## Build Status

`lake build` passes.
