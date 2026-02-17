# Implementation Plan: Augmented Extension Seed Approach

- **Task**: 880 - Investigate augmented extension seed approach for pure past/future cases
- **Status**: [PARTIAL] (Phases 1-4 + Decision Checkpoint complete, Phases 5-6 pending)
- **Effort**: 21-31 hours (Phase 1: ~9h, Phase 2: ~12-18h)
- **Dependencies**: None (builds on task 870 Phase 4 findings)
- **Research Inputs**: specs/880_augmented_extension_seed_approach/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan addresses the 12 sorry sites in ZornFamily.lean identified in task 870 Phase 4 and further analyzed in research-002.md. The core architectural flaw is that `forward_F` and `backward_P` fields assert universal propagation for existential operators, making domain extension impossible. The plan proceeds in two main phases: Phase 1 (Steps 0-3) eliminates 9/12 sorries with high confidence by removing the broken F/P fields and simplifying the seed. Phase 2 (Steps 4-6) tackles the remaining 3 sorries requiring controlled Lindenbaum extension. A decision checkpoint after Phase 1 enables pivoting to DovetailingChain if Phase 2 proves intractable.

### Research Integration

- **research-002.md**: Identified 6-step implementation path, sorry classification, and F/P architectural flaw
- **Key insight**: `forward_F` and `backward_P` are mathematically unsatisfiable for many families
- **Confidence assessment**: Steps 0-3 at 90%, Steps 4-6 at 55%

## Goals & Non-Goals

**Goals**:
- Eliminate all 12 sorry sites in ZornFamily.lean
- Remove fundamentally broken `forward_F` and `backward_P` fields
- Simplify extensionSeed to GContent + HContent only
- Establish controlled Lindenbaum extension for general cases
- Provide clear decision point before committing to high-risk phases

**Non-Goals**:
- Refactoring DovetailingChain.lean (fallback only if needed)
- Modifying the overall Zorn architecture beyond necessary changes
- Optimizing proof performance (correctness first)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| F/P removal causes cascading breaks | HIGH | MEDIUM | Careful dependency analysis in Phase 2; incremental commits |
| Controlled Lindenbaum proves intractable | HIGH | MEDIUM | Decision checkpoint after Phase 4; DovetailingChain fallback |
| Cross-sign case harder than expected | MEDIUM | LOW | Research shows clear path after F/P removal |
| non_total_has_boundary false | HIGH | CONFIRMED | Plan addresses with general extension (Phase 5) |

## Sorry Characterization

### Pre-existing Sorries

| ID | Line | Category | Description |
|----|------|----------|-------------|
| S1 | 844 | IMPOSSIBLE | `multi_witness_seed_consistent_future` - mathematically false |
| S2 | 874 | IMPOSSIBLE | `multi_witness_seed_consistent_past` - mathematically false |
| S3 | 888 | HARD→EASY | Cross-sign seed consistency (becomes trivial after Step 2) |
| S4 | 1120 | MEDIUM | `extensionSeed_consistent` pure future boundary |
| S5 | 1260 | MEDIUM | `extensionSeed_consistent` pure past boundary |
| S6 | 1764 | MEDIUM | `extend_family_preserves_GHCoherence` G-coherence |
| S7 | 1968 | MEDIUM | `extend_family_preserves_GHCoherence` H-coherence |
| S8 | 2091 | MEDIUM | `extend_family_preserves_GHCoherence` forward_F |
| S9 | 2161+2168 | MEDIUM | `extend_family_preserves_GHCoherence` backward_P |
| S10 | 1786 | HARD | General (non-boundary) extension |
| S11 | 1928 | HARD | G-coherence from-new-to-old via controlled Lindenbaum |
| S12 | (same) | HARD | H-coherence from-new-to-old via controlled Lindenbaum |

### Expected Resolution

| Phase | Sorries | Approach |
|-------|---------|----------|
| Phase 2 (Step 0) | S1, S2 | Delete false lemmas |
| Phase 3 (Step 1) | S6, S7, S8, S9 | Remove F/P fields from structure |
| Phase 4 (Steps 2-3) | S3, S4, S5 | Simplify seed and prove consistency |
| Phase 5-6 (Steps 4-6) | S10, S11, S12 | Controlled Lindenbaum extension |

### New Sorries

None expected. If proof complexity requires temporary sorry, will document with remediation timeline.

### Remaining Debt

After full implementation:
- 0 sorries expected in ZornFamily.lean
- Downstream theorems will no longer inherit sorry status
- Publication no longer blocked by these specific sorries

## Implementation Phases

### Phase 1: Delete False Lemmas (Step 0) [COMPLETED]

- **Dependencies:** None
- **Goal:** Remove mathematically false lemmas that can never be proven
- **Tasks:**
  - [x] Delete `multi_witness_seed_consistent_future` (lines 806-844)
  - [x] Delete `multi_witness_seed_consistent_past` (lines 849-874)
  - [x] Remove any references to these lemmas
  - [x] Verify build still compiles (with remaining sorries)
- **Timing:** 0.5 hours
- **Verification:**
  - [x] `lake build` succeeds (10 sorries remain, down from 12)
  - [x] No references to deleted lemmas remain (comments updated)

---

### Phase 2: Analyze F/P Field Dependencies [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Map all usages of `forward_F` and `backward_P` to prepare for removal
- **Tasks:**
  - [x] Search all uses of `forward_F` in codebase
  - [x] Search all uses of `backward_P` in codebase
  - [x] Identify which theorems depend on these fields
  - [x] Document the dependency graph
  - [x] Plan removal order to minimize cascading breaks
- **Timing:** 1 hour
- **Verification:**
  - [x] Complete list of F/P usages documented (see below)
  - [x] Clear removal sequence identified

**Dependency Graph (ZornFamily.lean)**:
1. Structure fields (lines 121, 127): `forward_F`, `backward_P` in `GHCoherentPartialFamily`
2. Chain upper bound (lines 390, 421): `chainUpperBound` must prove F/P fields
3. Singleton family (lines 1434, 1439): `singletonGHCoherentFamily` proves F/P vacuously
4. Extension (lines 1613-1672, 1786-1845): `extendFamilyUpperBoundary`, `extendFamilyLowerBoundary` have 4 sorries for F/P
5. F/P satisfaction (lines 2115-2141): `total_family_FObligations_satisfied`, `total_family_PObligations_satisfied` use structural fields
6. Final extraction (lines 2151-2256): Delegation to F/P satisfaction lemmas

**Removal Sequence**:
1. Remove fields from structure
2. Remove F/P proofs from `chainUpperBound`
3. Remove F/P proofs from `singletonGHCoherentFamily`
4. Remove F/P branches from extension functions (eliminating 4 sorries)
5. Refactor `total_family_*_satisfied` to use alternative derivation

---

### Phase 3: Remove forward_F and backward_P (Step 1) [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Remove the fundamentally broken F/P fields from GHCoherentPartialFamily
- **Tasks:**
  - [x] Remove `forward_F` field from `GHCoherentPartialFamily` structure
  - [x] Remove `backward_P` field from `GHCoherentPartialFamily` structure
  - [x] Update all structure instantiations (remove F/P proofs)
  - [x] Update `extend_family_preserves_GHCoherence` to not require F/P
  - [x] Remove S8, S9 sorry sites (F/P extension proofs no longer needed)
- **Verification:**
  - [x] Build succeeds (8 sorries remain, down from 10)
  - [x] 4 extension sorries removed (upper/lower boundary F/P proofs)
  - [x] 2 new sorries added for F/P satisfaction (alternative proof needed)
  - [ ] Verify remaining sorry count
- **Timing:** 4-6 hours
- **Files to modify:**
  - `Theories/Bimodal/Completeness/ZornFamily.lean` - structure definition, extension
- **Verification:**
  - Structure compiles without F/P fields
  - S6, S7, S8, S9 eliminated or restructured
  - Remaining sorry count reduced by 4

---

### Phase 4: Simplify extensionSeed and Prove Consistency (Steps 2-3) [COMPLETED]

- **Dependencies:** Phase 3
- **Goal:** Simplify seed to GContent + HContent only and prove consistency for all cases
- **Tasks:**
  - [x] Simplify `extensionSeed` definition to GContent + HContent only (remove FObligations, PObligations)
  - [x] Update `upperBoundarySeed` and `lowerBoundarySeed` to match
  - [x] Update seed equivalence theorems
  - [x] Rewrite `extensionSeed_consistent` proof structure for simplified seed
  - [x] Prove pure past/future cases - list induction proofs completed
  - [x] Prove cross-sign case (S3) - forward_G/backward_H interaction proof completed
- **Timing:** 4-7 hours (actual: ~2 hours for Phase 4 completion)
- **Status:** COMPLETED - extensionSeed_consistent fully proven
- **Verification:**
  - [x] Build succeeds (5 sorries remaining, down from 8)
  - [x] S3 (cross-sign) - PROVEN via forward_G to s_future + backward_H propagation
  - [x] S4, S5 (pure cases) - PROVEN via list induction for max/min source time

---

### DECISION CHECKPOINT [COMPLETED]

- **Dependencies:** Phase 4
- **Goal:** Evaluate progress and decide whether to continue with ZornFamily or pivot
- **Tasks:**
  - [x] Verify 9/12 sorries eliminated (S1-S9) - CONFIRMED: down from 12 to 5 sorries
  - [x] Assess complexity of remaining sorries:
    - S10 (line 1595): `non_total_has_boundary` internal gap - MEDIUM complexity
    - S11 (line 1665): `h_G_from_new` - requires controlled Lindenbaum
    - S12 (line 1672): `h_H_from_new` - requires controlled Lindenbaum
    - NEW S13 (line 1762): `total_family_FObligations_satisfied` - related to S11/S12
    - NEW S14 (line 1778): `total_family_PObligations_satisfied` - related to S11/S12
  - [x] Evaluate controlled Lindenbaum feasibility - FEASIBLE but non-trivial
  - [x] Document decision: CONTINUE with ZornFamily
- **Decision:** Continue with ZornFamily approach
- **Rationale:**
  - 9/12 original sorries eliminated as planned
  - S10 (internal gap) may be solvable by showing gaps can always be filled from boundaries
  - S11-S14 cluster around the same issue: controlled Lindenbaum for G/H from-new-to-old
  - Phase 5-6 remains viable, though will require careful Lindenbaum refinement

---

### Phase 5: General (Non-Boundary) Extension (Step 4) [NOT STARTED]

- **Dependencies:** Decision Checkpoint (decision: continue ZornFamily)
- **Goal:** Handle extension for non-boundary times
- **Tasks:**
  - [ ] Analyze why `non_total_has_boundary` is false (domain = even integers counterexample)
  - [ ] Restructure extension to handle ANY missing time, not just boundaries
  - [ ] Prove extension works for non-boundary times
  - [ ] Eliminate S10 sorry
- **Timing:** 6-10 hours
- **Verification:**
  - Extension handles arbitrary missing times
  - S10 eliminated
  - Build succeeds

---

### Phase 6: Controlled Lindenbaum for G/H from-new-to-old (Steps 5-6) [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Prove G/H coherence from newly added MCS to existing MCSs via controlled Lindenbaum
- **Tasks:**
  - [ ] Develop controlled Lindenbaum extension that respects G/H constraints
  - [ ] Prove G-coherence from new MCS to older MCSs in domain (S11)
  - [ ] Prove H-coherence from new MCS to newer MCSs in domain (S12)
  - [ ] Verify all 12 sorries eliminated
- **Timing:** 10-15 hours
- **Verification:**
  - S11, S12 eliminated
  - ZornFamily.lean has 0 sorries
  - Full build succeeds
  - All downstream theorems compile

---

### Phase 7: Fallback - DovetailingChain (if Phase 5-6 blocked) [NOT STARTED]

- **Dependencies:** Decision Checkpoint (decision: pivot to DovetailingChain)
- **Goal:** Transfer infrastructure to DovetailingChain approach
- **Tasks:**
  - [ ] Transfer cross-sign propagation infrastructure from ZornFamily
  - [ ] Build dovetailing enumeration for F/P witness placement
  - [ ] Address 4 sorry sites in DovetailingChain.lean
  - [ ] Verify completeness theorem compiles without sorry
- **Timing:** 12-18 hours (comparable to Phase 5-6)
- **Verification:**
  - DovetailingChain.lean has 0 sorries
  - Completeness theorem established

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] Sorry count decreases as expected per phase
- [ ] No new sorries introduced
- [ ] All modified theorems type-check correctly
- [ ] Downstream dependent theorems still compile
- [ ] Final sorry count in ZornFamily.lean: 0

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified `Theories/Bimodal/Completeness/ZornFamily.lean`
- Optionally modified `Theories/Bimodal/Completeness/DovetailingChain.lean` (if pivot)

## Rollback/Contingency

**Phase-level rollback:**
- Each phase committed separately; revert to previous commit if phase breaks invariants
- Git branch can be used for experimental Phase 5-6 work

**Full rollback:**
- If approach fundamentally fails, ZornFamily.lean remains with documented sorries
- DovetailingChain.lean as alternative path
- All sorries remain as technical debt with clear remediation documentation

**Pivot trigger:**
- If Phase 5-6 blocked for >20 hours of effort, evaluate DovetailingChain pivot
- Decision recorded in implementation summary
