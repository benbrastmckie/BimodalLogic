# Implementation Summary: Task #438 (Part B — Cluster Re-Issue)

- **Task**: 438 - reconcile_semantic_definitions_with_jpl_paper
- **Plan**: `specs/438_reconcile_semantic_definitions_with_jpl_paper/plans/03_reissue-paper-refactor-cluster.md` (v02)
- **Research inputs**: `reports/01_team-research.md`, `reports/02_logical-consequence-discrepancy-audit.md`
- **Date**: 2026-08-10
- **Phases**: 7 of 7 completed
- **Type**: lean4 (specification work only — zero Lean, LaTeX, typst, or paper edits)

## What Was Delivered

Part B (deliverables 6-10) of a scoping-and-re-issue task. The deliverable is a corrected set of
task specifications, not code: six cluster task descriptions rewritten against the paper's current
four-axiom `def:frame` and totality-based logical consequence, three task renames, SUPERSEDED
banners on stale artifacts, and a dependency graph verified acyclic.

Every change is confined to `specs/**`. `git diff --name-only` across all seven phase commits
returns only `specs/` paths.

## Phase-by-Phase

| Phase | Outcome |
|---|---|
| 1 — Preflight, cluster re-verification, rename-cost grep | COMPLETED. Cluster confirmed unchanged; rename surface measured; baseline task order captured; **a fourth paper drift wave detected** |
| 2 — Renames | COMPLETED. All three renames executed (none fell back to record-instead-of-rename) |
| 3 — Rewrite 414, 415, 417 + status reset | COMPLETED. Three descriptions rewritten, three statuses set to `not_started` |
| 4 — Rewrite 419, 420, 427 + 420 blockers | COMPLETED. Three descriptions rewritten, one `blockers` field revised, zero status transitions |
| 5 — SUPERSEDED banners | COMPLETED. 7 files bannered (estimate was ~6) |
| 6 — Dependency edge correction | COMPLETED. Exactly one edge removed; all four acyclicity checks pass |
| 7 — Final verification | COMPLETED. All gates run with hit counts recorded |

## Renames Executed (3 of 3; zero recorded-instead-of-renamed)

| Task | Old | New |
|---|---|---|
| 414 | `refactor_semantics_to_maximal_history_validity` | `refactor_semantics_to_total_history_validity` |
| 415 | `completeness_over_maximal_history_semantics` | `completeness_over_total_history_semantics` |
| 420 | `align_task_frame_with_positive_cone_limit_nullity` | `align_task_frame_with_positive_cone_axioms` |

Batch per rename: `git mv` + `project_name` + `artifacts[].path`. Six artifact paths rewritten
(420 x3, 414 x2, 415 x1), all owned by the renaming task itself. Five ephemeral dispatch-scratch
JSON files that travelled with the directories had their embedded self-paths rewritten so no
dangling path survives. Every residual old-slug hit is historical prose in a superseded report,
plan, or summary, or in task 438's own frozen Part A artifacts — enumerated and justified in the
plan's Phase 2 Execution Notes.

## Descriptions Rewritten

| Task | chars | status | corrections applied |
|---|---|---|---|
| 414 | 15,442 | `researched` -> `not_started` | C1, C2, C3, C6, C7 + both corrected earlier errors + the report-02 §3 coupling update + the optional frame-relative-validity deliverable |
| 415 | 10,207 | `researched` -> `not_started` | C1, C2, C3, C7 |
| 417 | 8,034 | `researched` -> `not_started` | C1, C3, C5, C7 |
| 419 | 9,344 | `not_started` (unchanged) | C1, C4, C7 |
| 420 | 14,391 + 2,180 blockers | `blocked` (unchanged) | C1, C2, C3, C6, C7 + corrected earlier error 1 |
| 427 | 11,374 | `not_started` (unchanged) | C1, C2, C3 |

420 was never presented as undone: both its description and its `blockers` field state that phases
1-5 are landed, green, and committed, and inventory landed-vs-stale explicitly.

## Banner Inventory (7 files)

`414/reports/01`, `414/reports/02`, `415/reports/01`, `417/reports/01`, `420/reports/01`,
`420/summaries/01`, and `420/plans/01`. The seventh (420's plan) was added beyond the plan's ~6
estimate by applying the phase's own criterion rather than the estimate — it carries 9 hits for
the superseded axiom name and the retired "not adopted" framing. `git diff --numstat` reports
exactly `2 0` for all seven: banner plus blank line inserted, zero deletions, no content modified.

**Decision recorded**: task 438's own `reports/01_team-research.md` was deliberately NOT bannered
and no see-also note was added. It remains authoritative for everything report 02 did not touch;
the precedence rule lives in the plan and in every rewritten description's survives/superseded
breakdown instead.

## Dependency Graph

One edge removed: `420.dependencies` `[415, 438]` -> `[438]`. All five other cluster arrays were
diffed before/after and are byte-identical. All four Deliverable 5 checks pass:

| Check | Before | After |
|---|---|---|
| (a) 415 out of wave 1 with `Blocked by: --` | wave 1, `--` (cycle symptom) | wave 4 |
| (b) 415 blocked by 414 and 420 | (masked by the cycle) | 414 in wave 3, 420 in wave 2, both strictly earlier |
| (c) 420 before 414/415/417 | 420 wave 2, 414 wave 3, 415 wave 1 (wrong) | 420 wave 2, 414 wave 3, 415/417 wave 4 |
| (d) 427 last in the Paper Refactor group | wave 5 | wave 5 |

The compensating record is in place: 420's `blockers` states the task-level edge is gone while the
phase-6 wait on 415's `bundleFlowFrame` is not, and directs direct coordination.

## Final Verification Gates (Phase 7)

**Forbidden-vocabulary grep — nine terms across all six descriptions.** Zero hits was never the
target; every remaining hit is inside explicit supersession framing, and none presents superseded
content as current.

| term | 414 | 415 | 417 | 419 | 420 | 427 | justification for every hit |
|---|---|---|---|---|---|---|---|
| `Limit Nullity` | 0 | 2 | 1 | 0 | 1 | 0 | "the axiom formerly called ... is now simply named *Limit*"; SUPERSEDED-list entries |
| `lax` | 0 | 0 | 0 | 0 | 0 | 0 | absent |
| `maximal-history` | 2 | 4 | 2 | 0 | 0 | 0 | the `RE-ISSUED ... (supersedes the prior maximal-history charter/framing)` headers and SUPERSEDED-list entries |
| `IsMaximal` | 0 | 0 | 0 | 0 | 0 | 0 | absent (where the refuted predicate is named, the texts say `IsMax`, Mathlib's actual name, inside supersession framing) |
| `NOT adopted` | 0 | 0 | 0 | 0 | 0 | 0 | absent |
| `Seg(` | 0 | 0 | 0 | 0 | 0 | 0 | absent |
| `lem:segments` | 0 | 0 | 0 | 0 | 0 | 0 | absent — referred to as "the lemma formerly cited for the two-sided segment family ... no longer exists in the paper", so the dead label never appears |
| `task-constrained` | 2 | 2 | 2 | 0 | 2 | 2 | "the vocabulary ... is RETIRED throughout the paper"; SUPERSEDED-list entries |
| `count among the segments` / `counting among the segments` / `nonempty segments` | 1 / 0 / 0 | 0 | 0 | 0 | 0 | 0 | 414's single hit: "the device by which one-sided fibers used to count among the segments is RETIRED" |

No superseded phrase outside the plan's nine-term list surfaced during the read-through, so the
recorded term list is the plan's list unextended.

**Positive-presence gate — every assigned token present in every assigned description.**

| token | assigned to | 414 | 415 | 417 | 419 | 420 | 427 |
|---|---|---|---|---|---|---|---|
| `lem:constraint` | 414, 415, 420, 427 | 5 | 2 | 2 | 1 | 3 | 2 |
| `lem:step` | 414, 415, 420, 427 | 8 | 3 | 3 | 1 | 7 | 3 |
| `partial history` | 414, 415, 420, 427 | 12 | 5 | 5 | 3 | 11 | 6 |
| `[w, v]_x^y` | 414, 415, 420, 427 | 3 | 3 | 1 | 1 | 2 | 2 |
| `def:directed` | 414, 420, 427 | 3 | 1 | 1 | 1 | 2 | 3 |
| `def:temporal-order` | 414, 420 | 2 | 0 | 0 | 0 | 3 | 2 |
| `def:task-relation` | 414, 420 | 2 | 1 | 1 | 1 | 3 | 2 |
| pinned SHA `98b52b41` | 414, 415, 417, 419 | 1 | 1 | 1 | 1 | 1 | 1 |

All six descriptions also carry the second SHA `c3da9852` (the re-verification snapshot — see
Paper Drift below), which the plan did not require but the Phase 1 finding made appropriate.

**Bare-locator gate.** 414, 415, 417, 420, 427 carry zero `possible_worlds.tex:NNNN` locators;
their only `possible_worlds.tex:` occurrences are the metasyntactic `possible_worlds.tex:NNNN`
inside the citation-discipline instruction itself. 419 carries `:3250` three times and `:926`
once, all four the justified case the plan anticipated: naming the stale citation being corrected,
recording that `:3250` still lives at `FormalSystem/Theorems/DedekindDerived.lean:359` and
`FormalSystem/Syntax/Formula.lean:467` as 419's own future work (task 438 has no write scope in
`FormalSystem/` and did not touch them), and the SUPERSEDED-list entries retiring both. None of
`:2412`, `:2570`, `:912-913`, `:949-960`, `:1833` appears anywhere.

**Structural gates.** `jq empty specs/state.json` passes; `generate-todo.sh` exits 0;
`generate-task-order.sh --print` renders an acyclic graph. `git diff --numstat` across every
`reports/` and `summaries/` file shows `+2 -0` and nothing else — no report deleted or
content-modified. `plans/01_reissue-paper-refactor-cluster.md` is byte-unmodified. All changes
confined to `specs/**`.

## Paper Drift Observed (a FOURTH wave, during this dispatch)

The plan's Phase 1 snapshot re-check found the paper had moved again between report 02's pin and
this implementation dispatch, on the same day:

| | report 02's pin | observed at implementation |
|---|---|---|
| HEAD | `98b52b41` (2026-08-10 14:57 -0700) | `c3da9852` (2026-08-10 16:05 -0700) |
| md5 | `aa0488c1fe6134e59256803ae891a5f2` | `0225d65a3d995275c6565145c71dade0` |
| lines | 3975 | 3943 |

Per the plan's contingency, no definitions were re-derived (that is Part A work). Instead every
quoted definition was re-read read-only at the new snapshot and **all were confirmed verbatim** —
`def:temporal-order`, `def:task-relation`, `def:directed`, `def:frame`, `lem:nullity`,
`def:world-history`, `lem:constraint`, `lem:step`, `thm:extension`, `thm:occurrence`,
`app:nonempty`, `def:BL-semantics`, `def:frame-validity`, `def:logical-consequence`, and the ℚ
non-example footnote including its closing sentence. `lem:segments` confirmed absent; `\Seg`
survives only in commented-out lines. Both snapshots are therefore recorded in the rewritten
descriptions: report 02's pin as the generation the surviving research was audited against, and
`c3da9852` as the most recent point at which every quote was confirmed.

**Anchor correction discovered during this re-check** (beyond what either report specified):
`CO` and `TMP-CO` are `\aitem` axiom KEYS resolved by `\aref`, not `\label{}` names. 419's rewrite
states the base-TM form as `\aitem{CO}` inside `\label{sub:Extension}` and the TM⁺ restatement as
`\aitem[CO]{TMP-CO}` inside `\label{def:TMplus-c}`, both quoted verbatim. Earlier research
described them as labels, which is imprecise as well as line-stale.

This fourth wave — the third to land inside a single task's lifecycle — is the strongest available
evidence for the recurrence-prevention follow-up below.

## Plan Deviations

- Phase 2, "record-instead-of-rename" branch: **not applicable**. Phase 1's measured grep surface
  green-lit all three renames, so no task took the fallback path. Annotated inline on the plan's
  checklist item.
- Phase 5 bannered **7** files rather than the Scope Hypothesis's ~6. The seventh
  (`420/plans/01_taskframe-limit-nullity-alignment.md`) was added by applying the phase's own
  stated criterion instead of the estimate. Recorded in the Phase 5 Execution Notes.
- Phase 1's snapshot re-check found a **fourth drift wave** rather than confirming report 02's
  pin. Handled per the plan's stated contingency (record and proceed from report 02), with the
  addition that all quotes were re-verified at the new snapshot and both baselines are carried in
  the descriptions.
- 419's CO anchors are recorded as `\aitem` keys with their enclosing `\label{}`, correcting both
  reports' `\label{CO}` / `\label{TMP-CO}` phrasing. This is a precision improvement over the
  plan's Phase 4 instruction, not a departure from its intent.

No other deviations: no phase was added, removed, or reordered; no status, rename, or edge
decision differs from the plan.

## Recommended Follow-Ups (recorded, not executed — outside Part B scope)

1. **Recurrence prevention — now the highest-leverage follow-up in the cluster's orbit.** A
   generated `specs/paper-definitions-of-record.md` plus a `check-paper-definitions.sh` lint
   anchored to a paper commit SHA recorded in `state.json`. Four drift waves have now hit this
   cluster, two of them mid-dispatch. Without this, the re-issued specs go stale a fifth time.
   Suggested as a `meta` task.
2. **Task 424** (`strong_completeness`, gates the entire ultraproduct branch) hard-codes the
   current Omega-parameterized `TruthAt`/box clause through its governing design doc under
   `specs/archive/361_*/design/02_compactness-route.md` and will break silently once 414 lands. It
   sits outside `topic == "paper-refactor"` and so outside Part B's rewrite scope. Related open
   item: tasks 421-423 and 425 are unchecked, not cleared — their design docs were never opened.
3. **`specs/ROADMAP.md`'s "Paper Alignment Programme" section** is itself stale (three-axiom frame,
   maximal-history validity). Deliverable 6 does not touch it.
4. **Frame-relative validity gap**: `def:frame-validity`'s `⊨_F` has no Lean counterpart and is
   the natural home for `app:nonempty`'s never-vacuous theorem. Folded into 414's rewrite as an
   explicit OPTIONAL deliverable rather than left as a loose note.
5. **Pre-existing unrelated defect observed**: the repo-wide `artifacts[].path` resolution sweep
   flagged one missing file, `specs/418_.../artifacts/after-verdicts.md`, belonging to task 418. It
   predates this dispatch and is unrelated to this cluster.

## Files Modified

- `specs/state.json` — `project_name` x3, `artifacts[].path` x6, `description` x6, `status` x3,
  `blockers` x1, `dependencies` x1
- `specs/TODO.md` — regenerated (never hand-edited)
- `specs/438_.../plans/03_reissue-paper-refactor-cluster.md` — phase markers plus per-phase
  execution notes
- Directory renames: `specs/414_*`, `specs/415_*`, `specs/420_*`
- SUPERSEDED banners: 7 files under `specs/{414,415,417,420}_*/{reports,plans,summaries}/`
- This summary
