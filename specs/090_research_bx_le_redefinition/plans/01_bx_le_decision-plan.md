# Implementation Plan: Task 90 — bx_le Redefinition Decision Artifact

- **Task**: 90 - Research bx_le redefinition decision
- **Status**: [COMPLETED]
- **Effort**: 3-4 hours
- **Dependencies**: None (team research complete)
- **Research Inputs**: specs/090_research_bx_le_redefinition/reports/01_team-research.md
- **Artifacts**: plans/01_bx_le_decision-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Task 90 is a research task whose team-research phase has produced a clear verdict: reject Option A (redefine `bx_le`), adopt Option B reframed as Burgess-Xu Until-induction on the existing `bx_le := g_content ⊆` ordering, but gate task 92 on a cheap diagnostic that probes whether `bx_le_linear` (or interval linearity) is directly derivable from BX7+BX11+BX12. This plan is a decision-artifact plan (not a Lean implementation plan): it executes the diagnostic via read-only lean-lsp MCP probes, documents findings, and produces a concrete recommendation artifact that feeds task 92. No Lean source files are edited.

### Research Integration

The `01_team-research.md` synthesis establishes three inputs this plan operationalizes:
1. BX11 (`temp_linearity`, Axioms.lean:240-244) and BX12 (`F_until_equiv`, Axioms.lean:258-263) are present — prior tasks 86/88/89 operated under an incorrect axiom inventory, so the BX7+BX11+BX12 combination for interval linearity has never actually been attempted.
2. Option A is structurally infeasible (non-equivalence with `g_content ⊆` + transitivity failure, 9-theorem cascade). Not investigated further here.
3. The highest-ROI next step is a 2-4h lean-lsp probe of `bx_le_linear` / interval linearity, which dominates both Options A and B on expected value.

### Prior Plan Reference

No prior plan. This is round 1 for task 90.

### Roadmap Alignment

Advances ROAD_MAP.md items related to closing the 4 Until/Since truth-lemma sorries at `BXCanonical/Frame.lean:653, 675, 690, 704` (assigned to task 92). Specifically, produces the decision input that the ROAD_MAP "Burgess-Xu Until-Induction Technique" section expects task 92 to branch on. Does not address sorries at `Frame.lean:440` (task 93, Box direction) or `Completeness.lean:154` (task 93, TaskModel embedding).

## Goals & Non-Goals

**Goals**:
- Probe whether `bx_le_linear : ∀ w v : BXPoint, bx_le w v ∨ bx_le v w` is derivable from BX7 + BX11 + BX12 using lean-lsp MCP tools, without editing any Lean source files.
- If global linearity is not immediate, probe the weaker `bx_le_interval_linear` variant that the 4 sorries actually need.
- Record the probe outcome (success / partial-with-identified-blocker / fundamental failure) in a reproducible diagnostic report.
- Produce a concrete, actionable decision document that maps probe outcome → direction for task 92 (direct proof vs Burgess-Xu induction vs escalation).
- Optionally update task 92's description in TODO.md / state.json to reflect the chosen approach.

**Non-Goals**:
- Editing any files under `Theories/Bimodal/`. All Lean interaction is read-only via lean-lsp MCP.
- Closing any of the 4 Frame.lean sorries (that is task 92's scope).
- Re-litigating Option A (research already rejects it; no further investigation).
- Addressing Frame.lean:440 or Completeness.lean:154 (task 93 scope).
- Implementing the Burgess-Xu Until-induction proof itself (task 92 scope).
- Modifying ROAD_MAP.md (read-only consultation per rules).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| lean-lsp probes are inconclusive (neither proves nor disproves linearity within the time budget) | M | M | Record intermediate goal states and identified sub-lemmas; recommendation defaults to Burgess-Xu induction path with the probe's stuck point as task 92's focal sub-goal. |
| Accidental file edits via lean-lsp tools | H | L | Only use read-only probes (`lean_goal`, `lean_multi_attempt`, `lean_hammer_premise`, `lean_state_search`, `lean_hover_info`, `lean_local_search`). Never use `lean_run_code` with mutations; never use Edit/Write on `Theories/**`. |
| Probe surfaces a provable non-linearity (formal countermodel) | M | L | Document it carefully — this would reject Option B as stated and escalate to /spawn for task 94 (quasimodels/Hintikka pivot). Captured as a third branch in the decision document. |
| Task 92 description drift — Phase 4 updates TODO but state.json not kept in sync | M | L | Follow the two-phase update pattern (state.json first, then TODO.md), per state-management.md. Phase 4 is explicitly optional and skipped if any doubt. |
| MCP rate limits on search tools (3/30s for leansearch/loogle/state_search/hammer_premise) | L | M | Batch probes; prefer `lean_local_search` and `lean_multi_attempt` first; use rate-limited tools only for specific lemma lookups. |
| Diagnostic takes longer than 2h and starves Phase 2/3 | M | M | Hard time-box Phase 1 to 2h. If no definitive verdict, record "inconclusive within budget" and proceed to Phase 2 — the inconclusive outcome is itself a valid input for Phase 3's decision branches. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Diagnostic — bx_le_linear probe [COMPLETED]

**Goal**: Determine via read-only lean-lsp probes whether `bx_le_linear` (or the weaker `bx_le_interval_linear`) is derivable from BX7 + BX11 + BX12 in the current axiom inventory. Record a definitive outcome (success / partial / blocked / inconclusive) with enough detail to guide task 92.

**Tasks**:
- [ ] Use `lean_file_outline` on `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` to orient on `bx_le` (lines 61-62), `bx_forward_witness` (line 164), and the 4 sorry sites (lines 653, 675, 690, 704).
- [ ] Use `lean_hover_info` on BX7 (Axioms.lean:180), BX11 (Axioms.lean:240-244), `temp_linearity_past` (249-253), BX12 (258-263) to capture exact statements.
- [ ] Open a scratch proof position via `lean_goal` / `lean_multi_attempt` at an existing `sorry` site in Frame.lean to obtain a working proof context with BXPoint in scope.
- [ ] Attempt `bx_le_linear` formulation via `lean_multi_attempt` with tactic candidates: direct application of BX11, `by_contra` + BX4, `rcases temp_linearity` branches. Record each attempt's goal-after.
- [ ] If global linearity stalls, pivot to `bx_le_interval_linear` (weaker, target-relevant) and repeat the probe.
- [ ] Use `lean_hammer_premise` (rate-limited, use 1-2 calls) on the most promising stuck goal to surface candidate closing lemmas.
- [ ] Use `lean_state_search` on the stuck goal for mathlib-side lemma suggestions.
- [ ] Classify outcome into one of: (a) Success — linearity proved and tactic recorded; (b) Partial — stuck on a specific identifiable sub-lemma; (c) Blocked — no plausible path with current axioms; (d) Inconclusive — time-box exhausted, record intermediate states.
- [ ] Capture all goal states, attempted tactics, and outputs in a working notes buffer for Phase 2 to formalize.

**Timing**: 1.5-2 hours (hard cap 2h).

**Depends on**: none

**Files to modify**:
- None. This phase is strictly read-only. All Lean interaction is via `mcp__lean-lsp__*` tools.

**Verification**:
- No changes to any file under `Theories/`.
- A classified outcome (a/b/c/d) is chosen and supported by at least 3 recorded probe attempts.
- At least one goal state (in Lean's infoview format) is captured verbatim for Phase 2's report.

---

### Phase 2: Document diagnostic findings [COMPLETED]

**Goal**: Write a short, reproducible diagnostic report capturing Phase 1's probes, outcomes, and evidence so that task 92 (and any future revisitor) can reconstruct the reasoning without re-running the probes.

**Tasks**:
- [ ] Create `specs/090_research_bx_le_redefinition/reports/02_bx_le_linear_diagnostic.md`.
- [ ] Section 1 — Context: one paragraph linking back to `01_team-research.md` and stating the diagnostic question.
- [ ] Section 2 — Axiom inventory snapshot: cite BX7/BX11/BX12 with line numbers and exact statements from `lean_hover_info`.
- [ ] Section 3 — Probe log: chronological list of attempted formulations and tactics (at least 3), each with the goal state before and after.
- [ ] Section 4 — Outcome classification: declare (a) / (b) / (c) / (d) and justify with evidence from Section 3.
- [ ] Section 5 — Identified obstructions or unlocks: if partial, name the exact stuck sub-lemma; if success, name the closing tactic.
- [ ] Section 6 — Implications for task 92: short mapping of outcome to the decision branches that Phase 3 will elaborate.

**Timing**: 30 minutes.

**Depends on**: 1

**Files to modify**:
- `specs/090_research_bx_le_redefinition/reports/02_bx_le_linear_diagnostic.md` — new file.

**Verification**:
- File exists and has all 6 sections.
- Outcome classification is one of a/b/c/d.
- At least 3 probe entries in Section 3.

---

### Phase 3: Produce decision artifact for task 92 [COMPLETED]

**Goal**: Synthesize the team research recommendation and Phase 2's diagnostic outcome into a single concrete recommendation document that tells task 92 exactly which path to take, with success criteria, the canonical name to use, and the scope boundaries.

**Tasks**:
- [ ] Create `specs/090_research_bx_le_redefinition/reports/03_task92_recommendation.md`.
- [ ] Record the final verdict: **reject Option A; adopt Burgess-Xu Until-induction on unchanged `bx_le := g_content ⊆`**, with outcome-specific refinements.
- [ ] Branch A (diagnostic outcome = success): task 92 reduces to a direct proof using the tactic recorded in `02_bx_le_linear_diagnostic.md`; estimated 4-8h; bypasses the full Burgess-Xu sketch.
- [ ] Branch B (diagnostic outcome = partial with identified blocker): task 92 focuses first on the stuck sub-lemma, then completes the ROAD_MAP "Burgess-Xu Until-Induction Technique" 8-step sketch; estimated 8-16h.
- [ ] Branch C (diagnostic outcome = blocked / fundamental failure, e.g. formal countermodel surfaced): task 92 is not viable as currently scoped — recommend `/spawn 92` to create task 94 (quasimodel / Hintikka pivot) and mark task 92 as [BLOCKED]; escalation checklist included.
- [ ] Branch D (diagnostic outcome = inconclusive within time budget): default to Branch B with the caveat that the first step of task 92 is to re-run the probe at greater depth before committing to the full induction.
- [ ] Name discipline: instruct task 92 to use "Burgess-Xu Until-induction" (not "Henkin closure") in all artifacts; cite the terminology confusion in the research synthesis.
- [ ] Scope fencing: explicit non-goals list stating the plan does NOT close `Frame.lean:440` (task 93) or `Completeness.lean:154` (task 93); closing the 4 sorries ≠ `bx_completeness`.
- [ ] Cross-references: link to `01_team-research.md`, `02_bx_le_linear_diagnostic.md`, and the relevant ROAD_MAP.md section.

**Timing**: 1 hour.

**Depends on**: 2

**Files to modify**:
- `specs/090_research_bx_le_redefinition/reports/03_task92_recommendation.md` — new file.

**Verification**:
- File exists and contains all four branches (A/B/C/D), with the active branch clearly marked based on Phase 2's outcome.
- Canonical name "Burgess-Xu Until-induction" appears at least once.
- Scope fence listing task 93 sorries is present.
- Cross-reference links to the two prior reports and ROAD_MAP.md are present.

---

### Phase 4: Update task 92 description (optional) [COMPLETED]

**Goal**: Reflect the chosen approach and any scope adjustments in task 92's public description in TODO.md and state.json so the next `/research` or `/plan` invocation on task 92 loads the right mental model. Skipped if any ambiguity exists about the update.

**Tasks**:
- [ ] Locate task 92 entry in `specs/TODO.md` and in `specs/state.json`.
- [ ] Draft a short description update (1-3 sentences) referencing the Burgess-Xu Until-induction approach and linking to `reports/03_task92_recommendation.md`.
- [ ] Apply two-phase update: write `state.json` first (machine state), then `TODO.md` (user-facing).
- [ ] Verify task 92's status marker is unchanged (still [NOT STARTED] or whatever it was) — this phase only edits description, not status.
- [ ] If any inconsistency is detected between TODO.md and state.json for task 92, skip the update and note it in `03_task92_recommendation.md` as a follow-up for the orchestrator.

**Timing**: 15 minutes.

**Depends on**: 3

**Files to modify**:
- `specs/state.json` — task 92 description field.
- `specs/TODO.md` — task 92 entry description line.

**Verification**:
- `state.json` and `TODO.md` both reflect the updated description for task 92, or both are unchanged (no partial update).
- Task 92 status unchanged.
- No other tasks affected.

## Testing & Validation

- [ ] No files under `Theories/Bimodal/` were modified during Phase 1 (verify via `git status`).
- [ ] `reports/02_bx_le_linear_diagnostic.md` exists with all 6 sections and an explicit outcome classification.
- [ ] `reports/03_task92_recommendation.md` exists with the four branches and cross-references.
- [ ] Outcome in `03_task92_recommendation.md` matches classification in `02_bx_le_linear_diagnostic.md`.
- [ ] If Phase 4 executed: `state.json` and `TODO.md` are in sync for task 92.
- [ ] Plan metadata (`.return-meta.json`) status transitions from `in_progress` → `planned` with all artifacts listed.

## Artifacts & Outputs

- `specs/090_research_bx_le_redefinition/plans/01_bx_le_decision-plan.md` — this plan (Phase 0 output).
- `specs/090_research_bx_le_redefinition/reports/02_bx_le_linear_diagnostic.md` — Phase 2 output: diagnostic findings report.
- `specs/090_research_bx_le_redefinition/reports/03_task92_recommendation.md` — Phase 3 output: decision artifact for task 92.
- Optional: updates to `specs/TODO.md` and `specs/state.json` (Phase 4, task 92 description only).

## Rollback/Contingency

- Phase 1 is read-only; no rollback is possible or necessary.
- Phase 2 and Phase 3 produce new files only; rollback = delete the created report files.
- Phase 4 rollback: revert the two-phase update. Because Phase 4 only edits task 92's description field (not its status, not other tasks), a `git checkout -- specs/TODO.md specs/state.json` fully restores prior state. If Phase 4 is skipped due to detected inconsistency, no rollback is needed.
- If the diagnostic surfaces a provable non-linearity (Branch C), the contingency is to invoke `/spawn 92` with the countermodel as the blocker description, rather than modifying task 90's plan.
