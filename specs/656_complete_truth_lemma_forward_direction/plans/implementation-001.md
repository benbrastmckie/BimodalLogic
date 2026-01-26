# Implementation Plan: Task #656

- **Task**: 656 - Complete truth lemma forward direction (imp/box cases)
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Priority**: Medium
- **Dependencies**: None (standalone proof task)
- **Research Inputs**: specs/656_complete_truth_lemma_forward_direction/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Complete the two remaining sorries in the truth lemma forward direction (lines 144 and 155 of TruthLemma.lean). The imp case requires MCS modus ponens closure which depends circularly on the backward direction IH. The box case requires universal quantification over all world histories. Research identified mutual induction as the preferred approach, restructuring the truth lemma as a biconditional with both directions proven simultaneously.

### Research Integration

Key findings from research-001.md:
- MCS modus ponens closure lemma `set_mcs_implication_property` exists in Boneyard (line 655-672 of Completeness.lean)
- The imp forward case has a circular dependency: needs backward IH to get `psi in mcs t` from `truth_at psi`
- The box case requires proving `psi` true at ALL world histories, not just canonical ones
- Mutual induction breaks the circularity and is the standard approach in completeness proofs
- Estimated effort: 8-12 hours (research), refined to 10 hours for implementation

## Goals & Non-Goals

**Goals**:
- Restructure truth_lemma as mutual induction proving both directions simultaneously
- Complete the imp case in the forward direction using backward IH
- Complete the box case or document architectural limitations with justification
- Prove backward direction cases that support the forward direction (imp, box)
- Ensure no regressions in existing proven cases (atom, bot, all_past, all_future)

**Non-Goals**:
- Completing ALL backward direction cases (temporal cases can remain sorry for now)
- Modifying the semantics definition in Truth.lean
- Adding new accessibility relations or frame properties
- Proving the representation theorem (already done in Task 654)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Mutual induction increases proof complexity | Medium | Medium | Follow standard textbook structure (Blackburn et al.), keep phases small |
| Box case may be unprovable with current semantics | High | Medium | Document limitation clearly if architectural change required, defer to future task |
| MCS lemma import issues from Boneyard | Low | Low | Lemma already imported via IndexedMCSFamily.lean; verify namespace |
| Backward temporal cases complicate structure | Medium | Low | Only prove backward cases needed for forward direction; mark others sorry |

## Implementation Phases

### Phase 1: Infrastructure and MCS Lemma Verification [NOT STARTED]

**Goal**: Verify MCS modus ponens closure lemma is accessible and understand its interface.

**Tasks**:
- [ ] Verify `set_mcs_implication_property` is accessible from TruthLemma.lean
- [ ] Check if additional imports are needed
- [ ] Test calling the lemma in a simple context
- [ ] Document the exact signature and requirements

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Add import if needed

**Verification**:
- `lake build` succeeds
- Can invoke `set_mcs_implication_property` without error
- `lean_hover_info` shows expected signature

---

### Phase 2: Restructure to Mutual Induction [NOT STARTED]

**Goal**: Refactor truth lemma to prove biconditional with mutual induction on formulas.

**Tasks**:
- [ ] Create new theorem `truth_lemma_biconditional` with structure:
  ```lean
  theorem truth_lemma_biconditional (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
      phi ∈ family.mcs t ↔ truth_at (canonical_model D family) (canonical_history_family D family) t phi := by
    induction phi generalizing t with
    | atom p => constructor <;> ...
    | bot => constructor <;> ...
    | imp psi chi ih_psi ih_chi => constructor <;> ...
    | box psi ih => constructor <;> ...
    | all_past psi ih => constructor <;> ...
    | all_future psi ih => constructor <;> ...
  ```
- [ ] Migrate existing forward direction proofs (atom, bot, all_past, all_future) into the new structure
- [ ] Verify existing proofs still work in biconditional form

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Add new biconditional theorem

**Verification**:
- `lake build` succeeds
- Existing cases (atom, bot, all_past, all_future) compile without sorry in forward direction
- Structure allows accessing both IH directions in each case

---

### Phase 3: Complete Imp Case (Both Directions) [NOT STARTED]

**Goal**: Prove the imp case in both directions using mutual induction.

**Tasks**:
- [ ] **Forward direction** (line 144):
  1. Given: `(psi.imp chi) in family.mcs t` and `truth_at psi`
  2. Apply backward IH: `ih_psi.mpr h_psi_true` gives `psi in family.mcs t`
  3. Apply `set_mcs_implication_property` with `h_mem` (imp in mcs) and `psi in mcs`
  4. Get `chi in family.mcs t`
  5. Apply forward IH: `ih_chi.mp h_chi_mem` gives `truth_at chi`
- [ ] **Backward direction** (line 211):
  1. Given: `truth_at psi -> truth_at chi` (semantic implication)
  2. Need: `(psi.imp chi) in family.mcs t`
  3. Use MCS negation completeness: either `(psi.imp chi)` or `neg(psi.imp chi)` is in mcs
  4. If `neg(psi.imp chi)` in mcs, derive contradiction
  5. `neg(psi.imp chi)` is equivalent to `psi and neg chi`
  6. This means both `psi` and `neg chi` are in mcs
  7. By forward IH on psi: `truth_at psi`
  8. By semantic assumption: `truth_at chi`
  9. By backward IH on chi: `chi in mcs`
  10. But `neg chi` also in mcs - contradiction with MCS consistency
- [ ] Verify both directions type-check

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Complete imp case

**Verification**:
- `lake build` succeeds
- No sorry in imp case
- Both directions proven

---

### Phase 4: Investigate Box Case Architecture [NOT STARTED]

**Goal**: Determine feasibility of box case with current semantics and implement if possible.

**Tasks**:
- [ ] Analyze the semantic requirement:
  ```lean
  truth_at M tau t (Formula.box psi) ↔
    ∀ sigma : WorldHistory F, truth_at M sigma t psi
  ```
- [ ] **Approach A**: Attempt proof assuming box membership propagates to all histories
  - If `box psi in family.mcs t`, what can we conclude about arbitrary sigma?
  - The canonical model uses `family.mcs t` for valuation at any world at time t
  - Key insight: For the canonical history specifically, states at t have mcs = family.mcs t
- [ ] **Approach B**: Check if box semantics can use canonical histories only
  - Review if `truth_at` definition can be restricted
  - Document if restriction is acceptable for representation theorem
- [ ] **Approach C**: If proof is not possible, document the limitation clearly
  - Add comment explaining why box requires semantic change
  - Note that box case is not needed for temporal completeness

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Investigate and document

**Verification**:
- Clear determination of whether box case is provable
- If provable: proof compiles
- If not: clear documentation of limitation and why

---

### Phase 5: Complete Box Case or Document Limitation [NOT STARTED]

**Goal**: Either complete the box case proof or document the architectural limitation.

**Tasks (if provable)**:
- [ ] Implement forward direction:
  1. Given: `box psi in family.mcs t`
  2. For arbitrary history sigma, show `truth_at M sigma t psi`
  3. Key: use that canonical model valuation is independent of history
  4. The valuation only depends on `w.mcs` where w is the world state
  5. For canonical construction, `w.mcs = family.mcs t` at time t
- [ ] Implement backward direction:
  1. Given: for all sigma, `truth_at M sigma t psi`
  2. Need: `box psi in family.mcs t`
  3. Use negation completeness and contrapositive

**Tasks (if not provable)**:
- [ ] Add detailed comment explaining the architectural limitation
- [ ] Consider adding `axiom box_truth_lemma_forward` as documented assumption
- [ ] Update the `truth_lemma` theorem to reflect partial status
- [ ] Create follow-up task for semantic extension if needed

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Complete or document box case

**Verification**:
- If proven: `lake build` succeeds, no sorry in box case
- If documented: clear comments, potential axiom, follow-up task created

---

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `lean_diagnostic_messages` shows no errors in TruthLemma.lean
- [ ] Existing proven cases (atom, bot, all_past, all_future) still work
- [ ] Imp case has no sorry in either direction
- [ ] Box case either proven or clearly documented with justification
- [ ] The `truth_lemma` biconditional theorem compiles
- [ ] No regressions in dependent files (if any)

## Artifacts & Outputs

- `specs/656_complete_truth_lemma_forward_direction/plans/implementation-001.md` (this file)
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` (modified)
- `specs/656_complete_truth_lemma_forward_direction/summaries/implementation-summary-{DATE}.md` (on completion)

## Rollback/Contingency

If mutual induction approach fails:
1. Revert TruthLemma.lean to original state
2. Keep separate forward/backward theorems with sorries
3. Document the attempted approach and why it failed
4. Create new task for alternative approach (axiomatization, semantic change)

If box case is provably impossible:
1. Add clear documentation in source file
2. Consider `axiom` for box truth lemma if needed for downstream proofs
3. Create follow-up task for semantic extension (modal accessibility relation)
