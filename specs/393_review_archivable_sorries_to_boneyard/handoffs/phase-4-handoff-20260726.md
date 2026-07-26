# Phase 4 Handoff — Correct the stale in-repo claims

**Status**: COMPLETED, green.

## Next action
Phase 5: final verification (full build, collectAxioms taint scan expecting exactly 3 tainted
declarations, Boneyard README audit) and the `countermodel_discrete` follow-up recommendation
in the summary.

## State
- `lake build` green (1875 jobs). Live sorries: 1 (`Transfer.lean:1227`) — unchanged, as
  required for a documentation-only phase.
- `Transfer.lean`: module docstring no longer calls `countermodel_discrete_reynolds` the
  "active path"; it now names `countermodel_discrete_reynolds_v2` and states the former is
  archived and was `sorryAx`-tainted. The DEPRECATED block was rewritten as
  "the one live sorry" with the two candidate proof routes.
- `Completeness.lean`: the "chronicle_gap_contradiction ... dead code" paragraph re-pointed to
  the Boneyard; the `completeness` sorry-status paragraph updated (its BX route is archived).
  Its `completeness_discrete` section already correctly named `..._reynolds_v2` and was left as is.
- `ReynoldsBridge.lean`: bypass narration annotated `(archived — ...)`, plus an explicit
  `..._reynolds` vs `..._reynolds_v2` disambiguation.
- `MCSMixedCase.lean`, `WeakCanonical.lean`, `ReflexiveCanonical.lean`: prose annotated.

## Deviations
None.
