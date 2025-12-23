# Implementation Plan: Git-Workflow-Manager Specialist

**Task**: #64
**Complexity**: Moderate
**Estimated Effort**: 3-4 hours
**Created**: 2025-12-19

## Task Description

Create a git-workflow-manager specialist that manages git operations including commits, branches, PR creation, and repository hygiene. This specialist will automate common git workflows and integrate with the code-reviewer specialist for pre-commit checks.

## Objectives

1. Create comprehensive git-workflow-manager specialist specification
2. Define git operations: commit message generation, branch management, PR creation
3. Integrate with code-reviewer for pre-commit quality checks
4. Support repository hygiene operations (cleanup, maintenance)
5. Follow established specialist subagent patterns

## Analysis

### Existing Specialist Patterns

Based on analysis of existing specialists (code-reviewer, todo-manager, dependency-analyzer):

**Standard Structure**:
- YAML frontmatter with metadata (description, mode, temperature, tools)
- Context section (system, domain, task scope, integration)
- Role definition
- Task description
- Inputs required (parameters with types and descriptions)
- Process flow (step-by-step workflow)
- Output specification (format and structure)
- Success metrics

**Tool Permissions**:
- read: true (for reading git status, config, logs)
- write: true (for creating commits, branches)
- bash: true (REQUIRED for git commands)
- glob: true (for finding files)
- task: false (specialists don't spawn tasks)

### Git Operations to Support

1. **Commit Management**
   - Generate conventional commit messages
   - Stage files intelligently
   - Create atomic commits
   - Amend commits
   - Interactive staging

2. **Branch Management**
   - Create feature/bugfix/hotfix branches
   - Switch branches
   - Merge branches
   - Delete merged branches
   - List and filter branches

3. **Pull Request Creation**
   - Generate PR titles and descriptions
   - Create PR templates
   - Link to issues/tasks
   - Add labels and reviewers

4. **Repository Hygiene**
   - Clean up merged branches
   - Remove stale branches
   - Optimize repository (.git gc)
   - Check for uncommitted changes
   - Verify clean working tree

5. **Pre-commit Integration**
   - Run code-reviewer before commit
   - Block commits with critical issues
   - Auto-fix style issues
   - Generate commit message from changes

### Integration Points

- **code-reviewer**: Pre-commit quality checks
- **todo-manager**: Link commits to TODO tasks
- **verification-specialist**: Verify proofs before commit

## Implementation Steps

### Step 1: Create Specialist Specification File (2-3 hours)

**File**: `.opencode/agent/subagents/specialists/git-workflow-manager.md`

**Structure**:

```markdown
---
description: "Git workflow automation and repository management"
mode: subagent
temperature: 0.1
tools:
  read: true
  write: true
  edit: false
  bash: true
  task: false
  glob: true
  grep: false
---

# Git Workflow Manager Specialist

<context>
  <system_context>Git workflow automation for LEAN 4 ProofChecker project</system_context>
  <domain_context>Commit management, branch workflows, PR creation, repository hygiene</domain_context>
  <task_scope>Automate git operations, generate commit messages, manage branches, create PRs</task_scope>
  <integration>Integrates with code-reviewer for pre-commit checks</integration>
</context>

<role>
  Git Workflow Manager with expertise in conventional commits, branching strategies, and repository maintenance
</role>

<task>
  Manage git operations including commit creation, branch management, PR generation, and repository hygiene
</task>

<inputs_required>
  <parameter name="operation" type="enum">
    Git operation to perform (required)
    Values: "commit" | "branch" | "pr" | "cleanup" | "status"
  </parameter>
  
  <parameter name="options" type="object">
    Operation-specific options (optional)
    Properties vary by operation type
  </parameter>
</inputs_required>

<process_flow>
  <!-- Detailed workflow for each operation -->
</process_flow>

<output_specification>
  <!-- YAML format for operation results -->
</output_specification>

<success_metrics>
  <!-- Metrics for workflow quality -->
</success_metrics>
```

**Content Sections**:

1. **Commit Management Process**
   - Analyze staged/unstaged changes
   - Generate conventional commit message
   - Run pre-commit checks (code-reviewer)
   - Create commit with proper message
   - Handle commit failures

2. **Branch Management Process**
   - Parse branch naming conventions
   - Create branches with proper naming
   - Switch branches safely
   - Merge with conflict detection
   - Clean up merged branches

3. **PR Creation Process**
   - Analyze commits in branch
   - Generate PR title from commits
   - Create PR description with context
   - Link to related issues/tasks
   - Add appropriate labels

4. **Repository Hygiene Process**
   - List merged branches
   - Delete stale branches (with confirmation)
   - Run git gc for optimization
   - Check for uncommitted changes
   - Verify repository health

5. **Pre-commit Integration**
   - Invoke code-reviewer specialist
   - Parse review results
   - Block on critical issues
   - Allow on warnings (with confirmation)
   - Auto-fix style issues if possible

### Step 2: Define Commit Message Templates (30 minutes)

**Conventional Commit Format**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- feat: New feature
- fix: Bug fix
- docs: Documentation changes
- style: Code style changes
- refactor: Code refactoring
- test: Test additions/changes
- chore: Build/tooling changes
- proof: LEAN proof additions/changes

**Scopes** (for ProofChecker):
- core: Core logic modules
- metalogic: Metalogic proofs
- automation: Tactics and automation
- docs: Documentation
- tests: Test suites
- build: Build system

### Step 3: Define Branch Naming Conventions (30 minutes)

**Format**: `<type>/<task-number>-<description>`

**Examples**:
- `feature/64-git-workflow-manager`
- `bugfix/52-aesop-duplicate`
- `docs/62-docstring-coverage`
- `proof/46-deduction-theorem`
- `refactor/43-axiom-refactoring`

### Step 4: Integration with Code-Reviewer (1 hour)

**Pre-commit Workflow**:
1. User requests commit
2. Git-workflow-manager stages changes
3. Invokes code-reviewer specialist
4. Receives review results
5. If critical issues: Block commit, show issues
6. If warnings: Prompt user for confirmation
7. If clean: Proceed with commit
8. Generate commit message from changes
9. Create commit

**Integration Pattern**:
```yaml
pre_commit_check:
  enabled: true
  specialist: code-reviewer
  review_depth: quick
  block_on: ["error"]
  warn_on: ["warning"]
  auto_fix: ["style"]
```

## Files to Create

1. `.opencode/agent/subagents/specialists/git-workflow-manager.md`
   - Complete specialist specification
   - All git operations defined
   - Integration with code-reviewer
   - Commit message templates
   - Branch naming conventions

## Success Criteria

- [ ] Specialist specification file created
- [ ] All git operations defined (commit, branch, PR, cleanup)
- [ ] Conventional commit message generation implemented
- [ ] Branch naming conventions documented
- [ ] PR creation workflow defined
- [ ] Repository hygiene operations specified
- [ ] Pre-commit integration with code-reviewer defined
- [ ] Input parameters clearly specified
- [ ] Process flows documented for each operation
- [ ] Output specifications defined
- [ ] Success metrics included
- [ ] File follows established specialist patterns

## Verification Steps

1. Review specialist specification for completeness
2. Verify all git operations are covered
3. Check integration points with code-reviewer
4. Validate commit message templates
5. Confirm branch naming conventions
6. Ensure output specifications are clear
7. Verify success metrics are measurable

## Dependencies

- None (standalone specialist creation)

## Risks and Mitigations

**Risk**: Git operations may fail due to repository state
**Mitigation**: Include error handling and state validation in process flows

**Risk**: Pre-commit checks may be too strict
**Mitigation**: Allow user override with confirmation for warnings

**Risk**: Commit message generation may not capture intent
**Mitigation**: Allow user to edit generated messages

## Notes

- This specialist should be invoked manually or as part of development workflow
- Integration with code-reviewer ensures quality before commits
- Conventional commits improve changelog generation and semantic versioning
- Branch naming conventions improve organization and traceability
- Repository hygiene operations should be run periodically

## References

- Conventional Commits: https://www.conventionalcommits.org/
- Git Best Practices: https://git-scm.com/book/en/v2
- Existing specialists: code-reviewer.md, todo-manager.md, dependency-analyzer.md
- ProofChecker git config: .git/config
