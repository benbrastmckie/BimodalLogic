# Implementation Plan: Task #29 (v8 - Preorder Acceptance Approach)

- **Task**: 29 - switch_to_reflexive_gh_semantics
- **Status**: [COMPLETED]
- **Effort**: 8-12 hours remaining
- **Dependencies**: None (self-contained refactoring)
- **Research Inputs**:
  - specs/029_switch_to_reflexive_gh_semantics/reports/31_team-research.md (Wave 8 blocker resolution)
  - specs/029_switch_to_reflexive_gh_semantics/reports/30_mcs-decided-blocker-analysis.md (v7 blocker analysis)
- **Supersedes**: plans/07_mcs-decided-atom-approach.md (v7 - blocked on seed consistency)
- **Artifacts**: plans/08_preorder-acceptance-approach.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

**Plan v8 adopts the two-layer architecture** from Wave 8 team research (report 31). The key insight is that basic completeness does NOT require strict successors - the canonical frame is a reflexive preorder, and this is mathematically correct. Order-theoretic constructions (Cantor isomorphism, dovetailing) are isolated as optional enhancements that may need minimal axioms.

This approach resolves all previous blockers (v5: cardinality, v6: per-construction, v7: seed consistency) by accepting the correct mathematical structure rather than fighting it.

### Research Integration

Report 31 team research established:
1. **G(neg q) implies G(neg G(q))** is a valid derivation under reflexive semantics
2. **Pathological MCS are reachable** but irrelevant for basic completeness
3. **Preorder acceptance is viable** - standard completeness for S4/KT4 uses preorder frames
4. **Seriality is trivially valid** under reflexive F (every point reaches itself)

### Two-Layer Architecture

**Layer 1: Basic Completeness (no axiom needed)**
- Accept CanonicalR as reflexive preorder
- Remove NoMaxOrder/NoMinOrder from basic completeness path
- Truth lemma + Lindenbaum + reflexivity = completeness

**Layer 2: Order-Theoretic Enhancements (isolated, may need axiom)**
- Cantor isomorphism: Optional enhancement, may need axiom for NoMaxOrder
- Dovetailed timeline: Assess necessity, possibly defer
- Discrete successor: DF/SF axiom provides witness

### Completed Work (Preserved from v5/v6/v7)

- **Phases 1-3**: IRR removed from proof system
- **Phase 4**: Flawed cardinality theorems deleted
- **Phase 5A**: Per-construction strictness infrastructure (partial)
  - `lt_of_canonicalR_and_not_reverse`
  - `strict_of_formula_in_g_content_not_in_source`
  - `strict_of_formula_with_G_not_in_source`
  - `canonicalR_reflexive` proven via T-axiom
  - `canonicalR_past_reflexive` proven

## Goals & Non-Goals

**Goals**:
- Refactor completeness to work with preorder structure
- Remove NoMaxOrder/NoMinOrder requirements from completeness pipeline
- Delete `canonicalR_irreflexive_axiom` to restore consistency
- Isolate order-theoretic constructions (Cantor, dovetailing)
- Update documentation for reflexive preorder semantics
- Complete T-axiom proofs for remaining axioms

**Non-Goals**:
- Proving universal strict successor existence (mathematically false)
- Proving antisymmetry (fails under reflexive semantics)
- MCS-decided atom approach (blocked, abandoned)
- Universal fresh atom existence (mathematically false)
- Maintaining NoMaxOrder/NoMinOrder for basic completeness

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Completeness proof requires strict successors | H | L | Research shows preorder sufficient for S4/KT4 |
| CantorApplication not isolable | M | M | May need to add minimal axiom for that file only |
| DovetailedTimelineQuot deeply coupled | M | M | Assess necessity; may defer to future work |
| Build cascades from removing NoMaxOrder | M | M | Incremental refactoring with `lake build` after each file |

## Implementation Phases

### Phase 1: Audit Completeness Pipeline [COMPLETED]

**Goal**: Identify exactly which files in the completeness pipeline depend on NoMaxOrder/NoMinOrder.

**Tasks**:
- [ ] Grep for NoMaxOrder/NoMinOrder usage in Metalogic/
- [ ] Map dependency graph from CanonicalSerialFrameInstance.lean
- [ ] Identify which uses are for completeness vs order-theoretic enhancements
- [ ] Document findings in phase notes

**Timing**: 1 hour

**Files to analyze**:
- `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean`
- All files importing CanonicalSerialFrameInstance

**Verification**:
- Dependency map documented
- Clear separation: completeness-critical vs enhancement-only

---

### Phase 2: Refactor CanonicalSerialFrameInstance [COMPLETED]

**Goal**: Remove NoMaxOrder/NoMinOrder instances that depend on canonicalR_irreflexive.

**Tasks**:
- [ ] Comment out or delete NoMaxOrder instance (depends on canonicalR_irreflexive)
- [ ] Comment out or delete NoMinOrder instance (depends on canonicalR_irreflexive)
- [ ] Run `lake build` to identify downstream breakage
- [ ] Create list of broken files for Phase 3

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean`

**Verification**:
- `lake build` produces error list (expected)
- NoMaxOrder/NoMinOrder instances removed or commented

---

### Phase 3: Fix Completeness-Path Breakage [COMPLETED]

**Goal**: Fix files in the basic completeness path that break without NoMaxOrder/NoMinOrder.

**Strategy**: For each broken file, determine if it genuinely needs strict successors for completeness, or if the requirement can be removed/relaxed.

**Tasks**:
- [ ] For each broken file in completeness path:
  - [ ] Assess whether NoMaxOrder/NoMinOrder is actually needed
  - [ ] If not needed: remove/refactor the dependency
  - [ ] If needed: mark for Phase 5 (order-theoretic isolation)
- [ ] Run `lake build` after each file fix
- [ ] Document which files were refactored vs marked

**Timing**: 2-3 hours

**Potential files** (to be confirmed by Phase 2):
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean`
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalQuot.lean`

**Verification**:
- Completeness pipeline builds without NoMaxOrder/NoMinOrder
- `lake build` passes for modified files

---

### Phase 4: Isolate Order-Theoretic Constructions [COMPLETED]

**Goal**: Move Cantor isomorphism and dovetailing to isolated modules that don't affect basic completeness.

**Strategy**:
- If CantorApplication is only needed for enhanced model properties (not completeness), mark it as requiring axiom
- If DovetailedTimelineQuot is only for specific model constructions, isolate it similarly

**Tasks**:
- [ ] Analyze CantorApplication.lean dependencies
  - Does completeness actually require Cantor isomorphism?
  - If not: document as enhancement-only
  - If yes: add minimal axiom or construction-specific strictness
- [ ] Analyze DovetailedTimelineQuot.lean
  - Is dovetailing needed for completeness?
  - If not: document as enhancement-only, possibly defer
- [ ] Create or update module documentation for isolated constructions
- [ ] Run `lake build`

**Timing**: 2-3 hours

**Files to analyze/modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`

**Verification**:
- Clear documentation of which constructions are completeness-critical vs enhancement
- Build passes
- Isolated constructions have explicit axiom dependencies if needed

---

### Phase 5: Delete Axiom and Restore Consistency [COMPLETED]

**Goal**: Remove the deprecated canonicalR_irreflexive_axiom.

**Prerequisite**: Phases 2-4 complete, no remaining dependencies on the axiom

**Tasks**:
- [ ] Delete `axiom canonicalR_irreflexive_axiom` from `CanonicalIrreflexivityAxiom.lean`
- [ ] Delete deprecated wrappers from `Canonical/CanonicalIrreflexivityAxiom.lean`
- [ ] Update `Bundle/CanonicalIrreflexivity.lean` to remove axiom-based theorems
- [ ] Run `lake build`
- [ ] Verify `grep -r "canonicalR_irreflexive_axiom" Theories/` returns no matches

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

**Verification**:
- `lake build` passes
- System is CONSISTENT (only `canonicalR_reflexive` exists)
- Axiom count reduced by 1

---

### Phase 6: Update Documentation [COMPLETED]

**Goal**: Align all documentation with reflexive preorder semantics.

**Tasks**:
- [ ] Update module docstrings explaining preorder structure
- [ ] Update comments in ~20 files with outdated irreflexive references
- [ ] Document why:
  - Universal fresh atom existence is false
  - MCS-decided atom pattern fails
  - Preorder structure is mathematically correct
- [ ] Document the two-layer architecture:
  - Layer 1: Basic completeness (preorder, no axiom)
  - Layer 2: Enhancements (may need axiom)
- [ ] Update typst/latex documentation if any

**Timing**: 1-2 hours

**Files to modify**: Files containing "irreflexive" in comments (see report 20)

**Verification**:
- Documentation accurately describes reflexive preorder semantics
- No misleading "irreflexive" comments remain in active code
- Two-layer architecture documented

---

### Phase 7: T-Axiom Proofs for Remaining Axioms [COMPLETED]

**Goal**: Prove seed consistency axioms using T-axiom where possible.

**Tasks**:
- [ ] Analyze `discreteImmediateSuccSeed_consistent_axiom`
  - Can DF/SF axiom provide the witness?
  - If yes: prove using T-axiom pattern
  - If no: document why axiom is necessary
- [ ] Analyze `discreteImmediateSucc_covers_axiom`
- [ ] Analyze `successor_deferral_seed_consistent_axiom`
- [ ] Analyze `predecessor_deferral_seed_consistent_axiom`
- [ ] Document remaining axioms with justification
- [ ] Run `lake build`

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- `lake build` passes
- Axiom count reduced where proofs succeed
- Remaining axioms documented with justification

---

### Phase 8: Final Verification and Summary [COMPLETED]

**Goal**: Verify complete system consistency and create summary.

**Tasks**:
- [ ] Full `lake build`
- [ ] Run `grep -r "canonicalR_irreflexive" Theories/` - should return only historical comments
- [ ] Count axioms: should be reduced by at least 1
- [ ] Verify completeness theorem still holds
- [ ] Create implementation summary at `specs/029_switch_to_reflexive_gh_semantics/summaries/`

**Timing**: 1 hour

**Verification**:
- Full build passes
- System is consistent
- Completeness theorem proven
- Summary documents all changes

---

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] Phase 2: NoMaxOrder/NoMinOrder instances removed
- [ ] Phase 3: Completeness path builds without strict successor requirements
- [ ] Phase 4: Order-theoretic constructions isolated
- [ ] Phase 5: `canonicalR_irreflexive_axiom` deleted
- [ ] Phase 6: Documentation updated
- [ ] Phase 7: Seed consistency axioms assessed
- [ ] Phase 8: Full build, consistency verified
- [ ] Final: `grep -r "canonicalR_irreflexive" Theories/` returns no code matches

## Artifacts & Outputs

- Updated `CanonicalSerialFrameInstance.lean` (NoMaxOrder/NoMinOrder removed)
- Refactored completeness pipeline (preorder-compatible)
- Isolated order-theoretic constructions with explicit axiom dependencies
- Deleted `canonicalR_irreflexive_axiom`
- Updated documentation for reflexive preorder semantics
- Implementation summary at `specs/029_switch_to_reflexive_gh_semantics/summaries/12_preorder-acceptance-summary.md`

## Key Mathematical Insight (From Wave 8 Team Research)

The team research established:

> **The canonical frame under reflexive G/H is a reflexive transitive linear preorder.** This is analogous to S4.3 (S4 + linearity).
>
> **Critical finding**: Standard completeness for reflexive modal logics works with preorders:
> - Truth lemma handles reflexive cases via T-axiom
> - Lindenbaum witnesses handle non-reflexive cases
> - No strict M != M' requirement for basic completeness
>
> **Seriality interpretation**: Under reflexive G, the operator F = neg G neg is also reflexive. The seriality axiom G phi implies F phi becomes trivially valid (follows from T-axiom: G phi implies phi implies F phi).

This means:
- NoMaxOrder/NoMinOrder for the STRICT order may not be needed for completeness
- The reflexive frame is already serial (every point reaches itself)
- Pathological MCS (where G(neg q) in M for all atoms) are reachable but don't block completeness

## Rollback/Contingency

**If completeness genuinely requires strict successors:**
1. Revert to v7 approach with construction-specific strictness
2. Add minimal semantic axiom for NoMaxOrder/NoMinOrder
3. Document the axiom with clear justification

**If Cantor/Dovetailing cannot be isolated:**
1. Accept that those constructions need axiom support
2. Add axiom with clear scope (enhancement-only, not completeness)
3. Document as technical debt for future resolution

**Git revert available**: All changes are incremental and revertible.

The preorder acceptance approach is mathematically sound. Only implementation mechanics remain.
