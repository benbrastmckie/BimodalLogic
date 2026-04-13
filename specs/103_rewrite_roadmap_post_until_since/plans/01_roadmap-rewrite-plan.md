# Implementation Plan: Rewrite ROAD_MAP.md Post-Until/Since

- **Task**: 103 - Comprehensive ROAD_MAP.md rewrite reflecting post-Until/Since closure state
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_roadmap-rewrite-research.md
- **Artifacts**: plans/01_roadmap-rewrite-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The current ROAD_MAP.md (written during task 91, patched during 2026-04-12 review) contains critical factual errors: the sorry inventory overstates active sorries (says 6, actually 1), body sections describe closed work items as open, the module import graph omits 9 new files (2,289 lines) added for the quasimodel/filtration infrastructure, and the recommended priority order lists completed tasks. This plan decomposes the rewrite into 4 phases that proceed sequentially through the document, updating each section group based on verified facts from the research report. Done when the file is internally consistent, all sorry counts match codebase reality, and the new BXCanonical infrastructure is documented.

### Research Integration

Research report `reports/01_roadmap-rewrite-research.md` provides: (1) verified sorry inventory (1 active-path, ~20 legacy, ~14 boneyard, ~57 examples), (2) complete list of 8 stale sections with line ranges and specific errors, (3) full documentation of 9 new BXCanonical files with line counts and key definitions, (4) updated module import graph, (5) remaining work before publication ordered by criticality.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task directly rewrites ROAD_MAP.md itself. It advances the "publication-blocking documentation" category by bringing the roadmap into factual alignment with codebase state.

## Goals & Non-Goals

**Goals**:
- Correct the sorry inventory from 6 to 1 active-path sorry
- Update the module import graph to include all BXCanonical files (13 files, 3,473 lines)
- Add documentation for the quasimodel/filtration infrastructure (9 new files)
- Rewrite recommended priority order to reflect only remaining tasks
- Remove all stale "STALE" warning banners
- Ensure task cross-reference table matches state.json

**Non-Goals**:
- Modifying any Lean source files
- Updating state.json or TODO.md task descriptions (that is task 104)
- Changing the fundamental structure/organization of ROAD_MAP.md beyond what is needed
- Adding content about tasks not yet created

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Line numbers in code references shift after task 105 | L | M | Use definition/function names as primary identifiers, line numbers as secondary |
| Task 82 (FMP) status ambiguous | L | L | Document current state accurately; note it may need reassessment |
| New sorry introduced before rewrite is implemented | M | L | Verify sorry count at implementation time with fresh grep |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Overview and Sorry Inventory Correction [COMPLETED]

**Goal**: Fix the overview sorry summary and the detailed sorry inventory section to reflect the actual state of 1 active-path sorry.

**Tasks**:
- [ ] Rewrite "Active-path sorry summary" (lines 17-29): remove STALE warning banner, update count from 6 to 1, simplify table to show only Completeness.lean:154
- [ ] Rewrite "Active-Path Sorry Inventory" section (lines 296-329): replace 6-entry table with 1-entry table for Completeness.lean:154
- [ ] Update "Current Gap Summary" (lines 312-328): remove X-vs-G mismatch as open gap (resolved)
- [ ] Update "Legacy Code Inventory" (lines 332-363): correct sorry counts (~20 active legacy, ~14 boneyard, ~57 examples)
- [ ] Verify updated counts against research report sorry inventory

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `specs/ROAD_MAP.md` -- Overview section, Sorry Inventory section, Legacy Code Inventory section

**Verification**:
- Sorry count in overview matches "1 active-path"
- No STALE warning banners remain
- Legacy sorry count says ~20 (not ~210)

---

### Phase 2: Module Graph and New Infrastructure Documentation [COMPLETED]

**Goal**: Update the module import graph to include all 13 BXCanonical files and add a new section documenting the quasimodel/filtration approach.

**Tasks**:
- [ ] Update "Active Metalogic Path: BXCanonical" section (lines 183-216): add CanonicalChain.lean, Quasimodel/ (6 files), Filtration/ (2 files) to the module listing
- [ ] Replace module import graph (lines 192-209) with the full 13-file graph from research report
- [ ] Update "Canonical Model Construction" section (lines 220-293): remove references to sorry at Frame.lean:440, remove Until/Since as "sorry" cases in truth lemma
- [ ] Add new section "Quasimodel/Filtration Infrastructure" documenting the 9 new files, their purpose, key definitions, and role in closing Until/Since eventuality obligations
- [ ] Add new section "How Until/Since Were Closed" with narrative of the successful approach (tasks 90, 92, 98, 102) -- Hintikka-set quasimodel with defect-discharge and sigma-restricted filtration ordering

**Timing**: 60 minutes

**Depends on**: 1

**Files to modify**:
- `specs/ROAD_MAP.md` -- BXCanonical section, Canonical Model Construction section, new sections

**Verification**:
- Module graph shows all 13 files with correct line counts
- New Quasimodel/ and Filtration/ sections exist with file-level documentation
- No references to Frame.lean sorries as open items

---

### Phase 3: Strategy and Priority Sections [COMPLETED]

**Goal**: Update the Burgess-Xu strategy section and recommended priority order to reflect completed work and remaining tasks.

**Tasks**:
- [ ] Rewrite "Burgess-Xu Until-Induction Technique" section (lines 367-432): convert Option A vs B discussion to historical context, document that Option A (quasimodel with defect-discharge) was chosen and implemented successfully
- [ ] Update "Other Open Items" section (lines 508-535): correct FMP Truth Preservation status (sorries archived to Boneyard, 0 remain in active tree), confirm Soundness is sorry-free
- [ ] Rewrite "Recommended Priority Order" section (lines 569-589): remove completed tasks (91, 90, 92, etc.), reorder to show: (1) task 93 -- close Completeness.lean:154, (2) task 95 -- verification audit, (3) task 94 -- archive legacy files, (4) remaining documentation/cleanup tasks

**Timing**: 45 minutes

**Depends on**: 2

**Files to modify**:
- `specs/ROAD_MAP.md` -- Burgess-Xu section, Other Open Items section, Recommended Priority Order section

**Verification**:
- No completed tasks appear in priority order
- Burgess-Xu section reads as historical record, not open decision
- FMP section accurately reflects archived status

---

### Phase 4: Cross-Reference Verification and Final Review [NOT STARTED]

**Goal**: Verify the task cross-reference table, ensure internal consistency across all sections, and remove any remaining stale content.

**Tasks**:
- [ ] Verify task cross-reference table (lines 593-612) against state.json: all completed tasks show correct status
- [ ] Full-document consistency pass: ensure sorry counts mentioned in overview match detailed inventory, module counts match graph, priority order references only existing tasks
- [ ] Remove any remaining STALE/WARNING banners or TODO markers
- [ ] Verify all section cross-references are internally consistent (e.g., phase references in overview match detailed sections)
- [ ] Run a fresh `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/ --include="*.lean"` to confirm sorry count has not changed since research

**Timing**: 30 minutes

**Depends on**: 3

**Files to modify**:
- `specs/ROAD_MAP.md` -- Cross-reference table, any remaining inconsistencies

**Verification**:
- Task cross-reference matches state.json
- No internal contradictions in sorry counts across sections
- No STALE/WARNING banners remain
- grep confirms 1 sorry in BXCanonical/

## Testing & Validation

- [ ] Sorry count in ROAD_MAP.md overview matches grep output from codebase (1 active-path)
- [ ] All 13 BXCanonical files appear in module import graph
- [ ] Task cross-reference table matches state.json for all referenced tasks
- [ ] No completed tasks appear in "Recommended Priority Order"
- [ ] No STALE warning banners remain in the document
- [ ] New Quasimodel/Filtration documentation section exists with all 9 files documented

## Artifacts & Outputs

- `specs/ROAD_MAP.md` -- Rewritten roadmap (primary deliverable)
- `specs/103_rewrite_roadmap_post_until_since/plans/01_roadmap-rewrite-plan.md` -- This plan
- `specs/103_rewrite_roadmap_post_until_since/summaries/01_roadmap-rewrite-summary.md` -- Post-implementation summary

## Rollback/Contingency

The file is under git version control. If the rewrite introduces errors, revert with `git checkout main -- specs/ROAD_MAP.md` to restore the pre-rewrite version. Since the current version already has a patched cross-reference table from the 2026-04-12 review, the rollback target is well-defined.
