---
next_project_number: 986
repository_health:
  overall_score: 92
  production_readiness: improved
  last_assessed: 2026-03-16T23:45:00Z
task_counts:
  active: 7
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
- **Effort**: 12-16 hours (7 phases)
- **Status**: [IMPLEMENTING]
- **Language**: lean
- **Priority**: high
- **Created**: 2026-03-16 (Review)
- **Research**: [research-006.md](specs/982_wire_dense_completeness_domain_connection/reports/research-006.md) (axiom-free modal saturation)
- **Plan**: [implementation-004.md](specs/982_wire_dense_completeness_domain_connection/plans/implementation-004.md) (v4: closure-based saturation)

**Description**: Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics using closure-based modal saturation (axiom-free approach).

**Research Summary**: Singleton BFMCS is mathematically impossible (requires φ→□φ which is false). The correct approach: multi-family BFMCS with closure-based modal saturation. The `saturated_modal_backward` theorem derives modal_backward without axioms.

**Resolution Path**:
1. Build witness family constructor via CanonicalR-chains (Phase 3)
2. Implement closure saturation iteration (Phase 4)
3. Prove closure-aware truth lemma (Phase 5)
4. Complete the sorry (Phase 6)

**Files to create/modify**:
- `StagedConstruction/WitnessChainFMCS.lean` - NEW
- `StagedConstruction/ClosureSaturation.lean` - NEW
- `StagedConstruction/TimelineQuotCanonical.lean` - MODIFIED
- `StagedConstruction/TimelineQuotCompleteness.lean` - MODIFIED (sorry resolved)

---

### 981. Remove axiom technical debt from task 979
- **Effort**: 16-24 hours (revised)
- **Status**: [PARTIAL]
- **Language**: lean
- **Depends On**: Task 978 [COMPLETED]
- **Research**: [research-001.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-001.md), [research-002.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-002.md) (team: constructive method path), [research-003.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-003.md) (team: blocker resolution), [research-004.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-004.md) (team: T-axiom path), [research-005.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-005.md) (blocker analysis), [research-006.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-006.md) (axiom elimination approaches)
- **Plan**: [implementation-003.md](specs/981_remove_axiom_technical_debt_from_task_979/plans/implementation-003.md) (v3: needs revision)
- **Summary**: [implementation-summary-20260316.md](specs/981_remove_axiom_technical_debt_from_task_979/summaries/implementation-summary-20260316.md)

**Description**: Task 979 incurred technical debt (accepting an axiom temporarily). After completing the systematic refactor in task 978, research the problem deeply, implement the mathematically correct solution, and remove the axiom to yield a debt-free repository.

**Progress (3/6 phases)**: Phases 2-3 COMPLETED (seed consistency via T-axiom, discreteImmediateSucc definition). Phase 4 BLOCKED (blocking formula approach insufficient). Plan revision required.

**Research Summary (research-006)**: Identified 5 axiom elimination approaches. PRIMARY: Incremental/staged construction (16-24h) — make covering hold BY CONSTRUCTION through incremental model building. SECONDARY: Well-founded minimal successor (12-16h) — define successor as minimum of forward-accessible MCSs. Blocking formula approach abandoned (constrains W but not intermediate K).

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

