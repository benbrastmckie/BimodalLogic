# Implementation Plan: Task #827

- **Task**: 827 - Complete multi-family BMCS construction to resolve modal_backward sorry
- **Status**: [IMPLEMENTING]
- **Effort**: 40 hours
- **Dependencies**: Task 818 (Bimodal metalogic refactor - completed)
- **Research Inputs**: specs/827_complete_multi_family_bmcs_construction/reports/research-002.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implement mathematically correct multi-family BMCS construction that eliminates the `modal_backward` sorry at Construction.lean line 255. The previous plan (implementation-001.md) created saturation infrastructure but could not saturate the single-family BMCS. This revision implements the **restricted construction approach** from research-002.md: work within a finite subformula closure, use restricted MCS construction via Lindenbaum, and iteratively add witness families for Diamond formulas with termination proof based on closure finiteness.

### Research Integration

Research-002.md provides the complete mathematical specification for sorry elimination:
- Single-family BMCS cannot prove modal_backward (would require invalid `phi -> Box phi`)
- Saturation requires multi-family construction with witness families for every Diamond formula
- Termination requires working in finite subformula closure (not arbitrary MCS)
- Restricted Lindenbaum construction only adds formulas from closure (prevents unbounded growth)
- Iterative saturation terminates because finite Diamond formulas need witnesses

## Goals & Non-Goals

**Goals**:
- Implement subformula closure infrastructure with finiteness proof
- Implement restricted MCS construction (Lindenbaum within closure)
- Build iterative saturation process with termination proof
- Assemble saturated BMCS from family collection
- Eliminate modal_backward sorry in Construction.lean
- Integrate saturated construction into existing completeness theorem

**Non-Goals**:
- Modifying single-family BMCS (research shows it cannot be saturated)
- Implementing arbitrary-context construction (requires closure fixing)
- Addressing temporal backward direction sorries (separate task 828)
- Implementing FDSM saturation (separate task 825/826)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Restricted Lindenbaum more complex than expected | High | Medium | Accept additional axiom if necessary (still eliminates sorry) |
| Termination proof requires complex well-founded relation | High | High | Use Finset.card as measure, leverage closure finiteness |
| Temporal coherence for new families difficult | Medium | Medium | New families use constant MCS pattern (matches existing approach) |
| Integration breaks existing completeness proofs | Medium | Low | Extend rather than modify existing structure, verify Completeness.lean still compiles |
| Subformula closure definition incomplete | Low | Medium | Define recursively following standard modal logic textbooks |

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry in `Construction.lean` at line 255 (`singleFamilyBMCS.modal_backward`)
- This sorry exists because single-family BMCS cannot prove `phi -> Box phi` (not valid in modal logic)

### Expected Resolution
- Phase 4 creates `MultiFamilyBMCS` structure with saturated families
- Phase 5 proves `saturated_bmcs.modal_backward` without sorry (uses saturation predicate)
- Phase 5 integrates saturated construction into `construct_bmcs` function
- Sorry eliminated by replacing single-family construction with saturated multi-family construction

### New Sorries
- None expected. If restricted Lindenbaum proves too complex, may introduce axiom (not sorry) for MCS extension within closure.
- Any temporary sorries during development will be documented with remediation timeline.

### Remaining Debt
After this implementation:
- 0 sorries expected in `Construction.lean` for modal_backward
- `saturated_modal_backward` theorem already proven without sorry (from implementation-001.md)
- Completeness theorem no longer inherits modal_backward sorry
- Publication no longer blocked by this specific sorry

## Implementation Phases

### Phase 1: Subformula Closure Infrastructure [IN PROGRESS]

**Goal**: Define subformula closure for formulas with finiteness proof

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Syntax/SubformulaClosure.lean`
- [ ] Define recursive `subformulas` function covering all formula constructors
- [ ] Prove `subformulas_finite` (closure is finite Finset)
- [ ] Define `closure` as subformulas union with their negations
- [ ] Define `diamond_subformulas` filter for Diamond formulas in closure
- [ ] Add imports to `Theories/Bimodal/Syntax.lean`

**Timing**: 5 hours

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Create new file
- `Theories/Bimodal/Syntax.lean` - Add import

**Verification**:
- `lake build` succeeds on new file
- `subformulas_finite` compiles without sorry
- Closure definition handles all formula cases (atom, bot, imp, box, all_future, all_past)

---

### Phase 2: Restricted MCS Construction [NOT STARTED]

**Goal**: Implement MCS construction restricted to finite closure

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean`
- [ ] Define `RestrictedMCS` as subtype of Set Formula with closure subset constraint
- [ ] Prove `restricted_lindenbaum`: extends consistent set to MCS within closure
- [ ] Prove `restricted_mcs_consistent`: RestrictedMCS satisfies consistency
- [ ] Prove `restricted_mcs_maximal`: RestrictedMCS is maximal within closure
- [ ] Prove `restricted_mcs_negation_complete`: For phi in closure, either phi or neg phi in MCS
- [ ] Add imports to `Theories/Bimodal/Metalogic/Core.lean`

**Timing**: 10 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Create new file
- `Theories/Bimodal/Metalogic/Core.lean` - Add import

**Verification**:
- `lake build` succeeds
- `restricted_lindenbaum` compiles (may use Classical.choice/axiom of choice)
- All restricted MCS properties proven
- RestrictedMCS can be coerced to IndexedMCSFamily D

---

### Phase 3: Iterative Saturation with Termination Proof [NOT STARTED]

**Goal**: Build saturation function that iteratively adds witness families with termination proof

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean`
- [ ] Define `unsatisfied_diamonds` predicate: Diamond formulas in families without witnesses
- [ ] Define `saturation_step`: adds one witness family for unsatisfied diamond
- [ ] Prove `saturation_step_reduces`: each step reduces unsatisfied diamond count
- [ ] Define `saturate_families` using well-founded recursion on (closure.card - satisfied_count)
- [ ] Prove `saturate_families_terminates`: recursion measure decreases each step
- [ ] Prove `saturate_families_preserves_validity`: new families satisfy modal_forward
- [ ] Add imports to `Theories/Bimodal/Metalogic/Bundle.lean`

**Timing**: 15 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Create new file
- `Theories/Bimodal/Metalogic/Bundle.lean` - Add import

**Verification**:
- `lake build` succeeds
- `saturate_families` compiles with explicit termination proof (no sorry in decreasing_by)
- Termination measure uses Finset.card (well-founded on Nat)
- Each recursive call strictly decreases measure

---

### Phase 4: BMCS Assembly from Saturated Families [NOT STARTED]

**Goal**: Assemble BMCS structure from saturated family collection

**Tasks**:
- [ ] In `SaturatedConstruction.lean`, define `construct_initial_family`: creates first family from formula
- [ ] Define `assemble_bmcs`: builds BMCS from saturated family collection
- [ ] Prove `assemble_bmcs_modal_forward`: Box phi in new_fam implies phi in all families
- [ ] Prove `assemble_bmcs_modal_backward`: requires saturation (deferred to Phase 5)
- [ ] Prove `assemble_bmcs_temporal_coherence`: forward_G, backward_H, etc. hold
- [ ] Define `construct_saturated_bmcs`: end-to-end construction for a formula

**Timing**: 5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Add assembly functions

**Verification**:
- `construct_saturated_bmcs` compiles
- Returns valid BMCS structure (satisfies all BMCS fields)
- Temporal coherence proven for all families (forward_G, backward_H, forward_F, backward_P)

---

### Phase 5: Integration with Existing Completeness [NOT STARTED]

**Goal**: Replace single-family construction with saturated construction and eliminate sorry

**Tasks**:
- [ ] In `Construction.lean`, import `SaturatedConstruction`
- [ ] Replace `singleFamilyBMCS` usage with call to `construct_saturated_bmcs`
- [ ] Verify `modal_backward` proof uses `saturated_modal_backward` from ModalSaturation.lean
- [ ] Update `construct_bmcs` function to use saturated construction
- [ ] Verify Completeness.lean still compiles without changes to theorem statements
- [ ] Run `lake build` on full Bimodal theory to ensure no regressions
- [ ] Document sorry elimination in Construction.lean comments

**Timing**: 5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Replace single-family with saturated
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Verify no changes needed

**Verification**:
- `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/Construction.lean | grep modal_backward` returns 0 results
- `lake build` succeeds with no new errors
- Completeness theorem compiles unchanged
- Truth lemma still applies (uses modal_backward as hypothesis)

---

## Testing & Validation

- [ ] `lake build` succeeds on full project with no new errors
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/Construction.lean` shows 1 fewer sorry than before
- [ ] SubformulaClosure.lean compiles with all finiteness proofs
- [ ] RestrictedMCS.lean compiles with restricted_lindenbaum proven
- [ ] SaturatedConstruction.lean compiles with termination proof (no sorry in decreasing_by)
- [ ] Completeness.lean compiles without modifications to theorem statements
- [ ] Truth lemma applies to saturated BMCS (uses modal_backward field)

## Artifacts & Outputs

- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - New file (Phase 1)
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - New file (Phase 2)
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - New file (Phase 3-4)
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Modified (Phase 5)
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Already exists from implementation-001.md
- `specs/827_complete_multi_family_bmcs_construction/summaries/implementation-summary-YYYYMMDD.md` - Implementation summary

## Rollback/Contingency

If implementation fails or introduces regressions:
1. Revert Construction.lean to use `singleFamilyBMCS` (sorry remains but system functional)
2. Keep new files (SubformulaClosure, RestrictedMCS, SaturatedConstruction) for future work
3. Document specific blocker in error report
4. Alternative: If restricted Lindenbaum proves too complex, accept explicit axiom for restricted extension existence (still eliminates sorry, maintains proof-theoretic correctness)
5. Partial completion: If Phases 1-3 complete but Phase 4-5 fail, keep infrastructure and document remaining work
