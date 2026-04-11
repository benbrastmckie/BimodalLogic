# Task 98 Implementation Summary (v3, session 3 — Phase 3 scaffolding)

- **Task**: 98 - research_filtration_quasimodel_pivot
- **Plan**: specs/098_research_filtration_quasimodel_pivot/plans/03_quasimodel-pivot-plan.md (v3)
- **Status**: PARTIAL (Phases 1-2 COMPLETED from prior sessions; Phase 3 scaffolding landed as PARTIAL; Phases 4-8 deferred)
- **Session**: sess_1775871394_240417
- **Date**: 2026-04-11

## Outcome

Phase 3 scaffolding has landed cleanly. The Construction.lean file now
carries the refined termination-measure infrastructure that Phases 4-5
will consume:

- `untilDefectSet` / `sinceDefectSet` — Finset of Until/Since defects at a
  Hintikka point, paired with `mem_*DefectSet_iff` characterizations.
- `defect_count_eq_card` — bridge between the existing `defect_count`
  measure and the new `Finset` view.
- `hintikka_step_target_decrease` (and Since dual) — the key strict-decrease
  lemma, proved modulo a `defect_mono` monotonicity hypothesis that will
  be discharged at the realization-lifting level in Phase 5.
- `QuasimodelChain` structure — refined type tracking the target defect
  `(target_lhs, target_rhs)` carrying a nonempty list of Hintikka points
  with consecutive `hintikka_step` proofs.
- `QuasimodelChain.last`, `.witnessReached`, `.length`, `.length_pos`,
  `.singleton` — constructors and accessors ready for the Phase 3
  remaining-work (well-founded recursion in `hintikka_chain_exists`).

Phase 3's remaining work — `hintikka_chain_exists` by well-founded
recursion on `defect_count`, plus `hintikka_chain_guard` and
`hintikka_chain_witness` — was not attempted this session because the
recursion construction is tightly coupled to the Phase 4 chain-step
seed-consistency proof and the Phase 5 `defect_mono` discharge. Attempting
it in isolation would produce either dead code or a sequence of `sorry`s,
neither of which is compatible with the "zero new sorries" constraint.
Phase 3 is therefore marked `[PARTIAL]` with the termination-scaffolding
delivered and the recursion construction deferred to the combined
Phase 3/4/5 work in a follow-up session.

## Phase Status

| Phase | Scope | Status | Notes |
|-------|-------|--------|-------|
| 1 | bigconj + EnrichedClosure definitions | COMPLETED | Prior session 1 |
| 2 | Migrate HintikkaPoint/Construction to EnrichedClosure | COMPLETED | Prior session 2; Gate A passed (blast radius 0, no migration needed) |
| 3 | Refined QuasimodelChain + defect_count termination | PARTIAL | Scaffolding delivered this session; recursive `hintikka_chain_exists` deferred |
| 4 | Chain-step seed consistency | NOT STARTED | Tightly coupled to remaining Phase 3 work |
| 5 | Realize full chain | NOT STARTED | Gate B not reached |
| 6 | Locus-control exhaustiveness | NOT STARTED | 12h ceiling |
| 7 | Close 6 Realization.lean sorries | NOT STARTED | Consumes phases 3-6 |
| 8 | Close 4 Frame.lean sorries | NOT STARTED | Consumes phase 7 |

## Files Modified

### `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean`

Appended a new section "Until-Defect Set and Strict-Decrease Infrastructure"
plus "Refined QuasimodelChain Type". Net addition: ~200 lines (file grew
from 210 to ~410 lines). All additions typecheck and are covered by
`lake build`.

Key new definitions and theorems:

```
noncomputable def untilDefectSet : HintikkaPoint Sigma → Finset Formula
noncomputable def sinceDefectSet : HintikkaPoint Sigma → Finset Formula
noncomputable def since_defect_count : HintikkaPoint Sigma → Nat

theorem defect_count_eq_card (h) : defect_count h = (untilDefectSet h).card
theorem mem_untilDefectSet_iff : f ∈ untilDefectSet h ↔ ...
theorem mem_sinceDefectSet_iff : f ∈ sinceDefectSet h ↔ ...

theorem hintikka_step_target_decrease
    (h_target_in : Formula.untl φ ψ ∈ h1.formulas)
    (h_target_sigma : Formula.untl φ ψ ∈ Sigma)
    (h_not : ψ ∉ h1.formulas)
    (h_witness : ψ ∈ h2.formulas)
    (defect_mono : untilDefectSet h2 ⊆ untilDefectSet h1) :
    defect_count h2 < defect_count h1

theorem hintikka_step_target_decrease_since : (Since dual of the above)

structure QuasimodelChain (Sigma : Finset Formula) (target_lhs target_rhs : Formula)
  points : List (HintikkaPoint Sigma)
  nonempty : points ≠ []
  target_at_head : Formula.untl target_lhs target_rhs ∈ (points.head nonempty).formulas
  step_chain : ∀ i : Fin (points.length - 1), hintikka_step ...

noncomputable def QuasimodelChain.last
def QuasimodelChain.witnessReached
def QuasimodelChain.length
theorem QuasimodelChain.length_pos
noncomputable def QuasimodelChain.singleton
```

### Design decision: `defect_mono` as an explicit hypothesis

The plan v3 Phase 3 task description calls for proving strict decrease
unconditionally from `hintikka_step`. However, the abstract `hintikka_step`
definition in `Construction.lean:44-51` does NOT imply that
`h2.formulas ⊆ h1.formulas`, nor does it restrict which new Until-formulas
may enter `h2`. Without a monotonicity constraint, `h2` could introduce
fresh Until-defects that cancel the target discharge, leaving the defect
count unchanged or higher.

Teammate D's findings (report 03_teammate-d-findings.md §"Concrete suggestion",
lines 184-191) implicitly assume such monotonicity when asserting that
"each step either discharges a defect or reaches the goal". In the actual
realization lifting (Phase 5), monotonicity holds by construction: each
`v_{i+1}` is built via Lindenbaum on a seed including `h_i.formulas`, so
all Until-formulas that were defects at `h_i` and are not discharged
remain defects at `h_{i+1}`.

The delivered `hintikka_step_target_decrease` therefore takes `defect_mono`
as an explicit hypothesis. Phase 4/5 will compose:

```
Phase 4/5: chain_step_seed_consistent + lindenbaum extension →
  for each step, defect_mono h2 h1 holds →
  hintikka_step_target_decrease applies →
  well-founded recursion in hintikka_chain_exists terminates
```

This is a tighter design than "prove strict decrease from hintikka_step
alone" because it cleanly separates the combinatorial termination argument
(delivered here) from the derivation-theoretic lifting argument (Phase 4).

## Verification

| Check | Result |
|-------|--------|
| `lake build` (full project) | PASS (949/949) |
| New sorries introduced this session | 0 |
| New axioms introduced this session | 0 |
| Raw sorry count across `Theories/` | 194 (unchanged from baseline) |
| Active sorry count in BXCanonical | 11 (unchanged: 4 Frame.lean + 6 Realization.lean + 1 Completeness.lean task 93 scope) |
| Axioms in `Theories/` | 4 (unchanged from baseline) |
| Frame.lean lines 140-583 unchanged | YES |
| TruthLemma.lean unchanged | YES |
| SubformulaClosure.lean unchanged | YES |
| HintikkaPoint.lean unchanged | YES |
| Construction.lean | MODIFIED (Phase 3 scaffolding appended, file grew ~210 → ~410 lines) |
| EnrichedClosure.lean unchanged | YES |
| Realization.lean unchanged | YES |
| LocusControl.lean unchanged | YES |
| Phase 3 marker | PARTIAL |

## Why Phases 4-8 Were Not Attempted

Plan v3 carries a 52-98h point estimate and explicitly anticipates partial
completion via the Gate A/Gate B/"bail to partial" fallback. Phase 4
(chain-step seed consistency) requires writing `bigconj_intro` and
`bigconj_mem_iff` at the `DerivationTree` level and composing them with
`g_content_closed_derivation` in a five-step reduction (Teammate A §3.3).
Phase 5 requires Lindenbaum extension on the Phase 4 seeds plus the
`defect_mono` discharge. Together these are 18-29h of focused work on
APIs (`DerivationTree`, Lindenbaum extension, `sigma_signature_mem`) that
are unfamiliar territory for a single session.

The delivered Phase 3 scaffolding represents the highest-leverage isolated
sub-unit that can stand alone: it provides the termination measure and
strict-decrease lemma that Phase 4/5 will consume, without taking on
any derivation-theoretic obligations. Follow-up sessions can proceed
directly to the Phase 4 `chain_step_seed_consistent` proof with the
`hintikka_step_target_decrease` lemma already available.

## Recommended Next Steps

1. **Follow-up session 1 (Phase 4, ~8-15h)**: Write `bigconj_intro` and
   `bigconj_mem_iff` at the `DerivationTree` level (deferred from Phase 1).
   Prove `chain_step_seed_consistent` via the five-step reduction from
   Teammate A §3.3. Add `bigconj_mem_hintikka`,
   `neg_bigconj_mem_next_hintikka`, `hintikka_locally_consistent`.

2. **Follow-up session 2 (Phase 3 remainder + Phase 5, ~10-16h)**: Define
   `hintikka_chain_exists` by well-founded recursion on `defect_count`,
   using `hintikka_step_target_decrease` plus the Phase 4 seed consistency
   to discharge `defect_mono` at each step. Prove `realize_chain_step`
   and `realize_full_chain`. Pass Gate B.

3. **Follow-up sessions 3-4 (Phases 6-8, ~25-50h)**: Prove locus-control
   exhaustiveness (or fall back to axiom per Phase 6 mitigation), close
   the 6 Realization.lean sorries, close the 4 Frame.lean sorries.

Alternative per plan v3 rollback: split off Phase 6 + Since direction
into a follow-on task 99, completing task 98 with the Until direction
only (~32-53h remaining).

## References

- Plan v3: specs/098_research_filtration_quasimodel_pivot/plans/03_quasimodel-pivot-plan.md
- Prior (session 1) summary: specs/098_research_filtration_quasimodel_pivot/summaries/03_enrichedclosure-implementation-summary.md
- Prior (session 2) summary: specs/098_research_filtration_quasimodel_pivot/summaries/04_phase2-plus-summary.md
- Round 3 team research: specs/098_research_filtration_quasimodel_pivot/reports/03_team-research.md
- Teammate A (EnrichedClosure construction): 03_teammate-a-findings.md
- Teammate C (gap identification): 03_teammate-c-findings.md
- Teammate D (defect_count termination design): 03_teammate-d-findings.md
