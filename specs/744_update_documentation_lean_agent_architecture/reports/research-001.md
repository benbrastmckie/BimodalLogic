# Research Report: Task #744

**Task**: 744 - update_documentation_lean_agent_architecture
**Started**: 2026-01-29T12:00:00Z
**Completed**: 2026-01-29T12:15:00Z
**Effort**: small
**Priority**: medium
**Dependencies**: None
**Sources/Inputs**: Codebase exploration, grep searches
**Artifacts**: specs/744_update_documentation_lean_agent_architecture/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The Lean skills (skill-lean-research, skill-lean-implementation) currently use the thin wrapper delegation pattern, routing to lean-research-agent and lean-implementation-agent
- CLAUDE.md skill-to-agent mapping table is already correct (shows skill-lean-research -> lean-research-agent)
- Multiple context files contain outdated documentation claiming "direct execution" for Lean skills
- The blocked-mcp-tools.md incorrectly refers to agent files as "deprecated"
- README.md contains a "Direct Execution Migration" section that is now outdated

## Context & Scope

This task addresses documentation inconsistencies following the restoration of the Lean agent delegation pattern. The Lean skills were temporarily refactored to direct execution due to MCP bugs, but have since been restored to the thin wrapper delegation pattern.

### Current State

**Active Agent Files**:
- `/home/benjamin/Projects/ProofChecker/.claude/agents/lean-research-agent.md` - Active, working
- `/home/benjamin/Projects/ProofChecker/.claude/agents/lean-implementation-agent.md` - Active, working

**Archived Files**:
- `/home/benjamin/Projects/ProofChecker/.claude/agents/archive/lean-research-agent.md.bak`
- `/home/benjamin/Projects/ProofChecker/.claude/agents/archive/lean-implementation-agent.md.bak`

**Skill Configuration**:
- skill-lean-research: Uses `allowed-tools: Task, Bash, Edit, Read, Write` and delegates to lean-research-agent
- skill-lean-implementation: Uses `allowed-tools: Task, Bash, Edit, Read, Write` and delegates to lean-implementation-agent

## Findings

### Finding 1: CLAUDE.md Skill-to-Agent Mapping (Lines 142-157)

**Location**: `/home/benjamin/Projects/ProofChecker/.claude/CLAUDE.md` (lines 142-157)

**Current Content** (CORRECT):
```markdown
| skill-lean-research | lean-research-agent | Lean 4/Mathlib research |
| skill-lean-implementation | lean-implementation-agent | Lean proof implementation |
```

**Status**: No changes needed - table already shows correct agent mapping.

---

### Finding 2: blocked-mcp-tools.md Deprecated Agent References (Lines 64-65)

**Location**: `/home/benjamin/Projects/ProofChecker/.claude/context/core/patterns/blocked-mcp-tools.md` (lines 64-65)

**Current Content** (INCORRECT):
```markdown
- `.claude/agents/lean-research-agent.md` - Deprecated agent with blocked tools warning
- `.claude/agents/lean-implementation-agent.md` - Deprecated agent with blocked tools warning
```

**Recommended Change**:
```markdown
- `.claude/agents/lean-research-agent.md` - Agent with blocked tools warning
- `.claude/agents/lean-implementation-agent.md` - Agent with blocked tools warning
```

---

### Finding 3: README.md Direct Execution Migration Section (Lines 1056-1058)

**Location**: `/home/benjamin/Projects/ProofChecker/.claude/README.md` (lines 1056-1058)

**Current Content** (OUTDATED):
```markdown
### Direct Execution Migration

Due to additional MCP bugs (#15945, #13254, #4580) causing indefinite hanging in subagents, the Lean skills (`skill-lean-research`, `skill-lean-implementation`) were refactored from the thin wrapper delegation pattern to direct execution. MCP tools now execute directly in the skill rather than in a delegated subagent, eliminating the hanging issue.
```

**Recommended Change**:
Replace with:
```markdown
### Lean Agent Delegation Restoration (January 2026)

The Lean skills (`skill-lean-research`, `skill-lean-implementation`) were temporarily refactored to direct execution due to MCP bugs (#15945, #13254, #4580) causing indefinite hanging. These issues have been resolved, and the skills now use the standard thin wrapper delegation pattern, routing to `lean-research-agent` and `lean-implementation-agent` respectively.
```

---

### Finding 4: thin-wrapper-skill.md Lean Skills Exception (Lines 165-177)

**Location**: `/home/benjamin/Projects/ProofChecker/.claude/context/core/patterns/thin-wrapper-skill.md` (lines 165-177)

**Current Content** (OUTDATED):
```markdown
### Lean Skills Exception

The Lean skills (`skill-lean-research`, `skill-lean-implementation`) were originally thin wrappers
delegating to `lean-research-agent` and `lean-implementation-agent`. They were refactored to
direct execution in January 2026 to fix MCP tool hanging issues.

**Why**: MCP tool calls in subagents hang indefinitely with no timeout mechanism. Since Lean
skills require heavy MCP tool usage (lean_goal, lean_leansearch, lean_loogle, etc.), direct
execution is required.

**How**: The agent logic was inlined into the skill, and MCP tools were added to the
`allowed-tools` frontmatter. The deprecated agent files are kept in `.claude/agents/archive/`
for reference.
```

**Recommended Change**:
Replace with:
```markdown
### Lean Skills (Standard Pattern)

The Lean skills (`skill-lean-research`, `skill-lean-implementation`) follow the standard thin wrapper pattern, delegating to `lean-research-agent` and `lean-implementation-agent` respectively.

**Note**: These skills were temporarily refactored to direct execution in January 2026 due to MCP tool hanging issues (bugs #15945, #13254, #4580). The issues have been resolved, and the skills have been restored to the standard delegation pattern.
```

---

### Finding 5: Additional Direct Execution References

**Locations requiring review** (search pattern: "direct execution" mentions related to Lean):

| File | Line | Context |
|------|------|---------|
| `.claude/README.md` | 1056-1058 | Direct Execution Migration section |
| `.claude/context/core/patterns/thin-wrapper-skill.md` | 165-177 | Lean Skills Exception |

**Files that correctly reference agent delegation** (no changes needed):
- `.claude/CLAUDE.md` - Skill-to-agent mapping table correct
- `.claude/README.md` lines 910-914 - Skill-to-agent mapping correct
- `.claude/agents/lean-research-agent.md` - Active agent, no deprecation note
- `.claude/agents/lean-implementation-agent.md` - Active agent, no deprecation note
- `.claude/skills/skill-lean-research/SKILL.md` - Uses Task tool delegation
- `.claude/skills/skill-lean-implementation/SKILL.md` - Uses Task tool delegation

---

### Finding 6: When NOT to Use Pattern in thin-wrapper-skill.md (Lines 153-158)

**Location**: `/home/benjamin/Projects/ProofChecker/.claude/context/core/patterns/thin-wrapper-skill.md` (lines 153-158)

**Current Content** (OUTDATED):
```markdown
Use direct execution instead when:
- Skill executes atomic operations (skill-status-sync)
- No subagent needed
- Work is trivial
- **MCP tools are involved** - Subagents cannot reliably use MCP tools due to Claude Code
  platform bugs (#15945, #13254, #4580) that cause indefinite hanging
```

**Recommended Change**:
Remove the MCP tools bullet point since the issue has been resolved:
```markdown
Use direct execution instead when:
- Skill executes atomic operations (skill-status-sync)
- No subagent needed
- Work is trivial
```

## Decisions

1. **Keep CLAUDE.md skill-to-agent mapping as-is**: Already shows correct agent names
2. **Update blocked-mcp-tools.md**: Remove "Deprecated" from agent file descriptions
3. **Update README.md**: Replace "Direct Execution Migration" with "Lean Agent Delegation Restoration"
4. **Update thin-wrapper-skill.md**: Remove Lean Skills Exception section and MCP tools caveat

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Missing additional references | Search results captured all 15+ files mentioning Lean agents |
| Breaking documentation links | Agent files remain in same location, only description changes |
| Historical context loss | Keep brief note about temporary direct execution period |

## Appendix

### Search Queries Used

1. `grep "direct execution" .claude/` - Found 27 matches
2. `grep "lean-research-agent|lean-implementation-agent" .claude/` - Found 98+ matches
3. `grep "skill-lean-research|skill-lean-implementation" .claude/` - Found 70+ matches
4. `grep "deprecated|deprecation" .claude/` - Found 30+ matches

### Files to Update (Summary)

| File | Lines | Change Type |
|------|-------|-------------|
| `.claude/context/core/patterns/blocked-mcp-tools.md` | 64-65 | Remove "Deprecated" |
| `.claude/README.md` | 1056-1058 | Rewrite section |
| `.claude/context/core/patterns/thin-wrapper-skill.md` | 153-177 | Remove outdated exceptions |

### Files Already Correct (No Changes)

- `.claude/CLAUDE.md` (lines 146-147)
- `.claude/README.md` (lines 910-914)
- `.claude/agents/lean-research-agent.md`
- `.claude/agents/lean-implementation-agent.md`
- `.claude/skills/skill-lean-research/SKILL.md`
- `.claude/skills/skill-lean-implementation/SKILL.md`
