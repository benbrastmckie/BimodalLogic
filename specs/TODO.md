---
next_project_number: 960
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-02-28T01:03:09Z
task_counts:
  active: 18
  completed: 662
  in_progress: 0
  not_started: 7
  abandoned: 37
  total: 716
technical_debt:
  sorry_count: 73
  axiom_count: 19
  build_errors: 0
  status: good
---

# TODO

## Tasks

### 959. Orient pure-syntax D construction: archive Int chain, cleanup, clear roadmap
- **Effort**: 4-6 hours
- **Status**: [COMPLETED]
- **Language**: lean
- **Priority**: high
- **Research**: [research-001.md](specs/959_orient_pure_syntax_d_construction_cleanup/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/959_orient_pure_syntax_d_construction_cleanup/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260311.md](specs/959_orient_pure_syntax_d_construction_cleanup/summaries/implementation-summary-20260311.md)

**Description**: Regain orientation for the D-from-syntax strategy. Three work items:
1. **Archive Int/Rat-tainted files**: `DovetailingChain.lean`, `TemporalCoherentConstruction.lean`, and the Int-dependent path in `Representation.lean` all violate the pure-syntax constraint. Archive to Boneyard. Clean up distracting comments pointing to these dead paths.
2. **Close Task 958 distraction**: `canonicalR_irreflexive` is provably unused (research-009). Add documentation, mark as contained debt, close the task.
3. **Map clear path for Task 956 Phases 6-8**: Fix 3 Cantor prerequisites in `CantorApplication.lean` (NoMaxOrder, NoMinOrder, DenselyOrdered on `TimelineQuot`), apply Cantor isomorphism → D, define `task_rel`, construct `TaskFrame`, prove standard completeness with zero Int/Rat imports.

**Key files**:
- Archive: `Bundle/DovetailingChain.lean` (uses Int), `Bundle/TemporalCoherentConstruction.lean` (uses Int), `Representation.lean` (depends on Int chain)
- Fix: `StagedConstruction/CantorApplication.lean` (3 sorries: NoMaxOrder, NoMinOrder, DenselyOrdered)
- New: D-from-syntax completeness path (Phases 7-8 of Task 956)

---

### 957. Density frame condition under irreflexive temporal semantics
- **Effort**: 8-16 hours
- **Status**: [COMPLETED]
- **Research**: [research-001.md](specs/957_density_frame_condition_irreflexive_temporal/reports/research-001.md), [research-002.md](specs/957_density_frame_condition_irreflexive_temporal/reports/research-002.md), [research-003.md](specs/957_density_frame_condition_irreflexive_temporal/reports/research-003.md) (IRR rule + selective Lindenbaum), [research-004.md](specs/957_density_frame_condition_irreflexive_temporal/reports/research-004.md) (IRR soundness)
- **Plan**: [implementation-004.md](specs/957_density_frame_condition_irreflexive_temporal/plans/implementation-004.md) (v4: restrict IRR soundness to domain-inhabited times)
- **Summary**: [implementation-summary-20260310c.md](specs/957_density_frame_condition_irreflexive_temporal/summaries/implementation-summary-20260310c.md) (complete: all 5 phases)
- **Language**: lean
- **Priority**: high
- **Dependencies**: Task 956 context (StagedConstruction infrastructure, axiom system)
- **Unblocks**: Task 956 (Phase 5: staged_timeline_densely_ordered)

**Description**: Prove the density frame condition for the canonical model under irreflexive semantics from temporal axioms alone, without importing any external dense linear order (Q or otherwise).

The condition to prove: for all MCS M, M' with CanonicalR M M' and NOT CanonicalR M' M, there exists W with CanonicalR M W AND CanonicalR W M'.

**Two sub-cases** (based on separating formula delta where G(delta) ∈ M' and delta ∉ M):
- **Case A** (G(delta) ∉ M): Intermediate W = Lindenbaum(GContent(M) ∪ {¬delta}) appears to work — ¬CanonicalR(M', W) follows directly from G(delta) ∈ M' and ¬delta ∈ W without T-axiom. Needs formal verification.
- **Case B** (G(delta) ∈ M, delta ∉ M): Obvious seed is inconsistent (delta ∈ GContent(M) conflicts with ¬delta). Investigate whether axioms force a Case A formula to always exist, or provide an alternative construction.

**Key constraint**: Must derive density from the axioms (temp_linearity, density F(φ)→F(F(φ)), seriality). Importing Q or any dense linear order is FORBIDDEN.

---

### 956. Construct D as translation group from syntax
- **Effort**: 30-50 hours
- **Status**: [IMPLEMENTING]
- **Previously blocked by**: Phase 6 quotient strictness gap (research-038 provides solution)
- **Previously blocked by**: Task 957 (density frame condition - NOW COMPLETE)
- **Language**: lean
- **Priority**: high
- **Dependencies**: Task 951 (BFMCS infrastructure, existence lemma), Task 957 (density frame condition)
- **Supersedes**: Task 954 (hardcoded Int refactor), Task 955 (CanonicalR task_rel)
- **Research**: [research-001.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-001.md), [research-002.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-002.md), [research-003.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-003.md), [research-004.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-004.md), [research-005.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-005.md), [research-006.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-006.md), [research-007.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-007.md), [research-008.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-008.md), [research-009.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-009.md), [research-010.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-010.md), [research-011.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-011.md), [research-012.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-012.md), [research-013.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-013.md), [research-014.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-014.md), [research-015.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-015.md), [research-016.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-016.md), [research-017.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-017.md), [research-018.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-018.md), [research-019.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-019.md), [research-020.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-020.md), [research-021.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-021.md), [research-022.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-022.md), [research-031.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-031.md), [research-032.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-032.md), [research-033.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-033.md), [research-034.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-034.md)
- **Plan**: [implementation-018.md](specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-018.md) (v018: Iteration-based strictness approach)
- **Summary**: [implementation-summary-20260312.md](specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-20260312.md) (Phase 6 partial: infrastructure done, backward strictness blocked), [phase-6-analysis-20260312.md](specs/956_construct_d_as_translation_group_from_syntax/summaries/phase-6-analysis-20260312.md) (backward strictness analysis)
- **Research**: [research-035.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-035.md) (team: density blocker + lex product densification)
- **Research**: [research-036.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-036.md) (unblocking analysis: task 957 complete, Phase 5 unblocked)
- **Research**: [research-037.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-037.md) (remaining work: Phase 6 blocker, 7-8h to completion)
- **Research**: [research-038.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-038.md) (math: Case A strictness solution recommended)
- **Research**: [research-039.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-039.md) (deep math: backward strictness - iteration approach)

**Description**: Construct the temporal duration group D entirely from pure syntax as the group of order-preserving automorphisms (translations) of the canonical timeline of MCSs, without assuming Int or defining a successor function. The construction proceeds:

1. **Origin**: Extend consistent set Γ₀ to MCS w₀ via Lindenbaum — this is the designated origin
2. **Timeline**: Build linear order T of MCSs reachable from w₀ via the existence lemma (if Fψ ∈ w, there exists w' > w with ψ ∈ w'; similarly for P). Temporal axioms force T to be a connected linear order without endpoints
3. **Translation group**: Define D = Aut⁺(T) = {f : T → T | f is order-preserving bijection}. Group operation is composition, identity is id, inverse is f⁻¹
4. **Origin bijection**: eval₀ : D → T defined by eval₀(d) = d(w₀). This is a bijection because D acts freely and transitively on T (homogeneity of T from temporal axioms + rigidity of order-automorphisms)
5. **Ordered group**: Pull back order from T to D: d₁ < d₂ iff d₁(w₀) < d₂(w₀). Makes D a linearly ordered abelian group
6. **task_rel = group action**: task_rel(d)(w) = d(w). This IS the group action — not an artificial map
7. **Canonical model**: M = (T, <, D, task_rel, V) where V(p) = {w : p ∈ w}
8. **Truth lemma**: M, w ⊨ φ ↔ φ ∈ w by structural induction
9. **Completeness**: If ⊬ φ, extend {¬φ} to MCS w₀, build canonical model, w₀ ⊭ φ

**Key advantages over previous approaches**:
- No dovetailing chain or F-persistence problem (existence lemma provides witnesses directly)
- No SuccOrder/PredOrder or orderIsoIntOfLinearSuccPredArch needed
- No hardcoded D = Int — D emerges as whatever translation group the axioms produce
- task_rel is the group action itself, not a separately-defined bridge
- For discrete time axioms, D ≅ ℤ as a theorem; for dense time, D ≅ ℚ as a theorem

---

### 955. Implement D and task_rel from pure syntax
- **Effort**: 25-40 hours
- **Status**: [PLANNED]
- **Language**: lean
- **Priority**: high
- **Dependencies**: Task 951 (BFMCS infrastructure), Task 954 (general duration refactor)
- **Plan**: [implementation-001.md](specs/955_implement_d_and_task_rel_from_pure_syntax/plans/implementation-001.md)

**Description**: Construct the temporal duration group D and a non-trivial task_rel entirely from syntactic proof-theoretic data. Replace the trivial `task_rel := fun _ _ _ => True` in Representation.lean with `task_rel := fun w _d u => CanonicalR w.val u.val`, where CanonicalR is derived from GContent/HContent inclusion on maximal consistent sets. Nullity from T-axiom (Gφ → φ), compositionality from 4-axiom (Gφ → GGφ). D = Int justified as satisfiability witness (not universal model). Comprehensive analysis of 7 approaches (direct quotient, Grothendieck, orderIsoInt, torsor, chain-based, sign-based, CanonicalR) with proofs of impossibility for 6 of them. Plan covers 6 phases: canonical TaskFrame definition, CanonicalR property verification, WorldHistory construction, truth lemma compatibility, D construction justification, and full integration.

---

### 954. Refactor representation theorem to avoid hardcoded Int for general duration type
- **Effort**: 45-75 hours
- **Status**: [PLANNED]
- **Language**: lean
- **Priority**: high
- **Dependencies**: Task 951 (completeness infrastructure), Task 922 (strategy study)
- **Research**: [research-001.md](specs/954_refactor_representation_theorem_general_duration/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/954_refactor_representation_theorem_general_duration/plans/implementation-001.md)

**Description**: Refactor the representation theorem so that the duration type D is constructed purely from syntax — shown to be a totally ordered abelian group — rather than hardcoding D = Int. The construction builds D as the Antisymmetrization of the BidirectionalFragment (a linear order quotient of reachable MCSes), then derives AddCommGroup via successor/predecessor structure and Mathlib's `orderIsoIntOfLinearSuccPredArch`. The refactored construction should be fully general and compatible with an extension that includes a density axiom, parameterized by a "temporal theory" type: base logic yields D ≅ Z, density extension yields D ≅ Q.

**Key construction pipeline**: Fragment → Quotient → SuccOrder/PredOrder → OrderIso to Z → Transfer AddCommGroup → TaskFrame D → FMCS D → BFMCS D → Truth lemma → Completeness.

**Hardcoding points to eliminate**: (1) `CanonicalTaskFrame : TaskFrame Int` in CanonicalConstruction.lean, (2) `canonicalFrame : BFMCS Int → TaskFrame Int` in CanonicalCompleteness.lean, (3) `standard_representation : satisfiable Int [φ]` in Representation.lean.

---

### 953. Refactor proof system to bilateral system
- **Effort**: 55-90 hours
- **Status**: [RESEARCHED]
- **Language**: lean
- **Priority**: medium
- **Research**: [research-001.md](specs/953_refactor_proof_system_to_bilateral/reports/research-001.md)

**Description**: Refactor the TM proof system from a unilateral system (single judgment `Γ ⊢ φ`) to a bilateral system with dual judgments: acceptance (`Γ ⊢⁺ φ`) and rejection (`Γ ⊢⁻ φ`). The bilateral system makes the dual roles of assertion and denial explicit, with rules governing how acceptance and rejection interact across all connectives and operators. Key design: keep Formula type unchanged (Option A), add BilateralDeriv alongside existing DerivationTree with a proven equivalence bridge. Several current axioms (ex_falso, peirce, modal_t, temp_t_future, temp_t_past) become structural rules in the bilateral system. The existing signed formula infrastructure in the decidability module provides the blueprint.

**Implementation approach**: Parallel bilateral system with equivalence bridge — not a replacement. Phase 1: bilateral infrastructure (BilateralContext, BilateralDeriv). Phase 2: prove equivalence with unilateral system. Phase 3: bilateral metalogic (MCS, FMCS, completeness). Phase 4: bilateral decidability integration.

---

### 952. Sync Theory/.claude/ improvements into ProofChecker/.claude/
- **Effort**: 3.5 hours
- **Status**: [COMPLETED]
- **Language**: meta
- **Research**: [research-001.md](specs/952_sync_theory_claude_improvements_into_proofchecker_claude/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/952_sync_theory_claude_improvements_into_proofchecker_claude/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260301.md](specs/952_sync_theory_claude_improvements_into_proofchecker_claude/summaries/implementation-summary-20260301.md)

**Description**: Sync Theory/.claude/ improvements into ProofChecker/.claude/. Bring in: typst-research skill+agent, /merge command, zero-padding ({NNN}) in paths and artifact templates, all domain content (category theory, bilateral semantics, mereology, bilattice-theory, monoidal-posets, scott-topology, etc.), logos-macros.md, extra orchestration files (delegation.md, orchestrator.md, routing.md, sessions.md, subagent-validation.md, validation.md), context-knowledge-template.md, README.md files in context/project/ subdirectories, extra typst patterns+standards, extra latex checklist items, tts-stt-integration.md, wezterm-integration.md in docs/guides/, opencode-conventions.md. PRESERVE: context/core/reference/ delegation, model: opus on agents, targeted file-by-file git staging, multi-agent team skills, condensed CLAUDE.md with @-references, all ProofChecker-specific patterns. IGNORE: output/ directory.

**Completed**: Synced 40 files including domain content (category theory, bilateral semantics, mereology), typst-research skill/agent, /merge command, orchestration references, and documentation guides. All 32 ProofChecker-unique files preserved.

---

### 951. Implement sorry-free completeness via CanonicalMCS domain
- **Effort**: 20-30 hours
- **Status**: [COMPLETED]
- **Language**: lean
- **Priority**: high
- **Dependencies**: Task 922 (research), Task 930 (analysis)
- **Research**: [research-001.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-001.md), [research-002.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-002.md), [research-003.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-003.md), [research-008.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-008.md) (team), [research-009.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-009.md), [research-010.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-010.md), [research-011.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-011.md), [research-012.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-012.md) (team), [research-013.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-013.md), [research-014.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-014.md), [research-015.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-015.md) (team), [research-016.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-016.md) (architecture redesign), [research-018.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-018.md) (non-trivial task_rel from pure syntax), [research-019.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-019.md) (D construction obstruction analysis), [research-021.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-021.md) (team 4-agent — ideals map, catalog, gap analysis, all 5 gating questions answered), [research-022.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-022.md) (histories-first approach, R-order analysis, Flag infrastructure), [research-023.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-023.md) (deep analysis of alternative encoding strategies for F-persistence), [research-024.md](specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-024.md) (team: F-preserving seed consistency analysis)
- **Plan**: [implementation-007.md](specs/951_implement_sorry_free_completeness_canonicalmcs/plans/implementation-007.md) (v7 - F-preserving seed consistency conjecture proof, 5 phases)
- **Previous Blockers**: Plans v1-v6 SUPERSEDED. v7 BLOCKED: F-preserving seed conjecture proven false.
- **Summary**: [implementation-summary-20260302.md](specs/951_implement_sorry_free_completeness_canonicalmcs/summaries/implementation-summary-20260302.md) (v7 blocked: counterexample found)

**Description**: Implement standard completeness theorem using Bidirectional Reachable Fragment approach:
1. Define bidirectional reachable fragment from root MCS
2. Prove fragment is linearly ordered via linearity axiom
3. Embed into Int via Antisymmetrization
4. Pull back FMCS structure to get `FMCS Int` with forward_F/backward_P
5. Build BFMCS with modal saturation
6. Prove truth lemma and completeness

**Plan v2 approach** (supersedes chain-based v1): Use Bidirectional Reachable Fragment. F/P are trivially sorry-free at CanonicalMCS level; embed linearly-ordered fragment into Int; pull back structure. Avoids F-formula non-persistence problem that blocked chain approach.

**Key files**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` - source of sorry-free forward_F/backward_P
- `Boneyard/Metalogic/Bundle/CanonicalQuotientApproach/` - infrastructure to resurrect
- `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` - Phase 1-2 infrastructure (857 lines)

---

### 950. Move Bimodal Boneyard contents to Metalogic Boneyard
- **Effort**: Small
- **Status**: [COMPLETED]
- **Language**: general
- **Research**: [research-001.md](specs/950_move_bimodal_boneyard_contents/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/950_move_bimodal_boneyard_contents/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260227.md](specs/950_move_bimodal_boneyard_contents/summaries/implementation-summary-20260227.md)

**Description**: Move the /home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/ contents into /home/benjamin/Projects/ProofChecker/Boneyard/Metalogic/ as appropriate.

**Completed**: Moved 112 Lean files to Boneyard/Metalogic/, updated Demo.lean and MaximalConsistent.lean imports to use active modules, consolidated MCS theory.

---

### 949. Update Demo.lean for current bimodal logic state
- **Effort**: Small
- **Status**: [NOT STARTED]
- **Language**: lean

**Description**: Update Theories/Bimodal/Examples/Demo.lean given the current state of the bimodal logic. The demo file should reflect the current API and showcase the working features of the bimodal logic implementation.

---

### 930. Verify correctness of MCS-membership box semantics in ChainBundleBFMCS
- **Effort**: 8-16 hours
- **Status**: [RESEARCHED]
- **Language**: lean
- **Started**: 2026-02-25
- **Research**: [research-001.md](specs/930_verify_mcs_membership_box_semantics_correctness/reports/research-001.md), [research-002.md](specs/930_verify_mcs_membership_box_semantics_correctness/reports/research-002.md), [research-003.md](specs/930_verify_mcs_membership_box_semantics_correctness/reports/research-003.md), [research-004.md](specs/930_verify_mcs_membership_box_semantics_correctness/reports/research-004.md), [research-005.md](specs/930_verify_mcs_membership_box_semantics_correctness/reports/research-005.md), [research-006.md](specs/930_verify_mcs_membership_box_semantics_correctness/reports/research-006.md), [research-007.md](specs/930_verify_mcs_membership_box_semantics_correctness/reports/research-007.md)

**Description**: Task 925 proved completeness using a modified truth predicate (`bmcs_truth_at_mcs`) in which the box case is defined by MCS-membership rather than recursive Kripke truth. Specifically:

- **Standard truth** (`bmcs_truth_at`, BFMCSTruth.lean:91): `□φ TRUE at (fam, t) := ∀ fam' ∈ B.families, bmcs_truth_at B fam' t φ`
- **MCS-membership truth** (`bmcs_truth_at_mcs`, ChainBundleBFMCS.lean:362): `□φ TRUE at (fam, t) := ∀ fam' ∈ B.families, φ ∈ fam'.mcs t`

This distinction matters because the completeness theorem (`bmcs_weak_completeness_mcs`) quantifies over validity under `bmcs_truth_at_mcs`, while the soundness theorem (`soundness` in Soundness.lean) quantifies over validity under `truth_at` (the intended Kripke semantics from `Bimodal.Semantics.Validity`). If the two truth predicates are not equivalent on BFMCS structures, soundness and completeness address different notions of validity and do not combine into a full correctness result.

**Research questions**:

1. **Equivalence question**: Is `bmcs_truth_at_mcs B fam t φ ↔ bmcs_truth_at B fam t φ` provable for all formulas φ, all BFMCS B, all fam ∈ B.families, and all t? This reduces (by structural induction) to: does `bmcs_truth_at B fam' t φ ↔ φ ∈ fam'.mcs t` hold for all fam' in a BFMCS, which is exactly the STANDARD truth lemma. The standard truth lemma was the obstacle that motivated MCS-membership semantics in the first place (it requires temporal coherence of all families in the bundle). So the question is whether the canonical BFMCS constructed in `chainBundleBFMCS` does in fact satisfy the standard truth lemma.

2. **Validity equivalence question**: Is `bmcs_valid_mcs φ ↔ bmcs_valid φ` (equivalently, `bmcs_valid_mcs φ ↔ (⊨ φ)`)? This would require every BFMCS model where φ fails under standard truth also witnesses failure under MCS-membership truth, and vice versa. These are different model classes so this is non-trivial.

3. **Semantic alignment question**: Does `bmcs_valid_mcs` correctly capture the intended notion of validity for bimodal temporal logic TM, as defined in `Bimodal.Semantics.Validity` (using `truth_at`)? Without an equivalence proof, the completeness theorem is relative to a potentially non-standard class of models.

4. **Soundness alignment question**: Is `bmcs_valid_mcs φ → ⊨ φ` provable? If so, together with completeness (`bmcs_valid_mcs φ → ⊢ φ`) and soundness (`⊢ φ → ⊨ φ`), this would give full soundness and completeness with respect to the intended semantics (though only via MCS-membership as an intermediate).

**Key files to study**:
- `Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean` — `bmcs_truth_at_mcs`, `bmcs_truth_lemma_mcs`, `bmcs_valid_mcs`, `bmcs_weak_completeness_mcs`
- `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` — `bmcs_truth_at`, `bmcs_valid`, standard truth lemma (if any)
- `Theories/Bimodal/Metalogic/Soundness.lean` — `soundness` using `⊨` from `Bimodal.Semantics.Validity`
- `Theories/Bimodal/Semantics/Validity.lean` — `truth_at`, `valid`, `⊨` notation

**Expected outcomes** (one of):

A. **Equivalence holds**: Prove `bmcs_truth_at_mcs B fam t φ ↔ bmcs_truth_at B fam t φ` for all saturated BFMCS (or at least for `chainBundleBFMCS`). If provable, state and prove `bmcs_valid_mcs_iff_valid : bmcs_valid_mcs φ ↔ (⊨ φ)` and update the completeness theorem to use `bmcs_valid` (the standard notion), making the result directly connect to soundness.

B. **Equivalence not provable in general, but holds for chainBundleBFMCS**: Show that `chainBundleBFMCS` specifically satisfies the standard truth lemma (because the chain construction gives enough temporal coherence), prove `bmcs_truth_at_mcs ↔ bmcs_truth_at` for that specific model, and derive the full completeness theorem `⊨ φ → ⊢ φ` by going through `chainBundleBFMCS`.

C. **Genuine gap**: If neither equivalence holds, determine whether MCS-membership semantics defines a valid but different logical system, and either (i) revise `ChainBundleBFMCS.lean` to use a construction that supports the standard truth lemma, or (ii) revise the statement of completeness to be explicit that it is with respect to MCS-membership models (with appropriate justification that this is still the intended logic).

**Constraints**: No new axioms or sorries may be introduced to paper over the gap. If outcome A or B holds, the result must be fully proved in Lean. If outcome C, the gap must be clearly documented and a plan for resolution created.

---

### 929. Prepare metalogic for publication
- **Effort**: 16-24 hours
- **Status**: [NOT STARTED]
- **Language**: lean

**Description**: Systematic preparation of the bimodal temporal logic metalogic for publication. The codebase currently has two independent sorry-free, axiom-free completeness proofs (BMCS via ChainBundleBMCS.lean and FMP via SemanticCanonicalModel.lean), a sound and complete decidability procedure, and a clean build. The following work remains before publication:

**Phase 1 — Abandon obsolete tasks**: The completion of Task 925 (sorry-free BMCS completeness) superseded several alternative proof strategies that are no longer needed. Abandon the following tasks with justification:
- Task 865 (canonical_task_frame_bimodal_completeness): Research into earlier canonical-frame completeness approach, now superseded by ChainBundleBMCS
- Task 881 (modally_saturated_bmcs_construction): Was a stepping stone toward DovetailingChain; the BMCS path (Task 925) provides sorry-free completeness without it
- Task 916 (implement_fp_witness_obligation_tracking): The F/P witness DovetailingChain path had an irreducible F-persistence gap; Task 925's BMCS approach sidesteps this entirely
- Task 917 (fix_forward_f_backward_p_temporal_witness_strictness): Documentation fix for concepts in Task 916; moot if Task 916 is abandoned
- Task 922 (strategy_study_fp_witness_completeness_blockers): Research prerequisite for Task 916; moot if Task 916 is abandoned

**Phase 2 — Ensure Task 928 is complete**: Task 928 (terminology refactoring BMCS→BFMCS) must be fully complete before publication. Verify all phases of Task 928 are done, including Boneyard cleanup (Phase 2 of that task).

**Phase 3 — Axiom and sorry annotation/cleanup**: The 5 remaining sorries and 2 custom axioms in the main metalogic all lie on non-BMCS proof paths. They do not affect the publication-ready results but need clear annotation:
- `Construction.lean:197` (`singleFamilyBMCS.modal_backward`): Mark as superseded; the single-family wrapper approach is no longer the primary path (ChainBundleBMCS is). Consider whether to remove `Construction.lean` entirely or clearly comment it as a deprecated/archived proof attempt.
- `DovetailingChain.lean:1869,1881` (`buildDovetailingChainFamily_forward_F`, `buildDovetailingChainFamily_backward_P`): The F/P witness gap. Add a module-level docstring clearly stating this file contains an unfinished alternative completeness path that is not part of the primary proof.
- `TemporalCoherentConstruction.lean:613,819`: These sorries are consequences of the `fully_saturated_bmcs_exists` axiom. Add clear annotation explaining the axiom and its scope.
- `fully_saturated_bmcs_exists` axiom (TemporalCoherentConstruction.lean:755): This axiom is used only by `standard_weak_completeness` / `standard_strong_completeness`, which are NOT on the primary BMCS proof path. Add a docstring: "This axiom asserts Henkin-style saturation; it is NOT needed for `bmcs_weak_completeness_mcs` or `bmcs_strong_completeness_mcs`, which are sorry-free and axiom-free." Consider running lean_verify on the primary theorems to confirm and document the axiom-free dependency chain.
- `saturated_extension_exists` axiom (CoherentConstruction.lean:871): Marked in audit as deprecated/superseded by Task 925. Remove or replace with a comment that this is archived research (the axiom is no longer needed).

**Phase 4 — Publication documentation**: Create or update the following documentation:
- Update `Metalogic.lean` (main export file) with a detailed module docstring explaining: (a) the logical system (bimodal temporal propositional logic TM), (b) the main theorems proven (soundness, BMCS weak/strong completeness, FMP weak completeness, decidability), (c) the key proof innovation (MCS-membership box semantics in ChainBundleBMCS that avoids requiring universal temporal coherence), (d) an explicit dependency map from the publication-ready theorems to their axiom dependencies (only standard Lean: propext, Classical.choice, Quot.sound).
- Add or update module docstrings in `ChainBundleBMCS.lean` and `FMP/SemanticCanonicalModel.lean` with theorem statements, proof strategies, and commentary suitable for a reader unfamiliar with the project history.
- Ensure `Soundness.lean` and `SoundnessLemmas.lean` have docstrings connecting them to the completeness theorems.
- Create a `docs/publication-summary.md` or `docs/THEOREMS.md` file listing all publication-ready results with their Lean names, file locations, and axiom dependencies (output of `#check` and `#print axioms`).

**Phase 5 — Verification pass**: Before finalizing for publication:
- Run `lean_verify` on `bmcs_weak_completeness_mcs`, `bmcs_strong_completeness_mcs`, `soundness`, and `fmp_weak_completeness` to confirm axiom dependencies
- Run `lake clean && lake build` to confirm zero build errors from a clean state
- Count and document: total active files, total sorry-free theorems, total sorries in non-primary paths, total custom axioms (target: 0 on primary path)

**Key context**:
- Primary publication path: `Soundness.lean` + `ChainBundleBMCS.lean` + `FMP/SemanticCanonicalModel.lean` + `Decidability/DecisionProcedure.lean` — all sorry-free, all axiom-free
- Innovation to highlight: MCS-membership box semantics (`φ ∈ fam'.mcs t` instead of evaluating φ at fam') decouples box-truth from universal temporal coherence
- 44/49 active files are sorry-free; 5 sorries all lie in non-primary alternative proof paths
- The Boneyard contains 147 archived files with 187 sorries representing exhausted research paths; these are intentionally archived and do not affect build or publication

---

### 922. Strategy study: identify viable path for forward_F/backward_P completeness
- **Effort**: 8-16 hours
- **Status**: [RESEARCHED]
- **Language**: lean
- **Created**: 2026-02-24
- **Started**: 2026-02-24
- **Blocks**: Task 924
- **Research**: [research-008.md](specs/922_strategy_study_fp_witness_completeness_blockers/reports/research-008.md)
- **Plan**: [implementation-005.md](specs/922_strategy_study_fp_witness_completeness_blockers/plans/implementation-005.md)
- **Summary**: [implementation-summary-20260224c.md](specs/922_strategy_study_fp_witness_completeness_blockers/summaries/implementation-summary-20260224c.md)

**Description**: Meta-analysis of 16 research reports and 12 plan versions to extract actionable insights for overcoming the forward_F/backward_P completeness challenge. **CONSTRAINT: Sorry debt is NEVER acceptable** — the study must find a path to zero sorries, not evaluate sorry acceptance as an option.

The study should focus on LEARNING FROM FAILURES to inspire creative solutions:

**Pattern Analysis of Failed Approaches:**
- What common assumptions did linear chains, enriched chains, omega-squared chains, witness-graph-guided approaches, and FPreservingSeed all share that led to failure?
- Is the "Lindenbaum opacity" a fundamental barrier, or does it reveal a hidden assumption we can drop?
- Why did 12 successive plan revisions each believe their approach would work when all hit the same wall? What cognitive trap is at play?

**Creative Reframing Questions:**
- What if the problem is not "prove forward_F for a chain" but "find a structure that makes forward_F trivially true"?
- Are there proof techniques from other domains (set theory, category theory, type theory) that handle similar "witness existence under opacity" problems?
- Can we work backward from the goal state (a BFMCS Int with forward_F) to discover what properties the construction MUST have, rather than forward from chain construction?
- What if we abandon BFMCS Int entirely and prove completeness through a different semantic structure?

**Mandatory Outputs:**
1. A "lessons learned" document identifying the precise mathematical property that all failed approaches lacked
2. At least 3 genuinely novel approach ideas that do NOT fit the "bottom-up chain construction" pattern
3. For each novel approach: a preliminary feasibility assessment with confidence level
4. A ranked recommendation with clear decision criteria

Key artifacts to study: `specs/916_implement_fp_witness_obligation_tracking/` (all reports, plans, handoffs), particularly the Phase 3 blocker analysis (`handoffs/phase-3-blocker-analysis-20260224.md`) which crystallizes the obstruction.

---

### 868. Reinstate lean-lsp MCP tools after GitHub issue resolution
- **Effort**: 1 hour
- **Status**: [BLOCKED]
- **Language**: meta
- **Created**: 2026-02-11
- **Blocked on**: lean-lsp-mcp issue #115 resolution

**Description**: Once lean-lsp-mcp issue #115 (server halts on lean_diagnostic_messages) is resolved, reinstate the blocked MCP tools. Follow the unblocking procedure: verify fix in repository, update package version, test tools manually, update blocked-mcp-tools.md to mark as UNBLOCKED, remove from CLAUDE.md blocked list, and restore documentation in mcp-tools-guide.md. Consider re-testing lean_file_outline as well since no specific open issue exists for it.

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

### 793. Fix Claude Code neovim sidebar black screen delay
- **Effort**: S
- **Status**: [PLANNING]
- **Language**: general
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Research**: [research-001.md](specs/793_fix_claude_code_neovim_sidebar_black_screen/reports/research-001.md)

**Description**: Investigate and fix issue where running a command in Claude Code sidebar in neovim causes an initial black screen (all text disappears) for approximately 30 seconds before showing activity. Functionality works correctly otherwise. Issue started recently. Root cause may be in hook system or external. Research online and review hook configuration to identify simple and elegant fix.

---

### 394. Research and port causal semantics from paper
- **Effort**: 4-6 hours
- **Status**: [PLANNING]
- **Language**: lean
- **Parent**: Task 381
- **Subtasks**: 398, 399
- **Research**: [research-001.md](specs/394_research_port_causal_semantics_from_paper/reports/research-001.md), [research-002.md](specs/394_research_port_causal_semantics_from_paper/reports/research-002.md)

**Description**: Research and port the correct causal operator semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md first, then to Lean. The causal operator is primitive (like the counterfactual conditional) and requires careful adaptation to the more sophisticated theory of time in Logos.

---

### 398. Port causal semantics to recursive-semantics.md
- **Effort**: 3-4 hours
- **Status**: [IMPLEMENTING]
- **Language**: markdown
- **Parent**: Task 394
- **Research**: [research-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/plans/implementation-001.md)

**Description**: Port the causal semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md. Adapt the 2-place task relation from the paper to the more sophisticated 3-place task relation (with duration) in Logos. Carefully study the counterfactual semantics already included in the recursive-semantics.md in order to adapt existing resources rather than positing additional resources in order to construct the three-condition truth clause for causation.

---

### 399. Implement causal semantics in Lean
- **Effort**: 6-8 hours
- **Status**: [NOT STARTED]
- **Language**: lean
- **Parent**: Task 394
- **Dependencies**: 398

**Description**: Implement the causal operator semantics in Lean based on the approved recursive-semantics.md specification. Extend CoreFrame with closeness ordering, define Evolution and ExpectedEvolution structures, implement CausalContext with background assumptions, and replace the current counterfactual-based definition in Truth.lean with the three-condition hyperintensional semantics.

---

### 685. Derive world-history and Barcan theorems
- **Effort**: 8-10 hours
- **Status**: [PLANNING]
- **Language**: lean
 **Created**: 2026-01-26
 **Source**: Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex (2 grouped TODO items)
 **Research**: [research-001.md](specs/685_derive_world_history_and_barcan_theorems/reports/research-001.md)

**Description**: Derive and prove 2 theorem groups in Logos Dynamics system based on TODO items: (1) line 200: Derive as theorem that every time in a world-history gets mapped to a world-state, then include remark discussing which constraints (from Containment subsection of counterfactual_worlds.tex line 1822) play a role in proving this theorem without assuming discreteness. Articulate theorem in Lean source with proof strategy in comments; (2) line 288: Derive Barcan formulas and prove their validity for the unrestricted quantifier and 'all possibly actual' quantifier. Similarly, show that the 'all sometimes actual' quantifier validates temporal analogs of Barcan formulas.

---


