---
name: skill-refresh
description: Identify and terminate orphaned Claude Code processes to reclaim memory
allowed-tools: Bash, Read, AskUserQuestion
---

# Refresh Skill (Direct Execution)

Direct execution skill for identifying and terminating orphaned Claude Code processes. This skill executes inline without spawning a subagent.

## Trigger Conditions

This skill activates when:
- User invokes `/refresh` command
- Memory usage needs investigation
- Orphaned processes need cleanup

## Command Syntax

```
/refresh [--force]
```

| Flag | Description |
|------|-------------|
| `--force` | Terminate orphaned processes immediately |
| (no flags) | Show status and prompt for confirmation |

---

## Execution

### 1. Parse Arguments

Parse command flags from input:
- `--force`: Skip confirmation and terminate immediately

### 2. Run Detection Script

Execute the detection script to get status:
```bash
.claude/scripts/claude-refresh.sh
```

The script will output:
- Process counts (total, active, orphaned)
- Memory usage breakdown
- List of orphaned processes with PID, memory, age, and command
- Exit without terminating (unless --force is passed)

### 3. Handle Based on Mode

#### Force Mode (--force flag provided)

Run the script with --force to terminate immediately:
```bash
.claude/scripts/claude-refresh.sh --force
```

Display the termination results and exit.

#### Default Mode (no flags)

1. Display the status output from the script
2. If orphaned processes were found, use AskUserQuestion for confirmation:

```json
{
  "question": "Terminate these orphaned processes?",
  "header": "Confirm Cleanup",
  "options": [
    {
      "label": "Yes, terminate",
      "description": "Kill orphaned processes and reclaim memory"
    },
    {
      "label": "Cancel",
      "description": "Exit without changes"
    }
  ]
}
```

3. If user confirms, run the script with --force:
```bash
.claude/scripts/claude-refresh.sh --force
```

4. Display the termination results

---

## Safety Measures

1. **Never kill processes with a TTY** - Active sessions have terminals
2. **Exclude current process tree** - Don't kill the running command
3. **SIGTERM before SIGKILL** - Allow graceful shutdown
4. **Confirmation by default** - Require `--force` to skip

---

## Integration with Scripts

The skill delegates to `.claude/scripts/claude-refresh.sh` for process management:

```bash
.claude/scripts/claude-refresh.sh [--force]
```

This separation allows:
- CLI usage outside Claude Code
- Integration with shell aliases
- systemd timer automation

---

## Return Format

### For default mode (no orphans):
```
Claude Code Refresh
===================

No orphaned processes found.
All N Claude processes are active sessions.
```

### For default mode (with orphans, after confirmation):
```
Claude Code Refresh
===================

Found N orphaned processes using X MB:

PID      Memory       Age        Command
-----    -------      -------    --------------------------------
12345    450 MB       2h 15m     node /path/to/claude-code/...
...

Terminating orphaned processes...
  PID 12345: terminated (graceful)
  ...

Claude Code Cleanup Complete
============================
Terminated: N processes
Failed:     0 processes
Memory reclaimed: ~X MB

Active sessions preserved: M
```

### For --force mode:
Same as above but without the confirmation prompt.

---

## Error Handling

### Permission Denied
If kill fails due to permissions, report which processes couldn't be terminated.

### No Orphaned Processes
If no orphaned processes found, report "All Claude processes are active sessions."

### Process Already Gone
If process exits between detection and kill, ignore the error and continue.
