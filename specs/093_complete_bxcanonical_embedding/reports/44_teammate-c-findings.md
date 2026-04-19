# Teammate C (Critic) Findings - Round 44: Quasimodel Bridge Gap Analysis

## Key Findings

### 1. CRITICAL: The Oracle Construction Has 7 Sorries (Not Sorry-Free)

**Verdict: The bridge partially collapses.**

The claim that `hintikka_chain_exists` is "sorry-free" is **misleading**. While `hintikka_chain_exists` itself (Construction.lean:594-659) is indeed sorry-free, it takes a `HintikkaStepOracle` as a **parameter**. The actual oracle construction in OracleStep.lean contains **7 sorry sites**:

1. **`hintikka_step_oracle` (line 302)** - the universal oracle - has **5 sorries**:
   - H-backward (line 341): `χ ∈ w.formulas` but cannot conclude `χ ∈ h.formulas` without `h = sigma_sig(w)`
   - Until-propagation guard (line 348): same structural gap
   - `ψ' ∈ w'` when `ψ' ∈ w` but `bx_le` only gives `g_content(w) ⊆ w'` (line 367)
   - `φ U ψ ∈ w'` when `ψ ∈ w` (line 386): cannot prove without `ψ ∉ w`
   - Defect-count decrease (line 393): `sorry`

2. **`hintikka_step_or_condition_sigma_sig` (line 272)** - defect_count decrease for sigma_sig: **1 sorry**
   - Sub-case (b) blocks defect monotonicity: Lindenbaum may introduce new Until-defects

3. **`hintikka_step_oracle_for_sigma_sig` (line 452)** - the "fully sorry-free" oracle for sigma_sig inputs: **1 sorry**
   - Same defect-count decrease problem at line 452

**The sorry-free claim at line 411 ("Fully sorry-free oracle") is FALSE.** The theorem itself has a sorry at line 452. Only `hintikka_step_for_sigma_sig` (line 188-222) is genuinely sorry-free -- but it only proves `hintikka_step`, not the OR-condition with defect-count decrease.

### 2. CRITICAL: The Defect-Count Decrease Problem Is Fundamental

All three oracle variants (universal, sigma_sig-specific, SubformulaClosure) fail at the **same** point: proving that `defect_count` strictly decreases. The obstacle documented at OracleStep.lean:260-272:

> Sub-case (b) blocks the general proof of defect_mono: `f U g` added by Lindenbaum (not in seed) may create NEW defects at the oracle step that were not defects at the original point.

This is not a technicality. Lindenbaum extension is **non-constructive** (Classical.choice). The extended MCS `w'` may contain arbitrary Until-formulas beyond those in the seed. There is no way to control which Until-formulas Lindenbaum adds, so defect monotonicity (`untilDefectSet(h2) ⊆ untilDefectSet(h1)`) is **unprovable** from the current construction.

**Impact**: Without defect-count decrease, `hintikka_chain_exists` cannot terminate its well-founded recursion. The chain construction itself is correct conditional on the oracle, but the oracle's termination guarantee is broken.

### 3. The BXPoint Witness Problem - Relocated, Not Solved

**Weakness 2 confirmed.** The quasimodel approach does NOT avoid the Lindenbaum control problem; it relocates it:

- `qm_oracle_step` (OracleStep.lean:87-91) uses `set_lindenbaum` to extend the oracle seed
- This is the SAME non-constructive mechanism used in `dd_chain`
- The new BXPoint `w'` has uncontrolled formulas outside the seed
- This is exactly what causes the defect-count decrease sorry

The `WitnessedHintikka` structure (Construction.lean:459-466) correctly tracks BXPoint witnesses, but the witnesses themselves come from Lindenbaum extension with the same control deficit.

### 4. G-Content Propagation - Partially Works

**Weakness 3 partially survives critique.** `SubformulaClosure_G_closed` (Realization.lean:562-571) proves that `G(χ) ∈ SubformulaClosure(target) → χ ∈ SubformulaClosure(target)`. Similarly for H-closure and U-closure.

However, the **enrichedClosure** (EnrichedClosure.lean:58-63) adds `G(neg_bigconj T)` and `H(neg_bigconj T)` formulas that are NOT in SubformulaClosure. The G/H/U-closure properties for enrichedClosure are **not proven**. If the quasimodel bridge needs `Sigma = enrichedClosure target` rather than `SubformulaClosure target`, the closure properties would need re-verification.

### 5. CRITICAL: The Family Structure Problem Is Unaddressed

**Weakness 4 confirmed.** The quasimodel chain gives a FINITE Nat-indexed sequence of HintikkaPoints. The BFMCS needs an `Int → MCS` family. No code exists to:

- Extend a finite quasimodel chain to a bi-infinite `Int → MCS` chain
- Handle negative indices (the backward direction)
- Compose the quasimodel chain with the existing `dd_chain` structure

The `dd_chain` in RootScopedChain.lean uses `fwd_chain_of_sigma` for positive indices and `bwd_chain_of_sigma` for negative indices. The quasimodel chain is a completely separate infrastructure with no integration point.

### 6. The Multi-Defect Problem Is Partially Handled

**Weakness 5 partially addressed.** The `qm_oracle_seed` (OracleStep.lean:66-69) includes ALL Until-defects from Sigma in a single seed:

```
{f | ∃ φ ψ, f = φ U ψ ∧ φ U ψ ∈ w ∧ ψ ∉ w ∧ φ U ψ ∈ Sigma}
```

This means the oracle step addresses ALL Until-defects simultaneously (not just one target). The `hintikka_chain_exists` only tracks ONE target for termination, but the oracle seed carries all defects forward. This is a reasonable design -- the chain terminates when the TARGET is discharged, and other defects are carried along.

However, the composition problem remains: `restricted_fuc` needs ALL Until formulas in `deferralClosure(root)` eventually discharged, requiring multiple sequential chain constructions. No composition theorem exists.

### 7. Backward Direction - Exists But Same Sorries

**Weakness 6 partially addressed.** `hintikka_chain_exists_since` (Construction.lean:769-824) and `HintikkaStepOracleSince` (Construction.lean:701-707) exist. `qm_oracle_step_bwd` (OracleStep.lean:150-155) provides the backward oracle step.

However, the backward oracle (`HintikkaStepOracleSince`) construction is **missing entirely** -- no backward analog of `hintikka_step_oracle` exists in OracleStep.lean. Only the forward oracle is constructed.

### 8. CRITICAL: The restricted_buc Problem Is Not Addressed

**Weakness 8 confirmed.** `restricted_buc` (RootScopedChain.lean:1147-1153) requires: if the semantic Until condition holds in the chain, then `φ U ψ ∈ mcs(t)`. The quasimodel chain DISCHARGES existing Until-defects (removes `φ U ψ` by reaching `ψ`). But `restricted_buc` needs the REVERSE direction: INTRODUCING `φ U ψ` into MCSs based on semantic evidence. No quasimodel infrastructure addresses this.

### 9. Quasimodel Infrastructure Is NOT Used In Any Sorry-Free Code Path

**Weakness 9 confirmed.** Searching the codebase:

- `bx_until_eventuality_resolution` (Frame.lean:623-644) is **sorry-free** and does NOT use quasimodel infrastructure
- `bx_until_eventuality_resolution'` (LocusControl.lean:32-37) delegates to the Frame.lean version
- The quasimodel chain is never consumed by RootScopedChain.lean
- The 3 remaining sorries (`restricted_tc`, `restricted_buc`, `restricted_fuc`) are in the `dd_chain` framework, which has NO import of quasimodel modules

The quasimodel infrastructure is entirely self-contained and disconnected from the actual sorry sites.

## Summary: Sorry Inventory

| Location | Sorry Count | Blocking? |
|----------|------------|-----------|
| OracleStep.lean `hintikka_step_oracle` | 5 | Yes - universal oracle unusable |
| OracleStep.lean `hintikka_step_or_condition_sigma_sig` | 1 | Yes - defect decrease |
| OracleStep.lean `hintikka_step_oracle_for_sigma_sig` | 1 | Yes - defect decrease |
| RootScopedChain.lean `fwd_chain_forward_F` | 1 | Yes - F-resolution termination |
| RootScopedChain.lean `dd_bfmcs_restricted_tc` | 2 | Yes - backward + P-direction |
| RootScopedChain.lean `dd_bfmcs_restricted_buc` | 1 | Yes - backward Until coherence |
| RootScopedChain.lean `dd_bfmcs_restricted_fuc` | 1 | Yes - forward Until coherence |

## Recommended Approach

**The quasimodel bridge approach CANNOT work as currently conceived.** The fundamental obstacles are:

1. **Defect-count decrease is unprovable** with Lindenbaum-based oracle steps (affects ALL oracle variants)
2. **No integration point** between quasimodel chains and dd_chain/BFMCS infrastructure
3. **restricted_buc requires the reverse direction** (introducing Until, not discharging it)
4. **No backward oracle construction** exists

**Alternative directions worth investigating:**

1. **Deterministic chain construction**: Replace Lindenbaum extension with a deterministic MCS construction that controls exactly which formulas appear. This would solve defect monotonicity.

2. **Direct dd_chain approach**: Fix `fwd_chain_forward_F` directly within the round-robin framework. The existing `preserving_fwd_step` with `f_carry` already preserves F-formulas. The missing piece is a pigeonhole/termination argument on finite `sigma_list`.

3. **Semantic argument**: Prove restricted_fuc/restricted_buc/restricted_tc via the truth lemma rather than syntactic chain manipulation. If the parametric truth lemma is already sorry-free, the coherence properties might follow from semantic correctness.

## Confidence Level

**High confidence (95%)** in findings 1, 2, 5, 8, 9 -- these are based on direct code reading with explicit line references.

**Medium confidence (80%)** in findings 3, 4, 6, 7 -- these involve architectural judgment about composability.

The core conclusion -- that the quasimodel bridge has fundamental gaps that prevent it from closing the 3 remaining sorries -- is supported by concrete sorry sites and structural disconnection between the two code paths.
