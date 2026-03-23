# Research Report: Task #40

**Task**: Add p-step condition to Succ relation or prove successor_satisfies_p_step
**Date**: 2026-03-23
**Mode**: Team Research (2 teammates)

## Summary

The forward chain case of `succ_chain_fam_p_step` (SuccChainFMCS.lean:350) has a single `sorry` blocking the proof that `p_content(forward_chain M0 (k+1)) ⊆ forward_chain M0 k ∪ p_content(forward_chain M0 k)`. Both teammates independently concluded that **Approach B as a pure theorem is not achievable** because the successor deferral seed (`g_content(u) ∪ deferralDisjunctions(u)`) contains no past-direction content. The recommended approach is adding an axiom `successor_p_step_axiom` mirroring the existing `predecessor_f_step_axiom` — this is minimal-disruption, semantically justified, and consistent with existing codebase patterns.

## Key Findings

### 1. The Blocked Sorry

The sole production `sorry` is at `SuccChainFMCS.lean:350`, in the `ofNat k` (forward chain) branch of `succ_chain_fam_p_step`. The backward chain cases (`negSucc`) are fully proven via `backward_chain_p_step` → `predecessor_satisfies_p_step`.

After `simp only [succ_chain_fam]`, the goal becomes:
```
h_φ : φ ∈ p_content (forward_chain M0 (k + 1))
⊢ φ ∈ forward_chain M0 k ∪ p_content (forward_chain M0 k)
```

This cascades to one dependent proof: `succ_chain_canonicalTask_backward_MCS_P_from` (SuccChainFMCS.lean:742/803).

### 2. Why Approach B (Pure Theorem) Fails

The successor is built as `Lindenbaum(g_content(u) ∪ {φ ∨ F(φ) | F(φ) ∈ u})`. The seed contains:
- **G-persistence**: `g_content(u)` — guarantees `g_content(u) ⊆ v`
- **F-step**: `deferralDisjunctions(u)` — guarantees `f_content(u) ⊆ v ∪ f_content(v)`

The seed has **no past-direction content** (`h_content`, `pastDeferralDisjunctions`). The P-step condition `p_content(v) ⊆ u ∪ p_content(u)` constrains the P-content of the extension, but the Lindenbaum extension can freely add P-formulas without constraint from the forward seed.

**Contrast with predecessor**: The predecessor seed is `h_content(u) ∪ pastDeferralDisjunctions(u)`, which directly encodes P-step obligations. That's why `predecessor_satisfies_p_step` is provable (SuccExistence.lean:573-598) — the seed's `pastDeferralDisjunction φ = φ ∨ P(φ)` gives the needed disjunction.

### 3. The Fundamental Asymmetry

The asymmetry is structural: the forward seed encodes **forward-direction obligations** (F-step) from source world `u`, but cannot encode **backward-direction obligations** (P-step) for the not-yet-known target world `v`. This mirrors exactly why `predecessor_f_step_axiom` (SuccExistence.lean:516-519) exists as an axiom — the predecessor seed cannot encode F-step for the same reason.

### 4. Approach A Impact Analysis

Extending Succ to 4 conditions does **not avoid** the hard proof:
- `successor_succ` would need `successor_satisfies_p_step` as its 4th field — the same unproven property
- `predecessor_succ` could add condition (4) from `predecessor_satisfies_p_step` (already proven)
- Condition (3) (`h_content v ⊆ u`) is already derivable from condition (1) via `Succ_implies_h_content_reverse`

Estimated impact: ~50-80 lines added, ~20 lines changed, threading through SuccRelation.lean, SuccExistence.lean, SuccChainFMCS.lean.

**Verdict**: Same semantic cost (one axiom either way), significantly more invasive.

## Synthesis

### Conflicts Resolved

**None** — both teammates independently reached the same diagnosis and recommendation with high confidence.

### Gaps Identified

1. **Approach B via indirect axiomatic reasoning**: Teammate B noted a potential path using `temp_a` (φ → G(P(φ))) to derive P-step indirectly, but assessed it as "non-trivial" and not currently present in the codebase infrastructure. This path could be explored in a future task to eliminate the axiom.

### Recommendations

**Primary recommendation**: Add `successor_p_step_axiom` to SuccExistence.lean.

```lean
axiom successor_p_step_axiom
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    p_content (successor_from_deferral_seed u h_mcs h_F_top) ⊆ u ∪ p_content u
```

**Proof sketch to fill the sorry**:

1. Add `successor_p_step_axiom` to SuccExistence.lean (after successor construction, symmetric to `predecessor_f_step_axiom` at line 516)

2. Add `forward_chain_p_step` to SuccChainFMCS.lean:
```lean
theorem forward_chain_p_step (M0 : SerialMCS) (k : Nat) :
    p_content (forward_chain M0 (k + 1)) ⊆
    forward_chain M0 k ∪ p_content (forward_chain M0 k) :=
  successor_p_step_axiom
    (forward_chain M0 k)
    (forward_chain_mcs M0 k)
    (forward_chain_has_F_top M0 k)
```

3. Fill the sorry:
```lean
| ofNat k =>
  simp only [succ_chain_fam] at h_φ ⊢
  exact forward_chain_p_step M0 k h_φ
```

**Semantic justification**: In a discrete linear frame where `Succ u v`, P-obligations in `v` must resolve to `u` or remain as P-obligations in `u`. This has identical semantic standing to `predecessor_f_step_axiom`.

**Future work**: Investigate proving the axiom from `temp_a`/`past_temp_a` infrastructure to eliminate the axiom debt.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary approaches: Approach B analysis, successor seed structure, proof sketch | completed | high |
| B | Alternatives: Approach A impact, symmetry exploitation, alternative definitions | completed | high |

## References

| Location | Relevance |
|----------|-----------|
| `SuccRelation.lean:60-61` | Succ has 2 conditions (g-persistence, f-step) |
| `SuccExistence.lean:86-87` | `successor_deferral_seed = g_content ∪ deferralDisjunctions` |
| `SuccExistence.lean:384-408` | `successor_satisfies_f_step` (proven from seed) |
| `SuccExistence.lean:516-519` | `predecessor_f_step_axiom` (symmetric axiom precedent) |
| `SuccExistence.lean:573-598` | `predecessor_satisfies_p_step` (proven from seed) |
| `SuccChainFMCS.lean:264-270` | `backward_chain_p_step` (working backward case) |
| `SuccChainFMCS.lean:344-350` | The blocked `sorry` in forward case |
| `SuccChainFMCS.lean:742/803` | Downstream dependent `succ_chain_canonicalTask_backward_MCS_P_from` |
| `WitnessSeed.lean:322-349` | g/h duality theorems (insufficient for p-step) |
| `CanonicalTaskRelation.lean:631` | `CanonicalTask_backward_MCS_P` requires P-step |
