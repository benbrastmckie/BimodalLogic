# Research Report: Task #600 (Supplementary Online Research)

**Task**: 600 - Fix Subagent Metadata Passing
**Started**: 2026-01-18T18:00:00Z
**Completed**: 2026-01-18T18:45:00Z
**Effort**: Supplementary research (2 hours estimated)
**Priority**: High
**Dependencies**: Task 599 (jq escaping workarounds), research-001.md (codebase analysis)
**Sources/Inputs**:
- Claude Code official documentation (code.claude.com)
- GitHub issues: #17351, #8093, #7091, #11712, #4580, #9905
- Third-party guides and tutorials
- Community patterns and workarounds
**Artifacts**:
- specs/600_fix_subagent_metadata_passing/reports/research-002.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Critical Bug Confirmed**: GitHub Issue #17351 confirms that nested skills do NOT return to the invoking skill context - they return to the main session context. This is a known, unresolved bug affecting Claude Code v2.1.x+.
- **Feature Request CLOSED**: GitHub Issue #8093 requesting subagents pass follow-up commands was closed as NOT_PLANNED, confirming no official support for programmatic skill/agent chaining.
- **Best Practice Identified**: Use **SubagentStop hooks** with `exit code 2` or `{"decision": "block"}` JSON output to force continuation and prevent workflow interruption.
- **Alternative Solution**: File-based metadata passing (writing return data to files instead of console output) is a documented community pattern that avoids console pollution.

## Context & Scope

This report supplements research-001.md with online research focused on:
1. Claude Code 2026 official documentation
2. GitHub issues tracking subagent/skill behavior
3. Community best practices and workarounds
4. Hook-based workflow control patterns

## Findings

### 1. Official Documentation on Subagent Returns

From [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents):

**Key Limitation**: Subagents return results as natural language text, NOT structured data.
> "The actual return format appears to be natural language from the subagent's work, without structured output configuration - subagents simply complete their tasks and their work is summarized in the results passed back."

**No `output_format` equivalent**: Unlike the Claude Agent SDK which provides `structured_output` configuration, Claude Code's Task tool has no mechanism for structured JSON returns. The JSON that agents output is treated as conversational text.

**Subagent Nesting Blocked**:
> "Subagents cannot spawn other subagents. If your workflow requires nested delegation, use Skills or chain subagents from the main conversation."

### 2. GitHub Issues Analysis

#### Issue #17351 - Nested Skills Context Return (CRITICAL)

**Status**: Open, Unresolved
**URL**: https://github.com/anthropics/claude-code/issues/17351
**Community Response**: 15+ thumbs up

**Problem**: A skill that invokes another skill cannot continue its workflow after the nested skill completes. Control returns to the main session context instead of the invoking skill.

**Impact**: This directly explains the "continue" prompt behavior observed in the user's outputs. When skill-lean-research completes and returns JSON, Claude considers the skill turn complete and awaits user input rather than continuing with postflight operations.

**Affected Configurations**:
- Skills with `context: fork`
- Skills with `agent:` specifications
- Skills without forking (all scenarios affected)

**Workaround Mentioned**: None provided in the issue.

#### Issue #8093 - Subagents Pass Follow-up Commands (CLOSED)

**Status**: Closed as NOT_PLANNED
**URL**: https://github.com/anthropics/claude-code/issues/8093

**Proposed Solution** (not implemented):
```json
{
  "content": [{ "type": "text", "text": "Summary" }],
  "follow_up_prompt": "/next-command"
}
```

**Official Position**: Feature request was auto-closed after 60 days of inactivity. No plans to implement.

**Alternative Documented**: "Coordinator Slash Command Pattern" - centralize workflow logic in a single skill rather than chaining. This aligns with research-001.md's recommendation for "skill-internal postflight."

#### Issue #7091 - Subagent Stuck on User Approval

**Status**: Open
**URL**: https://github.com/anthropics/claude-code/issues/7091

**Related Behavior**: When subagents require user input (approval/denial), the system can stall indefinitely. Only Ctrl+C recovery works.

**Relevance**: Confirms that subagent turn boundaries are rigid - no mechanism for automatic continuation exists at the Task tool level.

#### Issue #4580 - JSON Serialization Freeze

**Status**: Reported
**URL**: https://github.com/anthropics/claude-code/issues/4580

**Problem**: 100% CPU usage during JSON serialization when Task tool processes large responses.

**Relevance**: Large JSON return blocks from agents may cause performance issues, reinforcing the recommendation to minimize JSON output size.

### 3. Hook-Based Solutions (RECOMMENDED)

From [Claude Code Hooks Documentation](https://code.claude.com/docs/en/hooks):

#### SubagentStop Hook

This is the most promising official mechanism for controlling subagent completion behavior.

**Configuration**:
```json
{
  "hooks": {
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "check-completion.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

**Force Continuation with Exit Code 2**:
```bash
#!/bin/bash
# check-completion.sh
if ! grep -q "STATUS=COMPLETED" /tmp/task-state.txt; then
  echo "Postflight not complete. Continue." >&2
  exit 2  # Blocks stoppage, shows stderr to Claude
fi
exit 0
```

**Force Continuation with JSON Decision**:
```bash
#!/bin/bash
cat << 'EOF'
{
  "decision": "block",
  "reason": "Execute postflight: update task status to researched and commit changes."
}
EOF
exit 0
```

**Important**: Check `stop_hook_active` to prevent infinite loops:
```python
#!/usr/bin/env python3
import json
import sys

input_data = json.load(sys.stdin)
if input_data.get("stop_hook_active"):
    sys.exit(0)  # Allow stop to prevent loop

# Check if postflight needed
print(json.dumps({
    "decision": "block",
    "reason": "Postflight pending. Update status and commit."
}))
sys.exit(0)
```

#### Stop Hook (Main Agent)

Can also control the main agent's stopping behavior:
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if all workflow steps completed. Return {\"ok\": true} to stop or {\"ok\": false, \"reason\": \"...\"} to continue.",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### 4. YOLO Mode and Permission-Free Workflows

From [Claude Code YOLO Mode Documentation](https://blog.promptlayer.com/claude-dangerously-skip-permissions/):

**`--dangerously-skip-permissions` Flag**:
> "Enables fully unattended execution mode where Claude Code bypasses all permission prompts and runs uninterrupted until completion."

**Relevance**: For workflows requiring no user intervention, combining:
1. SubagentStop hooks to force continuation
2. `--dangerously-skip-permissions` for permission-free execution
3. Skill-internal postflight to avoid context transitions

This creates a fully autonomous pipeline.

**Caution**: Must run in isolated environment (container/VM) for safety.

### 5. File-Based Metadata Passing Pattern

From community patterns and Claude Code tutorials:

**Pattern**: Instead of returning JSON in conversation output, write metadata to a predictable file location.

**Implementation**:
```markdown
# Agent Instructions (in agent .md file)

## Return Protocol

Instead of outputting JSON to the conversation:
1. Write return metadata to: `specs/{N}_{SLUG}/.return-meta.json`
2. Output only a brief summary sentence to the conversation

The calling skill will read the metadata file for structured data.
```

**Example Return File**:
```json
{
  "status": "researched",
  "artifacts": [
    {
      "type": "report",
      "path": "specs/600_fix_subagent/reports/research-001.md"
    }
  ],
  "next_steps": "Run /plan 600"
}
```

**Skill reads file**:
```bash
# In skill postflight
return_data=$(cat "specs/${task_num}_${slug}/.return-meta.json")
status=$(echo "$return_data" | jq -r '.status')
# Update task status based on file contents
```

**Advantages**:
- No JSON in console output
- Structured data reliably parseable
- File persists for debugging
- Avoids JSON serialization issues (#4580)

**Disadvantages**:
- Extra file I/O
- Cleanup needed after processing
- Path must be predictable/passed to agent

### 6. Multi-Agent Coordination Patterns

From [wshobson/agents](https://github.com/wshobson/agents) and [Claude-Flow](https://github.com/ruvnet/claude-flow):

**File-Based Delegation**:
> "Multi-agent coordination is about choosing the right execution strategy... File-based delegation to avoid context pollution (50-80% token savings)."

**Brief Summaries**:
> "Brief summaries from sub-agents (clean orchestrator context) - One important advantage of agents is that they have their own context window and can provide a summary after doing extensive research."

**Recommended Summary Format**:
> "3-6 bullet summary of what it found" rather than detailed JSON.

### 7. Dual-Channel Communication (isMeta Pattern)

From [Claude Skills Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/):

**How Skills Use Dual Channels**:
> "When `isMeta: true`, the message gets sent to the Anthropic API as part of Claude's conversation context but never appears in the UI."

**Relevance**: Skills can inject metadata instructions without cluttering user-visible output. This is internal to Claude Code's skill system but demonstrates the concept of separating metadata from user output.

## Decisions

### Decision 1: Use SubagentStop Hook for Continuation

**Rationale**: This is the officially supported mechanism for controlling subagent stopping behavior. By checking if postflight is complete and blocking if not, we can force continuation without user input.

**Implementation Priority**: High

### Decision 2: Adopt File-Based Metadata Pattern

**Rationale**: Given that:
- JSON returns print to console (no structured output support)
- Task tool has no `follow_up_prompt` capability (Issue #8093 closed)
- Large JSON can cause performance issues (Issue #4580)

File-based metadata passing provides reliable structured data exchange without console pollution.

**Implementation Priority**: Medium

### Decision 3: Maintain Skill-Internal Postflight (from research-001.md)

**Rationale**: Online research confirms this is the recommended pattern:
- GitHub issues confirm skill chaining is broken (#17351)
- "Coordinator Slash Command Pattern" documentation recommends centralizing workflow in single skill
- Avoids context transition that causes "continue" prompt

**Implementation Priority**: High (already decided in research-001.md)

## Risks & Mitigations

### Risk 1: Infinite Loops with Stop Hooks

**Impact**: High
**Likelihood**: Medium (without proper guards)
**Mitigation**:
- Always check `stop_hook_active` flag
- Set maximum continuation count
- Use transcript analysis for intelligent decisions

### Risk 2: Hook Configuration Complexity

**Impact**: Medium
**Likelihood**: Medium
**Mitigation**:
- Start with simple bash hooks, not prompt-based
- Document hook behavior clearly
- Test hooks in isolation before deployment

### Risk 3: File-Based Metadata Path Synchronization

**Impact**: Low
**Likelihood**: Medium
**Mitigation**:
- Use predictable path pattern: `specs/{N}_{SLUG}/.return-meta.json`
- Pass path explicitly in agent delegation context
- Validate file exists before reading

## Recommendations

### Immediate Actions (Phase 1)

1. **Implement SubagentStop Hook**:
   Create `.claude/hooks/subagent-postflight.sh` that:
   - Checks for pending postflight operations
   - Returns `{"decision": "block", "reason": "..."}` if postflight needed
   - Checks `stop_hook_active` to prevent loops

2. **Update settings.json with hook configuration**:
   ```json
   {
     "hooks": {
       "SubagentStop": [{
         "hooks": [{
           "type": "command",
           "command": ".claude/hooks/subagent-postflight.sh"
         }]
       }]
     }
   }
   ```

### Short-Term Actions (Phase 2)

3. **Implement File-Based Return Protocol**:
   - Define `.return-meta.json` schema
   - Update agent instructions to write metadata to file
   - Update skills to read metadata from file

4. **Simplify Agent Return Output**:
   - Change agents to output brief summary (3-6 bullets)
   - Remove JSON blocks from conversation output
   - Keep metadata in files for skill consumption

### Long-Term Actions (Phase 3)

5. **Create Hook Library**:
   - `subagent-postflight.sh` - Force continuation for postflight
   - `validate-completion.sh` - Check if task truly complete
   - `prevent-loop.py` - Intelligent loop prevention with transcript analysis

6. **Document Patterns**:
   - Create context file for hook-based workflow control
   - Update agent instructions with new return protocol
   - Create troubleshooting guide for common issues

## Appendix

### Search Queries Used

- "Claude Code 2026 subagent metadata passing best practices Task tool"
- "Claude Code skills agents communication structured output patterns 2026"
- "Anthropic Claude Code multi-agent orchestration subagent return value"
- "Claude Code Task tool subagent JSON output console issue GitHub"
- "Claude Code hooks skills postflight automatic continuation workflow"
- "Claude Code CLAUDEMD skill development structured return format"
- "Claude Code continue prompt subagent workflow interruption automatic"
- "Claude Code Stop hook SubagentStop force continuation exit code 2"
- "Claude Code YOLO mode auto-accept workflow uninterrupted agentic"
- "Claude Code file-based coordination agents state passing metadata workflow"

### Documentation Sources

- [Claude Code Subagents](https://code.claude.com/docs/en/sub-agents)
- [Claude Code Skills](https://code.claude.com/docs/en/skills)
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Claude Code Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Claude Skills Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/)
- [Claude Code Customization Guide](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/)
- [Best Practices for Claude Code Subagents](https://www.pubnub.com/blog/best-practices-for-claude-code-sub-agents/)
- [How to Configure Hooks](https://claude.com/blog/how-to-configure-hooks)

### GitHub Issues Analyzed

| Issue | Title | Status | Relevance |
|-------|-------|--------|-----------|
| [#17351](https://github.com/anthropics/claude-code/issues/17351) | Nested skills don't return to invoking skill context | Open | Critical - explains continue prompt |
| [#8093](https://github.com/anthropics/claude-code/issues/8093) | Enable Subagents to Pass Follow-up Commands | Closed (NOT_PLANNED) | Confirms no official chaining support |
| [#7091](https://github.com/anthropics/claude-code/issues/7091) | Subagent stuck on user approval | Open | Confirms rigid turn boundaries |
| [#11712](https://github.com/anthropics/claude-code/issues/11712) | Subagent Resume Missing User Prompts | Open | Resume functionality issues |
| [#4580](https://github.com/anthropics/claude-code/issues/4580) | JSON Serialization Freeze | Reported | Large JSON performance issues |
| [#9905](https://github.com/anthropics/claude-code/issues/9905) | Background Agent Execution Request | Open | Async subagent feature request |
| [#10412](https://github.com/anthropics/claude-code/issues/10412) | Stop hooks exit code 2 fail via plugins | Reported | Hook installation nuance |

### Related Community Projects

- [wshobson/agents](https://github.com/wshobson/agents) - Multi-agent orchestration for Claude Code
- [ruvnet/claude-flow](https://github.com/ruvnet/claude-flow) - Agent orchestration platform
- [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) - 100+ specialized subagents
- [disler/claude-code-hooks-mastery](https://github.com/disler/claude-code-hooks-mastery) - Hooks examples and patterns

### Related Tasks

- Task 599: jq escaping workarounds (prerequisite for postflight jq commands)
- Task 480: Early stop behavior investigation (anti-stop patterns)
