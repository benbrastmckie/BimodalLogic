# Implementation Plan: Task #959 - Orient Pure-Syntax D Construction Cleanup

- **Task**: 959 - orient_pure_syntax_d_construction_cleanup
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/959_orient_pure_syntax_d_construction_cleanup/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task regains orientation for the D-from-syntax strategy by documenting the current state, marking deprecated files with clear comments (NOT removing them), updating ROAD_MAP.md for clarity, and closing Task 958 with proper documentation. The focus is on documentation and marking rather than file removal, per user guidance.

### Research Integration

From research-001.md:
- Three Int/Rat-tainted files identified: DovetailingChain.lean (archivable), TemporalCoherentConstruction.lean (import dependency blocking), Representation.lean (active completeness theorems)
- Task 958 confirmed completely unused (no imports, no references)
- CantorApplication.lean has 3 sorries sharing single root cause: quotient strictness gap
- Strategy C (prove strict witnesses) recommended for Phase 6-8 resolution

## Goals & Non-Goals

**Goals**:
- Add deprecation comments to Int/Rat-tainted files explaining their status
- Update ROAD_MAP.md with current D-from-syntax progress and phase status
- Document Task 958 resolution in CanonicalIrreflexivity.lean header
- Provide clear roadmap for Task 956 Phases 6-8

**Non-Goals**:
- Removing or archiving files that haven't been replaced yet
- Actually resolving the quotient strictness gap (Task 956 scope)
- Refactoring import dependencies (separate task if needed)
- Implementing any Lean code changes beyond comments

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Deprecation comments cause confusion | LOW | LOW | Use standardized format with clear DEPRECATED tag |
| ROAD_MAP.md update breaks formatting | LOW | LOW | Validate markdown structure after edit |
| Task 958 closure misinterpreted | MEDIUM | LOW | Document clearly why theorem is unused + unprovable |

## Sorry Characterization

### Pre-existing Sorries

This is a documentation/orientation task. The following sorries exist in the codebase but are NOT in scope for this task:
- 3 sorries in CantorApplication.lean (quotient strictness gap) - Task 956 scope
- 2 sorries in TemporalCoherentConstruction.lean (Int path) - deprecated, to be marked
- 2 sorries in DovetailingChain.lean (Int path) - deprecated, to be marked
- 2 sorries in CanonicalIrreflexivity.lean (unused theorem) - to be documented as unused

### Expected Resolution

- No sorries will be resolved in this task (documentation only)

### New Sorries

- None. This task adds only comments and documentation.

### Remaining Debt

All pre-existing sorries remain. Task 956 addresses the critical-path sorries (CantorApplication.lean).

## Implementation Phases

### Phase 1: Mark Deprecated Files with Comments [COMPLETED]

- **Dependencies:** None
- **Goal:** Add clear deprecation comments to Int/Rat-tainted files without removing them

**Tasks:**
- [ ] Add deprecation header comment to DovetailingChain.lean:
  - Mark as DEPRECATED with date
  - Explain: Int-indexed construction violates pure-syntax constraint
  - Note: Not imported by StagedConstruction chain
  - Reference: ROAD_MAP.md Dead End "All Int/Rat Import Approaches"
- [ ] Add deprecation header comment to TemporalCoherentConstruction.lean:
  - Mark as DEPRECATED with date
  - Explain: Int-specialized, violates pure-syntax constraint
  - Note: StagedExecution.lean depends on this (import refactoring needed before removal)
  - Reference: ROAD_MAP.md Dead End "All Int/Rat Import Approaches"
- [ ] Add deprecation header comment to Representation.lean:
  - Mark as DEPRECATED with date
  - Explain: Contains current working completeness but uses Int-indexed FMCS
  - Note: Will be superseded by Phase 8 TaskFrameFromSyntax.lean
  - Reference: Task 956 implementation plan

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - add deprecation header
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - add deprecation header
- `Theories/Bimodal/Metalogic/Representation.lean` - add deprecation header

**Verification:**
- [ ] `lake build` passes (comments only, no code changes)
- [ ] Each file has clear DEPRECATED comment at top of docstring

---

### Phase 2: Document Task 958 Status in Code [COMPLETED]

- **Dependencies:** None
- **Goal:** Add documentation to CanonicalIrreflexivity.lean explaining the theorem is unused and unprovable with String atoms

**Tasks:**
- [ ] Update CanonicalIrreflexivity.lean module docstring:
  - Add STATUS: UNUSED section explaining theorem is not imported anywhere
  - Add MATHEMATICAL GAP section explaining why unprovable with String atoms
  - Reference Task 958 research-009.md for full analysis
  - Note: Completeness chain does NOT require this theorem
  - Explain: Preorder on CanonicalMCS provides irreflexivity for free via strict `<`
- [ ] Add comment to canonicalR_irreflexive theorem:
  - Note that sorry is intentional and well-documented
  - Reference proof strategy and why it cannot complete

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - update docstring and comments

**Verification:**
- [ ] `lake build` passes
- [ ] Module docstring clearly explains UNUSED and UNPROVABLE status

---

### Phase 3: Update ROAD_MAP.md with Current Progress [COMPLETED]

- **Dependencies:** None
- **Goal:** Update ROAD_MAP.md to reflect current D-from-syntax progress and provide orientation

**Tasks:**
- [ ] Update "Strategy: D Construction from Canonical Timeline" section:
  - Add Outcomes subsection with Phase 0-5 completion status
  - Note current blocker: quotient strictness gap in CantorApplication.lean (3 sorries)
  - Reference latest implementation plan (v015 or current)
- [ ] Add new subsection "D-from-Syntax Phase Status" under Outcomes:
  - Phase 0-5: COMPLETED (sorry-free)
  - Phase 6: BLOCKED (3 sorries in CantorApplication.lean)
  - Phase 7-8: NOT STARTED (blocked by Phase 6)
- [ ] Update "Strategy: Indexed MCS Family Approach" if needed:
  - Clarify relationship to D-from-syntax strategy
- [ ] Ensure "Dead End: All Int/Rat Import Approaches" references the deprecated files

**Timing:** 45 minutes

**Files to modify:**
- `specs/ROAD_MAP.md` - update strategy outcomes and phase status

**Verification:**
- [ ] ROAD_MAP.md renders correctly in markdown viewer
- [ ] Phase status clearly documented
- [ ] References to deprecated files included

---

### Phase 4: Document Task 956 Phase 6-8 Path Forward [COMPLETED]

- **Dependencies:** Phase 3
- **Goal:** Add clear documentation for the path to completing Phases 6-8

**Tasks:**
- [ ] Create or update a "Phase 6-8 Roadmap" section in ROAD_MAP.md or link to implementation plan:
  - Phase 6 (CantorApplication.lean): Resolve quotient strictness gap
    - Root cause: DenseTimeline witnesses not proven STRICT in antisymmetrized quotient
    - Strategy C recommended: prove strict witnesses exist
    - Estimated effort: 3-4 hours
  - Phase 7 (DFromSyntax.lean): Define D = Q via Cantor isomorphism
    - Straightforward once Phase 6 done
    - Estimated effort: 1.5 hours
  - Phase 8 (TaskFrameFromSyntax.lean): Construct TaskFrame, prove completeness
    - Most substantial phase
    - Estimated effort: 2.5 hours
- [ ] Reference research-001.md Recommendation 1 for quotient strictness resolution strategies
- [ ] Note the escape valve: if stuck, mark [BLOCKED] for user review

**Timing:** 30 minutes

**Files to modify:**
- `specs/ROAD_MAP.md` - add Phase 6-8 roadmap section

**Verification:**
- [ ] Path forward clearly documented with estimates
- [ ] Blockers and strategies identified
- [ ] References to relevant research reports included

---

### Phase 5: Verification and Summary [COMPLETED]

- **Dependencies:** Phase 1, Phase 2, Phase 3, Phase 4
- **Goal:** Verify all changes are complete and consistent

**Tasks:**
- [ ] Run `lake build` to verify no build errors
- [ ] Review all modified files for consistency
- [ ] Verify ROAD_MAP.md renders correctly
- [ ] Check that deprecated file comments follow standard format
- [ ] Prepare summary of changes for commit message

**Timing:** 15 minutes

**Verification:**
- [ ] `lake build` passes
- [ ] All deprecation comments present and consistent
- [ ] ROAD_MAP.md updated with current progress
- [ ] CanonicalIrreflexivity.lean documented as unused
- [ ] Phase 6-8 path clearly documented

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] No new sorries introduced (this task adds only comments)

### General
- [ ] Deprecation comments use consistent format: `-- DEPRECATED (YYYY-MM-DD): reason`
- [ ] ROAD_MAP.md markdown renders correctly
- [ ] All references to research reports use correct paths

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- Modified files:
  - Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean (deprecation comment)
  - Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean (deprecation comment)
  - Theories/Bimodal/Metalogic/Representation.lean (deprecation comment)
  - Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean (unused documentation)
  - specs/ROAD_MAP.md (progress update)

## Rollback/Contingency

If changes cause issues:
1. Revert via `git checkout -- <file>` for any problematic file
2. Comments are additive-only, so removal is safe
3. ROAD_MAP.md changes can be reverted independently

## Deprecation Comment Standard Format

For consistency, use this format for deprecation headers:

```lean
/-!
-- DEPRECATED (2026-03-11): [Brief reason]
--
-- This file/module is deprecated because [full explanation].
--
-- Status:
-- - [What it does / why it exists]
-- - [Why it's deprecated]
-- - [What depends on it, if anything]
-- - [What will replace it]
--
-- References:
-- - ROAD_MAP.md: Dead End "[relevant dead end name]"
-- - Task [N]: [relevant task]
--
-- DO NOT USE for new development. Will be archived when [replacement] is complete.
-/
```
