# Research Report: Task #213 — Teammate D (Horizons)

**Task**: 213 - Production-scale dataset generation validation
**Teammate**: D (Strategic Alignment and Creative Directions)
**Started**: 2026-05-29T00:00:00Z
**Completed**: 2026-05-29T00:00:00Z
**Effort**: medium (6-8 hours research)
**Session**: sess_1780088631_bfd193

---

## Key Findings

1. **Task 213 is narrowly scoped but the opportunity window is broader**: The current task description focuses on validation regression testing (did task 210 actually fix things?), but the data and infrastructure now support significantly more ambitious generation goals. Task 213 should be split into two concerns: fast regression validation (< 1 day) and a longer-horizon enhancement pass.

2. **The proof step extractor (task 212) and the formula dataset generator are on divergent tracks that need to be reunited**: `proof_steps.jsonl` provides 2424 deep derivation tree records from 36 handcrafted theorems; the formula dataset provides 59K formulas with simplified 1-level proof traces. These two signal types are complementary but not yet integrated — the BimodalHarness currently has no bridge between them.

3. **The medium dataset has a severe validity signal problem**: 94% of the 1,284 valid formulas in `bmlogic-medium.jsonl` are `(⊥ → φ)` instances (ex_falso axiom schema). Only 76 are genuine non-trivial theorems (`modal_t`, `prop_s` instances). This means the validity signal is dominated by a degenerate pattern that a model could learn trivially from the `⊥` prefix — not a useful training signal.

4. **Proof heights are universally 0 in the formula dataset**: The `DatasetGenerator.extractProofTrace` implementation correctly handles modus ponens chains (height > 0), but `decideAuto` is returning single-axiom derivations for all the formulas it labels valid. The decision procedure is not surfacing the full derivation tree depth in the dataset export.

5. **Production scale for this project is realistically 500K–2M formulas at complexity 5-7**: The memoization fix in task 210 makes exhaustive complexity-5 generation take 1ms (vs 1.5 hours before). The bottleneck has shifted from enumeration to labeling (decision procedure calls). At ~10ms per formula, 500K formulas would take ~83 minutes.

6. **The Reynolds completeness bypass (task 202) is the project's critical path** — the ML training pipeline is secondary infrastructure. Dataset generation should not compete for development priority but should be positioned to benefit from completeness milestones (e.g., Dense/Discrete frame classes become available as frame-class filtering becomes possible).

---

## Strategic Context

### Project Direction (from ROADMAP.md)

The project's primary goal is sorry-free `completeness_discrete` via the Reynolds k-equivalence bypass (task 202). The recommended priority order is:

1. Task 155 (Reynolds pipeline Phase 6-7) → Task 202 (bypass) → Task 95 (axiom audit)
2. Post-completeness: structural refactor, naming conventions, tactics library
3. Post-refactor: documentation, publication quality

The ML training pipeline (tasks 201-213) is an independent track, explicitly not on the critical path. However, it is strategically important as a **demonstration of applied utility** — it shows that the Lean formalization is not purely academic but can power a neural proof search system.

**Implication**: Task 213 should not require completing or blocking the Reynolds bypass. It should run in parallel and produce artifacts that become more valuable as the core logic matures (e.g., Dense/Discrete frame class datasets when those proof systems are finalized).

### How the Pipeline Connects to Task 212

There are two distinct data flows:

**Flow A (Formula-level)**: `FormulaEnumerator` → `DatasetGenerator` (labeling via `decideAuto`) → `DatasetExporter` (JSONL) → BimodalHarness (value network training)

**Flow B (Proof-step-level)**: Handcrafted theorems → `ProofStepExtractor` → `proof_steps.jsonl` → BimodalHarness (policy network training on step sequences)

Currently, Flow A provides **what to prove** (labeled formulas with validity signal), and Flow B provides **how to prove** (step-by-step derivation sequences for known theorems). These should be combined: Flow A formulas proven by the decision procedure should feed into a Flow B extractor to generate step-level training data for those formulas automatically.

### What "Production Scale" Actually Means

Examining the existing data and the project's goals:

| Scale | Formula Count | Practical Purpose |
|-------|--------------|-------------------|
| Toy | < 5K | Feasibility validation (task 204 done) |
| Medium | 5K–50K | Benchmark curation (task 205 planned) |
| Production | 50K–500K | Initial model pretraining |
| Large-scale | 500K–5M | Full training dataset |

For a NeurIPS 2026 Datasets track submission (task 208 mention), the BMLogic-Bench benchmark should have 500–1K held-out formulas (task 205 target) plus a training set of at least 50K diverse labeled formulas. The existing 59K records satisfy the training set target but fail on validity signal quality (see Finding 3).

---

## Creative Approaches Worth Exploring

### 1. Proven Theorem Feedback Loop

Task 212's output (`proof_steps.jsonl`) contains 36 theorems with full derivation trees. Each theorem is a **proven valid formula**. These 36 goal formulas should be injected back into the `generateValidBatch` seed pool in `FormulaEnumerator.lean` alongside the current 8 axiom schemata. This would:
- Guarantee 36 additional valid seeds with non-trivial structure
- Provide seeds for modus ponens closure (if theorem φ and theorem φ→ψ, then ψ is valid)
- Increase formula diversity beyond the ex_falso-dominated current output

Implementation path: Extend `generateValidBatch` with a hardcoded `theoremSeeds : List Formula` parameter, or add a CLI flag `--theorem-seeds path` to the dataset_generator executable.

### 2. Near-Miss Formula Generation ("Adversarial Invalids")

The `FormulaMutator.lean` module already exists (task 206) and implements: atom substitution, operator weakening (box→diamond, G→F), subformula deletion, depth reduction, temporal duality. But this module is in PLANNED state and not yet integrated.

The key strategic insight: **near-miss invalids are more useful than random invalids for training**. A formula like `(□p → □□p)` (S4 axiom, valid) and its mutation `(◇p → □□p)` (invalid) is far more informative than a random deeply nested formula. The model must learn to distinguish the valid pattern precisely.

Prioritize completing task 206 (FormulaMutator integration) before or alongside task 213 validation, because near-miss invalids would dramatically improve the validity signal quality of any production dataset.

### 3. Python Model Checker as Pre-Filter

The project description mentions a Python model checker (in a separate repo) using Z3 for countermodel search. The current pipeline runs the Lean decision procedure on every formula, which:
- Is correct (formally verified)
- But is slow for formulas where `decideAuto` times out (~2.5% rate in deep run)

A two-pass architecture would help:
1. **Pass 1 (Python/Z3)**: Fast countermodel search. If Z3 finds a countermodel in < 100ms, label invalid without calling Lean. If no countermodel found quickly, escalate.
2. **Pass 2 (Lean)**: Run `decideAuto` on the remainder. If valid, export with full proof trace.

This would cut labeling time for invalid formulas significantly (the majority of the dataset). However, this requires Python/Lean coordination and introduces Z3 as a dependency — assess whether the BimodalHarness already has this infrastructure before building it in the Lean repo.

**Risk**: Z3 is a complete model finder for first-order logic but TM is a bimodal logic. The Python model checker must use a reduction to Z3 that is sound (Z3 finding a countermodel ≡ TM formula is invalid). Verify this reduction is correct before using Z3 labels as ground truth.

### 4. Difficulty Labels via Decision Time

The existing `metrics.decisionTimeMs` field already captures wall-clock decision time, and the `difficultyTier` (easy/medium/hard/very_hard) is assigned based on complexity. But there is a more principled difficulty measure: **proof height**. A formula proven by a single axiom application has height 0; a formula requiring 10 modus ponens steps has height 10.

Currently, proof heights are uniformly 0 in the formula dataset because `decideAuto` returns shallow derivations for the patterns it recognizes. The proof step extractor (task 212) shows that handcrafted proofs reach heights of 325 (perpetuity_4). This 0 vs 325 gap reveals that `decideAuto` is not doing deep proof search for the formula dataset — it is pattern-matching axiom instances.

**Recommendation**: Add a `proof_height_estimated` field computed from the derivation tree for valid formulas. Use this as a difficulty signal for curriculum learning. Formulas provable in 0-2 steps are "easy" axiom instances; formulas requiring deep modus ponens chains are "hard" non-axiom theorems.

For now, the practical proxy for difficulty is the combination of `complexity` + `modalDepth` + `temporalDepth` already in `pattern_key`. This is usable for curriculum learning even without true proof height.

### 5. Frame Class Stratified Dataset

The current dataset is entirely `FrameClass.Base`. Dense-specific axioms (density axiom `GGp→Gp`) and discrete-specific axioms (Prior-UZ/SZ, Z1) are available in the proof system. Once Dense/Discrete completeness milestones are reached (post-Reynolds bypass), it would be strategically valuable to generate Dense and Discrete frame class datasets:
- Dense dataset: includes density axiom instances as positive examples
- Discrete dataset: includes Z1, Prior-UZ/SZ instances
- Cross-frame contamination detection: same formula, different validity under different frame classes

This is future work (post-task 202), but task 213 should preserve the `frame_class` field in output schemas and design enumeration to be frame-class-parameterizable for when Dense/Discrete generation becomes possible.

---

## Task Scoping Recommendations

### Task 213 as Currently Scoped

The current description is: "Re-run the pipeline at complexity 5-7, compare against task 204 baselines, verify timing/counts/valid fractions, identify bottlenecks."

This is a **regression validation task** — it checks whether task 210's enumeration fix actually enables the runs that previously failed. This is legitimate and worth doing (estimated 4-8 hours), but it misses the larger opportunity.

**Recommended split**:

**Task 213A (Regression Validation)** — Keep as task 213, narrow scope:
- Run `lake exe dataset_generator` at complexity 5 (exhaustive) and 6 (exhaustive) with the new memoized enumerator
- Compare timing against task 204 baselines
- Verify the 15% valid fraction gate with `validSeedCount` tuning
- Document any remaining bottlenecks (e.g., labeling throughput)
- Estimated: 4-6 hours

**Task 213B (Signal Quality Enhancement)** — New task, medium scope:
- Diagnose why ex_falso dominates valid set (1208/1284 in medium dataset)
- Implement theorem seed feedback from task 212's 36 theorems
- Tune axiom-seeded generation (`generateValidBatch`) to diversify beyond trivial instances
- Target: < 50% ex_falso in valid set, proof height distribution spanning 0-10+
- Estimated: 8-12 hours, depends on task 212 artifacts

**Alternative**: Keep task 213 as one task but explicitly scope it to include signal quality improvement. Given that the validation regression is fast (a few hours of actual runtime), the remaining time in the task can be used for enhancement.

### Priority Relative to Other Tasks

Recommended ordering within the ML pipeline track:
1. Task 213A (regression validation) — unlock confidence in the fixed enumerator
2. Task 206 (contrastive pair generation, already PLANNED) — near-miss invalids
3. Task 213B / signal quality enhancement — integrate proof step seeds
4. Task 205 (benchmark curation, already PLANNED) — stratified sampling for BMLogic-Bench
5. Task 208 (HuggingFace packaging) — publication artifact

Tasks 206 and 205 are already planned and should not be blocked on task 213. Task 213 is effectively the gating step that confirms the enumerator fix works before producing large datasets for those downstream tasks.

---

## Long-term Vision Alignment

### Dual Verification Architecture

The ROADMAP describes a "dual verification architecture":
- **Lean side**: Decision procedure (`decideAuto`) produces formally verified validity labels
- **Python side**: Z3 model checker produces countermodels as corrective signal

The dataset generation pipeline embodies this architecture at the data level:
- Valid formulas: Lean-certified proof traces (positive signal for policy/value networks)
- Invalid formulas: Lean/Z3-produced countermodels (corrective signal for countermodel reasoning)

Task 213's job is to validate that this dual-signal pipeline operates reliably at scale. The strategic goal is not just "59K formulas" but "a dataset where every label is machine-checkable and every countermodel is independently verifiable."

### BMLogic-Bench as Research Contribution

The project has ambitions for a NeurIPS 2026 Datasets track submission (task 208). For this to succeed, the dataset must:
1. Have a compelling validity signal (not 94% ex_falso trivial instances)
2. Include difficulty stratification (curriculum learning support)
3. Have a held-out benchmark with known-correct ground truth
4. Be reproducible (deterministic seed, published generation code)

Task 213 is the gating step for all of these. If the production runs still have validity signal problems after the enumeration fix, the downstream benchmark curation (task 205) will inherit those problems.

### AlphaZero Proof Search Connection

The proof step extractor (task 212) produces step-level training data for the policy network component of an AlphaZero-style proof search (task 201). The formula dataset produces training data for the value network (is this goal reachable?). Both are needed for the full MCTS proof search architecture.

The long-term vision is: a neural proof assistant that can discover new theorems in TM bimodal logic by combining:
- **Value network**: predicts validity probability of a formula from its syntax
- **Policy network**: predicts the best next proof step given a partial derivation tree
- **MCTS**: uses both to search the proof space efficiently

Task 213 is one step in building the value network training data. It should be scoped with that end goal in mind: not just "does the pipeline run?" but "is the output useful for training a value network?"

### Completeness-Driven Dataset Evolution

As the Reynolds bypass (task 202) progresses, new opportunities open:
- When Dense completeness is sorry-free: generate Dense-specific formulas
- When Discrete completeness is sorry-free: generate Discrete-specific formulas  
- When the full axiom audit (task 95) completes: generate instances of all 42 axioms (currently only ~13 axiom names appear in proof steps)

Dataset generation should be treated as an evolving capability that matures alongside the proof system, not a one-time production run.

---

## Confidence Level

**High confidence**:
- The ex_falso dominance issue (directly measured: 1208/1284 = 94%)
- The proof height = 0 problem in the formula dataset (measured, root cause identified)
- Task 213 regression scope is achievable quickly (enumeration fix is confirmed by task 210 benchmarks: complexity 5 = 1ms, complexity 7 = 3ms)
- The two data flows (formula-level vs proof-step-level) are currently disconnected

**Medium confidence**:
- Production scale target of 500K–2M formulas (extrapolated from current labeling throughput estimates)
- The Python Z3 pre-filter proposal (depends on BimodalHarness architecture, not fully audited)
- Timeline for task 213B (proof step seed integration) — depends on how cleanly task 212 seeds can be extracted

**Low confidence**:
- Whether NeurIPS 2026 Datasets submission is realistic given the current signal quality issues
- Whether the BimodalHarness already has infrastructure for the proof step data (separate repo, not audited)
- Frame class stratified dataset timeline (blocked on Reynolds bypass)

---

## Appendix: Data Quality Metrics Summary

| Dataset | Records | Valid % | Ex_falso % of Valid | Proof Height > 0 |
|---------|---------|---------|---------------------|------------------|
| bmlogic-medium.jsonl | 5,136 | 25% | 94% | 0% |
| bmlogic-deep.jsonl | 53,979 | 1.6% | unknown | unknown |
| proof_steps.jsonl | 2,424 | 100% (by construction) | 0% | see below |
| axiom-instances.jsonl | 724 | 16% | unknown | unknown |

**Proof step height distribution (task 212)**:
- identity theorem: ~5 steps
- perpetuity_4: 325 steps (deepest)
- Average across 36 theorems: ~67 steps

**Key insight**: The proof step extractor produces deep, rich derivation records. The formula dataset produces shallow, axiom-dominated records. Bridging these two signal types is the highest-leverage enhancement for production readiness.

---

## Sources and References

- `specs/ROADMAP.md` — Project direction and critical path
- `specs/TODO.md` — Task status for tasks 201-213
- `specs/212_implement_proof_step_extractor/summaries/01_implementation-summary.md` — Task 212 artifacts
- `specs/204_dataset_production_runs/summaries/01_production-runs-summary.md` — Production run results
- `specs/210_enumerator_complexity_blowup/reports/01_enumerator-blowup-research.md` — Enumeration fix analysis
- `specs/210_enumerator_complexity_blowup/summaries/*.md` — Task 210 implementation
- `data/bmlogic-medium.jsonl` — Direct analysis (5,136 records)
- `data/bmlogic-deep.jsonl` — Direct analysis (53,979 records)
- `data/proof_steps.jsonl` — Direct analysis (2,424 records)
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` — Enumeration design
- `Theories/Bimodal/Automation/DatasetGenerator.lean` — Proof trace extraction logic
- `Theories/Bimodal/Automation/FormulaMutator.lean` — Contrastive pair module (task 206)
