# Research Report: Task #880 (Wave 3 Synthesis)

**Task**: Controlled Lindenbaum vs DovetailingChain Analysis
**Date**: 2026-02-12
**Mode**: Team Research (2 teammates)
**Session**: sess_1770945520_0342af
**Focus**: Zero-sorry path analysis for temporal coherent family construction

## Summary

This team research synthesizes findings from two specialized investigations into the remaining 5 sorries in ZornFamily.lean and the alternative DovetailingChain.lean approach. The unanimous conclusion is to **pivot to DovetailingChain** for the following reasons:

1. **ZornFamily has theorem-level flaws**: Universal `forward_F` is mathematically incompatible with domain extension; `maximal_implies_total` may be false
2. **DovetailingChain has a clear zero-sorry path**: ~15-21 hours of well-understood engineering work
3. **Controlled Lindenbaum is high-risk**: No existing infrastructure, novel technique required, ~25-40 hours with uncertain outcome
4. **Shared mathematical foundation**: Both approaches use the proven `temporal_witness_seed_consistent` lemma

## Key Findings

### 1. ZornFamily.lean Fundamental Blockers (from Teammate A)

**Universal forward_F is incompatible with domain extension**:

The `forward_F` structural field (now removed) required:
```
F(phi) in mcs(s) implies phi in mcs(t) for ALL t > s in domain
```

**Counterexample proving this is impossible**:
- Base family: domain = {0}, mcs(0) contains both F(p) and F(neg(p))
- This is consistent because F(p) = "p holds at some future time" and F(neg(p)) = "neg(p) holds at a different future time"
- Extending to domain = {0, 1} requires:
  - F(p) in mcs(0) implies p in mcs(1)
  - F(neg(p)) in mcs(0) implies neg(p) in mcs(1)
- But {p, neg(p)} contradicts mcs(1) being an MCS

**Consequence**: Zorn may yield maximal families with domain = {0} because extension is impossible. The proof of `maximal_implies_total` is inherently blocked.

### 2. Controlled Lindenbaum Feasibility (from Teammate A)

**Required infrastructure does not exist**:
- No Mathlib lemma for "extend consistent set to MCS while preserving property P"
- GH-controlled Lindenbaum would need to:
  - Enumerate formulas
  - Skip formulas that would violate G/H constraints
  - Prove the result is still maximal consistent

**Assessment**: High-risk, high-effort (~15-25 hours for infrastructure alone), uncertain success

### 3. DovetailingChain Analysis (from Teammate B)

**Current sorry inventory** (4 total):

| Line | Sorry | Root Cause |
|------|-------|------------|
| 606 | forward_G (t < 0) | Cross-sign propagation |
| 617 | backward_H (t >= 0) | Cross-sign propagation |
| 633 | forward_F | Witness construction |
| 640 | backward_P | Witness construction |

**Cross-sign propagation solution**:
1. Leverage the shared base MCS at index 0
2. G phi in M_t (t < 0) propagates via backward chain to M_0
3. G phi in M_0 propagates via forward chain to all M_{t'} (t' > 0)
4. Global lemma connects both chains through M_0

**Witness construction solution**:
1. Use proven `temporal_witness_seed_consistent` (single witness + GContent = consistent)
2. Use proven `past_temporal_witness_seed_consistent` (single witness + HContent = consistent)
3. Implement dovetailing enumeration (Nat.pair/unpair + Encodable Formula)
4. Modify seed construction to include witness obligations at appropriate steps

### 4. Comparative Effort Analysis (Both Teammates)

| Metric | DovetailingChain | ZornFamily |
|--------|------------------|------------|
| Estimated effort | 15-21 hours | 29-45 hours |
| Risk level | Low-Medium | High |
| Blocking issues | None | Theorem-level flaws |
| Path clarity | Clear | Requires redesign |
| Existing infrastructure | temporal_witness_seed_consistent | None for controlled Lindenbaum |

## Synthesis

### Conflicts Resolved

No conflicts - both teammates independently concluded that:
- ZornFamily has fundamental mathematical issues that cannot be resolved with reasonable effort
- DovetailingChain has a tractable path to zero sorries
- The single-witness approach (`temporal_witness_seed_consistent`) is the correct granularity

### Gaps Identified

1. **DovetailingChain cross-sign lemma**: Needs careful formulation using shared base
2. **Dovetailing enumeration**: Requires Nat.pair/unpair, Encodable Formula instance
3. **Seed modification**: DovetailingChain seeds must include witness obligations

### Zero-Sorry Path (DovetailingChain)

| Phase | Work | Hours | Risk |
|-------|------|-------|------|
| 1 | Global cross-sign propagation lemma via shared base | 6-8 | Low |
| 2 | Dovetailing enumeration infrastructure | 4-5 | Low |
| 3 | forward_F/backward_P with witness inclusion | 6-8 | Medium |
| **Total** | | **15-21** | **Low-Medium** |

## Recommendations

### Primary Recommendation: Pivot to DovetailingChain

**Rationale**:
1. Mathematical soundness - the approach has no theorem-level flaws
2. Proven infrastructure - `temporal_witness_seed_consistent` handles the core case
3. Clear implementation path - each sorry has a known resolution strategy
4. Lower effort and risk - 15-21 hours vs 29-45 hours with high uncertainty

### Implementation Approach

**Phase 1: Cross-Sign Propagation (6-8 hours)**
- Create global lemma: `G phi in M_t => G phi in M_0 => phi in M_{t'}` for any t < 0 < t'
- Key insight: Both chains share M_0, which acts as a bridge
- Use existing `dovetailForwardChain_G_propagates` as template

**Phase 2: Dovetailing Enumeration (4-5 hours)**
- Implement `Encodable Formula` instance (if not exists)
- Define witness enumeration: `witnessObligation : Nat -> Option (Int × Formula)`
- Prove completeness: every F/P obligation is eventually enumerated

**Phase 3: Witness Construction (6-8 hours)**
- Modify `dovetailForwardChainMCS` to include F-witness at appropriate step
- Modify `dovetailBackwardChainMCS` to include P-witness at appropriate step
- Prove `buildDovetailingChainFamily_forward_F` using enumeration completeness
- Prove `buildDovetailingChainFamily_backward_P` symmetrically

### Fallback Path

If DovetailingChain proves unexpectedly difficult:
1. Document learnings as technical debt in SORRY_REGISTRY.md
2. Consider weakening theorem statement (G/H coherence only, without F/P)
3. Archive ZornFamily attempts in Boneyard with comprehensive documentation

## Teammate Contributions

| Teammate | Focus | Status | Confidence |
|----------|-------|--------|------------|
| A | Controlled Lindenbaum feasibility, ZornFamily blocker analysis | Completed | High |
| B | DovetailingChain comparison, effort estimation, zero-sorry path | Completed | High |

## Evidence (Verified via lean_local_search)

### Proven Infrastructure Available
- `temporal_witness_seed_consistent` - single F-witness seed is consistent
- `past_temporal_witness_seed_consistent` - single P-witness seed is consistent
- `dovetail_GContent_consistent` - GContent of MCS is consistent
- `dovetail_HContent_consistent` - HContent of MCS is consistent
- `dovetailForwardChain_G_propagates` - G propagates along forward chain
- `dovetailBackwardChain_H_propagates` - H propagates along backward chain
- `chains_share_base` - forward and backward chains share M_0
- `set_lindenbaum` - Lindenbaum extension exists

### Missing (To Be Implemented)
- Global cross-sign propagation lemma
- Dovetailing enumeration infrastructure
- Witness seed modification in chain construction

## Strategic Decision Point

**Task 880 should transition from ZornFamily exploration to DovetailingChain completion.**

The work done on ZornFamily (Phases 1-4) was not wasted:
1. Confirmed that universal forward_F is incompatible with domain extension
2. Proved cross-sign seed consistency (reusable insight)
3. Identified that single-witness approach is correct (shared with DovetailingChain)
4. Eliminated false lemmas and simplified structure (cleaner codebase)

**Next Action**: Create new implementation plan for DovetailingChain completion based on this research.

## References

- ZornFamily.lean: `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`
- DovetailingChain.lean: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- TemporalContent.lean: `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean`
- Task 843 research: `specs/843_remove_singleFamily_modal_backward_axiom/reports/`
- Teammate A findings: `specs/880_augmented_extension_seed_approach/reports/research-003.md`
- Teammate B findings: `specs/880_augmented_extension_seed_approach/reports/teammate-b-dovetail-comparison.md`

## Next Steps

1. **Create implementation plan** for DovetailingChain completion (task 880 or new task)
2. **Execute Phase 1**: Global cross-sign propagation lemma
3. **Execute Phase 2**: Dovetailing enumeration infrastructure
4. **Execute Phase 3**: F/P witness proofs
5. **Verify**: `lake build` passes with 0 sorries in DovetailingChain.lean
