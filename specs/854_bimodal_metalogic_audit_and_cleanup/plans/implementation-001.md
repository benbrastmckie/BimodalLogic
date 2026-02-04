# Implementation Plan: Task #854

- **Task**: 854 - Bimodal metalogic audit and cleanup
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None (FMP line is already sorry-free and axiom-free)
- **Research Inputs**: reports/research-001.md, reports/research-004.md, reports/research-005.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan focuses exclusively on improving the FMP completeness line (`fmp_weak_completeness` -> `decidability`) to publication quality standards. Per research-005.md, this line is CONFIRMED sorry-free and axiom-free (uses only standard Lean axioms: propext, Classical.choice, Quot.sound). The work is documentation and organization cleanup: removing historical/WIP comments, adding clear explanatory docstrings, ensuring clean code structure with no cruft or rabbit trails.

The FMP line consists of 4 core files plus 8 decidability files. We will NOT touch Bundle/ or other metalogic paths to avoid regressions.

### Research Integration

From research-004.md and research-005.md:
- `fmp_weak_completeness` is transitively sorry-free and axiom-free
- The isolated sorry in `Closure.lean` (line 728) is UNUSED by `fmp_weak_completeness`
- The FMP approach is completely independent of Bundle/ axioms
- Decidability is also sorry-free
- `diamond_in_closureWithNeg_of_box` (Closure.lean:719-728) can be archived to Boneyard

## Goals & Non-Goals

**Goals**:
- Clean documentation: remove historical comments, WIP notes, task references
- Professional docstrings: clear, explanatory, no jargon about past attempts
- Organized structure: no cruft, dead code, or rabbit trails
- Publication-ready comments: suitable for academic publication
- Archive dead code: move unused theorems to Boneyard

**Non-Goals**:
- Modifying Bundle/ approach (out of scope per user request)
- Proving new theorems or fixing sorries (none needed - line is clean)
- Restructuring module hierarchy (cosmetic renaming not worth risk)
- Adding new functionality

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Accidental removal of used code | H | L | Run `lake build` after each file edit |
| Comment edits break compilation | L | L | Comments are syntactically independent |
| Build cache invalidation slows work | M | M | Make focused edits, build incrementally |

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry in `Closure.lean` at line 728: `diamond_in_closureWithNeg_of_box`

### Expected Resolution
- Phase 1 archives this unused theorem to Boneyard (not a dependency of `fmp_weak_completeness`)

### New Sorries
- None. This is documentation cleanup, not theorem proving.

### Remaining Debt
After this implementation:
- 0 sorries in FMP completeness dependency chain (was already 0)
- No downstream impact (sorry was isolated and unused)

## Implementation Phases

### Phase 1: Archive dead code and audit FMP/Closure.lean [NOT STARTED]

**Goal**: Remove unused sorry and clean up Closure.lean documentation

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/Metalogic_FMP_orphans/` directory
- [ ] Move `diamond_in_closureWithNeg_of_box` (lines 719-728) to `Boneyard/Metalogic_FMP_orphans/Closure_orphans.lean` with explanation
- [ ] Remove task references (Task 825, etc.) from Closure.lean docstrings
- [ ] Update module docstring: remove "Known Issue" section (no longer relevant after archival)
- [ ] Ensure docstrings explain mathematical concepts, not development history
- [ ] Verify `lake build Bimodal.Metalogic.FMP.Closure` succeeds

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/Closure.lean` - Remove dead theorem, clean docstrings
- Create `Theories/Bimodal/Boneyard/Metalogic_FMP_orphans/Closure_orphans.lean` (new)

**Verification**:
- `lake build Bimodal.Metalogic.FMP.Closure` succeeds
- `grep -r "diamond_in_closureWithNeg_of_box" Theories/Bimodal/Metalogic/` returns no matches in non-Boneyard files

---

### Phase 2: Clean FMP/BoundedTime.lean documentation [NOT STARTED]

**Goal**: Ensure BoundedTime has publication-quality documentation

**Tasks**:
- [ ] Audit docstrings for clarity and professionalism
- [ ] Remove any task references or historical notes
- [ ] Ensure mathematical concepts are clearly explained
- [ ] Verify definitions are well-documented (BoundedTime, origin, succ/pred operations)
- [ ] Run `lake build Bimodal.Metalogic.FMP.BoundedTime` to verify

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/BoundedTime.lean` - Clean docstrings

**Verification**:
- No task numbers or WIP comments in file
- `lake build` succeeds

---

### Phase 3: Clean FMP/FiniteWorldState.lean documentation [NOT STARTED]

**Goal**: Publication-quality documentation for finite world state construction

**Tasks**:
- [ ] Audit module docstring for clarity (currently good, verify)
- [ ] Ensure key theorems have clear docstrings explaining their role
- [ ] Verify `worldStateFromClosureMCS` and related functions are well-documented
- [ ] Remove any references to boneyard or archived code
- [ ] Verify cross-reference comments are accurate and helpful
- [ ] Run `lake build Bimodal.Metalogic.FMP.FiniteWorldState` to verify

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` - Clean docstrings

**Verification**:
- No task references in docstrings
- Build succeeds

---

### Phase 4: Clean FMP/SemanticCanonicalModel.lean documentation [NOT STARTED]

**Goal**: Publication-quality documentation for the main completeness theorem

**Tasks**:
- [ ] Review module docstring (currently good structure)
- [ ] Remove task references (Task 776, Task 750) from header
- [ ] Update "Archived Code" section to be more professional (no task numbers)
- [ ] Ensure `fmp_weak_completeness` theorem has clear, publication-ready docstring
- [ ] Verify `semanticWorldState_card_bound` (FMP cardinality bound) is well-documented
- [ ] Clean intermediate lemmas' docstrings
- [ ] Run `lake build Bimodal.Metalogic.FMP.SemanticCanonicalModel` to verify

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Clean docstrings

**Verification**:
- No task references in file
- Build succeeds

---

### Phase 5: Audit Decidability module documentation [NOT STARTED]

**Goal**: Clean decidability module chain for publication quality

**Tasks**:
- [ ] Audit `Decidability/DecisionProcedure.lean` - main entry point, ensure clear docs
- [ ] Audit `Decidability/Tableau.lean` - tableau construction documentation
- [ ] Audit `Decidability/Closure.lean` - closure operations documentation
- [ ] Audit `Decidability/Correctness.lean` - soundness/completeness of tableau
- [ ] Audit `Decidability/Saturation.lean` - saturation conditions
- [ ] Audit `Decidability/ProofExtraction.lean` - proof term extraction
- [ ] Audit `Decidability/CountermodelExtraction.lean` - countermodel construction
- [ ] Audit `Decidability/SignedFormula.lean` - signed formula infrastructure
- [ ] Remove any task references or WIP comments from all files
- [ ] Run `lake build Bimodal.Metalogic.Decidability` to verify

**Timing**: 90 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/*.lean` - All 8 files

**Verification**:
- No task references in any decidability file
- Build succeeds for entire Decidability module

---

### Phase 6: Create FMP module README and final verification [NOT STARTED]

**Goal**: Add clear documentation summarizing the FMP completeness approach

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/FMP/README.md` summarizing:
  - Purpose: sorry-free, axiom-free completeness via finite model property
  - Main theorem: `fmp_weak_completeness`
  - Cardinality bound: `semanticWorldState_card_bound`
  - Module structure and dependencies
  - Publication claims that can be made
- [ ] Run full build: `lake build` to verify no regressions
- [ ] Verify FMP line is still sorry-free: `grep -r "sorry" Theories/Bimodal/Metalogic/FMP/`
- [ ] Verify FMP line has no custom axioms: `grep -r "^axiom" Theories/Bimodal/Metalogic/FMP/`

**Timing**: 45 minutes

**Files to create**:
- `Theories/Bimodal/Metalogic/FMP/README.md` (new)

**Verification**:
- README accurately describes the module
- `lake build` succeeds with no errors
- `grep` confirms 0 sorries in FMP (after archiving dead code)
- `grep` confirms 0 custom axioms in FMP

## Testing & Validation

- [ ] Each phase: `lake build` succeeds for modified module
- [ ] Final: Full `lake build` with no errors
- [ ] FMP sorry count = 0 (after archiving `diamond_in_closureWithNeg_of_box`)
- [ ] FMP custom axiom count = 0
- [ ] No task references (Task NNN) in any FMP or Decidability file

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/Metalogic_FMP_orphans/Closure_orphans.lean` - Archived dead code
- `Theories/Bimodal/Metalogic/FMP/README.md` - Module documentation
- Cleaned docstrings in all 12 files (4 FMP + 8 Decidability)
- `specs/854_bimodal_metalogic_audit_and_cleanup/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If any phase breaks the build:
1. Use `git diff` to identify problematic changes
2. Revert specific edits with `git checkout` on affected files
3. Re-run `lake build` to confirm recovery
4. Document issue and proceed more carefully

All changes are documentation/comment edits (low risk) or moving dead code to Boneyard (reversible).
