#!/usr/bin/env bash
# readme-inventory.sh -- Generate a Markdown module inventory table for a directory
#
# Usage: ./scripts/readme-inventory.sh <directory>
#
# Output: Markdown table listing each .lean file and subdirectory with line count.
# Paste the output into the README.md Module Inventory section.

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <directory>" >&2
  exit 1
fi

DIR="$1"

if [ ! -d "$DIR" ]; then
  echo "Error: Directory '$DIR' does not exist." >&2
  exit 1
fi

echo "| File | Lines | Description |"
echo "|------|-------|-------------|"

# List .lean files directly in the directory (not in subdirectories)
find "$DIR" -maxdepth 1 -name "*.lean" | sort | while read -r file; do
  basename=$(basename "$file")
  lines=$(wc -l < "$file")
  echo "| \`$basename\` | $lines | <!-- TODO: add description --> |"
done

# List subdirectories that contain .lean files
find "$DIR" -maxdepth 1 -mindepth 1 -type d | sort | while read -r subdir; do
  subdirname=$(basename "$subdir")
  # Check if this subdirectory contains any .lean files (recursively)
  lean_count=$(find "$subdir" -name "*.lean" | wc -l)
  if [ "$lean_count" -gt 0 ]; then
    echo "| \`$subdirname/\` | — | <!-- TODO: subdirectory description --> |"
  fi
done
