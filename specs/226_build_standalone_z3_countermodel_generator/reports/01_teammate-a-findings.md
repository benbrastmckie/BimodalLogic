# Teammate A Findings: Primary Implementation Approach

**Task**: 226 — Build standalone Z3 countermodel generator for negative training signal
**Date**: 2026-05-30
**Angle**: Primary implementation architecture and Z3 encoding strategy
**Confidence Level**: High

## Key Findings

### 1. Repository Architecture: `z3_oracle/` at Project Root

BimodalLogic currently has Python scripts in `scripts/` (dataset generation, validation) and `data/scripts/` (paraphrases, splits). There is no `pyproject.toml`. The recommended placement is:

```
BimodalLogic/
├── z3_oracle/                    # New: standalone Z3 countermodel generator
│   ├── pyproject.toml            # Package metadata, z3-solver dependency
│   ├── src/
│   │   └── bmlogic_oracle/       # Installable package
│   │       ├── __init__.py
│   │       ├── encoding.py       # Z3 constraint encoding (frame + truth)
│   │       ├── formula.py        # Formula AST parsing from JSON
│   │       ├── countermodel.py   # Model extraction to structured format
│   │       ├── oracle.py         # Public API: find_countermodel()
│   │       └── config.py         # N/M bounds, timeout settings
│   ├── tests/
│   │   ├── test_frame_constraints.py
│   │   ├── test_truth_encoding.py
│   │   ├── test_conformance.py   # Cross-validation vs bmlogic-bench.jsonl
│   │   └── conftest.py
│   └── benchmarks/
│       └── perf_scaling.py       # N/M scaling measurements
├── Theories/Bimodal/Semantics/   # Existing Lean semantics (ground truth)
├── data/bmlogic-bench.jsonl      # Existing: formulas with countermodels
└── scripts/                      # Existing Python scripts
```

**Rationale**: 
- Colocation enables Lean metalogic to reference the Z3 encoding directly
- Separate `z3_oracle/` directory keeps it cleanly separated from the Lean project
- `src/` layout enables pip-installable package for BimodalHarness consumption

### 2. Z3 Encoding Strategy (Extracted from ModelChecker Analysis)

The ModelChecker's `semantic.py` (lines 139-697) provides a proven encoding that directly aligns with the Lean `TaskFrame` structure. The standalone version can strip ~70% of ModelChecker code (witness predicates, interactive display, model iteration, CVC5 backend, multiple solver adapters).

#### 2.1 Sorts and Primitives

```python
# Minimal sort definitions (from semantic.py:139-150)
WorldStateSort = z3.BitVecSort(N)   # 2^N possible world states
TimeSort = z3.IntSort()             # Bounded integer time [-M, M]

# Core primitives
task_rel = z3.Function("TaskRel", WorldStateSort, IntSort(), WorldStateSort, BoolSort())
world_function = z3.Function("world_function", IntSort(), ArraySort(TimeSort, WorldStateSort))
is_world = z3.Function("is_world", IntSort(), BoolSort())
truth_condition = z3.Function("truth_condition", WorldStateSort, AtomSort, BoolSort())
```

#### 2.2 Frame Constraints (Direct Lean Alignment)

| Lean Axiom | Z3 Encoding | ModelChecker Reference |
|---|---|---|
| `nullity_identity` | `ForAll([w,u], task_rel(w,0,u) == (w==u))` | `build_nullity_identity_constraint()` line 274 |
| `forward_comp` | `ForAll([w,v,u,d1,d2], Implies(And(task_rel(w,d1,v), task_rel(v,d2,u), guards), task_rel(w,d1+d2,u)))` | `build_forward_comp_constraint()` line 338 |
| `converse` | `ForAll([w,u,d], Implies(valid(d), task_rel(w,d,u) == task_rel(u,-d,w)))` | `build_converse_constraint()` line 299 |

Additional constraints needed for well-formed models:
- **Lawful evolution**: Consecutive states in a world history respect task_rel with duration 1 (line 556)
- **World enumeration**: World IDs are non-negative and contiguous (lines 517-544)
- **Abundance/shift-closure**: Time-shifted copies exist (line 604) — critical for box/temporal interaction
- **World interval**: Each world has a convex time domain [start, end] (line 552)

#### 2.3 Formula Truth Encoding (6 Constructors)

Direct recursive encoding matching `truth_at` from Truth.lean:122-131:

```python
def encode_truth(formula_json, world_id, time, semantics):
    tag = formula_json["tag"]
    if tag == "atom":
        state = z3.Select(world_function(world_id), time)
        return truth_condition(state, atom_const(formula_json["name"]))
    elif tag == "bot":
        return z3.BoolVal(False)
    elif tag == "imp":
        left = encode_truth(formula_json["left"], world_id, time, semantics)
        right = encode_truth(formula_json["right"], world_id, time, semantics)
        return z3.Implies(left, right)
    elif tag == "box":
        # ForAll valid world histories σ, truth at σ
        w = z3.Int('box_w')
        return z3.ForAll([w], z3.Implies(is_world(w), 
            encode_truth(formula_json["child"], w, time, semantics)))
    elif tag == "untl":
        # Exists s > t: event(s) AND ForAll r in (t,s): guard(r)
        s = z3.Int('until_s')
        r = z3.Int('until_r')
        event = encode_truth(formula_json["event"], world_id, s, semantics)
        guard = encode_truth(formula_json["guard"], world_id, r, semantics)
        return z3.Exists([s], z3.And(
            is_valid_time(s), time < s, event,
            z3.ForAll([r], z3.Implies(z3.And(time < r, r < s, is_valid_time(r)), guard))))
    elif tag == "snce":
        # Exists s < t: event(s) AND ForAll r in (s,t): guard(r)
        s = z3.Int('since_s')
        r = z3.Int('since_r')
        event = encode_truth(formula_json["event"], world_id, s, semantics)
        guard = encode_truth(formula_json["guard"], world_id, r, semantics)
        return z3.Exists([s], z3.And(
            is_valid_time(s), s < time, event,
            z3.ForAll([r], z3.Implies(z3.And(s < r, r < time, is_valid_time(r)), guard))))
```

#### 2.4 Countermodel Extraction

When Z3 returns SAT (formula is not valid), extract:
1. **World histories**: For each valid world_id, extract state at each time in its interval
2. **Task relation instances**: Extract the concrete task_rel assignments
3. **Atom valuation**: Extract truth_condition assignments per world state
4. **Evaluation point**: The (world_id=0, time=0) where the formula is false

### 3. Soundness Architecture: Two Complementary Approaches

#### 3.1 Conformance Test Suite (Immediate, High ROI)

The existing `data/bmlogic-bench.jsonl` contains 387+ formulas with known validity labels and countermodels exported from the Lean decision procedure. Use these as a ground-truth regression suite:

- For every `"label": "invalid"` formula, the Z3 oracle MUST find a countermodel (completeness test)
- For every `"label": "valid"` formula, the Z3 oracle MUST NOT find a countermodel (soundness test)
- Cross-validate: Z3-produced countermodels can be checked against the existing `countermodel` field

This gives **empirical soundness** coverage immediately.

#### 3.2 Lean Metalogic Proof (Long-term, High Confidence)

A Lean theorem of the form:

```lean
theorem z3_encoding_sound :
  ∀ (N M : ℕ) (φ : Formula),
    z3_countermodel_exists N M φ →
    ¬ valid φ
```

This would require:
- Defining `z3_countermodel_exists` as a Lean predicate capturing the finite model semantics
- Proving that any finite model satisfying the Z3 constraints constitutes a valid `TaskFrame`
- Proving the truth encoding is faithful to `truth_at`

The key insight: the Z3 encoding uses **finite bounded models** (N world states, time range [-M, M]). The Lean semantics is over arbitrary types. The soundness argument is:
1. A finite model satisfying the constraints IS a valid TaskFrame (with WorldState = Fin (2^N), D = ℤ restricted to [-M, M])
2. The truth encoding faithfully mirrors `truth_at` on this finite model
3. Therefore, if Z3 finds a model where ¬φ holds, then ¬(valid φ)

This is provable because the Z3 constraints are *stronger* than necessary (bounded model is a special case of the general semantics). Soundness is easy; completeness would require showing all countermodels have a finite representative, which is the finite model property (an open research question for this logic).

### 4. Soundness-Preserving Incompleteness (Speed Optimization)

The user explicitly notes: "Finding most countermodels quickly is more important than finding all slowly." The Z3 encoding can be deliberately **sound but incomplete** in several ways that improve performance:

1. **Small N,M bounds first, escalate on timeout**: Start with N=2, M=2 (fast), then try N=3, M=3 only if needed
2. **Omit abundance constraint for pure propositional formulas**: If formula has no temporal operators, skip shift-closure constraints entirely
3. **Quantifier-free propositional fragment**: For formulas with only atom/bot/imp/box (no untl/snce), use a simpler SAT-like encoding
4. **Timeout as "unknown"**: If Z3 times out, report "unknown" rather than "valid" — this is sound (we never falsely claim countermodel exists)

### 5. Negative Training Signal Format

For integration with ML training, countermodels should be structured as:

```json
{
  "formula": { "tag": "imp", ... },
  "label": "invalid",
  "countermodel": {
    "N": 2, "M": 2,
    "world_histories": [
      {"id": 0, "interval": [-1, 1], "states": {"-1": 0, "0": 1, "1": 0}},
      {"id": 1, "interval": [0, 1], "states": {"0": 0, "1": 1}}
    ],
    "task_relation": [
      {"source": 0, "duration": 1, "target": 1},
      {"source": 1, "duration": -1, "target": 0}
    ],
    "valuation": {"p": [1], "q": [0, 1]},
    "eval_point": {"world": 0, "time": 0}
  },
  "oracle_metadata": {
    "provider": "bmlogic_z3_base_v1",
    "solve_time_ms": 45,
    "bounds": {"N": 2, "M": 2}
  }
}
```

This rich structure enables:
- Graph-based tensor encodings (GNN on world-history graph)
- Feature extraction (model size, connectivity, temporal depth)
- Differential training signals (simple vs. complex countermodels)

### 6. Estimated Effort and Line Count

| Component | Lines | Complexity |
|---|---|---|
| Formula JSON parser | ~80 | Low |
| Z3 sorts + primitives | ~50 | Low |
| Frame constraints | ~200 | Medium |
| Truth encoding (recursive) | ~150 | Medium |
| Countermodel extraction | ~150 | Medium |
| Public API + config + caching | ~150 | Low |
| Conformance test suite | ~200 | Medium |
| pyproject.toml + infrastructure | ~50 | Low |
| **Total** | **~1030** | |

## Recommended Approach

1. **Phase 1**: Create `z3_oracle/` with pyproject.toml, implement formula parser and frame constraints
2. **Phase 2**: Implement truth encoding and countermodel extraction
3. **Phase 3**: Build conformance test suite against bmlogic-bench.jsonl
4. **Phase 4**: Performance tuning (escalating N/M, propositional fast-path)
5. **Phase 5** (optional): Lean metalogic soundness theorem

## Evidence/Examples

- ModelChecker's `semantic.py` (lines 274-388) proves the Z3 encoding of frame constraints is directly translatable
- `data/bmlogic-bench.jsonl` provides 387+ ground-truth test vectors
- The formula JSON schema (`tag`, `left`/`right`/`child`/`event`/`guard`) is already standardized
- Existing `scripts/generate_dataset.py` shows the Python tooling pattern already used in this repo

## Confidence Level

**High** — The Z3 encoding is proven by ModelChecker (thousands of successful runs). The novel contribution here is architectural: extracting a clean standalone oracle from a known-good encoding, placing it in the Lean-adjacent repository for metalogic leverage, and wiring it into training pipelines. The technical risks are performance-related (quantifier instantiation at larger bounds), not correctness-related.
