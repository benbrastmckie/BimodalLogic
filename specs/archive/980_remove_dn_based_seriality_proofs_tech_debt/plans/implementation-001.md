# Implementation Plan: Remove DN-Based Seriality Proofs Tech Debt

- **Task**: 980 - remove_dn_based_seriality_proofs_tech_debt
- **Status**: [COMPLETED]
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

### Phase 1: Analysis and Setup [COMPLETED]

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

### Phase 2: DN-Free Discrete NoMaxOrder/NoMinOrder via MCS Richness [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Prove NoMaxOrder/NoMinOrder using MCS Richness, bypassing density axiom DN

**Approach (Updated from Original Plan):**
The original plan proposed a "Direct NoMaxOrder" approach using canonical model structure.
After analysis, we implemented the MCS Richness approach (originally planned as Phase 3 fallback)
as the primary solution because it is mathematically cleaner and more direct.

**Tasks Completed:**
- [x] Proved `G_bot_not_in`: G(bot) is not in any serial MCS (contradicts F(neg bot))
- [x] Proved `G_bot_and_of_G_bot_and_X`: G(bot ∧ X) implies G(bot) via K-distribution
- [x] Proved `F_or_atom_in`: For any atom i, F(neg bot ∨ atom(i)) ∈ M (MCS Richness lemma)
- [x] Proved `mcs_has_large_F_formula`: For any N, exists phi with encoding >= N such that F(phi) ∈ M
- [x] Proved symmetric past lemmas: `H_bot_not_in`, `H_bot_and_of_H_bot_and_X`, `P_or_atom_in`
- [x] Proved `mcs_has_large_P_formula`: For any N, exists phi with encoding >= N such that P(phi) ∈ M
- [x] Proved helper defs: `derive_past_necessitation`, `derive_past_k_dist` (via temporal duality)
- [x] Refactored `discrete_staged_has_future` to use `mcs_has_large_F_formula` (DN-free!)
- [x] Refactored `discrete_staged_has_past` to use `mcs_has_large_P_formula` (DN-free!)
- [x] `lake build` passes with no errors

**Key Insight:**
For any atom i, we have F(neg bot ∨ atom(i)) ∈ M by MCS negation completeness
(either G(bot ∧ neg atom(i)) ∈ M or F(neg bot ∨ atom(i)) ∈ M, and the former
would imply G(bot) ∈ M, contradicting seriality F(neg bot) ∈ M).
Since there are infinitely many atoms, and encodings are injective, the
encodings of these formulas grow unboundedly - giving MCS Richness without DN.

**Timing:** 2 hours (as estimated)

**Files modified:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` - added MCS Richness lemmas and refactored discrete theorems

**Verification:**
- `lake build` passes
- `discrete_staged_has_future` no longer uses `iterated_future_in_mcs` (which depended on DN)
- `discrete_staged_has_past` no longer uses `iterated_past_in_mcs` (which depended on DN)

---

### Phase 3: MCS Richness Fallback (If Phase 2 Blocked) [SKIPPED - Integrated into Phase 2]

- **Dependencies:** Phase 2 (only if Phase 2 fails)
- **Goal:** Alternative DN-free approach using MCS negation completeness

**Status:** SKIPPED - The MCS Richness approach was successful and was integrated into Phase 2.
The tasks listed here were completed as part of Phase 2 above.

---

### Phase 4: Symmetric NoMinOrder Fix [COMPLETED - Integrated into Phase 2]

- **Dependencies:** Phase 2 or Phase 3
- **Goal:** Apply the same DN-free approach to `discrete_staged_has_past`

**Status:** COMPLETED - All past symmetry work was done as part of Phase 2.
The `discrete_staged_has_past` theorem now uses `mcs_has_large_P_formula` (DN-free).

**Tasks Completed:**
- [x] Applied MCS richness approach symmetrically to past (P_or_atom_in, mcs_has_large_P_formula)
- [x] Replaced `discrete_staged_has_past` proof body with DN-free version
- [x] `lake build` passes
- [x] `discrete_staged_has_past` no longer uses `iterated_past_in_mcs`

---

### Phase 5: Documentation Update and Cleanup [COMPLETED]

- **Dependencies:** Phase 4
- **Goal:** Update documentation, remove technical debt notes, verify zero DN dependency

**Tasks Completed:**
- [x] Updated docstring for `discrete_staged_has_future` to document DN-free proof via MCS richness
- [x] Updated docstring for `discrete_staged_has_past` to document DN-free proof via MCS richness
- [x] Updated `LogicVariants.lean` technical debt section (lines 60-75) to mark as RESOLVED
- [x] DN-specific helper lemmas (`iterated_future_in_mcs`, `iterated_past_in_mcs`) retained for dense construction
- [x] `lake build` passes

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

### Phase 6: Final Verification [COMPLETED]

- **Dependencies:** Phase 5
- **Goal:** Comprehensive verification of DN removal

**Tasks Completed:**
- [x] `lake build` passes on entire project (975 jobs)
- [x] `grep -rn "\bsorry\b" CantorPrereqs.lean` returns empty (zero-debt gate passed)
- [x] `grep -n "^axiom " CantorPrereqs.lean` returns empty (no new axioms)
- [x] Discrete theorems verified to use `mcs_has_large_F_formula` and `mcs_has_large_P_formula`
  (which use `F_or_atom_in` and `P_or_atom_in`, DN-free lemmas)
- [x] Implementation summary created (see below)

**Verification Results:**
- `lake build` passes with no errors
- Zero sorries in modified files
- Zero new axioms
- DN dependency successfully removed from discrete timeline proofs

## Testing & Validation

### For Lean Tasks (Required)
- [x] `lake build` passes with no errors
- [x] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` returns empty (zero-debt gate)
- [x] `grep -n "^axiom " Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` shows no new axioms
- [x] All proofs verified with `lean_goal` showing "no goals"

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
