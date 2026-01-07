---
name: review
agent: orchestrator
description: "Analyze codebase, update registries, create maintenance tasks"
context_level: 3
language: varies
routing:
  language_based: false
  target_agent: reviewer
timeout: 3600
context_loading:
  strategy: eager
  index: ".opencode/context/index.md"
  required:
    - "core/orchestration/delegation.md"
    - "core/orchestration/state-management.md"
    - "core/orchestration/routing.md"
    - "core/orchestration/state-lookup.md"  # Fast state.json queries
  data_files:
    - ".opencode/specs/TODO.md"
    - ".opencode/specs/state.json"  # State tracking
    - "Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md"
    - "Documentation/ProjectInfo/SORRY_REGISTRY.md"
    - "Documentation/ProjectInfo/TACTIC_REGISTRY.md"
    - "Documentation/ProjectInfo/FEATURE_REGISTRY.md"
  max_context_size: 100000
---

**Usage:** `/review [SCOPE]`

## Description

Analyzes codebase comprehensively, updates project registries (IMPLEMENTATION_STATUS, SORRY_REGISTRY, TACTIC_REGISTRY, FEATURE_REGISTRY), creates maintenance tasks for identified work, and commits registry updates.

## Workflow Setup

**Orchestrator handles:**
- Parse review scope from arguments (default: full codebase)
- Load current registries
- Determine review focus (Lean, docs, all)
- Read next_project_number from state.json
- Delegate to reviewer subagent
- Validate return format
- Relay result to user

**Reviewer subagent handles:**
- Codebase analysis (implementation status, sorry counts, tactic usage, features)
- Registry updates (IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, TACTIC_REGISTRY.md, FEATURE_REGISTRY.md)
- Task creation for identified maintenance work
- Project directory creation (.opencode/specs/{number}_codebase_review)
- Git commits

## Arguments

- `SCOPE` (optional): Review scope (lean, docs, all) - default: all

## Examples

```bash
/review                                  # Full codebase review
/review lean                             # Review Lean code only
/review docs                             # Review documentation only
```

## Delegation

**Target Agent:** `reviewer` (`.opencode/agent/subagents/reviewer.md`)  
**Timeout:** 3600s (1 hour)  
**Language-Based Routing:** No (always routes to reviewer)

**Reviewer Responsibilities:**
- Analyze codebase comprehensively
- Update all project registries atomically
- Create tasks for identified work (sorry removal, tactic improvements, feature completion)
- Create project directory lazily (.opencode/specs/{number}_codebase_review)
- Create git commit via git-workflow-manager

## Quality Standards

**Registry Updates:**
- IMPLEMENTATION_STATUS.md - Module completion tracking
- SORRY_REGISTRY.md - Sorry/axiom tracking
- TACTIC_REGISTRY.md - Tactic usage and effectiveness
- FEATURE_REGISTRY.md - Feature completeness tracking

**Atomic Updates:**
- All registries updated atomically
- Backup registries before writing
- Rollback on write failure

**Task Creation:**
- Create tasks for identified maintenance work
- Link tasks to registry entries
- Set appropriate priorities based on impact

**Project Directory:**
- Format: {next_project_number}_codebase_review
- Example: 207_codebase_review
- Created lazily by reviewer when writing first artifact

## Review Scope

**Lean Code Review:**
- Implementation status (module completion)
- Sorry/axiom counts and locations
- Tactic usage and effectiveness
- Proof complexity metrics

**Documentation Review:**
- Documentation completeness
- README quality
- API documentation coverage
- Example completeness

**Full Review:**
- All Lean code analysis
- All documentation analysis
- Cross-reference validation
- Consistency checks

## Error Handling

**Invalid Scope:**
```
Error: Invalid review scope: {scope}
Valid scopes: lean, docs, all
Usage: /review [SCOPE]
```

**Registry Load Failure:**
```
Error: Failed to load registry: {registry_name}
Details: {error_message}
Recommendation: Check registry file exists and is valid
```

**Review Timeout:**
```
Warning: Review timed out after 3600s
Status: Partial review may exist
Recommendation: Retry with /review
```

**Registry Update Failure:**
```
Error: Failed to update registries
Rollback: Restored from backup
Details: {error_message}
Recommendation: Retry with /review
```

**Task Creation Failure:**
```
Warning: Task creation failed for {task_description}
Details: {error_message}
Review completed, but task not created
Recommendation: Manually create task in TODO.md
```

## Notes

- **Comprehensive Analysis**: Reviews entire codebase or specified scope
- **Registry Maintenance**: Keeps all project registries up-to-date
- **Task Generation**: Automatically creates tasks for identified work
- **Atomic Updates**: All registry updates are atomic with backup/rollback
- **Git Workflow**: Delegated to git-workflow-manager for standardized commits
- **Context Level 3**: Eager loading with comprehensive context (100KB budget)

For detailed workflow documentation, see:
- `.opencode/agent/subagents/reviewer.md`
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
- `Documentation/ProjectInfo/SORRY_REGISTRY.md`
- `Documentation/ProjectInfo/TACTIC_REGISTRY.md`
- `Documentation/ProjectInfo/FEATURE_REGISTRY.md`
