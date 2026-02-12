# Research Report: Task #878

**Task**: 878 - Update skill-team-implement to use structured Dependencies field
**Started**: 2026-02-11
**Completed**: 2026-02-11
**Effort**: 0.5 hours
**Dependencies**: Task 876 (Dependencies field format), Task 877 (planner-agent generates Dependencies)
**Sources/Inputs**: skill-team-implement/SKILL.md, plan-format.md, task 876 and 877 artifacts
**Artifacts**: specs/878_update_skill_team_implement_use_structured_dependencies/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Stage 2 of skill-team-implement currently uses heuristic dependency analysis that should be replaced with explicit parsing of the Dependencies field
- The Dependencies field format is well-defined (`None`, `Phase N`, `Phase N, Phase M`) with backward compatibility requiring fallback to sequential execution
- A topological sort algorithm is needed to build execution waves from the parsed dependency graph
- The implementation requires 3 main changes: parsing, graph building, and wave extraction

## Context & Scope

Task 878 is part of a 3-task sequence:
1. **Task 876** (COMPLETED): Added Dependencies field to plan-format.md and artifact-formats.md
2. **Task 877** (COMPLETED): Updated planner-agent to generate Dependencies field in plans
3. **Task 878** (THIS TASK): Update skill-team-implement to consume the Dependencies field

This task focuses on modifying Stage 2 (Analyze Phase Dependencies) in `skill-team-implement/SKILL.md` to:
1. Parse the structured Dependencies field from each phase
2. Build a dependency graph from the parsed values
3. Compute execution waves using topological sort
4. Maintain backward compatibility (missing Dependencies = sequential execution)

## Findings

### Current Stage 2 Implementation (Lines 73-89)

The current Stage 2 in skill-team-implement/SKILL.md describes heuristic dependency analysis:

```
Parse plan to identify parallelizable phases:

1. **Extract all phases** from plan
2. **Identify dependencies** (phases that reference outputs of other phases)
3. **Group independent phases** that can run in parallel
4. **Create execution waves** respecting dependencies

Example grouping:
Wave 1: [Phase 1] - must go first (foundational)
Wave 2: [Phase 2, Phase 3] - independent, can parallelize
Wave 3: [Phase 4] - depends on Phase 2 and 3
Wave 4: [Phase 5, Phase 6] - independent cleanup phases
```

This approach:
- Infers dependencies by analyzing phase content (error-prone)
- Cannot be statically verified
- Misses explicitly stated relationships

### Dependencies Field Format (from plan-format.md, lines 76-116)

Task 876 established the Dependencies field specification:

**Syntax**:
- `None` - Phase can start immediately (no blockers)
- `Phase 1` - Phase blocked until Phase 1 completes
- `Phase 1, Phase 3` - Phase blocked until both Phase 1 and Phase 3 complete

**Example from plan-format.md**:
```markdown
### Phase 1: Setup [NOT STARTED]
- **Dependencies:** None
- **Goal:** Initialize project structure

### Phase 2: Core Implementation [NOT STARTED]
- **Dependencies:** Phase 1
- **Goal:** Implement core functionality

### Phase 3: Documentation [NOT STARTED]
- **Dependencies:** Phase 1
- **Goal:** Write user documentation

### Phase 4: Integration [NOT STARTED]
- **Dependencies:** Phase 2, Phase 3
- **Goal:** Integrate and test everything
```

**Backward Compatibility**: The Dependencies field is optional. Plans without this field should be treated as having `Dependencies: None` for all phases, but executed sequentially (implicit dependency chain).

### Dependency Parsing Algorithm

**Input**: Phase heading and metadata block
**Output**: List of phase numbers this phase depends on, or empty list

```
FUNCTION parse_dependencies(phase_content):
    # Find Dependencies line in phase metadata
    match = regex_search(phase_content, r'\*\*Dependencies\*\*:\s*(.+)')

    IF match is None:
        RETURN None  # Field missing (backward compat trigger)

    value = match.group(1).strip()

    IF value == "None":
        RETURN []  # No dependencies, can start immediately

    # Parse "Phase N" or "Phase N, Phase M, ..." format
    phase_refs = regex_findall(value, r'Phase\s+(\d+)')
    RETURN [int(n) for n in phase_refs]
```

### Graph Building Algorithm

**Input**: List of phases with their parsed dependencies
**Output**: Adjacency list representation of dependency graph

```
FUNCTION build_dependency_graph(phases):
    graph = {}

    FOR each phase in phases:
        phase_num = extract_phase_number(phase)
        deps = parse_dependencies(phase.content)

        IF deps is None:
            # Missing Dependencies field - trigger backward compat
            RETURN None

        graph[phase_num] = deps

    RETURN graph
```

### Wave Extraction via Topological Sort

**Input**: Dependency graph (adjacency list)
**Output**: List of waves, where each wave contains phase numbers that can execute in parallel

```
FUNCTION compute_execution_waves(graph):
    waves = []
    remaining = set(graph.keys())
    completed = set()

    WHILE remaining:
        # Find phases whose dependencies are all completed
        ready = []
        FOR phase in remaining:
            IF all(dep in completed FOR dep in graph[phase]):
                ready.append(phase)

        IF ready is empty:
            # Circular dependency detected
            ERROR "Circular dependency: unable to make progress"

        waves.append(sorted(ready))  # Sort for deterministic ordering
        completed.update(ready)
        remaining -= set(ready)

    RETURN waves
```

**Example execution**:
```
Input graph:
  Phase 1: []
  Phase 2: [1]
  Phase 3: [1]
  Phase 4: [2, 3]

Iteration 1: ready = [1], waves = [[1]]
Iteration 2: ready = [2, 3], waves = [[1], [2, 3]]
Iteration 3: ready = [4], waves = [[1], [2, 3], [4]]

Output: [[1], [2, 3], [4]]
```

### Backward Compatibility Approach

When the Dependencies field is missing from ANY phase:

```
FUNCTION handle_backward_compat(phases):
    # Fallback: treat as sequential (phase N depends on phase N-1)
    waves = []
    FOR i, phase in enumerate(phases):
        waves.append([extract_phase_number(phase)])
    RETURN waves
```

This ensures:
1. Old plans without Dependencies field work unchanged
2. Behavior is predictable (sequential execution, same as single-agent)
3. No parallelization for plans without explicit dependencies

### Specific Lines to Modify in SKILL.md

Based on the current Stage 2 structure (lines 73-89):

**Replace**: The current heuristic description
**With**: Explicit parsing algorithm with three steps

1. **Step 1 - Parse Dependencies** (new subsection):
   - Extract Dependencies field from each phase
   - Handle `None`, `Phase N`, and `Phase N, Phase M` formats
   - Return None if any phase is missing the field

2. **Step 2 - Build Dependency Graph** (new subsection):
   - Create adjacency list from parsed dependencies
   - If parsing returned None, trigger backward compat mode

3. **Step 3 - Compute Execution Waves** (new subsection):
   - Topological sort to group phases by execution order
   - Handle circular dependency error (should not occur with valid plans)

4. **Backward Compatibility Mode** (new subsection):
   - When Dependencies field is missing from any phase
   - Execute phases sequentially (each phase is its own wave)
   - Log that backward compat mode was used

### Error Handling Considerations

1. **Circular Dependencies**: The topological sort will detect cycles. If found:
   - Log error with the phases involved
   - Fall back to sequential execution
   - Report in metadata that circular dependency was detected

2. **Invalid Phase References**: If `Phase N` references a non-existent phase:
   - Log warning
   - Treat as no dependency (skip invalid reference)
   - Continue with wave computation

3. **Malformed Dependencies Field**: If the field exists but has invalid format:
   - Log warning with the malformed value
   - Treat that phase as having no dependencies
   - Continue with wave computation

### Integration with Existing Stage 2 Structure

The current Stage 2 (lines 73-89) can be restructured as follows:

```markdown
### Stage 2: Analyze Phase Dependencies

Parse plan to build execution waves from explicit Dependencies field:

#### Step 1: Parse Dependencies Field

For each phase in the plan:
1. Extract `- **Dependencies**:` line value
2. Parse format: `None` | `Phase N` | `Phase N, Phase M`
3. Convert to list of phase numbers (empty list for `None`)

If ANY phase is missing the Dependencies field, enter backward compatibility mode.

#### Step 2: Build Dependency Graph

Create adjacency list from parsed dependencies:
- Key: phase number
- Value: list of phase numbers this phase depends on

Example:
```
Phase 1: []
Phase 2: [1]
Phase 3: [1]
Phase 4: [2, 3]
```

#### Step 3: Compute Execution Waves

Use topological sort to group phases:
1. Find phases with all dependencies completed -> Wave N
2. Mark those phases as completed
3. Repeat until all phases assigned to waves

Output example:
```
Wave 1: [Phase 1] - no dependencies
Wave 2: [Phase 2, Phase 3] - both depend only on Phase 1 (parallel)
Wave 3: [Phase 4] - depends on Phase 2 and 3 (waits for both)
```

#### Backward Compatibility Mode

If Dependencies field is missing from any phase:
1. Log: "Using sequential execution (backward compat)"
2. Each phase executes in its own wave: [[1], [2], [3], ...]
3. No parallelization

This ensures old plans without Dependencies field work correctly.
```

## Decisions

1. **Parsing approach**: Regex-based parsing of the Dependencies line is simplest and sufficient for the defined format.

2. **Backward compatibility trigger**: Missing field on ANY phase triggers sequential mode (conservative approach).

3. **Error handling**: Invalid references and malformed values should log warnings but not fail the entire operation.

4. **Wave ordering**: Phases within a wave should be sorted numerically for deterministic execution order.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Plans with partial Dependencies fields (some phases have it, some don't) | M | L | Treat as missing = backward compat mode |
| Circular dependencies in plans | H | L | Detect via topological sort, fall back to sequential |
| Regex parsing edge cases | L | L | Test with examples from plan-format.md |
| Team mode unavailable | M | M | Existing fallback to single-agent already handles this |

## Appendix

### Search Queries Used

1. Codebase exploration:
   - `Glob: specs/876_*/**/*.md` - Task 876 artifacts
   - `Glob: specs/877_*/**/*.md` - Task 877 artifacts
   - `Glob: .claude/utils/team-wave-helpers.md` - Wave helper patterns

2. File reads:
   - `.claude/skills/skill-team-implement/SKILL.md` - Main skill to modify
   - `.claude/context/core/formats/plan-format.md` - Dependencies field specification
   - Task 876/877 plans and summaries - Understanding predecessor implementations

### References to Documentation

- `.claude/context/core/formats/plan-format.md` - Dependencies field syntax (lines 76-116)
- `.claude/rules/artifact-formats.md` - Phase format template
- `.claude/utils/team-wave-helpers.md` - Wave spawning patterns
- `.claude/skills/skill-team-implement/SKILL.md` - Current Stage 2 implementation (lines 73-89)
