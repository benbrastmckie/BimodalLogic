# Research Report: Task #723

**Task**: 723 - update_claude_documentation
**Started**: 2026-01-28T12:00:00Z
**Completed**: 2026-01-28T12:30:00Z
**Effort**: 2-3 hours (estimated for implementation)
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase exploration of .claude/ directory
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Current documentation is comprehensive but verbose - CLAUDE.md is ~500 lines, ARCHITECTURE.md is ~975 lines
- The system has 13 slash commands, 15 skills, and 9 agents with clear delegation patterns
- Primary workflow (task lifecycle) documentation exists but is scattered across multiple files
- Key documentation gaps: no quick-start guide in CLAUDE.md, outdated references to deprecated patterns, some commands lack clear examples
- Recommended approach: Consolidate CLAUDE.md as the primary reference, create a "Getting Started" section, and reorganize command documentation

## Context & Scope

This research analyzed the `.claude/` directory structure to understand:
1. What documentation currently exists and its organization
2. How complete the workflow documentation is
3. What commands are available and how they're documented
4. Where gaps, redundancies, or inaccuracies exist

## Findings

### 1. Documentation Structure Overview

The `.claude/` directory contains extensive documentation across multiple locations:

```
.claude/
├── CLAUDE.md                    # Main reference (499 lines) - Quick reference entry point
├── ARCHITECTURE.md              # System architecture (975 lines) - Detailed technical spec
├── commands/                    # 13 command files
├── skills/                      # 15 skill directories
├── agents/                      # 9 agent files
├── rules/                       # 7 rule files
├── context/                     # ~100+ context files organized by category
│   ├── index.md                 # Context discovery index (603 lines)
│   ├── core/                    # Core patterns, standards, orchestration
│   └── project/                 # Project-specific context (lean4, logic, latex, typst)
└── docs/                        # User documentation
    ├── README.md                # Documentation hub
    ├── guides/                  # How-to guides (7 files)
    ├── architecture/            # System overview
    ├── examples/                # Flow examples
    └── templates/               # Reusable templates
```

### 2. Available Commands Catalog

| Command | Purpose | Primary Workflow? | Documentation Quality |
|---------|---------|-------------------|----------------------|
| `/task` | Create, manage, sync tasks | Yes | Good - includes all modes |
| `/research` | Conduct task research | Yes (Step 2) | Good - checkpoint pattern |
| `/plan` | Create implementation plans | Yes (Step 3) | Good - checkpoint pattern |
| `/implement` | Execute implementation | Yes (Step 4) | Good - includes resume |
| `/revise` | Revise plans or descriptions | Support | Good - dual mode |
| `/review` | Code review, roadmap updates | Maintenance | Good - detailed |
| `/errors` | Analyze error patterns | Maintenance | Good |
| `/todo` | Archive completed tasks | Maintenance | Excellent - very detailed |
| `/meta` | System builder (create tasks) | Support | Good |
| `/learn` | Scan for FIX/NOTE/TODO tags | Support | Good - interactive |
| `/lake` | Build with auto-repair | Lean-specific | Excellent |
| `/refresh` | Cleanup orphaned processes | Maintenance | Good |
| `/convert` | Document format conversion | Utility | Good |

### 3. Primary Workflow Documentation

The task lifecycle is documented but scattered:

**Lifecycle**: Create -> Research -> Plan -> Implement -> Complete -> Archive

| Phase | Command | Status Transition | Documentation Location |
|-------|---------|-------------------|------------------------|
| Create | `/task "desc"` | - -> NOT STARTED | CLAUDE.md, commands/task.md |
| Research | `/research N` | NOT STARTED -> RESEARCHING -> RESEARCHED | CLAUDE.md, commands/research.md |
| Plan | `/plan N` | RESEARCHED -> PLANNING -> PLANNED | CLAUDE.md, commands/plan.md |
| Implement | `/implement N` | PLANNED -> IMPLEMENTING -> COMPLETED | CLAUDE.md, commands/implement.md |
| Archive | `/todo` | COMPLETED -> (archived) | CLAUDE.md, commands/todo.md |

**Gap**: No single place shows the complete workflow with examples.

### 4. Documentation Gaps Identified

#### 4.1 Missing Quick-Start Section in CLAUDE.md

CLAUDE.md jumps into system overview without a simple "Getting Started" section showing:
- How to create a task
- How to run the workflow
- What the expected output looks like

#### 4.2 Outdated References

Found references to deprecated patterns:
- CLAUDE.md mentions `.claude/agent/orchestrator.md` which doesn't exist (Line 159 of ARCHITECTURE.md)
- References to `command-lifecycle.md` marked as deprecated
- Some context files reference consolidated files that superseded them

#### 4.3 Command Examples Not Uniform

Some commands have excellent examples (like `/lake`), while others lack practical examples:
- `/research` - no example showing expected output
- `/plan` - no example of a generated plan structure
- `/implement` - no example of resume behavior

#### 4.4 Maintenance Commands Not Clearly Categorized

Commands like `/review`, `/errors`, `/todo`, `/refresh` are maintenance commands but aren't clearly distinguished from primary workflow commands.

### 5. Redundancy Analysis

**High Redundancy**:
- CLAUDE.md and ARCHITECTURE.md have significant overlap (both describe skill architecture, language routing)
- docs/architecture/system-overview.md duplicates content from ARCHITECTURE.md
- Multiple files describe checkpoint execution model

**Recommendation**: CLAUDE.md should be the concise entry point; ARCHITECTURE.md should be the detailed technical reference; docs/ should be user-facing guides.

### 6. Skill-to-Agent Mapping (Current)

| Skill | Agent | Execution Pattern |
|-------|-------|-------------------|
| skill-lean-research | (direct execution) | Direct - MCP tools |
| skill-lean-implementation | (direct execution) | Direct - MCP tools |
| skill-researcher | general-research-agent | Delegation via Task tool |
| skill-planner | planner-agent | Delegation via Task tool |
| skill-implementer | general-implementation-agent | Delegation via Task tool |
| skill-latex-implementation | latex-implementation-agent | Delegation via Task tool |
| skill-typst-implementation | typst-implementation-agent | Delegation via Task tool |
| skill-meta | meta-builder-agent | Delegation via Task tool |
| skill-document-converter | document-converter-agent | Delegation via Task tool |
| skill-status-sync | (direct execution) | Direct |
| skill-refresh | (direct execution) | Direct |
| skill-lake-repair | (direct execution) | Direct |
| skill-learn | (direct execution) | Direct |
| skill-git-workflow | (N/A) | Direct |

### 7. Language Routing Table (Complete)

| Language | Research Skill | Implementation Skill | Notes |
|----------|----------------|---------------------|-------|
| `lean` | skill-lean-research | skill-lean-implementation | Uses MCP tools |
| `latex` | skill-researcher | skill-latex-implementation | Web/codebase + pdflatex |
| `typst` | skill-researcher | skill-typst-implementation | Web/codebase + typst |
| `general` | skill-researcher | skill-implementer | Standard tools |
| `meta` | skill-researcher | skill-implementer | Read/Write/Edit |
| `markdown` | skill-researcher | skill-implementer | Standard tools |

### 8. Accuracy Issues Found

1. **ARCHITECTURE.md Line 159**: References `.claude/agent/orchestrator.md` - path should be updated or note added that orchestrator is distributed across skills
2. **CLAUDE.md Line 19-27**: Project structure shows `Logos/` but ProofChecker also uses `Theories/`
3. **Context index.md**: References deprecated files that were consolidated in Task 246

## Decisions

Based on this analysis:

1. **CLAUDE.md should remain the primary reference** but needs reorganization
2. **ARCHITECTURE.md should be technical detail only** - remove workflow duplication
3. **Add Getting Started section** at the top of CLAUDE.md
4. **Categorize commands clearly**: Primary Workflow vs Maintenance vs Utility
5. **Add concrete examples** for each primary workflow command

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Breaking existing documentation links | Update all internal references systematically |
| Information loss during consolidation | Preserve detailed content in ARCHITECTURE.md |
| User confusion during transition | Keep structure similar, just reorganize |

## Recommendations

### Phase 1: CLAUDE.md Restructure

1. Add "Getting Started" section (lines 1-50)
   - Show complete task lifecycle example
   - Include expected outputs

2. Reorganize "Command Workflows" section
   - Group by category: Primary, Maintenance, Utility
   - Add consistent example blocks

3. Remove redundant content that belongs in ARCHITECTURE.md
   - Detailed skill architecture
   - Forked subagent pattern details

4. Fix outdated references

### Phase 2: ARCHITECTURE.md Cleanup

1. Remove workflow examples (belong in CLAUDE.md)
2. Focus on technical specifications
3. Update file path references

### Phase 3: docs/ Alignment

1. Ensure docs/README.md accurately reflects current structure
2. Update docs/architecture/system-overview.md to remove duplication
3. Add practical examples to guides

## Appendix

### Files Examined

- `.claude/CLAUDE.md` (499 lines)
- `.claude/ARCHITECTURE.md` (975 lines)
- `.claude/context/index.md` (603 lines)
- `.claude/docs/README.md` (96 lines)
- `.claude/docs/architecture/system-overview.md` (282 lines)
- All 13 command files in `.claude/commands/`
- 15 skill SKILL.md files
- 9 agent files

### Documentation Metrics

| Component | Count | Total Lines |
|-----------|-------|-------------|
| Commands | 13 | ~2,500 |
| Skills | 15 | ~3,000 |
| Agents | 9 | ~4,000 |
| Context files | ~100+ | ~15,000 |
| Rules | 7 | ~800 |
| Main docs (CLAUDE.md, ARCHITECTURE.md) | 2 | ~1,475 |

### Command File Sizes

| Command | Lines | Notes |
|---------|-------|-------|
| task.md | 494 | Very detailed, all modes |
| todo.md | 1114 | Most detailed, includes jq patterns |
| review.md | 449 | Detailed roadmap integration |
| lake.md | 544 | Excellent with examples |
| research.md | 123 | Concise but complete |
| plan.md | 120 | Concise but complete |
| implement.md | 198 | Good with resume logic |
| revise.md | 211 | Clear dual-mode |
| meta.md | 190 | Good overview |
| learn.md | 260 | Good interactive flow |
| errors.md | 192 | Clear analysis mode |
| refresh.md | 182 | Clear structure |
| convert.md | 257 | Clear delegation |
