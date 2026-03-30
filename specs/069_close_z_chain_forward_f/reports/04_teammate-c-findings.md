# Temporal Coherence Analysis

**Task**: 69 - close_z_chain_forward_f
**Researcher**: logic-research-agent (teammate C focus)
**Date**: 2026-03-30

## Key Findings

### 1. Current Definition Uses Strict Inequality Throughout

The codebase uses strict inequality (`s > t`) consistently at every level:

- `TemporalCoherentFamily.forward_F` (TemporalCoherence.lean:148-149):
  ```lean
  forward_F : ∀ t : D, ∀ φ : Formula,
    Formula.some_future φ ∈ mcs t → ∃ s : D, t < s ∧ φ ∈ mcs s
  ```
- `BFMCS.temporally_coherent` (TemporalCoherence.lean:216-219): same strict inequality
- `bundle_forward_F` (UltrafilterChain.lean:2884-2886): same strict inequality
- `shifted_temporal_forward_F` (UltrafilterChain.lean:303-305): same strict inequality

The definitions are uniform and internally consistent.

### 2. The Semantics of F in Irreflexive vs Reflexive Linear Orders

The logic TM uses **irreflexive** temporal semantics (strict `<`). Under irreflexive semantics:

- `F(phi)` means: "phi is true at some **strictly future** time"
- The truth condition: `F(phi)` true at `t` iff `∃ s > t, phi` true at `s`

This means: if `phi ∈ chain(t)` and `F(phi) ∈ chain(t)`, the F-formula is semantically asserting that phi holds at some **strictly future** time - NOT that phi holding at t satisfies the F-obligation.

**This is fundamental**: under strict irreflexive semantics, `F(phi)` is NOT satisfied by phi being true at `t`. The MCS is consistently stating two things: "phi is true now" AND "phi will be true at some strictly future time."

### 3. The Blocker Is NOT a Definition Problem

The sorry at UltrafilterChain.lean:4509 is in the case:
- `phi ∈ chain(t)` (phi true at t)
- `F(phi) ∈ chain(t)` (F(phi) true at t, per the MCS)
- `G(phi) ∉ chain(t)` (phi not always true in the future)

Under irreflexive semantics, this MCS configuration is **semantically valid and consistent**: phi is true at t, will be true at some future time (but not all future times). The F-obligation requires witnessing phi at some `s > t`.

**The problem is NOT the definition**. Weakening to `s ≥ t` would be semantically wrong for an irreflexive frame. The strict definition is correct.

**The actual gap**: When `phi ∈ chain(t)` and `G(phi) ∉ chain(t)`, the F-preserving seed at step `t` does NOT propagate `F(phi)` forward (because the seed only preserves `F(psi)` when `psi ∉ chain(t)`). But `F(phi)` is still true and still needs a strict future witness.

### 4. Key Insight: F(phi) ∈ chain(t) + phi ∈ chain(t) Implies F(phi) Must Persist

Since `F(phi) ∈ chain(t)`, and by MCS consistency `neg(F(phi)) ∉ chain(t)`, i.e., `G(neg phi) ∉ chain(t)`. By MCS negation completeness applied to `G(neg phi)`: either `G(neg phi) ∈ chain(t)` or `neg(G(neg phi)) = F(phi) ∈ chain(t)`. We already have the latter.

At step `t → t+1`, the F-preserving seed adds `F(psi)` only when `psi ∉ chain(t)`. Since `phi ∈ chain(t)`, `F(phi)` is NOT in the seed. Thus `F(phi)` might not be in `chain(t+1)`.

However, `G(neg phi) ∉ chain(t)` means the seed for chain(t+1) does NOT include `G(neg phi)`. But Lindenbaum extension at `t+1` could still add `G(neg phi)` unless excluded.

**This is the gap**: The F-preserving seed excludes `F(phi)` from persistence when `phi ∈ chain(t)`, but doesn't prevent `G(neg phi)` from being added at `t+1`.

### 5. Alternative: Seed Must Include F(phi) Unconditionally When F(phi) is in chain(t)

The fix is to broaden the F-preservation invariant: include `F(psi)` in the seed whenever `F(psi) ∈ chain(t)`, regardless of whether `psi ∈ chain(t)`:

```lean
-- Current (buggy for this case):
F_unresolved_theory M = { F(psi) | F(psi) ∈ M ∧ psi ∉ M }

-- Corrected:
F_carry_theory M = { F(psi) | F(psi) ∈ M }
```

But this raises a new question: when `phi ∈ chain(t)` and `F(phi) ∈ chain(t)`, does adding `F(phi)` to the seed at `t+1` remain consistent? Yes: the seed would contain `F(phi)` = `neg(G(neg phi))`. Since `G(neg phi)` would then be excluded from `chain(t+1)` by consistency, `phi` could be added at some future step via dovetailing without conflict.

### 6. Alternative 2: Duplicate phi into Future Chain Steps

A simpler local fix: when `phi ∈ chain(t)` AND `F(phi) ∈ chain(t)`, include `phi` in the F-preserving seed at step `t+1` as the direct witness. This directly satisfies `∃ s > t, phi ∈ chain(s)` at `s = t+1`.

The F-preserving seed would be:
```lean
f_preserving_seed M selected_phi :=
  {selected_phi}
  ∪ G_theory M
  ∪ box_theory M
  ∪ { F(psi) | F(psi) ∈ M ∧ psi ∉ M }   -- persist unresolved F-obligations
  ∪ { psi | F(psi) ∈ M ∧ psi ∈ M }        -- duplicate already-true phi for strict witness
```

The last component `{ psi | F(psi) ∈ M ∧ psi ∈ M }` is consistent: if `F(psi) ∈ M` then `neg(F(psi)) = G(neg psi) ∉ M`, so including `psi` in the seed creates no conflict with G-content. By Lindenbaum, `psi` can be in the extension.

### 7. Impact on the Completeness Proof

The `forward_F` property (strict `t < s`) is used in:
- `temporal_backward_G` (TemporalCoherence.lean:165): needs strict inequality to apply the contraposition
- `shifted_truth_lemma` (CanonicalConstruction.lean:650): needs `B.temporally_coherent`

The backward_G proof structure (TemporalCoherence.lean:165-178) specifically relies on the strict form: given `F(neg phi) ∈ fam.mcs t`, it gets `∃ s > t, neg(phi) ∈ fam.mcs s`. If we weakened to `s ≥ t`, the same proof still works for `s = t` (we'd get `neg(phi)` at t contradicting `phi` at t), so the backward_G proof is valid under EITHER strict or weak coherence.

**Therefore**: weakening the definition would NOT break downstream proofs; BUT weakening is semantically incorrect for irreflexive frames.

## Recommended Approach

**Fix the construction, not the definition.**

The correct resolution is **Alternative 2**: extend the F-preserving seed to include direct witnesses for already-satisfied F-obligations:

```lean
-- When F(phi) ∈ M and phi ∈ M, include phi in the seed for M+1
-- This gives a strict witness at t+1 ≥ t+1 > t
direct_witness_theory M := { psi | Formula.some_future psi ∈ M ∧ psi ∈ M }

-- Updated seed:
f_preserving_seed_v2 M selected_phi :=
  {selected_phi} ∪ G_theory M ∪ box_theory M ∪ F_unresolved_theory M ∪ direct_witness_theory M
```

**Consistency argument**: For any `psi ∈ direct_witness_theory M`:
- `F(psi) ∈ M` implies `G(neg psi) ∉ M`
- So `neg psi ∉ G_theory M`
- Adding `psi` to the seed is consistent with `G_theory M`

**Proof sketch**: If `phi ∈ chain(t)` and `F(phi) ∈ chain(t)`, then `phi ∈ direct_witness_theory(chain(t))`, so `phi` is in the seed for `chain(t+1)`, so `phi ∈ chain(t+1)`, giving the required strict witness at `s = t+1 > t`.

## Evidence/Examples

From the literature on temporal logic completeness (Burgess 1984, Gabbay-Hodkinson-Reynolds):

- Standard canonical model construction for linear temporal logic uses **strict** F/P coherence
- The canonical frame for LTL has irreflexive accessibility: `t R s iff t < s`
- Temporal coherence is stated with strict inequality uniformly
- When `phi` is true at `t` AND `F(phi)` is true at `t`, the intended meaning is that phi recurs strictly in the future - not that `t` itself serves as the F-witness

From the Lean codebase:
- `shifted_temporal_forward_F` at UltrafilterChain.lean:303 uses the same strict form
- The `temporal_backward_G` proof at TemporalCoherence.lean:165 requires strict form for its contraposition but would still work weakened (as noted above)
- The bundle-level `boxClassFamilies_bundle_forward_F` at UltrafilterChain.lean:2991 is proven sorry-free and uses `∃ s > t`

## Confidence Level

**High** on the core analysis:
- The strict definition is semantically correct for irreflexive frames and should NOT be weakened
- The sorry at line 4509 is a construction gap, not a definition gap
- Adding `direct_witness_theory` to the seed resolves the case and remains consistent

**Medium** on the specific implementation detail:
- The seed consistency proof for `direct_witness_theory` requires a careful Lean proof showing `psi ∉ neg(G_theory M)` when `F(psi) ∈ M` and `psi ∈ M`
- This should follow from MCS consistency (`F(psi) ∈ M` implies `G(neg psi) ∉ M`) but needs formalization

**Low** concern about downstream impact:
- The `temporal_backward_G` proof structure is unaffected by the seed change
- Only `omega_F_preserving_forward_F_resolution` needs to be updated
