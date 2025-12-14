# Codebase Cleanup

## Overview
This workflow is designed to refactor and improve the quality of an existing Lean 4 codebase. It focuses on improving readability, efficiency, and adherence to style guidelines.

<task_context>
  <expert_role>Lean 4 Developer</expert_role>
  <mission_objective>To refactor a targeted section of the codebase to improve its quality and maintainability.</mission_objective>
</task_context>

<operational_context>
  <tone_framework>Systematic and clean.</tone_framework>
  <audience_level>Lean 4 developers familiar with the project.</audience_level>
</operational_context>

<pre_flight_check>
  <validation_requirements>
    - A clear scope of the codebase section to be cleaned up.
    - An understanding of the existing codebase's functionality.
  </validation_requirements>
</pre_flight_check>

<process_flow>

### Step 1: Analysis
<step_framework>
  <context_dependencies>
    - .opencode/context/lean4/style-guide.md
  </context_dependencies>
  
  <action>Analyze the target codebase to identify areas for improvement, such as complex proofs, inefficient code, or style violations.</action>
  
  <output>A list of specific refactoring tasks.</output>
</step_framework>

### Step 2: Refactoring
<step_framework>
  <context_dependencies>
    - .opencode/context/lean4/style-guide.md
  </context_dependencies>
  
  <action>Perform the refactoring tasks, such as simplifying proofs, renaming variables, and ensuring adherence to the style guide.</action>
  
  <output>Refactored Lean 4 code.</output>
</step_framework>

### Step 3: Validation
<step_framework>
  <context_dependencies>
    - .opencode/context/lean4/style-guide.md
  </context_dependencies>
  
  <action>Ensure that the refactored code still compiles and that all proofs are still valid. Run any existing tests.</action>
  
  <output>Validated and tested Lean 4 code.</output>
</step_framework>

</process_flow>

<guidance_systems>
  <when_to_use>
    - When a section of the codebase is difficult to understand or maintain.
    - After a major feature addition, to clean up technical debt.
  </when_to_use>
  
  <when_not_to_use>
    - For adding new features or fixing bugs (unless refactoring is a necessary part of the fix).
  </when_not_to_use>
</guidance_systems>

<post_flight_check>
  <validation_requirements>
    - The refactored code is more readable and maintainable.
    - All existing functionality remains intact.
  </validation_requirements>
</post_flight_check>

## Context Dependencies Summary
- **All Steps**: .opencode/context/lean4/style-guide.md

## Success Metrics
- A measurable improvement in code quality metrics (e.g., complexity, line count).
- The refactored code is easier to understand for new developers.
