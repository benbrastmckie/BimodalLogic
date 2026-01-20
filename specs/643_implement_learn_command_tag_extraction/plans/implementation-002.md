# Implementation Plan: Task #643

- **Task**: 643 - implement_learn_command_tag_extraction
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/643_implement_learn_command_tag_extraction/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false
- **Revision**: v002 - Added Phase 7 for documentation updates

## Overview

Implement the `/learn` command that scans codebase files for `FIX:`, `NOTE:`, and `TODO:` tags and creates structured tasks based on tag types. The implementation follows the thin-wrapper skill pattern with a dedicated `learn-agent` that handles tag extraction, grouping, and conditional task creation. The command creates fix-it-tasks (from FIX: and NOTE: tags), learn-it-tasks (from NOTE: tags for context file updates), and individual todo-tasks (from TODO: tags).

**Revision v002**: Added Phase 7 to update documentation files (`.claude/docs/` and `.claude/context/core/`) to document the new command-skill-agent pattern and the `/learn` workflow process.

### Research Integration

Key findings from research-001.md integrated into this plan:
- Comment syntax varies by file type: Lean (`--`), LaTeX (`%`), Markdown (`<!--`), Python/shell (`#`)
- Regex pattern: `(--|%|#|<!--)\s*(FIX|NOTE|TODO):\s*(.*)`
- Context routing heuristics for NOTE: tags based on source file type
- Task creation uses existing jq patterns from `/task` command
- Dry-run mode essential for user review before task creation

## Goals & Non-Goals

**Goals**:
- Create `/learn` command with path and --dry-run argument support
- Create `skill-learn` as thin wrapper delegating to `learn-agent`
- Create `learn-agent` with tag extraction, grouping, and task creation logic
- Support conditional task creation based on tag presence
- Group related tags appropriately (FIX:/NOTE: for fix-it, NOTE: for learn-it, individual TODO: for todo-tasks)
- **Document the new command-skill-agent in `.claude/docs/` and `.claude/context/core/` files**

**Non-Goals**:
- Multi-line tag continuation support (deferred to future enhancement)
- Automatic tag removal after task creation
- Integration with external issue trackers
- Real-time file watching for new tags

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Tag parsing misses edge cases | Medium | Medium | Start with simple patterns, test with existing codebase tags |
| Too many tasks created at once | Medium | Low | Require --dry-run review, add confirmation for >10 tasks |
| Context routing inaccurate for NOTE: tags | Low | Medium | Use conservative defaults, allow manual correction |
| jq escaping issues in task creation | Medium | Medium | Use two-step jq pattern from jq-escaping-workarounds.md |
| Documentation inconsistency | Low | Low | Update all relevant doc files in single phase |

## Implementation Phases

### Phase 1: Command and Skill Creation [NOT STARTED]

**Goal**: Create the command entry point and skill wrapper with proper argument handling

**Tasks**:
- [ ] Create `.claude/commands/learn.md` with argument parsing (paths, --dry-run)
- [ ] Create `.claude/skills/skill-learn/` directory
- [ ] Create `.claude/skills/skill-learn/SKILL.md` following thin-wrapper pattern
- [ ] Implement mode detection (paths vs --dry-run vs default)
- [ ] Implement delegation context preparation with session_id

**Timing**: 45 minutes

**Files to modify**:
- `.claude/commands/learn.md` - New command definition
- `.claude/skills/skill-learn/SKILL.md` - New skill definition

**Verification**:
- Command file passes YAML frontmatter validation
- Skill file has proper name, description, allowed-tools in frontmatter
- Arguments are correctly parsed and mode detected

---

### Phase 2: Agent Foundation [NOT STARTED]

**Goal**: Create the learn-agent with proper structure, context loading, and execution flow

**Tasks**:
- [ ] Create `.claude/agents/learn-agent.md` with YAML frontmatter
- [ ] Define allowed tools (Grep, Read, Write, Edit, Bash, Glob)
- [ ] Define context references and lazy loading strategy
- [ ] Implement Stage 1: Parse delegation context
- [ ] Implement Stage 2: Validate input paths (if provided)
- [ ] Define metadata file output location and schema

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/learn-agent.md` - New agent definition

**Verification**:
- Agent file recognized by Claude Code (has valid frontmatter)
- Delegation context parsing extracts session_id, paths, dry_run flag
- Stage structure follows existing agent patterns

---

### Phase 3: Tag Extraction Logic [NOT STARTED]

**Goal**: Implement comprehensive tag scanning across all supported file types

**Tasks**:
- [ ] Implement file type detection based on extension
- [ ] Create regex patterns for each comment style:
  - Lean: `--\s*(FIX|NOTE|TODO):\s*(.*)`
  - LaTeX: `%\s*(FIX|NOTE|TODO):\s*(.*)`
  - Markdown: `<!--\s*(FIX|NOTE|TODO):\s*(.*?)(?:\s*-->)?`
  - Python/Shell/YAML: `#\s*(FIX|NOTE|TODO):\s*(.*)`
- [ ] Use Grep tool with glob patterns for each file type
- [ ] Extract tag content (text after TAG:) with file path and line number
- [ ] Handle case where tag spans to end of line vs inline

**Timing**: 45 minutes

**Files to modify**:
- `.claude/agents/learn-agent.md` - Add tag extraction section

**Verification**:
- Can extract tags from existing codebase (use actual FIX:/NOTE:/TODO: tags)
- Tag content correctly parsed (full text after colon)
- File path and line number captured for each tag

---

### Phase 4: Tag Grouping and Task Generation [NOT STARTED]

**Goal**: Implement tag grouping logic and task creation for all three task types

**Tasks**:
- [ ] Implement fix-it-task grouping:
  - Combine all FIX: and NOTE: tags into single task description
  - Include file paths and line references
  - Set language based on predominant file type
- [ ] Implement learn-it-task grouping:
  - Group NOTE: tags by target context directory (using routing heuristics)
  - Create description referencing which context files to update
  - Set language to "meta"
- [ ] Implement todo-task generation:
  - One task per TODO: tag
  - Preserve original text as task description
  - Detect language from source file type
- [ ] Implement conditional task creation (only create task type if tags found)
- [ ] Implement jq patterns for state.json and TODO.md updates

**Timing**: 45 minutes

**Files to modify**:
- `.claude/agents/learn-agent.md` - Add task generation section

**Verification**:
- Fix-it-task created only when FIX: or NOTE: tags exist
- Learn-it-task created only when NOTE: tags exist
- Each TODO: tag creates individual task
- Tasks have correct language, priority, descriptions

---

### Phase 5: Dry-Run and Confirmation Flow [NOT STARTED]

**Goal**: Implement preview mode and user confirmation for task creation

**Tasks**:
- [ ] Implement --dry-run output format:
  - Show tag counts by type
  - Preview task titles and descriptions
  - Show file/line references for each tag
  - Display total tasks that would be created
- [ ] Implement confirmation prompt (when not in dry-run mode):
  - Display summary of tasks to create
  - Allow user to proceed or cancel
- [ ] Implement >10 tasks warning with explicit confirmation

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/learn-agent.md` - Add dry-run and confirmation sections

**Verification**:
- Dry-run shows accurate preview without creating tasks
- Confirmation required for non-dry-run execution
- Warning displayed when >10 tasks would be created

---

### Phase 6: Integration and Postflight [NOT STARTED]

**Goal**: Complete the workflow with proper metadata handling and git commit

**Tasks**:
- [ ] Implement metadata file writing to `.return-meta.json`
- [ ] Update skill with postflight handling:
  - Read metadata file
  - Git commit if tasks were created
  - Clean up metadata file
- [ ] Implement brief text summary return (not JSON)
- [ ] Add error handling for:
  - No tags found
  - Path validation failures
  - jq/git failures

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/learn-agent.md` - Add return and error handling sections
- `.claude/skills/skill-learn/SKILL.md` - Add postflight handling

**Verification**:
- Metadata file written with correct schema
- Git commit created with appropriate message
- Text summary returned (not JSON)
- Graceful handling when no tags found

---

### Phase 7: Documentation Updates [NOT STARTED]

**Goal**: Update documentation to reflect the new /learn command-skill-agent and its process

**Tasks**:
- [ ] Update `.claude/docs/README.md`:
  - Add `/learn` to Commands section (10 commands)
  - Add `skill-learn` to Skills section (10 skills)
  - Add `learn-agent` to Agents section (7 agents)
  - Update counts throughout
- [ ] Update `CLAUDE.md` (if needed):
  - Add `/learn` to Command Workflows section (if appropriate)
  - Add skill-to-agent mapping entry
- [ ] Create `.claude/docs/examples/learn-flow-example.md`:
  - End-to-end example showing `/learn path/to/dir --dry-run`
  - Show resulting task creation flow
  - Explain fix-it, learn-it, and todo-task differentiation
- [ ] Update `.claude/context/core/orchestration/routing.md`:
  - Add routing entry for `/learn` command
  - Document how it differs from other commands (creates multiple task types)
- [ ] Update `.claude/context/core/standards/task-management.md`:
  - Document the tag-based task creation pattern
  - Add section on NOTE: → context file updates workflow

**Timing**: 45 minutes

**Files to modify**:
- `.claude/docs/README.md` - Update command/skill/agent counts and add entries
- `CLAUDE.md` - Add skill-to-agent mapping (if appropriate)
- `.claude/docs/examples/learn-flow-example.md` - New example file
- `.claude/context/core/orchestration/routing.md` - Add routing entry
- `.claude/context/core/standards/task-management.md` - Document tag-based workflow

**Verification**:
- All counts in README.md are accurate
- Example file demonstrates complete workflow
- Routing documentation is consistent with implementation
- Task management standards include new pattern

---

## Testing & Validation

- [ ] Run `/learn --dry-run` on project root and verify tag extraction
- [ ] Run `/learn docs/` and verify scoped scanning works
- [ ] Verify FIX: tags in LaTeX files are detected (04-Metalogic.tex:89)
- [ ] Verify TODO: tags in Lean files are detected (RunEnvLinters.lean:67)
- [ ] Verify NOTE: tags create both fix-it and learn-it tasks
- [ ] Verify tasks are created in TODO.md and state.json with proper format
- [ ] Verify git commit message follows convention
- [ ] Test with no tags found - should report gracefully
- [ ] Verify documentation reflects actual implementation

## Artifacts & Outputs

- `.claude/commands/learn.md` - Command definition
- `.claude/skills/skill-learn/SKILL.md` - Skill wrapper
- `.claude/agents/learn-agent.md` - Agent implementation
- `.claude/docs/examples/learn-flow-example.md` - Usage example
- `specs/643_implement_learn_command_tag_extraction/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation causes issues:
1. Remove command file: `rm .claude/commands/learn.md`
2. Remove skill directory: `rm -rf .claude/skills/skill-learn/`
3. Remove agent file: `rm .claude/agents/learn-agent.md`
4. Remove example file: `rm .claude/docs/examples/learn-flow-example.md`
5. Revert documentation changes in `.claude/docs/README.md`
6. Revert state.json and TODO.md changes if any tasks were created
7. All changes are in `.claude/` and `specs/` directories - no core project files affected
