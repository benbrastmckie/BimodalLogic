---
name: skill-cleanup
description: Identify and terminate orphaned Claude Code processes to reclaim memory
allowed-tools: Bash, Read
---

# Cleanup Skill (Direct Execution)

Direct execution skill for identifying and terminating orphaned Claude Code processes. This skill executes inline without spawning a subagent.

## Trigger Conditions

This skill activates when:
- User invokes `/cleanup` command
- Memory usage needs investigation
- Orphaned processes need cleanup

## Command Syntax

```
/cleanup [--dry-run] [--force] [--status]
```

| Flag | Description |
|------|-------------|
| `--status` | Show memory usage without cleanup |
| `--dry-run` | Preview orphaned processes without terminating |
| `--force` | Skip confirmation prompt |
| (no flags) | Interactive cleanup with confirmation |

---

## Execution

### 1. Parse Arguments

Parse command flags from input:
- `--status`: Only show memory stats
- `--dry-run`: Preview without action
- `--force`: Skip confirmation

### 2. Detect Orphaned Processes

**Definition**: Claude Code processes with `TTY == "??"` (no controlling terminal) are considered orphaned.

**Detection Command**:
```bash
# Get orphaned Claude processes (excluding current session)
ps aux | grep -E '[c]laude|[n]ode.*claude' | awk '$7 == "??" {print $0}'
```

**Important**: Exclude current process and parent process from results:
```bash
current_pid=$$
parent_pid=$(ps -o ppid= -p $$)
```

### 3. Calculate Memory Usage

For `--status` mode, show memory summary:
```bash
# Get total memory used by Claude processes
ps aux | grep -E '[c]laude|[n]ode.*claude' | awk '{sum += $6} END {print sum/1024 " MB"}'

# Get orphaned process memory
ps aux | grep -E '[c]laude|[n]ode.*claude' | awk '$7 == "??" {sum += $6} END {print sum/1024 " MB"}'
```

### 4. Execute Cleanup (if not dry-run)

**For each orphaned process**:
```bash
# Send SIGTERM first (graceful)
kill -15 $pid

# Wait briefly
sleep 1

# If still running, SIGKILL
if kill -0 $pid 2>/dev/null; then
    kill -9 $pid
fi
```

### 5. Report Results

Return summary:
```
Claude Code Cleanup Report
==========================

Before:
- Total Claude processes: {N}
- Orphaned processes: {M}
- Total memory: {X} MB
- Orphaned memory: {Y} MB

Action taken: {none|preview|terminated}

After:
- Terminated processes: {count}
- Memory reclaimed: {Z} MB
```

---

## Safety Measures

1. **Never kill processes with a TTY** - Active sessions have terminals
2. **Exclude current process tree** - Don't kill the running cleanup command
3. **SIGTERM before SIGKILL** - Allow graceful shutdown
4. **Confirmation by default** - Require `--force` to skip

---

## Integration with Scripts

The skill delegates to `.claude/scripts/claude-cleanup.sh` for the actual process management:

```bash
.claude/scripts/claude-cleanup.sh [--dry-run] [--force] [--status]
```

This separation allows:
- CLI usage outside Claude Code
- Integration with shell aliases
- systemd timer automation

---

## Return Format

### For --status:
```
Claude Code Memory Status
=========================
Total Claude processes: 12
Active (with TTY): 3
Orphaned (no TTY): 9

Memory Usage:
- Total: 5.2 GB
- Active: 1.1 GB
- Orphaned: 4.1 GB (reclaimable)

Run `/cleanup` to terminate orphaned processes.
```

### For --dry-run:
```
Claude Code Cleanup (Dry Run)
=============================
The following 9 orphaned processes would be terminated:

PID    Memory    Age       Command
-----  -------   -------   --------------------------------
12345  450 MB    2h 15m    node /path/to/claude-code/...
12346  380 MB    1h 45m    node /path/to/claude-code/...
...

Total memory that would be reclaimed: 4.1 GB

Run `/cleanup --force` to terminate these processes.
```

### For cleanup:
```
Claude Code Cleanup Complete
============================
Terminated 9 orphaned processes
Memory reclaimed: 4.1 GB

Active sessions preserved: 3
```

---

## Error Handling

### Permission Denied
If kill fails due to permissions, report which processes couldn't be terminated.

### No Orphaned Processes
If no orphaned processes found, report "All Claude processes are active sessions."

### Process Already Gone
If process exits between detection and kill, ignore the error and continue.
