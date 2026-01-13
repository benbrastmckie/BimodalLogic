---
last_updated: 2026-01-12T23:34:26Z
next_project_number: 461
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-11T21:30:00Z
task_counts:
  active: 13
  completed: 130
  in_progress: 0
  not_started: 7
  abandoned: 7
  total: 150
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
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-13
- **Priority**: High
- **Language**: general
- **Research**: [research-001.md](.claude/specs/460_cosmos_institute_substack_essay/reports/research-001.md)

**Description**: Create a 1000-2000 word essay that makes the project and its conclusions accessible to the public. Essays should conform to the tone and style of those that have appeared on the Cosmos Institute Substack. With the Grantee's consent, select essays may be edited and featured on the Cosmos Institute Substack. This essay is due within 30 days after the conclusion of the grant term.

---

### 458. Extend canonical_history to full domain
- **Effort**: 10-14 hours
- **Status**: [IMPLEMENTING]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Priority**: High
- **Language**: lean
- **Parent**: Task 257
- **Dependencies**: 448
- **Research**: [research-001.md](.claude/specs/458_extend_canonical_history_full_domain/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/458_extend_canonical_history_full_domain/plans/implementation-001.md)

**Description**: Extend canonical_history from singleton domain to full domain for completeness proof correctness. The singleton domain (Task 448) makes temporal operators G φ and H φ vacuously true regardless of MCS membership, breaking the truth lemma correspondence: we need `G φ ∈ Γ iff G φ true` but singleton gives `G φ always true`. Requires implementing forward/backward existence lemmas to construct MCSs at arbitrary times while preserving canonical_task_rel.

---

### 437. Improve README consistency with recursive-semantics.md
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-12
- **Planned**: 2026-01-12
- **Completed**: 2026-01-12
- **Priority**: High
- **Language**: general
- **Research**: [research-001.md](.claude/specs/437_improve_readme_consistency_with_recursive_semantics/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/437_improve_readme_consistency_with_recursive_semantics/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/437_improve_readme_consistency_with_recursive_semantics/summaries/implementation-summary-20260112.md)

**Description**: Improved Logos README.md for consistency with recursive-semantics.md. Added ModelChecker references, consolidated Extension Architecture diagram to summary + link, fixed all symbol notation in operator tables, corrected Implementation Status table, added missing operators (derived temporal, quantifiers, causal), and fixed directory structure path.

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
- **Status**: [IMPLEMENTING]
- **Researched**: 2026-01-12
- **Planned**: 2026-01-13
- **Priority**: High
- **Language**: lean
- **Research**: [research-001.md](.claude/specs/454_fix_temporal_quantification_to_match_paper/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/454_fix_temporal_quantification_to_match_paper/plans/implementation-001.md)

**Description**: The Lean implementation restricts temporal quantification to times in the world history's domain dom(τ) despite the fact the source paper /home/benjamin/Projects/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex (lines 896-7 and lines 1862-1872) quantifies over all times. It is also important that the times are unrestricted in the definition of logical consequence in line 924 and 2273. Fix the lean source code to match the paper exactly.

---

## Medium Priority

### 459. Update Bimodal LaTeX Metalogic, Theorems, and Notes
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-13
- **Priority**: Medium
- **Language**: latex
- **Research**: [research-001.md](.claude/specs/459_update_bimodal_latex_metalogic_theorems_notes/reports/research-001.md)

**Description**: Update /home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/04-Metalogic.tex to include the decidability result and similarly update /home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/05-Theorems.tex and /home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/06-Notes.tex to include all recent progress made.

---

### 456. Address TODOs in Bimodal Semantics LaTeX
- **Effort**: 4 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: Medium
- **Language**: latex
- **Research**: [research-001.md](.claude/specs/456_address_todos_in_bimodal_semantics_latex/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/456_address_todos_in_bimodal_semantics_latex/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/456_address_todos_in_bimodal_semantics_latex/summaries/implementation-summary-20260113.md)

**Description**: Addressed all 20 TODO comments in 02-Semantics.tex: added primitives table for Task Frames, merged Respects Task into World History, replaced terminology with 'sentence letters', used x/y/z time variables, aligned time-shift notation with JPL paper, added perpetuity motivation, explicit types throughout.

---

### 455. Improve README extension layer descriptions
- **Effort**: 30 minutes
- **Status**: [COMPLETED]
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: Medium
- **Language**: general
- **Plan**: [implementation-001.md](.claude/specs/455_readme_extension_layer_descriptions/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/455_readme_extension_layer_descriptions/summaries/implementation-summary-20260113.md)

**Description**: Replaced terse bullet-point descriptions of Logos extension layers in README.md with expanded 2-3 sentence explanations covering operators (with Unicode symbols), semantic resources, and reasoning capabilities for each layer.

---

### 452. Use 'D' notation for duration group consistently
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: general

**Description**: Use 'D' instead of 'T' for the totally ordered commutative group of durations (also called times relative to a world history) consistently throughout the latex files in /home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/ and throughout the Lean Code in Logos/ to match the notation used in /home/benjamin/Projects/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex.

---

### 453. Add Ability and Free Choice Modal Extension to Logos
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean

**Description**: Building on task 451, add an extension layer for ability and free choice modals to the middle layer while also acknowledging that there are many other potential extensions that could be added to the middle layer. As with task 451, the aim is to characterize and create stubs in the lean code to match the 'Epistemic Extension' and other extension layers that remain to be developed, while nevertheless updating all the relevant documentation.

---

### 451. Add Reflection Extension to Logos layer extensions
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-12
- **Planned**: 2026-01-12
- **Completed**: 2026-01-12
- **Priority**: Medium
- **Language**: general
- **Research**: [research-001.md](.claude/specs/451_add_reflection_extension_to_logos_layer_extensions/reports/research-001.md), [research-002.md](.claude/specs/451_add_reflection_extension_to_logos_layer_extensions/reports/research-002.md)
- **Plan**: [implementation-001.md](.claude/specs/451_add_reflection_extension_to_logos_layer_extensions/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/451_add_reflection_extension_to_logos_layer_extensions/summaries/implementation-summary-20260112.md)

**Description**: Add 'Reflection Extension' for metacognition to the Logos layer extensions in /home/benjamin/Projects/ProofChecker/Theories/Logos/README.md, /home/benjamin/Projects/ProofChecker/Theories/Logos/docs/research/recursive-semantics.md, /home/benjamin/Projects/ProofChecker/Theories/Logos/docs/research/layer-extensions.md, /home/benjamin/Projects/ProofChecker/Theories/Logos/latex/LogosReference.tex, and /home/benjamin/Projects/ProofChecker/README.md where the 'Reflection Extension' follows the 'Agential Extension'.

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
 **Subtasks**: 444, 445, 446, 447, 448, 449, 450
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
- [ ] Lindenbaum lemma implemented
- [ ] Maximal consistent set properties proven
- [ ] Canonical frame constructed with frame properties
- [ ] Truth lemma proven
- [ ] Weak and strong completeness proven

**Impact**: Completes the metalogic foundation for TM logic by proving completeness, enabling derivability from validity.

---

### 444. Formula countability and set-list bridge
- **Effort**: 6-8 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-12
- **Planned**: 2026-01-12
- **Completed**: 2026-01-13
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 257
- **Research**: [research-001.md](.claude/specs/444_formula_countability_set_list_bridge/reports/research-001.md), [research-002.md](.claude/specs/444_formula_countability_set_list_bridge/reports/research-002.md)
- **Plan**: [implementation-001.md](.claude/specs/444_formula_countability_set_list_bridge/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/444_formula_countability_set_list_bridge/summaries/implementation-summary-20260112.md)

**Description**: Phase 1 of completeness proofs: Add Formula countability instances, refactor CanonicalWorldState from list-based to set-based, update canonical model signatures, remove unprovable list-based lindenbaum theorem.

---

### 445. Maximal consistent set properties
- **Effort**: 10-12 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-12
- **Planned**: 2026-01-12
- **Completed**: 2026-01-13
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 257
- **Dependencies**: 444
- **Research**: [research-001.md](.claude/specs/445_maximal_consistent_set_properties/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/445_maximal_consistent_set_properties/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/445_maximal_consistent_set_properties/summaries/implementation-summary-20260112.md)

**Description**: Phase 2 of completeness proofs: Prove key properties of maximal consistent sets. Prove maximal_consistent_closed, maximal_negation_complete, implication/conjunction/disjunction properties, modal and temporal saturation lemmas.

---

### 446. Agnostic duration construction
- **Effort**: 15-20 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 257
- **Dependencies**: 445
- **Research**: [research-001.md](.claude/specs/446_agnostic_duration_construction/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/446_agnostic_duration_construction/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/446_agnostic_duration_construction/summaries/implementation-summary-20260112.md)

**Description**: Implemented order-type based duration construction. Defined TemporalChain, ChainSegment, orderTypeEquiv setoid, PositiveDuration quotient with AddCommMonoid, Duration via Grothendieck construction with LinearOrder and IsOrderedAddMonoid instances. Some proofs use sorry (antisymmetry, totality).

---

### 447. Canonical frame and model construction
- **Effort**: 12-15 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 257
- **Dependencies**: 446
- **Research**: [research-001.md](.claude/specs/447_canonical_frame_model_construction/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/447_canonical_frame_model_construction/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/447_canonical_frame_model_construction/summaries/implementation-summary-20260113.md)

**Description**: Phase 4 of completeness proofs: Build canonical frame and model using agnostic Duration type. Define canonical_task_rel with modal/temporal transfer. Prove nullity and compositionality. Implement canonical_frame, canonical_valuation, canonical_model.

---

### 448. Build canonical_history
- **Effort**: 3-4 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 257
- **Dependencies**: 447
- **Research**: [research-001.md](.claude/specs/448_build_canonical_history/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/448_build_canonical_history/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/448_build_canonical_history/summaries/implementation-summary-20260113.md)

**Description**: Implemented canonical_history with singleton domain MVP. Domain contains only time 0, with convexity trivially satisfied and task relation respect proven via canonical_nullity. Temporal operators will be vacuously true at time 0. Extension to full domain possible if Task 449 requires non-trivial temporal witnesses.

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
