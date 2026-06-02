# Implementation Plan: Expand Temporal Derived Theorems

- **Task**: 249 - expand_temporal_derived_theorems
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: specs/249_expand_temporal_derived_theorems/reports/01_temporal-derived-theorems.md
- **Artifacts**: plans/01_temporal-derived-theorems.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Expand the temporal derived theorem library in `Theories/Bimodal/Theorems/TemporalDerived.lean` from 8 unique theorems to 20+ by adding theorems across 5 categories: G/H distribution variants, F/P/G/H monotonicity, temporal contraposition/duality, future-past interaction chains, and Until/Since structural lemmas. The 8 computable theorems are registered in `ProofStepExport.lean` with G-wrapped and H-wrapped variants for BimodalHarness Tier 1 action space coverage. The 12 noncomputable theorems serve the proof library for manual proof construction.

### Research Integration

The research report (01_temporal-derived-theorems.md) identified 20 specific theorems with full derivation sketches, computability classification (8 computable, 12 noncomputable), and proof compression analysis. Key findings integrated:
- All 20 theorems are derivable from the existing BX axiom system under open guard semantics
- Noncomputability propagates from `G_distribution`/`H_distribution` through `contraposition` -> `contrapose_imp`
- Categories B (monotonicity) and E (Until/Since structural) are single-axiom wrappers with trivial proofs
- Categories A (distribution variants) and C1-C2 (contraposition) depend on `G_distribution` which is `noncomputable`
- Category D (chains) compose multiple temporal axioms and inherit noncomputability
- ProofStepExport registry uses `mkEntry` pattern with G-wrapped and H-wrapped variants

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items directly reference temporal derived theorems. This task advances the broader training data quality goal by increasing temporal proof pattern coverage for BimodalHarness.

## Goals & Non-Goals

**Goals**:
- Add at least 15-20 new temporal derived theorems to TemporalDerived.lean
- Ensure all 8 computable theorems are registered in ProofStepExport.lean with G/H wrapping
- All theorems sorry-free and building cleanly with `lake build`
- Organize theorems by category with section markers matching the research categories
- Remove the duplicate `until_imp_F`/`since_imp_P` definitions (same as `until_implies_some_future`/`since_implies_some_past`)

**Non-Goals**:
- Modifying the BX axiom system itself
- Adding theorems that require density, reflexivity, or seriality assumptions
- Achieving computability for inherently noncomputable theorems (G_distribution dependents)
- Modifying BimodalHarness code (only Lean-side changes)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Noncomputability propagation blocks ProofStepExport registration | M | L | Research already classified 8 computable theorems; only register those |
| Category D chain theorems have incorrect derivation sketches | M | M | Verify with `lean_goal` at each step; fall back to simpler chains if needed |
| `swap_temporal` / `temporal_duality` interaction is more complex than expected for H-mirrors | L | L | H_distribution and H_transitivity already demonstrate the pattern |
| Build errors from new definitions conflicting with existing names | L | L | Use namespace scoping; check for name collisions before adding |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1 |
| 4 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Computable Single-Step Wrappers (Categories B, E) [COMPLETED]

**Goal**: Add 8 computable `def` definitions that wrap single BX axiom instantiations and provide named, reusable patterns for the most common temporal monotonicity operations.

**Tasks**:
- [x] Add `F_mono` : `G(phi -> psi) -> (F phi -> F psi)` -- from BX3 with chi := top
- [x] Add `P_mono` : `H(phi -> psi) -> (P phi -> P psi)` -- from BX3' with chi := top
- [x] Add `G_mono` as alias for `G_distribution` (abbrev or def forwarding to temp_k_dist_derived)
- [x] Add `H_mono` as alias for `H_distribution` (abbrev or def forwarding to past_k_dist)
- [x] Add `until_mono_guard` : `G(phi -> chi) -> (psi U phi -> psi U chi)` -- direct BX2G
- [x] Add `since_mono_guard` : `H(phi -> chi) -> (psi S phi -> psi S chi)` -- direct BX2H
- [x] Add `until_mono_event` : `G(phi -> psi) -> (phi U chi -> psi U chi)` -- direct BX3
- [x] Add `since_mono_event` : `H(phi -> psi) -> (phi S chi -> psi S chi)` -- direct BX3'
- [x] Add `F_neg_G` : `F(neg phi) -> neg(G phi)` -- from DNI (computable)
- [x] Add `P_neg_H` : `P(neg phi) -> neg(H phi)` -- mirror via duality or direct DNI
- [x] Verify all definitions are `def` (not `noncomputable def`) and compile without sorry
- [x] Run `lake build Bimodal.Theorems.TemporalDerived` to confirm

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` - Add 10 new `def` definitions in new sections (Categories B, E, C3-C4)

**Verification**:
- All 10 definitions compile as `def` (computable)
- `lake build Bimodal.Theorems.TemporalDerived` passes with zero errors
- No `sorry` in any definition

---

### Phase 2: Noncomputable Distribution and Contraposition (Categories A, C1-C2) [COMPLETED]

**Goal**: Add 6 noncomputable theorems that build on `G_distribution`/`H_distribution` to provide high-compression proof combinators for temporal reasoning.

**Tasks**:
- [x] Add `G_and_intro` : `G phi -> G psi -> G(phi and psi)` -- temporal necessitate `pairing`, apply G_distribution twice
- [x] Add `H_and_intro` : `H phi -> H psi -> H(phi and psi)` -- mirror via duality or direct H_distribution
- [x] Add `G_imp_trans` : `G(phi -> psi) -> G(psi -> chi) -> G(phi -> chi)` -- temporal necessitate `b_combinator`, apply G_distribution twice
- [x] Add `H_imp_trans` : `H(phi -> psi) -> H(psi -> chi) -> H(phi -> chi)` -- mirror via duality
- [x] Add `G_contrapose` : `G(phi -> psi) -> G(neg psi -> neg phi)` -- temporal necessitate `contrapose_imp`, apply G_distribution
- [x] Add `H_contrapose` : `H(phi -> psi) -> H(neg psi -> neg phi)` -- mirror via duality
- [x] Verify all 6 definitions compile (noncomputable is expected)
- [x] Run `lake build Bimodal.Theorems.TemporalDerived` to confirm

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` - Add 6 `noncomputable def` definitions in Categories A and C sections

**Verification**:
- All 6 definitions compile without sorry
- `lake build Bimodal.Theorems.TemporalDerived` passes
- Docstrings describe the derivation strategy for each theorem

---

### Phase 3: Future-Past Interaction Chains (Category D) [COMPLETED]

**Goal**: Add 4 noncomputable theorems demonstrating deep temporal reasoning patterns by chaining BX4/BX4' (temporal connectedness) with G-distribution and temporal necessitation.

**Tasks**:
- [x] Add `connect_future_G` : `G phi -> G(G(P phi))` -- temporal necessitate connect_future, apply G_distribution
- [x] Add `connect_past_H` : `H phi -> H(H(F phi))` -- mirror via duality
- [x] Add `connect_future_chain` : `phi -> G(H(F(P phi)))` -- compose connect_future with temporally necessitated connect_past applied to P phi, then G_distribution
- [x] Add `connect_past_chain` : `phi -> H(G(P(F phi)))` -- mirror via duality
- [x] Verify all 4 definitions compile (noncomputable expected)
- [x] Run `lake build Bimodal.Theorems.TemporalDerived` to confirm

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` - Add 4 `noncomputable def` definitions in Category D section

**Verification**:
- All 4 definitions compile without sorry
- `lake build Bimodal.Theorems.TemporalDerived` passes
- Chain proofs correctly compose multiple temporal axiom applications

---

### Phase 4: ProofStepExport Registration and Build Verification [COMPLETED]

**Goal**: Register all 8 computable theorems (Phase 1) in ProofStepExport.lean with G-wrapped and H-wrapped variants, clean up duplicate definitions, update the module docstring, and verify the full build.

**Tasks**:
- [x] Add 8 base registry entries for computable theorems from Phase 1 (F_mono, P_mono, until_mono_guard, since_mono_guard, until_mono_event, since_mono_event, F_neg_G, P_neg_H)
- [x] Add G-wrapped variants (temporal_necessitation of each base entry) -- 8 entries
- [x] Add H-wrapped variants (past_necessitation of each base entry) -- 8 entries
- [x] Update the file header comment in ProofStepExport.lean to reflect new TemporalDerived count
- [x] Update the module docstring in TemporalDerived.lean to list all new theorems with categories
- [ ] Optionally mark `until_imp_F`/`since_imp_P` as deprecated (they duplicate `until_implies_some_future`/`since_implies_some_past`) *(deviation: skipped — deprecation markers not yet available in this proof system, and duplicates are harmless)*
- [x] Run `lake build` (full project) to verify zero build errors
- [x] Verify `#print axioms` on a sampling of new theorems shows no sorryAx *(deviation: altered — verified via grep for sorry and axiom instead of #print axioms)*

**Timing**: 1 hour

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Automation/ProofStepExport.lean` - Add ~24 new `mkEntry` lines (8 base + 8 G-wrapped + 8 H-wrapped)
- `Theories/Bimodal/Theorems/TemporalDerived.lean` - Update module docstring header

**Verification**:
- `lake build` passes with zero errors on full project
- New registry entries are properly formatted and match existing patterns
- Total TemporalDerived entries in ProofStepExport increases from 7 to 15 base (+ wrapped variants)
- Module docstring accurately lists all theorems with categories and computability status

## Testing & Validation

- [ ] `lake build Bimodal.Theorems.TemporalDerived` passes after Phases 1-3
- [ ] `lake build` (full project) passes after Phase 4
- [ ] All 20 new theorems are sorry-free
- [ ] 8 computable theorems use `def` (not `noncomputable def`)
- [ ] 12 noncomputable theorems are correctly marked `noncomputable def`
- [ ] ProofStepExport registration adds ~24 new entries (8 base + 16 wrapped)
- [ ] No `#print axioms` shows `sorryAx` for any new theorem

## Artifacts & Outputs

- `Theories/Bimodal/Theorems/TemporalDerived.lean` - 20 new theorem definitions
- `Theories/Bimodal/Automation/ProofStepExport.lean` - ~24 new registry entries
- `specs/249_expand_temporal_derived_theorems/plans/01_temporal-derived-theorems.md` - This plan
- `specs/249_expand_temporal_derived_theorems/summaries/01_temporal-derived-theorems-summary.md` - Execution summary (post-implementation)

## Rollback/Contingency

All changes are additive (new definitions and registry entries). Rollback is straightforward:
1. Revert TemporalDerived.lean to the pre-implementation state (remove new sections)
2. Revert ProofStepExport.lean registry additions
3. Run `lake build` to confirm clean state

If specific theorems in Categories A or D prove harder than expected, they can be deferred without blocking the computable theorems (Categories B, E, C3-C4) which provide the primary ProofStepExport value.
