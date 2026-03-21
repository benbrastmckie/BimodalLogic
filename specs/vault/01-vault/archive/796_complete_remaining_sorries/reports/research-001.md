# Research Report: Task #796

**Task**: Complete Remaining Sorries
**Date**: 2026-02-01
**Focus**: Comprehensive survey and categorization of remaining sorries in active codebase

## Summary

After analyzing the codebase and the task 794 implementation summary, the remaining sorries fall into distinct categories: **semantic validity issues** (4 sorries), **architectural limitations** (12 sorries), **proof infrastructure gaps** (17 sorries), and **technical proofs** (15+ sorries). The key completeness theorems are already sorry-free; the remaining sorries are in supporting infrastructure that is either documented as "NOT REQUIRED FOR COMPLETENESS" or requires fundamental architectural changes.

## Findings

### Category 1: Semantic Validity Issues (4 sorries) - FUNDAMENTAL

**Location**: `Theories/Bimodal/Metalogic/Soundness.lean` (lines 663, 682) and `SoundnessLemmas.lean` (lines 833, 844)

**Nature**: The `temp_t_future` (Gφ → φ) and `temp_t_past` (Hφ → φ) axioms are NOT semantically valid with strict inequality semantics:
- `all_future` quantifies over s > t (strictly future)
- `all_past` quantifies over s < t (strictly past)
- Cannot derive φ at t from φ at all s > t (or s < t) for discrete time like ℤ

**Resolution Options**:
1. Remove temp_t axioms and fix completeness differently
2. Change semantics to reflexive temporal operators (s ≥ t, s ≤ t)
3. Document as known limitation (current approach)

**Difficulty**: High - Requires architectural decision on semantics vs. axiom design
**Impact**: Medium - Soundness proofs technically incomplete, but completeness theorems unaffected

### Category 2: Omega-Rule Limitation (6 sorries) - FUNDAMENTAL

**Locations**:
- `TruthLemma.lean` (lines 435, 459): backward temporal cases
- `TemporalCompleteness.lean` (lines 123, 141): H/G-completeness lemmas

**Nature**: Proving `(∀ s < t, φ ∈ mcs(s)) → Hφ ∈ mcs(t)` requires deriving Hφ from infinitely many φ instances (omega-rule). TM logic lacks this inference rule.

**Why Documented as Non-Blocking**:
- The representation theorem only uses `truth_lemma_forward`
- Backward direction is NOT REQUIRED FOR COMPLETENESS
- These sorries are explicitly documented with detailed explanations

**Resolution Options**:
1. Add H/G-completeness as axioms to IndexedMCSFamily
2. Prove for specific constructions (CoherentConstruction over ℤ)
3. Use finite domain restriction where omega becomes finite conjunction

**Difficulty**: Very High - Fundamental logical limitation
**Impact**: Low - Completeness proofs do not depend on these

### Category 3: Box Case Architectural Limitations (4 sorries)

**Location**: `TruthLemma.lean` (lines 383, 406)

**Nature**: Box (□) semantics quantifies over ALL histories, but MCS membership only captures behavior on the CANONICAL history. Cannot derive:
- Forward: □ψ ∈ mcs → ∀ σ, truth_at σ t ψ
- Backward: (∀ σ, truth_at σ t ψ) → □ψ ∈ mcs

**Why Non-Blocking**: Box cases are NOT critical for the main representation theorem (Task 654), which only needs temporal operators (G/H).

**Difficulty**: High - Requires semantic architecture changes
**Impact**: Low - Main completeness theorems unaffected

### Category 4: Coherent Construction Infrastructure (11 sorries)

**Locations**:
- `CoherentConstruction.lean` (lines 405, 418, 656, 659, 667, 670, 688, 695, 743, 746)
- `IndexedMCSFamily.lean` (lines 636, 643, 650, 657)

**Nature**: The coherent construction sorries relate to:
1. **Forward/backward seed consistency**: Proving `forward_seed S` is consistent when S is MCS (2 sorries)
2. **Coherence conditions**: SUPERSEDED by `construct_coherent_family` in CoherentConstruction.lean (4 sorries)
3. **Cross-origin coherence cases**: Various temporal propagation proofs

**Status**: Many are marked "SUPERSEDED" - the IndexedMCSFamily sorries are intentionally left because `construct_indexed_family` is deprecated in favor of `construct_coherent_family`.

**Difficulty**: Medium - Inductive infrastructure needed
**Impact**: Medium - Active code paths

### Category 5: MCS Property Proofs (4 sorries)

**Locations**:
- `CanonicalWorld.lean` (lines 116, 163): negation completeness and deductive closure
- `UniversalCanonicalModel.lean` (lines 84, 86): G⊥ ∉ Gamma and H⊥ ∉ Gamma proofs

**Nature**: Standard MCS properties that need adaptation from list-based to set-based representations:
- `negation_complete`: φ ∈ mcs ∨ ¬φ ∈ mcs
- `deductively_closed`: finite derivation closure
- G⊥/H⊥ absence: proving these cannot be in consistent MCS

**Difficulty**: Medium - Requires careful set-theoretic adaptation of existing list proofs
**Impact**: Medium - Required for full representation theorem

### Category 6: Task Relation Compositionality (5 sorries)

**Location**: `TaskRelation.lean` (lines 151, 164, 168, 174, 177)

**Nature**: Proving that canonical task relation composes (transitivity). Requires careful case analysis on signs of durations d1, d2.

**Difficulty**: Medium - Case analysis on integer signs
**Impact**: Low-Medium - Supporting infrastructure

### Category 7: CanonicalHistory T-Axiom Applications (2 sorries)

**Location**: `CanonicalHistory.lean` (lines 136, 139)

**Nature**: Applying T-axioms (Gφ → φ, Hφ → φ) within canonical history construction.

**Difficulty**: Low-Medium - Direct axiom application
**Impact**: Low - Supporting infrastructure

### Category 8: Decidability Module (6 sorries)

**Locations**:
- `Decidability/Correctness.lean` (lines 77, 88, 172): Tableau completeness
- `Decidability/Saturation.lean` (line 221): Expansion measure
- `Decidability/Closure.lean` (lines 185, 195): Technical findSome? lemmas

**Nature**: These require:
- Finite Model Property proof
- Tableau completeness relative to FMP
- Technical lemmas about formula complexity measures

**Difficulty**: High - Deep logical infrastructure
**Impact**: Low - Decidability is separate from completeness

### Category 9: FiniteCanonicalModel (50+ sorries)

**Location**: `Completeness/FiniteCanonicalModel.lean`

**Nature**: This file has extensive sorries in:
- Backward truth lemma directions
- Compositionality for mixed-sign durations
- Bridge lemmas connecting different canonical model representations
- Deduction theorem infrastructure

**Why Non-Blocking**: The main completeness is achieved via `semantic_weak_completeness` in `FMP/SemanticCanonicalModel.lean`, which is SORRY-FREE. FiniteCanonicalModel provides an alternative approach that is less mature.

**Difficulty**: High - Complex multi-part proofs
**Impact**: Very Low - Alternative approach, not the primary path

### Category 10: Logos Module (1 active sorry)

**Location**: `Logos/SubTheories/Dynamics/Truth.lean` (line 176)

**Nature**: Counterfactual causation semantics (○→) placeholder. Requires Task 394 implementation with:
- Context parameters ⟨time_cause, time_effect, background⟩
- Subevolution structure
- Difference-making counterfactuals

**Difficulty**: High - Novel semantics design
**Impact**: Low - Isolated module

## Sorry Count Summary

| Category | Location | Count | Priority | Status |
|----------|----------|-------|----------|--------|
| Semantic Validity | Soundness*.lean | 4 | Low | Documented limitation |
| Omega-Rule | TruthLemma, TemporalCompleteness | 6 | Low | NOT REQUIRED FOR COMPLETENESS |
| Box Case | TruthLemma.lean | 4 | Low | NOT REQUIRED |
| Coherent Construction | CoherentConstruction, IndexedMCSFamily | 15 | Medium | Partially SUPERSEDED |
| MCS Properties | CanonicalWorld, UniversalCanonicalModel | 6 | Medium | Needed for representation |
| Task Relation | TaskRelation.lean | 5 | Low | Supporting infrastructure |
| Canonical History | CanonicalHistory.lean | 2 | Low | T-axiom applications |
| Decidability | Decidability/*.lean | 6 | Low | Separate from completeness |
| FiniteCanonicalModel | FiniteCanonicalModel.lean | 50+ | Very Low | Alternative approach |
| Logos | Dynamics/Truth.lean | 1 | Low | Novel semantics |

**Total in Active Code (excluding Boneyard/Examples)**: ~99 sorries
**Sorries blocking main completeness**: 0 (key theorems are sorry-free per task 794)

## Recommendations

### Immediate Priority (Address First)

1. **MCS Property Proofs (CanonicalWorld.lean)**: These are relatively straightforward adaptations of existing list-based proofs. Completing them would strengthen the representation theorem foundation.
   - `negation_complete` (line 116)
   - `deductively_closed` (line 163)

2. **G⊥/H⊥ Absence (UniversalCanonicalModel.lean)**: These should follow from MCS consistency properties. Relatively isolated proofs.
   - `h_no_G_bot` (line 84)
   - `h_no_H_bot` (line 86)

### Medium Priority (Quality Improvement)

3. **Coherent Construction Seeds**: The `forward_seed` and `backward_seed` consistency proofs in CoherentConstruction.lean would complete the inductive construction.

4. **Task Relation Compositionality**: Case analysis on integer signs is mechanical but tedious.

### Low Priority (Documented Limitations)

5. **Semantic Validity Issues**: These require an architectural decision about strict vs. reflexive temporal operators. Document as known limitation for now.

6. **Omega-Rule Limitation**: Fundamental limitation of finitary proof systems. Already well-documented.

7. **Decidability Module**: Separate research direction requiring FMP machinery.

8. **FiniteCanonicalModel**: Alternative approach; not the primary completeness path.

## Mathlib Lemmas to Consider

For MCS properties, relevant Mathlib patterns include:
- `FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem`: Maximal theories have negation completeness
- `FirstOrder.Language.Theory.IsMaximal.isComplete`: Maximal implies complete

These can guide the adaptation of MCS properties to set-based representations.

## References

- Task 794 summary: `specs/794_sorry_free_completeness_theorems/summaries/implementation-summary-20260201.md`
- Research on omega-rule: `specs/741_.../reports/research-001.md`
- Semantic weak completeness (sorry-free): `Bimodal.Metalogic.FMP.SemanticCanonicalModel.semantic_weak_completeness`

## Next Steps

1. Confirm the priority ordering with project requirements
2. For MCS properties: Examine existing list-based proofs in Boneyard for adaptation patterns
3. For coherent construction: Identify the inductive invariants needed for seed consistency
4. Consider whether decidability sorries should be a separate task
