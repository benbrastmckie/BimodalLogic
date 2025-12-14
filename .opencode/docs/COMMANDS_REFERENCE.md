# Custom Commands Reference

This document provides a reference for the custom slash commands that have been created to interact with the LEAN 4 Development Suite. These commands are the primary entry points for the system's workflows.

---

### `/prove <theorem_statement>`

-   **Description**: Initiates the full, 5-stage `end-to-end-theorem-proving` workflow. This is the main command for proving a new theorem from scratch.
-   **Arguments**:
    -   `theorem_statement` (string): The theorem you want to prove, enclosed in quotes.
-   **Example**:
    ```bash
    /prove "For any natural numbers n and m, n + m = m + n"
    ```
-   **Agent Triggered**: `lean-dev-orchestrator`

---

### `/research <topic>`

-   **Description**: Performs a targeted information gathering task without starting the full proving workflow.
-   **Arguments**:
    -   `topic` (string): The concept, theorem, or definition you want to research, in quotes.
-   **Example**:
    ```bash
    /research "The definition of a group in Mathlib"
    ```
-   **Agent Triggered**: `lean-researcher`

---

### `/implement <outline_file>`

-   **Description**: Implements a proof in LEAN 4 using a pre-existing proof plan. This skips the research and planning stages.
-   **Arguments**:
    -   `outline_file` (path): The path to a markdown file containing the proof outline.
-   **Example**:
    ```bash
    /implement "proofs/addition_commutativity_plan.md"
    ```
-   **Agent Triggered**: `lean-implementer`

---

### `/refactor <file_path> [--line <number>]`

-   **Description**: Analyzes and refactors an existing LEAN 4 file to improve its quality. It can refactor the whole file or focus on a specific proof.
-   **Arguments**:
    -   `file_path` (path): The path to the `.lean` file to refactor.
    -   `--line <number>` (optional): The line number of a specific proof to focus on.
-   **Example**:
    ```bash
    /refactor "src/theorems/basic.lean" --line 42
    ```
-   **Agent Triggered**: `lean-refactor-agent`

---

### `/translate <file_path>`

-   **Description**: Translates a file between LEAN 4 and LaTeX. The direction of translation is usually inferred from the file extension.
-   **Arguments**:
    -   `file_path` (path): The path to the file to translate.
-   **Example**:
    ```bash
    /translate "docs/paper.tex"
    ```
-   **Agent Triggered**: `lean-latex-translator`

---

### `/manage-project [--status|--organize]`

-   **Description**: Performs project-level management tasks.
-   **Arguments**:
    -   `--status` (flag): Shows the current status of the project (e.g., which proofs are complete).
    -   `--organize` (flag): Initiates the `codebase-cleanup` workflow to document, format, and organize the entire project.
-   **Example**:
    ```bash
    /manage-project --organize
    ```
-   **Agent Triggered**: `lean-project-manager` or `codebase`
