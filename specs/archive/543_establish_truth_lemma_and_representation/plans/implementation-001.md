# Implementation Plan: Task #543

- **Task**: 543 - Establish TruthLemma and Representation (Phase 2 of 540)
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Priority**: High
- **Dependencies**: 542 (completed)
- **Research Inputs**: specs/543_establish_truth_lemma_and_representation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Fix TruthLemma.lean compilation errors (24 errors due to missing types, incorrect constructor names) and adapt RepresentationTheorem.lean to use working patterns from CanonicalModel.lean. The research report identifies that TruthLemma.lean uses undefined types (`CanonicalWorld`, `canonicalTruthAt`) and incorrect Formula constructors (`past`/`future` instead of `all_past`/`all_future`).

### Research Integration

- TruthLemma.lean has 24 compilation errors from missing types and incorrect constructor names
- CanonicalModel.lean already has correct definitions: `CanonicalWorldState`, MCS properties
- RepresentationTheorem.lean references broken definitions from TruthLemma.lean
- Completeness.lean contains proven MCS lemmas that can be imported

## Goals & Non-Goals

**Goals**:
- Fix all 24 compilation errors in TruthLemma.lean
- Define `canonicalTruthAt` connecting semantic truth to MCS membership
- Update RepresentationTheorem.lean to use correct Lindenbaum and MCS lemma names
- Achieve zero compilation errors in the Representation/ module

**Non-Goals**:
- Proving the full truth lemma induction (mark with sorry if needed)
- Optimizing proof performance
- Extending beyond the Representation/ module scope

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Type mismatches between modules | High | Medium | Use CanonicalModel.lean definitions consistently |
| Missing MCS properties | Medium | Low | Properties proven in Completeness.lean, import or adapt |
| Complex induction proof required | Medium | Medium | Start with trivial definition (membership = truth), mark complex proofs sorry |

## Implementation Phases

### Phase 1: Fix TruthLemma.lean Type Errors [COMPLETED]

**Goal**: Resolve all 24 compilation errors by fixing types and constructors

**Tasks**:
- [ ] Add `canonicalTruthAt` definition: `phi in w.carrier`
- [ ] Fix variable declarations to use `CanonicalWorldState` (not `CanonicalWorld`)
- [ ] Replace `past`/`future` with `all_past`/`all_future` in induction cases
- [ ] Remove references to undefined `w.is_closed_under_subformula`
- [ ] Run `lean_diagnostic_messages` to verify error count drops to 0

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Main fixes

**Verification**:
- `lean_diagnostic_messages` returns no errors for TruthLemma.lean
- Module imports successfully in parent Representation.lean

---

### Phase 2: Adapt TruthLemma Structure [COMPLETED]

**Goal**: Create proper truth lemma theorem connecting canonical truth to MCS membership

**Tasks**:
- [ ] Implement `truthLemma_detailed` theorem with correct type signature
- [ ] Add auxiliary lemmas for each Formula constructor (atom, bot, imp, box, all_past, all_future)
- [ ] Mark complex induction proofs with sorry if necessary (can be filled in later)
- [ ] Verify theorem is well-typed and usable from RepresentationTheorem.lean

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Add theorems

**Verification**:
- `truthLemma_detailed` has correct type signature matching research spec
- No type errors in theorem statements

---

### Phase 3: Fix RepresentationTheorem.lean [COMPLETED]

**Goal**: Update RepresentationTheorem.lean to use correct lemma names from CanonicalModel.lean

**Tasks**:
- [ ] Replace `MaximalConsistentSet.lindenbaum` with `set_lindenbaum` (or appropriate alias)
- [ ] Replace `MaximalConsistentSet.modus_ponens` with `mcs_modus_ponens`
- [ ] Update any other references to broken TruthLemma.lean definitions
- [ ] Verify module compiles successfully

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/RepresentationTheorem.lean` - Update references

**Verification**:
- `lean_diagnostic_messages` returns no errors for RepresentationTheorem.lean
- Module exports compile cleanly

---

## Testing & Validation

- [ ] `lean_diagnostic_messages` on TruthLemma.lean returns 0 errors
- [ ] `lean_diagnostic_messages` on RepresentationTheorem.lean returns 0 errors
- [ ] Parent module Representation.lean imports without errors
- [ ] `lake build` completes for Metalogic module (or check with lean_build)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Fixed file
- `Theories/Bimodal/Metalogic/Representation/RepresentationTheorem.lean` - Updated file
- `specs/543_establish_truth_lemma_and_representation/plans/implementation-001.md` - This plan
- `specs/543_establish_truth_lemma_and_representation/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If fixes introduce new issues:
1. Revert TruthLemma.lean and RepresentationTheorem.lean to pre-implementation state using git
2. Mark files with compilation issues as needing further research
3. Document specific blockers in error report

If full truth lemma proof is too complex:
1. Mark induction proofs with sorry
2. Document required lemmas in comments
3. Create follow-up task for completing proofs
