# Research Report: Task #226 (Round 2)

**Task**: Build standalone Z3 countermodel generator for negative training signal
**Date**: 2026-05-30
**Mode**: Team Research (4 teammates)
**Focus**: Revised scope given ModelChecker refactoring at /home/benjamin/Projects/ModelChecker/

## Summary

The project direction has changed: instead of building a standalone `z3_oracle/` in BimodalLogic, the existing ModelChecker is being refactored as a pip-installable BimodalOracle (tasks 99-105 in that repo). This fundamentally simplifies task 226 from "implement Z3 constraints" (~1000 lines Python) to "integrate + validate + prove soundness" (~300 lines Python scripts + ~200-400 lines Lean).

**Critical finding from Teammate C**: The ModelChecker's Z3 encoding IS sound relative to the Lean semantics. All 6 truth constructors match. The one divergence (forward_comp without non-negative guard) is actually a theorem of the Lean axioms. No unsound gap was found. The "every countermodel guarantees a valid Lean countermodel" claim is achievable with the existing encoding.

**Blockers identified by Teammate B**: (1) GPL-3.0 license not addressed in tasks 99-105 — must be relicensed to MIT; (2) Performance not resolved — quantifier-free encoding (100-1000x speedup) not in refactoring plan; (3) Task 98's highest-priority OOM fix (grounding abundance) was never implemented.

## Key Findings

### 1. Task 226 Should Be Redefined: Three Phases Within One Task

| Phase | Work | Location | Hours | Blocks On |
|-------|------|----------|-------|-----------|
| 1 | Oracle integration scripts | `scripts/` | ~4 | ModelChecker task 103 |
| 2 | Conformance test suite | `scripts/` | ~4 | ModelChecker task 103 |
| 3 | Lean bounded model soundness | `Theories/` | ~12 | Nothing (can start now) |

**Phase 3 can start immediately** — the Lean proof doesn't need the actual oracle, just the existing semantic framework (`FiniteTaskFrame`, `truth_at`, `valid`).

### 2. ModelChecker Z3 Encoding IS Sound (Verified Line-by-Line)

Teammate C performed a detailed source comparison:

| Component | Lean | ModelChecker | Verdict |
|-----------|------|-------------|---------|
| Until (strict witness + open guard) | Truth.lean:128 | operators.py:938-951 | ✅ Aligned |
| Since (strict witness + open guard) | Truth.lean:130 | operators.py:1165-1178 | ✅ Aligned |
| Box (∀ σ ∈ Omega, shift-closed) | Truth.lean:127 | operators.py:409 + abundance | ✅ Aligned |
| Atom domain (false outside) | Truth.lean:124 | semantic.py:1467-1472 | ✅ Aligned |
| forward_comp (non-negative guard) | TaskFrame.lean:114 | semantic.py:365-376 | ⚠️ Stronger (sound) |
| Lawful (unit step only) | WorldHistory.lean:96 | semantic.py:573 | ✅ Sound (via forward_comp induction) |
| Temporal bounds (finite D) | Truth.lean:128 (all D) | semantic.py:405-411 (-M,M) | ✅ Sound (intentional incompleteness) |

**Conclusion**: Every countermodel found by the ModelChecker IS a valid countermodel in the Lean sense. The soundness guarantee from the task description is achievable.

### 3. ModelChecker Tasks 99-105: Three Critical Gaps

**Gap 1 — License (BLOCKER)**: GPL-3.0 relicensing not addressed. Owner is sole copyright holder, so MIT relicensing is trivial but must be explicit. Should precede task 101.

**Gap 2 — Performance**: Task 97 achieved only 46% improvement (93s → 50s for 43 tests). The quantifier-free finite instantiation approach (100-1000x potential) is NOT in the plan. For batch processing 48K formulas, the current encoding (2-30s/formula) would take 27-400 hours.

**Gap 3 — Grounding (from task 98)**: The highest-priority OOM fix (ground `capped_skolem_abundance_constraint` for small M) was diagnosed and recommended but never implemented.

### 4. Dataset Enrichment Is High-Leverage

| Dataset | Invalid (atom-only CM) | Timeout | Enrichment Opportunity |
|---------|----------------------|---------|----------------------|
| bmlogic-c5 | 1,397 | 52 | 1,449 formulas |
| bmlogic-c7 | 46,717 | 1,500 | 48,217 formulas |
| **Total** | **48,114** | **1,552** | **49,666 formulas** |

All have `formula_ast` in 6-tag JSON format (exact input format for the oracle). Adding a `structured_countermodel` field preserves backward compatibility.

### 5. FiniteTaskFrame Already Exists — Lean Soundness Proof Is Short

`TaskFrame.lean:284-300` defines `FiniteTaskFrame` with coercion to `TaskFrame`. The soundness proof structure:

```lean
theorem bounded_model_sound (φ : Formula)
    (F : FiniteTaskFrame Int)       -- Z3 produces this
    (M : TaskModel F.toTaskFrame)   -- valuation from Z3
    (τ : WorldHistory F.toTaskFrame) (t : Int)
    (h_false : ¬ truth_at M Set.univ τ t φ) :
    ¬ valid φ :=
  not_valid_of_countermodel ⟨F.toTaskFrame, M, Set.univ, τ, t, h_false⟩
```

The core theorem is nearly trivial (a FiniteTaskFrame IS a TaskFrame, one falsifying model proves non-validity). The substantive work is showing the Z3 output constitutes valid `WorldHistory` objects (respects_task, convex domain), which is ~200-400 lines total.

### 6. Cross-Repository Dependency Order

```
ModelChecker tasks 99-105 (produces pip-installable bmlogic-oracle, MIT license)
    ↓ pip install bmlogic-oracle
BimodalLogic task 226 Phase 1-2 (integration scripts, conformance tests)
    ↓ enriched JSONL
BimodalHarness (imports oracle via entry-points for MCTS training)
```

**Minimum dependency**: ModelChecker task 103 (OracleProvider with `find_countermodel`).
**Phase 3 (Lean) is independent** — can proceed in parallel with ModelChecker work.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution | Evidence |
|----------|------------|----------|
| Standalone z3_oracle/ (Round 1) vs ModelChecker refactor (Round 2) | ModelChecker refactor is correct — encoding is already proven, 43 tests pass | Teammate C verified line-by-line soundness |
| "Build from scratch" vs "reuse" | Reuse via refactoring — the full encoding already matches Lean | semantic.py explicitly cites Lean ProofChecker |
| Performance (2-30s/formula) viability for 48K batch | Gap: QF encoding needed; not in tasks 99-105 | Task 97 achieved only 46%; grounding not implemented |
| GPL license compatibility | Must relicense to MIT (owner is sole copyright holder) | Teammate B confirmed blocker status |

### Recommendations for ModelChecker Tasks

1. **Add relicensing task** before task 101 (trivial but must be explicit)
2. **Add QF bounded encoding task** after 103 — critical for batch performance
3. **Implement task 98's grounding** as part of the refactor (highest-impact single change)
4. **StructuredCountermodel extraction** in task 103 needs explicit design (not just "optional")

### Updated Task 226 Description

Task 226 should be revised to:

> **Integrate refactored ModelChecker oracle for dataset enrichment and prove bounded model soundness.** Consume the pip-installable bmlogic-oracle package (from ModelChecker tasks 99-105) to: (1) batch-enrich 48K+ invalid formulas with StructuredCountermodels, (2) cross-validate oracle output against Lean tableau classifications (1,751 valid = soundness test), and (3) prove in Lean that bounded finite models satisfying frame axioms are genuine countermodels (leveraging existing FiniteTaskFrame). Phase 3 can start immediately; Phases 1-2 block on ModelChecker task 103.

## Teammate Contributions

| Teammate | Angle | Key Contribution |
|----------|-------|-----------------|
| A | Integration needs | BimodalLogic needs: requirements file, enrichment script, conformance script, Lean theorem (~50 lines core) |
| B | Refactoring review | GPL blocker, performance NOT fixed (46% only), QF encoding gap, thin wrapper not viable (81K dep) |
| C | Soundness analysis | ModelChecker IS sound: all 6 constructors match, divergences are stronger or expected, no unsound gap |
| D | Scope redefinition | 3-phase structure, FiniteTaskFrame exists for Lean proof, Phase 3 independent, certified oracle is novel contribution |

## Implementation Plan (Revised)

### Phase 1 — Oracle Integration (~4 hours, blocks on ModelChecker 103)
- `requirements-oracle.txt`: `bmlogic-oracle>=0.1.0`
- `scripts/enrich_countermodels.py`: Batch-process JSONL → add `structured_countermodel` field
- Output: Enriched `data/bmlogic-c5-enriched.jsonl` and `data/bmlogic-c7-enriched.jsonl`

### Phase 2 — Conformance Testing (~4 hours, blocks on ModelChecker 103)
- `scripts/validate_oracle_conformance.py`:
  - Soundness: 1,751 valid formulas → oracle must return None
  - Completeness: 48,114 invalid → oracle should find high % of countermodels
  - Coverage: 1,552 timeout → oracle may resolve some (pure gain)
- Report: Success rate, failure analysis, resolved timeouts

### Phase 3 — Lean Bounded Model Soundness (~12 hours, can start NOW)
- `Theories/Bimodal/Metalogic/Soundness/OracleSoundness.lean`
- Prove: FiniteTaskFrame satisfying Z3 constraints → valid TaskFrame
- Prove: truth evaluation on bounded model → truth_at on general model
- Prove: countermodel found → formula not valid
- Leverages: existing FiniteTaskFrame, coercion, FMP theorem

## References

- ModelChecker tasks 99-105: `/home/benjamin/Projects/ModelChecker/specs/TODO.md`
- OracleProvider protocol: `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/oracle/protocol.py`
- FiniteTaskFrame: `Theories/Bimodal/Semantics/TaskFrame.lean:284-300`
- Z3 encoding alignment: ModelChecker `semantic.py` + `operators.py` vs Lean `Truth.lean`
- Existing dataset: `data/bmlogic-c5.jsonl` (1,513), `data/bmlogic-c7.jsonl` (49,904)
- FMP (sorry-free): `Theories/Bimodal/Metalogic/Decidability/FMP/`
