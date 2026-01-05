# Research Report: Configure OpenCode Agent System to Prevent Permission Interruptions

**Task**: 313 - Configure opencode agent system to prevent permission interruptions and ensure greater autonomy by relying on git commits for safety while avoiding other backups  
**Started**: 2026-01-05  
**Completed**: 2026-01-05  
**Effort**: 3 hours  
**Priority**: Medium  
**Dependencies**: None  
**Sources/Inputs**: opencode.json, .opencode/ARCHITECTURE.md, .opencode/README.md, .opencode/context/core/standards/frontmatter-standard.md, .opencode/context/core/standards/git-safety.md, .opencode/agent/orchestrator.md, .opencode/agent/subagents/git-workflow-manager.md  
**Artifacts**: .opencode/specs/313_configure_opencode_agent_system_to_prevent_permission_interruptions/reports/research-001.md  
**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

---

## Executive Summary

This research investigates how to configure the OpenCode agent system to prevent permission interruptions and ensure greater autonomy by relying on git commits for safety while avoiding other backup mechanisms. The investigation reveals that OpenCode already has a sophisticated git-based safety system in place, but there are opportunities to enhance agent autonomy by:

1. **Eliminating remaining backup file patterns** - The system has migrated from .bak files to git safety commits, but some commands still use backup patterns
2. **Configuring permission boundaries** - The frontmatter `permissions` field provides fine-grained control over agent capabilities
3. **Enabling autonomous operation modes** - Agents can be configured to operate without user confirmation through proper permission configuration
4. **Leveraging git as the sole safety mechanism** - Git commits provide complete rollback capability without file system clutter

Key findings: The system already implements delegation safety (cycle detection, depth limits, timeout enforcement), git-based safety patterns (safety commits, rollback on failure), and standardized return formats. The primary configuration needed is to adjust permission boundaries in agent frontmatter and eliminate remaining backup file usage.

---

## Context & Scope

### Problem Statement

The task description requests configuration changes to "prevent permission interruptions and ensure greater autonomy by relying on git commits for safety while avoiding other backups." This suggests:

1. **Permission interruptions** - Agents may be requesting user permission/confirmation during execution
2. **Limited autonomy** - Agents may be constrained in ways that require human intervention
3. **Backup mechanisms** - The system may be using backup files (.bak, .backup) instead of git commits
4. **Safety concerns** - Need to maintain safety while increasing autonomy

### Current System Architecture

The OpenCode system (version 2.0) is a task management and automation framework with:

- **Three-layer delegation**: Orchestrator → Command files → Execution subagents
- **Delegation safety**: Session tracking, cycle detection, depth limits (max 3), timeout enforcement
- **Atomic state updates**: Two-phase commit with rollback via status-sync-manager
- **Language-based routing**: Lean tasks → lean-specific agents, other tasks → general agents
- **Git-based safety**: Safety commits before risky operations, automatic rollback on failure
- **Error tracking**: All errors logged to errors.json with fix effectiveness analysis

### Research Questions

1. What are "permission interruptions" in the OpenCode context?
2. How does the current system handle user permissions and confirmations?
3. What backup mechanisms exist beyond git commits?
4. How can agent autonomy be increased while maintaining safety?
5. What configuration files control agent behavior and permissions?

---

## Key Findings

### Finding 1: Permission System Architecture

**Source**: `.opencode/context/core/standards/frontmatter-standard.md`

The OpenCode system implements a comprehensive permission system through YAML frontmatter in agent files:

```yaml
permissions:
  allow:
    - read: ["**/*.md", ".opencode/**/*"]
    - write: [".opencode/specs/**/*"]
    - bash: ["grep", "find", "wc"]
  deny:
    - bash: ["rm -rf", "sudo", "chmod +x", "dd"]
    - write: [".git/**/*", "**/*.lean"]
    - read: [".env", "**/*.key", "**/*.pem"]
```

**Permission Evaluation**:
1. Check deny list first (deny takes precedence)
2. If not denied, check allow list
3. If not in allow list, deny by default
4. Log all permission denials for audit

**Key Insight**: The permission system is declarative and enforced at runtime. Agents don't request user permission - they either have permission (via allow list) or don't (denied automatically).

**Implication**: "Permission interruptions" likely refers to agents being denied operations due to restrictive permission configurations, not interactive user prompts.

### Finding 2: Git-Based Safety System

**Source**: `.opencode/context/core/standards/git-safety.md`

The system has migrated from backup files to git-based safety:

**Core Principle**: Never create `.bak` files. Use git commits for safety.

**Standard Pattern**:
1. **CreateSafetyCommit**: Stage files, create commit with message "safety: pre-{operation} snapshot", store commit SHA
2. **ExecuteRiskyOperation**: Perform operation, trigger rollback on failure
3. **CreateFinalCommit**: Stage changes, create commit with descriptive message

**Rollback Pattern**:
```bash
git reset --hard {safety_commit_sha}
git clean -fd
```

**Benefits vs Backup Files**:
- No file clutter (.bak files)
- Full history preserved in git log
- Easy debugging (git log --grep="safety:")
- Atomic rollback (git reset --hard)
- Automatic cleanup (part of git history)

**Key Insight**: The system already has a robust git-based safety mechanism that eliminates the need for backup files.

**Implication**: Any remaining backup file usage should be removed in favor of git safety commits.

### Finding 3: Current Backup File Usage

**Source**: grep search across .opencode directory

**Backup file references found**: 15 occurrences across various files

**Primary locations**:
1. **status-sync-manager** - Uses backup pattern for atomic updates
2. **sync command** - Creates backups before synchronization
3. **todo command** - References backup pattern (may be migrated)
4. **review command** - References backup/rollback pattern

**Example from sync.md**:
```bash
# Create backups
cp .opencode/specs/TODO.md /tmp/TODO.md.backup.$session_id
cp .opencode/specs/state.json /tmp/state.json.backup.$session_id
```

**Key Insight**: Some commands still use temporary backup files in /tmp for atomic operations, though the git-safety.md standard recommends eliminating these.

**Implication**: Migration to pure git-based safety is incomplete. Some commands need updating to use git safety commits instead of backup files.

### Finding 4: Agent Autonomy Patterns

**Source**: `.opencode/ARCHITECTURE.md`, `.opencode/README.md`

**Current autonomy features**:
1. **Automatic resume** - Interrupted implementations resume from last completed phase
2. **Non-blocking git failures** - Git commit failures logged but don't fail tasks
3. **Graceful degradation** - Lean agents fall back to direct file modification if tools unavailable
4. **Timeout handling** - Partial results returned on timeout with resume instructions
5. **Error recovery** - Automatic error analysis and fix plan generation

**No user confirmation patterns found** in core workflow commands. The system operates autonomously once invoked.

**Interactive patterns found**:
- `/meta` command uses interactive interview for system building
- Session cleanup asks for user confirmation before deletion
- Some maintenance operations request confirmation (>5 completed tasks)

**Key Insight**: The system is already highly autonomous for core workflows. User interaction is limited to specific meta-operations and cleanup tasks.

**Implication**: "Greater autonomy" likely means removing remaining confirmation prompts and expanding permission boundaries where safe.

### Finding 5: Configuration Files Controlling Behavior

**Primary configuration files**:

1. **opencode.json** (project root)
   - Default agent configuration
   - MCP server configuration
   - Tool enablement per agent
   - Agent-specific tool subsets

2. **Agent frontmatter** (.opencode/agent/subagents/*.md)
   - name, version, description
   - mode (subagent/orchestrator)
   - agent_type (research/planning/implementation/execution/validation)
   - temperature (0.1-0.3 based on agent type)
   - max_tokens (1000-8000)
   - timeout (60-10800 seconds)
   - tools (array of available tools)
   - **permissions** (allow/deny rules)
   - context_loading (lazy/eager/filtered)
   - delegation (max_depth, can_delegate_to, timeouts)

3. **Command frontmatter** (.opencode/command/*.md)
   - agent (target for delegation)
   - timeout
   - description

**Key Insight**: Agent behavior is controlled through YAML frontmatter in agent files, with project-wide defaults in opencode.json.

**Implication**: Increasing autonomy requires modifying permission boundaries in agent frontmatter files.

### Finding 6: Dangerous Operations and Safety Boundaries

**Source**: `.opencode/context/core/standards/frontmatter-standard.md`

**Dangerous commands that MUST be in deny list**:

```yaml
deny:
  # Destructive filesystem operations
  - bash: ["rm -rf", "rm -fr", "rm -r *"]
  
  # Privilege escalation
  - bash: ["sudo", "su", "doas"]
  
  # Permission changes
  - bash: ["chmod +x", "chmod 777", "chown"]
  
  # Disk operations
  - bash: ["dd", "mkfs", "fdisk"]
  
  # Network operations
  - bash: ["wget", "curl", "nc", "netcat"]
  
  # Process manipulation
  - bash: ["kill -9", "killall", "pkill"]
  
  # System modification
  - bash: ["systemctl", "service", "shutdown"]
  
  # Package management
  - bash: ["apt", "yum", "pip", "npm", "cargo"]
  
  # Shell execution
  - bash: ["eval", "exec", "source"]
  
  # Sensitive file access
  - read: [".env", "**/*.key", "**/*.pem", ".ssh/**/*"]
  
  # Critical file modification
  - write: [".git/**/*", "lakefile.lean", "lean-toolchain"]
```

**Key Insight**: The system has well-defined safety boundaries that prevent catastrophic operations while allowing productive work.

**Implication**: Increasing autonomy must respect these safety boundaries. Git commits provide safety for allowed operations.

### Finding 7: Git Workflow Manager

**Source**: `.opencode/agent/subagents/git-workflow-manager.md`

**Purpose**: Create scoped git commits with auto-generated messages

**Process**:
1. Receive explicit file list (scope_files)
2. Add related tracking files (TODO.md, state.json, plan files)
3. Validate all files exist
4. Generate commit message from template
5. Stage files with `git add {file_path}`
6. Create commit with `git commit -m "{message}"`
7. Handle errors gracefully (non-blocking)

**Key features**:
- Scoped commits (only specified files)
- Auto-generated messages following format standards
- Non-blocking failures (logged but don't fail task)
- Standardized return format

**Key Insight**: The git-workflow-manager provides a centralized, safe way to create commits without requiring user intervention.

**Implication**: All commands should delegate to git-workflow-manager for commits rather than implementing git operations directly.

---

## Detailed Analysis

### Analysis 1: Permission Interruption Root Causes

Based on the research, "permission interruptions" in the OpenCode context likely refers to:

1. **Restrictive permission configurations** - Agents denied operations they need to perform
2. **Missing tool access** - Agents lacking tools in their frontmatter configuration
3. **Overly conservative deny rules** - Operations blocked that could be safely allowed with git safety
4. **Incomplete permission specifications** - Agents without clear allow/deny rules defaulting to deny

**Evidence**:
- No interactive user permission prompts found in core workflow code
- Permission system is declarative (allow/deny lists in frontmatter)
- Permission denials are logged for audit
- System operates autonomously once invoked

**Recommendation**: Audit agent frontmatter files for overly restrictive permissions and expand allow lists where safe (with git safety as backup).

### Analysis 2: Backup File Migration Status

**Completed migrations**:
- Core workflow commands use git safety commits
- Git-safety.md standard documented and promoted
- git-workflow-manager provides centralized commit creation

**Incomplete migrations**:
- status-sync-manager may still use backup pattern
- sync command creates /tmp backups
- Some commands reference backup/rollback patterns

**Migration path**:
1. Identify all backup file creation (grep -r "\.bak\|backup" .opencode/)
2. For each location:
   - Add CreateSafetyCommit stage before operation
   - Remove backup file creation code
   - Add git rollback to error handling
   - Add CreateFinalCommit stage after operation
3. Test successful operation and rollback scenarios
4. Verify no .bak files created

**Recommendation**: Complete migration to pure git-based safety by removing all backup file patterns.

### Analysis 3: Autonomy Enhancement Opportunities

**Current state**: System is highly autonomous for core workflows

**Remaining user interactions**:
1. `/meta` command interactive interview (intentional, valuable)
2. Session cleanup confirmation (safety feature)
3. Maintenance operation confirmations (>5 tasks)

**Enhancement opportunities**:
1. **Remove maintenance confirmations** - Use git safety commits instead of asking user
2. **Expand permission boundaries** - Allow more file operations with git safety
3. **Enable parallel execution** - Execute independent phases in parallel (future)
4. **Automatic error recovery** - Implement fixes without user intervention (future)

**Recommendation**: Focus on removing maintenance confirmations and expanding permissions. Keep interactive interview for /meta (valuable UX).

### Analysis 4: Git Safety as Sole Safety Mechanism

**Advantages**:
1. **Complete rollback** - `git reset --hard` reverts all changes atomically
2. **No file clutter** - No .bak files to manage
3. **Full history** - All safety points preserved in git log
4. **Easy debugging** - `git log --grep="safety:"` shows all safety commits
5. **Verification** - `git status` confirms clean state after rollback

**Requirements for sole safety mechanism**:
1. **Git repository required** - System already requires git
2. **Clean working tree** - Operations should start with clean state
3. **Scoped commits** - Only commit relevant files
4. **Clear commit messages** - Follow format standards
5. **Non-blocking failures** - Git failures logged but don't fail tasks

**Current implementation**: Git-workflow-manager provides all required features

**Recommendation**: Adopt git commits as sole safety mechanism, remove all backup file patterns.

### Analysis 5: Configuration Changes Needed

**Agent frontmatter changes**:

1. **Expand allow lists** where safe:
   ```yaml
   permissions:
     allow:
       - write: [".opencode/specs/**/*", "Documentation/**/*", "*.md"]
       - bash: ["git", "grep", "find", "wc", "jq", "sed", "awk"]
   ```

2. **Remove overly restrictive deny rules**:
   - Keep dangerous operations denied (rm -rf, sudo, etc.)
   - Allow safe operations with git safety backup

3. **Add git to all agent tool lists**:
   ```yaml
   tools:
     - read
     - write
     - edit
     - bash
     - git  # Ensure git available for safety commits
   ```

**Command changes**:

1. **Remove backup file creation**:
   - Replace with CreateSafetyCommit stages
   - Use git rollback on failure

2. **Remove user confirmation prompts**:
   - Replace with git safety commits
   - Log operations for audit

3. **Delegate to git-workflow-manager**:
   - Use centralized commit creation
   - Ensure consistent commit messages

**opencode.json changes**:

1. **Enable git tool globally**:
   ```json
   {
     "tools": {
       "git": true
     }
   }
   ```

2. **Set default permission boundaries**:
   ```json
   {
     "permissions": {
       "allow": {
         "write": [".opencode/specs/**/*"],
         "bash": ["git", "grep", "find", "wc", "jq"]
       },
       "deny": {
         "bash": ["rm -rf", "sudo", "chmod +x"],
         "write": [".git/**/*"]
       }
     }
   }
   ```

---

## Decisions

### Decision 1: Adopt Git Commits as Sole Safety Mechanism

**Decision**: Remove all backup file patterns (.bak, /tmp backups) and rely exclusively on git commits for safety.

**Rationale**:
- Git provides complete rollback capability
- Eliminates file system clutter
- Provides full history and debugging capability
- Already implemented via git-workflow-manager
- Aligns with system architecture principles

**Implementation**: Complete migration of remaining commands to git safety pattern.

### Decision 2: Expand Agent Permission Boundaries

**Decision**: Expand allow lists in agent frontmatter to enable more autonomous operation while maintaining safety boundaries.

**Rationale**:
- Git safety commits provide rollback capability
- Current restrictions may be overly conservative
- Agents can operate more autonomously with broader permissions
- Dangerous operations remain denied

**Implementation**: Audit and update agent frontmatter files with expanded allow lists.

### Decision 3: Remove User Confirmation Prompts

**Decision**: Remove user confirmation prompts from maintenance operations, replacing with git safety commits.

**Rationale**:
- Git safety provides equivalent protection
- Reduces user interruptions
- Increases system autonomy
- Maintains audit trail via git log

**Implementation**: Update commands to use git safety instead of user confirmation.

### Decision 4: Keep Interactive Interview for /meta

**Decision**: Retain interactive interview pattern for /meta command.

**Rationale**:
- Intentional design for system building
- Valuable user experience
- Not a "permission interruption" but a workflow feature
- Appropriate for meta-operations

**Implementation**: No changes needed.

---

## Recommendations

### Recommendation 1: Complete Git Safety Migration (High Priority)

**Action**: Migrate all remaining backup file patterns to git safety commits.

**Steps**:
1. Search for backup file creation: `grep -r "\.bak\|backup" .opencode/`
2. For each location:
   - Add CreateSafetyCommit stage
   - Remove backup file creation
   - Add git rollback to error handling
   - Add CreateFinalCommit stage
3. Test successful operation and rollback
4. Verify no .bak files created: `find . -name "*.bak"`

**Files to update**:
- `.opencode/agent/subagents/status-sync-manager.md`
- `.opencode/command/sync.md`
- Any other commands with backup patterns

**Expected impact**: Eliminates file system clutter, provides consistent safety mechanism.

### Recommendation 2: Audit and Expand Agent Permissions (High Priority)

**Action**: Review all agent frontmatter files and expand allow lists where safe.

**Steps**:
1. List all agent files: `find .opencode/agent/subagents -name "*.md"`
2. For each agent:
   - Review current permissions
   - Identify operations needed for agent function
   - Expand allow list to include needed operations
   - Ensure dangerous operations remain denied
   - Add git to tools list if not present
3. Test agent operations with new permissions
4. Monitor permission denials in logs

**Example expansions**:
```yaml
# Research agents
permissions:
  allow:
    - read: ["**/*.md", ".opencode/**/*", "Documentation/**/*"]
    - write: [".opencode/specs/**/*"]
    - bash: ["git", "grep", "find", "wc", "jq"]

# Implementation agents
permissions:
  allow:
    - read: ["**/*"]
    - write: ["**/*.lean", "**/*.md", ".opencode/specs/**/*"]
    - edit: ["**/*.lean", "**/*.md"]
    - bash: ["git", "lake", "grep", "find"]
  deny:
    - write: [".git/**/*", "lakefile.lean", "lean-toolchain"]
```

**Expected impact**: Increased agent autonomy, reduced permission denials.

### Recommendation 3: Remove Maintenance Confirmation Prompts (Medium Priority)

**Action**: Replace user confirmation prompts with git safety commits.

**Steps**:
1. Identify commands with confirmation prompts: `grep -r "confirm\|approval" .opencode/command/`
2. For each prompt:
   - Add CreateSafetyCommit stage before operation
   - Remove confirmation prompt
   - Add git rollback on failure
   - Add CreateFinalCommit stage after operation
3. Update documentation to reflect autonomous operation
4. Test operations with git safety

**Files to update**:
- `.opencode/command/todo.md` (if >5 tasks confirmation exists)
- `.opencode/context/core/workflows/sessions.md` (session cleanup)
- Any other commands with confirmation prompts

**Expected impact**: Reduced user interruptions, increased autonomy.

### Recommendation 4: Standardize Git Workflow Manager Usage (Medium Priority)

**Action**: Ensure all commands delegate to git-workflow-manager for commits.

**Steps**:
1. Search for direct git commands: `grep -r "git commit" .opencode/command/ .opencode/agent/subagents/`
2. For each direct git usage:
   - Replace with delegation to git-workflow-manager
   - Pass scope_files, message_template, task_context
   - Handle return status (non-blocking)
3. Test commit creation and error handling

**Benefits**:
- Consistent commit message format
- Centralized error handling
- Scoped commits (no unrelated changes)
- Non-blocking failures

**Expected impact**: More consistent git workflow, better commit messages.

### Recommendation 5: Document Permission Configuration (Low Priority)

**Action**: Create comprehensive guide for configuring agent permissions.

**Steps**:
1. Create `.opencode/docs/guides/permission-configuration.md`
2. Document permission system architecture
3. Provide examples for common agent types
4. Document dangerous operations that must be denied
5. Provide troubleshooting guide for permission denials

**Content**:
- Permission evaluation order (deny → allow → default deny)
- Glob pattern syntax
- Examples by agent type (research, planning, implementation)
- Safety boundaries and rationale
- Debugging permission denials

**Expected impact**: Easier configuration, fewer permission issues.

### Recommendation 6: Add Permission Denial Monitoring (Low Priority)

**Action**: Implement monitoring for permission denials to identify configuration issues.

**Steps**:
1. Ensure all permission denials logged to errors.json
2. Add permission_denial error type
3. Create `/errors` analysis for permission denials
4. Provide recommendations for expanding permissions safely

**Error format**:
```json
{
  "type": "permission_denial",
  "severity": "medium",
  "context": {
    "agent": "researcher",
    "operation": "write",
    "path": "Documentation/Research/report.md"
  },
  "message": "Permission denied: write to Documentation/Research/report.md",
  "recommendation": "Add 'Documentation/**/*' to researcher allow list"
}
```

**Expected impact**: Proactive identification of permission issues.

---

## Risks & Mitigations

### Risk 1: Expanded Permissions Enable Destructive Operations

**Likelihood**: Low  
**Impact**: High  
**Mitigation**:
- Keep dangerous operations in deny list (rm -rf, sudo, etc.)
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
- Test each migration thoroughly
- Maintain backward compatibility during transition
- Document changes in CHANGELOG
- Provide rollback instructions if issues occur

### Risk 4: Increased Autonomy Reduces User Control

**Likelihood**: Low  
**Impact**: Low  
**Mitigation**:
- Git safety provides complete rollback capability
- All operations logged for audit
- User can interrupt with Ctrl+C and run /sync to reset
- Interactive patterns retained where valuable (/meta)

---

## Appendix: Sources and Citations

### Primary Sources

1. **opencode.json** - Project-wide configuration for agents and tools
2. **.opencode/ARCHITECTURE.md** - System architecture and principles
3. **.opencode/README.md** - System overview and quick start
4. **.opencode/context/core/standards/frontmatter-standard.md** - Agent frontmatter specification
5. **.opencode/context/core/standards/git-safety.md** - Git-based safety patterns
6. **.opencode/agent/orchestrator.md** - Orchestrator agent implementation
7. **.opencode/agent/subagents/git-workflow-manager.md** - Git workflow manager implementation
8. **.opencode/QUICK-START.md** - Quick start guide with workflow examples

### Secondary Sources

9. **.opencode/context/core/workflows/sessions.md** - Session management patterns
10. **.opencode/command/sync.md** - Sync command implementation
11. **.opencode/command/todo.md** - Todo command implementation
12. **.opencode/docs/troubleshooting/status-conflicts.md** - Troubleshooting guide

### Search Results

13. `grep -r "backup" .opencode/` - 15 occurrences of backup patterns
14. `grep -r "permission" .opencode/` - 100+ occurrences of permission references
15. `grep -r "autonomous\|autonomy" .opencode/` - 5 occurrences related to agent autonomy

---

## Appendix: Configuration Examples

### Example 1: Research Agent with Expanded Permissions

```yaml
---
name: "researcher"
version: "2.0.0"
description: "General research agent with expanded permissions for autonomous operation"
mode: subagent
agent_type: research
temperature: 0.3
max_tokens: 8000
timeout: 3600
tools:
  - read
  - write
  - bash
  - webfetch
  - grep
  - glob
  - git
permissions:
  allow:
    - read: ["**/*.md", ".opencode/**/*", "Documentation/**/*", "**/*.lean"]
    - write: [".opencode/specs/**/*", "Documentation/Research/**/*"]
    - bash: ["git", "grep", "find", "wc", "jq", "sed", "awk"]
  deny:
    - bash: ["rm -rf", "sudo", "chmod +x", "dd"]
    - write: [".git/**/*", "lakefile.lean", "lean-toolchain"]
    - read: [".env", "**/*.key", "**/*.pem"]
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/workflows/command-lifecycle.md"
    - "core/standards/subagent-return-format.md"
  max_context_size: 50000
delegation:
  max_depth: 3
  can_delegate_to:
    - "status-sync-manager"
    - "git-workflow-manager"
  timeout_default: 1800
  timeout_max: 3600
---
```

### Example 2: Implementation Agent with Git Safety

```yaml
---
name: "implementer"
version: "2.0.0"
description: "Implementation agent with git safety for autonomous operation"
mode: subagent
agent_type: implementation
temperature: 0.2
max_tokens: 4000
timeout: 7200
tools:
  - read
  - write
  - edit
  - bash
  - grep
  - glob
  - git
permissions:
  allow:
    - read: ["**/*"]
    - write: ["**/*.lean", "**/*.md", ".opencode/specs/**/*"]
    - edit: ["**/*.lean", "**/*.md"]
    - bash: ["git", "lake", "grep", "find", "wc", "jq"]
  deny:
    - bash: ["rm -rf", "sudo", "chmod +x", "dd", "wget", "curl"]
    - write: [".git/**/*", "lakefile.lean", "lean-toolchain"]
    - read: [".env", "**/*.key", "**/*.pem"]
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/workflows/command-lifecycle.md"
    - "core/standards/subagent-return-format.md"
    - "core/standards/git-safety.md"
  max_context_size: 50000
delegation:
  max_depth: 3
  can_delegate_to:
    - "status-sync-manager"
    - "git-workflow-manager"
  timeout_default: 3600
  timeout_max: 7200
---
```

### Example 3: Git Safety Pattern in Command

```xml
<stage id="5" name="CreateSafetyCommit">
  <action>Create git safety commit before risky operation</action>
  <process>
    1. Stage files that will be modified:
       ```bash
       git add .opencode/specs/TODO.md
       git add .opencode/specs/state.json
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

<stage id="6" name="ExecuteRiskyOperation">
  <action>Execute risky operation with rollback on failure</action>
  <process>
    1. Execute operation (modify files, move directories, etc.)
    2. If operation fails:
       - Execute git rollback:
         ```bash
         git reset --hard $safety_commit
         git clean -fd
         ```
       - Log rollback to errors.json
       - Return error to user with rollback confirmation
    3. If operation succeeds:
       - Proceed to final commit
  </process>
  <checkpoint>Operation executed or rolled back</checkpoint>
</stage>

<stage id="7" name="CreateFinalCommit">
  <action>Delegate to git-workflow-manager for final commit</action>
  <process>
    1. Prepare delegation context:
       - scope_files: [modified files]
       - message_template: "{operation}: {description}"
       - task_context: {operation, description}
       - session_id: {session_id}
       - delegation_depth: {depth + 1}
       - delegation_path: [...delegation_path, "git-workflow-manager"]
    2. Invoke git-workflow-manager with timeout (300s)
    3. Validate return status (completed or failed)
    4. If status == "failed": Log warning (non-critical)
    5. Continue (operation already succeeded)
  </process>
  <checkpoint>Final commit created or logged</checkpoint>
</stage>
```

---

## Conclusion

The OpenCode system already has a sophisticated architecture for autonomous operation with git-based safety. The primary configuration changes needed are:

1. **Complete git safety migration** - Remove remaining backup file patterns
2. **Expand agent permissions** - Update frontmatter allow lists where safe
3. **Remove confirmation prompts** - Replace with git safety commits
4. **Standardize git workflow** - Ensure all commands use git-workflow-manager

These changes will increase agent autonomy while maintaining safety through git commits as the sole safety mechanism. The system's existing delegation safety, timeout enforcement, and error tracking provide additional layers of protection.

Implementation should proceed incrementally, testing each change thoroughly and monitoring for permission denials or unexpected behavior. The git safety pattern provides complete rollback capability, making it safe to expand agent permissions within defined boundaries.
