# Wave Execution Process

This process describes how to execute a batch of theorems efficiently by grouping them into "waves" based on their dependencies.

## Concept
- **Wave 1 (Independent)**: Theorems that do not depend on any other unproven theorems in the current batch. These can be proven in parallel.
- **Wave 2 (Dependent)**: Theorems that depend only on theorems in Wave 1.
- **Wave N**: Theorems that depend on theorems in Wave N-1.

## Workflow

1.  **Analysis**:
    - The **Proof Planner** or **Proof Orchestrator** analyzes the list of theorems to be proven.
    - Dependencies are mapped.

2.  **Wave Assignment**:
    - Theorems are assigned to waves.
    - Example:
        - Wave 1: `theorem_A`, `theorem_B`
        - Wave 2: `theorem_C` (depends on A), `theorem_D` (depends on B)

3.  **Execution**:
    - **Wave 1**: The **Lean Expert** implements all theorems in Wave 1.
    - **Verification**: The project is built to ensure Wave 1 is correct.
    - **Wave 2**: Once Wave 1 is verified, the **Lean Expert** implements Wave 2.

## Benefits
- **Efficiency**: Allows for parallel mental processing (or actual parallel agents if supported).
- **Stability**: Ensures that dependencies are stable before building upon them.
- **Context**: Reduces context switching by focusing on a set of related problems.
