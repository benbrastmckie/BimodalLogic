# Implementation Plan: Clarify CanonicalMCS Role

- **Task**: 1009 - clarify_canonicalmcs_role
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/1009_clarify_canonicalmcs_role/reports/01_canonicalmcs-role-audit.md
- **Artifacts**: plans/02_clarification-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan updates comments, docstrings, and documentation to clarify that CanonicalMCS is the **world-state space** (set of all maximal consistent sets), NOT the temporal domain D required by TaskFrame. The confusion stems from overloaded use of type parameter name `D` and FMCSDef.lean's "time" language predating the CanonicalFMCS construction.

All changes are comment/docstring-only. No code changes. Build must pass after each phase.

### Research Integration

From the research audit (01_canonicalmcs-role-audit.md):
- **High priority files (6)**: FMCSDef.lean, CanonicalFMCS.lean, DenseCompleteness.lean, MultiFamilyBFMCS.lean, ROAD_MAP.md, StagedConstruction/Completeness.lean
- **Medium priority files (5)**: CanonicalFMCS.lean (additional lines), SaturatedBFMCSConstruction.lean, WitnessFamilyBundle.lean, ChainFMCS.lean, LogicVariants.lean
- **Model clarification statement** established for consistent terminology

## Goals & Non-Goals

**Goals**:
- Clarify that CanonicalMCS is the world-state space, not a temporal domain
- Distinguish FMCS indexing domain from TaskFrame temporal domain D
- Use consistent terminology: "world-state index" instead of "time point" when D = CanonicalMCS
- Preserve build passing after each phase

**Non-Goals**:
- Rename type parameters (would break code)
- Update Boneyard files (archived/deprecated)
- Update archived spec reports (historical artifacts)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Comment syntax errors break build | Medium | Low | Run `lake build` after each file edit |
| Inconsistent terminology across phases | Low | Medium | Use model clarification statement template |
| Missing some occurrences | Low | Medium | Research audit provides comprehensive line numbers |

## Implementation Phases

### Phase 1: FMCSDef.lean Core Clarification [NOT STARTED]

**Goal**: Add clarifying note to the foundational FMCS definition module that distinguishes when D is a temporal type vs. when D = CanonicalMCS.

**Tasks**:
- [ ] Add module-level clarification note after the existing docstring (lines 9-10)
- [ ] Update "time point" language at line 20 to include qualification
- [ ] Update "Duration/time type" at line 63 to include semantic distinction

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` - Add clarifying note, update terminology

**Verification**:
- `lake build` passes
- Comments clearly state: "When D is a temporal type (Int, Rat, TimelineQuot), indices are time points. When D = CanonicalMCS, indices are world states."

---

### Phase 2: CanonicalFMCS.lean Terminology [NOT STARTED]

**Goal**: Clarify all "domain" uses in the canonical FMCS construction file.

**Tasks**:
- [ ] Line 19: Change "domain" to "FMCS indexing domain (world-state space)"
- [ ] Line 70: Change "domain element" to "world-state index element"
- [ ] Line 177: Add clarification that indexing is by world states, not time points
- [ ] Line 280: Clarify that `FMCS CanonicalMCS` means "family indexed by world states"
- [ ] Line 286: Change "D = CanonicalMCS" to "FMCS indexing type = CanonicalMCS"

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` - Update 5 comment locations

**Verification**:
- `lake build` passes
- No "domain" used ambiguously (should say "FMCS indexing domain" or "world-state space")

---

### Phase 3: DenseCompleteness.lean and StagedConstruction/Completeness.lean [NOT STARTED]

**Goal**: Fix the most confusing phrases about CanonicalMCS as "times".

**Tasks**:
- [ ] DenseCompleteness.lean line 39: Change "(all MCSs as times)" to "(all MCSes as world-state indices)"
- [ ] DenseCompleteness.lean line 43: Clarify parenthetical "(or CanonicalMCS)" - they serve different roles
- [ ] DenseCompleteness.lean line 116: Change "domain" to "indexing type"
- [ ] DenseCompleteness.lean line 138: Clarify the mismatch is between indexing type vs temporal domain
- [ ] StagedConstruction/Completeness.lean line 116: Change "D = CanonicalMCS (the all-MCS domain)" to "FMCS indexed by CanonicalMCS (the world-state space)"

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - Update 4 comment locations
- `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean` - Update 1 comment location

**Verification**:
- `lake build` passes
- No "MCSs as times" language remains

---

### Phase 4: MultiFamilyBFMCS.lean Terminology [NOT STARTED]

**Goal**: Fix "time point" and "domain" terminology in the multi-family construction.

**Tasks**:
- [ ] Line 69: Change "domain is ALL canonical MCS" to "indexing type is CanonicalMCS (all world states)"
- [ ] Line 83: Change "CanonicalMCS domain" to "CanonicalMCS indexing type"
- [ ] Line 94: Change "each time point is a CanonicalMCS element" to "each index is a CanonicalMCS element (a world state)"
- [ ] Line 313: Change "common domain" to "common indexing type"
- [ ] Line 384: Change "domain (CanonicalMCS)" to "indexing type (CanonicalMCS)"
- [ ] Line 387: Change "time t : CanonicalMCS" to "index w : CanonicalMCS (world state)"

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean` - Update 6 comment locations

**Verification**:
- `lake build` passes
- Variable names `t` in comments clarified as world-state indices, not time points

---

### Phase 5: ROAD_MAP.md Documentation [NOT STARTED]

**Goal**: Clarify the central conflation in the roadmap documentation.

**Tasks**:
- [ ] Line 182: Change "the BFMCS uses D = CanonicalMCS while the TaskFrame semantics uses D = TimelineQuot" to clarify these are different type parameters
- [ ] Line 209: Clarify that BFMCS D and TaskFrame D are different roles
- [ ] Line 215: Change "domain mismatch" to "type parameter mismatch (indexing domain vs temporal domain)"
- [ ] Line 957: Change "at time t" to "at index t" when t : CanonicalMCS
- [ ] Line 1258: Clarify "D=CanonicalMCS" notation

**Timing**: 20 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Update 5 documentation locations

**Verification**:
- Documentation clearly distinguishes BFMCS indexing parameter from TaskFrame temporal parameter

---

### Phase 6: Medium Priority Files Cleanup [NOT STARTED]

**Goal**: Update remaining medium-priority files for consistency.

**Tasks**:
- [ ] SaturatedBFMCSConstruction.lean lines 202, 227: Clarify "domain" usage
- [ ] WitnessFamilyBundle.lean line 153: Clarify "domain" usage
- [ ] ChainFMCS.lean line 532: Clarify "domain" usage
- [ ] LogicVariants.lean lines 142-153: Add note about variable naming convention for CanonicalMCS elements

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedBFMCSConstruction.lean` - 2 updates
- `Theories/Bimodal/Metalogic/Bundle/WitnessFamilyBundle.lean` - 1 update
- `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean` - 1 update
- `Theories/Bimodal/LogicVariants.lean` - 1 update

**Verification**:
- `lake build` passes
- All active Lean files use consistent terminology

---

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] No "all MCSs as times" language remains in active files
- [ ] All "domain" uses are qualified as "FMCS indexing domain" or "temporal domain"
- [ ] Variable names like `t : CanonicalMCS` are clarified as world-state indices in nearby comments
- [ ] ROAD_MAP.md clearly distinguishes the two different uses of type parameter `D`

## Artifacts & Outputs

- plans/02_clarification-plan.md (this file)
- summaries/03_clarification-summary.md (post-implementation)

## Rollback/Contingency

All changes are comments/docstrings only. If any phase breaks the build:
1. Revert the specific file change with `git checkout -- <file>`
2. Re-examine comment syntax (ensure proper Lean comment markers)
3. Retry with corrected syntax

Since no code changes are made, rollback is trivial.
