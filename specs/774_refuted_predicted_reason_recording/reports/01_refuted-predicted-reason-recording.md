# Research Report: Task #774

**Task**: 774 - EVALUATE (AND BE WILLING TO DECLINE): should plan guidance require a refuted predicted REASON to be recorded distinctly from a refuted predicted OUTCOME?
**Started**: 2026-11-07T19:30:00Z
**Completed**: 2026-11-07T19:35:00Z
**Effort**: small
**Dependencies**: None
**Sources/Inputs**: - Codebase (source store at `/home/benjamin/.config/nvim/agent-system/extensions/core`), archived task 773's `issues.jsonl`, `specs/state.json`
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Conclusion: no change.** The existing `design-record defect or ambiguity` seed class in
  `context/formats/issue-log.md` already covers a predicted-reason refutation adequately, and a
  single minor-severity occurrence does not meet the recurrence bar the taxonomy's own
  Unknown-Class Tally mechanism sets for promoting `plan-accuracy` into the seed enum.
- All four grounding findings cited in the dispatch were re-verified verbatim against the live
  source store and hold exactly as stated; a fifth check (searching the entire source store for
  any existing "falsify-first" / "predicted outcome" / "both-outcomes" convention) turned up
  nothing, closing a gap the dispatch's grounding did not explicitly rule out.
- The `claim_invalidations` mechanism (`return-metadata-file.md`) does not fit this case: it is
  built to flag one task's claim as falsified **for the benefit of other tasks**, matched by
  literal `declaration_names` against *other* tasks' title/description — not to record a
  same-task divergence between a plan's predicted mechanism and what was actually measured.
- No plan-format change, no new issue-log class, and no new `.return-meta.json` field are
  warranted. This record's own reasoning is the artifact that lets the next occurrence be judged
  against precedent instead of re-litigated from scratch.

## Context & Scope

Task 773's plan was written falsify-first for its own purposes (not a documented system
convention): each Phase 2 attempt had its predicted outcome written down with both branches
pre-specified. Attempt (iii-a) confirmed the predicted *outcome* but refuted the predicted
*reason* — the plan expected an achievable-window argument positioned by residue coordinates;
the actual mechanism (`Count false false` holding the countdown at `0` through any idle
interval while `Drift` moves the next deadline freely, making every second-region length
reachable from every pending state) was stronger and simpler. The implementing dispatch recorded
this, on its own initiative, as issue-log entry `iss_1791780659461_iJw5zy`
(`class: plan-accuracy`, `severity: minor`, `resolution: null`). The exactly-one-channel rule in
`context/contracts/conclusion-stage.md` then forced this observation into a channel, producing
task 774 as a deliberately weak proposal: evaluate whether falsify-first plan guidance should
require a refuted predicted reason to be recorded distinctly from a refuted predicted outcome,
with "no change needed" stated up front as a fully acceptable outcome.

Scope here is exactly what the dispatch set: (1) read the cited entry verbatim and re-verify the
four grounding findings against the live source store; (2) decide among no-change, recording the
finding's existing home, deferring pending recurrence, or (only if genuinely justified)
introducing an explicit requirement; (3) write down the reasoning.

## Findings

### Codebase Patterns

**Cited entry, read verbatim** (`specs/archive/773_ladder_cell_index_factorization/issues.jsonl`
line 6, since task 773 has since been archived — the dispatch's path assumed the task was still
active): entry_id, timestamp, class, severity, phase, dispatch_seq, `what_happened`,
`evidence_path: null`, `resolution: null`, `suggested_channel: null` all match the dispatch's
summary exactly, word for word.

**Grounding finding 1 (re-verified, confirmed)**: `context/formats/plan-format.md`'s per-phase
required-field list is `Goal`, `Tasks`, `Timing`, `Depends on`, `Verification Tier`
(required), `Commit Mode` (optional), plus conditional `Scope Hypothesis` / `Tier Justification`
/ `Files to modify`. No predicted-outcome or predicted-reason field exists anywhere in this
document. A targeted grep for "predict", "expected outcome", "both-outcome", and "falsify"
across the file returned nothing. Task 773's both-outcomes style was that task's own authored
convention, not an instance of a documented one.

**Grounding finding 2 (re-verified, confirmed)**: every "outcome" occurrence in
`context/contracts/phase-closure.md` refers to terminal dispatch outcomes or status markers
(e.g. "those terminal outcomes count as 'closed'... only `[PARTIAL]`..."), never to plan
predictions. Not a plausible home for this requirement.

**Grounding finding 3 (re-verified, confirmed, with an added nuance)**:
`context/formats/return-metadata-file.md`'s `claim_invalidations` field exists exactly as
described — four keys (`declaration_names`, `kind: "refutation"|"supersession"`, `claim`,
`evidence_path`), consumed (read-only, advisory, not yet wired to any call site) by
`scripts/sweep-invalidated-claims.sh`. Reading its full spec surfaces why it is a **poor fit**
for task 773's finding specifically, beyond the documented precision/paraphrase caveat the
dispatch already flagged: its consumer "matches declaration names literally... against *other
tasks'* `title`/`description`" — it is a forward-pointing, cross-task mechanism for flagging that
some claim now known to be false might also appear, verbatim, in another task's framing. Task
773's case is a same-task divergence between a plan's own predicted mechanism and what its own
implementation measured, already fully resolved and recorded within that same task (the landed
probe and summary). There is no second task whose claim needs invalidating. Forcing this through
`claim_invalidations` would be a type mismatch with the field's actual purpose, not merely an
awkward fit.

**Grounding finding 4 (re-verified, confirmed)**: `context/formats/issue-log.md`'s Seed Class
Enum lists exactly 15 classes; `plan-accuracy` is not among them. The enum is explicitly open
(`scripts/issue-record.sh` warns to stderr on an unrecognized class but proceeds — it never
refuses), and the same document's Unknown-Class Tally section assigns the conclusion stage
(`context/contracts/conclusion-stage.md`, "The Unknown-Class Tally") the job of tallying
non-seed classes across tasks, with *recurrence* as the explicit criterion for promotion into the
seed list. `design-record defect or ambiguity`'s gloss — "The design record (plan, report, or
spec) was wrong, self-contradictory, or silent on a case the implementer actually hit" — reads
naturally over task 773's case: the plan (a design record) was wrong about *which* mechanism
would hold, even though it was right about the outcome. This is a defensible existing home.

**Fifth check, not explicitly requested but closing a residual gap**: a repo-wide search of the
entire source store (not just the three documents the dispatch named) for "falsify-first",
"predicted reason", "predicted outcome", and "both-outcomes"/"both outcomes" turned up zero
genuine hits — the two incidental string matches found (in `test-lean-challenge-snapshot.sh` and
`test-claude-refresh-matcher.sh`) are coincidental English usages inside unrelated test comments,
not a hidden convention. This confirms finding 1's claim at full breadth: no extension anywhere
in the loaded system (core, lean, formal, typst, literature, memory) documents a falsify-first
or predicted-outcome plan convention that task 773 was instantiating.

### External Resources

Not applicable — this is a meta/system-design question resolved entirely from the codebase's own
documented contracts; no external research was needed or performed.

## Decisions

- **No system document is edited by this task.** The existing `design-record defect or
  ambiguity` seed class in `context/formats/issue-log.md` already covers a predicted-reason
  refutation: a plan's stated mechanism being wrong, independent of whether the plan's stated
  outcome happened to survive, is naturally read as "the design record was wrong... on a case the
  implementer actually hit." No new seed class, no plan-format field, and no
  `claim_invalidations`-style mechanism is introduced.
- **`plan-accuracy` stays an unpromoted, open-vocabulary class.** Per
  `issue-log.md`'s own Extensibility Rule and the Unknown-Class Tally mechanism in
  `conclusion-stage.md`, promotion into the 15-class seed enum is recurrence-gated. One
  minor-severity, single-occurrence entry does not meet that bar; the correct action is to wait,
  not to legislate ahead of evidence. If `plan-accuracy` (or a similarly-shaped class) recurs
  across future tasks, that recurrence — not this record — is the trigger for revisiting the
  seed enum.
- **Why not introduce an explicit predicted-reason requirement**: doing so would mean
  *introducing* a plan-authoring convention (falsify-first predicted-outcome/predicted-reason
  wording is not currently documented anywhere in the system, confirmed above), not tightening an
  existing one — a materially larger, weaker-motivated change than the question's framing might
  suggest for a single minor finding that was already fully captured by the implementer's own
  initiative. The existing both-outcomes convention (where it is used, by task-local choice)
  behaved as designed: it caught the mechanism mismatch and the implementer recorded it
  unprompted. There is no gap in capability to close, only a question of taxonomy, which the
  system already has a documented, recurrence-gated process for answering.
- **Precedent for the next occurrence**: if a future task again finds a plan's predicted
  *mechanism* refuted while its predicted *outcome* holds, classify it under
  `design-record defect or ambiguity` (or `plan-accuracy` if that classification feels more
  precise — the enum is open) and let the conclusion stage's cross-task tally do its job across
  occurrences; do not route it through `claim_invalidations` (wrong shape: that field targets
  claims that could mislead *other* tasks, not same-task plan-versus-measurement divergence), and
  do not treat a single additional occurrence as sufficient grounds to add a plan-format field —
  wait for the tally to show a genuine pattern.

## Recommendations

- Take no action beyond this record. Close task 774 with the conclusion stated above.
- Carry forward the precedent in the Decisions section above (rather than a new document edit) so
  a future implementer who hits the same question again can be pointed at this task's reasoning
  instead of re-deriving it.
- If and when `plan-accuracy` (or a sibling class covering the same phenomenon) recurs enough to
  cross the conclusion stage's own promotion threshold, that future task should re-open the
  question of a seed-enum addition — not this one.

## Risks & Mitigations

- **Risk**: closing with "no change" could be read as under-delivering on a dispatched task.
  **Mitigation**: the dispatch itself states explicitly, twice, that "no change needed" is a
  fully acceptable and even expected outcome here, and warns against manufacturing a change to
  justify the record's existence. This report documents the re-verification work and the
  reasoning, which is the deliverable the dispatch actually asked for in its Scope item (3).
- **Risk**: a future, similar finding could again be routed to the wrong channel (e.g. forced
  into `claim_invalidations`) absent a visible precedent. **Mitigation**: this report's Decisions
  section states the precedent explicitly and durably in `specs/774_.../reports/01_...md`, citable
  by a future research dispatch the same way this one cited task 773's entry.

## Context Extension Recommendations

- none — this is a meta task and no context-documentation gap was identified; the existing
  documents (`plan-format.md`, `phase-closure.md`, `return-metadata-file.md`, `issue-log.md`,
  `conclusion-stage.md`) already provide everything needed to resolve this question without
  modification.

## Appendix

- Search queries used: `grep -n "iss_1791780659461_iJw5zy"` against archived task 773's
  `issues.jsonl`; targeted greps for required-field lists in `plan-format.md`; "outcome" in
  `phase-closure.md`; `claim_invalidations` section in `return-metadata-file.md`; "Seed Class
  Enum" and "Unknown-Class Tally" in `issue-log.md`; "Exactly-One-Channel Rule" and channel
  headings in `conclusion-stage.md`; repo-wide grep for "falsify-first", "predicted reason",
  "predicted outcome", "both-outcomes"/"both outcomes" across all loaded extensions.
- References: `specs/archive/773_ladder_cell_index_factorization/issues.jsonl`;
  `/home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/plan-format.md`;
  `/home/benjamin/.config/nvim/agent-system/extensions/core/context/contracts/phase-closure.md`;
  `/home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/return-metadata-file.md`;
  `/home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/issue-log.md`;
  `/home/benjamin/.config/nvim/agent-system/extensions/core/context/contracts/conclusion-stage.md`.
