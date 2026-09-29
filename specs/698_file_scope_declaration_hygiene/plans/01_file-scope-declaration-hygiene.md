# Implementation Plan: Task #698

- **Task**: 698 - file_scope_declaration_hygiene
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/698_file_scope_declaration_hygiene/reports/01_file-scope-hygiene-audit.md
- **Artifacts**: plans/01_file-scope-declaration-hygiene.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/context/standards/status-markers.md
  - .claude/context/standards/artifact-management.md
  - .claude/context/standards/git-staging-scope.md
  - .claude/rules/state-management.md
  - .claude/rules/git-workflow.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Make `specs/state.json`'s `file_scope` declarations describe what non-terminal tasks actually
touch, so `scripts/validate-state.sh`'s Check 8 (coarse whole-directory declarations) and Check 9
(intra-array duplicates) stop reporting findings that the cross-task admission gate silently
tolerates. Four coarse findings (177's `FormalSystem/Metalogic/Decidability/`; `BimodalTools/` on
282, 296 and 298) and one duplicate finding (178's doubled `FormalSystem/Examples/`) are in scope
by name, along with a shared-gate-script declaration audit and a residue re-check. Every change is
a `specs/state.json` edit made through the mutex-guarded writer; no declaration is widened, and no
finding is silenced by guessing. Done when Check 8 and Check 9 report zero findings for
non-terminal tasks OR every surviving finding carries a justification recorded inline in the
task's own `description`, and the residue (plus the out-of-repo enforcement follow-on) is written
down rather than left implicit.

### Research Integration

`reports/01_file-scope-hygiene-audit.md` supplies every per-item resolution this plan executes,
and each is grounded rather than guessed:

- **177 — justify, do not narrow.** 177's own description says the `Decidability/` re-audit is
  "open-ended by design: re-derive and widen file_scope at research time"; narrowing it before the
  decidability chain lands would be exactly the guessing the task prohibits. 7 of the 8 tasks
  Check 8 reports as overlapping (428, 429, 430, 464, 465, 481, 482) are already in 177's
  `dependencies`, so those overlaps are structurally dependency-gated. **696 is not**, and declares
  `Decidability/PlusWitnessFamily/*` and `Decidability/WitnessFamily/Sharing/*` — that missing
  dependency edge, not the directory-wide claim, is the real defect.
- **282, 296, 298 — narrow.** All three inherited an identical `BimodalTools/` +
  `FormalSystem/Automation/` + `Tests/BimodalToolsTest/` triad as a blanket defensive widening from
  task 632's relocation note, not from what each actually touches. The report derived each task's
  real surface from its description plus the corresponding Lean source: 296 →
  `FormulaEnumerator.lean` / `AtomCanonicalization.lean` / `EnumeratorCountsTest.lean`; 298 →
  `DatasetGenerator.lean` / `DatasetGeneratorTest.lean`; 282 → no `BimodalTools/` surface at all,
  but an undeclared `scripts/run_dataset_generation.sh` mode flip.
- **178 — `--fix`, not a hand edit.** Confirmed by reading `validate-state.sh`'s `--fix` block:
  order-preserving in-array dedup, applied through the deployed `state-write.sh`, then
  repair-then-revalidate fall-through. This is precisely Check 9 Class A.
- **Shared gate scripts — no additions evidenced.** `scripts/check-module-invariants.sh` is already
  declared by 695 and 696, the two tasks whose descriptions demonstrate they edit its
  `AXIOM_BASELINE` heredoc. 700, 481, 482 and 563 reference it only as a non-regression gate; per
  the same anti-guessing standard, a read/gate relationship is not grounds for adding it.
- **Residue — 412 is the priority.** A missing/null `file_scope` is invisible to
  `scopes_overlap_first` and therefore produces no signal at all, strictly worse than a coarse
  directory that at least surfaces as a WARN. 412 (headline tableau-decidability result, plausible
  future editor of `check-module-invariants.sh` + `docs/theorem-index.md`) has `null` file_scope.

Verified independently during planning: baseline `validate-state.sh` reproduces exactly the five
in-scope findings; all six narrowed target paths exist on disk; adding `696` to 177's dependencies
creates no cycle (696 → 700 → ∅, and nothing depends on 177).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context; ROADMAP.md was not consulted
and is not modified by this plan.

## Goals & Non-Goals

**Goals**:
- Repair 178's Check 9 Class A duplicate using the sanctioned `--fix` path.
- Narrow 282, 296 and 298 from the inherited `BimodalTools/` triad to their re-derived,
  evidence-grounded file lists, and record the derivation inline in each description.
- Record inline in 177's description why its `FormalSystem/Metalogic/Decidability/` claim is
  genuinely correct at this stage, and close the one real exposure by adding `696` to its
  `dependencies`.
- Re-verify (against current, this-cycle descriptions and any newly-landed sibling plans) which
  non-terminal tasks actually edit shared gate/tooling scripts — above all
  `scripts/check-module-invariants.sh` — and declare them where evidenced.
- Re-check for undeclared shared write targets among non-terminal tasks and report the residue
  explicitly, including 412's missing declaration.
- Record the out-of-repo postflight-enforcement follow-on durably enough to be filed later.

**Non-Goals**:
- Any edit to `extensions/core/scripts/orchestrate-cycle-postflight.sh` or anything else under
  `/home/benjamin/.config/nvim/agent-system` — a different git repository. Per
  `.claude/rules/source-store-deploy-boundary.md`, `.claude/**` here is a disposable deploy
  artifact, so the enforcement half must be raised as a task in that repository, never attempted
  from here.
- Any hand edit under `.claude/**`, and no redeploy (`deploy-headless.sh`) — regenerating the
  deploy tree mid-cycle would rewrite files under live sibling agents.
- A full sweep of the 28 missing-key/null-value `file_scope` visibility findings. That is a
  separate, larger, separately-tracked class; only 412 is flagged, because it bears directly on the
  shared-script question this task does ask about.
- Repairing the stale `data/*` filenames noticed in 282's and 298's declarations (declared
  `data/bmlogic-c4.json` / `data/bmlogic-c7.jsonl` vs. on-disk `data/bmlogic-c4.jsonl` /
  `data/bmlogic-c7.jsonl.zst`). Correcting these would require guessing which artifact each task
  will actually write; recorded as residue instead.
- Widening any declaration to make a finding disappear.
- Any Lean source, proof, or build change. No `lake build` is implicated by this task.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Concurrent siblings (695, 697, 699, 700) write `specs/state.json` this same cycle; a hand-rolled `jq > tmp && mv` would clobber their rows | H | H | Every write goes through `.claude/scripts/state-write.sh` (fail-closed mutex, private staging path). Never edit `specs/state.json` with `Edit`/`Write`/inline jq redirection. |
| Any commit of `specs/state.json` inevitably carries siblings' current rows — this file is the deliverable, so the contamination cannot be staged away | M | H | Commit via `git-commit-scoped.sh ... --honest-index-rows 698 -- specs/state.json`, which is required at every site staging `specs/state.json`/`specs/TODO.md` and appends an honest "Also carries current index rows for tasks: ..." body line. Never `git add -A`, never a directory pathspec. |
| Narrowing 296/298 to one or two implementation files each could be too tight if their eventual plan needs a shared helper (e.g. a pretty-printer or CLI-arg module) | M | M | Phase 2 re-derives each list against the task's own description before writing, and the recorded note states the declaration is the evidenced surface as of this date, to be re-widened by that task's own research phase if its chosen approach implicates more — the same convention 177's description already uses. |
| `validate-state.sh --fix` applies its dedup filter to every project with a `file_scope`, not just 178 | L | L | `--fix` only ever *removes* exact duplicates (never adds or widens), and it prints every project it touches. Phase 1 captures the Class A finding list immediately before the run and confirms the printed repair list matches it. |
| `--fix` refuses if no deployed `state-write.sh` resolves; this deploy tree is reported STALE for the `core` extension | M | L | The deployed `state-write.sh` is present and resolves today. If `--fix` refuses anyway, STOP and report — do not redeploy mid-cycle (it would rewrite `.claude/**` under live sibling agents) and do not hand-edit `specs/state.json` as a substitute. |
| Adding the 696 edge could delay 177 further if 696 stalls | L | M | 177's own description already carries the precedent ("if one stalls indefinitely, drop its edge rather than hold this task"); Phase 3's note states that clause extends to the new edge. |
| Adding a new `state.json` field (e.g. `file_scope_note`) to hold a justification would trip Check 4's closed `KNOWN_ENTRY_FIELDS` list as a FAIL | M | L | Justifications go inline in the existing `description` field, using the dated-note convention already present in 177's description (`SCOPE NARROWED (YYYY-MM-DD): ...`). No new field is introduced. |
| 177's Check 8 WARN survives by design, which could read as an unmet deliverable | L | H | The deliverable admits this explicitly ("or every surviving finding carries a recorded justification"). Phase 5 states the surviving finding and points at where its justification is recorded. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential by
construction: every phase writes the same single file (`specs/state.json`) and commits it, so
serializing the phases keeps each commit's diff attributable to one named repair rather than
interleaving two.

### Phase 1: Baseline capture and Check 9 duplicate repair (project 178) [NOT STARTED]

**Goal**: Record the pre-change finding set, then remove 178's exact-duplicate
`FormalSystem/Examples/` entry through `validate-state.sh --fix` rather than by hand.

**Tasks**:
- [ ] Capture the baseline to the scratchpad (not the repo):
      `bash .claude/scripts/validate-state.sh > "$SCRATCH/validate-before.txt" 2>&1 || true`,
      then grep it for `Coarse file_scope` / `Duplicate file_scope` and keep that list as the
      before-state for Phase 5's comparison.
- [ ] Confirm from that capture that project 178 is the only Class A (exact) duplicate reported.
      If a sibling has introduced another since research, note it and still proceed — `--fix`
      repairs exact duplicates only and never widens.
- [ ] Run `bash .claude/scripts/validate-state.sh --fix` and read its printed
      `--fix: project_number N: removing M exact-duplicate file_scope entry(ies)` lines.
- [ ] Confirm the printed repair list matches the Class A findings captured above. If `--fix`
      refuses for want of a deployed `state-write.sh`, STOP and report per the Risks table — do not
      redeploy and do not hand-edit `specs/state.json`.
- [ ] Verify the repair landed:
      `jq -r '.active_projects[] | select(.project_number==178) | .file_scope' specs/state.json`
      shows a single `FormalSystem/Examples/` entry.
- [ ] Commit:
      `bash .claude/scripts/git-commit-scoped.sh --message "task 698 phase 1: repair duplicate file_scope entry on project 178" --session "$SESSION_ID" --honest-index-rows 698 -- specs/state.json`

**Timing**: 30 minutes

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that project 178 is the *only* Class A duplicate in the
current `specs/state.json` (research observed exactly one). Confirm at implementation time from the
baseline capture's own `Duplicate file_scope entry (Class A` lines and from `--fix`'s printed
repair list — do not assume the count.

**Files to modify**:
- `specs/state.json` - project 178's `file_scope`: the doubled `FormalSystem/Examples/` collapses
  to one entry (written by `--fix` via the deployed `state-write.sh`, not by hand)

**Verification**:
- `bash .claude/scripts/validate-state.sh 2>&1 | grep "Duplicate file_scope"` reports the Class A
  PASS line (`No duplicate file_scope entries found`) and no 178 finding.
- `jq empty specs/state.json` succeeds.
- `git show --stat HEAD` shows `specs/state.json` and nothing else.

---

### Phase 2: Narrow the three inherited `BimodalTools/` declarations (282, 296, 298) [NOT STARTED]

**Goal**: Replace each of 282's, 296's and 298's `BimodalTools/` + `FormalSystem/Automation/` +
`Tests/BimodalToolsTest/` triad with the specific paths that task will touch, re-derived from its
own description, and record the derivation inline.

**Tasks**:
- [ ] For each of 282, 296 and 298, read the current description fresh
      (`jq -r '.active_projects[] | select(.project_number==N) | .description' specs/state.json`)
      and confirm the report's derived file list still follows from it. If a description implies a
      path the report did not name, add that path — do not drop it, and do not add a path the
      description does not imply.
- [ ] Project 296: replace the three directory entries with
      `BimodalTools/FormulaEnumerator.lean`, `BimodalTools/AtomCanonicalization.lean`,
      `Tests/BimodalToolsTest/EnumeratorCountsTest.lean`. Leave `data/bmlogic-c4.json` untouched.
- [ ] Project 298: replace the three directory entries with
      `BimodalTools/DatasetGenerator.lean`, `Tests/BimodalToolsTest/DatasetGeneratorTest.lean`.
      Leave `data/bmlogic-c7.jsonl` untouched.
- [ ] Project 282: drop all three directory entries and add
      `scripts/run_dataset_generation.sh` (the mode flip its description's next action names, never
      previously declared). Leave the four `data/*` entries untouched.
- [ ] Apply each edit through the mutex-guarded writer, one project per call, e.g.:
      `bash .claude/scripts/state-write.sh '.active_projects |= map(if .project_number==296 then .file_scope = $fs else . end)' --session-id "$SESSION_ID" --argjson fs '["BimodalTools/FormulaEnumerator.lean", ...]'`
      Never `Edit`/`Write` on `specs/state.json`, and never a hand-rolled `jq > tmp && mv`.
- [ ] Append a dated note to each of the three descriptions, in the same
      `SCOPE NARROWED (2026-09-28): ...` shape 177's description already uses, stating: what was
      removed, what replaced it, the evidence it was derived from (the description's own named work
      plus the corresponding Lean source), that the triad was an inherited blanket widening from
      task 632's relocation note rather than a derived surface, and that this task's own research
      phase should re-widen if its chosen approach implicates more files.
- [ ] Verify Check 8 no longer reports 282, 296 or 298, and that no new coarse or duplicate finding
      appeared (the edit only replaces directory-ending entries with file-ending ones).
- [ ] Commit:
      `bash .claude/scripts/git-commit-scoped.sh --message "task 698 phase 2: narrow inherited BimodalTools/ declarations on projects 282, 296, 298" --session "$SESSION_ID" --honest-index-rows 698 -- specs/state.json`

**Timing**: 45 minutes

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts a specific narrowed file list per task (3 paths for 296,
2 for 298, 1 added and 3 removed for 282) and that all six named Lean/script paths exist. Both were
confirmed during planning (each path `stat`s), but confirm again at implementation time by
re-reading each description before writing, and by `ls` on each path — a path that does not exist
is permitted in `file_scope` (it is prospective, never filesystem-validated), but its absence is a
signal to re-check the derivation rather than to declare it anyway.

**Files to modify**:
- `specs/state.json` - projects 282, 296, 298: `file_scope` narrowed, `description` gains a dated
  `SCOPE NARROWED` note

**Verification**:
- `bash .claude/scripts/validate-state.sh 2>&1 | grep "Coarse file_scope"` reports no finding for
  282, 296 or 298.
- `jq -r '.active_projects[] | select([282,296,298] | index(.project_number)) | "\(.project_number): \(.file_scope)"' specs/state.json`
  shows no trailing-`/` entry on any of the three.
- `bash .claude/scripts/validate-state.sh 2>&1 | grep -c "Duplicate file_scope entry"` is unchanged
  from Phase 1's post-state (no new duplicate introduced).
- `jq empty specs/state.json` succeeds.

---

### Phase 3: Justify 177's `Decidability/` claim and close the 177 to 696 dependency gap [NOT STARTED]

**Goal**: Record inline why 177's whole-directory `FormalSystem/Metalogic/Decidability/`
declaration is genuinely correct at this stage, and close the one real residual exposure by adding
`696` to 177's `dependencies`.

**Tasks**:
- [ ] Re-read 177's description and confirm the justification still holds: the `Decidability/`
      re-audit is gated on the decidability chain landing and the description itself defers the
      narrowing ("re-derive and widen file_scope at research time"), so narrowing now would be
      guessing.
- [ ] Re-run Check 8 and read 177's current overlap list. Confirm which of the reported overlaps
      are already covered by 177's `dependencies` (research found 7 of 8: 428, 429, 430, 464, 465,
      481, 482) and which are not (research found 696). If the overlap list has changed this cycle,
      apply the same test to the new members rather than assuming the old list.
- [ ] Add each un-gated overlapping task number to 177's `dependencies` via the mutex-guarded
      writer, e.g.:
      `bash .claude/scripts/state-write.sh '.active_projects |= map(if .project_number==177 then .dependencies = ((.dependencies // []) + [696] | unique) else . end)' --session-id "$SESSION_ID"`
- [ ] Append a dated note to 177's description, in its existing `FURTHER EDGES (YYYY-MM-DD): ...`
      shape, recording: (a) the justification for retaining the whole-directory entry, naming the
      description's own deferral clause; (b) that 7 of the 8 reported overlaps were already
      dependency-gated; (c) the new 696 edge and the specific shared paths that motivate it
      (`Decidability/PlusWitnessFamily/*`, `Decidability/WitnessFamily/Sharing/*`); (d) that the
      existing "if one stalls indefinitely, drop its edge rather than hold this task" clause extends
      to the new edge.
- [ ] Verify no dependency cycle was introduced (planning confirmed 696 → 700 → none, and nothing
      depends on 177, but re-confirm mechanically).
- [ ] Commit:
      `bash .claude/scripts/git-commit-scoped.sh --message "task 698 phase 3: justify project 177 Decidability declaration and add missing 696 dependency edge" --session "$SESSION_ID" --honest-index-rows 698 -- specs/state.json`

**Timing**: 30 minutes

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that exactly one of 177's 8 reported overlaps (696) lacks
a dependency edge. Confirm at implementation time by intersecting Check 8's printed overlap list
for 177 with `jq '.active_projects[] | select(.project_number==177) | .dependencies'` — do not take
the count of one on faith, since sibling tasks may have changed the non-terminal population this
cycle.

**Files to modify**:
- `specs/state.json` - project 177: `dependencies` gains 696 (and any other un-gated overlapping
  task found at implementation time), `description` gains a dated `FURTHER EDGES` note carrying the
  whole-directory justification

**Verification**:
- `bash .claude/scripts/validate-state.sh 2>&1 | grep "dependency cycle\|No dependency cycles"`
  reports the PASS line.
- `jq -r '.active_projects[] | select(.project_number==177) | .dependencies | index(696)'
  specs/state.json` is non-null.
- `jq -r '.active_projects[] | select(.project_number==177) | .description' specs/state.json | tail
  -c 800` shows the new dated note.
- Check 8 still reports 177's `Decidability/` entry (expected, now justified) and reports no other
  coarse finding.

---

### Phase 4: Shared gate/tooling script declarations — re-verify and declare where evidenced [NOT STARTED]

**Goal**: Determine, against current descriptions and any sibling plans that landed this cycle,
which non-terminal tasks actually *edit* shared gate/tooling scripts — above all
`scripts/check-module-invariants.sh` — and add the script to those tasks' declarations only where
the evidence is an edit, not a gate dependency.

**Tasks**:
- [ ] Enumerate candidates fresh rather than reusing the research list: with `jq`, select every
      `active_projects[]` entry whose `status` is not in `{completed, abandoned, expanded}` and whose
      `description` matches `check-module-invariants|AXIOM_BASELINE|axiom baseline|theorem-index`,
      printing `project_number` and `status`. Note the `jq` safety convention in
      `.claude/CLAUDE.md`: write `select(.x == "y" | not)` rather than `select(.x != "y")`, since
      `!=` gets escaped and produces a parse error.
- [ ] For each candidate, classify the relationship as EDIT (the description or its landed plan
      commits to changing the script's content — e.g. pinning a new `AXIOM_BASELINE` row or adding
      a `docs/theorem-index.md` row) or GATE (the script is only named as a non-regression check).
      Research classified 695 and 696 as EDIT (both already declare the script) and 700, 481, 482
      and 563 as GATE.
- [ ] Because siblings 695, 697, 699 and 700 are being planned this same cycle, re-check whether any
      of their newly-written plans names `scripts/check-module-invariants.sh` or
      `docs/theorem-index.md` under a `Files to modify` block while the task's `file_scope` omits it:
      `bash .claude/scripts/plan-file-scope-harvest.sh <plan-path>` per landed plan, compared
      against that task's declared `file_scope`.
- [ ] Add the shared script to the `file_scope` of every task classified EDIT that does not already
      declare it, via `state-write.sh`, with a dated note in that task's description naming the
      evidence. Add nothing for a GATE classification — a read/non-regression relationship is not
      grounds for a declaration.
- [ ] Record the classification table (candidate, EDIT/GATE, evidence, action) for the summary,
      including the explicit negative result if no task needs a change.
- [ ] Commit only if a declaration actually changed:
      `bash .claude/scripts/git-commit-scoped.sh --message "task 698 phase 4: declare shared gate scripts on tasks that edit them" --session "$SESSION_ID" --honest-index-rows 698 -- specs/state.json`

**Timing**: 30 minutes

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that no further task needs
`scripts/check-module-invariants.sh` added (695 and 696 already declare it; 700, 481, 482 and 563
are gate-only). This is the hypothesis most likely to change between research and implementation,
because sibling plans land this same cycle. Confirm by re-running the candidate enumeration above
and the per-plan `plan-file-scope-harvest.sh` comparison before concluding "no change needed"; a
zero-change outcome is a legitimate, reportable result, but only after that re-check.

**Files to modify**:
- `specs/state.json` - conditionally: `file_scope` and `description` of any task newly evidenced as
  an editor of a shared gate/tooling script. No change expected on current evidence; if none is
  evidenced, this phase writes no file and records the negative result instead.

**Verification**:
- The classification table exists with an explicit EDIT/GATE verdict and named evidence for every
  candidate the enumeration returned.
- For every task classified EDIT, `jq` confirms `scripts/check-module-invariants.sh` is present in
  its `file_scope`.
- `bash .claude/scripts/validate-state.sh` introduces no new Check 8/9 finding relative to Phase 3
  (an added single-file entry can create neither a coarse nor a duplicate finding).

---

### Phase 5: Residue re-check, close-out and follow-on record [NOT STARTED]

**Goal**: Re-check that no remaining pair of non-terminal tasks has an undeclared shared write
target, report the residue rather than silently leaving it, and record the out-of-repo enforcement
follow-on.

**Tasks**:
- [ ] Run the full validator and diff against Phase 1's baseline capture:
      `bash .claude/scripts/validate-state.sh > "$SCRATCH/validate-after.txt" 2>&1 || true` then
      `diff <(grep -E "Coarse file_scope|Duplicate file_scope" "$SCRATCH/validate-before.txt") <(grep -E "Coarse file_scope|Duplicate file_scope" "$SCRATCH/validate-after.txt")`.
      Confirm every removed line is an in-scope repair and that no line was added.
- [ ] Write a throwaway probe in the scratchpad (never committed) that sources
      `.claude/scripts/lib/file-scope-overlap.sh` and, using its canonical `scopes_overlap_first`
      predicate (never a re-derived rule), enumerates every pair of non-terminal tasks whose
      declared `file_scope`s overlap AND between which no dependency edge exists in either
      direction. Report that list as the residual undeclared-shared-write-target set.
- [ ] Note explicitly that two tasks correctly declaring the *same specific file* (695 and 696 both
      declaring `scripts/check-module-invariants.sh` and `docs/theorem-index.md`) is not a defect —
      the territory contract's per-hunk staging discipline is the designed mechanism for that case.
- [ ] Record the residue for the summary: (a) the non-dependency-gated overlapping pairs from the
      probe; (b) project 412's `null` `file_scope`, with the reason it outranks any coarse
      declaration (a missing declaration is invisible to `scopes_overlap_first`, so it produces no
      signal at all, not even a WARN); (c) the 28 missing-key/null-value visibility findings as a
      separately-tracked class this task deliberately did not sweep; (d) the stale `data/*`
      filenames on 282 and 298, left uncorrected because choosing the real target would be guessing.
- [ ] Record the named follow-on for the other repository:
      `/home/benjamin/.config/nvim/agent-system`, file
      `extensions/core/scripts/orchestrate-cycle-postflight.sh`, block
      "WORK (h): modified_files vs file_scope excursion advisory (detection only)" — the excursion
      computation already exists and is correct; only its consequence (stderr advisory, no gate, no
      exit-code, no verdict effect) needs changing. State that it must be filed as a task in that
      repository and must not be attempted from here, per
      `.claude/rules/source-store-deploy-boundary.md`.
- [ ] Regenerate the rendered view: `bash .claude/scripts/generate-todo.sh`. Do not stage
      `specs/TODO.md` from this phase — it is wholesale-regenerated and currently carries
      concurrent siblings' pending rows; 698's own postflight stages it under
      `--honest-index-rows`.
- [ ] Run the repo-wide task-reference lint to confirm this task introduced no task-number citation
      outside `specs/**`: `bash .claude/scripts/check-task-references.sh`.
- [ ] Commit any final `specs/state.json` delta:
      `bash .claude/scripts/git-commit-scoped.sh --message "task 698 phase 5: re-check file_scope residue and record enforcement follow-on" --session "$SESSION_ID" --honest-index-rows 698 -- specs/state.json`

**Timing**: 45 minutes

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the end state is "Check 8 reports exactly one finding
(177's, justified) and Check 9 reports none". Confirm from the before/after diff, not from this
plan's prediction: a sibling's own plan-postflight `file_scope` harvest can legitimately add a new
coarse declaration this cycle, which would be a new finding this task did not create and must
report rather than silently absorb.

**Files to modify**:
- `specs/state.json` - only if the residue re-check surfaces an in-scope repair not already made
- `specs/TODO.md` - regenerated from `specs/state.json` via `generate-todo.sh` (generated view,
  never hand-edited; deliberately not staged by this phase)

**Verification**:
- Check 9 reports `No duplicate file_scope entries found`.
- Check 8 reports at most the single project-177 `Decidability/` finding, and a justification for
  it is present inline in 177's `description` (confirmed by `jq` + `grep`).
- The before/after diff adds no finding line.
- `jq empty specs/state.json` succeeds and `bash .claude/scripts/validate-state.sh` reports no
  *new* FAIL relative to the baseline capture (the 10 pre-existing schema FAILs — unknown
  top-level/entry fields — are out of scope and must be unchanged, not fixed).
- `bash .claude/scripts/check-task-references.sh` passes.
- The residue list and the follow-on record both exist in the implementation summary.

---

## Testing & Validation

- [ ] `bash .claude/scripts/validate-state.sh` — Check 9 PASS; Check 8 reports at most project
      177's justified `Decidability/` entry.
- [ ] Before/after diff of the Check 8 + Check 9 finding lines shows only removals, never an
      addition.
- [ ] `jq empty specs/state.json` succeeds after every phase.
- [ ] The 10 pre-existing schema FAILs and the count of non-terminal tasks are unchanged — this task
      neither fixed nor worsened them.
- [ ] No declaration was widened: for every task touched, the post-state `file_scope` is a subset
      of the pre-state's coverage, except where a *specific file* was added on named evidence
      (282's `scripts/run_dataset_generation.sh`; any Phase 4 EDIT addition). Verify by diffing
      `git show HEAD~N:specs/state.json` against the working copy per touched project.
- [ ] `bash .claude/scripts/check-task-references.sh` passes (no task-number citation escaped
      `specs/**`).
- [ ] Every commit's `git show --stat` lists only `specs/state.json` (plus whatever 698's own
      postflight stages), and every commit body carries the `--honest-index-rows` addendum when
      sibling rows rode along.

## Artifacts & Outputs

- `specs/state.json` — repaired declarations on projects 177, 178, 282, 296, 298 (and conditionally
  a Phase 4 EDIT task), each substantive change accompanied by a dated inline note in that project's
  `description`.
- `specs/698_file_scope_declaration_hygiene/summaries/01_file-scope-declaration-hygiene-summary.md`
  — must carry: the before/after Check 8/9 finding lists; the surviving-finding justification and
  where it is recorded; the Phase 4 EDIT/GATE classification table; the residue list (non-gated
  overlapping pairs, 412's missing declaration, the visibility class, the stale `data/*` names);
  and the named out-of-repo follow-on.
- `specs/TODO.md` — regenerated view (not staged by this plan's phases).
- Scratchpad only, never committed: `validate-before.txt`, `validate-after.txt`, and the pairwise
  overlap probe.

## Rollback/Contingency

Every phase is one `specs/state.json` commit, so the unit of revert is a single commit:
`git revert <sha>` for the offending phase, or `git show <sha>:specs/state.json` to recover a prior
value for one project and re-apply it through `state-write.sh`. Prefer both of these to any
working-tree discard: siblings are writing this same file concurrently this cycle, so a whole-tree
rollback would destroy their in-flight work.

If a rollback that discards uncommitted work is genuinely unavoidable, take a durable snapshot
first and follow `context/contracts/recovery.md`'s rollback rung for the exact invocation shape,
including its out-of-scope override flag for the deliberate whole-tree case. Do not emit a
default-mode `git-snapshot.sh 698` as a precautionary checkpoint — for a defensive checkpoint
before risky work, use the non-reverting `--no-revert` form instead.

Because `--fix` (Phase 1) writes through `state-write.sh`, a bad outcome there is recoverable the
same way: revert the Phase 1 commit rather than re-editing by hand.
