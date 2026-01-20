# Research Report: Task #644

- **Task**: 644 - Redesign /learn command to use interactive task selection
- **Started**: 2026-01-20T09:00:00Z
- **Completed**: 2026-01-20T09:45:00Z
- **Effort**: 2-4 hours
- **Priority**: Medium
- **Dependencies**: None
- **Sources/Inputs**:
  - `.claude/commands/learn.md` - Current command specification
  - `.claude/skills/skill-learn/SKILL.md` - Current skill wrapper
  - `.claude/agents/learn-agent.md` - Current agent implementation
  - `.claude/skills/skill-refresh/SKILL.md` - AskUserQuestion pattern example
  - `.claude/agents/meta-builder-agent.md` - Interactive interview pattern
  - `specs/archive/385_refactor_meta_command_task_creation/reports/research-002.md` - Interview patterns research
- **Artifacts**:
  - `specs/644_redesign_learn_interactive_task_selection/reports/research-001.md` (this file)
- **Standards**: report-format.md, artifact-formats.md

## Executive Summary

- Current /learn implementation uses Task tool to delegate to learn-agent, running tag extraction in a subagent conversation
- The AskUserQuestion tool is available and used successfully in skill-refresh and meta-builder-agent for interactive selection
- Redesign should execute tag extraction directly in the skill (no subagent), then present findings interactively
- AskUserQuestion supports both single-select and multi-select modes, with options including labels and descriptions
- Recommended approach: skill scans synchronously, presents summary, then prompts for task type selection before creating any tasks

## Context & Scope

**Problem Statement**: The current /learn command auto-creates tasks after scanning for tags. Users may want to:
1. See what was found before any tasks are created
2. Select which task types to create (fix-it, learn-it, individual TODOs)
3. Optionally select individual TODO items for task creation
4. Avoid background processes that create tasks without explicit user confirmation

**Constraints**:
- Must remain synchronous (no Task tool delegation for main flow)
- Must preserve tag extraction logic
- Should use established AskUserQuestion patterns
- Must still update TODO.md and state.json for created tasks

## Findings

### 1. Current /learn Architecture

The current implementation follows a three-layer pattern:

```
/learn command (learn.md)
    |
    v
skill-learn (SKILL.md)
    |
    v [Task tool]
learn-agent (learn-agent.md)
```

**Key behaviors**:
- Command parses arguments (paths, --dry-run)
- Skill validates and builds delegation context
- Agent performs actual tag extraction and task creation
- Postflight in skill handles git commit

**Issues with current approach**:
- No user confirmation before task creation (except --dry-run preview)
- Subagent execution adds complexity
- User cannot select which tasks to create

### 2. AskUserQuestion Tool Capabilities

Based on analysis of skill-refresh and meta-builder-agent, the AskUserQuestion tool supports:

**Single-select mode** (default):
```json
{
  "question": "Select cleanup age threshold:",
  "header": "Age Threshold",
  "multiSelect": false,
  "options": [
    {
      "label": "8 hours (default)",
      "description": "Remove files older than 8 hours"
    },
    {
      "label": "2 days",
      "description": "Remove files older than 2 days"
    }
  ]
}
```

**Multi-select mode**:
```json
{
  "question": "Which task types should be created?",
  "header": "Task Types",
  "multiSelect": true,
  "options": [
    {"label": "fix-it task", "description": "Combine FIX:/NOTE: tags (3 items)"},
    {"label": "learn-it task", "description": "Update context from NOTE: tags (2 items)"},
    {"label": "TODO tasks", "description": "Create individual tasks (5 items)"}
  ]
}
```

**Key observations**:
- Options can have both label and description
- multiSelect enables checkbox-style selection
- Tool returns the selected option labels
- Works within skill context (no subagent needed)

### 3. Synchronous Execution Pattern

The skill-refresh implementation shows how to perform work directly in a skill without spawning a subagent:

```
skill-refresh (direct execution)
    |
    +-- Step 1: Parse Arguments
    +-- Step 2: Run Process Cleanup (Bash)
    +-- Step 3: Run Directory Survey (Bash)
    +-- Step 4: AskUserQuestion for selection
    +-- Step 5: Execute based on selection (Bash)
```

**Adaptation for /learn**:
1. Parse arguments (paths, no --dry-run since always interactive)
2. Extract tags using Grep/Bash directly
3. Present tag summary
4. AskUserQuestion for task type selection
5. Optionally AskUserQuestion for individual TODO selection
6. Create selected tasks
7. Git commit

### 4. Proposed Interactive Flow

#### Flow Diagram

```
/learn [paths]
    |
    v
[Skill: skill-learn]
    |
    +-- Parse paths (default to project root)
    |
    +-- Extract tags via Grep
    |   - FIX: tags
    |   - NOTE: tags
    |   - TODO: tags
    |
    +-- Display Tag Summary
    |   "Found 12 tags across 8 files:
    |    - 3 FIX: tags
    |    - 4 NOTE: tags
    |    - 5 TODO: tags"
    |
    +-- If no tags found: exit gracefully
    |
    +-- AskUserQuestion: Task Type Selection
    |   "Which task types should be created?"
    |   [ ] fix-it task (3 FIX + 4 NOTE tags)
    |   [ ] learn-it task (4 NOTE tags)
    |   [ ] TODO tasks (5 items)
    |
    +-- If "TODO tasks" selected:
    |   AskUserQuestion: Individual TODO Selection
    |   "Select TODO items to create as tasks:"
    |   [ ] "Add completeness theorem" (Modal.lean:67)
    |   [ ] "Implement helper function" (Shared.lean:23)
    |   ...
    |
    +-- Create selected tasks
    |   - Update state.json
    |   - Update TODO.md
    |
    +-- Display results
    |
    +-- Git commit
```

#### Design Decisions

**Question 1: Should --dry-run be preserved?**
- **Decision**: No. The new design is inherently "dry-run first" - users always see findings before any tasks are created.
- **Rationale**: Eliminates need for separate modes, simpler UX.

**Question 2: How granular should TODO selection be?**
- **Decision**: Offer two levels:
  1. First prompt: Select task types (fix-it, learn-it, TODO tasks as a group)
  2. Second prompt (if TODO tasks selected): Select individual TODO items
- **Rationale**: FIX and NOTE tags are meant to be grouped by design. TODO tags often have varying importance.

**Question 3: Should learn-agent be removed?**
- **Decision**: Yes, convert skill-learn to direct execution pattern.
- **Rationale**: Agent delegation adds complexity without benefit for this workflow. All operations can run synchronously in the skill.

**Question 4: What about large numbers of TODOs?**
- **Decision**: If >20 TODO tags found, add pagination or "Select all" option.
- **Rationale**: AskUserQuestion may have practical limits; need graceful handling.

### 5. Tag Extraction Implementation

The current agent uses grep patterns. These should be extracted to the skill:

```bash
# FIX: tags
grep -rn --include="*.lean" "-- FIX:" $paths
grep -rn --include="*.tex" "% FIX:" $paths
grep -rn --include="*.md" "<!-- FIX:" $paths
grep -rn --include="*.py" --include="*.sh" --include="*.yaml" "# FIX:" $paths

# NOTE: tags (same patterns with NOTE:)
# TODO: tags (same patterns with TODO:)
```

**Recommended**: Use the Grep tool directly in the skill rather than Bash grep, for consistency with the codebase.

### 6. Task Creation Logic

Task creation logic from learn-agent should be preserved:

**fix-it task**: Combines all FIX: and NOTE: tags into one task
- Title: "Fix issues from FIX:/NOTE: tags"
- Description: List of items with file:line references
- Language: Predominant source file type (lean, latex, meta, general)
- Priority: High

**learn-it task**: Groups NOTE: tags for context updates
- Title: "Update context files from NOTE: tags"
- Description: Grouped by target context directory
- Language: meta
- Priority: Medium

**todo-task**: One per selected TODO: tag
- Title: Tag content (truncated to 60 chars)
- Description: Full tag content with source file:line
- Language: Detected from source file type
- Priority: Medium

## Decisions

1. **Remove learn-agent**: Convert to direct execution in skill-learn
2. **Remove --dry-run flag**: Interactive flow replaces preview mode
3. **Two-stage selection**: Task types first, then individual TODOs if selected
4. **Preserve tag extraction logic**: Move grep patterns to skill
5. **Use multiSelect for task types**: Allow selecting multiple types at once
6. **Use multiSelect for TODO items**: Allow selecting individual items

## Recommendations

### Implementation Approach

1. **Modify skill-learn/SKILL.md**:
   - Change from thin wrapper to direct execution pattern
   - Remove Task tool invocation
   - Add AskUserQuestion to allowed-tools
   - Implement tag extraction inline
   - Add two-stage interactive selection

2. **Remove learn-agent.md**:
   - Delete `.claude/agents/learn-agent.md`
   - Agent functionality absorbed into skill

3. **Update learn.md command**:
   - Remove --dry-run documentation
   - Update execution section for new flow
   - Simplify output examples

4. **Preserve postflight**:
   - Git commit logic stays in skill
   - Same commit message format

### Suggested Implementation Phases

**Phase 1: Refactor skill-learn to direct execution**
- Remove Task tool delegation
- Add AskUserQuestion to allowed-tools
- Implement tag extraction using Grep tool
- Test tag extraction works

**Phase 2: Implement interactive selection**
- Add task type selection prompt
- Add individual TODO selection prompt
- Implement selection handling logic

**Phase 3: Task creation and finalization**
- Implement task creation for selected items
- Update TODO.md and state.json
- Implement git commit postflight
- Update command documentation

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| AskUserQuestion UI limitations with many options | Medium | Implement pagination or "Select all" for >20 items |
| Grep tool behavior differs from bash grep | Low | Test patterns thoroughly; adjust regex if needed |
| User confusion about removed --dry-run | Low | Clear documentation; new flow is more intuitive |
| Token overhead in skill with inline extraction | Medium | Keep extraction logic concise; use structured output |

## Appendix

### References

- `.claude/skills/skill-refresh/SKILL.md` - AskUserQuestion direct execution pattern
- `.claude/agents/meta-builder-agent.md` - Multi-stage AskUserQuestion usage
- `specs/archive/385_refactor_meta_command_task_creation/reports/research-002.md` - Interview patterns

### AskUserQuestion Tool Signature

Based on usage in meta-builder-agent:
```typescript
AskUserQuestion({
  question: string,      // The question text
  header?: string,       // Optional header/title
  multiSelect?: boolean, // true for checkbox, false for radio
  options: Array<{
    label: string,       // Option text
    description?: string // Optional description
  }>
})
```

Returns: string or string[] (selected label(s))

### Search Queries Used

- Grep for "AskUserQuestion" in project (34 files found)
- Read skill-refresh/SKILL.md for direct execution pattern
- Read meta-builder-agent.md for multi-stage interview pattern
- Read learn-agent.md for current tag extraction logic
