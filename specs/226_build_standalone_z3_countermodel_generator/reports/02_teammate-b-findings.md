# Teammate B Findings (Round 2): ModelChecker Refactoring Plan Review

**Task**: 226 — Build standalone Z3 countermodel generator for negative training signal
**Angle**: Review ModelChecker refactoring tasks 99-105, identify gaps and alternatives
**Date**: 2026-05-30
**Confidence Level**: High

## Key Findings

### 1. BLOCKER: License Relicensing Is Not Addressed in Tasks 99-105

The ModelChecker is **GPL-3.0-or-later** (code/LICENSE, code/pyproject.toml). BimodalHarness and BimodalLogic are both MIT. None of tasks 99-105 mention relicensing.

- **GPL-3.0 is a hard blocker** for MIT-licensed consumers. If BimodalHarness `pip install`s this package and imports it at runtime, BimodalHarness must be GPL-compatible.
- **The owner is sole copyright holder** (Copyright 2024 Benjamin Brast-McKie) — relicensing is legally trivial (no contributor agreements needed).
- **Missing task**: A "Relicense to MIT" task should precede or accompany task 101 (restructure as pip-installable). It's a 1-line change in pyproject.toml + new LICENSE file, but must be done explicitly.

### 2. Tasks 99-105 Dependency Chain Is Sound but Missing Three Things

The dependency chain: 99 (audit) → 100 (strip) → 101 (pip packaging) + 102 (JSON translation) → 103 (OracleProvider) → 104 (API cleanup) → 105 (integration tests).

**Missing tasks**:

1. **Relicensing** (see above) — should be task 99.5 or part of 101
2. **Performance optimization for batch countermodel generation** — task 97 achieved only 46% improvement (93s → 50s for 43 tests), and the quantifier-free finite instantiation approach (100-1000x potential speedup) is NOT addressed anywhere in 99-105. This is a gap if the oracle must process 46,000+ formulas.
3. **StructuredCountermodel extraction** — task 103 mentions "optionally StructuredCountermodel" but the existing `extract_model_elements` only produces display-oriented output (pretty-printed tables). A dedicated extraction pipeline for world_histories/task_relation/valuation as JSON is non-trivial.

### 3. Performance Status After Tasks 97 and 98

**Task 97 results** (COMPLETED):
- Removed `classical_truth` tautology → 46% speedup (93s → 50s for 43 examples)
- Pattern annotations on `lawful`/`converse` → SKIPPED (caused regressions)
- `world_uniqueness` array inequality replacement → SKIPPED (caused 8 regressions)
- `qi.max_instances` cap → SKIPPED (caused regressions)
- **Net improvement**: Only the tautology removal and `max_memory` guard shipped

**Task 98 results** (COMPLETED):
- Diagnosed the OOM amplification loop: `capped_skolem_abundance` → `world_uniqueness` → `forward_comp` creates unbounded ground term explosion
- Added `max_memory=4096` MB guard (Z3 returns 'unknown' instead of OOM kill)
- Proposed **grounding `capped_skolem_abundance`** as Rank 1 fix — NOT YET IMPLEMENTED

**Bottom line**: The fundamental quantifier performance issue (2-30s per formula at N=2,M=2) is **NOT resolved**. Task 97 achieved ~46% wall-clock improvement but the exponential MBQI scaling remains. The grounded abundance constraint (task 98's primary recommendation) was never implemented.

### 4. Thin Wrapper vs Full Refactor: Cost/Benefit Analysis

**Thin wrapper approach** (~50-100 lines):
```python
# adapter.py — wraps existing ModelChecker as OracleProvider
from model_checker.theory_lib.bimodal.semantic import BimodalSemantics
from model_checker.theory_lib.bimodal.operators import bimodal_operators

class Z3OracleProvider:
    def find_countermodel(self, formula_json, frame_class="Base", timeout_ms=5000):
        sentence = json_to_sentence(formula_json)  # ~100 lines
        settings = {"N": 2, "M": 2, "max_time": timeout_ms/1000, ...}
        semantics = BimodalSemantics(settings)
        structure = BimodalStructure(settings, semantics)
        # ... run Z3, extract model
```

**Problem**: This requires the ENTIRE 81,551-line ModelChecker as a dependency (including logos, builder, output, jupyter, settings, etc.). The import chain from `BimodalSemantics` pulls in `SemanticDefaults` → `ModelDefaults` → `PropositionDefaults` → the full models/ package → the full solver/ package → the full syntactic/ package.

**Full refactor cost breakdown** (from LOC analysis):
| Module | Lines | Keep? |
|--------|-------|-------|
| theory_lib/bimodal/ | 10,396 | YES (core) |
| models/ | 3,274 | MODIFY (base classes needed) |
| solver/ | 2,586 | MODIFY (Z3 adapter needed) |
| syntactic/ | 3,263 | KEEP (formula representation) |
| utils/ | 2,454 | MODIFY (ForAll/Exists helpers) |
| theory_lib/logos/ | 16,616 | REMOVE |
| builder/ | 16,649 | REMOVE |
| output/ | 7,859 | REMOVE |
| settings/ | 1,239 | SIMPLIFY |
| Other | ~17,215 | REVIEW |

**Verdict**: The full refactor (tasks 99-105) removes ~41,000 lines of dead weight. This is the RIGHT approach because:
- The thin wrapper carries 80K+ lines of unused GPL code as a runtime dependency
- Import time and memory footprint would be unreasonable
- The full refactor also cleans up for future maintenance
- It's a one-time cost that pays dividends forever

### 5. Quantifier-Free Encoding Is a Critical Gap

Round 1's Teammate B identified that **finite instantiation** (replacing ForAll/Exists with explicit conjunctions over bounded N,M) gives 100-1000x speedup by converting the problem to QF_BV/propositional SAT.

**This is NOT addressed in tasks 99-105.** The refactoring plan preserves the existing encoding verbatim (quantified ForAll/Exists with MBQI). Performance improvements from task 97 were modest (46%), and task 98's grounding recommendation was never implemented.

**Recommendation**: Add a task between 104 and 105 (or after 105) for "Implement quantifier-free bounded encoding mode" that:
- Adds a `mode="qf_bounded"` option alongside the existing `mode="quantified"` encoding
- For N≤4, M≤4: replaces all quantifiers with explicit enumeration
- Enables the 3-tier architecture from Round 1 (random → QF Z3 → quantified fallback)

This is the highest-leverage performance improvement available and is orthogonal to the structural refactoring.

### 6. Task 99 (Audit) Is Already Partially Obsolete

Task 99 asks for a "file-by-file refactor map." But tasks 100-105 already describe in detail what to keep/remove/modify. If the audit produces something conflicting, it wastes effort. The audit is most valuable as **validation** of the 100-105 plan (confirming import chains break cleanly) rather than as a standalone discovery exercise.

## Recommended Approach

1. **Add relicensing task** (blocker, precedes 101): Change LICENSE to MIT, update pyproject.toml
2. **Proceed with full refactor** (tasks 99-105): The thin wrapper is not viable due to import chain depth and total package size
3. **Add performance task** (after 103 or 104): Implement quantifier-free bounded encoding mode for batch countermodel generation
4. **Consider implementing task 98's grounding** as part of the refactor: The `build_grounded_abundance_constraints` + grounded `world_uniqueness` from the OOM report are the most impactful single changes
5. **Task 226 in BimodalLogic becomes an integration task**: Once ModelChecker ships as `bmlogic-oracle` (MIT), task 226 here becomes: add `bmlogic-oracle` to dev dependencies, create batch enrichment scripts, cross-validate against existing countermodels

## Evidence/Examples

| Finding | Source |
|---------|--------|
| GPL-3.0 license | `/home/benjamin/Projects/ModelChecker/code/LICENSE`, `pyproject.toml` line 12 |
| 46% perf improvement (only shipped fix) | Task 97 summary: 93s → 50s |
| Array inequality SKIPPED (8 regressions) | Task 97 summary: "Phase 2 world_uniqueness SKIPPED" |
| OOM amplification loop diagnosed | Task 98 report: lines 48-73 |
| Grounding recommended but NOT implemented | Task 98 report: "Rank 1: Ground capped_skolem_abundance_constraint" |
| 81,551 total lines in ModelChecker | `find ... -name "*.py" | xargs wc -l` |
| 10,396 lines bimodal-specific | theory_lib/bimodal/ line count |
| ~41,000 lines removable | logos + builder + output totals |

## Confidence Level

**High** — based on direct inspection of source code, completed task summaries, and LOC measurements. The license issue is factual and unambiguous. The performance gap is documented in task 97/98 results. The thin-wrapper assessment is based on the actual import chain depth.
