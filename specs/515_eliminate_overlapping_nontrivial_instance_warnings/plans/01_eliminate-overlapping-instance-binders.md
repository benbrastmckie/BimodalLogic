# Implementation Plan: Eliminate the 21 overlapping `[Nontrivial D]` instance warnings

- **Task**: 515 - Eliminate the 21 remaining "Overlapping instance parameters -- There are 2 [Nontrivial D] instances; one is sufficient" warnings across three Metalogic files
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/515_eliminate_overlapping_nontrivial_instance_warnings/reports/01_overlapping-nontrivial-instance-warnings.md
- **Artifacts**: plans/01_eliminate-overlapping-instance-binders.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

All 21 `linter.overlappingInstances` warnings are one defect with one shape: an enclosing
`variable` block and a nearer binder both supply `[Nontrivial D]` for the same `D`. The fix at
every site is deletion of the redundant binder — never suppression. 18 sites (Class A) delete an
explicit per-declaration `[Nontrivial D]`; 3 sites (Class B, all in `TruthLemma.lean`) inherit
the duplicate from two `variable` lines in the same section, and are fixed by deleting one of
those lines. Done means: 0 overlapping diagnostics in all three files, a genuine forced full
`lake build` at exit 0 with no warning of any class newly introduced, and `lake test` green.

### Research Integration

The research report is authoritative and supersedes the original task description. Four findings
are load-bearing for this plan and are carried into the phases below:

1. **The task description's "Class B shadowing" premise is false.** The outer
   `variable … [Nontrivial D]` at `TruthLemma.lean:74` sits inside `section Invariance`, closed by
   `end Invariance` at `:335` — eight lines *before* `section Countermodel` opens at `:343`. The
   outer `D` is out of scope there. Confirmed against the live source while writing this plan.
   The duplication is entirely local to `section Countermodel`, between its own `:346` and `:351`.
   Corroborated by the compiler: the diagnostic says "There are **2** `[Nontrivial D]` instances",
   not 3, and no `AddCommGroup`/`LinearOrder` overlap is reported — both of which would follow if
   `:74` leaked. **There is therefore no "which `D`" hazard at any site**, and no phase in this
   plan needs to guard against one.
2. **The real split is 18 Class A / 3 Class B, not 17/4.** `Decidable.lean:2761 truthAt_sep` is
   Class A: its binder is on continuation line `:2762`, as `[DenselyOrdered D] [Nontrivial D]`.
3. **Class B ownership is decided, not open** (see "Class B ownership decision" below).
4. **The complete fix was built, tested, and reverted during research.** Measured: forced full
   build (`--no-share`) exit 0, 2506 jobs, overlapping 21 -> 0, `unusedSectionVars` 97 -> 83,
   total warnings 381 -> 346, 0 errors, 0 `sorry`; `lake test` exit 0. No new warning of any
   class — verified set-theoretically via `comm -13` over sorted warning text, not by count.

**Expect the `unusedSectionVars` count to fall.** Most of these sites carry a *paired*
`linter.unusedSectionVars` warning naming `[Nontrivial D]`: the linter pair says the signature is
simultaneously over-supplied and carrying dead weight, because instance search resolves against
the nearer explicit binder and leaves the section one unused. Deleting the explicit binder clears
both. The tree-wide drop 97 -> 83 is a predicted consequence of this fix, not an unexplained
delta, and decomposes as FlowFrame -10, Decidable -2, TruthLemma -2.

### Class B ownership decision (required record)

Per the task's acceptance criteria, this plan records for each Class B site which `variable`
block owns `[Nontrivial D]` and why. All three sites share one decision, because all three
inherit from the same section header.

| Site | Owning block | Deleted |
|---|---|---|
| `TruthLemma.lean:364` `RegionValued` | `section Countermodel` header, `:345-346` | `:351` |
| `TruthLemma.lean:374` `atomRegionInvariant_regionHistory` | `section Countermodel` header, `:345-346` | `:351` |
| `TruthLemma.lean:389` `interpInvariantAt_regionHistory` | `section Countermodel` header, `:345-346` | `:351` |

**Why `:346` owns it and `:351` is deleted.** Note first that `:351` is the *older*, deliberate,
documented binder (commit `118ec5fdfd`, 19:26) and `:346`'s `[Nontrivial D]` is the later sweep's
addition (commit `ddfcb59c35`, 20:57) — so this recommendation deliberately keeps the historically
accidental line. Three grounds justify that:

1. **The `:348-350` comment states a requirement about scope, not position.** Its content is that
   `[Nontrivial D]` must be declared in its own right rather than recovered from `[NoMaxOrder D]`,
   so the `omit [Fintype ι] [DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D]` at `:368` cannot
   strip nontriviality along with the density instances. `:346` satisfies that requirement
   identically — it is equally absent from the `omit` list. The documented intent survives intact;
   only its anchor moves.
2. **`:346` is the codebase-wide bundle shape.** `{D : Type} [AddCommGroup D] [LinearOrder D]
   [IsOrderedAddMonoid D] [Nontrivial D]` is the standard duration-group prefix used at
   `TruthLemma.lean:74`, `Decidable.lean:136`, `FlowFrame.lean:449`, and across 33 files.
3. **It is the binder-order-preserving choice**, measured by `#check` signature diffing rather
   than assumed. Under deletion-of-`:351`, `interpInvariantAt_regionHistory`'s surviving
   `[Nontrivial D]` occupies exactly the baseline's slot (after `[IsOrderedAddMonoid D]`, before
   `[Fintype ι]`); deleting `:346`'s instead permutes it to the end. `RegionValued` and
   `atomRegionInvariant_regionHistory` are byte-identical either way. No consumer applies any of
   the 21 declarations with `@`, so both variants are safe — order preservation is the
   conservative tiebreak, not a correctness requirement.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context and no roadmap flag is set; ROADMAP.md
was not consulted.

## Goals & Non-Goals

**Goals**:
- Reduce `Overlapping instance parameters` diagnostics from 21 to 0 across the three target files
  and tree-wide, by deleting redundant `[Nontrivial D]` binders.
- Retarget the `TruthLemma.lean:348-350` comment so it documents the surviving binder at `:346`,
  preserving every claim the original made.
- Prove the result with a *genuine* forced full build (job count confirmed) plus `lake test`, and
  demonstrate set-theoretically that no warning of any class is newly introduced.

**Non-Goals**:
- Fixing the residual `unusedSectionVars` warnings that survive this change
  (`FlowFrame.lean:635 fmcs_box_persistent`; `Decidable.lean:1000/:1019/:1153/:1164`).
- Fixing the pre-existing `push_neg` deprecations in `TruthLemma.lean:193/:223/:254/:266`.
- Any change to `FormalSystem/Semantics/TaskFrame.lean` (already fixed by `e73dcb62f`),
  `FormalSystem/Semantics/Ultraproduct/**`, or `ShiftSet.lean`.
- Any restructuring of `variable` blocks beyond removing the duplication.
- Any edit to the six files whose `.olean` this invalidates — none needs a source change.

## Prohibitions (binding on every phase)

- **Never** add `set_option linter.overlappingInstances false` at any scope. The duplicate is
  what gets removed, never the warning. `grep -rn overlappingInstances FormalSystem/` must return
  nothing at the end.
- Do not restructure `variable` blocks beyond removing the duplication.
- Do not modify `FormalSystem/Semantics/TaskFrame.lean`,
  `FormalSystem/Semantics/Ultraproduct/**`, or `ShiftSet.lean`.
- Do not introduce `sorry`, `admit`, `axiom`, or `native_decide`.
- **`git checkout -- <path>` and `git restore <path>` are blocked** by the repo's
  `guard-destructive-git.sh` hook on a dirty tree. Every phase therefore saves a pristine copy of
  its target file to the scratchpad first and reverts with `cp` if needed.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A "full pass" is actually a replayed scoped result from the build guard's result sharing | H | M | Always pass `--no-share`, and explicitly confirm `Build completed successfully (2506 jobs).` in the log. A phase gate that cannot show the job count has not passed. |
| Editing `:2762` strips `[DenselyOrdered D]` along with `[Nontrivial D]` | H | M | Phase 2 states the exact post-edit line content (`    [DenselyOrdered D]`) and diffs it. |
| Line numbers drift as edits are applied within a file | M | H | Within each phase, apply edits **bottom-up** (highest line first) or match on unique declaration text rather than line number. |
| A blanket `sed s/ \[Nontrivial D\]//g` hits a site outside the authoritative list | H | M | Edits are per-site against the enumerated declaration names; the diff is reviewed for exact line count before any build. |
| Parallel phases 1-3 collide over the shared Lake build directory | M | M | Phases are territory-disjoint in *source*, but their verification builds share one `.lake`. Serialize all `lake` invocations; never run two concurrently. |
| Long builds exceed the tool timeout | M | M | Run builds detached via `Bash(run_in_background: true)` with the guard's `--timeout 1800`, per `context/project/lean4/operations/long-builds.md`. |
| Revert needed but destructive-git hook blocks it | M | L | Pristine copies saved to scratchpad in every phase; revert via `cp`, never `git checkout --`. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel. Phases 1-3 touch three disjoint files with
no cross-file edit, so their *source* territories are independent. Their verification builds are
not: all `lake` invocations share one build directory and MUST be serialized.

---

### Phase 1: FlowFrame.lean — 13 Class A binder deletions [COMPLETED]

**Goal**: Remove the redundant explicit `[Nontrivial D]` from all 13 declarations under the
`section BundleFlow` binder at `:449`, driving that file's overlapping count to 0.

**Tasks**:
- [x] Save a pristine copy: `cp FormalSystem/Metalogic/Algebraic/FlowFrame.lean <scratchpad>/FlowFrame.lean.orig`
- [x] Confirm the section binder at `:449` still reads
      `variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`
- [x] Delete the substring `` [Nontrivial D]`` (with its one leading space) from each of the 13
      declaration lines, working bottom-up. Nothing else on any line changes:
      `:803 bundleFlow_completeness_from_neg_membership`, `:678 bundleFlow_truth_lemma`,
      `:549 bundleFlow_total_eq_range`, `:533 bundleFlow_total_eq`, `:521 bundleFlow_spherical`,
      `:514 bundleFlow_limit`, `:506 bundleFlow_serial`, `:498 bundleFlow_comp_iff`,
      `:491 bundleFlow_pos_shift`, `:483 bundleFlowHistory_total`, `:479 bundleFlowModel`,
      `:472 bundleFlowHistory`, `:466 bundleFlowFrame`
- [x] Review `git diff FormalSystem/Metalogic/Algebraic/FlowFrame.lean`: exactly 13 changed lines,
      each losing exactly the 16-character ` [Nontrivial D]` token and nothing else
- [x] Run `lake env lean FormalSystem/Metalogic/Algebraic/FlowFrame.lean` and record the counts
- [x] Commit on green

**Timing**: 0.4 hours

**Depends on**: none

**Verification Tier**: interface

Rationale: the three `noncomputable def`s at `:466`/`:472`/`:479` lose one instance-implicit
argument, which is an arity change visible to six consuming files (`Algebraic.lean`,
`BXCanonical/{Completeness,CompletenessDedekind,DiscreteCarrierProbe}.lean`,
`BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`, `Bundle/LimitMCS.lean`). Research
confirmed none needs a source edit, but the `.olean` invalidation is real and the dependent set
is enumerated — which is exactly the `interface` tier. Building the one-hop dependents is
optional here given Phase 4's full build; single-file `lake env lean` plus the enumerated
dependent list satisfies the tier.

**Scope Hypothesis**: 13 sites in this file, at the lines named above, each carrying an explicit
` [Nontrivial D]` on the declaration line. Confirm before editing by running
`lake env lean FormalSystem/Metalogic/Algebraic/FlowFrame.lean 2>&1 | grep -c "Overlapping instance parameters"`
and requiring `13`; confirm after editing that the same command returns `0`. If the pre-count is
not 13, stop and reconcile against the report's Section 1 table rather than proceeding.

**Files to modify**:
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` — delete ` [Nontrivial D]` from 13
  declaration lines; no other change

**Verification**:
- `lake env lean FormalSystem/Metalogic/Algebraic/FlowFrame.lean` exits 0
- 0 `Overlapping instance parameters` (was 13)
- exactly 1 residual `automatically included section variable` warning, at `:635`
  `fmcs_box_persistent` (was 11) — this one is unrelated and stays
- total warnings for the file: 1 (was 24); 0 errors
- `git diff --stat` shows only this file, 13 insertions / 13 deletions

---

### Phase 2: Decidable.lean — 5 Class A binder deletions [COMPLETED]

**Goal**: Remove the redundant explicit `[Nontrivial D]` from all 5 declarations under the
file-wide binder at `:136`, including the continuation-line site.

**Tasks**:
- [x] Save a pristine copy to the scratchpad
- [x] Confirm the file-wide binder at `:136` still carries `[Nontrivial D]`
- [x] Confirm, by grep, that none of `exists_gt_self`, `exists_lt_self`,
      `exists_gt_not_untl_disj`, `exists_lt_not_snce_disj`, `truthAt_sep` is referenced outside
      `Decidable.lean` (research found the group file-internal, `truthAt_sep` `private`, and the
      `:2168`/`:2178` uses in the order-independent named form `exists_gt_self (D := D) t`).
      If any external reference is found, raise the phase's tier to `interface` and enumerate the
      dependents before proceeding.
- [x] Working bottom-up, delete ` [Nontrivial D]`:
      - `:2762` — the **continuation line** of the `:2761 truthAt_sep` declaration. It currently
        reads `    [DenselyOrdered D] [Nontrivial D]` and MUST be left as exactly
        `    [DenselyOrdered D]`. Do not delete the line.
      - `:2172 exists_lt_not_snce_disj`, `:2162 exists_gt_not_untl_disj`,
        `:2149 exists_lt_self`, `:2144 exists_gt_self` — binder on the declaration line
- [x] Review the diff: exactly 5 changed lines; confirm `:2762` retains `[DenselyOrdered D]`
- [x] Run `lake env lean` on the file and record counts
- [x] Commit on green

**Timing**: 0.3 hours

**Depends on**: none

**Verification Tier**: local

Rationale: all five declarations are `Decidable.lean`-internal (grep-confirmed as an explicit
task above, not assumed), and `truthAt_sep` is `private`. No externally visible signature
changes, so a single-module build is the matched tier. The grep task is what keeps this from
being an uncertain call that the tie-break rule would push to `interface`.

**Scope Hypothesis**: 5 sites in this file — 4 on declaration lines, 1 on continuation line
`:2762`. Confirm with
`lake env lean FormalSystem/Metalogic/Decidability/Verified/Decidable.lean 2>&1 | grep -c "Overlapping instance parameters"`
returning `5` before and `0` after. Note that a text grep for `[Nontrivial D]` on declaration
lines finds only 4 — the compiler diagnostic is the authority, not grep.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` — delete ` [Nontrivial D]` at
  `:2144`, `:2149`, `:2162`, `:2172`, `:2762`

**Verification**:
- `lake env lean FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` exits 0
- 0 `Overlapping instance parameters` (was 5)
- exactly 4 residual `unusedSectionVars`, at `:1000`, `:1019`, `:1153`, `:1164` (was 6) — all
  pre-existing and out of scope
- total warnings for the file: 8 (was 15); 0 errors
- `sed -n '2762p'` on the file returns exactly `    [DenselyOrdered D]`

---

### Phase 3: TruthLemma.lean — Class B ownership fix [COMPLETED]

**Goal**: Collapse the `section Countermodel` duplication by deleting the `variable [Nontrivial D]`
at `:351` and retargeting the `:348-350` comment to the surviving binder at `:346`, clearing all
3 Class B sites.

**Tasks**:
- [x] Save a pristine copy to the scratchpad
- [x] Re-confirm the section structure before editing: `end Invariance` at `:335` precedes
      `section Countermodel` at `:343`, so the `:74` binder is out of scope and `:345`'s
      `{D : Type}` is the section's only introduction of `D`. Record this confirmation in the
      phase notes — it is the finding that makes this a two-line edit rather than a scope
      analysis.
- [x] Delete line `:351` (`variable [Nontrivial D]`)
- [x] Replace the comment at `:348-350` with wording that documents the `:346` binder,
      preserving every claim the original made:
      ```lean
      -- `regionFrame` carries `[Nontrivial D]` (its *Limit* lemma needs it), which is why the binder
      -- above declares it in its own right rather than recovering it from `[NoMaxOrder D]`: the `omit`
      -- clauses below drop the density instances and must not take nontriviality with them.
      ```
- [x] Confirm `:346` still reads `  [IsOrderedAddMonoid D] [Nontrivial D]` — it is untouched
- [x] Confirm the `omit` clause (formerly `:368`) still lists exactly
      `[Fintype ι] [DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D]` and does **not** mention
      `Nontrivial D`
- [x] Run `lake env lean` on the file and record counts
- [x] Build the one-hop dependent `FormalSystem/Metalogic/Decidability/Verified/Bridge/Valuation.lean`
- [x] Commit on green

**Timing**: 0.4 hours

**Depends on**: none

**Verification Tier**: interface

Rationale: `RegionValued` and `interpInvariantAt_regionHistory` are consumed cross-file by
`Bridge/Valuation.lean`, and `interpInvariantAt_regionHistory`'s elaborated signature changes
(one `[Nontrivial D]` removed). The dependent set is a single enumerated file, which is exactly
the `interface` contract. Note the recommended variant is the binder-*order-preserving* one, so
`RegionValued` and `atomRegionInvariant_regionHistory` come out byte-identical to baseline.

**Scope Hypothesis**: 3 sites in this file (`:364 RegionValued`, `:374
atomRegionInvariant_regionHistory`, `:389 interpInvariantAt_regionHistory`), none of which is
itself edited — the fix is entirely in the section header. Confirm with
`lake env lean .../TruthLemma.lean 2>&1 | grep -c "Overlapping instance parameters"` returning
`3` before and `0` after. If the pre-count is not 3 — in particular if it names three rather than
two `[Nontrivial D]` instances, or reports an `AddCommGroup`/`LinearOrder` overlap — the
no-shadowing finding does not hold on the current source and the phase must stop and re-derive
ownership before editing.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean` — delete `:351`; rewrite
  the `:348-350` comment. No `variable` block other than the deleted line changes.

**Verification**:
- `lake env lean` on the file exits 0
- 0 `Overlapping instance parameters` (was 3)
- 0 `automatically included section variable` warnings (was 2)
- total warnings for the file: 4 (was 9), all four being the pre-existing `push_neg` deprecations
  at `:193`, `:223`, `:254`, `:266`; 0 errors
- `Bridge/Valuation.lean` builds clean with no source edit
- The phase notes record the ownership decision (`:346` owns `[Nontrivial D]`; `:351` deleted)
  and the three grounds from the plan's "Class B ownership decision" section

---

### Phase 4: Tree-wide acceptance [COMPLETED]

**Goal**: Prove the acceptance criteria on a genuine forced full build plus test run, and
demonstrate that no warning of any class was newly introduced anywhere in the tree.

**Tasks**:
- [x] Run the forced full build detached
      (`Bash(run_in_background: true)`, per `context/project/lean4/operations/long-builds.md`):
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --no-share -- build`
      Capture the full log to a scratchpad file.
- [x] **Confirm the job count explicitly** — the log must contain
      `Build completed successfully (2506 jobs).` A pass without a confirmed full job count does
      not close this phase, because the guard replays a completed result when the fingerprint
      matches and a scoped result can present as a full pass. `--no-share` is what forces the
      real thing.
- [x] Run `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --no-share -- test`;
      require exit 0
- [x] Count from the build log: `Overlapping instance parameters` = 0;
      `automatically included section variable` = 83; total `warning:` lines = 346;
      `error:` = 0; `declaration uses 'sorry'` = 0
- [x] **Set-theoretic no-new-warning check** (not a count comparison): sort the full warning text
      of the new build, sort a baseline warning list, and require `comm -13 baseline new` to be
      empty. If no baseline log is on hand, produce one by reverting all three files from the
      scratchpad copies via `cp` (never `git checkout --`), building, then restoring the edits.
      A count-only comparison is not sufficient — it cannot distinguish a cleared warning from a
      substituted one.
- [x] `grep -rn overlappingInstances FormalSystem/` returns nothing
- [x] `grep -rn "sorry\|admit\|native_decide" FormalSystem/` has not grown against baseline
- [x] `git status --porcelain` shows only the three intended files
- [x] Commit

**Timing**: 0.9 hours (dominated by two full builds)

**Depends on**: 1, 2, 3

**Verification Tier**: full

**Scope Hypothesis**: the post-fix build is expected to report 2506 jobs, 0 overlapping, 83
`unusedSectionVars`, 346 total warnings, 0 errors. These are measurements from the research
probe, not guarantees — the tree may have moved since. Confirm each by reading the actual log.
A deviation in `unusedSectionVars` or total warnings is a signal to run the `comm -13` check
before accepting; a deviation in the job count means the build was not genuinely full and must be
re-run.

**Files to modify**: none (verification only)

**Verification**:
- Forced full `lake build` exit 0 with confirmed 2506 jobs
- `lake test` exit 0
- Tree-wide `Overlapping instance parameters`: 21 -> 0
- `comm -13 baseline new` over sorted warning text is empty (no new warning of any class)
- No linter disabled; no `sorry`/`admit`/`native_decide` introduced

---

## Testing & Validation

- [x] `lake env lean FormalSystem/Metalogic/Algebraic/FlowFrame.lean` — 0 overlapping, 0 errors
- [x] `lake env lean FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` — 0 overlapping,
      0 errors
- [x] `lake env lean FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean` — 0
      overlapping, 0 errors
- [x] Forced full `lake build` (`--no-share`) exit 0, job count 2506 confirmed in the log
- [x] `lake test` exit 0
- [x] `grep -rn overlappingInstances FormalSystem/` returns nothing
- [x] `sorry`/`admit`/`native_decide` counts unchanged from baseline
- [x] `comm -13` over sorted baseline/new warning text is empty

## Artifacts & Outputs

- Modified: `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` (13 lines)
- Modified: `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` (5 lines)
- Modified: `FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean` (1 line deleted,
  3-line comment rewritten)
- `specs/515_eliminate_overlapping_nontrivial_instance_warnings/summaries/01_*-summary.md`
- One commit per phase per the Commit-Per-Green-Substep Mandate

## Rollback/Contingency

`git checkout -- <path>` and `git restore <path>` are **blocked** by the repo's
`guard-destructive-git.sh` PreToolUse hook whenever the tree is dirty. Each phase therefore saves
a pristine copy of its target file to the session scratchpad before editing, and reverts with
`cp <scratchpad>/<file>.orig <path>`. Because the three files are independent, a failure in one
phase can be reverted without disturbing the other two.

If a full build fails after all three phases: revert all three files by `cp`, rebuild to confirm
the baseline is restored, then reintroduce one file's edits at a time to isolate the failure. If
an intentional git-level rollback is ever wanted, run
`bash .claude/scripts/git-snapshot.sh 515` first, then the destructive command — never the
destructive command alone.

The change carries no runtime or proof risk beyond compile-time elaboration: it deletes redundant
instance binders only, and the research probe verified every elaborated signature is preserved up
to the position of one instance-implicit argument, with zero `@`-applications anywhere in
`FormalSystem/` or `Tests/` that could depend on that position.
