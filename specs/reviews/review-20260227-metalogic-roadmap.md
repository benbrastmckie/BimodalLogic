# Code Review Report: Metalogic and Roadmap Alignment

**Date**: 2026-02-27
**Scope**: Metalogic state vs ROAD_MAP.md accuracy
**Reviewed by**: Claude

## Summary

- **Critical issues**: 5 (roadmap significantly out of date with codebase)
- **High priority issues**: 2 (incorrect checkboxes in Ambitions)
- **Medium priority issues**: 3 (documentation structure issues)
- **Low priority issues**: 1 (minor text updates)

This review identifies significant discrepancies between ROAD_MAP.md and the actual codebase state following Task 948 (archive non-standard completeness theorems).

## Critical Issues

### 1. FMP Directory No Longer Exists

**File**: ROAD_MAP.md, Module Architecture section (line ~618-622)
**Description**: ROAD_MAP.md shows `Metalogic/FMP/` as an active directory with sorry-free completeness, but Task 948 archived the entire FMP directory to `Boneyard/Metalogic_v8/FMP/`.
**Impact**: Misleading developers about available completeness paths.
**Recommended fix**: Remove FMP/ from Module Architecture diagram, add note about archival.

### 2. False Claims About Sorry-Free Completeness Paths

**File**: ROAD_MAP.md, Current State section (line ~526-569)
**Description**: States "Two **sorry-free** completeness approaches are available: BFMCS Completeness and FMP Completeness" with detailed tables showing both as SORRY-FREE. In reality:
- Both were archived to Boneyard/Metalogic_v8 by Task 948
- They used non-standard validity definitions (`bmcs_valid`, `fmp_valid`)
- Standard completeness (`standard_weak_completeness`) is now sorry-DEPENDENT
**Impact**: Major confusion about actual proof status.
**Recommended fix**: Rewrite Current State section to reflect post-Task-948 reality.

### 3. Import Statements Reference Archived Modules

**File**: ROAD_MAP.md, multiple locations
**Description**: Shows import examples like:
```lean
import Bimodal.Metalogic.Bundle.Completeness
import Bimodal.Metalogic.FMP.SemanticCanonicalModel
```
These modules no longer exist in active codebase.
**Impact**: Developers following these instructions will get import errors.
**Recommended fix**: Update to show `import Bimodal.Metalogic.Representation` for standard completeness.

### 4. Sorry Debt Status Table Incomplete

**File**: ROAD_MAP.md, Sorry Debt Status section (line ~582-596)
**Description**: Describes sorries as "in Int-indexed construction infrastructure" and claims "main completeness theorems are **fully sorry-free**". Post-Task-948:
- Standard completeness theorems ARE sorry-dependent
- The archived bmcs/fmp completeness were sorry-free but non-standard
**Impact**: Misrepresents current sorry situation.
**Recommended fix**: Update to state that standard completeness is sorry-dependent and explain why.

### 5. Phase 0.3 Decidability Section References Deprecated FMP

**File**: ROAD_MAP.md, Phase 0.3 (line ~708-712)
**Description**: States "New approach: Parametric FMP infrastructure in `Metalogic/FMP/` provides finite model construction."
**Impact**: Points to non-existent directory.
**Recommended fix**: Update to note FMP was archived; decidability is via Decidability/ module (unrelated to FMP).

## High Priority Issues

### 6. Ambitions Section Has Wrong Checkboxes

**File**: ROAD_MAP.md, Proof Economy ambition (line ~263-278)
**Description**: Contains:
```markdown
- [x] FMP completeness sorry-free
- [x] No blocking sorries on main theorem paths (FMP path is clear)
```
Both are incorrect post-Task-948.
**Impact**: Misleads about project progress.
**Recommended fix**: Update to:
```markdown
- [ ] Standard completeness sorry-free (3 sorries remain in upstream construction)
- [ ] FMP completeness sorry-free *(archived to Boneyard, non-standard validity)*
```

### 7. Publication-Ready Ambition Has Stale Checkbox

**File**: ROAD_MAP.md, Publication-Ready Metalogic ambition (line ~171)
**Description**: Shows `- [ ] Soundness proven (currently axiomatized)` but soundness IS proven and sorry-free.
**Impact**: Underreports progress.
**Recommended fix**: Change to `- [x] Soundness proven *(Completed: Task 909+, 2026-02-19)*`

## Medium Priority Issues

### 8. Strategy Section Doesn't Reflect Task 948 Outcome

**File**: ROAD_MAP.md, Strategies section
**Description**: No strategy explicitly documents the decision to archive non-standard completeness and pursue standard completeness. Task 948 represents a major strategic decision that should be recorded.
**Impact**: Loss of institutional memory.
**Recommended fix**: Add new concluded strategy documenting the standard vs non-standard validity decision.

### 9. Dead Ends Section Missing Task 948 Decision

**File**: ROAD_MAP.md, Dead Ends section
**Description**: Should include entry for "Non-Standard Validity Completeness" documenting why bmcs_valid/fmp_valid were abandoned.
**Impact**: Incomplete historical record.
**Recommended fix**: Add Dead End entry referencing Task 948.

### 10. Historical Archived Approaches Section Incomplete

**File**: ROAD_MAP.md, Historical: Archived Approaches (line ~645-677)
**Description**: Doesn't mention Metalogic_v8 (Task 948 archival of Bundle/Completeness and FMP/).
**Impact**: Incomplete archive documentation.
**Recommended fix**: Add Metalogic_v8 entry.

## Low Priority Issues

### 11. Alternative Compactness Note Outdated

**File**: ROAD_MAP.md, Compactness section (line ~671)
**Description**: States "For sorry-free completeness, use `fmp_weak_completeness` or `bmcs_weak_completeness`" but both are archived.
**Impact**: Minor confusion.
**Recommended fix**: Update to reference standard completeness or note that sorry-free completeness paths are now archived.

---

## Code Quality Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Active sorry count (Metalogic/) | 3 | OK |
| Build status | Pass (741 jobs) | OK |
| FMP directory exists | No (archived) | Issue |
| ROAD_MAP.md accuracy | ~40% outdated | Critical |

## Roadmap Context

### Active Strategies

| Strategy | Status | Notes |
|----------|--------|-------|
| Representation-First Architecture | CONCLUDED | Core approach validated |
| Two-Chain Coherence | CONCLUDED | Cross-origin gaps accepted |
| Algebraic Verification Path | PAUSED | Partial implementation |

### Outstanding Ambition Criteria (HIGH priority)

From "Publication-Ready Metalogic" ambition:
- [ ] Full documentation with tutorials
- [ ] Paper draft or technical report

From "Proof Economy" ambition:
- [ ] Bundle completeness sorry-free (3 sorries remain)

## Current Actual Metalogic State (Post-Task-948)

### SORRY-FREE Results

| Theorem | Module | Notes |
|---------|--------|-------|
| `soundness` | Soundness.lean | All 15 TM axioms + 7 rules |
| `decide` | Decidability/DecisionProcedure.lean | Tableau-based |
| `bmcs_truth_lemma` | Bundle/TruthLemma.lean | MCS ↔ BFMCS truth |
| `canonical_truth_lemma` | Bundle/CanonicalConstruction.lean | MCS ↔ standard truth_at |

### SORRY-DEPENDENT Results

| Theorem | Module | Dependency |
|---------|--------|------------|
| `standard_weak_completeness` | Representation.lean | fully_saturated_bfmcs_exists_int |
| `standard_strong_completeness` | Representation.lean | fully_saturated_bfmcs_exists_int |

### ARCHIVED (Boneyard/Metalogic_v8)

| Theorem | Reason | Task |
|---------|--------|------|
| `bmcs_weak_completeness` | Non-standard validity (bmcs_valid) | 948 |
| `bmcs_strong_completeness` | Non-standard validity (bmcs_valid) | 948 |
| `fmp_weak_completeness` | Non-standard validity (fmp_valid) | 948 |

### Active Sorries (3)

1. `fully_saturated_bfmcs_exists_int` - TemporalCoherentConstruction.lean:600
2. `buildDovetailingChainFamily_forward_F` - DovetailingChain.lean:1869
3. `buildDovetailingChainFamily_backward_P` - DovetailingChain.lean:1881

---

## Recommendations

### Priority 1: Update Current State Section

Completely rewrite the "Current State: What's Been Accomplished" section to reflect:
1. Soundness is SORRY-FREE
2. Decidability is SORRY-FREE
3. Standard completeness (Representation.lean) is SORRY-DEPENDENT
4. Non-standard completeness was archived (Task 948)

### Priority 2: Fix Ambitions Checkboxes

Update the Proof Economy and Publication-Ready ambitions with accurate completion status.

### Priority 3: Add Task 948 to Strategic Record

Create either:
- New strategy entry: "Standard Validity Alignment"
- New dead end entry: "Non-Standard Validity Completeness"

### Priority 4: Update Module Architecture

Remove FMP/ from the active module diagram and add Metalogic_v8 to Historical Archived Approaches.

---

## Changelog Entry (if review warrants)

Review found 5 critical issues requiring ROAD_MAP.md updates. Task 948 archival not reflected.
