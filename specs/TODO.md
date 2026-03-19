---
next_project_number: 997
repository_health:
  overall_score: 92
  production_readiness: improved
  last_assessed: 2026-03-19T00:00:00Z
task_counts:
  active: 10
  completed: 686
  in_progress: 1
  not_started: 3
  abandoned: 45
  total: 745
technical_debt:
  sorry_count: 16
  sorry_count_note: "Excluding Boneyard: 3 wiring (FrameConditions/Completeness), 13 examples"
  publication_path_sorries: 0
  axiom_count: 3
  axiom_count_note: "canonicalR_irreflexive_axiom (justified per task 991), discrete_Icc_finite_axiom (documented debt from task 979), discreteImmediateSuccSeed_consistent_axiom (justified per task 991)"
  build_errors: 0
  status: excellent
---

# TODO

## Tasks
### 993. Add stability operator to bimodal formula language
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Language**: lean

**Description**: Add the stability operator (box-dot) to the bimodal formula language. The stability operator quantifies over histories passing through the same world state at a given time: (box-dot)phi at (alpha, t) holds iff phi holds at (beta, t) for all beta in Omega with beta(t) = alpha(t). Requires: (1) extend Formula inductive type with stability constructor, (2) define semantics in TaskModel, (3) add S5(box-dot) axiom schemas (T, 4, B, K), (4) prove box implies box-dot (absorption), (5) prove box-dot commutes with box but NOT with G/H. Per research-002 Section 6: box-dot and G have no valid interaction axioms due to genuine branching.

---

### 992. Implement Shift-Closed Tense S5 Algebra representation theorem
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Language**: lean
- **Research**: [01_stsa-algebraic-analysis.md](992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md)

**Description**: Implement the Shift-Closed Tense S5 Algebra (STSA) representation theorem. Define STSA as a Lean structure extending BooleanAlgebra with box, G, H, sigma operators and interaction axioms. Lift temporal duality sigma from swap_temporal to the Lindenbaum quotient. Prove LindenbaumAlg is an STSA instance by wiring existing pieces (BooleanStructure, InteriorOperators, UltrafilterMCS). Restructure ParametricRepresentation into unified STSA representation theorem. Research report 001 provides complete algebraic analysis with ~80% of formalization already existing.

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

### 981. Remove axiom technical debt from task 979
- **Effort**: 4-6 hours (4 phases)
- **Status**: [RESEARCHED]
- **Language**: lean
- **Depends On**: Task 978 [COMPLETED]
- **Research**: [31_team-research.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/31_team-research.md) (team research: density produces wrong formula, clean sorry recommended), [29_teammate-a-findings.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/29_teammate-a-findings.md), [29_teammate-b-findings.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/29_teammate-b-findings.md), [30_synthesis-big-picture.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/30_synthesis-big-picture.md)
- **Plan**: [13_coverage-based-approach.md](specs/981_remove_axiom_technical_debt_from_task_979/plans/13_coverage-based-approach.md) (v13: Coverage-based - prove dovetailed_covers_reachable by induction on CanonicalR chain length)

**Description**: Task 979 incurred technical debt (accepting an axiom temporarily). After completing the systematic refactor in task 978, research the problem deeply, implement the mathematically correct solution, and remove the axiom to yield a debt-free repository.

**Plan Summary (v13)**: 4-phase coverage-based approach. Phase 1: Define CanonicalR_chain reachability. Phase 2: Prove dovetailed_covers_reachable (by induction on chain length, NOT formula depth). Phase 3: Derive forward_F/backward_P from coverage theorem. Phase 4: Cleanup and verification. Key insight: induction on CanonicalR chain length avoids the formula depth measure problem entirely.

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

