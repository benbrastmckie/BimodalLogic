# Implementation Plan: Task #385

**Task**: Refactor /meta command to create tasks instead of direct implementation
**Version**: 001
**Created**: 2026-01-12
**Language**: meta

## Overview

The /meta command currently bypasses the task management system and directly implements changes. This plan refactors it to:
1. Analyze requirements (with prompt) or interview user (no prompt)
2. Break down work into discrete tasks with dependencies
3. Present task list for user confirmation
4. Create tasks in TODO.md + state.json (NOT implement directly)

The refactor follows patterns from OpenAgents meta.md and the existing refactor guide at `.claude/specs/meta-command-refactor-guide.md`.

## Phases

### Phase 1: Add Constraints and Update Frontmatter

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add explicit FORBIDDEN/REQUIRED constraints section
2. Add AskUserQuestion to allowed-tools
3. Update description to reflect task-creation focus

**Files to modify**:
- `.claude/commands/meta.md` - Add constraints, update frontmatter

**Steps**:
1. Add `AskUserQuestion` to allowed-tools in frontmatter
2. Add `Bash(jq:*)`, `Bash(mkdir:*)` for task creation operations
3. Add prominent "## Constraints" section after description stating:
   - FORBIDDEN: Direct creation of commands, skills, rules, context files
   - FORBIDDEN: Direct modification of CLAUDE.md or ARCHITECTURE.md
   - REQUIRED: All work tracked via tasks in TODO.md + state.json
   - REQUIRED: User confirmation before creating any tasks
4. Update the command description to emphasize task creation

**Verification**:
- Frontmatter includes AskUserQuestion
- Constraints section is prominently placed
- Running /meta --analyze still works (read-only mode)

---

### Phase 2: Restructure Stage Flow

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Replace 8-stage direct-generation flow with 9-stage task-creation flow
2. Add explicit checkpoints after each stage
3. Remove generation templates (move to reference only)

**Files to modify**:
- `.claude/commands/meta.md` - Complete stage restructure

**Steps**:
1. Replace current stages with new structure:
   - Stage 0: DetectExistingSystem - Analyze .claude/ structure
   - Stage 1: InitiateInterview - Explain process (if no prompt)
   - Stage 2: GatherRequirements - Collect domain/purpose info
   - Stage 3: DetectLanguage - Classify: lean, meta, latex, general
   - Stage 4: IdentifyTasks - Break down into discrete tasks
   - Stage 5: AssessComplexity - Estimate effort, dependencies
   - Stage 6: ReviewAndConfirm - Present task list, require confirmation
   - Stage 7: CreateTasks - Create entries in TODO.md + state.json
   - Stage 8: DeliverSummary - Show tasks, suggest next steps

2. Add checkpoint after each stage:
   ```
   **Checkpoint**: {What must be true before proceeding}
   ```

3. Move "Generation Templates" to an appendix section labeled "Reference Only"

**Verification**:
- All 9 stages are documented with checkpoints
- Stage 6 (ReviewAndConfirm) explicitly requires user confirmation
- Stage 7 is CreateTasks, not Generation
- Templates are reference-only, not for direct use

---

### Phase 3: Implement With-Prompt Mode

**Estimated effort**: 1.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Define analysis workflow when prompt is provided
2. Use AskUserQuestion for clarification
3. Present task breakdown for confirmation

**Files to modify**:
- `.claude/commands/meta.md` - Add "With Prompt Mode" section

**Steps**:
1. Add "## With Prompt Mode" section describing abbreviated flow:
   - Stage 0: Analyze .claude/ structure and prompt context
   - Stage 3: Detect language from prompt keywords
   - Stage 4-5: Identify tasks and dependencies from prompt
   - Stage 6: Present task breakdown with AskUserQuestion:
     ```
     AskUserQuestion:
       question: "I've analyzed your request and propose creating these tasks. Proceed?"
       options:
         - "Yes, create these tasks"
         - "Revise - I want to adjust"
         - "Cancel"
     ```
   - Stage 7-8: Create tasks and summarize

2. Document when to use AskUserQuestion:
   - Ambiguous requirements
   - Multiple valid interpretations
   - Confirming task breakdown

3. Show example output format for task proposal:
   ```
   ## Proposed Tasks

   ### Task 1: {title} (High Priority)
   - **Language**: meta
   - **Effort**: 2-3 hours
   - **Dependencies**: None

   ### Task 2: {title} (Medium Priority)
   - **Language**: meta
   - **Effort**: 1-2 hours
   - **Dependencies**: Task 1

   Proceed with task creation? [Yes/Revise/Cancel]
   ```

**Verification**:
- With-prompt mode documented with clear stages
- AskUserQuestion used for confirmation
- Example shows task proposal format

---

### Phase 4: Implement No-Prompt Interactive Mode

**Estimated effort**: 1.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Define full interview workflow for no-prompt invocation
2. Structure questions with examples (OpenAgents pattern)
3. Include validation checkpoints

**Files to modify**:
- `.claude/commands/meta.md` - Add "Interactive Mode" section

**Steps**:
1. Add "## Interactive Mode (No Arguments)" section with full interview:

   Stage 1 (InitiateInterview):
   ```
   ## Building Your Task Plan

   I'll help you create a structured set of tasks for your .claude/ system changes.

   **Process Overview**:
   - Phase 1: Understand what you want to accomplish (2-3 questions)
   - Phase 2: Break down into tasks (2-3 questions)
   - Phase 3: Review and confirm task list

   Let's begin!
   ```

   Stage 2 (GatherRequirements) - Structure each question:
   ```
   **Question 1**: What do you want to accomplish?

   Examples:
   - "Add a new command for X"
   - "Fix a bug in Y"
   - "Refactor Z for better performance"
   - "Create documentation for W"

   **Capture**: purpose, scope, domain
   ```

   Stage 4-5 (IdentifyTasks, AssessComplexity):
   ```
   **Question 2**: Can this be broken into smaller tasks?

   Examples:
   - "Yes, there are 3 distinct steps"
   - "No, it's a single focused change"
   - "Maybe - I'm not sure how to break it down"
   ```

2. Add validation checkpoints:
   ```
   **Checkpoint**: Requirements clearly understood
   - Domain: {identified}
   - Purpose: {clear}
   - Scope: {defined}

   Proceed to task identification? [Yes/Clarify]
   ```

**Verification**:
- Interactive mode has structured questions with examples
- Each stage has a checkpoint
- Questions use AskUserQuestion tool

---

### Phase 5: Implement Task Creation Logic

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Document task creation steps using jq patterns
2. Include dependency tracking in state.json
3. Add artifact links in TODO.md

**Files to modify**:
- `.claude/commands/meta.md` - Add "Stage 7: CreateTasks" implementation

**Steps**:
1. Document Stage 7 (CreateTasks) with jq patterns:
   ```bash
   # For each task identified:

   # 1. Get next task number
   next_num=$(jq -r '.next_project_number' .claude/specs/state.json)

   # 2. Create task directory
   mkdir -p .claude/specs/{N}_{SLUG}

   # 3. Update state.json with dependencies
   jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
     '.next_project_number = {NEW} |
      .active_projects = [{
        "project_number": {N},
        "project_name": "{slug}",
        "status": "not_started",
        "language": "{lang}",
        "priority": "{pri}",
        "dependencies": [{dep_numbers}],
        "created": $ts,
        "last_updated": $ts
      }] + .active_projects' \
     .claude/specs/state.json > /tmp/state.json && \
     mv /tmp/state.json .claude/specs/state.json

   # 4. Update TODO.md frontmatter
   sed -i 's/^next_project_number: [0-9]*/next_project_number: {NEW}/' \
     .claude/specs/TODO.md

   # 5. Add entry to TODO.md with dependencies
   ```

2. Show TODO.md entry format with dependencies:
   ```markdown
   ### {NNN}. {Title}
   - **Effort**: {estimate}
   - **Status**: [NOT STARTED]
   - **Priority**: {priority}
   - **Language**: {language}
   - **Dependencies**: Task #{dep1}, Task #{dep2}

   **Description**: {description}
   ```

3. Document git commit pattern:
   ```bash
   git add .claude/specs/
   git commit -m "meta: create {N} tasks for {domain}"
   ```

**Verification**:
- Task creation uses jq patterns from /task command
- Dependencies tracked in state.json and TODO.md
- Git commit follows project conventions

---

### Phase 6: Update Output Format and Clean Up

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update Stage 8 (DeliverSummary) output format
2. Remove --generate mode (no longer applicable)
3. Clean up obsolete sections

**Files to modify**:
- `.claude/commands/meta.md` - Update output, remove obsolete content

**Steps**:
1. Update Stage 8 output format:
   ```
   ## Tasks Created

   Created {N} tasks for {domain}:

   **High Priority**:
   - Task #{N1}: {title}
     Path: .claude/specs/{N1}_{SLUG}/

   **Medium Priority**:
   - Task #{N2}: {title} (depends on #{N1})
     Path: .claude/specs/{N2}_{SLUG}/

   **Next Steps**:
   1. Review tasks in TODO.md
   2. Run `/research {N1}` to begin research on first task
   3. Progress through /research → /plan → /implement cycle
   ```

2. Remove or update --generate mode:
   - Remove from Arguments section
   - Note: Task-based workflow doesn't need regeneration

3. Move "Generation Templates" appendix to reference section:
   - Label as "Reference: Component Templates"
   - Note these are for /implement, not /meta

**Verification**:
- Output shows created tasks with paths
- --generate mode removed or deprecated
- Templates clearly labeled as reference

---

## Dependencies

- Task #306 should be abandoned (duplicate task with missing artifacts)
- Task #386 (artifact linking) may be implemented in parallel

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing /meta --analyze | Medium | Low | Test --analyze mode after each phase |
| Over-complication of interview | Medium | Medium | Keep questions simple, 2-3 per stage max |
| Users expecting direct implementation | High | Medium | Clear messaging in Stage 1 about task-creation focus |

## Success Criteria

- [ ] /meta with prompt proposes tasks and requires confirmation before creation
- [ ] /meta without prompt runs full interview before task creation
- [ ] Tasks created with proper dependencies in state.json
- [ ] Tasks linked properly in TODO.md
- [ ] /meta --analyze still works (read-only analysis)
- [ ] No direct file creation outside .claude/specs/

## Rollback Plan

If implementation fails:
1. Revert `.claude/commands/meta.md` to previous version via git
2. The existing meta-command-refactor-guide.md remains as documentation
3. Users can manually create tasks via /task command
