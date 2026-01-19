#!/usr/bin/env bash
#
# claude-cleanup.sh - Identify and terminate orphaned Claude Code processes
#
# Usage: ./claude-cleanup.sh [--dry-run] [--force] [--status]
#
# Options:
#   --status   Show memory usage without cleanup
#   --dry-run  Preview orphaned processes without terminating
#   --force    Skip confirmation prompt
#   (none)     Interactive cleanup with confirmation
#
# Safety:
#   - Only targets processes with TTY == "?" (no controlling terminal)
#   - Excludes current process and parent process tree
#   - Uses SIGTERM first, then SIGKILL if needed

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
DRY_RUN=false
FORCE=false
STATUS_ONLY=false

for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            ;;
        --force)
            FORCE=true
            ;;
        --status)
            STATUS_ONLY=true
            ;;
        --help|-h)
            echo "Usage: $0 [--dry-run] [--force] [--status]"
            echo ""
            echo "Options:"
            echo "  --status   Show memory usage without cleanup"
            echo "  --dry-run  Preview orphaned processes without terminating"
            echo "  --force    Skip confirmation prompt"
            echo "  (none)     Interactive cleanup with confirmation"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Get current process tree to exclude
CURRENT_PID=$$
PARENT_PID=$(ps -o ppid= -p $$ 2>/dev/null | tr -d ' ')

# Function to check if a PID is in our process tree (should be excluded)
is_in_current_tree() {
    local pid=$1
    local check_pid=$pid

    # Walk up the process tree
    while [ "$check_pid" != "1" ] && [ -n "$check_pid" ]; do
        if [ "$check_pid" == "$CURRENT_PID" ] || [ "$check_pid" == "$PARENT_PID" ]; then
            return 0  # true, is in current tree
        fi
        check_pid=$(ps -o ppid= -p "$check_pid" 2>/dev/null | tr -d ' ')
    done
    return 1  # false, not in current tree
}

# Function to get process age in human-readable format
get_process_age() {
    local pid=$1
    local elapsed=$(ps -o etimes= -p "$pid" 2>/dev/null | tr -d ' ')

    if [ -z "$elapsed" ]; then
        echo "unknown"
        return
    fi

    local hours=$((elapsed / 3600))
    local minutes=$(((elapsed % 3600) / 60))

    if [ "$hours" -gt 0 ]; then
        echo "${hours}h ${minutes}m"
    else
        echo "${minutes}m"
    fi
}

# Function to format memory size (no bc dependency)
format_memory() {
    local kb=$1
    if [ "$kb" -ge 1048576 ]; then
        local gb=$((kb / 1048576))
        local gb_frac=$(((kb % 1048576) * 10 / 1048576))
        echo "${gb}.${gb_frac} GB"
    elif [ "$kb" -ge 1024 ]; then
        local mb=$((kb / 1024))
        local mb_frac=$(((kb % 1024) * 10 / 1024))
        echo "${mb}.${mb_frac} MB"
    else
        echo "${kb} KB"
    fi
}

# Get all Claude-related processes
# Match: claude, node.*claude, anthropic
get_claude_processes() {
    ps aux 2>/dev/null | grep -E '[c]laude|[n]ode.*claude|[a]nthropic' | grep -v grep || true
}

# Get orphaned processes (TTY == "?")
get_orphaned_processes() {
    get_claude_processes | awk '$7 == "?" {print $0}'
}

# Get active processes (have a TTY)
get_active_processes() {
    get_claude_processes | awk '$7 != "?"'
}

# Calculate total memory from process list
calculate_memory() {
    local total=0
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            mem=$(echo "$line" | awk '{print $6}')
            total=$((total + mem))
        fi
    done
    echo "$total"
}

# Main execution
echo ""

# Count processes - use wc -l with safeguard for empty strings
all_procs=$(get_claude_processes)
orphan_procs=$(get_orphaned_processes)
active_procs=$(get_active_processes)

count_lines() {
    local input="$1"
    if [ -z "$input" ]; then
        echo 0
    else
        echo "$input" | wc -l
    fi
}

total_count=$(count_lines "$all_procs")
orphan_count=$(count_lines "$orphan_procs")
active_count=$(count_lines "$active_procs")

# Calculate memory
total_mem=$(echo "$all_procs" | calculate_memory)
orphan_mem=$(echo "$orphan_procs" | calculate_memory)
active_mem=$(echo "$active_procs" | calculate_memory)

# Status mode - just show stats
if $STATUS_ONLY; then
    echo -e "${BLUE}Claude Code Memory Status${NC}"
    echo "========================="
    echo ""
    echo "Process Count:"
    echo "  Total Claude processes: $total_count"
    echo "  Active (with TTY):      $active_count"
    echo "  Orphaned (no TTY):      $orphan_count"
    echo ""
    echo "Memory Usage:"
    echo "  Total:    $(format_memory $total_mem)"
    echo "  Active:   $(format_memory $active_mem)"
    echo "  Orphaned: $(format_memory $orphan_mem) (reclaimable)"
    echo ""
    if [ "$orphan_count" -gt 0 ]; then
        echo -e "${YELLOW}Run '/cleanup' to terminate orphaned processes.${NC}"
    else
        echo -e "${GREEN}No orphaned processes found.${NC}"
    fi
    exit 0
fi

# No orphaned processes
if [ "$orphan_count" -eq 0 ]; then
    echo -e "${GREEN}Claude Code Cleanup${NC}"
    echo "==================="
    echo ""
    echo "No orphaned processes found."
    echo "All $active_count Claude processes are active sessions."
    exit 0
fi

# Build list of orphaned PIDs (excluding current tree)
orphan_pids=()
orphan_details=()

while IFS= read -r line; do
    if [ -n "$line" ]; then
        pid=$(echo "$line" | awk '{print $2}')

        # Skip if in current process tree
        if is_in_current_tree "$pid"; then
            continue
        fi

        mem=$(echo "$line" | awk '{print $6}')
        cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}' | cut -c1-50)
        age=$(get_process_age "$pid")

        orphan_pids+=("$pid")
        orphan_details+=("$pid|$(format_memory $mem)|$age|$cmd")
    fi
done <<< "$orphan_procs"

actual_orphan_count=${#orphan_pids[@]}

if [ "$actual_orphan_count" -eq 0 ]; then
    echo -e "${GREEN}Claude Code Cleanup${NC}"
    echo "==================="
    echo ""
    echo "No orphaned processes found (excluded current session)."
    exit 0
fi

# Dry run mode - show what would be cleaned
if $DRY_RUN; then
    echo -e "${YELLOW}Claude Code Cleanup (Dry Run)${NC}"
    echo "============================="
    echo ""
    echo "The following $actual_orphan_count orphaned processes would be terminated:"
    echo ""
    printf "%-8s %-12s %-10s %s\n" "PID" "Memory" "Age" "Command"
    printf "%-8s %-12s %-10s %s\n" "-----" "-------" "-------" "--------------------------------"

    for detail in "${orphan_details[@]}"; do
        IFS='|' read -r pid mem age cmd <<< "$detail"
        printf "%-8s %-12s %-10s %s\n" "$pid" "$mem" "$age" "$cmd"
    done

    echo ""
    echo "Total memory that would be reclaimed: $(format_memory $orphan_mem)"
    echo ""
    echo -e "${BLUE}Run '/cleanup --force' to terminate these processes.${NC}"
    exit 0
fi

# Interactive mode - ask for confirmation
if ! $FORCE; then
    echo -e "${YELLOW}Claude Code Cleanup${NC}"
    echo "==================="
    echo ""
    echo "Found $actual_orphan_count orphaned processes using $(format_memory $orphan_mem):"
    echo ""
    printf "%-8s %-12s %-10s %s\n" "PID" "Memory" "Age" "Command"
    printf "%-8s %-12s %-10s %s\n" "-----" "-------" "-------" "--------------------------------"

    for detail in "${orphan_details[@]}"; do
        IFS='|' read -r pid mem age cmd <<< "$detail"
        printf "%-8s %-12s %-10s %s\n" "$pid" "$mem" "$age" "$cmd"
    done

    echo ""
    read -p "Terminate these processes? [y/N] " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Execute cleanup
echo ""
echo -e "${GREEN}Terminating orphaned processes...${NC}"

terminated=0
failed=0

for pid in "${orphan_pids[@]}"; do
    # Check if process still exists
    if ! kill -0 "$pid" 2>/dev/null; then
        echo "  PID $pid: already gone"
        continue
    fi

    # Try SIGTERM first
    if kill -15 "$pid" 2>/dev/null; then
        sleep 0.5

        # Check if still running
        if kill -0 "$pid" 2>/dev/null; then
            # Force kill
            if kill -9 "$pid" 2>/dev/null; then
                echo "  PID $pid: terminated (forced)"
                ((terminated++))
            else
                echo "  PID $pid: failed to terminate"
                ((failed++))
            fi
        else
            echo "  PID $pid: terminated (graceful)"
            ((terminated++))
        fi
    else
        echo "  PID $pid: failed to signal (permission denied?)"
        ((failed++))
    fi
done

echo ""
echo -e "${GREEN}Claude Code Cleanup Complete${NC}"
echo "============================"
echo "Terminated: $terminated processes"
echo "Failed:     $failed processes"
echo "Memory reclaimed: ~$(format_memory $orphan_mem)"
echo ""
echo "Active sessions preserved: $active_count"
