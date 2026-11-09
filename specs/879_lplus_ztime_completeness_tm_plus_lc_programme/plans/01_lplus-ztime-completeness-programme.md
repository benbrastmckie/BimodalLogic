# Implementation Plan: Task #879

- **Task**: 879 - Own the L-plus ZTime completeness programme for TM-plus with the limit-closure schema
- **Status**: [NOT STARTED]
- **Effort**: 2.75 hours
- **Dependencies**: 870 (`[COMPLETED]`), 871 (`[COMPLETED]`), 867 (`[COMPLETED]`)
- **Research Inputs**: `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md`
- **Artifacts**: plans/01_lplus-ztime-completeness-programme.md (this file)
- **Standards**:
  - `.claude/context/formats/plan-format.md`
  - `.claude/context/standards/status-markers.md`
  - `.claude/rules/artifact-formats.md` (artifact-management)
  - `.claude/rules/state-management.md` (tasks)
  - `.claude/docs/reference/standards/multi-task-creation-standard.md`
  - `.claude/context/patterns/backlog-reconciliation.md`
- **Type**: formal
- **Lean Intent**: false

## Overview

The task's four deliverables — the target theorem as stated `Prop`s (T1/T2/T3, elaborated in
`probes/01_target-statements.lean`), the end-to-end architecture, the 21-row ingredient table,
and the go/no-go verdict — are already discharged by the research report, which is the whole of
this task's substantive output. What remains is the close-out the task description itself
mandates and the research agent could not perform for want of a task-creation surface: file each
of the nine missing ingredients as its own task through the backlog audit (deliverable 3's second
sentence), with the dependency edges the report names; amend the two `specs/ROADMAP.md` sentences
the report corrects (its Recommendation 5 and the stale `(H5)` ownership line); and close with a
summary and the full gate. Definition of done: nine new `not_started` tasks exist in
`specs/state.json` with declared `file_scope`, audited and non-duplicate, chained P2→P3→P4 and
P1→P9; `specs/ROADMAP.md` no longer names `LC_n` plus progress measures as the cure of record nor
870 as the owner of the universal-cover construction; nothing under `FormalSystem/` or `Tests/`
has changed; no completeness claim lands.

### Research Integration

The report is integrated as a set of dispositions, not re-derived:

- **Verdict (finding 4)**: GO on T3 (TM⁺ + `LCU` + mirror + clock + two AA rules) as a staged
  paper programme with cheap Lean ingredients landing now; NO-GO on T1 as stated (reduced, not
  refuted, to Q1/Q2); NO-GO on a Lean proof of any of T1–T3 today (determinization obstruction,
  aligned with the standing MSO refusal). Nothing in this plan reopens any part of the verdict.
- **Nine proposals (finding 3, `task-proposals.json`)**: P1 `lcu_until_form_schema_ztime_validity`,
  P2 `cone_unravelling_frame_layer_split_saturation`, P3 `auxiliary_atoms_rule_soundness_ztime`,
  P4 `lplus_extended_proof_system_and_target_statement`, P5
  `universal_cover_oriented_forest_two_way_bounded`, P6 `plus_invariance_base_without_saturation`,
  P7 `stability_cluster_type_product_lemma`, P8 `linear_ztime_validity_tm_plus_substitution_bridge`
  (all `lean4`), P9 `two_sided_reynolds_engine_paper_proof` (`formal`, research). Each was audited
  by `audit-task-proposals.sh` in the research dispatch (`task-proposals-audit.ndjson`) and every
  `duplicate-of-open`/`covered-by-closed` verdict was dismissed on inspection in the report's
  Backlog audit paragraph. Filed in Phase 2 with the report's suggested edges: P3 ← P2, P4 ← P3,
  P9 ← P1; P5–P8 independent.
- **Correction of record (finding 2.3, Recommendation 5)**: the schema the Reynolds engine
  consumes is the until-form `LCU` and its mirror, not the F-form `LC_n`; the "progress measure"
  is Reynolds' banned list, not an independent device. `specs/ROADMAP.md`'s sentence "The cure of
  record is `LC_n` plus progress measures in the state" is amended in Phase 3. The report's second
  cheap amendment — `PlusLCSchema.lean`'s `LCU` docstring citing P1 — is under `FormalSystem/`,
  conditional on P1 landing, and is therefore P1's to make, not this task's.
- **Not done here, by the report's own recommendation 6**: no Lean formalization of T3's
  completeness proof and no ω-automata determinization project is filed until P9 reports whether
  a progress-measure replacement exists.

### Prior Plan Reference

No prior plan for this task. The structural precedent is task 865's close-out plan
(`specs/archive/865_tm_plus_lc_axiomatization_and_automaton_obstruction/plans/01_lc-axiomatization-automaton-obstruction.md`),
whose three lessons are carried: (i) `state-write.sh --audit-verdict` cannot take the full audit
NDJSON (each line here is 139–185 KB, over Linux's 128 KB per-argv ceiling) and needs a condensed
evidence file; (ii) autonomous filing is pre-authorized by the task description's own "file each
missing ingredient as its own implementation task" and the Component 7 table is rendered into the
summary as the record; (iii) all state mutation goes through `state-write.sh` under the mutex.

### Roadmap Alignment

No `roadmap_path` and no `roadmap_flag` were supplied in this dispatch, so `specs/ROADMAP.md` was
not loaded as planning input in the roadmap-phase sense and this plan carries no
review/snapshot/update roadmap phases. `specs/ROADMAP.md` IS a correction target of Phase 3 on
the report's explicit Recommendation 5 — a sentence-level amendment of its hand-authored body,
not a roadmap sync (which remains `/todo`'s and `roadmap-integration.sh`'s job).

## Goals & Non-Goals

**Goals**:
- File the nine audited ingredient proposals as `not_started` tasks via `state-write.sh
  --allocate-into`, each carrying `task_type`, `file_scope`, and the report's dependency edges
  (P3 ← P2, P4 ← P3, P9 ← P1), with audit evidence recorded on each entry.
- Add the one substantive-overlap serialization edge the audit surfaced: task 869 depends on P6
  (both touch `FormalSystem/Semantics/HistoryMorphism.lean`; the report rules P6 first).
- Amend `specs/ROADMAP.md`: the "cure of record" sentence, and the `(H5)` line's stale ownership
  (870 is complete; the universal-cover half becomes P5's).
- Record, in the summary, the Component 7 confirmation table with allocated numbers, the
  dispositions of every non-`genuinely-new` verdict, and the explicit list of what is deliberately
  not filed (a Lean completeness proof; a determinization project).
- Leave `FormalSystem/` and `Tests/` byte-identical; make no completeness or decidability claim.

**Non-Goals**:
- Any library change. `PlusLCSchema.lean`'s docstring pointer to P1 is P1's own edit.
- Re-deriving, re-auditing from scratch, or re-litigating the report's verdict, architecture, or
  the nine proposals' content; the proposals are filed as audited, with the one `file_scope`
  change Phase 1 may make being a narrowing, never a widening.
- Re-running `audit-task-proposals.sh` on an unchanged proposal (the research-dispatch audit is
  the evidence of record); it is re-run only for a proposal whose `file_scope` Phase 1 changes.
- `docs/theorem-index.md` — the report confirms its "open at every frame class" sentence stands.
- `specs/CHANGE_LOG.md`, and any ROADMAP content at or after the `**Coverage appendix (uncovered
  tasks)**:` marker (generated; `roadmap-integration.sh` owns it).
- Creating a dependency edge for aggregator-only file overlaps (see Phase 2's decision gate).
- L^▷, Base, Dense, RTime.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `state-write.sh --audit-verdict` refuses the full NDJSON (per-argv size ceiling; 865 hit exit 126 at ~151 KB/line, these lines are 139–185 KB) | M | H | Phase 1 writes `task-proposals-audit-condensed.ndjson` (every non-`scope-blind` verdict verbatim, `scope-blind` collapsed to a count, `.proposal.id` preserved); the full NDJSON stays the committed evidence |
| Autonomous task creation bypasses the Multi-Task Creation Standard's foreground Component 7 confirmation | M | H | Stated assumption, as in 865: the task description's "File each missing ingredient as its own implementation task through the backlog audit" is the user's pre-authorization. Phase 2 renders the Component 7 table into its notes and the summary carries it. Any verdict other than `genuinely-new`/`scope-blind`/`overlaps-open`/`subset-of-open` is dropped or narrowed at the decision gate, never auto-filed |
| `specs/state.json`/`specs/TODO.md` are written concurrently by sibling dispatches (impl-867-c1 is live this session) | H | M | Every write goes through `state-write.sh` (flock mutex, `--allocate-into` membership-based numbering, `--regen-todo`); no hand-edit of either file; commits name files explicitly; `validate-state.sh` after the batch |
| Dependency edges between new tasks need numbers not known until allocation | M | H | File in the order P1, P2, P3, P4, P5, P6, P7, P8, P9, one `state-write.sh` call each, reading each allocated number from the script's output before writing the next entry's `dependencies`; the 869 ← P6 edge is added afterwards with `update-task-status.sh --depends-on-add` |
| An aggregator-only `overlaps-open` verdict (`docs/theorem-index.md`, `scripts/check-module-invariants.sh`, `FormalSystem.lean`) is read as requiring a blocking edge to 761 (`[HOLD]`), 763, 543, 838, 869, 873–876 | M | M | Decision gate rule (Phase 2): aggregator-only overlaps get no edge — the orchestrator's dispatch-time `file_scope` overlap admission already serializes them — and are recorded in the Backlog Check column; only a substantive `.lean` overlap (P6/869 on `HistoryMorphism.lean`) gets an edge |
| A concurrent `/todo` or `roadmap-integration.sh` run regenerates `specs/ROADMAP.md` between Phase 3's read and write | M | L | Re-read the two target sentences immediately before editing (`grep -n` for each), edit only the hand-authored body above the coverage-appendix marker, and re-grep after the write |
| The ROADMAP amendment is read as a completeness claim or as refuting T1 | M | L | The amendment names `LCU` as the schema of record, records `LC_n`'s role as open (Q1), and adds no positive claim; the report states three times that T1 is unreached, not refuted |
| The filed P9 (research, `formal`) is mistaken for a Lean task and dispatched to a Lean agent | L | L | `task_type: "formal"`, `file_scope: []`, and a description opening "RESEARCH TASK, report only" |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel (this plan is fully sequential: Phase 2 needs
Phase 1's evidence file, Phase 3 needs Phase 2's allocated numbers, Phase 4 closes everything).

### Phase 1: Dispositions and Condensed Audit Evidence [NOT STARTED]

**Goal**: A written disposition for each of the nine proposals and a `state-write.sh`-sized audit
evidence file, so Phase 2 can file without re-deciding anything.

**Tasks**:
- [ ] Re-read `task-proposals.json` and `task-proposals-audit.ndjson`; confirm the nine `id`s
  above are present in both, in order, and that every `.proposal.id` equals the `project_name`
  Phase 2 will write (the `id` string verbatim).
- [ ] Classify each proposal's open-side verdicts (`overlaps-open`, `subset-of-open`,
  `duplicate-of-open`) and every `covered-by-closed` at semantic score ≥ 0.55, writing the
  disposition into the Phase 1 notes of this plan (one line per proposal): `genuinely-new`;
  `aggregator-only overlap, no edge` (shared paths ⊆ {`docs/theorem-index.md`,
  `scripts/check-module-invariants.sh`, `FormalSystem.lean`, `FormalSystem/Semantics.lean`,
  `FormalSystem/Metalogic.lean`, `Tests/BimodalTest.lean`}); `substantive overlap, edge` (any
  other shared `.lean` path — at plan time only P6/869 on `FormalSystem/Semantics/HistoryMorphism.lean`);
  or `drop/narrow` (a `duplicate-of-open`/`covered-by-closed` that survives inspection — at plan
  time none does: 430 is the base-language tableau lift, 706/718/719/443/468 are reports and
  refactors; the report's Backlog audit paragraph already records these dismissals and they are
  re-confirmed here by reading the named records' titles, not re-derived).
- [ ] Write `task-proposals-audit-condensed.ndjson`: for each line of the full NDJSON, keep
  `.proposal` verbatim and `.verdicts` filtered to every non-`scope-blind` verdict verbatim, plus
  one synthetic field `scope_blind_count` (the number of `scope-blind` verdicts collapsed), via
  `jq -c '{proposal, verdicts: [.verdicts[] | select(.verdict == "scope-blind" | not)], scope_blind_count: ([.verdicts[] | select(.verdict == "scope-blind")] | length)}'`
  (note the `| not` form, never `!=` — see `.claude/CLAUDE.md`'s jq safety section). Confirm every
  line is under 100 KB (`awk '{print length($0)}'`).
- [ ] Record an issue-log entry (`issue-record.sh --kind issue --class tooling --severity minor`)
  if any proposal's disposition is other than `genuinely-new` or `aggregator-only overlap`, naming
  the proposal and the record it collided with; otherwise record a `win` attesting the clean pass.
- [ ] Commit the condensed file by explicit path (`git-commit-scoped.sh ... -- <path>`).

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for `task-proposals-audit-condensed.ndjson`, and the path lies entirely under `specs/**` (sub-case (a)) and is not a report/plan/summary artifact, so the covering check is `jq -e . <each line>` of the condensed file together with the `prose` row's diff read-through confirming only that one new data file and this plan's Phase 1 notes changed.

**Scope Hypothesis**: exactly one new file is written and exactly nine proposals are classified; at plan time the open-side verdicts are: P1 — `overlaps-open` 763, 761, 869 (`docs/theorem-index.md`, `scripts/check-module-invariants.sh`), 873–876 (`docs/theorem-index.md`); P2, P4, P5 — additionally `FormalSystem.lean` against 763, 761, 543, 838; P3, P7, P8 — `docs/theorem-index.md` only; P6 — `subset-of-open` 869 on `FormalSystem/Semantics/HistoryMorphism.lean` + `docs/theorem-index.md`; P6, P7, P8 — `duplicate-of-open` 430 (semantic only, 0.40–0.45); P9 — none. `scope-blind` counts 450–453 per proposal (carried from `task-proposals-audit.ndjson`, read at plan time). Confirm at implementation time by the jq extraction in the second task; if a verdict set differs (a sibling task filed since), re-classify that proposal rather than copying this list.

**Files to modify**:
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/task-proposals-audit-condensed.ndjson` - new; the `state-write.sh`-sized evidence file, one line per proposal, `.proposal.id` preserved
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/plans/01_lplus-ztime-completeness-programme.md` - Phase 1 notes: the nine dispositions

**Verification**:
- The condensed file has exactly nine lines, each parsing under `jq -e .`, each with a `.proposal.id` equal to one of the nine proposal ids and a `verdicts` array containing no `scope-blind` entry.
- Every line is under 100 KB.
- Each proposal has a written disposition before Phase 2 starts.

---

### Phase 2: File the Nine Ingredient Tasks [NOT STARTED]

**Goal**: Nine new `not_started` tasks exist in `specs/state.json` with declared `file_scope`,
audit evidence on each entry, the report's dependency edges, and the one serialization edge; `TODO.md`
renders them.

**Tasks**:
- [ ] Decision gate: for each proposal, proceed on `genuinely-new` or `aggregator-only overlap`
  (no edge); for `substantive overlap, edge` proceed and add the edge in the step below; for
  `drop/narrow` do not file unchanged — narrow `file_scope` and re-run
  `bash .claude/scripts/audit-task-proposals.sh --proposals-file <one-element file>` with the
  same `id`, or drop and record the reason in the Phase 2 notes.
- [ ] Record the pre-filing baseline: `jq '.active_projects | length' specs/state.json` and
  `jq '.next_project_number' specs/state.json` (893 at plan time; `--allocate-into` derives from
  membership, so read allocated numbers from the script's output, never from this cache).
- [ ] File in order P1, P2, P3, P4, P5, P6, P7, P8, P9, one call each:
  `bash .claude/scripts/state-write.sh '.active_projects += [{project_number: $n, project_name: "<id>", status: "not_started", task_type: "<lean4|formal>", title: "<title>", description: "<description>", file_scope: <file_scope>, dependencies: <deps>, priority: "medium", created: $now, last_updated: $now, next_artifact_number: 1}]' --session-id "$session_id" --allocate-into n --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --audit-verdict specs/879_lplus_ztime_completeness_tm_plus_lc_programme/task-proposals-audit-condensed.ndjson --regen-todo`
  — appending with `+=` only (never a wholesale `.active_projects = [...]`), `title`/`description`/
  `file_scope` copied verbatim from `task-proposals.json`, `task_type` `lean4` for P1–P8 and
  `formal` for P9, and `dependencies` set from the numbers already allocated: P3 → [P2's number],
  P4 → [P3's number], P9 → [P1's number], all others `[]`. Read the allocated number from each
  call's output before the next call.
- [ ] Add the serialization edge: `bash .claude/scripts/update-task-status.sh preflight 869 not_started "$session_id" --depends-on-add='[<P6 number>]'`
  (or the equivalent no-status-change operation the script's usage names), so 869 runs after
  P6 on their shared `HistoryMorphism.lean`; confirm with `jq '.active_projects[] | select(.project_number==869) | .dependencies'`.
- [ ] Verify each new entry: `project_name` equals its proposal `id`; `audit_verdict` is present
  (the gate recorded it); `file_scope` is non-empty for P1–P8 and `[]` for P9; `dependencies`
  match the edge list.
- [ ] Render the Component 7 confirmation table (number, title, task type, effort from the
  report's ingredient table, dependencies, backlog check with `scope-blind` as a count) into the
  Phase 2 notes of this plan; no interactive prompt is issued (see Risks).
- [ ] Run `bash .claude/scripts/validate-state.sh` and read its output in full; exit 0 required.
- [ ] After `git status --short` confirms no sibling's uncommitted hunks are mixed in, commit
  `specs/state.json`, `specs/TODO.md`, and this plan by explicit path.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: the edit is confined to `specs/state.json` plus the `TODO.md` view generated from it (and this plan's notes), and `bash .claude/scripts/validate-state.sh` is the whole-file consistency lint for exactly that pair, including the Check 12 allocation invariant `--allocate-into` writes against; no suite subset is claimed.

**Scope Hypothesis**: exactly nine new `active_projects` entries are added, `next_project_number` advances to the next free number past them, one existing entry (869) gains one dependency, and no other entry changes. Confirm by diffing `jq '.active_projects | length'` before and after (+9), by `jq '[.active_projects[] | select(.status=="not_started" and (.project_name | IN("lcu_until_form_schema_ztime_validity","cone_unravelling_frame_layer_split_saturation","auxiliary_atoms_rule_soundness_ztime","lplus_extended_proof_system_and_target_statement","universal_cover_oriented_forest_two_way_bounded","plus_invariance_base_without_saturation","stability_cluster_type_product_lemma","linear_ztime_validity_tm_plus_substitution_bridge","two_sided_reynolds_engine_paper_proof")))] | length'` = 9, and by `validate-state.sh` exiting 0. If the decision gate drops a proposal, the count is lower and the Phase 2 notes say which and why.

**Files to modify**:
- `specs/state.json` - append nine `active_projects` entries via `state-write.sh` under the mutex; add one dependency to entry 869
- `specs/TODO.md` - regenerated by `--regen-todo`; never hand-edited
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/plans/01_lplus-ztime-completeness-programme.md` - Phase 2 notes: the Component 7 confirmation table with allocated numbers

**Verification**:
- `bash .claude/scripts/validate-state.sh` exits 0.
- Nine new entries, each with `project_name` = proposal `id`, an `audit_verdict` field, and the declared `file_scope`; P3/P4/P9 carry their edges; 869 depends on P6's number.
- `specs/TODO.md` renders each new task with bracket-only artifact-link format and no `[name](path)` links.
- `git diff --staged --name-only` names only `specs/state.json`, `specs/TODO.md`, and this plan.
- `git status --short -- FormalSystem/ Tests/` is empty.

---

### Phase 3: Amend the ROADMAP Record [NOT STARTED]

**Goal**: `specs/ROADMAP.md`'s hand-authored body states the corrected cure of record and the
current ownership of the universal-cover construction, with the new task numbers, and nothing
else in the file changes.

**Tasks**:
- [ ] Re-read immediately before editing: `grep -n "The cure of record is" specs/ROADMAP.md`
  (one hit expected, in "## Cross-stage sequencing", at line 353 at plan time),
  `grep -n "universal-cover construction" specs/ROADMAP.md` (one hit expected, the `(H5)` line at
  124 at plan time), and `grep -n "R3, the doubled AA" specs/ROADMAP.md` (one hit, line 355 at plan
  time). If any count differs, re-locate by content rather than editing blind; if a sentence is
  gone, record that in the Phase 3 notes and skip it.
- [ ] Replace the sentence "The cure of record is `LC_n` plus progress measures in the state."
  with: "The cure of record is the until-form `LCU` and its mirror plus the Reynolds automaton-
  and-ban machinery (Reynolds 2001 §11–§13), per 879's report finding 2.3; `LC_n`'s role in a
  language with `untl`/`snce` primitive is open (879's Q1, owned by <P9 number>)." Keep the
  preceding sentences of that bullet byte-identical.
- [ ] In the `(H5)` line, replace "task 870's oriented-forest Saturation lemma and universal-cover
  construction, `[NOT STARTED]`" with "870's oriented-forest Saturation lemma (`[COMPLETED]`,
  `saturation_of_orientedForest`) and the universal-cover construction (<P5 number>,
  `[NOT STARTED]`)". Nothing else in that bullet changes.
- [ ] In the "R3, the doubled AA⊡ rule" bullet, append one sentence after "which files it if its
  ingredient table calls for it.": "Filed: <P2 number> (the cone carrier) and <P3 number> (the
  formula-level rule, gated on <P2 number>)." Leave the rest of the bullet byte-identical.
- [ ] Confirm nothing at or after the `**Coverage appendix (uncovered tasks)**:` marker changed
  (`git diff -U0 specs/ROADMAP.md` shows hunks only above line 170 at plan time) and that the
  three edits are the only hunks.
- [ ] Commit `specs/ROADMAP.md` by explicit path.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select specs/ROADMAP.md` returns `test-engine-written-state-paths-lib.sh,test-roadmap-generation.sh`, so the covering check is `bash .claude/scripts/tests/run-all.sh --only test-engine-written-state-paths-lib.sh,test-roadmap-generation.sh` (exit status read, confirming the generator still round-trips the body) together with the `prose` row's diff read-through confirming every hunk is one of the three sentence edits above.

**Scope Hypothesis**: exactly three hunks in one file, all in the hand-authored body above the coverage-appendix marker, each replacing or extending a single sentence located at plan time by the three greps in the first task; `specs/ROADMAP.md` is 418 lines with the marker at line 170 at plan time (carried from a plan-time `wc -l`/`grep -n`, re-measure before editing).

**Files to modify**:
- `specs/ROADMAP.md` - three sentence-level amendments in the hand-authored body: the "cure of record" sentence, the `(H5)` ownership clause, and the R3 filing note; confirmed present at plan time at lines 353, 124 and 355; if a target sentence is absent at implementation time, skip that edit and record it in the Phase 3 notes rather than inventing a location

**Verification**:
- Each of the three greps above matches exactly once after the edit (the amended sentences still contain their anchor text).
- `git diff -U0 -- specs/ROADMAP.md` shows exactly three hunks, none at or after the coverage-appendix marker.
- `bash .claude/scripts/tests/run-all.sh --only test-engine-written-state-paths-lib.sh,test-roadmap-generation.sh` exits 0.
- The amended text makes no completeness claim and does not describe T1 as refuted.

---

### Phase 4: Summary and Final Gate [NOT STARTED]

**Goal**: The task's close-out record exists, states what was filed and what was deliberately not,
and the repository passes its full gate set with `FormalSystem/` and `Tests/` untouched.

**Tasks**:
- [ ] Write `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/summaries/01_lplus-ztime-completeness-programme-summary.md`
  per `summary-format.md` (all six required headings verbatim), covering: the report's verdict in
  three sentences (GO on T3 as a staged paper programme; T1 reduced to Q1/Q2, not refuted; no Lean
  proof today, obstruction = determinization); the exact point separation is consumed (one
  sentence, finding 2.4); the Component 7 table with allocated numbers and the dependency edges;
  the ROADMAP amendments; the dispositions of every non-`genuinely-new` verdict; and an explicit
  paragraph recording that a Lean completeness proof and any ω-automata determinization project
  are deliberately not filed pending P9's progress-measure question, so neither reads as an
  oversight. Link the report and `probes/01_target-statements.lean` under `## References`.
- [ ] Confirm no library change: `git status --short -- FormalSystem/ Tests/` is empty and
  `git diff --stat HEAD~N -- FormalSystem/ Tests/` over this task's commits is empty.
- [ ] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh`. Read the output; do not
  infer a pass. If this dispatch carries a `## Batch Gate Deferral` directive, follow it and record
  the deferral in the summary's Verification section instead.
- [ ] Record a closing issue-log entry (win or issue) for this phase, or attest in the summary that
  nothing arose.
- [ ] Write `.orchestrator-handoff.json` and `.return-meta.json` (`status: "implemented"`,
  `dispatch_seq` echoed), and commit the summary by explicit path.

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: one new summary file is written and no file under `FormalSystem/` or `Tests/` is modified by any phase of this plan. Confirm by the two `git` checks above, read before the gate run.

**Files to modify**:
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/summaries/01_lplus-ztime-completeness-programme-summary.md` - new; the close-out record

**Verification**:
- `bash .claude/scripts/validate-artifact.sh specs/879_lplus_ztime_completeness_tm_plus_lc_programme/summaries/01_lplus-ztime-completeness-programme-summary.md summary` exits 0.
- `bash .claude/scripts/verify-deploy.sh` runs to completion and is observed green (the complete gate set, not a `--only-gate` subset and not `--skip-slow`), or the batch-deferral is recorded per the directive.
- `git status --short -- FormalSystem/ Tests/` is empty.
- `.orchestrator-handoff.json` validates (the write-time `validate-handoff-location.sh` gate accepts it) and `.return-meta.json` carries `status: "implemented"` with `dispatch_seq` echoed.

---

## Testing & Validation

- [ ] Condensed audit file: nine lines, each `jq -e .`-valid, no `scope-blind` verdicts, every line under 100 KB.
- [ ] `bash .claude/scripts/validate-state.sh` exits 0 after the filings.
- [ ] Nine new entries with `project_name` = proposal `id`, `audit_verdict` present, edges P3←P2, P4←P3, P9←P1, and 869←P6.
- [ ] `grep -c` anchors on `specs/ROADMAP.md` match once each after the amendment; no hunk at or after the coverage-appendix marker.
- [ ] `bash .claude/scripts/tests/run-all.sh --only test-engine-written-state-paths-lib.sh,test-roadmap-generation.sh` exits 0.
- [ ] `bash .claude/scripts/validate-artifact.sh <summary-path> summary` exits 0.
- [ ] `bash .claude/scripts/verify-deploy.sh` observed green in the dispatch that closes Phase 4 (or batch-deferred per directive).
- [ ] `git status --short -- FormalSystem/ Tests/` empty at every phase boundary.
- [ ] No commit stages a directory or glob pathspec; every commit names files explicitly.

## Artifacts & Outputs

- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/plans/01_lplus-ztime-completeness-programme.md` (this plan, with Phase 1 dispositions and the Phase 2 Component 7 table in its notes)
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/task-proposals-audit-condensed.ndjson`
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/summaries/01_lplus-ztime-completeness-programme-summary.md`
- Nine new `not_started` entries in `specs/state.json` (P1–P8 `lean4`, P9 `formal`), rendered into `specs/TODO.md`; one new dependency on entry 869
- Amended `specs/ROADMAP.md` (three sentences)
- Pre-existing, unchanged: `reports/01_lplus-ztime-completeness-programme.md`, `probes/01_target-statements.lean`, `task-proposals.json`, `task-proposals-audit.ndjson`

## Rollback/Contingency

Every phase is a single-file or single-script change with its own commit, so reverting is a
targeted `git revert` of that commit — no working-tree discard is needed and none is planned.

- **Phase 1**: the condensed file is evidence only, consumed by Phase 2's `--audit-verdict`;
  delete it or revert the commit.
- **Phase 2**: the hazard is a wrongly-filed task, not a corrupted file. Remedy forward rather
  than by reverting a shared file that siblings also write this cycle: mark the entry `abandoned`
  via `bash .claude/scripts/update-task-status.sh`, which keeps `state.json`'s append-only
  discipline intact; remove a wrong edge with the script's dependency operations, never by hand.
  Do **not** hand-edit `state.json` or `TODO.md`, and do not `git revert` a `state.json` commit a
  sibling has since extended.
- **Phase 3**: revert the ROADMAP commit; the three edits replace sentences in place, so the
  revert restores the prior wording exactly.
- **Phase 4**: revert the summary commit.

If a rollback that would discard uncommitted work ever becomes genuinely necessary, follow
`.claude/context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation
shape; this plan emits no precautionary snapshot step, and no phase needs one.
