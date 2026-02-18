# Implementation Plan: Recursive Seed Henkin Model Construction (v6 - Post-Condition Architecture)

- **Task**: 864 - Recursive seed construction for Henkin model completeness
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (supersedes implementation-005.md approach)
- **Research Inputs**:
  - specs/864_recursive_seed_henkin_model/reports/research-007.md (worklist algorithm design)
  - specs/900_prove_cut_rule_derivation_tree_manipulation/reports/research-002.md (post-condition architecture)
- **Artifacts**: plans/implementation-006.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary (v005 -> v006)

Based on task 900's team research discovering that `SeedConsistent` should be a **post-condition of closure**, not a loop invariant:

| Aspect | v005 | v006 Changes |
|--------|------|--------------|
| Consistency approach | Loop invariant (22 sorries blocked) | **Post-condition**: derive from closure properties |
| Key theorem | None | **`insert_consistent_of_derivable_parent`** (verified zero-sorry) |
| Phase order | Phases 4/5 parallel | **Phase 5 (closure) BEFORE Phase 4 (consistency)** |
| Temporal cases | Blocked with boxPositive | **May be provable NOW** using existing `_with_gpsi`/`_with_hpsi` lemmas |
| boxPositive blocker | Unresolved | **Resolved** via closure: if Box psi at position, psi also there by ModalClosed |

**Key insight from task 900 research**: The worklist algorithm can create semantic inconsistencies depending on processing order (e.g., `neg(Box p)` before `Box p` creates `{neg p, p}`). Instead of maintaining `SeedConsistent` as a loop invariant, we:
1. Complete closure proofs (ModalClosed, GClosed, HClosed) first
2. Derive `SeedConsistent` FROM closure properties using `insert_consistent_of_derivable_parent`

This is mathematically elegant because consistency is a **global property** of the completed model, not a local property of intermediate construction states.

## Overview

This plan restructures the implementation to prioritize closure proofs and use them to derive consistency as a post-condition. The key building block is the verified `insert_consistent_of_derivable_parent` theorem:

```lean
noncomputable def insert_consistent_of_derivable_parent
    {S : Set Formula} {parent child : Formula}
    (h_S_cons : SetConsistent S)
    (h_parent_in : parent ∈ S)
    (h_derives : |- parent.imp child) :
    SetConsistent (insert child S)
```

With corollaries for Box, G, and H modalities that justify each formula's presence in a consistent manner.

### Research Integration

From research-002.md (task 900 team research):
- **`insert_consistent_of_derivable_parent`** - Verified to compile with zero sorries
- **Post-condition architecture** - Both teammates converge on this as most elegant
- **Temporal cases insight** - `futurePositive` and `pastPositive` may work with existing lemmas
- **Processing order counterexample** - Explains why loop invariant approach is fundamentally blocked

## Goals & Non-Goals

**Goals**:
- Add `insert_consistent_of_derivable_parent` and corollaries to codebase
- Complete closure proofs (ModalClosed, GClosed, HClosed) with zero sorries
- Derive `SeedConsistent` from closure properties
- Resolve all 22 sorries in RecursiveSeed.lean consistency section
- Resolve all 5 sorries in SeedCompletion.lean
- Publication-ready: zero sorries, zero axioms

**Non-Goals**:
- Modifying the worklist algorithm structure
- Changing the existing `ModelSeed` data structure
- Adding new axioms (NEVER)
- Modifying Completeness.lean directly

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Closure proofs more complex than expected | High | Medium | Helper lemmas already proven in v005; follow same pattern |
| `insert_consistent_of_derivable_parent` doesn't integrate cleanly | Medium | Low | Theorem verified to compile; matches existing API |
| Temporal cases still need special handling | Low | Low | Task 900 research indicates existing lemmas should work |
| SeedCompletion integration difficulty | Medium | Medium | Bridge lemmas provide modular connection |

## Sorry Characterization

### Pre-existing Sorries

**RecursiveSeed.lean** (22 sorries in Phase 4):
- `processWorkItem_preserves_consistent` - 10 case sorries (boxPositive, futurePositive, pastPositive blocked)
- `processWorkItem_newWork_consistent` - 6 case sorries (modal/temporal cases)
- Helper lemmas - 6 sorries (box_inner_consistent, etc.)

**RecursiveSeed.lean** (3 sorries in Phase 5):
- `processWorkItem_preserves_closure` - 1 sorry
- `processWorklistAux_preserves_closure` - 2 sorries

**SeedCompletion.lean** (5 sorries):
- Line 161: `modal_witness_includes_boxcontent`
- Line 246: `forward_G` (cross-sign case)
- Line 256: `backward_H` (cross-sign case)
- Line 328: `buildFamilyFromSeed_cross_sign_seed`
- Line 372: `buildFamilyFromSeed_contains_seed` (t!=0)

### Expected Resolution

- **Phase 1**: Add `insert_consistent_of_derivable_parent` (0 new sorries)
- **Phase 2**: Complete closure proofs (reduce 3 sorries to 0)
- **Phase 3**: Derive consistency from closure (reduce 22 sorries to 0)
- **Phase 4**: Connect to SeedCompletion (reduce 5 sorries to 0)

### New Sorries

- None expected. The post-condition architecture is specifically designed to avoid the loop invariant blockers.

### Remaining Debt

After this implementation:
- 0 sorries in RecursiveSeed.lean (worklist algorithm path)
- 0 sorries in SeedCompletion.lean
- 3 non-critical sorries remain in RecursiveSeed.lean (buildSeedForList helper - not on critical path)
- Completeness theorem becomes publication-ready

## Axiom Characterization

### Pre-existing Axioms

- None in scope. The worklist algorithm uses only standard derivation rules.

### Expected Resolution

- N/A - no axioms to resolve

### New Axioms

- NEVER. The `insert_consistent_of_derivable_parent` theorem uses only standard derivation composition.

### Remaining Debt

- 0 axioms expected in saturation module
- Publication-ready without axiom disclosure

## Implementation Phases

### Phase 1: Add Key Theorem [NOT STARTED]

- **Dependencies:** None
- **Goal:** Add `insert_consistent_of_derivable_parent` and corollaries to RecursiveSeed.lean

**Tasks**:
- [ ] Add `insert_consistent_of_derivable_parent` theorem (from task 900 research)
- [ ] Add `insert_psi_consistent_of_box_psi_in` corollary
- [ ] Add `insert_psi_consistent_of_g_psi_in` corollary
- [ ] Add `insert_psi_consistent_of_h_psi_in` corollary
- [ ] Verify all compile with zero sorries

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - Add after existing consistency lemmas

**Verification:**
- `lake build` succeeds
- `#check insert_consistent_of_derivable_parent` shows correct type
- No sorries in new code

---

### Phase 2: Complete Closure Proofs [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Prove ModalClosed, GClosed, HClosed for buildSeedComplete output with zero sorries

**Tasks**:
- [ ] Complete `processWorkItem_preserves_closure` (currently 1 sorry)
  - Case analysis on classifyFormula for all 10 cases
  - Use helper lemmas: `foldl_addFormula_fam_puts_phi_in_all`, `foldl_addFormula_times_puts_phi_in_all`
- [ ] Complete `processWorklistAux_preserves_closure` (currently 2 sorries)
  - Fuel=0 case: handle termination
  - Process application case: chain through processWorkItem
- [ ] Verify `buildSeedComplete_closed` compiles with zero sorries
- [ ] Add `SeedClosed_implies_ModalClosed`, `SeedClosed_implies_GClosed`, `SeedClosed_implies_HClosed` extractors

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - Complete Phase 5 section

**Verification:**
- `lake build` succeeds
- 0 sorries in closure proof section
- `#check buildSeedComplete_closed` shows `SeedClosed (buildSeedComplete phi).seed`

---

### Phase 3: Derive Consistency from Closure [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Replace loop invariant consistency with post-condition derivation using closure properties

**Tasks**:
- [ ] Define `FormulaConsistent : Formula -> Prop` (weaker than SeedConsistent)
- [ ] Define `WorklistInvariant_Weak : WorklistState -> Prop` replacing SeedConsistent with FormulaConsistent
- [ ] Prove `processWorkItem_preserves_weak_invariant` (should be simpler than original)
- [ ] Prove `processWorklistAux_preserves_weak_invariant`
- [ ] Prove `closed_seed_implies_consistent`:
  ```lean
  theorem closed_seed_implies_consistent
      (h_closed : SeedClosed seed)
      (h_formula_cons : FormulaConsistent phi) :
      SeedConsistent seed
  ```
  - Uses `insert_consistent_of_derivable_parent` corollaries
  - For each position: if Box psi present, psi also there (ModalClosed) -> consistent
  - Similarly for G and H using GClosed, HClosed
- [ ] Prove `buildSeedComplete_consistent`:
  ```lean
  theorem buildSeedComplete_consistent (phi : Formula) (h : FormulaConsistent phi) :
      SeedConsistent (buildSeedComplete phi).seed
  ```
- [ ] Remove or deprecate old `processWorkItem_preserves_consistent` (22 sorries)

**Timing:** 3 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - Restructure Phase 4 section

**Verification:**
- `lake build` succeeds
- 0 sorries in consistency proof section
- `#check buildSeedComplete_consistent` shows correct type

---

### Phase 4: Check Temporal Cases with Existing Lemmas [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Verify that futurePositive and pastPositive cases work with existing infrastructure

**Tasks**:
- [ ] Examine `processWorkItem` futurePositive case (lines 6544-6555)
  - Verify it adds BOTH `psi` AND `G psi` to each future time
- [ ] Check if `foldl_addFormula_times_preserves_consistent_with_gpsi` (line 2903) applies
  - This lemma handles exactly the case where G psi is at target entries
- [ ] Similarly check pastPositive with `_with_hpsi` variant
- [ ] If working: Document that only boxPositive was truly blocked
- [ ] If not working: Document specific gap for Phase 3 attention

**Timing:** 1 hour

**Files to modify:**
- None (investigation only)

**Verification:**
- Document findings in this plan's Progress section
- Update Phase 3 approach if needed

---

### Phase 5: SeedCompletion Integration [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Connect closure properties to SeedCompletion.lean, resolve 5 sorries

**Tasks**:
- [ ] Update SeedCompletion.lean imports
- [ ] Prove `seed_to_mcs_box` using ModalClosed:
  - Box psi in seed at (f,t) implies psi in MCS at all families
- [ ] Prove `seed_to_mcs_G` using GClosed:
  - G psi in seed implies psi in MCS at all future times
- [ ] Prove `seed_to_mcs_H` using HClosed:
  - H psi in seed implies psi in MCS at all past times
- [ ] Resolve sorry at line 246 (forward_G cross-sign case)
- [ ] Resolve sorry at line 256 (backward_H cross-sign case)
- [ ] Resolve sorry at line 328 (buildFamilyFromSeed_cross_sign_seed)
- [ ] Resolve sorry at line 161 (modal_witness_includes_boxcontent)
- [ ] Resolve sorry at line 372 (buildFamilyFromSeed_contains_seed t!=0)

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean` - Resolve 5 sorries
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - Add bridge lemmas if needed

**Verification:**
- `lake build` succeeds
- `grep -c "sorry" SeedCompletion.lean` returns 0
- SeedBMCS.lean compiles

---

### Phase 6: Final Verification [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Verify publication-ready status

**Tasks**:
- [ ] Run `lake build` on entire Theories/ directory
- [ ] Verify `grep "sorry" RecursiveSeed.lean` shows only 3 non-critical sorries
- [ ] Verify `grep "sorry" SeedCompletion.lean` shows 0 sorries
- [ ] Verify `grep "axiom" RecursiveSeed.lean` shows 0 axioms
- [ ] Run `lean_verify` on `buildSeedComplete_consistent` theorem
- [ ] Run `lean_verify` on key SeedCompletion theorems
- [ ] Create implementation summary

**Timing:** 1 hour

**Files to modify:**
- None (verification only)
- `specs/864_recursive_seed_henkin_model/summaries/implementation-summary-YYYYMMDD.md` (create)

**Verification:**
- Zero sorries on critical path
- Zero axioms
- All verification passes

---

## Testing & Validation

- [ ] `lake build` succeeds on entire Theories/ directory
- [ ] `grep "sorry" RecursiveSeed.lean` shows only 3 non-critical sorries
- [ ] `grep "sorry" SeedCompletion.lean` shows 0 sorries
- [ ] `lean_verify` passes on `insert_consistent_of_derivable_parent`
- [ ] `lean_verify` passes on `buildSeedComplete_consistent`
- [ ] `lean_verify` passes on key closure theorems
- [ ] All closures provable without axioms

## Artifacts & Outputs

- `specs/864_recursive_seed_henkin_model/plans/implementation-006.md` (this file)
- Modified `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
- Modified `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean`
- `specs/864_recursive_seed_henkin_model/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If the post-condition architecture proves intractable:

1. **Weaker invariant alternative**: Use `FormulaConsistent` alone without deriving full `SeedConsistent`
2. **Processing order constraint**: Modify algorithm to process positive before negative items
3. **Preserve v005 work**: All Phase 1-3 (data structures, algorithm, termination) remain valid
4. **Partial closure**: Accept closure properties without full consistency derivation (blocks some SeedCompletion sorries)

The new code is additive. Rollback requires only removing new derivation theorems and reverting to v005's incomplete consistency proofs.
