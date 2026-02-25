# Implementation Plan: Task #921

- **Task**: 921 - Enforce Zero Proof Debt Policy for Lean Task Completion
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/921_enforce_zero_proof_debt_policy_for_lean_task_completion/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This implementation enforces a strict zero-proof-debt completion gate for all Lean tasks. No sorry may remain in completed Lean code, no new axioms may be introduced, and Option B style sorry deferral patterns are explicitly forbidden. The changes span policy documents, agent definitions, plan formats, and skill files to create defense in depth - policy states the rule, agents enforce during implementation, and skills verify in postflight.

### Research Integration

Research-001 analyzed 6 target files and identified these key gaps:
- proof-debt-policy.md lacks explicit completion gate and Option B prohibition
- lean-implementation-agent.md has sorry prohibition but no verification step
- lean-research-agent.md may recommend sorry deferral approaches
- planner-agent.md lacks Lean-specific completion criteria
- plan-format.md still allows "temporary sorry with documentation"
- skill-lean-implementation has no zero-debt verification in postflight

## Goals & Non-Goals

**Goals**:
- Establish zero-debt as MANDATORY for Lean task completion
- Explicitly forbid Option B "sorry now, fix later" patterns
- Add verification steps at agent and skill levels
- Create clear escalation path when proof cannot be completed (use BLOCKED, not sorry)

**Non-Goals**:
- Modifying how existing sorries are tracked or reported
- Changing axiom handling for publication-time disclosure
- Implementing automated sorry detection tools (grep patterns suffice)
- Modifying non-Lean agents or skills

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Complex proofs genuinely stuck | Medium | Medium | Clear guidance to use [BLOCKED] with hard blocker, not sorry |
| False positives (sorry in comments) | Low | Low | Grep for `\bsorry\b` tactic pattern specifically |
| Agent bypasses verification | High | Low | Skill-level enforcement as backup gate |
| Over-restrictive policy stalls work | Medium | Low | [BLOCKED] status provides escape valve with user review |

## Implementation Phases

### Phase 1: Update Policy Foundation [NOT STARTED]

- **Dependencies:** None
- **Goal:** Establish the zero-debt completion gate rule in the canonical policy document

**Tasks**:
- [ ] Add "Completion Gates" section to proof-debt-policy.md stating zero-debt requirement
- [ ] Add "Forbidden Patterns" section explicitly banning Option B style sorry deferral
- [ ] Clarify that Path D (Axiom Disclosure) applies only to existing axioms at publication, not task implementation
- [ ] Review and update any conflicting language in existing sections

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/project/lean4/standards/proof-debt-policy.md` - Add 2 new sections, clarify existing

**Verification**:
- Policy document has "Completion Gates" section with zero-debt rule
- Policy document has "Forbidden Patterns" section with Option B prohibition
- No conflicting language remains suggesting sorries are acceptable

---

### Phase 2: Update Lean Implementation Agent [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Add verification requirements to the agent that executes Lean implementations

**Tasks**:
- [ ] Add "Zero-Debt Completion Gate" section with explicit verification steps
- [ ] Add sorry detection to hard blocker criteria (requires_user_review: true)
- [ ] Update MUST DO: "Verify zero sorries in modified files before returning implemented status"
- [ ] Update MUST NOT: "Return implemented status if any sorry remains in modified files"
- [ ] Add verification commands: `grep -r "sorry" <modified files>`

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/lean-implementation-agent.md` - Add verification section, update MUST DO/MUST NOT

**Verification**:
- Agent has explicit zero-debt verification section
- Sorry in output triggers hard blocker status
- MUST DO/MUST NOT lists include zero-debt requirements

---

### Phase 3: Update Research and Planning Agents [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Ensure upstream agents do not recommend or plan sorry deferral patterns

**Tasks**:
- [ ] Add "Research Constraints for Lean Tasks" section to lean-research-agent.md
- [ ] Update lean-research-agent.md MUST NOT to include "Recommend sorry deferral patterns (Option B style)"
- [ ] Add "Lean Task Planning Constraints" section to planner-agent.md
- [ ] Require verification phase in Lean plans that confirms zero sorries
- [ ] Prohibit phases that intentionally introduce sorries for later resolution

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/lean-research-agent.md` - Add constraints section, update MUST NOT
- `.claude/agents/planner-agent.md` - Add Lean-specific planning constraints

**Verification**:
- Research agent cannot recommend sorry deferral
- Planner agent requires verification phase in Lean plans
- No "placeholder sorry" phases allowed in plans

---

### Phase 4: Update Plan Format and Skill [NOT STARTED]

- **Dependencies:** Phase 2, Phase 3
- **Goal:** Update template formats and add skill-level enforcement gate

**Tasks**:
- [ ] Update "New Sorries" subsection in plan-format.md: "NEVER introduce sorries. If proof gap exists, mark phase [BLOCKED]"
- [ ] Add Lean-specific Testing & Validation items to plan-format.md
- [ ] Add Stage 6b: Zero-Debt Verification to skill-lean-implementation/SKILL.md
- [ ] Update Stage 7 to only proceed if zero-debt verification passes
- [ ] Add rejection logic: if sorry found, set status to "partial" with requires_user_review

**Timing**: 45 minutes

**Files to modify**:
- `.claude/context/core/formats/plan-format.md` - Update New Sorries, add validation items
- `.claude/skills/skill-lean-implementation/SKILL.md` - Add verification stage

**Verification**:
- Plan format prohibits new sorries completely
- Skill has explicit zero-debt verification before status update
- Skill rejects "implemented" status when sorries detected

---

### Phase 5: Documentation and Consistency Check [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Verify all changes are consistent and update any cross-references

**Tasks**:
- [ ] Review all modified files for consistency in terminology
- [ ] Verify CLAUDE.md Proof Debt Policy reference is still accurate
- [ ] Check that error-handling.md doesn't conflict with new blocked status guidance
- [ ] Create summary of changes for completion_summary

**Timing**: 15 minutes

**Files to modify**:
- None expected (verification pass only)

**Verification**:
- All 6 target files updated consistently
- No terminology conflicts
- Cross-references remain valid

## Testing & Validation

- [ ] Zero-debt completion gate clearly stated in policy document
- [ ] Option B patterns explicitly forbidden in all relevant files
- [ ] Agent verification steps documented with grep commands
- [ ] Skill-level enforcement gate added
- [ ] All MUST DO/MUST NOT lists updated consistently
- [ ] No conflicting language remains in any target file

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (created at completion)
- Modified files:
  - `.claude/context/project/lean4/standards/proof-debt-policy.md`
  - `.claude/agents/lean-implementation-agent.md`
  - `.claude/agents/lean-research-agent.md`
  - `.claude/agents/planner-agent.md`
  - `.claude/context/core/formats/plan-format.md`
  - `.claude/skills/skill-lean-implementation/SKILL.md`

## Rollback/Contingency

All changes are to markdown documentation files in .claude/. Rollback via git:
```bash
git checkout HEAD~1 -- .claude/context/project/lean4/standards/proof-debt-policy.md
git checkout HEAD~1 -- .claude/agents/lean-implementation-agent.md
git checkout HEAD~1 -- .claude/agents/lean-research-agent.md
git checkout HEAD~1 -- .claude/agents/planner-agent.md
git checkout HEAD~1 -- .claude/context/core/formats/plan-format.md
git checkout HEAD~1 -- .claude/skills/skill-lean-implementation/SKILL.md
```

If zero-debt policy proves too restrictive, individual files can be reverted or the BLOCKED status guidance can be relaxed.
