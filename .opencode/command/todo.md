---
name: todo
agent: orchestrator
description: "Maintain project documentation: review TODO.md, clean up completed tasks, archive projects, update status documents"
---

You are maintaining project documentation for the LEAN 4 ProofChecker project.

**Request:** $ARGUMENTS

**Context Loaded:**
@/home/benjamin/Projects/ProofChecker/.opencode/specs/TODO.md
@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/standards/
@/home/benjamin/Projects/ProofChecker/.opencode/context/core/system/project-overview.md

**Task:**

Execute the TODO maintenance workflow:

1. Route to @subagents/reviewer with todo-maintenance scope
2. Reviewer will:
   - Review TODO.md for completed tasks
   - Clean up completed tasks from TODO.md (with user confirmation if >5 tasks)
   - Archive completed project directories from .opencode/specs/ to .opencode/specs/archive/
   - Update status documents:
     * Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md (high-level implementation progress)
     * Documentation/ProjectInfo/SORRY_REGISTRY.md (registry of sorry/unproven theorems)
     * Documentation/ProjectInfo/TACTIC_REGISTRY.md (tactic development progress - renamed from TACTIC_DEVELOPMENT.md)
   - Check for recent progress on tasks/proofs/tactics
   - Maintain separation: TODO.md (detailed tasks) vs status docs (high-level overview)
3. Present results with artifact references and summary of changes

**File Structure:**
- Working TODO: .opencode/specs/TODO.md
- Project specs: .opencode/specs/{project-name}/
- Archive: .opencode/specs/archive/{project-name}/
- Status docs: Documentation/ProjectInfo/

**Expected Output:**

- **Cleanup Summary:**
  * Number of completed tasks removed from TODO.md
  * List of removed task descriptions
  * Number of project directories moved to archive
  * List of archived project directories (with paths)
  * Any warnings or errors encountered during cleanup
- **Status Document Updates:**
  * IMPLEMENTATION_STATUS.md changes
  * SORRY_REGISTRY.md changes
  * TACTIC_REGISTRY.md changes (including rename if needed)
- **Maintenance Summary:**
  * Summary of all cleanup actions performed
  * Current project health snapshot
  * Recommendations for next steps

**Maintenance Operations:**

1. **Cleanup Completed Tasks**
   - Scan TODO.md for completed tasks (marked with ✅, [x], or in "Recently Completed"/"Completed" sections)
   - Identify all completed task entries
   - If >5 completed tasks found, confirm with user before removal
   - Remove completed task entries from TODO.md
   - Preserve all pending/in-progress tasks
   - Maintain TODO.md structure and formatting

2. **Archive Project Directories**
   - For each completed task, identify corresponding project directory in .opencode/specs/
   - Match completed tasks to directories using intelligent matching:
     * Task numbers (e.g., "Project #123" → "123_project_name/")
     * Project names (e.g., "Fix soundness proof" → "soundness_fix/")
     * Directory naming patterns
   - Create .opencode/specs/archive/ directory if it doesn't exist
   - Move completed project directories from .opencode/specs/{project}/ to .opencode/specs/archive/{project}/
   - Preserve all directory structure and files within archived projects
   - Handle errors gracefully:
     * Continue if .opencode/specs/ doesn't exist (skip archiving)
     * Continue if completed task has no matching directory
     * Continue with other directories if one move fails
     * Collect and report all errors at the end

3. **Update Status Documents**
   - IMPLEMENTATION_STATUS.md: Module-by-module completion tracking (user-facing, high-level)
   - SORRY_REGISTRY.md: Registry of sorry/unproven theorems (user-facing, high-level)
   - TACTIC_REGISTRY.md: Tactic development progress (rename from TACTIC_DEVELOPMENT.md if needed)

4. **Synchronize State**
   - Ensure status documents reflect actual project state
   - Check for recent proof completions
   - Check for tactic developments
   - Update completion percentages
   - Update state.json with archived project references

**Safety and Error Handling:**

1. **User Confirmation:**
   - If >5 completed tasks are found, list them and ask user to confirm removal
   - Proceed with cleanup only after confirmation
   - If ≤5 tasks, proceed automatically

2. **Graceful Degradation:**
   - If .opencode/specs/ directory doesn't exist, skip archiving and continue with other operations
   - If a completed task has no matching directory, note it in warnings and continue
   - If a directory move fails, log the error and continue with remaining directories
   - Don't fail the entire operation if one step fails

3. **Error Reporting:**
   - Collect all errors and warnings during execution
   - Report them in a dedicated section of the output
   - Include specific error messages and affected items
   - Provide recommendations for manual intervention if needed

4. **Data Preservation:**
   - Never delete files, only move them to archive
   - Preserve all directory structure and contents
   - Keep backup references in state.json
   - Ensure TODO.md changes are atomic (all or nothing)

Execute the TODO maintenance now.
