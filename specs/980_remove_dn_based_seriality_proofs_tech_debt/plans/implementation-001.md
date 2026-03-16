# Implementation Plan: Remove DN-Based Seriality Proofs Tech Debt

- **Task**: 980 - remove_dn_based_seriality_proofs_tech_debt
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Dependencies**: None
- **Research Inputs**: specs/980_remove_dn_based_seriality_proofs_tech_debt/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Remove technical debt where the discrete timeline construction incorrectly uses the density axiom DN (`F(phi) -> F(F(phi))`) to prove NoMaxOrder/NoMinOrder. The discrete logic explicitly excludes DN because density and discreteness are incompatible frame conditions. The recommended fix uses Direct NoMaxOrder via canonical model structure, bypassing encoding-based arguments entirely.

### Research Integration

- Research report `research-001.md` identified `discrete_staged_has_future` and `discrete_staged_has_past` in `CantorPrereqs.lean` (lines 522-703) as the primary location of the debt
- The debt exists because `iterated_future_in_mcs` uses `density_F_to_FF` to obtain arbitrarily large F-formulas
- Three approaches were evaluated: Direct NoMaxOrder (3-5h, recommended), MCS Richness (4-6h, fallback), Stage-Aware (8-12h, not recommended)

## Goals & Non-Goals

**Goals**:
- Remove dependency on DN axiom from `discrete_staged_has_future` and `discrete_staged_has_past`
- Provide DN-free proofs that discrete timelines have NoMaxOrder and NoMinOrder
- Maintain all existing theorems and build success
- Remove or update the technical debt documentation in `LogicVariants.lean`

**Non-Goals**:
- Modifying the dense timeline construction (which correctly uses DN)
- Restructuring the staged build mechanism itself
- Changing the canonical model definitions

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Direct approach fails mathematically | High | Medium | Fall back to MCS Richness approach |
| Both approaches fail | High | Low | Mark [BLOCKED] for user review with detailed analysis |
| Proof complexity exceeds estimate | Medium | Medium | Phase 3 is designed as fallback; can pivot early |
| Build breaks in dependent files | Medium | Low | Run `lake build` after each phase change |

## Sorry Characterization

### Pre-existing Sorries
- None in scope. `CantorPrereqs.lean` has no sorries in the target theorems.

### Expected Resolution
- N/A - no pre-existing sorries to resolve

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected
- DN dependency fully removed from discrete construction
- Technical debt documentation updated to reflect resolution

## Implementation Phases

### Phase 1: Analysis and Setup [NOT STARTED]

- **Dependencies:** None
- **Goal:** Understand the exact code paths and prepare the proof strategy

**Tasks:**
- [ ] Read `CantorPrereqs.lean` lines 520-710 to understand current proof structure
- [ ] Trace `iterated_future_in_mcs` usage to identify all DN-dependent code paths
- [ ] Read `canonical_forward_F` in `CanonicalModel.lean` to understand canonical successor construction
- [ ] Identify the key lemma needed: "every StagedPoint has a canonical successor in the timeline union"
- [ ] Document the proof strategy in a comment block for the new lemmas

**Timing:** 1 hour

**Files to read:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean`
- `Theories/Bimodal/Metalogic/Canonical/CanonicalModel.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/StagedTimeline.lean`

**Verification:**
- Clear understanding of what `canonical_forward_F` provides
- Written proof strategy documented

---

### Phase 2: Direct NoMaxOrder Approach [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Prove NoMaxOrder using canonical model structure directly, bypassing encoding arguments

**Tasks:**
- [ ] Prove helper lemma: `canonical_successor_exists` - every MCS has a canonical F-successor from seriality
- [ ] Prove helper lemma: `canonical_successor_in_discrete_timeline` - the canonical successor is reachable via bidirectional closure
- [ ] Implement `discrete_staged_has_future_direct`: DN-free version using canonical model structure
- [ ] Replace the proof body of `discrete_staged_has_future` with the direct approach
- [ ] Run `lake build` to verify no regressions

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` - add new lemmas and refactor theorem

**Verification:**
- `lake build` passes
- `grep -n "iterated_future_in_mcs" CantorPrereqs.lean` shows no usage in `discrete_staged_has_future`
- `lean_goal` shows no goals at theorem end

---

### Phase 3: MCS Richness Fallback (If Phase 2 Blocked) [NOT STARTED]

- **Dependencies:** Phase 2 (only if Phase 2 fails)
- **Goal:** Alternative DN-free approach using MCS negation completeness

**Tasks:**
- [ ] Prove `mcs_has_large_formula`: every MCS contains formulas with arbitrarily large encodings
- [ ] Prove `mcs_partition_lemma`: for any psi, either G(psi) in M or F(neg psi) in M
- [ ] Prove `mcs_has_large_F_formula`: for any N, exists phi with encoding >= N such that F(phi) in M
- [ ] Replace `discrete_staged_has_future` proof with MCS richness approach
- [ ] Run `lake build` to verify

**Timing:** 2-3 hours (only if needed)

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean`

**Verification:**
- `lake build` passes
- No DN dependency in the proof chain

---

### Phase 4: Symmetric NoMinOrder Fix [NOT STARTED]

- **Dependencies:** Phase 2 or Phase 3
- **Goal:** Apply the same DN-free approach to `discrete_staged_has_past`

**Tasks:**
- [ ] Apply the working approach (direct or MCS richness) symmetrically to past
- [ ] Implement `discrete_staged_has_past_direct` or use MCS richness for P(phi)
- [ ] Replace `discrete_staged_has_past` proof body
- [ ] Run `lake build` to verify

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean`

**Verification:**
- `lake build` passes
- `grep -n "iterated_past_in_mcs" CantorPrereqs.lean` shows no usage in `discrete_staged_has_past`

---

### Phase 5: Documentation Update and Cleanup [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Update documentation, remove technical debt notes, verify zero DN dependency

**Tasks:**
- [ ] Update docstring for `discrete_staged_has_future` to remove DN caveat
- [ ] Update docstring for `discrete_staged_has_past` to remove DN caveat
- [ ] Update `LogicVariants.lean` technical debt section (lines 60-75) to mark as resolved
- [ ] Remove or mark obsolete any DN-specific helper lemmas if no longer needed
- [ ] Final `lake build` verification

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` - docstrings
- `Theories/Bimodal/LogicVariants.lean` - technical debt documentation

**Verification:**
- `lake build` passes
- `grep -rn "INCORRECTLY uses DN" Theories/` returns empty
- `grep -rn "uses DN" Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` only in dense (not discrete) theorems
- Technical debt section in LogicVariants.lean updated

---

### Phase 6: Final Verification [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Comprehensive verification of DN removal

**Tasks:**
- [ ] Run `lake build` on entire project
- [ ] Verify `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` returns empty
- [ ] Verify discrete theorems no longer depend on `density_F_to_FF` via transitive imports
- [ ] Create implementation summary

**Timing:** 30 minutes

**Files to verify:**
- All files in `Theories/Bimodal/Metalogic/StagedConstruction/`

**Verification:**
- `lake build` passes with no errors
- Zero sorries in modified files
- No DN dependency in discrete timeline proofs

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Specific to This Task
- [ ] `grep -n "density" CantorPrereqs.lean` only in dense construction (lines < 500)
- [ ] `grep -n "iterated_future_in_mcs" CantorPrereqs.lean` only in dense construction
- [ ] Discrete timeline NoMaxOrder/NoMinOrder proofs are self-contained

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-{DATE}.md` (on completion)
- Modified `CantorPrereqs.lean` with DN-free discrete proofs
- Updated `LogicVariants.lean` technical debt documentation

## Rollback/Contingency

If implementation fails completely:
1. Git reset to pre-implementation state
2. Mark task [BLOCKED] with detailed analysis of why both approaches failed
3. Document mathematical obstacles for future reference
4. Consider alternative: accept DN as "semantically incorrect but computationally valid" with explicit warning (not recommended)
