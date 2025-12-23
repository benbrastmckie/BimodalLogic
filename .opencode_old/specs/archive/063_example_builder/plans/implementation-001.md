# Implementation Plan: Example-Builder Specialist

**Project**: 063_example_builder
**Task**: #63 - Create Example-Builder Specialist
**Complexity**: Moderate
**Estimated Effort**: 3-4 hours
**Created**: 2025-12-19

## Task Description

Create example-builder specialist that generates illustrative examples for LEAN 4 theorems, definitions, and tactics to improve documentation and understanding.

## Objectives

1. Create `.opencode/agent/subagents/specialists/example-builder.md` following established specialist pattern
2. Support generation of minimal examples, edge cases, and common usage patterns
3. Integrate with documentation-generator specialist
4. Follow LEAN 4 conventions and documentation standards

## Analysis

### Existing Specialist Patterns

Reviewed existing specialists to understand the pattern:
- **documentation-generator.md**: Generates comprehensive documentation with examples
- **tactic-recommender.md**: Suggests tactics based on goal patterns
- **test-generator.md**: Generates test cases and counterexamples

### Key Features Needed

1. **Example Types**:
   - Minimal examples (simplest usage)
   - Edge cases (boundary conditions, special cases)
   - Common usage patterns (typical scenarios)
   - Counterexamples (when applicable)

2. **Target Types**:
   - Theorems (proof examples)
   - Definitions (usage examples)
   - Tactics (application examples)
   - Functions (invocation examples)

3. **Integration Points**:
   - Documentation-generator (provide examples for docs)
   - Test-generator (use test cases as examples)
   - Syntax-validator (validate example compilation)

## Implementation Steps

### Step 1: Create Specialist Metadata (15 minutes)

Create YAML frontmatter with:
- Description
- Mode: subagent
- Temperature: 0.3 (creative but controlled)
- Tools: read, write, glob (for finding code)

### Step 2: Define Context and Role (15 minutes)

Define:
- System context: LEAN 4 example generation
- Domain context: Theorems, definitions, tactics, usage patterns
- Task scope: Generate illustrative examples
- Integration: Tier 2 specialist (depends on syntax-validator, test-generator)

### Step 3: Specify Input Parameters (30 minutes)

Define input parameters:
- `target` (object): What to generate examples for
  - type: "theorem" | "definition" | "tactic" | "function"
  - name: string
  - file_path: string
  - statement: string (optional)
- `example_types` (array): Which types to generate
  - Options: "minimal", "edge_cases", "common_usage", "counterexamples"
  - Default: ["minimal", "common_usage"]
- `num_examples` (integer): How many examples per type (1-5)
  - Default: 2
- `include_explanations` (boolean): Add natural language explanations
  - Default: true

### Step 4: Design Process Flow (60 minutes)

Define 5-step process:

1. **Analyze Target**:
   - Parse target definition/theorem
   - Extract type signatures
   - Identify parameters and constraints
   - Determine example complexity

2. **Generate Minimal Examples**:
   - Create simplest possible usage
   - Use basic values (0, 1, true, false)
   - Ensure compilation via syntax-validator

3. **Generate Edge Cases**:
   - Identify boundary conditions
   - Test special values (empty, max, min)
   - Include corner cases

4. **Generate Common Usage Patterns**:
   - Typical real-world scenarios
   - Composition with other functions
   - Integration patterns

5. **Format and Validate**:
   - Format as LEAN 4 code blocks
   - Add explanations if requested
   - Validate compilation
   - Return structured output

### Step 5: Define Output Specification (30 minutes)

Define output format:
```yaml
status: "success" | "partial" | "error"
examples:
  - type: "minimal" | "edge_case" | "common_usage" | "counterexample"
    code: string (LEAN 4 code)
    explanation: string (if include_explanations)
    compiles: boolean
    output: string (expected result)
metadata:
  target_name: string
  examples_generated: integer
  compilation_rate: float [0.0, 1.0]
```

### Step 6: Add Example Generation Strategies (45 minutes)

Define strategies for each target type:

**Theorems**:
- Minimal: Simplest proof application
- Edge cases: Boundary conditions
- Common: Typical proof patterns

**Definitions**:
- Minimal: Basic instantiation
- Edge cases: Special values
- Common: Real-world usage

**Tactics**:
- Minimal: Simple goal application
- Edge cases: Complex goals
- Common: Typical proof scenarios

**Functions**:
- Minimal: Basic invocation
- Edge cases: Boundary inputs
- Common: Composition patterns

### Step 7: Define Success Metrics (15 minutes)

Define metrics:
- `example_compilation_rate`: Target > 95%
- `example_usefulness`: Target > 4/5 user rating
- `generation_time`: Target < 10s
- `coverage`: Target > 80% of example types

### Step 8: Add Constraints and Validation (30 minutes)

Define constraints:
- Must validate target object structure
- Must generate at least one example
- Must validate examples compile (via syntax-validator)
- Must not generate invalid LEAN 4 code
- Must follow LEAN 4 style guide

### Step 9: Integration with Documentation-Generator (30 minutes)

Define integration:
- Documentation-generator calls example-builder for examples
- Example-builder returns formatted code blocks
- Documentation-generator includes examples in docstrings
- Shared validation via syntax-validator

## Files to Create

### Primary Deliverable

- `.opencode/agent/subagents/specialists/example-builder.md`

## Success Criteria

- [ ] Specialist file created following established pattern
- [ ] All input parameters clearly defined
- [ ] Process flow documented with 5 steps
- [ ] Output specification defined
- [ ] Example generation strategies for all target types
- [ ] Integration with documentation-generator specified
- [ ] Success metrics defined
- [ ] Constraints and validation rules specified
- [ ] File follows YAML frontmatter + markdown structure
- [ ] Consistent with other specialist files

## Verification Steps

1. Compare structure with existing specialists (documentation-generator, tactic-recommender, test-generator)
2. Verify YAML frontmatter is valid
3. Ensure all sections are complete
4. Check integration points are clearly defined
5. Validate example generation strategies are comprehensive

## Dependencies

- Existing specialist pattern (documentation-generator.md, tactic-recommender.md, test-generator.md)
- LEAN 4 syntax and conventions
- Documentation standards (context/core/standards/docs.md)

## Estimated Timeline

- Step 1: 15 minutes
- Step 2: 15 minutes
- Step 3: 30 minutes
- Step 4: 60 minutes
- Step 5: 30 minutes
- Step 6: 45 minutes
- Step 7: 15 minutes
- Step 8: 30 minutes
- Step 9: 30 minutes
- **Total**: ~4 hours

## Notes

- This is a Tier 2 specialist (depends on syntax-validator, test-generator)
- Focus on LEAN 4-specific example patterns
- Ensure examples are pedagogically useful
- Prioritize compilation and correctness
- Integration with documentation-generator is key use case
