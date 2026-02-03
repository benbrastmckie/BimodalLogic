# Research Report: Task #619 - GitHub Issue #16803 Status Check (February 2026)

**Task**: Agent system architecture upgrade (context:fork migration)
**Date**: 2026-02-03
**Focus**: Check if GitHub issue #16803 has been addressed
**Session**: sess_1770157494_33ab1f

## Summary

GitHub issue #16803 remains **OPEN** as of 2026-02-03. Recent comments (within the past week) confirm the issue persists in Claude Code v2.1.30. The bug is specific to **plugins** - skills in user-level `.claude/` folders reportedly work, while plugin-loaded skills do not fork correctly.

## Findings

### GitHub Issue #16803 Status

| Field | Value |
|-------|-------|
| **State** | OPEN |
| **Title** | feat: context: fork in skill frontmatter doesn't work - skill still runs inline |
| **Last Updated** | 2026-02-03T20:34:09Z |
| **Labels** | bug, has repro, platform:macos, area:core |

### Recent Activity (Since Last Research)

Two new comments since research-005.md (2026-01-28):

#### 1. abhinavos7a (2026-01-31) - Detailed Plugin Reproduction

Provided a thorough reproduction case showing:
- Plugin skills with `context: fork` and different `agent:` types do not spawn subagents
- Sequential execution instead of parallel (alpha finished before beta started, beta before gamma)
- Workaround: Task tool directly with custom subagents works correctly
- Version tested: Claude Code v2.1.16

#### 2. apoturaev (2026-02-03) - Workaround Confirmation

Confirmed on Claude Code v2.1.30 (current latest):
> "skill with `context: fork` runs in the main context when loaded from a plugin"
> "copying the skill to the local `.claude/skills/` folder makes it work correctly in a subagent"

### Key Insight: Plugin vs User-Level Distinction

The evidence now strongly supports the distinction first identified by jaodsilv (2026-01-20):

| Skill Location | context:fork Status |
|----------------|---------------------|
| Plugin (`--plugin-dir`) | **NOT WORKING** |
| User-level (`~/.claude/skills/`) | **WORKING** |
| Project-level (`.claude/skills/`) | **WORKING** (per jaodsilv) |

### ProofChecker Relevance

This project uses **project-level skills** in `.claude/skills/`. According to the community reports:
- Project-level `.claude/skills/` should work (same as user-level `~/.claude/`)
- This was empirically tested in research-005.md and found NOT working

**Discrepancy**: Our local testing (research-005.md) showed context:fork was not working even for project-level skills, contradicting community reports. Possible explanations:
1. Test methodology differences
2. Version-specific behavior
3. Additional configuration requirements not documented

## Recommendations

### 1. No Change to Current Implementation Strategy

The current architecture remains correct:
- **Lean skills**: Direct execution (needs MCP tools, which are blocked in subagents)
- **Non-Lean skills**: Task tool delegation (provides real isolation)

### 2. Re-test with Current Claude Code Version

Given apoturaev's confirmation that user-level skills work in v2.1.30, consider:
1. Check current Claude Code version: `claude --version`
2. Re-run test-lean-research skill
3. Document results to confirm/refute local behavior

### 3. Monitor Issue for Resolution

The issue has active community engagement. Watch for:
- Official Anthropic response
- Plugin-level fix announcement
- Changelog entries mentioning "context: fork"

## Conclusion

GitHub issue #16803 is **still OPEN** and actively receiving reports. The bug specifically affects **plugin-loaded skills**. User-level and project-level skills reportedly work, but our local testing showed otherwise. The safest path is to continue using the current architecture (direct execution for Lean skills, Task delegation for others) until the issue is resolved and locally verified.

## References

- GitHub Issue: https://github.com/anthropics/claude-code/issues/16803
- Previous research: research-005.md (2026-01-28)
- Current Claude Code version: Check with `claude --version`

## Next Steps

1. Verify current Claude Code version
2. Optionally re-test context:fork with project-level skill
3. Continue monitoring GitHub issue for resolution
