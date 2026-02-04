# Research Report: Task #860

**Task**: 860 - Propagate Axiom Policy to Agents and Rules
**Started**: 2026-02-04T12:00:00Z
**Completed**: 2026-02-04T12:45:00Z
**Effort**: 1 hour
**Dependencies**: Task 859 (completed - created proof-debt-policy.md)
**Sources/Inputs**:
- Codebase analysis of target files
- proof-debt-policy.md (created in task 859)
- Existing sorry-related patterns in agents and rules
**Artifacts**:
- specs/860_propagate_axiom_policy_to_agents_rules/reports/research-001.md (this file)
**Standards**: report-format.md, artifact-management.md, tasks.md

## Executive Summary

- Task 859 created proof-debt-policy.md with comprehensive axiom policy and framing rules
- Six target files identified, all containing sorry-related rules that need axiom parallels
- Four patterns require propagation: prohibited phrases, required phrases, MUST NOT rules, and context references
- Most files already reference proof-debt-policy.md but need explicit axiom-specific additions
- verification-workflow.md needs axiom checks parallel to sorry checks in Level 1 verification

## Context & Scope

This research analyzes six target files to identify exact locations where axiom policy additions are needed, mirroring existing sorry policies. The proof-debt-policy.md created in task 859 establishes the source-of-truth for axiom framing rules.

**Target Files**:
1. `.claude/agents/lean-implementation-agent.md`
2. `.claude/agents/lean-research-agent.md`
3. `.claude/rules/lean4.md`
4. `.claude/rules/state-management.md`
5. `.claude/CLAUDE.md`
6. `.claude/context/project/logic/processes/verification-workflow.md`

## Findings

### 1. lean-implementation-agent.md

**Current Sorry References**:
- Line 76-77: Context reference to proof-debt-policy.md (already includes axiom content)
- Line 205: `MUST NOT` rule - "Create empty or placeholder proofs (sorry, admit)"
- Line 217-218: `MUST NOT` rule - "Use 'acceptable sorry' framing"

**Required Axiom Additions**:

| Location | Current Content | Required Addition |
|----------|----------------|-------------------|
| Line 205 | "Create empty or placeholder proofs (sorry, admit)" | Add "or introduce axioms" |
| After Line 217 | Ends with sorry framing rule | Add parallel axiom framing rule |

**Specific Changes**:
- Line 205: Change to "Create empty or placeholder proofs (sorry, admit) or introduce axioms"
- Add new line after 217: `15. **Use 'acceptable axiom' framing** - axioms are technical debt, never "acceptable" (see proof-debt-policy.md)`

### 2. lean-research-agent.md

**Current Sorry References**:
- Line 79: Context reference to proof-debt-policy.md (already includes axiom content)
- Line 199: `MUST NOT` rule - "Use 'acceptable sorry' framing"

**Required Axiom Additions**:

| Location | Current Content | Required Addition |
|----------|----------------|-------------------|
| After Line 199 | Ends with sorry framing rule | Add parallel axiom framing rule |

**Specific Changes**:
- Add new line after 199: `13. **Use 'acceptable axiom' framing** - axioms are technical debt, never "acceptable" (see proof-debt-policy.md)`

### 3. lean4.md

**Current Sorry References**:
- Line 18: MCP tool note referencing sorry workflow
- Line 180: "Check that all theorems compile without `sorry`"
- Line 185: Context reference to proof-debt-policy.md

**Required Axiom Additions**:

| Location | Current Content | Required Addition |
|----------|----------------|-------------------|
| Line 180 | "Check that all theorems compile without `sorry`" | Add axiom check |
| Line 185 | References proof-debt-policy.md | Add explicit axiom note |

**Specific Changes**:
- Line 180: Change to "Check that all theorems compile without `sorry` or new `axiom` declarations"
- After Line 185, add: "- `@.claude/context/project/lean4/standards/proof-debt-policy.md` - Axiom elimination policy"

### 4. state-management.md

**Current Sorry References**:
- Lines 106-123: Repository health section with `sorry_count` and `axiom_count` fields
- Line 119: `sorry_count` definition
- Line 120: `axiom_count` definition

**Analysis**: This file already documents `axiom_count` as a tracked metric. No additions needed - axiom tracking is already present at the state management level.

**Required Axiom Additions**: None - already includes axiom_count in repository_health schema.

### 5. CLAUDE.md

**Current Sorry References**:
- Lines 92-99: state.json structure including `repository_health` with `sorry_count` and `axiom_count`

**Analysis**: CLAUDE.md already includes `axiom_count` in the repository_health example. However, it lacks explicit guidance on axiom policy similar to sorry policy.

**Required Axiom Additions**:

| Location | Current Content | Required Addition |
|----------|----------------|-------------------|
| After Line 99 | End of state.json Structure section | Add axiom policy reference |

**Specific Changes**:
- After the state.json structure (around line 100), add note: "See @.claude/context/project/lean4/standards/proof-debt-policy.md for axiom and sorry handling policies."

### 6. verification-workflow.md

**Current Sorry References**:
- Line 41: "No `sorry` placeholders (unless documented)"
- Lines 312-326: "Step 6: Verify Completeness" with sorry checks
- Lines 320-325: Development tolerance for documented sorries
- Lines 529-549: "Issue 4: Undocumented Sorry"
- Line 558: Success criteria includes "no undocumented `sorry`"

**Required Axiom Additions**:

| Location | Current Content | Required Addition |
|----------|----------------|-------------------|
| Line 41 | "No `sorry` placeholders" | Add axiom check |
| After Line 326 | Sorry development tolerance section | Add axiom parallel section |
| Line 558 | Sorry success criterion | Add axiom success criterion |

**Specific Changes**:
- Line 41: Change to "No `sorry` placeholders (unless documented) and no new `axiom` declarations"
- After Line 326, add new section on axiom verification
- Add success criterion: "No new axiom declarations (or documented with remediation plan)"

## Recommendations

### Implementation Order

1. **Phase 1: Agent Files** (lean-implementation-agent.md, lean-research-agent.md)
   - Add axiom framing MUST NOT rules parallel to sorry rules
   - Straightforward additions at end of MUST NOT sections

2. **Phase 2: Rules Files** (lean4.md)
   - Add axiom checks to testing section
   - Update context reference to clarify dual policy

3. **Phase 3: Workflow Files** (verification-workflow.md)
   - Add axiom parallel to sorry verification steps
   - More substantial changes to Level 1 verification

4. **Phase 4: Top-Level** (CLAUDE.md)
   - Add policy reference note
   - Minimal change for visibility

### Content Templates

**Agent MUST NOT Rule Template**:
```markdown
N. **Use 'acceptable axiom' framing** - axioms are technical debt, never "acceptable" (see proof-debt-policy.md)
```

**Verification Step Template**:
```markdown
### Axiom Verification (parallel to sorry verification)

**Development policy**: No new axioms should be introduced. If structural proof cannot avoid an axiom:
- Document the axiom with clear justification
- Register in SORRY_REGISTRY.md with remediation path
- Note transitive impact on dependent theorems

**Critical**: New axioms are NEVER acceptable as a solution. They represent technical debt requiring structural proof to eliminate.
```

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Inconsistent framing between files | Medium | Low | Use exact phrases from proof-debt-policy.md |
| Missing a sorry reference location | Low | Medium | Grep verified all sorry references |
| Verification workflow changes too complex | Low | Low | Keep changes minimal and parallel to sorry structure |

## Decisions

1. **state-management.md**: No changes needed - already tracks axiom_count
2. **Parallel structure**: Use exact same pattern as sorry rules (prohibited phrases, required phrases)
3. **Reference strategy**: Point to proof-debt-policy.md rather than duplicating policy details

## Appendix

### Files Analyzed

| File | Lines | Sorry References | Axiom Additions Needed |
|------|-------|------------------|------------------------|
| lean-implementation-agent.md | 218 | 3 | 2 |
| lean-research-agent.md | 200 | 2 | 1 |
| lean4.md | 186 | 3 | 2 |
| state-management.md | 272 | 2 | 0 (already has axiom_count) |
| CLAUDE.md | 209 | 1 | 1 |
| verification-workflow.md | 573 | 5 | 3 |

### Key Phrases from proof-debt-policy.md

**Prohibited Axiom Phrases** (from lines 130-135):
- "acceptable axiom" / "axiom is acceptable"
- "axiom-based solution"
- "add axiom to solve"
- "axiom count is acceptable"
- "N acceptable axioms"

**Required Axiom Phrases** (from lines 139-146):
- "axiom as technical debt"
- "axiom requires structural proof"
- "eliminates need for axiom"
- "zero-axiom approach"
- "axiom to be removed via [specific approach]"
- "inherits axiom dependency"
- "publication requires axiom disclosure or elimination"

### Search Queries Used

```bash
grep -r "sorry" .claude/ --include="*.md" | grep -v "/Boneyard/"
```

Found 36 files with sorry references, 6 targeted for this task.
