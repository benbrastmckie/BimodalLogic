# Implementation Plan: Task #537

**Task**: Identify and Configure Opus-Only Components
**Version**: 001
**Created**: 2026-01-17
**Language**: meta
**Session ID**: sess_1768660285_d5b57d

## Overview

Analyze the agent system to identify which components (if any) should use Opus instead of Sonnet, and configure them appropriately with documented rationale.

## Context from Previous Tasks

From Task 534 research:
- Agent frontmatter supports `model: opus` for highest capability
- Opus is recommended for: complex theorem discovery, multi-step reasoning
- Current agents all set to `model: sonnet` (Task 535)

From Task 536 analysis:
- Skills and commands run in main conversation context (typically Opus)
- Only agents can have independent model settings

## Phases

### Phase 1: Analyze Agents for Opus Candidacy

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Review each agent's responsibilities
2. Identify complexity factors that warrant Opus
3. Document decision for each agent

**Analysis Criteria**:
| Factor | Favors Opus | Favors Sonnet |
|--------|-------------|---------------|
| Reasoning complexity | Multi-step theorem proving | Template-based operations |
| Error recovery | Complex error analysis | Simple retry logic |
| Domain expertise | Deep mathematical reasoning | Standard programming |
| User interaction | Nuanced judgment calls | Structured responses |

**Agents to Analyze**:
1. lean-research-agent - Theorem discovery, Mathlib search
2. lean-implementation-agent - Proof development
3. general-research-agent - Web search, synthesis
4. general-implementation-agent - File operations
5. latex-implementation-agent - Document generation
6. planner-agent - Task decomposition
7. meta-builder-agent - System analysis

---

### Phase 2: Configure Opus Agents (if any)

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update identified agents to use `model: opus`
2. Add comments documenting the rationale

---

## Dependencies

- Task 534 (completed) - Research findings
- Task 535 (completed) - Agents set to Sonnet
- Task 536 (completed) - Architecture clarification

## Success Criteria

- [ ] Each agent analyzed with documented decision
- [ ] Opus agents configured (if any identified)
- [ ] Rationale documented for all decisions
