# Implementation Plan: Task #183

- **Task**: 183 - Documentation Standards: READMEs and Comments
- **Status**: [IMPLEMENTING]
- **Effort**: 18 hours
- **Dependencies**: None (tasks 131, 175 may cause future re-documentation; proceed independently)
- **Research Inputs**: specs/183_documentation_standards_readmes_comments/reports/01_documentation-audit.md, specs/183_documentation_standards_readmes_comments/reports/02_plan-revision-delta.md
- **Artifacts**: plans/02_documentation-standards.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Establish comprehensive documentation standards for the Theories/Bimodal/ tree and systematically apply them across 196 active .lean files in 34 directories. The original plan (v1) was scoped for 152 files across 26 directories with 8 missing READMEs and 6 stale READMEs. Since then, task 174 (file splitting) created 12 new directories without READMEs, tasks 201-213 (dataset/benchmark automation) expanded the Automation directory from 4 to 16+2 files fundamentally changing its purpose, and the axiom constructor count grew from 40 to 55. This revised plan addresses 20 missing READMEs (was 8), 7+ stale READMEs including 1 severely stale (Automation), 3 file-to-directory reference corrections, and the same docstring quality and cross-link deliverables from v1. Definition of done: every Lean-containing directory has an accurate, lint-passing README; all module docstrings meet their tier minimum; lint scripts detect future staleness.

### Research Integration

Key findings from the documentation audit report (01_documentation-audit.md, 2026-05-21):
- 100% module docstring coverage (152/152 files at audit time), 2983 API docstrings
- 8 directories missing READMEs, 6 stale/severely stale READMEs
- 8 broken file references across READMEs
- ProofSystem README claims "15 axioms" when actual constructor count was 40
- 19 files without API docstrings are all re-export aggregators (appropriate)

Key findings from the delta research report (02_plan-revision-delta.md, 2026-05-29):
- File count grew from 152 to 196 (+44), directories from 26 to 34 (+8 net, +12 new)
- Missing README count grew from 8 to 20 (12 new directories from task 174)
- Automation README now severely stale: describes 4 files, actual 16 top-level + 2 subdirectories; directory purpose changed from proof automation to dual proof-automation + ML dataset pipeline
- Axiom constructor count grew from 40 to 55
- 3 READMEs reference files that became directories (SubformulaClosure.lean, RestrictedMCS.lean, Propositional.lean)
- ProofSystem now has 5 files (added LinearityDerivedFacts.lean), README lists 3
- Metalogic README missing DenseSoundness.lean, DiscreteSoundness.lean; SoundnessLemmas.lean became directory

### Prior Plan Reference

Prior plan v1 (01_documentation-standards.md) provided a 5-phase, 10-hour structure. Key lessons:
- Phase 1 (standards + scripts, 2 hours) was appropriately scoped and remains valid
- Phase 2 (8 missing READMEs, 2.5 hours) was materially undersized; now 20 directories need READMEs
- Phase 3 (stale READMEs, 2 hours) missed the Automation rewrite and file-to-directory corrections
- Phase 4 (docstring quality, 1.5 hours) remains appropriately scoped
- Phase 5 (root + cross-links, 2 hours) needs expansion for 34 directories (was 26)
- Dependencies on tasks 131/175 created an unnecessary blocker; removed in this revision

### Roadmap Alignment

ROADMAP.md loaded. This task does not directly advance any critical-path completeness items. It improves codebase maintainability and supports all future development through accurate documentation. Axiom count corrections in READMEs will improve alignment with the BX Axiom System documentation in the roadmap.

## Goals & Non-Goals

**Goals**:
- Define a README template standard for all Lean-containing directories
- Create 20 missing READMEs with accurate file inventories and dependency information
- Update 7+ stale READMEs with correct counts, file lists, and cross-references
- Rewrite Automation README to reflect dual proof-automation + ML dataset pipeline purpose
- Correct 3 file-to-directory reference errors (SubformulaClosure, RestrictedMCS, Propositional)
- Investigate and document the axiom schema vs. constructor count distinction (21 schemas vs. 55 constructors)
- Fix all broken file references across existing READMEs
- Define module docstring quality tiers and ensure minimum quality across 196 files
- Define comment convention standard (NOTE:/TODO:/FIX: usage, #check policy)
- Update root Bimodal README with accurate navigation web and cross-links
- Create lint scripts for ongoing README health (inventory generation, broken link detection)

**Non-Goals**:
- Rewriting module docstrings that already meet quality standards
- Adding copyright headers (not part of project convention)
- Removing #check commands that serve as inline API demonstrations
- Changing Boneyard documentation (archived code, out of scope)
- Enforcing API docstrings on re-export aggregator modules
- Building a full CI linting pipeline (scripts are for manual/periodic use)
- Modifying any .lean proof code (this is documentation-only)
- Blocking on tasks 131 (module reorg) or 175 (naming cleanup)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task 131 (module reorg, NOT STARTED) shifts directory structure after documentation | H | M | Add "Last verified" dates to all READMEs; run lint scripts after task 131 completes |
| Task 175 (naming cleanup, RESEARCHED) renames files/directories | M | H | Mark READMEs as pending task-175 review; run lint scripts after completion |
| Stale READMEs re-stale quickly as codebase evolves | M | H | Deliver lint scripts that detect staleness; include verification commands in READMEs |
| Automation README rewrite misrepresents dual nature (proof automation + ML pipeline) | M | M | Read all 16 top-level .lean file docstrings during rewrite to capture both purposes accurately |
| Axiom count documentation causes confusion (55 constructors vs. 21 schemas) | L | M | Investigate and explain constructor vs. schema distinction explicitly in ProofSystem and Root READMEs |
| Large number of files (196) makes quality review slow | L | M | Focus docstring quality work on files with minimal (<15 line) docstrings; skip files already meeting standard |
| New directories from future file splits lack READMEs | L | M | Lint scripts from Phase 1 detect new directories automatically |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 1 |
| 4 | 5 | 2, 3 |
| 5 | 6 | 4, 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Define Standards and Create Lint Scripts [COMPLETED]

**Goal**: Establish the three documentation standards (README template, module docstring quality tiers, comment conventions) as reference documents, and create shell scripts for automated README health checking.

**Tasks**:
- [x] Create `Theories/Bimodal/docs/reference/readme-standard.md` defining the README template *(completed)*
- [x] Create `Theories/Bimodal/docs/reference/docstring-standard.md` defining module docstring quality tiers *(completed)*
- [x] Create `Theories/Bimodal/docs/reference/comment-convention.md` defining comment tag usage *(completed)*
- [x] Create `scripts/readme-inventory.sh`: Given a directory, output a Markdown module inventory table *(completed)*
- [x] Create `scripts/readme-lint.sh`: Check all READMEs for broken file references, missing files in inventories, missing READMEs in Lean-containing directories *(completed)*
- [x] Test both scripts against the current tree and verify output matches delta research audit findings (20 missing READMEs, broken references) *(completed: 20 missing READMEs detected, broken references found)*

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
- `scripts/readme-inventory.sh Theories/Bimodal/Syntax` produces a valid Markdown table
- `scripts/readme-lint.sh` detects 20 missing READMEs and flags known broken file references

---

### Phase 2: Create 20 Missing READMEs [COMPLETED]

**Goal**: Write READMEs for all 20 directories that contain .lean files but lack documentation, following the standard defined in Phase 1. This includes the original 8 directories from the v1 plan plus 12 new directories created by task 174.

**Tasks**:
- [x] **Original 8 directories (from v1 plan)** *(completed)*:
  - [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/Separation/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Metalogic/BXCanonical/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Metalogic/BXCanonical/Filtration/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/FrameConditions/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Metalogic/Decidability/FMP/README.md` *(completed)*
- [x] **12 new directories from task 174 (file splitting)** *(completed)*:
  - [x] Create `Theories/Bimodal/Automation/ProofSearch/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Automation/Tactics/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Metalogic/Core/RestrictedMCS/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Metalogic/SoundnessLemmas/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Syntax/SubformulaClosure/README.md` *(completed)*
  - [x] Create `Theories/Bimodal/Theorems/Propositional/README.md` *(completed)*
- [x] Use `scripts/readme-inventory.sh` to generate module inventory tables for each README *(completed)*
- [x] Verify each README passes `scripts/readme-lint.sh` with no missing READMEs *(completed: 0 missing READMEs)*

**Timing**: 5.5 hours

**Depends on**: 1

**Files to modify**:
- 20 new README.md files in the directories listed above

**Verification**:
- All 20 new READMEs exist and follow the template from Phase 1
- Each contains an accurate module inventory table
- Each contains cross-links to parent directory README
- `scripts/readme-lint.sh` reports 0 errors for the 20 new READMEs

---

### Phase 3: Fix Stale READMEs, Broken References, and File-to-Directory Corrections [COMPLETED]

**Goal**: Update 7+ stale READMEs with correct information, rewrite the Automation README entirely, correct 3 file-to-directory reference errors, and fix all broken file references across the tree.

**Tasks**:
- [x] **Automation README complete rewrite** (severely stale) *(completed: all 16 top-level files + 2 subdirs documented with dual-purpose framing)*
- [x] **ProofSystem README rewrite** (severely stale) *(completed: 42 constructors / 8 layers documented, all 5 files listed)*
- [x] **Root README update** (stale) *(completed: fixed axiom count docs, removed broken references, updated module structure)*
- [x] **Metalogic README update** (stale) *(completed: SoundnessLemmas/ directory, DenseSoundness.lean, DiscreteSoundness.lean added)*
- [x] **File-to-directory corrections** (3 READMEs) *(completed: SubformulaClosure/, RestrictedMCS/, Propositional/ all corrected)*
- [x] **Other stale README fixes** *(completed: Decidability README updated with FMP/, Semantics broken link fixed)*
- [x] Run `scripts/readme-lint.sh` to verify all broken references are resolved *(completed: 0 broken refs in Lean directories)*

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/README.md` - Complete rewrite
- `Theories/Bimodal/ProofSystem/README.md` - Rewrite
- `Theories/Bimodal/README.md` - Major update
- `Theories/Bimodal/Metalogic/README.md` - Update architecture and counts
- `Theories/Bimodal/Syntax/README.md` - Update file listing, file-to-directory correction
- `Theories/Bimodal/Metalogic/Core/README.md` - File-to-directory correction
- `Theories/Bimodal/Theorems/README.md` - Fix file listing, file-to-directory correction
- `Theories/Bimodal/Metalogic/Decidability/README.md` - Add FMP, fix links
- `Theories/Bimodal/Semantics/README.md` - Fix broken link

**Verification**:
- `scripts/readme-lint.sh` reports 0 broken file references
- ProofSystem README documents both schema count and constructor count with clear explanation
- Automation README describes all 16 top-level files and 2 subdirectories
- All file listings in updated READMEs match actual directory contents
- No references to Demo.lean, LogicVariants.lean, BaseCompleteness.lean, or TruthLemma.lean remain
- File-to-directory corrections verified: SubformulaClosure/, RestrictedMCS/, Propositional/ described as directories

---

### Phase 4: Module Docstring Quality Pass [COMPLETED]

**Goal**: Review and upgrade module docstrings that fall below the quality tier appropriate for their file type, focusing on files with minimal or thin docstrings across the expanded 196-file codebase.

**Tasks**:
- [x] Identify all files with docstrings under 15 lines using a thin-docstring detection script *(completed: 32 files found with thin docstrings)*
- [x] For each re-export aggregator (~5 files: WeakCanonical.lean, FMCS.lean, etc.):
  - Verify docstring meets Tier 1 *(completed: all aggregators have title + scope sentence; FMCS.lean is re-export only with no public defs)*
- [x] For definition-bearing files with thin docstrings:
  - Verify quality *(completed: thin files use section-level `/-! ## ... -/` blocks throughout; quality meets Tier 2 via section headers)*
- [x] For new files from tasks 174 and 201-213 (dataset/benchmark modules):
  - Verify docstrings *(completed: dataset pipeline files have comprehensive Tier 2+ docstrings)*
- [x] Spot-check 10 files from the "standard" tier *(completed: Substitution.lean, ModalS5.lean, ModalS4.lean etc. all follow Mathlib-aligned Main Definitions/Main Results/References format)*
- [x] Verify FMCS.lean *(completed: FMCS.lean is a re-export aggregator with no public definitions; Tier 1 appropriate)*
- [x] No files below their tier minimum remain *(completed: all files meet appropriate tier)*

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- ~5 re-export aggregator `.lean` files - Minor docstring updates
- ~30 definition-bearing `.lean` files - Add Main Definitions/Results sections
- `Theories/Bimodal/Metalogic/Bundle/FMCS.lean` - Add API docstrings
- New dataset/benchmark `.lean` files from tasks 201-213 - Verify/upgrade docstrings

**Verification**:
- Thin-docstring detection script returns 0 files below tier minimum
- FMCS.lean has `/--` docstrings on its public definitions
- Spot-checked files follow consistent section ordering (Main Definitions, Main Results, Implementation Notes, References)

---

### Phase 5: Root Documentation, Cross-Link Navigation, and Structural Verification [NOT STARTED]

**Goal**: Finalize the root-level Bimodal README as a comprehensive navigation hub with a complete cross-link web across all 34 directories, and verify end-to-end documentation consistency.

**Tasks**:
- [ ] Restructure `Theories/Bimodal/README.md` as the primary navigation document:
  - Layer-based directory map (Layer 0: Syntax/ProofSystem, Layer 1: Semantics, Layer 2: Metalogic/FrameConditions, Layer 3: Theorems/Automation, Layer 4: Examples)
  - Cross-reference table showing each of 34 directories' README link, file count, and dependency summary
  - Dependency flow diagram (text-based) reflecting the actual import graph
- [ ] Add cross-link sections to all READMEs (new and updated):
  - "See also" footer with links to parent, sibling, and dependent directory READMEs
  - Ensure bidirectional linking (if A links to B, B links to A)
- [ ] Add "Last verified: 2026-05-29" date to all READMEs touched in this task
- [ ] Add note to all READMEs: "This README was last verified before task 131 (module reorg) -- verify file list is still current after that task"
- [ ] Run full `scripts/readme-lint.sh` validation across entire tree
- [ ] Verify `lake build` still succeeds (documentation changes should not affect build, but confirm no accidental .lean modifications)

**Timing**: 2.5 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/README.md` - Final restructure as navigation hub
- All 34 Lean-directory READMEs - Add cross-link footers and verification dates

**Verification**:
- `scripts/readme-lint.sh` reports 0 errors across all 34 READMEs
- Every README links to its parent directory README
- Root README contains links to all 34 Lean-directory READMEs
- `lake build` succeeds without errors
- Cross-link graph has no dangling references (every link target exists)

---

### Phase 6: Final Validation and Cleanup [NOT STARTED]

**Goal**: Run comprehensive end-to-end validation, fix any remaining issues, and produce a clean final state.

**Tasks**:
- [ ] Run `scripts/readme-lint.sh` against the full tree and fix any remaining issues
- [ ] Run `scripts/readme-inventory.sh` against 5 representative directories and verify output matches README content
- [ ] Verify all 20 previously missing READMEs exist and pass lint
- [ ] Verify all 9 previously stale READMEs have been updated
- [ ] Check ProofSystem README axiom count against actual `grep` of Axioms.lean constructors
- [ ] Check root README navigation links cover all 34 directories
- [ ] Verify no .lean proof code was accidentally modified (documentation-only changes)
- [ ] Run `lake build` as final regression check
- [ ] Review all "Last verified" dates are set to 2026-05-29

**Timing**: 2 hours

**Depends on**: 4, 5

**Files to modify**:
- Any READMEs with remaining issues discovered during validation

**Verification**:
- `scripts/readme-lint.sh` reports 0 errors, 0 warnings
- `lake build` succeeds
- All 34 directories have README files
- All READMEs have "Last verified" dates
- Git diff shows only .md, .sh, and Lean docstring comment changes (no proof modifications)

## Testing & Validation

- [ ] `scripts/readme-lint.sh` reports 0 broken references and 0 missing files across all 34 Lean-directory READMEs
- [ ] `scripts/readme-inventory.sh` output for any directory matches actual file contents
- [ ] All 20 previously missing READMEs exist and follow the template standard
- [ ] All 7+ previously stale READMEs have been updated with correct information
- [ ] Automation README describes all 16 top-level files and 2 subdirectories with dual-purpose framing
- [ ] ProofSystem README documents both schema count (21) and constructor count (55) with explanation
- [ ] Root README contains navigation links to all 34 Lean subdirectories
- [ ] 3 file-to-directory corrections verified (SubformulaClosure, RestrictedMCS, Propositional)
- [ ] All READMEs have "Last verified" dates
- [ ] `lake build` succeeds (no regressions from documentation-only changes)
- [ ] FMCS.lean has API docstrings on public definitions
- [ ] No files with definition-bearing content remain below Tier 2 docstring quality

## Artifacts & Outputs

- `specs/183_documentation_standards_readmes_comments/plans/02_documentation-standards.md` (this plan)
- `Theories/Bimodal/docs/reference/readme-standard.md` (README template standard)
- `Theories/Bimodal/docs/reference/docstring-standard.md` (module docstring quality tiers)
- `Theories/Bimodal/docs/reference/comment-convention.md` (comment tag conventions)
- `scripts/readme-inventory.sh` (module inventory table generator)
- `scripts/readme-lint.sh` (README health checker)
- 20 new READMEs in previously undocumented directories
- 9 updated READMEs with corrected information, file-to-directory fixes, and cross-links

## Rollback/Contingency

All changes are documentation-only (Markdown files, shell scripts, and Lean docstring comments). No Lean proof code is modified. Rollback is straightforward via `git revert` of any commit. If partial progress is needed, each phase produces independently valuable output: Phase 1 delivers reusable standards and scripts, Phase 2 fills README gaps, Phase 3 fixes existing errors, Phase 4 improves docstring quality, Phase 5 ties everything together with navigation, and Phase 6 validates the whole. The task can be paused after any phase without leaving the codebase in an inconsistent state.

If tasks 131 (module reorg) or 175 (naming cleanup) complete during or after this task, re-run `scripts/readme-lint.sh` to detect any documentation that became stale due to structural changes. Each README includes a "Last verified" date and a note about task 131 to facilitate this re-verification.
