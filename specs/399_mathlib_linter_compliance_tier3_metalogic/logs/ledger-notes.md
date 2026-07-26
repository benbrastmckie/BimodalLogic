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

## Out-of-scope handoffs (must be UNCHANGED at close, not reduced)

- `linter.defProp` 35, `linter.dupNamespace` 13 → naming task
- `runLinter defsWithUnderscore` 572 → naming task
- `push_neg` deprecations 521 → deprecation task
