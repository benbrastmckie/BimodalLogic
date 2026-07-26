# Running ledger notes (source material for RESIDUALS.md in Phase 9)

Accumulated during Phases 1-8. Do not fix anything listed here.

## `simpNF LINTER FAILED` artifacts (6 total, all out-of-scope root cause)

Root cause is the looping `@[simp] neg_unfold` at `Theories/Bimodal/Automation/Normalization.lean:69`,
which is outside this task's charter. The attribute must NOT be dropped.

- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` — 2 artifacts (recorded Phase 1)
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` — 4 artifacts (to record in Phase 5)

## Accepted API residuals (Phase 9 decision)

- `runLinter unusedArguments` — 193 sites, 52 files
- `unusedDecidableInType` ∪ `unusedFintypeInType` — 187 sites (UNION, not the 360 raw sum), 33 files

## Mechanical sites refused by the per-site elaboration gate (Phases 4-6)

These are NOT accepted residuals in the same sense as the 380 below — they are individual
sites where the mechanical edit is provably unsafe, isolated by bisection so the rest of the
file still swept. Each was refused because applying it alone produced a build error (or, for
`show` in `VecEAFormula.lean`, made a later tactic dead, which is Phase 7 work).

**`Expressiveness/SplitPoint.lean` is NOT in this class** — it is unfinished work, not a
residual. It holds 196 of the 244 remaining mechanical sites (188 `longLine`, 3 `show`,
5 `unusedSimpArgs`) and was left entirely unswept. Two reasons, both mechanical:

1. Its breaker failures are a real gap in the breaker, not unsafe sites: the continuation
   indent is computed as `line_indent + 4`, but a break inside a tactic block opened
   MID-LINE by `by` must be indented past **the `by`'s own column**, not past the line's
   leading indent. Observed at `SplitPoint.lean:1036` (`... by rw [...];` then a
   continuation at indent 18 that closes the block) and `:319` (`... by rw` then `[...]`).
2. The file elaborates in ~2 minutes, so bisection over ~190 sites is impractical — the
   salvage run was stopped and the file reverted to its committed state rather than left
   half-applied.

Fixing rule 1 (continuation indent = `max(line_indent + 4, column_after_innermost_open_by)`)
is the single highest-value next change: it should clear SplitPoint in one plain pass and
also recover some of the refused `longLine` sites listed below.

Authoritative machine-readable list: `logs/salvage.jsonl` and `logs/phase{4,5,6}.jsonl`
(`refused` / `bisect_left` fields). Recurring shapes:

- **`longLine` with no safe break point.** A line whose only candidate break points would
  split a construct that is whitespace-sensitive: an anonymous structure instance
  (`unexpected identifier; expected '}'`), a tactic block continuation
  (`expected '*' or checkColGt`), or a `match`/`induction ... with` alternative
  (`Alternative 'succ' has not been provided`).
- **`unusedVariables` on a binder used as a NAMED ARGUMENT.** Prefixing with `_` renames the
  binder and breaks callers that pass it by name — observed as
  `Invalid argument name 'hName' for function 'negLeftClauseTLFin_holds'`
  (`Prop42NegationGeneral.lean`, 2 sites).
- **`show` that strands a tactic.** `VecEAFormula.lean` (15 sites): converting `show` to
  `change` makes a following tactic dead, so `linter.unusedTactic` rises. Deferred to Phase 7,
  where the dead tactic is deleted in the same edit rather than left behind.

## Out-of-scope handoffs (must be UNCHANGED at close, not reduced)

- `linter.defProp` 35, `linter.dupNamespace` 13 → naming task
- `runLinter defsWithUnderscore` 572 → naming task
- `push_neg` deprecations 521 → deprecation task
