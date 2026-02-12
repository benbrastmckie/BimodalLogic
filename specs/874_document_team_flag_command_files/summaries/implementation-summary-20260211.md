# Implementation Summary: Task #874

**Completed**: 2026-02-11
**Duration**: ~15 minutes

## Changes Made

Added documentation for `--team` and `--team-size N` flags to the `/research`, `/plan`, and `/implement` command files. These flags enable multi-agent parallel execution for research, planning, and implementation tasks respectively. The documentation follows the established Options table pattern from lake.md and includes explanatory text about team mode behavior.

## Files Modified

- `.claude/commands/research.md` - Updated argument-hint to `TASK_NUMBER [FOCUS] [--team [--team-size N]]`, added Options table with --team and --team-size flags, added explanation of team research behavior
- `.claude/commands/plan.md` - Updated argument-hint to `TASK_NUMBER [--team [--team-size N]]`, added Options table with --team and --team-size flags, added explanation of team planning behavior
- `.claude/commands/implement.md` - Updated argument-hint to `TASK_NUMBER [--team [--team-size N]] [--force]`, restructured Arguments section, added Options table with --team, --team-size, and --force flags, added explanation of team implementation behavior

## Verification

- All three command files have consistent Options table format (Flag | Description | Default)
- argument-hint values match CLAUDE.md Command Reference table
- Team mode explanations describe:
  - Which skill handles team mode (skill-team-research, skill-team-plan, skill-team-implement)
  - How teammates work (parallel execution, independent reports/plans)
  - What the lead does (synthesizes findings/best elements)
- --force flag preserved and moved to Options table in implement.md

## Notes

- The team-size range differs by command: research and implement support 2-4 teammates, plan supports 2-3 teammates (as per skill implementations)
- The --force flag was already present in implement.md but not in an Options table; it has been moved to the new Options section
