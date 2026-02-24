# Implementation Plan: Task #923 - Formalize Frame Correspondence for Linearity Axiom

- **Task**: 923 - formalize_frame_correspondence_linearity
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/923_formalize_frame_correspondence_linearity/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Prove the frame correspondence theorem showing that if the linearity axiom schema is valid on a Kripke frame, then the frame's accessibility relation is linear. The research report (research-001.md) provides extensive analysis identifying that the standard proof using G-enriched formulas (phi = G(alpha), psi = neg(alpha)) closes Cases 1 and 2 directly but Case 3 requires careful handling due to the reflexive F operator. The recommended approach uses the "G-enriched linearity" trick combined with the existing canonical frame infrastructure.

### Research Integration

The research report identifies three recommended approaches:
1. **Option A (Primary)**: G-enriched linearity with phi = G(alpha), psi = neg(alpha)
2. **Option B (Fallback)**: Accept sorry if Case 3 proves intractable
3. **Option C**: Abstract Kripke frame layer with non-reflexive F

This plan implements **Option A** with a fallback to **Option B** if Case 3 cannot be resolved within time constraints.

## Goals & Non-Goals

**Goals**:
- Prove `canonical_reachable_linear` (resolve the 1 sorry in CanonicalEmbedding.lean)
- Close all three cases of the linearity axiom application
- Build on existing infrastructure: `mcs_F_linearity`, `canonical_forward_F`, `canonical_F_of_mem_successor`
- Achieve zero sorries in the frame correspondence proof

**Non-Goals**:
- Introduce abstract Kripke frame layer (Option C - too much complexity for this task)
- Modify existing lemmas in CanonicalFrame.lean or CanonicalEmbedding.lean beyond the sorry
- Prove frame correspondence for other axioms

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Case 3 infinite regress cannot be closed | High | Medium | Document blocker, accept sorry with detailed analysis (Option B) |
| Missing helper lemmas for G-propagation | Medium | Low | Create helper lemmas incrementally in Phase 1 |
| Proof complexity exceeds time budget | Medium | Medium | Fallback to sorry with comprehensive documentation |

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry in `CanonicalEmbedding.lean` at theorem `canonical_reachable_linear` (line 288)

### Expected Resolution
- Phase 2 resolves the sorry via the G-enriched linearity proof strategy
- Cases 1 and 2 close by direct contradiction (G(alpha) gives alpha by T-axiom)
- Case 3 requires secondary linearity application or well-founded argument

### New Sorries
- None expected. If Case 3 proves intractable, will document thoroughly and flag for future work.

### Remaining Debt
After this implementation:
- 0 sorries expected in `canonical_reachable_linear`
- If Case 3 cannot be resolved: 1 sorry remains, but with comprehensive proof sketch and documentation

## Implementation Phases

### Phase 1: Helper Lemmas for G-Enriched Proof [NOT STARTED]

- **Dependencies:** None
- **Goal:** Establish auxiliary lemmas needed for the main proof

**Tasks**:
- [ ] Create helper lemma: `G_conj_distrib` - G(alpha) AND G(beta) in MCS implies G(alpha AND beta) in MCS
- [ ] Create helper lemma: `canonicalR_G_propagation` - G(alpha) in W and CanonicalR W W' implies alpha in W' (verify exists or create)
- [ ] Create helper lemma: `mcs_F_of_reflexive` - phi in M implies F(phi) in M (via CanonicalR reflexivity)
- [ ] Verify `temp_4` propagation: G(phi) in M implies G(G(phi)) in M (check existing infrastructure)

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean` - Add helper lemmas before `canonical_reachable_linear`

**Verification**:
- `lake build` succeeds
- Helper lemmas compile without sorry

---

### Phase 2: Main Proof - Cases 1 and 2 [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Prove Cases 1 and 2 of the linearity application with phi = G(alpha), psi = neg(alpha)

**Tasks**:
- [ ] Set up proof structure: Assume CanonicalR M M1, CanonicalR M M2, NOT(CanonicalR M1 M2)
- [ ] Extract witness alpha: G(alpha) in M1, neg(alpha) in M2 (from NOT(CanonicalR M1 M2) definition)
- [ ] Establish F(G(alpha)) in M (via canonical_F_of_mem_successor)
- [ ] Establish F(neg(alpha)) in M (via canonical_F_of_mem_successor)
- [ ] Apply mcs_F_linearity with phi = G(alpha), psi = neg(alpha)
- [ ] Close Case 1: F(G(alpha) AND neg(alpha)) - G(alpha) gives alpha by T-axiom, contradicting neg(alpha)
- [ ] Close Case 2: F(G(alpha) AND F(neg(alpha))) - G(alpha) propagates to F(neg(alpha)) witness, giving alpha AND neg(alpha)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean` - Replace sorry in `canonical_reachable_linear`

**Verification**:
- Proof compiles with Cases 1 and 2 resolved
- Case 3 remains (possibly as sorry or subgoal)

---

### Phase 3: Main Proof - Case 3 Resolution [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Close Case 3 or document why it cannot be closed

**Tasks**:
- [ ] Analyze Case 3 structure: F(F(G(alpha)) AND neg(alpha)) - world W with F(G(alpha)) at W and neg(alpha) at W
- [ ] Apply secondary linearity at W with same phi = G(alpha), psi = neg(alpha)
- [ ] Verify F(G(alpha)) in W (given) and F(neg(alpha)) in W (from neg(alpha) in W via reflexivity)
- [ ] Close secondary Cases 1 and 2 (same argument as Phase 2)
- [ ] For secondary Case 3: either close via well-founded argument or document intractability
- [ ] If intractable: document with detailed proof sketch in theorem docstring, maintain sorry

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean` - Complete `canonical_reachable_linear` proof

**Verification**:
- Full proof compiles without sorry, OR
- Proof has sorry for Case 3 with comprehensive documentation

---

### Phase 4: Verification and Documentation [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Verify build, document results, update theorem docstrings

**Tasks**:
- [ ] Run `lake build` to verify full project builds
- [ ] Count sorries to confirm resolution or document remaining
- [ ] Update docstring on `canonical_reachable_linear` with proof sketch and status
- [ ] If sorry remains: update docstring with detailed explanation of Case 3 blocker and potential resolutions
- [ ] Create implementation summary

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean` - Update docstring

**Verification**:
- `lake build` succeeds
- Theorem docstring accurately reflects proof status
- Implementation summary created

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `canonical_reachable_linear` compiles (with or without sorry)
- [ ] If sorry-free: verify via `lean_verify` that no axioms are introduced
- [ ] Docstrings accurately describe proof strategy and any remaining blockers

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean` - Updated with proof or documented sorry
- `specs/923_formalize_frame_correspondence_linearity/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If the proof approach fails completely:
1. Revert to original sorry-backed theorem
2. Update docstring with comprehensive analysis of why the approach failed
3. Document Case 3 infinite regress problem as known technical debt
4. Flag task 923 as [PARTIAL] with recommendation to explore Option C (abstract Kripke frame layer)
