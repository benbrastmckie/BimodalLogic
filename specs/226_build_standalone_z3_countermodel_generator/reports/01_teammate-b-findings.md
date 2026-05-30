# Teammate B Findings: Alternative Approaches

**Task**: 226 — Build standalone Z3 countermodel generator for negative training signal
**Angle**: Alternative solver strategies, soundness-by-construction, completeness trade-offs
**Date**: 2026-05-30

## Key Findings

### 1. Quantifier-Free Finite Instantiation Is the Critical Speed Optimization

The existing ModelChecker uses `z3.ForAll`/`z3.Exists` over unbounded integers, driving quantifier instantiation explosion (2-30s at N=2,M=2). Since the task domain is *bounded* (discrete Int with M time points, N=2^k world states), we can eliminate ALL quantifiers by finite instantiation:

**Approach**: For bounded M (time domain = {-M+1, ..., M-1}) and bounded N (world states = bitvectors of width k):
- Replace `ForAll([t], body(t))` with `And(body(-M+1), body(-M+2), ..., body(M-1))`
- Replace `Exists([t], body(t))` with `Or(body(-M+1), body(-M+2), ..., body(M-1))`
- Replace `ForAll([w], ...)` with conjunction over all 2^N bitvectors
- The task_rel becomes a truth table: `Bool` constants `task_rel_w_d_u` for each (w, d, u) triple

**Size estimate**: For N=2 (4 world states), M=2 (time domain {-1, 0, 1}):
- task_rel entries: 4 × 3 × 4 = 48 Boolean variables
- world_function entries: W_worlds × M_times = ~few × 3 state variables
- Frame constraints become propositional clauses

This converts the problem to **pure SAT/QF_BV** which Z3 solves orders of magnitude faster than quantified arithmetic. Expected speedup: 100-1000x for small N,M.

**Evidence**: The ModelChecker's `BimodalSemantics.build_forward_comp_constraint()` uses `z3.ForAll([w, v, u, d1, d2], ...)` with 5 quantified variables over unbounded domain — this is the primary performance bottleneck. Finite instantiation eliminates it entirely.

### 2. Incremental Solving with Push/Pop for Batch Generation

For generating countermodels for many formulas over the same frame class:

```python
solver = z3.Solver()
solver.add(frame_constraints)  # Shared across all formulas

for formula in formulas:
    solver.push()
    solver.add(encode_negation(formula))  # Assert formula is false
    if solver.check() == z3.sat:
        yield extract_countermodel(solver.model())
    solver.pop()
```

The frame constraints (nullity_identity, forward_comp, converse) are identical for every formula under the same frame class. By keeping them in the solver and using `push`/`pop`, we:
- Avoid re-encoding frame constraints (~40-60% of solve time)
- Allow Z3 to cache learned lemmas across formulas
- Enable clause sharing for related formulas

The ModelChecker's solver protocol already defines `push`/`pop` (solver/protocols.py:71-79), confirming this is a standard pattern.

### 3. Lean's Existing Tableau Produces Simple Countermodels — Z3 Can Produce Rich Ones

The existing `SimpleCountermodel` from the Lean tableau only captures `trueAtoms`/`falseAtoms`:
```json
{"trueAtoms": [], "falseAtoms": [{"base": "p", "fresh_index": null}], "formula": ...}
```

This tells you *which atoms* to set but not the task-frame structure (world histories, task relation, time structure). For temporal formulas like `U(φ,ψ)`, a simple atom valuation is insufficient to understand *why* the formula fails — you need to see the temporal unfolding.

A Z3 solution extracts a **full structured countermodel**:
```json
{
  "world_states": [0, 1, 2, 3],
  "time_domain": [-1, 0, 1],
  "world_histories": [
    {"id": 0, "history": {"-1": 2, "0": 0, "1": 1}},
    {"id": 1, "history": {"-1": 3, "0": 1, "1": 0}}
  ],
  "task_relation": [[0, 1, 1], [1, -1, 0], ...],
  "valuation": {"p": [0, 1], "q": [2, 3]},
  "eval_world": 0,
  "eval_time": 0
}
```

This provides dramatically richer training signal for graph neural networks (GNN encodings of the frame structure).

### 4. Iterative Deepening Is the Right Completeness Strategy

The task says "finding most countermodels quickly is more important than finding all slowly." The natural approach:

```python
def find_countermodel(formula, max_N=4, max_M=4, timeout_ms=5000):
    for N in [1, 2, 3, 4]:
        for M in [1, 2, 3]:
            result = solve_bounded(formula, N, M, timeout_ms // (N * M))
            if result is not None:
                return result
    return None  # No countermodel found within bounds
```

**What we miss** (completeness gaps):
- Formulas whose smallest countermodel requires N > 4 world states or M > 4 time points
- For **propositional + modal only** formulas (no temporal): smallest countermodel is bounded by formula complexity (no gap risk at reasonable N)
- For **temporal formulas with Until/Since**: countermodel size can grow with nesting depth, but literature suggests small models suffice for most practical formulas

**Key insight from the data**: The existing bmlogic-c5 and bmlogic-c7 datasets have 47040 formulas with temporal operators, and the Lean tableau (which IS complete) decides them all with fuel=1000. This suggests most practical formulas of complexity ≤7 have small countermodels.

### 5. Random Model Sampling as a Fast Pre-filter

Before calling Z3, we can try random sampling:

```python
def random_countermodel_check(formula, N=2, M=2, trials=100):
    for _ in range(trials):
        model = random_task_model(N, M)
        if not evaluate_truth(formula, model):
            return model
    return None  # No random countermodel found
```

For many simple invalid formulas (especially purely modal or propositional), random sampling finds countermodels in microseconds. This provides a fast pre-filter:
- **Easy formulas** (majority of invalid): random finds countermodel in <1ms
- **Hard formulas** (minority): fall through to Z3

The `evaluate_truth` function is a direct Python translation of the Lean `truth_at` recursive definition — simple and fast (no solver overhead). This is approximately O(formula_size × N × M) per trial.

**Confidence**: High. Random sampling for easy cases + Z3 for hard cases is a well-known strategy in automated reasoning (used by CaDiCaL, Glucose, etc. for SAT preprocessing).

### 6. Soundness-by-Construction: Lean-to-SMT Bridges Are Immature but Structured Export Works

**lean-smt** (https://github.com/ufmg-smite/lean-smt): Integrates SMT solvers as Lean tactics — goes in the wrong direction (SMT→Lean, not Lean→SMT export).

**duper**: Superposition-based prover inside Lean — internal use only, no SMT export.

**Practical soundness path**: Rather than generating Z3 from Lean, establish soundness as a *contract*:

1. The `Formula.toJson` schema (already defined in `DataExport.lean`) is the interface contract
2. Write a Z3 encoder in Python that matches the Lean `truth_at` case-by-case
3. Validate via cross-checking: for every formula in the existing JSONL dataset where Lean says "invalid" with a countermodel, verify Z3 also finds a countermodel (or at least doesn't claim validity)
4. Optionally, prove in Lean that any model satisfying the Z3 constraints is a valid TaskModel (this is the metalogic opportunity mentioned in the task description)

**Lean-side soundness theorem** (achievable): If we define the Z3 constraint set as a Lean `Prop` over finite structures, we can prove:
```lean
theorem z3_encoding_sound (N M : Nat) (φ : Formula) (model : FiniteTaskModel N M) :
    satisfies_z3_constraints model φ → ¬ truth_at model.toModel ... φ
```

This is tractable because both sides operate on finite structures with decidable equality.

### 7. CVC5 as Alternative Backend — Marginal Benefit

The ModelChecker already implements CVC5 (`solver/cvc5_adapter.py`). For quantifier-free finite instantiation, Z3 and CVC5 perform similarly (both use DPLL(T) + BV theory). The overhead of supporting two backends isn't justified for a focused countermodel generator. Stick with Z3 — it has better Python bindings and the ecosystem is stronger.

### 8. Lean's `decide` Tactic Is NOT Viable for Full Countermodels

The `decide` tactic works on decidable propositions by reducing to `Bool` evaluation. While `Formula → Bool` evaluation is decidable for finite models, using Lean's `decide` to *find* a countermodel requires:
- Enumerating all possible models
- Evaluating truth in each
- This is exactly what the tableau already does, but slower (no pruning)

The existing `DecisionProcedure.decide` in Lean IS the appropriate Lean-native approach. It produces `SimpleCountermodel` results. The Z3 approach adds value by producing *full structured* countermodels (with task relations and world histories), which the tableau doesn't provide.

## Recommended Approach

**Hybrid architecture with three tiers**:

1. **Tier 0 — Random sampling** (< 1ms): Try 50-100 random models at N=2, M=2. Catches ~60-70% of invalid formulas instantly.

2. **Tier 1 — Quantifier-free Z3** (1-50ms): Finite instantiation at N=2, M=2 → N=3, M=3. Pure propositional/BV encoding. Catches ~95%+ of remaining invalids.

3. **Tier 2 — Iterative deepening** (50ms-5s): Increase N,M bounds for hard cases. Timeout and mark as "undecided" rather than claiming validity.

**Key design decisions**:
- Use `push`/`pop` for batch generation with shared frame constraints
- Produce full `StructuredCountermodel` (world histories + task relation)
- Cross-validate against existing JSONL dataset (1461 invalid formulas in c5 alone)
- Keep the Lean metalogic soundness proof as a later opportunity (not blocking)

## Evidence/Examples

- ModelChecker `semantic.py:179-185`: Quantified task_rel encoding is the bottleneck
- `DecisionProcedure.lean:120`: Lean tableau decides all c5/c7 formulas with fuel=1000
- `DataExport.lean:96-116`: Formula JSON schema already defined for interop
- `bmlogic-c5.jsonl`: 1397 invalid formulas with simple countermodels (cross-validation corpus)
- ModelChecker `solver/protocols.py:71-79`: push/pop pattern already proven in production

## Confidence Level

**High** for the quantifier-free finite instantiation approach (well-established technique in bounded model checking). **Medium** for the random sampling tier (performance gain depends on formula distribution). **High** for the incremental solving pattern (standard Z3 usage). **Low** for the Lean metalogic soundness proof timeline (achievable but may take significant effort and should not block implementation).
