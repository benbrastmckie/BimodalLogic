# Implementation Plan: Task #556

- **Task**: 556 - Complete Metalogic_v2 Implementation
- **Status**: [NOT STARTED]
- **Effort**: 8-10 hours
- **Priority**: High
- **Dependencies**: 554 (completed)
- **Research Inputs**: specs/556_complete_metalogic_v2_implementation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Complete the Metalogic_v2 implementation by resolving all 11 sorry placeholders and 1 axiom across the directory. The architecture follows a representation-first approach where the Finite Model Property (FMP) serves as the central bridge. The critical path runs through MCS properties to the TruthLemma to the RepresentationTheorem and finally to completeness. Once complete, Metalogic_v2 will be a self-sufficient replacement for the original Metalogic directory.

### Research Integration

Key findings from research-001.md:
- 11 sorries identified across 7 files, plus 1 axiom in ContextProvability.lean
- Critical blocking chain: mcs_contains_or_neg -> mcs_modus_ponens -> TruthLemma -> consistent_implies_satisfiable -> axiom elimination
- Proven infrastructure available: DeductionTheorem, MaximalConsistent (list-based), Soundness, representation_theorem
- List-based `maximal_negation_complete` is proven and can guide set-based `mcs_contains_or_neg`

## Goals & Non-Goals

**Goals**:
- Eliminate all 11 sorry placeholders in Metalogic_v2
- Replace the `representation_theorem_backward_empty` axiom with a theorem
- Ensure `lake build Bimodal.Metalogic_v2` compiles with zero sorries
- Update README.md to reflect completion status

**Non-Goals**:
- Modifying the existing architecture or file organization
- Optimizing proof performance (focus is on correctness)
- Deprecating or removing the original Metalogic directory (separate task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| MCS properties harder than expected | High | Medium | Adapt existing list-based `maximal_negation_complete` proof from MaximalConsistent.lean |
| Semantic bridge requires model construction | Medium | Medium | Use completeness contrapositive instead of constructing concrete TaskModel |
| Axiom elimination requires additional infrastructure | High | Low | TruthLemma is trivial by definition; RepresentationTheorem already proven |
| Strong completeness helpers complex | Low | Medium | Treat as lower priority; main completeness path does not depend on these |
| Build failures due to import cycles | Medium | Low | Strict layering already enforced by existing architecture |

## Implementation Phases

### Phase 1: MCS Property Completion [NOT STARTED]

**Goal**: Prove the two critical MCS properties that are blocking downstream theorems.

**Tasks**:
- [ ] Prove `mcs_contains_or_neg` in Representation/CanonicalModel.lean (line 192)
  - Adapt proof from list-based `maximal_negation_complete` in MaximalConsistent.lean
  - Key insight: If phi not in S and neg phi not in S, both extensions are inconsistent, leading to contradiction
- [ ] Prove `mcs_modus_ponens` in Representation/CanonicalModel.lean (line 209)
  - Use `mcs_contains_or_neg` to get psi in S or neg psi in S
  - If neg psi in S with phi in S and (phi -> psi) in S, derive contradiction

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` - lines 192, 209

**Verification**:
- `lake build Bimodal.Metalogic_v2.Representation.CanonicalModel` succeeds with no sorries in target functions
- Check with `lean_diagnostic_messages` that no errors remain

---

### Phase 2: Bridge to Semantic Satisfiability [NOT STARTED]

**Goal**: Complete the bridge from canonical world representation to semantic satisfiability.

**Tasks**:
- [ ] Prove `consistent_implies_satisfiable` in Representation/FiniteModelProperty.lean (line 162)
  - From canonical world w, need to demonstrate formula_satisfiable phi
  - Strategy: Use soundness contrapositive - if consistent, cannot prove contradiction, so must have model
- [ ] Prove `subformulaList_finite` in Representation/FiniteModelProperty.lean (line 81)
  - Straightforward structural induction on Formula
  - Bound subformula list size by 2^complexity + 1

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` - lines 81, 162

**Verification**:
- `lake build Bimodal.Metalogic_v2.Representation.FiniteModelProperty` succeeds
- Sorries in target theorems resolved

---

### Phase 3: Strong Completeness Helpers [NOT STARTED]

**Goal**: Complete the helper lemmas for strong completeness.

**Tasks**:
- [ ] Prove `entails_imp_chain` helper in Completeness/StrongCompleteness.lean (line 82)
  - Semantic reasoning: if all of Gamma are true and phi -> psi is true, then psi is true when phi is true
- [ ] Prove `imp_chain_to_context` helper in Completeness/StrongCompleteness.lean (line 114)
  - Recursive application of modus ponens
  - If [] derives psi1 -> ... -> psin -> phi and each psi_i in Gamma, apply MP n times
- [ ] Prove double negation elimination in RepresentationTheorem.lean (line 151)
  - Use Peirce's law in TM proof system
- [ ] Prove canonical world contradiction in RepresentationTheorem.lean (line 159)
  - Connect validity to MCS membership via truth lemma

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Completeness/StrongCompleteness.lean` - lines 82, 114
- `Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean` - lines 151, 159

**Verification**:
- `lake build Bimodal.Metalogic_v2.Completeness.StrongCompleteness` succeeds
- `lake build Bimodal.Metalogic_v2.Representation.RepresentationTheorem` succeeds

---

### Phase 4: Axiom Elimination [NOT STARTED]

**Goal**: Replace the `representation_theorem_backward_empty` axiom with a proven theorem.

**Tasks**:
- [ ] Convert axiom to theorem in Representation/ContextProvability.lean (line 83)
  - Proof strategy:
    1. Assume semantic_consequence [] phi (validity)
    2. By contrapositive: if not provable, then [neg phi] is consistent
    3. By representation_theorem, [neg phi] has canonical world w with neg phi true
    4. Connect to semantic model to show phi not valid, contradiction
- [ ] Verify all downstream theorems still compile
  - WeakCompleteness.lean uses this transitively
  - Check provable_iff_valid and weak_completeness compile

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - line 83

**Verification**:
- `lake build Bimodal.Metalogic_v2.Representation.ContextProvability` succeeds with no axioms
- `lake build Bimodal.Metalogic_v2.Completeness.WeakCompleteness` succeeds
- Grep for `axiom` in Metalogic_v2 returns no results

---

### Phase 5: Cleanup and Documentation [NOT STARTED]

**Goal**: Resolve remaining minor sorries and update documentation.

**Tasks**:
- [ ] Prove `consistent_iff_consistent'` in Core/Basic.lean (line 56)
  - Equivalence between "exists unprovable formula" and "cannot prove false"
  - Requires ex-falso axiom integration
- [ ] Prove `necessitation_lemma` in Representation/TruthLemma.lean (line 160)
  - If [] derives phi then (box phi) in every MCS
  - Uses deductive closure of MCS and necessitation rule
- [ ] Update README.md with accurate completion status
  - Update sorry count per file (should be zero)
  - Add completion confirmation
  - Remove outdated "With Sorries" sections
- [ ] Run full build verification

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Core/Basic.lean` - line 56
- `Theories/Bimodal/Metalogic_v2/Representation/TruthLemma.lean` - line 160
- `Theories/Bimodal/Metalogic_v2/README.md`

**Verification**:
- `lake build Bimodal.Metalogic_v2` succeeds with zero sorries
- `grep -r "sorry" Theories/Bimodal/Metalogic_v2/` returns no results
- `grep -r "axiom" Theories/Bimodal/Metalogic_v2/` returns no project-specific axioms

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic_v2` compiles successfully
- [ ] No `sorry` placeholders remain in any .lean file
- [ ] No project-specific `axiom` declarations remain (only Lean/Mathlib axioms)
- [ ] Each phase builds incrementally without regressions
- [ ] README.md accurately reflects the implementation status

## Artifacts & Outputs

- `specs/556_complete_metalogic_v2_implementation/plans/implementation-001.md` (this file)
- `specs/556_complete_metalogic_v2_implementation/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified files:
  - `Theories/Bimodal/Metalogic_v2/Core/Basic.lean`
  - `Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean`
  - `Theories/Bimodal/Metalogic_v2/Representation/TruthLemma.lean`
  - `Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean`
  - `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean`
  - `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean`
  - `Theories/Bimodal/Metalogic_v2/Completeness/StrongCompleteness.lean`
  - `Theories/Bimodal/Metalogic_v2/README.md`

## Rollback/Contingency

If implementation fails:
1. Git revert to pre-implementation commit
2. All original sorry placeholders and axiom remain functional
3. Partial progress can be preserved by leaving some sorries if critical path is blocked
4. If Phase 1 MCS properties cannot be proven, explore alternative formulations:
   - Consider using Decidable instances instead of classical logic
   - Explore Mathlib's existing MCS infrastructure
