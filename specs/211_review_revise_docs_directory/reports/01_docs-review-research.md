# Research Report: docs/ Directory Review

**Task**: 211 - Review and revise docs/ directory
**Started**: 2026-05-29T00:00:00Z
**Completed**: 2026-05-29T00:00:00Z
**Effort**: medium (1-2 days)
**Dependencies**: None
**Sources/Inputs**: Codebase (all files in docs/), README.md, CLAUDE.md, lakefile.lean, actual Lean source files
**Artifacts**: specs/211_review_revise_docs_directory/reports/01_docs-review-research.md
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- The docs/ directory is large (43 files, ~16,000 lines) with a sound organizational structure but significant accuracy problems driven by stale references to an old project name ("Logos"), an old tooling system (".opencode"), and paths that no longer exist.
- File naming is inconsistent: development/, installation/, project-info/, reference/, and user-guide/ use SCREAMING_SNAKE_CASE for most files, while research/ and training/ use kebab-case; architecture/ mixes ADR convention with kebab-case.
- Four critical categories of broken or stale content: (1) missing installation files, (2) stale Logos/path references across development docs, (3) stale .opencode references in multiple files, (4) API_REFERENCE.md using wrong module namespaces.
- Recommended approach: a targeted revision pass fixing accuracy issues first (broken links, stale names, wrong paths), then a naming-convention normalization pass, then content consolidation for the overlapping noncomputable trilogy.

---

## Context & Scope

The docs/ directory provides project-wide documentation for the BimodalLogic (ProofChecker) repository. It serves multiple audiences: new users, contributors, developers, researchers, and ML engineers. The directory is distinct from theory-specific documentation in Theories/Bimodal/docs/ and the agent-system documentation in .claude/.

This review covers all 43 files across 8 subdirectories:

```
docs/
├── README.md                        (280 lines)
├── architecture/                    (4 files, ~1,000 lines)
├── development/                     (16 files, ~6,980 lines)
├── installation/                    (2 files, ~240 lines)
├── project-info/                    (5 files, ~1,280 lines)
├── reference/                       (2 files, ~760 lines)
├── research/                        (7 files, ~4,000 lines)
├── training/                        (1 file, ~800 lines)
└── user-guide/                      (3 files, ~1,010 lines)
```

---

## Findings

### 1. File Inventory and Quality Assessment

#### docs/README.md (280 lines)
Top-level navigation hub. Structure and content quality are good. Contains recently added sections (training/, bfmcs-architecture.md) that appear in the current git diff. References four missing files in installation/ (see Section 5 below) and uses "LEAN" all-caps inconsistently with lowercase "Lean 4" usage elsewhere in the repo.

#### docs/architecture/ (4 files)

| File | Lines | Quality |
|------|-------|---------|
| README.md | 61 | Good. Calls the project "Logos project" (stale name). |
| ADR-001-Classical-Logic-Noncomputable.md | 319 | Good content, accurate paths. Uses correct project context. |
| ADR-004-Remove-Project-Level-State-Files.md | 254 | Accurate as historical record but contains many .opencode paths that no longer exist. |
| bfmcs-architecture.md | 377 | Good content, recently moved from docs/ root to docs/architecture/. Current and accurate for the completeness proof architecture. |

#### docs/development/ (16 files)

| File | Lines | Quality |
|------|-------|---------|
| README.md | 93 | Good navigation document. "Logos project" name (stale). |
| CONTRIBUTING.md | 434 | Mixed. Good contribution workflow, but git clone URLs say `Logos.git`, directory references say `Logos/`, wrong `.opencode/` links for AI system. |
| DIRECTORY_README_STANDARD.md | 533 | Accurate and thorough. "Logos project" name (stale). |
| DOC_QUALITY_CHECKLIST.md | 587 | Useful but references `.opencode/context/core/standards/` paths that do not exist. |
| LATEX_STANDARDS.md | 170 | Small, focused, appears current. |
| LEAN_STYLE_GUIDE.md | 896 | Large, detailed, high-quality. References "Logos project" throughout. |
| METAPROGRAMMING_GUIDE.md | 729 | Large, detailed. References "Logos" namespace. |
| MODULE_ORGANIZATION.md | 377 | Severely outdated: describes a `Logos/Core/` directory structure with `LogosTest/` test suite that does not exist. Actual structure is `Theories/Bimodal/` with `Tests/BimodalTest/`. |
| NONCOMPUTABLE_GUIDE.md | 413 | Good content but overlaps heavily with research/noncomputable.md and ADR-001. |
| PHASED_IMPLEMENTATION.md | 548 | Describes early-stage implementation roadmap (Layer 0). Task numbers (1-11) refer to very old tasks. Still useful as architectural context but not a current action plan. |
| BENCHMARKING_GUIDE.md | 228 | Accurate for project-wide standards. Has a "Logos: (planned)" placeholder. |
| CI_CD_PROCESS.md | 227 | Accurate. `.github/workflows/ci.yml` exists. |
| PROPERTY_TESTING_GUIDE.md | 713 | Good, recent content (Task 174). |
| QUALITY_METRICS.md | 287 | References "Logos project" but targets are general and still applicable. |
| TESTING_STANDARDS.md | 428 | Describes a `Tests/Unit/` structure that does not match actual `Tests/BimodalTest/` layout. |
| VERSIONING.md | 317 | Good policy document. References "Logos" package name. |

#### docs/installation/ (2 files, missing 3 referenced files)

| File | Lines | Quality |
|------|-------|---------|
| README.md | 41 | Good overview. References correct version (v4.27.0-rc1). |
| BASIC_INSTALLATION.md | 203 | Good, but references three missing siblings: CLAUDE_CODE.md, GETTING_STARTED.md, USING_GIT.md. Also references `../user-guide/TUTORIAL.md` which does not exist in docs/user-guide/. |

#### docs/project-info/ (5 files)

| File | Lines | Quality |
|------|-------|---------|
| README.md | 88 | Describes "Four-Document Model" (4 files). MAINTENANCE.md says "Five-Document Model" (adds TACTIC_REGISTRY.md). Inconsistency. |
| IMPLEMENTATION_STATUS.md | 334 | Outdated. Last updated 2026-02-27 but reflects a much earlier state. Sorry counts (46 active per this doc vs 9 per SORRY_REGISTRY.md) are inconsistent. Uses wrong `Logos/` paths in verification commands. References .opencode tasks. |
| MAINTENANCE.md | 662 | Large document with good workflow. References `../../TODO.md` which would be the project root, but TODO.md is actually at `specs/TODO.md`. References TACTIC_REGISTRY.md as if it is in docs/project-info/ but it only exists in Theories/Bimodal/docs/project-info/. Contains `.opencode/` references (2 occurrences). |
| FEATURE_REGISTRY.md | 28 | Describes agent-system slash command behaviors (not Lean features). Contains multiple stale `.opencode/` references. Content is entirely about .opencode commands (now migrated to .claude). |
| SORRY_REGISTRY.md | 196 | Good content, current. Uses correct `Bimodal/**` paths in verification commands. |

#### docs/reference/ (2 files)

| File | Lines | Quality |
|------|-------|---------|
| README.md | 45 | Good, accurate. |
| API_REFERENCE.md | 719 | Significantly inaccurate module paths. Uses `Logos.Core.Syntax.Formula` and `Logos/Core/Syntax/Formula.lean` but actual namespace is `Bimodal.Syntax` and actual path is `Theories/Bimodal/Syntax/Formula.lean`. |

#### docs/research/ (7 files)

| File | Lines | Quality |
|------|-------|---------|
| README.md | 118 | Good navigation. |
| bimodal-logic.md | 139 | Good theoretical overview. |
| noncomputable.md | 671 | Research report format (with task/researcher metadata header). Overlaps with NONCOMPUTABLE_GUIDE.md and ADR-001. |
| deduction-theorem-necessity.md | 532 | Research report format. Focused and useful. |
| dual-verification.md | 508 | Uses "the Logos" as a name for a grand formal reasoning framework (different meaning from the project name "Logos"). |
| proof-library-design.md | 413 | Describes planned/future architecture. |
| property-based-testing-lean4.md | 985 | Research report format. Large, 102 code blocks without language specifiers. |

#### docs/training/ (1 file)

| File | Lines | Quality |
|------|-------|---------|
| pipeline.md | 797 | Recent, detailed, accurate. Describes the ML training pipeline correctly, references correct Lean module paths (Theories/Bimodal/Automation/). |

#### docs/user-guide/ (3 files)

| File | Lines | Quality |
|------|-------|---------|
| README.md | 64 | Good overview. |
| INTEGRATION.md | 417 | References `.opencode/README.md` (4 occurrences). Main integration content is sound. |
| MCP_INTEGRATION.md | 535 | Entirely about OpenCode/opencode.json MCP setup — describes the old .opencode tooling, not the current .claude system. References opencode.json (16 occurrences). Likely obsolete or should be rewritten for Claude Code. |

---

### 2. Naming Convention Issues

The docs/ directory uses two incompatible naming conventions with no clear rationale for the split:

**SCREAMING_SNAKE_CASE** (used in development/, installation/, project-info/, reference/, user-guide/):
- LEAN_STYLE_GUIDE.md, CONTRIBUTING.md, MODULE_ORGANIZATION.md, etc.
- 25 files

**kebab-case** (used in research/, training/, and architecture/bfmcs-architecture.md):
- bimodal-logic.md, noncomputable.md, pipeline.md, bfmcs-architecture.md
- 8 files

**ADR convention** (architecture/):
- ADR-001-Classical-Logic-Noncomputable.md, ADR-004-Remove-Project-Level-State-Files.md
- 2 files (ADR convention is widely understood and should be kept)

The SCREAMING_SNAKE_CASE convention dominates and is used in Theories/Bimodal/docs/ as well (AXIOM_REFERENCE.md, QUICKSTART.md, etc.), suggesting it is the de facto project standard. The research/ and training/ directories are outliers.

**Recommendation**: Standardize on SCREAMING_SNAKE_CASE for non-ADR documentation files across docs/ (and in Theories/Bimodal/docs/). ADR files retain their ADR-NNN prefix.

---

### 3. Broken and Missing Links

**Missing files referenced in docs/README.md and siblings:**

| Referenced Path | Referenced From | Issue |
|-----------------|-----------------|-------|
| installation/CLAUDE_CODE.md | docs/README.md, BASIC_INSTALLATION.md | File does not exist |
| installation/GETTING_STARTED.md | docs/README.md, BASIC_INSTALLATION.md | File does not exist |
| installation/USING_GIT.md | docs/README.md, BASIC_INSTALLATION.md | File does not exist |
| user-guide/TUTORIAL.md | BASIC_INSTALLATION.md | File does not exist |
| docs/project-info/TACTIC_REGISTRY.md | MAINTENANCE.md | File does not exist at this path (only in Theories/Bimodal/docs/project-info/) |

**Valid cross-references (confirmed existing):**
- All Theories/Bimodal/docs/ cross-references from docs/README.md are valid.
- architecture/bfmcs-architecture.md exists (recently moved from docs/ root).
- training/pipeline.md exists.

---

### 4. Stale References

**Stale .opencode references** (old agent system, replaced by .claude):

| File | Occurrences | Nature |
|------|-------------|--------|
| MCP_INTEGRATION.md | 16 | Entire document describes opencode.json setup |
| ADR-004-Remove-Project-Level-State-Files.md | 10 | Historical record (acceptable to retain) |
| CONTRIBUTING.md | 7 | Links to .opencode/README.md, .opencode/agent/, etc. |
| DOC_QUALITY_CHECKLIST.md | 5 | Links to .opencode/context/core/standards/ |
| INTEGRATION.md | 4 | Links to .opencode/README.md |
| FEATURE_REGISTRY.md | 3 | Content about .opencode commands |
| MAINTENANCE.md | 2 | References .opencode/README.md |
| IMPLEMENTATION_STATUS.md | 1 | References .opencode task |

**Stale "Logos" project name/path references:**
The package in lakefile.lean is named `Logos` but the library is `Bimodal` with srcDir `Theories`. There is no `Logos/` directory. Many development/ docs use "Logos project" to mean the overall project and `Logos/` as a source directory path. These are two distinct problems:

1. **"Logos project" as project name**: Used in CONTRIBUTING.md, LEAN_STYLE_GUIDE.md, DIRECTORY_README_STANDARD.md, architecture/README.md, development/README.md, QUALITY_METRICS.md, DOC_QUALITY_CHECKLIST.md, VERSIONING.md. The project is now called "ProofChecker" (per docs/README.md, README.md) or informally "BimodalLogic". "Logos" refers to the hyperintensional extension (Logos research track). Occurrences should say "ProofChecker" or "BimodalLogic" (matching the repository name and CLAUDE.md).

2. **`Logos/` as a source path**: MODULE_ORGANIZATION.md, IMPLEMENTATION_STATUS.md, TESTING_STANDARDS.md, and BENCHMARKING_GUIDE.md use `Logos/Core/`, `LogosTest/`, and `Logos/Metalogic/` paths in code examples and verification commands. These should be `Theories/Bimodal/`, `Tests/BimodalTest/`, and `Theories/Bimodal/Metalogic/`.

**Stale CONTRIBUTING.md clone URLs**: Uses `git clone https://github.com/YOUR-USERNAME/Logos.git` — should be `ProofChecker.git` to match the actual repo URL shown in README.md.

---

### 5. Redundancy and Overlap

**Noncomputable trilogy**: Three documents cover the same topic from overlapping angles:
- `docs/development/NONCOMPUTABLE_GUIDE.md` — developer guide, catalog of noncomputable defs
- `docs/research/noncomputable.md` — research report format, executive summary + analysis
- `docs/architecture/ADR-001-Classical-Logic-Noncomputable.md` — architectural decision record

These are complementary but share substantial content explaining what `noncomputable` means. The research report (noncomputable.md) predates the guide and ADR but is less structured as a reference. Options: (a) keep all three, remove duplicate explanatory content from noncomputable.md and have it link to the ADR and guide; (b) consolidate the research report into the guide, retaining the ADR.

**IMPLEMENTATION_STATUS.md duplication**: docs/project-info/IMPLEMENTATION_STATUS.md and Theories/Bimodal/docs/project-info/IMPLEMENTATION_STATUS.md both track Bimodal implementation status. docs/ version is outdated (2026-02-27 vs more recent updates in Theories/Bimodal/docs/) and contains conflicting sorry counts. The docs/ version should either be removed (leaving Theories/Bimodal/docs/ as authoritative) or explicitly scoped to project-wide (non-Bimodal-specific) status only.

**FEATURE_REGISTRY.md mismatch**: Titled "Feature Registry" but contains only agent-system slash command behaviors (2 entries about .opencode commands). Not a registry of Lean library features. Should either be rewritten to track Lean feature capabilities or retitled/repurposed.

---

### 6. Accuracy Issues

**MODULE_ORGANIZATION.md**: The entire directory tree in Section 1 is wrong. It describes:
```
Logos/
├── Logos/
│   ├── Core/
│   │   ├── Syntax/
```
Actual structure is:
```
Theories/
└── Bimodal/
    ├── Syntax/
    ├── ProofSystem/
    ├── Semantics/
    ├── Metalogic/
    ├── Theorems/
    └── Automation/
```
Test structure described (`LogosTest/Core/...`) also does not match actual `Tests/BimodalTest/` layout.

**API_REFERENCE.md**: Every module path and namespace is wrong. The document says:
- Namespace: `Logos.Core.Syntax.Formula`
- Path: `Logos/Core/Syntax/Formula.lean`

Actual:
- Namespace: `Bimodal.Syntax` (from `namespace Bimodal.Syntax` in Formula.lean)
- Path: `Theories/Bimodal/Syntax/Formula.lean`

**TESTING_STANDARDS.md**: Describes `Tests/Unit/Syntax/FormulaTests.lean` etc. but actual test structure is `Tests/BimodalTest/Syntax/`, `Tests/BimodalTest/ProofSystem/`, etc.

**IMPLEMENTATION_STATUS.md**: Verification commands use `Logos/Core/**/*.lean` paths that do not exist. Sorry counts from 2026-02-27 show 46 active sorries; SORRY_REGISTRY.md (updated 2026-03-15) shows 9 active sorries.

**MAINTENANCE.md**: References `../../TODO.md` (would resolve to project root) but TODO.md is at `specs/TODO.md` — correct relative path from docs/project-info/ would be `../../specs/TODO.md`.

**CONTRIBUTING.md**: LEAN version requirement says "v4.14.0 or later" but CLAUDE.md and lakefile.lean specify v4.27.0-rc1. Development setup instructions reference old AI system (`.opencode/`).

**BASIC_INSTALLATION.md**: References "v4.14.0+" for LEAN but correct version is v4.27.0-rc1 (matching lean-toolchain).

**MCP_INTEGRATION.md**: Entirely documents OpenCode's `opencode.json` MCP configuration approach. The current system is Claude Code (`.claude/`). The document is obsolete as a current reference but could be repurposed or archived.

---

### 7. Organization Assessment

The directory structure is logical and matches what docs/README.md promises:

```
architecture/    ADRs and system architecture — appropriate
development/     Developer standards — appropriate (but too many files)
installation/    Setup guides — appropriate (several files missing)
project-info/    Status tracking — appropriate
reference/       API and symbols — appropriate
research/        Research documents — appropriate
training/        ML pipeline — appropriate (new, recently added)
user-guide/      Integration guides — appropriate
```

**Issues with current organization:**

1. The research/ directory mixes research reports (task-scoped documents with researcher/date headers) with conceptual documentation (bimodal-logic.md, proof-library-design.md). Research reports are internal working documents; the conceptual documents would be more appropriate as reference or architecture docs.

2. The development/ directory has 15 non-README files, many of which (PHASED_IMPLEMENTATION.md, QUALITY_METRICS.md, BENCHMARKING_GUIDE.md) are not strictly development standards but planning/process documents. This is a minor organizational issue, not a structural problem.

3. There is no `docs/architecture/` README entry for bfmcs-architecture.md in the architecture/README.md (it only lists ADRs). The bfmcs-architecture.md is a specification document, not an ADR — the architecture/ directory serves two purposes now.

---

### 8. Documentation Standards Compliance

From docs/README.md declared standards:
- **Line limit**: 100 characters — widely violated (25 long lines in README.md alone; research files have many more)
- **ATX headings** (`#`, `##`): Mostly followed; no setext headings found
- **Code block language specifiers**: 484 code blocks without language specifiers, concentrated in research/ files (102 in that directory alone)
- **Formal symbols in backticks**: Followed in most places

---

## Decisions

- The "Logos" name is the Lake package name (`package Logos` in lakefile.lean) but the library is `Bimodal`. "Logos" as a project/directory name in documentation is stale and should be replaced with "ProofChecker" or "BimodalLogic" (for the repository) and `Bimodal` (for the Lean library and source paths).
- .opencode references in ADR-004 are acceptable as a historical record. In all other files, .opencode references should be updated to reflect the current .claude system.
- Research reports (files with task/researcher metadata headers) in research/ are internal working documents that do not need to conform to the same standards as reference documentation.

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| MODULE_ORGANIZATION.md is wrong enough to mislead contributors | High priority: rewrite Section 1 to reflect actual Theories/Bimodal/ structure |
| API_REFERENCE.md namespaces are wrong | High priority: update all module paths and namespaces |
| BASIC_INSTALLATION.md references wrong Lean version | High priority: update to v4.27.0-rc1 |
| Missing installation files (CLAUDE_CODE.md, GETTING_STARTED.md, USING_GIT.md) | Either create stub files or remove references from docs/README.md and BASIC_INSTALLATION.md |
| MCP_INTEGRATION.md describes obsolete system | Mark as legacy/archive, or rewrite for Claude Code |
| Sorry count discrepancy (46 vs 9) in IMPLEMENTATION_STATUS.md | SORRY_REGISTRY.md is more recent; update IMPLEMENTATION_STATUS.md |

---

## Prioritized Revision Plan

### Priority 1 — Accuracy (breaks things for users/contributors)

1. **MODULE_ORGANIZATION.md**: Rewrite directory tree to reflect `Theories/Bimodal/` and `Tests/BimodalTest/`.
2. **API_REFERENCE.md**: Update all module namespaces from `Logos.Core.*` to `Bimodal.*` and paths from `Logos/Core/` to `Theories/Bimodal/`.
3. **BASIC_INSTALLATION.md**: Update Lean version from v4.14.0+ to v4.27.0-rc1.
4. **CONTRIBUTING.md**: Fix clone URLs (Logos.git -> ProofChecker.git), update directory structure references, remove/replace .opencode links.
5. **MAINTENANCE.md**: Fix TODO.md path (`../../TODO.md` -> `../../specs/TODO.md`), remove TACTIC_REGISTRY.md from docs/project-info/ Five-Document Model (it belongs to Theories/Bimodal/docs/).
6. **IMPLEMENTATION_STATUS.md**: Fix verification commands (Logos/ paths -> Theories/Bimodal/), update sorry counts to match SORRY_REGISTRY.md.
7. **TESTING_STANDARDS.md**: Fix test directory structure to reflect `Tests/BimodalTest/`.

### Priority 2 — Stale system references

8. **INTEGRATION.md**: Remove/replace .opencode/README.md references with .claude/ equivalents.
9. **DOC_QUALITY_CHECKLIST.md**: Remove/replace .opencode/context/ references.
10. **MCP_INTEGRATION.md**: Rewrite or archive (describes obsolete OpenCode system).
11. **FEATURE_REGISTRY.md**: Rewrite content (current entries describe stale .opencode commands) or repurpose as Lean library feature registry.

### Priority 3 — Naming consistency

12. Rename kebab-case research/ files to SCREAMING_SNAKE_CASE (bimodal-logic.md -> BIMODAL_LOGIC.md, etc.) and training/pipeline.md -> training/PIPELINE.md; update all cross-references.
13. Update "Logos project" name references to "ProofChecker" in architecture/README.md, development/README.md, and other affected files.

### Priority 4 — Content gaps and organization

14. Create missing installation files (CLAUDE_CODE.md, GETTING_STARTED.md, USING_GIT.md) or remove references and simplify installation/README.md.
15. Fix project-info/README.md: reconcile "Four-Document Model" vs MAINTENANCE.md's "Five-Document Model", clarify TACTIC_REGISTRY.md is in Theories/Bimodal/docs/.
16. Reduce noncomputable overlap: have research/noncomputable.md link to ADR-001 and NONCOMPUTABLE_GUIDE.md rather than repeating the foundational explanation.
17. Add bfmcs-architecture.md to architecture/README.md catalog (it is listed only as a non-ADR doc).

---

## Context Extension Recommendations

- **Topic**: Project name conventions (ProofChecker vs BimodalLogic vs Logos)
- **Gap**: No single place documents which name to use in which context (package name vs library name vs repo name vs project display name)
- **Recommendation**: Add a brief note in CLAUDE.md or docs/README.md clarifying: repository = BimodalLogic, project display name = ProofChecker, Lake package = Logos, Lean library = Bimodal

---

## Appendix

### File Count Summary

| Directory | Files | Total Lines |
|-----------|-------|-------------|
| docs/ (root) | 1 | 280 |
| architecture/ | 4 | ~1,000 |
| development/ | 16 | ~6,980 |
| installation/ | 2 | ~240 |
| project-info/ | 5 | ~1,280 |
| reference/ | 2 | ~760 |
| research/ | 7 | ~4,000 |
| training/ | 1 | ~800 |
| user-guide/ | 3 | ~1,010 |
| **Total** | **41** | **~16,350** |

### Key Command for Verification

```bash
# Verify actual Lean namespace
grep "^namespace" Theories/Bimodal/Syntax/Formula.lean

# Verify actual test directory
ls Tests/BimodalTest/

# Verify actual source directory
ls Theories/Bimodal/

# Check current sorry count
grep -rn "sorry" Theories/Bimodal --include="*.lean" | grep -v Boneyard | wc -l

# Lean version
cat lean-toolchain
```
