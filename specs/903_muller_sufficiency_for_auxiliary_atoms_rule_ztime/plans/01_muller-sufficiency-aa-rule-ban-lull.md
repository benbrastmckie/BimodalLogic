# Implementation Plan: Task #903

- **Task**: 903 - Settle whether a deterministic Muller automaton suffices for the Auxiliary-Atoms rule and the ban/lull mechanism at ZTime, or whether Rabin or parity is genuinely needed
- **Status**: [IMPLEMENTING]
- **Effort**: 2.25 hours
- **Dependencies**: None
- **Research Inputs**: `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md`
- **Artifacts**: plans/01_muller-sufficiency-aa-rule-ban-lull.md (this file)
- **Standards**:
  - `context/formats/plan-format.md`
  - `context/standards/status-markers.md`
  - `context/standards/artifact-management.md`
  - `context/formats/summary-format.md`
  - `context/standards/git-staging-scope.md`
  - `context/contracts/territory.md`
  - `rules/state-management.md`, `rules/git-workflow.md`, `rules/pr-prohibition.md`
- **Type**: formal
- **Lean Intent**: false

## Overview

The research dispatch already delivered the task's entire stated deliverable: the one
acceptance-condition question is answered, as a split — a deterministic Muller automaton suffices
for the Auxiliary-Atoms rule, and does not suffice for the ban/lull mechanism. Nothing substantive
remains to be *found*, and by the task's own non-goals nothing may be built: no Lean source, no
`require`, no completeness claim.

What remains is to land the verdict in the records that other tasks read, and to retire the
open-question pointers that this answer closes. Three records currently assert, in their own
voices, that the acceptance-condition question is open: the re-assessment report's obstruction
(O1) and its matching Risks bullet, the completeness-programme report's ingredient row 16 and
verdict paragraph, and `specs/ROADMAP.md`'s "MSO/Rabin route" ruling, which names this task by
number as the owner of the open question. A fourth record change is a genuine *saving* rather
than a closure: obstruction (O2) is discharged for free by already-landed fork code under the
composition order the report names, so it leaves the obstruction list rather than being re-costed.

Accordingly this is a record-amendment plan, not an implementation plan in the usual sense. Its
four phases amend the two reports, narrow the ROADMAP ruling, and write the close-out record that
states explicitly which recommendations are deliberately not acted on and why. No Lean source, no
build file, no dependency declaration, and no file under `.claude/**` or in either CSLib checkout
is touched by any phase.

### Research Integration

The report is the sole substantive input, and each phase consumes a named part of it rather than
re-deriving anything:

- **Recommendation 1** supplies the replacement for the re-assessment report's (O1) parenthetical
  and the negative discharge of its matching Risks bullet. Phase 1 applies it.
- **Recommendation 2** removes (O2) from that report's obstruction list on Finding 3's ground, and
  withdraws — rather than re-files — its recommendation 6. Phase 1 applies both halves.
- **Recommendation 3** supplies the amendment to the completeness-programme report's ingredient
  row 16 and its verdict's third paragraph: row 16 must now say *why* Rabin is wanted (the AA rule
  needs only determinism; the banned list needs the pair shape), and the verdict must narrow
  "Rabin or parity" to Rabin alone on the proved `Parity.toRabin_language_eq`. Phase 2 applies it.
- **Findings 1 and 2** are the grounds every amendment cites: Finding 1 (the AA rule's interface
  is a deterministic transition table and nothing else, and both acceptance conditions lie in the
  same `{GF, FG}` Boolean fragment) and Finding 2 (the banned list is indexed by accepting pairs —
  Reynolds' `bl : T → (C × {1,…,K})*` — and §2.3's two-state counterexample shows pair-enumeration
  of a Muller family is unsound, not merely incomplete).
- **Finding 3** is the (O2) discharge: the cut product is a finite indexed union, `Muller.exists_iSup`
  already supplies it, and the composition order is union-on-the-Muller-side-then-determinize-once.
- **Finding 4's verdict** is what Phase 3 writes into the ROADMAP ruling, and what Phase 4's
  close-out states as the task's outcome.
- **Recommendations 4-7** are either CSLib-side (recommendation 4, the named `Muller.toRabinLAR`)
  or standing no-ops (5, do not re-open `require`; 6, leave P9 owning the progress-measure
  alternative; 7, file nothing resting on Muller sufficiency for the ban mechanism). Phase 4
  records each as deliberately not acted on, with its reason, rather than turning any into a task
  in this tree.

### Prior Plan Reference

No prior plan for this task. The structural precedent followed here is the re-assessment task's
own plan (`specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/plans/01_cslib-omega-automata-nogo-reassessment.md`,
`[COMPLETED]`), which solved the same shape of problem — a report-only research task whose
implementation phases are record amendments, a ROADMAP amendment, and a close-out summary. Five
calibrations are carried from it as *lessons*, not as copied phases:

1. Its Phase 1 measured that a verification criterion of the form "each anchor grep still matches
   exactly once after the edit" is **unsatisfiable** for any anchor the phase's own task list
   mandates replacing. Every phase below therefore states, per anchor, whether the anchor text is
   *kept* (count stays 1) or *replaced* (count goes to 0, with a named kept-half that must still
   count 1). This is the single most reusable lesson in that plan's notes.
2. Its Phase 3 measured `test-roadmap-generation.sh` exiting **2 (environment)** in this tree,
   because it resolves its subject in `source-store` mode with no deploy-tree fallback and never
   reads `specs/ROADMAP.md`. Phase 3 below names the covering substitute
   (`roadmap-integration.sh --regenerate --dry-run` plus `--print`) up front rather than
   discovering it.
3. Its Phase 1 hit a process deviation — the `[IN PROGRESS]` marker was not set before the first
   edit. Every phase below sets the marker first.
4. Its Phase 4 measured `verify-deploy.sh` at **15 checks, 0 failures**, with 22 SKIPs all reading
   "is a deploy consumer, not the source store" and one pre-existing WARN
   (`lean still declares routing_hard/routing_agents_hard`). Phase 4 below expects the same shape
   and will not read a pre-existing WARN as this task's regression.
5. Its row-16 amendment discovered the ingredient table has **four** columns (`#`, `Ingredient`,
   `Status`, `Evidence / proposal`), not three, and that the overturned ground lives in the fourth.
   Phase 2 below names the fourth cell directly.

Effort calibration: that task's four phases of the same character came in at 2.75 hours with a
task-filing phase. This plan has no filing phase — recommendation 4 is CSLib-side and
recommendation 7 forbids filing anything resting on the positive half — so it carries the same
four-phase shape at 2.25 hours.

### Roadmap Alignment

No `roadmap_path` and no `roadmap_flag` were supplied in this dispatch, so the roadmap-review and
roadmap-update phases a `--roadmap` run would mandate are not present. `specs/ROADMAP.md`
nevertheless exists (433 lines, read at plan time) and carries **a pointer naming this task as the
owner of the question this task has now answered**, in the "MSO/Rabin route reaches ZTime only"
bullet of `## Rulings in force`:

> "The open acceptance-condition question (whether a deterministic Muller automaton suffices, or
> Rabin/parity is genuinely needed) is owned by **903**."

That sentence (lines 119-120 at plan time, confirmed present exactly once) is the only ROADMAP
occurrence of this task's number. Phase 3 replaces it with the settled split verdict. It is a
*closure* amendment, not a status change: the bullet's surrounding ruling — that the MSO/Rabin
route stays a paper result and does not close `Decidable (PlusValidZTime φ)` constructively —
stands untouched, and no roadmap item is marked complete by this plan.

One nearby ROADMAP passage is deliberately **not** amended. The "MSO decidability formalization is
refused outright" bullet (lines 326-337 at plan time) says "ω-automata and determinization of
ω-automata are landed in CSLib — the closure lattice with complementation upstream, McNaughton
determinization to Muller in the local fork". That remains true as written: determinization *to
Muller* is landed. This task's finding is that the landed determinization is not the one the ban
mechanism consumes, which sharpens the *architecture's* gap and not that bullet's claim about
CSLib's inventory. Amending it would overstate the finding's reach. Recorded here so the omission
does not read as an oversight.

## Goals & Non-Goals

**Goals**:

- The re-assessment report's (O1) states the settled split (a DMA suffices for the AA rule, which
  carries no acceptance condition; it does not suffice for the ban/lull mechanism, whose banned
  list is indexed by accepting pairs), and names `Muller.toRabin_exists` as load-bearing and as
  the single highest-value `proof_wanted` in either tree. Its matching Risks bullet records that
  it was discharged *negatively*, and its two "settle (O1) first" recommendations record that the
  settlement has happened and where.
- (O2) is gone from that report's obstruction list, replaced by the discharge and its composition
  order, with its 100-150-line recommendation withdrawn rather than re-filed.
- The completeness-programme report's ingredient row 16 and verdict paragraph say *why* Rabin is
  wanted and narrow "Rabin or parity" to Rabin alone, with the NO-GO outcome preserved verbatim.
- `specs/ROADMAP.md`'s open-question pointer naming this task is replaced by the settled verdict,
  with the surrounding ruling left standing.
- Every amendment is dated, cites this task's report, and preserves the outcome of the record it
  amends — grounds change, verdicts do not.
- A close-out record states what was amended and — explicitly, so that none reads as an oversight
  — that no `require` was added, no PR opened, no CSLib-side lemma written, no task filed on the
  positive half, no `.claude/` redeploy run, and no Lean source touched.

**Non-Goals**:

- No change under `FormalSystem/` or `Tests/`, and no new Lean source anywhere. This plan declares
  `Lean Intent: false` and writes no `.lean` file. No Lean process is started by any phase.
- No edit to `lakefile.toml` or `lake-manifest.json`, and no `require` on CSLib in any form. The
  report's recommendation 5 is that the standing refusal is *strengthened*; a standing refusal is
  recorded, never executed.
- No PR, no push, no `gh`/`glab` write operation. Recommendation 4's named `Muller.toRabinLAR`
  construction belongs in `~/Projects/cslib` against `leanprover/cslib`;
  `rules/pr-prohibition.md` bars an agent from it unconditionally, and it is out of this task's
  scope besides.
- No edit in `~/Projects/cslib` or `~/Projects/cslib-pr648`, and no Lean lemma written anywhere —
  not `Muller.toRabinLAR`, not `Muller.compl`, not `Muller.inter`, not `Rabin.union`. The report's
  §3 shows four of those are off the critical path and recommendation 4 scopes the fifth to CSLib.
- No new task filed in this tree. Recommendation 7 forbids filing anything resting on Muller
  sufficiency for the ban mechanism; recommendation 4's item is CSLib-side; recommendation 6
  leaves the progress-measure alternative with the completeness-programme report's P9, where it
  already sits. The close-out records each as deliberately not filed.
- No amendment to any task *description* in `specs/state.json`. Task 901 (the two-sided Reynolds
  engine paper proof) already depends on this task, so it will read this report by construction;
  rewriting its description is outside this plan's scope, as the precedent task recorded for the
  same reason.
- No completeness claim, and no amendment that could be read as lifting the NO-GO or the T3 GO.
  The report's §4 is explicit that nothing in it bears on either.
- No redeploy of `.claude/`. The dispatch reports the deployed tree stale for six extensions and
  names `deploy-headless.sh` as the remedy; that is a whole-tree regeneration, is its own task,
  and no phase here lists the reserved whole-tree sentinel because no phase regenerates the tree.
  Measured at plan time: no `agent-system/` tree exists in this repository and
  `.claude-extensions.json` carries no `source_dir` key, so the warning is unactionable here —
  the same condition the precedent task measured. Handed forward, not acted on.
- No hand-authored file under `.claude/**`, per `rules/source-store-deploy-boundary.md`. No phase
  below has a `.claude/**` target, so the rule is satisfied vacuously rather than by exception.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| An amendment reads as lifting the NO-GO on a Lean proof, or the GO on T3 as a paper programme | H | M | Every amendment replaces a *ground* and preserves the outcome sentence verbatim. Phase 2's verification reads back that `**NO-GO on a Lean proof of T1, T2 or T3 today — a located obstruction.**` is byte-identical and that the executive summary's GO/NO-GO verdict string is byte-identical; Phase 1's reads back that the (O1)-(O4) obstruction frame still stands with three components. A grep for lifting language (`NO-GO is lifted`, `completeness is now formalizable`, `completeness proof is now available`) must return 0 in both reports. |
| The (O2) discharge is over-read as a general saving, when it depends on a named composition order and on `PT(w₀)` being finite | H | M | The replacement text must state both dependencies in the same sentence as the discharge: union-on-the-Muller-side-then-determinize-once, and `PT(w₀)` finite carried from the completeness-programme report §2.4 and not re-derived. The report's own Risks section flags both; Phase 1's verification requires the words "union" and "finite" in the replacement. |
| The (O1) amendment is read as making the *whole* question negative, erasing the positive AA-rule half | M | M | The replacement is a split by construction and must name both halves in order. Phase 1's verification requires the amended (O1) to contain both "Auxiliary-Atoms" and "ban" and to attribute the pair-indexing to Reynolds' `bl : T → (C × {1,…,K})*`. |
| `test-roadmap-generation.sh` exits 2 (environment) rather than passing, as measured in this tree | M | H | Carried from the precedent task's measurement: the suite resolves its subject in `source-store` mode with no deploy-tree fallback and never reads `specs/ROADMAP.md`. Phase 3 names the covering substitute (`roadmap-integration.sh --regenerate --dry-run` exit 0 and `--print` exit 0 against the amended file) in its verification criteria, and records the outcome as a `#### Reasoned Exclusions` row if it fires. |
| The ROADMAP amendment lands inside the generated coverage appendix and is destroyed by the next `roadmap-integration.sh --regenerate` | H | L | The amendment target is at lines 119-120, in `## Rulings in force`, far above `## Run these next` (line 145) and above the run-order section's `**Coverage appendix (uncovered tasks)**:` marker (line 177). That marker string occurs twice at plan time — the live one at 177 and a prose mention at 416 — so Phase 3 locates it by section, not by first match, and verifies no hunk lands at or after line 177. |
| A sibling task's uncommitted hunks are swept into a commit on this shared tree | H | M | Task 904 is dispatched this same cycle. Its declared `file_scope` is five `agent-system/extensions/**` paths, disjoint from every path below, and `agent-system/` does not currently exist. Each phase re-reads its target immediately before editing, reviews `git status --short` and `git diff --staged` before committing, and stages an explicit file list — never a directory or glob pathspec. No phase runs `git-snapshot.sh` in its reverting default mode. |
| An amendment anchor has moved or vanished since plan time | M | L | All fourteen anchors were confirmed present **exactly once** at plan time by fixed-string grep (`grep -cF`), with line numbers recorded per phase. Each phase re-measures before editing and, on a count mismatch, re-locates by content and records the discrepancy in its notes rather than editing blind. |
| The close-out is read as having filed the CSLib-side item | M | L | Phase 4's deliberately-not-done paragraph names it explicitly, with recommendation 4's narrowing preserved (a *named* `Muller.toRabinLAR : Muller State Symbol → Rabin (LAR State) Symbol` with a `language_eq`, not the existential `Muller.toRabin_exists` as currently stated, because (O3) is alive precisely because an `∃ (State : Type)` cannot be written into `θ_f`). |
| The full gate set is unavailable in this dispatch | L | M | Phase 4 follows a `## Batch Gate Deferral` directive if the dispatch carries one, recording the deferral in the summary's Verification section rather than claiming a gate run that did not happen. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel. Phases 1, 2 and 3 touch pairwise disjoint
files — the re-assessment report plus its summary, the completeness-programme report, and
`specs/ROADMAP.md` respectively — and none consumes another's output, since all three cite this
task's report rather than each other. Phase 4 is the terminal node and depends on all three.

### Phase 1: Settle (O1) and Discharge (O2) in the Re-Assessment Report [COMPLETED]

**Goal**: `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md`
states the settled split at (O1), records (O2) as discharged rather than open, and no longer
recommends settling or filing either — with the (O1)/(O3)/(O4) obstruction frame and the
"do not `require` anything now" conclusion both preserved.

**Tasks**:
- [x] Set this phase's heading to `[IN PROGRESS]` before the first edit. *(completed)*
- [x] Re-read the target immediately before editing (a sibling is active on this tree) and
  confirm each anchor still matches exactly once with `grep -cF`. Plan-time counts, all 1, in a
  398-line file: *(completed: all seven anchors re-measured at 1 immediately before editing,
  matching plan-time counts exactly; see Phase 1 notes below)*

  | Anchor (fixed string) | Line | Disposition |
  |---|---|---|
  | `so this may be a presentational preference rather than a real need` | 225 | **replaced** (count → 0) |
  | `**(O2) The indexed conjunctive product with a nameable initial state is absent from both trees.**` | 227 | **replaced** (count → 0) |
  | `**Settle (O1) on paper first, before any dependency decision.**` | 274 | **replaced** (count → 0) |
  | `**Settle (O1) on paper before any dependency decision**` | 284 | **replaced** (count → 0) |
  | `File the ≈100-150-line (O2) closure lemma as a CSLib-side item` | 289 | **replaced** (count → 0) |
  | `Risk: (O1) may be a presentational requirement rather than a real one` | 305 | **kept**, with the discharge appended (count stays 1) |
  | `## Executive Summary` | 26 | **kept**; the new dated note goes immediately under it |

  On a count mismatch, re-locate by content and record the discrepancy in the Phase 1 notes rather
  than editing blind. If an anchor is gone entirely, skip that edit and say so in the notes.
- [x] Replace (O1)'s closing parenthetical — everything from "*Unless* a DMA suffices" to
  "the cheapest thing anyone could do to this verdict." — with the settled split, per the report's
  recommendation 1. The replacement must: state that a DMA **suffices for the Auxiliary-Atoms
  rule**, which carries no acceptance condition at all; state that it does **not suffice for the
  ban/lull mechanism**, whose banned list is indexed by the automaton's accepting pairs, citing
  Reynolds 2001 §12's `bl : T → (C × {1,…,K})*`; and conclude that `Muller.toRabin_exists` is
  therefore load-bearing and is the single highest-value `proof_wanted` in either tree. Keep
  (O1)'s opening sentence and its cost figures byte-identical. *(completed)*
- [x] Narrow (O1)'s scope from "Rabin or parity" to Rabin alone where it names the blocking
  target, on `Parity.toRabin_language_eq` being proved: the ban mechanism consumes Rabin, so
  `Rabin.toParity_exists` (`:89`) is off the critical path. Leave (O1)'s inventory sentence (both
  `proof_wanted`s named, with their cost docstrings) intact — it is a true inventory statement —
  and add the off-the-critical-path note rather than deleting either name. *(completed: folded into
  the same (O1) edit as one paragraph)*
- [x] Replace the (O2) bullet with the discharge, per recommendation 2. The replacement must name
  all three of: that the cut product is a finite indexed **union** over `PT(w₀)` rather than an
  intersection; that `Muller.exists_iSup` (fork `DA/MullerClosure.lean:125`, proved) already
  supplies exactly that, so no new code is needed; and the composition order that makes this work
  — union on the Muller side first, determinize **once** afterwards. State that `PT(w₀)` finite is
  carried from the completeness-programme report §2.4 and not re-derived. Renumber nothing: keep
  the bullet in place as a recorded discharge so that (O3) and (O4) keep their labels, and say in
  the bullet itself that it is no longer an obstruction. *(completed)*
- [x] Amend the Risks bullet at line 305 in place, keeping its anchor sentence and appending the
  negative discharge: the expressibility argument the risk rested on is **sound** and simply does
  not reach the banned list, so (O1) does not vanish — it is preserved with its ground sharpened.
  The risk is discharged negatively, and the bullet must say so in those terms. *(completed)*
- [x] Replace both "settle (O1) first" recommendations (Finding 4b recommendation 1 at line 274,
  and Recommendations item 1 at line 284) with a record that the settlement has happened, naming
  this task's report as where, and carrying the split verdict in one sentence each. Do not delete
  either item — a recommendation that has been carried out is part of the record. Preserve
  recommendation 3 / Finding 4b recommendation 3 ("do not `require` anything now") byte-identical;
  this task's report strengthens it on a second, independent ground, which the amendment may note
  but must not weaken. *(completed; "Do not `require` anything now" confirmed byte-identical, count
  unchanged at 1)*
- [x] Replace recommendation 6 (line 289) with its **withdrawal**, per recommendation 2's explicit
  "withdrawn, not re-filed": the 100-150-line `Rabin.union` / `union_language_eq` plus
  `Rabin.exists_iSup` item is not needed at all under the union-first ordering, so it is withdrawn
  rather than re-costed or re-filed elsewhere. Note in the same item that `Muller.compl` and
  `Muller.inter` are cheap but off the critical path and are deliberately not filed either.
  *(completed)*
- [x] Add one dated amendment note immediately under the report's `## Executive Summary` heading,
  in the same form the completeness-programme report already carries:
  `**Amended by** specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md, 2026-11-09:`
  followed by two or three sentences stating that (O1) is settled as a split and preserved with a
  sharpened ground, that (O2) is discharged for free under a named composition order, and that the
  report's outcome — a located obstruction, four components reduced to three, no `require` — is
  otherwise unchanged. One note, not one per edit site. *(completed)*
- [x] Add the same dated amendment note under `## Executive Summary` (line 47 at plan time) of
  `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/summaries/01_cslib-omega-automata-nogo-reassessment-summary.md`,
  pointing at this task's report for the (O1) settlement and the (O2) discharge. Do **not** rewrite
  that summary's body: it is a completed task's close-out narrative, and a pointer is the right
  weight for a downstream finding. Its "Not filed, by decision" row for the (O2) lemma is now a
  withdrawal rather than a deferral, and the note says so in one clause. *(deviation: altered — the
  summary carries no `## Executive Summary` heading at all; that is a report-format heading and
  this is a summary-format document whose top section is `## Overview`. The line-47 text the plan
  cites is a prose mention of report 879's heading, not a heading in this file. The note was added
  immediately under this file's own `## Overview` heading instead, which is the structurally
  equivalent top-of-document anchor; see Phase 1 notes)*
- [x] Read the amended report back and confirm: the obstruction frame still names (O1), (O3) and
  (O4) as live; the "do not `require` anything now" conclusion is byte-identical; a grep for
  lifting language (`NO-GO is lifted`, `completeness is now formalizable`,
  `completeness proof is now available`) returns 0; and `git diff` shows no hunk outside the seven
  anchor regions and the two new notes. *(completed: all confirmed; see Phase 1 notes for the
  hunk-count discrepancy)*
- [x] Record an issue-log entry (`issue-record.sh --kind issue|win --phase implement
  --dispatch-seq <this dispatch's seq>`) naming any anchor whose count differed, or a `win`
  attesting that all seven matched once. *(completed)*
- [x] After `git status --short` confirms no sibling's uncommitted hunks are mixed in, commit the
  amended report, the amended summary, and this plan by explicit path
  (`git-commit-phase.sh`, or `git-commit-scoped.sh ... -- <paths>`); never a directory or glob
  pathspec. *(completed)*
- [x] Set this phase's heading to `[COMPLETED]`. *(completed)*

**Phase 1 notes**:
- All seven anchors re-measured immediately before editing at the exact plan-time counts (all 1);
  no discrepancy against the disposition table.
- (O1) and (O2) post-edit checks: amended (O1) contains `Auxiliary-Atoms`, `ban`,
  `bl : T → (C × {1,…,K})*`, and `Muller.toRabin_exists`; amended (O2) contains `union`, `finite`,
  and `Muller.exists_iSup`. `grep -cF 'Do not \`require\` anything now'` unchanged at 1; obstruction
  frame still names (O1), (O3), (O4) live; lifting-language grep returns 0 in all three strings.
- **Hunk-count deviation from the Scope Hypothesis**: `git diff -U0` shows **7** hunks in the
  report, not the anticipated 8. The (O1) parenthetical replacement and the (O1) scope-narrowing
  edit were authored as one contiguous paragraph edit (both land inside the same sentence run with
  no unchanged line between them), so they collapse into a single diff hunk rather than two. All
  seven anchor-table dispositions are nonetheless satisfied exactly as specified; this is a diff-
  mechanics artifact, not a missed edit. The summary shows 1 hunk as expected.
- **Anchor-location deviation (summary file)**: see the altered-task entry above — the dated note
  in `specs/902_.../summaries/01_cslib-omega-automata-nogo-reassessment-summary.md` landed under
  `## Overview`, not `## Executive Summary` (which does not exist in that file).
- `bash .claude/scripts/validate-artifact.sh <report> report` and `... <summary> summary` both exit
  0.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for both amendment targets (run at plan time over each path), so no suite covers either; both lie entirely under `specs/**` (sub-case (a)) and are `report` and `summary` artifacts, so the covering checks are `bash .claude/scripts/validate-artifact.sh <report-path> report` and `... <summary-path> summary` each exiting 0, together with the `prose` row's diff read-through confirming every hunk is one of the seven anchor amendments or one of the two new dated notes.

**Scope Hypothesis**: exactly three files change in this phase, and within the re-assessment report exactly eight hunks appear — seven in-place amendments at the anchors tabled above plus one new dated note under `## Executive Summary` — with exactly one hunk in the summary. Anchor line numbers at plan time: 225, 227, 274, 284, 289, 305, 26 in a 398-line report, and 47 in the summary; re-measure with the `grep -cF` table rather than trusting these. Confirm at implementation time by `git diff -U0 -- <report>` showing eight hunks and `git diff -U0 -- <summary>` showing one; if an anchor is absent, the count is lower and the Phase 1 notes say which and why.

**Files to modify**:
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md` - (O1)'s parenthetical replaced by the settled split and narrowed to Rabin; the (O2) bullet replaced by its discharge; the two "settle (O1) first" recommendations replaced by the settlement record; recommendation 6 withdrawn; the Risks bullet discharged negatively in place; one new dated amendment note under `## Executive Summary`
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/summaries/01_cslib-omega-automata-nogo-reassessment-summary.md` - one new dated amendment note under `## Executive Summary`, pointing at this task's report; body otherwise untouched
- `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/plans/01_muller-sufficiency-aa-rule-ban-lull.md` - Phase 1 notes: the seven anchor counts measured before and after

**Verification**:
- Each **replaced** anchor counts 0 after the edit and each **kept** anchor counts 1, exactly as the disposition column states; any deviation is recorded in the Phase 1 notes by name.
- The amended (O1) contains all of: `Auxiliary-Atoms`, `ban`, `bl : T → (C × {1,…,K})*`, and `Muller.toRabin_exists`.
- The replacement (O2) text contains the words `union` and `finite` and names `Muller.exists_iSup`.
- `bash .claude/scripts/validate-artifact.sh specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md report` exits 0.
- `bash .claude/scripts/validate-artifact.sh specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/summaries/01_cslib-omega-automata-nogo-reassessment-summary.md summary` exits 0.
- `git diff -U0` shows exactly eight hunks in the report and one in the summary.
- `grep -cF 'Do not \`require\` anything now' <report>` is unchanged from its pre-edit value, and the obstruction frame still names (O1), (O3) and (O4) as live.
- A grep for the three lifting-language strings returns 0 in the amended report.
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty.
- `git diff --staged --name-only` names only the three files above.

---

### Phase 2: Name the Ban/Lull Mechanism as the Consumer That Forces Rabin [COMPLETED]

**Goal**: `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md`
states *why* Rabin is wanted at its ingredient row 16 and its verdict paragraph, narrows
"Rabin or parity" to Rabin alone, and drops (O2) from its restatement of the obstruction list —
with the NO-GO outcome and the T3 GO both preserved byte-identical.

**Tasks**:
- [x] Set this phase's heading to `[IN PROGRESS]` before the first edit. *(completed)*
- [x] Re-read the target immediately before editing and confirm each anchor still matches exactly
  once with `grep -cF`. Plan-time counts, all 1, in a 288-line file: *(completed: all four anchors
  re-measured at 1, matching plan-time counts exactly)*

  | Anchor (fixed string) | Line | Disposition |
  |---|---|---|
  | `` Determinization to Rabin or parity is `proof_wanted` even in the fork, the indexed conjunctive product is absent from both trees `` | 200 | **replaced** (count → 0); row 16's fourth cell |
  | `(O2) the indexed conjunctive product with a nameable initial state is absent from both CSLib trees, costed at 100-150 lines` | 223 | **replaced** (count → 0); the NO-GO verdict paragraph |
  | `the indexed conjunctive product absent from both CSLib trees at ≈100-150 lines` | 35 | **replaced** (count → 0); the executive-summary deliverable-4 bullet |
  | `**NO-GO on a Lean proof of T1, T2 or T3 today — a located obstruction.**` | 223 | **kept** byte-identical (count stays 1) |

  On a count mismatch, re-locate by content and record the discrepancy in the Phase 2 notes rather
  than editing blind.
- [x] Amend ingredient row 16's **fourth** cell (`Evidence / proposal` — the table has four
  columns `#`, `Ingredient`, `Status`, `Evidence / proposal`, and the overturned ground lives in
  the fourth, as the precedent task measured), per recommendation 3. The amended cell must say:
  the Auxiliary-Atoms rule needs only **determinism**, because it carries no acceptance condition
  (so the fork's landed `IsRegular.iff_da_muller` is sufficient for the rule itself); the ban/lull
  mechanism needs the **pair shape**, because Reynolds' banned list is indexed by the automaton's
  accepting pairs; so determinization to **Rabin** (not "Rabin or parity") is the load-bearing
  gap, and `Muller.toRabin_exists` is its single named target. Drop the "indexed conjunctive
  product ... (≈100-150 lines to add)" clause, which is discharged. Keep the row's first three
  cells byte-identical — in particular the `Status` cell `paper (held: Safra/Piterman in corpus)`,
  since the ingredient remains a paper-level step — and keep the table's pipe structure intact
  (the replacement must not introduce an unescaped `|`). *(completed)*
- [x] In the NO-GO verdict paragraph (line 223), amend the (O1)-(O4) enumeration: (O1) narrows to
  determinization **to Rabin** being `proof_wanted` even in the local fork, with the ban/lull
  mechanism named as the consumer that forces the pair shape; (O2) is removed from the enumeration
  and replaced by one clause recording that it is discharged by `Muller.exists_iSup` under a
  union-first composition order; (O3) and (O4) stay byte-identical. The paragraph's opening
  sentence stays byte-identical, and so does its closing sentence about the progress-measure
  replacement being named in P9. *(completed)*
- [x] Amend the executive-summary deliverable-4 bullet (line 35) the same way and no further:
  narrow its "determinization to Rabin or parity `proof_wanted` even in the local CSLib fork" to
  Rabin alone, and replace its (O2) clause with the discharge. The bullet's GO/NO-GO verdict
  string — `GO for T3 as a staged paper programme with cheap Lean ingredients landing now; NO-GO
  on T1 as stated; NO-GO on a Lean proof of any of T1-T3 today` — stays byte-identical, and so
  does its "T1 is neither reached nor refuted" sentence. *(completed; both confirmed byte-identical)*
- [x] Add one dated amendment note immediately under the report's existing `**Amended by**` note
  (line 28 at plan time), in the same form:
  `**Amended by** specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md, 2026-11-09:`
  followed by two or three sentences stating that the acceptance-condition question is settled as
  a split, that the ban/lull mechanism is the consumer that forces the pair shape, that (O2) is
  discharged, and that the NO-GO and the T3 GO are both unchanged. Do not disturb the existing
  note; this is a second, separately dated amendment note, not a rewrite of the first. *(completed;
  the existing note is untouched, confirmed by `**Amended by**` count = 2)*
- [x] Leave ingredient **row 8** (the full-product lemma at the cut) byte-identical. It is this
  repository's own TaskFrame-semantics obligation, nothing in this task's report touches it, and
  the precedent task already recorded it as deliberately unchanged. Verify this explicitly rather
  than assuming it. *(completed: `git diff -U0` shows no hunk on the row-8 line)*
- [x] Read the amended file back and confirm: `NO-GO on a Lean proof` still occurs the same number
  of times as before the edit; no sentence states or implies that T1 is refuted or that a Lean
  completeness proof is available; row 8 is byte-identical; and `git diff` shows no hunk outside
  the three anchor regions and the new amendment note. *(completed: count unchanged at 2; 4 hunks
  total — row 16, the NO-GO paragraph, the exec-summary bullet, the new note)*
- [x] Record an issue-log entry (`win` or `issue`) for this phase, or attest in the Phase 2 notes
  that nothing arose. *(completed: win recorded — all four anchors matched on first measurement)*
- [x] After `git status --short` confirms no sibling's uncommitted hunks are mixed in, commit the
  amended report and this plan by explicit path; never a directory or glob pathspec. *(completed)*
- [x] Set this phase's heading to `[COMPLETED]`. *(completed)*

**Phase 2 notes**: All four anchors re-measured immediately before editing at the exact
plan-time counts (all 1); no discrepancy against the disposition table. Post-edit checks: row
16's fourth cell contains `Auxiliary-Atoms`, `ban`, `Rabin`, `Muller.toRabin_exists`, and does not
contain `100-150`; `NO-GO on a Lean proof` count unchanged (2 before and after); the deliverable-4
GO/NO-GO verdict string and the "T1 is neither reached nor refuted" sentence are byte-identical;
row 8 is byte-identical (no hunk at that line); the report now carries two `**Amended by**` notes.
`git diff -U0` shows exactly 4 hunks, matching the Scope Hypothesis exactly.
`bash .claude/scripts/validate-artifact.sh <report> report` exits 0.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for the amendment target (run at plan time over that path), so no suite covers it; the path lies entirely under `specs/**` (sub-case (a)) and is a `report` artifact, so the covering check is `bash .claude/scripts/validate-artifact.sh specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md report` exiting 0, together with the `prose` row's diff read-through confirming every hunk is one of the three anchor amendments or the single new dated note.

**Scope Hypothesis**: exactly two files change in this phase, and within the completeness-programme report exactly four hunks appear — three in-place amendments (row 16's fourth cell, the NO-GO verdict paragraph's (O1)/(O2) clauses, the executive-summary deliverable-4 bullet) plus one new dated amendment note under the existing one. Anchor line numbers at plan time: 200, 223, 35 and the note site 28, in a 288-line file; re-measure with the `grep -cF` table rather than trusting these. Confirm at implementation time by `git diff -U0 -- <report>` showing four hunks and no more; if an anchor is absent, the count is lower and the Phase 2 notes say which and why.

**Files to modify**:
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` - ingredient row 16's fourth cell, the NO-GO verdict paragraph's (O1)/(O2) clauses, the executive-summary deliverable-4 bullet, plus one new dated amendment note under the existing one; row 8 deliberately untouched
- `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/plans/01_muller-sufficiency-aa-rule-ban-lull.md` - Phase 2 notes: the four anchor counts measured before and after

**Verification**:
- Each **replaced** anchor counts 0 after the edit and the **kept** NO-GO opening sentence counts 1, exactly as the disposition column states.
- The amended row-16 cell contains all of: `Auxiliary-Atoms`, `ban`, `Rabin`, `Muller.toRabin_exists`; and does **not** contain `100-150`.
- `bash .claude/scripts/validate-artifact.sh specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md report` exits 0.
- `git diff -U0 -- <report>` shows exactly four hunks.
- `grep -c 'NO-GO on a Lean proof' <report>` is unchanged from its pre-edit value, and the deliverable-4 GO/NO-GO verdict string is byte-identical.
- Ingredient row 8 is byte-identical to its pre-edit text (confirmed by `git diff` showing no hunk at that row).
- The report's `**Amended by**` notes number two after the edit, each with its own date and source.
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty.
- `git diff --staged --name-only` names only the two files above.

---

### Phase 3: Retire the ROADMAP's Open-Question Pointer [COMPLETED WITH EXCLUSIONS]

**Goal**: `specs/ROADMAP.md`'s "MSO/Rabin route reaches ZTime only" ruling carries the settled
split verdict in place of the open-question pointer that names this task, with the ruling itself
— that the route stays a paper result and does not close `Decidable (PlusValidZTime φ)`
constructively — left standing.

**Tasks**:
- [x] Set this phase's heading to `[IN PROGRESS]` before the first edit. *(completed)*
- [x] Re-read `specs/ROADMAP.md` immediately before editing and confirm with `grep -cF`. Plan-time
  counts in a 433-line file: *(completed: all anchors re-measured at exact plan-time counts)*

  | Anchor (fixed string) | Count | Line | Disposition |
  |---|---|---|---|
  | `The open acceptance-condition question (whether a` | 1 | 119 | **replaced** (count → 0) |
  | `is owned by **903**` | 1 | 120 | **replaced** (count → 0) |
  | `**Coverage appendix (uncovered tasks)**:` | 2 | 177, 416 | **untouched**; 177 is the live marker in `## Run these next`, 416 a prose mention in `## Maintenance` |

  On a count mismatch, re-locate by content and record the discrepancy in the Phase 3 notes.
- [x] Replace the two-line open-question sentence with the settled verdict, in one or two
  sentences inside the same bullet: the acceptance-condition question is **settled as a split** —
  a deterministic Muller automaton suffices for the Auxiliary-Atoms rule, which carries no
  acceptance condition, and does **not** suffice for the ban/lull mechanism, whose banned list is
  indexed by the automaton's accepting pairs — so `Muller.toRabin_exists` is load-bearing and the
  fork's landed `IsRegular.iff_da_muller` is **not** the determinization the architecture consumes.
  Cite this task's report path. The bullet's following sentence — `It does **not** close
  \`Decidable (PlusValidZTime φ)\` constructively, which is still Stage 1's aim.` — stays
  byte-identical, as does everything from `**878 made the paper argument a proof** …` onward.
  *(completed; following sentence confirmed byte-identical by direct view)*
- [x] Do **not** amend the "MSO decidability formalization is refused outright" bullet (lines
  326-337 at plan time). Its claim that "ω-automata and determinization of ω-automata are landed
  in CSLib — … McNaughton determinization to Muller in the local fork" remains true as written;
  this task's finding sharpens the *architecture's* gap, not CSLib's inventory. Verify explicitly
  that `git diff` shows no hunk in that bullet, so the omission is a measured decision rather than
  an oversight. *(completed: confirmed no hunk there)*
- [x] Confirm the amendment lands in the hand-authored body above the run-order section: `git diff
  -U0 -- specs/ROADMAP.md` shows no hunk at or after the live `**Coverage appendix (uncovered
  tasks)**:` marker (line 177 at plan time), and no hunk inside `## Run these next` at all.
  *(completed: single hunk at line 119, well above both)*
- [x] Read the amended bullet back and confirm it still contains the word `refused` or its ruling
  equivalent, still describes the MSO/Rabin route as reaching ZTime only and staying a paper
  result, and contains no language that could be read as closing `Decidable (PlusValidZTime φ)`.
  *(completed: "step 5 is refused outright" retained unchanged earlier in the same bullet)*
- [x] Record an issue-log entry (`win` or `issue`) for this phase, or attest in the Phase 3 notes
  that nothing arose. *(completed)*
- [x] After `git status --short` confirms no sibling's uncommitted hunks are mixed in, commit
  `specs/ROADMAP.md` and this plan by explicit path; never a directory or glob pathspec.
  *(completed)*
- [x] Set this phase's heading to `[COMPLETED]`. *(completed)*

**Phase 3 notes**: Both replaced anchors confirmed at 0 after the edit (`is owned by **903**`
returns 0 across the whole file); the untouched coverage-appendix marker still counts 2. The
amended bullet contains `Auxiliary-Atoms`, `ban`, `Muller.toRabin_exists`, and this task's report
path. `git diff -U0 -- specs/ROADMAP.md` shows exactly 1 hunk, at line 119, well above both the
live coverage-appendix marker (177) and `## Run these next` (145). `bash
.claude/scripts/tests/run-all.sh --only test-engine-written-state-paths-lib.sh,test-roadmap-generation.sh`
ran: `test-engine-written-state-paths-lib.sh` passed; `test-roadmap-generation.sh` exited
non-zero for the environment reason named in Risks (`roadmap-integration.sh not found
(mode=source-store)` — this tree has no `agent-system/` and no `source_dir` key in
`.claude-extensions.json`, so the suite never reaches `specs/ROADMAP.md`). Recorded as a Reasoned
Exclusion below; substituted `bash .claude/scripts/roadmap-integration.sh --regenerate --dry-run`
(exit 0) and `bash .claude/scripts/roadmap-integration.sh --print` (exit 0), both run against the
amended file — the only diff either produces is in the generated coverage appendix (task 903 now
absorbed into the appendix's uncovered-task list, which is expected regeneration churn unrelated
to this phase's hand-authored edit), confirming the hand-authored body round-trips cleanly.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|---|---|---|
| `test-roadmap-generation.sh` (half of the Phase 3 verification tier) | The suite resolves its subject in `source-store` mode with no deploy-tree fallback; this tree has no `agent-system/` tree and `.claude-extensions.json` carries no `source_dir` key, so the suite can never read `specs/ROADMAP.md` here regardless of this phase's edit. Carried from the precedent task's (902) identical measurement. | `ERROR: roadmap-integration.sh not found (mode=source-store): /home/benjamin/Projects/BimodalLogic/agent-system/extensions/core/scripts/roadmap-integration.sh`; substituted `roadmap-integration.sh --regenerate --dry-run` and `--print`, both exit 0 against the amended file. |

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select specs/ROADMAP.md` returns `test-engine-written-state-paths-lib.sh,test-roadmap-generation.sh` (run at plan time), so the covering check is `bash .claude/scripts/tests/run-all.sh --only test-engine-written-state-paths-lib.sh,test-roadmap-generation.sh` with its exit status read — confirming the generator still round-trips the hand-authored body — together with the `prose` row's diff read-through confirming every hunk is the one sentence-level amendment above the coverage-appendix marker.

**Scope Hypothesis**: `specs/ROADMAP.md` is the only amendment target in this phase, and within it exactly one or two hunks appear (the replaced two-line sentence, counted as one hunk if contiguous), all inside the "MSO/Rabin route reaches ZTime only" bullet of `## Rulings in force`. At plan time the file is 433 lines, the anchor spans lines 119-120, `## Run these next` begins at line 145 and the live coverage-appendix marker is at line 177; re-measure with the `grep -cF` table before editing. Confirm by `git diff -U0 -- specs/ROADMAP.md` showing no hunk at or after line 177 and none in the "MSO decidability formalization" bullet. The Phase 3 notes written into this plan are bookkeeping on this plan's own record and are deliberately excluded from this phase's `Files to modify` so the tier claim above is measured against the amendment target alone; writing them is still required by the task list. The anticipated `test-roadmap-generation.sh` exit 2 is an environment outcome, not a scope change, and is handled in the verification criteria below.

**Files to modify**:
- `specs/ROADMAP.md` - the "MSO/Rabin route reaches ZTime only" bullet's open-question sentence replaced by the settled split verdict; the "MSO decidability formalization is refused outright" bullet deliberately untouched

**Verification**:
- Both replaced anchors count 0 after the edit; `grep -cF 'is owned by **903**'` is 0, and no other ROADMAP occurrence of this task's number appears.
- The amended bullet contains all of: `Auxiliary-Atoms`, `ban`, `Muller.toRabin_exists`, and the path of this task's report.
- `bash .claude/scripts/tests/run-all.sh --only test-engine-written-state-paths-lib.sh,test-roadmap-generation.sh` exits 0. If `test-roadmap-generation.sh` exits 2 for the environment reason named in Risks (it resolves its subject in `source-store` mode with no deploy-tree fallback, and this tree has no `agent-system/` and no `source_dir` key, so the suite never reads `specs/ROADMAP.md`), record a `#### Reasoned Exclusions` row for that half with the suite's stderr as evidence, and substitute: `bash .claude/scripts/roadmap-integration.sh --regenerate --dry-run` exits 0 against the amended file and `bash .claude/scripts/roadmap-integration.sh --print` exits 0.
- `git diff -U0 -- specs/ROADMAP.md` shows no hunk at or after the live coverage-appendix marker, no hunk inside `## Run these next`, and no hunk in the "MSO decidability formalization is refused outright" bullet.
- The sentence `It does **not** close \`Decidable (PlusValidZTime φ)\` constructively, which is still Stage 1's aim.` is byte-identical after the edit.
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty.
- `git diff --staged --name-only` names only `specs/ROADMAP.md` and this plan.

---

### Phase 4: Close-Out Record and Final Gate [COMPLETED]

**Goal**: The task's close-out record exists, states the split verdict and what was amended, names
every recommendation deliberately not acted on with its reason, and the repository passes its full
gate set with `FormalSystem/`, `Tests/`, `lakefile.toml` and `lake-manifest.json` untouched.

**Tasks**:
- [x] Set this phase's heading to `[IN PROGRESS]` before the first edit. *(completed)*
- [x] Write `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/summaries/01_muller-sufficiency-aa-rule-ban-lull-summary.md`
  per `summary-format.md` (all required headings verbatim), covering:
  - **The verdict in three sentences**: a deterministic Muller automaton suffices for the
    Auxiliary-Atoms rule, which carries no acceptance condition and demands only determinism
    (`p : Atom → ℕ → Atom` being a function is the whole requirement); it does not suffice for the
    ban/lull mechanism, whose banned list is indexed by the automaton's accepting pairs
    (Reynolds 2001 §12, `bl : T → (C × {1,…,K})*`); so (O1) is preserved with its ground sharpened
    and `Muller.toRabin_exists` is the single highest-value `proof_wanted` in either CSLib tree.
  - **Why the naive repair is unsound**, in two sentences with the two-state example: on
    `Q = {a,b}`, `𝓕 = {{a,b}}`, pair-enumeration yields `χ₁' ≡ GF a ∨ GF b`, valid over a finite
    state space, so `¬Eχ₁'` is unsatisfiable and `φ⁺'` inconsistent while `φ⁺` is consistent —
    strictly stronger than the incompleteness the fork's own docstring records. The same example
    shows no Rabin condition over `{a,b}` has accepted-`infOcc`-family `{{a,b}}`, so the LAR
    state-space blowup is unavoidable rather than an artifact of a bad pair choice.
  - **The one genuine saving**: (O2) is discharged for free by `Muller.exists_iSup` under the
    union-on-the-Muller-side-then-determinize-once ordering, so the automaton-side gap drops from
    two items to one. State its two carried dependencies (`PT(w₀)` finite, from the
    completeness-programme report §2.4; the composition order's legitimacy, from the re-assessment
    report's Finding 2).
  - **What is explicitly untouched**: (O3) and (O4) stand; the T3 GO as a paper programme is
    unaffected and never depended on the automaton being formalizable; nothing here is a
    completeness claim.
  - **The forensic note worth carrying forward**: Reynolds' Theorem 2 cites McNaughton (whose
    theorem lands in Muller) and Safra for a *Rabin* conclusion, so the Muller→Rabin step is
    silently absorbed into that theorem — exactly the step CSLib defers and exactly the step this
    task shows is load-bearing.
  - The Phase 1, Phase 2 and Phase 3 amendments, each with its file and what changed.
  - An explicit paragraph recording what is deliberately **not** done, each with its reason, so
    that none reads as an oversight: no `require` on either CSLib tree (recommendation 5 — the
    fork does not contain the determinization the architecture consumes, so a dependency would
    shorten nothing); no upstream PR and no CSLib-side lemma written (recommendation 4's named
    `Muller.toRabinLAR : Muller State Symbol → Rabin (LAR State) Symbol` with a `language_eq`
    belongs in `~/Projects/cslib`, is barred to an agent by `rules/pr-prohibition.md`, and is
    recorded with its narrowing — *named*, not the existential `Muller.toRabin_exists` as
    currently stated, because (O3) is alive precisely because an `∃ (State : Type)` cannot be
    written into `θ_f`); no `Muller.compl`, `Muller.inter`, `Rabin.union`, `Rabin.exists_iSup` or
    `Rabin.toParity_exists` filed anywhere (the report's §3 puts the first four off the critical
    path and `Parity.toRabin_language_eq` being proved puts the fifth there); no task filed in
    this tree (recommendation 7 — nothing may rest on Muller sufficiency for the ban mechanism,
    and task 901 already depends on this task so it will read this report by construction); no
    amendment to any task description; no Lean source, no `lakefile.toml`/`lake-manifest.json`
    edit, no Lean process started; and no `.claude/` redeploy, the dispatch's staleness warning
    being unactionable here because no `agent-system/` tree exists and
    `.claude-extensions.json` carries no `source_dir` key.
  - Link this task's report, both amended reports and `specs/ROADMAP.md` under `## References`.
  *(completed; see Phase 4 notes)*
- [x] Confirm no library or build-file change: `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json`
  is empty, and `git diff --stat <this task's first commit>^..HEAD -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json`
  is empty. *(completed: both empty)*
- [x] Confirm nothing was written under `.claude/**` or in either CSLib checkout by any phase:
  `git status --short -- .claude/` is empty (beyond anything a sibling owns), and no phase's
  committed diff names a path outside `specs/**`. *(completed: both confirmed; the union of
  `git show --name-only` over this task's own phase/plan commits names only `specs/**` paths)*
- [x] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh`. Read the output in full;
  do not infer a pass from the absence of visible errors. The precedent task measured this tree at
  15 checks / 0 failures with 22 "is a deploy consumer, not the source store" SKIPs and one
  pre-existing `lean still declares routing_hard/routing_agents_hard` WARN; neither the SKIPs nor
  that WARN is this task's regression, and the notes must say so rather than silently absorbing
  them. If this dispatch carries a `## Batch Gate Deferral` directive, follow it and record the
  deferral in the summary's Verification section instead of claiming a gate run that did not
  happen. *(deviation: altered — this dispatch's `.dispatch/5.md` carries a `## Batch Gate
  Deferral` section, so `verify-deploy.sh` was NOT independently run. This task's own touched
  paths resolve to `__FULL_SWEEP__` under `suite_selection_select` with no narrower `--only`
  suite or `--only-gate` available, so the deferral is recorded as-is with no substitute gate run
  beyond `validate-artifact.sh`/`validate-state.sh`, both green; see the summary's new
  `## Verification` section)*
- [x] Record a closing issue-log entry (`win` or `issue`) for this phase, or attest in the summary
  that nothing arose. *(completed)*
- [x] Write `.orchestrator-handoff.json` and `.return-meta.json` (`status: "implemented"`,
  `dispatch_seq` echoed verbatim, `phases_completed`/`phases_total` as top-level integers,
  `summary` and `blockers` both present), and commit the summary and this plan by explicit path.
  *(completed)*
- [x] Set this phase's heading to `[COMPLETED]`. *(completed)*

**Phase 4 notes**: The close-out summary covers all six plan-mandated content blocks (verdict,
unsoundness example, the (O2) saving, what is untouched, the forensic note, and the
deliberately-not-done paragraph). `verify-deploy.sh` was deferred per the dispatch's Batch Gate
Deferral directive rather than run independently, because this phase's own touched paths resolve
to `__FULL_SWEEP__` with no applicable `--only`/`--only-gate` narrowing — the same outcome
Phases 1 and 2 measured for their own `specs/**` report targets. `validate-artifact.sh` (all four
artifact checks) and `validate-state.sh` both exit 0. No library, build-file, `.claude/**`, or
CSLib-checkout path is touched by any phase of this task.

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3

**Verification Tier**: full

**Scope Hypothesis**: exactly one new summary file is written in this phase, and across all four phases exactly six files change — the two amended reports, the amended re-assessment summary, `specs/ROADMAP.md`, this plan, and the new summary — with no file under `FormalSystem/`, `Tests/`, `.claude/**`, or either CSLib checkout, and neither `lakefile.toml` nor `lake-manifest.json`. Confirm by the three `git` checks above plus `git diff --name-only <first commit>^..HEAD`, read before the gate run rather than after it.

**Files to modify**:
- `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/summaries/01_muller-sufficiency-aa-rule-ban-lull-summary.md` - new; the close-out record, including the deliberately-not-done paragraph
- `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/plans/01_muller-sufficiency-aa-rule-ban-lull.md` - Phase 4 notes and final phase markers

**Verification**:
- `bash .claude/scripts/validate-artifact.sh specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/summaries/01_muller-sufficiency-aa-rule-ban-lull-summary.md summary` exits 0.
- `bash .claude/scripts/verify-deploy.sh` runs to completion and is observed green (the complete gate set, not a `--only-gate` subset and not `--skip-slow`), or the batch deferral is recorded per the dispatch's directive.
- `bash .claude/scripts/validate-state.sh` exits 0.
- `bash .claude/scripts/validate-artifact.sh specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/plans/01_muller-sufficiency-aa-rule-ban-lull.md plan` exits 0 with every phase heading carrying a valid closed-enum marker.
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty, and the `git diff --stat` over this task's own commits for the same paths is empty.
- `git diff --name-only <first commit>^..HEAD` names only paths under `specs/**`, six files in total.
- `.orchestrator-handoff.json` validates (the write-time `validate-handoff-location.sh` gate accepts it) and `.return-meta.json` carries `status: "implemented"` with `dispatch_seq` echoed verbatim.
- The summary's deliberately-not-done paragraph names all of: no `require`, no PR / no CSLib lemma, no off-path lemma filed, no task filed, no task-description amendment, no Lean source, no redeploy — each with a reason.

## Testing & Validation

- [ ] Every anchor in Phases 1-3 ends at the count its disposition column states (0 for replaced, 1 for kept), or the phase notes record the deviation by name.
- [ ] `bash .claude/scripts/validate-artifact.sh` exits 0 on each amended and new artifact: both reports (`report`), the re-assessment summary and this task's new summary (`summary`), and this plan (`plan`).
- [ ] The amended re-assessment report still names (O1), (O3) and (O4) as live obstructions, still concludes "do not `require` anything now", and records (O2) as discharged rather than deleted.
- [ ] The amended completeness-programme report still states NO-GO on a Lean proof, still does not describe T1 as refuted, still carries its T3 GO verbatim, and its ingredient row 8 is byte-identical.
- [ ] Both amended reports carry a dated `**Amended by**` note citing this task's report, and the completeness-programme report carries two such notes (the existing one plus the new one).
- [ ] `grep -cF 'is owned by **903**' specs/ROADMAP.md` is 0, and no ROADMAP hunk lands at or after the live coverage-appendix marker or inside `## Run these next`.
- [ ] `bash .claude/scripts/tests/run-all.sh --only test-engine-written-state-paths-lib.sh,test-roadmap-generation.sh` exits 0, or the environment exit-2 is recorded as a Reasoned Exclusion with the `roadmap-integration.sh --regenerate --dry-run` / `--print` substitute evidence.
- [ ] A grep for lifting language (`NO-GO is lifted`, `completeness is now formalizable`, `completeness proof is now available`) returns 0 in both amended reports and in `specs/ROADMAP.md`.
- [ ] `bash .claude/scripts/verify-deploy.sh` observed green in the dispatch that closes Phase 4, or batch-deferred per directive; any SKIP or pre-existing WARN is attributed, not absorbed.
- [ ] `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty at every phase boundary.
- [ ] No commit stages a directory or glob pathspec; every commit names files explicitly, and `git status --short` is reviewed before each for a sibling's hunks.
- [ ] No file under `.claude/**`, no file in `~/Projects/cslib` or `~/Projects/cslib-pr648`, and no `.lean` file anywhere is modified by any phase.
- [ ] No new entry is added to `specs/state.json`'s `active_projects` by any phase, and no task description is amended.

## Artifacts & Outputs

- `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/plans/01_muller-sufficiency-aa-rule-ban-lull.md` (this plan, carrying the Phase 1-4 notes written at implementation time)
- `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/summaries/01_muller-sufficiency-aa-rule-ban-lull-summary.md` (the close-out record)
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md` (amended: (O1) settled as a split and narrowed to Rabin; (O2) discharged; two recommendations recorded as carried out; recommendation 6 withdrawn; Risks bullet discharged negatively)
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/summaries/01_cslib-omega-automata-nogo-reassessment-summary.md` (amended: one dated pointer note)
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` (amended: ingredient row 16 names the ban/lull mechanism as the consumer forcing Rabin; the verdict paragraph and executive-summary bullet narrowed to Rabin with (O2) discharged)
- `specs/ROADMAP.md` (amended: the open-question pointer naming this task replaced by the settled split verdict)
- `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/issues.jsonl` (issue-log entries recorded per phase)

No Lean source, no build file, no `.claude/**` file, no new `specs/state.json` entry, and no file
in any CSLib checkout is an output of this plan.

## Rollback/Contingency

Every change this plan makes is a text amendment to a Markdown file under `specs/**`, committed
one phase at a time. There is nothing to un-build and no build state to restore.

- **Per-phase rollback**: each phase commits exactly its own files by explicit path, so a bad
  amendment is reverted with `git revert` of that one commit, or — before committing — by
  re-editing the file to its pre-edit text, which the phase's own `git diff` review has in view.
  Do **not** use `git checkout --`/`git restore` on a dirty tree: a sibling task is active on this
  same working tree, and `guard-destructive-git.sh` blocks those forms for exactly that reason.
- **If a defensive checkpoint is wanted before a phase**: `bash .claude/scripts/git-snapshot.sh 903 --no-revert`.
  Never the bare reverting default form, which would discard a sibling's in-flight work.
- **If an anchor cannot be located**: skip that edit, record it by name in the phase notes, and
  carry the unamended passage forward into Phase 4's close-out as a named residual. A partially
  amended record with the gap stated is strictly better than a blind edit at a guessed location.
- **If `verify-deploy.sh` fails on a check unrelated to `specs/**`**: this plan touches no path any
  of its checks reads, so a failure is either pre-existing or a sibling's. Confirm with `git log`
  that the implicated work is not this task's, report it, and do not repair it inside this task —
  the territory contract requires reporting a foreign change, not absorbing it.
- **If the whole plan must be abandoned**: revert this task's commits in reverse order. The three
  amended records return to the state the re-assessment task left them in, the question they
  describe as open simply stays described as open, and this task's report remains on disk as the
  durable answer regardless. Nothing downstream breaks, because task 901's dependency on this task
  is a sequencing edge, not a content dependency on the amendments.
