# Implementation Plan: Task #658

- **Task**: 658 - Prove indexed family coherence conditions
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Priority**: Medium
- **Dependencies**: Task 654 (parent task)
- **Research Inputs**: specs/658_prove_indexed_family_coherence_conditions/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Prove the four coherence condition sorries in the `construct_indexed_family` function (IndexedMCSFamily.lean lines 433, 439, 448, 456). These conditions ensure the indexed MCS family satisfies temporal coherence requirements for irreflexive temporal semantics, avoiding the T-axiom problem. The research identified that forward_G and backward_H are directly provable via Temporal 4 axiom and seed membership, while forward_H and backward_G require contrapositive reasoning using MCS negation completeness.

### Research Integration

Integrated from research-001.md:
- Direct coherence (forward_G, backward_H): Use Temporal 4 axiom (`G phi -> GG phi`) and seed membership propagation
- Inverse coherence (forward_H, backward_G): Require contrapositive with `neg_complete` lemma
- Case analysis pattern: trichotomy on time positions (past/origin/future)
- Key lemmas: `theorem_in_mcs`, `mcs_at_time_contains_seed`, `extendToMCS_contains`
- Temporal axioms: `temp_4`, `temp_k_dist`, `temp_a`

## Goals & Non-Goals

**Goals**:
- Complete proofs for all four coherence conditions (forward_G, backward_H, forward_H, backward_G)
- Create reusable helper lemmas for time-based case analysis
- Ensure proofs compile without errors or warnings

**Non-Goals**:
- Fixing seed consistency sorries (lines 338, 354) - separate concern
- Fixing CanonicalWorld.neg_complete sorry (line 116) - handle as blocking dependency
- Generalizing the construction beyond current use case

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| neg_complete blocker | High | Medium | Attempt proof without it first; create separate task if needed |
| Temporal axiom propagation complexity | Medium | Medium | Use `lean_multi_attempt` to test tactics; factor out helper lemmas |
| Case analysis explosion | Medium | Low | Create helper lemmas for common subcases |
| Time estimate exceeded | Medium | Medium | Complete direct coherence first as partial progress |

## Implementation Phases

### Phase 1: Setup and Helper Lemmas [IN PROGRESS]

**Goal**: Create infrastructure for time-based case analysis and temporal axiom application

**Tasks**:
- [ ] Examine existing helper lemmas in IndexedMCSFamily.lean
- [ ] Create helper lemma for G formula propagation via Temporal 4: `G phi in mcs(t) -> G phi in mcs(t')` for appropriate t, t'
- [ ] Create helper lemma for H formula propagation (symmetric to G)
- [ ] Verify helpers compile and type-check

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - Add helper lemmas before coherence proofs

**Verification**:
- Helper lemmas compile without errors
- Types match expected usage in coherence conditions
- Use `lean_goal` to verify lemma statements

---

### Phase 2: Direct Coherence - forward_G and backward_H [NOT STARTED]

**Goal**: Prove the two "direct" coherence conditions that follow from seed construction

**Tasks**:
- [ ] Prove `forward_G` (line 433): `G phi in mcs(t) -> phi in mcs(t')` for `t < t'`
  - Case 1: t = 0 (origin) - phi in future_seed, use `mcs_at_time_contains_seed`
  - Case 2: t > 0 (future) - use Temporal 4 axiom transitivity
  - Case 3: t < 0 (past) - track G propagation through origin
- [ ] Prove `backward_H` (line 439): `H phi in mcs(t) -> phi in mcs(t')` for `t' < t`
  - Symmetric to forward_G using H instead of G
  - Use temporal duality where helpful

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - Replace sorries at lines 433, 439

**Verification**:
- Both proofs compile without errors
- Use `lean_diagnostic_messages` to check for warnings
- Run `lake build` to verify no regressions

---

### Phase 3: Inverse Coherence - backward_G [NOT STARTED]

**Goal**: Prove the "backward G" coherence condition using contrapositive reasoning

**Tasks**:
- [ ] Check if `CanonicalWorld.neg_complete` is available (line 116 may have sorry)
- [ ] If neg_complete unavailable, attempt direct proof approach first
- [ ] Prove `backward_G` (line 456): `G phi in mcs(t') -> phi in mcs(t)` for `t' < t`
  - Use contrapositive: assume `phi not in mcs(t)`, derive contradiction
  - Key: `neg_complete` gives `not phi in mcs(t)` from maximality
  - Use Temporal 4 and transitivity to show G phi cannot hold at t'
- [ ] Factor out reusable contrapositive pattern if successful

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - Replace sorry at line 456

**Verification**:
- Proof compiles without errors
- No new sorries introduced
- Use `lean_goal` at key proof points

---

### Phase 4: Inverse Coherence - forward_H [NOT STARTED]

**Goal**: Prove the "forward H" coherence condition (most complex case)

**Tasks**:
- [ ] Prove `forward_H` (line 448): `H phi in mcs(t') -> phi in mcs(t)` for `t < t'`
  - Use contrapositive similar to backward_G
  - "Looking back from future": if `H phi` at future time t', then phi held at earlier t
  - May need Temporal A axiom (`phi -> F(sometime_past phi)`)
- [ ] Handle case analysis for t' > 0, t = 0 (hardest subcase)
- [ ] Handle case analysis for both in future (t' > t > 0)
- [ ] Handle cross-origin case (t' > 0, t < 0) if distinct

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - Replace sorry at line 448

**Verification**:
- Proof compiles without errors
- All four coherence sorries eliminated
- Run `lake build Theories.Bimodal.Metalogic.Representation.IndexedMCSFamily` successfully

---

## Testing & Validation

- [ ] All four coherence condition sorries replaced with complete proofs
- [ ] `lake build` completes without errors for IndexedMCSFamily.lean
- [ ] No new sorries introduced in the file
- [ ] `lean_diagnostic_messages` shows no warnings for the modified lines
- [ ] The `construct_indexed_family` function compiles and passes type checking
- [ ] Run `#check construct_indexed_family` in Lean to verify construction is complete

## Artifacts & Outputs

- plans/implementation-001.md (this plan)
- summaries/implementation-summary-YYYYMMDD.md (upon completion)
- Modified file: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`

## Rollback/Contingency

- If neg_complete blocks phases 3-4: Document dependency, create separate task for neg_complete, mark phases 3-4 as [BLOCKED]
- If partial progress: Commit completed proofs, mark incomplete phases as [PARTIAL]
- Git revert available: All changes are to a single file, can revert specific commits if needed
- Alternative approach: If contrapositive fails, research alternative proof strategies using temporal semantic arguments
