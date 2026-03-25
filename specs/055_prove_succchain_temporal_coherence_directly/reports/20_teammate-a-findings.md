# Teammate A Findings: Forward Direction Mathematical Requirements

**Task**: 55 — Prove SuccChain Temporal Coherence Directly
**Date**: 2026-03-24
**Session**: sess_1774408665_28fbb4
**Focus**: Analyze precise mathematical requirements of the forward direction

---

## Key Findings

### 1. The Forward Direction Does NOT Need SuccChainTemporalCoherent (HIGH CONFIDENCE)

The forward direction of `succ_chain_truth_forward` only uses lemmas that are **sorry-free**:

| Lemma Used | Axiom Status | Purpose |
|------------|--------------|---------|
| `succ_chain_forward_G_le` | **SORRY-FREE** | G case forward: `G psi ∈ MCS t → psi ∈ MCS s` for `s ≥ t` |
| `succ_chain_backward_H_le` | **SORRY-FREE** | H case forward: `H psi ∈ MCS t → psi ∈ MCS s` for `s ≤ t` |
| `succ_chain_fam_mcs` | **SORRY-FREE** | MCS property of chain |

**Verified by**:
```bash
#print axioms Bimodal.Metalogic.Bundle.succ_chain_forward_G_le
# Output: [propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]
# NO sorryAx!
```

### 2. The Dependency is STRUCTURAL, Not Mathematical (HIGH CONFIDENCE)

The sorry enters `succ_chain_truth_forward` because of **how the proof is structured**, not because the forward direction mathematically requires `SuccChainTemporalCoherent`.

**Current Structure** (SuccChainTruth.lean:293-296):
```lean
theorem succ_chain_truth_forward (M0 : SerialMCS) (phi : Formula) (t : Int) :
    phi ∈ succ_chain_fam M0 t →
    truth_at succ_chain_model (succ_chain_omega M0) (succ_chain_history M0) t phi :=
  (succ_chain_truth_lemma M0 phi t).mp  -- ← .mp extracts forward from biconditional
```

The `.mp` operation extracts the forward implication from `succ_chain_truth_lemma`, which is an `↔`. Lean's axiom tracking is **whole-theorem based** — it doesn't distinguish which direction of the biconditional introduces the sorry.

### 3. Where SuccChainTemporalCoherent is Actually Used (HIGH CONFIDENCE)

`SuccChainTemporalCoherent` is used in **exactly two places** in `succ_chain_truth_lemma`:

| Case | Direction | Line | Usage |
|------|-----------|------|-------|
| `all_future` (G) | **BACKWARD** | 266 | `let tcf : TemporalCoherentFamily Int := SuccChainTemporalCoherent M0` |
| `all_past` (H) | **BACKWARD** | 282 | `let tcf : TemporalCoherentFamily Int := SuccChainTemporalCoherent M0` |

These are used to call `temporal_backward_G` and `temporal_backward_H`, which need `forward_F` for their contraposition proof.

**The forward G/H cases (lines 259-262, 275-278) use only `succ_chain_forward_G_le` and `succ_chain_backward_H_le`** — both sorry-free.

### 4. Box Case Also Has a Sorry (But Different) (HIGH CONFIDENCE)

The Box backward case (line 254) has an explicit sorry:
```lean
sorry -- Box backward not needed for completeness; requires modal coherence (BFMCS)
```

This is a **direct sorry** in the biconditional, separate from the `SuccChainTemporalCoherent` chain. It contributes to the `sorryAx` in the truth lemma but is **not on the critical path** for completeness.

### 5. The Imp Case Uses Backward Direction (HIGH CONFIDENCE)

A subtle but critical detail: the Imp case's forward direction (lines 189-197) requires the **backward** IH:
```lean
-- Forward: (psi -> chi) in MCS and truth psi -> truth chi
intro h_imp h_psi_true
-- By IH backward: psi in MCS  ← THIS LINE
have h_psi_mcs : psi ∈ succ_chain_fam M0 t := (ih_psi t).mpr h_psi_true
```

This means even the forward direction of Imp depends on the backward direction of sub-formulas. However, this is **not the source of the sorry** — the backward atom/bot cases are trivial.

---

## Mathematical Analysis

### What Forward G Actually Requires

`succ_chain_forward_G_le` (SuccChainFMCS.lean:1174-1184) proves:
```
G phi ∈ MCS(n) ∧ n ≤ m → phi ∈ MCS(m)
```

**Proof structure**:
- If `n = m`: Use T-axiom (`temp_t_future: G phi → phi`)
- If `n < m`: Use `succ_chain_forward_G` which iterates `succ_chain_forward_G_step`

`succ_chain_forward_G_step` (line 413) shows that `G phi ∈ MCS(n)` implies:
1. `phi ∈ MCS(n+1)` (by 4-axiom + constrained successor construction)
2. `G phi ∈ MCS(n+1)` (by temp_4 axiom: `G phi → G(G phi)`)

This is purely **monotonicity of the chain construction** — it does NOT need same-family F-witnesses.

### What Forward H Actually Requires

Symmetric to G. `succ_chain_backward_H_le` uses:
- T-axiom (`temp_t_past: H phi → phi`) for reflexive case
- `succ_chain_backward_H` which iterates `succ_chain_backward_H_step`

Again, purely monotonicity — NO temporal coherence needed.

### Why Backward G/H Needs SuccChainTemporalCoherent

The backward proof (TemporalCoherence.lean:165-178) uses contraposition:
1. Assume `G phi ∉ MCS(t)`
2. By maximality: `¬G phi ∈ MCS(t)`
3. By temporal duality: `F(¬phi) ∈ MCS(t)`
4. **By forward_F**: `∃ s > t. ¬phi ∈ MCS(s)` ← **REQUIRES SuccChainTemporalCoherent**
5. Contradiction with hypothesis `∀ s > t. phi ∈ MCS(s)`

The `forward_F` in step 4 is the problematic dependency.

---

## Recommended Approach

### Option A: Define Forward Truth Lemma Directly (RECOMMENDED)

Refactor `succ_chain_truth_forward` to be a **direct inductive proof**, not `.mp` of the biconditional:

```lean
theorem succ_chain_truth_forward_direct (M0 : SerialMCS) (phi : Formula) (t : Int) :
    phi ∈ succ_chain_fam M0 t →
    truth_at succ_chain_model (succ_chain_omega M0) (succ_chain_history M0) t phi := by
  induction phi generalizing t with
  | atom p => ... -- same as biconditional forward
  | bot => ... -- same
  | imp psi chi ih_psi ih_chi =>
      intro h_imp h_psi_true
      -- Forward: need psi in MCS from truth psi
      -- PROBLEM: This still needs backward direction!
      ...
```

**Problem**: The Imp case forward direction genuinely uses backward IH. This means we cannot fully separate forward from backward.

### Option B: Prove Imp Forward Without Backward (MEDIUM CONFIDENCE)

Alternative proof for Imp forward that avoids backward:
- Instead of using IH backward on psi, use classical reasoning
- Given `(psi → chi) ∈ MCS` and `truth psi`, derive `truth chi` directly

**Challenge**: The standard MCS proof uses "if truth psi then psi ∈ MCS" which IS the backward direction.

### Option C: Accept Biconditional but Isolate Sorry to Backward-Only Cases

Keep the biconditional structure but:
1. Prove all truly sorry-free cases (atom, bot, imp, box-forward, G-forward, H-forward)
2. Use `sorry` only for backward G/H and box-backward
3. Prove `succ_chain_truth_forward` as `.mp` — it will still inherit `sorryAx` but the mathematical content is valid

**Reality**: This is the **current state**. The issue is Lean's axiom tracking doesn't distinguish.

### Option D: Use Separate Forward/Backward Theorems (CLEANEST)

Define:
```lean
-- Forward only, sorry-free
theorem succ_chain_truth_forward_atom ...
theorem succ_chain_truth_forward_bot ...
theorem succ_chain_truth_forward_imp (ih_fwd_psi) (ih_bwd_psi) (ih_fwd_chi) ...
theorem succ_chain_truth_forward_box ...
theorem succ_chain_truth_forward_G (ih_fwd) ...
theorem succ_chain_truth_forward_H (ih_fwd) ...

-- Combine with mutual recursion
mutual
def succ_chain_truth_forward_aux ...
def succ_chain_truth_backward_atom_bot_imp ...  -- sorry-free for these
end
```

The Imp case would use `succ_chain_truth_backward_aux` only for atom/bot/imp sub-formulas, which are sorry-free.

---

## Conclusions

1. **The forward direction mathematically does NOT require `SuccChainTemporalCoherent`** except through the Imp case's use of backward IH.

2. **The Imp case is the critical coupling point** — forward Imp needs backward psi.

3. **For completeness**, we only need to prove `¬phi ∈ MCS → ¬truth phi`. Since `¬phi` is an Imp formula (`phi → ⊥`), and the backward direction for bot is trivial, we might be able to prove completeness via a more direct route.

4. **Recommended fix**: Either (a) restructure with mutual recursion separating sorry-free backward cases from sorry-dependent ones, or (b) prove completeness via a different argument that doesn't go through the full biconditional.

---

## References

- SuccChainTruth.lean:161-296 (truth lemma structure)
- SuccChainTruth.lean:266, 282 (SuccChainTemporalCoherent usage)
- SuccChainFMCS.lean:1174-1200 (forward_G_le, backward_H_le — sorry-free)
- SuccChainFMCS.lean:1225-1228 (SuccChainTemporalCoherent definition)
- TemporalCoherence.lean:165-178 (temporal_backward_G proof using forward_F)
