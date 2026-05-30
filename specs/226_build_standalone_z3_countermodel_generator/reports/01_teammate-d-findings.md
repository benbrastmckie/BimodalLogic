# Teammate D (Horizons) Findings: Task #226

**Focus**: Strategic alignment, cross-repository architecture, novel opportunities

## Key Findings

### 1. The "Negative Training Signal" Has Two Distinct Functions

The BimodalHarness architecture reveals that a countermodel oracle serves **two fundamentally different purposes** in the training pipeline:

1. **Value network training signal**: When MCTS explores a formula and encounters an invalid sub-goal, the countermodel provides a *ground-truth negative label* — proving that no proof exists. This trains the value network to predict "dead ends" before wasting search budget. (See BimodalHarness `record_training_signals` in MCTS config.)

2. **Dataset enrichment**: The existing dataset has 46,717 invalid formulas in c7 alone, but their countermodels are **atom-level only** (`trueAtoms`/`falseAtoms`). A Z3 oracle generating *full task-frame countermodels* (world histories, task relations, temporal structure) would provide richer corrective signal — the value network could learn *why* a formula fails, not just *that* it fails.

These are different use cases with different performance requirements. Purpose (1) needs online, sub-second responses during MCTS rollout. Purpose (2) is offline batch generation with no latency constraints.

### 2. Co-location with BimodalLogic Is Strategically Correct

**Why here rather than BimodalHarness?**

- **Lean semantics proximity**: The Z3 encoding must be faithful to `truth_at` in `Theories/Bimodal/Semantics/Truth.lean`. Co-location enables Lean-level soundness proofs (Z3 encoding implies Lean semantics).
- **Dataset generation integration**: BimodalLogic already has `DatasetGenerator.lean`, `DatasetExporter.lean`, `EnrichedCountermodel.lean` — the full pipeline from formula enumeration to JSONL export. A Z3 oracle integrated here can enrich these exports directly.
- **1,500 timeout formulas**: The current decision procedure times out on 3% of formulas (mostly valid, but some may be invalid). A Z3 oracle can resolve the invalid subset, reducing dataset noise.
- **License independence**: BimodalLogic is MIT; co-located Python/Z3 code remains MIT. ModelChecker is GPL-3.0.

**The BimodalHarness task 19 research (Round 5)** already converged on an `OracleProvider` protocol with entry-point discovery. This task can implement the oracle *here* and register it as a plugin for BimodalHarness via `pyproject.toml` entry points — best of both worlds.

### 3. Completeness Does NOT Make Countermodel Generation Redundant

Critical architectural insight: even after `completeness_discrete` is sorry-free, the completeness theorem says:
```
theorem completeness : valid φ → Nonempty (DerivationTree FrameClass.Base [] φ)
```

This gives existence but NOT a constructive algorithm efficient enough for training. The Lean tableau's `decideAuto` already times out on 1,500 formulas at complexity 7. Z3 uses fundamentally different search strategies (DPLL(T), theory propagation) that handle quantifier-rich constraints the tableau cannot.

Moreover, the completeness proof constructs canonical *infinite* models (over ℚ or ℤ). A Z3 oracle gives *finite* countermodels directly — more useful for GNN encoding and tensor computation in BimodalHarness.

### 4. The "Enriched Countermodel" Gap Is a Concrete Opportunity

The codebase already has `EnrichedCountermodel.lean` (task 201 Phase 4) which extracts full branch content (modal formulas, temporal formulas, branch length) from the tableau. But this is still propositional-level — it doesn't produce world histories or task relations.

The Z3 oracle can generate **StructuredCountermodel** objects with:
- `world_histories`: Actual functions from times to states
- `task_relation`: Ternary relation `task_rel(w, d, u)`
- `truth_valuation`: Which atoms hold at which states
- `evaluation_point`: The (history, time) where the formula fails

This is the semantic-level countermodel that enables GNN/graph-based encodings in BimodalHarness (task 20 in that repo).

### 5. Sound Incompleteness Is a Feature, Not a Bug

The task description flags "Z3 implementation need not be complete if there is an advantage to efficiency." This is correct and the advantage is real:

- **Bounded model checking**: Z3 searches over N worlds × M time steps. A formula invalid at (N=2, M=2) gets a fast countermodel. A formula only invalid at (N=5, M=5) takes much longer. Setting bounds makes the search space decidable.
- **Incompleteness = false negatives only**: A sound oracle never reports a false countermodel. It may fail to find a countermodel for some invalid formulas (returns None). This is the safe direction for training — you never feed the network a wrong label.
- **Progressive deepening**: Run at (N=2, M=2) first (~ms), then (N=3, M=3) if needed (~100ms), escalate to (N=4, M=4) only for hard cases (~seconds). Most countermodels are small.

### 6. Novel Opportunity: Countermodel-Guided Proof Debugging

Once the Z3 oracle works, it can:

1. **Validate the proof system**: For every formula the proof system claims valid (produces a derivation tree), the oracle should fail to find a countermodel. If it finds one, either the proof system is unsound or the oracle is wrong — either way, it's a bug.

2. **Debug completeness gaps**: For the 1,500 timeout formulas, run the oracle. If it finds countermodels → they're invalid (adds to negative training data). If it doesn't → they're likely valid but the proof search needs more fuel/different strategy.

3. **Generate adversarial training data**: Take valid formulas, apply the `FormulaMutator.lean` mutations, then use the oracle to find which mutations become invalid. This creates (valid → invalid) pairs that teach the network about *subtle semantic boundaries*.

### 7. Minimum Viable Scope Recommendation

Given the project's near-publication state, the Z3 oracle should be:
- **Lean-adjacent but not blocking**: Python package in a `z3_oracle/` or `tools/z3_oracle/` directory, separate from the Lean code
- **Batch-first**: Offline generation to enrich existing JSONL, not online real-time
- **Base frame only**: Dense/Discrete constraints don't exist anywhere yet
- **Sound by construction**: Mirror the 6 constructors of `truth_at` directly
- **Progressive bounds**: N=2,M=2 → N=3,M=3 → N=4,M=4 with timeout per level

**Soundness formalization** (Lean proof that Z3 encoding implies `truth_at`) can be a **separate, later task** — it's valuable but not required for the oracle to be operationally useful. The cross-validation against existing Lean-generated countermodels provides empirical soundness guarantees for now.

## Recommended Approach

**Phase 1 (MVP, ~10 hours)**: Standalone Z3 encoder in `tools/z3_oracle/` with `find_countermodel(formula_json) -> StructuredCountermodel | None`. Register as BimodalHarness `OracleProvider` entry point. Cross-validate against the 376 existing countermodels in bmlogic-bench.

**Phase 2 (Enrichment, ~10 hours)**: Batch-process all 46,717 invalid formulas in c7 (and 1,397 in c5) to generate StructuredCountermodels. Re-export enriched JSONL. Resolve timeout subset.

**Phase 3 (Soundness, ~15 hours)**: Lean formalization that the Z3 encoding implies `truth_at` for bounded models. This gives a certificate: "if Z3 says SAT at (N,M), there exists a genuine TaskFrame countermodel."

## Evidence/Examples

- **Dataset stats**: 93% of formulas are invalid; enriching countermodels is high-leverage
- **1,500 timeouts**: Z3 can likely resolve a subset, reducing dataset noise
- **Existing infrastructure**: `DatasetExporter.lean`, `EnrichedCountermodel.lean`, `formula_ast` JSON schema are all in place
- **BimodalHarness task 19 Round 5**: Already designed the `OracleProvider` protocol — this task implements it
- **FMP theorem** (sorry-free): Guarantees finite countermodels exist for invalid formulas — Z3's bounded search is complete in principle

## Confidence Level

**High** — The strategic alignment is clear: BimodalHarness needs countermodel oracles, BimodalLogic has the semantic specification, co-location enables soundness proofs, and the existing dataset infrastructure makes integration straightforward. The main risk is performance at higher complexity tiers (N≥4, M≥4), which the progressive deepening strategy mitigates.
