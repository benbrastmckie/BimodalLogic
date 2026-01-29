# Implementation Plan: Task #744

- **Task**: 744 - update_documentation_lean_agent_architecture
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Priority**: medium
- **Dependencies**: None
- **Research Inputs**: specs/744_update_documentation_lean_agent_architecture/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task updates documentation to reflect the restoration of Lean agent delegation patterns. The Lean skills were temporarily refactored to direct execution due to MCP bugs, but have since been restored to the standard thin wrapper delegation pattern. Three context files contain outdated references that need correction.

### Research Integration

Research identified 3 files requiring updates:
- `blocked-mcp-tools.md`: Lines 64-65 incorrectly mark agent files as "Deprecated"
- `README.md`: Lines 1056-1058 contain outdated "Direct Execution Migration" section
- `thin-wrapper-skill.md`: Lines 153-177 contain outdated "Lean Skills Exception" section and MCP caveat

CLAUDE.md skill-to-agent mapping table is already correct (no changes needed).

## Goals & Non-Goals

**Goals**:
- Remove outdated "deprecated" references to Lean agent files
- Update README.md to document restoration of delegation pattern
- Remove outdated exception documentation from thin-wrapper-skill.md
- Preserve historical context in brief notes

**Non-Goals**:
- Modifying agent or skill files (already correct)
- Changing CLAUDE.md skill-to-agent mapping (already correct)
- Adding new documentation beyond corrections

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Missing additional outdated references | L | L | Research grep covered all relevant patterns |
| Introducing documentation inconsistencies | M | L | Use exact replacement text from research |

## Implementation Phases

### Phase 1: Update blocked-mcp-tools.md [NOT STARTED]

**Goal**: Remove "Deprecated" from agent file descriptions in the Related Documentation section.

**Tasks**:
- [ ] Edit lines 64-65 to remove "Deprecated" prefix from agent descriptions

**Timing**: 5 minutes

**Files to modify**:
- `.claude/context/core/patterns/blocked-mcp-tools.md` - Remove "Deprecated" from lines 64-65

**Changes**:
```markdown
# BEFORE (lines 64-65):
- `.claude/agents/lean-research-agent.md` - Deprecated agent with blocked tools warning
- `.claude/agents/lean-implementation-agent.md` - Deprecated agent with blocked tools warning

# AFTER:
- `.claude/agents/lean-research-agent.md` - Agent with blocked tools warning
- `.claude/agents/lean-implementation-agent.md` - Agent with blocked tools warning
```

**Verification**:
- File contains no "Deprecated" references to agent files
- Related Documentation section lists both agent files

---

### Phase 2: Update README.md [NOT STARTED]

**Goal**: Replace "Direct Execution Migration" section with "Lean Agent Delegation Restoration" documenting the fix.

**Tasks**:
- [ ] Replace lines 1056-1058 with updated section title and content

**Timing**: 5 minutes

**Files to modify**:
- `.claude/README.md` - Replace Direct Execution Migration section

**Changes**:
```markdown
# BEFORE (lines 1056-1058):
### Direct Execution Migration

Due to additional MCP bugs (#15945, #13254, #4580) causing indefinite hanging in subagents, the Lean skills (`skill-lean-research`, `skill-lean-implementation`) were refactored from the thin wrapper delegation pattern to direct execution. MCP tools now execute directly in the skill rather than in a delegated subagent, eliminating the hanging issue.

# AFTER:
### Lean Agent Delegation Restoration (January 2026)

The Lean skills (`skill-lean-research`, `skill-lean-implementation`) were temporarily refactored to direct execution due to MCP bugs (#15945, #13254, #4580) causing indefinite hanging. These issues have been resolved, and the skills now use the standard thin wrapper delegation pattern, routing to `lean-research-agent` and `lean-implementation-agent` respectively.
```

**Verification**:
- Section title changed to "Lean Agent Delegation Restoration"
- Content reflects restoration, not migration to direct execution

---

### Phase 3: Update thin-wrapper-skill.md [NOT STARTED]

**Goal**: Remove outdated MCP tools caveat from "When NOT to Use" section and replace "Lean Skills Exception" section with brief historical note.

**Tasks**:
- [ ] Remove MCP tools bullet from "When NOT to Use" section (lines 157-158)
- [ ] Replace "Lean Skills Exception" section (lines 165-177) with "Lean Skills (Standard Pattern)" section

**Timing**: 10 minutes

**Files to modify**:
- `.claude/context/core/patterns/thin-wrapper-skill.md` - Remove outdated exceptions

**Changes (Part A - lines 153-158)**:
```markdown
# BEFORE:
Use direct execution instead when:
- Skill executes atomic operations (skill-status-sync)
- No subagent needed
- Work is trivial
- **MCP tools are involved** - Subagents cannot reliably use MCP tools due to Claude Code
  platform bugs (#15945, #13254, #4580) that cause indefinite hanging

# AFTER:
Use direct execution instead when:
- Skill executes atomic operations (skill-status-sync)
- No subagent needed
- Work is trivial
```

**Changes (Part B - lines 165-177)**:
```markdown
# BEFORE:
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

# AFTER:
### Lean Skills (Standard Pattern)

The Lean skills (`skill-lean-research`, `skill-lean-implementation`) follow the standard thin wrapper pattern, delegating to `lean-research-agent` and `lean-implementation-agent` respectively.

**Note**: These skills were temporarily refactored to direct execution in January 2026 due to MCP tool hanging issues (bugs #15945, #13254, #4580). The issues have been resolved, and the skills have been restored to the standard delegation pattern.
```

**Verification**:
- "When NOT to Use" section has no MCP tools bullet
- "Lean Skills Exception" section renamed to "Lean Skills (Standard Pattern)"
- Content reflects current (restored) state, with brief historical note

---

## Testing & Validation

- [ ] No grep matches for "Deprecated agent" in .claude/ directory
- [ ] No grep matches for "Direct Execution Migration" in .claude/ directory
- [ ] No grep matches for "Lean Skills Exception" in .claude/ directory
- [ ] Grep for "thin wrapper" in thin-wrapper-skill.md shows Lean skills using standard pattern

## Artifacts & Outputs

- Updated `.claude/context/core/patterns/blocked-mcp-tools.md`
- Updated `.claude/README.md`
- Updated `.claude/context/core/patterns/thin-wrapper-skill.md`
- Implementation summary after completion

## Rollback/Contingency

If updates introduce problems:
1. `git checkout HEAD~1 -- .claude/context/core/patterns/blocked-mcp-tools.md`
2. `git checkout HEAD~1 -- .claude/README.md`
3. `git checkout HEAD~1 -- .claude/context/core/patterns/thin-wrapper-skill.md`

All changes are documentation-only with no functional impact.
