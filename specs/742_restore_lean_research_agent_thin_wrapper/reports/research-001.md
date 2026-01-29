# Research Report: Task #742

**Task**: 742 - restore_lean_research_agent_thin_wrapper
**Started**: 2026-01-29T12:00:00Z
**Completed**: 2026-01-29T12:15:00Z
**Effort**: 2-3 hours (implementation)
**Priority**: high
**Dependencies**: None
**Sources/Inputs**: skill-researcher/SKILL.md, general-research-agent.md, skill-lean-research/SKILL.md, lean-research-agent.md, blocked-mcp-tools.md, lean-research-flow.md, return-metadata-file.md
**Artifacts**: specs/742_restore_lean_research_agent_thin_wrapper/reports/research-001.md
**Standards**: report-format.md

---

## Executive Summary

- skill-researcher (308 lines) provides the thin wrapper pattern: frontmatter with `allowed-tools: Task`, delegation via Task tool, skill-internal postflight handling
- general-research-agent (404 lines) provides the agent pattern: Stage 0 early metadata, execution flow with stages 1-7, metadata file exchange, brief text return
- skill-lean-research currently has 408 lines of direct execution code; needs reduction to ~80-line thin wrapper
- lean-research-agent.md (151 lines in current deprecated state, 144 lines in .bak archive) needs BLOCKED TOOLS section added before undeprecation
- Blocked tools guardrails are documented in blocked-mcp-tools.md and must be prominent in the agent

---

## Context & Scope

### What Was Researched

This research analyzed the patterns for converting skill-lean-research from direct execution to thin wrapper delegation pattern, and restoring lean-research-agent with proper blocked tool guardrails.

### Key Files Analyzed

| File | Lines | Purpose |
|------|-------|---------|
| `.claude/skills/skill-researcher/SKILL.md` | 308 | Model thin wrapper pattern |
| `.claude/agents/general-research-agent.md` | 404 | Model agent pattern |
| `.claude/skills/skill-lean-research/SKILL.md` | 408 | Current direct execution (to be converted) |
| `.claude/agents/lean-research-agent.md` | 151 | Deprecated agent (to be restored) |
| `.claude/agents/archive/lean-research-agent.md.bak` | 144 | Pre-deprecation backup |
| `.claude/context/core/patterns/blocked-mcp-tools.md` | 66 | Blocked tool documentation |
| `.claude/context/core/formats/return-metadata-file.md` | 504 | Metadata file schema |
| `.claude/context/project/lean4/agents/lean-research-flow.md` | 327 | Lean research execution flow |

---

## Findings

### 1. Thin Wrapper Pattern (from skill-researcher)

#### Frontmatter Structure
```yaml
---
name: skill-lean-research
description: Research Lean 4 and Mathlib for theorem proving tasks. Invoke for Lean-language research using LeanSearch, Loogle, and lean-lsp tools.
allowed-tools: Task, Bash, Edit, Read, Write
---
```

Key change: Replace all MCP tools with just `Task` (plus Bash, Edit, Read, Write for postflight).

#### Stage Flow (11 stages in skill-researcher)

1. **Input Validation** - Parse task_number, validate task exists in state.json
2. **Preflight Status Update** - Update state.json and TODO.md to `[RESEARCHING]`
3. **Create Postflight Marker** - Write `specs/.postflight-pending`
4. **Prepare Delegation Context** - Build JSON context for subagent
5. **Invoke Subagent** - Use **Task tool** to spawn lean-research-agent
6. **Parse Subagent Return** - Read `.return-meta.json` file
7. **Update Task Status** - state.json and TODO.md to `[RESEARCHED]`
8. **Link Artifacts** - Add artifact to state.json with summary
9. **Git Commit** - Commit with session ID
10. **Cleanup** - Remove marker and metadata files
11. **Return Brief Summary** - Text response (NOT JSON)

#### Critical Delegation Call Pattern
```
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "lean-research-agent"
  - prompt: [Include task_context, delegation_context, focus_prompt, metadata_file_path]
  - description: "Execute research for task {N}"
```

**WARNING**: Do NOT use `Skill(lean-research-agent)` - this will FAIL.

### 2. Agent Pattern (from general-research-agent)

#### Required Sections for lean-research-agent

1. **Overview** - Purpose, invoked by, return format
2. **Agent Metadata** - Name, purpose, invoked by, return format
3. **Allowed Tools** - File operations, Build tools, MCP tools
4. **Context References** - Lazy load via @-references
5. **Search Decision Tree** - Tool selection guidance
6. **Stage 0: Early Metadata** - CRITICAL: Create metadata file BEFORE work
7. **Execution** - Reference to lean-research-flow.md
8. **Critical Requirements** - MUST DO / MUST NOT lists

#### Stage 0 Early Metadata Pattern (CRITICAL)

```bash
mkdir -p "specs/{N}_{SLUG}"
```

```json
{
  "status": "in_progress",
  "started_at": "{ISO8601 timestamp}",
  "artifacts": [],
  "partial_progress": {
    "stage": "initializing",
    "details": "Agent started, parsing delegation context"
  },
  "metadata": {
    "session_id": "{from delegation context}",
    "agent_type": "lean-research-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "lean-research-agent"]
  }
}
```

**Why Critical**: Ensures metadata exists even if agent is interrupted. Skill postflight can detect interruption and guide resume.

### 3. Blocked Tools Guardrails

#### Current Issue in lean-research-agent.md.bak

The archived backup (line 39-48) lists `lean_diagnostic_messages` and `lean_file_outline` as regular core tools without warning:

```
**Core Tools (No Rate Limit)**:
- `mcp__lean-lsp__lean_goal` - Proof state at position (MOST IMPORTANT)
- `mcp__lean-lsp__lean_diagnostic_messages` - Compiler errors/warnings    <-- PROBLEM
...
- `mcp__lean-lsp__lean_file_outline` - Token-efficient file skeleton      <-- PROBLEM
```

#### Required Guardrails

Add explicit BLOCKED TOOLS section BEFORE the allowed tools list:

```markdown
## BLOCKED TOOLS (NEVER USE)

**CRITICAL**: These tools have known bugs that cause incorrect behavior. DO NOT call them under any circumstances.

| Tool | Bug | Alternative |
|------|-----|-------------|
| `lean_diagnostic_messages` | lean-lsp-mcp #118 | `lean_goal` or `lake build` via Bash |
| `lean_file_outline` | lean-lsp-mcp #115 | `Read` + `lean_hover_info` |

**Full documentation**: `.claude/context/core/patterns/blocked-mcp-tools.md`
```

Then remove these tools from the "Core Tools" list in the Allowed Tools section.

### 4. Line-by-Line Mapping: What Moves Where

#### Content Moving FROM skill-lean-research TO lean-research-agent

| Lines in skill-lean-research | Content | Destination in lean-research-agent |
|------------------------------|---------|-----------------------------------|
| 14-35 | Context References, Trigger Conditions | Context References section |
| 40-62 | Stage 1: Input Validation | NOT moved (stays in skill) |
| 64-82 | Stage 2: Preflight Status Update | NOT moved (stays in skill) |
| 84-102 | Stage 3: Create Postflight Marker | NOT moved (stays in skill) |
| 104-168 | Stage 4-5: Search Strategy, Execute Searches | Stage 2-3 in agent |
| 189-257 | Stage 6-7: Synthesize, Create Report | Stage 4-5 in agent |
| 259-312 | Stage 8-12: Postflight, Commit, Cleanup | NOT moved (stays in skill) |
| 113-188 | Rate Limits, Fallback Chains, MCP Recovery | Error Handling section in agent |

#### Content KEPT in skill-lean-research (Thin Wrapper)

1. **Frontmatter** (new: `allowed-tools: Task, Bash, Edit, Read, Write`)
2. **Description** (~5 lines)
3. **Stage 1: Input Validation** (~20 lines)
4. **Stage 2: Preflight Status Update** (~15 lines)
5. **Stage 3: Create Postflight Marker** (~15 lines)
6. **Stage 4: Prepare Delegation Context** (~15 lines, NEW)
7. **Stage 5: Invoke Subagent via Task tool** (~10 lines, NEW)
8. **Stage 6: Parse Return (Read metadata file)** (~15 lines)
9. **Stage 7-10: Postflight, Commit, Cleanup** (~25 lines)
10. **Stage 11: Return Brief Summary** (~5 lines)

**Estimated Total**: ~80-90 lines

### 5. Current vs Target State

#### skill-lean-research/SKILL.md

| Aspect | Current (408 lines) | Target (~80 lines) |
|--------|---------------------|-------------------|
| allowed-tools | 11 MCP tools + file tools | Task, Bash, Edit, Read, Write |
| Execution | Direct MCP tool calls | Delegate via Task tool |
| Report creation | In skill | In agent |
| Search logic | In skill | In agent |
| Postflight | In skill | In skill (remains) |

#### lean-research-agent.md

| Aspect | Current (deprecated, 151 lines) | Target (~250 lines) |
|--------|--------------------------------|---------------------|
| Status | DEPRECATED notice at top | Active (no notice) |
| Blocked tools | Listed in tools section but not blocked | Explicit BLOCKED TOOLS section |
| Stage 0 | Present but abbreviated | Full early metadata pattern |
| Execution flow | References lean-research-flow.md | Same (no change) |
| Error handling | Brief | Full MCP recovery patterns |

---

## Decisions

1. **Use skill-researcher as exact template** for skill-lean-research thin wrapper structure
2. **Use general-research-agent as template** for lean-research-agent restoration, NOT the .bak file
3. **Add BLOCKED TOOLS section prominently** before Allowed Tools in agent
4. **Keep lean-research-flow.md as-is** - agent references it for detailed stages
5. **Move all MCP tool documentation** from skill to agent
6. **Keep search decision tree** in agent (already exists in deprecated version)

---

## Recommendations

### Implementation Order

1. **Phase 1**: Restore lean-research-agent.md
   - Remove DEPRECATED notice
   - Add BLOCKED TOOLS section before Allowed Tools
   - Remove lean_diagnostic_messages and lean_file_outline from Core Tools list
   - Keep Stage 0 early metadata (already present)
   - Keep reference to lean-research-flow.md

2. **Phase 2**: Convert skill-lean-research to thin wrapper
   - Update frontmatter: `allowed-tools: Task, Bash, Edit, Read, Write`
   - Remove all MCP tool calls and direct execution logic
   - Add delegation context preparation (copy from skill-researcher Stage 4)
   - Add Task tool invocation (copy from skill-researcher Stage 5)
   - Keep all postflight stages (6-11)

3. **Phase 3**: Update CLAUDE.md skill-to-agent mapping
   - Change `skill-lean-research | (direct execution) | Lean 4/Mathlib research`
   - To: `skill-lean-research | lean-research-agent | Lean 4/Mathlib research`

### Template for skill-lean-research Thin Wrapper

```yaml
---
name: skill-lean-research
description: Research Lean 4 and Mathlib for theorem proving tasks. Invoke for Lean-language research using LeanSearch, Loogle, and lean-lsp tools.
allowed-tools: Task, Bash, Edit, Read, Write
---

# Lean Research Skill

Thin wrapper that delegates Lean research to `lean-research-agent` subagent.

**IMPORTANT**: This skill implements the skill-internal postflight pattern.

## Context References
[Reference to return-metadata-file.md, postflight-control.md, jq-escaping-workarounds.md]

## Trigger Conditions
[Same as current]

---

## Stage 1: Input Validation
[Keep from current skill-lean-research lines 40-62]

## Stage 2: Preflight Status Update
[Keep from current skill-lean-research lines 64-82]

## Stage 3: Create Postflight Marker
[Keep from current skill-lean-research lines 84-102]

## Stage 4: Prepare Delegation Context
[Copy from skill-researcher lines 106-125]

## Stage 5: Invoke Subagent
[Copy from skill-researcher lines 127-151, change to lean-research-agent]

## Stage 6: Parse Subagent Return
[Copy from skill-researcher lines 153-169]

## Stage 7: Update Task Status
[Copy from skill-researcher lines 171-191]

## Stage 8: Link Artifacts
[Copy from skill-researcher lines 193-217]

## Stage 9: Git Commit
[Keep from current skill-lean-research lines 315-325]

## Stage 10: Cleanup
[Keep from current skill-lean-research lines 329-337]

## Stage 11: Return Brief Summary
[Keep structure from skill-researcher lines 249-262]

## Error Handling
[Simplified - errors handled by agent, postflight handles metadata parsing]

## Return Format
[Same as skill-researcher]
```

### Template for lean-research-agent BLOCKED TOOLS Section

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

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| MCP tools may still hang in subagent | Document recovery pattern; agent continues with partial results |
| Agent may call blocked tools | Explicit BLOCKED TOOLS section at top of allowed tools |
| Skill-to-agent communication failure | Early metadata pattern ensures metadata exists for resume |
| Line count may exceed estimate | Consolidate repeated patterns; reference external docs |

---

## Appendix

### Files Read
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-researcher/SKILL.md` (308 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/agents/general-research-agent.md` (404 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-lean-research/SKILL.md` (408 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/agents/lean-research-agent.md` (151 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/agents/archive/lean-research-agent.md.bak` (144 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/patterns/blocked-mcp-tools.md` (66 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/formats/return-metadata-file.md` (504 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/context/project/lean4/agents/lean-research-flow.md` (327 lines)

### Key Patterns Referenced
- Thin wrapper pattern: skill-researcher SKILL.md
- Agent execution pattern: general-research-agent.md
- Early metadata pattern: return-metadata-file.md Stage 0
- Blocked tools: blocked-mcp-tools.md
- Metadata file schema: return-metadata-file.md
- Lean execution flow: lean-research-flow.md
