# Research Report: Investigate Artifact Path Errors

**Task**: 222  
**Date**: 2025-12-28  
**Researcher**: task-executor > researcher  
**Session**: sess_1735428122_a7b3c9

## Executive Summary

Root cause identified: **lean-research-agent.md** contains incorrect path pattern missing `.opencode/` prefix at line 497. All other subagents use correct `.opencode/specs/` pattern. This single inconsistency causes artifacts to be created in `/specs/` instead of `/.opencode/specs/`.

## Research Scope

Audited 7 subagents and 5 workflow commands for path usage patterns:
- Subagents: researcher, planner, implementer, task-executor, lean-implementation-agent, lean-research-agent, reviewer
- Commands: /research, /plan, /revise, /implement, /review

## Root Cause Analysis

### Primary Issue: lean-research-agent.md Line 497

**Location**: `.opencode/agent/subagents/lean-research-agent.md:497`

**Incorrect Path**:
```json
"path": "specs/{task_number}_{topic}/reports/research-001.md",
```

**Should Be**:
```json
"path": ".opencode/specs/{task_number}_{topic}/reports/research-001.md",
```

### Impact Assessment

**Affected Files**:
1. `lean-research-agent.md` - 1 instance at line 497 (return format example)

**Confirmed Affected Projects** (created in wrong location):
1. `213_resolve_is_valid_swap_involution_blocker/` - Lean research task
2. `215_fix_todo_command_task_block_removal/` - Lean research task
3. `218_fix_lean_lsp_mcp_integration_and_opencode_module_import_errors/` - Lean research task

**Pattern**: All affected projects are Lean research tasks that used lean-research-agent

**Unaffected Agents** (all use correct `.opencode/specs/` pattern):
- researcher.md (lines 114, 199, 230, 286) - [YES] Correct
- planner.md (lines 122, 230, 264) - [YES] Correct
- implementer.md (lines 210, 242) - [YES] Correct
- task-executor.md (lines 274, 329, 368) - [YES] Correct
- lean-implementation-agent.md (lines 326, 365, 400, 441) - [YES] Correct
- reviewer.md (lines 37, 258, 453) - [YES] Correct

## Detailed Findings

### 1. Path Pattern Analysis

**Correct Pattern** (used by 6/7 subagents):
```
.opencode/specs/{task_number}_{slug}/reports/
.opencode/specs/{task_number}_{slug}/plans/
.opencode/specs/{task_number}_{slug}/summaries/
```

**Incorrect Pattern** (lean-research-agent only):
```
specs/{task_number}_{topic}/reports/
```

### 2. Directory Creation Logic

All subagents correctly implement lazy directory creation:
- Process step mentions creating `.opencode/specs/{number}_{slug}/`
- Directory only created when writing first file
- Follows artifact-management.md standards

**However**, lean-research-agent's return format example shows wrong path, which would cause actual artifact creation in wrong location if agent follows its own example.

### 3. Command Path Usage

All workflow commands use correct `.opencode/specs/` pattern:
- `/research` command - references `.opencode/specs/` in metadata
- `/plan` command - references `.opencode/specs/` in metadata
- `/implement` command - references `.opencode/specs/` in metadata
- `/review` command - explicitly passes `.opencode/specs/{number}_codebase_review` as project_path
- `/revise` command - references existing plan paths in `.opencode/specs/`

### 4. Artifact Creation Flow

**Normal Flow** (researcher, planner, implementer, etc.):
1. Command invokes subagent
2. Subagent creates directory: `.opencode/specs/{number}_{slug}/`
3. Subagent writes artifact with full path
4. Returns artifact path in standardized format
5. [YES] Artifact created in correct location

**Broken Flow** (lean-research-agent):
1. /research command invokes lean-research-agent for Lean task
2. lean-research-agent uses path pattern from its own example (line 497)
3. Creates directory: `specs/{number}_{slug}/` (missing `.opencode/`)
4. Writes artifact to wrong location
5. Returns incorrect path
6. [NO] Artifact created in `/specs/` instead of `/.opencode/specs/`

## Migration Assessment

### Existing Misplaced Artifacts

**Projects to Migrate**:
```
/specs/213_resolve_is_valid_swap_involution_blocker/
/specs/215_fix_todo_command_task_block_removal/
/specs/218_fix_lean_lsp_mcp_integration_and_opencode_module_import_errors/
```

**Migration Strategy**:
1. Move each project directory to `.opencode/specs/`
2. Update artifact links in `.opencode/specs/TODO.md`
3. Update artifact paths in `.opencode/specs/state.json`
4. Verify all internal references updated
5. Remove empty `/specs/` directory

**Risk Assessment**: Low risk
- All artifacts are markdown files (no code dependencies)
- TODO.md and state.json can be updated atomically
- No external references to these paths

## Validation Approach

### Pre-Fix Validation
1. Confirm lean-research-agent.md line 497 has incorrect path
2. Verify all other subagents use correct `.opencode/specs/` pattern
3. Confirm affected projects were created by lean-research-agent

### Post-Fix Validation
1. Update lean-research-agent.md line 497 with correct path
2. Run test research task with lean-research-agent
3. Verify artifact created in `.opencode/specs/`
4. Confirm return path includes `.opencode/` prefix
5. Migrate existing misplaced artifacts
6. Update TODO.md and state.json references
7. Verify TODO.md links work correctly

## Recommendations

### Immediate Fix (High Priority)

**File**: `.opencode/agent/subagents/lean-research-agent.md`  
**Line**: 497  
**Change**:
```diff
- "path": "specs/{task_number}_{topic}/reports/research-001.md",
+ "path": ".opencode/specs/{task_number}_{topic}/reports/research-001.md",
```

### Migration Plan (Medium Priority)

**Phase 1**: Fix Path in lean-research-agent.md
- Update line 497 with correct path pattern
- Verify no other instances in file
- Commit fix

**Phase 2**: Migrate Existing Projects
- Move `/specs/213_*/` → `/.opencode/specs/213_*/`
- Move `/specs/215_*/` → `/.opencode/specs/215_*/`
- Move `/specs/218_*/` → `/.opencode/specs/218_*/`

**Phase 3**: Update References
- Update artifact paths in TODO.md for tasks 213, 215, 218
- Update artifact paths in state.json
- Update any plan file cross-references

**Phase 4**: Cleanup
- Remove empty `/specs/` directory
- Verify no broken links

### Prevention (Low Priority)

**Add Validation Check**:
- Create linter rule to detect path patterns without `.opencode/` prefix
- Add to pre-commit hook or CI validation
- Scan all subagent and command files for correct path patterns

**Documentation**:
- Add path pattern standard to artifact-management.md
- Clarify `.opencode/specs/` as canonical project artifact location
- Add examples showing correct vs incorrect patterns

## Testing Plan

### Unit Tests
1. Test lean-research-agent with Lean research task
2. Verify artifact path includes `.opencode/`
3. Confirm directory created in correct location

### Integration Tests
1. Run `/research {lean_task_number}`
2. Verify artifact created in `.opencode/specs/`
3. Verify TODO.md links work
4. Verify state.json paths correct

### Migration Validation
1. Move one test project (213)
2. Verify TODO.md link works
3. Verify no broken references
4. Apply to remaining projects

## References

### Files Analyzed

**Subagents**:
- `.opencode/agent/subagents/researcher.md` - 4 path instances, all correct
- `.opencode/agent/subagents/planner.md` - 3 path instances, all correct
- `.opencode/agent/subagents/implementer.md` - 2 path instances, all correct
- `.opencode/agent/subagents/task-executor.md` - 3 path instances, all correct
- `.opencode/agent/subagents/lean-implementation-agent.md` - 4 path instances, all correct
- `.opencode/agent/subagents/lean-research-agent.md` - 1 path instance, **INCORRECT** (line 497)
- `.opencode/agent/subagents/reviewer.md` - 3 path instances, all correct

**Commands**:
- `.opencode/command/research.md` - Uses `.opencode/specs/` pattern
- `.opencode/command/plan.md` - Uses `.opencode/specs/` pattern
- `.opencode/command/revise.md` - Uses `.opencode/specs/` pattern
- `.opencode/command/implement.md` - Uses `.opencode/specs/` pattern
- `.opencode/command/review.md` - Explicitly passes `.opencode/specs/` paths

### Affected Artifact Locations

**Actual Misplaced Files**:
```
/specs/213_resolve_is_valid_swap_involution_blocker/reports/research-001.md
/specs/213_resolve_is_valid_swap_involution_blocker/summaries/research-summary.md
/specs/213_resolve_is_valid_swap_involution_blocker/plans/implementation-001.md
/specs/213_resolve_is_valid_swap_involution_blocker/plans/implementation-002.md
/specs/215_fix_todo_command_task_block_removal/plans/implementation-001.md
/specs/218_fix_lean_lsp_mcp_integration_and_opencode_module_import_errors/reports/research-001.md
```

**Should Be**:
```
/.opencode/specs/213_resolve_is_valid_swap_involution_blocker/...
/.opencode/specs/215_fix_todo_command_task_block_removal/...
/.opencode/specs/218_fix_lean_lsp_mcp_integration_and_opencode_module_import_errors/...
```

## Conclusion

**Root Cause**: Single incorrect path pattern in lean-research-agent.md line 497  
**Scope**: Affects only Lean research tasks using lean-research-agent  
**Fix Complexity**: Simple one-line change  
**Migration Effort**: Move 3 directories and update 2 state files  
**Prevention**: Add path pattern validation to linting rules  

The fix is straightforward and low-risk. All other subagents and commands use correct path patterns. After fixing lean-research-agent.md and migrating existing projects, the issue will be fully resolved.
