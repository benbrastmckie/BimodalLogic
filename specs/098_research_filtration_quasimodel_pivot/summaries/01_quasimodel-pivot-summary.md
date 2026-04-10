# Implementation Summary: Task #98

- **Task**: 98 - research_filtration_quasimodel_pivot
- **Status**: [PARTIAL]
- **Started**: 2026-04-10
- **Completed**: 2026-04-10 (resumed implementation)
- **Effort**: ~8 hours total (4 initial + 4 resumed)
- **Dependencies**: None
- **Artifacts**: plans/01_quasimodel-pivot-plan.md, reports/01_filtration-quasimodel-pivot.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md, summary-format.md

## Overview

Resumed implementation of the Hintikka-set quasimodel pivot for the Until/Since truth lemma in the BX canonical model. The resumed session focused on closing the 6 sorry locations in Realization.lean. After extensive mathematical analysis (testing multiple proof strategies including enriched seeds, BX7/BX11 applications, and Until-monotonicity derivation), the investigation determined that the sorries represent a genuine mathematical gap: the canonical ordering `bx_le` (defined as `g_content ⊆`) is not a total order, and the guard-lifting steps require either totality or Until-monotonicity, neither of which is derivable from BX1-BX12 without Until-induction.

The session produced two concrete results: (1) a proof of enriched seed consistency (`enriched_seed_consistent_until` and `enriched_seed_consistent_since`), which partially advances the backward direction proofs, and (2) a comprehensive mathematical analysis identifying exactly why the sorries cannot be closed with the current axiom set and proof structure.

## What Changed (Resumed Session)

- **Rewrote `Realization.lean`**: Replaced the previous 6-sorry version with an improved version containing:
  - `F_of_mem` and `P_of_mem`: Helper lemmas deriving F(ψ)/P(ψ) from ψ ∈ w
  - `F_from_above`: Helper deriving F(ψ) ∈ w from bx_le w v and ψ ∈ v
  - `enriched_seed_consistent_until`: **Sorry-free proof** that the seed `{¬(φ U ψ)} ∪ g_content(w) ∪ h_content(v)` is consistent when ¬(φ U ψ) ∈ w and bx_le w v and ψ ∈ v
  - `enriched_seed_consistent_since`: **Sorry-free proof** of the dual seed consistency for Since
  - `until_backward`: Restructured to use enriched seed, constructing u with BOTH bx_le w u and bx_le u v (major progress over previous version which lacked bx_le w u)
  - `since_backward`: Restructured using dual enriched seed
  - Comprehensive mathematical documentation in the module docstring explaining the root cause of each sorry
- Still 6 sorry locations (same as before), but the proof structure is significantly improved and the mathematical gap is precisely characterized

## Mathematical Findings

### Root Cause: bx_le Non-Totality

`bx_le` (g_content ⊆) is a preorder but NOT a total order. Two MCSs can be bx_le-incomparable: G(p) ∈ w, p ∉ v AND G(q) ∈ v, q ∉ w for distinct atoms p, q. BX11 (temporal linearity) constrains F-witnesses to be ordered but does NOT force g_content inclusion to be total.

### Approaches Investigated and Rejected

1. **Enriched seed for empty interval** (making bx_le v w hold): The seed `{ψ} ∪ g_content(w) ∪ h_content(w)` is NOT necessarily consistent because g_content(w) ∪ h_content(w) ⊆ w.formulas, and formulas in w can derive ¬ψ (since ψ ∉ w).

2. **bx_le totality from BX11**: BX11 says F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ). This constrains F-witnesses but doesn't force g_content inclusion totality. Explicit counterexample: two MCSs with incomparable g_content that satisfy BX11.

3. **Until goal-weakening** ((φ U (φ ∧ ψ)) → (φ U ψ)): NOT derivable from BX1-BX12. BX7 combinations produce cases where BX6 (absorption) applies (giving the contradiction), but the MCS can consistently avoid the BX6-applicable case.

4. **Until chaining** ((α U β) ∧ (β → α U γ) → α U γ): Partially derivable using BX7 + BX6 (case 3 of BX7 gives α U (α ∧ (α U γ)) → α U γ by BX6), but the BX7 disjunction is not guaranteed to land on the right case.

5. **Direct G-propagation** (showing G(φ) ∈ w from φ U ψ ∈ w): Impossible since G(φ) means "φ at all future times" which is strictly stronger than "φ at current time".

### What Would Close the Sorries

1. **Until-induction axiom** (removed from BX): `(ψ ∨ (φ ∧ X(θ)) → θ) → (φ U ψ → θ)`
2. **Restructured canonical model**: Define bx_le using Until-witness ordering instead of g_content inclusion
3. **Full quasimodel construction**: Work in a finite model with guaranteed total ordering, then lift
4. **Until goal-weakening** as a new axiom: `(φ U (φ ∧ ψ)) → (φ U ψ)`

## Decisions

- Kept Frame.lean's 4 sorries in place (no regressions to existing proofs)
- Rewrote Realization.lean with enriched seed approach (structurally superior to previous version)
- Documented the mathematical analysis in the module docstring for future work

## Impacts

- The quasimodel infrastructure remains in place for future approaches
- The enriched seed consistency theorems are new sorry-free results that advance the backward direction
- The mathematical analysis identifies the precise blocker, enabling focused future work
- No existing sorry-free proofs affected (zero regressions)
- `lake build` succeeds with all 723 jobs

## Follow-ups

- **Option A** (estimated 5-10h): Add Until goal-weakening as a new axiom to the BX system, then close all 6 sorries. Requires soundness proof for the new axiom.
- **Option B** (estimated 20-40h): Restructure the canonical model to use Until-witness ordering instead of g_content inclusion. Major refactoring.
- **Option C** (estimated 30-50h): Implement full quasimodel/filtration construction with total ordering by construction, then lift to canonical model.
- **Recommended**: Option A is the most pragmatic path forward. Until goal-weakening IS sound on linear temporal orders and fills the gap left by removing Until-induction.

## References

- `specs/098_research_filtration_quasimodel_pivot/reports/01_filtration-quasimodel-pivot.md` -- research report
- `specs/098_research_filtration_quasimodel_pivot/plans/01_quasimodel-pivot-plan.md` -- implementation plan
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/` -- all source files
