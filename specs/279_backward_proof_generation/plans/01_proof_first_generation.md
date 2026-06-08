# Implementation Plan: Forward-Chaining Proof Generation (Task 279)

- **Task**: 279 - backward_proof_generation (proof-first / forward-chaining generation)
- **Status**: [COMPLETED]
- **Effort**: 20 hours
- **Dependencies**: Task 277 (tableau rule-firing traces) - delivered
- **Research Inputs**: specs/279_backward_proof_generation/reports/01_proof_first_generation.md (1231 lines, 12 findings, 10 recommendations)
- **Artifacts**: plans/01_proof_first_generation.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4

## Overview

Build a forward-chaining proof generation system that constructs derivation trees over the existing 42 axiom schemata in `Bimodal.ProofSystem.Axiom` (Axioms.lean:76-484) under the 7 inference rules of `DerivationTree` (Derivation.lean:85-167), then extracts the conclusion formulas as labeled training data. Every emitted `(formula, proof)` pair is a theorem by construction (Lean's type system IS the verifier). The system integrates as a third `proofFirst` mode in `DatasetGenerator.lean` alongside the existing `exhaustive` mode, with side-by-side comparison against the exhaustive baseline.

The implementation reuses 100% of `DerivationTree`, `extractProofTrace` (DatasetGenerator.lean:262), and `walkDerivationTree` (DataExport.lean:325) — the supervision signal extractors are unchanged. The new code is concentrated in three new files (`ForwardProofGenerator.lean`, `ProofFirstExporter.lean`, `ProofFirstBenchmark.lean`), one modified file (`FormulaEnumerator.lean` to extend `instantiateAxiom` to 42 cases with `Axiom` witnesses), and minimal additions to `DatasetGenerator.lean` and `lakefile.lean`.

### Research Integration

The full research report at `specs/279_backward_proof_generation/reports/01_proof_first_generation.md` is integrated. Key findings driving the plan:

- **Reuse `DerivationTree`**: 7 constructors, 42 axiom schemata, dependent types make full JSON serialization impractical — `extractProofTrace` summary is sufficient for ML training.
- **Generalize `generateValidBatch`**: FormulaEnumerator.lean:1361-1461 is the closest existing analogue. The change is to thread `DerivationTree fc [] φ` witnesses through the seed-and-fixpoint closure.
- **Extend `instantiateAxiom` to 42 cases**: FormulaEnumerator.lean:1153-1252 covers only 22 of the 42 `Axiom` constructors. The 20 missing schemata are mostly BX past-mirrors and uniformity/prior/density axioms.
- **Implication index for O(n) MP**: FormulaEnumerator.lean:1430-1448 HashMap pattern (Formula.lhs -> Array of (rhs, proof)) is the proven technique.
- **Ex_falso cap 20%**: Reuse `capExFalso` from FormulaEnumerator.lean:1389-1417 and EnumBenchmark.lean:79.
- **Dedup by shortest-height**: O(1) per insertion, deterministic, monotonic. One canonical proof per formula.
- **No `weakening` in forward pass**: Adds unused assumptions; produces log-equivalent duplicates under empty context.
- **Frame class filtering at instantiation time**: Filter schema list in `instantiateAxiomWithProof` to avoid runtime `decide` calls; `DerivationTree.lift` (Derivation.lean:190) lifts to higher frame classes post-hoc.
- **Task 277 complementarity**: Task 277 produces *tableau* trace certificates; task 279 produces *Hilbert* proof trees. They are complementary views of the same formula. Hybrid mode emits both (deferred to round 2).
- **Expected performance**: ~37x improvement in valid-formula throughput vs. exhaustive enumeration at c4 (per research report Section 14).

### Prior Plan Reference

No prior plan exists for this task. The research report (1231 lines) is the only prior artifact and is integrated above.

### Roadmap Alignment

No `specs/ROADMAP.md` exists in the task directory. The `roadmap_flag` is not set, so no roadmap-snapshot phases are required. The plan proceeds without roadmap integration.

## Goals & Non-Goals

**Goals**:
- Implement a forward-chaining combinator that starts from axiom instances and applies the 4 productive inference rules (modus ponens, necessitation, temporal necessitation, temporal duality) up to a configurable derivation depth N.
- Collect `(formula, proof_tree)` pairs where the proof tree is a `DerivationTree fc [] φ` witness.
- Control complexity via derivation depth (not formula AST size).
- Compute axiom diversity and branching metrics automatically using the rule-firing traces from task 277.
- Integrate as a third `proofFirst` mode in `DatasetGenerator.lean` alongside `exhaustive` and `hybrid`.
- Compare output quality vs. exhaustive generation across 8 cross-corpus metrics (axiom diversity, proof depth distribution, temporal axiom usage, modal axiom usage, rule profile distribution, ex_falso dominance, operator diversity, generation cost).

**Non-Goals**:
- Full JSON serialization of `DerivationTree` (deferred; `extractProofTrace` summary is sufficient).
- New `Axiom` constructors (the 42 existing schemata are sufficient).
- Hybrid-mode integration with `decideWithTrace` (deferred to round 2; only the `proofFirst` mode is required).
- Backward search integration (out of scope; we are building a forward generator).
- Replace existing `exhaustive` mode (it remains as-is; the new mode is an additional option).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `instantiateAxiom` extension to 42 cases breaks existing call sites | H | M | New function `instantiateAxiomWithProof` added alongside; old function untouched. Lean type system catches mismatched arity at compile time. |
| Pool size explosion at depth 5 (10^8 MP pairs) | M | M | Implication index reduces to O(n) per MP round (FormulaEnumerator.lean:1430-1448 pattern); `maxPoolSize` cap (default 10000) bounds memory. |
| Memory growth from `DerivationTree` witnesses | M | M | Each tree height is bounded by `maxDepth`; total memory is O(maxPoolSize × maxDepth × avgProofSize) ≈ 5MB for defaults. |
| Frame class typing fails at `DerivationTree.axiom` constructor | H | L | Filter schema list at `instantiateAxiomWithProof` time using `Axiom.minFrameClass` (Axioms.lean:456), so the runtime `decide` is never needed. `DerivationTree.lift` (Derivation.lean:190) lifts to higher frame classes post-hoc. |
| Soundness gap if `weakening` is applied | M | M | Explicitly excluded from the forward loop per research finding. Unit test asserts no `weakening` nodes in output. |
| `ex_falso` dominance degrades diversity | M | H | Hard cap at 20% via `capExFalso` (mirrors EnumBenchmark.lean:79); layer-uniform axiom selection enforces balance. |
| Dedup cost dominates at pool size 10000 | L | M | Shortest-wins dedup is O(1) per insertion; index lookup is O(1) via `Std.HashMap`. |
| Side-by-side comparison report is too coarse to show value | M | M | 8 distinct cross-corpus metrics per research Section 9.2; JSON output preserves full distribution. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 4, 5 | 1, 2 |
| 3 | 6, 7 | 2, 3, 4, 5 |
| 4 | 8, 9 | 6, 7 |
| 5 | 10 | 8 |
| 6 | 11, 12 | 8, 9, 10 |

Phases within the same wave can execute in parallel.

### Phase 1: Extend `instantiateAxiom` Coverage [IN PROGRESS]

**Goal**: Extend `instantiateAxiom` in `Theories/Bimodal/Automation/FormulaEnumerator.lean:1153-1252` from 22 to 42 axiom schemata, with each case now returning both the `Formula` and an `Axiom` witness, so it can serve as a prerequisite for the forward generator's `instantiateAxiomWithProof`.

**Tasks**:
- [ ] Add new function `instantiateAxiomWithWitness : List Atom → Nat → IO (Option (Σ φ, Axiom φ))` to FormulaEnumerator.lean (do NOT modify the existing 22-case `instantiateAxiom`).
- [ ] Cover the 20 missing schemata: 6 BX past-mirrors (`serial_past`, `left_mono_since_H`, `right_mono_since`, `connect_past`, `enrichment_since`, `self_accum_since`, `F_until_equiv_past` mirror), 4 uniformity axioms (`discrete_symm_fwd`, `discrete_symm_bwd`, `discrete_propagate_fwd`, `discrete_propagate_bwd`, `discrete_box_necessity`), 2 prior axioms (`prior_UZ`, `prior_SZ`), 1 Z1 axiom (`z1`), 2 density axioms (`density`, `dense_indicator`), and the missing modal_future mirror `modal_past` (per Axioms.lean:18-37 and the task research report).
- [ ] Wrap each existing 22 case to ALSO return the `Axiom` constructor (`.prop_k φ ψ χ`, `.modal_t φ`, etc.).
- [ ] Add a frame-class filter: at instantiation time, return `none` if the picked axiom's `Axiom.minFrameClass` (Axioms.lean:456) is not ≤ the requested `FrameClass`. Use the decidable `FrameClass.LE` instance (Axioms.lean:434-435).
- [ ] Add a small helper `pickSchemaIdx : List Atom → Nat → FrameClass → IO Nat` that re-weights the schema index distribution based on `FrameClass` (e.g., suppress `density` for `.Base`).

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` — add `instantiateAxiomWithWitness` (~120 LOC new), no changes to existing 22-case function.

**Verification**:
- Unit test: for each of the 42 `Axiom` constructors, `instantiateAxiomWithWitness` returns a witness that type-checks against the corresponding `Axiom` constructor (i.e., the constructed `Formula` matches the expected signature).
- Build passes: `lake build` succeeds with the new function.
- Property test: for `FrameClass = .Base`, all 37 base axioms are reachable; for `FrameClass = .Discrete`, the 3 discrete-only axioms (`prior_UZ`, `prior_SZ`, `z1`) are also reachable; for `FrameClass = .Dense`, the 2 dense axioms (`density`, `dense_indicator`) are also reachable.

### Phase 2: ForwardConfig and ProofPool Data Structures [NOT STARTED]

**Goal**: Create the new file `Theories/Bimodal/Automation/ForwardProofGenerator.lean` with the foundational data structures: `ForwardConfig` (configuration parameters) and `ProofPool` (the formula + proof store with shortest-wins dedup). No algorithmic content yet — only the type scaffolding that Phases 3-6 will populate.

**Tasks**:
- [ ] Create `Theories/Bimodal/Automation/ForwardProofGenerator.lean` with imports: `Bimodal.ProofSystem`, `Bimodal.ProofSystem.Derivation`, `Bimodal.Automation.DataExport`, `Bimodal.Automation.SuccessPatterns`, `Bimodal.Automation.FormulaEnumerator`.
- [ ] Define `structure ForwardConfig` with fields: `seedCount : Nat := 2000`, `maxParamSize : Nat := 4`, `maxDepth : Nat := 3`, `maxPoolSize : Nat := 10000`, `atoms : List Atom`, `frameClass : FrameClass := .Base`, `exFalsoCap : Nat := 1`, `exFalsoDenom : Nat := 5`, `layerUniform : Bool := true`, `dedupStrategy : DedupStrategy := .shortestWins`, deriving `Repr, Inhabited, BEq`.
- [ ] Define `inductive DedupStrategy where | shortestWins | distinctAxiomWins | firstWins`, deriving `Inhabited, Repr, BEq`.
- [ ] Define `structure ProofPool (fc : FrameClass) where entries : Array (Σ φ, DerivationTree fc [] φ) := #[]; formulas : Std.HashSet Formula := {}; index : Std.HashMap Formula Nat := {}; cap : Nat := 10000`.
- [ ] Define `ProofPool.empty`, `ProofPool.size`, `ProofPool.contains`, `ProofPool.add` (shortest-wins by default), `ProofPool.toList`, `ProofPool.filter` (by axiom name, by height range).
- [ ] Add docstrings referencing the research report (sections 6.1, 6.3, 8.1) and the existing `generateValidBatch` pattern (FormulaEnumerator.lean:1361).

**Timing**: 1.5 hours

**Depends on**: none

**Files to create**:
- `Theories/Bimodal/Automation/ForwardProofGenerator.lean` — new file, ~150 LOC.

**Verification**:
- File compiles: `lake build Bimodal.Automation.ForwardProofGenerator` succeeds.
- Unit test: `ProofPool.empty.size == 0`; after `pool.add φ d₁` and `pool.add φ d₂` with `d₂.height < d₁.height`, the stored proof is `d₂`; with `d₂.height > d₁.height`, the stored proof is `d₁` (shortest-wins).
- Unit test: `pool.contains φ` returns `true` after `pool.add φ d`.

### Phase 3: `instantiateAxiomWithProof` Returning DerivationTree Witnesses [COMPLETED]

**Goal**: Define `instantiateAxiomWithProof` in `ForwardProofGenerator.lean` that wraps the `instantiateAxiomWithWitness` (Phase 1) result into a `DerivationTree fc [] φ` (using the `DerivationTree.axiom` constructor) or returns `none` if the axiom's `minFrameClass` is not compatible with `fc`.

**Tasks**:
- [ ] Define `instantiateAxiomWithProof : ForwardConfig → IO (Option (Σ φ, DerivationTree cfg.frameClass [] φ))` that delegates to `instantiateAxiomWithWitness` (Phase 1) and wraps the result in `DerivationTree.axiom [] φ ax (by exact leOfMinFrameClass ...)` (matching the `h_fc` field).
- [ ] Add a helper `leOfMinFrameClass : (ax : Axiom φ) → (fc : FrameClass) → Decidable (ax.minFrameClass ≤ fc)` that uses `inferInstance` or `decide` to produce the proof obligation.
- [ ] Add a `randomAxiomSchema` helper that picks a uniform random index in `[0, 42)` and returns the schema name as a string (for diversity tracking in Phase 9).
- [ ] Add unit test that for a fixed seed, `instantiateAxiomWithProof` returns a value whose proof height is `0` (axiom case).
- [ ] Add a `Layer` enumeration (Propositional | Modal | BX | Interaction | Uniformity | Prior | Z1 | Density) and a `schemaLayer : Nat → Layer` function for layer-uniform selection.

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Files to create**:
- `Theories/Bimodal/Automation/ForwardProofGenerator.lean` — add ~80 LOC.

**Verification**:
- Unit test: for each of the 42 schemata (sample at least one per layer), `instantiateAxiomWithProof` returns `some σ` and `σ.snd` has `.height = 0`.
- Unit test: for `FrameClass = .Base` and schema index pointing to a `density` axiom, `instantiateAxiomWithProof` returns `none` (frame class mismatch).
- Property test: for 1000 random calls, the schema name distribution is uniform over the 42 (or the layer-uniform subset when `cfg.layerUniform = true`).

### Phase 4: Modus Ponens via Implication Index [COMPLETED]

**Goal**: Implement `applyModusPonens` in `ForwardProofGenerator.lean` that performs one pass of MP closure using a `Std.HashMap Formula (Array (Formula × DerivationTree))` implication index, achieving O(n) per round instead of O(n^2). This is the key optimization identified in research finding #4.

**Tasks**:
- [ ] Define `applyModusPonens (cfg : ForwardConfig) (pool : ProofPool cfg.frameClass) : IO (ProofPool cfg.frameClass)` that:
  1. Builds the implication index by iterating `pool.entries` and grouping by `Formula.lhs` for any `.imp lhs rhs`.
  2. For each entry in `pool`, looks up its `lhs` (or itself if not an implication) in the index and constructs a new `DerivationTree.modus_ponens` for each match.
  3. Calls `pool.add` with the new proof (which uses shortest-wins dedup).
- [ ] Add an `IO` progress log every 1000 MP steps (matching the pattern in FormulaEnumerator.lean:1455).
- [ ] Add a complexity filter: skip MP results whose `rhs.complexity > cfg.maxParamSize * 4` (or some configurable bound) to prevent explosion.
- [ ] Add a unit test with a small pool of 10 formulas, asserting the MP result count is correct and all results have `.height = 1` (since seeds are axioms, height 0; one MP step = height 1).
- [ ] Add a benchmark assertion: `applyModusPonens` on a 10000-formula pool completes in < 5 seconds (single-threaded).

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Files to create**:
- `Theories/Bimodal/Automation/ForwardProofGenerator.lean` — add ~70 LOC.

**Verification**:
- Unit test: with seeds `{p → (p → p) : axiom prop_s p p, p : axiom prop_s ...}` (constructed via `instantiateAxiomWithProof`), `applyModusPonens` produces the MP conclusion `p → p` with `.height = 1` and `DerivationTree.modus_ponens` root.
- Property test: MP closure is monotone: the new pool is a superset of the input.
- Benchmark: at `maxPoolSize = 10000`, `applyModusPonens` takes < 5s.

### Phase 5: Necessitation, Temporal Necessitation, Temporal Duality Closures [IN PROGRESS]

**Goal**: Implement `applyNecessitation`, `applyTemporalNecessitation`, `applyTemporalDuality` in `ForwardProofGenerator.lean`, each applying one of the three unary inference rules to every formula in the pool. The output pool is the original pool with the rule's wrapped versions of each formula added (using `pool.add` for shortest-wins dedup).

**Tasks**:
- [ ] Define `applyNecessitation (pool : ProofPool fc) : ProofPool fc` that for each `(φ, d)` in `pool.entries`, adds `(Formula.box φ, DerivationTree.necessitation φ d)` to the pool.
- [ ] Define `applyTemporalNecessitation` analogously using `DerivationTree.temporal_necessitation` and `Formula.all_future`.
- [ ] Define `applyTemporalDuality` analogously using `DerivationTree.temporal_duality` and `Formula.swap_temporal`.
- [ ] Add a combined `applyUnaryRules : ForwardConfig → ProofPool fc → ProofPool fc` that calls all three in sequence (with progress logging).
- [ ] Unit test: applying `applyNecessitation` to `pool = {[p, axiom]}` produces `pool' = {[p, axiom], [□p, necessitation]}` (after shortest-wins dedup).
- [ ] Unit test: `Formula.swap_temporal` is an involution (per Formula.lean:541-549) — applying `applyTemporalDuality` twice returns the original formula (but with doubled height).

**Timing**: 1 hour

**Depends on**: 1, 2

**Files to create**:
- `Theories/Bimodal/Automation/ForwardProofGenerator.lean` — add ~50 LOC.

**Verification**:
- Unit test: every new entry in the pool has `.height = 1` (one unary rule step from an axiom).
- Property test: pool size after `applyUnaryRules` is at most 4x the input size (each formula generates up to 3 new formulas: □φ, Gφ, swap_temporal φ).
- Property test: no `DerivationTree.weakening` nodes are introduced (asserted via pattern match on the tree).

### Phase 6: Bounded Fixpoint Loop and Ex_Falso Cap [NOT STARTED]

**Goal**: Implement the main `forwardGenerate` function in `ForwardProofGenerator.lean` that orchestrates the three phases from the research report: (1) seed pool with axiom instances, (2) cap ex_falso to 20%, (3) bounded fixpoint closure under (MP, Nec, TempNec, TempDual). The result is the full `(formula, proof)` list.

**Tasks**:
- [ ] Define `forwardGenerate (cfg : ForwardConfig) : IO (List (Σ φ, DerivationTree cfg.frameClass [] φ))` that:
  1. Initializes `pool : ProofPool cfg.frameClass = .empty` with `cap = cfg.maxPoolSize`.
  2. **Phase 1 — Seed**: loops `cfg.seedCount` times calling `instantiateAxiomWithProof cfg` and adding to `pool` (with progress logging every 10%).
  3. **Phase 2 — Ex_falso cap**: mirrors `FormulaEnumerator.lean:1389-1417`: count ex_falso entries, cap at `pool.size * cfg.exFalsoCap / cfg.exFalsoDenom` (default 1/5 = 20%), retry axiom instantiation with non-ex_falso bias.
  4. **Phase 3 — Fixpoint closure**: for `depth in [0, cfg.maxDepth)`, apply `applyModusPonens` (Phase 4) then `applyUnaryRules` (Phase 5). Stop early if pool size stops growing (growth rate < 1%) or `pool.size ≥ cfg.maxPoolSize`.
  5. Return `pool.toList`.
- [ ] Add wall-clock timing via `IO.monoMsNow` for each phase.
- [ ] Add a `progressLog : IO Unit` that prints `[proof-first] depth={d} pool={n} (+{g} growth) elapsed={t}ms` every 1000 entries.
- [ ] Add a `capExFalso` helper matching the logic in `FormulaEnumerator.lean:1389-1417`.
- [ ] Unit test: `forwardGenerate {seedCount := 10, maxDepth := 1, atoms := [p, q, r]}` returns a non-empty list of `(φ, d)` pairs.
- [ ] Property test: every returned `d` is a `DerivationTree cfg.frameClass [] φ` (type-check passes); every `d.height ≤ cfg.maxDepth` (since the fixpoint loop only runs `maxDepth` rounds).
- [ ] Property test: ex_falso fraction in the output is ≤ `cfg.exFalsoCap / cfg.exFalsoDenom` (default 0.2).

**Timing**: 2 hours

**Depends on**: 2, 3, 4, 5

**Files to create**:
- `Theories/Bimodal/Automation/ForwardProofGenerator.lean` — add ~120 LOC.

**Verification**:
- Integration test: with `cfg = {seedCount := 100, maxDepth := 2, maxPoolSize := 1000, atoms := [p, q, r]}`, `forwardGenerate` returns a list of ~500-1000 `(φ, d)` pairs in < 10 seconds.
- Soundness test: every `(φ, d)` in the output can be processed by `extractProofTrace` and `walkDerivationTree` (the existing extractors) without error.
- Property test: pool size is monotone non-decreasing across fixpoint rounds.

### Phase 7: GenerationMode Inductive and `labelFormula` Dispatch [NOT STARTED]

**Goal**: Add the `GenerationMode` inductive (`exhaustive | proofFirst | hybrid`) to `DatasetGenerator.lean`, modify `labelFormula` (currently at `DatasetGenerator.lean:545`) to dispatch on the mode, and add a new `labelFormulaProofFirst` that looks up a pre-computed `ProofPool` index.

**Tasks**:
- [ ] Add `inductive GenerationMode where | exhaustive | proofFirst | hybrid, deriving Inhabited, Repr, BEq` near the top of `DatasetGenerator.lean` (after imports, before `LabeledFormula`).
- [ ] Define `labelFormulaProofFirst (φ : Formula) (pool : ProofPool .Base) (fc : FrameClass := .Base) : IO LabeledFormula` that:
  1. Looks up `pool.index[φ]?`. If `some`, returns a `LabeledFormula` with `label = .valid`, `proofTrace := some (extractProofTrace σ.snd)`, `ruleProfile := some (walkDerivationTree σ.snd)`, `decisionMethod := "proof_first"`, `proofReconstructionMethod := some "proof_first_compositional"`, plus existing `computeMetrics`, `PatternKey.fromFormula`, `computeInterestingness` calls.
  2. If `none`, returns a fallback `LabeledFormula` with `label = .invalid` (or delegates to the existing `labelFormula` with the same mode set to `.exhaustive`).
- [ ] Modify the existing `labelFormula` signature to add `mode : GenerationMode := .exhaustive` and `proofFirstPool : Option (ProofPool .Base) := none` parameters. Implement dispatch:
  - `(.exhaustive, _)` → existing logic (no change).
  - `(.proofFirst, some pool)` → `labelFormulaProofFirst φ pool fc`.
  - `(.proofFirst, none)` → error log + fall back to exhaustive.
  - `(.hybrid, some pool)` → try `labelFormulaProofFirst` first; if `.invalid`, fall back to exhaustive.
  - `(.hybrid, none)` → exhaustive.
- [ ] Update all existing call sites of `labelFormula` to pass `.exhaustive` (no behavior change for them).
- [ ] Add a unit test for `labelFormulaProofFirst` with a small hand-built pool.

**Timing**: 1.5 hours

**Depends on**: 2, 3, 4, 5

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` — add `GenerationMode` (~5 LOC), `labelFormulaProofFirst` (~40 LOC), modify `labelFormula` signature (~10 LOC).

**Verification**:
- Build passes: `lake build` succeeds with the modified `labelFormula`.
- Regression test: all existing `labelFormula` call sites still produce the same outputs (since default `mode = .exhaustive`).
- Unit test: `labelFormulaProofFirst φ pool` with `φ ∈ pool` returns `.valid` with `decisionMethod = "proof_first"`.
- Unit test: `labelFormulaProofFirst φ pool` with `φ ∉ pool` returns `.invalid` (or falls back to exhaustive per the chosen policy).

### Phase 8: ProofFirstExporter for JSONL Output [NOT STARTED]

**Goal**: Create the new file `Theories/Bimodal/Automation/ProofFirstExporter.lean` that converts a `List (Σ φ, DerivationTree)` (the output of `forwardGenerate`) into a stream of `LabeledFormula` records and emits them as JSONL, mirroring the existing `DatasetExport.lean` pattern.

**Tasks**:
- [ ] Create `Theories/Bimodal/Automation/ProofFirstExporter.lean` with imports: `Bimodal.Automation.ForwardProofGenerator`, `Bimodal.Automation.DatasetGenerator`, `Bimodal.Automation.DataExport`.
- [ ] Define `exportToJsonl (cfg : ForwardConfig) (pool : List (Σ φ, DerivationTree cfg.frameClass [] φ)) : IO (List LabeledFormula)` that:
  1. For each `(φ, d)`, calls `extractProofTrace d`, `walkDerivationTree d`, `computeMetrics φ 0`, `PatternKey.fromFormula φ`, `computeInterestingness φ (some trace.toProofData) (some rp)`.
  2. Constructs a `LabeledFormula` with `label = .valid`, `decisionMethod = "proof_first"`, `proofReconstructionMethod = "proof_first_compositional"`, plus the computed fields.
  3. Returns the list of `LabeledFormula`.
- [ ] Define `writeJsonl (records : List LabeledFormula) (path : System.FilePath) : IO Unit` that writes one JSONL line per record (using `toJson` from `LabeledFormula`, mirroring `DatasetExport.lean:872-914`).
- [ ] Define `main : IO Unit` that parses CLI args (`--max-depth N --seed N --atoms "p,q,r" --output PATH`), calls `forwardGenerate cfg`, then `exportToJsonl`, then `writeJsonl`. Match the CLI style of `dataset_generator` (lakefile.lean:38-41).
- [ ] Add a CLI arg parser `parseForwardConfig : List String → IO ForwardConfig` that supports `--max-depth`, `--seed`, `--atoms`, `--output`, `--frame-class {base,dense,discrete}`, `--max-pool-size`, `--layer-uniform`.
- [ ] Add progress logs: `[proof-first] generating pool...`, `[proof-first] pool size: N`, `[proof-first] writing to PATH`.

**Timing**: 1.5 hours

**Depends on**: 6, 7

**Files to create**:
- `Theories/Bimodal/Automation/ProofFirstExporter.lean` — new file, ~200 LOC.

**Verification**:
- Build passes: `lake build Bimodal.Automation.ProofFirstExporter` succeeds.
- Smoke test: `lake exe proof_first_generator -- --max-depth 1 --seed 50 --atoms "p,q,r" --output /tmp/test.jsonl` produces a JSONL file with ≥ 50 records, each with `decisionMethod = "proof_first"` and `label = "valid"`.
- Round-trip test: every record in the JSONL can be parsed back into a `LabeledFormula` (using the existing `LabeledFormula.fromJson` if available, or `Json.parse`).

### Phase 9: ProofFirstBenchmark — 8 Cross-Corpus Metrics [COMPLETED]

**Goal**: Create the new file `Theories/Bimodal/Automation/ProofFirstBenchmark.lean` that computes the 8 cross-corpus metrics from research Section 9.2 over a `List LabeledFormula`, plus a comparison function between exhaustive and proof-first corpora.

**Tasks**:
- [ ] Create `Theories/Bimodal/Automation/ProofFirstBenchmark.lean` with imports: `Bimodal.Automation.DatasetGenerator`, `Bimodal.Automation.DataExport`, `Bimodal.Metalogic.Decidability.TraceCertificate`.
- [ ] Define `structure CorpusMetrics where axiomDiversity : Float; proofDepthHistogram : List (Nat × Nat); temporalAxiomUsage : Float; modalAxiomUsage : Float; ruleProfileDistribution : Std.HashMap String Nat; exFalsoDominance : Float; operatorDiversity : Float; generationCostMs : Nat; totalTheorems : Nat; totalAxiomApplications : Nat`, deriving `Inhabited, Repr`.
- [ ] Define `axiom_diversity : List LabeledFormula → Float` as `Σ (unique axiom names) / Σ (total axiom applications)`.
- [ ] Define `proof_depth_distribution : List LabeledFormula → List (Nat × Nat)` as a histogram of `proofTrace.height`.
- [ ] Define `temporal_axiom_usage : List LabeledFormula → Float` as `(proofs using BX axioms) / total`.
- [ ] Define `modal_axiom_usage : List LabeledFormula → Float` as `(proofs using modal_t/4/B/5/K) / total`.
- [ ] Define `rule_profile_distribution : List LabeledFormula → Std.HashMap String Nat` aggregating `ruleProfile.*Count` fields.
- [ ] Define `ex_falso_dominance : List LabeledFormula → Float` as `(proofs with ex_falso axiom) / (proofs with label=valid)`.
- [ ] Define `operator_diversity : List LabeledFormula → Float` as `(distinct GoalCategory values) / 7` (per `SuccessPatterns.lean:76`).
- [ ] Define `computeCorpusMetrics : List LabeledFormula → CorpusMetrics` that combines all 8.
- [ ] Define `compareCorpora : String → List LabeledFormula → List LabeledFormula → IO Unit` that computes metrics for both corpora, prints a side-by-side table, and writes a JSON report to `data/comparison-{timestamp}.json`.
- [ ] Add unit tests for each metric with small hand-constructed `LabeledFormula` lists.

**Timing**: 1.5 hours

**Depends on**: 6, 7

**Files to create**:
- `Theories/Bimodal/Automation/ProofFirstBenchmark.lean` — new file, ~200 LOC.

**Verification**:
- Build passes: `lake build Bimodal.Automation.ProofFirstBenchmark` succeeds.
- Unit test: `axiom_diversity` on a corpus with 1 unique axiom and 10 applications returns 0.1.
- Unit test: `ex_falso_dominance` on a corpus with 1 ex_falso proof out of 5 valid returns 0.2.
- Unit test: `compareCorpora` produces a non-empty JSON file with both corpora's metrics.

### Phase 10: CLI Executable in lakefile.lean [COMPLETED]

**Goal**: Register the new `proof_first_generator` executable in `lakefile.lean`, following the pattern of `dataset_generator` (lakefile.lean:38-41) and `trace_exporter` (lakefile.lean:102-104).

**Tasks**:
- [ ] Add `lean_exe proof_first_generator` to `lakefile.lean` after the `trace_exporter` block (line 104):
  ```lean
  /-- Proof-first generator: forward-chains from axioms, emits JSONL theorems (Task 279).
      Run with: lake exe proof_first_generator -- --max-depth 2 --seed 1000 --output data/proof_first.jsonl -/
  lean_exe proof_first_generator where
    root := `Bimodal.Automation.ProofFirstExporter
    srcDir := "Theories"
    supportInterpreter := true
  ```
- [ ] Verify `lake exe proof_first_generator --help` (or just running with no args) prints usage info.
- [ ] Add a smoke test in the test suite that invokes the executable with minimal args and asserts the JSONL output is non-empty.

**Timing**: 0.5 hours

**Depends on**: 8

**Files to modify**:
- `lakefile.lean` — add 6 LOC after line 104.

**Verification**:
- `lake build` succeeds.
- `lake exe proof_first_generator -- --max-depth 1 --seed 10 --atoms "p" --output /tmp/pf.jsonl` produces a non-empty JSONL.
- `which proof_first_generator` (via `lake exe`) shows the executable is registered.

### Phase 11: Integration Tests in BimodalTest/ [COMPLETED]

**Goal**: Create the new test file `Tests/BimodalTest/Automation/ProofFirstTests.lean` that exercises the end-to-end flow: `forwardGenerate → exportToJsonl → computeCorpusMetrics → compareCorpora`. This is the regression-net phase that catches integration bugs across the new modules.

**Tasks**:
- [ ] Create `Tests/BimodalTest/Automation/ProofFirstTests.lean` with imports for the new modules.
- [ ] Test 1 — `test_axiom_instantiation_covers_all_42_schemata`: for each of the 42 `Axiom` constructors, `instantiateAxiomWithProof` returns a valid witness.
- [ ] Test 2 — `test_pool_dedup_shortest_wins`: add the same formula with two different proofs (heights 5 and 2); the stored proof is the one with height 2.
- [ ] Test 3 — `test_mp_closure_via_implication_index`: with 5 implications and 5 antecedents in the pool, MP produces all valid conclusions in O(n) time (assert by comparing to brute-force O(n^2) result).
- [ ] Test 4 — `test_ex_falso_cap`: with `exFalsoCap = 1, exFalsoDenom = 5`, the ex_falso fraction in the output is ≤ 0.2.
- [ ] Test 5 — `test_no_weakening_in_output`: pattern match on every `DerivationTree` in the output and assert no `.weakening` nodes.
- [ ] Test 6 — `test_frame_class_filtering`: with `frameClass = .Base`, no `density` axioms appear in the output; with `frameClass = .Dense`, they do.
- [ ] Test 7 — `test_forward_generation_produces_valid_theorems`: for a small `forwardGenerate` run (10 seeds, depth 1), every output formula's proof `d : DerivationTree fc [] φ` passes `extractProofTrace` and `walkDerivationTree` without error.
- [ ] Test 8 — `test_label_formula_proof_first_dispatch`: call `labelFormula φ .Base 1000 .proofFirst (some pool)`; verify `decisionMethod = "proof_first"`.
- [ ] Test 9 — `test_label_formula_hybrid_mode`: call `labelFormula φ .Base 1000 .hybrid (some pool)`; verify behavior is consistent (proof-first hit or exhaustive fallback).
- [ ] Test 10 — `test_corpus_metrics_known_values`: hand-build a `LabeledFormula` list with known properties (1 unique axiom, 3 applications, 1 ex_falso out of 5 valid) and verify `computeCorpusMetrics` returns the expected fractions.
- [ ] Test 11 — `test_compare_corpora_writes_json`: run `compareCorpora` on two small corpora and verify the output JSON file is created and parseable.
- [ ] Test 12 — `test_end_to_end_cli_smoke`: invoke `lake exe proof_first_generator` with minimal args via `IO.Process.spawn` (or skip if too complex; defer to manual smoke test).

**Timing**: 2 hours

**Depends on**: 8, 9, 10

**Files to create**:
- `Tests/BimodalTest/Automation/ProofFirstTests.lean` — new file, ~250 LOC.

**Verification**:
- `lake test` (or `lake build BimodalTest && lake env lean Tests/BimodalTest/Automation/ProofFirstTests.lean`) passes all 12 tests.
- No regressions: `lake build` still succeeds for all existing test files.

### Phase 12: Side-by-Side Comparison Report [COMPLETED]

**Goal**: Generate a markdown report (`specs/279_backward_proof_generation/summaries/01_proof_first_vs_exhaustive.md`) that quantifies the gains of the forward-chaining approach vs. the existing exhaustive enumeration, using the 8 cross-corpus metrics from Phase 9. This is the deliverable that closes the loop on task requirement #6 (compare output quality).

**Tasks**:
- [ ] Create the `specs/279_backward_proof_generation/summaries/` directory (per the lazy-creation guardrail, only when writing this artifact).
- [ ] Run the existing `lake exe dataset_generator` on `c4, modal 2, temporal 2, atoms 3` → produces `data/exhaustive_c4.jsonl`.
- [ ] Run the new `lake exe proof_first_generator` on `maxDepth 2, seed 500, atoms [p, q, r]` → produces `data/proof_first_d2.jsonl`.
- [ ] Run `compareCorpora` on both files → produces `data/comparison-{timestamp}.json` and prints a side-by-side table.
- [ ] Author the markdown report with:
  1. **Setup**: configuration used for both runs (max complexity, atom pool, time budget).
  2. **Per-metric table**: 8 rows (axiom diversity, proof depth distribution, temporal axiom usage, modal axiom usage, rule profile distribution, ex_falso dominance, operator diversity, generation cost), 3 columns (exhaustive, proof-first, interpretation).
  3. **Headline result**: valid-formula throughput ratio (proof-first / exhaustive) and 100% valid rate.
  4. **Failure modes**: any cases where proof-first is worse (e.g., lower coverage of certain axiom layers).
  5. **Recommendations**: which mode to use for which task (e.g., proof-first for ML training, exhaustive for completeness benchmarks).
  6. **Next steps**: round 2 features (hybrid + tableau trace, full DerivationTree JSON serialization, larger depth).
- [ ] Cross-link the report with task 277's `TraceCertificate` deliverable (for hybrid mode round 2) and task 283's explosion analysis (for context on why this matters).

**Timing**: 1.5 hours

**Depends on**: 8, 9, 10

**Files to create**:
- `specs/279_backward_proof_generation/summaries/01_proof_first_vs_exhaustive.md` — new file, ~150 lines.

**Verification**:
- Report exists at the expected path and is non-empty.
- All 8 metrics are present in the table with non-null values.
- The headline result is consistent with the research report's projection (~37x improvement in valid-formula throughput).
- The report cross-references the existing data files (`data/exhaustive_c4.jsonl`, `data/proof_first_d2.jsonl`, `data/comparison-*.json`).

## Testing & Validation

End-to-end validation strategy across all phases:

- [ ] **Unit tests per phase**: each phase ships with its own unit tests (see Verification sections).
- [ ] **Build passes**: `lake build` succeeds after each phase.
- [ ] **Existing test suite still passes**: `lake test` (or `lake build BimodalTest`) shows no regressions in pre-existing test files.
- [ ] **Soundness property**: every `(φ, d)` in the forward generator's output has `d : DerivationTree fc [] φ` (type-check enforced). No runtime verifier needed.
- [ ] **Dedup invariant**: every formula appears at most once in the pool (HashSet invariant).
- [ ] **Ex_falso cap invariant**: ex_falso fraction ≤ `exFalsoCap / exFalsoDenom` in the output.
- [ ] **No-weakening invariant**: no `DerivationTree.weakening` nodes in the output (pattern-match check).
- [ ] **Frame class invariant**: every output proof is valid at the requested `FrameClass` (decidable via `Axiom.minFrameClass ≤ fc`).
- [ ] **End-to-end CLI smoke**: `lake exe proof_first_generator -- --max-depth 1 --seed 10 --output /tmp/test.jsonl` produces a parseable JSONL.
- [ ] **Comparison report**: 8 cross-corpus metrics in the report show proof-first ≥ exhaustive on the relevant axes (axiom diversity, temporal axiom usage, ex_falso dominance, valid rate) and proof-first ≤ exhaustive on generation cost.

## Artifacts & Outputs

New files:
- `Theories/Bimodal/Automation/ForwardProofGenerator.lean` (~470 LOC: config, pool, instantiation, MP closure, unary rules, fixpoint loop)
- `Theories/Bimodal/Automation/ProofFirstExporter.lean` (~200 LOC: JSONL export, CLI main)
- `Theories/Bimodal/Automation/ProofFirstBenchmark.lean` (~200 LOC: 8 metrics, comparison)
- `Tests/BimodalTest/Automation/ProofFirstTests.lean` (~250 LOC: 12 integration tests)
- `specs/279_backward_proof_generation/plans/01_proof_first_generation.md` (this file)
- `specs/279_backward_proof_generation/summaries/01_proof_first_vs_exhaustive.md` (Phase 12 deliverable)

Modified files:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` (+~120 LOC: `instantiateAxiomWithWitness` covering 42 schemata)
- `Theories/Bimodal/Automation/DatasetGenerator.lean` (+~55 LOC: `GenerationMode` inductive, `labelFormulaProofFirst`, modified `labelFormula` signature)
- `lakefile.lean` (+~6 LOC: `lean_exe proof_first_generator`)

Generated data files (not committed):
- `data/exhaustive_c4.jsonl` (exhaustive baseline for comparison)
- `data/proof_first_d2.jsonl` (forward generator output)
- `data/comparison-{timestamp}.json` (side-by-side metrics)

Total: ~1295 LOC new + 180 LOC modified = ~1475 LOC, achievable in 20 hours.

## Rollback/Contingency

If the implementation fails or produces unsatisfactory results:

1. **Phase-by-phase rollback**: each phase is independently revertible. Reverting Phase 7 (the `DatasetGenerator.lean` modification) restores the existing `labelFormula` signature. Reverting Phase 10 removes the CLI executable. Phases 1-6 are additive (new functions) and do not modify existing call sites, so they can be left in place even if downstream phases are reverted.

2. **Backwards compatibility**: the default `mode = .exhaustive` in the modified `labelFormula` ensures all existing call sites behave unchanged. Even if `proofFirst` mode is buggy, the existing pipeline continues to work.

3. **Branch isolation**: this work should be on a feature branch (`feature/279-proof-first-generation`) and merged only after the Phase 12 comparison report validates the gains. If the gains are insufficient, the branch can be abandoned without affecting main.

4. **Fallback plan if `forwardGenerate` performance is poor**: reduce defaults (`seedCount = 500`, `maxDepth = 2`, `maxPoolSize = 5000`) to bound runtime. The research report's 37x improvement projection is for the default configuration; lower bounds still produce gains over exhaustive enumeration.

5. **Fallback plan if frame class typing is intractable**: restrict the forward generator to `FrameClass.Base` only; provide a `liftToFrameClass : ForwardConfig → FrameClass → IO (List ...)` post-processor using `DerivationTree.lift` (Derivation.lean:190). This is research finding #7's alternative and does not require runtime `decide` calls.
