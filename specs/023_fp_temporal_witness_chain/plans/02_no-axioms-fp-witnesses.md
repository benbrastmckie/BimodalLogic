# Implementation Plan: Task #23 (Revision 2)

- **Task**: 23 - F/P Temporal Witness Chain Construction
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Dependencies**: None (research complete)
- **Research Inputs**: specs/023_fp_temporal_witness_chain/reports/02_team-research.md
- **Artifacts**: plans/02_no-axioms-fp-witnesses.md (this file)
- **Standards**: plan-format.md, status-markers.md
- **Type**: lean4
- **Lean Intent**: false

## Revision Notes

**Previous Plan**: 01_succ-based-fp-witnesses.md proposed analyzing 3 axioms and potentially accepting them as "semantic axioms" if unprovable.

**Constraint Change**: **ABSOLUTELY NO AXIOMS ARE ACCEPTABLE**. The plan must either:
1. PROVE the 3 axioms (convert to theorems), OR
2. Eliminate IntBFMCS sorries through a different approach that requires no axioms

## Overview

This plan addresses the 4 IntBFMCS sorries with the hard constraint that **no new axioms may be introduced**. Two paths exist:

**Path A (Preferred)**: Prove the 3 SuccExistence.lean axioms as theorems
- `successor_deferral_seed_consistent_axiom` → `successor_deferral_seed_consistent`
- `predecessor_deferral_seed_consistent_axiom` → `predecessor_deferral_seed_consistent`
- `predecessor_f_step_axiom` → `predecessor_f_step`

**Path B (Fallback)**: If any axiom is UNPROVABLE, reroute completeness through CanonicalFMCS
- CanonicalFMCS.lean is already **sorry-free** for forward_F and backward_P
- Delete IntBFMCS F/P sorries by restructuring to use CanonicalFMCS
- Accept that Int-indexed chains cannot directly satisfy F/P without axioms

## Goals & Non-Goals

**Goals**:
- Eliminate all 4 IntBFMCS sorries (intFMCS_forward_F, intFMCS_backward_P, enrichedIntFMCS_forward_F x2)
- Do so WITHOUT any axioms (existing or new)
- Either prove the 3 SuccExistence axioms OR reroute through CanonicalFMCS

**Non-Goals**:
- Accepting any axiom as "semantically justified" - this is forbidden
- Preserving IntBFMCS if it requires axioms - deletion is acceptable
- Partial solutions that leave axioms in place

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Seed consistency requires lemmas we don't have | H | M | Phase 1 identifies exactly what's needed; Phase 2 derives missing lemmas |
| Axioms are genuinely unprovable | H | L | Path B provides axiom-free alternative via CanonicalFMCS |
| CanonicalFMCS reroute breaks algebraic completeness | H | M | Phase 4 validates algebraic path still works |
| Proof complexity exceeds time budget | M | M | 2-hour hard limit per axiom; pivot to Path B if blocked |

## Implementation Phases

### Phase 1: Deep Axiom Analysis [IN PROGRESS]

**Goal**: Determine exactly what would prove each axiom, and whether those proofs exist or can be constructed.

**Tasks**:
- [ ] Analyze `successor_deferral_seed_consistent_axiom`:
  - What is `successor_deferral_seed`? What formulas does it contain?
  - What would make it inconsistent? (Find explicit contradiction scenario)
  - What lemmas would prove consistency? (e.g., derivability closure, MCS properties)
- [ ] Analyze `predecessor_deferral_seed_consistent_axiom`:
  - Apply symmetric analysis to predecessor case
  - Check if existing h_content/g_content duality helps
- [ ] Analyze `predecessor_f_step_axiom`:
  - Why is this separate from g-persistence?
  - What about the construction fails to satisfy f_content constraint?
  - Can the construction be modified to satisfy this directly?
- [ ] **Decision Point**: For each axiom, classify as:
  - PROVABLE: Clear proof path exists
  - LIKELY PROVABLE: Path exists but requires new lemmas
  - UNPROVABLE: Fundamental blocker, must use Path B

**Timing**: 2 hours

**Files to examine**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - axiom definitions
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` - seed definitions
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` - similar consistency proofs
- `Theories/Bimodal/Metalogic/Bundle/DiscreteSuccSeed.lean` - related patterns

**Verification**:
- Written analysis for each axiom with proof path or blocking reason
- Clear decision on Path A vs Path B

---

### Phase 2: Prove Axioms (Path A) [NOT STARTED]

**Precondition**: Phase 1 classified all 3 axioms as PROVABLE or LIKELY PROVABLE.

**Goal**: Convert all 3 axioms to theorems. Zero axioms remain.

**Tasks**:
- [ ] Prove `successor_deferral_seed_consistent`:
  - Implement proof following analysis from Phase 1
  - Key lemma likely: `deferral_disjunction_from_F` + MCS closure properties
  - Remove `axiom` declaration, replace with `theorem` + proof
- [ ] Prove `predecessor_deferral_seed_consistent`:
  - Apply symmetric proof or leverage duality
  - Remove axiom, replace with theorem
- [ ] Prove `predecessor_f_step`:
  - May require modifying `predecessor_from_deferral_seed` construction
  - Ensure f_content constraint satisfied by construction, not assumption
  - Remove axiom, replace with theorem
- [ ] Run `lake build` to verify no axioms remain in SuccExistence.lean

**Timing**: 3 hours (1 hour per axiom, hard timeout)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - axiom → theorem conversions

**Verification**:
- `grep -c "^axiom" Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` returns 0
- `lake build Bimodal.Metalogic.Bundle.SuccExistence` succeeds

**If ANY axiom cannot be proven**: STOP. Proceed to Phase 3 (Path B).

---

### Phase 3: CanonicalFMCS Reroute (Path B) [NOT STARTED]

**Precondition**: Phase 2 failed to prove at least one axiom, OR Phase 1 classified at least one axiom as UNPROVABLE.

**Goal**: Eliminate IntBFMCS sorries by restructuring to use CanonicalFMCS instead.

**Tasks**:
- [ ] Document why each unprovable axiom is fundamentally unprovable (not just hard)
- [ ] Identify all uses of IntBFMCS forward_F/backward_P in the codebase
- [ ] For each use site, determine if CanonicalFMCS can substitute:
  - Does the caller need Int-indexing specifically?
  - Can the property be lifted from CanonicalFMCS?
- [ ] Refactor use sites to use CanonicalFMCS (or mark IntBFMCS F/P as deprecated)
- [ ] Either:
  - Delete IntBFMCS forward_F/backward_P declarations entirely, OR
  - Mark them as `noncomputable` with explicit documentation that they're unsatisfiable for linear chains

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` - refactor or delete F/P
- Any files using IntBFMCS F/P properties

**Verification**:
- No sorries in IntBFMCS F/P (deleted or proven via CanonicalFMCS)
- `lake build` succeeds
- No new axioms introduced

---

### Phase 4: Verification and Cleanup [NOT STARTED]

**Goal**: Ensure zero axioms related to this task exist and all sorries are eliminated.

**Tasks**:
- [ ] Audit axiom count:
  ```bash
  grep -rn "^axiom" Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean
  grep -rn "sorry" Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean
  ```
- [ ] Verify algebraic completeness path still works (if Path B was taken)
- [ ] Update documentation in affected files
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to modify**:
- `specs/023_fp_temporal_witness_chain/summaries/01_no-axioms-resolution.md` - create summary

**Verification**:
- Zero task-related axioms in codebase
- Zero IntBFMCS F/P sorries
- `lake build` succeeds on full project

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `grep -rn "^axiom" Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` shows 0 matches (or only pre-existing unrelated axioms)
- [ ] IntBFMCS forward_F, backward_P, enrichedIntFMCS_forward_F sorries eliminated
- [ ] No new axioms introduced anywhere

## Artifacts & Outputs

- `specs/023_fp_temporal_witness_chain/plans/02_no-axioms-fp-witnesses.md` - this plan
- `specs/023_fp_temporal_witness_chain/summaries/01_no-axioms-resolution.md` - implementation summary
- Modified `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - axioms converted to theorems OR documented as fundamental blockers
- Modified `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` - sorries eliminated

## Rollback/Contingency

**Path A Rollback** (if proofs break other things):
1. Git revert SuccExistence.lean changes
2. Proceed to Path B

**Path B Rollback** (if CanonicalFMCS reroute breaks algebraic track):
1. Git revert IntBFMCS changes
2. Escalate to user: fundamental blocker requiring architectural decision

**Critical Constraint**: At no point may we accept axioms as a solution. If both paths fail, the task must be marked [BLOCKED] with clear documentation of why axiom-free resolution is impossible.
