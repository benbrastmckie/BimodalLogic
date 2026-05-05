# Teammate B Findings: Alternative Approaches for Pos Sub-case

## Key Findings

### 1. ROOT CAUSE: SetDeductivelyClosed Requires Consistency (Diverges from Burgess)

The formalization defines `SetDeductivelyClosed` (ChronicleTypes.lean:82) as:
```lean
def SetDeductivelyClosed (S : Set Formula) : Prop :=
  SetConsistent S ∧ ClosedUnderDerivation S
```

Burgess 1982 (Section 1.3, line 65 of literature file) defines DCS as:
> "A is *deductively closed* if it contains all its consequences."

**No consistency requirement.** In Burgess's framework, Set.univ IS a DCS (deductively closed, just not consistent). His R-maximality (line 142) quantifies over ALL proper DCS extensions:

> "R(A, B, C) ... r(A, B, C) holds, but r(A, B', C) never holds for any proper extension B' of B"

When Burgess writes "else consider B' = consequences of B ∪ {δ}", this works even when {δ}∪B is inconsistent (consequences = Set.univ, which IS a DCS in his sense). So his maximality witness β with ¬U(γ, β∧δ)∈A exists UNCONDITIONALLY — no case split needed.

### 2. The Inconsistent Case is a FORMALIZATION ARTIFACT

The case split at PointInsertion.lean:2051 (`by_cases h_cons : SetConsistent ({β} ∪ B)`) exists ONLY because:
- `BurgessR3Maximal_extension_fails` requires `h_cons : SetConsistent ({δ} ∪ B)` 
- This is required because the Zorn construction only gives maximality over `SetDeductivelyClosed` sets (which include consistency)
- If `{δ}∪B` is inconsistent, `DC({δ}∪B) = Set.univ` is NOT `SetDeductivelyClosed` in our sense, so maximality doesn't apply

In Burgess's framework, this case split doesn't exist because his DCS includes Set.univ.

### 3. irr_until Axiom `G(φ.neg) → (untl(φ,ψ)).neg` is NOT Sound for All Strict Linear Orders

Under open-guard semantics with the code's convention (`untl(guard, event)`):
- `untl(φ,ψ)` at t iff ∃s>t: ψ@s ∧ ∀r∈(t,s): φ@r
- On discrete orders with adjacent t, t+1: open interval (t,t+1) is empty
- So `untl(φ,ψ)` at t requires only ψ@(t+1) — guard φ is vacuously satisfied
- `G(φ.neg)` means φ is false at ALL future points, but doesn't constrain ψ
- Therefore `untl(φ,ψ)` CAN be true at t even with G(φ.neg) at t (just need ψ@(t+1))

**Conclusion**: This axiom is sound for DENSE strict orders only (where open intervals are non-empty). Adding it would restrict the completeness theorem to dense frames.

### 4. Structural Elimination — Can We Guarantee {β}∪B is Always Consistent?

At the call site (line 2051), `β` is the formula with `β ∉ B` (from the R-maximality/extension_fails step). The question is whether `{β}∪B` can ever be inconsistent.

**Answer**: YES, it can. B is a consistent DCS containing β.neg (β.neg ∈ B is possible when β.neg is a consequence of B). Since β ∉ B, and β.neg ∈ B, then {β}∪B is inconsistent (β + β.neg → ⊥). This is a genuine case.

**However**: In this case, `neg_mem_of_inconsistent_union` gives β.neg ∈ B directly. The question is whether the D0 seed is consistent — and it IS, because D0 ⊆ B ∪ {formulas already in A}. Since B is consistent and the extra formulas are membership conditions on A (which is an MCS), the seed inherits consistency from B.

### 5. RECOMMENDED FIX: Split SetDeductivelyClosed Into Separate Hypotheses

The cleanest fix (matching Burgess exactly) is:

**Option A** — Change the definition to match Burgess (HIGH IMPACT):
```lean
def SetDeductivelyClosed (S : Set Formula) : Prop := ClosedUnderDerivation S
```
Then add `SetConsistent` as a separate hypothesis where needed. The Zorn construction would quantify over `{S | ClosedUnderDerivation S ∧ SetConsistent S ∧ burgessR3 A S C}` as it does now, but `BurgessR3Maximal` maximality would quantify over ALL `ClosedUnderDerivation` sets. This was tried before (report 56) and introduced an unprovable sorry because `burgessR3(A, Set.univ, C)` is satisfiable.

**Option B** — Keep `SetDeductivelyClosed` as-is but prove the inconsistent case directly (CURRENT APPROACH):
The neg sub-case already works. For the pos sub-case, the key insight is that `untl(⊥, γ_hat) ∈ A` combined with left_mono_until_G gives `untl(q, γ_hat) ∈ A` for ANY q (since G(⊥→q) is a theorem). So the seed elements `untl(β', γ)` for β'∈B are ALL in A (via burgessR3), the seed elements in B are all in B, and β.neg ∈ B. The D0 seed consistency follows from B's consistency + the fact that all Until/Since additions are already in A or C.

**Option C** — Delete the inconsistent-case function entirely (PREFERRED):
Since β.neg ∈ B in the inconsistent case, and D0_seed = B ∪ {β.neg} ∪ {untl-formulas} ∪ {snce-formulas}, the seed simplifies to B ∪ {untl-formulas} ∪ {snce-formulas} (β.neg already in B). This is a SUBSET of what the consistent case proves. Just call the consistent case with a modified argument:
- Use `neg_mem_of_inconsistent_union` to get β.neg ∈ B
- Observe {β.neg}∪B = B (since β.neg ∈ B), so SetConsistent({β.neg}∪B) = SetConsistent(B) = true
- Call `burgess_D0_finite_subset_consistent` directly with appropriate witnesses

Wait — the consistent case function requires `h_cons : SetConsistent ({β} ∪ B)`, not `SetConsistent ({β.neg} ∪ B)`. And it needs the maximality witness `β₀, γ₀` from `BurgessR3Maximal_extension_fails` which requires `SetConsistent ({β} ∪ B)`. So this doesn't directly work.

**Option D** — Prove the pos sub-case is VACUOUS by showing `burgess_zeta_consistent` provides all needed implications:
In the neg sub-case, `burgess_zeta_consistent` produces an event implying b, β.neg, untl(b,γ_hat), and snce(b,α). These are EXACTLY the D0 seed elements. The neg sub-case handles the entire proof. The pos sub-case sorry can be resolved by showing it contradicts the MCS property: if `untl(b∧β, γ_hat) ∈ A` AND the neg sub-case's BX14 derivation both hold, MCS can't contain both. But that's circular (we case-split on whether the neg is in A).

## Recommended Approach

**Priority order**:
1. **Option C variant**: Prove that in the inconsistent case (β.neg ∈ B), the D0 seed consistency follows from a DIRECT argument not involving `burgess_zeta_consistent` at all. Since D0 ⊆ B ∪ {formulas provably in A via burgessR3}, and B is consistent, use compactness/DCS closure to show any finite subset is consistent. The Until formulas `untl(β', γ)` are in A (β'∈B, γ∈C, burgessR3 gives this). The Since formulas `snce(β', α)` are in C (β'∈B, α∈A, burgessR3Since gives this). Consistency of any finite L ⊆ D0 follows from the MCS property of A combined with DCS closure of B.

2. **irr_until axiom** (only if restricting to dense orders is acceptable): Add `G(φ.neg) → (untl(φ,ψ)).neg`. Makes pos sub-case vacuous. But restricts theorem scope.

## Evidence/Examples

- Burgess Section 1.3 (line 65): DCS = deductively closed (no consistency)
- Burgess Section 2.3 (line 142): R-maximality over all proper DCS extensions  
- ChronicleTypes.lean:82: SetDeductivelyClosed = SetConsistent ∧ ClosedUnderDerivation (diverges)
- Soundness.lean:524: left_mono_until_G proven sound for all strict linear orders
- On Z with adjacent points: untl(⊥, γ) satisfiable (witness = next point, empty guard interval)

## Confidence Level

**High** — The root cause (DCS definition mismatch) is clearly identified. The irr_until soundness analysis is straightforward from the semantics. The recommended direct-consistency approach for the inconsistent case needs verification against the actual proof obligations.
