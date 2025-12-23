# Command Documentation Standard

**Purpose**: Define the canonical structure and requirements for all `/command` docs and templates. Commands must use YAML front matter plus XML/@subagent-optimized sections that mirror meta/context exemplars, enforce status markers, language routing, lazy directory creation, and registry/state synchronization.

## Required Structure

1. **YAML Front Matter (top of file)**
   - `name`: slash command name (no leading slash)
   - `agent`: primary agent (orchestrator, researcher, planner, implementer, reviewer, refactorer, documenter, meta, task-adder, etc.)
   - `description`: one-line purpose
   - `context_level`: 1|2|3 (see Context Allocation)
   - `language`: primary language used by the command logic (e.g., markdown, lean, shell)
   - `subagents`: ordered list of subagents invoked by this command (by role)
   - `mcp_requirements`: required MCP servers (e.g., `lean-lsp` for Lean paths) or empty list; note planned/not-configured servers
   - `registry_impacts`: registries/state touched (e.g., TODO/state, IMPLEMENTATION_STATUS, SORRY_REGISTRY, TACTIC_REGISTRY)
   - `creates_root_on`: condition that triggers project root creation (if ever)
   - `creates_subdir`: subdir(s) created when artifacts are written (reports|plans|summaries)
   - `dry_run`: summary of routing-check behavior (no dirs/status/registry writes; MCP ping expectations)

2. **Context Loaded block** (plain list with `@` paths). Include common/system + standards and the minimal project contexts needed. For Lean flows, add project/lean4 and project/logic only when the TODO `Language: lean` or `--lang lean` flag applies.

3. **XML Sections** (order is mandatory):
   - `<context>`: system/domain/task/execution contexts
   - `<role>`: concise role description
   - `<task>`: single-paragraph mission statement
   - `<workflow_execution>`: ordered stages (id, name, action, process). Use status markers and timestamps for pre-flight/phase transitions.
   - `<routing_intelligence>`: agent selection, context-level rules, Lean routing/MCP validation, batch handling if applicable.
   - `<artifact_management>`: lazy creation guardrails, artifact naming, state/TODO/registry sync.
   - `<quality_standards>`: status markers, language routing, no emojis, validation expectations.
   - `<usage_examples>`: minimal examples reflecting real syntax (include flags where relevant).
   - `<validation>`: pre/mid/post-flight checks.

4. **Status Markers**
   - Tasks/phases must move through `[NOT STARTED] → [IN PROGRESS] → [COMPLETED]/[BLOCKED]/[ABANDONED]` with timestamps per status-markers.md.
   - Commands that generate artifacts must ensure summaries are produced/updated and linked in TODO/state.

5. **Lazy Directory Creation**
   - Never create project roots/subdirs until writing an artifact. When writing, create only the needed subdir (reports|plans|summaries). Do not emit placeholders.

6. **Registry/State Sync**
   - When commands mutate task/plan/implementation status or sorry/tactic counts, sync TODO.md, `.opencode/specs/state.json`, IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, and TACTIC_REGISTRY.md in the same operation. Dry-runs skip registry writes and avoid filesystem creation.

7. **Dry-Run / Routing-Check Semantics**
   - Dry-runs perform parsing, Lean detection, MCP ping (if applicable), and subagent path preview only; they MUST NOT create directories, write artifacts, or mutate TODO/state/registries/status markers.
8. **Git Commits (Targeted)**
   - Commands must reference `git-commits.md` and use `git-workflow-manager` for scoped commits after artifacts/state updates are written.
   - Stage only task-relevant files (no `git add -A` / repo-wide adds); prefer multiple small commits over blanket commits.
   - Run appropriate checks (build/test/lint) when code changes; skip for dry-runs.

## Context Allocation (Levels)
- **Level 1**: Simple/single-file/single-operation commands (e.g., /add, /todo, /refactor small scope).
- **Level 2**: Multi-step or project-scoped commands requiring standards and project overview (e.g., /task, /plan, /implement, /document, /revise).
- **Level 3**: Comprehensive analysis or repository-wide commands (e.g., /review, /research when broad).

## Language & Lean Routing
- Use TODO `Language` metadata as the authoritative Lean intent; `--lang` flag overrides metadata. Plan `lean:` is secondary.
- For Lean routes, validate `lean-lsp` (via `uvx lean-lsp-mcp`) before creating artifacts; warn/abort gracefully if missing.
- Non-Lean defaults apply unless explicitly overridden.

## Artifact & State Expectations
- Artifact names follow standards: `reports/research-NNN.md`, `plans/implementation-NNN.md`, `summaries/{type}-summary-YYYYMMDD.md`.
- When a new artifact is written, update the project state file (if present or create when first artifact is produced) and the global state/TODO links.
- Preserve numbering and reuse attached plan/research links; do not change project numbers.

## Error Handling & Safety
- Validate inputs/flags; fail clearly on invalid formats.
- Reject directory creation without artifacts.
- No emojis in commands, outputs, or artifacts.
- Include dry-run/health-check guidance where applicable.

## Migration Guidance
- All command docs under `.opencode/command/` must follow this standard with YAML + XML ordering above.
- Templates under `.opencode/context/common/templates/` must reflect this structure and be referenced by /meta outputs.
