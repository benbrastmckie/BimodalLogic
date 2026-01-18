# Harmonic Aristotle API Integration Research

## Research Scope
- **Topic**: Design and integrate Harmonic Aristotle API into Lean agents
- **Focus**: MCP availability, best practices, and integration design
- **Tools Used**: Web fetch (GitHub), Local context analysis
- **Context**: Lean 4 theorem proving automation

## Executive Summary
Harmonic's Aristotle is a "mathematical superintelligence" tool for Lean 4. A Model Context Protocol (MCP) server exists (`septract/lean-aristotle-mcp`) which enables direct integration with AI agents. The recommended integration strategy involves using this MCP server in asynchronous mode to handle long-running proof tasks (1-5 minutes) without blocking agent execution.

## MCP Availability
**Yes, an MCP server exists.**

- **Repository**: [`septract/lean-aristotle-mcp`](https://github.com/septract/lean-aristotle-mcp)
- **Description**: Wraps the Aristotle API for use with Claude Code and other MCP clients.
- **Installation**:
  ```bash
  claude mcp add aristotle -e ARISTOTLE_API_KEY=$ARISTOTLE_API_KEY -- uvx --from git+https://github.com/septract/lean-aristotle-mcp aristotle-mcp
  ```
- **Tools Provided**:
  - `prove(code, context_files, wait)`: Fill `sorry` in snippets.
  - `prove_file(file, wait)`: Prove entire files with Mathlib dependency resolution.
  - `formalize(description, context_file, wait)`: Convert natural language to Lean.
  - `check_proof`, `check_prove_file`, `check_formalize`: Polling tools for async jobs.

## Best Practices for AI Agents

### 1. Asynchronous Workflow (Critical)
Aristotle proofs typically take **1-5 minutes**. Blocking the agent for this duration is inefficient and may cause timeouts.
- **Pattern**: Submit job (`wait=False`) → Receive `project_id` → Poll status periodically (`check_*`).
- **Agent Behavior**: The agent should submit the proof request, then potentially switch to another task or enter a "waiting/polling" state, rather than hanging on the tool call.

### 2. File-Based Proving
Prefer `prove_file` over `prove` for complex theorems.
- **Reason**: `prove_file` automatically handles Lake dependencies and Mathlib imports, ensuring the prover has the full context of the project.
- **Usage**: The agent should write the theorem with `sorry` to a file, then call `prove_file`.

### 3. Mock Mode for Testing
Use the mock mode during development and integration testing to avoid API costs and latency.
- **Configuration**: Set `ARISTOTLE_MOCK=true`.
- **Benefit**: Allows verifying the agent's tool-calling logic without real backend execution.

### 4. Context Management
When using `prove` (snippets), explicitly provide `context_files` to ensure definitions are visible.
- **Tip**: Pass the path to the current file and any utility files as context.

## Integration Design

### Lean Implementer Agent
**Role**: Use Aristotle to close goals (`sorry`) during implementation.

1.  **Workflow**:
    -   Write partial implementation with `sorry`.
    -   Call `prove_file(current_file, wait=False)`.
    -   Store `project_id`.
    -   Poll `check_prove_file` every 30-60 seconds.
    -   Upon success (`status="complete"`), read the output file (or result) and update the codebase.
    -   If failure, fall back to manual tactic search or report error.

2.  **Tool Definition Update**:
    -   Add `aristotle_prove_file` and `aristotle_check_status` to the implementer's toolset.

### Lean Researcher Agent
**Role**: Use Aristotle to discover theorems and formalize concepts.

1.  **Workflow (Formalization)**:
    -   Take a natural language theorem statement.
    -   Call `formalize(description, wait=True)` (formalization is usually faster, or use async if slow).
    -   Review the generated Lean statement.

2.  **Workflow (Feasibility)**:
    -   Propose a conjecture.
    -   Call `prove(conjecture_snippet, wait=False)`.
    -   If Aristotle finds a proof, the conjecture is true.
    -   If it returns a counterexample (supported by Aristotle), refine the conjecture.

## References
- **MCP Repository**: https://github.com/septract/lean-aristotle-mcp
- **Aristotle API**: https://aristotle.harmonic.fun/
- **Python Library**: `aristotlelib` (PyPI)
