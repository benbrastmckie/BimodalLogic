# Research: Align /task with /implement summary artifact requirements (Task 162)

- **Status**: [COMPLETED]
- **Started**: 2025-12-24
- **Completed**: 2025-12-24
- **lean**: false
- **Language**: markdown
- **Task ID**: 162

## Research Inputs
- none linked

## context
- /implement enforces summary artifact creation (summaries/implementation-summary-YYYYMMDD.md) while /task paths can execute without producing summaries, leading to audit gaps.
- Lazy-creation rules forbid creating project roots/subdirs unless writing an artifact; summaries must be emitted only when implementation produces work products.
- Status synchronization must keep TODO/state/plan markers aligned and update registries when implementation status changes.
- Key surfaces: `.opencode/command/task.md`, `.opencode/agent/subagents/task-executor.md`, `.opencode/agent/subagents/implementation-orchestrator.md`, standards (`artifact-management.md`, `tasks.md`, `commands.md`, `status-markers.md`).

## findings
1) **Parity gap**: /implement always emits an implementation summary when work is executed; /task’s delegated implementer paths may exit without a summary, breaking artifact-management expectations.
2) **Trigger rules**: Summaries should be created only when implementation work occurs (code/docs/test changes), not for status-only operations. Lazy creation must gate summaries to actual artifact writes.
3) **Delegation contract**: task-executor should, when routing to implementation-orchestrator (or lean-implementation orchestrator), require that a summary is produced whenever phases produce artifacts, and record the summary path back to TODO/state.
4) **Status sync**: TODO/state/plan must reflect summary production; atomic updates are needed to avoid TODO/state divergence. Registry updates (IMPLEMENTATION_STATUS, SORRY_REGISTRY, TACTIC_REGISTRY) should run when implementation status or sorry/tactic counts change.
5) **Dry-run/routing-check**: These modes must not create summaries or directories; they should only preview whether a summary would be required based on the planned work.
6) **Docs/metadata**: Command/agent docs must state the summary requirement, lazy-creation guardrails, and registry-touch rules to enforce parity with /implement.

## recommendations
- Update `/command/task.md` to state: when implementation work is executed, a summary artifact under `summaries/implementation-summary-YYYYMMDD.md` is mandatory; dry-run/routing-check must preview without writing.
- In `task-executor`, add a post-implementation hook that ensures summaries are emitted (reusing implementation-orchestrator helpers) and that TODO/state link the summary path; guard with lazy creation (only write when work occurred).
- In `implementation-orchestrator` (as used by /task), expose/ensure a summary writer that is invoked for /task delegations as well as /implement, maintaining the same artifact naming and status-marker updates.
- Update docs (commands.md, tasks.md, artifact-management.md references) to mention /task summary parity and lazy-creation constraints; add tests/routing-check coverage for summary expectations and non-creation during dry-run.

## next_steps
- Add summary requirement language to `/command/task.md` and `task-executor` docs/flow; wire post-implementation summary emission into /task execution paths.
- Ensure implementation-orchestrator provides a reusable summary emission path and that /task delegates to it when artifacts were produced.
- Add tests/routing checks: implementation with artifacts → summary created and linked; status-only/dry-run → no summary created; lazy creation preserved.
- Sync TODO/state with summary links and update registries when implementation status changes.
