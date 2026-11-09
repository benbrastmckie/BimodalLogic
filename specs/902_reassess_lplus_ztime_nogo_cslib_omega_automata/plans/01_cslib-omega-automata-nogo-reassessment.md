# Implementation Plan: Task #902

- **Task**: 902 - Re-assess the L-plus ZTime completeness NO-GO against CSLib's deterministic omega-automata inventory, including the local fork
- **Status**: [IMPLEMENTING]
- **Effort**: 2.75 hours
- **Dependencies**: None
- **Research Inputs**: `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md`
- **Artifacts**: plans/01_cslib-omega-automata-nogo-reassessment.md (this file)
- **Standards**:
  - `context/formats/plan-format.md`
  - `context/standards/status-markers.md`
  - `context/standards/artifact-management.md`
  - `context/formats/summary-format.md`
  - `context/standards/git-staging-scope.md`
  - `context/patterns/backlog-reconciliation.md`
  - `rules/state-management.md`, `rules/git-workflow.md`, `rules/pr-prohibition.md`
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research dispatch has already delivered all four of the task's stated deliverables: the
verified inventory, the answer to the pasting-lemma question, the revised verdict, and the
dependency-cost assessment. Nothing substantive remains to be *found*. What remains is to land
the report's consequences in the records that other tasks read, and to hand forward the two
recommendations this repository can own, without taking any of the actions the report explicitly
declined.

Accordingly this plan is a record-and-handoff plan, not an implementation plan in the usual sense.
It amends the completeness-programme report whose NO-GO ground this task re-tested, narrows the
ROADMAP entry that carries the standing refusal that NO-GO cited as its authority, files the two
follow-up items the report recommends and this repository can own, and writes the close-out record
that states, explicitly, which recommendations are deliberately not acted on and why. No Lean
source, no build file, and no dependency declaration is touched by any phase.

### Research Integration

The report is the sole substantive input, and every phase below consumes a specific part of it
rather than re-deriving anything:

- **Finding 3, "What this changes in the record"**, supplies *verbatim* replacement text for the
  completeness-programme report's ingredient-table row 16 and for the inference drawn from its
  verdict sentence. Phase 1 applies that text; it does not compose its own.
- **Finding 3's four-component obstruction (O1)-(O4)** is the replacement verdict. (O1) —
  determinization to Rabin or parity is `proof_wanted` even in the fork — is flagged by the report
  as the cheapest open question in the whole assessment, and is what Phase 2 files.
- **Finding 2** settles deliverable (2) in two parts and names the dispatch's framing of it as a
  category error: the full-product lemma at the separation-consumption point is a TaskFrame
  semantics obligation that no CSLib version can discharge, and remains this repository's own
  (the completeness-programme report's row 8, unchanged). The automaton-side indexed conjunctive
  product is genuinely absent from both CSLib trees, and is costed at 100-150 lines. Phase 4
  records that row 8 is deliberately left exactly as written.
- **Finding 4** is a recommendation-only dependency assessment: do not `require` either tree now.
  That is a standing no-op, recorded in Phase 4, never executed.
- **Finding 0** fixes what the archived survey's prior art does and does not discharge, and
  Finding 1e corrects two factually wrong premises in this task's own dispatch (`prod_run_eq` is
  fork-only, not upstream; the fork is 4717 ahead **and 235 behind**). Both belong in the
  close-out record so a later reader does not re-inherit them.
- **The report's recommendations 4 and 6** concern the CSLib repository, not this one, and are
  recorded as deliberately-not-filed in Phase 4 rather than turned into tasks here.

### Prior Plan Reference

No prior plan for this task. The structural precedent followed here is the completeness-programme
task's own plan (`specs/879_lplus_ztime_completeness_tm_plus_lc_programme/plans/01_lplus-ztime-completeness-programme.md`,
`[COMPLETED]`), which solved the same shape of problem — a report-only research task whose
implementation phases are record amendments, task filings, a ROADMAP amendment, and a close-out
summary. Three calibrations are carried from it as *lessons*, not as copied phases:

1. Its Phase 3 measured that `test-roadmap-generation.sh` exits 2 (environment) in this
   deployed-only tree because it resolves its subject in `source-store` mode with no deploy-tree
   fallback, and recorded `roadmap-integration.sh --regenerate --dry-run` plus `--print` as the
   covering substitute. Phase 3 below names that substitute up front rather than discovering it.
2. Its Phase 2 measured that `state-write.sh --audit-verdict` is subject to a 128 KB per-argv
   ceiling, and that a multi-proposal condensed audit file must be sliced per proposal. With two
   proposals this is unlikely to bite, but Phase 2 below names the slice remedy anyway.
3. Its Phase 2 measured that `update-task-status.sh --depends-on-add` has no no-status-change
   token for a `not_started` task, so an added edge went through `state-write.sh` under the mutex
   instead. Phase 2 below plans the edge that way from the start.

Effort calibration: that task's four phases of the same character came in at 2.75 hours total.
This plan carries the same four-phase shape with a smaller filing step, and the same estimate.

### Roadmap Alignment

No `roadmap_path` and no `roadmap_flag` were supplied in this dispatch, so the roadmap-review and
roadmap-update phases that a `--roadmap` run would mandate are not present. `specs/ROADMAP.md`
nevertheless exists (422 lines, read at plan time) and carries the standing refusal that the
completeness-programme report cites as the authority for its own verdict, in two bullets:

- the "MSO/Rabin route reaches ZTime only" bullet (lines 112-114 at plan time), whose sentence
  "Mathlib has no MSO, no ω-automata and no Rabin tree theorem, so step 5 is refused outright
  rather than deferred" states one of the two grounds this task re-tested;
- the "MSO decidability formalization is refused outright, not deferred" bullet (lines 320-325 at
  plan time), whose sentence "The refusal rests on Mathlib's inventory — no MSO syntax, no
  ω-automata, no determinization of ω-automata, no Rabin tree theorem (866 finding 8, held)"
  enumerates four grounds, two of which this task's report narrows.

Phase 3 amends exactly those two sentences. It is a *ground* amendment that leaves both refusals
standing: CSLib has nothing in MSO syntax and nothing at `S2S`, so the MSO refusal is carried by
those two clauses alone and is not weakened by anything in this report. The plan advances no
roadmap item and marks none complete.

## Goals & Non-Goals

**Goals**:

- The completeness-programme report's ingredient-table row 16, its verdict sentence's inference,
  its executive-summary statement of the Lean obstruction, its recommendation 6, and its
  `[CARRIED-UNVERIFIED]` evidence tag all state the re-measured position, with the NO-GO outcome
  preserved and its ground replaced, each amendment dated and citing this task's report.
- `specs/ROADMAP.md`'s two ω-automata-absence sentences state which of the enumerated grounds are
  load-bearing after the re-measurement, with both refusals left standing.
- The two recommendations this repository can own exist as filed `not_started` tasks with
  backlog-reconciliation evidence on each entry: the Muller-sufficiency paper question that the
  report calls the cheapest open question in the assessment, and the three method lessons destined
  for the source store.
- A close-out record states what was amended, what was filed, and — explicitly, so that neither
  reads as an oversight — that no `require` was added, no PR was opened, no CSLib-side lemma was
  written, and the completeness-programme report's row 8 (the full-product lemma) was deliberately
  left exactly as written because it is this repository's own obligation.

**Non-Goals**:

- No change under `FormalSystem/` or `Tests/`, and no new Lean source anywhere. This plan declares
  `Lean Intent: false` and writes no `.lean` file.
- No edit to `lakefile.toml` or `lake-manifest.json`, and no `require` on CSLib in any form. The
  report's dependency assessment is a recommendation and is recorded as such, not executed.
- No PR, no push, no `gh`/`glab` write operation. The report's upstreaming recommendation names
  work in `~/Projects/cslib` against `leanprover/cslib`; `rules/pr-prohibition.md` bars an agent
  from it unconditionally, and it is out of this task's scope besides.
- No edit in `~/Projects/cslib` or `~/Projects/cslib-pr648`. The (O2) closure lemma belongs
  wherever the Rabin layer lives and must not be mirrored into this tree; it is recorded as
  deliberately not filed, with its reason.
- No completeness claim, and no amendment that could be read as lifting the NO-GO. The outcome is
  preserved throughout; only the stated ground changes.
- No redeploy of `.claude/`. The dispatch reports the deployed tree as stale for six extensions,
  and the remedy is `deploy-headless.sh` — a whole-tree regeneration that is not this task's work
  and that no phase here claims.
- No hand-authored file under `.claude/**`. The three method lessons are filed as a task whose
  `file_scope` names source-store paths, per `rules/source-store-deploy-boundary.md`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| An amendment to the completeness-programme report reads as lifting the NO-GO | H | M | Every amendment preserves the outcome sentence and replaces only the inference; each carries a dated note naming "ground replaced, outcome preserved". Phase 1's verification criteria include a read-back that the amended text still says NO-GO and still does not describe T1 as refuted. |
| The ROADMAP amendment weakens the MSO refusal, which rests on more than ω-automata | H | M | The refusal has four enumerated grounds; only two are narrowed. The replacement text states that CSLib has nothing in MSO syntax and nothing at `S2S` (the report's Risks section re-verified that a `ZSequence`/bi-infinite grep over `Cslib/` returns only unrelated hits), so the refusal stands on the MSO-syntax and Rabin-tree-theorem clauses alone. Phase 3's verification reads the amended bullets back for the word "refused" and for the absence of any lifting language. |
| `test-roadmap-generation.sh` exits 2 (environment) rather than passing, as measured in this tree | M | H | Carried from the completeness-programme task's own measurement: the suite resolves its subject in `source-store` mode with no deploy-tree fallback and never reads `specs/ROADMAP.md`. Phase 3 names the covering substitute (`roadmap-integration.sh --regenerate --dry-run` exit 0 and `--print` exit 0 against the amended file) in its verification criteria, and records the outcome as a `#### Reasoned Exclusions` row if it fires. |
| A filed task duplicates or is subsumed by an already-open one (901 owns the Reynolds engine paper proof; 895 owns the AA rule) | M | M | `audit-task-proposals.sh` runs over both proposals before any write, and `state-write.sh`'s audit-evidence gate refuses the write outright unless a verdict object covers each new entry. Phase 2 carries a decision gate that narrows or drops on a surviving `duplicate-of-open`/`subset-of-open` rather than filing unchanged. |
| The Muller-sufficiency question is filed but dispatched after 901, which consumes its answer | M | M | Phase 2 adds the edge 901 ← the new number, so 901 cannot be dispatched first. The edge goes through `state-write.sh` under the mutex (`--depends-on-add` has no no-status-change token for a `not_started` task), followed by `validate-state.sh`'s cycle check. |
| `--audit-verdict`'s payload exceeds the 128 KB per-argv ceiling | L | L | Two proposals, not nine. If it fires, slice the committed audit file to a one-line per-proposal file for each call, as the precedent task did. |
| `meta` is a core task type but no `meta` task is currently open in this tree, so its routing is unexercised here | L | L | `meta` is one of the three always-available core task types in `.claude/CLAUDE.md`'s routing table, routed to `general-research-agent`/`planner-agent`/`general-implementation-agent`. Phase 2 confirms the filed entry's `task_type` renders in `TODO.md` and passes `validate-state.sh`; no routing is exercised by filing. |
| The dispatch's deploy-freshness warning tempts a redeploy mid-plan | M | L | Declared a non-goal above. A redeploy is a whole-tree-regeneration claim and belongs to its own task; no phase here lists the reserved whole-tree sentinel, because no phase regenerates the tree. |
| The full gate set is unavailable in this dispatch | L | M | Phase 4 follows a `## Batch Gate Deferral` directive if the dispatch carries one, recording the deferral in the summary's Verification section rather than claiming a gate run that did not happen. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 1, 3 |

Phases within the same wave can execute in parallel. Phases 1 and 2 touch disjoint files (the
completeness-programme report versus `specs/state.json`/`TODO.md` plus two new evidence files in
this task's directory) and neither consumes the other's output, so they are genuinely
independent. Phase 3 needs Phase 2's allocated task numbers to cite. Phase 4 closes everything and
is the terminal node.

### Phase 1: Amend the Completeness-Programme Report's Automaton Row and Verdict Ground [COMPLETED]

**Goal**: `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md`
states the re-measured position at every point where it asserted the overturned ground, with the
NO-GO outcome preserved verbatim and each amendment dated and sourced to this task's report.

**Tasks**:
- [ ] Re-read immediately before editing, confirming each anchor still matches exactly once:
  `grep -c 'not formalizable at this Mathlib pin' <report>` (1 expected, ingredient-table row 16,
  line 198 at plan time); `grep -c 'Mathlib at this pin has no ω-automata and no determinization' <report>`
  (1 expected, the NO-GO verdict paragraph, line 221 at plan time);
  `grep -c 'Mathlib has no ω-automata and no determinization, and the standing ruling' <report>`
  (1 expected, the executive-summary deliverable-4 bullet, line 33 at plan time);
  `grep -c 'nor any ω-automata determinization project' <report>` (1 expected, recommendation 6,
  line 251 at plan time); `grep -c 'Mathlib has no ω-automata or determinization' <report>`
  (1 expected, the evidence-tier table's `[CARRIED-UNVERIFIED]` row, line 278 at plan time); and
  `grep -c 'The Lean obstruction is named as determinization' <report>` (1 expected, Decisions
  item 5, line 239 at plan time). If a count differs, re-locate by content rather than editing
  blind; if an anchor is gone, record that in the Phase 1 notes and skip that edit rather than
  inventing a location.
- [ ] Replace ingredient-table row 16's third column with the verbatim replacement text given in
  this task's report, Finding 3, under "What this changes in the record" — the sentence beginning
  "ω-automata, the ω-regular closure lattice and Büchi complementation are landed in CSLib
  upstream" and ending "Not a Mathlib-absence refusal; a located and costed gap." Keep the row's
  first two columns byte-identical, and keep the table's pipe structure intact (the replacement
  must not introduce an unescaped `|`).
- [ ] In the NO-GO verdict paragraph, keep the sentence "Mathlib at this pin has no ω-automata and
  no determinization" and drop only the inference drawn from it — the clause asserting that the
  same obstruction blocks the MSO route and is refused there outright is what must go, replaced by
  a sentence naming the four relocated components (O1) determinization to Rabin or parity is
  `proof_wanted` even in the local fork; (O2) the indexed conjunctive product with a nameable
  initial state is absent from both CSLib trees, costed at 100-150 lines; (O3) determinization
  arrives as an existential over `Type`, not as nameable syntax; (O4) nothing in CSLib touches the
  remaining rows of the ingredient table. The paragraph's opening sentence —
  "**NO-GO on a Lean proof of T1, T2 or T3 today — a located obstruction.**" — stays byte-identical.
- [ ] Amend the executive-summary deliverable-4 bullet's obstruction clause the same way: keep
  "Mathlib has no ω-automata and no determinization", drop "and the standing ruling already
  refuses that project for the MSO route", and state instead that the obstruction is relocated to
  (O1)-(O4) per this task's report. Keep the bullet's GO/NO-GO verdicts byte-identical.
- [ ] Narrow recommendation 6 from "nor any ω-automata determinization project" to "nor a
  *determinization* project, which is largely done in the local CSLib fork — the live question is
  whether to depend on it, and this task's report recommends not depending on it now", preserving
  the recommendation's "do not file a Lean formalization of T3's completeness proof" clause and
  its "until P9 reports" gating.
- [ ] Upgrade the evidence-tier table's row for "Mathlib has no ω-automata or determinization"
  from `[CARRIED-UNVERIFIED]` to a measured tier, citing this task's report and the Mathlib
  revision the re-verification ran against (`.lake/packages/mathlib` at `79d0395a`, tag
  `v4.33.0-rc1`). Amend Decisions item 5 ("The Lean obstruction is named as determinization,
  aligning this front with the standing refusal on the MSO route") to record that the alignment
  with the MSO refusal does not hold and why, without disturbing the other Decisions items.
- [ ] Add one dated amendment note immediately under the report's `## Executive Summary` heading:
  `**Amended by** specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md, 2026-11-09:`
  followed by two sentences stating that the ground of the Lean NO-GO is replaced and the NO-GO
  itself preserved, and that the ingredient table's row 8 (the full-product lemma) is unchanged
  because it is this repository's own TaskFrame-semantics obligation that no CSLib version can
  discharge. Do not add a second note per edit site; one note plus the in-place amendments is the
  record.
- [ ] Read the amended file back and confirm: the string "NO-GO on a Lean proof" still occurs; the
  report nowhere says T1 is refuted; no sentence states or implies that a Lean completeness proof
  is now available; and `git diff` shows no hunk outside the six anchor regions and the new
  amendment note.
- [ ] Record an issue-log entry (`issue-record.sh --kind issue|win ... --phase plan`-equivalent
  with `--phase implement --dispatch-seq <this dispatch's seq>`) naming any anchor whose count
  differed, or a `win` attesting that all six matched once.
- [ ] Commit the amended report and this plan by explicit path (`git-commit-phase.sh`, or
  `git-commit-scoped.sh ... -- <paths>`); never a directory or glob pathspec.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for both touched paths, so no suite covers either; both lie entirely under `specs/**` (sub-case (a)) and the amended file is a `report` artifact, so the covering check is `bash .claude/scripts/validate-artifact.sh specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md report` exiting 0, together with the `prose` row's diff read-through confirming every hunk is one of the six anchor amendments or the single new amendment note.

**Scope Hypothesis**: exactly two files change, and within the completeness-programme report exactly seven hunks appear — six in-place amendments at the anchors located by the first task (row 16, the NO-GO verdict paragraph, the executive-summary deliverable-4 bullet, recommendation 6, the evidence-tier row, Decisions item 5) plus one new amendment note under `## Executive Summary`. Anchor line numbers at plan time: 198, 221, 33, 251, 278, 239, in a 286-line file; re-measure with the first task's greps rather than trusting these. Confirm at implementation time by `git diff -U0 -- <report>` showing seven hunks and no more; if an anchor is absent, the count is lower and the Phase 1 notes say which and why.

**Files to modify**:
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` - six in-place sentence/cell amendments at the anchors above, plus one dated amendment note under `## Executive Summary`; each anchor confirmed present at plan time
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/plans/01_cslib-omega-automata-nogo-reassessment.md` - Phase 1 notes: the six anchor counts measured before and after

**Verification**:
- Each of the six greps in the first task matches exactly once after the edit (every amended passage retains its anchor text), or the Phase 1 notes record a skipped anchor.
- `bash .claude/scripts/validate-artifact.sh specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md report` exits 0.
- `git diff -U0 -- specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` shows exactly seven hunks.
- `grep -c 'NO-GO on a Lean proof' <report>` is unchanged from its pre-edit value, and a read of the amended passages confirms no lifting language and no completeness claim.
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty.
- `git diff --staged --name-only` names only the two files above.

#### Phase 1 Notes (measured 2026-11-09, dispatch_seq 3)

**Anchor counts.** All six anchors matched exactly once before editing, at the plan-time line
numbers, in a 286-line file (288 after):

| Anchor | Before | After | Line | Disposition |
|---|---|---|---|---|
| `not formalizable at this Mathlib pin` | 1 | 0 | 198 | replaced (row 16, Evidence/proposal cell) |
| `Mathlib at this pin has no ω-automata and no determinization` | 1 | 1 | 221 | kept; only the inference after it replaced |
| `Mathlib has no ω-automata and no determinization, and the standing ruling` | 1 | 0 | 33 | first half kept (counts 1 on its own), `and the standing ruling …` clause dropped |
| `nor any ω-automata determinization project` | 1 | 0 | 251 | narrowed per plan |
| `Mathlib has no ω-automata or determinization` | 1 | 1 | 278 | kept; evidence tier upgraded |
| `The Lean obstruction is named as determinization` | 1 | 1 | 239 | kept; the MSO-alignment clause corrected |

The plan's verification criterion "each of the six greps matches exactly once after the edit" is
**unsatisfiable for the three rows that count 0**, because this phase's own task list mandates
replacing or narrowing exactly the text those greps match. The substituted check, which all three
pass: each anchor's deliberately-kept half still counts 1 —
`Mathlib has no ω-automata and no determinization` (1), the recommendation-6 clause
`Do not file** a Lean formalization of T3's completeness proof` (1), and its `until P9 reports
whether a progress-measure replacement exists` gating (1).

**Hunks.** `git diff -U0` shows exactly **7** hunks, matching the Scope Hypothesis: six in-place
amendments plus the one dated amendment note under `## Executive Summary`. `git diff --stat`:
8 insertions, 6 deletions, one file.

**Row-16 column resolution (deviation).** The phase text says to replace "the third column" while
keeping "the row's first two columns byte-identical", but the ingredient table has four columns
(`#`, `Ingredient`, `Status`, `Evidence / proposal`) and the overturned ground lives in the
fourth. The verbatim replacement text was placed in the fourth cell; the `Status` cell
`paper (held: Safra/Piterman in corpus)` is left byte-identical, since the ingredient remains a
paper-level step and that cell carried none of the overturned claim.

**Outcome-preservation read-back.** `NO-GO on a Lean proof` still occurs twice (unchanged). The
verdict paragraph's opening `**NO-GO on a Lean proof of T1, T2 or T3 today — a located
obstruction.**` is byte-identical. The executive summary's deliverable-4 verdict string
`GO for T3 as a staged paper programme … NO-GO on a Lean proof of any of T1-T3 today` is
byte-identical. No sentence states T1 is refuted, and a grep for lifting language
(`completeness proof is now available`, `NO-GO is lifted`, `completeness is now formalizable`)
returns 0. Ingredient-table **row 8 is byte-identical** to its pre-edit text (now line 192).

**Gates.** `validate-artifact.sh … report` → `[PASS] report artifact is valid (0 warning(s))`,
exit 0. `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` → empty.

**Process deviation.** The `[IN PROGRESS]` marker was not set before this phase's first edit; the
heading went from `[NOT STARTED]` to `[COMPLETED]` after the edits and verification completed.
Recorded in the issue log. Phases 2-4 set the marker first.

**Timing**: 0.75 hours

---

### Phase 2: File the Two Owned Follow-Ups, With Backlog Evidence [COMPLETED]

**Goal**: Two new `not_started` entries exist in `specs/state.json`, each carrying
backlog-reconciliation evidence in its own `audit_verdict` field and a declared `file_scope`; the
Reynolds-engine paper-proof task depends on the Muller-sufficiency question; `TODO.md` renders both.

**Tasks**:
- [ ] Write `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/task-proposals.json` as a
  two-element JSON array, each element carrying exactly the four keys
  `{id, title, description, file_scope}` that `audit-task-proposals.sh` consumes:
  - `id: "muller_sufficiency_for_auxiliary_atoms_rule_ztime"`, `file_scope: []` (a paper
    question, no file target). Title and description from this task's report, recommendation 1 and
    Finding 3 (O1): settle whether a deterministic **Muller** automaton suffices for the
    Auxiliary-Atoms rule and the ban/lull mechanism at ZTime, or whether Rabin or parity is
    genuinely needed. The description must name what makes it answerable without Lean work —
    Reynolds' Lemma 13/26 and the expressibility of `infOcc ∈ accept` by state-valued atoms as a
    finite disjunction over `F ∈ accept` of `⋀_{b∈F} GF b ∧ ⋀_{b∉F} FG ¬b` — and must record the
    stake: if Muller suffices, the local CSLib fork's already-proved `IsRegular.iff_da_muller`
    *is* the determinization the architecture needs and (O1) vanishes; if Rabin is needed,
    `Muller.toRabin_exists` (`DA/Conversions.lean:112`, `proof_wanted`) becomes the
    single highest-value gap in either CSLib tree.
  - `id: "proof_wanted_trust_surface_and_external_library_dependency_assessment"`, with
    `file_scope` naming the source-store paths resolved from `.claude-extensions.json` (confirmed
    present at plan time except the new pattern file):
    `agent-system/extensions/lean/context/project/lean4/domain/metadata-trust-surfaces.md`,
    `agent-system/extensions/lean/context/project/lean4/patterns/external-library-dependency-assessment.md`
    (new), `agent-system/extensions/lean/index-entries.json`,
    `agent-system/extensions/core/context/formats/report-format.md`,
    `agent-system/extensions/core/index-entries.json`. The description carries all three method
    lessons from this task's report's Context Extension Recommendations: that `proof_wanted`
    elaborates and discards so a zero `sorry` count and a clean `#print axioms` are *both* blind
    to it (five named-but-absent theorems were found this way), with `grep -c '^proof_wanted'` as
    the only reliable detector; the external-library dependency-assessment checklist (read
    upstream claims through `git show upstream/main:<path>` rather than a fork worktree; measure
    `rev-list --left-right --count` in both directions; compare `lean-toolchain` before Mathlib
    revs; verify a build cache post-dates its sources before trusting `#print axioms`; compute the
    import closure rather than the repository line count); and the "ground overturned, outcome
    preserved" distinction for a verdict amendment. Note in the description that these must be
    authored in the source store, never under `.claude/**`.
- [ ] Run `bash .claude/scripts/audit-task-proposals.sh --proposals-file specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/task-proposals.json`
  and write its output to `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/task-proposals-audit.ndjson`.
  Read the verdicts in full.
- [ ] Decision gate: proceed on `genuinely-new` or an aggregator-only `overlaps-open`. On a
  `duplicate-of-open` or `subset-of-open` that survives inspection — the ones to inspect by name
  are 901 (the two-sided Reynolds engine paper proof) and 895 (the formula-level AA rule) against
  the Muller-sufficiency proposal — narrow `file_scope`/scope and re-run the audit with the same
  `id`, or drop and record the reason in the Phase 2 notes. Do not file unchanged.
- [ ] Record the pre-filing baseline: `jq '.active_projects | length' specs/state.json` and
  `jq '.next_project_number' specs/state.json`. `--allocate-into` derives its number from
  membership, not from this cache, so read each allocated number from the script's own output
  rather than from the baseline.
- [ ] File the two entries, one `state-write.sh` call each, appending with `+=` only (never a
  wholesale `.active_projects = [...]`), `title`/`description`/`file_scope` verbatim from
  `task-proposals.json`, `task_type` `formal` for the Muller question and `meta` for the method
  lessons, `dependencies: []` on both, `priority: "medium"`, `artifacts: []`,
  `next_artifact_number: 1`:
  `bash .claude/scripts/state-write.sh '.active_projects += [{project_number: $n, project_name: "<id>", status: "not_started", task_type: "<formal|meta>", title: "<title>", description: "<description>", file_scope: <file_scope>, dependencies: [], priority: "medium", created: $now, last_updated: $now, next_artifact_number: 1}]' --session-id "$session_id" --allocate-into n --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --audit-verdict specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/task-proposals-audit.ndjson --regen-todo`.
  If the audit payload trips the 128 KB per-argv ceiling, pass a one-line per-proposal slice of the
  committed audit file to each call instead.
- [ ] Add the serialization edge 901 ← the Muller question's allocated number, so the Reynolds
  engine paper proof cannot be dispatched before the acceptance-condition question it consumes is
  settled. `update-task-status.sh --depends-on-add` has no no-status-change token for a
  `not_started` task, so append the edge via `state-write.sh` under the mutex with a `+=` on that
  entry's `dependencies`, then confirm with
  `jq '.active_projects[] | select(.project_number==901) | .dependencies' specs/state.json`. If
  inspection at the decision gate showed the question is genuinely inside 901's own remit rather
  than upstream of it, skip the edge and record that in the Phase 2 notes instead.
- [ ] Verify each new entry: `project_name` equals its proposal `id`; `audit_verdict` is present
  (the gate records it verbatim); `file_scope` is `[]` for the Muller question and the five named
  source-store paths for the method lessons; `dependencies` is `[]` on both.
- [ ] Run `bash .claude/scripts/validate-state.sh` and read its output in full; exit 0 required,
  including its cycle check over the new edge.
- [ ] Render a confirmation table (allocated number, title, task type, dependencies, backlog
  check with `scope-blind` reported as a count) into the Phase 2 notes of this plan.
- [ ] Record an issue-log entry for this phase (`win` or `issue`), or attest in the Phase 2 notes
  that nothing arose.
- [ ] After `git status --short` confirms no sibling's uncommitted hunks are mixed in, commit
  `specs/state.json`, `specs/TODO.md`, the two new evidence files, and this plan by explicit path.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: the edit is confined to `specs/state.json` plus the `TODO.md` view generated from it, two new evidence files under this task's own directory, and this plan's notes; `bash .claude/scripts/validate-state.sh` is the whole-file consistency lint for exactly that pair, including the Check 12 allocation invariant that `--allocate-into` writes against and the dependency-cycle check the new edge needs, so no suite subset is claimed.

**Scope Hypothesis**: exactly two new `active_projects` entries are added, `next_project_number` is regenerated to the next free number past them, exactly one existing entry (901) gains exactly one dependency, and no other entry changes. Two new files appear under `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/`. Baseline at plan time: 902 is the only entry at or above 902, 898-901 are `not_started`, and `next_artifact_number` for 902 is 2 (so this round's artifacts are numbered `01`). Confirm at implementation time by diffing `jq '.active_projects | length'` before and after (+2) and by `validate-state.sh` exiting 0; if the decision gate drops or narrows a proposal, the count is lower and the Phase 2 notes say which and why. The `file_scope` of the method-lessons entry names source-store paths that do not exist in this repository's own tree — that is correct and matches established precedent for source-store work, and `file_scope` is descriptive rather than filesystem-validated.

**Files to modify**:
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/task-proposals.json` - new; the two proposals, four keys each
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/task-proposals-audit.ndjson` - new; the audit output consumed by `--audit-verdict`
- `specs/state.json` - append two `active_projects` entries via `state-write.sh` under the mutex; append one dependency to entry 901
- `specs/TODO.md` - regenerated by `--regen-todo`; never hand-edited
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/plans/01_cslib-omega-automata-nogo-reassessment.md` - Phase 2 notes: the confirmation table with allocated numbers

**Verification**:
- `bash .claude/scripts/validate-state.sh` exits 0, cycle check included.
- Two new entries, each with `project_name` equal to its proposal `id`, an `audit_verdict` field, and the declared `file_scope`; entry 901 depends on the Muller question's number (or the Phase 2 notes record why the edge was skipped).
- `jq -e . specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/task-proposals.json` succeeds and the array has two elements; every line of the audit NDJSON is `jq -e .`-valid.
- `specs/TODO.md` renders both new tasks with bracket-only artifact-link format and no `[name](path)` links.
- `git diff --staged --name-only` names only the five files above.
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty.

#### Phase 2 Notes (measured 2026-11-09, dispatch_seq 3)

**Baseline before filing**: `.active_projects | length` = 65, `next_project_number` = 903.
**After filing**: length = 67 (+2, as the Scope Hypothesis predicted), `next_project_number` = 905.

**Confirmation table**

| # | Title | Type | `file_scope` | Dependencies | Backlog check |
|---|---|---|---|---|---|
| 903 | Settle whether a deterministic Muller automaton suffices for the Auxiliary-Atoms rule and the ban/lull mechanism at ZTime, or whether Rabin or parity is genuinely needed | `formal` | `[]` (a paper question, no file target) | `[]` | 465 verdicts: 452 `scope-blind` (count), 12 `covered-by-closed` (scores 0.409-0.551, all semantic-shortlist noise), 1 `duplicate-of-open` — **against task 902 itself**, rejected on inspection |
| 904 | Record three method lessons in the source store: `proof_wanted` as a trust surface, the external-library dependency-assessment checklist, and ground-overturned-outcome-preserved verdict amendments | `meta` | the 5 declared source-store paths | `[]` | 471 verdicts: 452 `scope-blind` (count), 19 `covered-by-closed` (scores 0.352-0.5), **0** `duplicate-of-open`, **0** `subset-of-open` |

Both entries carry an `audit_verdict` field (written verbatim by `state-write.sh`'s audit-evidence
gate) and `project_name` equal to their proposal `id`.

**Decision gate.** Proceeded on both, unchanged and un-narrowed.

- The single `duplicate-of-open` is a **self-match against task 902**
  (`semantic_score` 0.48, `mechanical_class: none`) — unsurprising, since the proposal is drawn
  verbatim from 902's own report. It does not survive inspection: 902 is a report-only research
  task that explicitly declines to answer the Muller question and whose recommendation 1 is to
  file it.
- The two tasks the plan named for inspection came back **clear**. 901 scored 0.219 (Muller
  proposal) and 0.167 (method-lessons proposal) with verdict `scope-blind` only; **895 emitted no
  verdict at all** for either proposal. 901's own description independently confirms the edge
  direction: it names "the two deterministic **Rabin** automata over colour words" as its own
  subject matter, so it *presupposes* the answer 903 settles. 903 is genuinely upstream of 901,
  not inside its remit, and the edge was added rather than skipped.
- The 31 `covered-by-closed` verdicts are semantic-shortlist noise at scores 0.35-0.55 with
  `mechanical_class: none` throughout. The two worth naming: #736 (the archived CSLib ω-automata
  survey) at 0.417 against the Muller proposal — 902's Finding 0 already fixes that this survey
  never asks the acceptance-condition question; and #785 at 0.5 against the method-lessons
  proposal. Neither discharges either proposal.

**Serialization edge.** 901's `dependencies` went `[893]` → `[893, 903]`, appended via
`state-write.sh` under the mutex with a `map(... .dependencies += [903] ...)` filter, as the plan
directed (`--depends-on-add` has no no-status-change token for a `not_started` task). 903's own
`dependencies` is `[]`, so no cycle is possible; confirmed mechanically below.

**`--audit-verdict` payload exceeded the ceiling, and the plan's remedy was insufficient.**
`state-write.sh` passes the audit payload through argv (`--argjson verdicts`), so the 128 KB
per-argv ceiling applies. The plan's remedy — "slice the committed audit file to a one-line
per-proposal file" — does not help, because `audit-task-proposals.sh` **already** emits exactly
one line per proposal and each line is ~140 KB, dominated by the 452 `scope-blind` verdicts (one
per corpus record declaring no `file_scope`). Remedy applied: per-proposal condensed slices
keeping **every** non-`scope-blind` verdict verbatim and collapsing the 452 `scope-blind` verdicts
to a count plus a provenance note — which is what `context/patterns/backlog-reconciliation.md`'s
own Pass 1 guidance prescribes for rendering `scope-blind`. 66 KB each, under the ceiling. The
unabridged audit is committed at `task-proposals-audit.ndjson`, so no evidence is lost.

**Source store unreachable (plan premise corrected).** The plan states the five source-store paths
were "confirmed present at plan time except the new pattern file". Not reproducible: this
repository's `.claude-extensions.json` carries **no `source_dir` key** (its only keys are
`extensions` and `version`), and there is no `agent-system/` tree in this repo or anywhere under
`~/Projects`. The filing stands unchanged — `file_scope` is descriptive, not
filesystem-validated, and this phase's own Scope Hypothesis anticipates exactly this. Both
lessons were instead re-confirmed genuinely unimplemented against the deployed mirror:
`.claude/context/project/lean4/domain/metadata-trust-surfaces.md` contains **0** occurrences of
`proof_wanted`, and `.claude/context/project/lean4/patterns/external-library-dependency-assessment.md`
does not exist.

**Gates.** `jq -e` succeeds on `task-proposals.json` (2 elements, all four required keys on each)
and on both lines of `task-proposals-audit.ndjson`. `specs/TODO.md` renders 903 and 904, and a
grep for the prohibited `[name](path)` artifact-link form returns 0.
`validate-state.sh --deep` → **19 passed, 19 warnings, 0 failed, exit 0**, with
`No dependency cycles detected among active_projects`, `No dangling dependency references` and
`TODO.md is in sync … (regenerated content is byte-identical)` all explicitly observed. (A bare
`validate-state.sh` does **not** reach the cycle check — it is Check D5, inside the `--deep`
block; the plan's "cycle check included" criterion requires `--deep`.) The 19 warnings are all
pre-existing legacy `file_scope` visibility findings on tasks 125-502, none introduced here.
`git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` → empty.

**Observation handed forward, not acted on.** Task 901's description still carries the ground this
task overturned ("absent from Mathlib, and is not to be filed until that dependency is either
supplied or replaced by a progress-measure argument"). Amending task *descriptions* is outside
this plan's scope, which names only the completeness-programme report and `specs/ROADMAP.md` as
amendment targets. Recorded in the summary's Follow-ups.

**Timing**: 0.75 hours

---

### Phase 3: Narrow the ROADMAP's omega-Automata Absence Ground [NOT STARTED]

**Goal**: `specs/ROADMAP.md`'s two ω-automata-absence sentences state which of the enumerated
grounds survive the re-measurement, with both refusals left standing and the Muller-sufficiency
question's owner named; nothing else in the file changes, and nothing at or after the generated
coverage-appendix marker changes.

**Tasks**:
- [ ] Re-read immediately before editing: `grep -n 'Mathlib has no MSO, no ω-automata' specs/ROADMAP.md`
  (one hit expected, in the "MSO/Rabin route reaches ZTime only" bullet, line 113 at plan time);
  `grep -n "The refusal rests on Mathlib's inventory" specs/ROADMAP.md` (one hit expected, in the
  "MSO decidability formalization is refused outright" bullet, line 321 at plan time); and
  `grep -n 'Coverage appendix (uncovered tasks)' specs/ROADMAP.md` to locate the
  generated-content boundary (422-line file at plan time). If a count differs, re-locate by
  content rather than editing blind; if a sentence is gone, record that in the Phase 3 notes and
  skip it.
- [ ] Amend the first sentence to keep its Mathlib claim and its refusal, and to add that the
  refusal is carried by the MSO-syntax and Rabin-tree-theorem clauses specifically rather than by
  the ω-automata clause — because CSLib upstream carries the ω-regular closure lattice including
  `IsRegular.compl` (proved) and the local fork carries `IsRegular.iff_da_muller` (proved,
  sorry-free, measured clean), while CSLib has nothing in MSO and nothing at `S2S`. Cite this
  task's report. The clause "so step 5 is refused outright rather than deferred" stays.
- [ ] Amend the second sentence the same way: keep all four enumerated grounds and the
  "not on gap G1" clause, and append that the ω-automata and determinization clauses are true of
  Mathlib (re-verified against `.lake/packages/mathlib` at `79d0395a`) but false of the reachable
  Lean ecosystem, so the refusal now rests on the MSO-syntax and Rabin-tree-theorem clauses alone,
  neither of which CSLib has in any form. The bullet's own closing sentence — that the refusal
  stands on its own grounds regardless — stays byte-identical.
- [ ] In whichever of the two bullets reads more naturally, name the owner of the open
  acceptance-condition question in one clause: the Muller-sufficiency task's number allocated in
  Phase 2. Do not restate the question; one citation is the record.
- [ ] Confirm nothing at or after the `**Coverage appendix (uncovered tasks)**:` marker changed
  (`git diff -U0 specs/ROADMAP.md` shows hunks only above it) and that the amendments are the only
  hunks.
- [ ] Read the amended bullets back and confirm both still contain "refused" and neither contains
  any language that could be read as lifting the MSO refusal or as making a completeness claim.
- [ ] Write the Phase 3 notes into this plan: the anchor counts before and after, the hunk list,
  and the generator evidence (or the Reasoned Exclusions row, if the suite's environment exit-2
  fires).
- [ ] Record an issue-log entry for this phase (`win` or `issue`), or attest in the Phase 3 notes
  that nothing arose.
- [ ] Commit `specs/ROADMAP.md` and this plan by explicit path.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select specs/ROADMAP.md` returns `test-engine-written-state-paths-lib.sh,test-roadmap-generation.sh`, so the covering check is `bash .claude/scripts/tests/run-all.sh --only test-engine-written-state-paths-lib.sh,test-roadmap-generation.sh` with its exit status read (confirming the generator still round-trips the hand-authored body), together with the `prose` row's diff read-through confirming every hunk is one of the sentence-level amendments above the coverage-appendix marker; this plan's own path returns `__FULL_SWEEP__` and adds no suite.

**Scope Hypothesis**: `specs/ROADMAP.md` is the only file this phase's amendment touches, and within it exactly two or three hunks appear (the two sentence amendments, plus a third only if the task-number citation lands in a separate bullet from both), all in the hand-authored body above the coverage-appendix marker. At plan time `specs/ROADMAP.md` is 422 lines, the first anchor is at line 113, the second at 321, and the coverage-appendix marker is below both; re-measure with the first task's greps before editing. Confirm by `git diff -U0 -- specs/ROADMAP.md` showing no hunk at or after the marker. The Phase 3 notes written into this plan are bookkeeping on this plan's own record and are deliberately excluded from this phase's `Files to modify` so the tier claim below is measured against the amendment target alone; writing them is still required by the task list above. The anticipated `test-roadmap-generation.sh` exit 2 is an environment outcome, not a scope change, and is handled in the verification criteria below.

**Files to modify**:
- `specs/ROADMAP.md` - two sentence-level amendments in the hand-authored body (the "MSO/Rabin route reaches ZTime only" bullet's Mathlib-absence sentence, and the "MSO decidability formalization is refused outright" bullet's grounds sentence), plus one task-number citation; both anchors confirmed present at plan time. If an anchor is absent at implementation time, skip that edit and record it in the Phase 3 notes rather than inventing a location

**Verification**:
- Both greps in the first task match exactly once after the edit (each amended sentence retains its anchor text).
- `git diff -U0 -- specs/ROADMAP.md` shows two or three hunks, none at or after the coverage-appendix marker.
- `bash .claude/scripts/tests/run-all.sh --only test-engine-written-state-paths-lib.sh,test-roadmap-generation.sh` exits 0. If `test-roadmap-generation.sh` exits 2 for the environment reason named in Risks (it resolves its subject in `source-store` mode with no deploy-tree fallback and never reads `specs/ROADMAP.md`), record a `#### Reasoned Exclusions` row for that half with the suite's stderr as evidence, and substitute: `bash .claude/scripts/roadmap-integration.sh --regenerate --dry-run` exits 0 against the amended file and `bash .claude/scripts/roadmap-integration.sh --print` exits 0.
- Both amended bullets still contain "refused"; neither contains lifting language, and the amended text makes no completeness claim.
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty.

---

### Phase 4: Close-Out Record and Final Gate [NOT STARTED]

**Goal**: The task's close-out record exists, states what was amended and filed and — explicitly —
what was deliberately not acted on, and the repository passes its full gate set with
`FormalSystem/`, `Tests/`, `lakefile.toml`, and `lake-manifest.json` untouched.

**Tasks**:
- [ ] Write `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/summaries/01_cslib-omega-automata-nogo-reassessment-summary.md`
  per `summary-format.md` (all required headings verbatim), covering:
  - The report's verdict in three sentences: the NO-GO's stated ground (ω-automata absent from
    Mathlib, therefore in the MSO refusal class) is overturned; the NO-GO itself stands on four
    relocated components (O1)-(O4); the dependency recommendation is to `require` nothing now.
  - Deliverable (2)'s two-part answer in two sentences, naming the category error: the
    full-product lemma at the separation-consumption point is a TaskFrame-semantics obligation no
    CSLib version can discharge and remains this repository's own (the completeness-programme
    report's row 8, deliberately unchanged), while the automaton-side indexed conjunctive product
    is genuinely absent from both CSLib trees and is costed at 100-150 lines.
  - What the archived survey's prior art discharged and what it did not, and the two dispatch
    premises this task's report corrected (`prod_run_eq` is fork-only, not upstream; the fork is
    4717 ahead **and 235 behind**, and its worktree lacks `OmegaSequence/Topology.lean`), so a
    later reader does not re-inherit either.
  - The Phase 1 amendments, the Phase 3 ROADMAP amendments, and the Phase 2 confirmation table
    with allocated numbers and the 901 edge.
  - An explicit paragraph recording what is deliberately **not** done, each with its reason, so
    none reads as an oversight: no `require` on either CSLib tree (the assessment is a
    recommendation; a `require` decision belongs after the ingredient table's remaining rows have
    landed, not before); no upstream PR for the determinization block or the Rabin/Streett/Parity
    layer (work in `~/Projects/cslib` against `leanprover/cslib`, barred to an agent by
    `rules/pr-prohibition.md` and out of scope here, with the report's own counterweight recorded
    — 0 of 11 prior PRs from this author are merged, and the ω-automata material has never been
    offered upstream); no (O2) closure lemma written anywhere (it belongs wherever the Rabin layer
    lives and must not be mirrored into `FormalSystem/`); and no redeploy of the stale `.claude/`
    tree.
  - Link this task's report and the amended completeness-programme report under `## References`.
- [ ] Confirm no library or build-file change: `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json`
  is empty, and `git diff --stat <this task's first commit>^..HEAD -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json`
  is empty.
- [ ] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh`. Read the output in full;
  do not infer a pass from the absence of visible errors. If this dispatch carries a
  `## Batch Gate Deferral` directive, follow it and record the deferral in the summary's
  Verification section instead of claiming a gate run that did not happen.
- [ ] Record a closing issue-log entry (`win` or `issue`) for this phase, or attest in the summary
  that nothing arose.
- [ ] Write `.orchestrator-handoff.json` and `.return-meta.json` (`status: "implemented"`,
  `dispatch_seq` echoed verbatim, `phases_completed`/`phases_total` as top-level integers), and
  commit the summary by explicit path.

**Timing**: 0.75 hours

**Depends on**: 1, 3

**Verification Tier**: full

**Scope Hypothesis**: exactly one new summary file is written in this phase, and no file under `FormalSystem/` or `Tests/`, and neither `lakefile.toml` nor `lake-manifest.json`, is modified by any phase of this plan. Confirm by the two `git` checks above, read before the gate run rather than after it.

**Files to modify**:
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/summaries/01_cslib-omega-automata-nogo-reassessment-summary.md` - new; the close-out record, including the deliberately-not-done paragraph

**Verification**:
- `bash .claude/scripts/validate-artifact.sh specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/summaries/01_cslib-omega-automata-nogo-reassessment-summary.md summary` exits 0.
- `bash .claude/scripts/verify-deploy.sh` runs to completion and is observed green (the complete gate set, not a `--only-gate` subset and not `--skip-slow`), or the batch deferral is recorded per the dispatch's directive.
- `bash .claude/scripts/validate-state.sh` exits 0.
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty, and the `git diff --stat` over this task's own commits for the same paths is empty.
- `.orchestrator-handoff.json` validates (the write-time `validate-handoff-location.sh` gate accepts it) and `.return-meta.json` carries `status: "implemented"` with `dispatch_seq` echoed.
- The summary's deliberately-not-done paragraph names all four omissions (no `require`, no PR, no (O2) lemma, no redeploy), each with a reason.

---

## Testing & Validation

- [ ] Each of Phase 1's six anchor greps matches exactly once after the amendment, or the Phase 1 notes record a skipped anchor by name.
- [ ] `bash .claude/scripts/validate-artifact.sh specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md report` exits 0.
- [ ] The amended completeness-programme report still states NO-GO on a Lean proof, still does not describe T1 as refuted, and its ingredient-table row 8 is byte-identical to its pre-edit text.
- [ ] `jq -e .` succeeds on `task-proposals.json` (two elements) and on every line of `task-proposals-audit.ndjson`.
- [ ] `bash .claude/scripts/validate-state.sh` exits 0 after the filings, cycle check included.
- [ ] Two new entries with `project_name` equal to their proposal `id`, `audit_verdict` present, and the declared `file_scope`; entry 901 carries the new edge or the Phase 2 notes record why not.
- [ ] Both Phase 3 ROADMAP anchors match once after the amendment; no hunk at or after the coverage-appendix marker; both amended bullets still contain "refused".
- [ ] `bash .claude/scripts/tests/run-all.sh --only test-engine-written-state-paths-lib.sh,test-roadmap-generation.sh` exits 0, or the environment exit-2 is recorded as a Reasoned Exclusion with the `roadmap-integration.sh --regenerate --dry-run` / `--print` substitute evidence.
- [ ] `bash .claude/scripts/validate-artifact.sh <summary-path> summary` exits 0.
- [ ] `bash .claude/scripts/verify-deploy.sh` observed green in the dispatch that closes Phase 4, or batch-deferred per directive.
- [ ] `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty at every phase boundary.
- [ ] No commit stages a directory or glob pathspec; every commit names files explicitly.
- [ ] No file under `.claude/**` and no file in `~/Projects/cslib` or `~/Projects/cslib-pr648` is modified by any phase.

## Artifacts & Outputs

- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/plans/01_cslib-omega-automata-nogo-reassessment.md` (this plan, carrying the Phase 1-3 notes written at implementation time)
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/task-proposals.json` (two proposals)
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/task-proposals-audit.ndjson` (backlog-reconciliation evidence consumed by `--audit-verdict`)
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/summaries/01_cslib-omega-automata-nogo-reassessment-summary.md` (the close-out record)
- Amended `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` (six in-place amendments plus one dated amendment note)
- Amended `specs/ROADMAP.md` (two sentence-level ground amendments plus one task-number citation)
- Two new `not_started` entries in `specs/state.json` (one `formal`, one `meta`), rendered into `specs/TODO.md`; one new dependency on entry 901
- Pre-existing and unchanged: `reports/01_cslib-omega-automata-nogo-reassessment.md`, every file under `FormalSystem/` and `Tests/`, `lakefile.toml`, `lake-manifest.json`

## Rollback/Contingency

Every phase is a small, single-concern change with its own commit, so reverting is a targeted
`git revert` of that commit. No phase discards working-tree changes, and this plan emits no
precautionary `git-snapshot.sh` step because none is needed.

- **Phase 1**: revert the commit. The six amendments replace text in place and the amendment note
  is additive, so the revert restores the prior wording exactly.
- **Phase 2**: the hazard is a wrongly-filed task, not a corrupted file. Remedy forward rather
  than by reverting a shared file that siblings also write this cycle: mark the entry `abandoned`
  via `bash .claude/scripts/update-task-status.sh`, which preserves `state.json`'s append-only
  discipline; remove the 901 edge with the script's dependency operations, never by hand. Do not
  hand-edit `state.json` or `TODO.md`, and do not `git revert` a `state.json` commit a sibling has
  since extended. The two evidence files are inert once consumed and can be reverted
  independently.
- **Phase 3**: revert the ROADMAP commit; the amendments replace sentences in place, so the revert
  restores the prior wording exactly. Nothing in the generated coverage appendix is touched, so no
  regeneration is needed after a revert.
- **Phase 4**: revert the summary commit.

If a rollback that would discard uncommitted work ever becomes genuinely necessary, follow
`.claude/context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation
shape, with the task number passed explicitly.
