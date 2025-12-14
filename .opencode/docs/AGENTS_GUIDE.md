# Agents Guide

This document provides a reference for each of the primary agents in the system.

### 1. `orchestrator`
-   **Role**: The central coordinator.
-   **Manages**: All other primary agents and the main workflows.

### 2. `researcher`
-   **Role**: Information Gatherer.
-   **Purpose**: Collects background information to support the proving process.
-   **Subagents**:
    -   `web-searcher`: Searches the web for mathematical concepts.
    -   `arxiv-retriever`: Fetches academic papers from arXiv.
    -   `mathlib-explorer`: Searches the local Mathlib for relevant definitions and theorems.

### 3. `planner`
-   **Role**: Proof Strategist.
-   **Purpose**: Creates a structured outline for a LEAN 4 proof.
-   **Subagents**:
    -   `mathlib-searcher`: Finds specific lemmas in Mathlib to use in the plan.
    -   `proof-strategist`: Decides on the high-level approach for the proof (e.g., induction, contradiction).

### 4. `reviser`
-   **Role**: Problem Solver.
-   **Purpose**: Diagnoses and fixes issues in a proof plan when the implementation fails.
-   **Subagents**:
    -   `feedback-analyzer`: Interprets error messages from the LEAN compiler.
    -   `strategy-adjuster`: Proposes a specific change to the plan to fix the error.

### 5. `implementer`
-   **Role**: LEAN 4 Coder.
-   **Purpose**: Translates a proof plan into executable LEAN 4 code.
-   **Subagents**:
    -   `tactic-selector`: Chooses the best LEAN 4 tactic for a given proof step.
    -   `code-generator`: Writes the LEAN 4 syntax.
    -   `lean-linter`: Checks the generated code for style and correctness.

### 6. `codebase`
-   **Role**: Codebase Maintainer.
-   **Purpose**: Organizes files, adds documentation, and ensures the overall quality of the project.
-   **Subagents**:
    -   `docstring-writer`: Generates documentation for proofs and definitions.
    -   `file-organizer`: Suggests how to structure files and modules.
    -   `dependency-analyzer`: Analyzes the import graph of the project.

### 7. `refactor`
-   **Role**: Code Improver.
-   **Purpose**: Refactors existing LEAN 4 code to make it more readable and efficient.
-   **Subagents**:
    -   `lemma-extractor`: Pulls out parts of a long proof into helper lemmas.
    -   `proof-simplifier`: Finds shorter or more elegant proof tactics.
    -   `code-formatter`: Applies consistent styling.

### 8. `translator`
-   **Role**: Document Converter.
-   **Purpose**: Translates between LEAN 4 code and LaTeX documents.
-   **Subagents**:
    -   `syntax-converter`: Maps LEAN 4 syntax to LaTeX commands.
    -   `notation-mapper`: Handles mathematical notation differences.

### 9. `project`
-   **Role**: Version Control Specialist.
-   **Purpose**: Manages the project state, tracks progress, and interacts with Git.
-   **Subagents**:
    -   `git-handler`: Executes Git commands (commit, branch, etc.).
    -   `progress-tracker`: Maintains a log of completed and pending tasks.
