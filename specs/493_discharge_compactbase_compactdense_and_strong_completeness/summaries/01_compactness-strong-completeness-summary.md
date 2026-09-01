# Implementation Summary: Discharge CompactBase/CompactDense and Collect Strong Completeness

- **Task**: 493
- **Plan**: plans/01_compactness-strong-completeness.md
- **Status**: [COMPLETED]
- **Phases**: 5 of 5 completed

## What Was Done

### Phase 1 — the six theorems

`FormalSystem/Metalogic/Compactness.lean` (new, 166 lines) proves, unconditionally and
sorry-free:

| Declaration | Line | Route |
|---|---:|---|
| `modelExistenceBase` | 81 | ultraproduct over `Idx Γ` at `idxUF Γ`, truth read off by `los_truthAt` |
| `modelExistenceDense` | 107 | same, with the per-index density family reinstalled for instance synthesis |
| `compactBase` | 127 | `compactBase_of_modelExistence modelExistenceBase` |
| `compactDense` | 131 | `compactDense_of_modelExistenceDense modelExistenceDense` |
| `strongCompletenessBase` | 141 | `strongCompletenessBase_of_compact compactBase completeness_base` |
| `strongCompletenessDense` | 148 | `strongCompletenessDense_of_compact compactDense completeness_dense` |

Wired into `FormalSystem/Metalogic.lean` (one import). The research report's probe compiled
verbatim on the first attempt; no proof search was required.

### Phase 2 — Lean docstrings

`SetConsequence.lean`, `StrongCompleteness.lean` and `Metalogic.lean` corrected. The three-way
status taxonomy (Discrete refuted / Base+Dense open / Dedekind unavailable) collapsed to two-way
(Discrete refuted / Base+Dense **proved** / Dedekind unavailable) in lockstep across all four
mirrors. `StrongCompleteness.lean`'s chronicle-obstruction argument was REFRAMED, not deleted:
the `deferralClosure` / `subformulaClosure` `Finset` obstruction is intact and now explains why
the ultraproduct route is what it is.

### Phase 3 — documentation

`README.md`, `docs/project-info/known-limitations.md`,
`docs/project-info/implementation-status.md`, `docs/user-guide/architecture.md`,
`docs/reference/API_REFERENCE.md`, `docs/development/MODULE_ORGANIZATION.md`,
`FormalSystem/Metalogic/README.md`. `FormalSystem/Semantics/README.md` confirmed (not assumed)
to need no change.

### Phase 4 — paper-side record

`specs/paper-definitions-of-record.md`'s `cor:tm-completeness` row now shows item (ii) resolved
and item (i) live. Four dated retirement/correction notes added to the archived author memo
without rewriting its body. `typst/FormalFoundations.typ` records that the three named
statements are theorems for Base and Dense.

### Phase 5 — gate wiring

`scripts/check-module-invariants.sh` C14(ii) baseline enlarged with `strongCompletenessBase` and
`strongCompletenessDense`, both heredocs edited together and in the same order. The axiom audit
is now a standing gate rather than a one-off observation.

## Verification

| Check | Result |
|---|---|
| `lake build` | exit 0 |
| `#print axioms`, all six | `[propext, Classical.choice, Quot.sound]` |
| `sorryAx` | absent from the entire build output |
| C14 | PASS against the enlarged baseline |
| C8 | PASS |
| `scripts/module-invariants-manifest.txt` | unmodified, as required |
| `*_of_compact` engine parameters | intact (`StrongCompleteness.lean:318`, `:346`) |
| `typst compile typst/FormalFoundations.typ` | exit 0 (font warnings only) |
| Tree-wide re-grep sweep | no surviving now-false status claim in any in-scope file |
| Task-number citations introduced | none |

## Pre-existing failures, NOT caused by this task

- **C6** fails on three unreachable modules — `FormalSystem/Metalogic/TMCompletenessReduction.lean`,
  `FormalSystem/Semantics/BLSchemaValidity.lean`, `FormalSystem/Semantics/LexCarrier.lean` —
  all untracked files created by concurrent sessions during this implementation.
  `FormalSystem.Metalogic.Compactness` is NOT among them: it is reachable via `Metalogic.lean`,
  exactly as designed.
- **`scripts/readme-lint.sh`** exits 1 on a missing `FormalSystem/Semantics/Ultraproduct/README.md`
  and on `FormalSystem/Automation/README.md` inventory gaps. Check 2 does not list
  `Compactness.lean`, so this task's own obligation there is met.
- **`scripts/typst-sync-check.sh`** exits 1 on `ValidOver` / `ValidOverInt` in
  `typst/chapters/p2-frame-classes.typ`, a file this task did not touch; both identifiers were
  removed from `FormalSystem/` by the validity refactor. Checks 2 and 3 report 0 mismatches.

## Plan Deviations

- **Every line-number citation was re-derived rather than copied**, as the plan instructed. The
  plan's own "live" values were themselves stale by implementation time. Actual values used:
  `SetConsequence.lean` `StrongCompletenessBase` :306, `CompactBase` :314, `ModelExistenceBase`
  :335, `StrongCompletenessDense` :352, `CompactDense` :359, `ModelExistenceDense` :379,
  `not_setConsistent_of_setDerivable_bot` :280; `StrongCompleteness.lean` is 943 lines, not 924.
- **The author memo is not tracked by git.** `.gitignore:73` excludes `specs/archive/`. All four
  dated notes are present on disk but appear in no commit.
- **`typst/generated/status.typ`** was rewritten as a side effect of running
  `scripts/typst-status-counts.sh` (stamp commit/date only; all counts unchanged) and was
  deliberately left unstaged as out of scope.
- **`API_REFERENCE.md` gained a full `Compactness` module section**, not merely the table rows
  the plan called for; the module warranted its own entry alongside the other Metalogic modules.
