# Implementation Plan: Optimize .opencode command subagent routing and metadata [COMPLETED]

- **Task**: 155 (Optimize .opencode command subagent routing and metadata)
- **Project**: #155_optimize_opencode_command_subagent_routing_and_metadata
- **Version**: implementation-002
- **Status**: [COMPLETED]
- **Created**: 2025-12-23T00:00:00Z
- **Started**: 2025-12-23T00:00:00Z
- **Completed**: 2025-12-24T00:50:00Z
- **Priority**: Medium
- **Language**: markdown (no Lean intent)
- **Scope**: commands, agents, contexts, docs, routing (all)
- **Previous Version**: [.opencode/specs/155_optimize_opencode_command_subagent_routing_and_metadata/plans/implementation-001.md](./implementation-001.md)
- **Research Inputs**: [.opencode/specs/155_optimize_opencode_command_subagent_routing_and_metadata/reports/research-001.md](../reports/research-001.md)
- **Standards**: commands.md, tasks.md, plan.md, status-markers.md, artifact-management.md, context-guide.md
- **Constraints**: Markdown/meta only; lazy directory creation (roots/subdirs only on artifact writes); dry-run/routing checks must avoid directories, artifacts, TODO/state/registry writes; status markers per status-markers.md; command standards and patterns compliance; no Lean routing.

## Objectives (mirroring TODO acceptance criteria)
- Inventory all subagents with capabilities, required contexts, and MCP/server prerequisites.
- For each .opencode command, map required subagents and update metadata to list invoked subagents and invocation order.
- Update command execution flows to delegate to correct subagents with proper timing while respecting lazy directory creation and status-marker standards.
- Add dry-run/routing-check paths that validate subagent selection without creating directories or artifacts.
- Keep TODO/state consistency with numbering rules and status markers; ensure routing checks never create project directories.

## Scope & Out-of-Scope
- **In Scope**: All .opencode commands, agents, contexts, docs, routing metadata, dry-run/routing checks, registry/state touchpoint documentation, MCP validation hooks.
- **Out of Scope**: Lean code or Lean command implementation changes; non-.opencode commands; altering project numbering; introducing new MCP servers beyond documented validation/warnings.

## Deliverables
- **Plan v2**: this file (implementation-002.md).
- **optimize-report-YYYYMMDD.md**: consolidated routing/metadata update report (if produced during execution).
- **implementation-summary-YYYYMMDD.md**: optional summary if report is produced.

## Complexity Assessment
- **Level**: Moderate
- **Estimated Effort**: 1.5–3 hours
- **Required Knowledge**: command standards, tasks/plan/status-markers, artifact-management, context-guide, research-001 inventory, subagent/registry semantics, lazy-creation guardrails.
- **Potential Challenges**: Aligning per-command metadata with research-001 while preserving lazy-creation rules; ensuring dry-run/routing checks remain side-effect free; keeping status markers consistent across commands and docs.

## Technology Stack
- **Languages**: markdown
- **Frameworks/Tools**: .opencode command/agent docs, status-markers, artifact-management guidance
- **Dependencies**: None beyond docs; MCP references only for Lean validation notes (no Lean execution)

## Dependencies & Prerequisites
- Research-001 (subagent inventory, command mappings, MCP/dry-run recommendations)
- Prior plan implementation-001 for continuity
- Standards: commands.md, tasks.md, plan.md, status-markers.md, artifact-management.md, context-guide.md
- TODO.md task 155 metadata (status [IN PROGRESS], language markdown)

## Phases and Steps

### Phase A: Analyze current command/agent/subagent mapping vs standards [COMPLETED] ✅
(Completed: 2025-12-24T00:45:00Z)
**Owner**: context-references + dependency-mapper

1. **Collect sources**: Pull research-001, implementation-001, commands.md, tasks.md, status-markers.md, artifact-management.md, context-guide.md.
   - **Output**: Source packet checklist.
   - **Verification**: All sources listed with timestamps and locations.
2. **Gap scan**: Compare research-001 command→subagent mappings against current command docs to identify missing `subagents`, `mcp_requirements`, `registry_impacts`, `creates_root_on`, `creates_subdir`, `dry_run` metadata.
   - **Output**: Gap table by command.
   - **Verification**: Gap table covers all commands under .opencode/command/.*
3. **Routing issues log**: Note sequencing or lazy-creation inconsistencies (status timing, registry touchpoints) from research-001 recommendations.
   - **Output**: Issues list with severity.
   - **Verification**: Issues mapped to commands and standards references.

### Phase B: Update command metadata and routing flows [COMPLETED] ✅
(Started: 2025-12-23T21:30:00Z) (Completed: 2025-12-23T21:45:00Z)
**Owner**: implementer + doc-writer (guided by researcher findings)

1. **Metadata updates**: For each command doc, apply ordered `subagents`, `mcp_requirements`, `registry_impacts`, `creates_root_on`, `creates_subdir`, `dry_run` entries per commands.md and research-001.
   - **Output**: Updated command metadata blocks.
   - **Verification**: Metadata fields present and ordered; Lean MCP requirements called out for Lean-capable paths; planned/not-configured servers marked.
2. **Routing flow articulation**: Update workflow/routing sections to show delegation timing, MCP ping ordering, status-marker transitions, and lazy-creation gates (root only on first artifact write; subdir on artifact write).
   - **Output**: Per-command routing flow text.
   - **Verification**: Sequence includes parse → Lean detect → MCP ping (if applicable) → status updates (execute only) → artifact write with lazy creation.
3. **Dry-run/routing-check path**: Add explicit dry-run sections forbidding directory creation, artifact writes, TODO/state/registry mutations; include outputs (subagent sequence preview, MCP status, registry-impact preview).
   - **Output**: Dry-run/routing-check language per command.
   - **Verification**: Dry-run text present; no side-effect actions listed.
   - **Progress**: review.md, revise.md, and meta.md updated with ordered subagents, MCP/registry metadata, lazy-creation notes, and dry-run/routing-check semantics.

### Phase C: Validate docs/standards alignment [COMPLETED] ✅
(Completed: 2025-12-24T00:50:00Z)
**Owner**: doc-analyzer + style-checker

1. **Standards compliance pass**: Check command docs against commands.md structure (YAML + XML order) and status-markers requirements.
   - **Output**: Compliance checklist.
   - **Verification**: All required sections present; status markers formatted correctly.
2. **Registry/state consistency**: Ensure registry impacts and TODO/state sync rules are specified; confirm lazy-creation rules restated in artifact-management alignment.
   - **Output**: Registry/lazy-creation validation notes.
   - **Verification**: Each command lists registry touchpoints and explicitly states “no registry writes on dry-run.”
3. **Examples refresh**: Add/refresh usage examples including `--dry-run`/`--routing-check` and Lean override flags (`--lang lean`) where applicable.
   - **Output**: Updated examples per command.
   - **Verification**: Examples match syntax and avoid Lean routing unless explicit.

### Phase D: State/TODO sync and closure criteria [COMPLETED] ✅
(Completed: 2025-12-24T00:50:00Z)
**Owner**: batch-status-manager + task-adder (advice), implementer for doc edits

1. **Sync rules documentation**: Reaffirm TODO/state update expectations for command flows (when statuses transition, how timestamps are recorded), referencing status-markers and tasks/plan standards.
   - **Output**: Sync rules section across relevant command docs.
   - **Verification**: Status transitions include timestamps; no TODO/state changes in dry-run; lazy creation preserved.
2. **Exit checklist**: Codify acceptance criteria coverage and closure gates (metadata complete, routing flows updated, dry-run paths documented, registry/state sync rules present).
   - **Output**: Exit checklist aligned to TODO acceptance criteria.
   - **Verification**: Checklist items traceable to acceptance criteria.
3. **Report/summary stubs**: Prepare outline for optimize-report-YYYYMMDD.md and optional implementation-summary-YYYYMMDD.md (only created when executed; no directories created until write).
   - **Output**: Outline text ready for execution phase.
   - **Verification**: Outlines mention lazy-creation guardrail and linkage back to this plan.

## Risks & Mitigations
- **Directory creation during routing checks**: Mitigate by explicitly documenting “no dirs/artifacts/status/registry writes” in dry-run sections and ordering creation only at artifact write.
- **Status-marker inconsistency**: Mitigate with status-markers.md alignment checklist and examples; require timestamps on transitions.
- **MCP availability (Lean)**: Mitigate by documenting `uvx lean-lsp-mcp` ping/remediation for Lean-capable paths; mark planned servers as warnings only.
- **Coverage gaps across commands**: Mitigate with gap table (Phase A) and per-command checklist sign-off.

## Validation & Dry-Run Guardrails
- Dry-run/routing-check for every command performs only parsing, Lean detection, MCP ping (if applicable), subagent path preview, registry-impact preview.
- Dry-run forbids directory creation, artifact writes, TODO/state/registry mutations, and status-marker changes.
- Execution flows must state lazy-creation triggers: project root only when first artifact is written; subdir creation only when that artifact is written.
- Compliance check against commands.md, tasks.md, plan.md, status-markers.md, artifact-management.md.

## Exit Criteria
- Acceptance criteria from TODO met and evidenced in docs/metadata.
- Command docs include ordered subagent lists, MCP requirements, registry impacts, lazy-creation triggers, and dry-run/routing-check semantics.
- Routing flows show correct delegation timing and status-marker usage; Lean MCP validation documented where applicable.
- TODO/state sync rules documented; routing checks do not create project directories or mutate state/registries.
- optimize-report-YYYYMMDD.md produced (or ready to produce) and linked; optional summary prepared if report exists.

## Success Criteria
- All command docs under .opencode/command/ comply with commands.md structure and include required metadata fields.
- Dry-run/routing-check examples included and side-effect free.
- Lazy-creation guardrails preserved across docs; no instructions contradict artifact-management.
- Status markers and timestamps present wherever transitions are described.

## Notes
- No TODO/state edits are performed by this plan; executor must apply updates during implementation.
- Keep language markdown-only; exclude Lean routing unless explicitly flagged by task metadata/override.
