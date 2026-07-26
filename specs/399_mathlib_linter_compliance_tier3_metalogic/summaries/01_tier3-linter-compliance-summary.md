# Implementation Summary: Tier-3 Metalogic Mathlib Linter Compliance

- **Task**: 399 - mathlib_linter_compliance_tier3_metalogic
- **Status**: PARTIAL — phases 1-7 complete, phases 8-10 not started
- **Plan**: `plans/01_tier3-linter-compliance.md`
- **Dispatch**: 2 of an expected 6

## What was done

Phases 1-7 are complete. **Every in-scope linter category is now at zero across all 174
files**, at a green build with the sorry count untouched. What remains is Phase 8's authoring
work (52 docstrings), Phase 9's residual ledger, and Phase 10's closing global sweep.

### Category movement (full 174-file census, `logs/census-origin.json` → `logs/census-phase7.json`)

| Category | Origin | Now |
|---|---:|---:|
| `linter.style.longLine` | 2,740 | 0 |
| `linter.style.show` | 449 | 0 |
| `linter.unusedSimpArgs` | 300 | 0 |
| `linter.flexible` | 253 | 0 |
| `linter.unusedVariables` | 152 | 0 |
| `linter.style.emptyLine` | 113 | 0 |
| rcases `unused name:` | 68 | 0 |
| `linter.unusedSectionVars` | 34 | 0 |
| `linter.unusedTactic` | 24 | 0 |
| `linter.unreachableTactic` | 20 | 0 |
| `linter.style.multiGoal` | 18 | 0 |
| `linter.style.maxHeartbeats` | 17 | 0 |
| rintro `Try this: intro` | 6 | 0 |
| `warn.classDefReducibility` | 5 | 0 |
| `linter.style.openClassical` | 3 | 0 |
| `linter.style.setOption` | 2 | 0 |
| `linter.unnecessarySimpa` | 2 | 0 |
| `docString` / `whitespace` / `unnecessarySeqFocus` | 1 each | 0 |
| **in-scope categories remaining** | | **0** |

`lake exe runLinter Bimodal` at the Phase 7 boundary: genuine `simpNF` 1 → 0, `synTaut` 1 → 0.
`docBlame` 52 in tier-3 is unchanged — that is Phase 8's work, not a regression.

Sibling-task categories are **unchanged, not reduced** — the check that catches trespass:
`push_neg` 521 → 521, `defProp` 35 → 35, `dupNamespace` 13 → 13, `defsWithUnderscore` 888 → 888.
The 115 `LINTER FAILED` rows, all rooted at out-of-scope `Automation/Normalization.lean`, are
unchanged and untouched.

### Build invariant, held at every phase boundary

`lake build` green at 1,875 jobs, 0 errors. Sorry census exactly **1**, at
`WeakCanonical/Transfer.lean:1241`. Never 0, never 2.

## Deliverables

A reusable, differentially-gated toolkit under `tools/`, not one-off edits:

- `lintlib.py` — lint runner, log parser, distinct-site census, and the differential gate.
  Classifies the four footer-less categories by message text and reports
  `unusedDecidableInType ∪ unusedFintypeInType` as a **union**, never a sum.
- `fixers.py` — the five mechanical fixers plus a block-aware line breaker.
- `sweep.py` — parallel per-file driver with a resumable completion log, a `--sequential`
  per-category salvage mode, and bisection that refuses only the individual sites that break.
- `one.py` — single-file apply/lint/gate loop that does **not** auto-revert, for files whose
  elaboration is too slow (~2 min) for bisection to be practical.
- `sites.py` — dumps every in-scope diagnostic with the linter's own wording and the offending
  source line; the Phase 7 judgment bucket is driven from this, not from counts.
- `flexible.py` — the `simp?` bulk harvest with `--per-site` and `--incremental` fallbacks.
- `fullsweep.py` — parallel 174-file census and differential diff.

The gate is what made this safe: every file is reverted unless its in-scope categories reach
zero, no other category rises, and no error appears. Nothing was committed unverified.

## Findings that changed the approach

### The line breaker needed a model of Lean's positional blocks

Three defects, each caught by the gate, each generalising past the file that exposed it:

1. **A continuation must clear the column of any tactic block opened MID-LINE by `by`.** The
   original `indent + 4` rule lands far to the *left* of that column and silently closes the
   block. The continuation column is now `max(indent + 4, required_cont_col)` and is recomputed
   per fragment, because a fragment following a line that ends in `by` is itself the head of a
   new block. Breaking *immediately after* `by` is free and is now preferred: it opens the block
   on the continuation line, which is the ordinary `:= by` layout.
2. **Never break inside an `at h₁ h₂ …` location clause.** The list does not resume on a
   continuation line; the tactic block ends instead, surfacing far away as `unexpected
   identifier; expected command`.
3. **`case X =>`, `next h =>` and `| pat =>` open positional blocks; `fun x =>` does not.**
   Treating lambdas as blocks over-indents every one of them; not treating alternatives as
   blocks closes them.

With those three rules, `SplitPoint.lean` — 196 sites, the file dispatch 1 deferred whole —
cleared in a single plain pass at 0 errors.

Four earlier defects (from dispatch 1) still stand: `/--` and `-- ` both contain a literal
`--`; detaching a trailing comment can isolate a `·` and fire `linter.style.cdot`; clause
keywords must not be split from their operand in either direction; and `unusedVariables` does
not see `decreasing_by`, which is the one class the per-file gate cannot catch without the
full build.

### Two "mechanical" fixes were not mechanical

- **`show` → `change` can strand a load-bearing tactic.** In `VecEAFormula.lean` the linter
  reported the converted `change` as doing nothing — but deleting it broke `omega`, because it
  was pinning the `k` metavariable in `holds_eq_succ`'s `n - i = k + 1`. It became a named
  `have` instead.
- **The genuine `simpNF` finding could not be fixed as suggested.** Restating
  `skipFin_zero_succ`'s left-hand side as `skipFin 0 i` type-checks but changes the normal form
  that six downstream `rw [e]` steps in `SharedWitness.lean` depend on. Since every use already
  names the lemma explicitly in a `simp only`, the `@[simp]` attribute — which could never fire
  anyway, that being the linter's whole point — was dropped instead.

### `open Classical` removal is not always a deletion

Two of the three files needed nothing further. `DefectChain.lean` did: its two `Finset.filter`
predicates are genuinely undecidable. A `letI` inside the definition alone does not survive
`unfold` in the downstream bound, and `classical` in the theorem picks `instDecidableAnd`, which
is then not defeq to the definition's instance. The fix is two **named** classical witnesses
registered as local instances, so definition and theorem synthesise the same one.

## What remains

- **Phase 8** — author 52 `docBlame` docstrings across 14 files. Not started.
- **Phase 9** — write `RESIDUALS.md`. **Its numbers have moved; see the deviation below.**
- **Phase 10** — closing global sweep and final `runLinter` diff.

## Residual decisions for Phase 9

| Category | Plan/baseline | After Phase 7 |
|---|---:|---:|
| `unusedDecidableInType` ∪ `unusedFintypeInType` (union) | 187 | 156 |
| `runLinter unusedArguments` | 203 | 122 |
| `LINTER FAILED` artifacts | 115 | 115 |

The 115 `LINTER FAILED` rows are all rooted at the looping `@[simp] neg_unfold` in out-of-scope
`Automation/Normalization.lean`, untouched by charter.

## Plan Deviations

- **Phase 7, `unusedSectionVars` vs the Phase 9 residual decision — CONFLICT, needs a user
  decision.** The linter's own remedy for `unusedSectionVars` is `omit [Fintype sig.preds]
  [DecidableEq sig.preds] in`, and those are exactly the binders that produce the
  `unusedInstInType` / `unusedArguments` findings Phase 9 decided to *accept* as residuals.
  Clearing one necessarily clears part of the other; the two plan clauses cannot both be
  honoured. Phase 7's task list names `omit` explicitly, so the more specific clause was taken
  and the omits stand. Effect: `unusedInstInType(union)` 187 → 156, `runLinter unusedArguments`
  203 → 122, concentrated in `AggregateOffDiagK1.lean` (28 → 14), `ExteriorNavFutK1.lean`
  (10 → 1) and `ExteriorNavPastK1.lean` (9 → 1). No signature was hand-edited and no proof
  changed. Phase 9 must write `RESIDUALS.md` against the new numbers, and Phase 10's
  "unchanged from baseline" check for these two categories must be re-baselined.
- **Phase 7, `simpNF` — altered.** Fixed by dropping `@[simp]` rather than restating the
  left-hand side; see "Two 'mechanical' fixes were not mechanical".
- **Phase 7, `synTaut` — altered.** `kvE_subBracket2V_succ_j0` is an unreferenced
  definitional-compatibility check whose statement really is `a = a`. Converted from `theorem`
  to `example`, so the elaboration check survives without asserting a vacuous proposition.
- **Phase 6, `Completeness.lean` — altered.** Two fully-qualified names of 97 and 118 characters
  cannot be written inside the proof under a 100-column limit at any indentation. Resolved with
  `open ... in` on the theorem rather than by line-breaking.
- **Phase 1, `longLine` fixer — altered.** Added bracket-depth-aware break selection on top of
  the specified last-space rule; last-space alone produced valid but poor splits.
- **Phase 2, reconciliation — altered.** Order plus `at`-clause matching was necessary but not
  sufficient. Added `--per-site` and `--incremental` fallbacks. Two multi-line `simp`
  invocations in `Construction.lean` were hand-applied, the extent scanner being single-line.
- **Phase 2, gate — altered.** `longLine` and `unusedSimpArgs` are exempted from the Phase 2
  gate by design; Phases 4-6 own both and run afterwards.
- **Phase 3, mid-file checkpoint — skipped.** The 12,801-LOC file swept in one 27-second pass.
- **Phases 4-6, per-file gate — altered.** Added `--sequential` and bisection salvage so a
  single unsafe site cannot cost a file its other 190.
