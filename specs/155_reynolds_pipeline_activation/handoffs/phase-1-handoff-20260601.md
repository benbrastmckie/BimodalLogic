# Phase 1 Handoff: Task 155

**Date**: 2026-06-01
**Session**: sess_1748820600_orch155
**Status**: BLOCKED

## Summary

Phase 1 of the implementation plan is blocked because the plan's core mathematical
step -- deriving IsSuccArchimedean from one_class -- is incorrect.

## Analysis Performed

1. **Traced the sorry chain**: completeness_discrete -> countermodel_discrete_enriched ->
   cantor_bfmcs_discrete_restricted_tc/fuc -> succ_embed_surjective ->
   limitDomSubtype_isSuccArchimedean -> succ_cofinal -> chronicle_gap_contradiction ->
   prior_model_is_succ_archimedean -> no_gaps_faithful (sorry, KNOWN FALSE)

2. **Verified import feasibility**: Adding GoodStructuresModelSurgery import to
   ChronicleToCountermodel.lean creates no cycle (confirmed).

3. **Analyzed the plan's mathematical strategy**:
   - Construct OrderedMonadicStructure on LimitDomSubtype: feasible (pattern exists in
     priorModelAsMonadicStructure, ReynoldsModelSurgery.lean:107)
   - Prove semantic_prior_UZ/SZ: feasible (semantic_prior_UZ_raw/SZ_raw exist sorry-free
     in ReynoldsModelSurgery.lean:219/253)
   - Apply no_gaps_discrete_model_surgery to get one_class: feasible (pattern in
     chronicle_is_good_direct, ShiftAndGlue.lean:960-967)
   - **BLOCKED**: Derive IsSuccArchimedean from one_class: INCORRECT

4. **Verified the counterexample**: Z+Z (two copies of Z concatenated) with constant
   MCS assignment at every point. Satisfies:
   - SuccOrder, PredOrder, NoMaxOrder, NoMinOrder
   - semantic_prior_UZ (vacuously or via succ-witness with vacuous guard)
   - semantic_prior_SZ (symmetrically)
   - h_surj (atoms are infinite)
   - one_class (temporal_truth is constant, so all elements trivially contemp_equiv)
   - But NOT IsSuccArchimedean (gap between copies)

5. **Reviewed Reynolds 1994**: Reynolds proves Theorem 14 (class boundaries not at gaps)
   and Theorem 15 (existence of k-equivalent Z-model). He does NOT prove IsSuccArchimedean.
   His completeness proof (Theorem 18) uses k-equivalence transfer, not succ-embedding.

6. **Checked existing sorry-free paths**: one_class_implies_succ_archimedean
   (ReynoldsNoGaps.lean:321) delegates to prior_implies_succ_archimedean which uses
   no_gaps_prior (sorry, KNOWN FALSE). No sorry-free path from one_class to
   IsSuccArchimedean exists in the codebase.

## Key Decision Points

The BX pipeline (completeness_discrete path) requires IsSuccArchimedean.
The Reynolds pipeline (countermodel_discrete_reynolds path) does NOT require
IsSuccArchimedean but has its own sorry at Transfer.lean:1289.

## Alternative Approaches

(A) **Fix Reynolds pipeline** (Transfer.lean:1289): Requires showing Z-interval is
unbounded and constructing TaskModel with position-dependent valuation. The research
report says this is "architecturally unsolvable" due to S5 position-independence vs
Reynolds position-dependence. Needs deeper investigation.

(B) **Prove IsSuccArchimedean from chronicle construction**: The chronicle domain is
built as a countable limit of finite structures. Each finite stage IS IsSuccArchimedean.
The limit might preserve this, but proving it requires understanding how new points
are inserted between existing ones and showing no "accumulation without reaching" occurs.

(C) **Back-and-forth argument**: Prove that k-equivalence to Z-intervals for ALL k
implies isomorphism to Z (for countable structures). Standard model theory result
but not formalized in this codebase.

## Immediate Next Action

Run /revise 155 to create a new plan version addressing the mathematical gap.
The revised plan should pursue approach (A), (B), or (C) based on feasibility analysis.

## Files Examined (no changes made)

- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean
- Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean
- Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean
- Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean
- Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean
- Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean
- Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean
- Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean
- Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean
- Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean
- Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean
- Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean
- literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md
