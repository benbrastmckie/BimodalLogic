# Implementation Summary: Tier-3 Metalogic Mathlib Linter Compliance

- **Task**: 399 - mathlib_linter_compliance_tier3_metalogic
- **Status**: COMPLETED — all 10 phases
- **Plan**: `plans/01_tier3-linter-compliance.md`
- **Residual ledger**: `RESIDUALS.md`
- **Dispatches**: 3 (the plan expected 5-7)

## What was done

All ten phases are complete. **Every in-scope linter category is at zero across all 174 files**,
at a green build with the sorry count untouched: 4,651 distinct edit sites cleared, 52 docstrings
authored, and the 268 accepted sites converted into a written API decision rather than left as
silent leftovers.

### Category movement (full 174-file census, `logs/census-origin.json` → `logs/census-final.json`)

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

### Whole-library `lake exe runLinter Bimodal` (`baseline/runlinter-findings.json` → `logs/runlinter-final.json`)

| Category | Baseline | Final | In-scope baseline → final |
|---|---:|---:|---|
| `docBlame` | 91 | 39 | 52 → **0** (the 39 remaining are all `Automation/`) |
| genuine `simpNF` | 1 | 0 | 1 → **0** |
| `synTaut` | 1 | 0 | 1 → **0** |
| `unusedArguments` | 203 | 122 | 193 → 112 — accepted residual, see `RESIDUALS.md` |
| `LINTER FAILED` | 115 | 115 | 6 → 6 — accepted artifact |
| `defsWithUnderscore` | 888 | 888 | 572 → 572 — out of scope |
| `tacticDocs` / `structureInType` | 4 / 1 | 4 / 1 | outside the 174-file scope |

Sibling-task categories are **unchanged, not reduced** — the check that catches trespass, since a
reduction here would mean this task had edited another task's territory: `push_neg` 521 → 521,
`defProp` 35 → 35, `dupNamespace` 13 → 13, `defsWithUnderscore` 888 → 888.

### Build invariant, held at every phase boundary

`lake build` green at 1,875 jobs, 0 errors. Sorry census exactly **1**, at `countermodel_discrete`
in `WeakCanonical/Transfer.lean` (line 1225 as of close — the line number drifts as edits land, so
the *declaration* is the invariant, not the position the plan recorded). Never 0, never 2.

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
- `runlinter.py` — parses whole-library `lake exe runLinter` output into the 4-column findings
  JSON and diffs two artifacts. It encodes three traps that silently corrupt a hand-rolled parser
  (see "The `runLinter` output format has three traps" below).

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

### A `docBlame` finding does not always mean the prose is missing

Three of Phase 8's 52 findings — `henkin_bfmcs`, `kvE2_sepSlotValue`, `kvE_subBracket2` — already
sat under long, carefully written prose blocks. The blocks open with `/-!`, which makes them
**section** docs. A `/-!` block can never attach to a declaration no matter how it is positioned,
so the tempting fix on `henkin_bfmcs` (delete the stray blank line between the block and the
declaration, "re-attaching" it) is a non-fix that changes nothing the linter sees. All three
needed a genuine `/-- … -/` authored, with the section doc left in place as a section doc. Check
the comment opener before concluding that a `docBlame` finding means no prose exists.

### The `runLinter` output format has three traps

Each of these silently produces a wrong count rather than an error, which is the dangerous kind
of defect for a task whose entire gate is a differential count:

1. The section header opens with `/-`, **not** `/--`. A `/--`-anchored regex matches nothing at
   all, and the parse comes back empty rather than failing.
2. `LINTER FAILED` rows come in two shapes and both must be captured: a positioned
   `path:line:col: error: <decl> LINTER FAILED:` form (78 rows) and a positionless
   `#check <decl> /- LINTER FAILED` form (37 rows). Capturing only the first reads 78 instead of
   115. `LINTER FAILED` also appears *mid-message*, never at the start, so a `startswith` test
   files every one of them under `simpNF`.
3. `baseline/runlinter-findings.json` folds its 115 `LINTER FAILED` rows into its `simpNF` 116,
   while later artifacts break them out. A naive per-linter diff therefore reports a spurious
   `simpNF -115`. `runlinter.py` reclassifies by message text on *both* sides of a diff.

Also: `runLinter` takes about 40 seconds on this machine, not the ~7 minutes the plan budgeted,
so gating it per phase boundary cost far less than planned.

## Accepted residuals

Written up in full in `RESIDUALS.md`. In the 174-file scope: `unusedInstInType` (union) **156**
sites in 34 files, `runLinter unusedArguments` **112** sites in 28 files, and **6**
`simpNF LINTER FAILED` artifacts.

The acceptance rests on a documented architectural reason rather than on effort. Every one of the
156/112 findings is a `[Fintype sig.preds]` or `[DecidableEq sig.preds]` binder on a
`MonadicSignature`-parametric declaration, and `MonadicFO.lean`'s own `MonadicSignature` docstring
records why those instances cannot live on the structure: the expansion alphabet `E[Σ]` of
Rabinovich Def 4.1 adjoins every `TL(U,S)`-formula over `Σ` as a fresh atom and is genuinely
infinite. Finiteness and decidability are therefore threaded explicitly, per site, by design — the
binders are part of the stratified API's contract, and removing the locally-unused ones would make
a family of declarations that are used together carry mutually inconsistent signatures.

The 6 `LINTER FAILED` rows are not simp-normal-form violations at all; they are the `simpNF`
linter's own `simp` call exhausting its recursion limit, rooted in the looping `@[simp] neg_unfold`
at out-of-scope `Automation/Normalization.lean:69`, whose RHS `φ.imp bot` is definitionally its own
LHS pattern. That attribute is deliberately left in place.

No `sorry` was introduced, no axiom added, and no proof left partial.

## Plan Deviations

- **Phase 7, `unusedSectionVars` vs the Phase 9 residual decision — CONFLICT, resolved in favour
  of Phase 7.** The linter's own remedy for `unusedSectionVars` is `omit [Fintype sig.preds]
  [DecidableEq sig.preds] in`, and those are exactly the binders that produce the
  `unusedInstInType` / `unusedArguments` findings Phase 9 decided to *accept* as residuals.
  Clearing one necessarily clears part of the other; the two plan clauses cannot both be
  honoured. Phase 7's task list names `omit` explicitly, so the more specific clause governs and
  the omits stand. Effect: `unusedInstInType(union)` 187 → 156, `runLinter unusedArguments`
  203 → 122 whole-library / 193 → 112 in scope, concentrated in `AggregateOffDiagK1.lean`
  (28 → 14), `ExteriorNavFutK1.lean` (10 → 1) and `ExteriorNavPastK1.lean` (9 → 1). No signature
  was hand-edited, no proof changed, and no sibling-owned category moved. Phase 9's ledger is
  written against the new figures and Phase 10's "unchanged" check was re-baselined to
  "unchanged since Phase 7", so that any *further* movement is still caught as an unintended edit.
- **Phase 9, residual spot-checks — altered.** The plan named `parametric_task_rel_*` and
  `parametric_canonical_truth_lemma` as the declarations to cite in the ledger. Neither is a
  finding any more — both were among the ones Phase 7's omits cleared. `RESIDUALS.md` cites
  measured current examples instead (`sf_disj_truth_mu`, `rank_type_separator`,
  `kampPrior_site_env_bridge`).
- **Phase 9, out-of-scope handoffs — extended.** One the plan did not anticipate: a deprecated
  Mathlib **import** (`Mathlib.Data.Finite.Card` at `MonadicFO.lean:7`). It is the lone
  `(uncategorized)` row in the final census, is unchanged since baseline, and belongs to the
  deprecation task rather than this one.
- **Phase 8, docstring count — altered.** 57 docstrings were written for the 52 findings.
  `EnrichedEvent.h_untl` and `EnrichedEventSince.h_snce` were not flagged while their three
  sibling fields each were; documenting three of four fields and leaving the fourth bare is worse
  than documenting all four, so both were written. The other overage is multi-line docstrings the
  linter counts once.
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
