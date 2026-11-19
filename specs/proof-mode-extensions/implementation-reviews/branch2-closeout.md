# Branch 2 closeout

Scope: P3 on `feat/proof-mode-temporal`, stacked on rewriting commit `fc85c61`.
The semantic milestones remain active work on branch 3.

## Independent reviews

Codex's initial source grade is **86.45/100**; Opus 5.5's initial grade is **78/100, NO-GO**.
The original [Codex](codex-branch2.md) and [Opus](opus-branch2.md) reviews are retained.
Opus's [source closeout](opus-branch2-closeout.md) closes M1–M3, conditional on the actual checks.
Grades are subjective and unchanged by agreement; a grade never overrides a defect.

## Required fixes

- M1: `lapply` collects telescope parameters and leading elaboration holes, but exposes only
  this invocation's new holes. Prop/native-proof obligations are locked; data parameters stay
  inferable and follow the premises. Generic `futureConsequence` is exercised compactly.
  This test was added after the fix and was not observed red against the old implementation.
- M2: Dense Until unfolding refusal and conclusion-only reflection refusal now have positive
  controls. The reflection refusal matches the reflected conclusion but lacks its context.
- M3: long lines were wrapped and the inclusive definitions grouped before the final review.
- Exact dual folding refuses assignments to existing formula metavariables. Pure kept-step rules
  moved to the theorem layer; scoped selection/substitution is shared by modal/temporal commands.

## Other dispositions

The inclusive native equivalence is now exercised; literal equalities remain public. README
placeholders and stale staging descriptions were replaced. The legacy abstract `lstep` gate is
documented, preserving existing scripts. Reflection elaborates its term once and refuses
unresolved fact parameters. The application core prunes assigned head goals before counting
new premises. Instance-implicit binders attempt normal Lean instance synthesis. Errors from
side-condition resolution retain their cause instead of being relabelled concrete falsity.
Both expression-based application callers capture the counter before elaboration.

One closeout suggestion is inapplicable: `Language` is the rigid `.tm`/`.plus` datatype, not a
Lean expression or metavariable, so its structural equality is the appropriate comparison.

## Validation

- `lake build FormalSystem BimodalTest.Automation.ProofModeTest
  BimodalTest.Automation.ProofModeExtensionsTest --wfail`: passed on final source. Cached job
  totals include dependencies; only affected modules recompiled. No repeated clean builds.
- `lake exe runLinter FormalSystem`: passed after the source fixes, with no suppressions.
- Generated root, README inventories and book status counts refreshed. `typst-sync-check.sh`:
  all four checks passed. Relevant README lint passed; `git diff --check` clean.
- Final `check-module-invariants.sh --no-build`: ALL CHECKS PASSED. Compilation and linter
  gates skipped by that mode were run explicitly above.

No semantic-to-native conversion, completeness extraction, new axiom or test admission is used.
