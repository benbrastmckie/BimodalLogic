# Implementation Plan: Task #183

- **Task**: 183 - Documentation Standards: READMEs and Comments
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: 131, 175 (structural refactoring tasks should complete first)
- **Research Inputs**: specs/183_documentation_standards_readmes_comments/reports/01_documentation-audit.md
- **Artifacts**: plans/01_documentation-standards.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Establish comprehensive documentation standards for the Theories/Bimodal/ tree and systematically apply them. The research audit found 100% module docstring coverage (152/152 files) and 2983 API docstrings, but 8 directories lack READMEs and 6 existing READMEs are stale or severely stale (e.g., ProofSystem claims "15 axioms" when there are 40). This plan addresses four deliverables: (A) README standard with systematic creation and update, (B) module docstring quality standardization, (C) comment convention standard, and (D) root-level documentation with cross-link navigation.

### Research Integration

Key findings from the documentation audit report (01_documentation-audit.md):
- 8 directories missing READMEs: WeakCanonical (17 files), BXCanonical (7+13 in subdirs), FrameConditions (4), Decidability/FMP (7), WeakCanonical/Separation (13), BXCanonical/Chronicle (6), BXCanonical/Quasimodel (6), BXCanonical/Filtration (1)
- 6 stale/severely stale READMEs: ProofSystem (severely stale), Root, Syntax, Metalogic, Decidability, Theorems
- 8 broken file references across READMEs
- Outdated axiom counts in 3 READMEs (claim 15-21, actual is 40)
- Script-assisted inventory generation is feasible for module tables, broken link detection, and stale README detection
- ProofChecker's richer documentation style (vs minimal Mathlib) is appropriate for a research project; adopt Mathlib formatting consistency while keeping depth
- 19 files without API docstrings are all re-export aggregators (appropriate)
- 43 NOTE: comments (17 in SoundnessLemmas.lean documenting removed axioms), 2 TODO: comments, 0 FIX:/QUESTION:

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Define a README template standard for all Lean-containing directories
- Create 8 missing READMEs with accurate file inventories and dependency information
- Update 6 stale READMEs with correct counts, file lists, and cross-references
- Fix all 8 broken file references in existing READMEs
- Define module docstring quality tiers and ensure minimum quality across 152 files
- Define comment convention standard (NOTE:/TODO:/FIX: usage, #check policy)
- Update root Bimodal README with accurate navigation web and cross-links
- Create lint scripts for ongoing README health (inventory generation, broken link detection)

**Non-Goals**:
- Rewriting module docstrings that already meet quality standards (the 80+ "rich" and 37 "extensive" files)
- Adding copyright headers (not part of project convention)
- Removing #check commands that serve as inline API demonstrations
- Changing Boneyard documentation (archived code, out of scope)
- Enforcing API docstrings on re-export aggregator modules (19 files appropriately lack them)
- Building a full CI linting pipeline (scripts are for manual/periodic use)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Stale READMEs re-stale quickly as codebase evolves | M | H | Deliver lint scripts that detect staleness; include "Last verified" dates |
| Axiom/definition counts change during active development | M | M | Use grep-based verification commands in READMEs so counts can be re-checked |
| Large number of files (152) makes quality review slow | L | M | Focus docstring quality work on the ~35 files with minimal (<15 line) docstrings; skip files already meeting standard |
| Dependencies on tasks 131/175 mean directory structure may shift | H | L | Plan is robust to file additions/moves since READMEs are directory-scoped; re-run lint scripts after dependency tasks complete |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Define Standards and Create Lint Scripts [NOT STARTED]

**Goal**: Establish the three documentation standards (README template, module docstring quality tiers, comment conventions) as reference documents, and create shell scripts for automated README health checking.

**Tasks**:
- [ ] Create `Theories/Bimodal/docs/reference/readme-standard.md` defining the README template:
  - Required sections: title, scope description, module inventory table (file, lines, definitions), dependency diagram, cross-links to parent/sibling/child READMEs
  - Optional sections: sorry status, architecture notes, verification commands
  - Include "Last verified: YYYY-MM-DD" field
- [ ] Create `Theories/Bimodal/docs/reference/docstring-standard.md` defining module docstring quality tiers:
  - Tier 1 (Minimal): Re-export aggregators -- title + 1-sentence scope (appropriate for 5 files)
  - Tier 2 (Standard): Main Definitions + Main Results sections (minimum for all definition-bearing files)
  - Tier 3 (Rich): Standard + Implementation Notes or References (encouraged for complex files)
  - Tier 4 (Extensive): Rich + proof strategy, literature references, dependency flowcharts (metalogic files)
- [ ] Create `Theories/Bimodal/docs/reference/comment-convention.md` defining comment tag usage:
  - NOTE: for documenting removed/refactored items (current usage is appropriate)
  - TODO: for planned improvements (keep sparse, prefer task system)
  - FIX: for known bugs requiring attention
  - QUESTION: for design decisions needing discussion
  - #check: permitted in Examples/ and Theorems/ for API demonstration; discouraged in library core
- [ ] Create `scripts/readme-inventory.sh`: Given a directory, output a Markdown module inventory table (file, lines, definition count)
- [ ] Create `scripts/readme-lint.sh`: Check all READMEs for broken file references, missing files in inventories, and outdated counts
- [ ] Test both scripts against the current tree and verify output matches research audit findings

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/docs/reference/readme-standard.md` - Create (new)
- `Theories/Bimodal/docs/reference/docstring-standard.md` - Create (new)
- `Theories/Bimodal/docs/reference/comment-convention.md` - Create (new)
- `scripts/readme-inventory.sh` - Create (new)
- `scripts/readme-lint.sh` - Create (new)

**Verification**:
- All three standard documents exist and are internally consistent
- `scripts/readme-inventory.sh Theories/Bimodal/Syntax` produces a valid Markdown table with 6 rows
- `scripts/readme-lint.sh` detects the known 8 broken file references and flags stale READMEs

---

### Phase 2: Create 8 Missing READMEs [NOT STARTED]

**Goal**: Write READMEs for all 8 directories that contain .lean files but lack documentation, following the standard defined in Phase 1.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/README.md` (17 files -- highest priority)
  - Document the weak canonical model construction approach
  - Include module inventory, dependency relationships, sorry status
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Separation/README.md` (13 files)
  - Document the separation lemma development
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/README.md` (7 files + 3 subdirectories)
  - Document the BX canonical model approach, link to Chronicle/Filtration/Quasimodel subdirs
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/README.md` (6 files)
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/README.md` (6 files)
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Filtration/README.md` (1 file)
- [ ] Create `Theories/Bimodal/FrameConditions/README.md` (4 files)
  - Document frame condition verification and soundness per frame class
- [ ] Create `Theories/Bimodal/Metalogic/Decidability/FMP/README.md` (7 files)
  - Document the finite model property development
- [ ] Use `scripts/readme-inventory.sh` to generate module inventory tables for each README
- [ ] Verify each README passes `scripts/readme-lint.sh` with no errors

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/README.md` - Create (new)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/README.md` - Create (new)
- `Theories/Bimodal/Metalogic/BXCanonical/README.md` - Create (new)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/README.md` - Create (new)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/README.md` - Create (new)
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/README.md` - Create (new)
- `Theories/Bimodal/FrameConditions/README.md` - Create (new)
- `Theories/Bimodal/Metalogic/Decidability/FMP/README.md` - Create (new)

**Verification**:
- All 8 new READMEs exist and follow the template from Phase 1
- Each contains an accurate module inventory table
- Each contains cross-links to parent directory README
- `scripts/readme-lint.sh` reports 0 errors for the 8 new READMEs

---

### Phase 3: Fix Stale READMEs and Broken References [NOT STARTED]

**Goal**: Update the 6 stale READMEs with correct information and fix all 8 broken file references across the tree.

**Tasks**:
- [ ] Rewrite `Theories/Bimodal/ProofSystem/README.md` (severely stale):
  - Update axiom count from "15" to actual count (currently 40 constructors)
  - Add `Substitution.lean` to file listing
  - Regenerate module inventory table
- [ ] Update `Theories/Bimodal/README.md` (root, stale):
  - Fix axiom count from "21 axiom schemata" to correct count
  - Remove references to non-existent `Examples/Demo.lean`, `LogicVariants.lean`, `Metalogic/BaseCompleteness.lean`
  - Update submodule descriptions to match current state
  - Verify inference rule count against DerivationTree
- [ ] Update `Theories/Bimodal/Syntax/README.md` (stale):
  - Add missing `BigConj.lean` to file listing
  - Regenerate module inventory table
- [ ] Update `Theories/Bimodal/Metalogic/README.md` (stale):
  - Remove references to non-existent `Bundle/TruthLemma.lean`, `Bundle/BFMCSTruth.lean`, `Bundle/Completeness.lean`
  - Fix "15 TM axioms" reference in soundness description
  - Update architecture diagram to reflect current file structure
- [ ] Update `Theories/Bimodal/Metalogic/Decidability/README.md` (stale):
  - Add FMP/ subdirectory documentation (7 files)
  - Fix broken `../Soundness/README.md` reference
- [ ] Update `Theories/Bimodal/Theorems/README.md` (stale):
  - Remove non-existent `Discreteness.lean` from listing
  - Add missing `TemporalDerived.lean`
  - Regenerate module inventory table
- [ ] Fix `Theories/Bimodal/Semantics/README.md` broken link:
  - Fix `../Metalogic/Soundness/README.md` reference (Soundness is a file, not a directory)
- [ ] Run `scripts/readme-lint.sh` to verify all broken references are resolved

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/ProofSystem/README.md` - Rewrite
- `Theories/Bimodal/README.md` - Major update
- `Theories/Bimodal/Syntax/README.md` - Update file listing
- `Theories/Bimodal/Metalogic/README.md` - Update architecture and counts
- `Theories/Bimodal/Metalogic/Decidability/README.md` - Add FMP, fix links
- `Theories/Bimodal/Theorems/README.md` - Fix file listing
- `Theories/Bimodal/Semantics/README.md` - Fix broken link

**Verification**:
- `scripts/readme-lint.sh` reports 0 broken file references
- ProofSystem README mentions correct axiom count (verified with `grep -c "| " Theories/Bimodal/ProofSystem/Axioms.lean` or similar)
- All file listings in updated READMEs match actual directory contents
- No references to Demo.lean, LogicVariants.lean, BaseCompleteness.lean, TruthLemma.lean, BFMCSTruth.lean, Bundle/Completeness.lean remain

---

### Phase 4: Module Docstring Quality Pass [NOT STARTED]

**Goal**: Review and upgrade module docstrings that fall below the quality tier appropriate for their file type, focusing on the ~35 files with minimal or thin docstrings.

**Tasks**:
- [ ] Identify all files with docstrings under 15 lines using the thin-docstring detection script from the research report
- [ ] For each re-export aggregator (~5 files: WeakCanonical.lean, Core.lean, BXCanonical.lean, FMCS.lean, etc.):
  - Verify docstring meets Tier 1 (title + scope sentence)
  - Add brief description of what the aggregator re-exports if missing
- [ ] For each definition-bearing file with docstrings under 15 lines (~30 files):
  - Verify it has "Main Definitions" and/or "Main Results" sections
  - Add missing sections where absent
  - Ensure at least Tier 2 compliance
- [ ] Spot-check 10 files from the "standard" tier (16-50 line docstrings) for formatting consistency with the Mathlib-aligned template (heading style, section ordering)
- [ ] Verify FMCS.lean (Bundle) has API docstrings added for its definitions (flagged in research as missing)
- [ ] Run thin-docstring detection script to confirm no files below their tier minimum remain

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- ~5 re-export aggregator `.lean` files - Minor docstring updates
- ~30 definition-bearing `.lean` files - Add Main Definitions/Results sections
- `Theories/Bimodal/Metalogic/Bundle/FMCS.lean` - Add API docstrings

**Verification**:
- Thin-docstring detection script returns 0 files below tier minimum
- FMCS.lean has `/--` docstrings on its public definitions
- Spot-checked files follow consistent section ordering (Main Definitions, Main Results, Implementation Notes, References)

---

### Phase 5: Root Documentation and Cross-Link Navigation [NOT STARTED]

**Goal**: Finalize the root-level Bimodal README as a comprehensive navigation hub with a complete cross-link web, and verify end-to-end documentation consistency.

**Tasks**:
- [ ] Restructure `Theories/Bimodal/README.md` as the primary navigation document:
  - Layer-based directory map (Layer 0: Syntax/ProofSystem, Layer 1: Semantics, Layer 2: Metalogic/FrameConditions, Layer 3: Theorems/Automation, Layer 4: Examples)
  - Cross-reference table showing each directory's README link, file count, and dependency summary
  - Dependency flow diagram (text-based) reflecting the actual import graph from the research report
- [ ] Add cross-link sections to all READMEs (new and updated):
  - "See also" footer with links to parent, sibling, and dependent directory READMEs
  - Ensure bidirectional linking (if A links to B, B links to A)
- [ ] Add "Last verified: 2026-05-21" date to all READMEs touched in this task
- [ ] Run full `scripts/readme-lint.sh` validation across entire tree
- [ ] Verify `lake build` still succeeds (documentation changes should not affect build, but confirm no accidental .lean modifications)

**Timing**: 2 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/README.md` - Final restructure as navigation hub
- All 24 Lean-directory READMEs - Add cross-link footers and verification dates

**Verification**:
- `scripts/readme-lint.sh` reports 0 errors across all 24 READMEs
- Every README links to its parent directory README
- Root README contains links to all 24 Lean-directory READMEs
- `lake build` succeeds without errors
- Cross-link graph has no dangling references (every link target exists)

## Testing & Validation

- [ ] `scripts/readme-lint.sh` reports 0 broken references and 0 missing files across all 24 Lean-directory READMEs
- [ ] `scripts/readme-inventory.sh` output for any directory matches actual file contents
- [ ] All 8 previously missing READMEs exist and follow the template standard
- [ ] All 6 previously stale READMEs have been updated with correct information
- [ ] ProofSystem README axiom count matches actual constructor count in Axioms.lean
- [ ] Root README contains navigation links to all Lean subdirectories
- [ ] All READMEs have "Last verified" dates
- [ ] `lake build` succeeds (no regressions from documentation-only changes)
- [ ] FMCS.lean has API docstrings on public definitions
- [ ] No files with definition-bearing content remain below Tier 2 docstring quality

## Artifacts & Outputs

- `specs/183_documentation_standards_readmes_comments/plans/01_documentation-standards.md` (this plan)
- `Theories/Bimodal/docs/reference/readme-standard.md` (README template standard)
- `Theories/Bimodal/docs/reference/docstring-standard.md` (module docstring quality tiers)
- `Theories/Bimodal/docs/reference/comment-convention.md` (comment tag conventions)
- `scripts/readme-inventory.sh` (module inventory table generator)
- `scripts/readme-lint.sh` (README health checker)
- 8 new READMEs in previously undocumented directories
- 7 updated READMEs with corrected information and cross-links

## Rollback/Contingency

All changes are documentation-only (Markdown files, shell scripts, and Lean docstring comments). No Lean proof code is modified. Rollback is straightforward via `git revert` of any commit. If partial progress is needed, each phase produces independently valuable output: Phase 1 delivers reusable standards and scripts, Phase 2 fills README gaps, Phase 3 fixes existing errors, Phase 4 improves docstring quality, and Phase 5 ties everything together with navigation. The task can be paused after any phase without leaving the codebase in an inconsistent state.
