# Implementation Plan: Task #951 (Revision 2)

- **Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
- **Status**: [NOT STARTED]
- **Effort**: 40-60 hours
- **Version**: 2 (supersedes implementation-001.md)
- **Dependencies**: CanonicalFMCS.lean, Boneyard CanonicalReachable infrastructure
- **Research Inputs**:
  - specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-001.md
  - specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-002.md
  - specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-003.md (ROOT CAUSE ANALYSIS)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision History

| Version | Date | Key Changes |
|---------|------|-------------|
| 001 | 2026-02-27 | Initial plan: antisymmetrization via Z-indexed dovetailing chain |
| 002 | 2026-02-27 | **Major revision**: Abandon chain approach for forward_F/backward_P. Use Bidirectional Reachable Fragment (Solution Path C from research-003.md) |

## Why Revision is Needed

**Root Cause Analysis (research-003.md)**: The linear chain approach in implementation-001.md is **mathematically impossible**:

1. **F-formula non-persistence**: F-formulas (`F(φ) = ¬G(¬φ)`) are NOT in GContent. Lindenbaum extensions can introduce `G(¬φ)`, killing `F(φ)` at any step.

2. **Structural impossibility**: No property of F-formulas can be derived from GContent-based chain ordering. The linearity axiom constrains membership within a single MCS but does NOT prevent Lindenbaum from making choices that kill F-obligations.

3. **Phases 1-2 COMPLETED**, **Phase 3 BLOCKED**: The chain infrastructure works, but `forward_F_dovetailed` is unprovable.

**Solution**: Use **Bidirectional Reachable Fragment** approach:
- Operate at CanonicalMCS level where forward_F and backward_P are trivially sorry-free
- Define bidirectional reachable fragment from root MCS
- Prove it's linearly ordered via linearity axiom
- Embed into Int
- Pull back FMCS to get `FMCS Int` with forward_F AND backward_P

## Overview

Implement sorry-free completeness by:
1. Using `canonicalMCS_forward_F` and `canonicalMCS_backward_P` (already sorry-free in CanonicalFMCS.lean)
2. Constructing the **bidirectional reachable fragment** from any root MCS
3. Proving this fragment is linearly ordered (via linearity axiom)
4. Embedding into Int via Antisymmetrization + Mathlib infrastructure
5. Pulling back the FMCS structure to get `FMCS Int`

This avoids the F-persistence problem entirely by not relying on chain construction for forward_F/backward_P.

## Goals & Non-Goals

**Goals**:
- Eliminate sorries in completeness chain via embedding approach
- Prove forward_F and backward_P by transfer from CanonicalMCS level
- Achieve modal saturation via witness families (same construction per family)
- Bridge to standard `valid` with `FMCS Int`
- Maintain zero new sorries

**Non-Goals**:
- Fixing the chain-based approach (proven impossible)
- Generalizing semantics to Preorder D
- Modifying DovetailingChain.lean (keep as deprecated)

## Preserved Infrastructure from v001

**From Phase 1 (COMPLETED)**: CanonicalChain.lean (857 lines) contains:
- `CanonicalChain` structure with Z-indexed MCS
- Monotonicity and GContent/HContent inclusion proofs
- FMCS conversion infrastructure

**From Phase 2 (COMPLETED)**: Obligation enumeration in CanonicalChain.lean:
- `Obligation` inductive type
- Omega-squared diagonal enumeration
- Enriched chain construction with witness placement

**Note**: The enriched chain infrastructure remains useful for understanding but will NOT be used for forward_F/backward_P. The Bidirectional Reachable Fragment approach supersedes it.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Bidirectional totality proof fails | High | Medium | Carefully trace paths through common ancestors; use linearity axiom |
| Mathlib embedding infrastructure insufficient | Medium | Low | Antisymmetrization + countable-to-Int embedding are standard |
| Modal saturation complexity | Medium | Medium | Each witness family uses same construction (parallelize) |
| Integration with existing BFMCS machinery | Medium | Low | Define new types, don't modify existing |
| Boneyard infrastructure needs significant adaptation | Medium | Medium | CanonicalReachable proven; generalize to bidirectional |

## Implementation Phases

### Phase A: Resurrect and Adapt CanonicalReachable Infrastructure [NOT STARTED]

- **Dependencies**: None (uses Boneyard code)
- **Goal**: Adapt CanonicalReachable from Boneyard for bidirectional reachability

**Tasks**:
- [ ] Review `Boneyard/Metalogic/Bundle/CanonicalQuotientApproach/CanonicalReachable.lean`
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean`
- [ ] Define `BidirectionalReachable M₀` as reflexive-transitive-symmetric closure of CanonicalR from M₀
- [ ] Prove `root_in_bidirectional`: M₀ ∈ BidirectionalReachable M₀
- [ ] Prove `forward_reachable_closed`: if W ∈ BidirectionalReachable M₀ and CanonicalR W W', then W' ∈ BidirectionalReachable M₀
- [ ] Prove `backward_reachable_closed`: if W ∈ BidirectionalReachable M₀ and CanonicalR W' W, then W' ∈ BidirectionalReachable M₀
- [ ] Import and verify compatibility with CanonicalFMCS.lean

**Timing**: 6-10 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` - new file

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.BidirectionalReachable` passes
- No sorries in new file

---

### Phase B: Prove Linearity of Bidirectional Fragment [NOT STARTED]

- **Dependencies**: Phase A
- **Goal**: Prove any two elements in BidirectionalReachable M₀ are CanonicalR-comparable

**Key Insight**: The linearity axiom ensures that elements reachable from a common ancestor are comparable. For bidirectional reachability, we need to show that mixed forward/backward paths still yield comparable endpoints.

**Tasks**:
- [ ] Adapt `canonical_reachable_linear` from Boneyard (lines 290-383 in CanonicalEmbedding.lean)
- [ ] Define `bidirectional_path` type: sequence of CanonicalR or CanonicalR⁻¹ edges from M₀
- [ ] Prove path confluence: any two paths from M₀ to different endpoints share a common comparison point
- [ ] Prove `bidirectional_totally_ordered`: ∀ W₁ W₂ ∈ BidirectionalReachable M₀, CanonicalR W₁ W₂ ∨ CanonicalR W₂ W₁ ∨ W₁ = W₂
- [ ] Use `temp_linearity` axiom to establish ordering at each path junction

**Timing**: 10-15 hours (hardest phase)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` - extend

**Verification**:
- `lake build` passes
- `bidirectional_totally_ordered` proven without sorry
- `lean_goal` shows "no goals"

---

### Phase C: Forward_F and Backward_P within Fragment [NOT STARTED]

- **Dependencies**: Phase A
- **Goal**: Prove F/P witnesses stay within the bidirectional fragment

**Tasks**:
- [ ] Prove `forward_F_in_fragment`: if W ∈ BidirectionalReachable M₀ and F(φ) ∈ W, then the witness W' from `canonical_forward_F` is also in BidirectionalReachable M₀
- [ ] Prove `backward_P_in_fragment`: if W ∈ BidirectionalReachable M₀ and P(φ) ∈ W, then the witness W' from `canonical_backward_P` is also in BidirectionalReachable M₀
- [ ] These follow from closure properties in Phase A + witness existence in CanonicalFMCS.lean

**Timing**: 4-6 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` - extend

**Verification**:
- `lake build` passes
- No sorries in F/P fragment closure proofs

---

### Phase D: Antisymmetrization and Countability [NOT STARTED]

- **Dependencies**: Phase B
- **Goal**: Create LinearOrder quotient and prove countability

**Tasks**:
- [ ] Import Mathlib `Antisymmetrization` API
- [ ] Define `BidirectionalQuotient M₀` = Antisymmetrization (BidirectionalReachable M₀) CanonicalR
- [ ] Prove `quotient_linear_order`: BidirectionalQuotient has LinearOrder instance
- [ ] Prove `fragment_countable`: BidirectionalReachable M₀ is countable (generated from countable formula set)
- [ ] Prove `quotient_countable`: BidirectionalQuotient is countable

**Timing**: 6-8 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` - extend

**Verification**:
- `lake build` passes
- LinearOrder and Countable instances verified

---

### Phase E: Embedding into Int [NOT STARTED]

- **Dependencies**: Phase D
- **Goal**: Embed countable linear order into Int

**Tasks**:
- [ ] Use Mathlib `Order.embedding_from_countable_to_dense` or direct construction
- [ ] Define `embedIntoInt : BidirectionalQuotient M₀ ↪o Int` (order embedding)
- [ ] Prove embedding is order-preserving: q₁ ≤ q₂ → embedIntoInt q₁ ≤ embedIntoInt q₂
- [ ] Define inverse image: `preimage : Int → Option (BidirectionalQuotient M₀)`

**Timing**: 6-8 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean` - new file (or extend BidirectionalReachable)

**Verification**:
- `lake build` passes
- Order embedding verified

---

### Phase F: FMCS Int via Pullback [NOT STARTED]

- **Dependencies**: Phases C, E
- **Goal**: Construct FMCS Int by pulling back the CanonicalMCS structure along embedding

**Tasks**:
- [ ] Define `fmcs_from_embedding M₀ : FMCS Int` where:
  - `mcs t` = equivalence class in BidirectionalQuotient at position t (via inverse of embedding)
  - For positions outside embedded range: use M₀ as default (or prove all positions are covered)
- [ ] Prove `fmcs_forward_G`: G(φ) ∈ mcs(t) → φ ∈ mcs(s) for all s > t
- [ ] Prove `fmcs_backward_H`: H(φ) ∈ mcs(t) → φ ∈ mcs(s) for all s < t
- [ ] Prove `fmcs_forward_F`: F(φ) ∈ mcs(t) → ∃ s > t, φ ∈ mcs(s)
- [ ] Prove `fmcs_backward_P`: P(φ) ∈ mcs(t) → ∃ s < t, φ ∈ mcs(s)
- [ ] The F/P proofs transfer from Phase C via the embedding

**Timing**: 8-10 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` - new file

**Verification**:
- `lake build` passes
- All FMCS properties proven without sorry
- `lean_goal` shows "no goals" for forward_F, backward_P

---

### Phase G: BFMCS and Modal Saturation [NOT STARTED]

- **Dependencies**: Phase F
- **Goal**: Build modally saturated BFMCS Int

**Tasks**:
- [ ] Define eval family using `fmcs_from_embedding (Lindenbaum Γ)`
- [ ] For each diamond witness need, construct witness family using same embedding approach:
  - Root = the witnessing MCS
  - Embed its bidirectional fragment
  - Create FMCS Int for witness family
- [ ] Prove `is_modally_saturated`: every diamond obligation has witness family
- [ ] Prove `all_families_temporally_coherent`: all families satisfy forward_F and backward_P
- [ ] Combine into `saturated_bfmcs_int : BFMCS Int`

**Timing**: 10-14 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` - extend

**Verification**:
- `lake build` passes
- Modal saturation proven without sorry
- All family properties verified

---

### Phase H: Truth Lemma and Completeness [NOT STARTED]

- **Dependencies**: Phase G
- **Goal**: Prove truth lemma and derive completeness

**Tasks**:
- [ ] Prove truth lemma: `φ ∈ fam.mcs t ↔ truth_at model fam t φ` (by structural induction)
- [ ] Handle box case: uses modal saturation + truth lemma at witness families
- [ ] Handle F/P cases: uses forward_F/backward_P + witness existence
- [ ] Derive `weak_completeness`: ⊨ φ → ⊢ φ
- [ ] Derive `strong_completeness`: Γ ⊨ φ → Γ ⊢ φ
- [ ] Update `Metalogic.lean` exports

**Timing**: 8-12 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` - extend
- `Theories/Bimodal/Metalogic.lean` - update exports

**Verification**:
- `lake build` passes on full project
- All completeness theorems proven without sorry
- `lean_verify` confirms axiom dependencies

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <modified files>` returns empty for new proofs
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Completeness Verification
- [ ] `weak_completeness` proven without sorry
- [ ] `strong_completeness` proven without sorry
- [ ] Truth lemma covers all formula cases
- [ ] Modal saturation verified for all diamond obligations

### Property Verification
- [ ] `forward_F_in_fragment` proven without sorry
- [ ] `backward_P_in_fragment` proven without sorry
- [ ] `bidirectional_totally_ordered` proven without sorry
- [ ] Order embedding verified

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` - new module
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` - new module (or integrate into existing)
- `specs/951_implement_sorry_free_completeness_canonicalmcs/plans/implementation-002.md` - this plan
- `specs/951_implement_sorry_free_completeness_canonicalmcs/summaries/implementation-summary-YYYYMMDD.md` - completion summary

## Rollback/Contingency

1. **Phase B fails** (totality proof): This is the highest-risk phase. If it fails:
   - Try alternate totality argument (e.g., path induction)
   - Consider restricting to forward-only reachable + separate backward construction
   - Mark [BLOCKED] for user review

2. **Embedding fails**: Mathlib infrastructure is mature; unlikely. Fallback: direct countable enumeration.

3. **Modal saturation complex**: Each family is independent; can parallelize or serialize.

4. **Infrastructure from v001**: The CanonicalChain.lean infrastructure (856 lines) remains valid as reference/utility code even if not used for the main proof.

## Notes

**Key Mathematical Insight**: The bidirectional reachable fragment avoids the F-persistence problem because:
1. Forward_F and backward_P are proven at the CanonicalMCS level (trivially)
2. The fragment closure properties ensure witnesses stay in the domain
3. The embedding into Int preserves the ordering
4. The pullback transfers F/P properties without needing chain-based persistence

**Literature Reference**: Goldblatt (1992) "Logics of Time and Computation" Chapter 4 uses a similar approach: work at the canonical frame level, then embed into the desired time structure.
