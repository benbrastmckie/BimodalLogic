# Implementation Plan: Task #534 (Revised v004)

- **Task**: 534 - Comprehensive protocol/.claude/ Agent System Upgrade
- **Version**: 004
- **Status**: [NOT STARTED]
- **Effort**: 2.5-3 hours
- **Priority**: High
- **Dependencies**: Tasks 548, 563, 564 completed in ProofChecker
- **Research Inputs**:
  - specs/534_research_claude_code_model_selection/reports/research-001.md
  - specs/564_memory_issues_status_sync_agent/plans/implementation-003.md
  - specs/563_investigate_empty_directory_creation/plans/implementation-001.md
  - specs/archive/548_fix_skill_to_agent_delegation_pattern/plans/implementation-001.md
- **Previous Plans**: implementation-001.md, implementation-002.md, implementation-003.md
- **Revision Reason**: Include Task 563 (lazy directory creation) and Task 548 (CRITICAL Task tool directives) changes
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This comprehensive plan upgrades `protocol/.claude/` with all performance improvements from ProofChecker:

| Source Task | Change | Impact |
|-------------|--------|--------|
| 534 | Add model fields to agents | Explicit model selection |
| 548 | Add CRITICAL Task tool directives | Fix skill→agent delegation |
| 563 | Remove eager directory creation | Fix lazy creation violation |
| 564 | Verify direct execution status-sync | Prevent memory exhaustion |

### Current State Assessment (2026-01-17)

**Protocol/.claude/ Analysis**:

| Component | Current State | Action Needed |
|-----------|---------------|---------------|
| Agent model fields | ❌ Missing | Add to all 6 agents |
| CRITICAL Task directives | ❌ Missing | Add to 6 forked skills |
| Eager mkdir in task.md | ❌ Present (line 64) | Remove |
| Eager mkdir in meta-builder-agent | ❌ Present (lines 330, 482) | Remove |
| skill-status-sync | ✅ Direct execution | Verify only |
| status-sync-agent | ✅ Does not exist | None |

**Forked skills needing CRITICAL directive** (6 total):
1. `skill-researcher/SKILL.md` → general-research-agent
2. `skill-planner/SKILL.md` → planner-agent
3. `skill-implementer/SKILL.md` → general-implementation-agent
4. `skill-latex-implementation/SKILL.md` → latex-implementation-agent
5. `skill-meta/SKILL.md` → meta-builder-agent
6. `skill-document-converter/SKILL.md` → document-converter-agent

## Goals & Non-Goals

**Goals**:
- Add `model: sonnet` to all 6 protocol agents
- Add CRITICAL Task tool directives to all 6 forked skills
- Remove eager directory creation from task.md and meta-builder-agent.md
- Update CLAUDE.md with model documentation
- Update thin-wrapper-skill.md template (if exists)
- Update state-management.md documentation (if exists)
- Verify skill-status-sync direct execution pattern

**Non-Goals**:
- Adding Lean agents (not needed in protocol)
- Cleaning up empty directories (run separately if needed)
- Modifying archive operations (mkdir needed for moves)

## Implementation Phases

### Phase 1: Add Model Fields to Agents [COMPLETED]

**Goal**: Add explicit `model` field to all 6 agents

**Timing**: 30 minutes

**Tasks**:

- [ ] **1.1** Edit `agents/document-converter-agent.md`:
  ```yaml
  ---
  name: document-converter-agent
  description: ...
  model: sonnet  # ADD after description
  ---
  ```

- [ ] **1.2** Edit `agents/general-implementation-agent.md` - add `model: sonnet`

- [ ] **1.3** Edit `agents/general-research-agent.md` - add `model: sonnet`

- [ ] **1.4** Edit `agents/latex-implementation-agent.md` - add `model: sonnet`

- [ ] **1.5** Edit `agents/meta-builder-agent.md` - add `model: sonnet`

- [ ] **1.6** Edit `agents/planner-agent.md` - add `model: sonnet`

**Verification**:
```bash
grep -l "^model:" /home/benjamin/Projects/protocol/.claude/agents/*.md | wc -l
# Expected: 6
```

---

### Phase 2: Add CRITICAL Task Tool Directives to Forked Skills [COMPLETED]

**Goal**: Add explicit Task tool invocation directives to prevent Skill() misuse

**Timing**: 45 minutes

**Template to add to each skill** (after ## Execution or equivalent section):

```markdown
## CRITICAL: Subagent Invocation

**You MUST use the Task tool to invoke the subagent.**

**Tool**: `Task`
**Parameters**:
- `subagent_type`: "{agent-name}"
- `description`: "{brief 3-5 word description}"
- `prompt`: "{delegation context from above}"

**DO NOT use the Skill tool** to invoke agents. Skills and agents are in different directories:
- Skills: `.claude/skills/` → invoked via Skill tool
- Agents: `.claude/agents/` → invoked via Task tool

Using Skill() for an agent will fail because Claude Code looks in the wrong directory.
```

**Tasks**:

- [ ] **2.1** Edit `skills/skill-researcher/SKILL.md`:
  - Add CRITICAL section with `subagent_type: "general-research-agent"`

- [ ] **2.2** Edit `skills/skill-planner/SKILL.md`:
  - Add CRITICAL section with `subagent_type: "planner-agent"`

- [ ] **2.3** Edit `skills/skill-implementer/SKILL.md`:
  - Add CRITICAL section with `subagent_type: "general-implementation-agent"`

- [ ] **2.4** Edit `skills/skill-latex-implementation/SKILL.md`:
  - Add CRITICAL section with `subagent_type: "latex-implementation-agent"`

- [ ] **2.5** Edit `skills/skill-meta/SKILL.md`:
  - Add CRITICAL section with `subagent_type: "meta-builder-agent"`

- [ ] **2.6** Edit `skills/skill-document-converter/SKILL.md`:
  - Add CRITICAL section with `subagent_type: "document-converter-agent"`

**Verification**:
```bash
# All 6 forked skills should have CRITICAL directive
grep -l "CRITICAL.*Subagent" /home/benjamin/Projects/protocol/.claude/skills/*/SKILL.md | wc -l
# Expected: 6

# All should have DO NOT warning
grep -l "DO NOT.*Skill tool" /home/benjamin/Projects/protocol/.claude/skills/*/SKILL.md | wc -l
# Expected: 6
```

---

### Phase 3: Remove Eager Directory Creation [COMPLETED]

**Goal**: Eliminate `mkdir -p specs/{N}_{SLUG}` from task creation paths

**Timing**: 30 minutes

**Tasks**:

- [ ] **3.1** Edit `commands/task.md`:
  - Remove step 5 (line ~64): `mkdir -p specs/{NUMBER}_{SLUG}`
  - Renumber subsequent steps
  - Remove "Path: specs/{N}_{SLUG}/" from output section

- [ ] **3.2** Edit `agents/meta-builder-agent.md`:
  - Remove line 330: `mkdir -p "specs/${next_num}_${slug}"`
  - Remove line 482: `mkdir -p specs/{NNN}_{slug}`
  - Keep artifact subdirectory creation (reports/, plans/, summaries/) - those are correct

- [ ] **3.3** Update `rules/state-management.md` (if exists):
  - Add explicit "DO NOT create directories at task creation time"
  - Clarify lazy creation: "Directories are created when first artifact is written"

**Verification**:
```bash
# No eager mkdir in task.md or meta-builder-agent.md
grep "mkdir.*specs/\${.*}$" /home/benjamin/Projects/protocol/.claude/commands/task.md
grep "mkdir.*specs/\${.*}$" /home/benjamin/Projects/protocol/.claude/agents/meta-builder-agent.md
# Expected: no output (empty)

# Artifact subdirectory mkdir should still exist (correct)
grep -c "mkdir.*reports/\|mkdir.*plans/\|mkdir.*summaries/" /home/benjamin/Projects/protocol/.claude/agents/*.md
# Expected: some matches (this is correct behavior)
```

---

### Phase 4: Update Documentation [COMPLETED]

**Goal**: Update CLAUDE.md and template files

**Timing**: 30 minutes

**Tasks**:

- [ ] **4.1** Update `CLAUDE.md` Skill-to-Agent mapping table:
  ```markdown
  | Skill | Agent | Model | Purpose |
  |-------|-------|-------|---------|
  | skill-researcher | general-research-agent | sonnet | General web/codebase research |
  | skill-planner | planner-agent | sonnet | Implementation plan creation |
  | skill-implementer | general-implementation-agent | sonnet | General file implementation |
  | skill-latex-implementation | latex-implementation-agent | sonnet | LaTeX document implementation |
  | skill-meta | meta-builder-agent | sonnet | System building and task creation |
  | skill-status-sync | (direct execution) | - | Atomic status updates |
  | skill-document-converter | document-converter-agent | sonnet | Document format conversion |
  ```

- [ ] **4.2** Add Model Selection section to CLAUDE.md:
  ```markdown
  ### Model Selection

  Agents specify their model via YAML frontmatter:

  ```yaml
  ---
  name: agent-name
  description: Agent description
  model: sonnet  # sonnet | opus | haiku | inherit
  ---
  ```

  **Supported Values**:
  - `sonnet` - Claude Sonnet (default, balanced cost/capability)
  - `opus` - Claude Opus (highest capability, complex tasks)
  - `haiku` - Claude Haiku (fast, low-cost; caution: tool_reference limitation)
  - `inherit` - Uses parent conversation model

  **Note**: The Task tool's `model` parameter has a known bug (#12063). Prefer frontmatter specification.
  ```

- [ ] **4.3** Update `context/core/templates/thin-wrapper-skill.md` (if exists):
  - Add CRITICAL Task tool directive pattern
  - Add DO NOT warning about Skill tool
  - Add explanation of directory mapping

**Verification**:
- CLAUDE.md contains Model Selection section
- CLAUDE.md Skill-to-Agent table has Model column
- Template (if exists) has CRITICAL pattern

---

### Phase 5: Verify skill-status-sync Configuration [COMPLETED]

**Goal**: Confirm direct execution pattern (from Task 564)

**Timing**: 10 minutes

**Tasks**:

- [ ] **5.1** Verify NO forked pattern:
  ```bash
  grep -E "^(context: fork|agent:)" \
    /home/benjamin/Projects/protocol/.claude/skills/skill-status-sync/SKILL.md
  # Expected: no output
  ```

- [ ] **5.2** Verify HAS allowed-tools:
  ```bash
  grep "^allowed-tools:" \
    /home/benjamin/Projects/protocol/.claude/skills/skill-status-sync/SKILL.md
  # Expected: allowed-tools: Read, Write, Edit, Bash
  ```

- [ ] **5.3** Verify no status-sync-agent references:
  ```bash
  grep -r "status-sync-agent" /home/benjamin/Projects/protocol/.claude/
  # Expected: no output
  ```

**Verification**:
- skill-status-sync uses direct execution (not forked)
- No status-sync-agent exists

---

### Phase 6: Final Verification and Commit [IN PROGRESS]

**Goal**: Comprehensive verification and git commit

**Timing**: 20 minutes

**Tasks**:

- [ ] **6.1** Run full verification suite:
  ```bash
  cd /home/benjamin/Projects/protocol

  echo "=== 1. Agent model fields ==="
  for f in .claude/agents/*.md; do
    if ! grep -q "^model:" "$f"; then
      echo "MISSING: $f"
    fi
  done

  echo "=== 2. CRITICAL directives in forked skills ==="
  for skill in researcher planner implementer latex-implementation meta document-converter; do
    if ! grep -q "CRITICAL" ".claude/skills/skill-${skill}/SKILL.md" 2>/dev/null; then
      echo "MISSING: skill-${skill}"
    fi
  done

  echo "=== 3. No eager mkdir ==="
  grep "mkdir.*specs/\${" .claude/commands/task.md .claude/agents/meta-builder-agent.md && echo "FOUND!" || echo "OK"

  echo "=== 4. No status-sync-agent ==="
  grep -r "status-sync-agent" .claude/ && echo "FOUND!" || echo "OK"

  echo "=== 5. CLAUDE.md updated ==="
  grep -q "Model Selection" .claude/CLAUDE.md && echo "OK" || echo "MISSING"
  ```

- [ ] **6.2** Stage and review changes:
  ```bash
  git add .claude/
  git diff --cached --stat
  ```

- [ ] **6.3** Commit:
  ```bash
  git commit -m "$(cat <<'EOF'
  chore: comprehensive .claude/ agent system upgrade

  Based on ProofChecker improvements from tasks 534, 548, 563, 564:

  Model Selection (Task 534):
  - Add model: sonnet to all 6 agents
  - Add Model Selection documentation to CLAUDE.md
  - Add Model column to Skill-to-Agent mapping table

  Skill Delegation Fix (Task 548):
  - Add CRITICAL Task tool directives to all 6 forked skills
  - Add DO NOT warnings about Skill tool misuse
  - Update thin-wrapper template (if exists)

  Lazy Directory Creation (Task 563):
  - Remove mkdir from task.md step 5
  - Remove mkdir from meta-builder-agent.md lines 330, 482
  - Directories now created only when artifacts are written

  Direct Execution Verification (Task 564):
  - Confirmed skill-status-sync uses direct execution
  - No status-sync-agent exists (correct)

  Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
  EOF
  )"
  ```

**Verification**:
- All 6 checks pass
- Git commit successful

---

## Summary of Changes

### Files to Modify in protocol/.claude/

| Category | File | Change |
|----------|------|--------|
| Agents | `agents/document-converter-agent.md` | Add `model: sonnet` |
| Agents | `agents/general-implementation-agent.md` | Add `model: sonnet` |
| Agents | `agents/general-research-agent.md` | Add `model: sonnet` |
| Agents | `agents/latex-implementation-agent.md` | Add `model: sonnet` |
| Agents | `agents/meta-builder-agent.md` | Add `model: sonnet`, remove mkdir lines 330, 482 |
| Agents | `agents/planner-agent.md` | Add `model: sonnet` |
| Skills | `skills/skill-researcher/SKILL.md` | Add CRITICAL directive |
| Skills | `skills/skill-planner/SKILL.md` | Add CRITICAL directive |
| Skills | `skills/skill-implementer/SKILL.md` | Add CRITICAL directive |
| Skills | `skills/skill-latex-implementation/SKILL.md` | Add CRITICAL directive |
| Skills | `skills/skill-meta/SKILL.md` | Add CRITICAL directive |
| Skills | `skills/skill-document-converter/SKILL.md` | Add CRITICAL directive |
| Commands | `commands/task.md` | Remove mkdir step |
| Docs | `CLAUDE.md` | Add Model column, Model Selection section |
| Templates | `context/core/templates/thin-wrapper-skill.md` | Add CRITICAL pattern (if exists) |
| Rules | `rules/state-management.md` | Add lazy creation guidance (if exists) |

### No Changes Needed

| Component | Reason |
|-----------|--------|
| `skill-status-sync/SKILL.md` | Already direct execution |
| `status-sync-agent.md` | Does not exist (correct) |
| Archive mkdir operations | Needed for task moves |

## Testing & Validation

- [ ] All 6 agents have `model: sonnet`
- [ ] All 6 forked skills have CRITICAL directive
- [ ] All 6 forked skills have DO NOT warning
- [ ] No eager mkdir in task.md or meta-builder-agent.md
- [ ] skill-status-sync uses direct execution
- [ ] No status-sync-agent references
- [ ] CLAUDE.md has Model Selection section
- [ ] Git commit successful

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| CRITICAL directive placement wrong | High | Low | Follow ProofChecker examples exactly |
| mkdir removal breaks something | Low | Low | Agents already create subdirs for artifacts |
| Model field syntax error | High | Low | Use exact YAML from ProofChecker |
| Cached sessions use old context | Medium | High | Document: start fresh sessions after fix |

## Artifacts & Outputs

**This task produces**:
- 6 modified agent files (model field)
- 6 modified skill files (CRITICAL directive)
- 2 modified files (task.md, meta-builder-agent.md - mkdir removal)
- 1 modified CLAUDE.md
- Optional: template and rules updates
- Git commit in protocol/

**Reference materials**:
- ProofChecker specs/534_research_claude_code_model_selection/reports/research-001.md
- ProofChecker specs/564_memory_issues_status_sync_agent/plans/implementation-003.md
- ProofChecker specs/563_investigate_empty_directory_creation/plans/implementation-001.md
- ProofChecker specs/archive/548_fix_skill_to_agent_delegation_pattern/plans/implementation-001.md

## Rollback/Contingency

If any issues arise:
```bash
cd /home/benjamin/Projects/protocol
git checkout HEAD~1 -- .claude/
```

Changes are documentation/configuration only - straightforward git revert.
