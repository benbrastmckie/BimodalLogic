---
next_project_number: 248
repository_health:
  overall_score: 95
  production_readiness: near-publication
  last_assessed: 2026-06-01T00:00:00Z
task_counts:
  active: 53
  completed: 162
  in_progress: 1
  not_started: 41
  abandoned: 0
  total: 215
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

*Updated 2026-06-01. 53 active tasks.*

**Goal**: Sorry-free `bx_completeness` → structural refactor → tactics library → tactic-powered codebase refinement → documentation → publication-quality codebase.

### Phase 1 — Discrete Completeness (independent, Option C path)

202 [PLANNED] — Reynolds model surgery (v17): Definitive 11-piece, 6-phase plan synthesizing 17+ failed cycles. Closes 2 sorry sites (gap_prior_UZ/SZ_contradiction) + 1 wiring change (no_gaps_discrete). ~700 LOC, 16 hours.
  - **Reports**:
    - [specs/202_reynolds_k_equivalence_bypass/reports/17_deep-research-synthesis.md]
    - [specs/202_reynolds_k_equivalence_bypass/reports/16_team-research.md]
  - **Plans**:
    - [specs/202_reynolds_k_equivalence_bypass/plans/18_reynolds-model-surgery-v17.md]

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
  └─ 165, 239, 240
125 [NOT STARTED] — Jónsson-Tarski representation theorem for TM logic

### Tableau Training System (tasks 232-247)

**Goal**: Rebuild the broken tableau decision procedure into a correct, complete system for TM bimodal logic, then use it to generate large-scale training data for the BimodalHarness neural proof search pipeline.

#### Phase T1 — Tableau Foundation (independent of other phases)

232 [NOT STARTED] — Labeled branch infrastructure: world/time-indexed SignedFormula and Branch types
233 [NOT STARTED] — S5 modal tableau rules with multi-world bookkeeping
  └─ 232
234 [NOT STARTED] — Temporal G/H/F/P tableau rules with time-indexed branches
  └─ 232
235 [NOT STARTED] — Until/Since tableau rules with open-guard decomposition
  └─ 232
236 [NOT STARTED] — Modal-temporal interaction tableau rules
  └─ 233, 234

#### Phase T2 — Tableau Completion

237 [NOT STARTED] — Tableau termination via blocking and FMP bounds
  └─ 233, 234, 235
238 [NOT STARTED] — Frame-class-aware tableau expansion (Dense/Discrete gating)
  └─ 233, 234, 235
239 [NOT STARTED] — Proof term extraction from closed tableaux (DerivationTree construction)
  └─ 237, 238
240 [NOT STARTED] — Countermodel extraction with semantic correctness (real branchTruthLemma)
  └─ 237, 238

#### Phase T3 — Data Generation

241 [NOT STARTED] — Tableau-driven formula labeling for DatasetGenerator
  └─ 237, 238
242 [NOT STARTED] — Tableau-derived proof step extraction (100K+ steps)
  └─ 239, 241
243 [NOT STARTED] — Full axiom/rule coverage (42/42 axioms, 7/7 rules)
  └─ 242
244 [NOT STARTED] — Context-based proof steps for assumption/weakening training
  └─ 242

#### Phase T4 — BimodalHarness Integration

245 [NOT STARTED] — Cross-repository data sync pipeline (BimodalLogic → BimodalHarness)
  └─ 241
246 [NOT STARTED] — Lean REPL tableau bridge for live queries
  └─ 241
247 [NOT STARTED] — End-to-end training loop validation
  └─ 242, 245, 246

### Dataset Enhancements (from competitive landscape analysis, task 215)

228 [COMPLETED] — Fix dataset metadata and documentation staleness
229 [NOT STARTED] — Resolve train/benchmark formula contamination (71.2% overlap)
230 [NOT STARTED] — Benchmark refresh: splits, paraphrases, schema alignment
  └─ 229
231 [NOT STARTED] — Dataset regeneration automation (supersedes 227)
  └─ 228, 230
217 [IMPLEMENTING] — Complexity tier extension to c9/c11 (Lean oracle)
221 [COMPLETED] — Proof step dataset expansion (36 → 310 theorems, 10063 steps)
219 [RESEARCHED] — LLM baseline difficulty calibration

### Meta/Tooling

162 [NOT STARTED] — Enforce strict plan compliance for formal implementation agents


## Tasks

### 247. End-to-end training loop validation
- **Effort**: medium (6-10 hours)
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Priority**: medium
- **Topic**: tableau-training
- **Dependencies**: 242, 245, 246

**Description**: Validate the complete pipeline: Lean tableau → data export → BimodalHarness ingestion → training → evaluation. Generate a small dataset (1000 labeled formulas, 5000 proof steps) using the corrected tableau, sync to BimodalHarness, run supervised training on proof steps, run a single epoch of expert iteration, evaluate on benchmark, verify action predictions align with the 49-action space. Document schema mismatches and training failures. Create `scripts/smoke-test-training.sh` in BimodalHarness.

---

### 246. Lean REPL tableau bridge for live queries
- **Effort**: medium (8-12 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Topic**: tableau-training
- **Dependencies**: 241

**Description**: Enhance Lean to support live tableau queries from BimodalHarness's `lean/bridge.py`. Add `#tableau_decide` (structured JSON output), `#tableau_steps` (proof step JSONL extraction), `#countermodel` (semantic countermodel JSON) commands. Enable BFS/MCTS online training queries. Target <500ms per formula round-trip. Files: `Automation/`, BimodalHarness `lean/bridge.py`.

---

### 245. Cross-repository data sync pipeline
- **Effort**: medium (6-10 hours)
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Priority**: high
- **Topic**: tableau-training
- **Dependencies**: 241

**Description**: Build automated BimodalLogic → BimodalHarness data sync. Implement `scripts/export-training-data.sh` (runs generators, validates output, writes `data/VERSION`), enhance `make sync-data` (schema validation, 49-action-space check, ingestion validation), add `make verify-data` target, document sync protocol. Files: BimodalLogic `scripts/`, BimodalHarness `Makefile`, `data/bimodal/`.

---

### 244. Context-based proof steps for assumption/weakening training
- **Effort**: small (4-6 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Topic**: tableau-training
- **Dependencies**: 242

**Description**: Create library of theorems with non-empty contexts to exercise `assumption` and `weakening` rules (currently 0% of 10063 steps). Create conditional derivations, modus ponens in context, modal/temporal reasoning in context. Register 50+ contextual theorems in new `Theorems/Contextual.lean` with G/H wrapping variants. Target: assumption ≥5%, weakening ≥3% of steps.

---

### 243. Full axiom and rule coverage in proof step dataset
- **Effort**: medium (8-12 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Topic**: tableau-training
- **Dependencies**: 242

**Description**: Achieve 42/42 axiom names and 7/7 inference rules in proof step dataset (currently 31/42 and 5/7). For each missing axiom, construct a formula whose shortest proof requires it and generate via tableau. Add coverage tracking report and `data/coverage_report.json`. Files: `ProofStepExport.lean`, `FormulaEnumerator.lean`, `DataExport.lean`.

---

### 242. Tableau-derived proof step extraction
- **Effort**: medium (10-15 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: tableau-training
- **Dependencies**: 239, 241

**Description**: Extend proof step pipeline to generate `ProofStepRecord` JSONL from tableau-proved formulas (not just 310 hand-registered theorems). Enumerate formulas, decide via correct tableau, extract `DerivationTree`, run `extractStepSequence`, export as JSONL. Add deduplication and diversity metrics. Target: 100K+ proof steps with balanced rule distribution. Files: `ProofStepExport.lean`, `DatasetGenerator.lean`, `FormulaEnumerator.lean`.

---

### 241. Tableau-driven formula labeling for DatasetGenerator
- **Effort**: medium (8-12 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: tableau-training
- **Dependencies**: 237, 238

**Description**: Rebuild `DatasetGenerator.lean` to use corrected tableau for reliable formula labeling. Currently uses broken tableau producing incorrect labels for modal/temporal formulas. Update `LabeledFormula` records with richer proof traces and countermodels. Validate against all 42 axiom instances and known satisfiable non-theorems. Files: `DatasetGenerator.lean`, `DataExport.lean`, `EnrichedCountermodel.lean`, `DecisionProcedure.lean`.

---

### 240. Countermodel extraction with semantic correctness
- **Effort**: large (15-20 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: tableau-training
- **Dependencies**: 237, 238

**Description**: Replace vacuous `branchTruthLemma` (`∀ sf ∈ b, True`) with genuine truth lemma: T(φ) ∈ b implies φ true in extracted model, F(φ) ∈ b implies φ false. Extend `SimpleCountermodel` to `SemanticCountermodel` with world states, time domain, temporal ordering, valuation. Prove truth lemma by induction on formula structure using saturation. Files: `CountermodelExtraction.lean`, `Closure.lean`, potentially new `SemanticCountermodel.lean`.

---

### 239. Proof term extraction from closed tableaux
- **Effort**: large (15-25 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: tableau-training
- **Dependencies**: 237, 238

**Description**: Replace stub proof extraction (`"Full proof extraction not yet implemented"`) with complete backward-chaining algorithm building `DerivationTree` from closed branches. Augment expansion with proof reconstruction stack. Map closure reasons through expansion steps to axiom/rule combinations: propositional (peirce + modus_ponens), modal (necessitation + modal_k_dist), temporal (temporal_necessitation + BX axioms). Files: `ProofExtraction.lean`, `Tableau.lean`, `Saturation.lean`.

---

### 238. Frame-class-aware tableau expansion
- **Effort**: medium (6-10 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: tableau-training
- **Dependencies**: 233, 234, 235

**Description**: Add Dense and Discrete frame-class-specific rules. Dense: density rule, dense indicator (`¬U(⊤,⊥)`). Discrete: Prior rules, Z1, uniformity axioms. Parameterize `buildTableau`/`decide` by `FrameClass`, gate rules by `minFrameClass ≤ fc`. Files: `Tableau.lean`, `DecisionProcedure.lean`, `Saturation.lean`.

---

### 237. Tableau termination via blocking and FMP bounds
- **Effort**: medium (10-15 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: tableau-training
- **Dependencies**: 233, 234, 235

**Description**: Implement blocking strategy ensuring termination. Subset/equality blocking on time points and worlds. Relate fuel to FMP-derived size bound `f(2^|cl(φ)|)`. Replace ad-hoc `recommendedFuel` heuristic with sound bound. Prove blocking preserves completeness. Files: `Saturation.lean`, `DecisionProcedure.lean`, `FMP/`.

---

### 236. Modal-temporal interaction tableau rules
- **Effort**: small (4-6 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: tableau-training
- **Dependencies**: 233, 234

**Description**: Cross-modal-temporal rules based on `modal_future` axiom (`□φ → □(Gφ)`). Propagate `T(□φ)` to `T(Gφ)`, inherit temporal structure in new worlds and modal structure at new times. Test against `modal_future`, `temp_future`, and combined □/G/H/U/S formulas. Files: `Tableau.lean`, `Saturation.lean`.

---

### 235. Until/Since tableau rules with open-guard decomposition
- **Effort**: large (15-25 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: critical
- **Topic**: tableau-training
- **Dependencies**: 232

**Description**: Implement rules for primitive `untl` and `snce` — zero rules currently exist for these two constructors. `T(U(φ,ψ)) @ t` branches: event witness `T(φ) @ t_next` or guard+continue `T(ψ) @ t_next, T(U(φ,ψ)) @ t_next`. Open-guard convention (strict inequality). Eventuality tracking for loop detection. Symmetric for Since. Test against all 22 BX axioms. Files: `Tableau.lean`, `SignedFormula.lean`, `Saturation.lean`.

---

### 234. Temporal G/H/F/P tableau rules with time-indexed branches
- **Effort**: medium (10-15 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: critical
- **Topic**: tableau-training
- **Dependencies**: 232

**Description**: Replace unsound identity-collapse temporal rules with correct time-indexed rules. Strict-inequality semantics: `T(GA) @ t → T(A) @ t'` for all `t' > t`, `F(GA) @ t → F(A) @ t_new` with fresh `t_new > t`. Track time ordering constraints. Auto-propagate G/H-formulas to new time points. Wire unused `asSomeFuture?`/`asSomePast?` helpers into new rules. Files: `Tableau.lean`, `Saturation.lean`.

---

### 233. S5 modal tableau rules with multi-world bookkeeping
- **Effort**: medium (8-12 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: critical
- **Topic**: tableau-training
- **Dependencies**: 232

**Description**: Replace unsound identity-collapse modal rules with correct S5 rules. `T(□A) @ w → T(A) @ w'` for all worlds (propagation), `F(□A) @ w → F(A) @ w_new` (witness), `T(◇A) @ w → T(A) @ w_new` (witness), `F(◇A) @ w → F(A) @ w'` for all worlds (refutation). Track global □-formula propagation set. Replace `boxPos`/`boxNeg`/`diamondPos`/`diamondNeg` at `Tableau.lean` lines 84-99. Files: `Tableau.lean`, `Saturation.lean`.

---

### 232. Labeled branch infrastructure for world/time-indexed tableau
- **Effort**: medium (8-12 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: critical
- **Topic**: tableau-training
- **Dependencies**: none

**Description**: Replace flat `SignedFormula` (`{ sign, formula }` at `SignedFormula.lean:101-106`) and `Branch` (`List SignedFormula` at line 176) with world/time-indexed types. Extend `SignedFormula` with `worldIdx : Nat` and `timeIdx : Int`. Extend `Branch` with known worlds, known time points with ordering constraints, and propagation queues. Migrate 8 propositional rules (operate within same world+time). Update `Closure.lean` contradiction detection (match within same world+time). Update `Saturation.lean` expansion. Preserve sorry-free compilation. Files: `SignedFormula.lean`, `Tableau.lean`, `Closure.lean`, `Saturation.lean`, `DecisionProcedure.lean`, `ProofExtraction.lean`, `CountermodelExtraction.lean`, `Correctness.lean`.

---

### 231. Dataset regeneration automation
- **Effort**: large (2-3 days)
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: 228, 230

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

---

### 229. Resolve train/benchmark formula contamination
- **Effort**: medium (4-6 hours)
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Priority**: high
- **Topic**: dataset-enhancement

**Description**: 71.2% of benchmark formulas (553/777) appear verbatim in `bmlogic-c7.jsonl` training data, undermining the benchmark as held-out evaluation. All overlap is at complexity 3-7 (the c7 range); the 224 non-overlapping records are complexity >= 8 or axiom instances. Resolution options: (A) Regenerate benchmark excluding c7 formulas — truly held-out but smaller. (B) Keep overlap but add `contamination_flag` field and document that only 224 records are truly held-out. (C) Remove overlapping formulas from c7 — clean separation but holes in exhaustive enumeration. Implement chosen approach, update downstream artifacts, document analysis in dataset card.

---

### 228. Fix dataset metadata and documentation staleness
- **Effort**: small (2-3 hours)
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Priority**: high
- **Topic**: dataset-enhancement
- **Research**: [specs/228_fix_dataset_metadata_staleness/reports/01_metadata-staleness-audit.md]
- **Plan**: [specs/228_fix_dataset_metadata_staleness/plans/01_fix-metadata-staleness.md]

**Description**: Fix all stale metadata and documentation across `data/`. (1) Update `proof_steps_metadata.json`: `total_records` 2424→10063, `theorem_count` 36→310, `rule_distribution` to actual values (axiom:4635, modus_ponens:4325, temporal_necessitation:991, temporal_duality:63, necessitation:49), `step_statistics` (avg 32.5, max 327, min 1). (2) Standardize `bmlogic-bench_metadata.json`: rename `total_count` key to `total_records` for consistency with other metadata files. (3) Update `data/README.md`: fix record counts (proof_steps 2424→10063, theorems 36→310, benchmark 727→777), update training schema table from "14 fields" to "16 fields" documenting `max_modal_depth` and `max_temporal_depth`. (4) Update `data/dataset-card.md`: overview table counts, proof steps statistics. (5) Resolve license inconsistency: dataset-card.md YAML says `mit` but croissant.json says `CC BY 4.0`.

---

### 227. Dataset pipeline automation + Croissant sync infrastructure
- **Effort**: medium (1-2 days)
- **Status**: [PLANNED]
- **Task Type**: general
- **Research**: [specs/227_dataset_pipeline_automation_croissant_sync/reports/01_dataset-pipeline-research.md]
- **Plan**: [227_dataset_pipeline_automation_croissant_sync/plans/01_dataset-pipeline-plan.md]

**Description**: Build end-to-end automation so that every benchmark data regeneration (anchor expansion, new training data, eval runs) automatically updates all downstream artifacts. (1) Fix immediate croissant.json staleness: recompute SHA-256 hashes, update contentSize for all 5 distributions, regenerate or remove bmlogic-bench-splits.json, verify field counts match actual JSONL schemas. (2) Create a deterministic pipeline script (e.g., scripts/sync-dataset-artifacts.sh) that, given freshly regenerated data, automatically recomputes SHA-256 hashes and contentSize in croissant.json, updates record counts in metadata JSON, regenerates splits if applicable, validates croissant.json structure, updates data/README.md statistics, and commits with a structured message. (3) Update the lean-implementation-agent and general-implementation-agent definitions/context so that any task involving benchmark regeneration includes a post-implementation step that runs the sync script. Add this to agent context or plan templates so future /implement and /orchestrate runs automatically keep artifacts in sync. (4) Document the pipeline in data/README.md with a clear narrative: what each artifact is, how they relate, which script keeps them in sync, and what git history tracks. The goal is zero manual intervention — when an agent regenerates benchmark data, everything downstream updates atomically, and documentation tells the story of the dataset's evolution.



### 224. Investigate finite insertion argument for succ_cofinal (omega-chain structural alternative to Reynolds model surgery)
- **Effort**: medium (4-8 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Investigate whether the finite insertion argument can prove IsSuccArchimedean for the chronicle limit domain, as an alternative to Reynolds model surgery (Lemmas 6-13). The conjecture: between any two points at stage N of the omega-chain, the limit domain has only finitely many additional points. Key observations: (1) each eliminate step adds at most 1 point, (2) each counterexample is processed exactly once via Nat.unpair encoding, (3) the formula closure is FINITE (subformulas of A₀), (4) each interval can generate at most O(2^|formulas|) witnesses across all stages. If true, finite insertions imply the successor chain from any point reaches any other in finitely many steps, giving IsSuccArchimedean directly without model surgery. Related: task 202.

---

### 221. Proof step dataset expansion (36 → 200+ theorems)
- **Effort**: large (2-3 weeks)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: low
- **Topic**: dataset-enhancement
- **Research**: [221_proof_step_dataset_expansion/reports/01_proof-step-research.md]
- **Plan**: [221_proof_step_dataset_expansion/plans/01_proof-step-plan.md]
- **Summary**: [221_proof_step_dataset_expansion/summaries/01_proof-step-summary.md]

**Description**: Expand proof_steps.jsonl from 36 to 200+ theorems with better temporal rule coverage. Current rule distribution biased toward axiom application (50%) and modus_ponens (49%). Target: temporal rules (necessitation, temporal_duality, temporal_necessitation) represent at least 10% of steps. Record format backward-compatible with current 8-field schema. Uses the proof_extractor executable. Requires identifying and proving additional theorems that exercise temporal rules.


---

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

### 217. Complexity tier extension to c9/c11
- **Effort**: large (2-4 weeks, Lean oracle compute)
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Research**: [217_complexity_tier_extension_c9_c11/reports/01_complexity-tier-research.md]
- **Plan**: [217_complexity_tier_extension_c9_c11/plans/01_complexity-tier-plan.md]

**Description**: Extend exhaustive formula enumeration to complexity 9 and 11. bmlogic-c9.jsonl: exhaustive (if feasible) or stratified-sampled coverage of complexity ≤9, estimated 300K-800K records. bmlogic-c11.jsonl: stratified-sampled coverage of complexity ≤11, estimated 500K-2M records. 14-field schema compatible with c5/c7. Add very_hard+ benchmark slice with 100+ records at complexity 8-9. Add max_temporal_depth and max_modal_depth as first-class filter fields. Risk: intractable file sizes at c9 mitigated by stratified sampling.

---

### 202. Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Effort**: 14 hours
- **Status**: [PLANNED]
- **Type**: lean4
- **Priority**: CRITICAL
- **Dependencies**: none
- **Research**:
  - [202_reynolds_k_equivalence_bypass/reports/01_reynolds-bypass-research.md]
  - [202_reynolds_k_equivalence_bypass/reports/04_team-research.md]
  - [202_reynolds_k_equivalence_bypass/reports/05_reynolds-theorem-14-research.md]
  - [202_reynolds_k_equivalence_bypass/reports/07_bfmcs-bypass-research.md]
  - [202_reynolds_k_equivalence_bypass/reports/08_succ-cofinal-dependency-trace.md]
  - [202_reynolds_k_equivalence_bypass/reports/12_deviation-analysis.md]
- **Handoff**: [202_reynolds_k_equivalence_bypass/handoffs/phase-2-blocked-20260529.md]
- **Plans**:
  - [202_reynolds_k_equivalence_bypass/plans/10_chronicle-level-plan.md]
  - [202_reynolds_k_equivalence_bypass/plans/11_reynolds-model-surgery-plan.md]
- **Description**: Plan v12 (Reynolds model surgery). Phase 1 complete (Theorem 5 + infrastructure). Plan v12 formalizes Reynolds Lemmas 6-13 + Theorem 14 (model surgery / no-gaps) in new ReynoldsModelSurgery.lean (~600 lines) at the ChronicleAsPriorModel level. Phase 2: gap formula R (Lemma 6), R-interval structure (Lemma 7), class homogeneity (Lemmas 8-9), bad intervals (Lemma 10), formula propagation (Lemma 11), model surgery N = Q- u I u Q+ (Lemma 12), contradiction (Lemma 13), main theorem (Theorem 14). Phase 3: close chronicle_gap_contradiction sorry + verify completeness_discrete sorry-free.


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


### 190. Derived operator normalization tactic (modal_norm)
- **Effort**: medium (10-12 hours)
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Research**:
  - [specs/190_derived_operator_normalization/reports/01_normalization-seed.md]
  - [specs/190_derived_operator_normalization/reports/02_modal-norm-research.md]

**Description**: Create a `modal_norm` tactic that unfolds all derived operators to primitive form before proof search. The Formula type has 15+ derived operators (diamond, always, sometimes, some_past, some_future, neg, and, or, iff, top, etc.) that expand to combinations of 6 primitives (bot, imp, box, all_future, all_past, untl/snce, atom). AesopRules.lean already defines `@[aesop norm unfold]` for some operators. The tactic should: (1) unfold all derived operators to primitive form, (2) optionally canonicalize negation to `imp ... bot`, (3) support selective normalization (e.g., only unfold modal operators). This significantly reduces the branching factor for proof search since search only needs to handle primitive connectives.


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


### 185. Complete axiom & derived theorem coverage in modal_search
- **Effort**: small (6-8 hours)
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Research**:
  - [specs/185_complete_axiom_derived_coverage/reports/01_axiom-coverage-seed.md]
  - [specs/185_complete_axiom_derived_coverage/reports/02_axiom-coverage-research.md]

**Description**: Extend `tryAxiomMatch` in Tactics.lean to cover all axiom schemata (currently 12 of ~16: missing prior_UZ, prior_SZ, serial_future, serial_past, and incomplete connect_future coverage). Add a `tryDerivedMatch` function that registers derived theorems from Combinators.lean (imp_trans, identity, b_combinator, theorem_flip, dni, double_negation) and Propositional.lean (ecq, raa, efq, lce, rce, ldi, rdi, rcp) as additional apply targets in `modal_search`. Add tests for each new pattern. This is the foundational step that all subsequent tactics tasks build upon.


---

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
- **Dependencies**: None
- **Created**: 2026-04-10

**Description**: Verification pass on `bx_completeness` sorry status. Updated scope: (1) Verify `dd_countermodel_chronicle_dense` and `dd_countermodel_chronicle_mixed_sorry` show no `sorryAx` (confirmed sorry-free as of 2026-05-15). (2) Trace the discrete case `sorryAx` chain: `dd_countermodel_chronicle_discrete` -> `succ_embed_surjective` -> `limitDomSubtype_isSuccArchimedean` -> `succ_cofinal` (root sorry). (3) Classify all Metalogic/ sorry occurrences as critical-path vs dead-code vs non-critical-path. (4) Update stale axiom audit comments in Completeness.lean (lines 177-234 reference CE:3570 which is no longer the sorry source). (5) Verify soundness and decidability remain sorry-free. (6) Produce audit report.


## Recommended Order

