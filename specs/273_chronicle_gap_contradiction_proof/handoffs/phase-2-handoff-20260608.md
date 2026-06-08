# Phase 2 Handoff: Prior Transfer Lemma

**Task**: 273
**Phase**: 2 (Prior Transfer Lemma)
**Status**: BLOCKED
**Session**: sess_1780961805_2e63d7
**Timestamp**: 2026-06-08

## Immediate Next Action

Phase 2 is blocked. The separation-based bypass approach cannot produce a sorry-free `US_expressively_complete_over_prior` with the existing type signature. The recommended next action is one of:

1. **(Preferred) Fill the EF game sorry sites**: The sorry at StaviCompleteness.lean:2353 and :2435 is the 4-variable existential transfer in the GHR93 EF game composition argument. Filling these two sorry sites would make `stavi_expressive_completeness` sorry-free, which resolves the entire chain without any changes to PriorExpressiveness.lean or downstream consumers. This follows Reynolds 1994 Theorem 5 exactly as written.

2. **(Alternative) Add Z-iso hypothesis**: Modify `US_expressively_complete_over_prior` to take `(iso : M.carrier ≃o Z)` and update 7 call sites in GoodStructuresModelSurgery.lean. The consumers' structures likely ARE Z-isomorphic but the proof infrastructure needs updating.

3. **(Alternative) Prove IsSuccArchimedean from hypotheses**: If Prior-UZ + SuccOrder + PredOrder + NoMaxOrder + NoMinOrder + h_surj implies IsSuccArchimedean, then the Z-iso can be constructed inside the proof without changing the type signature.

## Current Proof State

- **Phases 0-1**: COMPLETED (axiom audit + SemanticBridge infrastructure)
- **Phase 2**: BLOCKED (Prior transfer lemma)
- **Phases 3-4**: NOT STARTED (depend on Phase 2)

## Key Decisions

The separation theorem (GHR94 Ch 10.2, formalized sorry-free) gives {U,S} expressive completeness over Z. Reynolds 1994 Theorem 5 gets {U,S} completeness over Prior structures by using GHR93's {U,S,U',S'} completeness for ALL linear structures. The sorry in `stavi_expressive_completeness` IS the GHR93 result. The separation result cannot substitute for it because:

- `eval` for MonadicFormula quantifies over M.carrier (carrier-dependent)
- Z-carrier and arbitrary Prior carriers may differ
- Prior-UZ/SZ do not imply IsSuccArchimedean in general
- The atom elimination step (quantElimFormula) is proved only for IntStructureFromSig

## Deviations

All Phase 2 tasks are blocked. See plan file for inline annotations on each task.

## Files Modified

- `specs/273_chronicle_gap_contradiction_proof/plans/03_separation-bypass-plan.md` (phase status + blocker documentation)
