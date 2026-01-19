# Implementation Plan: Task #597

- **Task**: 597 - Re-prove main_provable_iff_valid in Metalogic_v2
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: High
- **Dependencies**: None (all needed infrastructure exists in Metalogic_v2)
- **Research Inputs**: specs/597_reprove_main_provable_iff_valid_metalogic_v2/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Re-prove `main_provable_iff_valid` within Metalogic_v2 using the simpler contrapositive approach recommended by research. This avoids the complex finite canonical model machinery of old Metalogic and uses existing Metalogic_v2 infrastructure (MCS theory, truth lemma, soundness). Completion enables full deprecation of Theories/Bimodal/Metalogic/ directory.

### Research Integration

Key findings from research-001.md:
- Strategy B (contrapositive proof) recommended over Strategy A (finite canonical model)
- All required infrastructure already exists in Metalogic_v2: `set_lindenbaum`, `mcs_contains_or_neg`, `truthLemma_detailed`, `soundness`
- Key new lemma needed: `set_mcs_neg_excludes` (if phi.neg in MCS then phi not in MCS)
- Bridge construction needed: connect CanonicalWorldState to TaskModel for countermodel

## Goals & Non-Goals

**Goals**:
- Prove `main_provable_iff_valid : Nonempty (- phi) <-> valid phi` in Metalogic_v2
- Remove old Metalogic import from ContextProvability.lean
- Achieve full independence from Theories/Bimodal/Metalogic/ directory
- Zero sorries in the new proof

**Non-Goals**:
- Replicate finite canonical model infrastructure from old Metalogic
- Prove finite model property (not needed for this theorem)
- Delete old Metalogic directory (separate deprecation task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Truth lemma bridge complexity | High | Medium | Use trivial single-world model for countermodel construction |
| Temporal operators in bridge | Medium | Low | For validity countermodel, temporal structure can be trivial (static) |
| Missing helper lemmas | Medium | Low | Research identified all needed helpers; most exist or are simple |
| Build regression | Medium | Low | Run full `lake build` after changes; verify downstream files compile |

## Implementation Phases

### Phase 1: Helper Lemmas [NOT STARTED]

**Goal**: Add missing helper lemmas to Metalogic_v2 infrastructure

**Tasks**:
- [ ] Verify `not_derivable_implies_neg_consistent` exists in ContextProvability.lean
- [ ] Add `set_mcs_neg_excludes` lemma: If `phi.neg` in MCS M, then `phi` not in M
- [ ] Verify this follows from `mcs_contains_or_neg` + consistency property
- [ ] Test compilation of CanonicalModel.lean or MaximalConsistent.lean

**Timing**: 30 minutes

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` - Add `set_mcs_neg_excludes` if not present
- `Logos/Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean` - Alternative location for helper

**Verification**:
- `lake build Bimodal.Metalogic_v2.Representation.CanonicalModel` succeeds
- New lemma has no sorries

---

### Phase 2: Canonical-to-Semantic Bridge [NOT STARTED]

**Goal**: Create bridge connecting CanonicalWorldState to TaskModel for countermodel construction

**Tasks**:
- [ ] Create new file `Metalogic_v2/Completeness/WeakCompleteness.lean`
- [ ] Define `canonicalCountermodel : CanonicalWorldState -> TaskModel` construction
- [ ] For countermodel: use trivial domain (Unit or Fin 1), static temporal structure
- [ ] Prove truth correspondence: phi in MCS iff phi true in canonicalCountermodel at that world
- [ ] This leverages existing `truthLemma_detailed` from TruthLemma.lean

**Timing**: 1 hour

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Completeness/WeakCompleteness.lean` - Create new file

**Verification**:
- File compiles without errors
- Bridge construction has no sorries
- Truth correspondence lemma proven

---

### Phase 3: Main Theorem [NOT STARTED]

**Goal**: Prove `main_provable_iff_valid` using contrapositive approach

**Tasks**:
- [ ] Implement forward direction (soundness): `Nonempty (- phi) -> valid phi`
  - Use existing `soundness` theorem with empty context
- [ ] Implement backward direction (completeness via contrapositive): `valid phi -> Nonempty (- phi)`
  - Assume `valid phi` and `not Nonempty (- phi)` for contradiction
  - Show `{phi.neg}` is consistent using `not_derivable_implies_neg_consistent`
  - Extend to MCS via `set_lindenbaum`
  - Construct countermodel from MCS using Phase 2 bridge
  - Derive contradiction with validity assumption
- [ ] Verify no sorries in final proof

**Timing**: 30 minutes

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Completeness/WeakCompleteness.lean` - Add main theorem

**Verification**:
- `main_provable_iff_valid` proven without sorries
- `lake build Bimodal.Metalogic_v2.Completeness.WeakCompleteness` succeeds

---

### Phase 4: Import Cleanup and Integration [NOT STARTED]

**Goal**: Remove old Metalogic dependency and integrate new proof

**Tasks**:
- [ ] Remove old Metalogic `open` statement from ContextProvability.lean (lines 59-60)
- [ ] Add import for new WeakCompleteness.lean
- [ ] Update any other files that reference `main_provable_iff_valid` to use new location
- [ ] Update FMP.lean or other hub modules to export new theorem
- [ ] Run full `lake build` to verify no regressions

**Timing**: 30 minutes

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - Remove old import, add new
- `Logos/Theories/Bimodal/Metalogic_v2/FMP.lean` - Update exports (if applicable)

**Verification**:
- `grep -r "Metalogic.Completeness" Logos/Theories/Bimodal/Metalogic_v2/` returns no matches
- `lake build` succeeds with no new warnings
- All downstream files compile

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic_v2.Completeness.WeakCompleteness` compiles
- [ ] `lake build Bimodal.Metalogic_v2.Representation.ContextProvability` compiles without old Metalogic import
- [ ] `lake build` full project succeeds
- [ ] `grep -r "main_provable_iff_valid" Logos/` shows new location in Metalogic_v2
- [ ] No sorries in new proof (`grep "sorry" WeakCompleteness.lean` returns empty)
- [ ] Verify old Metalogic not imported: `grep -r "Metalogic.Completeness.FiniteCanonicalModel" Logos/Theories/Bimodal/Metalogic_v2/` returns empty

## Artifacts & Outputs

- `Logos/Theories/Bimodal/Metalogic_v2/Completeness/WeakCompleteness.lean` - New file with main theorem
- `Logos/Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` - Updated with helper lemmas
- `Logos/Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - Cleaned imports
- `specs/597_reprove_main_provable_iff_valid_metalogic_v2/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation fails:
1. Revert changes to ContextProvability.lean to restore old Metalogic import
2. Delete WeakCompleteness.lean if incomplete
3. Revert helper lemma additions to CanonicalModel.lean
4. Run `lake build` to verify rollback is clean

Alternative approach if contrapositive proof is blocked:
- Fall back to Strategy A: copy finite canonical model infrastructure from old Metalogic
- This is more work (~500 lines) but preserves exact proof structure
- Research report has list of definitions to copy
