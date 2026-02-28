# Implementation Plan: Task #951

- **Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
- **Status**: [NOT STARTED]
- **Effort**: 35-60 hours
- **Dependencies**: Task 950 (research), CanonicalFMCS.lean infrastructure
- **Research Inputs**:
  - specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-001.md
  - specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-002.md
  - specs/archive/945_canonical_model_construction_design/reports/research-003.md
  - specs/archive/945_canonical_model_construction_design/reports/research-004.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implement a sorry-free completeness theorem for bimodal logic using the **antisymmetrization approach** via CanonicalMCS infrastructure. The strategy constructs a Z-indexed chain through CanonicalMCS using incremental dovetailing, where each F/P witness is an independent Lindenbaum MCS added to the chain. The chain elements are fixed after construction, avoiding the GContent-corruption failure mode of the Int-indexed DovetailingChain approach. The linearity axiom ensures mutual comparability of witnesses from the same MCS.

### Research Integration

**From research-002.md (antisymmetrization approach)**:
- CanonicalMCS elements are world-states (not times); times emerge as equivalence classes within maximal chains
- Antisymmetrization quotient yields LinearOrder representing time structure
- Dovetailing over CanonicalMCS avoids GContent-corruption by using fixed, independent Lindenbaum witnesses
- Central risk: proving witnesses from different chain elements are mutually comparable
- Estimated 35-60 hours, 55-70% success probability

**From research-003.md and research-004.md (task 945)**:
- The time-state coupling in CanonicalMCS prevents modal saturation when using CanonicalMCS as D
- D = Z is correct for completeness (standard semantics requires AddCommGroup)
- Each chain step should be a direct CanonicalR-successor to ensure comparability
- Modal saturation requires separate chains for diamond witnesses (same dovetailing construction)

## Goals & Non-Goals

**Goals**:
- Eliminate the sorry in `fully_saturated_bfmcs_exists_int` (TemporalCoherentConstruction.lean:600)
- Prove `forward_F` and `backward_P` for a Z-indexed chain through CanonicalMCS
- Achieve modal saturation via separate dovetailed chains for diamond witnesses
- Bridge to standard `valid`/`semantic_consequence` (which requires `LinearOrderedAddCommGroup D`)
- Maintain zero new sorries (resolve existing, introduce none)

**Non-Goals**:
- Generalizing standard semantics to Preorder D (would require changing paper specification)
- Proving density or discreteness axioms (current logic has neither)
- Modifying the existing DovetailingChain.lean (create new module instead)
- Removing axioms from current proofs (only eliminating sorries)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cross-element witness comparability fails | High | Medium | Build chain sequentially; each element is direct CanonicalR-successor of previous |
| Omega-squared enumeration complexity | Medium | Low | Standard technique; enumerate (time, obligation) pairs diagonally |
| Modal saturation for witness families | High | Medium | Each witness family is a separate chain; same dovetailing construction |
| Linearity axiom insufficient for full chain | High | Low | Literature confirms sufficiency for step-by-step construction (Goldblatt 1992) |
| Formalization exceeds 60 hours | Medium | Medium | Prototype chain construction and comparability lemma in Phase 1 first |
| Integration with existing Representation.lean | Medium | Low | Keep Int specialization; no generalization needed |

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry in `TemporalCoherentConstruction.lean:600` (`fully_saturated_bfmcs_exists_int`)
- 2 sorries in `DovetailingChain.lean:1869,1881` (`forward_F`, `backward_P`)

### Expected Resolution
- Phase 3 and Phase 4 resolve forward_F and backward_P via new chain construction
- Phase 5 combines temporal coherence + modal saturation to eliminate `fully_saturated_bfmcs_exists_int` sorry

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in completeness chain
- Downstream theorems (`standard_weak_completeness`, `standard_strong_completeness`) will no longer inherit sorry status
- Existing DovetailingChain sorries become dead code (superseded by new construction)

## Implementation Phases

### Phase 1: Infrastructure - Z-Indexed Chain Type and Basic Properties [NOT STARTED]

- **Dependencies:** None
- **Goal:** Define the core data structure for a Z-indexed chain through CanonicalMCS with basic ordering properties

**Tasks:**
- [ ] Create new module `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean`
- [ ] Define `ChainElement` structure wrapping MCS with chain position metadata
- [ ] Define `CanonicalChain` structure: function `Z -> CanonicalMCS` with ordering invariants
- [ ] Prove `chain_ordered`: for all n, `CanonicalR chain(n) chain(n+1)` (GContent inclusion)
- [ ] Prove `chain_ordered_neg`: for all n, `CanonicalR chain(-n-1) chain(-n)` (backward direction)
- [ ] Import and verify compatibility with existing `CanonicalFMCS.lean` and `CanonicalFrame.lean`

**Timing:** 6-10 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` - new file

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.CanonicalChain` passes
- No sorries in new file
- `lean_goal` shows "no goals" for all theorems

---

### Phase 2: Dovetailing Enumeration and Obligation Processing [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Implement omega-squared enumeration of F/P obligations and the processing logic

**Tasks:**
- [ ] Define `Obligation` inductive type: `ForwardF (t : Z) (phi : Formula)` | `BackwardP (t : Z) (phi : Formula)`
- [ ] Define `enumerateObligations : Z -> Set (Z x Formula)` collecting all F/P obligations from constructed MCS
- [ ] Define `diagonalEnumeration : N -> Obligation` that enumerates (time, obligation) pairs
- [ ] Prove `diagonalEnumeration_surjective`: every obligation is eventually enumerated
- [ ] Define `processObligation : CanonicalChain -> Obligation -> CanonicalChain` extending chain with witness
- [ ] Prove processed witness satisfies `CanonicalR` ordering constraint with chain predecessors

**Timing:** 8-12 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` - extend

**Verification:**
- `lake build` passes
- No sorries in enumeration and processing logic
- `lean_goal` confirms obligation tracking is complete

---

### Phase 3: Forward F via Dovetailed Chain [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Prove forward_F for the dovetailed chain construction

**Tasks:**
- [ ] Define `buildChainForward : CanonicalMCS -> N -> CanonicalChain` (forward direction from root)
- [ ] Prove `forward_witness_in_chain`: for F(phi) at position t, witness phi exists at position s > t
- [ ] Prove witness placement: the Lindenbaum witness from `canonical_forward_F` is placed at next available position
- [ ] Prove comparability: new witness is CanonicalR-comparable with all existing chain elements
- [ ] Prove `forward_F_dovetailed`: full forward_F property for the constructed chain
- [ ] Verify linearity axiom usage: ensure `temp_linearity` constrains witness ordering correctly

**Timing:** 8-12 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` - extend

**Verification:**
- `lake build` passes
- `grep -rn "\bsorry\b" CanonicalChain.lean` returns empty
- `lean_goal` shows "no goals" for forward_F theorem
- If proof stuck: mark [BLOCKED] with `requires_user_review: true` and document obstacle

---

### Phase 4: Backward P via Dovetailed Chain [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Prove backward_P for the dovetailed chain construction (symmetric to Phase 3)

**Tasks:**
- [ ] Define `buildChainBackward : CanonicalMCS -> N -> CanonicalChain` (backward direction from root)
- [ ] Prove `backward_witness_in_chain`: for P(phi) at position t, witness phi exists at position s < t
- [ ] Use `canonical_backward_P` for witness existence and `HContent_subset_implies_GContent_reverse` for ordering
- [ ] Prove comparability: new backward witness is CanonicalR-comparable with existing chain elements
- [ ] Prove `backward_P_dovetailed`: full backward_P property for the constructed chain
- [ ] Integrate forward and backward construction into unified bidirectional chain

**Timing:** 6-10 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` - extend

**Verification:**
- `lake build` passes
- `grep -rn "\bsorry\b" CanonicalChain.lean` returns empty
- `lean_goal` shows "no goals" for backward_P theorem
- If proof stuck: mark [BLOCKED] with `requires_user_review: true` and document obstacle

---

### Phase 5: Modal Saturation via Witness Chain Families [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Build modally saturated BFMCS using separate chains for diamond witnesses

**Tasks:**
- [ ] Define `WitnessChain : CanonicalMCS -> Z -> CanonicalChain` (chain rooted at diamond witness)
- [ ] Prove each witness chain is temporally coherent (same argument as eval family)
- [ ] Define `BundleOfChains : BFMCS Int` combining eval chain + all witness chains
- [ ] Prove `modal_forward`: Box(phi) in eval chain at t implies phi in all witness chains at t
- [ ] Prove `modal_backward`: phi in all chains at t implies Box(phi) in eval chain at t (via `saturated_modal_backward`)
- [ ] Prove `is_modally_saturated BundleOfChains`: every diamond obligation has witness family

**Timing:** 10-15 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` - extend
- OR create `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` - new file

**Verification:**
- `lake build` passes
- No sorries in modal saturation construction
- `lean_goal` shows "no goals" for modal_forward, modal_backward, is_modally_saturated

---

### Phase 6: Eliminate fully_saturated_bfmcs_exists_int Sorry [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Replace the sorry in fully_saturated_bfmcs_exists_int with the new construction

**Tasks:**
- [ ] Create `fully_saturated_bfmcs_exists_int_proven` theorem using Phase 5 construction
- [ ] Verify all three properties: context preservation, temporal coherence, modal saturation
- [ ] Update `TemporalCoherentConstruction.lean` to use new construction (or mark old sorry obsolete)
- [ ] Verify `construct_saturated_bfmcs_int` no longer inherits any sorry
- [ ] Run `lake build` on full Metalogic module to confirm no sorry propagation

**Timing:** 4-6 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - modify or extend
- `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` or new completeness file

**Verification:**
- `lake build` passes on full project
- `grep -rn "\bsorry\b" TemporalCoherentConstruction.lean Representation.lean CanonicalChain.lean` returns empty for new theorems
- Existing sorry in line 600 is either replaced or marked deprecated

---

### Phase 7: Bridge to Standard Validity and Update Exports [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Connect new construction to standard validity definitions and update module exports

**Tasks:**
- [ ] Verify `standard_representation` no longer inherits sorry
- [ ] Verify `standard_weak_completeness` and `standard_strong_completeness` are sorry-free
- [ ] Update `Theories/Bimodal/Metalogic.lean` exports to include new modules
- [ ] Add documentation header explaining the antisymmetrization approach
- [ ] Run full verification: `lake build` on entire project
- [ ] Create implementation summary documenting the construction

**Timing:** 3-5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic.lean` - update exports
- `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` - add documentation

**Verification:**
- `lake build` passes
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/` shows only expected/known sorries outside completeness chain
- All standard completeness theorems verified sorry-free

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <modified files>` returns empty for new proofs
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Completeness Verification
- [ ] `standard_weak_completeness` does not inherit sorry
- [ ] `standard_strong_completeness` does not inherit sorry
- [ ] `construct_saturated_bfmcs_int` returns sorry-free BFMCS
- [ ] Existing DovetailingChain sorries no longer in completeness chain

### Property Verification
- [ ] `forward_F_dovetailed` proven without sorry
- [ ] `backward_P_dovetailed` proven without sorry
- [ ] `is_modally_saturated BundleOfChains` proven without sorry
- [ ] All chain ordering properties (CanonicalR) verified

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` - new module
- `specs/951_implement_sorry_free_completeness_canonicalmcs/plans/implementation-001.md` - this plan
- `specs/951_implement_sorry_free_completeness_canonicalmcs/summaries/implementation-summary-YYYYMMDD.md` - completion summary

## Rollback/Contingency

If the construction fails to eliminate sorries:

1. **Partial Completion**: Keep completed phases as infrastructure even if later phases fail
2. **Isolation**: New CanonicalChain.lean module is independent; does not break existing code
3. **Escape Valve**: Mark [BLOCKED] phases with `requires_user_review: true` for user decision
4. **Alternative**: If antisymmetrization approach fails, consider:
   - FMP strong completeness via bigAnd (would need resurrection from Boneyard)
   - Different chain enumeration strategy (e.g., tree unraveling with careful inverse handling)
5. **Revert**: If construction introduces regressions, `git revert` to pre-implementation state

## Notes

**Key Mathematical Insight**: The antisymmetrization framework provides conceptual scaffolding but is not operationally required. The Z-indexed chain corresponds to a section of the Antisymmetrization quotient of its image in CanonicalMCS. Each step is a Lindenbaum extension that is fixed after construction.

**Critical Lemma**: The comparability of witnesses from different chain elements relies on the incremental construction: each new element is built as a direct CanonicalR-successor of the previous, ensuring the entire chain remains totally ordered.

**Literature Reference**: Goldblatt (1992) "Logics of Time and Computation" Chapter 4 confirms the step-by-step method for linear tense logic completeness using the linearity axiom to order F-witnesses.
