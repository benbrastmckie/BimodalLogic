# Teammate C Findings: Critic — Gaps and Assumptions

## Key Findings

### 1. THE CASE SPLIT IS A FORMALIZATION ARTIFACT

**Burgess does NOT case-split on consistency.** His R-maximality definition (Section 2.3) says:

> "whenever R(A,B,C) holds and δ ∉ B there must exist β ∈ B such that r(A, β∧δ, C) does not hold (else consider B' = consequences of B ∪ {δ})"

Crucially, Burgess's "DCS" (Section 1.3) is ONLY "deductively closed" — NOT requiring consistency:

> "A is deductively closed if it contains all its consequences."

His "MCS" is the subset that IS consistent AND complete. But his R-maximality quantifies over ALL DCSs (including inconsistent ones like Set.univ). When {δ}∪B is inconsistent, consequences(B∪{δ}) = Set.univ, which trivially satisfies r(A, -, C) (every formula is in Set.univ). So the extension B' = Set.univ would be a proper DCS extension satisfying r(A,B',C), contradicting R-maximality. Hence the witness β₀, γ₀ with ~U(γ₀, β₀∧δ) ∈ A EXISTS REGARDLESS.

**The formalization's `SetDeductivelyClosed` definition (line 82 of ChronicleTypes.lean) includes `SetConsistent`, which breaks this argument.** Since Set.univ is not `SetDeductivelyClosed` in the formalization, the Zorn maximality clause doesn't cover it.

### 2. THE INCONSISTENT CASE IS REACHABLE (but the sorry might be eliminable structurally)

The case split at line 2051 (`by_cases h_cons : SetConsistent ({β} ∪ B)`) is necessary given the current definition because `BurgessR3Maximal_extension_fails` requires `h_cons`. But if the definition were fixed to match Burgess (maximality over ClosedUnderDerivation, not SetDeductivelyClosed), then:
- The witness would exist regardless of consistency
- The entire inconsistent-case function becomes dead code
- BUT: we already tried this (report 56), and it created an UNPROVABLE sorry in the Zorn construction

### 3. THE REAL PROBLEM IS CIRCULAR

- **ClosedUnderDerivation maximality** → witness exists always → no case split needed → but Zorn proof breaks (can't prove maximality over inconsistent sets from Zorn over consistent ones)
- **SetDeductivelyClosed maximality** → Zorn proof works → but witness only exists in consistent case → inconsistent case needs separate handling → pos sub-case is stuck

### 4. THE CORRECT FIX: TWO-LEVEL MAXIMALITY

The resolution is to have `BurgessR3Maximal_extension_fails` NOT require consistency as a hypothesis, but instead INTERNALLY do the case split:

```
BurgessR3Maximal_neg_or_ext_fails (h_r3m : BurgessR3Maximal A B C) (h_β_not_B : β ∉ B) :
  (β.neg ∈ B) ∨ (∃ β₀ ∈ B, ∃ γ₀ ∈ C, (untl (β₀ ∧ β) γ₀).neg ∈ A)
```

When {β}∪B is inconsistent → β.neg ∈ B (left disjunct).
When {β}∪B is consistent → extension_fails gives the witness (right disjunct).

**Then in `burgess_D0_seed_consistent`, the proof should be**:
- From `h_β_not_B`, apply `BurgessR3Maximal_neg_or_ext_fails`
- LEFT case (β.neg ∈ B): The witness β₀ = any element of B, γ₀ = any element of C. Use `~U(γ₀, β₀∧β) ∈ A`... wait, this is not guaranteed.
  
  Actually: in the LEFT case, β.neg ∈ B. Then {β.neg} ⊆ B, and since B satisfies burgessR3, we have untl(β.neg, γ) ∈ A for all γ∈C. We also have untl(β.neg, γ) ∈ A. Apply BX5 to get untl(β.neg ∧ untl(β.neg,γ), γ) ∈ A. Apply BX14 with witness ~untl(β.neg∧β, γ) which... requires it to be in A.

  **THIS IS THE SAME BLOCKER.** In the inconsistent case, we need ~U(γ₀, β₀∧β) ∈ A for some β₀, γ₀. If β₀ = β.neg, then β₀∧β = β.neg∧β → ⊥, and untl(⊥, γ₀) is satisfiable on discrete orders.

### 5. FUNDAMENTAL INSIGHT: BURGESS NEVER NEEDS THE NEG-UNTIL WITNESS IN THE INCONSISTENT CASE

Re-reading Section 2.6 more carefully: Burgess gets the witness (~U(γ₀, β₀∧δ) ∈ A) from R-maximality which works because his DCS includes inconsistent sets. The formalization's consistent-only DCS definition breaks this. But:

**Burgess's proof ONLY USES the witness in the construction of ζ**, not for showing inconsistency is impossible. He constructs:
```
ζ = S(α, β) ∧ β ∧ ~δ ∧ U(γ, β)
```
and then uses A5a, A4a, A3a to show ζ is consistent. The witness ~U(γ₀, β₀∧δ) ∈ A is essential for A4a (separation).

**So in the inconsistent case, if we DON'T have the neg-until witness, we CAN'T apply A4a.** The pos sub-case is genuinely stuck.

## Recommended Approach

**The correct fix is to restructure maximality to match Burgess**: quantify over `ClosedUnderDerivation` sets BUT do not prove this via Zorn over consistent sets. Instead:

1. Keep `BurgessR3Maximal` with `SetDeductivelyClosed` maximality (Zorn works)
2. Add a SEPARATE lemma: `BurgessR3Maximal_implies_neg_until_witness`:
   ```
   R(A,B,C) → β ∉ B → ∃ β₀ ∈ B, ∃ γ₀ ∈ C, ~U(γ₀, β₀∧β) ∈ A
   ```
   Proof: case split on SetConsistent({β}∪B).
   - Consistent: from extension_fails (existing proof)
   - Inconsistent: β.neg ∈ B. Then for ANY γ₀ ∈ C, from burgessR3 we have untl(β.neg, γ₀) ∈ A. 
     We need ~U(γ₀, β.neg∧β) ∈ A. Since β.neg∧β → ⊥, U(γ₀, β.neg∧β) means "exists future point with ⊥ true" (open guard) — **which IS falsifiable if we can show ~untl(⊥, γ₀) is a theorem**. But it's NOT a theorem on discrete orders.

**ALTERNATIVELY**: Skip Phase 2 entirely. Phases 3-7 are independent. The 2 sorries in Phase 2 may need the `irr_until` axiom (which would make `untl(⊥, φ)` unsatisfiable by ruling out adjacent-point models).

## Evidence/Examples

- Burgess Section 1.3: "A is deductively closed if it contains all its consequences" (NO consistency requirement)
- Burgess Section 2.3: R-maximality over "proper extensions" — considers consequences(B∪{δ}) which can be Set.univ
- ChronicleTypes.lean:82: `SetDeductivelyClosed S := SetConsistent S ∧ ClosedUnderDerivation S` (adds consistency)
- The Zorn proof (RRelation.lean:766-784) works BECAUSE it only needs maximality over consistent DCSs
- The seed consistency proof FAILS because it needs a witness that requires maximality over ALL deductively closed sets

## Confidence Level

**High** — The root cause is definitional: `SetDeductivelyClosed` requiring consistency diverges from Burgess's "DCS". All previous attempts have been treating symptoms of this structural mismatch. The pos sub-case is genuinely hard to resolve without either (1) matching Burgess's definition (breaks Zorn) or (2) adding an axiom that makes `untl(⊥, φ)` unsatisfiable.
