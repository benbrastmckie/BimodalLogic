# Implementation Plan: Task #23

- **Task**: 23 - F/P Temporal Witness Chain Construction
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None (research complete)
- **Research Inputs**: specs/023_fp_temporal_witness_chain/reports/02_team-research.md
- **Artifacts**: plans/01_succ-based-fp-witnesses.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan addresses the 4 IntBFMCS sorries (intFMCS_forward_F, intFMCS_backward_P, enrichedIntFMCS_forward_F x2) by completing the Succ-based approach that bypasses the mathematically impossible linear Lindenbaum chain construction. Research confirms the `bounded_witness` theorem is already proven; only 3 axioms in SuccExistence.lean remain to complete the alternative path.

### Research Integration

Key findings integrated from team research:
- **Linear chains impossible**: Lindenbaum extensions can introduce G(~phi), killing F(phi) obligations before witness step
- **Succ relation tracks F-obligations**: The F-step condition `f_content u <= v union f_content v` prevents silent killing
- **bounded_witness proven**: If F^n(phi) in u but F^{n+1}(phi) not in u, and n Succ steps to v, then phi in v
- **3 axioms remain**: successor_deferral_seed_consistent_axiom, predecessor_deferral_seed_consistent_axiom, predecessor_f_step_axiom

## Goals & Non-Goals

**Goals**:
- Analyze the 3 remaining axioms in SuccExistence.lean for provability
- Either prove the axioms OR document them as acceptable semantic axioms with clear justification
- Determine whether IntBFMCS sorries should be marked as fundamental blockers (Option B) or if Succ-based path resolves them (Option A)
- Create clear documentation of the resolution path chosen

**Non-Goals**:
- Building a complete Int-indexed TaskFrame from Succ chains (future task if axioms are proven)
- Proving AddCommGroup instance for CanonicalMCS (algebraic track, not this task)
- Modifying the IntBFMCS file itself (sorries remain until resolution path is clear)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Axioms require deep DF/DB manipulation | H | M | Research similar patterns in DiscreteSuccSeed.lean; apply analogous techniques |
| Seed consistency not provable without new lemmas | M | M | Document as semantic axiom with clear justification if unprovable |
| Predecessor F-step requires different approach than successor | M | L | The g/h duality is already proven; leverage existing h_content_subset_implies_g_content_reverse |
| Time overrun on complex proof attempts | M | M | Set 1-hour timeout per axiom; move to documentation path if stuck |

## Implementation Phases

### Phase 1: Axiom Analysis and Dependency Mapping [NOT STARTED]

**Goal**: Understand each axiom's structure, semantic justification, and proof dependencies.

**Tasks**:
- [ ] Analyze `successor_deferral_seed_consistent_axiom` (line 266): What lemmas would prove it? Does it reduce to existing seed consistency patterns?
- [ ] Analyze `predecessor_deferral_seed_consistent_axiom` (line 311): Is this truly symmetric to successor? What duality lemmas exist?
- [ ] Analyze `predecessor_f_step_axiom` (line 516): Why is this separate from g-persistence? What blocks direct proof?
- [ ] Map dependencies on DF axiom, seriality (F(top) in u), and existing consistency lemmas
- [ ] Document which axioms appear provable vs which require semantic justification

**Timing**: 1 hour

**Files to examine**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - axiom definitions and context
- `Theories/Bimodal/Metalogic/Bundle/DiscreteSuccSeed.lean` - similar patterns for `discreteImmediateSuccSeed_consistent`
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` - seed consistency patterns
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - g_content/h_content duality lemmas

**Verification**:
- Document produced with clear categorization: provable / likely provable / requires semantic axiom
- Dependencies listed for each axiom

---

### Phase 2: Attempt Successor Deferral Seed Consistency Proof [NOT STARTED]

**Goal**: Prove `successor_deferral_seed_consistent_axiom` or determine it requires semantic justification.

**Tasks**:
- [ ] Review `deferral_disjunction_from_F` lemma showing phi v F(phi) is derivable from F(phi)
- [ ] Check if `g_content_consistent` + derivability of deferral disjunctions suffices
- [ ] Attempt proof using pattern from `forward_temporal_witness_seed_consistent` in WitnessSeed.lean
- [ ] If proof succeeds: convert axiom to theorem
- [ ] If proof blocked: document blocking issue and confirm semantic justification is sound

**Timing**: 1 hour (hard timeout - move to documentation if not proven)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - potential axiom -> theorem conversion

**Verification**:
- If proven: `lake build Bimodal.Metalogic.Bundle.SuccExistence` compiles without axiom
- If not proven: clear documentation of why semantic axiom is acceptable

---

### Phase 3: Attempt Predecessor Axioms Proof [NOT STARTED]

**Goal**: Prove or document the two predecessor axioms.

**Tasks**:
- [ ] Apply symmetric reasoning from Phase 2 to `predecessor_deferral_seed_consistent_axiom`
- [ ] Analyze `predecessor_f_step_axiom` - why can't it be proven from the construction?
- [ ] Check if DP axiom (derivable from DF) provides necessary tools
- [ ] Attempt proofs with 30-minute timeout per axiom
- [ ] Document outcomes for each axiom

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - potential axiom -> theorem conversions

**Verification**:
- Each axiom either converted to theorem OR documented with semantic justification
- `lake build` succeeds

---

### Phase 4: Resolution Decision and Documentation [NOT STARTED]

**Goal**: Make final determination on IntBFMCS sorries and document the resolution.

**Tasks**:
- [ ] Based on axiom outcomes, determine path:
  - If all 3 axioms proven: Document that Succ-based path is complete; IntBFMCS sorries can use Succ chain construction
  - If axioms remain: Document that axioms are acceptable semantic axioms OR that IntBFMCS sorries are fundamental blockers
- [ ] Update SuccExistence.lean documentation to reflect outcomes
- [ ] Add commentary to IntBFMCS.lean about resolution (line 532-535 area)
- [ ] Create implementation summary in specs/023_fp_temporal_witness_chain/summaries/

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - documentation updates
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` - add resolution commentary
- `specs/023_fp_temporal_witness_chain/summaries/01_fp-witness-resolution.md` - create summary

**Verification**:
- Clear path forward documented for IntBFMCS sorries
- Summary explains what was achieved and what remains
- `lake build` succeeds

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.SuccExistence` succeeds after each phase
- [ ] No new sorries introduced (axioms remain or are converted to theorems)
- [ ] Documentation is consistent across all modified files
- [ ] Summary accurately reflects outcomes

## Artifacts & Outputs

- `specs/023_fp_temporal_witness_chain/plans/01_succ-based-fp-witnesses.md` - this plan
- `specs/023_fp_temporal_witness_chain/summaries/01_fp-witness-resolution.md` - implementation summary
- Updated `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - with proven theorems or documented axioms
- Updated `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` - with resolution commentary

## Rollback/Contingency

If implementation causes issues:
1. Git revert changes to SuccExistence.lean (preserve axioms as-is)
2. Keep IntBFMCS sorries unchanged
3. Document in summary that resolution requires future work
4. The existing codebase remains functional with current axioms

If time runs out:
1. Document progress in summary
2. Mark task [PARTIAL] with clear resume point
3. Preserve any partial proofs as comments
