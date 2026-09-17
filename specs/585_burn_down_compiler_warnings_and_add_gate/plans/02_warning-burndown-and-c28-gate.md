# Implementation Plan: Burn down the live compiler warnings and add a warning gate

- **Task**: 585 - Burn down the live compiler warnings and add a warning gate
- **Status**: [IMPLEMENTING]
- **Effort**: 17.5 hours
- **Dependencies**: Task 583 (CI wiring pattern) — complete and archived; Task 584 — complete.
  Downstream: Task 597 (Mathlib standard linter set + blanket-suppression ratchet) baselines its
  new warnings under the gate this task builds.
- **Research Inputs**:
  - `specs/585_burn_down_compiler_warnings_and_add_gate/reports/02_warning-gate-design-remeasure.md` (primary)
  - `specs/585_burn_down_compiler_warnings_and_add_gate/reports/01_compiler-warning-inventory.md` (superseded counts; retained for its per-file inventory)
  - Peer termination-layer census (parallel agent, this session) — adopted for the per-site edit
    discipline and the verified `linter.unusedTactic` false positive
- **Artifacts**: plans/02_warning-burndown-and-c28-gate.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`lake build` exits 0 while the tree carries 348 compiler warnings across 56 files, and nothing
gates them: C16 runs Batteries' `env_linter` against declarations and never sees a compiler
warning, so the two sets are disjoint and the hole is real. This plan burns the 348 down to zero
in six territory-scoped fix phases, and lands the gate as a build-free ratchet
(`scripts/warning-budget.py` + a new **C28** in `scripts/check-module-invariants.sh`) *before* the
first fix, so every later phase's delta is machine-verified rather than asserted. The task is done
when the observed warning count is 0 on the full CI target set, C28 is enforced,
`build-args: "--wfail"` is wired, and `docs/development/CI_CD_PROCESS.md` describes what CI
actually does.

### Research Integration

Findings from report 02 that shape this plan, carried in rather than re-derived:

- **The surface is 348 over 56 files, not 316 over 47.** Report 01 measured only `lake build`'s
  default target (`FormalSystem`). CI additionally builds `BimodalTest` and thirteen `lean_exe`
  roots, contributing 35 further warnings and one whole linter class (`linter.defProp`, 10) that
  report 01 never saw. Every count in this plan is against the **all-target** set.
- **Warnings replay from Lake's cache.** A warm all-target build re-emits all 348 in ~6s and
  `lake build --wfail` on a warm cache exits 1. A gate is therefore feasible and cheap, and this
  refutes the assumption recorded at `scripts/check-module-invariants.sh:685`.
- **`--iofail` is categorically unusable.** `FormalSystem/MainResults.lean` emits 54 deliberate
  `info:` messages (25 `#check` + 29 `#print axioms`) as a documented invariant surface tied to
  C2/C14/C21. cslib's `--wfail --iofail` precedent cannot be copied, and cslib's own CI records
  that combination as permanently red by design.
- **The gate must be build-free.** CI invokes `bash scripts/check-module-invariants.sh --no-build`
  (`.github/workflows/ci.yml`, "Check module invariants"), and `CI_CD_PROCESS.md` records that
  C2/C6/C24 are consequently not run in CI at all. A gate that shells out to `lake build` would
  silently join that list.
- **`push_neg` → `push Not` is provably behaviour-preserving**, not merely probably:
  `Mathlib/Tactic/Push.lean:281-292` implements the deprecated tactic as `push … (.const ``Not) loc`
  plus a `logWarning`.
- **Section variables are fixed per declaration** via the `omit [...] in` form Lean prints in each
  message; the `variable`-line rewrite is optional and is the only variant needing a whole-file
  re-read.
- **The termination cluster must be edited per site, never by pattern.** `all_goals (try subst hg)`
  is dead at 9 of 15 sites, `(simp_all only []; done)` at 5 of 6, the `mem_boxDiamondPersistence`
  alternative at 2 of 10. A global `sed` on any of the three breaks the build.
- **`linter.unusedTactic` has a verified in-tree false positive.**
  `…/Termination/MintBound/Invariants.lean:789-797` documents the failed deletion experiment (12
  goals unsolved) above a declaration-scoped `set_option linter.unusedTactic false in`; the same
  shape recurs at `MintBound/UntlSnceFree.lean:352`. That is the house model for "document why not".

### Corrections this plan makes to the research report

Two facts were re-derived at plan time and disagree with the report; the plan follows the
re-derived values.

1. **The new check is C28, not C26.** Report 02 and the peer census both proposed "C26" on the
   belief that the harness is numbered through C25. It is not: **C26** (snake_case `def`/`abbrev`
   names and in-source `nolint` attributes) and **C27** (live debug directives against
   `scripts/debug-artifact-allowlist.txt`) both already exist in
   `scripts/check-module-invariants.sh` and both have rows in
   `docs/development/MODULE_INVARIANTS.md`. Verified at plan time by enumerating check IDs in both
   files. Using C26 would collide with a live check.
2. **The unanalyzed set is 35 distinct warnings, not 45.** The 10 `linter.defProp` warnings are a
   *subset* of the 34 in `Tests/BimodalTest/` (5 in `ProofSystem/DerivationPropertyTest.lean`, 3 in
   `Integration/Helpers.lean`, 2 in `Semantics/SemanticPropertyTest.lean`), not a disjoint class.
   The unanalyzed set is `Tests/BimodalTest/` 34 + `FormalSystem/Automation/DatasetGeneratorMain.lean`
   1 = 35. The coordinator's substantive point stands unchanged and is answered below; only the
   arithmetic is corrected.

### Answer to the blind-spot directive (both (a) and (b), and why)

The directive asked for either (a) an explicit phase that reads and dispositions the unanalyzed
warnings before the baseline is written, or (b) all-target baseline generation that fails loudly on
any class with no recorded disposition. **This plan does both, deliberately, because neither alone
closes the hole:**

- **(b) alone cannot work**, because "fail on a class with no recorded disposition" presupposes a
  disposition record, and only a human-or-agent read produces one. Without (a), (b) degenerates into
  a prompt to write `advisory` next to a class nobody looked at.
- **(a) alone does not persist**, because nothing then prevents the *next* new linter class (task
  597 will add several) from being silently absorbed into the baseline by a routine `--update`.

So: **Phase 1 generates the baseline against the all-target set from the outset** (nothing is blessed
by omission — the 35 are in the baseline as *counted, pending-disposition* entries from day one),
**Phase 1 also builds the disposition table and the exit-2-on-undispositioned-class guard** (that is
(b)), and **Phase 8 is a dedicated read-and-disposition phase for exactly those 35 warnings**,
including a first-principles read of the whole `linter.defProp` class, which no artifact in this
task has yet formed a view on (that is (a)). The gate cannot close in Phase 10 while any class is
still `pending`.

### Prior Plan Reference

No prior plan. Report 01's phasing proposal was superseded by report 02's before any plan existed;
report 02's seven-phase recommendation is the direct ancestor of the ten phases below, re-split so
that no phase exceeds ~2 hours and so that file territories are explicit.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch and no roadmap phases were requested, so no
ROADMAP.md consultation or update is in scope.

## Goals & Non-Goals

**Goals**:
- Reduce the all-target compiler-warning count from 348 to 0 across all 56 warning-emitting files.
- Land a build-free, `--no-build`-safe warning ratchet as C28 in `scripts/check-module-invariants.sh`,
  backed by `scripts/warning-budget.txt` keyed on `<count> <path> <linter>`.
- Give every linter class an explicit, recorded blocking/advisory disposition — including the 35
  warnings in `Tests/BimodalTest/` + `DatasetGeneratorMain.lean` and the entire `linter.defProp`
  class, which no artifact has yet analysed.
- Close with `build-args: "--wfail"` on the lean-action step *in addition to* C28, and correct the
  four false `--wfail` claims in `docs/development/CI_CD_PROCESS.md`.
- Hand task 597 a measured number for what the three blanket `linter.unusedSectionVars false`
  suppressions currently hide.

**Non-Goals**:
- `FormalSystem/Boneyard/` (169 files, ~130 further `push_neg` occurrences). Excluded from the build
  closure and from every invariant traversal; it cannot warn and cannot break at a Mathlib bump.
- `--iofail` in any form. Rejected on the record: `MainResults.lean`'s 54 deliberate `info:` messages.
- `warningAsError := true` in `lakefile.toml`. Rejected: a `leanOptions` entry breaks every
  contributor's *local* build, while `--wfail` is a CI-only CLI flag. (Note: the task description
  and report 01 both say `lakefile.lean`; the package migrated to `lakefile.toml` in `089f35fe0` and
  there is no `lakefile.lean`.)
- Converting the three blanket `set_option linter.unusedSectionVars false` lines to `in`-scoped form.
  That is task 597's charter; this plan only *measures* what they hide.
- Any new CI step or runtime-budget row. C28 costs ~0.05s inside the existing ~23s invariants step.
- Deleting the deprecated `negImp` alias itself (see Phase 8).

## Lean Challenge Statements

Not applicable. This plan states no theorem goals: `- **Goals**:` above names no Lean identifiers,
because the task removes dead tactics, renames binders, adds `omit` modifiers, and substitutes
deprecated spellings — it introduces no new declaration. The identifier set declared here is
therefore empty, matching the empty identifier set under Goals, as
`plan-format.md`'s cross-validation requirement demands.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The gate reads Lake trace files and a toolchain bump changes `schemaVersion` (currently `2025-09-10`), so the ratchet silently passes at 0 | H | M | Anti-silence guard (Phase 1): exit 2 — never pass — when no trace files are found, when every trace lacks a `log` key, or when the recorded baseline total is non-zero while the observed total is 0. Plus a `--from-build` cross-check mode that re-derives the numbers from build stdout, schema-independently |
| A new linter class is silently absorbed into the baseline by a routine `--update`, blessing warnings nobody read | H | M | Disposition table + exit-2-on-undispositioned-class guard (Phase 1); Phase 10 refuses to close while any class is `pending` |
| Deleting a "does nothing" tactic that is actually an alternative's *failure* mechanism inside a `first` chain | H | M (verified to occur) | Phases 4-6 edit per site and rebuild; the 22 `first`-chain warnings are the case-by-case bucket and resolve as either delete-with-green-build or `set_option linter.unusedTactic false in` + a recorded experiment, following `Invariants.lean:789-797` |
| A pattern-wide `sed` on a template line that is dead at some sites and live at others breaks the build | H | M | Explicit MUST NOT in Phases 4 and 5; the three known dead/live splits (9/15, 5/6, 2/10) are named in the phase text |
| A Mathlib bump lands mid-burn-down and adds a new deprecation class, re-redding the gate with no absorber | M | M | This is exactly why the baseline ratchet, not `--wfail`, is the mechanism. `--wfail` is added only in Phase 10 and can be reverted to baseline-only in one line |
| Baseline regeneration used to launder a regression (the failure mode C16 warns about for `nolints.json`) | H | L | Copy C16's never-regenerate-to-hide-a-regression warning verbatim into both the script header and `scripts/warning-budget.txt`'s header; require the `--update` diff to be visible in the commit that contains it |
| Gating `unusedTactic` pressures a contributor into deleting a load-bearing tactic | M | M | Name documented declaration-scoped suppression as an accepted green outcome, with `Invariants.lean:789-797` as the worked example, so "fix" and "document why not" both pass. Advisory-only for that class remains a defensible fallback if this proves insufficient — but it must be a recorded decision, not a default |
| Task 597 un-suppresses the three blanket files and re-inflates the count after this task reports zero | M | H | Phase 7 measures the hidden count and records it in the summary so 597 baselines a known number |
| Phases 3/6/7/9 share files, so parallel dispatch within a wave corrupts the shared baseline file | M | M | Sequential execution is the recommended default; the wave table below is a permission, not an instruction. See the note under Dependency Analysis |
| `check-module-invariants.sh` is the harness every other gate runs through; a bug in C28 reds the whole tree | H | L | Phase 2 ships C28 **report-only**, following the documented `ENFORCE_C<n>` pattern in `MODULE_INVARIANTS.md`'s "Adding a Check", and includes the deliberate negative test that section requires |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4, 5, 8 | 2 |
| 4 | 6 | 3 |
| 5 | 7 | 3, 6 |
| 6 | 9 | 7 |
| 7 | 10 | 3, 4, 5, 6, 7, 8, 9 |

Phases within the same wave can execute in parallel **by file territory** — the wave grouping was
derived by intersecting the per-phase file lists, and phases sharing a wave touch no file in common.
However, every fix phase also writes `scripts/warning-budget.txt`, which is a shared target.
**Sequential execution is therefore the recommended default**; a parallel wave dispatch must be
followed by a single `python3 scripts/warning-budget.py --update` reconciliation commit before the
next wave starts.

**Measurement protocol, applying to every phase below.** All counts in this plan were re-derived at
plan time by scanning `.lake/build/**/*.trace` and dropping entries whose source file no longer
exists (8 stale entries today, in 4 deleted/renamed files). The scan reproduced 348 over 56 files
exactly, and classified every one of the 348 with zero unclassified residue: 87 `linter.unusedSimpArgs`,
85 `linter.unusedSectionVars`, 82 deprecations, 36 `linter.unusedVariables`, 25 `linter.unusedTactic`,
14 `introMerge`, 10 `linter.defProp`, 9 `linter.unreachableTactic`. Phase counts partition these 348
exactly: 75 + 78 + 20 + 20 + 85 + 35 + 35 = 348.

**Build protocol, applying to every phase below.** Every `lake build` runs detached and guarded:

```
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build <targets>
```

per `context/project/lean4/operations/long-builds.md`. The full-surface target set is
`FormalSystem BimodalTest $(python3 scripts/lake_targets.py exe-roots | tr '\n' ' ')`.

---

### Phase 1: Warning-budget scanner and all-target baseline [COMPLETED]

**Goal**: A standalone, build-free scanner that measures the all-target warning surface from Lake's
trace store, writes and verifies `scripts/warning-budget.txt`, and refuses to pass when it cannot
trust its own measurement or when a linter class has no recorded disposition.

**Tasks**:
- [x] Create `scripts/warning-budget.py` following the `scripts/lake_targets.py` precedent for a
      python3 helper the bash harness shells out to.
- [x] **Acquisition**: walk `.lake/build/lib/lean/**/*.trace`, take `log[]` entries with
      `level == "warning"`, parse `<path>:<line>:<col>: ` off the front of each message, and drop any
      entry whose source path no longer exists.
- [x] **Classification**: read the linter name out of the
      ``Note: This linter can be disabled with `set_option linter.X false` `` line (present on 252 of
      348); classify the remainder by message pattern as `deprecated` (`has been deprecated`) and
      `introMerge` (`Try this: intro`). Any message matching none of the three is `UNCLASSIFIED` and
      is an error, not a silent bucket.
- [x] **Baseline key**: `<count> <path> <linter>` — deliberately not a per-class scalar (which cannot
      catch one warning fixed and another introduced) and deliberately without line numbers (so
      ordinary edits do not churn the baseline).
- [x] **Disposition table** in `scripts/warning-budget.txt`'s header: one row per linter class with a
      value in `{blocking, advisory, pending}`. Seed it as: deprecations `blocking`;
      `linter.unusedSimpArgs` `blocking`; `linter.unusedSectionVars` `blocking`;
      `linter.unusedVariables` `blocking`; `linter.unusedTactic` and `linter.unreachableTactic`
      `blocking` with "fix or document via declaration-scoped `set_option … in`" named as the
      sanctioned resolution; `introMerge` `advisory`; `linter.defProp` **`pending`** (no artifact has
      analysed it — Phase 8 sets it).
- [x] **Undispositioned-class guard**: exit 2 when an observed linter class has no row in the
      disposition table. This is what stops a future class being absorbed by a routine `--update`.
- [x] **Anti-silence guard**: exit 2 — never pass — when no trace files are found, when every trace
      lacks a `log` key, or when the recorded baseline total is non-zero while the observed total is 0.
- [x] **Modes**: default verify (exit 1 on any count above its baseline entry), `--update` (rewrite
      the file), `--list` (current counts, highest first), `--from-build` (re-derive the same numbers
      from all-target `lake build` stdout, schema-independent, for re-baselining and after a toolchain
      bump). Exit 2 for usage/environment error. Model: `~/Projects/cslib/scripts/check-lint-suppressions.sh`.
- [x] Copy C16's never-regenerate-to-hide-a-regression warning (`check-module-invariants.sh:2083-2086`)
      verbatim into both the script header and the baseline file header, together with the
      "counts are a CEILING and may only decrease" rule.
- [x] Generate the initial baseline against the **all-target** set and commit it.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: The scanner is asserted to reproduce **348 warnings over 56 files** with **0
`UNCLASSIFIED`**, split 87/85/82/36/25/14/10/9 across the eight classes named in the Measurement
protocol above, and to drop exactly **8** stale entries across 4 files. Confirm by running
`python3 scripts/warning-budget.py --list` against a warm `.lake/build` and diffing the totals
against `--from-build` on a guarded all-target build. If `--list` and `--from-build` disagree, the
trace-scan classification is wrong and must be fixed before any fix phase begins — the whole plan's
delta verification rests on these two agreeing.

**Files to modify**:
- `scripts/warning-budget.py` - new; the scanner, all four modes, both guards
- `scripts/warning-budget.txt` - new; disposition table header + the 348-entry baseline

**Verification**:
- `python3 scripts/warning-budget.py --list` reports 348 over 56 files, 0 `UNCLASSIFIED`.
- `python3 scripts/warning-budget.py --from-build` agrees with `--list` on every class total.
- `python3 scripts/warning-budget.py` (verify) exits 0 against the freshly written baseline.
- Negative test, all three guards: (i) point the scanner at an empty directory — exit 2, not 0;
  (ii) hand-edit one baseline count down by 1 — exit 1; (iii) hand-add a fabricated linter class to
  the observed set with no disposition row — exit 2.

---

### Phase 2: Wire the scanner as C28, report-only [NOT STARTED]

**Goal**: C28 runs inside `scripts/check-module-invariants.sh` in every mode including `--no-build`,
reports the warning budget, and does not yet affect the exit code.

**Tasks**:
- [ ] Add a C28 block to `scripts/check-module-invariants.sh` that shells out to
      `python3 scripts/warning-budget.py` and **never invokes `lake`** — this is the whole reason the
      trace-scan acquisition was chosen; a build-dependent C28 would join C2/C6/C24 in
      `CI_CD_PROCESS.md`'s documented not-in-CI gap list, because CI runs the harness as
      `--no-build`.
- [ ] Ship it behind `ENFORCE_C28=0` (report-only), following the pattern `MODULE_INVARIANTS.md`'s
      "Adding a Check" section documents for `ENFORCE_C16_ROOTS` and C8/C9/C10: compute and print
      from the outset, gate the exit code behind the flag while the burn-down is in progress.
      Note in the code comment that the anti-silence and undispositioned-class guards (exit 2) are
      **not** suppressed by `ENFORCE_C28=0` — a measurement the harness cannot trust is an error in
      every mode.
- [ ] Add C28 to the `# Checks:` header comment block at the top of the script.
- [ ] Add the C28 row to `docs/development/MODULE_INVARIANTS.md`, and a
      `### scripts/warning-budget.txt` subsection alongside the existing
      `scripts/debug-artifact-allowlist.txt` (C27) subsection.
- [ ] Perform the **deliberate negative test** that `MODULE_INVARIANTS.md`'s "Adding a Check"
      requires: with `ENFORCE_C28=1`, hand-introduce one warning, observe `FAIL C28` and a non-zero
      script exit, revert, observe green. Record the observation in the commit message.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: The new check ID is asserted to be **C28** — verified at plan time by
enumerating check IDs in both `scripts/check-module-invariants.sh` and
`docs/development/MODULE_INVARIANTS.md`, which show C26 (snake_case names + `nolint` attributes) and
C27 (live debug directives) both already live. Re-confirm before writing the block:
`grep -oE '\bC[0-9]{1,2}[A-Z]?\b' scripts/check-module-invariants.sh | sort -uV | tail`. If a
concurrent task has taken C28, take the next free ID and say so in the commit message — do **not**
reuse C26.

**Files to modify**:
- `scripts/check-module-invariants.sh` - C28 block, `ENFORCE_C28` flag, header comment row
- `docs/development/MODULE_INVARIANTS.md` - C28 row + baseline-file subsection

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` prints the C28 report and exits 0.
- `bash scripts/check-module-invariants.sh` (full) passes, with C2 and C14 axiom baselines unmoved.
- The negative test above produced `FAIL C28` and a non-zero exit under `ENFORCE_C28=1`.
- `grep -c 'C28' docs/development/MODULE_INVARIANTS.md` is non-zero.

---

### Phase 3: Deprecations in `FormalSystem/` [NOT STARTED]

**Goal**: Zero deprecation warnings in `FormalSystem/` (excluding `DatasetGeneratorMain.lean`, which
Phase 8 owns): 71 `push_neg` → `push Not`, 4 `IsTrichotomous`/`IsIrrefl` → `Std.*`.

**Tasks**:
- [ ] Substitute `push_neg` → `push Not` at all 71 sites. Both live forms are covered: bare
      `push_neg` (5) and `push_neg at <h>` (66). The substitution is provably identity —
      `Mathlib/Tactic/Push.lean:281-292` defines the deprecated tactic as the same `push` call plus a
      `logWarning`.
- [ ] Work **per file with a per-file rebuild**, using the per-file warning counts as the exact
      expected delta: `BadIntervals.lean` 22, `Lemma34.lean` 12, `Interpolate.lean` 11,
      `Lemma5.lean` 6, `Decidable.lean` 4, `TruthLemma.lean` 4, `TruthTransfer.lean` 3,
      `Z1Countermodel.lean` 2, `DurationClassification.lean` 2, `ChronicleRealExtension.lean` 1,
      `DenseObstructionTransfer.lean` 1, `MixedSum.lean` 1, `NoGaps.lean` 1, `ShiftSetProduct.lean` 1.
      (`DoetsTheorem.lean` 2 and `BlockDecomposition.lean` 2 are the `Std` migration below, not `push_neg`.)
- [ ] `IsTrichotomous` → `Std.Trichotomous` and `IsIrrefl` → `Std.Irrefl`: 2 in `DoetsTheorem.lean`,
      2 in `BlockDecomposition.lean`.
- [ ] Do **not** adopt Mathlib's alternative suggestion of re-declaring `push_neg` as a local macro:
      it perpetuates a deprecated spelling, risks parser ambiguity against the still-present upstream
      `elab`, and re-does the work when upstream deletes the tactic.
- [ ] Run `python3 scripts/warning-budget.py --update` and include the diff in the phase commit.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 75 warnings across 16 files, composed as 71 `push_neg` + 4 `Std` migration.
A plan-time `grep -rl push_neg FormalSystem/ --include=*.lean` (excluding Boneyard) returns **18**
files, not 14 — the extra occurrences are expected to be in comments or docstrings, which do not
warn. Confirm at implementation time by diffing the grep file list against the 14 warning-bearing
files above; if a file carries a live `push_neg` tactic that does not appear in the warning list,
the measurement is wrong and Phase 1's scanner must be revisited before proceeding.

**Files to modify**:
- 14 files under `FormalSystem/Metalogic/` and `FormalSystem/Semantics/` for `push_neg`, per the
  per-file counts above
- `FormalSystem/Metalogic/WeakCanonical/RealModel/DoetsTheorem.lean` - `IsTrichotomous`/`IsIrrefl` ×2
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/BlockDecomposition.lean` - `IsTrichotomous`/`IsIrrefl` ×2
- `scripts/warning-budget.txt` - baseline update

**Verification**:
- Guarded all-target build exits 0; `python3 scripts/warning-budget.py --list` shows the `deprecated`
  class down by exactly 75 (to 7: the 6 in `Tests/` + 1 in `DatasetGeneratorMain.lean`).
- `bash scripts/check-module-invariants.sh` passes in full, C2/C14 axiom baselines unmoved, C3 zero `sorry`.

---

### Phase 4: `SubformulaProperty.lean` dead-tactic and unused-simp cluster [NOT STARTED]

**Goal**: Zero warnings in
`FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` (78 today), edited
per site with each `first`-chain alternative individually adjudicated.

**Tasks**:
- [ ] Delete the 54 unused simp arguments. None of the 87 unused-simp-arg warnings in the tree
      carries Lean's `←` caveat, so none is a rewrite-direction argument whose removal would also
      restore the other direction to the simp set — every one is safe to delete as the linter
      suggests. The recurring names are template residue: `or_false` 11, `List.not_mem_nil` 7,
      `List.flatten_nil` 7, `List.flatten_cons` 7, `List.append_nil` 7, `SignedFormula.neg` 6,
      `SignedFormula.pos` 4.
- [ ] Adjudicate each dead-tactic warning **per site**. The three template lines have known dead/live
      splits across the file: `all_goals (try subst hg)` dead at 9 of 15 sites,
      `(simp_all only []; done)` dead at 5 of 6 (line 1014 is still live), the
      `(obtain ⟨s, hs, hsg⟩ := mem_boxDiamondPersistence hg; …)` alternative dead at 2 of 10 (lines
      864 and 893 — `applyRule_boxNeg_closed` and `applyRule_diamondPos_closed`, precisely the two
      theorems commit `6b2be0db8` edited when it removed six temporal propagation blocks as unsound).
- [ ] For each warning attached to an alternative inside a `first` chain (the case-by-case bucket):
      either delete it and observe a green build, or keep it and add a declaration-scoped
      `set_option linter.unusedTactic false in` with a comment recording the deletion experiment and
      its outcome — following `…/MintBound/Invariants.lean:789-797`, which names all twelve goals
      left unsolved when the deletion was tried there.
- [ ] Note the asymmetric cases: at `:1039`, `:1071`, `:1269` both halves of `(simp_all only []; done)`
      are flagged plus "never executed"; at `:1103` and `:1135` *only* `done` is flagged, so
      `simp_all only []` is doing real work there. The two groups need different treatment.
- [ ] Run `python3 scripts/warning-budget.py --update` and include the diff in the phase commit.

**MUST NOT**: apply a pattern-wide or `sed`-style removal of any of the three template lines. Each is
dead at some instantiations and live at others; a global substitution on any one of them breaks the
build. This is a verified constraint, not a precaution.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 78 warnings in this one file (54 `linter.unusedSimpArgs` + the dead-tactic
remainder), of which roughly 22 tree-wide sit inside `first` chains and are case-by-case. The 54/78
split and the three dead/live ratios above are the peer census's figures, independently re-derived
at plan time only at the file-total level. Confirm the per-class split inside this file with
`python3 scripts/warning-budget.py --list` filtered to this path before editing, and confirm each
dead/live ratio by counting occurrences of the template line in the source against the flagged line
numbers — if a ratio differs, trust the live measurement, not this plan.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` - 78 sites
- `scripts/warning-budget.txt` - baseline update

**Verification**:
- Guarded build of the `FormalSystem` target exits 0 after every sub-step; no goal left unsolved.
- `--list` shows 0 warnings for this file.
- `bash scripts/check-module-invariants.sh` passes in full; C2/C14 unmoved; C3 zero `sorry`.
- Every retained-with-suppression site carries a comment naming what broke when deletion was tried.

---

### Phase 5: Termination-layer remainder [NOT STARTED]

**Goal**: Zero cluster-class warnings in the other three termination files: `MintPotential.lean` 15,
`TimeCensus.lean` 3, `Fuel.lean` 2 — 20 in total.

**Tasks**:
- [ ] `MintBound/MintPotential.lean` (15): 8 unused simp arguments plus the dead
      `(try contradiction)` `<;>`-chain tail at `:237` and the remaining template residue.
- [ ] `MintBound/TimeCensus.lean` (3): 2 unused simp arguments plus the dead `assumption` at `:392`
      under `mem_identifyTime_time_at_trigger`. **Caution**: its `_oriented` twin two lines below
      (`:394`) is still live — this is a per-site case, not a paired edit.
- [ ] `Fuel.lean` (2): the `(try omega)` tail of the `<;>` chain in `applyRule_branching_arity_le`,
      which produces both a "does nothing" and a "never executed" warning; the preceding `(try simp)`
      closes everything.
- [ ] Same per-site discipline and same fix-or-document resolution for `first`-chain alternatives as
      Phase 4.
- [ ] Run `python3 scripts/warning-budget.py --update` and include the diff in the phase commit.

**MUST NOT**: pattern-edit across files. The same template instantiations recur here with different
dead/live status.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 20 cluster-class warnings across exactly these three files. Note that
`MintBound/OrientedGate.lean`'s single warning is `linter.unusedVariables` (an unused binder `x`),
**not** a cluster-class warning, and is owned by Phase 9 — so the termination directory's oft-quoted
total of 99 is 98 cluster-class + 1 binder. Confirm with `--list` filtered to
`…/Verified/Termination/` before editing.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/MintPotential.lean` - 15 sites
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/TimeCensus.lean` - 3 sites
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - 2 sites
- `scripts/warning-budget.txt` - baseline update

**Verification**:
- Guarded build exits 0; `--list` shows 0 for all three files.
- `bash scripts/check-module-invariants.sh` passes in full; C2/C14 unmoved; C3 zero `sorry`.

---

### Phase 6: Cluster classes outside the termination layer [NOT STARTED]

**Goal**: Zero `linter.unusedSimpArgs`/`linter.unusedTactic`/`linter.unreachableTactic` warnings
outside `Verified/Termination/` — 20 across 7 files that no census has read.

**Tasks**:
- [ ] `FormalSystem/Metalogic/Decidability/Tableau.lean` (9).
- [ ] `FormalSystem/Metalogic/Decidability/CountermodelExtraction.lean` (4).
- [ ] `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Lemma34.lean` (2).
- [ ] `FormalSystem/Metalogic/Decidability/BiLasso/Examples.lean` (2).
- [ ] `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` (1),
      `FormalSystem/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (1),
      `FormalSystem/Metalogic/Decidability/BiLasso/Enumerate.lean` (1).
- [ ] Apply the same read-then-edit discipline: unused simp arguments delete safely (no `←` caveat
      anywhere in the tree); anything inside a `first` chain is fix-or-document.
- [ ] Run `python3 scripts/warning-budget.py --update` and include the diff in the phase commit.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 20 warnings across exactly these 7 files. These were **not** read by the peer
census (which scoped itself to `Verified/Termination/`) and are not individually classified anywhere
in this task's artifacts — the count and file list are from the plan-time trace scan only. Confirm
with `--list` before editing, and expect the delete/case-by-case ratio to differ from the termination
cluster's, because these are not instantiations of the same proof template.

**Files to modify**: the 7 files listed above, plus `scripts/warning-budget.txt`

**Verification**:
- Guarded build exits 0; `--list` shows the three cluster classes at 3 remaining tree-wide
  (the `Tests/BimodalTest/Integration/ComplexDerivationTest.lean` unused simp args, owned by Phase 8).
- `bash scripts/check-module-invariants.sh` passes in full; C2/C14 unmoved; C3 zero `sorry`.

---

### Phase 7: Section variables, and measuring what the blanket suppressions hide [NOT STARTED]

**Goal**: Zero `linter.unusedSectionVars` warnings (85 across 15 files) via the per-declaration
`omit [...] in` form, plus a recorded measurement of the count currently hidden by the three blanket
file-scoped suppressions.

**Tasks**:
- [ ] Apply `omit [...] in` to each flagged declaration, using the exact remedy Lean prints in each
      message. `omit … in` attaches to one declaration and cannot affect its neighbours, so this is
      the safe default; report 01's caution that the fix "changes what is in scope for every theorem
      in the section" applies only to the optional `variable`-line rewrite.
- [ ] Per-file counts (the expected delta for each): `TaskFrame.lean` 20, `BadIntervals.lean` 14,
      `DoetsTheorem.lean` 9, `NoGaps.lean` 6, `Lemma34.lean` 5, `Bridge/DenseTruth.lean` 5,
      `Lemma5.lean` 4, `Verified/Decidable.lean` 4, `Bridge/IntTruth.lean` 4, `Singletons.lean` 3,
      `TruthTransfer.lean` 3, `Bridge/Valuation.lean` 3, `LexCarrier.lean` 3, `FlowFrame.lean` 1,
      `ShuffleReal.lean` 1.
- [ ] The three dominant instance sets account for 73 of the 85: `[Nontrivial D]` 30,
      `[IsDualClosed C]` 22, `[Fintype sig.preds]` 21. Where a whole section's declarations all omit
      the same instance, the `variable`-line rewrite is the tidier fix and is permitted — but it
      requires a whole-file rebuild, so use it only where it is independently clearly better.
- [ ] **Measure the hidden count** (this is the deliverable task 597 depends on): temporarily comment
      out the file-scoped `set_option linter.unusedSectionVars false` at
      `FormalSystem/Semantics/Ultraproduct/Carrier.lean:63`, `…/Los.lean:47`, and
      `…/ShiftSetProduct.lean:60`; build those three files; record the revealed warning count per
      file; restore the three lines unchanged. Do **not** fix the revealed warnings and do **not**
      convert the suppressions to `in`-scoped form — both are task 597's charter.
- [ ] Record the measured number in the phase commit message and carry it into the implementation
      summary so 597 inherits a known quantity rather than a surprise.
- [ ] Run `python3 scripts/warning-budget.py --update` and include the diff in the phase commit.

**Timing**: 2 hours

**Depends on**: 3, 6

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 85 warnings across 15 files with the per-file distribution above, plus an
**unknown** hidden count behind the three blanket suppressions — that unknown is the phase's
measurement deliverable, not an assertion. Confirm the 85 with `--list` before editing; confirm each
per-file delta after each file.

**Files to modify**:
- The 15 files listed above (`omit … in` insertions)
- `FormalSystem/Semantics/Ultraproduct/{Carrier,Los,ShiftSetProduct}.lean` - **temporarily** only;
  restored byte-identical at the end of the phase
- `scripts/warning-budget.txt` - baseline update

**Verification**:
- Guarded build exits 0; `--list` shows `linter.unusedSectionVars` at 0.
- `git diff` over the three Ultraproduct files is empty at phase end.
- The hidden count is recorded in the commit message.
- `bash scripts/check-module-invariants.sh` passes in full; C2/C14 unmoved; C3 zero `sorry`.

---

### Phase 8: `Tests/BimodalTest/` + `DatasetGeneratorMain.lean` — read, disposition, fix [NOT STARTED]

**Goal**: Close the blind spot. Read and disposition all 35 warnings that exist only because CI
builds the test library and the thirteen `lean_exe` roots, including a first-principles read of the
entire `linter.defProp` class, and drive them to zero.

**Tasks**:
- [ ] **Read and disposition `linter.defProp` (10)** — no artifact in this task has formed a view on
      this class; report 01 never saw it and the peer census scoped it out. Sites:
      `ProofSystem/DerivationPropertyTest.lean` 5, `Integration/Helpers.lean` 3,
      `Semantics/SemanticPropertyTest.lean` 2. The linter's claim is that a `def` whose type is a
      proposition should be a `theorem`. Decide per site whether the `def` → `theorem` conversion is
      correct (it changes reducibility and definitional-unfolding behaviour, so it is not
      unconditionally safe in a test helper that other tests unfold), then set the class's
      disposition row in `scripts/warning-budget.txt` from `pending` to `blocking` or `advisory` with
      a one-line recorded reason. **The gate cannot close in Phase 10 while this row reads `pending`.**
- [ ] `linter.unusedVariables` (14): `Automation/TacticsTest.lean` 6,
      `Automation/ProofSearchTest.lean` 2, `ProofSystem/DerivationPropertyTest.lean` 2,
      `ProofSystem/DerivationTest.lean` 2, `Automation/DatasetGeneratorTest.lean` 1,
      `Integration/Helpers.lean` 1. Rename to `_`-prefixed binders.
- [ ] Deprecations (7): `Theorems/PropositionalTest.lean` 4 × `negImp` → `impOfNeg` (the live
      primary, per `FormalSystem/Theorems/Propositional/Core.lean:341`'s
      `@[deprecated impOfNeg (since := "2025-12-14")]`); `TraceExportTest.lean` 2 ×
      `String.takeRight` → `String.takeEnd`; `FormalSystem/Automation/DatasetGeneratorMain.lean:1276`
      × 1 `String.trimLeft` → its named replacement. **Note** for `takeRight`: the warning text
      records that the replacement has a *different return type* (`String.Slice`, not `String`), so
      this is not a pure rename — check the use site.
- [ ] `linter.unusedSimpArgs` (3): `Integration/ComplexDerivationTest.lean`.
- [ ] `introMerge` (1): `Syntax/ContextTest.lean`.
- [ ] **Decision to record**: keep the deprecated `negImp` alias itself (it is a deprecated public
      name with a documented `since` date and removing it is an API deletion this task does not own);
      only move its 4 call sites. Note in the commit that C17's dead-declaration scan
      (reporting-only) may now list the alias, which is expected.
- [ ] Run `python3 scripts/warning-budget.py --update` and include the diff in the phase commit.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: 35 warnings — 34 in `Tests/BimodalTest/` across 11 files plus 1 in
`FormalSystem/Automation/DatasetGeneratorMain.lean` — split 14 `unusedVariables` / 10 `defProp` /
7 deprecated / 3 `unusedSimpArgs` / 1 `introMerge`. The `defProp` 10 are a **subset** of the 34, not
a disjoint class; the coordinator's "45" double-counted them. Confirm with
`python3 scripts/warning-budget.py --list` filtered to non-`FormalSystem/` paths plus
`DatasetGeneratorMain.lean` before editing. The tier is `interface` rather than `local` because
`Integration/Helpers.lean` is a shared test helper whose `def` → `theorem` decisions are visible to
its dependents.

**Files to modify**:
- 11 files under `Tests/BimodalTest/` (per the distribution above)
- `FormalSystem/Automation/DatasetGeneratorMain.lean` - 1 deprecation
- `scripts/warning-budget.txt` - baseline update **and** the `linter.defProp` disposition row

**Verification**:
- Guarded **all-target** build (`FormalSystem BimodalTest` + exe roots) exits 0 — the default target
  alone does not exercise any of this phase's edits.
- `--list` shows 0 warnings for every non-`FormalSystem/` path and for `DatasetGeneratorMain.lean`.
- `scripts/warning-budget.txt` contains no `pending` disposition row.
- `bash scripts/check-module-invariants.sh` passes in full, including C25 (every `lean_exe` root
  compiles); C2/C14 unmoved; C3 zero `sorry`.

---

### Phase 9: Unreferenced binder names and `intro` merge suggestions in `FormalSystem/` [NOT STARTED]

**Goal**: Zero `linter.unusedVariables` (22) and `introMerge` (13) warnings in `FormalSystem/` — 35 in
total, all mechanical.

**Tasks**:
- [ ] `linter.unusedVariables` (22): `Bridge/IntTruth.lean` 8, `DoetsTheorem.lean` 5, `NoGaps.lean` 4,
      `CancellableExpansion.lean` 1, `Saturation.lean` 1, `MintBound/OrientedGate.lean` 1,
      `Bridge/RegionFrame.lean` 1, `PartialHistoryOrder.lean` 1. Rename each to a `_`-prefixed binder;
      do not delete the binder, which would change the declaration's arity.
- [ ] `introMerge` (13): `SoundnessLemmas/FrameClassVariants.lean` 8, `Metalogic/Soundness.lean` 2,
      `Core/RestrictedMCS/Basic.lean` 1, `Decidability/FMP/FMP.lean` 1,
      `Semantics/Correspondence/FwdRecBridge.lean` 1. Apply the `Try this: intro …` suggestion each
      message prints verbatim.
- [ ] Note that `RegionFrame.lean` already carries declaration-scoped `set_option` suppressions (×2);
      do not widen them to file scope while fixing the neighbouring warning.
- [ ] Run `python3 scripts/warning-budget.py --update` and include the diff in the phase commit.

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 35 warnings across 13 files with the per-file distribution above. `introMerge`
is proposed as `advisory` in Phase 1's disposition table, so these 13 are being fixed rather than
tolerated by choice — if a suggestion produces a worse-reading proof, leaving it and recording the
`advisory` disposition is an acceptable outcome for that site. Confirm the 22/13 split with `--list`
before editing.

**Files to modify**: the 13 files listed above, plus `scripts/warning-budget.txt`

**Verification**:
- Guarded all-target build exits 0; `--list` reports **0 warnings tree-wide** — this is the phase
  where the count reaches zero.
- `bash scripts/check-module-invariants.sh` passes in full; C2/C14 unmoved; C3 zero `sorry`.

---

### Phase 10: Close the gate [NOT STARTED]

**Goal**: The baseline is zero everywhere, C28 is enforced, `--wfail` is wired as the belt-and-braces
hard stop, and `CI_CD_PROCESS.md` describes what CI actually does.

**Tasks**:
- [ ] Regenerate `scripts/warning-budget.txt` to a zero baseline and confirm every class row is
      `blocking` or `advisory` — **no row may read `pending`**.
- [ ] Flip `ENFORCE_C28` to 1 in `scripts/check-module-invariants.sh` and update the C28 row in
      `docs/development/MODULE_INVARIANTS.md` to record that it now ships enforced, following the
      "flip the default to 1 once it reaches zero" convention that section already states for
      `ENFORCE_C16_ROOTS`.
- [ ] Add `build-args: "--wfail"` to the lean-action step in `.github/workflows/ci.yml`. Both gates
      deliberately: `--wfail` is an immediate hard stop covering anything the trace walk might miss;
      C28 supplies per-file/per-linter diagnostics and a reviewed escape hatch for the day an upstream
      deprecation lands mid-cycle. Do **not** add `--iofail` — `MainResults.lean` emits 54 deliberate
      `info:` messages and `--iofail` is `--fail-level=info`.
- [ ] Correct `docs/development/CI_CD_PROCESS.md`'s four false `--wfail` claims (lines 41-49, 69,
      319, 343), which asserted a gate `ci.yml` did not implement. After this phase they become true
      rather than aspirational; edit them to describe the *two*-gate reality (`--wfail` on the build
      step, C28 in the invariants step) and add C28 to whatever check inventory that document carries.
- [ ] Add a "Known Not-in-CI Gaps" note confirming C28 is **not** in that list, and why (build-free
      by construction, so it runs under `--no-build`).
- [ ] Record in the summary: the three-file hidden section-variable count from Phase 7, the
      `linter.defProp` disposition and its reason from Phase 8, and the C26→C28 numbering correction,
      so task 597 inherits all three.
- [ ] Optional, if cheap: add the measured Lake log-replay behaviour (warnings are cached per module
      in `.lake/build/**/*.trace` and replayed on a cache hit; `--wfail` honours replayed warnings;
      warm all-target replay ~6s) to `context/project/lean4/operations/long-builds.md` or a sibling
      `operations/build-log-replay.md`, and correct the stale assumption at
      `scripts/check-module-invariants.sh:685`.

**Timing**: 1.5 hours

**Depends on**: 3, 4, 5, 6, 7, 8, 9

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Four `--wfail` claims in `CI_CD_PROCESS.md` at lines 41-49, 69, 319, 343, and
zero `--wfail`/`--iofail`/`warningAsError` occurrences in `ci.yml` and `lakefile.toml` — both
re-derived at plan time. Re-confirm with
`grep -rn 'wfail\|iofail\|warningAsError' docs/development/CI_CD_PROCESS.md .github/workflows/*.yml lakefile.toml`
before editing; line numbers will have drifted if any doc phase touched the file.

**Files to modify**:
- `scripts/warning-budget.txt` - zero baseline, all dispositions final
- `scripts/check-module-invariants.sh` - `ENFORCE_C28=1`
- `.github/workflows/ci.yml` - `build-args: "--wfail"` on the lean-action step
- `docs/development/CI_CD_PROCESS.md` - correct the four claims, document the two-gate reality
- `docs/development/MODULE_INVARIANTS.md` - C28 now enforced
- Optionally `context/project/lean4/operations/long-builds.md` and
  `scripts/check-module-invariants.sh:685`'s stale comment

**Verification**:
- Guarded all-target build with `--wfail` exits **0** (it must, now that the count is zero — a
  non-zero exit here means a warning survived).
- `bash scripts/check-module-invariants.sh` and `bash scripts/check-module-invariants.sh --no-build`
  both pass with C28 enforced.
- `grep -c 'pending' scripts/warning-budget.txt` is 0.
- Negative test: re-introduce one warning, confirm **both** gates fire (C28 non-zero exit under
  `--no-build`, and `lake build --wfail` exit 1); revert; confirm green.
- No claim remains in `CI_CD_PROCESS.md` that `ci.yml` does not implement.

---

## Testing & Validation

Per-phase, every phase:
- [ ] Guarded `lake build` over the phase's target set exits 0 (all-target for Phases 1, 8, 9, 10).
- [ ] `python3 scripts/warning-budget.py --list` shows the phase's **exact** expected delta — not
      merely a decrease. An unexpected delta means either a measurement bug or an unintended edit.
- [ ] `scripts/warning-budget.txt` is updated in the **same commit** as the fixes, with the
      `--update` diff visible.
- [ ] `bash scripts/check-module-invariants.sh` passes in full.
- [ ] C2 and C14 axiom baselines unmoved; C3 reports zero `sorry`; no `sorry` introduced.

Task-level, at completion:
- [ ] All-target warning count is 0 across all 56 formerly-warning files.
- [ ] `lake build --wfail` over the full CI target set exits 0.
- [ ] C28 enforced and passing in both `--no-build` and full harness modes.
- [ ] Every linter class in `scripts/warning-budget.txt` carries a `blocking` or `advisory`
      disposition with a reason; none reads `pending`.
- [ ] Both negative tests recorded: C28 fires on a re-introduced warning; `--wfail` fires too.
- [ ] `docs/development/CI_CD_PROCESS.md` contains no claim `.github/workflows/ci.yml` does not implement.

## Artifacts & Outputs

- `scripts/warning-budget.py` - new; build-free trace-scan warning scanner, four modes, two guards
- `scripts/warning-budget.txt` - new; disposition table + per-`<path> <linter>` baseline, ending at zero
- `scripts/check-module-invariants.sh` - C28 block, `ENFORCE_C28`, header comment row
- `docs/development/MODULE_INVARIANTS.md` - C28 row + baseline-file subsection
- `.github/workflows/ci.yml` - `build-args: "--wfail"`
- `docs/development/CI_CD_PROCESS.md` - four corrected claims + the two-gate description
- ~56 Lean files under `FormalSystem/` and `Tests/BimodalTest/` with 348 warnings removed
- `specs/585_burn_down_compiler_warnings_and_add_gate/summaries/02_*-summary.md` - recording the
  Phase 7 hidden section-variable count, the Phase 8 `linter.defProp` disposition, and the
  C26→C28 numbering correction, all three of which task 597 inherits

## Rollback/Contingency

Every phase commits independently and each is individually revertible by `git revert` of its commit
— the fix phases touch disjoint or sequentially-ordered file territories, so reverting one does not
strand another. This is the preferred contingency and requires no working-tree destruction.

If a phase must be abandoned mid-flight with uncommitted edits in the tree, take a durable,
**non-reverting** checkpoint first — `bash .claude/scripts/git-snapshot.sh 585 --no-revert` — per
`context/patterns/checkpoint-before-overflow.md`, then decide. A genuine whole-tree rollback that
discards uncommitted work is a different operation with its own invocation shape and out-of-scope
override flag; see `context/contracts/recovery.md`'s rollback rung, and do not substitute a bare
default-mode snapshot call for a routine checkpoint.

Gate-specific contingency: if a Mathlib bump lands after Phase 10 and floods the tree with a new
deprecation class, the escape is to revert **only** the `build-args: "--wfail"` line in `ci.yml`
(one line) and absorb the new class into `scripts/warning-budget.txt` with an explicit disposition
and a reason. C28 then continues to hold the line on every other class. That asymmetry — a
one-line-revertible hard stop layered over a per-class ratchet — is the reason both gates exist
rather than either alone.
