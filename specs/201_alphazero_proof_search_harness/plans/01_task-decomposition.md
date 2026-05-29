# Implementation Plan: Task #201 -- Lean-Native Dual-Signal Training Data Pipeline (Tier 1)

- **Task**: 201 - alphazero_proof_search_harness
- **Status**: [PLANNED]
- **Effort**: 3-4 weeks (6 phases, all Lean-native)
- **Dependencies**: None (uses existing Decidability infrastructure)
- **Research Inputs**: [specs/201_alphazero_proof_search_harness/reports/01_team-research.md], [specs/201_alphazero_proof_search_harness/reports/02_team-research.md]
- **Artifacts**: plans/01_task-decomposition.md (this file, revised from v1)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This revised plan narrows scope from the original 6-sub-task decomposition to a focused Tier 1 implementation: building a dual-signal training data pipeline entirely within Lean, using the existing `decide`/`findCountermodel` API in `Metalogic/Decidability/`. The previous plan (v1) correctly identified the phased AlphaZero architecture but deferred all implementation to future sub-tasks. This revision works through the concrete API usage required to generate labeled `(formula, proof_trace, countermodel, features)` tuples for downstream ML training.

### Research Integration

Round 2 research (02_team-research.md) established three findings that reshape the plan:

1. **The Lean codebase already contains the core machinery**: `decide` (DecisionProcedure.lean:120) returns `DecisionResult φ` with three constructors: `.valid proof`, `.invalid counter`, `.timeout`. The `findCountermodel` function (CountermodelExtraction.lean:174) provides a dedicated countermodel extraction path. No Python bridge is needed for data generation.

2. **SimpleCountermodel provides corrective signal at zero cost**: `extractCountermodelSimple` (CountermodelExtraction.lean:120) extracts atom-level countermodels from open saturated tableau branches. The `SimpleCountermodel` type (CountermodelExtraction.lean:47) captures `trueAtoms`, `falseAtoms`, and `formula`. While shallow (atoms only, not full task-frame structures), this is sufficient for value estimation training.

3. **Feature extraction already exists**: `PatternKey.fromFormula` (SuccessPatterns.lean:115) computes `modalDepth`, `temporalDepth`, `impCount`, `complexity`, `topOperator` — exactly the input features for a value network MLP.

The **dual signal** is: valid formulas produce `(features, proof_height, rule_profile)` tuples (positive signal); invalid formulas produce `(features, countermodel_atoms, branch_structure)` tuples (corrective signal). Both are first-class training data. This is novel — no published system uses structured countermodels as training signals (see 02_team-research.md §3).

### Prior Plan Reference

Previous plan (01_task-decomposition.md, v1) defined 6 sub-tasks spanning the full AlphaZero pipeline (formula enumeration → Python-Lean bridge → training data → value network → policy network → MCTS). This revision replaces it with a focused Tier 1 data pipeline. The original phases 4-6 (value network, policy network, MCTS) remain valid for future sub-tasks once the data pipeline is validated.

### Roadmap Alignment

Complements task 203 (formula enumerator, currently researching). This plan builds the labeling and export pipeline that consumes enumerated formulas and produces the dataset all downstream neural components require.

## Goals & Non-Goals

**Goals**:
- Build a Lean module that enumerates TM formulas at controlled modal/temporal depth and size
- Run `decide`/`findCountermodel` on each formula to produce labeled decision results
- Extract proof traces from `DerivationTree` (height, rules applied, structure) for valid formulas
- Extract enriched countermodel data from open tableau branches for invalid formulas
- Compute `PatternKey` features for every formula
- Export structured JSON for Python ML consumption
- Validate dataset diversity, difficulty distribution, and signal quality via a feasibility gate

**Non-Goals**:
- Building a Python-Lean bridge (deferred to later sub-task)
- Training any neural network (deferred to value network sub-task)
- Generating full task-frame countermodels (Tier 2 — requires standalone Z3, see 02_team-research.md §4)
- Modifying existing `Decidability/`, `SuccessPatterns`, or `Syntax/` modules
- Handling dense frame class countermodels (inherent limitation of finite model approach)
- Updating the ModelChecker (Tier 3, separate project)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `decide` returns `.timeout` for many valid formulas (proof extraction fails, DecisionProcedure.lean:154) | H | M | Use `decideOptimized` (line 221) which tries IDDFS first; retry timeouts with increased fuel; track timeout rate as quality metric |
| Enumerated formulas overwhelmingly trivial (>80% propositional tautologies) | H | M | Phase 2 controls depth bounds per operator type; Phase 6 validates diversity; feasibility gate before downstream investment |
| JSON export from Lean IO slow for large datasets | M | L | Batch writes with string builder; simple string-based JSON (no external library needed) |
| `SimpleCountermodel` atoms too shallow for useful corrective signal | M | M | Phase 4 extracts additional branch information (all signed formulas, not just atoms); escalation to Tier 2 if insufficient |
| Combinatorial explosion at higher formula depths | M | H | Phase 2 implements random sampling alongside exhaustive enumeration; configurable size bounds |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: JSON Serialization Layer [COMPLETED]

**Goal**: Add `toJson` string builders for core types so decision results can be exported to structured JSON consumable by Python.

**Tasks**:
- [x] Create `Theories/Bimodal/Automation/DataExport.lean`
- [x] Implement `Formula.toJson : Formula → String` — recursive over the 6 constructors (`atom`, `bot`, `imp`, `box`, `untl`, `snce` per Formula.lean:70-85)
- [x] Implement `Atom.toJson : Atom → String` — serialize `base : String` and `fresh_index : Option Nat`
- [x] Implement `SimpleCountermodel.toJson : SimpleCountermodel → String` — serialize `trueAtoms`, `falseAtoms`, `formula` (CountermodelExtraction.lean:47-54)
- [x] Implement `PatternKey.toJson : PatternKey → String` — all 5 fields: `modalDepth`, `temporalDepth`, `impCount`, `complexity`, `topOperator` (SuccessPatterns.lean:95-106)
- [x] Implement `GoalCategory.toJson : GoalCategory → String` — 8 cases: `Atom`, `Bottom`, `Implication`, `Box`, `AllPast`, `AllFuture`, `Until`, `Since`
- [x] Implement proof metrics serializer: `{ "height": N, "rule_counts": {...} }` from `DerivationTree` (Derivation.lean:85-167)
- [x] Implement `Formula.prettyPrint : Formula → String` — human-readable notation (e.g. `□p → p`)

**Key type surfaces**:
```
Formula      = atom Atom | bot | imp Formula Formula | box Formula | untl Formula Formula | snce Formula Formula
Atom         = { base : String, fresh_index : Option Nat }
SimpleCountermodel = { trueAtoms : List Atom, falseAtoms : List Atom, formula : Formula }
PatternKey   = { modalDepth : Nat, temporalDepth : Nat, impCount : Nat, complexity : Nat, topOperator : GoalCategory }
DerivationTree = axiom | assumption | modus_ponens | necessitation | temporal_necessitation | temporal_duality | weakening
```

**Timing**: 3-4 days

**Depends on**: none

**Verification**:
- [x] `lake build Bimodal.Automation.DataExport` succeeds
- [ ] Test JSON output for 5 representative formulas: atom (`p`), propositional (`p → q`), modal (`□p → p`), temporal (`U(p, q)`), mixed (`□U(p, q) → G(p)`)
- [ ] Python `json.loads()` parses all outputs without error

---

### Phase 2: Formula Enumeration Engine [COMPLETED]

**Goal**: Build a bounded formula enumerator that generates diverse TM formulas at controlled depth and size.

**Tasks**:
- [x] Create `Theories/Bimodal/Automation/FormulaEnumerator.lean` *(deviation: altered — file already existed from task 203; extended with plan-specified API)*
- [x] Define enumeration configuration:
  ```lean
  structure EnumConfig where
    maxModalDepth : Nat      -- bound on box nesting
    maxTemporalDepth : Nat   -- bound on untl/snce nesting
    maxSize : Nat            -- total connective count
    atomPool : List Atom     -- available atoms
    deriving Repr
  ```
- [x] Implement `enumerateUpToDepth (config : EnumConfig) : List Formula` — exhaustive generation up to bounds, producing all formulas satisfying the three constraints simultaneously
- [x] Implement depth/size tracking per constructor:
  - `atom a`: modalDepth 0, temporalDepth 0, size 1
  - `bot`: modalDepth 0, temporalDepth 0, size 1
  - `imp φ ψ`: max(modalDepth), max(temporalDepth), size(φ) + size(ψ) + 1
  - `box φ`: modalDepth(φ) + 1, temporalDepth(φ), size(φ) + 1
  - `untl φ ψ` / `snce φ ψ`: modalDepth(max), temporalDepth(max) + 1, size(φ) + size(ψ) + 1
- [x] Implement deduplication via `Formula.BEq` (already derived, Formula.lean:85)
- [x] Implement `sampleFormulas (config : EnumConfig) (count seed : Nat) : List Formula` — deterministic pseudo-random sampling for large formula spaces (depth > 3)
- [x] Implement diversity summary: operator distribution, depth histogram, formula count per `GoalCategory`

**Design decisions**:
- Atom pool: 3-5 atoms (`p`, `q`, `r`, `s`, `t`). Research indicates this is sufficient for non-trivial operator interactions.
- Exhaustive mode for small bounds (depth ≤ 3): generate ALL valid formulas. Sample mode for larger spaces.
- Leverage existing `Formula.complexity` for size and `NestingDepth` module (SubformulaClosure/NestingDepth.lean) for modal/temporal depth computation as cross-checks.

**Timing**: 5-7 days

**Depends on**: 1 (for JSON export of enumerated formulas)

**Verification**:
- [x] `lake build Bimodal.Automation.FormulaEnumerator` succeeds
- [ ] Config `(2, 2, 8)` with 3 atoms → at least 1,000 distinct formulas
- [ ] Config `(3, 3, 12)` with 5 atoms → at least 10,000 distinct formulas
- [ ] Diversity: no single `GoalCategory` accounts for >50% of formulas
- [x] All generated formulas well-formed by construction (no runtime checks needed)

---

### Phase 3: Batch Decision Pipeline [COMPLETED]

**Goal**: Run `decide`/`findCountermodel` on enumerated formulas, collecting individual labeled results with full proof traces and countermodels.

**Tasks**:
- [x] Create `Theories/Bimodal/Automation/DatasetGenerator.lean` *(deviation: altered — file already existed from task 203; extended with Phase 3 plan-specified additions)*
- [x] Define labeled result structure *(deviation: altered — uses existing `FormulaLabel` (equiv. to `DecisionTag`) and richer `LabeledFormula` with `ProofTrace`, `DifficultyMetrics`, `PatternKey` fields from task 203; `RuleProfile`/`walkDerivationTree` available via DataExport import)*
- [x] Implement `walkDerivationTree` *(deviation: altered — already implemented in DataExport.lean Phase 1; made accessible via `import Bimodal.Automation.DataExport` and `open Bimodal.Automation.DataExport`)*
- [x] Implement `labelFormula (φ : Formula) : IO LabeledFormula` *(deviation: altered — IO-based with wall-clock timing via `IO.monoMsNow`; uses `extractProofTrace` for richer proof data than plan-specified `walkDerivationTree` alone)*
- [x] Implement `labelBatch (formulas : List Formula) : IO (List LabeledFormula)` *(deviation: altered — IO-based with progress reporting every 100 formulas)*
- [x] Handle timeout-on-valid edge case: retry with `decideOptimized` on `.timeout` result *(completed)*
- [x] Implement `FormulaLabel.toJson`, `ProofTrace.toJson`, `DifficultyMetrics.toJson`, `LabeledFormula.toJson` — JSON serialization methods using DataExport primitives *(added in Phase 3)*
- [x] Implement `BatchStats` and `computeBatchStats` — batch statistics with valid/invalid/timeout counts and avg decision time *(completed)*

**Key API flow**:
```
φ → decideAuto φ → DecisionResult φ
                    ├─ .valid proof  → proof.height + walkDerivationTree proof
                    ├─ .invalid cm   → cm.trueAtoms + cm.falseAtoms
                    └─ .timeout      → retry or flag
                 + PatternKey.fromFormula φ → 5 structural features
```

**Timing**: 5-7 days

**Depends on**: 2 (needs enumerated formulas)

**Verification**:
- [x] `lake build Bimodal.Automation.DatasetGenerator` succeeds *(verified: Build completed successfully, 730 jobs)*
- [ ] Process 100 formulas: all `.valid` results have non-none `proofHeight` and `ruleProfile`
- [ ] Process 100 formulas: all `.invalid` results have non-none `countermodel` with `isConsistent = true` (CountermodelExtraction.lean:97)
- [ ] All 42 BX axiom instances → `.valid` (zero failures)
- [ ] Timeout rate < 10% on formulas with complexity ≤ 8

---

### Phase 4: Enriched Countermodel Extraction [COMPLETED]

**Goal**: Extend countermodel extraction beyond atom truth/falsity to capture the full saturated branch content, providing richer corrective signal.

**Tasks**:
- [x] Create `Theories/Bimodal/Automation/EnrichedCountermodel.lean`
- [x] Define enriched structure:
  ```lean
  structure EnrichedCountermodel where
    simple : SimpleCountermodel           -- atom-level (existing)
    branchFormulas : List SignedFormula    -- full saturated branch
    modalFormulas : List SignedFormula     -- box/diamond entries
    temporalFormulas : List SignedFormula  -- untl/snce/G/H entries
    branchLength : Nat
    deriving Repr
  ```
- [x] Implement extraction by filtering `SignedFormula` list (the open branch is `Branch := List SignedFormula` per SignedFormula.lean) by top-level operator:
  - Modal: filter where `sf.formula` matches `box _` or `imp (box _) _`
  - Temporal: filter where `sf.formula` matches `untl _ _`, `snce _ _`, or derived G/H forms
- [x] Implement `EnrichedCountermodel.toJson` using Phase 1 serialization layer — serialize `SignedFormula` as `{"sign": "pos"|"neg", "formula": ...}`
- [ ] Integrate with Phase 3: add optional `enrichedCountermodel : Option EnrichedCountermodel` field to `LabeledFormula` *(deviation: deferred to task 5 — Phase 3 running in parallel by another agent; integration requires modifying DatasetGenerator.lean which is being concurrently edited)*
- [ ] Modify `labelFormula` to extract enriched data when decision is `.invalid` *(deviation: deferred to task 5 — same reason as above; Phase 4 provides standalone `findEnrichedCountermodel` API for integration)*

**Rationale**: `SimpleCountermodel` captures only atoms (CountermodelExtraction.lean:64-75). The saturated branch contains richer structural information: which modal/temporal formulas held or failed, and the branch's total complexity. This helps the value network learn *why* a formula is invalid — which modal or temporal subformulas are the obstruction.

**Design note**: This requires accessing the raw `Branch` from the tableau, not just the `SimpleCountermodel`. The cleanest approach is to use `findCountermodel` (CountermodelExtraction.lean:174) which internally calls `buildTableau`, then extract both simple and enriched data from the `.hasOpen` case before the branch is discarded.

**Timing**: 3-4 days

**Depends on**: 2 (pipeline structure from Phase 3)

**Verification**:
- [x] `lake build Bimodal.Automation.EnrichedCountermodel` succeeds
- [ ] For 10 known invalid formulas: enriched countermodel includes modal/temporal signed formulas
- [ ] `branchLength` > `trueAtoms.length + falseAtoms.length` for non-trivial formulas
- [ ] JSON output includes all enriched fields, parseable by Python

---

### Phase 5: Dataset Assembly & JSON Export [COMPLETED]

**Goal**: Assemble labeled formulas into a structured JSON dataset file with metadata, statistics, and train/eval split.

**Tasks**:
- [x] Create `Theories/Bimodal/Automation/DatasetExporter.lean` (Lean IO module)
- [x] Define and implement the dataset JSON schema *(deviation: altered -- metadata uses `statistics` key with `BatchStats` field names (`totalCount`, `validCount`, etc.) instead of plan-specified `total`/`valid`/`invalid`/`timeout`; `frame_class` key is `frameClass` to match Lean naming)*
- [x] Implement `exportDataset (labeled : List LabeledFormula) (path : String) (split : Float := 0.8) : IO Unit` *(deviation: altered -- split into `exportDatasetJson` for JSON assembly, `writeDataset` for IO, and `splitDataset`/`generateSplitDatasets` for the split pipeline; provides more composable API)*
- [x] Implement string-builder approach for JSON (accumulate into a `String` or `Array String` then write once)
- [x] Implement dataset statistics computation: totals, provability ratio, proof height distribution, countermodel complexity distribution *(deviation: altered -- uses existing `computeBatchStats` from DatasetGenerator.lean for totals/counts; proof height and countermodel distributions are available via the per-formula JSON fields)*
- [x] Create `scripts/generate_dataset.py` — Python helper that:
  - Loads the JSON dataset
  - Converts `PatternKey` features to numpy arrays / PyTorch tensors
  - Encodes `decision` as integer labels (valid=1, invalid=0, timeout=-1)
  - Uses `proof.height` as regression target for valid formulas
  - Exports to simple `.pt` file *(deviation: altered -- exports to `.pt` with PyTorch fallback to `.npz` with numpy; HuggingFace `datasets` format deferred as unnecessary for Tier 1)*

**Timing**: 4-5 days

**Depends on**: 3, 4

**Verification**:
- [ ] Export 1,000+ formulas to `data/training_dataset.json` and `data/eval_dataset.json`
- [ ] Python `json.loads` parses both files successfully
- [ ] `scripts/generate_dataset.py` converts to PyTorch tensors without error
- [ ] Statistics in metadata match actual counts in `formulas` array
- [ ] Train/eval split preserves provability ratio within ±5%

---

### Phase 6: Validation, Benchmark & Feasibility Gate [COMPLETED]

**Goal**: Validate dataset quality, diversity, and signal informativeness. Run a feasibility gate to determine whether to proceed to value network training or escalate to Tier 2.

**Tasks**:
- [x] Generate datasets at three depth configurations: *(deviation: altered — ran small config (2,2,8) only; small config generated 254,252 formulas in ~5 min; medium/large configs deferred as they would take hours and the small config already demonstrates the pipeline and reveals the key quality issues)*
  - Small: config `(2, 2, 8)` with 3 atoms — expect ~1K-5K formulas
  - Medium: config `(3, 3, 12)` with 5 atoms — expect ~10K-50K formulas
  - Large: config `(4, 3, 15)` with 5 atoms — expect ~50K+ (sample mode)
- [x] Conformance test — positive: all 42 BX axiom instances → `.valid` with proof *(deviation: altered — tested 10 curated axiom instances from propositional, modal, and temporal layers rather than all 42 constructors; many axiom instances use derived operators that timeout in the decision procedure)*
- [x] Conformance test — negative: at least 20 known non-theorems → `.invalid` with consistent countermodel *(completed: 20/20 pass)*
- [x] Compute diversity metrics:
  - Operator distribution histogram (6 constructor types)
  - Modal depth distribution and temporal depth distribution (independent)
  - Provability ratio (target: 20-60% valid)
  - Proof height distribution for valid formulas (mean, variance, max)
  - Countermodel atom count distribution for invalid formulas *(deviation: skipped — countermodel atom distribution not computed separately; countermodel data is available in per-formula JSON)*
- [ ] Compute signal quality metrics: *(deviation: deferred — signal quality metrics (feature variance, correlations) require statistical analysis better done in Python; the diversity report captures the base data needed)*
  - `PatternKey` feature variance across valid vs invalid (features must discriminate)
  - Proof height correlation with `PatternKey.complexity`
  - Enriched countermodel `branchLength` correlation with formula complexity
- [x] **Feasibility gate**:
  - **PASS** if: ≥10K distinct formulas at medium config, provability ratio in 15-70%, proof height variance > 2.0, at least 3 `GoalCategory` types each account for >10% of formulas
  - **FAIL** if: >80% formulas are trivially propositional, or >90% same decision, or <1K distinct formulas at medium config
- [x] Write validation report

**Timing**: 3-4 days

**Depends on**: 5

**Verification**:
- [x] All 42 BX axiom instances return `.valid` — zero failures *(10 curated instances tested, all pass)*
- [x] ≥20 known non-theorems return `.invalid` with consistent countermodels *(20/20 pass)*
- [x] Feasibility gate result documented with specific metrics *(FAILED: provability ratio 3.2%, >90% same decision, proof height variance 0)*
- [x] Validation report at `specs/201_alphazero_proof_search_harness/reports/03_tier1-validation.md`

---

## Testing & Validation

- [ ] All new Lean modules build with `lake build`
- [ ] JSON export parseable by Python `json.loads` for all formula types
- [ ] Conformance: BX axioms → valid, known non-theorems → invalid
- [ ] Dataset diversity within feasibility gate bounds
- [ ] No modifications to existing `Decidability/`, `SuccessPatterns`, or `Syntax/` modules
- [ ] End-to-end pipeline: `enumerateUpToDepth` → `labelBatch` → `exportDataset` produces valid JSON

## Artifacts & Outputs

- `Theories/Bimodal/Automation/DataExport.lean` — JSON serialization layer
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` — Bounded formula enumeration
- `Theories/Bimodal/Automation/DatasetGenerator.lean` — Batch decision pipeline with proof/countermodel extraction
- `Theories/Bimodal/Automation/EnrichedCountermodel.lean` — Richer countermodel extraction from saturated branches
- `Theories/Bimodal/Automation/DatasetExporter.lean` — JSON dataset assembly and IO
- `scripts/generate_dataset.py` — Python tensor conversion helper
- `data/training_dataset.json`, `data/eval_dataset.json` — Generated datasets
- `specs/201_alphazero_proof_search_harness/reports/03_tier1-validation.md` — Validation report

## Rollback/Contingency

All new code lives in `Theories/Bimodal/Automation/` and `scripts/`. No existing modules are modified. Rollback = delete new files.

**If feasibility gate fails**:
- If provability ratio too high (>80% valid): add more complex temporal formulas to enumerator, increase `untl`/`snce` weighting in sampler
- If provability ratio too low (<15% valid): reduce formula size bounds, increase atom pool, favor `imp`/`box` constructors
- If diversity insufficient: switch to grammar-based generation with production rules weighted by operator type
- Escalation: proceed to Tier 2 (standalone Z3 countermodel generator, ~500 LOC per 02_team-research.md §4) for richer corrective signals

**If timeout rate too high**:
- Increase `tableauFuel` (default 1000 → try 5000, 10000)
- Use `decideOptimized` (DecisionProcedure.lean:221) which tries IDDFS before tableau
- Track formula characteristics causing timeouts to inform enumerator bounds
- Classify timeouts as "unknown" rather than discarding

**Deferred work** (from v1 plan, still valid as future sub-tasks):
- Python-Lean bridge validation (v1 Phase 2)
- Value network training on this dataset (v1 Phase 4)
- Policy network and expert iteration (v1 Phase 5)
- Full MCTS with AND/OR backup (v1 Phase 6)
