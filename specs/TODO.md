---
next_project_number: 982
repository_health:
  overall_score: 92
  production_readiness: improved
  last_assessed: 2026-03-16T23:30:00Z
task_counts:
  active: 5
  completed: 686
  in_progress: 1
  not_started: 0
  abandoned: 42
  total: 742
technical_debt:
  sorry_count: 22
  sorry_count_note: "Excluding Boneyard: 9 metalogic (non-publication), 13 examples"
  publication_path_sorries: 0
  axiom_count: 1
  axiom_count_note: "discrete_Icc_finite_axiom (documented debt from task 979)"
  build_errors: 0
  status: excellent
---

# TODO

## Tasks

### 981. Remove axiom technical debt from task 979
- **Effort**: 2-4 hours (typeclass modification)
- **Status**: [RESEARCHING]
- **Language**: lean
- **Depends On**: Task 978 [COMPLETED]
- **Research**: [research-001.md](specs/981_remove_axiom_technical_debt_from_task_979/reports/research-001.md)

**Description**: Task 979 incurred technical debt (accepting an axiom temporarily). After completing the systematic refactor in task 978, research the problem deeply, implement the mathematically correct solution, and remove the axiom to yield a debt-free repository.

**Research Summary**: Deep analysis confirms covering lemma is THE critical gap - all approaches reduce to it. DF creates existential F-obligations that can be witnessed by any MCS, not specifically immediate successors. Density proof template does not invert. Recommends accepting axiom as architectural constraint and making `LocallyFiniteOrder` an explicit requirement in `DiscreteTemporalFrame` typeclass.

---

### 953. Refactor proof system to bilateral system
- **Effort**: 55-90 hours
- **Status**: [PLANNING]
- **Language**: lean
- **Priority**: medium
- **Research**: [research-001.md](specs/953_refactor_proof_system_to_bilateral/reports/research-001.md)

**Description**: Refactor the TM proof system from a unilateral system (single judgment `Γ ⊢ φ`) to a bilateral system with dual judgments: acceptance (`Γ ⊢⁺ φ`) and rejection (`Γ ⊢⁻ φ`). The bilateral system makes the dual roles of assertion and denial explicit, with rules governing how acceptance and rejection interact across all connectives and operators. Key design: keep Formula type unchanged (Option A), add BilateralDeriv alongside existing DerivationTree with a proven equivalence bridge. Several current axioms (ex_falso, peirce, modal_t, temp_t_future, temp_t_past) become structural rules in the bilateral system. The existing signed formula infrastructure in the decidability module provides the blueprint.

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

