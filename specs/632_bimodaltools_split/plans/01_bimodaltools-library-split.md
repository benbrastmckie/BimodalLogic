# Implementation Plan: BimodalTools library split

- **Task**: 632 - bimodaltools_split
- **Status**: [IMPLEMENTING]
- **Effort**: 11.5 hours
- **Dependencies**: 630 (landed — `scripts/move-modules.py` exists with one production relocation behind it)
- **Research Inputs**: specs/632_bimodaltools_split/reports/01_bimodaltools-library-split.md
- **Artifacts**: plans/01_bimodaltools-library-split.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Split the 25 tooling modules (14,750 lines) currently living under `FormalSystem/Automation/` and
`FormalSystem/Metalogic/Decidability/` out of the published library into a new
`lean_lib BimodalTools` that sits outside `defaultTargets`, with a matching
`lean_lib BimodalToolsTest` for the tooling tests. The 12 `lean_exe` targets re-root under
`BimodalTools.*` with their names unchanged, the `FormalSystem.Automation` namespace is renamed
for the moving half only, and a new `B3` invariant asserts that `FormalSystem` never imports
`BimodalTools`. Done means: `lake build` produces no `.olean` under `.lake/build/lib/lean/BimodalTools/`,
`lake build BimodalTools` and `lake build BimodalToolsTest` both exit 0 in CI, the invariant
harness reports 0 FAIL, and `measure-refactor-partitions.py automation-partition` reports an empty
tooling set.

The work is sequenced so that every gate learns the new scan roots **before** anything moves. This
is the plan's central structural commitment: the dominant risk here is not a red build but a
**silent** one, where 14,750 lines quietly leave a check's denominator and the check keeps passing.

### Research Integration

The research report (`reports/01_bimodaltools-library-split.md`) supplies five findings this plan is
built around, each of which changes the shape of the work rather than merely informing it:

1. **`FormalSystem/Automation.lean` imports 8 of the moving modules** and is the only reason
   `lake build` compiles them today. The partition script prunes the aggregator from its walk, so
   this edge is invisible in its output. Deleting those 8 import lines is what makes the split real.
2. **Two modules go unreachable after the split** (`DatasetAssembly`, `PrefilterSoundness`), which
   forces `BimodalTools.lean` to aggregate the 13 non-`Main` modules — and lets the C6 manifest line
   for `ProofFirstBenchmark` be deleted rather than renamed.
3. **`SuccessPatterns` stays in the library, undivided** (pure data, two live library call sites, no
   IO/JSON half to split off). This decision is a precondition for the move set, not an outcome.
4. **At least 12 harness checks plus two CI invocations hardcode `FormalSystem` as a scan root.**
   C25N is the worst case: its stray-`Main` walk would stop seeing all 12 exe roots and pass
   vacuously.
5. **`scripts/typst-module-map.sh` needs no change** — its globs cover only modules that stay. The
   task description names it (twice, in effect), and the correct answer for both namings is "no
   edit"; acceptance is `typst-sync-check.sh` staying green, not a diff in that script.

Verified independently against the tree while planning: `lakefile.toml` declares 13 `lean_exe`
targets of which 12 are the tooling roots (`checkInitImports` has `srcDir = "scripts"` and is not
in the move set); `scripts/readme-lint.sh` defaults to `ROOTS=("FormalSystem")` and CI calls it
with no arguments; C25N's walk tuple is `("FormalSystem", "Tests", "scripts")`;
`move-modules.py` carries `MODULE_ROOT_DIRS = {"BimodalTest": "Tests"}`; B2's
`grep -rnE '^import[[:space:]]+Boneyard(\.|[[:space:]]*$)'` shape is the template for the new B3.

### Prior Plan Reference

No prior plan. This is the first planning round for this task.

### Roadmap Alignment

No roadmap context was supplied in this dispatch. The task's own literature source is
`docs/development/PUBLICATION_REFACTOR.md` Phase 3, whose six bullets this plan discharges; its
Phase 4 bullet at line 358 ("cut `ProofSearch.Core -> SuccessPatterns`") is **superseded** by this
task's `SuccessPatterns` decision and is corrected in Phase 8.

## Goals & Non-Goals

**Goals**:
- `lean_lib BimodalTools` (repository root, outside `defaultTargets`) and `lean_lib BimodalToolsTest`
  (`srcDir = "Tests"`) declared and building.
- All 25 tooling modules relocated, with the `FormalSystem.Automation` namespace renamed for the
  moving half only and never via a bare-prefix map row.
- The 12 tooling `lean_exe` targets re-rooted under `BimodalTools.*`, names unchanged.
- The 8 tooling tests relocated and `NormalizationTest.lean` split rather than moved.
- Every gate that observes the moved paths widened to cover the new roots, with the widening landed
  and observable **before** the move.
- A new `B3` invariant asserting `FormalSystem` never imports `BimodalTools`, modelled on B1/B2.
- `lake build BimodalTools` and `lake build BimodalToolsTest` as CI steps.
- The `SuccessPatterns` decision recorded in `FormalSystem/Automation/README.md`.

**Non-Goals**:
- The `Tactic/Attr.lean` merge and `PropDecide` relocation (PUBLICATION_REFACTOR Phase 4).
- The `XLanguage/` merges (Phase 5) and `mk_all --check` adoption (Phase 8).
- Any change to `scripts/typst-module-map.sh` (its globs cover only staying modules).
- Any proof work. This task introduces no `sorry` and no axiom; C2/C3/C14 must be byte-identical
  before and after.
- Extending C24 (`checkInitImports`) to `BimodalTools`. Tooling modules falling outside the Init
  check is the correct outcome, recorded as a decision in Phase 3 rather than left as an accident.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A gate silently narrows; 14,750 lines leave its denominator with nothing turning red | H | H | Phases 2-4 widen every scan root **before** the move, so each widening is observable on the unmoved tree. Phase 9 asserts C7's module/line counts are unchanged across the move. |
| C25N passes vacuously once the 12 `Main` roots leave its walk | H | H | Widen its tuple in Phase 2 and **negative-test it**: drop a scratch `BimodalTools/ScratchMain.lean`, confirm `FAIL C25N`, remove it. Do not accept a green C25N as evidence on its own. |
| A bare `FormalSystem.Automation -> BimodalTools` namespace row corrupts the library half | H | M | The namespace map is authored explicitly with 19 dotted rows and **no bare prefix row**; `--dry-run` output is read in full before the real run; `git diff --stat FormalSystem/Automation/` after the run must show only the expected staying files. |
| The 11 bare-form citations are missed (`move-modules.py` will not rewrite them by design) | M | M | Re-grep immediately before Phase 6 and diff against the report's enumeration; `move-modules.py`'s bare-form audit line reports a delta. Phase 7 closes them explicitly. |
| `DatasetAssembly` / `PrefilterSoundness` rot unnoticed after the split | M | H | `BimodalTools.lean` aggregates all 13 non-`Main` modules; a `lake build BimodalTools` CI step compiles them. Verify by confirming the build fails if either is dropped from the aggregator. |
| `NormalizationTest` moved wholesale, dropping library normalization coverage from `lake test` | M | M | Split it as specified; assert the retained file still carries its `Normalization` `#guard`s and that `lake test` exercises them. |
| Tooling compiler warnings escape `--wfail` after the split | M | H | Neither new CI build step carries `--wfail`; C28's warning budget with a widened scan root is the compensating control. Recorded as a decision in Phase 2, not left implicit. |
| `move-modules.py` rewrites `measure-refactor-partitions.py`'s own hardcoded `TraceExport` string, appending a phantom row | M | H | Hand-fix that line in the same commit as the move (Phase 6); Phase 9's re-measurement would otherwise report a false non-empty tooling set. |
| Concurrent in-flight edits to `FormalSystem/Automation/` collide with the move | H | M | Immediately before Phase 6, `git status --short FormalSystem/Automation/` must be clean. **Stop and escalate if it is not** — do not merge around a concurrent edit mid-move. |
| Phase 6 is a large atomic commit that cannot be bisected | M | H | Declared `atomic-batch` with the file set fixed in Phase 5's dry-run; a full `--dry-run` review precedes it; rollback is a single `git reset` to the Phase 5 commit (see Rollback/Contingency). |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 4 | 1 |
| 3 | 3 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |
| 7 | 8 | 7 |
| 8 | 9 | 8 |

Phases within the same wave can execute in parallel. Phases 2 and 4 are genuinely parallel: Phase 2
owns `scripts/check-module-invariants.sh` exclusively and Phase 4 owns `.github/workflows/ci.yml`
exclusively. Every later phase is sequential because Phases 3, 7, 8 and 9 all touch
`scripts/check-module-invariants.sh` and must not contend for it.

---

### Phase 1: Declare the new Lake targets and stub aggregators [COMPLETED]

**Goal**: `lean_lib BimodalTools` and `lean_lib BimodalToolsTest` exist and build, with nothing yet
moved. The tree stays green and `lake build`'s output is byte-for-byte unchanged.

**Tasks**:
- [ ] Add `[[lean_lib]] name = "BimodalTools"` to `lakefile.toml`. Leave `srcDir` at its default
      (`.`) and `roots` at its default (`[name]`). **Do not add it to `defaultTargets`** — that
      exclusion is the whole point of the split. Give it
      `leanOptions = {pp.unicode.fun = true, autoImplicit = false}`, matching `FormalSystem`.
- [ ] Add `[[lean_lib]] name = "BimodalToolsTest"` with `srcDir = "Tests"` and the same three-key
      option set as `BimodalTest`, including `weak.linter.hashCommand = false` (the moving tests are
      `#guard`/`#eval` probes and will otherwise trip the `#`-command linter).
- [ ] Extend the existing comment block at the head of `lakefile.toml` (currently naming
      `FormalSystem` and `BimodalTest`) to name the two new libraries and state that `BimodalTools`
      is deliberately outside `defaultTargets`.
- [ ] Author `BimodalTools.lean` at the repository root as a stub: module docstring only, no
      imports yet. It must exist for `lake build BimodalTools` to resolve at all.
- [ ] Author `Tests/BimodalToolsTest.lean` as the same kind of stub.
- [ ] Create `BimodalTools/README.md` and `Tests/BimodalToolsTest/README.md`, each with a
      `<!-- BEGIN GENERATED: inventory dir=... -->` block. Run
      `bash scripts/check-module-invariants.sh --emit-inventory` to populate them (both will be
      empty at this point; that is correct).
- [ ] Add copyright headers to the two new `.lean` files per `scripts/check-copyright-headers.sh`.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: full

**Verification**:
- `lake build` succeeds and `python3 scripts/lake_targets.py exe-roots` output is unchanged.
- `lake build BimodalTools` and `lake build BimodalToolsTest` both exit 0.
- `bash scripts/check-module-invariants.sh --no-build` reports 0 FAIL (the established baseline).
- `bash scripts/readme-lint.sh FormalSystem BimodalTools` exits 0.
  *(deviation: altered — `readme-lint.sh` exits 1 on the UNMODIFIED tree. `scripts/readme-lint.sh
  FormalSystem` alone already reports 21 broken references, every one a `../Boneyard/...` relative
  link in a `FormalSystem/**/README.md` left stale by the archive relocation to the repository
  root. This is pre-existing, outside this task's scope, and makes CI's "Check README health" step
  red today. The achievable evidence was substituted and captured: the widened invocation's output
  is byte-identical to the unwidened one apart from the README count rising 60 -> 61. See the
  summary's Follow-ups.)*

**Files to modify**:
- `lakefile.toml` - two new `[[lean_lib]]` blocks and an extended header comment
- `BimodalTools.lean` - new stub aggregator
- `Tests/BimodalToolsTest.lean` - new stub aggregator
- `BimodalTools/README.md` - new, with inventory block
- `Tests/BimodalToolsTest/README.md` - new, with inventory block

---

### Phase 2: Widen the harness scan roots [COMPLETED]

**Goal**: Every check in `scripts/check-module-invariants.sh` that hardcodes `FormalSystem` as a
scan root also walks `BimodalTools`, landed and observable on the still-unmoved tree, so any
resulting failure is unambiguously attributable to the widening and not to the move.

**Tasks**:
- [ ] Widen each of these checks to include `BimodalTools` in its scan root (line numbers are the
      research report's reading and are hints, not anchors — locate each by check ID):
      C3 (structural sorry), C7 (live inventory), C8 (aggregator convention, the walked-parents
      tuple), C16 (env_linter, enforced half — both sites), C17 (dead declarations),
      C19 (docstring coverage), C20 (`file.lean:NNN` citations, the `SCAN_ROOTS` array),
      C25N (stray `Main`, the `("FormalSystem","Tests","scripts")` tuple), C26 (snake_case/nolint,
      both sites), C27 (debug directives), C28 (warning budget), C29 and C30 (linter suppressions,
      the `ROOTS` tuple).
      *(deviation: altered — reconciled against an independent grep of the script. **C16 needed no
      edit and was not edited**: its enforced half is `runLinter FormalSystem`, scoped to the
      FormalSystem import closure BY CONSTRUCTION, and widening it would mean linting the tooling
      against `scripts/nolints.json` — a burndown outside this task; its reporting half already
      reads the root list from `lakefile.toml` at run time and picked the two new libraries up the
      moment Phase 1 declared them. **C28 likewise needed no edit**: it has no source scan root at
      all, since `scripts/warning-budget.py` walks `.lake/build/lib/lean/**/*.trace` wholesale.
      Both non-edits are now recorded as in-file decisions at their check headers. Three checks the
      list omits DO hardcode a root and were widened: **B2** (live imports of the archive),
      **C15** (paper-anchor citers, two sites) and **C23** (naming regressions, two sites). C7's
      rollup gained a third `BimodalTools` column; C4/C5/C6/C8 were widened through the shared
      graph block's `LIB_ROOTS`/`TEST_SRC_ROOTS` tables rather than per-check.)*
- [x] Where a check already walks `Tests`, confirm `Tests/BimodalToolsTest/` is picked up for free
      (it lives under `Tests/`) rather than adding a redundant root.
- [x] **Negative-test C25N**: create a scratch `BimodalTools/ScratchMain.lean`, run the harness,
      confirm it reports `FAIL C25N` naming that file, then delete the scratch file and confirm the
      harness returns to 0 FAIL. A green C25N alone is not evidence the widening works.
      *(deviation: altered — a SECOND negative test was added beyond the plan's one. A scratch
      `BimodalTools/Scratch.lean` carrying a structural `sorry` and a bare
      `set_option linter.unusedVariables false` produced `FAIL C3`, `FAIL C6`, `FAIL C29`,
      `FAIL C30` and `FAIL INV` simultaneously, then green on deletion — evidence that the
      `live_lean_files`/`live_files` widenings and the reachability walk bind to `BimodalTools`
      rather than merely mentioning it.)*
- [x] Record, as a comment beside C28, the decision that C28's warning budget is the sole control
      watching tooling compiler warnings after the split, because neither new `lake build` CI step
      carries `--wfail`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: The research enumerates **12 check IDs across 15 edit sites** in
`scripts/check-module-invariants.sh` plus C28 named separately. Treat this as a hypothesis, not an
inventory. Confirm at implementation time by grepping the script for hardcoded scan roots
independently — e.g. `grep -nE '"FormalSystem"|\bFormalSystem\b[[:space:]]+Tests|SCAN_ROOTS|ROOTS=' scripts/check-module-invariants.sh`
— and reconcile the result against the list above. Report any check found that the list omits, and
any listed check that turns out not to hardcode a root.

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` still reports 0 FAIL on the unmoved tree.
  Because nothing has moved, a pure widening must be a no-op; a new failure here is a real
  pre-existing defect in the tooling tree that the check was not previously seeing, and must be
  investigated, not suppressed.
  *(deviation: altered — the widening was NOT a no-op. C5 immediately reported
  `docs/development/PUBLICATION_REFACTOR.md:147: BimodalTools.DatasetGeneratorMain`. Investigated
  rather than suppressed: it is a FORWARD reference inside a fenced TOML block illustrating the
  post-split lakefile, and C5 does not skip fenced blocks. It is neither a defect nor a stale
  path — it resolves for real once Phase 6 moves the module. Closed with a TEMPORARY,
  explicitly self-deleting entry in `scripts/module-invariants-allowlist.txt` whose comment
  instructs its own deletion in the Phase 6 commit; Phase 6 deletes it and Phase 9 confirms C5
  reports no stale allowlist entry.)*
- The C25N negative test produced `FAIL C25N` and then returned to green.

**Files to modify**:
- `scripts/check-module-invariants.sh` - scan-root widening across the enumerated checks
- `scripts/module-invariants-allowlist.txt` - one temporary forward-reference entry (deleted in
  Phase 6)

---

### Phase 3: Add the B3 separation invariant and record the C24 decision [COMPLETED]

**Goal**: The invariant that makes the split enforceable exists and passes *before* the move, so it
guards the move rather than merely describing its outcome.

**Tasks**:
- [ ] Add check `B3` to `scripts/check-module-invariants.sh`, modelled directly on B2 (do not
      invent a new shape). Two assertions:
      - Zero matches for `grep -rnE '^import[[:space:]]+BimodalTools(\.|[[:space:]]*$)'` under
        `FormalSystem/`. Matching on the `import` keyword — exactly as B2 does — so a docstring that
        merely cites a `BimodalTools` path is not a failure.
      - Zero `BimodalTools` occurrences in `FormalSystem.lean` and `FormalSystem/FormalSystem.lean`
        (the B1 half of the pattern).
- [ ] Write B3's header comment to state explicitly that the **converse** direction
      (`BimodalTools -> FormalSystem`) is the sanctioned one and must not be gated. Without this, a
      future reader is likely to "fix" the asymmetry.
- [ ] Add a comment at C24's site in `scripts/CheckInitImportsMain.lean` recording the decision
      that its ``name.getRoot = `FormalSystem`` filter deliberately excludes `BimodalTools.*`:
      `Init` is the library's root, so tooling modules are correctly outside the Init check. This is
      a recorded decision, not an oversight.
- [ ] Negative-test B3: add a scratch `import BimodalTools` line to a throwaway file under
      `FormalSystem/`, confirm `FAIL B3`, then revert it.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: full

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` reports `pass B3` and 0 FAIL overall.
- The B3 negative test produced `FAIL B3` and then reverted to green.

**Files to modify**:
- `scripts/check-module-invariants.sh` - new B3 check beside B1/B2
- `scripts/CheckInitImportsMain.lean` - C24 decision comment

---

### Phase 4: Widen the out-of-harness gate invocations [COMPLETED]

**Goal**: The two CI-invoked gates that default to `FormalSystem` cover `BimodalTools` too, verified
locally rather than on a CI round-trip.

**Tasks**:
- [ ] In `.github/workflows/ci.yml`, change the copyright-headers step to
      `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools`, updating the
      `::group::` echo on the preceding line to match.
- [ ] Change the README-health step to `bash scripts/readme-lint.sh FormalSystem BimodalTools`
      (it currently takes no arguments and so falls back to its `ROOTS=("FormalSystem")` default),
      updating its `::group::` echo to match.
- [ ] Run both commands locally to confirm they pass against the Phase 1 stub tree.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Verification**:
- `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools` exits 0.
- `bash scripts/readme-lint.sh FormalSystem BimodalTools` exits 0.
  *(deviation: altered — exits 1, and so does `bash scripts/readme-lint.sh` with no arguments on
  the unmodified tree. 21 pre-existing broken references, every one a `../Boneyard/...` relative
  link in a `FormalSystem/**/README.md` that the archive's relocation to the repository root left
  one directory level short. CI's "Check README health" step is red today for this reason,
  independently of this task. The widening itself is a clean no-op: output is byte-identical apart
  from the README count rising 60 -> 61. NOT fixed here — the 21 links are another task's
  territory and repairing them would widen this commit's scope. See the summary's Follow-ups for
  the exact remedy.)*
- `.github/workflows/ci.yml` parses (e.g. `python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/ci.yml'))"`).

**Files to modify**:
- `.github/workflows/ci.yml` - two step invocations plus their `::group::` echoes

---

### Phase 5: Author the relocation maps and review the dry run [COMPLETED]

**Goal**: The exact module map, namespace map, and hand-edit list for the move are written down and
reviewed, with `move-modules.py --dry-run` output read in full. Nothing moves in this phase.

**Tasks**:
- [x] Add `"BimodalToolsTest": "Tests"` to `MODULE_ROOT_DIRS` in `scripts/move-modules.py`.
      Without it every moved test's derived path is wrong. `BimodalTools` itself is at the
      repository root and needs no entry.
      *(deviation: altered — a SECOND, larger change to `move-modules.py` was required and made.
      `move_trees` resolved each mapping's extension-free path stem and `git mv`'d it, which works
      only for a DIRECTORY subtree; the Boneyard relocation it was built for was exactly that. All
      33 file-granular rows here reported `skip ... (not present)` and the first dry run moved
      **0 paths** while cheerfully rewriting all 236 citations — a silent no-op with an orderly
      report. Added `resolve_move()`, which resolves a stem to a directory or to `stem + ".lean"`,
      preferring the directory; the second dry run moves all 33.)*
- [ ] Author the module map (a scratch file, not a committed artifact) with one row per moving
      module:
      - 24 rows `FormalSystem.Automation.<X> -> BimodalTools.<X>` for the modules under
        `FormalSystem/Automation/` (the tooling half only — **not** `LemmaDB`, `Normalization`,
        `NormalizationAttr`, `TruthNormAttr`, `SuccessPatterns`, `ProofSearch/*`, `Tactics/*`).
      - 1 row `FormalSystem.Metalogic.Decidability.TraceExport -> BimodalTools.TraceExport`.
      - 8 rows moving the tooling tests into `BimodalToolsTest.*` (the three root-level `Trace*`
        tests and five under `BimodalTest.Automation.*`; **not** `NormalizationTest`, which is
        split in Phase 8, not moved).
- [x] Author the namespace map with **19 dotted rows** and verify by inspection that it contains
      **no bare `FormalSystem.Automation -> BimodalTools` row**.
      *(deviation: altered — the map carries **18** dotted rows, not 19. Counted from the tree:
      17 moving modules declare a dotted `FormalSystem.Automation.X` namespace, 6 declare the
      bare shared `FormalSystem.Automation` (hand-edited instead), `EnumBenchmarkMain` declares
      none, and `TraceExport` is the 18th. 17 + 1 = 18. The bare-row prohibition was asserted
      mechanically and holds.)* That prefix is shared with the
      library half and a bare row would rewrite the library's own namespace. Include the two rows
      whose namespace does not match their module:
      `FormalSystem.Automation.Enriched -> BimodalTools.Enriched` and
      `FormalSystem.Metalogic.Decidability.TraceExport -> BimodalTools.TraceExport`.
- [ ] Run `python3 scripts/move-modules.py --module-map <map> --namespace-map <nsmap> --dry-run`
      and read the whole report, in particular the per-class counts and the bare-form audit line.
- [x] Re-grep the 11 bare-form citation sites the report enumerates and diff against its list;
      record any drift.
      *(deviation: altered — **14** live line-sites, not 11 (`specs/**` excluded by policy). The
      three the report omits: `docs/development/NAMING_CONVENTION_DEVIATION.md:453`, the second
      citation on `typst/chapters/p4-dataset-pipeline.typ:30`, and
      `FormalSystem/Automation/MachineAppendixMain.lean:40` — the last inside a file that itself
      moves. Full list in the Phase 5 scratch checklist; Phase 7 closes all 14.)* Unlike the Boneyard relocation, these are *stale after* the move and need
      hand edits.
- [ ] Write the resulting hand-edit checklist into the scratch directory for Phase 6 to execute.

**Timing**: 1 hour

**Depends on**: 3, 4

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts **25 module rows + 8 test rows in the module map** and
**19 rows in the namespace map**, with **11 bare-form citation sites** and **8 FQN citations**
needing hand edits. Confirm each independently before executing Phase 6: re-run
`python3 scripts/measure-refactor-partitions.py automation-partition` for the module set, re-grep
for the bare forms, and check the `--dry-run` class counts against the report's citation table
(138 `FormalSystem/`, 20 `Tests/`, 11 `scripts/`, 5 `docs/`, 2 `typst/`, 1 `.github/`; total 177).
A material divergence means the tree moved under the research and the maps must be re-derived, not
forced.

**Verification**:
- `--dry-run` completes without error and its bare-form audit line reports a zero delta.
  *(deviation: altered — the audit reports `1 before, 1 after` (zero delta, so it passes), but the
  line is near-VACUOUS for a file-granular relocation and must not be read as coverage. Its
  pattern is the mapping's final path component used as a path PREFIX (`AtomCanonicalization/`),
  which is a directory shape; the bare forms that actually matter here are
  `Automation/<Module>.lean`, whose bare token is the module's PARENT. The 14 real sites were
  found by the independent re-grep below, not by this line.)*
- The namespace map contains no bare-prefix row (assert by grepping the map file for a row whose
  left side is exactly `FormalSystem.Automation`).
- `bash scripts/check-module-invariants.sh --no-build` still reports 0 FAIL (only
  `move-modules.py` changed).

**Files to modify**:
- `scripts/move-modules.py` - `MODULE_ROOT_DIRS` gains the `BimodalToolsTest` entry
- (scratch, uncommitted) module map, namespace map, hand-edit checklist

---

### Phase 6: Execute the move [COMPLETED]

**Goal**: The 25 modules and 8 tests are relocated, the exes are re-rooted, and the build is green
again — in one commit, because the tree does not build at any intermediate point.

**Tasks**:
- [ ] **Precondition**: `git status --short FormalSystem/Automation/` must be empty. If any path
      under it carries a concurrent uncommitted edit, **stop and escalate** rather than merging
      around it mid-move.
- [ ] Run `python3 scripts/move-modules.py --module-map <map> --namespace-map <nsmap> --no-verify`
      (the harness runs at the end of the phase, not between steps).
- [ ] Delete the 8 tooling `import` lines from `FormalSystem/Automation.lean`
      (`FormulaEnumerator`, `DatasetGenerator`, `DataExport`, `EnrichedCountermodel`,
      `DatasetAssembly`, `ProofStepExtractor`, `InterestingnessMetrics`, `PrefilterSoundness`).
      This is the edit that actually makes the split real.
- [x] Re-point the aggregator's importers at specific library modules:
      `FormalSystem/Examples/BimodalProofs.lean` (named in the task description) **and**
      `FormalSystem/Examples/Walkthrough.lean` (not named, same fix required) and
      `Tests/BimodalTest/Integration/AutomationProofSystemTest.lean`.
      `FormalSystem/FormalSystem.lean` keeps importing the aggregator, which is library-only after
      the import deletion.
      *(deviation: altered — each of the three needed `Automation.Tactics.Commands` as well, which
      is where `modal_search`'s syntax is declared; `Tactics.UserTactics` alone left every
      `modal_search` call site as `unknown tactic`. `Walkthrough` and the integration test
      additionally take `ProofSearch.Core` and `ProofSearch.Strategies`.)*
- [ ] Populate `BimodalTools.lean` with imports of the **13 non-`Main` modules** and **no `*Main`
      module** — each `*Main` declares a root-namespace `main` and importing two collides.
- [ ] Re-root the 12 tooling `[[lean_exe]]` blocks in `lakefile.toml` to `BimodalTools.<X>Main`.
      Target **names are unchanged**. Leave `checkInitImports` (`srcDir = "scripts"`) alone.
- [ ] Redistribute the test-aggregator imports: remove the moved tests' imports from
      `Tests/BimodalTest.lean` and add them to `Tests/BimodalToolsTest.lean`. Keep the
      `NormalizationTest` import in `Tests/BimodalTest.lean` — that file is split in Phase 8.
- [ ] Hand-edit the 6 files whose `namespace FormalSystem.Automation` / `end` pair becomes
      `namespace BimodalTools` / `end BimodalTools`: `AxiomNames`, `DatasetGenerator`,
      `FormulaEnumerator`, `ForwardProofGenerator`, `ProofFirstBenchmark`,
      `ProofFirstGeneratorMain`. `EnumBenchmarkMain` declares no namespace and needs nothing.
- [x] Add `open FormalSystem.Automation` to the modules that now need it: `DatasetGenerator`,
      `FormulaEnumerator`, `ForwardProofGenerator`, `ProofFirstBenchmark`, `ProofStepExtractor`.
      (`BenchmarkAnchorsMain`, `DataExport`, `DatasetGeneratorMain` already carry it.) Drop the now-
      unused `SuccessPatterns` import from `ForwardProofGenerator`.
      *(deviation: altered — the plan anticipated only the `open FormalSystem.Automation` direction.
      The larger need was the OPPOSITE one, `open BimodalTools`, and the plan names none of it:
      six modules were hand-edited out of `namespace FormalSystem.Automation`, so every unqualified
      reference to their declarations from a file not itself inside `namespace BimodalTools` broke.
      Added `open BimodalTools` at 13 sites across `EnumBenchmarkMain`, `DatasetGeneratorMain` (x2),
      `BenchmarkAnchorsMain` (x2), `BenchmarkOracleMain` (x2), `ContrastiveGeneratorMain` (x2),
      `Tests/BimodalTest/Automation/NormalizationTest.lean` and three moved tests. Three further
      repairs of the same class: `open FormalSystem.Metalogic.Decidability` in `TraceExport` (it
      left that enclosing namespace), `open FormalSystem.Automation` in `ProofFirstGeneratorMain`
      (for `PatternKey`), and five stale `FormalSystem.Automation.*` FQNs there rewritten to
      `BimodalTools.*` plus two in `NormalizationTest`. The four moved tests whose namespace did not
      match their module name (`C5Smoke`, `Interestingness`, `ProofFirst`, and `FormulaMutatorTest`'s
      bare `BimodalTest.Automation`) were renamed under `BimodalToolsTest.*` by hand, since the
      module map could not reach them. NONE of this was visible until the 12 exe roots were built
      individually: they sit outside every `lake build` closure, so `lake build`, `lake build
      BimodalTools`, `lake build BimodalToolsTest` and `lake test` were ALL green while five of the
      13 roots did not compile. C25 is what caught it.)*
- [x] Hand-fix `scripts/measure-refactor-partitions.py`'s hardcoded
      `f"{LIB}.Metalogic.Decidability.TraceExport"` (around line 309), which rewrite class 2 will
      otherwise have turned into `BimodalTools.TraceExport` and which would append a phantom row to
      Phase 9's acceptance measurement. Either drop the append or guard it on the module existing.
      *(deviation: altered — the predicted rewrite did NOT happen. The literal is an f-string,
      `f"{LIB}.Metalogic.Decidability.TraceExport"`, whose source text begins `{LIB}` and so
      matches no mapping. The phantom-row hazard was real regardless, for the other reason: the
      append is unconditional. Guarded on `trace_export in g.modules` rather than dropped, so the
      script keeps working on a pre-move tree.)*
- [ ] Confirm `git diff --stat FormalSystem/Automation/` shows changes only to the staying library
      files — evidence the namespace map did not reach the library half.

**Timing**: 2.5 hours

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: This phase asserts **8 import deletions** from `FormalSystem/Automation.lean`,
**3 aggregator re-points**, **13 imports** in `BimodalTools.lean`, **12 exe re-roots**, **6
namespace hand-edits** and **5 `open` additions**. Each is confirmed at execution time by the
corresponding grep against the post-move tree (e.g. `grep -c '^import' BimodalTools.lean` must be
13; `grep -c 'root = "BimodalTools\.' lakefile.toml` must be 12), not by trusting this list.

**Verification**:
- `lake build` exits 0.
- `lake build BimodalTools` and `lake build BimodalToolsTest` exit 0.
- `lake test` exits 0.
- `bash scripts/check-module-invariants.sh` reports 0 FAIL, including the new B3.
- `grep -rn 'namespace FormalSystem.Automation' BimodalTools/` returns nothing.

**Files to modify**:
- 25 module files relocated to `BimodalTools/` (by `move-modules.py`)
- 8 test files relocated to `Tests/BimodalToolsTest/` (by `move-modules.py`)
- `FormalSystem/Automation.lean` - 8 import deletions
- `FormalSystem/Examples/BimodalProofs.lean`, `FormalSystem/Examples/Walkthrough.lean`,
  `Tests/BimodalTest/Integration/AutomationProofSystemTest.lean` - aggregator re-points
- `BimodalTools.lean` - 13 imports
- `Tests/BimodalTest.lean`, `Tests/BimodalToolsTest.lean` - import redistribution
- `lakefile.toml` - 12 exe root changes
- `scripts/measure-refactor-partitions.py` - hand-fix the rewritten `TraceExport` literal
- ~177 citation sites across `FormalSystem/`, `Tests/`, `scripts/`, `docs/`, `typst/`, `.github/`
  (by `move-modules.py`)

---

### Phase 7: Close the bare-form citations and prose [COMPLETED]

**Goal**: The citations `move-modules.py` deliberately does not rewrite — bare `Automation/<tool>.lean`
forms, which are *stale* after this move rather than *correct* after it — are hand-corrected.

**Tasks**:
- [x] Fix the bare-form citation sites enumerated by the research:
      `typst/chapters/p4-dataset-pipeline.typ` (EnrichedCountermodel, DatasetGeneratorMain),
      `typst/chapters/ax-machine-appendix.typ` (DataExport),
      `docs/development/NAMING_CONVENTION_DEVIATION.md` (MachineAppendixMain, DatasetGeneratorMain),
      `docs/reference/paper-definitions-of-record.md` (DataExport, DatasetGenerator),
      `scripts/check-module-invariants.sh` C22's header comment (AxiomNames, ProofExtractorMain —
      note C22's own hardcoded full-prefix paths were already rewritten by class 3),
      `FormalSystem/Metalogic/Decidability/README.md` (TraceExporterMain),
      `Tests/BimodalTest.lean` prose block (3 bare `Main` citations).
      *(deviation: altered — 14 live line-sites closed, not 11. Three beyond the plan's list:
      `NAMING_CONVENTION_DEVIATION.md:453`, the second citation on
      `p4-dataset-pipeline.typ:30` (`Automation/README.md` -> `BimodalTools/README.md`), and
      `BimodalTools/MachineAppendixMain.lean:40`, inside a file that itself moved. Four further
      prose repairs the plan does not name: `FormalSystem/Metalogic/Decidability/README.md` lost
      its `TraceExport.lean` table row and its flowchart mention entirely — the module left that
      directory, so correcting the citation was not enough — and gained a short note saying where
      it went and that the certificate TYPES stay; `docs/development/MODULE_INVARIANTS.md` had six
      scan-root descriptions gone stale in Phase 2 (`B2`, `C17`, `C25N`, `C27`, `C29`, `C30`) and
      carried no `B3` row at all, both now fixed.)*
- [ ] Update the two tooling-namespace entries in `scripts/module-invariants-allowlist.txt` and
      their bare `Automation/...` path comments.
- [ ] Update `FormalSystem/Automation.lean`'s module-list docstring to reflect the 8 removed
      imports.
- [ ] Re-grep for any remaining bare `Automation/` citation of a moved module and confirm zero.

**Timing**: 0.75 hours

**Depends on**: 6

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts **11 bare-form sites** plus 2 allowlist entries. The
authoritative list is the re-grep performed in Phase 5, not the report's snapshot; reconcile the two
and close whichever set is larger.

**Verification**:
- Every changed hunk lies inside a comment, docstring, prose file, or allowlist data line — confirm
  by diff read-through (this is what the `prose` tier obliges).
- `bash scripts/check-module-invariants.sh --no-build` reports 0 FAIL, including C20's
  `file.lean:NNN` citation check and C22.
- `bash scripts/typst-sync-check.sh` exits 0.
  *(deviation: altered — exits 1 BEFORE and AFTER, for a pre-existing reason this task does not
  own. Baseline captured from a worktree at the pre-task commit: `TOTAL_VIOLATIONS=10`,
  `MISMATCH_COUNT=2`, `MODULE_MAP_MISMATCHES=7`, exit 1. The move briefly took Check 1 from 10 to
  **32** violations, because that check resolves every backticked identifier against the single
  Lean source root `FormalSystem/` and 22 of the manual's dataset-pipeline and machine-appendix
  citations name declarations that had just left it. Repaired by giving Check 1 a colon-separated
  root LIST (`LEAN_SRC_ROOTS`, Check 1 only — Checks 2-3 still take `BIMODAL_DIR` as one
  directory path). Check 1 is now back at the baseline set. `MODULE_MAP_MISMATCHES` was taken from
  7 to **0** by regenerating `typst/generated/automation-module-map.typ`, which confirmed the
  research finding that `typst-module-map.sh` needs no edit: every row it emits is a staying
  library module. `MISMATCH_COUNT=2` is left alone deliberately — it is
  `sorry-total: committed=4 live=0` for the row labelled "WeakCanonical/ (archived,
  Boneyard/Kamp/)", and regenerating it would delete a true statement about archived material
  that the generator can no longer see since the archive left `FormalSystem/`. That belongs to
  whoever owns the archive relocation. See the summary's Follow-ups.)*

**Files to modify**:
- `typst/chapters/p4-dataset-pipeline.typ`, `typst/chapters/ax-machine-appendix.typ`
- `docs/development/NAMING_CONVENTION_DEVIATION.md`, `docs/reference/paper-definitions-of-record.md`
- `scripts/check-module-invariants.sh` (C22 header comment only)
- `FormalSystem/Metalogic/Decidability/README.md`
- `Tests/BimodalTest.lean` (prose block)
- `scripts/module-invariants-allowlist.txt`
- `FormalSystem/Automation.lean` (module-list docstring)

---

### Phase 8: Split NormalizationTest, drop the C6 manifest line, record the SuccessPatterns decision [NOT STARTED]

**Goal**: The one test that straddles the split is divided rather than moved, the manifest
simplification the aggregator enables is taken, and the `SuccessPatterns` decision is written down
where the next reader will look for it.

**Tasks**:
- [ ] Split `Tests/BimodalTest/Automation/NormalizationTest.lean` (588 lines). Only two regions
      depend on the enumerator: the `decide`-timing block (around lines 233-250, referencing
      `smallConfig` / `enumerateUpToDepth`) and `section EnumeratorCounts` (around lines 560-586).
      Extract exactly those into `Tests/BimodalToolsTest/EnumeratorCountsTest.lean`. Everything
      else stays, so the library's normalization coverage stays inside `lake test`.
- [ ] Wire the new test into `Tests/BimodalToolsTest.lean`; confirm the retained file no longer
      imports any `BimodalTools` module.
- [ ] Delete the C6 manifest line for `FormalSystem.Automation.ProofFirstBenchmark` in
      `scripts/check-module-invariants.sh`. The `BimodalTools.lean` aggregator now makes that
      module reachable, so the manifest entry is deleted rather than renamed — a net simplification.
      Confirm `FormulaMutatorTest` and `ProofFirstTests` remain C6-manifested (they import an exe
      root carrying `main`) with their paths updated by the move.
- [ ] Record the `SuccessPatterns` decision in `FormalSystem/Automation/README.md` as
      PUBLICATION_REFACTOR Phase 3 bullet 4 requires: it stays whole in the library because it has
      no IO/JSON dependency, has two live library call sites in `ProofSearch/{Core,Strategies}`
      exercised by `ProofSearchBenchmark`, and the tooling reaches its `PatternKey`/`GoalCategory`
      vocabulary through the sanctioned `BimodalTools -> FormalSystem` direction.
- [ ] Note in the same record that PUBLICATION_REFACTOR.md Phase 4's "cut
      `ProofSearch.Core -> SuccessPatterns`" bullet (around line 358) is superseded by this
      decision and is a no-op when Phase 4 is planned.

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: full

**Scope Hypothesis**: The assertion that **exactly two regions** of `NormalizationTest.lean` depend
on the enumerator is a hypothesis. Confirm it mechanically: after the split, the retained file must
produce zero matches for `grep -nE 'BimodalTools|FormulaEnumerator|enumerateUpToDepth|smallConfig'`.
If a third region surfaces, extract it too and record the divergence.

**Verification**:
- `lake test` exits 0 and the retained `NormalizationTest.lean` still carries its `Normalization`
  `#guard`s (grep for them and confirm a non-zero count).
- `lake build BimodalToolsTest` exits 0 and compiles `EnumeratorCountsTest`.
- `bash scripts/check-module-invariants.sh` reports 0 FAIL, C6 included.
- The retained `NormalizationTest.lean` imports no `BimodalTools` module.

**Files to modify**:
- `Tests/BimodalTest/Automation/NormalizationTest.lean` - two regions extracted
- `Tests/BimodalToolsTest/EnumeratorCountsTest.lean` - new
- `Tests/BimodalToolsTest.lean` - new import
- `scripts/check-module-invariants.sh` - C6 manifest line deleted
- `FormalSystem/Automation/README.md` - SuccessPatterns decision record

---

### Phase 9: CI build steps and full acceptance [NOT STARTED]

**Goal**: CI compiles both new libraries, every inventory is regenerated, and each of the task's
four acceptance criteria is asserted with evidence.

**Tasks**:
- [ ] Add two CI steps to `.github/workflows/ci.yml` — `lake build BimodalTools` and
      `lake build BimodalToolsTest` — placed **after** the existing "Compile `lean_exe` roots" step
      so they reuse the warm cache, following the step-placement convention in
      `docs/development/CI_CD_PROCESS.md`. Two steps, not one: the `BimodalToolsTest` closure does
      not reach `DatasetAssembly` or `PrefilterSoundness`, so without the `BimodalTools` step those
      two are compiled by nothing in CI.
- [ ] Confirm the existing "Compile `lean_exe` roots" step needs **no edit**: it and C25 read roots
      at run time via `python3 scripts/lake_targets.py exe-roots`, so the re-rooting is picked up
      automatically. Verify by running that command and checking all 12 roots now read
      `BimodalTools.*`.
- [ ] Regenerate every inventory block: `bash scripts/check-module-invariants.sh --emit-inventory`,
      covering `FormalSystem/Automation/README.md`, `BimodalTools/README.md` and
      `Tests/BimodalToolsTest/README.md`. INV gates these.
- [ ] **Acceptance 1 — no `.olean` under BimodalTools from a default build.** After a clean
      `lake build` (not `lake build BimodalTools`), assert
      `find .lake/build/lib/lean/BimodalTools -name '*.olean'` is empty. Check the **build**
      directory, not the source tree: Lake places `.olean` files under `.lake/build/lib/lean/`, so a
      walk of `BimodalTools/` would be empty for the wrong reason and prove nothing.
- [ ] **Acceptance 2 — the separation invariant exists and passes.** `pass B3` in the harness output.
- [ ] **Acceptance 3 — `lake build BimodalToolsTest` exits 0 in CI.** Confirmed locally plus the new
      CI step.
- [ ] **Acceptance 4 — harness green.** `bash scripts/check-module-invariants.sh` reports 0 FAIL.
- [ ] Assert `python3 scripts/measure-refactor-partitions.py automation-partition` now reports an
      **empty tooling set** (and no phantom `TraceExport` row, which Phase 6's hand-fix prevents).
- [ ] Assert C7's module and line counts across `FormalSystem` + `BimodalTools` are unchanged from
      the pre-move baseline — the direct check that no gate's denominator silently shrank.
- [ ] Assert C2, C3 and C14 are **byte-identical** to their pre-move state. This refactor carries no
      proof obligation; if any of the three moved, the move was wrong, not the baseline.
- [ ] Verify the aggregator earns its keep: temporarily drop `DatasetAssembly` from
      `BimodalTools.lean`, confirm `lake build BimodalTools` still succeeds but the module is no
      longer compiled (or that the check catches it), then restore. Record what this probe actually
      demonstrated rather than asserting an untested claim.
- [ ] `bash scripts/typst-sync-check.sh` exits 0 — the acceptance for "update typst-module-map.sh",
      whose correct answer is no edit.

**Timing**: 1.5 hours

**Depends on**: 8

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts the partition script reports **0** tooling modules and that
C7's combined counts are **unchanged**. Both are confirmed by running the commands and diffing
against the pre-move baseline captured in the research report's Appendix, not by assumption. A
non-zero partition count or a changed C7 total is a finding to investigate, not a number to adjust.

**Verification**:
- All four acceptance criteria asserted with captured command output.
- `bash scripts/check-module-invariants.sh` reports 0 FAIL.
- `lake build`, `lake build BimodalTools`, `lake build BimodalToolsTest`, `lake test` all exit 0.
- `.github/workflows/ci.yml` parses.

**Files to modify**:
- `.github/workflows/ci.yml` - two new build steps
- `FormalSystem/Automation/README.md`, `BimodalTools/README.md`,
  `Tests/BimodalToolsTest/README.md` - regenerated inventory blocks

---

## Lean Challenge Statements

This plan carries **no** Lean challenge statements, and this section is deliberately empty of
declarations. The task is a build-graph and module-location refactor with zero proof obligations:
no theorem is stated, no `sorry` is introduced, and no axiom is added. The `- **Goals**:` bullets
above name no theorem identifiers, so the identifier sets on both sides of the cross-validation rule
agree — both are empty. C2, C3 and C14 are expected to be byte-identical before and after, and
Phase 9 asserts exactly that.

## Testing & Validation

- [ ] `lake build` exits 0 and emits no `.olean` under `.lake/build/lib/lean/BimodalTools/`.
- [ ] `lake build BimodalTools` exits 0.
- [ ] `lake build BimodalToolsTest` exits 0.
- [ ] `lake test` exits 0 and still exercises library `Normalization` coverage.
- [ ] `bash scripts/check-module-invariants.sh` reports 0 FAIL, with `pass B3` present.
- [ ] `bash scripts/check-module-invariants.sh --no-build` matches the research Appendix baseline
      (0 FAIL) for every check that was green before the move.
- [ ] `python3 scripts/measure-refactor-partitions.py automation-partition` reports an empty tooling
      set.
- [ ] `python3 scripts/lake_targets.py exe-roots` lists all 12 tooling roots under `BimodalTools.*`
      with unchanged target names.
- [ ] `bash scripts/typst-sync-check.sh` exits 0.
- [ ] `bash scripts/readme-lint.sh FormalSystem BimodalTools` exits 0.
- [ ] `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools` exits 0.
- [ ] C2, C3 and C14 baselines byte-identical to pre-move.
- [ ] C25N negative test (Phase 2) and B3 negative test (Phase 3) each produced the expected FAIL.

## Artifacts & Outputs

- `lakefile.toml` - two new `lean_lib` targets, 12 re-rooted `lean_exe` targets
- `BimodalTools.lean` - new library aggregator importing the 13 non-`Main` tooling modules
- `BimodalTools/` - 25 relocated tooling modules plus `README.md`
- `Tests/BimodalToolsTest.lean` and `Tests/BimodalToolsTest/` - 8 relocated tests, one new split-off
  test, plus `README.md`
- `scripts/check-module-invariants.sh` - widened scan roots, new B3 check, C6 manifest line removed
- `scripts/move-modules.py` - `MODULE_ROOT_DIRS` entry for `BimodalToolsTest`
- `scripts/measure-refactor-partitions.py` - hand-fixed `TraceExport` literal
- `.github/workflows/ci.yml` - widened gate invocations plus two new build steps
- `FormalSystem/Automation/README.md` - `SuccessPatterns` decision record
- `specs/632_bimodaltools_split/summaries/01_bimodaltools-library-split-summary.md`

## Rollback/Contingency

Each of Phases 1-5 and 7-9 ends green and is committed on its own, so rollback for any of them is
`git revert` of that phase's commit.

Phase 6 is the only atomic-batch phase and the only one that cannot be bisected. Its contingency:

- **Before starting Phase 6**, take a durable, non-reverting checkpoint with
  `bash .claude/scripts/git-snapshot.sh 632 --no-revert`. This preserves the Phase 5 state without
  touching the working tree — it is a checkpoint, not a rollback.
- **If Phase 6 cannot be brought green**, the recovery is to return to the Phase 5 commit. That is a
  genuine rollback of uncommitted work, so follow `context/contracts/recovery.md`'s rollback rung
  for the exact invocation shape (including its out-of-scope override flag, which this whole-tree
  case will need since the move touches paths outside any narrow `file_scope`). Do not reach for a
  destructive git command directly.
- **Fix forward is strongly preferred** over rollback here: the move is mechanical and its failures
  are almost always a missing `open`, a missed namespace hand-edit, or a citation the map did not
  cover — all cheaper to correct than to redo. Never discard uncommitted changes to reach a passing
  build.

If the Phase 6 precondition fails (a concurrent uncommitted edit under `FormalSystem/Automation/`),
stop before running `move-modules.py` at all. No rollback is needed because nothing has moved.
