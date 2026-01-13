---
last_updated: 2026-01-13T19:02:00Z
next_project_number: 487
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-01-11T21:30:00Z
task_counts:
  active: 22
  completed: 154
  in_progress: 2
  not_started: 12
  abandoned: 10
  total: 186
priority_distribution:
  critical: 0
  high: 3
  medium: 6
  low: 13
technical_debt:
  sorry_count: 19
  axiom_count: 11
  build_errors: 0
  status: manageable
---

# TODO

## High Priority

### 480. Investigate workflow delegation early stop issues
- **Effort**: 3-4 hours
- **Status**: [IMPLEMENTED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Implemented**: 2026-01-13
- **Priority**: High
- **Language**: meta
- **Research**: [research-001.md](.claude/specs/480_investigate_workflow_delegation_early_stop/reports/research-001.md)
- **Plan**: [implementation-002.md](.claude/specs/480_investigate_workflow_delegation_early_stop/plans/implementation-002.md)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/480_investigate_workflow_delegation_early_stop/summaries/implementation-summary-20260113.md)

**Description**: Investigate workflow delegation errors causing agents to stop early. Previous fix attempts (tasks 474, 467, 462) did not resolve the issue. Check `.claude/output/` for error patterns. Search for terms like "complete", "finished" etc. that might trigger Claude Code to stop early. Consult best practices for Claude Code agent systems and research similar errors online.

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

### 486. Add Abilities box to middle layer TikZ diagram
- **Effort**: 1-2 hours
- **Status**: [IMPLEMENTING]
- **Researched**: 2026-01-13
- **Priority**: Medium
- **Language**: latex
- **Research**: [research-001.md](.claude/specs/486_add_abilities_box_to_tikz_diagram/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/486_add_abilities_box_to_tikz_diagram/plans/implementation-001.md)

**Description**: Add free choice modals and ability modals to another Abilities box in the middle layer of the TikZ diagram in /home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/00-Introduction.tex and the Overview section of /home/benjamin/Projects/ProofChecker/README.md.

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

### 485. Create TikZ light-cone diagram for TM motivation
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: Medium
- **Language**: latex
- **Research**: [research-001.md](.claude/specs/485_tikz_light_cone_diagram_for_tm_motivation/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/485_tikz_light_cone_diagram_for_tm_motivation/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/485_tikz_light_cone_diagram_for_tm_motivation/summaries/implementation-summary-20260113.md)

**Description**: In line 13 of /home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/00-Introduction.tex, create a professional TikZ diagram to motivate the bimodal logic TM. The diagram should feature: (1) a curvy S-shaped arrow going from left to right and slightly from below to above, (2) a point marked with a dot along the S-curve, (3) a light-cone emanating from that point in both directions (past and future), (4) other intersecting arrows extending from the marked point that fit within the light-cones in both directions, (5) the portions of these intersecting arrows prior to the marked point should be dotted (representing past/counterfactual paths).

---

### 484. Sync TikZ diagram operators with GLOSSARY.md
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Revised**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: Medium
- **Language**: latex
- **Plan**: [implementation-002.md](.claude/specs/484_sync_tikz_diagram_operators_with_glossary/plans/implementation-002.md) (v002)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/484_sync_tikz_diagram_operators_with_glossary/summaries/implementation-summary-20260113.md)

**Description**: Use GLOSSARY.md to improve/expand the operators included in the TikZ diagram in 00-Introduction.tex. Ensure bidirectional sync: add any operators from the glossary missing in the TikZ diagram, and add any operators in the TikZ diagram that are missing from GLOSSARY.md.

**v002 Changes**: Epistemic box: remove K, add Pr, Mi, Mu, indicative conditional (↪). Normative box: add preference ordering and normative explanation. GLOSSARY.md: standardize indicative conditional to hook-right arrow (↪).

---

### 483. Investigate LaTeX aux file corruption errors
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: latex

**Description**: When making changes to LaTeX files (e.g., 00-Introduction.tex), rebuilding sometimes produces "File ended while scanning use of \@newl@bel" and "\@@BOOKMARK" errors, plus "Extra }, or forgotten \endgroup" errors in the .aux file. Identify the root cause (likely corrupted auxiliary files from interrupted builds) and document solutions to avoid these errors.

---

### 473. Fix compositionality gaps from Task 458
- **Effort**: 6-8 hours (reduced scope)
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: Medium
- **Language**: lean
- **Parent**: Task 458
- **Research**: [research-004.md](.claude/specs/473_fix_compositionality_gaps_task_458/reports/research-004.md)
- **Plan**: [implementation-004.md](.claude/specs/473_fix_compositionality_gaps_task_458/plans/implementation-004.md)
- **Summary**: [implementation-summary-20260113-final.md](.claude/specs/473_fix_compositionality_gaps_task_458/summaries/implementation-summary-20260113-final.md)

**Description**: Implemented Path A (Semantic History-Based World States). Defined SemanticWorldState as quotient of history-time pairs, making compositionality trivial by construction. Key achievement: reduced 8+ mathematically unprovable sorries (mixed-sign cases) to 2 constructible sorries (history gluing). All 6 phases completed, lake build succeeds.

---

### 481. Implement finite_history_from_state
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: Medium
- **Language**: lean
- **Parent**: Task 473
- **Research**: [research-001.md](.claude/specs/481_finite_history_from_state/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/481_finite_history_from_state/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/481_finite_history_from_state/summaries/implementation-summary-20260113.md)

**Description**: Implement `finite_history_from_state` to construct a FiniteHistory from any SemanticWorldState. This eliminates the nullity sorry in SemanticCanonicalFrame by proving that every world state has at least one witnessing history. Required for `SemanticCanonicalFrame.nullity` proof.

---

### 482. Implement history gluing lemma
- **Effort**: 4-5 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: Medium
- **Language**: lean
- **Parent**: Task 473
- **Research**: [research-001.md](.claude/specs/482_history_gluing_lemma/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/482_history_gluing_lemma/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/482_history_gluing_lemma/summaries/implementation-summary-20260113.md)

**Description**: Implemented history gluing lemma with glue_histories function and supporting lemmas (before_junction, at_junction, after_junction). Updated SemanticTaskRelV2.compositionality to use gluing construction. Lake build succeeds.

---

### 466. Add Reflection Extension to LogosReference
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: Medium
- **Language**: latex
- **Research**: [research-001.md](.claude/specs/466_reflection_extension_logosreference/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/466_reflection_extension_logosreference/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/466_reflection_extension_logosreference/summaries/implementation-summary-20260113.md)

**Description**: Added Reflection Extension content to LogosReference.tex. Updated Introduction TikZ diagram and layer descriptions. Added Truth Conditions, Derived Operators, and Temporal Interaction subsections to 09-Reflection.tex. Clean build verified (31 pages).

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
- **Effort**: 8-12 hours (reduced from 15-20)
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 257
- **Dependencies**: 448 (completed), 473 (completed), 481 (completed), 482 (completed)
- **Research**: [research-001.md](.claude/specs/449_truth_lemma/reports/research-001.md)
- **Plan**: [implementation-002.md](.claude/specs/449_truth_lemma/plans/implementation-002.md) (v002)
- **Summary**: [implementation-summary-20260113-phase3-4.md](.claude/specs/449_truth_lemma/summaries/implementation-summary-20260113-phase3-4.md)

**Description**: Phase 6 of completeness proofs: Complete truth lemma using SemanticWorldState infrastructure from Task 473. The semantic truth lemma (`semantic_truth_lemma_v2`) is proven. `semantic_weak_completeness` is proven (uses `mcs_projection_is_closure_mcs` which has one sorry for maximality). Connection to main completeness documented; formal bridging deferred to Task 450. Old `finite_truth_lemma` marked deprecated.

---

### 450. Completeness theorems
- **Effort**: 8-10 hours
- **Status**: [IMPLEMENTING]
- **Priority**: Low
- **Language**: lean
- **Parent**: Task 257
- **Dependencies**: 449, 481, 482
- **Research**: [research-001.md](.claude/specs/450_completeness_theorems/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/450_completeness_theorems/plans/implementation-001.md)

**Description**: Phase 7 of completeness proofs: Prove weak_completeness and strong_completeness using SemanticCanonicalModel from Task 473. Connect semantic_weak_completeness to main completeness theorem. Complete provable_iff_valid proof. Final cleanup to verify no axioms or sorry remain in Completeness.lean.

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

---

### 479. Fix TikZ extension dependencies diagram
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Researched**: 2026-01-13
- **Planned**: 2026-01-13
- **Completed**: 2026-01-13
- **Priority**: Medium
- **Language**: latex
- **Research**: [research-001.md](.claude/specs/479_fix_tikz_extension_dependencies_diagram/reports/research-001.md)
- **Plan**: [implementation-001.md](.claude/specs/479_fix_tikz_extension_dependencies_diagram/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260113.md](.claude/specs/479_fix_tikz_extension_dependencies_diagram/summaries/implementation-summary-20260113.md)

**Description**: The TikZ diagram in sec:extension-dependencies (line 21) of /home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/00-Introduction.tex does not match the diagram in the 'Overview' (line 7) of /home/benjamin/Projects/ProofChecker/README.md. Fix the TikZ diagram to match README.md layout. Requirements: (1) professional styling with rounded corners for boxes, (2) non-intersecting lines and labels, (3) middle layer extensions (Epistemic, Normative, Spatial) in a grey horizontal background box, (4) ellipses to left and right of middle layers to indicate extensibility, (5) explanatory text below the diagram.
