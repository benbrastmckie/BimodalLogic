# Implementation Plan: Task #392

- **Task**: 392 - correct_kamp_dedekind_task_charters
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/392_correct_kamp_dedekind_task_charters/reports/01_charter-corrections.md
- **Binding Decision**: specs/392_correct_kamp_dedekind_task_charters/DECISION.md
- **Artifacts**: plans/01_charter-corrections.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Apply two corrections to task metadata in `specs/state.json`, then regenerate `specs/TODO.md`.
CORRECTION 1 replaces task 378's `description` with the value-inverted charter drafted in the
research report's Part A, preserving every binding constraint. CORRECTION 2 sets task 383's status
to `abandoned` with the drafted `completion_summary`, per the user's binding decision. This task
touches `specs/` only: no `.lean` file, no `Theories/` file, no deliverable doc is modified, and
no build is run. Definition of done: `specs/state.json` is valid JSON, 378 carries the new
description with all binding constraints intact, 383 is `abandoned` with a completion summary, and
`TODO.md` is regenerated from state.

### Research Integration

The plan implements the research report's Part A (drafted 378 description) and Part B **primary
recommendation** (abandon 383). Three findings from the report drive plan detail:

- The 378 replacement text intentionally preserves four binding constraints verbatim while adding
  a bracketed staleness note — so verification must distinguish "preserved constraint sentence"
  from "newly added bracketed annotation".
- The research confirmed `KampPrior.lean:520`, `EANegation.lean:1090` and `:1249` no longer hold
  live sorries. The constraint text naming them is preserved anyway, by explicit instruction.
- The report's Part B *fallback* (keep 383 open with RECONCILE-scoped text) is superseded by
  DECISION.md and is **not** implemented.

### Prior Plan Reference

No prior plan.

### Binding Decision Integration

`DECISION.md` (2026-07-26) overrides the original charter's CORRECTION 2. Task 383 is marked
ABANDONED; **no** unblock sub-task is created and **no** dependency is wired into 383. Any
instruction elsewhere to run `/spawn 383` is void.

### Roadmap Alignment

No `specs/ROADMAP.md` consulted for this task; `roadmap_flag` not set.

## Goals & Non-Goals

**Goals**:
- Replace task 378's `description` in `specs/state.json` with the research report's Part A text,
  reflowed to the file's existing one-line-per-paragraph convention.
- Preserve, provably, every binding constraint in 378's charter: the three-strikes prohibition on
  `EANegation.lean:1090`/`:1249`, the amended sorry gate, the extended non-vacuity rule, the
  PDF-page-only Rabinovich citation rule, the PRESERVE and LIVENESS rules, the pointer to
  `specs/377_transcribe_rabinovich_faithful_nf_encoding/plans/02_section5-exists-carrier-rebase.md`,
  the Phase-6-largely-done / re-scope-to-7-8 note, and the added bracketed staleness note.
- Set task 383 `status` to `abandoned` with the drafted `completion_summary`, mirroring the field
  shape used for the already-archived abandoned siblings 376 and 358.
- Regenerate `specs/TODO.md` from `specs/state.json`.

**Non-Goals**:
- Creating any sub-task, or wiring any dependency into or out of 383 (explicitly forbidden by
  DECISION.md).
- Re-litigating or rewording task 378's AMENDED SORRY GATE beyond appending the bracketed
  staleness note already drafted. Fixing the gate's stale anchors is a separate follow-up.
- Editing `specs/377_.../plans/02_section5-exists-carrier-rebase.md` phase markers (the research
  flagged this staleness as out of scope).
- Any `Theories/` edit, `lake build`, or sorry-census run. This task changes no Lean source.
- Archiving 383 (that is `/todo`'s job on a later run).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Multi-line description injected via shell quoting corrupts `state.json` | H | M | Write the new description to a scratch file, inject with `jq --rawfile`, write to a temp file, validate with `jq empty`, and only then `mv` over `state.json`. Never edit `state.json` in place with a text editor. |
| Drafted text copied with the report's ~95-col hard wrapping, breaking TODO.md paragraph rendering | M | H | Phase 2 explicitly unwraps hard-wrapped lines back to one line per paragraph before injection, and verifies the resulting description has no line shorter than the paragraph it belongs to. |
| A binding constraint is silently dropped or reworded during transcription | H | M | Phase 1 extracts each constraint from the *live* pre-edit description into a scratch anchor file; Phase 4 re-checks every anchor against the post-edit description under whitespace normalization, and the phase fails if any anchor is missing. |
| Two informational blocks present today (the census `--cross-check` MISMATCH explanation and the BASELINE METRICS job/module counts) are absent from the drafted Part A text | M | H | Deliberate, explicit handling in Phase 2 step 6 — the tool-behavior note is re-appended verbatim; the metrics are re-appended with a "historical" qualifier. Decided here so the implementer does not have to improvise. |
| Concurrent session writes `state.json` between read and write, and `mv` clobbers it | H | L | Phase 1 records `git status --short specs/state.json` and the file's mtime; Phase 4 confirms the only diff to `state.json` is the 378 and 383 entries. |
| 383's abandonment loses the historical blocker record | L | M | `blockers` is preserved verbatim and `previous_status: "blocked"` is added, matching sibling task 358's archived field shape. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is fully sequential: phases 2 and 3
both write `specs/state.json` and must not be parallelized.

---

### Phase 1: Baseline capture and anchor extraction [COMPLETED]

**Goal**: Freeze a verifiable pre-edit baseline so Phase 4 can prove nothing binding was lost.

**Tasks**:
- [ ] Confirm the working tree state of the target file: `git status --short specs/state.json`
      (record whether it is already dirty; if dirty from an unrelated concurrent edit, stop and
      report rather than proceeding).
- [ ] Save the current descriptions to the scratch directory:
      `jq -r '.active_projects[] | select(.project_number==378) | .description' specs/state.json > /tmp/.../378-desc-before.txt`
      and the same for 383.
- [ ] Save the current full entries: `jq '.active_projects[] | select(.project_number==378 or .project_number==383)' specs/state.json > /tmp/.../entries-before.json`.
- [ ] Build the anchor file `/tmp/.../anchors.txt` — one binding string per line, extracted from
      `378-desc-before.txt`, **not** retyped from the report. Required anchors:
      1. `THREE-STRIKES PROHIBITION (standing):` through `...a fourth bare attempt.`
      2. `AMENDED SORRY GATE (user-approved, committed e74f129d1):` through `..."Do NOT discharge here").`
      3. `EXTENDED NON-VACUITY RULE:` through `...HasAttainedINF (landed).`
      4. `USER'S PRIMARY CONSTRAINT:` through `...(which is very hard)."`
      5. `CITE RABINOVICH BY PDF PAGE ONLY:` through `...No chunk_00NN-style citations.`
      6. `PRESERVE -- DO NOT DELETE FILES.` through `...anything in EANegationFix/.`
      7. `LIVENESS:` through `...in a dead module.`
      8. `specs/377_transcribe_rabinovich_faithful_nf_encoding/plans/02_section5-exists-carrier-rebase.md`
      9. The census `--cross-check` MISMATCH explanation sentence (`NOTE: the script's --cross-check
         reports a structural MISMATCH ...` through `Not a defect.`)
      10. The `BASELINE METRICS (post-377-phase-6):` sentence.
- [ ] Record `jq '.active_projects | length' specs/state.json` as the entry-count invariant.

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**: none (read-only phase; scratch files only)

**Verification**:
- `/tmp/.../378-desc-before.txt` is non-empty and contains all ten anchors (`grep -F` each).
- `entries-before.json` parses under `jq empty`.

---

### Phase 2: Apply CORRECTION 1 — replace task 378's description [COMPLETED]

**Goal**: Task 378 carries the value-inverted charter with every binding constraint intact.

**Tasks**:
- [ ] Extract the Part A drafted text from
      `reports/01_charter-corrections.md` (the fenced ` ```text ` block under
      `## Part A — Drafted replacement description for task 378`) into
      `/tmp/.../378-desc-new.txt`.
- [ ] **Unwrap the hard line-wrapping.** The report wraps that block at ~95 columns; `state.json`
      descriptions use one physical line per paragraph, with blank lines between paragraphs and
      one line per `- ` bullet. Join every run of lines that belongs to the same paragraph or the
      same `- ` bullet into a single line separated by one space, preserving blank lines between
      paragraphs. Do not reflow across a blank line, and do not merge two `- ` bullets.
- [ ] Verify all ten Phase 1 anchors survive the unwrap: for each anchor, compare under whitespace
      normalization (`tr -s '[:space:]' ' '` on both sides, then `grep -F`). Anchors 9 and 10 are
      expected to be **absent** at this point — they are re-added by the step below; anchors 1-8
      must all be present.
- [ ] Confirm the newly added material is present: the bracketed staleness note beginning
      `[STALENESS NOTE, preserved for the record, not a license to weaken this gate unilaterally:`
      inside the AMENDED SORRY GATE bullet, the `GOAL AND VALUE (supersedes the original deferral
      framing` paragraph, and the `Phase 6's task list is now LARGELY DONE` /
      `RE-SCOPE DISPATCH TO PHASES 7-8 ONLY` note.
- [ ] Confirm the obsolete banner is gone: the string `WHY IT WAS DEFERRED (do not re-litigate):
      fidelity-only, ZERO OPERATIONAL VALUE.` must **not** appear.
- [ ] **Re-append the two informational blocks the drafted text drops.** Neither was targeted by
      CORRECTION 1 (which changes only the value framing), and neither contradicts the drafted
      staleness notes:
      - Anchor 9 (the `--cross-check` structural-MISMATCH explanation) is a pure tool-behavior
        fact, not a point-in-time count. Append it verbatim to the end of the
        `SORRY CENSUS MUST BE TACTIC-POSITION` bullet, after the drafted `[Baseline note
        superseded: ...]` bracket.
      - Anchor 10 (the BASELINE METRICS job/module counts) is point-in-time. Re-append it as its
        own paragraph immediately before `DISPATCH GUIDANCE:`, prefixed with
        `BASELINE METRICS (HISTORICAL, post-377-phase-6; re-measure at dispatch):` and otherwise
        verbatim.
- [ ] Inject into `state.json` without shell-quoting the payload:
      ```
      jq --rawfile d /tmp/.../378-desc-new.txt \
        '(.active_projects[] | select(.project_number==378) | .description) = ($d | rtrimstr("\n"))
         | (.active_projects[] | select(.project_number==378) | .last_updated) = "2026-07-26T00:00:00Z"' \
        specs/state.json > /tmp/.../state.json.tmp
      ```
- [ ] Validate `jq empty /tmp/.../state.json.tmp`, then move it over `specs/state.json`.

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `specs/state.json` — `active_projects[project_number=378].description` replaced;
  `.last_updated` refreshed. No other field on 378 changes; `status` stays `not started`,
  `dependencies` stays `[341]`.

**Verification**:
- `jq empty specs/state.json` exits 0.
- `jq '.active_projects | length' specs/state.json` equals the Phase 1 invariant.
- All ten anchors present in the post-edit 378 description under whitespace normalization.
- `WHY IT WAS DEFERRED (do not re-litigate)` absent.
- `jq -r '.active_projects[] | select(.project_number==378) | .status'` still reports
  `not started`.

---

### Phase 3: Apply CORRECTION 2 — abandon task 383 [COMPLETED]

**Goal**: Task 383 is `abandoned` with the drafted completion summary, no sub-task created.

**Tasks**:
- [ ] Extract the drafted `completion_summary` from the research report's
      `### Primary recommendation: mark task 383 ABANDONED` fenced block into
      `/tmp/.../383-summary.txt`, and unwrap its hard line-wrapping to a single line (this text is
      one paragraph).
- [ ] Confirm the summary text names the required elements per DECISION.md: the sibling's
      alternate route (`kampArm_zeta`, task 379), and that the negation engine
      (`Prop42NegationGeneral.lean`, Phases 1-6) remains landed, green and sorry-free.
- [ ] Apply the status change, mirroring archived sibling 358's field shape:
      ```
      jq --rawfile s /tmp/.../383-summary.txt \
        '(.active_projects[] | select(.project_number==383)) |=
           (.previous_status = .status
            | .status = "abandoned"
            | .completion_summary = ($s | rtrimstr("\n"))
            | .last_updated = "2026-07-26T00:00:00Z")' \
        specs/state.json > /tmp/.../state.json.tmp
      ```
- [ ] Validate `jq empty`, then move over `specs/state.json`.
- [ ] Confirm no sub-task was created and no dependency edge was added: `.next_project_number` is
      unchanged from its Phase 1 value, `.active_projects | length` is unchanged, and no entry
      anywhere in `active_projects` has `383` in its `dependencies`.

**Timing**: 0.5 hours

**Depends on**: 2

**Files to modify**:
- `specs/state.json` — `active_projects[project_number=383]`: `status` -> `abandoned`,
  `previous_status` -> `blocked` added, `completion_summary` added, `last_updated` refreshed.
  `blockers`, `dependencies` (`[382]`), `artifacts`, `parent_task` and `description` are all left
  untouched as historical record.

**Verification**:
- `jq -r '.active_projects[] | select(.project_number==383) | .status'` reports `abandoned`.
- `jq -r '.active_projects[] | select(.project_number==383) | .completion_summary'` is non-empty
  and contains `kampArm_zeta` and `Prop42NegationGeneral.lean`.
- `jq -r '.active_projects[] | select(.project_number==383) | .blockers'` is byte-identical to
  the Phase 1 baseline.
- `.next_project_number` and `.active_projects | length` unchanged from Phase 1.

---

### Phase 4: Regenerate TODO.md and final cross-check [COMPLETED]

**Goal**: `TODO.md` reflects the new state, and the whole edit is proven scoped and lossless.

**Tasks**:
- [ ] Run `bash .claude/scripts/generate-todo.sh` from the repository root.
- [ ] Confirm `specs/TODO.md` shows task 383 under `[ABANDONED]` and task 378 with the new
      description text (spot-check that `GOAL AND VALUE` appears and `ZERO OPERATIONAL VALUE`
      does not).
- [ ] Re-run the full anchor check from Phase 1 against the final `state.json` 378 description —
      all ten anchors present under whitespace normalization.
- [ ] Confirm scope: `git status --short` shows only `specs/state.json`, `specs/TODO.md`, and this
      task's own `specs/392_.../` artifacts as modified/added. Any other modified path is a scope
      violation and must be reported, not committed.
- [ ] Review `git diff specs/state.json` and confirm the only changed entries are 378 and 383.
- [ ] Write `specs/392_correct_kamp_dedekind_task_charters/summaries/01_charter-corrections-summary.md`
      recording: which anchors were verified, the two informational blocks re-appended in Phase 2,
      and explicit confirmation that no sub-task was created.

**Timing**: 0.5 hours

**Depends on**: 3

**Files to modify**:
- `specs/TODO.md` — regenerated (never hand-edited).
- `specs/392_correct_kamp_dedekind_task_charters/summaries/01_charter-corrections-summary.md` — new.

**Verification**:
- `jq empty specs/state.json` exits 0.
- `specs/TODO.md` contains a `[ABANDONED]` marker on the 383 entry.
- `git diff --stat specs/state.json` shows changes confined to the two entries.

---

## Testing & Validation

- [ ] `jq empty specs/state.json` exits 0 after every write (round-trip validity).
- [ ] `jq '.active_projects | length'` and `.next_project_number` are unchanged end-to-end — proof
      that no task was created or removed.
- [ ] All ten Phase 1 anchors are present in the final 378 description under whitespace
      normalization; the four constraint anchors named in the charter (three-strikes, amended sorry
      gate, extended non-vacuity, PDF-page-only citation) are checked individually and reported by
      name in the summary.
- [ ] `WHY IT WAS DEFERRED (do not re-litigate): fidelity-only, ZERO OPERATIONAL VALUE.` is absent
      from the final 378 description.
- [ ] The bracketed `[STALENESS NOTE, ...]` is present inside the AMENDED SORRY GATE bullet.
- [ ] Task 383 `status == "abandoned"`, `completion_summary` non-empty, `blockers` unchanged.
- [ ] No entry in `active_projects` lists `383` as a dependency.
- [ ] `specs/TODO.md` regenerated by script, not hand-edited.
- [ ] No file under `Theories/` is modified (`git status --short Theories/` is empty).

## Artifacts & Outputs

- `specs/state.json` — updated entries for 378 (description) and 383 (abandonment).
- `specs/TODO.md` — regenerated from state.
- `specs/392_correct_kamp_dedekind_task_charters/summaries/01_charter-corrections-summary.md` —
  execution summary with the anchor-verification record.
- Scratch (not committed): `378-desc-before.txt`, `378-desc-new.txt`, `383-summary.txt`,
  `entries-before.json`, `anchors.txt`.

## Rollback/Contingency

- Both edits are confined to `specs/state.json`, which is tracked and was clean at Phase 1.
  To revert: `git checkout HEAD -- specs/state.json specs/TODO.md`, then re-run
  `bash .claude/scripts/generate-todo.sh`. Take a snapshot via
  `bash .claude/scripts/git-snapshot.sh` first if any other uncommitted work is present, per the
  no-destructive-git-on-a-dirty-tree rule.
- If Phase 2's anchor check fails after injection, restore from `entries-before.json` rather than
  patching the live file by hand, and re-run Phase 2 from the extraction step.
- If a concurrent session is found to have modified `specs/state.json` mid-flight, abort before
  `mv`, report the conflict, and do not force the write.
- Commit granularity: commit after Phase 2 (`task 392 phase 2: correct task 378 charter`) and
  after Phase 4 (`task 392: complete implementation`), staging only `specs/state.json`,
  `specs/TODO.md`, and `specs/392_.../`. Never `git add -A`.
