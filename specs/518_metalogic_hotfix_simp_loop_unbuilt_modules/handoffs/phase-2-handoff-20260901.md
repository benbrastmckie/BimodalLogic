# Phase 2 handoff — task 518

**Done**: Three markdown sites corrected to name `Formula`'s six real constructors and the
camelCase derived names.
- `FormalSystem/README.md` — both operator tables replaced by a cross-reference to the top-level
  README's Operators section plus an explicit six-constructor statement and the camelCase name
  list.
- `FormalSystem/Syntax/README.md:19` — corrected six-constructor list written **inline** (not a
  link), per the plan, because top-level `README.md:32` says "5 primitive connectives".
- `FormalSystem/Metalogic/Core/README.md:114,118` — **unplanned third site**;
  `Formula.all_future`/`Formula.all_past` -> `Formula.allFuture`/`Formula.allPast`.

**Scope hypothesis**: REFUTED (7 files, not 2). Four are deliberately untouched — see the plan's
rewritten Scope Hypothesis for the per-file reasoning (`EnrichedFormula` is a live different type;
two known-broken benchmark modules; one comment-only file).

**Verification**: C5, C12, C13 all PASS. C6 still the only FAIL (expected until Phase 5).

**Next**: Phase 3 (six typst `sorryAx` regions in `typst/FormalFoundations.typ`).
