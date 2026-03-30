# Teammate A Findings: F-Preserving Chain Approach for Z_chain_forward_F

**Task**: 69 - close_z_chain_forward_f
**Focus**: F-preserving chain approach for closing the remaining sorries
**Date**: 2026-03-30

---

## Key Findings

### 1. The Core Gap

`Z_chain` is defined at line 2557 using `omega_chain_forward` for the non-negative half:

```lean
noncomputable def Z_chain (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Int → Set Formula :=
  fun t =>
    if h : t ≥ 0 then
      omega_chain_forward M0 h_mcs0 t.toNat   -- <-- DOES NOT guarantee F-resolution
    else
      omega_chain_backward M0 h_mcs0 (-t).toNat
```

The three remaining sorries (lines 2797, 2814, 3976) all fall into the `phi ∉ chain(t)` branch. The root cause is identical: `omega_chain_forward` always resolves `F_top` at each step (line 2387: `omega_step_forward M_n inv_n.is_mcs (Formula.neg Formula.bot) h_F_top`), so it gives NO guarantee that an arbitrary `F(phi)` is ever resolved.

### 2. omega_chain_F_preserving_forward IS Complete

The F-preserving chain at line 4185 (`omega_chain_F_preserving_forward`) already has:

- **`omega_F_preserving_forward_F_resolution`** (line 4303): FULLY CLOSED. Proves that `F(phi) ∈ chain(t)` implies `∃ s, t ≤ s ∧ phi ∈ chain(s)`. This is exactly the statement needed.
- The proof uses Cantor pairing (`Nat.pair t (Encodable.encode phi)`) to ensure every F-obligation is eventually scheduled, with `F_persistence_through_chain` to carry F-obligations forward until resolution.

### 3. How omega_chain_F_preserving_forward Differs from omega_chain_forward

| Property | omega_chain_forward | omega_chain_F_preserving_forward |
|----------|--------------------|---------------------------------|
| Step target | Always F_top (neg bot) | Dovetailed: target = selectFormulaToResolve |
| F-persistence | Not tracked | Tracked via OmegaForwardFPreservingInvariant |
| F-resolution | Not guaranteed | Guaranteed by Cantor pairing |
| G-propagation | Yes | Yes |
| box_class_agree | Yes | Yes |
| base case | M0 | M0 |

The key invariant difference is `F_unresolved_persist` (line 4150): if `F(psi) ∈ W` and `psi ∉ W`, then `F(psi)` stays in the successor. This, combined with `selectFormulaToResolve` using `Nat.unpair`, ensures every F-obligation is eventually resolved.

### 4. Z_chain_forward_F' Has a Second Sorry

`Z_chain_forward_F'` (line 3943) has an additional sorry at line 3976 in the `t < 0` case (when `F(phi)` is in the backward chain). This case is structurally different: `F(phi)` appears in `omega_chain_backward` at index `(-t).toNat`, and we need to find `s ≥ t` with `phi ∈ Z_chain(s)`. The F-preserving approach for the forward chain does NOT directly solve this — it handles the case where F(phi) originates in the forward (non-negative) half.

### 5. Additional Sorries in Z_chain_forward_G and Z_chain_backward_H

There are two more sorries in `Z_chain_forward_G` (lines 2696, 2718) and one in `Z_chain_backward_H` (line 2732) involving cross-chain G/H propagation. These are NOT the focus of this research, but they affect whether `OmegaFMCS` compiles cleanly.

---

## Recommended Approach: Redefine Z_chain to Use F-Preserving Forward Chain

**Change Z_chain's positive half from `omega_chain_forward` to `omega_chain_F_preserving_forward`.**

### Feasibility

Mechanically straightforward. The change is one line in the definition (line 2561):

```lean
-- Current:
      omega_chain_forward M0 h_mcs0 t.toNat
-- Proposed:
      omega_chain_F_preserving_forward M0 h_mcs0 t.toNat
```

### Downstream Impact Assessment

`Z_chain` is used in the following theorems, which all delegate to the forward chain's properties:

| Theorem | Dependency on forward chain | Impact |
|---------|---------------------------|--------|
| `Z_chain_mcs` (line 2568) | `omega_chain_forward_mcs` | Replace with `omega_chain_F_preserving_forward_mcs` |
| `Z_chain_box_class` (line 2579) | `omega_chain_forward_box_class` | Replace with `omega_chain_F_preserving_forward_box_class` |
| `Z_chain_zero` (line 2590) | `omega_chain_forward_zero` | Replace with `omega_chain_F_preserving_forward_zero` |
| `Z_chain_forward_G` (line 2648) | `omega_chain_forward_G_monotone` | Need matching G-monotone for F-preserving chain |
| `Z_chain_forward_F` (line 2775) | (sorry) | Directly solved by `omega_F_preserving_forward_F_resolution` |
| `Z_chain_backward_P` (line 2805) | (sorry) | Symmetric — unaffected (uses backward chain) |

### Proof Sketch for Closing Z_chain_forward_F

After redefining Z_chain to use `omega_chain_F_preserving_forward`:

```lean
theorem Z_chain_forward_F (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t : Int) (phi : Formula) (h_F : Formula.some_future phi ∈ Z_chain M0 h_mcs0 t) :
    ∃ s : Int, t ≤ s ∧ phi ∈ Z_chain M0 h_mcs0 s := by
  by_cases h_phi_t : phi ∈ Z_chain M0 h_mcs0 t
  · exact ⟨t, le_refl t, h_phi_t⟩
  · -- t ≥ 0 case: Z_chain(t) = omega_chain_F_preserving_forward(t.toNat)
    -- h_F : F(phi) ∈ omega_chain_F_preserving_forward(t.toNat)
    -- apply omega_F_preserving_forward_F_resolution to get m with phi ∈ chain(m)
    -- set s = (m : Int), show t ≤ s and phi ∈ Z_chain(s)
    --
    -- t < 0 case: F(phi) in backward chain — still needs special handling
    sorry  -- only the t < 0 sub-case remains
```

The `t ≥ 0` sub-case closes directly. The `t < 0` sub-case (where `F(phi)` is in the backward chain) requires a separate argument — see the Risk section.

### Missing Lemma: G-Monotone for F-Preserving Chain

`Z_chain_forward_G` at line 2648 uses `omega_chain_forward_G_monotone`. We need an equivalent:

```
omega_chain_F_preserving_forward_G_monotone : G(phi) ∈ F_preserving_chain(m) →
    G(phi) ∈ F_preserving_chain(n)  (for m ≤ n)
```

This should follow by the same induction, since the F-preserving chain also builds witnesses using `omega_step_forward_F_preserving`, which preserves G-theory (line 4175: `G_propagate`). This lemma does NOT currently exist and must be added.

---

## Evidence / Examples

- `omega_chain_F_preserving_forward_with_inv` definition: line 4158
- `omega_chain_F_preserving_forward` accessor: line 4185
- `OmegaForwardFPreservingInvariant` structure: line 4142
- `F_persistence_through_chain` (key lemma): line 4227 — CLOSED
- `omega_F_preserving_forward_F_resolution` (key theorem): line 4303 — FULLY CLOSED
- `omega_chain_F_preserving_forward_G_theory` (G propagation exists): line 4214
- Summary of prior implementation: `specs/069_close_z_chain_forward_f/summaries/07_semantic-fix-summary.md`

---

## Confidence Level

**High** for the `t ≥ 0` sub-case of `Z_chain_forward_F` and `Z_chain_forward_F'`.

**Low-to-medium** for:
- `Z_chain_backward_P`: requires a symmetric P-preserving backward chain (not yet built)
- The `t < 0` branch of `Z_chain_forward_F'` (line 3976): `F(phi)` originates in the backward chain; reaching the forward chain to resolve it requires crossing the chain boundary, which is structurally non-trivial
- `Z_chain_forward_G` cross-chain cases (lines 2696, 2718): these have independent sorries that block `OmegaFMCS` regardless

---

## Risks and Trade-offs

### Risk 1: Backward Chain Symmetric Gap
The `Z_chain_backward_P` sorry (line 2814) is symmetric to `Z_chain_forward_F` but the backward chain (`omega_chain_backward`) also does NOT have an F/P-preserving equivalent. The same fix (redefine to use a P-preserving backward chain) would be needed. The P-preserving backward chain does not appear to exist yet in the file.

**Mitigation**: Implement `omega_chain_P_preserving_backward` by exact analogy to the forward case. The structure is symmetric.

### Risk 2: t < 0 Sub-case in Z_chain_forward_F'
When `t < 0`, `F(phi) ∈ omega_chain_backward((-t).toNat)`. To resolve phi, we need it to appear at some integer `s ≥ t`. Since `s` can be ≥ 0 (in the forward chain), we need to bridge from backward to forward. The backward chain and forward chain share only `M0` at index 0. This case likely requires:
- Pulling `F(phi)` forward to M0 via H-theory propagation, OR
- Extending backward chain construction to also track F-obligations

**Mitigation**: The `s = 0` case works if `phi ∈ M0` or if `F(phi) ∈ M0`. Otherwise this is genuinely blocked and may warrant marking `Z_chain_forward_F'` as `[BLOCKED]` pending a more complete construction.

### Risk 3: G-Monotone Missing Lemma
The G-monotone lemma for the F-preserving chain must be added before `Z_chain_forward_G` can be closed. This is a minor proof addition but adds to scope.

### Risk 4: Changing Z_chain Definition Cascades
Changing Z_chain's definition to use `omega_chain_F_preserving_forward` requires updating all 5 property lemmas. This is mechanical but requires running `lake build` to identify all broken proofs.

---

## Summary

The F-preserving approach is the right path for closing the `t ≥ 0` sub-cases of `Z_chain_forward_F` and `Z_chain_forward_F'`. The closed theorem `omega_F_preserving_forward_F_resolution` (line 4303) is a direct proof that F-obligations are eventually resolved in the F-preserving chain. Redefining `Z_chain` to use this chain for `t ≥ 0` closes that sub-case with a two-line proof.

The remaining blockers are:
1. `Z_chain_backward_P` — needs a symmetric P-preserving backward chain
2. `Z_chain_forward_F'` line 3976 — the `t < 0` backward-to-forward crossing case
3. `Z_chain_forward_G` lines 2696, 2718 — cross-chain G propagation (independent issue)

Recommendation: Implement `Z_chain` redefinition for `t ≥ 0` as the primary fix, then assess whether the `t < 0` cases require a more substantial construction or can be handled with targeted lemmas.
