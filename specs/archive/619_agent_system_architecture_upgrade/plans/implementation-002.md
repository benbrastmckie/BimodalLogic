# Implementation Plan: Task #619 (Revised)

- **Task**: 619 - agent_system_architecture_upgrade
- **Version**: 002
- **Status**: [NOT STARTED]
- **Effort**: 3 hours (reduced from 5 hours)
- **Priority**: Low (deferred until context:fork bug fixed)
- **Dependencies**: Anthropic fixing GitHub issue #16803
- **Research Inputs**: research-001.md, research-002.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan has been revised to focus on a **FUTURE upgrade** to the agent system architecture once the `context: fork` feature in Claude Code is fixed (GitHub #16803). The current system works correctly using Task tool delegation as the official workaround.

### Revision Rationale

Research-002.md confirmed:
1. `context: fork` IS a real Claude Code feature (added v2.1.0)
2. The feature is currently BROKEN (GitHub #16803)
3. The ProofChecker's Task tool delegation pattern is the CORRECT workaround
4. Current architecture should remain unchanged until bug is fixed

### What Changed from v001

| Aspect | v001 | v002 |
|--------|------|------|
| Scope | Immediate refactoring | Future upgrade after bug fix |
| CLAUDE.md reduction | Yes (Priority 1) | Deferred (current size acceptable) |
| state.json enhancement | Yes (Priority 2) | Keep as optional future work |
| context:fork references | Remove them | Document bug status instead |
| Trigger condition | Ready now | Wait for #16803 fix |

## Goals & Non-Goals

**Goals** (for future implementation):
- Migrate skills from Task tool delegation to native `context: fork`
- Simplify skill bodies by removing manual Task tool invocation
- Use `agent:` frontmatter field for subagent routing
- Document migration path for other projects

**Non-Goals** (until bug is fixed):
- Any changes to current working architecture
- CLAUDE.md reduction (current size is functional)
- state.json schema changes (current schema is sufficient)
- Removing Task tool delegation pattern (it works)

## Preconditions

**This plan should NOT be implemented until:**

1. GitHub issue #16803 is marked as RESOLVED
2. A Claude Code release confirms `context: fork` works
3. User verifies the fix in a test skill

**How to check status:**
```bash
# Check GitHub issue status
gh issue view 16803 --repo anthropics/claude-code --json state,title
```

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Bug never gets fixed | Low | Low | Current pattern is sustainable |
| Fix introduces new bugs | Medium | Medium | Test thoroughly before migrating |
| API changes with fix | Medium | Medium | Read release notes carefully |
| Partial migration breaks system | High | Low | Migrate one skill at a time |

## Implementation Phases

### Phase 1: Verify Bug Fix [NOT STARTED]

**Precondition**: GitHub #16803 marked RESOLVED

**Goal**: Confirm `context: fork` works correctly in the ProofChecker environment.

**Tasks**:
- [ ] Update Claude Code to latest version with the fix
- [ ] Create a test skill with `context: fork` frontmatter
- [ ] Verify the skill runs in isolated context
- [ ] Verify skill cannot access parent conversation history
- [ ] Document any quirks or requirements

**Timing**: 0.5 hours

**Test skill template**:
```yaml
---
name: test-context-fork
description: Test skill to verify context:fork is working
context: fork
agent: Explore
---

# Test Context Fork

This skill tests whether context:fork properly isolates the conversation.

## Verification Steps

1. Run `/test-context-fork`
2. Check if skill can access messages from before invocation (should NOT)
3. Check if skill results pollute main context (should NOT)
```

**Verification**:
- Test skill runs in isolated context
- No parent context leakage
- Clean return to main conversation

---

### Phase 2: Migrate One Skill [NOT STARTED]

**Precondition**: Phase 1 verification passed

**Goal**: Migrate skill-researcher to use native context:fork.

**Tasks**:
- [ ] Update skill-researcher SKILL.md frontmatter
- [ ] Add `context: fork` and `agent: general-research-agent`
- [ ] Remove manual Task tool invocation from skill body
- [ ] Update skill to return results via file-based exchange
- [ ] Test full research workflow
- [ ] Compare results with old pattern

**Timing**: 1 hour

**Before (current pattern)**:
```yaml
---
name: skill-researcher
description: General research skill
allowed-tools: Task
---
# Skill body manually invokes Task tool
```

**After (native context:fork)**:
```yaml
---
name: skill-researcher
description: General research skill
context: fork
agent: general-research-agent
---
# Skill body is simpler - no manual Task invocation needed
```

**Verification**:
- /research command works correctly
- Research report created
- Context isolation verified
- No regressions

---

### Phase 3: Migrate Remaining Skills [NOT STARTED]

**Precondition**: Phase 2 migration successful

**Goal**: Migrate all delegating skills to native context:fork.

**Tasks**:
- [ ] Migrate skill-lean-research
- [ ] Migrate skill-planner
- [ ] Migrate skill-implementer
- [ ] Migrate skill-lean-implementation
- [ ] Migrate skill-latex-implementation
- [ ] Migrate skill-meta
- [ ] Test each skill individually
- [ ] Run full workflow tests

**Timing**: 1.5 hours

**Skills to migrate**:

| Skill | Current Agent | context: fork | agent: |
|-------|---------------|---------------|--------|
| skill-researcher | general-research-agent | fork | general-research-agent |
| skill-lean-research | lean-research-agent | fork | lean-research-agent |
| skill-planner | planner-agent | fork | planner-agent |
| skill-implementer | general-implementation-agent | fork | general-implementation-agent |
| skill-lean-implementation | lean-implementation-agent | fork | lean-implementation-agent |
| skill-latex-implementation | latex-implementation-agent | fork | latex-implementation-agent |
| skill-meta | meta-builder-agent | fork | meta-builder-agent |

**Verification**:
- All /research, /plan, /implement commands work
- All language-specific routing works
- No context pollution in main conversation

---

## Testing & Validation

- [ ] Phase 1: context:fork works in isolation test
- [ ] Phase 2: skill-researcher migrated and working
- [ ] Phase 3: All skills migrated and working
- [ ] Full workflow: /task → /research → /plan → /implement
- [ ] Context isolation: main conversation not polluted
- [ ] Recovery: interrupted operations can resume

## Artifacts & Outputs

When implemented:
- `.claude/skills/skill-researcher/SKILL.md` - Updated frontmatter
- `.claude/skills/skill-lean-research/SKILL.md` - Updated frontmatter
- `.claude/skills/skill-planner/SKILL.md` - Updated frontmatter
- `.claude/skills/skill-implementer/SKILL.md` - Updated frontmatter
- `.claude/skills/skill-lean-implementation/SKILL.md` - Updated frontmatter
- `.claude/skills/skill-latex-implementation/SKILL.md` - Updated frontmatter
- `.claude/skills/skill-meta/SKILL.md` - Updated frontmatter
- `.claude/context/core/architecture/system-overview.md` - Updated documentation

## Rollback/Contingency

If migration fails:
1. Revert skill frontmatter changes
2. Restore Task tool invocation pattern
3. The old pattern will continue working

Both patterns can coexist, so partial migration is safe.

## Monitoring

After implementation:
- Monitor for context pollution issues
- Track any skill execution failures
- Compare token usage before/after (context:fork should be more efficient)

## Related Tasks

- None currently - this task is self-contained future work

## Status Tracking

**When to revisit this plan:**
```bash
# Set a reminder to check bug status
gh issue view 16803 --repo anthropics/claude-code --json state
```

**Current bug status (as of 2026-01-19):** OPEN

**Next check date:** 2026-02-01 (or when Claude Code 2.2.0 releases)
