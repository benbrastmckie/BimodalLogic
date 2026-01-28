# Implementation Plan: Task #721

**Task**: prevent_mcp_tool_hanging_multi_layer_defense
**Version**: 001
**Created**: 2026-01-28
**Language**: meta

## Overview

Implement multi-layer defense against MCP tool hanging by adding minimal, targeted blocking instructions. Task 720 removed tools from `allowed-tools` but agents still call them because: (1) primary agent has unrestricted access, (2) skill instructions still reference the tools.

## Goals & Non-Goals

**Goals**:
- Block lean_diagnostic_messages and lean_file_outline at all layers
- Keep additions minimal (< 10 lines per file)
- Optimize for token efficiency

**Non-Goals**:
- Detailed explanations of why tools hang
- Comprehensive documentation rewrites
- Changes to MCP server configuration

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Agents ignore instructions | Multiple layers catch violations |
| Context bloat | Each addition < 10 lines |

## Implementation Phases

### Phase 1: CLAUDE.md - Primary Agent Guard [NOT STARTED]

**Goal**: Stop primary agent from calling blocked tools before skill delegation.

**File**: `.claude/CLAUDE.md`

**Location**: After "## Lean 4 Integration" section header, before "### MCP Tools" subsection

**Add** (exactly):
```markdown
### Blocked MCP Tools

**DO NOT call directly** - these tools hang indefinitely:
- `lean_diagnostic_messages` → Use `lean_goal` or `lake build`
- `lean_file_outline` → Use `Read` + `lean_hover_info`

Delegate Lean work to skills which enforce this restriction.
```

**Verification**: Grep CLAUDE.md for "Blocked MCP Tools" section exists

---

### Phase 2: Skill Instruction Cleanup [NOT STARTED]

**Goal**: Remove references that tell agents to use blocked tools.

**Files to modify**:

#### 2A: skill-lean-implementation/SKILL.md

**Remove/Replace** references at:
- Line ~201: `Use lean_diagnostic_messages` → Remove or replace with `Use lean_goal`
- Line ~466: Fallback table row for `lean_diagnostic_messages` → Keep only as "Primary Tool" column entry (it's documenting fallback FROM the tool, not TO it - verify context)
- Line ~478: `Use lean_diagnostic_messages` → Replace with `Use lean_goal + lake build`

**Verify**: The workaround note at line 14 already documents the restriction. Ensure body text doesn't contradict it.

#### 2B: skill-lean-research/SKILL.md

**Check** for any references to blocked tools in workflow sections and remove/replace.

#### 2C: mcp-tools-guide.md

**Add** after "## Overview" section:
```markdown
### Blocked Tools (Temporary)

| Tool | Status | Alternative |
|------|--------|-------------|
| `lean_diagnostic_messages` | BLOCKED | `lean_goal` + `lake build` |
| `lean_file_outline` | BLOCKED | `Read` + `lean_hover_info` |
```

**Verification**: Grep skills for "lean_diagnostic_messages" in instruction context (not in workaround notes)

---

### Phase 3: Command-Level Warnings [NOT STARTED]

**Goal**: Add brief warning to commands that involve Lean work.

**Files**: `.claude/commands/research.md`, `implement.md`, `lake.md`

**Add** at start of "## Execution" section (before CHECKPOINT 1):
```markdown
**MCP Safety**: Do not call `lean_diagnostic_messages` or `lean_file_outline` - they hang. Delegate to skills.
```

**Verification**: Each command file contains MCP Safety note

---

### Phase 4: Verify and Test [NOT STARTED]

**Goal**: Confirm multi-layer defense is in place.

**Steps**:
1. Grep for "lean_diagnostic_messages" across .claude/ - only valid contexts should remain:
   - Workaround notes explaining removal
   - Fallback tables showing alternatives
   - Blocked tools lists
2. Verify CLAUDE.md has Blocked MCP Tools section
3. Verify commands have MCP Safety notes

**Verification**: No instructional text telling agents to USE blocked tools

---

## Dependencies

- None (builds on Task 720)

## Testing & Validation

- [ ] CLAUDE.md contains "Blocked MCP Tools" section
- [ ] skill-lean-implementation has no USE instructions for blocked tools
- [ ] skill-lean-research has no USE instructions for blocked tools
- [ ] mcp-tools-guide has Blocked Tools table
- [ ] research.md has MCP Safety note
- [ ] implement.md has MCP Safety note
- [ ] lake.md has MCP Safety note

## Success Criteria

- [ ] All 4 phases complete
- [ ] Grep shows no "use lean_diagnostic_messages" instructions
- [ ] Total additions < 50 lines across all files
