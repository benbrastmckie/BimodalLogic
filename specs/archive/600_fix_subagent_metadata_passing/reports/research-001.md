# Research Report: Task #600

**Task**: 600 - Fix Subagent Metadata Passing
**Started**: 2026-01-18T14:00:00Z
**Completed**: 2026-01-18T15:30:00Z
**Effort**: 4-6 hours (estimated implementation)
**Priority**: High
**Dependencies**: Task 599 (jq escaping workarounds)
**Sources/Inputs**:
- User-provided outputs: research.md, plan.md
- Claude Code documentation (code.claude.com)
- GitHub issues: #3978, #4371, #1132
- Codebase analysis: agents, skills, context files
- Web search for Claude Code 2026 best practices
**Artifacts**:
- specs/600_fix_subagent_metadata_passing/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Root Cause Identified**: Claude Code's Task tool (subagent mechanism) has a fundamental design limitation documented in GitHub Issue #3978 - subagent returns are opaque to users, and the JSON metadata that subagents output is treated as conversational text rather than structured data that the orchestrator can parse programmatically.
- **The 'continue' Interruption**: Observed in user outputs where subagent JSON return blocks print to console and then require user input to continue. This happens because the subagent's final text response (including the JSON) ends the subagent turn, but the parent skill/orchestrator doesn't automatically process it - Claude pauses awaiting user confirmation.
- **Two Distinct Problems**: (1) JSON being printed as console output instead of being parsed, and (2) workflow interruption requiring user 'continue' input between skill return and orchestrator postflight.
- **Recommended Solution**: Implement "silent orchestrator" pattern where postflight operations are embedded in the skill before returning, eliminating the hand-off that causes 'continue' prompts.

## Context & Scope

### Research Questions
1. Why does JSON from subagents print to console instead of being parsed?
2. Why are 'continue' interruptions occurring between skill returns and orchestrator postflight?
3. What are Claude Code 2026 best practices for subagent metadata passing?
4. How can the agent system be redesigned to avoid these issues?

### Scope
- Analysis of user-provided outputs (research.md, plan.md)
- Review of `.claude/` agent system architecture
- Web research on Claude Code subagent best practices
- GitHub issue analysis for Claude Code Task tool behavior

## Findings

### 1. Observed Behavior from User Outputs

**From research.md (Task 597)**:
```
● lean-research-agent(Execute Lean research for task 597)
  ⎿  Done (32 tool uses · 85.2k tokens · 3m 9s)

● Research completed successfully. Now I need to perform the postflight status update.
...
  Return to skill-lean-research:

  {
    "status": "researched",
    "summary": "...",
    ...
  }

✻ Cogitated for 4m 25s

❯ continue                    ← USER MUST TYPE THIS
```

**From plan.md (Task 599)**:
```
● planner-agent(Create implementation plan for task 599)
  ⎿  Done (16 tool uses · 54.5k tokens · 1m 35s)
...
  {
    "status": "planned",
    ...
  }

✻ Brewed for 3m 19s

❯ continue                    ← USER MUST TYPE THIS
```

### 2. Root Cause Analysis

#### Problem 1: JSON Printing to Console

The subagent-return.md format specifies that agents should "return ONLY valid JSON" at the end of their execution. However:

1. **Task tool returns text, not structured data**: When a subagent via the Task tool completes, Claude Code returns the agent's final text response. The JSON that agents write is part of this text response.

2. **No structured output field for subagents**: Unlike the Agent SDK's `output_format` option which provides `structured_output` in the result message, Claude Code's Task tool does not have an equivalent mechanism. The JSON is simply printed as the agent's conversational response.

3. **Parent skill must parse text**: The calling skill receives the subagent's text output and must manually extract/parse the JSON from it.

**Evidence from documentation**:
> "When a subagent completes, Claude receives its agent ID. Each subagent invocation creates a new instance with fresh context."
> -- Claude Code Docs

The documentation notably does NOT say "Claude receives structured JSON data from the subagent."

#### Problem 2: 'Continue' Interruptions

The interruption occurs at a specific point in the workflow:

```
SKILL EXECUTION:
1. Skill invokes subagent via Task tool      ← Works
2. Subagent executes and returns JSON text   ← Works
3. Skill receives subagent output            ← Works
4. Skill prints JSON (or Claude shows it)    ← Works
5. ★ PAUSE ★ - Skill turn ends              ← PROBLEM HERE
6. User must type 'continue'                 ← Required input
7. Orchestrator postflight runs              ← Only after continue
```

**Why this happens**:

1. **Skill instruction completion**: When the skill (e.g., skill-lean-research) finishes its instructions, Claude considers the "turn" complete and waits for user input.

2. **Orchestrator is in the same conversation**: The orchestrator (calling context) and skill run in the same Claude conversation. When the skill's final output is displayed, Claude's natural behavior is to pause for user response.

3. **Missing continuation trigger**: There's no automatic trigger to continue to postflight. The `next_steps` field in the JSON is informational, not actionable.

#### Problem 3: Documented Limitations (GitHub Issues)

**Issue #3978 - Task Tool Lacks Transparency**:
- Status: Closed as NOT_PLANNED
- Problem: "Tool returns only a final summary report, creating a 'black box' behavior"
- Workaround: Parse JSONL logs from `.claude/projects/` directory

**Issue #4371 - Sub-Agent Response Not Returning to Console**:
- Status: Closed as DUPLICATE of #3978
- Problem: "Nothing is ever returned to the console" when using subagents
- User: "Claude Code seems satisfied with the result, I cannot see the result"

**Issue #1132 - Bash Tool Escaping Bug** (related):
- Status: Closed as NOT_PLANNED
- Problem: jq commands with pipes get corrupted
- Impact: Some postflight jq commands fail, causing workflow errors

### 3. Current Architecture Analysis

The current agent system uses a three-layer architecture:

```
Layer 1: Command (e.g., /research)
    ↓
Layer 2: Skill (e.g., skill-lean-research)
    ↓ [Task tool]
Layer 3: Agent (e.g., lean-research-agent)
```

**Current flow** (problematic):
```
1. /research 597
2. Orchestrator validates, invokes skill-lean-research
3. Skill does preflight (status → researching)
4. Skill invokes lean-research-agent via Task tool
5. Agent conducts research, creates report, returns JSON
6. Skill receives JSON, prints it ← JSON visible in console
7. ★ SKILL TURN ENDS ★         ← 'continue' required
8. User types 'continue'
9. Orchestrator does postflight (status → researched)
10. Orchestrator commits
```

### 4. Claude Code 2026 Best Practices for Subagents

From web research, the following best practices are established:

1. **Structured Output with Agent SDK**: Use `outputFormat` option to get validated JSON via `structured_output` field. However, this is for the Agent SDK (programmatic API), not Claude Code CLI's Task tool.

2. **Subagent Output Should Be Summaries**: "One important advantage of agents is that they have their own context window and can provide a summary after doing extensive research to the main agent." Results should be "3-6 bullet summary of what it found."

3. **Fork + Gather Pattern**: "Launch multiple subagents in parallel, collect each agent's concise answer, then summarize/merge results in the main agent."

4. **Master-Clone Architecture**: "Let the main agent decide when and how to delegate work to copies of itself. The agent manages its own orchestration dynamically."

5. **Skill-Level Postflight**: For Claude Code specifically, the current best practice is to have the SKILL handle postflight before returning, rather than relying on an orchestrator layer.

### 5. Alternative Architectures Considered

#### Option A: Skill-Internal Postflight (Recommended)

Move postflight into the skill itself, so the skill completes all state updates before returning:

```
SKILL EXECUTION (self-contained):
1. Skill does preflight (status → researching)
2. Skill invokes subagent via Task tool
3. Subagent executes and returns
4. Skill validates return, parses artifacts
5. Skill does postflight (status → researched) ← MOVED HERE
6. Skill does git commit                        ← MOVED HERE
7. Skill returns final summary to user
NO 'continue' REQUIRED
```

**Advantages**:
- Eliminates 'continue' interruption
- All state updates atomic within skill
- JSON metadata used internally, not displayed

**Disadvantages**:
- Skills become larger/more complex
- Subagent return format still needed for skill-to-agent communication

#### Option B: Silent Orchestrator Hook

Use Claude Code hooks to automatically continue after skill completion:

```javascript
// hooks/skill-complete.js
module.exports = {
  event: 'skillComplete',
  handler: async (result) => {
    // Automatically trigger postflight
    await orchestrator.postflight(result);
    return { continue: true };
  }
};
```

**Advantages**:
- Preserves current architecture
- Hook handles continuation automatically

**Disadvantages**:
- Hooks are JavaScript/Node.js, not markdown-configurable
- Adds infrastructure complexity
- May not be fully supported in Claude Code

#### Option C: Command-Level Orchestration

Move all orchestration into the command file itself, eliminating the skill layer for simple workflows:

```
/research N
    ↓
Command does preflight
    ↓
Command invokes agent directly
    ↓
Command does postflight
    ↓
Command commits
```

**Advantages**:
- Simpler architecture
- Single execution context

**Disadvantages**:
- Duplicates logic across commands
- Loses skill reusability

#### Option D: JSON Suppression via Subagent Instruction

Instruct subagents to NOT output JSON, instead write metadata to a file:

```markdown
# Agent Instructions
...
Instead of returning JSON, write your return metadata to:
specs/{N}_{SLUG}/.subagent-return.json

Then output only a brief summary sentence.
```

**Advantages**:
- No JSON in console output
- File-based metadata can be parsed reliably

**Disadvantages**:
- Adds file I/O complexity
- Return file path must be predictable
- Cleanup needed after processing

## Decisions

### Decision 1: Adopt Option A (Skill-Internal Postflight)

**Rationale**:
- Most aligned with Claude Code's design (skills as self-contained units)
- Eliminates 'continue' interruption without infrastructure changes
- JSON metadata stays internal to skill-agent communication
- Already partially implemented (skills do preflight internally)

### Decision 2: Deprecate Orchestrator Postflight Pattern

**Current pattern** (in commands):
```markdown
### CHECKPOINT 2: GATE OUT

1. Validate Return
2. Verify Artifacts
3. Verify Status Updated

### CHECKPOINT 3: COMMIT

git commit...
```

**New pattern** (in skills):
```markdown
### 5. Postflight Status Update

After successful {operation}, update task status and link artifacts.
...

### 6. Git Commit (if skill has Bash access)

git add && git commit...

### 7. Return Summary

Return brief summary to user (no JSON).
```

### Decision 3: Simplify Subagent Return Format

Instead of requiring agents to return complex JSON structures that get displayed in console, agents should:

1. Write artifacts to files (already done)
2. Write metadata to a predictable location OR include key fields in artifact files
3. Return a brief conversational summary (not JSON)

The skill can then:
1. Verify artifact file exists
2. Read metadata from artifact or companion file
3. Proceed with postflight

## Risks & Mitigations

### Risk 1: Breaking Existing Workflows During Transition
**Impact**: High
**Likelihood**: Medium
**Mitigation**: Implement changes incrementally, starting with one skill (skill-lean-research). Test thoroughly before updating others. Keep existing patterns working during transition.

### Risk 2: Increased Skill Complexity
**Impact**: Medium
**Likelihood**: High
**Mitigation**: Create shared context files with reusable postflight patterns. Document clearly in inline-status-update.md. Ensure patterns handle jq escaping correctly (per Task 599).

### Risk 3: Loss of Structured Return Validation
**Impact**: Medium
**Likelihood**: Medium
**Mitigation**: Implement file-based validation. Skills check artifact file exists and is non-empty before postflight. Consider adding JSON schema to artifact header comments.

### Risk 4: Git Commit Failures in Skills
**Impact**: Low
**Likelihood**: Medium
**Mitigation**: Git commits are already non-blocking (log and continue). Skills can inherit this pattern. Ensure skill has Bash tool access for git operations.

## Recommendations

### Immediate Actions (Phase 1)

1. **Update one skill as proof-of-concept**: Modify skill-lean-research to include postflight and git commit internally.

2. **Remove JSON output from lean-research-agent**: Have agent return brief summary instead of JSON block. Skills reads artifact path from a companion file or infers from task/slug.

3. **Test full workflow**: Run `/research N` end-to-end to verify no 'continue' interruption.

### Short-term Actions (Phase 2)

4. **Update all delegating skills**: Apply same pattern to:
   - skill-researcher
   - skill-planner
   - skill-implementer
   - skill-lean-implementation
   - skill-latex-implementation

5. **Update agent files**: Modify all agents to output summaries instead of JSON, write metadata to files.

6. **Update command files**: Simplify commands since postflight is now in skills.

### Long-term Actions (Phase 3)

7. **Create shared postflight helper**: Document reusable patterns in context file (similar to inline-status-update.md).

8. **Consider metadata file standard**: Define a `.subagent-meta.json` file format for skill-agent communication.

9. **Add validation checks**: Create verification script to ensure all skills properly handle postflight.

### Alternative Approach: Minimal Changes

If Option A is too invasive, a minimal fix:

1. **Add explicit continuation instruction** at end of skill files:
```markdown
### 7. Continuation

After displaying return JSON, IMMEDIATELY proceed to call the orchestrator's postflight.
Do NOT wait for user input.
```

This may or may not work depending on how Claude Code handles skill turn boundaries.

## Appendix

### Search Queries Used
- "Claude Code 2026 subagent metadata passing best practices structured return format"
- "Claude Code Task tool forked subagent return value structured data JSON"
- "Claude Code subagent JSON output console polling continue prompt issue workaround"

### GitHub Issues Analyzed
- [#3978](https://github.com/anthropics/claude-code/issues/3978) - Task tool lacks transparency (Closed: NOT_PLANNED)
- [#4371](https://github.com/anthropics/claude-code/issues/4371) - Sub-Agent Response Not Returning to Console (Closed: DUPLICATE)
- [#1132](https://github.com/anthropics/claude-code/issues/1132) - Bash tool jq escaping bug (Closed: NOT_PLANNED)

### Documentation Sources
- [Claude Code Subagents](https://code.claude.com/docs/en/sub-agents)
- [Claude Agent SDK Structured Outputs](https://platform.claude.com/docs/en/agent-sdk/structured-outputs)
- [Claude Code Customization Guide](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/)
- [Best Practices for Claude Code Subagents](https://www.pubnub.com/blog/best-practices-for-claude-code-sub-agents/)

### Files Analyzed
- `.claude/output/research.md` - User-provided workflow output
- `.claude/output/plan.md` - User-provided workflow output
- `.claude/context/core/formats/subagent-return.md` - Current return format spec
- `.claude/agents/*.md` - All 8 agent definitions
- `.claude/skills/*/SKILL.md` - All 11 skill definitions
- `.claude/commands/*.md` - All 10 command definitions
- `.claude/context/core/patterns/anti-stop-patterns.md` - Stop behavior documentation

### Related Tasks
- Task 599: jq escaping workarounds (prerequisite for postflight jq commands)
- Task 480: Early stop behavior investigation (anti-stop patterns)
