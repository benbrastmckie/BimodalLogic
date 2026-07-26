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
