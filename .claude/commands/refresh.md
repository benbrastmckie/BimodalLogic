# /refresh Command

Manage Claude Code resources - terminate orphaned processes or clean up old project files.

## Syntax

```
/refresh [--force]                              # Process cleanup (default)
/refresh --projects [--age DAYS] [--dry-run] [--force]  # Project cleanup
```

## Modes

### Process Cleanup (Default)

Identify and terminate orphaned Claude Code processes to reclaim memory.

| Flag | Description |
|------|-------------|
| `--force` | Terminate orphaned processes immediately without confirmation |
| (no flags) | Show status and prompt for confirmation |

### Project Cleanup (--projects)

Survey and clean up accumulated session files in `~/.claude/projects/`.

| Flag | Description |
|------|-------------|
| `--projects` | Enable project file cleanup mode |
| `--age DAYS` | Only target sessions older than DAYS (default: 7) |
| `--dry-run` | Show what would be cleaned without making changes |
| `--force` | Skip confirmation and clean immediately |

## Execution

Invoke skill-refresh with the provided arguments:

```
skill: skill-refresh
args: {flags from command}
```

### Process Mode

The skill will:
1. Run the detection script to identify orphaned Claude processes
2. Display status report with process list and memory usage
3. Based on flags:
   - `--force`: Terminate orphaned processes immediately
   - default: Use AskUserQuestion to prompt for confirmation, then terminate if confirmed

### Project Mode

The skill will:
1. Run the project cleanup script to survey project files
2. Display usage statistics and cleanup candidates
3. Based on flags:
   - `--dry-run`: Show what would be deleted without changes
   - `--force`: Delete old files immediately
   - default: Use AskUserQuestion to prompt for confirmation, then clean if confirmed

## Safety

### Process Cleanup

- **Never kills active sessions** - Only targets processes without TTY
- **Preserves current session** - Excludes the current process tree
- **Graceful shutdown first** - Sends SIGTERM before SIGKILL

### Project Cleanup

- **Never modifies sessions-index.json** - System file managed by Claude Code
- **Never deletes recent files** - Files modified within last hour are protected
- **Age threshold** - Only targets sessions older than threshold (default: 7 days)
- **Dry-run available** - Preview changes before executing

## Examples

### Process Cleanup

```bash
# Show status and prompt for confirmation
/refresh

# Terminate orphaned processes immediately
/refresh --force
```

### Project Cleanup

```bash
# Survey project files and prompt for cleanup
/refresh --projects

# Preview cleanup without making changes
/refresh --projects --dry-run

# Clean files older than 14 days
/refresh --projects --age 14

# Clean files immediately without confirmation
/refresh --projects --force

# Preview cleanup with custom age threshold
/refresh --projects --age 3 --dry-run
```

## Output

### Process Mode

Reports include:
- Total Claude processes and their memory usage
- Count of active vs orphaned processes
- List of orphaned processes with PID, memory, age, and command
- Memory reclaimed (after cleanup)
- Any processes that couldn't be terminated

### Project Mode

Reports include:
- Project path and Claude Code project directory
- Total disk usage (size, session count, JSONL count)
- Cleanup candidates (files/dirs older than threshold)
- Size that can be reclaimed
- Detailed list of files (in dry-run or force mode)
