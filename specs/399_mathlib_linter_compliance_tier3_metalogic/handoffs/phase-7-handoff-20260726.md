# Handoff after Phase 7 (dispatch 2 of ~6)

## Immediate next action

**Get a user decision on the Phase 9 residual numbers, then start Phase 8 (52 docstrings).**

### The decision that is blocking Phase 9

Clearing `unusedSectionVars` (Phase 7) necessarily reduced the categories Phase 9 was going to
ledger as accepted residuals, because the linter's own prescribed remedy — `omit
[Fintype sig.preds] [DecidableEq sig.preds] in` — removes exactly the binders that produce
them. The two plan clauses conflict and cannot both hold.

| Category | Plan/baseline | Now |
|---|---:|---:|
| `unusedDecidableInType` ∪ `unusedFintypeInType` (union) | 187 | 156 |
| `runLinter unusedArguments` | 203 | 122 |

Concentrated in `AggregateOffDiagK1.lean` (28 → 14), `ExteriorNavFutK1.lean` (10 → 1),
`ExteriorNavPastK1.lean` (9 → 1). No signature was hand-edited; no proof changed; the build is
green. Either (a) accept and have Phase 9 write `RESIDUALS.md` against 156/122 and re-baseline
Phase 10's "unchanged" check, or (b) revert the omits in those three files and leave 25
`unusedSectionVars` outstanding, which would make Phase 10's "every in-scope category at 0"
fail. **(a) is the recommendation** — it is strictly more compliant and touches nothing a
sibling task owns.

### Phase 8: 52 `docBlame` docstrings, 14 files

Distribution from the plan, re-confirmed by `logs/runlinter-phase7.json` (`docBlame`, tier-3
rows only): `CounterexampleElimination.lean` 16, `CanonicalModel.lean` 11, `PointInsertion.lean`
6, `MonadicFO.lean` 4, then 2 each in `LindenbaumQuotient.lean`, `Construction.lean`,
`Realization.lean`, `ConjInterleave.lean`, `VecEATranslation.lean`, and 1 each in
`ExistsForallNF.lean`, `PriorInterface.lean`, `SharedWitness.lean`, `SubBracket2.lean`,
`Transfer.lean`. Get the exact list with:

```
python3 -c "import json; [print(r[1], r[2], r[3][:80]) for r in
  json.load(open('specs/399_.../logs/runlinter-phase7.json'))
  if r[0]=='docBlame' and '/Automation/' not in r[1]]"
```

Two hard rules: never place a docstring between an attribute and its declaration (parse error),
and keep every new line under 100 characters so Phase 8 does not reintroduce `longLine`.

## State

- Phases 1-7 COMPLETED. Phases 8, 9, 10 NOT STARTED.
- `lake build` green at 1875 jobs. Sorry census exactly **1**, `Transfer.lean:1241`.
- **Every in-scope category is at 0 across all 174 files** (`logs/census-phase7.json`).
- Last commit: `task 399 phase 7: judgment sweep complete, every in-scope category at zero`.

## Numbers to resume from

Sibling-task categories, verified unchanged (a *reduction* here is trespass, not progress):
`push_neg` 521, `defProp` 35, `dupNamespace` 13, `defsWithUnderscore` 888, `LINTER FAILED` 115,
`Automation/` `docBlame` 39.

Still open, all Phase 8/9/10: tier-3 `docBlame` 52; the residual ledger; the closing sweep.

## Tooling contract (do not re-derive)

- Censuses: `logs/census-origin.json` (pre-work) → `logs/census-phase6b.json` (mechanical done)
  → `logs/census-phase7.json` (now). Diff with
  `python3 tools/fullsweep.py --diff <new> --diff-against <old>`. Add `--fold` **only** when
  diffing against `baseline/per-file-categories.json`.
- `tools/sites.py --src --cats <cat>[,<cat>] --from-census <census.json>` dumps every matching
  diagnostic with the linter's own wording and the offending source line. The whole Phase 7
  bucket was driven from this; Phase 8 should be too.
- `tools/one.py` is the non-reverting single-file apply/lint/gate loop for slow files.
- `lake env lean` takes no lake lock, so censuses and sweeps parallelise (`--jobs`).
  `lake build` does **not** — never run two.
- **`lake env lean` on one file is not a substitute for `lake build`.** A `DecidablePred`
  synthesis failure in `DefectChain.lean` showed clean under the per-file census and failed the
  full build. Always build before committing.

## Breaker rules now encoded in `tools/fixers.py` (do not regress)

1. Continuation column is `max(indent + 4, required_cont_col)`, recomputed per fragment; a
   mid-line `by`/`do` fixes the block's column and a continuation left of it closes the block.
   Breaking immediately *after* `by` is free and preferred.
2. Never break inside an `at h₁ h₂ …` location clause.
3. `case X =>` / `next h =>` / `| pat =>` open positional blocks; `fun x =>` does not.
4. Plus the four dispatch-1 rules: `/--` and `-- ` both contain a literal `--`; detaching a
   trailing comment can isolate a `·`; clause keywords must not be split from their operand in
   either direction; `unusedVariables` does not see `decreasing_by`.

## Verification required at the Phase 8/9/10 boundaries

`lake exe runLinter Bimodal` (whole-library; ~5s here, not the 7 min the plan budgeted), parsed
with the header regex `^/-+ The \`(\w+)\` linter reports:` — note **`/-`, not `/--`** — and
`LINTER FAILED` rows counted separately from `simpNF`. The baseline
`baseline/runlinter-findings.json` folds the 115 `LINTER FAILED` rows into its `simpNF` 116, so
a naive per-linter diff shows a spurious -115.
