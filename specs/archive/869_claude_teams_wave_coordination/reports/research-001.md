# Research Report: Task #869

**Task**: 869 - claude_teams_wave_coordination
**Started**: 2026-02-11T12:00:00Z
**Completed**: 2026-02-11T12:45:00Z
**Effort**: Medium (3-4 hours for implementation)
**Dependencies**: None (builds on existing skill/agent architecture)
**Sources/Inputs**: Codebase exploration, Claude Code documentation, web search for multi-agent patterns
**Artifacts**: specs/869_claude_teams_wave_coordination/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- Claude Code Agent Teams feature (Feb 2026) provides native multi-agent coordination with shared task lists, inter-agent messaging, and automatic teammate lifecycle management
- Current .claude/ architecture uses a three-layer delegation pattern (Command -> Skill -> Agent) that can be extended to support wave-based team coordination
- Wave-based parallelization (1-4 agents per wave) aligns with best practices: cap concurrency at 4-6, start synthesis early, use lightweight reviewers
- Recommended approach: Implement `--team` flag on existing commands rather than new commands, enabling incremental adoption
- Key technical requirements: TeammateTool integration, wave orchestration logic, result aggregation patterns, debug/ report generation

---

## Context & Scope

### Research Questions

1. What are Claude Teams best practices as of February 2026?
2. How should wave-based multi-agent coordination be orchestrated?
3. What patterns exist for subagent communication and context-sharing?
4. How should agent results be aggregated and distilled?
5. What error handling patterns support graceful degradation in multi-agent systems?

### Constraints

- Must integrate with existing skill/agent architecture (no breaking changes)
- Must preserve existing single-agent workflow as default behavior
- Must support incremental adoption (--team flag optional)
- Must handle partial failures gracefully
- Token efficiency: teams use ~5x more tokens than single sessions

---

## Findings

### 1. Claude Code Agent Teams Feature (February 2026)

**Source**: [Claude Code Agent Teams Documentation](https://code.claude.com/docs/en/agent-teams)

Claude Code's Agent Teams feature is experimental but provides the core infrastructure for multi-agent coordination:

#### Architecture Components

| Component | Role |
|-----------|------|
| **Team Lead** | Main Claude Code session that creates team, spawns teammates, coordinates work |
| **Teammates** | Separate Claude Code instances working on assigned tasks |
| **Task List** | Shared list of work items that teammates claim and complete |
| **Mailbox** | Messaging system for inter-agent communication |

#### Key Capabilities

- **Teammate spawning**: Lead can spawn 1-N teammates with specific prompts and models
- **Task assignment**: Shared task list with claim-based coordination
- **Inter-agent messaging**: Direct teammate-to-teammate communication
- **Idle notifications**: Teammates notify lead when finished
- **Plan approval**: Lead can require plan approval before implementation
- **Delegate mode**: Restricts lead to coordination-only tools

#### Configuration

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

#### Limitations

- No session resumption with in-process teammates
- Task status can lag (teammates may not mark tasks complete)
- Shutdown can be slow (teammates finish current operations)
- One team per session
- No nested teams (teammates cannot spawn their own teams)
- ~5x token usage vs single session

### 2. Subagent vs Agent Teams Comparison

**Source**: [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)

| Aspect | Subagents (Current) | Agent Teams (Proposed) |
|--------|---------------------|------------------------|
| **Context** | Own context window; results return to caller | Own context window; fully independent |
| **Communication** | Report results back to main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only result matters | Complex work requiring discussion |
| **Token cost** | Lower (summarized back to main) | Higher (each is separate instance) |

**Decision**: For wave-based coordination, Agent Teams provides the right abstraction - we need inter-agent communication for hypothesis challenging and result synthesis.

### 3. Wave-Based Parallelization Best Practices

**Source**: [Anthropic - Building Effective Agents](https://www.anthropic.com/research/building-effective-agents), [Multi-Agent Parallel Execution](https://skywork.ai/blog/agent/multi-agent-parallel-execution/)

#### Core Principles

1. **Sectioning**: Break tasks into independent parallel subtasks
2. **Voting**: Run same task multiple times for diverse outputs and higher confidence
3. **Concurrency cap**: 4-6 parallel tasks per wave (diminishing returns beyond)
4. **Early synthesis**: Start aggregation as first results arrive (15-24% latency reduction)
5. **Lightweight reviewers**: Small model handles 80% of QA, escalate tricky conflicts

#### Wave Orchestration Pattern

```
Wave 1: Parallel Research (1-4 agents)
    ├── Agent A: Angle 1
    ├── Agent B: Angle 2
    ├── Agent C: Angle 3
    └── Agent D: Devil's advocate
         │
         ▼
    Synthesis: Distill findings
         │
         ▼
Wave 2: Resolution/Deep-dive (1-4 agents)
    ├── Agent E: Investigate gap 1
    └── Agent F: Investigate gap 2
         │
         ▼
    Final Synthesis
```

### 4. Existing Architecture Analysis

**Source**: Codebase exploration (.claude/skills/, .claude/agents/, .claude/context/)

#### Current Three-Layer Pattern

```
Layer 1: Commands (/research, /plan, /implement)
         │
         ▼
Layer 2: Skills (skill-researcher, skill-planner, skill-implementer)
         │
         ▼
Layer 3: Agents (general-research-agent, planner-agent, general-implementation-agent)
```

#### Skill Pattern A: Delegating with Internal Postflight

The existing pattern supports subagent delegation via Task tool with 11-stage execution:

```
Stage 1:  Input Validation
Stage 2:  Preflight Status Update      [RESEARCHING]
Stage 3:  Create Postflight Marker
Stage 4:  Prepare Delegation Context
Stage 5:  Invoke Subagent (Task tool)  <-- Extend for team coordination
Stage 6:  Parse Subagent Return
Stage 7:  Update Task Status           [RESEARCHED]
Stage 8:  Link Artifacts
Stage 9:  Git Commit
Stage 10: Cleanup
Stage 11: Return Brief Summary
```

#### Extension Points

1. **Stage 4**: Prepare team delegation context instead of single-agent context
2. **Stage 5**: Spawn team instead of single subagent
3. **Stage 6**: Aggregate results from multiple teammates
4. **New**: Wave orchestration between Stages 5-6

### 5. Proposed Wave Coordination Design

#### Design Decision: --team Flag vs New Commands

**Analysis**:

| Approach | Pros | Cons |
|----------|------|------|
| **New commands** (`/team-research`, etc.) | Clear separation, no behavior change to existing | Namespace proliferation, duplicate logic |
| **--team flag** (`/research 123 --team`) | Single entry point, incremental adoption, code reuse | Flag parsing complexity, potential confusion |

**Recommendation**: Use `--team` flag on existing commands. This enables:
- Gradual adoption without breaking existing workflows
- Single documentation location
- Shared validation and routing logic
- Optional `--team-size N` for wave sizing

#### Research Phase (team-research)

```
/research 123 --team

Team Lead: Orchestrates research
    │
    ▼
Wave 1 Research (spawn 2-4 teammates):
    ├── Teammate A: Primary angle research
    ├── Teammate B: Alternative approaches
    ├── Teammate C: Risk/blocker analysis
    └── Teammate D: Devil's advocate
    │
    ▼
Synthesis: Lead distills findings into unified report
    │
    ▼
[Optional] Wave 2: Deep-dive on gaps
    │
    ▼
Final Report: specs/{N}_{SLUG}/reports/research-001.md
```

**Teammate Prompts**:
```
Teammate A: "Research {task} focusing on implementation approaches. Challenge assumptions."
Teammate B: "Research {task} focusing on alternative patterns and prior art."
Teammate C: "Research {task} focusing on risks, blockers, and edge cases."
Teammate D: "Challenge findings from other teammates. Identify gaps and inconsistencies."
```

#### Planning Phase (team-plan)

```
/plan 123 --team

Team Lead: Orchestrates planning
    │
    ▼
Wave 1 Planning (spawn 2-3 teammates):
    ├── Teammate A: Plan version A (phased approach)
    ├── Teammate B: Plan version B (alternative structure)
    └── Teammate C: Risk analysis + dependency mapping
    │
    ▼
Trade-off Analysis: Lead compares plans
    │
    ▼
Synthesis: Best-of-breed final plan
    │
    ▼
Final Plan: specs/{N}_{SLUG}/plans/implementation-001.md
```

#### Implementation Phase (team-implement)

```
/implement 123 --team

Team Lead: Orchestrates implementation
    │
    ▼
Wave 1 Implementation (spawn 1-3 teammates per phase):
    ├── Implementer A: Phase N work
    ├── Implementer B: Parallel phase work (if independent)
    └── Debugger: Monitor and debug
    │
    ▼
[On error] Debug Wave:
    ├── Debugger: Analyze failure
    └── Fixer: Apply fix
    │
    ▼
Progress Report: Write debug/ reports on each cycle
    │
    ▼
Final Summary: specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md
```

**Debug Reports**:
```
specs/{N}_{SLUG}/debug/
├── debug-001-hypothesis.md    # Initial hypothesis
├── debug-001-analysis.md      # Analysis results
├── debug-001-resolution.md    # How resolved
└── debug-002-hypothesis.md    # Next cycle (if needed)
```

### 6. Result Aggregation Patterns

**Source**: [AI Agent Orchestration Guide](https://fast.io/resources/ai-agent-orchestration/), [Agyn Multi-Agent System](https://arxiv.org/html/2602.01465)

#### Aggregation Strategies

1. **Lead-as-synthesizer**: Lead reads all results, produces unified output
2. **Hierarchical synthesis**: Sub-leads summarize, lead synthesizes sub-summaries
3. **Voting/consensus**: Multiple agents vote on best approach

**Recommended for ProofChecker**: Lead-as-synthesizer for simplicity. Lead has full context and can make judgment calls on conflicting findings.

#### Distillation Protocol

```json
{
  "teammate_results": [
    {
      "teammate": "Angle A",
      "findings": [...],
      "confidence": "high|medium|low",
      "conflicts_with": ["Angle B finding 3"]
    }
  ],
  "synthesized_result": {
    "key_findings": [...],
    "conflicts_resolved": [...],
    "gaps_identified": [...],
    "recommendation": "..."
  }
}
```

### 7. Error Handling and Graceful Degradation

**Source**: Existing error-handling.md, multi-agent best practices

#### Failure Modes

| Failure | Detection | Recovery |
|---------|-----------|----------|
| Teammate timeout | No response after deadline | Continue with available results, note gap |
| Teammate error | Error status in return | Log error, spawn replacement or continue |
| Partial completion | `status: partial` | Save partial work, mark team task partial |
| Lead failure | No synthesis produced | Preserve raw teammate results |
| Team creation failure | Spawn fails | Fall back to single-agent mode |

#### Graceful Degradation

```
Team mode requested but fails:
    │
    ├── Log warning: "Team mode failed, falling back to single agent"
    ├── Execute standard single-agent workflow
    └── Include note in report: "Executed in single-agent mode (team mode unavailable)"
```

### 8. Technical Requirements

#### Environment Configuration

```json
// settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "teammateMode": "in-process"  // or "tmux" for split panes
}
```

#### New Skill Pattern: Team Delegation

```yaml
---
name: skill-team-research
description: Orchestrate team-based research with wave coordination
allowed-tools: Task, Bash, Edit, Read, Write, TeammateTool
---
```

**Note**: TeammateTool provides teammate spawning, messaging, and task list management.

#### Metadata Extensions

```json
// .return-meta.json extension for team results
{
  "status": "researched",
  "team_execution": {
    "wave_count": 2,
    "teammates_spawned": 4,
    "teammates_completed": 4,
    "token_usage_estimate": "~5x baseline"
  },
  "teammate_results": [
    {
      "name": "Angle A",
      "status": "completed",
      "artifact_path": "specs/{N}_{SLUG}/reports/teammate-a-findings.md"
    }
  ],
  "synthesis": {
    "conflicts_resolved": 2,
    "gaps_identified": 1
  }
}
```

---

## Decisions

1. **Use --team flag** on existing commands rather than new commands
2. **Wave size**: Default 2-4 teammates per wave (configurable with --team-size)
3. **Display mode**: Use in-process by default (works in all terminals)
4. **Synthesis approach**: Lead-as-synthesizer (simplest, maintains context)
5. **Fallback behavior**: Graceful degradation to single-agent on team failure
6. **Debug reports**: Generate debug/ directory for implementation debugging cycles

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Token cost explosion | High | Medium | Warn user before team execution, provide cost estimate |
| Teammate coordination lag | Medium | Low | Set reasonable timeouts, aggressive claim-based tasking |
| Feature instability (experimental) | Medium | Medium | Implement fallback to single-agent mode |
| Result conflicts | Medium | Low | Lead synthesis with conflict logging |
| Session resumption issues | Medium | Medium | Save team state to metadata for manual recovery |

---

## Implementation Approach

### Phase 1: Infrastructure (2-3 hours)

1. Enable Agent Teams feature via settings.json
2. Create skill-team-orchestrator base pattern
3. Implement wave management utilities
4. Add --team flag parsing to command routing

### Phase 2: Research Integration (1-2 hours)

1. Create team-research-skill extending existing pattern
2. Implement teammate prompt generation
3. Add result synthesis logic
4. Generate combined research report

### Phase 3: Planning/Implementation Integration (2-3 hours)

1. Apply pattern to /plan command
2. Apply pattern to /implement command
3. Implement debug/ report generation
4. Add error recovery and fallback

### Phase 4: Testing & Documentation (1-2 hours)

1. Test team mode on representative tasks
2. Document --team flag usage
3. Add team-specific error handling to errors.json
4. Update CLAUDE.md with team command options

---

## Appendix

### Search Queries Used

1. "Claude Teams multi-agent coordination documentation 2026"
2. "Claude Code subagent orchestration parallel execution patterns"
3. "AI agent wave-based parallelization best practices 2026"
4. "multi-agent debugging pivot patterns software development 2026"
5. "agent teams wave coordination result aggregation AI engineering"

### Key Documentation References

- [Claude Code Agent Teams](https://code.claude.com/docs/en/agent-teams)
- [Claude Code Subagents](https://code.claude.com/docs/en/sub-agents)
- [Anthropic - Building Effective Agents](https://www.anthropic.com/research/building-effective-agents)
- [Multi-Agent Parallel Execution](https://skywork.ai/blog/agent/multi-agent-parallel-execution/)
- [Google Multi-Agent Design Patterns](https://www.infoq.com/news/2026/01/multi-agent-design-patterns/)
- [AI Agent Orchestration Guide 2026](https://fast.io/resources/ai-agent-orchestration/)

### Codebase Files Examined

- `.claude/skills/skill-researcher/SKILL.md` - Current skill pattern
- `.claude/skills/skill-implementer/SKILL.md` - Implementation skill pattern
- `.claude/skills/skill-planner/SKILL.md` - Planning skill pattern
- `.claude/agents/general-research-agent.md` - Agent structure
- `.claude/agents/lean-implementation-agent.md` - Implementation agent
- `.claude/context/core/architecture/system-overview.md` - Architecture reference
- `.claude/context/core/orchestration/delegation.md` - Delegation patterns
- `.claude/context/core/formats/return-metadata-file.md` - Return format schema
