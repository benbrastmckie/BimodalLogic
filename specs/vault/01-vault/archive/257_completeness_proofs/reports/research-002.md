# Research Report: Task #257 (Updated)

**Task**: Completeness Proofs for TM Bimodal Logic
**Date**: 2026-01-12
**Focus**: Impact of Tasks 260/261 on completeness proof development

## Summary

Tasks 260 (Proof Search) and 261 (Decidability) have been completed, providing significant new infrastructure that impacts the completeness proof. The Type-based Axiom refactor enables proof term extraction, and the tableau-based decidability provides an alternative path to completeness via the finite model property. However, the canonical model completeness approach remains the primary strategy, now with better tooling support.

## Impact Analysis

### Task 260: Proof Search with Proof Term Construction

**Completed Work**:
1. **Axiom Type Refactor**: Changed `Axiom : Formula → Prop` to `Axiom : Formula → Type` (Axioms.lean:66)
2. **matchAxiom Function**: Pattern matches formulas against all 14 axiom schemas, returning `Option (Sigma Axiom)` with actual witnesses (ProofSearch.lean:375-514)
3. **bounded_search_with_proof**: Returns actual `DerivationTree` proof terms, not just `Bool` (ProofSearch.lean:837-936)
4. **MembershipWitness**: Type wrapper for extracting membership proofs from contexts (ProofSearch.lean:205-212)

**Impact on Completeness**:

| Component | Impact | Details |
|-----------|--------|---------|
| `truth_lemma` | **Positive** | Can now construct actual proof terms during truth lemma verification |
| `maximal_consistent_closed` | **Positive** | Type-based axioms allow explicit witness construction |
| `weak_completeness` | **Neutral** | Axiom witnesses available, but canonical model still needed |
| Proof verification | **Positive** | `verifyProof` and `proofHeight` functions available |

**Key Benefit**: The `matchAxiom` function can verify axiom instances during maximal consistent set construction, enabling explicit proof term construction instead of existential witnesses.

### Task 261: Decidability via Tableau Method

**Completed Work**:
1. **Tableau Infrastructure**: 8 new files in `Metalogic/Decidability/` (~1,950 lines)
2. **DecisionResult Type**: Returns `valid proof | invalid countermodel | timeout`
3. **Soundness Proven**: `decide_sound : ∀ φ proof, ⊨ φ` (via existing `soundness` theorem)
4. **Completeness Framework**: `tableau_complete` and `decide_complete` theorems (with `sorry`)

**Impact on Completeness**:

| Component | Impact | Details |
|-----------|--------|---------|
| Alternative Proof Path | **New Option** | Can prove completeness via FMP + tableau instead of canonical model |
| `provable_iff_valid` | **Partial** | Decidability provides `⊨ φ ∨ ¬⊨ φ`, but not constructive proof |
| Countermodel Extraction | **Useful** | Invalid formulas get explicit countermodels |
| Integration | **Available** | `findProofCombined` combines tableau + proof search |

**Key Connection**: The decidability correctness module (Correctness.lean) has these incomplete theorems:
- `tableau_complete` (line 74): Requires FMP formalization
- `decide_complete` (line 86): Requires tableau completeness

These have the same dependency structure as the canonical model completeness - they need the **finite model property (FMP)** for TM logic.

## Revised Completeness Strategy

### Option A: Canonical Model (Original, Recommended)

**Still Viable**: The canonical model approach remains the cleanest for this logic:

```
Lindenbaum → Canonical Frame → Truth Lemma → Completeness
```

**New Tools Available**:
- `matchAxiom` for axiom instance verification
- `bounded_search_with_proof` for constructive witness proofs
- `deduction_theorem` (complete) for maximal consistent set properties

**Revised Effort Estimate**: 60-75 hours (reduced from 70-90 due to better tooling)

### Option B: Decidability-Based Completeness (New Alternative)

**New Path Available**:

```
FMP → Tableau Completeness → decide_complete → weak_completeness
```

**Current Status**:
- Tableau infrastructure: Complete
- Soundness: Complete
- FMP: Not formalized (major undertaking)
- Completeness: Depends on FMP

**Effort Estimate**: 50-70 hours (FMP is complex but enables both decidability and completeness)

### Recommendation: Hybrid Approach

1. **Primary**: Continue canonical model approach with new tools
2. **Secondary**: Complete FMP formalization to enable decidability-based completeness
3. **Integration**: Use proof search/tableau as verification oracle during development

## Updated Implementation Plan

### Phase 1: Maximal Consistent Set Properties (5-6 hours)
*Reduced from 5-7 hours due to Type-based axioms*

**Leverage from Task 260**:
- Use `matchAxiom` to verify axiom instances in consistency proofs
- Use `bounded_search_with_proof` for constructive deduction witnesses

**Implementation**:
```lean
-- Can now use matchAxiom to verify axiom membership
theorem maximal_consistent_closed (Γ : Context) (φ : Formula) :
    MaximalConsistent Γ → DerivationTree Γ φ → φ ∈ Γ := by
  intro ⟨hcons, hmax⟩ hderiv
  by_contra hnot_mem
  -- From maximality: φ :: Γ is inconsistent
  have hincons : ¬Consistent (φ :: Γ) := hmax φ hnot_mem
  -- So (φ :: Γ) ⊢ ⊥
  -- By deduction_theorem: Γ ⊢ φ → ⊥
  -- Combined with Γ ⊢ φ gives Γ ⊢ ⊥, contradicting hcons
  sorry
```

### Phase 2: Lindenbaum's Lemma (12-15 hours)
*Unchanged - Zorn's lemma application is independent of Task 260/261*

**Mathlib Tools**:
```lean
-- From Mathlib.Order.Zorn
theorem zorn_le_nonempty₀ {α : Type*} [Preorder α] (s : Set α)
  (h : ∀ c ⊆ s, IsChain (· ≤ ·) c → ∀ y ∈ c, ∃ ub ∈ s, ∀ z ∈ c, z ≤ ub) :
  ∀ x ∈ s, ∃ m, x ≤ m ∧ Maximal (· ∈ s) m
```

**Key Proof Obligation**: Show union of chain of consistent sets is consistent.

### Phase 3: Canonical Frame (8-12 hours)
*Slightly reduced - proof search can verify frame property lemmas*

**New Verification Tool**:
```lean
-- Use decidability to verify frame property instances
#check decide (nullity_condition : Formula)  -- Quick sanity checks
```

### Phase 4: Canonical Model (4-6 hours)
*Unchanged*

### Phase 5: Truth Lemma (20-25 hours)
*Reduced from 25-30 hours due to proof term construction*

**Key Improvement**: The modal saturation lemma proof can now construct explicit proof terms:

```lean
-- Modal saturation: □φ ∈ Γ ↔ ∀ accessible Δ, φ ∈ Δ
-- Direction (→): Use matchAxiom to verify T axiom instance
-- Direction (←): Use bounded_search_with_proof for constructive witness
```

### Phase 6: Completeness Theorems (8-12 hours)
*Reduced from 10-15 hours due to available infrastructure*

**Integration with Decidability**:
```lean
-- Can verify completeness for specific formulas using decide
example : DerivationTree [] (φ.box.imp φ) := by
  -- matchAxiom proves this is modal_t axiom
  exact DerivationTree.axiom [] _ (Axiom.modal_t φ)
```

## Technical Dependencies

### From Task 260 (Proof Search)
| Definition | Location | Use in Completeness |
|------------|----------|---------------------|
| `Axiom : Formula → Type` | Axioms.lean:66 | Enables proof term construction |
| `matchAxiom` | ProofSearch.lean:392 | Verify axiom instances |
| `bounded_search_with_proof` | ProofSearch.lean:868 | Construct proof witnesses |
| `MembershipWitness` | ProofSearch.lean:205 | Extract membership proofs |

### From Task 261 (Decidability)
| Definition | Location | Use in Completeness |
|------------|----------|---------------------|
| `DecisionResult` | DecisionProcedure.lean:55 | Alternative completeness path |
| `decide_sound` | Correctness.lean:45 | Validates proof extraction |
| `tryAxiomProof` | ProofExtraction.lean:92 | Quick axiom verification |
| `extractProof` | ProofExtraction.lean:129 | Tableau-to-proof conversion |

### Existing Infrastructure (Used by Both)
| Definition | Location | Status |
|------------|----------|--------|
| `deduction_theorem` | DeductionTheorem.lean:307 | Complete |
| `soundness` | Soundness.lean | Complete (14/14 axioms) |
| `valid_iff_empty_consequence` | Validity.lean | Complete |

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| FMP needed for decidability completeness | Medium | Focus on canonical model (independent of FMP) |
| Proof term extraction incomplete | Low | Tableau proofs as fallback verification |
| Universe level issues in canonical model | Medium | Follow existing patterns in Validity.lean |
| Context representation (List vs Set) | Medium | Use Mathlib's Finset for finite subsets |

## Remaining `sorry` in Codebase

### In Completeness.lean
- Line 369: `provable_iff_valid` (semantic consequence ↔ validity direction)

### In Decidability/Correctness.lean
- Line 77: `tableau_complete` (requires FMP)
- Line 88: `decide_complete` (requires tableau completeness)
- Line 172: `decide_axiom_valid` (matchAxiom behavior verification)

## Conclusion

Tasks 260 and 261 provide valuable infrastructure but do not fundamentally change the completeness proof strategy. The main benefits are:

1. **Type-based Axioms**: Enable explicit proof term construction throughout
2. **Proof Search**: Provides constructive witnesses during development
3. **Decidability Framework**: Alternative completeness path available if FMP is formalized

**Revised Total Effort**: 57-76 hours (down from 70-90 hours)

**Next Steps**:
1. Run `/plan 257` to create updated implementation plan
2. Begin Phase 1 (maximal consistent set properties) using new tools
3. Consider parallel FMP formalization for decidability completeness

## Appendix: Search Queries Used

1. LeanSearch: "Zorn's lemma maximal element chain upper bound"
2. Loogle: `IsChain _ _ → ∃ _, Maximal _ _`
3. LeanFinder: "Lindenbaum lemma consistent set maximal extension completeness theorem"
4. Local search: `matchAxiom`, `bounded_search_with_proof`, `DecisionResult`

## References

- Task 260 Summary: `specs/260_proof_search/summaries/implementation-summary-20260112.md`
- Task 261 Summary: `specs/261_decidability/summaries/implementation-summary-20260112.md`
- Previous Research: `specs/257_completeness_proofs/reports/research-001.md`
- Mathlib.Order.Zorn documentation
- Modal Logic (Blackburn et al.), Chapter 4 (Canonical Models)
