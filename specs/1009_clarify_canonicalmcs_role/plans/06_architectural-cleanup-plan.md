# Implementation Plan: Remove FMCS CanonicalMCS Architecture

- **Task**: 1009 - clarify_canonicalmcs_role
- **Version**: 3 (major scope expansion)
- **Status**: [NOT STARTED]
- **Effort**: 8-12 hours
- **Dependencies**: None
- **Type**: lean4
- **Lean Intent**: true

## Scope Change

**Previous scope**: Documentation clarification (update comments to distinguish "FMCS indexed by CanonicalMCS" from TaskFrame temporal domain)

**New scope**: **Remove all FMCS CanonicalMCS constructions** — archiving the incorrect architectural pattern where CanonicalMCS (world states) is used as if it were a time domain.

**User directive**: "Remove all trivial indexing where FMCS is indexed by CanonicalMCS. This should never happen since that uses the CanonicalMCS as if it were a time domain instead of a world state domain. Fix this everywhere, archiving any incorrect constructions of this kind."

## Overview

The `FMCS CanonicalMCS` construction uses the degenerate identity mapping `mcs(w) = w.world`. While mathematically valid as a proof trick, it creates architectural confusion by treating world states (CanonicalMCS) as if they were temporal indices. This plan removes these constructions and archives them to Boneyard.

## Goals & Non-Goals

**Goals**:
- Identify all files where `FMCS CanonicalMCS` or similar patterns exist
- Archive these files/constructions to Boneyard
- Update imports and dependencies to remove references
- Ensure `lake build` passes after cleanup
- Document the archival decision in ROAD_MAP.md

**Non-Goals**:
- Preserving backwards compatibility with FMCS CanonicalMCS
- Providing migration path (constructions are being archived, not refactored)

## Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking TruthLemma proof | High | High | Identify alternative proof path before archiving |
| Breaking completeness pipeline | High | High | Verify what depends on archived code |
| Build failures | Medium | High | Run `lake build` after each phase |
| Losing correct lemmas | Medium | Medium | Extract reusable components before archiving |

**CRITICAL**: Phase 1 must audit dependencies before any archiving begins.

## Implementation Phases

### Phase 1: Dependency Audit [NOT STARTED]

**Goal**: Identify all files that define or use `FMCS CanonicalMCS` patterns, and map their dependencies.

**Tasks**:
- [ ] Grep for `FMCS CanonicalMCS` in all active Lean files
- [ ] Grep for `canonicalMCSBFMCS`, `canonicalMCS_mcs`, and related constructions
- [ ] Map import dependencies from these files
- [ ] Identify what completeness theorems depend on these constructions
- [ ] Create dependency graph showing impact of archival

**Timing**: 1.5 hours

**Files to examine**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` - Primary construction
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` - May use CanonicalMCS
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean` - Uses CanonicalMCS
- `Theories/Bimodal/Metalogic/StagedConstruction/*.lean` - Completeness pipeline
- `Theories/Bimodal/Metalogic/Algebraic/*.lean` - Algebraic constructions

**Verification**:
- Dependency graph documented
- Impact assessment complete

---

### Phase 2: Extract Reusable Components [NOT STARTED]

**Goal**: Before archiving, extract any lemmas/theorems that are correct and reusable in a different context.

**Tasks**:
- [ ] Identify lemmas about `SetMaximalConsistent` that don't depend on FMCS indexing
- [ ] Identify lemmas about `CanonicalR` that are pure accessibility relations
- [ ] Extract these to appropriate locations (e.g., `MCS.lean`, `CanonicalAccessibility.lean`)
- [ ] Verify extracted components build independently

**Timing**: 2 hours

**Extraction candidates**:
- `canonical_forward_F`, `canonical_backward_P` (if they don't require FMCS CanonicalMCS)
- Pure MCS theorems about consistency and maximality
- CanonicalR properties not tied to FMCS structure

**Verification**:
- `lake build` passes
- Extracted components don't reference archived patterns

---

### Phase 3: Archive CanonicalFMCS.lean [NOT STARTED]

**Goal**: Move the primary FMCS CanonicalMCS construction to Boneyard.

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/Task1009_CanonicalFMCS/` directory
- [ ] Move `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` to Boneyard
- [ ] Create README.md explaining why archived:
  ```markdown
  # CanonicalFMCS Archive

  **Archived**: 2026-03-21
  **Reason**: Task 1009 - Removes FMCS indexed by CanonicalMCS pattern.
  CanonicalMCS is the world-state space, not a temporal domain. Using it as
  FMCS indexing type creates architectural confusion and degenerate
  identity mappings (mcs(w) = w.world).

  **Alternative**: Use proper temporal domain (Int, Rat, TimelineQuot) for FMCS.
  ```
- [ ] Update `Theories/Bimodal/Metalogic/Metalogic.lean` to remove import

**Timing**: 1 hour

**Verification**:
- File moved to Boneyard
- Import removed from Metalogic.lean
- `lake build` passes (with expected downstream breakage)

---

### Phase 4: Archive Dependent Constructions [NOT STARTED]

**Goal**: Archive all files that depend on `FMCS CanonicalMCS` and cannot be salvaged.

**Tasks**:
- [ ] Archive each dependent file identified in Phase 1
- [ ] Create Boneyard subdirectories as needed
- [ ] Add README.md to each archived directory
- [ ] Update imports throughout `Theories/Bimodal/Metalogic/`

**Timing**: 2 hours

**Likely archival candidates** (to be confirmed in Phase 1):
- Parts of `MultiFamilyBFMCS.lean` using CanonicalMCS domain
- CanonicalMCS-based constructions in `StagedConstruction/`
- Any `BFMCS CanonicalMCS` instances

**Verification**:
- All CanonicalMCS-indexed constructions removed from active codebase
- `lake build` passes

---

### Phase 5: Update Documentation [NOT STARTED]

**Goal**: Update ROAD_MAP.md and other documentation to reflect the architectural decision.

**Tasks**:
- [ ] Update ROAD_MAP.md to document the removal
- [ ] Remove "D = CanonicalMCS" references from active documentation
- [ ] Add explanation of why FMCS should only be indexed by temporal types
- [ ] Update FMCSDef.lean docstring to require temporal semantics for D

**Timing**: 1 hour

**Files to modify**:
- `specs/ROAD_MAP.md`
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` (docstring)
- Any other files with "D = CanonicalMCS" language

**Verification**:
- `grep -r "D = CanonicalMCS" Theories/` returns 0 matches
- ROAD_MAP.md explains the architectural decision

---

### Phase 6: Verify Clean Build [NOT STARTED]

**Goal**: Ensure the codebase builds cleanly without FMCS CanonicalMCS patterns.

**Tasks**:
- [ ] Run `lake build` on full codebase
- [ ] Fix any remaining broken imports
- [ ] Verify no sorry was introduced as workaround
- [ ] Document any lost functionality in summary

**Timing**: 1.5 hours

**Verification**:
- `lake build` succeeds
- No new sorries
- Archived file list documented

---

## Testing & Validation

After all phases:
- [ ] `lake build` passes
- [ ] `grep -r "FMCS CanonicalMCS" Theories/` returns 0 matches (in active files)
- [ ] `grep -r "canonicalMCSBFMCS" Theories/` returns 0 matches (in active files)
- [ ] All CanonicalMCS-indexed FMCS constructions in Boneyard
- [ ] ROAD_MAP.md documents the decision

## Artifacts & Outputs

- plans/06_architectural-cleanup-plan.md (this file)
- summaries/07_cleanup-summary.md (post-implementation)
- Boneyard directories with README.md files

## Rollback/Contingency

If archival breaks critical functionality:
1. Recover files with `git checkout -- <file>`
2. Reassess dependency graph
3. Consider partial archival or extended extraction phase

## Impact Assessment

**What we lose**:
- TruthLemma proven via FMCS CanonicalMCS (will need alternative approach)
- Sorry-free forward_F/backward_P for CanonicalMCS domain
- Completeness infrastructure built on this pattern

**What we gain**:
- Clean architecture where FMCS D means D is a temporal domain
- No confusion between world states and time indices
- Clear path forward for completeness proof with proper semantics

## Alternative Approaches Considered

1. **Keep and document**: Previously recommended, but user rejects this approach
2. **Rename to WorldStateFMCS**: Would preserve construction but still creates confusion
3. **Full removal**: User's chosen approach — removes architectural confusion entirely
