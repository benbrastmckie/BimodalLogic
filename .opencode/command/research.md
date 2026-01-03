---
name: research
agent: orchestrator
description: "Conduct research and create reports with [RESEARCHED] status"
context_level: 2
language: markdown
routing:
  language_based: true
  lean: lean-research-agent
  default: researcher
timeout: 3600
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/workflows/status-transitions.md"
    - "core/system/routing-guide.md"
  optional:
    - "project/lean4/tools/leansearch-api.md"
    - "project/lean4/tools/loogle-api.md"
  max_context_size: 50000
---

**Usage:** `/research TASK_NUMBER [PROMPT] [--divide]`

## Description

Conducts research for tasks and creates research reports with [RESEARCHED] status. Supports language-based routing to use appropriate research tools (Lean-specific or general).

## Workflow Setup

**Orchestrator handles (Stage 1-5):**
- **Stage 1 (PreflightValidation):** Parse task number and flags from arguments, validate task exists
- **Stage 2 (DetermineRouting):** Extract language from task entry (state.json or TODO.md), map to agent using routing table, validate routing
- **Stage 3 (RegisterAndDelegate):** Register session and invoke target agent
- **Stage 4 (ValidateReturn):** Validate return format, verify artifacts exist and are non-empty (prevents phantom research)
- **Stage 5 (PostflightCleanup):** Update session registry and relay result to user

**Researcher subagent handles:**
- Research execution (web search, documentation, or Lean-specific tools)
- Topic subdivision (if --divide flag specified)
- Research report creation
- Status updates ([RESEARCHING] → [RESEARCHED])
- Git commits

## Arguments

- `TASK_NUMBER` (required): Task number from TODO.md
- `PROMPT` (optional): Custom research focus or instructions
- `--divide` (optional): Subdivide research into multiple topics

## Examples

```bash
/research 197                              # Research task 197
/research 197 "Focus on CLI integration"   # Research with custom focus
/research 197 --divide                     # Subdivide into topics
```

## Language-Based Routing

| Language | Agent | Tools |
|----------|-------|-------|
| lean | lean-research-agent | LeanExplore, Loogle, LeanSearch, lean-lsp-mcp |
| markdown | researcher | Web search, documentation review |
| python | researcher | Web search, documentation review |
| general | researcher | Web search, documentation review |

**Language Extraction (Orchestrator Stage 2):**
1. Priority 1: Project state.json (task-specific) - `.opencode/specs/{task_number}_*/state.json`
2. Priority 2: TODO.md task entry (**Language** field) - `grep -A 20 "^### {task_number}\."`
3. Priority 3: Default "general" (fallback) - If extraction fails

**Routing Validation (Orchestrator Stage 2):**
- Verify agent file exists at `.opencode/agent/subagents/{agent}.md`
- If language="lean": Agent must start with "lean-" (e.g., lean-research-agent)
- If language!="lean": Agent must NOT start with "lean-" (e.g., researcher)
- Log routing decision: `[INFO] Routing to {agent} (language={language})`

**Artifact Validation (Orchestrator Stage 4):**
- If status="completed": Artifacts array must be non-empty
- All artifact files must exist on disk
- All artifact files must be non-empty (size > 0 bytes)
- Prevents "phantom research" (status updated but no artifacts created)

## Delegation

**Target Agent:** Language-dependent (see routing table above)  
**Timeout:** 3600s (1 hour)  
**Language-Based Routing:** Yes

**Researcher Responsibilities:**
- Execute research using appropriate tools
- Create comprehensive research report
- Update status atomically via status-sync-manager
- Create git commit via git-workflow-manager

## Quality Standards

**Research Report Quality:**
- Comprehensive coverage of topic
- Relevant documentation and references cited
- Clear recommendations for implementation
- Technical details and considerations documented
- NO EMOJI (per documentation.md standards)

**Atomic Updates:**
- TODO.md (status, timestamps, research link)
- state.json (status, timestamps, research_path, research_metadata)

**Lazy Directory Creation:**
- `.opencode/specs/{number}_{slug}/` created when writing first artifact
- `reports/` subdirectory created when writing research-001.md

## Error Handling

**Task Not Found:**
```
Error: Task {task_number} not found in .opencode/specs/TODO.md
Recommendation: Verify task number exists in TODO.md
```

**Invalid Task Number:**
```
Error: Task number must be an integer. Got: {input}
Usage: /research TASK_NUMBER [PROMPT] [--divide]
```

**Language Extraction Failed:**
```
Warning: Language not found for task {task_number}, defaulting to 'general'
Proceeding with researcher agent (web search, documentation)
```

**Research Timeout:**
```
Warning: Research timed out after 3600s
Partial artifacts created: {list}
Resume with: /research {task_number}
```

## Notes

- **Language Routing**: Lean tasks route to lean-research-agent with specialized tools
- **Topic Subdivision**: Use --divide flag to break research into sub-topics
- **Research Tools**: Lean (LeanExplore, Loogle, LeanSearch, lean-lsp-mcp) or General (web search, docs)
- **Atomic Updates**: status-sync-manager ensures consistency across files
- **Git Workflow**: Delegated to git-workflow-manager for standardized commits

For detailed workflow documentation, see:
- `.opencode/context/project/lean4/tools/leansearch-api.md`
- `.opencode/context/project/lean4/tools/loogle-api.md`
- `.opencode/agent/subagents/researcher.md`
- `.opencode/agent/subagents/lean-research-agent.md`
