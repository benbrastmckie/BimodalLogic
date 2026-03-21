# Implementation Plan: Refactor Completeness.lean

- **Task**: 798 - refactor_completeness_lean
- **Status**: [COMPLETED]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/798_refactor_completeness_lean/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Refactor the monolithic Completeness.lean (~3720 lines) by extracting essential completeness infrastructure into modular Core files and archiving deprecated Duration-based constructions to Boneyard. The research report identifies clear line ranges for extraction (SetConsistency definitions lines 79-167, 410-733; Lindenbaum lemma lines 168-409) and archival (Duration construction lines 1414-3720). The expected result is a lean ~600-800 line Completeness.lean with proper imports from new Core modules.

### Research Integration

Key findings from research-001.md:
- File naturally divides into essential core (~600 lines), modal/temporal MCS (~400 lines), and deprecated infrastructure (~2800 lines)
- Existing Boneyard/Metalogic_v2/Core/MaximalConsistent.lean contains duplicated content - consider consolidation
- Safe extraction order: SetConsistency -> Lindenbaum -> Archive -> Refactor main file
- Uses `zorn_subset_nonempty` from Mathlib.Order.Zorn for Lindenbaum lemma

## Goals & Non-Goals

**Goals**:
- Extract `SetConsistent`, `SetMaximalConsistent`, and propositional MCS properties to `Core/SetConsistency.lean`
- Extract `set_lindenbaum` (Lindenbaum lemma via Zorn) and chain consistency lemmas to `Core/Lindenbaum.lean`
- Archive Duration construction, canonical model infrastructure, and axiom stubs to Boneyard
- Reduce Completeness.lean to ~600-800 lines containing only modal/temporal MCS properties
- Maintain all existing functionality through proper imports

**Non-Goals**:
- Fixing the 15+ sorry gaps in the deprecated Duration infrastructure (preserved as-is in archive)
- Consolidating with Boneyard/Metalogic_v2/Core/MaximalConsistent.lean (defer to future task)
- Modifying FiniteCanonicalModel.lean (working proofs remain untouched)
- Completing the axiom stubs (actual proofs are in FiniteCanonicalModel.lean)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import cycle between new Core files | High | Medium | Order extractions carefully: SetConsistency first (no Core deps), then Lindenbaum (depends on SetConsistency) |
| Missing dependencies after extraction | Medium | Low | Use `lake build` after each phase to detect issues early |
| Breaking Completeness.lean consumers | Medium | Low | Only Completeness/Completeness.lean and FiniteCanonicalModel.lean import it; verify both after refactor |
| Accidental modification of working code | High | Low | Extract/move only, no logic changes; git commit after each phase |

## Implementation Phases

### Phase 1: Create Core/SetConsistency.lean [SKIPPED]

**Note**: Content already exists in `Core/MaximalConsistent.lean` (re-exports from Boneyard) and `Core/MCSProperties.lean`. No new file needed.

**Goal**: Extract consistency definitions and basic MCS properties into a new Core file

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Core/SetConsistency.lean` with proper module header
- [ ] Extract from lines 79-167: `Consistent`, `MaximalConsistent`, `SetConsistent`, `SetMaximalConsistent`, `ConsistentExtensions`, `contextToSet`, `consistent_implies_set_consistent`
- [ ] Extract from lines 410-733: `inconsistent_derives_bot`, `derives_neg_from_inconsistent_extension`, `derives_bot_from_phi_neg_phi`, `maximal_extends_inconsistent`, `set_mcs_finite_subset_consistent`, `maximal_consistent_closed`, `maximal_negation_complete`, all `set_mcs_*` propositional lemmas
- [ ] Add necessary imports: `Bimodal.ProofSystem`, `Bimodal.Semantics`, `Bimodal.Metalogic.DeductionTheorem`, `Bimodal.Theorems.Propositional`
- [ ] Verify file compiles with `lake build Theories/Bimodal/Metalogic/Core/SetConsistency.lean`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/SetConsistency.lean` - CREATE new file (~400 lines)

**Verification**:
- File compiles without errors
- All extracted definitions and lemmas are accessible

---

### Phase 2: Create Core/Lindenbaum.lean [SKIPPED]

**Note**: `set_lindenbaum` and chain consistency lemmas already exist in `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean` and are re-exported via `Core/MaximalConsistent.lean`. No new file needed.

**Goal**: Extract Lindenbaum lemma and chain consistency infrastructure

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Core/Lindenbaum.lean` with proper module header
- [ ] Extract from lines 168-331: `usedFormulas`, `usedFormulas_subset`, `usedFormulas_empty_context`, `usedFormulas_necessitation_eq_nil`, `derivation_uses_finite_context`, `derivation_from_subset_weaken`, `finite_list_in_chain_member`, `consistent_chain_union`
- [ ] Extract from lines 332-409: `ConsistentSupersets`, `self_mem_consistent_supersets`, `set_lindenbaum`
- [ ] Add imports: `Bimodal.Metalogic.Core.SetConsistency`, `Mathlib.Order.Zorn`, `Mathlib.Order.Preorder.Chain`
- [ ] Verify file compiles with `lake build Theories/Bimodal/Metalogic/Core/Lindenbaum.lean`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/Lindenbaum.lean` - CREATE new file (~200 lines)

**Verification**:
- File compiles without errors
- `set_lindenbaum` theorem is accessible
- Uses `zorn_subset_nonempty` from Mathlib

---

### Phase 3: Create Boneyard Archive [COMPLETED]

**Goal**: Archive deprecated Duration-based canonical model infrastructure

**Tasks**:
- [ ] Create directory `Theories/Bimodal/Boneyard/Metalogic_v4/Completeness/`
- [ ] Create `MonolithicCompleteness.lean` with archive header documenting purpose
- [ ] Extract from lines 1414-1983: Duration construction (`TemporalChain`, `ChainSegment`, `PositiveDuration`, `Duration`, `CanonicalTime`)
- [ ] Extract from lines 1984-2440: Canonical task relation (`modal_transfer`, `future_transfer`, `past_transfer`, `canonical_task_rel`, `canonical_nullity`, `canonical_compositionality`, `canonical_frame`)
- [ ] Extract from lines 2441-2696: Seed definitions and model (`forward_seed`, `backward_seed`, `canonical_valuation`, `canonical_model`)
- [ ] Extract from lines 2697-3568: Chain-based history construction (`canonical_forward_chain`, `canonical_backward_chain`, `canonical_states`, `chain_indexed_history`, `canonical_history`)
- [ ] Extract from lines 3569-3720: Axioms/stubs and audit documentation (`someWorldState_exists`, `anotherWorldState_exists`, `truth_lemma`, `weak_completeness`, `strong_completeness`, `provable_iff_valid`)
- [ ] Add appropriate imports to make archive self-contained
- [ ] Verify archive compiles (with expected sorry gaps)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic_v4/Completeness/MonolithicCompleteness.lean` - CREATE archive (~2800 lines)

**Verification**:
- Archive file compiles (sorry gaps expected and documented)
- All deprecated infrastructure is preserved
- Archive header clearly documents why content was archived

---

### Phase 4: Refactor Completeness.lean [COMPLETED]

**Goal**: Refactor main file to import from new Core modules and remove archived content

**Tasks**:
- [ ] Add imports for new Core files: `import Bimodal.Metalogic.Core.SetConsistency`, `import Bimodal.Metalogic.Core.Lindenbaum`
- [ ] Remove lines 79-409 (now in Core/SetConsistency and Core/Lindenbaum)
- [ ] Remove lines 410-733 propositional MCS lemmas (now in Core/SetConsistency)
- [ ] Remove lines 1414-3720 (now in Boneyard archive)
- [ ] Keep lines 734-1413: temporal MCS properties, diamond-box duality proofs, saturation lemma stubs, CanonicalWorldState
- [ ] Update any internal references to use imported definitions
- [ ] Verify refactored file compiles

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - MODIFY (reduce from ~3720 to ~600-800 lines)

**Verification**:
- Refactored Completeness.lean compiles
- All kept functionality works via imports
- No duplicate definitions between files

---

### Phase 5: Update Core Re-exports and Verify Build [COMPLETED]

**Goal**: Update Core module re-exports and verify full project build

**Tasks**:
- [ ] Update `Theories/Bimodal/Metalogic/Core/Core.lean` to re-export SetConsistency and Lindenbaum
- [ ] Verify `Completeness/Completeness.lean` wrapper still works
- [ ] Verify `Completeness/FiniteCanonicalModel.lean` still compiles (it imports Completeness)
- [ ] Run full `lake build` to verify no regressions
- [ ] Update lakefile if needed for new modules

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/Core.lean` - UPDATE re-exports
- Possibly `lakefile.lean` if modules need explicit registration

**Verification**:
- `lake build` succeeds for entire project
- All consumers of Completeness.lean work correctly
- Import paths are clean and consistent

## Testing & Validation

- [ ] Phase 1: `lake build Theories/Bimodal/Metalogic/Core/SetConsistency.lean` compiles
- [ ] Phase 2: `lake build Theories/Bimodal/Metalogic/Core/Lindenbaum.lean` compiles
- [ ] Phase 3: Archive file compiles with expected sorry gaps
- [ ] Phase 4: Refactored Completeness.lean compiles
- [ ] Phase 5: Full `lake build` succeeds
- [ ] Verify no new sorry gaps introduced (only archived ones)
- [ ] Verify Completeness/FiniteCanonicalModel.lean unchanged and working

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Core/SetConsistency.lean` - New core module (~400 lines)
- `Theories/Bimodal/Metalogic/Core/Lindenbaum.lean` - New core module (~200 lines)
- `Theories/Bimodal/Boneyard/Metalogic_v4/Completeness/MonolithicCompleteness.lean` - Archive (~2800 lines)
- `Theories/Bimodal/Metalogic/Completeness.lean` - Refactored (~600-800 lines)
- `Theories/Bimodal/Metalogic/Core/Core.lean` - Updated re-exports
- `specs/798_refactor_completeness_lean/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If refactoring introduces unexpected issues:
1. All original code is preserved in git history
2. Archive can be un-archived by moving content back
3. New Core files can be deleted and Completeness.lean restored from git
4. Each phase commits separately for fine-grained rollback
5. FiniteCanonicalModel.lean (working proofs) is never modified
