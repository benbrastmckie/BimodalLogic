# Context Management Guide

The intelligence and domain-specificity of this AI system come from its context files. These are simple markdown files located in `.opencode/context/lean4/` that provide the agents with the knowledge they need to perform their tasks.

## The Purpose of Context

Instead of hard-coding knowledge into the agent prompts, we externalize it into these files. This makes the system:

-   **Easy to Customize**: You can improve the system's knowledge of a specific mathematical domain simply by editing a text file.
-   **Transparent**: You can see exactly what knowledge the AI is using.
-   **Modular**: Knowledge is organized into logical categories, making it easy to manage.

## Context Categories

The context is organized into four subdirectories inside `.opencode/context/lean4/`:

### 1. `domain/`
-   **Purpose**: Contains core knowledge about the LEAN 4 language and mathematics.
-   **Files**:
    -   `lean4-syntax.md`: The basic syntax and keywords of LEAN 4.
    -   `mathlib-overview.md`: Information about the structure and conventions of the Mathlib library.
    -   `key-mathematical-concepts.md`: Definitions and principles for specific areas of math.
-   **How to Use**: If you are working in a specific area of mathematics (e.g., number theory), you can add a `number-theory.md` file here with key definitions and theorems for the agents to use.

### 2. `processes/`
-   **Purpose**: Defines the steps for complex workflows.
-   **Files**:
    -   `end-to-end-proof-workflow.md`: The 5-stage process that the orchestrator follows.
    -   `project-structure-best-practices.md`: Guidelines for how to organize a LEAN 4 project.
-   **How to Use**: If you want to change how the AI proves theorems, you can modify the workflow file here.

### 3. `standards/`
-   **Purpose**: Contains rules, guidelines, and quality criteria.
-   **Files**:
    -   `lean4-style-guide.md`: Coding style rules.
    -   `documentation-standards.md`: How to write good docstrings.
    -   `proof-readability-criteria.md`: What makes a proof "good" or "readable."
-   **How to Use**: You can enforce your own coding standards by modifying these files.

### 4. `templates/`
-   **Purpose**: Provides boilerplate and reusable code snippets.
-   **Files**:
    -   `new-file-template.md`: The basic structure for a new `.lean` file.
    -   `proof-structure-templates.md`: Common patterns for proofs (e.g., induction).
-   **How to Use**: Add your own common templates here to speed up code generation.
