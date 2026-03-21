# Implementation Plan: Task #900

- **Task**: 900 - Prove cut rule / derivation tree manipulation for RecursiveSeed consistency
- **Status**: [PARTIAL]
- **Effort**: 4 hours
- **Dependencies**: Task 864 (parent task, Phase 4)
- **Research Inputs**: specs/900_prove_cut_rule_derivation_tree_manipulation/reports/research-002.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This is plan version 002, revising the approach after team research revealed key insights. The original plan (v1) completed Phases 1, 2, and 4, but blocked on Phase 3's positive modal/temporal cases (`boxPositive`, `futurePositive`, `pastPositive`). Team research discovered:

1. **Temporal cases may already work**: The algorithm adds `G psi` before `psi`, and existing lemmas `foldl_addFormula_times_preserves_consistent_with_gpsi` / `_with_hpsi` may already handle these cases.
2. **`insert_consistent_of_derivable_parent` verified**: A new theorem was proven (zero sorries) providing a path forward.
3. **boxPositive requires architecture change**: The algorithm can create contradictions depending on processing order. Solution: prove SeedConsistent as POST-CONDITION of closure properties, not as loop invariant.

### Research Integration

From research-002.md:
- Cut elimination is NOT needed - derivation composition infrastructure already exists
- The `boxPositive` blocker is SEMANTIC (processing order can create contradictions)
- Temporal cases add the parent formula (`G psi` / `H psi`) before the child, which enables use of existing `_with_gpsi` / `_with_hpsi` lemmas
- New theorem `insert_consistent_of_derivable_parent` was verified to compile with zero sorries

## Goals & Non-Goals

**Goals**:
- Verify temporal cases (`futurePositive`, `pastPositive`) work with existing infrastructure (potential quick win)
- Add `insert_consistent_of_derivable_parent` and corollaries to codebase
- Implement post-condition architecture for `boxPositive`: weaken loop invariant, prove SeedConsistent from closure properties
- Reduce blocked sorries from 3 to 0 in Phase 3 of original plan

**Non-Goals**:
- Modifying the worklist algorithm's processing order (solution 2 from research)
- Modifying the worklist algorithm to propagate parent first (solution 3 from research)
- Adding new axioms (only use existing proof infrastructure)
- Proving Phase 5 closure properties (separate concern, though they enable this solution)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Temporal cases don't work with existing lemmas | Medium | Medium | Fall back to insert_consistent_of_derivable_parent approach |
| Post-condition architecture requires extensive refactoring | High | Low | Research confirms this aligns with mathematical reality; implementation is modular |
| Closure properties not yet proven | High | Medium | May need to prove ModalClosed, GClosed, HClosed first (these are Phase 5 in parent task) |
| Algorithm add order different than expected | Medium | Low | Verify exact add sequence in processWorkItem before attempting proof |

## Sorry Characterization

### Pre-existing Sorries
- 3 sorries in `processWorkItem_preserves_consistent`:
  - `boxPositive` case (line ~6530)
  - `futurePositive` case (line ~6547)
  - `pastPositive` case (line ~6553)

### Expected Resolution
- Phase 1: Verify temporal cases, potentially resolve 2 sorries using existing `_with_gpsi` / `_with_hpsi` lemmas
- Phase 2: Add `insert_consistent_of_derivable_parent` (foundational building block)
- Phase 3: Implement post-condition architecture for boxPositive (resolve final sorry)

### New Sorries
- None expected. All proofs use existing infrastructure or newly verified theorems.

### Remaining Debt
After this implementation:
- 0 sorries in processWorkItem positive cases
- Phase 5 (closure properties) sorries remain separate but may be needed as dependencies

## Implementation Phases

### Phase 1: Verify Temporal Cases [PARTIAL]

- **Dependencies:** None
- **Goal:** Determine if `futurePositive` and `pastPositive` are provable NOW with existing infrastructure

**Rationale**: The `processWorkItem` for `futurePositive` adds BOTH `G psi` AND `psi` to each future time. The existing lemma `foldl_addFormula_times_preserves_consistent_with_gpsi` handles exactly this case - it requires `G psi` to be at target entries.

**Tasks**:
- [x] Read `processWorkItem` futurePositive case (lines 6544-6555) to verify exact add order
- [x] Verify `G psi` is added BEFORE `psi` at each time step
- [ ] ~~Attempt proof using `addToAllFutureTimes_preserves_seedConsistent_with_gpsi`~~
- [ ] ~~If successful, repeat for `pastPositive` using `_with_hpsi` variant~~
- [x] If blocked, document exactly what's missing

**Finding**: The add order is REVERSED from what the lemma requires:
- Actual order in foldl: `psi` is added FIRST, then `G psi` is added second
- Required order for existing lemma: `G psi` must be present BEFORE adding `psi`

This means `foldl_addFormula_times_preserves_consistent_with_gpsi` cannot be applied directly. The `addFormula_seed_preserves_consistent` requires that adding `psi` to each entry preserves consistency, but without `G psi` already in the entry, we cannot use the derivability argument.

**Blocked - requires Phase 3 approach**: A new helper lemma is needed that proves adding BOTH `psi` and `G psi` together preserves consistency, regardless of the internal add order. This is the "post-condition architecture" from Phase 3.

**Expected Outcome**: 2 sorries eliminated if add order is as expected; 0 sorries eliminated if order is reversed.

**Actual Outcome**: 0 sorries eliminated. Blocked on add order.

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (lines 6544-6555)

**Verification**:
- If successful: `lake build` succeeds, 2 fewer sorries in positive cases
- If blocked: Document blockers for Phase 3 approach

**Progress:**

**Session: 2026-02-18, sess_1771443646_20904f**
- Analyzed: `processWorkItem` futurePositive case structure (lines 6544-6555)
- Found: Add order is reversed - psi added before G psi in foldl
- Blocked: Cannot use `foldl_addFormula_times_preserves_consistent_with_gpsi` directly
- No changes committed (analysis only)

---

### Phase 2: Add insert_consistent_of_derivable_parent [COMPLETED]

- **Dependencies:** None (can run in parallel with Phase 1)
- **Goal:** Add the verified `insert_consistent_of_derivable_parent` theorem and its corollaries to the codebase

**Rationale**: This theorem was verified to compile with zero sorries in research. It provides a crucial building block regardless of which solution path is chosen for `boxPositive`.

**Theorem Statement** (verified to compile):
```lean
noncomputable def insert_consistent_of_derivable_parent
    {S : Set Formula} {parent child : Formula}
    (h_S_cons : SetConsistent S)
    (h_parent_in : parent ∈ S)
    (h_derives : |- parent.imp child) :
    SetConsistent (insert child S)
```

**Tasks**:
- [x] Find appropriate location in RecursiveSeed.lean (near existing consistency lemmas, ~line 2648-3002)
- [x] Add `insert_consistent_of_derivable_parent` theorem
- [x] Add three corollaries:
  - `insert_psi_consistent_of_box_psi_in`: If `Box psi` in S, then `insert psi S` consistent
  - `insert_psi_consistent_of_g_psi_in`: If `G psi` in S, then `insert psi S` consistent
  - `insert_psi_consistent_of_h_psi_in`: If `H psi` in S, then `insert psi S` consistent
- [x] Verify proofs use only existing infrastructure (T-axioms, imp_trans)
- [x] Build and verify no errors

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (insert near line 2900)

**Verification**:
- `lake build` succeeds
- New theorems have no sorries
- `lean_verify` on each theorem shows no axiom dependencies beyond standard ones

**Progress:**

**Session: 2026-02-18, sess_1771443646_20904f**
- Added: `insert_consistent_of_derivable_parent` at line ~1698 (after `addFormula_preserves_consistent`)
- Added: `insert_psi_consistent_of_box_psi_in` (corollary for Box using modal_t axiom)
- Added: `insert_psi_consistent_of_g_psi_in` (corollary for G using temp_t_future axiom)
- Added: `insert_psi_consistent_of_h_psi_in` (corollary for H using temp_t_past axiom)
- Verified: `lake build` succeeds (1000 jobs), no new sorries

---

### Phase 3: Post-Condition Architecture for boxPositive [BLOCKED]

- **Dependencies:** Phase 2 (uses insert_consistent_of_derivable_parent), **Phase 5 of parent task 864 (closure properties)**
- **Goal:** Prove `boxPositive` case using post-condition architecture

**Rationale**: The `boxPositive` case adds `psi` to ALL families at current time, but `Box psi` is only present in ONE family. This makes per-entry consistency unprovable as a loop invariant. Solution: prove consistency is a POST-CONDITION derived from closure properties.

**Architecture**:
1. Weaken `WorklistInvariant` to require only `FormulaConsistent` for each formula (not per-entry SeedConsistent)
2. Prove closure properties first: `ModalClosed`, `GClosed`, `HClosed` (if not already proven in Phase 5 of parent task)
3. Derive `SeedConsistent` from closures: In the completed seed, if `Box psi` is at any position, then by `ModalClosed`, `psi` is also there. The `insert_consistent_of_derivable_parent` corollaries then justify each formula's presence.

**Tasks**:
- [x] Check if `ModalClosed`, `GClosed`, `HClosed` are proven (Phase 5 of parent task)
- [ ] ~~If closure properties exist:~~
  - [ ] ~~Refactor `processWorkItem_preserves_consistent` for boxPositive to use post-condition approach~~
  - [ ] ~~Use `insert_psi_consistent_of_box_psi_in` with closure property witness~~
- [x] If closure properties don't exist:
  - [x] Document dependency on Phase 5 of parent task

**Blocker Analysis**:
- `processWorkItem_preserves_closure` (line 8023) has a sorry - "10-case proof"
- This theorem is needed to prove that the completed seed satisfies closure properties
- Without closure properties proven, the post-condition approach cannot be applied
- The `insert_psi_consistent_of_box_psi_in` corollary (added in Phase 2) IS ready to use once closure is proven

**Dependency**: Requires Phase 5 of task 864 (closure property proofs) to be completed first

**Alternative Approach** (if closures blocked): The worklist algorithm ensures `Box psi` work item is processed before its subformula `psi` is added globally. We can potentially track that `Box psi` WAS added to the seed before `psi` was propagated, even if `Box psi` isn't present at every entry.

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (lines 6525-6540)

**Verification**:
- `lake build` succeeds
- `boxPositive` case has no sorry
- No new axioms introduced

**Progress:**

**Session: 2026-02-18, sess_1771443646_20904f**
- Checked: Closure properties (ModalClosed, GClosed, HClosed) defined but not fully proven
- Found: `processWorkItem_preserves_closure` at line 8023 has sorry ("10-case proof")
- Found: `processWorklistAux_preserves_closure` at line 8037 has sorry ("fuel sufficiency argument")
- Blocked: Cannot apply post-condition architecture until Phase 5 closure properties are proven
- Added building block: `insert_psi_consistent_of_box_psi_in` corollary is READY to use once closure proven
- No changes committed to boxPositive case (blocked on dependency)

---

## Testing & Validation

- [x] `lake build` completes with no errors
- [x] No new sorries introduced in RecursiveSeed.lean
- [x] No new axioms introduced
- [ ] Three positive cases (`boxPositive`, `futurePositive`, `pastPositive`) have no sorries
  - **Status**: Still have 3 sorries (blocked on Phase 1 add order, Phase 3 closure properties)
- [ ] `lean_verify` on `processWorkItem_preserves_consistent` shows no suspicious axioms

## Artifacts & Outputs

- `plans/implementation-002.md` (this file)
- `summaries/implementation-summary-{DATE}.md` (post-implementation)
- Modified: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`

## Rollback/Contingency

If temporal cases don't work with existing lemmas:
1. Document exact blocker (add order, missing hypothesis, etc.)
2. Apply Phase 3 post-condition approach to all three cases uniformly

If post-condition architecture requires closure properties not yet proven:
1. Create explicit dependency on task 864 Phase 5
2. Mark `boxPositive` sorry with comment: "Blocked: requires ModalClosed from Phase 5"
3. Return partial completion

If refactoring WorklistInvariant causes cascading changes:
1. Preserve current invariant
2. Add separate `WorklistInvariant_FormulaConsistent` as weaker property
3. Prove SeedConsistent from weaker property + closures at termination
