# Implementation Summary: Task 86 -- Close BXCanonical Sorries via BX10 + Chain-Specific Eventuality

**Task**: 86 -- Close BXCanonical completeness sorries
**Session**: sess_1775760751_a5c0e8
**Plan**: plans/08_chain-eventuality-plan.md
**Status**: PARTIAL (Phase 1 completed, Phase 2 NO-GO, Phases 3-4 blocked)

## Changes Made

### Phase 1: Close WitnessSeed.lean Sorries via BX10/BX10' [COMPLETED]

Replaced 2 sorry'd until_induction-based proofs with direct BX10/BX10' contradiction arguments in `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean`.

**until_witness_seed_consistent**: The old proof constructed a complex until_induction argument through 7 steps (X(bot) construction, G-wrapped conjunction, until_induction axiom application, bot_until_bot_absurd). The sorry was at the until_induction axiom call, which was removed in the BX refactoring. The new proof is 6 lines: derive F(psi) from phi U psi via BX10 (until_imp_F), note F(psi) = neg(G(neg psi)) definitionally, contradict G(neg psi) in M via set_consistent_not_both.

**since_witness_seed_consistent**: Mirror replacement using BX10' (since_imp_P) and P(psi) = neg(H(neg psi)).

This makes `canonical_forward_U` and `canonical_backward_S` in CanonicalFrame.lean sorry-free as well (they depended solely on the seed consistency theorems).

### Phase 2: Design Chain-Specific Eventuality Resolution API [COMPLETED - NO-GO]

Thorough analysis of the chain-specific approach for Frame.lean's 4 eventuality resolution sorries. Key findings:

1. **DovetailedChain.lean is DEPRECATED** with 6 sorries from the same X-vs-G mismatch
2. **Global bx_le linearity is FALSE** (proven in research report 08)
3. **Both forward AND backward eventuality resolution are blocked** by the g_content vs Until-witness mismatch
4. **Chain-specific approach requires 20+ hours** of new infrastructure, far exceeding budget
5. **TruthLemma.lean's until_iff_mcs / since_iff_mcs are not used downstream**, so restructuring is safe but not currently needed

### Phases 3-4: BLOCKED / PARTIAL

Phase 3 blocked by Phase 2 NO-GO. Phase 4 partially completed (sorry audit, documentation updates).

## Sorry Audit

| File | Before | After | Delta |
|------|--------|-------|-------|
| WitnessSeed.lean | 2 | 0 | -2 |
| Frame.lean | 4 | 4 | 0 |
| CanonicalEmbedding.lean | 1 | 1 | 0 |
| Completeness.lean | 1 | 1 | 0 |
| **Total BXCanonical/** | **8** | **6** | **-2** |

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` -- 2 sorries closed (BX10/BX10' contradiction)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- updated docstring with Phase 2 analysis
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- updated comments with task 86 progress

## Verification

- `lake build` passes with zero errors (945 jobs)
- No new sorries or axioms introduced
- No regressions in existing sorry-free proofs

## Remaining Work

The 6 remaining sorries in BXCanonical require one of:
1. Re-adding temp_linearity axiom to the BX system (philosophically undesirable)
2. Proving F(phi) <-> top U phi from BX axioms (likely impossible without additional axioms)
3. A fundamentally new completeness technique (e.g., quasimodel/filtration approach that avoids canonical model ordering issues)
