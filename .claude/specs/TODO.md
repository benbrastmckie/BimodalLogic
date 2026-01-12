---
last_updated: 2026-01-12T22:00:00Z
next_project_number: 433
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-11T21:30:00Z
task_counts:
  active: 14
  completed: 105
  in_progress: 0
  not_started: 11
  abandoned: 7
  total: 126
priority_distribution:
  critical: 0
  high: 3
  medium: 1
  low: 10
technical_debt:
  sorry_count: 19
  axiom_count: 11
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

### 432. Fix artifact linking in TODO.md and state.json
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta

**Description**: After running `/implement 429`, the summary was not linked in task 429's TODO.md entry. Identify the root cause and fix this and any similar issues throughout the agent system to ensure that artifacts (research reports, plans, summaries) are appropriately appended to tasks in TODO.md and in state.json once they are created.

---

### 429. Extend command-skill-agent integration to /meta
- **Effort**: 3.5 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-01-12
- **Researched**: 2026-01-12
- **Planned**: 2026-01-12
- **Priority**: High
- **Language**: meta
- **Research**: [research-001.md](.claude/specs/429_extend_command_skill_agent_integration_to_meta/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/429_extend_command_skill_agent_integration_to_meta/plans/implementation-001.md)

**Description**: Extend the command-skill-agent integration approach (established in task 427) to /meta. Create `skill-meta` and `meta-builder-agent` following the thin wrapper pattern. Refactor `/meta` command to delegate to skill instead of direct execution. Maintain backward compatibility with all three modes (interactive, prompt, analyze).

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

### 431. WezTerm tab color notification for Claude Code input needed
- **Effort**: 2-3 hours
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-12
- **Priority**: Medium
- **Language**: general
- **Research**: [research-001.md](.claude/specs/431_wezterm_tab_color_notification/reports/research-001.md)

**Description**: Set up WezTerm tab color notification when Claude Code needs input. Using Claude Code in neovim via a plugin and WezTerm for the terminal on NixOS (software managed in ~/.dotfiles/). Configure so that when Claude Code completes or needs input, the numbered tab in WezTerm turns a visible color to indicate which tabs need attention.

---

### 430. Refactor documentation to present ProofChecker as general framework
- **Effort**: 3-4 hours
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-12
- **Priority**: Medium
- **Language**: general
- **Research**: [research-001.md](.claude/specs/430_refactor_documentation_general_framework/reports/research-001.md)

**Description**: Refactor the ProofChecker documentation (README.md and docs/README.md) to present ProofChecker as a general framework for developing related theories for formal languages with semantics, proof theories, and metalogics. The project now supports two theories: the Bimodal/ theory for tense and modality (entirely intensional) and the Logos/ theory (hyperintensional foundation with layered extensions).

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

### 260. Proof Search
- **Effort**: 40-60 hours
- **Status**: [RESEARCHED]
- **Started**: 2026-01-05
- **Researched**: 2026-01-12
- **Priority**: Medium
- **Language**: lean
- **Blocking Resolved**: Yes (via AxiomWitness pattern)
- **Dependencies**: None
- **Research**: [research-001.md](.claude/specs/260_proof_search/reports/research-001.md), [research-002.md](.claude/specs/260_proof_search/reports/research-002.md), [research-003.md](.claude/specs/260_proof_search/reports/research-003.md)
- **Plan**: [Implementation Plan](.claude/specs/260_proof_search/plans/implementation-001.md)
- **Implementation**: [Implementation Summary](.claude/specs/260_proof_search/summaries/implementation-summary-20260105.md)

**Description**: Implement automated proof search for TM logic with proof term construction.

**Blocking Resolution** (research-003 definitive analysis): AxiomWitness pattern is definitively recommended:
1. Existing metalogic proofs (Soundness, SoundnessLemmas) use `cases` on Axiom producing Prop results - unaffected by Axiom universe
2. Proof irrelevance for Axiom is never used in the codebase
3. AI training requires verifiable DerivationTree objects, not Axiom constructor identity
4. AxiomWitness preserves semantic distinction between "is an axiom" (Prop) and "specific axiom construction" (Type)

**Recommended Approach**:
1. Create `AxiomWitness` inductive in `Type` mirroring all 14 axiom constructors
2. Add `AxiomWitness.toAxiom` conversion function for soundness
3. Implement `matchAxiomWitness : Formula -> Option (Sigma AxiomWitness)`
4. Update `bounded_search` to return `Option (DerivationTree Gamma phi)`

**Files**:
- `Theories/Bimodal/Automation/ProofSearch.lean`
- `Theories/Bimodal/ProofSystem/Axioms.lean` (add AxiomWitness)

**Acceptance Criteria**:
- [ ] AxiomWitness type created with all 14 constructors
- [ ] matchAxiomWitness function implemented
- [ ] Proof search returns DerivationTree (not just Bool)
- [ ] Tests verify proof term validity
- [ ] Documentation updated

**Impact**: Enables automated proof discovery returning actual proof terms for TM logic, suitable for both metalogic proofs and AI training signals.

---

## Low Priority

### 257. Completeness Proofs

 **Effort**: 70-90 hours
 **Status**: [RESEARCHED]
 **Researched**: 2026-01-12
 **Priority**: Low
 **Language**: lean
 **Blocking**: Decidability
 **Dependencies**: Soundness (Complete), Deduction Theorem (Complete)
 **Research**: [research-001.md](.claude/specs/257_completeness_proofs/reports/research-001.md)

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

### 261. Decidability
- **Effort**: 40-60 hours
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-11
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Research**: [research-001.md](.claude/specs/261_decidability/reports/research-001.md)

**Description**: Implement decision procedures for TM logic using finite model property and tableau methods.

**Research Findings**:
- TM bimodal logic (S5 modal + linear temporal) is decidable via finite model property
- Tableau-based satisfiability checking provides countermodels for invalid formulas
- Existing proof search infrastructure (ProofSearch.lean, 1085 lines) provides foundation
- Verified decision procedures for modal K/KT/S4 exist in Lean (Wu & Gore)

**Action Items**:
1. Prove finite model property for TM logic (modal filtration + temporal unraveling)
2. Implement signed formula tableau rules for all connectives
3. Prove tableau termination and completeness
4. Implement decision procedure returning proof or countermodel
5. Integrate with existing proof search

**Files**:
- `Bimodal/Metalogic/Decidability/FMP.lean` (finite model property)
- `Bimodal/Metalogic/Decidability/Tableau.lean` (tableau rules)
- `Bimodal/Metalogic/Decidability/DecisionProcedure.lean` (main procedure)

**Acceptance Criteria**:
- [ ] Finite model property proved for TM logic
- [ ] Tableau method implemented with termination proof
- [ ] Decision procedure returns `DecisionResult` (valid proof or countermodel)
- [ ] Tests verify validity of axiom schemata
- [ ] Tests verify countermodel construction for invalid formulas

**Impact**: Provides complete algorithmic decision procedures for TM logic validity and satisfiability with formal correctness proofs.

---

### 132. Prove Lindenbaum maximal consistency lemma in Completeness.lean
- **Effort**: 3 hours
- **Status**: [ON HOLD]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Note**: On hold pending Bimodal polish (Task 360)
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
- **Status**: [ON HOLD]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 132
- **Note**: On hold pending Bimodal polish (Task 360)
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
