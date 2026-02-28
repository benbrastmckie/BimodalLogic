# Implementation Plan: Task #951 (Revision 2)

- **Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
- **Status**: [IMPLEMENTING]
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

### Phase A: Resurrect and Adapt CanonicalReachable Infrastructure [COMPLETED]

- **Dependencies**: None (uses Boneyard code)
- **Goal**: Adapt CanonicalReachable from Boneyard for bidirectional reachability

**Tasks**:
- [x] Review `Boneyard/Metalogic/Bundle/CanonicalQuotientApproach/CanonicalReachable.lean`
- [x] Create `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean`
- [x] Define `BidirectionalReachable M₀` as reflexive-transitive-symmetric closure of CanonicalR from M₀
- [x] Prove `root_in_bidirectional`: M₀ ∈ BidirectionalReachable M₀ (via `BidirectionalReachable.refl`)
- [x] Prove `forward_reachable_closed`: via `BidirectionalFragment.forward_closed`
- [x] Prove `backward_reachable_closed`: via `BidirectionalFragment.backward_closed`
- [x] Import and verify compatibility with CanonicalFMCS.lean
- [x] Prove `forward_F_stays_in_fragment`: F-witnesses stay in fragment
- [x] Prove `backward_P_stays_in_fragment`: P-witnesses stay in fragment

**Timing**: 6-10 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` - new file (257 lines)

**Verification**:
- [x] `lake build Bimodal.Metalogic.Bundle.BidirectionalReachable` passes
- [x] No sorries in new file

**Progress:**

**Session: 2026-02-27, sess_1772246447_439fa1e5**
- Added: `BidirectionalEdge` inductive type for one-step edges in either direction
- Added: `BidirectionalReachable` inductive type for reflexive-transitive-symmetric closure
- Added: `BidirectionalFragment` structure for MCSes reachable from root
- Added: `forward_closed`, `backward_closed` closure lemmas
- Added: `forward_F_stays_in_fragment`, `backward_P_stays_in_fragment` key theorems
- Added: `toCanonicalMCS` conversion and `Preorder` instance
- Verified: All proofs compile without sorry or axiom

---

### Phase B: Prove Linearity of Bidirectional Fragment [COMPLETED]

- **Dependencies**: Phase A
- **Goal**: Prove any two elements in BidirectionalReachable M₀ are CanonicalR-comparable

**Key Insight**: The linearity axiom ensures that elements reachable from a common ancestor are comparable. For bidirectional reachability, we need to show that mixed forward/backward paths still yield comparable endpoints.

**Tasks**:
- [x] Adapt `canonical_reachable_linear` from Boneyard -> `canonical_forward_reachable_linear`
- [x] Add `mcs_F_linearity`: linearity axiom application within MCS context
- [x] Add `canonical_F_of_mem_successor`: F-introduction from CanonicalR successor
- [x] Define `bidirectional_path` type: MCS-enriched BidirectionalReachable carries MCS proofs (restructured approach)
- [x] Prove path confluence: via `comparable_step_forward` and `comparable_step_backward` helper lemmas
- [x] Prove `bidirectional_totally_ordered`: ∀ W₁ W₂ ∈ BidirectionalReachable M₀, CanonicalR W₁ W₂ ∨ CanonicalR W₂ W₁ ∨ W₁ = W₂
- [x] Use `temp_linearity` axiom (future AND past via temporal duality) to establish ordering at each path junction

**Timing**: 10-15 hours (hardest phase, ~4 hours completed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` - extend

**Verification**:
- [x] `lake build` passes
- [x] `bidirectional_totally_ordered` proven without sorry
- [x] `lean_goal` shows "no goals"

**Progress:**

**Session: 2026-02-27, sess_1772246447_439fa1e5**
- Added: `mcs_F_linearity` - applies temp_linearity axiom within MCS
- Added: `canonical_F_of_mem_successor` - F-introduction from successor MCS
- Added: `canonical_forward_reachable_linear` - totality for forward-reachable elements (95 lines)
- Imported: TemporalCoherentConstruction for `mcs_double_neg_elim`
- Verified: All proofs compile without sorry
- Remaining: Extend linearity to full bidirectional reachability

**Session: 2026-02-27, sess_1772247674_resume**
- Refactored: `BidirectionalReachable` to carry MCS proofs at every intermediate step
- Added: `mcs_P_linearity` - past linearity via temporal duality (42 lines)
- Added: `canonical_P_of_mem_predecessor` - P-introduction from predecessor MCS (24 lines)
- Added: `canonical_backward_reachable_linear` - totality for backward-reachable elements (100 lines)
- Added: `comparable_step_forward` and `comparable_step_backward` - helper transitivity lemmas
- Added: `comparable_with_reachable` - core induction lemma for bidirectional totality
- Added: `comparable_with_root` - root comparability
- Added: `bidirectional_totally_ordered` - full bidirectional totality (12 lines)
- Verified: All proofs compile without sorry, `lean_goal` shows "no goals"

---

### Phase C: Forward_F and Backward_P within Fragment [COMPLETED]

- **Dependencies**: Phase A
- **Goal**: Prove F/P witnesses stay within the bidirectional fragment

**Tasks**:
- [x] Prove `forward_F_in_fragment`: via `forward_F_stays_in_fragment` in Phase A
- [x] Prove `backward_P_in_fragment`: via `backward_P_stays_in_fragment` in Phase A
- [x] These follow from closure properties in Phase A + witness existence in CanonicalFMCS.lean

**Timing**: Completed in Phase A

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` - completed in Phase A

**Verification**:
- [x] `lake build` passes
- [x] No sorries in F/P fragment closure proofs

**Progress:**

**Session: 2026-02-27, sess_1772246447_439fa1e5**
- Completed: `forward_F_stays_in_fragment` proven in Phase A
- Completed: `backward_P_stays_in_fragment` proven in Phase A
- Note: These were implemented during Phase A infrastructure work

---

### Phase D: Antisymmetrization, Linear Order, and Fragment FMCS [COMPLETED]

- **Dependencies**: Phase B
- **Goal**: Create LinearOrder quotient and fragment-level FMCS with sorry-free F/P

**Tasks**:
- [x] Import Mathlib `Antisymmetrization` API
- [x] Prove `fragment_le_total`: total preorder on BidirectionalFragment
- [x] Define `BidirectionalQuotient M₀` = Antisymmetrization (BidirectionalFragment M₀) (· ≤ ·)
- [x] Prove `instLinearOrderBidirectionalQuotient`: LinearOrder instance
- [x] Define `fragmentFMCS`: FMCS on BidirectionalFragment (sorry-free)
- [x] Prove `fragmentFMCS_forward_F`: forward_F at fragment level (sorry-free!)
- [x] Prove `fragmentFMCS_backward_P`: backward_P at fragment level (sorry-free!)
- [x] Prove `fragmentFMCS_temporally_coherent`: temporal coherence at fragment level
- [x] Prove `witness_seed_consistent`: key lemma for Int chain construction
- [x] Define BoxContent, BoxWitnessSeed, diamondWitnessMCS infrastructure
- [x] Prove `box_witness_seed_consistent`: Diamond witness consistency
- [-] Prove `fragment_countable`: DEFERRED (fragment may be uncountable in general)
- [-] Prove `quotient_countable`: DEFERRED (depends on countability)

**Timing**: 6-8 hours

**Note on countability**: The BidirectionalFragment may be uncountable since each
CanonicalR step has uncountably many possible successor MCSes (via Lindenbaum).
The countability is not needed for the fragment-level FMCS construction. For the
Int conversion, a countable sub-fragment can be built iteratively.

**Files modified**:
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` - extended with LinearOrder
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` - rewritten with fragmentFMCS

**Verification**:
- [x] `lake build` passes
- [x] LinearOrder instance verified
- [x] No sorries in modified files

**Progress:**

**Session: 2026-02-27, sess_1772247674_resume (iteration 2)**
- Added: `fragment_le_total` - totality of preorder on BidirectionalFragment
- Added: `IsTotal` instance for BidirectionalFragment
- Added: `BidirectionalQuotient` type alias (Antisymmetrization)
- Added: `instLinearOrderBidirectionalQuotient` - LinearOrder instance
- Added: `BidirectionalFragment.toQuotient` and `toQuotient_le`
- Added: `fragmentFMCS` - FMCS on BidirectionalFragment (sorry-free, 12 lines)
- Added: `fragmentFMCS_forward_F` - forward_F at fragment level (sorry-free, 4 lines)
- Added: `fragmentFMCS_backward_P` - backward_P at fragment level (sorry-free, 5 lines)
- Added: `fragmentFMCS_temporally_coherent` - temporal coherence (sorry-free)
- Added: `witness_seed_consistent` - key lemma for Int chain construction (8 lines)
- Added: BoxContent, BoxWitnessSeed, diamondWitnessMCS infrastructure (copied from iteration 1)
- Added: `box_witness_seed_consistent` - Diamond witness consistency (sorry-free, 28 lines)
- Verified: All proofs compile without sorry, `lake build` passes (705 jobs)
- Key insight: fragmentFMCS resolves the F-persistence problem at the BidirectionalFragment level.
  Converting to FMCS Int remains the main challenge for subsequent phases.

---

### Phase E: Embedding into Int [IN PROGRESS]

- **Dependencies**: Phase D
- **Goal**: Build FMCS Int from fragment-level FMCS via order-preserving embedding

**Revised approach**: Instead of embedding the quotient into Int, build a countable
sub-fragment closed under F/P witnesses and embed that into Int. The fragment-level
FMCS has sorry-free forward_F/backward_P; the challenge is transferring these to Int.

**Tasks**:
- [x] Define `fragmentGSucc`: GContent successor in the fragment
- [x] Prove `fragmentGSucc_le`: successor is ≥ predecessor
- [x] Define `fragmentFSucc`: enriched successor with F-witness placement
- [x] Prove `fragmentFSucc_contains_witness`: successor contains witness formula
- [x] Prove `fragmentFSucc_le`: enriched successor is ≥ predecessor
- [x] Prove `enriched_seed_consistent_from_F`: KEY lemma resolving F-persistence
- [x] Prove `enriched_seed_consistent_from_P`: backward analog
- [ ] Define `FPClosure`: countable sub-fragment closed under F/P witnesses
- [ ] Prove `FPClosure` is countable
- [ ] Prove `FPClosure` is linearly ordered
- [ ] Define order-preserving embedding `FPClosure → Int`
- [ ] Define `pullback_fmcs : FMCS Int` via the embedding
- [ ] Prove `pullback_fmcs` has forward_G, backward_H, forward_F, backward_P

**Key mathematical insight**: `enriched_seed_consistent_from_F` shows that when
`F(φ) ∈ w.world` for a fragment element `w`, the seed `{φ} ∪ GContent(w.world)`
is consistent. This resolves the fundamental F-persistence blocker from the
DovetailingChain approach.

**Timing**: 6-8 hours (revised: 10-15 hours for full FPClosure + embedding)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` - extend

**Verification**:
- `lake build` passes
- Order embedding verified
- No sorries in FMCS Int construction

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
