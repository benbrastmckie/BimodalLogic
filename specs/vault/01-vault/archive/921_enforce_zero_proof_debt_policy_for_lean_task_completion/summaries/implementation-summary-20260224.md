# Implementation Summary: Task #921

**Task**: Enforce Zero Proof Debt Policy for Lean Task Completion
**Status**: [COMPLETED]
**Started**: 2026-02-24
**Completed**: 2026-02-24
**Language**: meta

## Overview

This implementation enforces a strict zero-proof-debt completion gate for all Lean tasks across the agent system. The changes establish defense in depth: policy states the rule, agents enforce during implementation, and skills verify in postflight.

## Changes Made

### Phase 1: Policy Foundation
- **File**: `.claude/context/project/lean4/standards/proof-debt-policy.md`
- Added `Completion Gates` section with zero-debt requirement (zero sorries, no new axioms, build passes)
- Added `Forbidden Patterns` section explicitly banning Option B sorry deferral and new axiom introduction
- Clarified `Path D (Axiom Disclosure)` applies only to publication decisions on pre-existing axioms, not task implementation
- Added enforcement points table showing policy -> research -> planner -> agent -> skill chain

### Phase 2: Lean Implementation Agent
- **File**: `.claude/agents/lean-implementation-agent.md`
- Added `Zero-Debt Completion Gate (MANDATORY)` section with verification steps (grep for sorry, axiom count, lake build)
- Added `sorry_remains` and `new_axiom_required` to hard blocker table
- Added MUST DO items 18-19 for zero-debt verification
- Added MUST NOT items 18-20 prohibiting implemented status with sorries, new axioms, or Option B deferral

### Phase 3: Research and Planning Agents
- **File**: `.claude/agents/lean-research-agent.md`
  - Added `Research Constraints for Lean Tasks` section with forbidden recommendations
  - Added MUST NOT items 14-16 prohibiting sorry deferral recommendations

- **File**: `.claude/agents/planner-agent.md`
  - Added `Lean Task Planning Constraints` section (Stage 4a) with forbidden/required patterns
  - Added MUST DO items 11-13 for zero-debt planning
  - Added MUST NOT items 12-14 prohibiting planned sorries

### Phase 4: Plan Format and Skill
- **File**: `.claude/context/core/formats/plan-format.md`
  - Updated Sorry Characterization to state NEVER introduce new sorries
  - Updated New Sorries example to show BLOCKED pattern instead of deferral
  - Added Lean-specific Testing & Validation items (zero-debt check, axiom check, build)

- **File**: `.claude/skills/skill-lean-implementation/SKILL.md`
  - Added Stage 6b: Zero-Debt Verification Gate with sorry/axiom/build checks
  - Added rejection logic that overrides "implemented" to "partial" with requires_user_review on gate failure
  - Updated Stage 7 header to clarify it only proceeds if Stage 6b passed

### Phase 5: Consistency Verification
- Verified CLAUDE.md reference to proof-debt-policy.md remains valid
- Verified no conflicts with error-handling.md blocked status guidance
- Verified consistent "zero-debt" terminology across all 6 modified files

## Files Modified

| File | Change Summary |
|------|----------------|
| `.claude/context/project/lean4/standards/proof-debt-policy.md` | Added Completion Gates and Forbidden Patterns sections |
| `.claude/agents/lean-implementation-agent.md` | Added Zero-Debt Completion Gate section, updated blocker detection |
| `.claude/agents/lean-research-agent.md` | Added Research Constraints section |
| `.claude/agents/planner-agent.md` | Added Lean Task Planning Constraints section (Stage 4a) |
| `.claude/context/core/formats/plan-format.md` | Updated sorry handling, added Lean validation items |
| `.claude/skills/skill-lean-implementation/SKILL.md` | Added Stage 6b verification gate |

## Verification

- [x] Policy document has zero-debt completion gate clearly stated
- [x] Option B patterns explicitly forbidden in all relevant files
- [x] Agent verification steps documented with grep commands
- [x] Skill-level enforcement gate added (Stage 6b)
- [x] All MUST DO/MUST NOT lists updated consistently
- [x] No conflicting language remains in any target file
- [x] Consistent "zero-debt" terminology across all files

## Notes

The zero-debt policy is enforced at multiple levels:
1. **Policy** (proof-debt-policy.md) - States the rule
2. **Research** (lean-research-agent.md) - Cannot recommend sorry deferral
3. **Planning** (planner-agent.md) - Cannot plan phases that introduce sorries
4. **Implementation** (lean-implementation-agent.md) - Verifies zero sorries before returning implemented
5. **Skill Postflight** (skill-lean-implementation/SKILL.md) - Independent verification before status update

This defense in depth ensures no Lean task can reach [COMPLETED] status with sorries present.
