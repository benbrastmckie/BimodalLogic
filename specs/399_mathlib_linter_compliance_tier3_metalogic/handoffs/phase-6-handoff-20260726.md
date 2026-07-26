# Handoff after Phase 6 (dispatch 1 of ~6)

## Immediate next action

**Fix the line breaker's continuation-indent rule, then sweep `SplitPoint.lean`.**

In `tools/fixers.py`, `break_code` sets the continuation indent to `indent_of(ln) + 4`. That is
wrong whenever the break point sits inside a tactic block opened **mid-line** by `by`: the
continuation must be indented past **the `by`'s own column**, or the block closes and the
proof breaks. Change to roughly:

```python
cont_col = max(indent_of(ln) + 4, column_after_innermost_still_open_by_before_break)
```

and refuse the break if `cont_col` leaves too little room before column 100.

Evidence: `SplitPoint.lean:1036` (`... by rw [show ...];` with the continuation at indent 18,
closing the block) and `:319` (`... by rw` then `[...]`). Both are `unsolved goals` /
`unexpected identifier` at build time.

Then: `python3 tools/sweep.py --max-iter 2 --log logs/salvage.jsonl \
Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean`

Note the file elaborates in **~2 minutes**, so bisection over its ~190 sites is impractical —
get the plain pass right instead. It is currently at its committed (unswept) state.

After that, Phase 7.

## State

- Phases 1-5 COMPLETED, Phase 6 PARTIAL (42/43 files), Phases 7-10 NOT STARTED.
- `lake build` green at 1875 jobs. Sorry census exactly **1**. All commits at green.
- Last commit: `task 399 phases 4-6: mechanical sweep across all three territories`.

## Numbers to resume from

Mechanical 3,754 → 244 (93.5% cleared); `flexible` 253 → 0. Remaining mechanical:

| File | longLine | show | unusedSimpArgs | unusedVariables |
|---|---:|---:|---:|---:|
| `Expressiveness/SplitPoint.lean` | 188 | 3 | 5 | — |
| `WeakCanonical/NEquivalence.lean` | 12 | — | — | — |
| `Kamp/VecEAFormula.lean` | — | 15 | — | — |
| `WeakCanonical/Table.lean` | 4 | — | — | — |
| `Kamp/NfDepth0Generalized.lean` | 4 | — | — | — |
| `Kamp/EANegation.lean` | 2 | — | — | — |
| `BXCanonical/Completeness.lean` | 2 | — | — | — |
| `Chronicle/CounterexampleElimination.lean` | 2 | — | — | — |
| `Kamp/Prop42NegationGeneral.lean` | 1 | — | — | 2 |
| `WeakCanonical/NormalForm.lean` | 1 | — | — | — |
| `IntegerModel/GoodStructures.lean` | 1 | — | — | — |
| `Chronicle/PointInsertion.lean` | 1 | — | — | — |
| `Kamp/EANegationFix/NegFix.lean` | — | — | — | 1 |

Phase 7's bucket is untouched and at baseline: rcases `unused name:` 68, `unusedSectionVars` 34,
`unusedTactic` 24, `unreachableTactic` 20, `multiGoal` 18, `maxHeartbeats` 17, rintro 6,
`classDefReducibility` 5, `openClassical` 3, `setOption` 2, `unnecessarySimpa` 2, `docString` 1,
`unnecessarySeqFocus` 1, `whitespace` 1.

## Per-file notes for the next dispatch

- **`VecEAFormula.lean`, 15 `show` sites** — belongs in **Phase 7**, not a re-run of the
  mechanical sweep. Converting `show` to `change` there strands a tactic, so
  `linter.unusedTactic` rises and the gate correctly refuses it. Delete the dead tactic in the
  same edit.
- **`Prop42NegationGeneral.lean`, 2 `unusedVariables`** — the binder is passed by NAME by a
  caller (`Invalid argument name 'hName' for function 'negLeftClauseTLFin_holds'`). Underscoring
  it is wrong; either leave it or rename at both ends. Judgment, not mechanical.
- **`NegFix.lean`, 1 `unusedVariables`** — the binder is referenced from a `decreasing_by`
  block that the linter's scope analysis does not see. **Leave it.** This one was caught by
  `lake build`, not by the per-file lint; always run `lake build` before committing.

## Tooling contract (do not re-derive)

- Reference census: `logs/census-origin.json` (pre-work) vs `logs/census-phase6.json` (now).
  Diff with `python3 tools/fullsweep.py --diff <new> --diff-against logs/census-origin.json`.
  Add `--fold` **only** when diffing against `baseline/per-file-categories.json`, which merges
  the runLinter pass and collapses the four footer-less categories.
- Completion logs are the resume points: `logs/phase{1..6}.jsonl`, `logs/salvage.jsonl`. Files
  with `ok:true` are skipped without `--force`.
- `lake env lean` takes no lake lock, so censuses and sweeps parallelise (`--jobs`).
  `lake build` does **not** — never run two.
- Frozen categories are enforced in `lintlib.OUT_OF_SCOPE_FROZEN`: a file whose `defProp`,
  `dupNamespace`, `unusedArguments`, `unusedDecidableInType`, `unusedFintypeInType`, or
  deprecation count changes **in either direction** fails the gate.

## Not yet run this task

`lake exe runLinter Bimodal` (whole-library, ~7 min) has not been run since the baseline. It is
required at the Phase 7, 8, 9, and 10 boundaries, diffed against
`baseline/runlinter-findings.json`.
