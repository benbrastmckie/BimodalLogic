# Implementation Plan: Task #879 (Revised)

- **Task**: 879 - Investigate and fix team mode context limit failures
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Version**: 002
- **Previous**: implementation-001.md
- **Dependencies**: None
- **Research Inputs**: research-001.md (diagnosis), research-002.md (handoff patterns)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: meta
- **Lean Intent**: false

## Revision Summary

**Key changes from v001**:
- **Removed**: Single-agent fallback for complex phases (lead taking over)
- **Added**: Successor teammate pattern for context exhaustion handoffs
- **Added**: Handoff artifact schema and templates
- **Added**: Incremental progress file pattern
- **Refined**: Context efficiency guidance focuses on handoff triggers, not prevention

**Design principle**: Plan FOR context exhaustion, not against it. When a teammate exhausts context, spawn a successor teammate with minimal handoff context rather than having the lead take over.

## Overview

This revised plan addresses context limit failures by implementing graceful handoff patterns. Rather than constraining agents or predicting phase durations, we enable teammates to "pass the torch" cleanly when approaching context limits. Successor teammates receive minimal, structured handoff artifacts rather than full history.

### Research Integration

From research-001.md:
- Context exhaustion is inevitable for complex Lean work (~150k+ tokens)
- Teammates cannot use /compact during execution

From research-002.md:
- Anthropic pattern: progress log + work items + minimal startup
- LangChain pattern: offload-and-reference (paths + previews)
- Session-handoff pattern: structured handoff (state → next action → decisions → gotchas)
- Key insight: successor agents should read handoff index ONLY, not full history

## Goals & Non-Goals

**Goals**:
- Enable graceful context exhaustion with successor teammate handoffs
- Create structured handoff artifact schema
- Add incremental progress tracking for phases
- Update teammate prompts with handoff triggers
- Document successor teammate spawning pattern

**Non-Goals**:
- Preventing context exhaustion (impossible for complex work)
- Making lead agent complete teammate work (explicitly avoided)
- Predicting phase durations (unreliable)
- Constraining agent behavior (counterproductive)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Handoff overhead slows progress | Medium | Medium | Keep handoff minimal (one-screen max) |
| Successor misinterprets handoff | Medium | Medium | Structured template with validation |
| Too many handoffs (thrashing) | Low | Low | Minimum progress before handoff allowed |
| Handoff files accumulate | Low | Low | Archive completed handoffs |

## Implementation Phases

### Phase 1: Define Handoff Artifact Schema [NOT STARTED]

- **Dependencies**: None
- **Goal**: Create structured handoff artifact format for context exhaustion

**Tasks**:
- [ ] Add `handoff` artifact type to return-metadata-file.md
- [ ] Define handoff directory structure: `specs/{N}_{SLUG}/handoffs/`
- [ ] Create handoff document template (markdown)
- [ ] Add `handoff_path` field to partial_progress schema

**Timing**: 1 hour

**Files to modify**:
- `.claude/context/core/formats/return-metadata-file.md` - Add handoff_path to partial_progress
- `.claude/context/core/formats/handoff-artifact.md` - New file defining schema

**Handoff Template**:
```markdown
# Phase {P} Handoff - {timestamp}

## Immediate Next Action
{Single specific step - not a list}

## Current State
- File: {path}
- Location: Line {N}, after {tactic/statement}
- Goal state: {current proof goal or expected output}

## Key Decisions Made
1. {Decision}: {Rationale}

## What NOT to Try
1. {Approach}: {Why it failed}

## Critical Context (max 5 items)
- {Essential fact 1}
- {Essential fact 2}

## References (read only if stuck)
- Plan: {path}, Phase {P}
- Research: {path}, Section {X}
```

**Verification**:
- Handoff schema defined with all required sections
- Template is one-screen max
- Progressive disclosure pattern clear

---

### Phase 2: Add Progress File Pattern [NOT STARTED]

- **Dependencies**: None
- **Goal**: Enable incremental progress tracking within phases

**Tasks**:
- [ ] Define progress file schema (JSON)
- [ ] Create progress file template
- [ ] Add progress directory: `specs/{N}_{SLUG}/progress/`
- [ ] Document update protocol (after each objective)

**Timing**: 45 minutes

**Files to modify**:
- `.claude/context/core/formats/progress-file.md` - New file defining schema

**Progress File Schema**:
```json
{
  "phase": 3,
  "phase_name": "GH-controlled Lindenbaum",
  "started_at": "2026-02-12T10:30:00Z",
  "last_updated": "2026-02-12T11:45:00Z",
  "objectives": [
    {"id": 1, "description": "Define GHControlledState", "status": "done"},
    {"id": 2, "description": "Prove consistency lemma", "status": "in_progress", "note": "3 of 5 cases done"},
    {"id": 3, "description": "Prove extension theorem", "status": "not_started"}
  ],
  "current_objective": 2,
  "approaches_tried": [
    {"approach": "Direct induction on formula", "result": "failed - need structural approach"}
  ],
  "handoff_count": 0
}
```

**Verification**:
- Progress schema is machine-readable
- Objectives immutable (only status changes)
- Approaches tried prevents repeating failures

---

### Phase 3: Update Teammate Prompts with Handoff Protocol [NOT STARTED]

- **Dependencies**: Phase 1, Phase 2
- **Goal**: Add context-aware handoff triggers to teammate prompts

**Tasks**:
- [ ] Add "Context Management" section to lean-implementation-agent.md
- [ ] Add handoff trigger guidelines (~80% context estimate)
- [ ] Add progress file update instructions
- [ ] Add handoff document writing instructions
- [ ] Update general-implementation-agent.md similarly

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/agents/lean-implementation-agent.md` - Add context management section
- `.claude/agents/general-implementation-agent.md` - Add context management section

**Context Management Section**:
```markdown
## Context Management

You have a finite context window. Plan FOR exhaustion, not against it.

### Progress Tracking
1. Update `specs/{N}_{SLUG}/progress/phase-{P}-progress.json` after each objective
2. Mark objectives done/in_progress as work completes
3. Log failed approaches in `approaches_tried`

### Handoff Triggers
Write handoff when ANY of:
- Context estimate reaches ~80% (based on tool call volume)
- About to attempt operation that might push over limit
- Completing any objective (natural boundary)
- Finding yourself re-reading the same context repeatedly

### Handoff Protocol
1. Write handoff to `specs/{N}_{SLUG}/handoffs/phase-{P}-handoff-{timestamp}.md`
2. Update progress file with current state
3. Return `partial` status with `handoff_path` in metadata
4. Do NOT attempt to complete more work after writing handoff
```

**Verification**:
- Context management section added to both agents
- Handoff triggers are clear and actionable
- Protocol steps are unambiguous

---

### Phase 4: Implement Successor Teammate Pattern [NOT STARTED]

- **Dependencies**: Phase 1, Phase 3
- **Goal**: Define how lead spawns successor teammates from handoffs

**Tasks**:
- [ ] Add "Successor Teammate" section to team-wave-helpers.md
- [ ] Define successor prompt template (minimal context)
- [ ] Add successor spawning pattern to skill-team-implement
- [ ] Document when successor vs new wave is appropriate

**Timing**: 1 hour

**Files to modify**:
- `.claude/utils/team-wave-helpers.md` - Add successor teammate section
- `.claude/skills/skill-team-implement/SKILL.md` - Add successor pattern

**Successor Prompt Template**:
```markdown
## Successor Teammate for Phase {P}

You are continuing work started by a previous teammate who exhausted context.

### Quick Start (read ONLY this first)
{Contents of handoff document's Immediate Next Action and Current State sections}

### If You Get Stuck
Read the full handoff at: {handoff_path}

### Do NOT
- Re-read {large file} (already processed by predecessor)
- Try {approach from What NOT to Try} (already failed)
- Read full research reports or plans unless stuck

### Progress File
Update: `specs/{N}_{SLUG}/progress/phase-{P}-progress.json`
```

**Key principle**: Successor reads handoff index ONLY by default. Full handoff and other context are escape hatches, not starting points.

**Verification**:
- Successor pattern uses minimal context
- Handoff serves as primary context, not history
- Escape hatches documented for when stuck

---

### Phase 5: Update Error Handling Documentation [NOT STARTED]

- **Dependencies**: Phase 1, Phase 4
- **Goal**: Document context exhaustion as expected event with recovery pattern

**Tasks**:
- [ ] Add "Context Exhaustion Recovery" section to error-handling.md
- [ ] Document that this is expected, not a bug
- [ ] Describe successor teammate spawning as recovery pattern
- [ ] Add example partial_progress with handoff_path
- [ ] Cross-reference handoff artifact schema

**Timing**: 45 minutes

**Files to modify**:
- `.claude/rules/error-handling.md` - Add context exhaustion section

**Context Exhaustion Recovery Section**:
```markdown
### Context Exhaustion Recovery

Context exhaustion is **expected** for complex phases, not a bug. Teammates have finite context windows and cannot use /compact during execution.

**Recovery Pattern**:
1. Teammate writes handoff artifact before exhausting context
2. Teammate returns `partial` status with `handoff_path`
3. Lead spawns **successor teammate** (not single-agent fallback)
4. Successor reads minimal handoff context
5. Successor continues from `immediate_next_action`

**Metadata format**:
```json
{
  "status": "partial",
  "partial_progress": {
    "stage": "context_exhaustion_handoff",
    "details": "Approaching context limit. Handoff written.",
    "handoff_path": "specs/{N}_{SLUG}/handoffs/phase-{P}-handoff-{timestamp}.md"
  }
}
```

**Important**: Do NOT have lead agent complete the work. Spawn successor teammate to maintain parallelism and context isolation.
```

**Verification**:
- Context exhaustion framed as expected, not error
- Successor pattern emphasized over lead fallback
- Handoff path clearly documented

---

## Testing & Validation

- [ ] Verify handoff artifact schema is complete and minimal
- [ ] Verify progress file schema supports all required tracking
- [ ] Verify teammate prompts include context management section
- [ ] Verify successor template provides minimal starting context
- [ ] Verify error handling documents recovery pattern
- [ ] Dry-run: Create example handoff document to validate template

## Artifacts & Outputs

- New `.claude/context/core/formats/handoff-artifact.md`
- New `.claude/context/core/formats/progress-file.md`
- Updated `.claude/context/core/formats/return-metadata-file.md`
- Updated `.claude/agents/lean-implementation-agent.md`
- Updated `.claude/agents/general-implementation-agent.md`
- Updated `.claude/utils/team-wave-helpers.md`
- Updated `.claude/skills/skill-team-implement/SKILL.md`
- Updated `.claude/rules/error-handling.md`

## Rollback/Contingency

All changes are documentation-only additions. If issues arise:
1. Revert specific commits via `git revert`
2. No functional changes mean no runtime breakage risk
3. Previous behavior remains valid; new patterns are additive

## Success Criteria

- [ ] Handoff artifact schema enables minimal successor context
- [ ] Progress files track incremental work without bloat
- [ ] Teammates know when and how to write handoffs
- [ ] Successors can continue from handoff without reading full history
- [ ] Error handling treats context exhaustion as expected event
- [ ] Lead never takes over teammate work (spawns successor instead)
