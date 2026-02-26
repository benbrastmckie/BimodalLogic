---
name: skill-lean-version
description: Manage Lean toolchain and Mathlib versions with backup, upgrade, and rollback support
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
---

# Lean Version Management Skill (Direct Execution)

Direct execution skill for managing Lean toolchain and Mathlib versions. Provides check, upgrade, rollback, and dry-run modes. Creates backups before upgrades and supports interactive user confirmation.

This skill executes inline without spawning a subagent.

## Context References

Load on-demand using @-references:

**Always Load**:
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md` - MCP tool reference

**Load for Version Patterns**:
- `@.claude/rules/lean4.md` - Lean development patterns

---

## Execution

### Step 1: Parse Arguments

Extract mode and flags from command input:
- First non-flag argument: Mode (`check`, `upgrade`, `rollback`) - default: `check`
- `--dry-run`: Preview mode
- `--version VERSION`: Target version for upgrade

```bash
# Initialize defaults
mode="check"
dry_run=false
target_version=""

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    check|upgrade|rollback)
      mode="$arg"
      ;;
    --dry-run)
      dry_run=true
      ;;
    --version)
      shift
      target_version="$1"
      ;;
    --version=*)
      target_version="${arg#*=}"
      ;;
  esac
done
```

---

### Step 2: Read Current State

**EXECUTE NOW**: Read version configuration files.

```bash
# Read current toolchain
if [ -f "lean-toolchain" ]; then
  current_toolchain=$(cat lean-toolchain | tr -d '\n')
else
  current_toolchain="not found"
fi

# Read current Mathlib version from lakefile.lean
if [ -f "lakefile.lean" ]; then
  current_mathlib=$(grep -oP 'mathlib.*@\s*"\K[^"]+' lakefile.lean 2>/dev/null || echo "not found")
else
  current_mathlib="not found"
fi

echo "Current toolchain: $current_toolchain"
echo "Current Mathlib: $current_mathlib"
```

---

### Step 3: Route by Mode

Branch based on parsed mode:

- **check** -> Step 4 (Check Mode)
- **upgrade** -> Step 5 (Upgrade Mode)
- **rollback** -> Step 6 (Rollback Mode)

---

## Step 4: Check Mode

Display current version status and available information.

### 4A: Gather Information

```bash
# Get elan status
elan_status=$(elan show 2>/dev/null || echo "elan not available")

# List installed toolchains
toolchain_list=$(elan toolchain list 2>/dev/null || echo "none")

# Check for backups
backup_dir=".lean-version-backup"
if [ -d "$backup_dir" ]; then
  backup_list=$(ls -t "$backup_dir"/lean-toolchain.* 2>/dev/null | head -5 | while read f; do
    timestamp=$(basename "$f" | sed 's/lean-toolchain\.//')
    echo "- $timestamp"
  done)
  [ -z "$backup_list" ] && backup_list="None"
else
  backup_list="None"
fi
```

### 4B: Display Report

```
Lean Version Status
===================

Current Configuration:
- Toolchain: {current_toolchain}
- Mathlib: {current_mathlib}

Installed Toolchains:
{elan_status}

Backups Available:
{backup_list}

Tip: Run /lean upgrade to update to the latest version.
     Run /lean --dry-run upgrade to preview changes first.
```

**STOP** - execution complete.

---

## Step 5: Upgrade Mode

Perform interactive upgrade with backup and user confirmation.

### 5A: Check Dry-Run Mode

If `--dry-run` is set:

```
Lean Upgrade Preview (Dry Run)
==============================

Current Configuration:
- Toolchain: {current_toolchain}
- Mathlib: {current_mathlib}

Target Configuration:
- Toolchain: {target_version or "latest"}
- Mathlib: {target_version or "latest"}

Files that would be modified:
- lean-toolchain
- lakefile.lean

Commands that would run:
- lake update
- lake exe cache get

Backup would be created in: .lean-version-backup/

No changes made (dry run mode).
```

**STOP** - execution complete.

---

### 5B: Create Backup

**EXECUTE NOW**: Create backup before making changes.

```bash
# Create backup directory
mkdir -p .lean-version-backup

# Generate timestamp
timestamp=$(date +%Y%m%d_%H%M%S)

# Backup current files
cp lean-toolchain ".lean-version-backup/lean-toolchain.$timestamp" 2>/dev/null
cp lakefile.lean ".lean-version-backup/lakefile.lean.$timestamp" 2>/dev/null
cp lake-manifest.json ".lean-version-backup/lake-manifest.json.$timestamp" 2>/dev/null

echo "Backup created with timestamp: $timestamp"
```

---

### 5C: Prompt for Confirmation

**EXECUTE NOW**: Use AskUserQuestion to confirm upgrade.

```json
{
  "question": "Proceed with Lean version upgrade?",
  "header": "Upgrade Confirmation",
  "multiSelect": false,
  "options": [
    {
      "label": "Yes, upgrade",
      "description": "Update toolchain and Mathlib, run lake update, download cache"
    },
    {
      "label": "No, cancel",
      "description": "Keep current versions, no changes made"
    }
  ]
}
```

**If user selects "No, cancel"**:
```
Upgrade cancelled.
No changes made.
```
**STOP** - execution complete.

**If user selects "Yes, upgrade"**: **CONTINUE** to 5D.

---

### 5D: Determine Target Version

If `--version` was specified, use that. Otherwise, determine latest:

**Option 1: Use specified version**
```bash
if [ -n "$target_version" ]; then
  new_toolchain="leanprover/lean4:$target_version"
  new_mathlib="$target_version"
fi
```

**Option 2: Fetch latest from Mathlib master** (when no version specified)
```bash
# Fetch latest toolchain from Mathlib master
curl -sL https://raw.githubusercontent.com/leanprover-community/mathlib4/master/lean-toolchain -o /tmp/latest-toolchain
new_toolchain=$(cat /tmp/latest-toolchain | tr -d '\n')
# Extract version number for Mathlib
new_mathlib=$(echo "$new_toolchain" | grep -oP 'v[\d.]+(-rc\d+)?')
```

---

### 5E: Apply Changes

**EXECUTE NOW**: Update version files.

```bash
# Update lean-toolchain
echo "$new_toolchain" > lean-toolchain

# Update lakefile.lean Mathlib pin
# Pattern: @ "vX.Y.Z" or @ "vX.Y.Z-rcN"
sed -i "s|@ \"v[0-9.]*\(-rc[0-9]*\)\?\"|@ \"$new_mathlib\"|g" lakefile.lean
```

---

### 5F: Run Post-Upgrade Commands

**EXECUTE NOW**: Run lake update and cache download.

```bash
echo "Running lake update..."
lake_update_result=$(lake update 2>&1)
lake_update_status=$?

echo "Running lake exe cache get..."
cache_get_result=$(lake exe cache get 2>&1)
cache_get_status=$?
```

---

### 5G: Cleanup Old Backups

Keep only the 3 most recent backups:

```bash
# List all backup timestamps and keep only 3 most recent
ls -t .lean-version-backup/lean-toolchain.* 2>/dev/null | tail -n +4 | while read old_backup; do
  timestamp=$(basename "$old_backup" | sed 's/lean-toolchain\.//')
  rm -f ".lean-version-backup/lean-toolchain.$timestamp"
  rm -f ".lean-version-backup/lakefile.lean.$timestamp"
  rm -f ".lean-version-backup/lake-manifest.json.$timestamp"
done
```

---

### 5H: Report Result

```
Lean Upgrade Complete
=====================

Changes Applied:
- Toolchain: {old_toolchain} -> {new_toolchain}
- Mathlib: {old_mathlib} -> {new_mathlib}

Post-upgrade commands:
- lake update: {success/failed}
- lake exe cache get: {success/failed}

Backup saved: .lean-version-backup/{timestamp}

Next: Run /lake to verify the build passes.
```

**STOP** - execution complete.

---

## Step 6: Rollback Mode

Restore from a previous backup.

### 6A: List Available Backups

```bash
backup_dir=".lean-version-backup"

if [ ! -d "$backup_dir" ] || [ -z "$(ls -A $backup_dir 2>/dev/null)" ]; then
  echo "No backups available."
  echo ""
  echo "Alternative recovery methods:"
  echo "  git checkout lean-toolchain lakefile.lean"
  echo "  lake update"
  echo "  lake exe cache get"
  exit 0
fi

# Get unique timestamps
timestamps=$(ls "$backup_dir"/lean-toolchain.* 2>/dev/null | \
  sed 's|.*/lean-toolchain\.||' | sort -r | head -5)
```

---

### 6B: Prompt for Backup Selection

**EXECUTE NOW**: Use AskUserQuestion to select backup.

Build options array from available timestamps:

```json
{
  "question": "Select backup to restore:",
  "header": "Rollback Selection",
  "multiSelect": false,
  "options": [
    {"label": "{timestamp_1}", "description": "Restore toolchain and lakefile from this backup"},
    {"label": "{timestamp_2}", "description": "Restore toolchain and lakefile from this backup"},
    {"label": "Cancel", "description": "Do not restore, keep current versions"}
  ]
}
```

**If user selects "Cancel"**:
```
Rollback cancelled.
No changes made.
```
**STOP** - execution complete.

---

### 6C: Restore Backup

**EXECUTE NOW**: Copy backup files to project root.

```bash
selected_timestamp="$user_selection"  # From AskUserQuestion

# Restore files
cp ".lean-version-backup/lean-toolchain.$selected_timestamp" lean-toolchain
cp ".lean-version-backup/lakefile.lean.$selected_timestamp" lakefile.lean
if [ -f ".lean-version-backup/lake-manifest.json.$selected_timestamp" ]; then
  cp ".lean-version-backup/lake-manifest.json.$selected_timestamp" lake-manifest.json
fi
```

---

### 6D: Run Post-Rollback Commands

```bash
echo "Running lake update..."
lake update 2>&1

echo "Running lake exe cache get..."
lake exe cache get 2>&1
```

---

### 6E: Report Result

```
Lean Rollback Complete
======================

Restored from backup: {selected_timestamp}

Current Configuration:
- Toolchain: {restored_toolchain}
- Mathlib: {restored_mathlib}

Post-rollback commands executed:
- lake update: {status}
- lake exe cache get: {status}

Next: Run /lake to verify the build passes.
```

**STOP** - execution complete.

---

## Error Handling

### Network Failure

If `lake update` or `lake exe cache get` fails:

```
Warning: Post-upgrade command failed.

{error_output}

Recommendation:
1. Check network connectivity
2. Retry: lake update && lake exe cache get
3. Or rollback: /lean rollback
```

### File Not Found

If `lean-toolchain` or `lakefile.lean` doesn't exist:

```
Error: Required file not found: {filename}

This doesn't appear to be a Lean project directory.
Required files: lean-toolchain, lakefile.lean
```

### Elan Not Available

If `elan` command not found:

```
Warning: elan not found in PATH.

Toolchain management via elan is not available.
You can still use /lean to view and modify version files directly.

To install elan: https://github.com/leanprover/elan
```

### Backup Restore Failed

If backup files are corrupted or missing:

```
Error: Could not restore from backup {timestamp}.

Alternative recovery:
  git checkout lean-toolchain lakefile.lean
  lake update
  lake exe cache get
```

---

## Safety Measures

### Backup Before Changes

- Always create timestamped backup before upgrade
- Backup includes: `lean-toolchain`, `lakefile.lean`, `lake-manifest.json`
- Location: `.lean-version-backup/`
- Retention: Keep 3 most recent

### Dry-Run Support

- `--dry-run` previews all changes without applying
- Shows current vs. target versions
- Lists files that would be modified
- Lists commands that would run

### User Confirmation

- Upgrade mode requires explicit confirmation via AskUserQuestion
- Clear options: "Yes, upgrade" or "No, cancel"
- No changes made until confirmed

### Git Integration

- Project files are tracked in git
- Additional recovery: `git checkout lean-toolchain lakefile.lean`
- Backups are defense-in-depth, not primary recovery

---

## Example Flows

### Check Flow

```bash
$ /lean

Lean Version Status
===================

Current Configuration:
- Toolchain: leanprover/lean4:v4.27.0-rc1
- Mathlib: v4.27.0-rc1

Installed Toolchains:
  leanprover/lean4:v4.27.0-rc1 (active)
  leanprover/lean4:v4.22.0
  leanprover/lean4:v4.14.0

Backups Available:
- 20260226_103045

Tip: Run /lean upgrade to update to the latest version.
```

### Upgrade Flow

```bash
$ /lean upgrade

Creating backup...
Backup created: 20260226_143000

[Upgrade Confirmation]
Proceed with Lean version upgrade?
  1. Yes, upgrade
  2. No, cancel

> 1

Updating lean-toolchain...
Updating lakefile.lean...
Running lake update...
Running lake exe cache get...

Lean Upgrade Complete
=====================

Changes Applied:
- Toolchain: leanprover/lean4:v4.27.0-rc1 -> leanprover/lean4:v4.28.0
- Mathlib: v4.27.0-rc1 -> v4.28.0

Post-upgrade commands:
- lake update: success
- lake exe cache get: success

Backup saved: .lean-version-backup/20260226_143000

Next: Run /lake to verify the build passes.
```

### Rollback Flow

```bash
$ /lean rollback

[Rollback Selection]
Select backup to restore:
  1. 20260226_143000
  2. 20260225_091500
  3. Cancel

> 1

Restoring from backup 20260226_143000...
Running lake update...
Running lake exe cache get...

Lean Rollback Complete
======================

Restored from backup: 20260226_143000

Current Configuration:
- Toolchain: leanprover/lean4:v4.27.0-rc1
- Mathlib: v4.27.0-rc1

Next: Run /lake to verify the build passes.
```

### Dry-Run Flow

```bash
$ /lean --dry-run upgrade

Lean Upgrade Preview (Dry Run)
==============================

Current Configuration:
- Toolchain: leanprover/lean4:v4.27.0-rc1
- Mathlib: v4.27.0-rc1

Target Configuration:
- Toolchain: leanprover/lean4:v4.28.0 (latest)
- Mathlib: v4.28.0

Files that would be modified:
- lean-toolchain
- lakefile.lean

Commands that would run:
- lake update
- lake exe cache get

Backup would be created in: .lean-version-backup/

No changes made (dry run mode).
```
