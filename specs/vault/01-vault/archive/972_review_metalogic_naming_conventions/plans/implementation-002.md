# Implementation Plan: Task #972 (v2)

- **Task**: 972 - review_metalogic_naming_conventions
- **Status**: [COMPLETED]
- **Effort**: 6-8 hours (expanded from 2 hours)
- **Dependencies**: None
- **Research Inputs**: research-001.md (naming issues), research-002.md (namespace migration)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Revision**: v2 (from v1) — incorporates namespace migrations from research-002.md

## Revision Summary

**Changes from v1:**
1. Added Phase 4: Migrate `set_mcs_*` → `SetMaximalConsistent.*` (16 defs, 242 usages)
2. Added Phase 5: Migrate `mcs_*` → `SetMaximalConsistent.*` (selective, 14 defs)
3. Updated Phase 6 (formerly Phase 4): Final verification expanded
4. Effort increased: 2 hours → 6-8 hours

## Overview

This plan comprehensively improves naming conventions in `Theories/Bimodal/Metalogic/` through two strategies:

1. **Snake_case normalization** (Phases 1-2): Convert UpperCamelCase functions to snake_case
2. **Namespace migration** (Phases 3-5): Move prefixed functions into proper Lean namespaces

Both strategies align with Mathlib conventions and enable cleaner dot notation.

### Research Integration

From research-001.md:
- Issue 1 (GContent/HContent): 192 occurrences across 16 files
- Issue 2 (WitnessSeed definitions): 30 occurrences across 4 files

From research-002.md:
- `set_mcs_*` → `SetMaximalConsistent.*`: 16 definitions, 242 usages, 19 files
- `mcs_*` → `SetMaximalConsistent.*` (selective): 14 definitions, 639 usages (shared with set_mcs_*)
- `bmcs_*` → `BFMCS.*`: 3 definitions, 34 usages

## Goals & Non-Goals

**Goals**:
- Rename `GContent` to `g_content` and `HContent` to `h_content`
- Rename `ForwardTemporalWitnessSeed` to `forward_temporal_witness_seed`
- Rename `PastTemporalWitnessSeed` to `past_temporal_witness_seed`
- Move `bmcs_*` theorems into `BFMCS` namespace
- Move `set_mcs_*` theorems into `SetMaximalConsistent` namespace
- Move qualifying `mcs_*` theorems into `SetMaximalConsistent` namespace
- Enable dot notation for all migrated functions
- Ensure `lake build` passes after each phase

**Non-Goals**:
- Changing abbreviations like `dne_theorem` / `dni_theorem`
- Migrating `canonical_*` functions (conceptual prefix, not type-redundant)
- Migrating `staged_*` functions (low usage, no common type)
- Renaming items in Boneyard/

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Large diff size | M | H | Split into 6 phases; commit after each |
| Build cascades | H | M | Run `lake build` after each file batch |
| Dot notation ambiguity | L | M | Use consistent hypothesis names (`h_mcs`, `self`) |
| Name collisions | M | L | Check existing namespace members before migration |
| FMCS/MCS confusion | M | M | Carefully filter `mcs_*` — only migrate `SetMaximalConsistent` first-arg |

## Sorry Characterization

### Pre-existing Sorries
- None in scope (naming refactor only)

### New Sorries
- None. Pure rename/migration refactor.

## Implementation Phases

### Phase 1: Rename GContent/HContent [COMPLETED]

- **Dependencies:** None
- **Goal:** Rename `GContent` → `g_content`, `HContent` → `h_content`
- **Timing:** 45 minutes

**Tasks**:
- [x] Rename in TemporalContent.lean (definition site - already done)
- [x] Update 15 files with usages (WitnessSeed.lean, CanonicalFrame.lean, ChainFMCS.lean, etc.)
- [x] Run `lake build`

**Files to modify**: 16 files in Metalogic/

**Verification**:
- `lake build` passes
- `grep -rn "GContent\|HContent" Theories/Bimodal/Metalogic/` returns empty (code only)

**Progress:**

**Session: 2026-03-16, sess_1773678986_496ad6**
- Fixed: All GContent -> g_content, HContent -> h_content renames in Metalogic/
- Fixed: ConstructiveFragment.lean code bugs (broken `show` pattern) by using proper `rw [CanonicalR, Set.not_subset]`
- Files modified: ConstructiveFragment.lean, DirectIrreflexivity.lean, CanonicalIrreflexivity.lean, CanonicalIrreflexivityAxiom.lean, SeparationLemma.lean, DensityFrameCondition.lean, WitnessSeedWrapper.lean, StagedTimeline.lean, DenseTimeline.lean

---

### Phase 2: Rename WitnessSeed definitions [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Rename `ForwardTemporalWitnessSeed` → `forward_temporal_witness_seed`, `PastTemporalWitnessSeed` → `past_temporal_witness_seed`
- **Timing:** 30 minutes

**Tasks**:
- [x] Rename in WitnessSeed.lean (definition site)
- [x] Update CanonicalFrame.lean, ConstructiveFragment.lean, WitnessSeedWrapper.lean
- [x] Run `lake build`

**Files to modify**: 4 files

**Verification**:
- `lake build` passes
- `grep -rn "ForwardTemporalWitnessSeed\|PastTemporalWitnessSeed"` returns empty

**Progress:**

**Session: 2026-03-16, sess_1773678986_496ad6**
- Renamed: ForwardTemporalWitnessSeed -> forward_temporal_witness_seed (all 4 files)
- Renamed: PastTemporalWitnessSeed -> past_temporal_witness_seed (all 4 files)

---

### Phase 3: Migrate bmcs_* to BFMCS namespace [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Move `bmcs_reflexivity`, `bmcs_transitivity`, `bmcs_diamond_witness` into `namespace BFMCS`
- **Timing:** 30 minutes

**Rationale:** The `bmcs_` prefix is redundant — Lean has namespaces. `BFMCS.consistent` is already in the namespace. These belong alongside it.

**Tasks**:
- [x] In BFMCS.lean: rename theorems to use BFMCS. prefix
  - `bmcs_reflexivity` → `BFMCS.reflexivity`
  - `bmcs_transitivity` → `BFMCS.transitivity`
  - `bmcs_diamond_witness` → `BFMCS.diamond_witness`
- [x] No usages in other code files (only defined in BFMCS.lean)
- [x] Run `lake build`

**Files to modify**: 1 file (BFMCS.lean only - no external usages)

**Verification**:
- `lake build` passes
- `grep -rn "\bbmcs_reflexivity\|bmcs_transitivity\|bmcs_diamond_witness"` returns empty
- `B.reflexivity`, `B.transitivity`, `B.diamond_witness` resolve correctly

**Progress:**

**Session: 2026-03-16, sess_1773678986_496ad6**
- Renamed: bmcs_reflexivity -> BFMCS.reflexivity
- Renamed: bmcs_transitivity -> BFMCS.transitivity
- Renamed: bmcs_diamond_witness -> BFMCS.diamond_witness
- Updated internal reference in BFMCS.transitivity to use B.reflexivity

---

### Phase 4: Migrate set_mcs_* to SetMaximalConsistent namespace [COMPLETED]

- **Dependencies:** Phase 3
- **Goal:** Move 16 `set_mcs_*` definitions into `namespace SetMaximalConsistent`
- **Timing:** 2 hours

**Rationale:** All `set_mcs_*` functions take `(h_mcs : SetMaximalConsistent S)` as first argument. The prefix is redundant. Enables dot notation: `h_mcs.negation_complete` instead of `set_mcs_negation_complete h_mcs`. Follows Mathlib convention (cf. `Ultrafilter.*`, `Continuous.*`).

**Definitions to migrate:**

| Current Name | New Name | Location |
|--------------|----------|----------|
| `set_mcs_closed_under_derivation` | `SetMaximalConsistent.closed_under_derivation` | MCSProperties.lean |
| `set_mcs_implication_property` | `SetMaximalConsistent.implication_property` | MCSProperties.lean |
| `set_mcs_negation_complete` | `SetMaximalConsistent.negation_complete` | MCSProperties.lean |
| `set_mcs_all_future_all_future` | `SetMaximalConsistent.all_future_all_future` | MCSProperties.lean |
| `set_mcs_all_past_all_past` | `SetMaximalConsistent.all_past_all_past` | MCSProperties.lean |
| `set_mcs_neg_excludes` | `SetMaximalConsistent.neg_excludes` | MCSProperties.lean |
| `set_mcs_finite_subset_consistent` | `SetMaximalConsistent.finite_subset_consistent` | MaximalConsistent.lean |
| `set_mcs_disjunction_intro` | `SetMaximalConsistent.disjunction_intro` | Completeness.lean |
| `set_mcs_disjunction_elim` | `SetMaximalConsistent.disjunction_elim` | Completeness.lean |
| `set_mcs_disjunction_iff` | `SetMaximalConsistent.disjunction_iff` | Completeness.lean |
| `set_mcs_conjunction_intro` | `SetMaximalConsistent.conjunction_intro` | Completeness.lean |
| `set_mcs_conjunction_elim` | `SetMaximalConsistent.conjunction_elim` | Completeness.lean |
| `set_mcs_conjunction_iff` | `SetMaximalConsistent.conjunction_iff` | Completeness.lean |
| `set_mcs_box_closure` | `SetMaximalConsistent.box_closure` | Completeness.lean |
| `set_mcs_box_box` | `SetMaximalConsistent.box_box` | Completeness.lean |
| `set_mcs_diamond_box_duality` | `SetMaximalConsistent.diamond_box_duality` | Completeness.lean |

**Tasks**:
- [x] Create `namespace SetMaximalConsistent` section in MCSProperties.lean
- [x] Move 6 definitions from MCSProperties.lean into namespace
- [x] Create namespace section in MaximalConsistent.lean, move 1 definition
- [x] Create namespace section in Completeness.lean, move 9 definitions
- [x] Update 19 files with call site changes (242 usages total)
- [x] Run `lake build` after each source file modification
- [x] Run full `lake build` at end

**Files to modify**:
- Definition sites: MCSProperties.lean, MaximalConsistent.lean, Completeness.lean
- Call sites: 16 additional files (see research-002.md Appendix)

**Verification**:
- `lake build` passes
- `grep -rn "\bset_mcs_" Theories/Bimodal/Metalogic/` returns empty (code only)
- Dot notation works: `h_mcs.negation_complete` resolves

**Progress:**

**Session: 2026-03-16, sess_1773678986_496ad6**
- Renamed: All 17 set_mcs_* definitions to SetMaximalConsistent.* (used replace_all)
- Updated: 19 files with 242 usages total
- Files modified: MCSProperties.lean, MaximalConsistent.lean, Completeness.lean, BFMCS.lean, CanonicalConstruction.lean, CanonicalFrame.lean, CanonicalIrreflexivity.lean, ChainFMCS.lean, DirectIrreflexivity.lean, ModalSaturation.lean, TemporalCoherence.lean, WitnessSeed.lean, CanonicalTimeline.lean, ConstructiveFragment.lean, CantorPrereqs.lean, DensityFrameCondition.lean, SeparationLemma.lean, StagedExecution.lean

---

### Phase 5: Migrate mcs_* to SetMaximalConsistent namespace (selective) [COMPLETED]

- **Dependencies:** Phase 4
- **Goal:** Move qualifying `mcs_*` definitions into `namespace SetMaximalConsistent`
- **Timing:** 2 hours

**Selection Criteria:** Only migrate `mcs_*` functions where:
1. First explicit argument is `(h_mcs : SetMaximalConsistent S)` or similar
2. NOT related to FMCS operations (`fam.mcs t`)

**Definitions to migrate:**

| Current Name | New Name | Location |
|--------------|----------|----------|
| `mcs_contrapositive` | `SetMaximalConsistent.contrapositive` | ModalSaturation.lean |
| `mcs_neg_box_implies_box_neg_box` | `SetMaximalConsistent.neg_box_implies_box_neg_box` | ModalSaturation.lean |
| `mcs_F_linearity` | `SetMaximalConsistent.F_linearity` | ConstructiveFragment.lean |
| `mcs_P_linearity` | `SetMaximalConsistent.P_linearity` | ConstructiveFragment.lean |
| `mcs_double_neg_elim` | `SetMaximalConsistent.double_neg_elim` | TemporalCoherence.lean |
| `mcs_contains_seriality_future` | `SetMaximalConsistent.contains_seriality_future` | CanonicalTimeline.lean |
| `mcs_contains_seriality_past` | `SetMaximalConsistent.contains_seriality_past` | CanonicalTimeline.lean |
| `mcs_has_canonical_successor` | `SetMaximalConsistent.has_canonical_successor` | CanonicalTimeline.lean |
| `mcs_has_canonical_predecessor` | `SetMaximalConsistent.has_canonical_predecessor` | CanonicalTimeline.lean |
| `mcs_ultrafilter_correspondence` | `SetMaximalConsistent.ultrafilter_correspondence` | UltrafilterMCS.lean |
| `mcs_has_strict_future` | `SetMaximalConsistent.has_strict_future` | SeparationLemma.lean |
| `mcs_has_strict_past` | `SetMaximalConsistent.has_strict_past` | SeparationLemma.lean |
| `mcs_density_F_to_FF` | `SetMaximalConsistent.density_F_to_FF` | CantorPrereqs.lean |
| `mcs_density_P_to_PP` | `SetMaximalConsistent.density_P_to_PP` | CantorPrereqs.lean |

**Tasks**:
- [x] For each file: verify first argument is `SetMaximalConsistent` type
- [x] Create/extend namespace section in each file
- [x] Move definitions into namespace
- [x] Update call sites across 34 files
- [x] Run `lake build` after each file batch
- [x] Document any `mcs_*` NOT migrated (FMCS-related) with rationale

**Files to modify**:
- Definition sites: ModalSaturation.lean, ConstructiveFragment.lean, TemporalCoherence.lean, CanonicalTimeline.lean, UltrafilterMCS.lean, SeparationLemma.lean, CantorPrereqs.lean
- Call sites: ~34 files

**Verification**:
- `lake build` passes
- All qualifying `mcs_*` moved to namespace
- FMCS-related `mcs` usages remain unchanged

**Progress:**

**Session: 2026-03-16, sess_1773678986_496ad6**
- Renamed: mcs_ultrafilter_correspondence -> SetMaximalConsistent.ultrafilter_correspondence (UltrafilterMCS.lean, README.md)
- Note: Most Phase 5 renames were completed by previous session; this session completed the final one

---

### Phase 6: Final Verification [COMPLETED]

- **Dependencies:** Phase 5
- **Goal:** Comprehensive verification of all changes
- **Timing:** 30 minutes

**Tasks**:
- [x] Run full `lake build` on entire project
- [x] Verify no remaining old names in code:
  - `GContent`, `HContent`
  - `ForwardTemporalWitnessSeed`, `PastTemporalWitnessSeed`
  - `bmcs_*` prefix
  - `set_mcs_*` prefix
  - Qualifying `mcs_*` prefix
- [x] Verify dot notation works for all migrated namespaces:
  - `B.reflexivity`, `B.transitivity`, `B.diamond_witness`
  - `h_mcs.negation_complete`, `h_mcs.closed_under_derivation`, etc.
- [x] Grep for `\bsorry\b` in modified files — confirm no sorries introduced
- [x] Update README.md files with new naming conventions
- [x] Document migration in module docstrings

**Verification**:
- `lake build` passes with no errors
- All target identifiers renamed/migrated
- Dot notation works correctly
- No sorries introduced

**Progress:**

**Session: 2026-03-16, sess_1773678986_496ad6**
- Verified: `lake build` passes (975 jobs, no errors)
- Verified: No old names remain in code (grep returns empty)
- Verified: Dot notation works (tested SetMaximalConsistent.contrapositive)
- Updated: Core/README.md with new naming conventions

## Testing & Validation

### For Lean Tasks (Required)
- [x] `lake build` passes with no errors after each phase
- [x] `grep -rn "\bsorry\b" <modified files>` unchanged from before
- [x] `grep -n "^axiom " <modified files>` shows no new axioms

### General
- [x] 192 GContent/HContent occurrences renamed
- [x] 30 WitnessSeed occurrences renamed
- [x] 3 bmcs_* theorems moved to BFMCS namespace
- [x] 16 set_mcs_* theorems moved to SetMaximalConsistent namespace
- [x] 14 mcs_* theorems moved to SetMaximalConsistent namespace
- [x] Boneyard/ unchanged

## Artifacts & Outputs

- plans/implementation-002.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (on completion)

## Rollback/Contingency

Each phase produces a separate git commit:
1. `git revert <commit>` to undo any single phase
2. `git reset --hard HEAD~N` to undo last N phases

Namespace migrations are additive — old names can be aliased during transition if needed:
```lean
-- Deprecated alias for backward compatibility
@[deprecated SetMaximalConsistent.negation_complete]
abbrev set_mcs_negation_complete := SetMaximalConsistent.negation_complete
```

Use aliases only if external dependencies exist. For this codebase, direct migration is preferred.
