# Task 98 Implementation Summary (v2 attempt, partial)

- **Task**: 98 - research_filtration_quasimodel_pivot
- **Plan**: specs/098_research_filtration_quasimodel_pivot/plans/02_quasimodel-pivot-plan.md
- **Status**: PARTIAL (phases 4-5 BLOCKED)
- **Session**: sess_1775950000_i98res
- **Date**: 2026-04-10

## Outcome

Implementation halted at the Phase 4 gate check. The combined seed consistency
problem at the heart of the Hintikka-level chain realization approach could not
be closed cleanly within this session without introducing new sorries or new
axioms. Zero-debt requirement enforced: no code changes applied, baseline
preserved exactly as committed in 661f20557.

## Phase Status

| Phase | Scope | Status |
|-------|-------|--------|
| 1 | SubformulaClosure infrastructure | COMPLETED (prior commit 330d4449f) |
| 2 | HintikkaPoint definition + sigma_signature | COMPLETED (prior commit bce8f9f38) |
| 3 | Quasimodel Construction + MCS lemmas | COMPLETED (prior commit 661f20557) |
| 4 | Hintikka-level chain + realization lifting | BLOCKED (gate check) |
| 5 | Until/Since sorry closure in Frame.lean | BLOCKED (depends on 4) |
| 6 | Integration wiring | COMPLETED (prior, module already imported) |

## Gate Check: Phase 4 Sub-phase 4b

The planner explicitly flagged the chain-level realization lifting as a gate:

> GATE CHECK: If realize_chain_step's consistency proof or sigma_signature
> round-trip fails, HALT and report.

The required lemma is:

Given BXPoint `v_i` with `sigma_signature v_i Sigma = h_i` and Hintikka step
`hintikka_step h_i h_{i+1}`, the enriched seed
`h_{i+1}.formulas ∪ g_content(v_i.formulas)`
must be provably consistent in order to extract `v_{i+1}` via Lindenbaum with
`bx_le v_i v_{i+1}` and `sigma_signature v_{i+1} Sigma = h_{i+1}`.

### Why this is hard (round 2 team research, report 02_team-research.md)

Round 2 team research (commit 64bf54342) identified this exact lemma as
"the sole remaining hard sub-problem" after ruling out 5 alternative
approaches. The obstruction is that `h_{i+1}` is locally maximal over the
finite Sigma (so its consistency is local) while `g_content(v_i)` ranges
over arbitrary G-formulas in `v_i`'s infinite MCS. Combining them in a
Lindenbaum seed forces a global consistency argument that does not reduce
to the existing single-step `enriched_seed_consistent_until`/`..._since`
lemmas (Realization.lean:140, 193 — themselves sorry-free but single-step).

The analogous obstruction for Phase 5c (Since standalone realization) is
structurally identical with `h_content` in place of `g_content`.

### Why naive alternatives fail

All 5 alternatives from round 2 research remain closed:

1. `bx_le` totality via BX7 — FALSE (g_content comparisons are not totally
   ordered even on BX11-linear temporal witnesses).
2. Until-induction axiom — removed in refactor, no path to re-add.
3. Until goal-weakening `(φ U (φ ∧ ψ)) → (φ U ψ)` — NOT derivable from BX1-BX12.
4. Redefining `bx_le` via Until-witness ordering — cascade cost too high
   (breaks every sorry-free proof in Frame.lean:140-583).
5. Global quasimodel embedding — would require TaskModel construction (task 93),
   explicitly deferred.

## Files Touched

None. The baseline state preserved:

- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/SubformulaClosure.lean` — unchanged from Phase 1 completion
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/HintikkaPoint.lean` — unchanged from Phase 2 completion
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` — unchanged from Phase 3 completion
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` — 6 sorries from prior Phase 4 partial (commit 661f20557)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` — delegation wrappers (no proofs of their own)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — 4 Until/Since sorries at lines 653, 675, 690, 704

Only the plan phase markers were updated (Phase 4 and 5 set to BLOCKED).

## Verification

| Check | Result |
|-------|--------|
| `lake build` | PASS (baseline clean) |
| Active sorries in BXCanonical | 11 (no change from pre-session baseline) |
| New sorries introduced this session | 0 |
| New axioms introduced | 0 |
| Frame.lean lines 140-583 unchanged | YES (not touched) |
| TruthLemma.lean unchanged | YES (not touched) |

### Sorry inventory (active, non-comment)

- `Completeness.lean:154` — TaskModel construction (baseline, task 93 scope)
- `Frame.lean:653` — `bx_until_eventuality_resolution` (Phase 5 target, not closed)
- `Frame.lean:675` — `bx_until_backward` (Phase 5 target, not closed)
- `Frame.lean:690` — `bx_since_eventuality_resolution` (Phase 5 target, not closed)
- `Frame.lean:704` — `bx_since_backward` (Phase 5 target, not closed)
- `Realization.lean:282, 286` — `until_eventuality_resolution` guard-lift gaps
- `Realization.lean:346` — `until_backward` contradiction gap
- `Realization.lean:372, 374` — `since_eventuality_resolution` guard-lift gaps
- `Realization.lean:404` — `since_backward` contradiction gap

These 10 active-path sorries under BXCanonical/ correspond exactly to the
situation before this session. One additional baseline sorry is in
Completeness.lean:154 (TaskModel).

## Recommended Next Steps

The plan v2 restructure is mathematically sound (Hintikka-level guards are
trivial from `hintikka_step`), but realization lifting requires infrastructure
that is beyond what can be built in a single implementation session:

1. **Explicit well-founded recursion on `defect_count`** — needs a Lean
   termination proof that the Sigma-projection of the successor BXPoint
   strictly reduces the defect measure. The round 2 team research did not
   provide a constructive termination bound.
2. **Chain-level seed consistency** — requires either a new global lemma
   linking finite Hintikka sets to infinite g_content closures, or a proof
   technique that sidesteps the combined seed entirely (e.g., working
   purely at the Hintikka level until the very last step).

Concrete options for a follow-up task:

- **Option A** (multi-week): Fully formalize the Burgess-Xu quasimodel
  construction with explicit chain recursion and a constructive termination
  proof. Expected cost: 40-80 hours.
- **Option B** (pivot): Redefine `bx_le` via Until-witness ordering as
  originally investigated in task 90, accepting the cascade cost to
  Frame.lean:140-583 and re-proving those theorems. Expected cost: 80-120
  hours but resolves the problem definitively.
- **Option C** (defer): Mark the 4 Frame.lean sorries as accepted
  technical debt pending TaskModel embedding (task 93), which provides
  a semantic alternative that bypasses canonical-model completeness.

The current partial state (6 Realization.lean sorries documenting the
analysis) remains useful as a record of the gap for any future attempt.

## References

- Plan: specs/098_research_filtration_quasimodel_pivot/plans/02_quasimodel-pivot-plan.md
- Round 1 research: specs/098_research_filtration_quasimodel_pivot/reports/01_filtration-quasimodel-pivot.md
- Round 2 team research: specs/098_research_filtration_quasimodel_pivot/reports/02_team-research.md
- Prior partial commit: 661f20557
- Plan revision commit: cc49612fb
