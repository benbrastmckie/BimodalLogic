# Implementation Plan: Task #688

- **Task**: 688 - Add zombie cleanup and timeout protection to Lean implementation skill
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/688_add_zombie_cleanup_timeout_protection_lean_skill/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan implements a three-layer defense against MCP-induced agent hangs in skill-lean-implementation. The lean-lsp MCP server spawns lake build processes that become zombies when not properly reaped, blocking subsequent MCP calls indefinitely. The solution adds: (1) pre-flight zombie cleanup using a new script modeled on claude-refresh.sh, (2) integration of cleanup into skill preflight, (3) age-based deadlock detection in the postflight hook. Per-call timeout handling in the agent is deferred as it requires MCP protocol changes not currently available.

### Research Integration

Key findings from research-001.md:
- Root cause: lean-lsp MCP server spawns `lake` subprocesses that become zombies when not reaped
- Current state: 5 zombie lake processes detected, loop guard triggering at 3 iterations
- Must kill parent process to clear zombies (zombies themselves are already dead)
- Existing claude-refresh.sh provides battle-tested process cleanup patterns
- Safety requirements: preserve active sessions, age threshold, TTY checks

## Goals & Non-Goals

**Goals**:
- Prevent MCP-induced hangs from accumulating zombie lake processes
- Automatically clean zombie-bearing lean-lsp-mcp processes before agent starts
- Detect deadlocked sessions via age-based marker file analysis
- Preserve active Lean sessions during cleanup

**Non-Goals**:
- Fix lean-lsp MCP server zombie reaping bug (external dependency)
- Implement per-MCP-call timeouts in agent (requires MCP protocol changes)
- Guarantee zero hangs (defense in depth reduces probability)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Killing active Lean sessions | High | Low | TTY check, age threshold, process tree exclusion |
| Script fails to clean zombies | Low | Medium | Kill parent (guaranteed cleanup), non-fatal continuation |
| Race with active MCP call | Medium | Low | Run in preflight before agent starts |
| Marker age detection too aggressive | Medium | Low | Conservative 5-minute threshold |

## Implementation Phases

### Phase 1: Create Zombie Cleanup Script [NOT STARTED]

**Goal**: Create `.claude/scripts/lean-zombie-cleanup.sh` modeled on claude-refresh.sh patterns

**Tasks**:
- [ ] Create lean-zombie-cleanup.sh with safety checks
- [ ] Implement lean-lsp-mcp process identification
- [ ] Implement zombie child detection (ps --ppid with Z state)
- [ ] Implement age threshold check (default 1 hour)
- [ ] Implement TTY/orphan detection
- [ ] Add dry-run mode for testing
- [ ] Add verbose logging for diagnostics

**Timing**: 1.5 hours

**Files to create**:
- `.claude/scripts/lean-zombie-cleanup.sh` - Main cleanup script

**Verification**:
- Script runs without errors with no lean processes
- Script identifies current zombie-bearing lean-lsp processes
- Dry-run mode shows what would be killed without acting
- Age threshold prevents cleanup of recent processes

---

### Phase 2: Integrate Preflight Cleanup into Skill [NOT STARTED]

**Goal**: Add Stage 2.5 to skill-lean-implementation that calls cleanup before Task delegation

**Tasks**:
- [ ] Add Stage 2.5 section to SKILL.md after Stage 2
- [ ] Add conditional script execution with error handling
- [ ] Make cleanup non-blocking (log errors but continue)
- [ ] Update execution flow documentation

**Timing**: 1 hour

**Files to modify**:
- `.claude/skills/skill-lean-implementation/SKILL.md` - Add Stage 2.5 preflight cleanup

**Verification**:
- SKILL.md correctly documents new stage
- Skill continues if cleanup script is missing
- Skill continues if cleanup fails

---

### Phase 3: Enhance Loop Guard with Age Detection [NOT STARTED]

**Goal**: Add marker file age-based deadlock detection to postflight hook

**Tasks**:
- [ ] Add marker age calculation using jq timestamp parsing
- [ ] Add deadlock detection threshold (5 minutes)
- [ ] Force cleanup when marker exceeds age threshold
- [ ] Log deadlock events for diagnostics
- [ ] Update loop guard logic to check age before iteration count

**Timing**: 1 hour

**Files to modify**:
- `.claude/hooks/subagent-postflight.sh` - Add age-based deadlock detection

**Verification**:
- Old markers (>5 min) trigger cleanup
- Recent markers continue normal processing
- Deadlock events are logged

---

### Phase 4: Documentation and Testing [NOT STARTED]

**Goal**: Document the changes and verify end-to-end functionality

**Tasks**:
- [ ] Add zombie cleanup to CLAUDE.md Session Maintenance section
- [ ] Create manual test procedure for zombie cleanup
- [ ] Verify cleanup runs on /implement invocation
- [ ] Verify deadlock detection with simulated old marker
- [ ] Test with actual zombie processes (if available)

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/CLAUDE.md` - Add zombie cleanup documentation (optional, review at /todo)

**Verification**:
- Manual test procedure documented
- End-to-end test passes
- No regressions in normal /implement workflow

---

## Testing & Validation

- [ ] lean-zombie-cleanup.sh exits cleanly with no lean processes
- [ ] lean-zombie-cleanup.sh identifies zombie-bearing processes
- [ ] lean-zombie-cleanup.sh respects age threshold
- [ ] lean-zombie-cleanup.sh dry-run mode works correctly
- [ ] skill-lean-implementation Stage 2.5 executes cleanup
- [ ] skill-lean-implementation continues if cleanup fails
- [ ] subagent-postflight.sh detects old markers
- [ ] subagent-postflight.sh logs deadlock events
- [ ] Full /implement workflow still works normally

## Artifacts & Outputs

- `.claude/scripts/lean-zombie-cleanup.sh` - New cleanup script
- `.claude/skills/skill-lean-implementation/SKILL.md` - Updated with Stage 2.5
- `.claude/hooks/subagent-postflight.sh` - Updated with age detection
- `specs/688_add_zombie_cleanup_timeout_protection_lean_skill/summaries/implementation-summary-{DATE}.md` - Completion summary

## Rollback/Contingency

If implementation causes issues:
1. Remove Stage 2.5 from skill-lean-implementation/SKILL.md
2. Revert age detection changes in subagent-postflight.sh
3. lean-zombie-cleanup.sh can remain (not called if Stage 2.5 removed)

The changes are isolated to:
- One new script (additive, no impact if not called)
- One new stage in skill (can be commented out)
- One enhancement to hook (can be reverted independently)
