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
  "status": "completed|partial|failed",
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
