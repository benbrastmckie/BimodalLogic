# Implementation Plan: Task #733

- **Task**: 733 - ultraproduct_based_compactness_proof
- **Status**: [NOT STARTED]
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

### Phase 1: Bridge Algebraic and Semantic Satisfiability [NOT STARTED]

**Goal**: Create a lemma connecting `AlgSatisfiable` to `set_satisfiable`, establishing that if a formula has an ultrafilter containing it, then it has a semantic model.

**Tasks**:
- [ ] Read existing canonical model construction from FiniteStrongCompleteness
- [ ] Create `alg_satisfiable_implies_set_satisfiable` lemma
- [ ] This requires: from ultrafilter U with [phi] in U, construct MCS via `ultrafilterToSet`, then use canonical model from that MCS

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicRepresentation.lean` - Add bridge lemma

**Verification**:
- New lemma type-checks with no sorries
- `lake build Bimodal.Metalogic.Algebraic.AlgebraicRepresentation` succeeds

---

### Phase 2: Prove Set Consistency Implies Satisfiability [NOT STARTED]

**Goal**: Prove that if a set Gamma is set-consistent (every finite subset is consistent), then Gamma is satisfiable.

**Tasks**:
- [ ] Create `set_consistent_implies_satisfiable` lemma in a new or existing file
- [ ] Use Lindenbaum's lemma: extend consistent set to MCS
- [ ] Connect MCS to ultrafilter, then to model via Phase 1's bridge
- [ ] Handle the case where Gamma is infinite by using the existing Lindenbaum extension for sets

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicRepresentation.lean` or
- `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean` - Add set-level consistency lemma

**Verification**:
- Lemma compiles without sorries
- Connects to existing `set_consistent` definition

---

### Phase 3: Fill infinitary_strong_completeness Sorry [NOT STARTED]

**Goal**: Complete the main theorem by proving that semantic consequence from an infinite set has a finite derivation witness.

**Tasks**:
- [ ] Analyze the proof strategy: contraposition approach
  - If no finite Delta subset of Gamma derives phi, then for each finite Delta, Delta union {neg phi} is consistent
  - By compactness, Gamma union {neg phi} is satisfiable
  - This contradicts Gamma |= phi
- [ ] Implement the contrapositive proof using set_consistent_implies_satisfiable
- [ ] Connect to finite strong completeness for the case when a witness exists

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean` - Fill sorry at line 175

**Verification**:
- `infinitary_strong_completeness` compiles without `sorry`
- `lake build Bimodal.Metalogic.Completeness.InfinitaryStrongCompleteness` succeeds

---

### Phase 4: Verify Compactness Chain and Clean Up [NOT STARTED]

**Goal**: Ensure the full compactness chain works and the build is clean.

**Tasks**:
- [ ] Run `lake build` on the full project
- [ ] Verify `Compactness.lean` still compiles (it depends on infinitary_strong_completeness)
- [ ] Add module documentation explaining the proof approach
- [ ] Clean up any unused imports or helper lemmas

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
