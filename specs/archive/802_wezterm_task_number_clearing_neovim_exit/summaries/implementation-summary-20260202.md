# Implementation Summary: Task #802

**Completed**: 2026-02-02
**Duration**: ~15 minutes

## Changes Made

Implemented WezTerm tab task number clearing for non-workflow events. Task numbers now clear:
1. On all SessionStart events (startup, resume, /clear, compact)
2. When Neovim exits with an active Claude Code terminal

The design uses "clear by default, set only for workflow commands" - the existing UserPromptSubmit hook sets task numbers for workflow commands, and the new SessionStart hook clears them for everything else.

## Files Modified

- `.claude/hooks/wezterm-clear-task-number.sh` - Created: Hook script that clears TASK_NUMBER via OSC 1337 for WezTerm
- `.claude/settings.json` - Modified: Added SessionStart hook with matcher="*" to clear task number on all session events
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Modified: Added VimLeavePre autocmd to clear task number when Neovim exits with Claude terminal (outside project repo)

## Verification

- Hook script is executable (chmod +x)
- settings.json validates as valid JSON
- SessionStart hook array has matcher="*" entry before "startup" entry
- VimLeavePre autocmd added to Neovim config
- Neovim config loads without errors

## Test Matrix (Manual)

The following scenarios should be tested manually:

- [ ] `/research N` sets task number in tab
- [ ] Non-workflow command (e.g., "hello") clears task number
- [ ] `/clear` command clears task number (via SessionStart)
- [ ] Session startup clears task number (via SessionStart)
- [ ] Neovim exit (:qa) clears task number (via VimLeavePre)
- [ ] Tab shows correct directory after clearing

## Notes

- The Neovim config file (`~/.config/nvim/lua/neotex/config/autocmds.lua`) is outside the ProofChecker repository, so changes were applied but not committed to this repo
- The hook order in SessionStart matters: the matcher="*" hook runs for all events, while matcher="startup" only runs on initial startup
- The VimLeavePre autocmd uses the existing `wezterm.clear_task_number()` function from `neotex.lib.wezterm`
