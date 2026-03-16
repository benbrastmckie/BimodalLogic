# Research Report: Task 970 Phases 5-9 Analysis

**Task**: 970 - Review Metalogic for Publication Readiness
**Report**: research-002-teammate-a-findings.md
**Author**: lean-research-agent (teammate-a)
**Date**: 2026-03-15
**Confidence**: HIGH (verified via grep/file analysis)

## Executive Summary

Phases 1-4 and 10-12 are marked [COMPLETED]. This report analyzes the remaining phases 5-9 to determine exact scope, dependencies, and recommended execution order. The analysis reveals that several items mentioned in the plan have already been partially addressed, reducing the remaining work.

---

## Phase 5: Consolidate Duplicate Theorems [PARTIAL]

### Current State

The plan identifies 3 duplicate theorem bodies between `Completeness.lean` and `Core/MCSProperties.lean`:

| Theorem | Completeness.lean | MCSProperties.lean | Status |
|---------|-------------------|-------------------|--------|
| `set_mcs_all_future_all_future` | Lines 377-394 | Lines 243-260 | **DUPLICATE** |
| `set_mcs_all_past_all_past` | Lines 437-454 | Lines 303-320 | **DUPLICATE** |
| `temp_4_past` | Lines 401-423 | Lines 267-289 | **DUPLICATE** |

### Analysis

**File Comparison**:
- `Completeness.lean` (616 lines): Higher-level module that imports `Core/MCSProperties.lean`
- `Core/MCSProperties.lean` (363 lines): Core infrastructure that is widely imported

**Import Graph**:
- `MCSProperties.lean` is imported by 15+ files (BFMCS, ModalSaturation, TruthLemma, etc.)
- `Completeness.lean` is imported by only 2 files: `StagedExecution.lean`, `ConstructiveFragment.lean`

**Recommendation**: Keep definitions in `Core/MCSProperties.lean` (canonical location), remove from `Completeness.lean`.

### Unique Content in Completeness.lean to Migrate

These theorems exist ONLY in `Completeness.lean` and should be migrated to `Core/MCSProperties.lean`:

| Theorem | Lines | Purpose |
|---------|-------|---------|
| `set_mcs_disjunction_intro` | 62-110 | Disjunction forward |
| `set_mcs_disjunction_elim` | 117-127 | Disjunction backward |
| `set_mcs_disjunction_iff` | 134-137 | Disjunction iff |
| `set_mcs_conjunction_intro` | 145-181 | Conjunction forward |
| `set_mcs_conjunction_elim` | 188-284 | Conjunction backward |
| `set_mcs_conjunction_iff` | 291-294 | Conjunction iff |
| `set_mcs_box_closure` | 315-332 | Modal T property |
| `set_mcs_box_box` | 346-363 | Modal 4 property |
| `set_mcs_neg_box_implies_diamond_neg` | 463-528 | Diamond-box duality fwd |
| `set_mcs_diamond_neg_implies_neg_box` | 535-590 | Diamond-box duality bwd |
| `set_mcs_diamond_box_duality` | 600-603 | Diamond-box duality iff |

**Difficulty**: MEDIUM - Straightforward code movement with import updates
**Risk**: LOW - All files already import MCSProperties

### Tasks Remaining

1. Remove duplicate `set_mcs_all_future_all_future`, `set_mcs_all_past_all_past`, `temp_4_past` from Completeness.lean
2. Migrate unique theorems from Completeness.lean to MCSProperties.lean (11 theorems)
3. Update imports in dependent files
4. Verify `lake build` passes

---

## Phase 6: Unify asDiamond Definitions [PARTIAL]

### Current State

Two `asDiamond` definitions exist:

| Location | Definition | Pattern |
|----------|------------|---------|
| `Bundle/ModalSaturation.lean:70` | `def asDiamond` | `.imp (.box (.imp inner .bot)) .bot => some inner` |
| `Decidability/Tableau.lean:157` | `def asDiamond?` | `.imp (.box (.imp phi .bot)) .bot => some phi` |

### Analysis

**Comparison**:
- Both definitions are **semantically identical** - they match the same pattern: `neg(Box(neg A))` = `Diamond A`
- Only difference is naming: `asDiamond` vs `asDiamond?` (Option-returning convention)

**Usage**:
- `ModalSaturation.lean`: `asDiamond` is defined but **NEVER USED** in the codebase (0 external references)
- `Tableau.lean`: `asDiamond?` is actively used in tableau rule application (4 references within file)

**Recommendation**:
1. **Remove** `asDiamond` from `ModalSaturation.lean` (unused)
2. Keep `asDiamond?` in `Tableau.lean` (active usage)

**Difficulty**: LOW - Simple removal of unused definition
**Risk**: VERY LOW - No external usages

---

## Phase 7: Clean Internal Scaffolding [PARTIAL]

### Current State

The plan identifies `needs_modal_witness` as internal scaffolding:

| Definition | Location | Lines | Usage |
|------------|----------|-------|-------|
| `needs_modal_witness` | `ModalSaturation.lean` | 82-83 | Used ONLY in `is_modally_saturated_iff_no_needs_witness` (lines 101-111) |

### Analysis

**Definition**:
```lean
def needs_modal_witness (B : BFMCS D) (fam : FMCS D) (t : D) (psi : Formula) : Prop :=
  diamondFormula psi ∈ fam.mcs t ∧ ∀ fam' ∈ B.families, psi ∉ fam'.mcs t
```

**Scope**:
- Used exactly once in `is_modally_saturated_iff_no_needs_witness` theorem
- Not exported or used elsewhere in the codebase (0 external references)

**Additional Scaffolding Identified**:
- `diamondFormula` (line 63): Thin alias for `phi.diamond` - also used only internally in ModalSaturation.lean

**Recommendation**:
1. Make `needs_modal_witness` private or move to `where` clause of `is_modally_saturated_iff_no_needs_witness`
2. Remove or privatize `diamondFormula` (thin alias for `phi.diamond`)

**Note**: The plan (Phase 3) mentions `diamondFormula` was supposed to be removed, but it still exists. This may have been missed or deferred.

**Difficulty**: LOW - Scoping changes only
**Risk**: LOW - No external dependencies

---

## Phase 8: Remove Weak/Finite Completeness Variants [PARTIAL]

### Current State

Search for "weak_completeness" and "finite.*completeness" reveals:

| Location | Theorem/Reference | Status |
|----------|-------------------|--------|
| `Representation.lean:12` | `standard_weak_completeness` | **Comment only** (doc reference) |
| `README.md` files | Various mentions | Documentation references |
| `typst/` files | `semantic_weak_completeness` | Documentation for primary completeness theorem |
| `Boneyard/IntRepresentation/` | `standard_weak_completeness` | **ARCHIVED** (boneyard) |
| `StagedConstruction/Completeness.lean:111,179` | `dense_weak_completeness` | **Not implemented** (doc comment only) |

### Analysis

**Key Finding**: There are no active "weak" or "finite" completeness variants in the main codebase that need removal. The situation is:

1. **`semantic_weak_completeness`** in `FMP/SemanticCanonicalModel.lean`: This is the **primary sorry-free completeness theorem** and should be KEPT
2. **`standard_weak_completeness`**: Already archived to Boneyard (hardcoded D=Int approach)
3. **`dense_weak_completeness`**: Only exists as a documentation comment, not implemented

**The "weak" in `semantic_weak_completeness` is a misnomer** - it handles validity (`⊨ φ → ⊢ φ`) which is actually the standard completeness direction. The documentation correctly identifies this as the primary theorem.

**Recommendation**:
1. **No removals needed** - variants are already archived or don't exist
2. Consider renaming `semantic_weak_completeness` to `semantic_completeness` to avoid confusion (optional, low priority)
3. Update documentation to clarify terminology

**Difficulty**: LOW (primarily documentation updates)
**Risk**: VERY LOW

---

## Phase 9: Improve Naming Conventions [PARTIAL]

### Current State

Naming conventions analysis across the metalogic codebase:

| Convention | Current State | Examples |
|------------|---------------|----------|
| Structures | **Consistent** (PascalCase) | `BFMCS`, `FMCS`, `TemporalCoherentFamily`, `SaturatedBFMCS` |
| Definitions/theorems | **Mostly consistent** (snake_case) | `truth_at`, `bmcs_truth_lemma`, `set_mcs_box_closure` |
| Predicates | **Inconsistent** | `is_mcs` vs `SetMaximalConsistent`, `is_modally_saturated` vs `temporally_coherent` |
| Accessors | **Inconsistent** | `FMCS.is_mcs` (returns property), `BFMCS.temporally_coherent` (no `is_` prefix) |

### Identified Inconsistencies

| Current | Should Be | Location |
|---------|-----------|----------|
| `temporally_coherent` | `is_temporally_coherent` | BFMCS.lean (predicate) |
| `SetMaximalConsistent` | `IsSetMaximalConsistent` | Core/MaximalConsistent.lean |
| `SetConsistent` | `IsSetConsistent` | Core/MaximalConsistent.lean |

### Analysis

**Scope Assessment**:
- Renaming `SetMaximalConsistent` and `SetConsistent` would affect 50+ files
- Renaming `temporally_coherent` affects ~10 files

**Recommendation**:
1. **HIGH PRIORITY**: Add deprecation aliases rather than immediate rename (for backward compat)
2. **MEDIUM PRIORITY**: Update new code to use `is_` prefix convention
3. **LOW PRIORITY**: Consider bulk rename in dedicated follow-up task

**Difficulty**: MEDIUM-HIGH (due to widespread usage)
**Risk**: MEDIUM (requires careful deprecation strategy)

---

## Recommended Execution Order

Based on dependencies, difficulty, and risk:

| Order | Phase | Difficulty | Risk | Rationale |
|-------|-------|------------|------|-----------|
| 1 | **Phase 6** | LOW | VERY LOW | Remove unused `asDiamond`, simplest cleanup |
| 2 | **Phase 7** | LOW | LOW | Privatize scaffolding, contained to single file |
| 3 | **Phase 8** | LOW | VERY LOW | Mostly documentation updates, no code removals needed |
| 4 | **Phase 5** | MEDIUM | LOW | Consolidate theorems, requires careful migration |
| 5 | **Phase 9** | MEDIUM-HIGH | MEDIUM | Naming conventions - consider deferring bulk renames |

**Critical Path**: Phases 6, 7, 8 can be done in parallel. Phase 5 should precede Phase 9 to avoid renaming migrated code twice.

---

## Dependencies and Risks

### Dependencies

| Phase | Depends On | Blocks |
|-------|------------|--------|
| Phase 5 | None | Phase 9 |
| Phase 6 | None | None |
| Phase 7 | None | None |
| Phase 8 | None | None |
| Phase 9 | Phase 5 | None |

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Import cycle from theorem migration (Phase 5) | LOW | HIGH | Check import graph before migration |
| Breaking downstream usage (Phase 9 naming) | MEDIUM | MEDIUM | Use deprecation aliases |
| Missing usages in Boneyard (all phases) | LOW | LOW | Grep includes Boneyard in verification |

---

## Key Findings Summary

1. **Phase 5**: 3 duplicate theorems to remove, 11 unique theorems to migrate
2. **Phase 6**: `asDiamond` is unused, can be removed; `asDiamond?` should be kept
3. **Phase 7**: `needs_modal_witness` and `diamondFormula` are internal, can be privatized
4. **Phase 8**: No active weak/finite variants to remove (already archived or doc-only)
5. **Phase 9**: Naming inconsistencies exist but bulk rename should be separate task

---

## Confidence Level

**HIGH** - All findings verified via:
- Direct file reads (Completeness.lean, MCSProperties.lean, ModalSaturation.lean, Tableau.lean)
- Grep searches across Theories/ directory
- Import graph analysis

No MCP search tools were needed for this analysis - codebase inspection was sufficient.
