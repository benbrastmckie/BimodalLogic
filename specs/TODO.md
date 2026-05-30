---
next_project_number: 224
repository_health:
  overall_score: 95
  production_readiness: near-publication
  last_assessed: 2026-05-22T00:00:00Z
task_counts:
  active: 35
  completed: 151
  in_progress: 1
  not_started: 25
  abandoned: 0
  total: 186
technical_debt:
  sorry_count: 1
  sorry_count_note: "Audited 2026-05-15: 1 root sorry on bx_completeness critical path: succ_cofinal (ChronicleToCountermodel.lean:1885) blocks limitDomSubtype_isSuccArchimedean → succ_embed_surjective → discrete countermodel → bx_completeness. Dense case sorry-free (dd_countermodel_chronicle_dense). Mixed case sorry-free (dd_countermodel_chronicle_mixed_sorry via False.elim, task 142). Tasks 143-148 closed NormalForm/KType/table_correctness sorries. Reynolds pipeline bypass (task 155) in progress. ~17 dead-code sorries in BXCanonical pipeline (bypassed by Chronicle). ~6 non-critical TruthLemma sorries. Soundness, SoundnessLemmas, and Decidability are sorry-free. Zero axioms in Separation module (tasks 157, 171)."
  publication_path_sorries: 1
  axiom_count: 0
  axiom_count_note: "Zero custom axioms. Prior-UZ/SZ and discrete_box_necessity are standard axiom constructors with sorry-free soundness proofs. Separation module has zero axioms (tasks 157, 171 eliminated all 9)."
  build_errors: 0
  status: excellent
---

# TODO

<!-- Vault transition: 2026-03-20 - Archived to specs/vault/01-vault/ -->

## Task Order

*Updated 2026-05-29. 35 active tasks.*

**Goal**: Sorry-free `bx_completeness` → structural refactor → tactics library → tactic-powered codebase refinement → documentation → publication-quality codebase.

### Phase 1 — Discrete Completeness (independent, Option C path)

202 [PARTIAL] — Reynolds Hybrid Path (v8): Phase 1 complete (Theorem 5, 395 lines). Task 4.3 complete (Prior-UZ/SZ discharge). Plan v8 replaces novel TaskFrame (proven impossible) with hybrid: Phases 2-4 close no_gaps_discrete via Reynolds model surgery, Phase 5 derives succ_cofinal from one_class to close Path A (countermodel_discrete_enriched). 22 hours, 5 phases.
  - **Reports**:
    - [specs/202_reynolds_k_equivalence_bypass/reports/07_bfmcs-bypass-research.md]
    - [specs/202_reynolds_k_equivalence_bypass/reports/08_succ-cofinal-dependency-trace.md]
  - **Plan**: [specs/202_reynolds_k_equivalence_bypass/plans/09_reynolds-hybrid-plan.md]

### Phase 1 — Grid Tactic (unblocks 155 Phase 3B)

199 [NOT STARTED] — Grid order tactic: bespoke `grid_order_tac` for same_order_type dispatch with automatic Fin bridging, then apply to close Phase 3B sorry sites in CaseAnalysis.lean.
  └─ 155

### Phase 1b — Resume 155 (after task 199 grid tactic)

155 [PLANNED] — Reynolds pipeline: Plan v43 -- Definitive GHR93-faithful plan. Independent X_t construction (not via nf_characterizable_by_stavi), delta=4, general linear orders (Cases III/IV with left/right gap formulas), interval type formula A. 6 phases, 20-30 hours.
  └─ 154, 199

### Phase 2 — Post-155 Cleanup

176 [NOT STARTED] — Relocate Chronicle/ out of BXCanonical/, archive dead BXCanonical subtree
  └─ 155
95 [NOT STARTED] — Verification audit: `#print axioms` + sorry classification pass
  └─ 155

### Phase 3 — Structural Refactor

175 [RESEARCHED] — Naming conventions + bridge/wrapper cleanup
180 [NOT STARTED] — Copyright headers, universe polymorphism, 100-char line limits
131 [NOT STARTED] — Restructure Theories/Bimodal/ file hierarchy for clean APIs
  └─ 175, 180
161 [NOT STARTED] — Rename Theories/Bimodal/ to final namespace (LAST in Phase 3)
  └─ 131

### Phase 4 — Standards & Derivable Migration (after structural refactor)

183 [PLANNED] — Documentation standards: directory READMEs, module docstrings, comment conventions
  └─ 161
194 [NOT STARTED] — Migrate Nonempty (DerivationTree ...) patterns to Derivable
  └─ 161

### Phase 5 — Tactics Survey (generates tactic task roadmap)

196 [RESEARCHED] — Codebase-wide tactic opportunity survey (generates tasks)
  └─ 155, 161

### Phase 5a — Tactics Tier 1 (modal foundations, after structural refactor)

185 [RESEARCHED] — Complete axiom & derived theorem coverage in modal_search
190 [RESEARCHED] — Derived operator normalization tactic (modal_norm)

### Phase 6 — Tactics Tier 2 (engineering)

186 [NOT STARTED] — Unify computable and tactic proof search systems
  └─ 185
187 [NOT STARTED] — Backward-chaining lemma database (solve_by_elim analogue)
  └─ 185
189 [NOT STARTED] — Deduction theorem tactic
188 [NOT STARTED] — Weakening-aware proof search
  └─ 187

### Phase 7 — Tactics Tier 3 (research-level)

191 [NOT STARTED] — Propositional fragment decision procedure
192 [NOT STARTED] — Master tactic dispatch (tm_prove)
  └─ 185, 187, 190, 191, 194

### Phase 8 — Tactic-Powered Codebase Refactoring

193 [NOT STARTED] — Codebase-wide tactic refactoring
  └─ 192, 189

### Phase 9 — Final Documentation & Examples

177 [NOT STARTED] — Update README and all module docstrings
  └─ 183, 193
178 [NOT STARTED] — Publication examples and demo
  └─ 183, 193

### Deferred — New Features (post-publication)

169 [NOT STARTED] — Complete frame extension: axiom, typeclass, soundness, correspondence
170 [NOT STARTED] — Completeness theorem for TM^dc (dense + complete)
  └─ 169
127 [NOT STARTED] — Add time addition operator (+) for bimodal logic TM
128 [NOT STARTED] — Add topological open set (interior) operator
165 [NOT STARTED] — Establish semantic finite model property (filtration)
164 [NOT STARTED] — Prove tableau correctness (connect decide to semantic validity)
  └─ 165
125 [NOT STARTED] — Jónsson-Tarski representation theorem for TM logic

### Dataset Enhancements (from competitive landscape analysis, task 215)

218 [NOT STARTED] — Finalize Croissant metadata + HF leaderboard infrastructure
216 [RESEARCHED] — Natural-language paraphrase augmentation for bmlogic-bench
217 [NOT STARTED] — Complexity tier extension to c9/c11 (Lean oracle)
220 [NOT STARTED] — Anchor coverage expansion (14/42 → 42/42 axiom constructors)
221 [NOT STARTED] — Proof step dataset expansion (36 → 200+ theorems)
219 [NOT STARTED] — LLM baseline difficulty calibration
  └─ 216

### Meta/Tooling

162 [NOT STARTED] — Enforce strict plan compliance for formal implementation agents


## Tasks

### 223. Rename documentation files to lowercase kebab-case and update all references
- **Effort**: small (2-4 hours)
- **Status**: [COMPLETED]
- **Task Type**: general
- **Report**: [specs/223_rename_docs_lowercase_kebab_case/reports/01_rename-docs-research.md]
- **Plan**: [specs/223_rename_docs_lowercase_kebab_case/plans/02_rename-docs-plan.md]
- **Summary**: [specs/223_rename_docs_lowercase_kebab_case/summaries/03_rename-docs-summary.md]

**Description**: Rename all documentation files created/updated by task 183 to use consistent lowercase kebab-case naming. Audit Theories/Bimodal/docs/reference/ and scripts/ for any files using camelCase, Title_Case, or other non-kebab-case conventions, rename them to lowercase kebab-case, and systematically update all references across the entire Theories/Bimodal/ tree and specs/. Ensure the documentation standard reference docs themselves prescribe lowercase kebab-case as the naming convention going forward. Verify no broken references remain after renaming using scripts/readme-lint.sh.

### 222. Consolidate data/ and hf-dataset/ into unified directory structure
- **Status**: [COMPLETED]
- **Task Type**: general
- **Report**: [specs/222_consolidate_data_hf_dataset_directory/reports/01_consolidate-dirs-research.md]
- **Plan**: [specs/222_consolidate_data_hf_dataset_directory/plans/02_consolidate-dirs-plan.md]
- **Summary**: [specs/222_consolidate_data_hf_dataset_directory/summaries/03_consolidate-dirs-summary.md]

**Completion**: Moved hf-dataset/ to data/hf-dataset/ (git mv, history preserved), recreated 4 symlinks with corrected relative paths, moved competitive-landscape.md to docs/research/, replaced data/README.md with lightweight directory README, preserved HF dataset card as data/dataset-card.md. Lake build passes.

**Description**: Consolidate data/ and hf-dataset/ into a unified data/ directory with appropriate subdirectories. Add README.md files following repository standards. Move extended documentation to docs/. Currently both directories exist at root with overlapping concerns — merge into one coherent structure.

---

### 215. Competitive analysis and enhancement roadmap for BMLogic datasets
- **Effort**: small (4-6 hours)
- **Status**: [COMPLETED]
- **Task Type**: general
- **Dependencies**: 214, 208
- **Research**: [specs/215_dataset_competitive_analysis/reports/01_competitive-analysis.md]
- **Plan**: [specs/215_dataset_competitive_analysis/plans/01_competitive-analysis-plan.md]
- **Summary**: [specs/215_dataset_competitive_analysis/summaries/01_competitive-analysis-summary.md]

**Description**: Evaluate the novelty and value of BMLogic datasets (bmlogic-bench, bmlogic-c5, bmlogic-c7, proof_steps) by comparison with nearest competitors in formal logic / modal logic / theorem proving benchmarks (e.g., FOLIO, ProofWriter, LogicNLI, PrOntoQA, FLUTE, ReClor, AR-LSAT, NaturalProofs, LeanDojo, miniF2F, INT). Assess dimensions: domain coverage (bimodal/temporal/S5 vs propositional/FOL), task format (provability + countermodel vs entailment-only), proof trace availability, formula complexity distribution, dataset scale, schema richness (multi-representation fields). Identify gaps and potential enhancements: additional complexity tiers, harder benchmark slices, cross-logic transfer sets, natural-language paraphrase augmentation, difficulty calibration against LLM baselines, Croissant metadata, leaderboard scaffolding. Produce a competitive landscape report with a feature comparison matrix and a prioritized list of enhancement opportunities.

**Completion**: Produced publication-ready competitive landscape report (data/competitive-landscape.md) covering 12 benchmarks across 13 dimensions; implemented cross-logic transfer splits (R5) with generate_splits.py and bmlogic-bench-splits.json; created MLCommons Croissant 1.0 metadata skeleton (data/croissant.json); updated data/README.md.

---

### 221. Proof step dataset expansion (36 → 200+ theorems)
- **Effort**: large (2-3 weeks)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: low
- **Topic**: dataset-enhancement

**Description**: Expand proof_steps.jsonl from 36 to 200+ theorems with better temporal rule coverage. Current rule distribution biased toward axiom application (50%) and modus_ponens (49%). Target: temporal rules (necessitation, temporal_duality, temporal_necessitation) represent at least 10% of steps. Record format backward-compatible with current 8-field schema. Uses the proof_extractor executable. Requires identifying and proving additional theorems that exercise temporal rules.

---

### 220. Anchor coverage expansion (14/42 → 42/42 axiom constructors)
- **Effort**: medium (1-2 weeks)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Topic**: dataset-enhancement

**Description**: Expand benchmark anchor coverage from 14/42 to 42/42 axiom constructors, with at least 3 instances each (target: 126+ anchor records vs current 78). Ensures all TM axiom patterns are explicitly evaluated in bmlogic-bench. Uses the benchmark_anchors executable in the Lean 4 project. Overall benchmark size may grow to 800-900 records. No regression in existing record labels. Requires regenerating benchmark metadata after expansion.

---

### 219. LLM baseline difficulty calibration
- **Effort**: medium (3-5 days)
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Priority**: medium
- **Topic**: dataset-enhancement
- **Dependencies**: 216

**Description**: Run bmlogic-bench through multiple LLMs to establish baseline difficulty calibration. Evaluate at least 3 models (GPT-4o, Claude Sonnet, a 7B open model). Report zero-shot accuracy per difficulty tier (easy/medium/hard/very_hard), chain-of-thought vs direct label accuracy, error rate correlation with modal/temporal depth. Include random baseline (50% for balanced benchmark). Publish results in data/baselines/README.md with methodology. Both symbolic formula input and NL paraphrase input (if available from task 216).

---

### 218. Croissant metadata finalization + HuggingFace leaderboard
- **Effort**: small (2-4 hours + 1-3 days for optional Space)
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Priority**: high
- **Topic**: dataset-enhancement

**Description**: Finalize Croissant metadata (data/croissant.json skeleton exists) and update HuggingFace infrastructure. (a) Validate croissant.json against MLCommons 1.0 Python tooling, fix any schema issues, ensure all 4 JSONL distributions listed with correct field descriptions. (b) Update HF README task_categories to ["text-generation", "other"] with task_ids: ["formal-provability-classification"]. (c) Optional: Gradio Space for interactive formula classification demo and leaderboard submission endpoint.

---

### 217. Complexity tier extension to c9/c11
- **Effort**: large (2-4 weeks, Lean oracle compute)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement

**Description**: Extend exhaustive formula enumeration to complexity 9 and 11. bmlogic-c9.jsonl: exhaustive (if feasible) or stratified-sampled coverage of complexity ≤9, estimated 300K-800K records. bmlogic-c11.jsonl: stratified-sampled coverage of complexity ≤11, estimated 500K-2M records. 14-field schema compatible with c5/c7. Add very_hard+ benchmark slice with 100+ records at complexity 8-9. Add max_temporal_depth and max_modal_depth as first-class filter fields. Risk: intractable file sizes at c9 mitigated by stratified sampling.

---

### 216. Natural-language paraphrase augmentation for bmlogic-bench
- **Effort**: large (2-4 weeks, includes human review)
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Priority**: high
- **Topic**: dataset-enhancement
- **Research**: [216_nl_paraphrase_augmentation/reports/01_team-research.md]

**Description**: Add natural-language paraphrase field (nl_paraphrase) to all 727 bmlogic-bench records. Rule-based generation for formulas with modalDepth + temporalDepth ≤ 2 (~75% of benchmark); LLM-assisted with human verification for complex nesting (depth ≥ 3). Separate nl_paraphrase_method field records generation method. Backward-compatible: optional field. Acceptance: all 727 records have non-null nl_paraphrase, grammatically correct for depth ≤ 2, spot-checked for depth ≥ 3, generation code published.

---

### 214. Dataset cleanup, standardization, and documentation
- **Effort**: small (4-6 hours)
- **Status**: [COMPLETED]
- **Completed**: 2026-05-29
- **Summary**: Cleaned up data/ directory: updated 4 script defaults from medium/deep to c5/c7, deleted 11 superseded/intermediate/test files, installed Git LFS for large datasets, rewrote .gitignore, enriched c5/c7 metadata with common headers, created proof_steps_metadata.json, wrote comprehensive data/README.md, and validated all dataset schemas with zero errors.
- **Task Type**: general
- **Dependencies**: 204, 205
- **Research**:
  - [214_dataset_cleanup_documentation/reports/01_team-research.md]
  - [214_dataset_cleanup_documentation/reports/02_task-213-impact.md]
- **Plan**:
  - [214_dataset_cleanup_documentation/plans/01_dataset-cleanup-plan.md]
  - [214_dataset_cleanup_documentation/plans/02_dataset-cleanup-plan.md]
- **Summary Artifact**: [214_dataset_cleanup_documentation/summaries/02_dataset-cleanup-summary.md]

---

**Description**: Review, clean up, and document the data/ directory. Remove intermediate pipeline artifacts (axiom-instances.jsonl, bmlogic-bench-candidates.jsonl, bmlogic-bench-validated.jsonl) and test files (test.jsonl, test_c4.jsonl, test_metadata.json, test_c4_metadata.json). Keep final datasets: bmlogic-bench.jsonl (727 benchmark formulas), bmlogic-deep.jsonl (53,979 training records), bmlogic-medium.jsonl (5,136 training records), proof_steps.jsonl (2,424 proof step records). Standardize metadata JSON schemas across all kept datasets to match the richer bmlogic-bench_metadata.json format. Create a comprehensive data/README.md documenting each dataset. Update .gitignore to track final datasets while excluding intermediates. Verify all kept datasets have consistent field schemas.

---

### 208. HuggingFace dataset packaging for BMLogic-Bench
- **Effort**: small (4-6 hours)
- **Status**: [COMPLETED]
- **Completed**: 2026-05-29
- **Summary**: Created HuggingFace dataset packaging under hf-dataset/: dataset card README.md with YAML frontmatter for 4 configs (bmlogic-bench default/test, c5/c7 train, proof-steps train), CC BY 4.0 license, upload.py with --dry-run support, validate.py (all checks passing), requirements.txt, PUBLISHING.md guide, and symlinks to all 4 JSONL data files.
- **Task Type**: general
- **Dependencies**: 205, 207
- **Research**: [208_huggingface_dataset_packaging/reports/01_huggingface-packaging.md]
- **Plan**: [208_huggingface_dataset_packaging/plans/01_huggingface-packaging-plan.md]
- **Summary Artifact**: [208_huggingface_dataset_packaging/summaries/01_huggingface-packaging-summary.md]

**Description**: Package the BMLogic-Bench dataset for HuggingFace Datasets Hub publication. Create dataset_info.json metadata file, Python script to convert JSONL to Parquet format, dataset card (README.md) with usage examples and citation info, and train/val/test split validation. Target: one-line loading via `datasets.load_dataset("logos-labs/bmlogic-bench")`. Include dataset statistics, license, and benchmark description for the NeurIPS 2026 Datasets track submission.

---

### 202. Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Effort**: 22 hours
- **Status**: [RESEARCHING]
- **Type**: lean4
- **Priority**: CRITICAL
- **Dependencies**: none
- **Research**:
  - [202_reynolds_k_equivalence_bypass/reports/01_reynolds-bypass-research.md]
  - [202_reynolds_k_equivalence_bypass/reports/04_team-research.md]
  - [202_reynolds_k_equivalence_bypass/reports/05_reynolds-theorem-14-research.md]
  - [202_reynolds_k_equivalence_bypass/reports/07_bfmcs-bypass-research.md]
  - [202_reynolds_k_equivalence_bypass/reports/08_succ-cofinal-dependency-trace.md]
- **Plan**:
  - [202_reynolds_k_equivalence_bypass/plans/09_reynolds-hybrid-plan.md]
- **Description**: Formalize Reynolds Theorem 5 (US expressive completeness over Prior structures) and Lemmas 6-13 + Theorem 14 (model surgery / no-gaps) to close no_gaps_discrete, then derive succ_cofinal from one_class to close Path A (countermodel_discrete_enriched) for sorry-free completeness_discrete. Plan v8 (hybrid path): Phase 1 complete (Theorem 5, 395 lines), Task 4.3 complete (Prior-UZ/SZ discharge). Phases 2-3 (Reynolds model surgery), Phase 4 (Theorem 14 + close no_gaps_discrete), Phase 5 (bridge one_class to succ_cofinal). ~1100 new lines.

---

### 200. GHR93 Case II elegance rewrite (code quality)
- **Effort**: large (20-30 hours)
- **Status**: [NOT STARTED]
- **Type**: lean4
- **Priority**: low
- **Description**: Rewrite ghr93_case_II for GHR93 fidelity. Proof is already sorry-free and axiom-clean (733 lines). The rewrite would replace tau_left/tau_right with a single restricted tau, but this is blocked by a structural gap between GHR93's continuous order-type preservation and the formalization's finite-position EF games. Requires enriching the game framework or finding a new approach. See task 155 Phase 5 research (7 agents, 3 plan revisions).

### 199. Grid order tactic for same_order_type dispatch
- **Effort**: medium (4-8 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: 155

**Description**: Create a bespoke `grid_order_tac` tactic (in `Theories/Bimodal/Automation/`) that automates the `same_order_type` grid dispatch in `ghr93_case_II` (`Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`). The problem: after `same_order_type_grid` expands to `intro i j; simp only [game_tuple]; split_ifs`, it generates ~25 ordering goals per case. Each goal has shape `(a_bwd ⟨k, proof_n+1⟩ < x ↔ resp_tau ⟨k, proof_n⟩ < y) ∧ (... = ... ↔ ...)`. The available ordering lemmas (`tau_sel_y`, `tau_sel_sel`, `sel_pn_ord`, `pn_sel_ord`, `tau_d_sel`, `hord_cd_en_pn`, `pivot_chain_order`, `fwd_x_b`, `fwd_b_y`) are stated with `Fin n` but the goals use `Fin (n+1)`, causing `exact` to fail on metavar unification. The tactic must: (1) try each ordering lemma with automatic Fin bridging via `convert ... using 3 <;> (congr 1; exact Fin.ext (by omega))`, (2) handle the `hab_eq` rewrite for p_n cases (when `¬k < n`, rewrite `a_bwd` to `extendPoint p_n` before applying `sel_pn_ord`/`pn_sel_ord`), (3) handle symmetry (y < sel goal uses `tau_sel_y.symm`), (4) fall back to `sorry` with trace if no lemma applies. After building the tactic, apply it to replace the two sorry fallbacks in `ghr93_case_II`: Case A sorry at line ~1631 and Case B sorry at line ~1940 — these are the last fallthrough goals in the `first | ... | sorry` chains inside the `same_order_type` proof obligation. Verify zero build errors. Iterate on the tactic if the initial version does not close all goals.

---

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

---

### 194. Migrate Nonempty (DerivationTree ...) patterns to Derivable
- **Effort**: small (3-5 hours)
- **Status**: [NOT STARTED]
- **Research**: [specs/194_migrate_nonempty_to_derivable/reports/01_derivable-migration-seed.md]
- **Task Type**: lean4
- **Dependencies**: 161

**Description**: Replace all 56 occurrences of `Nonempty (DerivationTree ...)` across 16 active Metalogic/ files with the `Derivable` wrapper introduced in task 181. This is a mechanical, definitional migration — `Derivable G p` unfolds to `Nonempty (DerivationTree G p)` so no proof changes are needed. Also replace the local `ContextDerivable` duplicate in `Bundle/Construction.lean` with the global `Derivable` import. Depends on 161 (namespace rename) to avoid redoing the migration during structural refactor. Run after Phase 3.

---

### 193. Codebase-wide tactic refactoring
- **Effort**: large (30-40 hours)
- **Status**: [NOT STARTED]
- **Research**: [specs/193_codebase_tactic_refactor/reports/01_codebase-refactor-seed.md]
- **Task Type**: lean4
- **Dependencies**: 192, 189

**Description**: Once the tactics library is mature (tasks 185-192), refactor ALL proof files in Theorems/ to use the new automation. Currently ~120 proofs across 6,880 lines use explicit term-level constructions (manual imp_trans chains, explicit DerivationTree constructor applications). Many proofs could be dramatically shortened — e.g., a 7-line imp_trans proof reduces to `modal_search`. Survey all proofs, classify which are automatable vs necessarily structural, apply tactics systematically, and measure compression ratios. Update Examples/ to showcase tactics as pedagogical demonstrations. This task produces the "tactics as product" outcome.

---

### 192. Master tactic dispatch (tm_prove)
- **Effort**: large (20-25 hours)
- **Status**: [NOT STARTED]
- **Research**: [specs/192_master_tactic_dispatch/reports/01_master-dispatch-seed.md]
- **Task Type**: lean4
- **Dependencies**: 181, 185, 187, 190, 191, 194

**Description**: Create a unified `tm_prove` tactic that dispatches to the right sub-tactic based on goal type and formula structure. If goal is `Derivable G p` (Prop): use aesop with TMDerivable rule set, or `decide_prop` for propositional fragment. If goal is `DerivationTree G p` (Type): use `modal_search` with full search strategies. Implement formula analysis at the meta level to classify goals as propositional/modal/temporal/bimodal and route accordingly. Implement the transfer principle: prove `Derivable` via Prop reasoning, then extract `DerivationTree` via `Classical.choice` when needed. This is the integration point for all tactics work.

---

### 191. Propositional fragment decision procedure
- **Effort**: large (25-35 hours)
- **Status**: [NOT STARTED]
- **Research**: [specs/191_propositional_decision_procedure/reports/01_decision-procedure-seed.md]
- **Task Type**: lean4
- **Dependencies**: 181

**Description**: Implement a verified decision procedure for the propositional fragment of TM logic. The propositional axioms (prop_k, prop_s, ex_falso, peirce) are complete for classical propositional logic. Create a `Decidable` instance for `Derivable [] p` when `p` is purely propositional (no modal/temporal operators). Two implementation approaches: (a) truth-table evaluation via BoolEval — evaluate `p` under all atom assignments, if all true then derivable; (b) analytic tableaux — more efficient for large formulas. The `decide` tactic could then close propositional derivability goals automatically. This is publishable: a verified decision procedure for classical propositional logic inside a modal logic framework.

---

### 190. Derived operator normalization tactic (modal_norm)
- **Effort**: medium (10-12 hours)
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Research**:
  - [specs/190_derived_operator_normalization/reports/01_normalization-seed.md]
  - [specs/190_derived_operator_normalization/reports/02_modal-norm-research.md]

**Description**: Create a `modal_norm` tactic that unfolds all derived operators to primitive form before proof search. The Formula type has 15+ derived operators (diamond, always, sometimes, some_past, some_future, neg, and, or, iff, top, etc.) that expand to combinations of 6 primitives (bot, imp, box, all_future, all_past, untl/snce, atom). AesopRules.lean already defines `@[aesop norm unfold]` for some operators. The tactic should: (1) unfold all derived operators to primitive form, (2) optionally canonicalize negation to `imp ... bot`, (3) support selective normalization (e.g., only unfold modal operators). This significantly reduces the branching factor for proof search since search only needs to handle primitive connectives.

---

### 189. Deduction theorem tactic
- **Effort**: medium (10-12 hours)
- **Status**: [NOT STARTED]
- **Research**: [specs/189_deduction_theorem_tactic/reports/01_deduction-theorem-seed.md]
- **Task Type**: lean4
- **Dependencies**: none (uses existing Core/DeductionTheorem.lean)

**Description**: Wrap the deduction theorem (DeductionTheorem.lean) as a tactic. Create `deduction` tactic: given goal `G ⊢ p → q`, creates subgoal `G, p ⊢ q` (moving antecedent to context). Create `undischarge` tactic for the reverse direction. This gives a natural-deduction feel to Hilbert-style proofs, dramatically simplifying many derivations that currently require explicit imp_trans and b_combinator chains. The deduction theorem proof uses well-founded recursion on tree height (noncomputable), which affects tactic design — the tactic must mark results noncomputable. Currently 20+ files use deduction_theorem directly; the tactic would simplify those call sites.

---

### 188. Weakening-aware proof search
- **Effort**: medium (10-12 hours)
- **Status**: [NOT STARTED]
- **Research**: [specs/188_weakening_aware_search/reports/01_weakening-aware-seed.md]
- **Task Type**: lean4
- **Dependencies**: 187

**Description**: Extend proof search to automatically apply weakening when a lemma proves from a smaller context. Currently modal_search never applies `DerivationTree.weakening` — if a registered lemma proves `G ⊢ p` but the goal is `D ⊢ p` with `G ⊆ D`, the search fails. Implement context subsumption checking: when a lemma match is found with context `G`, verify `G ≤ D` (list subset) and automatically insert weakening. This removes the most common manual step in existing proofs. 50+ direct weakening calls and 186 `List.nil_subset` uses in the codebase would be eliminated. Integrates with the lemma database (task 187).

---

### 187. Backward-chaining lemma database (solve_by_elim analogue)
- **Effort**: large (20-25 hours)
- **Status**: [NOT STARTED]
- **Research**: [specs/187_backward_chaining_lemma_db/reports/01_lemma-database-seed.md]
- **Task Type**: lean4
- **Dependencies**: 185

**Description**: Build a TM-logic-specific analogue of Mathlib's `solve_by_elim`. Create a `@[tm_lemma]` attribute that registers `DerivationTree`-valued theorems for backward chaining. All theorems in Combinators.lean (~30), Propositional.lean (~15), ModalS5.lean, TemporalDerived.lean, Perpetuity.lean, and GeneralizedNecessitation.lean are candidates. The tactic: for goal `G ⊢ p`, find any registered lemma whose conclusion unifies with the goal, then recursively solve premises. Use heuristic ordering (axioms first, assumptions second, derived theorems by complexity). This is the core infrastructure that tasks 188 and 192 build upon.

---

### 186. Unify computable and tactic proof search systems
- **Effort**: medium (12-15 hours)
- **Status**: [NOT STARTED]
- **Research**: [specs/186_unify_search_systems/reports/01_unify-search-seed.md]
- **Task Type**: lean4
- **Dependencies**: 185

**Description**: Unify the two parallel proof search implementations: `modal_search` (TacticM, builds terms via `mkAppM`) and `bounded_search`/`bounded_search_with_proof` (computable, returns `Option (DerivationTree G p)`). The computable search is incomplete — `bounded_search_with_proof` has no modal K or temporal K (lines 951-955 say "would go here"). `SearchConfig` weights exist but `searchProof` ignores them (line 1028). Complete `bounded_search_with_proof` with modal K and temporal K. Make `SearchConfig` weights functional. Optionally have `modal_search` call the computable search as fallback for goals the TacticM search can't handle.

---

### 185. Complete axiom & derived theorem coverage in modal_search
- **Effort**: small (6-8 hours)
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Research**:
  - [specs/185_complete_axiom_derived_coverage/reports/01_axiom-coverage-seed.md]
  - [specs/185_complete_axiom_derived_coverage/reports/02_axiom-coverage-research.md]

**Description**: Extend `tryAxiomMatch` in Tactics.lean to cover all axiom schemata (currently 12 of ~16: missing prior_UZ, prior_SZ, serial_future, serial_past, and incomplete connect_future coverage). Add a `tryDerivedMatch` function that registers derived theorems from Combinators.lean (imp_trans, identity, b_combinator, theorem_flip, dni, double_negation) and Propositional.lean (ecq, raa, efq, lce, rce, ldi, rdi, rcp) as additional apply targets in `modal_search`. Add tests for each new pattern. This is the foundational step that all subsequent tactics tasks build upon.

---

### 183. Documentation standards: directory READMEs, module docstrings, comment conventions
- **Effort**: large (15-25 hours)
- **Status**: [COMPLETED]
- **Research**:
  - [specs/183_documentation_standards_readmes_comments/reports/01_documentation-audit.md]
  - [183_documentation_standards_readmes_comments/reports/02_plan-revision-delta.md]
- **Task Type**: lean4
- **Dependencies**: 161
- **Plan**:
  - [183_documentation_standards_readmes_comments/plans/01_documentation-standards.md]
  - [183_documentation_standards_readmes_comments/plans/02_documentation-standards.md]
- **Summary**: [183_documentation_standards_readmes_comments/summaries/02_documentation-standards-summary.md]

**Description**: Establish and apply a comprehensive documentation standard for the entire `Theories/Bimodal/` tree, then systematically update every README and docstring in the repository to be accurate and complete. This task defines the standard AND applies it after structural refactoring (tasks 131, 175) is complete. Four deliverables:

**A) Directory README standard + systematic update**: Every directory under `Theories/Bimodal/` must have a `README.md` with: (1) one-paragraph purpose statement, (2) module inventory table (file | lines | status | description), (3) cross-links to related directories (dependencies and dependents), (4) key definitions/theorems exported. Currently missing READMEs: `FrameConditions/`, `Metalogic/BXCanonical/`, `Metalogic/WeakCanonical/`, `latex/build/`. Existing READMEs vary wildly in style — normalize all to the template. **Critically**: every existing README must be audited for accuracy — many contain stale file counts, reference deleted modules, describe superseded architectures, or list wrong sorry counts. The update must be systematic: script-assisted where possible (e.g., auto-generating module inventory tables from `find` + `wc -l`, cross-checking listed files against actual directory contents) to ensure no README is left stale. The top-level `Theories/Bimodal/README.md`, `Metalogic/README.md`, and all subdirectory READMEs must reflect the post-refactoring state with accurate file inventories, dependency descriptions, and status information.

**B) Module docstring standard**: Every `.lean` file must have a `/-! ... -/` module docstring as its first non-import block containing: (1) one-line summary, (2) 2-3 sentence description of purpose and role, (3) key definitions/theorems listed, (4) cross-references to related modules. Currently 152 active files with inconsistent or missing docstrings. Audit all and bring to standard.

**C) Comment convention standard**: Define and enforce: (1) No multi-line removal/archived/tombstone comments in active code (those go in git history). (2) `-- NOTE:` for non-obvious invariants or constraints. (3) `-- FIX:` for known issues requiring attention. (4) No `#check` in library code (only in Examples/). (5) No commented-out code blocks. (6) Docstrings on all public `theorem`/`def`/`structure` declarations that form the module's API. Write the standard as a reference document at `Theories/Bimodal/docs/reference/documentation-standard.md` and then apply it across the codebase.

**D) Root-level documentation**: Update the project `README.md` at repository root and `Theories/Bimodal/README.md` to accurately reflect final architecture, sorry status, axiom inventory, directory structure, and build instructions. Ensure cross-links between all READMEs form a navigable web — every README should link to its parent, its children, and its key lateral dependencies so a reader can traverse the project structure from any entry point.

---

### 180. Add copyright headers, universe polymorphism, and 100-char line limits
- **Effort**: medium (6-10 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Add Mathlib-compatible copyright headers to all Lean files (currently missing on all ~207 files). Adopt universe polymorphism where appropriate (`Type*` instead of `Type`), particularly in Semantics/ and FrameConditions/ where structures should be universe-polymorphic. Enforce 100-character line limit throughout the codebase for Mathlib style compliance. This is a prerequisite for any future Mathlib contribution and improves code quality for the standalone library. Per task 179 research report `02_mathlib-submission.md`.

---

### 179. Research Lean 4 best practices and infrastructure for tactics and derived theorems
- **Effort**: large (20-30 hours)
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Research**:
  - [specs/179_research_lean4_tactics_infrastructure/reports/01_team-research.md]
  - [specs/179_research_lean4_tactics_infrastructure/reports/02_mathlib-submission.md]

**Description**: Research best practices for Lean 4 in 2026 online and in Mathlib to design a systematic library of tactics, derived theorems in the proof theory, semantic lemmas, and other general results that streamline codebase refactoring and raise overall code quality. In anticipation of completing task 155, cleaning up tasks 176 and 95, and beginning a deep refactor of completed theorems, investigate appropriate metaprogramming, custom tactics, derivation infrastructure, and organizational patterns to achieve the best structure throughout the implementation.

---

### 178. Publication examples and demo
- **Effort**: small (4-6 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: low
- **Dependencies**: 183, 193

**Description**: Expand `Examples/` with publication-quality demonstrations of the full verified pipeline. Add a complete worked example showing soundness-completeness-decidability on a concrete formula. Add examples exercising each frame class (Base, Dense, Discrete) with the FrameClass-parameterized `DerivationTree` from task 168. Add examples of the expressive completeness result (separation theorem). Update `BimodalProofs.lean` and `TemporalStructures.lean` to use current API conventions. All examples sorry-free.

---

### 177. Update README and all module docstrings
- **Effort**: small (3-5 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 183, 193

**Description**: Final documentation pass after all structural refactoring is complete. Update `README.md` axiom counts, architecture diagram, and sorry obligations section. Ensure every file in the final structure has an accurate `/-! ... -/` module docstring reflecting its role. Update `ROADMAP.md` to reflect completed refactoring. Verify Axiom Reference doc against actual constructors.

---

### 176. Relocate Chronicle and archive dead BXCanonical subtree
- **Effort**: medium (4-6 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 155

**Description**: Resolve architectural confusion where `Chronicle/` lives under `BXCanonical/` but is only consumed by `WeakCanonical/`. Move 6 Chronicle files (14,331 lines) to `Metalogic/Chronicle/` or `WeakCanonical/Chronicle/`. Archive entire non-Chronicle BXCanonical subtree (16 files, 4,615 lines, 19 mathematically false sorries under irreflexive semantics) to `Boneyard/BXCanonical/`. Verify `OrderedSeedConsistency.lean` dependency from `WeakCanonical/ReflexiveCanonical.lean` before archiving. Update aggregator imports. Subsumes part of task 130 scope (the BXCanonical dead-code sorries).

---

### 175. Naming convention and bridge/wrapper cleanup
- **Effort**: medium (6-10 hours)
- **Status**: [RESEARCHED]
- **Research**: [specs/175_naming_convention_and_bridge_cleanup/reports/01_team-research.md]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 168, 174

**Description**: Normalize naming conventions to follow Mathlib-style descriptive conventions and eliminate bridge/wrapper indirection for publication quality. Adopt Mathlib naming patterns: `bot_of_and_neg` instead of `ecq`, `and_left` instead of `lce`, `and_right` instead of `rce`, `or_inl` instead of `ldi`, `or_inr` instead of `rdi`, `absurd` instead of `raa`, `False.elim` instead of `efq`, `not_not_intro` instead of `dni`, etc. Expand opaque abbreviations (`bfmcs`, `drm`, `cud`, `sdc`, `dd_`, `tc_`, `fuc_`, `buc_`). Inline or remove `Bridge.lean` wrappers (993 lines, 16 forwarding definitions). Eliminate trivial primed variants. Normalize `z1_valid` to `axiom_z1_valid` for consistency. Rename `temp_` prefix to `temporal_` for clarity. Purge 81 removed/archived/superseded tombstone comments. Reference Mathlib naming conventions guide and task 179 research report `specs/179_research_lean4_tactics_infrastructure/reports/02_mathlib-submission.md` for the full mapping.

---

### 170. Establish completeness theorem for TM^dc (dense + complete extension)
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: 169

**Description**: Prove proof-theoretic completeness for TM^dc, the dense + complete extension of the base TM logic. TM^dc extends TM with the density axiom DN (Fφ → FFφ) and the completeness axiom CO (G(Pφ → FPφ) → (Pφ → Fφ)). The standard model is ℝ (the reals as a conditionally complete densely ordered abelian group). This requires constructing a canonical model for TM^dc and proving a truth lemma showing that every TM^dc-consistent formula is satisfiable in a task model over a conditionally complete dense linear order. The existing dense completeness proof (BXCanonical chronicle construction) produces models over quotient types that are dense but not necessarily complete; this task must either extend that construction to produce complete models, or develop a new completeness argument. This is a research-level formalization — the paper "The Construction of Possible Worlds" (Brast-McKie 2025) proves the CO correspondence theorem but does not establish TM^dc completeness. Literature: Burgess 1982/84, Xu 1988, Reynolds 1994 for the base completeness pipeline; the CO correspondence proof in the paper's Appendix provides the semantic characterization.

---

### 169. Add Complete frame extension with axiom, typeclass, and soundness
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: 168

**Description**: Add the Complete frame class as an extension of Dense to the TM logic formalization, following the paper "The Construction of Possible Worlds" (Brast-McKie 2025). The Complete frame condition (Dedekind completeness) requires every nonempty bounded-above subset of the temporal domain to have a least upper bound. Key changes: (1) Add FrameClass.Complete to the FrameClass enum with Dense ≤ Complete in the partial order (from task 168). (2) Add the CO axiom constructor to Axiom: G(Pφ → FPφ) → (Pφ → Fφ), mapped to minFrameClass = .Complete. (3) Add CompleteTemporalFrame typeclass extending DenseTemporalFrame with ConditionallyCompleteLinearOrder from Mathlib. (4) Add ℝ instance for CompleteTemporalFrame. (5) Prove CO soundness on complete frames (paper Appendix, ~50 lines, uses sInf on the set of counterexamples). (6) Prove CO correspondence: CO is valid over a frame iff the frame is Complete (paper Theorem at line 2453, both directions). (7) Prove CO is valid on Archimedean discrete frames (paper footnote: since every Archimedean discrete ordered group is conditionally complete, CO holds vacuously). (8) Update soundness wrappers in FrameConditions/Soundness.lean. (9) Update README to document the Complete extension and the full frame class hierarchy: Base ≤ Dense ≤ Complete, Base ≤ Discrete.

---

### 165. Establish semantic finite model property for TM bimodal logic
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Establish the semantic finite model property for TM bimodal logic. The existing FMP in `Decidability/FMP/` is purely proof-theoretic: it shows closure MCS structures are finite and that provability is decidable via MCS enumeration, but it does not construct finite semantic models (task frames with world histories). A standard semantic FMP requires: (1) Starting from a (possibly infinite) canonical model where φ fails, quotient worlds by agreement on the subformula closure of φ. (2) Prove the filtration lemma: truth of all subformulas is preserved in the quotient. The existing `TruthPreservation.lean` handles bot, imp, and box, but temporal operators are absent — the G/H cases were archived (they assumed the T-axiom, invalid under strict semantics) and Until/Since cases were never attempted. Until/Since are known to be problematic for naive filtration since they quantify over intermediate points; selective filtration or alternative constructions may be needed (see Blackburn/de Rijke/Venema Ch 2.3, Reynolds 2003). (3) Prove the quotient model is a valid task frame (nullity, compositionality, reflection preserved under filtration). (4) Bound the model size by `2^|cl(φ)|`. The result should be stated as: if φ is satisfiable in a task model, then φ is satisfiable in a finite task model of bounded size. This is needed for each frame class (serial, dense, discrete) to establish decidability.

### 164. Prove tableau correctness theorem for decision procedure
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Prove tableau correctness theorem connecting decision procedure output to semantic validity. The current `validity_decidable` theorem in `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` is trivially `Classical.em (⊨ φ)` — it says nothing about the tableau. The `decide` function in `DecisionProcedure.lean` implements a real tableau (proof search + branch expansion + countermodel extraction), but there is no theorem linking its output to semantic validity. Needed: (1) `decide_sound`: if `decide φ = .valid proof` then `⊨ φ` (may follow from soundness + the proof term). (2) `decide_complete`: if `decide φ = .invalid counter` then `¬(⊨ φ)` (requires proving countermodel extraction produces a genuine semantic countermodel). (3) `decide_terminates`: the procedure terminates for sufficient fuel (relates to FMP size bound). Without these, "sorry-free (tableau)" in the README is misleading — the implementation exists but its correctness is unverified.

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

---

### 155. Activate Reynolds pipeline for sorry-free discrete completeness
- **Effort**: 18-30 hours
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: 154
- **Research**:
  - [specs/155_reynolds_pipeline_activation/reports/01_team-research.md]
  - [specs/155_reynolds_pipeline_activation/reports/02_team-research.md]
  - [specs/155_reynolds_pipeline_activation/reports/03_post-157-status.md]
  - [specs/155_reynolds_pipeline_activation/reports/03_team-research.md]
  - [specs/155_reynolds_pipeline_activation/reports/07_ghr93-strategy-review.md]
  - [specs/155_reynolds_pipeline_activation/reports/35_phase1-blocker-prior-art.md]
  - [specs/155_reynolds_pipeline_activation/reports/39_game-depth-restructuring.md]
  - [specs/155_reynolds_pipeline_activation/reports/40_ghr93-case-ii-step6.md]
  - [specs/155_reynolds_pipeline_activation/reports/41_stavi-completeness-audit.md]
- **Plan**:
  - [specs/155_reynolds_pipeline_activation/plans/43_definitive-ghr93-plan.md]

**Description**: Replace the chronicle fallback in Transfer.lean with the full Reynolds Theorem 15 pipeline, eliminating `succ_cofinal` from `bx_completeness`. Plan v43 (definitive GHR93-faithful): delta=4 throughout, independent X_t construction (not via nf_characterizable_by_stavi), general linear orders with Cases III/IV using left(B,D)/right(B,D) gap formulas, interval type formula A = X_{(a_{n-1}, a_n)}. Bridge lemma deferred to separate task (NOT on bx_completeness critical path). 6 phases: (1) Theorem6 rank-varying IH, (2) X_t characteristic formula machinery, (3) Case II rewrite with U(B,A), (4) Cases III/IV gap handling, (5) Downstream sorry closure, (6) Verification. Definition of done: `bx_completeness` has no `sorryAx`, `lake build` passes.

---

### 131. Refactor module organization for clean APIs and documentation
- **Effort**: 15-25 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Restructure Theories/Bimodal/ file hierarchy for clean APIs and documentation. Currently 130 live .lean files across 7 top-level directories, with the Metalogic/ directory being a catch-all containing 7 subdirectories (Algebraic, Bundle, BXCanonical, ConservativeExtension, Core, Decidability, Relational) plus loose files (Soundness.lean, SoundnessLemmas.lean, DenseSoundness.lean, DiscreteSoundness.lean, Completeness.lean, Metalogic.lean). Goals: (1) Reorganize Metalogic/ into a clearer hierarchy — group soundness files into Metalogic/Soundness/, completeness files into Metalogic/Completeness/, clarify relationship between BXCanonical (chronicle approach) and Algebraic (parametric approach). (2) Add module-level documentation (docstrings on namespace declarations, module descriptions at file tops). (3) Establish clean APIs with explicit exports via root .lean files for each subdirectory. (4) Evaluate whether FrameConditions/ should be merged into Metalogic/ or remain separate. (5) Audit Boneyard/ organization (45 files across 10+ subdirectories). (6) Consider whether docs/ and latex/ and typst/ should remain under Theories/Bimodal/ or move to project root.

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

## Recommended Order

