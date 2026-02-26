#!/usr/bin/env bash
#
# generate-context-index.sh - Generate .claude/context/index.json
#
# Scans all .md, .json, .yaml files in .claude/context/ and generates
# index entries with load_when conditions based on file location patterns.
#
# Usage: ./generate-context-index.sh [--output FILE] [--dry-run]
#
# Options:
#   --output FILE   Output to FILE instead of .claude/context/index.json
#   --dry-run       Print to stdout without writing file
#

set -euo pipefail

# Change to project root (parent of .claude)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
cd "$PROJECT_ROOT"

CONTEXT_DIR=".claude/context"
OUTPUT_FILE="$CONTEXT_DIR/index.json"
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Function to extract summary from first heading or first paragraph
extract_summary() {
    local file="$1"
    local summary=""

    # Try to get first H1 heading (excluding the title line itself)
    summary=$(head -20 "$file" | grep -E "^# " | head -1 | sed 's/^# //' | tr -d '\r')

    # If no H1, try first non-empty line that's not a heading or metadata
    if [[ -z "$summary" ]] || [[ ${#summary} -lt 20 ]]; then
        summary=$(head -30 "$file" | grep -vE "^#|^-|^\*\*|^$" | head -1 | tr -d '\r')
    fi

    # Truncate to 200 chars max
    if [[ ${#summary} -gt 200 ]]; then
        summary="${summary:0:197}..."
    fi

    # Ensure minimum length (pad if needed)
    if [[ ${#summary} -lt 20 ]]; then
        summary="Context file for ${file##*/}"
    fi

    # Escape for JSON (backslash first, then quotes)
    summary=$(echo "$summary" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | tr -d '\n')
    echo "$summary"
}

# Function to generate topics from path and filename
generate_topics() {
    local rel_path="$1"
    local filename=$(basename "$rel_path" .md)
    local dirname=$(dirname "$rel_path")

    # Extract topics from filename (split by - and _)
    local topics=()

    # Add filename-derived topics
    IFS='-_' read -ra parts <<< "$filename"
    for part in "${parts[@]}"; do
        [[ -n "$part" ]] && topics+=("$part")
    done

    # Add parent directory as topic if not 'core' or 'project'
    local parent=$(basename "$dirname")
    if [[ "$parent" != "core" ]] && [[ "$parent" != "project" ]] && [[ -n "$parent" ]]; then
        topics=("$parent" "${topics[@]}")
    fi

    # Dedupe and limit to 5
    local unique_topics=()
    for t in "${topics[@]}"; do
        local found=false
        for u in "${unique_topics[@]}"; do
            [[ "$t" == "$u" ]] && found=true && break
        done
        $found || unique_topics+=("$t")
        [[ ${#unique_topics[@]} -ge 5 ]] && break
    done

    # Format as JSON array
    local json_arr="["
    local first=true
    for t in "${unique_topics[@]}"; do
        $first || json_arr+=", "
        json_arr+="\"$t\""
        first=false
    done
    json_arr+="]"

    echo "$json_arr"
}

# Function to determine load_when based on path patterns
determine_load_when() {
    local rel_path="$1"

    local languages="[]"
    local operations="[]"
    local tiers="[]"
    local agents="[]"
    local conditions="[]"

    # Domain-specific patterns
    if [[ "$rel_path" == project/lean4/* ]]; then
        languages='["lean"]'
        if [[ "$rel_path" == */patterns/* ]]; then
            operations='["implementation"]'
            tiers='["agent"]'
            agents='["lean-implementation-agent"]'
        elif [[ "$rel_path" == */tools/* ]]; then
            operations='["any"]'
            tiers='["agent"]'
            agents='["lean-research-agent", "lean-implementation-agent"]'
        elif [[ "$rel_path" == */agents/* ]]; then
            operations='["any"]'
            tiers='["orchestrator", "command"]'
        elif [[ "$rel_path" == */operations/* ]]; then
            operations='["implementation"]'
            tiers='["agent"]'
        elif [[ "$rel_path" == */domain/* ]]; then
            operations='["any"]'
            tiers='["agent"]'
            agents='["lean-research-agent", "lean-implementation-agent"]'
        else
            operations='["any"]'
            tiers='["agent"]'
        fi
    elif [[ "$rel_path" == project/logic/* ]]; then
        languages='["logic", "lean"]'
        operations='["any"]'
        tiers='["agent"]'
        agents='["lean-research-agent", "lean-implementation-agent"]'
    elif [[ "$rel_path" == project/math/* ]]; then
        languages='["math", "lean"]'
        operations='["any"]'
        tiers='["agent"]'
    elif [[ "$rel_path" == project/latex/* ]]; then
        languages='["latex"]'
        operations='["any"]'
        tiers='["agent"]'
    elif [[ "$rel_path" == project/typst/* ]]; then
        languages='["typst"]'
        operations='["any"]'
        tiers='["agent"]'
    elif [[ "$rel_path" == project/meta/* ]]; then
        languages='["meta"]'
        operations='["any"]'
        tiers='["orchestrator", "command"]'
    elif [[ "$rel_path" == project/* ]]; then
        # Other project files
        languages='["any"]'
        operations='["any"]'
        tiers='["agent"]'
    fi

    # Core patterns
    if [[ "$rel_path" == core/* ]]; then
        if [[ "$rel_path" == core/patterns/* ]]; then
            languages='["any"]'
            operations='["any"]'
            tiers='["agent"]'
            # Specific pattern files
            if [[ "$rel_path" == *blocked-mcp-tools* ]]; then
                languages='["lean"]'
                agents='["lean-research-agent", "lean-implementation-agent"]'
            elif [[ "$rel_path" == *anti-stop* ]] || [[ "$rel_path" == *early-metadata* ]]; then
                tiers='["agent"]'
            fi
        elif [[ "$rel_path" == core/workflows/* ]]; then
            languages='["any"]'
            operations='["any"]'
            tiers='["command"]'
        elif [[ "$rel_path" == core/orchestration/* ]]; then
            languages='["any"]'
            operations='["any"]'
            tiers='["orchestrator", "command"]'
        elif [[ "$rel_path" == core/reference/* ]]; then
            languages='["any"]'
            operations='["any"]'
            tiers='["orchestrator", "command", "agent"]'
        elif [[ "$rel_path" == core/formats/* ]]; then
            languages='["any"]'
            operations='["any"]'
            tiers='["agent"]'
        elif [[ "$rel_path" == core/checkpoints/* ]]; then
            languages='["any"]'
            operations='["any"]'
            tiers='["command"]'
        elif [[ "$rel_path" == core/standards/* ]]; then
            languages='["any"]'
            operations='["any"]'
            tiers='["agent"]'
        elif [[ "$rel_path" == core/templates/* ]]; then
            languages='["any"]'
            operations='["any"]'
            tiers='["agent"]'
        elif [[ "$rel_path" == core/architecture/* ]]; then
            languages='["meta"]'
            operations='["any"]'
            tiers='["orchestrator"]'
        elif [[ "$rel_path" == core/troubleshooting/* ]]; then
            languages='["any"]'
            operations='["any"]'
            tiers='["orchestrator", "command", "agent"]'
            conditions='["when diagnosing issues"]'
        elif [[ "$rel_path" == core/schemas/* ]]; then
            languages='["meta"]'
            operations='["any"]'
            tiers='["orchestrator", "command"]'
        else
            languages='["any"]'
            operations='["any"]'
            tiers='["command"]'
        fi
    fi

    # Root level files (index.md, README.md, etc.)
    if [[ "$rel_path" != */* ]]; then
        languages='["any"]'
        operations='["any"]'
        tiers='["orchestrator", "command"]'
    fi

    # Build JSON object
    local load_when="{"
    local first=true

    if [[ "$languages" != "[]" ]]; then
        $first || load_when+=", "
        load_when+="\"languages\": $languages"
        first=false
    fi
    if [[ "$operations" != "[]" ]]; then
        $first || load_when+=", "
        load_when+="\"operations\": $operations"
        first=false
    fi
    if [[ "$tiers" != "[]" ]]; then
        $first || load_when+=", "
        load_when+="\"tiers\": $tiers"
        first=false
    fi
    if [[ "$agents" != "[]" ]]; then
        $first || load_when+=", "
        load_when+="\"agents\": $agents"
        first=false
    fi
    if [[ "$conditions" != "[]" ]]; then
        $first || load_when+=", "
        load_when+="\"conditions\": $conditions"
        first=false
    fi

    load_when+="}"
    echo "$load_when"
}

# Read the existing schema header from index.json
read_schema_header() {
    if [[ -f "$CONTEXT_DIR/index.json" ]]; then
        # Extract everything up to and including "definitions" block
        jq 'del(.version, .generated_at, .file_count, .entries)' "$CONTEXT_DIR/index.json"
    else
        echo "Error: $CONTEXT_DIR/index.json does not exist. Create schema first." >&2
        exit 1
    fi
}

# Main execution
echo "Generating context index..." >&2

# Get schema header
schema_header=$(read_schema_header)

# Collect all files
files=()
while IFS= read -r file; do
    [[ "$file" == "$CONTEXT_DIR/index.json" ]] && continue
    files+=("$file")
done < <(find "$CONTEXT_DIR" -type f \( -name "*.md" -o -name "*.yaml" \) | sort)

count=${#files[@]}
echo "Found $count files..." >&2

# Build entries array incrementally to avoid huge string
entries_file=$(mktemp)
echo "[" > "$entries_file"

first=true
for file in "${files[@]}"; do
    # Get relative path from context dir
    rel_path="${file#$CONTEXT_DIR/}"

    # Determine domain
    domain="core"
    [[ "$rel_path" == project/* ]] && domain="project"
    [[ "$rel_path" != core/* ]] && [[ "$rel_path" != project/* ]] && domain="core"

    # Determine subdomain (second path component or root)
    subdomain=""
    if [[ "$rel_path" == */* ]]; then
        if [[ "$rel_path" == project/* ]]; then
            subdomain=$(echo "$rel_path" | cut -d'/' -f2)
        elif [[ "$rel_path" == core/* ]]; then
            subdomain=$(echo "$rel_path" | cut -d'/' -f2)
        else
            subdomain="root"
        fi
    else
        subdomain="root"
    fi

    # Determine category (third level if exists)
    category=""
    depth=$(echo "$rel_path" | tr '/' '\n' | wc -l)
    if [[ $depth -gt 3 ]]; then
        if [[ "$rel_path" == project/* ]]; then
            category=$(echo "$rel_path" | cut -d'/' -f3)
        elif [[ "$rel_path" == core/* ]]; then
            category=$(echo "$rel_path" | cut -d'/' -f3)
        fi
    fi

    # Get line count
    line_count=$(wc -l < "$file" | tr -d ' ')
    [[ $line_count -lt 1 ]] && line_count=1

    # Generate topics
    topics=$(generate_topics "$rel_path")

    # Extract summary
    summary=$(extract_summary "$file")

    # Determine load_when
    load_when=$(determine_load_when "$rel_path")

    # Build entry JSON
    $first || echo "," >> "$entries_file"
    echo -n "  {" >> "$entries_file"
    echo -n "\"path\": \"$rel_path\"" >> "$entries_file"
    echo -n ", \"domain\": \"$domain\"" >> "$entries_file"
    echo -n ", \"subdomain\": \"$subdomain\"" >> "$entries_file"
    [[ -n "$category" ]] && echo -n ", \"category\": \"$category\"" >> "$entries_file"
    echo -n ", \"topics\": $topics" >> "$entries_file"
    echo -n ", \"summary\": \"$summary\"" >> "$entries_file"
    echo -n ", \"load_when\": $load_when" >> "$entries_file"
    echo -n ", \"line_count\": $line_count" >> "$entries_file"
    echo "}" >> "$entries_file"

    first=false
done

echo "]" >> "$entries_file"

# Current timestamp
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Read entries from temp file
entries=$(cat "$entries_file")
rm "$entries_file"

# Merge schema with data
final_output=$(jq -n \
    --argjson schema "$schema_header" \
    --arg version "1.0.0" \
    --arg timestamp "$timestamp" \
    --argjson count "$count" \
    --argjson entries "$entries" \
    '$schema + {version: $version, generated_at: $timestamp, file_count: $count, entries: $entries}'
)

if $DRY_RUN; then
    echo "$final_output" | jq '.'
else
    echo "$final_output" | jq '.' > "$OUTPUT_FILE"
    echo "Generated $OUTPUT_FILE with $count entries" >&2
fi
