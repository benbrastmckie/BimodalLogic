# Implementation Plan: Task #860

- **Task**: 860 - Propagate Axiom Policy to Agents and Rules
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: Task 859 (completed - proof-debt-policy.md)
- **Research Inputs**: specs/860_propagate_axiom_policy_to_agents_rules/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Propagate the axiom policy established in proof-debt-policy.md to six target files across agents, rules, and workflows. Changes mirror existing sorry policies with parallel axiom-specific rules and checks. The research identified specific line locations and content templates for each file.

### Research Integration

Key findings from research:
- state-management.md already tracks axiom_count, no changes needed
- Agent files need MUST NOT rules parallel to sorry framing rules
- lean4.md needs axiom check in testing section
- verification-workflow.md needs axiom verification parallel to sorry verification
- All changes should reference proof-debt-policy.md rather than duplicating policy

## Goals & Non-Goals

**Goals**:
- Add axiom MUST NOT rules to agent files parallel to sorry rules
- Add axiom checks to lean4.md testing section
- Add axiom verification to verification-workflow.md Level 1 checks
- Add policy reference to CLAUDE.md
- Maintain consistent framing across all files

**Non-Goals**:
- Modifying state-management.md (already has axiom_count)
- Duplicating full policy content (reference proof-debt-policy.md instead)
- Changing existing sorry policies

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Inconsistent framing between files | Medium | Low | Use exact phrases from proof-debt-policy.md |
| Missing a required location | Low | Medium | Research grep verified all locations |
| Breaking existing functionality | Low | Low | Additions only, no deletions |

## Implementation Phases

### Phase 1: Agent Files [NOT STARTED]

**Goal**: Add axiom MUST NOT rules to lean-implementation-agent.md and lean-research-agent.md

**Tasks**:
- [ ] Update lean-implementation-agent.md line 205 to include axioms
- [ ] Add axiom framing MUST NOT rule after line 217 in lean-implementation-agent.md
- [ ] Add axiom framing MUST NOT rule after line 199 in lean-research-agent.md

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/lean-implementation-agent.md` - Add axiom to placeholder rule, add axiom framing rule
- `.claude/agents/lean-research-agent.md` - Add axiom framing rule

**Specific Changes**:

lean-implementation-agent.md:
- Line 205: Change "Create empty or placeholder proofs (sorry, admit)" to "Create empty or placeholder proofs (sorry, admit) or introduce axioms"
- After line 217: Add `15. **Use 'acceptable axiom' framing** - axioms are technical debt, never "acceptable" (see proof-debt-policy.md)`

lean-research-agent.md:
- After line 199: Add `13. **Use 'acceptable axiom' framing** - axioms are technical debt, never "acceptable" (see proof-debt-policy.md)`

**Verification**:
- grep for "acceptable axiom" in both agent files confirms additions
- Numbering of MUST NOT rules is sequential

---

### Phase 2: Lean4 Rules [NOT STARTED]

**Goal**: Add axiom checks to lean4.md testing and verification section

**Tasks**:
- [ ] Update line 180 to include axiom check
- [ ] Add explicit axiom policy context reference after line 185

**Timing**: 20 minutes

**Files to modify**:
- `.claude/rules/lean4.md` - Add axiom to testing checklist, add policy reference

**Specific Changes**:

- Line 180: Change "Check that all theorems compile without `sorry`" to "Check that all theorems compile without `sorry` or new `axiom` declarations"
- After line 185: Add "- `@.claude/context/project/lean4/standards/proof-debt-policy.md` - Axiom elimination policy"

**Verification**:
- grep for "axiom declarations" in lean4.md confirms addition
- Context reference section includes axiom policy

---

### Phase 3: Verification Workflow [NOT STARTED]

**Goal**: Add axiom verification parallel to sorry verification in verification-workflow.md

**Tasks**:
- [ ] Update line 41 to include axiom check
- [ ] Add axiom verification section after line 326
- [ ] Add axiom success criterion at line 558 area

**Timing**: 45 minutes

**Files to modify**:
- `.claude/context/project/logic/processes/verification-workflow.md` - Add axiom checks to Level 1 verification

**Specific Changes**:

- Line 41: Change "No `sorry` placeholders (unless documented)" to "No `sorry` placeholders (unless documented) and no new `axiom` declarations"
- After line 326: Add new axiom verification subsection:
  ```markdown
  ### Axiom Verification

  **Development policy**: No new axioms should be introduced. If structural proof cannot avoid an axiom:
  - Document the axiom with clear justification
  - Register in SORRY_REGISTRY.md with remediation path
  - Note transitive impact on dependent theorems

  **Critical**: New axioms are NEVER acceptable as a solution. They represent technical debt requiring structural proof to eliminate. See @.claude/context/project/lean4/standards/proof-debt-policy.md.
  ```
- Add success criterion: "No new axiom declarations (or documented with remediation plan)"

**Verification**:
- grep for "Axiom Verification" confirms new section
- grep for "axiom declarations" confirms success criterion

---

### Phase 4: Top-Level Documentation [NOT STARTED]

**Goal**: Add policy reference to CLAUDE.md for visibility

**Tasks**:
- [ ] Add axiom policy reference note after state.json structure section

**Timing**: 15 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Add policy reference

**Specific Changes**:

- After line 99 (end of state.json Structure section): Add note:
  ```markdown
  **Proof Debt Policy**: See @.claude/context/project/lean4/standards/proof-debt-policy.md for axiom and sorry handling policies.
  ```

**Verification**:
- grep for "Proof Debt Policy" in CLAUDE.md confirms addition

---

### Phase 5: Verification [NOT STARTED]

**Goal**: Verify all changes are consistent and complete

**Tasks**:
- [ ] Grep all modified files for "axiom" to verify additions
- [ ] Verify no duplicate or conflicting rules exist
- [ ] Check that all references to proof-debt-policy.md are correct paths

**Timing**: 10 minutes

**Verification**:
- All 5 modified files contain appropriate axiom references
- proof-debt-policy.md path is consistent across all references
- state-management.md unchanged (already has axiom_count)

## Testing & Validation

- [ ] All modified files valid markdown (no syntax errors)
- [ ] grep "acceptable axiom" returns matches in agent files
- [ ] grep "axiom declarations" returns matches in lean4.md and verification-workflow.md
- [ ] grep "Proof Debt Policy" returns match in CLAUDE.md
- [ ] All proof-debt-policy.md references use correct path

## Artifacts & Outputs

- Modified: `.claude/agents/lean-implementation-agent.md`
- Modified: `.claude/agents/lean-research-agent.md`
- Modified: `.claude/rules/lean4.md`
- Modified: `.claude/context/project/logic/processes/verification-workflow.md`
- Modified: `.claude/CLAUDE.md`
- Unchanged: `.claude/rules/state-management.md` (already has axiom_count)

## Rollback/Contingency

All changes are additions to existing files. If issues arise:
1. git diff shows exact changes made
2. git checkout -- {file} reverts individual files
3. No deletions or structural changes to rollback
