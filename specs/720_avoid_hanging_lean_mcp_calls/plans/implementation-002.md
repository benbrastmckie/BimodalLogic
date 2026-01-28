# Implementation Plan: Task #720

**Task**: avoid_hanging_lean_mcp_calls
**Version**: 002
**Created**: 2026-01-28
**Language**: meta
**Revision Reason**: Clarify that the goal is NOT to remove tools from allowed-tools lists, but to discourage their use via documentation while keeping them available.

## Overview

Add warnings and documentation to discourage use of `lean_diagnostic_messages` and `lean_file_outline` MCP tools which consistently hang. The tools should remain in allowed-tools lists (they work in principle), but workflow instructions should direct users to alternative approaches. This preserves the ability to use these tools if the bug is fixed or in edge cases, while preventing default use that causes hanging.

## Goals & Non-Goals

**Goals**:
- Add warnings about hanging behavior to skill documentation
- Update workflow instructions to recommend fallback alternatives as the default
- Document which tools to use instead (lean_goal, lake build, Read, lean_hover_info)
- Keep tools in allowed-tools lists (do NOT remove them)

**Non-Goals**:
- Removing tools from allowed-tools lists (they should remain available)
- Modifying deprecated agent files
- Changing general documentation files

## Key Clarification

**Previous plan (v001)**: Remove tools from allowed-tools lists
**Revised plan (v002)**: Keep tools in allowed-tools, add warnings and recommend alternatives

This approach is better because:
1. Tools remain available if bug is fixed or for edge cases
2. No need to re-add tools later (just remove warnings)
3. More informative to users about why alternatives are recommended

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| User ignores warnings and uses hanging tools | Medium | Low | Make warnings prominent, place near tool usage instructions |
| Warnings become stale after bug is fixed | Low | Medium | Include issue reference so warnings can be removed when resolved |

## Implementation Phases

### Phase 1: Add Warnings to Skill Files [NOT STARTED]

**Goal**: Add prominent warnings about hanging tools and recommend alternatives in all affected skill files.

**Estimated effort**: 0.5 hours

**Files to modify**:
- `.claude/skills/skill-lean-implementation/SKILL.md` - Add warning section, update workflow to recommend alternatives
- `.claude/skills/skill-lean-research/SKILL.md` - Add warning section
- `.claude/skills/skill-lake-repair/SKILL.md` - Add warning section, note reliance on Bash fallback

**Steps**:

1. **Edit skill-lean-implementation/SKILL.md**:
   - Add warning section after frontmatter (before ## Trigger Conditions):
     ```markdown
     ## Known Issues - Tool Availability

     **WARNING**: The following lean-lsp MCP tools are currently hanging and should NOT be used:
     - `lean_diagnostic_messages` - Use `lean_goal` or `lake build` via Bash instead
     - `lean_file_outline` - Use `Read` tool or `lean_hover_info` on specific symbols instead

     These tools remain in allowed-tools for when the upstream bug is fixed.
     See: lean-lsp-mcp issues #118, #115
     ```
   - Update any workflow steps that reference these tools to recommend alternatives

2. **Edit skill-lean-research/SKILL.md**:
   - Add similar warning section after frontmatter
   - Research workflows primarily use search tools, so minimal workflow changes needed

3. **Edit skill-lake-repair/SKILL.md**:
   - Add warning about `lean_diagnostic_messages`
   - Note that skill already uses `lake build` via Bash as the primary mechanism

**Verification**:
- Each skill file contains the warning section
- Warning appears prominently near the top of the file
- Alternative tools are clearly recommended

---

### Phase 2: Update Workflow Instructions [NOT STARTED]

**Goal**: Ensure workflow instructions recommend alternatives as the default approach.

**Estimated effort**: 0.25 hours

**Files to modify**:
- `.claude/skills/skill-lean-implementation/SKILL.md` - Update Stage 6 Step 4 and similar

**Steps**:

1. **Update skill-lean-implementation/SKILL.md workflow**:
   - Locate any steps that say "Use `lean_diagnostic_messages`"
   - Change to: "Use `lean_goal` to check proof state, or `lake build` via Bash for full error diagnostics"
   - Note: Do NOT remove the tools from allowed-tools

2. **Update skill-lake-repair/SKILL.md error handling**:
   - Ensure error handling section emphasizes `lake build` as primary approach
   - Note that `lean_diagnostic_messages` is listed but currently hangs

**Verification**:
- Workflow instructions recommend working alternatives
- No instructions tell users to use the hanging tools as the first option
- Tools still listed in allowed-tools (not removed)

---

## Dependencies

- None (standalone documentation updates)

## Testing & Validation

- [ ] Warning sections present in all 3 skill files
- [ ] Workflow instructions recommend alternatives (lean_goal, lake build, Read)
- [ ] Tools remain in allowed-tools lists (NOT removed)
- [ ] YAML frontmatter still valid

## Artifacts & Outputs

- Modified `.claude/skills/skill-lean-implementation/SKILL.md` (warning + workflow updates)
- Modified `.claude/skills/skill-lean-research/SKILL.md` (warning only)
- Modified `.claude/skills/skill-lake-repair/SKILL.md` (warning + emphasis on Bash)

## Rollback/Contingency

When upstream MCP bug is fixed:
1. Remove warning sections from skill files
2. Optionally restore original workflow text recommending these tools
3. No need to modify allowed-tools (tools already present)

## Success Criteria

- [ ] Warning sections added to all affected skill files
- [ ] Workflow instructions recommend working alternatives
- [ ] `lean_diagnostic_messages` and `lean_file_outline` remain in allowed-tools (NOT removed)
- [ ] No syntax errors in modified files
