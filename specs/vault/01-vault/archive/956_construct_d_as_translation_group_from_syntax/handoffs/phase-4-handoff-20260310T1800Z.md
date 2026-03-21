# Handoff: Task 956 Phase 4 - Staged Construction Execution

## Immediate Next Action

Start Phase 4: Create `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean` implementing the even/odd stage alternation. Begin with defining `stage_0` (Lindenbaum of {neg phi_0}), then implement the `even_stage` function for processing F/P obligations, and `odd_stage` for density insertion.

## Current State

- **Plan**: `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-014.md`
- **Phases 0-3**: All COMPLETED, zero sorries, zero axioms
- **Phase 4**: NOT STARTED (next to implement)
- **Build**: `lake build` passes (758 jobs)
- **Branch**: `claude/modal-logic-group-structure-5aQsV`

### Files Created So Far

| File | Purpose |
|------|---------|
| `Theories/Bimodal/Metalogic/StagedConstruction/StagedTimeline.lean` | Core types: `StagedPoint`, `StagedTimeline`, ordering, union, monotonicity |
| `Theories/Bimodal/Metalogic/StagedConstruction/WitnessSeedWrapper.lean` | Forward/backward witness construction, CanonicalR properties, density |
| `Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean` | Distinguishing formulas, Case A separation, density intermediates, seriality |

### Key Available Lemmas

- `executeForwardStep` / `executeBackwardStep` - Create witness MCSs
- `executeForwardStep_canonicalR` / `executeBackwardStep_canonicalR` - CanonicalR properties
- `executeForwardStep_contains_phi` / `executeBackwardStep_contains_phi` - Witness contains target
- `density_intermediate` - Density axiom gives F-preserving intermediate
- `mcs_has_strict_future` / `mcs_has_strict_past` - Seriality witnesses
- `not_G_implies_F_neg` - Case A: G(beta) not in M implies F(neg beta) in M
- `StagedTimeline` structure with root, monotonicity, linearity invariants

## Key Decisions Made

1. **No ConstructiveFragment import**: ConstructiveFragment.lean has pre-existing build errors from Lean version migration. All needed functions (executeForwardStep, etc.) are replicated in WitnessSeedWrapper.lean.

2. **No general separation lemma (Case B)**: Research-034 showed Case B (G(beta) in M) cannot be resolved by seed construction techniques. The staged construction uses `density_intermediate` instead, which provides F-preserving intermediate witnesses directly from the density axiom.

3. **Strictness of individual witness steps NOT provable**: This is the same blocker that killed the ConstructiveQuotient approach. The staged construction ensures density/no-endpoints through the OVERALL construction, not through individual step strictness.

4. **StagedPoint.le_antisymm_mcs removed**: Under irreflexive semantics, mutual CanonicalR does not imply MCS equality. Antisymmetry is ensured by the construction maintaining distinct MCSs for distinct points.

## What NOT to Try

- Do NOT try to prove `executeForwardStep_strict` or `executeBackwardStep_strict` (individual step strictness) -- these are blocked by the G-completeness issue
- Do NOT import ConstructiveFragment.lean -- it has build errors
- Do NOT fall back to Path D (D = ConstructiveQuotient x Q) -- explicitly forbidden
- Do NOT try to use the full separation lemma Case B -- research-034 showed it's blocked

## Critical Context

1. The staged construction needs to be defined as an inductive/recursive function on Nat (stage number), producing a sequence of growing Finsets of StagedPoints
2. Even stages (0, 2, 4, ...) process F/P formula obligations for all points in the current timeline
3. Odd stages (1, 3, 5, ...) insert intermediate points between successive pairs using `density_intermediate`
4. Formula enumeration is needed (enumerate all formulas for processing obligations) -- Formula is countable
5. The `IsLinearlyOrdered` invariant must be maintained at each stage -- new witnesses must be proven comparable to all existing points

## References

- Plan: `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-014.md` (Phase 4 section)
- Research: `specs/956_construct_d_as_translation_group_from_syntax/reports/research-034.md` (Finding 15)
- Summary: `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-20260310d.md`
