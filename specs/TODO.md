---
next_project_number: 928
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-02-20T00:15:00Z
task_counts:
  active: 10
  completed: 635
  in_progress: 0
  not_started: 1
  abandoned: 36
  total: 681
technical_debt:
  sorry_count: 123
  axiom_count: 19
  build_errors: 0
  status: manageable
---

# TODO

## Tasks

### 927. Fix status synchronization between plan files, TODO.md, and state.json
- **Effort**: 3.5 hours
- **Status**: [COMPLETED]
- **Language**: meta
- **Created**: 2026-02-25
- **Completed**: 2026-02-25
- **Research**: [research-001.md](specs/927_fix_status_synchronization_plan_todo_state/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/927_fix_status_synchronization_plan_todo_state/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260225.md](specs/927_fix_status_synchronization_plan_todo_state/summaries/implementation-summary-20260225.md)

**Description**: Fix status synchronization to ensure plan file status (line 4), TODO.md status, and state.json status all update together. Currently the plan file status sometimes doesn't get updated while the other two are correctly updated.

---

### 926. Audit agent system for context efficiency and reduce startup bloat
- **Effort**: 4-6 hours
- **Status**: [COMPLETED]
- **Language**: meta
- **Created**: 2026-02-25
- **Completed**: 2026-02-25
- **Research**: [research-001.md](specs/926_audit_agent_system_context_efficiency/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/926_audit_agent_system_context_efficiency/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260225.md](specs/926_audit_agent_system_context_efficiency/summaries/implementation-summary-20260225.md)

**Description**: Context usage is 20% immediately when starting a new Claude Code session. Review agent system complexity and identify opportunities to reduce context bloat following 2026 best practices.

---

### 925. Redesign BMCS completeness construction using MCS accessibility relation
- **Effort**: 12-20 hours
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-25
- **Completed**: 2026-02-25
- **Supersedes**: Tasks 916, 922, 924
- **Research**: [research-001.md](specs/925_redesign_bmcs_completeness_mcs_accessibility/reports/research-001.md), [research-002.md](specs/925_redesign_bmcs_completeness_mcs_accessibility/reports/research-002.md), [research-003.md](specs/925_redesign_bmcs_completeness_mcs_accessibility/reports/research-003.md), [research-004.md](specs/925_redesign_bmcs_completeness_mcs_accessibility/reports/research-004.md)
- **Plan**: [implementation-001.md](specs/925_redesign_bmcs_completeness_mcs_accessibility/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260225.md](specs/925_redesign_bmcs_completeness_mcs_accessibility/summaries/implementation-summary-20260225.md)

**Description**: Tasks 924, 922, and 916 have hit major issues requiring architectural redesign.

**Problems to remove**:
1. Standard witness families are CONSTANT (same MCS at every time) - needs fix to admit non-constant families
2. Truth lemma assumed only needed for eval family - hits dead end for complex formulas
3. Taking all MCSs to form a single canonical family does not work

**Correct path**:
1. Define MCSs as world states
2. Define four-constraint accessibility relation: MCS1 related to MCS2 iff whenever `Box G phi` in MCS1, then `phi` in MCS2
3. Define families as functions `Int -> MCS` where each MCS sees the next (or is seen by previous) via accessibility
4. This constructs a bundle of families resembling world histories
5. Prove every consistent sentence belongs to an MCS at time 0 in some family
6. Establish TruthLemma: sentence in MCS in family iff sentence true when evaluated at that family at corresponding integer

This construction is the core of the representation theorem.

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

### 923. Formalize frame correspondence theorem for linearity axiom
- **Effort**: 4-8 hours
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-24
- **Completed**: 2026-02-24
- **Research**: [research-001.md](specs/923_formalize_frame_correspondence_linearity/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/923_formalize_frame_correspondence_linearity/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260224.md](specs/923_formalize_frame_correspondence_linearity/summaries/implementation-summary-20260224.md)

**Description**: Formalize the frame correspondence theorem to show that the linearity axiom characterizes linear frames. This theorem proves: if the linearity axiom schema F(p) AND F(q) -> F(p AND q) OR F(p AND F(q)) OR F(F(p) AND q) is valid on a Kripke frame, then the frame's accessibility relation is linear. Required to complete task 922's Phase 3 blocker (canonical_reachable_linear theorem).

---

### 922. Strategy study: identify viable path for forward_F/backward_P completeness
- **Effort**: 8-16 hours
- **Status**: [IMPLEMENTING]
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

### 921. Enforce zero-proof-debt policy for Lean task completion
- **Effort**: 2.5 hours
- **Status**: [COMPLETED]
- **Language**: meta
- **Created**: 2026-02-24
- **Started**: 2026-02-25
- **Completed**: 2026-02-25
- **Research**: [research-001.md](specs/921_enforce_zero_proof_debt_policy_for_lean_task_completion/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/921_enforce_zero_proof_debt_policy_for_lean_task_completion/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260224.md](specs/921_enforce_zero_proof_debt_policy_for_lean_task_completion/summaries/implementation-summary-20260224.md)

**Description**: Update all Lean-related agents, skills, policy documents, and plan formats to enforce a strict zero-proof-debt completion gate. The policy must make crystal clear: (1) NO sorry may remain in a completed Lean task - all sorries must be closed before a task is marked [COMPLETED]; (2) NO new axioms may ever be introduced; (3) proof debt acceptance (e.g. "Option B" sorry deferral as in task 916 research-014) is FORBIDDEN under any circumstances. Components to update: (Phase 1) `proof-debt-policy.md` - add explicit Completion Gate section stating sorries must be resolved before task completion, clarify axioms are never acceptable even for internal work; (Phase 2) `lean-implementation-agent.md` - add MUST DO zero-sorry verification before returning implemented status, add MUST NOT returning implemented status with remaining sorries, add completion gate check in build verification stage; (Phase 3) `lean-research-agent.md` - add requirement to flag tasks that propose sorry debt acceptance as FORBIDDEN, clarify Option B style deferral is not a valid recommendation; `planner-agent.md` - add Lean-specific requirement that final plan phase must include sorry elimination verification; (Phase 4) `plan-format.md` - update Sorry Characterization to require zero-sorry target in "New Sorries" section, update Axiom Characterization to forbid new axioms; `skill-lean-implementation/SKILL.md` - add sorry count verification before accepting implemented status from subagent.

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

### 915. Document BFMCS proof architecture and remaining lacunae
- **Effort**: 3-5 hours
- **Status**: [COMPLETED]
- **Language**: meta
- **Created**: 2026-02-20
- **Research**: [research-001.md](specs/915_document_bfmcs_proof_architecture/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/915_document_bfmcs_proof_architecture/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260220.md](specs/915_document_bfmcs_proof_architecture/summaries/implementation-summary-20260220.md)

**Description**: Write comprehensive documentation explaining the two-level bundling ontology (BFMCS = temporal family, BMCS = modal bundle of families), the propagation requirements as construction constraints, why G-content propagates automatically while F-obligations require explicit witness tracking, the consistency argument via `temporal_witness_seed_consistent`, and precisely where the 4 remaining sorries in DovetailingChain.lean are and what closes them.

---

### 914. Rename IndexedMCSFamily to BFMCS across codebase
- **Effort**: 2-4 hours
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-20
- **Research**: [research-001.md](specs/914_rename_indexedmcsfamily_to_bfmcs/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/914_rename_indexedmcsfamily_to_bfmcs/plans/implementation-001.md)
- **Summary**: [implementation-summary-20260220.md](specs/914_rename_indexedmcsfamily_to_bfmcs/summaries/implementation-summary-20260220.md)

**Description**: Rename `IndexedMCSFamily` to `BFMCS` (Bundled Family of Maximal Consistent Sets) across 420 occurrences in 38 files to make the two-level ontological structure explicit. Rename `IndexedMCSFamily.lean` to `BFMCS.lean`, update all imports, and add doc comments explaining the BFMCS ontology.

---

### 912. Review completeness proof and metalogic state after task 910
- **Effort**: 18-27 hours (revised)
- **Status**: [COMPLETED]
- **Language**: lean
- **Created**: 2026-02-19
- **Researched**: 2026-02-19
- **Planned**: 2026-02-20
- **Completed**: 2026-02-19
- **Research**: [research-001.md](specs/912_review_completeness_proof_metalogic_state/reports/research-001.md), [research-002.md](specs/912_review_completeness_proof_metalogic_state/reports/research-002.md), [research-003.md](specs/912_review_completeness_proof_metalogic_state/reports/research-003.md)
- **Plan**: [implementation-002.md](specs/912_review_completeness_proof_metalogic_state/plans/implementation-002.md) (v2: ShiftClosed Omega approach)
- **Summary**: [implementation-summary-20260219.md](specs/912_review_completeness_proof_metalogic_state/summaries/implementation-summary-20260219.md)

**Description**: Systematically review the state of the completeness proof by way of the representation theorem and the FMP in order to evaluate the state of the metalogic, what has been finished, what remains to be done, and what can be archived to the Bimodal/Boneyard/, and how best to refactor or reorganize the metalogic.

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


