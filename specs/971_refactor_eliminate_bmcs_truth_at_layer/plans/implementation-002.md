# Implementation Plan: Task #971 - Eliminate bmcs_truth_at Layer (Revised)

- **Task**: 971 - Refactor to eliminate bmcs_truth_at layer
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None (self-contained refactor)
- **Research Inputs**:
  - specs/971_refactor_eliminate_bmcs_truth_at_layer/reports/research-001.md (initial analysis)
  - specs/971_refactor_eliminate_bmcs_truth_at_layer/reports/research-002.md (systematic simplifications)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: logic
- **Lean Intent**: true
- **Supersedes**: plans/implementation-001.md (conservative bridge approach)

## Overview

Aggressive clean-break refactor to fully eliminate the `bmcs_truth_at` layer from the metalogic codebase. Unlike implementation-001.md which recommended deriving `bmcs_truth_lemma` as a corollary (bridge approach), this revised plan follows the user's directive: **directly use `canonical_truth_lemma` everywhere, eliminating `bmcs_truth_lemma` entirely**.

The research (especially research-002.md) confirms that `bmcs_truth_lemma` has NO non-deprecated code usage outside its own module, making full elimination straightforward. This approach removes technical debt permanently rather than wrapping it.

### Research Integration

Key findings from both research reports:

**From research-001.md**:
- `bmcs_truth_at` is documented as structurally redundant (CanonicalConstruction.lean line 20)
- Two parallel truth lemma paths exist: Path A (legacy via bmcs_truth_at) and Path B (modern via canonical_truth_lemma)
- Only BFMCSTruth.lean and TruthLemma.lean actively use `bmcs_truth_at`

**From research-002.md** (primary):
- `bmcs_truth_lemma` has NO non-deprecated code usage outside its module - the "bridge" approach would create a dependency that doesn't exist
- Generic `D` type parameter is vestigial - all completeness code uses `D = Int`
- 7 simplification opportunities identified; this plan addresses all of them
- Full elimination is worth the extra effort vs bridge approach

## Goals & Non-Goals

**Goals**:
- **Complete elimination** of `bmcs_truth_at` layer (not deprecation, not bridging)
- Archive `BFMCSTruth.lean` and `TruthLemma.lean` to Boneyard/ (bulk move)
- Remove all imports referencing these files from active codebase
- Update `Metalogic.lean` to export only `canonical_truth_lemma` and `shifted_truth_lemma`
- Clean, minimal proof architecture for publication
- Zero compatibility shims or deprecation markers in active code
- Ensure `lake build` passes after each phase

**Non-Goals**:
- Preserving backward compatibility for `bmcs_truth_lemma` or `bmcs_truth_at`
- Deriving `bmcs_truth_lemma` as a corollary (this was the conservative approach in implementation-001.md)
- Modifying `CanonicalConstruction.lean` proofs (already the target architecture)
- Specializing generic `D` to `Int` throughout BFMCS (noted for future but out of scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hidden dependency on TruthLemma.lean | HIGH | LOW | Grep for imports before archiving; research found none outside deprecated code |
| Missing essential corollary after elimination | MEDIUM | LOW | Check usage of each corollary; research says most are unused |
| Import cycle after file moves | MEDIUM | LOW | Remove imports rather than redirect; CanonicalConstruction.lean is the new entry point |
| Build breakage from bulk deletion | MEDIUM | MEDIUM | Incremental verification with lake build at each phase |

## Sorry Characterization

### Pre-existing Sorries
- None identified in BFMCSTruth.lean or TruthLemma.lean (these are completed proofs)
- CanonicalConstruction.lean is already sorry-free

### Expected Resolution
- N/A - no sorries to resolve; this is a file organization/elimination task

### New Sorries
- None. This refactor involves file deletion and import cleanup, not new proof work.
- If any proof work is unexpectedly required, mark phase `[BLOCKED]` with `requires_user_review: true`.

### Remaining Debt
- After this implementation: 0 sorries introduced
- Proof architecture simplified (single truth lemma path)

## Implementation Phases

### Phase 1: Audit Dependencies and Establish Baseline [COMPLETED]

**Progress:**

**Session: 2026-03-16, sess_1773640383_94ce8f**
- Verified: `lake build` passes (baseline established)
- Audited: TruthLemma.lean imported by 3 active files (Metalogic.lean, CanonicalConstruction.lean, Completeness.lean)
- Audited: BFMCSTruth.lean imported by only TruthLemma.lean in active code
- Confirmed: No unexpected dependencies - matches research findings exactly

- **Dependencies:** None
- **Goal:** Verify all dependency assumptions from research and establish clean baseline

**Tasks:**
- [ ] Run `lake build` to confirm baseline compiles
- [ ] Grep for `import.*TruthLemma` to identify all importers
- [ ] Grep for `import.*BFMCSTruth` to identify all importers
- [ ] Grep for `bmcs_truth_lemma` usage (expect: only TruthLemma.lean and deprecated files)
- [ ] Grep for `bmcs_truth_at` usage (expect: only BFMCSTruth.lean, TruthLemma.lean, deprecated files)
- [ ] Document any unexpected dependencies that would block elimination
- [ ] If blockers found: mark phase `[BLOCKED]` with review_reason

**Timing:** 30 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic/Bundle/*.lean` - Core files
- `Theories/Bimodal/Metalogic.lean` - Publication entry point
- `Theories/Bimodal/Boneyard/**/*.lean` - Deprecated files (expected to reference, OK to ignore)

**Verification:**
- `lake build` passes (baseline)
- Documented dependency list matches research findings
- No unexpected active dependencies on bmcs_truth_at/bmcs_truth_lemma

---

### Phase 2: Archive BFMCSTruth.lean to Boneyard [COMPLETED]

**Progress:**

**Session: 2026-03-16, sess_1773640383_94ce8f**
- Created: Boneyard/Task971/ directory
- Moved: BFMCSTruth.lean to Boneyard/Task971/ with archive header
- Updated: Boneyard/README.md with Task 971 archive record

- **Dependencies:** Phase 1
- **Goal:** Move BFMCSTruth.lean to Boneyard in bulk (no shims, no deprecation in place)

**Tasks:**
- [ ] Create `Theories/Bimodal/Boneyard/Task971/` directory
- [ ] Move (not copy) `BFMCSTruth.lean` to `Boneyard/Task971/BFMCSTruth.lean`
- [ ] Add archive header to moved file documenting Task 971 context
- [ ] Remove `import Bimodal.Metalogic.Bundle.BFMCSTruth` from TruthLemma.lean temporarily (will break build)
- [ ] Document in Boneyard/README.md: "Task 971: BFMCSTruth.lean - bmcs_truth_at layer eliminated"

**Archive Header Content (for moved file)**:
```lean
/-!
# BFMCSTruth [ARCHIVED - Task 971]

This file has been archived as part of Task 971: eliminate bmcs_truth_at layer.

The `bmcs_truth_at` predicate was structurally redundant with `truth_at` when
canonical constructions are used. The `canonical_truth_lemma` in
`CanonicalConstruction.lean` provides the same semantics without indirection.

**Why Archived**: Clean-break elimination, not deprecation. No compatibility shims.
**Successor**: Use `canonical_truth_lemma` from `CanonicalConstruction.lean`
**Date**: 2026-03-15
-/
```

**Timing:** 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` - DELETE (move to Boneyard)
- `Theories/Bimodal/Boneyard/Task971/BFMCSTruth.lean` - CREATE
- `Theories/Bimodal/Boneyard/README.md` - UPDATE

**Verification:**
- File moved to Boneyard
- Original location no longer contains BFMCSTruth.lean
- Build will fail (expected - TruthLemma.lean references removed import)

---

### Phase 3: Archive TruthLemma.lean to Boneyard [COMPLETED]

**Progress:**

**Session: 2026-03-16, sess_1773640383_94ce8f**
- Moved: TruthLemma.lean to Boneyard/Task971/ with archive header
- Removed: `import Bimodal.Metalogic.Bundle.TruthLemma` from CanonicalConstruction.lean, Metalogic.lean, Completeness.lean
- Added: `neg_imp_implies_antecedent` and `neg_imp_implies_neg_consequent` helper definitions to CanonicalConstruction.lean
- Added: imports for DeductionTheorem and Propositional to CanonicalConstruction.lean
- Verified: `lake build` passes

- **Dependencies:** Phase 2
- **Goal:** Move TruthLemma.lean to Boneyard in bulk (completing layer elimination)

**Tasks:**
- [ ] Move (not copy) `TruthLemma.lean` to `Boneyard/Task971/TruthLemma.lean`
- [ ] Add archive header to moved file documenting Task 971 context
- [ ] Remove `import Bimodal.Metalogic.Bundle.TruthLemma` from CanonicalConstruction.lean
- [ ] Remove `import Bimodal.Metalogic.Bundle.TruthLemma` from any other files identified in Phase 1
- [ ] Update Boneyard/README.md: add TruthLemma.lean entry

**Archive Header Content (for moved file)**:
```lean
/-!
# TruthLemma [ARCHIVED - Task 971]

This file has been archived as part of Task 971: eliminate bmcs_truth_at layer.

The `bmcs_truth_lemma` proved here was rendered redundant by `canonical_truth_lemma`
in `CanonicalConstruction.lean`, which proves the same result directly at the
`truth_at` level without the intermediate `bmcs_truth_at` predicate.

**Why Archived**: Full elimination per research-002.md recommendation
**Successor**: Use `canonical_truth_lemma` from `CanonicalConstruction.lean`
**Date**: 2026-03-15
-/
```

**Timing:** 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - DELETE (move to Boneyard)
- `Theories/Bimodal/Boneyard/Task971/TruthLemma.lean` - CREATE
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - REMOVE import
- `Theories/Bimodal/Boneyard/README.md` - UPDATE

**Verification:**
- Both files archived in Boneyard/Task971/
- No TruthLemma.lean in active Bundle/ directory
- Run `lake build` - should now pass (if CanonicalConstruction.lean didn't depend on TruthLemma exports)

---

### Phase 4: Fix CanonicalConstruction.lean Dependencies (If Needed) [COMPLETED]

**Progress:**

**Session: 2026-03-16, sess_1773640383_94ce8f**
- Dependencies resolved in Phase 3 (helper functions ported)
- No additional corollaries needed - `bmcs_eval_truth`, `bmcs_eval_mcs`, `bmcs_box_iff_all_true` confirmed unused by active code per research
- `lake build` passes

- **Dependencies:** Phase 3
- **Goal:** Resolve any missing definitions that CanonicalConstruction.lean imported from TruthLemma.lean

**Tasks:**
- [ ] Run `lake build` and identify any errors in CanonicalConstruction.lean
- [ ] If errors exist: identify which definitions were imported from TruthLemma.lean
- [ ] For each missing definition, determine if:
  - (a) It can be derived directly from `canonical_truth_lemma` or standard Kripke semantics -> add to CanonicalConstruction.lean
  - (b) It is unused by any non-archived code -> skip, it's already in Boneyard
  - (c) It requires substantial proof work -> mark `[BLOCKED]` with requires_user_review
- [ ] Add any essential corollaries directly to CanonicalConstruction.lean (research suggests minimal or none needed)
- [ ] Run `lake build` to verify fix

**Potential Corollaries to Port** (from research-002.md Finding 5.6):
- `bmcs_eval_truth` - Check if used; if so, derive from `canonical_truth_lemma`
- `bmcs_eval_mcs` - Check if used; if so, derive from `canonical_truth_lemma`
- `bmcs_box_iff_all_true` - Check if used; if so, derive from `canonical_truth_lemma`

**Timing:** 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - ADD corollaries if needed

**Verification:**
- `lake build` passes
- No missing definitions
- Any added corollaries are derived from `canonical_truth_lemma` (not bmcs_truth_lemma)

---

### Phase 5: Update Metalogic.lean Publication Exports [COMPLETED]

**Progress:**

**Session: 2026-03-16, sess_1773640383_94ce8f**
- Removed: `import Bimodal.Metalogic.Bundle.TruthLemma`
- Updated: Publication-ready theorem list (bmcs_truth_lemma -> canonical_truth_lemma)
- Updated: Submodule description (truth lemma -> canonical truth lemma)
- Updated: References section (TruthLemma.lean -> CanonicalConstruction.lean)

- **Dependencies:** Phase 4
- **Goal:** Clean up the publication entry point to reflect streamlined architecture

**Tasks:**
- [ ] Remove `import Bimodal.Metalogic.Bundle.TruthLemma` if present
- [ ] Remove `import Bimodal.Metalogic.Bundle.BFMCSTruth` if present
- [ ] Update module docstring to reflect single truth lemma path:
  - Primary: `canonical_truth_lemma`
  - Shift-closed variant: `shifted_truth_lemma`
  - Remove any references to `bmcs_truth_lemma`
- [ ] Verify exports reference CanonicalConstruction.lean as the primary source
- [ ] Run `lake build`

**Timing:** 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic.lean` - UPDATE imports and docstring

**Verification:**
- `lake build` passes
- Metalogic.lean no longer references bmcs_truth_lemma
- Publication-ready theorem list shows canonical_truth_lemma and shifted_truth_lemma only

---

### Phase 6: Update StagedConstruction/Completeness.lean Documentation [COMPLETED]

**Progress:**

**Session: 2026-03-16, sess_1773640383_94ce8f**
- Removed: `import Bimodal.Metalogic.Bundle.TruthLemma`
- Added: `import Bimodal.Metalogic.Bundle.CanonicalConstruction`
- Updated: Architecture pipeline description (BFMCS + CanonicalConstruction)
- Updated: Zero-Sorry Status (canonical_truth_lemma, shifted_truth_lemma)
- Updated: References section (TruthLemma.lean -> CanonicalConstruction.lean)
- Updated: Key Infrastructure Summary (bmcs_truth_lemma -> canonical_truth_lemma)
- Verified: `lake build` passes

- **Dependencies:** Phase 5
- **Goal:** Update completeness pipeline documentation to reflect single path

**Tasks:**
- [ ] Remove references to "Path A (legacy via bmcs_truth_at)" from docstrings
- [ ] Update pipeline diagram to show only the canonical_truth_lemma path
- [ ] Remove any imports referencing archived files
- [ ] Update references to point to CanonicalConstruction.lean
- [ ] Run `lake build`

**Timing:** 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean` - UPDATE docstrings

**Verification:**
- `lake build` passes
- Documentation reflects streamlined architecture
- No references to bmcs_truth_at or bmcs_truth_lemma

---

### Phase 7: Clean Up Bundle/README.md and Documentation [COMPLETED]

**Progress:**

**Session: 2026-03-16, sess_1773640383_94ce8f**
- Rewrote: Bundle/README.md to reflect Task 971 architecture
- Removed: All references to BFMCSTruth.lean and TruthLemma.lean
- Added: Task 971 Architecture Simplification section
- Updated: Main theorems table (canonical_truth_lemma, shifted_truth_lemma)
- Updated: Usage examples to reference CanonicalConstruction.lean

- **Dependencies:** Phase 6
- **Goal:** Update all documentation to reflect the clean architecture

**Tasks:**
- [ ] Check if `Theories/Bimodal/Metalogic/Bundle/README.md` exists
- [ ] If exists: Remove examples using bmcs_truth_at
- [ ] If exists: Update to point to CanonicalConstruction.lean as primary entry point
- [ ] If not exists: Create minimal README documenting the Bundle structure
- [ ] Search for any other Markdown files referencing bmcs_truth_at and update
- [ ] Update Boneyard/README.md with complete Task 971 archive record

**Timing:** 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/README.md` - CREATE or UPDATE
- `Theories/Bimodal/Boneyard/README.md` - UPDATE (final Task 971 record)

**Verification:**
- All documentation references canonical_truth_lemma
- No documentation references bmcs_truth_at (except Boneyard archive notes)
- Clear guidance for future development

---

### Phase 8: Final Verification and Build [COMPLETED]

**Progress:**

**Session: 2026-03-16, sess_1773640383_94ce8f**
- Verified: `lake build` passes with zero errors
- Verified: BFMCSTruth.lean and TruthLemma.lean removed from Bundle/
- Verified: 14 .lean files remain in Bundle/ (down from 16)
- Verified: Only docstring references to bmcs_truth_at remain (explaining elimination)
- Verified: No bmcs_truth_lemma in active code
- Verified: All imports updated to use CanonicalConstruction.lean

- **Dependencies:** Phase 7
- **Goal:** Complete verification that elimination is successful

**Tasks:**
- [ ] Run `lake clean && lake build` for full rebuild
- [ ] Verify no sorries introduced: `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/`
- [ ] Verify no new axioms: `grep -rn "^axiom " Theories/Bimodal/Metalogic/`
- [ ] Verify bmcs_truth_at fully eliminated from active code:
  - `grep -rn "bmcs_truth_at" Theories/Bimodal/Metalogic/` should return only Boneyard references
  - `grep -rn "bmcs_truth_lemma" Theories/Bimodal/Metalogic/` should return only Boneyard references
- [ ] Verify import graph is clean (no imports from archived files)
- [ ] Create implementation summary

**Timing:** 30 minutes

**Files to verify**:
- All modified files from previous phases
- Full Theories/Bimodal/ directory

**Verification:**
- `lake build` passes with zero errors
- `grep -rn "bmcs_truth_at" Theories/Bimodal/Metalogic/Bundle/` returns empty
- `grep -rn "bmcs_truth_lemma" Theories/Bimodal/Metalogic/Bundle/` returns empty
- No new sorries or axioms
- Clean, publication-ready architecture

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/` returns empty (zero-debt gate)
- [ ] `grep -rn "^axiom " Theories/Bimodal/Metalogic/Bundle/` shows no new axioms
- [ ] All imports resolve correctly (no dangling references)

### General
- [ ] bmcs_truth_at fully removed from active code (only in Boneyard)
- [ ] bmcs_truth_lemma fully removed from active code (only in Boneyard)
- [ ] canonical_truth_lemma and shifted_truth_lemma are the only truth lemmas exported
- [ ] Documentation accurately reflects streamlined architecture
- [ ] Boneyard archive includes complete context for future reference

## Artifacts & Outputs

### Plan Artifacts
- `plans/implementation-002.md` (this file)
- `summaries/implementation-summary-{DATE}.md` - Final summary

### Code Changes
- **Deleted from active**: `Bundle/BFMCSTruth.lean`, `Bundle/TruthLemma.lean`
- **Created in Boneyard**: `Boneyard/Task971/BFMCSTruth.lean`, `Boneyard/Task971/TruthLemma.lean`
- **Modified**: `Metalogic.lean`, `CanonicalConstruction.lean`, `StagedConstruction/Completeness.lean`
- **Documentation**: `Bundle/README.md`, `Boneyard/README.md`

### Architecture After Implementation

```
Theories/Bimodal/Metalogic/
├── Metalogic.lean              # Publication entry point (exports canonical_truth_lemma)
├── Bundle/
│   ├── CanonicalConstruction.lean  # PRIMARY: canonical_truth_lemma, shifted_truth_lemma
│   ├── BFMCS.lean                  # Bundle definition (unchanged)
│   ├── FMCS.lean                   # Family definition (unchanged)
│   └── README.md                   # Updated documentation
├── StagedConstruction/
│   └── Completeness.lean           # Pipeline docs (updated)
└── Boneyard/
    └── Task971/
        ├── BFMCSTruth.lean         # ARCHIVED
        └── TruthLemma.lean         # ARCHIVED
```

## Rollback/Contingency

If issues arise that require reverting:

1. **Git restore**: All changes are tracked in git; `git checkout` affected files
2. **Boneyard restore**: Files archived to Boneyard can be moved back if unexpectedly needed
3. **Import restore**: Original import statements preserved in git history

**Key rollback commands**:
```bash
# Restore deleted files from git
git checkout HEAD~1 -- Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean
git checkout HEAD~1 -- Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean

# Or restore from Boneyard
mv Theories/Bimodal/Boneyard/Task971/BFMCSTruth.lean Theories/Bimodal/Metalogic/Bundle/
mv Theories/Bimodal/Boneyard/Task971/TruthLemma.lean Theories/Bimodal/Metalogic/Bundle/
```

## Comparison: Implementation-001.md vs Implementation-002.md

| Aspect | Implementation-001.md (Conservative) | Implementation-002.md (This Plan) |
|--------|--------------------------------------|-----------------------------------|
| Approach | Bridge derivation, deprecation notices | Full elimination, clean break |
| Files Modified | 3-4 (add deprecation headers) | 5-6 (delete + archive) |
| Files Archived | 0 | 2 (BFMCSTruth.lean, TruthLemma.lean) |
| Compatibility | Backward compatible | No compatibility shims |
| Complexity Reduction | Medium | High |
| Future Maintenance | Still have two paths | Single path |
| Publication Readiness | Improved | Maximized |
| Effort | 3.5 hours | 5 hours |
