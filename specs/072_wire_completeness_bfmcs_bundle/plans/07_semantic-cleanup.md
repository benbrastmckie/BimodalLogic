# Implementation Plan: Semantic Cleanup for Task #72

- **Task**: 72 - wire_completeness_bfmcs_bundle
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/072_wire_completeness_bfmcs_bundle/reports/06_semantic-correction.md
- **Artifacts**: plans/07_semantic-cleanup.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan addresses the semantic correction documented in report 06_semantic-correction.md. The bundle-level temporal coherence approach (BFMCS_Bundle, construct_bfmcs_bundle, etc.) is semantically wrong for TM task semantics because it allows F/P witnesses in DIFFERENT world histories, whereas TM temporal operators quantify over times in the SAME history. This cleanup archives the misleading bundle constructs and documents the semantic distinction clearly.

### Research Integration

From 06_semantic-correction.md:
- Bundle-level coherence allows `fam' != fam` for F/P witnesses -- WRONG for TM
- TM task semantics (Truth.lean:118-125): G/H quantify over times in SAME history `tau`
- ROADMAP.md (lines 158-160) already identifies bundle approach as dead end
- SuccChainFMCS with family-level coherence is the correct path
- ~250 lines of bundle code to archive from UltrafilterChain.lean

## Goals & Non-Goals

**Goals**:
- Archive bundle-level temporal coherence constructs to Boneyard/
- Create clear documentation explaining why bundle approach is semantically wrong
- Add errata to affected research reports (01-05)
- Update code comments to prevent future confusion
- Preserve semantically correct modal infrastructure (boxClassFamilies_modal_*)

**Non-Goals**:
- Implementing family-level forward_F/backward_P (that's SuccChainFMCS path, separate work)
- Modifying the core completeness strategy
- Creating new ROAD_MAP.md entries (just clarifying existing text)
- Touching any sorry-free correct code

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking imports | High | Low | Grep for BFMCS_Bundle usages before archiving |
| Missing bundle references | Medium | Medium | Comprehensive search of all files before archiving |
| Unclear archive documentation | Medium | Low | Include semantic explanation in Boneyard README |

## Implementation Phases

### Phase 1: Inventory and Preparation [COMPLETED]

**Goal**: Identify all bundle-related constructs and prepare archive directory structure

**Tasks**:
- [ ] Search for all bundle-related definitions and theorems in UltrafilterChain.lean
- [ ] Search for bundle references in other files (RestrictedTruthLemma.lean, etc.)
- [ ] Create Boneyard directory structure:
  - `Theories/Bimodal/Boneyard/BundleTemporalCoherence/`
  - `Theories/Bimodal/Boneyard/BundleTemporalCoherence/README.md`
- [ ] Verify no external dependencies import bundle constructs (Completeness.lean confirmed clean)

**Timing**: 30 minutes

**Files to modify**:
- Create `Theories/Bimodal/Boneyard/BundleTemporalCoherence/README.md`

**Verification**:
- Boneyard directory exists with README.md
- Complete inventory of constructs to archive documented

---

### Phase 2: Extract Bundle Code to Boneyard [IN PROGRESS]

**Goal**: Move bundle-level coherence constructs from UltrafilterChain.lean to Boneyard

**Tasks**:
- [ ] Extract the following constructs from UltrafilterChain.lean (lines ~5400-5752):
  - `bundle_forward_F` definition
  - `bundle_backward_P` definition
  - `BundleTemporallyCoherent` definition
  - `bundle_coherence_implies_F_witness` theorem
  - `bundle_coherence_implies_P_witness` theorem
  - `boxClassFamilies_box_agree_at_time` theorem (needed for context)
  - `boxClassFamilies_bundle_forward_F` theorem
  - `boxClassFamilies_bundle_backward_P` theorem
  - `boxClassFamilies_bundle_temporally_coherent` theorem
  - `BFMCS_Bundle` structure
  - `BFMCS_Bundle.reflexivity` theorem
  - `BFMCS_Bundle.diamond_witness` theorem
  - `construct_bfmcs_bundle` definition
  - `construct_bfmcs_bundle_eval_at_zero` theorem
  - `construct_bfmcs_bundle_temporally_coherent` theorem
- [ ] Create Boneyard lean file with proper import statements
- [ ] Add semantic explanation comments at top of Boneyard file
- [ ] Remove extracted code from UltrafilterChain.lean
- [ ] Update UltrafilterChain.lean section headers to reflect removal

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Remove bundle code
- Create `Theories/Bimodal/Boneyard/BundleTemporalCoherence/BundleCode.lean`

**Verification**:
- `lake build` succeeds after extraction
- Boneyard code compiles independently (as reference)
- UltrafilterChain.lean builds without bundle constructs

---

### Phase 3: Clean References in Other Files [NOT STARTED]

**Goal**: Remove or update bundle references in RestrictedTruthLemma.lean and other files

**Tasks**:
- [ ] Update RestrictedTruthLemma.lean lines 344-397 to remove construct_bfmcs_bundle strategy comments
- [ ] Remove references to BFMCS_Bundle from comments (replace with pointer to SuccChainFMCS)
- [ ] Update any remaining bundle references in UltrafilterChain.lean lines 8307, 8351
- [ ] Verify Completeness.lean has no bundle references (already confirmed clean)
- [ ] Add clarifying comments pointing to correct SuccChainFMCS approach

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` - Update comments
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Update remaining comments

**Verification**:
- `lake build` succeeds
- No references to bundle approach remain in active code paths
- Comments point to SuccChainFMCS as the correct approach

---

### Phase 4: Add Errata to Research Reports [NOT STARTED]

**Goal**: Add correction notices to affected research reports

**Tasks**:
- [ ] Add errata section to `reports/01_team-research.md`
- [ ] Add errata section to `reports/05_team-research.md`
- [ ] Add errata section to `reports/05_teammate-a-findings.md`
- [ ] Add errata section to `reports/05_teammate-b-findings.md`
- [ ] Reference 06_semantic-correction.md as the authoritative correction

**Timing**: 20 minutes

**Files to modify**:
- `specs/072_wire_completeness_bfmcs_bundle/reports/01_team-research.md`
- `specs/072_wire_completeness_bfmcs_bundle/reports/05_team-research.md`
- `specs/072_wire_completeness_bfmcs_bundle/reports/05_teammate-a-findings.md`
- `specs/072_wire_completeness_bfmcs_bundle/reports/05_teammate-b-findings.md`

**Errata Template**:
```markdown
## Errata (2026-03-31)

**CORRECTION**: The bundle-level temporal coherence approach recommended in this report
is semantically wrong for TM task semantics. TM temporal operators (G, H, F, P) quantify
over times in the SAME world history, not over different histories as bundle-level
coherence allows. See `reports/06_semantic-correction.md` for full analysis.

The correct approach uses SuccChainFMCS with family-level temporal coherence.
```

**Verification**:
- All 4 affected reports have errata sections
- Errata clearly reference 06_semantic-correction.md

---

### Phase 5: Final Documentation and Build Verification [NOT STARTED]

**Goal**: Ensure comprehensive documentation and clean build

**Tasks**:
- [ ] Update Boneyard README with full semantic explanation
- [ ] Run `lake build` to verify no regressions
- [ ] Run `lake build Theories.Bimodal.Boneyard.BundleTemporalCoherence.BundleCode` if needed
- [ ] Review all modified files for consistency
- [ ] Create implementation summary

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/BundleTemporalCoherence/README.md` - Finalize

**Verification**:
- `lake build` succeeds with no warnings related to changes
- Boneyard README explains the semantic issue clearly
- All documentation is self-consistent

---

## Testing & Validation

- [ ] `lake build` succeeds after all phases
- [ ] No sorries introduced (cleanup only, no new proofs)
- [ ] Grep confirms no bundle construct references in active code
- [ ] Boneyard contains complete extracted code for reference
- [ ] Research reports have appropriate errata

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/BundleTemporalCoherence/README.md` - Semantic explanation
- `Theories/Bimodal/Boneyard/BundleTemporalCoherence/BundleCode.lean` - Archived code
- Updated research reports with errata sections
- Clean UltrafilterChain.lean without bundle constructs
- Clean RestrictedTruthLemma.lean without bundle references

## Rollback/Contingency

If any phase breaks the build:
1. `git checkout HEAD -- Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
2. `git checkout HEAD -- Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean`
3. Review the error and adjust extraction scope

The bundle code is currently unused (no imports depend on it), so the primary risk is incomplete removal rather than breaking dependencies.
