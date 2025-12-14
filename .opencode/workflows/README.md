# Workflows README

This directory contains definitions for complex, multi-stage processes that the `lean-dev-orchestrator` can execute. Each workflow file outlines the sequence of actions, the agents involved, and the context required at each step.

## Available Workflows

-   **`end-to-end-theorem-proving.md`**: The primary workflow of the system. It orchestrates the entire 5-stage process from initial research to final documentation for proving a new theorem.
    -   **Trigger**: `/prove <theorem>`
    -   **Agents Involved**: All primary agents.

-   **`codebase-cleanup.md`**: A workflow for improving the quality of an existing codebase. It involves refactoring proofs, improving documentation, and organizing files.
    -   **Trigger**: Can be invoked via `/manage-project --organize` or run on a schedule.
    -   **Agents Involved**: `lean-refactor-agent`, `codebase`.

-   **`document-translation.md`**: A workflow for generating human-readable documentation (LaTeX) from LEAN 4 source files.
    -   **Trigger**: `/translate <file>`
    -   **Agents Involved**: `lean-latex-translator`.

## How They Work

Each workflow is essentially a state machine managed by the `lean-dev-orchestrator`. The file defines the states (stages), transitions, and conditions for moving from one stage to the next. This provides a structured and reliable way to automate complex tasks.
