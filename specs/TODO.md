---
next_project_number: 990
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
### 989. Discrete algebraic completeness
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Language**: lean

**Description**: Prove discrete algebraic completeness using D = Int. Requires: (1) proving DF and DP axioms are valid in `DiscreteCanonicalTaskFrame Int` (the G-operator Stone relation on Int-indexed MCS families satisfies immediate successor conditions), (2) using the BFMCS construction from task 986 for the discrete proof system, (3) wiring `discrete_representation_conditional` to obtain `valid_discrete φ → ⊢_discrete φ`. Does not overlap with task 981 (which removes an axiom from the staged construction; this uses the algebraic D = Int approach).

---

### 988. Dense algebraic completeness
- **Effort**: 12-16 hours (5 phases)
- **Status**: [RESEARCHING]
- **Language**: lean
- **Research**: [research-001.md](specs/988_dense_algebraic_completeness/reports/research-001.md), [research-002.md](specs/988_dense_algebraic_completeness/reports/research-002.md), [research-003.md](specs/988_dense_algebraic_completeness/reports/research-003.md)
- **Plan**: [implementation-002.md](specs/988_dense_algebraic_completeness/plans/implementation-002.md) (v2: CanonicalQuot approach) [BLOCKED]
- **Handoff**: [phase-1-handoff-20260317.md](specs/988_dense_algebraic_completeness/handoffs/phase-1-handoff-20260317.md)
- **Summary**: [implementation-summary-20260317.md](specs/988_dense_algebraic_completeness/summaries/implementation-summary-20260317.md) (blocker analysis)

**Research Summary (v3 - Semantics Architecture)**: Semantics has TWO distinct components: W (world states) and D (durations). WorldHistory h: D → W is the fundamental object. Previous approaches import D (Rat/Int) which violates pure-syntax constraint. CanonicalMCS has witnesses but lacks order; TimelineQuot has order but lacks witnesses.

**Recommended Approach**: Quotient CanonicalMCS to get CanonicalQuot with BOTH properties (witnesses + order). Then apply Cantor theorem to get D ≃ Rat from syntax. This constructs both W and D purely from syntax, respecting the semantics architecture.

**Description**: Prove dense algebraic completeness using D = Rat. Requires: (1) a sorry-free BFMCS construction over Rat (adapting the Int construction with density-exploiting witness placement), (2) proving the DN axiom is valid in `DenseCanonicalTaskFrame Rat` (Rat's density gives the required intermediate witnesses), (3) wiring `dense_representation_conditional` to obtain `valid_dense φ → ⊢_dense φ`. Does not overlap with task 982 (TimelineQuot approach).

---

### 987. Algebraic base completeness
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Language**: lean
- **Depends On**: Task 986

**Description**: Wire algebraic base completeness: use the sorry-free BFMCS construction from task 986 as the `construct_bfmcs` argument to `parametric_algebraic_representation_conditional` (D = Int), then prove `valid φ → ⊢ φ`. Resolve any type mismatch between `CanonicalWorldState` and `ParametricCanonicalWorldState`. Create `AlgebraicBaseCompleteness.lean` with the closed completeness theorem.

---

### 986. BFMCS construction for D = Int (conditional)
- **Effort**: 2-3 hours (4 phases)
- **Status**: [PLANNED]
- **Language**: lean
- **Research**: [research-001.md](specs/986_bfmcs_construction_for_int/reports/research-001.md), [research-002.md](specs/986_bfmcs_construction_for_int/reports/research-002.md), [research-003.md](specs/986_bfmcs_construction_for_int/reports/research-003.md), [research-004.md](specs/986_bfmcs_construction_for_int/reports/research-004.md)
- **Plan**: [implementation-002.md](specs/986_bfmcs_construction_for_int/plans/implementation-002.md) (v2: Conditional approach)
- **Summary**: [implementation-summary-20260317.md](specs/986_bfmcs_construction_for_int/summaries/implementation-summary-20260317.md)
- **Module**: [IntBFMCS.lean](Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean)

**Description**: Provide CONDITIONAL BFMCS construction for D = Int. Research proved F/P coherence is mathematically impossible (Countability Obstruction: uncountable MCS space cannot be indexed by countable Int). Convert sorries to documented hypotheses, provide conditional algebraic representation. Algebraic path provides conditional completeness; D-from-syntax path provides sorry-free.

**Research Summary (v4)**: W (MCSes) and D (Int) are distinct semantic components. History h: D→W maps times to states. Countability obstruction is FUNDAMENTAL - accept algebraic/syntax split.

**Plan v2**: Document obstruction, convert sorries to hypotheses, wire conditional representation. Preserves G/H infrastructure from v1 (614 lines).

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
- **Effort**: 8-12 hours (5 phases)
- **Status**: [RESEARCHED]
- **Language**: lean
- **Priority**: high
- **Created**: 2026-03-16 (Review)
- **Research**: [research-009.md](specs/982_wire_dense_completeness_domain_connection/reports/research-009.md) (W vs D semantics architecture), [research-010.md](specs/982_wire_dense_completeness_domain_connection/reports/research-010.md) (FMP-based completeness path - **recommended**)
- **Plan**: [implementation-007.md](specs/982_wire_dense_completeness_domain_connection/plans/implementation-007.md) (v7: W/D separated architecture)
- **Summary**: [implementation-summary-20260317.md](specs/982_wire_dense_completeness_domain_connection/summaries/implementation-summary-20260317.md)

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
- **Effort**: 16-24 hours (5 phases)
- **Status**: [RESEARCHING]
- **Language**: lean
- **Depends On**: Task 978 [COMPLETED]
- **Research**: [research-001.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-001.md), [research-002.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-002.md) (team: constructive method path), [research-003.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-003.md) (team: blocker resolution), [research-004.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-004.md) (team: T-axiom path), [research-005.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-005.md) (blocker analysis), [research-006.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-006.md) (axiom elimination approaches)
- **Plan**: [implementation-005.md](specs/981_remove_axiom_technical_debt_from_task_979/plans/implementation-005.md) (v5: well-founded minimal successor)

**Description**: Task 979 incurred technical debt (accepting an axiom temporarily). After completing the systematic refactor in task 978, research the problem deeply, implement the mathematically correct solution, and remove the axiom to yield a debt-free repository.

**Plan Summary (v5)**: Well-Founded Minimal Successor approach — define succ(M) := min { K : MCS | CanonicalR M K } using well-ordering. Covering follows trivially from minimality. Phases: (1) Stage-indexed infrastructure [COMPLETED], (2) Well-ordering on DiscreteTimelineQuot, (3) Minimal successor definition, (4) Covering from minimality and axiom elimination.

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

