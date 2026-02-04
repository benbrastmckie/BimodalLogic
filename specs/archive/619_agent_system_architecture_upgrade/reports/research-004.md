# Research Report: Task #619 - Context Fork for Direct Execution Skills

**Task**: 619 - Agent system architecture upgrade
**Date**: 2026-01-28
**Focus**: Evaluate context:fork for Lean skills after Task 710 refactoring
**Session**: sess_1769573256_b38d39

## Summary

GitHub issue #16803 remains **OPEN** as of 2026-01-28 with no official fix. However, the question of using `context: fork` for Lean skills has become partially moot after Task 710's refactoring. The Lean skills now use **direct execution** (not subagent delegation), which changes the calculus for whether `context: fork` would help with context bloat.

**Key Finding**: `context: fork` would provide meaningful benefit for direct execution skills, but the feature remains broken for plugins and has mixed reports for user-level skills. Testing is recommended before adoption.

## Findings

### GitHub Issue #16803 Status (as of 2026-01-28)

**Current State**: OPEN (not resolved)
**Last Activity**: 2026-01-20T03:25:58Z (jaodsilv comment)

The issue remains unfixed. Key insights from community:

| User | Date | Claim |
|------|------|-------|
| vantasnerdan | 2026-01-08 | context:fork WORKING (detailed tests) |
| robingedda | 2026-01-10 | NOT WORKING (v2.1.3) |
| sondemar | 2026-01-15 | NOT WORKING (v2.1.5) |
| jaodsilv | 2026-01-20 | Plugin vs user-level distinction identified |

**Critical Clarification** (jaodsilv):
> "For plugins it is still not working in 2.1.12. However, on 2.1.2 (current stable), and probably since 2.1.0, it was already working for skills/commands and agents in my user's .claude folder."

### Task 710 Impact Analysis

Task 710 refactored the Lean skills from:

**Before (thin wrapper delegation)**:
```
/research N -> skill-lean-research -> Task(lean-research-agent) -> MCP tools
```

**After (direct execution)**:
```
/research N -> skill-lean-research -> MCP tools (directly)
```

This changes the context isolation picture:

| Pattern | Skill Context | Agent Context | Total Context Bloat |
|---------|---------------|---------------|---------------------|
| Old delegation | Minimal | Agent loads all | Agent-isolated |
| New direct execution | Skill loads all | N/A | **Main conversation** |

**Implication**: Without `context: fork`, the direct execution skills now load their full context (MCP tool instructions, error handling patterns, etc.) directly into the main conversation, potentially causing context bloat.

### Would context:fork Help Direct Execution Skills?

**Yes**, but with caveats:

1. **Context Isolation Benefit**
   - The ~400 lines of skill instructions + MCP tool references would run in isolated context
   - Main conversation wouldn't accumulate Lean research/implementation details
   - Multiple Lean operations wouldn't compound context growth

2. **Current Behavior Without context:fork**
   - Each `/research N` or `/implement N` for Lean tasks adds ~2000+ tokens of skill context
   - MCP tool responses accumulate in main context
   - Over a session with multiple Lean operations, context grows significantly

3. **With context:fork (if working)**
   - Skill would run in isolated forked context
   - Only the final summary would return to main conversation
   - Repeated Lean operations wouldn't accumulate context

### Comparison with Non-Lean Skills

| Skill | Execution Pattern | Would Benefit from context:fork |
|-------|-------------------|--------------------------------|
| skill-lean-research | Direct | **Yes** - heavy MCP context |
| skill-lean-implementation | Direct | **Yes** - heavy MCP + proof state context |
| skill-researcher | Delegation (Task) | **Yes** - would simplify |
| skill-planner | Delegation (Task) | Moderate - already isolated via Task |
| skill-implementer | Delegation (Task) | Moderate - already isolated via Task |

### Recommendation for Lean Skills

Given that:
1. GitHub #16803 remains OPEN
2. User-level skills reportedly work with context:fork (jaodsilv)
3. Direct execution skills suffer from context bloat without it
4. ProofChecker uses user-level skills (not plugins)

**Recommended Action**: Create a test skill to verify context:fork works for user-level direct execution skills.

**Test Skill**:
```yaml
---
name: test-context-fork-direct
description: Test context:fork for direct execution pattern
context: fork
allowed-tools: Read, Glob
user-invocable: true
---

# Test Context Fork (Direct Execution)

Demonstrate context isolation by:
1. Reading this skill's own SKILL.md file
2. Listing files in .claude/skills/
3. Reporting what tools are available
4. Confirming no access to messages before invocation
```

**Verification Criteria**:
1. Skill runs in isolated context (no parent history visible)
2. Skill has access to specified tools only
3. Results return cleanly without polluting main context
4. Subsequent main conversation doesn't show skill internals

### Risk Analysis

| Decision | Risk | Impact |
|----------|------|--------|
| Add context:fork now | Feature broken, skill fails | Medium - can revert |
| Wait for official fix | Context bloat continues | Low - functional but inefficient |
| Test first, then adopt | Minimal risk | Recommended |

### Alternative: Lazy Context Loading

If context:fork doesn't work, the Lean skills could be optimized by:

1. **Minimal frontmatter context** - Only load what's always needed
2. **On-demand @-references** - Load MCP guide only when first MCP tool needed
3. **Chunked execution** - Return intermediate results to reduce single-call context

This wouldn't eliminate context bloat but would reduce it.

## Decisions

1. **Do not add context:fork to Lean skills without testing** - Issue #16803 status is unclear for user-level skills
2. **Create test skill to verify** - Determine if context:fork works in ProofChecker environment
3. **If test passes**: Add context:fork to skill-lean-research and skill-lean-implementation
4. **If test fails**: Wait for official fix or implement lazy loading optimization

## Recommendations

### Immediate (This Session)

1. Create test-context-fork-direct skill
2. Run test and document results
3. If working, update Task 619 plan to include Lean skills

### Short-term (If Test Passes)

1. Add `context: fork` to skill-lean-research SKILL.md
2. Add `context: fork` to skill-lean-implementation SKILL.md
3. Test full `/research` and `/implement` workflows
4. Measure context reduction

### If Test Fails

1. Keep current direct execution pattern
2. Monitor GitHub #16803 for resolution
3. Consider lazy context loading optimization as interim measure

## References

- GitHub Issue: https://github.com/anthropics/claude-code/issues/16803
- Task 710 Summary: specs/710_refactor_lean_skills_direct_execution/summaries/implementation-summary-20260128.md
- Previous Research: specs/619_agent_system_architecture_upgrade/reports/research-003.md
- Lean Skills: .claude/skills/skill-lean-research/SKILL.md, .claude/skills/skill-lean-implementation/SKILL.md

## Next Steps

1. **Test context:fork** with user-level direct execution skill
2. **Document results** in this task
3. **Update implementation plan** based on test outcome
4. **If positive**: Proceed with context:fork adoption for Lean skills
5. **If negative**: Wait for #16803 resolution or implement lazy loading
