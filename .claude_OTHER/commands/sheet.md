---
description: Create, edit, or analyze XLSX spreadsheets
allowed-tools: Skill, Bash(date:*), Bash(od:*), Bash(tr:*), Bash(test:*), Bash(dirname:*), Bash(basename:*), Read
argument-hint: FILE_PATH "instruction" [--create|--edit|--analyze]
---

# /sheet Command

Create, edit, or analyze XLSX spreadsheets by delegating to the sheet skill/agent chain.

## Arguments

- `$1` - File path (.xlsx or .xlsm) (required)
- `$2` - Natural language instruction describing the desired operation (required)
- `--create` - Force create mode (default for non-existent files)
- `--edit` - Force edit mode (default for existing files)
- `--analyze` - Analyze spreadsheet without modifying

## Usage Examples

```bash
# Create a new spreadsheet
/sheet budget.xlsx "Create a monthly budget tracker with categories for rent, utilities, food, and transportation. Include SUM formulas for totals."

# Edit an existing spreadsheet
/sheet data.xlsx "Add a new column for Q4 with SUM formulas at the bottom"

# Analyze spreadsheet contents
/sheet report.xlsx "Summarize the data and identify trends" --analyze

# Create with explicit flag
/sheet --create inventory.xlsx "Create an inventory tracking sheet with columns for item, quantity, unit price, and total cost with formulas"

# Edit with explicit flag
/sheet --edit budget.xlsx "Change the Marketing row values for March and April"
```

## Execution

### CHECKPOINT 1: GATE IN

1. **Generate Session ID**
   ```bash
   session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
   ```

2. **Parse Arguments**
   ```bash
   mode=""
   file_path=""
   instruction=""

   for arg in "$@"; do
     case "$arg" in
       --create) mode="create" ;;
       --edit) mode="edit" ;;
       --analyze) mode="analyze" ;;
       *)
         if [ -z "$file_path" ]; then
           file_path="$arg"
         else
           instruction="$arg"
         fi
         ;;
     esac
   done

   # Validate file path provided
   if [ -z "$file_path" ]; then
     echo "Error: File path required"
     echo "Usage: /sheet FILE_PATH \"instruction\" [--create|--edit|--analyze]"
     exit 1
   fi

   # Validate instruction provided
   if [ -z "$instruction" ]; then
     echo "Error: Instruction required"
     echo "Usage: /sheet FILE_PATH \"instruction\" [--create|--edit|--analyze]"
     exit 1
   fi

   # Convert to absolute path if relative
   if [[ "$file_path" != /* ]]; then
     file_path="$(pwd)/$file_path"
   fi
   ```

3. **Validate File Extension**
   ```bash
   ext="${file_path##*.}"
   case "$ext" in
     xlsx|xlsm) ;; # Valid
     *)
       echo "Error: Expected .xlsx or .xlsm extension, got: .$ext"
       echo "Supported: .xlsx, .xlsm"
       exit 1
       ;;
   esac
   ```

4. **Determine Mode** (if not explicitly set)
   ```bash
   if [ -z "$mode" ]; then
     if [ -f "$file_path" ]; then
       mode="edit"
     else
       mode="create"
     fi
   fi

   # Validate file exists for edit/analyze modes
   if [ "$mode" = "edit" ] || [ "$mode" = "analyze" ]; then
     if [ ! -f "$file_path" ]; then
       echo "Error: File not found: $file_path"
       echo "Use --create flag to create a new spreadsheet"
       exit 1
     fi
   fi

   # Validate parent directory exists for create mode
   if [ "$mode" = "create" ]; then
     parent_dir=$(dirname "$file_path")
     if [ ! -d "$parent_dir" ]; then
       echo "Error: Parent directory not found: $parent_dir"
       exit 1
     fi
   fi
   ```

**ABORT** if file extension is unsupported, instruction is missing, or validation fails.

**On GATE IN success**: Arguments validated. **IMMEDIATELY CONTINUE** to STAGE 2 below.

### STAGE 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Invoke the Skill tool NOW** with:
```
skill: "skill-sheet"
args: "file_path={file_path} instruction={instruction} mode={mode} session_id={session_id}"
```

The skill will spawn the sheet-agent to perform the operation.

**On DELEGATE success**: Operation attempted. **IMMEDIATELY CONTINUE** to CHECKPOINT 2 below.

### CHECKPOINT 2: GATE OUT

1. **Validate Return**
   Required fields: status, summary, artifacts

2. **Verify File** (create/edit modes)
   ```bash
   if [ "$mode" = "create" ] || [ "$mode" = "edit" ]; then
     if [ ! -f "$file_path" ]; then
       echo "Warning: File not found after operation"
     elif [ ! -s "$file_path" ]; then
       echo "Warning: File appears empty after operation"
     fi
   fi
   ```

**On GATE OUT success**: Output verified.

### CHECKPOINT 3: COMMIT

Git commit is **optional** for xlsx operations.

Only commit if:
- User explicitly requests it
- Operation is part of a task workflow

```bash
# Only if commit requested
git add "$file_path"
git commit -m "$(cat <<'EOF'
xlsx: {mode} {filename} - {brief_description}

Session: {session_id}

EOF
)"
```

Commit failure is non-blocking (log and continue).

## Output

**Success (create)**:
```
Spreadsheet created!

File: {file_path}
Content: {summary from agent}
Sheets: {count}
Size: {rows} rows x {columns} columns
Formulas: {count}

Status: created
```

**Success (edit)**:
```
Spreadsheet updated!

File: {file_path}
Changes: {summary from agent}

Status: edited
```

**Success (analyze)**:
```
Spreadsheet analysis:

File: {file_path}
{analysis summary from agent}

Status: analyzed
```

**Failed**:
```
XLSX operation failed.

File: {file_path}
Error: {error_message}

Recommendation: {recommendation from error}
```

## Error Handling

### GATE IN Failure

**File not found** (edit/analyze mode):
```
Error: File not found: {path}

Use --create flag to create a new spreadsheet:
  /sheet --create {path} "instruction"
```

**Unsupported extension**:
```
Error: Expected .xlsx or .xlsm extension, got: .{ext}

Supported formats: .xlsx, .xlsm
For spreadsheet-to-table conversion, use: /table {path}
```

### DELEGATE Failure

**Tool not available**:
```
Error: Required tools not available for XLSX operations.

Install with:
  pip install openpyxl pandas

Then retry: /sheet {file_path} "instruction"
```
