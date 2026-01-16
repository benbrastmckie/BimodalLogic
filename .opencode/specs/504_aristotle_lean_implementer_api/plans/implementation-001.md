---
task_number: 504
plan_version: 1
project_slug: aristotle_lean_implementer_api
language: lean
master_branch: main
github_repo: Benjamin-all/ProofChecker
timestamp: 2026-01-15T12:00:00Z
authors:
  - "@claude"
reviewers:
  - "@human"
sponsors:
  - "@human"

# METADATA
status: [NOT STARTED]
estimated_effort: 12 hours
complexity: medium
research_integrated: true
integration_strategy: "Harmonic API delegation from lean-implementer to aristotle for automated proof generation."
dependencies:
  - "lean-implementer agent"
  - "aristotle agent"
# END METADATA

# OVERVIEW
This document outlines the implementation plan for designing and integrating a harmonic API to allow the `lean-implementer` agent to delegate proof obligations to the `aristotle` agent. The goal is to leverage `aristotle`'s powerful proof generation capabilities to augment `lean-implementer`, making it more effective at completing complex proofs.

Based on user requirements, this integration will be limited to `lean-implementer`. The `lean-researcher` agent will NOT be integrated with `aristotle` to avoid long run times during the research phase where formal proofs are not strictly necessary.

The "Definition of Done" for this task includes:
1. A clearly defined and documented API for `aristotle`.
2. `lean-implementer` capable of calling this API with a proof goal.
3. `lean-implementer` capable of processing `aristotle`'s response to complete a proof.
4. End-to-end tests demonstrating successful proof delegation.

# INTEGRATION STRATEGY
The core of this task is to establish a clear, well-defined API contract between the two agents.

- **Initiator**: `lean-implementer`
- **Provider**: `aristotle`
- **Communication Protocol**: Local HTTP (e.g., via a lightweight Flask/FastAPI wrapper for `aristotle`).
- **Request Format**: A JSON object containing the Lean proof state. This will include the main goal, hypotheses, and relevant definitions from the current context.
  ```json
  {
    "lean_version": "4",
    "file_context": "import Mathlib.Data.List.Basic\n...",
    "proof_state": {
      "goal": "List.map f (l₁ ++ l₂) = List.map f l₁ ++ List.map f l₂",
      "hypotheses": [
        "f : α → β",
        "l₁ l₂ : List α"
      ]
    }
  }
  ```
- **Response Format**: A JSON object containing either a successfully generated proof term/tactic script or an error state.
  ```json
  {
    "status": "success", // or "failure"
    "proof_type": "tactic_script", // or "proof_term"
    "proof": "by induction l₁ with\n| nil => simp\n| cons h t ih => simp [ih]"
  }
  ```
- **Error Handling**: `lean-implementer` must gracefully handle cases where `aristotle` fails to find a proof or times out, falling back to its own native tactics.

# IMPLEMENTATION PHASES

### Phase 1: API Specification and `aristotle` Wrapper
- **Status**: [NOT STARTED]
- **Objective**: Finalize the API contract and create a runnable HTTP server for `aristotle`.
- **Tasks**:
  1. Formalize the JSON schemas for the request and response.
  2. Implement a lightweight Flask or FastAPI server that wraps the `aristotle` agent.
  3. Create a single endpoint (e.g., `/prove`) that accepts the proof state JSON.
  4. The endpoint should invoke `aristotle` with the provided context and return the formatted JSON response.
  5. Implement basic error handling for when `aristotle` fails.
- **Acceptance Criteria**: The `aristotle` server can be started, and the `/prove` endpoint can be successfully called with a tool like `curl`, returning a valid JSON response.
- **Estimated Effort**: 4 hours

### Phase 2: `lean-implementer` Integration Logic
- **Status**: [NOT STARTED]
- **Objective**: Modify `lean-implementer` to call the new `aristotle` API.
- **Tasks**:
  1. Identify the trigger point in `lean-implementer`'s workflow where proof delegation is appropriate (e.g., when simple tactics fail).
  2. Implement the logic to gather the current proof state (goal, hypotheses, context).
  3. Implement the client-side logic to make an HTTP request to the `aristotle` API.
  4. Add logic to parse the response from `aristotle`.
  5. Implement the mechanism to apply the returned tactic script or proof term to the current Lean goal.
- **Acceptance Criteria**: `lean-implementer` attempts to call the `aristotle` API when faced with a non-trivial proof goal.
- **Estimated Effort**: 4 hours

### Phase 3: End-to-End Testing and Refinement
- **Status**: [NOT STARTED]
- **Objective**: Verify the complete proof delegation workflow and handle edge cases.
- **Tasks**:
  1. Create a suite of test cases with Lean files containing proofs of varying difficulty.
  2. Execute `lean-implementer` on these test cases.
  3. Verify that `aristotle` is invoked correctly and its responses are applied successfully.
  4. Test and refine the fallback logic in `lean-implementer` for when `aristotle` fails.
  5. Monitor for performance and address any significant delays or timeouts.
- **Acceptance Criteria**: At least 3 test cases of medium complexity are successfully solved by `lean-implementer` via delegation to `aristotle`.
- **Estimated Effort**: 3 hours

### Phase 4: Documentation
- **Status**: [NOT STARTED]
- **Objective**: Document the new API and the integration for future maintenance.
- **Tasks**:
  1. Create a README or update the system documentation with details of the `aristotle` API (endpoint, request/response format).
  2. Update the `lean-implementer` agent's documentation to describe its new proof delegation capability.
- **Acceptance Criteria**: API and agent documentation is complete and checked into the repository.
- **Estimated Effort**: 1 hour

# ARTIFACTS
- **Plan**: `.opencode/specs/504_aristotle_lean_implementer_api/plans/implementation-001.md` (this file)
- **Source Code**: Modifications within the `lean-implementer` and `aristotle` agent source directories.
- **Documentation**: Updates to system documentation.

# ROLLBACK
- All new functionality will be developed on a dedicated feature branch.
- The integration will be controlled by a feature flag or configuration setting, allowing it to be disabled without a full rollback.
- If the integration proves unstable, the feature branch can be reverted, and the feature flag can be turned off in the main branch.
---
