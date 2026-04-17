# Research Report: Task #93

**Task**: Close TaskModel embedding sorry (sole remaining active-path sorry)
**Date**: 2026-04-17
**Mode**: Team Research (4 teammates)
**Session**: sess_1776435423_f21d0d

## Summary

Four-teammate deep study of the Quasimodel bridge approach for closing the `forward_F` / `backward_P` sorry sites. Three transformative discoveries emerged:

1. **BX12 axiom `F(φ) → ⊤ U φ`** reduces ALL F/P temporal coherence to Until/Since coherence — this is already an axiom in the system (Axioms.lean:258)
2. **The quasimodel infrastructure is sorry-free and well-built** (2132 LOC), but targets Until/Since only — NOT F-defects directly
3. **A round-robin chain with `self_resolving_fwd_step`** (~110 LOC) may close forward_F directly, bypassing the quasimodel entirely — but requires verifying non-target F-preservation

## Key Findings

### Primary Approach: BX12 Reduction (from Critic, Teammate C)

**The most important discovery**: BX12 (`F_until_equiv`, Axioms.lean:258) states:
```
F(φ) → (⊤ U φ)    where ⊤ = ⊥ → ⊥
```
And BX12' (`P_since_equiv`, Axioms.lean:263):
```
P(φ) → (⊤ S φ)
```

This means **all 8 sorry sites reduce to Until/Since coherence**:

| Sorry Site | Line | Reduces To |
|-----------|------|-----------|
| `rr_fwd_chain_forward_F` base | 1413 | Until coherence via BX12 |
| `dd_fmcs_forward_F` | 1457 | Until coherence via BX12 |
| `dd_fmcs_backward_P` | 1464 | Since coherence via BX12' |
| `dd_bfmcs_restricted_tc` | 1517 | Until/Since coherence via BX12/BX12' |
| `dd_bfmcs_restricted_buc` | 1522 | Direct Until/Since (no BX12 needed) |
| `dd_bfmcs_restricted_fuc` | 1527 | Direct Until/Since (no BX12 needed) |
| `defect_fwd_chain_forward_F` | 2196 | Until coherence via BX12 |
| `defect_bwd_chain_backward_P` | 2289 | Since coherence via BX12' |

**The reduction works as follows**: Given F(ψ) ∈ fam.mcs(t):
1. By BX12: (⊤ U ψ) ∈ fam.mcs(t)
2. By Until coherence: ∃ s ≥ t with ψ ∈ fam.mcs(s) and ⊤ ∈ fam.mcs(r) for r ∈ [t,s)
3. Guard ⊤ holds trivially (⊥ ∉ MCS is proved)
4. If ψ ∈ fam.mcs(t): witness s = t
5. If ψ ∉ fam.mcs(t): s > t, giving strict forward_F

**Closure alignment gap**: `restricted_forward_until_since_coherent` quantifies over `subformulaClosure(root)`, but `⊤ U ψ` (from BX12) is NOT in `subformulaClosure(root)`. Three fixes:
1. Widen restricted coherence to include BX12-derived Until formulas (~70 LOC)
2. Extend `extendedDeferralClosure` to include `⊤ U ψ` (~30 LOC)
3. **Cleanest**: Prove FULL (unrestricted) Until/Since coherence, then derive restricted as corollary

### Alternative Approaches (from Teammates A, B, D)

**Quasimodel Infrastructure Audit (Teammate A)**:
- ALL 6 Quasimodel/ files + 2 Filtration/ files are sorry-free (2132 LOC)
- `hintikka_chain_exists` is proved but requires a `HintikkaStepOracle` that has never been constructed
- `hintikka_step` handles G-propagation and Until-defects, NOT F-defects
- G-persistence obstacle: `hintikka_step` gives G(χ) ∈ h₁ → χ ∈ h₂, but NOT G(χ) ∈ h₂
- HintikkaRawChain produces finite lists of HintikkaPoints, NOT Int-indexed FMCS
- **Assessment**: Direct quasimodel bridge for F is the WRONG path; BX12 reduction changes the picture

**Bundle Analysis (Teammate B)**:
- Forward witness seed = `{ψ} ∪ g_content(M)`, confirmed NO f_carry — Path B (round-robin fwd_succ) is blocked
- `self_resolving_fwd_step` (lines 1961-1996): Given F(ψ) ∈ M, builds M' with ψ ∈ M' AND F(ψ) ∈ M' AND g_content(M) ⊆ M'
- `defect_fwd_chain_F_obligation_persists`: F(ψ) ∈ chain(n) → F(ψ) ∈ chain(n+1) (proved)
- f_carry cannot be added to basic resolving seed (potential inconsistency with F(A) and F(¬A))
- `bx_forward_witness` / `bx_backward_witness` exist at frame level (Frame.lean:164-185)

**Literature Review (Teammate D)**:
- Standard Henkin construction uses sequential targeting with round-robin — NOT simultaneous multi-defect
- The codebase's BX11-fold (simultaneous resolution) diverges from standard technique — root cause of obstruction
- `self_resolving_fwd_step` + round-robin could work in ~110 LOC
- Critical verification: does `self_resolving_fwd_step` preserve F(ψ_j) for non-target j?
- Literature confirms: F-persistence across steps is standard; the issue is discharge, not preservation

### Gaps and Shortcomings (from Critic, Teammate C)

1. **Closure alignment is the main technical risk**: `⊤ U ψ` not in subformulaClosure(root) means the restricted Until/Since coherence doesn't cover BX12-derived formulas. Must prove FULL coherence or extend the closure.

2. **G-persistence obstacle persists**: Even with BX12, lifting HintikkaPoints to MCS faces the G-persistence gap (Realization.lean:370-395). Chain extraction from quasimodel still requires solving this.

3. **Report 34 fairness claim is incorrect**: No infinite unfolding or fairness exists in the quasimodel — it produces FINITE chains. This doesn't matter for Until/Since coherence (finite witnesses suffice), but invalidates the "infinite fair schedule" narrative.

4. **HintikkaStepOracle never constructed**: `hintikka_chain_exists` is proved but the oracle it needs has never been built. This is the remaining construction gap.

5. **Non-target F-preservation unverified**: The round-robin alternative depends on `self_resolving_fwd_step` preserving non-target F-obligations. Its seed is `{ψ} ∪ g_content(M)` — this does NOT include f_carry, so non-target F(χ) is NOT guaranteed in M'. **This likely kills the 110-LOC round-robin approach for multi-defect.**

### Strategic Horizons (from Teammate D)

- Mosaic method for bimodal S5+temporal (Logica Universalis 2012) is theoretically optimal but requires substantial new infrastructure
- Quasimodel bridge has benefits beyond forward_F: decidability infrastructure, reusable for other logics, cleaner modular architecture
- Short-term recommendation: close forward_F via BX12 + Until/Since coherence
- Medium-term: extend quasimodel to also handle F-defects (unifying Until and F discharge)

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| A says quasimodel won't work for F; C says BX12 bridges the gap | **C is correct**: BX12 makes F reducible to Until. A's analysis is right that quasimodel doesn't handle F directly, but with BX12 it doesn't need to. |
| D proposes 110-LOC round-robin; B says f_carry missing from seed | **B is correct**: `self_resolving_fwd_step` seed is `{ψ} ∪ g_content(M)` without f_carry. Non-target F-obligations are NOT preserved. The 110-LOC approach likely fails for multi-defect (same obstruction as rejected approach #4). |
| A says oracle never constructed; C says oracle not needed for BX12 path | **Both correct**: For the BX12 reduction path, we need Until/Since coherence, which needs the oracle. The oracle construction IS the remaining work. |

### Gaps Identified

1. **HintikkaStepOracle construction** (~200-300 LOC): The oracle must produce, for each HintikkaPoint with an Until-defect, a next HintikkaPoint that either resolves the defect or strictly decreases defect_count. This requires using `bx_forward_witness` at the frame level to find backing BXPoints.

2. **Chain lifting: HintikkaPoint → MCS** (~200-300 LOC): Each HintikkaPoint in the chain needs to be extended to a full MCS via Lindenbaum. The G-persistence obstacle means the lifted chain may not have full G-propagation — but Sigma-restricted G-propagation may suffice for the restricted coherence predicate.

3. **Closure alignment** (~50-100 LOC): Either extend the closure to include BX12-derived Until formulas, or prove full (unrestricted) Until/Since coherence.

4. **Integration with dd_fmcs** (~100-200 LOC): Connect the quasimodel-derived Until/Since coherence proofs to the specific sorry site signatures in RootScopedChain.lean.

### Recommendations

**Recommended Strategy**: BX12 Reduction + Quasimodel Until/Since Coherence

1. **Phase 0 — Verification** (2-4 hours):
   - Confirm BX12 is usable: check that `F_until_equiv` has the exact type needed
   - Check closure alignment: what does `extendedDeferralClosure` contain?
   - Determine whether full or restricted Until/Since coherence is easier

2. **Phase 1 — Oracle Construction** (4-8 hours, ~200-300 LOC):
   - Build `HintikkaStepOracle` using `bx_forward_witness` from Frame.lean
   - Prove oracle produces valid steps with decreasing defect_count

3. **Phase 2 — Chain Extraction + Until/Since Coherence** (4-6 hours, ~200-300 LOC):
   - Extract the chain from `hintikka_chain_exists`
   - Prove Until/Since coherence for the extracted chain
   - Handle closure alignment (extend or prove full coherence)

4. **Phase 3 — BX12 Bridge + Sorry Closure** (3-5 hours, ~100-200 LOC):
   - Derive F/P temporal coherence from Until/Since via BX12/BX12'
   - Close sorry sites 1517, 1457, 1464, 1413
   - Close defect chain sorries 2196, 2289

5. **Phase 4 — Integration** (2-3 hours, ~100 LOC):
   - Wire into dd_bfmcs and completeness
   - Verify `lake build` passes

**Estimated total**: 600-900 LOC, 15-26 hours
**Success probability**: 65-75%

**Fallback**: If oracle construction is blocked, try extending `self_resolving_fwd_step` with f_carry enrichment (using BX11 to prove consistency of the enriched seed). This is a harder path but stays within the existing chain architecture.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Quasimodel infrastructure audit | completed | HIGH (audit), MEDIUM (recommendation) |
| B | Bundle infrastructure analysis | completed | HIGH |
| C | Critic - mathematical soundness | completed | MEDIUM-HIGH (65-75%) |
| D | Literature + strategic horizons | completed | MEDIUM-HIGH (70%) |

## References

### Codebase
- BX12 axiom: `Theories/Bimodal/ProofSystem/Axioms.lean:258`
- BX12' axiom: `Theories/Bimodal/ProofSystem/Axioms.lean:263`
- Quasimodel Construction: `BXCanonical/Quasimodel/Construction.lean`
- Quasimodel Realization: `BXCanonical/Quasimodel/Realization.lean`
- HintikkaPoint: `BXCanonical/Quasimodel/HintikkaPoint.lean`
- SubformulaClosure: `BXCanonical/Quasimodel/SubformulaClosure.lean`
- DefectChain: `BXCanonical/Filtration/DefectChain.lean`
- SigmaOrdering: `BXCanonical/Filtration/SigmaOrdering.lean`
- RootScopedChain sorry sites: `BXCanonical/RootScopedChain.lean:1413,1457,1464,1517,1522,1527,2196,2289`
- self_resolving_fwd_step: `BXCanonical/RootScopedChain.lean:1961-1996`
- F_obligation_persists: `BXCanonical/RootScopedChain.lean:2120-2133`
- bx_forward_witness: `BXCanonical/Frame.lean:164-171`
- WitnessSeed: `Bundle/WitnessSeed.lean:50-51`
- TemporalCoherence: `Bundle/TemporalCoherence.lean:147-153`

### Literature
- Goldblatt (1992): "Logics of Time and Computation" — Henkin chain construction
- Burgess (1984): "Basic tense logic" — defect-discharge for Until
- Reynolds (1996, 2003): Quasimodel technique for decidability
- Gabbay, Hodkinson, Reynolds (1994): "Temporal Logic: Mathematical Foundations"
- Marx, Mikulas, Reynolds (2000): "The Mosaic Method for Temporal Logics"
- Logica Universalis (2012): Extended mosaics for bimodal S5+temporal
- Verbrugge (2004): "Completeness by Construction for Tense Logics"
