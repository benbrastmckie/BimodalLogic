# Research Report: Blocker Analysis for F-Preserving Construction

**Task**: 69 - close_z_chain_forward_f
**Date**: 2026-03-30
**Mode**: Team Research (3 teammates)
**Session**: sess_1774900703_dc7199

## Summary

Three teammates investigated the two blockers from the partial implementation:
1. **Strict temporal coherence vs F-satisfaction at t** (sorry in omega_F_preserving_forward_F_resolution)
2. **G-lift with mixed contexts** (sorry in f_preserving_seed_consistent)

A critical finding emerged: **the project's semantics is reflexive but temporal coherence uses strict inequality**, creating a fundamental mismatch. Additionally, f_preserving_seed_consistent may be **unprovable as stated** due to a phi-negation inconsistency.

## Key Findings

### Finding 1: Semantic Mismatch (CONFIRMED by code)

The project uses **reflexive temporal semantics**:
- `Truth.lean:125`: `| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ`
- G(φ) at t means φ holds at all s **≥** t (including t itself)
- F(φ) = ¬G(¬φ) means ∃ s **≥** t with φ(s) (including s = t)
- The T-axiom `Gφ → φ` (Axioms.lean:290) exists precisely because of reflexive semantics

But temporal coherence uses **strict inequality**:
- `TemporalCoherence.lean:148-149`: `forward_F : ... t < s ∧ φ ∈ mcs s`
- Comment at line 144 says "irreflexive semantics" — **this comment is incorrect**

**Impact**: The temporal coherence definition is **strictly stronger than the semantics requires**. When `phi ∈ chain(t)`, F(phi) is semantically satisfied at t (since t ≤ t), but temporal coherence demands a witness at s > t that may not exist.

### Finding 2: f_preserving_seed_consistent May Be False (HIGH confidence)

Teammate B's proof-theoretic analysis identified a fundamental issue:

The theorem claims `{phi} ∪ temporal_box_seed M ∪ F_unresolved_theory M` is consistent. But:

1. After extracting F-formulas via deduction theorem and applying G-lift, one branch yields `neg(phi) ∈ M`
2. `neg(phi) ∈ M` is compatible with `F(phi) ∈ M` (phi false now, true later) — **no contradiction**
3. Since `temporal_box_seed M ∪ F_unresolved_theory M ⊆ M` and `neg(phi) ∈ M`, these elements can derive `neg(phi)`
4. Adding `phi` to a set that derives `neg(phi)` yields an **inconsistent set**

**Concrete scenario**: If M contains `neg(phi)`, `F(phi)`, and elements of temporal_box_seed that together derive `neg(phi)`, then f_preserving_seed is inconsistent.

This is NOT a formalization gap — the theorem as stated may be genuinely false.

### Finding 3: Downstream Impact of Weakening

If temporal coherence is weakened from `t < s` to `t ≤ s`:

- **temporal_backward_G** (contrapositive proof): Still works. The proof derives ∃ s ≥ t with neg(phi) ∈ fam.mcs s, contradicting phi ∈ fam.mcs s. Whether s = t or s > t, the contradiction holds as long as the hypothesis covers all s ≥ t.
- **shifted_temporal_forward_F**: Needs checking — shifting by k maps t < s to (t+k) < (s+k), same for ≤.
- **BFMCS.temporally_coherent**: Unchanged — it's a predicate, not a proof.

## Synthesis

### Conflicts Resolved

| Conflict | Teammate A | Teammate C | Resolution |
|----------|------------|------------|------------|
| F-semantics | Reflexive (s ≥ t) | Irreflexive (s > t) | **A correct** — Truth.lean:125 uses `t ≤ s` |
| Fix strategy | Weaken coherence | Fix construction | **Both valid**, but weakening is simpler and semantically justified |

Teammate C's analysis was based on the incorrect assumption of irreflexive semantics (matching the wrong comment at TemporalCoherence.lean:144). However, C's proposed `direct_witness_theory` construction remains a valid alternative if strict coherence is kept for other reasons.

### Gaps Identified

1. **Downstream proof audit**: Need to verify ALL consumers of `forward_F` work with `t ≤ s`
2. **f_preserving_seed_consistent validity**: Need to determine if theorem is true, and if not, what weaker statement suffices
3. **Alternative to f_preserving_seed**: If the theorem is false, the entire F-preserving construction needs restructuring

## Recommended Strategy

### Strategy A: Weaken Temporal Coherence (RECOMMENDED)

**Rationale**: Align the definition with the actual semantics.

1. Change `TemporalCoherentFamily.forward_F` from `t < s` to `t ≤ s`
2. Change `TemporalCoherentFamily.backward_P` from `s < t` to `s ≤ t`
3. The sorry in `omega_F_preserving_forward_F_resolution` becomes trivially closeable:
   - When `phi ∈ chain(t)`: return witness `s = t` with `t ≤ t`
   - When `phi ∉ chain(t)`: existing persistence argument finds `s > t`
4. Audit and update downstream proofs (`temporal_backward_G`, `shifted_temporal_forward_F`, etc.)
5. Fix the incorrect comment at TemporalCoherence.lean:144

**Risk**: Low. The weakening aligns with semantics and the T-axiom. All downstream proofs should adapt naturally.

### Strategy B: Restructure f_preserving_seed

Regardless of Strategy A, the f_preserving_seed_consistent theorem needs attention:

**Option B1** (if theorem is false): Replace with a Lindenbaum-based approach:
- Start with consistent `{phi} ∪ temporal_box_seed M` (guaranteed by `temporal_theory_witness_consistent`)
- Extend to MCS W via Lindenbaum
- Show W can be chosen to include F_unresolved elements (by freedom of Lindenbaum extension)

**Option B2** (if theorem is conditionally true): Add hypothesis `phi ∈ M` or `neg(phi) ∉ M` as precondition.

**Option B3**: If Strategy A is adopted, re-examine whether f_preserving_seed_consistent is even needed. With weak coherence, the construction may simplify enough to bypass it.

### Strategy C: Keep Strict + Fix Construction (Teammate C's approach)

Add `direct_witness_theory M := { psi | F(psi) ∈ M ∧ psi ∈ M }` to the seed. When phi ∈ chain(t) and F(phi) ∈ chain(t), phi enters the next chain via this theory, giving strict witness at t+1.

**Risk**: Medium. Need to prove this expanded seed is still consistent. The consistency argument (`F(phi) ∈ M → G(neg phi) ∉ M → phi ∈ M is safe`) needs careful verification.

## Priority Ranking

1. **Strategy A** (weaken coherence) — simplest, semantically justified, eliminates blocker 1
2. **Strategy B3** (re-examine need for f_preserving_seed_consistent under weak coherence)
3. **Strategy B1** (Lindenbaum-based fallback if B3 doesn't eliminate the need)

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Insight |
|----------|-------|--------|------------|-------------|
| A (modal-semantics) | F-operator semantics | completed | high | Semantics is reflexive; coherence is too strict |
| B (proof-theory) | Proof strategies | completed | high | f_preserving_seed_consistent may be false as stated |
| C (temporal-coherence) | Definition analysis | completed | medium | direct_witness_theory construction (valid but premised on wrong semantic assumption) |

## Code References

| File | Line | Description |
|------|------|-------------|
| `Truth.lean` | 125 | G semantics: `∀ s, t ≤ s → ...` (reflexive) |
| `Formula.lean` | 394 | F = ¬G¬ (derived, inherits reflexivity) |
| `Axioms.lean` | 290 | T-axiom Gφ → φ (reflexive consequence) |
| `TemporalCoherence.lean` | 144 | **INCORRECT** comment: "irreflexive semantics" |
| `TemporalCoherence.lean` | 148-149 | forward_F uses `t < s` (strict, mismatched) |
| `UltrafilterChain.lean` | ~4509 | Sorry: F-satisfaction at t edge case |
| `UltrafilterChain.lean` | ~1475 | Sorry: f_preserving_seed_consistent |

## References

- Goldblatt, R. "Logics of Time and Computation" — reflexive temporal frames use ≤
- Blackburn, de Rijke, Venema "Modal Logic" — F operator semantics depends on frame reflexivity
- Prior, A.N. "Past, Present and Future" — original reflexive temporal logic
