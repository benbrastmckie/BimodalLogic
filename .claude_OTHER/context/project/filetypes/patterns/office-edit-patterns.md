# Office Document Editing Patterns

Workflow patterns for in-place editing of Office documents (DOCX, XLSX) while the partner has them open in Microsoft Office applications.

## 5-Step Word Integration Workflow

The core workflow for editing a DOCX file that may be open in Word:

```
Step 1: CHECK   -- Is Word running? Does it have the file open?
Step 2: SAVE    -- If open, save partner's unsaved work via AppleScript
Step 3: EDIT    -- Perform SuperDoc operations on the file
Step 4: RELOAD  -- If Word had file open, trigger document reload
Step 5: CONFIRM -- Verify edit results (file modified, changes applied)
```

### Step 1: Check Word State (macOS)

```bash
# Check if Microsoft Word is running
word_running=$(osascript -e 'tell application "System Events" to (name of processes) contains "Microsoft Word"' 2>/dev/null)

# Check if specific file is open in Word (if Word is running)
if [ "$word_running" = "true" ]; then
  file_open=$(osascript -e "
    tell application \"Microsoft Word\"
      set docNames to name of every document
      return docNames contains \"$(basename "$file_path")\"
    end tell
  " 2>/dev/null)
fi
```

### Step 2: Save Partner's Unsaved Work (macOS)

```bash
# Save the active document to preserve partner's unsaved edits
osascript -e 'tell application "Microsoft Word" to save active document'
```

This ensures any unsaved partner edits are written to disk before SuperDoc modifies the file. Without this step, SuperDoc's changes would overwrite the partner's in-memory edits when they next save.

### Step 3: Perform SuperDoc Operations

Use the SuperDoc MCP tools to edit the document:

```
doc_id = open_document(file_path)
# ... editing operations ...
save_document(doc_id)
close_document(doc_id)
```

See `superdoc-integration.md` for the complete tool inventory.

### Step 4: Reload Document in Word (macOS)

```bash
# Reload the document from disk without closing the window
osascript -e 'tell application "Microsoft Word" to reload active document'
```

**Behavior notes**:
- Discards the in-memory version, reloads from disk
- Keeps the Word window open (no close/reopen cycle)
- Clears undo history (cannot undo back to pre-reload state)
- Asynchronous -- Word may take a moment to fully refresh
- Only works on previously saved documents

### Step 5: Confirm Results

After editing, verify:
1. File modification time changed
2. File size is non-zero
3. Expected changes are present (read back and check)

## AppleScript Command Reference

| Action | Command |
|--------|---------|
| Check Word running | `osascript -e 'tell application "System Events" to (name of processes) contains "Microsoft Word"'` |
| Save active document | `osascript -e 'tell application "Microsoft Word" to save active document'` |
| Reload active document | `osascript -e 'tell application "Microsoft Word" to reload active document'` |
| List open documents | `osascript -e 'tell application "Microsoft Word" to name of every document'` |
| Get active document path | `osascript -e 'tell application "Microsoft Word" to full name of active document'` |

## macOS File Locking Behavior

Word on macOS uses two locking mechanisms, neither of which blocks SuperDoc:

| Layer | Mechanism | Blocks SuperDoc? |
|-------|-----------|-----------------|
| Owner file (`~$filename.docx`) | Word-internal cooperative lock | No -- only other Word instances check it |
| OS-level `flock()`/`fcntl()` | POSIX advisory lock | No -- advisory locks are ignorable |

macOS/APFS does not support mandatory file locks. SuperDoc can freely read and write .docx files that Word has open.

**Key insight**: Word does not watch the file for external modifications. It works from an in-memory copy and will silently overwrite external changes on its next save. This is why Step 2 (save partner work) and Step 4 (reload) are essential.

## Tracked Changes Workflow

When editing with tracked changes:

1. **Ask the user** about tracked changes preference on first invocation:
   - "Should changes be tracked (visible as revisions in Word)?"
   - "What author name should appear for tracked changes?" (default: "Claude")

2. **Use `search_and_replace_with_tracked_changes`** instead of `search_and_replace`

3. **Author attribution**: The author name appears in Word's revision sidebar, allowing the partner to review and accept/reject each change individually.

## OneDrive/SharePoint Sync Pause Pattern

When editing files in a OneDrive/SharePoint-synced folder:

```bash
# Check if OneDrive is syncing (macOS)
onedrive_running=$(osascript -e 'tell application "System Events" to (name of processes) contains "OneDrive"' 2>/dev/null)

# If syncing, warn user about potential conflicts
if [ "$onedrive_running" = "true" ]; then
  echo "Warning: OneDrive sync detected. Edits may trigger sync conflicts."
  echo "Consider pausing OneDrive sync during batch operations."
fi
```

For batch edits (multiple files), recommend pausing OneDrive sync to avoid partial-upload conflicts. Individual file edits are typically safe -- the edit-save cycle completes in 2-5 seconds.

## Edge Cases

### Multiple Documents Open

When Word has multiple documents open, the AppleScript commands target the active (frontmost) document. To target a specific document:

```bash
osascript -e "
  tell application \"Microsoft Word\"
    set targetDoc to first document whose name is \"$filename\"
    save targetDoc
  end tell
"
```

### Word Not Running

If Word is not running, skip Steps 1, 2, and 4. SuperDoc can edit the file directly without any AppleScript interaction.

### Read-Only Mode

If the file is opened in Word as read-only, the save command in Step 2 may fail. The agent should catch this error and proceed anyway -- the partner has no unsaved changes to lose if the file is read-only.

### Non-macOS Platforms

On Linux or Windows, AppleScript is not available. The agent should:
1. Skip Steps 1, 2, and 4 entirely
2. Warn the user: "Please save and close the document in Word before editing, then reopen it after editing is complete."
3. Proceed with SuperDoc editing normally

### File Not Found

If the file path does not exist and `--new` flag is not set, return a failed status immediately. Do not attempt to create the file unless explicitly requested.

## Batch Editing Pattern

When editing multiple files in a directory:

```
1. Glob all .docx files in the directory
2. For each file:
   a. Apply the 5-step workflow
   b. Record per-file results (success/failure, change count)
3. Aggregate results into summary
```

Report format for batch operations:
```
Batch edit complete: 12/15 files modified
  - contract_v1.docx: 3 replacements
  - contract_v2.docx: 3 replacements
  - proposal.docx: 0 replacements (no matches)
  - template.docx: FAILED (file locked)
  ...
```

## Document Creation Pattern

When creating a new document (--new flag or file does not exist):

```
1. create_document(path)
2. add_heading(doc_id, title, 1)
3. For each content section:
   - add_heading(doc_id, section_title, 2)
   - add_paragraph(doc_id, section_content)
4. If tables requested:
   - add_table(doc_id, rows, cols, data)
5. save_document(doc_id)
6. close_document(doc_id)
```

Skip the Word integration steps (1, 2, 4) since the file is new and cannot be open in Word.
