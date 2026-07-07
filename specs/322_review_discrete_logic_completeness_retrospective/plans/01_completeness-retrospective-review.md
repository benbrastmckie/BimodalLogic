# Implementation Plan: Discrete-Logic Completeness Retrospective Review

- **Task**: 322 - review_discrete_logic_completeness_retrospective
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Dependencies**: None (diagnostic/retrospective; consumes artifacts of tasks 006-321)
- **Research Inputs**: reports/01_completeness-retrospective.md (H4-verified, Tier 1)
- **Artifacts**: plans/01_completeness-retrospective-review.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; plan-format-enforcement.md
- **Type**: lean4 (deliverable is markdown; NO Lean code is written by this task)

## Overview

Task 322 converts the H4-verified full-arc research report
(`reports/01_completeness-retrospective.md`) into two polished, standalone deliverables:
(1) a retrospective **review document** diagnosing why discrete-logic completeness (the Kamp
theorem formalization, tasks 006-321) has been so difficult — recurring failure modes,
refuted-device churn, literature-fidelity divergence — and (2) a **streamlining-recommendations
document** with concrete, dispatchable guidance for the remaining attempt (patch-vs-rebuild
decision framing, litmus design gate, churn-instrumentation fix, candidate follow-up task
descriptions ready for `/task` or `/revise`). Definition of done: both documents exist, every
load-bearing claim carries a citation (task artifact, Lean file:line, or Rabinovich anchor)
inherited or spot-verified from the research report, and a final verification pass confirms
citation integrity and zero Lean-tree modifications.

### Research Integration

- `reports/01_completeness-retrospective.md` (integrated, plan v1): sole substantive input.
  Findings F-1 through F-6, Decisions D1-D3, Recommendations 1-7, the Adversarial
  Self-Verification table, and the Appendix era-chronology are the source material for every
  phase. No new evidence-gathering is planned; gaps discovered during drafting are flagged, not
  re-researched (see Postmortem Constraints).

### Preserved Assets

The following work is complete and must not regress:

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| Full-arc research report (H4-verified) | specs/322_review_discrete_logic_completeness_retrospective/reports/01_completeness-retrospective.md | [COMPLETED] | 2026-07-07 |
| F1-F4 verdict records (read-only exhibits) | Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean (:3884, :3957, :5204, :5532) | [COMPLETED] | 2026-07-07 (per report verification table) |
| Task 320/321 alignment-audit conclusions (b3 GO, b1/b2 barred) | specs/320_.../reports/01, task 321 description | [COMPLETED] | 2026-07-07 (per report F-4) |

The Lean tree is entirely out of scope: this task modifies zero `.lean` files. The research
report itself is read-only input — the review document supersedes nothing and overwrites nothing.

### Source-to-Implementation Mapping (H3, Tier 1 — adapted)

This is a literature-backed (Tier 1) task, but its deliverable is a markdown review, not Lean
identifiers; per the H3 graceful-adaptation clause the 5-column lemma table is replaced by a
source-to-section mapping. No new Lean identifiers are produced, so the Lean
Identifier/Type-Signature columns are vacuous by construction.

| Source | Location | Review-document target | Status |
|--------|----------|------------------------|--------|
| Research report F-1 (single recurring obstruction) | reports/01, "F-1" table | Review §"The one obstruction, three costumes" | done (02 §3) |
| Research report F-2/F-3 (failure modes; F1-F4 churn table) | reports/01, "F-2"/"F-3" | Review §"Recurring failure modes" | done (02 §4) |
| Research report F-4 (Divergence Map) | reports/01, "F-4" table | Review §"Literature fidelity vs shortcuts" (table reproduced with citations) | done (02 §5) |
| Research report F-5 (what worked) | reports/01, "F-5" | Review §"What worked and why" | done (02 §6) |
| Research report F-6 + D1-D3 | reports/01, "F-6"/"Decisions" | Review §"Root-cause synthesis" | done (02 §7) |
| Research report Recommendations 1-7 | reports/01, "Recommendations" | Recommendations doc §1-§7 (expanded to dispatchable form) | pending |
| Rabinovich 2014 anchors (Def 3.1, Lemma 3.2(2), Prop 3.5, Prop 4.2, Lemma 5.1/5.3, Cor 5.4) | ~/Projects/Literature/sources/rabinovich_2014/...md:61-157 (per report Appendix) | Cited wherever the review makes a fidelity claim | done (02 §5) |
| Task 320 alignment audit (b3 GO-gate litmus) | specs/320_.../reports/01:23-37 (as cited in report F-4) | Recommendations doc §"Litmus design gate" | pending |

Citation discipline: page/proposition-level anchors are inherited from the research report
verbatim; the review does not weaken any citation to a bare author-year form.

## Postmortem Constraints

Binding rules for all implementation dispatches. These rules are derived from the research
report's own diagnosis of the completeness effort plus hard-mode planning doctrine.

**Do NOT**:
- Write, edit, or delete ANY `.lean` file. This task's deliverables are markdown only; the
  single biggest failure mode of this lineage (report F-2.3, encoding lock-in) must not be
  restarted by a retrospective task "just fixing one small thing" in the Lean tree.
- Re-research the arc. The report consumed ~4 hours of parallel evidence-gathering and passed
  adversarial verification; if a claim seems doubtful during drafting, spot-check the single
  cited file:line (cheap Read/grep) — do not launch new surveys of task directories or git
  history. Read budget per phase: the research report + at most 5 targeted spot-check
  reads/greps.
- Reopen barred routes in the recommendations text. Provider-side pinning (route a), the
  `nvar_transfer`/cross-structure-transfer family, arity-tower descent, and flat-carrier
  `kvE''` iterations are refuted (report Rec 7); the recommendations document must list them
  as CLOSED, never as "options worth revisiting."
- Soften or hedge the report's machine-checked verdicts. F2's refutation
  (`f2_relativized_refutation`) and the Phase-16 NO-GO are checked theorems; the review must
  state them as facts with their citations, not as "the team believed."
- Invent new diagnostic claims without a citation. Every load-bearing sentence in the review
  maps to a report finding, a task artifact path, a Lean file:line, or a Rabinovich md anchor.
  Uncited editorializing is a defect.
- Create follow-up tasks directly (no state.json writes for new tasks). Phase 2 produces
  candidate task DESCRIPTIONS only; task creation is the orchestrator's/user's decision.

**MUST preserve**:
- `reports/01_completeness-retrospective.md` byte-for-byte (input, never edited).
- The entire Lean tree (verify with `git status --porcelain -- Theories/` empty at each phase
  end).
- The report's Contradiction Log resolution (42 vs 113 sorry counts): if the review cites a
  sorry count, it must reproduce the both-correct-at-different-filters resolution, not pick one
  number silently.

**Design decisions are SETTLED** (do not re-open without concrete counterexample):
- D1: The remaining blocker is an architecture-selection problem, not a missing-lemma problem.
- D2: Route b3 (nested F_i-chain / Cor 5.4) is the only literature-consistent route; b1/b2 are
  barred shortcuts.
- D3: The position-by-evaluation-point litmus is applied BEFORE machine-probing, as a GO gate.
- (Report Rec 1, strengthened form): the patch-vs-rebuild decision is presented as
  A-probe-first-with-B-pre-authorized; the recommendations document frames it exactly this way
  rather than re-arguing it.

## Goals & Non-Goals

- **Goals**:
  - A polished, self-contained retrospective review document a future planner can read in one
    sitting without opening the 40+ underlying task directories.
  - A streamlining-recommendations document whose items are directly dispatchable: each one
    states owner, trigger condition, and concrete next action (including 2-4 candidate
    follow-up task descriptions in `/task`-ready prose).
  - Full citation integrity inherited from the H4-verified report.
- **Non-Goals**:
  - No Lean proofs, no Lean edits, no build runs (a `git status` cleanliness check is the only
    interaction with the Lean tree).
  - No new evidence gathering / git archaeology beyond bounded spot-checks.
  - No task creation, no revision of task 320/321 plans (candidate descriptions only).
  - No `.claude/` context-extension edits (report's Context Extension Recommendation is
    surfaced as a candidate task description instead, since context-gap task creation is
    currently disabled).

## Risks & Mitigations

- **Risk**: The review drifts into re-analysis (the lineage's own analysis-paralysis failure
  mode, ironically). **Mitigation**: hard read budget (report + <=5 spot-checks per phase);
  phases produce documents, and each phase's done-criterion is a file existing with required
  sections — analysis-only output is a defect.
- **Risk**: Recommendations too vague to dispatch ("improve churn tracking"). **Mitigation**:
  Phase 2 acceptance requires each recommendation to carry {owner, trigger, concrete action,
  citation}; candidate task descriptions must name target files/scripts (e.g.
  `.orchestrator-churn-state.json` counters, `skill-orchestrate-hard` three-strikes logic).
- **Risk**: Citation rot — the report cites live-tree line numbers that could shift.
  **Mitigation**: Phase 3 spot-verifies the five highest-value anchors (KampPrior.lean:351;
  NfMultiAnchorBridge.lean :3884/:3957/:5204/:5532) with grep and annotates the review with
  "verified 2026-07-07" markers; drift is recorded, not silently corrected.
- **Risk**: Accidental Lean-tree modification. **Mitigation**: postmortem constraint + per-phase
  `git status --porcelain -- Theories/` check in verification criteria.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |

Fully sequential: Phase 2 cross-references the review's section anchors, and Phase 3 verifies
both documents. No parallel opportunities (single-writer, single-deliverable-pair task; H7
territory is trivially the task directory).

### Phase 1: Author the retrospective review document [COMPLETED]

- **Goal:** Synthesize `reports/01_completeness-retrospective.md` into a polished, standalone
  review document at
  `specs/322_review_discrete_logic_completeness_retrospective/reports/02_completeness-retrospective-review.md`.
- **Tasks:**
  - [x] Write the review with this required section skeleton (bounded unit = this one document):
    1. Executive summary (<=1 page: the one-obstruction thesis, the churn diagnosis, the
       fidelity-correlates-with-success signal, the headline recommendation).
    2. Arc overview: three eras (early 006-129, middle 141-301, recent 303-321) with the
       metric-baseline table (commits/plan-versions/terminal-state) reproduced from the report.
    3. The one obstruction, three costumes (report F-1, table reproduced with citations).
    4. Recurring failure modes (report F-2, all six, each with its sharpest cited example) and
       the F1-F4 refuted-device churn table (report F-3).
    5. Literature fidelity vs formalization shortcuts: the Divergence Map (report F-4) with
       Rabinovich md anchors, plus the b1/b2/b3 verdict from task 320.
    6. What worked and why (report F-5: 273/308/310/311-v3 pattern; verdict-record house style
       as preserved practice).
    7. Root-cause synthesis (report F-6) and settled decisions D1-D3.
    8. Sorry-count clarification box (the 42/113/1 contradiction-log resolution, reproduced).
  - [x] Carry every citation through verbatim (task-artifact path, Lean file:line, or
    Rabinovich md:NN anchor); no bare author-year citations for load-bearing claims.
  - [x] End the document with a "Provenance" note: derived from the H4-verified report, with
    its Adversarial Self-Verification confidence levels summarized in 3-5 lines.
  - [x] Confirm `git status --porcelain -- Theories/` is empty (verified 2026-07-07).
- **Estimated output:** ~280 lines (one document; advisory band 100-300).
- **Done when:** `reports/02_completeness-retrospective-review.md` exists, contains all eight
  required sections, every F-1/F-3/F-4 table row carries a citation, and the Lean tree is
  untouched. Bounded-unit check: one fixed document with a fixed section list — no open-ended
  attempt surface.
- **Timing:** ~1.5 hours.
- **Depends on:** none

### Phase 2: Distill dispatchable streamlining recommendations [COMPLETED]

- **Goal:** Expand the report's Recommendations 1-7 into a concrete, dispatch-ready guidance
  document at
  `specs/322_review_discrete_logic_completeness_retrospective/reports/03_streamlining-recommendations.md`,
  including candidate follow-up task descriptions (descriptions only — no task creation).
- **Tasks:**
  - [ ] For each of the report's seven recommendations, write a dispatchable entry with fields:
    {What, Owner, Trigger/Gate, Concrete next action, Citation}. Preserve the report's priority
    order and the strengthened Rec-1 framing (Option A b3-probe first, Option B interval-EA
    rebuild pre-authorized as fallback; ~700-1050 line estimate per 305/reports/37 §4.4).
  - [ ] Write the "Barred routes register" (report Rec 7): route a provider-pinning,
    `nvar_transfer`/cross-structure transfer, arity-tower descent, flat-carrier kvE''
    iterations — each with its refutation citation, marked CLOSED.
  - [ ] Write the "Litmus design gate" as a copy-pasteable checklist block (position-by-
    evaluation-point litmus, arity firewall Lemma 3.2(2), G5 faithfulness-mapping precondition)
    suitable for direct inclusion in a future task-321/309-v8 plan guard set.
  - [ ] Draft 2-4 candidate follow-up task descriptions in `/task`-ready prose, covering at
    least: (a) the patch-vs-rebuild decision memo / b3 minimal probe re-point (report Rec 1+6,
    with the mandatory F4 Z counterexample data reproduced: `M=Z`, `p={0}`, `r={13}`, `x=10`,
    `t=20`, `sigma''=char[14,16,11,20]`); (b) churn-instrumentation fix (report Rec 4: count
    plan versions per leaf + self-refuted intermediates; trip at three; names
    `.orchestrator-churn-state.json` and the three-strikes logic as targets); (c) the
    lean-extension context note capturing the litmus + arity firewall (report Context Extension
    Recommendation). Mark each as CANDIDATE — creation deferred to orchestrator/user.
  - [ ] Cross-reference each entry to the review document's section anchors (Phase 1 output).
  - [ ] Confirm `git status --porcelain -- Theories/` is empty.
- **Estimated output:** ~200 lines (one document; advisory band 100-300).
- **Done when:** `reports/03_streamlining-recommendations.md` exists; all seven recommendations
  have the five required fields; the barred-routes register and litmus checklist are present;
  2-4 candidate task descriptions are marked CANDIDATE; no tasks were created in state.json.
  Bounded-unit check: fixed enumeration (7 recs + 1 register + 1 checklist + <=4 candidates).
- **Timing:** ~1 hour.
- **Depends on:** 1

### Phase 3: Verification pass and wrap-up [NOT STARTED]

- **Goal:** Verify citation integrity and deliverable completeness; write the implementation
  summary.
- **Tasks:**
  - [ ] Spot-verify the five highest-value Lean anchors cited in the review via grep (within
    the <=5 spot-check budget): `KampPrior.lean:351` (live blocker sorry),
    `NfMultiAnchorBridge.lean` F1 :3884, F2 :3957, F3 :5204, F4 :5532. Annotate the review's
    Provenance note with "anchors re-verified 2026-07-07"; if any anchor drifted, record the
    drift in the Provenance note (do not silently renumber).
  - [ ] Structural check of both deliverables: all required sections present (Phase 1's eight;
    Phase 2's four blocks); every table row in F-1/F-3/F-4 reproductions carries a citation;
    no "TODO"/placeholder text remains.
  - [ ] Confirm the two settled-decision guards held: zero `.lean` modifications
    (`git status --porcelain -- Theories/` empty) and zero new tasks in `specs/state.json`.
  - [ ] Write the implementation summary at
    `specs/322_review_discrete_logic_completeness_retrospective/summaries/01_completeness-retrospective-review-summary.md`
    (what was produced, verification results, the CANDIDATE task list for user decision).
- **Estimated output:** ~90 lines (summary + small annotations to the two documents).
- **Done when:** all five anchors checked and annotated; both documents pass the structural
  check; summary file exists; Lean tree and task state confirmed untouched. Bounded-unit check:
  fixed checklist of 5 greps + 2 document scans + 1 summary file.
- **Timing:** ~45 minutes.
- **Depends on:** 1, 2

## Testing & Validation

- [ ] `reports/02_completeness-retrospective-review.md` exists with all eight required sections
  (grep for the eight section headings).
- [ ] `reports/03_streamlining-recommendations.md` exists with 7 recommendation entries, the
  barred-routes register, the litmus checklist, and 2-4 CANDIDATE task descriptions.
- [ ] Citation integrity: no load-bearing table row lacking a `specs/`, `Theories/`, or
  Rabinovich `md:` citation (manual scan in Phase 3).
- [ ] `git status --porcelain -- Theories/` empty after every phase (no Lean changes).
- [ ] `jq '.active_projects | length' specs/state.json` unchanged by this task's implementation
  (no task creation).
- [ ] Summary file exists at `summaries/01_completeness-retrospective-review-summary.md`.

## Artifacts & Outputs

- plans/01_completeness-retrospective-review.md (this file)
- reports/02_completeness-retrospective-review.md (Phase 1 — the retrospective review)
- reports/03_streamlining-recommendations.md (Phase 2 — dispatchable recommendations +
  candidate follow-up task descriptions)
- summaries/01_completeness-retrospective-review-summary.md (Phase 3)

## Rollback/Contingency

- All outputs are new markdown files in the task directory; rollback is `git rm`/revert of
  those files only — nothing else is touched by construction.
- If Phase 1 exceeds its output bound materially (>2x advisory), split at the natural seam:
  1.1 = sections 1-4 (diagnosis), 1.2 = sections 5-8 (fidelity + synthesis); do not expand
  scope instead.
- If a spot-check in Phase 3 finds a materially wrong claim in the research report (beyond
  line-number drift), record it in the review's Provenance note and the summary as a flagged
  discrepancy; do not rewrite the research report and do not launch re-research — escalate to
  the orchestrator via the handoff blockers field.
