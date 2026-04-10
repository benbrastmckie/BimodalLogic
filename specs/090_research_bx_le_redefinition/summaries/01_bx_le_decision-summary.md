# Task 90 Implementation Summary

- **Task**: 90 — Research: Option A (redefine bx_le) vs Option B (Henkin closure)
- **Status**: [COMPLETED]
- **Session**: sess_1775852112_866cc4
- **Date**: 2026-04-10
- **Plan**: [01_bx_le_decision-plan.md](../plans/01_bx_le_decision-plan.md)

## Outcome

Decision artifact delivered. Task 92 is unblocked with a concrete,
actionable direction.

**Verdict**: Reject Option A; adopt **Burgess-Xu Until-induction** on the
unchanged `bx_le := g_content ⊆` ordering. Do NOT include a preliminary
`bx_le_linear` lemma — Phase 1 lean-lsp probes proved it non-derivable.

## Phases

| Phase | Status | Artifact |
|-------|--------|----------|
| 1. Diagnostic probe | COMPLETED | inline (see 02) |
| 2. Diagnostic report | COMPLETED | [02_bx_le_linear_diagnostic.md](../reports/02_bx_le_linear_diagnostic.md) |
| 3. Task 92 recommendation | COMPLETED | [03_task92_recommendation.md](../reports/03_task92_recommendation.md) |
| 4. Task 92 description update | COMPLETED | `specs/TODO.md`, `specs/state.json` |

## Key Findings

1. **Global `bx_le_linear` is not derivable from BX7+BX11+BX12.** BX11 is an
   internal formula schema; `bx_le` is a metalogic relation. No finitary
   characteristic formula bridges the two.
2. **Interval linearity inherits the same obstruction.** Having `w ≤ u` and
   `w ≤ v` does not exhibit a shared F-formula in `w.formulas` that BX11
   can decompose.
3. **The existing comment at `Frame.lean:674` is misleading.** The fix is
   not "prove `w ≤ u ∨ u ≤ w`"; the fix is to construct the trajectory
   directly via Burgess-Xu Until-induction so that `w ≤ u` holds by
   construction.
4. **Option A is structurally infeasible** — confirmed by both team research
   and the Phase 1 probe.

## Files Touched

- `specs/090_research_bx_le_redefinition/reports/02_bx_le_linear_diagnostic.md` (new)
- `specs/090_research_bx_le_redefinition/reports/03_task92_recommendation.md` (new)
- `specs/090_research_bx_le_redefinition/summaries/01_bx_le_decision-summary.md` (this file)
- `specs/090_research_bx_le_redefinition/plans/01_bx_le_decision-plan.md` (phase markers)
- `specs/state.json` (task 90 status, task 92 description)
- `specs/TODO.md` (task 90 status, task 92 description)

**No files under `Theories/` were modified.** All Lean interaction was
read-only via `lean-lsp` MCP, per plan Phase 1 constraints.

## Next Steps

Task 92 is now ready for `/research` (optional) or `/plan`. It should use
the Burgess-Xu Until-induction technique described in
`reports/03_task92_recommendation.md`.
