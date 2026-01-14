# Implementation Plan: Optimize .opencode command subagent routing and metadata
- **Task**: 155 - Optimize .opencode command subagent routing and metadata
- **Status**: [COMPLETED]
- **Started**: 2025-12-23T18:15:00Z
- **Completed**: 2025-12-23T18:45:00Z
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: [.opencode/specs/155_optimize_opencode_command_subagent_routing_and_metadata/reports/research-001.md](../reports/research-001.md)
- **Artifacts**: plans/implementation-001.md
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Language**: markdown
- **Lean Intent**: false

## Overview
This plan implements the routing and metadata optimizations for all .opencode commands, adding explicit subagent lists, MCP requirements, registry-impact matrices, and dry-run/routing-check semantics while reinforcing lazy directory creation. It encodes preflight MCP validation (especially Lean `lean-lsp`), status/registry guardrails, and lazy-creation triggers in command docs. Success means each command doc reflects correct routing, dry-run behavior, MCP gating, and lazy-creation boundaries without altering existing numbering/state rules.

## Goals & Non-Goals
- **Goals**:
  - Add standardized metadata to command docs: ordered `subagents`, `mcp_requirements`, `registry_impacts`, `creates_root_on`/`creates_subdir`, and `dry_run` semantics.
  - Define routing-check/dry-run flows and MCP validation hooks (Lean-sensitive) without side effects or premature directory creation.
  - Align command execution flows with lazy-creation guards and status/TODO/state/registry sync expectations.
  - Refresh verification notes and usage examples to show routing-check and Lean override/detection paths.
- **Non-Goals**:
  - Implement code changes in command executables (docs/standards only).
  - Modify project numbering or introduce new MCP servers beyond `lean-lsp` validation/remediation guidance.
  - Create summaries or additional artifacts beyond this plan.

## Risks & Mitigations
- Risk: Missing a command’s registry-impact nuance (IMPLEMENTATION_STATUS/SORRY_REGISTRY/TACTIC_REGISTRY) leads to drift. **Mitigation**: Cross-check research-001 mapping and status-markers/tasks standards per command.
- Risk: Misstating dry-run behavior or lazy creation could cause unintended directory creation. **Mitigation**: Explicitly document “no dirs/registries/status writes” in dry-run sections and specify `creates_root_on`/`creates_subdir` per command.
- Risk: Lean MCP gating underspecified for Lean-capable flows. **Mitigation**: Require `lean-lsp` ping/remediation steps for /lean and any Lean-path routing; mark planned servers as “planned/not configured”.
- Risk: Phase scope creep across many commands. **Mitigation**: Tackle metadata/backmatter first, then routing/dry-run, then flow/lazy-creation sync, then verification/examples; keep each phase to 1–1.5h with explicit verification.

## Implementation Phases

### Phase 1: Update command metadata/backmatter [NOT STARTED]
- **Goal:** Add ordered subagent lists and MCP/registry/dry-run/lazy-creation metadata fields to command docs and standards.
- **Tasks:**
  - [ ] Apply research-001 subagent inventory to each command doc (subagents ordered, roles noted).
  - [ ] Add `mcp_requirements` and `registry_impacts` fields per command, capturing Lean `lean-lsp` requirement where applicable.
  - [ ] Add `creates_root_on` and `creates_subdir` fields to document lazy-creation triggers.
  - [ ] Ensure standards/commands.md reflects the new metadata fields and examples.
- **Timing:** 1.0 hour
- **Dependencies:** Research-001, commands.md baseline
- **Verification:** All command docs contain the new fields with consistent formatting; commands.md template updated.

### Phase 2: Define routing-check and MCP validation flow [NOT STARTED]
- **Goal:** Document dry-run/routing-check paths and MCP validation hooks (especially Lean) without side effects.
- **Tasks:**
  - [ ] Add `dry_run`/`routing_check` sections describing no directory/registry/status writes and expected outputs.
  - [ ] Specify MCP ping (`uvx lean-lsp-mcp`) and remediation guidance for Lean-capable paths (/lean, /task when Lean, /plan or /research with Lean intent).
  - [ ] Mark planned servers (lean-explore/loogle/lean-search) as “planned/not configured” warnings.
- **Timing:** 1.0 hour
- **Dependencies:** Phase 1
- **Verification:** Dry-run language present in each command doc; MCP validation steps documented with remediation and no side effects.

### Phase 3: Align command flow with lazy-creation and status/registry sync [NOT STARTED]
- **Goal:** Encode sequencing for status markers, TODO/state sync, registry touchpoints, and lazy-creation guards across commands.
- **Tasks:**
  - [ ] Document preflight order: parse args → Lean detection → MCP ping → status updates only on execute (not dry-run) → artifact writes with lazy creation.
  - [ ] For each command, note which artifacts trigger root/subdir creation and how status markers propagate to TODO/state/plan.
  - [ ] Add registry-touch timing (IMPLEMENTATION_STATUS/SORRY/T ACTIC) and explicitly state “no registry writes” in dry-run/routing-check.
  - [ ] Ensure /task batch routing uses batch-status-manager for atomic status updates and skip/write rules for invalid tasks.
- **Timing:** 1.0–1.5 hours
- **Dependencies:** Phases 1–2
- **Verification:** Command docs show ordered execution flow with lazy-creation gates and status/registry sync rules; batch routing notes present for /task.

### Phase 4: Verification and examples refresh [NOT STARTED]
- **Goal:** Validate completeness and provide usage examples demonstrating routing-check and Lean overrides.
- **Tasks:**
  - [ ] Cross-check against research-001 command-to-subagent mapping and standards (plan/tasks/artifact-management/state-schema/status-markers).
  - [ ] Add/refresh examples showing `--dry-run`/routing-check and `--lang lean` override where relevant.
  - [ ] Quick consistency sweep for formatting and link correctness (relative paths intact).
- **Timing:** 0.5–0.75 hour
- **Dependencies:** Phases 1–3
- **Verification:** Examples present; links validate; metadata fields consistent; no missing commands.

## Testing & Validation
- [ ] Spot-check Lean-capable commands for documented MCP ping/remediation steps without side effects.
- [ ] Verify each command doc lists subagents in order and includes registry-impact notes and lazy-creation triggers.
- [ ] Confirm dry-run/routing-check language forbids directory creation, status/registry writes, and artifact emission.
- [ ] Consistency check against standards: plan.md, tasks.md, artifact-management.md, state-schema.md, status-markers.md.

## Artifacts & Outputs
- plans/implementation-001.md (this document)

## Rollback/Contingency
- If metadata additions conflict with existing docs, revert the specific command doc section and re-align with commands.md template before reapplying changes.
- If MCP validation guidance proves incorrect for an environment, update the remediation note without altering lazy-creation or routing-check semantics.
