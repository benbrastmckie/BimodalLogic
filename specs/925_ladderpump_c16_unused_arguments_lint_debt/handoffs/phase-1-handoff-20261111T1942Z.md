# Phase 1 Handoff: allowlist entry landed ahead of the attribute

- **Task**: 925
- **Phase**: 1 of 3 — Land the reasoned allowlist entry ahead of the attribute
- **Outcome**: [COMPLETED]
- **Dispatch**: seq 20, session sess_1794425759_f1ad4f

## Immediate Next Action

Phase 2, first task: re-read both `LadderPump.lean` regions (`sed -n '1817,1836p'` and
`sed -n '1859,1876p'`) and re-confirm `wc -l` reads 1931, then run the
`exists_idleSpliced_ladderPath` consumer sweep before deleting either instance binder.

## Current State

`scripts/nolint-attribute-allowlist.txt` is 136 lines with 7 `^unusedArguments:` keys; the new
key is `unusedArguments:exists_idleTypeBlock_of_budget_le_run`, preceded by a 17-line `#` reason
block and the locator line `# Metalogic/Decidability/RaySummary/LadderPump.lean.`

No Lean source was touched. `LadderPump.lean` is unmodified and still 1,931 lines, so Phase 2's
net-zero line budget starts from the figure the plan assumes.

`bash scripts/check-module-invariants.sh --no-build` exits 0 with `PASS C26` on both halves and
exactly one `INFO C26` stale line naming only the new key. That INFO is the expected, correct
output of this intermediate state; Phase 2's in-source `@[nolint unusedArguments]` extinguishes
it. If it survives Phase 2, the key and the as-written declaration name disagree.

C16's `env_linter` batch is `INFO ... skipped (--no-build)` — not a pass. The decisive
`runLinter FormalSystem` evidence is Phase 2's, and the build-gated groups are Phase 3's.

## Key Decisions

- Allowlist entry first, attribute second. C26 half two blocks (`FAIL`) on an in-source attribute
  with no allowlist entry, but only advises (`INFO`) on an allowlist entry matching nothing in the
  tree. This ordering keeps every intermediate commit green on C26 without an atomic batch across
  the two files, and the run above confirms the asymmetry empirically.
- The reason block carries all five admission-bar elements, each verified against live source
  rather than copied from the plan.

## Deviations

- Element (b)'s line numbers were re-derived. The plan cites
  `exists_idleBlock_of_hasIdleRunBelow` at `LadderWindow.lean:430` with the positional `hg`
  pass-through at `:443`; the live file has the declaration at `:472` and the pass-through at
  `:486`, shifted by task 918's commits (through `d2ce90db5`) landing between plan authoring and
  this dispatch. The substantive claim is unchanged and confirmed: that declaration takes its own
  `hg : IsLadderPath step pend g` and passes it positionally, so dropping the binder in
  `LadderPump.lean` would relocate the finding into `LadderWindow.lean` rather than clear it. The
  block carries the corrected numbers. Recorded in this task's issue log.

## Territory

`git status --short` shows exactly one non-`specs/**` file dirty: the allowlist. No foreign
uncommitted modification to `LadderPump.lean` or `LadderWindow.lean`, and no build this dispatch
did not start. Task 918's LadderWindow work is committed, not in flight.
