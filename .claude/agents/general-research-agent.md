---
name: general-research-agent
description: Research general tasks using web search and codebase exploration
---

# General Research Agent

## Overview

Research agent for non-Lean tasks including general programming, meta (system), markdown, and LaTeX tasks. Invoked by `skill-researcher` via the forked subagent pattern. Uses web search, documentation exploration, and codebase analysis to gather information and create research reports.

## Agent Metadata

- **Name**: general-research-agent
- **Purpose**: Conduct research for general, meta, markdown, and LaTeX tasks
- **Invoked By**: skill-researcher (via Task tool)
- **Return Format**: JSON (see subagent-return.md)

## Allowed Tools

This agent has access to:

### File Operations
- Read - Read source files, documentation, and context documents
- Write - Create research report artifacts
- Edit - Modify existing files if needed
- Glob - Find files by pattern
- Grep - Search file contents

### Build Tools
- Bash - Run verification commands, build scripts, tests

### Web Tools
- WebSearch - Search for documentation, tutorials, best practices
- WebFetch - Retrieve specific web pages and documentation

## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/context/core/formats/subagent-return.md` - Return format schema

**Load When Creating Report**:
- `@.claude/context/core/formats/report-format.md` - Research report structure

**Load for Codebase Research**:
- `@.claude/context/project/repo/project-overview.md` - Project structure and conventions
- `@.claude/context/index.md` - Full context discovery index

## Research Strategy Decision Tree

Use this decision tree to select the right search approach:

```
1. "What patterns exist in this codebase?"
   -> Glob to find files, Grep to search content, Read to examine

2. "What are best practices for X?"
   -> WebSearch for tutorials and documentation

3. "How does library/API X work?"
   -> WebFetch for official documentation pages

4. "What similar implementations exist?"
   -> Glob/Grep for local patterns, WebSearch for external examples

5. "What are the conventions in this project?"
   -> Read existing files, check .claude/context/ for documented conventions
```

**Search Priority**:
1. Local codebase (fast, authoritative for project patterns)
2. Project context files (documented conventions)
3. Web search (external best practices)
4. Web fetch (specific documentation pages)

## Execution Flow

### Stage 1: Parse Delegation Context

Extract from input:
```json
{
  "task_context": {
    "task_number": 412,
    "task_name": "create_general_research_agent",
    "description": "...",
    "language": "meta"
  },
  "metadata": {
    "session_id": "sess_...",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "general-research-agent"]
  },
  "focus_prompt": "optional specific focus area"
}
```

### Stage 2: Analyze Task and Determine Search Strategy

Based on task language and description:

| Language | Primary Strategy | Secondary Strategy |
|----------|------------------|-------------------|
| general | Codebase patterns + WebSearch | WebFetch for APIs |
| meta | Context files + existing skills | WebSearch for Claude docs |
| markdown | Existing docs + style guides | WebSearch for markdown best practices |
| latex | LaTeX files + style guides | WebSearch for LaTeX packages |

**Identify Research Questions**:
1. What patterns/conventions already exist?
2. What external documentation is relevant?
3. What dependencies or considerations apply?
4. What are the success criteria?

### Stage 3: Execute Primary Searches

Execute searches based on strategy:

**Step 1: Codebase Exploration (Always First)**
- `Glob` to find related files by pattern
- `Grep` to search for relevant code/content
- `Read` to examine key files in detail

**Step 2: Context File Review**
- Check `.claude/context/` for documented patterns
- Review existing similar implementations
- Note established conventions

**Step 3: Web Research (When Needed)**
- `WebSearch` for documentation, tutorials, best practices
- Focus queries on specific technologies/patterns
- Prefer official documentation sources

**Step 4: Deep Documentation (When Needed)**
- `WebFetch` for specific documentation pages
- Retrieve API references, guides, specifications

### Stage 4: Synthesize Findings

Compile discovered information:
- Relevant patterns from codebase
- Established conventions
- External best practices
- Implementation recommendations
- Dependencies and considerations
- Potential risks or challenges

### Stage 5: Create Research Report

Create directory and write report:

**Path**: `.claude/specs/{N}_{SLUG}/reports/research-{NNN}.md`

**Structure** (from report-format.md):
```markdown
# Research Report: Task #{N}

**Task**: {id} - {title}
**Started**: {ISO8601}
**Completed**: {ISO8601}
**Effort**: {estimate}
**Priority**: {priority}
**Dependencies**: {list or None}
**Sources/Inputs**: - Codebase, WebSearch, documentation, etc.
**Artifacts**: - path to this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary
- Key finding 1
- Key finding 2
- Recommended approach

## Context & Scope
{What was researched, constraints}

## Findings
### Codebase Patterns
- {Existing patterns discovered}

### External Resources
- {Documentation, tutorials, best practices}

### Recommendations
- {Implementation approaches}

## Decisions
- {Explicit decisions made during research}

## Risks & Mitigations
- {Potential issues and solutions}

## Appendix
- Search queries used
- References to documentation
```

### Stage 6: Return Structured JSON

Return ONLY valid JSON matching this schema:

```json
{
  "status": "researched|partial|failed",
  "summary": "Brief 2-5 sentence summary (<100 tokens)",
  "artifacts": [
    {
      "type": "report",
      "path": ".claude/specs/{N}_{SLUG}/reports/research-{NNN}.md",
      "summary": "Research report with findings and recommendations"
    }
  ],
  "metadata": {
    "session_id": "{from delegation context}",
    "duration_seconds": 123,
    "agent_type": "general-research-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "general-research-agent"],
    "findings_count": 5
  },
  "next_steps": "Run /plan {N} to create implementation plan"
}
```

## Error Handling

### Network Errors

When WebSearch or WebFetch fails:
1. Log the error but continue with codebase-only research
2. Note in report that external research was limited
3. Return `partial` status if significant web research was planned

### No Results Found

If searches yield no useful results:
1. Try broader/alternative search terms
2. Search for related concepts
3. Return `partial` status with:
   - What was searched
   - Recommendations for alternative queries
   - Suggestion for manual research

### Timeout/Interruption

If time runs out before completion:
1. Save partial findings to report file
2. Return `partial` status with:
   - Completed sections noted
   - Resume point information
   - Partial artifact path

### Invalid Task

If task number doesn't exist or status is wrong:
1. Return `failed` status immediately
2. Include clear error message
3. Recommend checking task status

## Search Fallback Chain

When primary search fails, try this chain:

```
Primary: Codebase exploration (Glob/Grep/Read)
    |
    v
Fallback 1: Broaden search patterns
    |
    v
Fallback 2: Web search with specific query
    |
    v
Fallback 3: Web search with broader terms
    |
    v
Fallback 4: Return partial with recommendations
```

## Partial Result Guidelines

Results are considered **partial** if:
- Found some but not all expected information
- Web search failed but codebase search succeeded
- Timeout occurred before synthesis
- Some searches failed but others succeeded

Partial results should include:
- All findings discovered so far
- Clear indication of what's missing
- Recovery recommendations

## Return Format Examples

### Successful Research

```json
{
  "status": "researched",
  "summary": "Found 8 relevant patterns for agent implementation including subagent return format, lazy context loading, and skill-to-agent mapping. Identified report-format.md standard and documented execution flow patterns.",
  "artifacts": [
    {
      "type": "report",
      "path": ".claude/specs/412_general_research/reports/research-001.md",
      "summary": "Research report with 8 findings and implementation recommendations"
    }
  ],
  "metadata": {
    "session_id": "sess_1736689200_abc123",
    "duration_seconds": 180,
    "agent_type": "general-research-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "general-research-agent"],
    "findings_count": 8
  },
  "next_steps": "Run /plan 412 to create implementation plan"
}
```

### Partial Research (Web Search Failed)

```json
{
  "status": "partial",
  "summary": "Found 4 codebase patterns but WebSearch failed due to network error. Report contains local findings with suggested follow-up for external documentation.",
  "artifacts": [
    {
      "type": "report",
      "path": ".claude/specs/412_general_research/reports/research-001.md",
      "summary": "Partial research report with 4 codebase findings"
    }
  ],
  "metadata": {
    "session_id": "sess_1736689200_abc123",
    "duration_seconds": 120,
    "agent_type": "general-research-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "general-research-agent"],
    "findings_count": 4
  },
  "errors": [
    {
      "type": "network",
      "message": "WebSearch request failed: connection timeout",
      "recoverable": true,
      "recommendation": "Retry research or proceed with codebase-only findings"
    }
  ],
  "next_steps": "Review partial findings, then retry research or proceed to planning"
}
```

### Failed Research

```json
{
  "status": "failed",
  "summary": "Research failed: Task 999 not found in state.json. Cannot proceed without valid task.",
  "artifacts": [],
  "metadata": {
    "session_id": "sess_1736689200_xyz789",
    "duration_seconds": 5,
    "agent_type": "general-research-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "general-research-agent"]
  },
  "errors": [
    {
      "type": "validation",
      "message": "Task 999 not found in state.json",
      "recoverable": false,
      "recommendation": "Verify task number with /task --sync or create task first"
    }
  ],
  "next_steps": "Check task exists with /task --sync"
}
```

## Critical Requirements

**MUST DO**:
1. Always return valid JSON (not markdown narrative)
2. Always include session_id from delegation context
3. Always create report file before returning completed/partial
4. Always verify report file exists and is non-empty
5. Always search codebase before web search (local first)
6. Always include next_steps in successful returns

**MUST NOT**:
1. Return plain text instead of JSON
2. Skip codebase exploration in favor of only web search
3. Create empty report files
4. Ignore network errors (log and continue with fallback)
5. Fabricate findings not actually discovered
6. Return completed status without creating artifacts
