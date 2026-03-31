# Implementation Summary: Task #72

**Task**: wire_completeness_bfmcs_bundle (Semantic Cleanup)
**Date**: 2026-03-31
**Session**: sess_1774986103_fc1e79
**Plan**: plans/07_semantic-cleanup.md
**Type**: lean4 (Lean Intent: false - documentation cleanup only)

## Overview

This task performed semantic cleanup for the bundle-level temporal coherence constructs. The bundle approach was identified as semantically wrong for TM task semantics (F/P witnesses must be in the SAME world history, not different histories as bundles allow). The cleanup archived misleading code documentation and added correction notices to research reports.

## Phase Completion Summary

| Phase | Name | Status | Notes |
|-------|------|--------|-------|
| 1 | Inventory and Preparation | COMPLETED | Boneyard directory created with README |
| 2 | Extract Bundle Code to Boneyard | COMPLETED | Reference copy created (BundleCode.lean) |
| 3 | Clean References in Other Files | COMPLETED | Comments updated in affected files |
| 4 | Add Errata to Research Reports | COMPLETED | 6 reports updated with correction notices |
| 5 | Final Documentation and Build Verification | COMPLETED | Build passes, documentation consistent |

## Artifacts Created

### Boneyard Archive
- `Theories/Bimodal/Boneyard/BundleTemporalCoherence/README.md` - Comprehensive semantic explanation (89 lines)
- `Theories/Bimodal/Boneyard/BundleTemporalCoherence/BundleCode.lean` - Reference documentation (74 lines)

### Research Report Errata
Added correction sections to:
- `reports/01_team-research.md`
- `reports/01_teammate-a-findings.md`
- `reports/01_teammate-b-findings.md`
- `reports/05_team-research.md`
- `reports/05_teammate-a-findings.md`
- `reports/05_teammate-b-findings.md`

All errata reference `reports/06_semantic-correction.md` as the authoritative correction.

## Key Semantic Distinction Documented

| Property | Bundle-Level | TM Requires |
|----------|--------------|-------------|
| F(phi) witness | Can be in ANY family | Must be in SAME family |
| World history | May differ from original | MUST be same history |
| Coherence type | Cross-family | Single-family |

## Build Verification

```
Build completed successfully (938 jobs).
```

Pre-existing warnings (not introduced by this task):
- SubformulaClosure.lean: 6 unused simp args
- Discreteness.lean: 1 unused simp arg
- Examples/*.lean: Pre-existing sorries in pedagogical files

## What Was NOT Changed

The bundle constructs remain in `UltrafilterChain.lean` because:
1. They are used by `Completeness.lean` (with isolated sorry)
2. The code compiles and is technically correct for what it claims
3. Only the INTERPRETATION (as sufficient for TM completeness) was wrong

The fix is documentation and semantic clarity, not code removal.

## Dependencies and Follow-Up

### Correct Path Forward
The SuccChainFMCS approach with family-level forward_F/backward_P is the correct path. Remaining sorries are in the "fuel exhaustion" branch of bounded witness proofs (Class B hard case per ROADMAP.md).

### Referenced Documentation
- `ROADMAP.md:158-160` - Bundle approach documented as "dead end"
- `ROADMAP.md:167-198` - SuccChainFMCS working approach
- `Truth.lean:118-125` - TM task semantics definition
- `reports/06_semantic-correction.md` - Full semantic analysis

## Verification Checklist

- [x] `lake build` succeeds with no new warnings
- [x] Boneyard README explains semantic issue clearly
- [x] All research reports have errata sections
- [x] Errata reference authoritative correction report
- [x] Documentation is self-consistent
- [x] No new sorries introduced (cleanup task)
- [x] No new axioms introduced
