# Implementation Plan: Task #764 (Revised)

- **Task**: 764 - improve_metalogic_structure_and_documentation
- **Version**: 002
- **Status**: [COMPLETED]
- **Effort**: 18-22 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: reports/research-001.md, reports/research-002.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: true (includes Lean code migration)

## Revision Notes

**Previous version**: implementation-001.md
**Revision reason**: User requested full Boneyard migration instead of just documentation. "I want to migrate everything from the Boneyard/ that is needed to avoid all imports to the Boneyard/ and to provide the highest quality Metalogic/ proof codebase."

**Key changes from v001**:
- Phase 1 expanded from single-lemma recovery to FULL MCS theory migration (~500 lines)
- New Phase 2 for FULL Soundness proof migration (~400 lines)
- Phase 3 now handles the single-lemma FMP/Closure fix
- Documentation phases (4-10) remain similar but updated for new content
- Estimated effort increased from 12 hours to 18-22 hours

## Overview

Migrate ALL necessary content from Boneyard/ to active Metalogic/ to eliminate all Boneyard imports, providing a self-contained, highest-quality proof codebase. Then systematically document the improved structure from deepest subdirectories to top-level README.md.

### Research Integration

- **research-001.md**: 5-layer architecture (Core -> Representation -> FMP -> Completeness -> Compactness), documentation assessment
- **research-002.md**: Identified 3 Boneyard imports requiring recovery:
  1. Core/MaximalConsistent.lean imports Boneyard MCS theory (~500 lines)
  2. Completeness/WeakCompleteness.lean imports Boneyard Soundness (~400 lines)
  3. FMP/Closure.lean imports single lemma `mcs_contains_or_neg`

## Goals & Non-Goals

**Goals**:
- **Eliminate ALL Boneyard imports** from active Metalogic/
- Migrate MCS theory (~500 lines) with improved naming for clarity
- Migrate Soundness proof (~400 lines) with proper organization
- Fix FMP/Closure.lean to use migrated MCS properties
- Document Algebraic/ as future extension infrastructure (not archive)
- Create comprehensive README.md documentation from deepest to top-level
- Provide highest-quality, self-contained metalogic proof codebase

**Non-Goals**:
- Archiving Algebraic/ to Boneyard (user wants it documented, not archived)
- Modifying proof strategies or mathematical content (pure migration)
- Adding new theorems beyond what exists in Boneyard

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| MCS migration breaks proofs | High | Medium | Migrate incrementally, `lake build` after each file |
| Naming changes cause import failures | High | Medium | Create clear rename mapping, update all importers |
| Soundness proof has hidden dependencies | Medium | Medium | Trace all imports before starting migration |
| Large migration scope leads to partial completion | Medium | Low | Clear phase boundaries allow stopping points |

## Implementation Phases

### Phase 1: MCS Theory Migration [COMPLETED]

**Goal**: Migrate complete MCS (Maximal Consistent Set) theory from Boneyard to Core/

**Tasks**:
- [x] Read Boneyard/Metalogic_v2/Core/MaximalConsistent.lean fully (~500 lines)
- [x] Identify all exports: `Consistent`, `MaximalConsistent`, `SetConsistent`, `SetMaximalConsistent`, `set_lindenbaum`, etc.
- [x] Expand Core/MaximalConsistent.lean with full MCS theory
- [x] Migrate definitions with improved naming (all kept as-is, clear names)
- [x] Migrate `set_lindenbaum` (Lindenbaum's Lemma) with full proof
- [x] Migrate all MCS property lemmas including `mcs_contains_or_neg`, `extract_neg_derivation`, etc.
- [x] Update namespace to `Bimodal.Metalogic.Core` (not Boneyard)
- [x] Run `lake build` to verify
- [x] Update all files that import Core/MaximalConsistent to use new exports

**Timing**: 5-6 hours (actual: ~4 hours)

**Files modified**:
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` (EXPANDED with full MCS theory)
- `Theories/Bimodal/Metalogic/Core/Core.lean` (UPDATED docstrings)

**Verification**:
- `lake build` succeeds
- `grep "import.*Boneyard.*MaximalConsistent" Theories/Bimodal/Metalogic/Core/` returns nothing
- All MCS-dependent files still compile

---

### Phase 2: Soundness Proof Migration [COMPLETED]

**Goal**: Migrate complete Soundness proof from Boneyard to new Soundness/ subdirectory

**Tasks**:
- [x] Read Boneyard/Metalogic_v2/Soundness/Soundness.lean (~300 lines)
- [x] Read Boneyard/Metalogic_v2/Soundness/SoundnessLemmas.lean (~100+ lines)
- [x] Create new directory: Metalogic/Soundness/
- [x] Create Soundness/SoundnessLemmas.lean (~540 lines) with temporal duality bridge theorems
- [x] Create Soundness/Soundness.lean (~315 lines) with main theorem and all 15 axiom validity lemmas
- [x] Update Completeness/WeakCompleteness.lean to import from Soundness/ (not Boneyard)
- [x] Run `lake build` to verify
- [x] Metalogic.lean aggregator already correctly structured

**Timing**: 5-6 hours (actual: ~3 hours)

**Files created**:
- `Theories/Bimodal/Metalogic/Soundness/` (NEW directory)
- `Theories/Bimodal/Metalogic/Soundness/SoundnessLemmas.lean` (temporal duality bridge)
- `Theories/Bimodal/Metalogic/Soundness/Soundness.lean` (main theorem + 15 axiom validity)

**Files modified**:
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` (UPDATED import)

**Verification**:
- `lake build` succeeds
- `grep "import.*Boneyard.*Soundness" Theories/Bimodal/Metalogic/` returns nothing
- WeakCompleteness still compiles and works

---

### Phase 3: FMP/Closure Fix [COMPLETED]

**Goal**: Update FMP/Closure.lean to use migrated MCS properties instead of Boneyard

**Tasks**:
- [x] Verify `mcs_contains_or_neg` was migrated in Phase 1
- [x] Remove Boneyard import from FMP/Closure.lean
- [x] Remove Boneyard namespace open from FMP/Closure.lean, SemanticCanonicalModel.lean, FiniteModelProperty.lean
- [x] Fix Algebraic/UltrafilterMCS.lean to use migrated `inconsistent_derives_bot`
- [x] Run `lake build` to verify
- [x] Verify FMP/ directory has no remaining Boneyard imports

**Timing**: 30 minutes (actual: ~1 hour including additional fixes)

**Files modified**:
- `Theories/Bimodal/Metalogic/FMP/Closure.lean` (REMOVED Boneyard import and open)
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` (REMOVED Boneyard namespace open)
- `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean` (REMOVED Boneyard namespace open)
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` (FIXED namespace references)

**Verification**:
- `lake build` succeeds
- `grep "import.*Boneyard" Theories/Bimodal/Metalogic/FMP/` returns nothing

---

### Phase 4: Verify Zero Boneyard Imports [COMPLETED]

**Goal**: Confirm ALL Boneyard imports eliminated from active Metalogic/

**Tasks**:
- [x] Run comprehensive grep: `grep -r "import.*Boneyard" Theories/Bimodal/Metalogic/`
- [x] Verified: ZERO Boneyard imports in Metalogic/
- [x] Verified: Only doc comments reference Metalogic_v2 (historical references)
- [x] Run full `lake build` - PASSES (983 jobs)
- [x] Document migration completion

**Timing**: 30 minutes (actual: 15 minutes)

**Verification**:
- `grep -r "import.*Boneyard" Theories/Bimodal/Metalogic/` returns NOTHING
- `grep -r "Metalogic_v2" --include="*.lean"` returns only doc comments (historical references)
- `lake build` succeeds (983 jobs)

---

### Phase 5: Algebraic/ Documentation [COMPLETED]

**Goal**: Document Algebraic/ subdirectory as infrastructure for future extensions

**Tasks**:
- [x] Read all 6 files in Algebraic/
- [x] Update Algebraic/README.md with:
  - Clear "Future Extension Infrastructure" header and status note
  - Purpose: Alternative algebraic approach to representation theorem
  - Module descriptions for all 6 files (was 5, actually has 6)
  - Internal dependency flowchart
  - Relationship to main proof path (independent alternative)
  - Future extension opportunities (Stone duality, algebraic topology)
- [x] Add "Status: Not required for main completeness proof" disclaimer
- [x] Removed references to non-existent files (AlgebraicSemanticBridge.lean, HybridCompleteness.lean)

**Timing**: 1.5 hours (actual: 30 minutes)

**Files modified**:
- `Theories/Bimodal/Metalogic/Algebraic/README.md`

**Verification**:
- README clearly indicates future extension status
- All 6 modules documented with sorry status
- Flowchart correct

---

### Phase 6: Code Quality Improvements [COMPLETED]

**Goal**: Improve naming conventions, comments, and organization across Metalogic/

**Tasks**:
- [x] Update Metalogic.lean aggregator with comprehensive documentation:
  - Architecture overview (7 subdirectories)
  - Dependency layers diagram
  - Main results with theorem signatures
  - Known limitations table
  - Self-contained status declaration
- [x] Mark "Self-contained (NO Boneyard dependencies)" in Metalogic.lean
- [x] `lake build` passes

**Timing**: 1.5 hours (actual: 20 minutes)

**Files modified**:
- `Theories/Bimodal/Metalogic/Metalogic.lean` (REWRITTEN with comprehensive docs)

**Verification**:
- `lake build` succeeds (983 jobs)
- Aggregator documents all 7 subdirectories
- Self-contained status clearly stated

---

### Phase 7: README - Core/ and Soundness/ [COMPLETED]

**Goal**: Create comprehensive README.md files for Core/ and new Soundness/

**Tasks**:
- [x] Rewrite Core/README.md:
  - "Self-Contained (No Boneyard Dependencies)" status header
  - Purpose (foundational definitions and MCS theory)
  - Module list with descriptions (4 modules, all sorry-free)
  - Dependency flowchart
  - Key theorems (Lindenbaum's Lemma, MCS properties)
  - Removed all Boneyard references
- [x] Create Soundness/README.md:
  - Purpose (soundness of proof system)
  - Module list (2 modules, both sorry-free)
  - Coverage: 15 axioms, 7 rules (all listed)
  - Technical details on temporal duality and time-shift

**Timing**: 1.5 hours (actual: 30 minutes)

**Files modified**:
- `Theories/Bimodal/Metalogic/Core/README.md` (REWRITTEN)
- `Theories/Bimodal/Metalogic/Soundness/README.md` (NEW)

**Verification**:
- Each README follows standard format with status header
- Flowcharts accurate
- No Boneyard dependencies mentioned

---

### Phase 8: README - FMP/ and Completeness/ [COMPLETED]

**Goal**: Create comprehensive README.md files for FMP/ and Completeness/

**Tasks**:
- [x] Rewrite FMP/README.md:
  - "Self-Contained (No Boneyard Dependencies)" status header
  - Purpose (Finite Model Property)
  - Module list with sorry status (5 modules)
  - Dependency flowchart
  - Architectural sorry explanation (Task 750 research)
  - Canonical completeness result documentation
- [x] Rewrite Completeness/README.md:
  - "Self-Contained (No Boneyard Dependencies)" status header
  - Purpose (completeness theorem hierarchy)
  - Module list (4 modules, all sorry-free)
  - Proof architecture diagram
  - Soundness integration note (now uses migrated Soundness/)

**Timing**: 1.5 hours (actual: 20 minutes)

**Files modified**:
- `Theories/Bimodal/Metalogic/FMP/README.md` (REWRITTEN)
- `Theories/Bimodal/Metalogic/Completeness/README.md` (REWRITTEN)

**Verification**:
- Standard format followed with status headers
- FMP documents architectural sorries and rationale
- Completeness documents sorry-free hierarchy

---

### Phase 9: README - Representation/ and Compactness/ [COMPLETED]

**Goal**: Create comprehensive README.md files for Representation/ and Compactness/

**Tasks**:
- [x] Rewrite Representation/README.md:
  - "Self-Contained (No Boneyard Dependencies)" status header
  - Purpose (canonical model construction)
  - All 7 modules with status
  - Dependency flowchart
  - Main result theorem signature
  - Proof architecture diagram
  - Architectural sorry explanations (not required for completeness)
- [x] Rewrite Compactness/README.md:
  - "Self-Contained (No Boneyard Dependencies)" status header
  - Purpose (compactness theorem)
  - Module list (1 module, sorry-free)
  - Updated dependency note (Soundness now self-contained)

**Timing**: 1.5 hours (actual: 15 minutes)

**Files modified**:
- `Theories/Bimodal/Metalogic/Representation/README.md` (REWRITTEN)
- `Theories/Bimodal/Metalogic/Compactness/README.md` (UPDATED)

**Verification**:
- All modules documented with status headers
- Flowcharts correct
- Soundness dependency now refers to migrated Soundness/

---

### Phase 10: Top-Level Metalogic/README.md [COMPLETED]

**Goal**: Create comprehensive top-level README with complete architectural overview

**Tasks**:
- [x] Rewrite Metalogic/README.md with sections:
  1. **Status header**: "Self-Contained (NO Boneyard Dependencies as of 2026-01-29)"
  2. **What the Metalogic Establishes** - 5 main results
  3. **Main Results** - Theorem signatures for all major results
  4. **Architecture Overview** - Full directory tree with file purposes
  5. **Dependency Layers** - 6-layer diagram
  6. **Subdirectory Summaries** - Table with status for all 7 directories
  7. **Known Architectural Limitations** - Table with explanations
  8. **Migration Notes** - Documentation of 2026-01-29 migration

**Timing**: 1 hour (actual: 20 minutes)

**Files modified**:
- `Theories/Bimodal/Metalogic/README.md` (FULLY REWRITTEN)

**Verification**:
- High-level overview is clear and accurate
- Architecture diagram shows all 7 subdirectories
- "Self-Contained" status prominently documented
- Migration notes explain what was done

## Testing & Validation

- [ ] `lake build` succeeds after all phases
- [ ] `grep -r "import.*Boneyard" Theories/Bimodal/Metalogic/` returns NOTHING
- [ ] Every subdirectory has complete README.md
- [ ] All flowcharts use consistent convention
- [ ] Top-level README provides accurate architectural overview
- [ ] All cross-references and links work

## Artifacts & Outputs

**New Files**:
- `Theories/Bimodal/Metalogic/Core/MCSTheory.lean` - Migrated MCS theory
- `Theories/Bimodal/Metalogic/Soundness/Soundness.lean` - Main soundness theorem
- `Theories/Bimodal/Metalogic/Soundness/AxiomValidity.lean` - Axiom validity lemmas
- `Theories/Bimodal/Metalogic/Soundness/RulePreservation.lean` - Rule preservation lemmas
- `Theories/Bimodal/Metalogic/Soundness/README.md` - Soundness documentation

**Modified Files**:
- All import statements removing Boneyard references
- All README.md files in Metalogic/ hierarchy
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Updated aggregator

**Summary**:
- `specs/764_improve_metalogic_structure_and_documentation/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

- Git commits per phase enable selective rollback
- If MCS migration breaks proofs:
  - Identify specific breaking change
  - Fix or revert that specific change
  - Consider splitting migration into smaller pieces
- If Soundness migration has hidden dependencies:
  - Trace dependency chain
  - Migrate additional dependencies as needed
  - Document unexpected dependencies

## Phase Summary

| Phase | Goal | Hours | Lean? |
|-------|------|-------|-------|
| 1 | MCS Theory Migration | 5-6 | Yes |
| 2 | Soundness Proof Migration | 5-6 | Yes |
| 3 | FMP/Closure Fix | 0.5 | Yes |
| 4 | Verify Zero Boneyard Imports | 0.5 | No |
| 5 | Algebraic/ Documentation | 1.5 | No |
| 6 | Code Quality Improvements | 1.5 | Partial |
| 7 | README - Core/ & Soundness/ | 1.5 | No |
| 8 | README - FMP/ & Completeness/ | 1.5 | No |
| 9 | README - Representation/ & Compactness/ | 1.5 | No |
| 10 | Top-Level README | 1 | No |
| **Total** | | **18-22** | |
