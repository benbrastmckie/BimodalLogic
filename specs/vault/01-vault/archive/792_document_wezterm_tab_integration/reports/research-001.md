# Research Report: Task #792

**Task**: Review and document WezTerm tab integration
**Date**: 2026-02-01
**Focus**: WezTerm integration with Neovim and Claude Code

## Summary

The WezTerm tab integration spans four recent implementations (tasks 788-791) that enable: (1) notification coloring on Claude completion, (2) task number display in tab titles, (3) OSC 7 directory updates from Neovim, and (4) task number monitoring from embedded Claude Code terminals. Documentation needs to be added in three locations following distinct documentation standards at each.

## Findings

### Component Architecture

```
WezTerm Tab Integration Flow
============================

                    ┌────────────────────────────────────────┐
                    │          ~/.dotfiles/config/           │
                    │              wezterm.lua               │
                    │                                        │
                    │  ┌────────────────────────────────────┐│
                    │  │ format-tab-title handler           ││
                    │  │ - Extracts project name from OSC 7 ││
                    │  │ - Reads TASK_NUMBER user var       ││
                    │  │ - Reads CLAUDE_STATUS user var     ││
                    │  │ - Applies amber color for notify   ││
                    │  └────────────────────────────────────┘│
                    │  ┌────────────────────────────────────┐│
                    │  │ update-status handler (task 788)   ││
                    │  │ - Tracks active tab per window     ││
                    │  │ - Clears CLAUDE_STATUS on switch   ││
                    │  └────────────────────────────────────┘│
                    └────────────────────────────────────────┘
                                       ▲
                                       │
          ┌────────────────────────────┼────────────────────────────┐
          │                            │                            │
          ▼                            ▼                            ▼
┌───────────────────┐    ┌───────────────────┐    ┌───────────────────┐
│ OSC 7 (directory) │    │ OSC 1337 user var │    │ OSC 1337 user var │
│ file://host/path  │    │ TASK_NUMBER=base64│    │ CLAUDE_STATUS=... │
└───────────────────┘    └───────────────────┘    └───────────────────┘
          ▲                       ▲  ▲                      ▲
          │                       │  │                      │
          │                       │  │                      │
┌─────────┴─────────┐   ┌────────┴──┴────────┐   ┌─────────┴─────────┐
│ Neovim autocmds   │   │ Shell hook (789)   │   │ Shell hook (788)  │
│ (task 790)        │   │ wezterm-task-      │   │ wezterm-notify.sh │
│ - DirChanged      │   │ number.sh          │   │ (on Stop)         │
│ - VimEnter        │   │ + Neovim monitor   │   │                   │
│ - BufEnter        │   │ (task 791)         │   │ wezterm-clear-    │
└───────────────────┘   └───────────────────┘   │ status.sh         │
        │                       │               │ (on UserPrompt)   │
        │                       │               └───────────────────┘
        ▼                       ▼                         │
┌───────────────────┐   ┌───────────────────┐            │
│ ~/.config/nvim/   │   │ .claude/hooks/    │◄───────────┘
│ lua/neotex/       │   │                   │
│ config/autocmds   │   │ settings.json     │
│ lib/wezterm.lua   │   │ hook registration │
└───────────────────┘   └───────────────────┘
```

### Files by Location

**ProofChecker/.claude/ (Claude Code hooks)**:
| File | Purpose | Task |
|------|---------|------|
| `hooks/wezterm-notify.sh` | Set CLAUDE_STATUS on Stop event | 788 |
| `hooks/wezterm-clear-status.sh` | Clear CLAUDE_STATUS on UserPromptSubmit | 788 |
| `hooks/wezterm-task-number.sh` | Set TASK_NUMBER from Claude commands | 789 |
| `settings.json` | Hook registration (Stop, UserPromptSubmit) | 788, 789 |

**~/.config/nvim/ (Neovim integration)**:
| File | Purpose | Task |
|------|---------|------|
| `lua/neotex/config/autocmds.lua` | OSC 7 emission + Claude terminal monitor | 790, 791 |
| `lua/neotex/lib/wezterm.lua` | OSC 1337 SetUserVar module | 791 |

**~/.dotfiles/ (WezTerm configuration)**:
| File | Purpose | Task |
|------|---------|------|
| `config/wezterm.lua` | format-tab-title + update-status handlers | 788, 789 |

### OSC Escape Sequences Used

| Sequence | Purpose | Format |
|----------|---------|--------|
| OSC 7 | Directory update | `ESC ] 7 ; file://hostname/path BEL` |
| OSC 1337 | User variable | `ESC ] 1337 ; SetUserVar=name=base64value BEL` |

### Integration Patterns

**Standalone Claude Code (shell hooks)**:
1. User runs `/research 792` in Claude Code
2. `wezterm-task-number.sh` parses CLAUDE_USER_PROMPT env var
3. Extracts task number, emits OSC 1337 to pane TTY
4. WezTerm `format-tab-title` reads TASK_NUMBER, displays "#792"

**Claude Code in Neovim (dual mechanism)**:
1. User runs `/research 792` in embedded Claude terminal
2. Neovim's `nvim_buf_attach` callback detects command pattern
3. `neotex.lib.wezterm.set_task_number()` emits OSC 1337
4. Shell hook may also fire (both coexist without conflict)

**Notification flow**:
1. Claude Code stops (awaiting input) - triggers Stop hook
2. `wezterm-notify.sh` sets CLAUDE_STATUS=needs_input
3. Inactive tab shows amber background
4. User switches to tab - `update-status` handler clears CLAUDE_STATUS
5. OR User submits prompt - `wezterm-clear-status.sh` clears it

### Documentation Standards by Location

**ProofChecker/.claude/** (present-state technical docs):
- README.md: System overview with architecture diagrams
- CLAUDE.md: Minimal quick reference for agent context
- Uses code blocks, tables, present-tense language
- Focus on "what" and "how", avoid historical context
- Cross-references via @-notation

**~/.config/nvim/** (comprehensive README structure):
- DOCUMENTATION_STANDARDS.md defines strict requirements
- Present-state focus: NO historical markers, temporal language
- Unicode box-drawing for diagrams (NO ASCII art)
- NO emojis
- Every directory needs README.md with purpose, modules, navigation
- Central docs/ for topic-focused documentation

**~/.dotfiles/** (minimal README structure):
- README.md: Overview + directory listing
- docs/ subdirectory with topic-specific .md files
- Brief, functional documentation style
- Focus on installation and configuration
- config/README.md is a simple file listing

### Documentation Gap Analysis

**ProofChecker/.claude/**:
- **Existing**: CLAUDE.md mentions hooks generally, README.md has architecture
- **Missing**: No dedicated documentation of WezTerm integration
- **Recommendation**: Add section to README.md under "Claude Code Hooks" or create dedicated context file

**~/.config/nvim/**:
- **Existing**: docs/NOTIFICATIONS.md covers notification system; autocmds.lua has inline comments
- **Missing**: No central documentation of WezTerm OSC integration
- **Recommendation**: Either extend NOTIFICATIONS.md or update lua/neotex/config/README.md with WezTerm section

**~/.dotfiles/**:
- **Existing**: docs/terminal.md mentions WezTerm/Kitty config; wezterm.lua has inline comments
- **Missing**: No documentation of Claude Code integration features
- **Recommendation**: Add section to docs/terminal.md covering Claude Code integration (user variables, notification coloring)

## Recommendations

### Documentation Structure

**1. ProofChecker/.claude/context/project/hooks/wezterm-integration.md** (new file):
```
Purpose: Document WezTerm tab integration for Claude Code
Contents:
- Architecture diagram (OSC flow)
- Hook descriptions (wezterm-notify.sh, wezterm-clear-status.sh, wezterm-task-number.sh)
- User variable protocol (CLAUDE_STATUS, TASK_NUMBER)
- Configuration options (WEZTERM_NOTIFY_ENABLED)
- Integration with Neovim (cross-reference)
```

**2. ~/.config/nvim/docs/TERMINAL.md** (new file or section in existing doc):
```
Purpose: Document terminal integration features
Contents:
- WezTerm OSC 7 integration (directory updates)
- Claude Code task number monitoring
- API reference for neotex.lib.wezterm module
```

**3. ~/.dotfiles/docs/terminal.md** (extend existing):
```
Purpose: Document terminal-specific integrations
New section: "WezTerm Claude Code Integration"
Contents:
- format-tab-title handler features
- update-status notification clearing
- User variable documentation (TASK_NUMBER, CLAUDE_STATUS)
- Behavior description with amber highlighting
```

### Cross-References

Each location should reference the others:
- ProofChecker: "WezTerm config in ~/.dotfiles/config/wezterm.lua"
- nvim: "Works with Claude Code hooks in project .claude/hooks/"
- dotfiles: "User variables set by Claude Code hooks and Neovim"

### Priority Order

1. **~/.dotfiles/docs/terminal.md** - Primary configuration location
2. **~/.config/nvim/lua/neotex/config/README.md** - Neovim-specific features
3. **ProofChecker/.claude/** - Hook documentation (optional, hooks are self-documenting)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Documentation divergence | Medium | Include cross-references between all three locations |
| Neovim doc standards are strict | Low | Follow DOCUMENTATION_STANDARDS.md exactly |
| Over-documentation | Low | Focus on user-facing behavior, not implementation details |

## Next Steps

1. Create implementation plan with phased documentation updates
2. Start with dotfiles (primary WezTerm config location)
3. Add Neovim documentation following strict standards
4. Optionally add ProofChecker hook documentation

## References

- Task 788 summary: `specs/788_wezterm_tab_coloring_on_claude_completion/summaries/implementation-summary-20260131.md`
- Task 789 summary: `specs/789_wezterm_tab_title_project_and_task_number/summaries/implementation-summary-20260131.md`
- Task 790 summary: `specs/790_neovim_wezterm_osc7_tab_title/summaries/implementation-summary-20260201.md`
- Task 791 summary: `specs/791_wezterm_task_number_from_claude_commands/summaries/implementation-summary-20260201.md`
- Neovim documentation standards: `~/.config/nvim/docs/DOCUMENTATION_STANDARDS.md`
