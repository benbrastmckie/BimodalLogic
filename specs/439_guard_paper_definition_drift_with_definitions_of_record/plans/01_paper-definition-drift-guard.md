# Implementation Plan: Task #439

- **Task**: 439 - guard_paper_definition_drift_with_definitions_of_record
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: `specs/439_guard_paper_definition_drift_with_definitions_of_record/reports/01_paper-definition-drift-guard.md`
- **Artifacts**: plans/01_paper-definition-drift-guard.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The research dispatch for this task overshot its phase and authored all three deliverables
directly. `specs/paper-definitions-of-record.md` (28 KB, 18 manifest anchors),
`scripts/check-paper-definitions.sh` (12.5 KB, executable), and the rewritten task-424 description
in `specs/state.json` all exist on disk, uncommitted. This plan therefore does **not** re-author
them. It plans the work that genuinely remains: **independent verification** of everything the
research agent self-reported, correction of whatever that verification turns up, and finalization.

The governing posture is that the research agent's self-report is a **hypothesis, not evidence**.
Every claim it made — the three-outcome lint contract, the 18 resolving anchors, the satisfiability
gap, the honesty of the dirty-pin caveat, the recorded skill-vs-hook decision, and the 424
dependency edge — is re-derived from scratch here before the deliverables are committed. Definition
of done: every recorded anchor independently confirmed to resolve, all three lint outcomes
independently reproduced, all four delegation-flagged items independently confirmed or corrected,
the 424 edge deliberately kept or dropped with a stated reason, and the deliverables committed.

### Research Integration

Key findings carried forward from the report:

- **The lint's three outcomes were tested against real data**, not fixtures: case (a) against the
  live paper, case (b) against the paper's HEAD commit `eb5be99e`, case (c) against `c3da9852`
  (reported as naming 6 drifted anchors plus 3 anchors unresolvable at that commit). These exact
  runs are re-executed in Phase 1 rather than trusted.
- **A real extraction bug was found and fixed mid-research**: an unfiltered `grep -m1` matched the
  paper's own `%% OLD: ...` editorial comment instead of the live line. The fix (a shared
  `filter_noncomment_keep_ln` helper applied to all three resolvers) is a regression the
  verification must specifically re-probe, since it is the one known place the extraction logic
  was wrong.
- **The paper's working tree was dirty at recording time** (base commit `eb5be99e`, `M
  possible_worlds.tex`, 32 insertions / 12 deletions confined to the `def:constraints` /
  `lem:constraint` / `lem:admissible` region, outside the tracked set). This is why the pin is a
  file checksum (`efe6fc74...`) rather than a clean commit SHA.
- **Satisfiability was recorded as a GAP** — no paper-native `\label`led definition exists,
  claimed to be corroborated by an exhaustive `satisfiab` grep.
- **The 424 edge (`[361]` -> `[361, 414]`) was flagged by the research agent itself** as a
  reviewable judgment call made under this task's audit authority, not a cluster-wide policy.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context, and no roadmap phases are included.
`specs/ROADMAP.md`'s re-issued Paper Alignment Programme is the cluster this infrastructure serves,
but this plan neither reads nor writes it.

## Goals & Non-Goals

**Goals**:

- Independently reproduce all three lint outcomes (silent pass, notice-pass, FAIL) from a clean
  slate, confirming exit codes and the specific drifted-anchor naming — never accepting the
  research agent's self-report as evidence.
- Independently confirm every one of the 18 manifest anchors resolves in the live paper (no
  dangling `\label` / `\aitem`) and that each recorded hash matches a freshly re-derived hash.
- Confirm the record's prose entries and its machine-readable manifest agree with each other — a
  consistency axis the research report never claims to have checked.
- Confirm or correct the four delegation-flagged items: the 424 dependency edge, the three
  provenance fields plus the honesty of the dirty-pin caveat, the reality of the satisfiability
  gap, and the presence of the recorded skill-preflight-vs-git-hook decision.
- Apply every correction the verification turns up, and record any verification that closed with
  no correction needed as an explicit evidenced finding rather than silence.
- Finalize and commit the deliverables with a non-goal compliance audit.

**Non-Goals**:

- Re-authoring `specs/paper-definitions-of-record.md` or `scripts/check-paper-definitions.sh` from
  scratch. They exist; they are audited and corrected, not rebuilt.
- Rubber-stamping the existing files. An audit that finds nothing must produce evidence that it
  looked, not an assurance that it did.
- Widening the manifest beyond the 18 anchors the task's "cover at minimum" list requires. The
  record's "Deliberately not covered" boundary is verified as honest, not expanded.
- Editing anything under `/home/benjamin/Philosophy/Papers/` — the paper is strictly read-only
  input. No write, no `git` mutation, no working-tree cleanup in that repository.
- Editing any file under `FormalSystem/`, `latex/`, or `typst/`.
- Restating, re-deriving, or "improving" any definition. The record quotes; it does not paraphrase.
- Performing task 424's underlying work (the Representation Theorem / compactness gate itself).
- Wiring the lint into CI, a git hook, or a skill preflight. The decision is *recorded*;
  implementing it is out of scope.
- Writing to `.claude/` — gitignored, disposable, regenerated from an external source store.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The paper drifted again between recording and verification, so case (a) no longer reproduces | M | H | Case (b) — paper moved, no tracked anchor drifted — is the *expected steady state*, not a failure. Phase 1 treats a case-(b) result as a pass. Do **not** re-pin the checksum to silence it; re-pinning is only warranted if Phase 2 finds an actual tracked-anchor drift (see Phase 5). | 
| A tracked anchor genuinely drifted since recording (real case (c) against the live paper) | H | L | Phase 5 handles this explicitly: re-record the drifted anchor's verbatim text and hash, re-pin the checksum/line count, and record the drift event in the provenance section. This is the record doing its job, not a defect. |
| `--against c3da9852` no longer reproduces because the paper repo's history was rewritten or the commit is unreachable | M | L | The script degrades gracefully by design (reports drift by hash without OLD text). If the commit is genuinely unreachable, substitute any older commit known to differ and record the substitution; do not skip case (c) verification entirely. |
| The `%% OLD:` comment-filter fix regressed or is incomplete for some resolver path | H | L | Phase 1 probes the fix directly by resolving a `def:frame` axiom whose `%% OLD:` comment is known to shadow it, rather than only checking that the aggregate run passes. |
| The 424 description rewrite silently dropped original scope, gate contract, or acceptance criteria | H | M | Phase 4 diffs the rewritten description against the pre-rewrite version recovered from git, rather than reading the new text alone and judging it plausible. |
| Verification is performed but produces no written evidence, leaving the audit unfalsifiable | M | M | Every phase's verification criteria require a recorded command and its observed output in the phase's progress notes and the final summary, not a bare assertion of having checked. |
| Accidental write into the read-only paper repository during verification | H | L | All paper access is read-only (`git show`, `grep`, `sha256sum`). Phase 6's non-goal audit explicitly re-checks that the paper repo's `git status --porcelain` is byte-identical to its pre-task state. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3, 4 | -- |
| 2 | 2 | 1 |
| 3 | 5 | 1, 2, 3, 4 |
| 4 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Independently reproduce the lint's three-outcome contract [COMPLETED]

**Goal**: Re-derive, from a clean slate, that `scripts/check-paper-definitions.sh` actually
implements the three-outcome contract the task specified — including the exit codes and the
specific drifted-anchor naming — without relying on the research report's account of having done so.

**Tasks**:

- [ ] Confirm script hygiene independently: `bash -n scripts/check-paper-definitions.sh` exits 0;
      `test -x scripts/check-paper-definitions.sh`; the file lives in `scripts/`, not
      `.claude/scripts/`.
- [ ] Read the script end to end, specifically checking that the `filter_noncomment_keep_ln`
      comment-filter is applied to **all** resolver paths (the `env` label search, the `env`
      end-marker search, and the `item` / `aitem` content searches) — the research report claims
      all four; confirm or refute by reading, not by trusting.
- [ ] Run the live check with no arguments. Record the exit code and full output verbatim.
      Classify the result as case (a) (silent, exit 0) or case (b) (notice naming a new checksum,
      exit 0). **Both are passes.** A case-(b) result means the paper moved again with no tracked
      anchor drifting, which is the outcome this lint exists to distinguish — record it and
      continue; do not treat it as failure and do not re-pin.
- [ ] Reproduce case (b) deliberately: run `--against eb5be99ea3f19a86c9891d7798e619890e36cd43`
      (the recorded base commit). Confirm exit 0 and a notice naming the differing checksum while
      reporting all recorded definitions unchanged.
- [ ] Reproduce case (c): run `--against c3da9852`. Confirm exit **1**, and confirm the output
      names each drifted anchor with old and new text. Record the actual drifted-anchor list
      observed.
- [ ] Probe the `%% OLD:` regression directly: use `--resolve` (or `--against c3da9852`) to resolve
      a `def:frame` axiom sub-anchor that has a `%% OLD:` comment shadowing it in the paper, and
      confirm the resolved text is the live `\item[\it ...]` line, not the comment.
- [ ] If `c3da9852` is unreachable, select and record a substitute older commit known to differ,
      and complete case (c) against it rather than skipping the case.

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The research report asserts case (c) against `c3da9852` names exactly **6
drifted anchors** (`def:frame`, its four axiom sub-anchors, and `def:world-history`) plus **3
unresolvable-at-that-commit anchors** (`def:temporal-order`, `def:task-relation`, `def:directed`).
Confirm by running the command and counting the anchors actually named in the output. A different
count is a finding to record and investigate in Phase 5, not a number to quietly adopt.

**Files to modify**:

- None. This phase is read-and-execute only. Any defect found is recorded and fixed in Phase 5.

**Verification**:

- All three outcomes reproduced with their exit codes recorded verbatim (0 for (a)/(b), 1 for (c)).
- The comment-filter probe returns live axiom text, not a `%% OLD:` line.
- Every command run and its observed output captured in the phase's progress notes.

---

### Phase 2: Independently confirm anchor resolution and record/manifest consistency [COMPLETED]

**Goal**: Confirm every recorded anchor actually resolves in the live paper with no dangling
`\label` or `\aitem`, that every manifest hash matches a freshly re-derived hash, and — an axis the
research report never claims to have checked — that the record's human-readable prose entries agree
with the machine-readable manifest they sit above.

**Tasks**:

- [ ] Extract the manifest rows from between the `<!-- MANIFEST:BEGIN -->` / `<!-- MANIFEST:END -->`
      sentinels and enumerate every `anchor_id|kind|enclosing|locator|sha256` row.
- [ ] For each row, re-resolve the anchor against the live paper via the script's `--resolve` mode
      and diff the freshly derived sha256 against the recorded one. Every anchor must resolve; any
      that does not is a dangling anchor and a Phase 5 correction item.
- [ ] Independently confirm each `\label` / `\aitem` name exists in the live paper via a direct
      `grep` over the paper source, so anchor existence is established without depending solely on
      the script whose correctness is itself under audit.
- [ ] Cross-check prose against manifest: for each `### ` entry in the record, confirm the anchor
      named in the prose heading appears in the manifest, and that the verbatim quoted block shown
      in the prose is the same text whose hash the manifest records. Report any prose entry with no
      manifest row, or any manifest row with no prose entry.
- [ ] Confirm the anchor-kind coverage the task required is actually present: `env`, `item`, and
      the `\aitem`-key kind (`CO` / `TMP-CO`, which are two distinct `\label` anchors sharing one
      displayed key).
- [ ] Confirm the record's "cover at minimum" list from the task description is fully satisfied:
      `def:frame` and its four axioms plus supporting machinery, `lem:nullity` and `thm:occurrence`
      as derived results, `def:world-history` including totality and the extension order,
      `thm:extension`, the truth clauses including the box clause's quantifier domain, logical
      consequence, and validity. Name any required item with no corresponding anchor.

**Timing**: 50 minutes

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: The manifest is asserted to contain exactly **18 anchors** (13 `env`, 4
`item`, 2 `aitem`), all of which resolve and hash-match. Confirm by counting the manifest rows
mechanically and by resolving each one; report the actual counts observed rather than restating
these.

**Files to modify**:

- None. Read-and-verify only; corrections land in Phase 5.

**Verification**:

- Every manifest anchor resolves against the live paper, with the resolved hash matching the
  recorded hash (or the mismatch recorded as a Phase 5 item).
- Every anchor name independently confirmed present in the paper by direct `grep`, not only via
  the script.
- Prose-vs-manifest cross-check completed with any asymmetry named.
- Each "cover at minimum" item from the task description mapped to a specific anchor, or its
  absence explicitly recorded.

---

### Phase 3: Verify the provenance pin, the satisfiability gap, and the recorded invocation decision [COMPLETED]

**Goal**: Independently confirm three of the four delegation-flagged items — that all three
provenance fields the task required are present and the dirty-pin caveat is explicit and honest,
that the satisfiability gap is a real finding rather than an omission dressed up as one, and that
the skill-preflight-vs-git-hook decision is genuinely recorded.

**Tasks**:

- [ ] Provenance completeness: confirm the record's header carries all **three** fields the task
      description required — the pinned paper commit SHA, the file checksum, and the line count —
      in both the human-readable table and the machine-readable HTML-comment sentinels the script
      parses.
- [ ] Provenance honesty: confirm the dirty-pin caveat explicitly states that the working tree was
      dirty relative to its own git HEAD at recording time, that the **checksum** (not the SHA) is
      the authoritative pin, and that the commit SHA is not claimed to be byte-identical to the
      quoted content. A caveat that merely mentions dirtiness without stating which field is
      authoritative is insufficient.
- [ ] Provenance accuracy: independently re-derive the paper's current sha256 and line count and
      compare against the recorded values. If they differ, that is the expected consequence of
      further paper movement — record the delta and confirm it is consistent with Phase 1's case
      (a)/(b) classification rather than silently reconciling it.
- [ ] Satisfiability gap reality: run an exhaustive case-insensitive `satisfiab` grep over the live
      paper source and inspect **every** hit. Confirm each is informal prose, not a `\label`led
      `Ddef`, `\aitem`, or otherwise-named definitional clause. The gap claim is only sustained if
      no definitional occurrence exists; a single labelled definition refutes it and becomes a
      Phase 5 correction (the anchor must then be recorded).
- [ ] Confirm the record's satisfiability section states the gap explicitly, does **not** invent a
      definition, and correctly marks the Lean `satisfiable` / `SatisfiableAbs` family as
      repository-native vocabulary rather than paper-sourced.
- [ ] Invocation decision: confirm the record contains a section recording a **decision** about
      whether the lint should be invoked from a skill preflight or a git hook — with a stated
      choice and reasoning, not merely a description of the options — and that it explicitly marks
      implementation as out of scope.
- [ ] Confirm the "Deliberately not covered" scope boundary is stated as a recorded decision with
      reasoning, so the excluded anchors read as a deliberate boundary rather than an oversight.

**Timing**: 40 minutes

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: The satisfiability gap rests on the assertion that an exhaustive `satisfiab`
grep yields **only informal prose occurrences**. Confirm by running the grep and reading every hit
individually — the claim is falsified by one labelled definition, so a hit count alone is not
confirmation.

**Files to modify**:

- None. Read-and-verify only; corrections land in Phase 5.

**Verification**:

- All three provenance fields confirmed present in both the table and the sentinels.
- The dirty-pin caveat confirmed to name the checksum as authoritative and to disclaim
  SHA-to-content byte-identity.
- Every `satisfiab` occurrence in the paper individually inspected and classified.
- The invocation decision confirmed to state a choice with reasoning and an out-of-scope marker.

---

### Phase 4: Audit the 424 description rewrite and deliberately keep or drop the dependency edge [COMPLETED]

**Goal**: Independently evaluate the two things the research agent did to task 424 — rewriting its
description and extending its dependencies from `[361]` to `[361, 414]` — and reach a deliberate,
stated decision on the edge rather than inheriting it by default.

**Tasks**:

- [ ] Recover the pre-rewrite 424 description from git (the last committed `specs/state.json`) and
      diff it against the current one. Confirm the rewrite **preserved** 424's original scope, its
      gate contract, its acceptance criteria, and its non-goals — the research report claims full
      preservation, so any dropped clause is a finding.
- [ ] Confirm the rewrite states the current definition as a settled input and names explicitly
      which of 424's prior research survives and which is superseded, matching the treatment the
      cluster's six re-issued tasks received.
- [ ] Confirm the corrected design-document path in the rewrite actually exists on disk (the
      research report states the path was corrected because task 361 archived after completion).
- [ ] Cycle check: confirm adding `414` to 424's dependencies introduces no cycle in the task
      dependency graph. Verify by computing reachability from `414` and confirming `424` is not
      reachable, then by a full-graph cycle scan over every task in `specs/state.json`.
- [ ] Warrant check: confirm the substantive claim behind the edge — that 424's design document
      states its Representation Theorem directly against the current `Omega`-parameterized
      `TruthAt` signature, and that task 414 is chartered to eliminate exactly that parameter — by
      reading the cited Lean sources and 414's own description. Do **not** perform 424's underlying
      work; this is a check on whether the dependency is warranted, not on whether the theorem holds.
- [ ] Reach a deliberate verdict: **keep** the edge (if the warrant check sustains it) or **drop**
      it back to `[361]` (if it does not), and record the reason either way in the implementation
      summary. Leaving the edge in place without a stated reason is not an acceptable outcome.
- [ ] If the edge is dropped, edit `specs/state.json` and regenerate TODO.md via
      `bash .claude/scripts/generate-todo.sh` — never edit `specs/TODO.md` directly.

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The dependency graph is asserted to be acyclic with the `424 -> 414` edge in
place, and 414's own dependencies are asserted to be `[420, 438]`. Confirm by running a full-graph
cycle scan at implementation time rather than adopting these values — other tasks in the cluster may
have moved since this plan was written.

**Files to modify**:

- `specs/state.json` — only if the edge is dropped, or if the diff reveals a dropped clause that
  must be restored to 424's description.
- `specs/TODO.md` — regenerated from state.json only if state.json changed.

**Verification**:

- Pre-rewrite vs post-rewrite diff of 424's description reviewed, with any dropped scope, gate
  contract, or acceptance criterion named.
- Full-graph cycle scan run and its result recorded.
- A stated keep-or-drop verdict with a reason, recorded in the summary.
- If state.json changed, TODO.md regenerated via the script (not hand-edited).

---

### Phase 5: Apply corrections found in verification [COMPLETED]

**Goal**: Fix everything Phases 1-4 surfaced. If a verification axis closed clean, record that
outcome with its evidence rather than leaving it unstated — an audit with no written result is
indistinguishable from an audit that never ran.

**Tasks**:

- [ ] Collect every finding from Phases 1-4 into a single correction list, each item tagged with
      the phase that found it and the evidence that establishes it.
- [ ] Fix any defect in `scripts/check-paper-definitions.sh` — a resolver missing the comment
      filter, an incorrect exit code, a case-(b) result misreported as drift, or an anchor the
      script cannot resolve. Re-run `bash -n` and all three outcome cases after any edit.
- [ ] Fix any defect in `specs/paper-definitions-of-record.md` — a dangling anchor, a hash that no
      longer matches, a prose entry that disagrees with its manifest row, a missing "cover at
      minimum" item, or a provenance field that is absent or overstated.
- [ ] Handle genuine tracked-anchor drift, if Phase 2 found any: re-record the drifted anchor's
      verbatim text and freshly derived hash, update the pinned checksum and line count, and add a
      dated note to the provenance section recording the drift event and what moved. Do **not**
      re-pin the checksum merely because the paper moved with no tracked anchor drifting — that is
      case (b), the designed steady state, and re-pinning would churn the record for no signal.
- [ ] Apply any 424 correction Phase 4 determined (edge drop, or restoration of a dropped clause),
      regenerating TODO.md from state.json afterward.
- [ ] For each verification axis that closed with no correction needed, write an explicit
      evidenced finding — the command run and what it showed — into the material Phase 6 will carry
      into the summary.
- [ ] Re-run the full lint after all corrections and confirm the outcome is (a) or (b), never (c).

**Timing**: 50 minutes

**Depends on**: 1, 2, 3, 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:

- `specs/paper-definitions-of-record.md` — conditional on findings.
- `scripts/check-paper-definitions.sh` — conditional on findings.
- `specs/state.json` — conditional on Phase 4's verdict.
- `specs/TODO.md` — regenerated only if state.json changed.

**Verification**:

- Every collected finding either fixed or explicitly recorded as accepted-with-reason.
- `bash -n` passes and all three outcome cases reproduce after any script edit.
- The full lint re-run ends in case (a) or (b) with exit 0.
- Every clean axis has a written evidenced finding, not silence.

---

### Phase 6: Non-goal compliance audit, summary, and commit [COMPLETED]

**Goal**: Confirm no hard boundary was crossed during verification, write the implementation
summary, and commit the deliverables.

**Tasks**:

- [ ] Confirm the paper repository at `/home/benjamin/Philosophy/Papers/PossibleWorlds` was not
      modified: its `git status --porcelain` and its `git log -1` must be unchanged from the
      pre-task state, and no commit may have been created there.
- [ ] Confirm this repository's diff touches no file under `FormalSystem/`, `latex/`, `typst/`, or
      `.claude/`, by inspecting `git status --short` against the full working tree.
- [ ] Confirm `scripts/check-paper-definitions.sh` carries no task-number citation, since it sits
      outside `specs/**` and is subject to the no-task-references-in-deliverables rule. (The record
      file is under `specs/**` and is exempt.)
- [ ] Confirm the script's placement remains `scripts/`, alongside its siblings, and that nothing
      was written into `.claude/scripts/`.
- [ ] Write `summaries/01_paper-definition-drift-guard-summary.md` recording, per verification
      axis, what was checked, the command used, what was observed, and what was corrected —
      including the axes that closed clean. State the 424 edge verdict and its reason explicitly.
- [ ] Stage the task-scoped file set only — the task directory, `specs/paper-definitions-of-record.md`,
      `scripts/check-paper-definitions.sh`, and `specs/state.json` / `specs/TODO.md` if changed.
      Never `git add -A` or `git commit -am`.
- [ ] Review `git status --short` and `git diff --staged` before committing, confirming no
      unrelated or concurrent-session edits were swept in.
- [ ] Commit as `task 439: complete implementation` with the session ID in the body.

**Timing**: 35 minutes

**Depends on**: 5

**Verification Tier**: local

**Files to modify**:

- `specs/439_guard_paper_definition_drift_with_definitions_of_record/summaries/01_paper-definition-drift-guard-summary.md` — new.

**Verification**:

- Paper repository confirmed byte-for-byte untouched.
- No staged path under `FormalSystem/`, `latex/`, `typst/`, or `.claude/`.
- Summary records every verification axis with its evidence, including clean ones.
- `git diff --staged` reviewed before the commit; staged set matches the task scope exactly.

---

## Testing & Validation

- [ ] `bash -n scripts/check-paper-definitions.sh` exits 0 and the file is executable.
- [ ] Live run (no arguments) exits 0 in case (a) or case (b); a case-(b) notice is a pass, not a
      failure.
- [ ] `--against <recorded base commit>` exits 0 with a notice naming the differing checksum.
- [ ] `--against c3da9852` (or a recorded substitute) exits 1 and names each drifted anchor with old
      and new text.
- [ ] Every manifest anchor resolves in the live paper; no dangling `\label` or `\aitem`.
- [ ] Every manifest hash matches a freshly re-derived hash, or the mismatch is recorded and
      resolved.
- [ ] Record prose entries and manifest rows are mutually consistent.
- [ ] Every task-required "cover at minimum" item maps to a recorded anchor, or its absence is
      explicitly justified.
- [ ] All three provenance fields (commit SHA, checksum, line count) present, with the dirty-pin
      caveat naming the checksum as authoritative.
- [ ] Every `satisfiab` occurrence in the paper individually inspected; the gap claim confirmed or
      refuted.
- [ ] The skill-preflight-vs-git-hook decision is recorded with a stated choice and reasoning.
- [ ] The task dependency graph is acyclic; the 424 edge verdict is stated with a reason.
- [ ] The paper repository is unmodified; no file under `FormalSystem/`, `latex/`, `typst/`, or
      `.claude/` is touched.

## Artifacts & Outputs

- `specs/paper-definitions-of-record.md` — audited and corrected (already exists; not re-authored).
- `scripts/check-paper-definitions.sh` — audited and corrected (already exists; not re-authored).
- `specs/state.json` — 424's rewritten description and dependency edge, kept or corrected under an
  explicit verdict.
- `specs/TODO.md` — regenerated from state.json if state.json changed.
- `specs/439_guard_paper_definition_drift_with_definitions_of_record/summaries/01_paper-definition-drift-guard-summary.md` — new.
- `specs/439_guard_paper_definition_drift_with_definitions_of_record/plans/01_paper-definition-drift-guard.md` — this plan.

## Rollback/Contingency

The deliverables are currently untracked and uncommitted, so rollback is cheap and no prior
committed state is at risk.

- **If verification finds the lint fundamentally broken** (an outcome it cannot distinguish, or an
  anchor class it cannot resolve): fix forward in Phase 5. Do not delete and re-author — the
  extraction logic embeds a real, hard-won fix for the `%% OLD:` comment-shadowing bug that a
  rewrite would likely reintroduce.
- **If the record is found to contain a fabricated or paraphrased definition** (a direct charter
  violation): remove the offending entry and its manifest row rather than "improving" it, and
  record the removal as an explicit scope-boundary note.
- **If the 424 rewrite is found to have dropped scope**: restore the dropped clauses from the git
  version of `specs/state.json` and regenerate TODO.md. If the rewrite is unsalvageable, revert
  424's entry to its committed state entirely and record the negative verdict instead.
- **If a destructive git operation becomes necessary while uncommitted work exists**: run
  `bash .claude/scripts/git-snapshot.sh 439` first, per the no-destructive-git rule.
- **Never** attempt rollback by mutating the paper repository. It is read-only input; nothing this
  task does needs to be undone there, and any change found there is a bug to report, not to fix.
