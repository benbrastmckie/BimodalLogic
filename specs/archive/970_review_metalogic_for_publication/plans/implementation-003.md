# Implementation Plan: Task #970 - Review Metalogic for Publication Readiness (v3)

- **Task**: 970 - Review Metalogic for Publication Readiness
- **Status**: [PLANNED]
- **Effort**: 7 hours (phases 5-9 only; phases 1-4, 10-12 completed in v2)
- **Dependencies**: None
- **Research Inputs**: research-001.md (team research), research-002.md (phases 5-9 + task 971 coordination)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: logic
- **Lean Intent**: true
- **Revision**: v3 (from v2) — Reordered phases 5-9 per research, reduced Phase 9 scope, added Task 971 coordination

## Revision Summary

**Changes from v2:**
1. **Phase Reordering**: 6→7→8→5→9 based on research-002 analysis (simplest first, structural work later)
2. **Phase 7 Expanded**: Must fix missed `diamondFormula` removal from Phase 3
3. **Phase 9 Scope Reduced**: Only rename `temporally_coherent` → `is_temporally_coherent` (~10 files); defer `SetMaximalConsistent`/`SetConsistent` (50+ files) to follow-up task
4. **Task 971 Coordination**: Documented parallel execution strategy; task 971 (full bmcs_truth_at elimination) can proceed immediately
5. **Non-Goal Updated**: Task 971 handles full bmcs_truth_at elimination per research-002 recommendation

## Overview

This plan covers the remaining phases (5-9) of the metalogic publication review. Phases 1-4 and 10-12 were completed in the v2 implementation run.

### Task 970/971 Coordination

Per research-002 analysis, task 970 phases 5-9 and task 971 can execute **in parallel** with minimal overlap:

| Task 970 Phase | Overlaps with 971? | Details |
|----------------|-------------------|---------|
| Phase 5: Consolidate Duplicates | NO | Different files (Completeness.lean, MCSProperties.lean) |
| Phase 6: Unify asDiamond | NO | Different subsystem (ModalSaturation, Tableau) |
| Phase 7: Clean Scaffolding | MINIMAL | Could touch BFMCSTruth.lean indirectly |
| Phase 8: Remove Weak Variants | NO | Different layer |
| Phase 9: Naming Conventions | POSSIBLE | If renaming `bmcs_*` identifiers |

**Task 971 Prerequisites — All Met:**
- Task 970 Phase 4 [COMPLETED] removed unused `bmcs_valid`, `bmcs_satisfiable_at`, `bmcs_satisfies_context`
- Task 970 Phase 11 [COMPLETED] added legacy path markers to `TruthLemma.lean` and `BFMCSTruth.lean`
- No import cycle risks identified

### Semantic Framework

As documented in v2, the bimodal temporal logic TM uses semantics evaluated at **history-time pairs** `(h, t)`, not standard Kripke worlds. Main theorems connect:
- **Derivability**: `Γ ⊢ φ` (syntactic)
- **Logical Consequence**: `Γ ⊨ φ` (semantic — for all models, all history-time pairs satisfying Γ, φ holds)

## Goals & Non-Goals

**Goals (Phases 5-9)**:
- Consolidate duplicate theorem bodies (Phase 5)
- Remove completely unused `asDiamond` definition (Phase 6)
- Clean internal scaffolding including missed `diamondFormula` alias (Phase 7)
- Document weak completeness clarification (Phase 8)
- Rename `temporally_coherent` → `is_temporally_coherent` for consistency (Phase 9)

**Non-Goals**:
- Full elimination of `bmcs_truth_at` layer (handled by Task 971 per research-002)
- Renaming `SetMaximalConsistent`/`SetConsistent` (affects 50+ files; defer to follow-up task)
- Changes to completed phases 1-4, 10-12

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking imports during theorem consolidation | High | Medium | Run `lake build` after each removal, grep for usages first |
| Conflict with task 971 on shared files | Medium | Low | Coordinate on bmcs_* identifiers; task 971 handles BFMCSTruth/TruthLemma |
| Phase 9 naming changes cascade | Medium | Low | Restricted scope to `temporally_coherent` only (~10 files) |
| `diamondFormula` removal breaks downstream | Low | Low | Already verified unused in research-002 |

## Implementation Phases

### Phase 6: Remove Unused asDiamond Definition [NOT STARTED]

- **Dependencies:** None (standalone)
- **Goal:** Remove completely unused `asDiamond` from ModalSaturation.lean
- **Effort:** 10 minutes

Per research-002: `asDiamond` in `ModalSaturation.lean:70` has **0 external references**. `asDiamond?` in `Decidability/Tableau.lean:157` has 4 active references and is the canonical definition.

**Tasks:**
- [ ] Verify zero usage: `grep -rn "asDiamond\b" Theories/Bimodal/Metalogic/ --include="*.lean"`
- [ ] Remove `asDiamond` definition from `ModalSaturation.lean`
- [ ] Verify: `lake build` passes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - remove unused definition

**Verification:**
- `lake build` completes successfully
- Only `asDiamond?` in Tableau.lean remains

---

### Phase 7: Clean Internal Scaffolding + Fix Missed diamondFormula [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Clean up internal scaffolding and remove `diamondFormula` alias (missed in Phase 3)
- **Effort:** 45 minutes

Per research-002: `diamondFormula` was supposed to be removed in Phase 3 but was missed. It is a thin alias for `phi.diamond`.

**Tasks:**
- [ ] **Remove `diamondFormula` alias** (`ModalSaturation.lean:63`):
  - [ ] Grep for all `diamondFormula` usages
  - [ ] Replace each call with `phi.diamond` or equivalent
  - [ ] Remove the `diamondFormula` definition
- [ ] **Make `needs_modal_witness` private** (`ModalSaturation.lean:82-83`):
  - [ ] Verify used only within `is_modally_saturated_iff_no_needs_witness`
  - [ ] Add `private` modifier or move to `where` clause
- [ ] Review any other internal scaffolding identified during phases 3-6
- [ ] Verify: `lake build` passes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - remove alias, privatize scaffolding

**Verification:**
- `lake build` completes successfully
- `grep -n "diamondFormula" Theories/Bimodal/Metalogic/**/*.lean` returns empty
- Public API contains only mathematically meaningful definitions

---

### Phase 8: Document Weak Completeness Clarification [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Clarify that `semantic_weak_completeness` is the correct name and handles validity (`⊨ φ → ⊢ φ`)
- **Effort:** 30 minutes

Per research-002: No active weak/finite completeness variants need removal. The name "weak" in `semantic_weak_completeness` (FMP/SemanticCanonicalModel.lean) is technically correct (validity vs strong completeness with premises). Optional: consider renaming to `semantic_completeness` for clarity.

**Tasks:**
- [ ] Review `semantic_weak_completeness` in `FMP/SemanticCanonicalModel.lean`
- [ ] Add clarifying docstring explaining:
  - "Weak completeness" = validity completeness (`⊨ φ → ⊢ φ`)
  - "Strong completeness" = with premises (`Γ ⊨ φ → Γ ⊢ φ`)
  - This is standard terminology, not an incomplete theorem
- [ ] Verify no other weak/finite variants exist outside Boneyard
- [ ] Verify: `lake build` passes

**Files to modify:**
- `Theories/Bimodal/FMP/SemanticCanonicalModel.lean` - add/update docstring

**Verification:**
- `lake build` completes successfully
- `grep -rn "weak_completeness" Theories/Bimodal/ --include="*.lean" | grep -v Boneyard` shows only documented locations

---

### Phase 5: Consolidate Duplicate Theorems [NOT STARTED]

- **Dependencies:** Phase 8
- **Goal:** Eliminate duplicate theorem bodies by removing copies from `Completeness.lean` and migrating unique content to `MCSProperties.lean`
- **Effort:** 2.5 hours

Per research-002:
- 3 duplicate theorem bodies exist between `Completeness.lean` and `MCSProperties.lean`
- `MCSProperties.lean` is imported by 15+ files; `Completeness.lean` by only 2
- Canonical location is `MCSProperties.lean`

**Duplicates to Remove from Completeness.lean:**

| Theorem | Completeness.lean | MCSProperties.lean | Action |
|---------|-------------------|--------------------|--------|
| `set_mcs_all_future_all_future` | Lines 377-394 | Lines 243-260 | Remove from Completeness.lean |
| `set_mcs_all_past_all_past` | Lines 437-454 | Lines 303-320 | Remove from Completeness.lean |
| `temp_4_past` | Lines 401-423 | Lines 267-289 | Remove from Completeness.lean |

**Unique Content to Migrate to MCSProperties.lean:**
- `set_mcs_disjunction_intro/elim/iff` (3 theorems)
- `set_mcs_conjunction_intro/elim/iff` (3 theorems)
- `set_mcs_box_closure`, `set_mcs_box_box` (2 theorems)
- `set_mcs_neg_box_implies_diamond_neg`, `set_mcs_diamond_neg_implies_neg_box`, `set_mcs_diamond_box_duality` (3 theorems)

**Tasks:**
- [ ] Verify import graph: ensure all files importing `Completeness.lean` also import `MCSProperties.lean`
- [ ] Remove 3 duplicate theorem bodies from `Completeness.lean`
- [ ] Migrate 11 unique theorems from `Completeness.lean` to `MCSProperties.lean`
- [ ] Update imports in dependent files (`StagedExecution.lean`, `ConstructiveFragment.lean`)
- [ ] Consider converting `Completeness.lean` to pure re-export file or deprecation
- [ ] Verify: `lake build` passes

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean` - remove duplicates, migrate content
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - receive migrated content
- `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean` - update imports if needed
- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` - update imports if needed

**Verification:**
- `lake build` completes successfully
- No theorem bodies appear in more than one file
- Import graph remains valid

---

### Phase 9: Rename temporally_coherent (Restricted Scope) [NOT STARTED]

- **Dependencies:** Phase 5, Task 971 completion (for coordination)
- **Goal:** Rename `temporally_coherent` → `is_temporally_coherent` for predicate naming consistency
- **Effort:** 1.5 hours

Per research-002, this phase has **restricted scope** compared to v2:
- **IN SCOPE**: `temporally_coherent` → `is_temporally_coherent` (~10 files)
- **OUT OF SCOPE**: `SetMaximalConsistent` and `SetConsistent` (affects 50+ files; create follow-up task)

**Coordination with Task 971:**
- If Task 971 is completed first: coordinate on any `bmcs_*` identifiers that may have been renamed
- If Task 971 is in progress: avoid modifying `BFMCSTruth.lean` or `TruthLemma.lean` naming

**Tasks:**
- [ ] **Rename `temporally_coherent` → `is_temporally_coherent`**:
  - [ ] `grep -rn "temporally_coherent" Theories/Bimodal/ --include="*.lean"` to identify all locations
  - [ ] Update definition site in `BFMCS.lean` or `TemporalCoherence.lean`
  - [ ] Update all call sites (~10 files expected)
  - [ ] Run `lake build` after each file
- [ ] **Create follow-up task** for `SetMaximalConsistent`/`SetConsistent` rename (50+ files)
- [ ] Document naming conventions in module docstring or README
- [ ] Verify: `lake build` passes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` - update definition
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` - update if definition is here
- Various files across `Theories/Bimodal/Metalogic/` - update call sites (~10 files)

**Verification:**
- `lake build` completes successfully
- `grep -rn "temporally_coherent\b" Theories/Bimodal/ --include="*.lean"` returns only `is_temporally_coherent`
- Follow-up task created for broader naming conventions

---

## Completed Phases (from v2)

### Phase 1: Extract Temporal Coherence Core [COMPLETED]
- Created `Bundle/TemporalCoherence.lean` with `TemporalCoherentFamily`, `temporal_backward_G`, `temporal_backward_H`, `BFMCS.temporally_coherent`, `mcs_double_neg_elim`
- Updated imports in TruthLemma.lean, CanonicalFMCS.lean, CanonicalConstruction.lean, StagedExecution.lean, ConstructiveFragment.lean

### Phase 2: Archive Deprecated File [COMPLETED]
- Moved `TemporalCoherentConstruction.lean` to `Boneyard/Task970/`
- File contained 2 sorries (Int-specialized construction)

### Phase 3: Remove Thin Aliases [COMPLETED]
- Removed `set_mcs_modal_saturation_forward` from Completeness.lean
- **Note**: `diamondFormula` was planned for removal but missed; addressed in Phase 7

### Phase 4: Remove Unused FMCS/BFMCS Convenience Definitions [COMPLETED]
- Removed ~20 unused definitions from FMCSDef.lean, BFMCS.lean, BFMCSTruth.lean

### Phase 10: Audit Main Theorem Formulations [COMPLETED]
- Verified theorem state: soundness, dense completeness, representation
- No changes needed - theorems are in consistent state

### Phase 11: Update Documentation [COMPLETED]
- Updated SORRY_REGISTRY.md: 9 active sorries (down from 46)
- Added legacy path markers to TruthLemma.lean and BFMCSTruth.lean

### Phase 12: Final Verification and Summary [COMPLETED]
- `lake build` passes, 9 active sorries, no custom axioms

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors after each phase
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Boneyard | wc -l` returns 9 or less
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/**/*.lean | grep -v Boneyard` shows no new axioms

### General
- [ ] All removed definitions verified to have zero external usage before removal
- [ ] Import graph remains valid (no circular dependencies introduced)
- [ ] Documentation accurately reflects codebase state
- [ ] Coordination with Task 971 documented

## Artifacts & Outputs

- `specs/970_review_metalogic_for_publication/plans/implementation-003.md` (this file)
- `specs/970_review_metalogic_for_publication/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Updated module docstrings in affected files
- Follow-up task for broader naming conventions (Phase 9)

## Rollback/Contingency

If any phase introduces breaking changes:
1. Use `git stash` or `git checkout` to revert phase changes
2. Mark phase as `[BLOCKED]` with specific blocker description
3. Continue with subsequent phases if they do not depend on blocked phase
4. Report blocked phases in implementation summary

For Phase 5 (consolidation), if migration proves complex:
- Keep duplicates temporarily, add `-- TODO: consolidate` markers
- Defer full migration to follow-up task

For Phase 9 (naming), if cascade effects are discovered:
- Restrict further (only most critical renames)
- Add deprecation aliases instead of hard renames
