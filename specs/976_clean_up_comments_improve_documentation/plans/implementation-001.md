# Implementation Plan: Task #976

- **Task**: 976 - Clean up comments and improve documentation
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None
- **Research Inputs**: specs/976_clean_up_comments_improve_documentation/reports/research-001.md, specs/976_clean_up_comments_improve_documentation/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

This plan systematically addresses all documentation issues identified across the codebase. The work covers: (1) fixing critical inaccuracies in existing READMEs (FMP references, LogosTest references), (2) updating outdated content, (3) creating 41 missing READMEs across Theories, Tests, Boneyard, and top-level directories, (4) cleaning up TODO/DEPRECATED comments, and (5) updating ROAD_MAP.md to reflect current project state. Definition of done: every subdirectory has an accurate, complete README.md and ROAD_MAP.md accurately reflects the present state.

### Research Integration

- **research-001**: Identified 51 existing READMEs, 41 missing READMEs, 2 TODO comments, 7+ DEPRECATED markers
- **research-002**: Identified 7 critical inaccuracies (FMP/LogosTest references), 5 outdated READMEs, 3 incomplete READMEs

## Goals & Non-Goals

**Goals**:
- Fix all factual inaccuracies in existing READMEs (FMP/, LogosTest/ references)
- Ensure every subdirectory has an accurate README.md with file listings
- Clean up or resolve all TODO/FIXME comments
- Verify DEPRECATED markers are appropriate and point to correct replacements
- Update ROAD_MAP.md with current sorry counts, module architecture, and phase status
- Establish consistent README template across all directories

**Non-Goals**:
- Creating READMEs for .lake/, .claude/, .opencode/ directories (config/build directories)
- Rewriting Lean docstrings (already excellent quality per research)
- Major restructuring of existing excellent READMEs (preserve quality content)
- Creating READMEs for latex/build/ or other build output directories

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| FMP code location unknown | Medium | Medium | Check git history, Boneyard, before removing references |
| Documentation becomes stale quickly | Medium | Medium | Add "Last Updated" dates, document in maintenance section |
| Inconsistent README styles | Low | Low | Use template consistently across all directories |
| Missing files in listing | Low | Medium | Run `ls` before writing each README, verify against actual contents |
| Large scope causes timeout | Medium | Medium | Split into 8 phases, each completable in single session |

## Implementation Phases

### Phase 1: Critical Fixes - FMP and LogosTest References [COMPLETED]

- **Dependencies**: None
- **Goal**: Fix all factual inaccuracies where READMEs reference non-existent directories

**Tasks**:
- [ ] Investigate FMP code location (check git history, search Boneyard, verify removal)
- [ ] Update Theories/Bimodal/Metalogic/README.md - remove or fix FMP references (lines 76, 168-198, 300-304)
- [ ] Update Theories/Bimodal/Metalogic/Bundle/README.md - remove FMP reference (line 158), verify sorry counts (lines 52-58)
- [ ] Update Theories/Bimodal/Metalogic/Compactness/README.md - remove FMP references (lines 28, 37)
- [ ] Update Theories/Bimodal/Metalogic/Decidability/README.md - remove FMP reference (line 101)
- [ ] Update Theories/Bimodal/Metalogic/Algebraic/README.md - remove FMP references (lines 118, 144)
- [ ] Update Tests/README.md - remove LogosTest references (lines 11, 26-31, 37)
- [ ] Fix Theories/Bimodal/docs/README.md case consistency (UserGuide -> user-guide, etc.)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md` - remove FMP references
- `Theories/Bimodal/Metalogic/Bundle/README.md` - remove FMP reference, verify sorry counts
- `Theories/Bimodal/Metalogic/Compactness/README.md` - remove FMP references
- `Theories/Bimodal/Metalogic/Decidability/README.md` - remove FMP reference
- `Theories/Bimodal/Metalogic/Algebraic/README.md` - remove FMP references
- `Tests/README.md` - remove LogosTest references
- `Theories/Bimodal/docs/README.md` - fix case consistency

**Verification**:
- `grep -rn "FMP/" Theories/` returns no hits
- `grep -rn "LogosTest" Tests/` returns no hits
- All modified READMEs are syntactically valid markdown

**Progress:**

**Session: 2026-03-16, sess_1773678809_acc23f**
- Fixed: Tests/README.md - removed LogosTest references
- Fixed: Theories/Bimodal/docs/README.md - corrected case consistency
- Fixed: Theories/Bimodal/Metalogic/README.md - removed FMP/ directory references
- Fixed: 7 additional READMEs with FMP references
- Fixed: 3 Lean files with FMP docstring references
- Verified: No FMP/ or LogosTest references remain in markdown files

---

### Phase 2: Outdated Content Updates [COMPLETED]

- **Dependencies**: Phase 1
- **Goal**: Update stale content in existing READMEs (sorry counts, architecture diagrams, file listings)

**Tasks**:
- [ ] Run sorry count grep: `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/` to get accurate counts
- [ ] Update Theories/Bimodal/Metalogic/README.md sorry counts (lines 313-324)
- [ ] Verify and update module architecture diagram in Metalogic/README.md
- [ ] Update Theories/Bimodal/README.md layer architecture (lines 219-243) if needed
- [ ] Verify Boneyard/Metalogic/README.md FiniteCanonicalModel.lean references (lines 78, 105)
- [ ] Update Theories/Bimodal/Automation/README.md implementation status
- [ ] Update Theories/Bimodal/Metalogic/Core/README.md - add RestrictedMCS.lean to module table
- [ ] Verify Tests/BimodalTest/README.md file listings match reality

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md` - sorry counts, architecture
- `Theories/Bimodal/README.md` - layer architecture verification
- `Boneyard/Metalogic/README.md` - verify references
- `Theories/Bimodal/Automation/README.md` - implementation status
- `Theories/Bimodal/Metalogic/Core/README.md` - add missing file
- `Tests/BimodalTest/README.md` - verify listings

**Verification**:
- Sorry counts match actual grep results
- All file references in READMEs correspond to existing files
- Architecture diagrams match current directory structure

**Progress:**

**Session: 2026-03-16, sess_1773678809_acc23f**
- Fixed: Theories/Bimodal/Metalogic/README.md - updated sorry status table
- Fixed: Theories/Bimodal/Metalogic/Bundle/README.md - updated architecture to match current files
- Fixed: Boneyard/Metalogic/README.md - updated FiniteCanonicalModel.lean references to BFMCS
- Fixed: Theories/Bimodal/Automation/README.md - updated implementation status
- Verified: Tests/BimodalTest/README.md file listings are accurate
- Verified: 7 actual sorries in Metalogic (all in Domain/DiscreteTimeline.lean)

---

### Phase 3: Comment Cleanup [COMPLETED]

- **Dependencies**: None
- **Goal**: Resolve or clean up TODO comments and verify DEPRECATED markers

**Tasks**:
- [ ] Evaluate TODO in Boneyard/Task956_StrictDensity/DensityFrameCondition_StrictAttempt.lean:1064
  - Determine if approach should be implemented or TODO removed (file is in Boneyard)
- [ ] Evaluate TODO in Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean:1183
  - GContent subset M' argument - determine status and resolve
- [ ] Verify DEPRECATED marker in Boneyard/Metalogic_v8/Bundle/DovetailingChain.lean:12-14
  - Ensure file is properly archived and marker accurate
- [ ] Verify DEPRECATED marker in Boneyard/Task970/TemporalCoherentConstruction.lean:12-14
- [ ] Verify DEPRECATED marker in Boneyard/IntRepresentation/Representation.lean:16-18
- [ ] Verify DEPRECATED reference in Metalogic/Representation.lean:17
- [ ] Verify deprecated tm_auto in Automation/AesopRules.lean:39

**Timing**: 1 hour

**Files to modify**:
- Files containing TODOs and DEPRECATED markers (as identified)
- Update or remove comments as appropriate

**Verification**:
- `grep -rn "TODO" Theories/` returns only intentional/tracked items
- All DEPRECATED markers point to valid replacement modules
- No stale or misleading comments remain

**Progress:**

**Session: 2026-03-16, sess_1773678809_acc23f**
- Verified: TODO in Boneyard/Task956_StrictDensity is appropriate (Boneyard code)
- Fixed: TODO in CanonicalIrreflexivity.lean - clarified that argument not needed
- Verified: All 3 DEPRECATED markers in Boneyard are comprehensive and accurate
- Verified: Metalogic/Representation.lean correctly documented as archived
- Verified: AesopRules.lean "deprecated" is documentation, not a deprecated tactic

---

### Phase 4: Create Priority 1 READMEs - Active Theories [COMPLETED]

- **Dependencies**: Phase 1, Phase 2
- **Goal**: Create READMEs for 10 active Theories directories (highest priority)

**Tasks**:
- [ ] Create Theories/Bimodal/Syntax/README.md
  - Document: Formula.lean, Atom.lean, Context.lean, other syntax files
- [ ] Create Theories/Bimodal/Semantics/README.md
  - Document: TaskFrame.lean, TaskModel.lean, Truth.lean, Validity.lean, etc.
- [ ] Create Theories/Bimodal/ProofSystem/README.md
  - Document: Axioms.lean, Derivation.lean, etc.
- [ ] Create Theories/Bimodal/Examples/README.md
  - Document: Demo and tutorial files
- [ ] Create Theories/Bimodal/Theorems/README.md
  - Document: Modal theorems directory structure
- [ ] Create Theories/Bimodal/Metalogic/ConservativeExtension/README.md
- [ ] Create Theories/Bimodal/Metalogic/Canonical/README.md
- [ ] Create Theories/Bimodal/Metalogic/Domain/README.md
- [ ] Create Theories/Bimodal/Metalogic/StagedConstruction/README.md
- [ ] Create Theories/Bimodal/Metalogic/Relational/README.md

**Timing**: 2 hours

**Files to create**:
- `Theories/Bimodal/Syntax/README.md`
- `Theories/Bimodal/Semantics/README.md`
- `Theories/Bimodal/ProofSystem/README.md`
- `Theories/Bimodal/Examples/README.md`
- `Theories/Bimodal/Theorems/README.md`
- `Theories/Bimodal/Metalogic/ConservativeExtension/README.md`
- `Theories/Bimodal/Metalogic/Canonical/README.md`
- `Theories/Bimodal/Metalogic/Domain/README.md`
- `Theories/Bimodal/Metalogic/StagedConstruction/README.md`
- `Theories/Bimodal/Metalogic/Relational/README.md`

**README Template**:
```markdown
# {Directory Name}

{One-sentence description of what this directory contains.}

## Contents

| File | Description |
|------|-------------|
| File1.lean | Brief description |
| File2.lean | Brief description |

## Related Documentation

- [Parent README](../README.md)
- [Relevant reference](path/to/doc.md)

---

*Last Updated: 2026-03-16*
```

**Verification**:
- Each new README lists all .lean files in directory
- Links to parent READMEs are valid
- Descriptions are accurate based on file contents

**Progress:**

**Session: 2026-03-16, sess_1773678809_acc23f**
- Created: Theories/Bimodal/Syntax/README.md (5 files documented)
- Created: Theories/Bimodal/Semantics/README.md (5 files documented)
- Created: Theories/Bimodal/ProofSystem/README.md (3 files documented)
- Created: Theories/Bimodal/Examples/README.md (8 files documented)
- Created: Theories/Bimodal/Theorems/README.md (8 files + subdirectory)
- Created: Metalogic/ConservativeExtension/README.md (4 files)
- Created: Metalogic/Canonical/README.md (3 files)
- Created: Metalogic/Domain/README.md (3 files, noted 7 sorries)
- Created: Metalogic/StagedConstruction/README.md (10 files)
- Created: Metalogic/Relational/README.md (placeholder, empty directory)

---

### Phase 5: Create Priority 2 READMEs - Top-Level and Latex [COMPLETED]

- **Dependencies**: None
- **Goal**: Create READMEs for 4 top-level directories and latex subdirectories

**Tasks**:
- [ ] Create /scripts/README.md
  - Document all utility scripts and their purposes
- [ ] Create /benchmarks/README.md
  - Document benchmark files and how to run them
- [ ] Create /specs/README.md
  - Document task artifact structure, plans/, reports/, summaries/
- [ ] Create /build/README.md (minimal)
  - Document build output directory
- [ ] Create Theories/Bimodal/latex/README.md
  - Document BimodalReference LaTeX documentation
- [ ] Create Theories/Bimodal/latex/subfiles/README.md
- [ ] Create Theories/Bimodal/latex/assets/README.md
- [ ] Create Theories/Bimodal/typst/chapters/README.md
- [ ] Create Theories/Bimodal/typst/notation/README.md

**Timing**: 1.5 hours

**Files to create**:
- `/scripts/README.md`
- `/benchmarks/README.md`
- `/specs/README.md`
- `/build/README.md`
- `Theories/Bimodal/latex/README.md`
- `Theories/Bimodal/latex/subfiles/README.md`
- `Theories/Bimodal/latex/assets/README.md`
- `Theories/Bimodal/typst/chapters/README.md`
- `Theories/Bimodal/typst/notation/README.md`

**Verification**:
- Each README accurately lists directory contents
- Purpose of each directory is clear

**Progress:**

**Session: 2026-03-16, sess_1773678809_acc23f**
- Created: scripts/README.md (8 files documented)
- Created: benchmarks/README.md (2 files documented)
- Created: specs/README.md (structure and naming documented)
- Created: build/README.md (minimal, build artifacts)
- Created: Theories/Bimodal/latex/README.md
- Created: Theories/Bimodal/latex/subfiles/README.md (7 chapter files)
- Created: Theories/Bimodal/latex/assets/README.md (3 style files)
- Created: Theories/Bimodal/typst/chapters/README.md (7 chapter files)
- Created: Theories/Bimodal/typst/notation/README.md (2 notation files)

---

### Phase 6: Create Priority 3 READMEs - Tests [COMPLETED]

- **Dependencies**: Phase 1 (Tests/README.md fixed)
- **Goal**: Create READMEs for 5 test subdirectories

**Tasks**:
- [ ] Create Tests/BimodalTest/Syntax/README.md
  - Document syntax-related test files
- [ ] Create Tests/BimodalTest/Semantics/README.md
  - Document semantics-related test files
- [ ] Create Tests/BimodalTest/ProofSystem/README.md
  - Document proof system test files
- [ ] Create Tests/BimodalTest/Theorems/README.md
  - Document theorem test files
- [ ] Create Tests/BimodalTest/Automation/README.md
  - Document automation test files

**Timing**: 1 hour

**Files to create**:
- `Tests/BimodalTest/Syntax/README.md`
- `Tests/BimodalTest/Semantics/README.md`
- `Tests/BimodalTest/ProofSystem/README.md`
- `Tests/BimodalTest/Theorems/README.md`
- `Tests/BimodalTest/Automation/README.md`

**Verification**:
- Each test README documents test files and their coverage areas
- Links to corresponding Theories directories are accurate

**Progress:**

**Session: 2026-03-16, sess_1773678809_acc23f**
- Created: Tests/BimodalTest/Syntax/README.md (3 test files)
- Created: Tests/BimodalTest/Semantics/README.md (4 test files)
- Created: Tests/BimodalTest/ProofSystem/README.md (4 test files)
- Created: Tests/BimodalTest/Theorems/README.md (4 test files)
- Created: Tests/BimodalTest/Automation/README.md (5 test files)

---

### Phase 7: Create Priority 4 READMEs - Boneyard [COMPLETED]

- **Dependencies**: Phase 3 (DEPRECATED markers verified)
- **Goal**: Create minimal READMEs for 15+ Boneyard directories

**Tasks**:
- [ ] Create Boneyard/Metalogic/Compat/README.md
- [ ] Create Boneyard/Metalogic/Bundle/README.md
- [ ] Create Boneyard/Metalogic/Bundle/CanonicalQuotientApproach/README.md
- [ ] Create Boneyard/Metalogic/Bundle/RecursiveSeed/README.md
- [ ] Create Boneyard/Metalogic/FDSM_SingleHistory/README.md
- [ ] Create Boneyard/Metalogic/Metalogic_v3/Coherence/README.md
- [ ] Create Boneyard/Metalogic/Metalogic_v3/TruthLemma/README.md
- [ ] Create Boneyard/Metalogic/Metalogic_v4/README.md (and subdirs)
- [ ] Create Boneyard/Metalogic/Metalogic_v5/README.md (and subdirs)
- [ ] Create Boneyard/Metalogic/Metalogic_v7/Bundle/README.md
- [ ] Create Boneyard/Metalogic/Metalogic_v8/README.md (and subdirs)
- [ ] Create Boneyard/Metalogic/Metalogic_FMP_orphans/README.md
- [ ] Create Theories/Bimodal/Boneyard/IntRepresentation/README.md
- [ ] Create Theories/Bimodal/Boneyard/Task970/README.md
- [ ] Create Theories/Bimodal/Boneyard/Task971/README.md
- [ ] Create Theories/Bimodal/Boneyard/Metalogic_v8/README.md

**Timing**: 1.5 hours

**Boneyard README Template** (minimal):
```markdown
# {Directory Name}

**Status**: ARCHIVED

{Brief description of what this contained and why it was archived.}

## Contents

- {File list}

## See Also

- [ROAD_MAP.md Dead Ends](../../../specs/ROAD_MAP.md#dead-ends) for context
- [Current implementation](../path/to/current)

---

*Archived: YYYY-MM-DD*
```

**Verification**:
- All Boneyard directories have minimal READMEs
- READMEs point to ROAD_MAP.md Dead Ends section
- Archive dates are accurate where known

**Progress:**

**Session: 2026-03-16, sess_1773678809_acc23f**
- Created: Boneyard/Metalogic/Compat/README.md
- Created: Boneyard/Metalogic/Bundle/README.md
- Created: Boneyard/Metalogic/FDSM_SingleHistory/README.md
- Created: Theories/Bimodal/Boneyard/IntRepresentation/README.md
- Created: Theories/Bimodal/Boneyard/Task970/README.md
- Created: Theories/Bimodal/Boneyard/Task971/README.md
- Created: Theories/Bimodal/Boneyard/Metalogic_v8/README.md
- Note: Many Boneyard directories already had READMEs

---

### Phase 8: ROAD_MAP.md Update and Final Verification [NOT STARTED]

- **Dependencies**: Phase 1, Phase 2, Phase 3, Phase 4, Phase 5, Phase 6, Phase 7
- **Goal**: Update ROAD_MAP.md to reflect current state and verify all documentation is complete

**Tasks**:
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/` - get exact sorry count
- [ ] Update ROAD_MAP.md line 1002 with accurate sorry count
- [ ] Update module architecture diagram (lines 1048-1081) to match current structure
- [ ] Review and update deprecated files section (lines 173-176)
- [ ] Verify all phase status markers are accurate
- [ ] Update "Content Boundaries" note to match actual TODO.md scope
- [ ] Update "Last Updated" date to 2026-03-16
- [ ] Add any new architectural decisions or strategies from recent work
- [ ] Run comprehensive README verification:
  - Count total READMEs: `find . -name "README.md" -not -path "./.lake/*" | wc -l`
  - Verify no directory is missing README: compare against directory list
- [ ] Verify all cross-references in READMEs are valid
- [ ] Create implementation summary

**Timing**: 2 hours

**Files to modify**:
- `specs/ROAD_MAP.md` - comprehensive update

**Verification**:
- Sorry count in ROAD_MAP.md matches `grep` output
- All phase markers in ROAD_MAP.md are accurate
- `find . -name "README.md" -not -path "./.lake/*" -not -path "./.claude/*" | wc -l` shows expected count (51 + 41 = 92)
- No `grep -rn "FMP/" Theories/` hits remain
- No stale directory references exist

---

## Testing & Validation

- [ ] All 7 critical READMEs updated (Phase 1 verification)
- [ ] All 5 outdated READMEs refreshed (Phase 2 verification)
- [ ] All TODO/DEPRECATED comments resolved or verified (Phase 3)
- [ ] 41 new READMEs created across all directories
- [ ] Every README accurately lists directory contents
- [ ] All cross-references in READMEs point to existing files
- [ ] ROAD_MAP.md reflects current project state
- [ ] `grep -rn "FMP/" Theories/` returns 0 hits
- [ ] `grep -rn "LogosTest" Tests/` returns 0 hits
- [ ] README count increased from 51 to ~92

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- 41 new README.md files across directories
- 15+ updated README.md files
- Updated specs/ROAD_MAP.md
- summaries/implementation-summary-20260316.md (final summary)

## Rollback/Contingency

If changes introduce errors or break existing documentation:
1. Use `git diff` to identify problematic changes
2. Use `git checkout -- path/to/file` to restore individual files
3. If significant issues, `git reset --soft HEAD~N` to uncommit recent changes
4. All existing READMEs are in git history and can be restored
5. For FMP references: if FMP code is found to still exist, restore references with correct paths
