# Research Report: enumerateAtBudget Exponential Blowup

**Task**: 210 -- Investigate and fix enumerateAtBudget exponential blowup at complexity 5+
**Session**: sess_1748563307_r210ab
**Date**: 2026-05-29

## Executive Summary

The `enumerateAtBudget` function in `FormulaEnumerator.lean` generates formula lists whose size grows super-exponentially with the budget parameter. At budget 5 with 3 atoms and modal/temporal depth 2, the function attempts to construct **937,036 formula AST nodes** in memory (before deduplication), yet only **1,440 structurally distinct formulas** exist at that exact complexity level. This 651x bloat ratio grows to **14,876x** at budget 7. The root causes are: (1) "up to budget" semantics that re-include all lower-complexity formulas at every recursive level, (2) no memoization of repeated recursive calls, and (3) Cartesian product explosion across binary connectives. The deep run's 1.6% valid fraction is a separate but related problem: random sampling at high complexity produces overwhelmingly invalid formulas because valid formulas require specific structural patterns.

---

## 1. Root Cause Analysis

### 1.1 The Combinatorial Explosion

The function `enumerateAtBudget` (lines 470-504 of FormulaEnumerator.lean) has three compounding performance problems:

**Problem 1: "Up to budget" semantics with base case re-inclusion**

At every recursion level (budget = n+1), the function includes the base cases `bot :: atoms.map .atom` regardless of the budget. This means `bot` and every atom appear in the output at budget 1, 2, 3, 4, 5, etc. While these are deduplicated at the end by `eraseDups`, they participate in every Cartesian product during enumeration, massively inflating intermediate list sizes.

**Problem 2: No memoization**

The function is a pure recursive function with no caching. The same `(budget, maxModal, maxTemporal)` triple is computed from scratch on every call. For binary operators at budget n, the function calls `enumerateAtBudget` for each `(leftBudget, rightBudget)` split. Many of these splits share the same argument values. At budget 5, there are 1,027 total recursive calls but only 27 unique argument triples.

**Problem 3: Cartesian product explosion**

Binary connectives (`imp`, `untl`, `snce`) take the Cartesian product of left and right formula lists. If `lefts` has L elements and `rights` has R elements, this produces L*R formulas per connective. With 3 binary connectives and "up to budget" lists that include all lower-complexity formulas, the products are massive:

```
Budget  | Raw formulas  | Exact distinct | Bloat ratio
--------|---------------|----------------|------------
1       | 4             | 4              | 1.0x
2       | 56            | 4              | 14.0x
3       | 1,404         | 52             | 27.0x
4       | 36,316        | 144            | 252.2x
5       | 937,036       | 1,440          | 650.7x
6       | 24,464,492    | 5,904          | 4,143.7x
7       | 650,043,020   | 43,696         | 14,876.5x
8       | 17.6 billion  | 203,008        | 86,660.5x
```

At budget 5, the function tries to allocate ~937K list nodes. At budget 6, it would attempt 24.5 million. This explains why exhaustive enumeration at complexity 5 does not terminate within 1.5 hours.

### 1.2 The `enumHelper` function (Plan-specified API)

The `enumHelper` function (lines 98-136) has the **identical** structural problems. It differs only in using simultaneous three-constraint bounding (modal depth, temporal depth, size) rather than the two-parameter `(budget, maxModal, maxTemporal)` of `enumerateAtBudget`. The same base-case re-inclusion, lack of memoization, and Cartesian product explosion apply.

### 1.3 Comparison: `enumerateExhaustive` compounds the problem

The `enumerateExhaustive` function (lines 512-517) calls `enumerateAtBudget` for each complexity from 1 to `maxComplexity`, then concatenates and deduplicates. This means all the work for lower budgets is done multiple times -- once when called directly, and again as sub-calls within higher-budget computations. At maxComplexity=5, the cumulative raw count is 974,816 formulas before deduplication.

### 1.4 Temporal operators double the binary cost

For each binary split, the code computes both the standard-depth left/right lists (for `imp`) and the reduced-temporal-depth left/right lists (for `untl` and `snce`). This effectively doubles the work for each split when `maxTemporal > 0`. The code does reuse `tLefts` and `tRights` for both `untl` and `snce`, so this is a 2x factor (not 3x), but it still compounds the explosion.

---

## 2. Valid Fraction Analysis

### 2.1 Observed rates

| Run | Mode | Max Complexity | Valid % | Valid Count |
|-----|------|----------------|---------|-------------|
| Medium | Exhaustive | 4 | 25% | 1,284/5,136 |
| Deep | Random | 7 | 1.6% | 888/53,979 |

### 2.2 Why validity drops at higher complexity

The dramatic drop from 25% to 1.6% has several causes:

1. **Structural argument**: In bimodal TM logic, valid formulas are a small subset of all formulas. A randomly generated formula at complexity 7 is overwhelmingly likely to be an arbitrary combination of implications, boxes, untils, and sinces that admits a countermodel. Theorems require specific patterns: axiom instances, modus ponens closures, necessitation of theorems, etc.

2. **Enrichment via duals helps at low complexity**: The medium run used `include-duals` with exhaustive enumeration, which doubles valid formula yield for free (temporal duality preserves validity). But at higher complexity, the base valid fraction is so low that doubling it still yields very few valid formulas.

3. **Random sampling is unbiased**: `sampleOneRandom` gives equal weight to all constructor types. It does not favor patterns known to produce valid formulas. At complexity 7, the space of possible formulas is vast (43K+ distinct structures) and the valid subset is tiny.

4. **No structural guidance**: The random sampler chooses between constructors uniformly at random. It has no notion of "axiom schema instances" or "modus ponens applications" that would bias toward validity.

### 2.3 Formula validity rate by structural class

Based on the medium run data and logic analysis:

- **Axiom instances** (e.g., `p -> (q -> p)`, `box p -> p`): 100% valid by construction
- **Implications with atoms/bot**: Mixed, depends on propositional structure
- **Random temporal formulas** (untl/snce with arbitrary sub-formulas): Very rarely valid
- **Deep modal nesting** (box(box(...))): Higher valid fraction due to S5 collapse

---

## 3. Python Model Checker Assessment

### 3.1 Architecture

The Python model checker at `/home/benjamin/Projects/Logos/ModelChecker/code/src/model_checker/theory_lib/bimodal/` implements bimodal TM logic semantics using Z3 as the constraint solver backend. Key components:

- **BimodalSemantics**: Defines frame constraints (lawfulness, abundance, nullity, converse, compositionality), truth conditions, and evaluation points
- **BimodalProposition**: Evaluates formulas at world/time pairs using Z3
- **BimodalStructure**: Manages world histories (arrays from time to world states) and Z3 solver interaction
- **Operators**: Full set of temporal (Until, Since, Future, Past) and modal (Necessity, Possibility) operators

### 3.2 Input/Output format

The model checker operates on **arguments**: lists of premises and conclusions in LaTeX-style string notation:
```python
premises = ['\\Box (A \\vee B)']
conclusions = ['\\Box A', '\\Box B']
settings = {'N': 2, 'M': 2, 'max_time': 1, 'expectation': True}
```

To check validity of a single formula phi, one would provide:
- premises = [] (empty)
- conclusions = [phi]  (the formula to check)
- expectation = False  (we expect no countermodel if phi is valid)

If Z3 finds a countermodel (sat), the formula is **invalid**. If unsatisfiable, the formula is **valid** (in finite models up to the given N, M bounds).

### 3.3 Operator coverage

The model checker supports all operators in the Lean Formula type:
- `bot` -> `\bot`
- `atom` -> sentence letters `A`, `B`, `C`, etc.
- `imp` -> `\rightarrow` (via ConditionalOperator)
- `box` -> `\Box` (NecessityOperator)
- `untl` -> `\Until` (UntilOperator)
- `snce` -> `\Since` (SinceOperator)

The semantics are aligned with the Lean ProofChecker: same frame conditions, same truth conditions for temporal operators (Burgess convention, strict witness).

### 3.4 Performance characteristics

- **Z3 backend**: Bounded model checking with configurable N (world states) and M (time points)
- **Typical solving time**: Sub-second for small N, M (2-3); seconds to minutes for larger models
- **Completeness caveat**: The model checker is **sound but incomplete for invalidity**: if it finds a countermodel, the formula is definitely invalid; but if it fails to find one within the N, M bounds, the formula might still be invalid at larger bounds
- **Solver timeout**: Configurable `max_time` parameter (default 1 second)

### 3.5 Integration feasibility

**Direct Python subprocess call from Lean**: The Lean dataset generator runs as an IO program. It could invoke the Python model checker via `IO.Process.spawn` for each formula, passing the formula string and receiving the result (valid/invalid/timeout). This is technically straightforward but has overhead per call (~100ms process startup + Z3 solving time).

**Batch mode**: More efficiently, the Lean generator could write a batch of formulas to a file, invoke a Python batch-checking script, and read back the results. This amortizes the Python startup cost.

**Dual verification workflow**:
1. Lean enumerates/samples candidate formulas
2. Python model checker runs as fast pre-filter: for each formula, try to find a countermodel with small N=2, M=2 (very fast, <100ms typically)
3. Formulas where Z3 finds a countermodel are labeled **invalid** (with the countermodel as evidence)
4. Remaining formulas (no countermodel found) are sent to the Lean decision procedure for definitive labeling

---

## 4. The Dual Verification Architecture

### 4.1 Technical memo vision

The technical memo at `/home/benjamin/Projects/Logos/Vision/shared/strategy/01-overview/03-technical_memo.typ` describes a dual verification architecture:

- **Proof certificates** (positive signal): The Lean ProofChecker generates machine-verified witnesses establishing correctness with mathematical certainty
- **Countermodels** (negative signal): The Python ModelChecker constructs explicit countermodels for invalid inferences where premises are true and the conclusion is false

This architecture is designed for training data generation where both positive and negative signals are valuable.

### 4.2 Application to the valid fraction problem

The dual verification architecture directly addresses the valid fraction problem:

1. **Fast invalid filtering**: For formulas that ARE invalid, the Python model checker can typically find a countermodel in <100ms with small bounds. This is much cheaper than running the full Lean decision procedure.

2. **Countermodel enrichment**: Invalid formulas labeled by the model checker come with explicit countermodels, providing richer training signal than a simple "invalid" label.

3. **Selective Lean usage**: The expensive Lean decision procedure only needs to run on formulas where the model checker fails to find a countermodel -- a much smaller subset.

### 4.3 Expected impact on valid fraction

If we use the Python model checker as a pre-filter:
- At complexity 7, ~98.4% of random formulas are invalid
- The model checker should identify most of these quickly (those with small countermodels)
- Remaining formulas passed to Lean would have a much higher valid fraction
- Even if the model checker only catches 80% of invalid formulas, the remaining pool's valid fraction rises from 1.6% to ~7.4%
- Combined with validity-biased sampling (see Section 5), the target 15% is achievable

---

## 5. Mitigation Strategies (Ranked)

### Strategy A: Memoized exact-complexity enumeration (HIGH impact, MEDIUM effort)

**What**: Rewrite `enumerateAtBudget` to:
1. Only generate formulas of **exactly** the given complexity (not "up to")
2. Cache results in a `HashMap (Nat x Nat x Nat) (List Formula)` keyed by `(budget, maxModal, maxTemporal)`
3. Have `enumerateExhaustive` call this for each complexity level and concatenate

**Impact**: Eliminates all three root causes:
- No base case re-inclusion (exact complexity only)
- Memoization prevents redundant computation
- Intermediate lists are smaller, so Cartesian products are less explosive

**Expected improvement**: The "exact distinct" column in the table above shows the real counts: 1,440 at complexity 5, 5,904 at complexity 6. These are well within memory limits. Memoization would make complexity 5 enumeration complete in seconds, and complexity 6 feasible.

**Effort**: Medium. Requires refactoring the recursion structure and adding a state monad or HashMap for memoization. Lean 4's `IO.Ref` or `StateM` monad can provide mutable state. The key algorithmic change is splitting the function into "generate formulas of exactly budget b" rather than "up to budget b".

**Lean implementation sketch**:
```lean
-- Generate formulas of EXACTLY the given complexity
def enumExact (atoms : List Atom) (budget : Nat) (maxModal maxTemporal : Nat)
    (cache : IO.Ref (HashMap (Nat × Nat × Nat) (List Formula)))
    : IO (List Formula) := do
  let key := (budget, maxModal, maxTemporal)
  let cached ← cache.get
  if let some result := cached.find? key then
    return result
  let result ← computeExact atoms budget maxModal maxTemporal cache
  cache.modify (·.insert key result)
  return result
```

### Strategy B: Python model checker as invalid pre-filter (HIGH impact, HIGH effort)

**What**: Build a bridge between the Lean dataset generator and the Python model checker:
1. Lean generates candidate formulas (via enumeration or random sampling)
2. A Python batch script receives formula strings, runs Z3 countermodel search with small bounds
3. Formulas with countermodels are labeled invalid immediately
4. Remaining formulas go to the Lean decision procedure

**Impact**: Dramatically improves the effective valid fraction of formulas sent to the expensive Lean decider. Also provides countermodel data for the training set.

**Effort**: High. Requires:
- Formula serialization from Lean to Python-readable format (already have `prettyPrint`)
- A Python batch-checking script that parses formula strings and runs the model checker
- IO integration in the Lean dataset generator to call the Python script
- Result parsing to feed back into the labeling pipeline

**Feasibility concern**: The Python model checker uses LaTeX-style notation (`\Box`, `\Until`) while the Lean prettyPrint uses Unicode. A notation translator is needed. Also, the model checker expects premises/conclusions format, not standalone formula validity checking -- a thin wrapper is needed.

### Strategy C: Validity-biased formula generation (MEDIUM impact, LOW effort)

**What**: Instead of uniform random sampling, bias the generator toward patterns known to produce valid formulas:
1. **Axiom schema instantiation**: Generate random instances of the ~30 axiom schemata (prop_k, modal_t, modal_4, etc.) by substituting random sub-formulas for schema variables
2. **Modus ponens closure**: Given valid formulas phi and phi->psi, generate psi
3. **Necessitation**: Given valid formula phi, generate box(phi)
4. **Temporal dual preservation**: Given valid phi, swap_temporal gives another valid formula

**Impact**: Directly produces valid formulas at any complexity level. With 30 axiom schemata and random substitution at complexity 5-7, this could generate thousands of valid formulas quickly.

**Effort**: Low. The axiom constructors are already defined in the ProofSystem. Generating random instances requires a function `instantiateAxiom : AxiomSchema -> Nat -> IO Formula` that fills schema variables with random formulas of bounded size.

### Strategy D: Cap-and-sample hybrid (LOW impact, LOW effort)

**What**: In the existing hybrid mode, add time-based caps:
1. Run exhaustive enumeration with a wall-clock timeout per complexity level (e.g., 30 seconds)
2. If timeout occurs, switch to random sampling for remaining budget
3. Collect whatever exhaustive results were computed before timeout

**Impact**: Prevents the infinite hang but does not solve the valid fraction problem. Useful as a safety net.

**Effort**: Low. Add `IO.monoMsNow` checks inside the enumeration loop with early termination.

### Strategy E: Pruning isomorphic/trivially invalid formulas (LOW impact, MEDIUM effort)

**What**: During enumeration, filter out formulas that are:
- Trivially valid: `bot -> phi` (always valid regardless of phi)
- Trivially invalid: `phi -> bot` where phi contains no negation (usually invalid)
- Alpha-equivalent: `p -> q` and `q -> p` are structurally isomorphic under atom renaming
- Subsumed: `box(box(p))` is equivalent to `box(p)` in S5

**Impact**: Reduces formula count by perhaps 2-5x but does not address the fundamental exponential growth.

**Effort**: Medium. Requires implementing equivalence checks and canonicalization.

### Strategy F: Streaming/incremental export (LOW impact, LOW effort)

**What**: Instead of building the entire formula list in memory, stream formulas to disk as they're generated. Avoids OOM but does not reduce computation time.

**Impact**: Prevents memory exhaustion but the computation still takes exponential time.

**Effort**: Low. Use `IO.FS.writeFile` in append mode during enumeration.

---

## 6. Recommended Approach

### Phase 1 (Immediate, High-value): Strategies A + C

1. **Rewrite `enumerateAtBudget` with exact-complexity enumeration and memoization** (Strategy A). This is the highest-priority fix because it directly unblocks exhaustive enumeration at complexity 5-6 and possibly 7. The rewrite should:
   - Split into `enumExactBudget` (formulas of exactly this complexity) 
   - Add memoization via `IO.Ref (HashMap ...)`
   - Have `enumerateExhaustive` call `enumExactBudget` for each level

2. **Add axiom-schema-based valid formula generation** (Strategy C). This directly addresses the valid fraction problem by generating guaranteed-valid formulas at any complexity. Implementation:
   - Create `instantiateAxiom` function that fills schema variables with random sub-formulas
   - Create `generateValidFormulas : Nat -> Nat -> IO (List Formula)` using axiom instantiation + modus ponens + necessitation
   - Mix valid-biased formulas with exhaustive/random formulas to achieve >= 15% valid fraction

### Phase 2 (Medium-term): Strategy B

3. **Build Python model checker integration** for the dual verification architecture. This is the vision described in the technical memo and provides the richest training signal:
   - Create a Python batch script: `check_validity_batch.py` that takes a file of formulas and outputs countermodel/no-countermodel results
   - Create notation translation (Lean Unicode <-> Python LaTeX)  
   - Wire into the Lean dataset pipeline as a labeling pre-filter

### Phase 3 (Safety): Strategy D

4. **Add time-based caps** to prevent infinite hangs as a safety net, even after the memoization fix.

### Expected outcomes

With Strategies A+C implemented:
- Exhaustive enumeration should work at complexity 5-6 (seconds, not hours)
- Valid fraction at complexity 5-7 should reach 15%+ through axiom instantiation
- Total formula yield at complexity 7 should be 10K-50K with good diversity

With Strategy B added:
- Invalid formulas get countermodel evidence (richer training signal)
- The Lean decider runs on fewer formulas (cost reduction)
- The dual verification architecture from the technical memo is realized

---

## 7. Feasibility Summary

| Strategy | Impact on Enumeration | Impact on Valid % | Effort | Priority |
|----------|----------------------|-------------------|--------|----------|
| A. Memoized exact enum | Fixes blowup entirely | None directly | Medium | 1 (critical) |
| C. Validity-biased gen | None | High (>15% target) | Low | 1 (critical) |
| B. Python model checker | None | Medium (pre-filter) | High | 2 (valuable) |
| D. Time caps | Safety net | None | Low | 3 (nice-to-have) |
| E. Isomorphic pruning | 2-5x reduction | Slight | Medium | 4 (optional) |
| F. Streaming export | Prevents OOM | None | Low | 4 (optional) |

The fastest path to >= 15% valid fraction at complexity 5-7 is combining Strategy A (fix the blowup) with Strategy C (generate valid formulas by construction). This requires changes only in `FormulaEnumerator.lean` and does not need new infrastructure.
