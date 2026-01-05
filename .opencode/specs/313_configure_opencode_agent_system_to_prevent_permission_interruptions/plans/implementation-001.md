# Implementation Plan: Configure OpenCode Agent System to Prevent Permission Interruptions

**Task**: 313 - Configure opencode agent system to prevent permission interruptions and ensure greater autonomy by relying on git commits for safety while avoiding other backups  
**Created**: 2026-01-05  
**Status**: [NOT STARTED]  
**Estimated Effort**: 12 hours  
**Complexity**: Medium  
**Language**: meta  
**Priority**: Medium  

---

## Metadata

- **Task Number**: 313
- **Task Type**: feature
- **Language**: meta
- **Dependencies**: None
- **Blocking**: None
- **Research Inputs**: 
  - Research Report: `.opencode/specs/313_configure_opencode_agent_system_to_prevent_permission_interruptions/reports/research-001.md`
  - Research completed: 2026-01-05
  - Research effort: 3 hours

---

## Overview

### Problem Statement

The OpenCode agent system currently has some remaining backup file patterns and potentially restrictive permission configurations that may interrupt agent autonomy. The research reveals that while the system has a sophisticated git-based safety mechanism, the migration from backup files to git commits is incomplete, and agent permission boundaries may be overly conservative.

### Scope

This implementation will:

1. **Complete git safety migration** - Remove all remaining backup file patterns (`.bak`, `/tmp` backups) in favor of git safety commits
2. **Expand agent permissions** - Audit and update agent frontmatter to enable more autonomous operation while maintaining safety boundaries
3. **Remove confirmation prompts** - Replace user confirmation prompts with git safety commits
4. **Standardize git workflow** - Ensure all commands delegate to git-workflow-manager for commits
5. **Document permission configuration** - Create comprehensive guide for configuring agent permissions

### Constraints

- **Must maintain safety boundaries** - Dangerous operations (rm -rf, sudo, etc.) must remain denied
- **Must preserve git safety** - All risky operations must use git safety commits
- **Must not break existing workflows** - Changes should be backward compatible
- **Must follow standards** - All changes must align with git-safety.md and frontmatter-standard.md

### Definition of Done

- [ ] All backup file patterns removed from commands and subagents
- [ ] All commands use git safety commits instead of backup files
- [ ] Agent frontmatter files audited and permissions expanded where safe
- [ ] User confirmation prompts replaced with git safety commits
- [ ] All commands delegate to git-workflow-manager for commits
- [ ] Permission configuration guide created
- [ ] All changes tested and validated
- [ ] Git commit created with descriptive message

### Research Integration

This plan integrates findings from 1 research report created for this task:

**Integrated Reports**:
- **research-001.md** (2026-01-05): Comprehensive analysis of OpenCode permission system, git safety architecture, and autonomy enhancement opportunities
  - Key Finding: System already has robust git-based safety mechanism via git-workflow-manager
  - Key Finding: Some commands still use temporary backup files in /tmp for atomic operations
  - Key Finding: Permission system is declarative (allow/deny lists in frontmatter), no interactive prompts
  - Key Finding: 15 occurrences of backup file patterns found across .opencode directory
  - Recommendation: Complete migration to pure git-based safety by removing all backup file patterns
  - Recommendation: Audit and expand agent frontmatter allow lists where safe with git safety as backup
  - Recommendation: Remove maintenance confirmation prompts, replace with git safety commits
  - Recommendation: Standardize git-workflow-manager usage across all commands

---

## Goals and Non-Goals

### Goals

1. Eliminate all backup file patterns in favor of git safety commits
2. Increase agent autonomy through expanded permissions
3. Remove user interruptions from maintenance operations
4. Standardize git workflow across all commands
5. Document permission configuration for future maintenance

### Non-Goals

1. Removing dangerous operation restrictions (rm -rf, sudo, etc.)
2. Changing the interactive interview pattern for /meta command
3. Modifying the core git-workflow-manager implementation
4. Implementing new safety mechanisms beyond git commits

---

## Risks and Mitigations

### Risk 1: Expanded Permissions Enable Destructive Operations

**Likelihood**: Low  
**Impact**: High  
**Mitigation**:
- Keep dangerous operations in deny list (rm -rf, sudo, chmod +x, dd, etc.)
- Use git safety commits before all risky operations
- Test rollback scenarios thoroughly
- Monitor permission denials for unexpected patterns

### Risk 2: Git Safety Commits Create Excessive History

**Likelihood**: Medium  
**Impact**: Low  
**Mitigation**:
- Safety commits are intentional and valuable for debugging
- Git history can be cleaned with `git rebase -i` if needed
- Safety commits clearly marked with "safety:" prefix
- Benefits (rollback, debugging) outweigh cost (history size)

### Risk 3: Migration Breaks Existing Workflows

**Likelihood**: Low  
**Impact**: Medium  
**Mitigation**:
- Test each migration thoroughly before committing
- Maintain backward compatibility during transition
- Document changes in implementation summary
- Provide rollback instructions if issues occur

### Risk 4: Increased Autonomy Reduces User Control

**Likelihood**: Low  
**Impact**: Low  
**Mitigation**:
- Git safety provides complete rollback capability
- All operations logged for audit trail
- User can interrupt with Ctrl+C and run /sync to reset
- Interactive patterns retained where valuable (/meta)

---

## Implementation Phases

### Phase 1: Audit Backup File Usage [NOT STARTED]

**Objective**: Identify all locations where backup files are created instead of git safety commits

**Tasks**:
1. Search for backup file creation patterns:
   ```bash
   grep -r "\.bak\|backup" .opencode/command/ .opencode/agent/subagents/
   ```
2. Document each location with:
   - File path
   - Backup pattern used
   - Purpose of backup
   - Surrounding context (what operation is being protected)
3. Create migration checklist with priority order:
   - High priority: status-sync-manager, sync command
   - Medium priority: todo command, review command
   - Low priority: any other occurrences
4. Verify no backup files currently exist:
   ```bash
   find .opencode -name "*.bak" -o -name "*.backup"
   ```

**Acceptance Criteria**:
- [ ] Complete list of backup file locations documented
- [ ] Migration checklist created with priorities
- [ ] No existing backup files found in .opencode directory

**Estimated Effort**: 1 hour

---

### Phase 2: Migrate Commands to Git Safety Pattern [NOT STARTED]

**Objective**: Replace backup file creation with git safety commits in all commands

**Tasks**:
1. For each command identified in Phase 1:
   
   a. **Add CreateSafetyCommit stage** before risky operation:
   ```xml
   <stage id="N" name="CreateSafetyCommit">
     <action>Create git safety commit before risky operation</action>
     <process>
       1. Stage files that will be modified:
          ```bash
          git add .opencode/specs/TODO.md .opencode/specs/state.json
          ```
       2. Create safety commit:
          ```bash
          git commit -m "safety: pre-{operation} snapshot"
          ```
       3. Store commit SHA:
          ```bash
          safety_commit=$(git rev-parse HEAD)
          ```
       4. Verify commit created:
          ```bash
          git log -1 --oneline
          ```
     </process>
     <checkpoint>Safety commit created, SHA stored</checkpoint>
   </stage>
   ```
   
   b. **Remove backup file creation code**:
   - Delete lines creating .bak files
   - Delete lines creating /tmp backups
   - Remove backup file cleanup code
   
   c. **Add git rollback to error handling**:
   ```xml
   <error_handling>
     IF operation fails:
       STEP 1: Execute git rollback
         ```bash
         git reset --hard $safety_commit
         git clean -fd
         ```
       STEP 2: Log rollback to errors.json
       STEP 3: Return error with rollback confirmation
   </error_handling>
   ```
   
   d. **Add CreateFinalCommit stage** (delegate to git-workflow-manager):
   ```xml
   <stage id="M" name="CreateFinalCommit">
     <action>Delegate to git-workflow-manager for final commit</action>
     <process>
       1. Prepare delegation context with scope_files, message_template, task_context
       2. Invoke git-workflow-manager with timeout (300s)
       3. Validate return status (completed or failed)
       4. If failed: Log warning (non-critical)
       5. Continue (operation already succeeded)
     </process>
     <checkpoint>Final commit created or logged</checkpoint>
   </stage>
   ```

2. Test each migrated command:
   - Test successful operation (verify final commit created)
   - Test failed operation (verify rollback to safety commit)
   - Verify no .bak files created
   - Verify git log shows safety and final commits

3. Update command documentation to reflect git safety pattern

**Acceptance Criteria**:
- [ ] All commands use git safety commits instead of backup files
- [ ] Error handling includes git rollback
- [ ] All commands delegate to git-workflow-manager for final commits
- [ ] Tests pass for successful and failed operations
- [ ] No backup files created during testing

**Estimated Effort**: 4 hours

---

### Phase 3: Audit and Expand Agent Permissions [NOT STARTED]

**Objective**: Review all agent frontmatter files and expand allow lists where safe

**Tasks**:
1. List all agent files:
   ```bash
   find .opencode/agent/subagents -name "*.md" | sort
   ```

2. For each agent file:
   
   a. **Review current permissions**:
   - Extract current allow and deny lists
   - Identify operations needed for agent function
   - Check if git tool is in tools list
   
   b. **Expand allow list** where safe:
   
   **Research agents**:
   ```yaml
   permissions:
     allow:
       - read: ["**/*.md", ".opencode/**/*", "Documentation/**/*", "**/*.lean"]
       - write: [".opencode/specs/**/*", "Documentation/Research/**/*"]
       - bash: ["git", "grep", "find", "wc", "jq", "sed", "awk"]
   ```
   
   **Planning agents**:
   ```yaml
   permissions:
     allow:
       - read: ["**/*.md", ".opencode/**/*", "Documentation/**/*"]
       - write: [".opencode/specs/**/*"]
       - bash: ["git", "grep", "find", "wc", "jq"]
   ```
   
   **Implementation agents**:
   ```yaml
   permissions:
     allow:
       - read: ["**/*"]
       - write: ["**/*.lean", "**/*.md", ".opencode/specs/**/*"]
       - edit: ["**/*.lean", "**/*.md"]
       - bash: ["git", "lake", "grep", "find", "wc", "jq"]
     deny:
       - write: [".git/**/*", "lakefile.lean", "lean-toolchain"]
   ```
   
   c. **Ensure dangerous operations remain denied**:
   ```yaml
   deny:
     - bash: ["rm -rf", "sudo", "chmod +x", "dd", "wget", "curl"]
     - write: [".git/**/*"]
     - read: [".env", "**/*.key", "**/*.pem"]
   ```
   
   d. **Add git to tools list** if not present:
   ```yaml
   tools:
     - read
     - write
     - edit
     - bash
     - git  # Ensure git available for safety commits
   ```

3. Test agent operations with new permissions:
   - Run sample operations for each agent type
   - Monitor permission denials in logs
   - Verify dangerous operations still denied

4. Document permission changes in implementation summary

**Acceptance Criteria**:
- [ ] All agent frontmatter files audited
- [ ] Allow lists expanded where safe
- [ ] Dangerous operations remain denied
- [ ] Git tool added to all agent tools lists
- [ ] Agent operations tested with new permissions
- [ ] Permission changes documented

**Estimated Effort**: 3 hours

---

### Phase 4: Remove Confirmation Prompts [NOT STARTED]

**Objective**: Replace user confirmation prompts with git safety commits

**Tasks**:
1. Search for confirmation prompts:
   ```bash
   grep -r "confirm\|approval\|prompt" .opencode/command/ .opencode/agent/subagents/
   ```

2. For each confirmation prompt found:
   
   a. **Identify the operation being confirmed**:
   - What files will be modified?
   - What is the risk being mitigated?
   - Is this a valuable user interaction or interruption?
   
   b. **Replace with git safety pattern** (if interruption):
   - Add CreateSafetyCommit stage before operation
   - Remove confirmation prompt code
   - Add git rollback to error handling
   - Add CreateFinalCommit stage after operation
   
   c. **Keep interactive pattern** (if valuable):
   - /meta command interview (intentional design)
   - Any other genuinely interactive workflows
   
3. Update command documentation:
   - Remove references to user confirmation
   - Document git safety as protection mechanism
   - Add rollback instructions for users

4. Test operations that previously required confirmation:
   - Verify operations complete without user input
   - Verify git safety commits created
   - Verify rollback works on failure

**Acceptance Criteria**:
- [ ] All maintenance confirmation prompts removed
- [ ] Git safety commits replace confirmations
- [ ] Interactive interview for /meta retained
- [ ] Command documentation updated
- [ ] Operations tested without user input

**Estimated Effort**: 2 hours

---

### Phase 5: Standardize Git Workflow Manager Usage [NOT STARTED]

**Objective**: Ensure all commands delegate to git-workflow-manager for commits

**Tasks**:
1. Search for direct git commands:
   ```bash
   grep -r "git commit\|git add" .opencode/command/ .opencode/agent/subagents/ | grep -v "git-workflow-manager"
   ```

2. For each direct git usage:
   
   a. **Replace with delegation to git-workflow-manager**:
   ```xml
   <stage id="N" name="CreateGitCommit">
     <action>Delegate to git-workflow-manager for commit</action>
     <process>
       1. Prepare delegation context:
          ```json
          {
            "scope_files": ["{modified_files}"],
            "message_template": "{operation}: {description}",
            "task_context": {
              "task_number": "{number}",
              "description": "{description}"
            },
            "session_id": "{session_id}",
            "delegation_depth": {depth + 1},
            "delegation_path": [...delegation_path, "git-workflow-manager"]
          }
          ```
       2. Invoke git-workflow-manager with timeout (120s)
       3. Validate return status (completed or failed)
       4. If status == "failed": Log error (non-critical)
       5. Continue (git failure doesn't fail command)
     </process>
     <checkpoint>Git commit created or error logged</checkpoint>
   </stage>
   ```
   
   b. **Test commit creation**:
   - Verify commit created with correct message format
   - Verify only scoped files included
   - Verify error handling for git failures
   
3. Document git-workflow-manager usage pattern:
   - Add examples to git-safety.md
   - Update command template with delegation pattern
   - Document non-blocking failure behavior

**Acceptance Criteria**:
- [ ] All commands delegate to git-workflow-manager for commits
- [ ] No direct git commit commands in workflow code
- [ ] Commit messages follow format standards
- [ ] Error handling tested for git failures
- [ ] Documentation updated with delegation pattern

**Estimated Effort**: 1.5 hours

---

### Phase 6: Document Permission Configuration [NOT STARTED]

**Objective**: Create comprehensive guide for configuring agent permissions

**Tasks**:
1. Create permission configuration guide:
   - File: `.opencode/docs/guides/permission-configuration.md`
   - Sections:
     * Permission System Architecture
     * Permission Evaluation Order (deny → allow → default deny)
     * Glob Pattern Syntax
     * Examples by Agent Type (research, planning, implementation)
     * Safety Boundaries and Rationale
     * Debugging Permission Denials
     * Common Permission Patterns

2. Document permission examples:
   
   **Research Agent Example**:
   ```yaml
   permissions:
     allow:
       - read: ["**/*.md", ".opencode/**/*", "Documentation/**/*"]
       - write: [".opencode/specs/**/*"]
       - bash: ["git", "grep", "find", "wc", "jq"]
     deny:
       - bash: ["rm -rf", "sudo", "chmod +x"]
       - write: [".git/**/*"]
   ```
   
   **Implementation Agent Example**:
   ```yaml
   permissions:
     allow:
       - read: ["**/*"]
       - write: ["**/*.lean", "**/*.md", ".opencode/specs/**/*"]
       - bash: ["git", "lake", "grep", "find"]
     deny:
       - bash: ["rm -rf", "sudo", "chmod +x", "dd"]
       - write: [".git/**/*", "lakefile.lean", "lean-toolchain"]
   ```

3. Document dangerous operations that must be denied:
   - Destructive filesystem operations (rm -rf, rm -fr)
   - Privilege escalation (sudo, su, doas)
   - Permission changes (chmod +x, chmod 777, chown)
   - Disk operations (dd, mkfs, fdisk)
   - Network operations (wget, curl, nc, netcat)
   - Process manipulation (kill -9, killall, pkill)
   - System modification (systemctl, service, shutdown)
   - Package management (apt, yum, pip, npm, cargo)
   - Shell execution (eval, exec, source)
   - Sensitive file access (.env, *.key, *.pem, .ssh/**)

4. Add troubleshooting section:
   - How to identify permission denials in logs
   - How to safely expand permissions
   - How to test permission changes
   - How to rollback permission changes

5. Link guide from main documentation:
   - Add reference in .opencode/README.md
   - Add reference in .opencode/ARCHITECTURE.md
   - Add reference in .opencode/context/core/standards/frontmatter-standard.md

**Acceptance Criteria**:
- [ ] Permission configuration guide created
- [ ] Examples provided for all agent types
- [ ] Dangerous operations documented
- [ ] Troubleshooting section complete
- [ ] Guide linked from main documentation

**Estimated Effort**: 0.5 hours

---

## Testing and Validation

### Unit Testing

1. **Backup file migration**:
   - Test each migrated command for successful operation
   - Test each migrated command for failed operation with rollback
   - Verify no .bak files created: `find .opencode -name "*.bak"`

2. **Permission expansion**:
   - Test each agent type with new permissions
   - Verify dangerous operations still denied
   - Monitor permission denials in logs

3. **Confirmation prompt removal**:
   - Test operations that previously required confirmation
   - Verify operations complete without user input
   - Verify git safety commits created

4. **Git workflow standardization**:
   - Test commit creation via git-workflow-manager
   - Verify commit message format
   - Test error handling for git failures

### Integration Testing

1. **End-to-end workflow testing**:
   - Run /research, /plan, /implement workflows
   - Verify git safety commits created at appropriate stages
   - Verify no backup files created
   - Verify no user confirmation prompts

2. **Rollback testing**:
   - Simulate operation failures
   - Verify git rollback to safety commit
   - Verify clean working tree after rollback

3. **Permission testing**:
   - Test agent operations with expanded permissions
   - Verify dangerous operations denied
   - Verify git safety provides adequate protection

### Validation Criteria

- [ ] All backup file patterns removed
- [ ] All commands use git safety commits
- [ ] Agent permissions expanded where safe
- [ ] Confirmation prompts removed
- [ ] Git workflow standardized
- [ ] Documentation complete
- [ ] All tests pass
- [ ] No backup files created during testing
- [ ] Git log shows safety and final commits

---

## Artifacts and Outputs

### Primary Artifacts

1. **Modified command files**:
   - `.opencode/command/sync.md` (git safety migration)
   - `.opencode/command/todo.md` (git safety migration)
   - `.opencode/command/review.md` (git safety migration)
   - Any other commands with backup patterns

2. **Modified agent files**:
   - `.opencode/agent/subagents/status-sync-manager.md` (git safety migration)
   - `.opencode/agent/subagents/researcher.md` (permission expansion)
   - `.opencode/agent/subagents/planner.md` (permission expansion)
   - `.opencode/agent/subagents/implementer.md` (permission expansion)
   - `.opencode/agent/subagents/lean-research-agent.md` (permission expansion)
   - `.opencode/agent/subagents/lean-implementation-agent.md` (permission expansion)
   - All other agent files (permission expansion)

3. **New documentation**:
   - `.opencode/docs/guides/permission-configuration.md` (new guide)

4. **Implementation summary**:
   - `.opencode/specs/313_configure_opencode_agent_system_to_prevent_permission_interruptions/summaries/implementation-summary-20260105.md`

### Supporting Artifacts

1. **Backup file audit**:
   - List of all backup file locations
   - Migration checklist with priorities

2. **Permission audit**:
   - List of all agent files
   - Current vs. expanded permissions for each agent
   - Permission changes documentation

3. **Test results**:
   - Unit test results for each phase
   - Integration test results
   - Validation checklist

---

## Rollback/Contingency

### Rollback Plan

If issues occur during implementation:

1. **Git rollback to safety commit**:
   ```bash
   git reset --hard {safety_commit_sha}
   git clean -fd
   ```

2. **Restore individual files** if needed:
   ```bash
   git checkout {commit_sha} -- {file_path}
   ```

3. **Revert permission changes**:
   - Restore original agent frontmatter files
   - Test agent operations with original permissions

### Contingency Actions

1. **If backup file migration breaks commands**:
   - Rollback to safety commit
   - Review git safety implementation
   - Test rollback scenarios more thoroughly
   - Retry migration with fixes

2. **If permission expansion enables destructive operations**:
   - Immediately revert permission changes
   - Review deny list for gaps
   - Add missing dangerous operations to deny list
   - Test with more restrictive permissions

3. **If git safety commits create excessive history**:
   - Continue with implementation (history size acceptable)
   - Document git history cleanup procedure
   - Consider squashing safety commits in future

4. **If confirmation prompt removal causes issues**:
   - Restore confirmation prompts temporarily
   - Review git safety implementation
   - Ensure rollback capability adequate
   - Retry removal with better testing

---

## Success Metrics

### Quantitative Metrics

1. **Backup file elimination**:
   - Target: 0 backup file patterns in .opencode directory
   - Measurement: `grep -r "\.bak\|backup" .opencode/ | wc -l`
   - Baseline: 15 occurrences
   - Goal: 0 occurrences

2. **Permission expansion**:
   - Target: All agent files have git tool in tools list
   - Measurement: Count of agent files with git tool
   - Baseline: Unknown (to be measured in Phase 3)
   - Goal: 100% of agent files

3. **Confirmation prompt removal**:
   - Target: 0 user confirmation prompts in maintenance operations
   - Measurement: `grep -r "confirm\|approval" .opencode/command/ | wc -l`
   - Baseline: Unknown (to be measured in Phase 4)
   - Goal: 0 occurrences (excluding /meta interview)

4. **Git workflow standardization**:
   - Target: All commits via git-workflow-manager
   - Measurement: `grep -r "git commit" .opencode/command/ | grep -v "git-workflow-manager" | wc -l`
   - Baseline: Unknown (to be measured in Phase 5)
   - Goal: 0 direct git commit commands

### Qualitative Metrics

1. **Agent autonomy**:
   - Agents operate without user interruptions
   - Permission denials reduced for legitimate operations
   - Git safety provides adequate protection

2. **Code quality**:
   - Consistent git safety pattern across all commands
   - Clear documentation for permission configuration
   - Maintainable permission boundaries

3. **User experience**:
   - Reduced interruptions during workflow execution
   - Clear rollback capability via git
   - Transparent operation logging

### Acceptance Criteria

- [ ] All quantitative metrics meet goals
- [ ] All qualitative metrics satisfied
- [ ] All tests pass
- [ ] Documentation complete and accurate
- [ ] Git commit created with descriptive message
- [ ] Implementation summary created

---

## Notes

### Implementation Strategy

This implementation follows an incremental approach:

1. **Phase 1-2**: Focus on git safety migration (foundation)
2. **Phase 3-4**: Expand autonomy (permissions and prompts)
3. **Phase 5-6**: Standardize and document (consistency)

Each phase builds on the previous, allowing for testing and validation at each step.

### Key Decisions

1. **Git commits as sole safety mechanism**: Research confirms this is adequate and superior to backup files
2. **Expand permissions with git safety**: Safe to expand permissions when git rollback available
3. **Remove maintenance confirmations**: Git safety provides equivalent protection
4. **Keep /meta interactive interview**: Intentional design, valuable user experience

### Dependencies

- Git repository required (already present)
- git-workflow-manager functional (already implemented)
- status-sync-manager functional (already implemented)

### Future Enhancements

1. **Permission denial monitoring**: Track denials in errors.json for proactive configuration
2. **Automated permission testing**: Test suite for permission boundaries
3. **Permission templates**: Reusable permission patterns for common agent types
4. **Git history cleanup**: Automated squashing of safety commits

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-05 | planner | Initial implementation plan created |
