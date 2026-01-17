# Implementation Plan: Task #557

- **Task**: 557 - MCS Property Completion
- **Status**: [NOT STARTED]
- **Effort**: 2-3 hours
- **Priority**: High
- **Dependencies**: None (building on existing infrastructure in MaximalConsistent.lean)
- **Research Inputs**: specs/557_mcs_property_completion/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task completes two critical `sorry` placeholders in `CanonicalModel.lean`: `mcs_contains_or_neg` (line 192) and `mcs_modus_ponens` (line 209). Both theorems are essential for the Truth Lemma and the completeness proof. The proofs require bridging between set-based consistency (`SetMaximalConsistent`) and list-based derivation infrastructure (`Consistent`, `DerivationTree`). The existing lemmas in `MaximalConsistent.lean` (`derives_neg_from_inconsistent_extension`, `derives_bot_from_phi_neg_phi`, `set_mcs_finite_subset_consistent`) provide the necessary foundation.

### Research Integration

From research-001.md:
- Both proofs use the pattern: extract witness from `SetConsistent` failure, apply deduction theorem lemmas
- Key lemmas already proven: `derives_neg_from_inconsistent_extension`, `derives_bot_from_phi_neg_phi`
- Bridge needed: `SetConsistent` (set-based) to `Consistent` (list-based)
- Mathlib pattern confirms approach: `FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem`

## Goals & Non-Goals

**Goals**:
- Prove `mcs_contains_or_neg`: For MCS S, either phi in S or neg phi in S
- Prove `mcs_modus_ponens`: For MCS S, if (phi -> psi) in S and phi in S, then psi in S
- Eliminate both `sorry` placeholders in CanonicalModel.lean
- Unblock downstream tasks 558, 559 (semantic satisfiability bridge, strong completeness helpers)

**Non-Goals**:
- Modifying the MaximalConsistent.lean infrastructure
- Proving additional MCS properties beyond these two
- Refactoring the canonical model definitions

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Witness extraction from SetConsistent may be complex | Medium | Medium | Add explicit helper lemma if inline reasoning is unwieldy |
| Type coercion between set/list memberships | Low | Medium | Use existing membership lemmas carefully, check with lean_hover_info |
| Derivation tree construction may be intricate | Medium | Low | Use lean_multi_attempt to test tactics systematically |

## Implementation Phases

### Phase 1: Analyze Goal States and Infrastructure [NOT STARTED]

**Goal**: Understand exact goal states and confirm available lemmas

**Tasks**:
- [ ] Use `lean_goal` at line 192 (mcs_contains_or_neg sorry) to capture exact goal state
- [ ] Use `lean_goal` at line 209 (mcs_modus_ponens sorry) to capture exact goal state
- [ ] Use `lean_hover_info` on `SetConsistent`, `SetMaximalConsistent`, `Consistent` to confirm types
- [ ] Verify `derives_neg_from_inconsistent_extension` and `derives_bot_from_phi_neg_phi` signatures

**Timing**: 20 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` - lines 174-210
- `Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean` - helper lemmas

**Verification**:
- Goal states documented for both sorries
- Helper lemma signatures confirmed

---

### Phase 2: Prove mcs_contains_or_neg [NOT STARTED]

**Goal**: Complete the proof that MCS contains phi or its negation

**Tasks**:
- [ ] Understand the goal state at line 192: need to derive False from h_incons_phi, h_incons_neg, and S being maximal consistent
- [ ] From `h_incons_phi : SetConsistent (insert phi S)`, extract witness using SetConsistent definition
- [ ] Apply `derives_neg_from_inconsistent_extension` pattern to get derivation of neg phi from S
- [ ] Similarly for `h_incons_neg` to get derivation of neg (neg phi) from S
- [ ] Use double negation elimination (`double_negation` from Propositional.lean) to get derivation of phi
- [ ] Combine phi and neg phi derivations using `derives_bot_from_phi_neg_phi`
- [ ] Show this contradicts `SetConsistent S` to complete proof
- [ ] Run `lean_diagnostic_messages` to verify no errors

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` - lines 174-192

**Proof Strategy**:
```
-- Goal: False (from neither phi nor neg phi in S)
-- Have: h_incons_phi : SetConsistent (insert phi S)
-- Have: h_incons_neg : SetConsistent (insert (neg phi) S)

-- Step 1: From insert phi S being inconsistent, there exists L subseteq insert phi S
-- such that not Consistent L. Extract the witness.

-- Step 2: If phi in L, use deduction theorem infrastructure to derive neg phi from S.
-- This uses derives_neg_from_inconsistent_extension pattern.

-- Step 3: Similarly, from insert (neg phi) S inconsistent, derive neg (neg phi) from S.

-- Step 4: Apply double negation elimination to get derivation of phi from S.

-- Step 5: Now have both phi and neg phi derivable from finite subsets of S.
-- Use derives_bot_from_phi_neg_phi to derive bot.

-- Step 6: This contradicts SetConsistent S.
```

**Verification**:
- `lean_diagnostic_messages` shows no errors for mcs_contains_or_neg
- `lean_goal` at line 192 shows "no goals" (proof complete)

---

### Phase 3: Prove mcs_modus_ponens [NOT STARTED]

**Goal**: Complete the modus ponens closure property for MCS

**Tasks**:
- [ ] Understand goal state at line 209: have phi in S, phi -> psi in S, neg psi in S, need False
- [ ] Construct explicit finite list L = [phi, phi.imp psi, psi.neg] where all elements are in S
- [ ] Build derivation of psi from L using modus ponens: assumption(phi), assumption(phi -> psi), MP
- [ ] Build derivation of neg psi from L using assumption
- [ ] Apply `derives_bot_from_phi_neg_phi` to derive bot from L
- [ ] Show L witnesses inconsistency of S, contradicting SetMaximalConsistent
- [ ] Run `lean_diagnostic_messages` to verify no errors

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` - lines 197-209

**Proof Strategy**:
```
-- Goal: False
-- Have: h_imp : (phi.imp psi) in S
-- Have: h_ant : phi in S
-- Have: h_neg : (psi.neg) in S

-- Step 1: Consider L = [phi, phi.imp psi, psi.neg]
-- All elements are in S by hypotheses.

-- Step 2: Build derivations:
-- d1 : L |- phi       (by assumption, phi in L)
-- d2 : L |- phi -> psi  (by assumption, imp in L)
-- d3 : L |- psi       (by modus ponens of d1, d2)
-- d4 : L |- neg psi   (by assumption, neg psi in L)
-- d5 : L |- bot       (by derives_bot_from_phi_neg_phi d3 d4)

-- Step 3: This shows not Consistent L.

-- Step 4: But all elements of L are in S, and S is SetMaximalConsistent,
-- so S is SetConsistent, meaning L should be Consistent.

-- Step 5: Contradiction.
```

**Verification**:
- `lean_diagnostic_messages` shows no errors for mcs_modus_ponens
- `lean_goal` at line 209 shows "no goals" (proof complete)

---

### Phase 4: Final Verification and Cleanup [NOT STARTED]

**Goal**: Ensure both proofs are complete and no sorries remain

**Tasks**:
- [ ] Run `lean_diagnostic_messages` on entire CanonicalModel.lean
- [ ] Verify no `sorry` placeholders remain in file
- [ ] Check that downstream imports (TruthLemma.lean, etc.) have no new errors
- [ ] Run `lake build` to verify project compiles
- [ ] Document any additional lemmas added (if helper lemmas were needed)

**Timing**: 15 minutes

**Files to verify**:
- `Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` - entire file
- `Theories/Bimodal/Metalogic_v2/TruthLemma.lean` - verify no new errors

**Verification**:
- Zero `sorry` placeholders in CanonicalModel.lean
- `lake build` succeeds without errors
- No regressions in dependent files

## Testing & Validation

- [ ] `lean_diagnostic_messages` on CanonicalModel.lean returns no errors
- [ ] `lean_goal` at former sorry locations shows "no goals"
- [ ] `lake build Bimodal.Metalogic_v2.Representation.CanonicalModel` succeeds
- [ ] Grep for `sorry` in CanonicalModel.lean returns zero matches
- [ ] `lake build` on full project succeeds

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` - modified with complete proofs
- `specs/557_mcs_property_completion/plans/implementation-001.md` - this plan
- `specs/557_mcs_property_completion/summaries/implementation-summary-{DATE}.md` - completion summary

## Rollback/Contingency

If proofs cannot be completed as designed:
1. Keep partial progress in the proof (intermediate lemmas, partial tactics)
2. Add detailed comments explaining the gap
3. If fundamentally blocked, consider adding helper lemmas to MaximalConsistent.lean
4. Worst case: document the blocking issue and mark task as BLOCKED with specific technical reason

The existing `sorry` placeholders allow the codebase to compile, so rollback simply means reverting to the original file state.
