# Phase 4 Handoff — task 493

## Immediate next action
Phase 5: C14 baseline enlargement in `scripts/check-module-invariants.sh`, then acceptance sweep.

## State
`specs/paper-definitions-of-record.md` `cor:tm-completeness` row now marks item (ii) resolved
(dated) and item (i) live; the row is not deleted. Four dated notes added to the archived author
memo (D1, D2, the `undischarged` verification rows, the "Confirmed absent" line); no memo body
rewritten. `typst/FormalFoundations.typ` Representation-theorem sketch gained a sentence
recording that the three named statements are theorems for base and dense; the `#leansrc` anchors
pointing at `Metalogic.SetConsequence` were left as-is, since the declarations are still defined
there.

`typst compile typst/FormalFoundations.typ` exits 0 (font warnings only).

## Deviations
- The author memo is under `specs/archive/`, which `.gitignore:73` excludes. The four dated
  notes are present on disk but are not tracked by git and so do not appear in any commit.
- `typst/generated/status.typ` was rewritten as a side effect of running
  `scripts/typst-status-counts.sh` (a stamp-commit/date refresh only; every count unchanged).
  Deliberately left UNSTAGED — it is a generated artifact refresh, not part of this task's scope.

## Known pre-existing lint state (NOT caused by this task)
`scripts/typst-sync-check.sh` exits 1 on two check-1 violations, `ValidOver` and `ValidOverInt`
in `typst/chapters/p2-frame-classes.typ` — a file this task did not touch. Both identifiers were
removed from `FormalSystem/` by the validity refactor. Checks 2 and 3 report 0 mismatches.
