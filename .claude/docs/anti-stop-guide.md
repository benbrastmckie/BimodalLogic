# Anti-Stop Pattern Guide

## Overview

Claude Code agents and skills must avoid certain status values and phrases that trigger early workflow termination. This guide explains the patterns to avoid and the correct alternatives.

## The Problem

When a subagent returns `"status": "completed"` or uses phrases like "Task complete", Claude interprets this as a signal to stop execution. This prevents the orchestrator from running postflight operations (status updates, artifact linking, git commits).

**Symptoms**:
- Tasks stuck in [RESEARCHING] instead of [RESEARCHED]
- Missing git commits after workflow commands
- Inconsistent state between TODO.md and actual progress

## Quick Reference

### Status Values

| DO NOT USE | USE INSTEAD |
|------------|-------------|
| `"completed"` | `"researched"` (for research) |
| `"completed"` | `"planned"` (for planning) |
| `"completed"` | `"implemented"` (for implementation) |
| `"done"` | Contextual value above |
| `"finished"` | Contextual value above |

### Phrases to Avoid

| DO NOT USE | USE INSTEAD |
|------------|-------------|
| "Task complete" | "Implementation finished. Run /task --sync to verify." |
| "Task is done" | "Research concluded. Artifacts created." |
| "Work is finished" | "Plan created. Ready for implementation." |

## For Agent Authors

When creating a new agent, add these items to your MUST NOT section:

```markdown
**MUST NOT**:
...
- Return the word "completed" as a status value (triggers Claude stop behavior)
- Use phrases like "task is complete", "work is done", or "finished" in summaries
- Assume your return ends the workflow (orchestrator continues with postflight)
```

## For Skill Authors

When defining skill return formats, use contextual status values:

```json
{
  "status": "implemented",  // NOT "completed"
  "summary": "All 3 phases executed successfully.",
  "next_steps": "Implementation finished. Run /task --sync to verify."  // NOT "Task complete"
}
```

## Verification

Check your files for forbidden patterns:

```bash
# Should return 0 matches
grep '"status": "completed' your-agent.md
grep "Task complete" your-skill/SKILL.md
```

## Reference

For full technical details, see:
- `.claude/context/core/patterns/anti-stop-patterns.md` - Complete pattern documentation
- `.claude/context/core/formats/subagent-return.md` - Return format specification
