# Research Report: Task 661

**Task**: 661 - create_documentation_standards_file
**Started**: 2026-01-21T15:30:00Z
**Completed**: 2026-01-21T16:15:00Z
**Effort**: Low
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase exploration, existing standards files
**Artifacts**: specs/661_create_documentation_standards_file/reports/research-001.md
**Standards**: report-format.md

---

## Executive Summary

- Existing `documentation.md` in `core/standards/` contains corrupted/duplicated content starting at line 315 with a second "# Documentation Standards" section
- File naming convention in `core/standards/` is **lowercase with hyphens** (kebab-case), not ALL_CAPS
- "Quick Start" and "Quick Reference" patterns appear extensively (54+ occurrences) across the codebase
- Clear distinction exists between `docs/` (user-facing guides) and `context/` (AI agent knowledge)
- The task description requests ALL_CAPS naming but existing conventions use lowercase

---

## Context & Scope

This research identifies documentation patterns, naming conventions, and corrupted content to inform creation of `DOCUMENTATION_STANDARDS.md` (or appropriate filename per conventions).

---

## Findings

### 1. Corrupted Content in documentation.md

The file `/home/benjamin/Projects/ProofChecker/.claude/context/core/standards/documentation.md` contains two distinct documentation standards documents concatenated together:

**First Document (Lines 1-312)**:
- Well-structured documentation standards for `.opencode` system and ProofChecker
- Covers: Core principles, formatting standards, NO EMOJI policy, NO VERSION HISTORY policy
- References: LEAN 4 specific standards, directory README standards, artifact documentation

**Second Document (Lines 313-473)**:
- Begins with HTML comment: `<!-- Context: standards/docs | Priority: critical | Version: 2.0 | Updated: 2025-01-21 -->`
- Different style with "Quick Reference" header
- Includes "Quick Start" section with generic README template
- Contains JavaScript-style documentation examples (mismatched with project focus)
- Duplicates some content but in a different format

**Corruption Point**: Line 313-315 where the second document begins

### 2. File Naming Conventions

**Existing Convention in `core/standards/`** (11 files):
```
analysis-framework.md
ci-workflow.md
code-patterns.md
documentation.md
error-handling.md
git-integration.md
git-safety.md
status-markers.md
task-management.md
testing.md
xml-structure.md
```

**Pattern**: All files use **lowercase with hyphens** (kebab-case), NO ALL_CAPS files exist.

**Exception in `docs/`**: `STANDARDS_QUICK_REF.md` uses ALL_CAPS with underscores.

**Recommendation**: Follow existing `core/standards/` convention with lowercase kebab-case. Creating `DOCUMENTATION_STANDARDS.md` would violate the established pattern.

### 3. "Quick Start" / "Quick Reference" Pattern Occurrences

Found 54+ occurrences across the codebase:

**Files with "Quick Reference" sections**:
- `.claude/docs/STANDARDS_QUICK_REF.md` - Entire file is a quick reference
- `.claude/docs/README.md` - Contains "Quick Start" section
- `.claude/context/core/standards/documentation.md` (corrupted section) - Has "Quick Reference" and "Quick Start"
- `.claude/context/index.md` - References "quick reference" in descriptions
- `.claude/rules/latex.md` - Contains "Quick Reference" section
- Multiple tool guides and pattern files

**Problematic Examples**:
1. `docs/README.md` line 41: "## Quick Start" section
2. `STANDARDS_QUICK_REF.md` - Title implies quick reference pattern
3. `documentation.md` line 317: "## Quick Reference" (corrupted section)
4. `documentation.md` line 355: "## Quick Start" (corrupted section)

### 4. docs/ vs context/ Directory Purpose

**`docs/` Directory Purpose** (from README.md):
```
.claude/docs/
├── guides/                      # How-to guides for users
├── examples/                    # Integration examples
├── templates/                   # Reusable templates
├── architecture/               # Architecture documentation
├── troubleshooting/            # Problem resolution
└── migrations/                 # Migration guides
```

- **Audience**: Human users (developers, contributors)
- **Content Type**: Installation guides, how-to guides, examples, troubleshooting
- **Style**: User-friendly, step-by-step instructions

**`context/` Directory Purpose** (from README.md):
```
.claude/context/
├── core/                        # General/reusable context (36 files)
│   ├── orchestration/           # System orchestration
│   ├── formats/                 # Output formats
│   ├── standards/               # Quality standards
│   ├── workflows/               # Workflow patterns
│   └── templates/               # Reusable templates
└── project/                     # ProofChecker-specific context
```

- **Audience**: AI agents (Claude Code)
- **Content Type**: Standards, schemas, patterns, domain knowledge
- **Style**: Technical, precise, optimized for AI parsing

**Key Distinction**:
| Aspect | docs/ | context/ |
|--------|-------|----------|
| Audience | Human users | AI agents |
| Style | Friendly, explanatory | Technical, precise |
| Purpose | How-to guides | Standards & knowledge |
| Examples | Step-by-step tutorials | Schema definitions |

### 5. README File Conventions

**Current Pattern**: All README files use `README.md` extension:
```
.claude/docs/README.md
.claude/docs/templates/README.md
.claude/docs/migrations/001-openagents-migration/README.md
.claude/context/README.md
.claude/context/core/checkpoints/README.md
.claude/context/project/latex/README.md
.claude/context/project/logic/README.md
.claude/context/project/lean4/README.md
```

**Recommendation**: No files named `README` (without extension) exist. Standard is `README.md`.

### 6. Present Tense and Historical Language

**Existing Policy** (from documentation.md lines 29-38):
```markdown
**Don't**:
- Include historical information about past versions
- Mention "we changed X to Y" or "previously this was Z"
- Include speculative future plans
- Add "Version History" sections (this is useless cruft)
- Include version numbers in documentation (e.g., "v1.0.0", "v2.0.0")
- Document what changed between versions
```

**Violation in context/README.md**: Lines 199-242 contain historical migration information from "Task 314" with detailed change logs.

### 7. Existing Standards That Could Be Consolidated

Files with overlapping documentation standards content:
1. `.claude/context/core/standards/documentation.md` (corrupted, needs cleanup)
2. `.claude/docs/STANDARDS_QUICK_REF.md` (quick reference anti-pattern)
3. `.claude/context/README.md` (has naming conventions section)

---

## Decisions

1. **File Naming**: The new file should follow existing `core/standards/` convention: `documentation-standards.md` (lowercase, kebab-case), NOT `DOCUMENTATION_STANDARDS.md` as specified in task description

2. **Location**: File should be created at `.claude/context/core/standards/documentation-standards.md`

3. **Scope**: New file consolidates documentation standards, existing `documentation.md` gets fixed (remove corruption)

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Task requests ALL_CAPS naming but convention is lowercase | Recommend following convention; escalate naming decision |
| Quick reference patterns are pervasive (54+ files) | Create standards prohibiting NEW occurrences; existing files grandfathered or scheduled for cleanup |
| Corrupted documentation.md must be fixed | Include fix in implementation plan |

---

## Implementation Recommendations

### Phase 1: Create New Standards File

Create `.claude/context/core/standards/documentation-standards.md` containing:

1. **File Naming Standards**
   - Lowercase kebab-case for `core/` files
   - README.md (not README without extension)
   - Prohibition on ALL_CAPS filenames in `context/`

2. **Prohibited Document Patterns**
   - No "Quick Start" sections (explain alternatives)
   - No "Quick Reference" sections (alternatives: summary tables, decision trees)
   - No standalone quick reference documents

3. **Temporal Language Standards**
   - Present tense only
   - No historical references ("previously", "changed from", "used to")
   - No version history sections

4. **Directory Purpose Standards**
   - docs/ = User-facing guides
   - context/ = AI agent knowledge
   - Clear criteria for placement decisions

### Phase 2: Fix Existing documentation.md

- Remove lines 313-473 (corrupted/duplicated content)
- Rename to `documentation-general.md` or keep as-is (general docs standards)

### Phase 3: Cleanup Quick Reference Files

- Flag `STANDARDS_QUICK_REF.md` for deprecation
- Create task to audit and remove quick reference patterns

---

## Appendix

### Search Queries Used

1. `Glob: .claude/docs/**/*.md` - Found 25 files
2. `Glob: .claude/context/**/*.md` - Found 90+ files
3. `Grep: quick.?start|quick.?reference` - Found 36 files
4. `Grep: documentation` - Found 105 files
5. `Glob: **/*README*` - Found 8 files
6. `Glob: .claude/context/core/standards/*` - Found 11 files

### Key Files Referenced

- `/home/benjamin/Projects/ProofChecker/.claude/context/core/standards/documentation.md`
- `/home/benjamin/Projects/ProofChecker/.claude/docs/STANDARDS_QUICK_REF.md`
- `/home/benjamin/Projects/ProofChecker/.claude/docs/README.md`
- `/home/benjamin/Projects/ProofChecker/.claude/context/README.md`
- `/home/benjamin/Projects/ProofChecker/.claude/context/index.md`
