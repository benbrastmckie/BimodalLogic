# Implementation Plan: Task #597

- **Task**: 597 - Adopt Mathlib's standard linter set, following cslib's precedent
- **Status**: [IMPLEMENTING]
- **Effort**: 25 hours
- **Dependencies**: Task 585 (compiler-warning burn-down + C28 gate) -- completed
- **Research Inputs**: specs/597_adopt_mathlib_standard_linter_set/reports/01_mathlib-linter-set-survey.md
- **Artifacts**: plans/01_mathlib-linter-set-adoption.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Enable `weak.linter.mathlibStandardSet` in a package-level `[leanOptions]` table of
`lakefile.toml`, so the 13 `lean_exe` roots are covered as well as both libraries. The enablement
is staged. Phase 1 turns on the whole set, plus a temporary `weak.linter.<X> = false` line for
every class that is not yet at zero. Each later phase takes one linter class (or one directory
slice of `longLine`) to zero and deletes that class's temporary line. As a result `lake build
--wfail` stays green after every phase and the C28 baseline stays at zero. The task is done when
the lakefile carries only documented permanent opt-outs, the build is green under `--wfail`, there
are no blanket suppressions and no unscoped `maxHeartbeats`, and a new ratchet check enforces that.

This is lint and configuration hygiene only. No theorem statements are added or changed in
meaning, so this plan deliberately has **no Lean Challenge Statements section**: the task proves
nothing new.

### Research Integration

The research report re-measured the tree and corrects the task description's premises. The plan
is built on the corrected facts:

- The file is `lakefile.toml`, not `lakefile.lean`.
- Only **1** blanket suppression remains, at `Semantics/Ultraproduct/Carrier.lean:81`, not 4.
- There are 50 scoped and 7 unscoped `maxHeartbeats`.
- `longFile` stays inert unless `weak.linter.style.longFile = 1500` is set.
- **CI's `--wfail` rules out a non-zero C28 baseline.** Every enabled class must reach zero or
  carry a documented lakefile opt-out. The description's phrase "baseline the rest under C28" is
  therefore read as "C28 disposition rows at zero count".
- Measured surface: 2,451 warnings in 283 files across 14 classes, from 555 of the 590 files. The
  projection is about 2,700 once the 35 unmeasured files are included.
- **5 test files turn a `longLine` warning into an error** through `#guard_msgs`.
- The blanket-suppression ratchet should extend C29's comment-masked walk and start from a
  **zero** baseline.

The phase order follows the report's recommendation (cheapest and most isolated first). The
largest classes are split so that no phase is longer than 2 hours.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap consultation requested for this dispatch.

## Goals & Non-Goals

**Goals**:
- The Mathlib standard linter set is enabled at package level, together with the length limit
  that switches on the long-file linter.
- Every linter class in the set is either at zero warnings or is a documented permanent opt-out
  with a written reason.
- The one remaining blanket linter suppression is removed by restructuring, not re-suppressed.
- All 7 unscoped heartbeat budgets are converted to declaration-scoped form, and every scoped
  budget carries Mathlib's trailing reason comment after the in keyword.
- The 38 files over 1,500 lines get Mathlib's in-source long-file baseline form. They are not
  split.
- A ratchet check (new C30) fails on any unscoped linter set-option (the long-file baseline form
  excepted) and on any unscoped heartbeat budget. It is documented in MODULE_INVARIANTS.md.
- A lint-suppression policy section is added to LEAN_STYLE_GUIDE.md, modelled on cslib's policy
  doc and listing every permanent opt-out.

**Non-Goals**:
- Splitting long files, unless a split is independently justified. The task description forbids
  splitting them just to satisfy the linter.
- Bulk-suppressing any class to reach zero.
- Adopting cslib's four inert opt-outs (pythonStyle, checkInitImports, allScriptsDocumented,
  unicodeLinter). None of them runs during the build at this Mathlib.
- C16 environment linters (runLinter / nolints.json). That area is separate and is not touched.
- Removing CI's `--wfail`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Every `leanOptions` edit forces a full rebuild of the tree | M | H | During a phase, verify per file with `lake env lean -Dweak.linter.mathlibStandardSet=true -Dweak.linter.<X>=true <file>`. This ignores lakefile options and writes no build outputs. Edit the lakefile once, at phase close, followed by one guarded build. Adjacent phases may batch their line deletions into one rebuild. |
| The 35 files left unmeasured by the research sweep hide extra warnings (about 230 `longLine`, about 13 `maxHeartbeats`) | M | H | Phase 1 does an authoritative per-class re-measurement across all 590 files and records the per-class counts in the phase notes. Later phases' scope hypotheses are corrected from that table. |
| The `#guard_msgs` breakage is an **error**, not a warning | H | H | Fix the 5 test files in Phase 12, before deleting the `longLine` opt-out in that same phase. |
| Removing an instance hypothesis cascades up the call graph, or causes a `DecidableEq` instance mismatch | H | M | Phases 13 and 14 iterate to a fixpoint and build after each wave. Phase 14 has a pre-declared, bounded fallback: a documented permanent lakefile opt-out for `unusedDecidableInType`, with the reason and evidence recorded. |
| A `flexible` fix changes proof behaviour when a `simp only` set is incomplete | M | M | Take the lemma list from `simp?`, and rebuild each file before moving on. |
| A library-level `leanOptions` entry does not override a package-level key the way it is expected to (this matters for the `hashCommand` opt-out scoped to `BimodalTest`) | M | L | Phase 1 probes it with one test file. If the override does not work, Phase 5 falls back to cslib's per-library form of the same option. |
| Concurrent sessions have many uncommitted Lean edits in the working tree (see git status) | H | H | Stage only files this phase touched, as an explicit file list. Never use `git add -A`, a directory pathspec, or `commit -am`. Rebuild on top of the other sessions' edits, and do not revert them. |
| C28 exits 2 on a class that has no disposition row | M | H | Phase 1 adds disposition rows for every set member that `warning-budget.py` can observe, including the zero-count classes. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 15 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9 | 8 |
| 10 | 10 | 9 |
| 11 | 11 | 10 |
| 12 | 12 | 11 |
| 13 | 13 | 12 |
| 14 | 14 | 13 |
| 15 | 16 | 14, 15 |

Phases within the same wave can execute in parallel. The Lean-editing phases are deliberately
sequential, for three reasons: they overlap in which files they touch; each one edits the shared
`lakefile.toml` and `scripts/warning-budget.txt`; and each lakefile edit forces a full rebuild.
Phase 15 edits only the harness script and its doc, so it can run alongside the Lean phases.

### Phase 1: Package-level enablement, temporary opt-outs, authoritative re-measurement [COMPLETED]

**Goal**: Turn the full linter set on at package level while the build stays green, and replace
the research sweep's partial counts with authoritative ones.

**Tasks**:
- [x] Add a top-level `[leanOptions]` table to `lakefile.toml` containing
      `weak.linter.mathlibStandardSet = true` and `weak.linter.style.longFile = 1500`. Keep the
      per-library `pp.unicode.fun` / `autoImplicit` entries unchanged. Add a header comment that
      explains the package-level placement: the `lean_exe` roots do not inherit library options.
- [x] Add a `weak.linter.<X> = false` line, each with a `# TEMPORARY (staged enablement)`
      comment, for every class with a non-zero count: `style.longLine`, `style.emptyLine`,
      `unusedFintypeInType`, `unusedDecidableInType`, `hashCommand`, `style.show`, `flexible`,
      `style.maxHeartbeats`, `style.setOption`, `style.docString`, `style.multiGoal`,
      `style.openClassical`, `style.missingEnd`, `style.cdot`, and `style.longFile`. `longFile`
      is included because it only fires once the 1500 limit is set. Do not cite task numbers in
      these comments. *(deviation: altered — longFile held off by commenting out the `= 1500` line, since TOML forbids a duplicate key)*
- [x] Re-measure all 590 live files once no other session is rebuilding. Use the per-file sweep
      from the research appendix (`lake env lean -Dweak.linter.mathlibStandardSet=true
      -Dweak.linter.style.longFile=1500`, `xargs -P5`). Record per-class and per-directory counts
      in this phase's completion notes. Any file that still fails is either a `#guard_msgs` file
      (expected) or needs a named explanation.
- [x] Probe library-over-package override. Set a `BimodalTest`-level
      `leanOptions = {..., weak.linter.hashCommand = false}` against a package-level `true` and
      confirm on one test file that the library value wins. Record the result for Phase 5. *(deviation: altered — settled from Lake source (`LeanLib.leanOptions`) instead of a probe build)*
- [x] Run `warning-budget.py` and learn the exact class-name spelling it observes (for example
      `linter.style.longLine`). Add a `# disposition <class> blocking <reason>` row for every set
      member it can observe. Confirm that rows for classes with zero observations are accepted
      and not rejected.
- [x] Do a guarded full build of all targets (`lake build FormalSystem BimodalTest` plus every exe
      root) with `--wfail`. It must be green. Run `check-module-invariants.sh` with C28 and C29
      green.

**Timing**: 1.5 hours (plus one full rebuild)

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: The 14 classes and the counts in the research table are what the build will
observe. The re-measurement above confirms them or supersedes them, and later phases use the
superseding numbers.

**Files to modify**:
- `lakefile.toml` - package `[leanOptions]` table and the temporary opt-outs
- `scripts/warning-budget.txt` - disposition rows

**Verification**:
- `lake build --wfail` is green across all targets, and C28/C29 pass.
- The re-measurement table is recorded in the plan's phase notes.

**Phase 1 notes (authoritative re-measurement, 2026-09-18)**: per-file sweep of all 591 live files
(590 under FormalSystem/ + Tests/, plus `scripts/CheckInitImportsMain.lean` and the root
`FormalSystem.lean`), `lake env lean -DautoImplicit=false -Dpp.unicode.fun=true
-Dweak.linter.mathlibStandardSet=true -Dweak.linter.style.longFile=1500`, `xargs -P6`, 949 s.
Total 2,685 warnings. Every file elaborated; the only failures are the 5 expected `#guard_msgs`
files (17 guard mismatches: BoxSpreadProbe 1, RayRegionProbe 3, RegionGateProbe 1,
TableauConformance 3, TemporalWitnessProbe 9).

| Class | Warnings | Files |
|-------|----------|-------|
| style.longLine | 1,010 | 202 |
| style.emptyLine | 540 | 33 |
| unusedFintypeInType | 274 | 55 |
| unusedDecidableInType | 249 | 53 |
| hashCommand | 241 | 10 (11 of them in FormalSystem: Normalization 4, BiLasso/Examples 4, BiLasso/Check 3) |
| style.show | 196 | 62 |
| flexible | 88 | 11 |
| style.longFile (at 1500) | 38 | 38 |
| style.maxHeartbeats | 32 | 11 |
| style.setOption | 7 | 3 |
| style.docString | 4 | 4 |
| style.multiGoal | 2 | 1 |
| style.openClassical | 2 | 2 |
| style.missingEnd | 1 | 1 |
| style.cdot | 1 | 1 |

`longLine` by directory: Metalogic/Decidability 206, Semantics 170, Metalogic/WeakCanonical 121,
Metalogic/Conservativity(+.lean) 138, Tests 87, Theorems 65, Syntax 58, Metalogic/Independence 47,
remaining FormalSystem ~118. Phase 11's share (rest of FormalSystem) is therefore ~600, above its
350 split threshold.

Deviations recorded in this phase:
- `longFile = 1500` is held commented-out rather than paired with a `longFile = 0` line: a TOML
  key cannot be set twice. Phase 4 uncomments it.
- Library-over-package override settled from Lake source rather than a probe build:
  `LeanLib.leanOptions = buildType ++ pkg.leanOptions ++ config.leanOptions`, and `LeanOptions`
  `++` lets the later entry override a clashing one, so a `BimodalTest` value wins.
- `scripts/warning-budget.py` could not classify the new classes: its trailer regex stopped at
  the first `.` of `linter.style.X`, and the longFile trailer ends in `0`, not `false`. Both fixed.

---

### Phase 2: Trivial classes and the Carrier.lean blanket suppression [COMPLETED]

**Goal**: Take `docString` (4), `multiGoal` (2), `openClassical` (2), `missingEnd` (1) and `cdot`
(1) to zero, and remove the one remaining blanket suppression.

**Tasks**:
- [x] Fix each warning site reported by the per-file sweep. For `openClassical`, scope it to
      `open Classical in` on the declarations that need it, at `DeterministicBridge.lean:87` and
      `PlusTruth.lean:69`. Do not write `set_option ... in open Classical`: cslib's policy doc
      records that this form scopes the `open` itself. *(deviation: altered — both files elaborate with no `Classical` at all, so the `open scoped Classical` lines were deleted outright rather than scoped)*
- [x] Restructure `FormalSystem/Semantics/Ultraproduct/Carrier.lean` as its own comment
      prescribes. Split the `variable` block so that `[∀ i, LinearOrder (D i)]` and
      `[∀ i, IsOrderedAddMonoid (D i)]` are in scope only for the declarations that depend on the
      order. Then delete the file-scoped `set_option linter.* false`. The fallback is a
      per-declaration `set_option ... false in` with a C29 reason.
- [x] Delete the five temporary lakefile lines, then do a guarded full build with `--wfail`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: 10 warning sites across about 9 files, plus 1 blanket suppression. The
Phase 1 re-measurement confirms these numbers.

**Files to modify**:
- `FormalSystem/Semantics/Ultraproduct/Carrier.lean` - split the variable block and remove the
  blanket suppression
- The site files named by the sweep: `Bridge/IntTruth.lean`, `Bundle/LimitMCS.lean`,
  `RamseyFactorization.lean`, `DeterministicBridge.lean`, `PlusTruth.lean`, and the 4
  `docString` sites
- `lakefile.toml` - remove the 5 temporary lines

**Phase 2 notes**: docString fixes were trailing-whitespace/blank-line docstring ends; `multiGoal`
at `IntTruth.lean:375` was an unassigned `?f` metavariable goal left by `rw [truthAt_box_iff_base]`,
fixed by `(f := f)`; `Carrier.lean` now has a group-only base `variable` block, two
`section Order` blocks with `[∀ i, LinearOrder (D i)]`, and `IsOrderedAddMonoid` as a binder of
its one instance. Full `--wfail` build green (1,267 s); C28/C29 pass (C29 now 6 sites). The INV
inventory blocks in 5 READMEs were regenerated for the changed line counts.

**Verification**:
- A grep for file-level `set_option linter\.[^ ]+ false$` (not followed by `in`) in live trees
  returns 0 hits.
- `lake build --wfail` is green.

---

### Phase 3: Heartbeat-budget group (`setOption` + `style.maxHeartbeats`) [COMPLETED]

**Goal**: Convert the 7 unscoped `maxHeartbeats` to declaration-scoped form, and bring every
scoped site into Mathlib's comment-after-`in` form.

**Tasks**:
- [x] Convert each unscoped site by trial, one declaration at a time: remove the budget and build.
      Add `set_option maxHeartbeats N in` with a trailing `--` reason only on declarations that
      actually need it. Choose N with `count_heartbeats in`. Do not copy a budget blindly onto
      every declaration. *(deviation: altered — measured every declaration in one pass with `#count_heartbeats in` under `set_option Elab.async false` (without it, async proofs report only the header cost) instead of remove-and-rebuild trials)* The sites are:
      - `Termination/SubformulaProperty.lean`: 5 sections (lines 470, 595, 690, 801 and 1165),
        covering about 37 theorems;
      - `Verified/Bridge/TemporalSaturation.lean:42`: file-scoped, 6 declarations;
      - `Decidability/Tableau.lean:2387`: `section ProgressLemmas`.
- [x] Rewrite about 31 scoped sites whose reason sits above the docstring. Move the reason into a
      `--` comment placed after the `in` and before the declaration. Mathlib requires this
      placement: a docstring does not count, and a comment above the `set_option` does not count.
      Most of these sites are in `Termination/MintBound/*`, `Bridge/{Prop,Box}Saturation`,
      `CountermodelExtraction` (lines 507 and 593) and `TemporalOrder` (lines 197 and 200).
- [x] Delete the `style.setOption` and `style.maxHeartbeats` temporary lines, then do a guarded
      full build with `--wfail`.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: 7 unscoped sites and about 31 scoped sites that need rewriting, which is
about 31 `style.maxHeartbeats` warnings in total counting the unmeasured files. Confirm this
before editing with `grep -rn 'set_option maxHeartbeats' FormalSystem Tests`, and compare the
result with the per-file sweep's warning list.

**Files to modify**:
- `FormalSystem/Metalogic/**/Termination/SubformulaProperty.lean`,
  `**/Verified/Bridge/TemporalSaturation.lean`, `**/Decidability/Tableau.lean` - scope the budgets
- The files with scoped sites listed by the sweep - move the reason comment
- `lakefile.toml` - remove 2 temporary lines

**Phase 3 notes**: measured (thousands of heartbeats as `maxHeartbeats` counts them):
SubformulaProperty — all 36 rule lemmas are over the default (34 at 0.86-0.90M, `serialityRule`
and `timeLinearity` at 2.09M), budgeted 1,200,000 and 3,000,000 per declaration; Tableau
`ProgressLemmas` — 5 of 28 over (three `applyRule` sweeps at ~0.77M -> 1,600,000, two
`findApplicableRule` picks at ~0.22M -> 400,000), the other 23 need no budget; TemporalSaturation
— all 6 under 5,000, so its file-wide budget was simply deleted (its docstring claim updated).
The 32 scoped sites got a reason comment after the `in`; `UntlSnceFree.lean` swapped its two
prefixes so C29's reason block stays adjacent to the linter suppression. Full `--wfail` build
green (1,169 s); C28/C29 pass.

**Verification**:
- A grep for `set_option maxHeartbeats [0-9]+\s*$` (no trailing `in`) returns 0 hits.
- `lake build --wfail` is green.

---

### Phase 4: `longFile` in-source baselines [COMPLETED]

**Goal**: Make `longFile` fire and pass by baselining it inside each long file, not by splitting
files.

**Tasks**:
- [x] For each file over 1,500 lines, add `set_option linter.style.longFile N` near the top of the
      file. N is Mathlib's `candidate = (lines/100)*100 + 200`. The linter itself checks that N is
      tight. This form is a baseline, not a suppression, and the Phase 15 ratchet will allow it.
- [x] Delete the `style.longFile` temporary line, then do a guarded full build with `--wfail`.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: 38 files over 1,500 lines; the largest is `EFGames/GapDetection.lean` at
5,090. Line counts drift, so confirm with
`find FormalSystem Tests -name '*.lean' -not -path '*/Boneyard/*' | xargs wc -l | awk '$1>1500'`
immediately before editing.

**Files to modify**:
- The long files (about 38) - one baseline line each
- `lakefile.toml` - remove 1 temporary line

**Phase 4 notes**: 38 files baselined (the set_option sits after each module docstring, since
the header linter wants the docstring first). The accepted window for a baseline N is
`N-200 <= lines < N`, so later phases that remove blank lines (Phase 6) or reflow long lines
(Phases 9-12) must re-tighten N; the helper that inserted them recomputes N on re-run. The
lakefile's `longFile = 1500` is now live. Full `--wfail` build green (1,219 s); C28/C29 pass.

**Verification**:
- `lake build --wfail` is green, and no `longFile` warning appears.

---

### Phase 5: `hashCommand` permanent opt-out for the test library [COMPLETED]

**Goal**: Settle `hashCommand`'s 241 warnings. All of them are in `Tests/`, where `#eval` and
`#guard` probes are the whole point of the files.

**Tasks**:
- [x] Move the opt-out from the package-level temporary line to the `BimodalTest` library's
      `leanOptions` (`weak.linter.hashCommand = false`), with a permanent reason comment. This
      follows cslib's per-library precedent for its tests. If Phase 1's probe showed that the
      library value does not override the package value, use the fallback recorded there.
- [x] Confirm that `FormalSystem` and the exe roots produce no `hashCommand` warnings, then fix
      any that do. The research measured all of them in `Tests/`. *(deviation: altered — the re-measurement found 11 in FormalSystem, all `#guard` evaluator smoke tests (Normalization 4, BiLasso/Examples 4, BiLasso/Check 3); each got a per-command `set_option linter.hashCommand false in` with a C29 reason, since a kernel `decide` would not test what they test)*
- [x] Run a guarded full build with `--wfail`.

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: 241 warnings in 10 files, all under `Tests/`. The Phase 1 re-measurement
confirms that none are outside `Tests/`.

**Files to modify**:
- `lakefile.toml` - remove the package-level temporary line and add the `BimodalTest` library
  opt-out

**Phase 5 notes**: the `BimodalTest` library-level `weak.linter.hashCommand = false` overrides
the package set (confirmed by the green `--wfail` build, which covers the 230 test-library sites).
This build also verified the Phase 4 citation re-pointing. Full `--wfail` build green (1,097 s);
C28/C29 pass (C29 now 17 sites).

**Verification**:
- `lake build --wfail` is green, and the `hashCommand` class shows zero in `FormalSystem`.

---

### Phase 6: `emptyLine` [COMPLETED]

**Goal**: Remove the blank lines inside commands that the `emptyLine` linter flags.

**Tasks**:
- [x] Fix the sites file by file, largest first: `ProofExtractorMain.lean` (158),
      `ProofSearch/Core.lean` (48), `Tactics/Search.lean` (36), then the rest. After each file,
      re-run the per-file sweep for `emptyLine` and confirm zero.
- [x] Delete the `style.emptyLine` temporary line, then do a guarded full build with `--wfail`.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: 534 warnings in 31 files, confirmed by the Phase 1 re-measurement.

**Files to modify**:
- The 31 `emptyLine` files named by the sweep
- `lakefile.toml` - remove 1 temporary line

**Phase 6 notes**: a fresh per-file sweep of the 33 files (line numbers had moved) reported 540
sites, every one a genuinely blank line; all 540 were deleted mechanically (the linter already
exempts string literals, docstrings and `where` fields) and the re-sweep reports 0. Follow-on:
`ProofExtractorMain.lean`'s longFile baseline re-tightened 1800 -> 1700; 8 `file.lean:NNN`
citations re-pointed. Full `--wfail` build green (1,129 s); C20/C28/C29/C30 pass.

**Verification**:
- The per-file `emptyLine` sweep reports 0, and `lake build --wfail` is green.

---

### Phase 7: `style.show` [COMPLETED]

**Goal**: Replace goal-changing uses of `show` with `change`, as the linter's message directs.

**Tasks**:
- [x] Work file by file, starting with `RamseyFactorization.lean` (17). Apply the linter's
      suggested replacement, rebuild each file, and re-run the per-file `show` sweep.
- [x] Delete the `style.show` temporary line, then do a guarded full build with `--wfail`.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: full

**Scope Hypothesis**: 193 warnings in 59 files. If the Phase 1 re-measurement puts this class
above about 230, split the phase by directory into 7.1 and 7.2. Keep the lakefile deletion in the
last sub-phase.

**Files to modify**:
- The 59 `show` files named by the sweep
- `lakefile.toml` - remove 1 temporary line

**Phase 7 notes**: fresh sweep of the 62 files found 196 sites (under the 230 split threshold,
so no 7.1/7.2 split). Each flagged `show` token was replaced by `change` at the exact reported
column; all 62 files re-elaborate and the re-sweep reports 0. No line counts moved. Full
`--wfail` build green (1,106 s); invariants pass.

**Verification**:
- The per-file `show` sweep reports 0, and `lake build --wfail` is green.

---

### Phase 8: `flexible` [COMPLETED]

**Goal**: Replace non-terminal flexible tactics (`simp`, and similar) that are followed by rigid
tactics. The fixes are `simp only [...]` using the list from `simp?`, or merging into `simpa`.

**Tasks**:
- [x] Fix, in order, `Termination/Fuel.lean` (33), `Decidability/Tableau.lean` (17),
      `EFGameTactics.lean` (8), then the other 6 files. Get each `simp only` list from `simp?` at
      that site, and rebuild each file before moving to the next.
- [x] Delete the `flexible` temporary line, then do a guarded full build with `--wfail`.

**Timing**: 2 hours

**Depends on**: 7

**Verification Tier**: full

**Scope Hypothesis**: 81 warnings in 9 files. The research could not elaborate `Fuel.lean`
completely because of the concurrent rebuild, so its count of 33 is a floor.

**Files to modify**:
- The 9 `flexible` files named by the sweep
- `lakefile.toml` - remove 1 temporary line

**Phase 8 notes**: the 88 warnings were 34 distinct tactic sites. Each flagged `simp`/`simp_all`
was turned into its `?` form, the file elaborated with `--json`, and the site replaced by
`simp only [...]` / `simp_all only [...]` carrying the UNION of the lemma lists every goal
reported (sites under `<;>`/`all_goals` see many goals). The first full build then failed on 9
`linter.unusedSimpArgs` warnings (a union member unused in every goal); those arguments were
removed. Per-file checks now run with the lakefile's full option set, not one linter at a time.
Full `--wfail` build green on the second run (1,215 s); invariants pass.

**Verification**:
- The per-file `flexible` sweep reports 0, and `lake build --wfail` is green.

---

### Phase 9: `longLine` (1 of 4) -- `Metalogic/Decidability` [NOT STARTED]

**Goal**: Reflow lines over 100 characters in the Decidability subtree.

**Tasks**:
- [ ] Reflow every flagged line so that it has no semantic change: break at binders, `→` or
      tactic separators, following LEAN_STYLE_GUIDE.md's existing 100-character guidance.
- [ ] Confirm zero `longLine` warnings in this subtree with a per-file sweep using
      `-Dweak.linter.style.longLine=true`, and build the touched modules. The lakefile line stays
      until Phase 12.

**Timing**: 1.5 hours

**Depends on**: 8

**Verification Tier**: local

**Scope Hypothesis**: The per-directory share of about 1,070 `longLine` warnings, taken from the
Phase 1 re-measurement table. If this subtree has more than about 300 warnings, split it into 9.1
and 9.2.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/**` - reflow

**Verification**:
- The per-file `longLine` sweep of this subtree reports 0, and the touched modules build.

---

### Phase 10: `longLine` (2 of 4) -- `Metalogic/WeakCanonical` [NOT STARTED]

**Goal**: The same work as Phase 9, for the WeakCanonical subtree.

**Tasks**:
- [ ] Reflow the flagged lines, run the per-file sweep to zero, and build the touched modules.

**Timing**: 1.5 hours

**Depends on**: 9

**Verification Tier**: local

**Scope Hypothesis**: This subtree's share, from the Phase 1 table. Split it the same way as
Phase 9 if it has more than about 300.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/**` - reflow

**Verification**:
- The per-file `longLine` sweep of this subtree reports 0, and the touched modules build.

---

### Phase 11: `longLine` (3 of 4) -- rest of `FormalSystem` [NOT STARTED]

**Goal**: Reflow the remaining `FormalSystem` lines, including `MintBound/Register.lean` (65) and
`Metalogic/Conservativity.lean` (29).

**Tasks**:
- [ ] Reflow the flagged lines, run the per-file sweep to zero across all of `FormalSystem/`, and
      build the touched modules.

**Timing**: 2 hours

**Depends on**: 10

**Verification Tier**: local

**Scope Hypothesis**: The remaining `FormalSystem` share, from the Phase 1 table. Split it by
directory into 11.1 and 11.2 if it has more than about 350.

**Files to modify**:
- The remaining `FormalSystem/**` files flagged by the sweep - reflow

**Verification**:
- The per-file `longLine` sweep of all of `FormalSystem/` reports 0.

---

### Phase 12: `longLine` (4 of 4) -- `Tests/`, the `#guard_msgs` files, and enablement [NOT STARTED]

**Goal**: Finish `longLine` in `Tests/`, fix the 5 `#guard_msgs` breakages, and turn the class on.

**Tasks**:
- [ ] Fix the 5 `#guard_msgs` files: `TableauConformance.lean` (around lines 910-936),
      `BoxSpreadProbe.lean`, `RegionGateProbe.lean`, `TemporalWitnessProbe.lean` and
      `RayRegionProbe.lean`. The preferred fix is to reflow the source line the warning points
      at. If the long line is the guarded output itself, use a per-command
      `set_option linter.style.longLine false in` with a C29 reason. Do not use
      `#guard_msgs (drop warning)`, because it would also hide other warnings.
- [ ] Reflow the rest of the `Tests/` lines.
- [ ] Delete the `style.longLine` temporary line, then do a guarded full build with `--wfail`
      across all targets.

**Timing**: 1.5 hours

**Depends on**: 11

**Verification Tier**: full

**Scope Hypothesis**: 5 `#guard_msgs` files, plus the `Tests/` share from the Phase 1 table.

**Files to modify**:
- `Tests/BimodalTest/**` - reflow and the `#guard_msgs` fixes
- `lakefile.toml` - remove 1 temporary line

**Verification**:
- `lake build --wfail` is green across all targets, and C28 and C29 pass.

---

### Phase 13: `unusedFintypeInType` [NOT STARTED]

**Goal**: Remove `Fintype` hypotheses that the statement does not use in its type, supplying them
in the proof instead with `classical` or `Fintype.ofFinite`. `Fintype` is a subsingleton, so
downstream instance mismatches cannot occur.

**Tasks**:
- [ ] Fix `[Fintype sig.preds]` (244) and `[Fintype ι]` (28) across the `MonadicSignature` layer,
      working in waves by directory: `Bridge/Interpolate.lean` first, then
      `WeakCanonical/Kamp/**`, `DenseModelSurgery/**` and `RealModel/**`. Build after each wave,
      and iterate to a fixpoint. Removing a hypothesis from one declaration can leave it unused in
      a caller, as the `omit` cascade in the burn-down work showed. Use `omit [...] in` only
      where the hypothesis is a section variable. It is not interchangeable with
      `set_option ... false in`.
- [ ] Delete the `unusedFintypeInType` temporary line, then do a guarded full build with
      `--wfail`.

**Timing**: 2 hours

**Depends on**: 12

**Verification Tier**: full

**Scope Hypothesis**: 274 warnings in 55 files before the cascade. The cascade can add more; the
fixpoint iteration will show how many.

**Files to modify**:
- About 55 files under `WeakCanonical/Kamp/**`, `DenseModelSurgery/**`, `RealModel/**` and
  `Bridge/Interpolate.lean`
- `lakefile.toml` - remove 1 temporary line

**Verification**:
- The per-file sweep reports 0, and `lake build --wfail` is green.

---

### Phase 14: `unusedDecidableInType` (fix, or bounded documented opt-out) [NOT STARTED]

**Goal**: Take `unusedDecidableInType` to zero, or record a documented permanent opt-out that has
evidence behind it.

**Tasks**:
- [ ] Remove `[DecidableEq sig.preds]` (245) and the few other sites the same way as Phase 13,
      building after each directory wave. Where a caller breaks on an instance mismatch
      (`Classical.decEq` against the specific instance), prefer keeping the hypothesis only on
      that declaration, with `set_option linter.unusedDecidableInType false in` and a C29 reason
      naming the caller that needs it.
- [ ] **Bounded fallback, decided before the phase starts.** Revert this phase's unfinished
      Lean edits and use a permanent `weak.linter.unusedDecidableInType = false` in the lakefile,
      with a reason comment, if either of these happens:
      - more than about 15 declarations need a per-declaration exemption, or
      - the fixpoint has not converged after 3 build waves.
      Record the reason and the evidence (mismatch examples, wave counts) in the phase notes. The
      opt-out also goes into the policy section written in Phase 16. This is the "documented
      opt-out where a linter does not fit this project" that the task description allows for.
      It is not a bulk suppression.
- [ ] Delete the temporary line (or convert it to the permanent documented opt-out), then do a
      guarded full build with `--wfail`.

**Timing**: 2 hours

**Depends on**: 13

**Verification Tier**: full

**Scope Hypothesis**: 249 warnings in 53 files, largely the same files as Phase 13.

**Files to modify**:
- The same `MonadicSignature`-layer files as Phase 13
- `lakefile.toml` - remove the temporary line, or make it permanent and documented

**Verification**:
- Either the per-file sweep reports 0, or the fallback is recorded with evidence. In both cases
  `lake build --wfail` is green.

---

### Phase 15: Ratchet check C30 (blanket suppression and unscoped heartbeats) [COMPLETED]

**Goal**: Mechanically enforce zero blanket linter suppressions and zero unscoped heartbeat
budgets from now on.

**Tasks**:
- [x] Add C30 to `scripts/check-module-invariants.sh`. It reuses C29's `live_files` walk and the
      `lean_debug_artifacts.mask` comment masker, starts from a zero baseline, and has no
      allow-list. It fails on:
      - (a) any masked `set_option linter.<X> <value>` without a trailing `in`, except
        `linter.style.longFile <N>`;
      - (b) any `set_option <...maxHeartbeats...> N` without a trailing `in`.
- [x] Keep the anti-silence guards: an empty walk exits 2, and so does zero matched scoped
      `set_option ... in` occurrences. Add fixture self-tests that match C29's pattern: a blanket
      form must fail, a scoped form must pass, a longFile baseline must pass, and a commented-out
      blanket form must pass.
- [x] Add an `ENFORCE_C30` toggle and a header entry, following the C28/C29 conventions, and add
      a C30 row to `docs/development/MODULE_INVARIANTS.md`.
- [x] Run the harness. C30 must be green on the tree as it stands after Phases 2-4.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Files to modify**:
- `scripts/check-module-invariants.sh` - C30 and its fixtures
- `docs/development/MODULE_INVARIANTS.md` - C30 row

**Phase 15 notes**: C30 added after C29 in `scripts/check-module-invariants.sh` with 12 fixtures,
`ENFORCE_C30=1`, and a header entry; `longFile 0` is deliberately NOT excepted (it is a disable).
It reports 591 live files, 108 scoped `set_option ... in`, zero hits. Probe: appending a blanket
`set_option linter.style.show false` to `FormalSystem/Syntax/Atom.lean` made C30 FAIL naming the
line; the file was restored byte-for-byte. MODULE_INVARIANTS.md has the C30 row.

**Verification**:
- `bash scripts/check-module-invariants.sh` shows C30 PASS, and its fixture self-tests pass.
- Temporarily adding a blanket `set_option linter.style.show false` line to a scratch copy makes
  C30 FAIL. Revert the probe afterwards.

---

### Phase 16: Policy documentation and final all-target gate [NOT STARTED]

**Goal**: Document the policy, and confirm the acceptance criteria against the authoritative
build.

**Tasks**:
- [ ] Add a lint-suppression policy section to `docs/development/LEAN_STYLE_GUIDE.md`, next to its
      existing suppression guidance, citing cslib's `docs/lint-suppression-policy.md` as the
      model. It covers:
      - the linter set in force and every permanent lakefile opt-out, with its reason (the
        `hashCommand` test-library opt-out, and `unusedDecidableInType` if Phase 14 fell back);
      - the rule that declaration-scoped `... false in` forms are allowed with a C29 reason, and
        blanket forms are forbidden (C30);
      - the longFile in-source baseline form;
      - Mathlib's comment-after-`in` rule for `maxHeartbeats`;
      - the `open Classical in` and `omit ... in` traps.
- [ ] Update `docs/development/CI_CD_PROCESS.md` if it describes the lakefile options or the
      warning gate.
- [ ] Confirm that `lakefile.toml` has no `TEMPORARY` lines left.
- [ ] Do a guarded full build of all targets with `--wfail`. Then run
      `python3 scripts/warning-budget.py --from-build` against that build (the baseline total must
      stay at 0) and `bash scripts/check-module-invariants.sh` (C28, C29 and C30 must be green).

**Timing**: 1.5 hours

**Depends on**: 14, 15

**Verification Tier**: full

**Files to modify**:
- `docs/development/LEAN_STYLE_GUIDE.md` - policy section
- `docs/development/CI_CD_PROCESS.md` - only if it is affected

**Verification**:
- Every acceptance criterion from the Testing & Validation section below is met.

## Testing & Validation

- [ ] `lakefile.toml` has a package-level `weak.linter.mathlibStandardSet = true` and
      `weak.linter.style.longFile = 1500`, and no `TEMPORARY` opt-out lines.
- [ ] `lake build --wfail` is green for `FormalSystem`, `BimodalTest` and all 13 exe roots.
- [ ] `warning-budget.py --from-build` reports that the baseline is still 0, with a disposition
      row for every observed class.
- [ ] Zero blanket `set_option linter.* false` and zero unscoped `maxHeartbeats`. C30 enforces
      both.
- [ ] C30 is documented in MODULE_INVARIANTS.md, and the policy section in LEAN_STYLE_GUIDE.md
      lists every permanent opt-out with its reason.
- [ ] No `sorry` or new axioms are introduced (lint-only task).

## Artifacts & Outputs

- `lakefile.toml` (package-level linter configuration)
- `scripts/warning-budget.txt` (disposition rows)
- `scripts/check-module-invariants.sh` (C30)
- `docs/development/MODULE_INVARIANTS.md`, `docs/development/LEAN_STYLE_GUIDE.md`
- Lint fixes across about 300 files under `FormalSystem/` and `Tests/`
- `specs/597_adopt_mathlib_standard_linter_set/summaries/01_mathlib-linter-set-adoption-summary.md`

## Rollback/Contingency

Each phase is committed on its own, with targeted staging, and keeps the build green under
`--wfail`. A failed phase can therefore be abandoned by reverting that phase's own commits. The
temporary opt-out line for its class stays in the lakefile, so enablement stays staged, and the
phase can be retried. If uncommitted work has to be discarded, follow
`context/contracts/recovery.md`'s rollback rung for the snapshot-then-rollback invocation. Other
sessions' uncommitted edits are in the tree, so never reset the whole tree. To abandon the whole
task, revert the Phase 1 lakefile commit: with the linter set off, every later lint fix is still
valid Lean and needs no revert.
