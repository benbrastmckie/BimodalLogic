# Implementation Plan: Task #958 - Product Frame Bulldozing Resolution

- **Task**: 958 - prove_canonicalr_irreflexive_irr_rule
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Dependencies**: naming_set_consistent (sorry-free), IRRSoundness.lean prod_frame infrastructure
- **Research Inputs**: specs/958_prove_canonicalr_irreflexive_irr_rule/reports/research-008.md
- **Artifacts**: plans/implementation-006.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Research-008.md definitively establishes that the naming argument gap is mathematically
unfixable for our String atoms formalization: when GContent(M) formulas mention p,
the IRR rule cannot be applied (the conclusion chi must be p-free, but GContent
injects p). This plan implements the recommended **product frame / bulldozing bypass**
approach that avoids the naming argument entirely.

### Research Integration

Key findings from research-008.md integrated into this plan:
- The naming argument requires global freshness which is impossible with String atoms
- The GContent transfer gap is not a search failure but a structural impossibility
- The product frame construction in IRRSoundness.lean provides existing infrastructure
- The FMCS/StagedTimeline construction may already guarantee irreflexivity (to be checked)

## Goals & Non-Goals

**Goals**:
- Resolve `canonicalR_irreflexive` theorem (currently with sorry)
- Unblock Task 956 Phase 6 (Cantor Isomorphism Application)
- Achieve zero-sorry status in CanonicalIrreflexivity.lean
- Document why naming argument is impossible for String atoms

**Non-Goals**:
- Re-attempting syntactic naming argument approaches (proven unfixable)
- Modifying the IRR rule or proof system
- Changing the Formula type's atom representation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| StagedTimeline does not already guarantee irreflexivity | MEDIUM | MEDIUM | Fall back to explicit product frame construction in Phase 1 |
| Product frame truth lemma transfer is complex | MEDIUM | LOW | IRRSoundness.lean provides existing truth_prod_iff infrastructure |
| Completeness integration requires significant refactoring | HIGH | MEDIUM | Design as wrapper module, minimize changes to existing files |
| Density preservation through product construction | MEDIUM | LOW | Mathematically verified in literature; IRRSoundness already handles this |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `CanonicalIrreflexivity.lean` (lines 1245, 1333): GContent transfer gap

### Expected Resolution
- Phase 2 provides alternative irreflexivity proof via product frame
- Phase 3 replaces sorry-using code with product frame approach
- Original naming argument sorries become dead code (removed in Phase 4)

### New Sorries
- None. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in `CanonicalIrreflexivity.lean`
- `canonicalR_irreflexive` fully proven via product frame bypass

## Implementation Phases

### Phase 0: Investigation - StagedTimeline Bypass Check [NOT STARTED]

- **Dependencies:** None
- **Goal:** Determine if StagedTimeline construction already guarantees irreflexivity

The FMCS construction in `StagedTimeline.lean` builds a timeline indexed by a dense
linear order D. Different time points have different MCS assignments by construction.
If the canonical relation R_timeline between adjacent MCSs is already irreflexive by
construction, then `canonicalR_irreflexive` may not be needed.

**Tasks**:
- [ ] Read `StagedTimeline.lean` and identify how CanonicalR relates to timeline ordering
- [ ] Check if different time points guarantee different MCSs (enforced by staged construction)
- [ ] Determine if the truth lemma uses `canonicalR_irreflexive` or if it can be bypassed
- [ ] Document findings and decision: proceed with Phase 1 (product frame) or bypass entirely

**Timing**: 1 hour

**Files to examine**:
- `Theories/Bimodal/Metalogic/Canonical/StagedTimeline.lean`
- `Theories/Bimodal/Metalogic/Canonical/TruthLemma.lean`
- `Theories/Bimodal/Metalogic/Completeness.lean`

**Verification**:
- Clear decision documented: bypass possible or product frame needed
- If bypass: outline of how completeness proceeds without `canonicalR_irreflexive`
- If product frame needed: confirm existing infrastructure suffices

---

### Phase 1: Product Frame Setup [NOT STARTED]

- **Dependencies:** Phase 0 (confirms product frame approach needed)
- **Goal:** Adapt prod_frame/prod_model from IRRSoundness for canonical model irreflexivity

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Canonical/ProductIrreflexivity.lean`
- [ ] Define `canonical_prod_frame`: product of canonical frame with time/indicator domain
- [ ] Define `canonical_prod_model`: valuation on product states projecting to canonical
- [ ] Prove `canonical_prod_irreflexive`: product relation is irreflexive by construction
- [ ] Prove `canonical_prod_dense`: density preserved through product construction

**Timing**: 2 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Canonical/ProductIrreflexivity.lean` (new, ~100-150 lines)

**Verification**:
- `lake build Bimodal.Metalogic.Canonical.ProductIrreflexivity` passes
- `grep -n "\bsorry\b" ProductIrreflexivity.lean` returns empty
- `canonical_prod_irreflexive` and `canonical_prod_dense` proven without sorry

---

### Phase 2: Truth Preservation [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Prove truth lemma transfers through product frame projection

**Tasks**:
- [ ] Define `proj_mcs`: projection from product-MCS pair to underlying MCS
- [ ] Prove `truth_prod_canonical_iff`: truth in product model iff truth in canonical model
- [ ] Verify preservation for all formula constructors (atom, bot, imp, box, H, G)
- [ ] Prove modal accessibility transfers: product relation iff canonical relation on projections

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/ProductIrreflexivity.lean` (extend, ~100-150 lines additional)

**Verification**:
- `truth_prod_canonical_iff` proven without sorry
- All formula constructors handled
- `lake build` passes with no errors

---

### Phase 3: Completeness Integration [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Connect product frame irreflexivity to existing completeness infrastructure

**Tasks**:
- [ ] Create wrapper theorem `canonicalR_irreflexive_via_product` in ProductIrreflexivity.lean
- [ ] Prove: for any MCS M, NOT CanonicalR(M, M) using product frame construction
- [ ] Update `CanonicalIrreflexivity.lean` to import and use product approach
- [ ] Replace sorry in `canonicalR_irreflexive` with call to product-based proof

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/ProductIrreflexivity.lean` (wrapper theorem)
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivity.lean` (import + replace sorry)

**Verification**:
- `grep -n "\bsorry\b" CanonicalIrreflexivity.lean` returns empty
- `grep -n "\bsorry\b" ProductIrreflexivity.lean` returns empty
- `lake build Bimodal.Metalogic.Canonical.CanonicalIrreflexivity` passes
- Task 956 Phase 6 unblocked

---

### Phase 4: Cleanup and Documentation [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Remove obsolete naming argument code, document resolution

**Tasks**:
- [ ] Mark obsolete code in CanonicalIrreflexivity.lean with deprecation comments
- [ ] Remove or comment out the naming argument infrastructure (keep for reference)
- [ ] Add module-level documentation explaining why naming argument was unfixable
- [ ] Update module header to reference product frame approach
- [ ] Run full `lake build` to verify no regressions
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivity.lean` (cleanup, docs)
- `specs/958_prove_canonicalr_irreflexive_irr_rule/summaries/implementation-summary-{DATE}.md` (new)

**Verification**:
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Canonical/*.lean` returns empty for target files
- Documentation explains the resolution approach
- Implementation summary created

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivity.lean` returns empty
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Canonical/ProductIrreflexivity.lean` returns empty
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] Task 956 Phase 6 can proceed (dependency unblocked)
- [ ] Product frame approach documented in module headers
- [ ] Implementation summary captures mathematical reasoning

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Canonical/ProductIrreflexivity.lean` (new file)
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivity.lean` (modified)
- `specs/958_prove_canonicalr_irreflexive_irr_rule/summaries/implementation-summary-{DATE}.md`
- `specs/958_prove_canonicalr_irreflexive_irr_rule/plans/implementation-006.md` (this file)

## Rollback/Contingency

1. **Phase 0 bypass discovery**: If StagedTimeline already guarantees irreflexivity, skip Phases 1-2 and directly integrate in Phase 3
2. **Phase 1-2 complexity**: If product frame construction is more complex than expected, mark [BLOCKED] for architecture review
3. **Phase 3 integration issues**: Existing CanonicalIrreflexivity.lean code preserved as comments; can restore if needed
4. **Full rollback**: ProductIrreflexivity.lean is a new file and can be deleted without affecting existing code
