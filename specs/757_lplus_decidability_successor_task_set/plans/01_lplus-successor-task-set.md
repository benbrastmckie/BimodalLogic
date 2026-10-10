# Implementation Plan: Task #757

- **Task**: 757 - Research, design, and file the successor task set that carries L+ decidability — the unfiled frontier after the (C)/(S)/(W) partial landings
- **Status**: [IMPLEMENTING]
- **Effort**: 7 hours
- **Dependencies**: None
- **Research Inputs**: specs/757_lplus_decidability_successor_task_set/reports/01_lplus-successor-task-set.md
- **Artifacts**: plans/01_lplus-successor-task-set.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This task proves nothing. It converts the three OPEN frontier obligations named by
`FormalSystem/Metalogic/Decidability/RaySummary/README.md`'s "The verdict" table into (i) a
followup-scope-spec in the precedent format of
`specs/archive/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md`, with a
Section 0 that re-verifies every cited anchor against the tree in this implementation round, and
(ii) six FILED task records (T1-T6 of the research report's Finding 5) carrying a statement shape,
a fixed depth, typed dependency edges, a declared `file_scope`, and an honest costability status,
plus (iii) a hand-authored `specs/ROADMAP.md` Stage 1 edit that sequences them. Filing is the step
the precedent records deliberately omitted and is in scope by user instruction. Definition of done:
the spec exists with its Section 0 record and Section H carrying the numbers the six tasks actually
received; `specs/state.json` holds six new `not_started` lean4 rows with `dependencies[]` and
`file_scope[]` set at creation and `validate-state.sh` exits 0; `specs/ROADMAP.md` Stage 1 names
the three dispatch batches; no file outside `specs/**` is modified; no Stage 0 task (712, 713,
734, 709) and no sliced-certificate task (716, 714) is transitioned or edited.

### Research Integration

The research report is complete on every design question and this plan re-derives none of them:

- **Section 0 of the report** (compile record: 55 `#check`/`#print axioms` lines, exit 0, every
  headline at `[propext, Classical.choice, Quot.sound]`; probe gate 27 PASS + 1 SKIP; 0
  statement-level occurrences of `Decidable (PlusValidZTime`) is the template for the spec's own
  Section 0, which the implementation re-runs rather than copies (Phase 1).
- **Findings 1-4** fix the statement shapes: `ladderCell_stabilizes` over BOTH ladder counters
  `(c, n)` with exhibited bound `B := (plusSubformulaClosure φ).card` and `∃ B` fallback
  (sharpening the README's "in the deadline counter `c`"); `exists_hitPresented` with `sizeBound φ k`
  a count; obligation (3) assigned to (W) with no standalone (S) record (WIDTH
  `Probe747.modelOf_incomplete`, COLLAPSE `stab_iff_of_presented_nowUnique`); the lift
  `not_plusValidZTime_iff_ladderRefutes` and its `Decidable (PlusValidZTime φ)` corollary stated
  only in T6.
- **Finding 5** is the six-record table (T1 `preCell_stable`/`preCell_zero_ne`/`postCell_stable`
  probe; T2 `hitPresented_node`/`not_hitPresented_node` probe; T3 `ladderModel`/`Adm`/
  `ladderCell_stabilizes`; T4 `LadderCons`/`ladderRealized`; T5 `exists_hitPresented`; T6 the
  lift) with Kahn order T1 → T2 → T3 → T4 → T5 → T6, logical vs. serialization edges, narrowest
  `file_scope`, and costability (only T1 and T2 costable; the basis for each figure named).
- **Finding 6** is the filing mechanics this plan's Phase 4 executes verbatim: the `/task` Create
  Task Mode `state-write.sh` creation object with `dependencies`, `file_scope`, `topic`,
  `task_type` set at creation, `--regen-todo`, then `manage-topics.sh set`, then
  `validate-state.sh`; `--depends-on-add`/`--file-scope-add` are not needed at creation.
- **Decisions D1-D6** are carried into the spec and the filed descriptions as agent decisions
  re-openable by `/revise`, never as user rulings.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied to this dispatch, so no roadmap-review/roadmap-update phase pair
is generated. `specs/ROADMAP.md` is nevertheless a DELIVERABLE of this task (declared in 757's
`file_scope`): Phase 5 hand-edits its Stage 1 section, since the file's own header records that
`roadmap-integration.sh --regenerate` aborts silently against the Stage layout. The task advances
Stage 1 ("Decidability of L⁺") by replacing its two completed bullets (749, 750) with the six
successor records and three dispatch batches.

## Goals & Non-Goals

**Goals**:
- A followup-scope-spec at `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md`
  in the 721 format: Section 0 (0.1 compile record, 0.2 declaration anchors, 0.3 gate anchors,
  0.4 task-record anchors, 0.5 differences from the research report), Sections A-C (obligations
  1-3), Section D (the lift), Section H (six records with the numbers received), a "Stage 0
  described, not moved" section, a State-write disclosure, and a Trace table.
- Six tasks filed in Kahn order with `task_type: "lean4"`, `topic: "decidability"`,
  `dependencies[]` and `file_scope[]` set in the creation object, each description carrying its
  first statement shape, fixed depth, costability status (or why not costable), guardrails
  (a)-(e), the zero-debt posture, and the `[BLOCKED]` contingency where it applies.
- `specs/ROADMAP.md` Stage 1 updated by hand: three dispatch lines in the `## Next batches` block
  and one bullet per record under `## Stage 1 — Decidability of L⁺`, including the sentence that
  T2 is the highest-information probe and that a Hit-level negative there is a Stage 0 ruling.
- Every status claim in the spec re-derived in this round (compile record, gate run, grep,
  `state.json` read), never copied from the report.

**Non-Goals**:
- No mathematics: no Lean file is created or edited; no `sorry`, no axiom, no probe is written.
- No edit to any file outside `specs/**` — not `RaySummary/README.md`, not
  `docs/theorem-index.md`, not any script or test. (The README's "Successor" paragraph already
  says "their own records" and task numbers are forbidden there.)
- No transition or edit of Stage 0 tasks 712, 713, 734, 709 (described in the spec, never moved)
  and no edit to the sliced-certificate tasks 716, 714.
- No re-litigation of R2/R4/R5, no fourth certificate class, no upper-bound claim anywhere.
- No `--compare`/Challenge snapshot on this task: it has no Lean goals (see Decisions).

## Decisions

- **D-plan-1**: The Lean Challenge Statements section (plan-format.md) is deliberately ABSENT from this plan
  although `task_type` is `lean4`. The section pins theorem statements this task commits to prove;
  this task proves nothing and names no Lean identifier under Goals. `lean-challenge-snapshot.sh`
  treats a present-but-empty section as a hard error (exit 71), so omission is the only
  well-formed shape. Consequence: `--compare` is inapplicable to this task.
- **D-plan-2**: The spec is written BEFORE filing (Phases 1-3), then filing happens (Phase 4), then
  the numbers received are written back into Section H (Phase 4) — because Section 0 must
  re-verify before anything acts on the tree (description: "re-derive all three against the tree
  before acting") and the filed descriptions are drafted as Section H text first.
- **D-plan-3**: Serialization overlaps INSIDE the successor set are recorded as `dependencies[]`
  edges (CLAUDE.md batching rule: an unordered overlap becomes an edge, not an exclusion);
  overlaps with 744, 734, 410 OUTSIDE the set are named in the descriptions and left to the
  admission gate — no cross-set edge is added (report D5).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `next_project_number` shifts before filing (other live sessions file tasks) | M | M | Phase 4 re-reads `.next_project_number` immediately before EACH `state-write.sh` call and never hardcodes a number; Section H numbers are written after filing, not before |
| `state-write.sh` mutex (`specs/.scope-lock`) held by a concurrent writer — it fails CLOSED on acquire timeout | M | M | Retry with bounded backoff (3 attempts, 30 s apart); on persistent refusal mark Phase 4 `[PARTIAL]` with the tasks already filed enumerated in `progress-file.md`; never bypass the mutex or hand-edit `state.json` |
| `.olean` tree not fresh or `lake-build-guard.sh status` reports a holder when Phase 1 runs the compile record | M | L | Check guard status first; if a holder exists wait per `context/patterns/bounded-build-waiter.md`; if the frontier is stale, run `lake build` detached under the guard with a bounded waiter before the scratch compile; record the evidence tier in Section 0 either way |
| `check-evidence-probes.sh` is slow (27 probes) | L | H | Run detached with log in the scratchpad and a bounded waiter (`kill -0` on the captured PID, hard timeout); never a foreground sleep or unbounded watch |
| Filing six `lean4` tasks whose `file_scope` share the library "shared set" trips `validate-state.sh` Check 8/9 WARNs | L | M | WARN-only; T3-T6 each carry a distinct new file so no exact duplicate; entries are files not directory roots (750's `specs/evidence/seam-gluing-ray-product/` root is NOT repeated); WARN lines are recorded in the State-write disclosure, not suppressed |
| Pre-commit hook (`.githooks/pre-commit`) fails the Phase 5 commit on `typst/generated/status.typ` drift | L | L | The hook fires only when sorry/axiom counts move; this task edits no Lean file. If it fires anyway, follow the hook's own remediation line and record it as an issue — do not add `status.typ` to this task's `file_scope` |
| A filed description leaks a task-number reference into a non-`specs/**` file | L | L | No non-`specs/**` file is in any phase's `Files to modify`; Phase 5 attests with `git diff --name-only <base>..HEAD` showing only `specs/**` paths and runs `check-task-references.sh` as the backstop |
| T2 later returns a Hit-level negative (R1 blocked at (C)) | H | M | Not this task's risk to mitigate mathematically; the T2 description and the ROADMAP sentence record that such a negative is a Stage 0 user ruling, never an agent transition, and that T5/T6 then wait on the user |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential: each phase's
content is an input to the next (Section 0 → design sections → Section H text → filing → numbers
and ROADMAP).

### Phase 1: Re-verify every anchor and write Section 0 [COMPLETED]

**Goal**: Produce the spec's Section 0 verification record from this round's own runs — compile
record, declaration anchors, gate anchors, task-record anchors, differences from the research
report — so that nothing the later sections cite rests on a carried figure.

**Tasks**:
- [x] `bash .claude/scripts/lake-build-guard.sh status`; confirm no holder and that no
      `FormalSystem/**/*.lean` is newer than `.lake/build/lib/lean/FormalSystem.olean`
      (`find FormalSystem -name '*.lean' -newer .lake/build/lib/lean/FormalSystem.olean`). If
      stale, rebuild detached under the guard with a bounded waiter before continuing.
- [x] Write a scratch file in the scratchpad (import `FormalSystem`) with one `#check` and one
      `#print axioms` line per anchor in the report's Section 0.1 (the perimeter:
      `Compression.decidableValidZTime`, `PlusValidZTime`, both `StabFaithful`; (S):
      `presented_modelOf`, `hitCl_modelOf_eq_hitOf`; (C): `HitPresented`,
      `hitPresented_of_presented`, `hit_eq_hitOf_of_presented`,
      `kTypeOf_listSeg_replicate_eventually_periodic_bounded`, `inFamily_of_shrink_run`; (W):
      `anchorCons_anchorCells`, `anchorCells_ncard_le`, `cellAt`, `cellAt_eq_cellAt`, `Rlad`,
      `ladderFrame`, `ladderFrame_isRegular`, `ofSlicedStepFinBranch_mem_HF_iff`; negatives:
      `no_finite_carrier_sat`, `not_finite_width_fmp`, `not_plusValidZTime_neg_Φ`; fixture:
      `NoFiniteWidth.M`, `NoFiniteWidth.F_isRegular`, `NoFiniteWidth.Φ`). Run
      `timeout 300 lake env lean <scratch>`; require exit 0 and no `Unknown identifier`; record
      types and axiom profiles in Section 0.1.
- [x] Re-grep the declaration anchors of the report's 0.2 table (rows 1-19) by declaration name
      and record path + declaration kind in Section 0.2; cite names and paths, never line numbers,
      in Sections A-H. Confirm `grep -i stabiliz FormalSystem/Metalogic/Decidability/RaySummary/*.lean`
      still hits only `iterate_stabilizes`, and `grep -rn 'Decidable (PlusValidZTime' FormalSystem/
      Tests/ specs/evidence/ --include=*.lean` still has 0 statement-level hits.
- [x] Run `bash scripts/check-evidence-probes.sh` detached (log in scratchpad, bounded waiter);
      record PASS/SKIP counts and exit code in Section 0.3; list the
      `specs/evidence/seam-gluing-ray-product/` file set.
- [x] Read `specs/state.json` (jq, read-only) for the 0.4 table: 757, 749, 750, 720, 744, 734,
      751, 752, 410, 712, 713, 709, 716, 714 — status, `dependencies`, `file_scope`; record
      `next_project_number` and the `active_topics` entry `decidability`.
- [x] Write Section 0.5 "Differences from the research report": any anchor that moved, any count
      that differs, and the two-counter `(c, n)` sharpening restated as the spec's reading.
- [x] Create `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` with the
      preamble (format of record: the 721 spec; what this file does and does not do — it FILES,
      unlike its precedents) and Section 0 only.
- [x] Record issues/wins as they arise via `issue-record.sh` (`--phase implement`).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: The report's figures carried into this phase — 55 check/print lines at exit 0,
27 PASS + 1 SKIP from the probe gate, 20 probe files, 0 statement-level `Decidable (PlusValidZTime`
hits, `next_project_number` 758 — come from
`specs/757_lplus_decidability_successor_task_set/reports/01_lplus-successor-task-set.md` Section 0
and are confirmed only by re-running each command in this phase; Section 0.5 records every
difference.

**Tier Justification**: The edit is one new markdown file under `specs/**` with no compile or
elaboration surface (`suite_selection_select` returns `__FULL_SWEEP__` for it), so the covering
check is `bash .claude/scripts/verify-deploy.sh --only-gate 3,4` (doc lint and task-reference
lint) plus a diff read-through confirming every hunk lies inside that one file; the compile record
and gate run are the phase's CONTENT, each required to exit 0.

**Files to modify**:
- `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` - new file; preamble and Section 0 (0.1-0.5)

**Verification**:
- `lake env lean` on the scratch file exits 0 with no `Unknown identifier`; every `#print axioms`
  line reads `[propext, Classical.choice, Quot.sound]` (or the deviation is recorded in 0.1).
- `scripts/check-evidence-probes.sh` exits 0; counts recorded in 0.3.
- The spec file exists, contains `## Section 0` with subsections 0.1-0.5, and cites no line number
  outside Section 0.
- `bash .claude/scripts/verify-deploy.sh --only-gate 3,4` exits 0.

---

### Phase 2: Write Sections A-D — the three obligations and the lift [NOT STARTED]

**Goal**: Author the design half of the spec: one section per obligation plus one for the lift,
each in the 721 per-section shape (Current record / What the tree says / Scope decision / What
the successor must NOT do / Action required), carrying the first statement shapes from the
report's Findings 1-4 and the guardrails that constrain them.

**Tasks**:
- [ ] Section A — Obligation (1), run-layer phase 2 soundness half: `cellAt` on the ladder model;
      the two sources of counter-dependence (`c` via `Count`'s `c' + 1 = c`; `n` via `c' = n` at
      an idle state); the proposed `ladderModel` definition and `ladderCell_stabilizes` statement
      over `(q, c, n)` with exhibited `B := (plusSubformulaClosure φ).card` and the `∃ B`
      fallback; the `AnchorLayer.lean` count-not-complexity disclaimer quoted; why a `Node`
      fixture probe (T1) precedes the lemma (750's mitigation R-A); `LadderCons` and `Adm` as
      T3/T4 definitions.
- [ ] Section B — Obligation (2), run-layer phase 3 = (C)'s general row: the README's statement
      shape as `exists_hitPresented` with `sizeBound φ k` a count; where the evidence is thin
      (model A is `box`/`stab`-free, finite-width slice; nothing tests `HitPresented` on a
      `⊡`-bearing formula or infinite width); the `Node` probe T2 with its two possible headlines
      `hitPresented_node` / `not_hitPresented_node`, the formula fallback order (`Φ`, then `D`,
      then `⊡Xp`), the seam `(t, pre k)` with `canon`; why a Hit-level negative blocks R1 with no
      fallback and is a Stage 0 ruling.
- [ ] Section C — Obligation (3), (S) beyond its landed corner: the README's own assignment to
      (W); WIDTH (`Probe747.modelOf_incomplete`) and COLLAPSE (`stab_iff_of_presented_nowUnique`);
      why no standalone (S) record is filed (guardrail (b)); the `box`/`stab` half as an
      acceptance clause of T4 (`box_mem_tpOf_iff` one global bit, `stab_mem_tpOf_iff` one bit per
      cell, `anchorCons_anchorCells` the completeness side); the "every seam but the one" half as
      T6's statement; `presented_modelOf` untouched.
- [ ] Section D — The lift: `not_plusValidZTime_iff_ladderRefutes` with `objBound φ` a count; (→)
      from anchor layer + (C)'s general row + the stabilization bound, (←) from the realization
      theorem at the refuting cell; the `Decidable (PlusValidZTime φ)` corollary by bounded
      enumeration stated ONLY here; depth `k = 1` throughout; not costable until T4/T5 have shapes.
- [ ] In every section: guardrails (a)-(e) applied by name; the forward-only caveat of guardrail
      (e) stated wherever a result is forward-only; `[BLOCKED]` named as the honest outcome where
      the mathematics may not close; no upper bound, no external Büchi/MSO citation, no cslib
      `require`.
- [ ] Record the report's Decisions D1-D4 in the sections they belong to, each marked as an agent
      decision re-openable by `/revise`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: Sections A-D are prose appended to the Phase 1 markdown file under
`specs/**` (no mapped suite; `__FULL_SWEEP__`), so the covering check is
`bash .claude/scripts/verify-deploy.sh --only-gate 3,4` plus a diff read-through confirming every
Lean name cited in A-D appears in Section 0.1 or 0.2 (grep each backticked identifier against the
Section 0 text).

**Files to modify**:
- `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` - append Sections A, B, C, D

**Verification**:
- Each of Sections A-D is present with the five 721 subsection labels.
- Every backticked declaration name in A-D resolves to a Section 0.1/0.2 row (scripted grep,
  zero unmatched names).
- No section contains "2EXPTIME" as an upper bound, "Büchi"/"MSO" as a cited lemma, or
  "cslib" as a dependency; a grep for each term shows only negated/guardrail uses.
- `bash .claude/scripts/verify-deploy.sh --only-gate 3,4` exits 0.

---

### Phase 3: Write Section H, the Stage 0 section, and the disclosure skeleton [NOT STARTED]

**Goal**: Draft the six records (T1-T6) as the exact text Phase 4 will file — title, `task_type`,
`topic`, `dependencies` (typed: logical vs. serialization), `file_scope` (files, never directory
roots), depth, first statement shape, costability status with basis or reason, guardrails,
zero-debt posture, `[BLOCKED]` contingency — plus the "Stage 0 described, not moved" section and
the State-write disclosure skeleton.

**Tasks**:
- [ ] Section H preamble: six records; filed BY THIS TASK's implementation phase (the deliberate
      departure from the 721/718 precedents); Kahn order T1 → T2 → T3 → T4 → T5 → T6; the
      Component 0 divide reasons that justify six and not fewer (report Finding 5, "Why six").
- [ ] H1 (T1) — `preCell_stable` / `preCell_zero_ne` / `postCell_stable` on `NoFiniteWidth.M` for
      `Φ` (fallback `D`): wired probe; `file_scope`
      `specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean`,
      `scripts/check-evidence-probes.sh`,
      `FormalSystem/Metalogic/Decidability/RaySummary/README.md`; deps none; costable (basis:
      `backward-dual-asymmetric-fixture.lean` and `deadline-ladder-branching.lean` line counts
      re-measured in Phase 1).
- [ ] H2 (T2) — `hitPresented_node` or `not_hitPresented_node` on `NoFiniteWidth.M`, seam
      `(t, pre k)`, every `k ≥ 1`: wired probe; `file_scope`
      `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean`,
      `scripts/check-evidence-probes.sh`, `RaySummary/README.md`; deps T1 (serialization);
      costable with a wide band (basis `hit-presented-model-a.lean`, marked CARRIED-UNVERIFIED
      from 749's summary unless re-measured); the highest-information probe; a negative is a
      Stage 0 ruling.
- [ ] H3 (T3) — `ladderModel`, `Adm`, `ladderCell_stabilizes` (both counters, exhibited `B`,
      fallback `∃ B`): library; `file_scope`
      `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean`,
      `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `FormalSystem.lean`,
      `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`,
      `scripts/check-module-invariants.sh`, `docs/theorem-index.md`, `RaySummary/README.md`,
      `typst/generated/status.typ`; deps T1 (logical), T2 (serialization); NOT costable — reason
      stated.
- [ ] H4 (T4) — `LadderCons`, `ladderCons_localRun`, `ladderRealized` per ladder cell for ALL `φ`
      including `box`/`stab` letters: library; `file_scope` `RaySummary/LadderRealize.lean` plus
      T3's shared set; deps T3; NOT costable — reason stated.
- [ ] H5 (T5) — `exists_hitPresented` with `sizeBound φ k` a count: library, research-first;
      `file_scope` `RaySummary/HitComplete.lean` plus shared set; deps T2 (logical), T4
      (serialization); NOT costable — open mathematics; `[BLOCKED]` honest.
- [ ] H6 (T6) — `not_plusValidZTime_iff_ladderRefutes` and the `Decidable (PlusValidZTime φ)`
      corollary: library, research-first; `file_scope` `RaySummary/Lift.lean` plus shared set;
      deps T4, T5; NOT costable — reason stated.
- [ ] Each H entry names its cross-set collisions (744 on `RaySummary/README.md` and
      `check-module-invariants.sh`; 734 on `check-evidence-probes.sh`; 410 on
      `typst/generated/status.typ`) as admission-gate matters, with no cross-set edge.
- [ ] Each H entry's description text is written in full as the string Phase 4 passes to
      `state-write.sh` (statement shape, not prose goal; depth; guardrails (a)-(e); zero debt;
      the forward-only caveat; the `[BLOCKED]` contingency).
- [ ] "Stage 0 described, not moved": 712 (`[BLOCKED]` marker correction), 713 (CTL-like fragment
      re-ruling), the held 2EXPTIME ceiling, 734 (`[PARTIAL]` mosaics route) — each described with
      its current `state.json` status from Section 0.4 and the sentence that this task may
      describe but never move them; 716/714 named as untouched.
- [ ] State-write disclosure skeleton (what this task will write: the spec, `state.json` rows
      T1-T6, `TODO.md` via regen, `ROADMAP.md`; what it will not: any `FormalSystem/`, `docs/`,
      `scripts/`, `Tests/`, typst file) — finalized in Phase 5.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: Six records with the `file_scope` lists above (from the report's Finding 5
table) is the hypothesis; confirm at authoring time that each new-file path does not already exist
(`ls` each), that every non-new path exists in the tree, and that no entry is a directory root.

**Tier Justification**: Prose appended to the `specs/**` spec file (no mapped suite;
`__FULL_SWEEP__`), covered by `bash .claude/scripts/verify-deploy.sh --only-gate 3,4` plus a
scripted check that every `file_scope` path in Section H either exists or is marked "(new)" and
that none ends in `/`.

**Files to modify**:
- `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` - append Section H (H1-H6 with T-labels), "Stage 0 described, not moved", State-write disclosure skeleton

**Verification**:
- Section H has exactly six `### H{n}` entries, each with Proposed title / `task_type` / `topic` /
  dependencies (typed) / `file_scope` / depth / first statement / costability / description /
  action required.
- Scripted `file_scope` check passes (existing paths exist; new paths absent and marked; no
  directory roots).
- Every `dependencies` edge named in H points only at T1-T6 (no cross-set edge).
- `bash .claude/scripts/verify-deploy.sh --only-gate 3,4` exits 0.

---

### Phase 4: File T1-T6 and record the numbers received [NOT STARTED]

**Goal**: Create the six task rows in `specs/state.json` through the sanctioned writer, in Kahn
order, with `dependencies` and `file_scope` in the creation object; register the topic; validate;
then write the received numbers into Section H.

**Tasks**:
- [ ] `source .claude/scripts/lib/common.sh`; use this dispatch's `session_id` for every
      `state-write.sh` call.
- [ ] For each of T1..T6 in order: re-read `next=$(jq '.next_project_number' specs/state.json)`;
      map the T-labels of its dependencies to the numbers already received; call
      `bash .claude/scripts/state-write.sh '<creation filter>' --session-id "$session_id" --arg ts
      "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg desc "$desc" --arg slug "$slug" --argjson deps
      '[...]' --argjson fs '[...]' --regen-todo`, where the filter is the `/task` Create Task Mode
      object (`commands/task.md` Step 6) extended with `"dependencies": $deps`,
      `"file_scope": $fs`, `"topic": "decidability"`, `"task_type": "lean4"`, `"status":
      "not_started"`, and `.next_project_number = <next+1>`; then
      `bash .claude/scripts/manage-topics.sh set <number> decidability` (hard error on failure,
      remediation line printed). Slugs (≤50 chars, snake_case): `node_cell_stabilization_probe`,
      `node_hit_presented_probe`, `ladder_model_cell_stabilization_lemma`,
      `ladder_realization_theorem`, `hit_presented_general_row`,
      `ladder_lift_decidability_corollary`.
- [ ] On a mutex refusal: retry up to 3 times at 30 s; on persistent refusal mark this phase
      `[PARTIAL]` with the filed subset enumerated; never hand-edit `state.json`.
- [ ] After the sixth write: `bash .claude/scripts/validate-state.sh specs/state.json` (exit 0;
      capture any Check 8/9 `file_scope` WARN lines for the disclosure); confirm `TODO.md` shows
      the six entries with `[NOT STARTED]`; confirm `jq '.active_projects[] | select(.topic ==
      "decidability")'` lists them.
- [ ] Write the numbers received into Section H: a "T-label → task number" map table at the top
      of Section H, each `### H{n}` heading gaining its number, and every `dependencies` entry
      restated with numbers.
- [ ] Commit the phase (scoped pathspec: `specs/state.json`, `specs/TODO.md`, the spec file) via
      `bash .claude/scripts/git-commit-scoped.sh --message "task 757 phase 4: file the six L+
      successor records" --session "$session_id" -- specs/state.json specs/TODO.md
      specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md`.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: Six rows created and `next_project_number` advancing from its Phase 1 value
by exactly six is the hypothesis; confirm by `jq '.next_project_number'` before and after, and by
counting rows with `topic == "decidability"` and `created` after this phase's start timestamp.

**Tier Justification**: The edit is confined to `specs/state.json` (and the generated
`specs/TODO.md` and the spec file), all machine-validated by one command —
`bash .claude/scripts/validate-state.sh specs/state.json` exit 0 is the complete covering check
for the JSON, with `generate-todo.sh`'s successful regeneration (already run by `--regen-todo`)
covering `TODO.md`; no code path outside the state writer reads these rows before the task closes.

**Files to modify**:
- `specs/state.json` - six new `active_projects` rows (T1-T6) via `state-write.sh`; `next_project_number` advanced by six
- `specs/TODO.md` - regenerated by `generate-todo.sh` through `--regen-todo` (never hand-edited)
- `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` - Section H numbers map and per-entry numbers

**Verification**:
- `bash .claude/scripts/validate-state.sh specs/state.json` exits 0.
- Six new rows: `status == "not_started"`, `task_type == "lean4"`, `topic == "decidability"`,
  `dependencies` arrays matching Section H's typed edges by number, `file_scope` arrays matching
  Section H exactly (files only).
- `specs/TODO.md` lists the six tasks; `manage-topics.sh` reports `decidability` for each.
- Section H's map table has six rows and no remaining bare T-label in a dependency entry.

---

### Phase 5: ROADMAP Stage 1 edit, disclosure, trace, full gate [NOT STARTED]

**Goal**: Sequence the six filed tasks in `specs/ROADMAP.md` Stage 1 by hand, finalize the spec's
State-write disclosure and Trace table, and run the complete gate set with the attestation that no
file outside `specs/**` changed.

**Tasks**:
- [ ] `specs/ROADMAP.md` `## Next batches` block, Stage 1: replace the completed `749` and `750`
      lines with three dispatch lines in dependency-inclusive batches — `T1,T2 --hard`, then
      `T3,T4 --hard --lit`, then `T5,T6 --hard --lit` (numbers from Phase 4), each with a short
      trailing comment in the file's existing style; leave the `720`, `716,714`, `712` lines and
      every other Stage untouched.
- [ ] `## Stage 1 — Decidability of L⁺`: replace the 749 and 750 bullets with one bullet per
      record (statement shape, depth, costability status, the typed edges, the collision note on
      744/734/410), plus the sentence that T2 is the highest-information probe on the frontier and
      that a Hit-level negative there is a Stage 0 ruling, not an agent transition; keep the
      Guardrails and Named risks subsections unchanged except to update the "Hit-level
      completeness fails" row's evidence pointer to name T2 by number.
- [ ] Update the header italic's "last edited" date.
- [ ] Finalize the spec's State-write disclosure (what was written: the spec, six `state.json`
      rows, `TODO.md` regen, `ROADMAP.md`; the `validate-state.sh` WARN lines if any; what was
      not: any file outside `specs/**`, any Stage 0 or sliced-certificate task) and the Trace
      table (ROADMAP change → specification section).
- [ ] Attest: `git diff --name-only <phase-1-base-commit>..HEAD -- . ':!specs/**'` is empty and
      the working tree has no non-`specs/**` change; `bash .claude/scripts/check-task-references.sh`
      exits 0.
- [ ] Full gate: `bash .claude/scripts/verify-deploy.sh` exits 0; `bash
      .claude/scripts/validate-state.sh specs/state.json` exits 0; `bash
      .claude/scripts/validate-artifact.sh specs/757_lplus_decidability_successor_task_set/plans/01_lplus-successor-task-set.md plan`
      exits 0.
- [ ] Commit the phase (scoped pathspec: `specs/ROADMAP.md`, the spec file) via
      `git-commit-scoped.sh`; write the summary per `summary-format.md` and the terminal
      `.return-meta.json` / `.orchestrator-handoff.json`.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: full

**Files to modify**:
- `specs/ROADMAP.md` - Stage 1 dispatch lines and bullets for the six records; header date
- `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` - State-write disclosure finalized; Trace table

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` exits 0 (the complete gate set; `--skip-slow` is not a
  tier and is not used here).
- `bash .claude/scripts/validate-state.sh specs/state.json` exits 0.
- `bash .claude/scripts/check-task-references.sh` exits 0 and the non-`specs/**` diff is empty.
- `specs/ROADMAP.md` Stage 1 names all six task numbers in both the `## Next batches` block and
  the Stage 1 bullets; 712/713/734/709/716/714 lines are byte-identical to before (diff shows
  no hunk touching them).
- The spec's Trace table maps every ROADMAP hunk to a section.

## Testing & Validation

- [ ] Phase 1 compile record exits 0 with no `Unknown identifier`; probe gate exits 0.
- [ ] Every Lean name cited in Sections A-H appears in Section 0.1/0.2 (scripted grep, zero
      unmatched).
- [ ] Section H `file_scope` check: existing paths exist, new paths absent and marked, no
      directory roots.
- [ ] `validate-state.sh` exits 0 after filing; six rows with correct `dependencies`/`file_scope`/
      `topic`/`task_type`.
- [ ] `TODO.md` regenerated (not hand-edited) and lists the six tasks.
- [ ] No file outside `specs/**` modified (empty non-`specs/**` diff); `check-task-references.sh`
      exits 0.
- [ ] `verify-deploy.sh` full run exits 0 before the task closes.
- [ ] Stage 0 tasks 712/713/734/709 and sliced-certificate tasks 716/714 unchanged in
      `state.json` (jq diff of those rows before/after).

## Artifacts & Outputs

- `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` — the specification
  (Sections 0, A-D, H, Stage 0 described-not-moved, State-write disclosure, Trace).
- Six new rows in `specs/state.json` (T1-T6; numbers assigned at filing) and their `TODO.md`
  entries.
- `specs/ROADMAP.md` Stage 1 updated.
- `specs/757_lplus_decidability_successor_task_set/summaries/01_lplus-successor-task-set-summary.md`
  (written at close by the implementation agent).

## Rollback/Contingency

- The spec file is additive and lives only under `specs/757_.../`; reverting it is a scoped
  `git checkout` of that one path after the snapshot-then-rollback recipe in
  `context/contracts/recovery.md`'s rollback rung (never a bare `git-snapshot.sh 757` as a
  routine checkpoint; for a defensive checkpoint before Phase 4 use `--no-revert`).
- Filed tasks are NEVER removed by hand-editing `state.json`; a wrongly filed record is retired
  with `/task --abandon N` (one per task), which is the sanctioned reverse of a creation write.
- A partial filing (mutex refusal mid-sequence) is resumable: the T-label → number map in
  Section H records what was filed; the next dispatch continues from the first unfiled label with
  `next_project_number` re-read.
- The `ROADMAP.md` edit is a single hunk set confined to Stage 1; revert by scoped checkout of
  that path if the filing is abandoned, since its lines would then name tasks that do not exist.
