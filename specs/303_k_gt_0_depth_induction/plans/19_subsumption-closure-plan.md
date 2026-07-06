# Implementation Plan: Task 303 Subsumption Closure

- **Task**: 303 - k_gt_0_depth_induction
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: 305 (hard entry gate — see Phase 1)
- **Research Inputs**: reports/10_blocker-resolution-path.md (authoritative, H4-verified)
- **Artifacts**: plans/19_subsumption-closure-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/plan-format-enforcement.md
- **Type**: lean4

## Overview

Task 303's original goal — closing the six `PriorComposition.lean` zone-3 sorries via NF-based
cross-structure witness transfer — is **moot**. Report 10 established (with H4 adversarial
verification) that task 305's Phase 0 archived `PriorComposition.lean` wholesale to
`Theories/Bimodal/Boneyard/KampBypassArchive/` (commits `3413d0292`, `32b4fae37`); nothing live
imports the archive, and `completeness_discrete` now routes through `KampPrior.lean`, whose only
live sorries (`:391`, `:394`) are task 305's territory (305 plan v37 Phases 5-6). Task 303 is
therefore **subsumed by task 305** and needs **zero Lean proof dispatches**. This is a short,
gated **cleanup/closure** plan — NOT a proof plan. Definition of done: once task 305 clears
`KampPrior:391/:394` (entry gate), delete the three retired Boneyard files, confirm `lake build`
is GREEN with no regression, confirm no live reference to the deleted declarations, and record the
closure note.

### Preserved Assets

The following work is complete and must not regress. Task 303 owns **no** live declaration; its
architecture was already retired by task 305 Phase 0.

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| PriorComposition archival (task 305 Phase 0) | Theories/Bimodal/Boneyard/KampBypassArchive/ | [COMPLETED] (by 305, commits 3413d0292 / 32b4fae37) | 2026-07-05 (report 10 §Adversarial) |
| Live Kamp/Prior route via KampPrior.lean | Theories/Bimodal/Kamp/KampPrior.lean | [COMPLETED] (owned by 305) | 2026-07-05 |
| Forward NF infra (ExistsForallNF, NfToVecEA, NfDepth0Generalized) | Theories/Bimodal/Kamp/ | [COMPLETED], sorry-free, live | 2026-07-05 (report 10 Retired-vs-Kept table) |

### Source-to-Implementation Mapping

| Load-bearing decision | Source | Action in this plan |
|-----------------------|--------|---------------------|
| The six 303 sorries are off the live path | report 10 §Reverse-Dependency Analysis + §Adversarial (VERIFIED) | Phase 1 deletes their archived host files |
| Deletion targets are exactly 3 files | report 10 lines 125-128 (Optional cleanup dispatch) | Phase 1 deletes only those 3 |
| Deletion is gated on 305 clearing KampPrior:391/:394 | report 10 §Concrete Next-Dispatch (Optional cleanup "only after 305 Phase 5/6 is GREEN") | Phase 1 entry gate |
| No cross-structure/nvar_transfer proof work | report 10 §Why not (b), reports 09/20, 305 report 37 audit | Postmortem Constraints (prohibited) |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from 10+ failed patch dispatches on the
303 cross-structure-transfer line and the H4-verified findings of report 10.

**Do NOT**:
- Do NOT attempt any `nvar_transfer` / `nvar_transfer_from_1var_agree` /
  `prior_nonconstenv_2var_agree_until/since` / cross-structure-witness-transfer / zone-3 proof
  work. That architecture is **refuted, not merely stuck** — two independent audits converge
  (report 20 §5.2: wrong abstraction after 10+ dispatches; 305 Phase 4: the per-model existential
  shape `∃ v, v.holds env ↔ eval φ` is vacuous, closable by `tt`/`ff` for any φ). Re-opening this
  line is prohibited.
- Do NOT resurrect, un-archive, edit, or re-prove any declaration in
  `Boneyard/KampBypassArchive/`. The archive is dead code; the only permitted operation on it is
  deletion of the three named files (Phase 1).
- Do NOT touch `KampPrior.lean:391/:394` or any 305-owned file. Those sorries are task 305's
  territory (305 plan v37 Phases 5-6), not 303's.
- Do NOT introduce any new `sorry`, new proof obligation, or new definition. This plan produces
  only deletions and a closure note (net 0 new proof obligations).
- Do NOT delete Boneyard files beyond the three named ones, and do NOT delete anything if the
  entry gate is unsatisfied.

**MUST preserve**:
- The live `completeness_discrete` route through `KampPrior.lean` and all sorry-free forward NF
  infra listed in Preserved Assets.
- A GREEN `lake build` (~1700 jobs) — the deletion must cause zero regression.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- Resolution is **(a) SUBSUMPTION** — 303 has no independent live sorry to close. Options (b)
  direct fix and (c) corrected target were refuted / reassigned to 305 in report 10 (§Why not (b),
  §Why not (c)). Do not re-litigate.

## Goals & Non-Goals

- **Goals**:
  - Gate all work on task 305 clearing `KampPrior:391/:394` (build GREEN).
  - Delete the three retired Boneyard files that hosted the 303 architecture.
  - Confirm `lake build` GREEN with no regression and no live reference to deleted declarations.
  - Record the subsumption closure note in the task summary.
- **Non-Goals**:
  - No Lean proof work of any kind (0 new proof obligations).
  - No changes to any live module or to task 305's files.
  - No deletion of Boneyard files other than the three named ones.

## Risks & Mitigations

- **Risk**: Entry gate misjudged — implementer starts deletion while 305 is still blocked.
  **Mitigation**: Phase 1 opens with an explicit, checkable entry gate; on failure the implementer
  exits immediately with `blocked-on-dependency`, no work attempted.
- **Risk**: A live module secretly references a deleted declaration, breaking the build.
  **Mitigation**: Phase 1 runs a pre-deletion grep for live references to the three files'
  declarations, and a post-deletion `lake build`. Report 10 already verified zero live imports of
  Boneyard; this re-checks at dispatch time.
- **Risk**: Scope creep back into refuted proof work. **Mitigation**: Postmortem Constraints
  forbid it explicitly; this plan is deletions + a note only.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases are sequential (Phase 2 depends on Phase 1's GREEN build).

### Phase 1: Entry-Gate Verification + Boneyard Deletion + GREEN Build [NOT STARTED]

- **Goal:** Behind a hard entry gate, delete the three retired Boneyard files and confirm the
  build stays GREEN with no live reference to the deleted declarations.
- **ENTRY GATE (check FIRST, before any other action):** Task 305 status = `completed` in
  `specs/state.json` **OR** `KampPrior.lean:391` and `KampPrior.lean:394` are cleared
  (`grep -n sorry Theories/Bimodal/Kamp/KampPrior.lean` shows neither line) **AND** `lake build`
  is GREEN. If the gate is **not** satisfied, the implementer MUST exit immediately with status
  `blocked-on-dependency`, attempt no deletion, and write no files. This is a hard stop, not a
  best-effort proceed.
- **Tasks:**
  - [ ] Evaluate the entry gate (query `state.json` for task 305 status; `grep -n sorry` on
    `KampPrior.lean`). If unsatisfied, exit `blocked-on-dependency` now.
  - [ ] Pre-deletion reference check: `grep -rn "PriorComposition\|KampBypassK1" Theories/Bimodal/
    --include=*.lean | grep -v "/Boneyard/"` returns empty (no live consumer).
  - [ ] Delete the three retired files:
    `Theories/Bimodal/Boneyard/KampBypassArchive/PriorComposition.lean`,
    `Theories/Bimodal/Boneyard/KampBypassArchive/PriorComposition_old.lean`,
    `Theories/Bimodal/Boneyard/KampBypassArchive/KampBypassK1.lean`.
  - [ ] Run `lake build`; confirm GREEN (~1700 jobs, no new errors/sorries introduced by the
    deletion).
  - [ ] Confirm post-deletion that no live file references the deleted declarations
    (`nvar_transfer_from_1var_agree`, `prior_nonconstenv_2var_agree_until/since`).
- **Timing:** ~30 minutes (gate check + deletion + build).
- **Depends on:** none (but blocked by the entry gate on task 305).
- **Done when:** the three files are deleted, `lake build` is GREEN, and grep confirms zero live
  references — OR the phase exited early with `blocked-on-dependency` (gate unsatisfied).
- **Estimated output:** ~0 lines added, 3 files deleted (~50 KB removed). Net 0 proof obligations.

### Phase 2: Subsumption Closure Note [NOT STARTED]

- **Goal:** Record the subsumption closure in the task summary so the terminal state is
  auditable.
- **Tasks:**
  - [ ] Write `specs/303_k_gt_0_depth_induction/summaries/19_subsumption-closure-summary.md`
    stating: 303 subsumed by 305 (resolution (a)); the three Boneyard files deleted; `lake build`
    GREEN; no live references remained; 0 Lean proof dispatches performed. Cite report 10 and the
    305 Phase 0 archival commits (`3413d0292`, `32b4fae37`).
  - [ ] Note that live `completeness_discrete` continues to route through `KampPrior.lean`
    (305 territory) unchanged.
- **Timing:** ~15 minutes.
- **Depends on:** 1
- **Done when:** the closure summary exists and records the deletion + GREEN build + subsumption
  rationale.
- **Estimated output:** ~40-60 lines (summary markdown). 0 code.

## Testing & Validation

- [ ] `lake build` GREEN after deletion (~1700 jobs, no new errors or sorries).
- [ ] `grep -rn "PriorComposition\|KampBypassK1" Theories/Bimodal/ --include=*.lean | grep -v
  "/Boneyard/"` returns empty.
- [ ] `grep -rn "import.*Boneyard" Theories/Bimodal/ --include=*.lean | grep -v "/Boneyard/"`
  returns empty (archive still imported by nothing live).
- [ ] Task 305 gate condition was verified satisfied before any deletion occurred.

## Artifacts & Outputs

- plans/19_subsumption-closure-plan.md (this file)
- summaries/19_subsumption-closure-summary.md (Phase 2)
- Deletions: Theories/Bimodal/Boneyard/KampBypassArchive/{PriorComposition.lean,
  PriorComposition_old.lean, KampBypassK1.lean}

## Rollback/Contingency

- The deletions are recoverable from git history (`git checkout <sha> -- <path>`) if a regression
  is ever discovered. Because report 10 verified zero live consumers, regression risk is minimal.
- If the entry gate is unsatisfied at dispatch time, no changes are made — the task simply remains
  blocked on 305, and this plan is re-dispatched after 305 completes. No rollback needed.
