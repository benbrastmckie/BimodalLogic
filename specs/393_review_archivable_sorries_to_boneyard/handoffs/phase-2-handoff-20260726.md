# Phase 2 Handoff — Excise Until/Since step block from Bundle/SuccRelation.lean

**Status**: COMPLETED, green.

## Next action
Phase 3 (highest risk): move the 8-declaration `chronicle_gap_contradiction` closure as ONE
unit — 7 decls in `BXCanonical/Chronicle/ChronicleToCountermodel.lean` plus
`countermodel_discrete_reynolds` in `WeakCanonical/Transfer.lean`. Heads first (sub-step 3.1,
commit green), then tails (3.2), then iterate the build to a closure fixpoint (3.3).
`countermodel_discrete` in Transfer.lean must NOT be touched.

## State
- `lake build` green (1875 jobs). Live sorries: 2 (was 9).
  Remaining: `ChronicleToCountermodel.lean:208`, `Transfer.lean:1297`.
- 7 decls excised to `Boneyard/SorriedDeclExcisions/BundleUntilSinceStep.lean` (imports
  verbatim, ARCHIVED docstring, `#exit`, code verbatim).
- Prose re-pointed in `Bundle/TemporalCoherence.lean` and `Bundle/UntilSinceCoherence.lean`.
- `SorriedDeclExcisions/README.md`: inventory row added; the "must not move" entry for the
  `chronicle_gap_contradiction` trio rewritten as a **Superseded** note.
- Root `Boneyard/README.md`: SorriedDeclExcisions row 5 -> 6 files / 3,342 lines; Total
  91 files / 57,549 lines.

## Deviations
None.
