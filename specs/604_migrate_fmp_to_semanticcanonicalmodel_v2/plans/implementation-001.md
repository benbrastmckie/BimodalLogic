# Implementation Plan: Task #604

- **Task**: 604 - Migrate FMP to SemanticCanonicalModel_v2
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Priority**: High
- **Dependencies**: Task 597 (SemanticCanonicalModel_v2 infrastructure)
- **Research Inputs**: specs/604_migrate_fmp_to_semanticcanonicalmodel_v2/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Migrate FiniteModelProperty.lean from using old `Bimodal.Metalogic.Completeness.FiniteCanonicalModel` to the new v2 infrastructure in `Bimodal.Metalogic_v2.Representation`. Research confirmed ContextProvability.lean requires no changes (already v2-compatible). The migration requires porting 6 definitions across 3 v2 target files, with one definition (`semantic_truth_implies_truth_at`) containing a sorry in the original code.

### Research Integration

Integrated findings from research-001.md:
- ContextProvability.lean is already clean (no migration needed)
- 6 definitions need porting from old FiniteCanonicalModel
- `semantic_truth_implies_truth_at` has a sorry in old code - will preserve as sorry
- Naming change: `self_mem_closure` -> `phi_mem_closure` (use existing v2 name)

## Goals & Non-Goals

**Goals**:
- Port all required definitions from old FiniteCanonicalModel to v2 infrastructure
- Remove `import Bimodal.Metalogic.Completeness.FiniteCanonicalModel` from FiniteModelProperty.lean
- Enable full independence of Metalogic_v2 from old Bimodal/Metalogic/ directory
- Maintain existing functionality (tests pass, `lake build` succeeds)

**Non-Goals**:
- Proving `semantic_truth_implies_truth_at` (has sorry in original - accept as technical debt)
- Refactoring the FMP proof structure itself
- Modifying ContextProvability.lean (already v2-compatible)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `semantic_truth_implies_truth_at` sorry propagates to FMP | High | Certain | Document as known limitation; FMP already depends on this sorry |
| Missing auxiliary lemmas not identified in research | Medium | Low | Search old FiniteCanonicalModel for transitive dependencies if errors arise |
| Namespace conflicts during migration | Medium | Low | Port definitions incrementally, verify build after each phase |
| Type signature mismatches between old and v2 | Medium | Medium | Use `lean_hover_info` to compare signatures; adapt as needed |

## Implementation Phases

### Phase 1: Port Trivial Definitions [NOT STARTED]

**Goal**: Add simple definitions to v2 infrastructure files with minimal complexity

**Tasks**:
- [ ] Add `closureSize` to `Closure.lean` (simple cardinality definition)
- [ ] Add `FiniteWorldState.ext` extensionality lemma to `FiniteWorldState.lean`
- [ ] Add `FiniteWorldState.mem_toSet_iff` membership characterization to `FiniteWorldState.lean`
- [ ] Add `phi_consistent_of_not_refutable` to `Core/MaximalConsistent.lean`
- [ ] Verify `lake build` passes after additions

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean` - add `closureSize`
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteWorldState.lean` - add `ext`, `mem_toSet_iff`
- `Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean` - add `phi_consistent_of_not_refutable`

**Verification**:
- `lake build Bimodal.Metalogic_v2.Representation.Closure` succeeds
- `lake build Bimodal.Metalogic_v2.Representation.FiniteWorldState` succeeds
- `lake build Bimodal.Metalogic_v2.Core.MaximalConsistent` succeeds

---

### Phase 2: Port Medium Complexity Definitions [NOT STARTED]

**Goal**: Add `semanticWorldState_finite` instance and `semantic_world_state_has_world_history` theorem

**Tasks**:
- [ ] Port `semanticWorldState_finite` instance to `SemanticCanonicalModel.lean`
  - Uses `Finite.of_injective` via `toFiniteWorldState` injection
- [ ] Port `semantic_world_state_has_world_history` theorem to `SemanticCanonicalModel.lean`
  - Uses `finite_history_from_state` and `finiteHistoryToWorldHistory` (already in v2)
- [ ] Verify `lake build` passes after additions

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - add both definitions

**Verification**:
- `lake build Bimodal.Metalogic_v2.Representation.SemanticCanonicalModel` succeeds
- `#check semanticWorldState_finite` shows `Finite (SemanticWorldState phi)`
- `#check semantic_world_state_has_world_history` shows correct type signature

---

### Phase 3: Port Complex Definition with Sorry [NOT STARTED]

**Goal**: Port `semantic_truth_implies_truth_at` preserving the existing sorry

**Tasks**:
- [ ] Read old `semantic_truth_implies_truth_at` from `FiniteCanonicalModel.lean`
- [ ] Adapt statement to v2 types (`SemanticWorldState`, `SemanticCanonicalModel`)
- [ ] Port the proof structure, preserving `sorry` where it exists in original
- [ ] Add documentation comment noting the sorry is inherited from old code
- [ ] Verify `lake build` passes

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - add `semantic_truth_implies_truth_at`

**Verification**:
- `lake build Bimodal.Metalogic_v2.Representation.SemanticCanonicalModel` succeeds
- `#check semantic_truth_implies_truth_at` shows correct type signature
- Warning appears for sorry (expected, matches old code)

---

### Phase 4: Migrate FiniteModelProperty.lean [NOT STARTED]

**Goal**: Update FiniteModelProperty.lean to use v2 infrastructure exclusively

**Tasks**:
- [ ] Remove import: `import Bimodal.Metalogic.Completeness.FiniteCanonicalModel`
- [ ] Update open statements from `Bimodal.Metalogic.Completeness` to `Bimodal.Metalogic_v2.Representation`
- [ ] Change `self_mem_closure` references to `phi_mem_closure`
- [ ] Fix any remaining namespace/name mismatches
- [ ] Verify `lake build Bimodal.Metalogic_v2.Representation.FiniteModelProperty` succeeds
- [ ] Verify full `lake build` succeeds

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean`
  - Line 9: Remove old import
  - Lines 301-302: Update open statements
  - Line 439: Change `self_mem_closure` to `phi_mem_closure`
  - Various lines: Namespace qualification updates as needed

**Verification**:
- `lake build` succeeds with no errors
- `grep -r "Bimodal.Metalogic.Completeness" Theories/Bimodal/Metalogic_v2/` returns no matches
- FiniteModelProperty theorems remain accessible (`#check finite_model_property_constructive`)

---

## Testing & Validation

- [ ] `lake build` completes successfully
- [ ] No new sorries introduced (only preserved existing one)
- [ ] All Metalogic_v2 imports are self-contained (no old Metalogic/ dependencies)
- [ ] `#check finite_model_property_constructive` works in FiniteModelProperty.lean
- [ ] `grep` confirms no remaining imports from `Bimodal.Metalogic.Completeness` in v2 files

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- Modified files:
  - `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean`
  - `Theories/Bimodal/Metalogic_v2/Representation/FiniteWorldState.lean`
  - `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean`
  - `Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean`
  - `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean`
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If migration causes unexpected issues:
1. Use `git stash` to preserve changes
2. Restore original FiniteModelProperty.lean from git history
3. Investigate specific failing definition
4. Port problematic definitions with alternative approach or additional sorry
5. Re-apply migration incrementally

For persistent issues with `semantic_truth_implies_truth_at`:
- Document as known technical debt
- Create follow-up task to prove this lemma properly
- FMP can proceed with sorry (matches current behavior)
