# Self-Contained Skill Lifecycle Pattern

## Overview

Skills should be self-contained workflows that own their complete lifecycle:
- **Preflight**: Update task status before starting work
- **Delegate**: Invoke agent to perform actual work
- **Postflight**: Update task status after completion
- **Return**: Return standardized JSON result

This pattern eliminates the need for multiple skill invocations per workflow command, reducing halt risk.

## Architecture

### Before (3 Skills)
```
/research N
├── GATE IN: Skill(skill-status-sync)    ← HALT RISK
├── DELEGATE: Skill(skill-researcher)     ← HALT RISK
├── GATE OUT: Skill(skill-status-sync)   ← HALT RISK
└── COMMIT: Bash
```

### After (1 Skill)
```
/research N
├── VALIDATE: Inline task lookup
├── DELEGATE: Skill(skill-researcher)
│   ├── 0. Preflight: Inline status update
│   ├── 1-4. Agent delegation and work
│   ├── 5. Postflight: Inline status update
│   └── Return: JSON with artifacts
└── COMMIT: Bash
```

## Skill Structure

### Frontmatter Requirements

Skills that manage lifecycle need these tools:
```yaml
---
name: skill-{name}
description: {description}
allowed-tools: Task, Bash(jq:*), Read, Edit, Glob, Grep
context: fork
agent: {agent-name}
---
```

### Section Organization

```markdown
## Execution

### 0. Preflight Status Update

Update task status before starting work.
See: @.claude/context/core/patterns/inline-status-update.md

### 1. Input Validation
### 2. Context Preparation
### 3. Invoke Subagent
### 4. Return Validation

### 5. Postflight Status Update

Update task status after successful completion.
See: @.claude/context/core/patterns/inline-status-update.md

### 6. Return Propagation
```

## Status Transitions by Workflow Type

| Workflow | Preflight Status | Postflight Status | Artifact Type |
|----------|------------------|-------------------|---------------|
| Research | researching | researched | research |
| Planning | planning | planned | plan |
| Implementation | implementing | completed/implementing | summary |

## Error Handling

### Preflight Errors
- If preflight fails, abort immediately
- Do not invoke agent
- Return error to caller

### Agent Errors
- If agent returns error/partial, do NOT run postflight
- Keep status in preflight state (e.g., "researching")
- Return agent error to caller

### Postflight Errors
- Log error but don't fail the workflow
- Artifacts were created, status can be fixed manually
- Return success with warning

## Benefits

1. **Single Skill Invocation**: Reduces halt risk from 3 to 1
2. **Clear Ownership**: Skill owns entire workflow lifecycle
3. **Simplified Commands**: Commands become thin routers
4. **Consistent State**: Preflight and postflight always run together

## References

- Inline patterns: `@.claude/context/core/patterns/inline-status-update.md`
- Anti-stop patterns: `@.claude/context/core/patterns/anti-stop-patterns.md`
- Subagent return format: `@.claude/context/core/formats/subagent-return.md`
