# Implementation Plan: Task #764

- **Task**: 764 - improve_metalogic_structure_and_documentation
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: reports/research-001.md, reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Improve the Bimodal/Metalogic/ directory structure and documentation through four primary objectives: (1) recover elements currently imported from Boneyard and rename them to fit existing conventions; (2) document Algebraic/ subdirectory as future extension infrastructure; (3) improve naming conventions, comments, and code quality; (4) systematically improve README.md files from deepest subdirectories back to Metalogic/README.md with complete dependency flowcharts.

### Research Integration

- **research-001.md**: Comprehensive analysis of directory structure, dependency graph showing 5-layer architecture (Core -> Representation -> FMP -> Completeness -> Compactness), documentation quality assessment, and flowchart convention recommendations
- **research-002.md**: Identified 3 Boneyard imports (Core/MaximalConsistent, Completeness/WeakCompleteness, FMP/Closure), confirmed Algebraic/ is independent alternative path not required for main completeness proof, provided recovery effort estimates

## Goals & Non-Goals

**Goals**:
- Eliminate Boneyard import in FMP/Closure.lean (low complexity, single lemma)
- Document remaining Boneyard dependencies with clear recovery roadmap
- Add clear documentation that Algebraic/ is future extension infrastructure
- Improve naming conventions and comments across Metalogic/
- Create consistent README.md files with dependency flowcharts (foundations above, derivatives below)
- Provide high-level architectural overview in Metalogic/README.md

**Non-Goals**:
- Full migration of MCS theory from Boneyard (HIGH effort, ~500 lines - separate task)
- Full migration of Soundness proof from Boneyard (HIGH effort, ~400 lines - separate task)
- Archival of Algebraic/ to Boneyard (user wants it documented as future extension, not archived)
- Modifying any proofs or sorry'd code
- Creating new theorems or mathematical content

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import changes break build | High | Medium | Run `lake build` after each Lean file modification |
| README updates become stale | Medium | Low | Include "Last assessed" dates in documentation |
| Flowchart conventions inconsistent | Low | Low | Define convention upfront, apply consistently |
| Boneyard lemma recovery introduces bugs | Medium | Low | Test with existing proofs that use the lemma |

## Implementation Phases

### Phase 1: Boneyard Import Recovery [NOT STARTED]

**Goal**: Eliminate FMP/Closure.lean's Boneyard import by recovering the single needed lemma `mcs_contains_or_neg`

**Tasks**:
- [ ] Read FMP/Closure.lean to understand how `mcs_contains_or_neg` is used
- [ ] Read Boneyard/Metalogic_v2/Representation/CanonicalModel.lean to understand the lemma
- [ ] Add `mcs_contains_or_neg` lemma to Core/MCSProperties.lean or prove directly
- [ ] Update FMP/Closure.lean import to use Core/MCSProperties instead of Boneyard
- [ ] Run `lake build` to verify no regressions
- [ ] Document remaining Boneyard dependencies in Metalogic/README.md

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - Add lemma
- `Theories/Bimodal/Metalogic/FMP/Closure.lean` - Update import

**Verification**:
- `lake build` succeeds
- No new errors or warnings in FMP/ directory
- `grep "import.*Boneyard" Theories/Bimodal/Metalogic/FMP/` returns nothing

---

### Phase 2: Algebraic/ Documentation [NOT STARTED]

**Goal**: Document Algebraic/ subdirectory as infrastructure for future extensions, not currently used by main proof path

**Tasks**:
- [ ] Read all files in Algebraic/ to understand current structure
- [ ] Update Algebraic/README.md with clear "Future Extension" status
- [ ] Add internal dependency flowchart (foundations above, derivatives below)
- [ ] Document relationship to main completeness path (independent alternative)
- [ ] List future extension opportunities (algebraic topology, Stone duality, etc.)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/README.md` - Complete rewrite

**Verification**:
- README.md contains "Future Extension" or equivalent status indicator
- Flowchart shows internal module dependencies correctly
- Clear explanation of why this path is not used by main completeness proof

---

### Phase 3: Code Quality Improvements [NOT STARTED]

**Goal**: Improve naming conventions, add/improve comments, and clean up code organization across Metalogic/

**Tasks**:
- [ ] Review naming conventions against Lean/Mathlib standards
- [ ] Add/improve section headers and doc comments in key files
- [ ] Ensure consistent import ordering across modules
- [ ] Update Metalogic.lean aggregator to import all subdirectories (not just FMP)
- [ ] Remove any dead code or commented-out sections
- [ ] Verify `lake build` after each file change

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Fix aggregator imports
- Various files across Metalogic/ - Comment and convention improvements

**Verification**:
- `lake build` succeeds
- Import statements follow consistent pattern
- Key theorems and definitions have doc comments

---

### Phase 4: Deep README Documentation - Compactness & Core [NOT STARTED]

**Goal**: Create consistent, complete README.md files for leaf directories (Compactness/, Core/)

**Tasks**:
- [ ] Read Compactness/README.md and all .lean files in directory
- [ ] Rewrite Compactness/README.md with:
  - Clear purpose statement
  - Module list with 1-line descriptions
  - Dependency flowchart (foundations above, derivatives below)
  - Key theorems exported
  - Status of proofs (sorry-free)
- [ ] Read Core/README.md and all .lean files in directory
- [ ] Rewrite Core/README.md with same structure
- [ ] Include Boneyard dependency documentation in Core/README.md

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Compactness/README.md`
- `Theories/Bimodal/Metalogic/Core/README.md`

**Verification**:
- Each README contains: purpose, modules, flowchart, key theorems, status
- Flowcharts show correct import relationships
- Boneyard dependencies clearly documented in Core/README.md

---

### Phase 5: Deep README Documentation - FMP & Completeness [NOT STARTED]

**Goal**: Create consistent, complete README.md files for FMP/ and Completeness/

**Tasks**:
- [ ] Read FMP/README.md and all .lean files in directory
- [ ] Rewrite FMP/README.md with:
  - Clear purpose statement (Finite Model Property)
  - Module list with descriptions
  - Dependency flowchart
  - Explanation of finite model construction vs infinite canonical model
  - Sorry status with justification (architectural, not bugs)
- [ ] Read Completeness/README.md and all .lean files
- [ ] Rewrite Completeness/README.md with same structure
- [ ] Document the sorry-free main path clearly

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/README.md`
- `Theories/Bimodal/Metalogic/Completeness/README.md`

**Verification**:
- Each README contains required sections
- FMP/README.md explains finite vs infinite model distinction
- Completeness/README.md documents sorry-free main path

---

### Phase 6: Deep README Documentation - Representation [NOT STARTED]

**Goal**: Create consistent, complete README.md for Representation/ (largest subdirectory)

**Tasks**:
- [ ] Read Representation/README.md and all .lean files (8 modules)
- [ ] Rewrite Representation/README.md with:
  - Clear purpose statement (canonical model construction)
  - All 8 modules with descriptions
  - Detailed dependency flowchart
  - Explanation of IndexedMCSFamily construction
  - Sorry status with architectural justifications
- [ ] Document relationship to UniversalCanonicalModel
- [ ] Explain how Representation layer feeds into FMP and Completeness

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/README.md`

**Verification**:
- All 8 modules documented
- Flowchart shows complex internal dependencies correctly
- Sorry justifications are mathematically clear

---

### Phase 7: Top-Level Metalogic/README.md [NOT STARTED]

**Goal**: Create comprehensive top-level README with architectural overview and links to subdirectories

**Tasks**:
- [ ] Read current Metalogic/README.md
- [ ] Create new structure:
  1. What the Metalogic Establishes (high-level summary)
  2. Main Results (weak completeness, FMP, compactness)
  3. Architecture Overview (6-subdirectory diagram)
  4. Full Dependency Flowchart (all layers)
  5. Subdirectory Summaries with links to detailed READMEs
  6. Boneyard Dependencies (with recovery roadmap)
  7. Extension Opportunities
- [ ] Ensure no duplication of subdirectory implementation details
- [ ] Include "Last assessed" date for maintainability

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md`

**Verification**:
- High-level overview explains what metalogic establishes
- Flowchart shows all 6 subdirectories and their relationships
- Links to subdirectory READMEs work correctly
- No redundant implementation details (those go in subdirectory READMEs)

## Testing & Validation

- [ ] `lake build` succeeds after all phases
- [ ] All Boneyard imports in Metalogic/ either eliminated or documented
- [ ] Every subdirectory README.md follows consistent structure
- [ ] All flowcharts use same convention (foundations above, derivatives below)
- [ ] Top-level README provides clear architectural overview
- [ ] No broken links in README files

## Artifacts & Outputs

- `specs/764_improve_metalogic_structure_and_documentation/plans/implementation-001.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/Core/MCSProperties.lean`
- Modified: `Theories/Bimodal/Metalogic/FMP/Closure.lean`
- Modified: `Theories/Bimodal/Metalogic/Metalogic.lean`
- Rewritten: All README.md files in Metalogic/ hierarchy
- `specs/764_improve_metalogic_structure_and_documentation/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

- All changes are to documentation (README.md) or imports/comments (no mathematical content)
- Git commits per phase enable selective rollback
- If Boneyard lemma recovery breaks build:
  - Revert Core/MCSProperties.lean changes
  - Revert FMP/Closure.lean import change
  - Document failure and recommend separate recovery task
- If documentation changes are incorrect:
  - Use git diff to identify changes
  - Revert specific README.md files as needed
