# Implementation Plan: Task #472

- **Task**: 472 - Lindenbaum extension for finite closures
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Priority**: Medium
- **Dependencies**: None (builds on existing infrastructure)
- **Research Inputs**: .claude/specs/472_lindenbaum_extension_finite_closures/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implement the restricted Lindenbaum lemma for finite closures in `FiniteCanonicalModel.lean`. The standard Lindenbaum lemma (in `Completeness.lean`) extends consistent sets to maximal consistent sets over all formulas using Zorn's lemma. For the finite canonical model, we need a restricted version that extends consistent formula sets to maximal consistent sets within the finite subformula closure. This enables proving the existence axioms (`finite_forward_existence`, `finite_backward_existence`) and completing the truth lemma backward directions.

### Research Integration

From research-001.md:
- **Primary strategy**: Project full MCS from `set_lindenbaum` to closure (Strategy A)
- **Key insight**: Use `closureWithNeg` to ensure negation-completeness
- **Bridge requirement**: Connect `ClosureMaximalConsistent` to `IsLocallyConsistent`
- **Blocking items resolved**: Existence axioms, truth lemma backward directions (8 sorries)

## Goals & Non-Goals

**Goals**:
- Define `ClosureConsistent` and `ClosureMaximalConsistent` structures
- Prove `closure_lindenbaum`: extend consistent closure subsets to closure MCS
- Prove closure-restricted negation-completeness
- Bridge MCS to `IsLocallyConsistent` / `FiniteWorldState`
- Replace `finite_forward_existence` axiom with theorem
- Replace `finite_backward_existence` axiom with theorem
- Complete `finite_history_from_state` proof

**Non-Goals**:
- Implementing a fully constructive proof (classical reasoning acceptable)
- Completing truth lemma backward directions (separate task 449)
- Addressing compositionality gaps (separate task 473)
- Modifying `IsLocallyConsistent` definition

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| MCS projection loses maximality | High | Low | Verify projection preserves maximality for closure formulas |
| `closureWithNeg` not closed under derivation | Medium | Medium | Only use negation-completeness where explicit |
| Axiom replacement breaks dependent proofs | High | Low | Keep axiom signatures identical during replacement |
| Classical reasoning incompatible with constructive parts | Low | Low | Isolate classical proofs in separate lemmas |

## Implementation Phases

### Phase 1: Define Closure-Restricted Structures [NOT STARTED]

**Goal**: Define `ClosureConsistent` and `ClosureMaximalConsistent` predicates that capture consistency and maximality relative to a finite closure.

**Tasks**:
- [ ] Define `ClosureConsistent phi S` predicate (S subset of closure, consistent as set)
- [ ] Define `ClosureMaximalConsistent phi S` predicate (closure-consistent + maximal wrt adding closure formulas)
- [ ] Prove `closure_consistent_subset`: ClosureConsistent implies SetConsistent
- [ ] Prove basic properties (subset relations, consistency inheritance)
- [ ] Add properties for `closureWithNeg` (membership, negation availability)

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Add definitions after `closureWithNeg` (around line 370)

**Verification**:
- Definitions compile without error
- Basic properties provable (subset implies consistent)

---

### Phase 2: Prove Closure Lindenbaum via Projection [NOT STARTED]

**Goal**: Prove the closure-restricted Lindenbaum lemma using projection from full MCS.

**Tasks**:
- [ ] Import/reference `set_lindenbaum` from Completeness.lean if not already available
- [ ] Prove `closure_lindenbaum_via_projection`: given S subset of closure and consistent, exists M superset with ClosureMaximalConsistent
- [ ] Handle the projection step: M_full intersect closure phi
- [ ] Prove projection preserves consistency (subset of consistent)
- [ ] Prove projection is closure-maximal (any formula not in M_full contradicts maximality)

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Add theorem after Phase 1 definitions

**Verification**:
- `closure_lindenbaum_via_projection` compiles without sorry
- Can instantiate with concrete example (empty set extends to closure MCS)

---

### Phase 3: Prove Closure Negation-Completeness [NOT STARTED]

**Goal**: Prove that closure-maximal consistent sets satisfy negation-completeness for formulas whose negations are also in the closure.

**Tasks**:
- [ ] Prove `closure_mcs_negation_complete`: for psi in closure with neg psi in closure, either psi in S or neg psi in S
- [ ] Use maximality argument: if psi not in S, then S + {psi} is inconsistent
- [ ] Extract derivation: S derives neg psi (by deduction theorem pattern)
- [ ] Show neg psi in S by closure under derivation
- [ ] Add helper lemma `closureWithNeg_neg_mem`: for psi in closure phi, Formula.neg psi in closureWithNeg phi

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Add after closure_lindenbaum

**Verification**:
- `closure_mcs_negation_complete` compiles
- Can apply to specific formula cases (implications, boxes)

---

### Phase 4: Bridge to FiniteWorldState [NOT STARTED]

**Goal**: Connect closure-maximal consistent sets to `IsLocallyConsistent` and `FiniteWorldState`.

**Tasks**:
- [ ] Define `assignmentFromClosureMCS`: convert closure MCS to FiniteTruthAssignment
- [ ] Prove `closure_mcs_implies_locally_consistent`: ClosureMaximalConsistent implies IsLocallyConsistent
  - Bot is false (from consistency)
  - Implications respected (from closure under derivation)
  - T axiom (from derivability of T axiom)
  - Temporal reflexivity (from derivability)
- [ ] Define `worldStateFromClosureMCS`: construct FiniteWorldState from closure MCS
- [ ] Prove `worldStateFromClosureMCS_correct`: membership in MCS equals models predicate

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Add after negation-completeness lemmas

**Verification**:
- `worldStateFromClosureMCS` constructs valid FiniteWorldState
- No type errors in assignment construction

---

### Phase 5: Prove Existence Lemmas [NOT STARTED]

**Goal**: Replace the axioms `finite_forward_existence` and `finite_backward_existence` with proven theorems.

**Tasks**:
- [ ] Construct forward successor requirements set from `all_future` formulas
- [ ] Prove forward requirements set is consistent (from world state consistency)
- [ ] Apply `closure_lindenbaum` to extend to closure MCS
- [ ] Construct successor world state using `worldStateFromClosureMCS`
- [ ] Prove `finite_forward_existence` (replace axiom with theorem)
- [ ] Repeat for backward case with `all_past` formulas
- [ ] Prove `finite_backward_existence` (replace axiom with theorem)
- [ ] Remove axiom declarations (or mark as deprecated with proven versions)

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Replace axioms at lines 1097-1107

**Verification**:
- Both existence theorems compile without sorry
- `lean_diagnostic_messages` shows no axiom warnings
- Dependent code (`finite_history_from_state`) still compiles

---

### Phase 6: Complete History Construction [NOT STARTED]

**Goal**: Complete the `finite_history_from_state` proof using the proven existence lemmas.

**Tasks**:
- [ ] Implement recursive state construction: forward from origin to maxTime
- [ ] Implement recursive state construction: backward from origin to minTime
- [ ] Combine into states function on full FiniteTime domain
- [ ] Prove forward relation constraint using existence lemma witnesses
- [ ] Prove backward relation constraint using existence lemma witnesses
- [ ] Remove sorries in `finite_history_from_state`
- [ ] Verify compositionality across boundary (forward meets backward at origin)

**Timing**: 2 hours (moved from research estimate; may overlap with Phase 5)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Complete proof at lines 1119-1134

**Verification**:
- `finite_history_from_state` compiles without sorry
- Can construct history from any world state

---

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Metalogic.Completeness.FiniteCanonicalModel` succeeds
- [ ] `lean_diagnostic_messages` shows no errors in FiniteCanonicalModel.lean
- [ ] No remaining axioms (only theorems for existence)
- [ ] `finite_history_from_state` has no sorry
- [ ] Truth lemma sorries unchanged (Phase 5 of this task does not fill them)
- [ ] Existing imports and dependent code unbroken

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`
  - New definitions: `ClosureConsistent`, `ClosureMaximalConsistent`, `assignmentFromClosureMCS`, `worldStateFromClosureMCS`
  - New theorems: `closure_lindenbaum_via_projection`, `closure_mcs_negation_complete`, `closure_mcs_implies_locally_consistent`
  - Replaced axioms: `finite_forward_existence`, `finite_backward_existence` (now theorems)
  - Completed proof: `finite_history_from_state`
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If implementation fails:
1. Keep axioms `finite_forward_existence` and `finite_backward_existence` as fallback
2. New definitions can remain even if theorems incomplete (add sorry)
3. `finite_history_from_state` sorries can remain if existence proofs blocked
4. Git revert to pre-implementation state if fundamental issues found

Alternative approach if projection strategy fails:
- Switch to Strategy B (direct finite construction using `Finite.exists_le_maximal`)
- Requires more setup but avoids classical Zorn dependency
