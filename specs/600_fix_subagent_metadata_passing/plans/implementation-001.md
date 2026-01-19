# Implementation Plan: Task #600

- **Task**: 600 - Fix Subagent Metadata Passing in Agent System
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Priority**: high
- **Dependencies**: Task 599 (jq escaping workarounds)
- **Research Inputs**:
  - specs/600_fix_subagent_metadata_passing/reports/research-001.md (codebase analysis)
  - specs/600_fix_subagent_metadata_passing/reports/research-002.md (online research, hooks, file-based patterns)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, subagent-return.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The agent system currently suffers from two critical issues: (1) subagent JSON return blocks print to console as conversational text instead of being parsed as structured data, and (2) workflow interruptions requiring user "continue" input between skill return and orchestrator postflight. Research confirms these are fundamental Claude Code limitations (GitHub Issue #17351 - nested skills don't return to invoking skill context, Issue #8093 - no follow_up_prompt support).

This plan implements the recommended solution: **skill-internal postflight pattern** combined with **file-based metadata passing** and **SubagentStop hooks** to create fully autonomous, uninterrupted workflow execution.

### Research Integration

**Key findings from research-001.md**:
- Skill-internal postflight eliminates context transitions causing "continue" prompts
- JSON output is treated as conversational text (no structured output support in Task tool)
- Recommended: Move postflight operations into skills before returning

**Key findings from research-002.md**:
- GitHub Issue #17351 confirms nested skills return to main session, not invoking skill (known bug)
- SubagentStop hooks can force continuation with `exit code 2` or `{"decision": "block"}` JSON
- File-based metadata pattern avoids console pollution and enables reliable parsing
- Community pattern: agents write brief summaries (3-6 bullets) + metadata to files, not console JSON

## Goals & Non-Goals

**Goals**:
- Eliminate "continue" interruptions between skill return and postflight
- Remove JSON console output (agents return brief summaries instead)
- Enable reliable structured metadata exchange via files (state.json + .return-meta.json)
- Create SubagentStop hook to force continuation when postflight pending
- Maintain backward compatibility during gradual migration

**Non-Goals**:
- Fixing underlying Claude Code bugs (GitHub issues are closed/not planned)
- Implementing programmatic skill chaining (explicitly not supported)
- Creating new orchestrator layer (consolidating logic into skills instead)
- Changing subagent-return.md schema (still used internally by skills)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing workflows during transition | High | Medium | Implement incrementally (one skill at a time), test thoroughly, keep old patterns working |
| Infinite loops with SubagentStop hook | High | Medium | Check `stop_hook_active` flag, set max continuation count, use state file guards |
| Increased skill complexity | Medium | High | Create shared context files with reusable postflight patterns, document clearly |
| File-based metadata path conflicts | Low | Medium | Use predictable paths (`specs/{N}_{SLUG}/.return-meta.json`), validate file exists before reading |
| Hook configuration errors | Medium | Medium | Start with simple bash hooks (not prompt-based), test in isolation before deployment |

## Implementation Phases

### Phase 1: Create SubagentStop Hook Infrastructure [NOT STARTED]

**Goal**: Implement hook to prevent premature workflow termination when postflight operations are pending.

**Tasks**:
- [ ] Create `.claude/hooks/subagent-postflight.sh` script
  - Check for postflight marker file (`specs/.postflight-pending`)
  - Return `{"decision": "block", "reason": "Postflight operations pending"}` if file exists
  - Check `stop_hook_active` flag to prevent infinite loops
  - Set maximum continuation count (default: 3)
- [ ] Update `.claude/settings.json` with hook configuration
  - Add `SubagentStop` hook pointing to script
  - Set timeout to 30 seconds
- [ ] Create postflight marker file utility patterns
  - Document pattern for skills to create/remove marker file
  - Add to `.claude/context/core/patterns/postflight-control.md`
- [ ] Test hook in isolation with dummy skill

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/hooks/subagent-postflight.sh` (create)
- `.claude/settings.json` (add hook config)
- `.claude/context/core/patterns/postflight-control.md` (create)

**Verification**:
- Hook script runs without errors
- Hook correctly blocks when marker file present
- Hook correctly allows when marker file absent
- Hook respects `stop_hook_active` flag

---

### Phase 2: Define File-Based Metadata Protocol [NOT STARTED]

**Goal**: Establish standard for agents to write metadata to files instead of console output, enabling reliable structured data exchange.

**Tasks**:
- [ ] Define `.return-meta.json` schema in context file
  - Create `.claude/context/core/formats/return-metadata-file.md`
  - Specify fields: status, artifacts, next_steps, session_id, agent_type
  - Document path convention: `specs/{N}_{SLUG}/.return-meta.json`
- [ ] Extend state.json to include artifact summaries
  - Add `artifact_summary` field to artifacts array
  - Document pattern: "Brief 1-sentence description of artifact"
  - Update `.claude/rules/state-management.md` with new field
- [ ] Create helper patterns for file reading/writing
  - Document jq commands for reading metadata (using Task 599 escaping fixes)
  - Document safe file cleanup (delete after successful processing)
  - Add to `.claude/context/core/patterns/file-metadata-exchange.md`

**Timing**: 1 hour

**Files to modify**:
- `.claude/context/core/formats/return-metadata-file.md` (create)
- `.claude/rules/state-management.md` (update)
- `.claude/context/core/patterns/file-metadata-exchange.md` (create)

**Verification**:
- Schema is well-defined with examples
- state.json format updated with artifact_summary field
- Helper patterns are clear and use correct jq escaping

---

### Phase 3: Migrate skill-lean-research (Proof of Concept) [NOT STARTED]

**Goal**: Convert one skill to the new pattern as proof-of-concept, validating approach before wider rollout.

**Tasks**:
- [ ] Update skill-lean-research to include internal postflight
  - Add Stage 5: Parse Subagent Return (read .return-meta.json)
  - Add Stage 6: Update Task Status (status → researched)
  - Add Stage 7: Link Artifacts (update state.json with artifacts + summaries)
  - Add Stage 8: Git Commit (commit changes with session ID)
  - Add Stage 9: Cleanup (delete .return-meta.json)
  - Add Stage 10: Return Brief Summary (3-6 bullets, no JSON)
- [ ] Update lean-research-agent instructions
  - Remove JSON output from final return
  - Add instruction to write metadata to `.return-meta.json`
  - Change final output to brief summary (3-6 bullets)
  - Include artifact summaries in metadata file
- [ ] Add postflight marker file handling
  - Create marker before invoking agent
  - Remove marker after postflight completes
- [ ] Test full workflow: `/research N`
  - Verify no "continue" prompt appears
  - Verify status updates to researched
  - Verify artifacts linked in state.json with summaries
  - Verify git commit occurs
  - Verify no JSON console output

**Timing**: 2 hours

**Files to modify**:
- `.claude/skills/skill-lean-research/SKILL.md` (major refactor)
- `.claude/agents/lean-research-agent.md` (update return instructions)

**Verification**:
- `/research N` completes without user intervention
- Status transitions: not_started → researching → researched (no pause)
- state.json updated with artifact path + summary
- Git commit created with session ID
- Console output shows brief summary only (no JSON)
- .return-meta.json cleanup successful

---

### Phase 4: Migrate Remaining Delegating Skills [NOT STARTED]

**Goal**: Apply the proven pattern to all other skills that delegate to subagents.

**Tasks**:
- [ ] Migrate skill-researcher
  - Apply same pattern as skill-lean-research
  - Update general-research-agent return instructions
  - Test with `/research N` for non-Lean tasks
- [ ] Migrate skill-planner
  - Apply same pattern
  - Update planner-agent return instructions
  - Test with `/plan N`
- [ ] Migrate skill-implementer
  - Apply same pattern
  - Update general-implementation-agent return instructions
  - Test with `/implement N` for general tasks
- [ ] Migrate skill-lean-implementation
  - Apply same pattern
  - Update lean-implementation-agent return instructions
  - Test with `/implement N` for Lean tasks
- [ ] Migrate skill-latex-implementation
  - Apply same pattern
  - Update latex-implementation-agent return instructions
  - Test with `/implement N` for LaTeX tasks
- [ ] Migrate skill-meta
  - Apply same pattern
  - Update meta-builder-agent return instructions
  - Test with `/meta`

**Timing**: 1.5 hours (6 skills × 15 min each)

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md`
- `.claude/agents/general-research-agent.md`
- `.claude/skills/skill-planner/SKILL.md`
- `.claude/agents/planner-agent.md`
- `.claude/skills/skill-implementer/SKILL.md`
- `.claude/agents/general-implementation-agent.md`
- `.claude/skills/skill-lean-implementation/SKILL.md`
- `.claude/agents/lean-implementation-agent.md`
- `.claude/skills/skill-latex-implementation/SKILL.md`
- `.claude/agents/latex-implementation-agent.md`
- `.claude/skills/skill-meta/SKILL.md`
- `.claude/agents/meta-builder-agent.md`

**Verification**:
- Each command completes without "continue" prompt
- All status transitions occur automatically
- state.json updated with artifact summaries
- Git commits created with session IDs
- Console output shows brief summaries only

---

### Phase 5: Update Documentation and Create Troubleshooting Guide [NOT STARTED]

**Goal**: Document the new patterns and create comprehensive troubleshooting guide for common issues.

**Tasks**:
- [ ] Update `.claude/CLAUDE.md` with new workflow patterns
  - Document skill-internal postflight approach
  - Remove references to orchestrator postflight
  - Add section on file-based metadata exchange
  - Document SubagentStop hook usage
- [ ] Update `.claude/context/core/workflows/delegation.md`
  - Document new delegation flow (with internal postflight)
  - Add diagrams showing stage progression
  - Document marker file pattern
- [ ] Create troubleshooting guide
  - Create `.claude/context/core/troubleshooting/workflow-interruptions.md`
  - Document common issues (hook loops, missing markers, etc.)
  - Include diagnostic commands
  - List recovery procedures
- [ ] Update subagent-return.md
  - Clarify that JSON return is for skill consumption, not console output
  - Add note about file-based exchange
  - Update examples to show metadata file pattern

**Timing**: 1 hour

**Files to modify**:
- `.claude/CLAUDE.md` (update workflow section)
- `.claude/context/core/workflows/delegation.md` (update)
- `.claude/context/core/troubleshooting/workflow-interruptions.md` (create)
- `.claude/context/core/formats/subagent-return.md` (clarify)

**Verification**:
- Documentation accurately reflects new patterns
- Examples are clear and correct
- Troubleshooting guide covers observed issues
- New users can understand workflow from docs

## Testing & Validation

- [ ] Full workflow test: `/research N` (Lean task)
- [ ] Full workflow test: `/research N` (general task)
- [ ] Full workflow test: `/plan N`
- [ ] Full workflow test: `/implement N` (Lean task)
- [ ] Full workflow test: `/implement N` (general task)
- [ ] Full workflow test: `/implement N` (LaTeX task)
- [ ] Full workflow test: `/meta` interactive mode
- [ ] Hook behavior: Test with marker file present (should block)
- [ ] Hook behavior: Test with marker file absent (should allow)
- [ ] Hook behavior: Test `stop_hook_active` flag (should allow to prevent loop)
- [ ] File cleanup: Verify .return-meta.json deleted after processing
- [ ] Error handling: Test with missing .return-meta.json (skill should fail gracefully)
- [ ] state.json validation: Verify artifact_summary field populated correctly
- [ ] Console output: Verify no JSON blocks appear in any workflow

## Artifacts & Outputs

- `.claude/hooks/subagent-postflight.sh` - SubagentStop hook script
- `.claude/settings.json` - Hook configuration
- `.claude/context/core/patterns/postflight-control.md` - Marker file pattern docs
- `.claude/context/core/formats/return-metadata-file.md` - Metadata file schema
- `.claude/context/core/patterns/file-metadata-exchange.md` - File I/O helpers
- `.claude/context/core/troubleshooting/workflow-interruptions.md` - Troubleshooting guide
- Updated skill files (7 skills)
- Updated agent files (6 agents)
- Updated documentation (CLAUDE.md, delegation.md, state-management.md, subagent-return.md)
- specs/600_fix_subagent_metadata_passing/summaries/implementation-summary-{DATE}.md - Final summary

## Rollback/Contingency

If implementation causes critical failures:

1. **Immediate rollback**:
   - Remove hook configuration from settings.json
   - Git revert commits for modified skills/agents
   - Restore original workflow patterns

2. **Partial rollback** (if some skills work, others fail):
   - Keep working skills on new pattern
   - Revert failing skills to old pattern
   - Document which skills use which pattern in CLAUDE.md

3. **Hook-only rollback** (if hook causes loops):
   - Remove SubagentStop hook from settings.json
   - Keep skill-internal postflight pattern (still beneficial)
   - Accept "continue" prompts as temporary workaround

4. **Recovery from infinite loop**:
   - Ctrl+C to interrupt
   - Remove `.claude/hooks/subagent-postflight.sh`
   - Delete marker file: `rm specs/.postflight-pending`
   - Restart Claude Code session

**Monitoring**: Watch for errors in workflow execution during first week post-deployment. Create Task 601 if critical issues arise requiring further fixes.
