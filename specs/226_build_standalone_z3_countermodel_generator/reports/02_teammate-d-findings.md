# Teammate D (Horizons) Findings: Round 2 — Scope Redefinition

**Task**: 226 — Build standalone Z3 countermodel generator for negative training signal
**Date**: 2026-05-30
**Focus**: Redefining task 226 given oracle development moved to ModelChecker repo

## Key Findings

### 1. Task 226 Must Be Redefined: Oracle Is External, Integration Is Local

The ModelChecker tasks 99-105 create a complete pipeline:
- Task 99: Refactor audit (file-by-file map)
- Task 100: Strip non-bimodal code
- Task 101: Restructure as pip-installable package with entry-point
- Task 102: Formula JSON translation layer (6-tag format ↔ internal Sentence)
- Task 103: OracleProvider implementation + countermodel serialization
- Task 104: Programmatic API cleanup
- Task 105: Integration testing

This means task 226 in BimodalLogic is NO LONGER about implementing Z3 constraints. It becomes:

**Option D (phased)** — recommended scope:
1. **Integration script**: Consume the oracle to enrich existing JSONL datasets
2. **Conformance test**: Verify oracle output matches Lean tableau classifications
3. **Lean soundness formalization**: Prove bounded finite models are genuine countermodels

### 2. Dataset Enrichment Is High-Leverage (48,114 Invalid Formulas)

Current dataset statistics:
| Dataset | Valid | Invalid (with atom-only CM) | Timeout | Total |
|---------|-------|----------------------------|---------|-------|
| bmlogic-c5 | 64 | 1,397 (1,397) | 52 | 1,513 |
| bmlogic-c7 | 1,687 | 46,717 (46,717) | 1,500 | 49,904 |
| bmlogic-bench | ~350 valid | ~377 invalid | ~0 | 727 |

**All 48,114 invalid formulas** currently have only `SimpleCountermodel` (trueAtoms/falseAtoms). The oracle enriches these with world histories, task relations, evaluation points — enabling graph-based training signals (GNNs).

**Additionally**: 1,552 timeout formulas might be resolvable by Z3 (different search strategy than the Lean tableau). These are currently uncategorized noise in the dataset.

### 3. Existing Infrastructure Makes Integration Straightforward

BimodalLogic already has:
- `scripts/generate_dataset.py`: Converts JSONL → PyTorch tensors (5-dim PatternKey features)
- `scripts/validate_datasets.py`, `validate_benchmark.py`: Dataset validation
- `data/bmlogic-c5.jsonl`, `data/bmlogic-c7.jsonl`: Standard JSONL schema with `formula_ast` field (matches oracle's `formula_json` input)
- `Theories/Bimodal/Automation/EnrichedCountermodel.lean`: Already extracts enriched branch info from Lean tableau
- `Theories/Bimodal/Automation/DataExport.lean`: Formula.toJson already defined
- `Theories/Bimodal/Semantics/TaskFrame.lean:284-300`: `FiniteTaskFrame` already defined (extends TaskFrame with `finite_world : Finite WorldState`)

The integration script would be ~100-200 lines:
```python
# scripts/enrich_countermodels.py
# For each invalid formula in JSONL:
#   1. Call oracle.find_countermodel(formula_ast, "Base")
#   2. If result, add "structured_countermodel" field to JSONL entry
#   3. Write enriched JSONL
```

### 4. Lean Soundness Formalization Is Achievable (but Medium Effort)

The key insight: `FiniteTaskFrame` already exists at line 284 of TaskFrame.lean. The soundness proof would show:

```lean
theorem bounded_model_sound (N M : Nat) (φ : Formula)
    (F : FiniteTaskFrame Int)  -- Z3 produces this
    (h_world_bound : Fintype.card F.WorldState ≤ N)
    (model : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame)
    (t : Int)
    (h_time_bound : |t| ≤ M)
    (h_false : ¬ truth_at model Set.univ τ t φ) :
    ¬ valid φ := by
  -- A FiniteTaskFrame IS a TaskFrame (coercion exists)
  -- truth_at on the finite model IS truth_at on the general model
  -- If φ is false somewhere, it's not valid
  exact not_valid_of_countermodel ⟨F.toTaskFrame, model, Set.univ, τ, t, h_false⟩
```

This is actually **quite short** because:
- `FiniteTaskFrame` coerces to `TaskFrame` (line 297)
- `truth_at` doesn't care about finiteness — it works on any `TaskFrame D`
- Validity means "true in ALL models" — one counterexample suffices

The harder part is proving the Z3 output constitutes a valid `FiniteTaskFrame` + `WorldHistory` pair:
- Frame axioms (nullity_identity, forward_comp, converse) need to hold
- `WorldHistory.respects_task` must hold for extracted histories
- Domain convexity must hold

Estimate: ~200-400 lines of Lean for the full certification, because `FiniteTaskFrame` already has the right structure and the coercion to `TaskFrame` gives all existing theorems for free.

### 5. Cross-Repository Dependency Order

```
ModelChecker tasks 99-105 (produces pip-installable oracle)
    ↓ pip install
BimodalLogic task 226 (consumes oracle, enriches datasets)
    ↓ enriched JSONL
BimodalHarness (imports oracle via entry-points, uses for MCTS training)
```

Task 226 BLOCKS ON ModelChecker tasks 101 + 103 (pip-installable + OracleProvider). It does NOT need tasks 104-105 (cleanup and validation are nice-to-have but not required for consumption).

**Minimum dependency**: ModelChecker task 103 (OracleProvider impl) must produce a working `find_countermodel(formula_json) -> dict | None`.

### 6. Recommendation: Split Task 226 Into 3 Phases (Not Separate Tasks)

Given the scope change, task 226 should be **re-described but not expanded** into separate task numbers. Three implementation phases within one task:

**Phase 1 — Oracle Integration Script (~4 hours)**
- `scripts/enrich_countermodels.py`: Batch-process JSONL through oracle
- Requirements: `pip install` the refactored ModelChecker
- Output: Enriched JSONL with `structured_countermodel` field
- Cross-validation: Oracle results vs Lean tableau labels must agree

**Phase 2 — Conformance Test Suite (~4 hours)**
- `scripts/test_oracle_conformance.py`: Verify oracle agrees with Lean tableau on all 48,114 classified formulas
- Regression testing: Any mismatch means either oracle or tableau has a bug
- Timeout resolution: Attempt oracle on 1,552 timeout formulas, report findings

**Phase 3 — Lean Bounded Model Soundness (~12 hours)**
- `Theories/Bimodal/Metalogic/Soundness/OracleSoundness.lean`: Formal proof
- Leverages existing `FiniteTaskFrame` and coercion to `TaskFrame`
- Theorem: if a formula is false in a bounded FiniteTaskFrame model, it's not valid
- This gives a **certified oracle**: the Python code need not be trusted

### 7. Strategic Value: Certified Negative Signal Is a Novel Contribution

No existing LLM training pipeline for formal reasoning has a **formally certified negative signal**. The combination of:
1. Lean FMP theorem (sorry-free) — guarantees finite countermodels exist
2. Z3 oracle — efficiently finds finite countermodels
3. Lean soundness theorem — certifies each oracle output is genuine

...means BimodalLogic would have **certified training labels** for invalid formulas — a unique selling point for the dataset. This is worth advertising in the paper/dataset card.

## Recommended Approach

1. **Update task 226 description** to reflect the new scope (consume external oracle, not build one)
2. **Block on ModelChecker task 103** — don't start until pip-installable oracle exists
3. **Implement in 3 phases** within the single task:
   - Phase 1: Integration script (depends on ModelChecker 103)
   - Phase 2: Conformance testing (can start as soon as oracle is callable)
   - Phase 3: Lean soundness formalization (independent of Python work)
4. **Phase 3 can start immediately** — the Lean proof doesn't need the actual oracle, just the semantic framework (which already exists: `FiniteTaskFrame`, `truth_at`, `valid`)

## Evidence/Examples

| Finding | Source | Reference |
|---------|--------|-----------|
| FiniteTaskFrame already defined | TaskFrame.lean | Lines 284-300 |
| Coercion to TaskFrame | TaskFrame.lean | Line 297 |
| fmp_completeness sorry-free | Correctness.lean | Line 100 |
| Formula.toJson schema | DataExport.lean | Existing |
| EnrichedCountermodel structure | EnrichedCountermodel.lean | Lines 1-39 |
| 48,114 invalid formulas with atom-only CM | data/bmlogic-c5.jsonl + c7.jsonl | Counted |
| 1,552 timeout formulas | data/bmlogic-c5.jsonl + c7.jsonl | Counted |
| OracleProvider protocol exists | BimodalHarness oracle/protocol.py | Full implementation |
| ModelChecker pyproject.toml | code/pyproject.toml | GPL-3.0, entry-points TBD |

## Confidence Level

**High** — The architectural picture is clear. The scope change simplifies task 226 considerably (from ~1000 lines of Z3 encoding to ~300 lines of integration scripts + ~300 lines of Lean formalization). The main uncertainty is timeline dependency on ModelChecker tasks 99-105 completing first. Phase 3 (Lean soundness) can proceed independently and is a novel contribution regardless of the oracle's implementation details.
