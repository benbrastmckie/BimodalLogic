# Implementation Plan: CI parity, root collapse and publication gate

- **Task**: 637 - CI parity, root collapse and publication gate
- **Status**: [IMPLEMENTING]
- **Effort**: 13 hours
- **Dependencies**: 636 (complete)
- **Research Inputs**: specs/637_ci_parity_root_collapse_publication_gate/reports/01_ci-parity-root-collapse.md
- **Artifacts**: plans/01_ci-parity-root-collapse.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false
- **Plan Version**: 2 (revised in place, same artifact round; version 1 is commit `ad0750d0c`)
- **Reports Integrated**: 01_ci-parity-root-collapse.md

## Overview

Phase 8 of the publication-refactor programme: collapse the two-level `FormalSystem` root into a
single `lake exe mk_all`-generated `FormalSystem.lean`, empty the C6 unreachable-module manifest,
wire `mk_all --check` and `lint-style-action` into CI, add a tag-triggered release workflow, adopt
the module-size and namespace-exception policy text, and close the publication gate with a
maintainer handoff. The collapse is cheap on its own but switches Mathlib's `linter.style.header`
from 1 module to 503 under CI's existing `--wfail`, so the latent header debt (about 21 files; see
Phase 1's Scope Hypothesis) must be cleared immediately before it — and must be *measured* by a
method that actually re-elaborates the modules, which a warm `lake build --wfail` does not. Definition of done: `lake exe mk_all --lib
FormalSystem --check` green, `scripts/module-invariants-manifest.txt` empty, the release workflow's
automatable dry-run (YAML parse plus action-pin resolution) passing, and the full
`check-module-invariants.sh` gate set green.

### Research Integration

Every phase below is grounded in `reports/01_ci-parity-root-collapse.md`, whose measurements were
taken at HEAD `657c41892`. Load-bearing findings carried into this plan:

- `mk_all` must be invoked as `--lib FormalSystem`. A bare `lake exe mk_all` errors: `BimodalTest`
  and `BimodalToolsTest` declare `srcDir = "Tests"` while `GetAllModules.getAllFiles` resolves a
  library name as a CWD-relative *directory*, and a generated `BimodalTools.lean` would import 12
  `*Main` modules whose `main` declarations cannot coexist. The other three aggregators stay
  hand-maintained under C8.
- `mk_all` emits imports only — no copyright header, no docstring. The `set_option
  linter.style.longLine false` tail is appended for `Mathlib` alone. `check-copyright-headers.sh`
  walks the `FormalSystem/` *directory*, so the repo-root file is outside its scan and the missing
  header is not a gate failure. `linter.style.longFile = 1500` is not approached (504 lines).
- `linter.style.header` gates on `isInLibraryRoot` — whether `./FormalSystem.lean` *directly*
  imports the module. Today that is one module; after the collapse it is all 503, under the
  lean-action step's existing `build-args: "--wfail"`. The report's latent-debt figure — 22 findings
  (16 docstring-not-first, 6 broad `import Lean`) — came from a text scanner *mirroring* the linter,
  not from the linter. This revision ran the real linter on three of those files and corrected the
  figure: see "Revision Notes" below.
- Import lines are exempt from `linter.style.longLine` (`Style.lean:471`), so the two 101-character
  generated import lines need no module renames. Risk checked and cleared.
- The C6 manifest holds **14** live entries, not the 12 the task description implies. Nine clear
  automatically once the generated root imports everything; two clear as a side effect; one is a
  vestigial import line; one needs a module split; one needs the `#eval` decision.
- `lint-style` costs 362 findings post-collapse across 87 files: 258 unicode-allowlist findings on
  this library's own notation and 103 trailing-whitespace findings. The whitespace half is free via
  `--fix`; the unicode half is settled by the recorded decision below.
- The publication-gate untracking item is **already done** in commit `6ac3b3844`; `.gitattributes`
  has never existed and `CITATION.cff` already reads `version: "1.0.0"`. What remains is the
  maintainer's `v1.0.0` tag alone.
- C16 re-measured at HEAD: 170 findings across 13 of 17 roots, superseding the script's recorded
  `179`/14-root table. C28's warning budget is 0 warnings across 0 files with every tooling root's
  trace warm, so the recorded reason for withholding `--wfail` from the two tooling CI steps no
  longer holds — and that block names exactly this condition as its revision trigger.
- All eight `unrelated` namespace-audit files already carry a written reason and are sound; renaming
  any of them would touch declaration moves, importers, external FQN citations and the pinned
  `#print axioms` baselines that appear twice each in `check-module-invariants.sh`.

### Revision Notes (plan version 2, dispatch 12)

A forced `--plan` round with no new research report. Every phase is `[NOT STARTED]`, so nothing was
preserved-as-completed; the ten-phase structure, ordering and recorded decisions of version 1 stand.
The revision re-checked version 1's load-bearing claims against the tree at HEAD `ad0750d0c` and
changed what did not survive:

1. **Phase 1's measuring instrument was blind, and its Scope Hypothesis told the implementer to trust
   it.** Version 1 generated a temporary root in the shared tree and read findings off
   `lake build --wfail`. Lake's module trace does not include the root aggregator, so every
   already-built module is *replayed* from its `.trace` log rather than re-elaborated, and the header
   linter — which reads `./FormalSystem.lean` at elaboration time — never re-runs. The expected
   observation was therefore **zero findings**, and the hypothesis line ("if the count differs from
   22, proceed against the actual figure") would have skipped the burndown and landed a latent-red
   collapse that detonates on the next CI cache miss. Replaced by a **zero-footprint probe**, run
   and verified during this revision: the real `lean`, invoked from a scratch working directory that
   holds only a generated `FormalSystem.lean`, with `--root=<repo>` and the package's `-D` options.
   `isInLibraryRoot` resolves the root path against the process CWD, so no temporary file ever
   enters the shared tree and nothing is written to `.lake/build`. Observed: `Kamp/EANegationFix/
   ConcatPin.lean` fires (docstring-not-first) and goes silent when the scratch root omits it;
   `Tactic/Meta.lean` fires (broad `import Lean`).
2. **`FormalSystem/Tactic/Attr.lean` is not a finding.** It imports `Lean` alone, so the header
   linter is never loaded in it; the probe reports nothing. Its docstring records that it *must*
   import `Lean` only (an `import FormalSystem.Init` would be a cycle). Version 1 listed it for
   narrowing; it is now explicitly left untouched. Version 1's "22 findings across 23 files" was also
   internally inconsistent (16 + 6 = 22 files), and the linter emits several diagnostics per
   docstring-position file, so the unit is now *files*, not diagnostics.
3. **"Narrow `import Lean`" needed a warning.** `broadImportsCheck` also rejects `Lean.Meta`,
   `Lean.Elab`, `Lean.Elab.Tactic` and `Std`, so narrowing to those is not a fix.
4. **Check ID `C31` is taken.** Task 643's plan claims `C31` (bibkeys) and `C32` (docstring links)
   and is `implementing` now, with uncommitted hunks in `scripts/check-module-invariants.sh` observed
   at revision time. This plan's generated-root invariant is renumbered to the next free ID —
   **expected `C33`** — and Phases 5 and 6 gain an explicit start gate on 643.
5. **Phase 7 contradicted the style guide it edits.** `LEAN_STYLE_GUIDE.md` says "There is exactly
   one" permanent opt-out and names `unicodeLinter` among cslib opt-outs that are "not adopted,
   because none of those linters runs during the build". Both sentences must be rewritten, not
   appended to.
6. Smaller corrections: `VERSIONING.md` carries 9 `CHANGELOG` occurrences, not 5; CI's
   `check-paper-definitions.sh` step was missing from Phase 10's gate set; the task's declared
   `file_scope` (9 entries) covers a small fraction of this plan's footprint, which is now a named
   risk.

### Prior Plan Reference

Version 1 of this plan is the same path at commit `ad0750d0c` (its dispatch wrote the plan but
returned off-schema, which is why this round was forced). This file supersedes it in place, within
artifact round 1.

### Roadmap Alignment

No `roadmap_path` was supplied in the dispatch context and no `ROADMAP.md` was consulted. The
programme record this task advances is `docs/development/PUBLICATION_REFACTOR.md` (Phase 8,
follow-up H), read through the research report rather than as a roadmap artifact.

### Recorded Decisions Carried In

| Decision | Source | Disposition |
|---|---|---|
| Unicode text linter | `.decisions.json`, cycle 1, non-blocking | Disable `linter.unicodeLinter` in `lakefile.toml` `[leanOptions]` with a recorded reason; adopt every other lint-style text linter. **Settled — do not re-ask.** |
| `mk_all` scope | Research, structural | `--lib FormalSystem` only. Not a preference. |
| `mk_all` harness check shape | Research | A build-free Python scanner inside `check-module-invariants.sh`, so CI's `--no-build` pass actually runs it; `lake exe mk_all --check` remains the full-mode authoritative cross-check. |
| `check-copyright-headers.sh` | Research, measured | **Kept, not retired.** It is the only header gate for the 12 `BimodalTools/*Main.lean` roots and the 65 files under `Tests/`, which `linter.style.header` structurally cannot reach. Its stale `WHY THIS EXISTS` premise is corrected instead. |
| Namespace exceptions | Research, measured | All eight kept, none renamed; the three lacking the standard heading get it, and an eight-row index lands in `ORGANISATION.md`. |
| `ENFORCE_C16_ROOTS` | Research | Stays `0`. Only the stale recorded measurement is corrected. |
| `specs/` disposition | User, recorded in the task description | Stays tracked and published permanently as the development record. Do not untrack, gitignore, or move it. |

## Goals & Non-Goals

**Goals**:
- A single repo-root `FormalSystem.lean` generated byte-for-byte by `lake exe mk_all --lib
  FormalSystem`, with `FormalSystem/FormalSystem.lean` absorbed and deleted.
- Zero `linter.style.header` findings across every `FormalSystem` module with the generated root in
  place, established by re-elaboration (the probe sweep), not by a warm, log-replaying build.
- `scripts/module-invariants-manifest.txt` empty, with every previously-manifested module wired into
  a build closure.
- A new enforced invariant asserting the generated root is byte-current — next free check ID,
  **expected `C33`** because task 643 claims `C31` and `C32` — plus its CI step and its
  `CI_CD_PROCESS.md` runtime-budget row. This plan writes "C33" below; every occurrence means "the
  ID confirmed free at Phase 5's start".
- `lint-style-action` wired and green: trailing whitespace fixed, `linter.unicodeLinter` disabled
  with a recorded reason.
- `.github/workflows/release.yml` with `push: tags: ['v*']` and an explicit `workflow_dispatch`.
- `--wfail` adopted on the two tooling build steps, with C28's decision block rewritten to record
  that its stated revision trigger fired.
- `ORGANISATION.md` carrying the module-size policy, the eight-row namespace-exception index, and a
  corrected `specs/` row.
- The publication gate recorded as satisfied, with the residue handed to the maintainer.

**Non-Goals**:
- The `v1.0.0` tag itself and the `workflow_dispatch` release run on the maintainer's account.
  Agents must not push tags or create releases (`rules/pr-prohibition.md`).
- The C16 burndown (170 findings, 67 of them in `BimodalTest` alone). Not this task's scope.
- The size splits of `GapDetection.lean` (5,094 lines) and `SplitPoint.lean` (4,906) — Phase 9 of
  the programme. This task adopts the *policy text* only.
- The Lean module system migration (programme Phase 9).
- Renaming any of the eight namespace-exception modules.
- Enabling `linter.checkInitImports` (duplicates C24) or `linter.allScriptsDocumented` (would gate
  `scripts/README.md`, which is task 644's declared territory this cycle). Both stay off by default;
  the plan records the choice rather than enabling by accident.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The collapse turns CI red via `linter.style.header` (`--wfail` already live) | H | H | Phase 1 clears every finding *before* Phase 2 lands the collapse, measured by the real linter through the scratch-CWD probe |
| **A warm `lake build --wfail` reports the tree header-clean when it is not**, because up-to-date modules are replayed from their `.trace` logs and never re-elaborated against the new root. The red build then arrives later, on the first CI cache miss or toolchain bump | H | H (certain on a warm tree) | Phases 1 and 2 treat the warm build as necessary but never sufficient. The header gate is the probe sweep over all `FormalSystem/**/*.lean`, which elaborates each file afresh and writes nothing. C28's warning budget is a trace scan and shares the blind spot, so it is not evidence either |
| Nine newly-reachable modules (80 declarations) enter `runLinter FormalSystem`'s enforced C16 half, which is at 0 today | H | M | Run `lake exe runLinter FormalSystem` inside Phase 2, before committing; any new finding is fixed, not nolisted |
| Same nine modules enter `--wfail` and C24's `checkInitImports` closure for the first time | H | M | Phase 2 verification is a full guarded `lake build --wfail` plus `lake exe checkInitImports` |
| **Territory collision on `scripts/check-module-invariants.sh` and `docs/development/MODULE_INVARIANTS.md`** — task 643 declares both this same cycle | H | H | Phases 5 and 6 re-read each file immediately before editing, stage only this task's own hunks (never a directory or glob `git add`), and rebase onto 643's landed changes rather than reverting them. On a foreign commit or foreign uncommitted modification, STOP and report per `context/contracts/territory.md` |
| **Territory collision on `FormalSystem/README.md` and `FormalSystem/Metalogic/README.md`** — task 614 declares both this cycle, and both carry `FormalSystem/FormalSystem.lean` prose the collapse invalidates | H | H | Same protocol inside Phase 2's atomic batch; the four free README/doc references can be written first. C5/C12/C13 fail on any missed reference, so the sweep is gated, not optional |
| `lint-style-action` lands permanently red | M | L | Phase 7 fixes the whitespace half and applies the recorded unicode decision *before* wiring the action; the action is never wired on an un-green tree |
| The release workflow cannot be self-certified locally (`actionlint`, `act`, `yamllint` all absent) | M | H | The automatable half is a YAML parse plus action-pin resolution; the `workflow_dispatch` green run is an explicit maintainer handoff item, not a self-certification |
| Wiring `DerivationBenchmark` in makes `lake test` print the whole benchmark table | M | M | Delete the five top-level `#eval` lines (the benchmark `def`s stay callable); C27's allow-list is unaffected, its 54 entries all being in `MainResults.lean` |
| `def version` silently disappears with the absorbed file | L | H | Relocate to a new `FormalSystem/Version.lean` reachable from the generated root, bumped to `"1.0.0"` to agree with `CITATION.cff`; reconcile `VERSIONING.md`'s "version in lakefile.toml" instruction, which names a field that does not exist |
| `--wfail` on the two tooling steps is adopted on a trace-scan alone and the runner disagrees | M | L | Phase 6 verifies with an actual `--wfail` build of both tooling roots locally, not with `warning-budget.py` output alone |
| **Check-ID collision**: task 643 claims `C31`/`C32` in the same script this cycle | M | H | This plan uses the next free ID (expected `C33`); Phase 5 re-derives it from the script *and* from 643's plan before writing, and does not start while 643 holds uncommitted hunks in the script |
| The task's declared `file_scope` (9 entries) omits most of this plan's footprint — `ci.yml`, `lakefile.toml`, `FormalSystem.lean`, `Tests/**`, `BimodalTools/**`, `docs/development/**`, `check-module-invariants.sh` | M | H | Territory overlap detection cannot see these edits, so the per-file re-read protocol is this task's only protection there. `git-snapshot.sh` in default mode will refuse on out-of-scope paths; use `--no-revert` for checkpoints. Reported to the orchestrator in this dispatch's return |
| A generated root that drifts silently between generation and commit | M | L | C33 (Phase 5) is the durable gate; its deliberate negative test is required by `MODULE_INVARIANTS.md`'s "Adding a Check" procedure |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 8, 9 | -- |
| 2 | 2 | 1 |
| 3 | 3, 5 | 2 |
| 4 | 4, 6 | 3, 5 |
| 5 | 7 | 6 |
| 6 | 10 | 4, 6, 7, 8, 9 |

Phases within the same wave can execute in parallel. In wave 4, Phase 4 is blocked by 3 and Phase 6
by 5. Phases 5 and 6 carry an additional **external start gate** that this table cannot express:
neither may edit `scripts/check-module-invariants.sh` while task 643 holds uncommitted hunks in it
(see Phase 5's first task). Phases 3, 4, 8 and 9 do not touch that file and are the work to pull
forward if the gate is closed.

---

### Phase 1: Clear the latent header-linter debt [COMPLETED]

**Goal**: Reach zero `linter.style.header` findings across `FormalSystem/`, measured by the real
linter under re-elaboration, so that the collapse in Phase 2 can land under CI's existing `--wfail`
without turning the build red — now or on a later cache miss.

**The probe** (verified during plan revision; this is the measuring instrument for Phases 1 and 2):

```bash
REPO=$PWD                                   # repo root
S=<session scratchpad>/hdr637; mkdir -p "$S"
LP=$(lake env printenv LEAN_PATH); LEANBIN=$(lake env which lean)
# The would-be generated root, written to SCRATCH only -- never into the repo:
( cd "$REPO" && find FormalSystem -name '*.lean' ! -path 'FormalSystem/FormalSystem.lean' \
    | LC_ALL=C sort | sed -e 's#/#.#g' -e 's#\.lean$##' -e 's#^#import #' ) > "$S/FormalSystem.lean"
# One file; run from $S so that isInLibraryRoot reads $S/FormalSystem.lean:
( cd "$S" && LEAN_PATH="$LP" "$LEANBIN" --root="$REPO" \
    -Dweak.linter.mathlibStandardSet=true -Dweak.linter.style.longFile=1500 \
    -Dpp.unicode.fun=true -DautoImplicit=false "$REPO/<file>" 2>&1 | grep -B3 'linter.style.header false' )
```

It writes nothing under `.lake/build` and puts no temporary root in the shared working tree, so it
is safe alongside the sibling tasks building in this tree. It costs one full elaboration per file;
sweep with `xargs -P "$(nproc)"`, one output file per module under `$S/out/`, and treat any
`warning:` followed by the header linter's trailer line (the one naming
`set_option linter.style.header false`) as a finding. Keep the unfiltered output too: an `error:`
there means the invocation is wrong (a missing `-D` option, a wrong `--root`), not that the file is
clean.

**Tasks**:
- [x] Confirm the blind spot once, so the phase notes record it as observed rather than asserted: on
      the untouched tree, `lake build --wfail` is green and re-elaborates nothing, while the probe on
      `FormalSystem/Metalogic/Expressiveness/Kamp/EANegationFix/ConcatPin.lean` reports a finding.
- [x] Build the candidate list cheaply with a throwaway text pre-filter (scratchpad only, never
      committed): files whose first non-import command is not `/-!`, and files importing `Lean`,
      `Lean.Meta`, `Lean.Elab`, `Lean.Elab.Tactic`, `Std`, `Mathlib.Tactic` or any `Lake.*` module.
      The pre-filter only *nominates*; it is known to over-report (`Tactic/Attr.lean`).
- [x] Run the probe on every candidate and record the per-file verdicts. This is the authoritative
      finding list. Count **files**, not diagnostics — a docstring-position file emits one warning per
      command that precedes its docstring.
- [x] Fix each docstring-position finding by moving the module docstring to directly after the
      imports, above the offending command (`assert_not_exists`, `namespace`, `open`, or
      `set_option autoImplicit false`). Expected shapes: 6 files under `Semantics/` and
      `MinusLanguage/` with `assert_not_exists` first; 9 files, mostly under
      `Metalogic/Expressiveness/Kamp/EANegationFix/`, with `namespace` first; and
      `FormalSystem/Metalogic/Conservativity/SpCountermodel.lean` with `set_option autoImplicit false`
      first. Where a file carries a `set_option linter.style.longFile N` baseline "after its module
      docstring", keep that relative order. *(deviation: altered — the probe's 16 docstring-position files were 13 pure block moves, plus `WeakCanonical/RealModel/OrderIsoReal.lean` (its header prose was a plain `/-` comment *before* the imports; moved after them and promoted to `/-!`) and two files with no module docstring at all, `Automation/ProofSearch/Strategies.lean` and `Automation/Tactics/Commands.lean`, which were given one. The 13 moves preserve every line number outside the header region, so C20's line-anchored citations into the `EANegationFix/` files and `Semantics/Truth.lean` are untouched. Four generated README inventories were re-emitted for the changed line counts, two of them in task 614's declared territory — numeric cells only.)*
- [x] Fix each broad-import finding. Try **deleting** the `import Lean` line first: all five affected
      files also import a `FormalSystem.*` module that reaches Mathlib, which already brings in most
      of `Lean`. If elaboration then fails, add the specific *leaf* modules the failing identifiers
      live in. Do **not** narrow to `Lean.Meta`, `Lean.Elab`, `Lean.Elab.Tactic` or `Std` — the same
      check rejects those. Only if no leaf set is workable, fall back to a suppression in the
      sanctioned form with a reason at the site (C29 requires the reason; C30 forbids the blanket
      form), and record why in the phase notes. *(completed — plain deletion sufficed in all five files; no leaf import and no suppression was needed)*
- [x] Leave `FormalSystem/Tactic/Attr.lean` untouched. The probe reports nothing for it (it imports
      `Lean` alone, so the linter is never loaded), and its docstring records why it must stay that
      way. Re-confirm with the probe; do not edit.
- [x] `lake build --wfail` after the edits. The edited files and their dependents genuinely
      re-elaborate here, so this build is meaningful for *them*; it proves the fixes compile, not that
      the tree is header-clean.
- [x] Re-run the probe on every fixed file and confirm silence.
- [x] Run the **full sweep** once — every `FormalSystem/**/*.lean`, not just the candidates — and
      confirm zero findings. This is the phase's exit gate and the only exhaustive evidence; it also
      catches whatever the pre-filter failed to nominate (duplicate imports, a malformed copyright
      block, `linter.directoryDependency`).
- [x] Confirm `git status --short` lists only the header-fix files, and that `FormalSystem.lean` and
      `FormalSystem/FormalSystem.lean` are untouched by this phase.

**Timing**: 1.5 hours (dominated by the full sweep's CPU time, roughly one cold project build)

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: about **21 files** — 16 docstring-position and 5 broad `import Lean` — from the
research scanner's 22 minus `Tactic/Attr.lean`, which the real linter does not flag. Two of the 21
were confirmed with the probe during plan revision (`ConcatPin.lean`, `Tactic/Meta.lean`); the other
19 are scanner nominations only. Confirm by the probe's per-file verdicts, and treat the full sweep's
result as final. **A count of zero from `lake build --wfail` is the known blind spot, not a
measurement** — never proceed against it. If the probe itself reports zero on `ConcatPin.lean`, the
probe is mis-invoked: stop and fix the invocation before drawing any conclusion.

**Files to modify**:
- `FormalSystem/Tactic/Meta.lean`, `FormalSystem/Automation/Tactics/{Deduction,Search,UserTactics}.lean`,
  `FormalSystem/Metalogic/Expressiveness/EFGameTactics.lean` - remove or leaf-narrow `import Lean`
- `FormalSystem/Metalogic/Conservativity/SpCountermodel.lean` - move docstring above `set_option`
- The remaining 15 docstring-position files, enumerated from the probe's output at phase start
- **Not** `FormalSystem/Tactic/Attr.lean`, and **not** `FormalSystem.lean` — this phase no longer
  generates a temporary root in the repository

**Verification**:
- Full probe sweep over `FormalSystem/**/*.lean` reports zero `linter.style.header` findings
- `lake build --wfail` green (compilation of the fixes; not the header gate)
- `git status --short` lists only the header-fix files; both root files byte-unchanged
- Nothing was written outside the header-fix files and the session scratchpad

---

### Phase 2: Collapse the root and sweep every reference [COMPLETED]

**Goal**: Replace the two-level root with one `mk_all`-generated `FormalSystem.lean`, rehouse
`def version`, and update every prose reference the collapse invalidates — as one atomic change, since
the intermediate states are red by construction.

**Tasks**:
- [x] Re-read `FormalSystem/README.md` and `FormalSystem/Metalogic/README.md` immediately before
      touching them: **task 614 declares both in its `file_scope` this same `/orchestrate` cycle.** If
      614 has already landed changes, rebase this phase's edits onto them. On a foreign commit or
      foreign uncommitted modification, check `git log` to confirm the work is not your own, then STOP
      and report rather than proceeding.
- [x] Create `FormalSystem/Version.lean`: an Apache-headered, module-docstringed module in
      `namespace FormalSystem` carrying `def version : String := "1.0.0"`, bumped from `"0.1.0"` to
      agree with `CITATION.cff`. The docstring records that this is the single definition site and
      that `VERSIONING.md`'s release checklist points here.
- [x] Delete `FormalSystem/FormalSystem.lean`. This is a precondition, not a nicety: `mk_all`'s
      `allModules.erase ml.lean` step erases the path `FormalSystem.lean`, which the walk of
      `FormalSystem/` never produces, so the file would otherwise be emitted as
      `import FormalSystem.FormalSystem`.
- [x] Run `lake exe mk_all --lib FormalSystem` to generate the new root. Do not hand-edit the result,
      and do not add a copyright header or docstring to it — `mk_all --check` compares byte-for-byte
      and any addition would make the new C33 gate (Phase 5) permanently red.
- [x] Rewrite the four free prose references that explain the self-named indirection as
      "load-bearing": `FormalSystem/{Plus,Minus,Star}Language/README.md` and
      `docs/development/DIRECTORY_README_STANDARD.md`. These are substantive rewrites, not path swaps. *(altered — a fifth free reference the plan's grep scope missed was also rewritten: the module docstring of `FormalSystem/Semantics.lean`. Two stale neighbours were corrected in the same batch because the collapse is what falsified them: `Decidability/BiLasso.lean`'s "stay unreachable" paragraph and `Decidability/BiLasso/README.md`'s "Imported by: nothing". `FormalSystem/README.md`'s generated inventory gained a `Version.lean` row and lost the inner-root row.)*
- [x] Rewrite the three coordinated references in `FormalSystem/README.md` (×1) and
      `FormalSystem/Metalogic/README.md` (×2), under the protocol above.
- [x] Leave `docs/development/PUBLICATION_REFACTOR.md`'s three occurrences as-is: they are programme
      prose describing this very work. *(altered — left as-is, but C12 fails on an unresolved slash-shaped path, so `FormalSystem/FormalSystem.lean` was added to `scripts/markdown-slash-path-allowlist.txt` with a recorded reason, on that file's own `FormalSystem/Boneyard` cited-as-history precedent.)*
- [x] Run `lake build --wfail`, `lake exe runLinter FormalSystem`, and `lake exe checkInitImports`
      before committing. The nine newly-reachable modules enter all three closures for the first time;
      any new C16 finding is **fixed**, never added to `scripts/nolints.json`. *(completed — `lake lint` passed with zero new findings; `checkInitImports` exit 0. **Deviation: altered** — the nine manifest entries Phase 3 was to delete were deleted here instead: C6's build-free half fails the moment an entry names a reachable module, so leaving them to Phase 3 would have committed a red `--no-build` gate. Phase 3 keeps the two `BimodalTest` entries.)*
- [x] Run Phase 1's **full probe sweep again, now against the real generated root** — from the repo
      root this time (`lake env lean --root=. <-D options> <file>`), since `./FormalSystem.lean` is
      now the genuine article, and including the new `FormalSystem/Version.lean`. The warm
      `lake build --wfail` above re-elaborates only the nine new modules and `Version.lean`; every
      other module is replayed from its trace log and proves nothing about the header linter. Zero
      findings here is the evidence that the collapse is not a deferred CI failure.
- [x] Stage only this task's own hunks — an explicit multi-file `git add -- <files>` list, never a
      directory or glob pathspec.

**Timing**: 2 hours (includes one full probe sweep)

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 14 occurrences of `FormalSystem/FormalSystem.lean` or `FormalSystem.FormalSystem`
outside `specs/`, of which 3 are in `scripts/check-module-invariants.sh` (deferred to Phase 6), 3 are
programme prose left as-is, and 8 are rewritten here. The generated root is expected at ~504 lines,
`FormalSystem.Automation` … `FormalSystem.Theorems.TemporalDerived`. Confirm both by
`grep -rn 'FormalSystem/FormalSystem\.lean\|FormalSystem\.FormalSystem' --exclude-dir=specs
--exclude-dir=.lake .` and `wc -l FormalSystem.lean` at phase start and phase end.

**Files to modify**:
- `FormalSystem.lean` - regenerated, import-only
- `FormalSystem/FormalSystem.lean` - deleted
- `FormalSystem/Version.lean` - new; `def version : String := "1.0.0"`
- `FormalSystem/{Plus,Minus,Star}Language/README.md` - rewrite the indirection prose
- `docs/development/DIRECTORY_README_STANDARD.md` - rewrite the indirection prose
- `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` - **task 614's territory**; rewrite
  under the coordination protocol

**Verification**:
- `lake exe mk_all --lib FormalSystem --check` exits 0
- `lake build --wfail` green, including the nine newly-reachable modules
- Full probe sweep against the real generated root: zero `linter.style.header` findings across every
  `FormalSystem` module (the warm build cannot show this)
- `lake exe runLinter FormalSystem` still reports zero un-nolisted findings
- `lake exe checkInitImports` green
- `bash scripts/check-module-invariants.sh --no-build` passes C5, C12 and C13 (no dangling reference
  to the absorbed module)
- `grep` for the absorbed path returns only the three `PUBLICATION_REFACTOR.md` occurrences and the
  three `check-module-invariants.sh` occurrences

---

### Phase 3: Empty the auto-clearing half of the C6 manifest [COMPLETED]

**Goal**: Remove the eleven manifest entries that the generated root either clears outright or clears
as a side effect, and wire the two `BimodalTest` modules whose sole reason for exclusion has gone.

**Tasks**:
- [x] Re-measure the manifest before editing: run `bash scripts/check-module-invariants.sh --no-build`
      and read C6's own count. The task description implies 12 entries and the research measured 14 at
      HEAD; task 632 already deleted one line. Work against the measured figure.
- [x] Delete manifest entries 1–9 — `FormalSystem.Metalogic.{Core,Bundle,SoundnessLemmas}`,
      `FormalSystem.Metalogic.SoundnessLemmas.CoValidity`,
      `…Kamp.NfMultiAnchorBridge.OuterGateFaithful`, and
      `…Decidability.BiLasso.{Extend,Successor,Orbit,Agreement}`. All nine are now reachable from the
      generated root; C6 fails on an entry naming a reachable module, so these are forced deletions,
      not optional tidying. *(deviation: altered — already done inside Phase 2's atomic batch, for the reason recorded there; this phase re-measured 5 live entries at its start, not 14.)*
- [x] Confirm no cycle was introduced: the three importer-less sibling aggregators are kept so that no
      *content* module imports an aggregator its own contents reach. Nothing imports the root, so the
      root importing them is safe. Verify by `lake build` rather than by inspection.
- [x] Add `import BimodalTest.Metalogic.PeriodicExtensionAxiomTest` and
      `import BimodalTest.Metalogic.Decidability.BiLassoSuccessorTest` to `Tests/BimodalTest.lean`,
      then delete manifest entries 10 and 11. Their only recorded reason for exclusion was that
      importing them would make `BiLasso.Orbit` / `BiLasso.Successor` reachable — which they now are
      regardless.
- [x] Drop the now-unnecessary recorded fix for entry 5 (the one import line in
      `NfMultiAnchorBridge.lean`) from the manifest's comment block if it names one. *(completed — the whole Metalogic comment block was rewritten as history in Phase 2; the stale exclusion prose in `Tests/BimodalTest.lean` and `BiLassoSuccessorTest.lean` was corrected here.)*

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: 11 of the 14 measured manifest entries clear in this phase, leaving 3 for
Phase 4. Confirm by C6's reported count before and after, and by `grep -cvE '^\s*#|^\s*$'
scripts/module-invariants-manifest.txt`.

**Files to modify**:
- `scripts/module-invariants-manifest.txt` - delete 11 entries
- `Tests/BimodalTest.lean` - add 2 imports

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` passes C6 with 3 remaining entries
- `lake build --wfail` and `lake test` green
- `lake test` output carries no new benchmark noise (the `DerivationBenchmark` `#eval`s are Phase 4)

---

### Phase 4: Empty the remaining three C6 manifest entries [COMPLETED]

**Goal**: Clear the last three manifest entries — one vestigial import, one module split, and the
`DerivationBenchmark` `#eval` decision — leaving the manifest empty.

**Tasks**:
- [x] `BimodalToolsTest.ProofFirstTests`: delete the vestigial
      `import BimodalTools.ProofFirstGeneratorMain` from
      `Tests/BimodalToolsTest/ProofFirstTests.lean`. Confirm first that nothing in the file references
      `exportToJsonl`, `writeJsonl`, `parseAtoms`, `parseForwardConfig` or `parseOutputPath`. Then wire
      the module into `Tests/BimodalToolsTest.lean` and delete its manifest entry. *(deviation: altered — the import is NOT vestigial: Test 12 calls `_root_.main args` for an end-to-end CLI smoke test, and deleting the import fails with `Unknown identifier _root_.main`. The research scanned for five named helpers and missed `main` itself. Fixed the same way as the mutator test instead: `ProofFirstGeneratorMain.lean` was split into `BimodalTools/ProofFirstGenerator.lean` (the helpers plus a new `runProofFirstGenerator`, the former body of `main`) and a thin `main`; the test imports the library half and calls `runProofFirstGenerator`, so its CLI coverage is kept. A stray task-number citation in the test's docstring title was removed in passing.)*
- [x] `BimodalToolsTest.FormulaMutatorTest`: extract `ContrastivePair` and the mutator logic from
      `BimodalTools/ContrastiveGeneratorMain.lean` into a new `BimodalTools/ContrastiveGenerator.lean`,
      leaving `ContrastiveGeneratorMain.lean` as a thin `main` that imports it. This mirrors the
      existing `DatasetGeneratorMain` / `DatasetGenerator` pair, which is the precedent shape. Add the
      new module to the hand-maintained repo-root `BimodalTools.lean` aggregator (it carries no `main`,
      so the double-`main` constraint is not engaged), re-point
      `Tests/BimodalToolsTest/FormulaMutatorTest.lean` at it, wire the test into
      `Tests/BimodalToolsTest.lean`, and delete the manifest entry. *(completed — the namespace was renamed with the module, `BimodalTools.ContrastiveGeneratorMain` → `BimodalTools.ContrastiveGenerator`; its only consumers were the CLI half and the test. The CLI's `ContrastiveConfig`/`parseContrastiveArgs` stay in the `Main` module with `main`. The aggregator now carries 15 non-`Main` modules; the recorded `13` in `ci.yml` and the manifest was corrected.)*
- [x] `BimodalTest.ProofSystem.DerivationBenchmark`: delete the five top-level `#eval` lines from
      `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean`, leaving the benchmark `def`s callable.
      This keeps the compile coverage and removes the `lake test` noise that was the recorded reason
      for exclusion, and needs no archive. Wire the module into `Tests/BimodalTest.lean` and delete the
      manifest entry. Record in the module docstring that the `#eval`s were removed deliberately and
      how to invoke the benchmark by hand. *(deviation: altered — there was exactly ONE top-level `#eval`, not five; the other four the plan counted are inside the module docstring's usage example. The one was deleted.)*
- [x] Confirm `scripts/module-invariants-manifest.txt` now holds zero live entries.
- [x] Verify B3 stays green: `FormalSystem` must still never import `BimodalTools`. The new
      `ContrastiveGenerator.lean` lives on the tooling side only.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: 3 manifest entries remain at phase start and 0 at phase end; the
`ContrastiveGeneratorMain` split moves exactly the `ContrastivePair` type and the mutator
declarations. Confirm the manifest count with `grep -cvE '^\s*#|^\s*$'` and the split's scope by
building both `BimodalTools` and `BimodalToolsTest` plus `lake exe contrastive_generator --help` (or
the executable's own no-side-effect invocation).

**Files to modify**:
- `Tests/BimodalToolsTest/ProofFirstTests.lean` - delete the vestigial import
- `BimodalTools/ContrastiveGenerator.lean` - new; extracted logic
- `BimodalTools/ContrastiveGeneratorMain.lean` - reduced to a thin `main`
- `BimodalTools.lean` - add the new module
- `Tests/BimodalToolsTest/FormulaMutatorTest.lean` - re-point imports
- `Tests/BimodalToolsTest.lean` - wire 2 modules
- `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean` - delete 5 top-level `#eval`s
- `Tests/BimodalTest.lean` - wire 1 module
- `scripts/module-invariants-manifest.txt` - delete the last 3 entries

**Verification**:
- `scripts/module-invariants-manifest.txt` holds zero live entries; C6 reports an empty manifest
- `bash scripts/check-module-invariants.sh` (full mode) passes C6 and B3
- `lake build BimodalTools`, `lake build BimodalToolsTest`, `lake test` all green
- `lake test` prints no benchmark table
- `python3 scripts/lake_targets.py exe-roots` still resolves, and `lake build
  BimodalTools.ContrastiveGeneratorMain` succeeds

---

### Phase 5: Add the generated-root invariant (expected C33) and its CI step [NOT STARTED]

**Goal**: Make the byte-currency of the generated root a durable, enforced, build-free invariant that
CI's `--no-build` pass actually runs.

**Tasks**:
- [ ] **Start gate.** Task 643 declares `scripts/check-module-invariants.sh` and
      `docs/development/MODULE_INVARIANTS.md` in its `file_scope`, was `implementing` at plan-revision
      time with uncommitted hunks in the script, and its plan adds `C31`, `C32`, their `ENFORCE_` flags
      and a third C20 assertion to exactly the regions this phase edits. Before editing, run
      `git status --short -- scripts/check-module-invariants.sh docs/development/MODULE_INVARIANTS.md`
      and `jq -r '.active_projects[] | select(.project_number==643) | .status' specs/state.json`. If
      either file carries uncommitted modifications that are not this task's own, **do not edit it**:
      mark this phase `[BLOCKED]` with the reason and report, per `context/contracts/territory.md`.
      Nothing else in this phase is worth landing first — the CI step and the budget row both
      presuppose the check. Interleaving two agents' uncommitted hunks in one file cannot be staged
      apart safely.
- [ ] Once clear, re-read both files in full. Rebase this phase's design onto whatever 643 landed;
      stage only this task's hunks.
- [ ] Derive the check ID rather than assuming it: take the highest `C<n>` that appears in the script
      **or** in `specs/643_citation_gates_bibkeys_links_and_line_anchors/plans/*.md`, plus one. The
      expectation is `C33`. Use the derived ID everywhere this plan writes "C33", including the
      `ENFORCE_` variable name, the CI step name and the `MODULE_INVARIANTS.md` row.
- [ ] Add check **C33** to `scripts/check-module-invariants.sh` as a build-free Python scanner: walk
      every `.lean` file under `FormalSystem/`, sort, prefix each with `import ` and the dotted module
      path, join with newlines plus a trailing newline, and compare byte-for-byte against
      `FormalSystem.lean`. This is the same reasoning that made C28 a trace-scan rather than a `lake`
      call — a check that shells out to `lake` would join the documented "Known Not-in-CI Gaps" list
      alongside C2/C6/C24.
- [ ] Ship C33 **enforced with no soft window**, on the C24/C25/C26 precedent: it is green the day it
      lands. Give it an `ENFORCE_C33` variable defaulting to `1` for consistency with its neighbours.
- [ ] Write the check's header block in the file's established style: what it asserts, why the scanner
      form was chosen over `lake exe mk_all --check`, and that `lake exe mk_all --lib FormalSystem
      --check` is the full-mode authoritative cross-check.
- [ ] Run the deliberate negative test `MODULE_INVARIANTS.md`'s "Adding a Check" procedure requires:
      add a stray `.lean` file under `FormalSystem/`, observe `FAIL` **and** a non-zero script exit,
      remove it, observe `PASS`. Record both observations.
- [ ] Add the C33 row to `docs/development/MODULE_INVARIANTS.md` (643's territory — same protocol).
- [ ] Add the CI step to `.github/workflows/ci.yml` following `CI_CD_PROCESS.md`'s "Wiring a New Check
      Script" convention: step `name:` carrying the exact invocation, `set -euo pipefail`,
      `::group::`/`::endgroup::` wrapping, appended directly before "Report results". The scanner is
      pure `python3`, so it carries no cache-warm placement constraint of its own.
- [ ] Add the step's row to `CI_CD_PROCESS.md`'s runtime budget table and **re-sum both columns** — the
      table's own instruction requires it.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: `C33` is the next free check ID — `C30` is the highest in the script at
plan-revision time, and task 643's plan claims `C31` and `C32`. Confirm with
`grep -oE '\bC[0-9]+\b' scripts/check-module-invariants.sh specs/643_*/plans/*.md | sed 's/.*:C//' | sort -n | tail -1`
and `grep -n 'ENFORCE_C[0-9]*=' scripts/check-module-invariants.sh` before writing. Note that the
script's `# --- C<n>` banner lines are not a complete index (several checks have no banner), so do not
derive the maximum from banners alone.

**Files to modify**:
- `scripts/check-module-invariants.sh` - **task 643's territory**; add C33 and its `ENFORCE_C33` flag
- `docs/development/MODULE_INVARIANTS.md` - **task 643's territory**; add the C33 row
- `.github/workflows/ci.yml` - add the C33 CI step before "Report results"
- `docs/development/CI_CD_PROCESS.md` - add the runtime-budget row and re-sum

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` runs C33 and reports `PASS`
- Negative test: a stray `FormalSystem/_Scratch.lean` produces `FAIL` and a non-zero exit; removing it
  restores `PASS`
- `lake exe mk_all --lib FormalSystem --check` agrees with C33's verdict
- The extracted `run:` body of the new CI step executes green locally
- `CI_CD_PROCESS.md`'s budget sums equal the sum of their own rows

---

### Phase 6: Correct the stale invariant records and adopt `--wfail` on the tooling steps [NOT STARTED]

**Goal**: Bring `check-module-invariants.sh`'s recorded measurements and decision blocks into agreement
with the tree, and act on C28's own stated revision trigger.

**Tasks**:
- [ ] Re-read `scripts/check-module-invariants.sh` immediately before editing (**task 643's
      territory**; same start gate and protocol as Phase 5 — no edits while the file carries another
      task's uncommitted hunks — and Phase 5's own edits must already be committed).
- [ ] Remove the dead `C8_ALLOW_SELFNAMED` entry `"FormalSystem/FormalSystem.lean"` and rewrite the
      preceding comment paragraph that justifies it. The `Semantics/Extension/Extension.lean` entry
      stays.
- [ ] Reduce B3's two-root loop (`for f in FormalSystem.lean FormalSystem/FormalSystem.lean`) to the
      single surviving root. The `[ -f "$f" ] || continue` guard means the current form degrades safely
      rather than failing, so this is correctness of the record, not a fix for a live break.
- [ ] Replace C16's recorded `179`-findings/14-root table with the re-measured **170 findings across 13
      of 17 roots**, and correct the `BimodalTest` row from `85` to `67`. The stale table predates the
      `BimodalTools`/`BimodalToolsTest` split; a recorded number disagreeing with the tree is precisely
      the defect class C14 exists to catch. Re-measure at the phase's own HEAD rather than transcribing
      the research figures, and use the measured values.
- [ ] Leave `ENFORCE_C16_ROOTS` at `0` and record the decision in its comment block: 170 findings, 67
      of them in `BimodalTest` alone, is not a burndown this task owns.
- [ ] Verify the `--wfail` claim directly: run `lake build BimodalTools --wfail` and
      `lake build BimodalToolsTest --wfail` locally and confirm both are green. Do not rely on
      `warning-budget.py`'s trace scan alone.
- [ ] Add `--wfail` to the two tooling CI build steps in `.github/workflows/ci.yml` (`lake build
      BimodalTools`, `lake build BimodalToolsTest`) and rewrite their inline comments, which currently
      state the tooling tree carries warnings the library does not.
- [ ] Rewrite C28's decision block to record that its stated revision trigger has fired, with the
      measured evidence and the date. Correct the `ENFORCE_C28` header's stale "The floor is 7, not 0"
      note — `scripts/warning-budget.txt` reads `Baseline total: 0 warning(s) across 0 file(s)`.

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: C16 stands at 170 findings across 13 of 17 roots, and the tooling tree at 0
compiler warnings. Both are research-time measurements at HEAD `657c41892` and both must be
**re-measured in this phase** — Phases 2–4 added nine modules to `FormalSystem`'s closure and split
`ContrastiveGeneratorMain`, either of which can move these numbers. Confirm with
`lake exe runLinter <each lakefile root>` and `python3 scripts/warning-budget.py`, and record the
figures actually observed.

**Files to modify**:
- `scripts/check-module-invariants.sh` - **task 643's territory**; C8 allow-list, B3 loop, C16 table,
  C28 decision block, `ENFORCE_C28` header note
- `.github/workflows/ci.yml` - add `--wfail` to the two tooling build steps; rewrite their comments

**Verification**:
- `lake build BimodalTools --wfail` and `lake build BimodalToolsTest --wfail` both green
- `bash scripts/check-module-invariants.sh` (full mode) green, with C16 and C28 reporting numbers that
  match their own recorded tables
- `grep` finds no remaining reference to `FormalSystem/FormalSystem.lean` in
  `scripts/check-module-invariants.sh`
- The extracted `run:` bodies of both modified CI steps execute green locally

---

### Phase 7: Adopt `lint-style-action` [NOT STARTED]

**Goal**: Land `lake exe lint-style` as a green CI gate, with the trailing-whitespace debt cleared and
the unicode linter disabled per the recorded decision.

**Tasks**:
- [ ] Re-measure with `lake exe lint-style` against the collapsed root and record the finding count and
      breakdown before changing anything.
- [ ] Run `lake exe lint-style --fix` to clear the trailing-whitespace findings. Review the resulting
      diff before staging — `--fix` touches whatever it finds, so the diff must be confirmed to be
      whitespace-only.
- [ ] Apply the recorded decision: add `weak.linter.unicodeLinter = false` to `lakefile.toml`'s
      `[leanOptions]` block with a comment recording *why* — this library's own notation (`⟐` the
      limit-closure diamond ×115, `⃗` vector arrows ×75, `⟺` ×28, `Ĝ` ×23) is documented and
      load-bearing, and Mathlib's allowlist is Mathlib-specific. Cross-reference the lint-suppression
      policy in `docs/development/LEAN_STYLE_GUIDE.md`, whose permanent-opt-out list this joins.
- [ ] Rewrite `LEAN_STYLE_GUIDE.md`'s "Permanent opt-outs" passage — appending a bullet is not
      enough, because three of its sentences become false: (a) "There is exactly one" becomes two;
      (b) "The library itself has no opt-out" is no longer true of a package-level option; (c) the
      closing sentence lists `unicodeLinter` among cslib opt-outs that are "not adopted, because none
      of those linters runs during the build at this Mathlib version" — keep the true half (it does
      not run during the build) and record that it is now adopted because `lake exe lint-style`, a
      text linter outside the build, does run it and reads this `[leanOptions]` block. The other three
      (`pythonStyle`, `checkInitImports`, `allScriptsDocumented`) stay unadopted. Add the new entry in
      the `linter.hashCommand` entry's shape, with the measured reason.
- [ ] In the same passage, correct the existing entry's scope: it says `hashCommand` is off "on the
      `BimodalTest` library only", but `lakefile.toml` sets it on `BimodalToolsTest` as well. A count
      sentence is being rewritten anyway; leave it true.
- [ ] Confirm `lake exe lint-style` now exits 0. Do **not** wire the CI step until it does — a wired
      action on an un-green tree lands a permanently-red gate.
- [ ] Wire `leanprover-community/lint-style-action` into `.github/workflows/ci.yml`, appended directly
      before "Report results", with a pinned action version. Record in the step's comment that
      `scripts/nolints-style.txt` is the per-project exception file and that it deliberately does not
      exist (the tool warns and proceeds with an empty exception set).
- [ ] Record, in the same step comment, that `linter.checkInitImports` (duplicates C24 /
      `lake exe checkInitImports`) and `linter.allScriptsDocumented` (would gate `scripts/README.md`,
      task 644's declared territory this cycle) stay at their default `false`, so that a future reader
      sees the choice rather than an accident.
- [ ] Add the step's row to `CI_CD_PROCESS.md`'s runtime budget table and re-sum.

**Timing**: 1 hour

**Depends on**: 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: 362 findings across 87 files at research time — 258 unicode, 103 trailing
whitespace, 1 other. Re-measure with `lake exe lint-style` at phase start: Phase 1's docstring moves
and Phase 2's regenerated root both change the scanned text. Work against the observed figures.

**Files to modify**:
- `lakefile.toml` - `weak.linter.unicodeLinter = false` with a recorded reason
- `docs/development/LEAN_STYLE_GUIDE.md` - rewrite the "Permanent opt-outs" passage (count, the
  "library itself has no opt-out" sentence, the cslib sentence, the `BimodalToolsTest` omission)
- `.github/workflows/ci.yml` - wire `lint-style-action` before "Report results"
- `docs/development/CI_CD_PROCESS.md` - budget row and re-sum
- Whatever files `lint-style --fix` touches for trailing whitespace (diff reviewed before staging)

**Verification**:
- `lake exe lint-style` exits 0
- The `--fix` diff contains only trailing-whitespace removals
- `lake build --wfail` still green after the `lakefile.toml` change (the option is `weak.`-prefixed, so
  an unrecognised name is a no-op rather than an error — confirm the name is in fact recognised by
  observing the finding count drop)
- `bash scripts/check-module-invariants.sh` green, including C29/C30 (the opt-out is a lakefile option,
  not an in-source `set_option`, so neither should engage — confirm rather than assume)

---

### Phase 8: Add the tag-triggered release workflow [COMPLETED]

**Goal**: A `.github/workflows/release.yml` the maintainer can exercise without creating a throwaway
tag, with the automatable half of its dry-run passing locally.

**Tasks**:
- [x] Model the new workflow on `.github/workflows/docs.yml`, the in-repo precedent for a non-CI
      workflow, including its prerequisite-checking header style.
- [x] Trigger on `push: tags: ['v*']` **plus** an explicit `workflow_dispatch`, so the maintainer can
      run it without a throwaway tag. The `workflow_dispatch` path must be a real, complete path, not a
      stub.
- [x] Build and test the library at the tagged commit, then produce the release artifacts. Keep the job
      minimal and honest: what it publishes must be what the repository can actually produce. *(completed — the job publishes a GitHub release whose notes are the version's `CHANGELOG.md` section, and nothing else; it first checks that the tag, `CITATION.cff` and `FormalSystem/Version.lean` agree. It therefore presupposes Phase 2's `Version.lean` and Phase 9's `CHANGELOG.md`.)*
- [x] Pin every referenced action to a specific version, matching `ci.yml`'s and `docs.yml`'s
      convention.
- [x] Write a header comment recording that `actionlint`, `act` and `yamllint` are unavailable in this
      environment, what the local dry-run therefore does and does not certify, and that the first green
      `workflow_dispatch` run is a maintainer step.
- [x] Run the automatable dry-run: `python3 -c "import yaml,sys;
      yaml.safe_load(open('.github/workflows/release.yml'))"` for the parse, and resolve every action
      pin (via `gh`, which is available locally) to confirm each reference exists at the pinned
      version. *(altered — widened: beyond the parse and the three pin resolutions, the version-resolution and release-notes `run:` bodies were extracted from the YAML and executed against fixtures: agreeing versions pass, a disagreeing tag exits 1, a missing CHANGELOG section exits 1.)*
- [x] **Do not** push a tag, create a release, or trigger the workflow. `rules/pr-prohibition.md`
      forbids all three; they belong to Phase 10's maintainer handoff.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: `actionlint`, `act` and `yamllint` are all absent locally while `gh` is present.
Confirm with `command -v actionlint act yamllint gh` at phase start; if any linter turns out to be
available, use it and widen the dry-run accordingly.

**Files to modify**:
- `.github/workflows/release.yml` - new

**Verification**:
- `yaml.safe_load` parses the file without error
- Every action pin resolves to an existing published version
- `git log` and `git tag` confirm no tag was created and nothing was pushed
- The workflow's `on:` block carries both `push: tags: ['v*']` and `workflow_dispatch`

**Note on the acceptance criterion**: the task's "release workflow dry-run passes" is satisfied here
only in its automatable half. The green `workflow_dispatch` run on the maintainer's account is
recorded as a handoff item in Phase 10, not self-certified.

---

### Phase 9: Adopt the policy text and consolidate the namespace exceptions [NOT STARTED]

**Goal**: Land the module-size policy, the namespace-exception index, and the documentation
corrections the research measured as factually wrong.

**Tasks**:
- [ ] Add a module-size subsection to `ORGANISATION.md` adopting cslib's rule: split along dependency
      seams, never to satisfy a line count. Name the two files currently over 4,500 lines —
      `FormalSystem/Metalogic/Expressiveness/EFGames/GapDetection.lean` (5,094) and
      `FormalSystem/Metalogic/Expressiveness/GameTransfer/SplitPoint.lean` (4,906) — re-measuring both
      counts rather than transcribing them, and point at the existing `linter.style.longFile = 1500`
      in-source baselines as the mechanical half.
- [ ] Fix `ORGANISATION.md`'s "Everything else" table row reading
      `| `specs/` | Task-management artefacts; not part of the deliverable |`. It contradicts the
      recorded user decision that `specs/` stays tracked and is published permanently as the project
      development record.
- [ ] Add the eight-row namespace-exception index to `ORGANISATION.md` as the single consolidated
      record: `ForMathlib/Order/PFilter` (`Order.PFilter`), `BXCanonical/Chronicle/
      ChronicleRealExtension` (`…Metalogic.Bundle`), `Decidability/BiLasso/Periodic`
      (`…Decidability.Periodic`), `WeakCanonical/DenseModelSurgery/ChronicleInstance` and
      `WeakCanonical/RealModel/ChronicleRealFlow` (both `…BXCanonical.Chronicle`),
      `Semantics/FrameClassValidity` (`FormalSystem.ProofSystem`), `Tactic/Meta`
      (`FormalSystem.Automation`), `Theorems/DeductionTheorem` (`FormalSystem.Metalogic.Core`). Re-run
      `python3 scripts/measure-refactor-partitions.py namespace-audit` to confirm the set is still
      exactly eight before writing the table.
- [ ] Add the standard `## Recorded namespace exception` heading to the three module docstrings that
      carry a reason in prose but lack the heading:
      `FormalSystem/ForMathlib/Order/PFilter.lean`, `FormalSystem/Tactic/Meta.lean`,
      `FormalSystem/Theorems/DeductionTheorem.lean`. Rename nothing.
- [ ] Rewrite `scripts/check-copyright-headers.sh`'s `WHY THIS EXISTS` block. Its stated premise —
      "This project's lakefile sets `srcDir := "FormalSystem"`, so `./FormalSystem.lean` does not
      exist" — is factually wrong and becomes more so after the collapse. Replace it with the measured
      surviving coverage gap: post-collapse `linter.style.header` subsumes this script for all 503
      `FormalSystem` modules and is strictly stronger there, but structurally cannot reach the 12
      `BimodalTools/*Main.lean` roots (not imported by `BimodalTools.lean`, and cannot be) or anything
      under `Tests/` (`./BimodalTest.lean` does not exist and will not, since `srcDir = "Tests"`). The
      script remains the only header gate for those 77 files. Keep the CI step unchanged.
- [ ] Reconcile `docs/development/VERSIONING.md`: its release checklist says "Update version in
      `lakefile.toml`", naming a field `lakefile.toml` does not have. Point it at
      `FormalSystem/Version.lean` instead, and at `CITATION.cff`.
- [ ] Create a minimal `CHANGELOG.md` seeded with the `1.0.0` entry, or — if the maintainer's
      preference is unknown — correct `VERSIONING.md`'s references (9 occurrences at plan-revision
      time) to a file that does not exist.
      Prefer creating the file: `VERSIONING.md`'s release process, `CITATION.cff`'s `1.0.0`, and the
      publication gate all assume one. Record the choice made.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: 8 `unrelated` namespace-audit files, 3 of them lacking the standard heading; 2
files over 4,500 lines; 9 `CHANGELOG` occurrences in `VERSIONING.md` (re-measured at plan revision;
version 1 of this plan said 5). Confirm each with `measure-refactor-partitions.py namespace-audit`,
`wc -l` over `FormalSystem/`, and `grep -o CHANGELOG docs/development/VERSIONING.md | wc -l`
respectively, before writing any count into prose.

**Files to modify**:
- `ORGANISATION.md` - module-size policy, corrected `specs/` row, namespace-exception index
- `FormalSystem/ForMathlib/Order/PFilter.lean`, `FormalSystem/Tactic/Meta.lean`,
  `FormalSystem/Theorems/DeductionTheorem.lean` - add the `## Recorded namespace exception` heading
- `scripts/check-copyright-headers.sh` - rewrite the `WHY THIS EXISTS` block
- `docs/development/VERSIONING.md` - point the release checklist at `FormalSystem/Version.lean`
- `CHANGELOG.md` - new (or `VERSIONING.md`'s references corrected instead)

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` green, including C14's status-claim tripwires
  and C9's task-number scan over `ORGANISATION.md` and `docs/`
- `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools` still green (the header
  rewrite is comment-only; confirm no behavioural change)
- `bash scripts/readme-lint.sh FormalSystem BimodalTools` green
- `measure-refactor-partitions.py namespace-audit` reports the same eight files the table names
- `lake build` green (the three docstring heading additions touch module docstrings only)

---

### Phase 10: Close the publication gate and hand off [NOT STARTED]

**Goal**: Verify every acceptance criterion against the tree, record the already-satisfied gate items
as satisfied rather than re-performing them, and hand the maintainer-only residue over explicitly.

**Tasks**:
- [ ] Verify the untracking item is already satisfied rather than re-performing it: `git ls-files`
      finds none of `CLAUDE.md`, `.claude-extensions.json`, `.syncprotect`; `.gitignore` carries the
      three that exist; `.gitattributes` has never existed; commit `6ac3b3844` is the record. If any of
      this no longer holds at this phase's HEAD, perform the missing part in one commit.
- [ ] Confirm `specs/` is still tracked and is **not** in `.gitignore`. It stays published as the
      project development record, per the recorded user decision.
- [ ] Confirm `CITATION.cff` already reads `version: "1.0.0"` / `date-released: "2026-09-07"`, and that
      `FormalSystem/Version.lean` agrees.
- [ ] Run the complete gate set: `bash scripts/check-module-invariants.sh` (full mode),
      `lake build --wfail`, `lake test`, `lake lint`, `lake build BimodalTools --wfail`,
      `lake build BimodalToolsTest --wfail`, `lake exe mk_all --lib FormalSystem --check`,
      `lake exe lint-style`, `bash scripts/check-copyright-headers.sh --strict FormalSystem
      BimodalTools`, `bash scripts/readme-lint.sh FormalSystem BimodalTools`,
      `bash scripts/check-evidence-probes.sh`, `bash scripts/check-metalogic-cycles.sh`,
      `bash scripts/typst-sync-check.sh`, `bash scripts/check-paper-definitions.sh`. Every one green.
      Cross-check the list against `grep -n -- '- name:' .github/workflows/ci.yml` so that every CI
      step has a local counterpart in this run; version 1 of this plan had missed one.
- [ ] Confirm the header gate one last time by citing Phase 2's full probe sweep, and re-probe any
      `FormalSystem` file added or whose header region changed after it (Phases 4, 7 and 9 touch a
      few). Do not cite `lake build --wfail` as header evidence.
- [ ] Confirm all three stated acceptance criteria against observed output: `mk_all --check` green; C6
      manifest empty; release-workflow dry-run (YAML parse + pin resolution) passing.
- [ ] Update `docs/development/PUBLICATION_REFACTOR.md`'s Phase 8 / follow-up H entries to record what
      landed, what was decided, and what remains with the maintainer.
- [ ] Write the maintainer handoff explicitly into the implementation summary and into
      `PUBLICATION_REFACTOR.md`: (a) create and push the `v1.0.0` tag; (b) run the release workflow
      once via `workflow_dispatch` and confirm it is green; (c) confirm the `CITATION.cff` fields at
      tag time. **Do none of these.** `rules/pr-prohibition.md` forbids agents from pushing, tagging,
      or creating releases, and the first green remote run is the only thing that can certify the
      workflow.
- [ ] Record the research report's context-extension recommendation as a follow-up: a note in
      `context/project/lean4/tools/` covering `isInLibraryRoot`'s activation gate, the
      `srcDir`-vs-directory-name asymmetry in `mk_all`/`GetAllModules`, and the import-line exemption
      in `linter.style.longLine`. Note it in the summary; do not author it here (it is outside this
      task's scope and lands in the deploy-artifact tree, whose source store is
      `agent-system/extensions/**`).

**Timing**: 1 hour

**Depends on**: 4, 6, 7, 8, 9

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: three of the four publication-gate untracking targets are already untracked and
the fourth has never existed. Confirm with `git ls-files -- CLAUDE.md .claude-extensions.json
.syncprotect .gitattributes` and `git log --oneline -1 6ac3b3844` before recording the item as
satisfied.

**Files to modify**:
- `docs/development/PUBLICATION_REFACTOR.md` - record Phase 8 outcomes and the maintainer handoff
- `specs/637_ci_parity_root_collapse_publication_gate/summaries/01_*-summary.md` - implementation
  summary carrying the handoff list

**Verification**:
- Every command in the gate set above exits 0
- `scripts/module-invariants-manifest.txt` holds zero live entries
- `lake exe mk_all --lib FormalSystem --check` exits 0
- `git ls-files` confirms the untracking state and that `specs/` is still tracked
- No tag exists and nothing was pushed (`git tag`, `git log origin/main..HEAD`)

---

## Lean Challenge Statements

This plan commits to **no new Lean theorem statements**. It is repository infrastructure — aggregator
generation, linter configuration, CI wiring, manifest bookkeeping and policy text — and its `Goals`
bullets name no Lean identifiers, so the challenge identifier set is empty by construction and matches.
The one new Lean declaration this plan introduces, `FormalSystem.version : String` in
`FormalSystem/Version.lean` (Phase 2), is a relocated constant with no proof obligation and is
therefore not a challenge statement.

## Testing & Validation

- [ ] `lake build --wfail` green, including the nine modules newly reachable from the generated root
- [ ] Full header-linter probe sweep (Phase 1's probe, real generated root): zero findings across every
      `FormalSystem` module. A warm build replays trace logs and cannot stand in for this
- [ ] `lake test` green, and printing no benchmark table
- [ ] `lake lint` (`runLinter FormalSystem` against `scripts/nolints.json`) still at zero un-nolisted
      findings — the enforced C16 half must not regress
- [ ] `lake build BimodalTools --wfail` and `lake build BimodalToolsTest --wfail` green
- [ ] `lake exe checkInitImports` green (C24's closure grew by nine modules)
- [ ] `lake exe mk_all --lib FormalSystem --check` exits 0
- [ ] `lake exe lint-style` exits 0
- [ ] `bash scripts/check-module-invariants.sh` (full mode) green — C6 empty, C8 without the dead
      allow-list entry, C16 and C28 agreeing with their own recorded tables, C33 passing
- [ ] C33's deliberate negative test: a stray `.lean` file produces `FAIL` and a non-zero exit;
      removing it restores `PASS`
- [ ] `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools` green
- [ ] `bash scripts/readme-lint.sh FormalSystem BimodalTools` green
- [ ] `bash scripts/check-evidence-probes.sh`, `check-metalogic-cycles.sh`, `typst-sync-check.sh`,
      `check-paper-definitions.sh` green
- [ ] `.github/workflows/release.yml` parses under `yaml.safe_load` and every action pin resolves
- [ ] Every modified CI step's `run:` body, extracted from the committed YAML rather than retyped,
      executes green locally
- [ ] `CI_CD_PROCESS.md`'s runtime-budget sums equal the sum of their own rows after both new rows land

## Artifacts & Outputs

- `FormalSystem.lean` - regenerated, import-only, byte-for-byte reproducible by `mk_all`
- `FormalSystem/Version.lean` - new
- `FormalSystem/FormalSystem.lean` - deleted
- `BimodalTools/ContrastiveGenerator.lean` - new
- `.github/workflows/release.yml` - new
- `CHANGELOG.md` - new (or `VERSIONING.md` corrected instead; the choice is recorded in Phase 9)
- `scripts/module-invariants-manifest.txt` - emptied
- `scripts/check-module-invariants.sh` - C33 (or the ID confirmed free) added; C8, B3, C16, C28
  records corrected
- `scripts/check-copyright-headers.sh` - `WHY THIS EXISTS` block corrected
- `.github/workflows/ci.yml` - C33 step, `lint-style-action` step, `--wfail` on the two tooling steps
- `lakefile.toml` - `weak.linter.unicodeLinter = false` with a recorded reason
- `ORGANISATION.md` - module-size policy, namespace-exception index, corrected `specs/` row
- `docs/development/{CI_CD_PROCESS,MODULE_INVARIANTS,LEAN_STYLE_GUIDE,VERSIONING,PUBLICATION_REFACTOR,DIRECTORY_README_STANDARD}.md`
- `specs/637_ci_parity_root_collapse_publication_gate/summaries/01_ci-parity-root-collapse-summary.md`

## Rollback/Contingency

- **Per-phase**: every phase except Phase 2 uses `per-substep` commits, so a failed step is recovered
  by fixing forward from the last green commit. `rules/error-handling.md` forbids discarding
  uncommitted changes to reach a passing build.
- **Phase 1 needs no restore step.** The probe's generated root lives in the session scratchpad and
  never enters the repository, so there is nothing to put back. If a temporary root is ever found in
  the working tree, it is a deviation from this plan: recover it with `git show HEAD:FormalSystem.lean
  > FormalSystem.lean` only after confirming via `git diff -- FormalSystem.lean` that the file carries
  no other change, never with `git checkout --` or `git restore`, which the `guard-destructive-git.sh`
  hook blocks on a dirty tree.
- **Phase 2 (`atomic-batch`)**: the only phase whose intermediate states are expected red. If it
  cannot be brought green, revert the single batch commit with `git revert` rather than a
  working-tree-discarding command. The pre-collapse root is recoverable from git history at any point.
- **A genuine whole-tree rollback**, if one is ever needed, follows `context/contracts/recovery.md`'s
  rollback rung: `bash .claude/scripts/git-snapshot.sh 637 --allow-out-of-scope` first (the override is
  required because a whole-tree rollback necessarily spans paths outside this task's `file_scope`),
  then the destructive command. Do not emit a bare `git-snapshot.sh 637` as a routine start-of-phase
  checkpoint; a defensive checkpoint before risky work uses `--no-revert`.
- **Territory conflicts**: if task 643 or 614 has landed changes to a shared file, rebase this task's
  edits onto theirs. If either still holds *uncommitted* hunks in a shared file, do not edit that file
  at all — mark the phase `[BLOCKED]` and report (Phases 2, 5, 6). Never revert a sibling's work to make room. On a foreign commit, foreign
  uncommitted modification, or a running build this task did not start, check `git log` to confirm the
  work is not this task's own, then STOP and report.
- **The C6 manifest** is the safety net for the reachability work: if a module cannot be wired, it can
  be re-manifested with a recorded reason rather than left dangling — but the task's acceptance
  criterion is an *empty* manifest, so any such re-manifesting is a `[PARTIAL]` outcome that must be
  reported, not absorbed silently.
