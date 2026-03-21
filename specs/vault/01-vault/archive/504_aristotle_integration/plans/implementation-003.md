# Implementation Plan: Aristotle Integration (v3)

- **Task**: 504
- **Version**: 3
- **Revised**: 2026-01-15
- **Previous Plan**: [implementation-002.md](implementation-002.md)
- **Revision Note**: Per user feedback, this version removes the integration of Aristotle with the `lean-researcher` agent to avoid long run times during the research phase. The integration will now focus exclusively on the `lean-implementer` for proof delegation.

---

## 1. Metadata

- **Task Number**: 504
- **Task Description**: Integration of harmonic API for aristotle into the lean-implementer agent.
- **Language**: lean
- **Integration Strategy**: Direct integration with the `septract/lean-aristotle-mcp` server, leveraging an asynchronous, polling-based workflow to manage long-running proof tasks for the `lean-implementer`.
- **Complexity**: Medium
- **Total Estimated Effort**: 3-5 hours
- **Mathlib Dependencies**: Handled by the `lean-aristotle-mcp` tool.

---

## 2. Overview

This plan revises the approach for integrating the Aristotle proof assistant. Based on the research findings and user feedback, we will integrate the existing `septract/lean-aristotle-mcp` Model Context Protocol (MCP) server **only with the `lean-implementer` agent**. The `lean-researcher` agent will not be modified.

The primary technical challenge is adapting the `lean-implementer` to handle the long-running nature of Aristotle's proof tasks (1-5 minutes). This will be accomplished by implementing an asynchronous, polling-based workflow where the agent can submit a proof, receive a project ID, and periodically check the status without blocking its main execution thread.

**Definition of Done**:
- The `lean-aristotle-mcp` tool is installed and configured in the environment.
- `lean-implementer` can successfully delegate a `sorry` to Aristotle, poll for the result, and integrate the completed proof.
- The agent correctly handles both successful and failed proof attempts.
- The `lean-implementer` documentation is updated to reflect the new capabilities.

---

## 3. Integration Strategy

The core strategy is to wrap the `lean-aristotle-mcp` tools within the `lean-implementer` skill.

1.  **Asynchronous Workflow**: The primary workflow will be asynchronous.
    -   Call `prove_file(..., wait=False)`.
    -   Receive a `project_id`.
    -   Enter a polling loop, calling `check_prove_file(project_id)` at intervals (e.g., every 30 seconds).
    -   Handle the final status (`completed` or `failed`).

2.  **Configuration**: The integration will rely on environment variables (`ARISTOTLE_API_KEY`, `ARISTOTLE_MOCK`) for configuration, which should be managed securely.

---

## 4. Implementation Phases

### Phase 1: MCP Tool Setup & Configuration
- **Status**: [NOT STARTED]
- **Objective**: Install and configure the `lean-aristotle-mcp` tool.
- **Tasks**:
    1.  Add the MCP tool using the `claude mcp add` command as specified in the research report.
    2.  Establish a secure method for managing the `ARISTOTLE_API_KEY` environment variable.
    3.  Verify the installation by running a simple command in mock mode (`ARISTOTLE_MOCK=true`).
- **Acceptance Criteria**: The `aristotle-mcp` tools are callable from the command line.
- **Estimated Effort**: 0.5 hours

### Phase 2: `lean-implementer` Integration
- **Status**: [NOT STARTED]
- **Objective**: Integrate Aristotle's proof-solving capability into the `lean-implementer` agent.
- **Tasks**:
    1.  Define new tools in the `lean-implementer`'s skill definition corresponding to `prove_file` and `check_prove_file`.
    2.  Implement the core asynchronous logic:
        -   Identify a `sorry` to be solved.
        -   Write the current buffer to a temporary file if necessary.
        -   Call `prove_file` with `wait=False`.
        -   Implement a polling loop that calls `check_prove_file` and handles pending, success, and failure states.
    3.  On success, parse the result and replace the `sorry` in the original file.
    4.  On failure, log the error and report back to the user that the proof could not be completed.
- **Acceptance Criteria**: The `lean-implementer` can autonomously solve a `sorry` in a Lean file using Aristotle.
- **Estimated Effort**: 2-3 hours

### Phase 3: Testing and Validation
- **Status**: [NOT STARTED]
- **Objective**: Ensure the integration is robust and handles various scenarios correctly.
- **Tasks**:
    1.  Create a test suite for the `lean-implementer` that covers:
        -   A successful asynchronous proof completion.
        -   A failed proof attempt.
        -   A timeout scenario during polling.
    2.  Conduct all tests using the mock mode (`ARISTOTLE_MOCK=true`) to ensure the agent logic is sound without incurring API costs.
- **Acceptance Criteria**: All test cases pass.
- **Estimated Effort**: 0.5 hours

### Phase 4: Documentation
- **Status**: [NOT STARTED]
- **Objective**: Update agent documentation to reflect the new capabilities.
- **Tasks**:
    1.  Update the `lean-implementer`'s documentation to explain its new ability to use Aristotle and the expected workflow.
- **Acceptance Criteria**: Documentation is updated and accurately reflects the new features.
- **Estimated Effort**: 0.5 hours

---

## 5. Rollback Plan

- **Short-term**: If issues arise during a phase, the `lean-implementer` skill definition can be reverted to its previous state by removing the new tool definitions and workflow logic. Git will be used to manage these changes.
- **Long-term**: If the `lean-aristotle-mcp` integration proves unstable, we can disable the tools by default and remove the MCP installation. The agent will revert to its previous functionality without errors.
- **Dependency Removal**: The MCP tool can be removed by running `claude mcp remove aristotle`.
