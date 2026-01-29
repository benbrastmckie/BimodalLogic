# Implementation Plan: Task #733

- **Task**: 733 - ultraproduct_based_compactness_proof
- **Status**: [COMPLETED]
- **Effort**: 4-6 hours
- **Priority**: Medium
- **Dependencies**: Task 735 (COMPLETED), Task 736 (COMPLETED)
- **Research Inputs**: specs/733_ultraproduct_based_compactness_proof/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

The goal is to complete the algebraic compactness proof for TM logic by filling the sorry at `InfinitaryStrongCompleteness.lean:175`. The research recommends **Approach A: Algebraic Compactness** using the ultrafilter-MCS correspondence that has been completed in Tasks 735/736.

Key insight: The `consistent_implies_satisfiable` theorem in `AlgebraicRepresentation.lean` is now PROVEN (lines 71-133). This means we have the critical bridge: consistent formulas can be satisfied by ultrafilters. The remaining work is to connect this algebraic satisfiability to semantic satisfiability and use it to prove `infinitary_strong_completeness`.

### Research Integration

From research-001.md:
- Algebraic approach leverages completed ultrafilter-MCS correspondence
- `mcsToUltrafilter` and `ultrafilterToSet_mcs` are fully proven (UltrafilterMCS.lean)
- `consistent_implies_satisfiable` now proven (AlgebraicRepresentation.lean:71-133)
- The sorry at InfinitaryStrongCompleteness.lean:175 requires showing: if Gamma |= phi semantically, then some finite Delta subset of Gamma derives phi proof-theoretically

## Goals & Non-Goals

**Goals**:
- Fill the sorry at `infinitary_strong_completeness` theorem (line 175)
- Complete the compactness proof chain from algebraic to semantic satisfiability
- Ensure `lake build` passes with no errors in the affected modules

**Non-Goals**:
- Building direct ultraproduct constructions for TaskModels (Approach B from research)
- Modifying the existing finite completeness machinery
- Changing the proof system axioms

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Algebraic satisfiability (AlgSatisfiable) may not directly imply semantic satisfiability (set_satisfiable) | High | Medium | Build bridge lemma connecting ultrafilter truth to model truth via canonical model |
| Proof complexity may exceed estimates | Medium | Medium | Use incremental approach with clear subgoals; commit working partial progress |
| May need additional lemmas about consistency of infinite sets | Medium | Low | The finitary nature of derivations already handles this |
| Type universe issues with existential witnesses | Low | Low | Leverage existing parametric completeness patterns |

## Implementation Phases

### Phase 1-3: Prove infinitary_strong_completeness [COMPLETED]

**Goal**: Fill the sorry in `infinitary_strong_completeness` using a direct contrapositive argument.

**Approach Taken** (simplified from original plan):
Instead of building separate algebraic bridge lemmas, we used a direct contrapositive proof:
1. Assume no finite Delta ⊆ Gamma derives phi
2. Prove Gamma ∪ {¬phi} is SetConsistent (via `no_finite_witness_implies_union_consistent`)
3. Extend to MCS via `set_lindenbaum`
4. Build canonical model from the MCS using `construct_coherent_family`
5. Use truth lemma to show both Gamma and ¬phi are true at the canonical model
6. Derive contradiction with Gamma |= phi

**Key Contributions**:
- Created `no_finite_witness_implies_union_consistent` lemma: proves that if no finite subset derives phi, then Gamma ∪ {¬phi} is consistent
- Proved `h_no_G_bot` and `h_no_H_bot` using temporal T axioms (temp_t_future, temp_t_past)
- Completed `infinitary_strong_completeness` theorem without sorry

**Files modified**:
- `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean`
  - Added import for `UniversalCanonicalModel`
  - Added `open` for `Bimodal.Metalogic.Core` and `Bimodal.Metalogic.Representation`
  - Added `no_finite_witness_implies_union_consistent` lemma
  - Filled the sorry in `infinitary_strong_completeness`

**Verification**:
- `lake build Bimodal.Metalogic.Completeness.InfinitaryStrongCompleteness` succeeds with no sorry warnings
- `lake build Bimodal.Metalogic.Compactness.Compactness` succeeds (depends on infinitary_strong_completeness)

---

### Phase 4: Verify Compactness Chain and Clean Up [COMPLETED]

**Goal**: Ensure the full compactness chain works and the build is clean.

**Tasks**:
- [x] Run `lake build` on the full project - SUCCESS (707 jobs)
- [x] Verify `Compactness.lean` still compiles (it depends on infinitary_strong_completeness) - SUCCESS
- [x] Add module documentation explaining the proof approach - DONE
- [x] Clean up any unused imports or helper lemmas - DONE (removed outdated comments)

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Compactness/Compactness.lean` - Verify/update docs
- Any files modified in earlier phases - Clean up

**Verification**:
- `lake build` succeeds with no errors
- No new sorries introduced
- Documentation reflects the algebraic proof approach

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `infinitary_strong_completeness` theorem has no `sorry`
- [ ] `compactness` and `compactness_iff` theorems work correctly
- [ ] All lemmas type-check with correct types
- [ ] No regressions in other modules

## Artifacts & Outputs

- Modified `AlgebraicRepresentation.lean` with bridge lemmas
- Modified `InfinitaryStrongCompleteness.lean` with completed proof
- Implementation summary at `specs/733_ultraproduct_based_compactness_proof/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If the algebraic approach encounters unexpected difficulties:
1. Preserve partial progress via git commits after each phase
2. The existing `sorry` can remain with enhanced documentation about what's needed
3. Alternative: mark specific sub-goals with `sorry` and document as separate follow-up tasks
4. Fallback to Approach B (direct ultraproduct) would require a new research phase
