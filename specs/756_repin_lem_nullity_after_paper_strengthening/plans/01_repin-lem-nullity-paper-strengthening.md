# Implementation Plan: Task #756

- **Task**: 756 - Re-pin `lem:nullity` in the paper definitions of record after the JPL paper strengthened it from an implication to a biconditional, and correct the in-tree docstrings that quote the retired wording
- **Status**: [IMPLEMENTING]
- **Effort**: 9.75 hours
- **Dependencies**: None
- **Research Inputs**: `specs/756_repin_lem_nullity_after_paper_strengthening/reports/01_repin-lem-nullity-paper-strengthening.md`
- **Artifacts**: plans/01_repin-lem-nullity-paper-strengthening.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The live JPL paper has drifted far past the single `lem:nullity` anchor the task description
assumes. `scripts/check-paper-definitions.sh` is red (exit 1) against the live paper, and the
drift set is a whole wave of anchors, not one. Per the settled decision recorded in
`.decisions.json` (Option A), this task absorbs the entire wave as one dated 2026-10-14
drift-correction re-pin of `docs/reference/paper-definitions-of-record.md`, following that file's
own 10-anchor and 14-anchor precedents, and then scopes the in-tree "verbatim" judgment pass to
exactly the re-pinned anchors. **No Lean proof work is implied**: `FrameOver.nullity_identity`
(the biconditional) and `nullity_identity_of_serial_limit` already exist and already over-satisfy
the strengthened lemma, derived choice-free from `serial` + `limit`. Done means: the gate exits 0
against the live paper, `lake build` is green, `readme-lint.sh` and
`check-module-invariants.sh --no-build` still exit 0, and no docstring claims a verbatim
quotation it does not reproduce.

### Research Integration

The research report establishes the four facts this plan is built on, each verified rather than
assumed: (1) the `lem:nullity` strengthening is genuine (implication → biconditional
characterising `⇒₀` as identity); (2) the formalization is *ahead* of the paper, so the re-pin is
a record-and-prose task with zero proof obligation; (3) "verbatim" in this tree's docstrings means
*verbatim against the record file*, not against the paper (stated at
`FormalSystem/Semantics/FrameAxioms.lean:45-46`) — which is what makes the in-tree correction
scope exactly equal to the re-pin scope; (4) `check-paper-definitions.sh` neutral-skips with
exit 0 when the paper is absent, which is the CI path, so this is a local-correctness obligation
and not a release blocker. The report's six "Keep" verdicts on the weak-form paraphrases (§4b) are
carried into Phases 4-6 as the starting hypothesis for the judgment pass, not as a conclusion.

The report also surfaced a gate the dispatch does not name: **C35** in
`check-module-invariants.sh` asserts `scripts/lean-citation-manifest.json` is byte-current by
recorded `span_start`/`span_end`/`keyword_line`, so any docstring edit that shifts a declaration
span turns it red. Phase 7 discharges this with the one sanctioned command.

**Divergence from the report, found at plan time and load-bearing:** the paper moved *again*
between the research dispatch and this one. Re-running the gate at plan time gives **27** drifted
anchors, not the 26 the report records: `def:strongest` newly drifted, and `thm:exist` and
`lem:uniq` re-drifted to hashes different from the ones the report captured
(`299ecc33…` → `93d23414…`, `4d7a5038…` → `56f31fca…`). The paper file also went from dirty to
clean, 3940 → 3959 lines, checksum `1fe9fcc5…` → `068f12c4…`, HEAD `ab7a4a94…` → `9359505a…`.
Every count and every hash in this plan is therefore a hypothesis to re-derive at implementation
time, per the record file's own "`--resolve`, never transcription" rule. Phase 1 exists precisely
to re-establish that ground truth.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context; no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- Re-pin every drifted anchor in `docs/reference/paper-definitions-of-record.md` — prose block,
  `sha256:` line, and `MANIFEST:BEGIN/END` row — from `--resolve` output, never by transcription.
- Re-pin the whole-file sentinels (`PINNED_COMMIT`, `FILE_CHECKSUM`, `LINE_COUNT`) and add the
  provenance-table rows, reconciling the existing sentinel/table divergence.
- Add one dated `### Drift correction (2026-10-14)` section following the 2026-09-17 section's
  shape: what was re-hashed, which changes carry content, and what in-tree prose they force.
- Correct every in-tree site that claims a verbatim quotation it no longer reproduces, starting
  with the four that quote the retired `lem:nullity` wording.
- Correct the in-tree restatements and attributions that now understate the paper's lemma
  (typst, `README.md`, `docs/reference/API_REFERENCE.md`, `FormalSystem/Semantics/README.md`).
- Keep `scripts/lean-citation-manifest.json` byte-current (C35) by regenerating it, never by hand.
- Preserve the record's standing claim that Nullity is DERIVED and not an axiom.

**Non-Goals**:
- No new Lean declarations. `nullity_identity` and `nullity_identity_of_serial_limit` already
  exist; nothing in this task creates, renames, or re-proves a declaration.
- No change to the four `def:frame` axioms or to Nullity's derived status. The four
  `def:frame#*` sub-anchors are byte-stable and must not be touched.
- No edit to the paper itself — it is a read-only input.
- No `sorry`, no axiom, no proof obligation of any kind.
- No fix for pre-existing false-verbatim claims on anchors *outside* the re-pinned set (see
  Risks); those are flagged in the summary, not fixed here.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The paper moves again mid-dispatch (it already moved once between research and planning, and the record file documents this happening twice before) | H | H | Phase 1 re-resolves everything from scratch. Phase 8 re-runs the bare check; if it reports fresh drift, absorb it into the *same* dated section rather than opening a second one |
| Hashes/counts carried from the research report are already stale | H | H | Treat every figure in this plan as a hypothesis. Each phase takes its hashes from its own `--resolve` calls, per the record's own rule. No hash is transcribed from this plan into the record file |
| C35 goes red after docstring edits shift declaration spans (29 seeded entries live in files this task edits: `TaskFrame.lean` 23, `PartialHistory.lean` 3, `Validity.lean` 2, `TemporalOrder.lean` 1) | M | H | Phase 7: `python3 scripts/export-lean-citations.py`, then `--check`. Never hand-edit the manifest |
| Over-correction: rewriting a verbatim quote whose quoted clause did not actually move (e.g. `def:world-history`'s first sentence, `thm:extension`'s main sentence) | M | M | Phases 4-6 diff the quoted clause against the freshly re-pinned block *before* editing. "No change needed" is the expected outcome for most claims |
| An edit crosses out of a Lean comment region and breaks the build | H | L | Per-module `lake build` in Phases 4-5; full `lake build` in Phase 8. All routed through `lake-build-guard.sh` |
| Concurrency: sibling tasks 789 and 793 dispatch this same cycle on this same working tree with no declared `file_scope` | M | M | Re-read each file immediately before editing; stage explicit file lists only (never a directory or glob add); never run `git-snapshot.sh` in its reverting default mode; treat a foreign commit, foreign modification, or unexpected failure outside this task's files as a sibling's and STOP and report rather than "fix" |
| Scope creep into pre-existing false-verbatim claims unrelated to this wave | M | M | Fix only those on *re-pinned* anchors (they are in files being touched anyway); enumerate everything left alone explicitly in the summary |
| typst edits sit outside the `lean4` task type's usual remit | L | M | The typst sites here are statement-accuracy corrections to a restatement of the paper's lemma, not presentation work, so they stay in scope. Phase 6 runs `typst-element-lint.sh` on the touched files and flags in the summary that they split cleanly into a `typst` follow-on if preferred |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4, 5, 6 | 2 |
| 4 | 7 | 4, 5 |
| 5 | 8 | 3, 6, 7 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Re-establish the live drift inventory [COMPLETED]

**Goal**: Produce the authoritative, freshly-derived inventory every later phase consumes — the
drifted-anchor list, each anchor's live text and sha256, and the live paper provenance — without
touching a single tracked file.

**Tasks**:
- [x] Run `bash scripts/check-paper-definitions.sh`, capturing full output to the scratchpad.
      Record the exact drifted-anchor count and the dangling count.
- [x] For each drifted anchor, run
      `bash scripts/check-paper-definitions.sh --resolve "<anchor>|env|-|-"` (use the anchor's
      own `kind|enclosing|locator` fields from its `MANIFEST:BEGIN/END` row, not a blind `env|-|-`)
      and save the emitted `sha256:` and `text:` block verbatim to the scratchpad inventory.
- [x] Confirm the four `def:frame#*` sub-anchors (`#Compositionality`, `#Seriality`, `#Limit`,
      `#Saturation`) are absent from the drifted list. If any has drifted, STOP and report — that
      would contradict this plan's non-goals and the ~91 in-tree verbatim claims resting on them.
- [x] Capture live paper provenance for the sentinel re-pin: `sha256sum` and `wc -l` on the paper
      file, plus `git -C <paper repo> rev-parse HEAD` and
      `git -C <paper repo> status --porcelain -- <paper path>` to record whether the file is
      clean or dirty against that commit (the record file's dirty-pin convention turns on this).
- [x] Classify each drifted anchor as presentational or content-bearing, using the research
      report's §2 table as the starting hypothesis and the fresh `--resolve` text as the
      evidence. This classification is the input to Phase 3's correction note.
- [x] Record any divergence from the research report's 26-anchor list via `issue-record.sh`.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: No tracked file is modified in this phase — its only output is a
scratchpad inventory — so the `prose` row's diff read-through is trivially satisfied (the diff is
empty), and the phase's real check is `bash scripts/check-paper-definitions.sh`'s own exit code
and anchor list, which this phase captures directly.

**Scope Hypothesis**: The drift set was 26 anchors at research time and 27 at plan time
(`def:strongest` newly drifted; `thm:exist` and `lem:uniq` re-drifted), both carried from runs of
`scripts/check-paper-definitions.sh` recorded in `reports/01_repin-lem-nullity-paper-strengthening.md`
§2 and in this plan's Research Integration section respectively. Neither figure is authoritative:
confirm the live count and membership by the bare-check run in this phase's first task, and treat
that run's output as the inventory for every later phase.

**Files to modify**:
- none planned — this phase writes only to the session scratchpad

**Verification**:
- The scratchpad inventory contains one `--resolve` block per drifted anchor reported by the
  bare check, with no anchor missing and none added.
- The drifted-anchor count in the inventory equals the count in the bare check's own summary line.
- The four `def:frame#*` sub-anchors are confirmed absent from the drifted list.

---

### Phase 2: Re-pin every drifted anchor's prose entry and manifest row [COMPLETED]

**Goal**: Make `docs/reference/paper-definitions-of-record.md` reproduce the live paper for every
drifted anchor, so `check-paper-definitions.sh` has nothing left to report.

**Tasks**:
- [x] Re-read `docs/reference/paper-definitions-of-record.md` immediately before editing
      (sibling-task concurrency).
- [x] For each anchor in Phase 1's inventory, in manifest order: replace the fenced ` ```latex `
      block in its `### <anchor>` prose entry with the `--resolve` `text:` block verbatim, and
      replace the following `sha256:` line with the `--resolve` hash. Copy from the inventory;
      never retype.
- [x] For the same anchor, replace the hash field in its `MANIFEST:BEGIN/END` row. Leave the
      `anchor_id|kind|enclosing|locator` fields untouched.
- [x] Leave every non-drifted row untouched, and specifically leave the four `def:frame#*`
      sub-anchor rows untouched.
- [x] Where a prose entry's `### <anchor> — <gloss>` heading gloss is falsified by the new text,
      update the gloss. For `lem:nullity` the heading gloss `DERIVED: w ⇒₀ w (Nullity is not an
      axiom)` becomes the biconditional while **keeping the DERIVED claim**, which the
      strengthening does not touch.
- [x] Commit per green sub-step: one commit per anchor (or per small group of anchors) once that
      anchor's recorded hash matches its `--resolve` hash. Stage `docs/reference/paper-definitions-of-record.md`
      explicitly by name.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: The only edited file is a markdown record with no compile, elaboration, or
executable surface, and the covering check is exact rather than approximate —
`bash scripts/check-paper-definitions.sh` re-hashes every recorded block against the live paper
and names any anchor still mismatched, which is strictly stronger than the `prose` row's diff
read-through for this file.

**Scope Hypothesis**: This phase asserts it edits ~27 prose entries and ~27 manifest rows, one per
drifted anchor, out of 43 pinned anchors. Confirm against Phase 1's inventory, not against this
number: the count of edited `sha256:` lines must equal the count of edited manifest rows must
equal the inventory's anchor count.

**Files to modify**:
- `docs/reference/paper-definitions-of-record.md` - per drifted anchor: the fenced `latex` block, the `sha256:` line, the manifest row hash, and the heading gloss where falsified

**Verification**:
- `bash scripts/check-paper-definitions.sh` reports zero drifted anchors for the anchors in
  Phase 1's inventory. It may still exit 1 on the whole-file sentinels, which Phase 3 re-pins.
- For each edited anchor, the recorded `sha256:` equals the recorded manifest-row hash equals the
  `--resolve` hash in the inventory.
- `git diff` on the record file touches no `def:frame#*` row and no non-drifted row.

---

### Phase 3: Re-pin the sentinels and write the dated drift-correction section [COMPLETED]

**Goal**: Close the record's whole-file provenance and leave a future reader the narrative the
record file's own convention requires for a drift correction.

**Tasks**:
- [x] Re-read the record file immediately before editing.
- [x] Set `<!-- PINNED_COMMIT: … -->`, `<!-- FILE_CHECKSUM: … -->` and `<!-- LINE_COUNT: … -->`
      to the live values Phase 1 captured. This is a drift correction, so all three are re-pinned
      (unlike a case-(b) coverage extension, which re-pins none).
- [x] Add the provenance-table rows for this wave at the top of the file, and **reconcile the
      existing divergence**: the table's last row names `88d9a9a6…` / 4573 lines as "current
      authoritative pin" while the `FILE_CHECKSUM` sentinel still carried `b4e45e2c…` / 4529.
      Setting both to the new live values resolves it.
- [x] Record whether the paper file was clean or dirty against `PINNED_COMMIT` (Phase 1 captured
      this), following the dirty-pin convention the 2026-08-25 and 2026-09-07 sections use.
- [x] Insert one `### Drift correction (2026-10-14): the <N>-anchor wave` section immediately
      after the sentinel block and before the `### Label rename absorption (2026-09-18)` section
      (sections run newest-first). Follow the 2026-09-17 section's shape:
  - [x] the before/after gate state (red, exit 1, N drifted; quiet pass after);
  - [x] the **Re-hashed** list, with the note that every block was re-quoted via `--resolve` and
        none was hand-written;
  - [x] each content-bearing change called out individually, from Phase 1's classification;
  - [x] the `lem:nullity` strengthening stated explicitly as implication → biconditional, with
        the DERIVED claim preserved and `FrameOver.nullity_identity` named as the Lean counterpart
        that already over-satisfies it;
  - [x] the two paper-ward-alignment notes: `def:task-relation`'s `x ≥ 0` → `x > 0` moves the
        paper *toward* the tree's existing treatment of zero (`reflection_of_limit`), and
        `cor:saturation-finite`'s generalization to bare task relations matches
        `TaskFrame.saturation_of_fib_subsingleton`/`saturation_of_finite`;
  - [x] the `thm:extension` footnote-removal note: the footnote asserting the choice-free status
        of `lem:nullity` and `cor:saturation-finite` against `thm:extension`'s Zorn appeal is gone
        from the paper. The tree's choice-freeness claims remain true *of the Lean proofs*, which
        is what the tree is entitled to assert, but they no longer have a live paper footnote
        behind them — record this so a future reader does not hunt for a citation that is gone;
  - [x] what in-tree prose the wave forced (fill in from Phases 4-6 once known, or state the
        enumerated site list and leave Phase 8 to confirm).
- [x] Commit, staging only `docs/reference/paper-definitions-of-record.md`.

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: prose

**Tier Justification**: The edit is confined to markdown prose, sentinel HTML comments, and a
provenance table in one non-executable record file, and the sentinel values are checked exactly by
`bash scripts/check-paper-definitions.sh`, which compares `FILE_CHECKSUM` and `LINE_COUNT` against
the live paper and is the gate this phase exists to turn green.

**Files to modify**:
- `docs/reference/paper-definitions-of-record.md` - `PINNED_COMMIT`/`FILE_CHECKSUM`/`LINE_COUNT` sentinels, provenance-table rows, and one new dated drift-correction section

**Verification**:
- `bash scripts/check-paper-definitions.sh` exits 0 (quiet case-(a) pass), assuming the paper has
  not moved again. If it has, absorb the fresh drift into this same dated section.
- The `FILE_CHECKSUM` sentinel, the `LINE_COUNT` sentinel, and the provenance table's
  "current authoritative pin" row all name the same values — the divergence is gone.
- The new section names every anchor in Phase 1's inventory in its **Re-hashed** list.

---

### Phase 4: Judgment pass and required corrections — `FormalSystem/Semantics/` top level [COMPLETED]

**Goal**: Make every verbatim claim in the top-level `FormalSystem/Semantics/` Lean modules true
against the freshly re-pinned record, including the three retired-`lem:nullity`-wording sites that
live here.

**Tasks**:
- [x] Re-read each target file immediately before editing.
- [x] **Required corrections** (these quote the retired `lem:nullity` sentence verbatim and become
      false the moment Phase 2 lands): replace the quoted sentence with the newly re-pinned
      biconditional text at `FormalSystem/Semantics/TaskFrame.lean:113` (module docstring),
      `FormalSystem/Semantics/TaskFrame.lean:919` (the docstring above `nullity_of_serial_limit`),
      and `FormalSystem/Semantics/FrameAxioms.lean:65` (the "Paper specification, transcribed"
      list). Anchor by surrounding text, not by line number — the numbers shift as edits land.
- [x] **Judgment pass**: for every remaining `verbatim`-marked claim in these files citing a
      re-pinned anchor, diff the *quoted clause* against the freshly re-pinned block. Edit only
      where the quoted clause actually moved. "No change needed" is the expected outcome for most
      — `def:world-history`'s first sentence and `thm:extension`'s main sentence did not move.
- [x] **Keep, do not rewrite** (research §4b verdicts, re-confirmed against the new text before
      acting): `FormalSystem/Semantics.lean:255-259` already names both forms and already calls
      `nullity_identity` "the biconditional" — the only change worth making is the optional note
      that the biconditional is now the paper's own statement;
      `FormalSystem/Semantics/FrameAxioms.lean:113` ("`lem:nullity` itself, DERIVED … from
      *Seriality* at `x = 0` plus *Limit*") is true of both halves.
- [x] Fix the pre-existing false-verbatim claims that sit on *re-pinned* anchors in these files
      (they are in files being touched anyway): `TaskFrame.lean:98-102` quotes `def:frame` as
      "A \textit{frame} is any…" where the record pins "a \textit{task frame} is any…" and omits
      the `⊇`-directed opening clause; `TaskFrame.lean:394-396`, `:412-413`, `:462-463` use the
      retired `\Fib(w, x)` function-application form where the record pins the brace form
      `\fib{w, x}`.
- [x] Keep every edit strictly inside a `/--`/`-/` or `/-!`/`-/` comment region. Do not touch a
      declaration, a signature, or a proof.
- [x] Commit per green sub-step, staging explicit file names only.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: Every edit is docstring-interior with no signature or proof change, and
each edited module is covered individually by
`bash .claude/scripts/lake-build-guard.sh build FormalSystem.Semantics.TaskFrame FormalSystem.Semantics.FrameAxioms FormalSystem.Semantics.FrameProperty FormalSystem.Semantics.PartialHistory FormalSystem.Semantics.PartialHistoryOrder FormalSystem.Semantics.TemporalOrder FormalSystem.Semantics.Validity FormalSystem.Semantics`,
which is the only failure mode a docstring edit has (a comment delimiter broken out of).

**Scope Hypothesis**: A plan-time
`grep -rn verbatim --include=*.lean --include=*.md --include=*.typ` sweep, filtered to the
re-pinned anchors and excluding `specs/**` and `Boneyard`, attributes 31 verbatim claims to this
phase's files (`TaskFrame.lean` 17, `PartialHistory.lean` 5, `FrameProperty.lean` 4,
`FrameAxioms.lean` 4, `Validity.lean` 2, `TemporalOrder.lean` 2, `PartialHistoryOrder.lean` 1;
`lem:nullity` itself accounts for 7 claims tree-wide, 4 of them quoting the retired sentence).
Re-run that sweep against Phase 1's actual inventory before starting, and expect most claims to
need no edit at all.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - retired `lem:nullity` wording at the module docstring and above `nullity_of_serial_limit`; the `def:frame` and `\fib{}` pre-existing mismatches; judgment pass over its other verbatim claims
- `FormalSystem/Semantics/FrameAxioms.lean` - retired `lem:nullity` wording in the transcribed-specification list; judgment pass
- `FormalSystem/Semantics.lean` - optional note that the biconditional is now the paper's own statement
- `FormalSystem/Semantics/PartialHistory.lean` - judgment pass over `def:world-history` claims
- `FormalSystem/Semantics/PartialHistoryOrder.lean` - judgment pass over `def:world-history` claims
- `FormalSystem/Semantics/FrameProperty.lean` - judgment pass over `def:frame-properties` / `def:frame` claims
- `FormalSystem/Semantics/TemporalOrder.lean` - judgment pass over `def:temporal-order` claims
- `FormalSystem/Semantics/Validity.lean` - judgment pass over `def:frame-validity` claims

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build <each edited module>` is green.
- `grep -rn 'Rightarrow_0 w' --include=*.lean FormalSystem/` returns no hit inside a
  `lem:nullity`-attributed verbatim claim in these files.
- Every remaining `verbatim`-marked quotation in these files reproduces its re-pinned record block
  character-for-character over the quoted clause.
- `git diff` shows no change outside a `/--`/`/-!` comment region.

---

### Phase 5: Judgment pass and required corrections — `Extension/`, Examples, Tests [COMPLETED]

**Goal**: Same obligation as Phase 4, for the `FormalSystem/Semantics/Extension/` subtree and the
two outlying Lean sites, including the fourth retired-wording site.

**Tasks**:
- [x] Re-read each target file immediately before editing.
- [x] **Required correction**: `FormalSystem/Semantics/Extension/Admissible.lean:34` quotes the
      retired `lem:nullity` sentence verbatim *and* already misquotes the current record ("in
      every **frame**" where the record pins "in every **task frame**"). Replace with the
      re-pinned biconditional text and fix the frame/task-frame wording.
- [x] Fix the pre-existing false-verbatim claim on a re-pinned anchor in the same docstring:
      `Admissible.lean:35-38` quotes `def:constraints` with the retired "constraints *imposed
      on*" wording and the retired `\Fib(…)` form, and `def:constraints` was restructured with
      named `A`, `C`, `F_t`, `S_{t,s}`. Re-quote from the re-pinned block.
- [x] **Judgment pass** over the remaining verbatim claims in this phase's files, diffing each
      quoted clause against the re-pinned block and editing only where the clause moved.
- [x] **Keep, do not rewrite** (research §4b, re-confirmed): `Admissible.lean:117` and
      `Extension/Extension.lean:171` are References lines naming the zero loop `w ⇒₀ w` — what
      the module actually consumes. A proof that needs only the weak loop keeps citing the weak
      loop.
- [x] Keep every edit strictly inside a comment region.
- [x] Commit per green sub-step, staging explicit file names only.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: Docstring-interior edits with no signature or proof change, covered module
by module by
`bash .claude/scripts/lake-build-guard.sh build FormalSystem.Semantics.Extension.Admissible FormalSystem.Semantics.Extension.Extension FormalSystem.Semantics.Extension.Constraint FormalSystem.Semantics.Extension.Step FormalSystem.Semantics.Extension.Completion FormalSystem.Examples.TemporalStructures`
plus `lake build BimodalTest` for the one test file.

**Scope Hypothesis**: The same plan-time sweep attributes 19 verbatim claims on re-pinned anchors
to this phase's files (`Extension/Extension.lean` 5, `Extension/Admissible.lean` 3,
`Extension/Constraint.lean` 2, `Extension/Step.lean` 1, `Extension/Completion.lean` 1,
`Extension/README.md` 1, `Examples/TemporalStructures.lean` 1,
`Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean` 1, `docs/theorem-index.md` 3 —
`theorem-index.md` is handled in Phase 6). Re-run the sweep against Phase 1's inventory before
starting.

**Files to modify**:
- `FormalSystem/Semantics/Extension/Admissible.lean` - retired `lem:nullity` wording, frame/task-frame fix, `def:constraints` re-quote; judgment pass
- `FormalSystem/Semantics/Extension/Extension.lean` - judgment pass over `def:constraints`/`thm:extension` claims
- `FormalSystem/Semantics/Extension/Constraint.lean` - judgment pass over `def:constraints` claims
- `FormalSystem/Semantics/Extension/Step.lean` - judgment pass
- `FormalSystem/Semantics/Extension/Completion.lean` - judgment pass
- `FormalSystem/Semantics/Extension/README.md` - judgment pass
- `FormalSystem/Examples/TemporalStructures.lean` - judgment pass
- `Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean` - judgment pass over the `cor:saturation-finite` claim

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build <each edited module>` is green, and
  `bash .claude/scripts/lake-build-guard.sh build BimodalTest` is green.
- No verbatim claim in these files quotes `$w \Rightarrow_0 w$` as the paper's `lem:nullity`.
- Every remaining `verbatim`-marked quotation reproduces its re-pinned record block over the
  quoted clause.
- `git diff` shows no change outside a comment region.

---

### Phase 6: Correct the restatements and attributions in docs, README and typst [NOT STARTED]

**Goal**: Stop the non-Lean deliverables from understating the paper's lemma, and make the
`lem:nullity` attributions point at the declaration the strengthening now names.

**Tasks**:
- [ ] Re-read each target file immediately before editing.
- [ ] `typst/FormalFoundations.typ:230` — `#lemma("Nullity")[$w arrow.r.double.long_(0) w$ for
      every world state $w$ of every frame.]` now understates the paper. State the biconditional,
      and point `#leansrc` at the biconditional's declaration rather than `nullity` (or keep
      `nullity` and say explicitly that it is the reflexivity half).
- [ ] `typst/chapters/02-semantics.typ:137-142` — same understatement in the `#lemma("Nullity")`
      block, which carries a `// CONFIRM(paper): lem:nullity states this lemma` comment. State
      the biconditional. `:155` already carries the biconditional (`#leanNullityIdentity`), so
      reconcile the two rather than duplicating; keep the "Why Nullity Is a Lemma, Not an Axiom"
      remark and the derived-status claim intact.
- [ ] `docs/reference/API_REFERENCE.md:196` — "`FrameOver.nullity` (`TaskRel w 0 w`, the paper's
      `lem:nullity`…)": the strengthening moves the `lem:nullity` attribution to
      `nullity_identity`, with `nullity` as its reflexivity half. Re-attribute.
- [ ] `README.md:84` — "Nullity (`w ⇒_0 w`) is **not** an axiom": the parenthetical now
      understates the paper. State the biconditional while keeping the not-an-axiom claim, which
      is the point of the sentence. The paragraph already names `nullity_identity` correctly two
      sentences later, so keep that consistent.
- [ ] `FormalSystem/Semantics/README.md:84` — same shape; it already names
      `FrameOver.nullity_identity`, so confirm rather than assume an edit is needed.
- [ ] `docs/reference/transcription-audit-surface.md:82` and `:165` — "The `⊇` half [of *Limit*]
      is `lem:nullity`, derived" is still true of the reflexivity half but imprecise now that
      `lem:nullity` names the whole biconditional. Add a parenthetical rather than rewriting the
      row.
- [ ] `docs/theorem-index.md` — judgment pass over its three verbatim claims on re-pinned anchors.
- [ ] **Keep, do not rewrite** (research §4c/§4b, re-confirmed): `typst/chapters/06-notes.typ:32`
      already covers both `nullity` and `nullity_identity`;
      `docs/development/PROPERTY_TESTING_GUIDE.md:295` ("`lem:nullity` is derived from *Seriality*
      and *Limit*") is true of both halves;
      `docs/reference/state-topology-appendix-support.md:103` states "given `w ⇒₀ w`" as a
      hypothesis, and the weak loop is genuinely all `coneTopology_le_nbhdTopology` consumes;
      `FormalSystem/Semantics/Presheaf/Behavior.lean:91` correctly states what the construction
      consumes.
- [ ] Commit per green sub-step, staging explicit file names only.

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: prose

**Tier Justification**: Every edit is markdown or typst prose with no Lean compile or elaboration
surface, and the covering checks are exact rather than a read-through:
`bash scripts/readme-lint.sh` for the two README files and
`bash .claude/scripts/typst-element-lint.sh --verbose typst/FormalFoundations.typ typst/chapters/02-semantics.typ`
for the typst files.

**Files to modify**:
- `typst/FormalFoundations.typ` - the `#lemma("Nullity")` statement and its `#leansrc` target
- `typst/chapters/02-semantics.typ` - the `#lemma("Nullity")` statement, reconciled with the existing `#leanNullityIdentity` paragraph
- `docs/reference/API_REFERENCE.md` - re-attribute `lem:nullity` from `nullity` to `nullity_identity`
- `README.md` - the Nullity parenthetical
- `FormalSystem/Semantics/README.md` - the Nullity parenthetical, if it needs one
- `docs/reference/transcription-audit-surface.md` - parenthetical on the two *Limit*/`lem:nullity` rows
- `docs/theorem-index.md` - judgment pass over its verbatim claims on re-pinned anchors

**Verification**:
- `bash scripts/readme-lint.sh` exits 0.
- `bash .claude/scripts/typst-element-lint.sh --verbose typst/FormalFoundations.typ typst/chapters/02-semantics.typ`
  reports no blocking placement finding.
- `typst compile` on the affected document root succeeds (the typst sources are compiled, so a
  malformed `#lemma` body is a hard failure, not a cosmetic one).
- No remaining non-Lean site states the paper's Nullity as a bare implication while claiming to
  state the paper's lemma.

---

### Phase 7: Regenerate the Lean citation manifest (C35) [NOT STARTED]

**Goal**: Restore C35 — `scripts/lean-citation-manifest.json` byte-current — after the docstring
edits of Phases 4 and 5 shifted declaration spans.

**Tasks**:
- [ ] Confirm C35 is actually red first: `bash scripts/check-module-invariants.sh --no-build` and
      read the C35 line. If it still passes, record that and skip the regeneration rather than
      producing a no-op diff.
- [ ] Run `python3 scripts/export-lean-citations.py` (no flags; it writes the manifest). Never
      hand-edit the manifest.
- [ ] Verify with `python3 scripts/export-lean-citations.py --check`.
- [ ] Re-run `bash scripts/check-module-invariants.sh --no-build` and confirm C35 PASS with zero
      `FAIL` lines overall.
- [ ] Commit, staging `scripts/lean-citation-manifest.json` explicitly by name.

**Timing**: 0.5 hours

**Depends on**: 4, 5

**Verification Tier**: local

**Tier Justification**: The only changed file is a generated JSON manifest with no compile
surface, and `bash scripts/check-module-invariants.sh --no-build` checks exactly it via C35 — an
exact byte-currency comparison against the regenerated export, which is a strictly stronger check
than any read-through of the diff.

**Scope Hypothesis**: 29 seeded manifest entries live in files Phases 4-5 edit
(`TaskFrame.lean` 23, `PartialHistory.lean` 3, `Validity.lean` 2, `TemporalOrder.lean` 1), derived
at plan time from `scripts/lean-citation-manifest.json` itself. Confirm by reading the C35 output
rather than this number: the regenerated manifest's diff should touch only entries in files
Phases 4-5 actually edited, and a diff touching other files is a signal to STOP (possibly a
sibling task's edit).

**Files to modify**:
- `scripts/lean-citation-manifest.json` - regenerated, never hand-edited

**Verification**:
- `python3 scripts/export-lean-citations.py --check` exits 0.
- `bash scripts/check-module-invariants.sh --no-build` exits 0 with C35 PASS and zero `FAIL` lines.
- `git diff scripts/lean-citation-manifest.json` touches only entries in files Phases 4-5 edited.

---

### Phase 8: Full gate sweep and acceptance confirmation [NOT STARTED]

**Goal**: Confirm every acceptance criterion against the live tree, and absorb any fresh paper
drift into the same dated correction section rather than leaving the gate red.

**Tasks**:
- [ ] Re-run `bash scripts/check-paper-definitions.sh` against the live paper. If fresh drift
      appeared, re-resolve and absorb it into Phase 3's existing dated section (do not open a
      second section), then re-run.
- [ ] Re-run `bash scripts/check-paper-definitions.sh --paper /nonexistent/x.tex` to confirm the
      neutral-skip CI path still exits 0 — the property that keeps this a local obligation rather
      than a release blocker.
- [ ] Run the full Lean build, detached and routed through the guard:
      `bash .claude/scripts/lake-build-guard.sh build` — see
      `context/patterns/bounded-build-waiter.md` for the hard-timeout / `kill -0` waiter shape.
      Confirm green.
- [ ] `bash scripts/readme-lint.sh` exits 0.
- [ ] `bash scripts/check-module-invariants.sh --no-build` exits 0 with zero `FAIL` lines
      (C15, C20, C35 all PASS).
- [ ] Run the complete repository gate set: `bash .claude/scripts/verify-deploy.sh`. This is the
      `full` tier's own named aggregator, not a hand-picked subset of it.
- [ ] Re-run the verbatim sweep
      (`grep -rn verbatim --include=*.lean --include=*.md --include=*.typ`, excluding `specs/**`
      and `Boneyard`) and confirm no claim on a re-pinned anchor misquotes its record block.
- [ ] Confirm the DERIVED, not-an-axiom claim survives at the record's `lem:nullity` entry,
      `TaskFrame.lean`'s module docstring, `README.md`, and `typst/chapters/02-semantics.typ`'s
      "Why Nullity Is a Lemma, Not an Axiom" remark.
- [ ] Enumerate in the summary everything deliberately left alone: pre-existing false-verbatim
      claims on anchors *outside* the re-pinned set, and the typst sites' availability as a
      `typst` follow-on.
- [ ] Final commit, staging explicit file names only.

**Timing**: 1.25 hours

**Depends on**: 3, 6, 7

**Verification Tier**: full

**Files to modify**:
- `docs/reference/paper-definitions-of-record.md` - only if fresh paper drift must be absorbed into the existing dated section

**Verification**:
- `bash scripts/check-paper-definitions.sh` exits 0 against the live paper.
- `bash scripts/check-paper-definitions.sh --paper /nonexistent/x.tex` exits 0 (neutral skip).
- `bash .claude/scripts/lake-build-guard.sh build` reports a green build.
- `bash scripts/readme-lint.sh` exits 0.
- `bash scripts/check-module-invariants.sh --no-build` exits 0, zero `FAIL` lines.
- `bash .claude/scripts/verify-deploy.sh` — the complete gate set this tier names — passes.
- No docstring claims a verbatim quotation it does not reproduce, for any re-pinned anchor.
- Zero `sorry` and zero new axiom introduced (trivially: no Lean declaration was touched).

---

## Lean Challenge Statements

None. This plan commits to **zero** new Lean declarations — the identifier set named under
`- **Goals**:` is empty, so the identifier set declared here is empty too, as that cross-validation
requires. `FrameOver.nullity_identity` and `nullity_identity_of_serial_limit` already exist in
`FormalSystem/Semantics/TaskFrame.lean` and already prove the strengthened biconditional, derived
from `serial` and `limit`; there is no proof obligation anywhere in this task.

## Testing & Validation

- [ ] `bash scripts/check-paper-definitions.sh` exits 0 against the live paper (the task's
      headline criterion).
- [ ] `bash scripts/check-paper-definitions.sh --paper /nonexistent/x.tex` still exits 0 — the
      neutral-skip CI path is intact.
- [ ] `bash .claude/scripts/lake-build-guard.sh build` is green.
- [ ] `bash scripts/readme-lint.sh` exits 0.
- [ ] `bash scripts/check-module-invariants.sh --no-build` exits 0 with zero `FAIL` lines; C15,
      C20 and C35 all PASS.
- [ ] `python3 scripts/export-lean-citations.py --check` exits 0.
- [ ] `bash .claude/scripts/typst-element-lint.sh --verbose` reports no blocking finding on the
      touched typst files, and those files compile.
- [ ] `bash .claude/scripts/verify-deploy.sh` passes.
- [ ] No docstring, README, doc page or typst block claims a verbatim quotation it does not
      reproduce, for any re-pinned anchor.
- [ ] Zero `sorry`, zero new axiom.

## Artifacts & Outputs

- `docs/reference/paper-definitions-of-record.md` — all drifted anchors re-pinned (prose block,
  `sha256:` line, manifest row), whole-file sentinels re-pinned, provenance table extended and
  reconciled, and one new dated `### Drift correction (2026-10-14)` section.
- Corrected Lean docstrings in `FormalSystem/Semantics/` (top level and `Extension/`),
  `FormalSystem/Examples/TemporalStructures.lean`, and
  `Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean`.
- Corrected prose in `README.md`, `FormalSystem/Semantics/README.md`,
  `docs/reference/API_REFERENCE.md`, `docs/reference/transcription-audit-surface.md`,
  `docs/theorem-index.md`, `typst/FormalFoundations.typ`, `typst/chapters/02-semantics.typ`.
- Regenerated `scripts/lean-citation-manifest.json`.
- `specs/756_repin_lem_nullity_after_paper_strengthening/summaries/01_repin-lem-nullity-paper-strengthening-summary.md`
  — including the explicit enumeration of what was left alone.

## Rollback/Contingency

Every phase commits independently and the whole task is additive to documentation and docstrings —
no declaration, signature, or proof is touched — so reverting is `git revert` of the task's own
commits, in reverse order, with no cascade. The three natural revert boundaries are: the record
file alone (Phases 2-3), the Lean docstrings (Phases 4-5, which then require Phase 7's manifest
regeneration to be reverted too, or re-run), and the docs/typst prose (Phase 6).

If the working tree must be rolled back rather than reverted — the only scenario being a
half-applied record-file edit that leaves `check-paper-definitions.sh` reporting a hash the record
does not contain — follow `context/contracts/recovery.md`'s rollback rung for the exact
snapshot-then-rollback invocation shape, including its out-of-scope override flag. Do **not** emit
`git-snapshot.sh {N}` in its reverting default mode as a precaution at the start of a phase; for
an ordinary defensive checkpoint before a large record-file edit, use
`bash .claude/scripts/git-snapshot.sh 756 --no-revert`, which is durable without reverting the
working tree.

Because sibling tasks are live on this same tree, a rollback must never be a whole-tree
operation: revert this task's own commits by sha, and if a foreign commit or foreign uncommitted
modification is present, STOP and report rather than rolling back over it.
