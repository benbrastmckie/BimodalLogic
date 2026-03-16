# Teammate C Findings: Archival and Risk Analysis

**Task**: 929 - Prepare metalogic for publication
**Run**: 001
**Date**: 2026-03-15
**Focus**: Files to archive, risks, and blockers for publication readiness

---

## Executive Summary

The three files recommended for archival (DovetailingChain.lean, TemporalCoherentConstruction.lean, Construction.lean) **CANNOT be immediately archived** because they have active import dependencies. TemporalCoherentConstruction.lean is imported by 4 publication-path files including StagedExecution.lean and CanonicalConstruction.lean. The build passes with warnings (unused variables, deprecated Mathlib API usage). No Boneyard root README exists - only scattered subdirectory READMEs. Fourteen sorries remain in the active Metalogic codebase, primarily in DovetailingChain.lean (5), TemporalCoherentConstruction.lean (13), DiscreteTimeline.lean (14), and ConstructiveFragment.lean (3).

---

## Files Safe to Archive

| File | Lines | Sorries | Import Check | Action |
|------|-------|---------|--------------|--------|
| DovetailingChain.lean | 1,932 | 5 | Only imports Construction, not imported by others | **SAFE to archive** |

**Notes**:
- DovetailingChain.lean is explicitly marked DEPRECATED (2026-03-11)
- Self-contained: imports Construction but no active file imports DovetailingChain
- 5 sorries: 2 in buildDovetailingChainFamily_forward_F/backward_P (lines 1893, 1905)

---

## Files with Import Dependencies

| File | Imported By | Resolution |
|------|-------------|------------|
| Construction.lean | DovetailingChain.lean, TemporalCoherentConstruction.lean, ConstructiveFragment.lean, WitnessSeedWrapper.lean | **CANNOT archive** - used by StagedConstruction path |
| TemporalCoherentConstruction.lean | CanonicalConstruction.lean, CanonicalFMCS.lean, TruthLemma.lean, StagedExecution.lean | **CANNOT archive** - used by publication path |

**Dependency Analysis**:

1. **Construction.lean** (270 lines, 5 sorries)
   - Imported by: WitnessSeedWrapper.lean (StagedConstruction), ConstructiveFragment.lean, plus deprecated files
   - Contains: BFMCS construction basics, ContextDerivable
   - WitnessSeedWrapper.lean is on publication path via StagedExecution
   - **Resolution**: Must refactor imports before archiving

2. **TemporalCoherentConstruction.lean** (574 lines, 13 sorries)
   - Imported by: 4 active files including publication-path StagedExecution.lean
   - Contains: TemporalCoherentFamily structure, fully_saturated_bfmcs_exists_int
   - CanonicalConstruction.lean (publication path) imports this
   - **Resolution**: Extract needed definitions to separate module before archiving

---

## Additional Archival Candidates

| File | Lines | Sorries | Reason | Recommendation |
|------|-------|---------|--------|----------------|
| ConstructiveFragment.lean | ~600 | 3 | Research path (Task 956 v012), sorries in wellOrderedWitnessPath | Evaluate - may have useful patterns |
| DiscreteTimeline.lean | ~300 | 14 | Discrete-time construction with many sorries | Keep - discrete case distinct from dense |

**Not Archival Candidates** (despite deprecated references):
- TruthLemma.lean: Publication path, truth lemma is sorry-free despite file referencing deprecated patterns
- CanonicalFMCS.lean: Publication path, 7 sorries but defines canonical FMCS

---

## Build Status

- `lake build` result: **PASS**
- Warnings: 26+ (all non-blocking)
- Issues:

| Type | Count | Files |
|------|-------|-------|
| Unused variables | 10+ | Validity.lean, Soundness.lean |
| Deprecated Mathlib API (`le_or_lt`) | 3 | SoundnessLemmas.lean, Soundness.lean |
| Unused simp arguments | 6+ | SoundnessLemmas.lean, Soundness.lean, SignedFormula.lean |
| Unused tactic | 2 | ProofSearch.lean |

---

## Risk Analysis

### High Priority Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| TemporalCoherentConstruction cannot be archived without breaking publication path | Blocks archival cleanup | Extract needed exports (fully_saturated_bfmcs_exists_int) to minimal module |
| Construction.lean imports required by StagedConstruction | Same as above | Audit what WitnessSeedWrapper actually needs |
| No root-level Boneyard README | Documentation gap | Create Boneyard/README.md summarizing archive structure |

### Medium Priority Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| 14 sorries in DiscreteTimeline.lean | Discrete-time completeness incomplete | Document as non-publication-path; dense case is proven |
| Mathlib deprecation warnings (le_or_lt -> le_or_gt) | Future breakage on Mathlib update | Update API calls before v4.28 |
| 95 sorries total in codebase (per TODO.md header) | Publication hygiene | Document sorry locations and which are on/off publication path |

### Low Priority Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Unused variable warnings | Style | Add `_` prefix or use `@[simp]` attributes |
| plausible dependency on main branch | Version lock not pinned | Pin to specific tag |

---

## Tasks to Abandon

Based on Task 929 description and research-008 findings:

| Task | Status | Reason |
|------|--------|--------|
| 865 | Should abandon | Superseded by ChainBundleBMCS (per Task 929 desc) |
| 881 | Should abandon | Stepping stone to DovetailingChain; BMCS path complete (per Task 929 desc) |
| 916 | Should abandon | F/P witness DovetailingChain path has irreducible gap (per Task 929 desc) |
| 917 | Should abandon | Documentation fix for Task 916 concepts; moot if 916 abandoned |
| 922 | Should abandon | Research prerequisite for Task 916; moot if 916 abandoned |
| 930 | Should abandon | Target definitions archived to Boneyard; StagedConstruction is publication path (per research-008) |

**Additional Candidates**:

| Task | Status | Reason |
|------|--------|--------|
| Not identified | - | TODO.md scan did not reveal other superseded tasks |

---

## Boneyard Documentation

| Location | Status | Notes |
|----------|--------|-------|
| Boneyard/README.md | **MISSING** | No root-level README |
| Theories/Bimodal/Boneyard/README.md | **MISSING** | No Theories Boneyard README |
| Boneyard/Metalogic/README.md | Present | Dated 2026-01-19, 111 lines, documents deprecated approaches |
| Boneyard/Metalogic/Metalogic_v7/README.md | Present | Subdirectory documentation |
| Boneyard/FMP_Bridge/README.md | Present | Subdirectory documentation |

**Action Required**: Create root Boneyard/README.md with:
- Overall structure description
- Pointer to subdirectory READMEs
- Quick reference for what's archived vs. active

---

## Recommendations

### Priority 1 - Prerequisites for Archival
1. **Analyze Construction.lean imports**: Determine minimal exports needed by WitnessSeedWrapper.lean
2. **Analyze TemporalCoherentConstruction.lean imports**: Determine minimal exports needed by publication-path files
3. **Create extraction plan**: Move needed definitions to a "bridge" or "common" module

### Priority 2 - Immediate Actions
4. **Archive DovetailingChain.lean**: Only file safe to archive now (no active importers)
5. **Update Boneyard README**: Create root Boneyard/README.md documenting structure
6. **Abandon 6 tasks**: Tasks 865, 881, 916, 917, 922, 930 as identified

### Priority 3 - Build Hygiene
7. **Fix deprecated Mathlib API**: Update `le_or_lt` to `le_or_gt` (3 locations)
8. **Address unused variable warnings**: Low priority but improves CI hygiene

### Priority 4 - Documentation
9. **Document sorry locations**: Create table of all 95 sorries indicating publication-path vs. off-path
10. **Update Metalogic.lean module docstring**: Per Task 929 Phase 4

---

## Import Dependency Tree for Archival Candidates

```
Construction.lean (270 lines, 5 sorries)
├── DovetailingChain.lean [DEPRECATED, no active importers -> SAFE]
├── TemporalCoherentConstruction.lean [DEPRECATED but imported]
│   ├── CanonicalConstruction.lean [PUBLICATION PATH]
│   ├── CanonicalFMCS.lean [PUBLICATION PATH]
│   ├── TruthLemma.lean [PUBLICATION PATH]
│   └── StagedExecution.lean [PUBLICATION PATH]
├── ConstructiveFragment.lean [RESEARCH, 3 sorries]
└── WitnessSeedWrapper.lean [PUBLICATION PATH via StagedConstruction]
```

**Key Insight**: Construction.lean and TemporalCoherentConstruction.lean are "transitively" on publication path through WitnessSeedWrapper and StagedExecution. Archiving requires refactoring imports first.

---

## Confidence Level

**HIGH** for:
- Build status (verified via `lake build`)
- Import dependencies (verified via grep)
- Tasks to abandon (per Task 929 description + research-008)
- DovetailingChain.lean archival safety

**MEDIUM** for:
- Additional archival candidates (requires deeper analysis)
- Exact sorry count breakdown (counts vary by search method)
- Refactoring effort for Construction/TemporalCoherentConstruction extraction

---

## Appendix: Sorry Count by File

| File | Sorry Count | Publication Path? |
|------|-------------|-------------------|
| DovetailingChain.lean | 5 | No (deprecated) |
| TemporalCoherentConstruction.lean | 13 | Indirect (imports) |
| DiscreteTimeline.lean | 14 | No (discrete case) |
| ConstructiveFragment.lean | 3 | No (research) |
| **Total in deprecated/off-path** | ~35 | - |

Note: TruthLemma.lean, CanonicalConstruction.lean, Completeness.lean (StagedConstruction) are sorry-free on the dense completeness path per research-008.
