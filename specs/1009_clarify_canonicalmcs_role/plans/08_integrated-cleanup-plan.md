# Implementation Plan: CanonicalMCS Role Cleanup (Integrated)

- **Task**: 1009 - clarify_canonicalmcs_role
- **Version**: 4 (integrated from plans 02, 04, 06)
- **Status**: [COMPLETED]
- **Effort**: 6-8 hours
- **Dependencies**: None
- **Type**: lean4
- **Lean Intent**: true

## Overview

This integrated plan combines:
- **Documentation cleanup** (plans 02, 04): Remove all "D = CanonicalMCS" notation
- **Architecture cleanup** (plan 06): Archive mistaken FMCS CanonicalMCS constructions

**Key simplification**: Since FMCS indexed by CanonicalMCS should **never happen**, we don't need replacement terminology like "world-state index" or "FMCS indexed by CanonicalMCS". We simply:
1. Archive the mistaken constructions
2. Remove all "D = CanonicalMCS" references from documentation
3. Clarify that FMCS's D parameter should be a temporal type (Int, Rat, TimelineQuot)

## Goals

1. **Archive** all `FMCS CanonicalMCS` constructions to Boneyard
2. **Remove** all "D = CanonicalMCS" notation from active comments and documentation
3. **Clarify** that D in FMCS should be temporal (not world states)
4. **Update** ROAD_MAP.md to document this architectural decision
5. **Ensure** `lake build` passes throughout

## Non-Goals

- Providing migration path (constructions are being archived)
- Creating replacement terminology for "D = CanonicalMCS" (shouldn't exist)
- Updating Boneyard files or archived spec reports

## Implementation Phases

### Phase 1: Dependency Audit [COMPLETED]

**Actual findings** (2026-03-20):
Based on research report 05 and code analysis:
- `CanonicalFMCS.lean` is **core infrastructure** with 20+ dependent files
- The `canonicalMCSBFMCS` construction is **legitimate but degenerate**
- It serves a critical purpose: trivializing F/P witness obligations for TruthLemma
- **Decision**: Do NOT archive CanonicalFMCS.lean or its dependents
- **Reinterpretation**: Phases 2-4 are SKIPPED; only documentation cleanup (Phases 5-6) is needed

**Goal**: Map all files that define or use FMCS CanonicalMCS patterns.

**Tasks**:
- [ ] `grep -r "FMCS CanonicalMCS\|canonicalMCSBFMCS\|canonicalMCS_mcs" Theories/`
- [ ] Map import dependencies
- [ ] Identify what depends on these constructions
- [ ] Create list of files to archive vs. files to update

**Timing**: 45 minutes

**Key files to examine**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean`

**Output**: Dependency report with archival/update classification

---

### Phase 2: Extract Reusable Components [SKIPPED]

**Reason**: Based on Phase 1 findings, CanonicalFMCS.lean is core infrastructure that should
not be archived. All components are already properly organized. No extraction needed.

**Goal**: Before archiving, extract lemmas that are correct and don't depend on FMCS CanonicalMCS.

**Tasks**:
- [ ] Identify pure `SetMaximalConsistent` lemmas
- [ ] Identify pure `CanonicalR` lemmas (accessibility relation)
- [ ] Identify `canonical_forward_F` and `canonical_backward_P` if salvageable
- [ ] Extract to appropriate locations (MCS.lean or similar)
- [ ] Verify extracted components build independently

**Timing**: 1.5 hours

**Verification**: `lake build` passes after extraction

---

### Phase 3: Archive CanonicalFMCS.lean [SKIPPED]

**Reason**: Research report 05 explicitly states: "Should FMCS CanonicalMCS Be Eliminated? **No**"
The construction is legitimate and serves a critical role in the completeness proof pipeline.
Archiving would break 20+ files that depend on this infrastructure.

**Goal**: Move the primary FMCS CanonicalMCS construction to Boneyard.

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/Task1009_CanonicalFMCS/`
- [ ] Move `CanonicalFMCS.lean` to Boneyard
- [ ] Add README.md:
  ```markdown
  # CanonicalFMCS Archive

  **Archived**: 2026-03-21
  **Task**: 1009
  **Reason**: FMCS should never be indexed by CanonicalMCS. CanonicalMCS is
  the world-state space, not a temporal domain. This construction used a
  degenerate identity mapping (mcs(w) = w.world) which is architecturally
  incorrect.
  ```
- [ ] Remove import from `Metalogic.lean`

**Timing**: 45 minutes

**Verification**: `lake build` (with expected downstream breakage)

---

### Phase 4: Archive Dependent Constructions [SKIPPED]

**Reason**: No constructions need archiving. The issue is documentation/naming confusion,
not architectural mistakes. All existing code is legitimate.

**Goal**: Archive all code that depends on FMCS CanonicalMCS.

**Tasks**:
- [ ] Archive each file identified in Phase 1 dependency audit
- [ ] Create Boneyard subdirectory with README for each
- [ ] Update imports throughout codebase
- [ ] Fix any remaining broken references

**Timing**: 1.5 hours

**Verification**: `lake build` passes

---

### Phase 5: Update Comments (FMCSDef.lean) [COMPLETED]

**Changes made**:
1. Added "FMCS Indexing Type (Task 1009)" section to FMCSDef.lean module doc
2. Clarified that D should be temporal domain (Int, TimelineQuot, Rat, etc.)
3. Explained FMCS CanonicalMCS as proof-theoretic special case
4. Added key distinction table between FMCS CanonicalMCS and TaskFrame D
5. Added Architectural Note to CanonicalFMCS.lean with role clarification
6. Fixed "D = CanonicalMCS" notation in CanonicalFMCS.lean line 286

**Goal**: Clarify that FMCS's D should be a temporal domain, not world states.

**Tasks**:
- [ ] Add module-level note:
  ```lean
  /-!
  ## FMCS Indexing Type

  The type parameter `D` in `FMCS D` should be a **temporal domain** such as
  `Int`, `Rat`, or `TimelineQuot`. The structure `mcs : D → Set Formula` maps
  each time point to the world state (MCS) at that time.

  **Important**: `D` should NOT be `CanonicalMCS` (the world-state space).
  Using world states as indices creates a degenerate identity mapping
  (mcs(w) = w.world) that conflates the index type with the codomain.
  -/
  ```
- [ ] Update "time point" references to clarify D is temporal
- [ ] Remove any suggestion that D could be CanonicalMCS

**Timing**: 30 minutes

**Verification**: `lake build` passes

---

### Phase 6: Update ROAD_MAP.md and Documentation [COMPLETED]

**Changes made**:
1. Updated ROAD_MAP.md line 182: Clarified "BFMCS uses CanonicalMCS as its indexing type"
2. Updated ROAD_MAP.md line 209: Clarified "(proof-theoretic: every MCS is in the domain)"
3. Updated StagedConstruction/Completeness.lean line 116: Clarified indexing type vs temporal domain
4. Updated DenseCompleteness.lean line 39: Changed "all MCSs as times" to "indexing" terminology

**Verification**:
- `grep -r "D = CanonicalMCS" Theories/` returns 0 matches
- `grep -r "D = CanonicalMCS" specs/ROAD_MAP.md` returns 0 matches

**Goal**: Remove all "D = CanonicalMCS" references and document the decision.

**Tasks**:
- [ ] Find all "D = CanonicalMCS" in ROAD_MAP.md (lines 182, 209, 1258)
- [ ] Replace with correct statements (e.g., "BFMCS construction was incorrectly indexed by CanonicalMCS; now archived")
- [ ] Add architectural decision entry explaining the removal
- [ ] Update DenseCompleteness.lean comments (line 39 "MCSs as times")
- [ ] Update StagedConstruction/Completeness.lean comments (line 116)
- [ ] Remove "D = CanonicalMCS" from any active Lean file comments

**Timing**: 1 hour

**Verification**:
- `grep -r "D = CanonicalMCS" Theories/` returns 0 matches
- `grep -r "D = CanonicalMCS" specs/ROAD_MAP.md` returns 0 matches

---

### Phase 7: Final Verification [COMPLETED]

**Results**:
- `lake build` passes (1024 jobs completed successfully)
- No new sorries introduced in modified files
- Axiom count unchanged at 11
- All "D = CanonicalMCS" references removed from active code/docs
- Build warnings are pre-existing (Examples, Validity.lean)

**Goal**: Ensure codebase is clean and builds.

**Tasks**:
- [ ] Run full `lake build`
- [ ] Verify no new sorries introduced
- [ ] Verify archived constructions are in Boneyard with READMEs
- [ ] Verify no "D = CanonicalMCS" in active code/docs
- [ ] Create implementation summary

**Timing**: 45 minutes

**Verification**:
- `lake build` passes
- All archival complete
- No residual references

---

## Summary of Changes

### Files to Archive (move to Boneyard)
- `CanonicalFMCS.lean` (primary construction)
- Dependent files identified in Phase 1

### Files to Update (comments only)
- `FMCSDef.lean` - Add clarification about D being temporal
- `ROAD_MAP.md` - Remove "D = CanonicalMCS" references
- `DenseCompleteness.lean` - Remove "MCSs as times"
- `StagedConstruction/Completeness.lean` - Update completeness gap description

### Components to Extract (if possible)
- Pure MCS lemmas
- Pure CanonicalR lemmas
- Witness lemmas (canonical_forward_F, canonical_backward_P) if not tied to FMCS indexing

## Rollback/Contingency

If archival breaks critical infrastructure:
1. `git checkout` to recover files
2. Reassess what truly depends on the construction
3. Consider keeping construction in Boneyard-accessible form
