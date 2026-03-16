# Implementation Plan: Task #971 - Eliminate bmcs_truth_at Layer

- **Task**: 971 - Refactor to eliminate bmcs_truth_at layer
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Dependencies**: None (self-contained refactor)
- **Research Inputs**: specs/971_refactor_eliminate_bmcs_truth_at_layer/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: logic
- **Lean Intent**: true

## Overview

Systematic refactor to eliminate the redundant `bmcs_truth_at` layer from the metalogic codebase. The research confirms that `bmcs_truth_at` is explicitly documented as structurally redundant (CanonicalConstruction.lean line 20) because `canonical_truth_lemma` now proves the truth lemma directly at the `truth_at` level. This refactor archives unused definitions to the Boneyard, updates the publication path to use `canonical_truth_lemma` as primary, and streamlines the proof architecture.

### Research Integration

Key findings from research-001.md:
- `bmcs_truth_at` is definitionally equivalent to `truth_at` for canonical constructions
- Two parallel truth lemma paths exist: Path A (legacy via bmcs_truth_at) and Path B (modern via canonical_truth_lemma)
- Only `BFMCSTruth.lean` and `TruthLemma.lean` actively use `bmcs_truth_at`; other code has already migrated
- Unused definitions confirmed: `bmcs_valid`, `bmcs_satisfiable_at`, `bmcs_satisfies_context` (lines 100-102 already note removal)
- Recommended approach: Option A (derive bmcs_truth_lemma as corollary, deprecate but preserve)

## Goals & Non-Goals

**Goals**:
- Archive `BFMCSTruth.lean` to `Theories/Bimodal/Boneyard/` (the file is already minimized)
- Refactor `TruthLemma.lean` to derive `bmcs_truth_lemma` from `canonical_truth_lemma`
- Update `Metalogic.lean` publication exports to reference `canonical_truth_lemma` as primary
- Ensure `lake build` passes after each phase
- Remove unused definitions (already noted as removed in comments)
- Update documentation to reflect streamlined architecture

**Non-Goals**:
- Full elimination of `bmcs_truth_at` definition (preserve for backward compatibility)
- Rewriting the inductive proof structure in TruthLemma.lean
- Modifying the `CanonicalConstruction.lean` proof (it is already the target architecture)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import cycle after moving BFMCSTruth.lean | HIGH | LOW | TruthLemma.lean imports CanonicalConstruction.lean which already imports TruthLemma.lean; keep BFMCSTruth.lean in place as deprecated, archive only fully unused files |
| Build breakage from removing imports | MEDIUM | MEDIUM | Run `lake build` after each file modification; preserve all imports initially, remove only after verification |
| Boneyard files not compiling | LOW | LOW | Mark archived files with `-- DEPRECATED` header; do not add to build |

## Implementation Phases

### Phase 1: Audit and Prepare [NOT STARTED]

- **Dependencies:** None
- **Goal:** Audit current dependency structure and prepare for refactor

**Tasks:**
- [ ] Run `lake build` to establish baseline (should pass)
- [ ] Verify `bmcs_truth_at` usage with grep (confirm only BFMCSTruth.lean, TruthLemma.lean, Representation.lean)
- [ ] Verify `bmcs_truth_lemma` usage in downstream files
- [ ] Document import graph for Bundle/ files

**Timing:** 20 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` - Definition file
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Primary consumer
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - Target architecture
- `Theories/Bimodal/Boneyard/IntRepresentation/Representation.lean` - Deprecated consumer

**Verification:**
- `lake build` passes
- Dependency map documented in commit message

---

### Phase 2: Archive BFMCSTruth Definitions to Boneyard [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Move BFMCSTruth.lean to Boneyard with proper deprecation notice

**Tasks:**
- [ ] Create `Theories/Bimodal/Boneyard/Task971_BFMCSTruth/` directory
- [ ] Copy `BFMCSTruth.lean` to `Boneyard/Task971_BFMCSTruth/BFMCSTruth.lean`
- [ ] Add comprehensive deprecation notice header to original file
- [ ] Keep original file in place (required by TruthLemma.lean import)
- [ ] Update Boneyard/README.md to document this archive

**Timing:** 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` - Add deprecation header
- `Theories/Bimodal/Boneyard/Task971_BFMCSTruth/BFMCSTruth.lean` - Create archived copy
- `Theories/Bimodal/Boneyard/README.md` - Document archive

**Deprecation Header Content:**
```lean
/-!
# BFMCS Truth Definition [DEPRECATED - Task 971]

**DEPRECATION NOTICE**: This module defines the intermediate `bmcs_truth_at` layer
which is structurally redundant. The `canonical_truth_lemma` in CanonicalConstruction.lean
proves the truth lemma directly at the `truth_at` level, eliminating this intermediate.

**Migration Guide**:
- For truth lemma: Use `canonical_truth_lemma` from `CanonicalConstruction.lean`
- For shift-closed variant: Use `shifted_truth_lemma` from `CanonicalConstruction.lean`
- The `bmcs_truth_at` definition remains for backward compatibility with TruthLemma.lean

**References**:
- CanonicalConstruction.lean line 20: Explicit acknowledgment of redundancy
- Task 971: Refactor to eliminate bmcs_truth_at layer
- Research: specs/971_refactor_eliminate_bmcs_truth_at_layer/reports/research-001.md
-/
```

**Verification:**
- `lake build` passes
- Archived file exists in Boneyard
- Deprecation notice visible in original

---

### Phase 3: Update TruthLemma.lean Documentation [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Update TruthLemma.lean to document that bmcs_truth_lemma is now a legacy pathway

**Tasks:**
- [ ] Update module header docstring to note deprecation status
- [ ] Add reference to `canonical_truth_lemma` as the modern alternative
- [ ] Document the relationship: bmcs_truth_lemma is equivalent to canonical_truth_lemma + bmcs_truth_at_eq_canonical_truth
- [ ] Keep all proofs intact (they remain mathematically correct)

**Timing:** 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Update docstrings

**Verification:**
- `lake build` passes
- Docstrings clearly indicate deprecation path

---

### Phase 4: Update Metalogic.lean Publication Documentation [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Update the publication-ready theorem list to prioritize canonical_truth_lemma

**Tasks:**
- [ ] Move `canonical_truth_lemma` and `shifted_truth_lemma` to top of publication list
- [ ] Add note that `bmcs_truth_lemma` is preserved for backward compatibility
- [ ] Update references section to point to CanonicalConstruction.lean as primary
- [ ] Verify all listed theorems are still accurate

**Timing:** 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic.lean` - Update publication documentation

**Verification:**
- `lake build` passes
- Documentation reflects streamlined architecture

---

### Phase 5: Archive IntRepresentation to Boneyard [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Ensure IntRepresentation (already in Boneyard) is properly documented

**Tasks:**
- [ ] Verify `Theories/Bimodal/Boneyard/IntRepresentation/Representation.lean` has deprecation header
- [ ] Update its deprecation notice to reference Task 971
- [ ] Remove from lakefile if present (should not be built)
- [ ] Document in Boneyard/README.md

**Timing:** 20 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/IntRepresentation/Representation.lean` - Update deprecation notice
- `Theories/Bimodal/Boneyard/README.md` - Update documentation

**Verification:**
- File has proper deprecation header
- Not included in build

---

### Phase 6: Update Bundle/README.md [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Update Bundle documentation to reflect the streamlined architecture

**Tasks:**
- [ ] Check if `Theories/Bimodal/Metalogic/Bundle/README.md` exists
- [ ] If exists, update to document deprecation of bmcs_truth_at pathway
- [ ] If not exists, create minimal README documenting architecture
- [ ] Document that CanonicalConstruction.lean is now the primary entry point

**Timing:** 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/README.md` - Create or update

**Verification:**
- README accurately reflects current architecture
- Clear guidance for new development

---

### Phase 7: Verify and Final Build [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Final verification that all changes are correct and build passes

**Tasks:**
- [ ] Run `lake clean && lake build` for full rebuild
- [ ] Verify no new sorries introduced
- [ ] Verify all imports still resolve
- [ ] Check grep for any remaining undocumented bmcs_truth_at usage
- [ ] Create implementation summary

**Timing:** 30 minutes

**Files to verify**:
- All modified files from previous phases
- Full project build

**Verification:**
- `lake build` passes with zero errors
- `grep -rn "bmcs_truth_at" Theories/` shows only documented locations
- No new technical debt introduced

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <modified files>` returns empty (zero-debt gate) - N/A, no proofs modified
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms - N/A, no proofs modified
- [ ] All existing proofs remain valid

### General
- [ ] All import statements resolve correctly
- [ ] Deprecation notices are clear and complete
- [ ] Boneyard structure follows existing patterns
- [ ] README documentation is accurate

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `Theories/Bimodal/Boneyard/Task971_BFMCSTruth/BFMCSTruth.lean` - Archived copy
- Updated deprecation headers in:
  - `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean`
  - `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`
- Updated documentation in:
  - `Theories/Bimodal/Metalogic.lean`
  - `Theories/Bimodal/Boneyard/README.md`
  - `Theories/Bimodal/Metalogic/Bundle/README.md`
- `summaries/implementation-summary-{DATE}.md` - Final summary

## Rollback/Contingency

If issues arise:
1. **Import failures**: Restore original import statements from git
2. **Build breakage**: `git checkout` affected files, retry with smaller changes
3. **Boneyard conflicts**: Rename archive directory with unique suffix

All changes are documentation-level (deprecation notices, README updates) with no proof modifications, making rollback straightforward via git restore.
