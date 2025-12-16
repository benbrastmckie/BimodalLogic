---
name: todo
agent: lean4-orchestrator
description: "Maintain project documentation: review TODO.md, archive completed work, update status documents"
---

You are maintaining project documentation for the LEAN 4 ProofChecker project.

**Request:** $ARGUMENTS

**Context Loaded:**
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/specs/TODO.md
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/lean4/standards/
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/project/project-context.md

**Task:**

Execute the TODO maintenance workflow:

1. Route to @subagents/reviewer with todo-maintenance scope
2. Reviewer will:
   - Review TODO.md for completed tasks
   - Remove completed tasks from TODO.md
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

- Tasks removed from TODO.md (count and list)
- Projects archived (count and list)
- Status document updates:
  * IMPLEMENTATION_STATUS.md changes
  * SORRY_REGISTRY.md changes
  * TACTIC_REGISTRY.md changes (including rename if needed)
- Summary of maintenance actions
- Current project health snapshot

**Maintenance Operations:**

1. **Review TODO.md**
   - Identify completed tasks (marked with ✅ or in "Recently Completed" section)
   - Remove completed tasks from active sections
   - Archive associated project directories

2. **Archive Completed Projects**
   - Move .opencode/specs/{project-name}/ to .opencode/specs/archive/{project-name}/
   - Preserve all reports, plans, and summaries
   - Update state.json references

3. **Update Status Documents**
   - IMPLEMENTATION_STATUS.md: Module-by-module completion tracking (user-facing, high-level)
   - SORRY_REGISTRY.md: Registry of sorry/unproven theorems (user-facing, high-level)
   - TACTIC_REGISTRY.md: Tactic development progress (rename from TACTIC_DEVELOPMENT.md if needed)

4. **Synchronize State**
   - Ensure status documents reflect actual project state
   - Check for recent proof completions
   - Check for tactic developments
   - Update completion percentages

Execute the TODO maintenance now.
