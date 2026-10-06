# Implementation Plan: Task #736

- **Task**: 736 - Cslib omega-automata survey and E3 reopen check
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/736_cslib_omega_automata_survey_and_e3_reopen_check/reports/01_cslib-omega-automata-survey.md
- **Artifacts**: plans/01_cslib-survey-e3-closure.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/context/standards/status-markers.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/workflows/task-breakdown.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

**The research dispatch already delivered all four of this task's acceptance items.** The report
(737 lines) carries the cslib inventory with per-declaration provenance, sorry status and axiom
profiles, the port assessment, the literature gap analysis and the explicit E3 verdict;
`specs/literature-index.json` went 93 → 106 entries with three identity hazards recorded;
`specs/evidence/seam-gluing-ray-product/cslib-ramsey-port-feasibility.lean` compiles sorry-free
and is wired into `scripts/check-evidence-probes.sh` (collection reported exit 0, 17 wired
probes); and every cslib claim was re-verified by elaboration, correcting three claims the task
description asserted. All of that is committed (`e244c6c05`, `f16504cf8`).

This implement round is therefore a **verification-and-closure round, not a build round**, and the
plan says so rather than inventing work to look busy. It does four things: re-verifies the
acceptance gates as they stand *now* rather than as the research dispatch left them (Phase 1);
makes one bounded, best-effort attempt at the three literature gaps the research could not close
by wiring because they are absent from the global corpus (Phase 2); records the E3 re-audit at
E3's own site, so a future reader of the device-selection probe learns that two of its four
rejection grounds were falsified (Phase 3); and writes the execution summary with an explicit
operator hand-off list of findings this task deliberately did not act on (Phase 4).

### Research Integration

Five report findings drive the phases above:

1. **The verdict is (i) KEEP candidate (d); E3's selection stands, with its reasons rewritten.**
   Two of E3's four rejection grounds do not survive: cslib *proves* McNaughton
   (`Cslib.ωLanguage.IsRegular.iff_da_muller`, fork-only) so Büchi determinization does exist in
   Lean by the Büchi/Choueka route, and `brunner_seidl_sickert_2019_verified_ltl_to_dra` is a
   complete Isabelle/HOL formalization of a *Safraless* LTL→DRA translation in the AFP. Neither
   failure favours a different candidate: (b)'s Lean core is `proof_wanted` and (c)'s MSO half is
   unformalized anywhere. This is what Phase 3 records at E3's site.
2. **E3's LOW-confidence (c)/(d) shared-Ramsey-core claim is RAISED to High, machine-checked.**
   `IsRegular.compl` is proved *through* `buchiFamily_cover`, which colours a pair of time points
   by the congruence class of the segment between them and applies `infinite_graph_ramsey`. That
   is candidate (d)'s device, and it is the proof of Büchi complementation. Also Phase 3 material.
3. **The dispatch's central premise is false where it matters.** `BuchiCompl.lean`'s three main
   theorems are `proof_wanted` — no declaration is emitted, `#print axioms` gives *unknown
   constant*, and `grep -c sorry` returns 0, so the sorry-count is a false negative. Nothing in
   this round may treat `complementNA` as a resource.
4. **Port nothing.** The McNaughton closure is 7,526 lines across 47 modules against a Mathlib 76
   commits divergent, and delivers an acceptor over *states* — the refuted axis. The `require`
   dissent is recorded and rejected on a stated ground. No phase here ports anything.
5. **Three literature gaps stayed open** for want of a source, not for want of wiring:
   Kupferman–Vardi FOCS 2005 "Safraless Decision Procedures", Grädel–Thomas–Wilke 2002, and the
   Hodkinson–Reynolds HbML §5.10–5.11 bodies. Phase 2 makes one bounded attempt at these.

### Prior Plan Reference

No prior plan. `next_artifact_number` is 2, so this is round 1's plan and shares the research
report's `01` sequence number.

### Roadmap Alignment

No `roadmap_path` and no `roadmap_flag` were provided in this dispatch, so per the planner
contract this plan adds no roadmap-review or roadmap-update phase and no phase edits
`specs/ROADMAP.md`. A read-only consultation was nonetheless performed, because the verdict bears
on the roadmap's text, and it found two statements in the Phase 1 "Selected — experiment E3 has
run" section that this task's evidence makes stale:

- "no Safra or Piterman formalization exists in any proof assistant" — still literally true of
  Safra/Piterman specifically, but it is deployed there as a rejection ground, and the framing it
  invites ("nothing in this area is formalized in Lean") is now false.
- "(3) Two limits stay open: ... that the MSO and Ramsey routes share Büchi's Ramsey core is
  LOW-confidence **framing, not a finding**, checkable against Thomas 1997 (in corpus)" — that
  check has now been performed and the claim is High, machine-checked. The limit is closed.

Both are carried to the operator as hand-off items in Phase 4, not edited here.

## Goals & Non-Goals

**Goals**:
- Re-establish, by running them, that all four acceptance items hold at this round's HEAD rather
  than at the research dispatch's HEAD.
- Make one bounded, best-effort acquisition attempt at the three still-WANTED sources, with
  "recorded WANTED, unchanged" an explicitly valid outcome.
- Record the E3 re-audit where E3's own record lives, comment-only, so the verdict is discoverable
  from the probe the ROADMAP cites.
- Deliver an execution summary carrying the verdict and an explicit operator hand-off list of
  findings deliberately not acted on, with the reason for each.

**Non-Goals**:
- **Any revision of task 711, any edit to its plan, and any touch of
  `FormalSystem/Metalogic/Decidability/RaySummary/**`** — the dispatch boundary. If the operator
  reads the verdict as licensing a revision, that is a separate `/revise 711` they run.
- **Any edit to `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean`**, including the
  stale `Nat.Nth` docstring note at line 36 that the research found and correctly declined. That
  file is in task 711's `file_scope` and 711 is `partial` — a live writer. Hand-off, not edit.
- **Any port of cslib code**, and no Lake `require` on cslib. The assessment is "port nothing" and
  this round does not relitigate it.
- **Any edit to `specs/ROADMAP.md`** (no `roadmap_flag`; see Roadmap Alignment).
- **Any `.claude/**` edit**, including the report's three context-extension recommendations. Those
  are source-store work under `.claude-extensions.json`'s `source_dir` per
  `.claude/rules/source-store-deploy-boundary.md`, and `/meta` territory besides. The deployed
  tree is additionally flagged STALE for `core filetypes lean typst` this dispatch, which is a
  second reason not to hand-patch it.
- **Spawning any follow-on task.** Follow-on work is filed by the operator from the report and the
  summary.
- Any complexity claim, upper or lower; any claim that the `⊡(Fp)`/`⊡(Pp)` shapes discriminate
  between devices (`Probe732Device` settled that they do not); any route over states rather than
  the time axis.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `scripts/check-evidence-probes.sh` is a shared file with live writers (711 `partial`, 733/734 `not_started`); a concurrent edit could collide | H | L | Phase 1 re-reads the file and records its blob hash before any phase touches it; Phase 3 re-reads again immediately before its gate run. No phase edits the script — this round appends nothing to it (the research dispatch already did the one append). |
| The comment-only append in Phase 3 crosses the `/- ... -/` block boundary and breaks a gate-wired probe | H | L | Verification tier `local`: compile that one probe with `lake env lean` immediately after the edit, before the collection run. The edit adds no `-/` and no code. |
| Phase 2's online acquisition reaches the network and could fetch an unexpected or paywalled object | M | M | Bounded: at most one `literature-discover.sh` query per named source and at most one `literature-ingest-online.sh` bridge call per open-access Tier-3 hit. `ONLINE_INGEST_NO_PDF` / paywall is a **valid completion**, not a failure. Nothing is force-downloaded; no re-ingest of anything already in corpus. |
| Re-ingesting a source already in corpus, or matching a doc_id by author-year stem | M | L | Match every id **whole** against `~/Projects/Literature/index.json`, never by stem. The `thomas_1997` / `thomas_1997_languages_automata` hazard and the three collisions the research recorded (`piterman_2007`, `vardi_1996`, `vardi_wolper_1986`) are respected as recorded. Phase 2 re-runs the orphan/duplicate audit after any write. |
| The probe collection is slow (17 wired probes, each elaborating against FormalSystem) and could exhaust a dispatch | M | M | Each phase that runs it budgets 0.75h and treats the collection as the single expensive step. If a run is backgrounded, follow `context/patterns/bounded-build-waiter.md` — hard timeout, `kill -0` on the captured PID, one waiter per log. |
| Phase 3 annotates a *completed* task's artifact (732 owns `device-selection-probe.lean`) | M | L | 732's status is `completed` — no live writer. The edit is comment-only, append-only within the header, changes no declaration, and is gate-verified. The rationale is stated in the appended block itself so the provenance is legible. |
| `file_scope` in state.json names `specs/evidence/cslib-omega-automata/`, which does not exist — the probe landed in `specs/evidence/seam-gluing-ray-product/` | L | — | `file_scope` is descriptive and never filesystem-validated. This plan's `Files to modify` entries are the harvest source (`plan-file-scope-harvest.sh`), so recording the real paths here corrects the drift as a side effect. Flagged, not separately fixed. |
| `check-task-references.sh` already FAILs repo-wide (198 pre-existing unexempted occurrences) and could be misread as a regression from this task | L | M | Baseline recorded in Phase 1. The new `(736)` reference in `scripts/check-evidence-probes.sh` was confirmed **not** flagged by the lint. The gate for this round is "count did not increase and no flagged occurrence sits in a file this task touched", never "lint passes". |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel. Phases 2 and 3 own disjoint file sets
(`specs/literature-index.json` + the global corpus vs. one file under `specs/evidence/`), so the
territory contract is clean if they are dispatched together.

---

### Phase 1: Re-verify the four acceptance items at this round's HEAD [NOT STARTED]

**Goal**: Establish, by running them rather than by citing the research dispatch's run, that all
four acceptance items hold now. This phase edits nothing; its output is recorded evidence that
later phases and the summary cite.

**Tasks**:
- [ ] Record the current blob hash and `WIRED`/`WIRED_REPO`/`DEFERRED` entry counts of
      `scripts/check-evidence-probes.sh` (`git rev-parse HEAD:scripts/check-evidence-probes.sh`),
      and confirm the `seam-gluing-ray-product/cslib-ramsey-port-feasibility` entry is still
      present and its doc block intact. This is the contention baseline for Phase 3.
- [ ] Run `bash scripts/check-evidence-probes.sh` from the repository root. Capture the full
      output and the exit code verbatim. Acceptance item (3) requires exit 0 with the whole
      collection passing.
- [ ] Validate `specs/literature-index.json` as a **sub-index**: valid JSON; entry count; every
      `doc_id` resolves **whole** in `~/Projects/Literature/index.json`; zero duplicate `doc_id`s;
      zero entries missing `doc_id`; every referenced source directory present on disk. Note in
      the record that `literature-validate-mode.md`'s `specs/literature/{path}` filesystem checks
      are written for a per-repo literature directory and do not apply to this `doc_id`-keyed
      sub-index — state the checks actually run rather than claiming a mode that does not fit.
- [ ] Confirm the report exists at the research artifact path and carries the four acceptance
      sections: the per-declaration inventory with provenance/sorry/axiom columns, the port
      assessment, the literature gap analysis, and the explicit E3 verdict.
- [ ] Record the `check-task-references.sh` baseline: run it, capture the unexempted count, and
      confirm no flagged occurrence lies in a file this task touched
      (`scripts/check-evidence-probes.sh`).
- [ ] Record any issue or win as it arises via `.claude/scripts/issue-record.sh` (non-fatal).

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

*(Zero edit surface — this phase changes no file. Its entire task list is gate execution, which
is strictly broader than this tier's floor; the tier is declared at the floor because there is no
edit for a higher tier to protect, not to defer any verification.)*

**Scope Hypothesis**: The research report asserts 17 wired probes passing with exit 0, 106
sub-index entries with 0 orphans / 0 duplicates, and a pre-existing 198-occurrence task-reference
lint baseline. All three are **hypotheses carried from a prior dispatch, not facts** — confirm
each by running the command and recording its actual output. A changed count is a finding to
record, not a number to reconcile silently.

**Files to modify**:
- none planned (verification only; no file is edited in this phase)

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0 and reports the whole collection passing.
- The sub-index audit reports 0 orphans, 0 duplicate `doc_id`s, 0 missing `doc_id`s, and 0
  unresolvable source directories, on a valid-JSON file.
- The report is present and the four acceptance sections are located by heading.
- The task-reference lint count is recorded and no flagged occurrence is in a touched file.

---

### Phase 2: Bounded acquisition attempt on the three still-WANTED sources [NOT STARTED]

**Goal**: Make one bounded, best-effort attempt to close the three literature gaps the research
could not close by wiring, because they are absent from the global corpus — not merely unwired.
**A "recorded WANTED, unchanged" outcome is a complete and valid result of this phase** and must
not be treated as a failure or a blockage.

**Tasks**:
- [ ] For each of the three named gaps, run at most one discovery query:
      `bash .claude/scripts/literature-discover.sh "<terms>"` for
      (a) Kupferman–Vardi, "Safraless Decision Procedures", FOCS 2005;
      (b) Grädel–Thomas–Wilke, "Automata, Logics, and Infinite Games", 2002;
      (c) Hodkinson–Reynolds, Handbook of Modal Logic ch. 11, §§5.10–5.11 bodies.
- [ ] For each discovery record, classify by tier and status. **Tier 1 means it is already in the
      global corpus** — in that case wire the sub-index reference and ingest nothing. Match every
      candidate id **whole**; never by author-year stem.
- [ ] For each Tier-3 `open_access` record carrying a `pdf_url` or `arxiv_id`, run exactly one
      `bash .claude/scripts/literature-ingest-online.sh --record '<json>'` bridge call. Dry-run
      first (`--dry-run`) and read the directive token before the live call.
- [ ] On `ONLINE_INGEST_NO_PDF`, a `paywall` status, or no usable hit: stop for that source and
      record it as still WANTED, with the query used and the reason, for the summary. Do not
      escalate, do not try alternate mirrors, do not fetch anything the bridge did not resolve.
- [ ] Re-run Phase 1's sub-index audit after any write (orphans / duplicates / missing `doc_id` /
      directory resolution), and record the before/after entry counts.
- [ ] Respect the recorded identity hazards: the pre-existing `thomas_1997` /
      `thomas_1997_languages_automata` split, and the three collisions the research recorded on
      `piterman_2007`, `vardi_1996` and `vardi_wolper_1986`. If a new entry collides on an
      author-year stem with an existing one, write the mirrored hazard field on both.
- [ ] Record each outcome (win or issue) via `.claude/scripts/issue-record.sh` as it happens.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: interface

*(The sub-index is read by the briefing generator and the coverage-delta script, so a shape or
id defect is visible outside the file; verification covers the file plus those enumerated direct
consumers.)*

**Scope Hypothesis**: Three sources are asserted still-WANTED and absent from the global corpus
(the research's finding). Confirm absence by a **whole-id** lookup in
`~/Projects/Literature/index.json` before any online step — if one of the three turns out to be
present after all, the correct action is to wire it and ingest nothing, and the "3 gaps" count
drops. The expected realistic outcome is that (b) and (c) stay WANTED (a 2002 Springer volume and
a Handbook chapter body); do not read a WANTED outcome as a phase failure.

**Files to modify**:
- `specs/literature-index.json` - only if a gap closes: append the new entry/entries with
  `doc_id`, `reason`, and any mirrored stem-collision `hazard`; additive writes only, never a
  wholesale array replacement
- `~/Projects/Literature/` (global corpus, outside the repository) - only via
  `literature-ingest-online.sh`, and only for a Tier-3 open-access hit

**Verification**:
- Each of the three sources ends in exactly one recorded state: CLOSED (wired, with the whole
  doc_id named) or still WANTED (with the query and the reason named).
- `specs/literature-index.json` remains valid JSON with 0 orphans, 0 duplicate `doc_id`s, 0
  missing `doc_id`s, and 0 unresolvable source directories after any write.
- Nothing already in corpus was re-ingested, converted, or re-downloaded.
- `bash .claude/scripts/literature-coverage-delta.sh` (topic query) shows no new unwired
  topic-relevant document introduced by this phase.

---

### Phase 3: Record the E3 re-audit at E3's own site [NOT STARTED]

**Goal**: Append one comment-only RE-AUDIT block to the header of
`specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`, so a reader of E3's own
record — the file the ROADMAP cites as the selection's record — learns that this task re-audited
its four rejection grounds, which two did not survive, why the selection nonetheless stands, and
where the full verdict lives. The verdict currently exists only inside a task directory.

**Boundary note**: this file is in task 732's `file_scope` and 732 is `completed`, so there is no
live writer. The edit is append-only within the existing header comment, touches no declaration,
and leaves the probe's own outcome claims intact — it annotates them, it does not rewrite them.
This phase does **not** edit task 711's plan, `RaySummary/**`, or `specs/ROADMAP.md`.

**Tasks**:
- [ ] Re-read the probe's header in full and confirm the four rejection grounds as the file
      actually states them, before writing anything about them.
- [ ] Append a RE-AUDIT block inside the header comment stating, with the report path named:
      (1) ground "Mathlib carries zero ω-automata infrastructure at the pin" — **CONFIRMED**, by a
      14-pattern sweep over 8,268 Mathlib source files;
      (2) ground "no formalization of Safra or Piterman determinization in any proof assistant" —
      **literally true of Safra/Piterman, but no longer supporting the conclusion**: cslib proves
      McNaughton (`Cslib.ωLanguage.IsRegular.iff_da_muller`, fork-only, axiom-clean) so
      determinization to a deterministic Muller acceptor is available in Lean by the Büchi/Choueka
      route, and a *Safraless* LTL→DRA translation is verified end-to-end in Isabelle/HOL in the
      AFP (`brunner_seidl_sickert_2019_verified_ltl_to_dra`);
      (3) ground "(c)'s discharge theorem has no Lean formalization" — **partially falsified, in
      the ω-automata half only**: `Cslib.ωLanguage.IsRegular.compl` is proved upstream, but cslib
      has **zero** MSO, so the MSO↔ω-regular correspondence remains unformalized anywhere and
      (c)'s discharge still cannot be cited;
      (4) the file's own "(c) and (d) are plausibly the same mathematics ... Low-confidence
      background" — **RAISED to High, machine-checked**: `IsRegular.compl` is proved *through*
      `buchiFamily_cover`, which colours a pair of time points by the congruence class of the
      segment between them and applies `infinite_graph_ramsey`; that is candidate (d)'s device and
      it is the proof of Büchi complementation.
- [ ] State in the same block that **the selection is unchanged — verdict (i), KEEP candidate
      (d)** — and why the two falsifications do not move it: (b)'s Lean core is `proof_wanted`
      (`complement_language_sub`/`sup`/`eq` emit no declaration), the Isabelle development is not
      portable under the zero-debt policy, and (c)'s MSO half is unformalized; while (d)'s one
      non-trivial ingredient is in-tree, proved, sorry-free, axiom-clean and has a live consumer.
- [ ] State what the block does **not** claim: no complexity bound; no device discrimination on
      the probed shapes (`Probe732Device` settled that and this block does not disturb it); no
      revision of any task; no claim about cslib's own proofs beyond what `#print axioms` and the
      absence of `sorryAx`/`proof_wanted` certify in cslib's build.
- [ ] Confirm no `-/` sequence was introduced and the block stays inside the opening `/-`.
- [ ] Compile that one probe: `lake env lean
      specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`.
- [ ] Re-read `scripts/check-evidence-probes.sh`, compare against Phase 1's recorded blob hash,
      then run `bash scripts/check-evidence-probes.sh` and confirm exit 0 with the collection
      passing.
- [ ] Commit this green sub-step before moving on (per-substep mandate), staging only the one
      edited file.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

*(The edit is comment-only, but it sits inside a `/- ... -/` block in a compiled, gate-wired Lean
file, where a stray delimiter is a compile failure. Tie-break to the stricter tier: build that
single module.)*

**Scope Hypothesis**: Exactly one file is edited, and the claim is that **two of E3's four
rejection grounds do not survive**. Confirm the ground count and their wording against the
probe's actual header text before asserting either in the appended block — the "four grounds"
framing comes from the report, and the file is the authority on what it claims. Confirm
`complement_language_eq` is still absent (`proof_wanted`, no declaration) rather than restating
it from the report, if the cslib tree is reachable; if it is not reachable this dispatch, attribute
the claim to the report's machine-checked run rather than re-asserting it as a fresh check.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` - append one comment-only
  RE-AUDIT block inside the existing header comment; no declaration, import, or proof touched

**Verification**:
- `lake env lean specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` succeeds with
  no error and no new warning.
- `bash scripts/check-evidence-probes.sh` exits 0 with the whole collection passing.
- `git diff` on the file shows additions only, all inside the header comment region.
- `scripts/check-evidence-probes.sh` is byte-identical to Phase 1's recorded hash (this phase does
  not edit it).

---

### Phase 4: Execution summary and operator hand-off [NOT STARTED]

**Goal**: Write the round's summary carrying the verdict, the acceptance evidence as actually
re-run, and an explicit hand-off list of findings this task deliberately did not act on with the
reason for each — so the operator can file follow-on work from a list rather than by re-reading
737 lines of report.

**Tasks**:
- [ ] Write `specs/736_cslib_omega_automata_survey_and_e3_reopen_check/summaries/01_cslib-omega-automata-survey-summary.md`
      per `.claude/context/formats/summary-format.md`.
- [ ] Lead with the verdict: **(i) KEEP candidate (d), the time-axis Ramsey-coloured summary.
      E3's selection stands, with its reasons substantially rewritten.** State plainly that this
      is a complete and valid outcome, not a blockage, and that nothing here licenses or requires
      a `/revise 711`.
- [ ] Record the acceptance-item evidence with the **actual** Phase 1/2/3 command outputs quoted
      (gate exit code and probe count, sub-index audit numbers, report sections located), never
      the research dispatch's numbers restated.
- [ ] Record the (c)/(d) confidence change — LOW → **High, machine-checked** — and name the two
      declarations that carry it (`Cslib.ωLanguage.IsRegular.compl`,
      `Cslib.Automata.NA.Buchi.buchiFamily_cover`) plus the in-tree counterpart already using the
      same device on the MSO side (`RamseyFactorization.lean`'s two orientation-specific
      instantiations of `infinite_ramsey_pairs` over monadic k-types).
- [ ] Write the **operator hand-off list**, each item with its reason for non-action:
      (a) `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean:36` carries a stale note
      that `Mathlib.Data.Nat.Nth` is unavailable here — falsified (the olean is present and this
      task's probe uses `Nat.nth`); **not edited** because the file is in task 711's `file_scope`
      and 711 is `partial`, a live writer;
      (b) `specs/ROADMAP.md`'s E3 section carries two now-stale statements (the "no formalization
      in any proof assistant" rejection framing, and item (3)'s "LOW-confidence framing, not a
      finding" limit, now closed); **not edited** — no `roadmap_flag` on this dispatch;
      (c) three context-extension recommendations from the report (`proof_wanted` as a trust
      surface distinct from `sorry` in `metadata-trust-surfaces.md`; a new
      `external-library-port-assessment.md` pattern; a stem-collision pass for the literature
      audit); **not implemented** — `.claude/**` is a deploy artifact and these belong in the
      source store via `/meta`;
      (d) any source left WANTED by Phase 2, with its query and reason;
      (e) the port assessment's standing recommendation — **port nothing; treat cslib as a
      read-only reference** — with the `require` dissent and the stated ground for rejecting it
      (it would drag *this* tree 76 Mathlib commits forward).
- [ ] Note the `file_scope` drift: state.json anticipated `specs/evidence/cslib-omega-automata/`
      while the probe landed in `specs/evidence/seam-gluing-ray-product/`; this plan's
      `Files to modify` entries are the harvest source that corrects it.
- [ ] Re-run `bash scripts/check-evidence-probes.sh` as the closing gate and record its exit code.
- [ ] Commit the summary with the scoped-staging flow (`git status --short`, `git diff --staged`
      review; explicit file list, never `git add -A` or a directory pathspec).

**Timing**: 0.75 hours

**Depends on**: 2, 3

**Verification Tier**: prose

*(Markdown artifact under `specs/**`, zero compile surface. The closing gate run in this phase's
task list is the full collection, above this tier's floor.)*

**Scope Hypothesis**: The hand-off list is asserted to have five items (a)–(e). Confirm at
write time: Phase 2's outcome may close item (d) entirely, and a Phase 1/2/3 finding may add an
item. The list is the phase's deliverable, not a fixed count to preserve.

**Files to modify**:
- `specs/736_cslib_omega_automata_survey_and_e3_reopen_check/summaries/01_cslib-omega-automata-survey-summary.md` - new
- `specs/736_cslib_omega_automata_survey_and_e3_reopen_check/plans/01_cslib-survey-e3-closure.md` - phase status markers only

**Verification**:
- The summary exists, follows `summary-format.md`, and names the verdict in its first section.
- Every acceptance item carries a re-run command output, not a carried-over number.
- Every hand-off item carries an explicit reason for non-action.
- `bash scripts/check-evidence-probes.sh` exits 0.
- The commit stages only this task's own artifacts (scoped staging verified by
  `git diff --staged`).

## Testing & Validation

- [ ] `bash scripts/check-evidence-probes.sh` exits 0 with the whole wired collection passing —
      run in Phase 1 (baseline), Phase 3 (after the only code-adjacent edit), and Phase 4
      (closing gate). This is acceptance item (3) and the task's own gate.
- [ ] `lake env lean specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` succeeds.
- [ ] `specs/literature-index.json` is valid JSON with 0 orphans (every `doc_id` resolving **whole**
      in the global index), 0 duplicate `doc_id`s, 0 entries missing `doc_id`, and 0 unresolvable
      source directories — acceptance item (2).
- [ ] The research report carries all four acceptance sections — acceptance item (1).
- [ ] No claim in any artifact this round rests on a description assertion rather than on
      elaboration or a recorded command output — acceptance item (4).
- [ ] `check-task-references.sh`'s unexempted count did not increase, and no flagged occurrence
      sits in a file this task touched. (The lint FAILs repo-wide on a pre-existing 198-occurrence
      baseline; the gate is non-regression, not a pass.)
- [ ] No file under `FormalSystem/Metalogic/Decidability/RaySummary/`,
      `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean`, `specs/ROADMAP.md`,
      task 711's plan, or `.claude/**` was modified — `git diff --name-only` confirms.

## Artifacts & Outputs

- `specs/736_cslib_omega_automata_survey_and_e3_reopen_check/summaries/01_cslib-omega-automata-survey-summary.md` — execution summary with the verdict and the operator hand-off list (new)
- `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` — one appended comment-only RE-AUDIT block (modified)
- `specs/literature-index.json` — new entries only if Phase 2 closes a gap (conditionally modified)
- `specs/736_cslib_omega_automata_survey_and_e3_reopen_check/plans/01_cslib-survey-e3-closure.md` — phase status markers (modified)
- Recorded gate evidence: probe-collection output and exit code, sub-index audit numbers,
  task-reference lint baseline (quoted in the summary, not a separate file)

## Rollback/Contingency

Every edit in this round is additive and small: one comment block, zero or a few JSON entries, and
two markdown files. Rollback is per-file `git revert` of the phase commit, or
`git checkout HEAD~1 -- <path>` for the one file, with no cross-file coupling to unwind.

- **If Phase 1's gate run fails** at HEAD, with no edit from this round yet applied: that is a
  pre-existing or concurrent-writer breakage, not this round's. Record it via
  `issue-record.sh`, do not attempt a repair of another task's probe, and report the failing
  entry in the summary. Phase 3 then does **not** run (it would append to a red collection);
  Phases 2 and 4 may still proceed, and the round closes `[PARTIAL]` with the blocked phase named.
- **If Phase 3's probe fails to compile** after the append: revert that one file
  (`git checkout -- specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`) and
  retry with a smaller block. If it fails twice, drop the phase, leave the probe untouched, and
  carry the re-audit to the operator as a hand-off item in Phase 4 instead — the verdict is
  already durable in the report either way.
- **If Phase 2's bridge writes a bad entry**: remove that entry from
  `specs/literature-index.json` (additive removal of the one object, never an array replacement)
  and re-run the audit. Nothing in the global corpus is deleted by this round.
- **A "no change" round is a valid terminus.** If Phase 2 closes nothing and Phase 3 is dropped,
  the round still completes: the four acceptance items were already met by research, this round
  re-verified them, and the summary says exactly that.
