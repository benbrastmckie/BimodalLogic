# Implementation Plan: Task #820

- **Task**: 820 - add_sorry_debt_policy_references
- **Status**: [COMPLETED]
- **Effort**: 0.5 hours
- **Dependencies**: Task 819 (creates sorry-debt-policy.md)
- **Research Inputs**: specs/820_add_sorry_debt_policy_references/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Add single-line references to the sorry-debt-policy.md context file in three Lean-related configuration files. Each edit adds a "Load for Sorry Handling" subsection or "Context References" section pointing to the policy file.

### Research Integration

Research identified exact insertion points in all three files:
- lean-implementation-agent.md: After "Load for Implementation" subsection
- lean-research-agent.md: After "Load When Creating Report" subsection
- lean4.md: New "Context References" section at end of file

## Goals & Non-Goals

**Goals**:
- Add sorry-debt-policy.md reference to lean-implementation-agent.md
- Add sorry-debt-policy.md reference to lean-research-agent.md
- Add sorry-debt-policy.md reference to lean4.md rules file

**Non-Goals**:
- Modifying the sorry-debt-policy.md content itself
- Adding references to other agent or rule files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| File content changed since research | L | L | Use unique string matching for edits |
| Inconsistent formatting | L | L | Use exact same reference text in all files |

## Implementation Phases

### Phase 1: Add References to Agent and Rule Files [COMPLETED]

**Goal**: Add sorry-debt-policy.md references to all three target files

**Tasks**:
- [x] Edit lean-implementation-agent.md - add "Load for Sorry Handling" subsection
- [x] Edit lean-research-agent.md - add "Load for Sorry Handling" subsection
- [x] Edit lean4.md - add "Context References" section at end

**Timing**: 0.5 hours

**Files to modify**:
- `.claude/agents/lean-implementation-agent.md` - Add sorry handling subsection
- `.claude/agents/lean-research-agent.md` - Add sorry handling subsection
- `.claude/rules/lean4.md` - Add context references section

**Verification**:
- Grep for "sorry-debt-policy.md" in all three files
- Verify consistent formatting across all references

---

## Testing & Validation

- [ ] All three files contain reference to sorry-debt-policy.md
- [ ] Reference format is consistent: `@.claude/context/project/lean4/standards/sorry-debt-policy.md - Sorry remediation policy`
- [ ] No syntax errors introduced in any file

## Artifacts & Outputs

- Modified `.claude/agents/lean-implementation-agent.md`
- Modified `.claude/agents/lean-research-agent.md`
- Modified `.claude/rules/lean4.md`

## Rollback/Contingency

Git revert if any edits introduce problems. All changes are additive (no deletions) so rollback is straightforward.
