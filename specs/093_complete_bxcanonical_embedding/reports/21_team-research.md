# Research Report: Task #93 — Complete BXCanonical Embedding

**Task**: 93 - Close TaskModel embedding sorry (sole remaining active-path sorry)
**Date**: 2026-04-16
**Mode**: Team Research (4 teammates)
**Session**: sess_1776219044_febe15

## Summary

Four teammates investigated the mathematically correct long-term path for closing 6 sorry sites in `RootScopedChain.lean`. After 20+ research rounds and 21+ dead ends documented, the team converges on a **two-tier approach**: (1) immediately close the `buc` and `fuc` Until/Since coherence sorries using existing quasimodel infrastructure (independent of forward_F), then (2) close the primary `rr_fwd_chain_forward_F` blocker via Plan v18's ordered-discharge chain with never-resolved count termination.

A critical finding: the fold-order trick (processing target LAST in the BX11 fold) has been repeatedly recommended but **never actually tested**. Plan v18's ROAD_MAP incorrectly lists it as a dead end. The trick eliminates BX11 Case 3 displacement but NOT Case 2 deferral, making it a partial fix at best. However, it should be tested concretely before committing to the full chain replacement.

## Key Findings

### Finding 1: The 6 Sorry Sites Reduce to 2 Independent Problems (All Teammates Agree)

The dependency structure is:
```
dd_countermodel
  ├── dd_bfmcs_restricted_tc (sorry, line 1386)
  │     └── dd_fmcs_forward_F (sorry) + dd_fmcs_backward_P (sorry)
  │           └── rr_fwd_chain_forward_F (sorry, line 1295) ← PRIMARY BLOCKER
  ├── dd_bfmcs_restricted_buc (sorry, line 1391) ← INDEPENDENT
  └── dd_bfmcs_restricted_fuc (sorry, line 1396) ← INDEPENDENT
```

**Problem A** (4 sorries): `rr_fwd_chain_forward_F` + its 3 downstream dependents (lines 1295, 1326, 1333, 1386)
**Problem B** (2 sorries): `dd_bfmcs_restricted_buc` + `dd_bfmcs_restricted_fuc` (lines 1391, 1396)

Problem B is about Until/Since coherence — the same class of problem that tasks 98+102 already solved via the quasimodel infrastructure (2,289 lines, sorry-free). Problem B may be closeable **without solving Problem A**.

### Finding 2: The Fold-Order Trick Was Never Actually Tested (Teammates A, B, C)

All three technical teammates independently identified that the fold-order trick — processing target LAST in `enriched_fwd_fold_with_witness` — was recommended in reports 18 and 19 but never implemented or tested. Plan v18's dead end #21 incorrectly characterizes it as "investigated."

**Mathematical analysis** (converged across all teammates):
- **Case 1** (F(β ∧ target) ∈ M): target ∈ M' via right conjunct extraction. **WORKS.**
- **Case 3** (F(F(β) ∧ target) ∈ M): target is the direct witness. **WORKS.**
- **Case 2** (F(β ∧ F(target)) ∈ M): gives F(target) ∈ M', not target ∈ M'. **FAILS.**

The trick eliminates Case 3 displacement (the most common failure mode) but Case 2 remains. Case 2 means "all other formulas' witnesses come before target" — target is deferred, not displaced.

**Confidence**: 35% that fold-order trick alone closes forward_F. Even if it fails, testing it concretely (2 hours) will clarify exactly where the never-resolved count argument needs to work.

### Finding 3: The buc/fuc Sorries Are Likely Closeable Now (Teammate D, Supported by B)

Teammate D identified that `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc` correspond to Until/Since eventuality obligations — exactly what `bx_until_eventuality_resolution` and `bx_until_backward` (proved sorry-free in tasks 98+102) handle. The `dd_fmcs` chain has g_content propagation (`dd_chain_g_content`, proved sorry-free), which is the key property needed to bridge.

**Proof sketch** (Teammate D):
1. Show `dd_fmcs` chain has same g_content propagation as `bx_fmcs`
2. Apply quasimodel lemmas (`LocusControl.lean`) for Until/Since witnesses
3. Translate witnesses back to chain indices

**Confidence**: 85% that buc/fuc are closeable independently of forward_F. Success would reduce active sorries from 6 to 4 (or 3 if backward_P follows from forward_F).

### Finding 4: Plan v18 Remains the Correct Long-Term Path for forward_F (All Teammates)

The ordered-discharge chain with never-resolved count termination is confirmed as the most mathematically sound approach:
- The never-resolved count is well-founded: bounded by |sigma_list|, strictly decreasing when a formula is first resolved, can never increase
- The key insight: separate target resolution (guaranteed by `discharge_single_step` at each step) from F-preservation (handled by the finite termination argument)
- The F-obligation constancy property (already proved) provides the structural backbone

**Effort estimate** (conflict resolved):
- Teammate A: 15-20 hours
- Teammate C (Critic): 30-50 hours (including ~30-40 downstream theorem re-proofs)
- Teammate D: 24-40 hours
- **Synthesis estimate**: 25-35 hours, accounting for Lean 4 formalization overhead on the ~30 downstream theorem re-proofs

### Finding 5: No Alternative Architecture Beats the Chain Approach (Teammate B)

Five alternatives analyzed, all closed:
| Architecture | Status | Reason |
|-------------|--------|--------|
| FMP via filtration | Closed | LTL lacks finite model property |
| Tree unraveling | Same obstacle | Termination argument identical to forward_F |
| Enriched resolving seed | Closed | Provably inconsistent (counterexample confirmed) |
| Deficiency induction | Closed | Defect count fluctuates (formulas resolved then lost) |
| BX12 (F(ψ) → ⊤ U ψ) | Closed | Produces abstract BXPoints, not chain indices |

### Finding 6: CanonicalModel.lean Sorries Are Dead Code (Teammate D)

5 additional sorries exist in `CanonicalModel.lean` but are NOT on the active completeness path (`bx_completeness` uses `dd_countermodel` from `RootScopedChain.lean`). These are candidates for deletion or explicit `sorry` markers without blocking path closure.

## Synthesis

### Conflicts Resolved

1. **Effort estimate for Plan v18**: Teammates disagreed (15-50 hours). Resolved: 25-35 hours is realistic, with the lower bound for mechanical re-proofs and upper bound for unexpected formalization obstacles.

2. **Fold-order trick viability**: Teammates A and C analyzed Case 2 differently but converged: Cases 1+3 work when target is last, Case 2 does not. The trick is worth testing (2h) but not a complete solution.

3. **Dead end #21 in ROAD_MAP**: Teammate C identified this as incorrectly listed (recommended for investigation, not actually investigated). Plan v18 Phase 1 already committed this to ROAD_MAP.md — it should be corrected in the next implementation attempt.

### Gaps Identified

1. **buc/fuc independent closure not attempted**: No previous research round systematically tried to close these using quasimodel infrastructure.
2. **Case 2 impossibility at visit steps**: Whether BX11 Case 2 can be ruled out when F(target) ∈ M at target's visit step remains unanalyzed.
3. **Backward chain symmetry**: Whether `rr_bwd_chain` has the same forward_F-like obstacle for P-obligations has not been explicitly verified.

### Recommendations

**Tier 1 — Immediate (5-10 hours): Close buc + fuc sorries**
- Attack `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc` using existing quasimodel infrastructure
- Independent of forward_F — can be done NOW
- Success reduces active sorries from 6 to 4
- Provides momentum and validates the infrastructure

**Tier 2 — Pre-attempt (2-4 hours): Test fold-order trick**
- Modify `enriched_fwd_fold_with_witness` to process target LAST
- Determine concretely whether Case 2 fires at visit steps
- Even if it fails, the result informs the never-resolved count formalization
- Correct dead end #21 in ROAD_MAP based on actual results

**Tier 3 — Primary (25-35 hours): Plan v18 ordered-discharge chain**
- Replace `enriched_fwd_step` with `target_resolving_fwd_step` using `discharge_single_step`
- Thread never-resolved count as well-founded termination measure
- Re-prove ~30 downstream theorems
- Close all remaining sorries (forward_F, backward_P, restricted_tc)

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary Approach | completed | high | Fold-order trick analysis, never-resolved count validation |
| B | Alternatives | completed | medium | 5 architectures evaluated, all closed; fold-order Case 2 analysis |
| C | Critic | completed | high | Found fold-order trick never tested; ROAD_MAP dead end #21 error; effort estimate revision |
| D | Horizons | completed | medium | buc/fuc independent closure path; CanonicalModel.lean dead code identification |

## References

- Plan v18: `specs/093_complete_bxcanonical_embedding/plans/18_bxcanonical-embedding.md`
- Round-robin chain history: `specs/093_complete_bxcanonical_embedding/reports/17_round-robin-chain-history.md`
- Team research reports 15-19 in `specs/093_complete_bxcanonical_embedding/reports/`
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (sorry sites at lines 1295, 1326, 1333, 1386, 1391, 1396)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (active completeness path)
- `Theories/Bimodal/Metalogic/Quasimodel/` (2,289 lines sorry-free Until/Since infrastructure)
