---
last_updated: 2026-01-13T18:58:00Z
next_project_number: 475
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-11T21:30:00Z
task_counts:
  active: 14
  completed: 145
  in_progress: 1
  not_started: 6
  abandoned: 10
  total: 169
priority_distribution:
  critical: 0
  high: 4
  medium: 1
  low: 5
technical_debt:
  sorry_count: 19
  axiom_count: 11
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

### 474. Fix skill return "status": "completed" field causing premature stops
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta

**Description**: Fix skill-status-sync return format `"status": "completed"` field causing Claude to stop execution prematurely. Tasks 462 and 467 added continuation markers but the root issue remains: skill returns include a status field with value "completed" that Claude interprets as a stop signal. Change to non-triggering terminology like `"result": "success"` or `"ok": true`, or remove field entirely if summary is sufficient.

---

### 467. Review task 462 changes and fix root cause
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: High
- **Language**: meta
- **Research**: [research-001.md](.claude/specs/467_review_task_462_changes_fix_root_cause/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/467_review_task_462_changes_fix_root_cause/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/467_review_task_462_changes_fix_root_cause/summaries/implementation-summary-20260113.md)

**Description**: Added explicit continuation markers to /research, /plan, /implement command files to fix workflow delegation errors. Root cause: Claude treated skill JSON returns as stopping points. Fix adds "IMMEDIATELY CONTINUE" markers after each checkpoint. Documented pattern in command-lifecycle.md.

---

### 462. Fix workflow command delegation
- **Effort**: 2.5 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-01-12
- **Priority**: High
- **Language**: meta
- **Research**: [research-001.md](.claude/specs/462_fix_workflow_command_delegation/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/462_fix_workflow_command_delegation/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/462_fix_workflow_command_delegation/summaries/implementation-summary-20260112.md)

**Description**: Fix /research and /implement commands stopping after preflight. Commands complete skill-status-sync for preflight but fail to proceed to STAGE 2 delegation. Root cause: command files describe workflow but Claude stops executing after preflight instead of continuing to delegate to implementation skills/agents.

---

### 458. Extend canonical_history to full domain
- **Effort**: 15-17 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13 (v004)
- **Completed**: 2026-01-13
- **Priority**: High
- **Language**: lean
- **Parent**: Task 257
- **Dependencies**: 448
- **Research**: [research-001.md](.claude/specs/458_extend_canonical_history_full_domain/reports/research-001.md), [research-002.md](.claude/specs/458_extend_canonical_history_full_domain/reports/research-002.md), [research-003.md](.claude/specs/458_extend_canonical_history_full_domain/reports/research-003.md), [research-004.md](.claude/specs/458_extend_canonical_history_full_domain/reports/research-004.md)
- **Plan**: [implementation-004.md](.claude/specs/458_extend_canonical_history_full_domain/plans/implementation-004.md) (v004 - finite canonical model via subformula closure)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/458_extend_canonical_history_full_domain/summaries/implementation-summary-20260113.md)

**Description**: Implemented finite canonical model approach for completeness. Created FiniteCanonicalModel.lean (1432 lines) with finite time domain, world states, task relation, frame/model structures, existence lemmas, truth lemma skeleton, and completeness theorem statements. Nullity proven completely; compositionality partial. Key remaining work: Lindenbaum extension for finite closures and truth lemma proof completion.

---

### 464. Research coherence alternatives (Strategy A)
- **Effort**: 4 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: High
- **Language**: lean
- **Parent**: Task 458
- **Research**: [research-001.md](.claude/specs/464_research_coherence_alternatives_strategy_a/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/464_research_coherence_alternatives_strategy_a/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/464_research_coherence_alternatives_strategy_a/summaries/implementation-summary-20260112.md)

**Description**: Implement Strategy A: strengthen `canonical_task_rel` with G/H-formula persistence conditions. This addresses the root cause of compositionality failure while keeping Duration structurally agnostic (no discreteness, density, or continuity assumptions). The x > 0, y > 0 case becomes provable; mixed-sign cases remain documented gaps.

---

### 394. Research and port causal semantics from paper
- **Effort**: 4-6 hours
- **Status**: [EXPANDED]
- **Researched**: 2026-01-12
- **Priority**: High
- **Language**: lean
- **Parent**: Task 381
- **Subtasks**: 398, 399
- **Research**: [research-001.md](.claude/specs/394_research_port_causal_semantics_from_paper/reports/research-001.md), [research-002.md](.claude/specs/394_research_port_causal_semantics_from_paper/reports/research-002.md)

**Description**: Research and port the correct causal operator semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md first, then to Lean. The causal operator is primitive (like the counterfactual conditional) and requires careful adaptation to the more sophisticated theory of time in Logos.

---

### 398. Port causal semantics to recursive-semantics.md
- **Effort**: 3-4 hours
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: markdown
- **Parent**: Task 394
- **Research**: [research-001.md](.claude/specs/398_port_causal_semantics_to_recursive_semantics_md/reports/research-001.md)

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

## Medium Priority

### 473. Fix compositionality gaps from Task 458
- **Status**: [RESEARCHING]
- **Priority**: Medium
- **Language**: lean
- **Parent**: Task 458

**Description**: Fix compositionality gaps from Task 458.

---

### 472. Lindenbaum extension for finite closures
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Parent**: Task 458

**Description**: Complete the Lindenbaum extension for finite closures, building on task 458. Implement the restricted Lindenbaum lemma that extends consistent formula sets to maximal consistent sets within the finite subformula closure, enabling the finite truth lemma proof.

---

### 466. Add Reflection Extension to LogosReference
- **Effort**: 2-3 hours
- **Status**: [RESEARCHING]
- **Priority**: Medium
- **Language**: latex

**Description**: Use /home/benjamin/Projects/ProofChecker/Theories/Logos/docs/research/recursive-semantics.md to revise /home/benjamin/Projects/ProofChecker/Theories/Logos/latex/LogosReference.tex and its subfiles to include the characterization and stub for the 'Reflection Extension'.

---

### 465. Convert Cosmos essay to LaTeX
- **Effort**: 3-4 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-01-12
- **Priority**: Medium
- **Language**: latex
- **Research**: [research-001.md](.claude/specs/465_cosmos_essay_latex/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/465_cosmos_essay_latex/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/465_cosmos_essay_latex/summaries/implementation-summary-20260112.md)

**Description**: Convert /home/benjamin/Projects/ProofChecker/docs/essays/cosmos-institute-essay.md to a professionally formatted LaTeX document with the same title information as given in BimodalReference.tex and LogosReference.tex, including the sources indicated in those manuals in the references and linking the ModelChecker and ProofChecker to the git repos.

---

### 463. Improve /meta context loading
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: meta
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Research**: [research-001.md](.claude/specs/463_meta_context_loading_improvements/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/463_meta_context_loading_improvements/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/463_meta_context_loading_improvements/summaries/implementation-summary-20260113.md)

**Description**: Research the files in .claude/context/core/ that are relevant to the /meta command in order to progressively load exactly the right context when modifying or reproducing the current agentic system in order to identify and make improvements to the context loading in /meta and its skill and agent in a manner comparable to the /research, /plan, /revise, and /implement commands which are working nicely.

---

### 431. WezTerm tab color notification for Claude Code input needed
- **Effort**: 2-3 hours
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-12
- **Priority**: Medium
- **Language**: general
- **Research**: [research-001.md](.claude/specs/431_wezterm_tab_color_notification/reports/research-001.md)

**Description**: Set up WezTerm tab color notification when Claude Code needs input. Using Claude Code in neovim via a plugin and WezTerm for the terminal on NixOS (software managed in ~/.dotfiles/). Configure so that when Claude Code completes or needs input, the numbered tab in WezTerm turns a visible color to indicate which tabs need attention.

---

## Low Priority

### 468. Refactor infinite canonical model code
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 458

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

### 471. Constructive model finiteness proof
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 458

**Description**: Prove model finiteness constructively in FiniteCanonicalModel.lean. Current implementation uses Classical.choice where needed. Investigate whether a fully constructive proof is possible and implement if feasible.

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
 **Research**: [research-001.md](.claude/specs/257_completeness_proofs/reports/research-001.md), [research-002.md](.claude/specs/257_completeness_proofs/reports/research-002.md), [research-003.md](.claude/specs/257_completeness_proofs/reports/research-003.md), [research-004.md](.claude/specs/257_completeness_proofs/reports/research-004.md), [research-005.md](.claude/specs/257_completeness_proofs/reports/research-005.md), [research-006.md](.claude/specs/257_completeness_proofs/reports/research-006.md), [research-007.md](.claude/specs/257_completeness_proofs/reports/research-007.md), [research-008.md](.claude/specs/257_completeness_proofs/reports/research-008.md)
 **Plan**: [implementation-002.md](.claude/specs/257_completeness_proofs/plans/implementation-002.md) (v002 - added Phase 5 canonical_history)

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

### 449. Truth lemma
- **Effort**: 15-20 hours
- **Status**: [IMPLEMENTING]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 257
- **Dependencies**: 448
- **Research**: [research-001.md](.claude/specs/449_truth_lemma/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/449_truth_lemma/plans/implementation-001.md)

**Description**: Phase 6 of completeness proofs: Prove truth lemma establishing correspondence between membership and truth. Cases for atoms, bottom, implication, box, past, future. Combine into main truth_lemma theorem.

---

### 450. Completeness theorems
- **Effort**: 8-10 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 257
- **Dependencies**: 449
- **Plan**: [implementation-002.md](.claude/specs/257_completeness_proofs/plans/implementation-002.md) (Phase 7)

**Description**: Phase 7 of completeness proofs: Prove weak_completeness and strong_completeness using truth lemma. Complete provable_iff_valid proof. Final cleanup to verify no axioms or sorry remain in Completeness.lean.

---

### 133. Build canonical model constructors in Completeness.lean
- **Effort**: 25-35 hours
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-12
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 132 (completed)
- **Research**: [research-001.md](.claude/specs/133_build_canonical_model_constructors_in_completeness/reports/research-001.md)
- **Files Affected**:
  - Theories/Bimodal/Metalogic/Completeness.lean
- **Description**: Implement canonical model construction helpers and remove associated axiom stubs. Requires implementing 7 axioms: maximal_consistent_closed, maximal_negation_complete, canonical_task_rel, canonical_frame, canonical_valuation, canonical_model, canonical_history.
- **Acceptance Criteria**:
  - [ ] Canonical model constructors implemented
  - [ ] Corresponding axiom placeholders removed
  - [ ] Construction type-checks with existing definitions
- **Impact**: Provides the core model for subsequent truth lemma proofs.

---

### 134. Prove truth lemma structure in Completeness.lean
- **Effort**: 3 hours
- **Status**: [ON HOLD]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 133
- **Note**: On hold pending Bimodal polish (Task 360)
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
- **Status**: [ON HOLD]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 132, 133, 134
- **Note**: On hold pending Bimodal polish (Task 360)
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Complete the `provable_iff_valid` theorem using the proven canonical model and truth lemma to eliminate the remaining sorry.
- **Acceptance Criteria**:
  - [ ] `provable_iff_valid` fully proven
  - [ ] No remaining axiom or sorry placeholders in Completeness.lean
  - [ ] Completeness tests added or updated
- **Impact**: Delivers full completeness, enabling derivability from validity.

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
