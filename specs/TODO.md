---
next_project_number: 300
repository_health:
  overall_score: 95
  production_readiness: near-publication
  last_assessed: 2026-06-08T17:16:21Z
task_counts:
  active: 43
  completed: 225
  abandoned: 2
  total: 270
technical_debt:
  sorry_count: 1
  publication_path_sorries: 1
  axiom_count: 0
  build_errors: 0
  status: excellent
---

# TODO

<!-- Vault transition: 2026-03-20 - Archived to specs/vault/01-vault/ -->

## Task Order

*Updated 2026-06-09. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 125,127,128,131,161,162,165,169,170,175,179,180,186,187,188,189,191,194,199,200,219,230,257,268,273,282,290,291,296,297 | -- | completeness, formula-refactor, frame-extensions, ... |
| 2 | 155,192,196,231,292,293,294 | 161,187,191,194,230,268,291 | completeness, publication-quality, sorry-elimination, ... |
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
    └─ 176 [NOT STARTED] — Resolve architectural confusion where Chronicle/ lives under BXCa
      └─ 254 [NOT STARTED] — Final metadata and documentation update after completeness pipeli (see above)
273 [PLANNED] — Bypass the GHR93 bridge lemma sorry in StaviCompleteness.lean by 

### Formula Refactor

131 [NOT STARTED] — Restructure Theories/Bimodal/ file hierarchy for clean APIs and d
  └─ 177 [NOT STARTED] — Update all documentation to match final codebase state after refa
  └─ 178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of the f
161 [NOT STARTED] — Rename Theories/Bimodal/ to FormalSystem/. Move the entire Theori
  └─ 196 [RESEARCHED] — Systematic survey of the entire Theories/Bimodal/ codebase to ide
    └─ 193 [NOT STARTED] — codebase_tactic_refactor
      └─ 177 [NOT STARTED] — Update all documentation to match final codebase state after refa (see above)
      └─ 178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of the f (see above)
175 [RESEARCHED] — Normalize naming conventions to follow Mathlib-style descriptive 
194 [NOT STARTED] — migrate_nonempty_to_derivable
  └─ 192 [NOT STARTED] — master_tactic_dispatch
    └─ 193 [NOT STARTED] — (automation: codebase_tactic_refactor) (see above)
176 [NOT STARTED] — Resolve architectural confusion where Chronicle/ lives under BXCa
  └─ 254 [NOT STARTED] — (completeness: Final metadata and documentation update ) (see above)

### Frame Extensions

127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ is 
128 [NOT STARTED] — Add topological open set (interior) operator for dense and contin

### Algebraic Representation

125 [NOT STARTED] — Implement a Jonsson-Tarski representation theorem for TM logic: e

### Agent System

162 [NOT STARTED] — Add a .claude/rules/ rule enforcing strict plan compliance for le

### Toolchain

291 [NOT STARTED] — Upgrade Lean toolchain from v4.27 to v4.31 and update Mathlib to 
  └─ 292 [NOT STARTED] — Add Apache 2.0 copyright headers to all source files under Theori
  └─ 293 [NOT STARTED] — Audit and fix Mathlib linter compliance across all sorry-free mod
  └─ 294 [NOT STARTED] — Eliminate all sorry instances in Theorems/ModalS5.lean and Theore

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
  └─ 192 [NOT STARTED] — master_tactic_dispatch (see above)
188 [NOT STARTED] — weakening_aware_search
189 [NOT STARTED] — deduction_theorem_tactic
  └─ 193 [NOT STARTED] — codebase_tactic_refactor (see above)
191 [NOT STARTED] — propositional_decision_procedure
  └─ 192 [NOT STARTED] — master_tactic_dispatch (see above)
199 [PARTIAL] — Create a bespoke grid_order_tac tactic (in Theories/Bimodal/Autom
192 [NOT STARTED] — master_tactic_dispatch
  └─ 193 [NOT STARTED] — codebase_tactic_refactor (see above)
193 [NOT STARTED] — codebase_tactic_refactor
  └─ 177 [NOT STARTED] — (formula-refactor: Update all documentation to match final ) (see above)
  └─ 178 [NOT STARTED] — (formula-refactor: Expand Examples/ with publication-qualit) (see above)
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
296 [NOT STARTED] — Re-add derived binary operators with dedup fix
297 [COMPLETED] — Verify operator removal and regenerate datasets
298 [RESEARCHED] — Fix c7 labeling bug and regenerate dataset

## Tasks

### 299. Refactor discrete game transfer to remove wrappers
- **Effort**: low (1-2 hours)
- **Status**: [NOT STARTED]
- **Dependencies**: 273
- **Description**: Once task 273 makes the completeness chain sorry-free, inline `discrete_ghr93_theorem6` by having callers use `ghr93_forward_to_backward` directly with discrete typeclass instances. Convert `discrete_rank_embed_eq_drc` to a `@[simp]` lemma. Remove `discrete_ghr93_theorem6_rank_varying` if the general version suffices. Clean up dead code from the old fixed-pivot architecture.

### 298. Fix c7 labeling bug and regenerate dataset
- **Effort**: medium (4-8 hours)
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Dependencies**: 297
- **Research**: [specs/298_fix_c7_labeling_bug_and_regenerate_dataset/reports/01_c7-labeling-bug.md]
- **Plan**: [298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md]

**Description**: Fix c7 labeling bug at formula ~13750 that causes unbounded memory growth in the decision procedure's timeout handling, then regenerate the full c7 dataset. During task 297 dataset regeneration, all 3 attempts to generate c7 stalled at exactly record 13,749 with RSS growing ~40MB/6s. The labeling function enters an apparent infinite loop or unbounded search for formula #13,750 in the sorted enumeration order. The timeout mechanism either does not fire or cannot interrupt the stuck state. Steps: (1) Identify the specific formula at position ~13,750 in the c7 enumeration. (2) Reproduce the hang in isolation with that formula. (3) Diagnose whether the decision procedure's timeout is failing to fire or the procedure is in an uninterruptible state. (4) Fix the timeout handling so it reliably terminates. (5) Regenerate the full c7 dataset (target: 77,272 records).

### 297. Verify operator removal and regenerate datasets
- **Effort**: medium (4-8 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Research**: [specs/297_verify_operator_removal_and_regenerate_datasets/reports/01_verify-operator-removal.md]
- **Plan**: [specs/297_verify_operator_removal_and_regenerate_datasets/plans/01_verify-operator-removal.md]
- **Summary**: [specs/297_verify_operator_removal_and_regenerate_datasets/summaries/01_verify-operator-removal-summary.md]

**Description**: Verify that the removal of 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) from the formula enumerator is correct and complete. (1) Confirm lake build passes with zero errors. (2) Run enumeration at c4-c7 and verify the 6 operators no longer appear in enumerated formulas. (3) Verify formula counts are reduced as expected (~40-60% reduction in raw enumeration). (4) Run exhaustive labeling at c4 and c5 to confirm correctness (zero label disagreements, prefilter and cache still working). (5) Regenerate datasets at c4, c5, and c6 (with appropriate timeouts). (6) Verify the regenerated JSONL files contain no formulas with the removed operators. (7) Compare new dataset sizes against pre-removal baselines from the task 295 diagnostic report.

### 296. Re-add derived binary operators with dedup fix
- **Effort**: medium (4-8 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: 295

**Description**: Re-add the 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) to the formula enumerator, adjusting canonicalization and/or the passesFilter gate so they survive deduplication and appear in the unique pipeline output. These operators were removed in task 295 because they inflated the enumeration space by ~40-60% without contributing unique formulas — their canonical representations collapsed with primitives. Potential approaches: (1) skip canonicalization for formulas containing derived binary operators, (2) canonicalize to the derived form instead of the primitive form, (3) lower or remove the passesFilter complexity gate for these operators, (4) add a fold-aware dedup stage that treats release(p,q) as distinct from neg(untl(neg p, neg q)). The goal is to have all 13 derived operators represented in the final dataset.

### 282. Make dataset generation script default to exhaustive enumeration without formula cap
- **Effort**: small (1-2 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 274

**Description**: The dataset generator defaults to `maxFormulas=5000` (in DatasetExport.lean:501 and FormulaEnumerator.lean:601), silently truncating exhaustive enumeration at higher complexity levels. Change the default behavior so that exhaustive mode keeps ALL enumerated formulas unless an explicit `--max-formulas N` flag is passed. (1) Change default `maxFormulas` in DatasetExport.lean and FormulaEnumerator.lean to 0 or a sentinel value meaning "no limit". (2) Update `FormulaEnumerator.lean:692` to skip the `.take` when maxFormulas is 0/unlimited. (3) Update `run_dataset_generation.sh` to remove `--max-formulas` from exhaustive tiers (c4-c8) since the default will now be unlimited. Keep `--max-formulas` only for stratified tiers (c9+) where it controls the sampling budget. (4) Add a `--max-formulas` flag description to the help text clarifying it's optional and only caps output for exhaustive mode. (5) Regenerate c4-c8 datasets to verify truly exhaustive output.


### 273. Prove chronicle_gap_contradiction from omega-chain construction of LimitDomSubtype
- **Effort**: 8 hours
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: completeness
- **Dependencies**: none
- **Research**:
  - [273_chronicle_gap_contradiction_proof/reports/01_gap-contradiction-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/02_deep-analysis.md]
  - [273_chronicle_gap_contradiction_proof/reports/03_stavi-sorry-analysis.md]
  - [273_chronicle_gap_contradiction_proof/reports/04_ghr93-literature-review.md]
  - [273_chronicle_gap_contradiction_proof/reports/03_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/05_proposition7-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/06_decomposition-path-research.md]
- **Plan**: [273_chronicle_gap_contradiction_proof/plans/08_ghr93-decomposition-plan.md]

**Description**: Prove `discrete_stavi_expressive_completeness` by following GHR93 exactly via the decomposition-formula path. Three new components: (1) `discrete_ghr93_theorem6` -- Theorem 6 for discrete orders (forward game -> backward game, induction on n, Cases I-II only); (2) `discrete_ghr93_proposition7` -- Proposition 7 for discrete orders (sub-interval games -> full EF game, induction on n); (3) game-win-to-existential-transfer bridge wired into sorry chain. Plan v8 replaces v7 which diverged from GHR93. ~700-1300 new lines across DiscreteGameTransfer.lean and StaviCompleteness.lean.

---

### 268. Reynolds pipeline bridge: archive divergent BX code and wire Theorem 14/15 to close IsSuccArchimedean
- **Effort**: medium (310-620 lines new code + 200-400 lines boneyard moves)
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: completeness
- **Dependencies**: none
- **Research**:
  - [268_reynolds_pipeline_bridge/reports/01_bridge-research.md]
  - [268_reynolds_pipeline_bridge/reports/04_team-research.md]
  - [268_reynolds_pipeline_bridge/reports/05_completion-analysis.md]
  - [268_reynolds_pipeline_bridge/reports/06_reynolds-literature-review.md]
- **Plan**: [268_reynolds_pipeline_bridge/plans/01_implementation-plan.md]

**Description**: Archive divergent BX code to Boneyard/ and wire Reynolds sorry-free Theorem 14/15 to close IsSuccArchimedean for completeness_discrete. Phase 1: archive dead code (ReynoldsModelSurgery.lean full, ChronicleToCountermodel.lean BX pipeline extract, Transfer.lean deprecated countermodel_discrete). Phase 2: build PriorModelData bridge from chronicle limit domain. Phase 3: wire one_class to IsSuccArchimedean via contrapositive of gap_of_not_succ_archimedean. Phase 4: close succ_embed_surjective with sorry-free limitDomSubtype_isSuccArchimedean. Phase 5: verify lake build with completeness_discrete sorry-free.

### 257. Investigate large data storage alternatives to Git LFS using Hugging Face
- **Effort**: M
- **Status**: [IMPLEMENTING]
- **Type**: general
- **Priority**: medium
- **Research**: [257_large_data_storage_huggingface/reports/01_large-data-storage.md]
- **Plan**: [257_large_data_storage_huggingface/plans/01_implementation-plan.md]
- **Summary**: [257_large_data_storage_huggingface/summaries/01_execution-summary.md]
- **Description**: Investigate standard practices for storing large data objects outside git (currently using Git LFS with ~146 MB uploads). Research using Hugging Face Datasets as external data host and linking from this repository. Evaluate trade-offs between Git LFS, Hugging Face Hub, and other approaches for dataset versioning and distribution.

### 254. Final metadata and documentation update after completeness pipeline stabilization
- **Effort**: S
- **Status**: [NOT STARTED]
- **Type**: meta
- **Priority**: medium
- **Dependencies**: Tasks 95, 176
- **Description**: Final metadata and documentation update after completeness pipeline stabilization: (1) TODO.md sorry_count_note — comprehensive audit of sorry landscape post-tasks 202/155; (2) ROADMAP.md — annotate all completeness milestones achieved; (3) Transfer.lean and Completeness.lean — update stale axiom audit comments and sorry status documentation; (4) Verify #print axioms completeness_discrete shows no sorryAx. Follows tasks 95 (verification audit) and 176 (Chronicle relocation) to capture the final state.

### 231. Dataset regeneration automation
- **Effort**: large (2-3 days)
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: 230

**Description**: Build comprehensive automation so that every dataset regeneration automatically updates all downstream artifacts and documentation fields. Supersedes task 227 scope. Create `data/scripts/sync-all.py` master sync script that: (a) scans all JSONL files and recomputes metadata JSON files (record counts, rule distributions, schema field lists, valid/invalid ratios, tier distributions, step statistics); (b) updates specific fields in `data/README.md` — file inventory table (Records, Size columns), training record schema table (field count), proof steps statistics, cross-logic split table, NL paraphrase statistics; (c) updates specific fields in `data/dataset-card.md` — overview table, record counts, proof steps section, competitive position paragraph; (d) recomputes SHA-256 hashes and contentSize in `croissant.json`; (e) regenerates `bmlogic-bench-splits.json`; (f) validates all JSONL records against declared schemas; (g) checks train/benchmark formula overlap and reports contamination %; (h) validates metadata key consistency. Modes: `--dry-run` (report only), `--commit` (auto-commit). CI-friendly exit codes. Integrate into agent context for automatic post-implementation sync.

---

### 230. Benchmark refresh — splits, paraphrases, schema alignment
- **Effort**: medium (3-5 hours)
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Priority**: medium
- **Topic**: dataset-enhancement
- **Dependencies**: 229

**Description**: After contamination resolution (task 229), regenerate all benchmark-derived artifacts. (1) Regenerate `bmlogic-bench-splits.json` for current record count — splits reference 727 records but benchmark has 777+. (2) Restore NL paraphrase fields lost when benchmark was regenerated — run `generate_paraphrases.py` and `validate_paraphrases.py`. (3) Schema alignment: add `formula_sexpr`, `formula_tokens`, `pattern_features` to benchmark records so evaluation uses same representations as training. (4) Decide whether to remove or keep redundant `max_modal_depth`/`max_temporal_depth` fields in training data (they duplicate `metrics.modalDepth`/`temporalDepth` and `pattern_key.modalDepth`/`temporalDepth`). (5) Fill `pattern_key` for the 15 benchmark records where it is null.


### 219. LLM baseline difficulty calibration
- **Effort**: medium (3-5 days)
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Priority**: medium
- **Topic**: dataset-enhancement
- **Dependencies**: 216
- **Research**: [219_llm_baseline_difficulty_calibration/reports/01_llm-baseline-research.md]

**Description**: Run bmlogic-bench through multiple LLMs to establish baseline difficulty calibration. Evaluate at least 3 models (GPT-4o, Claude Sonnet, a 7B open model). Report zero-shot accuracy per difficulty tier (easy/medium/hard/very_hard), chain-of-thought vs direct label accuracy, error rate correlation with modal/temporal depth. Include random baseline (50% for balanced benchmark). Publish results in data/baselines/README.md with methodology. Both symbolic formula input and NL paraphrase input (if available from task 216).

---

### 200. GHR93 Case II elegance rewrite (code quality)
- **Effort**: large (20-30 hours)
- **Status**: [NOT STARTED]
- **Type**: lean4
- **Priority**: low
- **Description**: Rewrite ghr93_case_II for GHR93 fidelity. Proof is already sorry-free and axiom-clean (733 lines). The rewrite would replace tau_left/tau_right with a single restricted tau, but this is blocked by a structural gap between GHR93's continuous order-type preservation and the formalization's finite-position EF games. Requires enriching the game framework or finding a new approach. See task 155 Phase 5 research (7 agents, 3 plan revisions).

### 199. Grid order tactic for same_order_type dispatch
- **Effort**: medium (4-8 hours)
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: none (155 depends on this task, not the reverse)

**Description**: Create a bespoke `grid_order_tac` tactic (in `Theories/Bimodal/Automation/`) that automates the `same_order_type` grid dispatch in `ghr93_case_II` (`Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`). The problem: after `same_order_type_grid` expands to `intro i j; simp only [game_tuple]; split_ifs`, it generates ~25 ordering goals per case. Each goal has shape `(a_bwd ⟨k, proof_n+1⟩ < x ↔ resp_tau ⟨k, proof_n⟩ < y) ∧ (... = ... ↔ ...)`. The available ordering lemmas (`tau_sel_y`, `tau_sel_sel`, `sel_pn_ord`, `pn_sel_ord`, `tau_d_sel`, `hord_cd_en_pn`, `pivot_chain_order`, `fwd_x_b`, `fwd_b_y`) are stated with `Fin n` but the goals use `Fin (n+1)`, causing `exact` to fail on metavar unification. The tactic must: (1) try each ordering lemma with automatic Fin bridging via `convert ... using 3 <;> (congr 1; exact Fin.ext (by omega))`, (2) handle the `hab_eq` rewrite for p_n cases (when `¬k < n`, rewrite `a_bwd` to `extendPoint p_n` before applying `sel_pn_ord`/`pn_sel_ord`), (3) handle symmetry (y < sel goal uses `tau_sel_y.symm`), (4) fall back to `sorry` with trace if no lemma applies. After building the tactic, apply it to replace the two sorry fallbacks in `ghr93_case_II`: Case A sorry at line ~1631 and Case B sorry at line ~1940 — these are the last fallthrough goals in the `first | ... | sorry` chains inside the `same_order_type` proof obligation. Verify zero build errors. Iterate on the tactic if the initial version does not close all goals.


### 196. Codebase-wide tactic opportunity survey
- **Effort**: medium (8-12 hours)
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 155, 161
- **Research**:
  - [specs/196_codebase_tactic_survey/reports/01_team-research.md]

**Description**: Systematic survey of the entire `Theories/Bimodal/` codebase (~50K+ lines across Syntax, ProofSystem, Semantics, Metalogic, Theorems, and Automation) to identify every repeated proof pattern that could benefit from custom tactics, simp sets, or macro abstractions. The survey produces a ranked inventory of tactic groups, each of which becomes a new implementation task.

**Methodology**:
1. **Scan every `.lean` file** in `Theories/Bimodal/` using grep, pattern matching, and manual inspection
2. **Classify patterns** into domains: modal proof search, frame semantics, derivation tree manipulation, EF games, model construction, soundness/completeness infrastructure, linear order reasoning, extended carrier manipulation
3. **For each pattern**, record: description, occurrence count, lines per occurrence, example file:line locations, estimated tactic complexity, estimated line savings, dependency on other tactics
4. **Group patterns** into coherent tactic units (a single tactic file or simp set that addresses related patterns)
5. **Rank groups** by (frequency × lines_saved) / implementation_effort
6. **Produce dependency graph** between tactic groups (e.g., `game_tuple_simp` is a prerequisite for `solve_same_order_type`)

**Scope includes** (not limited to):
- `Metalogic/WeakCanonical/` — EF games, expressive completeness, gap elimination, integer models, transfer, chronicle
- `Metalogic/Soundness*.lean` — soundness proof patterns
- `Metalogic/Completeness.lean` — completeness wiring
- `Metalogic/Decidability.lean` — decidability proof patterns
- `Theorems/` — derived theorem proofs (imp_trans chains, modal reasoning)
- `ProofSystem/` — derivation tree construction patterns
- `Semantics/` — frame/model evaluation patterns
- `Syntax/` — formula manipulation patterns

**Output**: A research report containing:
- Table of all identified tactic groups with metrics
- Dependency DAG between groups
- One proposed task per tactic group (title, description, effort, dependencies, target files)
- Recommendations for which existing tasks (185-195) to keep, merge, split, or replace
- Priority ordering for implementation

**Known deferred enhancements to evaluate**:
- **`pivot_order` context-search elab tactic** (deferred from task 195 Phase 3): A full `elab` tactic in `TacticM` that auto-discovers pivot elements, interval bounds, and ordering witnesses from the local context via `getLCtx`/`isDefEq`, then applies `pivot_chain_order'`/`pivot_chain_order_rev'` with zero explicit arguments. The pair-based convenience theorems already implemented in task 195 capture ~90% of the ergonomic win (6 args instead of 8), but the remaining step to full context search (~100 lines of metaprogramming) would eliminate all manual argument assembly at ~65 call sites. Evaluate whether the maintenance cost of context-search brittleness is justified by the marginal gain.

**Relationship to existing tasks**: Tasks 185-195 were created incrementally based on specific needs. This survey may confirm, refine, or supersede them. Task 195 (EF game automation) was created from a focused WeakCanonical/ scan and is likely correct but may be restructured. Tasks 185-193 (modal proof search pipeline) were designed top-down and may benefit from bottom-up validation.


### 194. Migrate Nonempty (DerivationTree ...) patterns to Derivable
- **Effort**: small (3-5 hours)
- **Status**: [NOT STARTED]
- **Research**: [specs/194_migrate_nonempty_to_derivable/reports/01_derivable-migration-seed.md]
- **Task Type**: lean4
- **Dependencies**: 161

**Description**: Replace all 56 occurrences of `Nonempty (DerivationTree ...)` across 16 active Metalogic/ files with the `Derivable` wrapper introduced in task 181. This is a mechanical, definitional migration — `Derivable G p` unfolds to `Nonempty (DerivationTree G p)` so no proof changes are needed. Also replace the local `ContextDerivable` duplicate in `Bundle/Construction.lean` with the global `Derivable` import. Depends on 161 (namespace rename) to avoid redoing the migration during structural refactor. Run after Phase 3.


### 193. Codebase-wide tactic refactoring
- **Effort**: large (30-40 hours)
- **Status**: [NOT STARTED]
- **Research**: [specs/193_codebase_tactic_refactor/reports/01_codebase-refactor-seed.md]
- **Task Type**: lean4
- **Dependencies**: 192, 189

**Description**: Once the tactics library is mature (tasks 185-192), refactor ALL proof files in Theorems/ to use the new automation. Currently ~120 proofs across 6,880 lines use explicit term-level constructions (manual imp_trans chains, explicit DerivationTree constructor applications). Many proofs could be dramatically shortened — e.g., a 7-line imp_trans proof reduces to `modal_search`. Survey all proofs, classify which are automatable vs necessarily structural, apply tactics systematically, and measure compression ratios. Update Examples/ to showcase tactics as pedagogical demonstrations. This task produces the "tactics as product" outcome.


### 192. Master tactic dispatch (tm_prove)
- **Effort**: large (20-25 hours)
- **Status**: [NOT STARTED]
- **Research**: [specs/192_master_tactic_dispatch/reports/01_master-dispatch-seed.md]
- **Task Type**: lean4
- **Dependencies**: 181, 185, 187, 190, 191, 194

**Description**: Create a unified `tm_prove` tactic that dispatches to the right sub-tactic based on goal type and formula structure. If goal is `Derivable G p` (Prop): use aesop with TMDerivable rule set, or `decide_prop` for propositional fragment. If goal is `DerivationTree G p` (Type): use `modal_search` with full search strategies. Implement formula analysis at the meta level to classify goals as propositional/modal/temporal/bimodal and route accordingly. Implement the transfer principle: prove `Derivable` via Prop reasoning, then extract `DerivationTree` via `Classical.choice` when needed. This is the integration point for all tactics work.


### 191. Propositional fragment decision procedure
- **Effort**: large (25-35 hours)
- **Status**: [NOT STARTED]
- **Research**: [specs/191_propositional_decision_procedure/reports/01_decision-procedure-seed.md]
- **Task Type**: lean4
- **Dependencies**: 181

**Description**: Implement a verified decision procedure for the propositional fragment of TM logic. The propositional axioms (prop_k, prop_s, ex_falso, peirce) are complete for classical propositional logic. Create a `Decidable` instance for `Derivable [] p` when `p` is purely propositional (no modal/temporal operators). Two implementation approaches: (a) truth-table evaluation via BoolEval — evaluate `p` under all atom assignments, if all true then derivable; (b) analytic tableaux — more efficient for large formulas. The `decide` tactic could then close propositional derivability goals automatically. This is publishable: a verified decision procedure for classical propositional logic inside a modal logic framework.


### 189. Deduction theorem tactic
- **Effort**: medium (10-12 hours)
- **Status**: [NOT STARTED]
- **Research**: [specs/189_deduction_theorem_tactic/reports/01_deduction-theorem-seed.md]
- **Task Type**: lean4
- **Dependencies**: none (uses existing Core/DeductionTheorem.lean)

**Description**: Wrap the deduction theorem (DeductionTheorem.lean) as a tactic. Create `deduction` tactic: given goal `G ⊢ p → q`, creates subgoal `G, p ⊢ q` (moving antecedent to context). Create `undischarge` tactic for the reverse direction. This gives a natural-deduction feel to Hilbert-style proofs, dramatically simplifying many derivations that currently require explicit imp_trans and b_combinator chains. The deduction theorem proof uses well-founded recursion on tree height (noncomputable), which affects tactic design — the tactic must mark results noncomputable. Currently 20+ files use deduction_theorem directly; the tactic would simplify those call sites.


### 188. Weakening-aware proof search
- **Effort**: medium (10-12 hours)
- **Status**: [NOT STARTED]
- **Research**: [specs/188_weakening_aware_search/reports/01_weakening-aware-seed.md]
- **Task Type**: lean4
- **Dependencies**: 187

**Description**: Extend proof search to automatically apply weakening when a lemma proves from a smaller context. Currently modal_search never applies `DerivationTree.weakening` — if a registered lemma proves `G ⊢ p` but the goal is `D ⊢ p` with `G ⊆ D`, the search fails. Implement context subsumption checking: when a lemma match is found with context `G`, verify `G ≤ D` (list subset) and automatically insert weakening. This removes the most common manual step in existing proofs. 50+ direct weakening calls and 186 `List.nil_subset` uses in the codebase would be eliminated. Integrates with the lemma database (task 187).


### 187. Backward-chaining lemma database (solve_by_elim analogue)
- **Effort**: large (20-25 hours)
- **Status**: [NOT STARTED]
- **Research**: [specs/187_backward_chaining_lemma_db/reports/01_lemma-database-seed.md]
- **Task Type**: lean4
- **Dependencies**: 185

**Description**: Build a TM-logic-specific analogue of Mathlib's `solve_by_elim`. Create a `@[tm_lemma]` attribute that registers `DerivationTree`-valued theorems for backward chaining. All theorems in Combinators.lean (~30), Propositional.lean (~15), ModalS5.lean, TemporalDerived.lean, Perpetuity.lean, and GeneralizedNecessitation.lean are candidates. The tactic: for goal `G ⊢ p`, find any registered lemma whose conclusion unifies with the goal, then recursively solve premises. Use heuristic ordering (axioms first, assumptions second, derived theorems by complexity). This is the core infrastructure that tasks 188 and 192 build upon.


### 186. Unify computable and tactic proof search systems
- **Effort**: medium (12-15 hours)
- **Status**: [NOT STARTED]
- **Research**: [specs/186_unify_search_systems/reports/01_unify-search-seed.md]
- **Task Type**: lean4
- **Dependencies**: 185

**Description**: Unify the two parallel proof search implementations: `modal_search` (TacticM, builds terms via `mkAppM`) and `bounded_search`/`bounded_search_with_proof` (computable, returns `Option (DerivationTree G p)`). The computable search is incomplete — `bounded_search_with_proof` has no modal K or temporal K (lines 951-955 say "would go here"). `SearchConfig` weights exist but `searchProof` ignores them (line 1028). Complete `bounded_search_with_proof` with modal K and temporal K. Make `SearchConfig` weights functional. Optionally have `modal_search` call the computable search as fallback for goals the TacticM search can't handle.


### 180. Add copyright headers, universe polymorphism, and 100-char line limits
- **Effort**: medium (6-10 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Add Mathlib-compatible copyright headers to all Lean files (currently missing on all ~207 files). Adopt universe polymorphism where appropriate (`Type*` instead of `Type`), particularly in Semantics/ and FrameConditions/ where structures should be universe-polymorphic. Enforce 100-character line limit throughout the codebase for Mathlib style compliance. This is a prerequisite for any future Mathlib contribution and improves code quality for the standalone library. Per task 179 research report `02_mathlib-submission.md`.


### 179. Research Lean 4 best practices and infrastructure for tactics and derived theorems
- **Effort**: large (20-30 hours)
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Research**:
  - [specs/179_research_lean4_tactics_infrastructure/reports/01_team-research.md]
  - [specs/179_research_lean4_tactics_infrastructure/reports/02_mathlib-submission.md]

**Description**: Research best practices for Lean 4 in 2026 online and in Mathlib to design a systematic library of tactics, derived theorems in the proof theory, semantic lemmas, and other general results that streamline codebase refactoring and raise overall code quality. In anticipation of completing task 155, cleaning up tasks 176 and 95, and beginning a deep refactor of completed theorems, investigate appropriate metaprogramming, custom tactics, derivation infrastructure, and organizational patterns to achieve the best structure throughout the implementation.


### 178. Publication examples and demo
- **Effort**: small (4-6 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: low
- **Dependencies**: 183, 193

**Description**: Expand `Examples/` with publication-quality demonstrations of the full verified pipeline. Add a complete worked example showing soundness-completeness-decidability on a concrete formula. Add examples exercising each frame class (Base, Dense, Discrete) with the FrameClass-parameterized `DerivationTree` from task 168. Add examples of the expressive completeness result (separation theorem). Update `BimodalProofs.lean` and `TemporalStructures.lean` to use current API conventions. All examples sorry-free.


### 177. Update README and all module docstrings
- **Effort**: small (3-5 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 183, 193

**Description**: Final documentation pass after all structural refactoring is complete. Update `README.md` axiom counts, architecture diagram, and sorry obligations section. Ensure every file in the final structure has an accurate `/-! ... -/` module docstring reflecting its role. Update `ROADMAP.md` to reflect completed refactoring. Verify Axiom Reference doc against actual constructors.


### 176. Relocate Chronicle and archive dead BXCanonical subtree
- **Effort**: medium (4-6 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 155

**Description**: Resolve architectural confusion where `Chronicle/` lives under `BXCanonical/` but is only consumed by `WeakCanonical/`. Move 6 Chronicle files (14,331 lines) to `Metalogic/Chronicle/` or `WeakCanonical/Chronicle/`. Archive entire non-Chronicle BXCanonical subtree (16 files, 4,615 lines, 19 mathematically false sorries under irreflexive semantics) to `Boneyard/BXCanonical/`. Verify `OrderedSeedConsistency.lean` dependency from `WeakCanonical/ReflexiveCanonical.lean` before archiving. Update aggregator imports. Subsumes part of task 130 scope (the BXCanonical dead-code sorries).


### 175. Naming convention and bridge/wrapper cleanup
- **Effort**: medium (6-10 hours)
- **Status**: [RESEARCHED]
- **Research**: [specs/175_naming_convention_and_bridge_cleanup/reports/01_team-research.md]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 168, 174

**Description**: Normalize naming conventions to follow Mathlib-style descriptive conventions and eliminate bridge/wrapper indirection for publication quality. Adopt Mathlib naming patterns: `bot_of_and_neg` instead of `ecq`, `and_left` instead of `lce`, `and_right` instead of `rce`, `or_inl` instead of `ldi`, `or_inr` instead of `rdi`, `absurd` instead of `raa`, `False.elim` instead of `efq`, `not_not_intro` instead of `dni`, etc. Expand opaque abbreviations (`bfmcs`, `drm`, `cud`, `sdc`, `dd_`, `tc_`, `fuc_`, `buc_`). Inline or remove `Bridge.lean` wrappers (993 lines, 16 forwarding definitions). Eliminate trivial primed variants. Normalize `z1_valid` to `axiom_z1_valid` for consistency. Rename `temp_` prefix to `temporal_` for clarity. Purge 81 removed/archived/superseded tombstone comments. Reference Mathlib naming conventions guide and task 179 research report `specs/179_research_lean4_tactics_infrastructure/reports/02_mathlib-submission.md` for the full mapping.


### 170. Establish completeness theorem for TM^dc (dense + complete extension)
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: 169

**Description**: Prove proof-theoretic completeness for TM^dc, the dense + complete extension of the base TM logic. TM^dc extends TM with the density axiom DN (Fφ → FFφ) and the completeness axiom CO (G(Pφ → FPφ) → (Pφ → Fφ)). The standard model is ℝ (the reals as a conditionally complete densely ordered abelian group). This requires constructing a canonical model for TM^dc and proving a truth lemma showing that every TM^dc-consistent formula is satisfiable in a task model over a conditionally complete dense linear order. The existing dense completeness proof (BXCanonical chronicle construction) produces models over quotient types that are dense but not necessarily complete; this task must either extend that construction to produce complete models, or develop a new completeness argument. This is a research-level formalization — the paper "The Construction of Possible Worlds" (Brast-McKie 2025) proves the CO correspondence theorem but does not establish TM^dc completeness. Literature: Burgess 1982/84, Xu 1988, Reynolds 1994 for the base completeness pipeline; the CO correspondence proof in the paper's Appendix provides the semantic characterization.


### 169. Add Complete frame extension with axiom, typeclass, and soundness
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: 168

**Description**: Add the Complete frame class as an extension of Dense to the TM logic formalization, following the paper "The Construction of Possible Worlds" (Brast-McKie 2025). The Complete frame condition (Dedekind completeness) requires every nonempty bounded-above subset of the temporal domain to have a least upper bound. Key changes: (1) Add FrameClass.Complete to the FrameClass enum with Dense ≤ Complete in the partial order (from task 168). (2) Add the CO axiom constructor to Axiom: G(Pφ → FPφ) → (Pφ → Fφ), mapped to minFrameClass = .Complete. (3) Add CompleteTemporalFrame typeclass extending DenseTemporalFrame with ConditionallyCompleteLinearOrder from Mathlib. (4) Add ℝ instance for CompleteTemporalFrame. (5) Prove CO soundness on complete frames (paper Appendix, ~50 lines, uses sInf on the set of counterexamples). (6) Prove CO correspondence: CO is valid over a frame iff the frame is Complete (paper Theorem at line 2453, both directions). (7) Prove CO is valid on Archimedean discrete frames (paper footnote: since every Archimedean discrete ordered group is conditionally complete, CO holds vacuously). (8) Update soundness wrappers in FrameConditions/Soundness.lean. (9) Update README to document the Complete extension and the full frame class hierarchy: Base ≤ Dense ≤ Complete, Base ≤ Discrete.


### 165. Establish semantic finite model property for TM bimodal logic
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Establish the semantic finite model property for TM bimodal logic. The existing FMP in `Decidability/FMP/` is purely proof-theoretic: it shows closure MCS structures are finite and that provability is decidable via MCS enumeration, but it does not construct finite semantic models (task frames with world histories). A standard semantic FMP requires: (1) Starting from a (possibly infinite) canonical model where φ fails, quotient worlds by agreement on the subformula closure of φ. (2) Prove the filtration lemma: truth of all subformulas is preserved in the quotient. The existing `TruthPreservation.lean` handles bot, imp, and box, but temporal operators are absent — the G/H cases were archived (they assumed the T-axiom, invalid under strict semantics) and Until/Since cases were never attempted. Until/Since are known to be problematic for naive filtration since they quantify over intermediate points; selective filtration or alternative constructions may be needed (see Blackburn/de Rijke/Venema Ch 2.3, Reynolds 2003). (3) Prove the quotient model is a valid task frame (nullity, compositionality, reflection preserved under filtration). (4) Bound the model size by `2^|cl(φ)|`. The result should be stated as: if φ is satisfiable in a task model, then φ is satisfiable in a finite task model of bounded size. This is needed for each frame class (serial, dense, discrete) to establish decidability.

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


### 155. Fix no_gaps_discrete import cycle for sorry-free discrete completeness
- **Effort**: 4-8 hours
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: 199
- **Research**:
  - [155_reynolds_pipeline_activation/reports/50_import-cycle-research.md]
  - [155_reynolds_pipeline_activation/reports/55_team-research.md]
  - [155_reynolds_pipeline_activation/reports/60_team-research.md]
  - [155_reynolds_pipeline_activation/reports/61_team-research.md]
- **Plan**:
  - [155_reynolds_pipeline_activation/plans/51_implementation-plan.md]
  - [155_reynolds_pipeline_activation/plans/55_implementation-plan.md]
  - [155_reynolds_pipeline_activation/plans/60_implementation-plan.md]
  - [155_reynolds_pipeline_activation/plans/61_implementation-plan.md]

**Description**: Close the `no_gaps_discrete` import cycle in GoodStructures.lean (GoodStructures.lean:855) by delegating to the sorry-free `no_gaps_discrete_model_surgery` (GoodStructuresModelSurgery.lean:2133), then rewire `completeness_discrete` to use the WeakCanonical path instead of the BX chronicle fallback. The import cycle (GoodStructuresModelSurgery.lean imports GoodStructures.lean) prevents direct delegation; the fix requires re-routing `no_gaps_discrete` to call `no_gaps_discrete_model_surgery` without creating a circular import, likely by extracting the model-surgery logic into a shared file or reorganizing the import chain. Steps: (1) Identify the exact import cycle causing the sorry in `no_gaps_discrete`. (2) Resolve the import cycle (extract shared logic, reorganize files, or use forward declaration). (3) Delegate `no_gaps_discrete` to `no_gaps_discrete_model_surgery`. (4) Rewire `completeness_discrete` to use the WeakCanonical path via `no_gaps_discrete`. (5) Verify `#print axioms completeness_discrete` shows no `sorryAx`. Definition of done: `no_gaps_discrete` delegates to `no_gaps_discrete_model_surgery` (no sorry), `completeness_discrete` uses WeakCanonical path (no sorry), `lake build` passes.


### 131. Refactor module organization for clean APIs and documentation
- **Effort**: 15-25 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Restructure Theories/Bimodal/ file hierarchy for clean APIs and documentation. Currently 130 live .lean files across 7 top-level directories, with the Metalogic/ directory being a catch-all containing 7 subdirectories (Algebraic, Bundle, BXCanonical, ConservativeExtension, Core, Decidability, Relational) plus loose files (Soundness.lean, SoundnessLemmas.lean, DenseSoundness.lean, DiscreteSoundness.lean, Completeness.lean, Metalogic.lean). Goals: (1) Reorganize Metalogic/ into a clearer hierarchy — group soundness files into Metalogic/Soundness/, completeness files into Metalogic/Completeness/, clarify relationship between BXCanonical (chronicle approach) and Algebraic (parametric approach). (2) Add module-level documentation (docstrings on namespace declarations, module descriptions at file tops). (3) Establish clean APIs with explicit exports via root .lean files for each subdirectory. (4) Evaluate whether FrameConditions/ should be merged into Metalogic/ or remain separate. (5) Audit Boneyard/ organization (45 files across 10+ subdirectories). (6) Consider whether docs/ and latex/ and typst/ should remain under Theories/Bimodal/ or move to project root.


### 128. Open set (interior) operator for dense and continuous temporal frames
- **Effort**: 15-25 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: 122

**Description**: Add topological interior operator for dense and continuous temporal frames. On discrete Z the interior is trivial, but on dense Q and continuous R it captures neighborhood-stable truth: Int(phi) true at t iff phi holds in an open neighborhood of t. Related to Dynamic Topological Logic (Kremer-Mints 2005), McKinsey-Tarski topological semantics for S4. Phases: TopologicalSpace instance for dense/continuous TaskFrame, interior Formula constructor with truth clause, S4-like axioms (Int(phi)->phi, Int(phi)->Int(Int(phi))), interaction with temporal operators and S5 box. Note: DTL is not finitely axiomatizable (Fernandez-Duque 2014).


### 127. Time addition operator (+) for bimodal logic TM
- **Effort**: 20-40 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: 123

**Description**: Add time addition operator to TM. phi + psi true at (tau, x) iff there exist y,z with x = y+z and phi at (tau,y) and psi at (tau,z). Internalizes AddCommGroup structure into the object language, extending expressive power from FO[<] to FO[<,+] (Presburger arithmetic). Related to arrow logic (Venema), relevant logic (Routley-Meyer ternary frames), separation logic (BI). Phases: add tadd/tsub constructors to Formula, truth clause, basic axioms (associativity, commutativity, identity, inverse), soundness, interaction with G/H/U/S/box. Completeness (ternary canonical model) and decidability are open research problems.


### 125. Jónsson-Tarski representation theorem for TM logic
- **Effort**: 15-25 hours
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Dependencies**: 116, 122, 163

**Description**: Implement a Jónsson-Tarski representation theorem for TM logic: every STSA embeds into the complex algebra of a concrete frame. This is a purely algebraic structural result with no mention of provability — distinct from the completeness theorems (renamed in task 163).

**Phased approach**:
- **Phase 1 — Complex algebra `Cm(F)`**: Define the powerset STSA for TaskFrames with `box`/`G`/`H`/`sigma` operators derived from frame relations. Prove `Cm(F)` satisfies all STSA axioms. Self-contained, depends only on Semantics and Mathlib.
- **Phase 2 — Ultrafilter frame `Uf(A)`**: Given abstract STSA `A`, construct frame whose worlds are ultrafilters with canonical relations `R_G`, `R_H`, `R_Box` (seed infrastructure recovered in task 163 from Boneyard). Prove `Uf(A)` satisfies TaskFrame axioms. Duration type D may require parametric treatment.
- **Phase 3 — Embedding theorem**: Prove `η(a) = {U | a ∈ U}` is an injective STSA homomorphism `A ↪ Cm(Uf(A))`. Core J-T result.
- **Phase 4 — Since/Until extension**: Extend STSA typeclass with binary `untl`/`sinc` operators (additive in each argument, conjugated per Venema 1997). Prove representation for full operator signature. S/U induce ternary canonical relations in the BAO framework.

**Start with basic `{□, G, H}` fragment** (Phases 1–3) before tackling S/U (Phase 4).

**Prerequisites**: Resolve 6 algebraic sorries (`temp_k_dist`, `temp_a`, `temp_l` in TenseS5Algebra/InteriorOperators/LindenbaumQuotient). Obtain 3 missing papers: Jónsson-Tarski 1951/52 (AJM), BRV 2001 Ch. 5, Goldblatt 1989 (APAL). Task 992 research report maps ~80% of needed infrastructure.

**Architecture**: Restructure `Algebraic/` into `Core/` (shared STSA, Boolean, ultrafilter), `Completeness/` (renamed existing), `Representation/` (new J-T work: ComplexAlgebra.lean, UltrafilterFrame.lean, RepresentationEmbedding.lean, FrameProperties.lean).

**Key references**: Venema 1991 Ch. 2 + App. A (BAO duality for temporal), de Rijke-Venema 1995 Thm 3.5 (Sahlqvist canonicity), Venema 1997 Thm 1.4 (conjugated varieties), GHV 2003 (BAOs and modal logic), Venema 1993 Anti-Axioms (orthodox axiomatizability).


### 95. Verification audit: #print axioms + sorry classification pass
- **Effort**: 2-4 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Priority**: medium
- **Dependencies**: 155
- **Created**: 2026-04-10

**Description**: Verification pass on sorry status for `completeness_discrete` and `bx_completeness`. Updated scope after task 202 completion and task 155 re-scope: (1) Verify `dd_countermodel_chronicle_dense` and `dd_countermodel_chronicle_mixed_sorry` show no `sorryAx` (confirmed sorry-free as of 2026-05-15). (2) Trace the discrete case sorryAx: The BX chronicle path (`dd_countermodel_chronicle_discrete` -> `succ_embed_surjective` -> `limitDomSubtype_isSuccArchimedean` -> `succ_cofinal`) is being bypassed. The correct fix is the WeakCanonical path: task 155 targets closing the `no_gaps_discrete` import cycle (GoodStructures.lean:855) by delegating to `no_gaps_discrete_model_surgery` (GoodStructuresModelSurgery.lean:2133), then rewiring `completeness_discrete`. Note: `succ_cofinal` remains the current root sorry on the BX chronicle path (ChronicleToCountermodel.lean), but this path is dead code -- the WeakCanonical route via `no_gaps_discrete_model_surgery` (already sorry-free) is the production path once the import cycle is resolved by task 155. (3) Classify all Metalogic/ sorry occurrences as critical-path vs dead-code vs non-critical-path. (4) Update stale axiom audit comments in Completeness.lean (lines 177-234 reference CE:3570 which is no longer the sorry source). (5) Verify soundness and decidability remain sorry-free. (6) Produce audit report.


### 290. Improve tableau fuel allocation heuristic for imbalanced branches
- **Effort**: small (4-6 hours)
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Priority**: medium
- **Topic**: dataset-enhancement
- **Dependencies**: Task 288 (invalid-pattern prefilter's branch analysis tools — `estimateBranchDifficulty` — can be reused for fuel allocation)
- **Report**: [specs/290_improve_tableau_fuel_allocation/reports/01_fuel-allocation-research.md]
- **Plan**: [specs/290_improve_tableau_fuel_allocation/plans/01_fuel-allocation-plan.md]

**Description**: In `expandBranchWithFuel` (Saturation.lean:181), when a branching rule fires, fuel is divided equally among sub-branches: `fuel / branches.length`. For imbalanced branches (one branch closes trivially, another is deep), this wastes fuel on the easy branch and starves the hard one. The result: the hard branch times out even though total fuel would have been sufficient if allocated adaptively.

**Implementation**:
1. Add an `estimateBranchDifficulty : Branch → Nat` heuristic:
   - Count unexpanded temporal formulas (U/S/F/P/G/H) — more temporal = harder.
   - Count modal formulas (□/◇) — modal adds world creation cost.
   - Count branch depth — deeper branches are closer to saturation.
   - Weighted sum: `difficulty = 3 * temporalCount + 2 * modalCount + branchDepth`.
2. In `expandBranchWithFuel`, when a split occurs, allocate fuel proportionally to difficulty:
   - Compute total difficulty = sum of difficulties across all sub-branches.
   - Assign each branch `fuel_i = fuel * difficulty_i / totalDifficulty`.
   - Ensure minimum fuel of 1 per branch (avoid zero-fuel branches).
3. **Conservative fallback**: if any branch has `difficulty = 0` (e.g., propositional-only), give it a small fixed allocation (e.g., `fuel / (branches.length * 2)`) and redistribute the rest.
4. Prove termination still holds: the total fuel across all branches ≤ original fuel, and each recursive call gets strictly less fuel than parent (except the fuel=0 base case).
5. Benchmark: run c6 labeling before/after heuristic change. Measure:
   - Timeout rate change
   - Distribution of "closed vs timeout" for formulas that previously timed out
   - Any regressions (formulas that closed before but now timeout due to over-allocation to one branch)

**Expected impact**: Modest (2-5% timeout reduction). Best for formulas with clear easy/hard branch splits (e.g., `impPos` where one side is a tautology and the other is complex).

**Risk**: Heuristic inaccuracy. If `estimateBranchDifficulty` mis-predicts, fuel allocation becomes worse than equal division. Mitigation: keep equal division as fallback when heuristic confidence is low (e.g., all branches have similar difficulty).

---

### 291. Upgrade Lean toolchain from v4.27 to v4.31 and update Mathlib
- **Effort**: medium (4-8 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: critical
- **Topic**: toolchain
- **Dependencies**: none

**Description**: Upgrade Lean toolchain from v4.27 to v4.31 and update Mathlib to the same pin as cslib. This is a prerequisite for all porting tasks: cslib uses Lean 4.31 and tasks 292-294 cannot proceed until BimodalLogic builds cleanly on 4.31. Steps: (1) Update lean-toolchain to v4.31.0-rc1 (or current cslib pin). (2) Run lake update to fetch compatible Mathlib. (3) Fix any API breakage caused by Lean/Mathlib version bump (expect ~50-200 lines of fixes across formula, tactic, and instance changes). (4) Run lake build to confirm zero errors. (5) Run existing tests to confirm no regressions. This task unlocks tasks 292, 293, 294 and all cslib porting tasks (2-13).

---

### 292. Add copyright headers (Apache 2.0) to all source files under Theories/Bimodal/
- **Effort**: small (1-2 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: publication-quality
- **Dependencies**: Task 291

**Description**: Add Apache 2.0 copyright headers to all source files under Theories/Bimodal/ (approximately 160 .lean files). cslib requires headers on all contributed files following the format: "-- Copyright (c) 2024 The Bimodal Logic Contributors. All rights reserved. -- Released under Apache 2.0 license as described in the file LICENSE. -- Authors: [author names]". Use a script to batch-add headers to files that lack them. Verify no duplicates are introduced. Run lake build to confirm no import errors.

---

### 293. Audit and fix Mathlib linter compliance across sorry-free modules
- **Effort**: medium (4-8 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: publication-quality
- **Dependencies**: Task 291

**Description**: Audit and fix Mathlib linter compliance across all sorry-free modules scheduled for porting to cslib (Syntax, Semantics, ProofSystem, Theorems, FrameConditions, Soundness, MCS/Deduction, Completeness, Decidability, Separation, ConservativeExtension). Run the Mathlib linter (set_option linter.all true or use #check_lint). Fix: (1) Naming convention violations -- Mathlib uses descriptive snake_case names not opaque abbreviations (e.g., bfmcs, drm). (2) Missing docstrings on public declarations. (3) Universe polymorphism issues. (4) Line length violations (100 char limit). (5) Unused variable warnings. This task produces files ready for direct porting to cslib without linter failures.

---

### 294. Eliminate sorry in Theorems/ModalS5.lean and Theorems/Perpetuity/Principles.lean
- **Effort**: small (2-4 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: sorry-elimination
- **Dependencies**: Task 291

**Description**: Eliminate all sorry instances in Theorems/ModalS5.lean and Theorems/Perpetuity/Principles.lean. These files are needed for PR 4 (Derived Theorems) in cslib but contain 1-3 sorry each. Analysis suggests these are small enough to resolve: ModalS5.lean sorries likely require direct axiom application or simple combinatorial arguments; Perpetuity/Principles.lean sorries relate to fixpoint principles for G/H operators that should follow from the core axiom system. Complete both files to be fully sorry-free. Run lake build to verify zero errors and zero sorries.

