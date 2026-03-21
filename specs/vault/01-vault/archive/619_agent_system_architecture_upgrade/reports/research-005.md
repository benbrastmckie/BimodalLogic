# Research Report: Task #619 - Context Fork Empirical Testing

**Task**: Agent system architecture upgrade (context:fork migration)
**Date**: 2026-01-28
**Focus**: Empirical validation of context:fork functionality via test-lean-research skill

## Summary

Empirical testing of the `context: fork` feature via the test-lean-research skill confirms that context isolation is **not working** in the current Claude Code version. The test definitively demonstrates that forked skills receive full parent context and unrestricted tool access, contradicting the documented behavior. This validates the current production implementation strategy (direct execution for Lean skills, Task tool delegation for others) and confirms that context:fork migration should be deferred until the feature is fixed.

## Test Methodology

### Test Setup

Created a controlled A/B test comparing three implementations:
1. **test-context-fork** - Basic skill with `context: fork` (no MCP tools)
2. **test-lean-research** - Full skill with `context: fork` + Lean MCP tools
3. **skill-lean-research** - Production skill with direct execution

Test execution: `/test-lean-research 658` (invokes test-lean-research skill on task 658)

### Expected vs Actual Behavior

| Aspect | Expected (per docs) | Actual (observed) |
|--------|---------------------|-------------------|
| Context visibility | Only skill instructions + arguments | Full parent context (43K+ tokens) |
| Tool access | Only `allowed-tools` from frontmatter | All session tools available |
| Execution mode | Isolated subprocess | Inline main conversation thread |
| MCP tools | Available (if in allowed-tools) | ✅ Available and functional |

## Findings

### 1. Context Isolation: FAILED ❌

**Evidence from test output:**
- Skill had access to full CLAUDE.md content (~20K tokens)
- Skill could read state.json and TODO.md
- Total visible context: 43K+ tokens from parent conversation

**Implication**: The `context: fork` feature provides **zero context isolation**. Skills execute with full parent context, making the token efficiency benefit completely unavailable.

### 2. Tool Access: UNRESTRICTED

**Evidence:**
- Skill frontmatter declared specific `allowed-tools`
- All session tools were available (Read, Write, Edit, Bash, Grep, Glob, etc.)
- No tool access restrictions enforced

**Implication**: The security/isolation boundary provided by `allowed-tools` is not enforced in forked context.

### 3. Execution Mode: INLINE

**Evidence:**
- Skill executed in main conversation thread
- No subprocess isolation observed
- Direct access to parent conversation state

**Implication**: No process isolation benefits realized.

### 4. MCP Tool Access: SUCCESS ✅

**Positive finding:**
- lean_local_search worked correctly
- Read tool accessed Lean source files
- Bash executed lake commands successfully

**Implication**: MCP tools **are** accessible in skills with `context: fork`, just without the isolation.

## Comparison: Three Implementation Patterns

| Pattern | Context Isolation | MCP Access | Production Readiness |
|---------|------------------|------------|---------------------|
| `context: fork` (test-lean-research) | ❌ Failed | ✅ Works | ❌ No - broken feature |
| Direct execution (skill-lean-research) | N/A (intentional) | ✅ Works | ✅ Yes - current production |
| Task tool delegation (skill-researcher) | ✅ Works | ❌ Blocked (subagent issue) | ✅ Yes - for non-MCP skills |

## Production Implementation Validation

### Current Strategy is Correct

The test **validates** the current production implementation approach:

1. **Lean skills (skill-lean-research, skill-lean-implementation)**:
   - Use direct execution (no context:fork, no Task delegation)
   - Reason: Need MCP tools + subagent delegation breaks MCP (bugs #15945, #13254, #4580)
   - **Status**: Correct approach confirmed

2. **Non-Lean skills (skill-researcher, skill-planner, skill-implementer)**:
   - Use Task tool delegation to spawn subagents
   - Reason: Provides real context isolation + no MCP dependency
   - **Status**: Correct approach confirmed

3. **DO NOT use context:fork**:
   - Provides no isolation benefits
   - Adds complexity without value
   - **Status**: Recommendation confirmed

## Related Issues

### Claude Code GitHub Issues

1. **#16803** - Context fork feature broken (mentioned in research-002.md)
   - Status: Still unfixed as of 2026-01-28
   - Impact: context:fork unusable

2. **#15945, #13254, #4580** - MCP tools hang in subagents
   - Status: Led to direct execution migration for Lean skills
   - Impact: Prevents Task delegation for MCP-dependent skills

## Recommendations

### Immediate Actions (Current)

1. ✅ **Keep direct execution** for skill-lean-research and skill-lean-implementation
2. ✅ **Keep Task delegation** for non-MCP skills (researcher, planner, implementer)
3. ✅ **Do NOT adopt context:fork** for any production skills

### Future Migration Path

Only consider context:fork migration after:

1. **Verification**: Claude Code GitHub issue #16803 is closed as fixed
2. **Testing**: Re-run test-lean-research to confirm isolation works
3. **Validation**: Verify MCP tools still function in truly forked context
4. **Gradual rollout**: Start with non-critical skills, monitor for regressions

### Test Infrastructure

The test-lean-research skill provides reusable infrastructure:
- Keep skill in `.claude/skills/test-lean-research/` for future validation
- Use `/test-lean-research N` to validate context:fork after Claude Code updates
- Compare against production skill-lean-research to verify parity

## Artifacts Generated

### Test Skill
- **Path**: `.claude/skills/test-lean-research/skill-test-lean-research.md`
- **Purpose**: Reusable test harness for context:fork validation
- **Status**: Retained for future testing

### Test Output
- **Path**: `.claude/output/test-lean-research.md`
- **Content**: Full test execution results with evidence
- **Status**: Preserved for documentation

## Conclusion

The empirical test provides definitive evidence that `context: fork` is non-functional in the current Claude Code version. The feature:
- Does not provide context isolation
- Does not restrict tool access
- Does not create subprocess isolation
- Does work with MCP tools (when it's eventually fixed)

**Migration recommendation**: **Do not migrate** to context:fork until the feature is fixed and re-validated. The current production implementation (direct execution for MCP skills, Task delegation for others) is the correct architecture.

## Next Steps

1. ✅ Document findings in task 619 artifacts
2. ✅ Update CLAUDE.md to reflect confirmed approach (if not already current)
3. 🔄 Monitor Claude Code releases for context:fork fixes
4. 🔄 Re-run test-lean-research after major Claude Code updates
5. 🔄 Consider migration only after successful re-validation

## References

- Test skill: `.claude/skills/test-lean-research/skill-test-lean-research.md`
- Test output: `.claude/output/test-lean-research.md`
- Production skill: `.claude/skills/skill-lean-research/skill-lean-research.md`
- Previous research: research-001.md through research-004.md
- Claude Code issue: https://github.com/anthropics/claude-code/issues/16803
- MCP hanging issues: #15945, #13254, #4580
