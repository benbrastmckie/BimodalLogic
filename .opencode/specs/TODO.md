# TODO

**Last Updated:** 2025-12-29T22:30:00Z


---

### 257. Completeness Proofs
- **Effort**: 70-90 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
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

**Acceptance Criteria**:
- [ ] Lindenbaum lemma implemented
- [ ] Maximal consistent set properties proven
- [ ] Canonical frame constructed with frame properties
- [ ] Truth lemma proven
- [ ] Weak and strong completeness proven

**Impact**: Completes the metalogic foundation for TM logic by proving completeness, enabling derivability from validity.

---

### 258. Resolve Truth.lean Sorries
- **Effort**: 10-20 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: Resolve the 3 remaining `sorry` placeholders in `Logos/Core/Semantics/Truth.lean` related to temporal swap validity. These require handling domain extension for history quantification.

**Action Items**:
1. Resolve `truth_swap_of_valid_at_triple` (implication case).
2. Resolve `truth_swap_of_valid_at_triple` (past case - domain extension).
3. Resolve `truth_swap_of_valid_at_triple` (future case - domain extension).

**Files**:
- `Logos/Core/Semantics/Truth.lean` (lines 697, 776, 798)

**Acceptance Criteria**:
- [ ] Implication case resolved
- [ ] Past case with domain extension resolved
- [ ] Future case with domain extension resolved
- [ ] All tests pass
- [ ] SORRY_REGISTRY.md updated

**Impact**: Completes temporal duality support in Truth.lean, enabling full soundness proofs for temporal operators.

---

### 259. Automation Tactics
- **Effort**: 40-60 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: Implement the remaining planned tactics for TM logic to support easier proof construction. Currently 4/12 tactics are implemented.

**Action Items**:
1. Implement `modal_k_tactic`, `temporal_k_tactic`.
2. Implement `modal_4_tactic`, `modal_b_tactic`.
3. Implement `temp_4_tactic`, `temp_a_tactic`.
4. Implement `modal_search`, `temporal_search`.
5. Fix Aesop integration (blocked by Batteries dependency).

**Files**:
- `Logos/Core/Automation/Tactics.lean`

**Acceptance Criteria**:
- [ ] All 8 remaining tactics implemented
- [ ] Aesop integration fixed
- [ ] Tests added for new tactics
- [ ] TACTIC_REGISTRY.md updated
- [ ] Documentation updated

**Impact**: Significantly improves proof automation capabilities for TM logic, making proof construction easier and more efficient.

---

### 260. Proof Search
- **Effort**: 40-60 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: Implement automated proof search for TM logic.

**Action Items**:
1. Implement breadth-first proof search.
2. Implement heuristic-guided search.

**Files**:
- `Logos/Core/Automation/ProofSearch.lean`

**Acceptance Criteria**:
- [ ] Breadth-first proof search implemented
- [ ] Heuristic-guided search implemented
- [ ] Tests added for proof search
- [ ] Performance benchmarks created
- [ ] Documentation updated

**Impact**: Enables automated proof discovery for TM logic, reducing manual proof construction effort.

---

### 261. Decidability
- **Effort**: 40-60 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: Implement decision procedures for TM logic.

**Action Items**:
1. Implement tableau method.
2. Implement satisfiability decision procedure.

**Files**:
- `Logos/Core/Metalogic/Decidability.lean` (to be created)

**Acceptance Criteria**:
- [ ] Tableau method implemented
- [ ] Satisfiability decision procedure implemented
- [ ] Tests added for decision procedures
- [ ] Documentation updated

**Impact**: Provides algorithmic decision procedures for TM logic validity and satisfiability.

---

### 262. ModalS5 Limitation
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: The theorem `diamond_mono_imp` in `ModalS5.lean` is marked with `sorry` because it is not valid as an object-level implication. This is a documented limitation.

**Action Items**:
1. Maintain documentation or find alternative formulation if possible.

**Files**:
- `Logos/Core/Theorems/ModalS5.lean`

**Acceptance Criteria**:
- [ ] Documentation maintained or alternative formulation found
- [ ] SORRY_REGISTRY.md updated with justification

**Impact**: Resolves documented limitation in ModalS5 theorems.

---

### 263. Refactor Context.lean
- **Effort**: 2-4 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: Task 264
- **Dependencies**: None

**Description**: Refactor the `Context.lean` file to improve clarity, performance, and alignment with the LEAN 4 style guide. This involves reviewing the existing implementation of proof contexts and applying best practices for data structures and function definitions in LEAN 4.

**Files Affected**:
- `Logos/Core/Syntax/Context.lean`
- `LogosTest/Core/Syntax/ContextTest.lean`

**Acceptance Criteria**:
- [ ] The `Context.lean` file is refactored for clarity and performance.
- [ ] All related tests in `ContextTest.lean` are updated and pass.
- [ ] The refactoring adheres to the LEAN 4 style guide.
- [ ] The public API of the `Context` module remains backward-compatible or changes are documented.

**Impact**: Improves the maintainability and readability of a core component of the syntax package.

---

### 264. Update Context References
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: Task 263

**Files Affected**:
- `Logos/Core/ProofSystem/Derivation.lean`
- `Logos/Core/Metalogic/DeductionTheorem.lean`
- Other files that import `Logos.Core.Syntax.Context`

**Description**: After refactoring `Context.lean`, update all references to the `Context` module throughout the codebase to ensure they are compatible with any changes made to the API. This task involves searching for all usages of `Context` and updating them as necessary.

**Acceptance Criteria**:
- [ ] All references to the `Context` module are updated.
- [ ] The project builds successfully after the updates.
- [ ] All tests pass after the updates.

**Impact**: Ensures that the entire codebase is compatible with the refactored `Context` module.

---


- **Total Tasks:** 61
- **Completed:** 8
- **High Priority:** 13
- **Medium Priority:** 10
- **Low Priority:** 10

---

## High Priority

### ✓ 254. Refactor /research command to directly invoke agents and properly manage task status and state updates
- **Effort**: 6-8 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-29
- **Completed**: 2025-12-29
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research**: [task-254-research-command-refactor.md](.opencode/research/task-254-research-command-refactor.md)
- **Plan**: [Implementation Plan](.opencode/specs/254_research_command_refactor/plans/implementation-001.md)
- **Implementation Summary**: [Summary](.opencode/specs/254_research_command_refactor/summaries/implementation-summary-20251229.md)

**Description**:
The /research command is currently experiencing systematic failures where it stops after routing stages 1-3 and does not proceed to execution stages 4-8. The command does not update TODO.md status to [RESEARCHING] at start or [RESEARCHED] at completion, does not update state.json, does not link research reports back to TODO.md, and does not create git commits. The current implementation is split between research.md (routing) and research-routing.md (redundant), with research.md.backup also present. This task involves creating a single, unified /research command that directly invokes the appropriate research agent (researcher or lean-research-agent), properly manages all status transitions, state updates, and git commits following the patterns established in the OpenAgents migration (tasks 244-247).

**Research Findings**:
Root cause identified: Workflow defined as XML documentation rather than executable code, causing stages 4-8 to be skipped. Solution: Implement frontmatter delegation pattern from Task 240 OpenAgents migration. Single research.md (150-200 lines) delegates to researcher.md agent owning complete workflow with status-sync-manager and git-workflow-manager integration. See research report for detailed implementation guidance.

**Tasks**:
- Remove redundant/backup files (research.md.backup, research-routing.md if not needed)
- Create unified /research command following frontmatter delegation pattern from tasks 244-247
- Implement proper argument parsing (task_number, optional prompt, --divide flag)
- Use state.json for language field lookup instead of parsing TODO.md
- Implement status update to [RESEARCHING] at command start (before agent invocation)
- Directly invoke appropriate research agent based on language (lean → lean-research-agent, else → researcher)
- Implement status update to [RESEARCHED] at command completion (after agent returns)
- Update state.json with status transitions following state-management.md schema
- Link research report path back to TODO.md task entry
- Update project state.json with artifacts array per state-schema.md
- Create git commit after successful research completion
- Follow artifact-management.md for lazy directory creation (no pre-creation)
- Ensure proper error handling and recovery for partial completions
- Validate against delegation.md return format requirements
- Test with both Lean and markdown tasks to verify routing

**Acceptance Criteria**:
- [ ] Single /research command file with frontmatter delegation (research.md)
- [ ] research.md.backup and research-routing.md removed (if redundant)
- [ ] Command parses arguments correctly (task_number, prompt, --divide)
- [ ] Language field read from state.json (not TODO.md parsing)
- [ ] TODO.md status updates to [RESEARCHING] before agent invocation
- [ ] Appropriate research agent invoked based on language field
- [ ] TODO.md status updates to [RESEARCHED] after successful completion
- [ ] state.json updated with proper status transitions
- [ ] Research report path linked in TODO.md task entry
- [ ] project state.json artifacts array updated
- [ ] git commit created after successful research
- [ ] Lazy directory creation follows artifact-management.md
- [ ] Error handling includes recovery instructions
- [ ] Return format validates against delegation.md schema
- [ ] Tested successfully with both Lean and markdown tasks

**Impact**: Fixes systematic research workflow failures, ensures proper task tracking and state management, provides reliable research command following OpenAgents migration patterns, eliminates redundant/backup files for cleaner codebase.

---

### ✓ 253. Improve /todo command to use git commits instead of backups and fix divider stacking
- **Effort**: 4-6 hours
- **Status**: [COMPLETED]
- **Started**: 2025-12-29
- **Researched**: 2025-12-29
- **Planned**: 2025-12-29
- **Completed**: 2025-12-29
- **Priority**: High
- **Language**: python
- **Blocking**: None
- **Dependencies**: None
- **Research**: [Research Report](.opencode/specs/253_improve_todo_command/reports/research-001.md)
- **Plan**: [Implementation Plan](.opencode/specs/253_improve_todo_command/plans/implementation-001.md)
- **Implementation Summary**: [Summary](.opencode/specs/253_improve_todo_command/summaries/implementation-summary-20251229.md)

**Description**:
The /todo command currently creates backups before cleanup operations and generates a Python script from scratch each time. This approach should be replaced with a more robust workflow using git commits (one before cleanup, one after cleanup) and a dedicated, reusable Python script that aligns with the TODO.md file standards defined in .opencode/specs/TODO.md. Additionally, the script currently leaves multiple stacked `---` dividers separated by empty lines, which should be fixed to ensure only one divider appears between tasks and no dividers between headers or between headers and tasks.

**Tasks**:
- Create a dedicated Python script (.opencode/scripts/todo_cleanup.py) that follows TODO.md file standards
- Ensure script properly parses TODO.md format (task headers, metadata fields, dividers)
- Fix divider handling to avoid stacked `---` dividers with empty lines between them
- Implement proper divider logic: one divider between tasks, no divider between headers or headers and tasks
- Update /todo command to use git commits instead of backup files
- Add pre-cleanup git commit with descriptive message
- Add post-cleanup git commit with descriptive message
- Remove backup file creation logic from /todo command
- Test script with current TODO.md file to verify correct behavior
- Document script usage and alignment with TODO.md standards

**Acceptance Criteria**:
- [x] Dedicated Python script created at .opencode/scripts/todo_cleanup.py
- [x] Script correctly parses TODO.md file format per .opencode/specs/TODO.md standards
- [x] Script handles dividers correctly: one divider between tasks, no dividers between headers or headers and tasks
- [x] No stacked `---` dividers with empty lines between them in output
- [x] /todo command uses git commit before cleanup operation
- [x] /todo command uses git commit after cleanup operation
- [x] /todo command no longer creates backup files
- [x] Script is reusable (no need to regenerate each time)
- [x] Script validated against .opencode/specs/TODO.md standards
- [x] Documentation updated with new workflow and script usage

**Impact**: Improves /todo command reliability by using git for version control instead of backups, provides a maintainable dedicated script that aligns with TODO.md standards, and fixes formatting issues with stacked dividers for cleaner output.

---

### 255. Improve opencode system following the improvement plan
- **Effort**: 8-12 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: general
- **Blocking**: None
- **Dependencies**: None
- **Plan**: [Implementation Plan](.opencode/specs/255_improve_opencode_system/plans/implementation-001.md)
- **Summary**: [Implementation Summary](.opencode/specs/255_improve_opencode_system/summaries/implementation-summary-20251229.md)
- **Completed**: 2025-12-29
- **Git Commits**: 
  - Phase 1: `f6bd085` - Context directory reorganization
  - Phase 3: `c2be177` - Command file simplification
  - Phase 4: `fb75110` - Documentation updates

**Description**:
Restructure the ProofChecker .opencode system to implement clean `core/` and `project/` context organization, streamlined orchestrator (smart coordinator pattern), thin command files (declarative workflow setup), language-based routing via orchestrator, and clear validation strategy. The improvement plan is a comprehensive 4-phase migration (8-12 hours total) that reorganizes context directories, simplifies the orchestrator, reduces command file complexity, and updates documentation. This follows the architectural patterns identified in the OpenAgents migration research.

**Tasks**:
- Phase 1: Context Directory Reorganization (2-3 hours)
  - Create new core/ directory structure (standards/, workflows/, system/, templates/)
  - Create new core files (context-loading-strategy.md, validation-strategy.md, delegation-guide.md, status-transitions.md, subagent-return-format.md)
  - Move existing files from system/ to core/system/
  - Update orchestrator and command context references
  - Update context README.md
- Phase 2: Orchestrator Streamlining (3-4 hours)
  - Backup current orchestrator
  - Update orchestrator frontmatter (version 5.0, new context paths)
  - Replace workflow execution section (reduce to 7 stages)
  - Update routing intelligence section
  - Update notes section
- Phase 3: Command File Simplification (2-3 hours)
  - Create command template
  - Simplify /plan, /research, /implement commands (~120-140 lines each)
  - Simplify /revise, /review, /errors commands
  - Add routing frontmatter to all commands
- Phase 4: Documentation Updates (1-2 hours)
  - Update ARCHITECTURE.md with smart coordinator pattern
  - Update README.md with new improvements
  - Create orchestrator-design.md
  - Update QUICK-START.md with command flow

**Acceptance Criteria**:
- [ ] Phase 1: context/core/ exists with 4 subdirectories, all files moved, references updated
- [ ] Phase 2: Orchestrator is ~450 lines (down from 592), 7 stages, no syntax errors
- [ ] Phase 3: Commands are 100-150 lines, all have routing frontmatter, use workflow_setup pattern
- [ ] Phase 4: Documentation updated, orchestrator-design.md created, no broken links
- [ ] .opencode/specs/ unchanged (TODO.md, state.json, project directories preserved)
- [ ] System functions correctly after migration
- [ ] All tasks and projects preserved

**Impact**: Implements clean architectural patterns from OpenAgents migration research, reduces context window bloat through better organization, simplifies orchestrator and command files for maintainability, and provides clear separation between core (reusable) and project (ProofChecker-specific) context.

---

### 256. Add /meta command from OpenAgents with system-builder subagents
- **Effort**: 14 hours
- **Status**: [PLANNED]
- **Research Started**: 2025-12-29
- **Research Completed**: 2025-12-29
- **Research Report**: .opencode/specs/256_add_meta_command_from_openagents_with_system_builder_subagents/reports/research-001.md
- **Plan Created**: 2025-12-29
- **Implementation Plan**: .opencode/specs/256_add_meta_command_from_openagents_with_system_builder_subagents/plans/implementation-001.md
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**:
Import and adapt the /meta command from the OpenAgents project (/home/benjamin/Projects/OpenAgents/.opencode/command/meta.md) to enable interactive system building capabilities in ProofChecker. The system-builder agents already exist in .opencode/agent/subagents/system-builder/ but should be renamed to .opencode/agent/subagents/meta/ for consistency. Compare with the backup version (.opencode.backup.20251225_173342/command/meta.md) but maintain the new high standards from the current refactor (frontmatter delegation, context efficiency, XML optimization). Update context files to support the /meta command and its subagents without bloating context windows.

**Tasks**:
- Review OpenAgents /meta command implementation (/home/benjamin/Projects/OpenAgents/.opencode/command/meta.md)
- Review backup /meta command (.opencode.backup.20251225_173342/command/meta.md) for comparison
- Rename .opencode/agent/subagents/system-builder/ to .opencode/agent/subagents/meta/
- Adapt /meta command to ProofChecker standards (frontmatter delegation pattern from tasks 244-247)
- Update meta command frontmatter with proper agent routing, context_level, and metadata
- Ensure meta subagents (agent-generator, command-creator, context-organizer, domain-analyzer, workflow-designer) follow current XML optimization patterns
- Create or update context files to support /meta command without bloating context:
  - Context files should be focused and modular (50-200 lines each)
  - Use lazy loading patterns from routing-guide.md
  - Avoid duplicating information already in other context files
- Update meta command to use state.json for project tracking
- Implement proper git commit workflow for generated files (use git-workflow-manager)
- Add validation for generated agent/command files (frontmatter schema, XML structure)
- Test /meta command with a simple domain to verify end-to-end workflow
- Document /meta command usage in appropriate README or guide

**Acceptance Criteria**:
- [ ] .opencode/agent/subagents/meta/ directory exists with all 5 subagents
- [ ] .opencode/command/meta.md exists with frontmatter delegation pattern
- [ ] meta.md routes to appropriate subagent based on user request
- [ ] meta subagents follow XML optimization patterns (context, role, task, workflow_execution, etc.)
- [ ] Context files support /meta without bloating (focused, modular, lazy-loaded)
- [ ] /meta command integrates with state.json for project tracking
- [ ] Generated files use git-workflow-manager for scoped commits
- [ ] Validation checks ensure generated agents/commands follow standards
- [ ] End-to-end test demonstrates /meta creating a simple agent/command
- [ ] Documentation explains /meta command usage and capabilities

**Impact**: Enables meta-programming capabilities for the ProofChecker .opencode system, allowing users to interactively create new agents, commands, and context files tailored to their needs. Provides a powerful tool for system extension and customization while maintaining high quality standards from the OpenAgents migration refactor.

---

### 251. Validate and Document Task 244 Phase 1 Abandoned Work (Phase 3 and Phase 6)
- **Effort**: 3-4 hours
- **Status**: [ABANDONED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: Task 244 (completed)

**Description**:
Review and document the two abandoned phases from Task 244 implementation plan: Phase 3 (researcher.md Workflow Ownership) and Phase 6 (Stage 7 Reliability Testing). Determine if the work these phases intended to accomplish was completed through alternative means or if follow-up work is needed. Create documentation explaining why these phases were abandoned and what impact (if any) this has on the overall migration success.

**Tasks**:
- Review Phase 3 abandonment reason: "Architectural mismatch - command-lifecycle pattern not needed in agent"
- Verify if researcher.md workflow ownership was accomplished through other means
- Review Phase 6 abandonment reason: "Requires OpenCode CLI integration - template created"
- Determine if Stage 7 reliability testing can be performed manually or needs automation
- Check if Task 245 Phase 2 work superseded the need for these phases
- Document findings in validation addendum report
- Update Task 244 implementation summary with clarifications
- Recommend if any follow-up work is needed

**Acceptance Criteria**:
- [ ] Both abandoned phases reviewed and documented
- [ ] Verification that intended outcomes were achieved (or why not needed)
- [ ] Validation addendum report created in Task 244 spec directory
- [ ] Task 244 implementation summary updated with clarifications
- [ ] Recommendations documented for any follow-up work needed

**Impact**: Ensures completeness of Phase 1 migration documentation, clarifies what was accomplished vs abandoned, provides closure on Task 244 implementation plan.


---

### 252. Implement Task 244 Phase 6: Stage 7 Reliability Testing with OpenCode CLI Integration
- **Effort**: 4-6 hours
- **Status**: [ABANDONED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: Task 244 (completed), Task 245 (completed)

**Description**:
Complete Task 244 Phase 6 which was abandoned due to OpenCode CLI integration requirements. Now that Phase 2 is complete and all 4 commands (/research, /plan, /implement, /revise) have been migrated to frontmatter delegation, implement comprehensive Stage 7 reliability testing to validate 100% execution rate across all workflow commands.

Phase 6 goal: Validate that the OpenAgents migration achieved 100% Stage 7 execution reliability, eliminating the systematic postflight failures that plagued the system before. This testing infrastructure will serve as regression protection for future changes.

**Tasks**:
- Create CLI-integrated reliability test script (.opencode/scripts/test-stage7-reliability.sh)
- Test /research command Stage 7 execution (20 consecutive runs, validate TODO.md/state.json updates)
- Test /plan command Stage 7 execution (20 consecutive runs, validate TODO.md/state.json updates)
- Test /implement command Stage 7 execution (20 consecutive runs, validate TODO.md/state.json/git updates)
- Test /revise command Stage 7 execution (20 consecutive runs, validate plan updates)
- Calculate success rates and generate metrics report
- Create validation report with baseline vs post-migration reliability
- Update Task 244 validation report with Phase 6 completion data

**Acceptance Criteria**:
- [ ] Reliability test script supports all 4 workflow commands
- [ ] /research Stage 7 reliability: 100% (20/20 runs with TODO.md/state.json updates verified)
- [ ] /plan Stage 7 reliability: 100% (20/20 runs with TODO.md/state.json updates verified)
- [ ] /implement Stage 7 reliability: 100% (20/20 runs with TODO.md/state.json/git updates verified)
- [ ] /revise Stage 7 reliability: 100% (20/20 runs with plan updates verified)
- [ ] Metrics report documents baseline (0%) vs post-migration (target: 100%)
- [ ] Validation report created with recommendations for regression testing
- [ ] Task 244 documentation updated with Phase 6 completion

**Impact**: Provides quantitative validation that OpenAgents migration eliminated Stage 7 failures. Creates regression test infrastructure to protect against future regressions. Completes Task 244 Phase 1 validation goals.


---

### 240. Systematically investigate and fix persistent workflow command Stage 7 (Postflight) failures causing incomplete status updates
- **Effort**: 56-78 hours (revised from comparative analysis)
- **Status**: [ABANDONED]
- **Started**: 2025-12-29
- **Researched**: 2025-12-29
- **Completed**: 2025-12-29
- **Priority**: Critical
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research**: [Comparative Analysis Report](.opencode/specs/240_systematically_investigate_and_fix_persistent_workflow_command_stage_7_postflight_failures/reports/research-001.md)
- **Plan**: [Implementation Plan](.opencode/specs/240_systematically_investigate_and_fix_persistent_workflow_command_stage_7_postflight_failures/plans/implementation-002.md)

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
**Status**: [PLANNED]
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

