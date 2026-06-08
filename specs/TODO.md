---
next_project_number: 295
repository_health:
  overall_score: 95
  production_readiness: near-publication
  last_assessed: 2026-06-02T14:31:27Z
task_counts:
  active: 43
  completed: 190
  abandoned: 2
  total: 235
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

*Updated 2026-06-03. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 125,127,128,131,161,162,165,169,170,175,179,180,186,187,188,189,191,194,199,200,219,230,255,257,268,269 | -- | completeness, formula-refactor, frame-extensions, ... |
| 2 | 155,192,196,231 | 161,187,191,194,230,268 | completeness, dataset-enhancement, automation |
| 3 | 95,176,193 | 155,189,192,196 | completeness, formula-refactor |
| 4 | 177,178,254 | 95,131,176,193 | completeness, formula-refactor |

**Grouped by Topic** (indented = depends on parent):

### Completeness

273 [PLANNED] — Prove chronicle_gap_contradiction from omega-chain construction of LimitDomSubtype (sole remaining sorry in discrete completeness chain)
268 [RESEARCHED] — Archive divergent BX code to Boneyard/ and wire Reynolds sorry-fr
  └─ 155 [IMPLEMENTING] — Eliminate all sorries from completeness_discrete by fixing 3 root
    └─ 95 [NOT STARTED] — Verification pass on sorry status for completeness_discrete and b
      └─ 254 [NOT STARTED] — Final metadata and documentation update after completeness pipeli
    └─ 176 [NOT STARTED] — Resolve architectural confusion where Chronicle/ lives under BXCa
      └─ 254 [NOT STARTED] — Final metadata and documentation update after completeness pipeli (see above)

### Formula Refactor

131 [NOT STARTED] — Restructure Theories/Bimodal/ file hierarchy for clean APIs and d
  └─ 177 [NOT STARTED] — Update all documentation to match final codebase state after refa
  └─ 178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of the f
175 [RESEARCHED] — Normalize naming conventions to follow Mathlib-style descriptive 
176 [NOT STARTED] — Resolve architectural confusion where Chronicle/ lives under BXCa
  └─ 254 [NOT STARTED] — (completeness: Final metadata and documentation update ) (see above)

### Frame Extensions

127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ is 
128 [NOT STARTED] — Add topological open set (interior) operator for dense and contin

### Algebraic Representation

125 [NOT STARTED] — Implement a Jonsson-Tarski representation theorem for TM logic: e

### Automation

199 [PARTIAL] — Create a bespoke grid_order_tac tactic (in Theories/Bimodal/Autom
196 [RESEARCHED] — Systematic survey of the entire Theories/Bimodal/ codebase to ide
  └─ 193 [NOT STARTED] — codebase_tactic_refactor
    └─ 177 [NOT STARTED] — (formula-refactor: Update all documentation to match final ) (see above)
    └─ 178 [NOT STARTED] — (formula-refactor: Expand Examples/ with publication-qualit) (see above)

### Code Quality

200 [NOT STARTED] — Rewrite ghr93_case_II in CaseAnalysis.lean for code elegance and 
255 [NOT STARTED] — Archive dead code to Boneyard/ after task 202 completed Reynolds 

### Dataset Enhancement

219 [RESEARCHED] — Run bmlogic-bench through multiple LLMs to establish baseline dif
230 [NOT STARTED] — After contamination resolution (task 229), regenerate all benchma
  └─ 231 [NOT STARTED] — Build comprehensive automation so that every dataset regeneration
284 [IMPLEMENTING] — Reduce c5 timeouts via hybrid proof-pool labeling and extended structural prefilter
285 [PLANNED] — Complete derived operator enumeration (diamond, always, sometimes, next, prev, weak_future, weak_past)
289 [PLANNED] — Add memoization/caching to tableau branch expansion (benefits from parallel batch infra)
  - **Report**: [specs/289_branch_result_memoization_caching/reports/01_memoization-research.md]
  - **Plan**: [specs/289_branch_result_memoization_caching/plans/01_memoization-plan.md]
287 [PLANNED] — Add formula normalization pass before tableau expansion
  - **Report**: [specs/287_formula_normalization_before_tableau/reports/01_normalization-research.md]
  - **Plan**: [specs/287_formula_normalization_before_tableau/plans/01_normalization-plan.md]
  └─ 288 [NOT STARTED] — Add deeper invalid-pattern recognizers to structuralPrefilter
      └─ 290 [NOT STARTED] — Improve fuel allocation heuristic for imbalanced branches

### cslib Integration (Tasks 291-294)

291 [NOT STARTED] — Upgrade Lean toolchain from v4.27 to v4.31 and update Mathlib (critical prerequisite for all porting)
  └─ 292 [NOT STARTED] — Add copyright headers (Apache 2.0) to all source files under Theories/Bimodal/
  └─ 293 [NOT STARTED] — Audit and fix Mathlib linter compliance across sorry-free modules
  └─ 294 [NOT STARTED] — Eliminate sorry in Theorems/ModalS5.lean and Theorems/Perpetuity/Principles.lean

### Uncategorized

161 [NOT STARTED] — Rename Theories/Bimodal/ to FormalSystem/. Move the entire Theori
  └─ 196 [RESEARCHED] — (automation: Systematic survey of the entire Theories) (see above)
162 [NOT STARTED] — Add a .claude/rules/ rule enforcing strict plan compliance for le
165 [NOT STARTED] — Establish the semantic finite model property for TM bimodal logic
169 [NOT STARTED] — complete_frame_extension_setup_and_soundness
170 [NOT STARTED] — complete_dense_extension_completeness
179 [RESEARCHED] — research_lean4_tactics_infrastructure
180 [NOT STARTED] — copyright_headers_universe_polymorphism_line_limits
186 [NOT STARTED] — unify_search_systems
187 [NOT STARTED] — backward_chaining_lemma_db
  └─ 192 [NOT STARTED] — master_tactic_dispatch
    └─ 193 [NOT STARTED] — codebase_tactic_refactor (see above)
188 [NOT STARTED] — weakening_aware_search
189 [NOT STARTED] — deduction_theorem_tactic
  └─ 193 [NOT STARTED] — codebase_tactic_refactor (see above)
191 [NOT STARTED] — propositional_decision_procedure
  └─ 192 [NOT STARTED] — master_tactic_dispatch (see above)
194 [NOT STARTED] — migrate_nonempty_to_derivable
  └─ 192 [NOT STARTED] — master_tactic_dispatch (see above)
257 [IMPLEMENTING] — large_data_storage_huggingface
269 [NOT STARTED] — export_interestingness_scores_to_jsonl

## Tasks

### 283. Mitigate cross-product explosion in exhaustive formula enumeration at complexity ≥ 8
- **Effort**: large (16-24 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 282
- **Research**:
  - [specs/283_enumeration_explosion_mitigation/reports/01_explosion-analysis.md]
  - [specs/283_enumeration_explosion_mitigation/reports/02_team-research.md]
- **Plan**: [283_enumeration_explosion_mitigation/plans/01_implementation-plan.md]

**Description**: The exhaustive formula enumerator in `FormulaEnumerator.lean` hits a combinatorial wall at complexity 8. The root cause is that `enumExactHelper` materializes the full cross-product of left × right subformulas for every binary operator (imp, untl, snce) at every complexity partition. At complexity 7, the worst partition (3,4) produces 132 × 960 ≈ 127K formulas — fast. At complexity 8, partition (4,4) produces 960 × 960 ≈ 922K formulas for `imp` alone, plus equivalent-sized cross-products for `untl` and `snce`, across all 7 partitions. The total materialized formulas at level 8 exceed 10M, taking 45+ minutes just to enumerate. Level 9 would be infeasible (hundreds of millions of cross-product entries). Research, design, and implement strategies to mitigate this explosion without losing coverage of interesting formulas. Approaches to investigate: (1) equivalence-class enumeration — generate one canonical representative per propositional/modal equivalence class instead of all syntactic variants; (2) lazy/streaming enumeration — avoid materializing full cross-products by filtering or sampling during generation; (3) symmetry breaking — skip commutativity-equivalent pairs (φ U ψ when ψ U φ already generated for commutative-up-to-semantics operators); (4) structural redundancy pruning — skip formulas containing syntactically simplifiable subexpressions (double negation, p → p subterms, box(box(φ)) under S5); (5) semantic deduplication — hash formulas by truth-table on small models to collapse semantically equivalent variants; (6) budget-aware cross-product — for partitions that produce >N cross-product entries, sample representative pairs instead of materializing all. Consult prior art on formula enumeration in SAT/SMT solvers, LTL benchmark generators (e.g. SPOT's randltl, LTLBench), and Lean/Mathlib enumeration patterns.

---

### 282. Make dataset generation script default to exhaustive enumeration without formula cap
- **Effort**: small (1-2 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 274

**Description**: The dataset generator defaults to `maxFormulas=5000` (in DatasetExport.lean:501 and FormulaEnumerator.lean:601), silently truncating exhaustive enumeration at higher complexity levels. Change the default behavior so that exhaustive mode keeps ALL enumerated formulas unless an explicit `--max-formulas N` flag is passed. (1) Change default `maxFormulas` in DatasetExport.lean and FormulaEnumerator.lean to 0 or a sentinel value meaning "no limit". (2) Update `FormulaEnumerator.lean:692` to skip the `.take` when maxFormulas is 0/unlimited. (3) Update `run_dataset_generation.sh` to remove `--max-formulas` from exhaustive tiers (c4-c8) since the default will now be unlimited. Keep `--max-formulas` only for stratified tiers (c9+) where it controls the sampling budget. (4) Add a `--max-formulas` flag description to the help text clarifying it's optional and only caps output for exhaustive mode. (5) Regenerate c4-c8 datasets to verify truly exhaustive output.

---

### 281. Complete countermodel_discrete_reynolds_v2 to bypass chronicle_gap_contradiction
- **Effort**: medium (6-10 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: completeness
- **Plan**: [specs/281_z_interval_countermodel_v2/plans/01_z-interval-countermodel.md]
- **Summary**: [specs/281_z_interval_countermodel_v2/summaries/01_z-interval-countermodel-summary.md]

**Description**: Complete countermodel_discrete_reynolds_v2 in ReynoldsBridge.lean to bypass chronicle_gap_contradiction. Build a BFMCS on Z directly from the Z-interval temporal_truth (derived from limitdom_is_good + truth_transfer), prove restricted temporal coherence, box uniformity, and Until/Since coherence from temporal_truth semantics, apply the restricted parametric truth lemma, and wire into completeness_discrete. This eliminates the entire sorry chain: chronicle_gap_contradiction → succ_cofinal → limitDomSubtype_isSuccArchimedean → succ_embed_surjective.

**Completion**: Multi-family Z-interval countermodel fully implemented. `countermodel_discrete_reynolds_v2` is sorry-free in `ReynoldsBridge.lean`, bypassing the chronicle_gap_contradiction → succ_cofinal → limitDomSubtype_isSuccArchimedean → succ_embed_surjective sorry chain. Wired into `completeness_discrete`.

---

### 275. Surface R/W/T/WS operators in hasBimodalInteraction and add complexity pattern-matching
- **Effort**: small (2-4 hours)
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 274
- **Research**: [specs/275_surface_rwt_ws_bimodal_interaction/reports/01_research.md]
- **Plan**: [specs/275_surface_rwt_ws_bimodal_interaction/plans/01_implementation-plan.md]
- **Summary**: [specs/275_surface_rwt_ws_bimodal_interaction/summaries/01_implementation-summary.md]

**Description**: Release (R), weak until (W), trigger (T), and weak since (WS) are already defined in Formula.lean but invisible to the dataset generator — `hasBimodalInteraction` only checks for F/P/G/H patterns. (1) Extend `hasDerivedTemporal` / `hasBimodalInteraction` in DatasetGenerator.lean to recognise R/W/T/WS structural patterns via subformula traversal. (2) Add complexity pattern-matching cases for R/W/T/WS in `Formula.complexity` (analogous to the F/P/G/H treatment from task 274), reducing their overhead from 5-8 to 1-2. (3) Update `FormulaEnumerator.lean` overhead constants to match. (4) Regenerate c5 dataset and verify ~3x increase in bimodal formula count. This is zero new axiom/proof work — purely surfacing existing operators in the automation layer.

**Completion**: Surfaced R/WU/T/WS operators in automation layer: complexity pattern-matching (4 cases), hasDerivedTemporal detection (4 patterns), enumerator sampling integration (4 functions), stale overhead fixes (4→1, 8→1), property tests (4 cases). C5 bimodal formulas increased from 2,616 to 6,072 (~2.3x). Build passes (1685 jobs).

---

### 276. Add Strong Release (M) and Strong Trigger (ST) derived operator definitions
- **Effort**: small (2-4 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 275
- **Research**: [specs/276_strong_release_trigger_operators/reports/01_research.md]
- **Plan**: [276_strong_release_trigger_operators/plans/01_implementation-plan.md]
- **Summary**: [specs/276_strong_release_trigger_operators/summaries/01_implementation-summary.md]

**Description**: Add Strong Release `M(φ,ψ) := ψ U (ψ ∧ φ)` and Strong Trigger `ST(φ,ψ) := ψ S (ψ ∧ φ)` as derived operator definitions in Formula.lean. These complete the classical operator quartets {U, W, R, M} (future) and {S, WS, T, ST} (past) used in positive normal form LTL. (1) Add `strong_release` and `strong_trigger` definitions (one line each). (2) Add complexity pattern-matching with overhead 2. (3) Add bimodal interaction schemata (~14-20 new patterns, e.g. `□φ → G(M(φ,ψ))`, interaction with always/sometimes). (4) Update `hasBimodalInteraction` to include M/ST patterns. (5) Add axiom schemata for M/ST interactions with modal operators. (6) Verify with c5 generation that new bimodal formulas appear.

---

### 277. Instrument tableau prover with rule-firing trace certificates
- **Effort**: medium (6-10 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 274
- **Research**: [specs/277_tableau_rule_firing_traces/reports/01_trace-certificates-design.md]
- **Plan**: [specs/277_tableau_rule_firing_traces/plans/01_trace-certificates-implementation.md]
- **Summary**: Instrumented Tableau.lean with rule-firing trace certificates. Added TraceCertificate.lean (5 inductive types, StateM monad), TraceExport.lean (string-based JSON), trace_exporter CLI executable, decideWithTrace API. All 4 existing termination/soundness proofs in Saturation.lean preserved via parallel _tracedImpl functions. Lake build passes (1686 jobs); 28/28 tests pass; 0 sorries; 0 new axioms.

**Description**: Instrument the tableau decision procedure in Tableau.lean to emit rule-firing traces during proof search. Each trace entry records `(rule_name, formula, world_label)` identifying which axiom schema was instantiated. (1) Add a `ProofCertificate` structure to collect trace entries during tableau expansion. (2) Thread the certificate through the proof search, recording each rule application (K, T, 4, 5, temporal Until-unfolding, Since-unfolding, G-introduction, etc.). (3) Post-process traces to compute per-proof axiom multisets (which axioms, how many times each). (4) Export axiom fingerprint and tableau branching factor to JSONL output. (5) For failed proof attempts (timeouts), preserve partial traces. This enables axiom diversity scoring, proof complexity stratification, and curriculum-based training data generation. Reference: Libal & Volpe (2016) "Certification of Prefixed Tableau Proofs for Modal Logic."

---

### 278. Expand structural prefilter with polarity analysis, 2-SAT skeleton, and temporal loop detection
- **Effort**: medium (6-10 hours)
- **Status**: [COMPLETED]
- **Completed**: 2026-06-07
- **Summary**: Implemented polarity analysis, conjunct helpers, S5 reflexive shortcutting, temporal loop detection, subsumption rules, and lightweight propositional contradiction in DatasetGenerator.lean. c7 benchmark: 44/2000 prefilter hits (2.2%), catching ~71% of valid formulas. Phase 5 (2-SAT) skipped as gap was not propositional. Build passes, no sorries, no new axioms.
- **Task Type**: lean4
- **Priority**: medium
- **Topic**: dataset-enhancement
- **Dependencies**: Task 274
- **Research**: [specs/278_structural_prefilter_expansion/reports/01_research.md]
- **Plan**: [specs/278_structural_prefilter_expansion/plans/01_structural-prefilter-expansion.md]

**Description**: Expand the structural prefilter in DatasetGenerator.lean with additional O(n) patterns to approximately double prefilter coverage from ~5% to ~10%. New patterns: (1) Polarity/sign analysis — walk the formula tracking positive/negative occurrences; a subformula appearing only positively that is a tautology can be dropped, one appearing only negatively that is a contradiction short-circuits. (2) 2-SAT propositional skeleton — strip all modal and temporal operators, compute the propositional 2-SAT skeleton; if unsatisfiable in O(n+e), the full formula is unsatisfiable. (3) S5 reflexive shortcutting — `Box phi ∧ neg phi` as top-level conjunct is immediately unsatisfiable (strict generalization of existing modal_t_weakening). (4) Temporal loop detection — `phi U psi` co-occurring with `G(neg psi)` as top-level conjuncts is unsatisfiable. (5) Subformula subsumption — ~10 modal/temporal syntactic implication rules (e.g., `Box phi` implies `phi` under T). Add axiom attribution labels for each new pattern. Run before/after comparison at c7.

---

### 279. Build backward proof-first formula generation over axiom set
- **Effort**: large (16-24 hours)
- **Status**: [COMPLETED]
- **Completed**: 2026-06-07
- **Summary**: Forward-chaining proof generation system complete with 42-schema axiom instantiation, ProofPool with shortest-wins dedup, implication-index MP closure, unary rules, bounded fixpoint loop with ex_falso cap (≤20%), GenerationMode dispatch in DatasetGenerator, JSONL exporter + CLI executable `proof_first_generator`, 8 cross-corpus benchmark metrics, 12 integration tests passing. Proof-first achieves ~769x valid-formula throughput vs exhaustive enumeration (10,000 valid/60ms vs 13 valid/806 total). Lake build passes (1687 jobs), zero sorries.
- **Task Type**: lean4
- **Priority**: medium
- **Topic**: dataset-enhancement
- **Dependencies**: Task 277
- **Report**: [279_backward_proof_generation/reports/01_proof_first_generation.md](../279_backward_proof_generation/reports/01_proof_first_generation.md)
- **Plan**: [279_backward_proof_generation/plans/01_proof_first_generation.md](../279_backward_proof_generation/plans/01_proof_first_generation.md)

**Description**: Implement a forward-chaining proof generation system that constructs derivation trees over the existing axiom schemata in ProofSystem/, then extracts the conclusion formulas as labeled training data. This bypasses exhaustive enumeration entirely — formulas are guaranteed interesting by construction because they have non-trivial proofs. (1) Write a forward-chaining combinator that starts from axiom instances and applies inference rules (modus ponens, necessitation, temporal rules) up to a configurable derivation depth N. (2) Collect `(formula, proof_tree)` pairs, where the proof tree serves as supervision signal. (3) Control complexity via derivation depth rather than formula AST size. (4) Use the rule-firing traces from task 277 to compute axiom diversity and branching metrics automatically. (5) Integrate as an alternative generation mode in DatasetGenerator.lean alongside exhaustive enumeration. (6) Compare output quality: axiom diversity, proof depth distribution, and temporal axiom usage vs. enumeration-based generation. Reference: DeepSeek-Prover-V2 subgoal decomposition pattern; SynLogic (NeurIPS 2025) parameterized generation with rule-based verifiers.

---

### 280. Add contrastive minimal-pair mutation pass for labeled corpus
- **Effort**: medium (6-10 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: medium
- **Topic**: dataset-enhancement
- **Dependencies**: Task 275, Task 276
- **Plan**: [280_contrastive_minimal_pair_generation/plans/01_implementation-plan.md]
- **Completed**: 2026-06-05
- **Summary**: Extended FormulaMutator.lean with single-occurrence mutation engine, ~15 new mutation rules (□↔◇, U↔R, F↔G, W↔M, T↔ST, implication flip, conjunct removal), pipeline integration with labelFormula, enriched JSON export with occurrence metadata, and 30+ unit tests. Lake build passes (1686 jobs). Zero sorries, zero new axioms.

**Description**: Implement a mutation pass over the existing labeled formula corpus to generate contrastive minimal pairs — (valid, invalid) formula pairs that differ by exactly one structural change. Given a valid formula φ, generate φ' by: (1) replacing one □ with ◇ (or vice versa), (2) replacing one temporal operator with another (U↔R, F↔G, etc.), (3) removing one conjunct, (4) flipping one implication direction, (5) swapping a derived operator (W↔M, T↔ST). Run the tableau prover on each φ'; if the validity label flips, emit the pair. These pairs are extremely high-signal for training models to discriminate fine-grained logical structure. (1) Define a set of ~10 mutation rules in a new `FormulaMutator.lean` module. (2) Apply mutations to the existing c5/c7 labeled corpus. (3) Re-label mutants via the tableau prover. (4) Export valid contrastive pairs to a new JSONL file with fields: `original_formula`, `mutated_formula`, `mutation_type`, `original_label`, `mutated_label`. (5) Measure contrastive pair yield rate per mutation type. Reference: LFC-DA (2025); contrast sets for NLP robustness.

---

### 274. Run dataset generation at increasing complexity to find new bottleneck after tasks 270-272
- **Effort**: medium (6-10 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 272
- **Research**: [specs/274_bimodal_bottleneck_sweep/reports/01_bottleneck-sweep.md]
- **Plan**: [specs/274_bimodal_bottleneck_sweep/plans/01_bottleneck-sweep.md]
- **Summary**: [specs/274_bimodal_bottleneck_sweep/summaries/01_bottleneck-sweep-summary.md]
- specs/274_bimodal_bottleneck_sweep/summaries/01_bottleneck-sweep-summary.md: [Implementation summary with metrics comparison]

**Description**: Tasks 270-272 delivered recursive unsatisfiability pre-filtering, active Until-negative rules for dense countermodels, and derived temporal operators (G/H/F/P) as first-class enumeration targets with 22 axiom schemata and a `hasBimodalInteraction` filter. Run `run_dataset_generation.sh` at c5, c7, and c9 to measure the combined impact: (1) what fraction of generated formulas now use derived temporal operators, (2) whether bimodal interaction formulas (containing both modal and temporal operators) actually exercise temporal axioms (modal_future, connect_future, etc.) in their proofs, (3) where the new timeout/bottleneck sits — is it still the prover, the enumerator producing uninteresting formulas, or a new pattern? Also run `generateBimodalSlice` directly at c5-c7 to test the targeted bimodal dataset path. Collect metrics on timeout rate, valid fraction, interestingness score distribution, and temporal axiom usage. Identify the next bottleneck blocking genuinely interesting bimodal proofs and propose what to fix.

---

### 270. Extend structural pre-filter with recursive unsatisfiability and consequent validity
- **Effort**: small (2-4 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 269

**Description**: Fix the structural pre-filter bug where `isUnsatBotTemporal` checks for literal `.bot` as the Until/Since event but not recursively unsatisfiable events. Currently `U(□⊥, X) → Y` times out even though `□⊥` is unsatisfiable and `isUnsatBotTemporal` already handles `.box a => recurse`. The Until/Since match needs to change from `.untl .bot _ => true` to `.untl event _ => isUnsatBotTemporal event` (and similarly for Since). Additionally, add a consequent validity check: `X → valid_formula` is always valid regardless of the antecedent, catching patterns like `X → (p → p)`. Combined, these two extensions should eliminate ~22% of current timeouts as provably valid. After fixing, regenerate c5 and c7 datasets to measure the impact on timeout rates and interestingness score distribution.

---

### 271. Add active Until-negative rule for dense countermodel construction
- **Effort**: medium (8-16 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 270

**Description**: Address the root cause of ~60% of dataset timeouts: the `untlNeg` rule in Tableau.lean only decomposes `F(U(event, guard))` at existing future time points but never creates new intermediate times. This prevents the tableau from constructing dense countermodels needed to refute formulas like `U(p, ⊥) → U(p, p)` (which requires an intermediate time where p is false). Modify the Until-negative (`untlNeg`) and Since-negative (`snceNeg`) rules to actively create fresh intermediate time points when decomposing negated temporal operators, enabling the tableau to find countermodels for formulas that require dense temporal structure. This is soundness-critical code — the modified rules must preserve the tableau soundness invariant (open saturated branches correspond to valid countermodels). After implementation, verify with `lake build`, check sorry/axiom counts, and regenerate the c7 dataset to measure the reduction in timeout rate (target: from 4.8% to under 2%). Also verify that no previously-valid or previously-invalid formula changes label (regression check).

---

### 272. Enumerate derived temporal operators to unlock bimodal proofs
- **Effort**: medium (8-12 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: medium
- **Topic**: dataset-enhancement
- **Dependencies**: Task 271
- **Research**: [specs/272_enumerate_derived_temporal_operators/reports/01_derived-temporal-ops.md]
- **Plan**: [specs/272_enumerate_derived_temporal_operators/plans/01_derived-temporal-ops.md]
- **Summary**: [specs/272_enumerate_derived_temporal_operators/summaries/01_derived-temporal-ops-summary.md]

**Description**: The interestingness analysis revealed that 0% of valid formulas at c5-c8 use temporal axioms in their proofs. This is not a bug — with the current enumeration bounds (raw Until/Since, modal depth 2, temporal depth 2), formulas requiring genuine bimodal reasoning like `G(p) → □G(p)` (which uses the `modal_future` axiom) are not expressible. Extend the formula enumerator in FormulaEnumerator.lean to include derived temporal operators (G = all_future, H = all_past, F = some_future, P = some_past) as first-class enumeration targets alongside the primitive Until/Since. These derived operators appear in the axiom schemas (F_until_equiv, P_since_equiv, modal_future) and are the natural building blocks for formulas that exercise bimodal interaction. After implementation, generate a targeted "bimodal interaction" dataset slice at c5-c7 using formulas containing both □ and G/H/F/P operators, and verify that valid formulas in this slice use temporal axioms (modal_future, connect_future, etc.) in their proofs.

---

### 269. Export interestingness scores from DatasetRecord to JSONL output
- **Effort**: small (1-2 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 267
- **Research**: [269_export_interestingness_scores_to_jsonl/reports/01_export-fix.md]
- **Plan**: [269_export_interestingness_scores_to_jsonl/plans/01_implementation-plan.md]
- **Summary**: [269_export_interestingness_scores_to_jsonl/summaries/01_export-fix-summary.md]

**Description**: Fix the dataset export pipeline where interestingness scores are computed in `LabeledFormula` (via `computeInterestingness` in DatasetGenerator.lean) but silently dropped during conversion to `DatasetRecord` in `labeledToRecord` (DatasetExport.lean:301-328). The `LabeledFormula` struct has `interestingnessScore : Option Nat` and `interestingnessTier : Option String` fields that are populated for every formula, and `LabeledFormula.toJson` serializes them correctly. However, `DatasetRecord` lacks these fields entirely, and `labeledToRecord` does not transfer them, so the final JSONL output contains no interestingness data. Fix by: (1) adding `interestingness_score : Option Nat` and `interestingness_tier : Option String` fields to the `DatasetRecord` structure, (2) mapping them in `labeledToRecord` from `lf.interestingnessScore` and `lf.interestingnessTier`, (3) serializing them in `datasetRecordToJson`. After fixing, regenerate the c5 dataset to verify scores appear in the output and validate the distribution (expect ~84% trivial for valid propositional-only proofs, ~16% with modal axiom usage scoring higher).

---

### 273. Prove chronicle_gap_contradiction from omega-chain construction of LimitDomSubtype
- **Effort**: 10 hours
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
- **Plan**: [273_chronicle_gap_contradiction_proof/plans/03_separation-bypass-plan.md]

**Description**: Bypass the GHR93 bridge lemma sorry in StaviCompleteness.lean by proving US_expressively_complete_over_prior directly via GHR94 Chapter 10 integer-time separation. The separation method is purely combinatorial: U'(A,B) and S'(A,B) simplify to bot on Prior structures, reducing {U,S,U',S'} to {U,S}. This avoids the 3 sorry sites in nf_2var_existential_transfer entirely, making completeness_discrete sorry-free. NOTE: The original target (chronicle_gap_contradiction) is bypassed by countermodel_discrete_reynolds_v2 and is not on the critical path.

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

### 267. Optimize dataset pipeline for exhaustive c9 generation and beyond
- **Effort**: large (12-20 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 266
- **Research**: [267_dataset_pipeline_c9_optimization/reports/01_team-research.md]
- **Plan**: [267_dataset_pipeline_c9_optimization/plans/01_implementation-plan.md]
- **Summary**: [267_dataset_pipeline_c9_optimization/summaries/01_implementation-summary.md]

**Description**: Overcome the combinatorial formula count bottleneck identified in task 266 to enable exhaustive dataset generation at c9 (~1.2M formulas) and stratified generation at c10+ (~6M formulas). Build on the progression of optimizations from tasks 264-266: task 264 identified the bimodal fuel distribution and timeout patterns, task 265 eliminated the c6 bottleneck via single-tier fuel and structural pre-filter (18 hours to 5.7 seconds), and task 266 added wall-clock timeout to tame c8 slow formulas (stalled at 14min to completing in 7min for 253K formulas). The remaining bottleneck is raw formula count at c9+, not per-formula cost. Investigate and implement: (1) parallel formula labeling using Lean's Task API to utilize multiple CPU cores (currently single-threaded), (2) incremental/resumable generation with checkpoint files so interrupted runs can continue from where they left off, (3) smarter enumeration that skips provably-redundant formulas (e.g., atom-permutation equivalence classes where U(p,q)→r and U(q,p)→r are structurally identical up to renaming), (4) extend the structural pre-filter with any new timeout patterns discovered at c7-c8 (task 266 found bare temporal patterns U(X,Y)→Z dominate at c7, and temporal-modal feedback loops at c8). After implementation, generate the complete c9 exhaustive dataset and a c10 stratified sample, producing an updated scaling curve through c10.

---

### 266. Scale dataset generation to c7+ to find next bottleneck
- **Effort**: medium (8-12 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 265
- **Research**: [266_scale_generation_c7_plus_bottleneck/reports/01_scaling-bottleneck.md]
- **Plan**: [266_scale_generation_c7_plus_bottleneck/plans/01_implementation-plan.md]
- **Summary**: [266_scale_generation_c7_plus_bottleneck/summaries/01_scaling-bottleneck-summary.md]

**Description**: Scale dataset generation to c7, c8, and beyond to identify the next bottleneck after the task 265 pre-filter eliminated the c6 bottleneck (18 hours to 5.7 seconds). For each complexity level: (1) run exhaustive generation, (2) record wall-clock time, formula count, timeout count/rate, and decision method distribution, (3) classify any new timeout patterns not caught by the current pre-filter, (4) identify "slow timeout" formulas (>1 second) and their structural signatures. Stop at the complexity level where exhaustive generation exceeds 1 hour or timeout patterns dominate. Produce a scaling curve and bottleneck characterization report analogous to task 264's output.

---

### 265. Simplify to single-tier fuel strategy with structural timeout pre-filter
- **Effort**: medium (8-12 hours)
- **Effort**: medium (8-12 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 264
- **Research**: [specs/265_single_tier_fuel_and_timeout_prefilter/reports/01_fuel-strategy-prefilter.md]
- **Plan**: [265_single_tier_fuel_and_timeout_prefilter/plans/01_implementation-plan.md]
- **Summary**: [265_single_tier_fuel_and_timeout_prefilter/summaries/01_implementation-summary.md]

**Description**: Simplify the adaptive fuel strategy from three tiers [500, 2000, 10000] to a single tier (fuel=500), since task 264 proved that zero formulas across all complexity levels (c3-c8) resolve at tier 2 or tier 3 — every formula either resolves at tier 1 or times out at all tiers. Additionally, add a structural pre-filter that detects known timeout patterns before invoking the decision procedure: double-box (□□X → Y), Until-bot (U(⊥,X) → Y), and Since-bot (S(⊥,X) → Y). These three patterns account for all 39 c5 timeouts and dominate at higher complexities. Pre-filtered formulas should be labeled as valid (all are provably valid) with a dedicated decision method tag (e.g., `structural_prefilter`) and zero fuel cost. This eliminates the 400+ second per-formula timeout detection cost that makes exhaustive generation impractical at c6+, potentially reducing c6 generation time from ~20 hours to under 1 hour. After implementation, regenerate the c6 dataset to validate the speedup.

---

### 264. Scale dataset generation to find timeout bottleneck
- **Effort**: medium (8-12 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 263
- specs/264_scale_dataset_timeout_bottleneck/reports/01_scaling-bottleneck.md: [Research report on scaling bottleneck]
- specs/264_scale_dataset_timeout_bottleneck/plans/01_scaling-bottleneck.md: [Implementation plan for scaling bottleneck]
- specs/264_scale_dataset_timeout_bottleneck/summaries/01_scaling-bottleneck-summary.md: [Bottleneck characterization report]

**Description**: Systematically scale dataset generation beyond c5 (c6, c7, c8, ...) to identify the complexity threshold where timeout rates become unacceptable. At c5 the timeout rate is 2.6% (39/1512, all from double-box and Until/Since-bot patterns). Generate progressively larger datasets, measuring timeout rate, mean/median/p95 decision time, and memory usage at each complexity level. Identify which formula families hit the fuel cap first, whether the bottleneck is in the tableau saturation, eventuality checking, or countermodel extraction, and at what complexity the current adaptive fuel strategy breaks down. Produce a scaling curve (complexity vs timeout rate) and characterize the dominant timeout patterns at each level to guide future decision procedure improvements.

---

### 263. Smoke-test c5 dataset generation
- **Effort**: small (1-2 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 261
- specs/263_smoke_test_c5_dataset_generation/reports/01_smoke-test-c5.md: [Research report on c5 smoke testing]
- specs/263_smoke_test_c5_dataset_generation/plans/01_smoke-test-c5.md: [Implementation plan for c5 smoke test]
- specs/263_smoke_test_c5_dataset_generation/summaries/01_smoke-test-c5-summary.md: [Implementation summary]

**Description**: Smoke-test dataset generation at c5: label a small batch of formulas at complexity 5 end-to-end using the updated decision procedure to verify that fuel bounding (task 261), per-record flush, and eventuality-aware blocking work correctly. Run the generation script or equivalent #eval test on Base frame class, confirm no stalling, confirm JSONL output is well-formed with all fields populated (no null metrics), and verify that previously-problematic formulas like (□⊥ → □r) now resolve correctly instead of timing out.

---

### 262. Interestingness metrics for theorems and derivations
- **Effort**: large (12-20 hours)
- **Status**: [COMPLETED]
- **Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Research**:
  - [262_interestingness_metrics_for_theorems/reports/01_interestingness-metrics.md]
  - [262_interestingness_metrics_for_theorems/reports/02_deep-interestingness-survey.md]
- **Plan**: [262_interestingness_metrics_for_theorems/plans/02_interestingness-implementation.md]
- **Summary**: [specs/262_interestingness_metrics_for_theorems/summaries/02_interestingness-implementation-summary.md]
- **Description**: Implemented three-tier interestingness scoring (syntactic metrics + proof-structural metrics + composite with SNT gate) in InterestingnessMetrics.lean. Integrated into LabeledFormula and JSONL export pipeline. 41-test validation suite. Zero sorries, zero axioms, full build passes.

### 261. Research dataset quality issues: stalling, timeout mislabeling, null metrics
- **Effort**: medium (8-12 hours)
- **Status**: [COMPLETED]
- **Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 253
- **Research**:
  - [specs/261_dataset_quality_and_stall_diagnosis/reports/01_dataset-quality-stall.md]
  - [261_dataset_quality_and_stall_diagnosis/reports/02_tableau-termination-literature.md]
- **Plan**:
  - [specs/261_dataset_quality_and_stall_diagnosis/plans/01_dataset-quality-stall.md]
  - [261_dataset_quality_and_stall_diagnosis/plans/03_dataset-quality-fix.md]
- **Summary**: [specs/261_dataset_quality_and_stall_diagnosis/summaries/03_dataset-quality-fix-summary.md]
- **Description**: Research and improve the quality of dataset generation records, diagnose why generation stalls, and fix the decision procedure to handle all cases without getting stuck. The c9 generation run produced only 5,671 of ~1.6M enumerated formulas before stalling indefinitely on a single formula. Issues found: (1) 11.4% of labeled formulas hit timeout, including provably valid formulas like `(□⊥ → □r)` at complexity 5 — these should not timeout. (2) Some metrics fields are null for valid/timeout records, suggesting code path inconsistencies. (3) The process got stuck consuming 100% CPU with no output for 2+ hours, likely on a single formula with no per-formula time bound or watchdog. (4) Only complexity 3-6 was reached before stalling; complexity 7-9 never started. (5) Only Base frame class was processed; Dense and Discrete never ran. Research should identify which formulas cause stalling and why, determine if the tableau has algorithmic gaps vs. needing longer timeouts, and propose fixes that preserve ALL cases — slow formulas should be recorded with their timing rather than silently skipped. Also investigate null metrics fields and the timeout-vs-valid mislabeling issue.

**Completion**: Implemented global fuel counter for branch splits (O(fuel) bound), per-record flush with slow-formula warnings, eventuality-aware blocking predicate, and --frame-class CLI flag. All 5 phases complete, lake build passes (1682 jobs, 0 errors).

### 257. Investigate large data storage alternatives to Git LFS using Hugging Face
- **Effort**: M
- **Status**: [IMPLEMENTING]
- **Type**: general
- **Priority**: medium
- **Research**: [257_large_data_storage_huggingface/reports/01_large-data-storage.md]
- **Plan**: [257_large_data_storage_huggingface/plans/01_implementation-plan.md]
- **Summary**: [257_large_data_storage_huggingface/summaries/01_execution-summary.md]
- **Description**: Investigate standard practices for storing large data objects outside git (currently using Git LFS with ~146 MB uploads). Research using Hugging Face Datasets as external data host and linking from this repository. Evaluate trade-offs between Git LFS, Hugging Face Hub, and other approaches for dataset versioning and distribution.

### 255. Boneyard dead Reynolds code
- **Effort**: S
- **Status**: [NOT STARTED]
- **Type**: lean4
- **Priority**: low
- **Description**: Archive dead code to Boneyard/: ReynoldsModelSurgery.lean (unprovable sorry), ReynoldsNoGaps.lean (deprecated), Transfer.lean countermodel_discrete (BX pipeline dead code). Remove stale imports.

### 254. Final metadata and documentation update after completeness pipeline stabilization
- **Effort**: S
- **Status**: [NOT STARTED]
- **Type**: meta
- **Priority**: medium
- **Dependencies**: Tasks 95, 176
- **Description**: Final metadata and documentation update after completeness pipeline stabilization: (1) TODO.md sorry_count_note — comprehensive audit of sorry landscape post-tasks 202/155; (2) ROADMAP.md — annotate all completeness milestones achieved; (3) Transfer.lean and Completeness.lean — update stale axiom audit comments and sorry status documentation; (4) Verify #print axioms completeness_discrete shows no sorryAx. Follows tasks 95 (verification audit) and 176 (Chronicle relocation) to capture the final state.

### 250. Add enriched formula JSON export to data pipeline
- **Effort**: M (5 hours)
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Dependencies**: Task 248
- **Research**: [specs/250_enriched_formula_json_export/reports/01_enriched-formula-export.md]
- **Plan**: [specs/250_enriched_formula_json_export/plans/01_enriched-formula-export.md]

**Description**: The data export pipeline (DatasetGenerator.lean, proof step extraction) currently exports formulas only in primitive representation (6 constructor tags: atom, bot, imp, box, untl, snce). BimodalHarness needs enriched representations alongside primitives for training. Add a formula_folded_json field to exported data records that contains the formula with defined operator tags (neg, top, next, prev, and, or, diamond, some_future, some_past, all_future, all_past) using the fold algorithm from Task 248. Update proof_steps.jsonl export to include both goal_json (primitive) and goal_folded_json (enriched). Update formula enumeration exports (bmlogic-c5.jsonl, bmlogic-c7.jsonl, etc.) to include both representations. The enriched representation enables BimodalHarness to train on defined-operator formulas while verifying via primitive expansion.

---

### 249. Expand temporal derived theorem library for training coverage
- **Effort**: L
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: The temporal derived theorem coverage is thin — after Task 173 archived 27 definitions, only ~8 useful temporal derived rules remain in Theorems/. This creates unbalanced action space coverage for BimodalHarness training (propositional and modal rules dominate). Prove additional temporal derived theorems focusing on patterns that commonly appear in proofs: temporal distribution variants (distributing G/H over various connectives), temporal induction principles, Until/Since decomposition lemmas, future-past interaction theorems, and temporal analogues of propositional rules (temporal contraposition, temporal case analysis). Target: at least 15-20 new temporal derived theorems with empty contexts suitable for BimodalHarness Tier 1 action space integration. Each theorem should follow the existing Theorems/ style (DerivationTree construction). Prioritize theorems that provide high proof compression — patterns that replace 5+ primitive steps with a single derived rule application.

---

### 248. Add fold direction to formula normalization
- **Effort**: S (2 hours)
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Research**: [specs/248_fold_direction_formula_normalization/reports/01_fold-direction-normalization.md]
- **Plan**: [specs/248_fold_direction_formula_normalization/plans/01_fold-direction-normalization.md]

**Description**: Task 190 (modal_norm) covers the unfold direction (defined operators -> primitives) but not the fold direction (primitives -> defined operators). The fold direction is needed for training data export -- BimodalHarness needs formulas in enriched representation alongside primitive representation. The fold algorithm is already fully implemented in Normalization.lean (EnrichedFormula ADT, two-pass greedy fold, serialization). Remaining work is purely integration: add `formula_folded_json`, `formula_folded_str`, `formula_folded_sexpr` fields to DatasetRecord and `goal_folded_json` to ProofStep, wiring them to existing `Formula.toEnrichedJson` etc. functions.

---

### 247. End-to-end training loop validation
- **Effort**: medium (6-10 hours)
- **Status**: [COMPLETED]
- **Task Type**: general
- **Priority**: medium
- **Topic**: tableau-training
- **Dependencies**: 242, 245, 246
- **Research**: [specs/247_training_loop_validation/reports/01_training-loop-validation.md]
- **Plan**: [specs/247_training_loop_validation/plans/01_training-loop-validation.md]
- **Summary**: [specs/247_training_loop_validation/summaries/01_training-loop-validation-summary.md]

**Description**: Validated complete pipeline: Lean tableau → BimodalHarness ingestion → supervised training → expert iteration → benchmark evaluation. All 5 phases completed. Created `scripts/smoke-test-training.sh` in BimodalHarness (8/8 steps PASS in 18.8s). Key finding: action space is 82 (not 49 as documented). No context field incompatibility. Expert iteration BFS finds 16/20 proofs; eval solve rate 100%.

---

### 244. Context-based proof steps for assumption/weakening training
- **Effort**: small (4-6 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: medium
- **Topic**: tableau-training
- **Dependencies**: 242
- **Research**: [specs/244_context_proof_steps/reports/01_context-proof-steps.md]
- **Plan**: [specs/244_context_proof_steps/plans/01_context-proof-steps.md]
- **Summary**: [specs/244_context_proof_steps/summaries/01_context-proof-steps-summary.md]

**Description**: Created `Theorems/ContextualProofs.lean` with 66 computable contextual derivations and registered 107 entries in `ProofStepExport.lean`. Achieved 7/7 rule coverage: 118 assumption steps (1.0%) + 115 weakening steps (1.0%) in 11,861 total steps across 463 theorems.

---

### 243. Full axiom and rule coverage in proof step dataset
- **Effort**: medium (5 hours)
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Priority**: medium
- **Topic**: tableau-training
- **Dependencies**: 242
- **Research**: [specs/243_full_axiom_rule_coverage/reports/01_axiom-rule-coverage.md]
- **Plan**: [specs/243_full_axiom_rule_coverage/plans/01_axiom-rule-coverage.md]

**Description**: Achieve 42/42 axiom names and 7/7 inference rules in proof step dataset (currently 31/42 and 5/7). For each missing axiom, construct a formula whose shortest proof requires it and generate via tableau. Add coverage tracking report and `data/coverage_report.json`. Files: `ProofStepExport.lean`, `FormulaEnumerator.lean`, `DataExport.lean`.

---

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

---

### 229. Resolve train/benchmark formula contamination
- **Effort**: medium (4-6 hours)
- **Status**: [COMPLETED]
- **Task Type**: general
- **Priority**: high
- **Topic**: dataset-enhancement
- **Research**: [229_resolve_train_bench_contamination/reports/01_train-bench-contamination.md]
- **Plan**: [229_resolve_train_bench_contamination/plans/01_contamination-resolution.md]
- **Summary**: [229_resolve_train_bench_contamination/summaries/01_contamination-resolution-summary.md]

**Description**: 71.2% of benchmark formulas (553/777) appear verbatim in `bmlogic-c7.jsonl` training data, undermining the benchmark as held-out evaluation. All overlap is at complexity 3-7 (the c7 range); the 224 non-overlapping records are complexity >= 8 or axiom instances. Resolution options: (A) Regenerate benchmark excluding c7 formulas — truly held-out but smaller. (B) Keep overlap but add `contamination_flag` field and document that only 224 records are truly held-out. (C) Remove overlapping formulas from c7 — clean separation but holes in exhaustive enumeration. Implement chosen approach, update downstream artifacts, document analysis in dataset card.

**Completion**: Added `contamination_flag` boolean field to all 777 benchmark records (553=true, 224=false), fixed stale splits total_records (727->777), updated croissant.json schema, added Contamination Analysis section to dataset card and HF README, updated validation script.

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


### 284. Reduce c5 timeouts via hybrid proof-pool labeling and extended structural prefilter
- **Effort**: medium (6-10 hours)
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Tasks 265, 274, 277, 278, 279
- **Research**: [specs/284_timeout_reduction_c5_hybrid_prefilter/reports/01_timeout_analysis_and_strategy.md]

**Description**: Post-task-278 c5 regeneration produced 1,156 timeouts (19.2%) out of 6,031 formulas. The dominant timeout class is `U(atom, X) -> U(Y, Z)` and `S(atom, X) -> S(Y, Z)` — formulas that are not trivially unsatisfiable but still stall the tableau prover. This task implements a three-phase strategy to reduce timeouts without skipping formulas:

- **Phase 1**: Enable proof-pool hybrid labeling. Pre-generate a theorem database via `proof_first_generator` (task 279), load it into `DatasetExport.lean`, and use `.hybrid` mode so valid formulas resolve via pool lookup (~0ms) before the tableau is invoked. Expected to catch a meaningful subset of valid timeout formulas.
- **Phase 2**: Extend the structural prefilter (task 278) with new pattern classes for nested temporal-modal implications. Requires formal analysis of whether `U(atom, X) -> U(Y, Z)` admits a structural decidability rule. If provably valid/invalid, add O(n) syntactic checks to `structuralPrefilterWithAxiom`.
- **Phase 3**: Add memoization/caching to the tableau prover's `expandBranchWithFuel` (root-cause fix). Cache branch expansion results keyed by `(SignedFormula, FrameClass, Fuel)` to eliminate redundant sub-branch construction for nested temporal operators. Benefits all complexity levels.

After each phase, regenerate c5 and measure timeout count, decision time distribution, and prefilter coverage. Target: reduce c5 timeout rate from 19% to <10% while maintaining zero false positives.


### 285. Complete derived operator enumeration (diamond, always, sometimes, next, prev, weak_future, weak_past)
- **Effort**: medium (3 hours)
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Priority**: medium
- **Topic**: dataset-enhancement
- **Dependencies**: Tasks 274, 275, 276, 278
- **Research**: [specs/285_complete_derived_operator_enumeration/reports/01_gap_analysis.md]
- **Plan**: [specs/285_complete_derived_operator_enumeration/plans/01_derived-operator-plan.md]

**Description**: The formula enumerator currently generates 14 operators as first-class targets (imp, bot, box, untl, snce, F, P, G, H, R, WU, T, WS, M, ST) but omits 7 semantically significant derived operators defined in `Formula.lean`:

- **Modal**: `diamond` (◇φ = ¬□¬φ) — dual of box; fundamental in S5
- **Temporal universal**: `always` (△φ = Hφ ∧ φ ∧ Gφ) — primary universal temporal quantifier from JPL paper
- **Temporal existential**: `sometimes` (▽φ = ¬△¬φ) — dual of always; primary existential quantifier
- **Discrete-time**: `next` (○φ = U(φ, ⊥)), `prev` (●φ = S(φ, ⊥))
- **Reflexive variants**: `weak_future` (G'φ = φ ∧ Gφ), `weak_past` (H'φ = φ ∧ Hφ)

These operators are never generated in their "native" derived form, which means the dataset lacks explicit coverage of formulas like △p, ◇q, or ○r. The JPL paper's axiomatization uses △ extensively, and S5 completeness requires ◇ interaction.

**Implementation plan**:
- **Phase 1** (high priority): Add `diamond`, `always`, `sometimes` to `enumExactHelper` with pattern-aware complexity = 1. These have the highest semantic value and increase branching factor from 5 → 8 unary choices (1.6×).
- **Phase 2** (medium priority): Add `next`, `prev` as unary operators with pattern-aware complexity = 1. Discrete-time operators with constrained semantics.
- **Phase 3** (low priority): Add `weak_future`, `weak_past`. Reflexive variants of G/H; lower semantic novelty.
- Update `InterestingnessMetrics.lean` to recognize the new operators in interaction detection.
- Verify c4 formula counts before/after to measure branching impact.
- Use `--max-formulas` or stratified mode for c6+ to prevent the formula count explosion observed in task 285's predecessor tasks.

**Risk**: Adding all 7 operators at once would increase c6 formula count from ~161K to potentially 400K+, making exhaustive generation impractical. Mitigation: phased rollout with pattern-aware complexity and explicit formula caps.

---

### 286. Parallelize batch formula labeling in DatasetGenerator.lean
- **Effort**: small (4-6 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: None (self-contained; task 289 builds on this)
- **Research needed**: Yes — investigate Lean 4 Task API patterns for CPU-bound parallelism.
- **Plan**: [specs/286_parallelize_batch_formula_labeling/plans/01_parallel-batch-labeling.md]
- **Summary**: [specs/286_parallelize_batch_formula_labeling/summaries/01_execution-summary.md]

**Description**: The current `labelBatch` (DatasetGenerator.lean:1070) processes formulas sequentially. Each `labelFormulaImpl` call already spawns `decideAutoAdaptive` on a dedicated `Task` thread for timeout enforcement, but the batch itself runs formulas one-at-a-time. With ~40K formulas at c6 and 25% hitting the 1000ms wall-clock timeout, sequential execution leaves most CPU cores idle.

**Implementation**:
1. Replace sequential `for` loop in `labelBatch` with a worker-pool or chunk-based parallel approach. Process formulas in chunks of `N` (e.g., chunk size = `max 1 (numCores * 4)`), spawn `labelFormula` for each formula in the chunk concurrently, collect results, and append to output.
2. Preserve deterministic output ordering: either (a) assign monotonic indices before spawning and sort results after collection, or (b) use an `IO.Ref`-based ordered accumulator.
3. Add `--parallel N` CLI flag to `dataset_generator` (default `N = 0` meaning auto-detect via `Task.getAvailableCores` or a fallback).
4. Ensure progress reporting still works: maintain an atomic counter for "formulas completed so far" and print every 1000 formulas.
5. Handle `Task` exceptions gracefully: if a formula triggers an unexpected error (e.g., OOM), catch it and label as `.timeout` so the batch continues.

**Expected impact**: On an 8-core machine, c6 labeling time drops from ~600s to ~80-120s (6-7× throughput improvement). Timeout rate stays the same (structural), but wall-clock batch time is dominated by valid/invalid formulas which parallelize well.

**Risk**: Memory pressure from concurrent tableau expansion. Mitigation: limit chunk size and add `--parallel` flag so users can tune.

**Completion**: Implemented 6-phase parallel labeling: chunk-based `IO.asTask` parallelism in `labelBatch` with deterministic ordering and exception handling. Updated downstream callers (DatasetExporter, FormulaMutator, EnumBenchmark, DatasetValidator) with `--parallel N` CLI flags. Build passes (1687 jobs, zero errors, zero new sorries). Benchmark: 5.17x at 8 threads, 7.87x at 16 threads.

---

### 287. Add formula normalization pass before tableau expansion in DecisionProcedure.lean
- **Effort**: medium (6-10 hours)
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: None (uses existing Normalization.lean; task 288 depends on this)
- **Report**: [specs/287_formula_normalization_before_tableau/reports/01_normalization-research.md]

**Description**: The tableau in `DecisionProcedure.decide` operates on formulas in their raw enumerated form, which may contain derived operators (`and`, `or`, `diamond`, `always`, `sometimes`, `next`, `prev`, `weak_future`, `weak_past`). The `Normalization.lean` module already has definitional unfold lemmas (`and_unfold`, `or_unfold`, `diamond_unfold`, `all_future_unfold`, etc., lines 213–229) and an `EnrichedFormula` IR, but `decide` does **not** normalize before calling `buildTableau`.

Normalizing to the 6 primitives (`atom`, `bot`, `imp`, `box`, `untl`, `snce`) would:
1. Shrink the AST depth (e.g., `A ∧ B` becomes `(A → (B → ⊥)) → ⊥` — 1 extra `imp`/`bot` but removes the pattern-matching overhead of `asAnd?`).
2. Reduce rule-match branching: the tableau currently tries `asAnd?`, `asOr?`, `asDiamond?`, `asAllFuture?` on every formula. Primitive-only formulas skip all derived-pattern matchers.
3. Improve structural prefilter coverage: prefilter already operates on primitive shapes; normalization makes more formulas match.

**Implementation**:
1. Add `normalizeFormula : Formula → Formula` in `Normalization.lean` (or `Automation/` helper) that recursively unfolds all derived operators using the existing unfold lemmas. Prove it terminates (follows from complexity decrease).
2. Add `normalizeSignedFormula : SignedFormula → SignedFormula` that applies `normalizeFormula` to the inner `Formula`.
3. Wire into `decide` (DecisionProcedure.lean:121): call `normalizeFormula` on `φ` before the fast-path checks and tableau expansion. The proof search fast-paths (`tryAxiomProof`, `buildCompositionalProof`, `bounded_search_with_proof`) should also receive the normalized formula.
4. **Critical**: Ensure the returned `DerivationTree` is a proof of the *original* `φ`, not the normalized one. Two approaches:
   - (A) Normalize only for the tableau path, then extract proof from tableau → this already produces a proof of the original `φ` (proof extraction works on tableau trace).
   - (B) Normalize for all paths, then post-compose with a `DerivationTree` of `normalize(φ) → φ` (requires proving each unfold is a theorem, which they already are via `neg_unfold`, `and_unfold`, etc.).
   Prefer (A) for minimal proof-term impact.
5. Benchmark: run c5/c6 labeling before/after normalization and measure:
   - Average decision time per formula
   - Timeout rate change
   - Structural prefilter hit rate change
   - Build time impact (does normalization add compile-time cost?)

**Expected impact**: Modest but consistent improvement. Formulas with multiple derived operators (e.g., `◇(p ∧ △q)`) see the biggest gains. Timeout rate may drop 2-5% due to simpler tableau shapes.

**Risk**: Normalization can increase formula size (e.g., `A ∧ B` → double-negation-style expansion). If the size increase dominates the rule-match savings, performance could regress. Benchmark first on a 1K-formula sample.

---

### 288. Add deeper invalid-pattern recognizers to structuralPrefilter
- **Effort**: medium (6-10 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: high
- **Topic**: dataset-enhancement
- **Dependencies**: Task 287 (normalization simplifies formulas to primitive shapes, making invalid-pattern detection easier)

**Description**: The c6 run showed 25% timeout rate. The slow formulas (warn-logged at >1000ms) share structural patterns:
- `((S(□⊥, U(□⊥, (⊥ → ⊥))) → ⊥) → ...)` — nested temporal with modal unsatisfiable guard
- `(S(□p, (⊥ → ⊥)) → U(q, (⊥ → ⊥)))` — Since-to-Until implication with box in guard
- `(U(((□p → q) → ⊥), (p → ⊥)) → ⊥)` — deeply nested implications with modal subformulas

These are almost certainly **invalid** (countermodel exists) but the tableau exhausts fuel before finding it. The current `structuralPrefilter` only recognizes *valid* patterns. Adding *invalid* pattern recognizers would short-circuit the tableau entirely.

**Implementation**:
1. Add `invalidPrefilter : Formula → Option Bool` (returns `some false` if structurally invalid, `none` if undetermined). Build on existing helpers:
   - `isUnsatBotTemporal` already detects unsatisfiable antecedents. Extend it to detect *satisfiable* consequents that force validity → already done. For invalidity, detect *satisfiable* antecedent + *unsatisfiable* consequent.
   - Add `isTemporalContradiction : Formula → Bool`: checks for formulas of the form `U(□⊥, X)` ("until false with any guard") — this is unsatisfiable because `□⊥` is false at all worlds, so the event can never be witnessed. Similarly for `S(□⊥, X)`.
   - Add `isObviousSatisfiable : Formula → Bool`: a formula that is clearly not valid because it admits a simple 1-world 1-time model. E.g., `□p → q` where `p ≠ q` is satisfiable (set `p=true`, `q=false` in the reflexive world).
   - Add `hasUnfulfillableEventuality : Formula → Bool`: `U(φ, ψ)` where `φ` is a literal/atom that contradicts a box formula in the branch context. Requires branch context, so this may belong in the tableau closure detector (`Closure.lean`) rather than the prefilter.
2. Add `Formula.isStructurallyInvalid` that composes the above checks with O(n) traversal.
3. Wire into `labelFormulaImpl` (line 807): *before* the valid-prefilter, check invalid-prefilter. If `some false`, return `.invalid` immediately with `decisionMethod = "structural_invalid_prefilter"`.
4. **Soundness requirement**: Every invalid-pattern recognizer must be formally justified. For each pattern added, write a small proof in `DatasetGenerator.lean` or a new `PrefilterSoundness.lean` module showing the pattern is indeed invalid in the base frame class. Start with 3-5 high-confidence patterns.
5. Benchmark: run c6 labeling, compare timeout rate and prefilter coverage before/after. Target: reduce timeout rate by 3-8% by catching structurally invalid formulas.

**Expected impact**: The biggest win for timeout reduction without changing the tableau engine. Invalid formulas that currently stall would resolve in O(n) structural inspection.

**Risk**: False negatives (labeling a formula invalid when it's actually valid) would corrupt the dataset. Mitigation: only add patterns with formal soundness proofs; gate behind a `--strict-prefilter` flag if uncertain.

---

### 289. Add branch-result memoization/caching to expandBranchWithFuel
- **Effort**: large (12-16 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Topic**: dataset-enhancement
- **Dependencies**: Task 286 (parallel batch infrastructure provides the shared-memory context where a global LRU cache is most effective)

**Description**: Many timeout formulas contain repeated subformulas across branches. For example, `((S(□⊥, U(□⊥, (⊥ → ⊥))) → ⊥) → ...)` re-evaluates `S(□⊥, U(□⊥, (⊥ → ⊥)))` and its negation in multiple branches. The tableau currently recomputes `expandBranchWithFuel` from scratch for every branch, even when the remaining subproblem is identical to one already explored.

**Implementation**:
1. Add a memoization cache keyed by a canonical representation of the "remaining subproblem": `(BranchState, FrameClass, RemainingFuel)` where `BranchState` is a hash of the unexpanded signed formulas + time ordering + applied set.
2. Use `Lean.HashMap` or an `IO.Ref` (if tableau is in IO; currently it's pure). The tableau is pure (`StateM` for traces), so the cache must be pure too. Options:
   - (A) Thread a `HashMap` through `expandBranchWithFuel` as an extra `StateT` layer (like the existing `TraceM` layer). This is invasive but clean.
   - (B) Use `Std.HashMap` with a mutable `Ref` inside `IO` — requires lifting the tableau into `IO`, which breaks pure proofs.
   - (C) **Preferred**: Use a bounded-size LRU cache in `IO` at the `decide` level, keyed by `(Formula, FrameClass)`. Since `decide` is called from `labelFormulaImpl` inside `IO`, cache `decide` results directly. This is simpler and catches repeated formulas across the batch.
3. If going with (C): Add `decideCache : IO.Ref (Std.HashMap (Formula × FrameClass) DecisionResult)` in `DecisionProcedure.lean` or `DatasetGenerator.lean`. Before calling `decide`, check the cache. On hit, return cached result; on miss, run `decide` and insert.
4. Cache invalidation: formulas with different `searchDepth`/`tableauFuel` need separate keys. Use `(Formula, FrameClass, searchDepth, tableauFuel)` as key.
5. Size bound: limit cache to e.g. 10K entries (LRU eviction) to prevent unbounded memory growth during c8+ runs.
6. Benchmark: run c6 with and without cache. Measure hit rate, memory footprint, and total labeling time.

**Expected impact**: Highly formula-dependent. For batches with many syntactic duplicates (common in exhaustive enumeration), hit rate can be 10-30%, reducing total time proportionally. For diverse formula sets, marginal. Best combined with parallelization (task 286).

**Risk**: Cache correctness — if `decide` is nondeterministic (it shouldn't be, but fuel-based cutoff makes it sensitive to execution order), caching could produce inconsistent results. Ensure `decide` is fully deterministic.

---

### 290. Improve tableau fuel allocation heuristic for imbalanced branches
- **Effort**: small (4-6 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Topic**: dataset-enhancement
- **Dependencies**: Task 288 (invalid-pattern prefilter's branch analysis tools — `estimateBranchDifficulty` — can be reused for fuel allocation)

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

---

