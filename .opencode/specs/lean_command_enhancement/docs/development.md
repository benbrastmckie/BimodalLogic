# Enhanced /lean Command - Development Guide

**Version**: 1.0  
**Last Updated**: 2025-12-20  
**Status**: Production Ready

---

## Table of Contents

1. [Development Setup](#development-setup)
2. [Modifying the Command](#modifying-the-command)
3. [Adding New Phases](#adding-new-phases)
4. [Adding New Specialists](#adding-new-specialists)
5. [Testing Guidelines](#testing-guidelines)
6. [Contribution Guidelines](#contribution-guidelines)

---

## Development Setup

### Prerequisites

**Required**:
- LEAN 4 (version 4.0+)
- Git
- Basic understanding of LEAN 4 syntax
- Familiarity with .opencode/ system architecture

**Recommended**:
- VS Code with Lean 4 extension
- Knowledge of modal logic (for ProofChecker domain)
- Understanding of XML-optimized agent patterns

### Environment Setup

#### 1. Clone Repository

```bash
cd /home/benjamin/Projects/ProofChecker
```

#### 2. Verify .opencode/ Structure

```bash
ls -la .opencode/
# Should see:
# - commands/
# - subagents/
# - context/
# - specs/
```

#### 3. Locate Enhanced /lean Command

```bash
cat .opencode/commands/lean.md
# Or wherever the enhanced lean command is deployed
```

#### 4. Review Documentation

```bash
cd .opencode/specs/lean_command_enhancement/docs/
ls -la
# Read: user-guide.md, architecture.md, this file
```

---

## Modifying the Command

### Command File Structure

The enhanced `/lean` command is defined in a single markdown file with XML workflow structure:

```markdown
---
name: lean
agent: orchestrator
description: "Implement a LEAN 4 proof with intelligent multi-phase execution"
---

[Introduction and usage]

## Multi-Phase Workflow

<workflow>
  <phase id="0" name="Input Validation & Configuration">
    [Phase 0 definition]
  </phase>
  
  <phase id="1" name="Pre-Planning Analysis" skippable="true">
    [Phase 1 definition]
  </phase>
  
  [... more phases ...]
</workflow>

## Expected Output

[Output format]
```

### Key Sections

#### 1. Frontmatter

```yaml
---
name: lean
agent: orchestrator
description: "Implement a LEAN 4 proof with intelligent multi-phase execution"
---
```

**Modifying**:
- `name`: Command name (don't change unless renaming command)
- `agent`: Orchestrator agent (don't change)
- `description`: Brief description (update if functionality changes)

---

#### 2. Usage Documentation

```markdown
**Usage:**
```
/lean NNN [--flags]
```

**Flags:**
- `--fast`: Skip research, optimization, and documentation phases
- `--skip-research`: Skip pre-planning and research phases
[...]
```

**Modifying**:
- Add new flags here
- Update flag descriptions
- Add usage examples

---

#### 3. Workflow Definition

```xml
<workflow>
  <phase id="N" name="Phase Name" skippable="true|false">
    <condition>
      Execute if: [conditions]
    </condition>
    <action>Brief description of phase action</action>
    <routing parallel="true|false">
      <route to="@subagents/specialists/specialist-name">
        <context_level>Level 1|2</context_level>
        <pass_data>
          - Data item 1
          - Data item 2
        </pass_data>
        <expected_return>
          {
            "field": "value"
          }
        </expected_return>
        <output_artifact>path/to/artifact.md</output_artifact>
      </route>
    </routing>
    <output>
      - Output 1
      - Output 2
    </output>
  </phase>
</workflow>
```

**Modifying**:
- Add new phases
- Modify routing
- Change skip conditions
- Update specialist invocations

---

### Common Modifications

#### 1. Add a New Flag

**Step 1**: Update frontmatter usage section

```markdown
**Flags:**
- `--fast`: Skip research, optimization, and documentation phases
- `--skip-research`: Skip pre-planning and research phases
- `--skip-optimization`: Skip proof optimization phase
- `--skip-docs`: Skip documentation generation phase
- `--full`: Execute all phases regardless of complexity
- `--my-new-flag`: Description of new flag  # ADD THIS
```

**Step 2**: Update Phase 0 (Input Validation)

```xml
<phase id="0" name="Input Validation & Configuration">
  <process>
    1. Parse project number from $ARGUMENTS
    2. Parse optional flags (--fast, --skip-*, --full, --my-new-flag)  # ADD HERE
    3. Locate project directory
    [...]
    6. Determine phase execution strategy based on:
       - Complexity level from plan
       - User flags (including --my-new-flag)  # ADD HERE
       [...]
  </process>
</phase>
```

**Step 3**: Update skip logic in relevant phases

```xml
<phase id="N" name="Some Phase" skippable="true">
  <condition>
    Execute if: NOT --my-new-flag AND [other conditions]  # ADD HERE
  </condition>
  [...]
</phase>
```

**Step 4**: Update documentation

- Add to `flag-reference.md`
- Add examples to `example-scenarios.md`
- Update `user-guide.md`

---

#### 2. Modify Skip Logic

**Location**: Phase `<condition>` blocks

**Example**: Change when Phase 1 is skipped

**Before**:
```xml
<phase id="1" name="Pre-Planning Analysis" skippable="true">
  <condition>
    Execute if: NOT --skip-research AND NOT --fast AND complexity != "simple"
  </condition>
  [...]
</phase>
```

**After** (also skip for moderate):
```xml
<phase id="1" name="Pre-Planning Analysis" skippable="true">
  <condition>
    Execute if: NOT --skip-research AND NOT --fast AND complexity == "complex"
  </condition>
  [...]
</phase>
```

**Impact**: Phase 1 now only executes for complex proofs

---

#### 3. Change Specialist Routing

**Location**: Phase `<routing>` blocks

**Example**: Add a new specialist to Phase 2

**Before**:
```xml
<phase id="2" name="Research & Strategy" skippable="true">
  <routing parallel="true">
    <route to="@subagents/specialists/library-navigator">
      [...]
    </route>
    <route to="@subagents/specialists/proof-strategy-advisor">
      [...]
    </route>
    <route to="@subagents/specialists/tactic-recommender">
      [...]
    </route>
  </routing>
</phase>
```

**After** (add theorem-classifier):
```xml
<phase id="2" name="Research & Strategy" skippable="true">
  <routing parallel="true">
    <route to="@subagents/specialists/library-navigator">
      [...]
    </route>
    <route to="@subagents/specialists/proof-strategy-advisor">
      [...]
    </route>
    <route to="@subagents/specialists/tactic-recommender">
      [...]
    </route>
    <route to="@subagents/specialists/theorem-classifier">  # NEW
      <context_level>Level 2</context_level>
      <pass_data>
        - Theorem statements
        - Type signatures
      </pass_data>
      <expected_return>
        {
          "classification": "constructive|classical|...",
          "confidence": 0.95
        }
      </expected_return>
      <output_artifact>.opencode/specs/NNN_project/research/classification-001.md</output_artifact>
    </route>
  </routing>
</phase>
```

**Impact**: Phase 2 now also classifies theorems

---

#### 4. Modify Output Format

**Location**: End of command file, "Expected Output" section

**Example**: Add new metric to output

**Before**:
```markdown
**Metrics**:
- Verification: {score}% ✅
- Code Review: {score}% ✅
- Style Compliance: {score}% ✅
- Optimization: {reduction}% size reduction, {speedup}% faster
- Documentation: {coverage}% coverage
```

**After** (add complexity accuracy):
```markdown
**Metrics**:
- Verification: {score}% ✅
- Code Review: {score}% ✅
- Style Compliance: {score}% ✅
- Optimization: {reduction}% size reduction, {speedup}% faster
- Documentation: {coverage}% coverage
- Complexity Accuracy: {accuracy}% (estimated vs. actual)  # NEW
```

**Impact**: Output now includes complexity estimation accuracy

---

## Adding New Phases

### When to Add a New Phase

**Good Reasons**:
- New category of work (e.g., "Phase 8: Testing")
- Logically distinct from existing phases
- Can be skipped independently
- Has clear inputs and outputs

**Bad Reasons**:
- Just adding a new specialist (add to existing phase instead)
- Minor variation of existing phase
- Can't be skipped independently

### Steps to Add a New Phase

#### Step 1: Design the Phase

**Questions to Answer**:
1. What is the phase's purpose?
2. What are the inputs?
3. What are the outputs?
4. Which specialists are needed?
5. Should it be skippable?
6. What are the skip conditions?
7. Should specialists run in parallel or sequential?
8. How long will it take?

**Example**: Adding "Phase 8: Testing"

**Answers**:
1. Purpose: Generate and run tests for implemented theorems
2. Inputs: Implemented files, examples
3. Outputs: Test files, test results
4. Specialists: test-generator, test-runner
5. Skippable: Yes
6. Skip conditions: --skip-tests flag, complexity = "simple"
7. Execution: Sequential (generate then run)
8. Duration: 60-120 seconds

---

#### Step 2: Define Phase XML

```xml
<phase id="8" name="Testing" skippable="true">
  <condition>
    Execute if: NOT --skip-tests AND complexity != "simple"
  </condition>
  
  <action>Generate and run tests for implemented theorems</action>
  
  <routing sequential="true">
    <route to="@subagents/specialists/test-generator">
      <context_level>Level 2</context_level>
      <pass_data>
        - Implemented theorems
        - Examples (from Phase 6)
        - Test patterns
      </pass_data>
      <expected_return>
        {
          "test_files": ["Test1.lean", "Test2.lean"],
          "test_count": 15,
          "summary": "Generated 15 tests"
        }
      </expected_return>
      <output_artifact>.opencode/specs/NNN_project/tests/tests-001.md</output_artifact>
    </route>
    
    <route to="@subagents/specialists/test-runner">
      <context_level>Level 2</context_level>
      <pass_data>
        - Test files (from test-generator)
        - Test configuration
      </pass_data>
      <expected_return>
        {
          "tests_passed": 14,
          "tests_failed": 1,
          "failures": [{"test": "test_edge_case", "error": "..."}],
          "summary": "14/15 tests passed"
        }
      </expected_return>
      <output_artifact>.opencode/specs/NNN_project/tests/test-results-001.md</output_artifact>
    </route>
  </routing>
  
  <output>
    - Test files (created in LogosTest/)
    - Test results report
    - Test coverage metrics
  </output>
  
  <success_criteria>
    - All tests pass OR
    - Failures documented with clear error messages
  </success_criteria>
  
  <error_handling>
    - Test generation fails → Log warning, skip test execution
    - Test execution fails → Document failures, continue
  </error_handling>
</phase>
```

---

#### Step 3: Update Phase 0 (Input Validation)

Add new flag handling:

```xml
<phase id="0" name="Input Validation & Configuration">
  <process>
    [...]
    2. Parse optional flags (--fast, --skip-*, --full, --skip-tests)  # ADD
    [...]
    6. Determine phase execution strategy:
       - If --fast: Skip phases 1, 2, 5, 6, 8  # ADD 8
       [...]
  </process>
</phase>
```

---

#### Step 4: Update Phase 7 (Finalization)

Add new artifacts to aggregation:

```xml
<phase id="7" name="Finalization">
  <process>
    1. Aggregate all reports and artifacts
       - [existing artifacts]
       - Test results (from Phase 8)  # ADD
    [...]
  </process>
</phase>
```

---

#### Step 5: Update Documentation

**Files to Update**:
1. `user-guide.md`: Add Phase 8 description
2. `flag-reference.md`: Add --skip-tests flag
3. `example-scenarios.md`: Add testing scenario
4. `architecture.md`: Add Phase 8 to workflow diagrams
5. `README.md`: Update phase count (7 → 8)

---

#### Step 6: Create Specialists (if needed)

If the specialists don't exist, create them:

**Location**: `.opencode/subagents/specialists/`

**Files to Create**:
- `test-generator.md`
- `test-runner.md`

See [Adding New Specialists](#adding-new-specialists) for details.

---

#### Step 7: Test the New Phase

1. Create test project with new phase
2. Run with and without --skip-tests
3. Verify artifacts are created
4. Check output format
5. Test error handling

---

## Adding New Specialists

### When to Add a New Specialist

**Good Reasons**:
- New capability needed (e.g., test generation)
- Existing specialist is too complex (split into multiple)
- Domain-specific expertise (e.g., modal logic specialist)

**Bad Reasons**:
- Minor variation of existing specialist
- One-off task (use existing specialist instead)

### Steps to Add a New Specialist

#### Step 1: Design the Specialist

**Questions to Answer**:
1. What is the specialist's purpose?
2. What are the inputs?
3. What are the outputs?
4. What context level is needed (L1 or L2)?
5. Which phase(s) will use it?
6. Should it run in parallel or sequential?

**Example**: Adding "theorem-classifier"

**Answers**:
1. Purpose: Classify theorems by type (constructive, classical, etc.)
2. Inputs: Theorem statements, type signatures
3. Outputs: Classification, confidence score
4. Context level: L2 (needs domain knowledge)
5. Phase: Phase 2 (Research & Strategy)
6. Execution: Parallel (with other Phase 2 specialists)

---

#### Step 2: Create Specialist File

**Location**: `.opencode/subagents/specialists/theorem-classifier.md`

**Template**:
```markdown
---
name: theorem-classifier
description: "Classify theorems by type (constructive, classical, etc.)"
mode: specialist
temperature: 0.3
tools: [read, write, bash]
---

<context>
  <system_context>
    Specialist for classifying LEAN 4 theorems by proof type and characteristics.
  </system_context>
  
  <domain_context>
    LEAN 4 theorem proving, modal logic, constructive vs. classical logic.
  </domain_context>
  
  <task_context>
    Analyze theorem statements and classify by type, providing confidence scores.
  </task_context>
</context>

<role>
  Theorem Classification Specialist
</role>

<task>
  Classify theorems by type (constructive, classical, modal, temporal, etc.)
  and provide confidence scores for classifications.
</task>

<workflow_execution>
  <stage id="1" name="AnalyzeTheorems">
    <action>Analyze theorem statements and type signatures</action>
    <process>
      1. Parse theorem statements
      2. Identify logical connectives and quantifiers
      3. Analyze proof structure (if available)
      4. Classify by type:
         - Constructive: Uses intuitionistic logic
         - Classical: Uses excluded middle
         - Modal: Uses box/diamond operators
         - Temporal: Uses temporal operators
         - Hybrid: Combination of above
      5. Calculate confidence score (0-1)
    </process>
    <checkpoint>Theorems analyzed and classified</checkpoint>
  </stage>
  
  <stage id="2" name="GenerateReport">
    <action>Generate classification report</action>
    <process>
      1. Create structured output:
         {
           "classifications": [
             {
               "theorem": "theorem_name",
               "type": "constructive|classical|modal|temporal|hybrid",
               "confidence": 0.95,
               "reasoning": "Uses intuitionistic logic, no excluded middle"
             }
           ],
           "summary": "Classified N theorems"
         }
      2. Write report to artifact location
    </process>
    <checkpoint>Report generated</checkpoint>
  </stage>
  
  <stage id="3" name="ReturnResults">
    <action>Return classification results</action>
    <return_format>
      {
        "classifications": [...],
        "summary": "..."
      }
    </return_format>
    <checkpoint>Results returned</checkpoint>
  </stage>
</workflow_execution>

<input_format>
  {
    "theorems": [
      {
        "name": "theorem_name",
        "statement": "⊢ □(p → p)",
        "type_signature": "Formula → Prop"
      }
    ]
  }
</input_format>

<output_format>
  {
    "classifications": [
      {
        "theorem": "theorem_name",
        "type": "modal",
        "confidence": 0.95,
        "reasoning": "Uses box operator"
      }
    ],
    "summary": "Classified 3 theorems: 2 modal, 1 classical"
  }
</output_format>

<error_handling>
  - Invalid theorem statement → Skip, log warning
  - Ambiguous classification → Return multiple types with confidence scores
  - No theorems provided → Return empty classifications
</error_handling>

Execute the theorem classification workflow now.
```

---

#### Step 3: Add Specialist to Phase

Update the phase that will use the specialist:

```xml
<phase id="2" name="Research & Strategy" skippable="true">
  <routing parallel="true">
    [... existing specialists ...]
    
    <route to="@subagents/specialists/theorem-classifier">  # NEW
      <context_level>Level 2</context_level>
      <pass_data>
        - Theorem statements from plan
        - Type signatures
      </pass_data>
      <expected_return>
        {
          "classifications": [...],
          "summary": "..."
        }
      </expected_return>
      <output_artifact>.opencode/specs/NNN_project/research/classification-001.md</output_artifact>
    </route>
  </routing>
</phase>
```

---

#### Step 4: Update Specialist Routing Matrix

Update `architecture.md`:

```markdown
| Phase | Specialist | Execution | Context | Input | Output | Skip Conditions |
|-------|-----------|-----------|---------|-------|--------|-----------------|
| [... existing specialists ...]
| **2** | theorem-classifier | Parallel | L2 | Theorems, types | Classifications | --skip-research, --fast+simple |
```

---

#### Step 5: Test the Specialist

1. Create test input:
   ```json
   {
     "theorems": [
       {
         "name": "box_self_impl",
         "statement": "⊢ □(p → p)",
         "type_signature": "Formula → Prop"
       }
     ]
   }
   ```

2. Invoke specialist manually:
   ```bash
   # Test specialist directly
   @subagents/specialists/theorem-classifier < test-input.json
   ```

3. Verify output format matches expected

4. Test error handling with invalid input

---

## Testing Guidelines

### Test Levels

#### 1. Unit Tests (Specialist Level)

**Purpose**: Test individual specialists in isolation

**Method**: Direct invocation with test inputs

**Example**:
```bash
# Test complexity-analyzer
echo '{"task": "Implement 3 theorems", "codebase": "..."}' | \
  @subagents/specialists/complexity-analyzer
```

**Verify**:
- Output format matches expected
- All required fields present
- Error handling works

---

#### 2. Integration Tests (Phase Level)

**Purpose**: Test phase execution with multiple specialists

**Method**: Run command with specific flags to execute single phase

**Example**:
```bash
# Test Phase 2 only (research)
/lean 002 --skip-optimization --skip-docs
```

**Verify**:
- All specialists in phase execute
- Artifacts created correctly
- Results aggregated properly

---

#### 3. End-to-End Tests (Full Command)

**Purpose**: Test complete workflow

**Method**: Run command on test projects

**Example**:
```bash
# Test full workflow on moderate project
/lean 002
```

**Verify**:
- All phases execute in order
- Context enrichment works
- Final output correct
- Artifacts complete

---

### Test Projects

Use the test projects created in Phase 2:

| Project | Complexity | Theorems | Purpose |
|---------|------------|----------|---------|
| 001_lean_test_simple | Simple | 1 | Test simple proof workflow |
| 002_lean_test_moderate | Moderate | 3 | Test moderate proof workflow |
| 003_lean_test_complex | Complex | 5 | Test complex proof workflow |

**Location**: `.opencode/specs/00N_lean_test_*/`

---

### Test Scenarios

See `testing/test-guide.md` for 12 comprehensive test scenarios:

1. TEST-001: Basic execution (simple)
2. TEST-002: Skip research flag
3. TEST-003: Skip planning flag
4. TEST-004: Parallel execution
5. TEST-005: Quick mode
6. TEST-006: Combined flags
7. TEST-007: Complex multi-file
8. TEST-008: Error handling - invalid project
9. TEST-009: Error handling - compilation failure
10. TEST-010: Phase skipping logic
11. TEST-011: Parallel specialist execution
12. TEST-012: All flags combined

---

### Regression Testing

**When to Run**:
- After modifying command
- After adding new phase
- After adding new specialist
- Before deployment

**How to Run**:
```bash
# Run all test scenarios
for i in 001 002 003; do
  echo "Testing project $i..."
  /lean $i
  /lean $i --fast
  /lean $i --skip-research
done
```

**Verify**:
- No regressions in existing functionality
- New features work as expected
- Performance hasn't degraded

---

## Contribution Guidelines

### Code Style

#### 1. XML Structure

**Follow XML optimization patterns**:
- Optimal component ordering: context → role → task → workflow
- Clear hierarchical structure
- Explicit routing with @ symbol
- Validation checkpoints

**Example**:
```xml
<workflow>
  <phase id="N" name="Phase Name">
    <condition>...</condition>
    <action>...</action>
    <routing>...</routing>
    <output>...</output>
  </phase>
</workflow>
```

---

#### 2. Markdown Formatting

**Follow markdown best practices**:
- Use headers for structure (##, ###, ####)
- Code blocks with syntax highlighting
- Tables for structured data
- Lists for sequences

**Example**:
```markdown
## Section Title

### Subsection

**Bold** for emphasis, *italic* for terms.

```bash
# Code block with syntax highlighting
/lean 123 --fast
```

| Column 1 | Column 2 |
|----------|----------|
| Value 1  | Value 2  |
```

---

#### 3. Documentation

**Always document**:
- Purpose of changes
- New features or flags
- Breaking changes (avoid if possible)
- Migration steps (if needed)

**Update all relevant docs**:
- User guide
- Flag reference
- Example scenarios
- Architecture
- This development guide

---

### Git Workflow

#### 1. Branch Naming

```bash
# Feature branches
git checkout -b feature/add-phase-8-testing

# Bug fix branches
git checkout -b fix/phase-2-timeout

# Documentation branches
git checkout -b docs/update-user-guide
```

---

#### 2. Commit Messages

**Format**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance

**Example**:
```
feat(lean): Add Phase 8 for automated testing

- Add test-generator specialist
- Add test-runner specialist
- Update Phase 0 to handle --skip-tests flag
- Update documentation

Closes #123
```

---

#### 3. Pull Request Process

**Steps**:
1. Create feature branch
2. Make changes
3. Test thoroughly
4. Update documentation
5. Create pull request
6. Address review comments
7. Merge when approved

**PR Template**:
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Refactoring

## Changes Made
- Change 1
- Change 2

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] End-to-end tests pass
- [ ] Documentation updated

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No breaking changes (or documented)
```

---

### Review Process

#### 1. Self-Review

**Before submitting PR**:
- [ ] Code works as expected
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No debug code left
- [ ] Follows style guidelines

---

#### 2. Peer Review

**Reviewers check**:
- [ ] Code quality
- [ ] Test coverage
- [ ] Documentation completeness
- [ ] No breaking changes
- [ ] Performance impact

---

#### 3. Approval

**Requirements**:
- At least 1 approval
- All tests pass
- Documentation complete
- No unresolved comments

---

## Summary

### Key Development Principles

1. **Modularity**: Keep phases and specialists focused
2. **Documentation**: Document everything thoroughly
3. **Testing**: Test at all levels (unit, integration, e2e)
4. **Backward Compatibility**: Avoid breaking changes
5. **Performance**: Consider execution time impact
6. **User Experience**: Make features intuitive and helpful

### Quick Reference

**Modify Command**: Edit `.opencode/commands/lean.md`

**Add Phase**: Add `<phase>` block to `<workflow>`

**Add Specialist**: Create `.opencode/subagents/specialists/name.md`

**Add Flag**: Update Phase 0 and relevant phase conditions

**Test**: Use test projects 001, 002, 003

**Document**: Update all 6 documentation files

### Getting Help

**Resources**:
- Architecture guide: `architecture.md`
- User guide: `user-guide.md`
- Implementation plan: `../plans/implementation-plan-v1.md`
- Test guide: `../testing/test-guide.md`

**Questions**:
- Check documentation first
- Review existing code
- Ask maintainers

---

**Happy Developing!** 🚀

The enhanced `/lean` command is designed to be extensible and maintainable. Follow these guidelines to contribute effectively and maintain code quality.
