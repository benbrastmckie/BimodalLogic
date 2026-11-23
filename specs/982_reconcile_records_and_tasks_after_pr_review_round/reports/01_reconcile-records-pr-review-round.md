# Research Report: Task #982

**Task**: 982 - Reconcile records and tasks after PR review round
**Started**: 2026-11-23T05:30:00Z
**Completed**: 2026-11-23T06:40:00Z
**Effort**: large (single research pass, no implementation)
**Dependencies**: 978, 979, 980, 981 (all `completed`)
**Sources/Inputs**:
- `gh pr view`/`gh pr view --json reviews,comments,files` for PRs #7-#11
- `specs/reviews/pr-reviews-2026-11-21/*.md` (FOLLOWUP.md, pr7-approval.md, pr7-review.md,
  pr8-review.md, pr8-record-edits.md, pr9-disposition.md, pr10-comment.md, pr10-review.md,
  pr11-comment.md, pr11-review.md)
- `records/milestones.md`, `records/proof-mode.md`, `records/proof-mode-architecture.md`,
  `records/README.md`, `records/theorem-library.md`
- `specs/state.json` (tasks 960, 969, 977, 944, 945, 973, 976, 978-985), `specs/ROADMAP.md`
- `specs/976_.../summaries/01_record-review-revision-summary.md` (the prior, 2026-11-20
  decisions round that is this round's baseline)
**Artifacts**: this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Not blocked.** The four review tasks have reported, and the user's rulings on the items
  those reports put first are recorded — two as posted GitHub reviews (PR #7 approved and
  merged; PR #11 changes-requested, posted 2026-11-23T01:57:16Z), three as fully drafted,
  decided text awaiting only the user's own posting action (PR #8's two remaining mechanical
  conditions, PR #9's close, PR #10's three additions). The one item genuinely still open —
  "does the signature layer land before or after the temporal contribution" (join 4 /
  milestones.md open decision 4 in the *current* numbering) — is explicitly named as "still the
  user's" in `FOLLOWUP.md` and is **not** one of the decisions this task's own WHAT-TO-CHANGE
  list asks to close; it is correctly already reflected as held-pending in both
  `records/milestones.md` and task 977's roadmap line. This task can proceed with the full
  reconciliation.
- `records/milestones.md`'s "Open decisions" list has already been edited down (by earlier
  review-round work, task 976 and the PR #8 re-review) from the longer list this task's
  description was written against, to four items. Two of the dispatch's four numbered closing
  instructions (its "open decision 4" = evaluator-placement, its "open decision 5" =
  expand/contract) map onto the *current* list's items 2 and 3 and are both now resolvable; the
  two the dispatch calls "open decision 1" (conditions of merging) and "open decision 2" (who
  drafts the semantic record) no longer exist as open-decision entries at all — they were
  already folded into "Where it stands" prose and are moot, not pending.
- `records/proof-mode.md`'s M17 section and its "Filed records" table row both still read
  "contributed and under review" for the rewriting contribution, which merged as PR #7 four
  hours before this dispatch ran (`3c7197f84`, 2026-11-22T22:58:00Z) — a live, mechanically
  checkable contradiction between `records/proof-mode.md` and `records/milestones.md`'s "Where
  it stands" prose, which already treats it as merged.
- `records/milestones.md`'s contributions table has four rows (Temporal, Semantic lemmas,
  Semantic record, Semantic mode) for the four *open* PRs; PR #7 is described only in prose above
  the table as merged. The dispatch's target of "five pull requests ... each with its current
  state" is not met by either the three-row table the task description was written against or
  the current four-row one — a fifth row for #7 (state: merged) is still missing.
- `records/README.md` already lists `milestones.md`; `records/semantic-proof-mode.md` cannot be
  added yet because the file does not exist on `main` — PR #10 (the branch that drafts it) is
  still open and unmerged. This part of the task is correctly blocked on that merge, not on any
  user ruling.
- Five of the six named task descriptions need concrete, citable edits (file moves, a lifted
  hold condition, a restated coordination paragraph); `theorem_library_countermodels` needs only
  a client/grade note, not a file-scope change. All six are detailed below with exact source
  citations for the planner.
- The roadmap's PR #7/#8 gating rule is **already current** in `specs/ROADMAP.md` (rendered
  from `state.json`, not hand-edited) — it already says "#7 is merged, so #8 is the only one
  still barring it." The one roadmap gap is a placeholder for Goal C's evaluator (C3) and
  semantic-mode/adapter (C4), which have no task record yet; a quoted `/roadmap` instruction is
  given in Recommendations.

## Context & Scope

Task 982 reconciles `records/milestones.md`, `records/proof-mode.md`,
`records/proof-mode-architecture.md`, `records/README.md`, six named task descriptions, and
`specs/ROADMAP.md`'s generating rules with the outcome of the review round on collaborator PRs
#7-#11. It posts nothing and merges nothing. This is dispatch_seq 13 for the task; no prior
dispatch left a report, plan, or summary artifact — `specs/982.../reports/`,
`specs/982.../plans/` and `specs/982.../summaries/` were all empty before this pass, confirming
that the task's prior dispatches were blocked on tasks 978-981 (all now `completed`) rather than
having already done partial reconciliation work.

**Gating check performed first, per the dispatch's own instruction**: `gh pr view` for #7-#11,
then the four reports under `specs/reviews/pr-reviews-2026-11-21/`. Findings below; the
conclusion is that the task is not blocked (see Executive Summary and "Gating Verdict" below).

## Findings

### Gating Verdict: PR and Review State (ground truth via `gh`)

| PR | State | Mergeable | Head | Posted review (via `gh pr view --json reviews`) |
|---|---|---|---|---|
| #7 | **MERGED** | n/a | `3c7197f84` merge commit, head `6313e693f` | CHANGES_REQUESTED 2026-11-20T23:33:56Z, then **APPROVED 2026-11-22T22:58:00Z** (matches `pr7-approval.md`) |
| #8 | OPEN | MERGEABLE | `5ecc91d63` (rebased onto post-#7 `main`) | CHANGES_REQUESTED 2026-11-20T23:33:57Z only — the re-review in `pr8-review.md` (dated against `5ecc91d63`) has **not** been posted to GitHub yet |
| #9 | OPEN | CONFLICTING | `b3d8f6463` | CHANGES_REQUESTED 2026-11-20T23:33:58Z only; a follow-up **comment** (not a review) was posted 2026-11-21T20:30:25Z narrowing the ask; the "close" disposition in `pr9-disposition.md`/`pr9-comment.md` has **not** been posted |
| #10 | OPEN | MERGEABLE | `ada7074d` | **no reviews posted at all**; `pr10-comment.md`'s three asks have **not** been posted |
| #11 | OPEN | MERGEABLE | `b2eb3ac0b` | **CHANGES_REQUESTED posted 2026-11-23T01:57:16Z**, body matches `pr11-comment.md` |

Three of five PRs (#8, #9, #10) have their decided reply text sitting as drafts in
`specs/reviews/pr-reviews-2026-11-21/`, not yet posted to GitHub. This is expected and does not
block this task: task 982 "posts nothing"; posting is a separate, user-gated action (outside
this task and outside any agent's authority per `pr-prohibition.md`). What matters for
reconciling *records* and *task descriptions* is whether the underlying **decision** is settled,
not whether the comment carrying it has been pasted into GitHub yet.

**Decision-recorded check**, reading `FOLLOWUP.md`'s "Decided" section against each PR:

- **#7**: decided and posted (approved, merged). No open item.
- **#8**: decided. `pr8-review.md` states "Two conditions remain" (carrying-table key/visibility,
  the split acceptance example) and that "`expand`/`contract` is settled" and the PR's own head
  already carries the `records/proof-mode-architecture.md` edit that settles it (open decision 2
  there). `pr8-record-edits.md` explicitly flags this a **drafted, decided** state: "Already
  landed by the PR — check before touching" for two record edits, "Still ours to apply" for two
  more (`records/milestones.md` open decision 3 and join 2). Nothing here awaits a user ruling.
- **#9**: decided — close, with the drafted closing comment in `pr9-comment.md`/
  `pr9-disposition.md`. No open item.
- **#10**: decided — the three additions (open-decisions section with full text, an adoption
  threshold, two scope sentences) are drafted in full in `pr10-comment.md`; its own
  `## Open decisions` draft item 1 says "I lean towards the assumption in `milestones.md`" (i.e.
  states a decision, not a request). A follow-up comment already posted to PR #9 on
  2026-11-21T20:30:25Z (read via `gh pr view 9 --json comments`) independently confirms the
  lemmas-and-record split the record reconciliation below assumes.
- **#11**: decided and posted (changes requested, three conditions; everything else is explicitly
  "after the merge, not conditions of it").

**The one genuinely open item**: join 4 of `records/milestones.md` ("Does the signature layer
land before or after the temporal contribution?", restated as the current open decision 4) is
explicitly named in `FOLLOWUP.md`'s "Related, not in the three" section: *"Open decision 4
(signature layer before or after) is untouched by this review and still the user's."* This is
**not** one of the items this task's own WHAT-TO-CHANGE list asks to close (it asks to close the
dispatch's "open decision 4" = evaluator placement and "open decision 5" = expand/contract, both
of which map to *different*, now-resolved entries in the current numbering — see next section).
`specs/ROADMAP.md`'s M0 batch 3 and task 977's own roadmap line already state this correctly
("research and plan now; implement after the temporal rules merge (open decision 4)"), so no
record or task text currently misstates it as closed. **Conclusion: not a blocker for this
task's scope.**

### Numbering Drift in the Task Description vs. the Current Records

The task description's WHAT-TO-CHANGE item (1) names "open decision 1 (conditions of merging)"
and "open decision 2 (who drafts the semantic record)" — **neither exists as an open-decision
list entry in the current `records/milestones.md`.** Both were already resolved into prose
before this dispatch: "conditions of merging" is now literally answered by the per-PR review
outcomes tabulated above (replacing an abstract open decision with the concrete ruling is exactly
"open decision 1 ... replaced by the ruling", as the dispatch asks); "who drafts the semantic
record" is moot because Tanner wrote `records/semantic-proof-mode.md` himself (on PR #10) — which
is exactly "removed, the contributor having written it." Both are already true of the *current*
state, not outstanding work.

The dispatch's "open decision 4 (evaluator beside the lemmas or its own mode)" and "open decision
5 (expand / contract)" map onto the **current** list's items 2 and 3:

- Current item 2 ("Evaluator with the lemmas or in a mode of its own?") already carries "Settled
  in C2" in its own text. `pr10-comment.md`'s drafted `## Open decisions` item 1 states the
  decision: "`milestones.md` assumes the evaluator sits under `FormalSystem/Semantics/` beside
  the lemmas... I lean towards the assumption in `milestones.md`" — i.e. the default stands,
  confirmed by the reviewer (the user) in the draft reply. **Close as: evaluator beside the
  lemmas is the default**, citing `pr10-comment.md` item 1.
- Current item 3 ("`expand` and `contract` for the Until and Since steps... awaits the user's
  ruling") is resolved per `pr8-review.md`'s "On the records" paragraph, which the user's own
  re-review text endorses ("Thank you for that; it is the most useful thing on the list") and
  `pr8-record-edits.md`'s explicit instruction: **"Strike it entirely and renumber item 4 to
  3."** `pr8-record-edits.md` also gives the exact replacement text for "What to do next" item 1
  (quoted in full there) once this is struck.

After these two closures, `records/milestones.md`'s "Open decisions" list drops from 4 items to
2: the renumbered item (signature-layer timing, still open — see Gating Verdict) and the
untouched library-registry item 1 ("Is `BimodalLib` in `defaultTargets`?", not named anywhere in
this task's WHAT-TO-CHANGE and correctly left alone).

### (1) `records/milestones.md`

| Sub-item | Current state | What the reports establish | Action |
|---|---|---|---|
| Contributions table | 4 rows (Temporal=#8, Semantic lemmas=#11, Semantic record=#10, Semantic mode=#9); #7 described only in prose above the table as merged | PR #7 is a fifth contribution with its own state (merged) | Add a fifth row for #7, or restructure so all five PRs appear uniformly with a State column reading: #7 merged; #8 open, rebased, two conditions remain (per `pr8-review.md`); #9 open, recommended close (per `pr9-disposition.md`); #10 open, three additions requested (per `pr10-comment.md`); #11 open, changes requested — three conditions, posted (per `pr11-comment.md`) |
| "Where it stands" prose | Describes #7 as merged correctly; the four-row table's state descriptions for #8-#11 are stale relative to the 2026-11-21 round (e.g. does not mention #8's two remaining conditions or that #8 is rebased and CI-green) | `pr8-review.md`, `pr9-disposition.md`, `pr10-comment.md`, `pr11-comment.md` | Rewrite each cell to the current, dated state above; cite no task numbers (per `no-task-references-in-deliverables.md`) |
| "What to do next" item 1 | "...merged with the carrying table agreed (join 2) and the `expand` and `contract` keywords ruled (open decision 3)" | `pr8-record-edits.md` gives exact replacement text: "...rebased onto `main` and re-reviewed at `5ecc91d63`; it merges once the carrying table's key is widened to `(source, target)` and made non-private (join 2), and once the one altered acceptance example in `ProofModeTest.lean` is split into the two cases it used to cover." | Apply verbatim per `pr8-record-edits.md` |
| Open decision 1 (old numbering: "conditions of merging") | n/a — no longer a list entry | Resolved into per-PR outcomes (table above) | No entry to remove; confirm it is not reintroduced |
| Open decision 2 (old numbering: "who drafts the semantic record") | n/a — no longer a list entry | Tanner wrote `records/semantic-proof-mode.md` on PR #10 | No entry to remove; confirm it is not reintroduced |
| Open decision 2 (current numbering: evaluator placement) | "Settled in C2" | `pr10-comment.md` item 1: evaluator beside lemmas is the default | Restate as settled design (not an open question); keep the "default" framing citable to `pr10-comment.md` once posted |
| Open decision 3 (current numbering: expand/contract) | "awaits the user's ruling" | `pr8-record-edits.md`: "Strike it entirely and renumber item 4 to 3" | Strike; renumber the signature-layer item to 3 |
| Join 2 (carrying table) | "The table's shape is fixed in A2, before A5 adds rows" | `pr8-record-edits.md` item 4 gives the concrete agreed shape (`CarryRule` keyed by `(source, target)`, a `framed` flag, module `Automation/ProofMode/Carrying.lean`, non-private) **only if the contributor accepts that shape** — it is Benjamin's ask to Tanner inside `pr8-review.md`'s "Conditions of merging" §1, not yet confirmed accepted | Record the asked-for shape as the live condition of merging (not yet as final design — `pr8-record-edits.md` itself says "Only if the contributor accepts"); do not overwrite with certainty beyond what the review state supports |
| Goal C's C1/C2 "given up to pointers" | C1 (semantic lemmas) and C2 (record agreed) are table rows with "Done when" criteria still spelled out in full | `records/README.md`'s own rule: "When a design is implemented, `docs/` is revised and the record gives it up... cuts that part down to a pointer" | **Not yet applicable** — neither PR #10 nor PR #11 has merged. Do not reduce C1/C2 to pointers yet; the dispatch's own phrasing ("once the lemmas and the record are merged") makes this conditional and the condition is unmet. Flag as deferred, not done. |
| Channel table | States phase order "Until temporal is merged" / "Temporal merged" | #7 (rewriting, A1) has in fact already merged, ahead of #8 (temporal, A2) merging | Check phrasing does not imply A1 and A2 merge together; the "Order within each channel" table already distinguishes them by column, so likely only wording polish is needed, not structural change |

### (2) `records/proof-mode.md`

- **M17** (rewriting): the done-when and "Current client" paragraph are *already* correct and
  matching the user's own correction in `pr7-approval.md` (no node counts, no timing claim,
  states the saving is in the proof script not the term, cites the larger-term finding). **No
  change needed to the "Current client" paragraph itself.** However, the **"Filed record" line
  within the M17 section (line 503) and its "Filed records" table row (line 790) both still read
  "contributed and under review"** — PR #7 merged 2026-11-22T22:58:00Z, well before this dispatch
  (and before the task's own dependency tasks 980/981 even reported). Change both occurrences to
  reflect the merge (e.g. "none; merged as PR #7" / "merged (#7)"), and confirm nothing in the
  surrounding "second run still owes" language (which correctly still describes the M3-selection
  rerun as outstanding) is disturbed.
- **M16** (views tier): "which rows and which modules exist" — on `main` today, the view table
  (`FormalSystem/Tactic/FormulaViews.lean` per the architecture record's placement) holds only the
  rows PR #7 contributed (modal/Boolean-adjacent views, per `pr7-approval.md`'s note on `lunfold`/
  `lfold` already existing and behaving like `rw`). **Twenty further rows (ten `Formula`, ten
  `PlusFormula`) live only on PR #8's branch** (`FormalSystem/Tactic/TemporalFormulaViews.lean`,
  confirmed by direct read in `pr8-review.md`: "does it, and does more... twenty rows... the
  extra pair being `after`") and are not yet on `main`. `ltemporal_dual` is retired on that
  branch, not yet on `main`. State both facts precisely — do not describe the 20 temporal rows as
  present until #8 merges. What the M16 **record** (`proof_mode_views_tier`, task 969) still owes
  is unchanged by either PR: building the actual fold/unfold tactic *tier* module with every
  defined operator having a row and the architecture record's "lane" placement (layer 0/1, no
  import of `Automation/ProofMode/`) is still task 969's own undone work — PR #7 and #8 only
  contribute table rows and seed the pair, inside the Automation-tier files for now, per
  `proof_mode_views_tier`'s own description's "COORDINATION WITH OPEN CONTRIBUTIONS" clause
  ("extract the views already inside them... into this tier").
- **M4** (linear-time / Until-Since induction): "expand/contract" naming is now settled (see
  above). "What is contributed": PR #8 contributes Until/Since introduction, one-step unfolding
  at ZTime, `keeping`, whole-judgment time reflection, and the strict leads-to layer — all
  confirmed merged-ready per `pr8-review.md`'s gate table (build/test/lint/invariants green,
  `#print axioms` clean on 18 rules, CI green). **The induction rule remains explicitly open**:
  `pr8-review.md` restates request 4 verbatim — "The generalizing Until/Since rule is still not
  derived, and the paragraph you added to M4 is a semantic argument rather than a derivation...
  That remains the most useful thing anyone could add next, and it still does not belong in this
  PR." M4's text already states this correctly ("statement proposed and not yet derived"); no
  change needed there beyond consistency with the rest of the record.
- **Dependency picture's M17-then-M0-then-M16 order**: still accurate. M17 (merged) satisfies "M0
  runs after the open contributions are merged or declined, M17 among them"; M0 (task 960) is
  still correctly held on #8 per the roadmap rule (already current, see below). No change to the
  ordering logic itself, only to the M17 status text noted above.
- **Filed records table**: only the M17 row's "none; contributed and under review" phrase needs
  the merged-status fix noted above; every other row is a task-record pointer and is unaffected
  by this review round.

### (3) `records/proof-mode-architecture.md`

- **Open decision 2 (rename)**: per `pr8-record-edits.md`, this is "Already landed by the PR" on
  PR #8's own branch — i.e. **not yet on `main`**, since #8 is unmerged. The dispatch's framing
  ("open decision 2 closed with the rename") is the *target* state once #8 merges; until then,
  the architecture record on `main` still correctly shows the decision as open with a
  recommendation. **Do not close this open decision in the architecture record before PR #8
  merges** — doing so would state as fact something that exists only on an unmerged branch,
  which is exactly the hazard `pr8-record-edits.md` was written to prevent ("Do not duplicate or
  revert those edits"). The correct action now is to leave `proof-mode-architecture.md`'s open
  decision 2 as-is and instead make the closure in `records/milestones.md`'s open decision 3
  (per the table above), which is this task's own territory and does not depend on #8 merging —
  `milestones.md`'s item explicitly points at `proof-mode-architecture.md`'s open decision 2 but
  states its *own* ruling independently once PR #8's content is known. On #8's actual merge, a
  *later* dispatch (or #8's own merge, which carries the edit) closes the architecture record's
  copy; this task should not race ahead of the merge for that one file.
- **"Where the work sits" rows for views, rewriting, carrying, Until/Since and the semantic
  tier**: the rewriting row ("Logical rewriting under operators... M17; `lrewrite` and `lsimp`
  apply native rules only") is accurate and current (M17 merged). The views row ("the first rows
  of the view table are contributed with the rewriting tactics") is accurate for `main` today;
  once #8 merges it should additionally credit the 20 temporal rows — **deferred**, not actionable
  now. The Until/Since row ("statement proposed and not yet derived") is accurate and unaffected.
  The "Truth at a point..." (semantic tier) row still reads "to be a separate mode in a directory
  of its own under `FormalSystem/Semantics/`, with one adapter module at layer 3, after
  `records/semantic-proof-mode.md`" — accurate, since the record is still only a PR #10 draft.
- **Semantic-mode paragraph** ("The semantic mode has a record and a measured client before any
  tactic is built. The record is `records/semantic-proof-mode.md`, **which is to be written**"):
  this is a minor currency gap — the record *has* been written, as a draft on PR #10's branch,
  just not yet merged. Recommend changing "which is to be written" to something like "drafted on
  PR #10 (`feat/proof-mode-semantics`'s successor), not yet merged" so the record does not imply
  no draft exists, **without** attempting the larger rewrite the dispatch describes ("once
  records/semantic-proof-mode.md is in the tree") — that larger rewrite is correctly gated on the
  merge and is out of scope for this pass.

### (4) `records/README.md`

Already lists exactly the four records present (`milestones.md`, `proof-mode.md`,
`proof-mode-architecture.md`, `theorem-library.md`) — `milestones.md` is already a row, matching
the first half of the dispatch's instruction. `records/semantic-proof-mode.md` does not exist on
`main` (confirmed via `ls records/`); it cannot be added as a row until PR #10 merges. **No
action available now**; this is correctly blocked on the merge, not on a user ruling or on any
missed edit in this repository's current `records/README.md`.

### (5) Task Descriptions

All six are `not_started`; none has been implemented, so an edit here is purely a description
(and, where named, `file_scope`) correction, not a revert of in-flight work.

| Task | Slug (project_number) | What the reports change | Concrete action |
|---|---|---|---|
| `proof_mode_split_shared_test_and_guide_files` | 960 | Coordination paragraph names "#7, #8 and #9" and "a shared test file `ProofModeExtensionsTest.lean`". #7 has merged (ahead of #8/#9, which are the two still-open items the paragraph should name); PR #9 is recommended for closure, so should no longer be named as a live coordinating PR; PR #8's actual diff (confirmed in `pr8-review.md`) already does the family-split work in `FormalSystem/Theorems/ProofMode/TemporalComposition/{Temporal,TemporalBoolean,TemporalZTime}.lean` and the matching `Automation/ProofMode/{Temporal,TemporalBoolean,TemporalZTime}.lean`, so once #8 merges there is markedly less for 960 to move than the paragraph currently implies | Rewrite the coordination paragraph to: name only PR #8 as the still-open blocker (PR #7 merged, already folded into layout by its own filing; PR #9 recommended closed, its content superseded as tabulated in `pr9-disposition.md`); state that what remains to move, once #8 merges, is narrower than originally scoped — chiefly the shared guide index, both ProofMode READMEs, and whatever of `Meta.lean`/`Modal.lean`/`Temporal.lean`'s *pre-#8* content still predates the family split (#8's own PR already splits its own additions). **Hold status**: the roadmap rule ("960's IMPLEMENTATION must not be dispatched while collaborator pull request #8 is open") is a statement, not a task-level hold field — confirm no hold flag needs lifting on the task record itself (none is set, per `specs/ROADMAP.md`'s own text: "This is a statement rather than a status: no hold is set") |
| `proof_mode_views_tier` | 969 | "COORDINATION WITH OPEN CONTRIBUTIONS" clause already anticipates exactly this case ("If #7 or #8 has merged, extract the views already inside them... into this tier"). #7 has merged; #8 has not. | Update to: #7 has merged — extract its contributed view rows (the modal/Boolean-adjacent ones) and the equality-handling parts of `lrewrite`/`lsimp` noted in the clause, leaving logical rewriting where it is. #8 has not merged — its 20 temporal rows and `ltemporal_dual` retirement remain "owed" extraction once it lands; do not claim them as already extractable. |
| `connective_signature_layer_shared_primitives` | 977 | Its relation to the Language table (TruthClauses.lean's generic clause classes, "FIRST QUESTION FOR RESEARCH... ONE HOME FOR THE DERIVED OPERATORS") and the landing window of join 4 | `specs/ROADMAP.md` already states the current ruling correctly ("research and plan now; implement after the temporal rules merge (open decision 4)"). The task description itself should restate that join 4's landing window is still genuinely undecided (per Gating Verdict above) and that research/planning (not implementation) may proceed now regardless of that undecided window — this matches the roadmap text and needs no reversal, only confirmation it is stated inside the task description itself, not only in the roadmap |
| `proof_mode_s5_aware_box_scopes` | 944 | "if pull request #8 has merged, its `keeping [...]` clause... must be folded into it, not left as a parallel path" — carrying table | #8 has not merged, so this remains correctly conditional. Once #8 merges, the concrete shape agreed in `pr8-record-edits.md` item 4 (`CarryRule` keyed by `(source, target)`, `framed` flag, `Automation/ProofMode/Carrying.lean`, non-private — **contingent on Tanner accepting it**) should be folded in here; **deferred**, not actionable before the merge |
| `proof_mode_cross_modal_scopes_mf_tf` | 945 | Same carrying table, "MF and TF enter as rows of the carrying table from `proof_mode_s5_aware_box_scopes`" | Same deferral as 944; no independent action beyond what 944 already states this task waits on |
| `theorem_library_countermodels` | 973 | The evaluator (C3) as a client, and the admission grade | `records/milestones.md` join 6 already states "C3's client is B4. The record of C2 names the declarations; B4 states the grade at which an evaluator-checked refutation is admitted." 973's own description already has three grades (SEMANTIC/CERTIFICATE/GATED TABLEAU) and a sequencing note ("C3 for the evaluator-checked entries" is in `milestones.md`'s B4 row, not yet in 973's own description text). Since C3 (the evaluator) has **no task record at all yet** (confirmed: no task description anywhere mentions building the evaluator module itself — see Recommendations, roadmap placeholder), 973's description is accurate as written and needs no file_scope change; only a cross-reference addition naming C3/`records/semantic-proof-mode.md` as the still-missing upstream dependency for the evaluator-checked grade specifically, so a future reader does not assume all three grades are equally ready |

**`file_scope` paths**: none of the five file-moving tasks above (960, 969, 944, 945) have had
their underlying target paths actually renamed yet in this repository (960, 969, 944, 945, 973
are all `not_started`); `file_scope` entries read against the *current* tree and are accurate as
declared. No `file_scope` correction is needed now — the dispatch's "whether their hold is
lifted" and "file_scope of each where paths moved" questions both resolve to "not yet, pending
#8's merge," which is a description-text fact, not a `file_scope` array edit.

### (6) Roadmap

`specs/ROADMAP.md` is generated from `state.json`'s `roadmap_milestones`/`primary_goals`/
`roadmap_context` fields by `roadmap-integration.sh`; this task does not edit it directly.
Checked against the current rendered file:

- **The PR #7/#8 gating rule is already current**: `## Rules` already states "960's
  IMPLEMENTATION must not be dispatched while collaborator pull request #8 is open; #7 is merged,
  so #8 is the only one still barring it. Research and planning may proceed. This is a statement
  rather than a status: no hold is set." — this already matches the review-round outcome; no
  `/roadmap` instruction is needed to fix it.
- **982's own roadmap annotation is stale**: `state.json`'s task-982 entry carries
  `"roadmap_annotation": "cannot finish ahead of the user's rulings on open decisions 3 and 4"`,
  rendered into M0 batch 1's task list as `982 blocked:978,979,980,981 ... <- cannot finish ahead
  of the user's rulings on open decisions 3 and 4`. Per the Gating Verdict and Numbering Drift
  sections above, current open decision 3 (expand/contract) is now resolved (pending only the
  mechanical #8 merge, not a user ruling), and only current open decision 4 (signature-layer
  timing) remains genuinely open. This annotation should be narrowed to name only the one
  remaining item, and this task's own completion (once its edits land) removes the "cannot
  finish" framing entirely, since this research pass establishes the task is not actually
  blocked.
- **No placeholder exists for Goal C's evaluator (C3) and semantic-mode/adapter (C4)**: neither
  has a task record (confirmed by searching all task descriptions for "evaluator"/"semantic
  mode"; only task 983, which is D4/the soundness statement, and task 985, which is a research-
  only task for the PR #10 reply, exist, and neither is C3 or C4 itself). `records/milestones.md`
  states C3's and C4's "Done when" and "Waits on" columns, but the roadmap has no batch or
  milestone row referencing either.

## Recommendations

1. Apply the `records/milestones.md`, `records/proof-mode.md`, and `records/proof-mode-
   architecture.md` edits exactly as scoped in Findings (1)-(3) above, respecting the
   merge-gating noted for the architecture record's open decision 2 and the "Goal C pointers"
   deferral.
2. Do not touch `records/README.md` or add a `records/semantic-proof-mode.md` row; both are
   correctly blocked on PR #10's merge.
3. Edit the six task descriptions via `state-write.sh` per Findings (5); none require a
   `file_scope` change at this time.
4. **Quoted instruction for the user to give `/roadmap`** (per the dispatch's constraint not to
   edit `specs/ROADMAP.md` directly):

   > Narrow task 982's roadmap_annotation to name only the signature-layer-timing open decision
   > (the one item in records/milestones.md's Open decisions still genuinely awaiting the user's
   > ruling, per join 4), since the expand/contract naming question this annotation used to cite
   > is now resolved pending only PR #8's mechanical merge. Add a placeholder milestone or batch
   > entry for records/milestones.md's Goal C evaluator (C3) and semantic-mode/adapter (C4)
   > work, noting that neither has a task record yet and that both wait on records/semantic-
   > proof-mode.md (PR #10) landing first; do not create the task records themselves, only the
   > roadmap placeholder naming the gap. Leave the existing PR #7/#8 gating rule on task 960
   > unchanged — it already correctly states #7 is merged and #8 is the remaining blocker.

5. **Closing consistency pass** (per the task's CONSTRAINTS): the one concrete, mechanically
   checkable contradiction found is `records/proof-mode.md`'s two "contributed and under review"
   occurrences for M17 (lines 503 and 790) against `records/milestones.md`'s "Where it stands"
   prose, which already treats the rewriting contribution as merged. No other cross-record
   contradiction was found in this pass; the apparent numbering mismatches between the task
   description's open-decision references and the current `records/milestones.md` list are not
   contradictions in the records themselves — they are the task description's own staleness,
   addressed by Finding "Numbering Drift" above and by this task's own edits, not by changing the
   records a second way.

## Decisions

- This task is **not blocked**: the review round's rulings on the items the four reports put
  first are recorded (as posted GitHub reviews for #7 and #11, and as fully decided, drafted
  text awaiting only the user's own posting action for #8, #9, #10). The one genuinely open item
  (signature-layer timing, join 4) is outside this task's own closing list and is already
  correctly stated as pending in both `records/milestones.md` and task 977's roadmap line.
- `records/proof-mode-architecture.md`'s open decision 2 (the `expand`/`contract` rename) is
  **not** closed in this pass, because the edit exists only on PR #8's unmerged branch;
  `records/milestones.md`'s own copy of that decision (its item 3) **is** closed in this pass,
  since the review-round outcome that settles it is independent of the merge actually landing.
- Goal C's C1/C2 milestones are **not** reduced to pointers in this pass; both PRs (#10, #11)
  that would complete them are still open.

## Risks & Mitigations

- **Risk**: closing `records/milestones.md`'s open decision 3 while `records/proof-mode-
  architecture.md`'s open decision 2 (the same question) stays open could itself read as a fresh
  contradiction between the two records. **Mitigation**: `milestones.md`'s item already points at
  the architecture record's open decision 2 by reference ("Open decision 2 of
  [proof-mode-architecture.md]"); the plan phase should word the closure so it states the
  *milestones-level* ruling (the keywords are decided as `expand`/`contract`, used throughout the
  merging PR) without asserting that the architecture record's own open-decision list has already
  been edited — e.g. "...ruled: the keywords are `expand` and `contract` (see
  `proof-mode-architecture.md`'s open decision 2, closed on PR #8's merge)."
- **Risk**: PR #8's carrying-table shape (`pr8-record-edits.md` item 4) is explicitly contingent
  ("Only if the contributor accepts that shape"). **Mitigation**: record it as the *current
  condition of merging* asked of the contributor, not as settled design, exactly as
  `pr8-record-edits.md` itself frames it.
- **Risk**: a later dispatch of this same task, run after PR #8 actually merges, might re-derive
  all of Finding (3)'s deferred items from scratch. **Mitigation**: this report's Findings tables
  are written so that re-running them after the #8 merge is a lookup (check whether each
  "deferred" row's precondition now holds) rather than fresh research.

## Context Extension Recommendations

- **Topic**: cross-record "merged vs. under review" currency.
- **Gap**: no existing context file documents a checklist for sweeping `records/*.md` for stale
  PR-status language after a PR merges; this report found one instance (M17 in
  `proof-mode.md`) by manual grep (`grep -n "under review" records/*.md`), which is cheap but not
  automated.
- **Recommendation**: if this class of staleness recurs across future PR merges, a small
  mechanical check (grep for "under review"/"contributed" near a PR number, cross-checked against
  `gh pr view --json state`) could be added to `.claude/scripts/` as a reconciliation aid; not
  proposed as a task here, since this is a single, already-found instance, not a recurring
  pattern yet.

## Appendix

Search/verification commands used (representative, not exhaustive):

```
gh pr view {7,8,9,10,11} --json number,title,state,mergeable,headRefOid,baseRefName,url
gh pr view {7,8,9,10,11} --json reviews --jq '.reviews[] | {author: .author.login, state, submittedAt}'
gh pr view 7 --json mergedAt,mergeCommit
gh pr view 9 --json comments --jq '.comments[-1].body'
jq -r '.active_projects[] | select(.project_number==N) | {...}' specs/state.json   # for 960,969,977,944,945,973,976,978-985,982
grep -n "under review\|PR #7" records/*.md
grep -n "^## Open decisions" -A 20 records/{proof-mode,theorem-library}.md
```

Files read in full or in substantial part: `records/milestones.md`, `records/proof-mode-
architecture.md`, large sections of `records/proof-mode.md` (M3, M4, M16-M18, dependency picture,
Filed records, Open decisions), `records/README.md`, `specs/reviews/pr-reviews-2026-11-21/
{FOLLOWUP,pr7-approval,pr7-review(partial),pr8-review,pr8-record-edits,pr9-disposition,
pr10-comment,pr11-comment}.md`, `specs/976_.../summaries/01_record-review-revision-summary.md`,
relevant sections of `specs/ROADMAP.md`.
