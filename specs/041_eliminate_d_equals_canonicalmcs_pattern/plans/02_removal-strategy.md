# Implementation Plan: Task #41 - D=CanonicalMCS Removal Strategy (v2)

- **Task**: 41 - eliminate_d_equals_canonicalmcs_pattern
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Dependencies**: None (SuccChain path is already independent)
- **Research Inputs**:
  - specs/041_eliminate_d_equals_canonicalmcs_pattern/reports/02_deep-research.md
  - specs/041_eliminate_d_equals_canonicalmcs_pattern/reports/03_removal-analysis.md
- **Artifacts**: plans/02_removal-strategy.md (this file)
- **Supersedes**: plans/01_coexistence-strategy.md
- **Type**: lean4
- **Lean Intent**: true (zero-sorry policy compliance)

## Overview

**Key Finding from Updated Research**: D=CanonicalMCS is **dead infrastructure**, not load-bearing. The SuccChain completeness path (D=Int) is already complete and **never references CanonicalMCS**. The "algebraic" path that uses CanonicalMCS has 4 blocking sorries and recommends SuccChain.

**Strategy Change**: From "coexistence" to **full removal**. Delete 8-10 files of dead infrastructure and clean imports from 5-6 files. This is primarily a cleanup operation.

### Research Summary

From 03_removal-analysis.md:
1. **Two completeness paths exist**:
   - Path A: SuccChain (D=Int) - ACTIVE, uses NO CanonicalMCS references
   - Path B: Algebraic (D=CanonicalMCS -> D=Int) - BLOCKED with 4 sorries
2. **FMCSTransfer is dead infrastructure** - never instantiated by active code
3. **`temporal_coherent_family_exists_CanonicalMCS`** is sorry-free but **never consumed** by any completeness theorem
4. **The 2 remaining sorries** (`f/p_nesting_is_bounded`) are in SuccChain path, unrelated to CanonicalMCS

## Goals & Non-Goals

**Goals**:
- Delete 8-10 files of dead D=CanonicalMCS infrastructure
- Remove CanonicalFMCS imports from active files (5-6 files)
- Decide on algebraic path retention (recommend deletion)
- Clean FMCSDef.lean comments
- Maintain zero-sorry policy (no new sorries)

**Non-Goals**:
- Fix the SuccChain sorries (Task 48 handles this)
- Retain coexistence model (superseded by removal)
- Preserve dead infrastructure "for history" (git history suffices)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking transitive imports | High | Medium | Check `lake build` after each deletion batch |
| Losing elegant proofs | Low | - | Git history preserves; proofs never fed completeness |
| Breaking dense completeness | None | - | DenseCompleteness only has comment references |
| Breaking algebraic completeness | Low | - | Already blocked by 4 sorries |

## Implementation Phases

### Phase 1: Delete Dead Infrastructure Files [NOT STARTED]

**Goal**: Remove files that are never imported by active completeness proofs.

**Files to delete** (move to Boneyard with headers):
1. `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean` - Dead transfer infrastructure
2. `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean` - Chain FMCS over CanonicalMCS flags
3. `Theories/Bimodal/Metalogic/Bundle/ClosedFlagBundle.lean` - Closed flag set construction
4. `Theories/Bimodal/Metalogic/Bundle/ClosedFlagIntBFMCS.lean` - Superseded by DirectMultiFamilyBFMCS
5. `Theories/Bimodal/Metalogic/Bundle/WitnessFamilyBundle.lean` - Witness family for CanonicalMCS
6. `Theories/Bimodal/Metalogic/Bundle/SaturatedBFMCSConstruction.lean` - Modal saturation over CanonicalMCS
7. `Theories/Bimodal/Metalogic/Bundle/ModalWitnessData.lean` - Modal witness data using CanonicalMCS
8. `Theories/Bimodal/Metalogic/Algebraic/CanonicalQuot.lean` - Antisymmetrization of CanonicalMCS
9. `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean` - Multi-family BFMCS over CanonicalMCS

**Tasks**:
- [ ] Create `Boneyard/CanonicalMCS_DeadInfrastructure/` directory
- [ ] Move each file with preservation header
- [ ] Run `lake build` after each batch (recommend batches of 2-3)
- [ ] Document import dependency order for clean removal

**Timing**: 2-3 hours

**Verification**:
- `lake build` succeeds with no new errors
- All files preserved in Boneyard

---

### Phase 2: Clean Imports from Active Files [NOT STARTED]

**Goal**: Remove `import Bimodal.Metalogic.Bundle.CanonicalFMCS` from files that only reference it in comments.

**Files to clean**:
1. `Theories/Bimodal/Metalogic/BaseCompleteness.lean` - Comments only
2. `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - Comments only
3. `Theories/Bimodal/Metalogic/DiscreteCompleteness.lean` - Comments only
4. `Theories/Bimodal/Metalogic/Completeness.lean` - Comments only
5. `Theories/Bimodal/LogicVariants.lean` - Fix broken `dense_components_proven` reference

**Tasks**:
- [ ] Remove import statements
- [ ] Clean/update comments that reference CanonicalMCS
- [ ] Fix LogicVariants.lean broken reference (either remove or point to SuccChain)
- [ ] Run `lake build` after each file

**Timing**: 1 hour

**Verification**:
- `lake build` succeeds
- No CanonicalFMCS imports remain in these files

---

### Phase 3: Decide on Algebraic Path [NOT STARTED]

**Goal**: Make architectural decision on DirectMultiFamilyBFMCS and related infrastructure.

**Background**: DirectMultiFamilyBFMCS uses CanonicalMCS for parameterization but has 4 blocking sorries. Its own documentation recommends SuccChain.

**Decision Point**: Delete or retain?

**Option A (RECOMMENDED): Delete Algebraic Path**
- Delete `Bundle/DirectMultiFamilyBFMCS.lean` (4 blocking sorries)
- Delete `Bundle/ModallyCoherentBFMCS.lean` (used only by DirectMultiFamilyBFMCS)
- Simplify `Algebraic/AlgebraicBaseCompleteness.lean` (remove sorry-backed code)
- SuccChain completeness becomes THE completeness theorem

**Option B: Retain Algebraic Path**
- Refactor DirectMultiFamilyBFMCS to use `(M : Set Formula, h_mcs : SetMaximalConsistent M)` wrapper
- Keep 4 sorries but document as future work
- More code to maintain for uncertain benefit

**Tasks**:
- [ ] Analyze transitive dependencies of DirectMultiFamilyBFMCS
- [ ] Check if any sorry-free code depends on it
- [ ] Make decision (recommend Option A unless strong reason for B)
- [ ] Execute deletion or refactoring

**Timing**: 2 hours

**Verification**:
- Clear architectural path forward
- `lake build` succeeds
- No orphaned imports

---

### Phase 4: Delete CanonicalFMCS.lean [NOT STARTED]

**Goal**: Remove the core D=CanonicalMCS definition file.

**Prerequisites**: Phases 1-3 complete (all importers removed)

**Tasks**:
- [ ] Verify no imports of CanonicalFMCS.lean remain
- [ ] Move to `Boneyard/CanonicalMCS_DeadInfrastructure/CanonicalFMCS.lean`
- [ ] Run `lake build`

**Timing**: 0.5 hours

**Verification**:
- `lake build` succeeds
- CanonicalFMCS.lean preserved in Boneyard

---

### Phase 5: Clean FMCSDef.lean Comments [NOT STARTED]

**Goal**: Remove D=CanonicalMCS commentary from FMCS definition file.

**Tasks**:
- [ ] Review FMCSDef.lean lines 20-31 (documented anti-pattern warning)
- [ ] Update/remove comments that reference the now-deleted pattern
- [ ] Add note pointing to SuccChain as canonical implementation

**Timing**: 0.5 hours

**Verification**:
- Documentation reflects current architecture
- No references to deleted infrastructure

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] No new sorries introduced (grep confirms)
- [ ] SuccChainCompleteness still compiles and proves
- [ ] No imports of deleted files remain (grep confirms)
- [ ] Boneyard preserves full file contents with headers

## Artifacts & Outputs

- `Boneyard/CanonicalMCS_DeadInfrastructure/` - 8-10 archived files
- Cleaned imports in 5+ active files
- Updated FMCSDef.lean documentation
- Summary report after completion

## Rollback/Contingency

**If any phase breaks build unexpectedly**:
1. `git checkout` the modified files
2. Analyze the transitive dependency that was missed
3. Add file to "retain" list or fix the dependency first

**If Option A (delete algebraic path) proves wrong**:
1. Restore from Boneyard
2. Refactor to Option B approach

## Success Criteria

Task 41 is complete when:
- [ ] All 8-10 dead infrastructure files moved to Boneyard (Phase 1)
- [ ] CanonicalFMCS imports removed from active files (Phase 2)
- [ ] Algebraic path decision made and executed (Phase 3)
- [ ] CanonicalFMCS.lean itself removed (Phase 4)
- [ ] FMCSDef.lean documentation updated (Phase 5)
- [ ] `lake build` succeeds with zero new sorries
- [ ] No imports of CanonicalFMCS remain in codebase

## Comparison with Previous Plan (v1)

| Aspect | v1 (Coexistence) | v2 (Removal) |
|--------|------------------|--------------|
| Premise | D=CanonicalMCS is load-bearing | D=CanonicalMCS is dead infrastructure |
| Strategy | Keep CanonicalMCS, add D=Int via FMCSTransfer | Delete CanonicalMCS entirely |
| Effort | 4h immediate + deferred | 6-8h total |
| Dependencies | Blocked on Tasks 48, 36, 37 | None |
| Risk | Low (documentation only) | Medium (deletion of 10+ files) |
| Outcome | Dual architecture | Clean single path (SuccChain) |

The key insight from 03_removal-analysis.md is that FMCSTransfer is dead, the algebraic path has 4 blocking sorries, and SuccChain already provides complete D=Int infrastructure without CanonicalMCS.
