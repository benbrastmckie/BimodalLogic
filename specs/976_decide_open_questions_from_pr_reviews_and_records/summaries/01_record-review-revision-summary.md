# Implementation Summary: Task #976

- **Task**: 976 - Decide open questions from PR reviews and records
- **Status**: [COMPLETED]
- **Started**: 2026-11-20T20:05:00Z
- **Completed**: 2026-11-20T20:40:00Z
- **Effort**: about 40 minutes of implementation across five phase dispatches
- **Dependencies**: None. Question (f) is coordinated with task 970 (`investigate_stability_as_modal_family`) and does not wait on it.
- **Artifacts**: plans/01_record-review-revision-plan.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The research report decided ten of the twelve questions, deferred (f) to
`investigate_stability_as_modal_family`, and returned two for the user. The three records under
`records/` state the ten decisions as design, each with its rejected alternative, and the
three review drafts under `specs/reviews/pr-reviews-2026-11-20/` state them instead of asking.
Two items await the user's ruling and are listed first below. Nothing was posted to GitHub: no
`gh` write command was run in any phase.

## Awaiting the user's ruling

Both are written into the records as open, with the recommendation; the records and reviews
proceed on the recommendation and neither blocks other work.

1. **(i) What "default" means for adoption (M12).** Listed under "Open decisions" of
   `records/proof-mode.md`.
   - A: new example and case-study modules are written in the mode. `Examples/` is layer 4 and
     can import `FormalSystem/Automation/`; it binds work outside the measure.
   - B: every new derived theorem is registered in `BimodalLib` with a proof-mode script or a
     recorded failure class. M12's done-when already states this clause; the registry (M18) is
     not built.
   - C: the mode stays optional outside the library's sweeps. No burden on contributors; it
     contradicts M12's done-when.
   - Fixed whatever the ruling: proofs under `FormalSystem/Theorems/` cannot be written in the
     mode (layer 2 is below layer 3), and M12 hard-depends on a GO at gate one.
   - **Recommendation**: B as the rule, A for `Examples/` and case studies,
     `FormalSystem/Theorems/` exempt and said to be so, all contingent on a GO. Since M12's
     done-when excludes C, the choice left is whether A is added to B.
2. **Whether PR #8's `luntil unfold` / `luntil fold` keywords are renamed.** Listed under "Open
   decisions" of `records/proof-mode-architecture.md`, and put to the contributor as a question
   in `pr8-review.md`.
   - Keep: the tactic heads differ from `lunfold` / `lfold`, so principle 1 is met to the
     letter.
   - Rename to `expand` / `contract`: fold and unfold then belong to the views tier alone.
   - **Recommendation**: rename. This is taste, not evidence.

Deferred, not for ruling now: **(f)** the place of `⊡` stays with
`investigate_stability_as_modal_family`. A ruling is needed only if that report recommends a
separate family.

## Question-by-file table

Record columns give the section that states the decision, or lists it as open. "-" means the
file does not treat the question.

| Q | Outcome | `proof-mode-architecture.md` | `proof-mode.md` | `theorem-library.md` | Reviews |
|---|---|---|---|---|---|
| (a) semantic mode placement | Decided: own directory under `FormalSystem/Semantics/` at layer 1; adapter one module at layer 3 under `Metalogic/`; views and planner at layer 0 or 1 | "Three tiers"; "One scheme, used six times"; last row of "Where the work sits" | M16 done-when and Lane; "Lanes" | - | `pr9-review.md` |
| (b) record and client first | Decided: yes; the countermodel half is a candidate client, made a measured one by a control run | "Three tiers" | - | - | `pr9-review.md` |
| (c) views tactic names | Decided: one pair `lunfold` / `lfold` taking a view name, one table | "Three tiers"; "Where the work sits" | M16, M17 done-when | - | `pr7-review.md`, `pr8-review.md` |
| (c) keyword residue | Open, recommendation stated | "Open decisions", second item | - | - | `pr8-review.md`, as a question |
| (d) rewriting and PR #8 rules at gate one | Decided: `lrewrite` / `lsimp` outside gate one; `G`/`H` carrying and time reflection only by adoption into M1 | "Aim and measure" | M1 and M17 "Filed record"; M17 done-when; "Gates" | - | `pr7-review.md`, `pr8-review.md` |
| (e) shared S5 statement | Decided: a structure with the operator as a field | "Operator families", Families | - (M8 points at the interface) | "Two operators in the Modal family" states the parameterized laws | `pr7-review.md` |
| (f) place of `⊡` | Open, deferred to `investigate_stability_as_modal_family` | "Open decisions", first item, a pointer | "Open decisions", second item, a pointer; M23 | "Open decisions", first item, the question itself | `pr7-review.md`, a pointer |
| (g) linearity and the induction rule | Decided: sequencing-only edge; statement proposed and not yet derived | "Where the work sits", induction row | M4, with the proposed statement | - | `pr8-review.md` |
| (h) leads-to base | Decided: present-inclusive is the named definition; strict rules are the layer beneath | "Where the work sits", leads-to row | M10 | - | `pr8-review.md` |
| (i) meaning of "default" | Open, awaiting the user's ruling, recommendation stated | - | "Open decisions", first item | - | - |
| (j) Minus instance | Decided: `MinusDeduction.lean` moves to `FormalSystem/Theorems/`; rule module under `Theorems/ProofMode/` | - | M9a "Filed record" | - | - |
| (k) `BimodalLib` default build | Decided: outside `defaultTargets`; explicit target and its own CI step | - | - | "Layout" | - |
| (l) views extraction and order | Decided: PR #7 carries its own surface separation; full tier under `proof_mode_views_tier`; order M17, M0, M16 | "Where the work sits", views row | M16, M17, M0 blocks; "Dependency picture" | - | `pr7-review.md` |

Every question has at least one record row. The architecture record states the order of (l) by
contribution ("the first rows of the view table are contributed with the rewriting tactics")
and does not use the milestone numbers; it agrees with `proof-mode.md` and `pr7-review.md`.

## What Changed

Across the five phases:

- `records/proof-mode-architecture.md` — decisions (a), (b), (c), (d), (e) stated in their
  sections; layer of `FormalSystem/Semantics/` given as 1; "Open decisions" holds the `⊡`
  pointer and the keyword question.
- `records/proof-mode.md` — decisions (d), (g), (h), (j), (l) in M1, M4, M9a, M10, M16, M17 and
  "Dependency picture"; "Open decisions" holds (i) and the `⊡` pointer. In phase 5: M16 and M17
  added to the two lists in "Gates" of work that does not wait on the gate-one verdict.
- `records/theorem-library.md` — decision (k) in "Layout"; "Open decisions" holds the `⊡`
  question and enumeration bounds.
- `specs/reviews/pr-reviews-2026-11-20/pr7-review.md`, `pr8-review.md`, `pr9-review.md` —
  state (a), (b), (c), (d), (e), (g), (h), (l); the mistaken layer correction in `pr9-review.md`
  is removed.

## Decisions

- The one phase-5 fix was made in `records/proof-mode.md` because its "Gates" section named
  neither M17 nor, in its closing paragraph, M16 among the work that runs before the verdict,
  while M17's own block says it is merged or declined before M0 runs.
- Two review passages flagged by phase 4 were left: the `pr8-review.md` table cell "the
  present-inclusive definition is open" uses "open" as the neighbouring cells do, for work not
  yet done against a done-when; the `pr9-review.md` cell "one adapter module above
  `Semantics/`" is true of a layer-3 module.
- Phase 5 was closed as completed with exclusions, not plain completed: see Verification.

## Plan Deviations

- **Task 4.9** altered: in `pr8-review.md`, the clause "M10's, if the strict layer is to stay
  as the base" was also removed from the list of what the PR should revise, because it
  contradicted (h).
- **Phase 5 verification** altered: the plan counts any failing suite beyond the planning-time
  baseline as a failure of the phase. Two such suites failed and were excluded with evidence
  instead (plan, Phase 5, "Reasoned Exclusions").

## Verification

- `grep -rn -i 'open decision[s]* [0-9]'` over the six files: no hit.
- `grep -rn 'layer 2'`: four hits, all about `FormalSystem/Theorems/`.
- `lunfold` / `lfold`: ten hits, one description in every file.
- Relative links in the three records: all resolve. `records/semantic-proof-mode.md` appears in
  backticks only.
- The four reversible positions in `records/proof-mode.md`: byte-identical to the text before
  phase 2 (`git show c4441b430^:records/proof-mode.md`).
- `check-record-versioning.sh records`: 0 BLOCKING, 1 ADVISORY (`theorem-library.md:4`, the
  planning-time baseline). `check-task-references.sh records`: 0.
- Scoped touched-path check, `verify-touched.sh --task-dir ...` over the six files: `SELECT:
  (none)`, six paths owed, fallback `--cost-class free`, **82 passed, 3 failed, 10 skipped**.
  The planning-time baseline was 84 passed, 1 failed. This is not equal to the baseline.
  - `tests/test-deploy-baseline-lib.sh`: in the baseline.
  - `tests/test-lint-state-writer-boundary.sh` and `tests/test-stall-reprompt-wiring.sh`: not
    in the baseline. Each fails when run alone, reads only files under the gitignored
    `.claude/` deploy tree, names neither `records/` nor the review directory, and is
    byte-identical to its copy in the core source store. Neither can be affected by a markdown
    edit under `records/`. Why they passed at planning time was not established; the dispatch
    file reports the deployed core extension as stale against its source store.
- The complete gate set was deferred to the batch stage under the dispatch's Batch Gate
  Deferral section and was not run in this task.
- Build: N/A. Tests: N/A (no Lean, script or state file edited). Files verified: Yes.

## Impacts

Task descriptions in `specs/state.json` that now contradict the records (read only, not
edited; revising them belongs to `/revise`):

| Task | What its description says | What the records say |
|---|---|---|
| 947 `proof_mode_reprove_perpetuity` | whether rewriting and the contributed temporal rules may be used at gate one "is open decision 5 of records/proof-mode-architecture.md and needs the user's ruling" | decided, (d) |
| 950 `proof_mode_until_since_intro_unfold_induction` | the induction rule's linearity edge is "undetermined until the plan states the rule's formula", settling "open decision 1 of records/proof-mode.md" | decided, (g): sequencing only, whatever the formula |
| 952 `proof_mode_abstract_frontend_interface` | structure or class "is open decision 5 of the architecture record"; where the Minus instance lives "is open decision 6 of records/proof-mode.md" | decided, (e) and (j) |
| 969 `proof_mode_views_tier` | "The plan settles the tactic names ... open decision 1 of the architecture record"; extraction from #7 is conditional on whether it has merged | decided, (c) and (l): the pair is fixed, #7 contributes the first rows and the tier takes them over; the tier sits at layer 0 or 1 |
| 971 `theorem_library_layout_and_registry` | "USER RULING NEEDED BEFORE IMPLEMENTATION: whether `BimodalLib` is in `defaultTargets`" | decided, (k): outside `defaultTargets` |

Descriptions that cite a decision still open by a number that no longer names it:

- 970 `investigate_stability_as_modal_family`: "open decision 2 of records/theorem-library.md"; it is the first item there.
- 972 `theorem_library_tableau_pipeline`: "open decision 3 of records/theorem-library.md" for enumeration bounds; it is the second item.

935 `determinization_free_progress_measure_design` is in the plan's list and is unrelated to
these decisions. 956 `proof_mode_leads_to_invariance_library` was also read and agrees with
(h). The list is a lower bound, as the plan says.

`roadmap_milestones` entries: none contradicts the order M17, M0, M16 (960 is held while PRs
#7 and #8 are open, and 969 carries an edge on 960). Two batch rationales are stale on other
points: in M5, the rationale for 953 says "Open decision 3 of records/proof-mode.md is live
here" for the Minus instance, which (j) decides; in M2, the rationale for 970 cites "Open
decision 4 of records/proof-mode.md", which is the second item there.

## Follow-ups

- The user's ruling on (i) and on the keyword question; apply each in place of the
  recommendation if it differs.
- `/revise` for the descriptions of 947, 950, 952, 969 and 971, and the stale numbers in 970 and
  972; `/roadmap` for the two stale rationales.
- `records/semantic-proof-mode.md` is to be written before the semantic mode is built; (b).
- The proposed Until/Since induction statement is argued by hand on ℤ and is not derived or
  machine-checked; deriving it is the work of `proof_mode_until_since_intro_unfold_induction`.
- The two suites that fail in the deployed tree are a matter for the repository that owns the
  core source store.
- The review drafts are local. Posting them is the user's act.

## References

- Plan: `specs/976_decide_open_questions_from_pr_reviews_and_records/plans/01_record-review-revision-plan.md`
- Report: `specs/976_decide_open_questions_from_pr_reviews_and_records/reports/01_open-questions-decisions.md`
- Handoffs: `specs/976_decide_open_questions_from_pr_reviews_and_records/handoffs/`
- Prototype for (e): `specs/976_decide_open_questions_from_pr_reviews_and_records/evidence/S5Proto.lean`
