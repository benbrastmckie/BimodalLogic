# Implementation Plan: Task #534 (Revised v003)

- **Task**: 534 - Upgrade protocol/.claude/ Agent System
- **Version**: 003
- **Status**: [NOT STARTED]
- **Effort**: 1.5-2 hours
- **Priority**: High
- **Dependencies**: Task 564 completed (status-sync-agent removal)
- **Research Inputs**:
  - specs/534_research_claude_code_model_selection/reports/research-001.md
  - specs/564_memory_issues_status_sync_agent/plans/implementation-003.md
- **Previous Plans**: implementation-001.md, implementation-002.md
- **Revision Reason**: Create detailed actionable plan to carry out the upgrade on protocol/.claude/
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan provides detailed, actionable steps to upgrade the `protocol/.claude/` agent system based on:
1. **Model selection research** (Task 534 research-001.md) - Add model fields to agents
2. **Task 564 changes** - Already partially applied (skill-status-sync is direct execution)

### Current State Assessment

**Protocol/.claude/ Analysis (2026-01-17)**:

| Component | Status | Action Needed |
|-----------|--------|---------------|
| `skill-status-sync` | ✅ Direct execution | None - already converted |
| `status-sync-agent` | ✅ Does not exist | None - never existed |
| Agent model fields | ❌ Missing | Add to all 6 agents |
| CLAUDE.md model docs | ❌ Missing | Add model column to table |

**Agents in protocol/.claude/agents/**:
1. `document-converter-agent.md`
2. `general-implementation-agent.md`
3. `general-research-agent.md`
4. `latex-implementation-agent.md`
5. `meta-builder-agent.md`
6. `planner-agent.md`

Note: Protocol does NOT have lean-research-agent or lean-implementation-agent (those are Lean-specific).

## Goals & Non-Goals

**Goals**:
- Add `model` field to all 6 protocol agents
- Update CLAUDE.md with model field documentation
- Verify skill-status-sync is properly configured
- Ensure full consistency with ProofChecker/.claude/ patterns

**Non-Goals**:
- Adding Lean agents to protocol (not needed for this project)
- Restructuring the agent architecture
- Changing skill behavior (already correct)

## Implementation Phases

### Phase 1: Add Model Fields to Agents [NOT STARTED]

**Goal**: Add explicit `model` field to all 6 agents in protocol/.claude/agents/

**Timing**: 30 minutes

**Model Assignments**:

| Agent | Model | Rationale |
|-------|-------|-----------|
| `document-converter-agent` | `sonnet` | Standard file operations |
| `general-implementation-agent` | `sonnet` | General file operations |
| `general-research-agent` | `sonnet` | Web search + synthesis |
| `latex-implementation-agent` | `sonnet` | Template-based work |
| `meta-builder-agent` | `sonnet` | Complex multi-turn interview |
| `planner-agent` | `sonnet` | Structured planning |

**Tasks**:

- [ ] **1.1** Edit `document-converter-agent.md` frontmatter:
  ```yaml
  ---
  name: document-converter-agent
  description: ...
  model: sonnet  # ADD THIS LINE
  ---
  ```

- [ ] **1.2** Edit `general-implementation-agent.md` frontmatter:
  ```yaml
  ---
  name: general-implementation-agent
  description: ...
  model: sonnet  # ADD THIS LINE
  ---
  ```

- [ ] **1.3** Edit `general-research-agent.md` frontmatter:
  ```yaml
  ---
  name: general-research-agent
  description: ...
  model: sonnet  # ADD THIS LINE
  ---
  ```

- [ ] **1.4** Edit `latex-implementation-agent.md` frontmatter:
  ```yaml
  ---
  name: latex-implementation-agent
  description: ...
  model: sonnet  # ADD THIS LINE
  ---
  ```

- [ ] **1.5** Edit `meta-builder-agent.md` frontmatter:
  ```yaml
  ---
  name: meta-builder-agent
  description: ...
  model: sonnet  # ADD THIS LINE
  ---
  ```

- [ ] **1.6** Edit `planner-agent.md` frontmatter:
  ```yaml
  ---
  name: planner-agent
  description: ...
  model: sonnet  # ADD THIS LINE
  ---
  ```

**Verification**:
```bash
# All 6 agents should have model field
grep -l "^model:" /home/benjamin/Projects/protocol/.claude/agents/*.md | wc -l
# Expected: 6
```

---

### Phase 2: Update CLAUDE.md Documentation [NOT STARTED]

**Goal**: Add model documentation to protocol CLAUDE.md

**Timing**: 20 minutes

**Tasks**:

- [ ] **2.1** Find the Skill-to-Agent Mapping table in `/home/benjamin/Projects/protocol/.claude/CLAUDE.md`

- [ ] **2.2** Add Model column to the table:
  ```markdown
  ### Skill-to-Agent Mapping

  | Skill | Agent | Model | Purpose |
  |-------|-------|-------|---------|
  | skill-researcher | general-research-agent | sonnet | General web/codebase research |
  | skill-planner | planner-agent | sonnet | Implementation plan creation |
  | skill-implementer | general-implementation-agent | sonnet | General file implementation |
  | skill-latex-implementation | latex-implementation-agent | sonnet | LaTeX document implementation |
  | skill-meta | meta-builder-agent | sonnet | System building and task creation |
  | skill-status-sync | (direct execution) | - | Atomic status updates for task state |
  | skill-document-converter | document-converter-agent | sonnet | Document format conversion |
  ```

- [ ] **2.3** Add Model Selection section (after Skill Architecture or Custom Agent Registration):
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
  - `opus` - Claude Opus (highest capability, reserved for complex tasks)
  - `haiku` - Claude Haiku (fast, low-cost; caution: tool_reference limitation)
  - `inherit` - Uses parent conversation model

  **Note**: The Task tool's `model` parameter has a known bug (#12063) where it may be ignored. Prefer frontmatter specification.
  ```

**Verification**:
- CLAUDE.md contains "model: sonnet" in documentation
- Skill-to-Agent table includes Model column

---

### Phase 3: Verify skill-status-sync Configuration [NOT STARTED]

**Goal**: Confirm skill-status-sync is correctly configured as direct execution

**Timing**: 10 minutes

**Tasks**:

- [ ] **3.1** Verify frontmatter does NOT have `context: fork` or `agent:` fields:
  ```bash
  grep -E "^(context: fork|agent:)" \
    /home/benjamin/Projects/protocol/.claude/skills/skill-status-sync/SKILL.md
  # Expected: no output (empty result)
  ```

- [ ] **3.2** Verify frontmatter HAS `allowed-tools`:
  ```bash
  grep "^allowed-tools:" \
    /home/benjamin/Projects/protocol/.claude/skills/skill-status-sync/SKILL.md
  # Expected: allowed-tools: Read, Write, Edit, Bash
  ```

- [ ] **3.3** Verify no status-sync-agent references anywhere:
  ```bash
  grep -r "status-sync-agent" /home/benjamin/Projects/protocol/.claude/
  # Expected: no output (empty result)
  ```

**Verification**:
- All three checks pass
- skill-status-sync operates in direct execution mode

---

### Phase 4: Cross-Repository Consistency Check [NOT STARTED]

**Goal**: Verify protocol/.claude/ matches ProofChecker/.claude/ patterns

**Timing**: 15 minutes

**Tasks**:

- [ ] **4.1** Compare skill-status-sync structure:
  ```bash
  diff <(head -10 /home/benjamin/Projects/ProofChecker/.claude/skills/skill-status-sync/SKILL.md) \
       <(head -10 /home/benjamin/Projects/protocol/.claude/skills/skill-status-sync/SKILL.md)
  # Frontmatter should be similar (direct execution pattern)
  ```

- [ ] **4.2** Verify shared agents have consistent model assignments:
  ```bash
  # Both repos should have these agents with sonnet:
  for agent in general-implementation-agent general-research-agent \
               latex-implementation-agent meta-builder-agent planner-agent; do
    echo "=== $agent ==="
    grep "^model:" /home/benjamin/Projects/ProofChecker/.claude/agents/${agent}.md 2>/dev/null
    grep "^model:" /home/benjamin/Projects/protocol/.claude/agents/${agent}.md 2>/dev/null
  done
  ```

- [ ] **4.3** Document any intentional differences:
  - ProofChecker has lean-research-agent (model: opus) - not needed in protocol
  - ProofChecker has lean-implementation-agent (model: opus) - not needed in protocol

**Verification**:
- Shared agents have identical model assignments
- Differences are documented and intentional

---

### Phase 5: Final Verification and Commit [NOT STARTED]

**Goal**: Verify all changes and commit

**Timing**: 15 minutes

**Tasks**:

- [ ] **5.1** Run full verification suite:
  ```bash
  # 1. All agents have model field
  echo "Checking agent model fields..."
  for f in /home/benjamin/Projects/protocol/.claude/agents/*.md; do
    if ! grep -q "^model:" "$f"; then
      echo "MISSING: $f"
    fi
  done

  # 2. No status-sync-agent references
  echo "Checking for status-sync-agent references..."
  grep -r "status-sync-agent" /home/benjamin/Projects/protocol/.claude/ && echo "FOUND!" || echo "OK"

  # 3. CLAUDE.md updated
  echo "Checking CLAUDE.md..."
  grep -q "Model Selection" /home/benjamin/Projects/protocol/.claude/CLAUDE.md && echo "OK" || echo "MISSING"
  ```

- [ ] **5.2** Stage changes:
  ```bash
  cd /home/benjamin/Projects/protocol
  git add .claude/
  git status
  ```

- [ ] **5.3** Commit with message:
  ```bash
  git commit -m "$(cat <<'EOF'
  chore: add model fields to agents and update documentation

  - Add model: sonnet to all 6 agents
  - Update CLAUDE.md with model selection documentation
  - Add Model column to Skill-to-Agent mapping table
  - Verify skill-status-sync direct execution pattern

  Based on ProofChecker tasks 534 (model selection research) and 564
  (status-sync-agent removal).

  Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
  EOF
  )"
  ```

**Verification**:
- All agents have model field
- No status-sync-agent references
- CLAUDE.md updated with model documentation
- Git commit successful

---

## Summary of Changes

### Files to Modify in protocol/.claude/

| File | Change |
|------|--------|
| `agents/document-converter-agent.md` | Add `model: sonnet` |
| `agents/general-implementation-agent.md` | Add `model: sonnet` |
| `agents/general-research-agent.md` | Add `model: sonnet` |
| `agents/latex-implementation-agent.md` | Add `model: sonnet` |
| `agents/meta-builder-agent.md` | Add `model: sonnet` |
| `agents/planner-agent.md` | Add `model: sonnet` |
| `CLAUDE.md` | Add Model column + Model Selection section |

### No Changes Needed

| Component | Reason |
|-----------|--------|
| `skill-status-sync/SKILL.md` | Already direct execution |
| `status-sync-agent.md` | Does not exist (correct) |
| Commands (research, plan, implement) | No changes needed |
| Context files | No changes needed |

## Testing & Validation

- [ ] All 6 agents have `model: sonnet` in frontmatter
- [ ] CLAUDE.md contains Model Selection documentation
- [ ] Skill-to-Agent table has Model column
- [ ] `grep -r "status-sync-agent" .claude/` returns empty
- [ ] skill-status-sync has `allowed-tools` (not `agent:`)
- [ ] Git commit successful in protocol/

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Model field syntax error | High | Low | Use exact YAML syntax from ProofChecker |
| CLAUDE.md formatting broken | Medium | Low | Preview changes before commit |
| Commit breaks something | Low | Low | All changes are additive/documentation |

## Artifacts & Outputs

**This task produces**:
- Updated protocol/.claude/agents/*.md (6 files)
- Updated protocol/.claude/CLAUDE.md
- Git commit in protocol repository

**Reference materials**:
- ProofChecker specs/534_research_claude_code_model_selection/reports/research-001.md
- ProofChecker specs/564_memory_issues_status_sync_agent/plans/implementation-003.md

## Rollback/Contingency

If any issues arise:
```bash
cd /home/benjamin/Projects/protocol
git checkout HEAD~1 -- .claude/
```

All changes are additive (model fields, documentation) - no destructive modifications.
