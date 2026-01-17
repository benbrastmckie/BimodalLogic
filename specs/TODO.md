---
next_project_number: 565
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-11T21:30:00Z
task_counts:
  active: 26
  completed: 167
  in_progress: 0
  not_started: 28
  abandoned: 14
  total: 201
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

### 534. Research Claude Code Model Selection Mechanisms
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Language**: meta
- **Session ID**: sess_1768691198_77654e
- **Created**: 2026-01-17
- **Researched**: 2026-01-17
- **Planned**: 2026-01-17
- **Completed**: 2026-01-17
- **Research**: [research-001.md](specs/534_research_claude_code_model_selection/reports/research-001.md)
- **Plan**: [implementation-004.md](specs/534_research_claude_code_model_selection/plans/implementation-004.md)
- **Summary**: [implementation-summary-20260117.md](specs/534_research_claude_code_model_selection/summaries/implementation-summary-20260117.md)

**Description**: Comprehensive protocol/.claude/ upgrade incorporating Tasks 534, 548, 563, 564. 6-phase plan: (1) Add model: sonnet to 6 agents, (2) Add CRITICAL Task tool directives to 6 forked skills, (3) Remove eager mkdir from task.md and meta-builder-agent.md, (4) Update CLAUDE.md documentation, (5) Verify skill-status-sync direct execution, (6) Final verification and commit.

---

## Medium Priority

### 563. Investigate Empty Directory Creation in specs/
- **Effort**: 1-2 hours
- **Status**: [IMPLEMENTING]
- **Priority**: Medium
- **Language**: meta
- **Created**: 2026-01-17
- **Planned**: 2026-01-17
- **Research**: [research-001.md](specs/563_investigate_empty_directory_creation/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/563_investigate_empty_directory_creation/plans/implementation-001.md)

**Description**: Investigate empty directories being created in specs/ which violates the lazy directory creation rule. Carefully inspect all potential sources in the .claude/ agent system to identify the root cause and resolve the issue elegantly.

---

### 556. Complete Metalogic_v2 Implementation
- **Effort**: 6-10 hours
- **Status**: [EXPANDED]
- **Priority**: High
- **Language**: lean
- **Session ID**: sess_1768682818_dff425
- **Created**: 2026-01-17
- **Researched**: 2026-01-17
- **Planned**: 2026-01-17
- **Dependencies**: 554
- **Research**: [research-001.md](specs/556_complete_metalogic_v2_implementation/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/556_complete_metalogic_v2_implementation/plans/implementation-001.md)
- **Subtasks**: 557, 558, 559, 560, 561

**Description**: Complete all aspects of the implementation of the reorganized /home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/ directory, completing all sorries and making this directory stand on its own so that I can delete Metalogic/ once Metalogic_v2/ is complete. Begin by improving /home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/README.md to accurately report the current state and what the target organization is.

---

### 559. Strong Completeness Helpers
- **Effort**: 2 hours
- **Status**: [IMPLEMENTING]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-17
- **Revised**: 2026-01-17
- **Parent**: 556
- **Dependencies**: 557
- **Research**: [research-001.md](specs/559_strong_completeness_helpers/reports/research-001.md)
- **Plan**: [implementation-002.md](specs/559_strong_completeness_helpers/plans/implementation-002.md)

**Description**: Prove entails_imp_chain and imp_chain_to_context in StrongCompleteness.lean, plus double negation elimination and canonical world contradiction in RepresentationTheorem.lean. The results in Bimodal/Metalogic/ serve as inspiration only - they should NOT be imported or distract from Metalogic_v2 reorganization. The representation theorem must be the foundation from which completeness derives. Metalogic/ will be deleted once Metalogic_v2 is complete.

---

### 560. Axiom Elimination
- **Effort**: 1-2 hours
- **Status**: [RESEARCHING]
- **Priority**: High
- **Language**: lean
- **Created**: 2026-01-17
- **Parent**: 556
- **Dependencies**: 558

**Description**: Replace representation_theorem_backward_empty axiom with a proven theorem in Representation/ContextProvability.lean. Uses completeness contrapositive argument.

---

### 561. Cleanup and Documentation
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Created**: 2026-01-17
- **Parent**: 556
- **Dependencies**: 560

**Description**: Prove consistent_iff_consistent in Basic.lean and necessitation_lemma in TruthLemma.lean. Update README.md with accurate completion status. Verify zero sorries in Metalogic_v2.

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

### 562. Agent System Refactor Report for Protocol Repository
- **Effort**: 2-3 hours
- **Status**: [PLANNING]
- **Priority**: Medium
- **Language**: general
- **Created**: 2026-01-17
- **Research**: [research-001.md](specs/562_agent_system_refactor_report/reports/research-001.md)

**Description**: Look through the recently completed refactors to .claude/ which addressed some of the errors I was having about continuation and skills calling skills and aborting, etc., in order to create a report in /home/benjamin/Projects/protocol/specs/ with links to all relevant reports and plans from these refactors so that similar changes can be made to protocol/.claude/ to emulate the advances made in the .claude/ agent system in this repository.

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
