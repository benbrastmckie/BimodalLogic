# Implementation Summary: Task 933 - Archive Boneyard Candidates

**Date**: 2026-02-26
**Session**: sess_1772093296_67ca46
**Plan**: specs/933_research_alternative_canonical_construction/plans/implementation-001.md
**Status**: IMPLEMENTED (all 6 phases completed)

## Overview

Archived the CanonicalReachable/CanonicalQuotient/CanonicalEmbedding construction stack
and removed dead code from BFMCSTruth.lean. These were intermediate approaches superseded
by the all-MCS approach (canonicalMCSBFMCS) which supports both forward_F and backward_P
without sorry.

## Changes Made

### Files Archived to Boneyard

All archived to `Theories/Bimodal/Boneyard/Bundle/CanonicalQuotientApproach/`:

1. **CanonicalReachable.lean** (329 lines) - Future-reachable fragment type and properties.
   Blocked because backward_P past witnesses are not future-reachable.

2. **CanonicalQuotient.lean** (277 lines) - Antisymmetrization quotient of reachable fragment.
   Infrastructure for the blocked CanonicalReachable approach.

3. **CanonicalEmbedding.lean** (398 lines) - Derived properties (F_implies_G_P_F, linearity,
   canonical existence lemmas). Infrastructure for the blocked approach.

4. **LegacyCanonicalFMCS.lean** (new, extracted) - Legacy definitions from CanonicalFMCS.lean
   including canonicalReachableBFMCS, canonicalBFMCS_mcs, and quotient Zero instances.

### Files Modified

5. **CanonicalFMCS.lean** - Removed import of CanonicalQuotient. Removed legacy section
   (lines 287-399, ~112 lines of legacy CanonicalReachable/CanonicalQuotient FMCS definitions).
   Updated module docstring to note archival.

6. **BFMCSTruth.lean** - Removed dead `bmcs_truth_eval` (1 def) and `bmcs_truth_eval_of_all`
   (1 lemma) plus the empty "Monotonicity Properties" section header (~19 lines).

### Files Removed from Active Codebase

- `Theories/Bimodal/Metalogic/Bundle/CanonicalReachable.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean`

## Verification

- `lake build` passes with 1001 jobs (no regressions)
- No new sorries introduced
- No new axioms introduced
- All 4 Boneyard files contain BONEYARD warning headers
- No orphan imports in active code
- No active code references archived definitions (only doc comments for historical context)

## Lines Changed

- **Archived**: ~1004 lines of Lean code to Boneyard (3 full files + 1 extracted section)
- **Removed from active**: ~131 lines (112 legacy section + 19 dead code)
- **Net active code reduction**: ~1135 lines removed from active compilation

## Phase Completion

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Archive CanonicalReachable.lean | COMPLETED |
| 2 | Archive CanonicalQuotient.lean | COMPLETED |
| 3 | Archive CanonicalEmbedding.lean | COMPLETED |
| 4 | Archive legacy section of CanonicalFMCS.lean | COMPLETED |
| 5 | Remove dead code from BFMCSTruth.lean | COMPLETED |
| 6 | Final verification | COMPLETED |
