# Case C Deep Dive: Mixed-Case Countermodel

**Task**: 142 — mixed_case_countermodel
**Date**: 2026-05-15
**Focus**: Resolving the "Case C" blocker where F'T ∈ subformulaClosure(φ)

## 1. Case C Characterization

**When does Case C arise?** Case C occurs when `F'T = imp(next_top, bot) ∈ subformulaClosure(φ)`. Since `subformulas` (Subformulas.lean:41) decomposes `imp ψ χ` into both children, this automatically forces `next_top = U(T,⊥) ∈ subformulaClosure(φ)`. The converse does NOT hold — `U(T,⊥) ∈ subformulaClosure(φ)` does not force F'T in.

**Can Case C be eliminated?** No. Any formula φ explicitly containing F'T as a subformula triggers Case C. Example: `φ = p ∧ F'T`. Then `¬φ = ¬p ∨ U(T,⊥)` is consistent and can inhabit a mixed-case MCS. And F'T ∈ subformulaClosure(φ). The mixed-case hypotheses (`¬□(F'T) ∈ A` and `¬□(U(T,⊥)) ∈ A`) impose no constraints on subformulaClosure(φ).

## 2. Truth Lemma Analysis

### 2.1 Box Case Structure

The box case of `fully_restricted_parametric_shifted_truth_lemma` (RestrictedParametricTruthLemma.lean:365-388) fires when `□ψ ∈ subformulaClosure(root)`:

**Forward** (□ψ ∈ fam.mcs(t) → truth_at(□ψ)):
- Uses `modal_forward` to get `ψ ∈ fam'.mcs(t+delta)` for any `fam' ∈ B.families`
- Calls `ih h_ψ_sub fam' hfam' (t + delta)` — IH at ALL families

**Backward** (truth_at(□ψ) → □ψ ∈ fam.mcs(t)):
- Builds `∀ fam' ∈ B.families, ψ ∈ fam'.mcs t` via IH at each fam'
- Uses `B.modal_backward fam hfam ψ t h_all_fam`

Both directions call the IH for ALL families in the BFMCS. The truth lemma must hold at every family, not just the eval family.

### 2.2 Until Case and Coherence

The `untl` case (line 421-436) uses `restricted_forward_until_since_coherent` at the CURRENT family only. The critical line is `h_fwd_U t phi psi h_sub h_U` which requires: if `U(α,β) ∈ subformulaClosure(root)` and `U(α,β) ∈ fam.mcs(t)`, then a witness `s > t` exists with α at s and β on the guard (t,s).

For `U(T,⊥)` on ℚ: the guard (t,s) is always nonempty (dense order), so ⊥ ∈ fam.mcs(r) would be needed for some r — impossible. The coherence FAILS for any family where `U(T,⊥) ∈ fam.mcs(t)` on a dense domain.

### 2.3 Imp Case and Density Formulas

F'T = imp(U(T,⊥), bot). When the imp case processes F'T (line 330-364), it calls:
- `ih_ψ` for ψ = U(T,⊥) — hits the untl case
- `ih_χ` for χ = bot — trivial

So processing F'T at ANY family automatically invokes the Until coherence for U(T,⊥) at that family.

### 2.4 How Box Forces Cross-Family Evaluation

When `□ψ ∈ subformulaClosure(φ)` and ψ contains F'T (or U(T,⊥)) somewhere in its subformula tree, the box case calls IH at ALL families, which descends through imp/box/etc. until reaching the untl case for U(T,⊥). This means the Until coherence for U(T,⊥) must hold at ALL families, including discrete ones.

## 3. Partial BFMCS Feasibility

### 3.1 Dense-Only BFMCS on ℚ

For sub-case C1 (F'T ∈ A, D = ℚ, dense-only families):
- Truth lemma at dense families: U(T,⊥) ∉ any dense fam.mcs(t) (by uniformity), so Until coherence is vacuously satisfied ✓
- F'T ∈ dense fam.mcs(t), truth_at(F'T) = True on ℚ ✓
- **modal_backward**: For F'T — ALL dense families have F'T ∈ fam'.mcs(t), so `(∀ dense fam', F'T ∈ fam'.mcs t)` is TRUE. modal_backward would give □(F'T) ∈ fam.mcs(t). But ¬□(F'T) ∈ A (mixed-case hypothesis). **CONTRADICTION** — modal_backward CANNOT hold. ✗

### 3.2 Discrete-Only BFMCS on ℤ

For sub-case C2 (U(T,⊥) ∈ A, D = ℤ, discrete-only families):
- Truth lemma at discrete families: U(T,⊥) ∈ fam'.mcs(t), witness at t+1 on ℤ (vacuous guard) ✓
- F'T ∉ discrete fam'.mcs(t), truth_at(F'T) = False on ℤ. Both sides false — IFF holds ✓
- **modal_backward for F'T**: Premise `∀ discrete fam', F'T ∈ fam'.mcs t` is FALSE (F'T ∉ any discrete family). Implication vacuously TRUE ✓
- **modal_backward for U(T,⊥)**: ALL discrete families have U(T,⊥). Premise TRUE. Would give □(U(T,⊥)) ∈ fam.mcs(t). But ¬□(U(T,⊥)) ∈ A. **CONTRADICTION** ✗

### 3.3 Summary

Neither partial BFMCS works. The fundamental issue: in the mixed case, ¬□(F'T) ∈ A and ¬□(U(T,⊥)) ∈ A. Any single-type BFMCS has ALL families agreeing on F'T/U(T,⊥), making the "all families have ψ" premise of modal_backward TRUE for the density marker, contradicting ¬□(marker) ∈ A.

## 4. The Box-Subformula Refinement

### 4.1 Key Observation

F'T ∈ subformulaClosure(φ) does NOT imply □(F'T) ∈ subformulaClosure(φ). The subformulas function (Subformulas.lean:42) gives `box ψ :: subformulas ψ` — a box node contains its child, but a child does NOT contain its parent box.

So □(F'T) is in the closure ONLY if φ explicitly contains □(F'T) as a subformula.

### 4.2 Case C-easy vs C-hard

- **Case C-easy**: F'T ∈ subformulaClosure(φ), but NO formula of the form `□(...)` containing F'T or U(T,⊥) in its sub-tree is in subformulaClosure(φ). The box case of the truth lemma never directly forces cross-family evaluation of density-sensitive formulas.

- **Case C-hard**: Some `□ψ ∈ subformulaClosure(φ)` where ψ's sub-tree contains F'T or U(T,⊥). The box case forces evaluation at all families, requiring Until coherence for U(T,⊥) at every family.

### 4.3 Does Case C-easy Work?

**Almost but not quite.** In Case C-easy, the box case fires for OTHER `□ψ` formulas (not containing density formulas). The IH calls for ψ at all families. If ψ doesn't touch F'T/U(T,⊥), the truth lemma at each family doesn't hit the untl case for U(T,⊥).

However, **modal_backward is still needed** for these other ψ. With a single-type BFMCS, modal_backward requires: if ¬□ψ ∈ A, then ∃ matching-type fam' with ψ ∉ fam'.mcs(t). This fails when all ¬ψ witnesses happen to be the wrong type.

Specifically, for discrete-only BFMCS on ℤ: modal_backward fails for U(T,⊥) (all discrete families have it, but ¬□(U(T,⊥)) ∈ A). Even if □(U(T,⊥)) ∉ subformulaClosure(φ), the modal_backward condition is part of the BFMCS STRUCTURE, not just part of the truth lemma induction. It must hold for ALL formulas, not just those in subformulaClosure.

Wait — re-reading the BFMCS definition (BFMCS.lean:97):
```lean
modal_backward : ∀ fam ∈ families, ∀ φ t,
    (∀ fam' ∈ families, φ ∈ fam'.mcs t) → Formula.box φ ∈ fam.mcs t
```

This is universally quantified over ALL φ, not just subformulaClosure. So modal_backward must hold for F'T and U(T,⊥) regardless of whether they appear in the closure.

**Conclusion**: Case C-easy doesn't help. The BFMCS modal_backward condition requires universal quantification over all formulas, making the single-type BFMCS impossible for the mixed case.

## 5. Alternative Approaches

### 5.1 Mixed BFMCS (Both Types)

A BFMCS on ℚ with both dense and discrete families: the restricted Until coherence for U(T,⊥) ∈ subformulaClosure(φ) requires a witness at discrete families on ℚ. No immediate successor exists on ℚ. FAILS.

A BFMCS on ℤ with both dense and discrete families: the truth lemma for F'T at dense families gives truth_at(F'T) = False on ℤ, but F'T ∈ fam.mcs(t). Mismatch. FAILS.

### 5.2 Ockhamist/Caleiro Frame Approach

The Caleiro-Vigano-Volpe 2013 paper uses C-D-frames where different ≃-classes (branches) can live on different linear orders. This naturally handles the mixed case: dense branches on ℚ, discrete branches on ℤ. However, our TaskFrame requires a single domain D for all histories. The Caleiro model cannot be directly embedded into a TaskFrame.

### 5.3 Weakening the Completeness Statement

Instead of completeness over all `TaskFrame D` (for all ordered abelian groups D), prove:
- Completeness over all TaskFrame ℚ models (dense)
- Completeness over all TaskFrame ℤ models (discrete)
- Completeness over ClosureMCSBundle (FMP, already sorry-free)

The full universal quantifier `∀ D` would remain unresolved for Case C.

### 5.4 Two-Model Disjunctive Approach

Build two countermodel candidates (M₁ on ℚ, M₂ on ℤ) and argue at least one falsifies φ. This requires a non-constructive disjunction: "either M₁ or M₂ works." The difficulty is that we'd need to show the truth lemma "almost works" in both and one succeeds. This is speculative and the proof architecture is unclear.

### 5.5 Restructured BFMCS with Restricted Modal Backward

Define a variant BFMCS where modal_backward is restricted to subformulaClosure(root):

```lean
restricted_modal_backward : ∀ fam ∈ families, ∀ φ t,
    φ ∈ subformulaClosure root →
    (∀ fam' ∈ families, φ ∈ fam'.mcs t) → Formula.box φ ∈ fam.mcs t
```

Then modal_backward for F'T/U(T,⊥) is only needed when they're in the closure AND boxed. This approach requires:
1. Modifying the BFMCS structure to add a `root` parameter
2. Proving the truth lemma works with restricted modal_backward
3. Verifying that the truth lemma's box case only invokes modal_backward for ψ ∈ subformulaClosure(root)

**Checking feasibility**: The box case (line 388) calls `B.modal_backward fam hfam ψ t h_all_fam` where `h_sub : Formula.box ψ ∈ subformulaClosure root`, hence `ψ ∈ subformulaClosure root` (by closure_box). So the call IS scoped to subformulaClosure(root).

**This means modal_backward in the truth lemma is ONLY used for ψ ∈ subformulaClosure(root)**. If we define a restricted_modal_backward that only covers these ψ, the truth lemma proof goes through unchanged (just referencing the restricted version).

**This is the breakthrough insight for Case C-easy**: if no `□(density-sensitive) ∈ subformulaClosure(φ)`, then the restricted modal_backward never needs to handle F'T or U(T,⊥) directly. A single-type BFMCS with restricted_modal_backward WORKS.

For Case C-easy with discrete-only BFMCS on ℤ:
- restricted_modal_backward for ψ ∈ subformulaClosure(φ): if ¬□ψ ∈ A, need ∃ discrete fam' with ψ ∉ fam'.mcs(t)
- U(T,⊥) ∈ subformulaClosure(φ) but □(U(T,⊥)) ∉ subformulaClosure(φ): the box case never fires for U(T,⊥), so restricted_modal_backward for U(T,⊥) is never invoked ✓
- F'T ∈ subformulaClosure(φ) but □(F'T) ∉ subformulaClosure(φ): same reasoning ✓
- For OTHER □ψ ∈ subformulaClosure(φ) where ψ doesn't force density-type witnesses: restricted_modal_backward works if ∃ discrete N with ¬ψ ∈ N

**Remaining risk in Case C-easy**: some `□ψ ∈ subformulaClosure(φ)` might have all ¬ψ witnesses be dense. This happens when Box(A) ⊢ ψ ∨ F'T (for discrete-only, sub-case C2). But since □(F'T) ∉ subformulaClosure(φ), the formula ψ doesn't directly contain boxed density markers.

### 5.6 Case C-hard: Fundamental Blocker

When `□(F'T) ∈ subformulaClosure(φ)` or `□(U(T,⊥)) ∈ subformulaClosure(φ)`:
- The box case fires for the density formula
- restricted_modal_backward IS invoked for F'T or U(T,⊥)
- With single-type BFMCS: the density marker is uniform across all families → modal_backward derives □(marker) → contradicts ¬□(marker) ∈ A

This is provably impossible within the current architecture. No single ordered abelian group D can give correct truth values for both types.

**However**: Case C-hard requires φ to explicitly contain `□(F'T)` or `□(U(T,⊥))` as a subformula. These are very specific formula patterns: `box(imp(untl(top, bot), bot))` or `box(untl(top, bot))`.

## 6. Recommended Approach

### 6.1 Three-Tier Strategy

**Tier 1: Cases A, B, D** (U(T,⊥) ∉ subformulaClosure(φ), or F'T ∉):
- Use existing approach: D = ℚ or D = ℤ with full BFMCS
- All coherence conditions satisfied
- **Effort**: 15-25 hours (adapt existing constructions)

**Tier 2: Case C-easy** (F'T ∈ subformulaClosure(φ), no boxed density formula):
- Use restricted_modal_backward BFMCS
- D = ℤ (sub-case C2) or D = ℚ (sub-case C1) with single-type families
- restricted_modal_backward scoped to subformulaClosure(φ) — density markers excluded
- **Effort**: 15-25 hours (new restricted BFMCS variant, truth lemma adaptation)
- **Risk**: Some non-density □ψ might have only wrong-type witnesses. Needs case-by-case analysis.

**Tier 3: Case C-hard** (□(F'T) or □(U(T,⊥)) ∈ subformulaClosure(φ)):
- Fundamentally blocked within current architecture
- Options:
  (a) **Derivability argument**: Show that for φ containing □(F'T) or □(U(T,⊥)), the mixed-case MCS has special properties allowing a shortcut (e.g., ¬φ derivable from BX). Unlikely for general φ.
  (b) **Ockhamist bridge**: Prove completeness via Caleiro-style C-D-frames (different domains per branch), then show this implies TaskFrame completeness. Major architectural change (~100+ hours).
  (c) **Accept as limitation**: Document Case C-hard as a known limitation. Prove completeness for all φ NOT containing □(F'T) or □(U(T,⊥)) as subformulas. This covers the vast majority of interesting formulas.
  (d) **Weaken TaskFrame**: Replace AddCommGroup with a weaker domain requirement that allows mixed-density domains.
- **Effort**: (a) 5-10h speculative, (b) 100+h, (c) 0h, (d) 40-60h

### 6.2 Concrete Recommendation

1. **Implement Tiers 1+2 first** (30-50 hours). This resolves the sorry for all φ where neither `□(F'T)` nor `□(U(T,⊥))` is an explicit subformula. This covers ALL formulas that don't specifically box the density/discreteness markers — a natural and broad class.

2. **For Tier 3**: Start with option (a) — investigate whether Case C-hard φ can be handled via derivability. If φ contains □(F'T), the mixed-case hypothesis ¬□(F'T) ∈ A directly says □(F'T) is NOT in A. Combined with the formula structure, there might be a propositional shortcut.

3. **Fallback**: Document Case C-hard as an open problem. The sorry would only fire for formulas explicitly containing `□(¬U(⊤,⊥))` or `□(U(⊤,⊥))` — a narrow class that doesn't arise in typical applications of the logic.

## 7. Estimated Effort

| Component | Hours | Risk |
|-----------|-------|------|
| Tiers 1 (Cases A/B/D): existing approach adaptation | 15-25h | Low |
| Tier 2 (Case C-easy): restricted_modal_backward BFMCS | 15-25h | Medium |
| Tier 3 (Case C-hard): derivability investigation | 5-10h | High (may fail) |
| Tier 3 fallback: documentation + partial proof | 3-5h | Low |
| **Total (without Tier 3 resolution)** | **33-55h** | |
| **Total (with Tier 3 if derivability works)** | **38-65h** | |

## 8. Open Questions

1. **Restricted modal_backward soundness**: Does the truth lemma proof actually work with restricted_modal_backward? I traced through the code and believe so (line 388 only invokes modal_backward for ψ ∈ subformulaClosure(root)), but this needs formal verification.

2. **Case C-easy witness availability**: For non-density □ψ ∈ subformulaClosure(φ) in the mixed case, is the ¬ψ witness always available in the matching type? This depends on whether Box(A) ⊢ ψ ∨ (density marker) for arbitrary ψ. Need to analyze specific formula patterns.

3. **Case C-hard derivability**: Can we show that for φ containing □(F'T), the combination of ¬φ ∈ A and the mixed-case hypotheses leads to a derivability argument? The interaction axiom `modal_future: □φ → □(Gφ)` might help.

4. **Literature gap**: None of the surveyed literature (Burgess, Caleiro, Reynolds, Venema, Doets) addresses the specific problem of combining S5 modality with Until/Since over ordered abelian group domains where different accessible worlds have different density types. Burgess avoids it (general linear orders, no groups). Caleiro handles it (C-D-frames with heterogeneous branches) but their semantic framework differs from TaskFrame.
