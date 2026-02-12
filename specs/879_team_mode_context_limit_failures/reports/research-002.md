# Research Report: Task #879 (Supplementary)

**Task**: 879 - Investigate and fix team mode context limit failures
**Date**: 2026-02-12
**Focus**: Artifact-based handoff patterns for graceful context exhaustion
**Supplements**: research-001.md (initial diagnosis)

## Summary

This supplementary research focuses on how agents can "pass the torch" when running low on context, rather than preventing context exhaustion (which is inevitable for complex work). Key findings include industry patterns for incremental progress files, artifact-based state passing, and minimal context loading for successor agents.

## Findings

### 1. Industry Patterns for Context Exhaustion Handoff

#### Anthropic's Incremental Progress Pattern

From [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents):

**Core principle**: Treat agents like shift-working engineers. Each session should:
1. Start oriented (not confused)
2. Make incremental progress
3. Leave clear artifacts for the next session

**Essential handoff artifacts**:
- `claude-progress.txt` - Log of what agents have accomplished
- `feature_list.json` - Structured list of work items with pass/fail status
- `init.sh` - Environment setup script for quick start

**Minimal successor requirements** (three-step pattern):
1. Run `pwd` to see working directory
2. Read git logs and progress files to get up to speed
3. Read features list and choose highest-priority item

**Key insight**: Git history serves as architectural memory alongside progress notes.

#### LangChain Deep Agents Context Management

From [Context Management for Deep Agents](https://blog.langchain.com/context-management-for-deepagents/):

**Compression techniques**:
1. **Offload large tool results** (>20k tokens) to filesystem with path references + 10-line preview
2. **Offload large tool inputs** at 85% context capacity, replacing with disk pointers
3. **Summarization** - structured summary preserving session intent, artifacts created, and next steps

**Preserve vs. discard decision**:
- **Preserve**: Session intent, artifact paths, next steps, critical facts for task completion
- **Discard**: Redundant tool call content already on disk, stale information

#### Google ADK Artifact Pattern

From [Google Developers Blog](https://developers.googleblog.com/architecting-efficient-context-aware-multi-agent-framework-for-production/):

**Artifact-first approach**:
- Large data lives in `ArtifactService` as named, versioned objects
- Agents see only lightweight references by default
- `LoadArtifactsTool` enables on-demand access
- Content unloaded after task completion

**Minimal context by default**: "Every model call and sub-agent sees the minimum context required."

### 2. Session Handoff Skills (Claude Code Ecosystem)

From [session-handoff skill](https://skills.sh/softaworks/agent-toolkit/session-handoff) and [Handoff Skill documentation](https://agent-skills.md/skills/galihcitta/dotclaudeskills/creating-handoffs):

**Handoff document structure** (prioritized sections):
1. **Current State Summary** - Present work status
2. **Important Context** - Critical information successor must know
3. **Immediate Next Steps** - Clear, actionable first actions
4. **Decisions Made** - Choices with rationale (not just outcomes)

**Additional sections**:
- Critical Files (important locations)
- Key Patterns Discovered (conventions to follow)
- Potential Gotchas (known issues to avoid)
- Pending Work items

**Validation requirements**:
- No `[TODO: ...]` placeholders left unfilled
- Required sections populated
- No secrets (API keys, passwords, tokens)
- Referenced files exist
- Quality score >= 70

**Staleness assessment** for successor agents:
- FRESH, SLIGHTLY_STALE, STALE, VERY_STALE categories
- Based on: commits since creation, branch divergence, missing referenced files

### 3. Existing Codebase Patterns

**Current partial_progress schema** (from return-metadata-file.md):
```json
{
  "partial_progress": {
    "stage": "phase_2_in_progress",
    "details": "Phase 1 completed. Phase 2 in progress: implementing core definitions.",
    "phases_completed": 1,
    "phases_total": 4
  }
}
```

**Limitation identified**: Current `partial_progress` is designed for skill postflight recovery, not for successor agent context loading. It lacks:
- What decisions were made and why
- What approaches were tried and failed
- What the immediate next action should be
- What files are in what state

**Team wave helpers** (from team-wave-helpers.md):
- Teammates output to separate files: `specs/{N}_{SLUG}/reports/teammate-{letter}-findings.md`
- Phase results: `specs/{N}_{SLUG}/phases/phase-{P}-results.md`
- Lead synthesizes from these files

### 4. Multi-Agent Handoff Best Practices

From [Claude Code Swarms](https://addyosmani.com/blog/claude-code-agent-teams/) and [Multi-Agent Orchestration](https://gist.github.com/kieranklaassen/4f2aba89594a4aea4ad64d753984b2ea):

**When to trigger handoff**:
- Context window approaches capacity
- Major task milestones completed
- Work session ends (natural boundary)

**Handoff chaining for long projects**:
- Handoffs chain sequentially with predecessor links
- New agents read most recent handoff first
- Reference predecessors as needed

**Context-centric decomposition**:
- Divide work by context boundaries
- Agent handling a feature also handles its tests
- Split only when context can be truly isolated

## Recommendations

### Recommendation 1: Introduce Handoff Artifact Schema

Create a new artifact type `handoff` for team members approaching context exhaustion:

```json
{
  "type": "handoff",
  "path": "specs/{N}_{SLUG}/handoffs/phase-{P}-handoff-{timestamp}.md",
  "schema": {
    "current_state": "What's done, what's in progress",
    "immediate_next_action": "Single, specific next step",
    "decisions_made": "Key choices with rationale",
    "approaches_tried": "What didn't work and why (avoid retry)",
    "critical_files": "Files that matter, their state",
    "gotchas": "Known issues to avoid"
  }
}
```

**Why markdown, not JSON**: Easier for agents to generate and read naturally. JSON is for machine parsing by skills; markdown is for agent context loading.

### Recommendation 2: Minimal Context Loading Pattern

Successor agents should NOT read:
- All prior research reports
- Full implementation plans
- Previous agent outputs

Instead, provide a **handoff index file** with:
```markdown
# Handoff Index: Task {N} Phase {P}

## Quick Start (read this first)
- Immediate next action: {specific action}
- Critical file: {path} at line {N}
- Current goal state: {proof goal or expected output}

## If You Get Stuck
- Read: {path to relevant section of plan}
- Key lemma: {name} (verified exists)
- Approach hint: {one-liner}

## Do NOT
- Re-read {large file} (already processed)
- Try {approach} (failed, see handoff for why)
```

This "progressive disclosure" pattern keeps initial context minimal while providing escape hatches.

### Recommendation 3: Teammate Context Exhaustion Protocol

When a teammate detects approaching context limit:

1. **Write handoff artifact** to designated path
2. **Update phase result file** with partial progress marker
3. **Return `partial` status** with `handoff_path` in metadata

```json
{
  "status": "partial",
  "partial_progress": {
    "stage": "context_exhaustion_handoff",
    "details": "Approaching context limit at ~85%. Handoff written.",
    "handoff_path": "specs/{N}_{SLUG}/handoffs/phase-{P}-handoff-{timestamp}.md"
  },
  "errors": [{
    "type": "context_exhaustion",
    "recoverable": true,
    "recommendation": "Spawn successor with handoff file"
  }]
}
```

### Recommendation 4: Wave Continuation Pattern

When a teammate exhausts context mid-phase:

**Option A: Successor teammate** (recommended for complex phases)
- Lead spawns new teammate with handoff file as primary context
- New teammate reads handoff index, NOT full history
- Continues from `immediate_next_action`

**Option B: Lead continuation** (for simpler remaining work)
- Lead reads handoff artifact
- Lead completes remaining work directly
- Avoids spawn overhead for small completions

### Recommendation 5: Incremental Progress File Pattern

Adapt Anthropic's `claude-progress.txt` pattern for team phases:

`specs/{N}_{SLUG}/progress/phase-{P}-progress.json`:
```json
{
  "phase": 3,
  "phase_name": "GH-controlled Lindenbaum",
  "started_at": "2026-02-12T10:30:00Z",
  "last_updated": "2026-02-12T11:45:00Z",
  "objectives": [
    {"id": 1, "description": "Define GHControlledState", "status": "done"},
    {"id": 2, "description": "Prove consistency lemma", "status": "in_progress", "note": "3 of 5 cases done"},
    {"id": 3, "description": "Prove extension theorem", "status": "not_started"}
  ],
  "current_objective": 2,
  "approaches_tried": [
    {"approach": "Direct induction on formula", "result": "failed - need structural approach"}
  ],
  "handoff_count": 0
}
```

**Key properties**:
- Machine-readable (JSON) for tracking
- Immutable objective descriptions (never edit/remove)
- Status updates only change `status` field
- `approaches_tried` prevents repeating failures

### Recommendation 6: Context Compression Guidelines for Teammates

Add to teammate prompt template:

```
## Context Efficiency
- Offload large tool outputs to files, keep references in context
- When lean_goal returns large proof state, save to scratch file
- Prefer targeted file reads (line ranges) over full reads
- At 80% context estimate, proactively write handoff

## Handoff Triggers
- Before any operation that might push over limit
- After completing any objective (natural boundary)
- When you find yourself re-reading the same context
```

## Concrete Implementation Suggestions

### Change 1: Add handoff_path to partial_progress schema

In `.claude/context/core/formats/return-metadata-file.md`:

```json
{
  "partial_progress": {
    "stage": "string",
    "details": "string",
    "phases_completed": "number (optional)",
    "phases_total": "number (optional)",
    "handoff_path": "string (optional) - path to handoff artifact for successor"
  }
}
```

### Change 2: Add handoff template to team-wave-helpers.md

```markdown
### Handoff Document Template

When approaching context exhaustion, write to `specs/{N}_{SLUG}/handoffs/`:

```markdown
# Phase {P} Handoff - {timestamp}

## Immediate Next Action
{Single specific step, not a list}

## Current State
- File: {path}
- Location: Line {N}, after {tactic/statement}
- Goal state: {current proof goal or expected output}

## Key Decisions Made
1. {Decision}: {Rationale}

## What NOT to Try
1. {Approach}: {Why it failed}

## Critical Context
- {One essential fact}
- {Another essential fact}
- (Max 5 items)

## References (read only if stuck)
- Plan: specs/{N}_{SLUG}/plans/implementation-{NNN}.md, Phase {P}
- Research: specs/{N}_{SLUG}/reports/research-{NNN}.md, Section {X}
```
```

### Change 3: Update teammate prompt for context awareness

Add to Lean teammate prompts in team-wave-helpers.md:

```
## Context Management
You have a finite context window. Plan for exhaustion, not against it.

1. Track progress in `specs/{N}_{SLUG}/progress/phase-{P}-progress.json`
2. Update after each objective completion
3. At ~80% context usage (estimate based on tool calls), write handoff
4. Handoff location: `specs/{N}_{SLUG}/handoffs/phase-{P}-handoff-{timestamp}.md`
5. Return partial status with handoff_path
```

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Handoff overhead slows progress | Medium | Keep handoff minimal (one-screen max) |
| Successor misinterprets handoff | Medium | Structured template with validation |
| Too many handoffs (thrashing) | Low | Set minimum work before handoff allowed |
| Handoff file bloat over time | Low | Archive completed handoffs |

## Summary of Key Patterns

1. **Three-artifact pattern** (Anthropic): progress log, work item list, environment script
2. **Progressive disclosure**: minimal starting context, expand on demand
3. **Offload-and-reference**: large data lives in files, context holds paths + previews
4. **Structured handoff**: prioritized sections (state, next action, decisions, gotchas)
5. **Machine-readable progress**: JSON for tracking, markdown for context

## References

- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) - Anthropic
- [Context Management for Deep Agents](https://blog.langchain.com/context-management-for-deepagents/) - LangChain
- [Google ADK Multi-Agent Framework](https://developers.googleblog.com/architecting-efficient-context-aware-multi-agent-framework-for-production/) - Google
- [Session-Handoff Skill](https://skills.sh/softaworks/agent-toolkit/session-handoff) - Agent Toolkit
- [Handoff Skill Documentation](https://agent-skills.md/skills/galihcitta/dotclaudeskills/creating-handoffs) - Agent Skills
- [Claude Code Swarms](https://addyosmani.com/blog/claude-code-agent-teams/) - Addy Osmani
- [Claude Code Multi-Agent Orchestration](https://gist.github.com/kieranklaassen/d2b35569be2c7f1412c64861a219d51f) - GitHub Gist
- [When to use multi-agent systems](https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them) - Anthropic

## Next Steps

1. Implement handoff artifact schema in return-metadata-file.md
2. Add handoff template to team-wave-helpers.md
3. Update Lean teammate prompts with context awareness guidance
4. Create progress file template for phase tracking
5. Test with a controlled context-heavy phase
