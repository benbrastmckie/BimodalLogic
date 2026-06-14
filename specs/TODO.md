---
next_project_number: 301
---

# TODO

## Task Order

*Updated 2026-06-14. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 125,127,128,131,161,162,165,169,170,175,179,180,186,187,188,189,191,194,199,200,219,230,257,268,273,282,290,290,291,296,300 | -- | completeness, formula-refactor, frame-extensions, ... |
| 2 | 155,192,196,231,292,293,294,298,299 | 161,187,191,194,230,268,273,291,300 | completeness, publication-quality, sorry-elimination, ... |
| 3 | 95,176,193 | 155,189,192,196 | completeness, formula-refactor, automation |
| 4 | 177,178,254 | 95,131,176,193 | completeness, formula-refactor |

**Grouped by Topic** (indented = depends on parent):

### Completeness

165 [NOT STARTED] — Establish the semantic finite model property for TM bimodal logic
169 [NOT STARTED] — complete_frame_extension_setup_and_soundness
170 [NOT STARTED] — complete_dense_extension_completeness
268 [RESEARCHED] — Strategy B: Refactor discrete completeness to use Reynolds k-equi
  └─ 155 [IMPLEMENTING] — Eliminate all sorries from completeness_discrete by fixing 3 root
    └─ 95 [NOT STARTED] — Verification pass on sorry status for completeness_discrete and b
      └─ 254 [NOT STARTED] — Final metadata and documentation update after completeness pipeli
273 [PLANNED] — Close the two remaining blockers for completeness_discrete: (1) K
  └─ 299 [NOT STARTED] — Refactor DiscreteGameTransfer.lean to eliminate the wrapper patte

### Formula Refactor

131 [NOT STARTED] — Restructure Theories/Bimodal/ file hierarchy for clean APIs and d
  └─ 177 [NOT STARTED] — Update all documentation to match final codebase state after refa
  └─ 178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of the f
161 [NOT STARTED] — Rename Theories/Bimodal/ to FormalSystem/. Move the entire Theori
175 [RESEARCHED] — Normalize naming conventions to follow Mathlib-style descriptive 
194 [NOT STARTED] — migrate_nonempty_to_derivable
176 [NOT STARTED] — Resolve architectural confusion where Chronicle/ lives under BXCa

### Frame Extensions

127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ is 
128 [NOT STARTED] — Add topological open set (interior) operator for dense and contin

### Algebraic Representation

125 [NOT STARTED] — Implement a Jonsson-Tarski representation theorem for TM logic: e

### Agent System

162 [NOT STARTED] — Add a .claude/rules/ rule enforcing strict plan compliance for le

### Toolchain

291 [NOT STARTED] — Upgrade Lean toolchain from v4.27 to v4.31 and update Mathlib to 

### Publication Quality

180 [NOT STARTED] — copyright_headers_universe_polymorphism_line_limits
292 [NOT STARTED] — Add Apache 2.0 copyright headers to all source files under Theori
293 [NOT STARTED] — Audit and fix Mathlib linter compliance across all sorry-free mod

### Sorry Elimination

294 [NOT STARTED] — Eliminate all sorry instances in Theorems/ModalS5.lean and Theore

### Automation

179 [RESEARCHED] — research_lean4_tactics_infrastructure
186 [NOT STARTED] — unify_search_systems
187 [NOT STARTED] — backward_chaining_lemma_db
  └─ 192 [NOT STARTED] — master_tactic_dispatch
    └─ 193 [NOT STARTED] — codebase_tactic_refactor
188 [NOT STARTED] — weakening_aware_search
189 [NOT STARTED] — deduction_theorem_tactic
  └─ 193 [NOT STARTED] — codebase_tactic_refactor (see above)
191 [NOT STARTED] — propositional_decision_procedure
  └─ 192 [NOT STARTED] — master_tactic_dispatch (see above)
199 [PARTIAL] — Create a bespoke grid_order_tac tactic (in Theories/Bimodal/Autom
196 [RESEARCHED] — Systematic survey of the entire Theories/Bimodal/ codebase to ide
  └─ 193 [NOT STARTED] — codebase_tactic_refactor (see above)

### Code Quality

200 [NOT STARTED] — Rewrite ghr93_case_II in CaseAnalysis.lean for code elegance and 

### Dataset Enhancement

219 [RESEARCHED] — Run bmlogic-bench through multiple LLMs to establish baseline dif
230 [NOT STARTED] — After contamination resolution (task 229), regenerate all benchma
  └─ 231 [NOT STARTED] — Build comprehensive automation so that every dataset regeneration
257 [IMPLEMENTING] — large_data_storage_huggingface
282 [NOT STARTED] — exhaustive_enumeration_by_default
290 [PLANNED] — Improve tableau fuel allocation heuristic for imbalanced branches
296 [NOT STARTED] — Re-add the 6 derived binary temporal operators (release, weak_unt

### Literature

300 [NOT STARTED] — Make the tableau decision procedure abort-aware by threading an I
  └─ 298 [PLANNED] — Fix c7 labeling bug at formula ~13750 that causes unbounded memor

### Uncategorized

## Tasks

### 300. Refactor literature index json
abort aware tableau cancellation
- **Status**: [COMPLETED
NOT_STARTED]
- **Task Type**: meta
lean4
- **Topic**: literature
literature
- **Dependencies**: 

**Description**: Refactor specs/literature/ to use index.json files for --lit flag compatibility, keeping PDFs but ignoring them during literature retrieval, modeled after cslib specs/literature/ structure
Make the tableau decision procedure abort-aware by threading an IO.Ref Bool abort signal through expandBranchWithFuel and related functions. Currently, IO.cancel in labelFormulaImpl is cooperative but the pure tableau computation never calls IO.checkCanceled, so cancelled tasks continue as zombie threads accumulating memory. The fix: (1) Add an IO.Ref Bool parameter to expandBranchWithFuel that is checked at each recursive step. (2) Wire the abort ref from the IO.cancel handler in labelFormulaImpl. (3) Ensure extractCountermodelData in mkInvalidLabel also respects the abort signal. This eliminates the root cause of the c7 OOM — zombie tableau computations that survive cancellation.

---

### 300. Refactor literature index json
abort aware tableau cancellation
- **Status**: [COMPLETED
NOT_STARTED]
- **Task Type**: meta
lean4
- **Topic**: literature
literature
- **Dependencies**: 

**Description**: Refactor specs/literature/ to use index.json files for --lit flag compatibility, keeping PDFs but ignoring them during literature retrieval, modeled after cslib specs/literature/ structure
Make the tableau decision procedure abort-aware by threading an IO.Ref Bool abort signal through expandBranchWithFuel and related functions. Currently, IO.cancel in labelFormulaImpl is cooperative but the pure tableau computation never calls IO.checkCanceled, so cancelled tasks continue as zombie threads accumulating memory. The fix: (1) Add an IO.Ref Bool parameter to expandBranchWithFuel that is checked at each recursive step. (2) Wire the abort ref from the IO.cancel handler in labelFormulaImpl. (3) Ensure extractCountermodelData in mkInvalidLabel also respects the abort signal. This eliminates the root cause of the c7 OOM — zombie tableau computations that survive cancellation.

---

### 299. Refactor discrete game transfer
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 273

**Description**: Refactor DiscreteGameTransfer.lean to eliminate the wrapper pattern once the completeness chain is sorry-free. Inline discrete_ghr93_theorem6 by having StaviCompleteness.lean call ghr93_forward_to_backward directly with discrete typeclass instances. Convert discrete_rank_embed_eq_drc to a @[simp] lemma. Remove discrete_ghr93_theorem6_rank_varying if callers can use the general version. Clean up any dead code from the old fixed-pivot architecture that was deleted in task 273.

---

### 298. Fix c7 labeling bug and regenerate dataset
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Dependencies**: Task 297, Task 300
- **Research**: [298_fix_c7_labeling_bug_and_regenerate_dataset/reports/01_c7-labeling-bug.md]
- **Plan**: [298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md]

**Description**: Fix c7 labeling bug at formula ~13750 that causes unbounded memory growth in the decision procedure's timeout handling, then regenerate the full c7 dataset. During task 297 dataset regeneration, all 3 attempts to generate c7 stalled at exactly record 13,749 with RSS growing ~40MB/6s. The labeling function enters an apparent infinite loop or unbounded search for formula #13,750 in the sorted enumeration order. The timeout mechanism either does not fire or cannot interrupt the stuck state. Steps: (1) Identify the specific formula at position ~13,750 in the c7 enumeration. (2) Reproduce the hang in isolation with that formula. (3) Diagnose whether the decision procedure's timeout is failing to fire or the procedure is in an uninterruptible state. (4) Fix the timeout handling so it reliably terminates. (5) Regenerate the full c7 dataset (target: 77,272 records)

---

### 297. Verify operator removal and regenerate datasets
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [297_verify_operator_removal_and_regenerate_datasets/reports/01_verify-operator-removal.md]
- **Plan**: [297_verify_operator_removal_and_regenerate_datasets/plans/01_verify-operator-removal.md]

**Description**: Verify that the removal of 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) from the formula enumerator is correct and complete. (1) Confirm lake build passes with zero errors. (2) Run enumeration at c4-c7 and verify the 6 operators no longer appear in enumerated formulas. (3) Verify formula counts are reduced as expected (~40-60% reduction in raw enumeration). (4) Run exhaustive labeling at c4 and c5 to confirm correctness (zero label disagreements, prefilter and cache still working). (5) Regenerate datasets at c4, c5, and c6 (with appropriate timeouts). (6) Verify the regenerated JSONL files contain no formulas with the removed operators. (7) Compare new dataset sizes against pre-removal baselines from the task 295 diagnostic report.

---

### 296. Re add derived binary operators with dedup fix
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 295

**Description**: Re-add the 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) to the formula enumerator, adjusting canonicalization and/or the passesFilter gate so they survive deduplication and appear in the unique pipeline output. These operators were removed in task 295 because they inflated the enumeration space by ~40-60% without contributing unique formulas — their canonical representations collapsed with primitives. Potential approaches: (1) skip canonicalization for formulas containing derived binary operators, (2) canonicalize to the derived form instead of the primitive form, (3) lower or remove the passesFilter complexity gate for these operators, (4) add a fold-aware dedup stage that treats release(p,q) as distinct from neg(untl(neg p, neg q)). The goal is to have all 13 derived operators represented in the final dataset.

---

### 294. Eliminate sorry in modals5 and perpetuity
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: sorry-elimination
- **Dependencies**: Task 291

**Description**: Eliminate all sorry instances in Theorems/ModalS5.lean and Theorems/Perpetuity/Principles.lean. These files are needed for PR 4 (Derived Theorems) in cslib but contain 1-3 sorry each. Analysis suggests these are small enough to resolve: ModalS5.lean sorries likely require direct axiom application or simple combinatorial arguments; Perpetuity/Principles.lean sorries relate to fixpoint principles for G/H operators that should follow from the core axiom system. Complete both files to be fully sorry-free. Run lake build to verify zero errors and zero sorries.

---

### 293. Audit and fix mathlib linter compliance
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: Task 291

**Description**: Audit and fix Mathlib linter compliance across all sorry-free modules scheduled for porting to cslib (Syntax, Semantics, ProofSystem, Theorems, FrameConditions, Soundness, MCS/Deduction, Completeness, Decidability, Separation, ConservativeExtension). Run the Mathlib linter (set_option linter.all true or use #check_lint). Fix: (1) Naming convention violations -- Mathlib uses descriptive snake_case names not opaque abbreviations (e.g., bfmcs, drm). (2) Missing docstrings on public declarations. (3) Universe polymorphism issues. (4) Line length violations (100 char limit). (5) Unused variable warnings. This task produces files ready for direct porting to cslib without linter failures.

---

### 292. Add copyright headers to all source files
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: Task 291

**Description**: Add Apache 2.0 copyright headers to all source files under Theories/Bimodal/ (approximately 160 .lean files). cslib requires headers on all contributed files following the format: "-- Copyright (c) 2024 The Bimodal Logic Contributors. All rights reserved. -- Released under Apache 2.0 license as described in the file LICENSE. -- Authors: [author names]". Use a script to batch-add headers to files that lack them. Verify no duplicates are introduced. Run lake build to confirm no import errors.

---

### 291. Upgrade lean toolchain to v431 and mathlib
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: toolchain
- **Dependencies**: None

**Description**: Upgrade Lean toolchain from v4.27 to v4.31 and update Mathlib to the same pin as cslib. This is a prerequisite for all porting tasks: cslib uses Lean 4.31 and tasks 292-294 cannot proceed until BimodalLogic builds cleanly on 4.31. Steps: (1) Update lean-toolchain to v4.31.0-rc1 (or current cslib pin). (2) Run lake update to fetch compatible Mathlib. (3) Fix any API breakage caused by Lean/Mathlib version bump (expect ~50-200 lines of fixes across formula, tactic, and instance changes). (4) Run lake build to confirm zero errors. (5) Run existing tests to confirm no regressions. This task unlocks tasks 292, 293, 294 and all cslib porting tasks (2-13).

---

### 290. Improve tableau fuel allocation
improve tableau fuel allocation
- **Status**: [PLANNED
PLANNED]
- **Task Type**: lean4
lean4
- **Topic**: dataset-enhancement
dataset-enhancement
- **Dependencies**: Task 288

**Description**: Improve tableau fuel allocation heuristic for imbalanced branches. Add estimateBranchDifficulty heuristic (temporal count, modal count, branch depth). Allocate fuel proportionally to difficulty across sub-branches. Prove termination still holds. Benchmark on c6. Expected 2-5% timeout reduction.
Improve tableau fuel allocation heuristic for imbalanced branches. Add estimateBranchDifficulty heuristic (temporal count, modal count, branch depth). Allocate fuel proportionally to difficulty across sub-branches. Prove termination still holds. Benchmark on c6. Expected 2-5% timeout reduction.

---

### 290. Improve tableau fuel allocation
improve tableau fuel allocation
- **Status**: [PLANNED
PLANNED]
- **Task Type**: lean4
lean4
- **Topic**: dataset-enhancement
dataset-enhancement
- **Dependencies**: Task 288

**Description**: Improve tableau fuel allocation heuristic for imbalanced branches. Add estimateBranchDifficulty heuristic (temporal count, modal count, branch depth). Allocate fuel proportionally to difficulty across sub-branches. Prove termination still holds. Benchmark on c6. Expected 2-5% timeout reduction.
Improve tableau fuel allocation heuristic for imbalanced branches. Add estimateBranchDifficulty heuristic (temporal count, modal count, branch depth). Allocate fuel proportionally to difficulty across sub-branches. Prove termination still holds. Benchmark on c6. Expected 2-5% timeout reduction.

---

### 289. Branch result memoization caching
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 286
- **Research**: [289_branch_result_memoization_caching/reports/01_memoization-research.md]
- **Plan**: [289_branch_result_memoization_caching/plans/01_memoization-plan.md]
- **Summary**: [289_branch_result_memoization_caching/summaries/01_memoization-summary.md]

**Description**: Add branch-result memoization/caching to expandBranchWithFuel. Cache decide results keyed by (Formula, FrameClass, searchDepth, tableauFuel) in an IO.Ref-based LRU cache at the decide level. Size bound to 10K entries. Benchmark hit rate and total labeling time. Best combined with parallelization (task 286).

---

### 288. Deeper invalid pattern recognizers
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 287
- **Research**: [288_deeper_invalid_pattern_recognizers/reports/01_invalid-patterns-research.md]
- **Plan**: [288_deeper_invalid_pattern_recognizers/plans/01_invalid-patterns-plan.md]
- **Summary**: [288_deeper_invalid_pattern_recognizers/summaries/01_invalid-patterns-summary.md]

**Description**: Add deeper invalid-pattern recognizers to structuralPrefilter. Detect structurally invalid formulas (e.g., U(box(bot), X)) that timeout the tableau but have obvious countermodels. Add isTemporalContradiction, isObviousSatisfiable, hasUnfulfillableEventuality. Wire into labelFormulaImpl before valid-prefilter. Each pattern must have formal soundness proof. Target: reduce c6 timeout rate by 3-8%.

---

### 282. Exhaustive enumeration by default
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 274

---

### 273. Chronicle gap contradiction proof
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None
- **Research**:
  - [273_chronicle_gap_contradiction_proof/reports/01_gap-contradiction-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/02_deep-analysis.md]
  - [273_chronicle_gap_contradiction_proof/reports/03_stavi-sorry-analysis.md]
  - [273_chronicle_gap_contradiction_proof/reports/04_ghr93-literature-review.md]
  - [273_chronicle_gap_contradiction_proof/reports/03_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/05_proposition7-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/06_decomposition-path-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/05_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/07_sorry-chain-verification.md]
  - [273_chronicle_gap_contradiction_proof/reports/08_game-pipeline-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/08_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/09_negation-closure-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/10_literature-transcription.md]
  - [273_chronicle_gap_contradiction_proof/reports/11_divergence-audit.md]
  - [273_chronicle_gap_contradiction_proof/reports/12_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/13_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/23_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/24_blocker-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/26_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/28_wiring-gap-analysis.md]
  - [273_chronicle_gap_contradiction_proof/reports/31_kamp-bypass-sorry-goals.md]
- **Plan**: [273_chronicle_gap_contradiction_proof/plans/32_depth0-sorries-completion.md]

**Description**: Close the two remaining blockers for completeness_discrete: (1) KampPrior.lean:149 via NF-specific Prop 4.3 restricted to arity-1 formulas, using sorry-free neg_2var_vec_ea for the negation case (~150-200 lines); (2) chronicle_gap_contradiction (ChronicleToCountermodel.lean:531) via fully-proved reynolds_model_surgery_core (~100-150 lines). VecEADecomposition.lean sorries quarantined as dead code.

---

### 268. Reynolds pipeline bridge
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None
- **Research**:
  - [268_reynolds_pipeline_bridge/reports/01_bridge-research.md]
  - [268_reynolds_pipeline_bridge/reports/04_team-research.md]
  - [268_reynolds_pipeline_bridge/reports/05_completion-analysis.md]
  - [268_reynolds_pipeline_bridge/reports/06_reynolds-literature-review.md]
- **Plan**:
  - [268_reynolds_pipeline_bridge/plans/01_implementation-plan.md]
  - [268_reynolds_pipeline_bridge/plans/04_strategy-b-plan.md]
- **Summary**: [268_reynolds_pipeline_bridge/summaries/01_implementation-summary.md]
- **Handoff**: [268_reynolds_pipeline_bridge/handoffs/phase-2-handoff-20260603.md]

**Description**: Strategy B: Refactor discrete completeness to use Reynolds k-equivalence bypass instead of IsSuccArchimedean. Build LimitDomSubtype as OrderedMonadicStructure, apply sorry-free one_class -> very_good -> good pipeline, extract k-equivalent Z-interval, transfer satisfiability, build countermodel on Z. Eliminates succ_embed_surjective sorry chain entirely.

---

### 257. Large data storage huggingface
- **Status**: [IMPLEMENTING]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [257_large_data_storage_huggingface/reports/01_large-data-storage.md]
- **Plan**: [257_large_data_storage_huggingface/plans/01_implementation-plan.md]
- **Summary**: [257_large_data_storage_huggingface/summaries/01_execution-summary.md]

---

### 254. Update stale metadata post 202
- **Status**: [NOT STARTED]
- **Task Type**: meta
- **Topic**: completeness
- **Dependencies**: Task 95, Task 176

**Description**: Final metadata and documentation update after completeness pipeline stabilization: (1) TODO.md sorry_count_note — comprehensive audit of sorry landscape post-tasks 202/155; (2) ROADMAP.md — annotate all completeness milestones achieved; (3) Transfer.lean and Completeness.lean — update stale axiom audit comments and sorry status documentation; (4) Verify #print axioms completeness_discrete shows no sorryAx. Follows tasks 95 (verification audit) and 176 (Chronicle relocation) to capture the final state.

---

### 231. Dataset regeneration automation
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 230

**Description**: Build comprehensive automation so that every dataset regeneration automatically updates all downstream artifacts and documentation fields. Supersedes task 227 scope. (1) Create data/scripts/sync-all.py master sync script that: (a) Scans all JSONL files and recomputes metadata JSON files (record counts, rule distributions, schema field lists, valid/invalid ratios, tier distributions, step statistics). (b) Updates specific fields in data/README.md: file inventory table (Records, Size columns), training record schema table (field count), proof steps statistics (records, theorems, rule distribution, steps per theorem), cross-logic split table (records, valid rates), NL paraphrase statistics. (c) Updates specific fields in data/dataset-card.md: overview table, all record counts, proof steps section, competitive position 'primary gaps' paragraph. (d) Recomputes SHA-256 hashes and contentSize for all distributions in croissant.json. (e) Regenerates bmlogic-bench-splits.json. (f) Validates all JSONL records against declared schemas (checks field presence, types, null patterns). (g) Checks train/benchmark formula overlap and reports contamination percentage. (h) Validates metadata key consistency (total_records not total_count). (2) Idempotent and safe to run after any regeneration command (lake exe dataset_generator, lake exe proof_extractor, lake exe benchmark_oracle, finalize_benchmark.py). (3) --dry-run mode that reports what would change. (4) --commit mode that creates structured git commit. (5) CI-friendly exit codes (0=clean, 1=staleness detected, 2=validation error). (6) Update data/README.md with pipeline documentation. (7) Integrate into agent context (.claude/context/project/dataset/) so /implement for dataset tasks runs sync-all as post-implementation step. Note: supersedes task 227 (dataset_pipeline_automation_croissant_sync) with broader scope covering README/dataset-card field updates and schema validation.

---

### 230. Benchmark refresh splits paraphrases schema
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 229

**Description**: After contamination resolution (task 229), regenerate all benchmark-derived artifacts. (1) Regenerate bmlogic-bench-splits.json for current record count — splits reference 727 records but benchmark now has 777. Run generate_splits.py and validate all IDs assigned to exactly one slice. (2) Restore NL paraphrase fields: benchmark was regenerated after paraphrases were added, losing nl_paraphrase and nl_paraphrase_method. Run generate_paraphrases.py and validate with validate_paraphrases.py. (3) Schema alignment: add formula_sexpr, formula_tokens, and pattern_features to benchmark records so evaluation uses the same representations as training. Extend finalize_benchmark.py or create enrichment script. (4) Decide whether to remove or keep the redundant max_modal_depth/max_temporal_depth fields in training data (they duplicate metrics.modalDepth/temporalDepth and pattern_key.modalDepth/temporalDepth — three copies of the same data). (5) Fill pattern_key for the 15 benchmark records where it is currently null.

---

### 219. Llm baseline difficulty calibration
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [219_llm_baseline_difficulty_calibration/reports/01_llm-baseline-research.md]

**Description**: Run bmlogic-bench through multiple LLMs to establish baseline difficulty calibration. Evaluate at least 3 models (GPT-4o, Claude Sonnet, a 7B open model). Report zero-shot accuracy per difficulty tier (easy/medium/hard/very_hard), chain-of-thought vs direct label accuracy, error rate correlation with modal/temporal depth. Include random baseline (50% for balanced benchmark). Publish results in data/baselines/README.md with methodology. Both symbolic formula input and NL paraphrase input (if available from R1).

---

### 200. Ghr93 case ii elegance rewrite
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: code-quality
- **Dependencies**: None

**Description**: Rewrite ghr93_case_II in CaseAnalysis.lean for code elegance and GHR93 fidelity. The proof is already correct, sorry-free, and axiom-clean (733 lines). The goal is to replace the tau_left/tau_right sub-game structure with a single restricted tau following GHR93 exactly. This requires resolving the fundamental gap between GHR93's continuous order-type preservation and the Lean formalization's finite-position EF games: same_order_type applies to n+3 positions, so orderings at interior points (p_n, e_n) require those points to be game endpoints — which is exactly what tau_left/tau_right achieve. A solution would require either (a) enriching the EF game framework to support continuous order-type preservation, or (b) finding a way to make the restricted tau's endpoint orderings imply interior-point orderings. Extensive research (7 agents, 3 plan revisions) confirmed the blocker is structural. GHR93 infrastructure theorems (untl_witness_bounded, ghr93_untl_transfer, ghr93_construct_en) are proved and available in CharacteristicFormula.lean and CaseAnalysis.lean. See specs/155_reynolds_pipeline_activation/reports/47_*.md and handoffs/phase-5-blocker-finite-position-games-20260528.md for full analysis.

---

### 199. Grid order tactic
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**: [199_grid_order_tactic/reports/01_grid-order-tactic.md]
- **Plan**: [199_grid_order_tactic/plans/01_grid-order-tactic.md]

**Description**: Create a bespoke grid_order_tac tactic (in Theories/Bimodal/Automation/) that automates the same_order_type grid dispatch in ghr93_case_II (Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean). The problem: after same_order_type_grid expands to intro i j; simp only [game_tuple]; split_ifs, it generates ~25 ordering goals per case. Each goal has shape (a_bwd ⟨k, proof_n+1⟩ < x ↔ resp_tau ⟨k, proof_n⟩ < y) ∧ (... = ... ↔ ...). The available ordering lemmas (tau_sel_y, tau_sel_sel, sel_pn_ord, pn_sel_ord, tau_d_sel, hord_cd_en_pn, pivot_chain_order, fwd_x_b, fwd_b_y) are stated with Fin n but the goals use Fin (n+1), causing exact to fail on metavar unification. The tactic must: (1) try each ordering lemma with automatic Fin bridging via convert ... using 3 <;> (congr 1; exact Fin.ext (by omega)), (2) handle the hab_eq rewrite for p_n cases (when not k < n, rewrite a_bwd to extendPoint p_n before applying sel_pn_ord/pn_sel_ord), (3) handle symmetry (y < sel goal uses tau_sel_y.symm), (4) fall back to sorry with trace if no lemma applies. After building the tactic, apply it to replace the two sorry fallbacks in ghr93_case_II: Case A sorry at line ~1631 and Case B sorry at line ~1940. These are the last fallthrough goals in the first | ... | sorry chains inside the same_order_type proof obligation. Verify zero build errors. Iterate on the tactic if the initial version does not close all goals.

---

### 196. Codebase tactic survey
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 161
- **Research**: [196_codebase_tactic_survey/reports/01_team-research.md]

**Description**: Systematic survey of the entire Theories/Bimodal/ codebase to identify all tactic and automation opportunities. Produces a ranked inventory of tactic groups with effort estimates, line savings, and dependency relationships. Output: one new task per tactic group, replacing or refining existing tasks 185-195.

---

### 194. Migrate nonempty to derivable
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: None
- **Research**: [194_migrate_nonempty_to_derivable/reports/01_derivable-migration-seed.md]

---

### 193. Codebase tactic refactor
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 189, Task 192, Task 196
- **Research**: [193_codebase_tactic_refactor/reports/01_codebase-refactor-seed.md]

---

### 192. Master tactic dispatch
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 185, Task 187, Task 190, Task 191, Task 194
- **Research**: [192_master_tactic_dispatch/reports/01_master-dispatch-seed.md]

---

### 191. Propositional decision procedure
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**: [191_propositional_decision_procedure/reports/01_decision-procedure-seed.md]

---

### 189. Deduction theorem tactic
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**: [189_deduction_theorem_tactic/reports/01_deduction-theorem-seed.md]

---

### 188. Weakening aware search
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**: [188_weakening_aware_search/reports/01_weakening-aware-seed.md]

---

### 187. Backward chaining lemma db
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**: [187_backward_chaining_lemma_db/reports/01_lemma-database-seed.md]

---

### 186. Unify search systems
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 185
- **Research**: [186_unify_search_systems/reports/01_unify-search-seed.md]

---

### 180. Copyright headers universe polymorphism line limits
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: None

---

### 179. Research lean4 tactics infrastructure
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**:
  - [179_research_lean4_tactics_infrastructure/reports/01_team-research.md]
  - [179_research_lean4_tactics_infrastructure/reports/02_mathlib-submission.md]

---

### 178. Publication examples and demo
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193

**Description**: Expand Examples/ with publication-quality demonstrations of the full verified pipeline. Complete worked example showing soundness-completeness-decidability on a concrete formula. Examples exercising each frame class with FrameClass-parameterized DerivationTree. Examples of the expressive completeness result. Update BimodalProofs.lean and TemporalStructures.lean. All examples sorry-free.

---

### 177. Update readme and module docstrings
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193

**Description**: Update all documentation to match final codebase state after refactoring. README.md axiom counts, architecture diagram, sorry obligations. Module-level docstrings for every file in the final structure. ROADMAP.md updates. Axiom Reference doc verification. This is the final documentation pass after all structural refactoring is complete.

---

### 176. Relocate chronicle and archive dead bxcanonical
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 155

**Description**: Resolve architectural confusion where Chronicle/ lives under BXCanonical/ but is only consumed by WeakCanonical/. Move 6 Chronicle files (14331 lines) to Metalogic/Chronicle/ or WeakCanonical/Chronicle/. Archive entire non-Chronicle BXCanonical subtree (16 files, 4615 lines, 19 false sorries) to Boneyard/BXCanonical/. Verify OrderedSeedConsistency.lean dependency from WeakCanonical/ReflexiveCanonical.lean before archiving. Update aggregator imports. Subsumes part of task 130 scope.

---

### 175. Naming convention and bridge cleanup
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: None
- **Research**: [175_naming_convention_and_bridge_cleanup/reports/01_team-research.md]

**Description**: Normalize naming conventions to follow Mathlib-style descriptive conventions and eliminate bridge/wrapper indirection for publication quality. Adopt Mathlib naming patterns: bot_of_and_neg instead of ecq, and_left instead of lce, and_right instead of rce, or_inl instead of ldi, or_inr instead of rdi, absurd instead of raa, False.elim instead of efq, not_not_intro instead of dni, etc. Expand opaque abbreviations (bfmcs, drm, cud, sdc, dd_, tc_, fuc_, buc_). Inline or remove Bridge.lean wrappers (993 lines, 16 forwarding definitions). Eliminate trivial primed variants. Normalize z1_valid to axiom_z1_valid for consistency. Rename temp_ prefix to temporal_ for clarity. Purge 81 removed/archived/superseded tombstone comments. Reference Mathlib naming conventions guide and task 179 research report for the full mapping.

---

### 170. Complete dense extension completeness
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None

---

### 169. Complete frame extension setup and soundness
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None

---

### 165. Establish semantic finite model property
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None

**Description**: Establish the semantic finite model property for TM bimodal logic. The existing FMP in Decidability/FMP/ is purely proof-theoretic: it shows closure MCS structures are finite and that provability is decidable via MCS enumeration, but it does not construct finite semantic models (task frames with world histories). A standard semantic FMP requires: (1) Starting from a canonical model where phi fails, quotient worlds by agreement on the subformula closure. (2) Prove the filtration lemma for all formula constructors including Until/Since (known to be problematic for naive filtration). (3) Prove the quotient model is a valid task frame. (4) Bound the model size by 2^|cl(phi)|. The result should be stated as: if phi is satisfiable in a task model, then phi is satisfiable in a finite task model of bounded size.

---

### 162. Enforce plan compliance rule
- **Status**: [NOT STARTED]
- **Task Type**: meta
- **Topic**: agent-system
- **Dependencies**: None

**Description**: Add a .claude/rules/ rule enforcing strict plan compliance for lean-implementation-agent and other formal implementation agents. The rule should: (1) Prohibit agents from "assessing what's truly minimal" or inventing alternative approaches when a plan exists. (2) Require agents to follow the plan's exact task sequence step-by-step, in order. (3) Explicitly ban common divergence patterns: skipping intermediate theorems, inlining proofs instead of following the plan's decomposition, routing through different helper lemmas than specified, and "cleaner approach" rationalizations. (4) Be auto-applied via glob pattern to Theories/ and any formal proof files. (5) Reference the repeated failures in task 157 (8 plan versions, agents diverging every time) as motivation. The rule should be concise but firm -- agents must treat the plan as a contract, not a suggestion.

---

### 161. Rename theories bimodal to formalsystem
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: None

**Description**: Rename Theories/Bimodal/ to FormalSystem/. Move the entire Theories/Bimodal/ directory to FormalSystem/, update all imports in Lean files, update lakefile.lean srcDir from Theories to FormalSystem and roots from Bimodal to FormalSystem, update any references in README.md, Tests/, and other files that point to the old path. Ensure lake build still passes after the rename.

---

### 155. Reynolds pipeline activation
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 268
- **Research**:
  - [155_reynolds_pipeline_activation/reports/01_team-research.md]
  - [155_reynolds_pipeline_activation/reports/02_team-research.md]
  - [155_reynolds_pipeline_activation/reports/03_post-157-status.md]
  - [155_reynolds_pipeline_activation/reports/03_team-research.md]
  - [155_reynolds_pipeline_activation/reports/04_phase4-blocker.md]
  - [155_reynolds_pipeline_activation/reports/05_full-reynolds-impl.md]
  - [155_reynolds_pipeline_activation/reports/06_path-b-feasibility.md]
  - [155_reynolds_pipeline_activation/reports/07_ghr93-strategy-review.md]
  - [155_reynolds_pipeline_activation/reports/08_ghr93-game-theory.md]
  - [155_reynolds_pipeline_activation/reports/09_lean-infrastructure-inventory.md]
  - [155_reynolds_pipeline_activation/reports/10_team-research.md]
  - [155_reynolds_pipeline_activation/reports/11_phase10-blocker-research.md]
  - [155_reynolds_pipeline_activation/reports/15_d-consistency-blocker.md]
  - [155_reynolds_pipeline_activation/reports/12_degenerate-interval-blocker.md]
  - [155_reynolds_pipeline_activation/reports/21_muSig-blocker-resolution.md]
  - [155_reynolds_pipeline_activation/reports/27_d-consistency-blocker.md]
  - [155_reynolds_pipeline_activation/reports/35_phase1-blocker-prior-art.md]
  - [155_reynolds_pipeline_activation/reports/18_task17-blocker-resolution.md]
  - [155_reynolds_pipeline_activation/reports/22_claim1-case2-literature.md]
  - [155_reynolds_pipeline_activation/reports/23_tactic-needs-beyond-195.md]
  - [155_reynolds_pipeline_activation/reports/27_post-195-assessment.md]
  - [155_reynolds_pipeline_activation/reports/27_team-research.md]
  - [155_reynolds_pipeline_activation/reports/28_team-research.md]
  - [155_reynolds_pipeline_activation/reports/29_phase3-blocker-research.md]
  - [155_reynolds_pipeline_activation/reports/30_blocker-study-prior-art.md]
  - [155_reynolds_pipeline_activation/reports/32_post-dependency-assessment.md]
  - [155_reynolds_pipeline_activation/reports/33_lit-sel-pn-ordering.md]
  - [155_reynolds_pipeline_activation/reports/33_infra-sel-pn-fix.md]
  - [155_reynolds_pipeline_activation/reports/33_tactic-sel-pn-grid.md]
  - [155_reynolds_pipeline_activation/reports/38_equality-case-research.md]
  - [155_reynolds_pipeline_activation/reports/39_game-depth-restructuring.md]
  - [155_reynolds_pipeline_activation/reports/40_ghr93-case-ii-step6.md]
  - [155_reynolds_pipeline_activation/reports/41_stavi-completeness-audit.md]
  - [155_reynolds_pipeline_activation/reports/42_plan-literature-alignment.md]
  - [155_reynolds_pipeline_activation/reports/44_team-research.md]
  - [155_reynolds_pipeline_activation/reports/50_import-cycle-research.md]
  - [155_reynolds_pipeline_activation/reports/55_team-research.md]
  - [155_reynolds_pipeline_activation/reports/56_phase2-blocker-research.md]
  - [155_reynolds_pipeline_activation/reports/57_bypass-surjectivity-research.md]
  - [155_reynolds_pipeline_activation/reports/58_proper-fix-research.md]
  - [155_reynolds_pipeline_activation/reports/60_team-research.md]
  - [155_reynolds_pipeline_activation/reports/61_team-research.md]
  - [155_reynolds_pipeline_activation/reports/62_blocker-literature-research.md]
  - [155_reynolds_pipeline_activation/reports/65_team-research.md]
- **Handoff**:
  - [155_reynolds_pipeline_activation/handoffs/phase-0-handoff-20260520.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-4-handoff-20260520c.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260522T160731Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260522T164255Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260522T180000Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260522T190000Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260522T174500Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260522T193000Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260522T210000Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-3-handoff-20260525T043000Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260603T051841Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-blocked-handoff-20260602.md]
- **Summary**: [155_reynolds_pipeline_activation/summaries/28_reynolds-bypass-summary.md]
- **Plan**:
  - [155_reynolds_pipeline_activation/plans/65_discrete-game-bypass.md]
  - [155_reynolds_pipeline_activation/plans/67_half-rank-game-bypass.md]

**Description**: Eliminate all sorries from completeness_discrete by fixing 3 root sorries in StaviCompleteness.lean (4-variable EF-game existential transfer, GHR93 Proposition 7) and rewiring limitDomSubtype_isSuccArchimedean to use the now-sorry-free Reynolds model surgery pipeline. Phase 1 (import cycle resolution) complete.

---

### 131. Refactor module organization
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: None

**Description**: Restructure Theories/Bimodal/ file hierarchy for clean APIs and documentation. Currently 130 live .lean files across 7 top-level directories, with the Metalogic/ directory being a catch-all containing 7 subdirectories (Algebraic, Bundle, BXCanonical, ConservativeExtension, Core, Decidability, Relational) plus loose files (Soundness.lean, SoundnessLemmas.lean, DenseSoundness.lean, DiscreteSoundness.lean, Completeness.lean, Metalogic.lean). Goals: (1) Reorganize Metalogic/ into a clearer hierarchy — group soundness files into Metalogic/Soundness/, completeness files into Metalogic/Completeness/, clarify relationship between BXCanonical (chronicle approach) and Algebraic (parametric approach). (2) Add module-level documentation (docstrings on namespace declarations, module descriptions at file tops). (3) Establish clean APIs with explicit exports via root .lean files for each subdirectory. (4) Evaluate whether FrameConditions/ should be merged into Metalogic/ or remain separate. (5) Audit Boneyard/ organization (45 files across 10+ subdirectories). (6) Consider whether docs/ and latex/ and typst/ should remain under Theories/Bimodal/ or move to project root.

---

### 128. Open set operator dense continuous
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None

**Description**: Add topological open set (interior) operator for dense and continuous temporal frames. On discrete ℤ the interior is trivial (discrete topology), but on dense ℚ and continuous ℝ it captures neighborhood-stable truth: Int(φ) true at t iff φ holds in an open neighborhood of t. Related to Dynamic Topological Logic (Kremer-Mints 2005), McKinsey-Tarski topological semantics for S4, and Fernandez-Duque intuitionistic temporal logic. Phase 1: add TopologicalSpace instance to TaskFrame for dense/continuous cases. Phase 2: add interior constructor to Formula with truth clause. Phase 3: axioms (S4-like: Int(φ)→φ, Int(φ)→Int(Int(φ))). Phase 4: interaction with temporal operators and S5 □. Note: DTL is not finitely axiomatizable (Fernandez-Duque 2014) — completeness may require non-standard techniques.

---

### 127. Time addition operator
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None

**Description**: Add time addition operator (+) to the bimodal logic TM. φ + ψ is true at (τ, x) iff ∃ y,z with x = y+z, φ true at (τ,y), ψ true at (τ,z). This internalizes the AddCommGroup structure of D into the object language, extending expressive power from FO[<] to FO[<,+] (Presburger arithmetic). Related to arrow logic (Venema), relevant logic (Routley-Meyer ternary frames), and separation logic (BI). Phase 1: add tadd/tsub constructors to Formula, truth clause in semantics. Phase 2: basic axioms (associativity, commutativity, identity, inverse). Phase 3: soundness proofs. Phase 4: interaction with G/H/U/S/□. Completeness (ternary canonical model) and decidability are open research problems — defer to later phases.

---

### 125. Jonsson tarski representation bimodal sus
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: None

**Description**: Implement a Jonsson-Tarski representation theorem for TM logic: every STSA embeds into the complex algebra of a concrete frame. Phased approach: Phase 1 — Complex algebra Cm(F): define powerset STSA for TaskFrames with box/G/H/sigma operators derived from frame relations. Prove Cm(F) satisfies all STSA axioms. Phase 2 — Ultrafilter frame Uf(A): given abstract STSA A, construct frame whose worlds are ultrafilters with canonical relations R_G, R_H, R_Box (seed infrastructure from task 163 recovery of UltrafilterChain.lean). Prove Uf(A) satisfies TaskFrame axioms. Phase 3 — Embedding theorem: prove eta(a) = {U | a in U} is an injective STSA homomorphism A into Cm(Uf(A)). Phase 4 — Since/Until extension: extend STSA typeclass with binary untl/sinc operators and prove representation for the full operator signature. Start with basic {box, G, H} fragment (Phases 1-3) before tackling S/U (Phase 4). Prerequisites: resolve 6 algebraic sorries (temp_k_dist, temp_a, temp_l in TenseS5Algebra/InteriorOperators/LindenbaumQuotient); obtain 3 missing papers (Jonsson-Tarski 1951/52, BRV 2001 Ch.5, Goldblatt 1989). Task 992 research report (01_stsa-algebraic-analysis.md) maps ~80% of needed infrastructure. Architecture: restructure Algebraic/ into Core/ (shared STSA/Boolean/ultrafilter), Completeness/ (renamed existing), Representation/ (new J-T work).

---

### 95. Completeness verification audit
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: completeness
- **Dependencies**: Task 155

**Description**: Verification pass on sorry status for completeness_discrete and bx_completeness. Updated scope after task 202 completion and task 155 re-scope: (1) Verify dd_countermodel_chronicle_dense and dd_countermodel_chronicle_mixed_sorry show no sorryAx (confirmed sorry-free as of 2026-05-15). (2) Trace the discrete case sorryAx: The BX chronicle path (dd_countermodel_chronicle_discrete -> succ_embed_surjective -> limitDomSubtype_isSuccArchimedean -> succ_cofinal) is being bypassed. The correct fix is the WeakCanonical path: task 155 targets closing the no_gaps_discrete import cycle (GoodStructures.lean:855) by delegating to no_gaps_discrete_model_surgery (GoodStructuresModelSurgery.lean:2133), then rewiring completeness_discrete. Note: succ_cofinal remains the current root sorry on the BX chronicle path (ChronicleToCountermodel.lean), but this path is dead code -- the WeakCanonical route via no_gaps_discrete_model_surgery (already sorry-free) is the production path once the import cycle is resolved by task 155. (3) Classify all Metalogic/ sorry occurrences as critical-path vs dead-code vs non-critical-path. (4) Update stale axiom audit comments in Completeness.lean (lines 177-234 reference CE:3570 which is no longer the sorry source). (5) Verify soundness and decidability remain sorry-free. (6) Produce audit report. Dependencies on tasks 93 and 109 removed (both completed).
