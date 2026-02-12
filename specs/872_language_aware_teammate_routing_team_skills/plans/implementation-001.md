# Implementation Plan: Task #872

- **Task**: 872 - Add language-aware teammate routing to team skills
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None (builds on existing infrastructure)
- **Research Inputs**: specs/872_language_aware_teammate_routing_team_skills/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Add language-based routing to team skills (skill-team-research, skill-team-plan, skill-team-implement) so teammates are spawned with language-appropriate agent patterns and MCP tool access. Currently, team skills spawn generic teammates without language routing, causing failures when Lean tasks require lean-lsp MCP tools. This implementation adds a routing decision stage to each team skill that checks the task language and constructs language-specific teammate prompts.

### Research Integration

Key findings from research-001.md integrated:
- Team skills extract language field but do not use it for teammate prompts
- Agent mapping exists: lean-research-agent, lean-implementation-agent patterns
- MCP tools require user-scope configuration (documented in setup script)
- Specific teammate prompt templates for Lean tasks documented in research

## Goals & Non-Goals

**Goals**:
- Modify skill-team-research to spawn Lean-aware teammates for Lean tasks
- Modify skill-team-implement to spawn Lean-aware teammates for Lean tasks
- Modify skill-team-plan to include Lean context references for Lean tasks
- Include blocked MCP tools warnings in all Lean teammate prompts
- Ensure teammates load appropriate agent definition files via @-references

**Non-Goals**:
- Creating separate lean-team skills (routing happens within existing skills)
- Modifying MCP configuration (already handled by setup script)
- Creating new agent definition files (existing agents are sufficient)
- Handling latex/typst routing (can be added in future iteration)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| MCP tools unavailable to teammates | H | M | Include fallback instructions in prompts; document user-scope requirement |
| Increased prompt complexity/token usage | M | L | Use @-references for deferred loading; keep core instructions minimal |
| Teammate coordination issues (concurrent Lean edits) | M | L | Phase dependency analysis prevents parallel work on same files |
| Regression in non-Lean task handling | M | L | Explicit else clause preserves existing generic behavior |

## Implementation Phases

### Phase 1: Add Language Routing Helper Pattern [NOT STARTED]

**Goal**: Create a reusable pattern for language routing that all team skills can reference.

**Tasks**:
- [ ] Create language routing helper section in team-wave-helpers.md
- [ ] Define agent pattern lookup by language
- [ ] Define context references lookup by language
- [ ] Define blocked tools list by language
- [ ] Document the pattern for teammate prompt construction

**Timing**: 45 minutes

**Files to modify**:
- `.claude/utils/team-wave-helpers.md` - Add language routing helper section

**Verification**:
- Helper section documents routing logic for: lean, latex, typst, general, meta
- Includes agent pattern, context references, and blocked tools for each language
- Pattern is reusable across all three team skills

---

### Phase 2: Modify skill-team-research [NOT STARTED]

**Goal**: Add language routing to research teammate prompts.

**Tasks**:
- [ ] Add Stage 5a: Language Routing Decision after team mode check
- [ ] Create language-specific prompt templates for Lean
- [ ] Modify Stage 5 to use language-aware prompts
- [ ] Include blocked tools list in Lean teammate prompts
- [ ] Include required context @-references in Lean prompts
- [ ] Preserve existing behavior for non-Lean languages

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/skills/skill-team-research/SKILL.md` - Add language routing logic

**Verification**:
- For Lean tasks: Teammate prompts include lean-research-agent pattern reference
- For Lean tasks: Prompts include lean_leansearch, lean_loogle, lean_leanfinder tools
- For Lean tasks: Prompts include blocked tools warning (lean_diagnostic_messages, lean_file_outline)
- For non-Lean tasks: Prompts unchanged from current generic behavior

---

### Phase 3: Modify skill-team-implement [NOT STARTED]

**Goal**: Add language routing to implementation teammate prompts (most critical change).

**Tasks**:
- [ ] Add Stage 5a: Language Routing Decision after team mode check
- [ ] Create language-specific prompt templates for Lean phase implementers
- [ ] Modify Stage 6 (Execute Implementation Waves) to use language-aware prompts
- [ ] Include lean_goal usage instructions in Lean implementer prompts
- [ ] Include verification requirements (lake build) in Lean prompts
- [ ] Modify Stage 7 (Handle Implementation Errors) for Lean debugger prompts
- [ ] Preserve existing behavior for non-Lean languages

**Timing**: 2 hours

**Files to modify**:
- `.claude/skills/skill-team-implement/SKILL.md` - Add language routing logic

**Verification**:
- For Lean tasks: Phase implementer prompts include lean-implementation-agent pattern
- For Lean tasks: Prompts include lean_goal, lean_multi_attempt, lean_state_search tools
- For Lean tasks: Debugger prompts include lean_goal for error analysis
- For Lean tasks: Verification includes lake build requirement
- For non-Lean tasks: Prompts unchanged from current generic behavior

---

### Phase 4: Modify skill-team-plan [NOT STARTED]

**Goal**: Add Lean context references to planning teammates for Lean tasks.

**Tasks**:
- [ ] Add Stage 5a: Language Routing Decision
- [ ] For Lean tasks: Include tactic-patterns.md reference in planner prompts
- [ ] For Lean tasks: Note that phases should correspond to proof milestones
- [ ] Preserve existing behavior for non-Lean languages

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-team-plan/SKILL.md` - Add Lean context references

**Verification**:
- For Lean tasks: Planner prompts include tactic-patterns.md reference
- For Lean tasks: Prompts note proof milestone structure for phases
- For non-Lean tasks: Prompts unchanged

---

### Phase 5: Update Documentation [NOT STARTED]

**Goal**: Document the language-aware routing in team skill headers and CLAUDE.md.

**Tasks**:
- [ ] Update skill-team-research header comment with language routing note
- [ ] Update skill-team-implement header comment with language routing note
- [ ] Update skill-team-plan header comment with language routing note
- [ ] Add note in CLAUDE.md Skill-to-Agent Mapping about team skill routing

**Timing**: 15 minutes

**Files to modify**:
- `.claude/skills/skill-team-research/SKILL.md` - Update header
- `.claude/skills/skill-team-implement/SKILL.md` - Update header
- `.claude/skills/skill-team-plan/SKILL.md` - Update header
- `.claude/CLAUDE.md` - Add note about team skill routing

**Verification**:
- Header comments mention language-aware routing for Lean tasks
- CLAUDE.md notes that team skills route to language-appropriate agents

## Testing & Validation

- [ ] Manual review: skill-team-research Lean prompt includes required elements
- [ ] Manual review: skill-team-implement Lean prompt includes required elements
- [ ] Manual review: skill-team-plan Lean prompt includes context references
- [ ] Manual review: Non-Lean prompts unchanged from prior behavior
- [ ] Verify blocked tools warnings present in all Lean prompts
- [ ] Verify @-references use correct paths

## Artifacts & Outputs

- `.claude/utils/team-wave-helpers.md` (modified) - Language routing helper
- `.claude/skills/skill-team-research/SKILL.md` (modified) - Language-aware routing
- `.claude/skills/skill-team-implement/SKILL.md` (modified) - Language-aware routing
- `.claude/skills/skill-team-plan/SKILL.md` (modified) - Lean context references
- `.claude/CLAUDE.md` (modified) - Documentation update
- `specs/872_language_aware_teammate_routing_team_skills/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation causes issues:
1. Revert to previous versions of the three SKILL.md files
2. Revert team-wave-helpers.md changes
3. Remove CLAUDE.md note
4. Team skills will continue working with generic prompts (no language routing)

The changes are additive conditional logic (if language == "lean" then ... else existing behavior), so rollback simply removes the conditional branches.
