# Implementation Plan: Phase 8 Resolution via Hybrid B+C Approach

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [PARTIAL]
- **Effort**: 15-20 hours (remaining from Phase 8 onward)
- **Dependencies**: None
- **Research Inputs**: research-017.md (Phase 8 blocker analysis, hybrid B+C recommendation)
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md
- **Type**: lean
- **Lean Intent**: true
- **Supersedes**: implementation-003.md (blocked at Phase 8 due to Lindenbaum collapse)

## Overview

This plan revises Phase 8 to resolve the DenselyOrdered blocker using a **hybrid B+C approach** from research-017. The key insight is that the forward_F approach suffers from "Lindenbaum collapse" where witnesses can collapse to endpoints. The solution is:

1. **Countable BQ first** (enables fallback and is useful regardless)
2. **Double-seed density proof** (combines forward and backward witnesses)
3. **Fallback**: Direct Q-embedding if double-seed proves too complex

### Root Cause (from research-017)

All 4 sorries share the same mathematical root: the Lindenbaum lemma provides no control over which MCS the consistent set extends to. The seed `{phi} UNION GContent(a)` can extend to `a.world` or `b.world` themselves.

### Research Integration

- **research-017 Section 7.2**: "Double seed" approach using `{chi, F(sigma)} UNION GContent(a)` where `chi in b \ a` distinguishes from `a` and `F(sigma) NOT in b` distinguishes from `b`.
- **research-017 Section 5**: Countable BQ proof is straightforward and enables direct Q-embedding.

## Goals & Non-Goals

**Goals**:
- Prove `Countable (BidirectionalQuotient M0 h_mcs0)` (Phase 8a)
- Resolve Phase 8 DenselyOrdered proof using double-seed approach (Phase 8b)
- Complete dense completeness theorem (Phases 9-10)
- Fix remaining metalogic files (Phases 11-14)

**Non-Goals**:
- Changing the irreflexive semantics (already completed in Phases 1-7)
- Full discrete path (separate task)
- Resolving pre-existing Int-chain sorries (orthogonal)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Double-seed case analysis too complex | Medium | Medium | Fallback to Approach C (direct Q-embedding) |
| Countable proof harder than expected | Low | Low | Mathematical argument is clear; standard Lean |
| Downstream phases need DenselyOrdered | Medium | Low | Audit first; most likely only Q-embedding matters |

## Sorry Characterization

### Current Sorries (Phase 8)
- DenseQuotient.lean lines 347, 349, 351, 698 (4 sorries)
- All stem from Lindenbaum collapse in forward_F approach

### Pre-existing Sorries (orthogonal)
- DovetailingChain.lean (2 sorries, archival path)
- FragmentCompleteness.lean (2 sorries, Int-chain path)
- TemporalCoherentConstruction.lean (2 sorries, Int path)

### Expected Resolution
- Phase 8b: 4 sorries -> 0 via double-seed approach or direct Q-embedding
- No new sorries introduced

## Implementation Phases

### Phases 1-7: [COMPLETED]

Irreflexive G/H refactoring completed. Semantics use strict `<`, T-axioms removed, soundness proofs adapted.

---

### Phase 8a: Prove Countable BidirectionalQuotient [BLOCKED]

- **Dependencies:** None
- **Goal:** Establish countability for direct Q-embedding option

**Mathematical Argument:**
1. `Formula` is countable (inductive type, finite base cases)
2. MCS is a subset of `Set Formula`, so at most `2^|Formula|` MCSes exist
3. BUT: BidirectionalFragment is reachable from a SINGLE root via CanonicalR
4. Each CanonicalR step is determined by `F(phi)` or `P(phi)` in source (countably many options)
5. Countable branching + single root = countable reachability
6. BidirectionalQuotient is quotient of countable type = countable

**Tasks:**
- [ ] Add `Countable BidirectionalFragment` instance in BidirectionalReachable.lean
  - Use `Countable.of_encodable` or manual encoding
  - Key lemma: each fragment element reachable via finite path from root
- [ ] Add `Countable BidirectionalQuotient` instance in DenseQuotient.lean
  - Follows from quotient of countable type

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean`
- `Theories/Bimodal/Metalogic/Bundle/DenseQuotient.lean`

**Verification:**
- `lake build` passes
- `Countable BidirectionalQuotient` instance available

---

### Phase 8b: Double-Seed DenselyOrdered Proof [NOT STARTED]

- **Dependencies:** Phase 8a (for fallback option)
- **Goal:** Resolve 4 sorries using combined forward-backward seed

**Strategy (from research-017 Section 7.2):**

Given `a < b` in quotient:
1. Extract `chi in b \ a` (exists by `exists_in_b_not_a`)
2. Extract `theta in a \ b` (exists by `exists_in_a_not_b`)
3. From `chi in b \ a`: `F(chi) in a` (F-introduction)
4. From `theta in a \ b`: `P(theta) in b` (P-introduction)
5. Apply DN: `FF(chi) in a`; Apply DP: `PP(theta) in b`
6. Use linearity to get `F(chi AND F(sigma)) in a` where `sigma` is the combined formula
7. Build intermediate `c` via seed `{chi AND F(sigma)} UNION GContent(a)`
8. Show `c != a` (chi in c, chi NOT in a)
9. Show `c != b` (F(sigma) in c, F(sigma) NOT in b)
10. Establish `CanonicalR a c` and `CanonicalR c b` by linearity

**Case Structure:**
- **Case A (GContent(b) NOT subset b)**:
  - Use combined formula `sigma = G(psi) AND NOT(psi)`
  - Need to handle 3 linearity sub-cases
- **Case B (GContent(b) subset b)**:
  - Use Goldblatt seed with separating formula
  - May need different approach

**Fallback:**
If case analysis proves too complex (>4 hours on any single case), fall back to Approach C:
- Remove `DenselyOrdered` requirement from downstream phases
- Use `Countable` + direct Q-embedding via `Order.embedding_from_countable_to_dense`

**Tasks:**
- [ ] Implement double-seed helper lemma `double_seed_consistent`
- [ ] Refactor Case A using double-seed approach
- [ ] Refactor Case B using double-seed approach
- [ ] Eliminate all 4 sorries OR implement Approach C fallback

**Timing:** 6-8 hours (key phase)

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/DenseQuotient.lean`

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.DenseQuotient` passes
- `grep -n "\bsorry\b" DenseQuotient.lean` returns 0 (or fallback: no DenselyOrdered dependency)
- Either `DenselyOrdered BidirectionalQuotient` instance OR `OrderEmbedding BQ Rat` instance

---

### Phase 9: Quotient Embedding into Q [NOT STARTED]

- **Dependencies:** Phase 8b
- **Goal:** Embed BidirectionalQuotient into rationals

**Tasks:**
- [ ] If Phase 8b DenselyOrdered succeeded:
  - Prove `NoMinOrder` and `NoMaxOrder` for quotient
  - Apply `Order.iso_of_countable_dense` (Cantor's theorem)
  - Get `Nonempty (BidirectionalQuotient ≃o Rat)`
- [ ] If Phase 8b fell back to Approach C:
  - Apply `Order.embedding_from_countable_to_dense`
  - Get `Nonempty (BidirectionalQuotient ↪o Rat)`
  - Verify downstream phases work with embedding (not isomorphism)

**Timing:** 2 hours

**Files to modify/create:**
- `Theories/Bimodal/Metalogic/Bundle/QuotientIsomorphism.lean`

**Verification:**
- `lake build` passes
- Order embedding/isomorphism to Rat exists

---

### Phase 10: Dense Completeness Theorem [NOT STARTED]

- **Dependencies:** Phase 9
- **Goal:** Prove completeness for TM + DN

**Tasks:**
- [ ] Define `TM_DN_provable` (temporal logic with DN axiom)
- [ ] Prove `dense_representation_theorem`: consistent formula has dense frame model
- [ ] Prove `dense_completeness : valid_dense phi -> TM_DN_provable phi`
- [ ] Use D = Q via embedding, `addGroupIsAddTorsor` for torsor structure

**Timing:** 3 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean`

**Verification:**
- `lake build Bimodal.Metalogic.DenseCompleteness` passes
- `grep -n "\bsorry\b"` returns empty
- `dense_completeness` theorem has correct type

---

### Phase 11: Fix Remaining Metalogic Files [NOT STARTED]

- **Dependencies:** Phase 10
- **Goal:** Adapt metalogic files for irreflexive semantics

**Tasks:**
- [ ] Fix `BFMCSTruth.lean` temporal cases if needed
- [ ] Fix `CanonicalChain.lean` if still used
- [ ] Mark DovetailingChain.lean for archival

**Timing:** 2 hours

**Files to modify:**
- Various `Bundle/*.lean` files

**Verification:**
- `lake build` passes for all metalogic files

---

### Phase 12: Fix Decidability and Algebraic [NOT STARTED]

- **Dependencies:** Phase 11
- **Goal:** Adapt decidability tableau and algebraic metalogic

**Tasks:**
- [ ] Update tableau rules for `<` instead of `<=`
- [ ] Update saturation conditions
- [ ] Remove interior operator properties that depended on T-axiom

**Timing:** 2.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Decidability/*.lean`
- `Theories/Bimodal/Metalogic/Algebraic/*.lean`

**Verification:**
- `lake build` passes for decidability and algebraic files

---

### Phase 13: Fix Theorems and Examples [NOT STARTED]

- **Dependencies:** Phase 12
- **Goal:** Adapt theorem files and examples

**Tasks:**
- [ ] Adapt Perpetuity.lean
- [ ] Update example proofs

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Theorems/*.lean`
- `Theories/Bimodal/Examples/*.lean`

**Verification:**
- Full `lake build` passes

---

### Phase 14: Final Verification and Summary [NOT STARTED]

- **Dependencies:** Phase 13
- **Goal:** Full verification, sorry audit, documentation

**Tasks:**
- [ ] Run full `lake build`
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/`
- [ ] Verify no NEW sorries (pre-existing sorries documented)
- [ ] Create implementation summary

**Timing:** 1 hour

**Files to create:**
- `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-{DATE}.md`

**Verification:**
- `lake build` passes
- Summary complete

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] Phase 8 sorries resolved (0 new, 4 eliminated)
- [ ] `dense_completeness` theorem compiles with correct type

### Mathematical Validation
- [ ] Countable BidirectionalQuotient proven
- [ ] Either DenselyOrdered proven OR direct Q-embedding works
- [ ] Completeness for TM + DN achieved

## Artifacts & Outputs

**Modified Files:**
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` (Countable)
- `Theories/Bimodal/Metalogic/Bundle/DenseQuotient.lean` (4 sorries resolved)
- `Theories/Bimodal/Metalogic/Bundle/QuotientIsomorphism.lean` (new/modified)
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` (completeness theorem)
- Plus ~20 additional files for irreflexive fixes

**Summary:**
- `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

1. **Phase 8b stuck**: Use Approach C fallback (direct Q-embedding)
2. **Approach C insufficient for downstream**: Research alternative representation theorems
3. **Irreflexive refactor issues**: Each phase independently committed; use `git revert`

## Comparison with implementation-003.md

| Aspect | implementation-003.md | implementation-004.md |
|--------|----------------------|----------------------|
| Phase 8 strategy | Single forward_F | Hybrid B+C (double-seed + Countable) |
| Countable BQ | Not addressed | Phase 8a prerequisite |
| Fallback option | Direct Q-embedding mentioned | Explicit Approach C with criteria |
| Linearity handling | Single case | 3 sub-cases documented |
| Estimated effort | 4 hours (Phase 8) | 7-9 hours (Phases 8a+8b) |
| Risk mitigation | Limited | Explicit fallback triggers |
