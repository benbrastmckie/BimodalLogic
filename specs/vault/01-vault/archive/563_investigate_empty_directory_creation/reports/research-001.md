# Research Report: Task #563

- **Task**: 563 - Investigate Empty Directory Creation in specs/
- **Started**: 2026-01-17T21:51:30Z
- **Completed**: 2026-01-17T21:55:00Z
- **Effort**: 30 minutes
- **Priority**: Medium
- **Dependencies**: None
- **Sources/Inputs**:
  - `.claude/commands/task.md` - Task creation command
  - `.claude/agents/meta-builder-agent.md` - Meta builder agent
  - `.claude/rules/state-management.md` - State management rules
  - `specs/` directory structure analysis
- **Artifacts**: specs/563_investigate_empty_directory_creation/reports/research-001.md (this file)
- **Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Root cause identified**: The `/task` command creates task directories eagerly at task creation time (step 5 in task.md:62-65), violating the lazy directory creation rule documented in state-management.md
- Empty directories found at two levels: (1) top-level task directories with no artifacts, and (2) empty subdirectories (reports/, plans/, summaries/) within tasks that were partially processed
- The `meta-builder-agent.md` also contains the same violation at lines 331 and 483
- The fix is straightforward: remove the `mkdir -p` step from task creation and ensure directories are only created when first artifacts are written
- **20+ empty directories** exist in specs/ that should not have been created

## Context & Scope

The investigation was triggered by observation of empty directories being created in `specs/` that violate the established lazy directory creation rule. This rule is clearly documented in `.claude/rules/state-management.md`:

> **Directory Creation**: Create task directories lazily (only when first artifact is created)

The scope covers:
1. Identifying where eager directory creation occurs
2. Cataloging affected files/locations
3. Documenting the impact
4. Providing fix recommendations

## Findings

### 1. Primary Violation Location: `/task` Command

**File**: `.claude/commands/task.md`
**Lines**: 62-65

```markdown
5. **Create task directory**:
   ```
   mkdir -p specs/{NUMBER}_{SLUG}
   ```
```

This step runs immediately after creating the slug, before any artifacts exist. Every task created via `/task "description"` gets an empty directory.

### 2. Secondary Violation Location: `meta-builder-agent.md`

**File**: `.claude/agents/meta-builder-agent.md`
**Lines**: 331 and 483

```bash
mkdir -p "specs/${next_num}_${slug}"
```

and

```bash
mkdir -p specs/{N}_{slug}
```

The meta-builder-agent creates directories for each task during the interview process, before any workflow commands are run.

### 3. Empty Directory Inventory

**Top-level empty task directories** (no artifacts created):
- `specs/468_refactor_infinite_canonical_model_code/`
- `specs/469_decidability_decision_procedure/`
- `specs/470_finite_model_computational_optimization/`
- `specs/399_implement_causal_semantics_in_lean/`
- `specs/563_investigate_empty_directory_creation/` (this task, before this report)

**Empty subdirectories** (partial processing):
- `specs/510_mereological_constraints/summaries/`
- `specs/534_research_claude_code_model_selection/summaries/`
- `specs/477_test_document_converter/summaries/`
- `specs/477_test_document_converter/reports/`
- `specs/477_test_document_converter/plans/`
- `specs/476_create_document_converter_agent/summaries/`
- `specs/476_create_document_converter_agent/reports/`
- `specs/476_create_document_converter_agent/plans/`
- `specs/errors/` (system directory with no content)

**Archive empty directories**:
- `specs/archive/471_constructive_model_finiteness_proof/`
- `specs/archive/533_document_workflow_anti_patterns/summaries/`
- `specs/archive/533_document_workflow_anti_patterns/reports/`
- `specs/archive/533_document_workflow_anti_patterns/plans/`
- `specs/archive/527_update_skill_files_specs_path/`
- `specs/archive/531_refactor_status_sync_non_terminal_returns/summaries/`
- `specs/archive/531_refactor_status_sync_non_terminal_returns/reports/`

### 4. Correct Lazy Creation Patterns

The following files correctly implement lazy directory creation:

**`planner-agent.md`** (line 135-137):
```markdown
Create directory if needed:
```
mkdir -p specs/{N}_{SLUG}/plans/
```
```

This is correct because it only runs when actually writing a plan file.

**Research and implementation agents**: Create directories only when writing first artifact.

### 5. Git Tracking Note

Empty directories are not tracked by git. The commit for task 563 (`46149249`) only shows `TODO.md` and `state.json` changes, not the empty directory. This means:
- Empty directories accumulate locally
- They persist across git operations
- They can cause confusion about task state

## Decisions

1. The `/task` command step 5 (`mkdir -p specs/{NUMBER}_{SLUG}`) should be removed
2. The `meta-builder-agent.md` directory creation steps should be removed
3. All agents that create artifacts should ensure they `mkdir -p` the specific subdirectory (reports/, plans/, summaries/) when writing, not the parent directory at task creation

## Recommendations

### High Priority

1. **Remove eager directory creation from task.md**
   - Delete lines 62-65 (step 5: Create task directory)
   - Update step 8 output to not reference "Path: specs/{N}_{SLUG}/"
   - Files: `.claude/commands/task.md`

2. **Remove eager directory creation from meta-builder-agent.md**
   - Delete or comment out lines 331 and 483
   - Files: `.claude/agents/meta-builder-agent.md`

### Medium Priority

3. **Clean up existing empty directories**
   - Run: `find specs/ -type d -empty -delete`
   - This will remove all empty directories
   - Safe because git doesn't track empty directories

4. **Add validation rule**
   - Add a rule or lint check that flags `mkdir -p specs/` patterns that don't include a subdirectory type (reports/, plans/, summaries/)
   - File: `.claude/rules/state-management.md` (add explicit guidance)

### Low Priority

5. **Document the lazy creation pattern more prominently**
   - Add to CLAUDE.md quick reference
   - Ensure all agent templates reference this rule

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking existing workflows | Low | Agents already create subdirs when writing artifacts |
| Confusion about task paths | Low | Task entries in TODO.md don't depend on directory existence |
| Clean command removes wanted empty dirs | Low | No legitimate use case for empty task directories |

## Appendix

### Files to Modify

1. `.claude/commands/task.md` - Remove step 5 (lines 62-65)
2. `.claude/agents/meta-builder-agent.md` - Remove lines 331 and 483
3. `.claude/rules/state-management.md` - Add explicit "DO NOT create directories at task creation" guidance

### Search Commands Used

```bash
# Find empty directories
find specs/ -type d -empty

# Find mkdir patterns
grep -r "mkdir.*specs/" .claude/

# Check specific patterns
grep -rn "mkdir.*-p" .claude/
```

### Reference: Lazy Creation Rule (state-management.md:132-140)

```markdown
## Directory Creation

Create task directories lazily (only when first artifact is created):
```
specs/{NUMBER}_{SLUG}/
├── reports/      # Created on first research
├── plans/        # Created on first plan
└── summaries/    # Created on completion
```
```
