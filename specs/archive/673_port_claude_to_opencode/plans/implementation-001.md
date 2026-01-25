# Implementation Plan: Port .claude agent system to .opencode
- **Task**: 673 - Port .claude agent system to .opencode (legacy source)
- **Status**: [IN PROGRESS]
- **Effort**: 10-14 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: None
- **Artifacts**: plans/implementation-001.md
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview
Port the ProofChecker .claude agent system into a new .opencode directory while preserving
functionality and workflow semantics. The scope covers commands, agents, skills, context, and
supporting assets with path updates and opencode layout adjustments. Definition of done is a
self-contained .opencode system that mirrors .claude behavior, with plan phases marked complete (legacy source reference).

## Goals & Non-Goals
- **Goals**:
  - Recreate .claude commands, agents, and skills in .opencode structure (legacy source).
  - Port core and project context files with updated path references.
  - Preserve workflow semantics for research/plan/implement/review/meta operations.
  - Capture supporting assets needed for opencode compatibility.
- **Non-Goals**:
  - Refactor or redesign workflow semantics beyond opencode best-practice adaptation.
  - Change existing ProofChecker task data in specs/TODO.md or specs/state.json.

## Risks & Mitigations
- Risk: Large number of files increases omission risk. Mitigation: structured inventory and
  phase-by-phase checklist with validation pass at the end.
- Risk: Path references become inconsistent. Mitigation: targeted search/replace while
  porting, and final reference audit.
- Risk: Missing directories break file creation. Mitigation: create base .opencode structure
  before file writes and confirm via glob checks.

## Implementation Phases
### Phase 1: Create .opencode scaffold [COMPLETED]
- **Goal:** Establish the .opencode directory structure and base index files.
- **Tasks:**
  - [x] Create .opencode directories for agent, command, context, docs, templates.
  - [x] Add base README and context index mirroring .claude structure.
  - [x] Record scaffold paths for later porting steps.
- **Timing:** 1-2 hours
- **Started:** 2026-01-22T00:00:00Z
- **Completed:** 2026-01-22T00:00:00Z

### Phase 2: Port agents and skills [COMPLETED]
- **Goal:** Recreate .claude agents and skills as opencode agents/subagents.
- **Tasks:**
  - [x] Map .claude agents/skills to .opencode/agent and subagent files.
  - [x] Port agent content with opencode frontmatter and updated paths.
  - [x] Ensure task-routing semantics match .claude workflows.
- **Timing:** 2-3 hours
- **Started:** 2026-01-22T00:00:00Z
- **Completed:** 2026-01-22T00:00:00Z

### Phase 3: Port command definitions [COMPLETED]
- **Goal:** Recreate .claude commands in .opencode/command with opencode routing (legacy source).
- **Tasks:**
  - [x] Port each .claude command to opencode command format.
  - [x] Update references to new agent paths and context locations.
  - [x] Align command descriptions and argument parsing semantics.
- **Timing:** 2-3 hours
- **Completed:** 2026-01-23T00:00:00Z

### Phase 4: Port context and standards [COMPLETED]
- **Goal:** Mirror .claude context core/project content inside .opencode/context (legacy source).
- **Tasks:**
  - [x] Copy core checkpoints, formats, patterns, standards, templates, and workflows.
  - [x] Copy orchestration + architecture + routing/validation files.
  - [x] Copy project meta and repo context files.
  - [x] Copy remaining project context (lean4, logic, math, physics, latex, processes).
  - [x] Resolve any remaining .claude references in opencode context.
- **Timing:** 3-4 hours
- **Started:** 2026-01-23T00:00:00Z
- **Completed:** 2026-01-23T00:00:00Z

### Phase 5: Port supporting assets and validate [IN PROGRESS]
- **Goal:** Carry over remaining assets and confirm integrity.
- **Tasks:**
  - [x] Port rules, hooks, docs, skills, templates, and systemd assets needed for workflow fidelity.
  - [x] Port scripts and refresh tooling for OpenCode.
  - [ ] Audit for missing files or broken references across .opencode.
  - [ ] Update plan status markers to completed.
- **Timing:** 1-2 hours
- **Started:** 2026-01-23T00:00:00Z

## Testing & Validation
- [ ] Confirm .opencode directory contains agents, commands, context, and docs.
- [ ] Verify .opencode files reference .opencode paths (no .claude path leakage beyond legacy references).
- [ ] Ensure each ported command references correct agent file.

## Artifacts & Outputs
- specs/673_port_claude_to_opencode/plans/implementation-001.md
- .opencode/agent/*
- .opencode/command/*
- .opencode/context/**
- .opencode/docs/**

## Rollback/Contingency
- Remove the .opencode directory to revert to the pre-port state.
- Keep the plan file for historical reference even if rollback is triggered.
