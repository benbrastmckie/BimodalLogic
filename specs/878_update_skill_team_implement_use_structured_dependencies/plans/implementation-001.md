# Implementation Plan: Update skill-team-implement to use structured Dependencies field

- **Task**: 878 - update_skill_team_implement_use_structured_dependencies
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: Task 876 (Dependencies field format), Task 877 (planner-agent generates Dependencies)
- **Research Inputs**: specs/878_update_skill_team_implement_use_structured_dependencies/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Replace the heuristic-based dependency analysis in skill-team-implement Stage 2 with explicit parsing of the Dependencies field. The research report provides complete algorithms for parsing, graph building, and wave computation via topological sort. Backward compatibility is maintained by detecting missing Dependencies fields and falling back to sequential execution.

### Research Integration

- Integrated research-001.md (task 878)
- Key algorithms: parse_dependencies(), build_dependency_graph(), compute_execution_waves()
- Backward compatibility: Missing field on ANY phase triggers sequential mode

## Goals & Non-Goals

**Goals**:
- Parse Dependencies field from each phase in implementation plans
- Build execution waves from explicit dependency graph (topological sort)
- Maintain backward compatibility with plans lacking Dependencies field
- Detect and handle circular dependencies gracefully

**Non-Goals**:
- Changing other stages of skill-team-implement
- Modifying the Dependencies field format (already defined by task 876)
- Implementing auto-parallelization heuristics as fallback

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Plans with partial Dependencies fields | M | L | Treat as missing = backward compat mode |
| Circular dependencies in plans | H | L | Detect via topological sort, fall back to sequential |
| Regex parsing edge cases | L | L | Test with examples from plan-format.md |

## Implementation Phases

### Phase 1: Replace Stage 2 Heuristic Description [NOT STARTED]

**Dependencies**: None
**Estimated effort**: 0.5 hours

**Objectives**:
1. Remove the current heuristic-based dependency analysis description
2. Add new structured description with three-step algorithm

**Files to modify**:
- `.claude/skills/skill-team-implement/SKILL.md` - Replace lines 73-89 (Stage 2)

**Steps**:
1. Read current Stage 2 content (lines 73-89)
2. Replace with new structure containing:
   - Step 1: Parse Dependencies Field (extract field, parse format, convert to phase numbers)
   - Step 2: Build Dependency Graph (create adjacency list)
   - Step 3: Compute Execution Waves (topological sort algorithm)
3. Include example showing graph and wave output

**Verification**:
- Stage 2 contains three distinct steps
- Algorithm description matches research report pseudocode
- Example shows wave grouping from dependency graph

---

### Phase 2: Add Backward Compatibility Section [NOT STARTED]

**Dependencies**: Phase 1
**Estimated effort**: 0.25 hours

**Objectives**:
1. Add explicit backward compatibility mode description after Stage 2 steps

**Files to modify**:
- `.claude/skills/skill-team-implement/SKILL.md` - Add after new Step 3

**Steps**:
1. Add "Backward Compatibility Mode" subsection to Stage 2
2. Document trigger condition: Dependencies field missing from ANY phase
3. Document behavior: Sequential execution (each phase in own wave)
4. Add logging note for traceability

**Verification**:
- Backward compatibility section exists
- Trigger condition is clearly stated
- Sequential execution behavior is documented

---

### Phase 3: Add Error Handling Subsection [NOT STARTED]

**Dependencies**: Phase 1
**Estimated effort**: 0.25 hours

**Objectives**:
1. Document error handling for circular dependencies, invalid references, malformed fields

**Files to modify**:
- `.claude/skills/skill-team-implement/SKILL.md` - Add error handling within Stage 2

**Steps**:
1. Add "Error Handling" subsection to Stage 2
2. Document circular dependency detection and fallback
3. Document invalid phase reference handling (skip invalid, continue)
4. Document malformed field handling (treat as no dependencies)

**Verification**:
- Error handling section exists
- All three error types are documented
- Recovery actions are specified

---

### Phase 4: Update Stage 6 Wave Execution Reference [NOT STARTED]

**Dependencies**: Phase 1, Phase 2, Phase 3
**Estimated effort**: 0.25 hours

**Objectives**:
1. Ensure Stage 6 (Execute Implementation Waves) references the new dependency-based waves
2. Verify consistency between Stage 2 output and Stage 6 input

**Files to modify**:
- `.claude/skills/skill-team-implement/SKILL.md` - Review and update Stage 6 if needed

**Steps**:
1. Read Stage 6 (lines 180-280)
2. Verify wave format compatibility with Stage 2 output
3. Add note that waves come from Stage 2 dependency analysis (if not already clear)
4. Ensure single-phase wave optimization is preserved

**Verification**:
- Stage 6 references Stage 2 wave output
- Wave format is consistent throughout document
- Single-phase wave optimization documented

---

### Phase 5: Verification and Consistency Check [NOT STARTED]

**Dependencies**: Phase 4
**Estimated effort**: 0.25 hours

**Objectives**:
1. Verify entire SKILL.md is internally consistent
2. Ensure all stage references are correct
3. Validate example scenarios work with new algorithm

**Files to modify**:
- `.claude/skills/skill-team-implement/SKILL.md` - Final consistency review

**Steps**:
1. Re-read entire SKILL.md
2. Verify all cross-references between stages
3. Walk through example plan with Dependencies field manually
4. Walk through example plan without Dependencies field manually
5. Confirm backward compatibility path works

**Verification**:
- No inconsistent stage references
- Example scenarios produce expected waves
- Both dependency-based and sequential paths are clear

## Testing & Validation

- [ ] Stage 2 contains three-step dependency parsing algorithm
- [ ] Backward compatibility mode is documented with trigger condition
- [ ] Error handling covers circular, invalid, and malformed cases
- [ ] Stage 6 correctly references Stage 2 wave output
- [ ] Example from plan-format.md produces correct waves: [[1], [2, 3], [4]]
- [ ] Plan without Dependencies produces sequential waves: [[1], [2], [3], ...]

## Artifacts & Outputs

- `.claude/skills/skill-team-implement/SKILL.md` - Updated Stage 2 with dependency parsing
- `specs/878_update_skill_team_implement_use_structured_dependencies/plans/implementation-001.md` - This plan
- `specs/878_update_skill_team_implement_use_structured_dependencies/summaries/implementation-summary-YYYYMMDD.md` - Summary after completion

## Rollback/Contingency

If the changes cause issues with team implementation:
1. Revert SKILL.md to previous version via git
2. The existing heuristic approach will continue working
3. Plans with Dependencies field will still be valid (field just ignored)
