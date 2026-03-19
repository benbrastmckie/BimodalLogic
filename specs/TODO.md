---
next_project_number: 1000
repository_health:
  overall_score: 92
  production_readiness: improved
  last_assessed: 2026-03-19T00:00:00Z
task_counts:
  active: 12
  completed: 686
  in_progress: 0
  not_started: 6
  abandoned: 45
  total: 750
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

## Recommended Order

1. **995** → plan + implement (unblocks 988, 989, 997)
2. **996** → soundness wiring (independent, bounded)
3. **988** → dense completeness (after 995)
4. **989** → discrete completeness (after 988)
5. **997** → base completeness (after 995, simplest)
6. **999** → F→FF derivation (small, anytime)
7. **949** → update Demo.lean (small, anytime)
8. **992** → STSA representation theorem (after completeness)

## Tasks
### 999. Derive F(phi) → FF(phi) from density axiom
- **Effort**: TBD (estimated 2-4 hours)
- **Status**: [NOT STARTED]
- **Language**: lean4

**Description**: Prove the derivation of `F(φ) → FF(φ)` from the density axiom `GGψ → Gψ`. Two files have the same sorry with the same mathematical gap: (1) `derive_F_to_FF` in `StagedConstruction/CantorPrereqs.lean` (line 111) — needs a `DerivationTree` for `F(φ) → FF(φ)`; (2) `density_of_canonicalR` in `Canonical/CanonicalTimeline.lean` (line 183) — needs the same derivation to find an intermediate `CanonicalR` witness. The density axiom is `GGψ → Gψ` (universal form). The existential dual `F(φ) → FF(φ)` follows via contrapositive: `Fφ = ¬G¬φ`, `FFφ = ¬G¬Fφ = ¬GG¬φ`, so `Fφ → FFφ` is `¬G¬φ → ¬GG¬φ`, the contrapositive of `GGψ → Gψ` for `ψ = ¬φ`. The derivation chains through double-negation and temporal K-distribution. Both sorries are marked `TODO (Task 991)`. Fixing them completes the staged construction pipeline for density proofs.

---

### 998. Redesign FMP filtration for strict temporal semantics
- **Effort**: TBD (estimated 4-8 hours)
- **Status**: [NOT STARTED]
- **Language**: lean4

**Description**: Redesign the FMP (Finite Model Property) filtration for strict temporal semantics. The 2 sorry'd theorems in `Decidability/FMP/TruthPreservation.lean` — `mcs_all_future_closure` (line 263) and `mcs_all_past_closure` (line 281) — are deprecated because the temporal T-axiom (`Gφ → φ`) is NOT valid under strict semantics. `filtration_all_future_forward` and `filtration_all_past_forward` depend on them. The FMP module is separate from the main decidability pipeline (`decide` is sorry-free), but completing it formally proves the finite model property. Resolution options: (A) restrict FMP statement to serial frames where temporal seriality holds, (B) redesign filtration to avoid temporal reflexivity entirely, (C) prove the filtered model satisfies a weaker correctness property sufficient for the FMP theorem. Note: `mcs_finite_model_property` in `FMP.lean` does NOT directly use these sorry'd lemmas, so the impact is localized to `filtration_all_future_forward`/`backward`.

---

### 997. Wire algebraic base completeness using FMCS domain transfer
- **Effort**: TBD (estimated 2-4 hours)
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Depends On**: Task 995

**Description**: Wire the algebraic base completeness theorem using the FMCS domain transfer lemma (task 995). After task 995 provides the order-embedding `CanonicalMCS → Int`, fill the 2 sorries in `AlgebraicBaseCompleteness.lean` (lines 104, 155) to prove `valid φ → ⊢ φ` for base TM logic. The file already has the right structure: `construct_bfmcs_int` (via CanonicalMCS transfer) feeds `parametric_algebraic_representation_conditional` with `D = Int`. This supersedes abandoned task 987 and completes the base completeness leg of the three-way completeness suite (base/dense/discrete).

---

### 996. Wire soundness theorem assembly
- **Effort**: TBD (estimated 4-6 hours)
- **Status**: [NOT STARTED]
- **Language**: lean

**Description**: Wire the 6 remaining sorries in `Soundness.lean` (lines 565, 569, 572, 575, 595, 598) using the already-proven component theorems. The sorries cover: (1) density axiom validity — proven in `DenseSoundness.axiom_dense_valid`, (2) discreteness_forward validity — proven in `DiscreteSoundness.axiom_discrete_valid`, (3) seriality_future/past validity — proven in `DiscreteSoundness`, (4) temporal_duality rule — component proof in `SoundnessLemmas.axiom_swap_valid`, (5) IRR rule — needs product frame construction. The main challenge is that the soundness theorem quantifies over ALL D, but the extension axioms are only valid on frames with specific properties (DenselyOrdered, SuccOrder, etc.). Resolution: either restrict the soundness statement to appropriate frame classes, or use the `Axiom.frameClass` classification already defined in `Axioms.lean` (lines 477-497) to dispatch each axiom to its correct frame class.

---

### 995. FMCS domain transfer lemma
- **Effort**: TBD (estimated 8-12 hours)
- **Status**: [PLANNED]
- **Language**: lean
- **Priority**: high
- **Research**: [01_fmcs-domain-transfer.md](995_fmcs_domain_transfer_lemma/reports/01_fmcs-domain-transfer.md)
- **Plan**: [01_fmcs-domain-transfer.md](995_fmcs_domain_transfer_lemma/plans/01_fmcs-domain-transfer.md)

**Description**: Build a general FMCS transfer lemma: given an order-embedding `e : CanonicalMCS → D` (where D has `AddCommGroup + LinearOrder + IsOrderedAddMonoid`), transfer temporal coherence (forward_F, backward_P) from the sorry-free `CanonicalMCS`-based BFMCS to a `BFMCS D`. This is the single highest-leverage piece of work in the codebase. The CanonicalMCS construction (in `CanonicalFMCS.lean`) is fully proven with zero sorries for forward_F, backward_P, and modal saturation. The only remaining gap is that `CanonicalMCS` lacks `AddCommGroup`, so it cannot serve as D in `TaskFrame`. This transfer lemma bridges that gap and simultaneously unblocks: (1) base completeness (embed into ℤ), (2) dense completeness (embed into ℚ via Cantor), (3) discrete completeness (embed into ℤ with SuccOrder).

---

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
- **Status**: [BLOCKED]
- **Blocked on**: Task 995 (FMCS domain transfer lemma), Task 974 (SuccOrder instance)
- **Language**: lean

**Description**: Prove discrete algebraic completeness using D = Int. Requires: (1) FMCS domain transfer from CanonicalMCS to Int (task 995), (2) proving DF and DP axioms are valid in `DiscreteCanonicalTaskFrame Int` (the parametric canonical TaskFrame instantiated at Int), (3) SuccOrder instance on DiscreteTimelineQuot (task 974, archived), (4) wiring `discrete_representation_conditional` to obtain `valid_discrete φ → ⊢_discrete φ`. Note: `DiscreteInstantiation.lean` uses live parametric infrastructure (`ParametricCanonicalTaskFrame Int`), not the deprecated `DiscreteTimeline.discreteCanonicalTaskFrame`.

---

### 988. Dense algebraic completeness
- **Effort**: 16 hours (4 phases)
- **Status**: [BLOCKED]
- **Blocked on**: Task 995 (FMCS domain transfer lemma)
- **Language**: lean
- **Research**: [research-001.md](specs/988_dense_algebraic_completeness/reports/research-001.md), [research-002.md](specs/988_dense_algebraic_completeness/reports/research-002.md), [research-003.md](specs/988_dense_algebraic_completeness/reports/research-003.md), [research-004.md](specs/988_dense_algebraic_completeness/reports/research-004.md), [research-005.md](specs/988_dense_algebraic_completeness/reports/research-005.md), [06_team-research.md](specs/988_dense_algebraic_completeness/reports/06_team-research.md)
- **Plan**: [06_representation-theorem-path.md](specs/988_dense_algebraic_completeness/plans/06_representation-theorem-path.md) (v6: Fix sorries, transport, wire)
- **Handoff**: [phase-1-handoff-20260317.md](specs/988_dense_algebraic_completeness/handoffs/phase-1-handoff-20260317.md)
- **Summary**: [implementation-summary-20260317.md](specs/988_dense_algebraic_completeness/summaries/implementation-summary-20260317.md), [02_implementation-summary.md](specs/988_dense_algebraic_completeness/summaries/02_implementation-summary.md) (v4 plan blocked), [03_sorry-analysis-summary.md](specs/988_dense_algebraic_completeness/summaries/03_sorry-analysis-summary.md) (v6 plan blocked), [04_architectural-gap-analysis.md](specs/988_dense_algebraic_completeness/summaries/04_architectural-gap-analysis.md) (v9 plan blocked)

**Status note (2026-03-19)**: Plans v4, v6, and v9 all blocked at Phase 1 due to the same fundamental issue: CanonicalMCS (sorry-free BFMCS) lacks AddCommGroup for TaskFrame D. The correct path is via task 995 (FMCS domain transfer): transfer the sorry-free CanonicalMCS construction to D = Rat via Cantor isomorphism (CanonicalMCS antisymmetrization ≃o ℚ). All temporal coherence components are already proven.

**Description**: Prove dense algebraic completeness using D = Rat. Requires: (1) a sorry-free BFMCS construction over Rat (adapting the Int construction with density-exploiting witness placement), (2) proving the DN axiom is valid in `DenseCanonicalTaskFrame Rat` (Rat's density gives the required intermediate witnesses), (3) wiring `dense_representation_conditional` to obtain `valid_dense φ → ⊢_dense φ`. Does not overlap with task 982 (TimelineQuot approach).

---

### 987. Algebraic base completeness
- **Effort**: TBD
- **Status**: [ABANDONED]
- **Abandoned**: 2026-03-19
- **Language**: lean
- **Depends On**: Task 986 [ARCHIVED]
- **Superseded By**: Task 995 (FMCS domain transfer lemma)
- **Research**: [research-001.md](specs/987_algebraic_base_completeness/reports/research-001.md)

**Abandonment reason**: Task 986 (dependency) is archived with 2 unresolvable sorries (forward_F/backward_P for D=Int). The CanonicalMCS path (sorry-free) cannot serve as D due to missing AddCommGroup. Task 995 (FMCS domain transfer) supersedes this by providing the general bridge from sorry-free CanonicalMCS to any D with AddCommGroup via order-embedding. Base completeness becomes a corollary of task 995 (embed into ℤ).

**Description**: Wire algebraic base completeness: use the sorry-free BFMCS construction from task 986 as the `construct_bfmcs` argument to `parametric_algebraic_representation_conditional` (D = Int), then prove `valid φ → ⊢ φ`. Resolve any type mismatch between `CanonicalWorldState` and `ParametricCanonicalWorldState`. Create `AlgebraicBaseCompleteness.lean` with the closed completeness theorem.

**Research Summary**: Task 986 has 2 sorries (forward_F/backward_P) blocking direct wiring. CanonicalWorldState and ParametricCanonicalWorldState are identical; real mismatch is D=Int (needs AddCommGroup) vs D=CanonicalMCS (sorry-free but only Preorder). Two paths: (A) complete task 986 dovetailing, or (B) semantic equivalence via CanonicalMCS completeness.

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
- **Status**: [RESEARCHED]
- **Language**: lean
- **Research**: [research-001.md](specs/949_update_demo_lean_bimodal_logic/reports/research-001.md)

**Description**: Update Theories/Bimodal/Examples/Demo.lean given the current state of the bimodal logic. The demo file should reflect the current API and showcase the working features of the bimodal logic implementation.

---

### 868. Reinstate lean-lsp MCP tools after GitHub issue resolution
- **Effort**: 1 hour
- **Status**: [ABANDONED]
- **Abandoned**: 2026-03-19
- **Language**: meta
- **Created**: 2026-02-11

**Abandonment reason**: The lean-lsp MCP tools have been reinstated and are actively working in the current project configuration (`.mcp.json`). Tools like `lean_goal`, `lean_hover_info`, `lean_completions`, `lean_diagnostic_messages`, etc. are all functional and used regularly in implementation sessions. Issue #115 (server hanging after import edits) is a minor inconvenience with a known workaround (use `lake build` for authoritative diagnostics). The task's premise — that tools are blocked and need reinstatement — is no longer accurate.

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

