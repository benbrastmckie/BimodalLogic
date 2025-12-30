# Research Report: Improve /todo Command to Use Git Commits Instead of Backups and Fix Divider Stacking

**Task Number**: 253  
**Research Date**: 2025-12-29  
**Researcher**: AI Assistant  
**Status**: Complete

---

## Executive Summary

This research analyzes the current /todo command implementation to identify opportunities for improvement by replacing the backup-based workflow with git commits and fixing divider stacking issues in TODO.md. The research reveals that:

1. **Current backup approach is fragile**: The /todo command creates `.bak` files for rollback, which can be lost or corrupted
2. **Git provides superior version control**: Git commits offer atomic operations, full history, and reliable rollback
3. **Divider stacking is widespread**: 20+ instances of stacked `---` dividers with empty lines between them
4. **Existing Python script provides foundation**: `.opencode/tmp/archive_tasks.py` demonstrates proper TODO.md parsing and can be adapted

**Recommended Approach**: Create dedicated Python script at `.opencode/scripts/todo_cleanup.py` that implements proper divider handling, integrate git commits (pre-cleanup and post-cleanup), and remove backup file logic from /todo command.

---

## 1. Current /todo Command Analysis

### 1.1 Command Overview

**Location**: `.opencode/command/todo.md`  
**Purpose**: Archive completed and abandoned tasks from TODO.md  
**Current Workflow**: 7-stage process with backup-based rollback

### 1.2 Current Backup Mechanism

The /todo command uses a two-phase commit with file backups:

**Phase 1 (Prepare)**:
```
1. Backup current state:
   - Backup .opencode/specs/TODO.md → .opencode/specs/TODO.md.bak
   - Backup state.json → state.json.bak
   - Backup archive/state.json → archive/state.json.bak
   - No directory backup (rely on git, expensive operation)
2. Validate all updates are well-formed
3. Validate all target paths are writable
```

**Phase 2 (Commit)**:
```
1. Write updated .opencode/specs/TODO.md
2. Write updated state.json
3. Write updated archive/state.json
4. Move project directories
5. On success: Delete backup files
6. On failure: Execute rollback_archival()
```

**Rollback Mechanism**:
```python
rollback_archival():
  1. Restore files from backups:
     - Copy .opencode/specs/TODO.md.bak → .opencode/specs/TODO.md
     - Copy state.json.bak → state.json
     - Copy archive/state.json.bak → archive/state.json
  2. Reverse directory moves
  3. Cleanup backup files
  4. Log rollback to errors.json
```

### 1.3 Current Task Block Removal Logic

The command specification defines task block structure and boundaries:

**Task Block Structure**:
```
A complete task block consists of:
1. Heading line: Matches pattern `^### \d+\. ` (e.g., "### 192. Fix bug...")
2. Body lines: All lines following the heading until the next boundary marker
```

**Boundary Patterns** (in precedence order):
1. Next task heading: `^### \d+\. `
2. Section heading: `^## `
3. Horizontal rule: `^---$`
4. End of file (EOF)

**Critical Issue**: The command specification describes the logic but does NOT implement it. The actual implementation is delegated to Claude at runtime, which generates Python code from scratch each time. This leads to:
- Inconsistent implementations
- No reusable code
- Potential for bugs in each execution
- No version control of the cleanup logic

### 1.4 Current Git Integration

The command includes Stage 6 (GitCommit) that creates a single commit AFTER archival:

```
Stage 6: GitCommit
1. Stage files:
   - git add .opencode/specs/TODO.md
   - git add .opencode/specs/state.json
   - git add .opencode/specs/archive/state.json
   - git add .opencode/specs/archive/  (pick up moved directories)
2. Verify staged changes: git status --short
3. Create commit:
   - Message format: "todo: archive {N} completed/abandoned tasks"
4. If commit fails: Log error, continue (commit failure non-critical)
```

**Limitation**: Only ONE commit after cleanup. No pre-cleanup snapshot for easy rollback.

---

## 2. TODO.md File Standards and Divider Rules

### 2.1 File Structure

**Location**: `.opencode/specs/TODO.md`  
**Format**: Markdown with structured metadata

**Standard Structure**:
```markdown
# TODO

**Last Updated:** 2025-12-29T17:36:00Z

## Overview
- **Total Tasks:** 59
- **Completed:** 8
...

---

## High Priority

### 253. Task Title
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Priority**: High
...

---

### 251. Next Task Title
...
```

### 2.2 Divider Placement Rules

Based on analysis of TODO.md structure and existing patterns:

**CORRECT Divider Placement**:
1. **One divider between sections**: `## Overview` → `---` → `## High Priority`
2. **One divider between tasks**: `### 253. Task` → `---` → `### 251. Task`
3. **NO divider between headers**: `## High Priority` → `### 253. Task` (NO divider)
4. **NO divider after last task**: `### 1. Last Task` → (EOF, NO divider)

**INCORRECT Patterns Found** (20+ instances):
```markdown
### 253. Task Title
...

---

---

### 251. Next Task Title
```

This creates stacked dividers with empty lines between them, which is a formatting violation.

### 2.3 Divider Stacking Analysis

**Detection Method**:
```bash
awk '/^---$/{if(prev=="---" || prev=="") print NR": STACKED"; prev="---"; next} {prev=$0}' TODO.md
```

**Results**: 20+ stacked dividers found at lines:
- 13, 54, 176, 197, 215, 234, 250, 266, 281, 283, 309, 335, 337, 355, 373, 391, 427, 445, 483, 502

**Example** (lines 280-285):
```markdown
---

---

### 8. Refactor `Logos/Core/Syntax/Context.lean`
```

**Root Cause**: Task removal leaves behind orphaned dividers. When a task is removed, its divider remains, creating stacked dividers.

### 2.4 Metadata Field Standards

**Required Fields** (from state-management.md):
- `**Status**`: Status marker (e.g., `[NOT STARTED]`, `[COMPLETED]`)
- `**Priority**`: High, Medium, Low
- `**Effort****: Estimated hours
- `**Language**`: Implementation language

**Optional Fields**:
- `**Started**`: YYYY-MM-DD
- `**Completed**`: YYYY-MM-DD
- `**Researched**`: YYYY-MM-DD
- `**Planned**`: YYYY-MM-DD
- `**Blocked**`: YYYY-MM-DD
- `**Abandoned**`: YYYY-MM-DD
- `**Dependencies**`: Task numbers
- `**Blocking**`: Task numbers

**Timestamp Format**: YYYY-MM-DD (date only, no time component)

---

## 3. Git Commit Integration Design

### 3.1 Git Workflow Benefits

**Advantages over Backup Files**:
1. **Atomic operations**: Git commits are atomic at the repository level
2. **Full history**: Complete audit trail of all changes
3. **Easy rollback**: `git reset --hard <commit>` for instant recovery
4. **Diff visibility**: `git diff` shows exactly what changed
5. **No orphaned backups**: No `.bak` files to manage or clean up
6. **Branch safety**: Can work on feature branches for testing

**Alignment with Standards**:
- Follows `.opencode/context/common/system/git-commits.md` standard
- Uses targeted, scoped commits (not `git add -A`)
- Includes task references in commit messages

### 3.2 Commit Message Templates

**Pre-Cleanup Commit**:
```
todo: snapshot before archiving {N} tasks (task 253)

Preparing to archive {completed_count} completed and {abandoned_count} abandoned tasks.
This commit creates a snapshot for easy rollback if cleanup fails.

Tasks to archive: {task_numbers}
```

**Post-Cleanup Commit**:
```
todo: archive {N} completed/abandoned tasks (task 253)

Archived {completed_count} completed and {abandoned_count} abandoned tasks.
Moved {dir_count} project directories to archive.

Tasks archived: {task_numbers}
```

**Example**:
```
todo: snapshot before archiving 5 tasks (task 253)

Preparing to archive 4 completed and 1 abandoned tasks.
This commit creates a snapshot for easy rollback if cleanup fails.

Tasks to archive: 236, 237, 238, 241, 242
```

### 3.3 Files to Commit

**Pre-Cleanup Commit** (snapshot current state):
```bash
git add .opencode/specs/TODO.md
git add .opencode/specs/state.json
git add .opencode/specs/archive/state.json
git commit -m "todo: snapshot before archiving {N} tasks (task 253)"
```

**Post-Cleanup Commit** (record changes):
```bash
git add .opencode/specs/TODO.md
git add .opencode/specs/state.json
git add .opencode/specs/archive/state.json
git add .opencode/specs/archive/  # Pick up moved directories
git commit -m "todo: archive {N} completed/abandoned tasks (task 253)"
```

### 3.4 Rollback Scenarios

**Scenario 1: Cleanup Script Fails**
```bash
# Rollback to pre-cleanup state
git reset --hard HEAD~1  # Undo post-cleanup commit (if created)
git reset --hard HEAD~1  # Undo pre-cleanup commit
```

**Scenario 2: User Wants to Undo Archival**
```bash
# View what was archived
git show HEAD

# Rollback archival
git revert HEAD  # Creates new commit undoing archival
```

**Scenario 3: Dirty Working Tree**
```
If working tree has uncommitted changes:
1. Stash changes: git stash
2. Run /todo command
3. Restore changes: git stash pop
```

### 3.5 Edge Cases

**Case 1: Merge Conflicts**
- Detection: Check `git status` before starting
- Resolution: Abort if merge in progress, ask user to resolve first

**Case 2: Detached HEAD**
- Detection: Check `git symbolic-ref -q HEAD`
- Resolution: Abort if detached, ask user to checkout branch

**Case 3: No Git Repository**
- Detection: Check `.git` directory exists
- Resolution: Abort with error, /todo requires git repository

**Case 4: Uncommitted Changes**
- Detection: Check `git status --porcelain`
- Resolution: Warn user, offer to stash or abort

---

## 4. Dedicated Python Script Design

### 4.1 Script Architecture

**Location**: `.opencode/scripts/todo_cleanup.py`  
**Purpose**: Reusable script for TODO.md cleanup with proper divider handling  
**Language**: Python 3.8+

**Design Principles**:
1. **Reusable**: No hardcoded task lists, accepts arguments
2. **Testable**: Pure functions, unit testable
3. **Aligned with standards**: Follows TODO.md format rules
4. **Robust**: Comprehensive error handling and validation
5. **Idempotent**: Can be run multiple times safely

### 4.2 Script Interface

**Command-Line Arguments**:
```bash
python3 .opencode/scripts/todo_cleanup.py [OPTIONS]

Options:
  --dry-run              Show what would be changed without modifying files
  --verbose              Print detailed progress information
  --validate-only        Validate TODO.md format without making changes
  --fix-dividers         Fix divider stacking issues only (no archival)
  --help                 Show help message

Exit Codes:
  0  Success
  1  Validation error (orphaned metadata, invalid format)
  2  File I/O error
  3  Invalid arguments
```

**Example Usage**:
```bash
# Dry run to preview changes
python3 .opencode/scripts/todo_cleanup.py --dry-run --verbose

# Fix dividers only
python3 .opencode/scripts/todo_cleanup.py --fix-dividers

# Validate TODO.md format
python3 .opencode/scripts/todo_cleanup.py --validate-only

# Archive completed/abandoned tasks
python3 .opencode/scripts/todo_cleanup.py
```

### 4.3 Core Functions

**Function 1: Parse TODO.md**
```python
def parse_todo_file(todo_path: Path) -> TodoDocument:
    """
    Parse TODO.md into structured representation.
    
    Returns:
        TodoDocument with sections, tasks, dividers
    """
    # Read file
    # Parse sections (## headers)
    # Parse tasks (### headers with metadata)
    # Track divider locations
    # Return structured document
```

**Function 2: Extract Task Block**
```python
def extract_task_block(content: str, task_number: int) -> Tuple[int, int, str]:
    """
    Extract complete task block (heading + body).
    
    Args:
        content: Full TODO.md content
        task_number: Task number to extract
        
    Returns:
        (start_line, end_line, task_content)
        
    Raises:
        ValueError: Task not found
    """
    # Find heading: ^### {task_number}\.
    # Scan for boundary: next task, section, divider, or EOF
    # Return line range and content
```

**Function 3: Fix Divider Stacking**
```python
def fix_divider_stacking(content: str) -> str:
    """
    Remove stacked dividers, ensure proper placement.
    
    Rules:
    - One divider between sections
    - One divider between tasks
    - No divider between headers
    - No divider after last task
    
    Returns:
        Cleaned content with proper dividers
    """
    # Parse into lines
    # Track context (section, task, divider)
    # Remove stacked dividers
    # Ensure proper placement
    # Return cleaned content
```

**Function 4: Validate TODO.md**
```python
def validate_todo_format(content: str) -> List[ValidationError]:
    """
    Validate TODO.md format and detect issues.
    
    Checks:
    - No orphaned metadata lines
    - Proper divider placement
    - Valid status markers
    - Required metadata fields present
    
    Returns:
        List of validation errors (empty if valid)
    """
    # Check for orphaned metadata
    # Check divider placement
    # Validate status markers
    # Validate metadata fields
    # Return errors
```

**Function 5: Archive Tasks**
```python
def archive_tasks(
    todo_path: Path,
    state_path: Path,
    archive_state_path: Path,
    specs_dir: Path
) -> ArchivalResult:
    """
    Archive completed and abandoned tasks.
    
    Process:
    1. Identify tasks to archive (COMPLETED, ABANDONED)
    2. Extract task blocks
    3. Update TODO.md (remove blocks)
    4. Fix dividers
    5. Update state.json
    6. Update archive/state.json
    7. Move project directories
    
    Returns:
        ArchivalResult with counts, moved directories, errors
    """
    # Identify tasks to archive
    # Extract and parse task blocks
    # Remove from TODO.md
    # Fix dividers
    # Update state files
    # Move directories
    # Return result
```

### 4.4 Divider Handling Algorithm

**Algorithm**: Context-Aware Divider Placement

```python
def fix_divider_stacking(lines: List[str]) -> List[str]:
    """
    Fix divider stacking using context-aware algorithm.
    """
    result = []
    prev_type = None  # 'section', 'task', 'divider', 'content', 'empty'
    
    for i, line in enumerate(lines):
        line_type = classify_line(line)
        
        # Rule 1: Skip stacked dividers
        if line_type == 'divider' and prev_type == 'divider':
            continue  # Skip this divider
        
        # Rule 2: Skip divider after section header
        if line_type == 'divider' and prev_type == 'section':
            continue  # No divider after section header
        
        # Rule 3: Ensure divider before section (if not first section)
        if line_type == 'section' and prev_type not in ['divider', None]:
            result.append('---')  # Add divider before section
        
        # Rule 4: Ensure divider before task (if not first task in section)
        if line_type == 'task' and prev_type == 'content':
            result.append('---')  # Add divider before task
        
        # Rule 5: Skip divider before EOF
        if line_type == 'divider' and i == len(lines) - 1:
            continue  # No divider at EOF
        
        # Add line
        result.append(line)
        
        # Update context (skip empty lines for context)
        if line_type != 'empty':
            prev_type = line_type
    
    return result

def classify_line(line: str) -> str:
    """Classify line type for divider algorithm."""
    if re.match(r'^## ', line):
        return 'section'
    elif re.match(r'^### \d+\.', line):
        return 'task'
    elif re.match(r'^---$', line):
        return 'divider'
    elif line.strip() == '':
        return 'empty'
    else:
        return 'content'
```

**Test Cases**:

```python
# Test 1: Remove stacked dividers
input = """
### 253. Task A
...
---

---
### 251. Task B
"""
expected = """
### 253. Task A
...
---
### 251. Task B
"""

# Test 2: No divider after section header
input = """
## High Priority
---
### 253. Task A
"""
expected = """
## High Priority
### 253. Task A
"""

# Test 3: Add divider between tasks
input = """
### 253. Task A
...
### 251. Task B
"""
expected = """
### 253. Task A
...
---
### 251. Task B
"""

# Test 4: No divider at EOF
input = """
### 1. Last Task
...
---
"""
expected = """
### 1. Last Task
...
"""
```

### 4.5 Error Handling

**Error Categories**:

1. **Validation Errors** (Exit Code 1):
   - Orphaned metadata lines
   - Invalid status markers
   - Missing required fields
   - Malformed task headers

2. **File I/O Errors** (Exit Code 2):
   - Cannot read TODO.md
   - Cannot write TODO.md
   - Cannot read/write state.json
   - Cannot move directories

3. **Argument Errors** (Exit Code 3):
   - Invalid command-line arguments
   - Conflicting options

**Error Reporting**:
```python
class ValidationError:
    line_number: int
    error_type: str
    message: str
    suggestion: str

def report_errors(errors: List[ValidationError]) -> None:
    """Print validation errors in user-friendly format."""
    print(f"[FAIL] Validation failed with {len(errors)} errors:\n")
    for error in errors:
        print(f"  Line {error.line_number}: {error.error_type}")
        print(f"    {error.message}")
        print(f"    Suggestion: {error.suggestion}\n")
```

---

## 5. Implementation Strategy

### 5.1 /todo Command Integration

**Updated Workflow**:

```
Stage 1: ScanTODO (unchanged)
  - Scan TODO.md for COMPLETED/ABANDONED tasks
  - Count tasks to archive
  - Prepare removal list

Stage 2: ConfirmArchival (unchanged)
  - Confirm with user if > 5 tasks
  - Abort if user declines

Stage 3: GitPreCommit (NEW)
  - Check git status (abort if dirty/merge/detached)
  - Create pre-cleanup snapshot commit
  - Message: "todo: snapshot before archiving {N} tasks (task 253)"

Stage 4: RunCleanupScript (NEW, replaces PrepareArchival + PrepareUpdates)
  - Execute: python3 .opencode/scripts/todo_cleanup.py
  - Script handles:
    * Task block extraction
    * TODO.md updates
    * Divider fixing
    * state.json updates
    * archive/state.json updates
    * Directory moves
  - Capture exit code and output
  - On failure: Rollback git commit and abort

Stage 5: GitPostCommit (replaces GitCommit)
  - Create post-cleanup commit
  - Message: "todo: archive {N} completed/abandoned tasks (task 253)"
  - On failure: Log error but continue (archival already complete)

Stage 6: ReturnSuccess (unchanged)
  - Return comprehensive archival summary
```

**Removed Stages**:
- Stage 3: PrepareArchival (moved to script)
- Stage 4: PrepareUpdates (moved to script)
- Stage 5: AtomicUpdate (moved to script)

**Benefits**:
- Simpler command specification (3 stages removed)
- Reusable cleanup logic (no regeneration)
- Git-based rollback (no backup files)
- Proper divider handling (built into script)

### 5.2 Command Changes Required

**File**: `.opencode/command/todo.md`

**Changes**:

1. **Remove backup logic** from Stage 5 (AtomicUpdate):
   ```diff
   - **Phase 1 (Prepare)**:
   - 1. Backup current state:
   -    - Backup .opencode/specs/TODO.md → .opencode/specs/TODO.md.bak
   -    - Backup state.json → state.json.bak
   -    - Backup archive/state.json → archive/state.json.bak
   ```

2. **Add Stage 3: GitPreCommit**:
   ```xml
   <stage id="3" name="GitPreCommit">
     <action>Create pre-cleanup git snapshot</action>
     <process>
       1. Check git status:
          - Abort if dirty working tree (uncommitted changes)
          - Abort if merge in progress
          - Abort if detached HEAD
       2. Stage files:
          - git add .opencode/specs/TODO.md
          - git add .opencode/specs/state.json
          - git add .opencode/specs/archive/state.json
       3. Create commit:
          - Message: "todo: snapshot before archiving {N} tasks (task 253)"
       4. If commit fails: Abort archival
     </process>
   </stage>
   ```

3. **Replace Stages 3-5 with Stage 4: RunCleanupScript**:
   ```xml
   <stage id="4" name="RunCleanupScript">
     <action>Execute dedicated cleanup script</action>
     <process>
       1. Execute script:
          - Command: python3 .opencode/scripts/todo_cleanup.py
          - Capture stdout, stderr, exit code
       2. Check exit code:
          - 0: Success, proceed to GitPostCommit
          - 1: Validation error, rollback git commit, abort
          - 2: File I/O error, rollback git commit, abort
          - 3: Argument error, rollback git commit, abort
       3. On failure:
          - Rollback: git reset --hard HEAD~1
          - Return error with script output
     </process>
   </stage>
   ```

4. **Update Stage 6 (GitCommit) to Stage 5 (GitPostCommit)**:
   ```xml
   <stage id="5" name="GitPostCommit">
     <action>Commit archival changes</action>
     <process>
       1. Stage files:
          - git add .opencode/specs/TODO.md
          - git add .opencode/specs/state.json
          - git add .opencode/specs/archive/state.json
          - git add .opencode/specs/archive/  (pick up moved directories)
       2. Create commit:
          - Message: "todo: archive {N} completed/abandoned tasks (task 253)"
       3. If commit fails:
          - Log error to errors.json
          - Continue (archival already complete, commit failure non-critical)
     </process>
   </stage>
   ```

### 5.3 Testing Plan

**Test Suite**: `.opencode/specs/253_improve_todo_command/tests/`

**Test 1: Divider Fixing**
```python
def test_fix_divider_stacking():
    """Test divider stacking removal."""
    input_todo = """
## High Priority
---
### 253. Task A
...
---

---
### 251. Task B
"""
    expected = """
## High Priority
### 253. Task A
...
---
### 251. Task B
"""
    result = fix_divider_stacking(input_todo)
    assert result == expected
```

**Test 2: Task Block Extraction**
```python
def test_extract_task_block():
    """Test complete task block extraction."""
    todo_content = """
### 253. Task A
- **Status**: [COMPLETED]
- **Priority**: High

---

### 251. Task B
"""
    start, end, content = extract_task_block(todo_content, 253)
    assert start == 0
    assert end == 4  # Stops at divider
    assert "Task A" in content
    assert "Task B" not in content
```

**Test 3: Orphaned Metadata Detection**
```python
def test_validate_no_orphaned_metadata():
    """Test orphaned metadata detection."""
    invalid_todo = """
## High Priority
- **Status**: [COMPLETED]  # Orphaned, no task header
- **Priority**: High
"""
    errors = validate_todo_format(invalid_todo)
    assert len(errors) == 2
    assert errors[0].error_type == "orphaned_metadata"
```

**Test 4: Git Integration**
```python
def test_git_pre_commit():
    """Test pre-cleanup git commit."""
    # Setup: Create test repo with TODO.md
    # Execute: Run /todo command
    # Verify: Pre-commit created with correct message
    # Verify: Commit includes TODO.md, state.json, archive/state.json
```

**Test 5: Rollback on Failure**
```python
def test_rollback_on_script_failure():
    """Test git rollback when script fails."""
    # Setup: Create test repo, inject script failure
    # Execute: Run /todo command
    # Verify: Pre-commit rolled back
    # Verify: Files unchanged
```

**Test 6: End-to-End Archival**
```python
def test_end_to_end_archival():
    """Test complete archival workflow."""
    # Setup: Create TODO.md with completed tasks
    # Execute: Run /todo command
    # Verify: Tasks removed from TODO.md
    # Verify: Dividers fixed
    # Verify: state.json updated
    # Verify: archive/state.json updated
    # Verify: Directories moved
    # Verify: Two git commits created
```

### 5.4 Edge Cases

**Edge Case 1: No Tasks to Archive**
- Input: TODO.md with only [NOT STARTED] and [IN PROGRESS] tasks
- Expected: Early return, no git commits, message "No tasks to archive"

**Edge Case 2: All Tasks Completed**
- Input: TODO.md with only [COMPLETED] tasks
- Expected: Archive all tasks, empty TODO.md (except headers)

**Edge Case 3: Task with No Project Directory**
- Input: Completed task with no `.opencode/specs/{number}_{slug}/` directory
- Expected: Archive task, log info "No project directory", continue

**Edge Case 4: Dirty Working Tree**
- Input: Uncommitted changes in working tree
- Expected: Abort with error "Uncommitted changes detected. Commit or stash before running /todo"

**Edge Case 5: Merge in Progress**
- Input: Git merge in progress
- Expected: Abort with error "Merge in progress. Resolve merge before running /todo"

**Edge Case 6: Script Validation Failure**
- Input: TODO.md with orphaned metadata
- Expected: Script exits with code 1, git rollback, error message with details

---

## 6. Risk Assessment

### 6.1 Risks

**Risk 1: Git Commit Failures**
- **Probability**: Low
- **Impact**: Medium
- **Mitigation**: Comprehensive git status checks before starting, clear error messages

**Risk 2: Script Bugs**
- **Probability**: Medium (new code)
- **Impact**: High (could corrupt TODO.md)
- **Mitigation**: Extensive testing, dry-run mode, git rollback on failure

**Risk 3: Divider Algorithm Errors**
- **Probability**: Medium
- **Impact**: Low (cosmetic issue)
- **Mitigation**: Comprehensive test suite, validation mode

**Risk 4: Breaking Existing Workflows**
- **Probability**: Low
- **Impact**: High
- **Mitigation**: Maintain backward compatibility, test with existing TODO.md

**Risk 5: Performance Degradation**
- **Probability**: Low
- **Impact**: Low
- **Mitigation**: Python script is fast, git operations are efficient

### 6.2 Mitigation Strategies

1. **Comprehensive Testing**: Test suite covering all edge cases
2. **Dry-Run Mode**: Allow users to preview changes before applying
3. **Git Rollback**: Automatic rollback on any failure
4. **Validation Mode**: Separate validation without changes
5. **Incremental Rollout**: Test on small TODO.md files first
6. **Documentation**: Clear error messages and troubleshooting guide

---

## 7. Recommendations

### 7.1 Implementation Priorities

**Priority 1: Create Dedicated Script** (2-3 hours)
- Implement `.opencode/scripts/todo_cleanup.py`
- Include divider fixing algorithm
- Add validation mode
- Add dry-run mode

**Priority 2: Update /todo Command** (1-2 hours)
- Add GitPreCommit stage
- Replace stages 3-5 with RunCleanupScript
- Update GitCommit to GitPostCommit
- Remove backup logic

**Priority 3: Testing** (1-2 hours)
- Create test suite
- Test divider fixing
- Test git integration
- Test edge cases

**Priority 4: Documentation** (0.5-1 hour)
- Update /todo command documentation
- Add script usage guide
- Document divider rules
- Add troubleshooting section

### 7.2 Success Criteria

**Functional Requirements**:
- [PASS] Script correctly parses TODO.md format
- [PASS] Script removes complete task blocks (heading + body)
- [PASS] Script fixes divider stacking (no stacked dividers)
- [PASS] Script updates state.json and archive/state.json
- [PASS] Script moves project directories
- [PASS] /todo command creates pre-cleanup git commit
- [PASS] /todo command creates post-cleanup git commit
- [PASS] /todo command rolls back on script failure
- [PASS] No backup files created

**Quality Requirements**:
- [PASS] Script has comprehensive error handling
- [PASS] Script validates TODO.md format
- [PASS] Script provides clear error messages
- [PASS] Script is reusable (no hardcoded values)
- [PASS] Script has dry-run mode
- [PASS] Script has validation mode

**Testing Requirements**:
- [PASS] Test suite covers all edge cases
- [PASS] All tests pass
- [PASS] Manual testing with real TODO.md successful
- [PASS] Git integration tested

### 7.3 Future Enhancements

**Enhancement 1: Interactive Mode**
- Allow user to select which tasks to archive
- Preview changes before applying
- Confirm each task individually

**Enhancement 2: Undo Command**
- Add `/todo undo` to revert last archival
- Use git revert for safe undo

**Enhancement 3: Divider Linting**
- Add `/todo lint` to check divider placement
- Report violations without fixing

**Enhancement 4: Archive Search**
- Add `/todo search <query>` to search archived tasks
- Search by task number, title, or date

---

## 8. Conclusion

The current /todo command uses a fragile backup-based approach and generates Python code from scratch each time, leading to inconsistent implementations and divider stacking issues. This research recommends:

1. **Create dedicated Python script** at `.opencode/scripts/todo_cleanup.py` with proper TODO.md parsing and divider handling
2. **Replace backup workflow with git commits** (pre-cleanup snapshot + post-cleanup commit)
3. **Implement context-aware divider algorithm** to fix stacking issues
4. **Simplify /todo command** by delegating to reusable script

**Estimated Effort**: 4-6 hours (aligns with task estimate)
- Script implementation: 2-3 hours
- Command integration: 1-2 hours
- Testing: 1-2 hours
- Documentation: 0.5-1 hour

**Impact**: Improves /todo command reliability, provides maintainable cleanup logic, fixes formatting issues, and leverages git for version control.

---

## References

1. `.opencode/command/todo.md` - Current /todo command specification
2. `.opencode/specs/TODO.md` - TODO.md file format and structure
3. `.opencode/specs/state.json` - State file schema
4. `.opencode/tmp/archive_tasks.py` - Existing Python archival script
5. `.opencode/context/common/system/git-commits.md` - Git commit standards
6. `.opencode/context/core/system/state-management.md` - State management standards
