# Implementation Plan: Dense Algebraic Completeness via CanonicalQuot (v2)

- **Task**: 988 - dense_algebraic_completeness
- **Status**: [NOT STARTED]
- **Effort**: 12-16 hours (5 phases)
- **Dependencies**: Task 985 (complete)
- **Research Inputs**: research-001.md, research-002.md, research-003.md (semantics architecture)
- **Supersedes**: implementation-001.md (blocked on TimelineQuot transfer)
- **Type**: lean
- **Lean Intent**: true

## Overview

This revised plan follows the **CanonicalQuot approach** from research-003, which correctly addresses the semantics architecture:

**Key Insight**: The semantics has TWO distinct components:
1. **W (World States)**: Constructed from MCS - DONE
2. **D (Durations)**: Must emerge from syntax, NOT be imported as Rat

**The Solution**: Quotient CanonicalMCS via Antisymmetrization to get **CanonicalQuot** which has:
- All witnesses (inherited from CanonicalMCS - forward_F, backward_P proven)
- Linear order (from quotienting)
- Countable, dense, no endpoints (from axiom structure)

Then apply Cantor theorem: `CanonicalQuot ≃ Rat` to get D from syntax.

### Why This Plan Differs from v1

| Issue in v1 | Resolution in v2 |
|-------------|-----------------|
| Imported Rat as D | D emerges from CanonicalQuot via Cantor |
| TimelineQuot lacks witnesses | CanonicalQuot inherits witnesses from CanonicalMCS |
| forward_F witnesses outside subset | ALL MCS are in CanonicalQuot (no subset) |

## Goals & Non-Goals

**Goals**:
- Define `CanonicalQuot` as Antisymmetrization of CanonicalMCS
- Prove order properties (linear, countable, dense, no endpoints)
- Build FMCS/BFMCS over CanonicalQuot with proven temporal coherence
- Apply Cantor: `CanonicalQuot ≃o Rat`
- Wire to `parametric_algebraic_representation_conditional`
- Prove `dense_algebraic_completeness : valid_dense phi -> provable phi`
- Zero sorries, zero new axioms

**Non-Goals**:
- Using TimelineQuot directly (it lacks witnesses)
- Importing Rat as D (violates pure-syntax constraint)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Antisymmetrization loses witnesses | High | LOW | `denseTimelineElem_mutual_le_implies_mcs_eq` proves MCS preserved on equivalence classes |
| CanonicalMCS not densely ordered | Medium | LOW | DN axiom forces density in quotient |
| Cantor transfer complexity | Medium | MEDIUM | Mathlib provides `Order.embedding_from_countable_to_dense` |
| modal_backward fails for singleton | Medium | MEDIUM | Use multi-family BFMCS if needed |

## Implementation Phases

### Phase 1: CanonicalQuot Definition and Basic Properties [NOT STARTED]

- **Dependencies:** None
- **Goal:** Define CanonicalQuot as antisymmetrization of CanonicalMCS, prove basic order properties

**Tasks:**
- [ ] Define `CanonicalQuot := Antisymmetrization CanonicalMCS CanonicalR`
- [ ] Define `toCanonicalQuot : CanonicalMCS -> CanonicalQuot` (canonical map)
- [ ] Prove `CanonicalQuot` has LinearOrder (from Antisymmetrization)
- [ ] Prove `CanonicalQuot` is Countable (inherits from CanonicalMCS)
- [ ] Define `canonicalQuotMCS : CanonicalQuot -> Set Formula` (well-defined by `mutual_le_implies_mcs_eq`)

**Timing:** 2-3 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalQuot.lean`
  - `CanonicalQuot : Type`
  - `toCanonicalQuot : CanonicalMCS -> CanonicalQuot`
  - `linearOrder_canonicalQuot : LinearOrder CanonicalQuot`
  - `countable_canonicalQuot : Countable CanonicalQuot`
  - `canonicalQuotMCS : CanonicalQuot -> Set Formula`
  - `canonicalQuotMCS_is_mcs : forall q, SetMaximalConsistent (canonicalQuotMCS q)`

**Verification:**
- `lake build Bimodal.Metalogic.Algebraic.CanonicalQuot` passes
- `grep -n "\bsorry\b"` returns empty

---

### Phase 2: Order Properties (Dense, No Endpoints) [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Prove CanonicalQuot has dense order and no min/max

**Key Insight:** These properties follow from the proof system axioms:
- **Density**: DN axiom (always exists intermediate state) forces DenselyOrdered
- **No min/max**: Seriality axioms force NoMinOrder, NoMaxOrder

**Tasks:**
- [ ] Prove `DenselyOrdered CanonicalQuot` using DN axiom derivability
- [ ] Prove `NoMinOrder CanonicalQuot` using backward seriality
- [ ] Prove `NoMaxOrder CanonicalQuot` using forward seriality
- [ ] Bundle into `CountableDenseLinearOrder CanonicalQuot`

**Timing:** 2-3 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalQuot.lean`
  - Add `denselyOrdered_canonicalQuot : DenselyOrdered CanonicalQuot`
  - Add `noMinOrder_canonicalQuot : NoMinOrder CanonicalQuot`
  - Add `noMaxOrder_canonicalQuot : NoMaxOrder CanonicalQuot`

**Verification:**
- All order instances compile
- DN axiom usage traced to proof system

---

### Phase 3: FMCS over CanonicalQuot with Temporal Coherence [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Build FMCS over CanonicalQuot with proven forward_F/backward_P

**Key Insight:** Witnesses survive quotienting because:
- `canonical_forward_F` gives witness W with `CanonicalR M W` and `phi in W`
- Quotienting: `[M] < [W]` and `phi in canonicalQuotMCS [W]`
- The witness W projects to a valid witness in the quotient

**Tasks:**
- [ ] Define `CanonicalQuotFMCS : FMCS CanonicalQuot` structure
- [ ] Prove `forward_G` coherence (from canonicalMCS_forward_G + quotient)
- [ ] Prove `backward_H` coherence (from canonicalMCS_backward_H + quotient)
- [ ] Prove `forward_F` witness exists (key lemma: witnesses project correctly)
- [ ] Prove `backward_P` witness exists (symmetric)
- [ ] Construct `construct_fmcs_canonicalquot : (M : Set Formula) -> SetMaximalConsistent M -> FMCS CanonicalQuot`

**Timing:** 3-4 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalQuotFMCS.lean`
  - `CanonicalQuotFMCS : FMCS CanonicalQuot`
  - `canonicalQuotFMCS_forward_G`, `canonicalQuotFMCS_backward_H`
  - `canonicalQuotFMCS_forward_F`, `canonicalQuotFMCS_backward_P`
  - `construct_fmcs_canonicalquot`

**Verification:**
- All temporal coherence lemmas compile without sorry
- `forward_F`, `backward_P` provide concrete witnesses

---

### Phase 4: Cantor Isomorphism and Transfer to Rat [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Apply Cantor theorem to get CanonicalQuot ≃ Rat, transfer FMCS

**Tasks:**
- [ ] Apply Mathlib `Order.iso_of_countable_dense` to get `CanonicalQuot ≃o Rat`
- [ ] Define `RatFMCS : FMCS Rat` by transferring through isomorphism
- [ ] Prove temporal coherence properties transfer
- [ ] Construct `construct_bfmcs_rat : (M : Set Formula) -> SetMaximalConsistent M -> BFMCS Rat`
- [ ] Verify `RatBFMCS.temporally_coherent`

**Timing:** 2-3 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/Algebraic/RatTransfer.lean`
  - `canonicalQuot_iso_rat : CanonicalQuot ≃o Rat`
  - `RatFMCS : FMCS Rat`
  - `RatBFMCS : BFMCS Rat`
  - `construct_bfmcs_rat`

**Verification:**
- Cantor isomorphism exists (Mathlib provides)
- All transfer lemmas compile

---

### Phase 5: Wiring and Dense Algebraic Completeness [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Wire to parametric representation and prove completeness

**Tasks:**
- [ ] Instantiate `parametric_algebraic_representation_conditional` with `construct_bfmcs_rat`
- [ ] Prove `dense_representation : not_provable phi -> exists countermodel`
- [ ] Verify DN axiom valid in DenseCanonicalTaskFrame Rat
- [ ] Prove contrapositive: `valid_dense phi -> provable phi`
- [ ] Create final `dense_algebraic_completeness` theorem
- [ ] Add to module imports and verify full build

**Timing:** 3-4 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean`
  - Import RatTransfer.lean
  - Add `dense_algebraic_completeness : valid_dense phi -> Nonempty (DerivationTree [] phi)`

**Verification:**
- `lake build` passes
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/*.lean` returns empty for new files
- `grep -n "^axiom "` shows no new axioms

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] All new files have zero sorries
- [ ] No new axioms introduced
- [ ] `dense_algebraic_completeness` theorem exists and type-checks

### Theorem Verification
- [ ] `CanonicalQuot` has all required instances (LinearOrder, Countable, DenselyOrdered, etc.)
- [ ] `canonicalQuotFMCS_forward_F` provides concrete witnesses
- [ ] `canonicalQuot_iso_rat` is an OrderIso

## Artifacts & Outputs

New files:
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalQuot.lean`
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalQuotFMCS.lean`
- `Theories/Bimodal/Metalogic/Algebraic/RatTransfer.lean`

Modified files:
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean`

Summary:
- `specs/988_dense_algebraic_completeness/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If CanonicalQuot approach encounters issues:
1. Check if `mutual_le_implies_mcs_eq` is available/proven
2. May need to prove equivalence classes have unique MCS
3. If multi-family BFMCS needed for modal_backward, follow ModalSaturation.lean pattern

The CanonicalQuot approach is mathematically correct and should not encounter fundamental blockers (unlike v1).
