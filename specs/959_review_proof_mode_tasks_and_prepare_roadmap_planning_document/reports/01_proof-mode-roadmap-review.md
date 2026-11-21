# Research Report: Task #959

**Task**: 959 - Review proof mode tasks and prepare roadmap planning document
**Started**: 2026-11-20T06:35:58Z
**Completed**: 2026-11-20T06:39:42Z
**Effort**: small-to-medium (one markdown deliverable, ~250-400 lines; no Lean)
**Dependencies**: None
**Sources/Inputs**: - Codebase (`FormalSystem/Automation/ProofMode/`, `FormalSystem/Theorems/ProofMode/`, `Tests/BimodalTest/Automation/ProofModeTest.lean`), `docs/user-guide/derivation-proof-mode.md`, `research/NEW_DIRECTIONS.md`, `specs/state.json` (tasks 944-958, `roadmap_batches`), `specs/ROADMAP.md`, `.claude/agents/roadmap-agent.md`. No web research was needed.
**Artifacts**: - specs/959_review_proof_mode_tasks_and_prepare_roadmap_planning_document/reports/01_proof-mode-roadmap-review.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The merged proof mode is two commits (`8e9af6925`, `db2adff6c`, 2026-11-17/18): 5 elaborator
  modules (1,013 lines), 8 pure-rule modules (1,157 lines, of which 624 are the TM-plus copies),
  one 233-line acceptance-test file, and a 97-line user guide. It has no client outside its own
  tests.
- Fourteen follow-on tasks (944-957) are filed, all `not_started`, all `topic: proof-mode`, none
  with a `file_scope`. Their dependency edges make ONE total chain:
  944 -> 945 -> 946 -> 955 -> 947 -> 949 -> 950 -> 948 -> 954 -> 951 -> 952 -> 953 -> 956 -> 957.
  The roadmap already cuts that chain into four batches at the adequacy gate (947) and after.
- The chain is stricter than the logic requires. `research/NEW_DIRECTIONS.md` says so itself:
  the full linearization exists because every task edits the same test file, user guide and two
  READMEs. At least five edges are sequencing edges, not logical ones. That is where the natural
  joints are, and it is the main thing the new document can add over what is already written.
- Eight dimensions of development are identifiable. Seven are covered by filed tasks; several
  further ones are not filed at all (adoption after a GO verdict, trust and cost measurement,
  the ModelChecker bridge, decision-procedure closers, deduction theorems for Star and Open,
  reference-manual coverage, de-contention of the shared files).
- `/roadmap` does not read documents. The roadmap agent reads tasks from `specs/state.json`. So
  `records/proof-mode.md` reaches `/roadmap` only through (a) tasks filed from it and (b) a
  quoted instruction naming it. The document should be written so both are mechanical.
- Recommended shape for `records/proof-mode.md`: aims, current state, dimensions, twelve to
  fifteen milestones each with done-when / hard dependencies / sequencing-only dependencies /
  lane, a dependency picture, lanes for division of labour, and an explicit "not yet filed" list.
  It must carry NO task numbers and no draft-history language (it sits outside `specs/`).

## Context & Scope

The task asks for a long-horizon goals document at `records/proof-mode.md` that (1) reviews the
existing proof-mode tasks, (2) builds on what is merged, (3) surveys other dimensions, (4) finds
joints that can be independent milestones with dependencies, and (5) is usable as input to
`/roadmap`. This report supplies the review, the measurements, the joint analysis and a proposed
outline. It does not write the document.

Constraints found:

- `records/proof-mode.md` already exists, EMPTY (0 bytes), in an untracked `records/` directory.
  `records/` is not gitignored and has no entry in `ORGANISATION.md`.
- `research/` IS gitignored (`.gitignore:91`). `research/NEW_DIRECTIONS.md`, the source every
  filed task cites, is a local-only file. The new document cannot lean on it as a durable anchor
  and should be self-contained.
- `records/` is outside `specs/`, so `.claude/rules/no-task-references-in-deliverables.md` and
  `no-record-versioning-in-deliverables.md` both apply. A write-time hook
  (`hooks/validate-no-task-references.sh`) is described as blocking. Task numbers stay in this
  report; the document should name milestones by its own IDs and, where a pointer to a filed
  record helps, by task slug (`proof_mode_s5_aware_box_scopes`), which survives renumbering.

## Findings

### What is merged

Measured on the working tree at `f616bb5c6`.

| Item | Measurement | How measured |
|---|---|---|
| Tactics | 21 distinct names | `grep '^syntax (name :='` over `Automation/ProofMode/*.lean`; cross-checked by extracting quoted `"l..."` literals, same 21 names |
| Elaborator modules | 5 files, 1,013 lines | `wc -l` (Basic 212, Discrete 86, Meta 187, Modal 271, Temporal 257) |
| Pure-rule modules | 8 files, 1,157 lines | `wc -l` |
| TM-plus copies | 624 lines in `Plus*.lean` | `cat Plus*.lean \| wc -l` |
| Name-pair dispatch | 42 `ruleName` occurrences | `grep -n ruleName` |
| `throwError` sites | 65 | `grep -o throwError \| wc -l` |
| Negative tests | 2, both bare `fail_if_success`; zero `#guard_msgs` | `grep` on the test file |
| Acceptance examples | 31 | `grep -c '^example'` |
| `sorry` / `axiom` / `native_decide` | none | `grep` over both directories |
| Clients | none outside aggregators and the test file | `grep -rl ProofMode` over `FormalSystem Tests BimodalTools` |
| Axiom audit in tests | none (`#print axioms` absent) | `grep` on the test file |
| Reference-manual coverage | none | `grep -rli` over `typst/` returns nothing |

The 21 tactics: `lstart lintro lexact lapply lsplit lhave lcases lleft lright` (Basic);
`lmodal_intro lmodal_use lmodal_cases ltemporal_intro` (Modal); `ltemporal_cases ladvance
ltemporal_use lprogress luntil lsince` (Temporal); `lstep linvariant` (Discrete).

**Discrepancy**: `research/NEW_DIRECTIONS.md` says "22 tactics". Two differently shaped searches
both give 21. `lmodal_intro` takes four mode keywords, which may be how 22 was reached. The
document should say 21 or say "about twenty"; it should not repeat 22.

The other carried figures in the filed task descriptions check out: 65 `throwError` sites, two
negative checks, "about 620 lines" of TM-plus copies (624).

What the merged work established beyond the tactics (stated in the user guide and READMEs; not
re-verified by build in this pass):

- Scope safety by typing: a named hypothesis is a Lean local whose type keeps its source context.
- Integer-time invariance (`forwardInvariantRule`, `Theorems/ProofMode/Discrete.lean:147`)
  derived inside the calculus.
- A native TM-plus deduction theorem and generalized K for all four universal operators.

### The fourteen filed tasks

Enumerated by `jq` over `active_projects` with `topic == "proof-mode"` and number below 959;
cross-checked against the wave table from `generate-task-order.sh --print` and against
`ROADMAP.md` line 224, which also says fourteen and gives the same chain.

| Task | Slug | Deliverable in one line | Filed deps | Kind |
|---|---|---|---|---|
| 944 | proof_mode_s5_aware_box_scopes | box / stability scopes carry `box A`, `diamond A` intact (derived 4 and 5) | none | Lean |
| 945 | proof_mode_cross_modal_scopes_mf_tf | box facts cross into G/H scopes via MF and derived TF | 944 | Lean |
| 946 | proof_mode_always_sometimes_scopes | always / sometimes rules; P1-P6 as acceptance scripts | 945 | Lean |
| 955 | proof_mode_close_leaves_with_automation | leaf closer on `propDecide`; `modal_search` bounded fallback only | 946, 958 | Lean |
| 947 | proof_mode_reprove_perpetuity | Perpetuity supporting lemmas re-proved; GO / RE-PLAN report | 946, 955 | Lean + report, GATE |
| 949 | proof_mode_linearity_case_tactic | three-case split from TL / CN, in CN order | 947 | Lean |
| 950 | proof_mode_until_since_intro_unfold_induction | Until/Since introduction, ZTime unfolding, induction | 949 | Lean |
| 948 | proof_mode_reprove_temporal_slice | fixed Burgess-Xu slice re-proved; missing-rule report | 947, 949, 950 | Lean + report |
| 954 | proof_mode_goal_display_patterns_error_tests | error-test backfill; nested patterns; goal display | 946, 948 | Lean, 3 parts |
| 951 | proof_mode_dense_and_real_time_rules | DN at Dense; PU, SEP, CO at RTime, certificates as goals | 950, 954 | Lean |
| 952 | proof_mode_abstract_frontend_interface | object-level typeclass; rules proved once | 946, 948, 951 | Lean refactor |
| 953 | proof_mode_instances_other_languages | Minus instance; Star/Open instance or written reason | 952 | Lean / prose |
| 956 | proof_mode_leads_to_invariance_library | reflexive leads-to; invariance; finite well-founded progress | 948, 950, 953 | Lean |
| 957 | proof_mode_transition_systems_tm_specifications | research report on transition systems, Veil, ModelChecker | 956 | report |

Task 958 (`repair_buildcontextexpr_modal_search`, `topic: automation`) is `completed`; it was the
one hard prerequisite outside the chain, for 955's fallback.

Current batches in `roadmap_batches` (positions 2-5 of 23):
`[944,945,946,955,947]`, `[949,950,948,954]`, `[951,952,953]`, `[956,957]`.

### Filed edges versus logical dependence

The filed graph is a total order. Comparing each edge with what the task's own description
needs gives the split below. "Logical" means the dependent task's deliverable cannot be stated or
proved without the predecessor's. "Sequencing" means the edge exists because both tasks edit
`ProofModeTest.lean`, the user guide and the two READMEs, or because of a preference about order.
The right-hand column is a reading of the task descriptions, not a machine-checked result.

| Edge | Reading | Ground |
|---|---|---|
| 944 -> 945 -> 946 | logical | each extends the scope rules the previous one adds; P1-P6 need all three |
| 946 -> 955 | sequencing | the closer rests on `propDecide` and deduction; nothing in it uses a scope rule. `NEW_DIRECTIONS` placed it in Stage 1 so the gate measures the mode with leaves automated |
| 958 -> 955 | logical, discharged | 958 is completed |
| 946, 955 -> 947 | logical | the gate measures exactly that rule set |
| 947 -> 949 | gate | 949 must read the verdict and stop on RE-PLAN |
| 949 -> 950 | weak | `NEW_DIRECTIONS` gives PM-7 a PM-6 edge without a stated reason; Until/Since introduction and unfolding do not use the linearity split. Possibly logical for the induction rule; needs a planner's look |
| 949, 950 -> 948 | logical | the slice includes `tempLinearity` and US/UF proofs |
| 946, 948 -> 954 | sequencing for part 1 and part 2; soft for part 3 | error-test backfill and nested patterns need no temporal rule. Running late only means fewer sites to backfill twice |
| 950, 954 -> 951 | sequencing | DN, PU, SEP, CO are axiom-schema exposures behind a frame certificate, on the pattern `lstep` already has. `density` and `coDerived` exist with `Dense <= fc` / `RTime <= fc` parameters |
| 946, 948, 951 -> 952 | logical by design | "extract the interface from the rule set as it stands after the adequacy tests" |
| 952 -> 953 | logical for the Minus instance only | the Star and Open deduction theorems are new metatheory that needs no interface |
| 953 -> 956 | doubtful | 956 is stated "for TM and TM-plus"; what it plausibly needs is 952 (prove once), not the other-language instances |
| 948, 950 -> 956 | logical | leads-to builds on the induction rule |
| 956 -> 957 | logical for the assessment; not for the survey parts | the Veil and ModelChecker sections do not depend on any rule |

Consequence: with the shared-file contention removed, the programme is not one lane. A fair
picture is a spine with side branches (see the milestone graph under Recommendations).

### Dimensions of development

Eight dimensions, with coverage by the filed tasks.

| Dimension | What "done" would look like | Filed coverage | Gap |
|---|---|---|---|
| 1. Bimodal scope rules | every TM interaction axiom (4, 5, MF, TF, perpetuity operators) usable inside scopes | 944, 945, 946 | none identified |
| 2. Linear-time rules | linearity cases; Until/Since introduction, unfolding, induction | 949, 950 | whatever 948's missing-rule list names |
| 3. Frame coverage | rules at Base, Dense, ZTime, RTime | 951 (ZTime is merged) | none identified |
| 4. Closure automation | structure by the mode, leaves by automation | 955 (propositional only, TM only) | TM-plus closer; closers from the decision procedures |
| 5. Evidence and adoption | measured adequacy; the mode used by real proofs | 947, 948 | what follows a GO: no task says where proof-mode proofs live after the gates, or which new work must use it |
| 6. Architecture and language reach | rules proved once; instances per calculus | 952, 953 | Star and Open deduction theorems; the languages the user guide lists as separate work (counterfactual, stored-index, metric) |
| 7. Usability | readable goals, patterns, tested errors, documentation | 954 | reference-manual chapter; tactic-reference upkeep; error-coverage ratchet so the count cannot regress |
| 8. Specification reasoning | safety / liveness library; transition systems | 956, 957 | everything after 957's report (case study, Veil work) is by design unfiled until the report exists |

Two cross-cutting dimensions have no filed coverage at all:

- **Trust and cost.** The tests assert no axiom set for any proof-mode derivation, though
  `Tests/BimodalTest/WalkthroughAxioms.lean` shows the repository has that pattern. Nothing
  measures the size of the derivation terms the tactics build or their elaboration time.
  `lintro` discharges by the deduction theorem, a transformation whose output can grow with
  proof size, so this is a real question for long scripts. Not measured in this pass.
- **Dual verification.** The README pairs this repository with the ModelChecker. A failed leaf is
  the natural point to ask for a countermodel. Only 957's report touches it, and only as a
  section. The dataset tooling (`BimodalTools`, `proof_extractor`) is a second possible consumer
  of proof-mode scripts; no record connects them.

One structural fact bears on dimension 5. The task records state that `Theorems/` must not
import `Automation/`. If that invariant stands, "the mode becomes the default" cannot mean
rewriting `Theorems/` in it: proof-mode proofs live in `Examples/`, tests, or a new downstream
directory. (Carried from the task descriptions; not re-verified against
`scripts/check-module-invariants.sh` in this pass.) The goals document should state what
"default" means under that constraint, or mark it as an open decision.

### How `/roadmap` will consume the document

From `.claude/agents/roadmap-agent.md`: the agent builds its picture from `roadmap_batches`,
`roadmap_notes`, the open tasks in `state.json`, the wave table, and a render preview. It writes
batches, notes and `dependencies[]` edges. It reads no goals document unless the instruction
tells it to, and it can add edges but its contract describes no edge removal.

So the document affects the roadmap through three channels:

1. Tasks filed from its unfiled milestones (via `/task`), which the agent then batches.
2. A quoted instruction, for example `/roadmap "re-batch the proof-mode programme against
   records/proof-mode.md"`.
3. Edge changes. Relaxing a sequencing edge means removing a filed dependency, which is outside
   what the roadmap agent's contract describes; it would need the user or a separate step.

## Decisions

- The document is a goals document, not a second roadmap. It states aims, milestones and joints;
  batch order stays in `roadmap_batches`.
- Milestones are identified by document-local IDs and task slugs, never task numbers.
- The existing four-batch cut at the adequacy gate is sound and is kept as the spine. The
  report proposes side branches, not a reordering.
- Edge classifications above are offered as a reading for the planner and user to confirm. No
  edge was changed and no task was created in this dispatch.
- The 21-versus-22 tactic count is resolved in favour of the measured 21.

## Recommendations

### 1. Outline for `records/proof-mode.md`

1. **Aim** - one paragraph: from a tested frontend to the ordinary way TM derivations are
   written, and from there to specification reasoning; the invariant that nothing semantic
   stands in for a derivation.
2. **Where it stands** - the measured table above, minus the method column; the gap list.
3. **Dimensions** - the eight plus the two cross-cutting ones, each with a done-state.
4. **Milestones** - one block each: aim, done-when, hard dependencies, sequencing-only
   dependencies, lane, filed slug or "not filed".
5. **Dependency picture** - the graph below.
6. **Gates** - the two adequacy reports and what a RE-PLAN does to everything downstream.
7. **Lanes** - division of labour.
8. **Open decisions** - items needing a user ruling.
9. **Not yet filed** - a list written so each item can be handed to `/task` as is.

### 2. Proposed milestones

| ID | Milestone | Covers | Hard deps | Sequencing only |
|---|---|---|---|---|
| M0 | Shared-file de-contention: split the acceptance tests and the guide by tactic family; give every record a `file_scope` | not filed | none | none |
| M1 | Bimodal scope core | 944, 945, 946 | none | none |
| M2 | Leaf closure | 955 | none open | M1 |
| M3 | Gate one: Perpetuity adequacy, GO / RE-PLAN | 947 | M1, M2 | none |
| M4 | Linear-time rules | 949, 950 | M3 verdict | none |
| M5 | Gate two: temporal slice and missing-rule list | 948 | M4 | none |
| M6a | Error-message coverage, with a count check that cannot regress | 954 part 1 | none | M1-M5 |
| M6b | Nested introduction patterns | 954 part 2 | none | M1-M5 |
| M6c | Goal display | 954 part 3 | none | M5 (so it reflects real scripts) |
| M7 | Frame coverage, Dense and RTime | 951 | none beyond merged `lstep` pattern | M4, M6 |
| M8 | One interface, rules proved once | 952 | M5, M7 | none |
| M9a | Minus instance | 953 (part) | M8 | none |
| M9b | Deduction theorems for Star and Open | not filed (953 may spawn it) | none | none |
| M10 | Safety and liveness library | 956 | M4, M5; M8 if proved once | M9a |
| M11 | Transition-system architecture report | 957 | M10 for the assessment | none for the Veil / ModelChecker survey |
| M12 | Adoption after GO: where proof-mode proofs live, what must use the mode | not filed | M3 | none |
| M13 | Trust and cost: axiom audits in tests; term-size and elaboration-time baseline | not filed | none | none |
| M14 | ModelChecker bridge and closers from decision procedures | not filed | M11; the decidability results | none |
| M15 | Reference-manual chapter and tactic-reference upkeep | not filed | M5 (stable rule set) | none |

Graph, hard dependencies only:

```
M1 --+
     +--> M3 (gate) --> M4 --> M5 (gate) --+--> M8 --> M9a
M2 --+                   |                 |      |
                         +-----------------+--> M10 --> M11 --> M14
M7 ---------------------------------------------^ (into M8)
M0, M6a, M6b, M9b, M13   no hard predecessor
M12 after M3;  M6c, M15 after M5
```

Whether M2 and M7 really run beside the spine depends on M0. Without M0 the single shared test
file forces the present total order, and the document should say that plainly: M0 is the
milestone that buys parallelism, and it is the cheapest one on the list.

### 3. Lanes

- **Rule theory** - pure rules in `FormalSystem/Theorems/ProofMode/`. Since `Theorems/` does not
  import `Automation/`, the pure rule for any milestone can land ahead of its tactic.
- **Elaborators** - `FormalSystem/Automation/ProofMode/`: tactics, patterns, goal display, errors.
- **Evaluation** - the two adequacy modules and reports, M13's measurements.
- **Metatheory** - M9b, and later the decision-procedure side of M14.
- **Research and writing** - M11, M12's decision, M15.

The rule / tactic seam inside each task is the finest joint available and costs nothing to use.

### 4. Items for the planner and user

- Confirm or reject each "sequencing" reading before any edge is relaxed. Three deserve a real
  look: 949 -> 950, 953 -> 956, and 950/954 -> 951.
- Decide whether `records/` is tracked and whether `ORGANISATION.md` gains a row for it. The
  repository's README and invariant lints may care about an unlisted top-level directory; this
  was not tested.
- Decide what "default" means for M12 given the `Theorems/` import invariant.
- Keep the 947 gate exactly as filed. Nothing proposed here weakens it; M4 onward still waits on
  the verdict.

## Risks & Mitigations

- **Task numbers leaking into the document.** A write-time hook may reject the file. Mitigation:
  slugs and local IDs only; keep the number mapping in this report.
- **The document duplicating `ROADMAP.md`.** The batch rationales there are already long.
  Mitigation: the document states goals and joints; it does not restate batch order or rationale.
- **Over-reading the edge analysis.** The logical / sequencing split is a reading of prose
  descriptions. Mitigation: present it in the document as proposed, with the three doubtful edges
  named as open.
- **Parallel lanes without M0.** Co-dispatching tasks that all edit one test file will collide,
  and no record declares a `file_scope` for the admission gate to see. Mitigation: M0 first, or
  keep the total order.
- **Source drift.** `research/NEW_DIRECTIONS.md` is gitignored and its tactic count is off by
  one. Mitigation: the document re-states what it needs and cites tracked files only.
- **Stale deployed agent system.** The dispatch notes the `.claude/` tree is stale for core,
  lean, sapience and typst. The roadmap-agent contract read here is the deployed copy; its
  behaviour was not checked against the source store.

## Context Extension Recommendations

none (meta task)

## Appendix

Search patterns used:

- `grep -hn '^syntax\|^elab\|^macro'` and `grep -o '"l[a-z_]*"' | sort -u` over
  `FormalSystem/Automation/ProofMode/*.lean` (tactic inventory, two shapes)
- `grep -o throwError | wc -l`; `grep -c 'guard_msgs\|fail_if_success'`
- `grep -rln ProofMode --include=*.lean FormalSystem Tests BimodalTools` (clients)
- `jq` over `specs/state.json` for `topic`, `dependencies`, `file_scope`, `roadmap_batches`
- `bash .claude/scripts/generate-task-order.sh --print` (wave table)
- `git check-ignore -v research/NEW_DIRECTIONS.md records/proof-mode.md`
- `git log -- FormalSystem/Automation/ProofMode`

Not done in this pass: no `lake build`, no lean-lsp queries, no check of
`scripts/check-module-invariants.sh` against a new `records/` directory, no measurement of
derivation term sizes.

Files read: `research/NEW_DIRECTIONS.md`, `docs/user-guide/derivation-proof-mode.md`, both
ProofMode READMEs, `FormalSystem/Automation/README.md`, `FormalSystem/Examples/README.md`,
`specs/TODO.md` entries 944-957, `specs/ROADMAP.md` (head and section index),
`.claude/agents/roadmap-agent.md`, `.claude/context/formats/report-format.md` (headings section).
