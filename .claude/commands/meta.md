---
description: Interactive system builder that creates TASKS for agent architecture changes (never implements directly)
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(jq:*), Bash(mkdir:*), Bash(sed:*), Task, TodoWrite, AskUserQuestion
argument-hint: [PROMPT] | --analyze
model: claude-opus-4-5-20251101
---

# /meta Command

Interactive system builder that creates TASKS for .claude/ system changes. This command analyzes requirements, breaks them into discrete tasks, and creates task entries - it NEVER implements changes directly.

## Constraints

**FORBIDDEN** - This command MUST NOT:
- Directly create commands, skills, rules, or context files
- Directly modify CLAUDE.md or ARCHITECTURE.md
- Implement any work without user confirmation
- Write any files outside .claude/specs/

**REQUIRED** - This command MUST:
- Track all work via tasks in TODO.md + state.json
- Require explicit user confirmation before creating any tasks
- Create task directories for each task
- Follow the staged workflow with checkpoints

## Arguments

- No args: Start interactive interview
- `PROMPT` - Direct analysis of change request
- `--analyze` - Analyze existing .claude/ structure (read-only)

Note: --generate mode removed. Use /implement for task execution.

## Interview Patterns

### Progressive Disclosure
Start with broad questions, then drill into specifics based on responses.

### Adaptive Questioning
Adjust question complexity based on user's technical level and domain familiarity.

### Example-Driven
Provide concrete examples for every question to guide user thinking.

### Validation Checkpoints
Summarize and confirm understanding after each phase before proceeding.

---

## With Prompt Mode

When $ARGUMENTS contains a prompt (not a flag):

### Abbreviated Flow

Skip interview stages 1-2, proceed directly to analysis:

1. **Stage 0**: DetectExistingSystem (always runs)
2. **Stage 2.5**: DetectDomainType from prompt keywords
3. **Stage 3-4**: Analyze prompt to identify tasks and estimate complexity
4. **Stage 5**: Present task breakdown with confirmation (MANDATORY)
5. **Stage 6-7**: Create tasks and summarize

### Analysis Process

1. **Parse prompt for keywords** indicating:
   - Language: "lean", "proof", "theorem" → lean; "command", "skill", "agent" → meta; "latex", "document" → latex
   - Scope: component names, file paths, feature areas
   - Change type: "fix", "add", "refactor", "document"

2. **Check for related existing tasks** via keyword matching in state.json

3. **Propose task breakdown** based on analysis

### Clarification (when needed)

Use AskUserQuestion when:
- Prompt is ambiguous (multiple interpretations)
- Scope is unclear
- Dependencies are uncertain

Example:
```
AskUserQuestion:
  question: "Your request could be implemented as:"
  options:
    - "Single task: {description}"
    - "Multiple tasks: {task1}, {task2}"
    - "Let me explain more"
```

---

## Interactive Mode (No Arguments)

When $ARGUMENTS is empty, run full interview:

### Stage 0: DetectExistingSystem

**Action**: Analyze existing .claude/ structure and identify relevant context

**Process**:
```bash
# Count existing components
cmd_count=$(ls .claude/commands/*.md 2>/dev/null | wc -l)
skill_count=$(find .claude/skills -name "SKILL.md" 2>/dev/null | wc -l)
rule_count=$(ls .claude/rules/*.md 2>/dev/null | wc -l)
active_tasks=$(jq '.active_projects | length' .claude/specs/state.json)
```

**Output** (when existing system detected):
```
## Existing .claude/ System Detected

**Components**:
- Commands: {N}
- Skills: {N}
- Rules: {N}
- Active Tasks: {N}

**Related Existing Tasks** (if any match prompt keywords):
- Task #{N}: {title} [{status}]
```

**Checkpoint**: Existing system analyzed
- [ ] Component counts captured
- [ ] Related tasks identified (if any)

---

### Stage 1: InitiateInterview

**Action**: Greet user and explain process

**Output**:
```
## Building Your Task Plan

I'll help you create structured tasks for your .claude/ system changes.

**Process** (5-10 minutes):
1. Understand what you want to accomplish
2. Break down into discrete tasks
3. Review and confirm task list
4. Create tasks in TODO.md

**What You'll Get**:
- Task entries in TODO.md and state.json
- Clear descriptions and priorities
- Dependencies mapped between tasks
- Ready for /research → /plan → /implement cycle

Let's begin!
```

**Checkpoint**: User understands process and is ready

---

### Stage 2: GatherDomainInfo

**Question 1**:
- **Ask**: What do you want to accomplish with this change?
- **Examples**:
  - "Add a new command for X"
  - "Fix a bug in the Y workflow"
  - "Refactor Z for better performance"
  - "Create documentation for W"
- **Capture**: purpose, change_type

**Question 2**:
- **Ask**: What part of the .claude/ system is affected?
- **Examples**:
  - "A specific command (e.g., /task)"
  - "A skill or agent"
  - "Rules or context files"
  - "Multiple components"
- **Capture**: affected_components, scope

**Checkpoint**: Domain and purpose clearly identified
- [ ] Purpose is clear and specific
- [ ] Affected components identified
- [ ] Scope is bounded

---

### Stage 2.5: DetectDomainType

**Action**: Classify language from keywords

**Classification Logic**:
- Keywords: "lean", "theorem", "proof", "lemma", "Mathlib" → language = "lean"
- Keywords: "command", "skill", "agent", "meta", ".claude/" → language = "meta"
- Keywords: "latex", "document", "pdf", "tex" → language = "latex"
- Otherwise → language = "general"

**Checkpoint**: Language classification determined

---

### Stage 3: IdentifyUseCases

**Question 3**:
- **Ask**: Can this be broken into smaller, independent tasks?
- **Examples**:
  - "Yes, there are 3 distinct steps: research, design, implement"
  - "No, it's a single focused change"
  - "Maybe - help me break it down"
- **Capture**: task_count_estimate, breakdown_type

**Question 4** (if breakdown_type != "single"):
- **Ask**: What are the discrete tasks? List them in order of dependency.
- **Examples**:
  - "1. Add constraint section, 2. Update stage flow, 3. Add new output"
  - "Research first, then plan, then implement"
- **Capture**: task_list[], dependency_order[]

**Checkpoint**: Tasks identified with dependencies
- [ ] Task count determined ({N} tasks)
- [ ] Dependencies mapped
- [ ] Each task is discrete and actionable

---

### Stage 4: AssessComplexity

**Question 5**:
- **Ask**: For each task, what's the estimated effort?
- **Options** (per task):
  - Small: < 1 hour
  - Medium: 1-3 hours
  - Large: 3-6 hours
  - Very Large: > 6 hours (consider splitting)
- **Capture**: effort_estimates{}

**Question 6**:
- **Ask**: What priority should each task have?
- **Options**: High, Medium, Low
- **Guidance**: High = blocking other work or critical fix
- **Capture**: priority_assignments{}

**Checkpoint**: Complexity and priority assessed
- [ ] Each task has effort estimate
- [ ] Priorities assigned
- [ ] No "Very Large" tasks without splitting

---

### Stage 5: ReviewAndConfirm

**CRITICAL**: User MUST confirm before any task creation.

**Present comprehensive summary**:
```
## Task Summary

**Domain**: {domain}
**Purpose**: {purpose}
**Scope**: {affected_components}

**Tasks to Create** ({N} total):

| # | Title | Language | Priority | Effort | Dependencies |
|---|-------|----------|----------|--------|--------------|
| {N} | {title} | {lang} | {pri} | {hrs} | None |
| {N} | {title} | {lang} | {pri} | {hrs} | #{N} |

**Total Estimated Effort**: {sum} hours

---

Does this look correct?
- ✅ **Proceed** - Create these tasks
- 🔄 **Revise** - Adjust task breakdown
- ❌ **Cancel** - Exit without creating tasks
```

**Use AskUserQuestion**:
```
AskUserQuestion:
  question: "Proceed with creating these tasks?"
  header: "Confirm"
  options:
    - label: "Yes, create tasks"
      description: "Create {N} tasks in TODO.md and state.json"
    - label: "Revise"
      description: "Go back and adjust the task breakdown"
    - label: "Cancel"
      description: "Exit without creating any tasks"
```

**Checkpoint**: User has explicitly confirmed task creation
- [ ] User selected "Proceed"
- [ ] All tasks have required fields

---

### Stage 6: CreateTasks

**Action**: Create task entries in TODO.md and state.json

**Process** (for each task):

```bash
# 1. Get next task number (will become {N})
next_num=$(jq -r '.next_project_number' .claude/specs/state.json)

# 2. Create slug from title (lowercase, underscores, max 50 chars)
slug=$(echo "{title}" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd 'a-z0-9_' | cut -c1-50)

# 3. Create task directory
mkdir -p ".claude/specs/${next_num}_${slug}"

# 4. Update state.json with dependencies
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg desc "{description}" \
  '.next_project_number = ({next_num} + 1) |
   .active_projects = [{
     "project_number": {next_num},
     "project_name": "{slug}",
     "status": "not_started",
     "language": "{lang}",
     "priority": "{pri}",
     "description": $desc,
     "dependencies": [{dep_numbers}],
     "created": $ts,
     "last_updated": $ts
   }] + .active_projects' \
  .claude/specs/state.json > /tmp/state.json && \
  mv /tmp/state.json .claude/specs/state.json

# 5. Update TODO.md frontmatter
sed -i "s/^next_project_number: [0-9]*/next_project_number: $((next_num + 1))/" \
  .claude/specs/TODO.md

# 6. Add entry to TODO.md under appropriate priority section
```

**TODO.md Entry Format**:
```markdown
### {N}. {Title}
- **Effort**: {estimate}
- **Status**: [NOT STARTED]
- **Priority**: {priority}
- **Language**: {language}
- **Dependencies**: Task #{N}, Task #{N}

**Description**: {description}

---
```

**Git Commit**:
```bash
git add .claude/specs/
git commit -m "meta: create {N} tasks for {domain}"
```

Note: {N} in commit message is the COUNT of tasks created.

**Checkpoint**: Tasks created successfully
- [ ] All task directories created
- [ ] state.json updated with all tasks
- [ ] TODO.md entries added
- [ ] Git commit completed

---

### Stage 7: DeliverSummary

**Output**:
```
## Tasks Created

Created {N} task(s) for {domain}:

**High Priority**:
- Task #{N}: {title}
  Path: .claude/specs/{N}_{slug}/

**Medium Priority**:
- Task #{N}: {title} (depends on #{N})
  Path: .claude/specs/{N}_{slug}/

**Low Priority**:
- Task #{N}: {title}
  Path: .claude/specs/{N}_{slug}/

---

**Next Steps**:
1. Review tasks in TODO.md
2. Run `/research {N}` to begin research on first task
3. Progress through /research → /plan → /implement cycle

**Suggested Order** (respecting dependencies):
1. Task #{N} (no dependencies)
2. Task #{N} (depends on #{N})
```

---

## Analyze Mode (--analyze)

Examine existing .claude/ structure (read-only):

```
Current .claude/ Structure:

Commands ({N}):
- /{command1} - {description}
- /{command2} - {description}

Skills ({N}):
- {skill1} - {description}
- {skill2} - {description}

Rules ({N}):
- {rule1}.md - {paths}

Active Tasks ({N}):
- #{N}: {title} [{status}]
- #{N}: {title} [{status}]

Context Files:
- core/: {N} files
- project/: {N} files

Recommendations:
1. {suggestion based on analysis}
2. {suggestion based on analysis}
```

---

## Appendix: Reference Templates

These templates are for reference only. Actual file creation happens during `/implement`, not `/meta`.

### Command Template Reference

```markdown
---
description: {description}
allowed-tools: {tools}
argument-hint: {hint}
model: claude-opus-4-5-20251101
---

# /{command} Command

{documentation}

## Arguments

- `$1` - {arg description}

## Execution

### 1. {Step}

{details}

## Output

{expected output format}
```

### Skill Template Reference

```markdown
---
name: {skill-name}
description: {when to invoke}
allowed-tools: {tools}
context: fork
---

# {Skill Name}

## Trigger Conditions

This skill activates when:
- {condition}

## Execution

{steps}

## Return Format

{format}
```

### Rule Template Reference

```markdown
---
paths: {glob pattern}
---

# {Rule Title}

## {Section}

{content}
```
