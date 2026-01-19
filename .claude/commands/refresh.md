# /cleanup Command

Identify and terminate orphaned Claude Code processes to reclaim memory.

## Syntax

```
/cleanup [--dry-run] [--force] [--status]
```

## Options

| Flag | Description |
|------|-------------|
| `--status` | Show current memory usage by Claude processes |
| `--dry-run` | Preview orphaned processes without terminating them |
| `--force` | Skip confirmation prompt and terminate immediately |
| (no flags) | Interactive cleanup with confirmation prompt |

## Execution

Invoke skill-cleanup with the provided arguments:

```
skill: skill-cleanup
args: {flags from command}
```

The skill will:
1. Detect orphaned Claude processes (processes with no controlling terminal)
2. Calculate memory usage
3. Based on flags:
   - `--status`: Display memory report and exit
   - `--dry-run`: List processes that would be terminated
   - `--force`: Terminate orphaned processes without confirmation
   - default: Show preview and ask for confirmation

## Safety

- **Never kills active sessions** - Only targets processes without TTY
- **Preserves current session** - Excludes the current process tree
- **Graceful shutdown first** - Sends SIGTERM before SIGKILL

## Examples

```bash
# Check memory usage
/cleanup --status

# Preview what would be cleaned
/cleanup --dry-run

# Clean up with confirmation
/cleanup

# Clean up immediately
/cleanup --force
```

## Output

Reports include:
- Total Claude processes and their memory usage
- Count of active vs orphaned processes
- Memory reclaimed (after cleanup)
- Any processes that couldn't be terminated
