# Implementation Plan: Task #795 (Revised v004)

- **Task**: 795 - Fix wezterm tab project number persistence for workflow commands
- **Version**: 004 (Revised)
- **Status**: [IMPLEMENTING]
- **Effort**: 0.5 hours
- **Dependencies**: Tasks 788-791 completed (WezTerm integration established)
- **Research Inputs**: specs/795_wezterm_tab_project_number_persistence/reports/research-001.md
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Revision Rationale

- **v001**: Maintained a list of "clear commands" - high maintenance burden
- **v002**: Never clear except terminal close - too persistent
- **v003**: Clear on every non-workflow input - didn't persist across Claude responses
- **v004** (this): Set on workflow commands, clear on non-workflow commands, persist across Claude output

**Correct behavior**:
1. Workflow command (`/research N`, `/plan N`, `/implement N`, `/revise N`) → Set task number to N
2. Non-workflow command (any other user prompt/command) → Clear task number
3. Between user inputs (Claude responses, tool confirmations, etc.) → Preserve current state

The key insight: Only evaluate task number changes on **user prompt submission**, not on every line of terminal output.

## Goals & Non-Goals

**Goals**:
- Set task number when workflow command is submitted
- Clear task number when non-workflow command is submitted
- Persist task number across Claude's execution (responses, tool use, etc.)
- Zero maintenance burden - only 4 workflow patterns to track

**Non-Goals**:
- Tracking intermediate terminal output
- Clearing on Claude responses or tool confirmations
- Maintaining lists of non-workflow commands

## Design

**State machine**:
```
State: TASK_NUMBER (can be set or cleared)

Event: User submits prompt
  → If matches workflow pattern: set TASK_NUMBER to N
  → Else: clear TASK_NUMBER

Event: Claude responds / Tool runs / etc.
  → No change (preserve current TASK_NUMBER)

Event: Terminal closes
  → Clear TASK_NUMBER
```

**Implementation approach**:

The current bug is that the Neovim monitor evaluates EVERY line in the terminal buffer, including Claude's output. This causes the task number to clear when Claude responds (since Claude's text doesn't match workflow patterns).

**Fix**: Only evaluate lines that look like user prompts. In Claude Code, user prompts typically:
- Start fresh after Claude's response
- Are the last line before Claude starts responding
- Can be identified by context (e.g., after a prompt marker)

Alternatively, the shell hook already fires only on `UserPromptSubmit` - we can rely more heavily on it and reduce the Neovim monitor's role.

**Simplest fix**: Modify Neovim to only trigger task number evaluation on specific events (user input), not on buffer content changes.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Detecting user vs Claude output | Medium | Medium | Use prompt markers or input events |
| Task number flickers during rapid input | Low | Low | Debounce if needed |
| New workflow commands not detected | Low | Very Low | Core 4 commands are stable |

## Implementation Phases

### Phase 1: Analyze Current Monitoring Approach [COMPLETED]

**Goal**: Understand exactly how the Neovim monitor currently works and why it clears on Claude output.

**Tasks**:
- [ ] Read `autocmds.lua` to understand the `nvim_buf_attach` callback
- [ ] Identify what triggers the callback (every line? specific events?)
- [ ] Determine how to filter for user input only

**Timing**: 0.1 hours

**Files to examine**:
- `~/.config/nvim/lua/neotex/config/autocmds.lua` - Current monitoring logic

**Questions to answer**:
1. What event triggers the task number evaluation?
2. How can we distinguish user prompts from Claude output?
3. Is the shell hook (`UserPromptSubmit`) sufficient on its own?

---

### Phase 2: Implement Selective Evaluation [COMPLETED]

**Goal**: Modify the monitor to only evaluate task numbers on user prompts, not Claude output.

**Approach options** (pick one during Phase 1):

**Option A: Use prompt markers**
- Claude Code uses specific prompt markers (e.g., `❯`, `>`, or similar)
- Only evaluate lines that follow a prompt marker

**Option B: Event-based triggering**
- Instead of monitoring all buffer changes, hook into specific events
- Use `TermEnter` or similar to detect when user is about to type

**Option C: Rely on shell hook**
- The shell hook already fires only on `UserPromptSubmit`
- Neovim monitor only handles terminal close clearing
- Remove the per-line evaluation from Neovim entirely

**Tasks**:
- [ ] Implement chosen approach
- [ ] Ensure workflow commands set task number
- [ ] Ensure non-workflow commands clear task number
- [ ] Ensure Claude output doesn't trigger changes

**Timing**: 0.2 hours

**Files to modify**:
- `~/.config/nvim/lua/neotex/config/autocmds.lua`

**Verification**:
- `/research 795` → sets `#795`
- Claude responds → `#795` persists
- User types `/todo` → clears
- User types `/plan 796` → sets `#796`

---

### Phase 3: Manual Testing [COMPLETED]

**Goal**: Verify complete behavior across all scenarios.

**Test cases**:

| Step | Action | Expected |
|------|--------|----------|
| 1 | Open Claude Code | No task number |
| 2 | Type `/research 795` | Shows `#795` |
| 3 | Claude processes and responds | `#795` persists |
| 4 | Tool confirmation appears | `#795` persists |
| 5 | Type "continue" | Clears (non-workflow) |
| 6 | Type `/plan 795` | Shows `#795` |
| 7 | Claude responds | `#795` persists |
| 8 | Type `/todo` | Clears |
| 9 | Type `/implement 796` | Shows `#796` |
| 10 | Close terminal | Clears |

**Timing**: 0.1 hours

**Verification**:
- All test cases pass
- Task number only changes on user prompt submission

---

### Phase 4: Update Documentation [COMPLETED]

**Goal**: Document the correct persistence behavior.

**Tasks**:
- [ ] Update `.claude/context/project/hooks/wezterm-integration.md`
- [ ] Document: "Task number persists until next user prompt"
- [ ] Explain the workflow vs non-workflow distinction

**Timing**: 0.1 hours

**Files to modify**:
- `.claude/context/project/hooks/wezterm-integration.md`

## Testing & Validation

| Scenario | Expected |
|----------|----------|
| `/research N` submitted | Set `#N` |
| Claude responds | Persist |
| Tool runs | Persist |
| Non-workflow prompt submitted | Clear |
| `/plan N` submitted | Set `#N` |
| Terminal closes | Clear |

## Artifacts & Outputs

- Modified `~/.config/nvim/lua/neotex/config/autocmds.lua`
- Updated `.claude/context/project/hooks/wezterm-integration.md`

## Version History

| Version | Approach | Issue |
|---------|----------|-------|
| v001 | List of clear commands | Maintenance burden |
| v002 | Never clear | Too persistent |
| v003 | Clear on every non-match | Didn't persist across Claude output |
| v004 | Set/clear on user prompt only | Correct behavior |
