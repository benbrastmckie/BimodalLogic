# Implementation Summary: Quasimodel Pivot v5 (Phases 5-8)

- **Task**: 98 - research_filtration_quasimodel_pivot
- **Artifact**: summaries/10_v5-implementation-summary.md
- **Date**: 2026-04-11
- **Session**: sess_1775924610_34c8e8

## Outcome: BLOCKED at Phase 5

Plan v5 Phases 5-8 could not be executed. The direct BX7-based approach for closing the four Frame.lean sorries is fundamentally blocked by a circularity in the proof structure.

## Investigation Summary

### Approach Attempted

The plan called for proving `bx_until_eventuality_resolution`, `bx_until_backward`, `bx_since_eventuality_resolution`, and `bx_since_backward` in Frame.lean using BX7 (Until linearity) and BX11 (temporal linearity) directly at the MCS level, bypassing the chain realization approach.

### Key Finding: Circularity

The guard proof for the Until truth lemma requires showing `phi in u` for intermediate BXPoints u in a `bx_le` interval [w, v). To derive `phi in u` from a Until formula's guard, one needs the FORWARD direction of the Until truth lemma -- the same theorem being proved. This creates an irreducible circularity.

### What Was Verified

Two helper lemmas were proved correct via `lean_run_code` (not committed to codebase):

1. **G_phi_F_psi_implies_until**: From `G(phi) in w` and `F(psi) in w`, derive `phi U psi in w`. Uses BX12 (F-Until bridge), BX2 (left monotonicity), prop_s (weakening), temporal_necessitation, and temp_k_dist.

2. **enriched_seed_with_G_phi_inconsistent**: The seed `{neg(phi U psi), G(phi)} union g_content(w) union h_content(v)` is inconsistent given `bx_le w v` and `psi in v`. This shows that G(phi) cannot coexist with neg(phi U psi) in any enriched-seed MCS.

### Root Cause

The canonical ordering `bx_le` (defined as g_content inclusion) is a preorder but NOT total. BX7 and BX11 constrain the ordering of Until-witnesses and F-witnesses respectively, but these constraints operate on formula membership, not on g_content inclusion between BXPoints. There is no axiom-derivable bridge between "F-witnesses are ordered" and "g_content inclusion is total on intervals."

### Approaches Exhausted

| Approach | Result |
|----------|--------|
| BX7 on phi U psi and top U psi | Trivially reduces (top doesn't constrain guard) |
| BX7 on self-accumulated forms | Equivalent to starting formulas |
| BX11 case analysis | Case 1 gives contradiction; Cases 2-3 create infinite regress |
| Enriched seed + G(phi) | Proved inconsistent but can't derive G(phi) from guard |
| Enriched seed + neg phi | May be consistent in bx_le v u case |
| Enriched seed + g_content(v) | Cannot derive phi U psi at u from bx_le-equivalent v |
| Direct G(phi) derivation from guard | Guard covers [w,v) not all future; G(phi) requires all future |

## Sorries Remaining

All 10 targeted sorries remain open:

| File | Theorem | Status |
|------|---------|--------|
| Frame.lean:653 | bx_until_eventuality_resolution | sorry (unchanged) |
| Frame.lean:675 | bx_until_backward | sorry (unchanged) |
| Frame.lean:690 | bx_since_eventuality_resolution | sorry (unchanged) |
| Frame.lean:704 | bx_since_backward | sorry (unchanged) |
| Realization.lean:500 | until_eventuality_resolution (guard 1) | sorry (unchanged) |
| Realization.lean:504 | until_eventuality_resolution (guard 2) | sorry (unchanged) |
| Realization.lean:564 | until_backward | sorry (unchanged) |
| Realization.lean:590 | since_eventuality_resolution (guard 1) | sorry (unchanged) |
| Realization.lean:592 | since_eventuality_resolution (guard 2) | sorry (unchanged) |
| Realization.lean:622 | since_backward | sorry (unchanged) |

## Recommendation

Trigger Phase 9 contingency: quotient/filtration model construction as a new task. The classical approach (Goldblatt 1992, Blackburn et al. 2001) constructs a finite quotient model where the ordering is total by construction, avoiding the bx_le non-totality issue entirely. Estimated effort: 40-60h, 85% confidence.

## Artifacts

- Handoff: `specs/098_research_filtration_quasimodel_pivot/handoffs/phase5_bx7_blocked.md`
- This summary: `specs/098_research_filtration_quasimodel_pivot/summaries/10_v5-implementation-summary.md`
