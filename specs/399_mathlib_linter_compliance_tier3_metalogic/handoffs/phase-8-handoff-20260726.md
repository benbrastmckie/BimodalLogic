# Handoff after Phase 8 (dispatch 3)

## Immediate next action

Phase 9: write `RESIDUALS.md` against the CURRENT figures (`unusedInstInType` union 156,
`runLinter unusedArguments` 122) — the orchestrator has SETTLED the Phase 7/9 conflict in favour
of Phase 7's `omit` clause. Do not restore 187/203.

## State

- Phases 1-8 COMPLETED. Phases 9, 10 NOT STARTED.
- `lake build` green at 1875 jobs. Sorry census exactly 1, `Transfer.lean:1225`
  (`countermodel_discrete` — the line number drifts as edits land; the declaration is the invariant).
- Every in-scope style category 0 across all 174 files (`logs/census-phase8.json`).
- Tier-3 `docBlame` 52 -> 0; `Automation/` `docBlame` 39 unchanged.

## Verified numbers (whole-library `lake exe runLinter Bimodal`, `logs/runlinter-phase8.json`)

| Category | Baseline | Now | Note |
|---|---:|---:|---|
| `docBlame` | 91 | 39 | tier-3 52 -> 0; the 39 are all `Automation/` |
| `defsWithUnderscore` | 888 | 888 | frozen — naming task |
| `unusedArguments` | 203 | 122 | settled Phase 7 reduction |
| `LINTER FAILED` | 115 | 115 | frozen |
| `simpNF` (genuine) | 1 | 0 | Phase 7 |
| `synTaut` | 1 | 0 | Phase 7 |
| `tacticDocs` | 4 | 4 | out of scope |
| `structureInType` | 1 | 1 | out of scope |

Style census (`logs/census-phase8.json`), frozen categories all `+0` vs Phase 7:
`push_neg` 521, `defProp` 35, `dupNamespace` 13, `unusedInstInType(union)` 156,
`(uncategorized)` 1, `(sorry)` 1.

The single `(uncategorized)` row is `MonadicFO.lean:7` — a deprecated **Mathlib import**
(`Mathlib.Data.Finite.Card`), not a linter finding. Out of scope (deprecation task); unchanged
since baseline. Ledger it in Phase 9, do not fix it.

## Tooling added this dispatch

`tools/runlinter.py` — parses `lake exe runLinter` raw output into the task's 4-column findings
JSON, and diffs two artifacts.

Three traps it encodes, each of which silently corrupts a hand-rolled parser:

1. The section header opens with `/-`, **not** `/--`. A `/--`-anchored regex matches nothing.
2. `LINTER FAILED` rows come in TWO shapes and both must be captured, or the count reads 78
   instead of 115: a positioned `path:line:col: error: <decl> LINTER FAILED:` form (78 rows) and a
   positionless `#check <decl> /- LINTER FAILED` form (37 rows, filed by the baseline artifact
   under the pseudo-path `(#check form)`). `LINTER FAILED` is mid-message, never at the start.
3. `counts()` reclassifies by message text on BOTH sides of a diff, because the baseline artifact
   files its 115 `LINTER FAILED` rows inside its `simpNF` 116 while later artifacts break them
   out. Without that normalisation a diff reports a spurious `simpNF -115`.

Also note: `runLinter` takes ~40s here, not the 7 min the plan budgeted.

## Phase 8 lesson worth carrying

Three "missing docstring" findings were not missing prose at all — the declaration sat under a
long `/-!` **section** doc that reads exactly like a docstring but can never attach
(`henkin_bfmcs`, `kvE2_sepSlotValue`, `kvE_subBracket2`). Deleting the blank line to "re-attach"
it is a non-fix; a real `/-- … -/` has to be authored. Check the comment opener before assuming a
docBlame finding means no prose exists.

## Everything else

Unchanged from `phase-7-handoff-20260726.md` — the census/diff tooling contract, the breaker
rules in `tools/fixers.py`, and the "`lake env lean` on one file is not a substitute for
`lake build`" rule all still hold.
