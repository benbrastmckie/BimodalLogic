# Implementation Plan: Task #542

- **Task**: 542 - Fix CanonicalModel Foundation (Phase 1 of 540)
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/542_fix_canonical_model_foundation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Fix `Representation/CanonicalModel.lean` to compile by replacing broken definitions with working patterns from `Completeness.lean`. The file currently has 21 compilation errors from outdated Mathlib APIs, incorrect Formula constructors (`past`/`future` should be `all_past`/`all_future`), and invalid type operations (`.toList` on Set). Research identified working definitions (`SetConsistent`, `SetMaximalConsistent`, `set_lindenbaum`) that can be directly reused.

### Research Integration

From research-001.md:
- Working definitions exist in Completeness.lean (lines 129-1413)
- Use `zorn_subset_nonempty` from Mathlib (not `zorn_nonempty_partial_order`)
- Formula constructors are `all_past`/`all_future` (not `past`/`future`)
- Use `Formula.neg φ` for negation (not Prop `¬φ`)
- 21 errors categorized: invalid .toList (4), wrong Zorn API (1), wrong constructors (4), type mismatches (3), unknown identifiers (3), missing match alternatives (4)

## Goals & Non-Goals

**Goals**:
- Fix all 21 compilation errors in CanonicalModel.lean
- Reuse proven working patterns from Completeness.lean
- Maintain proper module structure for Task 543 (TruthLemma) to build upon
- Zero compilation errors after implementation

**Non-Goals**:
- Implement TruthLemma (Task 543)
- Prove new theorems beyond what's needed for compilation
- Refactor Completeness.lean (separate concern)
- Add subformula closure (not needed for MCS definition)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import cycles with Completeness.lean | Medium | Medium | Copy definitions instead of importing; can refactor to shared module later |
| Lean build issues after changes | Medium | Low | Use lean_diagnostic_messages after each phase to verify |
| Missing match alternatives | Low | Low | Use Lean exhaustiveness checker to identify all needed cases |
| Lindenbaum lemma complexity | High | Medium | Copy working `set_lindenbaum` verbatim from Completeness.lean |

## Implementation Phases

### Phase 1: Fix Imports and Core Definitions [COMPLETED]

**Goal**: Replace broken MCS definitions with working versions from Completeness.lean

**Tasks**:
- [ ] Open CanonicalModel.lean and review current broken structure
- [ ] Copy `SetConsistent` definition from Completeness.lean (line 129)
- [ ] Copy `SetMaximalConsistent` definition from Completeness.lean (line 136)
- [ ] Copy `ConsistentExtensions` definition from Completeness.lean (line 142)
- [ ] Replace or update `MaximalConsistentSet` structure to use `SetMaximalConsistent`
- [ ] Remove invalid `.toList` calls and `.subformula_closure` field
- [ ] Run lean_diagnostic_messages to verify progress

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CanonicalModel.lean` - Replace core definitions

**Verification**:
- No errors related to SetConsistent/SetMaximalConsistent/toList

---

### Phase 2: Fix Lindenbaum's Lemma [COMPLETED]

**Goal**: Replace broken Lindenbaum implementation with working `set_lindenbaum` pattern

**Tasks**:
- [ ] Copy supporting lemmas from Completeness.lean:
  - `consistent_chain_union` (if needed)
  - `self_mem_consistent_supersets`
- [ ] Copy working `set_lindenbaum` theorem (lines 360-409)
- [ ] Adapt to use correct Mathlib APIs:
  - `zorn_subset_nonempty` (not `zorn_nonempty_partial_order`)
  - `IsChain (· ⊆ ·) C` (not `C.chain`)
  - `Set.subset_sUnion_of_mem` (not `subset_union`)
- [ ] Remove references to invalid identifiers (`exists_mem_of_mem_union`)
- [ ] Run lean_diagnostic_messages to verify

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CanonicalModel.lean` - Fix Lindenbaum lemma

**Verification**:
- No errors related to Zorn's lemma or chain operations
- Lindenbaum lemma compiles without sorry

---

### Phase 3: Fix Formula Constructor Usage [COMPLETED]

**Goal**: Update all Formula pattern matches to use correct constructors

**Tasks**:
- [ ] Replace `past` with `all_past` in all pattern matches
- [ ] Replace `future` with `all_future` in all pattern matches
- [ ] Replace `□φ` notation issues with `Formula.box φ`
- [ ] Add missing match alternatives for `all_past` and `all_future`
- [ ] Update any `canonicalTruthAt` or similar functions with complete matches
- [ ] Run lean_diagnostic_messages to verify

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CanonicalModel.lean` - Fix pattern matches

**Verification**:
- No errors about missing alternatives or unknown constructors
- All match statements are exhaustive

---

### Phase 4: Fix Type Mismatches [COMPLETED]

**Goal**: Fix negation and other type issues

**Tasks**:
- [ ] Replace Prop negation `¬φ` with `Formula.neg φ` throughout
- [ ] Fix any `contains_or_neg` theorem to use correct Formula negation
- [ ] Fix valuation type issues (if present)
- [ ] Ensure MCS properties use correct types
- [ ] Run lean_diagnostic_messages to verify zero errors

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CanonicalModel.lean` - Fix type mismatches

**Verification**:
- No type mismatch errors
- Zero total compilation errors

---

### Phase 5: Final Verification and Cleanup [COMPLETED]

**Goal**: Ensure clean compilation and proper module structure

**Tasks**:
- [ ] Run full `lake build Bimodal.Metalogic.Representation.CanonicalModel`
- [ ] Verify zero errors with lean_diagnostic_messages
- [ ] Check that exports are properly available for Task 543
- [ ] Remove any temporary comments or debug code
- [ ] Verify module imports are minimal and correct

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CanonicalModel.lean` - Cleanup

**Verification**:
- `lake build` succeeds for the module
- Zero diagnostic errors
- Module ready for TruthLemma.lean to import

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Representation.CanonicalModel` succeeds
- [ ] lean_diagnostic_messages returns zero errors for the file
- [ ] All definitions are non-sorry (or have explicit sorry markers for Task 543)
- [ ] MaximalConsistentSet/CanonicalWorldState properly defined
- [ ] Lindenbaum lemma available for use

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Representation/CanonicalModel.lean` - Fixed implementation
- `specs/542_fix_canonical_model_foundation/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation introduces regressions:
1. Revert to git HEAD for CanonicalModel.lean
2. Consider alternative approach: import definitions from Completeness.lean via shared module
3. If import cycles are unavoidable, create new shared file `Theories/Bimodal/Metalogic/Core/MCSDefinitions.lean`
