# Implementation Plan: Task #921

- **Task**: 921 - Enforce Zero Proof Debt Policy for Lean Task Completion
- **Status**: [COMPLETED]
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

### Phase 1: Update Policy Foundation [COMPLETED]

- **Dependencies:** None
- **Goal:** Establish the zero-debt completion gate rule in the canonical policy document

**Tasks**:
- [x] Add "Completion Gates" section to proof-debt-policy.md stating zero-debt requirement
- [x] Add "Forbidden Patterns" section explicitly banning Option B style sorry deferral
- [x] Clarify that Path D (Axiom Disclosure) applies only to existing axioms at publication, not task implementation
- [x] Review and update any conflicting language in existing sections

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/project/lean4/standards/proof-debt-policy.md` - Add 2 new sections, clarify existing

**Verification**:
- Policy document has "Completion Gates" section with zero-debt rule
- Policy document has "Forbidden Patterns" section with Option B prohibition
- No conflicting language remains suggesting sorries are acceptable

**Progress:**

**Session: 2026-02-24, sess_1771980315_7bc399**
- Added: `Completion Gates` section with zero-debt requirement, enforcement points table, soft vs hard blocker criteria
- Added: `Forbidden Patterns` section with explicit Option B sorry deferral prohibition and new axiom prohibition
- Fixed: Path D (Axiom Disclosure) clarified to apply only to publication decisions on pre-existing axioms, not task implementation

---

### Phase 2: Update Lean Implementation Agent [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Add verification requirements to the agent that executes Lean implementations

**Tasks**:
- [x] Add "Zero-Debt Completion Gate" section with explicit verification steps
- [x] Add sorry detection to hard blocker criteria (requires_user_review: true)
- [x] Update MUST DO: "Verify zero sorries in modified files before returning implemented status"
- [x] Update MUST NOT: "Return implemented status if any sorry remains in modified files"
- [x] Add verification commands: `grep -r "sorry" <modified files>`

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/lean-implementation-agent.md` - Add verification section, update MUST DO/MUST NOT

**Verification**:
- Agent has explicit zero-debt verification section
- Sorry in output triggers hard blocker status
- MUST DO/MUST NOT lists include zero-debt requirements

**Progress:**

**Session: 2026-02-24, sess_1771980315_7bc399**
- Added: `Zero-Debt Completion Gate (MANDATORY)` section with verification steps and sorry detection commands
- Added: `sorry_remains` and `new_axiom_required` to hard blocker table
- Added: MUST DO items 18-19 for zero-debt verification
- Added: MUST NOT items 18-20 prohibiting implemented status with sorries, new axioms, or Option B deferral

---

### Phase 3: Update Research and Planning Agents [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Ensure upstream agents do not recommend or plan sorry deferral patterns

**Tasks**:
- [x] Add "Research Constraints for Lean Tasks" section to lean-research-agent.md
- [x] Update lean-research-agent.md MUST NOT to include "Recommend sorry deferral patterns (Option B style)"
- [x] Add "Lean Task Planning Constraints" section to planner-agent.md
- [x] Require verification phase in Lean plans that confirms zero sorries
- [x] Prohibit phases that intentionally introduce sorries for later resolution

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/lean-research-agent.md` - Add constraints section, update MUST NOT
- `.claude/agents/planner-agent.md` - Add Lean-specific planning constraints

**Verification**:
- Research agent cannot recommend sorry deferral
- Planner agent requires verification phase in Lean plans
- No "placeholder sorry" phases allowed in plans

**Progress:**

**Session: 2026-02-24, sess_1771980315_7bc399**
- Added: `Research Constraints for Lean Tasks` section to lean-research-agent.md with forbidden recommendations and required approach
- Added: MUST NOT items 14-16 to lean-research-agent.md prohibiting sorry deferral recommendations
- Added: `Lean Task Planning Constraints` section (Stage 4a) to planner-agent.md with forbidden/required patterns
- Added: MUST DO items 11-13 to planner-agent.md for Lean task planning
- Added: MUST NOT items 12-14 to planner-agent.md prohibiting planned sorries

---

### Phase 4: Update Plan Format and Skill [COMPLETED]

- **Dependencies:** Phase 2, Phase 3
- **Goal:** Update template formats and add skill-level enforcement gate

**Tasks**:
- [x] Update "New Sorries" subsection in plan-format.md: "NEVER introduce sorries. If proof gap exists, mark phase [BLOCKED]"
- [x] Add Lean-specific Testing & Validation items to plan-format.md
- [x] Add Stage 6b: Zero-Debt Verification to skill-lean-implementation/SKILL.md
- [x] Update Stage 7 to only proceed if zero-debt verification passes
- [x] Add rejection logic: if sorry found, set status to "partial" with requires_user_review

**Timing**: 45 minutes

**Files to modify**:
- `.claude/context/core/formats/plan-format.md` - Update New Sorries, add validation items
- `.claude/skills/skill-lean-implementation/SKILL.md` - Add verification stage

**Verification**:
- Plan format prohibits new sorries completely
- Skill has explicit zero-debt verification before status update
- Skill rejects "implemented" status when sorries detected

**Progress:**

**Session: 2026-02-24, sess_1771980315_7bc399**
- Fixed: Sorry Characterization section in plan-format.md now states NEVER introduce new sorries
- Added: Lean-specific Testing & Validation items (zero-debt check, axiom check, build verification)
- Added: Stage 6b Zero-Debt Verification Gate to skill-lean-implementation/SKILL.md with sorry/axiom/build checks
- Fixed: Stage 7 header clarified to only proceed if Stage 6b passed
- Added: Rejection logic in Stage 6b that overrides "implemented" to "partial" with requires_user_review on gate failure

---

### Phase 5: Documentation and Consistency Check [COMPLETED]

- **Dependencies:** Phase 4
- **Goal:** Verify all changes are consistent and update any cross-references

**Tasks**:
- [x] Review all modified files for consistency in terminology
- [x] Verify CLAUDE.md Proof Debt Policy reference is still accurate
- [x] Check that error-handling.md doesn't conflict with new blocked status guidance
- [x] Create summary of changes for completion_summary

**Timing**: 15 minutes

**Files to modify**:
- None expected (verification pass only)

**Verification**:
- All 6 target files updated consistently
- No terminology conflicts
- Cross-references remain valid

**Progress:**

**Session: 2026-02-24, sess_1771980315_7bc399**
- Completed: Consistency verification across all 6 modified files
- Completed: CLAUDE.md reference to proof-debt-policy.md confirmed valid
- Completed: error-handling.md checked for conflicts (none found)
- Added: implementation-summary-20260224.md with full change documentation

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
