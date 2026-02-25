# Research Report: Task #921

**Task**: 921 - Enforce Zero Proof Debt Policy for Lean Task Completion
**Started**: 2026-02-24T12:00:00Z
**Completed**: 2026-02-24T12:30:00Z
**Effort**: 1 hour
**Dependencies**: None
**Sources/Inputs**: Codebase analysis of .claude/ directory
**Artifacts**: specs/921_enforce_zero_proof_debt_policy_for_lean_task_completion/reports/research-001.md
**Standards**: report-format.md, proof-debt-policy.md

## Executive Summary

- All 6 target files exist and have been analyzed for current sorry/axiom handling
- Current policy documents correctly characterize sorry/axiom as debt, but lack enforcement gates
- Implementation agents and skills need explicit completion gates prohibiting sorry/axiom
- "Option B" style sorry deferral (from task 916 research) must be explicitly forbidden
- Changes are well-scoped: each file needs 1-3 sections added or modified

## Context & Scope

Task 921 aims to enforce a strict zero-proof-debt completion gate for Lean tasks. This means:

1. **NO sorry may remain** in code produced by a completed Lean task
2. **NO new axioms may be introduced** during Lean task implementation
3. **Option B style sorry deferral is FORBIDDEN** - no "sorry now, fix later" patterns

The task covers these files:
- `.claude/context/project/lean4/standards/proof-debt-policy.md`
- `.claude/agents/lean-implementation-agent.md`
- `.claude/agents/lean-research-agent.md`
- `.claude/agents/planner-agent.md`
- `.claude/context/core/formats/plan-format.md`
- `.claude/skills/skill-lean-implementation/SKILL.md`

## Findings

### 1. proof-debt-policy.md - Current State

**Location**: `.claude/context/project/lean4/standards/proof-debt-policy.md`

**Current Content**:
- Comprehensive sorry/axiom taxonomy (lines 169-207)
- Prohibited/required framing language (lines 68-102, 129-147)
- Discovery protocol for encountering proof debt (lines 241-266)
- Metrics integration with repository health (lines 289-316)

**Gaps Identified**:
1. **No explicit completion gate** - The document describes framing and categories but does not state that Lean task completion REQUIRES zero sorries and zero new axioms
2. **No Option B prohibition** - The document doesn't explicitly forbid "sorry now, fix later" patterns that appeared in task 916 research
3. **Remediation paths describe deferral** - Path D (Axiom Disclosure) implies publication-time deferral is acceptable

**Changes Needed**:
- Add "Completion Gates" section explicitly stating zero-debt requirement for task completion
- Add "Forbidden Patterns" section explicitly banning Option B style sorry deferral
- Clarify that Path D applies only to existing axioms during publication, NOT task implementation

### 2. lean-implementation-agent.md - Current State

**Location**: `.claude/agents/lean-implementation-agent.md`

**Current Content**:
- References proof-debt-policy.md in context references (line 76)
- MUST NOT section includes "Create empty or placeholder proofs (sorry, admit) or introduce axioms" (line 401)
- MUST NOT section includes "Use 'acceptable sorry' framing" and "Use 'acceptable axiom' framing" (lines 410-411)
- MUST DO includes "run `lake build` before returning implemented status" (line 380)
- MUST DO includes "verify proofs are actually complete ('no goals')" (line 381)

**Gaps Identified**:
1. **No explicit sorry-count gate** - Says don't create sorries, but doesn't verify zero sorries before completion
2. **No axiom-count verification** - Says don't introduce axioms, but doesn't verify no new axioms
3. **No hard blocker for sorry detection** - A sorry in output should trigger `requires_user_review: true`
4. **Partial status allowed with sorry** - Current blocker detection doesn't flag sorries as hard blockers

**Changes Needed**:
- Add "Zero-Debt Completion Gate" section with explicit verification steps
- Add sorry detection to hard blocker list (mathematically_false, proof_impossible, etc.)
- Add verification commands: `grep -r "sorry" <modified files>` and `grep -r "^axiom " <modified files>`
- Update MUST DO: "Verify zero sorries in modified files before returning implemented status"
- Update MUST NOT: "Return implemented status if any sorry remains in modified files"

### 3. lean-research-agent.md - Current State

**Location**: `.claude/agents/lean-research-agent.md`

**Current Content**:
- References proof-debt-policy.md in context references (line 80)
- MUST NOT includes "Use 'acceptable sorry' framing" and "Use 'acceptable axiom' framing" (lines 200-201)

**Gaps Identified**:
1. **No guidance on Option B prohibition** - Research may suggest "sorry now, fix later" as approach
2. **No explicit statement that research should NOT recommend sorry deferral**

**Changes Needed**:
- Add section "Research Constraints for Lean Tasks" stating:
  - Research MUST NOT recommend approaches that defer proof obligations
  - Research MUST NOT suggest "Option B" style sorry patterns
  - If a proof gap cannot be filled, report as BLOCKER not as "acceptable sorry"
- Update MUST NOT to include "Recommend sorry deferral patterns (Option B style)"

### 4. planner-agent.md - Current State

**Location**: `.claude/agents/planner-agent.md`

**Current Content**:
- General planning guidance without Lean-specific completion criteria
- References plan-format.md (line 41) which has Sorry/Axiom Characterization sections
- No explicit mention of zero-debt requirement for Lean plans

**Gaps Identified**:
1. **No Lean-specific completion criteria** - Plans don't specify that implementation MUST end with zero sorries
2. **No verification phase requirement** - Plans should require a zero-debt verification phase
3. **No Option B prohibition** - Planner might create plans with "sorry placeholder" phases

**Changes Needed**:
- Add "Lean Task Planning Constraints" section:
  - All Lean plans MUST include a verification phase that confirms zero sorries
  - Plans MUST NOT include phases that intentionally introduce sorries for later resolution
  - Plans MUST NOT use Option B style "defer proof obligation" patterns
  - Testing & Validation section MUST include "Zero sorries in modified files"

### 5. plan-format.md - Current State

**Location**: `.claude/context/core/formats/plan-format.md`

**Current Content**:
- Sorry Characterization section (lines 153-200) with framing rules
- Axiom Characterization section (lines 202-249) with framing rules
- Both sections describe handling existing debt, not completion gates
- New Sorries subsection says "None expected. If proof complexity requires temporary sorry, will document with remediation timeline." (line 242)
- New Axioms subsection says "NEVER introduce new axioms" (line 242)

**Gaps Identified**:
1. **"Temporary sorry" is still allowed** - Line 242 implies sorries may be introduced if documented
2. **No completion gate requirement** - Format doesn't mandate zero-debt verification
3. **Testing & Validation section is generic** - Should require zero-debt check for Lean

**Changes Needed**:
- Update "New Sorries" subsection: "NEVER introduce sorries. If proof gap exists, mark phase [BLOCKED] and report as hard blocker."
- Update "New Axioms" subsection: Keep current text, already says NEVER
- Add to Testing & Validation section for Lean plans:
  - `[ ] Zero sorries in all modified Lean files`
  - `[ ] Zero new axioms introduced`
  - `[ ] lake build succeeds with no sorry warnings`
- Add "Completion Gate" subsection stating implementation cannot be marked complete with proof debt

### 6. skill-lean-implementation/SKILL.md - Current State

**Location**: `.claude/skills/skill-lean-implementation/SKILL.md`

**Current Content**:
- Stage 6a: Continuous Handoff Loop with stop conditions (lines 227-340)
- Stage 7: Update Task Status (lines 343-396) - updates to "completed" if status is "implemented"
- No verification of zero sorries before completion
- No check for new axioms before completion

**Gaps Identified**:
1. **No zero-debt verification in postflight** - Skill updates status to completed without verifying no sorries
2. **No axiom check** - Skill doesn't verify no new axioms were introduced
3. **No rejection of "implemented" status with sorries** - If agent returns implemented but code has sorries, skill should reject

**Changes Needed**:
- Add Stage 6b: Zero-Debt Verification before status update
  - Run `grep -r "sorry" Theories/` on modified paths
  - Run `grep -r "^axiom " Theories/` comparing before/after
  - If any sorry found in new/modified code, reject "implemented" status
  - Set status to "partial" with `requires_user_review: true` and `review_reason: "Sorry found in completed code"`
- Update Stage 7 to only proceed if Stage 6b passes

## Option B Context (Task 916 Reference)

From task 916 research reports, "Option B" refers to a pattern where:
- Sorries are introduced as placeholders during implementation
- Full proofs are deferred to a later phase or task
- The approach was explicitly rejected in research-013: "Option A... without introducing temporary proof debt"

This pattern MUST be explicitly forbidden because:
1. It creates proof debt that propagates transitively
2. It violates the principle that completed tasks should not increase sorry count
3. It normalizes "acceptable sorry" thinking

## Decisions

1. **Zero-debt is MANDATORY for Lean task completion** - No exceptions
2. **Option B patterns are FORBIDDEN** - No "sorry now, fix later" approaches
3. **Hard blocker on sorry detection** - Finding a sorry should trigger `requires_user_review: true`
4. **Verification is agent responsibility** - Agent must verify before returning "implemented"
5. **Skill enforces gate** - Skill rejects "implemented" if sorries detected

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Agent bypasses verification | Low | High | Skill-level enforcement as backup |
| Complex proofs genuinely stuck | Medium | Medium | Use `partial` status with hard blocker, don't complete with sorry |
| False positives (sorry in comments/strings) | Low | Low | Grep for `sorry` tactic pattern specifically |
| Performance overhead of grep checks | Low | Low | Only check modified files, not entire codebase |

## Implementation Summary

**Files to modify**: 6 files
**Total sections to add/modify**: ~12-15 sections
**Estimated effort**: 2-3 hours

### Per-File Changes Summary

| File | Changes Needed |
|------|---------------|
| proof-debt-policy.md | Add Completion Gates section, add Forbidden Patterns section |
| lean-implementation-agent.md | Add Zero-Debt Completion Gate section, update MUST DO/MUST NOT |
| lean-research-agent.md | Add Research Constraints section, update MUST NOT |
| planner-agent.md | Add Lean Task Planning Constraints section |
| plan-format.md | Update New Sorries subsection, add Testing & Validation items |
| skill-lean-implementation/SKILL.md | Add Stage 6b: Zero-Debt Verification |

## Appendix

### Search Queries Used
- `grep -r "sorry" .claude/agents/` - Find sorry references in agents
- `grep -r "Option B" specs/916_*` - Find Option B references
- `grep -r "completion.*gate" .claude/` - Find existing completion gates
- File reads of all 6 target files

### Key References
- proof-debt-policy.md - Lines 68-102 (framing rules), 169-207 (categories)
- lean-implementation-agent.md - Lines 373-414 (MUST DO/MUST NOT)
- task 916 research-013 - Option B pattern definition and rejection
- task 916 research-010 - "Deferred concretization" as Option B variant
