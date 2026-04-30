# Implementation Summary: Task #107 -- Burgess Chronicle Construction

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [IN PROGRESS]
- **Started**: 2026-04-29T12:00:00Z
- **Completed**: N/A (partial)
- **Effort**: ~3 hours
- **Artifacts**:
  - [plans/47_implementation-plan.md]
  - [handoffs/08_phase6-burgess-seed-handoff.md]

## Overview

Phase 6 partial implementation. The old Case 1/Case 2 proof for Lemma 2.7 was deleted and replaced with Burgess's direct seed strategy. Two sorry-free helper lemmas were added (`right_mono_until_mcs` and `untl_conj_eta_of_g_content`). The core Lemma 2.7 body remains as a single sorry due to three interrelated blockers: seed consistency with h_content(C), getting xi into D under open guard semantics, and proving eta in B' without G(eta) in A.

## What Changed

- Deleted old Case 1/Case 2 approach in PointInsertion.lean (was 2 sorries at lines 1026 and 1093)
- Added `right_mono_until_mcs`: BX3 (right monotonicity of Until) at MCS level, sorry-free
- Added `untl_conj_eta_of_g_content`: Proves U(xi, beta AND eta) in A for all beta with G(beta) in A, sorry-free
- Updated Lemma 2.7 docstring with Burgess direct seed strategy (Steps 1-9)
- Lemma 2.7 body: single sorry replacing 2 sorries (net reduction: -1 sorry in PointInsertion.lean)
- Phase 6 status: [IN PROGRESS] -> [PARTIAL]

## Decisions

- Deleted the old BX7-on-U(eta.neg,top) approach per plan v33 and research report 47
- Identified that under open guard semantics, U(xi,eta) does NOT imply F(xi), making direct seed construction harder than under reflexive semantics
- Identified that BurgessR3Maximal B is NOT negation-complete (unlike R3Maximal), complicating seed consistency proofs
- Recommended Option A (full Burgess seed construction) or Option C (Xu's Lemma 2.4) for completing Phase 6

## Impacts

- PointInsertion.lean sorry count: 1 (was 2)
- Build: passes with warnings only
- No downstream breakage (lemma_2_7 has no callers yet)

## Follow-ups

- Complete Lemma 2.7 proof via one of three approaches documented in handoff 08
- Option A: Full Burgess seed D_0 with BX5+BX7+BX13 consistency (8-12 hrs)
- Option B: Weaken theorem to skip eta-in-B' (2-3 hrs + downstream investigation)
- Option C: Use Xu's Lemma 2.4 alternative splitting (4-6 hrs)
- Consider running `/revise 107` to update plan with Phase 6 findings

## References

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- `/home/benjamin/Projects/ProofChecker/specs/107_chain_design_diagnostics_for_representation_theorem/handoffs/08_phase6-burgess-seed-handoff.md`
- `/home/benjamin/Projects/ProofChecker/specs/107_chain_design_diagnostics_for_representation_theorem/plans/47_implementation-plan.md`
