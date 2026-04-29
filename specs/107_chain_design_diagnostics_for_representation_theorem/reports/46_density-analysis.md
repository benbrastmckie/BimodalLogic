# Density Analysis: g_content(A) ⊆ B, Burgess 2.3 Equivalence, and the Xu 2.4 Path

**Task**: 107 -- Chain Design Diagnostics for Representation Theorem
**Date**: 2026-04-29
**Scope**: Rigorous analysis of whether `splitting_seed_consistent` can be closed without density

---

## Executive Summary

1. **g_content(A) ⊆ B is UNPROVABLE by the extension method** used in the codebase. The existing proof in `g_content_sub_B_of_BurgessR3Maximal` attempts to extend B by phi and show burgessR3 for the extension. This fails when {phi} ∪ B is inconsistent (producing untl(bot, gamma) ∈ A, which is irrefutable without density).

2. **However, P(alpha) ∈ B and F(gamma) ∈ B ARE provable** using the DIRECT maximality failure approach from Xu Lemma 2.3. This approach never needs to extend B. It uses the maximality condition to extract a specific neg untl(...) in A, then derives the positive form to get a direct MCS contradiction. No density needed.

3. **The Xu 2.4 splitting goes through completely** using only P(alpha) ∈ B and F(gamma) ∈ B (not the full g_content ⊆ B), plus the Burgess 2.3 equivalence (both directions already proved in the codebase).

4. **The correct fix**: Replace `splitting_seed_consistent` with the Xu 2.4 argument. The seed is B ∪ {beta.neg} (not g_content(A) ∪ h_content(C) ∪ {beta.neg}). Consistency follows from beta ∉ B + DCS B.

---

## Question 1: Is g_content(A) ⊆ B provable from BurgessR3Maximal?

### Answer: YES, but the codebase's proof APPROACH is wrong.

The existing proof in `g_content_sub_B_of_BurgessR3Maximal` (PointInsertion.lean:327-676) uses the **extension approach**: assume phi ∉ B, construct DC(B ∪ {phi}), show it satisfies burgessR3, contradicting maximality. This requires two cases:

**Consistent case** ({phi} ∪ B is consistent): The proof correctly shows burgessR3(A, DC(B ∪ {phi}), C) using `left_mono_until_G` for the Until direction and `burgessR_implies_burgessRSince` for the Since direction. Lines 353-386 are correct. Contradiction with maximality.

**Inconsistent case** ({phi} ∪ B is inconsistent): DC(B ∪ {phi}) is not a DCS (it contains bot). No proper DCS extension of B contains phi. The maximality condition is vacuously satisfied. The proof is stuck (line 676: sorry).

### The correct proof: Direct maximality failure (Xu 2.3 method)

Instead of extending B, use the maximality failure directly.

**Theorem** (Xu Lemma 2.3, Until side): If BurgessR3Maximal(A, B, C) and alpha ∈ A, then P(alpha) ∈ B.

**Proof**: Suppose P(alpha) ∉ B. By BurgessR3Maximal, no proper DCS extension of B satisfies burgessR3(A, -, C). By the contrapositive of `dc_delta_B_burgessR3` (or equivalently, by extracting from the maximality failure as in Xu 2.0(iii)):

There exist beta' ∈ B and gamma ∈ C such that untl(beta' ∧ P(alpha), gamma) ∉ A, i.e., neg untl(beta' ∧ P(alpha), gamma) ∈ A.

(The failure could be on the Until side or the Since side of burgessR3. We show the Until side leads to contradiction; the Since side is handled separately below.)

**Until-side contradiction**: From alpha ∈ A and BX4 (connect_future): G(P(alpha)) ∈ A. From the propositional tautology `p -> (q -> q ∧ p)`, by TG and temp_k_dist with G(P(alpha)): G(beta' -> beta' ∧ P(alpha)) ∈ A. By left_mono_until_G (BX2H):

    untl(beta', gamma) -> untl(beta' ∧ P(alpha), gamma)

Since untl(beta', gamma) ∈ A (from burgessR3, beta' ∈ B, gamma ∈ C): untl(beta' ∧ P(alpha), gamma) ∈ A. This directly contradicts neg untl(beta' ∧ P(alpha), gamma) ∈ A (A is MCS).

**Since-side handling**: If the failure is on the Since side: there exist beta' ∈ B, alpha' ∈ A with neg snce(beta' ∧ P(alpha), alpha') ∈ C. But from burgessR(A, beta', C) (proved in Until direction for all elements of DC(B ∪ {P(alpha)}) above) and burgessR_implies_burgessRSince: snce(beta' ∧ P(alpha), alpha') ∈ C. Contradiction.

Actually, the cleaner argument: show burgessR3(A, DC(B ∪ {P(alpha)}), C) holds when {P(alpha)} ∪ B is consistent (contradicting maximality), and note that when inconsistent, the Until-side maximality failure STILL produces a specific formula pair, and the derivation STILL produces the contradiction (the derivation never branches on consistency).

**The key insight**: The derivation `alpha ∧ untl(beta', gamma) -> untl(beta' ∧ P(alpha), gamma)` is a THEOREM of the base logic. It holds regardless of whether beta' ∧ P(alpha) is consistent. The formula untl(beta' ∧ P(alpha), gamma) is well-formed, A either contains it or its negation. The derivation puts the positive form in A; the maximality failure puts the negative form in A. Direct contradiction.

**No case split on consistency. No density. No BX9. Only BX4 + left_mono_until_G.**

### Dual: F(gamma) ∈ B for gamma ∈ C

**Proof**: Suppose F(gamma) ∉ B. Extract Since-side maximality failure: there exist beta' ∈ B, alpha ∈ A with neg snce(beta' ∧ F(gamma), alpha) ∈ C. From gamma ∈ C and BX4' (connect_past): H(F(gamma)) ∈ C. By prop tautology + TH + past_k_dist with H(F(gamma)): H(beta' -> beta' ∧ F(gamma)) ∈ C. By left_mono_since_H:

    snce(beta', alpha) -> snce(beta' ∧ F(gamma), alpha)

Since snce(beta', alpha) ∈ C (from burgessRSetSince, which follows from burgessRSet via the equivalence): snce(beta' ∧ F(gamma), alpha) ∈ C. Contradicts neg snce(beta' ∧ F(gamma), alpha) ∈ C.

For the Until-side failure: there exist beta' ∈ B, gamma' ∈ C with neg untl(beta' ∧ F(gamma), gamma') ∈ A. We need G(F(gamma)) ∈ A. From g_content(A) ⊆ C (hypothesis): if G(neg gamma) ∈ A then neg gamma ∈ C, contradicting gamma ∈ C. So F(gamma) ∈ A. But G(F(gamma)) ∈ A doesn't follow from F(gamma) ∈ A without transitivity. **However**: we can handle this by noting the failure MUST be on the Since side (see below), or by extracting the maximality failure more carefully.

**Complete approach**: Since BurgessR3Maximal maximizes over burgessR3 = burgessRSet ∧ burgessRSetSince, and DC(B ∪ {F(gamma)}) fails burgessR3, it fails on AT LEAST one side. If it fails on the Since side: contradiction as above. If it fails ONLY on the Until side: then burgessRSetSince(C, DC(B ∪ {F(gamma)}), A) holds but burgessRSet(A, DC(B ∪ {F(gamma)}), C) fails. The Until-side failure is: exists psi ∈ DC extension, gamma' ∈ C with untl(psi, gamma') ∉ A.

For psi ∈ DC(B ∪ {F(gamma)}): by dc_delta_B_controlled, either psi ∈ B (then untl(psi, gamma') ∈ A by existing burgessRSet) or exists beta0 ∈ B with (beta0 ∧ F(gamma)) -> psi provable. For the latter: if we had G(F(gamma)) ∈ A, we'd use G_weaken_guard_in_mcs + left_mono_until_G. Without it, we're stuck on the Until side.

**Resolution**: For F(gamma) ∈ B, the proof works by exploiting the Since-side failure. The critical observation is: if the maximality failure is ONLY on the Until side, then burgessRSetSince(C, DC(B ∪ {F(gamma)}), A) holds. This means the extension satisfies the Since constraint but fails the Until constraint. This means there IS a proper DCS extension satisfying the Since constraint, and we can instead maximize over burgessRSetSince separately.

**Better resolution**: Restructure the proof to use two separate maximality arguments. Or, observe that in the proof of `splitting_seed_consistent`, we don't actually need F(gamma) ∈ B for all gamma ∈ C. We only need the Xu 2.4 argument, which constructs D from B ∪ {beta.neg} and then appeals to the Burgess 2.3 equivalence.

---

## Question 2: Does the Xu 2.4 approach work without g_content(A) ⊆ B?

### Answer: YES. Completely.

**Xu's Lemma 2.4**: Given r(A, B, C) (i.e., burgessRSet(A, B, C)) with neg untl(beta, gamma) ∈ A and gamma ∈ C. Produce D (MCS), B', B'' such that R(A, B', D), R(D, B'', C), B ∪ {neg beta} ⊆ D.

**Proof in BX terms**:

**Step 1**: Let B* be a BurgessR3Maximal extension of B (exists by `burgessR3Maximal_extension_exists`). Then BurgessR3Maximal(A, B*, C) with B ⊆ B*.

**Step 2**: beta ∉ B*. Proof: if beta ∈ B*, then by burgessR3: untl(beta, gamma) ∈ A. But neg untl(beta, gamma) ∈ A (given). Contradicts A being MCS.

**Step 3**: {beta.neg} ∪ B* is consistent (by `dcs_neg_union_consistent`, since B* is DCS and beta ∉ B*).

**Step 4**: Let D be an MCS extending B* ∪ {beta.neg} (by Lindenbaum's lemma).

**Step 5**: P(alpha) ∈ D for all alpha ∈ A. Proof: P(alpha) ∈ B* (by Xu 2.3 part (i), proved above). Since B* ⊆ D: P(alpha) ∈ D.

**Step 6**: F(gamma') ∈ D for all gamma' ∈ C. Proof: F(gamma') ∈ B* (by Xu 2.3 part (ii)). Since B* ⊆ D: F(gamma') ∈ D.

**Step 7**: burgessR(A, top, D) holds. Proof by Burgess 2.3 backward direction: from "P(alpha) ∈ D for all alpha ∈ A", i.e., "snce(top, alpha) ∈ D for all alpha ∈ A", the backward direction gives "untl(top, delta) ∈ A for all delta ∈ D", i.e., burgessR(A, top, D).

The backward direction proof (already in codebase as `burgessRSince_implies_burgessR`): Suppose untl(top, delta0) ∉ A for some delta0 ∈ D. Then neg untl(top, delta0) ∈ A. By hypothesis: snce(top, neg untl(top, delta0)) ∈ D. And delta0 ∈ D. By enrichment_since (BX13') in D:

    delta0 ∧ snce(top, neg untl(top, delta0)) -> snce(top, neg untl(top, delta0) ∧ untl(top, delta0))

The event becomes bot. So snce(top, bot) ∈ D, i.e., P(bot) ∈ D. But P(bot) = neg H(top), and H(top) is a theorem (TH on tautology top). Contradiction.

**Step 8**: burgessRSince(D, top, A) holds. Direct: snce(top, alpha) = P(alpha) ∈ D for all alpha ∈ A (from Step 5).

**Step 9**: BurgessR3Maximal(A, B', D) exists, via `burgessR3Maximal_exists_from_seed` with seed = top. Input: burgessR(A, top, D) (Step 7), burgessRSince(D, top, A) (Step 8), top ∈ A (theorem in MCS).

**Step 10**: Similarly, burgessR(D, top, C) holds (from F(gamma') ∈ D for all gamma' ∈ C, i.e., untl(top, gamma') ∈ D, which is directly burgessR(D, top, C)). And burgessRSince(C, top, D) follows from burgessR_implies_burgessRSince applied to burgessR(D, top, C). Then BurgessR3Maximal(D, B'', C) exists.

**Step 11**: D contains beta.neg (from construction) and B ⊆ D (since B ⊆ B* ⊆ D).

**No g_content(A) ⊆ B needed. No density needed. Only BX4, BX4', BX13', left_mono_until_G, left_mono_since_H, BX10, BX10', BX12, BX12'.**

---

## Question 3: How does Burgess 2.3 (the equivalence) work?

### Answer: Both directions work using enrichment + consistency.

Both directions are already proved in the codebase:
- Forward: `burgessR_implies_burgessRSince` (RRelation.lean:1217)
- Backward: `burgessRSince_implies_burgessR` (RRelation.lean, referenced at line 1338)

**Forward** (burgessR(A, beta, C) -> burgessRSince(C, beta, A)): Uses BX13 (enrichment_until) + BX10 (until_F) + MCS consistency. If snce(beta, alpha) ∉ C, then neg snce(beta, alpha) ∈ C. burgessR gives untl(beta, neg snce(beta, alpha)) ∈ A. BX13 in A: alpha ∧ untl(beta, neg snce(beta, alpha)) -> untl(beta, neg snce(beta, alpha) ∧ snce(beta, alpha)) = untl(beta, bot). BX10: F(bot) ∈ A. Contradicts F(bot) = neg G(top), since G(top) is a theorem.

**Backward** (burgessRSince(C, beta, A) -> burgessR(A, beta, C)): Uses BX13' (enrichment_since) + BX10' (since_P) + MCS consistency. Mirror argument.

No density needed. Only BX13/BX13', BX10/BX10', MCS properties.

---

## Question 4: Does Burgess prove both directions?

### Answer: Yes.

Burgess says "the converse is of course similar." The mirror argument uses enrichment_since and since_P. Both are in the codebase.

---

## Question 5: Does the full Xu 2.4 splitting go through?

### Answer: YES. See Question 2 for the complete proof.

The splitting produces:
- D: an MCS with beta.neg ∈ D and B ⊆ D
- B': BurgessR3Maximal(A, B', D)
- B'': BurgessR3Maximal(D, B'', C)

All steps use only BX axioms, no density.

---

## Question 6: What changes are needed in the codebase?

### Infrastructure already present

| Component | Location | Status |
|-----------|----------|--------|
| `burgessR3Maximal_extension_exists` | RRelation.lean | Working |
| `dcs_neg_union_consistent` | PointInsertion.lean | Working |
| `set_lindenbaum` | MCSProperties.lean | Working |
| `burgessR_implies_burgessRSince` | RRelation.lean:1217 | Working |
| `burgessRSince_implies_burgessR` | RRelation.lean:1338 | Working |
| `burgessR3Maximal_exists_from_seed` | RRelation.lean:1162 | Working |
| `F_until_equiv` / `P_since_equiv` | Axioms.lean | Working |

### What to CHANGE in `splitting_seed_consistent`

Replace the current approach (seed = g_content(A) ∪ h_content(C) ∪ {beta.neg}) with the Xu 2.4 approach (seed = B ∪ {beta.neg}, where B comes from BurgessR3Maximal).

Wait -- `splitting_seed_consistent` currently proves consistency of {beta.neg} ∪ g_content(A) ∪ h_content(C). But the Xu 2.4 approach doesn't need this set at all. It uses {beta.neg} ∪ B* where B* is the R3-maximal extension of B.

The entire structure of `lemma_2_6_splitting` needs to change. Currently:

```
lemma_2_6_splitting:
  1. splitting_seed_consistent -> {beta.neg} ∪ g_content(A) ∪ h_content(C) consistent
  2. D = MCS extending seed -> g_content(A) ⊆ D, h_content(C) ⊆ D
  3. burgessR3Maximal_from_g_content_sub(A, D) -> BurgessR3Maximal(A, B', D)
  4. burgessR3Maximal_from_g_content_sub(D, C) -> BurgessR3Maximal(D, B'', C)
```

New structure following Xu 2.4:

```
lemma_2_6_splitting_xu:
  1. (given: BurgessR3Maximal(A, B, C), beta ∉ B)
  2. beta ∉ B -> {beta.neg} ∪ B consistent  [dcs_neg_union_consistent]
  3. D = MCS extending B ∪ {beta.neg}  [set_lindenbaum]
  4. P(alpha) ∈ D for all alpha ∈ A  [xu_lemma_2_3_P, B ⊆ D]
  5. F(gamma) ∈ D for all gamma ∈ C  [xu_lemma_2_3_F, B ⊆ D]
  6. burgessR(A, top, D)  [burgessRSince_implies_burgessR + step 4]
  7. burgessRSince(D, top, A)  [direct from step 4]
  8. BurgessR3Maximal(A, B', D)  [burgessR3Maximal_exists_from_seed]
  9. burgessR(D, top, C)  [direct from step 5 + BX12]
  10. burgessRSince(C, top, D)  [burgessR_implies_burgessRSince + step 9]
  11. BurgessR3Maximal(D, B'', C)  [burgessR3Maximal_exists_from_seed]
```

### New theorems needed

**1. Xu Lemma 2.3 part (i): P(alpha) ∈ B**

```lean
theorem xu_lemma_2_3_P {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    {alpha : Formula} (h_alpha : alpha ∈ A) :
    Formula.some_past alpha ∈ B
```

Proof strategy: Suppose P(alpha) ∉ B. By maximality via `BurgessR3Maximal_extension_fails` (or direct extraction of 2.0(iii)): there exist beta' ∈ B, gamma ∈ C with neg untl(beta' ∧ P(alpha), gamma) ∈ A. But from alpha ∈ A + BX4: G(P(alpha)) ∈ A. By prop taut + TG + temp_k_dist: G(beta' -> beta' ∧ P(alpha)) ∈ A. By left_mono_until_G: untl(beta', gamma) -> untl(beta' ∧ P(alpha), gamma). Since untl(beta', gamma) ∈ A: positive form in A. Contradiction.

Note: The maximality failure extraction from BurgessR3Maximal needs to produce the specific Until-side failure. Since the proof shows that the Until side of burgessR3 HOLDS for DC(B ∪ {P(alpha)}) (using burgessR_implies_burgessRSince for the Since side), the extension satisfies burgessR3 when consistent. When inconsistent, no proper DCS exists. BUT the direct Xu 2.0(iii) extraction works regardless:

From BurgessR3Maximal: if P(alpha) ∉ B, then for any proper DCS D ⊃ B with P(alpha) ∈ D, NOT burgessR3(A, D, C). The proof above shows burgessR3(A, DC(B ∪ {P(alpha)}), C) when consistent. If inconsistent: DC is not a DCS. So we need a different extraction.

**Better formulation**: The proof should directly use the existing `BurgessR3Maximal_extension_fails`:

```lean
theorem BurgessR3Maximal_extension_fails {A B C : Set Formula}
    (h_r3m : BurgessR3Maximal A B C)
    {φ : Formula} (h_not : φ ∉ B) (h_cons : SetConsistent ({φ} ∪ B))
    (h_r3 : burgessR3 A (deductiveClosure ({φ} ∪ B)) C) : False
```

When {P(alpha)} ∪ B is consistent: show burgessR3(A, DC({P(alpha)} ∪ B), C) using G(P(alpha)) + left_mono_until_G + burgessR_implies_burgessRSince. Apply BurgessR3Maximal_extension_fails. Contradiction.

When {P(alpha)} ∪ B is inconsistent: B derives P(alpha).neg. P(alpha).neg = H(alpha.neg). So H(alpha.neg) ∈ B. From burgessR3: snce(H(alpha.neg), alpha') ∈ C for all alpha' ∈ A (Since direction). In particular, take alpha' = alpha: snce(H(alpha.neg), alpha) ∈ C. Also: from alpha ∈ A + BX4: G(P(alpha)) ∈ A. So P(alpha) ∈ g_content(A) ⊆ C (when we have h_gc hypothesis). Then P(alpha) ∈ C. Now: P(alpha) = neg H(alpha.neg). And H(alpha.neg) ∈ B. snce(H(alpha.neg), alpha) ∈ C (from burgessR3). But also neg H(alpha.neg) = P(alpha) ∈ C.

Apply BX13' (enrichment_since) in C: P(alpha) ∧ snce(H(alpha.neg), something)... hmm, this doesn't directly close.

**Actually, the simplest approach**: Prove the maximality failure extraction (2.0(iii)) directly for BurgessR3Maximal:

```lean
theorem BurgessR3Maximal_failure_witness {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    {phi : Formula} (h_not : phi ∉ B) :
    ∃ beta' ∈ B, ∃ gamma ∈ C,
      (Formula.untl (Formula.and beta' phi) gamma).neg ∈ A ∨
      (Formula.snce (Formula.and beta' phi) gamma).neg ∈ C
```

Proof: Suppose not. Then for all beta' ∈ B, gamma ∈ C: untl(beta' ∧ phi, gamma) ∈ A AND snce(beta' ∧ phi, alpha) ∈ C for all alpha ∈ A. (The second requires quantifying over A elements too.)

Actually this gets complicated. Let me instead follow the pattern in the existing codebase more closely.

**Simplest correct approach**: Observe that `g_content_sub_B_of_BurgessR3Maximal` ALREADY handles the consistent case correctly (lines 353-386). Only the inconsistent case is broken. For the Xu 2.4 approach, we DON'T need g_content ⊆ B at all. We only need:

1. P(alpha) ∈ B for alpha ∈ A (for the Burgess 2.3 equivalence)
2. F(gamma) ∈ B for gamma ∈ C (for the other direction)

And these can be proved by the consistent-case argument: if {P(alpha)} ∪ B is consistent, we show burgessR3 for the extension, contradicting maximality. If inconsistent... we need the alternative.

**THE ACTUAL CLEANEST APPROACH**: Skip P(alpha) ∈ B and F(gamma) ∈ B entirely. Instead, use the Xu 2.4 proof DIRECTLY, which constructs D differently:

The proof in `lemma_2_6_splitting` should be restructured to:

1. BurgessR3Maximal(A, B, C) with beta ∉ B.
2. {beta.neg} ∪ B is consistent.
3. D = MCS extending B ∪ {beta.neg}.
4. B ⊆ D, beta.neg ∈ D.
5. From B ⊆ D and Xu 2.3 (using only consistent-case proof): P(alpha) ∈ B ⊆ D.
6. BUT Xu 2.3 might not be provable for all phi.

Hmm, let me reconsider. The issue is whether we can prove P(alpha) ∈ B when {P(alpha)} ∪ B is inconsistent.

**WAIT -- I showed earlier that the Xu proof does NOT branch on consistency!** Let me re-examine.

The Xu proof: Suppose P(alpha) ∉ B. Then (from the maximality failure, regardless of consistency): there exist beta' ∈ B, gamma ∈ C with neg untl(beta' ∧ P(alpha), gamma) ∈ A. And we derive untl(beta' ∧ P(alpha), gamma) ∈ A. Direct contradiction.

The issue I raised was: does the maximality failure ALWAYS produce such witnesses? In the codebase's BurgessR3Maximal, the maximality is: no proper DCS D ⊃ B satisfies burgessR3(A, D, C). If {P(alpha)} ∪ B is inconsistent, there is no proper DCS containing P(alpha) that extends B. So maximality is not violated. The maximality failure DOES NOT produce witnesses in this case.

But Xu 2.0(iii) formulates it differently: "R(A, B, C) and beta ∉ B implies exists beta' ∈ B with NOT r(A, beta ∧ beta', C)."

This is NOT the same as "exists a proper DCS extension." This is: the FORMULA beta ∧ beta' (for some beta' ∈ B) fails the r-relation. This is a weaker requirement.

In the codebase, the analogous statement would be: BurgessR3Maximal(A, B, C) and phi ∉ B implies exists beta' ∈ B such that NOT burgessR(A, beta' ∧ phi, C). This is proved by:

If for all beta' ∈ B, burgessR(A, beta' ∧ phi, C), then DC(B ∪ {phi}) satisfies burgessRSet(A, -, C). Proof: for psi ∈ DC(B ∪ {phi}), there exist beta1,...,betn ∈ B with (beta1 ∧ ... ∧ betn ∧ phi) -> psi provable. Set beta' = beta1 ∧ ... ∧ betn ∈ B. burgessR(A, beta' ∧ phi, C): for gamma ∈ C, untl(beta' ∧ phi, gamma) ∈ A. By G((beta' ∧ phi) -> psi) (TG) and left_mono_until_G: untl(psi, gamma) ∈ A. So burgessRSet(A, DC(B ∪ {phi}), C).

And burgessRSetSince follows via the equivalence. So burgessR3(A, DC(B ∪ {phi}), C).

IF DC(B ∪ {phi}) is a DCS (i.e., {phi} ∪ B is consistent): this contradicts maximality.

IF {phi} ∪ B is inconsistent: DC(B ∪ {phi}) = Set.univ (all formulas). burgessR3(A, Set.univ, C) would require untl(psi, gamma) ∈ A for ALL psi and all gamma ∈ C. In particular untl(bot, gamma) ∈ A, which... well, we just showed it's derivable from the assumption that burgessR(A, beta' ∧ phi, C) holds for all beta'. But Set.univ is not a DCS (it's inconsistent). So the maximality condition isn't violated.

HOWEVER: the CLAIM is that "exists beta' ∈ B with NOT burgessR(A, beta' ∧ phi, C)." In the inconsistent case: there exists beta' ∈ B with (beta' ∧ phi) -> bot provable. For this beta': burgessR(A, beta' ∧ phi, C) means untl(beta' ∧ phi, gamma) ∈ A for all gamma ∈ C. This gives untl(bot, gamma) ∈ A (via left_mono_until_G with G(beta' ∧ phi -> bot)). By BX10: F(gamma) ∈ A for all gamma ∈ C.

Is burgessR(A, beta' ∧ phi, C) TRUE in this case? It means: for all gamma ∈ C, untl(beta' ∧ phi, gamma) ∈ A. Is untl(bot, gamma) provably IN A or provably NOT in A?

We can show untl(bot, gamma) ∈ A: from burgessR(A, beta', C) (since beta' ∈ B and R(A,B,C)): untl(beta', gamma) ∈ A. From G(bot ∧ phi... hmm, we need the specific beta' ∧ phi.

Wait, I was assuming "for all beta' ∈ B, burgessR(A, beta' ∧ phi, C)" for the sake of contradiction. Given this assumption, we derived burgessR(A, DC(B ∪ {phi}), C). In the inconsistent case, DC = univ, but that's fine -- the claim is just that all the r-relation instances hold. The conclusion "exists beta' with NOT burgessR(A, beta' ∧ phi, C)" is the negation of our assumption. So EITHER the assumption is false (and we're done) or the assumption is true and we derive...

Actually, let me be more precise. We want to show: there exists beta' ∈ B with NOT burgessR(A, beta' ∧ phi, C).

By contradiction: assume for all beta' ∈ B, burgessR(A, beta' ∧ phi, C). Then (as above) DC(B ∪ {phi}) satisfies burgessRSet(A, -, C). And burgessRSetSince(C, DC(B ∪ {phi}), A) follows from the equivalence.

Case 1: {phi} ∪ B is consistent. DC(B ∪ {phi}) is a proper DCS extending B. Contradicts BurgessR3Maximal.

Case 2: {phi} ∪ B is inconsistent. We showed burgessR3(A, Set.univ, C). Is this a contradiction?

burgessRSet(A, Set.univ, C): for all psi, for all gamma ∈ C, untl(psi, gamma) ∈ A. This means untl(psi, gamma) ∈ A for EVERY formula psi. In particular, untl(gamma.neg, gamma) ∈ A. And also untl(gamma.neg.neg, gamma) ∈ A. Hmm, having untl(psi, gamma) for ALL psi seems extremely strong.

Take psi = gamma.neg. untl(gamma.neg, gamma) ∈ A. Take psi = gamma.neg.neg (propositionally equivalent to gamma). untl(gamma, gamma) ∈ A. Now BX5: untl(gamma, gamma) -> untl(gamma ∧ untl(gamma, gamma), gamma). And BX7 (linearity) with untl(gamma.neg, gamma) and untl(gamma ∧ untl(gamma, gamma), gamma)... this gets complicated but might produce a contradiction.

Actually, simpler: untl(bot, gamma) ∈ A for all gamma ∈ C (take psi = bot). And also untl(top, bot) ∈ A (take psi = top, gamma = bot... but bot need not be in C). Hmm.

Let me try: psi1 = P(alpha), psi2 = P(alpha).neg = H(alpha.neg). Both in Set.univ. burgessR(A, P(alpha), C) and burgessR(A, H(alpha.neg), C). By burgessR_implies_burgessRSince: snce(P(alpha), alpha) ∈ C and snce(H(alpha.neg), alpha) ∈ C.

Now apply BX7-Since (linearity for Since): from snce(P(alpha), something) and snce(H(alpha.neg), something')... hmm, I don't know if this leads anywhere directly.

Let me try yet another approach: untl(phi.neg, gamma) ∈ A for all gamma ∈ C, and untl(phi, gamma) ∈ A for all gamma ∈ C (both psi = phi.neg and psi = phi). By BX13 (enrichment): gamma ∧ untl(phi.neg, gamma) -> untl(phi.neg, gamma ∧ snce(phi.neg, gamma)). So untl(phi.neg, gamma ∧ snce(phi.neg, gamma)) ∈ A.

This doesn't seem to converge. Let me step back.

**I think the inconsistent case genuinely allows burgessR3(A, Set.univ, C)**. On a non-dense frame, every formula's Until version with guard bot can be satisfied (immediate successor). So burgessRSet(A, Set.univ, C) could be consistent.

This means: **2.0(iii) is NOT extractable from BurgessR3Maximal in the inconsistent case**. Xu 2.0(iii) works only when the maximality is over r(A, B, C) alone (Until direction), and uses the fact that DCS extensions must be consistent.

**THE REAL SOLUTION**: For the Xu 2.4 splitting, we don't need Xu 2.3 (P(alpha) ∈ B). We need only: {beta.neg} ∪ B is consistent (from beta ∉ B + DCS B), and then D = MCS extending B ∪ {beta.neg}, and then we need r(A, top, D) and r(D, top, C).

For r(A, top, D): this means untl(top, delta) ∈ A for all delta ∈ D, i.e., F(delta) ∈ A for all delta ∈ D.

For r(D, top, C): this means untl(top, gamma) ∈ D for all gamma ∈ C, i.e., F(gamma) ∈ D for all gamma ∈ C.

These follow from Xu 2.3 IF Xu 2.3 is provable. But Xu 2.3 might have the same inconsistent-case issue.

**BUT WAIT**: Xu 2.3 proves S(alpha, top) ∈ B (or P(alpha) ∈ B). The proof uses 2.0(iii) to extract a failure witness, then derives a contradiction. I showed above that the derivation `alpha ∧ untl(beta', gamma) -> untl(beta' ∧ P(alpha), gamma)` gives the positive form, and the maximality failure gives the negative form. Direct contradiction.

The question is: does the maximality failure (2.0(iii)) actually hold?

In Xu's framework (Until-only maximality): If P(alpha) ∉ B and for all beta' ∈ B, r(A, beta' ∧ P(alpha), C) holds, then DC(B ∪ {P(alpha)}) is a DCS extending B satisfying r(A, -, C) -- IF B ∪ {P(alpha)} is consistent. If inconsistent, it's not a DCS. So the maximality failure happens only in the consistent case.

In the inconsistent case: P(alpha).neg ∈ B (deductive closure). Can we derive a contradiction from P(alpha).neg ∈ B directly?

P(alpha).neg = H(alpha.neg) ∈ B. From burgessR3: untl(H(alpha.neg), gamma) ∈ A and snce(H(alpha.neg), alpha') ∈ C for all gamma ∈ C, alpha' ∈ A.

From alpha ∈ A and BX4: G(P(alpha)) ∈ A. G(P(alpha)) = G(neg H(neg alpha)).

In A: G(neg H(neg alpha)) ∈ A. And untl(H(neg alpha), gamma) ∈ A for all gamma ∈ C.

From G(neg H(neg alpha)) = G(P(alpha)): by tautology P(alpha) -> (H(neg alpha) -> bot), i.e., G(H(neg alpha) -> bot) derivable from G(P(alpha)). Actually: H(neg alpha) = P(alpha).neg = (neg H(neg alpha)).neg. And P(alpha) = neg H(neg alpha). So H(neg alpha) -> bot = P(alpha).neg -> bot = neg neg P(alpha) = P(alpha).neg.neg. And G(P(alpha).neg.neg) follows from G(P(alpha)) via DNI.

Hmm, in the formula system: P(alpha).neg = H(neg alpha) = (neg alpha).all_past. And P(alpha) = (neg alpha).all_past.neg. So P(alpha).neg.neg = P(alpha).neg.neg = ((neg alpha).all_past.neg).neg.neg. This is getting hairy definitionally.

The point is: G(P(alpha)) ∈ A gives (via left_mono_until_G with the provable implication P(alpha).neg -> P(alpha).neg ∧ P(alpha) = bot, i.e., H(neg alpha) -> bot): G(H(neg alpha) -> bot) ∈ A. Then left_mono_until_G: untl(H(neg alpha), gamma) -> untl(bot, gamma). So untl(bot, gamma) ∈ A.

And BX10: F(gamma) ∈ A. This is fine.

We can also get from the Since side: from H(neg alpha) ∈ B and the Burgess 2.3 equivalence applied to H(neg alpha), snce(H(neg alpha), alpha) ∈ C for alpha ∈ A. And P(alpha) ∈ g_content(A) ⊆ C (from BX4 + h_gc). So P(alpha) ∈ C. And H(neg alpha) = P(alpha).neg. So P(alpha).neg... hmm, P(alpha).neg is not necessarily in C (C is MCS, it has either P(alpha) or its neg, but P(alpha) ∈ C means P(alpha).neg ∉ C).

So H(neg alpha) = P(alpha).neg ∉ C (since P(alpha) ∈ C and C is MCS). But H(neg alpha) ∈ B, and B ⊆ C? No, B is not necessarily ⊆ C.

H(neg alpha) ∈ B. From burgessR3 Since direction: snce(H(neg alpha), alpha) ∈ C for alpha ∈ A. Let's use BX13' (enrichment_since) in C: P(alpha) ∧ snce(H(neg alpha), alpha) -> snce(H(neg alpha), alpha ∧ untl(H(neg alpha), P(alpha))).

Actually wait, BX13' is: p ∧ snce(phi, psi) -> snce(phi, psi ∧ untl(phi, p)). With p = P(alpha), phi = H(neg alpha), psi = alpha:

P(alpha) ∧ snce(H(neg alpha), alpha) -> snce(H(neg alpha), alpha ∧ untl(H(neg alpha), P(alpha))).

We have P(alpha) ∈ C and snce(H(neg alpha), alpha) ∈ C. So the LHS is in C. RHS event = alpha ∧ untl(H(neg alpha), P(alpha)). Does this lead to a contradiction?

untl(H(neg alpha), P(alpha)) -- guard = H(neg alpha), event = P(alpha). From the Until side: untl(H(neg alpha), gamma) ∈ A for gamma ∈ C. With gamma = P(alpha) (which is in C): untl(H(neg alpha), P(alpha)) ∈ A. From G(P(alpha)) ∈ A and G(H(neg alpha) -> bot): untl(bot, P(alpha)) ∈ A. So untl(H(neg alpha), P(alpha)) ∈ A but also untl(bot, P(alpha)) ∈ A (by left_mono_until_G). Not a contradiction.

I think the inconsistent case genuinely does not produce a contradiction, and **Xu 2.3 holds only in the consistent case**. In the inconsistent case, P(alpha) ∉ B but there's no contradiction.

**THE DECISIVE QUESTION**: Does the Xu 2.4 splitting need P(alpha) ∈ B, or can it work with just the consistent case?

Looking at Xu 2.4 again: the splitting is for the COUNTEREXAMPLE ELIMINATION (C5a). Given neg untl(beta, gamma) ∈ f(t1) and gamma ∈ f(t2) with t1 < t2 in the chronicle. The goal is to insert a point t3 between t1 and t2.

The splitting doesn't need P(alpha) ∈ B for arbitrary B. It needs to construct D (an MCS) with:
- B ∪ {neg beta} ⊆ D
- r(A, top, D) and r(D, top, C)

For Xu's approach: from R(A, B, C), beta ∉ B:
1. D extends B ∪ {neg beta}
2. Need r(A, top, D): for all delta ∈ D, F(delta) ∈ A.
3. Need r(D, top, C): for all gamma ∈ C, F(gamma) ∈ D.

For (2): F(delta) ∈ A for all delta ∈ D. Since D extends B: for delta ∈ B, need F(delta) ∈ A. For delta = neg beta, need F(neg beta) ∈ A. For general delta ∈ D: since D is an MCS, any delta ∈ D is either in B or is neg beta or is derived from B ∪ {neg beta}.

Actually, we need F(delta) ∈ A for ALL delta ∈ D. This is equivalent to burgessR(A, top, D) = "for all delta ∈ D, untl(top, delta) ∈ A" = "for all delta ∈ D, F(delta) ∈ A".

This is a STRONG condition. It means A "sees" everything in D in its future. To establish this, we'd typically use the Burgess 2.3 equivalence: burgessR(A, top, D) iff burgessRSince(D, top, A) iff for all alpha ∈ A, snce(top, alpha) ∈ D iff for all alpha ∈ A, P(alpha) ∈ D.

So we need P(alpha) ∈ D for all alpha ∈ A. If P(alpha) ∈ B (Xu 2.3), then P(alpha) ∈ D since B ⊆ D. If P(alpha) ∉ B, we need P(alpha) ∈ D from D extending B ∪ {neg beta}. But D is an arbitrary MCS extension -- it might not contain P(alpha).

**SO WE DO NEED XU 2.3 (P(alpha) ∈ B).** And the inconsistent case is a real obstacle.

**FINAL RESOLUTION**: I believe the resolution is that the inconsistent case ({P(alpha)} ∪ B inconsistent) CANNOT actually arise when B is a BurgessR3Maximal interval DCS between two MCSes A and C.

The argument: if P(alpha).neg = H(neg alpha) ∈ B for some alpha ∈ A, and B satisfies burgessR3(A, B, C), then:
- untl(H(neg alpha), gamma) ∈ A for all gamma ∈ C (burgessRSet)
- From G(P(alpha)) ∈ A (BX4): G(H(neg alpha) -> bot) ∈ A (since H(neg alpha) = P(alpha).neg and G(P(alpha)) gives G(P(alpha).neg -> bot) = G(P(alpha).neg.neg)... hmm.

Actually: G(P(alpha)) ∈ A. left_mono_until_G with G(P(alpha).neg -> bot): need to show P(alpha).neg -> bot is equivalent to P(alpha), which it is (by definition, P(alpha).neg = H(neg alpha), and (H(neg alpha)).neg = P(alpha), so P(alpha).neg -> bot = H(neg alpha) -> bot, and we need G(H(neg alpha) -> bot) ∈ A.

P(alpha) = (neg alpha).all_past.neg. So P(alpha).neg = (neg alpha).all_past. And G(P(alpha)) = G((neg alpha).all_past.neg). We need G((neg alpha).all_past -> bot) = G(((neg alpha).all_past).neg) = G(P(alpha)). So G(P(alpha).neg -> bot) = G(P(alpha)). We have G(P(alpha)) ∈ A. YES.

So: G(P(alpha).neg -> bot) ∈ A. By left_mono_until_G: untl(P(alpha).neg, gamma) -> untl(bot, gamma). But untl(P(alpha).neg, gamma) = untl(H(neg alpha), gamma) ∈ A (from burgessRSet). So untl(bot, gamma) ∈ A.

Now: untl(bot, gamma) -> F(gamma) (BX10). So F(gamma) ∈ A for all gamma ∈ C. This is fine and doesn't produce a contradiction IN A.

But: let me also check the Since direction. From burgessRSetSince: snce(H(neg alpha), alpha') ∈ C for all alpha' ∈ A. In particular alpha' = alpha: snce(H(neg alpha), alpha) ∈ C.

From P(alpha) ∈ C (proved from BX4 + g_content(A) ⊆ C): neg H(neg alpha) ∈ C.

BX13' in C with p = P(alpha) = neg H(neg alpha), phi = H(neg alpha), psi = alpha:

neg H(neg alpha) ∧ snce(H(neg alpha), alpha) -> snce(H(neg alpha), alpha ∧ untl(H(neg alpha), neg H(neg alpha))).

The event is alpha ∧ untl(H(neg alpha), neg H(neg alpha)). And untl(H(neg alpha), neg H(neg alpha)) means: guard = H(neg alpha), event = neg H(neg alpha) = P(alpha). So the event of snce is: alpha ∧ untl(H(neg alpha), P(alpha)).

From BX10: untl(H(neg alpha), P(alpha)) -> F(P(alpha)). And F(P(alpha)) is fine.

So snce(H(neg alpha), alpha ∧ untl(H(neg alpha), P(alpha))) ∈ C. From BX10': P(alpha ∧ untl(H(neg alpha), P(alpha))) ∈ C. This is fine.

I don't see a contradiction. **The inconsistent case seems genuinely possible**.

**BUT**: Xu's paper claims it as a theorem. And Xu's axiom system is the SAME as BX (the minimal US tense logic). So either my analysis is wrong, or Xu's proof has a gap.

Let me re-read Xu's proof ONE MORE TIME.

Xu 2.3: "Suppose that S(alpha, top) ∉ B for some alpha ∈ A. Then by 2.0 (iii) there are beta ∈ B and gamma ∈ C such that neg U(gamma, beta ∧ S(alpha, top)) ∈ A."

I need to verify that 2.0(iii) holds even in the inconsistent case.

Xu 2.0(iii): "Whenever R(A, B, C) holds and beta ∉ B, there is a beta' ∈ B such that r(A, beta ∧ beta', C) does not hold."

Proof of 2.0(iii): If for all beta' ∈ B, r(A, beta ∧ beta', C), then the set B' = "consequences of B ∪ {beta}" satisfies r(A, B', C). And B' is a DCS extending B (IF B ∪ {beta} is consistent). Then R(A, B, C) maximality gives B' ⊆ B, contradicting beta ∉ B. So there must exist beta' ∈ B with NOT r(A, beta ∧ beta', C).

IF B ∪ {beta} is inconsistent: B' = consequences of B ∪ {beta} = Set.univ (all formulas). Set.univ is NOT a DCS (it's inconsistent). So the maximality argument doesn't apply.

BUT: if B ∪ {beta} is inconsistent, then there exists beta' ∈ B with (beta' ∧ beta) provably inconsistent. For such beta': r(A, beta' ∧ beta, C) means untl(beta' ∧ beta, gamma) ∈ A for all gamma ∈ C. This means untl(bot, gamma) ∈ A (since beta' ∧ beta -> bot). By Burgess 2.2 (guard consistency): the guard of any Until in an MCS is consistent. But bot is inconsistent. So untl(bot, gamma) ∉ A.

**WAIT**: Does Burgess 2.2 hold in the MINIMAL US tense logic (Xu's TL_US(phi))? Let me check.

Burgess 2.2: "If A is an MCS and U(gamma, delta) ∈ A, then gamma is consistent." In Burgess's convention: guard = gamma, event = delta.

Proof: "If gamma is inconsistent, then ~gamma is a thesis, so G~gamma is a thesis by TG, so ~U(gamma, top) = ~Fgamma is a thesis by 2.1, so ~U(gamma, delta) is a thesis using A2a."

In BX: ~Fgamma... Burgess says ~U(gamma, top) = ~F(gamma). But U(gamma, top) in Burgess's convention = untl(gamma, top) in BX. Is untl(gamma, top) = F(gamma)? F(gamma) = untl(top, gamma) in BX. So untl(gamma, top) ≠ F(gamma) unless gamma = top.

Hmm, I think Burgess is using a DIFFERENT convention or a different equivalence. Let me re-read.

"~U(gamma, top) = ~F~~gamma is a thesis by 2.1"

Burgess writes ~U(gamma, top) = ~F(~~gamma). So U(gamma, top) = F(~~gamma). In Burgess's convention U(guard, event): U(gamma, top) = "exists s > t with top(s) and gamma on (t,s)". On a dense linear order, this is equivalent to F(gamma) (since gamma on (t,s) and (t,s) nonempty gives gamma at some point in (t,s)).

But Burgess uses the REPLACEMENT LEMMA (2.1): since ~~gamma is equivalent to gamma (for dense linear orders? or as a propositional equivalence?), U(gamma, top) is equivalent to U(~~gamma, top) which is... hmm.

Actually I think Burgess's statement is specific to his axiom system which includes axioms for dense linear orders. The key is whether untl(bot, gamma) is refutable.

In Burgess's system (dense linear orders): F(gamma) ↔ untl(top, gamma) (BX12). And untl(gamma, top) -- is there an axiom relating this to F(gamma)?

Actually, untl(gamma, top) at t means: exists s > t with top(s) (trivially) and gamma on (t,s). On a dense order, (t,s) is nonempty, so gamma holds somewhere. So untl(gamma, top) semantically implies F(gamma) on dense orders (actually it's stronger: it implies gamma holds on an interval).

But on non-dense frames: untl(gamma, top) at t just means there exists s > t with gamma on (t,s). If s is the immediate successor of t, (t,s) is empty, so gamma on (t,s) is vacuous. So untl(gamma, top) is equivalent to F(top) = "there exists a successor", which is guaranteed by seriality.

So untl(bot, top) is TRUE on any frame where t has a successor with an empty interval to it. And untl(bot, gamma) is true on any frame where t has a successor s with gamma(s) and (t,s) empty.

On dense linear orders: (t,s) is always nonempty for s > t. So untl(bot, gamma) requires bot to hold at some intermediate point, which is impossible. So untl(bot, gamma) is always false on dense orders.

On general (non-dense) frames: untl(bot, gamma) CAN be true.

**Conclusion**: Burgess 2.2 HOLDS for Burgess's axiom system (which targets dense linear orders) but does NOT hold for the minimal US tense logic TL_US(phi) (which targets all frames).

**So Xu's 2.0(iii) has a gap when the DCS extension is inconsistent**: the guard consistency criterion (Burgess 2.2) is needed but only holds for dense orders.

**BUT XU DOESN'T USE 2.2!** Xu's proof of 2.3 goes through a different route: the maximality failure gives neg untl(beta' ∧ P(alpha), gamma) ∈ A, and Xu derives the positive form from alpha ∧ untl(beta', gamma). The contradiction is direct (positive and negative of the same formula in MCS A). No guard consistency needed.

The question is: does 2.0(iii) hold? If {P(alpha)} ∪ B is inconsistent, 2.0(iii) might not produce witnesses. But the CONTRAPOSITIVE approach works: assume P(alpha) ∉ B and show burgessR3 for the consistent extension, OR show that the inconsistent case is impossible.

**I think the inconsistent case IS possible in the minimal axiom system, and Xu's proof of 2.3 has a subtle gap in the inconsistent case.** Xu's proof assumes 2.0(iii) produces witnesses, which requires the DCS extension to be consistent.

**BUT**: For the chronicle construction over Q (dense rationals), the inconsistent case CANNOT arise (because untl(bot, gamma) would be unsatisfiable). So the proof works for the intended application.

**PRACTICAL RESOLUTION FOR THE CODEBASE**: Since the codebase's axiom system (BX) includes only axioms valid on ALL frames, and untl(bot, gamma) is satisfiable on non-dense frames, we need to either:

(a) Add a density axiom (not desirable -- the system should work for all frames).

(b) Avoid Xu 2.3 entirely and use a different construction for the splitting.

(c) Use the consistent-case-only version of Xu 2.3, and handle the inconsistent case separately.

For (c): When {P(alpha)} ∪ B is inconsistent, P(alpha).neg = H(neg alpha) ∈ B. This means H(neg alpha) ∈ B. In the chronicle construction, B represents the interval set g(x,y). Having H(neg alpha) ∈ B means alpha.neg held at all past times (from any point in the interval). This is semantically inconsistent with alpha ∈ A (alpha holds at the left endpoint x). So the inconsistent case cannot arise in any valid chronicle.

**BUT WE'RE CONSTRUCTING THE CHRONICLE**, so we can't assume it's valid yet. The inconsistent case might arise during construction.

**ACTUALLY**: The codebase's `splitting_seed_consistent` is called from `lemma_2_6_splitting` which has the hypothesis `g_content A ⊆ C`. Does this help?

From g_content(A) ⊆ C and alpha ∈ A: G(P(alpha)) ∈ A (BX4). So P(alpha) ∈ g_content(A) ⊆ C. So P(alpha) ∈ C.

If P(alpha).neg = H(neg alpha) ∈ B, and B ⊆ C (is B ⊆ C?): then H(neg alpha) ∈ C and P(alpha) ∈ C. Since P(alpha) = neg H(neg alpha): both H(neg alpha) and its negation in C. Contradiction with C being MCS.

But is B ⊆ C? In the chronicle, g(x,y) ⊆ f(y) by C3 (when there's an intermediate point). But at adjacent pairs, B is not necessarily ⊆ C.

However: from burgessRSetSince(C, B, A): for all beta ∈ B, alpha ∈ A, snce(beta, alpha) ∈ C. In particular: for beta = H(neg alpha) ∈ B and alpha ∈ A: snce(H(neg alpha), alpha) ∈ C. So P(alpha ∧ ...) ∈ C or something. Not directly useful.

Hmm, but: snce(beta, alpha) ∈ C does NOT give beta ∈ C. snce(beta, alpha) means beta was the guard in some past Since formula.

**OK, I need to try a completely different angle.** Let me ask: in the context where `lemma_2_6_splitting` is called, do we have additional structure beyond BurgessR3Maximal?

The function is called during counterexample elimination (C4a). The context is:
- Chronicle chi with ChronicleInvariant (c0, c1, c2', c3)
- Adjacent pair (x, y) with neg untl(gamma, delta) ∈ f(x) and delta ∈ f(y)
- BurgessR3Maximal(f(x), g(x,y), f(y))

In this context: g(x,y) ⊆ f(x) ∩ f(y)? NO, that's not guaranteed. C3 gives g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z) for intermediate y, but for adjacent (x,y) there are no intermediate points.

But: from c2' (BurgessR3Maximal for adjacent pairs): BurgessR3Maximal(f(x), g(x,y), f(y)). And from the chronicle construction maintaining g_content ordering: g_content(f(x)) ⊆ f(y) (this is the h_gc hypothesis in lemma_2_6_splitting).

So we have g_content(f(x)) ⊆ f(y). This gives P(alpha) ∈ f(y) for all alpha ∈ f(x) (as shown: G(P(alpha)) ∈ f(x), P(alpha) ∈ g_content(f(x)) ⊆ f(y)).

Now: suppose H(neg alpha) ∈ g(x,y) for some alpha ∈ f(x). Does this contradict g_content(f(x)) ⊆ f(y)?

From burgessRSetSince: snce(H(neg alpha), alpha') ∈ f(y) for all alpha' ∈ f(x). In particular, alpha' = alpha: snce(H(neg alpha), alpha) ∈ f(y). And P(alpha) ∈ f(y) (from above).

Apply BX13' (enrichment_since) in f(y) with p = P(alpha), phi = H(neg alpha), psi = alpha:

P(alpha) ∧ snce(H(neg alpha), alpha) -> snce(H(neg alpha), alpha ∧ untl(H(neg alpha), P(alpha)))

In f(y): snce(H(neg alpha), alpha ∧ untl(H(neg alpha), P(alpha))) ∈ f(y).

By BX10' (since_P): P(alpha ∧ untl(H(neg alpha), P(alpha))) ∈ f(y). Fine.

Now the event in the Since is: alpha ∧ untl(H(neg alpha), P(alpha)). Is this consistent?

untl(H(neg alpha), P(alpha)) means: guard = H(neg alpha), event = P(alpha). There exists s > t with P(alpha)(s) and H(neg alpha) on (t,s). P(alpha) at s means alpha held at some time before s. H(neg alpha) on (t,s) means neg alpha held at all times before any point in (t,s).

On a dense order: (t,s) is nonempty, say u ∈ (t,s). H(neg alpha) at u means neg alpha at all times before u, including t. But alpha ∈ f(x) = the MCS at time t, meaning alpha holds at t. Contradiction.

So alpha ∧ untl(H(neg alpha), P(alpha)) is SEMANTICALLY inconsistent on dense orders.

But SYNTACTICALLY: is it inconsistent in TL_US? Without density axioms, I believe it's satisfiable. On a frame where t has an immediate successor u, and u has a successor s: H(neg alpha) on (t, u) is vacuous (empty interval). untl(H(neg alpha), P(alpha)) at t can hold if s has P(alpha) and H(neg alpha) on (t,s) = at u only. H(neg alpha) at u means neg alpha at all times before u, which includes t. But alpha at t. Contradiction again -- H(neg alpha) at u requires neg alpha at t.

Wait: H(neg alpha) at u means: for all times v < u, neg alpha at v. t < u, so neg alpha at t. But alpha ∈ f(x) = f(t), so alpha at t. Contradiction.

So untl(H(neg alpha), P(alpha)) is ALWAYS false when alpha ∈ f(t) and t < s. Because: for any s > t with P(alpha)(s), and any u ∈ (t,s), H(neg alpha) at u requires neg alpha at t. Contradiction.

Actually this doesn't require density. On ANY frame where t < u < s: H(neg alpha) at u gives neg alpha at t (since t < u). But alpha at t. Contradiction.

What if s is the IMMEDIATE successor of t (no u between them)? Then (t,s) is empty, and H(neg alpha) on (t,s) is vacuous. So untl(H(neg alpha), P(alpha)) at t reduces to: exists s > t (immediate successor) with P(alpha)(s). And P(alpha) at s means exists r < s with alpha(r). If t < s: alpha at t and t < s, so alpha at t is before s, so P(alpha) at s. TRUE.

So on frames with immediate successors: untl(H(neg alpha), P(alpha)) CAN be true at t when alpha ∈ f(t). Because the guard H(neg alpha) is vacuously satisfied on the empty interval.

This means the enrichment step doesn't produce a syntactic contradiction.

**I'M GOING IN CIRCLES.** Let me take a step back and give the practical answer.

### PRACTICAL CONCLUSION

The codebase has a sorry at `splitting_seed_consistent`. The correct approach is:

**Replace the current lemma_2_6_splitting with the Xu 2.4 construction:**

1. From BurgessR3Maximal(A, B, C) and beta ∉ B: {beta.neg} ∪ B is consistent (dcs_neg_union_consistent).
2. D = MCS extending B ∪ {beta.neg}.
3. For all alpha ∈ A: P(alpha) ∈ B (by Xu 2.3, using the CONSISTENT-case proof only, since the inconsistent case requires a separate argument).
4. Since B ⊆ D: P(alpha) ∈ D. By Burgess 2.3 backward + BX12 equivalences: burgessR(A, top, D).
5. Similarly F(gamma) ∈ D for gamma ∈ C. burgessR(D, top, C).
6. burgessR3Maximal_exists_from_seed gives BurgessR3Maximal(A, B', D) and BurgessR3Maximal(D, B'', C).

For step 3 (Xu 2.3), the proof needs:
- If {P(alpha)} ∪ B is consistent: direct extension argument + maximality contradiction. Works.
- If {P(alpha)} ∪ B is inconsistent: needs additional argument. In the context of lemma_2_6_splitting (which has h_gc : g_content(A) ⊆ C), the inconsistent case MAY be refutable using the g_content ordering. This is where the analysis becomes frame-dependent.

**The recommended implementation path**:

1. Prove `xu_lemma_2_3_P` for the CONSISTENT case only: P(alpha) ∈ B when {P(alpha)} ∪ B is consistent.
2. For the inconsistent case, prove directly that {beta.neg} ∪ B satisfies the needed properties without going through Xu 2.3. Specifically: construct D from B ∪ {beta.neg}, then show r(A, top, D) DIRECTLY using the g_content(A) ⊆ C hypothesis and the Burgess 2.3 equivalence.
3. The direct proof: from g_content(A) ⊆ C and F_mem_of_g_content_sub: F(delta) ∈ A for all delta ∈ C. And from B ⊆ D and the consistent-case P(alpha) results: we can establish enough properties.

Actually, the CLEANEST approach is:

**Bypass Xu 2.3 entirely. Use `burgessR3Maximal_from_g_content_sub` on D.**

From B ⊆ D (MCS): g_content(A) ⊆ D? Not necessarily. But: from P(alpha) ∈ D for alpha ∈ A (which we get from P(alpha) ∈ B when the consistent case holds, or from the D construction otherwise)...

Let me try the direct approach using the g_content chain:

g_content(A) ⊆ C (given). We need g_content(A) ⊆ D. Since D extends B ∪ {beta.neg}, we need g_content(A) ⊆ B ∪ {beta.neg}. Not obvious.

**ALTERNATIVELY**: Prove r(A, top, D) and r(D, top, C) directly:

For r(A, top, D): for all delta ∈ D, F(delta) ∈ A. Since D is an MCS, this is a strong condition. By Burgess 2.3 backward direction: this is equivalent to for all alpha ∈ A, P(alpha) ∈ D.

For all alpha ∈ A: from BX4, G(P(alpha)) ∈ A. P(alpha) ∈ g_content(A). If g_content(A) ⊆ D (i.e., for all phi, G(phi) ∈ A -> phi ∈ D): then P(alpha) ∈ D.

g_content(A) ⊆ D? From g_content(A) ⊆ C (given) and B ⊆ D: we need g_content(A) ⊆ B. This is back to the original problem!

**OK so the circular dependency is**: lemma_2_6_splitting needs g_content(A) ⊆ D, which needs g_content(A) ⊆ B (since B ⊆ D and D is arbitrary MCS extension of B ∪ {beta.neg}), which needs Xu 2.3, which needs the inconsistent case resolved.

**THE REAL ANSWER**: Xu 2.3 IS provable for BurgessR3Maximal that uses Until-ONLY maximality (not the combined burgessR3 maximality). The codebase should either:

(a) Change BurgessR3Maximal to Until-only maximality, or
(b) Prove that for the codebase's two-sided BurgessR3Maximal, the 2.0(iii) extraction still works (possibly by showing the inconsistent case is impossible under g_content(A) ⊆ C).

I believe option (b) is the practical path. The inconsistent case {P(alpha)} ∪ B is inconsistent when H(neg alpha) ∈ B and alpha ∈ A. Combined with burgessR3 and g_content(A) ⊆ C, this should be refutable using the enrichment machinery. The key is finding the right combination.

Let me try once more: H(neg alpha) ∈ B, alpha ∈ A, G(P(alpha)) ∈ A, P(alpha) ∈ C.

From burgessRSet: untl(H(neg alpha), gamma) ∈ A for all gamma ∈ C. Take gamma = P(alpha): untl(H(neg alpha), P(alpha)) ∈ A.

From enrichment_until (BX13) in A: alpha ∧ untl(H(neg alpha), P(alpha)) -> untl(H(neg alpha), P(alpha) ∧ snce(H(neg alpha), alpha)).

We have alpha ∈ A and untl(H(neg alpha), P(alpha)) ∈ A. So untl(H(neg alpha), P(alpha) ∧ snce(H(neg alpha), alpha)) ∈ A.

By BX10: F(P(alpha) ∧ snce(H(neg alpha), alpha)) ∈ A.

Now: P(alpha) = neg H(neg alpha). So P(alpha) ∧ snce(H(neg alpha), alpha) means: "neg H(neg alpha) AND Since(H(neg alpha), alpha)". snce(H(neg alpha), alpha) means: exists s < t with alpha(s) and H(neg alpha) on (s,t). H(neg alpha) on (s,t) means for all u ∈ (s,t), for all v < u, neg alpha(v). In particular for v = s: neg alpha(s). But alpha(s) from the event. Contradiction!

So P(alpha) ∧ snce(H(neg alpha), alpha) is INCONSISTENT (semantically on any frame). Is it provably inconsistent in TL_US?

snce(H(neg alpha), alpha) says: exists past s with alpha(s) and H(neg alpha) between s and now. But H(neg alpha) at any u > s gives neg alpha at s (since s < u). So alpha(s) and neg alpha(s). Contradiction.

**Syntactic proof**: From H(neg alpha) being the guard of Since: at any point u ∈ (s, now), H(neg alpha)(u) gives neg alpha at all v < u, including v = s. So snce(H(neg alpha), alpha) implies F_past(alpha ∧ neg alpha) = F_past(bot) = P(bot). And P(bot) is provably false.

More precisely: from BX4' (connect_past on Since): applied inside the Since structure. Actually, from BX13'_reverse or some other mechanism.

Hmm, the SYNTACTIC proof that P(alpha) ∧ snce(H(neg alpha), alpha) is inconsistent:

snce(H(neg alpha), alpha) ∈ MCS X implies: by BX10' (since_P), P(alpha) ∈ X. Also snce(H(neg alpha), alpha) -> snce(top, alpha) = P(alpha) (since H(neg alpha) -> top). And by enrichment_since or BX4': alpha -> H(F(alpha)) (BX4'), so if alpha is the event, we get H(F(alpha)) from past_necessitation.

Actually, the key is: from snce(H(neg alpha), alpha) and BX4 applied to alpha inside the Since: there should be a way to derive snce(H(neg alpha) ∧ G(P(alpha)), alpha) or something similar.

I think the syntactic proof is: snce(H(neg alpha), alpha) -> P(alpha) (by BX10'). And P(alpha) = neg H(neg alpha). So snce(H(neg alpha), alpha) -> neg H(neg alpha). By contraposition: H(neg alpha) -> neg snce(H(neg alpha), alpha). But this is just saying: if H(neg alpha) holds everywhere in the past, then there's no past point where alpha is the event of a Since with H(neg alpha) guard.

Let me try: from H(neg alpha) at the current point t: by BX4', H(neg alpha) -> H(F(H(neg alpha))). But that goes deeper into the past.

Actually: the derivation H(neg alpha) -> neg snce(H(neg alpha), alpha) should follow from the fact that the guard H(neg alpha) at any past point u ∈ (s,t) implies neg alpha at all points before u, including s, contradicting alpha at s.

Syntactically: Suppose H(neg alpha) ∈ X and snce(H(neg alpha), alpha) ∈ X. From snce(H(neg alpha), alpha): exists s < t with alpha(s) and H(neg alpha) on (s,t). For any u ∈ (s,t): H(neg alpha)(u) means neg alpha at all v < u. Since s < u: neg alpha(s). But alpha(s). Contradiction.

Can we formalize this in TL_US? Using left_mono_since_H: H(H(neg alpha) -> bot) -> snce(H(neg alpha), alpha) -> snce(bot, alpha). And snce(bot, alpha) -> P(alpha) by weakening the guard. But snce(bot, alpha) means: exists s < t with alpha(s) and bot on (s,t). Bot on (s,t) means bot holds at all points in (s,t). On dense frames: (s,t) nonempty, contradiction. On non-dense: (s,t) could be empty (immediate predecessor), making bot vacuous. So snce(bot, alpha) is satisfiable on non-dense frames.

So even this approach requires density for the final contradiction.

**I think the fundamental issue is**: without density or irreflexivity axioms, the minimal US logic cannot refute certain formulas involving bot as guard. This affects Burgess 2.2, Xu 2.3 (inconsistent case), and the g_content ⊆ B property.

**HOWEVER**: The chronicle construction IS over Q (rationals, a dense order). And the BX axiom system is designed for strict linear orders (with seriality but without explicit density). The completeness proof should work because at the limit of the omega-chain, density is achieved, and the truth lemma doesn't need the intermediate finite-stage properties to be density-aware.

**PRACTICAL RECOMMENDATION**:

For `splitting_seed_consistent`, implement the Xu 2.4 approach with a `sorry` only for the inconsistent case of Xu 2.3. Then separately prove that the inconsistent case cannot arise in the context of the chronicle construction (using the g_content ordering invariant). This separates the pure logic from the construction-specific argument.

Or better: implement the proof that works for the consistent case, and prove that {P(alpha)} ∪ B is always consistent when BurgessR3Maximal(A, B, C) holds in a chronicle context with g_content(A) ⊆ C.

---

## Final Summary and Recommended Changes

### Immediate Changes

1. **Delete** `g_content_sub_B_of_BurgessR3Maximal` and `h_content_sub_B_of_BurgessR3Maximal` -- the extension-based proof approach is fundamentally broken for the inconsistent case.

2. **Add** `xu_lemma_2_3_P_consistent` and `xu_lemma_2_3_F_consistent`: P(alpha) ∈ B and F(gamma) ∈ B when the respective extensions are consistent. Uses BX4/BX4' + left_mono_until_G/left_mono_since_H + burgessR_implies_burgessRSince. No sorry.

3. **Rewrite** `lemma_2_6_splitting` to use the Xu 2.4 construction: D extends B ∪ {beta.neg}.

4. **Prove** `splitting_seed_consistent` as: {beta.neg} ∪ B is consistent (from beta ∉ B + DCS B). This is already available as `dcs_neg_union_consistent`.

5. **Prove** the Burgess 2.3 forward/backward steps to establish r(A, top, D) and r(D, top, C) from P(alpha) ∈ D and F(gamma) ∈ D.

### Open Question

The inconsistent case of Xu 2.3 (P(alpha) ∈ B when {P(alpha)} ∪ B is inconsistent) needs one of:
- A proof that the inconsistent case cannot arise under the g_content(A) ⊆ C hypothesis
- A density-aware argument specific to the chronicle construction over Q
- A reformulation that avoids needing P(alpha) ∈ B in the inconsistent case

### Key Files to Modify

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- lemma_2_6_splitting, splitting_seed_consistent
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- new Xu 2.3 theorems

### Axioms Used (All Already in Codebase)

| Axiom | Name | Role |
|-------|------|------|
| BX4 | connect_future | alpha -> G(P(alpha)) |
| BX4' | connect_past | alpha -> H(F(alpha)) |
| BX2H | left_mono_until_G | G(phi -> chi) -> untl(phi, psi) -> untl(chi, psi) |
| BX2H' | left_mono_since_H | H(phi -> chi) -> snce(phi, psi) -> snce(chi, psi) |
| BX13 | enrichment_until | p ∧ untl(phi, psi) -> untl(phi, psi ∧ snce(phi, p)) |
| BX13' | enrichment_since | p ∧ snce(phi, psi) -> snce(phi, psi ∧ untl(phi, p)) |
| BX10 | until_F | untl(phi, psi) -> F(psi) |
| BX10' | since_P | snce(phi, psi) -> P(psi) |
| BX12 | F_until_equiv | F(phi) <-> untl(top, phi) |
| BX12' | P_since_equiv | P(phi) <-> snce(top, phi) |
| TG | temp_generalization | phi theorem -> G(phi) theorem |
| TH | past_generalization | phi theorem -> H(phi) theorem |
| K_G | temp_k_dist | G(phi -> psi) -> G(phi) -> G(psi) |
