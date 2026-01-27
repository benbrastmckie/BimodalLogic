# Parity Matrix: .claude vs .opencode (ProofChecker)

## Overview

This matrix compares ProofChecker `.claude` components to the `.opencode` port and flags parity gaps plus OpenAgents alignment needs. Use this as the audit output for Phase 1 in implementation-002.

## Agents

| Component | .claude File | .opencode File | Parity Status | Gaps / Notes |
| --- | --- | --- | --- | --- |
| document-converter-agent | `.claude/agents/document-converter-agent.md` | `.opencode/agent/document-converter-agent.md` | Aligned | Expanded to include conversion matrix, tool detection, metadata file workflow, and error handling. |
| planner-agent | `.claude/agents/planner-agent.md` | `.opencode/agent/planner-agent.md` | Aligned | Added staged workflow, metadata handling, and context loading gates. |
| general-research-agent | `.claude/agents/general-research-agent.md` | `.opencode/agent/general-research-agent.md` | Aligned | Added research strategy, metadata file workflow, and context gating. |
| general-implementation-agent | `.claude/agents/general-implementation-agent.md` | `.opencode/agent/general-implementation-agent.md` | Aligned | Added phased execution outline, summary creation, and completion_data guidance. |
| meta-builder-agent | `.claude/agents/meta-builder-agent.md` | `.opencode/agent/meta-builder-agent.md` | Aligned | Added context-loading gate guidance and lazy loading note. |
| lean-research-agent | `.claude/agents/lean-research-agent.md` | `.opencode/agent/lean-research-agent.md` | Aligned | Added context-loading gates and critical requirements. |
| lean-implementation-agent | `.claude/agents/lean-implementation-agent.md` | `.opencode/agent/lean-implementation-agent.md` | Aligned | Added context-loading gates and critical requirements. |
| latex-implementation-agent | `.claude/agents/latex-implementation-agent.md` | `.opencode/agent/latex-implementation-agent.md` | Aligned | Added context-loading gates and critical requirements. |
| skill-orchestrator agent | `.claude/skills/skill-orchestrator/SKILL.md` | `.opencode/agent/skill-orchestrator.md` | Aligned | Added routing summary and context-loading gate. |

## Skills

| Component | .claude File | .opencode File | Parity Status | Gaps / Notes |
| --- | --- | --- | --- | --- |
| skill-document-converter | `.claude/skills/skill-document-converter/SKILL.md` | `.opencode/skills/skill-document-converter/SKILL.md` | Aligned | Added context references, triggers, and execution flow. |
| skill-planner | `.claude/skills/skill-planner/SKILL.md` | `.opencode/skills/skill-planner/SKILL.md` | Aligned | Added postflight references and detailed execution flow. |
| skill-implementer | `.claude/skills/skill-implementer/SKILL.md` | `.opencode/skills/skill-implementer/SKILL.md` | Aligned | Added postflight references and detailed execution flow. |
| skill-orchestrator | `.claude/skills/skill-orchestrator/SKILL.md` | `.opencode/skills/skill-orchestrator/SKILL.md` | Aligned | Added context loading and routing summary. |
| skill-researcher | `.claude/skills/skill-researcher/SKILL.md` | `.opencode/skills/skill-researcher/SKILL.md` | Aligned | Added postflight references and execution flow. |
| skill-lean-research | `.claude/skills/skill-lean-research/SKILL.md` | `.opencode/skills/skill-lean-research/SKILL.md` | Aligned | Added postflight references and execution flow. |
| skill-lean-implementation | `.claude/skills/skill-lean-implementation/SKILL.md` | `.opencode/skills/skill-lean-implementation/SKILL.md` | Aligned | Added postflight references and execution flow. |
| skill-latex-implementation | `.claude/skills/skill-latex-implementation/SKILL.md` | `.opencode/skills/skill-latex-implementation/SKILL.md` | Aligned | Added postflight references, triggers, and execution flow. |
| skill-meta | `.claude/skills/skill-meta/SKILL.md` | `.opencode/skills/skill-meta/SKILL.md` | Aligned | Added postflight references and context index usage. |
| skill-status-sync | `.claude/skills/skill-status-sync/SKILL.md` | `.opencode/skills/skill-status-sync/SKILL.md` | Aligned | Added context references and standalone-use guidance. |
| skill-refresh | `.claude/skills/skill-refresh/SKILL.md` | `.opencode/skills/skill-refresh/SKILL.md` | Aligned | Added context references and trigger conditions. |
| skill-learn | `.claude/skills/skill-learn/SKILL.md` | `.opencode/skills/skill-learn/SKILL.md` | Aligned | Clarified direct-execution nature and context references. |
| skill-git-workflow | `.claude/skills/skill-git-workflow/SKILL.md` | `.opencode/skills/skill-git-workflow/SKILL.md` | Aligned | Added context references. |

## Commands

| Component | .claude File | .opencode File | Parity Status | Gaps / Notes |
| --- | --- | --- | --- | --- |
| /convert | `.claude/commands/convert.md` | `.opencode/command/convert.md` | Aligned | Added context-loading guidance; removed model field. |
| /plan | `.claude/commands/plan.md` | `.opencode/command/plan.md` | Aligned | Added context-loading guidance; removed model field. |
| /implement | `.claude/commands/implement.md` | `.opencode/command/implement.md` | Aligned | Removed model field; matches checkpoint flow. |
| /research | `.claude/commands/research.md` | `.opencode/command/research.md` | Aligned | Added context-loading guidance; removed model field. |
| /review | `.claude/commands/review.md` | `.opencode/command/review.md` | Aligned | Removed model field. |
| /task | `.claude/commands/task.md` | `.opencode/command/task.md` | Aligned | Added context-loading guidance; removed model field. |
| /todo | `.claude/commands/todo.md` | `.opencode/command/todo.md` | Aligned | Removed model field. |
| /learn | `.claude/commands/learn.md` | `.opencode/command/learn.md` | Aligned | Removed model field. |
| /refresh | `.claude/commands/refresh.md` | `.opencode/command/refresh.md` | Aligned | Updated wording to OpenCode resources. |
| /revise | `.claude/commands/revise.md` | `.opencode/command/revise.md` | Aligned | Removed model field. |
| /meta | `.claude/commands/meta.md` | `.opencode/command/meta.md` | Aligned | Added context-loading guidance; removed model field. |
| /errors | `.claude/commands/errors.md` | `.opencode/command/errors.md` | Aligned | Added context-loading guidance; removed model field. |

## OpenAgents Alignment (Cross-Cutting)

- Context index usage in `.opencode/context/index.md` already matches OpenAgents quick map; ensure agents/skills reference it consistently.
- Critical context-loading gates: missing in most `.opencode/agent/*.md` and `skills/*/SKILL.md` vs OpenAgents `agent/AGENT.md` pattern.
- Delegation criteria: define explicit thresholds (4+ files, >60 minutes, specialized knowledge) in agent/skill docs.
- Return schema guidance: ensure `.opencode/context/core/orchestration/orchestration-core.md` return format is referenced in agents/skills.
- Command lifecycle: align `.opencode/rules/workflows.md` and command docs with checkpoint model (`core/checkpoints/*`).
- Frontmatter: remove any model-specific fields (none spotted yet in sampled files) and standardize tool permissions.
