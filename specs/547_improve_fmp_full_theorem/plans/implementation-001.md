# Implementation Plan: Task #547

- **Task**: 547 - Improve FMP Full Theorem
- **Status**: [NOT STARTED]
- **Effort**: 4-5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/547_improve_fmp_full_theorem/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan addresses proving the full Finite Model Property (FMP) theorem for TM bimodal logic. The current implementation has a proven core (`semantic_weak_completeness`) but gaps in the full theorem statement and several build errors blocking progress. The approach uses the contrapositive of `semantic_weak_completeness` to establish FMP, leveraging existing proven infrastructure rather than implementing classical filtration from scratch.

### Research Integration

Key findings from research-001.md integrated into this plan:
- `semantic_weak_completeness` is proven (lines 3317-3386) and can be leveraged via contrapositive
- 22+ build errors in FiniteCanonicalModel.lean must be fixed first (missing `backward_rel` field, unknown constants, type mismatches)
- Bridge lemmas needed: `satisfiable_implies_not_refutable` and `semantic_satisfiable_implies_formula_satisfiable`
- Contrapositive approach is simpler than filtration (already-proven infrastructure vs. new `filtration_preserves_truth` lemma)

## Goals & Non-Goals

**Goals**:
- Fix all build errors in FiniteCanonicalModel.lean to enable further development
- Prove `finite_model_property_v2` theorem (currently has sorry placeholder)
- Establish bridge between `formula_satisfiable` and `SemanticCanonicalModel`
- Prove key lemma `satisfiable_implies_not_refutable`

**Non-Goals**:
- Proving `Fintype` instance for `SemanticWorldState` (deferred to future task)
- Implementing classical filtration approach (using contrapositive instead)
- Proving decidability of satisfiability (separate concern)
- Optimizing existing proven lemmas

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Build errors more complex than identified | High | Medium | Start with simplest errors; use `sorry` temporarily if blocked on specific lemmas |
| Time arithmetic proofs fragile with omega | Medium | High | Use `decide` for bounded cases; add explicit coercions for Int/Nat conversions |
| Bridge lemma proofs require deep induction | Medium | Medium | Leverage existing truth lemma proofs as templates; use `semantic_weak_completeness` structure |
| SetConsistent.exists_false_derivation missing | High | High | Define locally or find alternative approach using existing consistency lemmas |

## Implementation Phases

### Phase 1: Fix Build Errors - Structure Fields [IN PROGRESS]

**Goal**: Resolve missing field errors to get FiniteCanonicalModel.lean partially compiling

**Tasks**:
- [ ] Fix `FiniteHistory.time_shift` (line ~1821): Add missing `backward_rel` field
- [ ] Verify `FiniteHistory` structure has all required fields after fix
- [ ] Run `lake build` to confirm these errors resolved

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Add missing structure fields

**Verification**:
- `lean_diagnostic_messages` shows reduction in "missing field" errors
- Structure definitions compile without field-related errors

---

### Phase 2: Fix Build Errors - Unknown Constants [NOT STARTED]

**Goal**: Resolve unknown constant references

**Tasks**:
- [ ] Investigate `SetConsistent.exists_false_derivation` (lines 3025, 3081)
- [ ] Either: (a) add missing lemma to SetConsistent namespace, or (b) refactor to use alternative consistency lemmas
- [ ] Fix any other unknown constant errors revealed after Phase 1

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Add/fix constant references
- Potentially `Theories/Bimodal/Metalogic/Completeness.lean` - If SetConsistent needs extension

**Verification**:
- `lean_diagnostic_messages` shows no "unknown constant" errors
- File compiles past the affected lines

---

### Phase 3: Fix Build Errors - Type Mismatches and Proofs [NOT STARTED]

**Goal**: Resolve remaining type mismatches and unsolved goal errors

**Tasks**:
- [ ] Fix `finiteHistoryToWorldHistory.respects_task` (line 3467): Resolve unsolved goals in time arithmetic
- [ ] Fix `semantic_world_state_has_world_history` (line 3556-3577): Repair type mismatches
- [ ] Address omega/simp failures in time arithmetic proofs with explicit tactics
- [ ] Run full `lake build` to verify file compiles

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Fix type mismatches and proof obligations

**Verification**:
- `lake build` succeeds for FiniteCanonicalModel.lean
- `lean_diagnostic_messages` returns no errors for the file

---

### Phase 4: Prove Bridge Lemma - satisfiable_implies_not_refutable [NOT STARTED]

**Goal**: Prove the key bridge lemma connecting satisfiability to non-derivability

**Tasks**:
- [ ] Define lemma signature: `theorem satisfiable_implies_not_refutable (phi : Formula) : formula_satisfiable phi -> not (Nonempty (deriv (neg phi)))`
- [ ] Proof strategy: Use soundness - if `neg phi` derivable, then valid, contradicting satisfiability of `phi`
- [ ] Verify lemma type-checks with the existing Soundness infrastructure
- [ ] Complete the proof using soundness and validity definitions

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Add bridge lemma near FMP theorem

**Verification**:
- Lemma compiles without sorry
- `lean_goal` shows no unsolved goals after proof

---

### Phase 5: Prove finite_model_property_v2 [NOT STARTED]

**Goal**: Replace the sorry in `finite_model_property_v2` with a complete proof

**Tasks**:
- [ ] Use `satisfiable_implies_not_refutable` to show `phi` is consistent (not refutable)
- [ ] Apply contrapositive of `semantic_weak_completeness` to get SemanticWorldState witness
- [ ] Bridge SemanticCanonicalModel witness to FiniteTaskFrame existence
- [ ] Construct required witnesses: `FiniteTaskFrame Int`, `TaskModel`, `WorldHistory`, time point
- [ ] Complete the proof showing `truth_at M tau t phi`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Complete FMP theorem proof

**Verification**:
- `finite_model_property_v2` compiles without sorry
- `lean_diagnostic_messages` shows no errors for theorem
- Full file builds successfully with `lake build`

---

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Metalogic.Completeness.FiniteCanonicalModel` succeeds
- [ ] No sorry placeholders remain in FMP-related theorems
- [ ] `lean_diagnostic_messages` returns empty for FiniteCanonicalModel.lean
- [ ] Verify `semantic_weak_completeness` is still valid after changes
- [ ] Spot-check related imports still compile (Completeness.lean parent module)

## Artifacts & Outputs

- `specs/547_improve_fmp_full_theorem/plans/implementation-001.md` (this file)
- Modified `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` with:
  - Fixed build errors (Phases 1-3)
  - New `satisfiable_implies_not_refutable` lemma (Phase 4)
  - Completed `finite_model_property_v2` proof (Phase 5)
- `specs/547_improve_fmp_full_theorem/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

- Git stash or branch before starting implementation
- If Phase 1-3 fixes break other proofs, use `sorry` temporarily to isolate changes
- If FMP proof blocked on missing infrastructure, document gap and create follow-up task
- Preserve working `semantic_weak_completeness` - never modify its proof body
- If time exceeded, mark completed phases and create follow-up task for remaining phases
