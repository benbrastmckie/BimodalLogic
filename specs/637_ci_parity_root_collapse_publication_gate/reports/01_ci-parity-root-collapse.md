# Research Report: CI parity, root collapse and publication gate

**Task**: 637 - CI parity, root collapse and publication gate
**Started**: 2026-09-21T00:00:00Z
**Completed**: 2026-09-21T00:00:00Z
**Effort**: large (7 independent work items, 2 of which carry measured pre-existing debt)
**Dependencies**: 636 (complete)
**Sources/Inputs**: - Codebase at HEAD `657c41892`; Mathlib v4.33.0-rc1 sources under `.lake/packages/mathlib/` (`scripts/mk_all.lean`, `scripts/lint-style.lean`, `Mathlib/Tactic/Linter/Header.lean`, `Mathlib/Tactic/Linter/Style.lean`, `Mathlib/Tactic/Linter/TextBased.lean`, `Mathlib/Util/GetAllModules.lean`, `Mathlib/Init.lean`); `docs/development/PUBLICATION_REFACTOR.md` (Phase 8, follow-up H); live measurement via `lake exe mk_all`, `lake exe lint-style`, `lake exe runLinter`, `scripts/check-module-invariants.sh --no-build`, `scripts/warning-budget.py`, `scripts/measure-refactor-partitions.py namespace-audit`
**Artifacts**: - specs/637_ci_parity_root_collapse_publication_gate/reports/01_ci-parity-root-collapse.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The root collapse is cheap; what it switches on is not.** `lake exe mk_all --lib FormalSystem`
  works today (verified: the executable builds, `--check` correctly reports the root out of date,
  and a generated-then-restored root was produced and inspected). But Mathlib's
  `linter.style.header` gates itself on `isInLibraryRoot` — *does `./FormalSystem.lean` **directly**
  import this module* — so today it is live on exactly one module and inert on the other 503. The
  collapse turns it on for all of them at once, under CI's existing `--wfail`. **22 latent findings
  measured** (16 files whose first non-import command is not a module docstring, 6 `import Lean`
  broad imports). These must be cleared **in the same change as** the collapse or CI goes red.
- **`mk_all` is usable for `FormalSystem` only.** It cannot generate `BimodalTools.lean` (it would
  import all 12 `*Main` modules, and two `main` declarations cannot coexist) and it cannot generate
  either test aggregator (it resolves a library name as a repo-root *directory*, and
  `BimodalTest/` / `BimodalToolsTest/` live under `Tests/`). Scope the new check to
  `--lib FormalSystem`; the other three aggregators stay hand-maintained under C8.
- **`lint-style-action` costs 362 findings across 87 files** post-collapse (measured, not
  estimated): 258 unicode-allowlist findings on this library's own notation (`⟐` ×115, `⃗` ×75,
  `⟺` ×28, `Ĝ` ×23, …) and 103 trailing-whitespace findings. The whitespace half is free
  (`lake exe lint-style --fix`). The unicode half needs a **user decision** (disable
  `linter.unicodeLinter` in `lakefile.toml`, vs. seed `scripts/nolints-style.txt`, vs. defer
  adoption).
- **The publication-gate untracking item is already done.** `CLAUDE.md`,
  `.claude-extensions.json` and `.syncprotect` were untracked and gitignored in
  `6ac3b3844`; `.gitattributes` has never existed. `CITATION.cff` already reads
  `version: "1.0.0"` / `date-released: "2026-09-07"`. What remains for the gate is the maintainer's
  `v1.0.0` tag alone (no tags exist yet).
- **The C6 manifest holds 14 entries, not the 12 the description implies.** Nine clear
  automatically the moment the generated root imports everything; of the remaining five, two clear
  as a side effect, one is a vestigial import line, one needs a small module split, and one needs a
  decision about five top-level `#eval`s.
- **Re-measured at HEAD**: C16 widened scope is **170 findings across 13 of 17 roots** (the
  script's recorded `179`/14-root table is pre-split and stale). C28's warning budget is **0
  warnings across 0 files** even after building every tooling root — so the recorded reason for
  withholding `--wfail` from the two tooling CI steps no longer holds.

## Context & Scope

Phase 8 of the publication-refactor programme (`docs/development/PUBLICATION_REFACTOR.md`,
follow-up **H**). Seven separable work items, researched for feasibility, cost and ordering:

1. Collapse the two-level root into one `mk_all`-generated `FormalSystem.lean`, absorbing
   `FormalSystem/FormalSystem.lean`.
2. Empty the C6 unreachable-module manifest.
3. Add `mk_all --check` as a harness check plus a CI step.
4. Add `lint-style-action`.
5. Add a tag-triggered release workflow.
6. Adopt cslib's module-size policy text in `ORGANISATION.md`.
7. Test whether `linter.style.header` under `--wfail` retires `check-copyright-headers.sh`.

Plus three folded-in items from the dispatch's post-relocation revision: re-measure C16 and decide
`ENFORCE_C16_ROOTS`; decide `--wfail` on the two tooling CI steps and update the C28 note; settle
the eight `unrelated` namespace-audit files.

Not researched (outside this task): the Lean module system (Phase 9), the size splits themselves
(Phase 9), the `v1.0.0` tag itself (maintainer).

## Findings

### Codebase Patterns

**The two-level root today.** `FormalSystem.lean` (repo root, 51 lines) carries an Apache header, a
single `import FormalSystem.FormalSystem`, and a docstring. `FormalSystem/FormalSystem.lean` (132
lines) carries the 12 component imports, the long per-component docstring, and
`def version : String := "0.1.0"` in `namespace FormalSystem`.

**`mk_all`'s exact behaviour** (`.lake/packages/mathlib/scripts/mk_all.lean`, and
`Mathlib/Util/GetAllModules.lean`):

- With no `--lib`, `getLeanLibs` returns **every** `lean_lib` of the root package — here
  `FormalSystem`, `BimodalTest`, `BimodalTools`, `BimodalToolsTest`.
- `getAllFiles git ml` treats the library name `ml` as a **directory path relative to the CWD**.
  It never consults `srcDir`. `BimodalTest` and `BimodalToolsTest` declare `srcDir = "Tests"`, so
  `walkDir "BimodalTest"` has no directory to walk. A bare `lake exe mk_all` therefore cannot work
  in this repository; `--lib FormalSystem` is mandatory.
- Generated content is `"\n".intercalate (imports) ++ "\n"` — **no copyright header, no
  docstring**. The `set_option linter.style.longLine false` tail is appended only when
  `d == "Mathlib"`.
- The `allModules.erase ml.lean` step erases the path `FormalSystem.lean`, which the walk of
  `FormalSystem/` never produces. So `FormalSystem/FormalSystem.lean` **is** picked up and emitted
  as `import FormalSystem.FormalSystem`. Deleting that file is a precondition, not a nicety.

Verified end to end: `lake build mk_all` succeeded; `lake exe mk_all --lib FormalSystem --check`
printed `The file 'FormalSystem.lean' is out of date`; a real generation produced a 504-line
import-only file (`FormalSystem.Automation` … `FormalSystem.Theorems.TemporalDerived`). The
working tree was restored from a pre-generation copy and the restore verified by `sha256sum -c`
plus a clean `git status`.

**Why `mk_all` cannot cover the other three libraries.**

| Library | Blocker |
|---|---|
| `BimodalTools` | The generated aggregator would import all 12 `BimodalTools.*Main` modules. Two `main` declarations cannot coexist — the same constraint the lakefile header already records for the hand-maintained 13-import `BimodalTools.lean`. |
| `BimodalTest` | `srcDir = "Tests"`; `mk_all` would look for a repo-root `BimodalTest/` directory. |
| `BimodalToolsTest` | Same `srcDir` problem, *and* the double-`main` problem (see C6 below). |

**The header linter's activation gate** (`Mathlib/Tactic/Linter/Header.lean:259`):

```lean
def isInLibraryRoot (modName : Name) : IO Bool := do
  let rootPath := (modName.getRoot.toString : System.FilePath).addExtension "lean"
  if ← rootPath.pathExists then
    let res ← parseImports' (← IO.FS.readFile rootPath) ""
    return res.imports.any (·.module == modName)
  else return false
```

A **direct** import check against `./<Root>.lean`. `linter.style.header` is a member of
`linter.mathlibStandardSet` (`Mathlib/Init.lean`), which `lakefile.toml` enables package-wide via
`weak.linter.mathlibStandardSet = true`, and every library module transitively imports
`Mathlib.Init` through `FormalSystem/Init.lean` — so the linter *is* registered and *is* enabled;
it is the root-membership gate alone that keeps it silent. Consequences:

| Tree | Covered by `linter.style.header` today | After the collapse |
|---|---|---|
| `FormalSystem/` | 1 module (`FormalSystem.FormalSystem`) | all 503 |
| `BimodalTools/` | the 13 modules `BimodalTools.lean` imports | unchanged |
| `BimodalTools/*Main.lean` | none (not imported by the root) | unchanged — **never** |
| `Tests/**` | none (`./BimodalTest.lean` does not exist) | unchanged — **never** |

`scripts/check-copyright-headers.sh`'s own header already reasons about this gate, but its stated
premise (`lakefile sets srcDir := "FormalSystem"`, so `./FormalSystem.lean` does not exist) is
**stale** — the lakefile no longer sets `srcDir` for `FormalSystem`, and the root file does exist.
Its conclusion survives the correction: the root directly imports one module.

**Measured latent header-linter debt.** A scanner mirroring the linter's four checks
(`copyrightHeaderChecks`, `broadImportsCheck`, `duplicateImportsCheck`, and the
"first non-import command must be a module docstring" branch at `Header.lean:443`) reports:

| Tree | Files | Findings |
|---|---|---|
| `FormalSystem/` (504 files) | 22 | 16 × docstring-not-first, 6 × broad `import Lean` |
| `BimodalTools/` (25 files) | 0 | — |
| `Tests/` (65 files) | 1 | 1 × docstring-not-first |

The 6 broad imports are `FormalSystem/{Tactic/Attr,Tactic/Meta,Automation/Tactics/Deduction,
Automation/Tactics/Search,Automation/Tactics/UserTactics,Metalogic/Expressiveness/EFGameTactics}.lean`
— all metaprogramming modules for which `import Lean` is genuine. The 16 docstring-position
findings split into three shapes: `assert_not_exists …` first (6 files, all under `Semantics/` and
`MinusLanguage/`), `namespace …` first (9 files, mostly `Kamp/EANegationFix/`), and one
`set_option autoImplicit false` first (`Metalogic/Conservativity/SpCountermodel.lean`). All 16 are
mechanical to fix: move the module docstring above the offending command.

Zero copyright-block findings anywhere — which is the substantive half of the
`check-copyright-headers.sh` redundancy question.

**Import lines are exempt from `linter.style.longLine`.** Two generated import lines are 101
characters (`…Kamp.NfMultiAnchorBridge.SharedWitness.{DisjunctionSpikes,FragmentFoldRight}`), with
22 more in the 91–100 band. This looked like a blocker requiring module renames; it is not.
`Mathlib/Tactic/Linter/Style.lean:471` skips any line for which `isImport line` holds. **Risk
checked and cleared — no renames needed.**

**C6 manifest, measured at HEAD.** 14 live entries (not 12); the harness reports
`all 14 unreachable live module(s) are manifested`, carrying 119 declarations across 2,889 lines.

| # | Manifest entry | Disposition under this task |
|---|---|---|
| 1–3 | `FormalSystem.Metalogic.{Core,Bundle,SoundnessLemmas}` | **Auto-clear.** Importer-less sibling aggregators, kept so that no *content* module imports an aggregator its own contents reach. The generated root importing them introduces no cycle (nothing imports the root). |
| 4 | `FormalSystem.Metalogic.SoundnessLemmas.CoValidity` | **Auto-clear** (inherits reachability). |
| 5 | `…Kamp.NfMultiAnchorBridge.OuterGateFaithful` | **Auto-clear.** The manifest's recorded fix (one import line in `NfMultiAnchorBridge.lean`) becomes unnecessary. |
| 6–9 | `…Decidability.BiLasso.{Extend,Successor,Orbit,Agreement}` | **Auto-clear.** |
| 10 | `BimodalTest.Metalogic.PeriodicExtensionAxiomTest` | **Clears as a side effect.** Its only reason for exclusion was that importing it would make `BiLasso.Orbit` reachable. After the collapse `Orbit` is reachable anyway — add one import to `Tests/BimodalTest.lean`. |
| 11 | `BimodalTest.Metalogic.Decidability.BiLassoSuccessorTest` | **Clears as a side effect**, same reasoning via `BiLasso.Successor`. |
| 12 | `BimodalToolsTest.ProofFirstTests` | **One-line fix.** Its `import BimodalTools.ProofFirstGeneratorMain` (line 12) is vestigial — nothing in the file references `exportToJsonl`, `writeJsonl`, `parseAtoms`, `parseForwardConfig` or `parseOutputPath`. Delete the import, then wire into `Tests/BimodalToolsTest.lean`. |
| 13 | `BimodalToolsTest.FormulaMutatorTest` | **Needs a module split.** It genuinely uses `ContrastivePair` and the mutators, which live in `BimodalTools/ContrastiveGeneratorMain.lean` alongside `main`. Unlike `DatasetGeneratorMain`/`DatasetGenerator`, this root has no non-`Main` sibling. Extract the logic into `BimodalTools/ContrastiveGenerator.lean`, leave `ContrastiveGeneratorMain.lean` as a thin `main`, add the new module to `BimodalTools.lean`, re-point the test. |
| 14 | `BimodalTest.ProofSystem.DerivationBenchmark` | **Needs a decision.** Kept out because its five top-level `#eval`s would print the whole benchmark table on every `lake test`. Recommended: delete the five top-level `#eval` lines (the benchmark `def`s stay callable) and wire it in — this keeps the compile coverage, removes the test-run noise, and needs no archive. Archiving to `Boneyard/` is the precedent-backed alternative (its sibling semantic benchmark was retired that way) but loses the compile check. |

**`lint-style` measured, before and after.** The executable builds and runs in this project today.

| Scope | Result |
|---|---|
| Today (root imports 1 module) | 1 finding — `FormalSystem/FormalSystem.lean:56`, unicode `⃗` (U+20D7), in the file this task deletes |
| Post-collapse (root imports 503) | **362 findings across 87 files**, exit 87 |

Post-collapse breakdown: 258 × "unicode character not on the allowlist"
(`⟐` 115, `⃗` 75, `⟺` 28, `Ĝ` 23, `″` 7, `✗` 4, combining macron 3, `⟸` 3, `Ć` 1, …) and
103 × "This line ends with some whitespace". Zero findings from `modulesUpperCamelCase`,
`modulesForbiddenWindows` or `adaptationNote`.

`⟐` is the library's own limit-closure/diamond notation, live in 19 files including
`FormalSystem/Metalogic/README.md` and the `Independence/` modules. It is not incidental and must
not be rewritten. The text-based linters default to `true` independently of
`linter.mathlibStandardSet` (`TextBased.lean:403,300`) and read their options from
`getLakefileLeanOptions`, i.e. from this repository's own `[leanOptions]` block.

`lint-style` also carries two checks that are **off** by default and would be worth enabling
deliberately rather than by accident: `linter.checkInitImports` (duplicates C24 /
`lake exe checkInitImports`) and `linter.allScriptsDocumented` (would gate `scripts/README.md`
completeness — note `scripts/README.md` is **task 644's declared territory this cycle**).

`scripts/nolints-style.txt` does not exist; `lint-style` warns and proceeds with an empty
exception set.

**C16, re-measured at HEAD** (17 roots: 4 libraries + 13 executables; each root built before
linting, per the note in `MODULE_INVARIANTS.md`):

```
BimodalTest                        67     BimodalTools.TraceExporterMain      5
BimodalTools.DatasetGeneratorMain  33     BimodalTools.EnumBenchmarkMain      5
BimodalTools.MachineAppendixMain   16     BimodalTools.DatasetValidatorMain   2
BimodalTools.ContrastiveGeneratorMain 15  CheckInitImportsMain                1
BimodalTools.TableauBridgeMain     13     BimodalTools.ProofFirstGeneratorMain 1
BimodalTools.BenchmarkOracleMain   10     BimodalTools.BenchmarkAnchorsMain   1
                                          BimodalTools                        1
FormalSystem 0 · BimodalToolsTest 0 · BimodalTools.TableauProofStepsMain 0 · BimodalTools.ProofExtractorMain 0
```

**170 findings across 13 of 17 roots.** This matches the figure in task 632's summary and
supersedes the `179`-across-14-roots table recorded in the C16 header block of
`scripts/check-module-invariants.sh` (that table predates `BimodalTools`/`BimodalToolsTest` and
records `BimodalTest 85`, now 67). The enforced half (`runLinter FormalSystem` against
`scripts/nolints.json`) remains at 0.

**C28 / `--wfail` on the tooling steps.** `python3 scripts/warning-budget.py` reports
`0 warning(s) across 0 file(s)` — re-run *after* this research built `BimodalTools`,
`BimodalToolsTest` and all 13 executable roots, so the trace store covers them. The reason C28's
decision block records for withholding `--wfail` ("the tooling tree carries warnings today that
the library does not") **is no longer true at HEAD**, and that block names exactly this condition
as its revision trigger. `scripts/warning-budget.txt` likewise carries `Baseline total: 0
warning(s) across 0 file(s)`, which also makes the `ENFORCE_C28` header's "The floor is 7, not 0"
note stale.

**Namespace audit** (`measure-refactor-partitions.py namespace-audit`): 286 equal-or-descendant,
171 ancestor, 39 none, **8 unrelated**:

| Module | First namespace | Recorded where |
|---|---|---|
| `FormalSystem.ForMathlib.Order.PFilter` | `Order.PFilter` | docstring prose (upstreaming target; must be Mathlib's namespace) |
| `FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleRealExtension` | `…Metalogic.Bundle` | `## Recorded namespace exception` |
| `FormalSystem.Metalogic.Decidability.BiLasso.Periodic` | `…Decidability.Periodic` | `## Recorded namespace exception` |
| `FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.ChronicleInstance` | `…BXCanonical.Chronicle` | `## Recorded namespace exception` |
| `FormalSystem.Metalogic.WeakCanonical.RealModel.ChronicleRealFlow` | `…BXCanonical.Chronicle` | `## Recorded namespace exception` |
| `FormalSystem.Semantics.FrameClassValidity` | `FormalSystem.ProofSystem` | `## Recorded namespace exception` |
| `FormalSystem.Tactic.Meta` | `FormalSystem.Automation` | docstring prose, no heading |
| `FormalSystem.Theorems.DeductionTheorem` | `FormalSystem.Metalogic.Core` | docstring prose, no heading |

All eight already carry a written reason; five use the standard `## Recorded namespace exception`
heading, three do not.

**References to the absorbed file.** 14 occurrences of `FormalSystem/FormalSystem.lean` or
`FormalSystem.FormalSystem` outside `specs/`:

- `scripts/check-module-invariants.sh` ×3 — B3's two-root loop at line 803 (guarded by
  `[ -f "$f" ] || continue`, so it degrades safely), and C8's `C8_ALLOW_SELFNAMED` entry plus its
  comment at 1205/1215 (the entry becomes dead once the file is gone).
- `FormalSystem/README.md` ×1, `FormalSystem/Metalogic/README.md` ×2 — **both in task 614's
  declared `file_scope` this cycle**.
- `FormalSystem/{Plus,Minus,Star}Language/README.md` ×3 — free.
- `docs/development/DIRECTORY_README_STANDARD.md` ×1 — free.
- `docs/development/PUBLICATION_REFACTOR.md` ×3 — programme prose describing this very work;
  leave as-is.

Each README passage explains the self-named indirection as "load-bearing", so these are
substantive rewrites, not path swaps. C5/C12/C13 will fail on any that are missed.

**`def version` is homeless after the collapse.** `def version : String := "0.1.0"` exists only in
`FormalSystem/FormalSystem.lean` and is referenced by nothing in the tree. It also disagrees with
`CITATION.cff` (`1.0.0`) and with `docs/development/VERSIONING.md`'s release checklist, which
tells the maintainer to "Update version in lakefile.toml" — a field `lakefile.toml` does not have.
There is no `CHANGELOG.md`, though VERSIONING.md's release process references one.

**Release-workflow tooling.** `gh` is available locally; `actionlint`, `act` and `yamllint` are
not. The existing `.github/workflows/docs.yml` is the in-repo model for a non-CI workflow, and its
header documents the prerequisite-checking style this repository favours.

### External Resources

- `lake exe mk_all` — Mathlib's aggregator generator. Downstream usage is explicitly supported
  (`"If you are working in a project downstream of mathlib, use lake exe mk_all --lib MyProject"`).
  Exit code is the number of files it would update, capped at 125.
- `leanprover-community/lint-style-action` — wraps `lake exe lint-style`. Its per-project exception
  file is `scripts/nolints-style.txt`; per-file/per-linter entries are parsed by
  `parseStyleExceptions`.
- `linter.style.header` / `linter.style.longLine` / `linter.unicodeLinter` /
  `linter.trailingWhitespace` — see the source citations above.

### Recommendations

Implementation order matters here; the header-linter debt must be cleared **before or with** the
collapse, not after.

1. **Clear the 22 header-linter findings first** (16 docstring moves, 6 `import Lean`). For the
   six metaprogramming modules, `import Lean` is legitimate; the sanctioned route is a
   declaration-scoped suppression with a reason at the site (C29 requires the reason; C30 forbids
   the blanket form) or narrowing `import Lean` to the specific `Lean.*` modules used. Narrowing is
   preferable — it is what the linter is asking for and it costs no suppression.
2. **Collapse the root**: delete `FormalSystem/FormalSystem.lean`, relocate `def version` (a new
   `FormalSystem/Version.lean` reachable from the generated root, bumped to `"1.0.0"` to agree with
   `CITATION.cff`), run `lake exe mk_all --lib FormalSystem`, rewrite the 6 free README/doc
   passages, and **coordinate with task 614** on `FormalSystem/README.md` and
   `FormalSystem/Metalogic/README.md`. Remove the now-dead `C8_ALLOW_SELFNAMED` entry and B3's
   second loop element — **coordinate with task 643**, which owns
   `scripts/check-module-invariants.sh` this cycle.
3. **Empty the manifest** per the 14-row table above. Items 1–9 are deletions that the collapse
   forces (C6 fails on an entry naming a now-reachable module). Items 10–13 are small, mechanical.
   Item 14 needs the `#eval` decision.
4. **Add the `mk_all` check to the harness as a build-free scanner**, with
   `lake exe mk_all --lib FormalSystem --check` as the full-mode authoritative cross-check. CI runs
   `check-module-invariants.sh --no-build`, so a check that shells out to `lake` joins the
   documented "Known Not-in-CI Gaps" list (C2/C6/C24). The generation rule is a ~15-line Python
   walk (all `.lean` under `FormalSystem/`, sorted, `import ` prefix, trailing newline) compared
   byte-for-byte against `FormalSystem.lean` — the same reasoning that made C28 a trace-scan rather
   than a `lake` call. Ship it **enforced with no soft window**, on the C24/C25/C26 precedent (it
   is green the day it lands), and run the deliberate negative test `MODULE_INVARIANTS.md`
   requires: add a stray `.lean` file, observe `FAIL` *and* a non-zero script exit, remove it,
   observe `PASS`.
5. **Add the CI step** for `mk_all --check` following `CI_CD_PROCESS.md`'s "Wiring a New Check
   Script" convention (step name carries the exact invocation, `set -euo pipefail`,
   `::group::`/`::endgroup::`, appended directly before "Report results", cache-warm placement
   after the lean-action step since it calls `lake`), and add its row to that document's runtime
   budget table with a re-sum.
6. **Adopt `lint-style-action` in two steps**: first `lake exe lint-style --fix` to clear the 103
   trailing-whitespace findings (a real improvement, zero judgement), then the unicode decision
   (see "Decisions" — this one needs the user). Wiring the action before the unicode question is
   settled would land a permanently-red gate.
7. **Retire nothing: keep `check-copyright-headers.sh`, with a corrected header.** The Phase 8
   question ("does `linter.style.header` under `--wfail` make it redundant?") resolves to **no, but
   nearly**. Post-collapse the linter subsumes it for all 503 `FormalSystem` modules and is
   strictly stronger there (it also checks docstring position, broad imports, duplicate imports).
   It does **not** and structurally **cannot** cover: the 12 `BimodalTools/*Main.lean` roots (not
   imported by `BimodalTools.lean`, and cannot be) or anything under `Tests/` (`./BimodalTest.lean`
   does not exist and will not, since `srcDir = "Tests"`). The script is the only header gate for
   those 12 + 65 files. Recommended change: keep the CI step as-is, and rewrite the script's
   `WHY THIS EXISTS` block — its `srcDir := "FormalSystem"` premise is already factually wrong —
   to state the surviving coverage gap instead.
8. **Release workflow**: `push: tags: ['v*']` plus an explicit `workflow_dispatch` trigger so the
   maintainer can exercise it without creating a throwaway tag. Given no local `actionlint`/`act`,
   the honest reading of the acceptance criterion "release workflow dry-run passes" is: YAML parses
   (`python3 -c "import yaml,sys; yaml.safe_load(...)"`), every referenced action pin resolves, and
   the `workflow_dispatch` path runs green once on the maintainer's account. That last step is a
   **maintainer handoff**, not something this task can self-certify.
9. **Module-size policy**: add a short subsection to `ORGANISATION.md` adopting cslib's rule (split
   along dependency seams, never to satisfy a line count), naming the two files over 4,500 lines —
   `Metalogic/Expressiveness/EFGames/GapDetection.lean` (5,094) and
   `Metalogic/Expressiveness/GameTransfer/SplitPoint.lean` (4,906) — and pointing at the existing
   `linter.style.longFile = 1500` in-source baselines as the mechanical half. While editing that
   file, fix the "Everything else" table row that still reads "`specs/` … not part of the
   deliverable", which contradicts the recorded decision that `specs/` stays tracked and published.
10. **Namespace exceptions: keep all eight, rename none.** Every one carries a written reason and
    every one is sound (upstreaming target, notation resolution against the type's namespace, a
    generic scheme named rather than a directory, a measured-and-refuted hoist). Renaming touches
    declaration moves, importers, external FQN citations and the pinned `#print axioms` baselines
    that appear twice each in `check-module-invariants.sh` — high cost, no benefit. Deliverable:
    add the `## Recorded namespace exception` heading to the three that lack it (`ForMathlib/Order/
    PFilter.lean`, `Tactic/Meta.lean`, `Theorems/DeductionTheorem.lean`) and add the eight-row
    table above to `ORGANISATION.md` as the single consolidated index.
11. **`ENFORCE_C16_ROOTS` stays 0**; update the recorded numbers. 170 across 13 of 17 roots is not
    a burndown this task owns (67 of them are in `BimodalTest` alone). The actionable half is
    correcting the stale `179`/14-root table in the C16 header so the record matches the tree —
    which is precisely the defect class C14 exists to catch. **Coordinate with task 643.**
12. **Adopt `--wfail` on the two tooling CI steps** (`lake build BimodalTools`,
    `lake build BimodalToolsTest`) and rewrite the C28 decision block accordingly. The deferral's
    own stated trigger has fired: the tooling tree is at zero compiler warnings at HEAD, measured
    with the trace store warm for every tooling root. Verify with an actual `--wfail` build in the
    implementing phase rather than on the trace scan alone.

## Decisions

- **`mk_all` is scoped to `--lib FormalSystem`.** Not a preference — the other three libraries are
  structurally incompatible (double `main`; `srcDir` vs. directory name). The CI invocation must
  carry `--lib FormalSystem` explicitly; a bare `lake exe mk_all` errors.
- **The `mk_all` harness check is a build-free Python scanner, not a `lake` shell-out**, so CI's
  `--no-build` pass actually runs it. `lake exe mk_all --check` remains the full-mode form.
- **`check-copyright-headers.sh` is kept, not retired**, on measured coverage grounds (77 files the
  header linter structurally cannot reach). Its stale rationale header is corrected in the same
  change.
- **All eight namespace exceptions are kept**, consolidated into `ORGANISATION.md`; the three
  lacking the standard heading get it.
- **`ENFORCE_C16_ROOTS` stays 0**; only the stale recorded measurement is corrected.
- **The header-linter burndown precedes the collapse in the same change.** Ordering, not taste:
  `--wfail` makes the two inseparable.
- **The publication-gate untracking item is already satisfied** and should be recorded as such
  rather than re-performed. Verified: `git ls-files` finds none of the four; `.gitignore` carries
  three (`.gitattributes` has never existed); `6ac3b3844` is the commit.

## Risks & Mitigations

| Risk | Evidence | Mitigation |
|---|---|---|
| **The collapse turns CI red via `linter.style.header`** | 22 measured findings, `--wfail` already on the lean-action step | Clear all 22 in the same change; the scanner used here is reproducible and cheap |
| Nine newly-reachable modules enter `runLinter FormalSystem`'s enforced scope (C16 half 1) and could add un-nolisted findings | 80 declarations across 9 modules that `runLinter FormalSystem` has never observed | Run `lake exe runLinter FormalSystem` immediately after the collapse, before committing; the enforced half is at 0 today and must stay there |
| Same nine modules enter `--wfail` and C24's `checkInitImports` closure | They are compile-checked in isolation today, not built by `lake build` | Full guarded `lake build` plus `lake exe checkInitImports` as phase-end verification |
| **Territory collision on `scripts/check-module-invariants.sh`** | Task 643 declares it in `file_scope` this same `/orchestrate` cycle; this task needs C6/C8/C16/C28 edits and a new check in it | Re-read immediately before editing; stage only this task's hunks; if 643 has landed changes, rebase this task's edits onto them rather than reverting |
| **Territory collision on two READMEs** | Task 614 declares `FormalSystem/README.md` and `FormalSystem/Metalogic/README.md`; both carry `FormalSystem/FormalSystem.lean` prose that the collapse invalidates | Same protocol; the other four README/doc references are free and can land first |
| `lint-style-action` lands permanently red | 362 measured findings | Do not wire the action until the unicode decision is taken and the whitespace half is fixed |
| Release workflow cannot be self-certified locally | No `actionlint`/`act`; agents must not push tags (`pr-prohibition.md`) | Local YAML-parse + action-pin resolution as the automatable half; `workflow_dispatch` run as an explicit maintainer handoff item |
| Wiring `DerivationBenchmark` in makes `lake test` print a benchmark table | 5 top-level `#eval`s; the manifest records this as the reason it is unwired | Delete the top-level `#eval` lines rather than the module; C27's allow-list is unaffected (its 54 entries are all in `MainResults.lean`) |
| `def version` silently disappears with the absorbed file | Sole definition site; unreferenced, so nothing would fail | Relocate to `FormalSystem/Version.lean` and bump to `1.0.0`; reconcile `VERSIONING.md`'s "version in lakefile.toml" instruction, which names a field that does not exist |

## Tactic Survey Results

- Not applicable (no tactic survey performed). This task is repository infrastructure — CI
  workflows, aggregator generation, linter configuration and manifest bookkeeping. It contains no
  proof goals, and the acceptance criteria are `mk_all --check` green, an empty C6 manifest, and a
  release-workflow dry-run.

## Context Extension Recommendations

- **Topic**: Mathlib's `isInLibraryRoot` activation gate for `linter.style.header`.
- **Gap**: Nothing in `context/project/lean4/` records that a downstream project's *root aggregator
  shape* silently decides how much of Mathlib's style linting runs. The effect here is a 1-module
  vs. 503-module difference with no diagnostic anywhere — the linter passes by doing nothing.
- **Recommendation**: add a short note to `context/project/lean4/tools/` covering the gate, the
  `srcDir`-vs-directory-name asymmetry in `mk_all`/`GetAllModules`, and the import-line exemption
  in `linter.style.longLine`. All three are non-obvious, all three were load-bearing for this
  task's conclusions, and all three would mislead a future agent reasoning from the linter names
  alone.

## Appendix

**Commands run (all read-only except the one restored generation).**

```bash
lake build mk_all                                   # exe builds
lake exe mk_all --lib FormalSystem --check          # "out of date", as expected
lake exe mk_all --lib FormalSystem                  # generated; root restored from a copy, sha verified
lake build lint-style
lake exe lint-style                                 # 1 finding pre-collapse; 362 with the generated root
lake exe runLinter <each of 17 lakefile roots>      # 170 findings, 13 dirty roots
bash scripts/check-module-invariants.sh --no-build  # ALL CHECKS PASSED; C6 = 14 manifested
python3 scripts/warning-budget.py                   # 0 warnings across 0 files, tooling traces warm
python3 scripts/measure-refactor-partitions.py namespace-audit
```

**Source citations.**

- `.lake/packages/mathlib/scripts/mk_all.lean:26-37` (`getLeanLibs` returns every `lean_lib`),
  `:54-56` (`--lib`), `:76-83` (generated content; the `Mathlib`-only `longLine` tail),
  `:91-98` (`--check` semantics)
- `.lake/packages/mathlib/Mathlib/Util/GetAllModules.lean` — `getAllFiles` walks the library name
  as a CWD-relative directory; `srcDir` is never consulted
- `.lake/packages/mathlib/Mathlib/Tactic/Linter/Header.lean:259-264` (`isInLibraryRoot`),
  `:306-327` (`broadImportsCheck`), `:443-448` (module-docstring-first)
- `.lake/packages/mathlib/Mathlib/Tactic/Linter/Style.lean:440-444,471` (import lines exempt from
  `longLine`)
- `.lake/packages/mathlib/Mathlib/Tactic/Linter/TextBased.lean:300,403` (`trailingWhitespace`,
  `unicodeLinter` default to `true`)
- `.lake/packages/mathlib/Mathlib/Init.lean` — `register_linter_set linter.mathlibStandardSet`
  includes `linter.style.header`
- `.lake/packages/mathlib/scripts/lint-style.lean:245-262` (module scope = direct imports;
  `scripts/nolints-style.txt`)
- `scripts/check-module-invariants.sh:669-681` (`ENFORCE_C16_ROOTS`), `:2370-2385` (the stale
  179-finding table), `:4116-4125` (the C28 `--wfail` deferral and its revision trigger),
  `:1205-1215` (`C8_ALLOW_SELFNAMED`), `:803-805` (B3's two-root loop)
- `scripts/module-invariants-manifest.txt` — the 14 entries and their recorded reasons
- `docs/development/PUBLICATION_REFACTOR.md:486-497` (Phase 8), `:601-612` (follow-up H),
  `:519-527` (the publication gate and the `specs/` decision)
- `docs/development/CI_CD_PROCESS.md:199-266` (wiring convention, runtime budget)
- `docs/development/MODULE_INVARIANTS.md:229-290` (Adding a Check; the negative-test requirement)
- Commit `6ac3b3844` — the already-landed untracking of the agent-configuration files
