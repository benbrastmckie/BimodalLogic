# Research Report: Task #541

**Task**: 541 - progressive_disclosure_refactor
**Started**: 2026-01-17T16:50:00Z
**Completed**: 2026-01-17T17:30:00Z
**Effort**: 2-3 hours (estimate for refactor)
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**:
- Codebase analysis (.claude/agents/, .claude/skills/, .claude/commands/, .claude/context/)
- Claude Code official documentation (code.claude.com/docs/en/sub-agents)
- Anthropic engineering best practices (anthropic.com/engineering/claude-code-best-practices)
- Recent task research reports (534, 539)
- Web search for 2026 Claude Code patterns
**Artifacts**: specs/541_progressive_disclosure_refactor/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Current architecture is well-designed** and mostly follows 2026 Claude Code best practices with command-skill-agent layering, forked subagent pattern, and lazy context loading
- **Key gap identified**: Skills using custom `agent:` frontmatter field are causing invocation failures - Claude uses `Skill()` instead of `Task()` to invoke agents
- **Claude Code's native subagent model field** (sonnet/opus/haiku/inherit) is fully supported and recently implemented in Task 535-537
- **Progressive disclosure is partially implemented** via `context: fork` pattern but can be improved with clearer isolation boundaries
- **Primary recommendation**: Add explicit Task tool invocation directives to all forked skills to prevent the Skill/Task confusion

## Context & Scope

This research examines the `.claude/` agent system architecture against 2026 Claude Code best practices for:
1. Progressive disclosure and lazy context loading
2. Command-skill-agent pattern implementation
3. Metadata passing and session tracking
4. Model tiering and cost optimization
5. Subagent isolation and context management

## Findings

### 1. Current Architecture Alignment with 2026 Best Practices

**What's Working Well:**

| Pattern | Implementation Status | Assessment |
|---------|----------------------|------------|
| Three-tier hierarchy (command-skill-agent) | Implemented | Good separation of concerns |
| Lazy context loading via `context: fork` | Implemented | Prevents context bloat in parent |
| Standardized return format (subagent-return.md) | Implemented | Enables validation and tracking |
| Session ID tracking | Implemented | Full traceability via `sess_{timestamp}_{random}` |
| Anti-stop patterns | Documented | Contextual status values prevent premature halts |
| Model tiering (sonnet/opus/haiku) | Implemented (Tasks 535-537) | Cost optimization enabled |
| Language-based routing | Implemented | Lean vs general agents |

**Key Architecture Patterns (per 2026 Claude Code docs):**

1. **Skills as "lazy-loaded" instructions** - Claude sees only skill titles until triggered
2. **Subagents for context isolation** - Each gets fresh context window, reports back summary
3. **Built-in Explore agent** uses Haiku for fast read-only operations
4. **Model specification in frontmatter** - `model: sonnet|opus|haiku|inherit`

### 2. Critical Gap: Skill-to-Agent Invocation Pattern

**Problem Identified (from Task 539 research-002.md):**

Skills with `agent:` frontmatter field are causing Claude to use `Skill(agent-name)` instead of `Task(agent-name)`. This is fundamentally incorrect because:
- `Skill()` tool invokes skills from `.claude/skills/`
- `Task()` tool spawns subagents from `.claude/agents/`
- Agents exist in `.claude/agents/`, not `.claude/skills/`

**Root Cause:**

The `agent:` field in skill frontmatter is a **custom convention**, not a native Claude Code field. Claude sees this field and pattern-matches to `Skill()` invocation rather than `Task()`.

**Current Pattern (Problematic):**
```yaml
---
name: skill-researcher
allowed-tools: Task
context: fork
agent: general-research-agent  # Custom field causing confusion
---

### 3. Invoke Subagent
Invoke `general-research-agent` via Task tool with:
- Task context
```

**Claude's Misinterpretation:**
```
Skill(skill-researcher)
   Skill(general-research-agent)  # WRONG - agents aren't skills!
```

**Fix Required:**
Add explicit, bold directive in skill body:
```markdown
### 3. Invoke Subagent

**CRITICAL**: Use the Task tool (NOT Skill tool) to spawn the subagent.

Call Task tool with:
- subagent_type: "general-research-agent"
- prompt: Include task context and focus prompt

DO NOT use Skill() - agents are in .claude/agents/, not .claude/skills/
```

### 3. 2026 Claude Code Subagent Best Practices

**From Official Documentation:**

| Feature | Supported Fields | Notes |
|---------|------------------|-------|
| Model selection | `model: sonnet\|opus\|haiku\|inherit` | Defaults to sonnet if omitted |
| Tool restrictions | `tools:` or `disallowedTools:` | Comma-separated list |
| Permission modes | `permissionMode: default\|acceptEdits\|dontAsk\|bypassPermissions\|plan` | Controls approval prompts |
| Skills injection | `skills:` | Inject skill content (not inherited) |
| Lifecycle hooks | `hooks:` | PreToolUse, PostToolUse, Stop events |

**Context Isolation Principles:**
1. Subagents receive only custom system prompt + basic environment
2. NOT the full Claude Code system prompt
3. Output stays isolated in subagent transcript
4. Summary returned to parent preserves main context

**Built-in Subagent Reference:**
| Name | Model | Tools | Purpose |
|------|-------|-------|---------|
| Explore | haiku | Read-only | Fast codebase search |
| Plan | inherit | Read-only | Research before planning |
| general-purpose | inherit | All | Complex multi-step tasks |

### 4. Progressive Disclosure Patterns

**Current Implementation:**

```
Level 0: CLAUDE.md (~1500 lines)
  - Always loaded into context
  - Contains routing rules, quick reference

Level 1: Commands (~100-200 lines each)
  - Loaded when user invokes /command
  - Contains argument parsing, checkpoint flow

Level 2: Skills (~100-150 lines each)
  - Loaded when command invokes skill
  - Thin wrapper with context: fork

Level 3: Agents (~300-500 lines each)
  - Loaded ONLY in isolated subagent context
  - Full execution logic, domain context references
```

**Token Budget Analysis:**

| Layer | Lines | Est. Tokens | % of 200K |
|-------|-------|-------------|-----------|
| CLAUDE.md | ~1500 | ~6000 | 3% |
| Command (research.md) | ~130 | ~520 | 0.26% |
| Skill (skill-researcher) | ~150 | ~600 | 0.3% |
| Agent (general-research-agent) | ~400 | ~1600 | 0.8% |

**Observation**: Progressive disclosure is working - parent context stays under 5% of window even with command + skill loaded.

### 5. Metadata Passing Patterns

**Session Tracking Flow:**
```
/research 541
  ├── GATE IN: Generate session_id = sess_1768661109_395fa8
  ├── Command: Pass session_id to skill
  ├── Skill: Include in delegation context
  ├── Agent: Include in return metadata
  └── GATE OUT: Verify session_id matches
```

**Delegation Context Schema:**
```json
{
  "session_id": "sess_{timestamp}_{random}",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "research", "skill-researcher"],
  "timeout": 3600,
  "task_context": {
    "task_number": 541,
    "task_name": "progressive_disclosure_refactor",
    "description": "...",
    "language": "meta"
  },
  "focus_prompt": "optional focus"
}
```

### 6. Model Tiering Current State

**From Task 534-538:**

| Agent | Model | Rationale |
|-------|-------|-----------|
| lean-implementation-agent | opus | Complex proof development |
| lean-research-agent | sonnet | Mathlib/theorem search |
| general-research-agent | sonnet | Web + codebase research |
| general-implementation-agent | sonnet | General file operations |
| planner-agent | sonnet | Structured plan creation |
| meta-builder-agent | sonnet | Multi-turn interview |
| latex-implementation-agent | sonnet | Template-based work |

**Note**: Skills cannot have model fields - they execute in main conversation context and inherit that model.

### 7. Alternative Architecture Patterns Considered

**Pattern A: All Context in CLAUDE.md (Not Recommended)**

Some practitioners put all context in CLAUDE.md and let main agent self-orchestrate. This approach:
- Pros: Simpler, no subagent overhead
- Cons: Bloats context window, loses isolation benefits

**Pattern B: Current Forked Subagent Pattern (Recommended)**

Current architecture with thin skills delegating to forked agents:
- Pros: Context isolation, model tiering, clear separation
- Cons: Requires explicit Task tool invocation

**Pattern C: Direct Task Tool from Commands (Partial)**

Skip skills, invoke agents directly from commands:
- Pros: Fewer layers, simpler flow
- Cons: Loses skill reusability, harder to route

**Recommendation**: Continue with Pattern B but fix the Skill/Task invocation issue.

## Recommendations

### Immediate Fixes (High Priority)

1. **Add explicit Task tool invocation directives** to all forked skills:
   - `.claude/skills/skill-researcher/SKILL.md`
   - `.claude/skills/skill-lean-research/SKILL.md`
   - `.claude/skills/skill-planner/SKILL.md`
   - `.claude/skills/skill-implementer/SKILL.md`
   - `.claude/skills/skill-lean-implementation/SKILL.md`
   - `.claude/skills/skill-latex-implementation/SKILL.md`
   - `.claude/skills/skill-meta/SKILL.md`

2. **Pattern to add in each skill:**
   ```markdown
   ### 3. Invoke Subagent

   **CRITICAL**: You MUST use the Task tool (NOT Skill tool) to invoke the subagent.

   The `agent` field in frontmatter specifies the subagent_type for the Task tool.

   Call Task tool with:
   - subagent_type: "{agent-name-from-frontmatter}"
   - prompt: "Task {N}: {description}\n\nFocus: {focus_prompt}\n\nSession: {session_id}"

   WARNING: Do NOT use Skill() for agents - agents are in .claude/agents/, not .claude/skills/
   ```

### Architecture Improvements (Medium Priority)

3. **Consider removing `agent:` frontmatter field** - it's non-standard and causes confusion. Specify agent name in instruction body instead.

4. **Add model field validation** - Create a pre-commit hook to verify all agents have explicit `model:` fields.

5. **Document the Skill vs Task distinction** in `.claude/docs/guides/`:
   ```markdown
   | Directory | Tool | Usage |
   |-----------|------|-------|
   | .claude/skills/ | Skill tool | Invoke skills |
   | .claude/agents/ | Task tool | Spawn subagents |
   | .claude/commands/ | Direct | User-invoked via /command |
   ```

### Progressive Disclosure Enhancements (Lower Priority)

6. **Create context budget dashboard** - Track token usage per layer.

7. **Consolidate context files further** - Current consolidation (Task 246) achieved 72% reduction. Consider further consolidation of standards/ files.

8. **Add context caching hints** - Document which context files are frequently loaded together.

## Decisions

1. **Keep forked subagent pattern** - Token efficiency benefits outweigh complexity costs
2. **Keep custom `agent:` field but add explicit directives** - Removing field would require significant refactor
3. **Model tiering is correctly implemented** - No changes needed to agent model assignments
4. **Session tracking is comprehensive** - No changes needed

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Skills still calling Skill() after fix | High | Medium | Add validation in GATE OUT |
| Old sessions have cached bad context | Medium | High | Document: start fresh sessions |
| Haiku agents fail with tool_reference bug | Medium | Medium | Test thoroughly, limit tool count |
| CLAUDE.md grows too large | Low | Low | Regular context budget reviews |

## Appendix

### Sources

- [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Context Engineering from Claude](https://01.me/en/2025/12/context-engineering-from-claude/)
- [Subagents Best Practices Guide](https://www.pubnub.com/blog/best-practices-for-claude-code-sub-agents/)

### Codebase Files Analyzed

- `.claude/CLAUDE.md` - Main configuration
- `.claude/ARCHITECTURE.md` - System architecture
- `.claude/agents/*.md` - 7 agent files
- `.claude/skills/*/SKILL.md` - 10 skill files
- `.claude/commands/*.md` - 9 command files
- `.claude/context/index.md` - Context discovery index
- `.claude/context/core/formats/subagent-return.md` - Return format
- `.claude/context/core/patterns/anti-stop-patterns.md` - Anti-stop patterns
- `.claude/context/core/patterns/skill-lifecycle.md` - Skill lifecycle
- `.claude/context/core/patterns/inline-status-update.md` - Status update patterns
- `.claude/context/core/templates/thin-wrapper-skill.md` - Skill template
- `specs/534_*/reports/research-001.md` - Model selection research
- `specs/539_*/reports/research-002.md` - Workflow failure diagnosis

### Web Search Queries Used

1. "Claude Code 2026 best practices context management lazy loading subagents"
2. Official documentation fetch from code.claude.com/docs/en/sub-agents
3. Official documentation fetch from anthropic.com/engineering/claude-code-best-practices

### Related Tasks

- Task 534: Research Claude Code model selection mechanisms
- Task 535: Refactor heavy-lifting agents to use Sonnet
- Task 536: Refactor dispatch skills to use Haiku
- Task 537: Identify Opus-only components
- Task 538: Update model tier documentation
- Task 539: Test and validate model tiering
- Task 529: Unify workflow commands (single-execution pattern)
- Task 530: Add continuation guards to commands
