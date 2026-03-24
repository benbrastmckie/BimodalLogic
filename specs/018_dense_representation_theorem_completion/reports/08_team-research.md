# Research Report: Closure-Based Refactoring for Dense Temporal Coherence

**Task**: 18 - dense_representation_theorem_completion
**Date**: 2026-03-21
**Mode**: Team Research (3 teammates)
**Session**: sess_1774117703_fa1892
**Focus**: Design the correct closure-based refactoring and identify the mathematically cleanest approach

## Summary

Three teammates investigated the closure operator design from complementary angles: mathematical foundations (A), concrete refactoring (B), and risk analysis (C). The research produced a fundamental insight that reshapes the approach: **the closure of the staged timeline under F/P-witnesses converges to all of CanonicalMCS** (Teammate A). This means a closure operator on TimelineQuot is the wrong abstraction — it rebuilds the canonical model. All three teammates independently confirmed the "direct bridge" strategy from report-05 has an unresolvable gap (phi membership in witnesses is not guaranteed by CanonicalR).

Three viable strategies emerged, ranked by mathematical elegance:

1. **CanonicalMCS as domain** (Teammate A): Use CanonicalMCS directly, generalize TaskFrame to drop AddCommGroup. Forward_F/backward_P are already sorry-free on CanonicalMCS.
2. **Eager processing** (Teammate C, Option D): Modify the staged construction to process ALL F-obligations when a point is added, eliminating the m > 2k gap by construction.
3. **Pre-quotient closure** (Teammate B): Add a closure step to `denseTimelineUnion` BEFORE forming TimelineQuot. Requires re-engineering the quotient pipeline.

## Key Findings

### 1. The Closure Fixpoint IS CanonicalMCS (High Confidence)

Teammate A proved that the closure operator on any seed set of MCSes, defined as:
```
cl(S) = lfp(F) where F(X) = S ∪ FWit(X) ∪ PWit(X)
```
converges to the full set of CanonicalMCS at omega steps. This is because every MCS is reachable by iterated Lindenbaum extension from any root MCS. The implication: **a closure operator on a subset of MCSes is just a complicated way of recovering the canonical model**.

This is the single most important finding. It means we should not build closure infrastructure on TimelineQuot — we should use the canonical model directly.

### 2. Direct Bridge Strategy Has Unresolvable Gap (High Confidence)

All three teammates independently confirmed:
- `CanonicalR(M, W)` transfers g_content (G-formulas), NOT F-formulas
- `F(phi) ∈ M ∧ CanonicalR(M, W)` does NOT imply `phi ∈ W`
- The comment thread in ClosureSaturation.lean:463-667 correctly diagnosed this gap
- Report-05's synthesis walked this back but the gap persists

### 3. TimelineQuot Cannot Be Extended Post-Hoc (High Confidence)

Teammate C identified a critical engineering constraint: `TimelineQuot` is defined as `Antisymmetrization DenseTimelineElem (· ≤ ·)` — a fixed Lean 4 quotient type. Adding points after quotienting requires a new type. Any closure approach must happen BEFORE quotienting, which means modifying `denseTimelineUnion` or creating a new pipeline.

### 4. FMCSTransfer Architecture Already Exists (High Confidence)

Teammate A discovered that `Bundle/FMCSTransfer.lean` provides sorry-free temporal coherence transfer from CanonicalMCS to any domain with an embed/retract pair. The `transfer_forward_F` theorem (line 244) is proven without sorry. The key obstacle: building an `FMCSTransfer` for TimelineQuot requires every CanonicalMCS to embed into TimelineQuot — which is the original problem.

### 5. Dovetailed Construction Exists But Incomplete (Medium Confidence)

Teammate B found that `DovetailedBuild.lean`, `DovetailedCoverage.lean`, and `DovetailedCoverageReach.lean` already implement a construction designed to fix the m > 2k gap by processing (point, formula) pairs via Cantor pairing. However, DovetailedCoverageReach.lean has its own sorry gaps (termination of density-based recursion).

### 6. Eager Processing Is Viable But Invasive (Medium Confidence)

Teammate C's Option D: when a new point enters the staged build at stage m, immediately process ALL of its F-obligations (not just encoding m/2). This eliminates the m > 2k gap by construction. Risk: changes the staged construction infrastructure, potentially cascading through StagedExecution.lean and DenseTimeline.lean.

### 7. derive_F_to_FF Is a Mechanical 8-10 Step Derivation (High Confidence)

All teammates confirmed the derivation chain:
1. Density axiom: `G(G(¬ψ)) → G(¬ψ)`
2. Contrapositive: `F(ψ) → ¬G(G(¬ψ))`
3. DNE + temporal necessitation + K-distribution: `G(¬¬G(¬ψ)) → G(G(¬ψ))`
4. Contrapositive of step 3: `¬G(G(¬ψ)) → ¬G(¬¬G(¬ψ))`
5. Chain steps 2+4: `F(ψ) → F(F(ψ))`

Blocks `density_F_to_FF` which is needed regardless of approach. Estimated 1-2 hours.

### 8. Sorry Inventory Refined (High Confidence)

Teammate B audited ClosureSaturation.lean and found 4 sorries (not 28):

| # | Line | Theorem | Status |
|---|------|---------|--------|
| 1 | 696 | `timelineQuotFMCS_forward_F` (m > 2k) | BLOCKING |
| 2 | 701 | `timelineQuotFMCS_forward_F` (density) | BLOCKING |
| 3 | 716 | `timelineQuotFMCS_backward_P` | BLOCKING |
| 4 | 778 | `timelineQuotSingletonBFMCS.modal_backward` | DEPRECATED |

Plus sorry #7 in CantorPrereqs.lean:111 (`derive_F_to_FF`) and sorry #1 in TimelineQuotCompleteness.lean:127 (`timelineQuot_not_valid_of_neg_consistent`).

## Synthesis

### Conflict 1: Closure vs No Closure vs Eager Processing

**Teammate A**: No closure needed — use CanonicalMCS as domain, forward_F/backward_P are already sorry-free there.

**Teammate B**: Closure approach is viable — create TemporalClosure.lean, add witnesses pre-quotient.

**Teammate C**: Closure is impractical due to re-quotienting — prefer eager processing (modify staged construction to process all F-obligations at point-of-addition).

**Resolution**: Teammate A's insight is mathematically decisive. The closure converges to CanonicalMCS, so building closure infrastructure is rebuilding the canonical model with extra steps. The correct approach depends on whether TaskFrame can be generalized:

- **If TaskFrame can drop AddCommGroup**: Use CanonicalMCS directly (cleanest, ~4 hours)
- **If TaskFrame requires AddCommGroup**: Either eager processing (modify staged construction, ~6 hours) or pre-quotient closure (new pipeline, ~7 hours)

### Conflict 2: File Organization

**Teammate B** proposed creating `TemporalClosure.lean` as a new file for the closure operator.

**Resolution**: If the CanonicalMCS approach is chosen, no new file is needed — the sorries in ClosureSaturation.lean become dead code. If eager processing is chosen, StagedExecution.lean is modified instead. `TemporalClosure.lean` is only needed for the pre-quotient closure approach (least preferred).

### Conflict 3: Reuse of Existing Code

**Teammate B** identified the m ≤ 2k branch (lines 363-413) as reusable. **Teammate A** argued the entire `timelineQuotFMCS_forward_F` becomes unnecessary if using CanonicalMCS.

**Resolution**: Depends on chosen approach. If CanonicalMCS: archive most of ClosureSaturation.lean. If eager processing: keep the m ≤ 2k branch, fix the m > 2k branch.

### Gaps Identified

1. **AddCommGroup constraint on TaskFrame**: Must investigate whether this can be relaxed. If not, the CanonicalMCS approach requires a workaround.
2. **DenselyOrdered CanonicalMCS**: New lemma needed. Must prove that between any two CanonicalR-related MCSes, there exists a third (follows from density axiom + Lindenbaum).
3. **DovetailedCoverageReach completion**: If eager processing is chosen, this alternative pipeline should be evaluated for reuse.
4. **Existing proofs depending on TimelineQuot as domain**: Must audit what breaks if switching to CanonicalMCS.

## Recommended Approach (Ranked by Elegance)

### Option 1: CanonicalMCS as Domain (Most Elegant)

**Prerequisite**: Verify TaskFrame can be generalized to drop AddCommGroup.

**Steps**:
1. Generalize `TaskFrame` to require only `LinearOrder D`, `DenselyOrdered D`, `NoMaxOrder D`, `NoMinOrder D` (remove `AddCommGroup D`)
2. Prove `DenselyOrdered CanonicalMCS` (using density axiom)
3. Prove `LinearOrder CanonicalMCS` (from CanonicalR)
4. Prove `NoMaxOrder CanonicalMCS` and `NoMinOrder CanonicalMCS` (from Lindenbaum + density)
5. Instantiate `parametric_canonical_truth_lemma` at `D = CanonicalMCS`
6. Wire `dense_completeness_theorem`
7. Archive ClosureSaturation.lean temporal coherence code (becomes dead)

**Effort**: ~4-6 hours (generalization + new lemmas + wiring)
**Risk**: TaskFrame generalization may cascade through existing discrete pipeline

### Option 2: Eager Processing (Clean Refactor)

**Prerequisite**: Audit StagedExecution.lean for modification safety.

**Steps**:
1. Fix `derive_F_to_FF` (1-2 hours)
2. Modify `processForwardObligation` to process ALL F-formulas for newly added points (not just the current stage's encoding)
3. Prove the modified construction still maintains Finset stages (bounded by formulas with encoding ≤ relevant bound)
4. Fix sorries #2, #3 in ClosureSaturation.lean using the new guarantee
5. Fix sorry #4 (backward_P) symmetrically
6. Wire TimelineQuotCompleteness.lean sorry #1
7. Clean up ClosureSaturation.lean exploration comments

**Effort**: ~6-8 hours (staged construction modification + sorry fixes)
**Risk**: Changes to StagedExecution.lean may cascade

### Option 3: Pre-Quotient Closure (Fallback)

**Steps**:
1. Fix `derive_F_to_FF`
2. Create `TemporalClosure.lean` with closure operator on `denseTimelineUnion`
3. Prove closure preserves countability, density, linear order
4. Redefine `TimelineQuot` over the closed set (or create `ClosedTimelineQuot`)
5. Prove forward_F/backward_P for the closed timeline
6. Update downstream consumers

**Effort**: ~7-10 hours (new file + re-quotienting + downstream updates)
**Risk**: Highest engineering cost, most code changes

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Insight |
|----------|-------|--------|------------|-------------|
| A | Closure math design | completed | high | Closure fixpoint = CanonicalMCS; use CanonicalMCS directly |
| B | Refactoring plan | completed | high | ClosureSaturation has 300+ lines dead exploration; dovetailed build exists |
| C | Risk analysis | completed | high | Re-quotienting is critical blocker; eager processing is most viable for TimelineQuot |

## Individual Reports

- [08_teammate-a-findings.md](08_teammate-a-findings.md) — Closure operator design, FMCSTransfer discovery, CanonicalMCS-as-domain recommendation
- [08_teammate-b-findings.md](08_teammate-b-findings.md) — Code audit, dovetailed construction analysis, file organization proposal
- [08_teammate-c-findings.md](08_teammate-c-findings.md) — Termination bounds, re-quotienting analysis, derive_F_to_FF chain, eager processing proposal
