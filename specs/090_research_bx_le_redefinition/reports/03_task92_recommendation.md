# Task 92 Recommendation: Burgess-Xu Until-Induction

- **Task**: 90 — bx_le redefinition decision (Phase 3 output)
- **Audience**: Task 92 executor and `/research` / `/plan` invocations on task 92
- **Date**: 2026-04-10
- **Inputs**:
  - [01_team-research.md](01_team-research.md) — team research synthesis
  - [02_bx_le_linear_diagnostic.md](02_bx_le_linear_diagnostic.md) — lean-lsp probe findings
  - ROAD_MAP.md — "Burgess-Xu Until-Induction Technique" section

## Final Verdict

**Reject Option A. Adopt Burgess-Xu Until-induction on the unchanged
`bx_le := g_content ⊆` ordering.** Do NOT include a preliminary
`bx_le_linear` (or interval-linear) lemma as a prerequisite. Build the
trajectory directly via Until-induction, so that the required `w ≤ u`
relationships hold *by construction* rather than by post-hoc linearization.

### Canonical Name

Use **"Burgess-Xu Until-induction"** in all task 92 artifacts, commit
messages, and in-file comments. Do NOT use "Henkin closure" or
"Henkin enrichment" — the team research flagged that terminology as
historically confusable with the unrelated Henkin construction for first-
order completeness, and the probe confirms the mechanism has nothing to do
with enriching the MCS closure. The technique is purely a metalogic
induction along a BX5/BX6/BX10/BX12-manufactured trajectory.

## Active Branch

Based on the Phase 2 diagnostic outcome `(b) PARTIAL — structural blocker
identified`, the active branch is **Branch B**.

### Branch B (ACTIVE) — Burgess-Xu Until-induction, no prereq linearity lemma

The diagnostic demonstrated that neither global `bx_le_linear` nor the
interval variant is derivable from BX7 + BX11 + BX12. The obstruction is
structural: BX11 is an internal axiom schema (object-level F-linearity) and
`bx_le` is a metalogic relation; there is no finitary characteristic formula
to bridge them.

The solution is to bypass the bridge entirely by constructing the trajectory
explicitly. For `bx_until_eventuality_resolution` (`Frame.lean:632-653`):

1. From `φ U ψ ∈ w` and BX10, get `F(ψ) ∈ w`. Via `bx_forward_witness`,
   obtain some `v₀` with `w ≤ v₀` and `ψ ∈ v₀.formulas`.
2. BX5 (`self_accum_until`): `φ U ψ → (φ ∧ (φ U ψ)) U ψ`. This upgrades the
   Until into its "self-accumulating" form; at every intermediate point of
   the guard, `(φ U ψ)` is still true.
3. BX6 (`absorb_until`): `(φ U (φ ∧ (φ U ψ))) U ψ → (φ U ψ)`. Combined with
   BX5, every reachable point on the `[w, v]` trajectory that lies strictly
   before the first ψ-witness carries `φ` in its formula set.
4. For the guard property (third conjunct of the goal), take any `u` with
   `w ≤ u ≤ v ∧ ¬(v ≤ u)`. By the self-accumulation form, `(φ U ψ) ∈ u`.
   By BX9 (`until_elim`), `φ ∨ ψ ∈ u`. If `ψ ∈ u` then `u` and `v` would be
   indistinguishable on ψ and we obtain `v ≤ u` (contradicting the strict
   hypothesis), so `φ ∈ u`.
5. The construction of `v` itself uses BX10 + BX12: BX10 gives `F(ψ)`,
   BX12 gives the vacuous-guard Until form `⊤ U ψ`, which combined with
   BX7 (linear_until on `(φ U ψ) ∧ (⊤ U ψ)`) lets us pick the *earliest*
   ψ-witness along the trajectory. Earliest-ness is what eliminates the
   "lies between" checks; we no longer need to linearize arbitrary u, v ≥ w.

For `bx_until_backward` (`Frame.lean:664-675`), the comment block at
line 674 reads:

> Gap: need w ≤ u to use the guard. Requires linearity of bx_le between
> w and u.

**This comment is now known to be misleading.** The fix is not to prove
linearity. The fix is: instead of taking `u` from `P(¬(φ U ψ)) ∈ v` and then
asking whether `w ≤ u`, use BX4 `connect_future` directly on `w` to
propagate `¬(φ U ψ)` *forward* along the `w`-trajectory (not backward from
`v`), then contradict with the guard hypothesis at the propagated point. The
point is in the `w`-trajectory by construction.

Mirrors apply for `bx_since_eventuality_resolution`
(`Frame.lean:683-690`) and `bx_since_backward` (`Frame.lean:697-704`)
using BX5', BX6', BX7', BX10', BX11', BX12'.

**Estimated effort**: 8-16 hours (4 sorries × 2-4h each, with BX6/BX6'
absorption being the most delicate step).

**Success criteria for task 92**:
- All four sorries at `Frame.lean:653, 675, 690, 704` closed.
- No new axioms or definitions added; `bx_le` unchanged.
- No preliminary `bx_le_linear` or `bx_le_interval_linear` lemma.
- `lake build Bimodal.Metalogic.BXCanonical.Frame` succeeds.
- The misleading "linearity gap" comments at lines 647-651 and 674 rewritten
  to describe the Burgess-Xu construction.

## Inactive Branches (Recorded for Traceability)

### Branch A — Direct proof via bx_le_linear lemma (ELIMINATED)

Phase 2 Probes 1-3 demonstrated that `bx_le_linear` and its interval variant
are not directly derivable. This branch is structurally infeasible, not
merely absent from the current proof.

### Branch C — Escalation to quasimodel/Hintikka pivot (INACTIVE)

The diagnostic did not surface a formal countermodel to linearity, so there
is no need to invoke `/spawn 92`. If Branch B fails during implementation
(e.g., BX6 absorption cannot be discharged), *then* escalate via `/spawn 92`
with the specific stuck sub-goal as the blocker, creating task 94 for a
quasimodel or Hintikka pivot. Do NOT escalate preemptively.

### Branch D — Inconclusive fallback (INACTIVE)

The Phase 1 probes produced a decisive classification; no fallback is
required.

## Scope Fence (Non-Goals for Task 92)

Closing the 4 Until/Since sorries is NOT the same as proving
`bx_completeness`. Task 92 explicitly does NOT address:

- `Frame.lean:440` — Box-direction sorry (owned by **task 93**).
- `Completeness.lean:154` — TaskModel embedding sorry (owned by **task 93**).
- Any change to `bx_le` (line 61), `bx_modal_equiv` (line 67), or axiom
  inventory in `Theories/Bimodal/ProofSystem/Axioms.lean`.
- Any refactor of `bx_forward_witness`, `bx_backward_witness`,
  `bx_G_forward`, `bx_G_backward`, `bx_H_forward`, `bx_H_backward`, or
  `box_preserved_along_bx_le`.

The 4 Until/Since sorries feed a future task (likely in the 93/94/95 range)
that will combine them with the Box direction to close `bx_completeness`.

## Cross-References

- [01_team-research.md](01_team-research.md) — team research synthesis
  (Option A rejection, Option B reframing, axiom inventory audit).
- [02_bx_le_linear_diagnostic.md](02_bx_le_linear_diagnostic.md) —
  lean-lsp probe evidence for Branch B selection.
- `ROAD_MAP.md` — Burgess-Xu Until-Induction Technique section.
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:624-704` — the 4
  sorries that task 92 will close.
- `Theories/Bimodal/ProofSystem/Axioms.lean:176-263` — BX5, BX6, BX7,
  BX10, BX11, BX12 definitions.
