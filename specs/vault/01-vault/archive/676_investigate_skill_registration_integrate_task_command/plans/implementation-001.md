# Implementation Plan: Task #676

- **Task**: 676 - Investigate skill registration and integrate /task command with checkpoint pattern
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Priority**: High
- **Dependencies**: Coordinate with Tasks 674, 675, 677
- **Research Inputs**:
  - specs/676_investigate_skill_registration_integrate_task_command/reports/research-001.md
  - specs/676_investigate_skill_registration_integrate_task_command/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan addresses preflight/postflight integration improvements across the .claude/ agent system, leveraging Claude Code 2026 features discovered in research. The key insight from research-002.md is that commands and skills merged in January 2026 - `.claude/commands/*.md` files ARE skills with optional bash preflight. The `.opencode/` directory is a legacy OpenCode installation causing confusion that should be archived. This plan implements skill-scoped hooks for checkpoint enforcement, completes the OpenCode to Claude Code migration, and documents the 2026 architecture.

### Research Integration

**From research-001.md**:
- All 13 skills in `.claude/skills/` are properly registered with valid YAML frontmatter
- Commands are bash scripts that bypass the Skill tool entirely
- `/task` command lacks a skill wrapper (unlike /research, /plan, /implement)
- Checkpoint pattern exists in documentation but lacks architectural enforcement

**From research-002.md**:
- Commands and skills merged in Claude Code Jan 2026 - same files, dual functionality
- `.opencode/` is legacy OpenCode installation (package v1.1.25), not current system
- Skill hot-reload eliminates registration issues (changes are instant)
- Context forking (`context: fork`) enables subagent isolation for checkpoints
- Skill-scoped hooks can enforce checkpoint pattern at skill level

## Goals & Non-Goals

**Goals**:
- Archive `.opencode/` legacy system to eliminate dual-system confusion
- Implement skill-scoped hooks for checkpoint enforcement on /task command
- Document the 2026 commands-as-skills architecture in CLAUDE.md
- Establish pattern for other commands to adopt (coordinate with Tasks 674, 675)
- Validate that checkpoint hooks execute and enforce GATE IN/GATE OUT boundaries

**Non-Goals**:
- Full refactor of all commands (that's Task 674's scope)
- Implementing `context: fork` pattern (blocked by GitHub #16803 per Task 619)
- Removing bash from commands entirely (2026 architecture supports bash preflight)
- Decomposing CLAUDE.md into smaller skills (that's a separate optimization)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking changes from .opencode removal | Medium | Medium | Grep for .opencode references first, update all paths before archiving |
| Skill hooks may not work as documented | Medium | Low | Prototype with /task first, test thoroughly before applying to other commands |
| Coordination gaps with Tasks 674, 675 | Medium | Medium | Document shared patterns, ensure this task creates reusable hook scripts |
| Incomplete migration leaves dangling refs | Low | Medium | Create validation script to detect remaining .opencode references |

## Implementation Phases

### Phase 1: Archive .opencode Legacy System [NOT STARTED]

**Goal**: Eliminate dual-system confusion by archiving .opencode/ to a dated backup directory

**Tasks**:
- [ ] Search entire codebase for `.opencode/` references using Grep
- [ ] Document all files containing .opencode references
- [ ] Update all discovered references to point to `.claude/` equivalents
- [ ] Create archive directory `archive/opencode-legacy-20260125/`
- [ ] Move `.opencode/` and `.opencode_OLD/` to archive
- [ ] Add archive/ to appropriate documentation
- [ ] Verify no broken paths remain in active codebase

**Timing**: 1.5 hours

**Files to modify**:
- Any files containing `.opencode/` references (to be discovered)
- `.gitignore` - ensure archive/ is appropriately handled

**Verification**:
- `grep -r ".opencode" --include="*.md" --include="*.sh" --include="*.py"` returns no results from active codebase
- All commands still function after archival
- Git status shows clean migration without lost functionality

---

### Phase 2: Create Checkpoint Hook Infrastructure [NOT STARTED]

**Goal**: Establish reusable hook scripts for checkpoint pattern enforcement

**Tasks**:
- [ ] Create `.claude/hooks/` directory for hook scripts
- [ ] Create `checkpoint-gate-in.sh` script with:
  - Session ID generation
  - Task existence validation (reads state.json)
  - Status transition validation
  - Preflight status update execution
- [ ] Create `checkpoint-gate-out.sh` script with:
  - Return metadata file validation
  - Artifact existence verification
  - Postflight status update execution
  - Git commit preparation
- [ ] Create `checkpoint-commit.sh` for standardized git commits with session ID
- [ ] Document hook contract in `.claude/context/core/patterns/checkpoint-hooks.md`

**Timing**: 2 hours

**Files to create**:
- `.claude/hooks/checkpoint-gate-in.sh`
- `.claude/hooks/checkpoint-gate-out.sh`
- `.claude/hooks/checkpoint-commit.sh`
- `.claude/context/core/patterns/checkpoint-hooks.md`

**Verification**:
- Scripts are executable and return correct exit codes
- Gate-in validates task existence and status
- Gate-out validates return metadata file exists
- All scripts handle error cases gracefully

---

### Phase 3: Update /task Command with Hook Integration [NOT STARTED]

**Goal**: Add skill-scoped hooks to /task command following 2026 best practices

**Tasks**:
- [ ] Add `hooks:` section to `.claude/commands/task.md` frontmatter
- [ ] Configure PreToolUse hook to call checkpoint-gate-in.sh
- [ ] Configure PostToolUse hook to call checkpoint-gate-out.sh
- [ ] Update /task bash code to generate session_id and pass through delegation
- [ ] Ensure /task modes (create, recover, expand, sync, abandon, review) all respect hooks
- [ ] Add return metadata file writing to task completion paths
- [ ] Test each /task mode with hooks active

**Timing**: 2 hours

**Files to modify**:
- `.claude/commands/task.md` - Add hooks frontmatter and update bash code

**Verification**:
- `/task "Test task"` creates task with session_id in commit
- `/task --sync` executes with gate-in/gate-out hooks
- `/task --abandon N` updates state.json with session tracking
- All modes produce consistent checkpoint behavior

---

### Phase 4: Update CLAUDE.md Architecture Documentation [NOT STARTED]

**Goal**: Document the 2026 commands-as-skills architecture and checkpoint hook pattern

**Tasks**:
- [ ] Add "Claude Code 2026 Architecture" section explaining commands-skills merge
- [ ] Document that `.claude/commands/*.md` files ARE skills with bash preflight
- [ ] Explain skill-scoped hooks for checkpoint enforcement
- [ ] Update "Skill Architecture" section to reflect 2026 patterns
- [ ] Add reference to checkpoint-hooks.md pattern documentation
- [ ] Note that .opencode/ was legacy OpenCode (now archived)
- [ ] Update session tracking documentation with hook integration

**Timing**: 1 hour

**Files to modify**:
- `.claude/CLAUDE.md`

**Verification**:
- New sections accurately reflect 2026 architecture
- Examples match actual implementation
- References to archived .opencode/ are historical context only

---

### Phase 5: Create Validation and Testing [NOT STARTED]

**Goal**: Ensure checkpoint pattern is enforced and migration is complete

**Tasks**:
- [ ] Create `scripts/validate-checkpoint-hooks.sh` that:
  - Tests each /task mode with hook execution
  - Verifies return metadata file creation
  - Checks session_id propagation
  - Validates git commit format
- [ ] Create `scripts/detect-opencode-refs.sh` that:
  - Scans codebase for any remaining .opencode references
  - Reports findings with file:line format
  - Returns non-zero exit if references found
- [ ] Run validation scripts and fix any issues discovered
- [ ] Document test results in implementation summary

**Timing**: 1.5 hours

**Files to create**:
- `.claude/scripts/validate-checkpoint-hooks.sh`
- `.claude/scripts/detect-opencode-refs.sh`

**Verification**:
- Both validation scripts pass without errors
- Checkpoint hooks execute on all /task operations
- No .opencode references remain in active codebase
- Git commits include session_id

## Testing & Validation

- [ ] All /task modes work correctly with checkpoint hooks
- [ ] Return metadata files are created and cleaned up properly
- [ ] Session IDs propagate through entire operation chain
- [ ] Git commits include session_id in standardized format
- [ ] No .opencode references remain in active codebase
- [ ] CLAUDE.md accurately documents 2026 architecture
- [ ] Hook scripts handle error cases without breaking commands
- [ ] Validation scripts provide clear pass/fail feedback

## Artifacts & Outputs

- `.claude/hooks/checkpoint-gate-in.sh` - Preflight validation hook
- `.claude/hooks/checkpoint-gate-out.sh` - Postflight validation hook
- `.claude/hooks/checkpoint-commit.sh` - Standardized commit hook
- `.claude/context/core/patterns/checkpoint-hooks.md` - Hook pattern documentation
- `.claude/scripts/validate-checkpoint-hooks.sh` - Checkpoint validation script
- `.claude/scripts/detect-opencode-refs.sh` - Migration validation script
- `archive/opencode-legacy-20260125/` - Archived legacy system
- `specs/676_investigate_skill_registration_integrate_task_command/summaries/implementation-summary-YYYYMMDD.md` - Implementation summary

## Rollback/Contingency

If checkpoint hooks cause command failures:
1. Remove `hooks:` section from `.claude/commands/task.md` frontmatter
2. Hook scripts remain available but inactive
3. Commands revert to pre-hook behavior

If .opencode archival breaks functionality:
1. Move contents from `archive/opencode-legacy-20260125/` back to project root
2. Restore as `.opencode/` and `.opencode_OLD/`
3. Revert any path reference changes

Git branch strategy:
- Create feature branch before Phase 1
- Commit after each phase for granular rollback
- Merge to main only after all validation passes

## Coordination Notes

**Task 674** (Systematic command-skill-agent architecture improvement):
- This task creates the reusable hook infrastructure
- Task 674 can apply same hooks to /research, /plan, /implement

**Task 675** (Enforce skill postflight checkpoint pattern):
- This task implements the enforcement mechanism via hooks
- Task 675 validates that enforcement works across the system

**Task 677** (Study preflight/postflight patterns for improvements):
- Research from Task 677 should inform any refinements to hooks
- This task implements initial pattern that Task 677 can evaluate
