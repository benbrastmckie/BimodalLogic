# Implementation Plan: Recursive Seed Henkin Model - File Split and Incremental Rebuild (v7)

- **Task**: 864 - Recursive seed construction for Henkin model completeness
- **Status**: [PARTIAL]
- **Effort**: 22 hours (realistic estimate)
- **Dependencies**: None (supersedes implementation-006.md)
- **Research Inputs**:
  - specs/864_recursive_seed_henkin_model/reports/research-008.md (meta-analysis and Option B recommendation)
  - specs/864_recursive_seed_henkin_model/reports/research-007.md (worklist algorithm design)
- **Artifacts**: plans/implementation-007.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary (v006 -> v007)

v006 was blocked by ~100 build errors in the monolithic 11,694-line RecursiveSeed.lean. The user has chosen **Option B** from research-008.md: split the file first, then fix build errors incrementally in smaller files, then proceed with proof completion.

| Aspect | v006 | v007 Changes |
|--------|------|--------------|
| File structure | Single 11,694-line file | **Split into 5 files** under RecursiveSeed/ directory |
| Build strategy | Fix all 100+ errors in one file | **Fix errors per-file** (smaller, independent) |
| Build graph | Orphaned (not in main build) | **Add to main build graph** for CI detection |
| Proof approach | Post-condition architecture | **Preserved** -- split does not change proof strategy |
| Phase order | Phase 2 (closure) blocked on build | **Phase 1: split, Phase 2: fix, Phase 3: integrate** |

## Overview

This plan restructures the implementation around a file-splitting-first strategy. The monolithic RecursiveSeed.lean (11,694 lines, ~100 build errors) is split into 5 smaller files organized by responsibility. Each file is fixed independently, integrated into the main build graph, and then proof work continues on the smaller, faster-building files.

The splitting preserves all existing code and proofs. The 5 target files are:

1. **RecursiveSeed/Core.lean** (~2,400 lines) -- Data structures, ModelSeed operations, classification
2. **RecursiveSeed/Builder.lean** (~4,400 lines) -- buildSeedAux, seedConsistent, consistency infrastructure
3. **RecursiveSeed/Worklist.lean** (~1,600 lines) -- WorkItem, WorklistState, processWorkItem, processWorklist
4. **RecursiveSeed/Consistency.lean** (~1,200 lines) -- Worklist consistency proofs (invariant, post-condition)
5. **RecursiveSeed/Closure.lean** (~2,100 lines) -- Closure properties, SeedClosed, Dershowitz-Manna termination

A barrel file `RecursiveSeed.lean` re-exports all submodules for backward compatibility with SeedCompletion.lean.

### Research Integration

From research-008.md:
- **Option B selected**: Split file and incremental rebuild (lower risk, medium effort)
- **Build error categories**: 8 categories totaling ~100 errors, many cascading
- **Sorry inventory**: 12 in RecursiveSeed, 5 in SeedCompletion, 5 in SeedBMCS (22 total)
- **Dershowitz-Manna blocker**: 1 sorry requiring multiset ordering formalization (3-5 hours)
- **Post-condition architecture**: Validated in v006, preserved across split

## Goals & Non-Goals

**Goals**:
- Split RecursiveSeed.lean into 5 smaller files (each under 4,500 lines)
- Fix all ~100 build errors so each file compiles independently
- Add seed pipeline to the main build graph via Bimodal.Metalogic.Metalogic imports
- Preserve all existing proofs and code structure
- Enable incremental proof development in smaller, faster-building files
- Complete closure proofs (resolve termination sorry)
- Derive consistency from closure via post-condition architecture
- Resolve SeedCompletion.lean and SeedBMCS.lean sorries

**Non-Goals**:
- Rewriting the worklist algorithm (preserve existing structure)
- Changing the mathematical approach (post-condition architecture stays)
- Adding new axioms (NEVER)
- Achieving zero sorries in the legacy buildSeedAux path (non-critical)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Internal references break during split | Medium | Medium | Careful namespace management; test each file's build after split |
| Build errors harder than estimated | Medium | Medium | Cascade errors resolve automatically; 8-hour buffer in estimate |
| Circular dependencies between split files | High | Low | Dependency graph designed to be acyclic (Core -> Builder -> Worklist -> Consistency -> Closure) |
| Dershowitz-Manna termination intractable in Lean 4 | Medium | Medium | Accept as sorry with documentation if blocked after 4 hours; mathematical validity established |
| Post-condition consistency approach fails | Medium | Low | Fall back to axiom with documented remediation path |
| SeedCompletion architectural gap (t!=0) | High | Medium | May require redesigning buildFamilyFromSeed to use all seed positions |

## Sorry Characterization

### Pre-existing Sorries (22 total across pipeline)

**RecursiveSeed.lean** (12 sorry tactic occurrences):

| Line | Theorem | Target File | Difficulty | Critical Path? |
|------|---------|-------------|------------|----------------|
| 5984 | `buildSeedForList_consistent_foldl` | Builder.lean | Medium | No (legacy) |
| 6009 | `buildSeedForList_consistent` | Builder.lean | Medium | No (legacy) |
| 6198 | `buildSeedForList_propagates_box` | Builder.lean | Low | No (legacy) |
| 6551 | `buildSeedAux_preserves_hasPosition` (neg) | Builder.lean | Low | No |
| 6556 | `buildSeedAux_preserves_hasPosition` (imp) | Builder.lean | Low | No |
| 7655 | `processWorkItem_preserves_consistent` (boxPositive) | Consistency.lean | Medium | Yes (Phase 6) |
| 7701 | `processWorkItem_preserves_consistent` (futurePositive) | Consistency.lean | Medium | Yes (Phase 6) |
| 7748 | `processWorkItem_preserves_consistent` (pastPositive) | Consistency.lean | Medium | Yes (Phase 6) |
| 8051 | `processWorklistAux_preserves_invariant` (well-formedness) | Consistency.lean | Medium | Yes (Phase 6) |
| 8062 | `processWorklistAux_preserves_invariant` (membership) | Consistency.lean | Medium | Yes (Phase 6) |
| 8068 | `processWorklistAux_preserves_invariant` (new work) | Consistency.lean | Medium | Yes (Phase 6) |
| 11635 | `processWorklistAux_preserves_closure` (termination) | Closure.lean | High | Yes (Phase 5) |

**SeedCompletion.lean** (5 sorries):
- Line 161: `modal_witness_includes_boxcontent` -- needs ModalClosed
- Line 246: `forward_G` cross-sign -- needs GClosed
- Line 256: `backward_H` cross-sign -- needs HClosed
- Line 328: `buildFamilyFromSeed_cross_sign_seed` -- needs G/HClosed
- Line 372: `buildFamilyFromSeed_contains_seed` (t!=0) -- architectural gap

**SeedBMCS.lean** (5 sorries):
- Lines 89, 94: modal coherence -- depends on SeedCompletion
- Lines 180, 188, 199: BMCS construction -- depends on SeedCompletion

### Expected Resolution

- **Phase 1-3**: No sorry changes (structural refactoring only)
- **Phase 4**: Fix build errors, no sorry changes
- **Phase 5**: Resolve 1 termination sorry via Dershowitz-Manna formalization
- **Phase 6**: Resolve 6 consistency sorries via post-condition architecture; 5 legacy sorries remain as technical debt (non-critical path)
- **Phase 7**: Resolve 5 SeedCompletion sorries; resolve 5 SeedBMCS sorries

### New Sorries

- None expected. All phases either refactor or resolve existing sorries.

### Remaining Debt

After full implementation:
- 0 sorries on critical worklist path (RecursiveSeed/Worklist.lean, Closure.lean, Consistency.lean)
- 5 sorries in RecursiveSeed/Builder.lean (legacy buildSeedAux infrastructure, non-critical path)
  - Tolerated during development; remediation priority: low
  - These are in the old recursive builder path, superseded by the worklist algorithm
- 0 sorries in SeedCompletion.lean (blocks publication if unresolved)
- 0 sorries in SeedBMCS.lean

## Axiom Characterization

### Pre-existing Axioms

- None in RecursiveSeed.lean or its dependencies within the seed pipeline.

### Expected Resolution

- N/A -- no axioms to resolve.

### New Axioms

- NEVER. All proofs use standard derivation composition. If proof complexity blocks a sorry, it remains a sorry with documented remediation, not an axiom.

### Remaining Debt

- 0 axioms expected. Publication-ready without axiom disclosure.

## Implementation Phases

### Phase 1: Create RecursiveSeed Directory and Core.lean [COMPLETED]

- **Dependencies:** None
- **Goal:** Extract data structures, ModelSeed operations, and formula classification into Core.lean

**Tasks**:
- [ ] Create directory `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/`
- [ ] Create `Core.lean` with imports from the original file header (lines 1-8)
- [ ] Move `FormulaClass` inductive and `classifyFormula` (lines 75-130)
- [ ] Move `SeedEntryType` inductive (lines 150-155)
- [ ] Move `SeedEntry` structure (lines 174-187)
- [ ] Move `ModelSeed` structure (lines 208-228)
- [ ] Move all `ModelSeed` manipulation functions (lines 232-378):
  - `findEntry`, `getFormulas`, `getEntryType`, `addFormula`, `addToAllFamilies`,
    `addToAllFutureTimes`, `addToAllPastTimes`, `createNewFamily`, `createNewTime`,
    `familyIndices`, `timeIndices`, `hasPosition`, `size`
- [ ] Move `hasPosition` theorems (lines 346-377):
  - `hasPosition_iff_findEntry_isSome`, `findEntry_some_of_hasPosition`, `mem_getFormulas_implies_hasPosition`
- [ ] Move fresh time functions and theorems (lines 390-610):
  - `freshFutureTime`, `freshPastTime`, and all related lemmas
- [ ] Move classification inversion lemmas (lines 1286-1373):
  - `classifyFormula_eq_atomic`, `classifyFormula_eq_bottom`, `classifyFormula_eq_implication`, `classifyFormula_eq_negation`
- [ ] Move `SeedConsistent`, `SeedWellFormed`, `FormulaConsistent` type definitions (lines 1397-1430)
- [ ] Move `ModalClosed`, `GClosed`, `HClosed`, `SeedClosed` definitions (lines 8120-8152)
- [ ] Verify `Core.lean` builds independently with `lake build Bimodal.Metalogic.Bundle.RecursiveSeed.Core`

**Timing:** 1.5 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Core.lean`

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.RecursiveSeed.Core` succeeds
- All moved definitions are accessible
- No sorries in Core.lean (pure definitions)

**Progress:**

**Session: 2026-02-18, sess_1771477072_486361**
- Added: `Core.lean` (758 lines) with data structures, ModelSeed ops, classification, type definitions, closure definitions
- Fixed: Made `classifyFormula_eq_atomic/bottom/implication/negation` non-private for cross-file access
- Completed: Core.lean builds with 0 errors, only warnings

---

### Phase 2: Create Builder.lean [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Extract the original buildSeedAux recursive builder and its consistency proofs

**Tasks**:
- [ ] Create `Builder.lean` importing `RecursiveSeed.Core`
- [ ] Move `buildSeedAux` function (lines 614-681)
- [ ] Move `buildSeed` function and `initial_*` lemmas (lines 681-711)
- [ ] Move family/time index preservation helpers (lines 712-1230):
  - `addFormula_preserves_single_family`, `addToAllFamilies_preserves_single_family`, etc.
  - `addFormula_preserves_single_time`, etc.
  - `buildSeedAux_preserves_familyIndices`
  - `buildSeed_has_family_zero`
- [ ] Move seed builder tests (lines 1233-1285)
- [ ] Move consistency infrastructure (lines 1375-2846):
  - `initialSeedConsistent`, `initialSeedWellFormed`
  - `addFormula_preserves_consistent_of_theorem`
  - `diamond_box_interaction`
  - `SeedConsistentInvariant`
  - `insert_consistent_of_derivable_parent` and corollaries
  - All `addFormula_*_preserves_consistent/wellFormed` theorems
  - `box_consistent_implies_content_consistent` and variants
  - `createNewFamily/createNewTime` formulas/indices lemmas
- [ ] Move membership lemmas section (lines 2848-3037):
  - `addToAllFamilies_preserves_consistent`, `addToAllFamilies_preserves_wellFormed`
  - `addToAllFutureTimes/PastTimes_preserves_wellFormed`
- [ ] Move `addToAllFutureTimes_preserves_seedConsistent_with_gpsi` and past variant (lines 3058-3375)
- [ ] Move `addFormula_formula_in_getFormulas` and membership preservation (lines 3376-3880)
- [ ] Move `createNewFamily_preserves_seedConsistent` (lines 3882-3924)
- [ ] Move `buildSeedAux_preserves_seedConsistent` and `seedConsistent` theorem (lines 3925-4985)
- [ ] Move membership preservation helpers section (lines 4987-5893):
  - All `addFormula/addToAllFamilies/createNewFamily_preserves_mem_getFormulas` lemmas
  - `buildSeedAux_preserves_mem_general`, `buildSeedAux_preserves_getFormulas`
  - `buildSeedAux_adds_formula`
- [ ] Move multi-formula builder and bridge lemmas (lines 5895-6693):
  - `buildSeedForList`, `buildSeedForList_consistent` (contains 2 sorries)
  - `buildSeed_contains_formula`
  - `buildSeedForList_propagates_box` (contains 1 sorry)
  - hasPosition preservation: `addFormula_preserves_hasPosition`, etc. (lines 6265-6563)
  - `buildSeedAux_preserves_hasPosition` (contains 2 sorries)
  - `seedToConstantMCS` and related (lines 6628-6693)
- [ ] Verify `Builder.lean` builds (may have errors from API changes -- note them for Phase 4)

**Timing:** 2 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Builder.lean`

**Verification:**
- File created with correct imports
- Content matches original line ranges
- Build attempted, errors catalogued for Phase 4

---

### Phase 3: Create Worklist.lean, Consistency.lean, and Closure.lean [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Extract worklist algorithm, consistency proofs, and closure proofs into separate files

**Tasks**:

**Worklist.lean** (~1,600 lines):
- [ ] Create `Worklist.lean` importing `RecursiveSeed.Builder`
- [ ] Move worklist data structures (lines 6695-6835):
  - `WorkItem`, `WorklistState`, `getFutureTimes`, `getPastTimes`
  - `WorkItem.complexity`, `totalPendingComplexity`, `terminationMeasure`, `pendingComplexityMultiset`
- [ ] Move `processWorkItem` function (lines 6851-6936)
- [ ] Move formula complexity theorems (lines 6944-6989)
- [ ] Move processWorkItem properties (lines 6990-7332):
  - Pending complexity lemmas
  - `processWorkItem_preserves_processed`
  - `processWorkItem_result_independent`
  - `processWorkItem_newWork_complexity_lt`
  - `processWorkItem_newWork_hasPosition`
  - `processWorkItem_preserves_hasPosition_monotone`
- [ ] Move `processWorklistAux`, `worklistFuelBound`, `processWorklist`, `buildSeedComplete` (lines 7334-7403)

**Consistency.lean** (~1,200 lines):
- [ ] Create `Consistency.lean` importing `RecursiveSeed.Worklist`
- [ ] Move `WorklistInvariant` definition (lines 7436-7444)
- [ ] Move `empty_seed_consistent'` (lines 7445-7457)
- [ ] Move inner consistency lemmas (lines 7458-7592):
  - `box_inner_consistent`, `all_future_inner_consistent`, `all_past_inner_consistent`
  - `neg_box_neg_inner_consistent`, `neg_future_neg_inner_consistent`, `neg_past_neg_inner_consistent`
- [ ] Move `processWorkItem_preserves_consistent` (lines 7593-7801, contains 3 sorries)
- [ ] Move `processWorkItem_newWork_consistent` (lines 7802-8015, contains 3 sorries -- estimated from plan v006)
- [ ] Move `processWorklistAux_preserves_invariant` (lines 8016-8072, contains 3 sorries)
- [ ] Move `processWorklist_preserves_consistent` and `buildSeedComplete_consistent` (lines 8073-8105)

**Closure.lean** (~2,100 lines):
- [ ] Create `Closure.lean` importing `RecursiveSeed.Worklist`
- [ ] Move `WorklistClosureInvariant` and `empty_worklist_closure` (lines 8155-8206)
- [ ] Move `initial_seed_getFormulas_unique` and `initial_closure_invariant` (lines 8207-8433)
- [ ] Move foldl helper lemmas for closure (lines 8434-9029):
  - `foldl_addFormula_fam_creates_position`, `foldl_addFormula_fam_preserves_existing`
  - `foldl_addFormula_times_creates_position`
  - Compound foldl helpers (future/past)
- [ ] Move `processWorkItem_preserves_closure` (lines 9030-11318, all 10 cases proven)
- [ ] Move `WorklistPosInvariant` and `initial_pos_invariant` (lines 11319-11396)
- [ ] Move `FuelSufficient` definition (lines 11397-11402)
- [ ] Move `processWorklistAux_preserves_closure` (lines 11403-11639, contains 1 sorry)
- [ ] Move `buildSeedComplete_closed` and SeedClosed extractors (lines 11640-11693)

**Timing:** 2 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Worklist.lean`
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Consistency.lean`
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Closure.lean`

**Verification:**
- All 3 files created with correct imports
- Content matches original line ranges
- Dependency order: Core -> Builder -> Worklist -> {Consistency, Closure}
- Build attempted, errors catalogued for Phase 4

---

### Phase 4: Fix Build Errors Across All Split Files [PARTIAL]

- **Dependencies:** Phase 1, Phase 2, Phase 3
- **Goal:** Fix ~100 build errors so all 5 files compile successfully

**Tasks**:

**Category 1: API Renames (Low difficulty, ~9 errors)**:
- [ ] Fix `List.getElem?_mem` renamed (~5 errors)
  - Search Mathlib for replacement: likely `List.getElem?_mem` -> `List.mem_of_getElem?_eq_some` or similar
  - Use `lean_loogle` to find the correct current name
- [ ] Fix `Bool.or_eq_true_iff_left_or_right.mpr` unknown (~4 errors)
  - Use `lean_loogle` to find replacement in current Mathlib

**Category 2: Simp Failures (Low-Medium difficulty, ~8 errors)**:
- [ ] Fix `simp` made no progress errors
  - Replace `simp` with `simp only [specific_lemmas]` where needed
  - Some may need `rfl` or `exact` instead

**Category 3: Finset/Set Membership (Low-Medium difficulty, ~15 errors)**:
- [ ] Fix `Finset.mem_singleton` vs `Set.mem_singleton_iff` confusion
  - Audit each usage: determine if Finset or Set context
  - Use `lean_hover_info` to check types at each error site

**Category 4: hasPosition Unfold Failures (Medium difficulty, ~5 errors)**:
- [ ] Fix `ModelSeed.hasPosition` unfold failures
  - Check if definition structure changed during refactoring
  - May need `simp only [ModelSeed.hasPosition]` or `unfold ModelSeed.hasPosition`

**Category 5: Application Type Mismatches (Medium difficulty, ~30 errors)**:
- [ ] Fix type mismatch errors
  - Use `lean_goal` at each error site to see expected vs actual types
  - Many may be cascading from earlier errors

**Category 6: Unknown Identifiers (Medium difficulty, ~10 errors)**:
- [ ] Fix missing identifier errors
  - Check if declarations moved to wrong file during split
  - Check if import is missing
  - Use `lean_local_search` to locate declarations

**Category 7: Cascading Errors (~25 errors)**:
- [ ] After fixing categories 1-6, re-build to see how many cascading errors resolve
- [ ] Fix remaining cascading errors individually

**Build verification per file**:
- [ ] `lake build Bimodal.Metalogic.Bundle.RecursiveSeed.Core` -- 0 errors
- [ ] `lake build Bimodal.Metalogic.Bundle.RecursiveSeed.Builder` -- 0 errors (excluding sorry)
- [ ] `lake build Bimodal.Metalogic.Bundle.RecursiveSeed.Worklist` -- 0 errors
- [ ] `lake build Bimodal.Metalogic.Bundle.RecursiveSeed.Consistency` -- 0 errors (excluding sorry)
- [ ] `lake build Bimodal.Metalogic.Bundle.RecursiveSeed.Closure` -- 0 errors (excluding sorry)

**Strategy note**: Fix files in dependency order (Core first, then Builder, then Worklist, then Consistency and Closure). Fixing earlier files resolves cascading errors in later files.

**Timing:** 6 hours (realistic; 4 optimistic, 8 pessimistic)

**Files to modify:**
- All 5 files under `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/`

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.RecursiveSeed.Closure` succeeds (implies all upstream files build)
- `grep -c "sorry"` counts match expected: 5 in Builder, 6 in Consistency, 1 in Closure
- No new sorries introduced

---

### Phase 5: Create Barrel File and Integrate into Build Graph [PARTIAL]

- **Dependencies:** Phase 4
- **Goal:** Create re-export barrel file and add seed pipeline to the main build graph

**Tasks**:
- [ ] Create barrel file `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (replaces original):
  ```lean
  import Bimodal.Metalogic.Bundle.RecursiveSeed.Core
  import Bimodal.Metalogic.Bundle.RecursiveSeed.Builder
  import Bimodal.Metalogic.Bundle.RecursiveSeed.Worklist
  import Bimodal.Metalogic.Bundle.RecursiveSeed.Consistency
  import Bimodal.Metalogic.Bundle.RecursiveSeed.Closure
  ```
- [ ] Verify SeedCompletion.lean still compiles with the barrel import (it imports `Bimodal.Metalogic.Bundle.RecursiveSeed`)
- [ ] Verify SeedBMCS.lean compiles (imports SeedCompletion.lean)
- [ ] Add import to `Theories/Bimodal/Metalogic/Metalogic.lean`:
  ```lean
  import Bimodal.Metalogic.Bundle.SeedBMCS
  ```
  This adds the entire seed pipeline to the main build graph.
- [ ] Run full `lake build Bimodal` to verify no downstream breakage
- [ ] Verify `grep -rn "sorry" Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/` shows expected count

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (replace with barrel file)
- `Theories/Bimodal/Metalogic/Metalogic.lean` (add import)

**Files to verify:**
- `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean`
- `Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean`

**Verification:**
- `lake build Bimodal` succeeds
- SeedCompletion.lean builds (with its existing 5 sorries)
- SeedBMCS.lean builds (with its existing 5 sorries)
- Future API changes will be caught by CI

---

### Phase 6: Complete Closure and Consistency Proofs [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Resolve the Dershowitz-Manna termination sorry in Closure.lean; derive consistency from closure in Consistency.lean

**Tasks**:

**6a: Dershowitz-Manna Termination (Closure.lean)**:
- [ ] Formalize `pendingComplexityMultiset` decrease under DM ordering
  - Key fact: processing one item removes it (complexity c) and adds items of complexity < c
  - This is exactly the Dershowitz-Manna criterion: multiset decreases when one element is replaced by finitely many smaller elements
- [ ] Use Mathlib's `Multiset.instWellFoundedRelation` or `WellFounded.lt` infrastructure
  - Check `import Mathlib.Data.Multiset.DershowitzManna` (already imported)
  - Use `lean_loogle` for `Multiset` well-founded ordering lemmas
- [ ] Prove `processWorklistAux_preserves_closure` fuel=0 case (currently line ~11635)
  - If formalization proves intractable after 4 hours: document as technical debt with sorry, proceed to Phase 6b
  - Remediation priority: medium (algorithm provably terminates; formalization is the gap)

**6b: Post-Condition Consistency (Consistency.lean)**:
- [ ] Define `FormulaConsistent_Weak` (weaker invariant for worklist processing)
- [ ] Prove `closed_seed_implies_consistent`:
  ```lean
  theorem closed_seed_implies_consistent (seed : ModelSeed)
      (h_closed : SeedClosed seed)
      (h_formula_cons : FormulaConsistent phi) :
      SeedConsistent seed
  ```
  - Uses `insert_consistent_of_derivable_parent` corollaries (proven in Builder.lean)
  - For each position: if Box psi present, psi also there (ModalClosed) -> consistent by derivation
  - Similarly for G/H using GClosed/HClosed
- [ ] Prove `buildSeedComplete_consistent` using closure + post-condition:
  ```lean
  theorem buildSeedComplete_consistent (phi : Formula) (h_cons : FormulaConsistent phi) :
      SeedConsistent (buildSeedComplete phi)
  ```
- [ ] Remove or deprecate old `processWorkItem_preserves_consistent` sorries (6 sorries eliminated)
- [ ] Resolve `processWorklistAux_preserves_invariant` sorries (3 sorries eliminated)

**Timing:** 5 hours (2 hours termination, 3 hours consistency)

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Closure.lean`
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Consistency.lean`

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.RecursiveSeed.Closure` -- 0 sorries (or 1 if termination deferred)
- `lake build Bimodal.Metalogic.Bundle.RecursiveSeed.Consistency` -- 0 critical-path sorries
- `#check buildSeedComplete_consistent` shows correct type

---

### Phase 7: SeedCompletion and SeedBMCS Integration [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Resolve 5 sorries in SeedCompletion.lean and 5 sorries in SeedBMCS.lean

**Tasks**:

**7a: SeedCompletion.lean**:
- [ ] Resolve `modal_witness_includes_boxcontent` (line 161):
  - Use ModalClosed from `buildSeedComplete_modalClosed`
  - If Box phi in parent MCS, then phi is in all families by ModalClosed -> phi in witness MCS
- [ ] Resolve `forward_G` cross-sign case (line 246):
  - Use GClosed: if G phi in seed at time t < 0, phi is at all seed times with greater t
  - Since seed places phi at time 0 (via GClosed), dovetailing chain propagates from there
- [ ] Resolve `backward_H` cross-sign case (line 256):
  - Symmetric to forward_G using HClosed
- [ ] Resolve `buildFamilyFromSeed_cross_sign_seed` (line 328):
  - Follows from GClosed + seed temporal propagation
- [ ] Resolve `buildFamilyFromSeed_contains_seed` for t!=0 (line 372):
  - **Architectural gap**: Current construction uses only time-0 seed as base
  - **Strategy A**: Prove that all seed formulas at non-zero times also appear at time 0 (via addToAllFutureTimes/addToAllPastTimes propagation)
  - **Strategy B**: Redesign `buildFamilyFromSeed` to incorporate seed entries at ALL times, not just time 0
  - Evaluate both; prefer Strategy A if feasible

**7b: SeedBMCS.lean**:
- [ ] Resolve `modal_forward` sorry (line 89):
  - Use ModalClosed + seedFamilyMCS_contains_seed
- [ ] Resolve `modal_backward` sorry (line 94):
  - Use MCS saturation: neg(Box phi) would create witness family contradicting modal coherence
- [ ] Resolve `construct_seed_bmcs` sorry (line 180):
  - Implement using `buildSeedComplete` + `buildFamilyFromSeed`
- [ ] Resolve `construct_seed_bmcs_contains_context` sorry (line 188):
  - Use `buildSeed_contains_formula` + `seedFamilyMCS_contains_seed`
- [ ] Resolve `construct_seed_bmcs_temporally_coherent` sorry (line 199):
  - Follows from IndexedMCSFamily structure (forward_G, backward_H fields)

**Timing:** 4 hours (2.5 SeedCompletion, 1.5 SeedBMCS)

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean`
- `Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean`

**Verification:**
- `grep -c "sorry" SeedCompletion.lean` returns 0
- `grep -c "sorry" SeedBMCS.lean` returns 0
- `lake build Bimodal.Metalogic.Bundle.SeedBMCS` succeeds
- Full build: `lake build Bimodal` succeeds

---

### Phase 8: Final Verification and Summary [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Verify publication-ready status and create implementation summary

**Tasks**:
- [ ] Run `lake build Bimodal` -- full project build
- [ ] Count sorries across seed pipeline:
  - `grep -rn "sorry" Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/`
  - `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean`
  - `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean`
- [ ] Verify no axioms: `grep -rn "axiom" Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/`
- [ ] Run `lean_verify` on key theorems:
  - `buildSeedComplete_closed`
  - `buildSeedComplete_consistent`
  - `seedBMCS_modal_forward`
  - `seedBMCS_temporally_coherent`
- [ ] Create implementation summary at `specs/864_recursive_seed_henkin_model/summaries/implementation-summary-YYYYMMDD.md`
- [ ] Update plan status markers to [COMPLETED]

**Timing:** 0.5 hours

**Files to create:**
- `specs/864_recursive_seed_henkin_model/summaries/implementation-summary-YYYYMMDD.md`

**Verification:**
- Zero sorries on critical path
- Zero axioms
- Full build succeeds
- All verification checks pass

---

## Testing & Validation

- [ ] `lake build Bimodal` succeeds (full project)
- [ ] Each RecursiveSeed submodule builds independently
- [ ] SeedCompletion.lean builds with 0 sorries
- [ ] SeedBMCS.lean builds with 0 sorries
- [ ] `lean_verify` passes on `buildSeedComplete_closed`
- [ ] `lean_verify` passes on `buildSeedComplete_consistent`
- [ ] No axioms in seed pipeline
- [ ] RecursiveSeed.lean barrel file re-exports all submodules correctly

## Artifacts & Outputs

- `specs/864_recursive_seed_henkin_model/plans/implementation-007.md` (this file)
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Core.lean` (new)
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Builder.lean` (new)
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Worklist.lean` (new)
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Consistency.lean` (new)
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Closure.lean` (new)
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (replaced with barrel file)
- Modified `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean`
- Modified `Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean`
- Modified `Theories/Bimodal/Metalogic/Metalogic.lean`
- `specs/864_recursive_seed_henkin_model/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

The file split is non-destructive:

1. **If split breaks things**: The original RecursiveSeed.lean is preserved in git history. `git checkout HEAD -- Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` restores it.

2. **If build errors prove intractable**: Focus on Core.lean and Worklist.lean (most important for forward progress). Accept sorries in Builder.lean (legacy path).

3. **If Dershowitz-Manna is too hard**: Accept the 1 sorry with documentation. The algorithm provably terminates (mathematical fact); only the Lean 4 formalization is blocked. Remediation priority: medium.

4. **If post-condition consistency fails**: Fall back to the old loop invariant approach (which worked for the original architecture) or accept axiom with documented remediation path.

5. **If SeedCompletion t!=0 gap is architectural**: Redesign `buildFamilyFromSeed` to use all seed entries, not just time 0. This is a moderate change (~2-3 hours) that can be done as a follow-up task.
