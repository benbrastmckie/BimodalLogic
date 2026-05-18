---
next_project_number: 163
repository_health:
  overall_score: 95
  production_readiness: near-publication
  last_assessed: 2026-05-15T21:30:00Z
task_counts:
  active: 14
  completed: 784
  in_progress: 0
  not_started: 9
  abandoned: 85
  total: 879
technical_debt:
  sorry_count: 1
  sorry_count_note: "Audited 2026-05-15: 1 root sorry on bx_completeness critical path: succ_cofinal (ChronicleToCountermodel.lean:1885) blocks limitDomSubtype_isSuccArchimedean → succ_embed_surjective → discrete countermodel → bx_completeness. Dense case sorry-free (dd_countermodel_chronicle_dense). Mixed case sorry-free (dd_countermodel_chronicle_mixed_sorry via False.elim, task 142). Tasks 143-148 closed NormalForm/KType/table_correctness sorries. Two paths to eliminate succ_cofinal: direct proof (task 153) or Reynolds pipeline bypass (tasks 154-155). ~17 dead-code sorries in BXCanonical pipeline (bypassed by Chronicle). ~6 non-critical TruthLemma sorries. Soundness, SoundnessLemmas, and Decidability are sorry-free."
  publication_path_sorries: 1
  axiom_count: 0
  axiom_count_note: "Zero custom axioms. Prior-UZ/SZ and discrete_box_necessity are standard axiom constructors with sorry-free soundness proofs."
  build_errors: 0
  status: excellent
---

# TODO

<!-- Vault transition: 2026-03-20 - Archived to specs/vault/01-vault/ -->

## Task Order

*Updated 2026-05-15. Generated from state.json dependency graph.*

**Goal**: Sorry-free `bx_completeness` → module reorganization → frame hierarchy → formula refactor → expressive extensions → algebraic representation.

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 21,60,95,112,114,116,122,126,127,130,131,619,949,953,992,998 | -- | completeness, formula-refactor, frame-extensions, ... |
| 2 | 125,128,155 | 116,122 | completeness, frame-extensions, algebraic-representation |

**Grouped by Topic** (indented = must complete first):

### Completeness

21 [NOT STARTED] — Clean up technical debt from metalogic refactoring track (tasks 9
95 [NOT STARTED] — Verification pass on bx_completeness sorry status. Updated scope:
155 [RESEARCHED] — Replace the chronicle fallback in Transfer.lean with the full Rey


### Formula Refactor

60 [NOT STARTED] — discrete_Icc_finite_axiom was already eliminated (zero custom axi
116 [PLANNED] — Remove all_future (G) and all_past (H) as primitive constructors 
130 [NOT STARTED] — After task 129 provides IsSuccArchimedean via weak/reflexive comp
131 [NOT STARTED] — Restructure Theories/Bimodal/ file hierarchy for clean APIs and d


### Frame Extensions

122 [RESEARCHED] — Build discrete BFMCS on Z and complete dd_countermodel_chronicle_
126 [RESEARCHED] — Establish a four-tier axiom hierarchy with explicit frame corresp
127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ is 
128 [NOT STARTED] — Add topological open set (interior) operator for dense and contin
  └─ 122 [RESEARCHED] — Build discrete BFMCS on Z and complete dd_countermodel_chronicle_ (see above)
998 [RESEARCHING] — Redesign the FMP filtration for strict temporal semantics. The 2 


### Algebraic Representation

112 [RESEARCHED] — literature_study_representation_theorem
125 [NOT STARTED] — Research algebraic methods for establishing a Jónsson-Tarski-styl
  └─ 116 [PLANNED] — (formula-refactor: Remove all_future (G) and all_past (H) a) (see above)
  └─ 122 [RESEARCHED] — (frame-extensions: Build discrete BFMCS on Z and complete d) (see above)
992 [RESEARCHED] — Implement the Shift-Closed Tense S5 Algebra (STSA) representation


### Bilateral

953 [RESEARCHED] — Refactor unilateral proof system (Γ ⊢ φ) to bilateral system with


### Agent System

114 [NOT STARTED] — Add a .claude/rules/ rule enforcing plan compliance for implement
619 [RESEARCHED] — agent_system_architecture_upgrade
949 [RESEARCHED] — update_demo_lean_bimodal_logic


## Tasks

### 162. Enforce strict plan compliance for formal implementation agents
- **Effort**: small
- **Status**: [NOT STARTED]
- **Task Type**: meta

**Description**: Add a .claude/rules/ rule enforcing strict plan compliance for lean-implementation-agent and other formal implementation agents. The rule should: (1) Prohibit agents from "assessing what's truly minimal" or inventing alternative approaches when a plan exists. (2) Require agents to follow the plan's exact task sequence step-by-step, in order. (3) Explicitly ban common divergence patterns: skipping intermediate theorems, inlining proofs instead of following the plan's decomposition, routing through different helper lemmas than specified, and "cleaner approach" rationalizations. (4) Be auto-applied via glob pattern to Theories/ and any formal proof files. (5) Reference the repeated failures in task 157 (8 plan versions, agents diverging every time) as motivation. The rule should be concise but firm -- agents must treat the plan as a contract, not a suggestion.

### 161. Rename Theories/Bimodal/ to FormalSystem/
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Rename Theories/Bimodal/ to FormalSystem/. Move the entire Theories/Bimodal/ directory to FormalSystem/, update all imports in Lean files, update lakefile.lean srcDir from Theories to FormalSystem and roots from Bimodal to FormalSystem, update any references in README.md, Tests/, and other files that point to the old path. Ensure lake build still passes after the rename.

### 160. Fix failing CI badge in README.md
- **Effort**: small
- **Status**: [COMPLETED]
- **Task Type**: general
- **Research**: [160_fix_ci_badge_failing/reports/01_ci-badge-research.md]
- **Plan**: [160_fix_ci_badge_failing/plans/01_fix-ci-badge.md]
- **Summary**: [160_fix_ci_badge_failing/summaries/01_fix-ci-badge-summary.md]

**Description**: Fix the CI badge on line 3 of README.md which currently shows as failing on GitHub. Investigate the GitHub Actions workflow at .github/workflows/ci.yml, determine why CI is failing (likely due to the example file deletions from task 158 or other recent changes), fix the build or workflow configuration, and ensure the badge shows as passing.

### 159. Refactor Formula to remove all_past and all_future as primitive constructors
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Refactor Formula inductive type to remove all_past (H) and all_future (G) as primitive constructors, making them derived operators defined as G := ¬F¬ and H := ¬P¬, where F := U(φ, ¬⊥) and P := S(φ, ¬⊥). Currently the Lean source has 7 primitive constructors (bot, imp, box, all_past, all_future, untl, snce) but the README and the intended mathematical presentation treats only 5 as primitive (bot, imp, box, untl, snce). This requires updating the Formula inductive type, redefining G/H/F/P as defs, updating all pattern matches on Formula throughout the codebase (Syntax/, ProofSystem/, Semantics/, Metalogic/, Theorems/, Automation/, Examples/, Tests/), updating the axiom system to use the new derived definitions, and verifying that soundness/completeness/decidability proofs still compile. This is a large structural refactor touching most files in the codebase.

### 158. Update README.md to reflect metalogic progress and improve organization
- **Effort**: small
- **Status**: [COMPLETED]
- **Task Type**: markdown
- **Research**: [specs/158_update_readme_metalogic_progress/reports/01_team-research.md]
- **Plan**: [158_update_readme_metalogic_progress/plans/01_readme-overhaul-plan.md]
- **Summary**: [158_update_readme_metalogic_progress/summaries/01_readme-overhaul-summary.md]

**Description**: Update README.md to reflect metalogic progress in BimodalLogic. Explain that this is the intensional bimodal fragment of the Logos developed by Logos Laboratories (link to https://logos-labs.ai/). Move codebase size to end of intro (not at end, not immediately). After introductions covering operators, task semantics, research paper, demo, and project structure, add sections for installation, core metalogical results (soundness and completeness for extensions of the base logic with a labeled mermaid diagram), documentation, related projects, and citation. README should be well-organized, clear, and concise.

### 157. Formalize expressive completeness of {S,U} over integer time
- **Effort**: 3-4 weeks (~2500 lines)
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: 155
- **Research**:
  - [specs/157_expressive_completeness_su_integer/reports/01_expressive-completeness-proof.md]
  - [specs/157_expressive_completeness_su_integer/reports/04_team-research.md]
  - [specs/157_expressive_completeness_su_integer/reports/05_team-research.md]
  - [157_expressive_completeness_su_integer/reports/06_team-research.md]
  - [157_expressive_completeness_su_integer/reports/07_team-research.md]
- **Plan**:
  - [157_expressive_completeness_su_integer/plans/05_dedekind-approach-plan.md]
  - [157_expressive_completeness_su_integer/plans/06_phase7-first-plan.md]
  - [157_expressive_completeness_su_integer/plans/07_complete-remaining-plan.md]
- **Summary**: [specs/157_expressive_completeness_su_integer/summaries/06_implementation-summary.md]
  - [157_expressive_completeness_su_integer/plans/07_dedekind-specialization-plan.md]

**Description**: Formalize expressive completeness of {S,U} over integer time (GHR94 Ch 10.2 separation theorem). Prove that every monadic first-order sentence over integer time has a temporal {U,S} equivalent (Theorem 10.2.9-10.2.10). This is Reynolds's Theorem 5, required as prerequisite for Phase 3B of task 155 (gap elimination, Reynolds Theorem 14). Literature: GHR94 Chapters 9-10 (in literature/ with markdown conversions). Proof structure: 8 elimination cases (pulling U out of S and vice versa), nested 4-level induction (junction depth -> nesting depth -> number of U-subformulas -> single case).

---

### 156. Improve formal/lean/math/logic research agents with multi-angle team research strategy
- **Effort**: 4-8 hours
- **Status**: [NOT STARTED]
- **Task Type**: meta
- **Priority**: medium

**Description**: Improve formal/lean/math/logic research agents with multi-angle team research strategy. In the task 154 research cycle, a proof blocker persisted through multiple single-agent rounds. What broke through was launching 4 parallel agents each assigned a distinct angle: (A) backward from sorry sites using lean_goal/lean_multi_attempt, (B) infrastructure inventory with exact signatures and gap analysis, (C) literature review assessing approach soundness, (D) decomposition into small lemmas with lean_run_code verification. Improvements: (1) Add multi-angle analysis mode to lean-research-agent, (2) Always try lean_multi_attempt/lean_run_code to verify solutions compile, (3) Add guidance for when to recommend team research after repeated blockers, (4) Add prototype-first research pattern, (5) Update formal-research-agent to auto-route to multi-angle team research when multiple handoffs indicate the same blocker.

---

### 155. Activate Reynolds pipeline for sorry-free discrete completeness
- **Effort**: 6-10 hours
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: 154
- **Research**:
  - [specs/155_reynolds_pipeline_activation/reports/01_team-research.md]
  - [specs/155_reynolds_pipeline_activation/reports/02_team-research.md]
- **Plan**:
  - [155_reynolds_pipeline_activation/plans/01_reynolds-pipeline-plan.md]
  - [155_reynolds_pipeline_activation/plans/02_reynolds-pipeline-plan.md]

**Description**: Replace the chronicle fallback in Transfer.lean with the full Reynolds Theorem 15 pipeline, eliminating `succ_cofinal` from `bx_completeness`. Rather than bridging `ZIntervalStructure` to `TaskFrame` via an adapter, refactor the pipeline to construct a `TaskFrame Int` directly from the Reynolds output. Wire `chronicle_is_good` (unblocked by task 154), `table_correctness` (sorry-free from tasks 147-148), and a direct `TaskFrame` construction into Transfer.lean. Definition of done: `doets_countermodel_discrete` uses Reynolds pipeline, `bx_completeness` has no `sorryAx`, `lake build` passes.

---

### 154. Prove sum_preservation via Ehrenfeucht-Fraisse games (Doets Lemma 1.4)
- **Effort**: 8-15 hours
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: None
- **Report**: [specs/154_sum_preservation_ef_games/reports/01_sum-preservation-research.md]
- **Research**:
  - [154_sum_preservation_ef_games/reports/02_team-research.md]
  - [154_sum_preservation_ef_games/reports/03_team-research.md]
  - [specs/154_sum_preservation_ef_games/reports/04_literature-approach.md]
  - [specs/154_sum_preservation_ef_games/reports/05_team-research.md]
  - [154_sum_preservation_ef_games/reports/06_team-research.md]
  - [154_sum_preservation_ef_games/reports/07_team-research.md]
- **Plan**:
  - [154_sum_preservation_ef_games/plans/02_sum-preservation-plan.md]
  - [154_sum_preservation_ef_games/plans/03_sum-preservation-plan.md]
  - [154_sum_preservation_ef_games/plans/04_sum-preservation-plan.md]
  - [154_sum_preservation_ef_games/plans/06_sum-preservation-plan.md]
  - [154_sum_preservation_ef_games/plans/07_sum-preservation-plan.md]

**Description**: Prove `sum_preservation` (NEquivalence.lean:190) and `doets_lemma_1_4` (OrderedSum.lean:45): k-equivalence is preserved under ordered sums of monadic structures. The proof follows Doets 1987 Lemma 1.4 using Ehrenfeucht-Fraisse games. Also close the `carrier_order` sorries in the Sigma-type ordered sum construction (lexicographic order), and downstream sorries in `contemp_equiv_is_equiv` transitivity (IntegerModel.lean:128) and `no_gaps_discrete` (IntegerModel.lean:145). Definition of done: `sum_preservation` sorry-free, `doets_lemma_1_4` sorry-free, `carrier_order` defined (not sorry), `lake build` passes.

---

### 152. Task Order topic grouping and wave separation
- **Effort**: 3-6 hours
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Dependencies**: Task #149, Task #150
- **Research**:
  - [152_task_order_topic_grouping/reports/01_topic-grouping-research.md]
  - [152_task_order_topic_grouping/reports/02_topic-field-population.md]
- **Plan**:
  - [152_task_order_topic_grouping/plans/01_topic-grouping.md]
  - [152_task_order_topic_grouping/plans/02_topic-grouping.md]
- **Summary**: [152_task_order_topic_grouping/summaries/02_topic-grouping-summary.md]
- **Description**: Improve Task Order UX in TODO.md by splitting the monolithic dependency tree into grouped, scannable sections. Detect independent subgraphs (connected components), add optional topic field to state.json, update generate-task-order.sh to group roots by topic with per-group code blocks and markdown headings, enhance wave table with topic breakdown, and backfill topic for existing tasks.

---

### 149. Redesign Task Order format and generation script
- **Effort**: 3-6 hours
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Dependencies**: None
- **Research**: [149_redesign_task_order_format/reports/01_format-redesign-research.md]
- **Plan**: [149_redesign_task_order_format/plans/01_task-order-redesign.md]
- **Summary**: [149_redesign_task_order_format/summaries/01_task-order-redesign-summary.md]

**Description**: Redesign the Task Order section format in TODO.md. Replace flat category lists with dependency wave table and indented dependency tree format. Create `generate-task-order.sh` script to regenerate Task Order from state.json dependency graph. Update `task-order-format.md` spec with new wave+tree format definition. Files: `.claude/context/formats/task-order-format.md` (redesign), `.claude/scripts/generate-task-order.sh` (new).

---

### 150. Task Order auto-pruning and auto-insertion
- **Effort**: 3-6 hours
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Dependencies**: Task #149
- **Research**: [150_task_order_auto_sync/reports/01_task-order-auto-sync.md]
- **Plan**: [150_task_order_auto_sync/plans/01_task-order-auto-sync.md]
- **Summary**: [150_task_order_auto_sync/summaries/01_task-order-auto-sync-summary.md]

**Description**: Add automatic Task Order synchronization. Update `update-task-status.sh` to auto-prune completed tasks from Task Order when status is set to [COMPLETED]. Update `/task` command to auto-insert new tasks into Task Order with correct dependencies. Add sync validation logic to detect and auto-correct drift between Task Order status markers and state.json. Files: `.claude/scripts/update-task-status.sh`, `.claude/commands/task.md`.

---

### 151. Task Order command integration and rules
- **Effort**: 1-3 hours
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Dependencies**: Task #149
- **Research**: [151_task_order_command_integration/reports/01_command-integration.md]
- **Plan**: [151_task_order_command_integration/plans/01_command-integration.md]
- **Summary**: [151_task_order_command_integration/summaries/01_command-integration-summary.md]

**Description**: Integrate Task Order with `/todo` and `/review` commands. Update `/todo` to regenerate Task Order during archive flow using `generate-task-order.sh`. Update `/review` to use new wave+tree format instead of old pruning logic. Add Task Order sync rules to `state-management.md`. Files: `.claude/commands/todo.md`, `.claude/commands/review.md` (Section 6.5), `.claude/rules/state-management.md`.

---

### 147. Prove lift_eval and insertEnv De Bruijn substitution lemmas
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-05-15
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: None
- **Research**: [specs/147_lift_eval_insertenv_lemmas/reports/01_scope-analysis.md]
- **Plan**: [147_lift_eval_insertenv_lemmas/plans/01_debruijn-plan.md]
- **Summary**: [specs/147_lift_eval_insertenv_lemmas/summaries/01_debruijn-summary.md]

**Description**: Prove the 4 De Bruijn substitution lemmas in NEquivalence.lean left sorry by task 140: `insertEnv_zero_eq_cons` (inserting at 0 equals Fin.cons), `insertEnv_succ_cons` (commutation of insertEnv with Fin.cons under binders), `insertEnv_finLift` (inverse relationship between insertEnv and finLift), and `lift_eval` (main substitution lemma: evaluating a lifted formula in an inserted environment recovers original evaluation). Pure Fin-arithmetic / function-extensionality proofs. Once proved, `weaken_eval` becomes sorry-free automatically.

---

### 148. Complete table_correctness temporal operator cases
- **Effort**: 1.5-2 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-05-15
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: 147
- **Research**:
  - [specs/148_table_correctness_temporal_cases/reports/01_scope-analysis.md]
  - [specs/148_table_correctness_temporal_cases/reports/02_proof-development.md]
- **Plan**: [specs/148_table_correctness_temporal_cases/plans/02_proof-plan.md]
- **Summary**: [specs/148_table_correctness_temporal_cases/summaries/02_proof-summary.md]

**Description**: Close the 4 temporal operator cases of `table_correctness` (`all_future`, `all_past`, `untl`, `snce`) in Table.lean, plus 2 helper lemmas (`cons_eq_insertEnv_one`, `cons3_eq_insertEnv`). Each temporal case: unfold definitions, apply `lift1_eval`/`lift1_lift1_eval`, use induction hypothesis. Also fix `chronicle_is_good` atomMap signature in Transfer.lean step 3 comment and update pipeline status table. Result: `table_correctness` fully sorry-free with `lean_verify` showing no `sorryAx`.

---

### 143. Doets Lemma 1.1: normal form KType redesign with finite domain
- **Effort**: 6-9 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-05-15
- **Task Type**: lean4
- **Priority**: critical
- **Dependencies**: 139
- **Plan**: [143_doets_lemma_1_1_normal_form_ktype/plans/02_revised-plan.md]
- **Summary**: Doets Lemma 1.1 proved sorry-free. KType redesigned to NormalForm domain (task 145). k_equiv_monotone closed (task 145). Dead code removed, cardinality theorems proved (task 146). finite_types closed.

**Description**: Prove Doets 1989 Lemma 1.1 (finitely many formulas up to logical equivalence) and redesign `KType` with a finite normal form domain, closing `ktype_finite` and `KEquivalenceFramework.finite_types`.

The current `KType` uses an infinite domain (`{s : MonadicFormula sig 0 // s.quantifier_depth ≤ k} → Bool`) making `Fintype` impossible. The correct mathematical object (Doets 1987 Chapter 1, Section 1.6-1.7) is the space of n-characteristics. Define `NormalForm sig k n` as a finite type of Hintikka formula representatives, prove every formula is equivalent to one (Doets Lemma 1.1 by induction on k), redefine `KType sig k := NormalForm sig k 0 → Bool`, and close `finite_types` via `Setoid.quotientKerEquivRange`.

**Literature**: Doets 1987 thesis Ch. 1 (Sections 1.6-1.7), Doets 1989 Lemma 1.1.

- **Research**:
  - [specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_team-research.md]
  - [specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_teammate-a-findings.md]
  - [specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_teammate-b-findings.md]
  - [specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_teammate-c-findings.md]
  - [specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_teammate-d-findings.md]

---

### 145. Split NEquivalence.lean, redesign KType to NormalForm, close k_equiv_monotone
- **Effort**: 3-5 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-05-15
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: 143
- **Research**: [specs/145_split_nequivalence_close_k_equiv_monotone/reports/01_split-design.md]
- **Plan**: [145_split_nequivalence_close_k_equiv_monotone/plans/01_split-plan.md]
- **Summary**: [specs/145_split_nequivalence_close_k_equiv_monotone/summaries/01_split-summary.md]

**Description**: Split NEquivalence.lean into MonadicFO.lean (pure FO definitions: MonadicSignature, MonadicFormula, eval, atomCount, nfCount, NormalFormIdx) and NEquivalence.lean (k-equiv framework). Break the circular import so NEquivalence.lean can import NormalForm.lean. Redefine `KType sig k := NormalForm sig k 0 -> Bool` (replacing NormalFormIdx). Redefine `k_type_of` using `nf_eval_nf` (replacing vacuous `nf_rep`). Close `k_equiv_monotone` sorry via `nf_agreement_monotone`. Delete `nf_rep`. Verify `finite_types` remains closed and `lake build` passes.

---

### 146. NormalForm legacy cleanup and cardinality correspondence proof
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-05-15
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 145
- **Research**:
  - [specs/146_normalform_cleanup_cardinality/reports/01_cleanup-design.md]
  - [specs/146_normalform_cleanup_cardinality/reports/02_post-split-audit.md]
- **Plan**: [specs/146_normalform_cleanup_cardinality/plans/02_cleanup-plan.md]
- **Summary**: [specs/146_normalform_cleanup_cardinality/summaries/02_cleanup-summary.md]

**Description**: Remove legacy dead code (vacuous `nf_eval`, `nf_vector`, `normalFormIdx_nonempty`) from NormalForm.lean. Prove cardinality correspondences: `Fintype.card (AtomKind sig n) = atomCount p n` and `Fintype.card (NormalForm sig k n) = nfCount p k n`, confirming the counting function matches the actual type. Update docstrings for publication quality. Optionally prove `normalForm_equiv_fin : NormalForm sig k n ≃ NormalFormIdx sig k n`.

---

### 131. Refactor module organization for clean APIs and documentation
- **Effort**: 15-25 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Restructure Theories/Bimodal/ file hierarchy for clean APIs and documentation. Currently 130 live .lean files across 7 top-level directories, with the Metalogic/ directory being a catch-all containing 7 subdirectories (Algebraic, Bundle, BXCanonical, ConservativeExtension, Core, Decidability, Relational) plus loose files (Soundness.lean, SoundnessLemmas.lean, DenseSoundness.lean, DiscreteSoundness.lean, Completeness.lean, Metalogic.lean). Goals: (1) Reorganize Metalogic/ into a clearer hierarchy — group soundness files into Metalogic/Soundness/, completeness files into Metalogic/Completeness/, clarify relationship between BXCanonical (chronicle approach) and Algebraic (parametric approach). (2) Add module-level documentation (docstrings on namespace declarations, module descriptions at file tops). (3) Establish clean APIs with explicit exports via root .lean files for each subdirectory. (4) Evaluate whether FrameConditions/ should be merged into Metalogic/ or remain separate. (5) Audit Boneyard/ organization (45 files across 10+ subdirectories). (6) Consider whether docs/ and latex/ and typst/ should remain under Theories/Bimodal/ or move to project root.

---

### 142. Mixed-case countermodel for bx_completeness
- **Effort**: 8 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-05-15
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: None
- **Research**:
  - [specs/142_mixed_case_countermodel/reports/01_mixed-case-research.md]
  - [142_mixed_case_countermodel/reports/02_team-research.md]
  - [142_mixed_case_countermodel/reports/04_team-research.md]
- **Plan**: [142_mixed_case_countermodel/plans/04_structural-axiom-plan.md]
- **Summary**: All 5 phases complete. Added structural axiom `discrete_box_necessity` (U(T,bot) → □(U(T,bot))). Proved soundness via translation-invariance. Derived `mcs_mixed_case_absurd` showing mixed case is impossible. `dd_countermodel_chronicle_mixed_sorry` proved via `False.elim`. Axiom count 41→42.

**Description**: Resolved the mixed-case sorry in `bx_completeness` by adding the structural axiom `discrete_box_necessity` and proving the mixed case contradictory.

---

### 130. Archive dead sorries to Boneyard
- **Effort**: 4-8 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 129

**Description**: After task 129 provides IsSuccArchimedean via weak/reflexive completeness, archive all dead-code sorries to the Boneyard. Includes: (1) succ_reaches_dom_N boundary cases (ChronicleToCountermodel.lean) — stage induction superseded by Henkin model. (2) limit_dom_points_are_succ_iterates — convergence approach superseded. (3) succ_cofinal gap analysis — entire convergence + Z1 gap section. (4) BXCanonical pipeline dead code (Quasimodel/Realization, Quasimodel/Construction, TruthLemma, RootScopedChain, Filtration/SigmaOrdering, Frame) — bypassed by Chronicle. (5) Bundle/SuccRelation and Bundle/SuccExistence sorries if no longer needed. Total: ~40 sorries to archive.

---

### 128. Open set (interior) operator for dense and continuous temporal frames
- **Effort**: 15-25 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: 122

**Description**: Add topological interior operator for dense and continuous temporal frames. On discrete Z the interior is trivial, but on dense Q and continuous R it captures neighborhood-stable truth: Int(phi) true at t iff phi holds in an open neighborhood of t. Related to Dynamic Topological Logic (Kremer-Mints 2005), McKinsey-Tarski topological semantics for S4. Phases: TopologicalSpace instance for dense/continuous TaskFrame, interior Formula constructor with truth clause, S4-like axioms (Int(phi)->phi, Int(phi)->Int(Int(phi))), interaction with temporal operators and S5 box. Note: DTL is not finitely axiomatizable (Fernandez-Duque 2014).

---

### 127. Time addition operator (+) for bimodal logic TM
- **Effort**: 20-40 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: 123

**Description**: Add time addition operator to TM. phi + psi true at (tau, x) iff there exist y,z with x = y+z and phi at (tau,y) and psi at (tau,z). Internalizes AddCommGroup structure into the object language, extending expressive power from FO[<] to FO[<,+] (Presburger arithmetic). Related to arrow logic (Venema), relevant logic (Routley-Meyer ternary frames), separation logic (BI). Phases: add tadd/tsub constructors to Formula, truth clause, basic axioms (associativity, commutativity, identity, inverse), soundness, interaction with G/H/U/S/box. Completeness (ternary canonical model) and decidability are open research problems.

---

### 125. Jónsson-Tarski representation theorem for bimodal S/U/□ logic
- **Effort**: 15-25 hours
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Dependencies**: 123, 124, 122, 116, 115

**Description**: Research algebraic methods for establishing a Jónsson-Tarski-style representation theorem for the bimodal logic TM with primitives Since (S), Until (U), and Box (□), plus material implication (→) and bottom (⊥). Key questions: (1) Does standard n-ary BAO representation apply directly to binary S/U + unary □, or does S5 interaction complicate things? (2) Role of orthodox axiomatizability (no IRR rule) per Venema 1993. (3) Can TenseS5Algebra.lean extend to a full BAO with S/U? (4) Relationship between parametric representation and Jónsson-Tarski. (5) Interaction of Prior-UZ/SZ and uniformity axioms with the algebraic representation. Literature: Venema 1991 Ch2+AppA, Venema 1993 Anti-Axioms, GHV 2003, Venema 1997, de Rijke-Venema 1995, BdRV 2001 Ch5.

---

### 122. Build discrete BFMCS on ℤ and complete discrete countermodel
- **Effort**: 8-15 hours
- **Status**: [ABANDONED]
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: 123
- **Research**: [specs/122_build_discrete_bfmcs_and_complete_countermodel/reports/01_discrete-bfmcs-research.md]

**Description**: Build discrete BFMCS on ℤ and complete `dd_countermodel_chronicle_nondense_sorry`. Mirror the dense case pattern: use `discrete_fmcs` (already exists) to build a `BFMCS Int` with restricted coherence properties, then wire into parametric representation for the countermodel. Located at ChronicleToCountermodel.lean:836.

---

### 126. Four-tier frame hierarchy: Base → Dense/Discrete → Integer extensions
- **Effort**: 15-25 hours
- **Status**: [ABANDONED]
- **Task Type**: lean4
- **Dependencies**: 123, 129
- **Research**: [specs/126_frame_hierarchy_dense_discrete_integer_extensions/reports/01_frame-hierarchy-research.md]

**Description**: Establish a four-tier axiom hierarchy with explicit frame correspondence. Tier 0 (Base): BX axioms sound on all linear orders. Tier 1a (Dense): base + density axiom GGp→Gp (characterizes DenselyOrdered). Tier 1b (Discrete): base + next_top=U(⊤,⊥) (characterizes SuccOrder/PredOrder). Tier 2 (Integer): discrete + Prior-UZ + Prior-SZ + Z1 (characterizes IsSuccArchimedean). Split valid_discrete/valid_integer, add Axiom.frameClass variants, update soundness dispatch, prove Sahlqvist-style frame correspondence for each extension axiom.

---

### 116. Redefine G, H, F, P in terms of U and S following Burgess 1982
- **Effort**: 15-25 hours
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Dependencies**: 107
- **Research**: [specs/116_redefine_ghfp_via_until_since/reports/01_redefine-ghfp-research.md]
- **Plan**: [116_redefine_ghfp_via_until_since/plans/01_redefine-ghfp-plan.md]

**Description**: Remove `all_future` (G) and `all_past` (H) as primitive constructors from the `Formula` inductive type. Define F and P as abbreviations using `untl`/`snce` with ⊤, then G and H as ¬F¬ and ¬P¬, matching Burgess 1982 §1.1. `box` (□) remains primitive (S5 modal operator). ~3200 references across codebase. Should be done AFTER task 107 Phase 9 (convention migration) to avoid double-refactoring.

---

### 114. Add plan-compliance rule for implementation agents
- **Effort**: small
- **Status**: [NOT STARTED]
- **Task Type**: meta
- **Priority**: high

**Description**: Add a `.claude/rules/` rule enforcing plan compliance for implementation agents. Root cause: lean-implementation-agent invented a "theorems-as-interval" shortcut for task 107 Phase 1 instead of following the planned Burgess D₀ seed construction. The agent definition, skill, and workflow docs tell agents HOW to execute (lean_goal, phase markers, builds) but never say they MUST follow the plan's specified approach. The rule must state: (1) agents MUST implement the plan's specified approach, not invent alternatives; (2) if agent believes a simpler approach exists, MUST write a handoff recommending `/revise` and return partial — never implement the alternative silently; (3) plan task items are binding specifications, not suggestions.

---

### 112. Systematic literature study for task 107 representation theorem
- **Effort**: medium
- **Status**: [ABANDONED]
- **Task Type**: formal
- **Research**: [specs/112_literature_study_representation_theorem/reports/01_team-research.md]

**Description**: Review 5 non-original literature sources (Burgess 1982b, Venema 1993, Obendrauf 2024, Burgess 1984, Thomason 1984) for relevance to the task 107 representation theorem. Assess how each source's techniques relate to the three-layer infrastructure problem (g-function, guard conventions, domain extension) and the hybrid approach identified in task 107 research round 15.

---

### 95. Verification audit: #print axioms + sorry classification pass
- **Effort**: 2-4 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Priority**: medium
- **Dependencies**: None
- **Created**: 2026-04-10

**Description**: Verification pass on `bx_completeness` sorry status. Updated scope: (1) Verify `dd_countermodel_chronicle_dense` and `dd_countermodel_chronicle_mixed_sorry` show no `sorryAx` (confirmed sorry-free as of 2026-05-15). (2) Trace the discrete case `sorryAx` chain: `dd_countermodel_chronicle_discrete` -> `succ_embed_surjective` -> `limitDomSubtype_isSuccArchimedean` -> `succ_cofinal` (root sorry). (3) Classify all Metalogic/ sorry occurrences as critical-path vs dead-code vs non-critical-path. (4) Update stale axiom audit comments in Completeness.lean (lines 177-234 reference CE:3570 which is no longer the sorry source). (5) Verify soundness and decidability remain sorry-free. (6) Produce audit report.
---

### 68. Prove dense_completeness_fc via Rat canonical model
- **Status**: [ABANDONED]
- **Language**: lean4

**Description**: Abandoned: target file (FrameConditions/Completeness.lean) moved to Boneyard. Dense completeness solved through `dd_countermodel_chronicle_dense`.
---

### 64. Critical path review: algebraic analysis of completeness obstacles
- **Status**: [ABANDONED]
- **Language**: lean4

**Description**: Abandoned: research-only task whose findings (Strategy C recommendations) were fully acted upon via the chronicle approach in tasks 107-142.
---

### 60. Clean up stale discrete_Icc_finite_axiom references
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Language**: lean4

**Description**: discrete_Icc_finite_axiom was already eliminated (zero custom axioms confirmed). Remaining scope: clean up stale docstrings in FrameClass.lean and SuccExistence.lean that still reference the removed axiom.

### 21. Clean up technical debt from tasks 9-20
- **Effort**: 3-5 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: None
- **Research**:
  - [01_tech-debt-audit.md](021_technical_debt_cleanup/reports/01_tech-debt-audit.md)
  - [02_team-research.md](021_technical_debt_cleanup/reports/02_team-research.md)
- **Plan**: [01_tech-debt-cleanup-plan.md](021_technical_debt_cleanup/plans/01_tech-debt-cleanup-plan.md)

**Description**: Clean up technical debt from metalogic refactoring track (tasks 9-20). Scope revised: (1) Document which metalogic paths are live (chronicle BXCanonical approach) vs dead (TimelineQuot, DenseTask, CanonicalModel parametric approach). (2) Remove dead code from non-chronicle paths or archive to Boneyard (overlaps with task 130). (3) Update stale docstrings in Metalogic/ files that reference superseded approaches. (4) Consolidate parametric representation usage documentation. Original dependency on task 18 removed (task 18 abandoned).
---

### 20. Audit and update parametric canonical infrastructure
- **Status**: [ABANDONED]
- **Language**: lean4

**Description**: Abandoned: depended on task 18 (now abandoned). Parametric infrastructure already used successfully by both dense and discrete countermodel paths.

---

### 18. Complete dense representation theorem via DenseTask
- **Status**: [ABANDONED]
- **Language**: lean4

**Description**: Abandoned: dense case solved via `dd_countermodel_chronicle_dense` (Burgess chronicle + Cantor iso on Q), verified sorry-free. TimelineQuot/DenseTask approach entirely superseded.

---

### 8. Establish genuine truth_at completeness theorems for TM logic
- **Status**: [ABANDONED]
- **Language**: lean4

**Description**: Abandoned: broad umbrella task superseded by chronicle approach. `bx_completeness` already uses `truth_at` semantics. Dense+mixed cases sorry-free. Remaining discrete sorry (`succ_cofinal`) tracked by focused tasks 153-155.

---

### 998. Redesign FMP filtration for strict temporal semantics
- **Effort**: TBD (estimated 4-8 hours)
- **Status**: [ABANDONED]
- **Language**: lean4
- **Priority**: high
- **Related**: Tasks 74-77 (strict temporal extensions research track)

**Description**: Redesign the FMP (Finite Model Property) filtration for strict temporal semantics. The 2 sorry'd theorems in `Decidability/FMP/TruthPreservation.lean` — `mcs_all_future_closure` (line 263) and `mcs_all_past_closure` (line 281) — are deprecated because the temporal T-axiom (`Gφ → φ`) is NOT valid under strict semantics. `filtration_all_future_forward` and `filtration_all_past_forward` depend on them. The FMP module is separate from the main decidability pipeline (`decide` is sorry-free), but completing it formally proves the finite model property. Resolution options: (A) restrict FMP statement to serial frames where temporal seriality holds, (B) redesign filtration to avoid temporal reflexivity entirely, (C) prove the filtered model satisfies a weaker correctness property sufficient for the FMP theorem. Note: `mcs_finite_model_property` in `FMP.lean` does NOT directly use these sorry'd lemmas, so the impact is localized to `filtration_all_future_forward`/`backward`.

---


### 992. Implement Shift-Closed Tense S5 Algebra representation theorem
- **Effort**: TBD
- **Status**: [ABANDONED]
- **Language**: lean
- **Research**: [01_stsa-algebraic-analysis.md](992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md)

**Description**: Implement the Shift-Closed Tense S5 Algebra (STSA) representation theorem. Define STSA as a Lean structure extending BooleanAlgebra with box, G, H, sigma operators and interaction axioms. Lift temporal duality sigma from swap_temporal to the Lindenbaum quotient. Prove LindenbaumAlg is an STSA instance by wiring existing pieces (BooleanStructure, InteriorOperators, UltrafilterMCS). Restructure ParametricRepresentation into unified STSA representation theorem. Research report 001 provides complete algebraic analysis with ~80% of formalization already existing.

---


### 953. Refactor proof system to bilateral system
- **Effort**: 55-90 hours
- **Status**: [ABANDONED]
- **Language**: lean
- **Priority**: medium
- **Research**: [research-001.md](specs/953_refactor_proof_system_to_bilateral/reports/research-001.md), [research-002.md](specs/953_refactor_proof_system_to_bilateral/reports/research-002.md), [research-003.md](specs/953_refactor_proof_system_to_bilateral/reports/research-003.md)

**Description**: Refactor the TM proof system from a unilateral system (single judgment `Γ ⊢ φ`) to a bilateral system with dual judgments: acceptance (`Γ ⊢⁺ φ`) and rejection (`Γ ⊢⁻ φ`). The bilateral system makes the dual roles of assertion and denial explicit, with rules governing how acceptance and rejection interact across all connectives and operators. Key design: keep Formula type unchanged (Option A), add BilateralDeriv alongside existing DerivationTree with a proven equivalence bridge. Several current axioms (ex_falso, peirce, modal_t, temp_t_future, temp_t_past) become structural rules in the bilateral system. The existing signed formula infrastructure in the decidability module provides the blueprint.

**Research summary (research-003)**: Cost-benefit analysis recommends deferring bilateral refactor until higher-priority tasks (981: axiom debt, 951: completeness) progress. Benefits are primarily theoretical (assertion/denial duality, tableau alignment); existing unilateral system is adequate. Parallel-system approach (Option A) minimizes risk.

**Implementation approach**: Parallel bilateral system with equivalence bridge — not a replacement. Phase 1: bilateral infrastructure (BilateralContext, BilateralDeriv). Phase 2: prove equivalence with unilateral system. Phase 3: bilateral metalogic (MCS, FMCS, completeness). Phase 4: bilateral decidability integration.

---

### 949. Update Demo.lean for current bimodal logic state
- **Effort**: Small (~2 hours)
- **Status**: [ABANDONED]
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


## Recommended Order

