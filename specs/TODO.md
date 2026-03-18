---
next_project_number: 992
repository_health:
  overall_score: 92
  production_readiness: improved
  last_assessed: 2026-03-16T23:45:00Z
task_counts:
  active: 11
  completed: 686
  in_progress: 1
  not_started: 2
  abandoned: 42
  total: 743
technical_debt:
  sorry_count: 16
  sorry_count_note: "Excluding Boneyard: 3 wiring (FrameConditions/Completeness), 13 examples"
  publication_path_sorries: 0
  axiom_count: 1
  axiom_count_note: "discrete_Icc_finite_axiom (documented debt from task 979)"
  build_errors: 0
  status: excellent
---

# TODO

## Tasks
### 991. Irreflexive semantics refactoring and STSA representation theorem
- **Effort**: TBD
- **Status**: [PLANNED]
- **Language**: lean
- **Research**: [research-001.md](991_temporal_algebraic_representation/reports/research-001.md), [research-002.md](991_temporal_algebraic_representation/reports/research-002.md), [research-003-irreflexive-refactoring-plan.md](991_temporal_algebraic_representation/reports/research-003-irreflexive-refactoring-plan.md)
- **Plan**: [01_irreflexive-semantics-refactoring.md](991_temporal_algebraic_representation/plans/01_irreflexive-semantics-refactoring.md)

**Description**: Refactor the ProofChecker codebase from reflexive (≤/≥) to irreflexive (</>)
temporal semantics, and build a Shift-Closed Tense S5 Algebra (STSA) representation theorem. Under current reflexive semantics, density/seriality/discreteness axioms are trivially valid on all frames, making parametric representation theorems for distinct frame classes impossible. Switching to irreflexive semantics makes these axioms genuinely characterize their respective frame classes, simplifies the codebase (eliminates the ~1200-line Gabbay IRR proof, removes reflexive case branches), and enables a clean algebraic variety representation theorem. Research report 003 provides a complete file-by-file change specification.

---

### 990. Research representation theorem design for parametric durations
- **Effort**: 6 hours
- **Status**: [COMPLETED]
- **Language**: formal
- **Research**: [01_teammate-a-findings.md](990_representation_theorem_duration_design/reports/01_teammate-a-findings.md), [01_teammate-b-findings.md](990_representation_theorem_duration_design/reports/01_teammate-b-findings.md), [02_synthesis.md](990_representation_theorem_duration_design/reports/02_synthesis.md)
- **Plan**: [01_parametric-duration-architecture.md](990_representation_theorem_duration_design/plans/01_parametric-duration-architecture.md)
- **Summary**: [01_architecture-decision-summary.md](990_representation_theorem_duration_design/summaries/01_architecture-decision-summary.md)
- **Started**: 2026-03-17
- **Completed**: 2026-03-17

**Description**: Research how representation theorems for TM base logic and its dense/discrete extensions should handle durations D. The key question: should D be constructed from pure syntax, or should D be parametric with axioms (density, discreteness, or linear commutative group) constraining its structure? Conduct systematic research into existing results in modal logic completeness (algebraic and Henkin-style approaches) to inform the mathematically correct design, then implement the recommended architecture.

---

### 989. Discrete algebraic completeness
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Language**: lean

**Description**: Prove discrete algebraic completeness using D = Int. Requires: (1) proving DF and DP axioms are valid in `DiscreteCanonicalTaskFrame Int` (the G-operator Stone relation on Int-indexed MCS families satisfies immediate successor conditions), (2) using the BFMCS construction from task 986 for the discrete proof system, (3) wiring `discrete_representation_conditional` to obtain `valid_discrete φ → ⊢_discrete φ`. Does not overlap with task 981 (which removes an axiom from the staged construction; this uses the algebraic D = Int approach).

---

### 988. Dense algebraic completeness
- **Effort**: 16 hours (4 phases)
- **Status**: [IMPLEMENTING]
- **Language**: lean
- **Research**: [research-001.md](specs/988_dense_algebraic_completeness/reports/research-001.md), [research-002.md](specs/988_dense_algebraic_completeness/reports/research-002.md), [research-003.md](specs/988_dense_algebraic_completeness/reports/research-003.md), [research-004.md](specs/988_dense_algebraic_completeness/reports/research-004.md), [research-005.md](specs/988_dense_algebraic_completeness/reports/research-005.md), [06_team-research.md](specs/988_dense_algebraic_completeness/reports/06_team-research.md)
- **Plan**: [06_representation-theorem-path.md](specs/988_dense_algebraic_completeness/plans/06_representation-theorem-path.md) (v6: Fix sorries, transport, wire)
- **Handoff**: [phase-1-handoff-20260317.md](specs/988_dense_algebraic_completeness/handoffs/phase-1-handoff-20260317.md)
- **Summary**: [implementation-summary-20260317.md](specs/988_dense_algebraic_completeness/summaries/implementation-summary-20260317.md), [02_implementation-summary.md](specs/988_dense_algebraic_completeness/summaries/02_implementation-summary.md) (v4 plan blocked), [03_sorry-analysis-summary.md](specs/988_dense_algebraic_completeness/summaries/03_sorry-analysis-summary.md) (v6 plan blocked)

**Plan v6 approach**: Use `dense_representation_conditional` directly. The 4 sorries in ClosureSaturation.lean (lines 659, 664, 679, 724) are the only blockers. Fix them -> transport via `cantor_isomorphism : TimelineQuot ~=o Rat` -> wire into representation theorem.

**Description**: Prove dense algebraic completeness using D = Rat. Requires: (1) a sorry-free BFMCS construction over Rat (adapting the Int construction with density-exploiting witness placement), (2) proving the DN axiom is valid in `DenseCanonicalTaskFrame Rat` (Rat's density gives the required intermediate witnesses), (3) wiring `dense_representation_conditional` to obtain `valid_dense φ → ⊢_dense φ`. Does not overlap with task 982 (TimelineQuot approach).

---

### 987. Algebraic base completeness
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Language**: lean
- **Depends On**: Task 986
- **Research**: [research-001.md](specs/987_algebraic_base_completeness/reports/research-001.md)

**Description**: Wire algebraic base completeness: use the sorry-free BFMCS construction from task 986 as the `construct_bfmcs` argument to `parametric_algebraic_representation_conditional` (D = Int), then prove `valid φ → ⊢ φ`. Resolve any type mismatch between `CanonicalWorldState` and `ParametricCanonicalWorldState`. Create `AlgebraicBaseCompleteness.lean` with the closed completeness theorem.

**Research Summary**: Task 986 has 2 sorries (forward_F/backward_P) blocking direct wiring. CanonicalWorldState and ParametricCanonicalWorldState are identical; real mismatch is D=Int (needs AddCommGroup) vs D=CanonicalMCS (sorry-free but only Preorder). Two paths: (A) complete task 986 dovetailing, or (B) semantic equivalence via CanonicalMCS completeness.

---

### 985. Develop Lindenbaum-Tarski algebraic representation theorem approach
- **Effort**: 12 hours (6 phases)
- **Status**: [COMPLETED]
- **Completed**: 2026-03-17
- **Language**: logic
- **Research**: [research-001.md](specs/985_lindenbaum_tarski_representation_theorem/reports/research-001.md) (team: algebraic approach), [research-002.md](specs/985_lindenbaum_tarski_representation_theorem/reports/research-002.md) (TaskFrame-specific algebraic construction)
- **Plan**: [implementation-001.md](specs/985_lindenbaum_tarski_representation_theorem/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260316.md](specs/985_lindenbaum_tarski_representation_theorem/summaries/implementation-summary-20260316.md)

**Description**: Develop the purely algebraic Lindenbaum-Tarski approach to establishing a representation theorem for the base TM logic as well as both the dense and discrete extensions in parallel to the existing proof. Research how this should proceed, drawing on the existing completeness results for guidance.

**Completion Summary**: Implemented D-parametric Lindenbaum-Tarski algebraic representation theorem. Created 6 new Lean modules (ParametricCanonical, ParametricHistory, ParametricTruthLemma, ParametricRepresentation, DenseInstantiation, DiscreteInstantiation) with zero sorries.

---

### 984. Review and revise documentation to remove `.claude/` directory references
- **Effort**: 1.5 hours (4 phases)
- **Status**: [COMPLETED]
- **Completed**: 2026-03-17
- **Language**: general
- **Research**: [research-001.md](specs/984_review_docs_remove_claude_dir_references/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/984_review_docs_remove_claude_dir_references/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260316.md](specs/984_review_docs_remove_claude_dir_references/summaries/implementation-summary-20260316.md)

**Description**: Review and revise all documentation to remove references to the `.claude/` directory (now gitignored), while preserving references to Claude Code itself.

**Completion Summary**: Removed 17 `.claude/` references from 6 documentation files, deleted 75K-line export file. Claude Code product name preserved throughout.


### 983. Review decidability results and FMP for publication
- **Effort**: 48 hours (8 phases)
- **Status**: [COMPLETED]
- **Completed**: 2026-03-17
- **Language**: logic
- **Research**: [research-001.md](specs/983_review_decidability_fmp_completeness/reports/research-001.md) (team), [research-002.md](specs/983_review_decidability_fmp_completeness/reports/research-002.md) (Boneyard salvageability)
- **Plan**: [implementation-002.md](specs/983_review_decidability_fmp_completeness/plans/implementation-002.md) (v2: clean FMP from scratch, no bridges, unified naming)
- **Summary**: [implementation-summary-20260316.md](specs/983_review_decidability_fmp_completeness/summaries/implementation-summary-20260316.md)

**Description**: Review the decidability results that have been established, and what remains to be done to establish the FMP and all natural decidability results that we might aim to establish alongside soundness and completeness, researching and implementing any missing results at the highest level of quality for the purposes of publication.

**Completion Summary**: Proved FMP for TM bimodal logic using MCS-based filtration. Created 8 Lean modules with zero sorries and zero axioms. Key theorems: mcs_finite_model_property, fmp_contrapositive, fmp_completeness.

---

### 982. Wire dense completeness domain connection
- **Effort**: 22 hours (6 phases)
- **Status**: [COMPLETED]
- **Language**: lean
- **Priority**: high
- **Created**: 2026-03-16 (Review)
- **Completed**: 2026-03-17
- **Research**: [research-009.md](specs/982_wire_dense_completeness_domain_connection/reports/research-009.md) (W vs D), [research-013.md](specs/982_wire_dense_completeness_domain_connection/reports/research-013.md) (gap analysis), [15_team-research.md](specs/982_wire_dense_completeness_domain_connection/reports/15_team-research.md) (team analysis), [16_dovetailing-analysis.md](specs/982_wire_dense_completeness_domain_connection/reports/16_dovetailing-analysis.md) (dovetailing deep-dive), [17_blocker-resolution.md](specs/982_wire_dense_completeness_domain_connection/reports/17_blocker-resolution.md) (blocker resolution)
- **Plan**: [11_density-resolution.md](specs/982_wire_dense_completeness_domain_connection/plans/11_density-resolution.md) (v11: Density argument)
- **Summary**: [03_density-resolution-summary.md](specs/982_wire_dense_completeness_domain_connection/summaries/03_density-resolution-summary.md)

**Completion Summary**: Proved dense completeness via full dovetailing. Created DovetailedCoverage.lean with sorry-free has_future/has_past theorems using density argument (F^i formulas with unbounded encodings). Created DovetailedCompleteness.lean wiring to TimelineQuot-based completeness.

**Description**: Complete dense completeness using W/D separated TaskFrame architecture: W = CanonicalMCS (world states), D = TimelineQuot (durations). Witnesses exist in W, not necessarily in Range(h).

**Research Summary**: The semantics has TWO distinct components: W (world states) and D (durations). Previous approaches conflated these. With separation: D = TimelineQuot (linear order), W = CanonicalMCS (all MCSs). Modal witnesses exist in W, making staged construction edge cases irrelevant.

**Resolution Path**:
1. Verify semantics architecture supports W/D separation (Phase 1)
2. Build separated TaskFrame: D = TimelineQuot, W = CanonicalMCS (Phase 2)
3. Build WorldHistories h : D → W (Phase 3)
4. Prove truth lemma with witnesses in W (Phase 4)
5. Complete dense completeness theorem (Phase 5)

**Files to create/modify**:
- `Metalogic/Algebraic/SeparatedTaskFrame.lean` - NEW
- `Metalogic/Algebraic/SeparatedHistory.lean` - NEW
- `Metalogic/Algebraic/SeparatedTruthLemma.lean` - NEW
- `FrameConditions/Completeness.lean` - MODIFIED

---

### 981. Remove axiom technical debt from task 979
- **Effort**: 4-6 hours (6 phases)
- **Status**: [IMPLEMENTING]
- **Language**: lean
- **Depends On**: Task 978 [COMPLETED]
- **Research**: [research-001.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-001.md), [research-002.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-002.md) (team: constructive method path), [research-003.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-003.md) (team: blocker resolution), [research-004.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-004.md) (team: T-axiom path), [research-005.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-005.md) (blocker analysis), [research-006.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-006.md) (axiom elimination approaches), [research-007.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-007.md) (covering proof gap confirmed unfillable), [research-008.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-008.md) (world history discreteness - W=D equivalence), [research-009.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-009.md) (architectural clarity - W=D is simplification), [research-010.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-010.md) (team: W=D is fundamental error; correct W!=D architecture already exists; gap is FMCS TimelineQuot truth lemma)
- **Plan**: [07_timelinequot-truth-lemma.md](specs/981_remove_axiom_technical_debt_from_task_979/plans/07_timelinequot-truth-lemma.md) (v7: TimelineQuot truth lemma pivot)

**Description**: Task 979 incurred technical debt (accepting an axiom temporarily). After completing the systematic refactor in task 978, research the problem deeply, implement the mathematically correct solution, and remove the axiom to yield a debt-free repository.

**Plan Summary (v7)**: TimelineQuot Truth Lemma approach — pivots from failed W=D discrete covering to correct W≠D architecture. Phases: (1) Deprecate W=D constructs [NOT STARTED], (2) TimelineQuot FMCS construction [NOT STARTED], (3) Separated truth lemma [NOT STARTED], (4) Completeness wiring [NOT STARTED], (5) Axiom removal [NOT STARTED], (6) Documentation [NOT STARTED]. Prior v1-v6 plans archived as dead end (discrete covering approach).

---

### 953. Refactor proof system to bilateral system
- **Effort**: 55-90 hours
- **Status**: [RESEARCHED]
- **Language**: lean
- **Priority**: medium
- **Research**: [research-001.md](specs/953_refactor_proof_system_to_bilateral/reports/research-001.md), [research-002.md](specs/953_refactor_proof_system_to_bilateral/reports/research-002.md), [research-003.md](specs/953_refactor_proof_system_to_bilateral/reports/research-003.md)

**Description**: Refactor the TM proof system from a unilateral system (single judgment `Γ ⊢ φ`) to a bilateral system with dual judgments: acceptance (`Γ ⊢⁺ φ`) and rejection (`Γ ⊢⁻ φ`). The bilateral system makes the dual roles of assertion and denial explicit, with rules governing how acceptance and rejection interact across all connectives and operators. Key design: keep Formula type unchanged (Option A), add BilateralDeriv alongside existing DerivationTree with a proven equivalence bridge. Several current axioms (ex_falso, peirce, modal_t, temp_t_future, temp_t_past) become structural rules in the bilateral system. The existing signed formula infrastructure in the decidability module provides the blueprint.

**Research summary (research-003)**: Cost-benefit analysis recommends deferring bilateral refactor until higher-priority tasks (981: axiom debt, 951: completeness) progress. Benefits are primarily theoretical (assertion/denial duality, tableau alignment); existing unilateral system is adequate. Parallel-system approach (Option A) minimizes risk.

**Implementation approach**: Parallel bilateral system with equivalence bridge — not a replacement. Phase 1: bilateral infrastructure (BilateralContext, BilateralDeriv). Phase 2: prove equivalence with unilateral system. Phase 3: bilateral metalogic (MCS, FMCS, completeness). Phase 4: bilateral decidability integration.

---

### 949. Update Demo.lean for current bimodal logic state
- **Effort**: Small (~2 hours)
- **Status**: [PLANNING]
- **Language**: lean
- **Research**: [research-001.md](specs/949_update_demo_lean_bimodal_logic/reports/research-001.md)

**Description**: Update Theories/Bimodal/Examples/Demo.lean given the current state of the bimodal logic. The demo file should reflect the current API and showcase the working features of the bimodal logic implementation.

---

### 868. Reinstate lean-lsp MCP tools after GitHub issue resolution
- **Effort**: 1 hour
- **Status**: [BLOCKED]
- **Language**: meta
- **Created**: 2026-02-11
- **Blocked on**: lean-lsp-mcp issue #115 resolution

**Description**: Once lean-lsp-mcp issue #115 (server halts on lean_diagnostic_messages) is resolved, reinstate the blocked MCP tools. Follow the unblocking procedure: verify fix in repository, update package version, test tools manually, update blocked-mcp-tools.md to mark as UNBLOCKED, remove from CLAUDE.md blocked list, and restore documentation in mcp-tools-guide.md. Consider re-testing lean_file_outline as well since no specific open issue exists for it.

---

### 619. Migrate skills to native context:fork isolation
- **Effort**: 3 hours
- **Status**: [PLANNING]
- **Researched**: 2026-02-17
- **Language**: meta
- **Created**: 2026-01-19
- **Researched**: 2026-01-28
- **Planned**: 2026-01-19
- **Blocked on**: GitHub anthropics/claude-code #16803 (context:fork runs inline instead of forking)
- **Research**: [research-001.md](specs/archive/619_agent_system_architecture_upgrade/reports/research-001.md), [research-006.md](specs/archive/619_agent_system_architecture_upgrade/reports/research-006.md), [research-007.md](specs/619_agent_system_architecture_upgrade/reports/research-007.md)
- **Plan**: [implementation-002.md](specs/archive/619_agent_system_architecture_upgrade/plans/implementation-002.md)

**Description**: Migrate all delegation skills from manual Task tool invocation to native `context: fork` frontmatter. Skills to migrate: skill-researcher, skill-lean-research, skill-planner, skill-implementer, skill-lean-implementation, skill-latex-implementation, skill-meta. Implementation plan has 3 phases: (1) verify bug fix with test skill, (2) migrate skill-researcher as pilot, (3) migrate remaining skills. Current workaround (Task tool delegation) continues to work. **Unblock when**: GitHub #16803 is closed AND fix verified locally. Last checked: 2026-02-17 — still OPEN (v2.1.32).

