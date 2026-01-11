# Implementation Plan: Task #385

**Task**: Refactor /meta command to create tasks instead of direct implementation
**Version**: 002
**Created**: 2026-01-12
**Revision of**: implementation-001.md
**Reason**: Use padded {NNN} format for consistency with project directory numbering. Better incorporate OpenAgents patterns from research-002.md including structured question patterns, explicit capture variables, and comprehensive existing system detection.

## Revision Summary

### Previous Plan Status
- Phase 1: [NOT STARTED] - Add constraints (ready to implement)
- Phase 2: [NOT STARTED] - Stage restructure (needs enhancement)
- Phase 3: [NOT STARTED] - With-prompt mode (needs OpenAgents patterns)
- Phase 4: [NOT STARTED] - Interactive mode (needs structured questions)
- Phase 5: [NOT STARTED] - Task creation logic (needs {NNN} format)
- Phase 6: [NOT STARTED] - Output cleanup (ready to implement)

### Key Changes
1. **Consistent numbering format**: Use `{NNN}` (padded 3-digit) throughout instead of `{N}`
2. **Structured question pattern**: Add `<ask>`, `<examples>`, `<capture>` structure from OpenAgents
3. **Existing system detection**: Add comprehensive Stage 0 for analyzing current .claude/ structure
4. **Interview patterns section**: Add explicit documentation of progressive disclosure, adaptive questioning, example-driven, and validation checkpoints patterns
5. **Enhanced checkpoints**: Every stage now has explicit checkpoint with validation criteria

## Overview

The /meta command currently bypasses the task management system and directly implements changes. This plan refactors it to:
1. Detect and analyze existing .claude/ system (Stage 0)
2. Interview user or analyze prompt to understand requirements
3. Break down work into discrete tasks with dependencies
4. Present task list for user confirmation (mandatory)
5. Create tasks in TODO.md + state.json (NOT implement directly)

The refactor follows patterns from OpenAgents meta.md (research-002.md) and the existing refactor guide at `.claude/specs/meta-command-refactor-guide.md`.

## Phases

### Phase 1: Add Constraints and Update Frontmatter

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add explicit FORBIDDEN/REQUIRED constraints section
2. Add AskUserQuestion to allowed-tools
3. Update description to reflect task-creation focus

**Files to modify**:
- `.claude/commands/meta.md` - Add constraints, update frontmatter

**Steps**:
1. Update frontmatter allowed-tools:
   ```yaml
   allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(jq:*), Bash(mkdir:*), Bash(sed:*), Task, TodoWrite, AskUserQuestion
   ```

2. Add prominent "## Constraints" section immediately after the command description:
   ```markdown
   ## Constraints

   **FORBIDDEN** - This command MUST NOT:
   - Directly create commands, skills, rules, or context files
   - Directly modify CLAUDE.md or ARCHITECTURE.md
   - Implement any work without user confirmation
   - Write any files outside .claude/specs/

   **REQUIRED** - This command MUST:
   - Track all work via tasks in TODO.md + state.json
   - Require explicit user confirmation before creating any tasks
   - Create plan artifacts for each task when appropriate
   - Follow the staged workflow with checkpoints
   ```

3. Update the command description to emphasize task creation:
   ```
   Interactive system builder that creates TASKS for agent architecture changes (never implements directly).
   ```

**Verification**:
- Frontmatter includes AskUserQuestion and jq/mkdir/sed
- Constraints section is prominently placed after description
- Running /meta --analyze still works (read-only mode)

---

### Phase 2: Add Existing System Detection (Stage 0)

**Estimated effort**: 45 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add Stage 0: DetectExistingSystem following OpenAgents pattern
2. Scan current .claude/ structure
3. Present merge/extend options when relevant

**Files to modify**:
- `.claude/commands/meta.md` - Add Stage 0

**Steps**:
1. Add Stage 0 before current Stage 1:
   ```markdown
   ### Stage 0: DetectExistingSystem

   **Action**: Analyze existing .claude/ structure and identify relevant context

   **Process**:
   1. Scan for existing commands: `ls .claude/commands/*.md`
   2. Scan for existing skills: `ls .claude/skills/*/SKILL.md`
   3. Scan for existing rules: `ls .claude/rules/*.md`
   4. Identify active tasks: `jq '.active_projects | length' .claude/specs/state.json`
   5. Check for related existing tasks based on prompt keywords

   **Output** (when existing system detected):
   ```
   ## Existing .claude/ System Detected

   **Components**:
   - Commands: {NNN} (/{cmd1}, /{cmd2}, ...)
   - Skills: {NNN} ({skill1}, {skill2}, ...)
   - Rules: {NNN}
   - Active Tasks: {NNN}

   **Related Existing Tasks** (if any match prompt keywords):
   - Task #{NNN}: {title} [{status}]

   **Options**:
   1. **Extend** - Add new tasks that integrate with existing system
   2. **Independent** - Create standalone tasks
   3. **Cancel** - Exit without changes
   ```

   **Checkpoint**: Existing system analyzed and approach selected
   ```

**Verification**:
- Stage 0 scans .claude/ structure
- Related tasks identified by keyword matching
- Options presented for how to proceed

---

### Phase 3: Restructure Stage Flow with Checkpoints

**Estimated effort**: 1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Replace 8-stage direct-generation flow with 10-stage task-creation flow
2. Add explicit checkpoints after each stage with validation criteria
3. Document interview patterns section

**Files to modify**:
- `.claude/commands/meta.md` - Complete stage restructure

**Steps**:
1. Define new stage structure (note: stages use consistent naming):
   ```
   Stage 0: DetectExistingSystem - Analyze .claude/ structure
   Stage 1: InitiateInterview - Greet user, explain process, set expectations
   Stage 2: GatherDomainInfo - Collect purpose, scope, domain (2-3 questions)
   Stage 2.5: DetectDomainType - Classify: lean, meta, latex, general
   Stage 3: IdentifyUseCases - Break down into discrete tasks (2-3 questions)
   Stage 4: AssessComplexity - Estimate effort, identify dependencies
   Stage 5: ReviewAndConfirm - Present task list, REQUIRE user confirmation
   Stage 6: CreateTasks - Create entries in TODO.md + state.json
   Stage 7: DeliverSummary - Show created tasks, suggest next steps
   ```

2. Add checkpoint after each stage with validation criteria:
   ```markdown
   **Checkpoint**: {Stage name} complete
   - [ ] {Validation criterion 1}
   - [ ] {Validation criterion 2}

   Proceed to Stage {N+1}? [Yes/Clarify/Cancel]
   ```

3. Add Interview Patterns section (from OpenAgents):
   ```markdown
   ## Interview Patterns

   ### Progressive Disclosure
   Start with broad questions, then drill into specifics based on responses.

   ### Adaptive Questioning
   Adjust question complexity based on user's technical level and domain familiarity.

   ### Example-Driven
   Provide concrete examples for every question to guide user thinking.

   ### Validation Checkpoints
   Summarize and confirm understanding after each phase before proceeding.
   ```

4. Move "Generation Templates" to appendix labeled "Reference: Component Templates (for /implement)"

**Verification**:
- All stages documented with explicit checkpoints
- Stage 5 (ReviewAndConfirm) requires user confirmation
- Stage 6 is CreateTasks (not Generation)
- Interview patterns documented

---

### Phase 4: Implement Structured Question Patterns

**Estimated effort**: 1.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Use OpenAgents question structure pattern for all interview questions
2. Define explicit capture variables for each question
3. Include examples with each question

**Files to modify**:
- `.claude/commands/meta.md` - Add structured questions

**Steps**:
1. Define Stage 2 (GatherDomainInfo) questions with structure:
   ```markdown
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
   ```

2. Define Stage 3 (IdentifyUseCases) with task breakdown:
   ```markdown
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
   - [ ] Task count determined ({NNN} tasks)
   - [ ] Dependencies mapped
   - [ ] Each task is discrete and actionable
   ```

3. Define Stage 4 (AssessComplexity):
   ```markdown
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
   ```

**Verification**:
- All questions have Ask/Examples/Capture structure
- Checkpoints validate captured data
- Questions use AskUserQuestion tool format

---

### Phase 5: Implement With-Prompt Mode

**Estimated effort**: 1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Define abbreviated workflow when prompt is provided
2. Use AskUserQuestion for clarification and confirmation
3. Jump directly to analysis without full interview

**Files to modify**:
- `.claude/commands/meta.md` - Add "With Prompt Mode" section

**Steps**:
1. Add "## With Prompt Mode" section:
   ```markdown
   ## With Prompt Mode

   When $ARGUMENTS contains a prompt (not a flag):

   ### Abbreviated Flow
   - Stage 0: DetectExistingSystem (always runs)
   - Stage 2.5: DetectDomainType from prompt keywords
   - Stage 3-4: Analyze prompt to identify tasks and estimate complexity
   - Stage 5: Present task breakdown with confirmation
   - Stage 6-7: Create tasks and summarize

   ### Analysis Process
   1. Parse prompt for keywords indicating:
      - Language: "lean", "proof", "theorem" → lean; "command", "skill", "agent" → meta
      - Scope: component names, file paths, feature areas
      - Change type: "fix", "add", "refactor", "document"

   2. Check for related existing tasks via keyword matching

   3. Propose task breakdown based on analysis

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
   ```

2. Document task proposal output format:
   ```markdown
   ### Task Proposal Format (Stage 5)

   ```
   ## Proposed Tasks

   Based on your request, I propose creating {NNN} task(s):

   ### Task {NNN}: {Title}
   - **Language**: {language}
   - **Priority**: {priority}
   - **Effort**: {estimate}
   - **Dependencies**: None

   ### Task {NNN}: {Title}
   - **Language**: {language}
   - **Priority**: {priority}
   - **Effort**: {estimate}
   - **Dependencies**: Task #{NNN}

   ---
   **Total Estimated Effort**: {sum} hours

   Proceed with task creation?
   - Yes, create these tasks
   - Revise - I want to adjust
   - Cancel
   ```
   ```

**Verification**:
- With-prompt mode has clear abbreviated flow
- AskUserQuestion used for clarification
- Task proposal uses {NNN} format

---

### Phase 6: Implement No-Prompt Interactive Mode

**Estimated effort**: 1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Define full interview workflow for no-prompt invocation
2. Follow OpenAgents progressive disclosure pattern
3. All questions use structured format

**Files to modify**:
- `.claude/commands/meta.md` - Add "Interactive Mode" section

**Steps**:
1. Add "## Interactive Mode (No Arguments)" section:
   ```markdown
   ## Interactive Mode (No Arguments)

   When $ARGUMENTS is empty, run full interview:

   ### Stage 1: InitiateInterview

   ```
   ## Building Your Task Plan

   I'll help you create structured tasks for your .claude/ system changes.

   **Process** (5-10 minutes):
   1. Understand what you want to accomplish
   2. Break down into discrete tasks
   3. Review and confirm task list
   4. Create tasks in TODO.md

   **What You'll Get**:
   - {NNN} task(s) in TODO.md and state.json
   - Clear descriptions and priorities
   - Dependencies mapped between tasks
   - Ready for /research → /plan → /implement cycle

   Let's begin!
   ```

   **Checkpoint**: User understands process and is ready
   ```

2. Reference Stage 2-4 questions (from Phase 4)

3. Add Stage 5 (ReviewAndConfirm) with explicit confirmation:
   ```markdown
   ### Stage 5: ReviewAndConfirm

   **CRITICAL**: User MUST confirm before any task creation.

   Present comprehensive summary:
   ```
   ## Task Summary

   **Domain**: {domain}
   **Purpose**: {purpose}
   **Scope**: {affected_components}

   **Tasks to Create** ({NNN} total):

   | # | Title | Language | Priority | Effort | Dependencies |
   |---|-------|----------|----------|--------|--------------|
   | {NNN} | {title} | {lang} | {pri} | {hrs} | None |
   | {NNN} | {title} | {lang} | {pri} | {hrs} | #{NNN} |

   **Total Estimated Effort**: {sum} hours

   ---

   Does this look correct?
   - ✅ **Proceed** - Create these tasks
   - 🔄 **Revise** - Adjust task breakdown
   - ❌ **Cancel** - Exit without creating tasks
   ```

   **Checkpoint**: User has explicitly confirmed task creation
   - [ ] User selected "Proceed"
   - [ ] All tasks have required fields
   ```

**Verification**:
- Interactive mode follows full interview flow
- Stage 5 requires explicit confirmation
- All outputs use {NNN} format

---

### Phase 7: Implement Task Creation Logic

**Estimated effort**: 45 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Document task creation steps using jq patterns with {NNN} format
2. Include dependency tracking in state.json
3. Add proper TODO.md entries with links

**Files to modify**:
- `.claude/commands/meta.md` - Add "Stage 6: CreateTasks" implementation

**Steps**:
1. Document Stage 6 (CreateTasks) with jq patterns:
   ```markdown
   ### Stage 6: CreateTasks

   **Action**: Create task entries in TODO.md and state.json

   **Process** (for each task):

   ```bash
   # 1. Get next task number (will become {NNN})
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

2. Show TODO.md entry format with {NNN}:
   ```markdown
   ### {NNN}. {Title}
   - **Effort**: {estimate}
   - **Status**: [NOT STARTED]
   - **Priority**: {priority}
   - **Language**: {language}
   - **Dependencies**: Task #{NNN}, Task #{NNN}

   **Description**: {description}

   ---
   ```

3. Document git commit:
   ```bash
   git add .claude/specs/
   git commit -m "meta: create {NNN} tasks for {domain}"
   ```

   Note: {NNN} in commit message is the COUNT of tasks, not a task number.

**Verification**:
- All task numbers use {NNN} format
- Dependencies tracked in both state.json and TODO.md
- Git commit follows project conventions

---

### Phase 8: Update Output Format and Clean Up

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Update Stage 7 (DeliverSummary) output format
2. Remove --generate mode
3. Clean up obsolete sections

**Files to modify**:
- `.claude/commands/meta.md` - Update output, remove obsolete content

**Steps**:
1. Update Stage 7 output format:
   ```markdown
   ### Stage 7: DeliverSummary

   ```
   ## Tasks Created

   Created {NNN} task(s) for {domain}:

   **High Priority**:
   - Task #{NNN}: {title}
     Path: .claude/specs/{NNN}_{slug}/

   **Medium Priority**:
   - Task #{NNN}: {title} (depends on #{NNN})
     Path: .claude/specs/{NNN}_{slug}/

   **Low Priority**:
   - Task #{NNN}: {title}
     Path: .claude/specs/{NNN}_{slug}/

   ---

   **Next Steps**:
   1. Review tasks in TODO.md
   2. Run `/research {NNN}` to begin research on first task
   3. Progress through /research → /plan → /implement cycle

   **Suggested Order** (respecting dependencies):
   1. Task #{NNN} (no dependencies)
   2. Task #{NNN} (depends on #{NNN})
   ```
   ```

2. Remove --generate from Arguments section:
   ```markdown
   ## Arguments

   - No args: Start interactive interview
   - `PROMPT` - Direct analysis of change request
   - `--analyze` - Analyze existing .claude/ structure (read-only)

   Note: --generate mode removed. Use /implement for task execution.
   ```

3. Move templates to reference appendix:
   ```markdown
   ## Appendix: Reference Templates

   These templates are for reference only. Actual file creation happens during /implement, not /meta.

   ### Command Template Reference
   ...

   ### Skill Template Reference
   ...
   ```

**Verification**:
- Output shows created tasks with {NNN} format
- --generate mode removed
- Templates clearly labeled as reference-only

---

## Dependencies

- Task #306 should be abandoned (duplicate task with missing artifacts)
- Task #386 (artifact linking) should be fixed first or in parallel

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing /meta --analyze | Medium | Low | Test --analyze mode after each phase |
| Over-complication of interview | Medium | Medium | Keep to 2-3 questions per stage, use examples |
| Users expecting direct implementation | High | Medium | Clear messaging in Stage 1 and Constraints section |
| Inconsistent {NNN} vs {N} usage | Low | Low | Regex search before committing each phase |

## Success Criteria

- [ ] /meta with prompt proposes tasks and requires confirmation before creation
- [ ] /meta without prompt runs full interview with structured questions
- [ ] All task numbers use padded {NNN} format consistently
- [ ] Tasks created with proper dependencies in state.json
- [ ] Tasks linked properly in TODO.md with {NNN} format
- [ ] /meta --analyze still works (read-only analysis)
- [ ] No direct file creation outside .claude/specs/
- [ ] Interview patterns section documents all four patterns

## Rollback Plan

If implementation fails:
1. Revert `.claude/commands/meta.md` to previous version via git
2. The existing meta-command-refactor-guide.md remains as documentation
3. Users can manually create tasks via /task command
