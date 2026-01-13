---
last_updated: 2026-01-13T02:18:19Z
next_project_number: 462
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-11T21:30:00Z
task_counts:
  active: 23
  completed: 139
  in_progress: 0
  not_started: 7
  abandoned: 7
  total: 169
priority_distribution:
  critical: 0
  high: 4
  medium: 3
  low: 6
technical_debt:
  sorry_count: 19
  axiom_count: 11
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

### 460. Cosmos Institute Substack Essay
- **Effort**: 3.5 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: High
- **Language**: general
- **Research**: [research-001.md](.claude/specs/460_cosmos_institute_substack_essay/reports/research-001.md), [research-002.md](.claude/specs/460_cosmos_institute_substack_essay/reports/research-002.md)
- **Plan**: [implementation-001.md](.claude/specs/460_cosmos_institute_substack_essay/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/460_cosmos_institute_substack_essay/summaries/implementation-summary-20260113.md)

**Description**: Created 1,321-word essay "Teaching Machines to Prove They're Right" for Cosmos Institute Substack. Synthesizes three grant contributions (machine-verified proofs, language for planning, unlimited training data) into accessible narrative with philosopher-builder theme. Essay at `docs/essays/cosmos-institute-essay.md`.

---

### 458. Extend canonical_history to full domain
- **Effort**: 8-12 hours
- **Status**: [PLANNED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-12 (v002)
- **Priority**: High
- **Language**: lean
- **Parent**: Task 257
- **Dependencies**: 448
- **Research**: [research-001.md](.claude/specs/458_extend_canonical_history_full_domain/reports/research-001.md)
- **Plan**: [implementation-002.md](.claude/specs/458_extend_canonical_history_full_domain/plans/implementation-002.md) (v002 - chain construction)

**Description**: Extend canonical_history from singleton domain to full domain for completeness proof correctness. v002: Redesigned to use **chain construction from 0** (instead of independent Classical.choose) to solve the coherence problem where independently chosen states may not lie on the same timeline. Build states as forward/backward chains from origin, ensuring compositionality by construction.

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

### 454. Fix temporal quantification to match paper
- **Effort**: 6-8 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-12
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: High
- **Language**: lean
- **Research**: [research-001.md](.claude/specs/454_fix_temporal_quantification_to_match_paper/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/454_fix_temporal_quantification_to_match_paper/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/454_fix_temporal_quantification_to_match_paper/summaries/implementation-summary-20260112.md)

**Description**: Fixed temporal quantification to match JPL paper. Changed `truth_at` to remove domain parameter, atoms use existential quantification (false outside domain), temporal operators quantify over all times T, validity/consequence definitions updated. All soundness proofs updated. `lake build Bimodal` succeeds.

---

## Medium Priority

### 461. Expand Bimodal Theory README section
- **Effort**: 25 minutes
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: Medium
- **Language**: general
- **Research**: [research-001.md](.claude/specs/461_expand_bimodal_theory_readme_section/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/461_expand_bimodal_theory_readme_section/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/461_expand_bimodal_theory_readme_section/summaries/implementation-summary-20260113.md)

**Description**: Expanded Bimodal Theory section in README.md from ~80 to ~260 words. Now explains time-possibility relationship, perpetuity principles P1-P6, methodology testbed purpose, and transfer patterns to Logos.

---

### 459. Update Bimodal LaTeX Metalogic, Theorems, and Notes
- **Effort**: 2.5 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: Medium
- **Language**: latex
- **Research**: [research-001.md](.claude/specs/459_update_bimodal_latex_metalogic_theorems_notes/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/459_update_bimodal_latex_metalogic_theorems_notes/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/459_update_bimodal_latex_metalogic_theorems_notes/summaries/implementation-summary-20260113.md)

**Description**: Updated three Bimodal LaTeX subfiles: added Decidability section to 04-Metalogic.tex with tableau algorithm and complexity analysis, added S5 Diamond-Box to Truth and T-Box Consistency theorems to 05-Theorems.tex, updated 06-Notes.tex with decidability status and discrepancy note. Build verified successfully (21-page PDF).

---

### 452. Use 'D' notation for duration group consistently
- **Effort**: 3.25 hours
- **Status**: [IMPLEMENTING]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Priority**: Medium
- **Language**: general
- **Research**: [research-001.md](.claude/specs/452_use_d_notation_for_duration_group/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/452_use_d_notation_for_duration_group/plans/implementation-001.md)

**Description**: Use 'D' instead of 'T' for the totally ordered commutative group of durations (also called times relative to a world history) consistently throughout the latex files in /home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/ and throughout the Lean Code in Logos/ to match the notation used in /home/benjamin/Projects/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex.

---

### 453. Add Ability and Free Choice Modal Extension to Logos
- **Effort**: TBD
- **Status**: [PLANNING]
- **Researched**: 2026-01-13
- **Priority**: Medium
- **Language**: lean
- **Research**: [research-001.md](.claude/specs/453_add_ability_free_choice_modal_extension/reports/research-001.md)

**Description**: Building on task 451, add an extension layer for ability and free choice modals to the middle layer while also acknowledging that there are many other potential extensions that could be added to the middle layer. As with task 451, the aim is to characterize and create stubs in the lean code to match the 'Epistemic Extension' and other extension layers that remain to be developed, while nevertheless updating all the relevant documentation.

---

### 441. Prove completeness via Relativized Completeness approach
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean

**Description**: Prove completeness following Approach 2 'Relativized Completeness' from research-004.md. The syntactic construction yields the "free" ordered abelian group on one generator, isomorphic to ℤ. Adding density axioms yields ℚ, completeness axioms approaches ℝ. References: .claude/specs/257_completeness_proofs/reports/research-004.md and research-006.md.

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

### 400. Investigate Explanatory/Truth.lean build performance
- **Effort**: 2-3 hours
- **Status**: [EXPANDED]
- **Researched**: 2026-01-11
- **Priority**: Medium
- **Language**: lean
- **Subtasks**: 419 (416, 417, 418, 420 completed)
- **Research**: [research-001.md](.claude/specs/400_investigate_explanatory_truth_build_performance/reports/research-001.md)

**Description**: Investigate why building Explanatory/Truth.lean is so computationally demanding and identify ways to build faster or more efficiently.

---

### 419. Refactor mutual recursion in Foundation/Semantics.lean
- **Effort**: 4-6 hours
- **Status**: [PLANNED]
- **Researched**: 2026-01-12
- **Planned**: 2026-01-12
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 400
- **Dependencies**: 416
- **Research**: [research-001.md](.claude/specs/419_refactor_mutual_recursion_semantics/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/419_refactor_mutual_recursion_semantics/plans/implementation-001.md)

**Description**: Refactor the mutual recursion between verifies/falsifies in Foundation/Semantics.lean. Replace the `mutual` block with a single `eval` function parameterized by a `Polarity` type, enabling cleaner structural recursion and reducing well-founded recursion elaboration overhead.

---

## Low Priority

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
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 257
- **Dependencies**: 448
- **Plan**: [implementation-002.md](.claude/specs/257_completeness_proofs/plans/implementation-002.md) (Phase 6)

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
