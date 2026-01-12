# Implementation Plan: Prove Lindenbaum Maximal Consistency Lemma

- **Task**: 132 - Prove Lindenbaum maximal consistency lemma in Completeness.lean
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Priority**: Low
- **Dependencies**: None (can be developed independently)
- **Research Inputs**: .claude/specs/132_prove_lindenbaum_maximal_consistency_lemma_in_completeness/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implement the Lindenbaum lemma proof in `Theories/Bimodal/Metalogic/Completeness.lean`, replacing the current axiom placeholder at lines 117-118. The proof uses Zorn's lemma from Mathlib to extend consistent sets to maximal consistent sets. The key challenge is proving that unions of chains of consistent sets remain consistent, which requires establishing that derivations use only finitely many context formulas.

### Research Integration

From research-001.md:
- Use `zorn_le_nonempty0` from `Mathlib.Order.Zorn` as primary approach
- Work with `Set Formula` internally rather than `List Formula` for cleaner Zorn application
- Critical lemma: `deriv_uses_finite_context` - derivations use finite context subsets
- Critical lemma: `consistent_union_chain` - chain unions preserve consistency
- Estimated complexity revised from 3 hours to 14-19 hours based on Zorn application complexity

## Goals & Non-Goals

**Goals**:
- Remove the `axiom lindenbaum` placeholder and replace with a proven theorem
- Implement required supporting lemmas for the Zorn's lemma application
- Maintain compatibility with existing `Consistent` and `MaximalConsistent` definitions
- Ensure the proof compiles without `sorry` statements

**Non-Goals**:
- Proving `maximal_consistent_closed` and `maximal_negation_complete` (separate axioms)
- Modifying the `DerivationTree` type or proof system
- Implementing the full completeness proof (tasks 133-135, 257)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Zorn's lemma application complexity | H | M | Use simpler `zorn_le_nonempty0` variant; consult Mathlib examples |
| Context representation mismatch (List vs Set) | M | H | Define explicit conversion functions; use Set internally |
| Proving finiteness of derivations | H | M | Structural induction on DerivationTree; may need auxiliary definitions |
| Mathlib version compatibility | M | L | Check Mathlib imports; use stable API patterns |
| Interaction with existing axioms | M | L | Test that lindenbaum theorem type matches axiom signature exactly |

## Implementation Phases

### Phase 1: Infrastructure and Imports [NOT STARTED]

**Goal**: Set up the necessary imports and define helper structures for working with consistent set extensions.

**Tasks**:
- [ ] Add required Mathlib imports for Zorn's lemma (`Mathlib.Order.Zorn`, `Mathlib.Order.Max`)
- [ ] Define `ConsistentExtensions` type representing the set of consistent extensions of a context
- [ ] Define preorder instance on contexts (subset inclusion)
- [ ] Verify imports compile without errors

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add imports and infrastructure

**Verification**:
- `lake build Bimodal.Metalogic.Completeness` compiles
- `lean_diagnostic_messages` shows no errors on new definitions

---

### Phase 2: Finite Context Usage Lemma [NOT STARTED]

**Goal**: Prove that any derivation uses only finitely many formulas from its context.

**Tasks**:
- [ ] Define `formulas_used : DerivationTree Gamma phi -> Finset Formula` by structural recursion
- [ ] Prove `formulas_used_subset : formulas_used d subset Gamma.toFinset`
- [ ] Prove `deriv_from_finite_subset : exists Gamma' subset Gamma, Finite Gamma' and DerivationTree Gamma' phi`
- [ ] Add helper lemmas for DerivationTree case analysis

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add finiteness lemmas

**Verification**:
- All lemmas compile without `sorry`
- `lean_goal` confirms proof states are resolved

---

### Phase 3: Chain Union Consistency Lemma [NOT STARTED]

**Goal**: Prove that unions of chains of consistent sets are consistent.

**Tasks**:
- [ ] Define `chain_union : Set (Set Formula) -> Set Formula` for taking unions of chains
- [ ] Prove `finite_subset_in_chain_member` - any finite subset of chain union is in some chain member
- [ ] Prove `consistent_union_chain` - if all chain members consistent, union is consistent
- [ ] Connect proof to finite context usage lemma from Phase 2

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add chain lemmas

**Verification**:
- All lemmas compile without `sorry`
- Chain property lemmas satisfy Zorn's lemma prerequisites

---

### Phase 4: Zorn's Lemma Application [NOT STARTED]

**Goal**: Apply Zorn's lemma to obtain maximal consistent extensions.

**Tasks**:
- [ ] Define the set `S = {Delta | Gamma subset Delta and Consistent Delta}` (ConsistentExtensions)
- [ ] Prove `nonempty_S : Gamma in S` (input hypothesis)
- [ ] Prove `chain_bounded_in_S : IsChain le c -> c subset S -> exists ub in S, forall x in c, x le ub`
- [ ] Apply `zorn_le_nonempty0` to obtain maximal element
- [ ] Convert maximal-in-S to MaximalConsistent definition

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Zorn application

**Verification**:
- `zorn_le_nonempty0` application compiles
- Result matches `MaximalConsistent` definition

---

### Phase 5: Final Theorem and Cleanup [NOT STARTED]

**Goal**: Complete the lindenbaum theorem proof and replace the axiom.

**Tasks**:
- [ ] Prove `lindenbaum` theorem matching the axiom signature exactly
- [ ] Remove or comment out the axiom declaration
- [ ] Verify dependent code still compiles (weak_completeness, strong_completeness references)
- [ ] Add documentation comments explaining the proof structure
- [ ] Clean up any temporary helper definitions

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Final theorem and cleanup

**Verification**:
- `lake build Bimodal.Metalogic.Completeness` succeeds
- No `sorry` in lindenbaum proof
- Type signature matches exactly: `(Gamma : Context) (h : Consistent Gamma) : exists Delta : Context, (forall phi, phi in Gamma -> phi in Delta) and MaximalConsistent Delta`

---

## Testing & Validation

- [ ] `lake build` succeeds for entire project
- [ ] `lean_diagnostic_messages` shows no errors in Completeness.lean
- [ ] Lindenbaum theorem type matches original axiom signature
- [ ] All supporting lemmas compile without `sorry`
- [ ] Downstream axioms (weak_completeness, strong_completeness) still reference lindenbaum correctly

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Completeness.lean` - Modified with proven lindenbaum theorem
- `.claude/specs/132_prove_lindenbaum_maximal_consistency_lemma_in_completeness/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation fails or introduces regressions:
1. The original axiom can be restored from git history
2. Partial progress (supporting lemmas) can remain as separate theorems
3. If Zorn application proves too complex, consider alternative approaches:
   - Direct induction on enumeration of formulas (requires decidable Formula type)
   - Constructive maximal extension using choice functions

## Notes

- The research report revised the effort estimate from 3 hours to 14-19 hours due to Zorn complexity
- This plan estimates 16 hours total, within the research-revised range
- Tasks 133-135 depend on this task but can proceed once lindenbaum is proven
- The proof follows the standard textbook approach (Blackburn et al., Chapter 4)
