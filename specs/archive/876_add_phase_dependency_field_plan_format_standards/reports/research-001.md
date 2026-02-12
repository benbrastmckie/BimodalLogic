# Research Report: Task #876

**Task**: 876 - Add phase dependency field to plan format standards
**Date**: 2026-02-11
**Focus**: Phase dependency notation, backward compatibility, integration with team-implement

## Summary

The current plan format lacks explicit phase dependency notation, making parallel execution in team-implement rely on heuristic analysis. Adding a `Dependencies` field to each phase with notation `None | Phase {N} | Phase {N}, Phase {M}` would enable explicit DAG representation while maintaining backward compatibility through optional field treatment.

## Findings

### Current Phase Format Structure

The current phase format in `plan-format.md` (lines 76-83) specifies:

```markdown
### Phase N: {name} [STATUS]
- **Goal:** short statement
- **Tasks:** bullet checklist
- **Timing:** expected duration or window
- **Owner:** (optional)
- **Started/Completed/Blocked/Abandoned:** timestamp lines
```

The `artifact-formats.md` (lines 74-89) shows similar structure without a dependencies field.

### How skill-team-implement Currently Parses Phases

From `skill-team-implement/SKILL.md` (Stage 2: Analyze Phase Dependencies, lines 73-89):

```
1. Extract all phases from plan
2. Identify dependencies (phases that reference outputs of other phases)
3. Group independent phases that can run in parallel
4. Create execution waves respecting dependencies
```

Current approach is heuristic - the skill analyzes phase content to infer dependencies by looking for references to other phase outputs. This is error-prone and cannot be verified statically.

Example wave grouping from the skill documentation:
```
Wave 1: [Phase 1] - must go first (foundational)
Wave 2: [Phase 2, Phase 3] - independent, can parallelize
Wave 3: [Phase 4] - depends on Phase 2 and 3
Wave 4: [Phase 5, Phase 6] - independent cleanup phases
```

### Existing Dependency Notation Patterns in Codebase

1. **Task-level Dependencies**: Plan metadata already has a Dependencies field:
   ```markdown
   - **Dependencies**: None (builds on existing infrastructure)
   ```

2. **Informal Phase References**: Found in plans like task 870:
   ```markdown
   - [ ] Complete F/P proof body (blocked by Phases 3, 5)
   ```

3. **Plan-level Dependencies**: The `plan-format.md` shows task-level dependencies but not phase-level.

### Industry Best Practices for DAG Notation

From research on DAG systems ([Argo Workflows](https://argo-workflows.readthedocs.io/en/latest/walk-through/dag/), [Airflow](https://airflow.apache.org/docs/apache-airflow/stable/concepts/dags.html), [dbt](https://www.getdbt.com/blog/dag-use-cases-and-best-practices)):

1. **Explicit Declaration**: Dependencies should be explicitly declared, not inferred:
   ```yaml
   - name: TaskD
     dependencies: [TaskB, TaskC]
   ```

2. **Array Notation**: Multiple dependencies expressed as a list

3. **No Dependencies = Root Node**: Omitting dependencies means task can start immediately

4. **Topological Ordering**: System validates that graph is acyclic

### Proposed Notation

Based on findings, the recommended notation is:

```markdown
### Phase N: {name} [STATUS]
- **Dependencies**: None | Phase {N} | Phase {N}, Phase {M}
- **Goal:** ...
```

**Examples**:
- `**Dependencies**: None` - Phase can start immediately
- `**Dependencies**: Phase 1` - Depends on single phase
- `**Dependencies**: Phase 2, Phase 3` - Depends on multiple phases (must wait for all)

### Backward Compatibility Analysis

1. **Optional Field**: The field is optional. Missing field = `None` (phase can start immediately).

2. **Parsing Impact**: skill-team-implement currently infers dependencies. With explicit field:
   - If field present: Use explicit dependencies
   - If field absent: Fall back to current heuristic inference

3. **Existing Plans**: All existing plans without the field continue working unchanged.

4. **Plan Creation**: planner-agent would be updated to include dependency field, defaulting to `None` for first phase and inferring from phase content for others.

### Integration Points

1. **plan-format.md**: Add `Dependencies` to Implementation Phases format section (line ~79)

2. **artifact-formats.md**: Add `Dependencies` to phase format (line ~76)

3. **skill-team-implement/SKILL.md**: Update Stage 2 to prefer explicit dependencies when present

4. **skill-planner/SKILL.md**: Update to generate `Dependencies` field during planning

5. **team-wave-helpers.md**: Already documents wave grouping pattern, would benefit from explicit dependency support

### Validation Considerations

The system should validate:
1. No circular dependencies (DAG property)
2. Referenced phases exist (e.g., `Phase 5` requires phases 1-5 to exist)
3. Phase numbers are valid positive integers

## Recommendations

1. **Add Dependencies Field to Phase Format**
   - Location: After heading, before Goal
   - Syntax: `**Dependencies**: None | Phase {N} | Phase {N}, Phase {M}`
   - Optional field with default behavior of `None`

2. **Update skill-team-implement**
   - Parse explicit dependencies when present
   - Fall back to heuristic when absent (backward compatibility)
   - Log which method was used for debugging

3. **Update skill-planner/planner-agent**
   - Generate Dependencies field for each phase
   - Phase 1 defaults to `None`
   - Subsequent phases infer from phase content

4. **Consider Future Enhancements**
   - DAG validation in plan verification step
   - Visual dependency graph generation
   - Dependency chain analysis in research phase

## References

- `.claude/context/core/formats/plan-format.md` - Current plan format standard
- `.claude/rules/artifact-formats.md` - Artifact format rules
- `.claude/skills/skill-team-implement/SKILL.md` - Team implementation skill
- `.claude/utils/team-wave-helpers.md` - Wave coordination helpers
- [Argo Workflows DAG Documentation](https://argo-workflows.readthedocs.io/en/latest/walk-through/dag/)
- [Apache Airflow DAG Concepts](https://airflow.apache.org/docs/apache-airflow/stable/concepts/dags.html)
- [dbt DAG Best Practices](https://www.getdbt.com/blog/dag-use-cases-and-best-practices)

## Next Steps

Run `/plan 876` to create an implementation plan that:
1. Adds Dependencies field to plan-format.md
2. Adds Dependencies field to artifact-formats.md
3. Updates skill-team-implement to parse explicit dependencies
4. Optionally updates planner-agent to generate dependencies
