# Teammate A Findings (Round 2): Integration with Refactored ModelChecker Oracle

**Task**: 226 — Build standalone Z3 countermodel generator for negative training signal
**Date**: 2026-05-30
**Angle**: What BimodalLogic needs now that ModelChecker is being refactored externally
**Confidence Level**: High

## Key Findings

### 1. Task 226 Scope Should Shift to "Integration + Enrichment + Soundness"

With ModelChecker tasks 99-105 handling the oracle itself, task 226 in BimodalLogic becomes:

| Component | Location | Purpose |
|---|---|---|
| Oracle package | ModelChecker (external) | Z3 countermodel finding |
| Integration scripts | BimodalLogic `scripts/` | Batch enrichment of JSONL datasets |
| Conformance tests | BimodalLogic `scripts/` or `tests/` | Validate oracle agrees with Lean |
| Soundness formalization | BimodalLogic `Theories/` | Lean proof: bounded models are sound |
| Requirements file | BimodalLogic root | Dev dependency on bmlogic-oracle |

### 2. Existing Dataset Infrastructure Is Ready for Enrichment

The dataset pipeline is mature:

- **`data/bmlogic-c5.jsonl`**: 1,513 formulas (1,397 invalid with SimpleCountermodels, 64 valid, 52 timeout)
- **`data/bmlogic-c7.jsonl`**: 49,904 formulas (46,717 invalid with SimpleCountermodels, 1,687 valid, 1,500 timeout)
- **Schema**: 14-field training format with `countermodel` field already present (currently atom-only: `{trueAtoms, falseAtoms, formula}`)
- **Validation**: `scripts/validate_datasets.py` enforces field schema consistency
- **Metadata**: `data/bmlogic-c5_metadata.json` and `bmlogic-c7_metadata.json` track record counts

The `countermodel` field can be extended or a new `structured_countermodel` field added alongside the existing one.

### 3. Formula JSON Format Is Already Standardized

`DataExport.lean` (lines 104-116) defines the canonical JSON format:
```
atom → {"tag": "atom", "name": "<base>"}
bot  → {"tag": "bot"}
imp  → {"tag": "imp", "left": <φ>, "right": <ψ>}
box  → {"tag": "box", "child": <φ>}
untl → {"tag": "untl", "event": <φ>, "guard": <ψ>}
snce → {"tag": "snce", "event": <φ>, "guard": <ψ>}
```

ModelChecker task 102 implements `json_to_sentence()` translating this exact format to ModelChecker internals. No changes needed on the BimodalLogic side.

### 4. BimodalLogic Needs a Minimal Integration Layer

What's needed in THIS repo:

**a) `requirements-oracle.txt`** (or section in a future pyproject.toml):
```
bmlogic-oracle>=0.1.0  # Refactored ModelChecker
```

**b) `scripts/enrich_countermodels.py`** — Batch enrichment script:
```python
"""Enrich JSONL datasets with StructuredCountermodels from bmlogic-oracle."""
# For each invalid formula in c5/c7:
#   1. Parse formula_ast field (already in 6-tag JSON)
#   2. Call oracle.find_countermodel(formula_ast, frame_class="Base")
#   3. If result: add 'structured_countermodel' field to record
#   4. Write enriched JSONL
```

**c) `scripts/validate_oracle_conformance.py`** — Cross-validation:
```python
"""Validate oracle agrees with Lean tableau on known formulas."""
# For invalid formulas: oracle SHOULD find countermodel
# For valid formulas: oracle MUST NOT find countermodel (soundness)
# For timeout formulas: oracle MAY resolve some (pure gain)
```

### 5. The Conformance Testing Opportunity Is Large

The dataset provides a massive conformance suite:
- **Soundness check**: 1,687 + 64 = 1,751 known-valid formulas → oracle must return None
- **Completeness check**: 48,114 known-invalid formulas → oracle should find countermodels for high %
- **Coverage gain**: 1,552 timeout formulas → oracle may resolve (adds to training data)

This is far beyond typical test suites. Any soundness violation (oracle claims countermodel for a valid formula) is a critical bug.

### 6. Lean Soundness Formalization: Finite Bounded Model Theorem

The sorry-free FMP in `Theories/Bimodal/Metalogic/Decidability/FMP/` proves:
```
finite_model_property: ¬valid(φ) → ∃ finite model falsifying φ
```

The metalogic opportunity for task 226 is a complementary theorem:

```lean
theorem bounded_model_soundness (N M : Nat) (φ : Formula)
    (F : TaskFrame Int) [Fintype F.WorldState]
    (hN : Fintype.card F.WorldState ≤ 2^N)
    (histories : Fin K → WorldHistory F)
    (hK : K ≤ N^M)
    (hOmega : ShiftClosed (Set.range histories))
    (τ : WorldHistory F) (t : Int) (ht : -M < t ∧ t < M)
    (h_false : ¬ truth_at M (Set.range histories) τ t φ) :
    ¬ valid φ := by
  -- Any model that falsifies φ proves ¬valid(φ), regardless of size
  exact not_valid_of_not_truth_at ...
```

This is actually straightforward: "if there exists ANY model (finite or infinite) where φ is false, then φ is not valid" is the definition of invalidity. The real work is showing that the Z3 finite model IS a valid TaskFrame — i.e., that the finite structure with nullity_identity, forward_comp, converse constraints satisfied constitutes a legal `TaskFrame Int`.

The key lemma:
```lean
theorem finite_task_frame_valid (N M : Nat)
    (WorldState : Type) [Fintype WorldState] [DecidableEq WorldState]
    (task_rel : WorldState → Int → WorldState → Prop)
    (h_null : ∀ w u, task_rel w 0 u ↔ w = u)
    (h_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v)
    (h_conv : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w) :
    TaskFrame Int where
  WorldState := WorldState
  task_rel := task_rel
  nullity_identity := h_null
  forward_comp := h_comp
  converse := h_conv
```

This is trivial — a finite type satisfying the axioms IS a TaskFrame by definition. The soundness theorem then follows automatically. The Lean formalization is ~50 lines, not hundreds.

### 7. StructuredCountermodel Schema for Enrichment

The enriched output format (added alongside existing `countermodel` field):

```json
{
  "structured_countermodel": {
    "world_count": 2,
    "time_bound": 2,
    "world_states": [0, 1, 2, 3],
    "time_domain": [-1, 0, 1],
    "world_histories": [
      {"id": 0, "states": {"-1": 0, "0": 1, "1": 2}},
      {"id": 1, "states": {"-1": 1, "0": 0, "1": 3}}
    ],
    "task_relation": [
      [0, 1, 1], [1, -1, 0]
    ],
    "valuation": {"p": [0, 2], "q": [1, 3]},
    "eval_world": 0,
    "eval_time": 0,
    "oracle_provider": "bmlogic_z3_base_v1",
    "solve_time_ms": 42
  }
}
```

This preserves backward compatibility (existing `countermodel` field untouched) while adding semantic-level structure.

## Recommended Approach

### Phase 1: Integration Infrastructure (~3 hours)
- Create `requirements-oracle.txt` with bmlogic-oracle dependency
- Create `scripts/enrich_countermodels.py` batch processing script
- Create `scripts/validate_oracle_conformance.py` cross-validation

### Phase 2: Dataset Enrichment (~5 hours)
- Batch-process 48,114 invalid formulas through oracle
- Add `structured_countermodel` field to enriched records
- Re-validate with updated `validate_datasets.py` (add new schema for enriched field)
- Re-export to HuggingFace dataset

### Phase 3: Lean Soundness Theorem (~5 hours)
- Prove `finite_task_frame_valid`: finite structure satisfying axioms IS a TaskFrame
- Prove `bounded_model_soundness`: countermodel in any model implies invalidity
- This is straightforward (definition-level) and gives a formal certificate

### Phase 4: Timeout Resolution (~3 hours)
- Run oracle on 1,552 timeout formulas
- Resolved invalids → add to training data with structured countermodels
- Resolved valids → update labels (requires cross-checking with extended tableau runs)

## Evidence/Examples

- `data/bmlogic-c5.jsonl`: 14-field schema with `countermodel` field already present
- `scripts/validate_datasets.py`: Schema enforcement exists and can be extended
- `DataExport.lean:104-116`: Formula JSON format matches ModelChecker task 102's target
- `FMP/FMP.lean`: Sorry-free finite model property proves finite models suffice
- `FMP/FiniteModel.lean`: FilteredWorld.finite gives bounded cardinality
- `CountermodelExtraction.lean:47-54`: SimpleCountermodel structure (atoms only)
- `EnrichedCountermodel.lean:63-69`: EnrichedCountermodel adds branch info but still no semantic structure
- `DatasetValidator.lean`: Lean-side conformance infrastructure exists

## Confidence Level

**High** — The infrastructure is mature. The dataset format is standardized. The formula JSON schema matches what ModelChecker task 102 will implement. The Lean soundness theorem is definitionally simple. The main risk is performance of the oracle on 48K+ formulas (addressed by ModelChecker tasks 97-98 on Z3 optimization).
