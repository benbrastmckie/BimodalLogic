# Research Report: Optimize .opencode command subagent routing and metadata

**Project**: #155_optimize_opencode_command_subagent_routing_and_metadata  
**Date**: 2025-12-23  
**Research Type**: command-routing optimization  
**Status**: [RESEARCHED]

## Summary
- Current command docs already use YAML+XML standard but lack explicit subagent lists, dry-run routing guards, and uniform MCP validation hooks (especially Lean paths and registry-touching flows). 
- Subagent inventory spans orchestration, Lean, planning, research, documentation, refactor, batch/task management, and code-review specialists; most have no MCP deps except Lean flows requiring `lean-lsp` (uvx lean-lsp-mcp) and planned servers flagged as warnings. 
- Each command’s routing can be made explicit by adding `subagents:` metadata (ordered), preflight routing-check sections, and MCP validation steps; dry-runs must avoid directory creation and registry writes. 
- TODO/state/registry sync rules are consistent in standards but need per-command metadata fields capturing which registries are touched and when; routing checks should reuse these without emitting artifacts. 
- Lazy creation rules are respected in docs but should be codified in metadata per command (subdir+artifact type) to prevent accidental root creation during routing probes.

## Subagent Inventory
| Name | Role | Capabilities | Required Contexts | MCP/Server Deps | Notes |
| --- | --- | --- | --- | --- | --- |
| orchestrator | Main task router | Routes commands, status propagation, batching | commands.md, tasks.md, status-markers, artifact-management | None | Used by /task, /context; delegates to specialists |
| task-adder | Create tasks | Numbering, TODO/state writes | TODO.md, state.json, tasks.md | None | /add; no dirs created |
| planner | Plan author | Plan creation/revision | TODO.md, state.json, plan standard | None | /plan, /revise |
| researcher | Research orchestrator | Produce research reports | TODO/state, report standard | None | /research |
| implementation-orchestrator | Plan executor | Execute phases, summarize | TODO/state, code/patterns | None | /implement |
| lean-implementation-orchestrator | Lean plan executor | Lean phases, Lean specialists | lean4/logic contexts | **lean-lsp (uvx lean-lsp-mcp)** required; planned lean-explore/loogle warn | /lean; abort if MCP missing |
| reviewer | Gap/verification | Analysis, task proposals | commands/tasks standards, FEATURE_REGISTRY, IMPLEMENTATION_STATUS | None | /review, /todo maintenance path |
| refactorer | Refactor specialist | Style-check, refactors | code/patterns | None; validate lean-lsp if Lean file | /refactor |
| documenter | Docs specialist | Doc analysis + writing | documentation standard | None | /document |
| meta | System builder | Generates agent/command systems | templates, context guide | None | /meta |
| context-refactor | Context reorg planner | Plans context refactor | context guide | None | invoked via /context |
| context-references | Context mapping | Generates reference-update plan | context guide | None | invoked via /context |
| batch-task-orchestrator | Batch executor | Wave-based multi-task execution | tasks/commands standards | None | used by /task batches |
| batch-status-manager | Batch status sync | Atomic status updates | status-markers, state schema | None | used by /task batches |
| complexity-analyzer | Analysis specialist | Complexity estimates | Lean/project contexts when used | None | optional via /lean analysis |
| dependency-mapper | Dependency mapping | Dependency graphs | Lean/project contexts when used | None | optional via /lean analysis |
| library-navigator | Library search | Lean lib lookup | Lean contexts | **lean-lsp** | optional via /lean research |
| proof-strategy-advisor | Strategy guidance | Suggest proof strategies | Lean contexts | **lean-lsp** | optional via /lean research |
| tactic-recommender | Tactic sequencing | Suggest tactics | Lean contexts | **lean-lsp** | optional via /lean research |
| proof-developer | Lean implementation | Implement proofs | Lean contexts | **lean-lsp** | via /lean implementation |
| proof-optimizer | Optimize proofs | Simplify/optimize | Lean contexts | **lean-lsp** | optional via /lean optimize |
| performance-profiler | Perf profiling | Profile Lean proofs | Lean contexts | **lean-lsp** | optional via /lean optimize |
| example-builder | Example generator | Build examples/tests | Lean contexts | **lean-lsp** | optional via /lean docs |
| documentation-generator | Docs generator | Generate docs | doc standards | None | optional via /lean docs |
| doc-analyzer | Doc analyzer | Find doc gaps | doc standards | None | via /document |
| style-checker | Style enforcement | Style checks | code/patterns | None | via refactor/lean/review |
| code-reviewer | Code review | Review changes | code standards | None | via /review or optional lean verification |

## Command-to-Subagent Mapping
| Command | Primary Agent | Subagents Invoked (order) | Trigger Points | Artifacts Created | Lazy-Creation Notes | Dry-Run/Routing Checks | TODO/State/Registry Impacts |
| --- | --- | --- | --- | --- | --- | --- | --- |
| /add | task-adder | (none) | On creation of tasks | None (only TODO/state edits) | No dirs ever | `--dry-run` should parse/number but skip writes | Increments next_project_number; updates TODO/state; no registries |
| /todo | orchestrator | reviewer (todo-maintenance) | Analyze→migrate phases | Optional reports (if reviewer emits) | No new roots; move existing only | `--dry-run` skip moves/writes | Sync TODO/state/archive; update FEATURE/IMPLEMENTATION_STATUS; skip registries unless specified |
| /research | researcher | web-research-specialist | After preflight status set | reports/research-XXX.md | Create project root+reports only on write | Add routing-check: validate task + Lean intent + MCP (if Lean) without dirs | TODO/state to [IN PROGRESS]→[RESEARCHED]; no registries |
| /plan | planner | planner core | After preflight status set | plans/implementation-XXX.md | Create root+plans only on write | Routing-check: task+Lean detection; no dirs | TODO/state [IN PROGRESS]→[PLANNED]; registries only if implementation status expectations change |
| /revise | planner | planner core | After preflight validation | plans/implementation-{N+1}.md | Use existing plans/; no new root | Routing-check: ensure plan link exists; no dirs | TODO/state link update; registries if implementation status affected |
| /implement | implementation-orchestrator | implementer subagents | During ExecutePhases | summaries/implementation-summary-YYYYMMDD.md (+ plan updates) | Create subdir only when writing summary; reuse plan dir | Routing-check: validate plan path, Lean intent, MCP if Lean; no dirs | TODO/state status updates; registries when implementation status/sorry/tactic counts change |
| /lean | lean-implementation-orchestrator | complexity-analyzer → dependency-mapper → (optional research: library-navigator, proof-strategy-advisor, tactic-recommender) → proof-developer → (verification: code-reviewer/style-checker) → (optimize: proof-optimizer/performance-profiler) → (docs: example-builder/documentation-generator) | PhaseExecution per flags | reports/{analysis|research|verification}-NNN.md; summaries/implementation-summary-YYYYMMDD.md; plan updates | Create root/subdir only when writing each artifact; reuse existing plan dir | Mandatory MCP validation `lean-lsp`; routing-check should run MCP ping and plan existence without dirs | TODO/state status + timestamps; registries IMPLEMENTATION_STATUS/SORRY_REGISTRY/TACTIC_REGISTRY on Lean changes |
| /task | orchestrator | batch-task-orchestrator + batch-status-manager; routes to implementer/researcher/planner/documenter/refactorer/reviewer/lean-implementation-orchestrator as per task type | During Execute stage per task | Summaries when artifacts produced; updates existing plans | Create roots/subdirs only when delegated agent writes | Routing-check: expand numbers, detect Lean, ensure linked plan/research presence; no dirs, no registry writes | TODO/plan/state statuses; registries when status or sorry/tactic counts change; skip on dry-run |
| /review | reviewer | reviewer gap-analysis; optional /add for new tasks | GapAnalysis→TaskRegistration | Optional reports/analysis-NNN.md | Create root/subdir only if report written | Routing-check: scope parse; no dirs | TODO/state via /add; update FEATURE/IMPLEMENTATION_STATUS; registries unchanged unless verification updates |
| /refactor | refactorer | style-checker, refactoring-assistant | Refactor stage | Optional reports/refactoring-NNN.md; summaries if produced | Create only when report/summary written | Routing-check: validate files, Lean detection; no dirs | TODO/state if task-bound; registries when implementation status changes |
| /document | documenter | doc-analyzer → doc-writer → documentation-generator (optional) | ExecuteDocumentation | Optional summaries/{type}-summary-YYYYMMDD.md | Create summary only when written | Routing-check: scope parse; no dirs | TODO/state if task-bound; registries usually untouched |
| /context | orchestrator | context-refactor → context-references → task-adder | Sequential stages | Plans from subagents; task entries via /add | Subagents create only when writing their artifacts; orchestrator none | Routing-check: validate refs; no dirs | TODO/state via /add; registries unchanged |
| /meta | meta | meta subagents | Stage 0..7 per interview | Many generated system files | Creates structures during generation (not used in current repo tasks) | Routing-check: detect existing .opencode; no dirs until generate | Not task-bound; no TODO/state unless creating tasks |

## Recommendations (metadata and routing improvements)
- Add `subagents:` YAML array to every command doc (ordered) plus `registry_impacts:` and `mcp_requirements:` fields (e.g., `lean-lsp` required for /lean and any Lean-routed paths via /task). 
- Add `dry_run:` section in workflow/validation for all commands, explicitly stating: no directory creation, no registry writes, MCP ping only (for Lean), and status markers untouched. 
- For Lean-capable commands (/lean, /task when Lean, /plan /research when Lean intent): add a preflight MCP validation step (ping `uvx lean-lsp-mcp`) and warn/abort with remediation if missing; mark planned servers as “planned/not configured”. 
- Embed lazy-creation metadata per command: `creates_root_on:` (first artifact write) and `creates_subdir:` (reports|plans|summaries) to prevent orchestration code from pre-creating. 
- For status/registry clarity, add per-command matrices indicating which status markers transition when and which registries are touched; reuse in routing-check paths without writing artifacts. 
- Extend usage examples to include `--dry-run`/routing-check invocations and Lean overrides (`--lang lean`) to drive correct paths. 

## Execution-Flow Fixes
- Standardize preflight order: (1) parse/validate args; (2) detect Lean + MCP ping; (3) status markers to [IN PROGRESS] only when executing, not during dry-run; (4) collect linked artifacts; (5) only then delegate to subagents. 
- In /task batching, run routing-check wave to confirm per-task agent path and MCP availability before any status change; skip tasks that fail validation and report. 
- In /plan and /research, set status markers before delegation but ensure routing-check mode leaves statuses untouched and avoids root creation. 
- In /implement and /lean, require plan existence before status updates; for Lean, refuse to proceed if MCP missing. 
- In /todo maintenance, require confirmation gates but ensure dry-run path avoids archive moves and state writes. 

## Dry-Run / Routing-Check Guidance
- Add `--dry-run` (or `--routing-check`) to all commands: perform parsing, Lean detection, MCP ping (if applicable), and registry-impact preview; **no directory creation, no artifact writes, no TODO/state/registry edits**. 
- Return proposed subagent sequence, expected artifacts (by type), and whether MCP/linked artifacts are satisfied. 
- For Lean: return MCP status and remediation steps; do not set statuses to [IN PROGRESS]. 

## Risks and Open Questions
- Some subagent definitions (e.g., meta’s generation subagents) lack formal MCP checks—should generation be gated by additional validations? 
- Registry update triggers may differ across implementations; need confirmation of when refactors or documentation changes should touch IMPLEMENTATION_STATUS vs. code-focused commands. 
- Batch routing in /task could race on status updates if underlying implementation is not atomic; ensure batch-status-manager is enforced. 
- Planned MCP servers (lean-explore/loogle/lean-search) are not available—need policy on optional vs. blocking behavior.

## Specialist Reports
- (Not produced; single-pass analysis based on existing standards and command docs.)
