# Research Report: Inconsistent Case Resolution — No Density Required

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-29
**Session**: sess_1777484344_568000
**Type**: lean4

## Summary

The Phase 5b blocker (inconsistent case of g_content(A) ⊆ B) is a **false alarm**. The team research in Reports 45 and 46 incorrectly concluded that the inconsistent case requires density. The actual issue is that the codebase's `BurgessR3Maximal_extension_fails` lemma (PointInsertion.lean:641) is too weak — it requires `SetConsistent ({φ} ∪ B)`, but the BurgessR3Maximal definition (ChronicleTypes.lean:315-318) maximizes over ALL DCSs including inconsistent ones. The inconsistent case is handled by showing burgessR3(A, Set.univ, C), which contradicts maximality since B ⊂ Set.univ.

No density axiom needed. No semantic shortcut needed. The existing left_mono_until_G axiom suffices.

## The Error in Reports 45-46

Reports 45 and 46 identified the inconsistent case: when G(φ) ∈ A and ¬φ ∈ B (so {φ}∪B is inconsistent), the proof produces `untl(⊥, γ) ∈ A`, which is satisfiable on non-dense frames and irrefutable in TL_US. The reports concluded this was a genuine blocker requiring density or a semantic shortcut.

**The error**: The reports analyzed `BurgessR3Maximal_extension_fails` and saw it requires `h_cons : SetConsistent ({delta} ∪ B)`. They concluded the inconsistent case couldn't produce a maximality contradiction. But the BurgessR3Maximal DEFINITION says:

```lean
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  burgessR3 A B C ∧
  ∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessR3 A D C
```

The maximality condition `∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessR3 A D C` quantifies over ALL DCSs D, including inconsistent ones like Set.univ. The lemma `BurgessR3Maximal_extension_fails` is simply too weak — it only handles the consistent case. The inconsistent case should use the definition directly.

## The Correct Proof

### Theorem: g_content(A) ⊆ B when BurgessR3Maximal(A, B, C)

**Given**: BurgessR3Maximal(A, B, C), G(φ) ∈ A, g_content(A) ⊆ C (hypothesis of lemma_2_6_splitting).
**Goal**: φ ∈ B.

Suppose φ ∉ B. By classical logic, either {φ}∪B is consistent or inconsistent.

#### Case 1: {φ}∪B is consistent (ALREADY PROVED in codebase)

DC(B∪{φ}) is a proper consistent DCS extending B. By the existing proof (PointInsertion.lean lines 353-386), burgessR3(A, DC(B∪{φ}), C) holds using left_mono_until_G + dc_delta_B_controlled. By BurgessR3Maximal maximality: contradiction. ✓

#### Case 2: {φ}∪B is inconsistent (THE NEW PART)

**Step 1**: DC(B∪{φ}) = Set.univ (deductive closure of an inconsistent set is all formulas).

**Step 2**: Set.univ is SetDeductivelyClosed (trivially — all consequences are in Set.univ).

**Step 3**: B ⊂ Set.univ. Proof: B ⊆ Set.univ is trivial. B ≠ Set.univ because φ ∈ Set.univ but φ ∉ B (our assumption).

**Step 4**: burgessR3(A, Set.univ, C) holds.

*Until direction*: For any ψ (any formula at all) and any γ ∈ C, need untl(ψ, γ) ∈ A.

Since {φ}∪B is inconsistent, there exists β₀ ∈ B with `⊢ (β₀ ∧ φ) → ⊥` (from DCS closure of B). For any formula ψ: `⊢ (β₀ ∧ φ) → ψ` (ex falso quodlibet).

From `⊢ (β₀ ∧ φ) → ψ`, by currying: `⊢ φ → (β₀ → ψ)`.
By TG: `⊢ G(φ → (β₀ → ψ))`.
By temporal K distribution: `G(φ) → G(β₀ → ψ)`.
Since G(φ) ∈ A: **G(β₀ → ψ) ∈ A**.

By left_mono_until_G: `G(β₀ → ψ) → untl(β₀, γ) → untl(ψ, γ)`.
From burgessR3(A, B, C) with β₀ ∈ B: untl(β₀, γ) ∈ A.
Therefore: **untl(ψ, γ) ∈ A**. ✓

*Since direction*: burgessRSetSince(C, Set.univ, A) follows from burgessR_implies_burgessRSince applied to burgessRSet(A, Set.univ, C). This lemma is already sorry-free in the codebase (RRelation.lean:1217). ✓

**Step 5**: By BurgessR3Maximal definition (line 318): SetDeductivelyClosed(Set.univ) ∧ B ⊂ Set.univ → ¬burgessR3(A, Set.univ, C). But we proved burgessR3(A, Set.univ, C) in Step 4. **Contradiction**. ✓

### Why untl(⊥, γ) Is Irrelevant

The team research focused on `untl(⊥, γ) ∈ A` being irrefutable. But this is a red herring. We never need to refute untl(⊥, γ). Instead, we derive untl(ψ, γ) ∈ A for ALL ψ (including ψ = ⊥), and use this to show burgessR3(A, Set.univ, C). The contradiction comes from MAXIMALITY (B ⊂ Set.univ with burgessR3 for Set.univ), not from refuting any particular formula in A.

The formula untl(⊥, γ) IS satisfiable on non-dense frames, and it IS irrefutable. But that doesn't matter — the proof never tries to refute it. It uses it constructively: untl(ψ, γ) ∈ A for all ψ means burgessRSet(A, Set.univ, C), which gives the maximality contradiction.

## Burgess's Framework Confirms This

Burgess's "earlier remark" (Section 2.3, after Lemma 2.3 definition): *"Note that whenever R(A, B, C) holds and δ ∉ B there must exist a β ∈ B such that r(A, β ∧ δ, C) does not hold (else consider B' = consequences of B ∪ {δ})."*

Burgess's argument works for BOTH the consistent and inconsistent cases:
- Consistent: DC(B∪{δ}) is a proper consistent DCS, contradicts R-maximality.
- Inconsistent: DC(B∪{δ}) = Set.univ is a proper (since δ ∉ B) DCS, and if r(A, Set.univ, C) holds, contradicts R-maximality.

Burgess does not distinguish these cases because both work the same way. He works over all linear orders (𝒦₀), not just dense ones. His axiom system 𝒥₀ does NOT include density.

Xu's framework confirms this as well — Xu 2.0(iii) uses the same argument structure.

## Implementation Plan

### What needs to change in the codebase

1. **In the inconsistent case of `g_content_sub_B_of_BurgessR3Maximal`** (PointInsertion.lean, currently sorry at line 676):
   - Show DC(B∪{φ}) = Set.univ (from inconsistency)
   - Show Set.univ is SetDeductivelyClosed
   - Show B ⊂ Set.univ (from φ ∉ B)
   - Show burgessR3(A, Set.univ, C) using the ex-falso + left_mono_until_G argument
   - Apply BurgessR3Maximal maximality directly (not via BurgessR3Maximal_extension_fails)
   - Derive False

2. **Helper lemmas needed**:
   - `deductiveClosure_inconsistent_eq_univ`: if ¬SetConsistent S, then deductiveClosure S = Set.univ (~10 lines)
   - `set_univ_deductively_closed`: Set.univ is SetDeductivelyClosed (~5 lines, trivial)
   - `burgessR3_univ_from_inconsistent_extension`: the ex-falso argument showing burgessR3(A, Set.univ, C) when ∃β₀∈B with (β₀∧φ)→⊥ provable and G(φ)∈A (~30 lines)

3. **The `h_content_sub_B` dual** follows by the mirror argument.

4. **`splitting_seed_consistent`** then closes trivially as before: seed ⊆ {β.neg} ∪ B, consistent by dcs_neg_union_consistent.

### Estimated effort: 4-6 hours total for Phase 5b completion

### No changes needed to:
- Axiom system (left_mono_until_G already added)
- Soundness proofs (already done)
- Match arms (already done)
- BurgessR3Maximal definition (correct as-is)
- Downstream phases 6-11 (independent of this fix)

## Key Lesson

The blocker was not a mathematical gap — it was an API gap. The codebase's `BurgessR3Maximal_extension_fails` lemma was weaker than the definition it was derived from. The definition quantifies over all DCSs (consistent or not), but the lemma only handled the consistent case. Handling the inconsistent case directly against the definition resolves the issue completely.

## References

- Burgess 1982, Section 2.3: "earlier remark" about maximality failure (line 142 of literature transcription)
- BurgessR3Maximal definition: ChronicleTypes.lean:315-318
- BurgessR3Maximal_extension_fails: PointInsertion.lean:641-645 (too weak)
- g_content_sub_B consistent case: PointInsertion.lean:353-386 (already proved)
- g_content_sub_B inconsistent case: PointInsertion.lean:676 (sorry, to be fixed)
