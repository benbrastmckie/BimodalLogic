# Phase 11 handoff — `ReynoldsBridge.lean` at the ℤ fibre

**Status**: [COMPLETED]. `lake build` 0, `lake build BimodalTest` 0,
`scripts/check-module-invariants.sh` ALL CHECKS PASSED, zero structural sorry, C2 profiles
`[propext, Classical.choice, Quot.sound]` on all four flagship theorems.

## Immediate next action
Phase 12 — `Metalogic/Algebraic/FlowFrame.lean` + `Metalogic/Bundle/CanonicalTaskRelation.lean`.

## Key decisions
- `countermodel_discrete_reynolds_v2`'s existential now yields `(F : TaskFrame)` plus the four
  CARRIER side conditions at `↑F.Duration`; the four ALGEBRA binders are gone (they are the
  frame's `Duration` field).
- Its consumer `BXCanonical/Completeness.lean` supplies the four side conditions by explicit
  `@`-application, NOT by `haveI`. See the Phase 11 Record in the plan: `IsSuccArchimedean` is
  indexed by its `SuccOrder` argument, and `haveI` introduces an opaque copy that breaks the
  index match.
- 5 residual `ParamTaskFrame` tokens in `ReynoldsBridge.lean` are `ParamTaskFrame.limit_of_shift`
  namespace references; relocation is Phase 20's.

## Deviations
- Blast radius 2 files, not 1 (`Completeness.lean` repaired in the same phase).
