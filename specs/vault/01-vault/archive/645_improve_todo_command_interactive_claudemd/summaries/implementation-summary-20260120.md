# Implementation Summary: Task #645

**Completed**: 2026-01-20
**Duration**: ~30 minutes

## Changes Made

Improved the /todo command specification to fix jq syntax errors from Claude Code Issue #1132 and add interactive CLAUDE.md suggestion selection via AskUserQuestion with auto-application via the Edit tool.

## Files Modified

- `.claude/commands/todo.md` - Updated with:
  - Step 3.5.2: File-based jq filter for non-meta task extraction (avoids `!=` operator)
  - Step 3.6.1: Added comment documenting `has()` usage for Issue #1132
  - Step 5B: Explicit jq code using `del()` pattern for removing archived tasks
  - Step 5.6: Complete rewrite with interactive AskUserQuestion selection flow
    - Step 5.6.1: Filter actionable suggestions
    - Step 5.6.2: AskUserQuestion with multiSelect for suggestion selection
    - Step 5.6.3: Apply selected suggestions via Edit tool
    - Step 5.6.4: Display results (applied/failed/skipped)
    - Step 5.6.5: Handle "none" action tasks
  - Step 4 (dry-run): Added note about interactive selection
  - Step 7 (output): Updated to show applied/failed/skipped counts
  - Notes section: Added "Interactive CLAUDE.md Application" and "jq Pattern Safety (Issue #1132)" subsections

## Verification

- All jq commands now use Issue #1132-safe patterns:
  - File-based filters for `!=` operators
  - `has()` for null checks
  - `del()` for exclusion filters
- Interactive selection flow documented with complete AskUserQuestion specification
- "Skip all" option preserved for manual review preference
- Edit failure handling documented

## Notes

The implementation follows the research findings from research-001.md regarding:
- Two-step jq patterns to work around Claude Code Issue #1132
- AskUserQuestion multiSelect usage with dynamic option building
- Edit tool application patterns for ADD/UPDATE/REMOVE actions

The command specification is now ready for execution. No code was run during this implementation as todo.md is a specification document, not executable code.
