# /refresh Command

Identify and terminate orphaned Claude Code processes to reclaim memory.

## Syntax

```
/refresh [--force]
```

## Options

| Flag | Description |
|------|-------------|
| `--force` | Terminate orphaned processes immediately without confirmation |
| (no flags) | Show status and prompt for confirmation |

## Execution

Invoke skill-refresh with the provided arguments:

```
skill: skill-refresh
args: {flags from command}
```

The skill will:
1. Run the detection script to identify orphaned Claude processes
2. Display status report with process list and memory usage
3. Based on flags:
   - `--force`: Terminate orphaned processes immediately
   - default: Use AskUserQuestion to prompt for confirmation, then terminate if confirmed

## Safety

- **Never kills active sessions** - Only targets processes without TTY
- **Preserves current session** - Excludes the current process tree
- **Graceful shutdown first** - Sends SIGTERM before SIGKILL

## Examples

```bash
# Show status and prompt for confirmation
/refresh

# Terminate orphaned processes immediately
/refresh --force
```

## Output

Reports include:
- Total Claude processes and their memory usage
- Count of active vs orphaned processes
- List of orphaned processes with PID, memory, age, and command
- Memory reclaimed (after cleanup)
- Any processes that couldn't be terminated
