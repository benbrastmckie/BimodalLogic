# Implementation Plan: Task #211

- **Task**: 211 - Review and revise docs/ directory
- **Status**: [NOT STARTED]
- **Effort**: 7 hours
- **Dependencies**: None
- **Research Inputs**: specs/211_review_revise_docs_directory/reports/01_docs-review-research.md
- **Artifacts**: plans/01_docs-revision-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Systematically revise the 41 markdown files in docs/ to fix accuracy errors, eliminate stale system references, normalize naming conventions, and resolve content gaps. The research report identified four priority tiers: (1) critical accuracy issues in MODULE_ORGANIZATION.md, API_REFERENCE.md, CONTRIBUTING.md, and others with wrong paths/namespaces/versions; (2) stale .opencode and "Logos" project name references across 8+ files; (3) naming inconsistency between kebab-case research/ files and SCREAMING_SNAKE_CASE elsewhere; (4) missing installation files and content overlap. The plan addresses all four tiers across five phases, ordered by severity and dependency.

### Research Integration

Key findings from the research report (01_docs-review-research.md):
- MODULE_ORGANIZATION.md describes a non-existent `Logos/` directory tree; actual structure is `Theories/Bimodal/`
- API_REFERENCE.md uses wrong namespaces (`Logos.Core.*` instead of `Bimodal.*`) and wrong paths (`Logos/Core/` instead of `Theories/Bimodal/`)
- BASIC_INSTALLATION.md and CONTRIBUTING.md reference Lean v4.14.0 instead of v4.27.0-rc1
- 8 files contain stale .opencode references (48+ occurrences, excluding ADR-004 historical record)
- research/ and training/ directories use kebab-case vs SCREAMING_SNAKE_CASE in all other directories
- 3 missing installation files (CLAUDE_CODE.md, GETTING_STARTED.md, USING_GIT.md) are referenced but do not exist
- MCP_INTEGRATION.md is entirely about the obsolete OpenCode system
- FEATURE_REGISTRY.md describes stale .opencode commands, not Lean features

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items directly correspond to this task. This is a documentation maintenance task that ensures docs/ accuracy for contributors and users.

## Goals & Non-Goals

**Goals**:
- Fix all critical accuracy errors (wrong paths, namespaces, versions, broken links)
- Replace stale .opencode references with current .claude equivalents
- Replace stale "Logos" project/path name references with "ProofChecker"/"BimodalLogic"/"Bimodal" as appropriate
- Normalize file naming to SCREAMING_SNAKE_CASE across all non-ADR documentation
- Resolve missing file references (either create stubs or remove dangling links)
- Reduce redundancy in the noncomputable documentation trilogy

**Non-Goals**:
- Adding language specifiers to all 484 code blocks (mechanical, low value, large scope)
- Enforcing 100-character line limits across all docs (low severity, large scope)
- Rewriting research/ files to match reference documentation standards (they are internal working documents)
- Modifying Theories/Bimodal/docs/ files (covered by task 183)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cross-reference breakage after file renames | M | H | Update all references in a single phase after renames; grep for old names to verify |
| MODULE_ORGANIZATION.md rewrite misses actual structure changes | H | L | Verify against `ls Theories/Bimodal/` before writing |
| MCP_INTEGRATION.md deletion loses useful integration patterns | L | M | Archive to a legacy notice rather than delete; keep any reusable content |
| Stale "Logos" replacement introduces incorrect naming in mathematical context | M | L | Distinguish "Logos project" (stale, replace) from "Logos" as a research concept (keep) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Fix Critical Accuracy Errors [IN PROGRESS]

**Goal**: Correct all factually wrong content that could mislead users or contributors -- wrong directory structures, module namespaces, file paths, version numbers, and broken internal links.

**Tasks**:
- [ ] Rewrite MODULE_ORGANIZATION.md Section 1 directory tree to reflect actual `Theories/Bimodal/` structure with correct subdirectories (Syntax, ProofSystem, Semantics, Metalogic, Theorems, Automation, Examples) and `Tests/BimodalTest/` test layout
- [ ] Update API_REFERENCE.md: replace all `Logos.Core.*` namespaces with `Bimodal.*` equivalents and all `Logos/Core/` paths with `Theories/Bimodal/` paths
- [ ] Fix BASIC_INSTALLATION.md: update Lean version from "v4.14.0 or later" to "v4.27.0-rc1"
- [ ] Fix CONTRIBUTING.md: update clone URL from `Logos.git` to the correct repository URL, fix directory structure references
- [ ] Fix MAINTENANCE.md: correct TODO.md path from `../../TODO.md` to `../../specs/TODO.md`; remove TACTIC_REGISTRY.md from the Five-Document Model (it belongs to Theories/Bimodal/docs/project-info/, not docs/project-info/); reconcile with project-info/README.md Four-Document Model
- [ ] Fix IMPLEMENTATION_STATUS.md: update verification commands from `Logos/Core/**/*.lean` to `Theories/Bimodal/**/*.lean`; update sorry counts to match SORRY_REGISTRY.md (9 active, not 46)
- [ ] Fix TESTING_STANDARDS.md: update test directory structure from `Tests/Unit/Syntax/FormulaTests.lean` to `Tests/BimodalTest/Syntax/` etc.
- [ ] Fix project-info/README.md: reconcile "Four-Document Model" with MAINTENANCE.md, clarify that TACTIC_REGISTRY.md resides in Theories/Bimodal/docs/

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `docs/development/MODULE_ORGANIZATION.md` -- rewrite directory tree section
- `docs/reference/API_REFERENCE.md` -- fix all namespace and path references
- `docs/installation/BASIC_INSTALLATION.md` -- fix version number
- `docs/development/CONTRIBUTING.md` -- fix clone URL and directory references
- `docs/project-info/MAINTENANCE.md` -- fix TODO.md path and document model
- `docs/project-info/IMPLEMENTATION_STATUS.md` -- fix paths and sorry counts
- `docs/development/TESTING_STANDARDS.md` -- fix test directory structure
- `docs/project-info/README.md` -- reconcile document model description

**Verification**:
- Grep for `Logos/Core` across docs/ returns zero results (except in ADR-004 historical record and research/dual-verification.md where "Logos" is used as a concept name)
- Grep for `v4.14` across docs/ returns zero results
- Grep for `LogosTest` across docs/ returns zero results
- All internal cross-references in modified files point to existing files

---

### Phase 2: Eliminate Stale System References [NOT STARTED]

**Goal**: Replace all .opencode references with .claude equivalents and update "Logos project" name references to "ProofChecker" or "BimodalLogic" throughout the documentation.

**Tasks**:
- [ ] Update INTEGRATION.md: replace 4 `.opencode/README.md` references with `.claude/` equivalents
- [ ] Update DOC_QUALITY_CHECKLIST.md: replace 5 `.opencode/context/core/standards/` references with current .claude paths
- [ ] Rewrite or archive MCP_INTEGRATION.md: the entire document describes OpenCode's `opencode.json` MCP configuration (16 occurrences). Add a legacy notice at the top explaining this describes the old system; rewrite the essential integration patterns for Claude Code if applicable, or reduce to a brief stub pointing to `.claude/CLAUDE.md`
- [ ] Rewrite FEATURE_REGISTRY.md: current content (3 .opencode references) describes stale commands. Either repurpose as a Lean library feature registry or retitle and populate with current Claude Code feature tracking
- [ ] Update CONTRIBUTING.md: replace remaining .opencode links (7 occurrences) with .claude equivalents
- [ ] Update MAINTENANCE.md: replace 2 `.opencode/` references
- [ ] Update IMPLEMENTATION_STATUS.md: replace 1 `.opencode` task reference
- [ ] Replace "Logos project" name references with "ProofChecker" in: architecture/README.md, development/README.md, LEAN_STYLE_GUIDE.md, DIRECTORY_README_STANDARD.md, CONTRIBUTING.md, DOC_QUALITY_CHECKLIST.md, QUALITY_METRICS.md, VERSIONING.md, BENCHMARKING_GUIDE.md
- [ ] Replace `Logos/` source path references with `Theories/Bimodal/` in: METAPROGRAMMING_GUIDE.md (Logos namespace references)
- [ ] Add a project name clarification note to docs/README.md: repository = BimodalLogic, project display name = ProofChecker, Lake package = Logos, Lean library = Bimodal

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `docs/user-guide/INTEGRATION.md` -- replace .opencode references
- `docs/development/DOC_QUALITY_CHECKLIST.md` -- replace .opencode references
- `docs/user-guide/MCP_INTEGRATION.md` -- major rewrite or archive
- `docs/project-info/FEATURE_REGISTRY.md` -- major rewrite
- `docs/development/CONTRIBUTING.md` -- replace .opencode and Logos references
- `docs/project-info/MAINTENANCE.md` -- replace .opencode references
- `docs/project-info/IMPLEMENTATION_STATUS.md` -- replace .opencode reference
- `docs/architecture/README.md` -- replace Logos project name
- `docs/development/README.md` -- replace Logos project name
- `docs/development/LEAN_STYLE_GUIDE.md` -- replace Logos project name
- `docs/development/DIRECTORY_README_STANDARD.md` -- replace Logos project name
- `docs/development/DOC_QUALITY_CHECKLIST.md` -- replace Logos project name
- `docs/development/QUALITY_METRICS.md` -- replace Logos project name
- `docs/development/VERSIONING.md` -- replace Logos project name
- `docs/development/BENCHMARKING_GUIDE.md` -- replace Logos placeholder
- `docs/development/METAPROGRAMMING_GUIDE.md` -- replace Logos namespace references
- `docs/README.md` -- add project name clarification

**Verification**:
- Grep for `.opencode` across docs/ returns results only in ADR-004 (historical record)
- Grep for `"Logos project"` or `"the Logos"` (as project name) across docs/ returns zero results
- All .claude paths referenced actually exist

---

### Phase 3: Normalize File Naming Conventions [NOT STARTED]

**Goal**: Rename kebab-case files in research/ and training/ to SCREAMING_SNAKE_CASE to match the convention used across all other docs/ subdirectories. Update all cross-references.

**Tasks**:
- [ ] Rename research/ files:
  - `bimodal-logic.md` -> `BIMODAL_LOGIC.md`
  - `noncomputable.md` -> `NONCOMPUTABLE.md`
  - `deduction-theorem-necessity.md` -> `DEDUCTION_THEOREM_NECESSITY.md`
  - `dual-verification.md` -> `DUAL_VERIFICATION.md`
  - `proof-library-design.md` -> `PROOF_LIBRARY_DESIGN.md`
  - `property-based-testing-lean4.md` -> `PROPERTY_BASED_TESTING_LEAN4.md`
- [ ] Rename training/ file:
  - `pipeline.md` -> `PIPELINE.md`
- [ ] Rename architecture/ non-ADR file:
  - `bfmcs-architecture.md` -> `BFMCS_ARCHITECTURE.md`
- [ ] Update research/README.md: fix all internal links to use new filenames
- [ ] Update docs/README.md: fix all cross-references to renamed files
- [ ] Update architecture/README.md: add entry for BFMCS_ARCHITECTURE.md
- [ ] Grep entire docs/ directory for old kebab-case filenames and update any remaining cross-references

**Timing**: 1 hour

**Depends on**: 1

**Files to modify/rename**:
- `docs/research/bimodal-logic.md` -> `docs/research/BIMODAL_LOGIC.md`
- `docs/research/noncomputable.md` -> `docs/research/NONCOMPUTABLE.md`
- `docs/research/deduction-theorem-necessity.md` -> `docs/research/DEDUCTION_THEOREM_NECESSITY.md`
- `docs/research/dual-verification.md` -> `docs/research/DUAL_VERIFICATION.md`
- `docs/research/proof-library-design.md` -> `docs/research/PROOF_LIBRARY_DESIGN.md`
- `docs/research/property-based-testing-lean4.md` -> `docs/research/PROPERTY_BASED_TESTING_LEAN4.md`
- `docs/training/pipeline.md` -> `docs/training/PIPELINE.md`
- `docs/architecture/bfmcs-architecture.md` -> `docs/architecture/BFMCS_ARCHITECTURE.md`
- `docs/research/README.md` -- update links
- `docs/README.md` -- update links
- `docs/architecture/README.md` -- add BFMCS_ARCHITECTURE.md entry

**Verification**:
- No kebab-case `.md` files remain in docs/ except README.md files and ADR-prefixed files
- All cross-references in README.md files resolve to existing files
- `find docs/ -name "*.md" -not -name "README.md" -not -name "ADR-*"` shows only SCREAMING_SNAKE_CASE names

---

### Phase 4: Resolve Content Gaps and Redundancy [NOT STARTED]

**Goal**: Address missing files, dangling references, and content overlap identified in the research report.

**Tasks**:
- [ ] Resolve missing installation files: remove references to CLAUDE_CODE.md, GETTING_STARTED.md, and USING_GIT.md from docs/README.md and BASIC_INSTALLATION.md (these files were never created and their content is not critical -- BASIC_INSTALLATION.md covers the essentials). Simplify installation/README.md accordingly
- [ ] Remove reference to `user-guide/TUTORIAL.md` from BASIC_INSTALLATION.md (file does not exist)
- [ ] Reduce noncomputable overlap: edit research/NONCOMPUTABLE.md (post-rename) to replace duplicated explanatory content with cross-references to ADR-001 and NONCOMPUTABLE_GUIDE.md, keeping only the research-specific analysis
- [ ] Resolve IMPLEMENTATION_STATUS.md duplication: add a note to docs/project-info/IMPLEMENTATION_STATUS.md clarifying that the authoritative per-module status is in Theories/Bimodal/docs/project-info/IMPLEMENTATION_STATUS.md, and scope the docs/ version to project-wide (non-Bimodal-specific) status tracking
- [ ] Add BFMCS_ARCHITECTURE.md to the architecture/README.md catalog with appropriate description (it is a specification document, not an ADR)

**Timing**: 1 hour

**Depends on**: 2, 3

**Files to modify**:
- `docs/README.md` -- remove missing file references from installation section
- `docs/installation/README.md` -- simplify to reflect actual file inventory
- `docs/installation/BASIC_INSTALLATION.md` -- remove references to missing siblings and TUTORIAL.md
- `docs/research/NONCOMPUTABLE.md` (post-rename) -- add cross-references, reduce duplication
- `docs/project-info/IMPLEMENTATION_STATUS.md` -- add scoping note
- `docs/architecture/README.md` -- add BFMCS_ARCHITECTURE.md entry (if not done in Phase 3)

**Verification**:
- No links in docs/README.md or BASIC_INSTALLATION.md point to non-existent files
- research/NONCOMPUTABLE.md contains explicit cross-references to ADR-001 and NONCOMPUTABLE_GUIDE.md
- architecture/README.md lists BFMCS_ARCHITECTURE.md

---

### Phase 5: Final Review and Consistency Pass [NOT STARTED]

**Goal**: Verify all changes are consistent, no broken cross-references remain, and the docs/ directory meets the stated documentation standards.

**Tasks**:
- [ ] Run a comprehensive cross-reference check: for every internal link in docs/ README files, verify the target file exists
- [ ] Verify no stale references remain: grep for `Logos/Core`, `.opencode`, `v4.14`, `LogosTest`, `opencode.json` across docs/ (ADR-004 and dual-verification.md concept usage excepted)
- [ ] Verify naming consistency: confirm all non-README, non-ADR files in docs/ use SCREAMING_SNAKE_CASE
- [ ] Review docs/README.md as the navigation hub: ensure all 8 subdirectories are listed with accurate file counts and descriptions
- [ ] Spot-check 3-5 files for internal consistency (correct paths, current version numbers, accurate descriptions)

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `docs/README.md` -- final updates to file counts and navigation if needed
- Any files with remaining inconsistencies found during review

**Verification**:
- Zero broken internal cross-references in docs/
- Zero stale system references (except ADR-004 historical record)
- Uniform SCREAMING_SNAKE_CASE naming for all non-README, non-ADR documentation files
- docs/README.md accurately reflects the current docs/ file inventory

## Testing & Validation

- [ ] All internal cross-references in docs/ README files resolve to existing files
- [ ] `grep -r "Logos/Core" docs/` returns zero results (outside ADR-004)
- [ ] `grep -r "\.opencode" docs/` returns results only in ADR-004
- [ ] `grep -r "v4\.14" docs/` returns zero results
- [ ] `grep -r "LogosTest" docs/` returns zero results
- [ ] `grep -r "opencode\.json" docs/` returns zero results (outside ADR-004)
- [ ] `find docs/ -name "*.md" -not -name "README.md" -not -name "ADR-*" | grep -c "[a-z]-[a-z]"` returns zero (no kebab-case non-ADR files)
- [ ] docs/README.md file count per subdirectory matches actual `find` results

## Artifacts & Outputs

- `specs/211_review_revise_docs_directory/plans/01_docs-revision-plan.md` (this plan)
- Modified docs/ files (approximately 30 files across 8 subdirectories)
- No new Lean code or test files

## Rollback/Contingency

All changes are to markdown documentation files with no build impact. If any revision introduces errors:
1. Individual files can be reverted via `git checkout` to the pre-implementation state
2. File renames can be undone with `git mv` in reverse
3. No downstream code dependencies exist on docs/ file content
