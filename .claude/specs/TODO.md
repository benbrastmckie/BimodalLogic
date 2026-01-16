---
last_updated: 2025-01-15T18:27:00Z
next_project_number: 512
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-11T21:30:00Z
task_counts:
  active: 20
  completed: 171
  in_progress: 2
  not_started: 10
  researched: 1
  abandoned: 14
  total: 206
priority_distribution:
  critical: 0
  high: 3
  medium: 8
  low: 9
technical_debt:
  sorry_count: 19
  axiom_count: 11
  build_errors: 0
  status: manageable
---

# TODO


---

## High Priority


### 394. Research and port causal semantics from paper
- **Effort**: 4-6 hours
- **Status**: [PLANNED]
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


### 510. Research mereological constraints
- **Effort**: 2-4 hours
- **Status**: [RESEARCHED]
- **Researched**: 2025-01-15
- **Priority**: Medium
- **Language**: lean
- **Research**: [research-001.md](.claude/specs/510_mereological_constraints_research/reports/research-001.md)

**Description**: Research on mereological constraints for predicate functions

### 511. Fix Task 512 Inconsistent Status
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-01-16
- **Priority**: High
- **Language**: meta
- **Research**: [research-001.md](.claude/specs/511_fix_task_512_status/reports/research-001.md)

**Description**: Investigate and fix inconsistent status issue for task 512 (task appears to be missing)

---

### 488. Fill remaining bridge lemmas
- **Effort**: 3-4 hours
- **Status**: [IMPLEMENTING]
- **Researched**: 2026-01-14
- **Planned**: 2026-01-14
- **Started**: 2026-01-14
- **Priority**: Medium
- **Language**: lean
- **Research**: [research-001.md](.claude/specs/488_fill_remaining_bridge_lemmas/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/488_fill_remaining_bridge_lemmas/plans/implementation-001.md)

**Description**: Fill the 6 remaining bridge lemma sorries in FiniteCanonicalModel.lean: finiteHistoryToWorldHistory.respects_task, semantic_world_state_has_world_history, glue_histories.forward_rel, glue_histories.backward_rel, and 2 in SemanticTaskRelV2.compositionality. These are type-level connections, not logical gaps.

---

### 489. Formal FMP theorem packaging
- **Effort**: 2-3 hours
- **Status**: [IMPLEMENTING]
- **Started**: 2026-01-14
- **Priority**: Medium
- **Language**: lean
- **Research**: [research-001.md](.claude/specs/489_formal_fmp_theorem_packaging/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/489_formal_fmp_theorem_packaging/plans/implementation-001.md)

**Description**: Create formal Finite Model Property theorem statement: ∀ φ, satisfiable φ → ∃ (M : FiniteModel), M ⊨ φ. Package existing semantic_weak_completeness proof into standard FMP format. Add documentation explaining bounds (temporal depth, modal depth).

---


### 475. Create skill-document-converter thin wrapper
- **Effort**: 1 hour
- **Status**: [NOT STARTED]
- **Priority**: Medium
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

### 470. Finite model computational optimization
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 458

**Description**: Optimize FiniteCanonicalModel.lean for computational efficiency. Current implementation prioritizes correctness over performance. Identify and implement optimizations for the finite world state enumeration, task relation checking, and truth evaluation.

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

### 503. Update LaTeX to use dependent-type conventions for Lean consistency
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: latex
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Theories/Logos/latex/*.tex (multiple files)
  - Theories/Logos/latex/subfiles/*.tex (multiple files)
- **Description**: Update LaTeX notation throughout the Logos documentation to use dependent-type conventions consistent with Lean 4. Replace set-theoretic notation with type-theoretic notation using ':' for typing instead of set membership. Keep notation simple and minimal for readability while avoiding explicit set ideology. Do NOT replace function application notation with indexed family notation - preserve standard function application f(t₁, ..., tₙ).
- **Acceptance Criteria**:
  - [ ] All set membership notation ∈ replaced with typing notation ':' where appropriate
  - [ ] Function application notation preserved as f(t₁, ..., tₙ)
  - [ ] Type annotations use consistent dependent-type syntax
  - [ ] No explicit set-theoretic language or ideology remains
  - [ ] LaTeX files compile successfully after changes
  - [ ] Notation remains readable and minimal
- **Impact**: Improves consistency between LaTeX documentation and Lean 4 formalization, removes set-theoretic bias while maintaining readability.

---

### 505. Add state constraint to n-place predicates in LaTeX
- **Effort**: 1 hour
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: latex
- **Files Affected**:
  - Theories/Logos/latex/subfiles/01-ConstitutiveFoundation.tex
- **Description**: Add constraint to lines 75-76 in 01-ConstitutiveFoundation.tex that the n input states must all be parts of the output state. This clarifies the relationship between input states and the resulting state in n-place predicate definitions.
- **Acceptance Criteria**:
  - [ ] Add constraint that n input states are parts of the output state
  - [ ] Modification made to lines 75-76 in the verifier/falsifier function type definitions
  - [ ] LaTeX file compiles successfully after changes
  - [ ] Mathematical notation is clear and consistent with existing style
- **Impact**: Improves formal precision of predicate semantics by explicitly stating the part-whole relationship between input and output states.
