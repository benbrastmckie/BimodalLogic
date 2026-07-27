# Implementation Plan: Line-Limit Compliance and Publication Residue

- **Task**: 180 - line_limit_compliance_and_publication_residue
- **Status**: [IMPLEMENTING]
- **Effort**: 12 hours
- **Dependencies**: 292, 402 (both complete)
- **Research Inputs**: `specs/180_line_limit_compliance_and_publication_residue/reports/01_line-limit-compliance-residue.md`
- **Artifacts**: plans/01_line-limit-compliance-residue.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Bring the entire live Lean tree (`FormalSystem/**` minus `**/Boneyard/**`, plus `Tests/**`) into
`linter.style.longLine` compliance: **598 violations across 65 files**, measured by codepoint.
The work is mechanical source reformatting under a build gate — no proofs change, no declarations
are renamed, no `sorry` is added. A repaired copy of the archived line-breaking harness does
~90% of the work; roughly 63 string-heavy sites need hand treatment, and a new string-gap breaker
is added to absorb most of those. The copyright-header and universe-polymorphism scope items are
recorded as **verified no-work**, re-confirmed at completion rather than re-performed.

Definition of done: live-tree codepoint violations = 0; `lake build` green; `lake build
BimodalTest` green; comment-stripped live `sorry` count exactly 1 (`countermodel_discrete`);
declaration inventory unchanged; sibling-owned linter categories unchanged by equality.

### Research Integration

The plan is built on the measured report, not the task description. Findings that drive it:

| Finding | Plan consequence |
|---|---|
| 598 violations / 65 files, not 312 | Scope is `Automation/` 327 + `Tests/` 231 + `FormalSystem/` other 40 |
| `Tests/` (231, 39%) was never in any prior sweep's scope | Phases 6-7 exist at all; gated on `lake build BimodalTest` |
| Rename regression real: FS-other 4 → 40 | Phase 3 is a distinct, already-validated slice |
| Harness lives at `specs/archive/400_.../tools/`, stale in 5 places | Phase 1 is blocking; nothing downstream is trustworthy first |
| Unrepaired harness reports a **vacuous zero** | Every census asserts record count > 0 before being believed |
| Auto-fix applicability 99.5%, not 25.1% | Mechanical sweep is the primary mechanism; hand-fix is the tail |
| `awk 'length>100'` counts **bytes** (2116 vs true 598) | A single codepoint-correct counter is defined once and reused by every phase |
| `lake build` never reports `linter.style.longLine` | No phase gates on a linter category count for longLine |
| Copyright 330/330; zero `universe` declarations | Recorded as verified in Phase 8, not manufactured as work |
| Sole live `sorry` located by content (naive grep returns 287) | All `sorry` gates strip comments first |

Verified independently while planning: the census reproduces at exactly **598 violations / 65
files** with the identical area split (327 / 231 / 40), and copyright is **330 / 330**. The three
`^\s*universe\s` grep hits are all line-wrapped prose inside comments — confirming that the
universe check, like the `sorry` check, must strip comments before it means anything.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` exists but was not supplied as `roadmap_path` for this dispatch, and no
roadmap phases are requested. This task advances publication-quality closeout; no ROADMAP.md
edits are in scope and none are to be made.

## Goals & Non-Goals

**Goals**:
- Live-tree `linter.style.longLine` violations reduced from 598 to 0, measured by codepoint.
- A repaired, non-vacuous measurement harness owned by this task, usable by every phase.
- A string-gap breaker in `fixers.py`, reducing the hand-fix tail.
- Copyright-header and universe-polymorphism items re-confirmed and recorded as verified no-work.
- Every phase independently buildable, verifiable, and committable.

**Non-Goals**:
- Boneyard trees (155 files, a further 512 violations) — excluded from the build, out of scope.
- Any declaration rename, `def`→`theorem` flip, or signature change — sibling territory,
  actively gated against by the declaration inventory check.
- Any reduction in sibling-owned linter categories (`linter.unusedVariables`,
  `linter.unusedSimpArgs`, `linter.style.show`, `linter.defProp`, `linter.dupNamespace`,
  `linter.unusedArguments`, `defsWithUnderscore`, …) — these must hold by **equality**.
- Discharging `countermodel_discrete`. Its `sorry` is a pre-existing open mathematical
  obligation and an **invariant to preserve** (count stays exactly 1), not work to perform.
- Modifying anything under `specs/archive/` — the archived harness is read-only provenance.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| Harness reports a vacuous zero from the stale `Theories/` regex | H | **H if Phase 1 skipped** | Phase 1 is blocking; every census asserts `records > 0` and cross-checks against the standalone counter |
| Byte-vs-codepoint miscounting inflates or deflates progress | H | M | One canonical `count_long_lines.py` written in Phase 1; no phase may use `awk 'length>100'` |
| A break silently reparses instead of erroring (do-notation `return`) | H | L | `FORBIDDEN_TAIL`/`GLUED_TAIL` guards plus a per-file `lake build` gate with auto-revert |
| Sweep trespasses into sibling linter territory | M | **M** — `sweep.py`'s default `STAGE_A` fixes `unusedVariables`/`unusedSimpArgs`/`show` | Phase 1 narrows the fixer stage list to `linter.style.longLine` only and moves every other category into the frozen set |
| A fixer edit drifts a declaration name | H | VL | `gate.py` declaration-inventory equality check |
| String-heavy residual resists mechanical fixing | M | **Certain (~63 sites)** | Phase 2 string-gap breaker; Phases 5 and 7 hand-fix the remainder |
| A string gap changes the runtime value of an emitted string | H | M | String-gap edits must preserve the decoded literal; verified by `#eval`/`#guard` where the string is observable, and by the existing `Tests/` checks |
| Lost work from a bad mechanical pass | M | L | `sweep.py` reverts per-file on regression; `bash .claude/scripts/git-snapshot.sh` before any rollback; commit at every green phase |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4, 6 | 2 |
| 4 | 5, 7 | 4, 6 |
| 5 | 8 | 3, 5, 7 |

Phases within the same wave can execute in parallel. Territory contracts for the parallel waves:

- **Wave 2**: Phase 2 owns `specs/180_.../tools/fixers.py`; Phase 3 owns `FormalSystem/**`
  `.lean` files outside `Automation/`. If run concurrently, Phase 3 must first take a frozen
  harness copy (`cp -r specs/180_.../tools specs/180_.../tools-frozen`) and invoke that, so
  Phase 2's in-flight edits cannot destabilize it.
- **Wave 3**: Phase 4 owns `FormalSystem/Automation/**`; Phase 6 owns `Tests/**`. Disjoint.
- **Wave 4**: Phase 5 owns `FormalSystem/Automation/**`; Phase 7 owns `Tests/**`. Disjoint.

---

### Phase 1: Relocate and Repair the Measurement Harness [COMPLETED]

- **Goal:** A harness owned by this task that measures the live tree correctly and can never
  report a vacuous zero.

- **Tasks:**
  - [x] Copy the harness into task-owned space, excluding `__pycache__`:
        `specs/archive/400_clear_lean_v433_deprecation_warnings/tools/` →
        `specs/180_line_limit_compliance_and_publication_residue/tools/`.
        Do not edit anything under `specs/archive/`. *(completed; the two task-400 site lists
        `other_sites.txt` / `push_neg_sites.txt` were dropped as stale provenance)*
  - [x] Fix `lintlib.py:21` `REPO`. At the new location the existing four-`dirname` chain happens
        to resolve correctly — do **not** rely on that. Replace it with an explicit anchor that
        walks upward until it finds `lakefile.lean`, and `raise` if none is found.
        *(completed: `_find_repo_root`)*
  - [x] Fix `lintlib.py:25` `POS_RE`: `^(Theories/[^\s:]+\.lean)` →
        `^((?:FormalSystem|Tests)/[^\s:]+\.lean)`. *(completed; built from a single
        `LIVE_ROOTS` tuple so the two regexes cannot drift apart)*
  - [x] Fix `lintlib.py:29` `LAKE_POS_RE`: same `Theories/` → `(?:FormalSystem|Tests)/` correction.
  - [x] Fix `gate.py:24` `EXPECTED_SORRY_FILE` →
        `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`. Leave `EXPECTED_SORRY_DECL =
        'countermodel_discrete'` and the locate-by-content logic untouched.
  - [x] Fix `gate.py:34` `lean_files()`: walk **both** `REPO/FormalSystem` and `REPO/Tests`,
        keeping the `Boneyard` directory prune. *(completed; also raises on an empty walk)*
  - [x] Fix `gate.py`'s `long_lines()` to count codepoints, and confirm it reads files as UTF-8
        (it already passes `encoding='utf-8'`; the bug to check for is any `len()` over bytes).
        *(deviation: altered — `len()` was already over `str`, so codepoints were never the
        defect. The real defect was a SECOND, exemption-free definition of the count that could
        silently disagree with the plan's canonical counter. `long_lines()` now delegates to
        `count_long_lines.violations()`; a `long_lines_by_area()` companion was added.)*
  - [x] **Narrow the scope sets for this task.** In `sweep.py`, set the active fixer stage to
        `['linter.style.longLine']` only — the inherited `STAGE_A`
        (`linter.unusedSimpArgs`, `linter.style.show`, `linter.unusedVariables`) and the
        `linter.style.emptyLine` entry in `STAGE_B` belong to sibling tasks. In `lintlib.py`,
        move every category except `linter.style.longLine` out of `IN_SCOPE` and into
        `OUT_OF_SCOPE_FROZEN`. *(completed; `STAGE_A` is now empty and `gate.py:check()` no
        longer exempts `(deprecation)` from the equality check)*
  - [x] Add a **vacuity assertion**: `lintlib.census()` (or its callers) must `raise` when a lint
        run produced output but zero parsed records. A silent zero is the failure mode this whole
        phase exists to prevent. *(completed: `VacuousParse` + `assert_not_vacuous()`, wired into
        a new `lintlib.lint()` that all six `sweep.py` call sites now use in place of the raw
        `parse(run_lint(...))` pair. Proven to fire: re-running the census with the archived
        `Theories/` regex parses 0 records from a 245-diagnostic log and raises.)*
  - [x] Write `specs/180_.../tools/count_long_lines.py` — the single canonical, dependency-free
        counter used by **every** verification step in this plan. It walks `FormalSystem` and
        `Tests`, prunes `Boneyard`, reads UTF-8, counts lines whose `len(str)` exceeds 100
        codepoints, applies the linter's `http` and leading-`import` exemptions, and prints a
        total, a file count, and a per-area breakdown. It must exit non-zero if the total is 0
        while `--expect-nonzero` is passed. *(completed; exemptions transcribed from
        `Mathlib/Tactic/Linter/Style.lean` `Style.longLine.isImport` + the `splitOn "http"`
        guard)*
  - [x] Re-derive `baseline_snapshot.json` and `baseline_categories.json` against current HEAD.
        *(completed; derived from the `lake build BimodalTest` log, which is a superset of the
        `lake build` log and so covers both live roots' warnings)*

- **Phase 1 measured result:**

  | Check | Expected | Measured |
  |---|---|---|
  | `count_long_lines.py` total / files | 598 / 65 | **598 / 65** |
  | — `FormalSystem/Automation/` | 327 / 20 | **327 / 20** |
  | — `Tests/` | 231 / 24 | **231 / 24** |
  | — `FormalSystem/` other | 40 / 21 | **40 / 21** |
  | census records on `ProofStepExport.lean` | > 0 | **245** (83 longLine) |
  | `gate.py` live-file walk | 330 (288 + 42) | **330 (288 + 42)** |
  | live `sorry` (by content) | 1, `countermodel_discrete` | **1, `countermodel_discrete`** |
  | copyright headers | 330 / 330 | **330 / 330** |
  | `lake build` | green, ≥ 1883 jobs | **green, 1883** |
  | `lake build BimodalTest` | green, ≥ 1923 jobs | **green, 1923** |
  | `.lean` files modified | none | **none** |

  The sole live `sorry` is now at `Transfer.lean:1225`, not the `:1242` the plan cites — the line
  drifted again, confirming that locating it by content rather than by line is load-bearing.

- **Timing:** 1.5 hours
- **Depends on:** none

- **Files to modify:**
  - `specs/180_.../tools/lintlib.py` — `REPO` anchor, both path regexes, scope sets, vacuity assert
  - `specs/180_.../tools/gate.py` — sorry-file constant, `lean_files()` roots, codepoint counting
  - `specs/180_.../tools/sweep.py` — fixer stage list narrowed to longLine
  - `specs/180_.../tools/count_long_lines.py` — new
  - `specs/180_.../tools/baseline_snapshot.json`, `baseline_categories.json` — re-derived

- **Verification** (all must pass; none is satisfied by a zero):
  - `python3 specs/180_.../tools/count_long_lines.py` prints **598 total, 65 files**, split
    `FormalSystem/Automation/` **327 / 20**, `Tests/` **231 / 24**, `FormalSystem/` other
    **40 / 21**. Any other number means the counter is wrong, not that the tree changed.
  - A `lintlib` census over at least one known-violating file
    (`FormalSystem/Automation/ProofStepExport.lean`, 83 sites) returns **> 0** records — this is
    the direct anti-vacuity check on the repaired `POS_RE`.
  - `gate.py`'s file walk enumerates **330** live `.lean` files (288 `FormalSystem/`, 42 `Tests/`).
  - `gate.py`'s sorry check locates exactly **1**, declaration `countermodel_discrete`, in
    `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`.
  - No `.lean` file is modified in this phase: `git status --short -- '*.lean'` is empty.

---

### Phase 2: String-Gap Breaker in `fixers.py` [NOT STARTED]

- **Goal:** Extend the break engine to split long string literals using Lean string gaps,
  shrinking the hand-fix tail from ~63 sites.

- **Tasks:**
  - [ ] Implement a string-gap break in `fixers.py`: when the only overflow lies inside a string
        span identified by `string_spans` (`:48`), break inside the literal by emitting a
        trailing `\` and continuing on the next line. A `\` at end-of-line inside a Lean string
        literal absorbs the following leading whitespace, so the decoded value is unchanged.
        The linter's own message text specifies this technique
        (`Mathlib/Tactic/Linter/Style.lean:472-476` appends the hint whenever the line contains
        a `"`).
  - [ ] Wire it into `find_break`/`break_code` as a **last-resort** strategy: only when no legal
        code break exists. The existing seven guards (`FORBIDDEN_TAIL`, `GLUED_TAIL`,
        `at_clause_spans`, `required_cont_col`, the `in_comment` bypass, `string_spans`,
        the `-/` orphan guard) keep priority and must not be weakened.
  - [ ] Handle the two dominant shapes: interpolated `s!"…{x}…"` log strings (never break inside
        a `{…}` interpolation) and embedded JSON literals with escaped quotes (never break
        between a `\` and the character it escapes).
  - [ ] Refuse rather than guess: if the gap cannot be placed without altering the decoded value,
        decline and leave the site for hand treatment.
  - [ ] Re-run the dry run across all 598 live sites and record the new applied / declined /
        residual numbers in the phase notes.

- **Timing:** 1.5 hours
- **Depends on:** 1

- **Files to modify:**
  - `specs/180_.../tools/fixers.py` — new string-gap breaker plus its dispatch

- **Verification:**
  - **No regression on non-string lines**: a dry run restricted to the 21 `FormalSystem/`
    non-`Automation/` files (zero string literals) still reports **40 breaks applied, 0 residual**
    — byte-identical to the pre-change dry run.
  - Dry run over all 598 sites reports a residual strictly **lower than the 60** recorded in the
    research baseline, and the new figure is written into the phase notes.
  - Round-trip value check: for at least three representative gap-broken lines (one `s!`
    interpolation, one escaped-quote JSON literal, one plain literal), confirm via
    `lean_run_code` / `#eval` that the decoded string is identical before and after.
  - No `.lean` file is modified in this phase: `git status --short -- '*.lean'` is empty.

---

### Phase 3: The 40 Rename Regressions (`FormalSystem/` non-`Automation/`) [NOT STARTED]

- **Goal:** Return the 21 `FormalSystem/` non-`Automation/` files from 40 violations to 0 —
  the regression introduced by the naming upgrade, and the cleanest slice (30 pure-code +
  10 docstring lines, **zero string literals**).

- **Tasks:**
  - [ ] If running concurrently with Phase 2, take the frozen harness copy first (see the Wave 2
        territory contract above).
  - [ ] Run the sweep over the 21 files, highest-count first:
        `ParametricTruthLemma.lean` (6), `Chronicle/PointInsertion.lean` (4),
        `Chronicle/RRelation.lean` (4), `Bundle/CanonicalTaskRelation.lean` (4),
        `RestrictedParametricTruthLemma.lean` (3), `FormalSystem.lean` (2),
        `Bundle/TemporalContent.lean` (2), `Theorems/Propositional/Core.lean` (2), and the 13
        single-site files (`ProofSystem.lean`, `Core/MaximalConsistent.lean`,
        `BXCanonical/Completeness.lean`, `Algebraic/BooleanStructure.lean`,
        `Algebraic/ParametricCompleteness.lean`, `Kamp/Prop43Translate.lean`,
        `NfMultiAnchorBridge/InteriorGateGeneralK.lean`,
        `NfMultiAnchorBridge/SharedWitness/Carrier.lean`,
        `NfMultiAnchorBridge/SharedWitness/OrderGate.lean`, `Bundle/ModalSaturation.lean`,
        `Theorems/ModalS4.lean`, `Theorems/Perpetuity.lean`, `Theorems/TemporalDerived.lean`).
  - [ ] Note that 4 of these (`ProofSystem.lean`, `InteriorGateGeneralK.lean`,
        `SharedWitness/OrderGate.lean`, `SharedWitness/Carrier.lean`) predate the rename; they
        are in scope all the same.
  - [ ] Hand-fix any site the sweep declines. Research measured 40/40 applicable with 0 residual,
        so any decline here is a signal that something changed — investigate before proceeding.
  - [ ] Commit.

- **Timing:** 1 hour
- **Depends on:** 1

- **Files to modify:** the 21 `FormalSystem/` non-`Automation/` `.lean` files listed above.

- **Verification:**
  - `count_long_lines.py` reports **0** for the `FormalSystem/` non-`Automation/` area, and the
    global total drops 598 → **558**.
  - `lake build` green, **≥ 1883 jobs**, exit 0, zero errors.
  - Declaration inventory over the touched files unchanged (`gate.py` `DECL_RE` census).
  - Comment-stripped live `sorry` count = 1 (`countermodel_discrete`).
  - `git diff --stat` touches only `.lean` files in this phase's territory.

---

### Phase 4: `Automation/` Mechanical Sweep (327 sites, 20 files) [NOT STARTED]

- **Goal:** Drive the mechanical fixer across all 20 `FormalSystem/Automation/` files and reduce
  the area to its irreducible hand-fix residual.

- **Tasks:**
  - [ ] Run `sweep.py` with a completion log so the run is resumable, over the 20 files in
        descending order: `ProofStepExport.lean` (83), `DatasetGenerator.lean` (51),
        `FormulaMutator.lean` (43), `FormulaEnumerator.lean` (41), `DatasetExport.lean` (30),
        `ProofFirstBenchmark.lean` (15), `Tactics/Commands.lean` (14),
        `TableauProofStepPipeline.lean` (13), `ProofSearch/Core.lean` (8),
        `ProofSearch/Strategies.lean` (7), `Tactics/Helpers.lean` (6),
        `ForwardProofGenerator.lean` (5), `DatasetValidator.lean` (3),
        `BenchmarkAnchors.lean` (2), and the six single-site files (`AesopRules.lean`,
        `EnumBenchmark.lean`, `Normalization.lean`, `ProofFirstExporter.lean`,
        `TraceExporter.lean`, `Tactics/Deduction.lean`).
  - [ ] Let the per-file lint → fix → re-lint → revert-on-regression loop run to fixpoint.
  - [ ] Enumerate the surviving residual into a checked-in list for Phase 5, with file, line, and
        why the breaker declined.
  - [ ] Commit the mechanical result even though the area is not yet at zero — it is green and
        independently verifiable.

- **Timing:** 1.5 hours
- **Depends on:** 2

- **Files to modify:** the 20 `FormalSystem/Automation/` `.lean` files listed above; plus
  `specs/180_.../tools/logs/automation-residual.txt` (new).

- **Verification:**
  - `count_long_lines.py` reports the `Automation/` area strictly below 327, and the residual it
    reports **equals** the length of the enumerated residual list — the list is not allowed to
    drift from the measurement.
  - `lake build` green, ≥ 1883 jobs, exit 0, zero errors.
  - Sibling-owned frozen categories unchanged **by equality** against the Phase 1 baseline —
    in particular `linter.unusedVariables` (e.g. the pre-existing warning at
    `DatasetGenerator.lean:2179`) must still be present, not silently fixed.
  - Declaration inventory unchanged.
  - Comment-stripped live `sorry` count = 1.

---

### Phase 5: `Automation/` Residual Hand-Fix [NOT STARTED]

- **Goal:** `FormalSystem/Automation/` at exactly 0 violations.

- **Tasks:**
  - [ ] Work the enumerated residual from Phase 4. Research predicts ~50 sites before the
        string-gap breaker lands, concentrated in `DatasetExport.lean` (23),
        `TableauProofStepPipeline.lean` (9), `DatasetGenerator.lean` (6),
        `FormulaEnumerator.lean` (6), `Tactics/Commands.lean` (3), and a 16-site tail across
        ~10 files; Phase 2 should have absorbed a substantial part of that.
  - [ ] For interpolated log strings, prefer extracting a `let` binding for a sub-expression over
        contorting the literal, where that reads better than a gap.
  - [ ] For embedded JSON schema literals in `DatasetExport.lean`, string gaps are the intended
        technique; keep the emitted JSON byte-identical.
  - [ ] Rebuild after each file, not only at the end.
  - [ ] Commit.

- **Timing:** 2 hours
- **Depends on:** 4

- **Files to modify:** the subset of `FormalSystem/Automation/` files named in the Phase 4
  residual list.

- **Verification:**
  - `count_long_lines.py` reports **0** for `FormalSystem/Automation/`.
  - `lake build` green, ≥ 1883 jobs, exit 0, zero errors.
  - For every hand-edited string literal, the decoded value is unchanged — checked by the
    surrounding `#guard`/`#eval` where one exists, and by inspection of the escape sequences
    otherwise.
  - Declaration inventory unchanged; frozen categories unchanged by equality.
  - Comment-stripped live `sorry` count = 1.

---

### Phase 6: `Tests/` Mechanical Sweep (231 sites, 24 files) [NOT STARTED]

- **Goal:** Drive the mechanical fixer across `Tests/` — never in any prior sweep's scope — and
  reduce it to its hand-fix residual.

- **Tasks:**
  - [ ] Run `sweep.py` over the 24 files in descending order:
        `Automation/TacticsTest.lean` (73), `ProofSystem/AxiomsTest.lean` (25),
        `Automation/ProofSearchTest.lean` (22), `Theorems/PerpetuityTest.lean` (13),
        `Automation/EdgeCaseTest.lean` (10), `Integration/AutomationProofSystemTest.lean` (10),
        `Automation/ProofFirstTests.lean` (9), `Automation/ProofSearchBenchmark.lean` (9),
        `Integration/ProofSystemSemanticsTest.lean` (7),
        `Integration/TemporalIntegrationTest.lean` (7), `Semantics/SemanticBenchmark.lean` (6),
        `TraceExportTest.lean` (5), `ProofSystem/DerivationTest.lean` (5),
        `Theorems/PropositionalTest.lean` (4), `Automation/FormulaMutatorTest.lean` (4),
        `Automation/InterestingnessTest.lean` (4), `Syntax/FormulaTest.lean` (4),
        `TraceCertificateTest.lean` (3), `ProofSystem/DerivationBenchmark.lean` (3),
        `Automation/NormalizationTest.lean` (2), `ProofSystem/DerivationPropertyTest.lean` (2),
        `Integration/BimodalIntegrationTest.lean` (2), `Automation/C5SmokeTest.lean` (1),
        `Semantics/TruthTest.lean` (1) — all under `Tests/BimodalTest/`.
  - [ ] Gate every file on `lake build BimodalTest`, not `lake build`. The suite has **no
        `main`**: `BimodalTest` is a `lean_lib` aggregator of **758 compile-time `#guard` /
        `example` checks**, so that build **is** the test run and `lake test` reduces to it.
  - [ ] Enumerate the residual for Phase 7. Expect higher residual density than `Automation/`:
        two thirds of `Tests/` violations touch a string literal (98 code-with-string,
        58 string-dominated, 19 line comments).
  - [ ] Commit.

- **Timing:** 1.5 hours
- **Depends on:** 2

- **Files to modify:** the 24 `Tests/BimodalTest/` `.lean` files listed above; plus
  `specs/180_.../tools/logs/tests-residual.txt` (new).

- **Verification:**
  - `count_long_lines.py` reports the `Tests/` area strictly below 231, matching the enumerated
    residual length exactly.
  - `lake build BimodalTest` green, **≥ 1923 jobs**, exit 0, zero errors. A broken `#guard`
    surfaces here as a build error — this is the substantive check that no reformatting changed
    a test's meaning.
  - `lake build` still green, ≥ 1883 jobs.
  - Declaration inventory unchanged; frozen categories unchanged by equality.

---

### Phase 7: `Tests/` Residual Hand-Fix [NOT STARTED]

- **Goal:** `Tests/` at exactly 0 violations.

- **Tasks:**
  - [ ] Work the enumerated residual from Phase 6.
  - [ ] Line comments (19 sites) rewrap via `break_prose`; if any survived, wrap by hand
        preserving the `-- ` prefix and indent.
  - [ ] For `#guard`/`example` lines, never break in a way that changes what is asserted — prefer
        hoisting a `let` or a local abbreviation over reflowing the proposition.
  - [ ] Rebuild `BimodalTest` after each file.
  - [ ] Commit.

- **Timing:** 2 hours
- **Depends on:** 6

- **Files to modify:** the subset of `Tests/BimodalTest/` files named in the Phase 6 residual list.

- **Verification:**
  - `count_long_lines.py` reports **0** for `Tests/`.
  - `lake build BimodalTest` green, ≥ 1923 jobs, exit 0, zero errors.
  - `lake build` green, ≥ 1883 jobs.
  - The count of `#guard` / `example` declarations in `Tests/` is unchanged (758), so no check
    was deleted rather than reflowed.

---

### Phase 8: Final Gate, Verified-No-Work Record, and Summary [NOT STARTED]

- **Goal:** Prove the end state against every acceptance criterion, and record the two no-work
  items as **verified at completion time**, not as work performed.

- **Tasks:**
  - [ ] Run the full `gate.py` end-state gate and capture its output into the summary.
  - [ ] Re-confirm and record the copyright invariant: every live `.lean` file carries a
        `Copyright` line within its first three lines. Record it as **verified, no work
        performed**, and note the correction that the task description's "277 of 277" was simply
        an older, smaller denominator — the invariant held, the file count grew.
  - [ ] Re-confirm and record the universe-polymorphism finding as an **empty set**: zero
        `universe` declarations in the live tree. This check must **strip comments first** — a
        raw `grep -E '^\s*universe\s'` returns 3 hits, all of which are line-wrapped English
        prose inside docstrings (`SoundnessLemmas/Core.lean:30`,
        `Kamp/NfMultiAnchorBridge/ExteriorNegationK.lean:369`,
        `Decidability/CountermodelExtraction.lean:166`). Record that `Semantics/` uses `Type*` in
        34 places and that `Validity.lean:77,101` document a deliberate monomorphization.
        **Do not manufacture work here.**
  - [ ] Write `summaries/01_line-limit-compliance-residue-summary.md` with the before/after
        census, the harness repairs, the string-gap breaker's measured effect, the hand-fix
        inventory, and the two verified-no-work records.
  - [ ] Commit.

- **Timing:** 1 hour
- **Depends on:** 3, 5, 7

- **Files to modify:**
  - `specs/180_.../summaries/01_line-limit-compliance-residue-summary.md` — new
  - No `.lean` files.

- **Verification** — all six acceptance criteria, each producing a number, none satisfiable by a
  vacuous zero:
  1. `count_long_lines.py` reports **0 total across 0 files** for the live tree — **and** the
     same script, run unchanged against the pre-task baseline commit in a throwaway
     `git worktree`, still reports **598 / 65**. This second half is what makes the zero
     meaningful: it proves the counter reached zero because the tree changed, not because the
     counter broke — the precise failure mode the stale `Theories/` regex would have produced.
  2. `lake build` → green, **≥ 1883 jobs**, exit 0, zero errors.
  3. `lake build BimodalTest` → green, **≥ 1923 jobs**, exit 0, zero errors.
  4. Comment-stripped `sorry` count over the live tree = **exactly 1**, declaration
     `countermodel_discrete`, in `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` (located by
     content, never by line — the line has already drifted). A naive `grep -c sorry` returning
     ~287 is expected and is not the check.
  5. Declaration inventory unchanged versus the Phase 1 baseline (`gate.py` `DECL_RE` census) —
     no rename, no `def`→`theorem` flip.
  6. Sibling-owned frozen linter categories unchanged **by equality**, not merely "not
     increased" — a reduction is trespass, not a bonus.
  - Plus the two recorded invariants: copyright **330 / 330** live files; **0** `universe`
    declarations after comment stripping.

---

## Testing & Validation

- [ ] `lake build` green, ≥ 1883 jobs, exit 0, zero errors — after every phase that touches
      `FormalSystem/`.
- [ ] `lake build BimodalTest` green, ≥ 1923 jobs, exit 0, zero errors — after every phase that
      touches `Tests/`. This build **is** the test run (758 compile-time checks, no `main`).
- [ ] `count_long_lines.py` = 0 across the live tree at completion; per-area = 0 at the end of
      Phases 3, 5, and 7 respectively.
- [ ] Comment-stripped live `sorry` count = 1 (`countermodel_discrete`) at every phase boundary.
- [ ] Declaration inventory unchanged at every phase boundary.
- [ ] Sibling-owned linter categories unchanged by equality at every phase boundary.
- [ ] Copyright 330/330 and zero `universe` declarations re-confirmed at completion.

**Explicitly not a valid gate**: the `linter.style.longLine` category count in a `lake build` log.
`lake build` does not enable the Mathlib style linters, so that count is always zero and gating on
it proves nothing. Count from source by codepoint, or lint with
`-Dlinter.mathlibStandardSet=true`.

**Also not a valid gate**: `awk 'length>100'`. In a C/POSIX locale it counts bytes, and this
codebase is dense in multi-byte notation (`□ ◇ △ ▽ φ ψ → ⊥ ∈ ⟨⟩`) — it reports 2116 against a true
codepoint count of 598.

## Artifacts & Outputs

- `specs/180_.../plans/01_line-limit-compliance-residue.md` (this file)
- `specs/180_.../tools/` — task-owned repaired harness (`lintlib.py`, `fixers.py`, `sweep.py`,
  `gate.py`, `runlinter.py`, `sites.py`, re-derived `baseline_snapshot.json`,
  `baseline_categories.json`)
- `specs/180_.../tools/count_long_lines.py` — the canonical codepoint counter
- `specs/180_.../tools/logs/automation-residual.txt`, `tests-residual.txt` — hand-fix inventories
- 65 reformatted `.lean` files across `FormalSystem/` and `Tests/`
- `specs/180_.../summaries/01_line-limit-compliance-residue-summary.md`

## Rollback/Contingency

- **Per-file**: `sweep.py` reverts a file automatically on build error or category increase, and
  records the failure in its completion log; the log is also the resume point for an interrupted
  run.
- **Per-phase**: each phase is a separate commit. Revert the phase commit to undo it — the
  phases are ordered so that reverting a later one never invalidates an earlier one.
- **Mid-phase**: run `bash .claude/scripts/git-snapshot.sh` before any destructive git operation
  on a dirty tree; never `git reset --hard` or `git checkout --` over uncommitted work otherwise.
- **If the string-gap breaker proves unsafe** (Phase 2 round-trip check fails): drop it, revert
  the `fixers.py` change, and absorb the larger residual by hand in Phases 5 and 7. The plan
  still reaches zero, at higher hand-fix cost.
- **If a phase cannot reach zero for its area**, mark it `[PARTIAL]`, leave the enumerated
  residual checked in, and commit the green partial rather than reverting the whole area — the
  build invariants matter more than the count.

## Constraints

- **MUST NOT** edit anything under `specs/archive/`.
- **MUST NOT** add, remove, or rename any declaration; no `def`→`theorem` conversions.
- **MUST NOT** add a `sorry`, an `axiom`, or a `set_option ... false` suppression to reach a gate.
  The line limit is met by breaking lines, never by silencing the linter.
- **MUST NOT** reduce a sibling-owned linter category, including the pre-existing
  `linter.unusedVariables` warnings.
- **MUST NOT** touch `Boneyard` trees.
- **MUST NOT** write task-number references into any `.lean` file or any deliverable outside
  `specs/**` (`.claude/rules/no-task-references-in-deliverables.md`).
