# Research Report: Task #55 — Root Cause Analysis (Deep Dive)

**Task**: Prove SuccChain Temporal Coherence Directly
**Date**: 2026-03-24
**Mode**: Team Research (2 teammates)
**Session**: sess_1774406528_15e8e2

## Executive Summary

After 5 plan versions and 15+ research reports, this team research confirms with HIGH confidence that the blocker is **architectural, not mathematical**. The root cause is a semantic mismatch between two witness construction paradigms:

1. **SuccChain** builds deterministic chains where F-obligations can be infinitely deferred
2. **Canonical construction** builds per-obligation Lindenbaum witnesses that trivially satisfy forward_F

The codebase already contains a **sorry-free completeness path** via `CanonicalConstruction.lean`. The sorry chain exists only in `construct_bfmcs`, which is **deprecated and unused** by the main completeness theorems.

**Bottom Line**: The task may already be solved — the sorry is in dead code. The canonical path provides completeness without same-family temporal coherence.

---

## Key Findings

### 1. Root Cause: Semantic Mismatch Between Witness Paradigms (HIGH CONFIDENCE)

The fundamental problem is a type-level incompatibility:

| Property | TemporalCoherentFamily.forward_F | canonical_forward_F |
|----------|----------------------------------|---------------------|
| Signature | `∃ s > t, φ ∈ fam.mcs s` | `∃ W, MCS W ∧ ExistsTask M W ∧ φ ∈ W` |
| Witness location | Same FMCS chain, later time | Fresh MCS via Lindenbaum |
| Why needed | backward_G requires same-MCS contradiction | Truth lemma at frame level |

**Why same-family is essential for TemporalCoherentFamily**: The `temporal_backward_G` proof derives `neg(phi) ∈ fam.mcs s` from forward_F, then contradicts with `phi ∈ fam.mcs s` from the hypothesis. Cross-family witnesses cannot provide this contradiction because they live in different MCSes.

**Why SuccChain cannot provide same-family witnesses**: The chain construction uses `constrained_successor_from_seed` with deferral disjunctions `psi ∨ F(psi)`. Lindenbaum can always choose `F(psi)`, deferring forever. The counterexample `{F^n(p) | n ∈ ℕ}` demonstrates this: a valid MCS with unbounded F-nesting that extends to a SuccChain where `p` is perpetually deferred.

### 2. Two Parallel Completeness Paths Exist (HIGH CONFIDENCE)

| Path | Key Files | forward_F Status | Truth Lemma Status | Used By |
|------|-----------|------------------|--------------------|---------|
| **Canonical** | CanonicalFrame.lean, CanonicalConstruction.lean | **PROVEN** (no sorry) | **PROVEN** (no sorry) | `canonical_truth_lemma`, `shifted_truth_lemma` |
| **SuccChain** | SuccChainFMCS.lean, UltrafilterChain.lean | **BLOCKED** (sorry chain) | N/A | `construct_bfmcs` (deprecated) |

**The sorry chain only exists in the SuccChain path**:
```
f_nesting_is_bounded (MATHEMATICALLY FALSE)
  → f_nesting_boundary
  → succ_chain_forward_F
  → SuccChainTemporalCoherent
  → boxClassFamilies_temporally_coherent
  → construct_bfmcs (DEPRECATED)
```

**The canonical path is entirely sorry-free**:
```
forward_temporal_witness_seed_consistent (PROVEN)
  → set_lindenbaum (PROVEN)
  → canonical_forward_F (PROVEN)
  → canonical_truth_lemma (PROVEN)
  → shifted_truth_lemma (PROVEN)
```

### 3. construct_bfmcs is Dead Code (HIGH CONFIDENCE)

`construct_bfmcs` is:
- Marked `@[deprecated]` in UltrafilterChain.lean
- NOT imported or used by the main completeness theorems
- Only referenced by `parametric_algebraic_representation_conditional` as a parameter
- `succ_chain_completeness` uses `succ_chain_model`, NOT `construct_bfmcs`

**Implication**: The sorry chain may already be inert — completeness is routed through the canonical path.

### 4. Standard Literature Confirms Canonical Approach (HIGH CONFIDENCE)

Both teammates independently verified:
- Blackburn, de Rijke, Venema (2001): Saturated canonical model with per-obligation witnesses
- Goldblatt (1992): Same approach for tense logics
- Manna & Pnueli (1992): Fair-scheduling for LTL (unnecessary here since canonical works)

The canonical model approach (per-obligation Lindenbaum witnesses) is the **standard** way to prove temporal logic completeness. The SuccChain approach is non-standard and introduces the deterministic chain problem.

---

## Synthesis

### Conflicts Resolved

**No conflicts found.** Both teammates converged on the same diagnosis and recommendation:
- Root cause: semantic mismatch between witness paradigms
- `f_nesting_is_bounded` is FALSE (standard counterexample)
- Same-family constraint in TemporalCoherentFamily is essential (backward_G requires it)
- Canonical construction path is sorry-free and sufficient
- `construct_bfmcs` is dead code

### Gaps Identified

1. **Verification needed**: Does the project's overall completeness theorem (the one exported to users) go through the canonical path or the SuccChain path? If canonical, the task is already solved.

2. **Parametric representation**: `parametric_algebraic_representation_conditional` takes `construct_bfmcs` as a parameter. Need to check if this function is used anywhere meaningful, or if it's also dead code.

3. **Sorry count impact**: If `construct_bfmcs` is truly dead code, removing/deprecating it should reduce the sorry count. Need to verify which sorries are in the SuccChain path vs other sorry sources.

---

## Recommendations

### Immediate Action (before next plan)

1. **Trace the completeness export path**: Run `#print axioms` on the final completeness theorem to determine if it depends on any sorry in the SuccChain path. If not, the sorry chain is already inert.

2. **Check parametric_algebraic_representation_conditional**: Is it used? If not, it's also dead code.

### Resolution Options (in priority order)

| Option | Effort | Confidence | Description |
|--------|--------|------------|-------------|
| **A: Verify sorry is in dead code** | 30 min | HIGH | Trace axioms of main completeness theorems |
| **B: Deprecate entire SuccChain temporal path** | 1 hour | HIGH | Mark all sorry-chain theorems as deprecated |
| **C: Fair-scheduling chain** | 5-10 hours | MEDIUM | Only if Option A reveals sorry in live code |

**Recommended**: Start with Option A. If the main completeness theorems don't depend on the sorry chain, the task reduces to documentation and cleanup.

---

## Teammate Contributions

| Teammate | Angle | Key Finding | Confidence |
|----------|-------|-------------|------------|
| A | Root cause architecture | Type mismatch is structural; backward_G requires same-family; construct_bfmcs is dead code | HIGH |
| B | Alternative paths / prior art | Canonical approach is standard textbook method; already implemented and sorry-free; fair-scheduling unnecessary | HIGH |

---

## References

**Literature**:
- Blackburn, de Rijke, Venema (2001). Modal Logic, Ch. 4 (Completeness)
- Goldblatt (1992). Logics of Time and Computation, Ch. 6
- Manna & Pnueli (1992). Temporal Logic of Reactive Systems, Ch. 5
- Emerson & Clarke (1982). Design and Synthesis of Synchronization Skeletons

**Codebase (sorry-free path)**:
- CanonicalFrame.lean:139-154 (`canonical_forward_F` — PROVEN)
- CanonicalConstruction.lean:490-630 (`canonical_truth_lemma` — PROVEN)
- CanonicalConstruction.lean:648+ (`shifted_truth_lemma` — PROVEN)

**Codebase (blocked path)**:
- UltrafilterChain.lean:1853-1877 (`construct_bfmcs` — DEPRECATED, has sorry)
- SuccChainFMCS.lean (`f_nesting_is_bounded` — MATHEMATICALLY FALSE)

---

## Next Steps

1. **Run `#print axioms` on main completeness theorems** to determine if sorry is in dead code
2. **If dead code**: Task reduces to deprecation + documentation (Option A/B above)
3. **If live code**: Implement fair-scheduling chain or restructure completeness path (Option C)
