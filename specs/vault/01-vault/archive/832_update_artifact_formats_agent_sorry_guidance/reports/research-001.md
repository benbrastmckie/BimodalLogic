# Research Report: Update artifact formats and agent definitions for consistent sorry handling

- **Task**: 832 - update_artifact_formats_agent_sorry_guidance
- **Started**: 2026-02-03T12:00:00Z
- **Completed**: 2026-02-03T12:45:00Z
- **Effort**: 45 minutes
- **Dependencies**: Task 831 (strengthen_sorry_debt_policy_language) - provides foundation
- **Sources/Inputs**:
  - `.claude/context/core/formats/report-format.md`
  - `.claude/context/core/formats/plan-format.md`
  - `.claude/context/project/lean4/standards/sorry-debt-policy.md`
  - `.claude/agents/lean-research-agent.md`
  - `.claude/agents/lean-implementation-agent.md`
  - `specs/831_strengthen_sorry_debt_policy_language/reports/research-001.md`
- **Artifacts**: specs/832_update_artifact_formats_agent_sorry_guidance/reports/research-001.md
- **Standards**: report-format.md, artifact-formats.md

## Executive Summary

- Found 6 files requiring updates for consistent sorry characterization guidance
- report-format.md and plan-format.md need new "Sorry Characterization" sections
- lean-research-agent.md and lean-implementation-agent.md need sorry-debt-policy.md moved from "Load for Sorry Handling" to "Always Load"
- Both agent Critical Requirements sections need explicit MUST NOT prohibition against "acceptable sorry" framing
- Task 831 research provides ready-to-use prohibited/required framing examples

## Context & Scope

Task 832 requires updating artifact formats and agent definitions to ensure agents consistently characterize sorries without using "acceptable" language. The specific requirements are:

1. Add "Sorry Characterization" section to report-format.md and plan-format.md
2. Move sorry-debt-policy.md from optional to mandatory "Always Load" context in lean agents
3. Add explicit prohibition against "acceptable" framing in agent critical requirements

This task complements task 831 (updating sorry-debt-policy.md itself) by propagating the policy into artifact templates and agent instructions.

## Findings

### 1. Current State of report-format.md

**Location**: `.claude/context/core/formats/report-format.md`

**Current Structure** (90 lines):
```
1. Metadata (required)
2. Project Context (Lean only)
3. Executive Summary
4. Context & Scope
5. Findings
6. Decisions
7. Recommendations
8. Risks & Mitigations
9. Appendix
```

**Observation**: No sorry-related guidance exists. The structure section (lines 17-26) defines the ordered sections but has no entry for sorry characterization.

**Insertion Point**: After "Findings" section description (line 22), add a new entry for "Sorry Characterization (Lean reports only)".

**Alternative**: Create a dedicated subsection after "Project Context (Lean only)" section (lines 27-37).

### 2. Current State of plan-format.md

**Location**: `.claude/context/core/formats/plan-format.md`

**Current Structure** (139 lines):
```
1. Metadata block
2. Plan Metadata Schema
3. Overview (with Research Integration subsection)
4. Goals & Non-Goals
5. Risks & Mitigations
6. Implementation Phases
7. Testing & Validation
8. Artifacts & Outputs
9. Rollback/Contingency
```

**Observation**: No sorry-related guidance. Plans focus on implementation mechanics.

**Insertion Point**: After "Risks & Mitigations" (line 69), before Implementation Phases. This positions sorry assessment before implementation begins.

### 3. Current State of lean-research-agent.md

**Location**: `.claude/agents/lean-research-agent.md`

**Current Context References** (lines 72-87):
```markdown
## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md` - Full MCP tool reference
- `@.claude/context/core/formats/return-metadata-file.md` - Metadata file schema

**Load After Stage 0**:
- `@.claude/context/project/lean4/agents/lean-research-flow.md` - Detailed execution stages

**Load When Creating Report**:
- `@.claude/context/core/formats/report-format.md` - Research report structure

**Load for Sorry Handling**:
- `@.claude/context/project/lean4/standards/sorry-debt-policy.md` - Sorry remediation policy
```

**Issue**: sorry-debt-policy.md is in optional "Load for Sorry Handling" section. Since research reports must always characterize sorries correctly, this should be mandatory.

**Current Critical Requirements** (lines 175-201): Has MUST DO (10 items) and MUST NOT (11 items) sections but no sorry-related prohibitions.

### 4. Current State of lean-implementation-agent.md

**Location**: `.claude/agents/lean-implementation-agent.md`

**Current Context References** (lines 69-91):
```markdown
## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md` - Full MCP tool reference
- `@.claude/context/core/formats/return-metadata-file.md` - Metadata file schema

**Load After Stage 0**:
- `@.claude/context/project/lean4/agents/lean-implementation-flow.md` - Detailed execution stages

**Load for Implementation**:
- `@.claude/context/project/lean4/patterns/tactic-patterns.md` - Common tactic usage patterns
- `@.claude/context/project/lean4/style/lean4-style-guide.md` - Code style conventions

**Load for Sorry Handling**:
- `@.claude/context/project/lean4/standards/sorry-debt-policy.md` - Sorry remediation policy

**Load for Specific Needs**:
- `@Logos/Layer0/` files - When implementing Layer 0 proofs
...
```

**Issue**: Same as research agent - sorry-debt-policy.md is optional when it should be mandatory.

**Current Critical Requirements** (lines 188-219): Has MUST DO (13 items) and MUST NOT (13 items) sections. Item 5 mentions "Create empty or placeholder proofs (sorry, admit)" but this is about not creating new sorries, not about characterization.

### 5. sorry-debt-policy.md Content Analysis

**Key Content for Artifact Guidance** (from task 831 research):

The policy contains (or will contain after task 831):
- Philosophy section explaining mathematical debt
- Transitive Sorry Inheritance section
- Sorry Categories taxonomy
- Remediation Paths (A, B, C)
- Discovery Protocol

**Missing in current policy**: Explicit characterization guidance for reports/plans. Task 831 adds a "Characterizing Sorries in Reports and Plans" section.

**Prohibited phrases** (from task 831 research):
- "acceptable sorry" / "sorry is acceptable"
- "acceptable limitation"
- "sorry is fine" / "okay to have sorry"
- "sorry count is acceptable"
- "<N sorries acceptable"

**Required framing** (from task 831 research):
- "tolerated during development"
- "technical debt requiring documentation"
- "blocks publication if not resolved"
- "inherited by all dependents"

### 6. Pattern for "Always Load" vs "Load for X"

Analyzed across all agent files. The pattern is:

**Always Load**: Context that every invocation of the agent requires
**Load for X**: Context needed only in specific scenarios

Examples:
- `return-metadata-file.md` is Always Load (every agent writes metadata)
- `plan-format.md` is Always Load in planner-agent.md
- `report-format.md` is "Load When Creating Report" in lean-research-agent.md

**Recommendation**: Since Lean research and implementation inherently involve potential sorries, and incorrect characterization creates persistent artifacts, sorry-debt-policy.md should be Always Load for Lean agents.

## Decisions

1. **Sorry Characterization section placement in report-format.md**: Add as new subsection after "Project Context (Lean only)" since both are Lean-specific. Number as section 1a or integrate into Project Context.

2. **Sorry Characterization section placement in plan-format.md**: Add as new numbered section after "Risks & Mitigations" (section 7). Plans should assess sorry impact before defining implementation phases.

3. **Context promotion pattern**: Move sorry-debt-policy.md entry from "Load for Sorry Handling" to "Always Load" in both agents. Remove the now-empty "Load for Sorry Handling" section.

4. **Critical Requirements additions**: Add to MUST NOT section (not MUST DO) since prohibitions are clearer as "don't do X" statements.

## Recommendations

### Update 1: report-format.md - Add Sorry Characterization Section

**Location**: After line 37 (after Project Context section)

**Add new section**:
```markdown
## Sorry Characterization (Lean reports only)

**Applicability**: Include this section only for Lean research reports where sorries are discovered or relevant.

**Purpose**: Ensures consistent, accurate characterization of sorry debt without "acceptable" framing.

**Required Elements**:
1. **Sorry count**: Number of sorries directly in scope
2. **Categories**: Map each sorry to sorry-debt-policy.md taxonomy
3. **Transitive impact**: What depends on these sorries
4. **Remediation path**: For each sorry, specify Path A (complete), B (refactor), or C (boneyard)

**Framing Rules** (per sorry-debt-policy.md):
- NEVER use: "acceptable sorry", "sorry is acceptable", "acceptable limitation", "<N acceptable"
- ALWAYS use: "tolerated during development", "technical debt", "blocks publication", "inherited by dependents"

**Example**:
```
## Sorry Characterization

- **Direct sorries**: 1 (modal_backward in Construction.lean)
- **Category**: Construction Assumption - Tolerated During Development
- **Transitive impact**: Inherited by Completeness.lean (blocks publication claim)
- **Remediation**: Path B (multi-family refactoring) or Path A (direct proof)
```
```

### Update 2: plan-format.md - Add Sorry Characterization Section

**Location**: After line 69 (after "Risks & Mitigations" section description)

**Add new section**:
```markdown
7. **Sorry Characterization (Lean plans only)** - sorry assessment before implementation.
```

**Add detailed section later in document** (after Risks & Mitigations format example, around line 118):
```markdown
## Sorry Characterization (Lean plans only)

Include this section for Lean implementation plans when:
- The task involves code with known sorries
- The implementation may introduce new sorries
- The task explicitly addresses sorry remediation

**Required Elements**:
1. **Baseline**: Current sorry count in affected files
2. **Expected outcome**: Target sorry count (should be <= baseline)
3. **Transitive awareness**: Dependencies that will inherit remaining sorries
4. **Publication impact**: Whether this blocks any publication claims

**Framing Rules** (per sorry-debt-policy.md):
- NEVER use: "acceptable sorry", "acceptable outcome", "<N acceptable"
- ALWAYS use: "tolerated during development", "requires remediation", "blocks publication"

**Example**:
```
## Sorry Characterization (Lean)
- **Baseline**: 2 sorries in Construction.lean
- **Expected outcome**: 1 sorry (modal_backward remains)
- **Remaining sorry status**: Tolerated as construction assumption; blocks transitive sorry-freedom
- **Remediation path**: Future task for multi-family approach (Path B)
```
```

### Update 3: lean-research-agent.md - Move sorry-debt-policy.md to Always Load

**Change lines 76-87**:

**FROM**:
```markdown
**Always Load**:
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md` - Full MCP tool reference
- `@.claude/context/core/formats/return-metadata-file.md` - Metadata file schema

**Load After Stage 0**:
- `@.claude/context/project/lean4/agents/lean-research-flow.md` - Detailed execution stages

**Load When Creating Report**:
- `@.claude/context/core/formats/report-format.md` - Research report structure

**Load for Sorry Handling**:
- `@.claude/context/project/lean4/standards/sorry-debt-policy.md` - Sorry remediation policy
```

**TO**:
```markdown
**Always Load**:
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md` - Full MCP tool reference
- `@.claude/context/core/formats/return-metadata-file.md` - Metadata file schema
- `@.claude/context/project/lean4/standards/sorry-debt-policy.md` - Sorry debt policy (REQUIRED for correct characterization)

**Load After Stage 0**:
- `@.claude/context/project/lean4/agents/lean-research-flow.md` - Detailed execution stages

**Load When Creating Report**:
- `@.claude/context/core/formats/report-format.md` - Research report structure
```

### Update 4: lean-research-agent.md - Add MUST NOT prohibition

**Add to MUST NOT section** (after line 200):
```markdown
12. **Use "acceptable sorry" framing** - never describe sorries as acceptable, fine, okay, or use "<N acceptable" patterns
```

### Update 5: lean-implementation-agent.md - Move sorry-debt-policy.md to Always Load

**Change lines 73-91**:

**FROM**:
```markdown
**Always Load**:
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md` - Full MCP tool reference
- `@.claude/context/core/formats/return-metadata-file.md` - Metadata file schema

**Load After Stage 0**:
- `@.claude/context/project/lean4/agents/lean-implementation-flow.md` - Detailed execution stages

**Load for Implementation**:
- `@.claude/context/project/lean4/patterns/tactic-patterns.md` - Common tactic usage patterns
- `@.claude/context/project/lean4/style/lean4-style-guide.md` - Code style conventions

**Load for Sorry Handling**:
- `@.claude/context/project/lean4/standards/sorry-debt-policy.md` - Sorry remediation policy

**Load for Specific Needs**:
...
```

**TO**:
```markdown
**Always Load**:
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md` - Full MCP tool reference
- `@.claude/context/core/formats/return-metadata-file.md` - Metadata file schema
- `@.claude/context/project/lean4/standards/sorry-debt-policy.md` - Sorry debt policy (REQUIRED for correct characterization)

**Load After Stage 0**:
- `@.claude/context/project/lean4/agents/lean-implementation-flow.md` - Detailed execution stages

**Load for Implementation**:
- `@.claude/context/project/lean4/patterns/tactic-patterns.md` - Common tactic usage patterns
- `@.claude/context/project/lean4/style/lean4-style-guide.md` - Code style conventions

**Load for Specific Needs**:
...
```

### Update 6: lean-implementation-agent.md - Add MUST NOT prohibition

**Add to MUST NOT section** (after line 218):
```markdown
14. **Use "acceptable sorry" framing** - never describe sorries as acceptable, fine, okay, or use "<N acceptable" patterns
```

## Summary of Changes

| File | Change Type | Description |
|------|-------------|-------------|
| report-format.md | Add section | "Sorry Characterization (Lean only)" with framing rules |
| plan-format.md | Add section | "Sorry Characterization (Lean only)" with framing rules |
| lean-research-agent.md | Move context | sorry-debt-policy.md from optional to Always Load |
| lean-research-agent.md | Add prohibition | MUST NOT #12: "acceptable sorry" framing |
| lean-implementation-agent.md | Move context | sorry-debt-policy.md from optional to Always Load |
| lean-implementation-agent.md | Add prohibition | MUST NOT #14: "acceptable sorry" framing |

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Report/plan templates become verbose | Keep sorry section optional, only when sorries are relevant |
| Agents ignore mandatory context | Policy is also enforced via Critical Requirements prohibition |
| Existing reports use "acceptable" language | Forward-only; archives are historical record |
| Circular dependency with task 831 | Task 831 updates policy itself; task 832 propagates to artifacts/agents |

## Appendix

### Files Analyzed

**Primary (format definitions)**:
- `.claude/context/core/formats/report-format.md` - 90 lines
- `.claude/context/core/formats/plan-format.md` - 139 lines

**Primary (agent definitions)**:
- `.claude/agents/lean-research-agent.md` - 201 lines
- `.claude/agents/lean-implementation-agent.md` - 219 lines

**Reference (policy)**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md` - 128 lines
- `specs/831_strengthen_sorry_debt_policy_language/reports/research-001.md` - 311 lines

### Search Commands Used

```bash
# Find format files
fd -e md report-format .claude/
fd -e md plan-format .claude/

# Find agent files
fd -e md lean.*agent .claude/

# Check sorry references
grep -r "sorry" .claude/ --include="*.md" | wc -l  # 34 files

# Check context loading patterns
grep -A2 "Always Load\|Load for\|Load When" .claude/agents/*.md
```

### Related Tasks

- Task 831: Updates sorry-debt-policy.md content (prerequisite)
- Task 832: Propagates policy to artifacts and agents (this task)
