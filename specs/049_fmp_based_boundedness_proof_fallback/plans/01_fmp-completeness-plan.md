# Implementation Plan: Task #49 - FMP-Based Completeness

- **Task**: 49 - fmp_based_boundedness_proof_fallback
- **Status**: [NOT STARTED]
- **Effort**: 11-15 hours
- **Dependencies**: None (independent of Task 48 SuccChain approach)
- **Research Inputs**: specs/049_fmp_based_boundedness_proof_fallback/reports/04_fmp-implementation-details.md
- **Artifacts**: plans/01_fmp-completeness-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Implement FMP-based completeness for TM bimodal logic as a complement to the algebraic approach (Task 48). The aim is to provide two independent completeness proofs plus their formal equivalence. This leverages the existing FMP infrastructure in `Theories/Bimodal/Metalogic/Decidability/FMP/` which is nearly complete with only 2 trivially-fixable sorries.

### Research Integration

From research report 04_fmp-implementation-details.md:
- Two sorries in TruthPreservation.lean are fixable with exact proof terms (Axiom.temp_t_future/temp_t_past)
- The "DEPRECATED" docstrings are incorrect - project uses reflexive semantics where T axioms are valid
- FMP provides a clean path to completeness bypassing SuccChain complexity
- Semantic bridge requires connecting filtered model truth to semantic validity

## Goals & Non-Goals

**Goals**:
- Fix the 2 remaining sorries in TruthPreservation.lean (making FMP infrastructure sorry-free)
- Establish semantic completeness via FMP: valid phi -> provable phi
- Prove FMP-algebraic equivalence theorem showing both approaches are formally equivalent
- Formalize decidability/computability result with PSPACE bound

**Non-Goals**:
- Replace or deprecate the algebraic approach (Task 48)
- Implement constructive decision procedure with verified extraction
- Prove PSPACE lower bound (only upper bound needed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Filtered model interpretation mismatch | H | M | Follow existing filteredMcsTruth structure |
| Extension lemma (closure MCS -> full MCS) is complex | M | H | May require Lindenbaum on remaining formulas |
| Fintype instance for ClosureMCSBundle blocks decidability | M | M | Use FilteredWorld.finite as base |
| Phase 3 takes longer than estimated | L | H | Phase 3 is lower priority, can be deferred |

## Implementation Phases

### Phase 1: Fix TruthPreservation Sorries [NOT STARTED]

**Goal**: Eliminate the 2 remaining sorries in TruthPreservation.lean, making the entire FMP infrastructure sorry-free.

**Tasks**:
- [ ] Replace `sorry` at line 263 (`mcs_all_future_closure`) with proof using `Axiom.temp_t_future`
- [ ] Replace `sorry` at line 281 (`mcs_all_past_closure`) with proof using `Axiom.temp_t_past`
- [ ] Update docstrings to remove incorrect "DEPRECATED" claims about strict temporal semantics
- [ ] Run `lake build` to verify FMP directory compiles without sorries

**Timing**: 15-20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean` - fix sorries and docstrings

**Verification**:
- `lake build` succeeds
- `grep -r "sorry" Theories/Bimodal/Metalogic/Decidability/FMP/` returns empty

---

### Phase 2: Semantic Completeness Bridge [NOT STARTED]

**Goal**: Prove that semantic validity implies provability via the FMP path.

**Tasks**:
- [ ] Define `filtered_model_interpretation : Atom -> FilteredWorld phi -> Prop`
- [ ] Prove `filtered_truth_lemma`: truth at filtered world matches MCS membership
- [ ] Show filtered frame satisfies TM frame conditions (reflexive temporal order, S5 accessibility)
- [ ] Prove `fmp_semantic_completeness`: `(forall D [constraints], valid_over D phi) -> Nonempty (DerivationTree [] phi)`
- [ ] Wire to existing `fmp_contrapositive` theorem

**Timing**: 3-5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/FMP/FMP.lean` - new theorems
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` - integration (if needed)

**Verification**:
- All new theorems compile without sorry
- `fmp_semantic_completeness` statement matches specification from research report

---

### Phase 3: FMP-Algebraic Equivalence [NOT STARTED]

**Goal**: Prove formal equivalence between FMP approach (closure MCS) and algebraic approach (ultrafilters).

**Tasks**:
- [ ] Prove `closure_mcs_extends_to_full_mcs`: closure MCS can be extended to full MCS
- [ ] Show `mcsToUltrafilter` restricted to closure formulas preserves membership
- [ ] Prove forward direction: all closure MCS contain phi -> all ultrafilters contain [phi]
- [ ] Prove backward direction: all ultrafilters contain [phi] -> all closure MCS contain phi
- [ ] Combine into `fmp_algebraic_equivalence` biconditional

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` - add equivalence section

**Verification**:
- `fmp_algebraic_equivalence` compiles without sorry
- Both directions have complete proofs

---

### Phase 4: Decidability Theorem [NOT STARTED]

**Goal**: Formalize that TM logic validity is decidable with explicit complexity bound.

**Tasks**:
- [ ] Prove `ClosureMCSBundle.fintype`: Fintype instance for ClosureMCSBundle phi
- [ ] Prove `fmp_decidability_constructive`: constructive decidability using Fintype
- [ ] Document complexity bound: PSPACE (2^|closure|)
- [ ] Add `fmp_size_bound` theorem stating explicit bound

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` - decidability theorems
- `Theories/Bimodal/Metalogic/Decidability/FMP/FiniteModel.lean` - Fintype instance (if not in Correctness)

**Verification**:
- `fmp_decidability_constructive` compiles without sorry
- Fintype instance is computable (not classical)

---

### Phase 5: Integration and Verification [NOT STARTED]

**Goal**: Ensure all new theorems integrate properly and the codebase is clean.

**Tasks**:
- [ ] Run `lake build` for full project
- [ ] Verify no new sorries introduced: `grep -rn "sorry" Theories/`
- [ ] Verify all FMP files import correctly in dependent modules
- [ ] Update any export statements in module files if needed
- [ ] Create implementation summary

**Timing**: 1-2 hours

**Files to modify**:
- Various import statements if needed
- `Theories/Bimodal.lean` or similar module root (if export changes needed)

**Verification**:
- Clean `lake build` with no errors or warnings
- Sorry count unchanged or reduced from baseline
- All new theorems accessible from main module

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Decidability/FMP/` returns empty after Phase 1
- [ ] New theorems match specifications from research report
- [ ] No regressions in existing functionality

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean` - fixed sorries
- `Theories/Bimodal/Metalogic/Decidability/FMP/FMP.lean` - semantic completeness theorems
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` - FMP-algebraic equivalence
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` - decidability theorems
- `specs/049_fmp_based_boundedness_proof_fallback/summaries/01_fmp-completeness-summary.md` - execution summary

## Rollback/Contingency

If implementation encounters fundamental obstacles:
1. Keep Phase 1 fixes (trivially correct, no risk)
2. Phase 2-4 changes can be reverted by git reset to pre-implementation commit
3. FMP infrastructure remains functional without new theorems
4. Task 48 algebraic approach provides alternative completeness path
