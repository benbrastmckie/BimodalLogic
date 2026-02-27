---
next_project_number: 946
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-02-27T02:51:23Z
task_counts:
  active: 16
  completed: 658
  in_progress: 2
  not_started: 3
  abandoned: 36
  total: 713
technical_debt:
  sorry_count: 80
  axiom_count: 19
  build_errors: 0
  status: manageable
---

# TODO

## Tasks

### 945. Design canonical model construction for TruthLemma
- **Effort**: Large
- **Status**: [RESEARCHED]
- **Language**: lean
- **Research**: [research-001.md](specs/945_canonical_model_construction_design/reports/research-001.md)
- **Research**: [research-002.md](specs/945_canonical_model_construction_design/reports/research-002.md)

**Description**: Take careful stock of the metalogic in order to identify what remains to finishing the representation theorem in order to design and implement a fully adequate syntactic construction by which to define a canonical model that satisfies the TruthLemma. The hard work should go into thinking carefully about how the construction should go since, once the right construction is found, establishing the TruthLemma will be easy. Don't move until you see it; it is better to think deeply to find the right construction than to go down the wrong rabbit hole.

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

### 924. Prove fully_saturated_bmcs_exists combining modal saturation with temporal coherence
- **Effort**: 8-16 hours
- **Status**: [PLANNING]
- **Language**: lean
- **Created**: 2026-02-24
- **Blocked by**: Task 922
- **Research**: [research-005.md](specs/924_prove_fully_saturated_bmcs_exists_modal_temporal/reports/research-005.md)
- **Plan**: [implementation-001.md](specs/924_prove_fully_saturated_bmcs_exists_modal_temporal/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260224.md](specs/924_prove_fully_saturated_bmcs_exists_modal_temporal/summaries/implementation-summary-20260224.md)

**Description**: Prove `fully_saturated_bmcs_exists`: combining modal saturation with temporal coherence in a single BMCS construction.

This is the final blocker for the completeness chain. The current sorry in `TemporalCoherentConstruction.lean` (`fully_saturated_bmcs_exists_int`) requires:
1. Modal saturation: every consistent formula set can be extended to a fully saturated MCS (Lindenbaum via modal witnesses)
2. Temporal coherence: the resulting family satisfies forward_G and backward_H
3. Both simultaneously: modal saturation adds constant witness families, which must themselves be temporally coherent

The tension: modal saturation uses Lindenbaum extension which does NOT preserve temporal saturation (where F(psi) -> psi). The current approach proves temporal coherence and modal saturation separately but cannot combine them.

Context: Task 922 proved forward_F and backward_P sorry-free using the Preorder/all-MCS approach. This task addresses the remaining sorry: constructing a fully saturated BMCS that satisfies ALL four conditions simultaneously with a root MCS witnessing a given consistent formula.

Key files:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - contains `fully_saturated_bmcs_exists_int` sorry
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - modal saturation tools
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` - new all-MCS BFMCS construction from task 922

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

### 917. Fix forward_F/backward_P temporal witness strictness in DovetailingChain and comments
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Language**: lean
- **Created**: 2026-02-21

**Description**: The description of `forward_F` and `backward_P` in `DovetailingChain.lean` and related comments/documentation incorrectly characterizes them as requiring a STRICTLY future (or past) witness. They should instead say "present OR future" (and "present OR past"), i.e., the witness time `s` satisfies `t ≤ s` rather than `t < s`. Source: `specs/916_implement_fp_witness_obligation_tracking/reports/research-008.md:28`. Find where this wrong perception is propagated (comments, docstrings, research reports) and fix it everywhere.

---

### 916. Implement F/P witness obligation tracking to close DovetailingChain sorries
- **Effort**: 24-48 hours (Omega-squared immediate processing)
- **Status**: [PARTIAL]
- **Language**: lean
- **Created**: 2026-02-20
- **Research**: [research-001.md](specs/916_implement_fp_witness_obligation_tracking/reports/research-001.md), [research-002.md](specs/916_implement_fp_witness_obligation_tracking/reports/research-002.md), [research-003.md](specs/916_implement_fp_witness_obligation_tracking/reports/research-003.md) (Team Research v3), [research-004.md](specs/916_implement_fp_witness_obligation_tracking/reports/research-004.md) (Obstruction Analysis), [research-005.md](specs/916_implement_fp_witness_obligation_tracking/reports/research-005.md) (Synthesis), [research-006.md](specs/916_implement_fp_witness_obligation_tracking/reports/research-006.md) (Constraints), [research-007.md](specs/916_implement_fp_witness_obligation_tracking/reports/research-007.md) (Proof Technique), [research-008.md](specs/916_implement_fp_witness_obligation_tracking/reports/research-008.md) (Root Cause), [research-009.md](specs/916_implement_fp_witness_obligation_tracking/reports/research-009.md) (Canonical Model vs AliveF), [research-010.md](specs/916_implement_fp_witness_obligation_tracking/reports/research-010.md) (Constraint-Based / Deferred Concretization), [research-011.md](specs/916_implement_fp_witness_obligation_tracking/reports/research-011.md) (Progress Review), [research-012.md](specs/916_implement_fp_witness_obligation_tracking/reports/research-012.md) (Error Analysis), [research-013.md](specs/916_implement_fp_witness_obligation_tracking/reports/research-013.md) (Option A Fix Patterns), [research-014.md](specs/916_implement_fp_witness_obligation_tracking/reports/research-014.md) (Path Forward Synthesis), [research-015.md](specs/916_implement_fp_witness_obligation_tracking/reports/research-015.md) (Team Research - Omega-squared), [research-016.md](specs/916_implement_fp_witness_obligation_tracking/reports/research-016.md) (Team Research - Witness-graph blocked)
- **Plan**: [implementation-012.md](specs/916_implement_fp_witness_obligation_tracking/plans/implementation-012.md) (v12: Omega-squared immediate processing - 5 phases)
- **Summary**: [implementation-summary-20260221.md](specs/916_implement_fp_witness_obligation_tracking/summaries/implementation-summary-20260221.md) (FPreservingSeed counterexample)

**Description**: Close the 4 remaining sorries in `DovetailingChain.lean` by implementing F/P witness obligation tracking in the chain construction and resolving the cross-sign propagation gap. Phase 1 unifies the split forward/backward half-chains into a single interleaved dovetailing chain (closes cross-sign forward_G and backward_H sorries). Phase 2 adds F/P witness scheduling via Cantor-pairing enumeration of all (time, formula) obligations (closes forward_F and backward_P sorries). See description.md for full proof strategy and key lemmas.

---

### 881. Construct modally saturated BMCS to eliminate fully_saturated_bmcs_exists axiom
- **Effort**: 8-12 hours
- **Status**: [BLOCKED]
- **Language**: lean
- **Created**: 2026-02-13
- **Researched**: 2026-02-16
- **Planned**: 2026-02-17
- **Blocked**: Task 887 completed with sorries. Temporal coherence of witness families requires temporal-aware Lindenbaum. See task 888.
- **Dependencies**: Task 888 (research required)
- **Research**: [research-011.md](specs/881_modally_saturated_bmcs_construction/reports/research-011.md) (Implementation review, remaining work after task 887), [research-010.md](specs/881_modally_saturated_bmcs_construction/reports/research-010.md) (Team v10: Option D)
- **Plan**: [implementation-007.md](specs/881_modally_saturated_bmcs_construction/plans/implementation-007.md) (v7: No technical debt; Options A/C/D decision tree)
- **Summary**: [implementation-summary-20260217.md](specs/881_modally_saturated_bmcs_construction/summaries/implementation-summary-20260217.md) (Phase 3 escalation)

**Description**: Replace the `fully_saturated_bmcs_exists` axiom in TemporalCoherentConstruction.lean with a constructive proof, achieving fully axiom-free completeness. The axiom currently requires: (1) context preservation, (2) temporal coherence, and (3) modal saturation. Tasks 870/880 have proven temporal coherence via ZornFamily/DovetailingChain, but modal saturation remains. Modal saturation requires that every Diamond formula in a family's MCS has a witness family in the bundle where the inner formula holds. The construction must enumerate all Diamond formulas (neg(Box(neg psi))) and extend the family set to include witnesses. Key approaches: (a) Extend ZornFamily with modal witness enumeration using Zorn's lemma on families satisfying both temporal coherence AND modal saturation conditions, (b) Extend DovetailingChain to interleave modal witness creation with temporal witness creation, or (c) Post-process a temporally coherent family by iteratively adding modal witnesses until saturated. Critical challenge: Proving termination/well-foundedness when adding infinitely many witness families. Success eliminates the final axiom blocker for sorry-free completeness, connecting proven temporal infrastructure (RecursiveSeed, ZornFamily) to the representation theorem. See ModalSaturation.lean for is_modally_saturated definition, Completeness.lean for usage, and DovetailingChain.lean/ZornFamily.lean for temporal coherence infrastructure to extend.

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

### 865. Construct canonical task frame for Bimodal completeness
- **Effort**: TBD
- **Status**: [RESEARCHING]
- **Language**: lean
- **Created**: 2026-02-05
- **Researched**: 2026-02-10
- **Research**: [research-001.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-001.md), [research-002.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-002.md), [research-003.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-003.md), [research-004.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-004.md), [research-005.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-005.md)

**Description**: Research and construct a canonical task frame (world-states, task relation, durations) for the Bimodal logic representation theorem. Define a two-place task relation w ⇒ u where: (1) φ ∈ u whenever □G φ ∈ w; (2) φ ∈ w whenever □H φ ∈ u; with witness conditions (GW) and (HW). World histories are functions τ from a totally ordered commutative group of durations to MCSs respecting the task relation. Key challenges: constructing durations from syntax, building a proper three-place task relation matching the semantics, and possibly using the two-place task relation to construct a topology (closeness via possible nearness in time) with durations abstracted as equivalence classes. The construction should culminate in a seed built from a consistent sentence of arbitrary complexity, with the canonical model satisfying the TruthLemma as the guiding North Star.

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


