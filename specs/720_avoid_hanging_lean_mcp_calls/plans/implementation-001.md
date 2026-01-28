# Implementation Plan: Task #720

**Task**: avoid_hanging_lean_mcp_calls
**Version**: 001
**Created**: 2026-01-28
**Language**: meta

## Overview

Remove `lean_diagnostic_messages` and `lean_file_outline` from skill allowed-tools lists and update workflow documentation to use existing fallback mechanisms (`lean_goal`, `lake build` via Bash, `Read` tool). This is a temporary workaround for the lean-lsp MCP hanging bug.

## Goals & Non-Goals

**Goals**:
- Remove hanging MCP tools from all active skill allowed-tools lists
- Update workflow instructions to use fallback alternatives
- Add workaround notes explaining the temporary removal

**Non-Goals**:
- Modifying deprecated agent files (they are not actively invoked)
- Changing general documentation files (they document capabilities, not active workflows)
- Implementing new fallback mechanisms (existing fallbacks are sufficient)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `lean_goal` doesn't catch all errors | Medium | Medium | Fall back to `lake build` for comprehensive diagnostics |
| `Read` tool less efficient than `lean_file_outline` | Low | Low | Only affects code understanding, not correctness |
| Forgetting to restore tools after fix | Low | Medium | Add TODO comments with date and issue reference |

## Implementation Phases

### Phase 1: Modify Skill and Command Files [COMPLETED]

**Goal**: Remove hanging tools from allowed-tools and update workflow text in all 4 affected files.

**Estimated effort**: 0.5 hours

**Files to modify**:
- `.claude/skills/skill-lean-implementation/SKILL.md` - Remove both tools from allowed-tools, update workflow references
- `.claude/skills/skill-lean-research/SKILL.md` - Remove both tools from allowed-tools
- `.claude/skills/skill-lake-repair/SKILL.md` - Remove `lean_diagnostic_messages` from allowed-tools
- `.claude/commands/lake.md` - Remove `lean_diagnostic_messages` from allowed-tools

**Steps**:

1. **Edit skill-lean-implementation/SKILL.md**:
   - Line 4: Remove `mcp__lean-lsp__lean_diagnostic_messages` and `mcp__lean-lsp__lean_file_outline` from allowed-tools
   - Add workaround note after line 12 explaining temporary removal

2. **Edit skill-lean-research/SKILL.md**:
   - Line 4: Remove `mcp__lean-lsp__lean_diagnostic_messages` and `mcp__lean-lsp__lean_file_outline` from allowed-tools
   - Add workaround note after line 12 explaining temporary removal

3. **Edit skill-lake-repair/SKILL.md**:
   - Line 4: Remove `mcp__lean-lsp__lean_diagnostic_messages` from allowed-tools
   - Add workaround note after line 11 explaining temporary removal

4. **Edit commands/lake.md**:
   - Line 3: Remove `mcp__lean-lsp__lean_diagnostic_messages` from allowed-tools

**Verification**:
- Grep for `lean_diagnostic_messages` in `.claude/skills/` and `.claude/commands/` - should return 0 matches in allowed-tools lines
- Grep for `lean_file_outline` in `.claude/skills/` - should return 0 matches in allowed-tools lines
- All 4 files still parse as valid YAML frontmatter

---

### Phase 2: Verify and Document [COMPLETED]

**Goal**: Verify changes are complete and add restoration TODO comments.

**Estimated effort**: 0.25 hours

**Steps**:

1. **Verify no active skills reference removed tools in allowed-tools**:
   ```bash
   grep -l "lean_diagnostic_messages" .claude/skills/*/SKILL.md .claude/commands/*.md | head -10
   ```
   Should return empty (deprecated files in .claude/agents/ are expected to still reference them)

2. **Verify workaround notes are in place**:
   Each modified skill file should contain a note like:
   ```
   **Temporary Workaround**: `lean_diagnostic_messages` and `lean_file_outline` removed due to MCP hanging bug.
   Use `lean_goal` + `lake build` for diagnostics, `Read` + `lean_hover_info` for file structure.
   ```

3. **Add restoration TODO** (optional, in workaround notes):
   Reference lean-lsp-mcp issues #118, #115 for tracking when to restore

**Verification**:
- All modified files have workaround notes
- Skills can still be invoked (no syntax errors)
- Fallback mechanisms documented in notes

---

## Dependencies

- None (standalone modification to existing files)

## Testing & Validation

- [ ] Grep confirms no `lean_diagnostic_messages` in active skill allowed-tools
- [ ] Grep confirms no `lean_file_outline` in active skill allowed-tools
- [ ] All 4 modified files have valid YAML frontmatter
- [ ] Workaround notes added to skill files

## Artifacts & Outputs

- Modified `.claude/skills/skill-lean-implementation/SKILL.md`
- Modified `.claude/skills/skill-lean-research/SKILL.md`
- Modified `.claude/skills/skill-lake-repair/SKILL.md`
- Modified `.claude/commands/lake.md`

## Rollback/Contingency

When upstream MCP bug is fixed:
1. Re-add `mcp__lean-lsp__lean_diagnostic_messages` to all 4 files
2. Re-add `mcp__lean-lsp__lean_file_outline` to skill-lean-implementation and skill-lean-research
3. Remove workaround notes
4. Optionally restore original workflow text referencing these tools

## Success Criteria

- [ ] `lean_diagnostic_messages` removed from all active skill/command allowed-tools lists
- [ ] `lean_file_outline` removed from all active skill allowed-tools lists
- [ ] Workaround notes explain temporary removal and fallback mechanisms
- [ ] No syntax errors in modified files
