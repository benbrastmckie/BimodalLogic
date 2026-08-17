# Phase 5 handoff — task 417, plan 05, dispatch 6

**Immediate next action**: Phase 6 — read `BXCanonical/Quasimodel/HintikkaPoint.lean` and
`Construction.lean`, then define `LocalCoherent`, `Fulfilling`, `BoxOracleSound` in
`Annotation.lean` and the two non-vacuity witnesses in a new `Examples.lean`.

## State

- Phases 4 and 5 `[COMPLETED]`.
- New, building clean, sorry-free:
  - `FormalSystem/Metalogic/Decidability/BiLasso/Periodic.lean`
  - `FormalSystem/Metalogic/Decidability/BiLasso/Annotation.lean`
- `Basic.lean` verified byte-identical (`git diff --exit-code` exits 0) after both phases.

## Key decisions

- Duplication grep returned only `Basic.lean:145`'s own `structure BiLasso`. The
  effective-periodic-extension work has landed no generic periodic-sequence type, so
  `Periodic.lean` was written as planned; the phase did not shrink to `Annot` alone. The
  deliberate `emod` duplication against `Basic.lean` and its retirement trigger are recorded in
  `Periodic.lean`'s module docstring.
- Alignment is carried by `Annot.readIndex` (one definition, stated in the **lasso's** segment
  lengths) plus `Annot.label_unroll_aligned`, which proves label and state are read at that same
  index in all three regimes. The three length-agreement fields are genuinely consumed in
  transporting the label decoding's own thresholds and moduli onto the state lengths.
- `label_subset_closure` is derived from the `label_sub` structure field, covering the
  out-of-range `∅` default as well as listed labels.

## API surface for Phase 6

- `Annot.label : ℤ → Finset Formula`, `Annot.readIndex`, `Annot.backLab_ne`, `Annot.fwdLab_ne`
- `Annot.label_sub_back_length` (`t < 0`), `Annot.label_add_fwd_length` (`|mid| ≤ t`) — same
  thresholds as the state periodicities in `Basic.lean`
- `Annot.label_subset_closure`
- From Phase 4: `truth_untl_succ`, `truth_snce_pred`, `Int.rightInduction`, `Int.leftInduction`

## Deviations

None.
