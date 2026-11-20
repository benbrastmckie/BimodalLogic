# Implementation Plan: Task #958

- **Task**: 958 - Repair FormalSystem/Tactic/Meta.lean's buildContextExpr, which throws on every call and hard-fails modal_search on any box-headed goal
- **Status**: [NOT STARTED]
- **Effort**: 1.25 hours
- **Dependencies**: None (task 955 depends on this task, not the reverse)
- **Research Inputs**: specs/958_repair_buildcontextexpr_modal_search/reports/01_repair-buildcontextexpr-modal-search.md
- **Artifacts**: plans/01_repair-buildcontextexpr-modal-search.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

One-token repair at `FormalSystem/Tactic/Meta.lean:113` (`mkAppM` -> `mkAppOptM ``List.nil
#[some formulaType]`), plus relocation of both `buildContextExpr` call sites in
`FormalSystem/Automation/Tactics/Search.lean` into their `observing?` blocks so a speculative
search branch absorbs an elaboration failure instead of aborting the tactic, plus the
regression and acceptance coverage that would have caught the defect. Research measured the
entire change green end to end (`lake build` and `lake test` both exit 0 with zero warnings,
three `modal_search` acceptance examples compile, axiom profile unchanged) and measured the
box-headed acceptance example **red** pre-repair, so the coverage discriminates rather than
tautologizing.

Single phase, deliberately. The decisive reason is not change size: it is that the source
repair has **no discriminating verification of its own**. `lake build BimodalTest` was already
exit-0 with zero warnings *before* any edit (research row 13), because no test currently reaches
`tryModalK` or `tryTemporalK`. A source-only phase would therefore close on a gate that was
already green, and the only measurement that distinguishes repaired from broken is the
acceptance test. Repair and coverage belong to the same atom.

### Research Integration

- Repair (1) (`mkAppOptM`) is chosen over repair (2) (raw `mkApp`/`mkConst`) on measured in-repo
  convention: `FormalSystem/Automation/ProofMode/Meta.lean:100-106`'s `contextExpr` is a
  line-for-line working twin of `buildContextExpr` differing *only* in that line; the repo has
  three `mkAppOptM ``List.nil #[some ...]` sites (one of them in `Search.lean` itself at `:265`)
  and zero sites of the shape repair (2) proposes. Both repairs were measured working, so this is
  a style ruling between two green options.
- The task description's open question ("assess whether the two Search.lean call sites belong
  INSIDE their `observing?` blocks") resolves **yes**, on three grounds research established:
  it is why this defect was a hard tactic error rather than a search miss; `Search.lean:265` is
  the unambiguous in-file precedent; and the residual throw path through
  `mkAppM ``List.cons #[f, result]` survives the repair, so a speculative branch should still
  absorb it.
- Research found a linter collision invisible to review: moving the call carries its comment
  with it and leaves a bare blank line above `let success <- observing? do`, which Mathlib's
  standard linter set rejects ("do not place empty lines within commands") at the current
  `Search.lean:473` and `:525`. Deleting both blank lines clears it (measured).
- `Meta.mkListLit` is recorded as a *rejected* alternative, not adopted: it produces a
  syntactically identical `Expr` (measured) but moves `buildContextExpr` away from its twin
  rather than toward it.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` provided in this dispatch; `specs/ROADMAP.md` was not consulted.

## Goals & Non-Goals

**Goals**:

- `buildContextExpr` returns a well-typed `Context` expression on the empty list and on
  non-empty lists, instead of throwing on every input.
- An elaboration failure inside `tryModalK` / `tryTemporalK` registers as a failed search
  branch, not a hard tactic error.
- `modal_search` closes a box-headed goal, a box-headed goal at a non-empty all-boxed context,
  and an `allFuture`-headed goal.
- The test suite gains coverage that actually *invokes* `buildContextExpr`, so this defect class
  cannot recur silently behind a `#check`.
- `lake build` and `lake test` green with zero warnings; no new axioms.

**Non-Goals**:

- The `FrameClass.Base` hard-coding in `tryModalK`/`tryTemporalK`. Both docstrings already
  record it as a separately deferred capability gap; this repair neither touches it nor worsens
  it, and all three acceptance examples pass at `FrameClass.Base`.
- Collapsing `buildContextExpr` to `Meta.mkListLit`, or consolidating it with
  `ProofMode/Meta.lean`'s `contextExpr`. Recorded in research as a visible option for a later
  consolidation pass; out of scope here.
- Authoring the `context/project/lean4/patterns/appbuilder-argument-arity.md` context file the
  research report recommends. That is a source-store edit under
  `agent-system/extensions/lean/` (per `.claude/rules/source-store-deploy-boundary.md`), is
  absent from this task's description, and belongs to its own task.
- `Tests/BimodalTest/Automation/LemmaDBTest.lean`'s module-header claim that the file is
  "Organized in three groups" while a Group 6 exists. Pre-existing and unrelated; this phase
  edits inside Group 6 without making that inconsistency worse.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Generated line-count surfaces go stale and the pre-commit hook blocks the commit | M | H | Scheduled as named phase work below, in the same phase as the Lean edits — see the coupled-surface task group; `typst/generated/status.typ` is commit-blocking and cannot be deferred |
| The blank-line linter finding is reintroduced by any later reflow of those two blocks | M | M | The zero-warning `lake build` gate catches it (that is how research found it); keep the full-project build in the phase criteria, not a scoped test-module build alone |
| `tryModalK` becomes reachable for the first time; `goal.assign proof` does not typecheck its assignment, so a context/formula mismatch would surface downstream rather than as a clean branch failure | M | L | Genuinely new coverage, not a restoration. The full `lake test` run is the check; research measured it green across 3061 targets |
| `Formula.allFuture` is a `def`, not a constructor (`Syntax/Formula.lean:168`), so `tryTemporalK`'s `.app (.const ``Formula.allFuture _) inner` match depends on the goal staying unfolded | L | L | The `allFuture`-headed acceptance example *is* the guard; keep it |
| Stale `.lake` oleans from the research dispatch's probe builds | L | M | Sources were reverted, so Lake recompiles the four affected modules; do not read a fast first build as evidence the repair is already applied — check the source line |
| `check-module-invariants.sh` carries a pre-existing C16 `unusedArguments` finding at `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean:2136` | L | H | Baseline delta, not absolute zero: "green" means that finding and no other new one |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |

Phases within the same wave can execute in parallel. This plan has one phase, which is
therefore also its final phase.

---

### Phase 1: Repair `buildContextExpr`, relocate both call sites, and land invoked regression coverage [NOT STARTED]

**Goal**: `buildContextExpr` builds a correct `Context` expression; both `Search.lean` consumers
treat an elaboration failure as a failed search branch; the suite invokes `buildContextExpr` and
exercises `modal_search` on box-headed and `allFuture`-headed goals; every coupled generated
surface is back in sync and the whole project builds and tests green with zero warnings.

**Tasks**:

*Source repair*

- [ ] At `FormalSystem/Tactic/Meta.lean:113`, replace
      `let mut result ← mkAppM ``List.nil #[formulaType]` with
      `let mut result ← mkAppOptM ``List.nil #[some formulaType]`. Leave the `List.cons` loop at
      `:114-115` untouched — `List.cons` takes exactly two explicit arguments, so that line is
      already correct.
- [ ] In `tryModalK` (`FormalSystem/Automation/Tactics/Search.lean`, currently the
      `-- Build the unboxed context expression` comment at `:474` and
      `let unboxedCtxExpr ← buildContextExpr unboxedCtx` at `:475`), move the comment and the
      `let` **inside** the `observing? do` block that currently opens at `:476`, as the block's
      first statements, above `setGoals [goal]`. The call does not read goal state, and
      `observing?`'s state rollback on failure is harmless to it.
- [ ] Delete the now-stray blank line left directly above `let success ← observing? do` in
      `tryModalK` (currently `:473`). Research measured that leaving it produces
      `warning: ... do not place empty lines within commands!`, and CI builds with `--wfail`, so
      this is a hard gate, not a style note.
- [ ] Apply the same two moves in `tryTemporalK`: relocate the
      `-- Build the unfutured context expression` comment (`:526`) and
      `let unfuturedCtxExpr ← buildContextExpr unfuturedCtx` (`:527`) inside the `observing? do`
      block at `:528`, and delete the stray blank line at `:525`.

*Regression and acceptance coverage*

- [ ] In `Tests/BimodalTest/Automation/LemmaDBTest.lean`'s `section MetaHelperProbes`
      (`:243-279`), keeping the existing `#check @buildContextExpr` beside it, add an invoked
      `MetaM` probe that calls `buildContextExpr` on `[]` and on a two-element list, runs
      `Meta.check` on each result, confirms the empty case `isDefEq` to `Context`, and pins both
      results against `Meta.mkListLit (mkConst ``Formula) ...`. Use the qualified `Meta.check`,
      not bare `check`: the file opens `Lean` but not `Lean.Meta`, and research measured bare
      `check` failing with `Unknown identifier `check``. The exact body research compiled green
      is in the report's "The invoked probe that passes (row 9)" subsection.
- [ ] Add all three `modal_search` acceptance examples research compiled green together, in the
      same section. Keep all three: the empty-context box-headed one is the example the task
      description names; the non-empty all-boxed-context one is the only thing that drives the
      `List.cons` fold through the tactic (with an empty context `buildContextExpr` is only ever
      called on `[]`); the `allFuture`-headed one is the only acceptance coverage `tryTemporalK`
      gets.
- [ ] Rewrite the paragraph at `Tests/BimodalTest/Automation/LemmaDBTest.lean:235-240` — the one
      beginning "`buildContextExpr` is the exception, and deliberately so." It states that
      `buildContextExpr` "is `#check`ed and never applied", names the `mkAppM ``List.nil` defect
      as live, and says "the repair belongs to whoever edits that declaration". Left standing it
      would contradict the invoked probe sitting directly beneath it. Replace it with prose
      stating the current design: the helper is invoked, and why an invoked `#eval` probe rather
      than a signature pin is what this file owes a `MetaM` helper. Do not narrate the paragraph's
      own revision history (`.claude/rules/no-record-versioning-in-deliverables.md`) and do not
      cite a task number (`.claude/rules/no-task-references-in-deliverables.md`). *If this
      paragraph is not found where expected*, locate it by its opening sentence; it was confirmed
      present at authoring time at `:235`.

*Coupled generated surfaces — same phase, not deferred*

- [ ] Regenerate `typst/generated/status.typ` via
      `bash scripts/typst-sync-check.sh --fix` and stage it. **This cannot be deferred**:
      `.githooks/pre-commit` blocks any commit whose staged set touches a `.lean` path while
      `scripts/typst-sync-check.sh --counts-only` reports drift, and this phase moves two of its
      compared figures — `formalsystem-line-count` (Search.lean loses two blank lines: 620 -> 618)
      and `tests-line-count` (the new test block). Verify with
      `bash scripts/typst-sync-check.sh --counts-only` before committing.
- [ ] Regenerate the machine-owned module-inventory blocks via
      `bash scripts/check-module-invariants.sh --emit-inventory`, then confirm with
      `--emit-inventory --check`, and stage whatever files it rewrote.
      `FormalSystem/Automation/Tactics/README.md` carries `Search.lean`'s raw line count (`620`)
      in a `<!-- BEGIN GENERATED -->` block and will drift. Never hand-edit these numerals.

*Verification and commit*

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project),
      detached as a shell-level background job and blocked on with the bounded single-call idiom
      per `context/project/lean4/operations/long-builds.md` — never
      `Bash(run_in_background: true)`. Require exit 0 with **zero warnings**; under `--wfail` a
      warning is a failure.
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- test`. Require exit 0
      with zero warnings.
- [ ] Confirm no new axioms: `#print axioms` (or `lean_verify` on a fully qualified name) against
      named copies of the box-headed and `allFuture`-headed goals must report only
      `[propext, Classical.choice, Quot.sound]`, with no `sorryAx`.
- [ ] Commit once, as the pre-declared atomic batch (see **Commit Mode**), via
      `.claude/scripts/git-commit-scoped.sh` with an explicit file list — never `git add -A`,
      `git add .`, or a directory/glob pathspec.

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Three edited lines across two source files, one test block plus one
rewritten paragraph in one test file, and exactly two drifting generated surfaces
(`typst/generated/status.typ` and `FormalSystem/Automation/Tactics/README.md`). The generated-surface
half of this is a hypothesis, not a fact: the root `README.md` block counts *code* and *comment*
lines rather than raw lines, so a blank-line deletion was judged not to move it, and
`FormalSystem/README.md` (`rows=loose`) and `FormalSystem/Automation/README.md` (subdirectory
rows showing `—`) were judged unaffected. The implementer confirms by **running both regenerators
and staging whatever they actually rewrite**, rather than by trusting this enumeration; if a
third file is rewritten, stage it and record the deviation.

**Files to modify**:

- `FormalSystem/Tactic/Meta.lean` - `:113`, `mkAppM` -> `mkAppOptM ``List.nil #[some formulaType]`
- `FormalSystem/Automation/Tactics/Search.lean` - relocate both `buildContextExpr` calls (with
  their comments) inside their `observing?` blocks in `tryModalK` and `tryTemporalK`; delete the
  two stray blank lines left above `let success ← observing? do`
- `Tests/BimodalTest/Automation/LemmaDBTest.lean` - invoked `buildContextExpr` `MetaM` probe,
  three `modal_search` acceptance examples, and the rewritten `:235-240` paragraph
- `typst/generated/status.typ` - regenerated `formalsystem-line-count` and `tests-line-count`
  (commit-blocking surface; `scripts/typst-sync-check.sh --fix` owns these numerals)
- `FormalSystem/Automation/Tactics/README.md` - regenerated `Search.lean` line-count row inside
  its `<!-- BEGIN GENERATED -->` block (`scripts/check-module-invariants.sh --emit-inventory`
  owns it)

**Verification**:

- `FormalSystem/Tactic/Meta.lean:113` reads `mkAppOptM ``List.nil #[some formulaType]`, and both
  `Search.lean` `buildContextExpr` calls are lexically inside their `observing? do` blocks.
- The invoked `MetaM` probe in `LemmaDBTest.lean` elaborates and its assertions pass (a failing
  `throwError` surfaces as a build error, so a green build of that module is the pass signal).
- All three `modal_search` acceptance examples compile, including the box-headed example named in
  the task description. Research measured this example **red** pre-repair with
  `AppBuilder for `mkAppM`, too many explicit arguments provided to`, so a green build here is a
  genuine discrimination, not a tautology.
- Full-project `lake build` exits 0 with zero errors and zero warnings; `lake test` exits 0 with
  zero warnings. Stated as absolutes rather than as a baseline delta because research measured
  both absolutely green on this tree pre-change (rows 10, 11, 13).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0, and
  `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- Axiom profile on the two named goals is `[propext, Classical.choice, Quot.sound]` with no
  `sorryAx`.
- Any *other* repo-wide lint run is read as a delta against the pre-task baseline, not an
  absolute zero: `check-module-invariants.sh`'s C16 group carries a pre-existing
  `unusedArguments` finding at `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean:2136`
  that is not this task's to fix, and `scripts/check-paper-definitions.sh` exits 1 on manuscript
  drift outside this repository. Each file this phase modifies must pass individually; a
  pre-existing finding outside this phase's file scope is a recorded PASS with that finding
  enumerated, not a blocker.
- **Final-phase gate handling**: this phase's own in-dispatch obligation is the scoped,
  touched-path verification enumerated above. The complete gate set owed once per orchestration
  invocation is **explicitly deferred to the orchestration close**, not invoked independently
  here as this phase's criterion.

---

## Testing & Validation

- [ ] `buildContextExpr []` and `buildContextExpr [p, q]` both return well-typed expressions,
      measured by an invoked probe rather than a `#check`.
- [ ] Both probe results agree with `Meta.mkListLit (mkConst ``Formula) ...`.
- [ ] `example : ⊢ ((Formula.atomS "p").imp (Formula.atomS "p")).box := by modal_search` compiles.
- [ ] `example : [(Formula.atomS "p").box] ⊢ ((Formula.atomS "p").imp (Formula.atomS "p")).box := by modal_search`
      compiles (drives the `List.cons` fold through the tactic).
- [ ] `example : ⊢ ((Formula.atomS "p").imp (Formula.atomS "p")).allFuture := by modal_search`
      compiles (the only acceptance coverage `tryTemporalK` gets).
- [ ] Full `lake build` and `lake test`: exit 0, zero errors, zero warnings.
- [ ] No new axioms; no `sorryAx`.
- [ ] `typst-sync-check.sh --counts-only` and `check-module-invariants.sh --emit-inventory --check`
      both exit 0, so the commit is not refused by `.githooks/pre-commit`.

## Artifacts & Outputs

- Repaired `FormalSystem/Tactic/Meta.lean` and `FormalSystem/Automation/Tactics/Search.lean`.
- Extended `Tests/BimodalTest/Automation/LemmaDBTest.lean` with an invoked `buildContextExpr`
  probe, three `modal_search` acceptance examples, and corrected section prose.
- Regenerated `typst/generated/status.typ` and `FormalSystem/Automation/Tactics/README.md`.
- One summary artifact at `specs/958_repair_buildcontextexpr_modal_search/summaries/01_repair-buildcontextexpr-modal-search-summary.md`.

## Rollback/Contingency

The change is confined to one token in `Meta.lean`, two statement relocations plus two blank-line
deletions in `Search.lean`, one test block in `LemmaDBTest.lean`, and two machine-regenerated
files. All of it lands in a single commit (see **Commit Mode**), so reverting that one commit
restores the pre-task tree exactly — including both generated surfaces, since they are staged in
the same commit.

If the phase cannot reach green: do **not** discard uncommitted changes to reach a passing build
(`.claude/rules/error-handling.md`). Fix forward; if genuinely blocked, mark the phase
`[BLOCKED]`, record what was tried and the goal/error state reached, and return
`status: "partial"` with `requires_user_review: true`. Because `.lean` edits are involved, a
would-be plan deviation must be raised as a blocker rather than silently annotated
(`.claude/rules/plan-compliance.md`). Before any intentional rollback that the destructive-git
guard would otherwise refuse, run `bash .claude/scripts/git-snapshot.sh 958` first. Note the
working-tree hazard research recorded: this tree carries other sessions' uncommitted `specs/`
changes, so `git checkout -- <path>` is blocked on a dirty tree; restore from a saved copy
instead.
