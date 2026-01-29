# Implementation Plan: Prove decide_complete Theorem

- **Task**: 625 - prove_decide_complete
- **Status**: [NOT STARTED]
- **Effort**: 2-3 hours
- **Priority**: Medium
- **Dependencies**: Task 624 (tableau_complete) - completed
- **Research Inputs**: specs/625_prove_decide_complete/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task proves the `decide_complete` theorem in Correctness.lean, establishing that for any semantically valid formula, the `decide` function returns `.valid proof` given sufficient fuel. The proof builds directly on `tableau_complete` (completed in Task 624) but must bridge the gap between tableau validity (returning `.allClosed`) and proof extraction (returning `.valid proof`). The research identifies a critical complexity: even when `buildTableau` returns `.allClosed`, the `decide` function may still return `.timeout` if proof extraction fails.

### Research Integration

Key findings from research-001.md:
- The `decide` function has multiple code paths: axiom proof, proof search, tableau method
- Proof extraction from closed branches may fail (returning `.timeout` for valid formulas)
- Three recommended approaches: (A) strengthen proof extraction, (B) prove proof search completeness, (C) use classical weakening
- Existing gaps: `buildTableau_terminates` (sorry), `open_branch_implies_not_valid` (axiom)

## Goals & Non-Goals

**Goals**:
- Prove `decide_complete` theorem or a reasonable variant
- Bridge `tableau_complete` to `decide` returning `.valid proof`
- Maintain clean proof structure following existing patterns in Correctness.lean

**Non-Goals**:
- Full proof reconstruction from closed branches (would require substantial infrastructure)
- Proving `buildTableau_terminates` without sorry (separate task)
- Completing `open_branch_implies_not_valid` (separate semantic bridge task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Proof extraction may not be complete | High | Medium | Use classical reasoning or weaken theorem statement |
| Bounded proof search depth insufficient | Medium | Medium | Accept sorry for depth completeness or use FMP bound |
| Complex case analysis on decide paths | Low | High | Systematic analysis of all code paths |

## Implementation Phases

### Phase 1: Analyze decide function structure [NOT STARTED]

**Goal**: Understand all code paths in `decide` and identify proof obligation for each.

**Tasks**:
- [ ] Document all paths through `decide` that can return `.valid proof`
- [ ] Document conditions where valid formula returns `.timeout`
- [ ] Identify which helper lemmas are needed for each path
- [ ] Determine if current infrastructure supports proof or if classical reasoning needed

**Timing**: 30 minutes

**Files to examine**:
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/DecisionProcedure.lean` - decide function
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/ProofExtraction.lean` - tryAxiomProof
- `Theories/Bimodal/Boneyard/Metalogic/Automation/Automation.lean` - bounded_search_with_proof

**Verification**:
- Clear documentation of all code paths
- Identified strategy for proof

---

### Phase 2: Attempt direct proof using tableau_complete [NOT STARTED]

**Goal**: Prove `decide_complete` directly using `tableau_complete` as the foundation.

**Tasks**:
- [ ] Start proof with `obtain ⟨fuel, h_terminates, h_valid⟩ := tableau_complete φ hvalid`
- [ ] Use fuel value to show `buildTableau φ fuel = some (.allClosed closedBranches)`
- [ ] Analyze proof extraction paths in decide:
  - Path 1: `tryAxiomProof` returns proof
  - Path 2: `bounded_search_with_proof` returns proof
  - Path 3: Tableau `.allClosed` leads to `.valid` via axiom proofs or proof search
- [ ] Bridge the gap: show at least one path succeeds for valid φ

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/Correctness.lean` - theorem decide_complete

**Verification**:
- Proof compiles (even if with sorry for helper lemmas)
- Structure is sound and follows logical flow

---

### Phase 3: Add supporting lemmas or use classical reasoning [NOT STARTED]

**Goal**: Complete the proof by adding necessary lemmas or accepting classical justification.

**Tasks**:
- [ ] If direct proof works: clean up and document
- [ ] If proof extraction gap exists, choose approach:
  - **Option A**: Add lemma `allClosed_has_valid_return` showing `.allClosed` implies valid return
  - **Option B**: Use `Classical.choice` or similar to assert proof existence
  - **Option C**: Weaken statement to `∃ fuel, (decide φ 10 fuel).isValid = true`
- [ ] Document any sorry with clear explanation of what would be needed
- [ ] Ensure proof follows pattern of `tableau_complete` in same file

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/Correctness.lean` - supporting lemmas

**Verification**:
- All new lemmas compile
- Any sorry has clear documentation

---

### Phase 4: Build and verify [NOT STARTED]

**Goal**: Ensure entire Decidability module builds and theorem is usable.

**Tasks**:
- [ ] Run `lake build` on Decidability module
- [ ] Verify `#check decide_complete` shows correct signature
- [ ] Check that `tableau_complete` dependency is correctly used
- [ ] Test theorem can be applied (simple example if possible)
- [ ] Review any remaining sorry count vs starting point

**Timing**: 30 minutes

**Files to verify**:
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/Correctness.lean`
- Entire `Decidability/` module via `lake build`

**Verification**:
- `lake build` succeeds with no new errors
- `#check decide_complete` shows `∃ (fuel : Nat), ∃ proof, decide φ 10 fuel = .valid proof`

---

## Testing & Validation

- [ ] `lake build` succeeds for Decidability module
- [ ] No new sorry introduced beyond documented gaps
- [ ] Theorem statement unchanged from original
- [ ] Proof structure is clear and documented
- [ ] Any axioms/sorry have explicit justification comments

## Artifacts & Outputs

- `specs/625_prove_decide_complete/plans/implementation-001.md` (this file)
- `specs/625_prove_decide_complete/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified: `Theories/Bimodal/Boneyard/Metalogic/Decidability/Correctness.lean`

## Rollback/Contingency

If the theorem cannot be proved cleanly:
1. Document the gap clearly in comments above the theorem
2. Use `sorry` with explicit TODO explaining what infrastructure would be needed
3. Alternatively, prove a weaker variant (isValid instead of extracting proof term)
4. The weaker variant still demonstrates the logical structure is correct

The worst case is using a `sorry` with documentation, which is acceptable given:
- `tableau_complete` already proved (Task 624)
- The logical gap is proof extraction, not validity itself
- Similar approach used for `buildTableau_terminates` and `open_branch_implies_not_valid`
