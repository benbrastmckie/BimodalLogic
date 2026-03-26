# Research Report: Task #65 (Wave 3)

**Task**: Build TaskModel from Restricted Construction
**Date**: 2026-03-26
**Mode**: Team Research Wave 3 (Teammate A only — focused analysis)
**Session**: sess_1774564779_fb09d1

## Executive Summary

Wave 3 focused on a single precise question: **Can a forward-only truth lemma suffice for completeness, avoiding the family-level coherence requirement?**

**Answer: No.** The `imp` forward case in `shifted_truth_lemma` requires the backward IH for the antecedent (line 677: `.mpr`), making a purely forward truth lemma impossible in the current proof strategy. The coherence gap for G/H is a secondary obstacle; the `imp` case is a primary obstacle that has nothing to do with temporal coherence.

**Revised recommendation**: The omega-enumeration construction (achieving family-level temporal coherence) remains the only viable path for a truth-lemma-based completeness proof.

## Wave 3 Focus: Mathematical Analysis of Coherence Gap

### The Forward-Only Truth Lemma Hypothesis

The hypothesis entering wave 3 was: for completeness via contrapositive, we only need the forward direction of the truth lemma (MCS membership implies truth), not the backward direction (truth implies MCS membership). The backward direction is needed for G/H backward cases which require family-level coherence.

### The `imp` Forward Case Obstacle (New Finding)

Examining `shifted_truth_lemma` at `CanonicalConstruction.lean:672-702`:

```lean
| imp ψ χ ih_ψ ih_χ =>
  constructor
  · -- Forward: (ψ → χ) ∈ fam.mcs t → (truth ψ → truth χ)
    intro h_imp h_ψ_true
    have h_ψ_mem := (ih_ψ fam hfam t).mpr h_ψ_true   -- LINE 677: BACKWARD IH!
    exact (ih_χ fam hfam t).mp (...)
```

**The forward direction of `imp` calls `.mpr` on `ih_ψ`** — the backward direction of the IH for the antecedent. This is not avoidable: to show that "(ψ → χ) in MCS implies (truth ψ → truth χ)," the proof must convert "truth ψ" back to "ψ ∈ MCS" using the MCS implication property, which requires the backward direction for ψ.

This means the full biconditional is required for ALL subformulas, even when applying the truth lemma only in the forward direction at the outermost level.

### Complete Case Analysis of `shifted_truth_lemma`

| Case | Direction | Coherence Needed | Notes |
|------|-----------|-----------------|-------|
| `atom` forward | Forward IH | None | Trivial |
| `atom` backward | Backward IH | None | Trivial |
| `bot` forward | Forward only | None | By MCS consistency |
| `imp` forward | **Backward IH for ψ** | None | Line 677 |
| `imp` backward | Backward IH for χ | None | Line 701 |
| `box` forward | Forward IH | `modal_forward` | Uses `B.modal_forward` |
| `box` backward | Backward IH | `modal_backward` | Uses `B.modal_backward` |
| `G` forward | Forward IH | `FMCS.forward_G` | No temporal coherence needed |
| `G` backward | **Backward IH** | **Family-level forward_F** | Lines 744-754 |
| `H` forward | Forward IH | `FMCS.backward_H` | No temporal coherence needed |
| `H` backward | **Backward IH** | **Family-level backward_P** | Lines 762-772 |

The G/H backward cases require `h_tc : B.temporally_coherent` (family-level). But the `imp` forward case requires the full biconditional IH for its antecedent — creating a recursive dependency on the biconditional for all subformulas regardless.

### What the Completeness Proof Actually Needs

The sorry in `bundle_validity_implies_provability` (Completeness.lean:186-214) requires:

```
valid_over Int phi
    → phi ∈ M0  (for specific MCS M0)
```

The proof path via the truth lemma:
1. Instantiate `valid_over Int phi` with `(CanonicalTaskFrame, CanonicalTaskModel, ShiftClosedCanonicalOmega B)`
2. Get: `truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history B.eval_family) 0 phi`
3. Apply `shifted_truth_lemma` **backward** direction: truth → MCS membership
4. Get: `phi ∈ B.eval_family.mcs 0 = M0`

Step 3 requires the **backward** direction of `shifted_truth_lemma`, which requires family-level temporal coherence for the G/H cases. There is no way around this via the truth-lemma path.

### Summary: Why Forward-Only Does Not Suffice

Two independent obstacles prevent a forward-only approach:

1. **`imp` forward requires backward IH for antecedent** — fundamental to the MCS-based proof strategy, unrelated to temporal coherence. Cannot be avoided.

2. **The completeness bridge requires backward truth lemma** — `valid_over` instantiation gives "phi is true," but we need "phi is in MCS." This is the backward direction.

The forward direction of the truth lemma (MCS membership → truth) is only useful for showing "neg(phi) is false at some model point" — but this already follows directly from `mcs_neg_gives_countermodel` without any truth lemma.

## Updated Assessment of Viable Paths

### Path A: Omega-Enumeration Construction (Recommended)

Build families with genuine family-level temporal coherence using explicit dovetailing of F/P obligations. This enables `shifted_truth_lemma` as currently proven to go through without modification.

- **Status**: Construction not yet implemented (see UltrafilterChain.lean:1865-1893 for documentation only)
- **Effort**: High (6-10 hours) — requires building `omegaClassFamilies`
- **Correctness**: High confidence — addresses the coherence mismatch directly

### Path B: Alternative Bridge via Soundness

Rather than using the truth lemma as a bridge, use a proof-theoretic argument:

- Soundness: `[] ⊢ phi → valid_over Int phi`
- Contrapositive: `¬valid_over Int phi → ¬([] ⊢ phi)`
- Valid_over → provable is equivalent to: not provable → not valid
- Build a countermodel directly (algebraic completeness already done in `bundle_completeness_contradiction`)

**The gap**: `bundle_completeness_contradiction` shows `¬(∀ M : SetMaximalConsistent, phi ∈ M)`, but `valid_over` requires truth in ALL `TaskModel`s, not just all MCSes. The bridge from "not in some MCS" to "not valid in some TaskModel" still requires the truth lemma (forward direction this time: MCS membership → truth).

For the forward direction: if `neg(phi) ∈ M0` (which is a MCS), then `neg(phi)` is true in the canonical model at `(eval_family, time 0)`. This requires the **forward** truth lemma for `neg(phi)`.

And the forward truth lemma for `neg(phi) = phi.imp bot` hits the `imp` forward obstacle: it needs the backward IH for `phi`.

**Conclusion**: Path B collapses to the same requirement as Path A.

### Path C: Axiom-Free Algebraic Completeness

Sidestep the `valid_over → provable` direction entirely using a different definition of validity. If `valid_over` were defined algebraically (in terms of MCS membership rather than truth semantics), the sorry could be resolved without a truth lemma. But this would require changing the definition of `valid_over`, which has downstream effects.

This path is not recommended — it changes the theorem statement rather than proving it.

## Conclusion

**The forward-only truth lemma approach is not viable.** The `imp` forward case requires the full biconditional for subformulas, and the completeness bridge requires the truth lemma in the backward direction. Both obstacles are fundamental.

**The omega-enumeration construction (Path A) is the correct resolution.** It achieves family-level temporal coherence, enabling the existing `shifted_truth_lemma` to apply, which enables the backward truth lemma direction needed for the completeness bridge.

## References

| Claim | File | Lines |
|-------|------|-------|
| `imp` forward uses backward IH for antecedent | CanonicalConstruction.lean | 677 |
| G backward requires family-level forward_F | CanonicalConstruction.lean | 744-754 |
| H backward requires family-level backward_P | CanonicalConstruction.lean | 762-772 |
| Completeness sorry (model-theoretic glue) | Completeness.lean | 186-214 |
| Algebraic completeness (sorry-free) | UltrafilterChain.lean | 2931-2945 |
| Omega-enumeration construction (docs only) | UltrafilterChain.lean | 1865-1893 |
