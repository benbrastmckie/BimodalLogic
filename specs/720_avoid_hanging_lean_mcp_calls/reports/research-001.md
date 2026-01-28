# Research Report: Task #720

**Task**: 720 - avoid_hanging_lean_mcp_calls
**Started**: 2026-01-28T12:00:00Z
**Completed**: 2026-01-28T12:15:00Z
**Effort**: 1-2 hours
**Priority**: High (blocking Lean workflows)
**Dependencies**: None
**Sources/Inputs**: Codebase analysis (.claude/skills/, .claude/agents/, .claude/context/)
**Artifacts**: specs/720_avoid_hanging_lean_mcp_calls/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- **3 skill files** contain `lean_diagnostic_messages` and/or `lean_file_outline` in their allowed-tools
- **2 deprecated agent files** reference these tools but are not actively invoked
- **Existing fallback patterns** are already documented for `lean_diagnostic_messages` failures
- **Modification approach**: Remove tools from allowed-tools list, update documentation to use existing fallbacks

## Context & Scope

The lean-lsp MCP server is experiencing hanging issues when `lean_diagnostic_messages` and `lean_file_outline` are called. This affects Lean workflows that rely on these tools. The task requires modifying lean skills to avoid these calls while preserving functionality using existing fallback mechanisms.

## Findings

### Files Containing Problematic Tool References

#### 1. skill-lean-implementation/SKILL.md (Active - Direct Execution)

**Path**: `.claude/skills/skill-lean-implementation/SKILL.md`

**Current allowed-tools line 4**:
```yaml
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, mcp__lean-lsp__lean_goal, mcp__lean-lsp__lean_diagnostic_messages, mcp__lean-lsp__lean_hover_info, mcp__lean-lsp__lean_completions, mcp__lean-lsp__lean_multi_attempt, mcp__lean-lsp__lean_local_search, mcp__lean-lsp__lean_state_search, mcp__lean-lsp__lean_hammer_premise, mcp__lean-lsp__lean_file_outline, mcp__lean-lsp__lean_term_goal, mcp__lean-lsp__lean_declaration_file, mcp__lean-lsp__lean_run_code, mcp__lean-lsp__lean_build, mcp__lean-lsp__lean_leansearch, mcp__lean-lsp__lean_loogle, mcp__lean-lsp__lean_leanfinder
```

**Tools to remove**:
- `mcp__lean-lsp__lean_diagnostic_messages`
- `mcp__lean-lsp__lean_file_outline`

**Usage in file**:
- Line 199: "Use `lean_diagnostic_messages` to check for errors"
- Line 464: Fallback table showing `lean_diagnostic_messages` -> `lean_goal` -> `lake build`
- Line 476: "Use `lean_diagnostic_messages` to get details"

**Modification needed**:
1. Remove from allowed-tools
2. Update Step 4 (line 199) to use `lean_goal` instead
3. Keep fallback table but mark `lean_diagnostic_messages` as unavailable
4. Update line 476 to use `lean_goal` or `lake build` directly

---

#### 2. skill-lean-research/SKILL.md (Active - Direct Execution)

**Path**: `.claude/skills/skill-lean-research/SKILL.md`

**Current allowed-tools line 4**:
```yaml
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, mcp__lean-lsp__lean_leansearch, mcp__lean-lsp__lean_loogle, mcp__lean-lsp__lean_leanfinder, mcp__lean-lsp__lean_local_search, mcp__lean-lsp__lean_hover_info, mcp__lean-lsp__lean_state_search, mcp__lean-lsp__lean_hammer_premise, mcp__lean-lsp__lean_goal, mcp__lean-lsp__lean_file_outline, mcp__lean-lsp__lean_diagnostic_messages, mcp__lean-lsp__lean_completions, mcp__lean-lsp__lean_declaration_file, mcp__lean-lsp__lean_run_code
```

**Tools to remove**:
- `mcp__lean-lsp__lean_diagnostic_messages`
- `mcp__lean-lsp__lean_file_outline`

**Usage in file**:
- Not explicitly used in workflow stages (tools are listed for availability)
- Research workflow primarily uses search tools (leansearch, loogle, leanfinder)

**Modification needed**:
1. Remove from allowed-tools
2. No workflow text changes needed (research doesn't rely on diagnostics)

---

#### 3. skill-lake-repair/SKILL.md (Active - Direct Execution)

**Path**: `.claude/skills/skill-lake-repair/SKILL.md`

**Current allowed-tools line 4**:
```yaml
allowed-tools: Read, Write, Edit, Bash, mcp__lean-lsp__lean_build, mcp__lean-lsp__lean_diagnostic_messages
```

**Tools to remove**:
- `mcp__lean-lsp__lean_diagnostic_messages`

**Usage in file**:
- Line 691: Error handling section mentions both tools as MCP alternatives

**Modification needed**:
1. Remove from allowed-tools
2. Update error handling section (line 691) to rely solely on `lake build` via Bash
3. Skill already has robust error parsing from `lake build` stdout/stderr

---

#### 4. lake.md (Command Definition)

**Path**: `.claude/commands/lake.md`

**Current allowed-tools line 3**:
```yaml
allowed-tools: Read, Write, Edit, Bash, mcp__lean-lsp__lean_build, mcp__lean-lsp__lean_diagnostic_messages
```

**Modification needed**:
1. Remove `mcp__lean-lsp__lean_diagnostic_messages`
2. This file is the command definition that maps to skill-lake-repair

---

### Deprecated Files (Reference Only - No Changes Needed)

#### lean-implementation-agent.md

**Path**: `.claude/agents/lean-implementation-agent.md`

**Status**: DEPRECATED (line 6-9) - No longer invoked, kept for reference

**Tools listed**: Both `lean_diagnostic_messages` and `lean_file_outline`

**Action**: No changes needed (deprecated file)

---

#### lean-research-agent.md

**Path**: `.claude/agents/lean-research-agent.md`

**Status**: DEPRECATED (line 6-9) - No longer invoked, kept for reference

**Tools listed**: Both `lean_diagnostic_messages` and `lean_file_outline`

**Action**: No changes needed (deprecated file)

---

### Documentation Files Referencing These Tools

The following documentation files reference these tools but do NOT need modification (they document general capabilities, not active workflows):

1. `.claude/CLAUDE.md` - General MCP tools overview (line 231)
2. `.claude/rules/lean4.md` - Lean development patterns (lines 14, 61, 64, 128, 178)
3. `.claude/context/project/lean4/tools/mcp-tools-guide.md` - Tool reference (lines 47-61, 119-129)
4. `.claude/context/core/patterns/mcp-tool-recovery.md` - Recovery patterns (line 84, 132)
5. `.claude/context/project/lean4/agents/lean-implementation-flow.md` - Flow documentation (lines 98, 331, 357)
6. `.claude/docs/guides/user-installation.md` - User guide (lines 121, 224)

**Recommendation**: Leave documentation as-is. The tools still exist in the MCP server; we're just avoiding their use due to a temporary bug. Documentation should note the workaround but doesn't need wholesale removal.

---

### Existing Fallback Mechanisms

The codebase already documents fallback patterns in `mcp-tool-recovery.md`:

| Primary Tool | Alternative | Fallback |
|--------------|-------------|----------|
| `lean_diagnostic_messages` | `lean_goal` | `lake build` via Bash |

This existing pattern means:
1. `lean_goal` can show proof state and detect basic errors
2. `lake build` via Bash provides full error output
3. Error parsing from build output is already implemented in skill-lake-repair

---

### Alternative Information Sources

Instead of the hanging tools, use:

| Hanging Tool | Alternative Approach |
|--------------|---------------------|
| `lean_diagnostic_messages` | 1. `lean_goal` for proof state errors, 2. `lake build` via Bash for full diagnostics |
| `lean_file_outline` | 1. `Read` tool to read the file directly, 2. `lean_hover_info` on specific symbols, 3. `Grep` to find declarations |

---

## Decisions

1. **Remove tools from allowed-tools lists** rather than trying to catch/handle hanging
2. **Update workflow documentation** to use fallbacks directly
3. **Keep deprecated agent files unchanged** since they're already deprecated
4. **Leave general documentation intact** to avoid information loss when bug is fixed
5. **Add a temporary workaround note** in affected skill files

## Recommendations

### Phase 1: Skill Modifications (Required)

1. **skill-lean-implementation/SKILL.md**
   - Remove `mcp__lean-lsp__lean_diagnostic_messages` from allowed-tools
   - Remove `mcp__lean-lsp__lean_file_outline` from allowed-tools
   - Update Stage 6 Step 4 to use `lean_goal` + `lake build` instead
   - Add workaround note explaining temporary removal

2. **skill-lean-research/SKILL.md**
   - Remove `mcp__lean-lsp__lean_diagnostic_messages` from allowed-tools
   - Remove `mcp__lean-lsp__lean_file_outline` from allowed-tools
   - Add workaround note

3. **skill-lake-repair/SKILL.md**
   - Remove `mcp__lean-lsp__lean_diagnostic_messages` from allowed-tools
   - Update MCP Tool Failure section to note it relies on Bash fallback
   - Add workaround note

4. **commands/lake.md**
   - Remove `mcp__lean-lsp__lean_diagnostic_messages` from allowed-tools

### Phase 2: Documentation Update (Optional)

1. Add a note to `.claude/context/project/lean4/tools/mcp-tools-guide.md` explaining the temporary unavailability
2. Update `mcp-tool-recovery.md` to note that `lean_diagnostic_messages` fallback is now the default

### Phase 3: Restoration (Future)

When the upstream MCP bug is fixed:
1. Re-add tools to allowed-tools lists
2. Remove workaround notes
3. Optionally restore original workflow text

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| `lean_goal` doesn't catch all errors | Medium | Medium | Fall back to `lake build` for comprehensive diagnostics |
| `Read` tool less efficient than `lean_file_outline` | Low | Low | Only affects code understanding, not correctness |
| Forgetting to restore tools after fix | Medium | Low | Add TODO comments with date and issue reference |

---

## Appendix

### Files Modified Summary

| File | Change Type | Tools Removed |
|------|-------------|---------------|
| `.claude/skills/skill-lean-implementation/SKILL.md` | allowed-tools + text | `lean_diagnostic_messages`, `lean_file_outline` |
| `.claude/skills/skill-lean-research/SKILL.md` | allowed-tools | `lean_diagnostic_messages`, `lean_file_outline` |
| `.claude/skills/skill-lake-repair/SKILL.md` | allowed-tools + text | `lean_diagnostic_messages` |
| `.claude/commands/lake.md` | allowed-tools | `lean_diagnostic_messages` |

### Search Queries Used

1. `Grep "lean_diagnostic_messages"` in `.claude/`
2. `Grep "lean_file_outline"` in `.claude/`
3. `Glob ".claude/skills/**/skill-lean*"` for skill files

### References

- lean-lsp-mcp GitHub issues: #118, #115 (hanging diagnostics)
- Claude Code bugs: #15945, #13254, #4580 (MCP hanging in subagents)
- Existing documentation: `.claude/context/core/patterns/mcp-tool-recovery.md`
