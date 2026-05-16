---
description: Edit Office documents in-place (DOCX with tracked changes, batch edit, create new)
allowed-tools: Skill, Bash(date:*), Bash(od:*), Bash(tr:*), Bash(test:*), Bash(dirname:*), Bash(basename:*), Bash(find:*), Read
argument-hint: FILE_OR_DIR "instruction" [--new]
---

# /edit Command

Edit Office documents in-place by delegating to the docx-edit skill/agent chain. Supports single file editing, batch editing across directories, and new document creation.

## Arguments

- `$1` - File path (.docx) or directory path for batch operations (required)
- `$2` - Natural language instruction describing the desired changes (required)
- `--new` - Flag indicating document creation rather than editing an existing file

## Usage Examples

```bash
# Edit a single DOCX with tracked changes
/edit contract.docx "Replace ACME Corp with NewCo Inc. using tracked changes"

# Edit with explicit path
/edit ~/Documents/proposal.docx "Change the deadline from March to April"

# Batch edit all .docx files in a directory
/edit ~/Documents/Contracts/ "Replace Old Company LLC with New Company LLC in all files"

# Create a new document from scratch
/edit --new memo.docx "Create Q2 Budget Review memo with executive summary, department breakdown table, and recommendations section"

# Future: spreadsheet editing (not yet available)
# /edit budget.xlsx "Change Marketing Q2 from 5000 to 7500"
```

## Supported Operations

| Operation | File Type | Status |
|-----------|----------|--------|
| Edit existing DOCX | .docx | Available |
| Batch edit DOCX directory | directory of .docx | Available |
| Create new DOCX | .docx (--new) | Available |
| Edit existing XLSX | .xlsx | Not yet available |

## Execution

### CHECKPOINT 1: GATE IN

1. **Generate Session ID**
   ```bash
   session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
   ```

2. **Parse Arguments**
   ```bash
   # Detect --new flag
   new_mode=false
   file_path=""
   instruction=""

   for arg in "$@"; do
     if [ "$arg" = "--new" ]; then
       new_mode=true
     elif [ -z "$file_path" ]; then
       file_path="$arg"
     else
       instruction="$arg"
     fi
   done

   # Validate file path provided
   if [ -z "$file_path" ]; then
     echo "Error: File or directory path required"
     echo "Usage: /edit FILE_OR_DIR \"instruction\" [--new]"
     exit 1
   fi

   # Validate instruction provided
   if [ -z "$instruction" ]; then
     echo "Error: Editing instruction required"
     echo "Usage: /edit FILE_OR_DIR \"instruction\" [--new]"
     exit 1
   fi

   # Convert to absolute path if relative
   if [[ "$file_path" != /* ]]; then
     file_path="$(pwd)/$file_path"
   fi
   ```

3. **Validate File/Directory Exists**
   ```bash
   if [ "$new_mode" = "false" ]; then
     if [ ! -e "$file_path" ]; then
       echo "Error: Path not found: $file_path"
       echo "Use --new flag to create a new document"
       exit 1
     fi
   fi
   ```

4. **Detect File Type**
   ```bash
   if [ -d "$file_path" ]; then
     mode="batch"
     file_type="docx"
   elif [ "$new_mode" = "true" ]; then
     mode="create"
     ext="${file_path##*.}"
     file_type="$ext"
   else
     mode="edit"
     ext="${file_path##*.}"
     file_type="$ext"
   fi

   case "$file_type" in
     docx)
       target_skill="skill-docx-edit"
       ;;
     xlsx)
       echo "Error: XLSX editing is not yet available."
       echo "The openpyxl MCP server is declared but skill-sheet-edit has not been implemented."
       echo "You can use the openpyxl MCP tools directly in conversation for spreadsheet editing."
       exit 1
       ;;
     *)
       echo "Error: Unsupported file type: .$file_type"
       echo "Supported: .docx (edit/create), .xlsx (planned)"
       exit 1
       ;;
   esac
   ```

**ABORT** if file does not exist (without --new), instruction is missing, or file type is unsupported.

**On GATE IN success**: Arguments validated. **IMMEDIATELY CONTINUE** to STAGE 2 below.

### STAGE 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Invoke the Skill tool NOW** with:
```
skill: "skill-docx-edit"
args: "file_path={file_path} instruction={instruction} mode={mode} session_id={session_id}"
```

The skill will spawn the docx-edit-agent, which performs the actual editing.

**On DELEGATE success**: Editing attempted. **IMMEDIATELY CONTINUE** to CHECKPOINT 2 below.

### CHECKPOINT 2: GATE OUT

1. **Validate Return**
   Required fields: status, summary, artifacts

2. **Verify File Modified** (edit mode)
   ```bash
   if [ "$mode" = "edit" ] && [ -f "$file_path" ]; then
     if [ ! -s "$file_path" ]; then
       echo "Warning: File appears empty after editing"
     fi
   fi
   ```

3. **Verify File Created** (create mode)
   ```bash
   if [ "$mode" = "create" ]; then
     if [ ! -f "$file_path" ]; then
       echo "Warning: New file was not created"
     fi
   fi
   ```

**On GATE OUT success**: Output verified.

### CHECKPOINT 3: COMMIT

Git commit is **optional** for document edits.

Only commit if:
- User explicitly requests it
- Edit is part of a task workflow

```bash
# Only if commit requested
git add "$file_path"
git commit -m "$(cat <<'EOF'
edit: {filename} - {brief_description}

Session: {session_id}

EOF
)"
```

Commit failure is non-blocking (log and continue).

## Output

**Success (edit)**:
```
Edit complete!

File: {file_path}
Changes: {summary from agent}
Tracked: {yes/no}

Status: edited
```

**Success (create)**:
```
Document created!

File: {file_path}
Content: {summary from agent}

Status: created
```

**Success (batch)**:
```
Batch edit complete!

Directory: {dir_path}
Files modified: {count}/{total}
Details:
  - file1.docx: {changes}
  - file2.docx: {changes}

Status: edited
```

**Failed**:
```
Edit failed.

File: {file_path}
Error: {error_message}

Recommendation: {recommendation from error}
```

## Error Handling

### GATE IN Failure

**File not found**:
```
Error: Path not found: {path}

Use --new flag to create a new document:
  /edit --new {path} "instruction"
```

**Unsupported format**:
```
Error: Unsupported file type: .{ext}

Supported formats:
  - .docx: Edit, create, batch edit (available)
  - .xlsx: Spreadsheet editing (planned, not yet available)
```

### DELEGATE Failure

**Tool not available**:
```
Error: No DOCX editing tools available.

Required tools (install one):
  - SuperDoc MCP: Declared in extension manifest (requires Node.js 18+)
  - python-docx: pip install python-docx

Then retry: /edit {file_path} "instruction"
```

### GATE OUT Failure

**File not modified**:
```
Warning: File was not modified.

The instruction may not have matched any content in the document.
Check the instruction and try again with more specific text.
```
