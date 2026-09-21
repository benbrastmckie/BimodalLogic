# Phase 5 Handoff

- Next action: Phase 6, the metalogic result map inside `lean-appendix-reading-source`.
- Done: three new sections between the tactics and conventions sections —
  `<lean-appendix-derived-theorem>` (`perpetuity2` walked line by line, `perpetuity1` by
  signature, the MF instance by `modal_search`), `<lean-appendix-semantic-counterpart>`
  (`modal_future_valid`, `timeShift_preserves_truth` via `truthAt_of_truthCorr` at `shiftCorr`,
  the soundness remark, the axiom-footprint contrast) and `<lean-appendix-derivations-as-data>`
  (`DerivationTree.lift`, the `FrameClass` `LE` instance, `by decide` order facts, `lift` call).
  All four gates green.
- Phase 2's owed `@lean-appendix-derived-theorem` reference restored in the binder subsection.
- Two deviations, annotated on the plan checklist: `Perpetuity.contraposition` and two of the
  `FrameClass` order spans do not resolve under Check 1 and were re-expressed rather than
  whitelisted.
- `@lean-appendix-decision-procedure` was NOT used — the derivations-as-data section points at
  `@lean-appendix-reading-source` instead, since Phase 7 places the decision procedure as a
  subsection there rather than as a top-level section.
- Scope hypothesis confirmed: `lift` has seven arms, only `.axiom` does work, `perpetuity2`'s
  body is one `have` and one `exact`.
