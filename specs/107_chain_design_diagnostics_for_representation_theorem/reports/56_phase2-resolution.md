# Phase 2 Resolution: Maximality Definition Gap

**Task**: 107 - chain_design_diagnostics_for_representation_theorem
**Date**: 2026-05-04
**Session**: sess_1777938108_72f75f
**Type**: Mathematical resolution report

---

## 1. Problem Statement

The two sorry sites at `PointInsertion.lean:1872-1873` require proving:
- `h_ev_b : DerivationTree [] (event.imp b)` -- the event implies the B-guard conjunction
- `h_ev_untl : DerivationTree [] (event.imp (Formula.untl b gamma_hat))` -- the event implies the until-formula

These arise in `burgess_D0_finite_subset_consistent_incons`, the "inconsistent case" of Lemma 2.6 seed consistency. The inconsistent case occurs when `{beta}∪B` is inconsistent (equivalently, `beta.neg ∈ B`).

The consistent case (lines 1601-1801) works correctly by using `burgess_zeta_consistent` which chains BX5 + BX14 + BX13 + BX10. The critical BX14 step transforms the event from `gamma_hat` to `q ∧ (b∧beta).neg` where `q = b ∧ untl(b, gamma_hat)`. Since the new event CONTAINS `q`, extracting `b` and `untl(b, gamma_hat)` is trivial conjunction elimination.

The inconsistent case CANNOT use BX14 because BX14 requires `¬untl(r, gamma_hat) ∈ A` for some formula `r`, and the standard source of such witnesses (the `BurgessR3Maximal_extension_fails` lemma) requires `SetConsistent ({beta} ∪ B)` -- which is exactly what FAILS in the inconsistent case.

## 2. Root Cause: Misalignment with Burgess's Maximality Notion

### Burgess's Original (Paper Section 2.3)

In Burgess 1982, a "deductively closed set" (DCS) is defined as any set closed under logical consequence, with NO consistency requirement. The R-maximality `R(A,B,C)` means B is maximal among ALL DCSs satisfying `r(A,_,C)`.

The key argument (Section 2.3): "whenever R(A,B,C) holds and delta not in B, there must exist beta in B such that r(A, beta∧delta, C) does not hold (else consider B' = consequences of B∪{delta})."

This works UNIFORMLY regardless of whether `{delta}∪B` is consistent:
- If consistent: `DC(B∪{delta})` is a consistent DCS, properly extends B, and (by assumption for contradiction) satisfies r. Violates maximality.
- If inconsistent: `DC(B∪{delta}) = Set.univ` (everything). `Set.univ` is deductively closed (trivially). It properly extends B (since B is consistent, ⊥ not in B). And (by assumption for contradiction) satisfies r. Still violates maximality -- because Burgess's maximality is over ALL DCSs.

### The Code's Current Definition (ChronicleTypes.lean:320-323)

```lean
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  burgessR3 A B C ∧
  ∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessR3 A D C
```

Where `SetDeductivelyClosed D = SetConsistent D ∧ ClosedUnderDerivation D`.

The maximality clause requires D to be `SetDeductivelyClosed`, which INCLUDES consistency. So Set.univ (inconsistent) is excluded from the maximality clause. This makes the code's maximality WEAKER than Burgess's.

### Consequence

When `{beta}∪B` is inconsistent, `DC({beta}∪B) = Set.univ` is NOT `SetDeductivelyClosed` (not consistent). So it cannot serve as the `D` in the maximality clause. The proof-by-contradiction argument fails, and maximality witnesses cannot be extracted.

## 3. Burgess's Actual Method (What the Proof Needs)

Burgess's proof of Lemma 2.6 does NOT have separate "consistent" and "inconsistent" cases. It uses a SINGLE uniform argument:

1. From R-maximality (over all DCSs) and delta not in B: extract witnesses beta0 in B, gamma0 in C with `¬U(gamma0, beta0∧delta) ∈ A` (our: `¬untl(beta0∧delta, gamma0) ∈ A`).

2. WLOG strengthen: replace beta by beta∧beta0, gamma by gamma∧gamma0.

3. Chain: `U(gamma, beta) ∈ A` (from r(A,B,C)) → BX5 gives `U(beta∧U(gamma,beta), beta) ∈ A` → BX14/A4a with the negated witness gives `U(beta∧U(gamma,beta)∧¬delta, beta) ∈ A` → BX13/A3a gives `U(beta∧U(gamma,beta)∧¬delta∧S(alpha,beta), beta) ∈ A` → BX10 gives F(event) ∈ A where event = beta∧U(gamma,beta)∧¬delta∧S(alpha,beta).

4. The event CONTAINS beta (the guard), U(gamma,beta) (the until-formula), ¬delta, and S(alpha,beta). All needed components are present.

The key: BX14 is used IN ALL CASES, and the witnesses always exist because of the stronger maximality.

## 4. Recommended Resolution

### Approach: Strengthen Maximality Clause

Change the maximality clause in `BurgessR3Maximal` from `SetDeductivelyClosed D` to `ClosedUnderDerivation D`:

```lean
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  burgessR3 A B C ∧
  ∀ D, ClosedUnderDerivation D → B ⊂ D → ¬burgessR3 A D C
```

This matches Burgess's original notion: B is maximal among ALL deductively closed sets (the third clause), while B itself must still be consistent (the first clause).

### Implementation Steps

#### Step 1: Update `BurgessR3Maximal` definition (ChronicleTypes.lean:320-323)

Change the maximality clause from `SetDeductivelyClosed D` to `ClosedUnderDerivation D`.

#### Step 2: Update `burgessR3Maximal_extension_exists` (RRelation.lean:724-765)

The Zorn construction produces B maximal among CONSISTENT DCSs. We must verify the stronger maximality holds for the Zorn-maximal B.

**Proof that stronger maximality holds**: Let D be ClosedUnderDerivation with B ⊂ D and burgessR3(A,D,C).
- If D is consistent: D is SetDeductivelyClosed. Since burgessR3(A,D,C) and S ⊆ B ⊆ D: D is in `burgessR3DCSExtensions`. By Zorn maximality: D ⊆ B. Combined with B ⊂ D: contradiction.
- If D is inconsistent: D = Set.univ (any inconsistent set closed under derivation contains everything). So burgessR3(A, Set.univ, C). This means for ALL phi, for all gamma in C: untl(phi, gamma) ∈ A. In particular, for any consistent DCS D' with B ⊂ D' (which exists since B is produced from a seed that's not an MCS -- see Step 2b): burgessR3(A, D', C) holds (since D' ⊆ Set.univ and burgessR3 is monotone-decreasing in the second argument -- fewer formulas to check). But this contradicts Zorn-maximality.

**Step 2b: Prove B is not an MCS.** The Zorn-maximal B is constructed from a seed S = DC({eta}) where eta is typically a simple tautology. If burgessR3(A, Set.univ, C) held, then EVERY consistent DCS would satisfy burgessR3, so the Zorn-maximal would be an MCS. But g_content(A) ⊆ C provides constraints that prevent this.

Specifically: if B is an MCS and burgessR3(A, Set.univ, C), use `burgessR3_univ_of_inconsistent_ext` in REVERSE -- if burgessR3(A, Set.univ, C) holds, and there exists ANY phi not in B with G(phi) in A, then we reach contradiction via the g_content argument at lines 744-757.

**Alternative for Step 2**: If proving B is never an MCS is difficult, add `¬burgessR3 A Set.univ C` as an additional hypothesis to `burgessR3Maximal_from_g_content_sub`. This is provable at all call sites because: at the call site (lemma_2_4, line 172), the MCS A satisfies U(gamma, beta) ∈ A for specific gamma, beta from the original until-formula being witnessed. This means there are formulas NOT satisfying the universal condition.

#### Step 3: Update `BurgessR3Maximal_extension_fails` (PointInsertion.lean:566-579)

Remove the `h_cons` hypothesis. The proof becomes:

```lean
theorem BurgessR3Maximal_extension_fails {A B C : Set Formula}
    (h_R3M : BurgessR3Maximal A B C)
    {delta : Formula} (h_delta_not : delta ∉ B) :
    ¬burgessR3 A (deductiveClosure ({delta} ∪ B)) C := by
  intro h_r3
  -- DC({delta}∪B) is ClosedUnderDerivation (regardless of consistency)
  have h_cud : ClosedUnderDerivation (deductiveClosure ({delta} ∪ B)) :=
    deductiveClosure_closed_under_derivation ({delta} ∪ B)
  -- B ⊂ DC({delta}∪B) (since delta ∈ DC but delta ∉ B)
  have h_sub : B ⊆ deductiveClosure ({delta} ∪ B) :=
    fun phi hphi => subset_deductiveClosure _ (Set.mem_union_right _ hphi)
  have h_delta_in : delta ∈ deductiveClosure ({delta} ∪ B) :=
    subset_deductiveClosure _ (Set.mem_union_left _ (Set.mem_singleton delta))
  have h_proper : B ⊂ deductiveClosure ({delta} ∪ B) :=
    ⟨h_sub, fun h_eq => h_delta_not (h_eq h_delta_in)⟩
  exact h_R3M.2.2 _ h_cud h_proper h_r3
```

Note: Needs a lemma `deductiveClosure_closed_under_derivation` that proves deductiveClosure is ClosedUnderDerivation regardless of consistency. This is straightforward from the existing `deductiveClosure_closed` theorem (RRelation.lean:156-189).

#### Step 4: Remove the case split in `burgess_D0_seed_consistent`

With the updated `BurgessR3Maximal_extension_fails` (no `h_cons` needed), both the consistent and inconsistent cases can use the SAME extraction of maximality witnesses. The inconsistent-case function `burgess_D0_finite_subset_consistent_incons` becomes unnecessary.

The unified proof:
1. From BurgessR3Maximal + beta not in B: `BurgessR3Maximal_extension_fails` gives ¬burgessR3(A, DC({beta}∪B), C)
2. Extract witnesses beta0, gamma0 with ¬untl(beta0∧beta, gamma0) ∈ A (same argument as current lines 2045-2081)
3. Derive F(beta.neg) ∈ A (same BX chain as current lines 2083-2143)
4. Call `burgess_D0_finite_subset_consistent` (the existing consistent-case function, which already works correctly)

The `h_neg_cons : SetConsistent ({beta.neg} ∪ B)` required by `burgess_D0_finite_subset_consistent` is provable in BOTH cases:
- Consistent case: from beta not in B and B DCS, {beta.neg}∪B is consistent (by DNE argument at lines 2265-2277)
- Inconsistent case: beta.neg ∈ B, so {beta.neg}∪B = B which is consistent

#### Step 5: Delete `burgess_D0_finite_subset_consistent_incons`

The function with the two sorries (lines 1811-1976) is no longer needed.

## 5. Files to Modify

| File | Change |
|------|--------|
| `ChronicleTypes.lean:320-323` | Change `SetDeductivelyClosed D` to `ClosedUnderDerivation D` in maximality clause |
| `RRelation.lean:724-765` | Update Zorn construction proof for stronger maximality |
| `RRelation.lean` (new) | Add `deductiveClosure_closed_under_derivation` lemma |
| `PointInsertion.lean:566-579` | Remove `h_cons` from `BurgessR3Maximal_extension_fails` |
| `PointInsertion.lean:1811-1976` | Delete `burgess_D0_finite_subset_consistent_incons` |
| `PointInsertion.lean:2290-2319` | Simplify inconsistent case to use same path as consistent case |

## 6. Risk Assessment

### Low Risk
- Changing the maximality clause is mathematically correct (aligns with Burgess)
- The existing consistent-case proof (`burgess_D0_finite_subset_consistent`) already works and handles both scenarios once witnesses are available
- `BurgessR3Maximal_extension_fails` without `h_cons` is strictly more general

### Medium Risk
- The Zorn construction proof (Step 2) needs to show the stronger maximality holds. This requires proving either:
  (a) B is never an MCS (from the construction), or
  (b) If B is an MCS then burgessR3(A, Set.univ, C) leads to contradiction with the hypotheses available at the construction site

### Mitigation
- If Step 2 proves difficult, an ALTERNATIVE is to add `¬burgessR3 A Set.univ C` as an explicit hypothesis to `burgessR3Maximal_from_g_content_sub` and prove it at each call site. This avoids the need to prove it inside the Zorn construction.

## 7. Verification Criteria

After implementation:
1. `lake build` passes with no errors
2. The two sorries at lines 1872-1873 are eliminated
3. No new sorries or axioms are introduced
4. `lean_verify` on `lemma_2_6_splitting` shows no axioms beyond the standard ones

## 8. Connection to Phases 3-8

This fix does NOT affect Phases 3-8 of the implementation plan. Those phases target different sorry sites (lemma_2_7_seed_consistent at line 2414, and various chronicle construction sorries). The definition change to `BurgessR3Maximal` may require minor adjustments to theorems that pattern-match on the maximality clause, but the change is strictly MORE permissive (the new clause accepts more D values), so existing uses of the maximality clause remain valid.
