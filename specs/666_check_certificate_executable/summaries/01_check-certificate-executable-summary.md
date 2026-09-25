# Implementation Summary: Task #666

- **Task**: 666 - Check certificate executable
- **Status**: [COMPLETED]
- **Started**: 2026-09-24T23:06:00Z
- **Completed**: 2026-09-25T00:40:00Z
- **Effort**: ~1.5 hours (plan estimate: 8.5 hours)
- **Dependencies**: Task 665 (witness-family certificate soundness, COMPLETED); Task 667 (tableau bridge branch gates, COMPLETED)
- **Artifacts**: plans/01_check-certificate-executable.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`lake exe check_certificate` now reads a witness-family certificate as JSON on stdin, rebuilds
the dependently-typed `WitnessFamily` at runtime, runs the four `Decidable` instances the
certificate layer delivers, and prints one JSON line: `{"status":"countermodel","time":t}` or
`{"status":"rejected","failed":[...]}` naming the failed condition, lasso index, position and
formula. All seven plan phases are complete. The tag-format JSON parser was extracted into a
single shared module along the way, removing one of two existing duplicates rather than adding a
third.

## What Changed

- `BimodalTools/JsonParse.lean` — **created**. The tag-format recursive-descent parser
  (`PState`, `mkPState`, `pEof`, `pPeek`, `pAdvance`, `pSkipWS`, `pExpect`, `pString`,
  `pSkipValue`, `pFormula`, `pNat`) moved verbatim out of `TableauBridge.lean`, under
  `namespace BimodalTools.JsonParse`, importing `FormalSystem.Syntax` only.
- `BimodalTools/TableauBridge.lean` — both parser regions deleted; now imports and opens
  `BimodalTools.JsonParse`. Its header and References block were re-pointed accordingly.
- `BimodalTools/CertificateImport.lean` — **created** (563 lines). Holds:
  - `closureList` and **`mem_closureList`** (the one new theorem, closing the
    computable-closure-enumeration obligation that `Finset.toList`'s noncomputability creates),
    and `intRange`;
  - `RawLasso` / `RawCertificate`, whose field names mirror the Lean structures exactly;
  - the envelope parser (`pKeyword`, `pBool`, `pInt`, `pArrayOf`, `pObjectFields`, `pLabel`,
    `pSegment`, `pBxPair`, `pRawLasso`, `pRawCertificate`, `parseCertificate`) and the inverse
    serializer (`RawCertificate.toJson` and friends);
  - `hasFreshAtom`, the atom-shape guard;
  - `bxOf`, `mkLasso`, `mkFamily` — every proof field (`back_ne`, `fwd_ne`, `label_sub`,
    `lassos_ne`) discharged by a `dite`, with `LassoFault` / `StructuralFault` naming each
    violation;
  - `Failure`, `CheckResult`, the four localization scans (`cohFailure`, `fulFailure`,
    `boxFailure`, `targetFailure`), `unlocalized`, `checkRaw`, `checkLine`, and the result
    serializer.
- `BimodalTools/CheckCertificateMain.lean` — **created**. `main` only: read stdin, print one
  JSON line. Its module docstring states the trust model.
- `Tests/BimodalToolsTest/CertificateImportTest.lean` — **created**. 21 `#guard` rows.
- `lakefile.toml` — new `[[lean_exe]] name = "check_certificate"`,
  `root = "BimodalTools.CheckCertificateMain"`, `supportInterpreter = true`; two count updates.
- `BimodalTools.lean`, `Tests/BimodalToolsTest.lean` — aggregator imports.
- `BimodalTools/README.md` — new `## Certificate re-verification protocol` section beside the
  tableau bridge protocol; regenerated inventory block with descriptions for the three new
  modules.
- `Tests/BimodalToolsTest/README.md` — regenerated inventory row.
- `.github/workflows/ci.yml`, `scripts/check-copyright-headers.sh`,
  `scripts/check-module-invariants.sh`, `scripts/module-invariants-manifest.txt` — comment-only
  count updates.

### Theorems and definitions

One new theorem, `BimodalTools.CertificateImport.mem_closureList`, proved by the single `simp`
call the research spike found, depending only on `[propext, Classical.choice, Quot.sound]`.
Everything else added is a definition. No `sorry`, no new axiom, no `noncomputable` marker.

## Decisions

- **The verdict is the four top-level instances, nothing else.** `checkRaw` evaluates
  `decidableLocalCoherentLab`, `decidableFulfillingLab`, `decidableBoxFaithful` and
  `decidableTarget` — named explicitly via `@Decidable.decide _ (...)` rather than left to
  synthesis — short-circuiting on the first `false`. The localization scans run only on the
  reject path and range over exactly the units those instances decide, so they cannot contradict
  a verdict. An instance that says `false` with an empty scan produces an explicit
  `"unlocalized"` record rather than an empty `failed` list.
- **Structural violations are `rejected`, malformed input is `error`.** An empty `back`/`fwd`,
  an empty `lassos` list, a label outside `closureOf (Γ ++ Δ)`, or a fresh-indexed atom is
  certificate content failing a precondition.
- **The atom-shape guard is enforced, not merely documented.** `mkFamily` rejects a
  fresh-indexed atom with `StructuralFault.atomNotBase`. It is vacuous on parsed input by
  construction (`pFormula` can only build base atoms) but not on a `RawCertificate` assembled in
  Lean, which is how the tests and any in-process producer reach the checker.
- **Only the first failure per condition is reported.** The plan names an all-failures
  `--verbose` mode as a future extension; the scan finds four consecutive failing positions on
  the separation family and reports the first, `(0, -2, p U q)`.

## Plan Deviations

- None (implementation followed plan). Three mechanical adjustments were made inside plan steps
  and are recorded rather than treated as deviations:
  - `closureList` / `mem_closureList` needed fully-qualified
    `FormalSystem.Syntax.Formula.subformulas` and `FormalSystem.Syntax.subformulaClosure`,
    because `DataExport`'s import closure brings a same-named tableau `subformulaClosure` into
    scope. Same definitions, disambiguated.
  - Doc comments that preceded a `#guard` became line comments: a `/-- -/` cannot attach to a
    command.
  - The fresh-atom test row matches on the constructor instead of comparing two `Except` values,
    because `Except _ (WitnessFamily ..)` has no `DecidableEq` (its box guess is a function).
  - Phase 3's "temporary `#eval`" verification was performed through the built binary instead,
    which exercises the same functions end to end and leaves no temporary declaration behind.
- **Scope Hypothesis corrected by evidence, as the plan instructed.** The plan predicted six
  prose sites for the executable-root count and `15 -> 17` for the non-`Main` module count. The
  confirming grep found three further present-tense spelled-out counts in
  `scripts/check-module-invariants.sh` and one in `.github/workflows/ci.yml`; and the non-`Main`
  count was already stale at 15 when the true pre-task figure was 16, so it becomes 18, not 17.
  Dated historical measurements were deliberately left alone, as was
  `docs/development/PUBLICATION_REFACTOR.md`.

## Verification

- Build: **Success**. `lake build` (default `FormalSystem` target) exit 0, 0 errors;
  `lake build BimodalTools --wfail` exit 0 at zero warnings; `lake build BimodalToolsTest
  --wfail` exit 0 at zero warnings with all 21 `#guard` rows passing; every one of the 14
  `lean_exe` roots compiled the way CI enumerates them.
- Sorry count: **0** (`lean-sorry-census.sh` over all four source roots).
- Vacuous count: **0 attributable to this task**. The census pattern reports one hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`, which is present unchanged at the
  pre-task commit `f929bcbf6` in a file this task never touched.
- Axiom count: **14, unchanged** from the pre-task baseline at `f929bcbf6`.
- `bash scripts/check-module-invariants.sh` — **ALL CHECKS PASSED**, including C25N (14 roots,
  each `PascalCase(target)Main`) and INV (inventory current).
- `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools` — 599 conforming,
  0 nonconforming.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` — PASS.
- Acceptance, end to end through the built binary:
  - the non-vacuity family serialized to JSON → `{"status":"countermodel","time":0}`;
  - the separation family → `{"status":"rejected","failed":[{"condition":"fulfilling",
    "lasso":0,"position":-2,"formula":{...p U q...},...}]}` — the research spike's tuple exactly;
  - a label outside the closure → `rejected` under `structural`, not a parse error;
  - malformed input → `{"status":"error","message":...}`.
- **Measured runtime**: on a padded positive family with `back` 50, `mid` 1, `fwd` 50 (total
  segment length **101**, 10-formula labels), the compiled binary took **61, 61, 62 ms** on one
  run of three and **99, 71, 91, 67, 70 ms** on a later run of five — all well under the
  one-second acceptance bar. (The interpreter measured ~68 ms in the research spike.)
- Files verified: Yes.

## Impacts

- The model checker half of the dual-verification architecture now has a re-verification target
  to emit against, with the wire schema documented beside the tableau bridge protocol it sits
  next to.
- `BimodalTools/JsonParse.lean` is a shared parser both JSON interfaces now use. The tableau
  bridge's own copy is gone; `BenchmarkOracleMain.lean`'s replication survives, deliberately out
  of scope.
- `check_certificate` is the 13th `BimodalTools` executable root and the 14th `lean_exe` target;
  CI picks it up automatically through `scripts/lake_targets.py exe-roots`, so no CI step logic
  changed.

## Follow-ups

- Retire `BimodalTools/BenchmarkOracleMain.lean`'s verbatim parser copy the same way
  `TableauBridge.lean`'s was retired. It is an exe root, so nothing imports it and the
  duplication is inert; this was a named non-goal here.
- A `--verbose` mode emitting every failing `(lasso, position, clause)` rather than the first,
  and a JSONL batch/REPL mode mirroring `tableau_bridge`. Both named as future extensions.
- The research report's context-extension recommendation stands: a single statement of what a
  compiled `Decidable` instance returning `true` licenses, versus a kernel-checked proof. This
  executable is the third artifact to need it; today the statement is duplicated in
  `CheckCertificateMain.lean`'s docstring, `CertificateImport.lean`'s docstring and
  `BimodalTools/README.md`.

## References

- `specs/666_check_certificate_executable/plans/01_check-certificate-executable.md`
- `specs/666_check_certificate_executable/reports/01_check-certificate-executable.md`
- `specs/666_check_certificate_executable/handoffs/` — one per phase
- `BimodalTools/README.md` — the wire schema
- `FormalSystem/Metalogic/Decidability/WitnessFamily/{Basic,Predicates,Decide,Examples}.lean`
