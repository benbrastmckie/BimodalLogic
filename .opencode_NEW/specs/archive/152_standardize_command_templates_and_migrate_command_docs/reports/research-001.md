# Research Report: Standardize command templates and migrate command docs

**Project**: #152_standardize_command_templates_and_migrate_command_docs  
**Date**: 2025-12-23  
**Research Type**: standards definition and migration guidance  
**Inputs**: specs/TODO.md; specs/state.json; .opencode/context/core/system/state-schema.md; .opencode/context/core/system/artifact-management.md; .opencode/context/core/standards/tasks.md; .opencode/context/core/standards/patterns.md; .opencode/context/core/workflows/task-breakdown.md; .opencode/command/README.md and command docs (legacy YAML/@ tags)

## Research Question
Define a unified command documentation standard and template aligned with status markers, lazy directory rules, and artifact/state synchronization; provide migration guidance for existing command docs and /meta context/templates.

## Sources Consulted
- TODO.md (task definition, status markers usage)
- state.json (numbering/state expectations)
- artifact-management.md (lazy creation, artifact naming)
- state-schema.md (state fields and timestamps)
- standards/tasks.md, standards/patterns.md (status, language, sync requirements)
- workflows/task-breakdown.md (phase breakdown guidance)
- Current .opencode/command/*.md and README.md (legacy YAML front-matter and @context/subagent tags)

## Key Findings
1. Current command docs mix YAML front matter with inline `@context`/subagent callouts and lack a single commands.md standard; lazy creation, status markers, and registry sync expectations are scattered.
2. Tasks and artifact-management standards require lazy project creation, language metadata, and registry sync (IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, TACTIC_REGISTRY.md) across commands—these must be explicit in the command standard.
3. A consistent command template should capture metadata (name, purpose, primary agent, context level, inputs/outputs, language/routing, lazy-creation guardrails), invocation syntax, context loads, workflows, artifact/state/registry sync, error handling, and examples without XML/subagent markup.
4. Migration should replace YAML/front-matter + `@...` tags with Markdown metadata/context lists, add status markers aligned to status-markers.md, and spell out artifact paths and lazy-creation boundaries per command.
5. Meta/context updates must add shared templates so /meta outputs follow the new standard, and scans should target `.opencode/command/*`, `.opencode/context/common/*`, and `.opencode/meta/*` for drift.

## Proposed commands.md outline (standard)
- Purpose and scope (commands only; cross-link to tasks/plan/report standards)
- Status markers and lifecycle: allowed markers (`[NOT STARTED]`, `[IN PROGRESS]`, `[BLOCKED]`, `[ABANDONED]`, `[COMPLETED]`) and mapping to state.status/phase; lazy-creation boundaries for commands (create project root + needed subdir only when writing artifacts)
- Required metadata per command: name, primary agent, intent, context level (1-3), language support, inputs/outputs, artifacts produced, registry sync responsibilities (IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, TACTIC_REGISTRY.md), related standards
- Invocation and arguments: syntax pattern, argument validation rules, supported flags (e.g., `--lang` override), examples
- Routing and context loading: agent/subagent roles, context selection rules (core/standards/system + project/{logic,lean4,math,physics,repo} as applicable), Lean routing and MCP validation requirements
- Artifact and state updates: artifact naming (reports/research-NNN.md, plans/implementation-NNN.md, summaries/*), TODO.md link/update rules, state.json updates (fields + timestamps), lazy directory rules, numbering reuse
- Error handling and safety: input validation, missing TODO/plan behavior, dry-run behavior, no emojis, security/logging defaults
- Examples: minimal and expanded invocation showing status updates and artifact paths

## Proposed command template (templates/command-template.md)
- Title: `# /{command} Command`
- Metadata block (bullet list):
  - **Name**: `{command}`
  - **Primary Agent**: `{agent}`
  - **Intent**: `{short purpose}`
  - **Context Level**: `{1|2|3}` with rationale
  - **Inputs**: `{arguments/flags}`
  - **Outputs/Artifacts**: `{reports|plans|summaries|none}` + lazy-creation note
  - **Registry Sync**: `{IMPLEMENTATION_STATUS.md|SORRY_REGISTRY.md|TACTIC_REGISTRY.md responsibilities}`
  - **Language Routing**: `{Language field handling, --lang overrides, Lean MCP validation}`
- Sections:
  1) Purpose and Scope
  2) Invocation and Arguments (syntax + validation rules)
  3) Context to Load (Markdown list of paths; no `@`/XML; separate common vs project contexts)
  4) Workflow Steps (ordered list; include pre-flight status markers, lazy creation guardrails, artifact/state/TODO updates, registry sync rules)
  5) Artifacts and State Updates (paths relative to project root; naming/numbering rules)
  6) Error Handling and Edge Cases
  7) Examples (basic, advanced/batch)
  8) Related Standards (links to tasks.md, artifact-management.md, status-markers.md, report/plan/summary standards)
- Conventions:
  - Use Markdown only (no XML/front-matter blocks; keep metadata in bullets)
  - Replace `@subagent` tags with descriptive routing bullets naming agent roles, not invocation syntax
  - Use status markers textually; align with status-markers.md and state schema

## Migration checklist and priority
1. Author `commands.md` standard in `.opencode/context/core/standards/commands.md` using the outline above; cross-link to tasks.md, artifact-management.md, and status-markers.md.
2. Add template file at `.opencode/context/core/templates/command-template.md` with the sections/placeholders listed above.
3. Migrate command docs in `.opencode/command/`:
   - Remove YAML front matter and `@context`/`@subagent` tags; replace with Markdown metadata and context lists.
   - Normalize section order to match the template; add status/registry/lazy-creation notes.
   - Ensure each command includes language/routing rules, artifact/state/TODO updates, registry sync responsibilities, and examples aligned with numbering/lazy creation.
4. Update `.opencode/command/README.md` to reference the new standard/template, clarify context levels, and remove legacy XML/subagent language.
5. Extend /meta support: add references/templates under `.opencode/context/core/templates/` or `.opencode/meta/` (when present) so /meta-generated commands use the new standard; ensure meta docs mention status markers, registry sync, lazy creation, and language routing.
6. Verify IMPLEMENTATION_STATUS.md/SORRY_REGISTRY.md/TACTIC_REGISTRY.md touchpoints for commands that mutate status or sorry/tactic counts; document expectations in commands.md.
7. Run drift scan: search `.opencode/command/*.md`, `.opencode/context/common/*`, `.opencode/meta/*` for legacy `@` tags, XML front matter, or outdated context paths; update links and numbering references.

## Coordination notes (IMPLEMENTATION_STATUS and lazy creation)
- Commands modifying task/plan/implementation status must sync TODO.md, state.json, and registries in the same operation; dry-runs must skip registry writes and avoid creating project roots/subdirs.
- Lazy creation: no project roots or subdirs until an artifact is written; when artifacts are produced, create only the required subdir at write time and update state concurrently.
- Numbering: reuse existing project numbers from TODO/state; do not increment `next_project_number` during command execution unless a new task is created.
- Status markers: keep TODO markers and plan phase markers aligned with status-markers.md and state.status/phase fields.

## File targets and migration risks
- Targets: `.opencode/command/*.md`, `.opencode/command/README.md`, `.opencode/context/core/templates/`, `.opencode/context/core/standards/commands.md` (new), `.opencode/context/core/system/*` references, `.opencode/meta/*` (when present).
- Risks: legacy YAML/@subagent syntax causing parser drift; inconsistent context paths after refactor; missing meta directory requiring creation when adding templates; registry sync omissions; accidental project directory creation during command runs; numbering/status mismatches with IMPLEMENTATION_STATUS.md/SORRY_REGISTRY.md/TACTIC_REGISTRY.md.
- Mitigations: adhere to lazy-creation rules in commands.md, spell out registry sync steps per command, provide examples with correct status markers, and run link/path checks post-migration.

## Recommendations / Next Steps
- Draft commands.md and command-template.md first, then refactor command docs in priority order: research → plan → task → implement → revise → review → refactor/document/add/todo/context/lean/meta.
- Update /meta guidance/templates to emit the new structure and forbid XML/@ tags.
- After migration, perform a repository-wide grep for legacy `@context`/`@subagent` markers and YAML front matter in `.opencode/command/` and `.opencode/meta/`; resolve any stragglers.

## Specialist Reports
- None; findings derived from repository standards and existing command docs.
