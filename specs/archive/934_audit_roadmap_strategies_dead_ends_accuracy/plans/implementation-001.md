# Implementation Plan: Audit ROAD_MAP.md Strategies and Dead Ends

- **Task**: 934 - audit_roadmap_strategies_dead_ends_accuracy
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/934_audit_roadmap_strategies_dead_ends_accuracy/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This implementation corrects factual inaccuracies and broken references in `specs/ROAD_MAP.md`. The research identified major semantic errors in the Strategies section (reflexive vs irreflexive semantics) and broken file paths in both sections. The goal is a ROAD_MAP.md that accurately reflects current code state and project history for strategic planning of new proof methods.

### Research Integration

Integrated from research-001.md and teammate findings:
- **Strategies**: 3/4 entries have errors (Indexed MCS Family semantic mischaracterization, CoherentConstruction wrong status, Representation-First outdated paths)
- **Dead Ends**: 4/8 entries have broken evidence paths, 1 has terminology error
- All corrections are factual (verified against codebase), not subjective rewrites

## Goals & Non-Goals

**Goals**:
- Fix the reflexive/irreflexive semantic mischaracterization in Indexed MCS Family strategy
- Update all broken file paths to current locations (active code) or Boneyard (archived code)
- Correct status fields for superseded strategies (CoherentConstruction: ACTIVE -> SUPERSEDED)
- Fix task reference errors (814 -> 808 for CoherentConstruction audits)
- Fix the T-axiom terminology error in Single-Family BFMCS dead end
- Ensure every claim matches actual code and project history

**Non-Goals**:
- Restructuring the document format (format is good per user)
- Adding new dead ends for undocumented Boneyard items (lower priority, optional)
- Adding new strategies (no new approaches to document)
- Rewriting accurate content that needs no correction

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Incorrect correction introduces new errors | H | L | Verify each correction against code; research provides evidence |
| Missing a correction | M | M | Systematic file-by-file review of research findings |
| Overwriting useful historical context | M | L | Only correct factual errors; preserve lessons learned |

## Implementation Phases

### Phase 1: Strategies Section Corrections [COMPLETED]

- **Dependencies**: None
- **Goal**: Fix all errors in the Strategies section (3 entries with issues)

**Tasks**:
- [ ] Read current ROAD_MAP.md Strategies section (lines 127-249)
- [ ] **Indexed MCS Family Approach** (lines 174-195):
  - [ ] Replace "irreflexive" with "REFLEXIVE" in semantics description
  - [ ] Replace "without requiring T-axioms" with "T-axioms are valid via reflexivity"
  - [ ] Update file references from `Representation/` to current `Bundle/FMCSDef.lean`, `Bundle/TruthLemma.lean`
  - [ ] Add note that original `IndexedMCSFamily.lean` is archived in Boneyard
- [ ] **CoherentConstruction Two-Chain Design** (lines 198-221):
  - [ ] Change status from `ACTIVE` to `SUPERSEDED`
  - [ ] Update file reference to Boneyard path: `Boneyard/Metalogic_v5/Representation/CoherentConstruction.lean`
  - [ ] Add note that `DovetailingChain.lean` is the current replacement
- [ ] **Representation-First Architecture** (lines 150-171):
  - [ ] Update file reference from `Representation/UniversalCanonicalModel.lean` to `Representation.lean` (current BFMCS entry)
  - [ ] Clarify that sorry-free completeness is via FMP, not archived Representation approach
- [ ] Verify Algebraic Verification Path entry is accurate (no changes expected)

**Timing**: 1 hour

**Files to modify**:
- `specs/ROAD_MAP.md` - Strategies section

**Verification**:
- Each correction matches evidence from research-001-teammate-a-findings.md
- No new errors introduced (file paths exist, status values valid)

---

### Phase 2: Dead Ends Section Corrections [COMPLETED]

- **Dependencies**: Phase 1
- **Goal**: Fix broken paths, wrong task references, and terminology errors in Dead Ends section (5 entries with issues)

**Tasks**:
- [ ] Read current ROAD_MAP.md Dead Ends section
- [ ] **Boneyard Decidability Infrastructure**:
  - [ ] Fix path: `Theories/Boneyard/` -> `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/`
- [ ] **Single-History FDSM Construction**:
  - [ ] Fix archive slug: `825_fdsm_construction` -> `825_fdsm_multi_history_modal_saturation`
  - [ ] Fix report number if needed: `research-002.md` -> `research-001.md`
- [ ] **Cross-Origin Coherence Proofs**:
  - [ ] Update CoherentConstruction.lean path to Boneyard: `Boneyard/Bundle/CoherentConstruction.lean`
  - [ ] Change task reference: 814 -> 808
  - [ ] Update evidence path: `814_sorry_reduction_...` -> `808_audit_coherentconstruction_taskrelation_sorries`
- [ ] **Original IndexedMCSFamily**:
  - [ ] Fix same task 814 -> 808 reference
- [ ] **Single-Family BFMCS modal_backward**:
  - [ ] Fix terminology: "T-axiom `phi -> Box(phi)`" -> "`phi -> Box(phi)` (converse of T-axiom, unprovable in TM)"
- [ ] Verify remaining entries are accurate (CanonicalReachable/CanonicalQuotient, MCS-Membership, Constant Witness)

**Timing**: 45 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Dead Ends section

**Verification**:
- Each correction matches evidence from research-001-teammate-b-findings.md
- All file paths verified to exist
- Task references point to correct archive entries

---

### Phase 3: Verification and Polish [COMPLETED]

- **Dependencies**: Phase 1, Phase 2
- **Goal**: Final review for consistency, verify all corrections, prepare summary

**Tasks**:
- [ ] Read entire ROAD_MAP.md for consistency check:
  - [ ] File path format consistency (relative paths, consistent `Theories/Bimodal/` prefix)
  - [ ] Status marker consistency (ACTIVE, PAUSED, CONCLUDED, SUPERSEDED)
  - [ ] Terminology consistency (reflexive semantics, T-axioms)
- [ ] Verify no unintended changes to accurate content
- [ ] Spot-check 3 corrected paths by verifying files exist:
  - [ ] `Bundle/FMCSDef.lean` exists
  - [ ] `Boneyard/Bundle/CoherentConstruction.lean` exists
  - [ ] `specs/archive/808_audit_coherentconstruction_taskrelation_sorries/` exists
- [ ] Create implementation summary

**Timing**: 45 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Final polish
- `specs/934_audit_roadmap_strategies_dead_ends_accuracy/summaries/implementation-summary-20260226.md` - Summary

**Verification**:
- ROAD_MAP.md builds correctly (no broken markdown)
- All claims are factually accurate
- Document is clear, complete, consistent, concise, and accurate

---

## Testing & Validation

- [ ] All corrected file paths verified to exist in codebase
- [ ] All corrected archive paths verified to exist in `specs/archive/`
- [ ] Status values are valid per ROAD_MAP.md conventions
- [ ] No markdown formatting errors
- [ ] Changes reviewed against research findings checklist

## Artifacts & Outputs

- `plans/implementation-001.md` - This plan
- `specs/ROAD_MAP.md` - Corrected document (existing file, modified)
- `summaries/implementation-summary-20260226.md` - Implementation summary

## Rollback/Contingency

- `git diff` before commit to review all changes
- `git checkout specs/ROAD_MAP.md` to revert if needed
- Research reports preserve original content analysis for reference

---

## Progress

**Session: 2026-02-26, sess_1772130380_4ff103**
- Fixed: Indexed MCS Family semantic description (irreflexive -> REFLEXIVE)
- Fixed: T-axiom claims ("without requiring" -> "valid and used")
- Fixed: CoherentConstruction status (ACTIVE -> SUPERSEDED)
- Fixed: 9 broken file paths to current or Boneyard locations
- Fixed: 3 task references (814 -> 808)
- Fixed: T-axiom terminology in Single-Family BFMCS dead end
- Completed: All 3 phases executed, all corrections verified against filesystem
