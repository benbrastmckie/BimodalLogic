---
next_project_number: 554
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-11T21:30:00Z
task_counts:
  active: 22
  completed: 163
  in_progress: 0
  not_started: 28
  abandoned: 14
  total: 197
priority_distribution:
  critical: 0
  high: 10
  medium: 9
  low: 11
technical_debt:
  sorry_count: 19
  axiom_count: 11
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

### 547. Improve FMP Full Theorem
- **Effort**: 4-5 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: lean
- **Session ID**: sess_1768669081_835e7d
- **Created**: 2026-01-17
- **Researched**: 2026-01-17
- **Planned**: 2026-01-17
- **Completed**: 2026-01-17
- **Research**: [research-001.md](specs/547_improve_fmp_full_theorem/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/547_improve_fmp_full_theorem/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260117.md](specs/547_improve_fmp_full_theorem/summaries/implementation-summary-20260117.md)

**Description**: Improve the current implementation to establish the full FMP theorem proving that ANY model can be reduced to a FINITE model.

**Implementation**: Fixed 22+ build errors in FiniteCanonicalModel.lean. Added `satisfiable_implies_not_refutable` bridge lemma and `phi_consistent_of_not_refutable` helper. Implemented `finite_model_property_v2` theorem establishing that satisfiable formulas have finite model witnesses via SemanticCanonicalFrame. One bridge gap remains requiring formula induction.

---

### 548. Fix Skill-to-Agent Delegation Pattern
- **Effort**: 2-3 hours
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: meta
- **Session ID**: sess_1768669365_4f0a88
- **Created**: 2026-01-17
- **Researched**: 2026-01-17
- **Planned**: 2026-01-17
- **Research**: [research-001.md](specs/548_fix_skill_to_agent_delegation_pattern/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/548_fix_skill_to_agent_delegation_pattern/plans/implementation-001.md)

**Description**: Add explicit Task tool invocation instructions to all 7 forked skills that delegate to agents. Replace ambiguous prose with clear directives: "You MUST use the Task tool (NOT Skill tool) to spawn the subagent." This fixes the root cause identified in Task 539 research.

---

### 549. Research Intelligent Model Routing Architecture
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-17
- **Dependencies**: 548

**Description**: Research how to implement intelligent model routing in the .claude/ architecture. Options include: query complexity analyzer skill, task-type based routing rules, or model cascade pattern. Evaluate trade-offs between complexity, cost savings, and reliability given the Haiku tool_reference limitation.

---

### 550. Implement Model Tier Strategy
- **Effort**: 3-4 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta
- **Created**: 2026-01-17
- **Dependencies**: 548, 549

**Description**: Based on Task 549 research, implement the chosen model tiering strategy. Update agent frontmatter with appropriate model assignments. Strategy options: Simple (Haiku for research, Sonnet for implementation, Opus for lean-implementation), Optimized (complexity-based variants), or Advanced (routing logic in orchestrator).

---

### 534. Research Claude Code Model Selection Mechanisms
- **Effort**: 2-3 hours
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: meta
- **Session ID**: sess_1768659565_318297
- **Created**: 2026-01-17
- **Researched**: 2026-01-17
- **Planned**: 2026-01-17
- **Research**: [research-001.md](specs/534_research_claude_code_model_selection/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/534_research_claude_code_model_selection/plans/implementation-001.md)

**Description**: Research how Claude Code handles model selection for the Task tool. Determine if agent YAML frontmatter supports model specification, whether the model parameter must be set at Task tool invocation, and document the complete model selection mechanism including inheritance and defaults.

---







### 517. Fix /research command to avoid creating unnecessary summary files and properly link research reports in TODO.md and state.json with correct status updates
- **Effort**: 2-3 hours
- **Status**: [ABANDONED]
- **Priority**: High
- **Language**: general
- **Session ID**: sess_1768592660_vnieb
- **Research**: [Research Report](specs/517_fix_research_command_summary_files/reports/research-001.md)
- **Researched**: 2025-01-16T10:51:00Z

**Description**: Fix the /research command to avoid creating unnecessary implementation-summary files in summaries/ directory, properly link research reports in TODO.md and state.json, and correctly update task status to RESEARCHED. These issues prevent proper workflow tracking and create cleanup burden.

---

## Medium Priority

### 551. Create Model Complexity Analyzer
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-17
- **Dependencies**: 550

**Description**: Create a lightweight skill that analyzes task complexity to recommend optimal model tier. Criteria: task language, estimated effort, number of files affected, tool requirements. This enables dynamic model selection without creating variant agents.

---

### 552. Test and Validate Model Tiering Changes
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-17
- **Dependencies**: 550

**Description**: Test model tiering changes across all workflow commands (/research, /plan, /implement). Verify: Haiku works for simple tasks, Sonnet handles standard work, Opus reserved for hardest tasks (complex Lean proofs). Document any Haiku failures due to tool_reference limitation.

---

### 553. Document Final Model Tier Architecture
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-17
- **Dependencies**: 551, 552

**Description**: Create comprehensive documentation for the model tier system. Include: decision matrix for model selection, cost comparison examples, known limitations (Haiku tool_reference bug), and troubleshooting guide.

---

### 540. Finish Metalogic Directory Refactor and Cleanup
- **Effort**: 4-6 hours
- **Status**: [EXPANDED]
- **Priority**: Medium
- **Language**: lean
- **Session ID**: sess_1768661078_ad3932
- **Created**: 2026-01-17
- **Researched**: 2026-01-17
- **Research**: [research-001.md](specs/540_finish_metalogic_refactor_cleanup/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/540_finish_metalogic_refactor_cleanup/plans/implementation-001.md)
- **Subtasks**: 542, 543, 544, 545, 546

**Description**: Finish the Logos/Metalogic/ directory refactor, leaving no stray elements or parallel structures. The situation is documented in specs/523_bimodal_cleanup/reports/research-003.md. Move anything worth saving that is not necessary for the refactored implementation to Bimodal/Boneyard/ (if not already represented), and update all documentation to be fully accurate.

---




### 545. Complete Applications Module (Phase 4 of 540)
- **Effort**: 0.5 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-17
- **Completed**: 2026-01-17
- **Parent**: 540
- **Dependencies**: 542, 543, 544
- **Research**: [research-001.md](specs/545_complete_applications_module/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/545_complete_applications_module/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260117.md](specs/545_complete_applications_module/summaries/implementation-summary-20260117.md)

**Description**: Fix CompletenessTheorem.lean and Compactness.lean to use the new architecture. Export weak_completeness and strong_completeness theorems, update parent Metalogic.lean module.

**Implementation**: Rewrote CompletenessTheorem.lean as thin re-export module from Completeness.lean (exporting weak_completeness, strong_completeness, provable_iff_valid, consistency_iff_satisfiability). Rewrote Compactness.lean with correct List-based Context signatures. Updated Metalogic.lean with new imports.

---

### 546. Documentation Update (Phase 5 of 540)
- **Effort**: 0.5 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-17
- **Completed**: 2026-01-17
- **Parent**: 540
- **Dependencies**: 542, 543, 544, 545
- **Research**: [research-001.md](specs/546_documentation_update/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/546_documentation_update/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260117.md](specs/546_documentation_update/summaries/implementation-summary-20260117.md)

**Description**: Update Metalogic/README.md with accurate architecture diagram and module status. Remove references to non-existent Metalogic/Boneyard/, point to Bimodal/Boneyard/ instead. Add module-level docstrings.

**Implementation**: Fixed all Boneyard path references (Metalogic/Boneyard/ → Bimodal/Boneyard/), updated module status table (Representation modules now PARTIAL with sorries), refreshed architecture diagrams, marked Phase 1 complete in Migration Path, updated Building section and footer.

---


### 511. Resolve 26 sorry placeholders in Completeness.lean
- **Effort**: 20 hours
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: lean
- **Created By**: Review task 506
- **Review Artifact**: [specs/506_codebase_review/summaries/review-summary.md](specs/506_codebase_review/summaries/review-summary.md)
- **Research Report**: [specs/511_resolve_26_sorry_placeholders_in_completeness.lean/reports/research-001.md](specs/511_resolve_26_sorry_placeholders_in_completeness.lean/reports/research-001.md)
- **Session ID**: sess_1768517000_research511
- **Researched**: 2026-01-16

**Description**: Resolve 26 sorry placeholders in Completeness.lean. Research reveals Aristotle made no progress (39 sorry gaps remain). Recommendation: pivot to finite canonical model approach already complete in FiniteCanonicalModel.lean.

---

### 513. Address tm_auto proof reconstruction issues
- **Effort**: 5 hours
- **Status**: [RESEARCHED]
- **Priority**: Medium
- **Language**: lean
- **Session ID**: sess_1768594543_in7i1i
- **Created By**: Review task 506
- **Review Artifact**: [specs/506_codebase_review/summaries/review-summary.md](specs/506_codebase_review/summaries/review-summary.md)
- **Research**: [Research Report](specs/513_address_tm_auto_proof_reconstruction_issues/reports/research-001.md)
- **Researched**: 2026-01-16T19:55:00Z

**Description**: Address tm_auto proof reconstruction issues. Tactic implementation exists but has proof reconstruction problems.

---

### 514. Expand test coverage for Logos theory modules
- **Effort**: 10 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created By**: Review task 506
- **Review Artifact**: [specs/506_codebase_review/summaries/review-summary.md](specs/506_codebase_review/summaries/review-summary.md)

**Description**: Expand test coverage for Logos theory modules. Currently 53.6% coverage (45 test files for 84 core files).

---

### 394. Research and port causal semantics from paper
- **Effort**: 4-6 hours
- **Status**: [EXPANDED]
- **Researched**: 2026-01-12
- **Priority**: High
- **Language**: lean
- **Parent**: Task 381
- **Subtasks**: 398, 399
- **Research**: [research-001.md](specs/394_research_port_causal_semantics_from_paper/reports/research-001.md), [research-002.md](specs/394_research_port_causal_semantics_from_paper/reports/research-002.md)

**Description**: Research and port the correct causal operator semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md first, then to Lean. The causal operator is primitive (like the counterfactual conditional) and requires careful adaptation to the more sophisticated theory of time in Logos.

---

### 398. Port causal semantics to recursive-semantics.md
- **Effort**: 3-4 hours
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: markdown
- **Parent**: Task 394
- **Research**: [research-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/reports/research-001.md)

**Description**: Port the causal semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md. Adapt the 2-place task relation from the paper to the more sophisticated 3-place task relation (with duration) in Logos. Carefully study the counterfactual semantics already included in the recursive-semantics.md in order to adapt existing resources rather than positing additional resources in order to construct the three-condition truth clause for causation.

---

### 399. Implement causal semantics in Lean
- **Effort**: 6-8 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: lean
- **Parent**: Task 394
- **Dependencies**: 398

**Description**: Implement the causal operator semantics in Lean based on the approved recursive-semantics.md specification. Extend CoreFrame with closeness ordering, define Evolution and ExpectedEvolution structures, implement CausalContext with background assumptions, and replace the current counterfactual-based definition in Truth.lean with the three-condition hyperintensional semantics.

---

### 502. Complete representation theorem using context-based provability based on Task 499 foundation
 **Effort**: 4 hours
 **Status**: [COMPLETED]
 **Priority**: High
 **Language**: lean
 **Started**: 2026-01-14
- **Completed**: 2026-01-14
 **Researched**: 2026-01-14
 **Revised**: 2026-01-14
 **Parent**: Task 499
 **Dependencies**: Task 499 (completed)
 **Research**: [research-001.md](specs/502_complete_representation_theorem/reports/research-001.md), [research-002.md](specs/502_complete_representation_theorem/reports/research-002.md)
 *
 **Analysis**: [initial-analysis.md](specs/502_complete_representation_theorem/reports/initial-analysis.md)
 **Summary**: [research-002.md](specs/502_complete_representation_theorem/summaries/research-002.md)
 **Plan**: [implementation-001.md](specs/502_complete_representation_theorem/plans/implementation-001.md)
- **Implementation**: [RepresentationTheorems.lean](Theories/Bimodal/Metalogic/RepresentationTheorems.lean)
 **Session**: sess_1768452611_xef

**Description**: Complete representation theorem using Lean native context-based provability (ContextDerivable using List Formula) throughout Bimodal/ theory. Draw on research findings that confirm context-based provability is superior to set-based SetDerivable. Eliminate set-based provability entirely and integrate with FiniteCanonicalModel.lean using context-based approach.

**Key Implementation Points**:
- Replace SetDerivable with ContextDerivable throughout Bimodal/ theory
- Implement completeness theorems using context-based provability only
- Remove all set-based components from RepresentationTheorems.lean
- Integrate with FiniteCanonicalModel.lean using context-based approach
- Ensure Lean idiomatic patterns using List Formula for provability
- Leverage Task 499 foundation for metalogical architecture

**Files**:
- Theories/Bimodal/Metalogic/RepresentationTheorems.lean (scaffold exists)
- FiniteCanonicalModel.lean (integration target)
- Theories/Bimodal/Metalogic.lean (parent module)

---

## Medium Priority

### 516. Test task creation after refactoring
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: general
- **Session ID**: agent_system-1768239349
- **Created**: 2026-01-16

**Description**: Test the task creation system to ensure it works correctly after the recent agent system refactoring. This is a validation task to verify that the workflow commands, task management, and file synchronization are functioning properly after the structural changes.

---

### 510. Add constraint to verifier and falsifier functions
- **Effort**: 2 hours
- **Status**: [PLANNED]
- **Priority**: Medium
- **Language**: latex
- **Research**: [research-001.md](/home/benjamin/Projects/ProofChecker/specs/510_mereological_constraints_research/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/510_mereological_constraints/plans/implementation-001.md)
- **Researched**: 2025-01-15
- **Planned**: 2025-01-16

**Description**: Create distinct VerifierFunction and FalsifierFunction types with mereological constraints using pure dependent type theory. Avoid set-theoretic notions while allowing different extensions for verifiers vs falsifiers. Update both Lean implementation and LaTeX documentation (lines 75-76).

---

### 504. Integration of harmonic API for aristotle into lean implementer and researcher agents
- **Effort**: 4-6 hours
- **Status**: [REVISED]
- **Priority**: Medium
- **Language**: lean
- **Session**: sess_1768539600_revise504
- **Researched**: 2026-01-15T02:35:00Z
- **Planned**: 2026-01-15
- **Revised**: 2026-01-15
- **Research**: [research-001.md](/home/benjamin/Projects/ProofChecker/specs/504_aristotle_integration/reports/research-001.md)

- **Plan**: [Revised integration plan for Harmonic Aristotle API into Lean implementer agent](specs/504_aristotle_integration/plans/implementation-003.md)

**Description**: Design and integrate harmonic API for aristotle into lean implementer and researcher agents as appropriate. This involves API design, integration planning, and coordination between lean-specific agents.

### 475. Create skill-document-converter thin wrapper
- **Effort**: 1 hour
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Research Report**: [research-001.md](498_verify_bridge_lemma_infrastructure/reports/research-001.md)
- **Language**: meta

**Description**: Create skill-document-converter as thin wrapper following ProofChecker's forked subagent pattern. Validates input, delegates to document-converter-agent, returns standardized result. No external script dependencies.

**Reference Files**:
- Inspiration: `/home/benjamin/Projects/Logos/.claude/skills/document-converter/README.md`
- Issues to avoid: `/home/benjamin/Projects/Logos/.claude/outputs/convert.md`

---

### 476. Create document-converter-agent
- **Effort**: 3-4 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Research Report**: [research-001.md](498_verify_bridge_lemma_infrastructure/reports/research-001.md)
- **Language**: meta
- **Dependencies**: 475

**Description**: Create document-converter-agent following ProofChecker's agent pattern. Handles actual conversion logic with runtime tool detection (markitdown, pandoc, typst), graceful fallbacks to Claude's native PDF reading, bidirectional conversion support, and standardized JSON returns.

**Reference Files**:
- Inspiration: `/home/benjamin/Projects/Logos/.claude/skills/document-converter/README.md`
- Issues to avoid: `/home/benjamin/Projects/Logos/.claude/outputs/convert.md`

**Design Requirements**:
1. NO external shell script dependencies - all logic embedded in agent
2. Detect tools via Bash within agent (`command -v` checks)
3. Use Claude's native PDF/image reading (Read tool) as fallback
4. Tool priority: markitdown > pandoc > Claude native
5. Avoid pip output contamination - separate installation from conversion
6. Support bidirectional: PDF/DOCX → Markdown AND Markdown → PDF/DOCX

---

### 477. Test document-converter on sample files
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Research Report**: [research-001.md](498_verify_bridge_lemma_infrastructure/reports/research-001.md)
- **Language**: meta
- **Dependencies**: 476

**Description**: Test document-converter skill on sample PDF, DOCX, and Markdown files. Verify bidirectional conversion, graceful fallback when tools unavailable, and proper error handling.

**Reference Files**:
- Issues to avoid: `/home/benjamin/Projects/Logos/.claude/outputs/convert.md`

**Test Cases**:
1. PDF → Markdown (with markitdown available)
2. PDF → Markdown (markitdown fails, fallback to Claude native)
3. DOCX → Markdown
4. Markdown → PDF (using pandoc/typst)
5. Error handling when no tools available

---

### 483. Investigate LaTeX aux file corruption errors
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Research Report**: [research-001.md](498_verify_bridge_lemma_infrastructure/reports/research-001.md)
- **Language**: latex

**Description**: When making changes to LaTeX files (e.g., 00-Introduction.tex), rebuilding sometimes produces "File ended while scanning use of \@newl@bel" and "\@@BOOKMARK" errors, plus "Extra }, or forgotten \endgroup" errors in the .aux file. Identify the root cause (likely corrupted auxiliary files from interrupted builds) and document solutions to avoid these errors.

---

### 431. WezTerm tab color notification for Claude Code input needed
- **Effort**: 2-3 hours
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-12
- **Priority**: Medium
- **Research Report**: [research-001.md](498_verify_bridge_lemma_infrastructure/reports/research-001.md)
- **Language**: general
- **Research**: [research-001.md](specs/431_wezterm_tab_color_notification/reports/research-001.md)

**Description**: Set up WezTerm tab color notification when Claude Code needs input. Using Claude Code in neovim via a plugin and WezTerm for the terminal on NixOS (software managed in ~/.dotfiles/). Configure so that when Claude Code completes or needs input, the numbered tab in WezTerm turns a visible color to indicate which tabs need attention.

---

## Low Priority

### 468. Refactor infinite canonical model code
- **Status**: [RESEARCHED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 458
- **Researched**: 2026-01-15T23:20:00Z
- **Research**: [research-001.md](specs/468_remove_or_refactor_the_existing_infinite_canonical_model_code_in_completeness.lean/reports/research-001.md)

**Description**: Remove or refactor the existing infinite canonical model code in Completeness.lean. Now that FiniteCanonicalModel.lean implements the finite approach, assess whether the infinite Duration-based code should be removed, preserved for future use, or refactored.

---

### 469. Decidability decision procedure
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 458

**Description**: Implement full decidability decision procedure for TM logic. The finite model property from FiniteCanonicalModel.lean directly yields decidability - implement a tableau-based or model-checking decision procedure that exploits the bounded model size.

---

### 470. Finite model computational optimization
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 458

**Description**: Optimize FiniteCanonicalModel.lean for computational efficiency. Current implementation prioritizes correctness over performance. Identify and implement optimizations for the finite world state enumeration, task relation checking, and truth evaluation.

---

### 490. Complete decidability procedure
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 469

**Description**: Complete the decidability procedure for TM logic. The existing Decidability module has tableau infrastructure but needs: proof extraction from closed tableaux, completeness proof connecting to FMP, and full decide function verification. Extends Task 469.

---

### 491. Research alternative completeness proofs
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean

**Description**: Research alternative completeness proof approaches for TM logic: filtration-based proofs (standard modal technique), algebraic semantics (Boolean algebras with operators), and step-by-step canonical model variations. Compare with current semantic history-based approach for potential improvements or independent verification.

---

### 257. Completeness Proofs

 **Effort**: 65-85 hours (revised from 57-76 to include Phase 5)
 **Status**: [EXPANDED]
 **Researched**: 2026-01-12
 **Planned**: 2026-01-12
 **Revised**: 2026-01-12
 **Priority**: Low
 **Language**: lean
 **Blocking**: None (Decidability complete)
 **Dependencies**: Soundness (Complete), Deduction Theorem (Complete), Proof Search (Complete), Decidability (Complete)
 **Subtasks**: 444 (completed), 445 (completed), 446 (completed), 447 (completed), 448 (completed), 449, 450
 **Research**: [research-001.md](specs/257_completeness_proofs/reports/research-001.md), [research-002.md](specs/257_completeness_proofs/reports/research-002.md), [research-003.md](specs/257_completeness_proofs/reports/research-003.md), [research-004.md](specs/257_completeness_proofs/reports/research-004.md), [research-005.md](specs/257_completeness_proofs/reports/research-005.md), [research-006.md](specs/257_completeness_proofs/reports/research-006.md), [research-007.md](specs/257_completeness_proofs/reports/research-007.md), [research-008.md](specs/257_completeness_proofs/reports/research-008.md)
 **Plan**: [implementation-002.md](specs/257_completeness_proofs/plans/implementation-002.md) (v002 - added Phase 5 canonical_history)

**Description**: Implement the completeness proof for TM logic using the canonical model method. Research-004 clarifies the key approach: use **relativized completeness** where times are a type parameter T (not constructed from syntax), while worlds (maximal consistent sets) and task relations ARE constructed from syntax. This matches the polymorphic validity definition and remains agnostic about discrete/dense/continuous time.

**Action Items**:
1. Implement `lindenbaum` lemma (extend consistent sets to maximal consistent sets using Zorn's lemma).
2. Prove properties of maximal consistent sets (deductive closure, negation completeness).
3. Construct `canonical_frame` and prove frame properties (nullity, compositionality).
4. Prove `truth_lemma` (correspondence between membership and truth).
5. Prove `weak_completeness` and `strong_completeness`.

**Files**:
- `Logos/Core/Metalogic/Completeness.lean`

**Acceptance Criteria**:
- [x] Lindenbaum lemma implemented
- [x] Maximal consistent set properties proven
- [x] Canonical frame constructed with frame properties
- [ ] Truth lemma proven
- [ ] Weak and strong completeness proven

**Impact**: Completes the metalogic foundation for TM logic by proving completeness, enabling derivability from validity.

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

---
