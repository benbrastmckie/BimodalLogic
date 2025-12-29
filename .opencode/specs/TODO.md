# TODO

**Last Updated:** 2025-12-29T06:38:08Z

## Overview

- **Total Tasks:** 55
- **Completed:** 8
- **High Priority:** 8
- **Medium Priority:** 9
- **Low Priority:** 10

---

## High Priority

### 243. Implement Phase 4 from task 237 implementation plan (aggressive command file deduplication)
- **Effort**: 12-16 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: Task 237 Phase 3 (completed)
- **Research**: [Research Report](.opencode/specs/243_implement_phase_4_aggressive_command_deduplication/reports/research-001.md)

**Description**:
Implement Phase 4 from task 237's implementation plan: Remove duplicated lifecycle logic from command execution files (research.md, plan.md, implement.md, revise.md) by referencing command-lifecycle.md, reducing execution file sizes by 60-70%. This phase would analyze all 4 execution files line-by-line to identify common patterns (Stages 4-8 structure) and variations (status markers, artifacts, git commits). The goal is to create a minimal execution file structure that keeps only variations while referencing command-lifecycle.md for common logic, achieving execution file reduction from 15-25KB to 8-12KB each (56-72KB total savings).

**Phase 4 Tasks** (from implementation plan):
1. Analyze command execution file duplication (2 hours) - identify common patterns and variations
2. Design minimal execution file structure (2 hours) - variations-only template with lifecycle references
3. Refactor research-execution.md (2 hours) - remove common logic, keep only variations
4. Refactor plan-execution.md (2 hours) - remove common logic, keep only variations
5. Refactor revise-execution.md (2 hours) - remove common logic, keep only variations
6. Refactor implement-execution.md (2 hours) - remove common logic, keep only variations
7. Update command-lifecycle.md (2 hours) - enhance with variation interpretation logic
8. Integration testing (4 hours) - verify lifecycle stages execute identically across commands

**Acceptance Criteria**:
- [ ] All 4 execution files refactored to variations-only (8-12KB each vs 15-25KB before)
- [ ] Common lifecycle logic consolidated in command-lifecycle.md only
- [ ] Variations applied correctly by orchestrator
- [ ] Execution context reduced by 56-72KB additional savings
- [ ] All commands function identically to before deduplication
- [ ] Lifecycle stages execute consistently across commands
- [ ] No functional regressions
- [ ] Code duplication reduced from 2,600 lines to 0 lines
- [ ] Single source of truth achieved (command-lifecycle.md)
- [ ] Maintainability improved through reduced duplication

### 242. Implement Phase 2 from task 237 implementation plan (split command files into routing and execution)
- **Effort**: 8-12 hours
- **Status**: [PLANNED]
- **Started**: 2025-12-28
- **Researched**: 2025-12-28
- **Completed**: 2025-12-29
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: Task 237 Phase 1 (completed)
- **Research**: [Research Report](.opencode/specs/242_phase2_split_command_files/reports/research-001.md)
- **Plan**: [Implementation Plan](.opencode/specs/242_phase2_split_command_files/plans/implementation-001.md)

**Description**:
Implement Phase 2 from task 237's implementation plan: Split workflow command files (research.md, plan.md, implement.md, revise.md) into lightweight routing files (3-4KB for Stages 1-3) and comprehensive execution files (15-25KB for Stages 4-8). This phase was deferred during task 237 implementation due to requiring orchestrator architectural changes to support loading lightweight routing files during Stages 1-3 and delegating to execution files in Stage 4. Phase 2 would provide 72-104KB context savings (36-52% reduction) if implemented. Note: Phase 2 is marked DEFERRED in task 237 plan due to architectural complexity - this task should evaluate whether the architectural changes are warranted or if alternative approaches exist.

**Research Questions**:
1. Can orchestrator be refactored to support split file loading without breaking existing workflows?
2. What architectural changes are required to support routing vs execution file separation?
3. Are there alternative approaches that achieve similar context savings without file splitting?
4. Is the 72-104KB savings worth the architectural complexity?

**Research Findings** (2025-12-28):
- Phase 2 requires orchestrator architectural changes with MEDIUM-HIGH risk for 72-104KB savings
- Context transition (unloading routing file) is NOT feasible without major refactoring
- Phase 3 (selective TODO.md loading) achieved 40KB savings with ZERO architectural risk (COMPLETED)
- Phase 4 (aggressive deduplication) offers 56-72KB savings with LOWER risk than Phase 2
- **Recommendation: ABANDON Phase 2, pursue Phase 4 instead** (Phase 3 + Phase 4 = 96-112KB total savings, lower risk)

**Acceptance Criteria**:
- [x] Architectural feasibility assessed (routing vs execution file loading)
- [ ] If feasible: Orchestrator refactored to support split file loading
- [ ] If feasible: All 4 commands split into routing (3-4KB) and execution (15-25KB) files
- [ ] If feasible: Routing context reduced by 72-104KB (36-52%)
- [x] If not feasible: Alternative approaches documented and evaluated
- [ ] All commands function identically after changes
- [ ] No functional regressions
- [ ] Backward compatibility maintained

### 240. Systematically investigate and fix persistent workflow command Stage 7 (Postflight) failures causing incomplete status updates
- **Effort**: 56-78 hours (revised from comparative analysis)
- **Status**: [RESEARCHED]
- **Started**: 2025-12-29
- **Researched**: 2025-12-29
- **Completed**: 2025-12-29
- **Priority**: Critical
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research**: [Comparative Analysis Report](.opencode/specs/240_systematically_investigate_and_fix_persistent_workflow_command_stage_7_postflight_failures/reports/research-001.md)
- **Original Plan**: [Implementation Plan](.opencode/specs/240_systematically_investigate_and_fix_persistent_workflow_command_stage_7_postflight_failures/plans/implementation-001.md)

**Description**:
Despite tasks 231, 221, and others attempting to fix Stage 7 (Postflight) execution failures in workflow commands (/research, /plan, /implement, /revise), the issue persists. When running `/research 236`, the research report was created successfully but the TODO.md file was NOT updated to [RESEARCHED] status and the research report was NOT linked (though this appears to have been corrected later, likely manually or through retry). This systematic failure affects ALL workflow commands and indicates a fundamental architectural problem that requires deep investigation and comprehensive refactoring. The problem manifests as: (1) Subagents complete their work and create artifacts successfully, (2) status-sync-manager is supposedly invoked but TODO.md/state.json remain unchanged, (3) No error messages are returned to user, creating silent failures, (4) Manual retries or corrections are required. Root causes to investigate: (A) Stage 7 is being skipped entirely by Claude despite explicit instructions, (B) status-sync-manager is not actually being invoked despite appearing in command specs, (C) status-sync-manager is being invoked but failing silently, (D) Orchestrator validation is insufficient to catch Stage 7 failures, (E) Command lifecycle pattern is fundamentally flawed and needs redesign, (F) Return validation is missing critical checks. This task will conduct systematic root cause analysis and implement a comprehensive, tested solution that ACTUALLY works.

**Research Questions**:
1. Is Stage 7 actually executing or being skipped?
2. Is status-sync-manager actually being invoked or just documented?
3. If invoked, is status-sync-manager succeeding or failing silently?
4. Are orchestrator validation checks actually running?
5. Why do previous "fixes" (tasks 231, 221) not resolve the issue?
6. Is there a fundamental design flaw in the command lifecycle pattern?
7. What evidence exists of Stage 7 execution in actual command runs?
8. Are there race conditions or timing issues?

**Research Findings** (Comparative Analysis):
Comparative analysis of OpenAgents and ProofChecker .opencode systems reveals systematic architectural solution. Root cause: Commands contain Stage 7 logic as XML documentation (narrative), not executable code. Claude skips XML stages because they're guidelines, not requirements. OpenAgents avoids this through agent-driven architecture where commands define "what" (frontmatter with `agent:` field) and agents own "how" (workflow stages as executable code). Key findings: (1) OpenAgents commands 63% smaller (262 vs 712 lines) through frontmatter delegation, (2) OpenAgents context 73% smaller (2,207 vs 8,093 lines) via lazy-loading index, (3) OpenAgents uses session-based temporary context (.tmp/sessions/), (4) OpenAgents orchestrator 69x simpler (15 vs 1,038 lines). Recommended: Adopt OpenAgents architectural patterns rather than band-aid orchestrator validation. Estimated effort: 56-78 hours for 4-phase migration achieving 60-70% systematic improvements.

**Acceptance Criteria**:
- [x] Comprehensive investigation conducted - OpenAgents vs ProofChecker comparative analysis
- [x] Root cause definitively identified - Commands contain workflow as XML documentation, not executable code
- [x] Evidence collected - OpenAgents agents own workflows, ProofChecker commands embed workflows
- [x] Evidence collected - Stage 7 is XML narrative in commands, not enforced by runtime
- [x] Evidence collected - Orchestrator has no stage completion validation
- [x] Alternative architectural approaches evaluated - OpenAgents frontmatter delegation pattern
- [x] Solution designed - 4-phase migration to agent-driven architecture
- [ ] Phase 1 implemented - Context index, frontmatter prototype (12-16 hours)
- [ ] Phase 2 implemented - Migrate all commands to frontmatter pattern (20-30 hours)
- [ ] Phase 3 implemented - Consolidate context files (16-20 hours)
- [ ] Phase 4 implemented - Testing and documentation (8-12 hours)
- [ ] Extensive testing confirms Stage 7 executes 100% reliably (agents own it)
- [ ] Validation confirms TODO.md/state.json update 100% reliably
- [ ] User testing confirms no more silent failures
- [ ] Documentation updated with OpenAgents patterns

**Impact**:
CRITICAL BLOCKER - Without reliable Stage 7 execution, the entire workflow system is fundamentally broken. Tasks appear to complete but tracking files are not updated, requiring manual intervention and creating confusion. Comparative analysis reveals this is symptom of architectural mismatch (command-driven vs agent-driven architecture). OpenAgents patterns provide systematic solution addressing both Stage 7 failures (Task 240) and context bloat (Task 237) through architectural alignment. 4-phase migration delivers 60-70% improvements across command size, context size, and reliability.

**Next Steps**:
1. Create implementation plan for 4-phase migration to OpenAgents patterns
2. Phase 1 prototype: context/index.md + /research frontmatter delegation
3. Validate improvements: context <10% routing, Stage 7 100% reliable
4. If successful, proceed with Phases 2-4 full migration

---

### 237. Investigate and systematically fix context window bloat in workflow commands
- **Effort**: 28-42 hours (revised from research)
- **Status**: [SUPERSEDED]
- **Started**: 2025-12-29
- **Researched**: 2025-12-29
- **Planned**: 2025-12-29
- **Implementing**: 2025-12-28
- **Superseded**: 2025-12-29
- **Phases Completed**: 2 of 4 (Phase 1, Phase 3)
- **Priority**: Critical
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Superseded By**: Task 240 comparative analysis identified architectural solution
- **Research**: [Research Report](.opencode/specs/237_investigate_fix_context_window_bloat_workflow_commands/reports/research-001.md)
- **Architectural Analysis**: [Task 240 Comparative Research](.opencode/specs/240_systematically_investigate_and_fix_persistent_workflow_command_stage_7_postflight_failures/reports/research-001.md)
- **Plan**: [Implementation Plan](.opencode/specs/237_investigate_fix_context_window_bloat_workflow_commands/plans/implementation-001.md)
- **Implementation Summary**: [Phase 1-3 Summary](.opencode/specs/237_investigate_fix_context_window_bloat_workflow_commands/summaries/implementation-summary-20251228-phase3.md)
- **Final Summary**: [Implementation Summary](.opencode/specs/237_investigate_fix_context_window_bloat_workflow_commands/summaries/implementation-summary-final.md)
- **Phases Deferred**: 1 of 4 (Phase 2)
- **Phase 1 Status**: [COMPLETED] - Eliminated 56KB orchestrator context duplication (28% reduction)
- **Phase 2 Status**: [DEFERRED] - Requires orchestrator architectural changes, deferred to future work
- **Phase 3 Status**: [COMPLETED] - Selective TODO.md loading implemented (40KB savings, 91% reduction)
- **Phase 4 Status**: [NOT STARTED] - Aggressive command deduplication (optional)
- **Total Savings**: 96KB (48% reduction from baseline)
- **Artifacts**:
  - [research.md](.opencode/command/research.md) - Task extraction logic implemented
  - [plan.md](.opencode/command/plan.md) - Task extraction logic implemented
  - [implement.md](.opencode/command/implement.md) - Task extraction logic implemented
  - [revise.md](.opencode/command/revise.md) - Task extraction logic implemented

**Description**:
When running workflow commands (/research, /plan, /revise, /implement), the context window jumps to approximately 58% immediately, before any actual work begins. This indicates that context is being loaded too early and too broadly in the orchestrator or command routing stage. The root cause needs to be identified and a systematic solution implemented to protect the context window of both the primary agent (orchestrator) and subagents by loading exactly the context that is needed for each job and nothing more.

**Research Questions**:
1. At what stage is context being loaded (orchestrator routing vs command execution)?
2. Which context files are being loaded and how large are they?
3. Is context being loaded speculatively before knowing which command will execute?
4. Are there duplicated context loads across agent boundaries?
5. What is the minimal context needed for routing decisions vs execution?
6. How can we defer context loading to the appropriate stage?

**Research Findings**:
Root cause identified: Commands load 78-86KB during routing (39-43% of budget) due to premature command file loading, context duplication, and large TODO.md. Recommended 4-phase fix plan reduces routing context to <6% through file splitting, deduplication, and selective loading. Phase 1 quick win: Eliminate orchestrator duplication (2-4 hours, 56KB savings, LOW risk).

**Architectural Analysis** (Task 240):
Comparative analysis of OpenAgents and ProofChecker systems reveals systematic architectural improvements that address context bloat: (1) Frontmatter-based delegation pattern eliminates workflow duplication in commands (commands average 262 lines vs 712 lines, 63% reduction), (2) Lazy-loading context index enables on-demand loading (2,207 total context lines vs 8,093 lines, 73% reduction), (3) Session-based temporary context (.tmp/sessions/) prevents upfront loading of all context, (4) Agent-driven architecture where commands define "what" and agents define "how" eliminates 1,138-line command-lifecycle.md. Recommended: Adopt OpenAgents patterns for systematic 60-70% context reduction rather than incremental Phase 2-4 fixes.

**Acceptance Criteria**:
- [x] Root cause identified - which files/stages load excessive context
- [x] Baseline context usage measured for each workflow command at routing stage
- [x] Baseline context usage measured for each workflow command at execution stage
- [x] Context loading profiled - identify what consumes the 58% before work begins
- [x] Solution designed to defer context loading to appropriate stage
- [x] **Phase 1 Complete**: Orchestrator context duplication eliminated (56KB / 28% reduction)
- [ ] **Phase 2 Deferred**: Command files split into routing and execution (requires orchestrator refactor)
- [x] **Phase 3 Complete**: Selective TODO.md loading implemented (40KB / 91% reduction)
- [ ] **Phase 4 Not Started**: Aggressive command deduplication (56-72KB additional reduction, optional)
- [ ] Orchestrator routing optimized to use <10% context (Phase 1: 28% reduction achieved, need Phases 2-4 for <10% target)
- [ ] Command execution stage loads full context only when needed
- [ ] Language detection remains lightweight (bash grep only, no heavy context)
- [ ] All 4 commands tested: context <15% at routing, appropriate usage at execution
- [ ] Documentation updated with context loading best practices
- [ ] Validation that context budget is protected throughout command lifecycle

**Impact**:
CRITICAL - Protects context windows from bloat across all workflow commands, enabling more efficient task execution and preventing early context exhaustion. Ensures context budget is preserved for actual implementation work rather than routing decisions. This is a systematic issue affecting user experience and command performance.

**Status**: [SUPERSEDED] by Task 240 architectural analysis. Phase 1 (orchestrator deduplication) and Phase 3 (selective TODO loading) achieved 48% reduction (96KB savings). Phase 2 (command file splitting) requires orchestrator refactor but Task 240 comparative analysis recommends adopting OpenAgents frontmatter delegation pattern instead, which eliminates need for split files and achieves 60-70% systematic reduction through architectural alignment.

---

### 238. Find and eliminate all emojis from .opencode system to maintain NO EMOJI standard
- **Effort**: 4-6 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-29
- **Researched**: 2025-12-29
- **Planned**: 2025-12-29
- **Completed**: 2025-12-28
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research**: [Research Report](.opencode/specs/238_find_and_eliminate_all_emojis/reports/research-001.md)
- **Plan**: [Implementation Plan](.opencode/specs/238_find_and_eliminate_all_emojis/plans/implementation-001.md)
- **Implementation Summary**: [Summary](.opencode/specs/238_find_and_eliminate_all_emojis/summaries/implementation-summary-20251228.md)
- **Artifacts**:
  - [researcher.md](.opencode/agent/subagents/researcher.md) - Enhanced with NO EMOJI validation
  - [planner.md](.opencode/agent/subagents/planner.md) - Enhanced with NO EMOJI validation
  - [implementer.md](.opencode/agent/subagents/implementer.md) - Enhanced with NO EMOJI validation
  - [task-executor.md](.opencode/agent/subagents/task-executor.md) - Enhanced with NO EMOJI validation
  - [lean-research-agent.md](.opencode/agent/subagents/lean-research-agent.md) - Enhanced with NO EMOJI validation
  - [lean-implementation-agent.md](.opencode/agent/subagents/lean-implementation-agent.md) - Enhanced with NO EMOJI validation
  - [research.md](.opencode/command/research.md) - Enhanced no_emojis tag with validation
  - [plan.md](.opencode/command/plan.md) - Enhanced no_emojis tag with validation
  - [implement.md](.opencode/command/implement.md) - Enhanced no_emojis tag with validation
  - [revise.md](.opencode/command/revise.md) - Enhanced no_emojis tag with validation
  - [task.md](.opencode/command/task.md) - Enhanced no_emojis tag with validation
  - [review.md](.opencode/command/review.md) - Enhanced no_emojis tag with validation
  - [documentation.md](.opencode/context/common/standards/documentation.md) - Added NO EMOJI Policy section
  - [status-markers.md](.opencode/context/common/system/status-markers.md) - Fixed contradictory emoji examples

**Description**:
Emojis have made their way back into /home/benjamin/Projects/ProofChecker/.opencode/specs/TODO.md and some plans, reports, and summaries (e.g., checkmark emoji in completed tasks like task 234). The repository has a strict NO EMOJI standard that needs to be enforced. Unicode characters are acceptable, but emojis are not. This task requires: (1) Systematically search all .opencode system files for emoji usage (.opencode/specs/TODO.md, all plan files, all report files, all summary files, all command files, all agent files, all context files), (2) Remove all found emojis while preserving meaning (e.g., replace checkmark emojis with text-based markers), (3) Update context files and standards documentation to make the NO EMOJI standard more explicit and easier to enforce, (4) Add guidance to relevant standards files about emoji prevention.

**Acceptance Criteria**:
- [ ] Complete scan of .opencode/specs/TODO.md for emojis
- [ ] Complete scan of .opencode/specs/*/plans/*.md for emojis
- [ ] Complete scan of .opencode/specs/*/reports/*.md for emojis
- [ ] Complete scan of .opencode/specs/*/summaries/*.md for emojis
- [ ] Complete scan of .opencode/command/*.md for emojis
- [ ] Complete scan of .opencode/agent/**/*.md for emojis
- [ ] Complete scan of .opencode/context/**/*.md for emojis
- [ ] All found emojis removed and replaced with appropriate text equivalents
- [ ] status-markers.md updated with explicit NO EMOJI guidance
- [ ] documentation.md standards updated with NO EMOJI enforcement
- [ ] commands.md standards updated with NO EMOJI guidance for output
- [ ] Quality checklist created or updated with emoji validation step
- [ ] Git commit created documenting emoji removal

**Impact**:
Maintains repository consistency and professional standards. Emojis can cause parsing issues, display inconsistently across systems, and violate established documentation standards. Enforcing NO EMOJI standard ensures all documentation is text-based, parseable, and universally displayable.

---

### 241. Optimize NO EMOJI validation to eliminate redundant checks and reduce system overhead
- **Effort**: 4-6 hours
- **Status**: [PLANNED]
- **Started**: 2025-12-28
- **Researched**: 2025-12-28
- **Planned**: 2025-12-28
- **Completed**: 2025-12-28
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: 238
- **Research**: [Research Report](.opencode/specs/241_optimize_no_emoji_validation/reports/research-001.md)
- **Plan**: [Implementation Plan](.opencode/specs/241_optimize_no_emoji_validation/plans/implementation-001.md)
- **Description**: Task 238 implemented comprehensive NO EMOJI enforcement across all .opencode system files (24 files, 88 emoji instances removed). However, this introduced extensive validation checks and warning messages in multiple agent files, command files, and context files which may slow down the opencode system with redundant overhead. Design and implement a more efficient approach that prevents emojis WITHOUT excessive validation overhead. Proposed solution: Create a centralized AGENTS.md file (per https://opencode.ai/docs/rules/) with the NO EMOJIS rule, then remove all redundant mentions and validation checks from individual agent/command/context files. AGENTS.md is automatically loaded by OpenCode into all agent contexts, providing universal rule enforcement without duplication.

**Research Questions**:
1. What is the current overhead cost of distributed NO EMOJI validation? (count of validation blocks, line count, context window usage)
2. How does AGENTS.md work in OpenCode? (automatic loading, precedence, combination with other instructions)
3. What minimal NO EMOJI rule text in AGENTS.md would be sufficient?
4. Which files currently have NO EMOJI validation/warnings that could be removed?
5. Are there any validation checks that MUST remain (e.g., critical output validation)?
6. What is the performance impact of current approach vs. AGENTS.md approach?

**Acceptance Criteria**:
- [ ] Research completed on current NO EMOJI validation overhead (file count, line count, duplication)
- [ ] Research completed on AGENTS.md functionality and best practices
- [ ] AGENTS.md file created with centralized NO EMOJI rule
- [ ] All redundant NO EMOJI validation checks removed from agent files
- [ ] All redundant NO EMOJI validation checks removed from command files  
- [ ] All redundant NO EMOJI validation checks removed from context files
- [ ] Only critical output validation checks retained (if any)
- [ ] Testing confirms NO EMOJI rule still enforced via AGENTS.md
- [ ] Documentation updated to reference AGENTS.md as primary source for NO EMOJI rule
- [ ] Performance comparison documented (context window savings, overhead reduction)
- [ ] Implementation summary created

**Impact**:
Reduces system overhead and context window bloat while maintaining NO EMOJI standard. Eliminates redundant validation checks across ~15-20 files (estimated 200-400 lines of duplicate validation code). AGENTS.md provides cleaner, more maintainable solution with automatic enforcement across all agents. Expected context window savings: 5-10KB per command invocation.

---

### 236. Investigate and fix task standard violations in TODO.md tasks 1-9
- **Effort**: 4 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-29
- **Researched**: 2025-12-29
- **Planned**: 2025-12-29
- **Completed**: 2025-12-28
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research**: [Research Report](.opencode/specs/236_investigate_and_fix_task_standard_violations_in_todomd_tasks_1_9/reports/research-001.md)
- **Plan**: [Implementation Plan](.opencode/specs/236_investigate_and_fix_task_standard_violations_in_todomd_tasks_1_9/plans/implementation-001.md)
- **Implementation Summary**: [Summary](.opencode/specs/236_investigate_and_fix_task_standard_violations_in_todomd_tasks_1_9/summaries/implementation-summary-20251228.md)
- **Artifacts**:
  - [TODO.md](.opencode/specs/TODO.md) - Fixed tasks 1-9 with Language field and bullet formatting
  - [task.md](.opencode/command/task.md) - Enhanced with pre-flight validation
  - [review.md](.opencode/command/review.md) - Enhanced with post-flight validation
  - [tasks.md](.opencode/context/common/standards/tasks.md) - Added troubleshooting documentation

**Description**:
Tasks 1-9 in .opencode/specs/TODO.md do not follow the task standards defined in .opencode/context/common/standards/tasks.md. These tasks are missing required metadata fields including **Language**, and have non-standard formatting (using * instead of - for metadata bullets). Investigation needed to determine: (1) How these tasks were created (which command or agent), (2) Why task standards were not enforced at creation time, (3) Implement a fix to enforce task standards for all task creation mechanisms. The task standards require: Task ID from state.json, Title format "### {ID}. {Title}", Required metadata (Language is mandatory per line 110 quality checklist), Auto-populated defaults for Priority/Language/Effort/etc., Proper formatting with - bullets not *. Tasks 1-9 use format like "*Effort**: ..." and "*Status**: ..." instead of "- **Effort**: ..." and "- **Status**: ..." and are completely missing the **Language** field which is required.

**Acceptance Criteria**:
- [ ] Identify which command/agent created tasks 1-9 (likely /task, /review, or manual entry)
- [ ] Review task creation code in identified command/agent for standards enforcement
- [ ] Implement validation to enforce task standards (required fields, formatting, Language field)
- [ ] Update tasks 1-9 to comply with task standards (add Language field, fix bullet formatting)
- [ ] Add pre-flight validation to /task command to reject non-compliant task creation
- [ ] Add post-flight validation to /review command to ensure created tasks are compliant
- [ ] Test task creation with validation enabled
- [ ] Document task standard enforcement in relevant command files

**Impact**:
Ensures all tasks in TODO.md follow consistent standards, making them easier to parse, track, and process by automation tools. Missing Language field prevents proper routing to Lean-specific agents.

---

### 1. Completeness Proofs
- **Effort**: 70-90 hours
- **Status**: INFRASTRUCTURE ONLY
- **Language**: lean
- **Blocking**: Decidability
- **Dependencies**: Soundness (Complete), Deduction Theorem (Complete)

**Description**: Implement the completeness proof for TM logic using the canonical model method. The infrastructure (types and axiom statements) is present in `Logos/Core/Metalogic/Completeness.lean`.

**Action Items**:
1. Implement `lindenbaum` lemma (extend consistent sets to maximal consistent sets using Zorn's lemma).
2. Prove properties of maximal consistent sets (deductive closure, negation completeness).
3. Construct `canonical_frame` and prove frame properties (nullity, compositionality).
4. Prove `truth_lemma` (correspondence between membership and truth).
5. Prove `weak_completeness` and `strong_completeness`.

**Files**:
- `Logos/Core/Metalogic/Completeness.lean`

---

### 2. Resolve Truth.lean Sorries
- **Effort**: 10-20 hours
- **Status**: PARTIAL
- **Priority**: Medium (Soundness depends on this for full temporal duality)
- **Language**: lean

**Description**: Resolve the 3 remaining `sorry` placeholders in `Logos/Core/Semantics/Truth.lean` related to temporal swap validity. These require handling domain extension for history quantification.

**Action Items**:
1. Resolve `truth_swap_of_valid_at_triple` (implication case).
2. Resolve `truth_swap_of_valid_at_triple` (past case - domain extension).
3. Resolve `truth_swap_of_valid_at_triple` (future case - domain extension).

**Files**:
- `Logos/Core/Semantics/Truth.lean` (lines 697, 776, 798)

---

### 3. Automation Tactics
- **Effort**: 40-60 hours
- **Status**: PARTIAL (4/12 implemented)
- **Language**: lean

**Description**: Implement the remaining planned tactics for TM logic to support easier proof construction.

**Action Items**:
1. Implement `modal_k_tactic`, `temporal_k_tactic`.
2. Implement `modal_4_tactic`, `modal_b_tactic`.
3. Implement `temp_4_tactic`, `temp_a_tactic`.
4. Implement `modal_search`, `temporal_search`.
5. Fix Aesop integration (blocked by Batteries dependency).

**Files**:
- `Logos/Core/Automation/Tactics.lean`

---

### 4. Proof Search
- **Effort**: 40-60 hours
- **Status**: PLANNED
- **Language**: lean

**Description**: Implement automated proof search for TM logic.

**Action Items**:
1. Implement breadth-first proof search.
2. Implement heuristic-guided search.

**Files**:
- `Logos/Core/Automation/ProofSearch.lean`

---

### 5. Decidability
- **Effort**: 40-60 hours
- **Status**: PLANNED
- **Language**: lean

**Description**: Implement decision procedures for TM logic.

**Action Items**:
1. Implement tableau method.
2. Implement satisfiability decision procedure.

**Files**:
- `Logos/Core/Metalogic/Decidability.lean` (to be created)

---

### 6. ModalS5 Limitation
- **Effort**: Low
- **Status**: DOCUMENTED LIMITATION
- **Language**: lean

**Description**: The theorem `diamond_mono_imp` in `ModalS5.lean` is marked with `sorry` because it is not valid as an object-level implication. This is a documented limitation.

**Action Items**:
1. Maintain documentation or find alternative formulation if possible.

**Files**:
- `Logos/Core/Theorems/ModalS5.lean`

---

### 7. Document Creation of Context Files
- **Effort**: 1-2 hours
- **Status**: DONE
- **Priority**: Low
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Files Affected**:
- `Logos/Core/Syntax/Context.lean`
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`

**Description**:
This task was to document the creation and functionality of the `Context.lean` file, which manages proof contexts (premise lists) in the LEAN 4 ProofChecker project. The documentation was added to `IMPLEMENTATION_STATUS.md` to reflect the completion of this core syntax component.

**Acceptance Criteria**:
- [x] `Context.lean` is fully implemented and tested.
- [x] `IMPLEMENTATION_STATUS.md` accurately reflects the status of `Context.lean`.
- [x] The role of `Context.lean` in the syntax package is clearly described.

**Impact**:
Provides clear documentation for a core component of the syntax package, improving project maintainability and onboarding for new contributors.

---

### 8. Refactor `Logos/Core/Syntax/Context.lean`
- **Effort**: 2-4 hours
- **Status**: PLANNED
- **Priority**: Medium
- **Language**: lean
- **Blocking**: Task 9
- **Dependencies**: None

**Files Affected**:
- `Logos/Core/Syntax/Context.lean`
- `LogosTest/Core/Syntax/ContextTest.lean`

**Description**:
Refactor the `Context.lean` file to improve clarity, performance, and alignment with the LEAN 4 style guide. This involves reviewing the existing implementation of proof contexts and applying best practices for data structures and function definitions in LEAN 4.

**Acceptance Criteria**:
- [ ] The `Context.lean` file is refactored for clarity and performance.
- [ ] All related tests in `ContextTest.lean` are updated and pass.
- [ ] The refactoring adheres to the LEAN 4 style guide.
- [ ] The public API of the `Context` module remains backward-compatible or changes are documented.

**Impact**:
Improves the maintainability and readability of a core component of the syntax package.

---

### 9. Update Context References
- **Effort**: 1-2 hours
- **Status**: PLANNED
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: Task 8

**Files Affected**:
- `Logos/Core/ProofSystem/Derivation.lean`
- `Logos/Core/Metalogic/DeductionTheorem.lean`
- Other files that import `Logos.Core.Syntax.Context`

**Description**:
After refactoring `Context.lean`, update all references to the `Context` module throughout the codebase to ensure they are compatible with any changes made to the API. This task involves searching for all usages of `Context` and updating them as necessary.

**Acceptance Criteria**:
- [ ] All references to the `Context` module are updated.
- [ ] The project builds successfully after the updates.
- [ ] All tests pass after the updates.

**Impact**:
Ensures that the entire codebase is compatible with the refactored `Context` module.

---

### 126. Implement bounded_search and matches_axiom in ProofSearch
**Effort**: 3 hours
**Status**: COMPLETED (Started: 2025-12-22, Completed: 2025-12-22)
**Priority**: Medium
**Blocking**: None
**Dependencies**: None
**Artifacts**: [.opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/plans/implementation-001.md](.opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/plans/implementation-001.md), [.opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/reports/research-001.md](.opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/reports/research-001.md), [.opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/summaries/implementation-summary-20251222.md](.opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/summaries/implementation-summary-20251222.md)

**Files Affected**:
- `Logos/Core/Automation/ProofSearch.lean`
- `LogosTest/Core/Automation/ProofSearchTest.lean`

**Description**:
Implement bounded search driver with depth/visit limits, cache/visited threading, and structural axiom matching for all 14 schemas to replace stubs and enable basic proof search execution. Lean intent true; plan ready at [.opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/plans/implementation-001.md](.opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/plans/implementation-001.md).

**Acceptance Criteria**:
- [x] `bounded_search` implemented with depth and visit limits.
- [x] `matches_axiom` implemented with correct structural matching logic (all 14 schemas) and axiom stubs removed.
- [x] `search_with_cache`/basic search runs on sample goals without timeouts.
- [x] Tests cover axiom matching and bounded search termination (unit + integration under Automation).

**Impact**:
Enables the first working path for automated proof search with termination guards.

---

### 132. Prove Lindenbaum maximal consistency lemma in Completeness.lean
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Formalize and prove the Lindenbaum maximal consistency lemma to eliminate the first axiom placeholder.
- **Acceptance Criteria**:
  - [ ] Lindenbaum lemma proven and axiom removed
  - [ ] Proof integrates with existing canonical model scaffolding
  - [ ] Related tests added or updated
- **Impact**: Unlocks subsequent completeness proofs by establishing maximal consistency.

---

### 133. Build canonical model constructors in Completeness.lean
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 132
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Implement canonical model construction helpers and remove associated axiom stubs.
- **Acceptance Criteria**:
  - [ ] Canonical model constructors implemented
  - [ ] Corresponding axiom placeholders removed
  - [ ] Construction type-checks with existing definitions
- **Impact**: Provides the core model for subsequent truth lemma proofs.

---

### 134. Prove truth lemma structure in Completeness.lean
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 133
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Prove the truth lemma for the canonical model, removing the corresponding axiom placeholder.
- **Acceptance Criteria**:
  - [ ] Truth lemma proven and axiom removed
  - [ ] Proof integrates with canonical model components
  - [ ] Tests (or placeholders) updated to exercise lemma
- **Impact**: Establishes the key bridge between syntax and semantics for completeness.

---

### 135. Remove provable_iff_valid sorry in Completeness.lean
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 132, 133, 134
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Complete the `provable_iff_valid` theorem using the proven canonical model and truth lemma to eliminate the remaining sorry.
- **Acceptance Criteria**:
  - [ ] `provable_iff_valid` fully proven
  - [ ] No remaining axiom or sorry placeholders in Completeness.lean
  - [ ] Completeness tests added or updated
- **Impact**: Delivers full completeness, enabling derivability from validity.

### Decidability

---

### 136. Design Decidability.lean architecture and signatures
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Logos/Core/Metalogic/Decidability.lean
- **Description**: Define the module structure, main theorems, and function signatures for decidability (tableau and satisfiability checks).
- **Acceptance Criteria**:
  - [ ] Module skeleton with signatures for tableau and decision procedures
  - [ ] Documentation comments outline intended algorithms
  - [ ] No build warnings from new declarations
- **Impact**: Establishes a foundation for future decidability proofs and implementations.

---

### 137. Implement tableau core rules in Decidability.lean
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 136
- **Files Affected**:
  - Logos/Core/Metalogic/Decidability.lean
- **Description**: Implement the core tableau expansion rules and supporting helpers for validity checking.
- **Acceptance Criteria**:
  - [ ] Tableau expansion rules implemented and type-checking
  - [ ] Basic examples compile demonstrating rule application
  - [ ] No placeholder axioms for these rules remain
- **Impact**: Provides executable building blocks for the decision procedure.

---

### 138. Implement satisfiability and validity decision procedure tests
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 136, 137
- **Files Affected**:
  - Logos/Core/Metalogic/Decidability.lean
  - LogosTest/Metalogic/DecidabilityTest.lean (new or updated)
- **Description**: Wire the tableau components into a decision procedure and add tests covering satisfiable and unsatisfiable cases.
- **Acceptance Criteria**:
  - [ ] Decision procedure implemented and compiles
  - [ ] Tests cover satisfiable and unsatisfiable scenarios
  - [ ] No remaining placeholder axioms in the decision procedure path
- **Impact**: Delivers an initial, test-backed decision procedure for TM logic.

### Layer Extensions (Future Planning)

---

### 139. Draft Layer 1 counterfactual operator plan
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Documentation/UserGuide/ARCHITECTURE.md
  - Documentation/UserGuide/METHODOLOGY.md
- **Description**: Draft a plan for Layer 1 counterfactual operators, defining `box_c` and `diamond_m` semantics and integration points.
- **Acceptance Criteria**:
  - [ ] Draft plan describing operators, semantics, and required modules
  - [ ] Architecture updated with Layer 1 scope and assumptions
  - [ ] Clear follow-on tasks identified
- **Impact**: Provides roadmap for counterfactual extensions post Layer 0.

---

### 140. Draft Layer 2 epistemic operator plan
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Documentation/UserGuide/ARCHITECTURE.md
  - Documentation/UserGuide/METHODOLOGY.md
- **Description**: Draft a plan for Layer 2 epistemic operators (`K`, `B`) including semantics and proof obligations.
- **Acceptance Criteria**:
  - [ ] Draft plan outlines semantics, target theorems, and module impacts
  - [ ] Architecture updated with Layer 2 scope and assumptions
  - [ ] Follow-on tasks identified
- **Impact**: Establishes roadmap for epistemic extensions.

---

### 141. Draft Layer 3 normative operator plan
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Documentation/UserGuide/ARCHITECTURE.md
  - Documentation/UserGuide/METHODOLOGY.md
- **Description**: Draft a plan for Layer 3 normative operators (`O`, `P`) including semantics and proof obligations.
- **Acceptance Criteria**:
  - [ ] Draft plan outlines semantics, target theorems, and module impacts
  - [ ] Architecture updated with Layer 3 scope and assumptions
  - [ ] Follow-on tasks identified
- **Impact**: Provides a roadmap for normative logic extensions.

---

### 175. Establish CI/CD pipeline with automated testing and linting
- **Effort**: 13 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .github/workflows/ci.yml (new)
  - .github/workflows/lint.yml (new)
  - .github/workflows/coverage.yml (new)
  - Documentation/Development/CI_CD_PROCESS.md (new)
- **Description**: Create GitHub Actions workflows for continuous integration and deployment. Currently all tests run manually. CI/CD pipeline should run tests, linting, style checks, coverage reporting, and documentation build checks automatically on every pull request and commit.
- **Acceptance Criteria**:
  - [ ] GitHub Actions workflow for tests created and passing
  - [ ] Linting and style checks integrated into CI
  - [ ] Coverage reporting integrated into CI
  - [ ] Documentation build checks integrated into CI
  - [ ] CI runs on all pull requests and commits to main
  - [ ] CI failure blocks merge
  - [ ] CI/CD process documented in CI_CD_PROCESS.md
- **Impact**: Ensures code quality automatically, prevents regressions, and enables confident merging of pull requests. Essential for maintaining production-ready code.

---

### 176. Enhance proof search with domain-specific heuristics and caching
- **Effort**: 18 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Logos/Core/Automation/ProofSearch.lean
  - Logos/Core/Automation/ProofSearchHeuristics.lean (new)
  - Logos/Core/Automation/ProofCache.lean (new)
  - LogosTest/Core/Automation/ProofSearchHeuristicsTest.lean (new)
- **Description**: Enhance ProofSearch.lean with modal-specific and temporal-specific heuristics, proof caching with hash-consing, and success pattern learning. Current heuristics are basic (Task 127 complete). Domain-specific optimizations will significantly improve proof search effectiveness.
- **Acceptance Criteria**:
  - [ ] Modal-specific heuristics implemented (prefer S5 axioms for modal goals)
  - [ ] Temporal-specific heuristics implemented (prefer temporal axioms for temporal goals)
  - [ ] Proof caching with hash-consing implemented
  - [ ] Success pattern learning implemented
  - [ ] Heuristics tested and benchmarked
  - [ ] Documentation for heuristic tuning added
- **Impact**: Improves automation effectiveness by tailoring proof search to the structure of modal and temporal problems, reducing search time and increasing success rate.

---

### 178. Complete advanced tutorial sections with hands-on exercises
- **Effort**: 13 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: 172
- **Files Affected**:
  - Documentation/UserGuide/TUTORIAL.md
  - Documentation/UserGuide/TUTORIAL_EXERCISES.md (new)
  - Documentation/UserGuide/TROUBLESHOOTING.md (new)
- **Description**: Enhance TUTORIAL.md with advanced sections on proof search automation, custom tactic development, and metalogic. Add hands-on exercises with solutions and a troubleshooting guide. Current tutorial is basic and lacks advanced topics.
- **Acceptance Criteria**:
  - [ ] Advanced tutorial section on proof search and automation added
  - [ ] Advanced tutorial section on custom tactic development added
  - [ ] Advanced tutorial section on metalogic and soundness added
  - [ ] Hands-on exercises with solutions added
  - [ ] Troubleshooting guide created
  - [ ] Tutorial tested with new users for clarity
- **Impact**: Improves onboarding by providing comprehensive learning path from basics to advanced topics with practical exercises.

---

### 179. Implement performance benchmarks for proof search and derivation
- **Effort**: 13 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - LogosBench/ (new directory)
  - LogosBench/ProofSearchBench.lean (new)
  - LogosBench/DerivationBench.lean (new)
  - LogosBench/SemanticEvaluationBench.lean (new)
  - Documentation/Development/PERFORMANCE_TARGETS.md (new)
- **Description**: Create performance benchmark suite for proof search, derivation, and semantic evaluation. Add performance regression testing to CI. Currently no benchmarks exist and performance could regress unnoticed. Document performance targets.
- **Acceptance Criteria**:
  - [ ] Benchmark suite for proof search created
  - [ ] Benchmark suite for derivation created
  - [ ] Benchmark suite for semantic evaluation created
  - [ ] Performance regression testing added to CI
  - [ ] Performance targets documented
  - [ ] Baseline performance measurements recorded
- **Impact**: Ensures performance doesn't regress and provides data for optimization efforts. Critical for maintaining usable proof search times.

---

### 180. Add test coverage metrics and reporting
- **Effort**: 9 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: 175
- **Files Affected**:
  - .github/workflows/coverage.yml
  - scripts/GenerateCoverage.lean (new)
  - Documentation/Development/TEST_COVERAGE.md (new)
- **Description**: Integrate test coverage measurement tool, generate coverage reports, add coverage reporting to CI, and create coverage improvement plan. TESTING_STANDARDS.md defines target of at least 85 percent but no measurement exists.
- **Acceptance Criteria**:
  - [ ] Coverage measurement tool integrated
  - [ ] Coverage reports generated automatically
  - [ ] Coverage reporting integrated into CI
  - [ ] Coverage improvement plan created
  - [ ] Coverage measurement process documented
  - [ ] Current coverage baseline established
- **Impact**: Enables data-driven test improvement by identifying untested code paths and tracking coverage over time.

---

### 189. Add --divide flag to /research command for topic subdivision
- **Effort**: 3 hours
- **Status**: [IN PROGRESS]
- **Started**: 2025-12-26
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research Artifacts**:
  - Main Report: [.opencode/specs/189_research_divide_flag/reports/research-001.md]
  - Summary: [.opencode/specs/189_research_divide_flag/summaries/research-summary.md]
- **Files Affected**:
  - .opencode/command/research.md
  - .opencode/agent/subagents/researcher.md
  - .opencode/agent/subagents/specialists/web-research-specialist.md
- **Description**: Add a --divide flag to the /research command that changes its behavior. Without --divide, /research should create individual research reports only (no research summary). With --divide, /research should invoke a subagent to divide the research topic into natural subtopics, pass each subtopic to further research subagents to research and create individual reports, then compile the references and brief summaries into a research summary report. The research summary should contain only references to the individual reports and their brief summaries, not duplicate the full content.
- **Acceptance Criteria**:
  - [ ] --divide flag added to /research command documentation and input parsing
  - [ ] Without --divide: /research creates only individual research reports (reports/research-NNN.md), no summary
  - [ ] With --divide: /research divides topic into subtopics using a subagent
  - [ ] With --divide: Each subtopic is researched by a separate subagent, creating individual reports
  - [ ] With --divide: Research summary report (summaries/research-summary.md) is created compiling references and brief summaries
  - [ ] Research summary contains only references and brief summaries, not full content
  - [ ] All behavior follows lazy directory creation (create summaries/ only when writing summary)
  - [ ] Status markers and state sync work correctly for both modes
  - [ ] Documentation updated to explain --divide flag behavior
- **Impact**: Provides more flexible research workflow - simple research creates focused reports without overhead of summary compilation, while complex research can be divided into manageable subtopics with a summary overview.

---

### 203. Add --complex flag to /research for subtopic subdivision with summary
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/command/research.md
  - .opencode/agent/subagents/researcher.md
  - .opencode/agent/subagents/lean-research-agent.md
- **Description**: Enhance the /research command to support a --complex flag that changes its behavior for handling complex research topics. Without --complex flag: /research creates a single research report (reports/research-001.md) with no summary - this is the current default behavior. With --complex flag: /research should (1) Divide the topic into 1-5 appropriate subtopics using intelligent analysis, (2) Spawn research subagents to complete each subtopic in parallel, creating individual research reports (reports/research-001.md, reports/research-002.md, etc.), (3) Each subagent returns only its report path and brief summary (not full content) to the primary agent, (4) Primary agent compiles all report paths and brief summaries into a research summary report (summaries/research-summary.md), (5) Update TODO.md and state.json with all report references and mark task as [RESEARCHED]. The --complex flag enables comprehensive research on large topics while protecting context windows through summarization.
- **Acceptance Criteria**:
  - [ ] --complex flag added to /research command argument parsing
  - [ ] Without --complex: /research creates single report, no summary (current behavior preserved)
  - [ ] With --complex: Topic intelligently divided into 1-5 subtopics
  - [ ] With --complex: Separate research subagents spawned for each subtopic
  - [ ] With --complex: Each subtopic generates individual report (reports/research-NNN.md)
  - [ ] With --complex: Subagents return only report path + brief summary (not full content)
  - [ ] With --complex: Primary agent creates research summary (summaries/research-summary.md) compiling all references
  - [ ] Research summary contains only paths and brief summaries, not duplicated full content
  - [ ] Lazy directory creation followed (summaries/ created only when writing summary)
  - [ ] TODO.md updated with all report references and [RESEARCHED] status for both modes
  - [ ] state.json updated correctly for both modes
  - [ ] Documentation explains --complex flag behavior and use cases
- **Impact**: Enables comprehensive research on complex topics by dividing them into manageable subtopics while protecting the primary agent's context window through summarization. Provides flexibility - simple topics get focused single reports, complex topics get thorough multi-report coverage with summary overview.

---

### 205. Implement Lean tool usage verification and monitoring system
- **Effort**: 6-8 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/command/research.md
  - .opencode/command/implement.md
  - .opencode/agent/subagents/lean-research-agent.md
  - .opencode/agent/subagents/lean-implementation-agent.md
  - .opencode/context/common/standards/lean-tool-verification.md (new)
  - .opencode/specs/monitoring/ (new directory structure)
- **Description**: Design and implement a comprehensive monitoring and verification system to detect and validate that Lean-specific tools (lean-lsp-mcp, Loogle, LeanExplore, LeanSearch) are being correctly used by the appropriate commands and agents when processing Lean tasks. The system should provide visibility into tool usage patterns, detect routing errors, track tool availability issues, and identify opportunities for improvement. This includes creating verification methods, logging standards, monitoring dashboards, and automated health checks to ensure the system is working optimally.
- **Acceptance Criteria**:
  - [ ] Verification method identified for detecting lean-lsp-mcp usage in /implement command for Lean tasks
  - [ ] Verification method identified for detecting Loogle usage in /research command for Lean tasks
  - [ ] Automated tool availability checks implemented (binary existence, process health, API connectivity)
  - [ ] Tool usage logging standardized in lean-research-agent and lean-implementation-agent return formats
  - [ ] Monitoring dashboard or report created showing tool usage metrics per command execution
  - [ ] Health check command or script created to verify routing is working correctly
  - [ ] Documentation created explaining verification methods and monitoring approach
  - [ ] Error detection implemented for cases where tools should be used but aren't (routing failures)
  - [ ] Recommendations provided for system improvements based on monitoring data
  - [ ] All verification methods tested with real command executions on Lean tasks
- **Impact**: Provides visibility and confidence that the Lean tool integration is working correctly, enables early detection of routing or configuration issues, and identifies opportunities to improve the system's effectiveness with Lean-specific research and implementation workflows.

---

### 218. Fix lean-lsp-mcp integration and opencode module import errors
**Effort**: 0.75 hours
**Status**: [RESEARCHED]
**Started**: 2025-12-28
**Researched**: 2025-12-28
**Priority**: High
**Blocking**: None
**Dependencies**: 212 (completed)
**Language**: python
**Research Artifacts**:
  - Main Report: [.opencode/specs/218_fix_lean_lsp_mcp_integration/reports/research-002.md]
**Research Findings** (2025-12-28): CRITICAL DISCOVERY: OpenCode has native MCP support via opencode.json configuration, NOT .mcp.json. Task 212's custom Python MCP client approach is architecturally incompatible - OpenCode agents use natural language tool instructions, not Python imports. The ModuleNotFoundError is a symptom of wrong architectural approach, not missing __init__.py files. Solution requires complete pivot from Python-based integration to configuration-based integration: (1) Create opencode.json with lean-lsp-mcp server configuration, (2) Update lean-implementation-agent.md to use natural language MCP tool instructions instead of Python imports, (3) Remove custom MCP client from task 212 (architecturally incompatible). Proper approach enables 15+ lean-lsp-mcp tools (compile, check-proof, search, etc.) via native OpenCode MCP bridge. Previous plan obsolete - new configuration-based approach estimated 1-2 hours.

**Files Affected**:
- opencode.json (new, MCP server configuration)
- .opencode/agent/subagents/lean-implementation-agent.md (update to use MCP tool instructions)
- .opencode/agent/subagents/lean-research-agent.md (update to use MCP tool instructions)
- Documentation/UserGuide/MCP_INTEGRATION.md (new, user guide)
- .opencode/tool/mcp/client.py (mark deprecated, incompatible with OpenCode architecture)

**Description**:
Research revealed that OpenCode has native MCP (Model Context Protocol) support that makes task 212's custom Python MCP client unnecessary and architecturally incompatible. OpenCode agents interact with MCP servers through natural language tool instructions, not Python imports. The proper integration approach uses opencode.json configuration to register MCP servers, making their tools automatically available to agents. This enables lean-implementation-agent to use lean-lsp-mcp's 15+ tools for real-time compilation checking, proof state inspection, and theorem search during Lean proof implementation.

**Acceptance Criteria**:
- [ ] opencode.json created with lean-lsp-mcp server configuration
- [ ] lean-implementation-agent.md updated with MCP tool usage instructions
- [ ] lean-research-agent.md updated with MCP tool usage instructions  
- [ ] MCP integration guide created in user documentation
- [ ] Test Lean task implementation successfully uses lean-lsp-mcp tools
- [ ] No Python import errors (using configuration-based approach)
- [ ] Selective tool enablement reduces context window usage

**Impact**:
CRITICAL ARCHITECTURAL CORRECTION: Pivots from incompatible custom Python client to proper OpenCode-native MCP integration. Enables lean-lsp-mcp tools for real-time Lean compilation checking, proof verification, and theorem search. Reduces context window usage by 2000-5000 tokens through selective per-agent tool enablement. Establishes foundation for additional MCP servers (Context7, Grep) to enhance Lean development workflow.

---
