# Research Report: Task #226

**Task**: Build standalone Z3 countermodel generator for negative training signal
**Date**: 2026-05-30
**Mode**: Team Research (4 teammates)

## Summary

Four researchers investigated implementing a standalone Z3 countermodel generator within BimodalLogic. The unanimous recommendation is a **3-tier hybrid architecture** (random sampling → quantifier-free Z3 → iterative deepening) placed in a `z3_oracle/` directory at project root. The critical technical challenge identified by the Critic is **box quantification over N^M histories** — which the quantifier-free finite instantiation approach from Teammate B directly solves by eliminating all quantifiers. Sound incompleteness (bounded models ≤ N=4, M=4) is the correct trade-off: every countermodel found IS valid (false negatives only), and progressive deepening catches most countermodels quickly at small bounds. The Lean metalogic soundness proof is achievable but should be a separate follow-up task; empirical cross-validation against 376 existing Lean-generated countermodels provides immediate soundness confidence.

## Key Findings

### 1. The "Negative Training Signal" Has Two Distinct Functions (Conflict Resolved)

**Conflict**: Teammate C questioned what value a Z3 oracle adds when 376/387 invalid formulas already have countermodels. Teammate D clarified the two purposes:

1. **Enriched countermodels**: Existing countermodels are atom-only (`{trueAtoms, falseAtoms}`). Z3 produces *full task-frame countermodels* with world histories, task relations, and temporal structure — enabling GNN-based encodings for richer training signal.

2. **Coverage expansion**: The current Lean tableau times out on ~1,500 formulas at complexity 7. Z3 uses fundamentally different search strategies (DPLL(T), theory propagation) that can resolve a subset the tableau cannot.

**Resolution**: Both are valuable. The primary deliverable is structured countermodels; the secondary is coverage of timeout formulas.

### 2. Quantifier-Free Finite Instantiation Eliminates the Performance Bottleneck

**Conflict**: ModelChecker uses `z3.ForAll`/`z3.Exists` over unbounded integers, causing 2-30s solve times. Teammate B identified the fix: since the model is bounded (N worlds, M time steps), ALL quantifiers can be eliminated by finite instantiation.

- Replace `ForAll([t], body(t))` with `And(body(0), body(1), ..., body(M-1))`
- Replace `Exists([t], body(t))` with `Or(body(0), body(1), ..., body(M-1))`
- task_rel becomes a truth table: `Bool` constants for each `(w, d, u)` triple

This converts the problem to **QF_BV/propositional SAT** which Z3 solves 100-1000x faster.

**Evidence**: ModelChecker's `build_forward_comp_constraint()` uses 5 quantified variables over unbounded domain — this single constraint drives the performance bottleneck. Finite instantiation eliminates it.

### 3. Box Quantification Over N^M Histories Is the Engineering Challenge

**Teammate C's critical observation**: Box quantifies over `∀ σ ∈ Omega` where Omega must be shift-closed. For bounded models with Omega = Set.univ (all histories), this means enumerating **N^M** possible histories.

| N (worlds) | M (time steps) | Histories (N^M) |
|---|---|---|
| 2 | 2 | 4 |
| 2 | 3 | 8 |
| 3 | 3 | 27 |
| 4 | 3 | 64 |
| 3 | 4 | 81 |

**Resolution**: This IS manageable at small bounds (N=2, M=2: 4 histories). The quantifier-free encoding instantiates box as conjunction over all valid histories — 4 conjuncts at N=2,M=2 is trivial for Z3. At larger bounds (N=3, M=4: 81 histories), formula size grows but remains within SAT solver capabilities.

**respects_task constraint** (from Teammate C): Each history requires O(M²) task_rel constraints (all pairs of time points must satisfy the relation). At N=2, M=2 with 4 histories: 4 × 1 = 4 constraints. At N=2, M=3 with 8 histories: 8 × 3 = 24 constraints. Manageable.

### 4. Sound Incompleteness Is Universally Agreed

All four teammates agree: bounded model checking at small N,M is **sound** (any countermodel found is valid) but **incomplete** (may miss countermodels requiring larger bounds). This is the correct design:

- **False negatives only**: Never produce a wrong countermodel. May fail to find one for hard formulas.
- **Progressive deepening**: N=2,M=2 first (~ms), then N=3,M=3 (~100ms), then N=4,M=4 (~seconds).
- **Existing FMP theorem** (Teammate D): BimodalLogic has a sorry-free finite model property theorem, guaranteeing finite countermodels exist for all invalid formulas. Z3 WILL find them given sufficient bounds.

### 5. Architecture: `z3_oracle/` at Project Root

**Conflict**: Teammate A proposed `z3_oracle/` with full package structure. Teammate C suggested scripts + requirements.txt. Teammate D proposed `tools/z3_oracle/`.

**Resolution**: `z3_oracle/` at project root with `pyproject.toml`. Reasons:
- The oracle is complex enough (~1000 lines) to warrant package structure
- `pyproject.toml` enables registration as BimodalHarness OracleProvider entry point
- Separation from Lean code is clean (no lakefile.lean interference)
- Tests and benchmarks need a proper test runner

```
BimodalLogic/
├── z3_oracle/
│   ├── pyproject.toml           # z3-solver dep, entry point registration
│   ├── src/bmlogic_oracle/
│   │   ├── __init__.py
│   │   ├── encoding.py          # Frame constraints + truth encoding
│   │   ├── formula.py           # JSON formula parser
│   │   ├── countermodel.py      # Model extraction
│   │   ├── oracle.py            # Public API + 3-tier dispatch
│   │   └── sampling.py          # Tier 0: random model sampling
│   ├── tests/
│   │   ├── test_conformance.py  # Cross-validation vs bmlogic-bench
│   │   └── ...
│   └── benchmarks/
```

### 6. Metalogic Soundness Proof: Achievable But Deferred

All teammates agree: a Lean proof of the form `z3_countermodel_exists N M φ → ¬ valid φ` is achievable because:
- Both sides operate on finite structures with decidable equality
- The Z3 constraints are STRONGER than necessary (bounded model is a special case)
- Soundness is the easy direction (completeness would require the FMP)

But it's a multi-hundred-line Lean formalization that should be a **separate follow-up task**. Cross-validation against 376 existing countermodels provides empirical soundness for now.

### 7. The 3-Tier Hybrid Architecture (from Teammate B)

| Tier | Method | Expected Time | Coverage |
|---|---|---|---|
| 0 | Random model sampling (100 trials) | < 1ms | ~60-70% of easy invalids |
| 1 | Quantifier-free Z3 at N=2, M=2 | 1-50ms | ~95% of remaining |
| 2 | Iterative deepening N=3→4, M=3→4 | 50ms-5s | Remaining hard cases |

**Batch optimization**: Use Z3 `push`/`pop` to share frame constraints across formulas. Frame constraints are identical for all formulas under the same frame class — encode once, reuse for entire batch.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution | Evidence |
|----------|------------|----------|
| What value does Z3 add (C) vs clear value (A,D) | Enriched structure + coverage expansion | 376 existing are atom-only; 1500 timeouts need resolution |
| Full package (A) vs scripts (C) vs tools/ (D) | `z3_oracle/` with pyproject.toml | Complex enough for package; needs entry point for BimodalHarness |
| Quantified Z3 (A) vs quantifier-free (B) | Quantifier-free finite instantiation | Eliminates 100-1000x performance bottleneck |
| N^M explosion makes box hard (C) vs manageable (B) | Manageable at small bounds (4-8 histories) | N=2,M=2 → 4 histories; progressive deepening handles scale |
| Lean soundness now (task desc) vs defer (all) | Defer to follow-up task, use cross-validation now | Multi-hundred lines of Lean formalization is separate scope |

### Gaps Identified

1. **StructuredCountermodel schema**: Must be designed concretely before implementation. Teammate A proposed a format; needs finalization with BimodalHarness compatibility.
2. **Omega shift-closure in bounded setting**: Teammate C's concern about shift-closure under bounded time. Resolved by using all N^M histories (trivially shift-closed when domain is the full interval), but worth noting in the soundness argument.
3. **Full-domain simplification**: All histories having the same domain {0,...,M-1} is a sound restriction but means we cannot find countermodels that exploit partial histories. Unlikely to matter for practical formulas.
4. **BimodalHarness OracleProvider integration**: The protocol is designed (Round 5 research in BimodalHarness task 19) but not implemented. This task implements the oracle; integration is downstream.
5. **Dense/Discrete frame classes**: Only Base frame is implementable now. Interface should accept `frame_class` parameter for future extension.

### Recommendations

1. **Start with Tier 1 (QF Z3)**: The random sampling tier is nice-to-have but the real value is the Z3 encoding. Get the encoding right first, add random pre-filter as optimization.

2. **Use full-domain histories with Omega = Set.univ**: Simplest sound approach. All histories have domain {0,...,M-1}. Box quantifies over all N^M possible histories. This IS correct and manageable at N=2, M=2.

3. **Cross-validate against bmlogic-bench.jsonl immediately**: The 376 known-invalid formulas with countermodels are the test suite. Oracle must find countermodels for a high fraction.

4. **Produce StructuredCountermodel with world histories + task relation**: This is the unique value proposition vs existing SimpleCountermodel.

5. **Register as BimodalHarness OracleProvider**: Use `pyproject.toml` entry points so BimodalHarness can discover and use this oracle.

6. **Flag metalogic soundness as a separate task**: Worth pursuing later but not blocking.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary Implementation | completed | high | Architecture layout, Z3 encoding details, LOC estimate |
| B | Alternative Approaches | completed | high | QF finite instantiation (100-1000x speedup), 3-tier hybrid, random sampling |
| C | Critic | completed | high | N^M history explosion, respects_task complexity, shift-closure, atom domain |
| D | Horizons | completed | high | Strategic justification, two purposes of negative signal, phasing |

## Implementation Phasing

### Phase 1 — MVP Oracle (~10 hours)
- `z3_oracle/` directory with pyproject.toml
- Formula JSON parser (6 constructors)
- QF finite instantiation encoding at N=2, M=2
- Frame constraints (nullity_identity, forward_comp, converse)
- Truth encoding (recursive, 6 cases)
- StructuredCountermodel extraction
- Cross-validation test suite vs bmlogic-bench.jsonl

### Phase 2 — Performance & Coverage (~8 hours)
- Progressive deepening (N=2→4, M=2→4)
- Random model sampling pre-filter (Tier 0)
- Push/pop batch optimization
- Benchmark suite for scaling analysis
- Handle timeout formulas from existing dataset

### Phase 3 — Integration (~5 hours)
- BimodalHarness OracleProvider entry point registration
- Batch enrichment of JSONL datasets
- StructuredCountermodel → tensor encoding (coordinate with BimodalHarness)

### Phase 4 — Lean Soundness (separate task, ~15 hours)
- Lean formalization of finite bounded model semantics
- Proof: Z3 constraints imply valid TaskFrame + TaskModel
- Proof: truth encoding is faithful to truth_at
- Theorem: z3_countermodel_exists → ¬ valid

## References

- `Theories/Bimodal/Semantics/Truth.lean:122-131` — Ground truth: truth_at definition
- `Theories/Bimodal/Semantics/TaskFrame.lean:93-122` — Frame axioms
- `Theories/Bimodal/Semantics/WorldHistory.lean:69-97` — History constraints (convexity, respects_task)
- `data/bmlogic-bench.jsonl` — 387 formulas with known labels (cross-validation corpus)
- BimodalHarness task 19 Round 5 — OracleProvider protocol design
- ModelChecker `semantic.py:139-697` — Proven Z3 encoding (reference implementation)
