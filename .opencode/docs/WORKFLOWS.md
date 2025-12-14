# Workflows Guide

This system is built around several key workflows that automate complex, multi-step tasks. These workflows are managed by the `lean-dev-orchestrator`.

## 1. End-to-End Theorem Proving

This is the primary workflow of the system, triggered by the `/prove` command. It guides a theorem from a high-level idea to a fully implemented and documented proof.

**Stages:**

1.  **Research (`lean-researcher`)**:
    -   The orchestrator first calls the researcher to gather all relevant context. This includes searching Mathlib, arXiv, and the web for definitions, related theorems, and common proof techniques.

2.  **Planning (`lean-planner`)**:
    -   The research context is passed to the planner.
    -   The planner creates a detailed, step-by-step outline of the proof, including which lemmas from Mathlib to use.

3.  **Revision (`lean-plan-reviser`)**:
    -   This stage is crucial for handling errors. If the implementation fails, the orchestrator sends the error message and the plan to the reviser.
    -   The reviser diagnoses the problem and proposes a fix, creating a new version of the plan.

4.  **Implementation (`lean-implementer`)**:
    -   The orchestrator gives the (revised) plan to the implementer.
    -   The implementer writes the actual LEAN 4 code, following the plan step-by-step.

5.  **Documentation (`lean-codebase-manager`)**:
    -   Once the proof is successfully implemented, the orchestrator calls the codebase manager.
    -   It generates docstrings, ensures the code is well-formatted, and places the new proof in the correct file in the project.

## 2. Codebase Cleanup

This workflow, triggered by `/manage-project --organize`, is designed to improve the quality of an existing LEAN 4 project.

-   **Process**: The orchestrator uses the `lean-codebase-manager` and `lean-refactor-agent` to scan the entire project.
-   **Tasks**:
    -   Add missing documentation.
    -   Refactor long proofs into helper lemmas.
    -   Ensure consistent formatting.
    -   Suggest improvements to the file and module structure.

## 3. Document Translation

This workflow, triggered by `/translate`, converts a LEAN 4 file into a LaTeX document or vice-versa.

-   **Process**: The orchestrator uses the `lean-latex-translator` to perform the conversion.
-   **Tasks**:
    -   Map LEAN 4 keywords and tactics to LaTeX commands.
    -   Convert mathematical notation.
    -   Preserve the logical structure of the proof or definition.
