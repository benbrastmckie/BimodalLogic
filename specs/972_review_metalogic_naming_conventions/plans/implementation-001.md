# Implementation Plan: Task #972

- **Task**: 972 - review_metalogic_naming_conventions
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/972_review_metalogic_naming_conventions/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan addresses three naming convention issues in Theories/Bimodal/Metalogic/, renaming functions from UpperCamelCase to snake_case per Lean 4/Mathlib conventions. Each issue is a separate phase to enable atomic commits and easy rollback.

### Research Integration

From research-001.md:
- Issue 1 (GContent/HContent): 192 occurrences across 16 files in Metalogic/
- Issue 2 (WitnessSeed definitions): 30 occurrences across 4 files in Metalogic/
- Issue 4 (bmcs_ prefix): 34 occurrences across 6 files (includes README documentation)

## Goals & Non-Goals

**Goals**:
- Rename `GContent` to `g_content` and `HContent` to `h_content`
- Rename `ForwardTemporalWitnessSeed` to `forward_temporal_witness_seed`
- Rename `PastTemporalWitnessSeed` to `past_temporal_witness_seed`
- Replace `bmcs_` prefix with `bfmcs_` prefix for consistency with type name `BFMCS`
- Ensure `lake build` passes after each phase

**Non-Goals**:
- Changing abbreviations like `dne_theorem` / `dni_theorem` (Issue 3 from research)
- Moving functions to namespaces (alternative approach for Issue 4)
- Renaming items in Boneyard/ (archived code, not in active use)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cascading build failures | H | M | Rename definition and all usages in single Edit operation with replace_all; lake build after each file |
| Missing usages | M | L | Use Grep to find all occurrences before rename; verify count matches after |
| Breaking Boneyard code | L | H | Explicitly exclude Boneyard/ from changes; document this exclusion |

## Sorry Characterization

### Pre-existing Sorries
- None in scope (naming refactor only, no new proofs)

### Expected Resolution
- N/A (no sorries being resolved)

### New Sorries
- None. This is a pure rename refactor; no proof logic changes.

### Remaining Debt
- No change to sorry count; this task does not affect proof completeness.

## Implementation Phases

### Phase 1: Rename GContent/HContent [NOT STARTED]

- **Dependencies:** None
- **Goal:** Rename `GContent` to `g_content` and `HContent` to `h_content` in all Metalogic/ files

**Tasks**:
- [ ] Rename in TemporalContent.lean (definition site): `GContent` -> `g_content`, `HContent` -> `h_content`
- [ ] Update WitnessSeed.lean (30 usages of GContent/HContent)
- [ ] Update CanonicalFrame.lean (34 usages)
- [ ] Update ChainFMCS.lean (39 usages)
- [ ] Update DensityFrameCondition.lean (26 usages)
- [ ] Update DirectIrreflexivity.lean (5 usages)
- [ ] Update CanonicalConstruction.lean (3 usages)
- [ ] Update CanonicalIrreflexivity.lean (8 usages)
- [ ] Update CanonicalIrreflexivityAxiom.lean (3 usages)
- [ ] Update CanonicalFMCS.lean (8 usages)
- [ ] Update ConstructiveFragment.lean (4 usages)
- [ ] Update StagedTimeline.lean (1 usage)
- [ ] Update WitnessSeedWrapper.lean (2 usages)
- [ ] Update DenseTimeline.lean (5 usages)
- [ ] Update SeparationLemma.lean (8 usages)
- [ ] Update StagedExecution.lean (4 usages)
- [ ] Run `lake build` to verify no breakage

**Timing:** 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - Definition site
- 15 additional files in Metalogic/ with usages

**Verification**:
- `lake build` passes
- `grep -rn "GContent\|HContent" Theories/Bimodal/Metalogic/` returns empty (excluding comments/docs)

---

### Phase 2: Rename WitnessSeed definitions [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Rename `ForwardTemporalWitnessSeed` to `forward_temporal_witness_seed` and `PastTemporalWitnessSeed` to `past_temporal_witness_seed`

**Tasks**:
- [ ] Rename in WitnessSeed.lean (definition site, 18 occurrences)
- [ ] Update CanonicalFrame.lean (8 occurrences)
- [ ] Update ConstructiveFragment.lean (2 occurrences)
- [ ] Update WitnessSeedWrapper.lean (2 occurrences)
- [ ] Update docstrings referencing the old names
- [ ] Run `lake build` to verify no breakage

**Timing:** 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` - Definition site
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/WitnessSeedWrapper.lean`

**Verification**:
- `lake build` passes
- `grep -rn "ForwardTemporalWitnessSeed\|PastTemporalWitnessSeed" Theories/Bimodal/Metalogic/` returns empty (excluding comments/docs)

---

### Phase 3: Rename bmcs_ prefix to bfmcs_ [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Replace `bmcs_` prefix with `bfmcs_` prefix for consistency with type name `BFMCS`

**Tasks**:
- [ ] Rename in BFMCS.lean: `bmcs_reflexivity` -> `bfmcs_reflexivity`, `bmcs_transitivity` -> `bfmcs_transitivity`, `bmcs_diamond_witness` -> `bfmcs_diamond_witness`
- [ ] Update CanonicalConstruction.lean (2 usages)
- [ ] Update Completeness.lean (3 usages)
- [ ] Update Metalogic.lean (1 usage in module docstring)
- [ ] Update README.md files (documentation only, 15 occurrences in Bundle/README.md, 5 in Metalogic/README.md)
- [ ] Run `lake build` to verify no breakage

**Timing:** 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` - Definition site
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean`
- `Theories/Bimodal/Metalogic/Metalogic.lean`
- `Theories/Bimodal/Metalogic/Bundle/README.md`
- `Theories/Bimodal/Metalogic/README.md`

**Verification**:
- `lake build` passes
- `grep -rn "\bbmcs_" Theories/Bimodal/Metalogic/` returns empty (code only, docs updated)

---

### Phase 4: Final Verification [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Comprehensive verification that all renames are complete and consistent

**Tasks**:
- [ ] Run full `lake build` on entire project
- [ ] Verify no remaining UpperCamelCase function names in scope (GContent, HContent, ForwardTemporalWitnessSeed, PastTemporalWitnessSeed)
- [ ] Verify no remaining `bmcs_` prefixes in code (only `bfmcs_`)
- [ ] Grep for `\bsorry\b` in modified files to confirm no sorries introduced
- [ ] Document any edge cases or exclusions

**Timing:** 15 minutes

**Verification**:
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/` returns only pre-existing sorries (if any)
- All target identifiers renamed

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <modified files>` returns empty (zero-debt gate) - or unchanged from before
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All proofs verified (no proof changes, only renames)

### General
- [ ] All 192 GContent/HContent occurrences renamed
- [ ] All 30 WitnessSeed occurrences renamed
- [ ] All 8 bmcs_* function definitions renamed (34 total including usages and docs)
- [ ] Boneyard/ explicitly excluded and unchanged

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (after completion)

## Rollback/Contingency

Each phase produces a separate git commit, enabling:
1. `git revert <commit>` to undo any single phase
2. `git reset --hard HEAD~N` to undo last N phases

If cascading failures occur:
1. Identify which rename broke the build
2. Check for missed usages with broader grep
3. Fix and re-run lake build
4. If unresolvable, revert phase and document blocker
