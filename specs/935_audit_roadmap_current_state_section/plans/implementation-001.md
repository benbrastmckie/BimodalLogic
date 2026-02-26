# Implementation Plan: Task #935

- **Task**: 935 - audit_roadmap_current_state_section
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/935_audit_roadmap_current_state_section/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task audits and rewrites the "Current State: What's Been Accomplished" section (lines 636-1497) of specs/ROAD_MAP.md. Research identified 15 findings across 4 categories: outdated claims (completeness hierarchy, compactness, sorry counts), inaccurate file paths, unclear historical context, and missing documentation for active BFMCS/FMP approaches. The plan restructures the section around current architecture rather than archived Metalogic_v5.

### Research Integration

Key findings from research-001.md:
- Completeness Hierarchy table references archived files (WeakCompleteness.lean, etc.)
- Compactness module is fully archived to Boneyard
- Sorry counts claim "~29" but actual count is **3** (in DovetailingChain/TemporalCoherentConstruction)
- IndexedMCSFamily approach is superseded by BFMCS
- Active completeness theorems in Bundle/Completeness.lean not documented
- FMP approach in FMP/SemanticCanonicalModel.lean barely mentioned

## Goals & Non-Goals

**Goals**:
- Accurately reflect current codebase state (not archived Metalogic_v5)
- Document BFMCS completeness as primary active approach
- Correctly report sorry counts (3 sorries, not ~29)
- Distinguish active code from archived Boneyard code
- Provide clear guidance for theory development

**Non-Goals**:
- Rewriting other sections of ROAD_MAP.md (focus on lines 636-1497)
- Changing the codebase structure
- Adding new completeness proofs
- Documenting every historical approach in detail

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Incorrect file paths | High | Medium | Cross-reference with `glob` before writing |
| Missing active accomplishments | Medium | Low | Consult Bundle/README.md and FMP/README.md |
| Excessive historical detail | Medium | Medium | Keep historical section brief, link to Boneyard READMEs |
| Sorry count becomes stale | Low | High | Add timestamp and grep command for verification |

## Implementation Phases

### Phase 1: Restructure Section Architecture [COMPLETED]

- **Dependencies:** None
- **Goal:** Create new section structure that prioritizes current architecture over historical

**Tasks**:
- [ ] Read current section (lines 636-1497) to understand existing structure
- [ ] Create new subsection order:
  1. Current Architecture (BFMCS Bundle)
  2. Key Accomplishments (with correct paths)
  3. Sorry Debt Status (with verification method)
  4. Archived Approaches (brief, with Boneyard links)
- [ ] Draft section headers and navigation structure

**Timing**: 30 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` (lines 636-1497) - restructure subsections

**Verification**:
- New structure clearly separates "Current" from "Historical/Archived"
- Section headers follow existing ROAD_MAP.md style

---

### Phase 2: Update Current Architecture Documentation [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Document BFMCS and FMP approaches as the active completeness strategies

**Tasks**:
- [ ] Add "Current Architecture: BFMCS Bundle Approach" subsection documenting:
  - `bmcs_representation` at `Bundle/Completeness.lean:100`
  - `bmcs_weak_completeness` at `Bundle/Completeness.lean:243`
  - `bmcs_strong_completeness` at `Bundle/Completeness.lean`
- [ ] Add "FMP Completeness" subsection documenting:
  - `fmp_weak_completeness` at `FMP/SemanticCanonicalModel.lean`
- [ ] Remove/archive "Core Infrastructure" table referencing IndexedMCSFamily.lean
- [ ] Remove/archive "Completeness Hierarchy" table referencing non-existent files
- [ ] Update "Compactness" section to status "ARCHIVED"

**Timing**: 45 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - rewrite core accomplishments with correct paths

**Verification**:
- All file paths verified with `glob` to exist in active code (not Boneyard)
- No references to IndexedMCSFamily.lean, CanonicalHistory.lean, WeakCompleteness.lean as active code

---

### Phase 3: Correct Sorry Counts and Debt Status [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Update sorry counts to match actual codebase state (3 sorries)

**Tasks**:
- [ ] Replace "~29 sorries" claim with accurate count (3)
- [ ] Update sorry location table:
  | File | Count | Description |
  |------|-------|-------------|
  | Bundle/TemporalCoherentConstruction.lean:600 | 1 | Temporal coherent construction |
  | Bundle/DovetailingChain.lean:1869 | 1 | Cross-sign propagation |
  | Bundle/DovetailingChain.lean:1881 | 1 | Cross-sign propagation |
- [ ] Remove outdated sorry count categories (Representation/, Completeness/, Algebraic/)
- [ ] Add timestamp: "as of 2026-02-26"
- [ ] Add verification command: `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic --include="*.lean" | grep -v Boneyard`

**Timing**: 20 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - update sorry count section

**Verification**:
- Running the grep command returns exactly 3 results matching documented locations
- No claims of sorry counts in directories that are now archived

---

### Phase 4: Archive Historical Content [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Move IndexedMCSFamily approach documentation to clearly-marked historical section

**Tasks**:
- [ ] Create "Historical: Archived Approaches" subsection
- [ ] Move IndexedMCSFamily approach content with clear "ARCHIVED - Superseded by BFMCS" marker
- [ ] Fix Boneyard paths from `Theories/Boneyard/` to `Theories/Bimodal/Boneyard/`
- [ ] Add links to Boneyard README files for historical reference:
  - `Theories/Bimodal/Boneyard/Metalogic_v5/README.md`
  - `Theories/Bimodal/Metalogic/Representation/README.md` (archived notice)
  - `Theories/Bimodal/Metalogic/Compactness/README.md` (archived notice)
- [ ] Reduce historical detail to brief summary with pointers

**Timing**: 25 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - consolidate historical content into marked section

**Verification**:
- Historical content clearly marked with "ARCHIVED" or "Historical"
- All Boneyard paths use correct `Theories/Bimodal/Boneyard/` prefix
- Links to README files are valid

---

## Testing & Validation

- [ ] Verify all file paths exist using `glob` or `ls`
- [ ] Run sorry grep command and confirm 3 sorries reported
- [ ] Check no references to archived files as "active" or "current"
- [ ] Verify Boneyard paths use correct prefix
- [ ] Read through section for clarity and consistency
- [ ] Confirm section follows existing ROAD_MAP.md formatting style

## Artifacts & Outputs

- `specs/ROAD_MAP.md` - Updated Current State section (lines 636-1497)
- `specs/935_audit_roadmap_current_state_section/summaries/implementation-summary-20260226.md` - Implementation summary

## Rollback/Contingency

If changes introduce confusion or errors:
1. Git history preserves original ROAD_MAP.md
2. Can restore specific sections from prior commit
3. All changes are to a single markdown file with clear diff visibility

---

## Progress

**Session: 2026-02-26, sess_1772134530_b965c7**
- Completed: Phase 1 - Restructured section architecture with new subsection order
- Completed: Phase 2 - Added BFMCS and FMP completeness documentation with accurate paths
- Completed: Phase 3 - Corrected sorry counts from ~29 to 3 with exact locations
- Completed: Phase 4 - Archived historical content with clear ARCHIVED markers
- Fixed: All file paths verified to exist in active codebase
- Fixed: Updated Phase 0.1, Phase 5, and Conclusion sections with accurate information
