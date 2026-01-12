---
last_updated: 2026-01-12T19:00:00Z
next_project_number: 439
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-11T21:30:00Z
task_counts:
  active: 17
  completed: 113
  in_progress: 1
  not_started: 7
  abandoned: 7
  total: 137
priority_distribution:
  critical: 0
  high: 5
  medium: 3
  low: 9
technical_debt:
  sorry_count: 19
  axiom_count: 11
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

### 437. Improve README consistency with recursive-semantics.md
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-01-12
- **Researched**: 2026-01-12
- **Planned**: 2026-01-12
- **Priority**: High
- **Language**: general
- **Research**: [research-001.md](.claude/specs/437_improve_readme_consistency_with_recursive_semantics/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/437_improve_readme_consistency_with_recursive_semantics/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/437_improve_readme_consistency_with_recursive_semantics/summaries/implementation-summary-20260112.md)

**Description**: Improve /home/benjamin/Projects/ProofChecker/README.md for consistency and clarity with the recursive-semantics.md documentation (/home/benjamin/Projects/ProofChecker/Theories/Logos/docs/research/recursive-semantics.md) which provides an authoritative overview of the base layer and various extensions. Reduce redundancy by presenting layer extensions only once in a high-quality way. Fix any internal discrepancies in README.md. Emphasize the parallel development of Logos in the ModelChecker, including a link to https://github.com/benbrastmckie/ModelChecker where appropriate.

---

### 432. Systematic agent system overhaul for robustness
- **Effort**: 11-17 hours
- **Status**: [PLANNED]
- **Researched**: 2026-01-12
- **Planned**: 2026-01-12
- **Priority**: High
- **Language**: meta
- **Research**: [research-001.md](.claude/specs/432_fix_artifact_linking_in_todo_and_state/reports/research-001.md), [research-002.md](.claude/specs/432_fix_artifact_linking_in_todo_and_state/reports/research-002.md), [research-003.md](.claude/specs/432_fix_artifact_linking_in_todo_and_state/reports/research-003.md), [research-004.md](.claude/specs/432_fix_artifact_linking_in_todo_and_state/reports/research-004.md), [research-005.md](.claude/specs/432_fix_artifact_linking_in_todo_and_state/reports/research-005.md)
- **Plan**: [implementation-001.md](.claude/specs/432_fix_artifact_linking_in_todo_and_state/plans/implementation-001.md)

**Description**: Systematic overhaul of the .claude/ agent system to improve robustness and uniformity while maintaining efficiency. Implementation priorities (from research-001 through research-005):

**Architecture Changes:**
- Introduce Checkpoint-Based Execution Model with three gates: GATE IN (preflight), GATE OUT (postflight), COMMIT (finalize)
- Unify all status updates through skill-status-sync (eliminate inline jq in commands)
- Implement tiered progressive context loading: Commands ~200 tokens (routing), Skills ~300 tokens (validation), Agents ~10k+ tokens (execution)
- Standardize plan-file-as-checkpoint pattern across all implementer agents (phase markers + git commits)

**Key Fixes (High Priority):**
- Add idempotency check (grep) before artifact linking
- Implement 5-stage artifact lifecycle: created → validated → registered → linked → committed
- Add session_id to git commit messages for traceability

**Design Decisions:**
- Phase-level checkpointing only (no sub-phase recovery)
- Schema-only validation at GATE OUT (no quality review agents)
- Human-in-the-loop at command boundaries provides quality control

**Enhancements (Medium Priority):**
- Extend errors.json with context, trajectory, and recovery fields
- Add error pattern aggregation for /errors command
- Use "Context Pointers" pattern instead of @-references in skills

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

### 438. Refactor Bimodal README for systematic documentation
- **Effort**: 2-3 hours
- **Status**: [PLANNING]
- **Researched**: 2026-01-12
- **Priority**: Medium
- **Language**: general
- **Research**: [research-001.md](.claude/specs/438_refactor_bimodal_readme/reports/research-001.md)

**Description**: Refactor Theories/Bimodal/README.md to provide a more systematic account of the Bimodal/ theory including a basic outline of its syntax, semantics, proof theory, and metalogic while also linking the BimodalReference.pdf and BimodalReference.tex for a more complete reference.

---

### 431. Module Aggregator Standard for Bimodal/
- **Effort**: 2.5 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-01-12
- **Researched**: 2026-01-12
- **Planned**: 2026-01-12
- **Priority**: Medium
- **Language**: lean
- **Research**: [research-001.md](.claude/specs/435_module_aggregator_standard_bimodal/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/435_module_aggregator_standard_bimodal/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/435_module_aggregator_standard_bimodal/summaries/implementation-summary-20260112.md)

**Description**: Systematically and uniformly improve the Module Aggregator Standard throughout the Bimodal/ theory following best practices for Lean 4 implementation.

---

### 433. Refine README title and consolidate Bimodal documentation
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-01-12
- **Researched**: 2026-01-12
- **Planned**: 2026-01-12
- **Priority**: Medium
- **Language**: general
- **Research**: [research-001.md](.claude/specs/433_refine_readme_title_and_bimodal_section/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/433_refine_readme_title_and_bimodal_section/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/433_refine_readme_title_and_bimodal_section/summaries/implementation-summary-20260112.md)

**Description**: Refine documentation from task 430. Change README.md title to 'Logos: A Logic for Interpreted and Verified AI Reasoning' (from LogosReference.tex). Create new `docs/research/bimodal-logic.md` titled "A Bimodal Logic for Tense and Modality" as the authoritative Bimodal presentation, replacing `theory-comparison.md`. Condense the Bimodal section in README.md to a brief summary with link. Update all 20+ cross-references across the codebase.

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

### 430. Refactor documentation to present ProofChecker as general framework
- **Effort**: 3-4 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-01-12
- **Researched**: 2026-01-12
- **Planned**: 2026-01-12
- **Priority**: Medium
- **Language**: general
- **Research**: [research-001.md](.claude/specs/430_refactor_documentation_general_framework/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/430_refactor_documentation_general_framework/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/430_refactor_documentation_general_framework/summaries/implementation-summary-20260112.md)

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
- **Effort**: 16-22 hours (actual: ~3 hours)
- **Status**: [COMPLETED]
- **Started**: 2026-01-05
- **Researched**: 2026-01-12
- **Planned**: 2026-01-12 (v002)
- **Completed**: 2026-01-12
- **Priority**: Medium
- **Language**: lean
- **Blocking Resolved**: Yes (via Direct Refactor)
- **Dependencies**: None
- **Research**: [research-001.md](.claude/specs/260_proof_search/reports/research-001.md), [research-002.md](.claude/specs/260_proof_search/reports/research-002.md), [research-003.md](.claude/specs/260_proof_search/reports/research-003.md), [research-004.md](.claude/specs/260_proof_search/reports/research-004.md)
- **Plan (Current)**: [implementation-002.md](.claude/specs/260_proof_search/plans/implementation-002.md) (Direct Refactor approach)
- **Plan (Superseded)**: [implementation-001.md](.claude/specs/260_proof_search/plans/implementation-001.md) (AxiomWitness pattern - abandoned)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/260_proof_search/summaries/implementation-summary-20260112.md)

**Description**: Implement automated proof search for TM logic with proof term construction using Direct Refactor approach (Axiom: Prop -> Type).

**Plan v002 Summary** (Direct Refactor approach per research-004):

| Phase | Description | Hours | Status |
|-------|-------------|-------|--------|
| 1 | Axiom Refactor (Prop -> Type) | 1 | [COMPLETED] |
| 2 | Proof Term Construction | 6-8 | [COMPLETED] |
| 3 | Tactic Integration (optional) | 4-6 | [DEFERRED] |
| 4 | BFS Variant (optional) | 3-4 | [DEFERRED] |
| 5 | Testing and Validation | 2-3 | [COMPLETED] |

**Implementation Highlights**:
- Changed `Axiom : Formula -> Prop` to `Axiom : Formula -> Type` with zero breaking changes
- Implemented `matchAxiom` function returning `Option (Sigma Axiom)` for all 14 axiom patterns
- Implemented `bounded_search_with_proof` returning actual `DerivationTree` proof terms
- All metalogic modules (Soundness, SoundnessLemmas, Completeness, DeductionTheorem) compile unchanged

**Acceptance Criteria**:
- [ ] Axiom changed from Prop to Type
- [ ] `deriving Repr, DecidableEq` added to Axiom
- [ ] `matchAxiom : Formula -> Option (Sigma Axiom)` implemented
- [ ] `bounded_search_with_proof` returns `DerivationTree`
- [ ] Existing metalogic proofs (Soundness, SoundnessLemmas) compile unchanged
- [ ] Tests verify proof term validity

**Impact**: Enables automated proof discovery returning actual proof terms for TM logic, suitable for both metalogic proofs and AI training signals.

---

## Low Priority

### 257. Completeness Proofs

 **Effort**: 57-76 hours (revised down from 70-90)
 **Status**: [RESEARCHING]
 **Researched**: 2026-01-12
 **Priority**: Low
 **Language**: lean
 **Blocking**: None (Decidability complete)
 **Dependencies**: Soundness (Complete), Deduction Theorem (Complete), Proof Search (Complete), Decidability (Complete)
 **Research**: [research-001.md](.claude/specs/257_completeness_proofs/reports/research-001.md), [research-002.md](.claude/specs/257_completeness_proofs/reports/research-002.md)

**Description**: Implement the completeness proof for TM logic using the canonical model method. The infrastructure (types and axiom statements) is present in `Theories/Bimodal/Metalogic/Completeness.lean`. Research-002 analyzes impact of completed tasks 260 (Proof Search) and 261 (Decidability) - both provide new tooling that reduces effort estimate.

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
- **Effort**: 40-50 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-01-12
- **Researched**: 2026-01-12
- **Planned**: 2026-01-12
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Research**: [research-001.md](.claude/specs/261_decidability/reports/research-001.md), [research-002.md](.claude/specs/261_decidability/reports/research-002.md)
- **Plan**: [implementation-001.md](.claude/specs/261_decidability/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260112.md](.claude/specs/261_decidability/summaries/implementation-summary-20260112.md)

**Description**: Implement decision procedures for TM logic using finite model property and tableau methods. Research-002 analyzes implications of the Type-based axiom refactor from task 260, enabling direct proof term construction in decision procedures.

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
