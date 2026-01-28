# Implementation Plan: Task #715

**Task**: Fix /lake command execution
**Version**: 001
**Created**: 2026-01-28
**Language**: meta

## Overview

The `/lake` command fails to execute because it lacks explicit execution directives. The command file describes what skill-lake-repair does but doesn't instruct Claude to actually execute the steps. This plan adds frontmatter and execution directives following the pattern of working commands like `/implement`.

## Root Cause Analysis

**Problem**: When user runs `/lake --clean`, Claude:
1. Loads the command file
2. Reads the documentation about what the skill does
3. Reports "The skill is running" without actually running anything
4. No actual `lake build` or error fixing occurs

**Compare to `/implement`** which works correctly:
1. Has frontmatter with `allowed-tools: Skill, Bash(jq:*), Bash(git:*), Read, Edit, Glob`
2. Has explicit "**EXECUTE NOW**" directives
3. Has "**IMMEDIATELY CONTINUE** to STAGE 2" instructions
4. Has structured CHECKPOINT pattern with clear action items

**The fix**: Add frontmatter and execution directives to `/lake.md` command file.

---

## Phases

### Phase 1: Update lake.md command file

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add YAML frontmatter with allowed-tools
2. Add explicit execution directives
3. Follow the checkpoint pattern from working commands

**Files to modify**:
- `.claude/commands/lake.md` - Add execution logic

**Steps**:

1. **Add frontmatter** at the top of lake.md:
   ```yaml
   ---
   description: Run Lean build with automatic error repair
   allowed-tools: Read, Write, Edit, Bash, mcp__lean-lsp__lean_build, mcp__lean-lsp__lean_diagnostic_messages
   argument-hint: [--clean] [--max-retries N] [--dry-run] [--module NAME]
   ---
   ```

2. **Restructure Execution section** to use checkpoint pattern:
   - Add "### STEP 1: Parse Arguments" with "**EXECUTE NOW**" directive
   - Add "### STEP 2: Run Build" with "**EXECUTE NOW**: Run lake build"
   - Add "### STEP 3: Parse and Fix Errors" with iteration loop
   - Add "### STEP 4: Report Results"

3. **Add critical execution directives** after each step:
   - "**On success**: **IMMEDIATELY CONTINUE** to next step"
   - "**EXECUTE NOW**: [action]"

4. **Reference the skill file** for detailed fix logic:
   - Add: "For detailed fix algorithms, reference @.claude/skills/skill-lake-repair/SKILL.md"

**Verification**:
- Run `/lake --dry-run` and verify it actually runs lake build and shows preview
- Run `/lake` and verify it builds and attempts fixes

---

### Phase 2: Test execution

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Verify command executes properly
2. Verify dry-run mode works
3. Verify clean mode works

**Steps**:

1. Test dry-run mode:
   ```bash
   /lake --dry-run
   ```
   Expected: Shows build output and preview of fixes without applying

2. Test clean mode:
   ```bash
   /lake --clean
   ```
   Expected: Runs `lake clean`, then builds, then fixes errors

3. Test basic mode:
   ```bash
   /lake
   ```
   Expected: Runs build and fixes errors

**Verification**:
- All three modes execute actual commands
- Build output is captured and displayed
- Fixes are applied (or previewed in dry-run)

---

## Dependencies

- None (self-contained fix)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Execution directives too verbose | Low | Keep concise, reference skill file for details |
| MCP tools unavailable | Medium | Skill already has fallback to Bash lake build |

## Success Criteria

- [ ] `/lake` actually runs `lake build` command
- [ ] `/lake --dry-run` shows preview without changes
- [ ] `/lake --clean` runs `lake clean` first
- [ ] Error parsing and fixing loop executes
- [ ] Results are reported to user

## Implementation Notes

The key insight is that command files need explicit "EXECUTE NOW" directives because Claude Code loads them as context but doesn't automatically execute steps. The `/implement` command works because it has:

```markdown
**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.
```

And:

```markdown
**On GATE IN success**: Task validated. **IMMEDIATELY CONTINUE** to STAGE 2 below.
```

These explicit directives tell Claude to take action rather than just describe what should happen.
