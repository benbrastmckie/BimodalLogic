# Implementation Plan: Clarify CanonicalMCS Role (Revised)

- **Task**: 1009 - clarify_canonicalmcs_role
- **Version**: 2 (revised after additional research)
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/1009_clarify_canonicalmcs_role/reports/01_canonicalmcs-role-audit.md
  - specs/1009_clarify_canonicalmcs_role/reports/03_d-equals-canonicalmcs-audit.md (NEW)
- **Type**: lean4
- **Lean Intent**: true

## Overview

This revised plan incorporates user feedback that **"D = CanonicalMCS" is categorically wrong** and should never appear in documentation or comments. The notation creates a fundamental confusion because:

- `D` in `TaskFrame D` = **durations** (requires AddCommGroup + LinearOrder + IsOrderedAddMonoid)
- `CanonicalMCS` = **world states** (has only Preorder, no group structure)

These are completely different constructions. Writing "D = CanonicalMCS" falsely implies CanonicalMCS could serve as a temporal domain, which is impossible.

### Key Terminology Change

| WRONG | CORRECT |
|-------|---------|
| `D = CanonicalMCS` | `FMCS indexed by CanonicalMCS` |
| `D = CanonicalMCS` | `W = CanonicalMCS` (world-state space) |
| "the all-MCS domain" | "the world-state space" |
| "time t : CanonicalMCS" | "world state w : CanonicalMCS" |

### Correct Model (from SeparatedTaskFrame.lean)

```lean
-- D = TimelineQuot (temporal domain), W = CanonicalMCS (world-state space)
```

## Goals & Non-Goals

**Goals**:
- Eliminate all instances of "D = CanonicalMCS" from active code and documentation
- Use "FMCS indexed by CanonicalMCS" or "W = CanonicalMCS" consistently
- Add clarifying comments distinguishing FMCS indexing type from TaskFrame temporal domain
- Preserve build passing after each phase

**Non-Goals**:
- Rename type parameters in code (would break API)
- Update Boneyard files (archived/deprecated)
- Update archived spec reports (historical artifacts)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Comment syntax errors break build | Medium | Low | Run `lake build` after each file edit |
| Missing some occurrences | Low | Low | New audit (03_d-equals-canonicalmcs-audit.md) is comprehensive |

## Implementation Phases

### Phase 1: Core Clarification in FMCSDef.lean [NOT STARTED]

**Goal**: Add foundational clarification that FMCS's type parameter D is an indexing type, NOT the TaskFrame temporal domain. This is the root of the confusion.

**Tasks**:
- [ ] Add module-level clarification block after docstring:
  ```lean
  /-!
  ## Important: FMCS Indexing vs TaskFrame Temporal Domain

  The type parameter `D` in `FMCS D` is the **indexing type** for the family.
  This is NOT the same as `D` in `TaskFrame D` (the temporal domain).

  - When `D = Int` or `D = Rat`: indices are time points
  - When `D = CanonicalMCS`: indices are **world states**, not time points

  `CanonicalMCS` has only `[Preorder CanonicalMCS]` and cannot serve as a
  `TaskFrame D` temporal domain, which requires `[AddCommGroup D] [LinearOrder D]`.
  -/
  ```
- [ ] Update "time point" language at line 20 to: "indexed element (time point when D is temporal, world state when D = CanonicalMCS)"
- [ ] Update "Duration/time type" at line 63 to include the indexing distinction

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`

**Verification**:
- `lake build` passes

---

### Phase 2: Eliminate "D = CanonicalMCS" in CanonicalFMCS.lean [NOT STARTED]

**Goal**: Replace all "D = CanonicalMCS" notation with correct terminology.

**Tasks**:
- [ ] Line 19: Change "domain is CanonicalMCS" to "indexed by CanonicalMCS (the world-state space)"
- [ ] Line 70: Change "domain element" to "world-state index"
- [ ] Line 177: Add clarification that indexing is by world states, not time
- [ ] Line 280: Change "FMCS CanonicalMCS" discussion to explicitly say "FMCS indexed by CanonicalMCS (world states)"
- [ ] **Line 286 (HIGH PRIORITY)**: Change "for D = CanonicalMCS" to "for FMCS indexed by CanonicalMCS"

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`

**Verification**:
- `lake build` passes
- Grep for "D = CanonicalMCS" returns 0 matches in this file

---

### Phase 3: Fix DenseCompleteness.lean and StagedConstruction/Completeness.lean [NOT STARTED]

**Goal**: Eliminate the most confusing language about CanonicalMCS as "times" and the "D = CanonicalMCS" notation.

**Tasks**:
- [ ] DenseCompleteness.lean line 39: Change "(all MCSs as times)" to "(all MCSes as world-state indices)"
- [ ] DenseCompleteness.lean line 43: Clarify that Int is temporal domain, CanonicalMCS is indexing type (different roles)
- [ ] DenseCompleteness.lean line 116: Change "D = CanonicalMCS" to "indexed by CanonicalMCS"
- [ ] DenseCompleteness.lean line 138: Change "domain mismatch" to "architectural distinction: FMCS indexing type (CanonicalMCS/world states) vs TaskFrame temporal domain (TimelineQuot/time)"
- [ ] **StagedConstruction/Completeness.lean line 116 (HIGH PRIORITY)**: Change "D = CanonicalMCS (the all-MCS domain)" to "indexed by CanonicalMCS (the world-state space)"
- [ ] StagedConstruction/Completeness.lean line 119: Add note clarifying D = Int is the temporal domain (TaskFrame sense)

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean`

**Verification**:
- `lake build` passes
- No "MCSs as times" language remains
- No "D = CanonicalMCS" remains

---

### Phase 4: Fix MultiFamilyBFMCS.lean [NOT STARTED]

**Goal**: Eliminate "time" and "domain" terminology when referring to CanonicalMCS.

**Tasks**:
- [ ] Line 69: Change "domain is ALL canonical MCS" to "indexed by CanonicalMCS (all world states)"
- [ ] Line 83: Change "CanonicalMCS domain" to "CanonicalMCS indexing type"
- [ ] Line 94: Change "each time point is a CanonicalMCS element" to "each index is a world state (CanonicalMCS element)"
- [ ] Line 313: Change "common domain" to "common indexing type"
- [ ] Line 384: Change "domain (CanonicalMCS)" to "indexing type (CanonicalMCS world-state space)"
- [ ] **Line 387 (HIGH PRIORITY)**: Change "time t : CanonicalMCS" to "world state w : CanonicalMCS" (variable rename in comments)

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean`

**Verification**:
- `lake build` passes
- No "time t : CanonicalMCS" language remains

---

### Phase 5: ROAD_MAP.md Critical Updates [NOT STARTED]

**Goal**: Fix the central conflation in the roadmap where "D = CanonicalMCS" and "D = TimelineQuot" are written side-by-side as if competing for the same role.

**Tasks**:
- [ ] **Line 182 (HIGH PRIORITY)**: Change "the BFMCS uses D = CanonicalMCS while the TaskFrame semantics uses D = TimelineQuot" to:
  "the BFMCS is indexed by CanonicalMCS (world-state space) while the TaskFrame uses temporal domain D = TimelineQuot"
- [ ] **Line 209 (HIGH PRIORITY)**: Change to:
  "The BFMCS infrastructure is indexed by CanonicalMCS (world states), while TaskFrame uses temporal domain D = TimelineQuot (dense linear order)"
- [ ] Line 215: Change "domain mismatch" to "architectural distinction between FMCS indexing type and TaskFrame temporal domain"
- [ ] Line 957: Change "at time t" to "at world-state index w" when context is CanonicalMCS
- [ ] **Line 1258 (HIGH PRIORITY)**: Change "D=CanonicalMCS families" to "CanonicalMCS-indexed families"

**Timing**: 25 minutes

**Files to modify**:
- `specs/ROAD_MAP.md`

**Verification**:
- Grep for "D = CanonicalMCS" and "D=CanonicalMCS" returns 0 matches
- Documentation clearly distinguishes indexing type from temporal domain

---

### Phase 6: Medium Priority Files + Task 1008 Plans [NOT STARTED]

**Goal**: Update remaining files and the related task 1008 plans for consistency.

**Tasks**:
- [ ] SaturatedBFMCSConstruction.lean lines 202, 227: Clarify "domain" as indexing type
- [ ] WitnessFamilyBundle.lean line 153: Clarify "domain" as indexing type
- [ ] ChainFMCS.lean line 532: Clarify "domain" as indexing type
- [ ] LogicVariants.lean lines 142-153: Add note clarifying variable naming for CanonicalMCS elements
- [ ] **02_completeness-plan.md line 45**: Change "FMCS D where D = CanonicalMCS" to "FMCS indexed by CanonicalMCS"
- [ ] **02_completeness-plan.md line 53**: Change "using D = CanonicalMCS" to "using CanonicalMCS-indexed FMCS"

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedBFMCSConstruction.lean`
- `Theories/Bimodal/Metalogic/Bundle/WitnessFamilyBundle.lean`
- `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean`
- `Theories/Bimodal/LogicVariants.lean`
- `specs/1008_genuine_truth_at_completeness/plans/02_completeness-plan.md`

**Verification**:
- `lake build` passes
- All active files use consistent terminology

---

## Testing & Validation

After all phases:
- [ ] `lake build` passes
- [ ] `grep -r "D = CanonicalMCS" Theories/` returns 0 matches
- [ ] `grep -r "D=CanonicalMCS" Theories/` returns 0 matches
- [ ] `grep -r "D = CanonicalMCS" specs/ROAD_MAP.md` returns 0 matches
- [ ] No "time t : CanonicalMCS" language in active files
- [ ] No "all MCSs as times" language in active files

## Artifacts & Outputs

- plans/04_revised-clarification-plan.md (this file)
- summaries/05_clarification-summary.md (post-implementation)

## Rollback/Contingency

All changes are comments/docstrings only. If any phase breaks the build:
1. Revert with `git checkout -- <file>`
2. Re-examine comment syntax
3. Retry with corrected syntax

## Appendix: Correct Patterns Reference

### Pattern 1: Explicit Role Distinction
```
D = TimelineQuot (temporal domain), W = CanonicalMCS (world-state space)
```

### Pattern 2: Indexing Language for FMCS
```
FMCS indexed by CanonicalMCS
CanonicalMCS-indexed family
```

### Pattern 3: Clarifying Comments
```lean
-- Note: In `FMCS CanonicalMCS`, the type parameter is the indexing type (world states),
-- NOT the temporal domain D of TaskFrame (which requires AddCommGroup/LinearOrder).
```

### Files Already Using Correct Patterns (models to follow)
- SeparatedTaskFrame.lean line 6: `D = TimelineQuot, W = CanonicalMCS`
- AlgebraicBaseCompleteness.lean line 41: correctly identifies the typeclass mismatch
