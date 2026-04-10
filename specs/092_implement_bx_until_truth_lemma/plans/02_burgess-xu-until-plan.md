# Implementation Plan: Task #92 - Burgess-Xu Until/Since Truth Lemma

- **Task**: 92 - implement_bx_until_truth_lemma
- **Status**: [NOT STARTED]
- **Effort**: 13-23 hours
- **Dependencies**: Task 90 (completed), Task 92 research round 02 (completed)
- **Research Inputs**:
  - specs/092_implement_bx_until_truth_lemma/reports/01_inherited-from-task90.md
  - specs/092_implement_bx_until_truth_lemma/reports/02_team-research.md
  - specs/092_implement_bx_until_truth_lemma/reports/02_teammate-a-findings.md
  - specs/092_implement_bx_until_truth_lemma/reports/02_teammate-b-findings.md
  - specs/092_implement_bx_until_truth_lemma/reports/02_teammate-c-findings.md
  - specs/092_implement_bx_until_truth_lemma/reports/02_teammate-d-findings.md
  - specs/090_research_bx_le_redefinition/reports/03_task92_recommendation.md
- **Artifacts**: plans/02_burgess-xu-until-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
  - .claude/context/formats/status-markers.md
  - .claude/context/workflows/task-breakdown.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the four Until/Since truth-lemma sorries in `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` at lines 653, 675, 690, and 704 using a Burgess-Xu Until-induction approach, holding `bx_le := g_content ⊆ (·)` unchanged. Task 90 research established that Option A (strengthening `bx_le`) is infeasible and that `bx_le_linear` is non-derivable from current axioms, so the proofs must route through BX-axiom-derived witness lemmas rather than frame-level linearity. Because the team research (round 02) identified two unrescued gaps in the headline approach (Gap U5 on BX5 self-accumulation propagation; B-GAP on BX4 backward direction), this plan begins with a mandatory Phase 0 diagnostic gate that must validate (or rescue) each step of the Burgess-Xu kernel before any proof implementation begins. Definition of done: the four sorries are closed with no new sorries or axioms, `lake build` succeeds, `#print axioms bx_completeness` shows no regressions, and helper lemmas live in a new `BXCanonical/UntilHelpers.lean` module.

### Research Integration

The plan integrates the round-02 team synthesis in full:

- **Teammate A** provided tactic-level skeletons at `Frame.lean:653` and `:675` with `[GAP]` markers pinpointing where standard Burgess-Xu steps break under the current axiom set. These skeletons seed the Phase 1/2 proof drafts.
- **Teammate B** catalogued alternative approaches and rejected them; recovered `or_until_imp` at `TemporalDerived.lean:338` as a reusable helper; proposed a two-formula `bx_earliest_until_witness` primitive via `(φ U ψ) ∧ (⊤ U ψ)` as the rescue path (R1) for Gap U5.
- **Teammate C** produced a critical-issues audit, the axiom table, the Phase 0 probe proposals (6 probes), and the Since-mirror asymmetry analysis (Issue 5). The probe list in Phase 0 below is C's proposal verbatim, and C's scope-fence audit confirms task 92 and task 93 are mathematically independent.
- **Teammate D** proposed the module layout (`UntilHelpers.lean`), the quality bar (including comment preservation and a soundness sanity test), the memory-harvest targets, and the "Linearity Gap Narrative" prose block that must be copied into the new module.

### Prior Plan Reference

No prior plan for task 92. Task 90's recommendation report (`specs/090_research_bx_le_redefinition/reports/03_task92_recommendation.md`) is treated as reference only — round-02 research has since identified gaps in that recommendation that this plan addresses with the Phase 0 diagnostic gate.

### Roadmap Alignment

This plan advances the ROAD_MAP.md "Active-Path Sorry Inventory" by retiring four rows (Frame.lean:653, 675, 690, 704). It does NOT advance task 93 (Box modal witness at Frame.lean:440; TaskModel embedding at Completeness.lean:154) — scope fence enforced. Upon completion, the critical-path diagram in ROAD_MAP.md must be updated to reflect the retired sorries and the shifted weight onto task 93.

## Goals & Non-Goals

**Goals**:
- Close `bx_until_eventuality_resolution` (Frame.lean:653)
- Close `bx_until_backward` (Frame.lean:675)
- Close `bx_since_eventuality_resolution` (Frame.lean:690)
- Close `bx_since_backward` (Frame.lean:704)
- Introduce no new `sorry` and no new `axiom` anywhere in the codebase
- Extract Burgess-Xu kernel helpers into a new `BXCanonical/UntilHelpers.lean` module with docstrings
- Preserve and extend existing linearity-gap documentation at Frame.lean:585-622, :647-651, :674
- Update ROAD_MAP.md sorry inventory and critical-path diagram
- Propose memory-vault entries for retrieved discoveries
- Add a light soundness sanity test in `Tests/BimodalTest/` as regression guard

**Non-Goals**:
- Closing `Frame.lean:440` Box modal witness sorry (task 93 scope)
- Closing `Completeness.lean:154` TaskModel embedding sorry (task 93 scope)
- Redefining `bx_le` or proving `bx_le_linear` as a theorem (task 90 verdict: infeasible / non-derivable)
- Adding new BX axioms to the proof system
- Refactoring the module boundary between `Frame.lean` and `Completeness.lean` beyond extracting `UntilHelpers.lean`
- Proving a general soundness theorem (the sanity test is a single-instance smoke test only)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 0 Probes 1 AND 2 both fail (Gap U5 unrescued) | H | M | Stop; `/spawn 92` with blocker description; task 92 → [BLOCKED]. This is a scientifically correct outcome. |
| Phase 0 Probes 3 AND 4 both fail (B-GAP unrescued) | H | M | Stop; `/spawn 92`; task 92 → [BLOCKED]. |
| Since-mirror duals fail despite forward Until succeeding (asymmetry from teammate C Issue 5) | H | M | Phase 3/4 each include a standalone asymmetry audit before adapting forward proofs. If mirror fails, spawn task for Since-specific lemma research. |
| New helper lemma is unprovable without inventing a sorry | H | L | Zero-debt policy: pause and `/spawn 92`; never commit a sorry. |
| `lake build` regressions from new `UntilHelpers.lean` imports | M | L | Phase 5 is isolated restructuring; run `lake build Bimodal.Metalogic.BXCanonical.Frame` incrementally. |
| `#print axioms bx_completeness` reveals unexpected axiom leak | M | L | Phase 6 inspection step; if new axioms appear, halt and diagnose before completion. |
| Soundness sanity test evaluation diverges from canonical truth | M | L | Test is smoke-only; failure indicates real bug and halts completion. |
| Effort overruns the 13-23h envelope | M | M | Phase 0 timebox (≤3h) is a hard gate; early signals of infeasibility trigger `/spawn` rather than indefinite grinding. |
| Comment deletion regresses documentation (teammate C Issue 4) | L | L | Phase 6 checklist item: verify Frame.lean:585-622, :647-651, :674 still present and extended, not replaced. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1, 2 | 0 |
| 3 | 3, 4 | 1, 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel. Phase 0 is a hard gate: no later phase may start until Phase 0 produces an explicit go decision in its diagnostic report.

---

### Phase 0: Diagnostic Gate (Burgess-Xu Probes) [BLOCKED]

**Goal**: Before any proof implementation, run six diagnostic probes to validate (or rescue) each fragile step in the Burgess-Xu kernel. Produce a written decision document that determines whether Phases 1-6 proceed or task 92 goes [BLOCKED] via `/spawn 92`.

**Tasks**:
- [ ] **Probe 1 — BX5 self-accumulation propagation**: At `Frame.lean:653`, use `lean_goal` to capture the exact state, then `lean_multi_attempt` candidates that propagate a BX5 self-accumulation hypothesis along an Until chain. Expected outcome: failure. Record the precise formal statement of Gap U5 (the missing propagation lemma) in the decision document.
- [ ] **Probe 2 — BX7 two-formula earliest-witness rescue (R1 for Gap U5)**: Attempt to construct an earliest-witness via the conjunction `(φ U ψ) ∧ (⊤ U ψ)`, leveraging BX7 linear-Until-local structure. Use `lean_multi_attempt` and `lean_state_search` at `Frame.lean:653` to test whether this formulation closes the gap. Record the candidate helper name (e.g., `bx_earliest_until_witness`) and its statement if rescue succeeds.
- [ ] **Probe 3 — BX4 backward direction**: At `Frame.lean:675`, use `lean_goal` + `lean_multi_attempt` to test whether BX4 directly closes the backward direction. Expected outcome: failure. Record the formal statement of B-GAP.
- [ ] **Probe 4 — BX4' `connect_past` rescue (R4 for B-GAP)**: Apply a `connect_past`-style alternative: instantiate a connectedness axiom at the candidate point `v` with the witness formula `ψ`. Test with `lean_multi_attempt` at `:675`. Record whether rescue succeeds and the candidate helper name (e.g., `bx_not_until_backward_pull`).
- [ ] **Probe 5 — Derived Until-persistence search**: Use `lean_leansearch` and `lean_state_search` to surface any existing Mathlib or project lemma that proves Until-persistence under BX axioms (e.g., in `TemporalDerived.lean`). Record hits and assess whether they collapse Gap U5 or B-GAP.
- [ ] **Probe 6 — BX11 `temp_linearity` role and Since-mirror asymmetry walk**: Inspect BX11's role in the existing proofs and walk the Since-mirror duals under the teammate C Issue 5 asymmetry. Record which Since-specific helpers will need standalone proofs (not mere `.symm`/`.dual` renames of Until helpers).
- [ ] Write decision document at `specs/092_implement_bx_until_truth_lemma/reports/03_phase0-diagnostic.md` recording each probe's verbatim goal state, the attempted tactics, outcomes, and the go/no-go decision.
- [ ] **Escalation gate**: If (Probe 1 fails AND Probe 2 fails) OR (Probe 3 fails AND Probe 4 fails), stop immediately. Invoke `/spawn 92` with blocker description: "BX5 propagation gap and BX4 connectedness disavowal both unrescued in diagnostic Phase 0". Set task 92 status to [BLOCKED]. This is an acceptable and scientifically correct outcome.
- [ ] **Go decision**: If escalation is not triggered, commit the diagnostic report and proceed to Wave 2.

**Timing**: ≤3 hours (hard cap)

**Depends on**: none

**Files to modify**:
- `specs/092_implement_bx_until_truth_lemma/reports/03_phase0-diagnostic.md` — new file; probe outcomes + decision

**Verification**:
- Diagnostic report exists at the path above
- Each of the six probes has a recorded outcome (pass/fail + notes)
- Either a go decision with rescue helper names identified, or a `/spawn 92` invocation with blocker description

---

### Phase 1: Until Forward Eventuality Resolution [NOT STARTED]

**Goal**: Close `bx_until_eventuality_resolution` at `Frame.lean:653` using the rescue helper validated in Phase 0 (Probe 2 outcome).

**Tasks**:
- [ ] Re-read teammate A's skeleton for `:653` and adapt using the Phase 0 rescue helper
- [ ] Draft the forward-propagation helper lemma (name per Phase 0 decision; e.g., `bx_earliest_until_witness` or equivalent) in a scratch buffer, with full docstring describing its Burgess-Xu lineage
- [ ] Prove the helper via `lean_multi_attempt` iteration; use `lean_state_search` / `lean_hammer_premise` when stuck
- [ ] Prove `bx_vacuous_guard_lift` (BX12 F→⊤U) if the forward proof calls for it
- [ ] Use `or_until_imp` from `TemporalDerived.lean:338` where applicable
- [ ] Close the sorry at `Frame.lean:653` by invoking the helper lemmas
- [ ] Run `lean_diagnostic_messages` on Frame.lean; confirm no new errors
- [ ] Run `lake build Bimodal.Metalogic.BXCanonical.Frame` to confirm incremental compile
- [ ] Do NOT yet extract helpers to `UntilHelpers.lean` — they stay inline in Frame.lean until Phase 5

**Timing**: 3-5 hours

**Depends on**: 0

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — close sorry at line 653; add inline helper lemmas above the `bx_until_eventuality_resolution` declaration

**Verification**:
- Sorry at line 653 is removed
- `lean_diagnostic_messages` returns clean for the affected region
- `lake build Bimodal.Metalogic.BXCanonical.Frame` succeeds
- No new `sorry` or `axiom` introduced (check via `lean_verify` or grep)

---

### Phase 2: Until Backward [NOT STARTED]

**Goal**: Close `bx_until_backward` at `Frame.lean:675` using the backward rescue helper from Phase 0 (Probe 4 outcome).

**Tasks**:
- [ ] Re-read teammate A's skeleton for `:675`
- [ ] Draft the backward helper lemma (e.g., `bx_not_until_backward_pull` or the name emerging from Probe 4) with docstring
- [ ] Prove the backward helper via `lean_multi_attempt` / `lean_state_search`
- [ ] Close the sorry at `Frame.lean:675` by invoking helpers
- [ ] Run `lean_diagnostic_messages`; confirm clean
- [ ] Run `lake build` to confirm incremental compile
- [ ] Keep helpers inline until Phase 5

**Timing**: 3-5 hours

**Depends on**: 0

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — close sorry at line 675; add inline backward helpers

**Verification**:
- Sorry at line 675 is removed
- `lean_diagnostic_messages` clean
- `lake build` succeeds
- No new sorry/axiom

**Note**: Phase 2 may run in parallel with Phase 1 after Phase 0; they touch different sorries and different helper lemmas.

---

### Phase 3: Since Forward Eventuality Resolution [NOT STARTED]

**Goal**: Close `bx_since_eventuality_resolution` at `Frame.lean:690` by adapting Phase 1's forward helpers as Since-duals, with an explicit asymmetry audit to catch cases where the dual is not a mere mirror (teammate C Issue 5).

**Tasks**:
- [ ] Asymmetry audit: for each Phase 1 helper, identify whether its Since-dual is (a) a literal `.symm` / time-reversed mirror, or (b) requires a standalone proof due to Since-specific axiom gaps
- [ ] For category (a) helpers: derive duals by mirror rewrite
- [ ] For category (b) helpers: draft and prove standalone Since lemmas with docstrings noting the asymmetry
- [ ] Close the sorry at `Frame.lean:690`
- [ ] Run `lean_diagnostic_messages`; confirm clean
- [ ] Run `lake build`
- [ ] If a category (b) helper cannot be proved, STOP and `/spawn 92` with blocker description citing the specific Since-asymmetry gap

**Timing**: 2-4 hours

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — close sorry at line 690; add inline Since-dual helpers

**Verification**:
- Sorry at line 690 removed
- Asymmetry audit notes recorded in the helper docstrings
- `lean_diagnostic_messages` clean
- `lake build` succeeds
- No new sorry/axiom

---

### Phase 4: Since Backward [NOT STARTED]

**Goal**: Close `bx_since_backward` at `Frame.lean:704` by adapting Phase 2's backward helpers as Since-duals with asymmetry audit.

**Tasks**:
- [ ] Asymmetry audit for Phase 2 backward helpers
- [ ] Derive or standalone-prove Since backward duals
- [ ] Close the sorry at `Frame.lean:704`
- [ ] Run `lean_diagnostic_messages`; confirm clean
- [ ] Run `lake build`
- [ ] Zero-debt escalation if any dual is unprovable

**Timing**: 2-4 hours

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — close sorry at line 704; add inline Since-dual backward helpers

**Verification**:
- Sorry at line 704 removed
- `lean_diagnostic_messages` clean
- `lake build` succeeds
- No new sorry/axiom

**Note**: Phase 4 may run in parallel with Phase 3 after Phases 1 and 2.

---

### Phase 5: Module Restructuring — Extract `UntilHelpers.lean` [NOT STARTED]

**Goal**: Move the Burgess-Xu kernel helpers from their inline locations in `Frame.lean` into a new dedicated module `Theories/Bimodal/Metalogic/BXCanonical/UntilHelpers.lean`, update the aggregator, and verify the build.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/UntilHelpers.lean`
- [ ] At the top of `UntilHelpers.lean`, copy verbatim (or near-verbatim) teammate D's "Linearity Gap Narrative" prose block as a module docstring / section comment
- [ ] Move the following helpers from `Frame.lean` into `UntilHelpers.lean`, preserving docstrings:
  - `bx_vacuous_guard_lift` (BX12 F→⊤U)
  - `bx_earliest_until_witness` (or the equivalent from Phase 0 Probe 2 outcome)
  - The Phase 1 forward propagation helper
  - `bx_not_until_backward_pull` (or Phase 2 equivalent)
  - All Since-duals from Phases 3 and 4
- [ ] Add the necessary `import Theories.Bimodal.ProofSystem…` prologue to `UntilHelpers.lean`
- [ ] Update `Theories/Bimodal/Metalogic/BXCanonical.lean` aggregator to import `UntilHelpers`
- [ ] Update `Frame.lean` to import `UntilHelpers` and remove the now-moved helper definitions
- [ ] Run `lake build Bimodal.Metalogic.BXCanonical.Frame`; fix any import ordering issues
- [ ] Run full `lake build`; confirm no downstream breakage
- [ ] Verify `lean_diagnostic_messages` clean on both `Frame.lean` and `UntilHelpers.lean`

**Timing**: 1-2 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/UntilHelpers.lean` — new file
- `Theories/Bimodal/Metalogic/BXCanonical.lean` — add import
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — remove moved helpers, add import

**Verification**:
- `UntilHelpers.lean` exists and contains the Linearity Gap Narrative prose block
- `lake build` succeeds for the full project
- No new sorry/axiom
- `lean_file_outline` on `UntilHelpers.lean` shows all expected helpers

---

### Phase 6: Documentation, Memory Harvest, Sanity Test, Axiom Inspection [NOT STARTED]

**Goal**: Update `ROAD_MAP.md`, preserve and extend in-file documentation, add the light soundness sanity test, propose memory-vault entries, and verify no axiom regressions.

**Tasks**:
- [ ] **ROAD_MAP.md update**: In the "Active-Path Sorry Inventory" section, remove the four rows corresponding to `Frame.lean:653`, `:675`, `:690`, `:704`. Update the critical-path diagram to reflect the remaining task-93 sorries.
- [ ] **In-file documentation preservation**: Verify that `Frame.lean:585-622` module docstring, `:647-651`, and `:674` linearity-gap comments are still present and not deleted. Extend them with a new subsection titled "Task 92 resolution: Burgess-Xu substitute" that cites `BXCanonical/UntilHelpers.lean` and cross-references the Linearity Gap Narrative prose block.
- [ ] **Soundness sanity test**: Add a test file in `Tests/BimodalTest/` that evaluates a concrete small-instance derivation (e.g., `φ U ψ → F ψ`) at a small canonical frame and checks the canonical-model truth evaluation. This is a single-instance smoke test, not a general soundness proof. Run the test via `lake build` or the project's test harness and confirm it passes.
- [ ] **Axiom inspection**: Run `lean_verify Bimodal.Metalogic.BXCanonical.Frame.bx_completeness` (or equivalent via `#print axioms bx_completeness` through `lean_run_code`). Compare the axiom list to the pre-task-92 baseline. If any new axioms appear, halt and diagnose before marking the task complete.
- [ ] **Memory harvest proposals**: Draft suggestions (do not execute) for `/learn --task 92` to create these memory entries after task completion:
  - `bx_le-is-g-content-subset-intentionally.md` (why task 90 Option A is infeasible)
  - `until-via-burgess-xu-not-linearity.md` (the proof strategy)
  - `bx7-linear-until-is-local.md` (the BX7 insight)
  - Optional: `bxcanonical-file-layout.md` (the new module structure)
- [ ] Record the memory harvest proposals in the task completion summary (state.json `completion_summary` field) or in a `summaries/` artifact

**Timing**: 2-3 hours

**Depends on**: 5

**Files to modify**:
- `specs/ROAD_MAP.md` — update Active-Path Sorry Inventory and critical-path diagram
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — extend (do not delete) documentation at lines 585-622, 647-651, 674
- `Tests/BimodalTest/{test-file-name}.lean` — new file; soundness sanity smoke test
- `specs/092_implement_bx_until_truth_lemma/summaries/01_completion-summary.md` — optional completion summary with memory harvest proposals

**Verification**:
- ROAD_MAP.md no longer lists the four retired sorries
- Frame.lean documentation at :585-622, :647-651, :674 is present and extended, not replaced
- Sanity test passes under `lake build`
- `lean_verify` / `#print axioms` shows no new axioms compared to baseline
- Memory harvest proposals recorded
- No new sorry/axiom anywhere

---

## Testing & Validation

- [ ] Phase 0 diagnostic report produced with explicit go/no-go decision
- [ ] `lake build` succeeds at the end of each of Phases 1, 2, 3, 4, 5, 6
- [ ] `lean_diagnostic_messages` clean on `Frame.lean` and `UntilHelpers.lean` after each phase
- [ ] `lean_verify` on `bx_completeness` (or equivalent `#print axioms` inspection) shows no new axioms compared to pre-task-92 baseline
- [ ] No `sorry` or new `axiom` introduced anywhere in the repository (verify via grep / `lean_verify`)
- [ ] Soundness sanity test in `Tests/BimodalTest/` passes
- [ ] `Frame.lean:585-622`, `:647-651`, `:674` documentation preserved and extended
- [ ] ROAD_MAP.md "Active-Path Sorry Inventory" updated
- [ ] Scope fence honored: `Frame.lean:440` and `Completeness.lean:154` remain untouched (still `sorry`, reserved for task 93)

## Artifacts & Outputs

- `specs/092_implement_bx_until_truth_lemma/reports/03_phase0-diagnostic.md` — Phase 0 probe results and go/no-go decision
- `Theories/Bimodal/Metalogic/BXCanonical/UntilHelpers.lean` — new module with Burgess-Xu kernel helpers and Linearity Gap Narrative prose block
- `Theories/Bimodal/Metalogic/BXCanonical.lean` — updated aggregator import list
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — four sorries closed; documentation extended; moved helpers removed
- `Tests/BimodalTest/{test-file}.lean` — soundness sanity smoke test
- `specs/ROAD_MAP.md` — Active-Path Sorry Inventory and critical-path diagram updated
- `specs/092_implement_bx_until_truth_lemma/summaries/01_completion-summary.md` — completion summary with memory harvest proposals (optional)

## Rollback/Contingency

If any phase cannot be completed without introducing a sorry or axiom:

1. **Zero-debt policy**: Do NOT commit a sorry as a placeholder.
2. **Phase 0 escalation**: If the diagnostic gate fails (Probes 1 AND 2 fail, OR Probes 3 AND 4 fail), invoke `/spawn 92` with blocker description "BX5 propagation gap and BX4 connectedness disavowal both unrescued in diagnostic Phase 0". Set task 92 to [BLOCKED].
3. **Phase 1-4 escalation**: If a helper lemma is unprovable despite Phase 0 indicating it should be reachable, revert the in-progress changes (`git checkout Theories/Bimodal/Metalogic/BXCanonical/Frame.lean`), mark the task [PARTIAL], and `/spawn 92` with the specific unprovable helper as the blocker.
4. **Phase 5 build failure**: If module restructuring breaks the build, revert `UntilHelpers.lean` and the aggregator changes; keep helpers inline in `Frame.lean` and document the deferral in the summary. The four sorries remain closed — only the refactor is rolled back.
5. **Phase 6 axiom regression**: If `#print axioms` shows a new axiom leak, halt completion. Diagnose which helper introduced the leak (binary search via `lean_verify`), fix or revert that helper, and re-run Phase 1-4 verifications.
6. **Phase 6 sanity test failure**: Treat as a real bug — halt completion, investigate, and do not mark the task complete until the test passes.

Task 92 and task 93 are mathematically independent per teammate C's scope-fence audit, so a task 92 rollback does not block task 93 from proceeding.
