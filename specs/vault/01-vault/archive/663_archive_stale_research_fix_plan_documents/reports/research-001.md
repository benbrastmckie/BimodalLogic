# Research Report: Task #663

**Task**: 663 - archive_stale_research_fix_plan_documents
**Started**: 2026-01-21T00:00:00Z
**Completed**: 2026-01-21T00:00:00Z
**Effort**: Low
**Priority**: Medium
**Dependencies**: Task 661 (documentation-standards.md)
**Sources/Inputs**: Codebase analysis, documentation-standards.md, prior research (Task 662)
**Artifacts**: This report
**Standards**: report-format.md, documentation-standards.md

## Executive Summary

- Four stale documents exist in `.claude/docs/`: one is a research artifact, one is distilled guidance, one is a historical fix plan, and one is an issue analysis document
- `orchestrator-workflow-execution-issue.md` is correctly located in `architecture/` subdirectory, not docs root
- `skills-vs-agents-context-behavior.md` contains valuable guidance already captured in context/ files; no extraction needed
- All four files are referenced only in archived task research (Tasks 591, 611, 614) and README.md
- Recommendation: Delete all four files and update README.md to remove broken reference

## Context & Scope

Task 663 requires evaluating four potentially stale documents:
1. `.claude/docs/research-skill-agent-contexts.md` - research artifact
2. `.claude/docs/skills-vs-agents-context-behavior.md` - distilled guidance
3. `.claude/docs/memory-leak-fix-plan.md` - historical fix plan
4. `.claude/docs/architecture/orchestrator-workflow-execution-issue.md` - issue document

The objective is to determine for each:
- Is it still relevant?
- Does it contain valuable permanent guidance to extract?
- Should it be archived or deleted?

## Findings

### 1. research-skill-agent-contexts.md

**Location**: `.claude/docs/research-skill-agent-contexts.md`
**Type**: Research artifact
**Created**: 2026-01-18
**Lines**: 201

**Content Summary**:
- Research on Claude Code skills vs agents context behavior
- Documents findings about default skill execution, `context: fork`, and subagent isolation
- Includes official source citations

**References Found**:
- `specs/archive/591_find_fix_double_forking/reports/research-001.md` (archived task)
- `specs/TODO.md` (task description)

**Analysis**:
- This is a raw research artifact that should have been placed in `specs/` from the start
- Research findings have been fully incorporated into:
  - `.claude/context/core/patterns/thin-wrapper-skill.md`
  - `.claude/context/core/architecture/system-overview.md`
- No unique content remains to extract

**Recommendation**: **DELETE**. Content has been distilled to context files.

---

### 2. skills-vs-agents-context-behavior.md

**Location**: `.claude/docs/skills-vs-agents-context-behavior.md`
**Type**: Distilled guidance document
**Created**: 2026-01-18 (derived from research-skill-agent-contexts.md)
**Lines**: 601

**Content Summary**:
- Comprehensive guide on skill vs agent context behavior
- Includes context comparison table, architectural analysis, decision guide
- Documents token efficiency savings (150K+ per session)
- Provides migration guides and debugging tools

**References Found**:
- `specs/archive/591_find_fix_double_forking/reports/research-001.md` (archived task)
- `specs/TODO.md` (task description)

**Analysis**:
- This is an expanded version of the research findings
- Key content already exists in context/:

| Content in skills-vs-agents-context-behavior.md | Existing Coverage |
|------------------------------------------------|-------------------|
| Context comparison table | thin-wrapper-skill.md |
| Three execution patterns (A, B, C) | system-overview.md |
| Pattern selection decision tree | system-overview.md |
| Delegation flow diagram | system-overview.md |
| Command-Skill-Agent mapping | system-overview.md |
| Token budget analysis | Not documented elsewhere (historical interest only) |
| Migration guide | Not needed (system is stable) |
| Debugging tools | Could be useful but is CLI-specific |

**Remaining Unique Content**:
- Token budget analysis: 450 tokens per command cycle, 15K savings per fork
- Debugging commands: `find ~/.claude/projects -name "*.jsonl"`, etc.

**Assessment**: The token budget numbers are interesting but historical. The debugging commands are useful but belong in a troubleshooting guide, not architecture docs. Neither justifies keeping a 600-line document.

**Recommendation**: **DELETE**. Core patterns documented in context/; remaining content is historical or belongs elsewhere.

---

### 3. memory-leak-fix-plan.md

**Location**: `.claude/docs/memory-leak-fix-plan.md`
**Type**: Historical fix plan
**Created**: 2026-01-18
**Lines**: 381

**Content Summary**:
- Root cause analysis of JavaScript heap OOM errors during /implement
- Four identified causes: zombie processes, delegation chain memory, unbounded context, no resource limits
- Proposed fixes in three priority tiers
- Testing plan and success criteria

**References Found**:
- `specs/archive/614_refactor_cleanup_to_refresh_command/plans/implementation-001.md`
- `specs/archive/614_refactor_cleanup_to_refresh_command/reports/research-001.md`
- `specs/archive/611_context_optimization_and_loading_patterns/summaries/implementation-summary-20260119.md`
- `specs/archive/591_find_fix_double_forking/reports/research-001.md`
- `specs/TODO.md` (task description)

**Analysis**:
- This issue was addressed by Task 614 (refactor cleanup to /refresh command)
- The `/refresh` command now exists and handles:
  - Zombie process cleanup (Fix 1.1, 2.3)
  - Session cleanup (Fix 2.2)
- Delegation chain flattening (Fix 2.1) was NOT implemented (still 3 levels)
- Circuit breaker (Fix 3.2) was NOT implemented
- Memory tracking (Fix 3.1) was NOT implemented

**Remaining Unimplemented Fixes**:

| Fix | Status | Notes |
|-----|--------|-------|
| 1.2: max_turns limit | Unknown | Not verified if Task tool supports this |
| 1.3: Memory budget docs | Not done | Could still be valuable |
| 2.1: Flatten delegation | Not done | Architectural decision to keep 3 layers |
| 3.1: Memory tracking | Not done | Low priority enhancement |
| 3.2: Circuit breaker | Not done | Low priority enhancement |

**Assessment**: The implemented fixes (/refresh command) address the primary symptoms. Unimplemented fixes are either architectural decisions (keep 3 layers) or low-priority enhancements. The document served its purpose for Task 614 planning.

**Recommendation**: **DELETE**. The actionable items have been addressed; remaining items are deferred enhancements that can be re-researched if needed.

---

### 4. orchestrator-workflow-execution-issue.md

**Location**: `.claude/docs/architecture/orchestrator-workflow-execution-issue.md`
**Type**: Issue analysis document
**Created**: Unknown (references Tasks 240-247, 335, 342-345)
**Lines**: 165

**Content Summary**:
- Root cause analysis of Task 335 workflow execution failure
- Describes issue where orchestrator doesn't execute command file workflow stages
- Proposes 4 tasks (342-345) totaling 19-28 hours to fix

**References Found**:
- `.claude/docs/README.md` (listed in documentation map)
- `specs/archive/594_fix_progress_interruptions_agent_system/reports/research-001.md`
- `specs/archive/342_research_orchestrator_command_file_workflow_execution_mechanism/reports/research-001.md`

**Analysis**:
- This document describes an issue from the "OpenAgents migration" era (Tasks 240-247)
- The proposed solution (Tasks 342-345) may have been implemented or superseded
- Current system uses a different architecture (thin wrapper skills with internal postflight)
- The file is listed in README.md's documentation map but provides no current value

**Assessment**: This is a historical issue document that describes a problem from an earlier architectural iteration. The current system uses Pattern A (delegating skills with internal postflight) which handles workflow execution differently than described here.

**Recommendation**: **DELETE**. Historical issue document from superseded architecture.

---

## Cross-Reference Summary

**Files that reference these documents**:

| File | References |
|------|------------|
| `specs/TODO.md` | Task 663 description (meta-reference) |
| `specs/archive/591_*/research-001.md` | All four files |
| `specs/archive/594_*/research-001.md` | orchestrator-workflow-execution-issue.md |
| `specs/archive/611_*/implementation-summary.md` | memory-leak-fix-plan.md |
| `specs/archive/614_*/research-001.md` | memory-leak-fix-plan.md |
| `specs/archive/614_*/plans/implementation-001.md` | memory-leak-fix-plan.md |
| `.claude/docs/README.md` | orchestrator-workflow-execution-issue.md (in doc map) |

**Impact of Deletion**:
- Archive references are historical and don't need updating
- README.md documentation map needs updating to remove broken reference

---

## Recommendations

### Implementation Plan

**Phase 1: Delete stale documents**

1. Delete `.claude/docs/research-skill-agent-contexts.md`
2. Delete `.claude/docs/skills-vs-agents-context-behavior.md`
3. Delete `.claude/docs/memory-leak-fix-plan.md`
4. Delete `.claude/docs/architecture/orchestrator-workflow-execution-issue.md`

**Phase 2: Update README.md**

Update `.claude/docs/README.md` documentation map to remove reference to deleted file:

```markdown
# Before (line 32)
│   └── orchestrator-workflow-execution-issue.md

# After (remove the line entirely)
```

**Phase 3: Verify no broken internal links**

After deletion, grep for any remaining references and fix if needed.

---

## Decisions

1. **No extraction needed**: All valuable content from `skills-vs-agents-context-behavior.md` already exists in context/ files
2. **Memory fix plan served its purpose**: The actionable items led to Task 614 and /refresh command
3. **Historical documents provide no current value**: Both issue documents describe superseded architectures
4. **Archive references acceptable as-is**: Archived task research can reference deleted files (historical context)

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Deleting useful debugging commands | Low | Commands are CLI-specific; can be re-documented in troubleshooting guide if needed |
| Loss of token budget analysis | Low | Numbers are historical; can be re-measured if optimization needed |
| Broken link in README.md | Medium | Update README.md to remove reference |
| Archive references become stale | None | Archive references are already historical; no action needed |

---

## Appendix

### Files Analyzed

- `/home/benjamin/Projects/ProofChecker/.claude/docs/research-skill-agent-contexts.md` (201 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/docs/skills-vs-agents-context-behavior.md` (601 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/docs/memory-leak-fix-plan.md` (381 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/docs/architecture/orchestrator-workflow-execution-issue.md` (165 lines)

### Context Files Containing Equivalent Content

- `.claude/context/core/patterns/thin-wrapper-skill.md` - Skill delegation pattern
- `.claude/context/core/architecture/system-overview.md` - Three-layer architecture, patterns A/B/C
- `.claude/context/core/formats/subagent-return.md` - Return format standard

### Related Completed Tasks

- Task 591: find_fix_double_forking (archived)
- Task 611: context_optimization_and_loading_patterns (archived)
- Task 614: refactor_cleanup_to_refresh_command (archived)
- Task 661: create_documentation_standards_file (completed)
- Task 662: consolidate_update_docs_readme (prior research)
