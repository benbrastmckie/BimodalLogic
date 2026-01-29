# Implementation Plan: Task #746

- **Task**: 746 - improve_bimodal_metalogic_source_comments
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/746_improve_bimodal_metalogic_source_comments/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: false

## Overview

This task improves comment quality across 15 Lean files in `Theories/Bimodal/Metalogic/` by removing temporal/historical language, standardizing proof narration, and ensuring consistent documentation style. The research identified ~150 comment blocks requiring changes across files organized into high, medium, and low priority groups.

### Research Integration

The research report (research-001.md) identified four main issue categories:
1. Temporal/historical language (~60 instances): "now", "currently", "previously"
2. Informal proof narration (~80 instances): "we need", "we have", "we get"
3. Development history references (~15 sections): task refs, "superseded", "originally"
4. Inconsistent issue markers (~10 instances): varied formatting for known issues

## Goals & Non-Goals

**Goals**:
- Remove all temporal language ("now", "currently", "previously", "at this point")
- Replace informal proof narration with direct declarative statements
- Remove development history references and comparisons to past approaches
- Standardize "Known Issue" / "Known Limitation" formatting
- Preserve all code functionality (comments only)

**Non-Goals**:
- Modifying any Lean code or proofs
- Adding new documentation to low-priority files with minimal comments
- Expanding existing comments beyond clarity improvements
- Changing the mathematical content of explanations

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Accidentally modify code while editing comments | High | Low | Use Edit tool with precise old_string matching; verify with lake build after each phase |
| Remove useful context from historical notes | Medium | Medium | Preserve the factual content while removing temporal framing |
| Inconsistent style across phases | Medium | Low | Apply consistent transformation rules per issue category |
| Build failure from comment syntax errors | Medium | Low | Run lake build verification after each phase |

## Implementation Phases

### Phase 1: High Priority - History and Development References [COMPLETED]

**Goal**: Remove SUPERSEDED sections and development history from the most heavily affected files

**Tasks**:
- [ ] CoherentConstruction.lean: Remove "SUPERSEDED CONSTRUCTION" section, "NOTE: previously from Boneyard", "Key Insight" comparisons to original approach
- [ ] IndexedMCSFamily.lean: Remove "Design Evolution" section, task references; rewrite as direct factual documentation
- [ ] Verify files compile with `lake build`

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` - Remove ~3 historical sections
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - Rewrite design documentation

**Verification**:
- No references to task numbers remain in comments
- No "previously", "originally", "superseded" language
- `lake build Theories.Bimodal.Metalogic.Representation` succeeds

---

### Phase 2: High Priority - Temporal Language Cleanup [COMPLETED]

**Goal**: Remove temporal framing from high-priority files

**Tasks**:
- [ ] BooleanStructure.lean: Replace "We now establish...", "For now, we provide...", "Now compose..."
- [ ] InfinitaryStrongCompleteness.lean: Replace "at this point", "we need to show" patterns
- [ ] UltrafilterMCS.lean: Replace "We need [phi] vdash psi..." patterns
- [ ] SemanticCanonicalModel.lean: Standardize "KNOWN GAP" to "Known Limitation" format
- [ ] Verify files compile

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/BooleanStructure.lean` - ~15 temporal instances
- `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean` - ~10 instances
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` - ~10 instances
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Standardize formatting

**Verification**:
- No "now", "currently" in modified files
- "Known Limitation" consistently formatted
- `lake build Theories.Bimodal.Metalogic.Algebraic Theories.Bimodal.Metalogic.Completeness Theories.Bimodal.Metalogic.FMP` succeeds

---

### Phase 3: Medium Priority - Targeted Fixes [COMPLETED]

**Goal**: Apply targeted fixes to medium-priority files

**Tasks**:
- [ ] LindenbaumQuotient.lean: Replace "We now lift..." at L276
- [ ] CanonicalWorld.lean: Replace "For now" comments, standardize TODOs
- [ ] UniversalCanonicalModel.lean: Replace "For now" at L82, standardize TODO at L81
- [ ] MCSProperties.lean: Clean up proof narration comments
- [ ] DeductionTheorem.lean: Clean up proof narration comments
- [ ] Compactness.lean: Replace "at this point" at L100
- [ ] Verify files compile

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean` - 1 instance
- `Theories/Bimodal/Metalogic/Representation/CanonicalWorld.lean` - 2-3 instances
- `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean` - 2 instances
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - ~5 instances
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` - ~5 instances
- `Theories/Bimodal/Metalogic/Compactness/Compactness.lean` - 1 instance

**Verification**:
- No temporal language in modified files
- TODOs follow consistent format: `-- TODO: description`
- `lake build` succeeds for all modified modules

---

### Phase 4: Medium Priority - Issue Marker Standardization [COMPLETED]

**Goal**: Standardize "Known Issue" documentation across remaining files

**Tasks**:
- [ ] Closure.lean: Standardize "Known Issue" section formatting
- [ ] FiniteModelProperty.lean: Standardize "Known Sorries" section
- [ ] FiniteWorldState.lean: Standardize NOTE marker
- [ ] Review all files for consistent "Known Limitation" heading format
- [ ] Verify files compile

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/Closure.lean` - Standardize section
- `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean` - Standardize section
- `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` - Standardize marker

**Verification**:
- Consistent "Known Limitations" or "Open Problems" headings
- No mixed formats for issue documentation
- `lake build Theories.Bimodal.Metalogic.FMP` succeeds

---

### Phase 5: Final Review and Verification [COMPLETED]

**Goal**: Verify all changes, ensure no regressions

**Tasks**:
- [ ] Run full `lake build` for Theories.Bimodal.Metalogic
- [ ] Grep for remaining temporal language patterns
- [ ] Grep for remaining development history patterns
- [ ] Verify no code changes (only comment modifications)
- [ ] Create implementation summary

**Timing**: 30 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build Theories.Bimodal.Metalogic` succeeds without errors
- `grep -r "now" Theories/Bimodal/Metalogic/` shows no temporal uses in comments
- `grep -r "previously\|superseded\|originally" Theories/Bimodal/Metalogic/` returns empty
- Git diff shows only comment changes, no code modifications

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Metalogic` succeeds after each phase
- [ ] No new warnings introduced
- [ ] Grep verification shows temporal/historical patterns removed
- [ ] Git diff confirms changes are comment-only (no code lines modified)

## Artifacts & Outputs

- `specs/746_improve_bimodal_metalogic_source_comments/plans/implementation-001.md` (this file)
- `specs/746_improve_bimodal_metalogic_source_comments/summaries/implementation-summary-20260129.md` (created on completion)

## Rollback/Contingency

Since this task modifies only comments and not code:
- Git revert of any commit restores previous state
- No functional changes to undo
- If build fails after a phase, git checkout the affected files and re-apply changes more carefully
