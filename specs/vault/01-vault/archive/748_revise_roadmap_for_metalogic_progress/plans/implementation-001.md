# Implementation Plan: Task #748

- **Task**: 748 - Revise ROAD_MAP.md for Metalogic Progress
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: Research report research-001.md (completed)
- **Research Inputs**: specs/748_revise_roadmap_for_metalogic_progress/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Systematically revise `/home/benjamin/Projects/ProofChecker/specs/ROAD_MAP.md` to reflect the current state of Bimodal/Metalogic development. The roadmap has not been updated since Task 654 and requires updates to: (1) mark completed items, (2) add new sections for completeness hierarchy, compactness, and CoherentConstruction, (3) update sorry tables with current locations, and (4) add active tasks section.

### Research Integration

The research report (research-001.md) provides:
- Comprehensive comparison of ROAD_MAP.md vs actual Metalogic state
- Specific items to mark as COMPLETED with line references
- New sections to add (Completeness Hierarchy, Compactness, CoherentConstruction, Algebraic)
- Current sorry count analysis with categories
- Obsolete items to flag or remove

## Goals & Non-Goals

**Goals**:
- Mark completed items in Phases 0, 1, 4, 6 with checkmarks
- Add new section documenting Completeness Hierarchy (Weak, Finite Strong, Infinitary Strong)
- Add new section documenting Compactness theorem (sorry-free)
- Update sorry table (Phase 5) with current locations and categories
- Add CoherentConstruction architectural documentation
- Add Active Tasks section linking to in-progress work
- Update "Current State" tables with verified status

**Non-Goals**:
- Removing deprecated Boneyard documentation (keep for historical reference)
- Restructuring the entire roadmap hierarchy
- Adding new phases or reordering existing phases
- Modifying Lean source files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Inaccurate status marking | Medium | Low | Cross-reference with README files and grep for sorries |
| Missing new achievements | Medium | Low | Research report provides comprehensive inventory |
| Breaking existing links | Low | Low | Only modify content, not structure |

## Implementation Phases

### Phase 1: Mark Completed Items [COMPLETED]

**Goal**: Update checkboxes for items that have been completed since Task 654

**Tasks**:
- [ ] Update Phase 0.1 (Audit Current Sorries) - mark partially complete, reference Task 758
- [ ] Update Phase 0.4 (Document Inventory) - mark complete, reference README hierarchy (Task 747)
- [ ] Update Phase 1.2 items (import graph visualization, layer discipline) - mark complete
- [ ] Update Phase 1.3 (module overviews) - mark complete with README references
- [ ] Update Phase 4.1/4.2 (representation theorem as primary export) - mark complete
- [ ] Update Phase 6.1 (comprehensive README) - mark complete
- [ ] Update Phase 6.3 (test suite) - mark complete with test file count

**Timing**: 30 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Phases 0, 1, 4, 6 sections

**Verification**:
- Each marked item has supporting evidence (README path, task reference, or file path)
- Checkmarks use `[x]` format consistently

---

### Phase 2: Add New Achievement Sections [COMPLETED]

**Goal**: Document new Metalogic achievements not present in current roadmap

**Tasks**:
- [ ] Add "Completeness Hierarchy" section after line 98 with table:
  - weak_completeness (PROVEN)
  - finite_strong_completeness (PROVEN)
  - infinitary_strong_completeness (PROVEN)
  - provable_iff_valid (PROVEN, soundness axiomatized)
- [ ] Add "Compactness" section after completeness with table:
  - compactness (PROVEN, sorry-free)
  - compactness_iff (PROVEN)
  - compactness_entailment (PROVEN)
  - compactness_unsatisfiability (PROVEN)
- [ ] Add "CoherentConstruction Approach" section documenting:
  - Two-chain architecture (forward/backward from origin)
  - Definitional coherence (not proved after construction)
  - Cases 1 and 4 needed for completeness
- [ ] Add brief "Algebraic Approach" section:
  - Lindenbaum-Tarski quotient algebra
  - Status: partial, independent verification path

**Timing**: 40 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Insert new sections in "Bimodal/Metalogic" area

**Verification**:
- Tables have consistent formatting with existing tables
- Status markers match verified Lean code state
- File paths are accurate

---

### Phase 3: Update Sorry Tables [COMPLETED]

**Goal**: Replace outdated Phase 5 sorry table with current locations and categories

**Tasks**:
- [ ] Update sorry table header to reflect current architecture
- [ ] Add current sorry counts by directory:
  - Representation/: ~17 (mixed: IndexedMCSFamily superseded, CoherentConstruction, TaskRelation)
  - FMP/: ~3 (truth bridge gaps, documented)
  - Completeness/: 1 (soundness axiomatized)
  - Algebraic/: ~8 (independent path, partial)
  - Compactness/: 0 (sorry-free)
  - Core/: 0 (re-exports proven code)
- [ ] Update recommendations for each sorry category:
  - `semantic_task_rel_compositionality` - document as architectural limitation
  - `main_provable_iff_valid_v2` - use `semantic_weak_completeness` instead
  - Update location references (old line numbers invalid)
- [ ] Mark Phase 2.1.A (Set-Based Strong Completeness) as COMPLETED with `infinitary_strong_completeness`

**Timing**: 30 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Phase 5 section, Phase 2.1.A

**Verification**:
- Sorry counts match current grep analysis
- Each sorry has recommendation (fix, skip, or document)
- No references to non-existent files/lines

---

### Phase 4: Add Active Work and Future Sections [COMPLETED]

**Goal**: Link roadmap to current task system and future directions

**Tasks**:
- [ ] Add "Active Tasks" section listing in-progress Metalogic work:
  - Task 749: sorry-free completeness via semantic_weak_completeness
  - Task 750: forward Truth Lemma refactoring
  - Task 753: CoherentConstruction sorries
  - Task 755: Option C FMP path
  - Task 758: systematic sorry audit
- [ ] Update Phase 0.3 (Decidability Decision):
  - Boneyard decidability is DEPRECATED
  - New FMP infrastructure in Metalogic/FMP/ provides parametric FMP
  - Full decidability proof not critical given sorry-free completeness
- [ ] Update "Last Updated" header to current date (2026-01-29)
- [ ] Update status line to reflect "Completeness Hierarchy Complete, Active Refinement Phase"

**Timing**: 20 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Add Active Tasks section, update header and Phase 0.3

**Verification**:
- Task numbers link to valid entries in TODO.md/state.json
- Header date matches implementation date
- Status line accurately reflects project state

## Testing & Validation

- [ ] All checkmarks have supporting evidence
- [ ] New tables follow existing formatting conventions
- [ ] No broken internal references
- [ ] File paths in tables exist
- [ ] Task numbers in Active Tasks section are valid
- [ ] Document renders correctly as Markdown

## Artifacts & Outputs

- `specs/ROAD_MAP.md` - Revised roadmap document
- `specs/748_revise_roadmap_for_metalogic_progress/summaries/implementation-summary-20260129.md` - Implementation summary

## Rollback/Contingency

If revision introduces errors:
1. Use `git checkout specs/ROAD_MAP.md` to restore previous version
2. Re-apply changes incrementally, verifying each section
3. Cross-reference against research report for accuracy
