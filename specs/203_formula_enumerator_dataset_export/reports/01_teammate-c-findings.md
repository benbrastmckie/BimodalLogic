# Teammate C (Critic) Findings: Task #203

**Task**: 203 — Formula enumerator, decider labeling, and JSON dataset export
**Date**: 2026-05-29
**Angle**: Critical evaluation — gaps, shortcomings, and blind spots
**Confidence**: HIGH (code-inspected, combinatorics verified, online research conducted)

---

## Key Findings

### 1. Combinatorial Explosion Makes Exhaustive Enumeration Infeasible Above Complexity ~7

**Severity**: CRITICAL — architectural decision required

The formula space grows super-exponentially with complexity. With 3 atoms and 6 primitive constructors (atom, bot, imp, box, untl, snce):

| Max Complexity | Total Formulas | Feasible to Enumerate All? |
|:--------------:|:--------------:|:--------------------------:|
| 5              | 1,652          | Yes (trivial)              |
| 7              | 60,460         | Yes (~10 min to decide all)|
| 9              | 2,554,596      | Marginal (~71 hours)       |
| 11             | 117,615,644    | No                         |
| 12             | 785,407,344    | No                         |

**Implication**: The task description says "enumerate TM formulas at controlled modal/temporal depth" — but depth-bounded enumeration is also unbounded in formula count because `imp` doesn't increase depth. With modal depth ≤ 2 and temporal depth ≤ 2, the `imp` constructor can nest arbitrarily, producing unlimited formulas at any fixed depth bound.

**The task must use SAMPLING, not exhaustive enumeration**. The plan should explicitly specify the sampling strategy: random generation (like the existing `Arbitrary Formula` instance), stratified sampling by complexity band, or grammar-guided generation. This is not a minor implementation detail — it's the central design decision.

### 2. The ">80% Trivially Propositional" Feasibility Gate Is Misleadingly Easy to Pass

**Severity**: MEDIUM — gate needs redesign

The propositional fraction (formulas containing only atom, bot, imp) drops rapidly:

| Max Complexity | Propositional % |
|:--------------:|:---------------:|
| 3              | 33.3%           |
| 5              | 9.0%            |
| 7              | 2.4%            |
| 9              | 0.6%            |

At complexity ≥ 5, fewer than 10% of all formulas are purely propositional. The gate will trivially pass for any reasonable enumeration strategy that includes complexity ≥ 5.

**The real diversity concern is different**: formulas that are syntactically modal/temporal but semantically trivial. For example, `□(p → p)` contains a box but is propositionally valid — the box adds no difficulty. Similarly, `U(p, ⊤)` (= F(p)) with a tautological guard is barely temporal. The feasibility gate should measure **semantic non-triviality** (e.g., fraction where the decision procedure actually exercises temporal/modal tableau rules), not just syntactic presence of operators.

### 3. The `decide` Function Only Works for Base Frame Class

**Severity**: HIGH — the task description doesn't mention this limitation

Code inspection reveals that `decide` returns `⊢ φ` which is notation for `DerivationTree FrameClass.Base [] φ`. The proof extraction path (line 140 of DecisionProcedure.lean) explicitly checks `ax.minFrameClass ≤ FrameClass.Base`. This means:

- **Dense-only axioms** (`density`, `dense_indicator`) are NEVER used in extracted proofs
- **Discrete-only axioms** (`prior_UZ`, `prior_SZ`, `z1`) are NEVER used in extracted proofs
- Formulas that are valid in Dense but not in Base will be labeled **invalid** (correct but incomplete)
- Formulas valid in Discrete but not in Base will also be labeled **invalid** (correct but incomplete)

**For the training data use case**: if the downstream ML model should learn about all three frame classes, the dataset needs three separate `decide` calls per formula (one per frame class). But the existing `decide` only supports Base. Building Dense and Discrete deciders would require non-trivial changes to the proof extraction pipeline.

**At minimum**: the dataset schema must record which frame class the decision applies to, and the task description should acknowledge that only Base-class labeling is available initially.

### 4. The `SimpleCountermodel` Type Is Too Shallow for Useful Negative Training Signal

**Severity**: MEDIUM — limits training data quality

`SimpleCountermodel` (CountermodelExtraction.lean:47-54) contains only:
```lean
structure SimpleCountermodel where
  trueAtoms : List Atom
  falseAtoms : List Atom
  formula : Formula
```

This is a **propositional valuation**, not a modal/temporal countermodel. It does not include:
- World structure (how many worlds, which are accessible)
- Time structure (which time points, ordering)
- Task relations (which worlds relate to which)
- Per-world, per-time-point valuations

For formulas where invalidity depends on the modal/temporal structure (which is most of them beyond propositional logic), the countermodel provides minimal information. It tells you which atoms should be true/false at the initial world/time, but not why the formula fails across the frame.

**Impact on task 203**: The "proof_trace_or_countermodel" field in the JSON export will be severely asymmetric — rich proof trees for valid formulas, but only atom lists for invalid ones. This limits the corrective training signal identified in task 201 research round 2. The task should explicitly call out this limitation and note that richer countermodels (Tier 2/3 from task 201 findings) are future work.

### 5. DerivationTree Serialization Is Non-Trivial

**Severity**: MEDIUM — engineering challenge, not a blocker

The `DerivationTree` type (Derivation.lean:85-167) is a dependent type parameterized by `FrameClass`, `Context`, and `Formula`. It contains:
- `Axiom φ` values (which are themselves inductive with 42 constructors)
- `Context` membership proofs (`h : φ ∈ Γ`)
- Nested derivation trees (recursive)
- `h_fc : ax.minFrameClass ≤ fc` frame class compatibility proofs

**JSON serialization challenges**:
1. The type contains Lean propositions (`h : φ ∈ Γ`, `h_fc : ...`) that have no meaningful JSON representation
2. Deep proof trees for complex formulas could be very large (modus ponens chains create binary trees)
3. The `Axiom φ` type has 42 constructors — each needs a serialization case
4. No `ToJson` instances exist anywhere in the codebase (confirmed: zero imports of `Lean.Data.Json`)

**Recommended approach**: Don't serialize the full `DerivationTree`. Instead, create a simplified `ProofTrace` type that captures:
- Rule sequence (list of rule names applied)
- Tree height
- Axioms used (list of axiom constructor names)
- Key metrics from `PatternKey`

This is both more useful for ML training and tractable to implement.

### 6. Lean Performance Concerns for Large-Scale Computation

**Severity**: MEDIUM-HIGH — affects architecture choice

**`#eval` vs compiled execution**: Lean 4's interpreter uses bytecode compilation, and calls native code for stdlib functions. However, for custom decision procedures with deep recursion and allocation, `#eval` can be 10-100x slower than compiled native code.

**The architecture must use a compiled executable**, not `#eval` or `#check`. This means:
- Define a `main : IO Unit` entry point
- Use `lake exe` to build and run a native binary
- Write results to files using `IO.FS.Handle`
- This is a Lean 4 `IO` application, not a proof-mode computation

**Memory concerns**: Lean 4 uses reference counting with a tracing GC backup. For 50K formulas, each with a `DecisionResult` containing either a `DerivationTree` or `SimpleCountermodel`, memory usage could be significant if results aren't streamed to disk. The pipeline must process and export formulas one-at-a-time (streaming), not accumulate all results in memory.

**JSON output size**: If proof trees average 500 bytes each and countermodels 100 bytes, 50K formulas produce ~10-25MB of JSON. Manageable, but JSON-lines format (one JSON object per line) is strongly preferred over a single JSON array, both for streaming writes and for downstream consumption.

### 7. Missing Requirements and Ambiguities

**Severity**: MEDIUM — need clarification before implementation

1. **"Evaluation benchmark of 500-1K held-out formulas"**: Held out from what? If we're sampling 50K from millions, random hold-out is meaningless — any fresh sample is held-out by default. The benchmark needs a principled design:
   - Stratified by complexity band (easy/medium/hard)
   - Stratified by modal/temporal depth
   - Include known axiom instances as positive controls
   - Include known non-theorems as negative controls
   - Include near-miss formulas (single-operator mutations of valid formulas)

2. **Formula equivalences**: `p → q` and `¬p ∨ q` are logically equivalent but syntactically distinct. Since the formula type uses primitive constructors, these are different formulas. For ML training, this is arguably a *feature* (the model should learn equivalences), but the benchmark should test awareness of equivalences.

3. **Temporal duality**: `swap_temporal` maps every theorem to another theorem. Should both be in the dataset, or should we deduplicate by duality class? Including both doubles the positive training data for free but may bias the model toward symmetric features.

4. **Atom naming**: The formula type uses structured `Atom` (base string + optional fresh index). The enumerator must decide: use fixed atom names like "p", "q", "r"? Or vary names? For ML training, fixed names are better (consistent vocabulary).

5. **`decideAuto` vs `decide`**: The codebase has both `decide` (fixed fuel) and `decideAuto` (complexity-scaled fuel). The choice matters: `decideAuto` with `recommendedFuel φ = 10 * φ.complexity + 100` gives fuel 150 at complexity 5 and fuel 210 at complexity 11. This is conservative and may produce many timeouts at higher complexity.

---

## Recommended Approach (Addressing the Gaps)

### Architecture: Compiled Lean Executable with Streaming JSON-Lines Output

```
FormulaEnumerator.lean     -- Generate formulas (stratified random sampling)
  ↓
DatasetGenerator.lean      -- Run decide, collect results per formula
  ↓
JsonExport.lean            -- Stream to JSON-lines file (one record per line)
  ↓
Main.lean (IO entrypoint)  -- Orchestrate pipeline, CLI args for params
```

### Sampling Strategy (NOT Exhaustive Enumeration)

1. **Stratified by complexity band**: Sample N formulas per complexity level (e.g., 5K at complexity 5, 10K at complexity 7, 10K at complexity 9, etc.)
2. **Require operator diversity**: Within each band, enforce minimum fractions of box/untl/snce usage via rejection sampling
3. **Cap formula complexity at ~9-11**: Above this, timeout rates increase and decision times become prohibitive
4. **Use 2-3 atoms only**: More atoms don't add structural diversity, just combinatorial noise

### Feasibility Gate Redesign

Replace ">80% non-propositional" with:
- **< 20% timeout rate** (decision procedure completes on ≥80% of formulas)
- **≥ 30% valid formulas** in the labeled dataset (too few positives limits supervised learning)
- **Structural diversity score**: measure entropy over `PatternKey` (modalDepth, temporalDepth, topOperator) in the generated dataset

### Proof Trace Simplification

Create `ProofSummary` instead of serializing full `DerivationTree`:
```lean
structure ProofSummary where
  height : Nat
  axioms_used : List String      -- axiom constructor names
  rules_applied : List String    -- rule names in application order
  pattern_key : PatternKey       -- structural features
```

### Frame Class Handling

Label the dataset as Base-class only. Add a `frame_class : String` field to the JSON schema for future extension. Document this limitation prominently.

---

## Evidence/Examples

### Existing Codebase Gap: Property Test Generator Missing Constructors

The existing `Arbitrary Formula` instance in `Tests/BimodalTest/Property/Generators.lean` (line 50-69) generates `atom`, `bot`, `imp`, `box`, `all_past`, `all_future` — but **not** `untl` or `snce` directly. It uses derived operators (`all_past`, `all_future`) rather than primitives. A formula enumerator must use ALL 6 primitive constructors to produce genuinely diverse formulas.

### `decideAuto` Fuel Calculation

```lean
def recommendedFuel (φ : Formula) : Nat :=
  10 * φ.complexity + 100
```

At complexity 9, fuel = 190. The question is whether this is sufficient for tableau saturation of temporal formulas at this complexity. Temporal operators create more branches than propositional ones (Until/Since require witness point exploration). The fuel parameter may need empirical tuning per complexity band.

### No Existing JSON Infrastructure

Zero files in `Theories/` import `Lean.Data.Json`. The entire JSON serialization layer must be built from scratch — `ToJson` instances for `Formula`, `SimpleCountermodel`, the new `ProofSummary`, `PatternKey`, `GoalCategory`, and the dataset record type. This is ~200-400 lines of boilerplate.

---

## Confidence Level

**Overall: HIGH**

- Combinatorial analysis: verified by computation (exact formula counts)
- Code inspection: confirmed `decide` Base-class limitation, `SimpleCountermodel` shallowness, missing JSON infrastructure
- Performance estimates: based on published Lean 4 benchmarks and PSPACE complexity bounds (time estimates are order-of-magnitude, not precise)
- Sampling recommendation: supported by the literature on synthetic theorem generation (MUSTARD, "Training a First-Order Theorem Prover from Synthetic Data")
- JSON-lines recommendation: standard practice for large ML datasets

**Lower confidence areas**:
- Exact timeout rates at various complexities (needs empirical measurement)
- Memory usage of compiled Lean binary at scale (needs profiling)
- Whether `recommendedFuel` is adequate for temporal formulas (needs testing)

---

## Sources

- [Lean.Data.Json.FromToJson API](https://leanprover-community.github.io/mathlib4_docs/Lean/Data/Json/FromToJson.html)
- [lean4-json-schema: Proven-Correct JSON Schema in Lean 4](https://predictablemachines.com/blog/announcing-lean4-json-schema/)
- [Parameterized Modal Satisfiability](https://arxiv.org/pdf/0912.4941) — modal formula complexity bounds
- [MUSTARD: Mastering Uniform Synthesis of Theorem and Proof Data](https://arxiv.org/pdf/2402.08957)
- [Training a First-Order Theorem Prover from Synthetic Data](https://arxiv.org/pdf/2103.03798)
- [LLM-based Automated Theorem Proving Hinges on Scalable Synthetic Data Generation](https://arxiv.org/pdf/2505.12031)
- [A Survey on Deep Learning for Theorem Proving](https://arxiv.org/pdf/2404.09939)
