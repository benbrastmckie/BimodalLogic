# Testing Guide

This document provides a comprehensive guide for testing and validating the LEAN 4 Development Suite. A systematic approach to testing is crucial to ensure all components work as expected.

---

## 1. Prerequisites

Before you begin testing, please ensure the following are set up in your environment:

-   **LEAN 4 Environment**: The `lean` command-line tool must be installed and accessible in your system's PATH.
-   **Git**: The `git` command-line tool must be installed.
-   **Project Structure**: For workflow tests, have a sample LEAN 4 project directory available.

---

## 2. Component Tests (Unit Tests)

These tests are designed to validate the functionality of individual agents in isolation.

### ✅ Test Case: `lean-researcher`
1.  **Command**: `/research "definition of a monoid in Mathlib"`
2.  **Expected Outcome**: The agent should return a summary containing relevant definitions and file paths from the Mathlib library.
3.  **Verification**: Check if the output is accurate and relevant to the query.

### ✅ Test Case: `lean-refactor-agent`
1.  **Setup**: Create a `.lean` file with a long, poorly formatted proof.
2.  **Command**: `/refactor <path_to_your_file.lean>`
3.  **Expected Outcome**: The agent should modify the file, breaking the long proof into smaller helper lemmas and improving the formatting.
4.  **Verification**:
    -   Confirm the file was modified.
    -   Run `lean <path_to_your_file.lean>` to ensure the refactored proof is still valid.

---

## 3. Integration Tests

These tests validate that a primary agent can correctly manage and coordinate its subagents.

### ✅ Test Case: `lean-plan-reviser` Integration
1.  **Setup**: This is a more advanced test. You need to manually trigger the `lean-plan-reviser` with a sample proof plan and a simulated error message.
2.  **Action**: Provide the agent with a plan and an error like `"tactic 'rw' failed"`.
3.  **Expected Outcome**: The `feedback-analyzer` subagent should first diagnose the error, and then the `strategy-adjuster` subagent should propose a concrete change to the plan.
4.  **Verification**: Check if the final output is a revised plan that addresses the simulated error.

---

## 4. End-to-End Workflow Tests

These are the most important tests, validating the entire system's ability to perform complex tasks from start to finish.

### ✅ Test Case: Full Theorem Proving Workflow
1.  **Command**: `/prove "∀ (a b : ℕ), a + b = b + a"`
2.  **Expected Outcome**: The system should execute the full 5-stage workflow:
    -   **Research**: Gathers info on natural number addition.
    -   **Planning**: Creates a proof plan (likely using induction).
    -   **Implementation**: Writes the LEAN 4 code for the proof.
    -   **Revision**: (This stage may be skipped if the implementation is successful on the first try).
    -   **Documentation**: Adds docstrings to the new theorem.
3.  **Verification**:
    -   A new `.lean` file (or a modification to an existing one) should be created.
    -   The file should contain a valid, documented proof of the commutativity of addition.
    -   Run `lean` on the file to confirm there are no errors.

### ✅ Test Case: Codebase Cleanup Workflow
1.  **Setup**: Create a small, messy LEAN 4 project with multiple files, missing documentation, and inconsistent formatting.
2.  **Command**: `/manage-project --organize`
3.  **Expected Outcome**: The system should recursively scan the project and make several improvements.
4.  **Verification**: Use `git diff` to review the changes. You should see added docstrings, improved formatting, and potentially some refactored proofs.

---

## 5. Command Reference Checklist

Use this checklist to perform a final validation of all entry points.

-   [ ] `/prove`: Triggers the end-to-end workflow.
-   [ ] `/research`: Returns relevant information.
-   [ ] `/implement`: Correctly implements a given plan file.
-   [ ] `/refactor`: Improves a given `.lean` file.
-   [ ] `/translate`: Converts a file between LEAN 4 and LaTeX.
-   [ ] `/manage-project --status`: Returns a status report.
-   [ ] `/manage-project --organize`: Triggers the cleanup workflow.
