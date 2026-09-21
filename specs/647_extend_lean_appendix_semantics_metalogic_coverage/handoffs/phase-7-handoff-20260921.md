# Phase 7 Handoff

- Next action: Phase 8, extend `scripts/typst-status-counts.sh` and `scripts/typst-sync-check.sh`
  Check 2 together as one atomic-batch commit, then regenerate `typst/generated/status.typ`.
- Done: `=== The Decision Procedure` added inside `lean-appendix-reading-source` before
  Trust-Reading Practice (four `DecisionResult` constructors with the fuelExhausted/
  extractionFailed distinction, `decide`'s three optional parameters, `sound_of_isValid`, and
  the established-versus-open split pointing at `@sec:fmp-resolution` and
  `@sec:decidability-practice`). Trust-Reading Practice extended with "a name is not a proof",
  quoting both retired statements verbatim from the retirement note. All four gates green.
- `decide φ 10 1000 .Base` does not resolve as an inline span, so both calls moved into a
  compiled didactic block. The scratch snippet file was updated to the unqualified spelling the
  appendix now shows and recompiled with `lake env lean`, exit 0.
- Scope hypothesis confirmed: four `DecisionResult` constructors and three `decide` defaults.
- `grep` finds no `specs/` path and no task number in the appendix.
