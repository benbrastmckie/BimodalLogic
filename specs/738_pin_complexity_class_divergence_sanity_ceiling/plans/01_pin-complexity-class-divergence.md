# Implementation Plan: Task #738

- **Task**: 738 - Pin the complexity-class divergence behind the CTL-star 2EXPTIME sanity ceiling and repair its citation paths
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None (713 stays on HOLD and is not a dependency; this task edits its record)
- **Research Inputs**: specs/738_pin_complexity_class_divergence_sanity_ceiling/reports/01_pin-complexity-class-divergence.md
- **Artifacts**: plans/01_pin-complexity-class-divergence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

The research report rules the co-NEXPTIME/NEXPTIME wording difference between source A (706 Q4)
and source B (703 round-2 section 1.6) RECONCILED, not divergent: each names a different side of
one containment (validity with co-NEXPTIME, non-validity/satisfiability with NEXPTIME), and the
two containments are equivalent because 2EXPTIME is a deterministic class closed under
complement. The repair surface is therefore 713's own `specs/state.json` record (the only place
carrying "two versions of the consequence"), plus three `FormalSystem` READMEs that cite the
ceiling without the ARGUED qualifier. This plan rewrites 713's `description` and `hold_reason` in
one mutex-guarded `state-write.sh` call that leaves `status`, `prior_status` and `held_at`
untouched (so the hold and its 2026-10-03 ruling date survive), inserts the qualifier at the
three README sites, and closes with an output audit for upper-bound language. No Lean, no
archive edits, no hold lift.

### Research Integration

- D1/R1: ruling is "reconciled"; canonical wording (quoted verbatim in Phase 1) names the
  problem on each side and both classes as one fact, carries the ARGUED qualifier, and ends with
  the explicit lower-bound-only prohibition.
- Finding 4/R2: four stale paths in 713, not three -- the dispatch's three plus the
  `followup-scope-spec.md` path in the KEEP-OR-ABANDON paragraph; plus a stale "status
  not_started" opening sentence. All four archive paths re-verified present at plan time.
- Finding 6/R4: `update-task-status.sh preflight 713 hold --hold-reason=...` resets `held_at` to
  today; the plan uses a direct `state-write.sh` filter instead, and post-checks the three
  preserved fields.
- Finding 5/R5: three README sites lack the qualifier. Taken into scope here (the dispatch's
  acceptance (4) is "every citation site", and `file_scope` on this task already lists them).
- Finding 3: the three dispatch-named citing records (718, 721, 719) quote only the lower bound,
  never the consequence, so no edit is owed at those sites (and 718/721/719 are archived and
  must not be edited regardless).
- R6/D5: no `user_decision`. The hold stays; whether its reason should be re-held as fully
  settled is left to the operator as a recommendation in the summary.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied to this dispatch; roadmap not consulted. (`specs/ROADMAP.md:106`
already carries the ARGUED qualifier per the report's Finding 5 and needs no edit.)

## Goals & Non-Goals

**Goals**:
- Record the reconciliation ruling, with the validity/non-validity direction explicit, in 713's
  `description`, replacing its CAVEAT sentence pair.
- Place ONE canonical wording of the consequence in 713's `description` under a labelled
  heading, for any future citing record to quote verbatim.
- Correct all four stale paths in 713's `description` to their `specs/archive/` locations with
  line anchors, and correct the stale status sentence.
- Close the open sub-item clause in 713's `hold_reason` without lifting the hold or changing
  `held_at`/`prior_status`.
- Insert the "argued, not formalized" qualifier at the three `FormalSystem` README citation
  sites.
- Leave zero upper-bound claims anywhere in this task's output.

**Non-Goals**:
- Formalizing the reduction, or adding any CTL-star syntax/semantics (713's GOAL; out of scope).
- Lifting 713's HOLD (operator-only; `update-task-status.sh preflight 713 unhold`).
- Editing anything under `specs/archive/` (the sources being adjudicated are evidence).
- Editing `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` (already
  qualified; Lean is out of scope).
- Writing a second durable copy of the canonical wording as a separate `specs/` note (713's
  description is the single citable home; a second copy is the drift this task removes).
- Touching the live descriptions of 711, 732, 735, 737, 739 (all already carry ARGUED).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Canonical wording drifts into an upper-bound reading when transcribed | H | L | Quote R1's text verbatim; Phase 3 greps the whole diff for `suffices`, `upper bound`, `in 2EXPTIME`, `2EXPTIME-complete`, `decidable in` |
| `held_at` silently reset to today, erasing the 2026-10-03 user-ruling date | M | M | Never use `update-task-status.sh ... hold` for the reason rewrite; Phase 1 post-check asserts `held_at == "2026-10-03"` |
| Sibling task edits `specs/state.json` in the same cycle; stale jq input | M | L | Build the filter with `--arg` bindings (not a pre-rendered document); `state-write.sh` serializes the write; re-read 713's record immediately before and after |
| README line numbers drift again before implementation (they already moved between report and plan: 35->41, 96->101) | L | M | Phase 2 locates each site by phrase, not line; Scope Hypothesis names the check |
| A task-number citation lands in a `FormalSystem/` README | M | L | Phase 2 inserts only the parenthetical qualifier; `hooks/validate-no-task-references.sh` gates the write |
| Over-reading the ruling as a claim about the reduction itself | M | L | Phase 1 edits only the CAVEAT paragraph, the status sentence and the four paths; GOAL, THE REDUCTION, WHAT IT COSTS and the R4 "LOW" risk text are left verbatim |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Rewrite 713's record -- ruling, canonical wording, paths, hold sub-item [COMPLETED]

**Goal**: 713's `description` carries the reconciliation ruling and the single canonical wording,
all four citation paths point at their archive locations, the status sentence is current, and
`hold_reason`'s open sub-item is closed -- in one write that leaves `status`, `prior_status`
and `held_at` untouched.

**Tasks**:
- [x] Re-read 713's current record: `jq '.active_projects[] | select(.project_number == 713)' specs/state.json`. Confirm `status == "hold"`, `prior_status == "not_started"`, `held_at == "2026-10-03"` before editing. *(completed)*
- [x] Draft the new `description` in a scratch file OUTSIDE the repo (the session scratchpad), starting from the current text and applying exactly these edits, leaving every other sentence verbatim: *(completed)*
  - (a) Status sentence. Replace `This task stays unscheduled: status not_started, dependencies [], nothing depends on it.` with `This task stays unscheduled: status HOLD (user ruling 2026-10-03; prior_status not_started), dependencies [], nothing depends on it.`
  - (b1) Replace `All three were verified against the tree at the time of this revision:` with `All three were re-verified against the tree on 2026-10-07 (task 738), at their archive locations:`
  - (b2) Replace `1. specs/718_omega_sequence_decidability_full_lplus/reports/02_ranked-route-analysis.md, the "Complexity sanity check" bullet:` with `1. specs/archive/718_omega_sequence_decidability_full_lplus/reports/02_ranked-route-analysis.md (archived), the "Complexity sanity check" bullet at line 258:`
  - (b3) Replace `2. Task 719's description (ray layer, seam gluing and stab fibre), Deliverable 5:` with `2. Task 719's description (ray layer, seam gluing and stab fibre; completed and archived at specs/archive/719_ray_layer_seam_gluing_and_stab_fibre, record in specs/archive/state.json -- now provenance rather than a live document), Deliverable 5:`
  - (b4) Replace `3. specs/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md section 3.1 (L-plus routes forward):` with `3. specs/archive/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md (archived) section 3.1 (L-plus routes forward), line 147 -- its Section C ruling on this task is at line 183:`
  - (b5) In the KEEP-OR-ABANDON paragraph, replace `(specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md)` with `(specs/archive/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md, Section C at line 220)`.
  - (c) Replace the two CAVEAT sentences -- from `CAVEAT ON THAT CONSEQUENCE:` through `must not restate the consequence as an upper bound on L-plus.` -- with the following, as a new paragraph (verbatim, including the heading):

    `CANONICAL WORDING OF THE CONSEQUENCE (quote this, verbatim, in any record that repeats it). L-plus Z-time validity -- equivalently, by negation, L-plus Z-time satisfiability -- is 2EXPTIME-hard by the CTL-star reduction. ARGUED, NOT FORMALIZED: no Lean declaration establishes it. CONSEQUENCE, stated for NON-VALIDITY: if every non-valid formula had a certificate of size singly exponential in the closure size, checkable in time polynomial in the certificate's size, then non-validity (satisfiability of the negation) would be in NEXPTIME and, equivalently, validity would be in co-NEXPTIME; hence 2EXPTIME would be contained in NEXPTIME, equivalently in co-NEXPTIME, since 2EXPTIME is closed under complement. That containment is not refuted but is widely disbelieved. The two class names are the same statement read from opposite sides of the complement: a record may name either, but must say which problem it is placing (NON-VALIDITY with NEXPTIME; VALIDITY with co-NEXPTIME). This is a LOWER bound used as a ceiling: nothing cheaper than 2EXPTIME is credible. It says nothing about any cost sufficing for L-plus and must never be restated as an upper bound. Sources: 706 Q4 (validity / co-NEXPTIME reading) and 703 round-2 section 1.6 (satisfiability / NEXPTIME reading), reconciled 2026-10-07 (task 738): the apparent divergence was one of presentation, not content.`
- [x] Draft the new `hold_reason` in a second scratch file: keep everything up to and including `but not schedulable by ordinary dispatch.` verbatim, then replace the final clause (`Open sub-item: sources diverge between co-NEXPTIME and NEXPTIME; pin which bound the citing records should quote, or record the divergence here.`) with `Sub-item closed 2026-10-07 (task 738): the co-NEXPTIME/NEXPTIME wording difference between 706 Q4 and 703 round-2 section 1.6 is reconciled, not a divergence -- the two name opposite sides of one containment; canonical wording now in this record's description.` *(completed)*
- [x] Apply with ONE `state-write.sh` call (never `update-task-status.sh preflight 713 hold`, which resets `held_at`): *(completed)*
  ```
  bash .claude/scripts/state-write.sh \
    '(.active_projects[] | select(.project_number == 713)) |= (.description = $desc | .hold_reason = $hr | .last_updated = $ts)' \
    --session-id "$SESSION_ID" \
    --arg desc "$(cat "$SCRATCH/713-description.txt")" \
    --arg hr "$(cat "$SCRATCH/713-hold-reason.txt")" \
    --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --regen-todo
  ```
- [x] Post-write invariants (all must hold): `jq -e '.active_projects[] | select(.project_number == 713) | .status == "hold" and .prior_status == "not_started" and .held_at == "2026-10-03"' specs/state.json`; `jq -r '... | .description' | grep -c 'CANONICAL WORDING OF THE CONSEQUENCE'` is 1; the description contains no `specs/718_`, `specs/721_` path without the `archive/` prefix; `grep -c 'Open sub-item' <hold_reason>` is 0; `specs/TODO.md`'s `### 713.` entry renders the new description and still shows `- **Held**: 2026-10-03`. *(completed)*
- [x] Commit (scoped: `specs/state.json`, `specs/TODO.md`) as `task 738 phase 1: rewrite 713's record -- ruling, canonical wording, archive paths, hold sub-item`. *(completed)*

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The four archive paths and their line anchors (718 report line 258; 721 report lines 147 and 183; 721 followup-scope-spec line 220) are CARRIED from the research report's Finding 4 (file existence re-verified at plan time; line numbers not re-derived). Confirm each anchor with `sed -n '<line>p' <archive-path>` before writing it into 713's description; if a line has moved, write the current line number. The archive is read-only for this task, so drift is possible only from a later `/todo` run, not from any edit here.

**Files to modify**:
- `specs/state.json` - task 713's `description` (edits a-c), `hold_reason` (final clause), `last_updated`; nothing else on that record, no other record
- `specs/TODO.md` - regenerated by `--regen-todo`, not hand-edited

**Verification**:
- `state-write.sh` exits 0 (its internal `validate-state.sh` passes) and the post-write jq invariants above all hold
- `git diff specs/state.json` touches exactly three fields of exactly one record (713)
- Diff read-through: no sentence outside the CAVEAT paragraph, the status sentence, the "All three were verified" sentence and the four path citations has changed

---

### Phase 2: Insert the ARGUED qualifier at the three FormalSystem README sites [COMPLETED]

**Goal**: Every live citation of the CTL-star 2EXPTIME lower bound in deliverable prose carries
the "argued, not formalized" qualifier, as 713's record requires of every citing site.

**Tasks**:
- [x] Locate each site by phrase (line numbers below are as of plan authoring and have already drifted once): `grep -n "2EXPTIME" FormalSystem/Semantics/Presheaf/README.md FormalSystem/Metalogic/Decidability/RaySummary/README.md FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md`. *(completed)*
- [x] `FormalSystem/Semantics/Presheaf/README.md` (~line 306): `The CTL\* 2EXPTIME lower bound is the sanity check` -> `The CTL\* 2EXPTIME lower bound (argued, not formalized) is the sanity check`. *(completed)*
- [x] `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (~line 41, sentence wraps onto line 42): `The CTL⋆ 2EXPTIME lower bound is a` -> `The CTL⋆ 2EXPTIME lower bound (argued, not formalized) is a`. *(completed)*
- [x] `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` (~line 101): `the CTL⋆ 2EXPTIME lower bound is a sanity ceiling only` -> `the CTL⋆ 2EXPTIME lower bound (argued, not formalized) is a sanity ceiling only`. *(completed)*
- [x] Insert nothing else: no task number, no pointer to `specs/`, no restatement of the consequence. (These files are outside `specs/**`; `no-task-references-in-deliverables.md` applies and the write hook enforces it.) *(completed)*
- [x] Confirm the three target lines sit outside any `<!-- BEGIN GENERATED ... -->` / `<!-- END GENERATED -->` block (Presheaf's generated inventory block is lines 55-64; the other two READMEs have none at plan time). *(completed)*
- [x] Commit (scoped: the three README paths, listed explicitly) as `task 738 phase 2: carry the ARGUED qualifier at the three README citation sites`. *(completed)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: Exactly three `FormalSystem/**/README.md` sites cite the 2EXPTIME bound without the qualifier (re-derived at plan time via `grep -rn "2EXPTIME" FormalSystem --include=README.md | grep -vi argued`, which returned precisely these three). Re-run that grep at implementation time; after the edit it must return zero lines. If it returns a fourth site, add it to this phase and record the addition in the summary.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/README.md` - one parenthetical insertion
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - one parenthetical insertion
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` - one parenthetical insertion

**Verification**:
- `grep -rn "2EXPTIME" FormalSystem --include=README.md | grep -vi "argued"` returns nothing
- `git diff --stat` shows exactly three files, each +1/-1 (or +2/-2 where the sentence re-wraps)
- Diff read-through: every changed hunk is inside markdown prose; no `task` + digits introduced

---

### Phase 3: Output audit and close [COMPLETED]

**Goal**: Confirm the hard constraints across everything this task wrote -- no upper-bound
claim, no archive edit, no hold lift, no Lean -- and leave the operator recommendation on
713's hold reason recorded in the summary.

**Tasks**:
- [x] Upper-bound sweep over the task's whole output: `git diff <base>..HEAD -- specs/state.json FormalSystem/ specs/738_pin_complexity_class_divergence_sanity_ceiling/ | grep -n -i "suffices\|upper bound\|upper-bound\|in 2EXPTIME\|2EXPTIME-complete\|decidable in\|EXPSPACE-complete"`. Every hit must be either a prohibition ("must never be restated as an upper bound", "never a source of an upper bound") or a direct quotation of 713's existing hazard text; any other hit is a defect to fix before closing. *(completed)*
- [x] Archive integrity: `git status --short specs/archive/` is empty and `git diff --stat <base>..HEAD -- specs/archive/` is empty. *(completed)*
- [x] Hold integrity: re-run Phase 1's three-field jq invariant; `grep -c "^### 713\." specs/TODO.md` is 1 and the entry is still `[HOLD]`. *(completed)*
- [x] Lean integrity: `git diff --stat <base>..HEAD -- '*.lean'` is empty. *(completed)*
- [x] Record in the implementation summary: (i) the ruling ("reconciled, not divergent") in one sentence with the direction named; (ii) the four paths corrected (three from the dispatch + the followup-scope-spec path); (iii) the three README sites qualified; (iv) RECOMMENDATION ONLY for the operator -- 713's `hold_reason` no longer names open work and its stated purpose ("keep the record live so the three citations stay valid") stands alone; if the operator wants the hold re-stated as fully settled, that is their `preflight 713 unhold` / re-hold cycle, not this task's; (v) the research report's context-extension note on archive-stable citation hygiene, as a follow-up candidate, not tasked here. *(completed)*
- [x] Final commit per the implementation contract (`task 738: complete implementation`), scoped to this task's artifacts plus `specs/state.json`/`specs/TODO.md`. *(deviation: altered — phase-closing commit is `task 738 phase 3: output audit and close`; the `complete implementation` commit is emitted by orchestrator postflight)*

**Timing**: 0.5 hours

**Depends on**: 1, 2

**Verification Tier**: prose

**Files to modify**:
- `specs/738_pin_complexity_class_divergence_sanity_ceiling/summaries/01_pin-complexity-class-divergence-summary.md` - implementation summary (created)

**Verification**:
- All four integrity checks above pass with empty/expected output
- Summary file exists, names the ruling with the validity/non-validity direction, and contains no upper-bound claim

## Testing & Validation

- [x] `jq -e` three-field invariant on 713 (`hold` / `not_started` / `2026-10-03`) holds after Phase 1 and again at Phase 3 *(completed)*
- [x] `grep -c 'CANONICAL WORDING OF THE CONSEQUENCE'` on 713's description is exactly 1; `grep -c 'Open sub-item'` on its `hold_reason` is 0 *(completed)*
- [x] No `specs/718_` or `specs/721_` path without `archive/` remains in 713's description *(completed)*
- [x] `grep -rn "2EXPTIME" FormalSystem --include=README.md | grep -vi argued` is empty *(completed)*
- [x] Upper-bound sweep (Phase 3) yields only prohibitions/quotations *(completed)*
- [x] `specs/archive/` and `*.lean` untouched by any commit of this task *(completed)*
- [x] `validate-no-task-references` hook does not fire on any Phase 2 write *(completed)*

## Artifacts & Outputs

- `specs/state.json` - task 713's `description`, `hold_reason`, `last_updated` rewritten; status fields preserved
- `specs/TODO.md` - regenerated rendering of 713
- `FormalSystem/Semantics/Presheaf/README.md`, `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` - qualifier inserted
- `specs/738_pin_complexity_class_divergence_sanity_ceiling/summaries/01_pin-complexity-class-divergence-summary.md` - implementation summary

**file_scope** (already set on this task's record and confirmed at plan time; no change needed): `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md`, `FormalSystem/Semantics/Presheaf/README.md`, `specs/738_pin_complexity_class_divergence_sanity_ceiling/**`, `specs/TODO.md`, `specs/state.json`.

## Rollback/Contingency

- Every phase is a prose/JSON edit committed on its own; reverting is `git revert <phase-commit>` -- never `git reset --hard` on a dirty tree (see `rules/git-workflow.md`). A defensive checkpoint before Phase 1, if wanted, is `bash .claude/scripts/git-snapshot.sh 738 --no-revert`.
- If `state-write.sh` refuses the write (validation failure, mutex timeout), nothing has been written: fix the filter/bindings and retry; do not fall back to a hand-rolled `jq > tmp && mv`.
- If the post-write invariant on `held_at` fails, restore the three hold fields with a second `state-write.sh` call setting `.held_at = "2026-10-03"`, `.prior_status = "not_started"`, `.status = "hold"` on 713, and record the incident via `issue-record.sh`.
- If the Phase 2 write hook fires on a task-number reference, rewrite the parenthetical without it; the qualifier itself needs no citation.
