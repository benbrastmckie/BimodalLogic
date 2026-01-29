# Implementation Plan: Task #764 (Revised)

- **Task**: 764 - improve_metalogic_structure_and_documentation
- **Version**: 002
- **Status**: [IMPLEMENTING]
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

### Phase 1: MCS Theory Migration [IN PROGRESS]

**Goal**: Migrate complete MCS (Maximal Consistent Set) theory from Boneyard to Core/

**Tasks**:
- [ ] Read Boneyard/Metalogic_v2/Core/MaximalConsistent.lean fully (~500 lines)
- [ ] Identify all exports: `Consistent`, `MaximalConsistent`, `SetConsistent`, `SetMaximalConsistent`, `set_lindenbaum`, etc.
- [ ] Create new file Core/MCSTheory.lean (or expand Core/MaximalConsistent.lean)
- [ ] Migrate definitions with improved naming:
  - `Consistent` -> keep (clear)
  - `MaximalConsistent` -> keep (clear)
  - `SetConsistent` -> keep
  - `SetMaximalConsistent` -> keep
  - Helper lemmas with improved doc comments
- [ ] Migrate `set_lindenbaum` (Lindenbaum's Lemma) with full proof
- [ ] Migrate all MCS property lemmas:
  - `maximal_negation_complete`
  - `maximal_consistent_closed`
  - `theorem_in_mcs`
  - `mcs_contains_or_neg`
  - etc.
- [ ] Update Core/MaximalConsistent.lean to import from new location (not Boneyard)
- [ ] Run `lake build` to verify
- [ ] Update all files that import Core/MaximalConsistent to use new exports

**Timing**: 5-6 hours

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/Core/MCSTheory.lean` (NEW - main theory file)
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` (UPDATE imports)
- `Theories/Bimodal/Metalogic/Core/Core.lean` (UPDATE aggregator)

**Verification**:
- `lake build` succeeds
- `grep "import.*Boneyard.*MaximalConsistent" Theories/Bimodal/Metalogic/Core/` returns nothing
- All MCS-dependent files still compile

---

### Phase 2: Soundness Proof Migration [NOT STARTED]

**Goal**: Migrate complete Soundness proof from Boneyard to new Soundness/ subdirectory

**Tasks**:
- [ ] Read Boneyard/Metalogic_v2/Soundness/Soundness.lean (~300 lines)
- [ ] Read Boneyard/Metalogic_v2/Soundness/SoundnessLemmas.lean (~100+ lines)
- [ ] Create new directory: Metalogic/Soundness/
- [ ] Create Soundness/Soundness.lean with:
  - Main theorem: `soundness : DerivationTree Gamma phi -> semantic_consequence Gamma phi`
  - Doc comments explaining structure
- [ ] Create Soundness/AxiomValidity.lean with:
  - All 15 TM axiom validity lemmas
  - Clear organization by axiom type
- [ ] Create Soundness/RulePreservation.lean with:
  - All 7 derivation rule preservation lemmas
- [ ] Create Soundness/README.md with module documentation
- [ ] Update Completeness/WeakCompleteness.lean to import from Soundness/ (not Boneyard)
- [ ] Run `lake build` to verify
- [ ] Update Metalogic.lean aggregator to include Soundness/

**Timing**: 5-6 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Soundness/` (NEW directory)
- `Theories/Bimodal/Metalogic/Soundness/Soundness.lean` (main theorem)
- `Theories/Bimodal/Metalogic/Soundness/AxiomValidity.lean` (axiom lemmas)
- `Theories/Bimodal/Metalogic/Soundness/RulePreservation.lean` (rule lemmas)
- `Theories/Bimodal/Metalogic/Soundness/README.md` (documentation)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` (UPDATE import)
- `Theories/Bimodal/Metalogic/Metalogic.lean` (UPDATE aggregator)

**Verification**:
- `lake build` succeeds
- `grep "import.*Boneyard.*Soundness" Theories/Bimodal/Metalogic/` returns nothing
- WeakCompleteness still compiles and works

---

### Phase 3: FMP/Closure Fix [NOT STARTED]

**Goal**: Update FMP/Closure.lean to use migrated MCS properties instead of Boneyard

**Tasks**:
- [ ] Verify `mcs_contains_or_neg` was migrated in Phase 1
- [ ] Update FMP/Closure.lean import to use Core/MCSTheory (not Boneyard)
- [ ] Run `lake build` to verify
- [ ] Verify FMP/ directory has no remaining Boneyard imports

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/Closure.lean` (UPDATE import)

**Verification**:
- `lake build` succeeds
- `grep "import.*Boneyard" Theories/Bimodal/Metalogic/FMP/` returns nothing

---

### Phase 4: Verify Zero Boneyard Imports [NOT STARTED]

**Goal**: Confirm ALL Boneyard imports eliminated from active Metalogic/

**Tasks**:
- [ ] Run comprehensive grep: `grep -r "import.*Boneyard" Theories/Bimodal/Metalogic/`
- [ ] If any imports found, trace and fix
- [ ] Run full `lake build`
- [ ] Document migration completion

**Timing**: 30 minutes

**Verification**:
- `grep -r "import.*Boneyard" Theories/Bimodal/Metalogic/` returns nothing
- `lake build` succeeds with no warnings

---

### Phase 5: Algebraic/ Documentation [NOT STARTED]

**Goal**: Document Algebraic/ subdirectory as infrastructure for future extensions

**Tasks**:
- [ ] Read all 5 files in Algebraic/
- [ ] Update Algebraic/README.md with:
  - Clear "Future Extension Infrastructure" header
  - Purpose: Alternative algebraic approach to representation theorem
  - Module descriptions for all 5 files
  - Internal dependency flowchart
  - Relationship to main proof path (independent alternative)
  - Future extension opportunities (Stone duality, algebraic topology)
- [ ] Add "Status: Not required for main completeness proof" disclaimer

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/README.md`

**Verification**:
- README clearly indicates future extension status
- All 5 modules documented
- Flowchart correct

---

### Phase 6: Code Quality Improvements [NOT STARTED]

**Goal**: Improve naming conventions, comments, and organization across Metalogic/

**Tasks**:
- [ ] Review and improve doc comments on key theorems
- [ ] Ensure consistent import ordering
- [ ] Update Metalogic.lean aggregator to include:
  - Core/
  - Soundness/ (new)
  - Representation/
  - FMP/
  - Completeness/
  - Compactness/
  - Algebraic/ (with comment noting future extension status)
- [ ] Remove dead code or redundant comments
- [ ] `lake build` after changes

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Metalogic.lean`
- Various files (comments and conventions)

**Verification**:
- `lake build` succeeds
- Aggregator imports all subdirectories
- Key theorems have doc comments

---

### Phase 7: README - Core/ and Soundness/ [NOT STARTED]

**Goal**: Create comprehensive README.md files for Core/ and new Soundness/

**Tasks**:
- [ ] Rewrite Core/README.md:
  - Purpose (foundational definitions and MCS theory)
  - Module list with descriptions
  - Dependency flowchart (foundations above, derivatives below)
  - Key theorems (Lindenbaum's Lemma, MCS properties)
  - Status: Sorry-free
- [ ] Create/update Soundness/README.md (done in Phase 2, verify/enhance):
  - Purpose (soundness of proof system)
  - Module list
  - Coverage: 15 axioms, 7 rules
  - Status: Sorry-free

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/README.md`
- `Theories/Bimodal/Metalogic/Soundness/README.md`

**Verification**:
- Each README follows standard format
- Flowcharts accurate
- No Boneyard dependencies mentioned (they're gone!)

---

### Phase 8: README - FMP/ and Completeness/ [NOT STARTED]

**Goal**: Create comprehensive README.md files for FMP/ and Completeness/

**Tasks**:
- [ ] Rewrite FMP/README.md:
  - Purpose (Finite Model Property)
  - Module list with descriptions
  - Dependency flowchart
  - Explanation: finite model vs infinite canonical model
  - Sorry status with justification (architectural)
- [ ] Rewrite Completeness/README.md:
  - Purpose (weak completeness theorem)
  - Module list
  - Main theorem: `semantic_weak_completeness`
  - Sorry-free main path documentation

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/README.md`
- `Theories/Bimodal/Metalogic/Completeness/README.md`

**Verification**:
- Standard format followed
- FMP explains finite vs infinite model distinction
- Completeness documents sorry-free path

---

### Phase 9: README - Representation/ and Compactness/ [NOT STARTED]

**Goal**: Create comprehensive README.md files for Representation/ and Compactness/

**Tasks**:
- [ ] Rewrite Representation/README.md:
  - Purpose (canonical model construction)
  - All 8 modules with descriptions
  - Complex internal dependency flowchart
  - IndexedMCSFamily explanation
  - Sorry status with justifications
- [ ] Rewrite Compactness/README.md:
  - Purpose (compactness theorem)
  - Module list
  - Relationship to completeness
  - Status

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/README.md`
- `Theories/Bimodal/Metalogic/Compactness/README.md`

**Verification**:
- All modules documented
- Flowcharts correct
- Sorry justifications clear

---

### Phase 10: Top-Level Metalogic/README.md [NOT STARTED]

**Goal**: Create comprehensive top-level README with complete architectural overview

**Tasks**:
- [ ] Rewrite Metalogic/README.md with sections:
  1. **What the Metalogic Establishes** - high-level summary of results
  2. **Main Results** - weak completeness, FMP, compactness with theorem names
  3. **Architecture Overview** - 7-subdirectory diagram (Core, Soundness, Representation, FMP, Completeness, Compactness, Algebraic)
  4. **Full Dependency Flowchart** - all layers, foundations above
  5. **Subdirectory Summaries** - 1-paragraph + link for each
  6. **Self-Contained Status** - NO Boneyard dependencies
  7. **Extension Opportunities** - future work (Algebraic path, etc.)
  8. **Last Assessed** date
- [ ] Verify all subdirectory links work
- [ ] Review for consistency with subdirectory READMEs

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md`

**Verification**:
- High-level overview is clear and accurate
- Flowchart shows all 7 subdirectories
- "Self-Contained" status documented (no Boneyard imports)
- All links work

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
