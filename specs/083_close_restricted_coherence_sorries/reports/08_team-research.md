# Research Report: Task #83 (Round 8)

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-03
**Mode**: Team Research (2 teammates)

## Summary

Both teammates independently converged on the same root cause and recommended solution. The completeness proof (`completeness_over_Int`) is blocked by exactly **2 sorries** — the Until and Since cases of `restricted_shifted_truth_lemma` (CanonicalConstruction.lean:929-930). The root cause is a mismatch between the reflexive (closed-interval) Until/Since semantics and the Burgess-Xu axioms designed for strict ordering. The recommended fix is to change the Until/Since semantic definition to use a half-open interval (`r < s` instead of `r ≤ s` for the φ guard), which makes `until_intro` sound and unblocks the backward direction of the truth lemma.

## Key Findings

### 1. Only 2 Sorries Block Completeness

The complete call chain for `completeness_over_Int`:
```
completeness_over_Int                               -- Completeness.lean:472
  └── dovetailed_bundle_validity_implies_provability -- Completeness.lean:430
        ├── construct_dovetailed_bfmcs_bundle        -- sorry-free
        ├── dovetailed_bfmcs_restricted_temporally_coherent -- sorry-free
        └── restricted_shifted_truth_lemma           -- CanonicalConstruction.lean:800
              ├── atom, bot, imp, box, G, H          -- all sorry-free
              ├── untl (Until)  → SORRY (line 929)   ← BLOCKER #1
              └── snce (Since)  → SORRY (line 930)   ← BLOCKER #2
```

Everything else in the dovetailed completeness path is sorry-free. The original target sorries (`succ_chain_restricted_forward_F` at UltrafilterChain.lean:3762 and `succ_chain_restricted_backward_P` at :3772) are fully bypassed by the dovetailed chain.

### 2. Root Cause: Reflexive vs Strict Semantics Mismatch

The semantic definition of Until (Truth.lean) uses closed intervals:
```
φ U ψ at t  :=  ∃ s, t ≤ s ∧ ψ(s) ∧ ∀ r, t ≤ r → r ≤ s → φ(r)
```

This requires φ at ALL points in `[t, s]` including both endpoints. The Burgess-Xu axioms were designed for strict ordering where:
- `until_intro`: `ψ → φ U ψ` is sound because the guard interval is empty when `s = t`
- `until_unfold`: The deferral `G(φ U ψ)` works because G means strictly future

Under reflexive semantics:
- **`until_intro` is UNSOUND**: `ψ(t) → (φ U ψ)(t)` fails because witness `s = t` requires `φ(t)` which isn't provided
- **`until_unfold` is UNSOUND**: `G(φ U ψ)` requires Until at ALL `s ≥ t`, but the original witness only covers `[t, s_w]`
- **`until_induction` is UNSOUND**: Backward propagation from witness to `t` is not supported by the premise structure

All 6 unsound axioms (3 Until + 3 Since mirrors) are marked sorry in Soundness.lean (12 sorries across base and dense soundness theorems).

### 3. Unsoundness Does NOT Block Completeness Directly

Critical insight from both teammates: the dovetailed chain uses these axioms **only at the proof-theoretic (MCS) level**, where they are valid as syntactic derivation rules regardless of semantic soundness. The sorry-free `DovetailedFMCS_forward_F` and `DovetailedFMCS_backward_P` are pure proof theory.

The problem manifests only in the truth lemma, which bridges proof theory and semantics:
- **Forward direction** (`(φ U ψ) ∈ MCS(t) → ∃ semantic witness`): Needs to extract a witness. Can use dovetailed chain's `forward_F` for this. BUT under closed-interval semantics, `(φ U ψ) ∈ MCS` should imply `φ ∈ MCS` (since `r = t` is in the guard range), and `until_unfold` in the `ψ` case doesn't provide this.
- **Backward direction** (`∃ semantic witness → (φ U ψ) ∈ MCS(t)`): Requires `until_intro` to PUT `φ U ψ` into the MCS. The axiom is the only introduction rule, and it's unsound.

### 4. Complete Sorry Inventory

| Category | Count | Blocks completeness? |
|----------|-------|---------------------|
| Critical path (truth lemma U/S) | 2 | **YES** |
| Soundness (unsound axioms) | 12 | No (soundness only) |
| Bypassed paths (old chain) | 9 | No (dovetailed bypasses) |
| Dead code | 4 | No |
| Semantically unreachable (fuel=0) | 3 | No |
| Separate projects (dense, discrete, FMP) | 3+ | No |
| Examples/demos | 7+ | No |
| **Total** | **~40** | |

Notable: SuccChainFMCS.lean:2529 contains a **provably false** theorem (documented counterexample). Lines 5833/5991/6187 are semantically unreachable fuel=0 branches.

## Synthesis

### Conflicts Resolved

**Approach selection**: Teammate A recommended "Option A: Switch to strict temporal semantics" as safer. Teammate B recommended "Approach C/E: Half-open interval semantics" as more targeted. After analysis, **half-open is preferred** because:
1. It's the minimal change — only the φ guard changes from `r ≤ s` to `r < s`
2. It matches standard Kamp semantics
3. It makes `until_intro` immediately sound (vacuous guard when `s = t`)
4. It preserves the reflexive witness range (`t ≤ s`, not `t < s`) so F ≡ ⊤ U still works
5. The dovetailed chain is unaffected (pure proof theory)

**Unfold axiom**: Both noted `until_unfold` with `G` remains unsound even under half-open semantics. However, for completeness, the forward direction of the truth lemma doesn't need the unfold axiom to be *semantically* sound — it uses the dovetailed chain's `forward_F` guarantee directly. The unfold is only used proof-theoretically within MCS reasoning.

### Gaps Identified

1. **Forward direction detail**: Exactly how to thread the dovetailed chain's `forward_F` into the truth lemma's forward Until case. The `restricted_shifted_truth_lemma` operates at the BFMCS level (multiple families), and `forward_F` is a family-level property provided by `restricted_temporally_coherent`. Need to verify that `F(ψ) ∈ fam.mcs(t)` is derivable from `(φ U ψ) ∈ fam.mcs(t)` — this uses `until_implies_F_in_mcs` which is sorry-free.

2. **Backward direction with half-open**: Under half-open semantics, `until_intro`'s first disjunct `ψ → φ U ψ` becomes sound. The backward proof strategy:
   - If `s = t`: `ψ ∈ MCS(t)`, apply `until_intro` first disjunct → `(φ U ψ) ∈ MCS(t)`
   - If `s > t`: Need induction backward from `s` to `t`. At `s`: `(φ U ψ) ∈ MCS(s)` by above. At `k < s`: need `(φ U ψ) ∈ MCS(k)` from `φ ∈ MCS(k)` and `(φ U ψ) ∈ MCS(k+1)`. This uses `until_intro` second disjunct `φ ∧ G(φ U ψ) → φ U ψ`. But `G(φ U ψ) ∈ MCS(k)` requires `(φ U ψ)` at ALL `s ≥ k`, which we don't have for `s > s_witness`. **This remains a challenge.**

3. **Alternative backward approach**: Instead of `G(φ U ψ)`, could use contrapositive: assume `¬(φ U ψ) ∈ MCS(t)` and derive contradiction using the semantic witnesses. This needs axioms decomposing `¬(φ U ψ)`.

## Recommendations

### Immediate Action: Change to Half-Open Interval Semantics

Modify `truth_at` in `Truth.lean` for Until/Since:
```lean
-- Current (closed interval):
| Formula.untl φ ψ => ∃ s, t ≤ s ∧ truth_at ... s ψ ∧ ∀ r, t ≤ r → r ≤ s → truth_at ... r φ

-- Proposed (half-open interval):
| Formula.untl φ ψ => ∃ s, t ≤ s ∧ truth_at ... s ψ ∧ ∀ r, t ≤ r → r < s → truth_at ... r φ
```

This change:
1. Makes `until_intro` first disjunct sound (3 soundness sorries fillable immediately)
2. Preserves `F(ψ) ≡ ⊤ U ψ` equivalence (witness still uses `t ≤ s`)
3. Enables the truth lemma base case (`s = t`)
4. Is a ~20-line semantic change + ~100 lines of downstream fixes

### Remaining Challenge: Backward Induction

The backward truth lemma direction for `s > t` still requires care. Two sub-approaches:

**Sub-approach 1**: Strengthen `until_intro` to use `F(φ U ψ)` instead of `G(φ U ψ)`:
```
ψ ∨ (φ ∧ F(φ U ψ)) → φ U ψ
```
This is weaker (hence sound) and the dovetailed chain still produces the proof-theoretic content needed. But it changes the axiom and may affect the dovetailed chain's MCS-level reasoning.

**Sub-approach 2**: Use discrete induction on Int. Since we're proving `completeness_over_Int` specifically, exploit the discrete structure: at position `k`, if `(φ U ψ) ∈ MCS(k+1)` and `φ ∈ MCS(k)`, then `u_step` in the Succ relation gives exactly what's needed to propagate `φ U ψ` backward. This is the cleanest approach for Int-specific completeness.

### Estimated Effort

| Step | Lines | Time |
|------|-------|------|
| Change truth_at to half-open | ~20 | 1h |
| Fix downstream Truth.lean lemmas | ~100 | 3h |
| Fill until_intro soundness proof | ~30 | 1h |
| Truth lemma forward direction | ~100 | 4h |
| Truth lemma backward direction | ~80 | 4h |
| Fix broken soundness proofs | ~50 | 2h |
| **Total** | **~380** | **~15h** |

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Sorry catalog + critical path analysis | completed | high |
| B | Alternative approaches + risk assessment | completed | high |

## References

- Burgess, J. (1982). "Axioms for tense logic"
- Xu, M. (1988). "On some U,S-tense logics"
- Kamp, H. (1968). "Tense Logic and the Theory of Linear Order"
- Standard LTL axiomatization with next-time operator
