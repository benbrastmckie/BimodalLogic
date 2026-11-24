# Implementation Summary: Task #973

- **Task**: 973 - Theorem library: countermodels
- **Status**: [COMPLETED]
- **Started**: 2026-11-24T12:08:25Z
- **Completed**: 2026-11-24T13:31:00Z
- **Effort**: ~1.4 hours
- **Dependencies**: `theorem_library_layout_and_registry` (landed); `theorem_library_tableau_pipeline` (landed, sequencing-only)
- **Artifacts**: plans/01_theorem-library-countermodels.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The countermodel half of `BimodalLib` now exists: one `PointTruth`-generic entry type whose
`refutation` field the kernel checks and whose `profile_eq` field makes the filing computed, 13
registered rows covering all three admitted grades, both TRANSFER theorems, the eight branch
gates bundled as one decidable `Bool` with its bridge theorem, lookup of an inference up to
renaming of atoms, a generated index section with a per-grade census, a build invariant over the
near-miss field, tests in both directions, and the reference page documenting the grades. All
nine plan phases are `[COMPLETED]`; `BimodalLib/` carries no `sorry`, no new `axiom` and no
`native_decide`, and `FormalSystem` imports nothing from `BimodalLib`.

## What Changed

- `BimodalLib/Countermodel.lean` — Created. `GenericConsequenceIn` (the premise-bearing
  consequence relation over `PointTruth`, which existed for neither language);
  `genericConsequenceIn_nil` (the empty-premise bridge that admits the existing corpus without
  restatement); `HasProfile` with both instances; `inferenceProfile`; `Grade` and `Grade.name`;
  the `CountermodelEntry` structure; `fragment` and `cellName`.
- `BimodalLib/Countermodel/Transfer.lean` — Created. `not_genericConsequenceIn_of_le` (transfer
  down the frame-class order, with the order checked by the kernel);
  `not_genericConsequenceIn_ofFormula` (L into L⁺ through `plusTruthAt_ofFormula`);
  `inferenceProfile_map_ofFormula`; `hasProfile_eq_profileF`/`hasProfile_eq_profileP`;
  `CountermodelEntry.transferLe` and `.toPlus`.
- `BimodalLib/Countermodel/Gates.lean` — Created. `gatesOK` and
  `not_genericConsequenceIn_of_gatesOK`.
- `BimodalLib/Countermodel/Lookup.lean` — Created. `sameUpToRenaming` and its `PlusFormula`
  companion, `inferenceAsFormula`, `inferenceSameUpToRenaming`, `lookupCountermodel?`,
  `lookupCountermodelP?`, `isRefutedUpToRenaming`.
- `BimodalLib/Countermodels/TemporalBoolean/ZTime.lean` — Created. Two SEMANTIC rows (`cmDensity`,
  `cmDenseIndicator`), the CERTIFICATE row `cmBotUntl`, and the named `rfl` bridge
  `genericConsequenceIn_eq_semanticConsequenceIn`.
- `BimodalLib/Countermodels/TemporalBoolean/Dense.lean` — Created. `cmPriorUGap`, `cmSep`.
- `BimodalLib/Countermodels/TemporalBoolean/RTime.lean` — Created. `cmPriorUZ`, `cmZ1`.
- `BimodalLib/Countermodels/ModalBoolean/Base.lean` — Created. `cmStabBox`, with `nearMiss`
  naming the MS axiom constructor it is the converse of.
- `BimodalLib/Countermodels/ModalTemporalBoolean/Base.lean` — Created. The four remaining
  stability refutations, three with a resolvable `nearMiss`.
- `BimodalLib/Countermodels/Boolean/GatedTableau.lean` — Created. The explicit branch data, the
  `decide`-discharged `gates_ok`, and the GATED TABLEAU row `cmGatedImpBot`.
- `BimodalLib/Countermodels/Complete.lean` — Created. The aggregator and
  `assert_near_miss_targets_resolve`, run there.
- `BimodalLib/Index.lean` — `CountermodelRow`, `countermodelRow`, `countermodelRows`,
  `renderCountermodels`, `gradeOfExpr?`, `optStringOfExpr?`, `nameFromExpr?`, `gradeOrder`, wired
  into `renderIndex`.
- `BimodalLib/Subsumption.lean` — The four-function `PlusFormula` companion matcher, with the `⊡`
  case.
- `BimodalLib.lean`, `BimodalLib/INDEX.md`, `BimodalLib/README.md` — Imports, the regenerated
  index (+80 lines), and three module-table rows.
- `Tests/BimodalLibTest/CountermodelTest.lean`, `GateAgreementTest.lean`,
  `Fixtures/UnresolvedNearMiss.lean`, `Tests/BimodalLibTest.lean` — Created and wired.
- `typst/generated/status.typ` — Regenerated: `tests-file-count` 106 -> 109,
  `tests-line-count` 31327 -> 31641.
- `docs/reference/bimodal-lib.md`, `records/theorem-library.md` — The half documented; the record
  cut to what remains unimplemented.

## Decisions

- **The entry type is generic over `PointTruth`, not duplicated per language.** `ValidIn` and
  `PlusValidIn` are definitionally `GenericValidIn`, so genericity costs nothing at the statement
  side. The recorded price — one explicit per-language branch, because `evalExpr` is monomorphic
  — came to four lines in `countermodelRows`, so the plan's two-concrete-row-types fallback was
  not needed.
- **Rows are admitted at maximal frame classes only.** The 14 concrete class-tag refutations in
  the tree collapse to 6 rows under this rule, which is what keeps the transfer theorem
  load-bearing rather than decorative.
- **The gated grade is realized on explicit branch data, not by deciding `buildTableau`.** No
  gate theorem requires the branch to have come from the tableau construction, so the cheap
  shape is also the sound one.
- **`nearMiss` names a declaration and the asymmetry is recorded, not engineered away.**
  `TheoremEntry` is `Formula`-only by type, so the bounded laws cannot be registry rows; the
  invariant checks the one direction that is constructible.
- **No `maxRecDepth` bump on the gate discharge.** The research probe used
  `maxRecDepth 10000`; measured, `decide` closes at the default 512, and an unneeded ceiling
  would hide a later regression in exactly the quantity it was raised to protect.

## Plan Deviations

- **Phase 4, "record that this entry's `premises` list is non-empty"** altered: the premise is
  false as measured. `botUntlFamily : WitnessFamily ([] : Context) [botUntl]`, and a compiled
  probe reads `cmBotUntl.premises.length = 0`. The research report had claimed only that this is
  the one row whose refutation goes through a predicate taking a premise list *natively* — a
  claim about `not_consequence_ztime`'s signature, which the plan over-read into a claim about
  this row's own `Γ`. The note records the true fact. **Consequence worth carrying: no row
  landed by this task has a non-empty premise list**, so the `Γ` slot is exercised only by the
  transfer theorems and the lookup.
- **Phase 5, the `linter.style.longFile` baseline** skipped: not triggered. `GatedTableau.lean`
  is 123 lines and `Gates.lean` 99, against a 1500-line limit.
- **Phase 9, the bare-name citation rule** altered: the hand-written docs use bare names and need
  no exemption, but the *generated* `BimodalLib/INDEX.md` emits two dotted names out of row field
  data and cannot be hand-rewritten without staling `library-index.sh --check`. A concurrent
  writer allowlisted both while this phase ran; this dispatch's duplicate append was removed, so
  its net change to `scripts/module-invariants-allowlist.txt` is zero lines.
- **Phase 3 file list** extended by one module: `BimodalLib/Countermodels/TemporalBoolean/ZTime.lean`
  was not in the declared list, because the plan's Scope Hypothesis did not anticipate two
  ZTime-maximal semantic rows. Creating it follows the plan's own governing instruction (file each
  row at `<Fragment>/<FrameClass>.lean`, at its maximal class); it is Phase 4's declared path,
  which Phase 4 then extended rather than created.

## Verification

- Build: Success. `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
  BimodalLib BimodalLibTest --wfail` exits 0 with 0 errors and 0 warnings.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots reports
  `sorry_count: 0`; `BimodalLib/` grep is 0).
- Vacuous count: 0 in this task's files. The 2 repo-wide pattern hits
  (`FormalSystem/Examples/TemporalStructures.lean:495`,
  `FormalSystem/Semantics/PointTransport.lean:163`) are pre-existing and untouched.
- Axiom count: 0 in `BimodalLib/`; the 14 repo-wide hits are pre-existing and untouched. No new
  axiom. `native_decide`: 0 uses (the single grep hit is a docstring saying it is barred).
- Tests: Passed. `lake build BimodalLibTest --wfail` green; the six renaming cases, two
  `PlusFormula` cases, five lookup cases, the per-grade census assertion, four `#print axioms`
  pins, and the gate-agreement pins in both verdicts all compile.
- Files verified: Yes.
- `scripts/check-module-invariants.sh`: the only failing group is C16's roots ceiling,
  byte-for-byte identical to the pre-task baseline at `a76a46f6e`; baseline and final tails both
  read `1 CHECK GROUP(S) FAILED`. C3 PASS (structural sorry inventory ZERO across
  `FormalSystem/`, `BimodalTools/`, `BimodalLib/`), C5 PASS, C20 no FAIL, C26 PASS, B3 PASS.
- `scripts/library-index.sh --check`: index current. Its census reads `semantic` 11,
  `certificate` 1, `gated tableau` 1 — the DONE WHEN clause, read off the generated artifact.
- `scripts/typst-sync-check.sh --counts-only`: `MISMATCH_COUNT=0`.
- **Batch-aware deferral**: the complete gate set was NOT independently run, per this dispatch's
  Batch Gate Deferral directive. The scoped discharge is
  `verify-deploy.sh --only-gate 4 --skip-unchanged` (PASS, 0 failures) plus every
  repository-specific check named above. `verify-touched.sh` was additionally attempted and
  abandoned: its working-tree path derivation picked up a concurrent sibling dispatch's untracked
  `.githooks/*` files and selected 87 agent-system shell suites unrelated to this task's changes;
  it was torn down before reporting.

## Impacts

- The proof mode's unclosed-leaf route now has its entry point: `lookupCountermodel?` reports a
  registered refutation against a leaf, up to renaming of atoms, without closing a goal.
- `BimodalLib/INDEX.md` gains a Countermodels section with a per-grade census, so the library's
  refutation coverage is visible without reading source.
- `assert_near_miss_targets_resolve` runs inside `lake build BimodalLib --wfail`, so a renamed or
  deleted near-miss target now turns the build red.
- A measured hazard for every later `BimodalLib` module: a new module whose basename collides
  with a `FormalSystem` one silently breaks C20 for unrelated files citing the `FormalSystem`
  one. `BimodalLib/Countermodel/Transfer.lean` did exactly this and a concurrent writer fixed it
  forward in `0579cf458`, recording it as the third occurrence of the mechanism.

## Follow-ups

- Bulk admission of the pipeline's 1,047 distinct gated statements, left in
  `records/theorem-library.md` with its two measured obstacles: the data file carries no branch
  or `TimeOrdering`, and ~70 wrapped lines per row against a 1,500-line file linter.
- The EVALUATOR-CHECKED fourth grade, waiting on the evaluator and on
  `records/semantic-proof-mode.md`.
- A basename-collision pre-check on new module paths would catch the C20 class above before CI
  does; nothing warns today at the point the file is added.
- The premise list is matched positionally rather than as a set in the lookup; moot while every
  row has an empty `Γ`, and worth revisiting when the first row with premises lands.

## References

- `specs/973_theorem_library_countermodels/plans/01_theorem-library-countermodels.md`
- `specs/973_theorem_library_countermodels/reports/01_theorem-library-countermodels.md`
- `specs/973_theorem_library_countermodels/handoffs/` — one per phase
- `specs/973_theorem_library_countermodels/issues.jsonl`
- `docs/reference/bimodal-lib.md`, `records/theorem-library.md`, `records/proof-mode.md` (M20)
