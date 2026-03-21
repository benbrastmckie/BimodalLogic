# Implementation Plan: Task #712

- **Task**: 712 - Create /lean-research command with context:fork
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None (test-context-fork basic test skill exists)
- **Research Inputs**:
  - specs/619_agent_system_architecture_upgrade/reports/research-003.md
  - specs/619_agent_system_architecture_upgrade/reports/research-004.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create a controlled A/B test for the `context: fork` feature by implementing a new `/lean-research` command that routes to a test skill using `context: fork`. This allows testing context:fork with full Lean MCP tooling in isolation without modifying the production `skill-lean-research` skill. The existing `test-context-fork` skill tests basic context isolation; this test extends that to verify context:fork works with the full Lean MCP toolset.

### Research Integration

Research from Task 619 (research-003.md, research-004.md) found:
- GitHub issue #16803 remains OPEN but `context: fork` reportedly works for user-level skills (not plugins)
- ProofChecker uses user-level skills, making testing viable
- Direct execution skills (like skill-lean-research) would benefit from context:fork to avoid context bloat
- Testing recommended before production adoption

## Goals & Non-Goals

**Goals**:
- Create test-lean-research skill with `context: fork` and full Lean MCP allowed-tools
- Set up routing from `/lean-research` command to the test skill
- Enable controlled comparison between direct execution (production) and context:fork (test)
- Preserve production skill-lean-research unchanged

**Non-Goals**:
- Modifying production skill-lean-research
- Full migration of all skills to context:fork
- Performance benchmarking (qualitative testing only)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| context:fork feature broken | Test skill fails to run | Medium | Simple revert - test skill only |
| MCP tools don't work with context:fork | Skill runs but tools fail | Medium | Clearly separated test path, easy to diagnose |
| Command routing conflict | /lean-research conflicts with existing commands | Low | Check for existing commands before creating |

## Implementation Phases

### Phase 1: Create test-lean-research Skill [COMPLETED]

**Goal**: Create a copy of skill-lean-research that uses `context: fork` instead of direct execution

**Tasks**:
- [ ] Create skill directory: `.claude/skills/test-lean-research/`
- [ ] Create SKILL.md with:
  - Frontmatter with `context: fork` added
  - Same `allowed-tools` as skill-lean-research (full Lean MCP toolset)
  - Same `description` with "(context:fork test)" suffix
  - `user-invocable: true` for direct `/lean-research` invocation
- [ ] Copy execution flow from skill-lean-research
- [ ] Add test-specific context reporting (what context is visible)

**Timing**: 30 minutes

**Files to create**:
- `.claude/skills/test-lean-research/SKILL.md` - Test skill definition

**Verification**:
- Skill file exists and has valid YAML frontmatter
- `context: fork` is present in frontmatter
- All MCP tools from production skill are in allowed-tools

---

### Phase 2: Set Up Command Routing [COMPLETED]

**Goal**: Enable `/lean-research` command to invoke the test skill

**Tasks**:
- [ ] Verify skill name in frontmatter matches expected command pattern
- [ ] Test that `/lean-research` invokes the test skill (Claude Code automatically routes `/skill-name` commands)
- [ ] Document invocation syntax: `/lean-research N [focus]` for task N

**Timing**: 15 minutes

**Files to modify**:
- None (Claude Code auto-routes based on skill name)

**Note**: Claude Code automatically creates commands from skill names. The skill `test-lean-research` will be invocable as `/test-lean-research`. For clarity we use the base name pattern, but the actual command will be `/test-lean-research`.

**Verification**:
- Running `/test-lean-research` invokes the skill
- Skill has access to allowed-tools only (not main session tools)

---

### Phase 3: Verification Testing [COMPLETED]

**Goal**: Verify context:fork works correctly with Lean MCP tools

**Tasks**:
- [ ] Run `/test-lean-research` with a simple Lean task number
- [ ] Verify context isolation (skill reports no parent context visible)
- [ ] Verify MCP tool access (lean_local_search, lean_leansearch, etc.)
- [ ] Verify results return cleanly to main conversation
- [ ] Compare context bloat between production and test skill
- [ ] Document test results in task summary

**Timing**: 45 minutes

**Test Script**:
```
1. Note current context size (if observable)
2. Run: /test-lean-research {lean_task_number}
3. Observe: Does skill see parent conversation?
4. Observe: Can skill call lean_local_search?
5. Observe: Can skill call lean_leansearch?
6. Observe: Does result return to main context?
7. Note final context size
```

**Verification**:
- Skill executes with context isolation
- MCP tools are accessible
- Results return without error
- Main conversation not polluted with skill internals

## Testing & Validation

- [ ] Skill file passes frontmatter validation (valid YAML)
- [ ] Skill can be invoked via `/test-lean-research`
- [ ] Context isolation works (skill cannot see parent messages)
- [ ] At least one Lean MCP tool callable from skill
- [ ] Results return to main conversation
- [ ] No changes to production skill-lean-research

## Artifacts & Outputs

- `.claude/skills/test-lean-research/SKILL.md` - Test skill with context:fork
- `specs/712_create_lean_research_command_with_context_fork/summaries/implementation-summary-{DATE}.md` - Completion summary with test results

## Rollback/Contingency

If context:fork does not work:
1. Delete `.claude/skills/test-lean-research/` directory
2. Document negative finding in task summary
3. Keep production skill-lean-research unchanged
4. Report back to Task 619 that context:fork is not ready for Lean skills

If partial success (context:fork works but MCP tools fail):
1. Document which tools work/fail
2. Compare with test-context-fork results
3. Consider whether partial MCP access is useful for testing
