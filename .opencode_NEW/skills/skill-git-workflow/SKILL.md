---
name: skill-git-workflow
description: Manage git commits for task workflows.
allowed-tools: Bash, Edit, Read
---

# Git Workflow Skill

Direct execution skill for git operations and commit hygiene.

<context>
  <system_context>OpenCode git workflow maintenance.</system_context>
  <task_context>Create commits for task workflows.</task_context>
</context>

<role>Direct execution skill for git operations.</role>

<task>Stage and commit changes following git workflow rules.</task>

<execution>Use the Execution Flow section to guide commit creation.</execution>

<validation>Confirm commit formatting and staged file scope.</validation>

<return_format>Return structured commit summary.</return_format>

## Context References

Reference (do not load eagerly):
- Path: `.opencode/context/core/standards/git-safety.md` - Git safety rules
- Path: `.opencode/context/index.md` - Context discovery index
