# Implementation Summary: Task #871

**Completed**: 2026-02-11
**Duration**: Approximately 30 minutes

## Changes Made

Replaced unsafe `git add -A` patterns with targeted staging across the entire .claude/ directory to prevent race conditions when concurrent agents modify overlapping files. Each agent type now stages only files within its designated scope.

## Files Modified

### Phase 1: Documentation
- `.claude/context/core/standards/git-staging-scope.md` - Created new documentation with agent-specific staging rules
- `.claude/context/core/standards/git-safety.md` - Added reference to new git-staging-scope.md

### Phase 2: High-Priority Skills
- `.claude/skills/skill-researcher/SKILL.md` - Stage only research reports, metadata, TODO.md, state.json
- `.claude/skills/skill-lean-research/SKILL.md` - Same pattern as skill-researcher
- `.claude/skills/skill-planner/SKILL.md` - Stage only plans, metadata, TODO.md, state.json
- `.claude/skills/skill-implementer/SKILL.md` - Stage task-specific + implementation files
- `.claude/skills/skill-lean-implementation/SKILL.md` - Stage Theories/, summaries, plans, TODO.md, state.json

### Phase 3: Remaining Skills and Commands
- `.claude/skills/skill-latex-implementation/SKILL.md` - Stage docs/, task files
- `.claude/skills/skill-typst-implementation/SKILL.md` - Stage docs/, task files
- `.claude/skills/skill-git-workflow/SKILL.md` - Stage task-specific files
- `.claude/skills/skill-team-research/SKILL.md` - Targeted staging for team research
- `.claude/skills/skill-team-plan/SKILL.md` - Targeted staging for team planning
- `.claude/skills/skill-team-implement/SKILL.md` - Targeted staging for team implementation
- `.claude/commands/implement.md` - Updated CHECKPOINT 3 COMMIT section
- `.claude/commands/plan.md` - Updated CHECKPOINT 3 COMMIT section
- `.claude/commands/research.md` - Updated CHECKPOINT 3 COMMIT section
- `.claude/commands/revise.md` - Updated CHECKPOINT 3 COMMIT section
- `.claude/commands/errors.md` - Updated git commit section

### Phase 4: Agents and Context Patterns
- `.claude/agents/general-implementation-agent.md` - Targeted staging in phase checkpoint protocol
- `.claude/agents/latex-implementation-agent.md` - Targeted staging in phase checkpoint protocol
- `.claude/agents/typst-implementation-agent.md` - Targeted staging in phase checkpoint protocol
- `.claude/context/core/patterns/checkpoint-execution.md` - Updated CHECKPOINT 3 description
- `.claude/context/core/patterns/file-metadata-exchange.md` - Updated postflight example
- `.claude/context/core/checkpoints/checkpoint-commit.md` - Updated staging step
- `.claude/context/core/templates/command-template.md` - Updated CHECKPOINT 3 template
- `.claude/context/project/lean4/agents/lean-implementation-flow.md` - Targeted staging in phase protocol
- `.claude/context/core/troubleshooting/workflow-interruptions.md` - Updated manual commit example
- `.claude/commands/todo.md` - Added exclusive access warning

## Verification

- All skill files now have explicit file lists in git add commands
- All agent files now have explicit file lists in phase commit sections
- All command files now have targeted staging in CHECKPOINT 3
- Created comprehensive documentation at git-staging-scope.md with:
  - Agent-specific allowed file scopes
  - Copy-paste bash snippets for each agent type
  - Verification commands
  - Migration checklist
  - Anti-patterns section

## Notes

- `/todo` command is a special case requiring exclusive access to specs/
- skill-meta and skill-document-converter don't have typical git staging patterns (they work differently)
- The verification grep commands now only find documentation references warning against `git add -A`
- Each agent stages only files within its designated scope per the new git-staging-scope.md documentation
