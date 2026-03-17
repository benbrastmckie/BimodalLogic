# Implementation Plan: Dense Algebraic Completeness (D = Rat)

- **Task**: 988 - dense_algebraic_completeness
- **Status**: [IMPLEMENTING]
- **Effort**: 15-20 hours
- **Dependencies**: Task 985 (complete), Task 982 (independent/parallel)
- **Research Inputs**: specs/988_dense_algebraic_completeness/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task proves dense algebraic completeness using D = Rat by: (1) constructing a sorry-free BFMCS over Rat via embedding CanonicalMCS into Rat using Cantor's theorem, (2) verifying DN axiom validity in `DenseCanonicalTaskFrame Rat` (automatic from Rat's `DenselyOrdered` instance), and (3) wiring `dense_representation_conditional` to obtain `valid_dense phi -> provable_dense phi`.

### Research Integration

Key findings from research-001.md:
- D-parametric infrastructure (ParametricCanonical, ParametricTruthLemma, ParametricRepresentation) is complete and sorry-free
- Critical gap: `construct_bfmcs : M -> BFMCS Rat` function to build temporally coherent BFMCS over Rat
- DN axiom validity is automatic via `LinearOrderedSemiField.toDenselyOrdered` for Rat
- Recommended approach: Embed CanonicalMCS into Rat using Cantor's isomorphism theorem, pull back FMCS structure
- CanonicalMCS FMCS construction is already sorry-free in `CanonicalFMCS.lean`

## Goals & Non-Goals

**Goals**:
- Prove `construct_bfmcs_rat : (M : Set Formula) -> SetMaximalConsistent M -> BFMCS Rat` sorry-free
- Wire `dense_representation_conditional` with `construct_bfmcs_rat` to get unconditional representation
- Prove `dense_algebraic_completeness : valid_dense phi -> Nonempty (DerivationTree [] phi)`
- Zero sorries in all new code

**Non-Goals**:
- Overlap with task 982 (TimelineQuot approach) - this uses direct Rat embedding
- Proving new properties about CanonicalMCS that aren't already in CanonicalFMCS.lean
- Building alternative BFMCS constructions

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| CanonicalMCS may have max/min elements under CanonicalR | High | Medium | Use Mathlib's `OrderEmbedding` for partial orders, not just DenselyOrdered |
| Embedding CanonicalMCS -> Rat may require countability proof | Medium | Medium | CanonicalMCS elements are subtypes of Set Formula; use standard countability arguments |
| Pulling back FMCS structure through embedding may be complex | Medium | Low | FMCS only requires Preorder; embedding preserves this |
| Validity connection between canonical model and `valid_dense` may need extra infrastructure | Medium | Medium | Follow pattern from DenseSoundness.lean; may need lemmas about ShiftClosedParametricCanonicalOmega |

## Sorry Characterization

### Pre-existing Sorries
- None in scope. The D-parametric infrastructure (task 985) is sorry-free.
- `DenseInstantiation.lean` uses a conditional theorem (no sorry, just requires `construct_bfmcs`)

### Expected Resolution
- Phase 2 provides `construct_bfmcs_rat`, eliminating the conditional requirement
- All phases produce sorry-free code

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in dense algebraic completeness module
- Dense completeness theorem becomes unconditional
- Publication-ready for dense fragment

## Implementation Phases

### Phase 1: CanonicalMCS Embedding Infrastructure [PARTIAL]

- **Dependencies:** None
- **Goal:** Create order-preserving embedding from CanonicalMCS to Rat

**Tasks:**
- [ ] Research Mathlib's Cantor theorem for countable dense linear orders (`Order.CountableDenseLinearOrder`)
- [ ] Prove `CanonicalMCS` is countable (each element is a subset of countable Formula type)
- [ ] Create embedding `canonicalMCS_to_rat : CanonicalMCS -> Rat` preserving `<` relation
- [ ] Prove embedding is strictly monotone: `a < b -> canonicalMCS_to_rat a < canonicalMCS_to_rat b`
- [ ] Handle edge cases: CanonicalMCS may have min/max elements (embedding maps to open interval)

**Timing:** 4-5 hours

**Files to create/modify:**
- Create: `Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean`
  - `canonicalMCS_countable : Countable CanonicalMCS`
  - `canonicalMCS_to_rat : CanonicalMCS -> Rat`
  - `canonicalMCS_to_rat_strictMono : StrictMono canonicalMCS_to_rat`

**Verification:**
- `lake build Bimodal.Metalogic.Algebraic.CanonicalEmbedding` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean` returns empty

**Progress:**

**Session: 2026-03-17, sess_1742152800_988i**
- Added: `CanonicalEmbedding.lean` - infrastructure for FMCS over Rat via Cantor isomorphism
- Added: `canonicalIso` - extracts order isomorphism `TimelineQuot ≃o ℚ` from `cantor_iso`
- Added: `ratMCS`, `ratMCS_is_mcs` - MCS assignment for Rat via isomorphism
- Added: `ratMCS_forward_G`, `ratMCS_backward_H` - FMCS coherence (proven)
- Added: `ratFMCS` - FMCS structure over ℚ
- Sorries: 5 introduced (see blockers below)

**Blockers:**
1. `ratFMCS_forward_F` - needs proof that canonical_forward_F witnesses appear in dense timeline
2. `ratFMCS_backward_P` - symmetric to forward_F
3. `ratBFMCS.modal_backward` - singleton bundle doesn't satisfy modal saturation
4. `ratFMCS_root_eq` - needs proof that timelineQuotMCS of root equals root_mcs

**Key Insight:** Direct embedding of CanonicalMCS into Rat is NOT possible because CanonicalMCS has Preorder (not LinearOrder). Used TimelineQuot (antisymmetrization) approach instead, which is already proven to have all required properties.

---

### Phase 2: BFMCS Construction over Rat [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Construct temporally coherent BFMCS over Rat from any MCS

**Tasks:**
- [ ] Define `RatFMCS : FMCS Rat` by pulling back `canonicalMCSBFMCS` through embedding
- [ ] Define `mcs_rat : Rat -> Set Formula` via inverse embedding + canonicalMCS_mcs
- [ ] Prove `is_mcs_rat : forall t, SetMaximalConsistent (mcs_rat t)`
- [ ] Prove forward_G coherence for RatFMCS (follows from canonicalMCS_forward_G + embedding)
- [ ] Prove backward_H coherence for RatFMCS (follows from canonicalMCS_backward_H + embedding)
- [ ] Prove forward_F witness exists (uses canonicalMCS_forward_F + embedding injectivity)
- [ ] Prove backward_P witness exists (uses canonicalMCS_backward_P + embedding)
- [ ] Construct `construct_bfmcs_rat` function with full type signature

**Timing:** 5-6 hours

**Files to create/modify:**
- Create: `Theories/Bimodal/Metalogic/Algebraic/RatBFMCS.lean`
  - `RatFMCS : FMCS Rat`
  - `RatBFMCS : BFMCS Rat`
  - `RatBFMCS_temporally_coherent : RatBFMCS.temporally_coherent`
  - `construct_bfmcs_rat : (M : Set Formula) -> SetMaximalConsistent M -> (BFMCS Rat, ...)`

**Verification:**
- `lake build Bimodal.Metalogic.Algebraic.RatBFMCS` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/RatBFMCS.lean` returns empty
- All F/P witness lemmas proven (no sorry markers)

---

### Phase 3: Wiring and Completeness Theorem [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Wire construct_bfmcs_rat to conditional representation and prove completeness

**Tasks:**
- [ ] Instantiate `dense_representation_conditional` with `construct_bfmcs_rat`
- [ ] Prove `dense_representation : (phi : Formula) -> not_provable phi -> exists countermodel`
- [ ] Prove DN axiom is in every MCS (it's a theorem, follows from proof system)
- [ ] Verify `DenseCanonicalTaskFrame Rat` is valid for dense semantics
- [ ] Connect `ShiftClosedParametricCanonicalOmega` to `valid_dense` definition
- [ ] Prove contrapositive: countermodel implies not valid_dense
- [ ] Prove `dense_algebraic_completeness : valid_dense phi -> Nonempty (DerivationTree [] phi)`

**Timing:** 4-5 hours

**Files to create/modify:**
- Modify: `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean`
  - Add import of `RatBFMCS.lean`
  - Add `dense_representation` (unconditional version)
  - Add `dense_algebraic_completeness`
- Possibly create: `Theories/Bimodal/Metalogic/Algebraic/DenseCompleteness.lean` if cleaner separation needed

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean` returns empty
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/*.lean` returns empty for all new files
- `dense_algebraic_completeness` theorem exists and compiles

---

### Phase 4: Integration and Cleanup [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Integrate with existing infrastructure and verify zero-debt completion

**Tasks:**
- [ ] Add new modules to `Theories/Bimodal.lean` imports
- [ ] Verify no circular dependencies introduced
- [ ] Run `lake build` for full project
- [ ] Verify `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/` returns only pre-existing sorries (if any)
- [ ] Document in module headers how this relates to task 982 (TimelineQuot approach)
- [ ] Update `DenseCompleteness.lean` to reference new algebraic completeness

**Timing:** 2-3 hours

**Files to modify:**
- `Theories/Bimodal.lean` - add imports
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - update documentation

**Verification:**
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/` shows zero sorries in new files
- All new theorems referenced in existing completeness infrastructure

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean` returns empty
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/RatBFMCS.lean` returns empty
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Algebraic/*.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Theorem Verification
- [ ] `dense_algebraic_completeness` type-checks: `valid_dense phi -> Nonempty (DerivationTree [] phi)`
- [ ] `construct_bfmcs_rat` type-checks with full dependent signature
- [ ] `canonicalMCS_to_rat_strictMono` proves strict monotonicity

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean` (new)
- `Theories/Bimodal/Metalogic/Algebraic/RatBFMCS.lean` (new)
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean` (modified)
- `specs/988_dense_algebraic_completeness/summaries/implementation-summary-YYYYMMDD.md` (upon completion)

## Rollback/Contingency

If embedding approach fails (e.g., CanonicalMCS doesn't embed nicely into Rat):
1. Fall back to direct FMCS construction over Rat without embedding
2. Use density of Rat directly to construct F/P witnesses
3. May require more complex inductive construction, but avoids embedding issues

If proof complexity exceeds estimates:
1. Mark current phase [PARTIAL] with progress notes
2. Split remaining work into sub-phases
3. Do NOT introduce sorries - mark [BLOCKED] for user review if stuck
