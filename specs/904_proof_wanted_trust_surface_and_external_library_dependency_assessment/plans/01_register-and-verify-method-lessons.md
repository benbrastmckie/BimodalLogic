# Implementation Plan: Task #904

- **Task**: 904 - File three method lessons from the cslib omega-automata reassessment report's Context Extension Recommendations
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/904_proof_wanted_trust_surface_and_external_library_dependency_assessment/reports/01_proof-wanted-trust-surface-and-dependency-assessment-lessons.md`
- **Artifacts**: plans/01_register-and-verify-method-lessons.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The research round for this task did not merely research — it authored all three method lessons
directly in the source store, and plan-authoring verification confirms each one is present and
content-complete against the dispatch's stated requirements. This plan therefore does not
re-author them. It closes the four gaps that authoring round left behind: the new pattern file is
absent from both of the lean extension's explicit per-file discoverability registries, its
cross-link to `dependency-tracing.md` runs one direction only, it carries one occurrence of a
phrase the record-versioning lint pattern matches, and the research report's own Decisions
section records the cross-link state that the first of those fixes will change.

### Research Integration

The report at `reports/01_proof-wanted-trust-surface-and-dependency-assessment-lessons.md`
resolved `source_dir` per extension and authored each lesson at the path the source-store/deploy
boundary requires. Plan-authoring re-verification of its claims, against the source store on
disk:

| Lesson | Target | Verified state |
|--------|--------|----------------|
| 1 | `lean/context/project/lean4/domain/metadata-trust-surfaces.md` | `## 6. proof_wanted is a trust surface distinct from sorry` present (line 180); prior section renumbered to `## 7. Practical consequences`; `grep -c '^proof_wanted'` named as the reliable detector; the declares-nothing claim stated |
| 2 | `lean/context/project/lean4/patterns/external-library-dependency-assessment.md` | New file, 122 lines, untracked in the source-store git repository; all five checklist items present with their measured consequences |
| 3 | `core/context/formats/report-format.md` | `## Amending a Prior Verdict: Ground Overturned vs. Outcome Overturned` present (line 138), between Carried-Figure Discipline and Example Skeleton |

Both edited files' `index-entries.json` `line_count` figures were already refreshed by that round
(229/229 and 218/218, measured). The report's own Recommendations section claims "no further
action is required to finish these three lessons"; that claim is correct about each lesson's
*content* and incomplete about its *reachability*, which is what this plan addresses.

Three findings from plan-authoring verification that the research report does not record:

- `lean/manifest.json`'s `provides.context` is **directory-based** (`["project/lean4",
  "contracts"]`), so the new file is already covered for file-copy deployment. No manifest edit is
  needed, and none is planned.
- `lean/index-entries.json` holds 43 entries and **none** matches the new file's path; a per-file
  index entry is explicit and does not follow from the directory-based `provides.context`.
- `lean/EXTENSION.md`'s `### Context Pointers` list names `dependency-tracing.md`,
  `plan-authoring-gate-collisions.md` and `metadata-trust-surfaces.md` individually, and does not
  name the new file.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and no `roadmap_flag` was set; no roadmap phases
are included and no ROADMAP.md was read or will be written.

## Goals & Non-Goals

**Goals**:

- Make `external-library-dependency-assessment.md` reachable through both of the lean extension's
  explicit per-file registries (`index-entries.json`, `EXTENSION.md`).
- Close the one-directional cross-link between the new pattern file and `dependency-tracing.md`.
- Remove the single record-versioning lint-pattern occurrence from the newly authored prose.
- Re-verify every content requirement the dispatch states for each of the three lessons, and
  every NON-GOAL it states, against the source store on disk.
- Bring the research report's Decisions section into agreement with the cross-link's final state.

**Non-Goals**:

- Re-authoring or restructuring any of the three lessons. Their content is verified complete.
- Any hand-authored file under `.claude/**` in either repository.
- Running or claiming a redeploy. The registration edits take effect at the next redeploy, which
  this task does not perform; the deployed tree is already flagged stale for six extensions
  independently of this task.
- Any change under `FormalSystem/`, `Tests/`, `lakefile.toml`, or `lake-manifest.json`.
- Adding the new file to `lean/context/project/lean4/README.md`'s Key Files list. That list is
  already partial — it names neither `dependency-tracing.md` nor
  `plan-authoring-gate-collisions.md` — so omitting the new file matches existing practice rather
  than creating an inconsistency.
- Committing the source-store repository (`~/.config/nvim`). See Risks below.
- Any `lean/manifest.json` edit; `provides.context` already covers the new file by directory.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Source-store edits live on disk but unrecorded in git — that repository already carried unrelated modified and untracked paths before this task touched it | M | H (already the case) | This plan names every source-store path it touches so a later reader can distinguish them from the pre-existing dirt; committing a shared external repository on unrelated concurrent work's behalf stays out of scope |
| Registration edits are invisible until the next redeploy, so a reader checking the deployed tree sees no change | L | H (by design) | Every Phase 2 verification criterion asserts source-store state only, never deployed state; the redeploy non-goal is stated above |
| Piping `index-entries.json` through `jq` reflows every record's formatting, producing a diff far wider than the two records actually changed | M | M | Edit the JSON with a targeted in-place edit rather than a whole-file `jq` rewrite, then diff to confirm only the intended records moved (see `context/patterns/jq-escaping-workarounds.md`'s reflow section) |
| A sibling task (903, plan phase, no declared file scope) runs this same cycle on this same working tree | M | M | Re-read every file immediately before editing it; stage only this task's own hunks by explicit file list; never run `git-snapshot.sh` in its reverting default mode; report any foreign commit or modification rather than dismissing it |
| A future renumbering of `metadata-trust-surfaces.md` silently breaks a `§N` cross-reference | L | L | Phase 3 re-runs the `grep -n '§[0-9]'` sweep the research round performed, keeping the check on the record |
| `dependency-tracing.md` has no `## See Also` section to extend, so the back-link requires creating one | L | H (verified absent) | Phase 1's task states both branches: create the section, or extend it if one has appeared by implementation time |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |

Phases within the same wave can execute in parallel. Phase 2 follows Phase 1 because it records
line counts that Phase 1's edits can change, and because both phases would otherwise contend for
`index-entries.json`.

---

### Phase 1: Close the content-level loose ends [COMPLETED]

**Goal**: Remove the one record-versioning lint-pattern occurrence from the newly authored prose,
and make the cross-link between the new pattern file and `dependency-tracing.md` bidirectional.

**Tasks**:

- [x] Re-read `external-library-dependency-assessment.md` around line 70 immediately before
      editing, in case a sibling has changed the file. *(completed: confirmed line 70 unchanged)*
- [x] Rephrase the one occurrence of `no longer` (line 70: "may describe code that no longer
      matches what is on disk") so the technical meaning is preserved without the matched phrase —
      e.g. "may describe code that differs from what is now on disk". This is a lint-pattern
      occurrence, not a genuine draft-history reference, but rephrasing is cheaper than carrying a
      standing exemption. *(completed: rephrased to "differs from what is now on disk")*
- [x] Re-run the combined sweep over all three authored files for
      `task [0-9]+|tasks [0-9]+|no longer|previously|formerly|used to |supersedes|withdrawn|carried forward from`
      and confirm zero remaining hits. *(completed: zero hits confirmed)*
- [x] Append a `## See Also` section to `dependency-tracing.md` with one entry pointing at
      `context/project/lean4/patterns/external-library-dependency-assessment.md`, naming the
      shared import-closure technique as the specific connection. If that file has acquired a
      `## See Also` section by implementation time, add the entry to the existing section instead
      of creating a second one. *(completed: section created, file grew to 237 lines)*

**Timing**: 0.4 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for both paths, so no
suite covers them; the covering check is the source-store gate subset
`bash /home/benjamin/.config/nvim/.claude/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim`
(sub-case (b): that repository root holds both a deployed `.claude/` tree and
`agent-system/extensions`) together with this tier's diff read-through.

**Scope Hypothesis**: exactly one record-version pattern occurrence exists across the three
authored files — a single `no longer` at line 70 of `external-library-dependency-assessment.md` —
and `dependency-tracing.md` carries no `## See Also` section (its last heading is `## Usability
Without the Originating Repository`). Confirm both with the grep sweep and a `grep -n '^## '` over
`dependency-tracing.md` before editing; if either differs, adjust the edit rather than assuming
the figure.

**Files to modify**:

- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/patterns/external-library-dependency-assessment.md` - rephrase the one `no longer` occurrence. File exists (verified at authoring time, 122 lines); if it is absent at implementation time, STOP and report rather than re-authoring it — the whole plan rests on the research round's authoring being intact.
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/patterns/dependency-tracing.md` - append a `## See Also` section carrying the back-link. File exists (verified, 229 lines, no See Also section); if a See Also section is present by then, extend it instead.

**Verification**:

- The combined record-version / task-reference grep over all three authored files returns no hit.
- `grep -c 'external-library-dependency-assessment' <dependency-tracing.md>` returns 1.
- `grep -c 'dependency-tracing' <external-library-dependency-assessment.md>` is still nonzero
  (the forward link was not disturbed).
- The source-store gate subset named in the Tier Justification exits 0.
- Diff read-through confirms every changed hunk lies in prose, with no change to any code block's
  command text.

---

### Phase 2: Register the new pattern file in both explicit registries [COMPLETED]

**Goal**: Make `external-library-dependency-assessment.md` discoverable through the two per-file
registries that do not pick it up from the directory-based `provides.context` entry: the lean
extension's index entries and its merged Context Pointers list.

**Tasks**:

- [x] Measure the post-Phase-1 line counts of both
      `external-library-dependency-assessment.md` and `dependency-tracing.md` with `wc -l`. Do not
      reuse the authoring-time figures (122 / 229) without re-measuring — Phase 1 edits both files.
      *(completed: 122 unchanged / 237 post-Phase-1)*
- [x] Add one entry to `lean/index-entries.json`'s `entries` array for the new file, copying the
      field shape of the existing `dependency-tracing.md` entry verbatim: `path`, `line_count`,
      `load_when.agents`, `load_when.task_types`, `domain` (`project`), `subdomain` (`lean`),
      `summary`, `keywords`. *(completed)*
- [x] Set the new entry's `load_when.agents` to both `lean-research-agent` and
      `lean-implementation-agent`, matching the `plan-authoring-gate-collisions.md` entry rather
      than `dependency-tracing.md`'s implementation-only list: whether to adopt an external
      library is a research-phase question before it is an implementation one. *(completed)*
- [x] Refresh the existing `dependency-tracing.md` entry's `line_count` in the same file to its
      post-Phase-1 value. *(completed: 229 -> 237)*
- [x] Make both JSON changes with a targeted in-place edit, not a whole-file `jq` rewrite, then
      diff to confirm only those two records changed and no unrelated record was reflowed.
      *(completed: targeted Edit used; diff confined to the two intended records plus one
      pre-existing, uncommitted change to the metadata-trust-surfaces.md entry's line_count from
      the prior research-round dispatch — not touched by this phase)*
- [x] Append one `### Context Pointers` line to `lean/EXTENSION.md`, placed immediately after the
      `dependency-tracing.md` line, using the same deployed-path form
      (`.claude/context/project/lean4/patterns/...`) and `path - description` shape the
      surrounding entries use. *(completed)*

**Timing**: 0.4 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `suite_selection_select` maps this phase's two paths to five real suites,
so the covering check is
`bash /home/benjamin/.config/nvim/.claude/scripts/tests/run-all.sh --only test-context-reachability.sh,test-deploy-orphans.sh,test-index-entries-schema.sh,test-install-uninstall-extension.sh,test-manifest-scripts-sync.sh`
run in the source-store repository, which is where these registry suites have anything to read.

**Scope Hypothesis**: `lean/index-entries.json` currently holds 43 entries, none with
`path == "project/lean4/patterns/external-library-dependency-assessment.md"`, and
`lean/EXTENSION.md` has no pointer line naming that file. Confirm with
`jq -r '.entries | length'` and a grep over both files before editing; if the entry already
exists, update it in place rather than adding a duplicate.

**Files to modify**:

- `/home/benjamin/.config/nvim/agent-system/extensions/lean/index-entries.json` - add one entry for the new pattern file; refresh `dependency-tracing.md`'s `line_count`. File exists (verified, 43 entries); if absent at implementation time, STOP and report.
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/EXTENSION.md` - add one Context Pointers line. File exists (verified, pointer list at lines 32-40); if the pointer list has moved, place the entry beside the `dependency-tracing.md` line wherever it now sits.

**Verification**:

- `jq empty <index-entries.json>` exits 0.
- `jq -r '.entries | length'` returns 44.
- `jq -r '.entries[] | select(.path=="project/lean4/patterns/external-library-dependency-assessment.md")'`
  returns one complete entry whose `line_count` equals the file's measured `wc -l`.
- `jq -r '.entries[] | select(.path=="project/lean4/patterns/dependency-tracing.md") | .line_count'`
  equals that file's measured `wc -l`.
- `grep -c 'external-library-dependency-assessment' <EXTENSION.md>` returns 1.
- `git -C /home/benjamin/.config/nvim diff -- agent-system/extensions/lean/index-entries.json`
  shows changes confined to the two intended records.
- The five-suite `run-all.sh --only` invocation named in the Tier Justification exits 0. Two of
  those suites (`test-index-entries-schema.sh`, `test-context-reachability.sh`) are the specific
  reason this phase is suite-covered rather than a pure prose edit: they are what would catch a
  malformed new entry or a pointer naming a path that does not resolve.

---

### Phase 3: Verification sweep, report amendment, and final gate [COMPLETED WITH EXCLUSIONS]

**Goal**: Confirm every content requirement and NON-GOAL the dispatch states, bring the research
report's Decisions section into agreement with the cross-link's final state, and run the complete
gate set.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| Task repository's full `verify-deploy.sh` run (BimodalLogic) | This dispatch's own dispatch file (`.dispatch/6.md`) carries a `## Batch Gate Deferral` section directing this final `full`-tier phase to discharge against a scoped tier instead of independently running the complete gate set, since this is one of several `implement`-phase dispatches inside one multi-task `/orchestrate` batch invocation; the complete gate set runs once, for the whole batch, at the end of the invocation. | Dispatch file section quoted verbatim in the dispatch context; scoped discharge run instead: `validate-artifact.sh` on the amended report exited 0 ("[PASS] report artifact is valid (0 warning(s))"), and a fast non-source-store-only gate subset (`verify-deploy.sh --skip-slow --only-gate 1,2`) exited 0 ("PASS -- 12 check(s), 0 failure(s)"). |
| Source-store `verify-deploy.sh` gate 3 (doc-lint, Rule S deployed-index-orphan) | Rule S reads the DEPLOYED `.claude/context/index.json` directly, which only picks up this task's `lean/index-entries.json` registration at redeploy time; this plan's own Non-Goals explicitly exclude running or claiming a redeploy. Structurally unresolvable within this task's scope without violating a stated Non-Goal. | `check-extension-docs.sh` output: "FAIL: Rule S: deployed context/project/lean4/patterns/external-library-dependency-assessment.md has no entry in .claude/context/index.json" (also observed identically at the end of Phase 1, before Phase 2's registration edit, confirming it is pre-existing and redeploy-gated, not introduced by this task's content edits). |
| Source-store `verify-deploy.sh` gate 5 (manifest-driven content-hash equality) | Reports "Content differs from source" for `dependency-tracing.md` and `external-library-dependency-assessment.md` because the deployed copies have not been regenerated from the just-edited source files — this is the direct, unavoidable consequence of this plan's Non-Goal against running a redeploy. | `verify-deploy.sh --skip-slow` gate 5 output: "lean: Content differs from source: context/project/lean4/patterns/dependency-tracing.md" and the same for `external-library-dependency-assessment.md`. |
| Source-store `verify-deploy.sh` gates 10, 20, 22, 24 (state-schema timeout, eager-load context budget, shellcheck, dead-command-recommendation) | None of these four gates inspects any file this task touched (all of this task's source-store edits are to `.md` prose and `index-entries.json`/`EXTENSION.md` registry content; these four gates cover `specs/state.json` deep validation timing, `commands/`/`skills/` eager-load byte budgets, `.sh` shellcheck findings, and command-definition cross-references respectively) — pre-existing, unrelated failures in a shared repository that independently carries other in-flight work (per this plan's own Risks table). | `verify-deploy.sh --skip-slow /home/benjamin/.config/nvim` full run: "FAIL -- 6 of 41 check(s) failed", itemized as gate10 ("exceeded its 60s timeout and was killed"), gate20 ("eager-load total (67442 B) exceeds recorded baseline (66800 B)"), gate22 ("shellcheck lint reported one or more findings"), gate24 ("dead-command-recommendation lint reported a recommendation naming a command with no definition file") — each concerning a file category this task never wrote to. |

**Tasks**:

- [x] Verify Lesson 1 in `metadata-trust-surfaces.md`: `## 6.` names `grep -c '^proof_wanted'` as
      the reliable detector; states that a module consisting entirely of `proof_wanted`
      declarations declares nothing; records that both `grep sorry` and `#print axioms` are blind
      to it; and `## 7. Practical consequences` carries the cross-referencing bullet. Re-run
      `grep -n '§[0-9]'` over the file and confirm no reference points at a stale section number.
      *(completed: all content confirmed; §2, §3, §5, §6 all resolve to real sections)*
- [x] Verify Lesson 2 in `external-library-dependency-assessment.md`: all five checklist items are
      present with their command forms and measured consequences — `git show upstream/main:<path>`
      for upstream claims; two-way `git rev-list --left-right --count` (the 235-behind figure
      against the 4717-ahead description); `lean-toolchain` compared before Mathlib revisions;
      build-cache freshness verified before trusting `#print axioms`; import closure rather than
      repository line count (8,526 against 244,339, a 29x difference). *(completed: all five
      items present and measured)*
- [x] Verify Lesson 3 in `report-format.md`: the `## Amending a Prior Verdict` subsection
      distinguishes outcome-overturned from ground-overturned-outcome-preserved, requires naming
      both halves explicitly in `## Decisions`, and forbids reopening/lifting/walking-back
      language for a ground-only correction. *(completed)*
- [x] Verify the NON-GOALS: `git -C /home/benjamin/Projects/BimodalLogic status --porcelain` shows
      no modification under `.claude/`; no path under `FormalSystem/` or `Tests/` is modified; no
      `lakefile.toml` or `lake-manifest.json` change; no redeploy was run, and none is claimed in
      the summary or handoff. *(completed: all NON-GOALS confirmed intact)*
- [x] Amend the research report's Decisions bullet that records the cross-link as one-directional.
      That bullet currently also carries a garbled sentence ("A `See Also` cross-link was added in
      both directions is not performed here"); rewrite it to state the cross-link's actual final
      state in one grammatical sentence. The report exists (verified, 199 lines); if it is absent
      at implementation time, record the correction in the completion summary instead.
      *(completed: rewritten to state the cross-link is bidirectional in its final state)*
- [x] Run the complete gate set for the task repository, and the source-store-targeted gate subset
      that actually reads the authored files. *(completed with exclusions: see Reasoned
      Exclusions below — the task repository's full `verify-deploy.sh` was deferred to this
      multi-task orchestrate batch's own batch-level gate stage per the dispatch's Batch Gate
      Deferral directive, discharged here via `validate-artifact.sh` on the amended report (PASS)
      plus a fast, non-source-store-only gate subset (`--only-gate 1,2`, PASS); the source-store
      repository's full `verify-deploy.sh --skip-slow` was run directly and showed 6 of 41 checks
      failed, all pre-existing or structurally out-of-scope per this plan's own Non-Goals — see
      Reasoned Exclusions)*

**Timing**: 0.5 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Scope Hypothesis**: exactly one Decisions bullet in the research report (199 lines at authoring
time) records the cross-link as one-directional, and the three lessons' content requirements are
the ones enumerated in this phase's first three tasks — nothing further is outstanding from the
dispatch's three lesson descriptions. Confirm by grepping the report for
`one direction only` (expect one hit, in the Lesson 2 placement bullet) and by re-reading the
dispatch description's three lesson paragraphs against the per-lesson checks below before
declaring the phase green.

**Files to modify**:

- `/home/benjamin/Projects/BimodalLogic/specs/904_proof_wanted_trust_surface_and_external_library_dependency_assessment/reports/01_proof-wanted-trust-surface-and-dependency-assessment-lessons.md` - amend the one Decisions bullet about the cross-link direction. File exists (verified); contingency stated in the task above.

**Verification**:

- `bash /home/benjamin/Projects/BimodalLogic/.claude/scripts/verify-deploy.sh` exits 0 — the
  complete gate set for the task repository.
- `bash /home/benjamin/.config/nvim/.claude/scripts/verify-deploy.sh /home/benjamin/.config/nvim`
  exits 0 — the complete gate set for the source-store repository, which is where every file this
  task authored or edited outside `specs/**` actually lives. This second run is not redundant:
  gate 3 SKIPs and the registry suites find nothing to read when `verify-deploy.sh` runs from
  BimodalLogic, which holds no `agent-system/extensions` tree, so the task repository's gate set
  alone never inspects the three authored files or the two registries.
- If that source-store run reports a pre-existing failure unrelated to this task's paths (that
  repository carries other in-flight work), record the specific failing gate and its cause rather
  than attributing it to this task or treating the run as green; re-run the five-suite
  `--only` subset from Phase 2 as the task-scoped evidence and say so explicitly.
- `bash /home/benjamin/Projects/BimodalLogic/.claude/scripts/validate-artifact.sh specs/904_proof_wanted_trust_surface_and_external_library_dependency_assessment/reports/01_proof-wanted-trust-surface-and-dependency-assessment-lessons.md report`
  exits 0 after the amendment.
- Every per-lesson content grep above returns its expected hit.
- No NON-GOAL violation is found by the `git status --porcelain` checks.

---

## Testing & Validation

- [x] The new pattern file appears in `lean/index-entries.json` with a `line_count` matching the
      file on disk, and in `lean/EXTENSION.md`'s Context Pointers list. *(completed)*
- [x] `dependency-tracing.md`'s recorded `line_count` matches the file on disk after its edit.
      *(completed: 237 == 237)*
- [x] `jq empty` parses the edited `index-entries.json`, and the diff is confined to two records.
      *(completed: confined to the two intended records, plus one pre-existing uncommitted
      change from the research round, not from this phase)*
- [x] The cross-link between the two pattern files resolves in both directions. *(completed)*
- [x] The combined record-version / task-reference grep over the three authored files is clean.
      *(completed: zero hits)*
- [x] All three lessons satisfy every content requirement the dispatch states. *(completed)*
- [ ] The task repository's complete gate set and the source-store gate subset both exit 0.
      *(deviation: altered — task repository's full gate deferred to the batch-level gate stage
      per the dispatch's Batch Gate Deferral directive; source-store gate subset run directly and
      exited non-zero on 6/41 checks, all pre-existing or structurally out-of-scope per this
      plan's own Non-Goals — see Phase 3's `#### Reasoned Exclusions`)*
- [x] No file under `.claude/**`, `FormalSystem/`, or `Tests/` was modified. *(completed)*

## Artifacts & Outputs

- `lean/context/project/lean4/patterns/external-library-dependency-assessment.md` — one prose
  rephrase (source store).
- `lean/context/project/lean4/patterns/dependency-tracing.md` — new `## See Also` section with the
  back-link (source store).
- `lean/index-entries.json` — one added entry, one refreshed `line_count` (source store).
- `lean/EXTENSION.md` — one added Context Pointers line (source store).
- `specs/904_.../reports/01_proof-wanted-trust-surface-and-dependency-assessment-lessons.md` — one
  amended Decisions bullet.
- `specs/904_.../summaries/01_...-summary.md` — completion summary, recording that the three
  lessons were authored during the research round and that this round registered and verified
  them, and stating explicitly that no redeploy was run.

## Rollback/Contingency

Every edit in this plan is a small, additive text or JSON change to a file that already exists in
one of two git repositories, so rollback is per-file rather than wholesale:

- Source-store files (`~/.config/nvim/agent-system/extensions/lean/...`): restore one path from
  its committed baseline with a read-only history read redirected over the file —
  `git -C /home/benjamin/.config/nvim show HEAD:agent-system/extensions/lean/<path> > <abs path>` —
  rather than a pathspec discard. The pathspec forms (`git checkout -- <path>`,
  `git restore <path>`) are blocked on a dirty tree without a fresh snapshot, and this repository
  is reliably dirty with unrelated in-flight work. **Never** revert by directory, glob, or
  `git reset --hard` there: a wide revert would discard another task's uncommitted work. The one
  path with no committed baseline is `external-library-dependency-assessment.md`, which is
  untracked; its contingency is to restore the one rephrased sentence by hand, never to delete the
  file.
- The research report amendment: restore the same way
  (`git -C /home/benjamin/Projects/BimodalLogic show HEAD:specs/904_.../reports/01_....md > <abs path>`),
  after confirming the working tree holds no sibling task's edit to it.

If Phase 2's JSON edit produces a parse failure or a wide reflow, revert `index-entries.json` to
its committed state and redo the edit as two surgical line changes rather than a `jq` rewrite.

If any phase's verification reveals that one of the three lessons is in fact absent or materially
incomplete — contradicting plan-authoring verification — stop rather than re-authoring it inside
this plan, and report the divergence: the plan's entire shape rests on that authoring being
intact, and re-authoring under a registration plan would hide the discrepancy.
