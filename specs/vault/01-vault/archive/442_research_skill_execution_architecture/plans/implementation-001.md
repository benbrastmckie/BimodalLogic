# Implementation Plan: Task #438

**Task**: Fix skill/agent execution architecture
**Version**: 001
**Created**: 2026-01-12
**Language**: meta

## Overview

This plan implements the **Option D (Hybrid)** recommendation from research: fix agent registration via YAML frontmatter, fix session ID generation, and validate the complete workflow. The root cause of observed failures is that custom agents lack frontmatter, so Claude Code doesn't register them as valid `subagent_type` values.

**Key Changes**:
1. Add YAML frontmatter to all 7 agent files in `.claude/agents/`
2. Fix session ID generation to use portable command (no `xxd`)
3. Validate end-to-end workflow with registered agents

**Estimated Total Effort**: 3-4 hours

---

## Phases

### Phase 1: Add YAML Frontmatter to Agent Files

**Estimated effort**: 1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Add properly formatted YAML frontmatter to all 7 agent files
2. Include required fields: name, description
3. Preserve existing agent content after frontmatter

**Files to modify**:
- `.claude/agents/lean-research-agent.md`
- `.claude/agents/lean-implementation-agent.md`
- `.claude/agents/general-research-agent.md`
- `.claude/agents/general-implementation-agent.md`
- `.claude/agents/latex-implementation-agent.md`
- `.claude/agents/planner-agent.md`
- `.claude/agents/meta-builder-agent.md`

**Steps**:

1. For each agent file, add frontmatter at the very beginning:
   ```yaml
   ---
   name: {filename-without-extension}
   description: {one-line from Overview section}
   ---
   ```

2. Frontmatter values for each file:

   | File | name | description |
   |------|------|-------------|
   | lean-research-agent.md | lean-research-agent | Research Lean 4 and Mathlib for theorem proving tasks |
   | lean-implementation-agent.md | lean-implementation-agent | Implement Lean 4 proofs following implementation plans |
   | general-research-agent.md | general-research-agent | Research general tasks using web search and codebase exploration |
   | general-implementation-agent.md | general-implementation-agent | Implement general, meta, and markdown tasks from plans |
   | latex-implementation-agent.md | latex-implementation-agent | Implement LaTeX documents following implementation plans |
   | planner-agent.md | planner-agent | Create phased implementation plans from research findings |
   | meta-builder-agent.md | meta-builder-agent | Interactive system builder for .claude/ architecture changes |

3. Verify each file starts with `---` (frontmatter delimiter)

**Verification**:
- Each agent file begins with valid YAML frontmatter
- Frontmatter has `name` and `description` fields
- Content after frontmatter is preserved unchanged

---

### Phase 2: Test Agent Registration

**Estimated effort**: 30 minutes
**Status**: [PARTIAL - requires session restart]

**Objectives**:
1. Verify agents are recognized as valid subagent_type values
2. Test that Task tool can invoke custom agents
3. Document any issues for troubleshooting

**Steps**:

1. Note: Claude Code session must be restarted after Phase 1 for agents to register

2. Test agent recognition by attempting Task tool call:
   ```
   Task(subagent_type="planner-agent", prompt="Confirm you are planner-agent. Return a JSON object with your agent name.")
   ```

3. If test succeeds:
   - Agent is registered correctly
   - Proceed to Phase 3

4. If test fails with "Agent type not found":
   - Check frontmatter syntax (must have `---` delimiters)
   - Check `name` field matches exactly what's used in subagent_type
   - Try without `model` or `tools` fields (may not be required)
   - Document specific error for troubleshooting

5. Test at least 2 agents to confirm pattern works:
   - `planner-agent` (used by /plan)
   - `lean-research-agent` (used by /research for lean tasks)

**Verification**:
- At least one custom agent recognized by Task tool
- Agent executes and returns response
- No "Agent type not found" errors for registered agents

---

### Phase 3: Fix Session ID Generation

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Update checkpoint-gate-in.md with portable session ID command
2. Ensure command works on NixOS (no `xxd` dependency)

**Files to modify**:
- `.claude/context/core/checkpoints/checkpoint-gate-in.md`

**Steps**:

1. Read current checkpoint-gate-in.md

2. Find the session ID generation section (should be under "### 1. Generate Session ID")

3. Replace the command:
   ```bash
   # OLD (breaks on NixOS - xxd not available)
   session_id="sess_$(date +%s)_$(head -c 3 /dev/urandom | xxd -p)"

   # NEW (portable - works on NixOS, macOS, Linux)
   session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
   ```

4. Verify the new command works:
   ```bash
   echo "sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
   ```
   Should output something like: `sess_1768249204_ba78e9`

**Verification**:
- checkpoint-gate-in.md has updated command
- Command produces valid session ID format
- No `xxd` dependency

---

### Phase 4: Validate End-to-End Workflow

**Estimated effort**: 1 hour
**Status**: [PARTIAL - requires session restart]

**Objectives**:
1. Test complete /research -> /plan -> /implement cycle
2. Verify agent delegation works correctly
3. Confirm artifact linking and status updates work

**Steps**:

1. Create a simple test task (or use existing low-priority task)

2. Run `/research {N}` and verify:
   - Session ID generated correctly
   - Status updates to RESEARCHING then RESEARCHED
   - Research report created and linked
   - Git commit succeeds

3. Run `/plan {N}` and verify:
   - Delegation to planner-agent works (if registered)
   - OR falls back to general-purpose gracefully
   - Plan file created and linked
   - Git commit succeeds

4. If agents registered successfully, verify skill->agent delegation:
   - Check that skills with `context: fork` and `agent: xxx` trigger subagent
   - Confirm structured return is captured

5. Document any remaining issues in errors.json

**Verification**:
- Full workflow completes without manual intervention
- Artifacts created and linked correctly
- Status updates work in both state.json and TODO.md
- Git commits include session ID

---

### Phase 5: Update Documentation

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Document the frontmatter requirement for custom agents
2. Update any incorrect documentation about agent registration
3. Note lessons learned

**Files to modify**:
- `.claude/CLAUDE.md` - Add note about agent frontmatter requirement

**Steps**:

1. Add section or update existing section in CLAUDE.md about agent registration:
   ```markdown
   ### Custom Agent Registration

   Custom agents in `.claude/agents/` require YAML frontmatter to register:

   ```yaml
   ---
   name: {agent-name}
   description: {one-line description}
   ---
   ```

   Without frontmatter, Claude Code ignores the agent files.
   ```

2. Verify skill-to-agent mapping table in CLAUDE.md is accurate

3. Create implementation summary

**Verification**:
- CLAUDE.md documents frontmatter requirement
- No misleading documentation about automatic agent registration

---

## Dependencies

| Phase | Depends On | Reason |
|-------|-----------|--------|
| Phase 2 | Phase 1 | Agents must have frontmatter before testing registration |
| Phase 3 | None | Independent fix |
| Phase 4 | Phase 1, 2 | Need registered agents for full validation |
| Phase 5 | Phase 4 | Document based on validation results |

**Recommended Execution Order**:
1. Phase 1 (add frontmatter) - can run immediately
2. Phase 3 (fix session ID) - can run in parallel with Phase 1
3. *Restart Claude Code session*
4. Phase 2 (test registration)
5. Phase 4 (validate end-to-end)
6. Phase 5 (documentation)

---

## Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Frontmatter format incorrect | High | Medium | Test immediately after Phase 1; check Claude Code docs for exact format |
| Agents still not recognized | High | Low | Fall back to general-purpose; investigate further |
| Session ID command fails | Medium | Low | Test command in isolation first |
| Skill-agent link still broken | Medium | Low | Skills already have correct fields; issue is registration |

---

## Success Criteria

After implementation, the following must be true:

- [ ] All 7 agent files have valid YAML frontmatter with `name` and `description`
- [ ] At least one custom agent (`planner-agent`) recognized by Task tool
- [ ] Session ID generation uses portable `od` command
- [ ] checkpoint-gate-in.md updated with portable command
- [ ] `/plan` command works without "Agent type not found" error
- [ ] CLAUDE.md documents frontmatter requirement
- [ ] Implementation summary created

**Key Metric**: Custom agents appear in available subagent_type list after session restart.
