# Targeted Git Commits Standard

**Purpose**: Define when and how to create minimal, task-scoped commits that follow artifact-first sequencing. Applies to all commands/agents.

## When to Commit
- After artifacts are written (code, docs, reports, plans, summaries) and status/state/TODO updates are applied.
- Once validation steps for the scope are done (e.g., `lake build`, `lake exe test`, lint or file-level checks when code changed).
- Do not commit during dry-run or routing-check flows.

## Scoping Rules
- Stage only files relevant to the current task/feature. Avoid repo-wide adds.
- Use `git add <file1> <file2>`; **do not** use `git add -A` or `git commit -am`.
- Split unrelated changes into separate commits; prefer smaller, cohesive commits.
- Exclude build artifacts, lockfiles, or generated files unless intentionally changed.

## Recommended Flow
1) Review changes: `git status --short`, `git diff --stat` (and `git diff` for details).
2) Stage target files only: `git add path/to/file1 path/to/file2`.
3) Re-check scope: `git status --short` to confirm only intended files are staged.
4) Run relevant checks (as needed): `lake build`, `lake exe test`, formatters/linters.
5) Commit with a focused message: `git commit -m "<area>: <summary> (task 156)"`.
6) Leave unstaged any out-of-scope changes for follow-up commits.

## Commit Messages
- Format: `<area>: <what>`; include task/plan IDs when known (e.g., `commands: add targeted git commit rules (task 156)`).
- Keep imperative, concise, and scoped to staged changes.

## Safety Checks
- Ensure artifacts exist and references are updated (TODO/state/IMPLEMENTATION_STATUS/SORRY_REGISTRY/TACTIC_REGISTRY when applicable).
- Avoid committing during blocked/abandoned states.
- No emojis in messages or logs.

## Integration
- Commands should reference this file plus `git-workflow-manager` for commit guidance.
- Git-workflow-manager provides scoped commit suggestions; commands must execute commits only after artifacts are produced and validations complete.
