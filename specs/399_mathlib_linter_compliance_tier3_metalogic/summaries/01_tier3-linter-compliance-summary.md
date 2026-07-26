# Implementation Summary: Tier-3 Metalogic Mathlib Linter Compliance

- **Task**: 399 - mathlib_linter_compliance_tier3_metalogic
- **Status**: PARTIAL — phases 1-5 complete, phase 6 partial, phases 7-10 not started
- **Plan**: `plans/01_tier3-linter-compliance.md`
- **Dispatch**: 1 of an expected 6

## What was done

Phases 1-5 of the plan are complete and Phase 6 is 42 files of 43. The whole `linter.flexible`
category is cleared, and 93.5% of the mechanical surface is cleared, at a green build with the
sorry count untouched.

### Category movement (full 174-file census, `logs/census-origin.json` → `logs/census-phase6.json`)

| Category | Origin | Now | Cleared |
|---|---:|---:|---:|
| `linter.style.longLine` | 2,740 | 218 | 92.0% |
| `linter.style.show` | 449 | 18 | 96.0% |
| `linter.unusedSimpArgs` | 300 | 5 | 98.3% |
| `linter.flexible` | 253 | 0 | **100%** |
| `linter.unusedVariables` | 152 | 3 | 98.0% |
| `linter.style.emptyLine` | 113 | 0 | **100%** |
| **mechanical total** | **3,754** | **244** | **93.5%** |

Out-of-scope categories owned by sibling tasks are **unchanged, not reduced** — the check that
catches trespass: `push_neg` 521 → 521, `defProp` 35 → 35, `dupNamespace` 13 → 13. The judgment
bucket owned by Phase 7 is likewise untouched: rcases `unused name:` 68, `unusedSectionVars` 34,
`unusedTactic` 24, `multiGoal` 18, `maxHeartbeats` 17, rintro `Try this: intro` 6,
`classDefReducibility` 5.

### Build invariant, held at every phase boundary

`lake build` green at 1,875 jobs, 0 errors. Sorry census exactly **1**, at
`WeakCanonical/Transfer.lean`. Never 0, never 2.

## Deliverables

A reusable, differentially-gated toolkit under `tools/`, not one-off edits:

- `lintlib.py` — lint runner, log parser, distinct-site census, and the differential gate.
  Classifies the four footer-less categories by message text and reports
  `unusedDecidableInType ∪ unusedFintypeInType` as a **union**, never a sum.
- `fixers.py` — the five mechanical fixers plus a bracket-depth-aware line breaker.
- `sweep.py` — parallel per-file driver with a resumable completion log, a `--sequential`
  per-category salvage mode, and bisection that refuses only the individual sites that break.
- `flexible.py` — the `simp?` bulk harvest with `--per-site` and `--incremental` fallbacks.
- `fullsweep.py` — parallel 174-file census and differential diff.

The gate is what made this safe: every file is reverted unless its in-scope categories reach
zero, no other category rises, and no error appears. Nothing was committed unverified.

## Findings that changed the approach

Four defects were caught by the gate rather than by review, and each generalises past the file
that exposed it.

1. **Comment prefixes look like trailing comments.** `/--` and `-- ` both contain a literal
   `--`, so the trailing-comment guard rejected every break candidate on a comment line and
   left it unwrapped. Separately, an indented `-/` alone on a line makes
   `linter.style.docString` fire.
2. **Detaching a trailing comment can isolate a focus dot.** On a line whose only code was
   `·`, moving the comment above left the dot bare and `linter.style.cdot` fired. The comment
   now stays attached and only its overflow wraps.
3. **Clause keywords must not be split from their operand, in either direction.**
   `simp only [...]` newline `at h`, and `... by rw` newline `[...]`, both end the enclosing
   tactic block instead of continuing it.
4. **`unusedVariables` does not see `decreasing_by`.** Underscoring a binder that a
   termination proof references produced `Unknown identifier` — visible to `lake build` but
   **not** to the per-file lint, because the two disagree. This is the one class the per-file
   gate cannot catch on its own.

On the `flexible` harvest, the plan's reconcile-by-order-and-location rule was necessary but
not sufficient. Two further traps: `[apply]` payloads are emitted by other linters too
(`unusedSimpArgs` suggests a corrected `simp [...]`, `unusedVariables` suggests `_x`), so only
a payload directly under a bare `Try this:` line is a `simp?` suggestion; and a long suggestion
**wraps across log lines**, which silently truncates the lemma list and leaves an unbalanced
`[`. The 15-for-14 duplicate-elaboration figure from research reproduced exactly on
`UltrafilterMCS.lean`.

## What remains

**244 mechanical sites**, of which **196 are `SplitPoint.lean` alone** — deferred whole, not
refused. Its breaker failures are a gap in the breaker, not unsafe sites: a continuation inside
a tactic block opened **mid-line** by `by` must be indented past the `by`'s own column, not
past the line's leading indent. The file also elaborates in ~2 minutes, making bisection
impractical, so it was reverted to its committed state rather than left half-applied.

The other **48 sites across 10 files** are individually refused, each with its logged error, in
`logs/salvage.jsonl` and `logs/phase{4,5,6}.jsonl`. The 15 `show` sites in `VecEAFormula.lean`
belong to Phase 7, where the tactic they strand is deleted in the same edit.

**Phases 7-10 are not started**: the 186-site judgment sweep, 52 `docBlame` docstrings, the
residual ledger (`RESIDUALS.md`), and the closing global sweep. `logs/ledger-notes.md`
accumulates the ledger source material.

## Residual decisions deferred to Phase 9

Unchanged and deliberately untouched, per the plan's accepted-residual decision:
`runLinter unusedArguments` 193 sites, and `unusedDecidableInType ∪ unusedFintypeInType` 187
sites (the **union**, not the 360 raw sum). The 6 `simpNF LINTER FAILED` artifacts remain, root
cause named as the looping `@[simp] neg_unfold` in out-of-scope `Automation/Normalization.lean`.

## Plan Deviations

- **Phase 1, `longLine` fixer — altered.** Added bracket-depth-aware break selection on top of
  the specified last-space rule; last-space alone produced valid but poor splits (orphaned
  `:=`, binders split mid-group).
- **Phase 2, reconciliation — altered.** Order plus `at`-clause matching was necessary but not
  sufficient; see findings 1-2 above. Added `--per-site` and `--incremental` fallbacks. Two
  multi-line `simp` invocations in `Construction.lean` were hand-applied, the extent scanner
  being single-line.
- **Phase 2, gate — altered.** `longLine` and `unusedSimpArgs` are exempted from the Phase 2
  gate by design: a transcribed `simp only [...]` is longer than the `simp` it replaces, and
  Phases 4-6 own both categories and run afterwards. Every other category is still held to
  no-increase.
- **Phase 3, mid-file checkpoint — skipped.** The 12,801-LOC file swept in one 27-second pass,
  so no checkpoint was needed.
- **Phases 4-6, per-file gate — altered.** Added `--sequential` and bisection salvage so a
  single unsafe site cannot cost a file its other 190.
- **Phase 6, `SplitPoint.lean` — deferred.** See "What remains".
