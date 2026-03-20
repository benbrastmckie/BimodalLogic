---
next_project_number: 1007
repository_health:
  overall_score: 92
  production_readiness: improved
  last_assessed: 2026-03-19T23:50:22Z
task_counts:
  active: 10
  completed: 694
  in_progress: 1
  not_started: 4
  abandoned: 47
  total: 752
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

1. **997** → implement (base completeness, task 995 complete)
2. **988** → implement (dense completeness, 1003 complete)
3. **989** → implement (discrete completeness, after 988)
4. **999** → implement (F→FF derivation, small, anytime)
5. **949** → implement (update Demo.lean, small, anytime)
6. **992** → implement (STSA representation theorem, after completeness)
7. **1006** -> revise plan (independent, new research)

## Tasks

### 1006. Replace FlagBFMCS satisfies_at with canonical TaskFrame using truth_at
- **Effort**: 8-12 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Dependencies**: Task #1003
- **Research**:
  - [01_team-research.md](1006_canonical_taskframe_completeness/reports/01_team-research.md)
  - [02_direct-construction.md](1006_canonical_taskframe_completeness/reports/02_direct-construction.md)
  - [03_dense-discrete-compatibility.md](1006_canonical_taskframe_completeness/reports/03_dense-discrete-compatibility.md)
- **Plan**: [01_canonical-taskframe-plan.md](1006_canonical_taskframe_completeness/plans/01_canonical-taskframe-plan.md)

**Description**: Replace the internal `satisfies_at` relation in FlagBFMCS completeness with the official `truth_at` from the semantic layer. Construct a canonical TaskFrame directly from FlagBFMCS data: (1) canonical world states from CanonicalMCS, (2) duration domain D parametrically from Flag chain positions, (3) task relation R from CanonicalR, (4) WorldHistory instances from Flags (each Flag maps durations to world states), (5) canonical TaskFrame and TaskModel, (6) truth lemma for truth_at directly, (7) completeness theorem using canonical `valid`. Supersedes validity bridge approach in task 997.

### 999. Derive F(phi) → FF(phi) from density axiom
- **Effort**: TBD (estimated 2-4 hours)
- **Status**: [NOT STARTED]
- **Language**: lean

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
- **Status**: [IMPLEMENTING]
- **Language**: lean4
- **Depends On**: Task 995
- **Research**:
  - [01_wire-base-completeness.md](997_wire_algebraic_base_completeness/reports/01_wire-base-completeness.md)
  - [02_post-flagbfmcs-analysis.md](997_wire_algebraic_base_completeness/reports/02_post-flagbfmcs-analysis.md)
  - [03_validity-unification.md](997_wire_algebraic_base_completeness/reports/03_validity-unification.md)
- **Plan**: [02_validity-bridge-plan.md](997_wire_algebraic_base_completeness/plans/02_validity-bridge-plan.md)
- **Plan**: [01_wire-base-completeness-plan.md](997_wire_algebraic_base_completeness/plans/01_wire-base-completeness-plan.md)

**Description**: Wire the algebraic base completeness theorem using the FMCS domain transfer lemma (task 995). After task 995 provides the order-embedding `CanonicalMCS → Int`, fill the 2 sorries in `AlgebraicBaseCompleteness.lean` (lines 104, 155) to prove `valid φ → ⊢ φ` for base TM logic. The file already has the right structure: `construct_bfmcs_int` (via CanonicalMCS transfer) feeds `parametric_algebraic_representation_conditional` with `D = Int`. This supersedes abandoned task 987 and completes the base completeness leg of the three-way completeness suite (base/dense/discrete).

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
- **Status**: [RESEARCHING]
- **Blocked on**: Task 995 (FMCS domain transfer lemma), Task 974 (SuccOrder instance)
- **Language**: lean

**Description**: Prove discrete algebraic completeness using D = Int. Requires: (1) FMCS domain transfer from CanonicalMCS to Int (task 995), (2) proving DF and DP axioms are valid in `DiscreteCanonicalTaskFrame Int` (the parametric canonical TaskFrame instantiated at Int), (3) SuccOrder instance on DiscreteTimelineQuot (task 974, archived), (4) wiring `discrete_representation_conditional` to obtain `valid_discrete φ → ⊢_discrete φ`. Note: `DiscreteInstantiation.lean` uses live parametric infrastructure (`ParametricCanonicalTaskFrame Int`), not the deprecated `DiscreteTimeline.discreteCanonicalTaskFrame`.

---

### 988. Dense algebraic completeness
- **Effort**: 8 hours (multi-family BFMCS)
- **Status**: [RESEARCHING]
- **Language**: lean
- **Dependencies**: Task #1002, Task #1003
- **Research**: [13_dense-completeness-synthesis.md](988_dense_algebraic_completeness/reports/13_dense-completeness-synthesis.md) (synthesis), [12_teammate-a-findings.md](988_dense_algebraic_completeness/reports/12_teammate-a-findings.md), [12_teammate-b-findings.md](988_dense_algebraic_completeness/reports/12_teammate-b-findings.md)
- **Plan**: [12_multi-family-bfmcs-bundle.md](988_dense_algebraic_completeness/plans/12_multi-family-bfmcs-bundle.md) (v12: Multi-family BFMCS bundle)
- **Handoff**: [phase-1-handoff-20260317.md](specs/988_dense_algebraic_completeness/handoffs/phase-1-handoff-20260317.md)
- **Summary**: [05_v10-implementation-summary.md](specs/988_dense_algebraic_completeness/summaries/05_v10-implementation-summary.md) (v10 blocked)

**Status note (2026-03-19)**: Plans v4-v10 all blocked. Synthesis report 13 identifies two independent blockers: (1) forward_F chain witness termination, (2) modal_backward multi-family requirement. **Recommended approach**: Zorn saturated chain via ChainFMCS infrastructure - builds saturation by construction, avoids TimelineQuot termination gap. Next: create plan v11.

**Description**: Prove dense algebraic completeness using D = Rat. Requires: (1) a sorry-free BFMCS construction over Rat (adapting the Int construction with density-exploiting witness placement), (2) proving the DN axiom is valid in `DenseCanonicalTaskFrame Rat` (Rat's density gives the required intermediate witnesses), (3) wiring `dense_representation_conditional` to obtain `valid_dense φ → ⊢_dense φ`. Does not overlap with task 982 (TimelineQuot approach).

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

