# Research Report: Task #881

**Task**: Construct modally saturated BMCS to eliminate fully_saturated_bmcs_exists axiom
**Date**: 2026-02-13
**Mode**: Team Research (2 teammates)

## Summary

Research identifies a clear path to eliminate the `fully_saturated_bmcs_exists` axiom through S5 negative introspection. The key breakthrough is that axiom 5 (`neg(Box phi) -> Box(neg(Box phi))`), derivable from the existing `modal_5_collapse` axiom, ensures BoxContent invariance when extending MCS via Lindenbaum. This resolves all 3 sorries in `SaturatedConstruction.lean`. Full integration with temporal coherence requires a two-tier construction combining the proven temporal infrastructure (RecursiveSeed/ZornFamily) with the modal saturation construction.

## Key Findings

### 1. The Axiom Structure

Three related axioms exist in the codebase:

| Axiom | File:Line | Status |
|-------|-----------|--------|
| `fully_saturated_bmcs_exists` | TemporalCoherentConstruction.lean:773 | Target for elimination |
| `saturated_extension_exists` | CoherentConstruction.lean:871 | Subsumed by target |
| `singleFamily_modal_backward_axiom` | Construction.lean:219 | Known FALSE |

The target axiom requires three simultaneous properties:
1. **Context preservation**: `Gamma` formulas in `B.eval_family.mcs 0`
2. **Temporal coherence**: `B.temporally_coherent` (forward_F, backward_P)
3. **Modal saturation**: `is_modally_saturated B` (Diamond witnesses)

### 2. S5 Negative Introspection Breakthrough (Teammate A)

**The Key Insight**: S5 axiom 5 (negative introspection) resolves all 3 sorries.

From the existing `Axiom.modal_5_collapse` (`Diamond(Box phi) -> Box phi`), the contrapositive gives:
```
neg(Box phi) -> neg(Diamond(Box phi)) = Box(neg(Box phi))
```

This is the S5 negative introspection axiom.

**BoxContent Invariance Lemma**: If W_set is any MCS extending `BC_fam = {chi | Box chi in fam.mcs t}`, then `{chi | Box chi in W_set} = BC_fam`.

**Proof sketch**:
1. Suppose `Box alpha in W_set` but `Box alpha not in fam.mcs 0`
2. Then `neg(Box alpha) in fam.mcs 0` (MCS negation completeness)
3. By axiom 5: `Box(neg(Box alpha)) in fam.mcs 0`
4. So `neg(Box alpha) in BC_fam` subseteq `W_set`
5. But `Box alpha in W_set` and `neg(Box alpha) in W_set` contradicts MCS consistency
6. Therefore `Box alpha in fam.mcs 0`, so `{chi | Box chi in W_set} = BC_fam`

### 3. Resolution of the 3 Sorries in SaturatedConstruction.lean

| Sorry | Location | Root Cause | Resolution via Axiom 5 |
|-------|----------|------------|------------------------|
| Sorry 1 (line 985) | `h_witness_set_consistent` psi-in-L case | BoxContent collection from all families/times | Use restricted `BC_fam = {chi | Box chi in fam.mcs 0}` + `diamond_box_coherent_consistent` |
| Sorry 2 (line 1005) | `h_witness_set_consistent` psi-not-in-L case | L subseteq fam.mcs t propagation | `BC_fam subseteq fam.mcs t` by T-axiom |
| Sorry 3 (line 1069) | `h_extended_coherence` for witness family | Lindenbaum adds uncontrolled boxes | BoxContent invariance lemma via axiom 5 |

### 4. EvalCoherentBundle Infrastructure (Teammate B)

The `EvalCoherentBundle` approach in CoherentConstruction.lean is the most developed path:

| Component | Status | Purpose |
|-----------|--------|---------|
| `diamond_boxcontent_consistent_constant` | Proven | WitnessSeed consistency for constant families |
| `EvalCoherentBundle.addWitness` | Proven | Add single witness preserving EvalCoherent |
| `addWitness_preserves_EvalCoherent` | Proven | Invariant preservation |
| `addWitnessesForList` | Defined | Iterate over Diamond formulas |

**Key Advantage**: EvalCoherent only requires BoxContent(eval_family), which is fixed permanently at construction time.

### 5. Prior Art Analysis (Teammate B)

| Approach | What Failed | Lesson |
|----------|-------------|--------|
| CoherentBundle + Zorn | Lindenbaum adds uncontrolled boxes | UnionBoxContent grows, creating circular dependency |
| FDSM (Boneyard) | `mcsTrackedHistory_finite` sorry | World-state-to-MCS gap |
| RecursiveSeed | Only structural witnesses | Pre-placement incomplete for F/P |

### 6. Temporal Coherence Integration

Constant families satisfy modal saturation cleanly but NOT temporal coherence (forward_F, backward_P). Two options:

**Option A: Two-Tier Construction (Recommended)**
1. First tier: Temporally coherent families from RecursiveSeed/ZornFamily
2. Second tier: Modal witness families (constant) from Lindenbaum extension
3. Prove combined set maintains box_coherence using constant witness BoxContent invariance

**Option B: EvalBMCS Path**
1. Use EvalCoherentBundle for eval-centered saturation
2. Weaken axiom if completeness only needs eval_family properties
3. Audit downstream usage in Completeness.lean

## Conflicts Resolved

**Conflict 1**: Teammate A recommends constant families + Zorn; Teammate B recommends single-step EvalCoherentBundle.
**Resolution**: Both paths converge on the same mathematical insight (BoxContent invariance via axiom 5). The single-step construction is simpler for constant families; EvalCoherentBundle provides more infrastructure.

**Conflict 2**: Iteration vs single-step for witness construction.
**Resolution**: Single-step is sufficient when using constant families. The witness families don't introduce NEW unsatisfied Diamond formulas because BoxContent is invariant.

## Gaps Identified

1. **Axiom 5 derivation**: Not yet formalized as a standalone theorem (straightforward from 5-collapse)
2. **BoxContent invariance lemma**: Needs Lean proof (argument verified via lean_run_code)
3. **Temporal + Modal integration**: Two-tier construction architecture not yet implemented
4. **Downstream audit**: Need to verify if full `is_modally_saturated` is required or EvalBMCS suffices

## Recommendations

### Phase 1: Prove Axiom 5 (2-3 hours)
Derive `neg(Box phi) -> Box(neg(Box phi))` from `modal_5_collapse` contrapositive + DNE.

### Phase 2: Prove BoxContent Invariance (3-5 hours)
Formalize the lemma that Lindenbaum extension of `{psi} union BC_fam` preserves BoxContent.

### Phase 3: Fix 3 Sorries (8-12 hours)
Apply restricted BoxContent + invariance lemma to SaturatedConstruction.lean.

### Phase 4: Temporal Integration (12-20 hours)
Two-tier construction:
1. Build temporally coherent families (RecursiveSeed, already 0 sorries)
2. Add constant witness families for modal saturation
3. Prove combined BMCS satisfies all properties

### Phase 5: Replace Axiom (3-5 hours)
Replace `fully_saturated_bmcs_exists` with constructive proof, update downstream usage.

**Total Estimate**: 28-45 hours (aligned with task effort estimate of 40-60 hours)

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary approach | completed | Medium-High | S5 axiom 5 breakthrough, BoxContent invariance proof |
| B | Alternatives | completed | Medium-High | EvalCoherentBundle analysis, prior art post-mortem |

## References

### Codebase
- TemporalCoherentConstruction.lean:773 - Target axiom
- ModalSaturation.lean:94 - `is_modally_saturated` definition
- SaturatedConstruction.lean:757 - 3 sorries to fix
- CoherentConstruction.lean:249 - `diamond_boxcontent_consistent_constant`
- Boneyard/FDSM/ModalSaturation.lean - Prior attempt

### Task Reports
- specs/880_augmented_extension_seed_approach/summaries/implementation-summary-20260213.md - RecursiveSeed 0 sorries
- specs/870_zorn_family_temporal_coherence/reports/research-008.md - Temporal coherence research

## Next Steps

1. Formalize axiom 5 derivation
2. Prove BoxContent invariance lemma
3. Create implementation plan with phased approach
4. Execute Phases 1-5 to eliminate axiom
