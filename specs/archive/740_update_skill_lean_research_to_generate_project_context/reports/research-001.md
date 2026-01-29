# Research Report: Task #740

**Task**: 740 - Update skill-lean-research to generate Project Context section
**Started**: 2026-01-29T12:00:00Z
**Completed**: 2026-01-29T12:15:00Z
**Effort**: 30 minutes
**Priority**: Medium
**Dependencies**: 739 (completed - report-format.md updated)
**Sources/Inputs**:
- skill-lean-research/SKILL.md
- report-format.md
- lean-research-flow.md
- project-overview.md
**Artifacts**:
- specs/740_update_skill_lean_research_to_generate_project_context/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- Task 739 added Project Context section specification to report-format.md with four fields: Upstream Dependencies, Downstream Dependents, Alternative Paths, and Potential Extensions
- skill-lean-research/SKILL.md Stage 7 currently generates reports WITHOUT the Project Context section
- lean-research-flow.md Stage 5 documentation also lacks the Project Context section in its template
- The project-overview.md provides orientation information that should inform context generation
- Implementation requires updating two files: SKILL.md (Stage 7) and lean-research-flow.md (Stage 5)

## Context & Scope

This research examines how to update the skill-lean-research skill to include the new Project Context section in Lean research reports. The Project Context section was defined in task 739 and provides proof dependency relationships that help orient readers to how the research topic fits into the codebase.

## Findings

### 1. Current skill-lean-research Structure (SKILL.md)

**Stage 7 Report Template** (lines 201-258) generates reports with:
- Metadata block (Task, Started, Completed, Effort, Priority, Dependencies, Sources/Inputs, Artifacts, Standards)
- Executive Summary
- Context & Scope
- Findings (Relevant Theorems, Proof Strategies, Dependencies)
- Decisions
- Recommendations
- Risks & Mitigations
- Appendix

**Missing**: No Project Context section between metadata and Executive Summary.

**Context Loading** (lines 16-27): Currently loads:
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md` - Always
- `@.claude/context/core/formats/report-format.md` - When creating report

**Missing**: No reference to `@.claude/context/project/repo/project-overview.md` for context generation.

### 2. lean-research-flow.md Structure

**Stage 5 Report Template** (lines 86-138) mirrors SKILL.md template but also lacks the Project Context section.

This file provides supplementary documentation for the lean research execution flow and needs to be updated in parallel with SKILL.md.

### 3. report-format.md Project Context Specification

The specification (lines 28-38) defines four fields for Lean reports only:

| Field | Purpose | Example |
|-------|---------|---------|
| **Upstream Dependencies** | Existing/planned theorems this builds upon | "Depends on `Soundness`, `Kripke.eval`, `Formula.subst`" |
| **Downstream Dependents** | Results that will use this | "Enables `Completeness`, `DecidabilityTheorem`" |
| **Alternative Paths** | Where this provides redundancy | "Alternative to algebraic approach in `Theories/Algebraic/`" |
| **Potential Extensions** | New directions enabled | "Could extend to multi-modal logics" |

**Applicability Note**: "Include this section only for Lean research reports where understanding proof dependencies is essential. For non-Lean reports (general, meta, latex, typst), this section may be omitted."

### 4. project-overview.md Content Analysis

The file provides:
- Project structure documentation (Logos/Core hierarchy)
- Core architecture explanation (layered operators, semantics)
- Key file locations (Syntax, ProofSystem, Semantics, Metalogic, Automation)
- Current project status (completed vs in-progress modules)
- Build and test commands

**Relevant for Context Generation**:
- Module dependency relationships (e.g., Metalogic depends on Syntax, Semantics, ProofSystem)
- Project status (what's completed, what's in progress)
- Extension layers (Epistemic, Explanatory, Normative - planned)

### 5. Implementation Approach

The implementation should:

1. **Add context reference** to SKILL.md Context References section:
   ```markdown
   **Load for Project Context**:
   - `@.claude/context/project/repo/project-overview.md` - Project structure and dependencies
   ```

2. **Update Stage 7 report template** in SKILL.md to include Project Context section after metadata:
   ```markdown
   ## Project Context
   - **Upstream Dependencies**: {theorems/definitions this builds on}
   - **Downstream Dependents**: {results that will use this}
   - **Alternative Paths**: {redundancy or different approaches}
   - **Potential Extensions**: {new directions enabled}
   ```

3. **Update Stage 5 template** in lean-research-flow.md with the same addition.

4. **Add generation guidance** explaining how to derive the four fields:
   - Upstream: Search existing code for what the task topic imports/uses
   - Downstream: Identify what would import/use the result
   - Alternative: Check for similar approaches in different modules
   - Extensions: Consider logical extensions based on project-overview.md roadmap

## Decisions

- The Project Context section should be placed between metadata and Executive Summary (matching report-format.md example skeleton)
- The context should be generated dynamically based on task description and codebase exploration, not hardcoded
- project-overview.md should be added to context references as a "Load When Creating Report" item

## Recommendations

1. **Update SKILL.md Stage 7** to include Project Context section template and generation guidance
2. **Update lean-research-flow.md Stage 5** to include the same template for consistency
3. **Add project-overview.md reference** to the Context References section in SKILL.md
4. **Add generation guidance** explaining how to determine upstream/downstream dependencies by examining:
   - Import statements in relevant Lean files
   - Project-overview.md module structure
   - Task description context
5. **Consider adding a "Project Context Guidelines"** subsection explaining what information to include for each field

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Over-engineering context generation | Medium - adds complexity | Keep fields brief, allow "None identified" where appropriate |
| Incorrect dependency analysis | Medium - misleading reports | Recommend verification against actual import statements |
| Inconsistent context across reports | Low - cosmetic | Provide clear examples in both documentation files |

## Appendix

### Files to Modify

1. `.claude/skills/skill-lean-research/SKILL.md`
   - Context References section (add project-overview.md)
   - Stage 7: Create Research Report (add Project Context template)

2. `.claude/context/project/lean4/agents/lean-research-flow.md`
   - Stage 5: Create Research Report (add Project Context template)

### Reference: report-format.md Example Skeleton

```markdown
# Research Report: {title}
- **Task**: {id} - {title}
- **Started**: 2025-12-22T10:00:00Z
...

## Project Context (Lean only)
- **Upstream Dependencies**: `Soundness`, `Kripke.eval`, `Formula.subst`
- **Downstream Dependents**: `Completeness`, `DecidabilityTheorem`
- **Alternative Paths**: None identified
- **Potential Extensions**: Multi-modal logics, temporal operators

## Executive Summary
...
```
