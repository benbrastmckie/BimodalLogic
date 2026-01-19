# Implementation Plan: Task #470

- **Task**: 470 - Finite Model Computational Optimization
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Priority**: Normal
- **Dependencies**: Task 604 (FMP migration to SemanticCanonicalModel_v2 - completed)
- **Research Inputs**:
  - specs/470_finite_model_computational_optimization/reports/research-001.md
  - specs/470_finite_model_computational_optimization/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan optimizes the Metalogic_v2 representation layer for computational efficiency. The architecture follows a representation-first approach with the Finite Model Property (FMP) as the central bridge theorem. The current implementation prioritizes correctness over performance, with 14 sorries across 4 files and several noncomputable definitions that could be made computable.

The optimization strategy is:
1. Complete critical sorries that block the completeness pipeline (SemanticCanonicalModel.lean)
2. Resolve supporting sorries in Closure.lean that enable the core proofs
3. Migrate the `Formula.subformulas` dependency away from old Metalogic
4. Add computable decidable instances for efficient enumeration

### Research Integration

**Research-001** (old Metalogic analysis):
- Identified noncomputable patterns: `Classical.choose` in time shifts, `Classical.propDecidable` in assignments
- Recommended precomputed closure decomposition structures
- Recommended explicit time arithmetic over Classical.choose

**Research-002** (Metalogic_v2 focus):
- 4 critical sorries in SemanticCanonicalModel.lean blocking completeness
- 9 sorries in Closure.lean (subformula membership, negation completeness)
- 1 sorry in FiniteWorldState.lean (temporal reflexivity issue - architectural)
- Key insight: Semantic approach bypasses temporal reflexivity issues in syntactic approach

## Goals & Non-Goals

**Goals**:
- Complete the 4 critical sorries in SemanticCanonicalModel.lean enabling full completeness proof
- Resolve the 9 sorries in Closure.lean (subformula membership lemmas, MCS properties)
- Migrate `Formula.subformulas` to `Bimodal.Syntax` module, eliminating old Metalogic dependency
- Make `intToFiniteTime` and related time conversions computable
- Add computable `DecidableEq` instances where classical dependencies can be removed

**Non-Goals**:
- Resolving the 1 sorry in FiniteWorldState.lean (`closure_mcs_implies_locally_consistent`) - this requires temporal reflexivity axioms not valid in TM logic; the semantic approach bypasses this
- Implementing lazy enumeration/backtracking for truth assignments - optimization for future work
- Creating specialized HashMap/Array data structures - would complicate reasoning
- Deleting old Metalogic directory - separate cleanup task

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| History gluing (line 207) is complex | High - blocks compositionality | Focus effort here first; may need auxiliary lemmas about history concatenation |
| Closure sorries are interdependent | Medium - delays progress | Map dependencies carefully; work bottom-up |
| Classical dependencies run deep | Medium - hard to make computable | Accept some noncomputable for proofs; add separate decidable layer |
| Migration breaks existing proofs | Low - Metalogic_v2 is isolated | Test incrementally with `lake build` |

## Implementation Phases

### Phase 1: Migrate Formula.subformulas to Bimodal.Syntax [COMPLETED]

**Goal**: Eliminate the dependency on old `Bimodal.Metalogic.Decidability.SignedFormula` by creating a standalone subformulas definition in the Syntax module.

**Estimated effort**: 1.5 hours

**Objectives**:
1. Create `Formula.subformulas` definition in Bimodal.Syntax
2. Prove basic subformula membership lemmas
3. Update Closure.lean import to use new location
4. Verify build succeeds

**Files to modify**:
- `Theories/Bimodal/Syntax/Subformulas.lean` (create new)
- `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean` - Update import

**Steps**:
1. Create `Theories/Bimodal/Syntax/Subformulas.lean` with:
   - `Formula.subformulas : Formula -> List Formula` definition
   - `phi_mem_subformulas : phi in subformulas phi`
   - Subformula transitivity lemmas for each constructor
2. Add new file to lakefile manifest
3. Update Closure.lean to import from `Bimodal.Syntax.Subformulas`
4. Remove old import `Bimodal.Metalogic.Decidability.SignedFormula`
5. Run `lake build Bimodal.Metalogic_v2.Representation.Closure`

**Verification**:
- `lake build` succeeds for all Metalogic_v2 files
- No imports from `Bimodal.Metalogic` (non-v2) remain

---

### Phase 2: Complete Closure.lean Subformula Membership Lemmas [IN PROGRESS]

**Goal**: Fill in the 5 sorries for subformula membership lemmas that trace through the Formula structure.

**Estimated effort**: 2 hours

**Objectives**:
1. Prove `closure_imp_left` and `closure_imp_right`
2. Prove `closure_box`
3. Prove `closure_all_past` and `closure_all_future`

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean` - Lines 481-523

**Steps**:
1. For `closure_imp_left` (line 487):
   - Use `List.mem_toFinset` to convert to list membership
   - Show `psi in subformulas (imp psi chi)` by constructor definition
   - Use transitivity: if `imp psi chi in subformulas phi` and `psi in subformulas (imp psi chi)`, then `psi in subformulas phi`
2. Apply same pattern for `closure_imp_right` (line 496)
3. For `closure_box` (line 505): simpler - one constructor to trace through
4. For `closure_all_past` (line 514) and `closure_all_future` (line 523): same pattern as box

**Verification**:
- `lean_diagnostic_messages` shows no errors on lines 481-523
- `lake build Bimodal.Metalogic_v2.Representation.Closure` succeeds

---

### Phase 3: Complete Closure.lean MCS Properties [NOT STARTED]

**Goal**: Fill in the 4 sorries related to MCS negation completeness and implication properties.

**Estimated effort**: 2.5 hours

**Objectives**:
1. Prove `closure_mcs_neg_complete` (line 348)
2. Prove `mcs_projection_is_closure_mcs` maximality case (line 472)
3. Prove `closure_mcs_imp_iff` backward direction (lines 608-613)

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean` - Lines 348, 472, 608-613

**Steps**:
1. For `closure_mcs_neg_complete` (line 348):
   - Case analysis on how psi is in closureWithNeg:
     - If psi in closure phi: psi.neg in closureWithNeg by `neg_mem_closureWithNeg`
     - If psi = chi.neg for chi in closure: need careful handling of double negation
   - Use maximality property: if neither psi nor psi.neg in S, derive contradiction
2. For `mcs_projection_is_closure_mcs` (line 472):
   - Show psi.neg in closureWithNeg (follows from case analysis on how psi in closureWithNeg)
   - Use `mcs_contains_or_neg` from full MCS M
   - Show insert psi (projection) inconsistent via psi.neg being in projection
3. For `closure_mcs_imp_iff` backward (lines 608-613):
   - Case psi in S: h_material gives chi in S; derive (psi -> chi) via propositional reasoning
   - Case psi.neg in S: derive (psi -> chi) via explosion pattern
   - Need `chi_imp_psi_chi : chi -> (psi -> chi)` theorem from proof system

**Verification**:
- No sorry markers remain in Closure.lean
- `lake build Bimodal.Metalogic_v2.Representation.Closure` succeeds

---

### Phase 4: Implement Time Arithmetic for respects_task [NOT STARTED]

**Goal**: Complete the time arithmetic proof in `finiteHistoryToWorldHistory.respects_task` (line 286).

**Estimated effort**: 1 hour

**Objectives**:
1. Prove `toInt ft - toInt fs = t - s` where ft and fs are constructed via intToFiniteTime

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - Line 286

**Steps**:
1. Unfold definitions of `intToFiniteTime` and `FiniteTime.toInt`
2. Key identity: `toInt k (intToFiniteTime phi t h) = t` when t in domain
   - `intToFiniteTime phi t h = (t + k, ...)` where k = temporalBound phi
   - `toInt k (t + k, ...) = (t + k) - k = t`
3. Apply to both fs and ft
4. Conclude: `toInt ft - toInt fs = t - s`

**Verification**:
- `lean_goal` at line 286 shows no goals
- No sorry marker at line 286

---

### Phase 5: Implement History Gluing for Compositionality [NOT STARTED]

**Goal**: Complete the history gluing proof in `semantic_task_rel_compositionality` (line 207).

**Estimated effort**: 2.5 hours

**Objectives**:
1. Implement history gluing when two histories agree at a junction point
2. Prove compositionality: w -[d1]-> u and u -[d2]-> v implies w -[d1+d2]-> v

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - Line 207

**Steps**:
1. Extract witnesses from h_wu and h_uv:
   - h1, t1, t1' where h1.states t1 gives w and h1.states t1' gives u
   - h2, t2, t2' where h2.states t2 gives u and h2.states t2' gives v
2. Key observation: h1.states t1' = h2.states t2 (both equal underlying state of u)
3. Define glued history h_glued:
   - For time t < junction point: use h1.states (shifted appropriately)
   - For time t >= junction point: use h2.states (shifted appropriately)
   - Junction is at origin (time 0) after shifting
4. Prove h_glued.states witnesses the composed relation:
   - h_glued at shifted t1 gives w
   - h_glued at shifted t2' gives v
   - Time difference is (t1' - t1) + (t2' - t2) = d1 + d2
5. Handle edge case: if h1 = h2, proof is simpler (single history)

**Verification**:
- `lean_goal` at line 207 shows no goals
- No sorry marker at line 207

---

### Phase 6: Implement Truth Bridge Lemma [NOT STARTED]

**Goal**: Complete `semantic_truth_implies_truth_at` (line 404) connecting finite world state truth to model truth.

**Estimated effort**: 2 hours

**Objectives**:
1. Prove by induction on formula structure that membership in finite world state implies truth_at in model

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - Line 404

**Steps**:
1. Induction on phi (the formula structure):
   - **Atom case**: By definition of semantic_valuation
   - **Bot case**: w.models bot is always false; truth_at bot is always false
   - **Imp case**: Use local consistency of world state and IH
   - **Box case**: Use task relation witnesses and IH
   - **All_past/All_future cases**: Use history structure and IH
2. Key connection: For modal/temporal cases, the history structure of SemanticWorldState provides the witnesses needed for truth_at quantifiers
3. The proof uses the fact that tau.states 0 ht = w, so the world at time 0 in the history is exactly w

**Verification**:
- `lean_goal` at line 404 shows no goals
- No sorry marker at line 404

---

### Phase 7: Complete Main Completeness and Make Definitions Computable [NOT STARTED]

**Goal**: Complete `main_weak_completeness_v2` (line 554) and make key definitions computable.

**Estimated effort**: 1.5 hours

**Objectives**:
1. Complete the main completeness theorem proof
2. Make `intToFiniteTime` computable by removing Classical dependency
3. Add computable DecidableEq for FiniteWorldState

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - Line 554
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteWorldState.lean` - Make definitions computable

**Steps**:
1. For `main_weak_completeness_v2`:
   - With Phase 6 complete, use semantic_truth_implies_truth_at
   - Connect: tau.states 0 h_dom to sw, sw.toFiniteWorldState to w
   - Use constant history property: all states equal w
   - Derive contradiction from h_phi_false and h_truth
2. For `intToFiniteTime`:
   - Current definition uses `.toNat` which is already computable
   - Remove `noncomputable` keyword if no Classical dependencies remain
3. For FiniteWorldState.DecidableEq:
   - Add: `instance (phi : Formula) : DecidableEq (FiniteWorldState phi)`
   - Use `decidable_of_iff (w1.assignment = w2.assignment) FiniteWorldState.ext_iff`
   - Requires `DecidableEq (FiniteTruthAssignment phi)` which comes from Pi.instDecidableEq

**Verification**:
- No sorry markers in SemanticCanonicalModel.lean
- `lake build Bimodal.Metalogic_v2` succeeds
- Definitions that were `noncomputable` now compile without that keyword (where possible)

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic_v2` completes without errors
- [ ] No sorry markers remain in SemanticCanonicalModel.lean (0 of 4)
- [ ] No sorry markers remain in Closure.lean (0 of 9)
- [ ] Import `Bimodal.Metalogic.Decidability.SignedFormula` removed from Metalogic_v2
- [ ] `main_provable_iff_valid_v2` compiles without sorry
- [ ] Tests in `Tests/BimodalTest/Metalogic_v2/` pass
- [ ] `intToFiniteTime` compiles without `noncomputable` marker

## Artifacts & Outputs

- `Theories/Bimodal/Syntax/Subformulas.lean` - New file with Formula.subformulas
- `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean` - 9 sorries resolved
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - 4 sorries resolved
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteWorldState.lean` - Computable instances added
- `specs/470_finite_model_computational_optimization/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If changes break existing proofs:
1. Phase 1 (migration) can be reverted by restoring old import
2. Each phase is independent except Phase 7 depends on Phases 4-6
3. Git commit after each phase enables selective rollback
4. If history gluing (Phase 5) proves too complex, mark as sorry with detailed comment and proceed with other phases
