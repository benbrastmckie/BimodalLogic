# Implementation Plan: Refactor Representation Theorem for General Duration Types

- **Task**: 954 - Refactor representation theorem to avoid hardcoded Int
- **Status**: [NOT STARTED]
- **Effort**: 50 hours (45-75 range per research)
- **Dependencies**: Task 951 (completeness infrastructure), Task 922 (strategy study)
- **Research Inputs**: specs/954_refactor_representation_theorem_general_duration/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Refactor the representation theorem so that the duration type `D` is constructed purely from syntax as a totally ordered abelian group, rather than hardcoding `D = Int`. The construction follows a 5-step pipeline: BidirectionalFragment (Preorder) -> Antisymmetrization (LinearOrder) -> SuccOrder/PredOrder -> OrderIso to Z -> Transfer AddCommGroup. The refactored construction eliminates hardcoding at three points (CanonicalTaskFrame, canonicalFrame, standard_representation) while remaining compatible with future density axiom extensions.

### Research Integration

- **Research-001 (2026-03-03)**: Detailed analysis of current architecture, 5-step construction pipeline, Mathlib theorems (orderIsoIntOfLinearSuccPredArch, Equiv.addCommGroup), hardcoding points, and risk assessment. Key finding: coverness (immediate successor) proof is the primary technical challenge.

## Goals & Non-Goals

**Goals**:
- Construct D (BidirectionalQuotient) purely from syntactic operations on MCSes
- Derive AddCommGroup + LinearOrder + IsOrderedAddMonoid via Mathlib transfer
- Parameterize CanonicalTaskFrame, canonicalFrame, and representation over the syntactic D
- Design architecture compatible with future density axiom extension (D ~ Q)
- Achieve zero-sorry implementation with all proofs complete

**Non-Goals**:
- Implementing the dense canonical model (D ~ Q) for density axiom extension (future task)
- Modifying the `valid` definition (already quantifies over all D)
- Changing DovetailingChain.lean (Int-specific alternative construction, unaffected)
- Runtime performance optimization (noncomputable is fine for metalogic)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Coverness (immediate successor) proof intractable | High | Medium | Mark [BLOCKED] with review_reason if stuck; fallback: use chain enumeration instead of quotient successor |
| Fragment totality proof depends on linearity axiom | Medium | Low | Linearity axiom (temp_linearity) is in system; proof should follow from existing machinery |
| OrderIso transfer breaks IsOrderedAddMonoid | Medium | Low | Verify Mathlib's OrderIso.isOrderedAddMonoid handles this; use lean_hover to check |
| Quotient lifting for SuccOrder fails | Medium | Medium | Prove intermediate lemmas showing fragmentGSucc respects equivalence |
| BidirectionalFragment preorder not total | High | Low | Linearity axiom forces totality; if issue arises, review fragment definition |

## Sorry Characterization

### Pre-existing Sorries
- None in scope. This is new construction building on existing sorry-free infrastructure.

### Expected Resolution
- N/A (no pre-existing sorries to resolve)

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in new files (CanonicalDomain.lean, SuccessorAlgebra.lean, DomainTransfer.lean)
- 0 sorries expected in modified files (CanonicalConstruction.lean, CanonicalCompleteness.lean, Representation.lean)

## Implementation Phases

### Phase 1: SuccOrder and PredOrder on BidirectionalQuotient [NOT STARTED]

- **Dependencies:** None
- **Goal:** Establish SuccOrder and PredOrder instances on the BidirectionalQuotient, proving the critical coverness property

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Domain/SuccessorAlgebra.lean`
- [ ] Define `fragmentGSucc : BidirectionalFragment -> BidirectionalFragment` using Lindenbaum extension of GContent
- [ ] Define `fragmentHPred : BidirectionalFragment -> BidirectionalFragment` using Lindenbaum extension of HContent
- [ ] Prove `fragmentGSucc_respects_equiv`: if M ~ N in quotient, then fragmentGSucc(M) ~ fragmentGSucc(N)
- [ ] Prove `fragmentHPred_respects_equiv`: symmetric for predecessor
- [ ] Define `quotientSucc : BidirectionalQuotient -> BidirectionalQuotient` via quotient lifting
- [ ] Define `quotientPred : BidirectionalQuotient -> BidirectionalQuotient` via quotient lifting
- [ ] Prove coverness for succ: no element exists between [M] and succ([M])
- [ ] Prove coverness for pred: no element exists between pred([M]) and [M]
- [ ] Instantiate `SuccOrder BidirectionalQuotient`
- [ ] Instantiate `PredOrder BidirectionalQuotient`
- [ ] Verify `lake build` passes with no sorries

**Timing**: 15-25 hours (highest risk phase)

**Files to modify**:
- Create `Theories/Bimodal/Metalogic/Domain/SuccessorAlgebra.lean`
- May need to extend `BidirectionalReachable.lean` with helper lemmas

**Verification**:
- `lake build` passes
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/SuccessorAlgebra.lean` returns empty
- `SuccOrder BidirectionalQuotient` and `PredOrder BidirectionalQuotient` instances compile

**Contingency**: If coverness proof is blocked after exhausting approaches, mark [BLOCKED] with `requires_user_review: true` and document the specific obstacle. Fallback approach: use chain enumeration (index into fragment via well-ordering) instead of intrinsic successor.

---

### Phase 2: Archimedean and Unboundedness Properties [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Prove IsSuccArchimedean, NoMaxOrder, and NoMinOrder on BidirectionalQuotient

**Tasks**:
- [ ] Add to `SuccessorAlgebra.lean` or create `Theories/Bimodal/Metalogic/Domain/ArchUnbound.lean`
- [ ] Prove `mcs_has_F_top`: every MCS contains F(top) (may already exist; verify)
- [ ] Prove `mcs_has_P_top`: every MCS contains P(top) (may already exist; verify)
- [ ] Prove `NoMaxOrder BidirectionalQuotient`: for any [M], succ([M]) is strictly greater
- [ ] Prove `NoMinOrder BidirectionalQuotient`: for any [M], pred([M]) is strictly less
- [ ] Prove reachability: every element [M] is reachable from [M0] in finitely many succ/pred steps
- [ ] Prove `IsSuccArchimedean BidirectionalQuotient`: induction on fragment distance
- [ ] Verify all instances compile together

**Timing**: 5-10 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Domain/SuccessorAlgebra.lean` (extend)
- Or create `Theories/Bimodal/Metalogic/Domain/ArchUnbound.lean`

**Verification**:
- `lake build` passes
- `IsSuccArchimedean BidirectionalQuotient`, `NoMaxOrder BidirectionalQuotient`, `NoMinOrder BidirectionalQuotient` instances compile
- `grep -rn "\bsorry\b"` on modified files returns empty

---

### Phase 3: Order Isomorphism and Group Transfer [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Apply Mathlib's orderIsoIntOfLinearSuccPredArch and transfer AddCommGroup structure

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Domain/DomainTransfer.lean`
- [ ] Import Mathlib.Order.SuccPred.LinearLocallyFinite
- [ ] Import Mathlib.Algebra.Group.TransferInstance (or equivalent)
- [ ] Define `quotientOrderIsoInt : BidirectionalQuotient ≃o Z` using orderIsoIntOfLinearSuccPredArch
- [ ] Define `quotientEquivInt : BidirectionalQuotient ≃ Z` from the order isomorphism
- [ ] Instantiate `AddCommGroup BidirectionalQuotient` via Equiv.addCommGroup
- [ ] Instantiate `IsOrderedAddMonoid BidirectionalQuotient` via transfer from Z
- [ ] Verify the three typeclasses required by TaskFrame: AddCommGroup, LinearOrder, IsOrderedAddMonoid
- [ ] Verify `lake build` passes

**Timing**: 5-10 hours

**Files to modify**:
- Create `Theories/Bimodal/Metalogic/Domain/DomainTransfer.lean`

**Verification**:
- `lake build` passes
- All three typeclasses available on BidirectionalQuotient
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/DomainTransfer.lean` returns empty

---

### Phase 4: Parameterize Canonical Construction [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Replace hardcoded Int with syntactic BidirectionalQuotient in canonical construction files

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Domain/CanonicalDomain.lean` as unified interface
- [ ] Define `CanonicalD (M0 : MCS) := BidirectionalQuotient M0` with all instances
- [ ] Modify `CanonicalConstruction.lean`: replace `TaskFrame Int` with `TaskFrame (CanonicalD M0)`
- [ ] Update `canonical_task_rel` to use meaningful duration based on fragment step count
- [ ] Modify `CanonicalCompleteness.lean`: replace `BFMCS Int` with `BFMCS (CanonicalD M0)`
- [ ] Update `canonicalFrame` to use CanonicalD
- [ ] Modify `Representation.lean`: replace `satisfiable Int` with `satisfiable (CanonicalD M0)`
- [ ] Prove backward compatibility: existing theorems still hold with new parameterization
- [ ] Verify `lake build` passes for entire project

**Timing**: 10-15 hours

**Files to modify**:
- Create `Theories/Bimodal/Metalogic/Domain/CanonicalDomain.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean`
- `Theories/Bimodal/Metalogic/Representation.lean`

**Verification**:
- `lake build` passes with no errors
- `grep -rn "\bsorry\b"` on all modified files returns empty
- `grep -n "TaskFrame Int" Theories/Bimodal/` returns empty (no hardcoding)
- `grep -n "BFMCS Int" Theories/Bimodal/` returns empty (no hardcoding)

---

### Phase 5: TemporalTheory Abstraction and Verification [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Add TemporalTheory abstraction for future density extension compatibility; final verification

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Domain/TemporalTheory.lean`
- [ ] Define `inductive TemporalTheory` with `base`, `discrete`, `dense` variants
- [ ] Define `CanonicalDomain (T : TemporalTheory)` structure with D, instances
- [ ] For base/discrete: use BidirectionalQuotient construction (this task)
- [ ] For dense: leave as sorry-placeholder with clear TODO (out of scope)
- [ ] Add documentation explaining extension path for density axiom
- [ ] Run full `lake build` verification
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/` to verify zero sorries in completed code
- [ ] Verify no regression in existing theorems

**Timing**: 10-15 hours

**Files to modify**:
- Create `Theories/Bimodal/Metalogic/Domain/TemporalTheory.lean`
- May need minor updates to `CanonicalDomain.lean`

**Verification**:
- `lake build` passes
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/` shows only the expected `dense` placeholder (if any)
- All existing tests/theorems still compile
- Documentation explains density extension path

**Note**: The `dense` case may have a controlled sorry as a placeholder for future work. This is documented and out of scope for task 954. If implemented, it would be a separate task.

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/` returns empty (except documented dense placeholder)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Domain/` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Specific Validations
- [ ] `SuccOrder BidirectionalQuotient` instance compiles
- [ ] `PredOrder BidirectionalQuotient` instance compiles
- [ ] `IsSuccArchimedean BidirectionalQuotient` instance compiles
- [ ] `NoMaxOrder BidirectionalQuotient` instance compiles
- [ ] `NoMinOrder BidirectionalQuotient` instance compiles
- [ ] `quotientOrderIsoInt : BidirectionalQuotient ≃o Z` compiles
- [ ] `AddCommGroup BidirectionalQuotient` instance compiles
- [ ] `IsOrderedAddMonoid BidirectionalQuotient` instance compiles
- [ ] `TaskFrame (CanonicalD M0)` compiles
- [ ] `standard_representation` theorem still provable (now with CanonicalD)

### Integration Tests
- [ ] Existing completeness infrastructure still works
- [ ] No regressions in Representation.lean theorems
- [ ] DovetailingChain.lean unchanged and still compiles

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Domain/SuccessorAlgebra.lean` - SuccOrder/PredOrder on quotient (150-250 lines)
- `Theories/Bimodal/Metalogic/Domain/DomainTransfer.lean` - OrderIso and group transfer (100-150 lines)
- `Theories/Bimodal/Metalogic/Domain/CanonicalDomain.lean` - Unified interface (100-150 lines)
- `Theories/Bimodal/Metalogic/Domain/TemporalTheory.lean` - Extensibility abstraction (80-120 lines)
- Modified `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
- Modified `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean`
- Modified `Theories/Bimodal/Metalogic/Representation.lean`
- `specs/954_refactor_representation_theorem_general_duration/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

**If Phase 1 coverness proof fails**:
1. Mark phase [BLOCKED] with requires_user_review: true
2. Document the specific obstacle and attempted approaches
3. Fallback: Use chain enumeration instead of quotient successor
   - Enumerate BidirectionalFragment via well-ordering
   - Embed into Z via enumeration index
   - This achieves "D from syntax" without requiring intrinsic SuccOrder

**If Mathlib imports cause conflicts**:
1. Check Mathlib version compatibility
2. May need to update lakefile.lean dependencies
3. If irresolvable, implement transfer manually (more work but self-contained)

**General rollback**:
- All new files are in new `Domain/` subdirectory
- Modifications to existing files are additive (new parameterization)
- Can revert to Int-hardcoded version by reverting commits
- DovetailingChain.lean provides alternative completeness path if needed
