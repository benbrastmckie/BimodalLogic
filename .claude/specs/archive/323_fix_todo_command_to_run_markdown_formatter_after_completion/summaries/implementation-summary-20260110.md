# Implementation Summary: Task #323

**Completed**: 2026-01-10
**Plan Version**: 002 (revised for Claude Code)
**Duration**: ~45 minutes

## Summary

Successfully enhanced `todo_cleanup.py` with markdown formatting capabilities. The script now applies comprehensive formatting to TODO.md after archival operations, fixing issues with trailing whitespace, inconsistent blank lines, and spacing around headings and dividers.

## Changes Made

### Phase 1: Path Updates

Updated path constants in `.opencode/scripts/todo_cleanup.py`:
- `todo_path`: `.opencode/specs/TODO.md` → `.claude/specs/TODO.md`
- `state_path`: `.opencode/specs/state.json` → `.claude/specs/state.json`
- `archive_state_path`: `.opencode/specs/archive/state.json` → `.claude/specs/archive/state.json`
- `specs_dir`: `.opencode/specs/` → `.claude/specs/`

Also updated docstring reference on line 11.

### Phase 2: format_markdown() Function

Added `format_markdown()` function (lines 217-305) implementing:
1. Remove trailing whitespace from all lines
2. Normalize blank lines (max 2 consecutive)
3. Ensure blank line before/after headings (## and ###)
4. Ensure blank line before/after dividers (---)
5. Ensure single trailing newline at EOF
6. Preserve frontmatter (YAML between --- markers at start)
7. Preserve code blocks (between ``` markers)

### Phase 3: Integration

1. **--format-only flag**: New command-line option for standalone formatting
2. **Archive mode**: Formatting applied after archival operations
3. **Fix-dividers mode**: Formatting now applied along with divider fixes
4. **Non-fatal errors**: Formatting failures logged but don't abort archival

### Phase 4: Testing

Verified:
- `--format-only --dry-run` shows correct behavior
- `--format-only` applies formatting correctly
- `--dry-run --verbose` shows formatting in archival flow
- `--validate-only` passes after formatting
- Frontmatter preserved correctly
- No content loss

## Files Modified

| File | Change |
|------|--------|
| `.opencode/scripts/todo_cleanup.py` | Path updates, format_markdown(), --format-only flag, integration |
| `.claude/specs/323_.../plans/implementation-002.md` | Marked phases complete |
| `.claude/specs/TODO.md` | Applied formatting |

## Usage

```bash
# Format only
python3 .opencode/scripts/todo_cleanup.py --format-only

# Format with dry-run
python3 .opencode/scripts/todo_cleanup.py --format-only --dry-run

# Full archival (includes formatting)
python3 .opencode/scripts/todo_cleanup.py

# Fix dividers (also includes formatting)
python3 .opencode/scripts/todo_cleanup.py --fix-dividers
```

## Verification Checklist

- [x] format_markdown() applies all formatting rules
- [x] Frontmatter preserved
- [x] Code blocks preserved
- [x] Function well-documented
- [x] Formatting applied after archival
- [x] --format-only flag works
- [x] Formatting failure doesn't abort archival
- [x] Dry-run shows formatting changes
- [x] No content loss
- [x] Script uses .claude/specs/ paths

## Notes

### Script Location

The script remains at `.opencode/scripts/todo_cleanup.py` (not yet migrated to `.claude/scripts/`). A separate task should handle migrating all scripts from `.opencode/` to `.claude/`.

### Formatting Rules

The formatting is intentionally conservative:
- Only removes trailing whitespace (not leading)
- Allows up to 2 consecutive blank lines
- Preserves frontmatter and code blocks exactly
- Adds blank lines around headings/dividers only if missing
