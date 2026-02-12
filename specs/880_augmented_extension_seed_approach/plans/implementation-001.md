# Implementation Plan: Augmented Extension Seed Approach

- **Task**: 880 - Investigate augmented extension seed approach for pure past/future cases
- **Status**: [NOT STARTED]
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

### Phase 1: Delete False Lemmas (Step 0) [NOT STARTED]

- **Dependencies:** None
- **Goal:** Remove mathematically false lemmas that can never be proven
- **Tasks:**
  - [ ] Delete `multi_witness_seed_consistent_future` (lines 806-844)
  - [ ] Delete `multi_witness_seed_consistent_past` (lines 849-874)
  - [ ] Remove any references to these lemmas
  - [ ] Verify build still compiles (with remaining sorries)
- **Timing:** 0.5 hours
- **Verification:**
  - `lake build` succeeds (with existing sorry count minus 2)
  - No references to deleted lemmas remain

---

### Phase 2: Analyze F/P Field Dependencies [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Map all usages of `forward_F` and `backward_P` to prepare for removal
- **Tasks:**
  - [ ] Search all uses of `forward_F` in codebase
  - [ ] Search all uses of `backward_P` in codebase
  - [ ] Identify which theorems depend on these fields
  - [ ] Document the dependency graph
  - [ ] Plan removal order to minimize cascading breaks
- **Timing:** 1 hour
- **Verification:**
  - Complete list of F/P usages documented
  - Clear removal sequence identified

---

### Phase 3: Remove forward_F and backward_P (Step 1) [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Remove the fundamentally broken F/P fields from GHCoherentPartialFamily
- **Tasks:**
  - [ ] Remove `forward_F` field from `GHCoherentPartialFamily` structure
  - [ ] Remove `backward_P` field from `GHCoherentPartialFamily` structure
  - [ ] Update all structure instantiations (remove F/P proofs)
  - [ ] Update `extend_family_preserves_GHCoherence` to not require F/P
  - [ ] Remove S8, S9 sorry sites (F/P extension proofs no longer needed)
  - [ ] Verify remaining sorry count
- **Timing:** 4-6 hours
- **Files to modify:**
  - `Theories/Bimodal/Completeness/ZornFamily.lean` - structure definition, extension
- **Verification:**
  - Structure compiles without F/P fields
  - S6, S7, S8, S9 eliminated or restructured
  - Remaining sorry count reduced by 4

---

### Phase 4: Simplify extensionSeed and Prove Consistency (Steps 2-3) [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Simplify seed to GContent + HContent only and prove consistency for all cases
- **Tasks:**
  - [ ] Simplify `extensionSeed` definition to GContent + HContent only (remove FObligations, PObligations)
  - [ ] Prove `extensionSeed_consistent` for pure future boundary case (S4)
  - [ ] Prove `extensionSeed_consistent` for pure past boundary case (S5)
  - [ ] Prove `extensionSeed_consistent` for cross-sign case (S3)
    - GContent propagates forward via `GContent_propagates_forward`
    - HContent propagates backward via `HContent_propagates_backward`
    - All elements land in consistent MCS via T-axiom
  - [ ] Verify all 3 seed consistency sorries eliminated
- **Timing:** 4-7 hours
- **Verification:**
  - S3, S4, S5 eliminated
  - Build succeeds with 9 fewer sorries total (Phase 1-4)
  - Cross-sign case proven via propagation lemmas

---

### DECISION CHECKPOINT [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Evaluate progress and decide whether to continue with ZornFamily or pivot
- **Tasks:**
  - [ ] Verify 9/12 sorries eliminated (S1-S9)
  - [ ] Assess complexity of remaining 3 sorries (S10, S11, S12)
  - [ ] Evaluate controlled Lindenbaum feasibility based on Phase 3-4 learnings
  - [ ] Document decision: continue with ZornFamily vs. pivot to DovetailingChain
- **Timing:** 0.5 hours
- **Criteria for continuing:**
  - 9/12 sorries eliminated as expected
  - Clear path visible for controlled Lindenbaum
  - No unexpected blockers discovered
- **Criteria for pivot:**
  - Unexpected structural issues discovered
  - Controlled Lindenbaum appears fundamentally blocked
  - DovetailingChain path seems shorter

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
