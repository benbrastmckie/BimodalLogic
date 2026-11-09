# Implementation Summary: Task #902

- **Task**: 902 - Re-assess the L⁺ ZTime completeness NO-GO against CSLib's deterministic ω-automata inventory, including the local fork
- **Status**: [COMPLETED]
- **Started**: 2026-11-09T05:46:00Z
- **Completed**: 2026-11-09T06:34:00Z
- **Effort**: ~2.75 hours
- **Dependencies**: None
- **Artifacts**: plans/01_cslib-omega-automata-nogo-reassessment.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

This task re-tested exactly one premise of the completeness-programme report's Lean NO-GO: the
claim that deterministic ω-automata are "absent from Mathlib" and therefore in the same refusal
class as MSO. The research dispatch delivered all four stated deliverables; this implementation
dispatch landed their consequences in the records other tasks read. It is a record-and-handoff
dispatch: no Lean source, no build file, and no dependency declaration was touched by any phase.

**The verdict in three sentences.** The NO-GO's *stated ground* is overturned — ω-automata are not
absent from the reachable Lean ecosystem, since CSLib upstream carries the ω-regular closure
lattice including a proved `IsRegular.compl`, and the local CSLib fork carries McNaughton
determinization to Muller (`IsRegular.iff_da_muller`) proved in both directions, sorry-free, on
this project's own `v4.33.0-rc1` toolchain. The NO-GO *itself* stands, on four relocated
components: **(O1)** determinization to Rabin or parity is `proof_wanted` even in the fork;
**(O2)** the indexed conjunctive product with a nameable initial state is absent from both CSLib
trees, costed at 100-150 lines; **(O3)** determinization arrives as an existential over `Type`,
not as nameable syntax the AA rule can use; **(O4)** nothing in CSLib touches the remaining rows
of a 21-row ingredient table, so the finding removes one row and shortens no critical path. The
dependency recommendation is to `require` **nothing** now, in either form.

**Deliverable (2)'s answer, in two sentences, naming the category error.** The dispatch's question
("does the fork have the full-product / pasting lemma?") is not answerable as posed: that lemma is
a TaskFrame-semantics obligation about `WorldHistory`, `TaskFrame.IsRegular` and free pasting at a
state, which no version of CSLib contains or could contain — it remains this repository's own
obligation and is absent in-tree, so the completeness-programme report's ingredient-table row 8
stands exactly as written and was deliberately left byte-identical. The *automaton-side* indexed
conjunctive product, by contrast, is genuinely absent from both CSLib trees and the dispatch's
premise about it is right — `DA.prod` plus `prod_run_eq` is strictly weaker than the step needs —
but it is cheap, costed at 100-150 lines in the fork's existing idiom, because Rabin acceptance's
`∃ pair ∈ pairs` structure makes the finite *union* of DRA languages a DRA and
`Rabin.toStreett_language_eq` already delivers the complement on the same state space.

## What Changed

- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md`
  — six in-place amendments plus one dated amendment note under `## Executive Summary`; the NO-GO
  outcome preserved verbatim throughout and only its ground replaced. Amended: ingredient-table
  row 16's evidence cell; the NO-GO verdict paragraph's MSO-analogy inference; the
  executive-summary deliverable-4 bullet's obstruction clause; recommendation 6 (narrowed from
  "any ω-automata determinization project" to "a *determinization* project, which is largely
  done"); the evidence-tier table's row for the Mathlib-absence claim, upgraded from
  `[CARRIED-UNVERIFIED]` to measured; and Decisions item 5, which had asserted an alignment with
  the MSO refusal that does not hold.
- `specs/ROADMAP.md` — two sentence-level ground amendments, both refusals left standing. The
  "MSO/Rabin route reaches ZTime only" bullet now states that its refusal is carried by the
  MSO-syntax and Rabin-tree-theorem clauses specifically rather than by the ω-automata clause, and
  names task 903 as the owner of the open acceptance-condition question. The "MSO decidability
  formalization is refused outright" bullet now states that two of its four enumerated grounds are
  true of Mathlib but false of the reachable Lean ecosystem, so the refusal rests on the other two
  alone — neither of which CSLib has in any form.
- `specs/state.json`, `specs/TODO.md` — two new `not_started` entries, each carrying
  backlog-reconciliation evidence in its own `audit_verdict` field, plus one new dependency edge.
- `specs/902_.../task-proposals.json`, `task-proposals-audit.ndjson`,
  `audit-muller-condensed.ndjson`, `audit-meta-condensed.ndjson` — new; the proposals and the
  unabridged plus condensed backlog evidence.
- `specs/902_.../plans/01_cslib-omega-automata-nogo-reassessment.md` — Phase 1-3 notes written at
  implementation time, including Phase 3's `#### Reasoned Exclusions` record.
- `specs/902_.../summaries/01_cslib-omega-automata-nogo-reassessment-summary.md` — new; this file.

**Tasks filed (Phase 2 confirmation table)**

| # | Title | Type | `file_scope` | Dependencies | Backlog check |
|---|---|---|---|---|---|
| 903 | Settle whether a deterministic Muller automaton suffices for the Auxiliary-Atoms rule and the ban/lull mechanism at ZTime, or whether Rabin or parity is genuinely needed | `formal` | `[]` (a paper question) | `[]` | 465 verdicts: 452 `scope-blind` (count), 12 `covered-by-closed` (0.409-0.551), 1 `duplicate-of-open` — against task 902 itself, rejected on inspection |
| 904 | Record three method lessons in the source store: `proof_wanted` as a trust surface, the external-library dependency-assessment checklist, and ground-overturned-outcome-preserved verdict amendments | `meta` | 5 declared source-store paths | `[]` | 471 verdicts: 452 `scope-blind` (count), 19 `covered-by-closed` (0.352-0.5), 0 `duplicate-of-open`, 0 `subset-of-open` |

Serialization edge added: task **901**'s `dependencies` went `[893]` → `[893, 903]`, so the
two-sided Reynolds engine paper proof cannot be dispatched before the acceptance-condition
question it consumes is settled. 901's own description independently confirms the direction — it
names "the two deterministic **Rabin** automata over colour words" as its subject matter, and so
presupposes the very answer 903 settles.

## What the prior art discharged, and what it did not

The archived CSLib ω-automata survey
(`specs/archive/736_cslib_omega_automata_survey_and_e3_reopen_check/`) is prior art, not a
blocker. Of its six-item operator hand-off list: items (a), (b) and (f) bear on nothing here;
item (c) (three context-extension recommendations) is **still open** and is extended and filed as
task 904; item (d) (three WANTED literature sources) is **still open** and untouched; item (e)
("port nothing; treat cslib as a read-only reference", with the `require` dissent rejected) is
**partially discharged and its ground re-measured**.

It discharges parts of deliverable (1) — three of its claims re-verified true by direct read
(`iff_da_muller` `proof_wanted` upstream and proved in the fork; `NA/BuchiCompl.lean` still a
non-resource; the shared Ramsey core). It discharges **none** of deliverable (2), **none** of
deliverable (3) — the NO-GO it is being asked to re-test did not exist yet — the decisive half of
deliverable (4), nor deliverable (1)'s Rabin/Streett/Parity rows, which postdate its inventory.

**Two premises in this task's own dispatch were factually wrong and are corrected here**, so a
later reader does not re-inherit either: `DA.prod` **with `prod_run_eq`** is *not* upstream —
upstream has `prod` + `prod_mtr_eq` only, and `prod_run_eq` is fork-only; and the fork is
4717 commits ahead **and 235 behind** upstream, not merely ahead. The 235-commit lag is
load-bearing: upstream has since added `OmegaSequence/Topology.lean` (absent from the fork
worktree entirely) and `Languages/SafetyLiveness.lean`, the latter directly on-topic for the
observation that the violation language is not a safety language.

## Decisions

- **Amend the ground, never the outcome.** Every amendment preserves its record's verdict sentence
  byte-identically and replaces only the inference drawn from it. The amended
  completeness-programme report still says `NO-GO on a Lean proof` (twice, unchanged), its
  deliverable-4 GO/NO-GO verdict string is byte-identical, and no sentence in either amended file
  describes T1 as refuted or states that a Lean completeness proof is now available.
- **Row 8 left byte-identical, deliberately.** Finding 2 establishes it is this repository's own
  TaskFrame-semantics obligation; amending it would have implied CSLib bears on it, which is the
  category error the report corrects.
- **Both ROADMAP refusals left standing.** Only two of the MSO refusal's four enumerated grounds
  are narrowed. CSLib has nothing in MSO syntax and nothing at `S2S`, so the refusal is carried by
  the MSO-syntax and Rabin-tree-theorem clauses alone.
- **The `duplicate-of-open` verdict against task 902 was rejected on inspection**, being a
  self-match: 902 is a report-only research task that explicitly declines to answer the Muller
  question and whose recommendation 1 is to file it.
- **The audit payload was condensed, not truncated.** `state-write.sh` passes `--audit-verdict`
  through argv, so the 128 KB per-argv ceiling applies; each one-line per-proposal slice is
  ~140 KB, dominated by 452 `scope-blind` verdicts. The condensed slices keep **every**
  non-`scope-blind` verdict verbatim and collapse `scope-blind` to a count — which is what
  `backlog-reconciliation.md`'s own Pass 1 guidance prescribes for rendering it — and the
  unabridged audit is committed alongside, so no evidence is lost.

## What is deliberately NOT done, and why

Stated explicitly so that none of it reads as an oversight.

- **No `require` on either CSLib tree, and no edit to `lakefile.toml` or `lake-manifest.json`.**
  The dependency assessment is a recommendation and is recorded as such. A `require` decision
  belongs after the ingredient table's remaining rows have landed and the automaton is the last
  thing left — not before, while (O4) stands and CSLib removes one row from twenty-one. The
  assessment's measured reversal of *ground* is recorded for whenever that decision is taken: the
  fork matches this project's toolchain and its Mathlib pin is a 76-commit fast-forward inside one
  release window, where upstream demands a three-release toolchain jump **and** still lacks
  determinization entirely.
- **No upstream PR for the determinization block or the Rabin/Streett/Parity layer.** That is work
  in `~/Projects/cslib` against `leanprover/cslib`; `rules/pr-prohibition.md` bars an agent from
  it unconditionally, and it is outside this task's scope besides. The report's own counterweight
  is recorded with it: of 11 prior PRs from this author to upstream, **zero are merged** (8 closed
  unmerged, 3 open), and the ω-automata material has never been offered upstream — so that path
  has unbounded, so far unrealised latency and is not a substitute for settling (O1) on paper.
- **No (O2) closure lemma written anywhere.** It belongs wherever the Rabin layer lives and must
  not be mirrored into `FormalSystem/`. Recorded as deliberately not filed in this tree.
- **No redeploy of the stale `.claude/` tree.** The dispatch reports six extensions stale and the
  remedy is `deploy-headless.sh`, a whole-tree regeneration that is its own task and that no phase
  here claims.
- **No edit in `~/Projects/cslib` or `~/Projects/cslib-pr648`**, and no change under
  `FormalSystem/` or `Tests/`. Verified empty by `git status` and by a `git diff --stat` over this
  task's own three commits.
- **Task 901's description was not amended**, though it still carries the overturned ground.
  Amending task *descriptions* is outside this plan's scope, which names only the
  completeness-programme report and `specs/ROADMAP.md` as amendment targets. Handed forward below.

## Plan Deviations

- **Phase 1** altered: the row-16 instruction says to replace "the third column" while keeping
  "the row's first two columns byte-identical", but the ingredient table has four columns (`#`,
  `Ingredient`, `Status`, `Evidence / proposal`) and the overturned ground lives in the fourth.
  The verbatim replacement text was placed in the fourth cell and the `Status` cell left
  byte-identical, since the ingredient remains a paper-level step and that cell carried none of
  the overturned claim.
- **Phase 1** altered: its verification criterion ("each of the six greps matches exactly once
  after the edit") is unsatisfiable for three anchors whose own task text mandates replacing or
  narrowing exactly the text those greps match. Substituted check, which all three pass: each
  anchor's deliberately-kept half still counts 1.
- **Phase 1** deviation (process): the `[IN PROGRESS]` marker was not set before the phase's first
  edit; the heading went `[NOT STARTED]` → `[COMPLETED]` after edits and verification. No
  consequence in a single-agent dispatch with no resume, but the contract was not honoured in
  order. Phases 2-4 set the marker first.
- **Phase 2** altered: the plan's remedy for an oversized `--audit-verdict` payload ("slice the
  committed audit file to a one-line per-proposal file") is insufficient, because the audit script
  already emits one line per proposal and each is ~140 KB. Condensed per-proposal slices were used
  instead, as described under Decisions.
- **Phase 2** altered: the plan's "`validate-state.sh` exits 0, cycle check included" requires
  `--deep` — the dependency-cycle check is Check D5 inside the `--deep` block and a bare
  invocation never reaches it. Run as `--deep`.
- **Phase 2** corrected premise: the plan states the five source-store paths were "confirmed
  present at plan time except the new pattern file". Not reproducible — this repository's
  `.claude-extensions.json` carries **no `source_dir` key** and no `agent-system/` tree exists
  here or anywhere under `~/Projects`, so the source store is unreachable from this tree. The
  filing stands unchanged (`file_scope` is descriptive, not filesystem-validated, and this phase's
  own Scope Hypothesis anticipates exactly this), and both lessons were re-confirmed genuinely
  unimplemented against the deployed mirror instead.
- **Phase 3** `[COMPLETED WITH EXCLUSIONS]`: `test-roadmap-generation.sh` could not run in this
  tree (exit 2, environment — it resolves its subject in `source-store` mode with no deploy-tree
  fallback, and never reads `specs/ROADMAP.md`). Recorded as a `#### Reasoned Exclusions` row with
  the suite's stderr as evidence; the plan's named substitute was run and observed green.
- **Phase 3** corrected premise: the plan asserts the coverage-appendix marker "is below both"
  anchors and directs that no hunk land at or after it. Measured false — the marker is at line 171
  and anchor 2 at line 321 — so the stated check is unsatisfiable. The real hazard is narrower:
  `strip_coverage_appendix` discards content after the marker **only within the run-order
  section**, and both anchors sit outside it. Substituted check, which passes: neither hunk falls
  inside the run-order section and no coverage-appendix `/orchestrate` line changed.

## Verification

- Build: N/A — `Lean Intent: false`; no `.lean` file was written, read for proof state, or
  compiled by any phase. No `lake build` was run, and none was required: nothing under
  `FormalSystem/` or `Tests/` was touched.
- Sorry count: **0**, measured by `lean-sorry-census.sh` over the roots `lean-src-roots.sh`
  resolves (`FormalSystem`, `Tests/BimodalTest`, `BimodalTools` and their root modules); the
  inventory is empty.
- Vacuous count: **0** real. The vacuous-pattern grep returns exactly one line —
  `FormalSystem/Examples/TemporalStructures.lean:495`,
  `theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial` — which is a
  legitimate proof by `trivial` of a genuinely trivial domain-membership statement, not a
  placeholder, and is pre-existing (last touched by `f388012a8`, none of this task's commits).
- Axiom count: **14**, a pre-existing baseline **unchanged** by this task — the same count
  measured at this task's first commit's parent (`8310217fd^`). No `axiom` was introduced.
- This task modified **zero** `.lean` files: `git diff --name-only 8310217fd^..HEAD` contains no
  `.lean` path and no `.lean` file is dirty, so it could not have introduced any of the above.
- Tests: `bash .claude/scripts/tests/run-all.sh --only test-engine-written-state-paths-lib.sh,test-roadmap-generation.sh`
  → 1 passed, 1 failed. The failure is `test-roadmap-generation.sh` exiting **2** (environment),
  recorded as a Reasoned Exclusion; the substitute
  `roadmap-integration.sh --regenerate --dry-run` → exit 0 and `--print` → exit 0 against the
  amended file, with the dry-run leaving `specs/ROADMAP.md` at exactly its two amendment hunks.
- Full gate set: `bash .claude/scripts/verify-deploy.sh` → **`PASS -- 15 check(s), 0 failure(s)`**,
  exit 0. Tally: 14 `[PASS]`, 22 `[SKIP]` (all because this repository is a deploy consumer, not
  the source store — consistent with the unreachable source store found in Phase 2), 1 `[WARN]`
  (`lean still declares routing_hard/routing_agents_hard`, pre-existing and unrelated to this
  task). Not a `--only-gate` subset and not `--skip-slow`. No batch gate deferral directive was
  carried by this dispatch.
- State: `bash .claude/scripts/validate-state.sh --deep` → **19 passed, 19 warnings, 0 failed**,
  exit 0, with `No dependency cycles detected among active_projects`, `No dangling dependency
  references`, `No self-referential dependencies` and `TODO.md is in sync with … (regenerated
  content is byte-identical)` all explicitly observed. The 19 warnings are pre-existing legacy
  `file_scope` visibility findings on tasks 125-502, none introduced here.
- Artifacts: `validate-artifact.sh … report` on the amended completeness-programme report → PASS,
  0 warnings. `validate-artifact.sh … plan` on this task's plan → PASS, 0 warnings.
  `validate-artifact.sh … summary` on this file → recorded below.
- Scope: `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` → empty, and
  `git diff --stat <first commit>^..HEAD` over the same paths → empty. No file under `.claude/**`,
  `~/Projects/cslib` or `~/Projects/cslib-pr648` was modified. No commit staged a directory or
  glob pathspec; every commit named files explicitly.
- Hunk discipline: the amended completeness-programme report shows exactly **7** hunks (six
  amendments plus the dated note), matching its Scope Hypothesis; `specs/ROADMAP.md` shows exactly
  **2**, the low end of its "two or three".
- Files verified: Yes

## Impacts

- The completeness-programme report no longer licenses the inference that a Lean completeness
  proof is unreachable *because Mathlib lacks ω-automata*. Any task reading it now reads a located,
  costed four-component obstruction instead, with (O1) flagged as the cheapest thing anyone could
  do to the verdict.
- `specs/ROADMAP.md`'s two standing refusals are unchanged in force but now state which of their
  enumerated grounds are load-bearing, so a future reader cannot inherit a ground this task
  measured false — nor read the narrowing as a lifting.
- Task 901 is now serialized behind task 903, so the two-sided Reynolds engine write-up will not
  be drafted against an acceptance condition (Rabin) that may be unnecessary.
- The evidence tier of the Mathlib-absence claim rose from `[CARRIED-UNVERIFIED]` to measured, so
  the next record to cite it need not re-carry it.
- Task 904 puts the `proof_wanted` trust-surface lesson in the pipeline. It is the sharpest
  finding of the whole assessment for general use: a tree described by its own dispatch as "all
  reported sorry-free" contained **five** named-but-absent theorems that both a zero `sorry` count
  and a clean `#print axioms` are blind to.

## Follow-ups

- Task **903** (filed): settle on paper whether a deterministic Muller automaton suffices for the
  AA rule and the ban/lull mechanism at ZTime. If it does, the fork's already-proved
  `iff_da_muller` *is* the determinization the architecture needs and (O1) vanishes; if Rabin is
  needed, `Muller.toRabin_exists` (fork `DA/Conversions.lean:112`, `proof_wanted`) becomes the
  single highest-value gap in either CSLib tree.
- Task **904** (filed): the three method lessons, to be authored in the source store.
- **Task 901's description still carries the overturned ground** ("absent from Mathlib, and is not
  to be filed until that dependency is either supplied or replaced by a progress-measure
  argument"). Amending task descriptions was outside this plan's scope. Worth a one-line fix
  whenever 901 is next touched.
- **Not filed, by decision**: the ≈100-150-line (O2) `Rabin.union` / `union_language_eq` plus
  `Rabin.exists_iSup` block (belongs wherever the Rabin layer lives, not in this tree); the two
  upstream PRs (barred to an agent); the archived survey's three WANTED literature sources, still
  open and untouched here.
- **Deploy-freshness**: this repository's `.claude/` tree is stale for six extensions (core,
  formal, lean, literature, memory, typst) and its source store is unreachable from here, which is
  also why 22 of `verify-deploy.sh`'s checks skip. Neither was acted on; `deploy-headless.sh` is
  its own task.

## References

- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md`
  — this task's research report; the sole substantive input, and the source of every verbatim
  amendment applied here
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/plans/01_cslib-omega-automata-nogo-reassessment.md`
  — the plan, carrying the Phase 1-3 implementation notes and Phase 3's Reasoned Exclusions
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md`
  — the amended completeness-programme report, whose NO-GO ground this task re-tested
- `specs/ROADMAP.md` — the two amended refusal bullets
- `specs/archive/736_cslib_omega_automata_survey_and_e3_reopen_check/summaries/01_cslib-omega-automata-survey-summary.md`
  — the prior art and its six-item operator hand-off list
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/task-proposals.json`,
  `task-proposals-audit.ndjson` — the two proposals and their unabridged backlog evidence
