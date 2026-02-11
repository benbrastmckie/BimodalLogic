# Implementation Plan: Task #869

- **Task**: 869 - claude_teams_wave_coordination
- **Status**: [NOT STARTED]
- **Effort**: 7 hours
- **Dependencies**: None (builds on existing skill/agent architecture)
- **Research Inputs**: specs/869_claude_teams_wave_coordination/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Upgrade the .claude/ agent system to leverage Claude Teams for coordinated multi-agent execution. This implementation adds `--team` flag support to /research, /plan, and /implement commands, enabling wave-based parallelization where 1-4 specialized subagents work concurrently with synthesis between waves. The design preserves existing single-agent workflows as default while enabling team mode for complex tasks requiring multi-angle investigation or parallel execution.

### Research Integration

Integrated from research-001.md:
- Claude Code Agent Teams feature (experimental, Feb 2026) with TeammateTool for spawning, messaging, and task lists
- Wave-based parallelization best practices: cap at 4 agents per wave, early synthesis, lightweight reviewers
- Lead-as-synthesizer pattern for result aggregation
- Graceful degradation to single-agent mode on team creation failure
- Debug/ report generation for implementation debugging cycles

## Goals & Non-Goals

**Goals**:
- Add `--team` and `--team-size N` flags to /research, /plan, /implement commands
- Create team orchestration infrastructure (wave management, teammate spawning, result synthesis)
- Implement team-research skill with multi-angle investigation and distilled summaries
- Implement team-plan skill with candidate plan generation and trade-off analysis
- Implement team-implement skill with parallel execution and debugger agents
- Maintain backward compatibility with existing single-agent workflows
- Support graceful degradation when team mode fails

**Non-Goals**:
- Creating entirely new commands (/team-research, etc.) - using --team flag approach
- Nested teams (teammates spawning their own teams)
- Session resumption with in-process teammates (limitation of current Teams feature)
- Automatic cost estimation (token usage varies significantly by task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Token cost explosion (~5x baseline) | Medium | High | Warn user before team execution, document cost implications |
| Agent Teams feature instability (experimental) | Medium | Medium | Implement robust fallback to single-agent mode |
| Teammate coordination lag | Low | Medium | Set reasonable timeouts, use claim-based task assignment |
| Result synthesis conflicts | Low | Medium | Lead-as-synthesizer with conflict logging |
| Session resumption issues | Medium | Medium | Save team state to metadata for manual recovery guidance |

## Implementation Phases

### Phase 1: Infrastructure Foundation [NOT STARTED]

**Goal**: Create base team orchestration infrastructure and enable Agent Teams feature

**Tasks**:
- [ ] Create `.claude/context/core/patterns/team-orchestration.md` documenting wave coordination patterns
- [ ] Create `.claude/context/core/formats/team-metadata-extension.md` with schema for team execution results
- [ ] Add environment configuration guidance for `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- [ ] Create `.claude/utils/team-wave-helpers.md` with wave management patterns (spawn, wait, collect, synthesize)
- [ ] Update `.claude/CLAUDE.md` with team command flag documentation

**Timing**: 1.5 hours

**Files to create**:
- `.claude/context/core/patterns/team-orchestration.md` - Wave coordination patterns
- `.claude/context/core/formats/team-metadata-extension.md` - Team result schema
- `.claude/utils/team-wave-helpers.md` - Reusable wave management patterns

**Files to modify**:
- `.claude/CLAUDE.md` - Add team command options to Command Reference

**Verification**:
- All pattern documents exist with complete schemas
- CLAUDE.md has --team flag documented for /research, /plan, /implement

---

### Phase 2: Team Research Implementation [NOT STARTED]

**Goal**: Implement team-based research with multi-angle investigation

**Tasks**:
- [ ] Create `skill-team-research/SKILL.md` extending skill-researcher pattern with team coordination
- [ ] Define teammate prompt templates for: primary angle, alternative approaches, risk analysis, devil's advocate
- [ ] Implement wave spawning logic (2-4 teammates per wave)
- [ ] Implement synthesis stage that distills findings into unified report
- [ ] Add fallback to single-agent research on team creation failure
- [ ] Create teammate result collection and conflict resolution logic

**Timing**: 1.5 hours

**Files to create**:
- `.claude/skills/skill-team-research/SKILL.md` - Team research skill definition

**Files to modify**:
- `.claude/CLAUDE.md` - Add skill-team-research to Skill-to-Agent Mapping

**Verification**:
- skill-team-research SKILL.md has complete 11-stage execution flow
- Teammate prompts are documented for each research angle
- Fallback to single-agent mode is implemented
- Synthesis protocol produces unified research report

---

### Phase 3: Team Planning Implementation [NOT STARTED]

**Goal**: Implement team-based planning with candidate plan generation

**Tasks**:
- [ ] Create `skill-team-plan/SKILL.md` extending skill-planner pattern with team coordination
- [ ] Define teammate prompt templates for: phased plan A, alternative plan B, risk/dependency analysis
- [ ] Implement trade-off analysis stage comparing candidate plans
- [ ] Implement synthesis stage that produces best-of-breed final plan
- [ ] Add fallback to single-agent planning on team creation failure

**Timing**: 1 hour

**Files to create**:
- `.claude/skills/skill-team-plan/SKILL.md` - Team planning skill definition

**Files to modify**:
- `.claude/CLAUDE.md` - Add skill-team-plan to Skill-to-Agent Mapping

**Verification**:
- skill-team-plan SKILL.md has complete execution flow
- Trade-off analysis stage is documented
- Plan synthesis produces single coherent plan with cited sources

---

### Phase 4: Team Implementation Execution [NOT STARTED]

**Goal**: Implement team-based implementation with parallel execution and debugging

**Tasks**:
- [ ] Create `skill-team-implement/SKILL.md` extending skill-implementer pattern with team coordination
- [ ] Implement phase parallelization logic (identify independent phases from plan)
- [ ] Define debugger agent role and prompt for error analysis
- [ ] Create debug/ report generation protocol (hypothesis, analysis, resolution)
- [ ] Implement debug wave spawning on implementation failure
- [ ] Add fallback to single-agent implementation on team creation failure

**Timing**: 1.5 hours

**Files to create**:
- `.claude/skills/skill-team-implement/SKILL.md` - Team implementation skill definition
- `.claude/context/core/formats/debug-report-format.md` - Debug report schema

**Files to modify**:
- `.claude/CLAUDE.md` - Add skill-team-implement to Skill-to-Agent Mapping

**Verification**:
- skill-team-implement SKILL.md has complete execution flow
- Debug wave protocol is documented
- Debug reports are written to specs/{N}_{SLUG}/debug/

---

### Phase 5: Command Routing Integration [NOT STARTED]

**Goal**: Integrate --team flag routing into existing commands

**Tasks**:
- [ ] Update skill-orchestrator to parse --team and --team-size flags
- [ ] Add team mode routing logic (--team -> skill-team-*, default -> skill-*)
- [ ] Document flag parsing in orchestrator skill
- [ ] Ensure session_id propagation through team execution

**Timing**: 1 hour

**Files to modify**:
- `.claude/skills/skill-orchestrator/SKILL.md` - Add --team flag routing

**Verification**:
- /research 123 --team routes to skill-team-research
- /plan 123 --team routes to skill-team-plan
- /implement 123 --team routes to skill-team-implement
- Default behavior (no --team) unchanged

---

### Phase 6: Documentation and Error Handling [NOT STARTED]

**Goal**: Complete documentation and error handling patterns

**Tasks**:
- [ ] Update error-handling.md with team-specific error types (team_creation_failed, teammate_timeout, synthesis_failed)
- [ ] Add team error recovery patterns
- [ ] Create user-facing documentation for --team usage
- [ ] Document token cost implications and when to use team mode
- [ ] Add team-related entries to errors.json schema

**Timing**: 0.5 hours

**Files to modify**:
- `.claude/rules/error-handling.md` - Add team error types
- `.claude/README.md` - Add team mode documentation section

**Verification**:
- Error types documented with recovery strategies
- User documentation explains when to use --team
- Token cost implications are documented

## Testing & Validation

- [ ] Manual test: `/research 869 --team` spawns multiple teammates and produces unified report
- [ ] Manual test: `/plan 869 --team` generates candidate plans with trade-off analysis
- [ ] Manual test: `/implement 869 --team` executes with debugger support
- [ ] Verify fallback: Disable CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS, confirm single-agent execution
- [ ] Verify backward compatibility: Commands without --team work unchanged
- [ ] Verify metadata: Team execution metadata includes teammate_results and synthesis fields

## Artifacts & Outputs

- `.claude/skills/skill-team-research/SKILL.md` - Team research skill
- `.claude/skills/skill-team-plan/SKILL.md` - Team planning skill
- `.claude/skills/skill-team-implement/SKILL.md` - Team implementation skill
- `.claude/context/core/patterns/team-orchestration.md` - Wave coordination patterns
- `.claude/context/core/formats/team-metadata-extension.md` - Team result schema
- `.claude/context/core/formats/debug-report-format.md` - Debug report schema
- `.claude/utils/team-wave-helpers.md` - Reusable wave management patterns
- Updated `.claude/CLAUDE.md` with team command documentation
- Updated `.claude/rules/error-handling.md` with team error types
- Updated `.claude/README.md` with team mode user documentation
- `specs/869_claude_teams_wave_coordination/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If the implementation causes issues:
1. The --team flag is opt-in, so existing workflows are unaffected
2. Remove skill-team-* directories to disable team features
3. Revert CLAUDE.md and error-handling.md changes
4. Team orchestration patterns are isolated in context/ and can be removed without affecting core system
5. Fallback to single-agent mode is built into each team skill, so partial failures degrade gracefully
