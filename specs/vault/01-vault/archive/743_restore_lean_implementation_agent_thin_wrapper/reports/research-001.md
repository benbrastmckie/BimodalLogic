# Research Report: Task #743

**Task**: 743 - restore_lean_implementation_agent_thin_wrapper
**Started**: 2026-01-29
**Completed**: 2026-01-29
**Effort**: 2.5 hours (estimated)
**Priority**: high
**Dependencies**: None (Task 742 completed successfully, provides parallel template)
**Sources/Inputs**: Codebase files, Task 742 artifacts
**Artifacts**: specs/743_restore_lean_implementation_agent_thin_wrapper/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Current skill-lean-implementation is 524-line direct execution that should be converted to ~100-line thin wrapper
- Parallel task 742 successfully restored lean-research-agent and skill-lean-research, providing proven template
- Lean-implementation-agent exists but is marked DEPRECATED; needs blocked tools section added
- Key patterns: early metadata (Stage 0), completion_data generation, blocked MCP tools guardrails
- Conversion follows established skill-implementer and general-implementation-agent patterns

## Context & Scope

Task 743 aims to restore the lean-implementation-agent subagent and convert skill-lean-implementation from direct execution to thin wrapper delegation pattern. This mirrors task 742 which successfully completed the same transformation for lean-research-agent.

The goal is architectural consistency: all Lean MCP tool usage should flow through dedicated subagents with explicit blocked tool guardrails, while skills remain thin wrappers handling preflight/postflight operations.

## Findings

### 1. Current State of skill-lean-implementation

**File**: `.claude/skills/skill-lean-implementation/SKILL.md` (524 lines)

**Current Architecture**: Direct execution skill that:
- Performs all Lean MCP tool calls directly (lean_goal, lean_multi_attempt, lean_hover_info, etc.)
- Handles proof development loop inline
- Contains tactic selection strategy documentation
- Performs phase execution and verification
- Handles completion_data generation (Stage 9)
- Manages postflight operations (Stage 10-14)

**Key Sections to Preserve**:
- Stage 1: Input Validation (lines 47-80)
- Stage 2: Preflight Status Update (lines 85-110)
- Stage 3: Create Postflight Marker (lines 114-129)
- Stage 10: Update Task Status (Postflight) - contains completion_data logic (lines 314-370)
- Stage 11: Link Artifacts (lines 376-406)
- Stage 12: Git Commit (lines 409-420)
- Stage 13: Cleanup (lines 423-430)
- Stage 14: Return Brief Summary (lines 435-448)

**Sections to Move to Agent**:
- Stage 4: Load and Parse Implementation Plan
- Stage 5: Find Resume Point
- Stage 6: Execute Proof Development Loop (largest section)
- Stage 7: Run Final Build Verification
- Stage 8: Create Implementation Summary
- Stage 9: Generate Completion Data (agent generates, skill propagates)

**Blocked Tools Note (line 14)**:
> `lean_diagnostic_messages` and `lean_file_outline` removed due to MCP hanging bug

This warning needs to be made more prominent in the restored agent.

### 2. Thin Wrapper Pattern from skill-implementer

**File**: `.claude/skills/skill-implementer/SKILL.md` (409 lines)

**Pattern Structure**:
```
Stage 1: Input Validation (20 lines)
Stage 2: Preflight Status Update (25 lines)
Stage 3: Create Postflight Marker (20 lines)
Stage 4: Prepare Delegation Context (30 lines)
Stage 5: Invoke Subagent via Task tool (25 lines)
Stage 5a: Validate Subagent Return Format (15 lines)
Stage 6: Parse Subagent Return (read metadata file) (20 lines)
Stage 7: Update Task Status (Postflight) (60 lines, with completion_data)
Stage 8: Link Artifacts (30 lines)
Stage 9: Git Commit (15 lines)
Stage 10: Cleanup (10 lines)
Stage 11: Return Brief Summary (15 lines)
```

**Key Features**:
- Uses Task tool (NOT Skill tool) to spawn subagent
- Passes delegation context with session_id, task_context, plan_path, metadata_file_path
- Stage 5a validates that subagent didn't accidentally return JSON to console
- Reads metadata from `.return-meta.json` file
- Extracts completion_data fields (completion_summary, claudemd_suggestions, roadmap_items)
- Propagates completion_data to state.json

### 3. Pattern from skill-lean-research (Task 742 Result)

**File**: `.claude/skills/skill-lean-research/SKILL.md` (305 lines)

Recently converted by task 742, this skill demonstrates the Lean-specific thin wrapper pattern:
- Frontmatter: `allowed-tools: Task, Bash, Edit, Read, Write`
- Delegates to lean-research-agent via Task tool
- Preserves all postflight stages for status update and commit
- Matches skill-researcher pattern for consistency

**Difference from skill-implementer**:
- No completion_data handling (research skills don't complete tasks)
- Different status values (researched vs implemented)
- Different timeout (3600s vs 7200s)

### 4. Current State of lean-implementation-agent

**File**: `.claude/agents/lean-implementation-agent.md` (143 lines)

**Status**: DEPRECATED with notice:
```
> **DEPRECATED (2026-01-28)**: This agent is no longer invoked. The Lean implementation functionality
> has been moved to direct execution in `skill-lean-implementation` to fix MCP tool hanging issues
> in subagents (Claude Code bugs #15945, #13254, #4580).
```

**Current Content**:
- Has BLOCKED TOOLS section (lines 43-44) but brief - just lists tools without explanation
- Has Stage 0 early metadata pattern (lines 81-109)
- References lean-implementation-flow.md for detailed execution stages
- Has MCP Scope Note about user scope configuration
- Has Core Tools and Search Tools lists
- Has Critical Requirements section

**Changes Needed for Restoration**:
1. Remove DEPRECATED notice
2. Expand BLOCKED TOOLS section (add table, explanations, "Why Blocked")
3. Verify blocked tools not in Allowed Tools section
4. Add explicit MUST NOT #11: "Call blocked tools (lean_diagnostic_messages, lean_file_outline)"
5. Ensure completion_data generation is documented

### 5. Pattern from lean-research-agent (Task 742 Result)

**File**: `.claude/agents/lean-research-agent.md` (198 lines)

**BLOCKED TOOLS Section (lines 21-35)**:
```markdown
## BLOCKED TOOLS (NEVER USE)

**CRITICAL**: These tools have known bugs that cause incorrect behavior. DO NOT call them under any circumstances.

| Tool | Bug | Alternative |
|------|-----|-------------|
| `lean_diagnostic_messages` | lean-lsp-mcp #118 | `lean_goal` or `lake build` via Bash |
| `lean_file_outline` | lean-lsp-mcp #115 | `Read` + `lean_hover_info` |

**Full documentation**: `.claude/context/core/patterns/blocked-mcp-tools.md`

**Why Blocked**:
- `lean_diagnostic_messages`: Returns inconsistent or incorrect diagnostic information...
- `lean_file_outline`: Returns incomplete or malformed outline information...
```

**Critical Requirements (lines 174-197)**:
- MUST DO #10: "NEVER call lean_diagnostic_messages or lean_file_outline (blocked tools)"
- MUST NOT #11: "Call blocked tools (lean_diagnostic_messages, lean_file_outline)"

This pattern should be copied to lean-implementation-agent.

### 6. Metadata File Exchange Pattern

**File**: `.claude/context/core/formats/return-metadata-file.md` (504 lines)

**Key Schema for Implementation Agents**:
```json
{
  "status": "implemented|partial|failed",
  "artifacts": [...],
  "completion_data": {
    "completion_summary": "1-3 sentence description of what was accomplished",
    "roadmap_items": ["Optional explicit roadmap item texts"]
  },
  "metadata": {
    "session_id": "...",
    "agent_type": "lean-implementation-agent",
    "phases_completed": 4,
    "phases_total": 4
  }
}
```

**Status Values**: NEVER use "completed" (triggers Claude stop behavior). Use "implemented" for success.

### 7. Early Metadata Pattern (Stage 0)

**File**: `.claude/context/core/patterns/early-metadata-pattern.md` (262 lines)

**Pattern Summary**:
1. Create metadata file BEFORE any substantive work
2. Set status to "in_progress" with partial_progress object
3. Update partial_progress at milestones (phase completions)
4. Update to final status on completion

**Implementation Agent Milestones**:
```
| Milestone | partial_progress.stage | partial_progress.details |
|-----------|------------------------|--------------------------|
| After plan loaded | "plan_loaded" | "Loaded {N}-phase plan, resuming from phase {P}" |
| After each phase | "phase_{N}_completed" | "Phase {N} completed: {phase_name}" |
| After verification | "verification_completed" | "Build/tests passed" |
| After summary written | "summary_created" | "Summary written to {path}" |
```

### 8. Completion Data Generation

**Source**: Current skill-lean-implementation Stage 9 (lines 299-310) and general-implementation-agent Stage 6a

**Agent Responsibilities**:
1. Generate `completion_summary`: Focus on mathematical/proof outcome
2. Optionally generate `roadmap_items`: Array of ROAD_MAP.md item texts

**Example for Lean**:
```json
{
  "completion_summary": "Proved completeness theorem using canonical model construction. Implemented 4 supporting lemmas including truth lemma and existence lemma.",
  "roadmap_items": ["Prove completeness theorem for K modal logic"]
}
```

**Skill Responsibilities (Postflight)**:
1. Read completion_data from metadata file
2. Propagate completion_summary to state.json
3. Propagate roadmap_items to state.json (if non-empty)

### 9. Key Differences: Research vs Implementation Agents

| Aspect | Research Agent | Implementation Agent |
|--------|----------------|----------------------|
| Status value | "researched" | "implemented" |
| Timeout | 3600s | 7200s |
| completion_data | Not applicable | Required |
| Phases | N/A | Yes (from plan) |
| Verification | N/A | lake build |
| Partial progress | search/synthesis stages | phase numbers |
| Git commits | Research commit | Per-phase + final |

## Recommendations

### Implementation Approach

**Phase 1: Restore lean-implementation-agent.md** (~45 min)
1. Remove DEPRECATED notice block
2. Add BLOCKED TOOLS section before Allowed Tools (copy from lean-research-agent)
3. Remove lean_diagnostic_messages and lean_file_outline from Core Tools
4. Add "Why Blocked" explanations
5. Add explicit prohibition in Critical Requirements
6. Verify Stage 0 early metadata pattern is present
7. Verify completion_data generation is documented

**Phase 2: Convert skill-lean-implementation to Thin Wrapper** (~60 min)
1. Update frontmatter: `allowed-tools: Task, Bash, Edit, Read, Write`
2. Keep Stages 1-3 (validation, preflight, marker)
3. Add Stage 4: Prepare Delegation Context (from skill-implementer)
4. Add Stage 5: Invoke Subagent via Task tool
5. Add Stage 5a: Validate Subagent Return Format
6. Add Stage 6: Parse Subagent Return (read metadata file)
7. Keep Stage 7: Update Task Status with completion_data handling
8. Keep Stages 8-11 (artifacts, commit, cleanup, return)
9. Remove all direct MCP tool calls and proof development logic

**Phase 3: Update CLAUDE.md** (~15 min)
1. Change skill-lean-implementation agent from "(direct execution)" to "lean-implementation-agent"
2. Verify table alignment

**Phase 4: Verification** (~30 min)
1. Verify all files have valid syntax
2. Verify blocked tools not in Allowed Tools
3. Verify Task tool invocation pattern matches skill-implementer
4. Verify completion_data flow from agent to skill postflight

### Estimated Line Counts

- skill-lean-implementation (thin wrapper): ~100-120 lines
  - Closer to skill-implementer (409 lines) than skill-researcher (305 lines) due to completion_data handling
  - But significantly shorter than current 524 lines
- lean-implementation-agent: ~150-200 lines
  - Similar to lean-research-agent (198 lines)
  - Detailed execution in lean-implementation-flow.md

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Agent may call blocked tools | Medium | Prominent BLOCKED TOOLS section, Critical Requirements checklist |
| MCP tool hanging in subagent | Medium | Early metadata ensures recovery; agent continues with partial |
| completion_data not propagated | High | Explicit Stage 6a in agent, explicit Stage 7 extraction in skill |
| Phase commit granularity lost | Low | Agent commits per-phase; skill commits final |

## Appendix

### Files Examined

1. `.claude/skills/skill-lean-implementation/SKILL.md` (524 lines) - current direct execution
2. `.claude/skills/skill-implementer/SKILL.md` (409 lines) - thin wrapper template
3. `.claude/skills/skill-lean-research/SKILL.md` (305 lines) - task 742 result
4. `.claude/agents/lean-implementation-agent.md` (143 lines) - current deprecated
5. `.claude/agents/lean-research-agent.md` (198 lines) - task 742 result
6. `.claude/agents/general-implementation-agent.md` (493 lines) - implementation agent template
7. `.claude/context/core/formats/return-metadata-file.md` (504 lines)
8. `.claude/context/core/patterns/early-metadata-pattern.md` (262 lines)
9. `.claude/context/core/patterns/blocked-mcp-tools.md` (66 lines)
10. Task 742 implementation summary and plan

### Template Sections to Copy

**BLOCKED TOOLS Section** (from lean-research-agent):
```markdown
## BLOCKED TOOLS (NEVER USE)

**CRITICAL**: These tools have known bugs that cause incorrect behavior. DO NOT call them under any circumstances.

| Tool | Bug | Alternative |
|------|-----|-------------|
| `lean_diagnostic_messages` | lean-lsp-mcp #118 | `lean_goal` or `lake build` via Bash |
| `lean_file_outline` | lean-lsp-mcp #115 | `Read` + `lean_hover_info` |

**Full documentation**: `.claude/context/core/patterns/blocked-mcp-tools.md`

**Why Blocked**:
- `lean_diagnostic_messages`: Returns inconsistent or incorrect diagnostic information. Can cause agent confusion and incorrect error handling decisions.
- `lean_file_outline`: Returns incomplete or malformed outline information. The tool's output is unreliable for determining file structure.
```

**Delegation Context** (from skill-implementer):
```json
{
  "session_id": "sess_{timestamp}_{random}",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "implement", "skill-lean-implementation"],
  "timeout": 7200,
  "task_context": {
    "task_number": N,
    "task_name": "{project_name}",
    "description": "{description}",
    "language": "lean"
  },
  "plan_path": "specs/{N}_{SLUG}/plans/implementation-{NNN}.md",
  "metadata_file_path": "specs/{N}_{SLUG}/.return-meta.json"
}
```

**completion_data Extraction** (from skill-implementer Stage 6):
```bash
completion_summary=$(jq -r '.completion_data.completion_summary // ""' "$metadata_file")
roadmap_items=$(jq -c '.completion_data.roadmap_items // []' "$metadata_file")
```

## Next Steps

Run `/plan 743` to create detailed implementation plan based on this research.
