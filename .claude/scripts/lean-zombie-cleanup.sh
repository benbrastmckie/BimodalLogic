#!/usr/bin/env bash
#
# lean-zombie-cleanup.sh - Clean up lean-lsp-mcp processes with zombie children
#
# Usage: ./lean-zombie-cleanup.sh [--force] [--dry-run] [--age-threshold MINUTES] [--verbose]
#
# Options:
#   --force          Execute cleanup without confirmation
#   --dry-run        Show what would be killed without acting
#   --age-threshold  Minimum process age in minutes (default: 60)
#   --verbose        Enable detailed logging
#
# Safety:
#   - Only targets processes with TTY == "?" (no controlling terminal)
#   - Only targets lean-lsp-mcp processes with zombie children
#   - Respects age threshold (default 60 minutes)
#   - Excludes current process tree
#
# Background:
#   The lean-lsp MCP server spawns `lake` subprocesses that can become zombies
#   when not properly reaped. This causes subsequent MCP calls to block indefinitely.
#   Since zombies are already dead, we must kill the parent process to clear them.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
FORCE=false
DRY_RUN=false
AGE_THRESHOLD=60  # minutes
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --age-threshold)
            AGE_THRESHOLD="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--force] [--dry-run] [--age-threshold MINUTES] [--verbose]"
            echo ""
            echo "Clean up lean-lsp-mcp processes with zombie children."
            echo ""
            echo "Options:"
            echo "  --force          Execute cleanup without confirmation"
            echo "  --dry-run        Show what would be killed without acting"
            echo "  --age-threshold  Minimum process age in minutes (default: 60)"
            echo "  --verbose        Enable detailed logging"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Convert age threshold to seconds
AGE_THRESHOLD_SECS=$((AGE_THRESHOLD * 60))

# Get current process tree to exclude
CURRENT_PID=$$
PARENT_PID=$(ps -o ppid= -p $$ 2>/dev/null | tr -d ' ')

# Logging function
log_verbose() {
    if $VERBOSE; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

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

# Function to get process age in seconds
get_process_age_secs() {
    local pid=$1
    ps -o etimes= -p "$pid" 2>/dev/null | tr -d ' '
}

# Function to get process age in human-readable format
get_process_age() {
    local pid=$1
    local elapsed=$(get_process_age_secs "$pid")

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

# Function to check if process has zombie children
has_zombie_children() {
    local ppid=$1
    # Look for children of this process in Z (zombie) state
    local zombie_count=$(ps --ppid "$ppid" -o stat= 2>/dev/null | grep -c '^Z' || echo "0")
    [ "$zombie_count" -gt 0 ]
}

# Function to count zombie children
count_zombie_children() {
    local ppid=$1
    ps --ppid "$ppid" -o stat= 2>/dev/null | grep -c '^Z' || echo "0"
}

# Function to get lean-lsp-mcp processes
get_lean_lsp_processes() {
    # Match lean-lsp processes (python/node running lean-lsp-mcp)
    ps aux 2>/dev/null | grep -E '[l]ean-lsp|[l]ean.*mcp' | grep -v grep || true
}

# Function to get orphaned lean-lsp processes (TTY == "?")
get_orphaned_lean_lsp_processes() {
    get_lean_lsp_processes | awk '$7 == "?" {print $0}'
}

# Main execution
log_verbose "Starting lean zombie cleanup"
log_verbose "Age threshold: ${AGE_THRESHOLD} minutes (${AGE_THRESHOLD_SECS} seconds)"
log_verbose "Current PID: $CURRENT_PID, Parent PID: $PARENT_PID"

# Get orphaned lean-lsp processes
orphan_procs=$(get_orphaned_lean_lsp_processes)

if [ -z "$orphan_procs" ]; then
    log_info "No orphaned lean-lsp-mcp processes found."
    exit 0
fi

log_verbose "Found orphaned lean-lsp processes:"
log_verbose "$orphan_procs"

# Build list of zombie-bearing processes that meet criteria
zombie_bearing_pids=()
zombie_bearing_details=()

while IFS= read -r line; do
    if [ -n "$line" ]; then
        pid=$(echo "$line" | awk '{print $2}')

        log_verbose "Checking PID $pid..."

        # Skip if in current process tree
        if is_in_current_tree "$pid"; then
            log_verbose "  Skipping: in current process tree"
            continue
        fi

        # Check process age
        age_secs=$(get_process_age_secs "$pid")
        if [ -z "$age_secs" ] || [ "$age_secs" -lt "$AGE_THRESHOLD_SECS" ]; then
            log_verbose "  Skipping: too young (${age_secs}s < ${AGE_THRESHOLD_SECS}s)"
            continue
        fi

        # Check for zombie children
        if ! has_zombie_children "$pid"; then
            log_verbose "  Skipping: no zombie children"
            continue
        fi

        zombie_count=$(count_zombie_children "$pid")
        age=$(get_process_age "$pid")
        cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}' | cut -c1-50)

        log_verbose "  MATCH: $zombie_count zombie children, age $age"

        zombie_bearing_pids+=("$pid")
        zombie_bearing_details+=("$pid|$zombie_count|$age|$cmd")
    fi
done <<< "$orphan_procs"

actual_count=${#zombie_bearing_pids[@]}

if [ "$actual_count" -eq 0 ]; then
    log_info "No zombie-bearing lean-lsp-mcp processes found (age >= ${AGE_THRESHOLD}m)."
    exit 0
fi

# Display findings
echo ""
echo -e "${YELLOW}Lean Zombie Cleanup${NC}"
echo "==================="
echo ""
echo "Found $actual_count lean-lsp-mcp process(es) with zombie children:"
echo ""
printf "%-8s %-10s %-10s %s\n" "PID" "Zombies" "Age" "Command"
printf "%-8s %-10s %-10s %s\n" "-----" "-------" "-------" "--------------------------------"

for detail in "${zombie_bearing_details[@]}"; do
    IFS='|' read -r pid zombies age cmd <<< "$detail"
    printf "%-8s %-10s %-10s %s\n" "$pid" "$zombies" "$age" "$cmd"
done

echo ""

# Dry-run mode - just report
if $DRY_RUN; then
    echo -e "${BLUE}DRY RUN:${NC} Would terminate $actual_count process(es)"
    echo "Re-run without --dry-run to execute cleanup"
    exit 0
fi

# Non-force mode without confirmation - just report
if ! $FORCE; then
    echo "Run with --force to terminate these processes"
    exit 0
fi

# Force mode - execute cleanup
echo -e "${GREEN}Terminating zombie-bearing processes...${NC}"
echo ""

terminated=0
failed=0

for pid in "${zombie_bearing_pids[@]}"; do
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
                terminated=$((terminated + 1))
            else
                echo "  PID $pid: failed to terminate"
                failed=$((failed + 1))
            fi
        else
            echo "  PID $pid: terminated (graceful)"
            terminated=$((terminated + 1))
        fi
    else
        echo "  PID $pid: failed to signal (permission denied?)"
        failed=$((failed + 1))
    fi
done

echo ""
echo -e "${GREEN}Lean Zombie Cleanup Complete${NC}"
echo "============================"
echo "Terminated: $terminated process(es)"
echo "Failed:     $failed process(es)"
echo ""
