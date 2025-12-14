# System Architecture

This system employs a hierarchical, manager-worker agent architecture. This design is highly modular, scalable, and efficient at managing context.

## 1. The Orchestrator

At the top level is the **`orchestrator`**. It is the single entry point for all requests.

-   **Role**: Acts as the "project manager" for the AI team.
-   **Function**:
    -   Analyzes the user's request.
    -   Selects the appropriate primary agent for the task.
    -   Manages the execution of complex, multi-stage workflows, such as the 5-stage `end-to-end-theorem-proving` process.
    -   Maintains the state of the LEAN 4 project.

## 2. Primary Agents

The orchestrator delegates tasks to a team of 8 **Primary Agents**. Each is a specialist in a specific domain of the LEAN 4 development lifecycle.

-   **Examples**: `researcher`, `planner`, `implementer`, `refactor`.
-   **Function**: Each primary agent is responsible for accomplishing a high-level goal. They manage the process by breaking it down into smaller steps and delegating those steps to their own team of subagents.

## 3. Subagents

Each primary agent has a team of **Subagents**. These are highly specialized "workers" that perform a single, well-defined task.

-   **Examples**: `arxiv-retriever`, `proof-strategist`, `tactic-selector`, `lemma-extractor`.
-   **Function**: Subagents do the "real" work. For example, the `implementer` might call its `tactic-selector` subagent to decide which LEAN 4 tactic to use for a specific proof step.

## Data Flow Example: `/prove` command

1.  **User** runs `/prove "theorem..."`.
2.  **`orchestrator`** receives the request and initiates the `end-to-end-theorem-proving` workflow.
3.  **Orchestrator** calls the **`researcher`** (Primary Agent).
4.  **`researcher`** calls its **`arxiv-retriever`** and **`web-searcher`** (Subagents) to gather information.
5.  The research results are passed back to the **Orchestrator**.
6.  **Orchestrator** then calls the **`planner`** with the research context to create a proof plan.
7.  This process continues through all 5 stages, with the orchestrator managing the flow of data between the specialist primary agents.
