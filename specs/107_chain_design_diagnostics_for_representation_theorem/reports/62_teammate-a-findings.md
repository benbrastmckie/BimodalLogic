# Teammate A — Primary Approach Analysis: 8 Sorry Sites vs. Burgess 1982

**Task**: 107 — Burgess chronicle construction for BX representation theorem
**Date**: 2026-05-05
**Angle**: Primary approach — map each sorry to Burgess's paper, determine correct resolution
**Confidence**: See per-site ratings below

---

## Sorry Site #1: PointInsertion.lean:1977 — Case B (B is MCS) in Lemma 2.6 Splitting

### Burgess Reference
Lemma 2.6 (p. 371): The proof constructs D₀ = {S(α,β) : α ∈ A, β ∈ B} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ ∈ C, β ∈ B} and proves D₀ is consistent. The key step uses **maximality of B**: since δ ∉ B, there exist β₀ ∈ B, γ₀ ∈ C with ¬U(γ₀, β₀∧δ) ∈ A. This witness comes from R(A,B,C) maximality.

### Current Lean State
The code case-splits on `SetMaximalConsistent B`. In Case B (B is MCS), the pos sub-case has `untl(b∧β, γ_hat) ∈ A` and needs to derive `False`. The problem: when B is MCS, every formula δ ∉ B has δ.neg ∈ B, making {δ}∪B inconsistent. The `BurgessR3Maximal_extension_fails` mechanism cannot extract a neg-until witness because it requires **consistent** extensions.

### Root Cause
This sorry exists because the code performs a case split on `SetMaximalConsistent B` that **Burgess never makes**. In Burgess, B is a DCS (deductively closed set), never required to be an MCS. The maximality is over **all** DCSs (including Set.univ), so δ ∉ B always yields a neg-until witness regardless of whether B is MCS.

### Resolution Following Burgess
The current `BurgessR3Maximal` definition (line 326 of ChronicleTypes.lean) already uses maximality over `ClosedUnderDerivation` sets:
```lean
∀ D, ClosedUnderDerivation D → B ⊂ D → ¬burgessR3 A D C
```
When B is MCS and β ∉ B, we have β.neg ∈ B, so {β}∪B is inconsistent. Then DC({β}∪B) = Set.univ (by `inconsistent_cud_is_univ`). Since Set.univ is ClosedUnderDerivation and B ⊂ Set.univ (B is consistent, Set.univ is not), the maximality clause gives ¬burgessR3(A, Set.univ, C). But we ALSO need a **specific** neg-until witness ¬U(γ₀, β₀∧β) ∈ A.

The correct proof: From ¬burgessR3(A, Set.univ, C), unfolding the definition, either:
- ∃ δ ∈ Set.univ, ∃ γ ∈ C, untl(δ, γ) ∉ A — i.e., there exist formulas δ, γ ∈ C with ¬untl(δ, γ) ∈ A (since A is MCS), OR
- ∃ δ ∈ Set.univ, ∃ α ∈ A, snce(δ, α) ∉ C

For the first case, we get ¬burgessRSet(A, Set.univ, C), meaning ∃ δ, ∃ γ ∈ C, untl(δ, γ) ∉ A. Since A is MCS: ¬untl(δ, γ) ∈ A. We can then choose β₀ = any element of B (e.g., bot→bot) and γ₀ = γ. By left_mono: ¬untl(β₀∧β, γ) ∈ A follows from ¬untl(δ, γ) ∈ A... wait, this doesn't directly work. We need the specific form ¬untl(β₀∧β, γ₀) where β₀ ∈ B and γ₀ ∈ C.

**Actually**, the correct approach is different. The existing `BurgessR3Maximal_extension_fails` should work for the Set.univ case. Since B ⊂ Set.univ (B is MCS hence consistent, Set.univ is not), and ClosedUnderDerivation Set.univ is trivially true, the maximality clause gives ¬burgessR3(A, Set.univ, C). Unfolding: ¬(burgessRSet(A, Set.univ, C) ∧ burgessRSetSince(C, Set.univ, A)). By `push_neg`: ¬burgessRSet(A, Set.univ, C) ∨ ¬burgessRSetSince(C, Set.univ, A).

For the Until direction: ¬burgessRSet(A, Set.univ, C) means ∃ δ, ∃ γ ∈ C, untl(δ, γ) ∉ A. Since β ∈ Set.univ (trivially), we can substitute β₀ = δ. Then by left_mono using ⊢ (b∧β) → δ... no, we need ⊢ δ → (b∧β). That's backwards.

**The right approach**: We don't need a neg-until witness with the specific form β₀∧β. What we actually need in the proof is to show the D₀ seed is consistent. Looking at Burgess's proof more carefully: he uses δ ∉ B (where δ is arbitrary, not β) and extracts β₀ ∈ B, γ₀ ∈ C with ¬U(γ₀, β₀∧δ) ∉ A. 

In our code, we're trying to prove the seed `burgess_D0_seed A B C β` is consistent, where β is a specific formula with β.neg ∈ B. The δ in Burgess's proof is our β. The maximality of B gives: since β ∉ B, there exist β₀ ∈ B, γ₀ ∈ C with ¬untl(γ₀, β₀∧β) ∈ A (after convention swap). But wait — in our convention, untl(xi, eta) = U(eta, xi). So Burgess's ¬U(γ₀, β₀∧δ) becomes ¬untl(β₀∧δ, γ₀) in our notation.

The maximality clause gives: ∀ D, ClosedUnderDerivation D → B ⊂ D → ¬burgessR3(A, D, C). With D = DC({β}∪B) = Set.univ (since {β}∪B is inconsistent). So ¬burgessR3(A, Set.univ, C). Unfolding: ∃ δ' ∈ Set.univ, ∃ γ ∈ C, untl(δ', γ) ∉ A, or the Since variant.

The problem is that this gives us SOME neg-until in A, but not necessarily one involving elements of B. The proof needs:
- β₀ ∈ B, γ₀ ∈ C, ¬untl(β₀∧β, γ₀) ∈ A (in our convention)

Can we get this from ¬burgessR3(A, Set.univ, C)? Yes, because ¬burgessRSet(A, Set.univ, C) gives ∃ δ' ∈ Set.univ, ∃ γ₀ ∈ C, untl(δ', γ₀) ∉ A. Then untl(β₀∧β, γ₀) ∉ A by the anti-monotonicity argument: if untl(β₀∧β, γ₀) ∈ A, then by left_mono (since ⊢ δ' → β₀∧β would be needed but NOT available in general)... 

Wait, left_mono goes the WRONG way. A1a (our BX1): G(p→q) → (U(p,r)→U(q,r)). In our convention: untl(q, r) means U(r, q). So G(p→q) → untl(q, r) → untl(p, r)... no, U(p,r)→U(q,r) means untl(r,p)→untl(r,q). So left_mono for untl is: if ⊢ p→q then untl(p,_) ∈ A → untl(q,_) ∈ A. That's BX2. And BX1: if ⊢ p→q then untl(_,p) ∈ A → untl(_,q) ∈ A.

So from untl(δ', γ₀) ∉ A and A is MCS: ¬untl(δ', γ₀) ∈ A. We need ¬untl(β₀∧β, γ₀) ∈ A for some β₀ ∈ B. If we had ⊢ (β₀∧β) → δ', we could use BX1 contrapositive: untl(δ', γ₀) → untl(β₀∧β, γ₀), so ¬untl(β₀∧β, γ₀) → ¬untl(δ', γ₀). But we have it the other way: ¬untl(δ', γ₀) ∈ A. We'd need ⊢ δ' → (β₀∧β) to get ¬untl(β₀∧β, γ₀) from ¬untl(δ', γ₀).

But we DON'T have such an implication in general. So this approach doesn't directly work.

**The real fix**: The maximality clause should be used MORE DIRECTLY. Instead of going through Set.univ, use the maximality over ClosedUnderDerivation directly. When β ∉ B:
- Let D = DC(B ∪ {β}). D is ClosedUnderDerivation (always).
- If D is consistent, then D is a DCS, B ⊂ D (since β ∈ D \ B), and D is ClosedUnderDerivation. By maximality: ¬burgessR3(A, D, C).
- If D is inconsistent, then D = Set.univ. By maximality: ¬burgessR3(A, Set.univ, C).

In BOTH cases we get ¬burgessR3(A, D, C) for some ClosedUnderDerivation D with B ⊂ D and β ∈ D.

Now unfolding ¬burgessR3(A, D, C): ∃ δ' ∈ D, ∃ γ₀ ∈ C, untl(δ', γ₀) ∉ A. Since β ∈ D and B ⊆ D, we have β₀∧β ∈ D for any β₀ ∈ B (D is closed under conjunction since it's deductively closed). So β₀∧β ∈ D. But the witness δ' might not equal β₀∧β.

Hmm, but since D is deductively closed and β₀, β ∈ D, we have β₀∧β ∈ D. And δ' ∈ D. So β₀∧β∧δ' ∈ D. We have ¬untl(δ', γ₀) ∈ A. By left_mono contrapositive (BX1 direction): since ⊢ (β₀∧β∧δ') → δ', we get untl(δ', γ₀) → untl(β₀∧β∧δ', γ₀), hence ¬untl(β₀∧β∧δ', γ₀) → ¬untl(δ', γ₀). But we NEED the direction: ¬untl(δ', γ₀) → ¬untl(β₀∧β∧δ', γ₀)? No — we need ¬untl(β₀∧δ, γ₀) where δ is something containing β.

Actually rethinking: Burgess's proof says "since δ ∉ B, there exist β₀ ∈ B, γ₀ ∈ C with ¬U(γ₀, β₀∧δ) ∈ A." Looking at the maximality definition again: R(A,B,C) means ∀ δ ∉ B, ∃ β ∈ B, ∃ γ ∈ C, U(γ, β∧δ) ∉ A. This is DIFFERENT from our current definition which uses `ClosedUnderDerivation D → B ⊂ D → ¬burgessR3(A, D, C)`.

The Burgess maximality is: B is maximal among DCSs D with r(A,D,C). Equivalently: for any δ ∉ B, r(A, β∧δ, C) fails for some β ∈ B. This means ∃ γ ∈ C, U(γ, β∧δ) ∉ A.

Our Lean definition captures this at the SET level: any proper extension D with ClosedUnderDerivation D has ¬burgessR3(A, D, C). To extract the ELEMENT-LEVEL witness (∃ β₀ ∈ B, ∃ γ₀ ∈ C, ¬untl(β₀∧δ, γ₀) ∈ A), we need to go through D = DC(B ∪ {δ}):

1. D is ClosedUnderDerivation (always)
2. B ⊂ D (since δ ∈ D \ B)
3. ¬burgessR3(A, D, C) by maximality
4. So ∃ φ ∈ D, ∃ γ₀ ∈ C, untl(φ, γ₀) ∉ A
5. Since φ ∈ D = DC(B ∪ {δ}), there exist β₁,...,βₖ ∈ B such that ⊢ (β₁∧...∧βₖ∧δ) → φ
6. Let β₀ = β₁∧...∧βₖ ∈ B (B closed under conjunction as DCS)
7. Then ⊢ (β₀∧δ) → φ
8. By left_mono (BX1 direction, CONTRAPOSITIVE): untl(φ, γ₀) → untl(β₀∧δ, γ₀), so ¬untl(β₀∧δ, γ₀) → ¬untl(φ, γ₀)

Wait, I need to check the direction. BX1 says G(p→q) → (U(p,r) → U(q,r)). In our convention untl(xi,eta) = U(eta,xi), this is: G(p→q) → untl(r,p) → untl(r,q). So if ⊢ p→q, then untl(r,p) ∈ A → untl(r,q) ∈ A. The GUARD (first arg) stays the same, the EVENT (second arg) is monotone.

But we need monotonicity in the GUARD (first arg of untl). That's BX2: G(p→q) → (U(r,p) → U(r,q)). In our convention: G(p→q) → untl(p,r) → untl(q,r). So if ⊢ p→q, then untl(p,r) ∈ A → untl(q,r) ∈ A. Guard is monotone.

So from ⊢ (β₀∧δ) → φ (step 7): untl(β₀∧δ, γ₀) ∈ A → untl(φ, γ₀) ∈ A. Contrapositive: untl(φ, γ₀) ∉ A → untl(β₀∧δ, γ₀) ∉ A. Since we have untl(φ, γ₀) ∉ A (step 4), we get untl(β₀∧δ, γ₀) ∉ A. Since A is MCS: ¬untl(β₀∧δ, γ₀) ∈ A. ✓

Wait, the direction of the implication is crucial. We have ⊢ (β₀∧δ) → φ. BX2 gives untl(β₀∧δ, γ₀) → untl(φ, γ₀). So if untl(β₀∧δ, γ₀) ∈ A then untl(φ, γ₀) ∈ A. Contrapositive: if untl(φ, γ₀) ∉ A then untl(β₀∧δ, γ₀) ∉ A. YES, this is the right direction! ✓

So the extraction is:
1. β ∉ B
2. DC(B ∪ {β}) is ClosedUnderDerivation, B ⊂ DC(B ∪ {β})
3. ¬burgessR3(A, DC(B ∪ {β}), C)
4. ∃ φ ∈ DC(B ∪ {β}), ∃ γ₀ ∈ C, untl(φ, γ₀) ∉ A [or Since variant]
5. φ ∈ DC(B ∪ {β}) → ∃ β₀ ∈ B, ⊢ (β₀∧β) → φ
6. By BX2 contrapositive: untl(β₀∧β, γ₀) ∉ A
7. Since A is MCS: (untl(β₀∧β, γ₀)).neg ∈ A ✓

This exactly gives the Burgess witness! The key helper needed is step 5: extracting a conjunction of B-elements from DC(B ∪ {β}).

**This works regardless of whether B is MCS or not.** The case split on `SetMaximalConsistent B` is unnecessary.

### Recommended Approach
1. Remove the case split on `SetMaximalConsistent B`
2. Use the maximality clause directly: β ∉ B → DC(B ∪ {β}) is a proper ClosedUnderDerivation extension → ¬burgessR3(A, DC(B∪{β}), C)
3. Extract element-level witness and use BX2 contrapositive to get ¬untl(β₀∧β, γ₀) ∈ A
4. This gives the neg-until witness needed for `burgess_D0_seed` consistency

### Key Lean Helpers Needed
- `deductiveClosure_elem_witness`: φ ∈ DC(B ∪ {β}) → ∃ β₀ (conjunction of B-elements), ⊢ (β₀ ∧ β) → φ
- Or use the existing `deductiveClosure` infrastructure with List-based hypotheses

### Confidence: HIGH
This is a direct transcription of Burgess. The current case split is an artifact of the code, not of the math.

---

## Sorry Site #2: PointInsertion.lean:2744 — lemma_2_7_seed_consistent

### Burgess Reference
Lemma 2.7 (p. 372): Proves consistency of D₀ (called ζ) by showing each formula ζ = S(α, β∧η) ∧ β ∧ ξ ∧ U(γ, β) is consistent, where α ∈ A, β ∈ B, γ ∈ C. The argument uses:
1. η ∉ B (guard not in B), so ∃ β₀ ∈ B, γ₀ ∈ C with ¬U(γ₀, β₀∧η) ∈ A. WLOG β₀ = β, γ₀ = γ.
2. A5a on both U(γ,β) and U(ξ,η) to get self-accumulated versions
3. A7a (our BX7) three-way disjunction, eliminating two candidates
4. The survivor gives U(ξ, β∧η) ∈ A via A3a
5. By 2.2: ζ is consistent

### Current Lean State
The code has the seed definition at line 2697 and a `sorry` at line 2744. The docstring (lines 2702-2734) outlines the 12-step plan closely matching Burgess but with convention adjustments.

### Convention Analysis
Burgess: U(ξ,η) ∈ A, η ∉ B. Our code: untl(xi, eta) ∈ A, xi ∉ B.

Burgess convention: U(ξ,η) means "event ξ will occur while guard η holds." Our untl(xi,eta) = U(eta, xi) means "event eta will occur while guard xi holds." So:
- Burgess ξ = our eta (the event)
- Burgess η = our xi (the guard)
- Burgess condition η ∉ B = our xi ∉ B ✓

### Proof Strategy Following Burgess
1. From xi ∉ B + maximality, extract β₀ ∈ B, γ₀ ∈ C with ¬untl(β₀∧xi, γ₀) ∈ A (using the same extraction technique as Sorry #1)
2. WLOG β₀ = β, γ₀ = γ (by replacing β with β∧β₀ and γ with γ∧γ₀)
3. BX5 (A5a) on untl(xi, eta): untl(xi, eta∧untl(xi,eta)) ∈ A
4. BX5 on untl(β, γ): untl(β, γ∧untl(β,γ)) ∈ A
5. Wait — we need to be careful with the convention swap. In Burgess: U(γ,β) and U(ξ,η) become untl(β,γ) and untl(xi,eta). BX5 = A5a: U(p,q) → U(p, q∧U(p,q)). In our convention: untl(q,p) → untl(q∧untl(q,p), p). So BX5 gives untl(β∧untl(β,γ), γ) ∈ A and untl(xi∧untl(xi,eta), eta) ∈ A.

Actually wait, let me recheck. A5a: U(p,q) → U(p, q∧U(p,q)). untl(xi,eta) = U(eta,xi). So if untl(xi,eta) ∈ A, i.e., U(eta,xi) ∈ A, then A5a with p=eta, q=xi gives U(eta, xi∧U(eta,xi)) = untl(xi∧untl(xi,eta), eta). So we get untl(xi∧untl(xi,eta), eta) ∈ A. ✓

6. BX7 = A7a: U(p,q) ∧ U(r,s) → U(p∧r, q∧s) ∨ U(p∧s, q∧s) ∨ U(q∧r, q∧s).
   With p=eta from untl(β∧untl(β,γ), gamma), and r=eta from untl(xi∧untl(xi,eta), eta):
   
   Actually this is getting complex with the convention swap. The key point is that the Lean code's 12-step outline is essentially correct and matches Burgess. The proof is a long but mechanical axiom chain.

### Recommended Approach
Follow the 12-step outline in the docstring. The key difficulty is implementing the BX7 three-way disjunction and eliminating two candidates. Each step is a derivation tree + membership argument using existing `_mcs` wrappers.

### Confidence: MEDIUM-HIGH
The math is correct per Burgess. Implementation complexity is the risk — each step requires careful formula construction and derivation trees. Estimated 6-10 hours for this single sorry.

---

## Sorry Site #3: PointInsertion.lean:2875 — Lemma 2.7 Inconsistent Case

### Burgess Reference
Burgess's Lemma 2.7 has the condition η ∉ B (our xi ∉ B). The proof NEVER considers the case {η}∪B inconsistent separately — it proceeds uniformly using maximality. The consistency of {η}∪B is irrelevant to Burgess's argument because:
1. The seed D₀ is always the same regardless of consistency of {η}∪B
2. D₀ consistency follows from the A7a argument, which doesn't require {η}∪B to be consistent
3. The splitting into B', D, B'' via Zorn works for any seed

### Current Lean State
The code at line 2827 case-splits on `SetConsistent ({xi} ∪ B)`. In the consistent case, it builds DC({xi}) and extends via Zorn. In the inconsistent case, it hits sorry at line 2875.

### Root Cause
This case split is an artifact of the Lean implementation, not of Burgess. The code tries to build B' from DC({xi}) in the consistent case, but in the inconsistent case, DC({xi}∪B) = Set.univ, and the code can't proceed.

### Resolution Following Burgess
Burgess's proof doesn't build B' from DC({xi}). Instead:
1. Prove D₀ consistent (sorry #2 above)
2. Extend D₀ to MCS D
3. Extract that xi ∈ D (from the seed containing snce(β∧xi, α) for all α, β — the 5th seed component gives burgessRSince(D, xi, A), hence by Lemma 2.3 equivalence, burgessR(A, xi, D), hence untl(xi, δ) ∈ A for all δ ∈ D)

Wait, the issue is: Burgess needs η ∈ B' (our xi ∈ B'). How does Burgess get this?

Looking at Burgess 2.7 more carefully: "there exist B', D, B'' such that η ∈ B', ξ ∈ D." Burgess's construction: After getting D (MCS extending D₀), take B' maximal with B ⊆ B' and r(A, B', D). Since the seed contains S(α, β∧η) for all α ∈ A, β ∈ B, we get η ∈ B' because the maximality construction automatically includes η.

Actually: B' is maximal with B ⊆ B' and r(A, B', D). The seed guarantees S(α, β∧η) ∈ D for all α, β. By Lemma 2.3 direction (b)→(a): β∧η satisfies r(A, β∧η, D) for all β ∈ B. Since β ∈ B', we have β∧η is a consequence of B' ∪ {η}. For η ∈ B', we need to show that r(A, B' ∪ {η}, D) still holds... but that's what maximality gives us! If η ∉ B', then B' is not truly maximal since B' ∪ {η} also satisfies r.

Wait, not quite — B' must satisfy r as a DCS. The set DC(B' ∪ {η}) satisfies r(A, DC(B' ∪ {η}), D)? Yes, IF r(A, η, D) holds. And r(A, η, D) holds iff ∀ δ ∈ D, untl(η, δ) ∈ A. This is exactly what the seed's 5th component gives (through the chain: snce(β∧xi, α) ∈ D → burgessRSince → burgessR by Lemma 2.3 → untl(xi, δ) ∈ A).

So η ∈ B' follows from maximality of B'. The case split on consistency of {xi}∪B is unnecessary!

### Recommended Approach
**Remove the case split entirely.** After proving D₀ consistent and obtaining D:
1. Show r(A, xi, D) holds (from the 5th seed component and Lemma 2.3)
2. Build B' via Zorn from B, maximizing r(A, B', D) with the constraint B ⊆ B'
3. By maximality of B': xi ∈ B' (since r(A, xi, D) holds and B' ∪ DC({xi}) would be a valid extension if xi ∉ B')

The existing code at lines 2813-2822 already establishes `h_burgessR_xi : burgessR A xi D`, which is exactly r(A, xi, D). The problem is that it then tries to build DC({xi}) as a concrete DCS to feed into `burgessR3Maximal_extension_exists`, which requires consistency. Instead, it should build DC(B ∪ {xi}) (if consistent) or argue maximality differently.

**Simpler fix**: After establishing burgessR3(A, B, D) and burgessR(A, xi, D), use a modified Zorn that starts from B ∪ {xi} rather than DC({xi}). Since burgessR3 with B already holds and xi is compatible (r(A, xi, D) holds), the seed B ∪ {xi} is valid regardless of consistency. The `burgessR3Maximal_extension_exists` should accept any ClosedUnderDerivation seed S with B ⊆ S and burgessR3(A, S, D), not requiring consistency.

Actually, looking at the current Zorn function signature:
```lean
burgessR3Maximal_extension_exists h_mcs_A h_D_mcs h_dc_xi_dcs h_dc_xi_r3 h_no_univ
```
It requires `h_dc_xi_dcs : SetDeductivelyClosed (DC({xi}))` — this requires consistency! But Burgess's Zorn works with ClosedUnderDerivation sets (no consistency needed).

**The fix**: Modify `burgessR3Maximal_extension_exists` to accept `ClosedUnderDerivation S` instead of `SetDeductivelyClosed S`, or create a variant that starts from B and includes xi in the maximal extension.

### Confidence: HIGH
The mathematical argument is clear from Burgess. The implementation needs a Zorn variant that works without consistency.

---

## Sorry Site #4: CounterexampleElimination.lean:413 — C4 Hard Case (Until direction)

### Burgess Reference
Lemma 2.9 (p. 373), Case n = m+1: Let x' immediately succeed x in dom f. If ¬U(γ,δ) ∈ f(x'), reduce to n=m. If U(γ,δ) ∈ f(x'), then δ ∈ f(x') (else it wouldn't be a counterexample). Let γ' = δ ∧ U(γ,δ). Using A3a: ¬U(γ', δ) ∈ f(x), so reduce to n=0 by replacing γ with γ' and y with x'.

### Current Lean State
The code finds the rightmost w with ¬untl(γ,δ) ∈ f(w), then its successor w_next. At w_next, either:
- w_next = y: δ directly available
- w_next < y: untl(γ,δ) ∈ f(w_next) (since w was rightmost)

The "hard case" is γ ∈ f(x) AND γ ∈ f(y) with the comment "Need BurgessR3 bridging from c2'."

### Analysis
Looking at the sorry context more carefully: the code has found adjacent (w, w_next) with ¬untl(γ,δ) ∈ f(w). The C2' condition gives BurgessR3Maximal(f(w), g(w,w_next), f(w_next)). From this, one should be able to apply Lemma 2.6 to insert a point z with ¬δ ∈ f(z) between w and w_next (the n=0 case of Burgess 2.9).

But the code says "c2' is removed from omega_chain invariant per Phase 7." This means the c2' invariant was lost during refactoring!

### Resolution Following Burgess
Burgess's 2.9 proof (case n=m+1) does NOT use c2' directly. It uses a case analysis on f(x'):
1. If ¬U(γ,δ) ∈ f(x'): reduce to smaller n (replace x with x')
2. If U(γ,δ) ∈ f(x'): δ must be in f(x') (else not a counterexample), form γ' = δ∧U(γ,δ) ∈ f(x'), use A3a to get ¬U(γ',δ) ∈ f(x), then apply n=0 to the adjacent pair (x, x').

In case 2, the n=0 case uses R(f(x), g(x,x'), f(x')) to apply Lemma 2.6. This IS c2' — it requires BurgessR3Maximal for the adjacent pair.

So c2' IS needed. The resolution requires restoring c2' in the omega chain construction.

### Recommended Approach
1. Restore c2' to the EliminationResult structure and omega_chain invariant
2. Each elimination step must preserve c2' (this was "Phase 7" work that was deferred)
3. Once c2' is available, the C4 proof follows Burgess 2.9 exactly

### Confidence: HIGH
The math is straightforward from Burgess. The blocking issue is infrastructure (c2' threading).

---

## Sorry Site #5: CounterexampleElimination.lean:511 — C4' Hard Case (Since direction)

### Analysis
Exact mirror of Sorry #4, for the Since/C4b direction.

### Resolution
Same as Sorry #4 — restore c2' invariant, then the proof follows by mirroring 2.9.

### Confidence: HIGH

---

## Sorry Site #6: ChronicleToCountermodel.lean:621 — Forward Until Coherence (FUC)

### Burgess Reference
Claim 2.11 (p. 374): The truth lemma. For U(β,γ): if U(β,γ) ∈ f(x), then by C5a there exists y > x with γ ∈ f(y) and β ∈ g(x,y). For any z with x < z < y, C3 gives g(x,y) ⊆ f(z), hence β ∈ f(z).

### Current Lean State
`limit_satisfies_c5_weak` gives ∃ y > x with η ∈ f(y) (the endpoint witness). The GUARD at intermediate points (ξ ∈ f(z) for x < z < y) requires g(x,y) and C3, which exist at the limit level:
- `limit_g` is defined (line 845)
- `limit_c3` is proved (line 861)
- `limit_c3_interval_subset_point` gives g(x,z) ⊆ f(y) (line 887)

The blocker is connecting `limit_satisfies_c5_weak` with `limit_g`. The C5_weak version only gives the ENDPOINT witness (η ∈ f(y)). The FULL C5 requires ξ ∈ g(x,y), meaning ξ ∈ f(z) for ALL z between x and y in the limit domain.

### Root Cause
The omega chain's C5 elimination (Lemma 2.10 / `eliminate_C5_counterexample`) only guarantees η ∈ f'(y) (the event at the new point), NOT ξ ∈ g(x,y). Looking at `eliminate_C5_counterexample` (line 167): it uses `lemma_2_4` to get C (MCS with η ∈ C) and B (interval DCS), but the **g function is unchanged** (`fun _ _ => rfl`). The new point y gets f(y) = C, but g is not updated to include B as g(x,y).

This is a FUNDAMENTAL architectural gap. In Burgess's construction, when a point y is added for C5, the g function IS extended: g'(x,y) = B. But in the current code, g is not modified.

### Resolution Following Burgess
The C5 elimination must also set g'(x,y) = B (the DCS from Lemma 2.4) and extend g to other pairs via C3: g'(w,y) = g(w,x) ∩ f(x) ∩ g'(x,y) for w < x, and similarly for y < w.

However, at the LIMIT level, `limit_g` is defined as {φ | ∀ z ∈ limit_dom, x < z < y → φ ∈ limit_f(z)}, which automatically includes the correct information. The question is whether limit_g + C5_weak is ENOUGH.

Claim: `limit_g(x,y)` already contains ξ when untl(ξ,η) ∈ f(x) and the C5 elimination created y with η ∈ f(y):

For any z in limit_dom with x < z < y_witness: if z was added BEFORE y_witness, then at the stage when y_witness was added, z was already in the domain. The C5 elimination adds y with f(y) = C where C extends the seed from Lemma 2.4. The guard ξ is in g(x,y) = B (from Lemma 2.4), and C3 gives g(x,y) ⊆ f(z) for x < z < y... but only in the stage where this is tracked.

Actually, the limit_g definition captures exactly this: ξ ∈ limit_g(x, y_witness) iff ξ ∈ limit_f(z) for ALL z in limit_dom between x and y_witness. We need to show this from the construction.

The key insight: when C5 counterexample (x, ξ, η) is eliminated at stage n, the new point y_n gets f(y_n) = C (MCS with η ∈ C and g_content(f(x)) ⊆ C). At later stages, if a point z is added between x and y_n, the elimination procedures (2.6 or 2.7) use R(f(x), g(x,y_n), f(y_n)) and insert D with g(x,z) ⊆ f(z). Since ξ ∈ g(x,y_n) = B (from Lemma 2.4), and C3 gives g(x,y_n) ⊆ g(x,z) ∩ f(z) ∩ g(z,y_n)... hmm, that's the wrong direction. C3: g(x,y_n) = g(x,z) ∩ f(z) ∩ g(z,y_n), so g(x,y_n) ⊆ f(z). So ξ ∈ f(z). ✓

But this requires c2' at each intermediate stage! And c2' is currently not tracked properly (see sorry #4). Once c2' is restored and C3 is established at finite stages, the argument follows.

### Recommended Approach
1. First resolve sorry #4/#5 (restore c2' invariant)
2. Establish C3 at finite stages (using c2' + C3 identity)
3. Strengthen C5 elimination to also set g(x,y) properly
4. At the limit: use limit_g definition + C3 + c5_weak to prove full C5

Actually, there may be a SIMPLER path. Since limit_g is DEFINED as {φ | ∀ z between x and y_witness, φ ∈ limit_f(z)}, and limit_satisfies_c5_weak gives the endpoint y, we need to show ξ ∈ limit_g(x, y), i.e., ξ ∈ limit_f(z) for ALL z between x and y.

The question is: does the construction ensure ξ ∈ f(z) for all intermediate z? This follows from the fact that every point z added between x and y inherits formulas from g(x,y) via C3 at finite stages. But this requires tracking g at finite stages properly, which circles back to c2'.

### Confidence: MEDIUM
The math is clear from Burgess, but the implementation requires significant infrastructure work (c2' restoration, finite-stage C3, full C5 with guard).

---

## Sorry Site #7: ChronicleToCountermodel.lean:625 — Forward Since Coherence (FSC)

### Analysis
Exact mirror of Sorry #6, for the Since/S direction.

### Confidence: MEDIUM (same as #6)

---

## Sorry Site #8: Completeness.lean:152 — NoUnivBurgessR3

### Burgess Reference
This condition is IMPLICIT in Burgess. Burgess defines R-maximality as: B is maximal among DCSs with r(A,B,C). Since DCSs are consistent by definition in Burgess, Set.univ (which is inconsistent) never enters the picture. However, our formalization separates `ClosedUnderDerivation` (no consistency) from `SetDeductivelyClosed` (requires consistency), creating this gap.

### Current Lean State
```lean
def NoUnivBurgessR3 : Prop :=
  ∀ A C : Set Formula, SetMaximalConsistent A → SetMaximalConsistent C →
    ¬burgessR3 A Set.univ C
```

The claim: burgessR3(A, Set.univ, C) is false for all MCS A, C. burgessR3 requires:
1. burgessRSet(A, Set.univ, C): ∀ β ∈ Set.univ, ∀ γ ∈ C, untl(β, γ) ∈ A
2. burgessRSetSince(C, Set.univ, A): ∀ β ∈ Set.univ, ∀ α ∈ A, snce(β, α) ∈ C

Condition 1 requires untl(β, γ) ∈ A for ALL formulas β. In particular, β = ⊥. So untl(⊥, γ) ∈ A for all γ ∈ C. But untl(⊥, γ) = U(γ, ⊥) in Burgess. By Lemma 2.2 (consistency criterion): U(γ, ⊥) ∈ A implies γ is consistent. But γ ∈ C and C is MCS, so γ might be consistent. Actually, this doesn't give a contradiction.

Wait — untl(⊥, γ) ∈ A means U(γ, ⊥) ∈ A. By the semantics: U(γ,⊥) means "there exists y > x with ⊥ ∈ f(y) and γ true up to y." But ⊥ is never true. So semantically U(γ,⊥) = ⊥. By soundness, ¬U(γ,⊥) is a thesis. Hence U(γ,⊥) ∉ A for any MCS A.

Wait, is this derivable? We need ⊢ ¬U(γ,⊥). From ⊢ ¬⊥ (tautology) and TG: ⊢ G(¬⊥). Then ⊢ G(¬⊥) → (U(⊥,⊤) → U(⊥,⊤)) is trivial but not helpful. We need to show ⊢ ¬U(γ,⊥).

By 2.2: if U(γ,δ) ∈ A then γ is consistent. With δ = ⊤: U(γ,⊤) ∈ A → γ consistent. But we need the general case. 

Actually, re-examining: untl(⊥, γ) = U(γ, ⊥) in our convention (untl(xi,eta) = U(eta,xi), so xi=⊥, eta=γ). So U(γ, ⊥) ∈ A. Lemma 2.2 says: if U(γ, δ) ∈ A then γ is consistent. Here γ is the first argument of U. So U(γ, ⊥) ∈ A → γ is consistent. This doesn't help since γ could be consistent.

Let me try differently. U(γ, ⊥) means "there exists a future time where ⊥ is true and γ holds at all intermediate times." But ⊥ is never true, so this is false. The derivation: ¬⊥ is a tautology. G(¬⊥) by TG. ¬F(⊥) follows (since F(⊥) = ¬G(¬⊥)). And U(γ,⊥) → F(⊥) by A2a with q=⊤: G(⊥→⊤) → (U(γ,⊥) → U(γ,⊤)) = (U(γ,⊥) → F(γ)). Hmm, that doesn't give F(⊥).

Actually: U(γ, ⊥) → F(γ) (since if there's a future time where ⊥ is true and γ holds at intermediate times, then γ is eventually true... no that's not right either).

Let me think about which of our axioms gives this. F(α) = U(α, ⊤). So U(γ, ⊥) ... hmm. Let me check: does ⊢ ¬U(⊥, γ)? (This is untl(γ, ⊥) in our convention.)

U(⊥, γ) means there exists a future time where γ is true and ⊥ holds at all intermediate times. If the order is dense, there are always intermediate points, so ⊥ must hold somewhere, which is impossible. But for discrete orders, there could be an immediate successor with γ, and no intermediate points for ⊥ to hold at. So U(⊥, γ) could be satisfiable on discrete orders! And J₀ is complete for ALL linear orders.

So ¬U(⊥, γ) is NOT a thesis of J₀! This means NoUnivBurgessR3 is NOT derivable from the axioms alone.

But wait: the condition in the code says burgessRSet(A, Set.univ, C) requires untl(β, γ) ∈ A for ALL β, including β = ⊥. untl(⊥, γ) = U(γ, ⊥). This requires F(γ) with ⊥ guard... 

Actually, let me reconsider. The semantic meaning of U(γ, ⊥) (untl(⊥, γ)): "there exists y > x with γ ∈ V(y) and ⊥ ∈ V(z) for all x < z < y." If x has an immediate successor y, then there are no z with x < z < y, so the guard condition is vacuously true, and we just need γ ∈ V(y). So U(γ, ⊥) is equivalent to "there exists an immediate successor with γ" — NOT valid in general but satisfiable.

Hmm but we need untl(⊥, γ) ∈ A for ALL γ ∈ C. That means U(γ, ⊥) ∈ A for all γ ∈ C. For ANY MCS A, this requires A to contain U(γ, ⊥) for every formula γ that's in C. This is extremely strong.

Consider: if U(¬γ, ⊥) ∈ A and U(γ, ⊥) ∈ A, then by BX7 (A7a): U(¬γ∧γ, ⊥∧⊥) ∨ ... This gives U(⊥, ⊥) ∈ A (since ¬γ∧γ = ⊥). And U(⊥, ⊥) means "⊥ will occur with ⊥ guard" which implies F(⊥). But F(⊥) is inconsistent (since ¬⊥ is a tautology, G(¬⊥) follows by TG, and ¬F(⊥) follows). So U(⊥, ⊥) ∉ A for MCS A. This means we can't have BOTH U(γ, ⊥) and U(¬γ, ⊥) in A. But C is MCS, so one of γ, ¬γ is in C. So burgessRSet(A, Set.univ, C) requires U(γ, ⊥) ∈ A AND U(¬γ, ⊥) ∈ A for the same γ... and BOTH are required since both γ and... wait, C is MCS so only ONE of γ, ¬γ is in C. So only one of U(γ, ⊥) or U(¬γ, ⊥) is required.

Let me try another approach. If burgessRSet(A, Set.univ, C), then ∀ β, ∀ γ ∈ C, untl(β, γ) ∈ A. With β = ⊥: ∀ γ ∈ C, untl(⊥, γ) = U(γ, ⊥) ∈ A. With γ = ⊤ ∈ C: U(⊤, ⊥) ∈ A. But U(⊤, ⊥) means "there exists a future point y with ⊤ at y and ⊥ at all intermediate points." For dense orders, this is impossible (there's always an intermediate point where ⊥ fails). But for orders with an immediate successor, this just means "there's a next point" (⊤ is always true at the successor, no intermediate points to check).

Can we DERIVE ¬U(⊤, ⊥)? U(⊤, ⊥) is untl(⊥, ⊤) in our convention. And untl(⊥, ⊤) = F(⊤) (since F(α) = untl(⊤, α)... wait, F(α) = U(α, ⊤) = untl(⊤, α). So F(⊤) = untl(⊤, ⊤). That's different from untl(⊥, ⊤) = U(⊤, ⊥).

Hmm, U(⊤, ⊥) is NOT F(⊤). It's "there exists a future point with ⊤ (trivially) and ⊥ holds at all intermediate points." This is NOT provably false in J₀ (satisfiable on orders with an immediate successor).

### Alternative Approach: Use the Since direction
For burgessRSetSince(C, Set.univ, A), we need: ∀ β, ∀ α ∈ A, snce(β, α) ∈ C. With β = ⊥: ∀ α ∈ A, snce(⊥, α) ∈ C. snce(⊥, α) = S(α, ⊥) in Burgess. By the mirror of 2.2: S(α, ⊥) ∈ C → α is consistent. But α ∈ A and A is MCS, so α is consistent. This doesn't help.

### The Real Issue
I now believe NoUnivBurgessR3 is **NOT provable** from J₀ axioms alone. The comment in ChronicleTypes.lean (line 344-346) confirms this:

> "This condition is NOT derivable from J₀ axioms alone (since J₀ is also complete for discrete orders where untl(⊥, gamma) can hold vacuously). It is a property specific to the dense-order chronicle construction."

The condition is a property of the CONSTRUCTION, not a theorem. It holds because the chronicle is built over a dense domain (the rationals), where every adjacent pair eventually gets a point inserted between them. In the limit, there are no adjacent pairs, so g(x,y) = {φ | ∀ z between, φ ∈ f(z)}, and ⊥ ∉ g(x,y) for any non-degenerate interval.

### Resolution
NoUnivBurgessR3 should be PROVED from the properties of the limit construction, not postulated. Specifically:

1. In the limit, limit_dom is dense (proved: `limit_dom_dense`)
2. For any MCS A, C and any γ ∈ C: untl(⊥, γ) ∈ A implies (unfolding): there exists y > x in limit_dom with γ ∈ limit_f(y) and ⊥ ∈ limit_f(z) for all z between. But limit_dom is dense, so there exists z between, and ⊥ ∉ limit_f(z) (since limit_f(z) is MCS). Contradiction.

Wait, but NoUnivBurgessR3 is a statement about ALL MCS A, C, not about the limit construction. It says burgessR3(A, Set.univ, C) is false for arbitrary MCS pairs. This IS used as a hypothesis throughout the construction.

The question is: can burgessR3(A, Set.univ, C) ever hold for ANY pair of MCS A, C?

burgessR3(A, Set.univ, C) = burgessRSet(A, Set.univ, C) ∧ burgessRSetSince(C, Set.univ, A)

burgessRSet(A, Set.univ, C) = ∀ β, ∀ γ ∈ C, untl(β, γ) ∈ A

Taking β = ⊥: ∀ γ ∈ C, untl(⊥, γ) ∈ A. But untl(⊥, γ) = U(γ, ⊥). 

Now: U(γ, ⊥) → F(⊥∨γ)? No. By A1a with p→q being ⊥→(⊥∨γ): G(⊥→(⊥∨γ)) → U(⊥, r) → U(⊥∨γ, r). Doesn't help.

Let me use A2a: G(p→q) → U(r,p) → U(r,q). With p=⊥, q=anything: G(⊥→q) is a thesis (ex falso). So G(⊥→⊥) → U(γ, ⊥) → U(γ, ⊥). Trivial.

How about: U(γ₁, ⊥) ∧ U(γ₂, ⊥). By A7a: U(γ₁∧γ₂, ⊥∧⊥) ∨ U(γ₁∧⊥, ⊥∧⊥) ∨ U(⊥∧γ₂, ⊥∧⊥). 
⊥∧⊥ = ⊥. γ₁∧⊥ = ⊥. So: U(γ₁∧γ₂, ⊥) ∨ U(⊥, ⊥) ∨ U(⊥, ⊥).

Now, is U(⊥, ⊥) consistent? U(⊥, ⊥) → F(⊥) (since if there's a point where ⊥ holds, then F(⊥)). Actually: can we derive U(⊥, ⊥) → F(⊥)? F(⊥) = U(⊥, ⊤). By A2a: G(⊥→⊤) → U(⊥, ⊥) → U(⊥, ⊤). G(⊥→⊤) is a thesis. So yes: ⊢ U(⊥, ⊥) → F(⊥).

And ⊢ ¬F(⊥) is a thesis: ⊢ ¬⊥ (tautology), ⊢ G(¬⊥) by TG, ⊢ ¬F(⊥) by definition.

So ⊢ ¬U(⊥, ⊥). In our convention: ⊢ ¬untl(⊥, ⊥).

Now from U(γ₁, ⊥) ∧ U(γ₂, ⊥): A7a gives U(γ₁∧γ₂, ⊥) ∨ U(⊥, ⊥) ∨ U(⊥, ⊥). Since U(⊥,⊥) is refutable, the disjunction reduces to U(γ₁∧γ₂, ⊥).

By induction: if U(γ₁, ⊥), ..., U(γₙ, ⊥) ∈ A, then U(γ₁∧...∧γₙ, ⊥) ∈ A.

Now let γ₁ = p and γ₂ = ¬p (where p is any propositional variable). Then U(p, ⊥), U(¬p, ⊥) ∈ A (both p, ¬p ∈ C since C is MCS). By the above: U(p∧¬p, ⊥) = U(⊥, ⊥) ∈ A. Contradiction with ¬U(⊥, ⊥)!

Wait — we need BOTH p ∈ C and ¬p ∈ C, but C is MCS so exactly ONE of p, ¬p is in C. So we can't get both U(p, ⊥) and U(¬p, ⊥) from burgessRSet(A, Set.univ, C).

Let me try another angle. We need U(γ, ⊥) for all γ ∈ C. Pick any formula φ. Either φ ∈ C or ¬φ ∈ C. 

Take γ₁ ∈ C and γ₂ = ¬γ₁. If ¬γ₁ ∈ C, then γ₁ ∉ C (C is MCS). But we only need U(γ, ⊥) for γ ∈ C. So U(¬γ₁, ⊥) might not be required.

Hmm, but Set.univ contains ⊥. So burgessRSet requires untl(⊥, γ) ∈ A for all γ ∈ C. That is U(γ, ⊥) ∈ A. And burgessRSetSince requires snce(⊥, α) ∈ C for all α ∈ A. That is S(α, ⊥) ∈ C.

Similarly, Set.univ contains ⊤ → ⊥ = ¬⊤. So burgessRSet requires untl(¬⊤, γ) = untl(⊥, γ) ∈ A (same as above since ¬⊤ = ⊥).

Now, the Since direction: ∀ β ∈ Set.univ, ∀ α ∈ A, snce(β, α) ∈ C. With β = ⊤: ∀ α ∈ A, snce(⊤, α) = S(α, ⊤) = P(α) ∈ C. So P(α) ∈ C for ALL α ∈ A. This means H(α) ∉ C for any α ∉ A. Since C is MCS: ¬H(α) ∈ C iff H(α) ∉ C. And ¬H(α) = P(¬α). So P(¬α) ∈ C iff α ∉ A.

Also from the Until direction: ∀ γ ∈ C, untl(⊤, γ) = U(γ, ⊤) = F(γ) ∈ A. So F(γ) ∈ A for all γ ∈ C. This means G(¬γ) ∉ A for any γ ∈ C. Since A is MCS: ¬G(¬γ) = F(γ) ∈ A ✓ (consistent).

From both: F(γ) ∈ A for all γ ∈ C, and P(α) ∈ C for all α ∈ A.

Now take β = ⊥ in the Since direction: S(α, ⊥) ∈ C for all α ∈ A. By the mirror of 2.2: S(α, ⊥) ∈ C → α is consistent. OK, α ∈ A so α is consistent. No contradiction.

Can we get something from the Until direction with β = ⊥? U(γ, ⊥) ∈ A for all γ ∈ C. By 2.2: U(γ, δ) ∈ A → γ is consistent. With δ=⊥: U(γ, ⊥) ∈ A → γ is consistent ✓ (since γ ∈ C, MCS).

Hmm, this is harder than I thought. Let me try two SPECIFIC γ ∈ C that are contradictory within A.

Take γ ∈ C arbitrary. U(γ, ⊥) ∈ A. By A5a: U(γ, ⊥∧U(γ,⊥)) = U(γ, U(γ,⊥)) ∈ A (since ⊥∧U(γ,⊥) = U(γ,⊥) is wrong; ⊥∧anything = ⊥; so U(γ, ⊥) ∈ A).

Actually A5a: U(p,q) → U(p, q∧U(p,q)). With p=γ, q=⊥: U(γ, ⊥) → U(γ, ⊥∧U(γ,⊥)) = U(γ, ⊥). Trivial.

Try A4a: U(p,q) ∧ ¬U(p,r) → U(q∧¬r, q). With p=γ, q=⊥: U(γ,⊥) ∧ ¬U(γ,r) → U(⊥∧¬r, ⊥) = U(⊥, ⊥) for any r with ¬U(γ,r) ∈ A.

If ¬U(γ,r) ∈ A for some r, then U(γ,⊥) ∧ ¬U(γ,r) → U(⊥,⊥) ∈ A. But ¬U(⊥,⊥) is a thesis. So U(γ,⊥) ∧ ¬U(γ,r) → ⊥. Hence U(γ,⊥) → U(γ,r) for all r! So if U(γ,⊥) ∈ A then U(γ,r) ∈ A for all r.

In particular: U(γ, ⊤) = F(γ) ∈ A, and U(γ, ¬γ) ∈ A, and U(γ, p) ∈ A for any p.

Now take two formulas γ₁, γ₂ ∈ C. We have U(γ₁, ⊥) and U(γ₂, ⊥) ∈ A. By the above: U(γ₁, r) ∈ A for all r, and U(γ₂, r) ∈ A for all r. In particular U(γ₁, ¬γ₁) ∈ A.

But does U(γ₁, ¬γ₁) lead to a contradiction? Semantically: "there exists y > x with γ₁ at y and ¬γ₁ at all intermediate points." This is satisfiable (e.g., on a 2-point order x < y with γ₁ at y and no intermediate points). So no syntactic contradiction.

Let me try yet another approach. Since U(γ, ⊥) ∈ A → U(γ, r) ∈ A for all r (proved above), we get U(γ, s) ∈ A for ALL formulas s, for each γ ∈ C. 

In particular: U(γ, ¬γ) ∈ A for each γ ∈ C.

Now use A3a: α ∧ U(γ, ¬γ) → U(γ ∧ S(α, ¬γ), ¬γ). With α ∈ A: since U(γ, ¬γ) ∈ A, we get U(γ ∧ S(α, ¬γ), ¬γ) ∈ A.

From the Since direction: S(α, ⊥) ∈ C for all α ∈ A. Similarly to the Until argument: S(α, ⊥) ∈ C → S(α, r) ∈ C for all r (by A4b analog). So S(α, ¬γ) ∈ C for all α ∈ A, γ.

If γ ∧ S(α, ¬γ) ∈ C... then U(γ∧S(α,¬γ), ¬γ) ∈ A implies γ∧S(α,¬γ) is consistent (by 2.2). Since C is MCS, γ∧S(α,¬γ) ∈ C iff both γ ∈ C and S(α,¬γ) ∈ C. We have both ✓. So γ∧S(α,¬γ) ∈ C. And U(γ∧S(α,¬γ), ¬γ) ∈ A.

Now A6a: U(q∧U(p,q), q) → U(p,q). With p=γ∧S(α,¬γ), q=¬γ: U(¬γ∧U(γ∧S(α,¬γ), ¬γ), ¬γ) → U(γ∧S(α,¬γ), ¬γ). But we already have U(γ∧S(α,¬γ), ¬γ) ∈ A, so this doesn't help.

This is getting complex. Let me try the simplest possible approach:

Key claim: ⊢ ¬(U(⊥, ⊥)). This is true (shown above: U(⊥,⊥) → F(⊥), and ¬F(⊥) is provable).

From U(γ, ⊥) ∈ A, we showed U(γ, r) ∈ A for all r. Take r = γ: U(γ, γ) ∈ A.

Now with U(γ₁, γ₁) and U(γ₂, γ₂) ∈ A (for γ₁, γ₂ ∈ C), apply A7a: 
U(γ₁, γ₁) ∧ U(γ₂, γ₂) → U(γ₁∧γ₂, γ₁∧γ₂) ∨ U(γ₁∧γ₂, γ₁∧γ₂) ∨ U(γ₁∧γ₂, γ₁∧γ₂). 

This just gives U(γ₁∧γ₂, γ₁∧γ₂) ∈ A. If γ₁ ∈ C and γ₂ ∈ C, then γ₁∧γ₂ ∈ C. So we get U(δ, δ) ∈ A for all δ ∈ C (by closure of C under conjunction).

Now for any δ ∈ C: U(δ, δ) ∈ A. And from the Until direction with β = ¬δ: U(δ, ⊥) ∈ A since δ ∈ C. Wait, we already used β = ⊥. Let me try β = ¬δ ∈ Set.univ: untl(¬δ, γ) ∈ A = U(γ, ¬δ) ∈ A for all γ ∈ C. With γ = δ: U(δ, ¬δ) ∈ A.

A7a with U(δ, δ) and U(δ, ¬δ): 
U(δ∧δ, δ∧¬δ) ∨ U(δ∧¬δ, δ∧¬δ) ∨ U(δ∧δ, δ∧¬δ).
= U(δ, ⊥) ∨ U(⊥, ⊥) ∨ U(δ, ⊥).
Since ¬U(⊥,⊥) is provable: U(δ, ⊥) ∈ A. (Which we already know.)

I'm going in circles. Let me try the SYMMETRIC version — combining Until and Since:

From Until direction: U(γ, ⊥) ∈ A for all γ ∈ C → U(γ, r) ∈ A for all γ ∈ C, r.

In particular: U(γ, γ) ∈ A for all γ ∈ C.

From Since direction: S(α, ⊥) ∈ C for all α ∈ A → S(α, r) ∈ C for all α ∈ A, r.

In particular: S(α, α) ∈ C for all α ∈ A.

Take γ ∈ C, α ∈ A. We have U(γ, γ) ∈ A and S(α, α) ∈ C.

A3a: α ∧ U(γ, γ) → U(γ ∧ S(α, γ), γ). Since α ∈ A and U(γ,γ) ∈ A: U(γ∧S(α,γ), γ) ∈ A.

Now S(α, γ) ∈ C (from the Since direction with r=γ). And γ ∈ C. So γ∧S(α,γ) ∈ C.

Continuing... I'm not finding a contradiction from J₀ alone. The key issue is:

**NoUnivBurgessR3 may genuinely require a separate argument.** 

After more thought, I believe the correct approach is:

The property CAN be proved using the COMBINED structure. Since U(γ, ⊥) ∈ A for all γ ∈ C means U(γ, r) ∈ A for all r (via A4a contrapositive), taking r = ¬γ: U(γ, ¬γ) ∈ A. And also U(¬γ', r) ∈ A for all r (using β=¬γ' ∈ Set.univ from burgessRSet, with γ' ∈ C). Wait, we need ¬γ' = β ∈ Set.univ and some γ'' ∈ C: untl(¬γ', γ'') = U(γ'', ¬γ') ∈ A.

From "U(γ, ⊥) ∈ A → U(γ, r) ∈ A for all r": this gives U(γ, ⊥) ∈ A → U(γ, s) ∈ A for any s.

Now take γ ∈ C. U(γ, ⊥) ∈ A. So U(γ, s) ∈ A for all s. In particular U(γ, ¬γ∧¬S(γ,γ)) ∈ A.

Wait — I think there's a cleaner proof. The condition U(γ, ⊥) → U(γ, r) for all r (proved via A4a) means that U(γ, ⊥) in an MCS implies "γ will happen at some point with literally nothing true at intermediate points." Combining with A3a and the fact that S(α, ⊥) ∈ C for all α ∈ A (from the Since direction):

A3a: α ∧ U(γ, ⊥) → U(γ∧S(α,⊥), ⊥). But ⊥ is not in B=Set.univ... wait, ⊥ IS in Set.univ. So from U(γ∧S(α,⊥), ⊥) → ... the event γ∧S(α,⊥) must be consistent by 2.2. And S(α,⊥) ∈ C... by hypothesis (Since direction). And γ ∈ C. So γ∧S(α,⊥) ∈ C. Is γ∧S(α,⊥) consistent? C is MCS so yes.

This doesn't lead to contradiction either.

**I believe NoUnivBurgessR3 requires the specific proof using A4a to show U(γ, ⊥) → U(γ, r) for all r, and then deriving from the combined Until+Since conditions that Set.univ satisfying both is impossible.** But I haven't found the exact derivation.

**Alternative**: Perhaps it IS simply provable that burgessR3(A, Set.univ, C) = False because it would make A and C "too connected" — every formula in A has since-partners in C for EVERY guard, and every formula in C has until-partners in A for every guard, which creates a circularity that leads to contradiction. But the exact argument eludes me in this analysis.

**Practical resolution**: Since this is a single sorry used as a hypothesis, and the comment says it "holds because Set.univ contains bot, violating the consistency requirement implicit in burgessR3's definition" — but burgessR3 does NOT explicitly require consistency of B — the cleanest approach may be to add an explicit consistency requirement to burgessR3 or burgessRSet (matching Burgess's DCS which ARE consistent by definition). Then NoUnivBurgessR3 becomes trivial: Set.univ is not consistent, so it can't be a DCS, and burgessR3 with B=Set.univ fails.

### Recommended Approach (Two Options)

**Option A (Proof from axioms)**: Prove NoUnivBurgessR3 as a theorem using the A4a argument (U(γ,⊥) → U(γ,r) for all r) and then deriving contradiction from the combined Until+Since conditions. This is mathematically deeper but keeps the current definitions intact.

**Option B (Definition fix)**: Add `SetConsistent B` to the definition of `burgessR3` or `burgessRSet`. Burgess's DCSs are consistent by definition (§1.3: "A is consistent if ⊥ is not a consequence of A. A is deductively closed if it contains all its consequences."). Then NoUnivBurgessR3 becomes trivial since Set.univ is not consistent. This would require checking that no existing proofs break.

### Confidence: MEDIUM
Option A needs more mathematical work to find the exact contradiction. Option B is clean but may require cascading changes.

---

## Summary Table

| # | File:Line | Burgess Ref | Root Cause | Resolution | Confidence |
|---|-----------|-------------|------------|------------|------------|
| 1 | PointInsertion:1977 | Lemma 2.6 | Unnecessary MCS case split; extraction from maximality not implemented | Remove case split, extract witness via DC(B∪{β}) + BX2 contrapositive | HIGH |
| 2 | PointInsertion:2744 | Lemma 2.7 | Seed consistency proof not implemented | Follow 12-step plan in docstring, matching Burgess exactly | MED-HIGH |
| 3 | PointInsertion:2875 | Lemma 2.7 | Unnecessary case split on {xi}∪B consistency | Remove case split, use Zorn from B with xi compatibility | HIGH |
| 4 | CounterexampleElim:413 | Lemma 2.9 (n=m+1) | c2' invariant not threaded through elimination steps | Restore c2' to omega chain, then follow Burgess 2.9 | HIGH |
| 5 | CounterexampleElim:511 | Lemma 2.9' (mirror) | Same as #4 | Mirror of #4 | HIGH |
| 6 | ChronicleToCountermodel:621 | Claim 2.11 (Until) | C5 weak missing guard; c2' + C3 infrastructure needed | Restore c2', prove full C5 with guard via limit_g + C3 | MEDIUM |
| 7 | ChronicleToCountermodel:625 | Claim 2.11 (Since) | Same as #6 | Mirror of #6 | MEDIUM |
| 8 | Completeness:152 | Implicit in Burgess | burgessR3 lacks explicit consistency requirement | Option A: prove from axioms; Option B: add SetConsistent to burgessR3 | MEDIUM |

## Dependency Order for Resolution

```
#8 (NoUnivBurgessR3)  — independent, can be done first
  ↓
#1 (Case B) — needs extraction lemma from maximality
  ↓
#2 (Seed consistency) — depends on maximality extraction (#1 technique)
  ↓
#3 (Inconsistent case) — needs Zorn variant, depends on seed consistency (#2)
  ↓
#4/#5 (C4 hard cases) — need c2' restoration (independent of #1-3)
  ↓
#6/#7 (FUC/FSC) — need c2' + C3 + full C5 (depends on #4/#5)
```

The critical path is: #8 → (#1, #2, #3 in sequence) and (#4, #5 → #6, #7) in parallel.

## Key Helpers Needed

1. **`deductiveClosure_elem_witness`**: Extract conjunction of base elements from DC(B ∪ {β})
2. **`burgessR3Maximal_neg_until_witness`**: From BurgessR3Maximal + δ ∉ B, extract β₀ ∈ B, γ₀ ∈ C with ¬untl(β₀∧δ, γ₀) ∈ A
3. **`burgessR3Maximal_extension_exists_cud`**: Zorn variant accepting ClosedUnderDerivation seed (no consistency requirement)
4. **c2' threading infrastructure**: Restore c2' to all elimination result types
5. **Full C5 with guard**: Bridge limit_g + c5_weak into full C5
