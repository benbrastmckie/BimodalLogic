# Research Report: Task #93 (Round 37)

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-17
**Mode**: Team Research (4 teammates)
**Session**: sess_1776446215_22d129

## Summary

Round 37 focused on the HintikkaStepOracle construction blocker: Until formula propagation through `bx_le`. All 4 teammates converge on the oracle being constructable, but with a critical correction to the seed construction. The oracle requires an **extended Lindenbaum seed** that includes all active Until defects alongside the target witness, not just bare `bx_forward_witness`. This seed is provably consistent. The oracle always takes the left branch (one-step discharge via BX8), making `hintikka_chain_exists` produce chains of length at most 2.

## Key Findings

### 1. The Blocker is Real but Mischaracterized (Teammate C, confirmed by A)

The `hintikka_step` Until propagation clause is **universally quantified**:
```
∀ φ ψ, (φ U ψ) ∈ h1 → ψ ∉ h1 → φ ∈ h1 ∧ (φ U ψ) ∈ h2
```

This requires ALL active Until defects from h1 to appear in h2, not just the oracle's target. Bare `bx_forward_witness` only guarantees `ψ_target ∈ v` (plus `g_content(w) ⊆ v`). Non-target Until formulas `(α U β)` are NOT in `g_content(w)` (they're not G-formulas), so they may not appear in `v`.

### 2. Extended Seed Resolves the Blocker (Teammate C, key insight)

The oracle should use an **extended Lindenbaum seed**:
```
seed = {ψ_target} ∪ g_content(w) ∪ {(α₁ U β₁), ..., (αk U βk)}
```
where `(αᵢ U βᵢ)` are all active Until defects from `w.formulas`.

**Consistency proof**: All elements except `ψ_target` are in `w.formulas` (g_content(w) ⊆ w by BX1, Until defects ∈ w by definition). The consistency follows from the same argument as `forward_temporal_witness_seed_consistent`: assume `L ⊢ ⊥` with `L ⊆ seed`. If `ψ_target ∉ L`, then `L ⊆ w.formulas`, contradicting `w` being MCS. If `ψ_target ∈ L`, then derive `¬ψ_target` from `L \ {ψ_target} ⊆ w.formulas`, but `F(ψ_target) ∈ w` gives contradiction via the same argument as the existing seed consistency proof.

The Lindenbaum extension of this seed gives `v'` with:
- `ψ_target ∈ v'` (target discharged)
- `g_content(w) ⊆ v'` (so `bx_le w v'`, enabling G-propagation and H-backward)
- All Until defects `(αᵢ U βᵢ) ∈ v'` (Until propagation satisfied)

### 3. All Three hintikka_step Clauses Are Satisfiable (Teammates A, C, D)

With the extended seed producing `v'` and `h2 = sigma_signature(v', Sigma)`:

| Clause | Mechanism | Key Lemma |
|--------|-----------|-----------|
| G-propagation | `G(χ) ∈ h1 → G(χ) ∈ w → χ ∈ v'` via `g_content(w) ⊆ v'` | `SubformulaClosure_G_closed` |
| H-backward | `H(χ) ∈ h2 → H(χ) ∈ v' → χ ∈ w` via `bx_H_forward` with `bx_le w v'` | `SubformulaClosure_H_closed`, `bx_H_forward` |
| Until propagation | Target: `ψ ∈ v' → (φ U ψ) ∈ v'` via BX8. Others: directly in seed | `refl_intro_until_mcs`, extended seed |

### 4. Oracle Always Takes Left Branch (Teammates A, D)

Since `ψ_target ∈ v'` directly (and `ψ ∈ Sigma` by `SubformulaClosure_untl_closed`), the oracle returns `Or.inl (ψ ∈ h')`. The defect_count decrease branch is NEVER needed. This eliminates the `defect_mono` concern entirely.

Consequence: `hintikka_chain_exists` produces chains of length at most 2 for this oracle. The chain is `[h0, h']` where `h'` has `ψ ∈ h'.formulas`.

### 5. Oracle Requires WitnessedHintikka Input (Teammate A)

`HintikkaStepOracle` takes arbitrary `HintikkaPoint Sigma`, but `bx_forward_witness` needs a BXPoint to start from. The oracle must be strengthened to accept `WitnessedHintikka` inputs. This is sound because:
- `hintikka_chain_exists` starts from a `WitnessedHintikka` input
- All oracle outputs are `WitnessedHintikka`
- The chain is always witnessed throughout

**Option A** (change `HintikkaStepOracle` signature to take `WitnessedHintikka`) is the cleanest fix.

### 6. Sorry Sites Split Into Two Independent Problems (Teammate B)

| Problem | Sorry Lines | Root Cause | Solution |
|---------|-------------|------------|----------|
| Eventualities (forward_F, backward_P) | 1413, 1457, 1464, 2196, 2289 | Depth-0 base case of `rr_fwd_chain_forward_F` | Oracle + chain OR self_resolving_fwd_step chain |
| Restricted coherence (tc, buc, fuc) | 1517, 1522, 1527 | Until/Since-resolving chain absent from `dd_bfmcs` | New BFMCS from quasimodel chain |

### 7. `self_resolving_fwd_step` Is a Viable Alternative for Forward_F (Teammate B)

The sorry-free `self_resolving_fwd_step` (lines 1961-1996) guarantees `ψ ∈ M'` directly (not disjunction). A round-robin chain using this step function avoids the BX11 perpetual deferral entirely. Key infrastructure already proved:
- `F_and_self_F_mcs`: `F(ψ) ∈ M → F(ψ ∧ F(ψ)) ∈ M`
- `self_resolving_fwd_step_target`: `ψ ∈ M'`
- `self_resolving_fwd_step_F_target`: `F(ψ) ∈ M'` (F-persistence)
- `self_resolving_fwd_step_g_content`: `g_content(M) ⊆ M'`

### 8. Backward Chain Diagnosis (Teammate B)

`defect_bwd_chain` uses `bwd_pred M hM Formula.bot` which is ALWAYS non-resolving (P(bot) never in any MCS). It should use `defect_bwd_step` (the resolving backward step at line ~1699, proved). This is a straightforward fix.

### 9. BX11 Fold Is Dead Code (Teammates B, D)

The BX11-based `enriched_fwd_step` / `resolving_enriched_fwd_exists` diverges from all known literature and is the root cause of 35+ rounds of failure. It resolves SOME formula each step but cannot guarantee WHICH one, leading to perpetual deferral. Should be annotated as dead code.

### 10. Literature Confirms the Approach (Teammate D)

Burgess (1982/1984), Reynolds (2003), and Gabbay-Hodkinson-Reynolds (1994) all use the same technique: sequential one-at-a-time defect discharge with Lindenbaum extension. The codebase's `Construction.lean` implements exactly this pattern. The oracle is the concrete realization of the Burgess step.

## Synthesis

### Conflicts Resolved

**Conflict 1: Does bare `bx_forward_witness` suffice for the oracle?**
- Teammates A, D: Yes, ψ ∈ v implies (φ U ψ) ∈ v by BX8
- Teammate C: No, non-target Until defects need explicit inclusion in seed
- **Resolution**: C is correct. BX8 handles the TARGET defect (ψ ∈ v → φ U ψ ∈ v), but OTHER active Until defects are not guaranteed in `v`. The extended seed is needed. However, the extended seed is trivially consistent (subset-of-MCS argument), so this is not a major obstacle -- just a correction to the construction.

**Conflict 2: Is the quasimodel layer necessary?**
- Teammate B: Alternatives exist (self_resolving chain, direct BXPoint chain)
- Teammate D: Quasimodel is the right abstraction
- **Resolution**: Both are correct for different sorry subsets. The quasimodel is needed for the 3 coherence sorries (1517, 1522, 1527). The self_resolving chain is simpler for the 5 eventualities sorries. The optimal approach uses BOTH.

### Gaps Identified

1. **Extended seed consistency formal proof**: The argument is clear but needs implementation (~50 LOC). Pattern matches `forward_temporal_witness_seed_consistent`.

2. **WitnessedHintikka oracle signature**: Requires modifying `HintikkaStepOracle` in Construction.lean and updating `hintikka_chain_exists` (~50-100 LOC change).

3. **Int extension**: Stitching forward and backward quasimodel chains into an Int-indexed FMCS. Non-trivial but standard (~200-400 LOC).

4. **Multiple Until defects per BFMCS family**: Each `hintikka_chain_exists` invocation handles ONE target defect. A BFMCS family needs ALL Until defects discharged. Need to compose multiple chain invocations or use iterative defect discharge.

5. **Backward Until coherence (restricted_buc)**: Requires backward induction from semantic witnesses to formula membership. Needs BX8-based reasoning at each step.

### Recommendations

**Revised Plan v36 Phase 1** (oracle construction, ~200-300 LOC):
1. Modify `HintikkaStepOracle` to accept `WitnessedHintikka` inputs
2. Prove extended seed consistency: `{ψ} ∪ g_content(w) ∪ {active Until defects}` is consistent
3. Build oracle via: `until_F_mcs` → extended Lindenbaum → `sigma_signature` → verify `hintikka_step`
4. Oracle always returns `Or.inl` (one-step discharge)

**Revised Plan v36 Phase 2** (BFMCS construction):
- Consider hybrid: use `self_resolving_fwd_step` chain for the `rr_fwd_chain` replacement (closes forward_F directly), and oracle + `hintikka_chain_exists` for Until/Since coherence on the new BFMCS.

**Quick win**: Try closing `dd_bfmcs_restricted_tc` (line 1517) directly from existing `dd_chain_g_content` + backward H lemmas (~100 LOC). This is independent of the main architecture.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Insight |
|----------|-------|--------|------------|-------------|
| A | Primary approaches | completed | High (90%) | Oracle feasible; WitnessedHintikka input needed |
| B | Alternatives | completed | High | self_resolving_fwd_step chain; backward chain diagnosis |
| C | Critic | completed | High | Extended seed needed for non-target Until defects |
| D | Horizons | completed | High | Literature confirms; one-step discharge; chain length ≤ 2 |

## References

### Literature
- Burgess (1982/1984): Axioms for Tense Logic I: "Since" and "Until"
- Reynolds (2003): Axiomatization of full computation tree logic
- Gabbay-Hodkinson-Reynolds (1994): Temporal Logic: Mathematical Foundations
- Finger-Gabbay (1996): Combining Temporal Logic Systems

### Codebase (sorry-free infrastructure)
- `Construction.lean`: `hintikka_chain_exists`, `hintikka_chain_exists_since`, `refl_intro_until_mcs`, `until_F_mcs`
- `Frame.lean`: `bx_forward_witness`, `bx_backward_witness`, `bx_H_forward`, `bx_le_refl`
- `RootScopedChain.lean`: `self_resolving_fwd_step` infrastructure (lines 1950-1996), `defect_bwd_step` (line ~1699)
- `HintikkaPoint.lean`: `sigma_signature`, `sigma_signature_mem`
- `Realization.lean`: `SubformulaClosure_G_closed`, `SubformulaClosure_H_closed`, `SubformulaClosure_untl_closed`
- `CanonicalChain.lean`: `F_imp_top_until_mcs` (BX12)
