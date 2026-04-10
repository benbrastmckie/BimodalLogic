# Research Report: Burgess-Xu Until-Induction (Inherited from Task 90)

- **Task**: 92 — Implement Burgess-Xu Until/Since truth lemma in `BXCanonical/Frame.lean`
- **Type**: Inherited research (no new investigation; all findings come from task 90)
- **Date**: 2026-04-10
- **Source**: Task 90 decision artifacts
- **Status**: Complete — task 92 is ready for `/plan 92`

## Inheritance

Task 92's research phase is satisfied by task 90's decision artifacts.
Task 90 investigated "Option A (redefine `bx_le`) vs Option B
(Henkin-closure enrichment)", concluded with a decisive verdict, and
produced an explicit recommendation document for task 92. No further
investigation is required before planning.

## Source Artifacts (Task 90)

| File | Purpose |
|------|---------|
| [../../090_research_bx_le_redefinition/reports/01_team-research.md](../../090_research_bx_le_redefinition/reports/01_team-research.md) | Team research (4 teammates): Option A rejection, Option B reframing, axiom inventory audit |
| [../../090_research_bx_le_redefinition/reports/02_bx_le_linear_diagnostic.md](../../090_research_bx_le_redefinition/reports/02_bx_le_linear_diagnostic.md) | `lean-lsp` probe evidence that global/interval `bx_le_linear` is not derivable from BX7+BX11+BX12 |
| [../../090_research_bx_le_redefinition/reports/03_task92_recommendation.md](../../090_research_bx_le_redefinition/reports/03_task92_recommendation.md) | The definitive direction for task 92 — the primary input for `/plan 92` |
| [../../090_research_bx_le_redefinition/summaries/01_bx_le_decision-summary.md](../../090_research_bx_le_redefinition/summaries/01_bx_le_decision-summary.md) | Task 90 completion summary |

## Verdict Summary (from task 90)

**Adopt Burgess-Xu Until-induction on the unchanged `bx_le := g_content ⊆`
ordering.** Do NOT redefine `bx_le` (Option A is structurally infeasible).
Do NOT attempt a preliminary `bx_le_linear` lemma (Phase 1 `lean-lsp`
probes proved it non-derivable).

## Key Findings Task 92 Must Respect

1. **Axiom inventory is complete.** BX5, BX6, BX7, BX10, BX11, BX12 and
   their Since-primed duals are all present in `Axioms.lean:176-263`.
   Task 92 does NOT need to add any new axioms.
2. **`bx_le` stays as `g_content ⊆`** (`Frame.lean:61`). Do not redefine,
   refactor, or shadow it.
3. **Global `bx_le_linear` is not derivable.** Probes 1-2 of the Phase 1
   diagnostic showed the goal `bx_le a b ∨ bx_le b a` for arbitrary MCSes
   has no closing tactic because BX11 is an object-logic formula schema
   while `bx_le` is a metalogic relation. The structural obstruction is
   the absence of a finitary characteristic formula for an MCS.
4. **Interval linearity is also not derivable.** Probe 3 showed that even
   with both `u, v` in the `w`-future cone, BX11 cannot be invoked because
   there is no shared F-formula in `w.formulas` pinning down both `u` and
   `v`.
5. **The `Frame.lean:674` comment is misleading.** The comment says
   > Gap: need w ≤ u to use the guard. Requires linearity of bx_le between
   > w and u.
   Task 92 must rewrite this comment. The fix is not to prove
   `w ≤ u ∨ u ≤ w`. The fix is to propagate `¬(φ U ψ)` *forward* along
   the `w`-trajectory (via BX4 `connect_future`), not backward from `v`,
   so the guard is applied at a point that lies in `w`'s trajectory by
   construction.
6. **The `Frame.lean:647-651` comment is also misleading.** It attributes
   the block to a "g-content vs Until-witness mismatch". The actual block
   is the missing metalogic/object-logic bridge, and the solution is
   *direct construction* of the trajectory, not redefinition or
   quasimodels.

## Proof Sketch (Verbatim from Task 90 Recommendation)

For `bx_until_eventuality_resolution` (`Frame.lean:632-653`):

1. From `φ U ψ ∈ w` and BX10 (`until_F`), get `F(ψ) ∈ w`. Via
   `bx_forward_witness` (`Frame.lean:161-171`), obtain some `v₀` with
   `w ≤ v₀` and `ψ ∈ v₀.formulas`.
2. BX5 (`self_accum_until`): `φ U ψ → (φ ∧ (φ U ψ)) U ψ`. Upgrades the
   Until into self-accumulating form; at every intermediate point of the
   guard, `(φ U ψ)` is still true.
3. BX6 (`absorb_until`): `(φ U (φ ∧ (φ U ψ))) U ψ → (φ U ψ)`. Combined
   with BX5, every reachable point on the `[w, v]` trajectory that lies
   strictly before the first ψ-witness carries `φ` in its formula set.
4. For the guard property (third conjunct of the goal), take any `u` with
   `w ≤ u ≤ v ∧ ¬(v ≤ u)`. By the self-accumulation form,
   `(φ U ψ) ∈ u`. By BX9 (`until_elim`), `φ ∨ ψ ∈ u`. If `ψ ∈ u` then
   `u` and `v` would be indistinguishable on ψ and we obtain `v ≤ u`
   (contradicting the strict hypothesis), so `φ ∈ u`.
5. The construction of `v` itself uses BX10 + BX12: BX10 gives `F(ψ)`,
   BX12 gives the vacuous-guard Until form `⊤ U ψ`, which combined with
   BX7 (`linear_until` on `(φ U ψ) ∧ (⊤ U ψ)`) lets us pick the
   *earliest* ψ-witness along the trajectory. Earliest-ness is what
   eliminates the "lies between" checks; we no longer need to linearize
   arbitrary `u, v ≥ w`.

For `bx_until_backward` (`Frame.lean:664-675`):

- Instead of taking `u` from `P(¬(φ U ψ)) ∈ v` and asking whether
  `w ≤ u`, use BX4 `connect_future` directly on `w` to propagate
  `¬(φ U ψ)` *forward* along the `w`-trajectory, then contradict with
  the guard hypothesis at the propagated point. The point is in the
  `w`-trajectory by construction.

Mirrors for `bx_since_eventuality_resolution` and `bx_since_backward`
use BX5', BX6', BX7', BX10', BX11', BX12'.

## Scope Fence (Non-Goals)

Closing the 4 Until/Since sorries is NOT the same as proving
`bx_completeness`. Task 92 explicitly does NOT address:

- `Frame.lean:440` — Box-direction sorry (owned by **task 93**).
- `Completeness.lean:154` — TaskModel embedding sorry (owned by
  **task 93**).
- Any change to `bx_le` (`Frame.lean:61`), `bx_modal_equiv`
  (`Frame.lean:67`), or the axiom inventory in
  `ProofSystem/Axioms.lean`.
- Any refactor of `bx_forward_witness`, `bx_backward_witness`,
  `bx_G_forward`, `bx_G_backward`, `bx_H_forward`, `bx_H_backward`,
  or `box_preserved_along_bx_le`.

## Inputs for `/plan 92`

When `/plan 92` runs, it should treat this document together with
[03_task92_recommendation.md](../../090_research_bx_le_redefinition/reports/03_task92_recommendation.md)
as the primary research input. Expected plan structure (preliminary):

| Phase | Scope |
|-------|-------|
| 1 | Close `bx_until_eventuality_resolution` via BX10+BX12+BX7+BX5+BX6 |
| 2 | Close `bx_until_backward` via BX4 forward propagation |
| 3 | Close `bx_since_eventuality_resolution` (mirror of 1) |
| 4 | Close `bx_since_backward` (mirror of 2) |
| 5 | Rewrite misleading comments at `Frame.lean:647-651` and `:674` |

Estimated 8-16 hours total (2-4h per sorry plus cleanup).

## Escalation Path

If Phase 1 or Phase 3 stalls on BX6 absorption during implementation,
invoke `/spawn 92` with the stuck sub-goal as the blocker. This would
create a new task (likely 94) for a quasimodel or Hintikka pivot.
**Do NOT escalate preemptively.**

## Canonical Name Discipline

Use **"Burgess-Xu Until-induction"** in all task 92 artifacts, commit
messages, and in-file comments. Do NOT use "Henkin closure" or
"Henkin enrichment" — historically confusable with the first-order
completeness Henkin construction. The mechanism is purely metalogic
induction along a BX5/BX6/BX10/BX12-manufactured trajectory.
